$guidValue = 'fptre98g3qaybku'
$kvName = 'kv' + $guidValue
# if key vault not exist, create
# else get existing key vault for use in bicep deployment
$rg = 'azureresume'
if ((Get-AzContext).Subscription.Id -ne $env:AZURE_SUBSCRIPTION_ID)
{
    Write-Error "need to change subscription"
    Exit 1
}

$kv = Get-AzKeyVault -ResourceGroupName $rg -VaultName $kvName
if (-Not($kv))
{
    Write-Host "Key vault not found. Deploying..."
    New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile "$PSScriptRoot\keyvault.bicep" -TemplateParameterFile "$PSScriptRoot\main.bicepparam"
}
else
{
    Write-Host "Key vault already exists."
}

# New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile "$PSScriptRoot\main.bicep" -TemplateParameterFile "$PSScriptRoot\main.bicepparam"

az deployment group create --resource-group $rg --template-file "$PSScriptRoot\cosmosdb.bicep" --parameters guidValue=$guidValue

az deployment group create --resource-group $rg --template-file "$PSScriptRoot\main.bicep" --parameters guidValue=$guidValue
