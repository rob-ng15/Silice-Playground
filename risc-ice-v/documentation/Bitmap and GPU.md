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
            * "Brute force" algorithm
                * Vertices best specified as TOP then clockwise from TOP
                    * Some limited checks to arrange vertices
                * Works from top to bottom on a bounding box
                    * Optimisation moves to the next line once no longer inside the triangle
                    * Optimisation moves from left to right or right to left depending upon which side the last point in the previous line was closest to
                * Quicker than software equivalent
        * Blitter for 32 x 16 x 16 1 bit user settable tiles
            * Can blit as 16 x 16 pixels or double size 32 x 32 pixels
    * Hardware scrolling
        * The viewport ( 0, 0 ) can be moved pixel by pixel within the bitmap
        * Pixels wrap from left/right top/bottom
    * Vector block drawer
        * 32 vector blocks, each of 16 vertices
            * Vertices range from (-31,-31) to (31,31)
            * Lines are drawn from vertex to vertex, offset from the centre coordinate provided until an inactive vertex is encountered

## PAWS LIBRARY FUNCTIONS

```void gpu_cs( void )``` Clear the bitmap to transparent
```void gpu_pixel( unsigned char colour, short x, short y )``` Set a pixel
```void gpu_rectangle( unsigned char colour, short x1, short y1, short x2, short y2 )``` Draw a filled rectangle from (x1,y1) to (x2,y2)
```void gpu_line( unsigned char colour, short x1, short y1, short x2, short y2 )``` Draw a straight line from (x1,y1) to (x2,y2)
```void gpu_circle( unsigned char colour, short x1, short y1, short radius )``` Draw a circle with centre at (x1,y1)
```void gpu_blit( unsigned char colour, short x1, short y1, short tile, unsigned char blit_size )``` Blit a 16 x 16 pixel tile to (x1,y1) with optional doubling to 32 x 32 pixels
```void gpu_fillcircle( unsigned char colour, short x1, short y1, short radius )``` Draw a filled circle with centre at (x1,y1)
```void gpu_triangle( unsigned char colour, short x1, short y1, short x2, short y2, short x3, short y3 )``` Draw a filled triangle with vertices (x1,y1), (x2,y2) and (x3,y3) _Vertices should be presented clockwise from the top_

```void set_blitter_bitmap( unsigned char tile, unsigned short *bitmap )``` Set a blitter tile (bitmap points to a 16 x 16 bit bitmap)

```void set_vector_vertex( unsigned char block, unsigned char vertex, unsigned char active, char deltax, char deltay )``` Set a vertex in a vector block
```void draw_vector_block( unsigned char block, unsigned char colour, short xc, short yc )``` Draw a vector block with centre (xc,yc)

```void bitmap_scrollwrap( unsigned char action )``` Moves the bitmap according to ```action``` 1 = Move LEFT, 2 = Move UP, 3 = Move RIGHT, 4 = Move DOWN, 5 = RESET

## PAWS LIBRARY FUNCTION EXAMPLES

### Vector Block

(From the asteroids example) This sets the vertices of vector block 0 to a small line drawn ship. Note that the last vertex is marked as __inactive__, the vector block drawer will stop once it reaches this vertex.

```
void set_ship_vector( void )
{
    set_vector_vertex( 0, 0, 1, 0, 0 );
    set_vector_vertex( 0, 1, 1, 5, 10 );
    set_vector_vertex( 0, 2, 1, 0, 6 );
    set_vector_vertex( 0, 3, 1, -5, 10 );
    set_vector_vertex( 0, 4, 1, 0, 0 );
    set_vector_vertex( 0, 5, 0, 0, 0 );
}
```

To draw a vector block, provide the block number, colour ( 63 is white ) along with the centre coordinates.

```draw_vector_block( 0, 63, 608, 464 );```


## GPU Timings

The GPU with the PAWS system runs at 50MHz, double the speed of the video and CPU clocks. The GPU can therefore draw to the bitmap far faster than the CPU, and will continue drawing the selected shape without further intervention from the CPU.

The PAWS library functions wait for the GPU to finish the previous command before dispatching.
