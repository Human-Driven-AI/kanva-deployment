#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
container_app_name=""
tag=""
image_name=""
custom_config=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --container-app-name)
            container_app_name="$2"
            shift 2
            ;;
        --tag)
            tag="$2"
            shift 2
            ;;
        --image-name)
            image_name="$2"
            shift 2
            ;;
        --custom-config)
            custom_config="$2"
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

full_image_name="${registryServer}/${image_name}:${tag}"

write_log "Creating new revision for container app $container_app_name with imageName $full_image_name"

az containerapp update \
    --subscription "$subscriptionId" \
    --resource-group "$resourceGroupName" \
    --name "$container_app_name" \
    --image "$full_image_name" \
    --revision-suffix "$tag"

write_log "New revision created for $container_app_name"
write_log "Done"
