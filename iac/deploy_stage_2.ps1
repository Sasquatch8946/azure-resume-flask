Param
(
    [string]$guidValue=${env:GUID}
)

Write-Host "GUIDVALUE: $guidValue"
$kvName = 'kv' + $guidValue
$rg = 'azureresume'

$apim = Get-AzApiManagement -ResourceGroupName $rg
if (-Not($apim))
{
    Write-Host "API management service not found. Deploying..."
    $deploy = New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile "$PSScriptRoot/apim.bicep" -TemplateParameterObject @{"guidValue"=$guidValue}
    $deploy.Outputs
    $deploy2 = New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile "$PSScriptRoot/namedvalue.bicep" -TemplateParameterObject @{"guidValue"=$guidValue}
    $deploy2.Outputs
    $deploy3 = New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile "$PSScriptRoot/apimPolicy.bicep" -TemplateParameterObject @{"guidValue"=$guidValue}
    $deploy3.Outputs

}
else  
{
    Write-Host "API management service already exists."
}

