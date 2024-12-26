param guidValue string
param location string = 'centralus'
param appName string = 'crcapp${guidValue}-2'
param appServicePlanCapacity int = 1
param frontDoorEndpointName string = 'afd-${guidValue}-2'
param frontDoorSkuName string = 'Standard_AzureFrontDoor'

var appServicePlanName = 'appsvc${guidValue}'
var frontDoorProfileName = 'frontDoor${guidValue}'
var frontDoorOriginGroupName = 'MyOriginGroup'
var frontDoorOriginName = 'MyAppServiceOrigin'
var frontDoorRouteName = 'MyRoute'
var kvName = 'kv${guidValue}'
var secretName = 'apimSubUrl'

resource frontDoorProfile 'Microsoft.Cdn/profiles@2024-09-01' = {
  name: frontDoorProfileName
  location: 'global'
  sku: { 
    name: 'Standard_Microsoft'
  }
}

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

resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: frontDoorEndpointName
  parent: frontDoorProfile
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  name: frontDoorOriginGroupName
  parent: frontDoorProfile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 100
    }
  }
}

resource frontDoorOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  name: frontDoorOriginName
  parent: frontDoorOriginGroup
  properties: {
    hostName: app.properties.defaultHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: app.properties.defaultHostName
    priority: 1
    weight: 1000
  }
}

resource frontDoorRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: frontDoorRouteName
  parent: frontDoorEndpoint
  dependsOn: [
    frontDoorOrigin // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
  properties: {
    originGroup: {
      id: frontDoorOriginGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

output appServiceHostName string = app.properties.defaultHostName
output frontDoorEndpointHostName string = frontDoorEndpoint.properties.hostName


