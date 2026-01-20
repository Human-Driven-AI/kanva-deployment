#!/bin/bash

# Get the directory where this script is located
UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utility scripts
source "$UTILS_DIR/test-resource-exists.sh"
source "$UTILS_DIR/write-config.sh"
source "$UTILS_DIR/write-log.sh"

get_active_azure_subscription() {
    local subscription
    subscription=$(az account show --query '{name:name, id:id, tenantId:tenantId}' --output json 2>/dev/null)

    if [[ -n "$subscription" ]]; then
        echo "$subscription"
    else
        echo "Error: No active subscription found. Please log in to Azure or set an active subscription." >&2
        return 1
    fi
}

get_hub_url() {
    local hub_app_name="$1"
    local resource_group_name="$2"

    local hub_fqdn
    hub_fqdn=$(az containerapp show \
        --name "$hub_app_name" \
        --resource-group "$resource_group_name" \
        --query "properties.configuration.ingress.fqdn" \
        --output tsv)

    echo "https://$hub_fqdn/hub-agent"
}

test_container_app_environment_exists() {
    local container_app_env_name="$1"
    local resource_group_name="$2"

    local exists
    exists=$(az containerapp env show --name "$container_app_env_name" --resource-group "$resource_group_name" --query "name" --output tsv 2>/dev/null)

    if [[ "$exists" == "$container_app_env_name" ]]; then
        return 0  # true
    else
        return 1  # false
    fi
}
