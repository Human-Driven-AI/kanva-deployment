#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
container_app_name=""
container_name=""
custom_config=""
identity_client_id=""
identity_resource_id=""
image_name=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --container-app-name)
            container_app_name="$2"
            shift 2
            ;;
        --container-name)
            container_name="$2"
            shift 2
            ;;
        --custom-config)
            custom_config="$2"
            shift 2
            ;;
        --identity-client-id)
            identity_client_id="$2"
            shift 2
            ;;
        --identity-resource-id)
            identity_resource_id="$2"
            shift 2
            ;;
        --image-name)
            image_name="$2"
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

write_log "Creating container app $container_app_name from container $container_name and image ${registryServer}/${image_name}"
write_log "$hubAgentUrl"

az containerapp create \
    --subscription "$subscriptionId" \
    --resource-group "$resourceGroupName" \
    --name "$container_app_name" \
    --container-name "$container_name" \
    --image "${registryServer}/${image_name}" \
    --environment "$containerAppEnvName" \
    --registry-server "$registryServer" \
    --registry-username "$registryUsername" \
    --registry-password "$registryPassword" \
    --memory 1Gi \
    --min-replicas 1 \
    --max-replicas 1 \
    --transport auto \
    --revision-suffix "00-initial-deploy" \
    --cpu 0.5 \
    --env-vars "KANVA_HUB_URL=$hubAgentUrl" "ManagedIdentityClientId=$identity_client_id" \
    --user-assigned "$identity_resource_id"

write_log "Done"
