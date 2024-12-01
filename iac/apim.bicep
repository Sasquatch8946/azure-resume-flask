param location string = 'centralus'
param guidValue string
var publisherName = 'Sean Chapman'
param apimServiceName string = 'apim${guidValue}'
var subscriptionName = 'azresume'
var keyVaultName = 'kv${guidValue}'

resource kv 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = { 
  name: 'kv${guidValue}'
}

resource funcApp 'Microsoft.Web/sites@2023-12-01' existing = { 
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
    serviceUrl: 'https://${funcApp.properties.defaultHostName}/api'
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
    subscriptionRequired: true 
    state: 'published'
    description: 'for Azure app service to use to call function api'
  }

}

resource apimProductApi 'Microsoft.ApiManagement/service/products/apis@2023-09-01-preview' = { 
  name: api.name
  parent: apimProduct
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

resource productSubscription 'Microsoft.ApiManagement/service/subscriptions@2023-09-01-preview' = { 
  name: subscriptionName
  parent: apim
  properties: { 
     displayName: subscriptionName
     scope: '/products/${apimProduct.id}'
     state: 'active'
  }
}

module accessPolModule 'accesspol.bicep' = {
  name: 'accessPolDeploy'
  params: { 
    guidValue: guidValue
    managedID: apim.identity.principalId
  }
}

module secretModule './kvsecret.bicep' = {
  name: 'apimSubUrl'
  params: {
    secretName: '${keyVaultName}/apimSubUrl'
    secretValue: 'https://${apim.name}.azure-api.net/hello/hello?subscription-key=${productSubscription.listSecrets().primaryKey}'
  }

}


