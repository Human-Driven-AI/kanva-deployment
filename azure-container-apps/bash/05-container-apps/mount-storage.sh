#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
container_app_name=""
custom_config=""

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

revision_suffix=$(date +"%Y%m%d-%H%M")

write_log "Reading container app configuration"
az containerapp show \
    --name "$container_app_name" \
    --resource-group "$resourceGroupName" \
    --output yaml > app.yaml

# Use yq to modify the YAML (needs to be installed: brew install yq on macOS, or apt install yq on Linux)
# If yq is not available, we'll use a Python script as fallback

if command -v yq &> /dev/null; then
    # Using yq
    yq eval ".properties.template.volumes = [{\"mountOptions\": \"dir_mode=0777,file_mode=0777,cache=none\", \"name\": \"$fileShareName\", \"storageName\": \"$fileShareName\", \"storageType\": \"AzureFile\"}]" -i app.yaml
    yq eval ".properties.template.containers[0].volumeMounts = (.properties.template.containers[0].volumeMounts // []) + [{\"volumeName\": \"$fileShareName\", \"mountPath\": \"/app/data\"}]" -i app.yaml
    yq eval ".properties.template.revisionSuffix = \"$revision_suffix\"" -i app.yaml
    mv app.yaml updated_app.yaml
else
    # Fallback using Python
    python3 << EOF
import yaml

with open('app.yaml', 'r') as f:
    config = yaml.safe_load(f)

# Modify the configuration
config['properties']['template']['volumes'] = [{
    'mountOptions': 'dir_mode=0777,file_mode=0777,cache=none',
    'name': '$fileShareName',
    'storageName': '$fileShareName',
    'storageType': 'AzureFile'
}]

if config['properties']['template']['containers'][0].get('volumeMounts') is None:
    config['properties']['template']['containers'][0]['volumeMounts'] = []

config['properties']['template']['containers'][0]['volumeMounts'].append({
    'volumeName': '$fileShareName',
    'mountPath': '/app/data'
})

config['properties']['template']['revisionSuffix'] = '$revision_suffix'

with open('updated_app.yaml', 'w') as f:
    yaml.dump(config, f, default_flow_style=False)
EOF
fi

write_log "Creating new revision with storage mount"
# Update the container app with the new configuration
az containerapp update \
    --name "$container_app_name" \
    --resource-group "$resourceGroupName" \
    --yaml updated_app.yaml \
    --output table

# Remove the temporary files
rm -f app.yaml updated_app.yaml

write_log "Done"
