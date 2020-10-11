# j1eforth

## DE10NANO and ULX3S Enhancements

* Display
* - VGA for the DE10NANO
* - HDMI for the ULX3S
* PS/2 Keyboard
* - ULX3S has keyboard input (not yet implemented)
* - PS/2 takes priority over the UART
* J1+ CPU
* - 50MHz operation
* - 5 clock cycles per operation agains 13 clock cycles per operation on the FOMU

For communication with j1eforth there is a UART which provides input and output, output is duplicated on the terminal display.

__DE10NANO__ Open a terminal in the DE10NANO directory and type ```make de10nano```. Wait. Upload your design your DE10NNANO with ```quartus_pgm -m jtag -o "p;BUILD_de10nano/build.sof@2"```. Or download from this repository.

__ULX3S__ Open a terminal in the ULX3S directory and type ```make ulx3s```. Wait. Upload your design your ULX3S with ```fujproj BUILD_ulx3s/build.bit```. Or download from this repository.

### Resource Usage (de10nano)

```
Fitter Status : Successful - Sat Oct 10 13:08:36 2020
Quartus Prime Version : 20.1.0 Build 711 06/05/2020 SJ Lite Edition
Revision Name : build
Top-level Entity Name : top
Family : Cyclone V
Device : 5CSEBA6U23I7
Timing Models : Final
Logic utilization (in ALMs) : 4,333 / 41,910 ( 10 % )
Total registers : 1898
Total pins : 31 / 314 ( 10 % )
Total virtual pins : 0
Total block memory bits : 2,595,040 / 5,662,720 ( 46 % )
Total RAM Blocks : 338 / 553 ( 61 % )
Total DSP Blocks : 0 / 112 ( 0 % )
Total HSSI RX PCSs : 0
Total HSSI PMA RX Deserializers : 0
Total HSSI TX PCSs : 0
Total HSSI PMA TX Serializers : 0
Total PLLs : 1 / 6 ( 17 % )
Total DLLs : 0 / 4 ( 0 % )
```

### Resource Usage (ulx3s)
```
Need recent compilation statistics.
```

## VGA/HDMI Multiplexed Display

* VGA/HDMI Output

The VGA/HDMI output has the following layers in order:

* Background with configurable, but not yet fully implemented, designs
* - single { rrggbb } colour
* - alternative { rrggbb } colour, used in some designs
* - selectable solid or checkerboard display
* - fader level
* Lower Sprite Layer - between the background and the bitmap
* - 8 x 16 x 16 1 bit sprites each in one of { rrggbb } colours
* - Each sprite can show one of 3 user settable tiles. These tiles are specific to each sprite
* - Each sprite can be visible/invisible
* - Each sprite can be individually positioned
* - Fader level for the sprite layer
* 640 x 480 64 colour { Arrggbb } bitmap display
* - If A (ALPHA) is 1, then the lower layers are displayed
* - Includes a simple GPU to:
* - - Draw pixels
* - - Lines (via Bresenham's Line Drawing Algorithm)
* - - Circles (via Bresenham's Circle Drawing Algorithm) 
* - - Filled rectangles
* - - Blitter for 16 x 16 1 bit user settable tiles
* - Fader level for the bitmap layer
* Upper Sprite Layer - between the bitmap and the character display
* - Specifics as per the Lower Sprite Layer above
* 80 x 30 64 colour text display, using IBM 8x16 256 character ROM
* - Includes a simple TPU to draw characters on the display (will be expanded)
* - Each character has 3 attributes
* - - Character code
* - - Foreground colour { rrggbb }
* - - Background colour { Arrggbb ) if A (ALPHA) is 1, then the lower layers are displayed.
* 80 x 8 2 colour blue/white text display, using IBM 8x8 256 character ROM as input/output terminal
* - Includes a simple terminal output protocol to display characters
* - Includes a flashing cursor
* - Can be shown/hidden to allow the larger character 8x16 map or the bitmap to be fully displayed

Due to the address space limitations of the J1+ CPU the display layer memories cannot be memory mapped. Control of the display layers is done via memory mapped control registers. _Some_ j1eforth words are provided as helpers.

### Display Control Registers

Hexadecimal Address | Usage
:----: | :----:
ff00 | GPU set the x coordinate
ff01 | GPU set the y coordinate
ff02 | GPU set the colour
ff03 | GPU set parameter 0
ff04 | GPU set parameter 1
ff05 | GPU set parameter 2
ff06 | GPU set parameter 3
ff07 | GPU start<br>1 - Plot a pixel x,y in colour<br>2 - Fill a rectangle from x,y to param0,param1 in colour<br>3 - Draw a line from x,y to param0,param1 in colour<br>4 - Draw a circle centred at x,y of radius param0 in colour<br>5 - 1 bit blitter of a 16x16 tile to x,y using tile number param0 in colour<br>6 - Set line param1 of tile param0 to param2 in the 1 bit blitter tile map
ff10 | TPU set the x coordinate
ff11 | TPU set the y coordinate
ff12 | TPU set the character code
ff13 | TPU set the background colour
ff14 | TPU set the foreground colour
ff15 | TPU start<br>1 - Move to x,y<br>2 - Write character code in foreground colour, background colour to x,y and move to the next position<br>__Note__ No scrolling, wraps back to the top
ff20 | TERMINAL outputs a character
ff21 | TERMINAL show/hide<br>1 - Show the termnal<br>0 - Hide the terminal
ff30 | LOWER SPRITE LAYER set sprite number to update the following:
ff31 | LSL set sprite active flag
ff32 | LSL set sprite tile number 0-3
ff33 | LSL set sprite colour
ff34 | LSL set sprite x coordinate
ff35 | LSL set sprite y coordinate
ff36 | LOWER SPRITE LAYER TILE BITMAP WRITER set sprite number
ff37 | LSLTBW set tile line ( 0 - 63 )
ff38 | LSLTBW set tile bitmap
ff3f | LSL set the fade level
ff40 | UPPER SPRITE LAYER set sprite number to update the following:
ff41 | USL set sprite active flag
ff42 | USL set sprite tile number 0-3
ff43 | USL set sprite colour
ff44 | USL set sprite x coordinate
ff45 | USL set sprite y coordinate
ff46 | UPPER SPRITE LAYER TILE BITMAP WRITER set sprite number
ff47 | USLTBW set tile line ( 0 - 63 )
ff48 | USLTBW set tile bitmap
ff4f | USL set the fade level
fff0 | BACKGROUND set the background colour
fff1 | BACKGROUND set the alternative background colour
fff2 | BACKGROUND set the background mode<br>0 - Solid, 1 - Small checkerboard
ffff | BACKGROUND set the fade level

### Display added j1eforth words

Helper words for controlling the display are built into the j1eforth environment.

GPU/TPU/TERMINAL Word | Usage
:-----: | :-----:
background! | ```colour background!````sets the background colour<br>Ensure that bitmap and character map is transparent
pixel! | ```colour x y pixel!``` draws a pixel at x,y in colour
rectangle! | ```colour x1 y1 x2 y2 rectangle!``` draws a rectangle from x1,y1 to x2,y2 in colour
line! | ```colour x1 y1 x2 y2 line!``` draws a line from x1,y1 to x2,y2 in colour
circle! | ```colour xc yc r circle!``` draws a circle centred at xc,yc of radius r in colour
blit1! | ```colour tile x y blit1!``` blits tilemap tile to x,y in colour
blit1tile! | ```16bitmaplines tilenumber bit1tile!``` sets a blit1 tilemap tile to the 16 bitmap lines (see example below)
lsltile! | ```64bitmaplines spritenumber lsltile!``` sets a lower sprite layer tilemap for a sprite to the 64 bitmap lines
usltile! | ```64bitmaplines spritenumber usltile!``` sets an upper sprite layer tilemap for a sprite to the 64 bitmap lines
cs! | ```cs!``` clears the bitmap (sets to transparent)
tpucs! | ```tpucs!``` clears the character map (sets to transparent so the bitmap can show through)
tpuxy! | ```x y tpuxy!``` moves the TPU cursor to x,y
tpuforeground! |```foreground tpuforeground!``` sets the foreground colour
tpubackground! | ```background tpubackground!``` sets the background colour
tpuemit | emit for the TPU character map
tputype | type for the TPU character map
tpuspace<br>tpuspaces | space and spaces for the TPU character map
tpu.r<br>tpu!u.r<br>tpuu.<br>tpu.<br>tpu.#<br>tpuu.#<br>tpuu.r#<br>tpu.r#<br>tpu.$ | Equivalents for .r u.r u. . .# u.# u.r# .r# .$ for the TPU character map
terminalshow! | show the blue terminal window
terminalhide! | hide the blue terminal window

### Colour hex numbers

Colour Guide<br>HEX | Colour
:-----: | :-----:
40 | Transparent
00 | Black
03 | Blue
0c | Green
0f | Cyan
30 | Red
33 | Magenta
3c | Yellow
3f | White

### GPU and TPU demonstration

```
: drawrectangles
  3f 0 do
    i 0 i 4 * 20 i 4 * 20 + rectangle!
    i i 10 * 0 i 10 * 20 + 20 rectangle!
    i i 10 * 1ff i 10 * 20 + 21f rectangle!
    i 1ff i 10 * 21f i 10 * 20 + rectangle!
    i i 10 * i 10 * i 10 * 20 + i 10 * 20 + rectangle!
  loop ;
cs! drawrectangles

```
```
: drawblocks
  3f 0 do
    i i i 200 200 rectangle!
  loop ;
cs! drawblocks

```
```
: drawcircles
  3f 0 do
    i 100 100 3f i - 2* circle!
  loop ;
cs! drawcircles

```
```
701c 1830 820 820
ff8 3938 3938 fffe
dff6 dff6 9c72 d836
c60 c60 ee0 0
0 blit1tile!
: invaders
  10 0 do
    i 10 0 do
      dup 3f i - swap 0 swap 18 * i 18 * blit1!
    loop  drop
  loop ;
cs! invaders

```
```
: tputest
  3f 0 do
    40 i - tpubackground!
    i tpuforeground!
    i tpuemit
  loop ;
tpucs! tputest

```
```
: ledtest
    base @ 2 base !
    tpucs!
    40 0 do
        i tpuforeground! 3f i - tpubackground!
        8 1 tpuxy! timer@ dup 5 tpuu.r# tpuspace $" seconds " tpu.$
        led! led@ 
        8 tpuu.r tpuspace $" LEDs" tpu.$ 
        8000 0 do loop 
    loop
   cr 0 led! base ! ;
ledtest

```
```
: setsprites
  7 0 do
    5555 a0a0 5555 a0a0 5555 a0a0 5555 a0a0
    5555 a0a0 5555 a0a0 5555 a0a0 5555 a0a0
    a0a0 5555 a0a0 5555 a0a0 5555 a0a0 5555
    a0a0 5555 a0a0 5555 a0a0 5555 a0a0 5555
    701c 1830 820 820 ff8 3938 3938 fffe
    dff6 dff6 9c72 d836 c60 c60 ee0 0
    ffff ffff ffff ffff ffff ffff ffff ffff
    ffff ffff ffff ffff ffff ffff ffff ffff 
    i lsltile!
    5555 a0a0 5555 a0a0 5555 a0a0 5555 a0a0
    5555 a0a0 5555 a0a0 5555 a0a0 5555 a0a0
    a0a0 5555 a0a0 5555 a0a0 5555 a0a0 5555
    a0a0 5555 a0a0 5555 a0a0 5555 a0a0 5555
    701c 1830 820 820 ff8 3938 3938 fffe
    dff6 dff6 9c72 d836 c60 c60 ee0 0
    ffff ffff ffff ffff ffff ffff ffff ffff
    ffff ffff ffff ffff ffff ffff ffff ffff 
    i usltile!
  loop ;
setsprites

: screentest
  cs! tpucs!
  1 background! 4 fff1 ! 1 fff2 !

  15 70 0 a0 110 rectangle!
  2a 0 70 110 a0 rectangle!
  3f 90 90 40 circle!

  0 ff30 ! 3 ff33 ! 1 ff31 ! 0 ff32 !
  1 ff30 ! c ff33 ! 1 ff31 ! 1 ff32 !
  2 ff30 ! 30 ff33 ! 1 ff31 ! 2 ff32 !
  3 ff30 ! 3f ff33 ! 1 ff31 ! 3 ff32 !
  0 ff40 ! 0 ff43 ! 1 ff41 ! 0 ff42 !
  1 ff40 ! f ff43 ! 1 ff41 ! 1 ff42 !
  2 ff40 ! 33 ff43 ! 1 ff41 ! 2 ff42 !
  3 ff40 ! 3c ff43 ! 1 ff41 ! 3 ff42 !

  3f tpubackground! 3 tpuforeground!

  100 0 do 
    10 2 tpuxy! $" Counting " tpu.$ timer@ dup led! tpu.#    
    0 ff30 ! i ff34 ! i ff35 !
    1 ff30 ! i ff34 ! 100 i - ff35 !
    2 ff30 ! 100 i - ff34 ! i ff35 !
    3 ff30 ! 100 i - ff34 ! 100 i - ff35 !
    0 ff40 ! i ff44 ! 80 ff45 !
    1 ff40 ! 80 ff44 ! i ff45 !
    2 ff40 ! 100 i - ff44 ! 80 ff45 !
    3 ff40 ! 80 ff44 ! 100 i - ff45 !
    
    2000 0 do loop
  loop ;
screentest

```

## Issues

* Bitmap output is misaligned on the display (1 pixel to the right) (de10nano)

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
* - BLITTER
* - - 10 bit { Arrggbb } 16 x 16 blitter from a configurable 64 16 x 16 tilemap (16384 * 7 bit, might be too big for the blockram)

* VECTOR LIST
* - Provide a list of (up to 16) vertices for each vector
* - - centre x, centre y, colour
* - - - 16 lots of active, offsetx1, offsety1, offsetx2, offsety2
* - Can be drawn with one command to the bitmap
* - Potentially multiple vectors blocks in the list

* DISPLAY LIST
* - List of GPU commands to be executed in sequence on activation to be drawn to the bitmap

* BACKGROUND
* - Implement more patterns

## Notes

* UART rx for the de10nano is on PIN_AG11 which maps to Arduino_IO15. On the MiSTer I/O board this pin is accessible by the USB3-lookalike USER port.
* UART tx for the de10nano is on PIN_AH9 which maps to Arduino_IO14. On the MiSTer I/O board this pin is accessible by the USB3-lookalike USER port.

I use a USB3 breakout board in the USER port to easily access the above pins.

![USB3 Breakout for UART pins](documentation/DE10NANO-USERPORT.jpg)
