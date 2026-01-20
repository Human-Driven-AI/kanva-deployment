#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
custom_config="${1:-}"

source "$SCRIPT_DIR/../utils/utils.sh"
source "$SCRIPT_DIR/../config/variables.sh"
if [[ -n "$custom_config" ]]; then
    source "$SCRIPT_DIR/../config/$custom_config"
fi

write_log "Creating resource group $resourceGroupName for subscription $subscriptionId in location $location"
az account set --subscription "$subscriptionId"
az group create --name "$resourceGroupName" --location "$location"
write_log "Done"
