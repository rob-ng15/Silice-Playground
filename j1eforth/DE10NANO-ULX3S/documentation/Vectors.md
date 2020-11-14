# Vector Drawer

* Provides 32 vector blocks, each of 16 vertices
* Each vertex is a displacement from 0, 0 in the range -31 to 0 to 31
    * Each vertex has an active flag
        * When drawing the vector block, the vector drawer will stop when it reaches an inactive vertex
* Tightly coupled to the GPU. The vectors are directly sent to the GPU, when the GPU is ready

When drawing a vector block, a colour, x-centre, y-centre and vector block number is provided. This should be quicker than specifiying each line to draw in Forth code, as the vector drawer will send the next vector to the GPU as soon as the previous one is rendered, and will continue in the background with no further intervention from the Forth code.

## Memory Map for the Vector Drawer

Hexadecimal<br>Address | Write | Read
:-----: | ----- | -----
ff70 | Set the vector block number for drawing
ff71 | Set the colour for drawing
ff72 | Set the x centre coordinate for drawing
ff73 | Set the y centre coordinate for drawing
ff74 | Start the vector drawing | Display List/Vector block busy
ff75 | Set the vector block number for writing
ff76 | Set the vertex in the vector block number for writing
ff77 | Set the x delta of the vertex for writing
ff78 | Set the y delta of the vertex for writing
ff79 | Set the active status of the vertex for writing
ff7a | Write the vertex to the vector block

## j1eforth Vector Drawer words

VECTOR<br>DRAWER<br>Word | Usage
----- | -----
vectorvertex! | Example ```1 -6 -18 a 0 vectorvertex!``` sets vertex 0 in vector block a to -6, -18 and active
vector? | Example ```vector?``` waits whilst the VECTOR DRAWER is busy
vector! | Example ```c 50 50 9 vector!``` draws vector block 9 centred at 50, 50 in colour c
