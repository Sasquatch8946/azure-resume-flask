@description('SKU for the storage account')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Location for resources taken from resource group.')
param location string = resourceGroup().location

@description('Prefix for storage name.')
param prefixName string

var storageAccountName = '${prefixName}${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  properties: {}
}

resource existingVNet 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
  name: 'doesnotexist'
}

output storageAccountName string = storageAccountName
output vnetResult object = existingVNet
