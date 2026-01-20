param(
    [string]$customConfig
)

. "$PSScriptRoot\..\utils\utils.ps1"
. "$PSScriptRoot\..\config\variables.ps1"
if ($customConfig) {
    . "$PSScriptRoot\..\config\$customConfig"
}

$logWorkspaceExists = Test-LogAnalyticsWorkspaceExists -resourceGroupName $resourceGroupName -workspaceName $logAnalyticsWorkspaceName
if ($logWorkspaceExists) {
    Write-Log "Log Analytics workspace $logAnalyticsWorkspaceName already exists."
}
else {
    Write-Log "Creating Log Analytics workspace $logAnalyticsWorkspaceName"
    az monitor log-analytics workspace create --resource-group $resourceGroupName --workspace-name $logAnalyticsWorkspaceName
}

# Retrieve the log workspace ID and key
$workspaceId = az monitor log-analytics workspace show `
    --resource-group $resourceGroupName `
    --workspace-name $logAnalyticsWorkspaceName `
    --query customerId `
    --output tsv
$workspaceKey = az monitor log-analytics workspace get-shared-keys `
    --resource-group $resourceGroupName `
    --workspace-name $logAnalyticsWorkspaceName `
    --query primarySharedKey `
    --output tsv

$envExists = Test-ContainerAppEnvironmentExists -containerAppEnvName $containerAppEnvName -resourceGroupName $resourceGroupName -customConfig $customConfig
if ($envExists -eq $containerAppEnvName) {
    Write-Log "Container App Environment '$containerAppEnvName' already exists."
}
else {
    Write-Log "Creating container app environment $containerAppEnvName"
    az containerapp env create `
        --name $containerAppEnvName `
        --resource-group $resourceGroupName `
        --location $location `
        --logs-destination log-analytics `
        --logs-workspace-id $workspaceId `
        --logs-workspace-key $workspaceKey

    Write-Log "Linking storage account $storageAccountName to container app environment"
    az containerapp env storage set --name $containerAppEnvName `
        --resource-group $resourceGroupName `
        --storage-name $fileShareName `
        --azure-file-account-name $storageAccountName `
        --azure-file-account-key $storageAccountKey `
        --azure-file-share-name $fileShareName `
        --access-mode ReadWrite
}

& "$PSScriptRoot\create-key-vault.ps1" -customConfig $customConfig

Write-Log "Done"