Param
(
    [string]$guidValue=${env:GUID}
)
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
    $deploy = New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile "$PSScriptRoot/keyvault.bicep" -TemplateParameterObject @{"guidValue"=$guidValue}
    $deployOutputs
}
else  
{
    Write-Host "Key vault already exists."
}
$cosmos = Get-AzCosmosDBAccount -ResourceGroupName 'azureresume'
if (-Not($cosmos))
{
	$deploy2 = New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile "$PSScriptRoot/cosmosdb.bicep" 
	$deploy2.Outputs
}
else
{
	Write-Host "Cosmos DB already exists."
}

$functionApp = Get-AzFunctionApp -ResourceGroupName 'azureresume'
if (-Not($functionApp))
{
	$deploy3 = New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile "$PSScriptRoot/azfunc.bicep" 
	$deploy3.Outputs
}
else
{
	Write-Host "Function app already exists."
}
