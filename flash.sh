#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "lib/colors.sh"
source "lib/utils.sh"

FIRMWARE_PATH="firmware/blaster_6810.hex"
CABLE="usb-blasterII"

# 1. Input Validation
if [ -z "$1" ]; then
    echo -e "${RED}Error: No SVF file provided.${NC}"
    echo "Usage: ./flash.sh path/to/project.svf"
    exit 1
fi

SVF_FILE="$1"

if [ ! -f "$SVF_FILE" ]; then
    echo -e "${RED}Error: File '$SVF_FILE' not found.${NC}"
    exit 1
fi

if [ ! -f "$FIRMWARE_PATH" ]; then
    echo -e "${RED}Error: Firmware missing in $FIRMWARE_PATH.${NC}"
    exit 1
fi

echo -e "${BLUE}Step 1: Waking up USB-Blaster II...${NC}"

# 2. Firmware Injection (Safe to run even if already loaded)
# We suppress output because it throws errors if device is already initialized
openFPGALoader -c $CABLE --probe-firmware "$FIRMWARE_PATH" > /dev/null 2>&1

# Wait for physical USB renumeration
# Can tune this, generally it takes a little while for MacOS to enumerate the device
sleep 1.5

# 3. Dynamic Device Detection
echo -e "${BLUE}Step 2: Detecting FPGA on JTAG chain...${NC}"
FPGA_INDEX=$(detect_fpga_index "$FIRMWARE_PATH")

if [ "$FPGA_INDEX" == "NOT_FOUND" ]; then
    echo -e "${RED}Error: FPGA not found.${NC}"
    exit 1
fi

echo -e "${GREEN}Found Cyclone V at Index $FPGA_INDEX${NC}"

# 4. Flashing
echo -e "${BLUE}Step 3: Flashing $SVF_FILE...${NC}"
openFPGALoader -c $CABLE --probe-firmware "$FIRMWARE_PATH" --index-chain "$FPGA_INDEX" "$SVF_FILE"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Success! Board flashed.${NC}"
else
    echo -e "${RED}Flashing failed.${NC}"
    exit 1
fi