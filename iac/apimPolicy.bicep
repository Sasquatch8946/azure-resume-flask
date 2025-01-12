param guidValue string
param apimServiceName string = 'apim${guidValue}' 

resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' existing = { 
  name: apimServiceName
}

resource api 'Microsoft.ApiManagement/service/apis@2023-09-01-preview' existing = { 
  name: 'hello'
  parent: apim
}

resource apiOperation 'Microsoft.ApiManagement/service/apis/operations@2023-09-01-preview' existing = { 
  name: 'getcloudresumecount'
  parent: api
}

resource apimPolicy 'Microsoft.ApiManagement/service/apis/operations/policies@2023-09-01-preview' = { 
  name: 'policy'
  parent: apiOperation  
  properties: {                                                        
    value: loadTextContent('./policy.xml') 
    format: 'rawxml'
  }
}
