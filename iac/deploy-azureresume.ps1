if (!(Get-AzContext) -or ((Get-AzContext).Tenant.Id -ne $ENV:AZURE_TENANT_ID))
{
    Connect-AzAccount -Subscription $ENV:AZURE_SUBSCRIPTION_ID -Tenant $ENV:AZURE_TENANT_ID
}

# Initial setup
# New-AzResourceGroup -location 'southcentralus' -name 'azureresume'