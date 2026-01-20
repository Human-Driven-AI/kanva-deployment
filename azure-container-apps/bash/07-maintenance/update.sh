#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
custom_config="${1:-}"

source "$SCRIPT_DIR/../utils/utils.sh"
source "$SCRIPT_DIR/../config/variables.sh"
if [[ -n "$custom_config" ]]; then
    source "$SCRIPT_DIR/../config/$custom_config"
fi

echo "Updating container apps"
"$SCRIPT_DIR/create-revision.sh" --custom-config "$custom_config" --container-app-name "$hubAppName" --image-name "hub" --tag "$hubLatestImage"
"$SCRIPT_DIR/create-revision.sh" --custom-config "$custom_config" --container-app-name "$delphiAppName" --image-name "delphi" --tag "$delphiLatestImage"
"$SCRIPT_DIR/create-revision.sh" --custom-config "$custom_config" --container-app-name "$pythonessAppName" --image-name "pythoness" --tag "$pythonessLatestImage"
echo "Done"
