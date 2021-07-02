# PAWS4th

j1eforth ( developed from https://github.com/samawati/j1eforth ) with the J1+ CPU on the PAWS SoC.

* All features from the PAWS SoC, with the Risc-V CPU swapped for the J1+ CPU
    * J1+ CPU
        * 32k ( 16k x 16bit ) BRAM (contains j1eforth environment)
        * 32M ( 16M x 16bit ) SDRAM accessed via ```w d ram!``` and ```d ram@```
        * Hardware accelerated multiplication and division ( used by j1eforth base words )
        * Hardware accelerated double word arithmetic and comparisons ( accessed via additional j1eforth words listed below )
    * DISPLAY
        * Background
        * Lower and Upper Tile Map
            * 42 x 32 ( 40 x 30 visible ) with single pixel scrolling
            * 32 user definable 16x16 tiles
        * Lower and Upper Sprites
            * 16 Sprites
                * 8 user definable 16x16 tiles per sprite
                * Displayable at 16x16 or 32x32 pixels with x and/or y axis reflection
        * Bitmap with GPU
            * 2 x 320x240 pixel bitmaps
            * GPU with hardware accelerated drawings of pixels, lines, rectangles, circles, triangles, tile blitter, character blitter, colour tile blitter and vector drawer
        * Character Map
            *  80 x 30 Text Display
        *  Terminal Window
            *  80 x 8 Text Display
                *  UART and PS/2 Keyboard Input
    *  PERIPHERALS
        *  115200 baud UART ( via US1 )
        *  LEDS
        *  BUTTONS
        *  TIMERS
        *  STEREO AUDIO
        *  SDCARD via SPI

## Additional j1eforth Words above base from https://github.com/samawati/j1eforth

<br>

Word | Usage ( w single word, d double word )
:----- | :-----
led@ | ```led@``` returns the led status to the stack
led! | ```w led!``` sets the led status to w
buttons@ | ```buttons@``` returns the buttons status to the stack
 | |
clock@ | ```clock@``` returns the system clock (seconds from start) to the stack
timer1hz! | ```timer1hz!``` resets the user clock to 0
timer1hz@ | ```timer1hz@``` returns the user clock (seconds from reset) to the stack
timer1khz! | ```w timer1khz!``` resets the 1khz countdown timer to w
timer1khz@ | ```timer1khz@``` returns the 1khz countdown timer to the stack
timer1khz? | ```timer1khz?``` waits for the 1khz countdown timer to reach 0
sleep | ```w sleep``` sleep for w milliseconds
rng | ```w rng``` returns a pseudo random number (0 to w-1) to the stack
 | |
vblank? | ```vblank?``` waits for the display vertical blank
frambuffer! | ```w1 w2 framebuffer``` sets the display framebuffer to w1 and the drawing framebuffer to w2
terminal! | ```w terminal!``` w == 0 hide the terminal window, w == 1 display the terminal window
background! | ```w1 w2 w3 background!``` sets the background generator to colour w1, alt colour w2 and mode w3
 | |
colour! | ```w1 w2 w3 colour!``` sets the GPU colour to w1, alt colour to w2 and the dither mode to w3
pixel | ```w1 w2 pixel``` sets the pixel at (w1,w2)
line | ```w1 w2 w3 w4 line``` draws a line from (w1,w2) to (w3,w4)
rectangle | ```w1 w2 w3 w4 rectangle``` draws a filled rectangle with vertices at (w1,w2) and (w3,w4)
circle | ```w1 w2 w3 w4 circle``` draws a circle with centre at (w1,w2), radius of w3 and sector mask w4
fcircle | ```w1 w2 w3 w4 fcircle``` draws a filled circle with centre at (w1,w2), radius of w3 and sector mask w4
triangle | ```w1 w2 w3 w4 w5 w6 rectangle``` draws a filled triangle with vertices at (w1,w2), (w3,w4) and (w5,w6)
blit | ```w1 w2 w3 w4 blit``` blits the 16x16 tile w3 at scale w4 to (w1,w2)
charblit | ```w1 w2 w3 w4 charblit``` blits the 8x8 character w3 at scale w4 to (w1,w2)
colblit | ```w1 w2 w3 w4 colblit``` blits the 16x16 colour tile w3 at scale w4 to (w1,w2)
cs | ```cs``` clears the framebuffer
 | |
tcolour! | ```w1 w2 tcolour!``` sets the tpu character map foreground colour to w1 and the background colour to w2
tpuxy! | ```w1 w2 tpuxy!``` sets the tpu character map coordinates to (w1,w2)
tpuemit | ```w tpu!``` displays character w on the tpu character map
tpuspace |
tpuspaces |
tputype |
tpu.$ |
tpu.r |
tpuu.r |
tpuu. |
tpu. |
tpu.# |
tpuu.# |
tpuu.r# |
tpu.r# |
tcs | ```tcs``` clears the tpu character map
 | |
ram! | ```w d ram!``` sets the sdram at address d to w
ram@ | ```d ram@``` returns the contents of sdram at address d to the stack
 | |
sdreadsector | ```d sdreadsector``` read sector d from the sdcard to the buffer
sd@ | ```w sd@``` read byte w from the sdcard buffer

<br>

Double Word | Usage
:----- | :-----
d! | ```d w d!``` stores d at address w
d@ | ```w d@``` returns the double word from address w to the stack ( d to stack )
2constant |
2variable | ```2variable name``` creates a double width variable name
s>d | ```w s>d``` expands single width word w to double width word ( d to stack )
d0= | ```d d0=``` returns result of d = 0 ( w to stack )
d= | ```d1 d2 d=``` returns result of d1 = d2 ( w to stack )
d+ | ```d1 d2 d+``` returns result of d1 + d2 ( d to stack )
d- | ```d1 d2 d-``` returns result of d1 - d2 ( d to stack )
d1+ | ```d d1+``` returns result of d + 1 ( d to stack )
d1- | ```d d1-``` returns result of d - 1 ( d to stack )
dxor | ```d1 d2 dxor```
dand | ```d1 d2 dand```
dor | ```d1 d2 dor```
dinvert | ```d dinvert```
d2* | ```d d2*```
d2/ | ```d dd/```
dabs | ```d dabs```
dmax | ```d1 d2 dmax```
dmin | ```d1 d2 dmin```
