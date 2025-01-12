param guidValue string


resource kv 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = { 
  name: 'kv${guidValue}'
}

resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' existing = { 
  name: 'apim${guidValue}'
}
resource namedValue1 'Microsoft.ApiManagement/service/namedValues@2023-09-01-preview' = { 
  name: 'azresume-keyvault-ref'
  parent: apim
  properties: { 
    displayName: 'azresume-keyvault-ref'
    keyVault: { 
      secretIdentifier: '${kv.properties.vaultUri}secrets/azresume-func-key'
    }
    secret: true
  }
}
