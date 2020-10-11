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
* - 5 clock cycles per operation agains 13 clock cycles per operation on the FOMU, giving an effective CPU running at 10MHz

For communication with j1eforth there is a UART which provides input and output, output is duplicated on the terminal display.

__DE10NANO__ Open a terminal in the DE10NANO directory and type ```make de10nano```. Wait. Upload your design your DE10NNANO with ```quartus_pgm -m jtag -o "p;BUILD_de10nano/build.sof@2"```. Or download from this repository.

__ULX3S__ Open a terminal in the ULX3S directory and type ```make ulx3s```. Wait. Upload your design your ULX3S with ```fujproj BUILD_ulx3s/build.bit```. Or download from this repository.

### Resource Usage (de10nano)

```
Quartus Prime Version : 20.1.0 Build 711 06/05/2020 SJ Lite Edition
Revision Name : build
Top-level Entity Name : top
Family : Cyclone V
Device : 5CSEBA6U23I7
Timing Models : Final
Logic utilization (in ALMs) : 6,040 / 41,910 ( 14 % )
Total registers : 2600
Total pins : 31 / 314 ( 10 % )
Total virtual pins : 0
Total block memory bits : 2,611,424 / 5,662,720 ( 46 % )
Total RAM Blocks : 354 / 553 ( 64 % )
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
Info: Device utilisation:                                                                                                           
Info:          TRELLIS_SLICE: 12308/41820    29%                                                                                    
Info:             TRELLIS_IO:    26/  365     7%                                                                                    
Info:                   DCCA:     4/   56     7%                                                                                    
Info:                 DP16KD:   174/  208    83%                                                                                    
Info:             MULT18X18D:     5/  156     3%                                                                                    
Info:                 ALU54B:     0/   78     0%                                                                                    
Info:                EHXPLLL:     2/    4    50%                                                                                    
Info:                EXTREFB:     0/    2     0%                                                                                    
Info:                   DCUA:     0/    2     0%                                                                                    
Info:              PCSCLKDIV:     0/    2     0%                                                                                    
Info:                IOLOGIC:     0/  224     0%                                                                                    
Info:               SIOLOGIC:     8/  141     5%                                                                                    
Info:                    GSR:     0/    1     0%                                                                                    
Info:                  JTAGG:     0/    1     0%                                                                                    
Info:                   OSCG:     0/    1     0%                                                                                    
Info:                  SEDGA:     0/    1     0%                                                                                    
Info:                    DTR:     0/    1     0%                                                                                    
Info:                USRMCLK:     0/    1     0%                                                                                    
Info:                CLKDIVF:     0/    4     0%                                                                                    
Info:              ECLKSYNCB:     0/   10     0%                                                                                    
Info:                DLLDELD:     0/    8     0%                                                                                    
Info:                 DDRDLL:     0/    4     0%                                                                                    
Info:                DQSBUFM:     0/   14     0%                                                                                    
Info:        TRELLIS_ECLKBUF:     0/    8     0%                                                                                    
Info:           ECLKBRIDGECS:     0/    2     0%                                                                                    ```
```
## VGA/HDMI Multiplexed Display

The VGA DE10NANO/HDMI ULX3S output has the following layers in order:

* Background with configurable designs
* - single { rrggbb } colour
* - alternative { rrggbb } colour, used in some designs
* - selectable solid or checkerboard display
* - fader level
* Lower Sprite Layer - between the background and the bitmap
* - 16 x 16 x 16 1 bit sprites each in one of { rrggbb } colours
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
ff08 | BITMAP READ colour at x,y
ff09 | BITMAP READ x - set the x pixel for reading
ff0a | BITMAP READ y - set the y pixel for reading
ff0f | BITMAP set the fade level
ff10 | TPU set the x coordinate
ff11 | TPU set the y coordinate
ff12 | TPU set the character code
ff13 | TPU set the background colour
ff14 | TPU set the foreground colour
ff15 | TPU start<br>1 - Move to x,y<br>2 - Write character code in foreground colour, background colour to x,y and move to the next position<br>__Note__ No scrolling, wraps back to the top
ff20 | TERMINAL outputs a character
ff21 | TERMINAL show/hide<br>1 - Show the termnal<br>0 - Hide the terminal
ff30 | LOWER SPRITE LAYER set sprite number to update/read the following:
ff31 | LSL set or read sprite active flag
ff32 | LSL set or read sprite tile number 0-3
ff33 | LSL set or read sprite colour
ff34 | LSL set or read sprite x coordinate
ff35 | LSL set or read sprite y coordinate
ff36 | LOWER SPRITE LAYER TILE BITMAP WRITER set sprite number
ff37 | LSLTBW set tile line ( 0 - 63 )
ff38 | LSLTBW set tile bitmap
ff39 | LOWER SPRITE LAYER SPRITES AT x,y FLAG<br>Returns the sprites with visible pixels at x,y. BASIC collision detection.
ff3a | LSLSAT set the x coordinate
ff3b | LSLSAT set the y coordinate
ff3f | LSL set the fade level
ff40 | UPPER SPRITE LAYER set sprite number to update/read the following:
ff41 | USL set or read sprite active flag
ff42 | USL set or read sprite tile number 0-3
ff43 | USL set or read sprite colour
ff44 | USL set or read sprite x coordinate
ff45 | USL set or read sprite y coordinate
ff46 | UPPER SPRITE LAYER TILE BITMAP WRITER set sprite number
ff47 | USLTBW set tile line ( 0 - 63 )
ff48 | USLTBW set tile bitmap
ff49 | UPPER SPRITE LAYER SPRITES AT x,y FLAG<br>Returns the sprites with visible pixels at x,y. BASIC collision detection.
ff4a | USLSAT set the x coordinate
ff4b | USLSAT set the y coordinate
ff4f | USL set the fade level
fff0 | BACKGROUND set the background colour
fff1 | BACKGROUND set the alternative background colour
fff2 | BACKGROUND set the background mode<br>0 - Solid, 1 - Small checkerboard, 2 - Medium checkerboard, 3 - Large checkerboard, 4 - Huge checkerboard
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
