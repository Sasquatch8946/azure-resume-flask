param guidValue string
param location string = resourceGroup().location
var apimName = 'apim${guidValue}'
param publisherEmail string
param publisherName string
param funcName string
var apiName = 'azfunc'
var appRoute = 'hello'


resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' = { 
  name: apimName
  location: location
  sku: { 
    capacity: 0
    name: 'Consumption'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

resource api 'Microsoft.ApiManagement/service/apis@2023-09-01-preview' = { 
  name: '${apimName}/${apiName}'
  properties: {
    displayName: apiName
    subscriptionRequired: true
    apiRevision: '1'
    description: 'Import from getandupdatecounter Function App'
    path: 'hello'
    protocols: [
      'https'
    ]
  }
}

resource backend 'Microsoft.ApiManagement/service/backends@2023-09-01-preview' = {
  name: '${apimName}/${funcName}'
  properties: {
    url: 'https://${funcName}.azurewebsites.net/api/${appRoute}'
    protocol: 'http'
    title: 'GetAndUpdateCounter'
    
  }
}

// need named values as well
resource apiPolicy 'Microsoft.ApiManagement/service/apis/operations/policies@2023-09-01-preview' = {
  name: '${apimName}/${apiName}/hello/GET'
  properties: {
    format: 'xml'
    value: '<policies>\r\n  <inbound>\r\n    <base />\r\n    <set-backend-service base-url=\'https://${funcName}.azurewebsites.net/api/\' />\r\n    <set-header name=\'x-functions-key\' exists-action=\'append\'>\r\n      <value>{{getandupdatecounter-key}}</value>\r\n    </set-header>\r\n    <set-query-parameter name=\'code\' exists-action=\'override\'>\r\n      <value>{{azresume-kv-ref}}</value>\r\n    </set-query-parameter>\r\n    <rate-limit calls=\'20\' renewal-period=\'90\' remaining-calls-variable-name=\'remainingCallsPerSubscription\' />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
  }
}
