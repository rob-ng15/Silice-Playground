# Silice-Playground

Examples to play with FOMU via Silice

BLINKY pulses the LED, 
USB_ACM echoes UART input and sets LED according to the input

j1eforth

A working j1eforth (https://github.com/samawati/j1eforth) interactive Forth environment using the J1 CPU (https://excamera.com/sphinx/fpga-j1.html).

Compile using ./fomu_hacker_USB_SPRAM.sh j1eforth.ice

This uses the included framework and pcf file, which are not presently uploaded to Silice.

Upload to the FOMU using dfu-util -D build.dfu

GREEN will flash to indicate clearing of SPRAM, RED will flash to indicate copying of ROM to SPRAM.


Connect to the FOMU via /dev/ttyACMx (as per your machine) using screen / putty / minicom as preferred.

Waits for SPACE to be sent to initialise the J1 CPU, ? returned if not SPACE, # returned if SPACE.

RED will flash to indicate character received (need to , GREEN will flash to indicate character being sent, BLUE will flash to indicate UART status being checked.

