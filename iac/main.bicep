param location string = resourceGroup().location
param guidValue string
var keyVaultName = 'kv${guidValue}'

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}


module azFunc './azfunc.bicep' = {
  name: 'funcDeploy'
  params: {
    cosmosDBConnectionString: keyVault.getSecret('myCosmosDBAcct')
    guidValue: guidValue
    packageUri: keyVault.getSecret('funcBlobURI')
    location: location
  }
}


