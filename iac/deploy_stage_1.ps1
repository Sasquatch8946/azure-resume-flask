Param
(
    [string]$guidValue=${env:GUID}
)
Write-Host "GUIDVALUE: $guidValue"
$kvName = 'kv' + $guidValue
# if key vault not exist, create
# else get existing key vault for use in bicep deployment
$rg = 'azureresume'

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
	Write-Host "Cosmos DB not found. Deploying..."
	$deploy2 = New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile "$PSScriptRoot/cosmosdb.bicep" -TemplateParameterObject @{"guidValue"=$guidValue} 
	$deploy2.Outputs
}
else
{
	Write-Host "Cosmos DB already exists."
}

$functionApp = Get-AzFunctionApp -ResourceGroupName 'azureresume'
if (-Not($functionApp))
{
	Write-Host "Function app not found. Deploying..."
	$deploy3 = New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile "$PSScriptRoot/azfunc.bicep" -TemplateParameterObject @{"guidValue"=$guidValue}
	$deploy3.Outputs
}
else
{
	Write-Host "Function app already exists."
}
