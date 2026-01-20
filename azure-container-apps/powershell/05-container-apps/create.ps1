param(
    [string]$customConfig
)

. "$PSScriptRoot\..\utils\utils.ps1"
. "$PSScriptRoot\..\config\variables.ps1"
if ($customConfig) {
    . "$PSScriptRoot\..\config\$customConfig"
}

if (!(Test-ContainerAppJobExists -resourceGroupName $resourceGroupName -jobName $dbMigrationJobName)) {
    & "$PSScriptRoot\create-db-migration-job.ps1" -customConfig $customConfig
}
else {
    Write-Host "Skipping db migration job creation as it already exists" -ForegroundColor DarkGreen -BackgroundColor White
}

# Grant key vault access and get identity for hub
$hubIdentity = & "$PSScriptRoot\grant-key-vault-access.ps1" -containerAppName $hubAppName -customConfig $customConfig -secretPermissions @("delete", "get", "list", "set")

if (!(Test-ContainerAppExists -resourceGroupName $resourceGroupName -containerAppName $hubAppName)) {
    & "$PSScriptRoot\create-container-app-hub.ps1" -imageName "hub:$hubLatestImage" -containerAppName $hubAppName -containerName "kanva-hub" -customConfig $customConfig -identityResourceId $hubIdentity.IdentityResourceId -identityClientId $hubIdentity.ClientId
}
else {
    Write-Host "Skipping hub creation as it already exists" -ForegroundColor DarkGreen -BackgroundColor White
}

$hubUrl = az containerapp show `
    --name $hubAppName `
    --resource-group $resourceGroupName `
    --query "properties.configuration.ingress.fqdn" `
    --output tsv
$hubUrl = "https://$hubUrl"
$hubAgentUrl = "$hubUrl/hub-agent"

$configFileToUse = if ($customConfig) { $customConfig } else { "variables.ps1" }
$configPath = "$PSScriptRoot\..\config\$configFileToUse"
Update-ConfigVariable -ConfigFile $configPath -VariableName "hubUrl" -VariableValue $hubUrl
Update-ConfigVariable -ConfigFile $configPath -VariableName "hubAgentUrl" -VariableValue $hubAgentUrl

# Grant key vault access and get identity for delphi
$delphiIdentity = & "$PSScriptRoot\grant-key-vault-access.ps1" -containerAppName $delphiAppName -customConfig $customConfig

if (!(Test-ContainerAppExists -resourceGroupName $resourceGroupName -containerAppName $delphiAppName)) {
    & "$PSScriptRoot\create-container-apps-agent.ps1" -imageName "delphi:$delphiLatestImage" -containerAppName $delphiAppName -containerName "delphi" -customConfig $customConfig -identityResourceId $delphiIdentity.IdentityResourceId -identityClientId $delphiIdentity.ClientId
    & "$PSScriptRoot\mount-storage.ps1" -containerAppName $delphiAppName -customConfig $customConfig
}
else {
    Write-Host "Skipping data agent creation as it already exists" -ForegroundColor DarkGreen -BackgroundColor White
}

# Grant key vault access and get identity for pythoness
$pythonessIdentity = & "$PSScriptRoot\grant-key-vault-access.ps1" -containerAppName $pythonessAppName -customConfig $customConfig -secretPermissions @()

if (!(Test-ContainerAppExists -resourceGroupName $resourceGroupName -containerAppName $pythonessAppName)) {
    & "$PSScriptRoot\create-container-apps-agent.ps1" -imageName "pythoness:$pythonessLatestImage" -containerAppName $pythonessAppName -containerName "pythoness" -customConfig $customConfig -identityResourceId $pythonessIdentity.IdentityResourceId -identityClientId $pythonessIdentity.ClientId
    & "$PSScriptRoot\mount-storage.ps1" -containerAppName $pythonessAppName -customConfig $customConfig
}
else {
    Write-Host "Skipping training agent creation as it already exists" -ForegroundColor DarkGreen -BackgroundColor White
}