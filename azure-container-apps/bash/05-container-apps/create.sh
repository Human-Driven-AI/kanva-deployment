#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
custom_config="${1:-}"

source "$SCRIPT_DIR/../utils/utils.sh"
source "$SCRIPT_DIR/../config/variables.sh"
if [[ -n "$custom_config" ]]; then
    source "$SCRIPT_DIR/../config/$custom_config"
fi

# Helper function to parse identity output
parse_identity_output() {
    local output="$1"
    IDENTITY_RESOURCE_ID=$(echo "$output" | grep "IDENTITY_RESOURCE_ID=" | cut -d'=' -f2)
    CLIENT_ID=$(echo "$output" | grep "CLIENT_ID=" | cut -d'=' -f2)
}

# Create DB migration job if it doesn't exist
if ! test_container_app_job_exists "$resourceGroupName" "$dbMigrationJobName"; then
    "$SCRIPT_DIR/create-db-migration-job.sh" "$custom_config"
else
    echo "Skipping db migration job creation as it already exists"
fi

# Grant key vault access and get identity for hub
hub_identity_output=$("$SCRIPT_DIR/grant-key-vault-access.sh" \
    --container-app-name "$hubAppName" \
    --custom-config "$custom_config" \
    --secret-permissions "delete get list set")
parse_identity_output "$hub_identity_output"
hub_identity_resource_id="$IDENTITY_RESOURCE_ID"
hub_client_id="$CLIENT_ID"

if ! test_container_app_exists "$resourceGroupName" "$hubAppName"; then
    "$SCRIPT_DIR/create-container-app-hub.sh" \
        --image-name "hub:$hubLatestImage" \
        --container-app-name "$hubAppName" \
        --container-name "kanva-hub" \
        --custom-config "$custom_config" \
        --identity-resource-id "$hub_identity_resource_id" \
        --identity-client-id "$hub_client_id"
else
    echo "Skipping hub creation as it already exists"
fi

# Get hub URL
hub_fqdn=$(az containerapp show \
    --name "$hubAppName" \
    --resource-group "$resourceGroupName" \
    --query "properties.configuration.ingress.fqdn" \
    --output tsv)
hubUrl="https://$hub_fqdn"
hubAgentUrl="$hubUrl/hub-agent"

config_file_to_use="${custom_config:-variables.sh}"
config_path="$SCRIPT_DIR/../config/$config_file_to_use"
update_config_variable "$config_path" "hubUrl" "$hubUrl"
update_config_variable "$config_path" "hubAgentUrl" "$hubAgentUrl"

# Re-source to get the updated hubAgentUrl
source "$SCRIPT_DIR/../config/variables.sh"
if [[ -n "$custom_config" ]]; then
    source "$SCRIPT_DIR/../config/$custom_config"
fi

# Grant key vault access and get identity for delphi
delphi_identity_output=$("$SCRIPT_DIR/grant-key-vault-access.sh" \
    --container-app-name "$delphiAppName" \
    --custom-config "$custom_config" \
    --secret-permissions "get list")
parse_identity_output "$delphi_identity_output"
delphi_identity_resource_id="$IDENTITY_RESOURCE_ID"
delphi_client_id="$CLIENT_ID"

if ! test_container_app_exists "$resourceGroupName" "$delphiAppName"; then
    "$SCRIPT_DIR/create-container-apps-agent.sh" \
        --image-name "delphi:$delphiLatestImage" \
        --container-app-name "$delphiAppName" \
        --container-name "delphi" \
        --custom-config "$custom_config" \
        --identity-resource-id "$delphi_identity_resource_id" \
        --identity-client-id "$delphi_client_id"
    "$SCRIPT_DIR/mount-storage.sh" \
        --container-app-name "$delphiAppName" \
        --custom-config "$custom_config"
else
    echo "Skipping data agent creation as it already exists"
fi

# Grant key vault access and get identity for pythoness (no secret permissions)
pythoness_identity_output=$("$SCRIPT_DIR/grant-key-vault-access.sh" \
    --container-app-name "$pythonessAppName" \
    --custom-config "$custom_config" \
    --secret-permissions "")
parse_identity_output "$pythoness_identity_output"
pythoness_identity_resource_id="$IDENTITY_RESOURCE_ID"
pythoness_client_id="$CLIENT_ID"

if ! test_container_app_exists "$resourceGroupName" "$pythonessAppName"; then
    "$SCRIPT_DIR/create-container-apps-agent.sh" \
        --image-name "pythoness:$pythonessLatestImage" \
        --container-app-name "$pythonessAppName" \
        --container-name "pythoness" \
        --custom-config "$custom_config" \
        --identity-resource-id "$pythoness_identity_resource_id" \
        --identity-client-id "$pythoness_client_id"
    "$SCRIPT_DIR/mount-storage.sh" \
        --container-app-name "$pythonessAppName" \
        --custom-config "$custom_config"
else
    echo "Skipping training agent creation as it already exists"
fi
