param guidValue string
param location string = resourceGroup().location
var apimName = 'apim${guidValue}'

resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' = { 
  name: apimName
  location: location
}
