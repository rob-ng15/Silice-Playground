# PAWS4th

j1eforth ( developed from https://github.com/samawati/j1eforth ) with the J1+ CPU on the PAWS SoC.

* All features from the PAWS SoC, with the Risc-V CPU swapped for the J1+ CPU
    * J1+ CPU
        * 48k ( 24k x 16bit ) BRAM (contains j1eforth environment)
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

Word | Usage ( w single word, d double word, f float single word )
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
qrng | ```w qrng``` returns a pseudo random number generator (0 to w) to the stack (w must be a power of 2 - 1)
 | |
beep? | ```w beep?``` waits for the beep on channel w to finish
beep! | ```w1 w2 w3 w4 beep!``` starts a beep on channel w1 in waveform w2 of note w3 for 24 milliseconds
 | |
vblank? | ```vblank?``` waits for the display vertical blank
screen! | ```w screen!``` reorders the screen layers
frambuffer! | ```w1 w2 framebuffer``` sets the display framebuffer to w1 and the drawing framebuffer to w2
bmmove! | ```w bmmove!``` moves the bitmap == 1 left == 2 up == 3 right == 4 down == 5 reset
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
blittile! | ```w0 w1 .. w15 w16 blittile!``` set tile w16 for the blitter to w0 .. w15
pbstart! | ````w0 w1 w2 w3 pbstart!``` sets the GPU to draw a pixel block at (w0,w1) of width w2 with transparency colour w3
pbpixel! | ```w pbpixel!``` output a pixel of colour w to the pixel block and move to the next pixel
pbstop! | ```pbstop!``` stops the pixel block
cs | ```cs``` clears the framebuffer
 | |
tml! |
tmu! |
tmltile! |
tmutile! |
tmlmove! |
tmumove! |
tmlcs | ```tmlcs``` clears the lower tilemap
tmucs | ```tmlcs``` clears the lower tilemap
 | |
lsprite | ``` w1 w2 w3 w4 w5 w6 w7 lsprite``` set lower sprite w7 to tile w1 at (w2,w3) in colour w4 attribute w5 with active status w6
usprite | ``` w1 w2 w3 w4 w5 w6 w7 usprite``` set upper sprite w7 to tile w1 at (w2,w3) in colour w4 attribute w5 with active status w6
lspriteupdate | ```w1 w2 lspriteupdate``` update lower sprite w2 with update flag w1
uspriteupdate | ```w1 w2 uspriteupdate``` update upper sprite w2 with update flag w1
lspritetile! | ```w0 w1 .. w127 w128 lspritetile!``` set the tiles for lower sprite w128 to w0 .. w127
uspritetile! | ```w0 w1 .. w127 w128 uspritetile!``` set the tiles for upper sprite w128 to w0 .. w127
lsprite@ | ```w1 w2 lsprite@``` returns attribute w1 of lower sprite w2 to the stack ( w1 == 7 layer collision == 6 collision == 5 tile == 4 x == 3 y == 2 colour == 1 double == 0 active )
usprite@ | ```w1 w2 usprite@``` returns attribute w1 of upper sprite w2 to the stack ( w1 7 layer collision == 6 collision == 5 tile == 4 x == 3 y == 2 colour == 1 double == 0 active )
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
tpuf.# |
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
2! | ```d w d!``` stores the double word d at address w
2@ | ```w d@``` returns the double word from address w to the stack ( d to stack )
2constant | ```d 2constant name``` creates a double width constant called name
2variable | ```2variable name``` creates a double width variable called name
s>d | ```w s>d``` expands single width word w to double width word ( d to stack )
d0= | ```d d0=``` returns result of d = 0 ( w to stack )
d= | ```d1 d2 d=``` returns result of d1 = d2 ( w to stack )
d< | ```d1 d2 d=``` returns result of d1 < d2 ( w to stack )
d+ | ```d1 d2 d+``` returns result of d1 + d2 ( d to stack )
d- | ```d1 d2 d-``` returns result of d1 - d2 ( d to stack )
d1+ | ```d d1+``` returns result of d + 1 ( d to stack )
d1- | ```d d1-``` returns result of d - 1 ( d to stack )
dxor | ```d1 d2 dxor``` returns result of d1 ^ d2 ( d to stack )
dand | ```d1 d2 dand``` returns result of d1 & d2 ( d to stack )
dor | ```d1 d2 dor``` returns result of d1 | d2 ( d to stack )
dinvert | ```d dinvert``` inverts d ( d to stack )
d2* | ```d d2*``` returns double d ( d to stack )
d2/ | ```d d2/``` returns half d ( d to stack )
dabs | ```d dabs``` returns absolute value of d ( d to stack )
dmax | ```d1 d2 dmax``` returns the largest of d1 and d2 ( d to stack )
dmin | ```d1 d2 dmin``` returns the smallest of d1 and d2 ( d to stack )

<br>

Float Word | Usage
:----- | :-----
s>f | ```w s>f``` converts the integer w to float16 ( f to stack )
f>s | ```f f>s``` converts the float16 f to integer ( w to stack )
f+ | ```f1 f2 f+``` returns the result of f1 + f2 to the stack ( f to stack )
f- | ```f1 f2 f-``` returns the result of f1 - f2 to the stack ( f to stack )
f* | ```f1 f2 f*``` returns the result of f1 * f2 to the stack ( f to stack )
f/ | ```f1 f2 f/``` returns the result of f1 / f2 to the stack ( f to stack )
fsqrt | ```f fsqrt``` returns the result of square root of f to the stack ( f to stack )
f< | ```f1 f2 f<``` returns the result of f1 < f2 to the stack ( w to stack )
f= | ```f1 f2 f=``` returns the result of f1 = f2 to the stack ( w to stack )
f<= | ```f1 f2 f<=``` returns the result of f1 <= f2 to the stack ( w to stack )
f.# | ```f f.#``` emits the floating point number f to the terminal in decimal
