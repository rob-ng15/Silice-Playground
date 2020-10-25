# Display List

* Provides 256 display list entries
    * Each entry comprises of a 56 bits coding a complete command to send to the GPU or VECTOR BLOCK
        * active
        * command ( GPU command or VECTOR DRAWER (15 (f hex) as the command) )
        * colour { Arrggbb }
        * x
        * y
        * param0 - circle radius, rectangle x1, blitter tile number, vector block number
        * param1 - rectangle y1

The display list operates at 25Mhz and once started can dispatch a command to the GPU or the VECTOR DRAWER within 1 clock cycle of the previous action completing, allowing the display to be generated quicker than the Forth code would be able to achieve.
        
_Note: No display is presently output on the ULX3S, but is on the DE10NANO._

## Memory Map for the Display List

Hexadecimal<br>Address | Write | Read
----- | ----- | -----
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

## j1eforth Display List words

DISPLAY<br>LIST<br>Word | Usage
----- | -----
dlentry! | Example ```1 2 3f 10 10 20 20 0 dlentry!!``` sets display list entry 0 to active, command 2 (GPU rectanlge) in colour 3f from 10, 10 to 20, 20
dlstart! | Example ```8 10 dlstart!``` starts the display list to draw entries 8 to 10
