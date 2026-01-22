#!/bin/bash
source "lib/colors.sh"

echo -e "${BLUE}=== DE1-SoC Flasher Setup ===${NC}"

# 1. Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Homebrew not found. Please install it first.${NC}"
    exit 1
fi

# 2. Install openFPGALoader
if ! command -v openFPGALoader &> /dev/null; then
    echo -e "${YELLOW}Installing openFPGALoader...${NC}"
    brew install openfpgaloader
else
    echo -e "${GREEN}openFPGALoader is installed.${NC}"
fi

# 3. Check Firmware
if [ -f "firmware/blaster_6810.hex" ]; then
    echo -e "${GREEN}Firmware file found.${NC}"
else
    echo -e "${YELLOW}Missing firmware/blaster_6810.hex${NC}"
    echo "   Please copy 'blaster_6810.hex' from your Quartus installation into the 'firmware/' folder."
fi

echo -e "${GREEN}Setup complete.${NC}"
chmod +x flash.sh