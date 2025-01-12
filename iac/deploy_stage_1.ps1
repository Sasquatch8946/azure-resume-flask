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
}
else  
{
    Write-Host "Key vault already exists."
}

$deploy = New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile "$PSScriptRoot/keyvault.bicep" -TemplateParameterObject @{"guidValue"=$guidValue}
$deploy.Outputs

$cosmos = Get-AzCosmosDBAccount -ResourceGroupName 'azureresume'
if (-Not($cosmos))
{
	Write-Host "Cosmos DB not found. Deploying..."
}
else
{
	Write-Host "Cosmos DB already exists."
}

$deploy2 = New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile "$PSScriptRoot/cosmosdb.bicep" -TemplateParameterObject @{"guidValue"=$guidValue} 
$deploy2.Outputs

$functionApp = Get-AzFunctionApp -ResourceGroupName 'azureresume'
if (-Not($functionApp))
{
	Write-Host "Function app not found."
}
else
{
	Write-Host "Function app already exists."
}

# deploying function app every time in order to update settings as needed
# able to re-deploy this resource over and over again without issue
$deploy3 = New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile "$PSScriptRoot/azfunc.bicep" -TemplateParameterObject @{"guidValue"=$guidValue}
$deploy3.Outputs


if ($env:keyVaultManager)
{
	Write-Host "Detected keyVaultManager, going to configure key vault access."
	$deploy4 = New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile "$PSScriptRoot/accesspol.bicep" -TemplateParameterObject @{"guidValue"=$guidValue; managedID="$($env:keyVaultManager)"}
	$deploy4.Outputs
}
else 
{
	Write-Host "keyVaultManager NOT configured"
}
