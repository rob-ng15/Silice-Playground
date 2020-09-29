# Silice-Playground
My Silice (https://github.com/sylefeb/Silice) Coding Experimental Area

Examples to play with for the DE10NANO with MiSTer SDRAM, USB HUB and I/O BOARD.

Port of the j1eforth with J1+ CPU from the FOMU.

__Works!__ _sort of_

## Issues

* UART input does not correctly record all characters. It misses the occasional typed character, and copy'n'paste overloads it.
* UART output misses some characters.

## Notes

* UART rx is on PIN_AG11 which maps to Arduino_IO15. On the MiSTer I/O board this pin is accessible by the USB3-lookalike USER port.
* UART tx is on PIN_AH9 which maps to Arduino_IO14. On the MiSTer I/O board this pin is accessible by the USB3-lookalike USER port.

I use a USB3 breakout board in the USER port to easily access the above pins.

![USB3 Breakout for UART pins](DE10NANO-USERPORT.jpg)
