# Silice-Playground
My Silice (https://github.com/sylefeb/Silice) Coding Experimental Area

Examples to play with for the DE10NANO with MiSTer SDRAM, USB HUB and I/O BOARD.

Port of the j1eforth with J1+ CPU from the FOMU.

__Works__ _sort of_!

## Building

This uses the _**DRAFT**_ branch of Silice (https://github.com/sylefeb/Silice). Open a terminal in the DE10NANO/j1eforth directory and type ```make de10nano```. Wait. Upload your design your DE10NNANO with ```quartus_pgm -m jtag -o "p;BUILD_de10nano/build.sof@2"```.

## Features

* VGA Output

The VGA output is a multiplexed bitmap and character display, with the bitmap __under__ the characters. To allow the bitmap to be displayed, set the corresponding character map to 0.

* 640 x 480 256 colour { rrrgggbb } bitmap display
* - Includes a simple GPU to draw pixels, lines (via Bresenham's Line Drawing Algorithm) and filled rectangles.
* 80 x 30 256 colour { rrrgggbb } text display, using IBM 8x16 256 character ROM
* - Includes a simple TPU to draw characters on the display (will be expanded)
* - Each character has 3 attributes, character code, foreground colour and background colour
* - Character 0 allows the underlying bitmap to display
* 80 x 8 2 colour blue/white text display, using IBM 8x8 256 character ROM as input/output terminal
* - Includes a simple terminal output protocol to display characters
* - Includes a flashing cursor
* - Can be shown/hidden to allow the larger character and bitmap to be fully displayed

Due to the address space limitations of the J1+ CPU the bitmap, character map and terminal map cannot be memory mapped so these memory areas are controlled by the multiplex_display algorithm, providing a small GPU (graphics processing unit), a small TPU (text processing unit) and a small terminal interface. 

Words to control the GPU, TPU and TERMINAL are built into the j1eforth environment

GPU/TPU/TERMINAL Word | Usage
:-----: | :-----:
gpu!pixel | ```colour x y gpu!pixel``` draws a pixel at x,y in colour
gpu!rectangle | ```colour x1 y1 x2 y2 gpu!rectangle``` draws a rectangle from x1,y1 to x2,y2 in colour
gpu!line | ```colour x1 y1 x2 y2 gpu!line``` draws a line from x1,y1 to x2,y2 in colour
gpu!cs | ```gpu!cs``` clears the bitmap
 | 
tpu!cs | ```tpu!cs``` clears the character map (allows bitmap to show through)
tpu!xy | ```x y tpu!xy``` moves the TPU cursor to x,y
tpu!foreground |```foreground tpu!foreground``` sets the foreground colour
tpu!background | ```background tpu!background``` sets the background colour
tpu!emit | emit for the TPU character map
tpu!type | type for the TPU character map
tpu!space<br>tpu!spaces | space and spaces for the TPU character map
tpu!.r<br>tpu!u.r<br>tpu!u.<br>tpu!.<br>tpu!.#<br>tpu!u.#<br>tpu!u.r#<br>tpu!.r# | Equivalents for .r u.r u. . .# u.# u.r# .r# for the TPU character map
 | 
terminal!show | show the blue terminal window
terminal!hide | hide the blue terminal window

Fun GPU and TPU words:

```
: drawrectangles
  gpu!cs
  100 0 do
    i 0 i 20 i 20 + gpu!rectangle
    i i 0 i 20 + 20 gpu!rectangle
    i i 100 i 20 + 120 gpu!rectangle
    i 100 i 120 i 20 + gpu!rectangle
    i i i i 20 + i 20 + gpu!rectangle
  loop ;

: drawblock
  gpu!cs
  100 0 do
    i i i 100 100  gpu!rectangle
    i 101 101 200 i - 200 i - gpu!rectangle
    i i 200 i - 101 101 gpu!rectangle
    i 200 i - i 101 101 gpu!rectangle
  loop ;
  
: tputest
  ff 0 do
    255 i - tpu!background
    i tpu!foreground
    i tpu!emit
  loop ;
```

## Issues

* UART input works, with copy'n'paste.
* UART output misses some characters.
* Text and Bitmap output is misaligned on the display.

## Notes

* UART rx is on PIN_AG11 which maps to Arduino_IO15. On the MiSTer I/O board this pin is accessible by the USB3-lookalike USER port.
* UART tx is on PIN_AH9 which maps to Arduino_IO14. On the MiSTer I/O board this pin is accessible by the USB3-lookalike USER port.

I use a USB3 breakout board in the USER port to easily access the above pins.

![USB3 Breakout for UART pins](DE10NANO-USERPORT.jpg)
