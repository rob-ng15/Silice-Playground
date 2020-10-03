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

The GPU is controlled by writing to the following addresses:

Hexadecimal Address | GPU Usage
:----: | :----:
ff00 | GPU X coordinate from stack
ff01 | GPU Y coordinate from stack
ff02 | GPU colour from stack
ff03 | GPU parameter 0 from stack
ff03 | GPU parameter 1 from stack
ff03 | GPU parameter 2 from stack
ff03 | GPU parameter 3 from stack
ff07 | Start GPU Operation from stack (WRITE)<br>Read GPU Active Status to stack

GPU Operation | GPU Action
:-----: | :-----:
0 | Idle
1 | Set pixel x,y to colour
2 | Fill rectangle x,y to param0,param1 in colour
3 | Bresenham's line drawing algorithm from x,y to param0,param1 in colour<br>Work in Progress
4 | Bresenham's circle drawing algorithm centred at x,y of radius r in colour<br>Work in Progress

The TPU is controlled by writing to the following addresses:

Hexadecimal Address | TPU Action
:----: | :----:
ff10 | TPU x coordinate from stack
ff11 | TPU y coordinate from stack
ff12 | Write character from stack to x,y
ff13 | Write background colour from stack to x,y
ff14 | Write foreground colour from stack to x,y

The terminal is controlled by writing to the following addresses:

Hexadecimal Address | Terminal Action
:----: | :----:
ff20 | Terminal write character from stack ( part of emit )<br>Red Terminal Active Status to stack
ff21 | ```1 ff21 !``` show the terminal<br>```0 ff21 !``` hide the terminal

Helpful GPU and TPU words:

```
: gpu_setpixel ff01 ! ff00 ! ff02 ! 1 ff07 ! 
  begin ff07 @ 0= until ;
: gpu_rectangle ff04 ! ff03 ! ff01 ! ff00 ! ff02 ! 2 ff07 !
  begin ff07 @ 0= until ;
: gpu_line ff04 ! ff03 ! ff01 ! ff00 ! ff02 ! 3 ff07 !
  begin ff07 @ 0= until ;
: gpu_cs 0 0 0 2f7 1df gpu_rectangle
  begin ff07 @ 0= until ;

: tpu_setchar ff11 ! ff10 ! ff13 ! ff14 ! ff12 ! ;
: tpu_cs 50 0 do i
    1e 0 do
        dup 0 swap 0 swap 0 swap i tpu_setchar
    loop
loop ;
```
GPU/TPU Word | Usage
:-----: | :-----:
gpu_setpixel | colour x y gpu_setpixel<br>_Sets pixel x,y to colour_
gpu_rectangle | colour x1 y1 x2 y2 gpu_rectangle<br>_Draws a solid rectanlge of colour from x1,y1 to x2,y2_
gpu_line | colour x1 y1 x2 y2 gpu_line<br>_Draws a line of colour from x1,y1 to x2,y2_
gpu_cs | gpu_cs<br>_Clears the graphic display_
tpu_setchar | character x y foreground background tpu_setchar<br>_Puts character at x,y in foreground and background colours
tpu_cs | tpu_cs<br>_Clears the text display (allows graphics to show)_

Fun GPU and TPU words:

```
: drawrectangles
  gpu_cs
  100 0 do
    i 0 i 20 i 20 + gpu_rectangle
    i i 0 i 20 + 20 gpu_rectangle
    i i 100 i 20 + 120 gpu_rectangle
    i 100 i 120 i 20 + gpu_rectangle
    i i i i 20 + i 20 + gpu_rectangle
  loop ;

: drawblock
  gpu_cs
  100 0 do
    i i i 100 100  gpu_rectangle
    i 101 101 200 i - 200 i - gpu_rectangle
    i i 200 i - 101 101 gpu_rectangle
    i 200 i - i 101 101 gpu_rectangle
  loop ;
  
: de10
  tpu_cs
  44 2 ff 0 16 tpu_setchar
  45 2 ff 1 16 tpu_setchar
  31 2 ff 2 16 tpu_setchar
  30 2 ff 3 16 tpu_setchar ;

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
