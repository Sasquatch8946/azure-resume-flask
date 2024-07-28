param location string = resourceGroup().location
param guidValue string
param funcAppName string = 'crcfunc${guidValue}'
param runtime string = 'python'
var applicationInsightsName = funcAppName
var functionWorkerRuntime = runtime
var storageAccountName = 'stgacct${guidValue}'
param storageAccountType string = 'Standard_LRS'
@secure()
param cosmosDBConnectionString string
@description('The zip content url.')
@secure()
param packageUri string



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
  identity: {
    type: 'SystemAssigned'
  }
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
          value: cosmosDBConnectionString // need to get this from output of cosmos db file
        }
        {
          name: 'AzureWebJobsFeatureFlags'
          value: 'EnableWorkerIndexing'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
        { 
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: packageUri
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

resource functionAppName_ZipDeploy 'Microsoft.Web/sites/extensions@2021-02-01' = {
  name: '${funcAppName}/ZipDeploy'
  location: location
  properties: {
    packageUri: packageUri
  }
}
