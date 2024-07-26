// param guidValue string = newGuid()
param location string = resourceGroup().location
param guidValue string = 'vcdsrtnwblmn6'


module cosmosDeploy './cosmosdb.bicep' = {
  name: 'cosmosDB'
  params: {
    guidValue: guidValue
    location: location
  }
}

output secretsUri string = cosmosDeploy.outputs.secretUri
output cString string = cosmosDeploy.outputs.cString
