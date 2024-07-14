param appName string = 'bicepFunc'
param location string = 'eastus'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${appName}-serviceplan'
  location: location
  sku: {
    name: 'F1'
    capacity: 1
  }
}

resource crcFunc 'Microsoft.Web/sites@2022-03-01' = {
  name: appName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}
