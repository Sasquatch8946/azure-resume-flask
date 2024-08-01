param guidValue string
param funcAppName string = 'crcfunc${guidValue}'
param location string = resourceGroup().location
@secure()
param packageUri string

resource functionAppName_ZipDeploy 'Microsoft.Web/sites/extensions@2021-02-01' = {
  name: '${funcAppName}/ZipDeploy'
  location: location
  properties: {
    packageUri: packageUri
    appOffline: true
  }
}
