Param
(
    [string]$guid
)

$kvName = "kv$guid"

$url = Get-AzKeyVaultSecret -VaultName $kvName -Name 'apimSubUrl' -AsPlainText

Write-Output "retrieved url $url"

$r = Invoke-RestMethod -Method GET $url 

$r
