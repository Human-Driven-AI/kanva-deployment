#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
container_app_name=""
custom_config=""
secret_permissions="get list"

while [[ $# -gt 0 ]]; do
    case $1 in
        --container-app-name)
            container_app_name="$2"
            shift 2
            ;;
        --custom-config)
            custom_config="$2"
            shift 2
            ;;
        --secret-permissions)
            secret_permissions="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

source "$SCRIPT_DIR/../utils/utils.sh"
source "$SCRIPT_DIR/../config/variables.sh"
if [[ -n "$custom_config" ]]; then
    source "$SCRIPT_DIR/../config/$custom_config"
fi

identity_name="${container_app_name}-identity"

# Check if the identity already exists
existing_identity=$(az identity show --name "$identity_name" --resource-group "$resourceGroupName" --query id --output tsv 2>/dev/null || echo "")

if [[ -n "$existing_identity" ]]; then
    write_log "Managed identity $identity_name already exists."
    principal_id=$(az identity show --name "$identity_name" --resource-group "$resourceGroupName" --query principalId --output tsv)
    identity_resource_id="$existing_identity"
else
    write_log "Creating container app managed identity $identity_name"
    principal_id=$(az identity create --name "$identity_name" --resource-group "$resourceGroupName" --query principalId --output tsv)
    identity_resource_id=$(az identity show --name "$identity_name" --resource-group "$resourceGroupName" --query id --output tsv)
fi

existing_policy=$(az keyvault show --name "$keyVaultName" --query "properties.accessPolicies[?objectId=='$principal_id']" -o tsv 2>/dev/null || echo "")

if [[ -n "$existing_policy" ]]; then
    write_log "Policy already exists for principalId $principal_id. Skipping policy creation."
else
    if [[ -n "$secret_permissions" ]]; then
        write_log "Creating Key Vault policy with permissions: $secret_permissions."
        az keyvault set-policy --name "$keyVaultName" --object-id "$principal_id" --secret-permissions $secret_permissions
    else
        write_log "No secret permissions specified, skipping policy creation."
    fi
fi

write_log "Done"

# Get the client ID of the managed identity
client_id=$(az identity show --name "$identity_name" --resource-group "$resourceGroupName" --query clientId --output tsv)

# Output the identity resource ID and client ID (can be captured by caller)
echo "IDENTITY_RESOURCE_ID=$identity_resource_id"
echo "CLIENT_ID=$client_id"
