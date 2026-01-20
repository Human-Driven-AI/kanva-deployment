#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
custom_config="${1:-}"

source "$SCRIPT_DIR/../utils/utils.sh"
source "$SCRIPT_DIR/../config/variables.sh"
if [[ -n "$custom_config" ]]; then
    source "$SCRIPT_DIR/../config/$custom_config"
fi

write_log "Creating database server $databaseName"
az sql server create \
    --name "$databaseName" \
    --resource-group "$resourceGroupName" \
    --location "$location" \
    --admin-user "$adminUser" \
    --admin-password "$adminPassword"

write_log "Creating database $databaseName"
az sql db create \
    --resource-group "$resourceGroupName" \
    --server "$databaseName" \
    --name "$databaseName" \
    --edition GeneralPurpose \
    --family Gen5 \
    --capacity "$capacity" \
    --zone-redundant false \
    --collation "SQL_Latin1_General_CP1_CI_AS" \
    --max-size 2GB \
    --read-replicas 0 \
    --auto-pause-delay -1 \
    --min-capacity 0.5 \
    --backup-storage-redundancy Local \
    --compute-model "$computeModel"

write_log "Creating firewall rule to allow all Azure services"
az sql server firewall-rule create \
    --resource-group "$resourceGroupName" \
    --server "$databaseName" \
    --name "AllowAllAzureServices" \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

connectionString=$(az sql db show-connection-string \
    --server "$databaseName" \
    --name "$databaseName" \
    --client ado.net \
    --output tsv)

connectionString="${connectionString/<username>/$adminUser}"
connectionString="${connectionString/<password>/$adminPassword}"
echo "$connectionString"

config_file_to_use="${custom_config:-variables.sh}"
config_path="$SCRIPT_DIR/../config/$config_file_to_use"
update_config_variable "$config_path" "connectionString" "$connectionString"
write_log "The new connection string: $connectionString has been written to $config_path" "$DARK_GREEN"
write_log "Done"
