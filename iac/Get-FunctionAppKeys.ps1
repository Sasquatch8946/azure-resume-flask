# This script gets azure function function key and stores it in keyvault for the API Management service to use later.
$guidValue = gc .\guid.txt

$secret = az functionapp keys list -n "crcfunc$guidValue" -g 'azureresume' | ConvertFrom-Json | select -expand  functionKeys | select -expand default

az keyvault secret set --vault-name "kv$guidValue" --name "azresume-func-key" --value $secret
