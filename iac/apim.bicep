param location string = 'centralus'
param guidValue string
var publisherName = 'Sean Chapman'
param apimServiceName string = 'apim${guidValue}'
var namedValueName = 'azresume-keyvault-ref'
var rId = resourceId(resourceGroup().name, 'Microsoft.Web/sites', func.name)
var mgmtApi = environment().resourceManager
var myUri = '${environment().resourceManager}${rId}'
var absUrl = uri(mgmtApi, rId)

resource kv 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = { 
  name: 'kv${guidValue}'
}

resource func 'Microsoft.Web/sites/functions@2023-12-01' existing = { 
  name: 'crcfunc${guidValue}'
}

resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' = { 
  name: apimServiceName
  location: location
  sku: { 
    name: 'Consumption'
    capacity: 0
  }
  identity: { 
    type: 'SystemAssigned'
  }
  properties: { 
    publisherEmail: 'schapman684@gmail.com'
    publisherName: publisherName
  }
}

resource api 'Microsoft.ApiManagement/service/apis@2023-09-01-preview' = { 
  name: 'hello'
  parent: apim
  properties: { 
    displayName: 'crcfunc${guidValue}'
    description: 'Import from \'crcFunc${guidValue}\' function app.'
    path: 'hello'
    subscriptionRequired: true
    protocols: [
      'https'
    ]
    isCurrent: true
    subscriptionKeyParameterNames: {
      header: 'Ocp-Apim-Subscription-Key'
      query: 'subscription-key'
      }
  }
}


resource backend 'Microsoft.ApiManagement/service/backends@2017-03-01' = { 
  name: func.name
  parent: apim
  properties: { 
    protocol: 'http'
    url: 'https://${func.name}.azureweb'
    resourceId: absUrl
  }
}

// https://www.mikaelsand.se/2021/12/how-to-deploy-namedvalues-from-keyvault-in-apim-using-bicep/

resource KeyVaultSetting 'Microsoft.KeyVault/vaults/accessPolicies@2021-06-01-preview' = {
  name: 'add'
  parent: kv
  properties: {
    accessPolicies: [
      {
        objectId: apim.identity.principalId
        tenantId: apim.identity.tenantId
        permissions: {
          keys: []
          secrets: [
            'list'
            'get'
          ]
          certificates: []
        }
      }
    ]
  }
}

resource namedValue1 'Microsoft.ApiManagement/service/namedValues@2023-09-01-preview' = { 
  name: 'azresume-keyvault-ref'
  parent: apim
  properties: { 
    displayName: 'azresume-keyvault-ref'
    keyVault: { 
      secretIdentifier: '${kv.properties.vaultUri}secrets/azresume-func-key'
    }
    secret: true
  }
}


resource apimProduct 'Microsoft.ApiManagement/service/products@2023-09-01-preview' = { 
  name: 'crcfunc${guidValue}-product'
  parent: apim
  properties: { 
    displayName: 'crcfunc${guidValue}-product'
    subscriptionRequired: false 
    state: 'published'
  }
}

resource apiOperation 'Microsoft.ApiManagement/service/apis/operations@2023-09-01-preview' = { 
  name: 'getcloudresumecount'
  parent: api
  properties: { 
    displayName: 'getCloudResumeCount'
    method: 'GET'
    urlTemplate: '/hello'
  }
}

resource apimPolicy 'Microsoft.ApiManagement/service/apis/operations/policies@2023-09-01-preview' = { 
  name: 'policy'
  parent: apiOperation  
  properties: {                                                        
    value: loadTextContent('./policy.xml') 
    format: 'rawxml'
  }
}

