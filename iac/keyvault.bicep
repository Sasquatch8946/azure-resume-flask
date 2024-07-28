param location string = resourceGroup().location
param guidValue string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'kv${guidValue}'
  location: location
  properties: {
    enabledForTemplateDeployment: true
    createMode: 'default'
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: []
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    tenantId: subscription().tenantId
  }



}

output keyVaultName string = keyVault.name
