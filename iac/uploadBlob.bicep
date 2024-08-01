param utcValue string = utcNow()
param location string = resourceGroup().location
param guidValue string
var stgAcctName = 'blobstg${guidValue}'
// param fileName string = 'F:\azure_resume_flask\\iac\\azfunc.zip'
param containerName string = 'azresumefunc'

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name:stgAcctName
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployscript-upload-blob-${utcValue}'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '12.0'
    timeout: 'PT5M'
    retentionInterval: 'PT1H'
    environmentVariables: [
      {
        name: 'AZURE_STORAGE_ACCOUNT'
        value: storage.name
      }
      {
        name: 'AZURE_STORAGE_KEY'
        secureValue: storage.listKeys().keys[0].value
      }
    ]
    scriptContent: 'Set-AzStorageBlobContent -File "F:\\azure_resume_flask\\iac\\azfunc.zip" -Container ${containerName} -Blob "azfunc.zip"'
  }
}
