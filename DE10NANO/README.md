# Silice-Playground
My Silice (https://github.com/sylefeb/Silice) Coding Experimental Area

Examples to play with for the DE10NANO with MiSTer SDRAM, USB HUB and I/O BOARD.

Port of the j1eforth with J1+ CPU from the FOMU.

__Works__ _sort of_!

## Features

* VGA Output

The VGA output is a multiplexed bitmap and character display, with the bitmap __under__ the characters. To allow the bitmap to be displayed, set the corresponding character map to 0.

* 640 x 480 256 colour { rrrgggbb } bitmap display
* 80 x 30 256 colour { rrrgggbb } text display, using IBM 256 character ROM

Each character has 3 attributes, character, foreground and background.

Due to the address space limitations of the J1+ CPU the bitmap and character map cannot be memory mapped so these memory areas are controlled by the multiplex_display algorithm, providing a small GPU (graphics processing unit) and a small TPU (text processing unit). 

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
ff07 | Start GPU Operation from stack

GPU Operation | Action
:-----: | :-----:
0 | Idle
1 | Set pixel x,y to colour
2 | Fill rectangle x,y to param0,param1 in colour
3 | Bresenham's line drawing algorithm from x,y to param0,param1 in colour<br>Work in Progress
4 | Bresenham's circle drawing algorithm centred at x,y of radius r in colour<br>Work in Progress

The TPU is controlled by writing to the following addresses:

Hexadecimal Address | TPU Usage
:----: | :----:
ff10 | TPU x coordinate from stack
ff11 | TPU y coordinate from stack
ff12 | Write character from stack to x,y
ff13 | Write background colour from stack to x,y
ff14 | Write foreground colour from stack to x,y

Helpful GPU and TPU words:

```
( GPU )
: gpu_setpixel ( colour x y ) ff01 ! ff00 ! ff02 ! 1 ff07 ! ;

: gpu_rectangle ( colour x y x1 y1 ) ff04 ! ff03 ! ff01 ! ff00 ! ff02 ! 2 ff07 ! ;
: gpu_line ( colour x y x1 y1 ) ff04 ! ff03 ! ff01 ! ff00 ! ff02 ! 3 ff07 ! ;

( Use GPU to draw a rectangle from 0,0 to 639,479 in colour 0 )
: gpu_cs 0 0 0 2f7 1df gpu_rectangle ;

( TPU )
: tpu_setchar ( char fore back x y ) ff11 ! ff10 ! ff13 ! ff14 ! ff12 ! ;
: tpu_cs 50 0 do i
    1e 0 do
        dup 0 swap 0 swap 0 swap i tpu_setchar
    loop
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
