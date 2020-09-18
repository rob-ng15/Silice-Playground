# Silice-Playground

Examples to play with FOMU via Silice

BLINKY pulses the LED, 
USB_ACM echoes UART input and sets LED according to the input


j1eforth

A working j1eforth (https://github.com/samawati/j1eforth) interactive Forth environment using the J1 CPU (https://excamera.com/sphinx/fpga-j1.html).

Compiled dfu file is included as j1eforth-FOMU.dfu which can be flashed with dfu-util -D j1eforth-FOMU.dfu



Compile using ./fomu_hacker_USB_SPRAM.sh j1eforth.ice

This uses the included framework and pcf file, which are not presently uploaded to Silice.

Upload to the FOMU using dfu-util -D build.dfu

Connect to the FOMU via /dev/ttyACMx (as per your machine) using screen / putty / minicom as preferred.

Useful forth words:

cold (performs a reset)

words (displays the list of known words)

decimal (switch to decimal notation)

f003 @ . (read and display the state of the user buttons bxxxx = 4:3:2:1)

7 f002 ! (write to the rgb LED to switch on the red, green and blue LEDS 7 = b111 for red:green:blue)


