#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
custom_config="${1:-}"

source "$SCRIPT_DIR/../utils/utils.sh"
source "$SCRIPT_DIR/../config/variables.sh"
if [[ -n "$custom_config" ]]; then
    source "$SCRIPT_DIR/../config/$custom_config"
fi

image_name="kanvaimages.azurecr.io/efbundle:$dbMigrationLatestImage"

write_log "Creating DB migration job"

# Create the Container App Job
az containerapp job create \
    --name "$dbMigrationJobName" \
    --resource-group "$resourceGroupName" \
    --environment "$containerAppEnvName" \
    --trigger-type Manual \
    --replica-timeout 1800 \
    --replica-retry-limit 1 \
    --replica-completion-count 1 \
    --parallelism 1 \
    --image "$image_name" \
    --registry-server "$registryServer" \
    --registry-username "$registryUsername" \
    --registry-password "$registryPassword" \
    --cpu 0.5 \
    --memory 1Gi \
    --env-vars "ConnectionStringsDefault=$connectionString"

# Start the job
az containerapp job start --name "$dbMigrationJobName" --resource-group "$resourceGroupName"

# Optional: Wait for the job to complete and check its status
az containerapp job execution list \
    --name "$dbMigrationJobName" \
    --resource-group "$resourceGroupName" \
    --output table

write_log "Job created and started. Check the execution list above for status." "$DARK_GREEN"
write_log "Done"
