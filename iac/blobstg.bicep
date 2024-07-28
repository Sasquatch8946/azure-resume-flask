param guidValue string
param location string = resourceGroup().location
var containerName = 'azresumefunc'

resource stgAcct 'Microsoft.Storage/storageAccounts@2023-05-01' = { 
  name: 'blobstg${guidValue}'
  kind: 'StorageV2'
  location: location
  sku: { 
    name: 'Standard_LRS'
  }
  properties: { 
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = { 
  name: '${stgAcct.name}/default/${containerName}'
}
