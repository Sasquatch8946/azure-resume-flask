param guidValue string
var kvName = 'kv${guidValue}'
param accessPolName string = 'kvAccessPol'
param managedID string

resource kv 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: kvName
}

// helpful link
// https://www.vanderveer.io/key-vault-access-policy-bicep/
resource accessPol 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  name: '${kvName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: managedID
        permissions: {
          secrets: ['get']
        }
        tenantId: tenant().tenantId
      }
    ]
  }
}
