#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
custom_config="${1:-}"

source "$SCRIPT_DIR/../utils/utils.sh"
source "$SCRIPT_DIR/../config/variables.sh"
if [[ -n "$custom_config" ]]; then
    source "$SCRIPT_DIR/../config/$custom_config"
fi

echo "Stopping container apps"
revision="${delphiAppName}--${delphiLatestImage}"
az containerapp revision deactivate --revision "$revision" --resource-group "$resourceGroupName"
revision="${pythonessAppName}--${pythonessLatestImage}"
az containerapp revision deactivate --revision "$revision" --resource-group "$resourceGroupName"
revision="${hubAppName}--${hubLatestImage}"
az containerapp revision deactivate --revision "$revision" --resource-group "$resourceGroupName"
echo "Done"
