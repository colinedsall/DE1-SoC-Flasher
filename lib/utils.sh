#!/bin/bash
source "$(dirname "$0")/lib/colors.sh"

detect_fpga_index() {
    local fw_path="$1"
    
    # Run detect WITH the firmware path so it doesn't fail
    # We redirect stderr to stdout (2>&1) so we can grep/awk the errors if needed
    local output=$(openFPGALoader -c usb-blasterII --probe-firmware "$fw_path" --detect 2>&1)
    
    # Debug: Uncomment the next line if you want to see what the tool is finding
    # echo "$output" >&2

    # Logic:
    # 1. When we see "index X:", save "X" as the current ID.
    # 2. When we see "Cyclone V", print the most recently saved ID.
    local index=$(echo "$output" | awk '/index [0-9]+:/{id=$2} /cyclone V/{print id}' | tr -d :)
    
    if [ -z "$index" ]; then
        echo "NOT_FOUND"
    else
        echo "$index"
    fi
}