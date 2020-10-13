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

For communication with j1eforth there is a UART which provides input and output, output is duplicated on the terminal display. The ULX3S has a PS/2 keyboard input via the us2 connector and a USB OTG and PS/2 to USB converter.

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
Logic utilization (in ALMs) : 4,778 / 41,910 ( 11 % )
Total registers : 2196
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
Info:          TRELLIS_SLICE:  9905/41820    23%                                                                                    
Info:             TRELLIS_IO:    30/  365     8%                                                                                    
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
Info:           ECLKBRIDGECS:     0/    2     0%
```

## VGA/HDMI Multiplexed Display

The VGA DE10NANO/HDMI ULX3S output has the following layers in order:

* Background
* Lower Sprite Layer
* Bitmap with GPU
* Upper Sprite Layer
* Character Map with TPU
* Terminal

Due to the address space limitations of the J1+ CPU the display layer memories cannot be memory mapped. Control of the display layers is done via memory mapped control registers. _Some_ j1eforth words are provided as helpers.

### Background Layer

The background layer displays at a pixel if __ALL__ of the layers above are transpoarent.

* Background with configurable designs
    * single { rrggbb } colour
    * alternative { rrggbb } colour for some designs
    * selectable solid, checkerboard, rainbow or static 
    * fader level

#### Memory Map for the BACKGROUND Layer

Hexadecimal<br>Address | Write | Read
:----: | ---- | -----
fff0 | Set the background colour |
fff1 | Set the alternative background colour |
fff2 | Set the background design<br>0 - Solid<br>1 - Small checkerboard<br>2 - Medium checkerboard<br>3 - Large checkerboard<br>4 - Huge checkerboard<br>5 - Rainbow<br>6 - Static<br>7 - Starfield (not implemented) |
ffff | Set the fade level for the background layer | VBLANK flag

#### j1eforth BACKGROUND words

DISPLAY<br>Word | Usage
----- | -----
vblank | Example ```vblank``` await vblank

BACKGROUND<br>Word | Usage
----- | -----
background! | Example: ```3 2 4 background!``` Sets the background to a HUGE blue/dark blue checkerboard

### Lower (and Upper) Sprite Layer

* Sprite Layer
    * 8 x 16 x 16 1 bit sprites
    * 4 user settable tiles per sprite
    * fader level

The lower sprite layer displays between the background and the bitmap; the upper sprite layers displays between the bitmap and the character map.

Each Sprite has the following attributes:

Sprite Tile<br>Map | Active | Tile Number | X | Y | Colour 
----- | ----- | ----- | ----- | ----- | -----
64 lines of 16 pixels<br>4 x 16 x 16 tiles per Sprite | Display(1) or Hide(0) the Sprite | 0 - 3 Select tile from the sprite tile map | X coordinate | Y coordinate | { rrggbb } colour

#### Memory Map for the LOWER and UPPER SPRITE Layers

Hexadecimal<br>Address<br>ff30 - ff3f for lower sprites<br>ff40 - ff4f for upper sprites | Write | Read
:-----: | ----- | -----
ff30 | Set __Active Sprite Number__ referred to as _ASN_ in the following |
ff31 | Set _ASN_ active | Read _ASN_ active
ff32 | Set _ASN_ tile number | Read _ASN_ tile number
ff33 | Set _ASN_ colour | Read _ASN_ colour
ff34 | Set _ASN_ x coordinate | Read _ASN_ x coordinate
ff35 | Set _ASN_ y coordinate | Read _ASN_ coordinate
ff36 | Set __Tile Map Writer Sprite Number__ referred to as _TMWSN_ in the following<br> |
ff37 | Set _TMWSN_ tile map line ( 0 - 63 ) |
ff38 | Set _TMWSN_ tile map line bitmap |
ff39 | | Sprites at flag<br>8 bit { sprite7, sprite6 ... sprite0 } flag of which sprites are visible at the x,y coordinate set below<br>Updates every frame whilst the pixel is being rendered
ff3a | Sprites at x coordinate |
ff3b | Sprites at y coordinate |
ff3c | Update a sprite<br>See notes below |
ff3f | Set the fade level for the sprite layer

_For the Upper Sprite Layer add ff10 to the address_.

#### j1eforth SPRITE LAYER words

SPRITE LAYER<br>Word | Usage
----- | -----
lslsprite! | Example ```10 20 3f 2 1 0 lslsprite!``` set lower sprite layer sprite 0 to 10,20 in colour 3f with tile map number 2 and active
uslsprite! | Example ```10 20 3f 2 1 0 uslsprite!``` set upper sprite layer sprite 0 to 10,20 in colour 3f with tile map number 2 and active
lsltile! | Example (put 64 16bit bitmap lines to the stack) ```0 lsltile!``` set lower sprite layer sprite 0 tile map to the 64 bitmap lines
usltile! | Example (put 64 16bit bitmap lines to the stack) ```0 usltile!``` set upper sprite layer sprite 0 tile map to the 64 bitmap lines
lslupdate! | Example ```57 lslupdate!``` Update lower sprite layer sprite 0 according to (binary) { 0 000000 0 0 1 010 111 }<br>No change to colour, x wrap, y wrap, Iicrement tile number, y=y+2, x=x-1
uslupdate! | Example ```86b1 uslupdate!``` Update upper sprite layer sprite 0 according to (binary) { 1 000011 0 1 0 110 001 }<br>Change colour to 3(blue), x wrap, y kill, keep tile number, y=y-2, x=x+1

#### Notes about the SPRITE UPDATE binary code

Bit(s) | Purpose
:-----: | -----
15 | Colour action - 0 = leave as is, 1 = change to { rrggbb } as given in bits 14 - 9
14 - 9 | { rrggbb } colour
8 | Y action - 0 = wrap y-axis, 1 = set sprite to inactive if it moves off screen
7 | X action - 0 = wrap x-axis, 1 = set sprite to inactive if it moves off screen
6 | Tile number action - 0 = leave as is, 1 = increment the tile number (simple animation)
5 - 3 | Y delta - amount to move along the y-axis, 2's complement number
2 - 0 | X delta - amount to move along the x-axis, 2's complement number

### Bitmap Layer with GPU

* 640 x 480 64 colour { Arrggbb } bitmap display
    * If A (ALPHA) is 1, then the lower layers are displayed
    * Includes a simple GPU to:
        * Draw pixels
        * Lines (via Bresenham's Line Drawing Algorithm)
        * Circles (via Bresenham's Circle Drawing Algorithm) 
        * Filled rectangles
        * Blitter for 16 x 16 1 bit user settable tiles
    * Fader level for the bitmap layer

#### Memory Map for the BITMAP Layer and GPU

Hexadecimal<br>Address | Write | Read
:-----: | ----- | -----
ff00 | Set the GPU x coordinate |
ff01 | Set the GPU y coordinate |
ff02 | Set the GPU colour |
ff03 | Set GPU parameter 0 |
ff04 | Set GPU parameter 1 |
ff05 | Set GPU parameter 2 |
ff06 | Set GPU parameter 3 |
ff07 | Start GPU<br>1 - Plot a pixel x,y in colour<br>2 - Fill a rectangle from x,y to param0,param1 in colour<br>3 - Draw a line from x,y to param0,param1 in colour<br>4 - Draw a circle centred at x,y of radius param0 in colour<br>5 - 1 bit blitter of a 16x16 tile to x,y using tile number param0 in colour<br>6 - Set line param1 of tile param0 to param2 in the 1 bit blitter tile map | GPU busy
ff08 | | Colour of the pixel at x,y (set below)<br>Updates every frame whilst the selected pixel is being rendered
ff09 | Set the x coordinate for reading |
ff0a | Set the y coordinate for reading |
ff0f | Set the fade level for the bitmap layer |

#### j1eforth BITMAP and GPU words

BITMAP and GPU<br>Word | Usage
----- | -----
pixel! | Example ```30 10 10 pixel!``` plots pixel 10,10 in colour 30 (red)
rectangle! | Example ```c 10 10 20 20 rectangle!``` draws a rectangle from 10,10 to 20,20 in colour c (green)
line! | Example ```3c 0 0 100 100 line!``` draws a line from 0,0 to 100,100 in colour 3c (yellow)
circle! | Example ```33 100 100 50 circle!``` draws a circle centred at 100,100 of radius 50 in colour 33 (magenta)
blit1! | Example ```f 0 10 10 blit1!``` blits tilemap tile 0 to 10,10 in colour f (cyan)
blit1tile! | Example (put 16 16bit bitmap lines to the stack) ```0 bit1tile!``` sets a blit1 tilemap tile 0 to the 16 bitmap lines
cs! | Example ```cs!``` clears the bitmap (sets to transparent)

_```gpu?``` writes the GPU busy flag to the stack, and ```gpu!``` will start the GPU according to the action from the stack. ALl of the above BITMAP and GPU words query the GPU busy flag before commiting their action to the GPU_.

### Upper Sprite Layer

_Details in Lower Sprite Layer section_

### Character Map with TPU

* 80 x 30 64 colour character map display, using IBM 8x16 256 character ROM
    * Includes a simple TPU to draw characters on the display (will be expanded)
    * Each character map cell has 3 attributes
        * Character code
        * Foreground colour { rrggbb }
        * Background colour { Arrggbb ) if A (ALPHA) is 1, then the lower layers are displayed.

#### Memory Map for the CHARACTER MAP Layer and TPU

Hexadecima<br>Address | Write | Read
:-----: | ----- | -----
ff10 | Set the TPU x coordinate |
ff11 | Set the TPU y coordinate |
ff12 | Set the TPU character code |
ff13 | Set the TPU background colour |
ff14 | Set the TPU foreground colour |
ff15 | Start TPU<br>1 - Move to x,y<br>2 - Write character code in foreground colour, background colour to x,y and move to the next position<br>__Note__ No scrolling, wraps back to the top |

#### j1eforth CHARACTER MAP and TPU words

CHARACTER MAP and TPU<br>Word | Usage
----- | -----
tpucs! | Example ```tpucs!``` clears the character map (sets to transparent)
tpuxy! | Example ```0 0 tpuxy!``` moves the TPU cursor to 0,0 (top left)
tpuforeground! | Example ```3f tpuforeground!``` sets the TPU foreground to colour 3f (white)
tpubackground! | Example ```3 tpubackground!``` sets the TPU background to colour 3 (blue)
tpuemit | Equivalent to ```emit``` for the TPU and character map
tputype | Equivalent ```type``` for the TPU and character map
tpuspace<br>tpuspaces | Equivalent to ```space``` and ```spaces``` for the TPU and character map
tpu.r<br>tpu!u.r<br>tpuu.<br>tpu.<br>tpu.#<br>tpuu.#<br>tpuu.r#<br>tpu.r#<br>tpu.$ | Equivalent to ```.r``` ```u.r``` ```u.``` ```.``` ```.#``` ```u.#``` ```u.r#``` ```.r#``` ```.$``` for the TPU and character map

### Terminal Window

* 80 x 8 2 colour blue/white text display, using IBM 8x8 256 character ROM as input/output terminal
    * Includes a simple terminal output protocol to display characters
    * Includes a flashing cursor
    * Can be shown/hidden to allow the larger character 8x16 map or the bitmap to be fully displayed

#### Memory Map for the TERMINAL Window

Hexadecimal<br>Address | Write | Read
:-----: | ----- | -----
ff20 | TERMINAL outputs a character | TERMINAL busy
ff21 | TERMINAL show/hide<br>1 - Show the termnal<br>0 - Hide the terminal

#### j1eforth TERMINAL words

TERMINAL<br>Word | Usage
----- | -----
terminalshow! | Example ```terminalshow!``` show the blue terminal window
terminalhide! | Example ```terminalhide!``` hide the blue terminal window

### Colour hex numbers

Colour<br>Guide<br>__HEX__ | Colour
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
    * Put a 42 x 32 tilemap between background and bitmap along with a configurable 256 16 x 16 backtilemap
        * Tiles would be 1 bit with foreground and background colour per tile (with ALPHA bit)
        * Tilemap offset of -16 to 16 in x and y to allow scrolling
        * Tilemap scroller to move tilemap up, down, left, right
    * Put a 42 x 32 tilemap between bitmap and the character map along with a configurable 256 16 x 16 fronttilemap
        * Tiles would be 1 bit with foreground and background colour per tile (with ALPHA bit)
        * Tilemap offset of -16 to 16 in x and y to allow scrolling
        * Tilemap scroller to move tilemap up, down, left, right

* GPU
    * Complete line drawing - STEEP lines do not work
    * BLITTER
        * 10 bit { Arrggbb } 16 x 16 blitter from a configurable 64 16 x 16 tilemap (16384 * 7 bit, might be too big for the blockram)

* VECTOR LIST
    * Provide a list of (up to 16) vertices for each vector
        * centre x, centre y, colour
        * 16 lots of active, offsetx1, offsety1, offsetx2, offsety2
    * Can be drawn with one command to the bitmap

* DISPLAY LIST
    * List of GPU, SPRITE or VECTOR commands to be executed in sequence

* BACKGROUND
    * Implement more patterns

## Notes

* UART rx for the de10nano is on PIN_AG11 which maps to Arduino_IO15. On the MiSTer I/O board this pin is accessible by the USB3-lookalike USER port.
* UART tx for the de10nano is on PIN_AH9 which maps to Arduino_IO14. On the MiSTer I/O board this pin is accessible by the USB3-lookalike USER port.

I use a USB3 breakout board in the USER port to easily access the above pins.

![USB3 Breakout for UART pins](documentation/DE10NANO-USERPORT.jpg)
