param guidValue string
param location string = 'centralus'
param appName string = 'crcapp${guidValue}'
param appServicePlanCapacity int = 1
param frontDoorEndpointName string = 'afd-${guidValue}'

var appServicePlanName = 'appsvc${guidValue}'
var frontDoorProfileName = 'frontDoor${guidValue}'
var kvName = 'kv${guidValue}'
var secretName = 'apimSubUrl'

resource appServicePlan 'Microsoft.Web/serverFarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  properties: { 
    maximumElasticWorkerCount: 1
    targetWorkerCount: 0
    targetWorkerSizeId: 0 
    hyperV: false
    isSpot: false 
    isXenon: false 
    perSiteScaling: false
    reserved: true
    
  }
  sku: {
    name: 'F1'
    capacity: appServicePlanCapacity
    family: 'F'
    size: 'F1'
    tier: 'Free'
  }
  kind: 'linux'
}

resource app 'Microsoft.Web/sites@2020-06-01' = {
  name: appName
  location: location
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    clientAffinityEnabled: true 
    clientCertEnabled: false 
    clientCertMode: 'Required'
    containerSize: 0
    dailyMemoryTimeQuota: 0
    enabled: true 
    redundancyMode: 'None'
    reserved: true
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: false 
      http20Enabled: true 
      acrUseManagedIdentityCreds: false 
      linuxFxVersion: 'PYTHON|3.10'
      numberOfWorkers: 1
      detailedErrorLoggingEnabled: true
      httpLoggingEnabled: true
      requestTracingEnabled: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        { 
          name: 'ENVIRONMENT'
          value: 'production'
        }
        { 
          name: 'FUNCTION_URL'
          value: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=${secretName})'

        }
        { 
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'True'
        }
        { 
          name: 'WEBSITE_HTTPLOGGING_RETENTION_DAYS'
          value: '3'
        }
      ]
    }
  }
}

module accessPol '../accesspol.bicep' = { 
  name: 'keyVaultAccessForAppSvc'
  params: { 
    guidValue: guidValue 
    managedID: app.identity.principalId
  }
}

module frontDoor './frontdoor-standard-custom-domain.bicep' = { 
  name: 'frontDoor'
  params: { 
    customDomainName: 'test.seanchapman.xyz'
    guidValue: guidValue
    originHostName: app.properties.defaultHostName
    endpointName: 'afd-${guidValue}'
    skuName: 'Standard_AzureFrontDoor'
  }
}
output appServiceHostName string = app.properties.defaultHostName


