param cdnName string = 'crcwebsite'

// storage account to host static website
resource stgacct 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: cdnName
  location: 'eastus'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {

  }
}

// cdn profile
resource cdn 'Microsoft.Cdn/profiles@2022-11-01-preview' = {
  name: cdnName
  location: 'Global'
  sku: {
    name: 'Standard_Microsoft'
  }
}

// cdn endpoint
resource endpt 'Microsoft.Cdn/profiles/endpoints@2022-11-01-preview' = {
  name: '${cdnName}endpoint'
  parent: cdn
  location: 'Global'
  properties: {
    origins: [

    ]
  }
}
