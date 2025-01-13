param location string = 'centralus'
param guidValue string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'kv${guidValue}'
  location: location
  properties: {
    enabledForTemplateDeployment: true
    enablePurgeProtection: true 
    enableSoftDelete: true
    createMode: 'default'
    sku: {
      family: 'A'
      name: 'standard'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    tenantId: subscription().tenantId
  }




}

output keyVaultName string = keyVault.name
