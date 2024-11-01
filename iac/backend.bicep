param guidValue string
var apimServiceName = 'apim${guidValue}-2'
var rId = resourceId(resourceGroup().name, 'Microsoft.Web/sites', func.name)
var mgmtApi = environment().resourceManager
var myUri = '${environment().resourceManager}${rId}'
var absUrl = uri(mgmtApi, rId)
resource func 'Microsoft.Web/sites/functions@2023-12-01' existing = { 
  name: 'crcfunc${guidValue}'
}

resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' existing = { 
  name: apimServiceName
}

resource backend 'Microsoft.ApiManagement/service/backends@2017-03-01' = { 
  name: 'test'
  parent: apim
  properties: { 
    protocol: 'http'
    url: 'https://crcfunc${guidValue}.azureweb'
    resourceId: absUrl
    //resourceId: 'https://management.azure.com/subscriptions/{yoursubscriptionID}/resourceGroups/{yourresourcegroupname}/providers/Microsoft.Web/sites/{functionappname}'
  }
}

output fID string = absUrl

