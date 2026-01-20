#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils/utils.sh"
source "$SCRIPT_DIR/config/variables.sh"

custom_config=""
subscription_id="$subscriptionId"

# Track which menu options have been used
declare -A menu_used

import_custom_config() {
    local config_files=()
    while IFS= read -r -d '' file; do
        config_files+=("$file")
    done < <(find "$SCRIPT_DIR/config" -name "variables-*.sh" -print0 2>/dev/null)

    echo "Available configurations:"
    echo "0. Base (default)"
    for i in "${!config_files[@]}"; do
        local config_name
        config_name=$(basename "${config_files[$i]}" | sed 's/^variables-//' | sed 's/\.sh$//' | sed 's/-/ /g')
        echo "$((i + 1)). $config_name"
    done
    echo "C. Cancel"

    while true; do
        read -rp "Enter the number of the configuration to load, '0' for Base config, or 'C' to cancel: " selection

        if [[ "$selection" == "C" || "$selection" == "c" ]]; then
            echo "Operation cancelled. No changes made to configuration."
            return
        fi

        if [[ "$selection" == "0" ]]; then
            source "$SCRIPT_DIR/config/variables.sh"
            echo "Loaded base configuration."
            custom_config=""
            subscription_id="$subscriptionId"
            return
        fi

        local index=$((selection - 1))
        if [[ $index -ge 0 && $index -lt ${#config_files[@]} ]]; then
            local selected_config
            selected_config=$(basename "${config_files[$index]}")
            source "$SCRIPT_DIR/config/variables.sh"
            source "$SCRIPT_DIR/config/$selected_config"
            echo "Loaded custom configuration: $selected_config"
            custom_config="$selected_config"
            subscription_id="$subscriptionId"
            return
        fi

        echo "Invalid selection. Please try again."
    done
}

show_current_config() {
    source "$SCRIPT_DIR/config/variables.sh"
    if [[ -n "$custom_config" ]]; then
        source "$SCRIPT_DIR/config/$custom_config"
    fi
    echo "Current configuration:"
    echo "Subscription ID: $subscriptionId"
    echo "Resource Group: $resourceGroupName"
    echo "Storage Account: $storageAccountName"
    echo "Location: $location"
    echo "Database: $databaseName"
}

show_menu() {
    local current_config
    if [[ -n "$custom_config" ]]; then
        current_config=$(echo "$custom_config" | sed 's/^variables-//' | sed 's/\.sh$//' | sed 's/-/ /g')
    else
        current_config="Base"
    fi

    local menu_width=60
    local config_display="Config: $current_config ($subscription_id)"

    clear
    printf "%${menu_width}s\n" "$config_display"
    printf '%*s\n' "$menu_width" '' | tr ' ' ' '
    echo " Kanva Setup"
    echo ""

    local check_mark
    for i in 1 2 3 4 5 6; do
        if [[ "${menu_used[$i]}" == "true" ]]; then
            check_mark="[x]"
        else
            check_mark="[ ]"
        fi
        case $i in
            1) echo " $i. Create Resource Group $check_mark" ;;
            2) echo " $i. Create Storage Account $check_mark" ;;
            3) echo " $i. Create Projects Database $check_mark" ;;
            4) echo " $i. Create Container App Environment $check_mark" ;;
            5) echo " $i. Create Container Apps $check_mark" ;;
            6) echo " $i. Create App Registration (For Authentication) $check_mark" ;;
        esac
    done

    echo " 7. Maintenance"
    echo " 8. Utils"
    echo " 9. Print Current Config"
    echo "10. Load Config"
    echo " E. Exit"
    echo ""
    printf '%*s\n' "$menu_width" '' | tr ' ' '='
}

invoke_menu_option() {
    local index=$1

    case $index in
        1)
            ensure_subscription
            "$SCRIPT_DIR/01-resource-group/create.sh" "$custom_config"
            menu_used[1]="true"
            ;;
        2)
            ensure_subscription
            "$SCRIPT_DIR/02-storage-account/create.sh" "$custom_config"
            menu_used[2]="true"
            ;;
        3)
            ensure_subscription
            "$SCRIPT_DIR/03-projects-database/create.sh" "$custom_config"
            menu_used[3]="true"
            ;;
        4)
            ensure_subscription
            "$SCRIPT_DIR/04-container-app-environment/create.sh" "$custom_config"
            menu_used[4]="true"
            ;;
        5)
            ensure_subscription
            "$SCRIPT_DIR/05-container-apps/create.sh" "$custom_config"
            menu_used[5]="true"
            ;;
        6)
            ensure_subscription
            if [[ -f "$SCRIPT_DIR/06-app-registration/create.sh" ]]; then
                "$SCRIPT_DIR/06-app-registration/create.sh" "$custom_config"
            else
                echo "App registration script not found"
            fi
            menu_used[6]="true"
            ;;
        7)
            show_maintenance_menu
            ;;
        8)
            show_utils_menu
            ;;
        9)
            show_current_config
            ;;
        10)
            import_custom_config
            ;;
        *)
            echo "Invalid selection"
            ;;
    esac
}

ensure_subscription() {
    local active_subscription
    active_subscription=$(az account show --query 'id' --output tsv 2>/dev/null || echo "")

    if [[ "$active_subscription" != "$subscription_id" ]]; then
        write_log "Switching to subscription $subscription_id"
        az account set --subscription "$subscription_id"
    fi
}

show_maintenance_menu() {
    echo "Maintenance submenu:"
    echo "1. Start Apps"
    echo "2. Stop Apps"
    echo "3. Update Apps To Latest Revision"
    echo "4. Back to Main Menu"

    az account set --subscription "$subscriptionId"
    read -rp "Enter your choice: " sub_selection

    case $sub_selection in
        1) "$SCRIPT_DIR/07-maintenance/start.sh" "$custom_config" ;;
        2) "$SCRIPT_DIR/07-maintenance/stop.sh" "$custom_config" ;;
        3) "$SCRIPT_DIR/07-maintenance/update.sh" "$custom_config" ;;
        4) return ;;
        *) echo "Invalid selection" ;;
    esac
    menu_used[7]="true"
}

show_utils_menu() {
    echo "Utils submenu:"
    echo "1. Fetch Last Container Tags"
    echo "2. Back to Main Menu"

    read -rp "Enter your choice: " sub_selection

    case $sub_selection in
        1) "$SCRIPT_DIR/utils/fetch-last-container-tags.sh" ;;
        2) return ;;
        *) echo "Invalid selection" ;;
    esac
    menu_used[8]="true"
}

# Main loop
continue_loop=true
while $continue_loop; do
    show_menu
    read -rp "Enter your choice: " selection

    if [[ "$selection" == "e" || "$selection" == "E" ]]; then
        continue_loop=false
    else
        invoke_menu_option "$selection"

        if $continue_loop; then
            echo "Press Enter to continue..."
            read -r
        fi
    fi
done
