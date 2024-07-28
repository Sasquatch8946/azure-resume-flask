param location string = resourceGroup().location
param guidValue string
param keyVaultName string


resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = { 
  name: keyVaultName
}

module cosmosDB './cosmosdb.bicep' = { 
  name: 'cosmosDeploy'
  params: { 
    guidValue: guidValue
    location: location
    keyVaultName: keyVaultName
  }
}  

module azFunc './azfunc.bicep' = { 
  name: 'funcDeploy'
  params: { 
    cosmosDBConnectionString: keyVault.getSecret('myCosmosDBAcct')
    guidValue: guidValue
    packageUri: keyVault.getSecret('funcBlobURI')
  }
  dependsOn: [ 
    cosmosDB
  ]
}

