# Silice-Playground

Examples to play with FOMU via Silice

BLINKY pulses the LED, 
USB_ACM echoes UART input and sets LED according to the input

j1eforth

Attempts to implement the j1eforth (https://github.com/samawati/j1eforth) interactive Forth environment using the J1 CPU (https://excamera.com/sphinx/fpga-j1.html).

Compile using ./fomu_hacker_USB_SPRAM.sh j1eforth.ice
This uses the included framework and pcf file, which are not presently uploaded to Silice.

Upload to the FOMU using dfu-util -D build
Connect to the FOMU via /dev/ttyACMx (as per your machine) using screen / putty / minicom as preferred.

You'll receive back a string of characters representing the instruction being executed presently. Starts working, but fails after approximately 100 instructions where it gets stcuk in some kind of loop. Not yet managed to find out why!
