param location string = 'northcentralus'
param dbName string = 'CloudResume'
param appName string = 'crcBicepFunc'
param storageAccountType string = 'Standard_LRS'
param runtime string = 'python'

var storageAccountName = '${uniqueString(resourceGroup().id)}azfunctions'
var applicationInsightsName = appName
var functionWorkerRuntime = runtime

// Cosmos DB resources
// account
resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' = {
  name: 'crcdbaccount'
  kind: 'GlobalDocumentDB'
  location: location
  properties: {
    databaseAccountOfferType: 'Standard'
    /*locations: [
      {
        locationName: 'northcentralus'
        failoverPriority: 0
        isZoneRedundant: true

      }
      {
        locationName: 'southcentralus'
        failoverPriority: 1
        isZoneRedundant: true
      }
    ]*/
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

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${appName}-serviceplan'
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
  name: appName
  location: location
  kind: 'functionapp,linux' // need this or regular web app will be deployed that cannot use consumption plan
  // need to clear out the rg before redeploying
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.8'
      //pythonVersion: '3.8'
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

