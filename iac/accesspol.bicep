param guidValue string
var kvName = 'kv${guidValue}'
param managedID string
param secretPerms array = [ 'get' ]
// helpful link
// https://www.vanderveer.io/key-vault-access-policy-bicep/
resource accessPol 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  name: '${kvName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: managedID
        permissions: {
          secrets: secretPerms
        }
        tenantId: tenant().tenantId
      }
    ]
  }
}
