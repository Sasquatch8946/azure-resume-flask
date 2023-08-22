param appName string = 'bicepFunc'
param location string = 'eastus'


resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' = {
  name: 'crcDBAccount'
  kind: 'GlobalDocumentDB'
  location: location
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: 'eastus'
        failoverPriority: 0
        isZoneRedundant: true

      }
      {
        locationName: 'eastus2'
        failoverPriority: 1
        isZoneRedundant: true
      }
    ]
    publicNetworkAccess: 'Enabled'
  }
}

resource cosmosDB 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-08-15' = {
  name: 'crcDB' // need to review error message
  parent: cosmosDBAccount
  properties: {
    resource: {
      id: 'cloudResume'
    }

  }
}

resource cosmosContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2022-08-15' = {
  name: 'Counter'
  parent: cosmosDB
  properties: {
    resource: {
      id: 'Counter'
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

resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: '${appName}_serviceplan'
  location: location
  sku: {
    name: 'F1'
    capacity: 1
  }
}

resource crcFunc 'Microsoft.Web/sites@2022-03-01' = {
  name: appName
  location: location
}
