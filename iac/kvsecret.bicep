// https://learn.microsoft.com/en-us/azure/key-vault/secrets/quick-create-bicep?tabs=CLI
param secretName string
@secure()
param secretValue string

resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: secretName
  properties: {
    value: secretValue
  }
}


output secretUri string = secret.properties.secretUri
