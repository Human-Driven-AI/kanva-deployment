#!/bin/bash

update_config_variable() {
    local config_file="$1"
    local variable_name="$2"
    local variable_value="$3"

    # Ensure the config file exists
    if [[ ! -f "$config_file" ]]; then
        echo "Error: Config file not found: $config_file" >&2
        return 1
    fi

    # Check if the variable already exists in the file
    if grep -q "^[[:space:]]*${variable_name}=" "$config_file"; then
        # Variable exists, update its value
        # Use different sed syntax for macOS vs Linux
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|^[[:space:]]*${variable_name}=.*|${variable_name}=\"${variable_value}\"|" "$config_file"
        else
            sed -i "s|^[[:space:]]*${variable_name}=.*|${variable_name}=\"${variable_value}\"|" "$config_file"
        fi
    else
        # Variable doesn't exist, add it at the beginning of the file
        local temp_file
        temp_file=$(mktemp)
        echo "${variable_name}=\"${variable_value}\"" > "$temp_file"
        cat "$config_file" >> "$temp_file"
        mv "$temp_file" "$config_file"
    fi
}
