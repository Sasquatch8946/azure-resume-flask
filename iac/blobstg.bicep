param guidValue string
param location string = resourceGroup().location
var containerName = 'azresumefunc'
var kvName = 'kv${guidValue}'

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

var blobEndpoint  = 'https://${stgAcct.name}.blob.${environment().suffixes.storage}'
var containerBlobEndpoint = 'https://${stgAcct.name}.blob.${environment().suffixes.storage}/${containerName}'

//SAS to upload blobs to just the mycontainer container.
var myContainerDownloadSAS = listServiceSAS(stgAcct.name,'2021-04-01', {
  canonicalizedResource: '/blob/${stgAcct.name}/${containerName}'
  signedResource: 'c'
  signedProtocol: 'https'
  signedPermission: 'r'
  signedServices: 'b'
  signedExpiry: '2024-09-01T00:00:00Z'
}).serviceSasToken

module sasSecret 'kvsecret.bicep' = {
  name: 'sasSecretDeploy'
  params: {
    secretName: '${kvName}/funcBlobURI'
    // need to include blob endpoint here
    secretValue: '${containerBlobEndpoint}?${myContainerDownloadSAS}'
  }
}
