param location string = 'centralus'
param guidValue string
param funcAppName string = 'crcfunc${guidValue}'
param runtime string = 'python'
var applicationInsightsName = funcAppName
var functionWorkerRuntime = runtime
var storageAccountName = 'stgacct${guidValue}'
param storageAccountType string = 'Standard_LRS'
var kvName = 'kv${guidValue}'
var settingName = 'MyAccount_COSMOSDB'
var secretName = 'myCosmosDBAcct'



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
    //computeMode: 'Dynamic'
    reserved: true
  }
}

resource crcFunc 'Microsoft.Web/sites@2022-03-01' = {
  name: funcAppName
  location: location
  kind: 'functionapp,linux' // need this or regular web app will be deployed that cannot use consumption plan
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanFunctionApp.id
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.10'
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
          name: settingName
          value: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=${secretName})'
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
          value: '1'
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

module accessPolModule 'accesspol.bicep' = {
  name: 'accessPolDeploy'
  params: { 
    guidValue: guidValue
    managedID: crcFunc.identity.principalId
  }
}

output url string = '${crcFunc.properties.defaultHostName}/api'
