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

__*Not necessarily the most recent build, used for indicative purporses and monitoring during coding*__

```
Top-level Entity Name : top
Family : Cyclone V
Device : 5CSEBA6U23I7
Timing Models : Final
Logic utilization (in ALMs) : 5,447 / 41,910 ( 13 % )
Total registers : 2724
Total pins : 36 / 314 ( 11 % )
Total virtual pins : 0
Total block memory bits : 2,601,696 / 5,662,720 ( 46 % )
Total RAM Blocks : 339 / 553 ( 61 % )
Total DSP Blocks : 1 / 112 ( < 1 % )
Total HSSI RX PCSs : 0
Total HSSI PMA RX Deserializers : 0
Total HSSI TX PCSs : 0
Total HSSI PMA TX Serializers : 0
Total PLLs : 1 / 6 ( 17 % )
Total DLLs : 0 / 4 ( 0 % )
```

### Resource Usage (ulx3s)

__*Not necessarily the most recent build, used for indicative purporses and monitoring during coding*__

```
Info: Device utilisation:
Info:          TRELLIS_SLICE: 11411/41820    27%
Info:             TRELLIS_IO:    34/  365     9%
Info:                   DCCA:     4/   56     7%
Info:                 DP16KD:   176/  208    84%
Info:             MULT18X18D:     6/  156     3%
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

### Colour hex numbers

Colour<br>Guide<br>__HEX__ | Colour
:-----: | :-----:
40 | Transparent<br>(where used, bitmap layer, character map layer)
00 | Black
03 | Blue
0c | Green
0f | Cyan
30 | Red
33 | Magenta
3c | Yellow
3f | White

### Background Layer

The background layer displays at a pixel if __ALL__ of the layers above are transpoarent.

* Background with configurable designs
    * single { rrggbb } colour
    * alternative { rrggbb } colour for some designs
    * selectable solid, checkerboard, rainbow or rolling static 
    * fader level

#### Memory Map for the BACKGROUND Layer

Hexadecimal<br>Address | Write | Read
:----: | ---- | -----
fff0 | Set the background colour |
fff1 | Set the alternative background colour |
fff2 | Set the background design<br>0 - Solid<br>1 - Small checkerboard<br>2 - Medium checkerboard<br>3 - Large checkerboard<br>4 - Huge checkerboard<br>5 - Rainbow<br>6 - Rolling static<br>7 - Starfield (not implemented) |
ffff | Set the fade level for the background layer | VBLANK flag

#### j1eforth BACKGROUND words

DISPLAY<br>Word | Usage
----- | -----
vblank? | Example ```vblank``` wait for vblank

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

_```gpu?``` waits whilst the GPU is busy, and ```gpu!``` will start the GPU according to the action from the stack. ALl of the above BITMAP and GPU words query the GPU busy flag before commiting their action to the GPU_.

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

### Audio Output

Audio output is implemented for the ULX3S only at present. Audio output is via the 3.5mm jack.

* Stereo audio ( two audio processors, left and right )
* Specified notes in the range Deep C to Double High C
* Selectable waveforms
    * Square
    * Sawtooth
    * Triangle
    * Sine
    * Noise
* Selectable duration in milliseconds, 1000 being 1 second

#### Memory Map for the Audio Output

Hexadecimal<br>Address | Write | Read
:-----: | ----- | -----
ffe0 | Set the Left APU waveform<br>0 = square, 1 = sawtooth, 2 = triangle, 3 = sine, 4 = noise<br>_square wave_ is working |
ffe1 | Set the Left APU note<br>_HEX_ 1 = C 2, D = C 3, 19 = C 4 (middle), 25 = C 5, 31 = C 6, 3D = C 7 | 
ffe2 | Set the Left APU duration in milliseconds<br>_HEX_ 3e8 = 1 second
ffe3 | Start the Left APU to output the specified note | Milliseconds left on the present note
ffe4 | Set the Right APU waveform<br>0 = square, 1 = sawtooth, 2 = triangle, 3 = sine, 4 = noise<br>_square wave_ is working |
ffe5 | Set the Right APU note<br>_HEX_ 1 = C 2, D = C 3, 19 = C 4 (middle), 25 = C 5, 31 = C 6, 3D = C 7 | 
ffe6 | Set the Right APU duration in milliseconds<br>_HEX_ 3e8 = 1 second
ffe7 | Start the Right APU to output the specified note | Milliseconds left on the present note

#### j1eforth AUDIO words

AUDIO<br>Word | Usage
----- | -----
beep! | Example ```0 19 3e8 beep!``` outputs a middle c square wave for 1 second ( 3e8 hex = 1000 milliseconds ) to left and right channels
beep? | Example ```beep?``` waits for the APU to finish (present note) on left and right channels

_```beepL!```, ```beepR!``` , ```beepL?``` and ```beepR?``` are for the respective single channels only_

#### Note table

Octave | C | C#/Db | D | D#/Eb | E | F | F#/Gb | G | G#/Ab | A | A#/Bb | B
:-----: | :--: | :--: |  :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--:
C2 (Deep C) | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | a | b | c
C3 | d | e | f | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18
C4 (Middle C) | 19 | 1a | 1b | 1c | 1d | 1e | 1f | 20 | 21 | 22 | 23 | 24
C5 (Tenor C) | 25 | 26 | 27 | 28 | 29 | 2a | 2b | 2c | 2d | 2e | 2f | 30
C6 (Soprano C) | 31 | 32 | 33 | 34 | 35 | 36 | 37 | 38 | 39 | 3a | 3b | 3c
C7 (Double High C) | 3d

### Timers

* Two 1hz (1 second) counters
    * A systemclock, number of seconds since startup
    * A user resetable timer
    
* Two 1khz (1 millisecond) countdown timers
    * A sleep timer
    * A user resetable timer

#### Memory Map for the Timers

Hexadecimal<br>Address | Write | Read
:-----: | ----- | -----
f004 | | Read the 1hz systemClock
ffed | Reset the 1hz user timer | Read the 1hz user timer
ffee | Start the 1khz user timer | Read the 1khz user timer
ffef | Start the 1khz sleep timer | Read the 1khz sleep timer

#### j1eforth TIMER words

TIMER<br>Word | Usage
----- | -----
clock@ | Example ```clock@``` puts the systemClock, number of seconds since startup onto the stack
timer1hz! | Example ```timer1hz!``` resets the 1hz user timer
timer1hz@ | Example ```timer1hz@``` puts the 1hz user timer onto the stack
timer1khz! | Example ```3e8 timer1khz!``` starts the 1khz timer at 1 second ( 3e8 hex = 1000 milliseconds )
timer1khz? | Example ```timer1khz?``` waits for the 1khz timer to finish
sleep | Example ```3e8 sleep``` waits for 1 second ( 3e8 hex = 1000 milliseconds )

## TODO

### AUDIO

* Ensure waveforms other than square work
* Allow polyphonic sound
* Volume control

### TILEMAPS

* Put a 42 x 32 tilemap between background and bitmap along with a configurable 256 16 x 16 backtilemap
    * Tiles would be 1 bit with foreground and background colour per tile (with ALPHA bit)
    * Tilemap offset of -16 to 16 in x and y to allow scrolling
    * Tilemap scroller to move tilemap up, down, left, right
* Put a 42 x 32 tilemap between bitmap and the character map along with a configurable 256 16 x 16 fronttilemap
    * Tiles would be 1 bit with foreground and background colour per tile (with ALPHA bit)
    * Tilemap offset of -16 to 16 in x and y to allow scrolling
    * Tilemap scroller to move tilemap up, down, left, right

### GPU

* COLOUR BLITTER
    * 10 bit { Arrggbb } 16 x 16 blitter from a configurable 64 16 x 16 tilemap (16384 * 7 bit, might be too big for the blockram)
        * A will determine if pixel is placed or missed (mask)

### VECTOR DRAWER ( Work In Progress )

_Coded, still misses the odd line. Wired in to memory map and extra j1eforth words added._

* Provides 32 vector blocks, each of 16 vertices
* Each vertex is a displacement from 0, 0 in the range -31 to 0 to 31
    * Each vertex has an active flag
        * When drawing the vector block, the vector drawer will stop when it reaches and inactive vertex
* Tightly coupled to the GPU. The vectors are directly sent to the GPU, when the GPU is ready, when not active
        
When drawing a vector block, a colour, x-centre, y-centre and vector block number is provided. This should be quicker than specifiying each line to draw in Forth code, as the vector drawer will send the next vector to the GPU as soon as the previous one is rendered, and will continue in the background with no further intervention from the Forth code.

Hexadecimal<br>Address | Write | Read
:-----: | ----- | -----
ff70 | Set the vector block number for drawing
ff71 | Set the colour for drawing
ff72 | Set the x centre coordinate for drawing
ff73 | Set the y centre coordinate for drawing
ff74 | Start the vector drawing | Vector block busy
ff75 | Set the vector block number for writing
ff76 | Set the vertex in the vector block number for writing
ff77 | Set the x delta of the vertex for writing
ff78 | Set the y delta of the vertex for writing
ff79 | Set the active status of the vertex for writing
ff7a | Write the vertex to the vector block

#### j1eforth VECTOR DRAWER words

VECTOR<br>DRAWER<br>Word | Usage
----- | -----
vectorvertex! | Example ```1 -6 -18 a 0 vectorvertex!``` sets vertex 0 in vector block a to -6, -18 and active
vector? | Example ```vector?``` waits whilst the VECTOR DRAWER is busy
vector! | Example ```c 50 50 9 vector!``` draws vector block 9 centred at 50, 50 in colour c 

### DISPLAY LIST

_Partially coded. No extra j1eforth words added._

* Provides 256 display list entries
    * Each entry comprises of a 56 bits coding a complete command to send to the GPU or VECTOR BLOCK
        * active
        * command ( GPU command or VECTOR DRAWER )
        * colour { Arrggbb }
        * x
        * y
        * param0 - circle radius, rectangle x1, blitter tile number, vector block number
        * param1 - rectangle y1

Hexadecimal<br>Address | Write | Read
:-----: | ----- | -----
ff80 | Set the display list start entry number for drawing
ff81 | Set the display list finish entry number for drawing
ff82 | Start the display list drawing from start entry to finish entry | Display list busy
ff83 | Set the display entry number for writing
ff84 | Set the display list entry active status for writing
ff85 | Set the display list entry command for writing
ff86 | Set the display list entry colour for writing
ff87 | Set the display list entry x for writing
ff88 | Set the display list entry y for writing
ff89 | Set the display list entry p0 for writing
ff8a | Set the display list entry p1 for writing
ff8b | Write the display list entry to the display list<br>1 - Replace entry, 2 - Update via update flag, 3 - Update active status, 4 - Update colour, 5 - Update x, 6 - Update y, 7 - Update p0, 8 - Update p1

#### j1eforth DISPLAY LIST words

DISPLAY<br>LIST<br>Word | Usage
----- | -----
dlentry! | Example ```1 2 3f 10 10 20 20 0 dlentry!!``` sets display list entry 0 to active, command 2 (GPU rectanlge) in colour 3f from 10, 10 to 20, 20
dlstart! | Example ```8 10 dlstart!``` starts the display list to draw entries 8 to 10

### BACKGROUND

* Implement more patterns

## Notes

* UART rx for the de10nano is on PIN_AG11 which maps to Arduino_IO15. On the MiSTer I/O board this pin is accessible by the USB3-lookalike USER port.
* UART tx for the de10nano is on PIN_AH9 which maps to Arduino_IO14. On the MiSTer I/O board this pin is accessible by the USB3-lookalike USER port.

I use a USB3 breakout board in the USER port to easily access the above pins.

![USB3 Breakout for UART pins](documentation/DE10NANO-USERPORT.jpg)
