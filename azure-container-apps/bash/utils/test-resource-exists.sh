#!/bin/bash

test_azure_resource_exists() {
    local resource_group_name="$1"
    local resource_name="$2"
    local az_command="$3"

    local result
    result=$($az_command --name "$resource_name" --resource-group "$resource_group_name" --query 'name' --output tsv 2>/dev/null)

    if [[ $? -eq 0 && "$result" == "$resource_name" ]]; then
        return 0  # true
    else
        return 1  # false
    fi
}

test_container_app_exists() {
    local resource_group_name="$1"
    local container_app_name="$2"

    test_azure_resource_exists "$resource_group_name" "$container_app_name" "az containerapp show"
}

test_container_app_job_exists() {
    local resource_group_name="$1"
    local job_name="$2"

    test_azure_resource_exists "$resource_group_name" "$job_name" "az containerapp job show"
}

test_log_analytics_workspace_exists() {
    local resource_group_name="$1"
    local workspace_name="$2"

    test_azure_resource_exists "$resource_group_name" "$workspace_name" "az monitor log-analytics workspace show"
}

test_key_vault_exists() {
    local resource_group_name="$1"
    local key_vault_name="$2"

    test_azure_resource_exists "$resource_group_name" "$key_vault_name" "az keyvault show"
}

test_key_vault_soft_deleted() {
    local key_vault_name="$1"
    local location="$2"

    local result
    result=$(az keyvault list-deleted --query "[?name=='$key_vault_name' && properties.location=='$location'].name" --output tsv 2>/dev/null)

    if [[ $? -eq 0 && "$result" == "$key_vault_name" ]]; then
        return 0  # true
    else
        return 1  # false
    fi
}
