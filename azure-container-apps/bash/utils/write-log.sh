#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
DARK_GREEN='\033[0;32m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

write_log() {
    local message="$1"
    local foreground="${2:-$WHITE}"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local log_message="[$timestamp] $message"

    # Write to console with color
    echo -e "${foreground}${log_message}${NC}"

    # Write to log file
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local log_file="$script_dir/setup-kanva.log"
    echo "$log_message" >> "$log_file"
}
