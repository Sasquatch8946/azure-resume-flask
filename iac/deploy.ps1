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
    $deploy = New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile "$PSScriptRoot/keyvault.bicep"
    $deploy | gm
    $deploy.Outputs
}
else  
{
    Write-Host "Key vault already exists."
}

$deploy2 = New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile "$PSScriptRoot/main.bcep" -TemplateParameterFile "$PSScriptRoot/main.bicepparam"
$deploy2 | gm
$deploy2.Outputs