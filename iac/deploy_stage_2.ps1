Param
(
    [string]$guidValue=${env:GUID}
)

$kvName = 'kv' + $guidValue
$rg = 'azureresume'

$apim = Get-AzApiManagement -ResourceGroupName $rg
if (-Not($apim))
{
    Write-Host "API management service not found. Deploying..."
    $deploy = New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile "$PSScriptRoot/apim.bicep" -TemplateParameterObject @{"guidValue"=$guidValue}
    $deploy.Outputs
}
else  
{
    Write-Host "API management service already exists."
}

# Get-AzApiManagementNamedValue
$apimContext = New-AzApiManagementContext -ResourceGroupName $rg -ServiceName "apim$guidValue"
$namedValue = Get-AzApiManagementNamedValue -Context $apimContext -Name "azresume-keyvault-ref"
if (-Not($namedValue))
{
    Write-Host "API management named value not found. Deploying named value and policy..."
    $deploy2 = New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile "$PSScriptRoot/namedvalue.bicep" -TemplateParameterObject @{"guidValue"=$guidValue}
    $deploy2.Outputs
    $deploy3 = New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile "$PSScriptRoot/apimPolicy.bicep" -TemplateParameterObject @{"guidValue"=$guidValue}
    $deploy3.Outputs

}
else  
{
    Write-Host "API management named value already exists."
}
