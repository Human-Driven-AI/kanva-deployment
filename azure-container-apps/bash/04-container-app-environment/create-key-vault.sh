#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
custom_config="${1:-}"

source "$SCRIPT_DIR/../utils/utils.sh"
source "$SCRIPT_DIR/../config/variables.sh"
if [[ -n "$custom_config" ]]; then
    source "$SCRIPT_DIR/../config/$custom_config"
fi

if test_key_vault_exists "$resourceGroupName" "$keyVaultName"; then
    write_log "Key Vault $keyVaultName already exists."
    keyVaultUrl="https://$keyVaultName.vault.azure.net/"
else
    if test_key_vault_soft_deleted "$keyVaultName" "$location"; then
        write_log "Key Vault $keyVaultName is soft-deleted, purging. This may take a few minutes."
        az keyvault purge --location "$location" --name "$keyVaultName"
    fi

    write_log "Creating Key Vault $keyVaultName"
    publicNetworkAccess="Disabled"
    if [[ "$createPublicKeyVault" == "true" ]]; then
        publicNetworkAccess="Enabled"
    fi

    # Create the Key Vault
    keyVaultUrl=$(az keyvault create \
        --name "$keyVaultName" \
        --resource-group "$resourceGroupName" \
        --location "$location" \
        --sku Standard \
        --enable-rbac-authorization false \
        --public-network-access "$publicNetworkAccess" \
        --enabled-for-deployment false \
        --enabled-for-disk-encryption false \
        --enabled-for-template-deployment false \
        --retention-days 90 \
        --query "properties.vaultUri" \
        --output tsv)
fi

config_file_to_use="${custom_config:-variables.sh}"
config_path="$SCRIPT_DIR/../config/$config_file_to_use"
update_config_variable "$config_path" "keyVaultUrl" "$keyVaultUrl"

write_log "Done"
