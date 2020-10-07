# Silice-Playground
My Silice (https://github.com/sylefeb/Silice) Coding Experimental Area

Examples to play with for the DE10NANO with MiSTer SDRAM, USB HUB and I/O BOARD.
Examples to play with for the ULX3S.

## j1eforth

Port of the j1eforth with J1+ CPU from the FOMU. __Works__ _sort of_! This uses the _**WIP**_ branch of Silice (https://github.com/sylefeb/Silice). 

Translation of the j1eforth interactive Forth environment to DE10NANO or ULX3S with VGA (de10nano) or HDMI (ulx3s) video output.

The original J1 CPU (https://www.excamera.com/sphinx/fpga-j1.html with a very clear explanatory paper at https://www.excamera.com/files/j1.pdf) along with the j1eforth interactive Forth environment (https://github.com/samawati/j1eforth) was written for an FPGA with access to 16384 x 16bit (256kbit) dual port same cycle block ram. The Silice environment gives provides single cycle block ram, so delays have to be introduced between setting the address and reading the result.

j1eforth with the enhanced J1+ CPU for FOMU is coded in Silice (https://github.com/sylefeb/Silice) due to my limited (i.e. NO) FPGA programming experience. Silice provides a nice introduction to FPGA programming for those coming from more tradition software coding.

I've, in my opinion, tidied up the code, to make the variables more explanatory, and to aid my coding.

For communication with j1eforth there is a UART (working de10nano, not implemented ulx3s) which provides input and output, output is duplicated on the terminal display.

__DE10NANO__ Open a terminal in the DE10NANO directory and type ```make de10nano```. Wait. Upload your design your DE10NNANO with ```quartus_pgm -m jtag -o "p;BUILD_de10nano/build.sof@2"```.

__ULX3S not yet tested__ Open a terminal in the DE10NANO directory and type ```make ulx3s```. Wait. Upload your design your ULX3S with ```?```.

### Resource Usage (de10nano)

```
Fitter Status : Successful - Wed Oct  7 15:31:11 2020
Quartus Prime Version : 20.1.0 Build 711 06/05/2020 SJ Lite Edition
Revision Name : build
Top-level Entity Name : top
Family : Cyclone V
Device : 5CSEBA6U23I7
Timing Models : Final
Logic utilization (in ALMs) : 22,549 / 41,910 ( 54 % )
Total registers : 39317
Total pins : 31 / 314 ( 10 % )
Total virtual pins : 0
Total block memory bits : 3,742,912 / 5,662,720 ( 66 % )
Total RAM Blocks : 461 / 553 ( 83 % )
Total DSP Blocks : 0 / 112 ( 0 % )
Total HSSI RX PCSs : 0
Total HSSI PMA RX Deserializers : 0
Total HSSI TX PCSs : 0
Total HSSI PMA TX Serializers : 0
Total PLLs : 1 / 6 ( 17 % )
Total DLLs : 0 / 4 ( 0 % )
```

## J1/J1+ CPU Architecture and Comparisons

The original J1 CPU had a 33 entry data stack and a 32 entry return stack. The J1+ CPU has a 257 entry data stack and a 256 entry return stack.

The original J1 CPU has this instruction encoding:

```
+---------------------------------------------------------------+
| F | E | D | C | B | A | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
+---------------------------------------------------------------+
| 1 |                    LITERAL VALUE                          |
+---------------------------------------------------------------+
| 0 | 0 | 0 |            BRANCH TARGET ADDRESS                  |
+---------------------------------------------------------------+
| 0 | 0 | 1 |            CONDITIONAL BRANCH TARGET ADDRESS      |
+---------------------------------------------------------------+
| 0 | 1 | 0 |            CALL TARGET ADDRESS                    |
+---------------------------------------------------------------+
| 0 | 1 | 1 |R2P| ALU OPERATION |T2N|T2R|N2A|   | RSTACK| DSTACK|
+---------------------------------------------------------------+
| F | E | D | C | B | A | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
+---------------------------------------------------------------+

T   : Top of data stack
N   : Next on data stack
PC  : Program Counter
 
LITERAL VALUES : push a value onto the data stack
CONDITIONAL    : BRANCHS pop and test the T
CALLS          : PC+1 onto the return stack

T2N : Move T to N
T2R : Move T to top of return stack
N2A : STORE T to memory location addressed by N
R2P : Move top of return stack to PC

RSTACK and DSTACK are signed values (twos compliment) that are
the stack delta (the amount to increment or decrement the stack
by for their respective stacks: return and data)
```

The J1+ CPU adds up to 16 new alu operations, by assigning new alu operations by using ALU bit 4 to determine if J1 or J1+ alu operations, with the ALU instruction encoding:

```
+---------------------------------------------------------------+
| 0 | 1 | 1 |R2P| ALU OPERATION |T2N|T2R|N2A|J1+| RSTACK| DSTACK|
+---------------------------------------------------------------+
| F | E | D | C | B | A | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
+---------------------------------------------------------------+
```

Binary ALU Operation Code | J1 CPU | J1+ CPU | J1 CPU Forth Word (notes) | J1+ CPU Forth Word | J1+ Implemented in j1eforth
:----: | :----: | :----: | :----: | :----: | :----:
0000 | T | T==0 | (top of stack) | 0= | X
0001 | N | T<>0 | (next on stack) | 0<> | X
0010 | T+N | N<>T | + | <> | X
0011 | T&N | T+1 | and | 1+ | X
0100 | T&#124;N | T<<1 | or | 2&#42; | X
0101 | T^N | T>>1 | xor | 2/ | (stops ROM working)
0110 | ~T | N>T | invert | > <br> (signed) | X
0111 | N==T | NU>T | = | > <br> (unsigned) | X
1000 | N<T | T<0 | < <br> (signed) | 0< | X
1001 | N>>T | T>0 | rshift | 0> | X
1010 | T-1 | ABST | 1- | abs | X
1011 |  rt | MXNT | (push top of return stack to data stack) | max | X
1100 | [T] | MNNT | @ <br> (read from memory) | min | X
1101 | N<<T | -T | lshift | negate | X
1110 | dsp | N-T | (depth of stacks) | - | (stops ROM working)
1111 | NU<T | N>=T | < <br> (unsigned) | >= <br> (signed) | X

*I am presently unable to add the 2/ or - to the j1eforth ROM, as the compiled ROM is no longer functional. Some assistance to add these instructions would be appreciated.*

### Memory Map

Hexadecimal Address | Usage
:----: | :----:
0000 - 7fff | Program code and data
f000 | UART input/output (best to leave to j1eforth to operate via IN/OUT buffers).
f001 | UART Status (bit 1 = TX buffer full, bit 0 = RX character available, best to leave to j1eforth to operate via IN/OUT buffers).
f002 | LED input/output bitfield { 8b0, led } `led led!` sets the LED, `led@` places the LED status onto the stack.
f003 | BUTTONS input bitfield `buttons@` places the buttons status onto the stack.<br>de10 nano { switch3, switch2, switch1, switch0, button1, button0 }.<br>ulx3s { button6, button5, button4, button3, button2, button1, button0 }.
f004 | TIMER 1hz (1 second) counter since boot, `timer@` places the timer onto the stack

The memory map controls for the GPU, TPU and TERMINAL are listed below.

### Forth Words to try

__j1eforth__ defaults to __hex__ for numbers. 

* `.` prints the top of the stack in the current base, `.#` does the same in decimal.
* `u.` prints the _unsigned_ top of the stack in the current base, `u.#` does the same in decimal.
* `.r` prints the second in the stack, aligned to top of stack digits, in the current base, `.r#` does the same in decimal.
* `u.r` prints the _unsigned_ second in the stack, aligned to top of stack digits, in the current base, `u.r#` does the same in decimal.

* `cold` reset
* `words` list known Forth words
* `cr` output a carriage return
* `2a emit` output a * ( character 2a (hex) 42 (decimal) ) to the terminal
* `decimal` use decimal notation
* `hex` use hexadecimal notation

The j1eforth wordlist has been extended to include some double (32 bit) integer words, including `2variable` to create a double variable, double integer arithmetic, along with some words for manipulating double integers on the stack.

* `2variable` creates a named double integer variable
* `2!` writes the double integer on the stack to a double integer variable (this was already part of j1eforth)
* `2@` reads a double integer variable to the stack (this was already part of j1eforth)
* `s>d` converts a single integer on the stack to a double integer on the stack
* `d1+` and `d1-` increment and decrement the double integer on the stack
* `d+` and `d-` do double integer addition and subtraction
* `d=`, `d<` do double integer comparisons
* `d0=` do double integer 0 comparisons
* `dand`, `dor`, `dxor` and `dinvert` do double integer binary arithmetic
* `2swap` `2over`, `2rot` and `2nip` along with the j1eforth `2dup` and `2drop` work with double integers on the stack
* `m*` and `um*` perform single integer signed and unsigned multiplication giving a double integer result (these were already part of j1eforth)
* `m/mod` and `um/mod` divide a double integer by a single integer, signed and unsigned, to give a single integer remainder and quotient (these were already part of j1eforth)

## VGA/HDMI GPU, TPU and TERMINAL

* VGA/HDMI Output

The VGA/HDMI output is a multiplexed bitmap and character display, with the following layers in order:

* Background colour - single { rrrgggbbb } colour.
* 640 x 480 (de10nano) or 320 x 240 (ulx3s with double sized pixels) 512 colour { Arrrgggbbb } bitmap display.
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

### GPU and TPU added j1eforth words

GPU/TPU/TERMINAL Word | Usage
:-----: | :-----:
background! | ```colour background!````sets the background colour<br>Ensure that bitmap and character map is transparent
pixel! | ```colour x y pixel!``` draws a pixel at x,y in colour
rectangle! | ```colour x1 y1 x2 y2 rectangle!``` draws a rectangle from x1,y1 to x2,y2 in colour
line! | ```colour x1 y1 x2 y2 line!``` draws a line from x1,y1 to x2,y2 in colour
circle! | ```colour xc yc r circle!``` draws a circle centred at xc,yc of radius r in colour
blit1! | ```colour tile x y blit1!``` blits tilemap tile to x,y in colour
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
200 | Transparent
000 | Black
007 | Blue
038 | Green
03F | Cyan
1c0 | Red
1c7 | Magenta
1f8 | Yellow
1ff | White

### GPU, TPU and TERMINAL Memory Map

Where possible, use the provided j1eforth words.

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
fff0 | BACKGROUND set the background colour
fff1 | BACKGROUND set the alternative background colour
fff2 | BACKGROUND set the background mode<br>0 - Solid
fff3 | BACKGROUND set the fade level

### GPU and TPU demonstration

```
: drawrectangles
  1ff 0 do
    i 0 i 20 i 20 + rectangle!
    i i 0 i 20 + 20 rectangle!
    i i 1ff i 20 + 21f rectangle!
    i 1ff i 21f i 20 + rectangle!
    i i i i 20 + i 20 + rectangle!
  loop ;
tpucs! cs! drawrectangles

tpucs! cs!
: drawblocks
  1ff 0 do
    i i i 200 200 rectangle!
  loop ;
tpucs! cs! drawblocks
  
tpucs! cs!
: drawcircles
  1ff 0 do
    i 180 180 1ff i - circle!
  loop ;
tpucs! cs! drawcircles
  
2 base !
0000000000000000
0000111011100000
0000110001100000
0000110001100000
1101100000110110
1001110001110010
1101111111110110
1101111111110110
1111111111111110
0011100100111000
0011100100111000
0001111111110000
0000100000100000
0000100000100000
0001100000110000
0111000000011100
hex
: blit1tile!
  ff03 !
  10 0 do
    i ff04 !
    ff05 !
    6 ff07 !
  loop ;
0 blit1tile!
: invaders
  10 0 do
    i 10 0 do
      dup 1ff i - swap 0 swap 18 * i 18 * blit1!
    loop  
  loop ;
tpucs! cs! invaders

: tputest
  1ff 0 do
    200 i - tpubackground!
    i tpuforeground!
    i tpuemit
  loop ;
tpucs! tputest

: ledtest
    base @ 2 base !
    tpucs!
    100 0 do
        i tpuforeground! 1ff i - tpubackground!
        8 1 tpuxy! timer@ dup 5 tpuu.r# tpuspace $" seconds " tpu.$
        led! led@ 
        8 tpuu.r tpuspace $" LEDs" tpu.$ 
        8000 0 do loop 
    loop
    cr 0 led! base ! ;
ledtest
```

## Issues

* ```tpucs! cs!``` must be issued to display graphics as memory is initialised for text display
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

* UART rx for the de10nano is on PIN_AG11 which maps to Arduino_IO15. On the MiSTer I/O board this pin is accessible by the USB3-lookalike USER port.
* UART tx for the de10nano is on PIN_AH9 which maps to Arduino_IO14. On the MiSTer I/O board this pin is accessible by the USB3-lookalike USER port.

I use a USB3 breakout board in the USER port to easily access the above pins.

![USB3 Breakout for UART pins](DE10NANO-USERPORT.jpg)
