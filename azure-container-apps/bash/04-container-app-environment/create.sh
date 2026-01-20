#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
custom_config="${1:-}"

source "$SCRIPT_DIR/../utils/utils.sh"
source "$SCRIPT_DIR/../config/variables.sh"
if [[ -n "$custom_config" ]]; then
    source "$SCRIPT_DIR/../config/$custom_config"
fi

if test_log_analytics_workspace_exists "$resourceGroupName" "$logAnalyticsWorkspaceName"; then
    write_log "Log Analytics workspace $logAnalyticsWorkspaceName already exists."
else
    write_log "Creating Log Analytics workspace $logAnalyticsWorkspaceName"
    az monitor log-analytics workspace create --resource-group "$resourceGroupName" --workspace-name "$logAnalyticsWorkspaceName"
fi

# Retrieve the log workspace ID and key
workspaceId=$(az monitor log-analytics workspace show \
    --resource-group "$resourceGroupName" \
    --workspace-name "$logAnalyticsWorkspaceName" \
    --query customerId \
    --output tsv)
workspaceKey=$(az monitor log-analytics workspace get-shared-keys \
    --resource-group "$resourceGroupName" \
    --workspace-name "$logAnalyticsWorkspaceName" \
    --query primarySharedKey \
    --output tsv)

if test_container_app_environment_exists "$containerAppEnvName" "$resourceGroupName"; then
    write_log "Container App Environment '$containerAppEnvName' already exists."
else
    write_log "Creating container app environment $containerAppEnvName"
    az containerapp env create \
        --name "$containerAppEnvName" \
        --resource-group "$resourceGroupName" \
        --location "$location" \
        --logs-destination log-analytics \
        --logs-workspace-id "$workspaceId" \
        --logs-workspace-key "$workspaceKey"

    write_log "Linking storage account $storageAccountName to container app environment"
    az containerapp env storage set --name "$containerAppEnvName" \
        --resource-group "$resourceGroupName" \
        --storage-name "$fileShareName" \
        --azure-file-account-name "$storageAccountName" \
        --azure-file-account-key "$storageAccountKey" \
        --azure-file-share-name "$fileShareName" \
        --access-mode ReadWrite
fi

"$SCRIPT_DIR/create-key-vault.sh" "$custom_config"

write_log "Done"
