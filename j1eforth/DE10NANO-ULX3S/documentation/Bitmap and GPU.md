# Bitmap Layer with GPU

* 640 x 480 64 colour { Arrggbb } bitmap display
    * If A (ALPHA) is 1, then the lower layers are displayed
    * Includes a simple GPU to:
        * Draw pixels
        * Lines (via Bresenham's Line Drawing Algorithm)
        * Circles (via Bresenham's Circle Drawing Algorithm)
        * Filled circles (via Bresenham's Circle Drawing Algorithm)
            * "Brute force" algorithm, some pixels double drawn
        * Filled rectangles
        * Filled triangles (_work in progress_)
            * "Brute force" algorithm, not optimal
                * Quicker than software equivalent
        * Blitter for 16 x 16 1 bit user settable tiles

## Memory Map for the Bitmap Layer and GPU

Hexadecimal<br>Address | Write | Read
----- | ----- | -----
ff00 | Set the GPU x coordinate |
ff01 | Set the GPU y coordinate |
ff02 | Set the GPU colour |
ff03 | Set GPU parameter 0 |
ff04 | Set GPU parameter 1 |
ff05 | Set GPU parameter 2 |
ff06 | Set GPU parameter 3 |
ff07 | Start GPU<br>Operation codes are listed in the timings section | GPU busy
ff08 | | Colour of the pixel at x,y (set below)<br>Updates every frame whilst the selected pixel is being rendered
ff09 | Set the x coordinate for reading |
ff0a | Set the y coordinate for reading |
ff0b | Set blit1 tile writer tile number |
ff0c | Set blit1 tile map line ( 0 - 15 ) |
ff0d | Set tile map line bitmap | 

## j1eforth BITMAP and GPU words

BITMAP and GPU<br>Word | Usage
----- | -----
pixel! | Example ```30 10 10 pixel!``` plots pixel 10,10 in colour 30 (red)
rectangle! | Example ```c 10 10 20 20 rectangle!``` draws a rectangle from 10,10 to 20,20 in colour c (green)
line! | Example ```3c 0 0 100 100 line!``` draws a line from 0,0 to 100,100 in colour 3c (yellow)
circle! | Example ```33 100 100 50 circle!``` draws a circle centred at 100,100 of radius 50 in colour 33 (magenta)
fcircle! | Example ```33 100 100 50 fcircle!``` draws a filled circle centred at 100,100 of radius 50 in colour 33 (magenta)
blit1! | Example ```f 0 10 10 blit1!``` blits tilemap tile 0 to 10,10 in colour f (cyan)
blit1tile! | Example (put 16 16bit bitmap lines to the stack) ```0 bit1tile!``` sets a blit1 tilemap tile 0 to the 16 bitmap lines
cs! | Example ```cs!``` clears the bitmap (sets to transparent)

_```gpu?``` waits whilst the GPU is busy, and ```gpu!``` will start the GPU according to the action from the stack. ALl of the above BITMAP and GPU words query the GPU busy flag before commiting their action to the GPU_.

## GPU Timings

The GPU within the j1eforth implementation on the DE10NANO and the ULX3S runs at 25MHz, the same rate as the video pixel clock. The GPU runs at every pixel clock, even during vblank and hblank.

### Setup and render cycles per pixel

Operation | Setup Cycles | Per Pixel | Notes
---- | ---- | ----- | -----
PIXEL | 0 | 1 | Operation 1 - Plot a pixel x,y in colour<br>The pixel is sent directly to the BITMAP, the GPU does not activate. The BITMAP checks if the pixel is in range before rendering.
RECTANGLE | 1 | 1 | Operation 2 - Fill a rectangle from x,y to param0,param1 in colour<br>Total time is 1 + 1 cycle per pixel, so for a 10 x 10 rectangle, 101 cycles.
LINE | 2 | 3 | Operation 3 - Draw a line from x,y to param0,param1 in colour<br>Initial setup is 2 cycles. Total time is 2 + 3 x ( number of pixels - 1 ) + 1. For the line 10,10 to 15, 20 a total of 11 pixels, 33 cycles.
CIRCLE | 1 | 8 | Operation 4 - Draw a circle centred at x,y of radius param0 in colour<br>Calculates 1 pixel on 1st arc of the circle, then renders each of the 8 arcs.
BLIT1 | 1 + 1 per line | 1 | Operation 5 - 1 bit blitter of a 16x16 tile to x,y using tile number param0 in colour<br>Total time is always 1 + 17 x 16 cycles, 273 cycles.
FILLED CIRCLE | | | Operation 6 - Draw a filled circle centred at x,y of radius param0 in colour<br>Calculates 1 pixel on the 1st arc of the circle, then renders joining lines in each of the 8 arcs
FILLED TRIANGLE | | | Operation 7 - Draw a filled triangle with vertices at x,y param0,param1 param2,param3
