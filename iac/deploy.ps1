$guidValue = '0qsyur9jgndia2l'
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
    $deploy = az deployment group create --resource-group 'azureresume' --template-file "$PSScriptRoot\keyvault.bicep" --parameters guidValue=$guidValue
    $deploy | gm
}
else  
{
    Write-Host "Key vault already exists."
}

az deployment group create --resource-group $rg --template-file './iac/main.bicep' --parameters guidValue=$guidValue keyVaultName=$kvName