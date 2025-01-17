param location string = 'centralus'
param guidValue string
param dbName string = 'CloudResume'
param dbAccountName string = 'cosmosacct${uniqueString(guidValue)}'
var keyVaultName = 'kv${guidValue}'

resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' = {
  name: dbAccountName
  kind: 'GlobalDocumentDB'
  location: location
  properties: {
    databaseAccountOfferType: 'Standard'
    publicNetworkAccess: 'Enabled'
    enableFreeTier: true
    capabilities: [
      { 
        name: 'EnableServerless'
      }
    ]
    locations: [
      { 
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }

    ]
  }
}

// database
resource cosmosDB 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-08-15' = {
  name: dbName // need to review error message
  parent: cosmosDBAccount
  properties: {
    resource: {
      id: dbName //id has to match with name above and be globally unique?
    }

  }
}

// container
resource cosmosContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2022-08-15' = {
  name: 'Counter'
  parent: cosmosDB
  properties: {
    resource: {
      id: 'Counter' // id has to match with name above
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/\'_etag\'/?'
          }
        ]
      }
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
        version: 2
      }
      conflictResolutionPolicy: {
        mode: 'LastWriterWins'
        conflictResolutionPath: '/_ts'
      }
    }
  }
}

module secretModule './kvsecret.bicep' = {
  name: 'cosmosDBSecret'
  params: {
    secretName: '${keyVaultName}/myCosmosDBAcct'
    secretValue: cosmosDBAccount.listConnectionStrings().connectionStrings[0].connectionString
  }

}

