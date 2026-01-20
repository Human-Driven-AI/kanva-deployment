#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/../config/variables.sh"

echo "Fetching latest container tags for registry $registryName..."

az account set --subscription "$hdaiSubscriptionId"

get_latest_image_tag() {
    local repository="$1"

    local tags
    tags=$(az acr repository show-tags --name "$registryName" --repository "$repository" --orderby time_desc --output tsv)

    while IFS= read -r tag; do
        if [[ "$tag" != "marketplace" ]]; then
            echo "$tag"
            return
        fi
    done <<< "$tags"

    echo "Warning: No non-marketplace tags found for repository $repository" >&2
    return 1
}

config_path="$SCRIPT_DIR/../config/variables.sh"

latest_tag=$(get_latest_image_tag "efbundle")
if [[ "$latest_tag" != "$dbMigrationLatestImage" ]]; then
    update_config_variable "$config_path" "dbMigrationLatestImage" "$latest_tag"
fi

latest_tag=$(get_latest_image_tag "hub")
if [[ "$latest_tag" != "$hubLatestImage" ]]; then
    update_config_variable "$config_path" "hubLatestImage" "$latest_tag"
fi

latest_tag=$(get_latest_image_tag "delphi")
if [[ "$latest_tag" != "$delphiLatestImage" ]]; then
    update_config_variable "$config_path" "delphiLatestImage" "$latest_tag"
fi

latest_tag=$(get_latest_image_tag "pythoness")
if [[ "$latest_tag" != "$pythonessLatestImage" ]]; then
    update_config_variable "$config_path" "pythonessLatestImage" "$latest_tag"
fi

echo "Done fetching latest container tags"
