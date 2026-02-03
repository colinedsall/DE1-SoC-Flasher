# DE1-SoC-Flasher
Tool to bypass x86 requirements for USB-Blaster II with the Altera DE1-SoC board on natively on Apple Silicon utilizing openFPGALoader.

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Disclaimer:**
This tool is a wrapper for [openFPGALoader](https://github.com/Trabucayre/openFPGALoader). It requires proprietary firmware (`blaster_6810.hex`) owned by Intel Corporation (formerly Altera).
- This repository **does not** contain any proprietary Intel files.
- Users must obtain the firmware from their own legally licensed copy of Quartus Prime.
- This tool is not affiliated with or endorsed by Intel or Terasic.

## Prerequisites
Before using this tool, you must gather one proprietary file from your Quartus installation and configure your project correctly.

### 1. Get the USB-Blaster II Firmware
The DE1-SoC requires a specific firmware file (blaster_6810.hex) to wake up the USB controller. Because this file is proprietary to Intel/Altera, it cannot be included in this repo. Any valid installation of Quartus will have this file.

**Where to find it:**
1. Open your Windows VM (Parallels/UTM) or a Windows PC with Quartus installed.
2. Navigate to the Quartus drivers folder. It is usually located at:
   - C:\intelFPGA_lite\<version>\quartus\bin64\blaster_6810.hex
   - OR C:\intelFPGA\<version>\quartus\linux64\blaster_6810.hex
3. Copy this file to your Mac and place it in the firmware/ folder of this repository:
   de1-soc-flasher/firmware/blaster_6810.hex

### 2. Configure Quartus to Generate SVF Files
This tool works best with Serial Vector Format (.svf) files. You must tell Quartus to generate this file automatically every time you compile.

1. Open your project in Quartus Prime.
2. Go to Assignments > Device.
3. Click the "Device and Pin Options..." button.
4. Select the "Programming Files" tab (left sidebar).
5. Check the box for "Serial Vector Format (.svf)".
6. Click OK > OK.

Next time you run "Compile Design", a .svf file will appear in your output_files/ directory.

Note that this is not a permanent setting, as you will have to reconfigure every time you open a new project.

#### Alternative: Use the Programmer Tool
1. Open Tools > Programmer
2. Go to File > Create JAM, JBC, SVF, or ISC File...
3. Select File Format: Serial Vector Format (.svf)
4. Click "OK"
5. The `.svf` file will appear in your project directory.

## Setup
1. Clone or Download this repository.
2. Make the scripts executable:
``` sh
chmod +x flash.sh setup.sh lib/*.sh
```
3. Run the setup script:
``` sh
./setup.sh
```
   (This will check for Homebrew, install openFPGALoader, and verify you placed the firmware file correctly.)

## Usage
To program your board, simply run the flash.sh script and provide the path to your SVF file.
``` sh
./flash.sh path/to/your/project.svf
```

**Example:**
``` sh
./flash.sh ~/Desktop/Project/output_files/Project.svf
```

### What the script does:
1. Injects Firmware: Loads blaster_6810.hex into the board's RAM (if not already loaded).
2. Detects Device: Scans the JTAG chain to automatically find the Cyclone V FPGA index.
3. Flashes: Programs the FPGA with your design.

## Troubleshooting

### "Success! Board flashed." but nothing happens?
This is usually a logic reset issue, not a flashing issue.
* The Cause: The DE1-SoC keys are Active Low (0 = Pressed, 1 = Released). If your Verilog says "if(reset)" and you mapped Reset to KEY[0], your design is being held in reset whenever you aren't touching the board.
* The Fix: Press and hold KEY[0]. If it starts working, invert your reset logic in Verilog (use !reset).

### "Error: FPGA not found"
1. Check Physical Connection: Ensure the USB cable is plugged into the USB BLASTER port (Type-B), not the UART port (Mini-USB).
2. Power Cycle: Turn the board off and on again.
3. Cable Check: Some USB-C hubs on Mac don't play nice with USB 2.0 devices. Try a simple USB 2.0 hub in between the Mac and the Board.

You may also investigate using Ethernet and a microSD card to program the board, but this is not supported by this tool.

### "Error: Firmware missing"
You skipped Prerequisite #1. You must find blaster_6810.hex and put it in the firmware/ folder.
