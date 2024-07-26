az account set -s 'a937970b-f2d4-4fba-a46d-b7a3096592c8'

az deployment group create --resource-group 'azureresume' --template-file 'main.bicep'