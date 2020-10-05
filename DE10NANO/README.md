# Silice-Playground
My Silice (https://github.com/sylefeb/Silice) Coding Experimental Area

Examples to play with for the DE10NANO with MiSTer SDRAM, USB HUB and I/O BOARD.

Port of the j1eforth with J1+ CPU from the FOMU.

__Works__ _sort of_!

## Building

This uses the _**DRAFT**_ branch of Silice (https://github.com/sylefeb/Silice). Open a terminal in the DE10NANO/j1eforth directory and type ```make de10nano```. Wait. Upload your design your DE10NNANO with ```quartus_pgm -m jtag -o "p;BUILD_de10nano/build.sof@2"```.

## Features

* VGA Output

The VGA output is a multiplexed bitmap and character display, with the bitmap __under__ the characters.

* Background colour - single { rrrgggbbb } colour.
* 640 x 480 512 colour { Arrrgggbbb } bitmap display.
* - If A (ALPHA) is 1, then the background colour is displayed.
* - Includes a simple GPU to draw pixels, lines (via Bresenham's Line Drawing Algorithm) and filled rectangles.
* 80 x 30 512 colour text display, using IBM 8x16 256 character ROM
* - Includes a simple TPU to draw characters on the display (will be expanded)
* - Each character has 3 attributes
* - - Character code
* - - Foreground colour { rrrgggbbb }
* - - Background colour { Arrrgggbbb ) if A (ALPHA) is 1, then the bitmap or background colour is displayed.
* 80 x 8 2 colour blue/white text display, using IBM 8x8 256 character ROM as input/output terminal
* - Includes a simple terminal output protocol to display characters
* - Includes a flashing cursor
* - Can be shown/hidden to allow the larger character 8x16 map or the bitmap to be fully displayed

Due to the address space limitations of the J1+ CPU the bitmap, character map and terminal map cannot be memory mapped so these memory areas are controlled by the multiplex_display algorithm, providing a small GPU (graphics processing unit), a small TPU (text processing unit) and a small terminal interface. Words to control the GPU, TPU and TERMINAL are built into the j1eforth environment.

GPU/TPU/TERMINAL Word | Usage
:-----: | :-----:
background! | ```colour background!````sets the background colour<br>Ensure that bitmap and character map is transparent
pixel! | ```colour x y pixel!``` draws a pixel at x,y in colour
rectangle! | ```colour x1 y1 x2 y2 rectangle!``` draws a rectangle from x1,y1 to x2,y2 in colour
line! | ```colour x1 y1 x2 y2 line!``` draws a line from x1,y1 to x2,y2 in colour
circle! | ```colour xc yc r circle!``` draws a circle centred at xc,yc of radius r in colour
blit1! | ```colour tile x y blit1!``` blits tilemap tile to x,y in colour
cs! | ```cs!``` clears the bitmap (sets to transparent)
tpu!cs | ```tpu!cs``` clears the character map (sets to transparent so the bitmap can show through)
tpu!xy | ```x y tpu!xy``` moves the TPU cursor to x,y
tpu!foreground |```foreground tpu!foreground``` sets the foreground colour
tpu!background | ```background tpu!background``` sets the background colour
tpu!emit | emit for the TPU character map
tpu!type | type for the TPU character map
tpu!space<br>tpu!spaces | space and spaces for the TPU character map
tpu!.r<br>tpu!u.r<br>tpu!u.<br>tpu!.<br>tpu!.#<br>tpu!u.#<br>tpu!u.r#<br>tpu!.r#<br>tpu!.$ | Equivalents for .r u.r u. . .# u.# u.r# .r# .$ for the TPU character map
terminal!show | show the blue terminal window
terminal!hide | hide the blue terminal window

Colour Guide<br>HEX | Colour
:-----: | :-----:
200 | Transparent
000 | Black
007 | Blue
038 | Green
03F | Cyan
1c0 | Red
1c7 | Magenta
1f8 | Yellow
1ff | White

Fun GPU and TPU words:

```
: drawrectangles
  cs!
  1ff 0 do
    i 0 i 20 i 20 + rectangle!
    i i 0 i 20 + 20 rectangle!
    i i 1ff i 20 + 21f rectangle!
    i 1ff i 21f i 20 + rectangle!
    i i i i 20 + i 20 + rectangle!
  loop ;
drawrectangles

: drawblocks
  cs!
  1ff 0 do
    i i i 200 200 rectangle!
  loop ;
drawblocks
  
: drawcircles
  cs!
  1ff 0 do
    i 180 180 1ff i - circle!
  loop ;
drawcircles
  
2 base !
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0001101100000000
1010000010100000
1011111110100000
1111111111100000
0110111011000000
0011111110000000
0001000100000000
0010000010000000 
hex
: setblit1tile
  ff03 !
  10 0 do
    i ff04 !
    ff05 !
    6 ff07 !
  loop ;
0 setblit1tile
: invaders
  10 0 do
    i 0 i 10 * i 10 * blit1!
  loop ;
invaders

: tputest
  1ff 0 do
    200 i - tpu!background
    i tpu!foreground
    i tpu!emit
  loop ;
tputest
```
: setblit1tile
  ff03 . .
  10 0 do
    i ff04 . .
    ff05 . .
    6 ff07 . .
  loop ;

## Issues

* ```tpu!cs cs!``` must be issued to display graphics as memory is initialised for text display
* UART input works, with copy'n'paste
* - Glitches occasionally when copy'n'paste
* UART output misses some characters.
* Bitmap output is misaligned on the display (1 pixel to the right).

## TODO (Wishlist)

* TILEMAPS
* - Put a 42 x 32 tilemap between background and bitmap along with a configurable 256 16 x 16 backtilemap
* - - Tiles would be 1 bit with foreground and background colour per tile (with ALPHA bit)
* - - Tilemap offset of -16 to 16 in x and y to allow scrolling
* - - Tilemap scroller to move tilemap up, down, left, right
* - Put a 42 x 32 tilemap between bitmap and the character map along with a configurable 256 16 x 16 fronttilemap
* - - Tiles would be 1 bit with foreground and background colour per tile (with ALPHA bit)
* - - Tilemap offset of -16 to 16 in x and y to allow scrolling
* - - Tilemap scroller to move tilemap up, down, left, right

* GPU
* - Complete line drawing - STEEP lines do not work
* - DEBUG rectangle drawing
* - BLITTER
* - - 1 bit 16x16 blitter from a configurable 256 16 x 16 tilemap
* - - 10 bit { Arrrgggbbb } 16 x 16 blitter from a configurable 64 16 x 16 tilemap (16384 * 10 bit, might be too big for the blockram)

* VECTOR LIST
* - Provide a list of (up to 16) vertices for each vector
* - - centre x, centre y, colour
* - - - 16 lots of active, offsetx1, offsety1, offsetx2, offsety2
* - Can be drawn with one command to the bitmap
* - Potentially multiple vectors blocks in the list

* DISPLAY LIST
* - List of GPU commands to be executed in sequence on activation to be drawn to the bitmap

## Notes

* UART rx is on PIN_AG11 which maps to Arduino_IO15. On the MiSTer I/O board this pin is accessible by the USB3-lookalike USER port.
* UART tx is on PIN_AH9 which maps to Arduino_IO14. On the MiSTer I/O board this pin is accessible by the USB3-lookalike USER port.

I use a USB3 breakout board in the USER port to easily access the above pins.

![USB3 Breakout for UART pins](DE10NANO-USERPORT.jpg)
