#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
custom_config="${1:-}"

source "$SCRIPT_DIR/../utils/utils.sh"
source "$SCRIPT_DIR/../config/variables.sh"
if [[ -n "$custom_config" ]]; then
    source "$SCRIPT_DIR/../config/$custom_config"
fi

write_log "Creating storage account $storageAccountName"

az storage account create \
    --name "$storageAccountName" \
    --resource-group "$resourceGroupName" \
    --location "$location" \
    --sku "$sku" \
    --kind "$kind" \
    --access-tier "$accessTier" \
    --enable-hierarchical-namespace true \
    --allow-blob-public-access true \
    --allow-cross-tenant-replication false \
    --min-tls-version TLS1_2 \
    --public-network-access Enabled

# Get the storage account key
storageAccountKey=$(az storage account keys list --resource-group "$resourceGroupName" --account-name "$storageAccountName" --query '[0].value' -o tsv)

# Create file share
az storage share create \
    --name "$fileShareName" \
    --account-name "$storageAccountName" \
    --account-key "$storageAccountKey" \
    --quota "$fileShareQuota"

config_file_to_use="${custom_config:-variables.sh}"
config_path="$SCRIPT_DIR/../config/$config_file_to_use"
update_config_variable "$config_path" "storageAccountKey" "$storageAccountKey"

# Display the storage account key
write_log "The new storage account key: $storageAccountKey has been written to $config_path" "$DARK_GREEN"
