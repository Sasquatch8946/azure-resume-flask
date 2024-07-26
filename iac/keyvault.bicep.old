param location string = resourceGroup().location
param appSvcManagedId string
param tenantId string = subscription().tenantId
param funcManagedId string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'azureresume-kv'
  location: location
  properties: {
    enabledForTemplateDeployment: true
    createMode: 'default'
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: [
      {
        objectId: appSvcManagedId
        tenantId: tenantId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
      {
        objectId: funcManagedId
        tenantId: tenantId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
    ]
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    tenantId: subscription().tenantId
  }



}
