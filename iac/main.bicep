param funcAppName string = 'getandupdatecounter'
param location string = resourceGroup().location
param cdnName string = 'azureresumecdn'
param dbName string = 'CloudResume'
param appName string = 'bicepfunc${uniqueString(resourceGroup().id)}'
param storageAccountType string = 'Standard_LRS'
param runtime string = 'python'

var storageAccountName = '${uniqueString(resourceGroup().id)}azfunctions'
var applicationInsightsName = appName
var functionWorkerRuntime = runtime

// web app params
param webAppName string = uniqueString(resourceGroup().id) // Generate unique String for web app name
param sku string = 'F1' // The SKU of App Service Plan
param linuxFxVersion string = 'PYTHON|3.10' // The runtime stack of web app
param repositoryUrl string = 'https://github.com/Azure-Samples/nodejs-docs-hello-world'
param branch string = 'main'
var appServicePlanName = toLower('AppServicePlan-${webAppName}')
var webSiteName = toLower('wapp-${webAppName}')

// START Azure App Service

resource appServicePlanAppService 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: sku
  }
  kind: 'linux'
}

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: webSiteName
  location: location
  properties: {
    serverFarmId: appServicePlanAppService.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
    }
  }
}

resource srcControls 'Microsoft.Web/sites/sourcecontrols@2021-01-01' = {
  name: '${appServicePlanAppService.name}/web'
  properties: {
    repoUrl: repositoryUrl
    branch: branch
    isManualIntegration: true
  }
}

// END Azure App Service

// START cosmosdb2.bicep
// Cosmos DB resources
// account
resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' = {
  name: 'crcdbaccount'
  kind: 'GlobalDocumentDB'
  location: location
  properties: {
    databaseAccountOfferType: 'Standard'
    publicNetworkAccess: 'Enabled'
  }
}

// database
resource cosmosDB 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-08-15' = {
  name: dbName // need to review error message
  parent: cosmosDBAccount
  properties: {
    enableFreeTier: true
    resource: {
      id: dbName //id has to match with name above and be globally unique?
    }

  }
}

// container
resource cosmosContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2022-08-15' = {
  name: 'Counter'
  parent: cosmosDB
  properties: {
    resource: {
      id: 'Counter' // id has to match with name above
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/\'_etag\'/?'
          }
        ]
      }
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
        version: 2
      }
      conflictResolutionPolicy: {
        mode: 'LastWriterWins'
        conflictResolutionPath: '/_ts'
      }
    }
  }
}

// Beginning of Function App resources

// storage account

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
  }
}

resource appServicePlanFunctionApp 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${funcAppName}-serviceplan'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
  properties: {
    computeMode: 'Dynamic'
    reserved: true
  }
}

resource crcFunc 'Microsoft.Web/sites@2022-03-01' = {
  name: funcAppName
  location: location
  kind: 'functionapp,linux' // need this or regular web app will be deployed that cannot use consumption plan
  // need to clear out the rg before redeploying
  properties: {
    serverFarmId: appServicePlanFunctionApp.id
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.10'
      //pythonVersion: '3.10'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
        }
        {
          name: 'myAccount_COSMOSDB'
          value: cosmosDBAccount.listConnectionStrings().connectionStrings[0].connectionString // considered best practice to use kv reference instead
        }
        {
          name: 'AzureWebJobsFeatureFlags'
          value: 'EnableWorkerIndexing'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
      ]
      //linuxFxVersion:'Python|3.9'
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}

resource siteConfig 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'web'
  parent: crcFunc
  properties: {
    cors: {
      allowedOrigins: [
          'https://www.seanchapman.xyz'
          'https://portal.azure.com'
      ]
      supportCredentials: false
    }

  }
}


resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

// END cosmosdb2.bicep

// cdn profile
resource cdn 'Microsoft.Cdn/profiles@2022-11-01-preview' = {
  name: cdnName
  location: 'Global'
  sku: {
    name: 'Standard_Microsoft'
  }
}

// cdn endpoint
resource endpt 'Microsoft.Cdn/profiles/endpoints@2022-11-01-preview' = {
  name: '${cdnName}endpoint'
  parent: cdn
  location: 'Global'
  properties: {
    isHttpAllowed: true
    isHttpsAllowed: true
    queryStringCachingBehavior: 'IgnoreQueryString'
    origins: [
      {
        name: 'origin1'
        properties: {
          // https://stackoverflow.com/questions/72881498/how-to-get-the-host-url-of-a-linux-app-service-in-azure-bicep-deployment-templat
          hostName: 'https://${appService.properties.defaultHostName}'
        }
      }
    ]
  }
}

// custom domain
resource customDomain 'Microsoft.Cdn/profiles/endpoints/customDomains@2023-07-01-preview' = {
  name: 'www.seanchapman.xyz'
  parent: endpt
  properties: {
    hostName: 'www.seanchapman.xyz'
  }
}
