// HELPER CIRCUITS

// MINIMUM OF 2 VALUES
circuitry min( input value1, input value2, output minimum ) {
    minimum = ( value1 < value2 ) ? value1 : value2;
}

// MINIMUM OF 3 VALUES
circuitry min3( input value1, input value2, input value3, output minimum ) {
    minimum = ( value1 < value2 ) ? ( value1 < value3 ? value1 : value3 ) : ( value2 < value3 ? value2 : value3 );
}

// MAXIMUM OF 2 VALUES
circuitry max( input value1, input value2, output maximum ) {
    maximum = ( value1 > value2 ) ? value1 : value2;
}

// MAXIMUM OF 3 VALUES
circuitry max3( input value1, input value2, input value3, output maximum ) {
    maximum = ( value1 > value2 ) ? ( value1 > value3 ? value1 : value3 ) : ( value2 > value3 ? value2 : value3 );
}

// ABSOLUTE VALUE
circuitry abs( input value1, output absolute ) {
    absolute = ( value1 < 0 ) ? -value1 : value1;
}

// ABSOLUTE DELTA ( DIFFERENCE )
circuitry absdelta( input value1, input value2, output delta ) {
    delta = ( value1 < value2 ) ? value2 - value1 : value1 - value2;
}

// COPY COORDINATES
circuitry copycoordinates( input x, input y, output x1, output y1 ) {
    x1 = x;
    y1 = y;
}

// SWAP COORDINATES
circuitry swapcoordinates( input x, input y, input x1, input  y1, output x2, output y2, output x3, output y3 ) {
    x2 = x1;
    y2 = y1;
    x3 = x;
    y3 = y;
}

// ADJUST COORDINATES BY DELTAS
circuitry deltacoordinates( input x, input dx, input y, input dy, output xdx, output ydy ) {
    xdx = x + dx;
    ydy = y + dy;
}

// CROP COORDINATES TO SCREEN RANGE
circuitry cropleft( input x, output x1 ) {
    x1 = ( x < 0 ) ? 0 : x;
}
circuitry croptop( input y, output y1 ) {
    y1 = ( y < 0 ) ? 0 : y;
}
circuitry cropright( input x, output x1 ) {
    x1 = ( x > 639 ) ? 639 : x;
}
circuitry cropbottom( input y, output y1 ) {
    y1 = ( y > 479 ) ? 479 : y;
}
// CROP (x1,y1) to left and top, (x2,y2) to right and bottom
circuitry cropscreen( input x1, input y1, input x2, input y2, output newx1, output newy1, output newx2, output newy2 ) {
    newx1 = ( x1 < 0 ) ? 0 : x1;
    newy1 = ( y1 < 0 ) ? 0 : y1;
    newx2 = ( x2 > 639 ) ? 639 : x2;
    newy2 = ( y1 > 479 ) ? 479 : y2;
}

// CALCULATE IF A PIXEL IS INSIDE THE TRIANGLE BEING DRAWN
circuitry insideTriangle( input sx, input sy, input x, input y, input x1, input y1, input x2, input y2, output inside ) {
    inside = ( (( x2 - x1 ) * ( sy - y1 ) - ( y2 - y1 ) * ( sx - x1 )) >= 0 ) &&
             ( (( x - x2 ) * ( sy - y2 ) - ( y - y2 ) * ( sx - x2 )) >= 0 ) &&
             ( (( x1 - x ) * ( sy - y ) - ( y1 - y ) * ( sx - x )) >= 0 );
}

// UPDATE THE NUMERATOR FOR THE CIRCLE BEING DRAWN
circuitry updatenumerator( input gpu_numerator, input gpu_active_x, input gpu_active_y,  output new_numerator ) {
    if( gpu_numerator > 0 ) {
        new_numerator = gpu_numerator + { (gpu_active_x - gpu_active_y), 2b00 } + 10;
    } else {
        new_numerator = gpu_numerator + { gpu_active_x, 2b00 } + 6;
    }
}

algorithm gpu(
    // GPU to SET and GET pixels
    output! int11 bitmap_x_write,
    output! int11 bitmap_y_write,
    output! uint7 bitmap_colour_write,
    output! uint1 bitmap_write,

    // From j1eforth
    input   int11 gpu_x,
    input   int11 gpu_y,
    input   uint8 gpu_colour,
    input   int11 gpu_param0,
    input   int11 gpu_param1,
    input   int11 gpu_param2,
    input   int11 gpu_param3,
    input   uint4 gpu_write,

    // For setting blit1 tile bitmaps
    input   uint5   blit1_writer_tile,
    input   uint4   blit1_writer_line,
    input   uint16  blit1_writer_bitmap,

    // VECTOR BLOCK
    input   uint5   vector_block_number,
    input   uint7   vector_block_colour,
    input   int11   vector_block_xc,
    input   int11   vector_block_yc,
    input   uint1   draw_vector,
    // For setting vertices
    input   uint5   vertices_writer_block,
    input   uint6   vertices_writer_vertex,
    input   int6    vertices_writer_xdelta,
    input   int6    vertices_writer_ydelta,
    input   uint1   vertices_writer_active,

    output  uint1   gpu_active,
    output  uint1   vector_block_active
) <autorun> {
    // RECTANGLE - OUTPUT PIXELS TO DRAW A RECTANGLE
    subroutine rectangle( reads gpu_x, reads gpu_y, reads gpu_param0, reads gpu_param1, writes bitmap_x_write, writes bitmap_y_write, writes bitmap_write ) {
        int11   gpu_active_x = uninitialized;
        int11   gpu_active_y = uninitialized;
        int11   gpu_x1 = uninitialized;
        int11   gpu_max_x = uninitialized;
        int11   gpu_max_y = uninitialized;

        // Setup drawing a rectangle from x,y to param0,param1 in colour
        // Ensures that works left to right, top to bottom, crop to screen edges
        ( gpu_active_x ) = min( gpu_x, gpu_param0 );
        ( gpu_active_y ) = min( gpu_y, gpu_param1 );
        ( gpu_max_x ) = max( gpu_x, gpu_param0 );
        ( gpu_max_y ) = max( gpu_y, gpu_param1 );
        ++:
        ( gpu_active_x, gpu_active_y, gpu_max_x, gpu_max_y ) = cropscreen( gpu_active_x, gpu_active_y, gpu_max_x, gpu_max_y );
        ( gpu_x1 ) = cropleft( gpu_active_x );
        ++:
        while( gpu_active_y <= gpu_max_y ) {
            while( gpu_active_x <= gpu_max_x ) {
                ( bitmap_x_write, bitmap_y_write ) = copycoordinates( gpu_active_x, gpu_active_y );
                bitmap_write = 1;
                gpu_active_x = gpu_active_x + 1;
            }
            gpu_active_x = gpu_x1;
            gpu_active_y = gpu_active_y + 1;
        }
    }
    // LINE - OUTPUT PIXELS TO DRAW A LINE
    subroutine line( input int11 x, input int11 y, input int11 param0, input int11 param1, writes bitmap_x_write, writes bitmap_y_write, writes bitmap_write ) {
        int11   gpu_active_x = uninitialized;
        int11   gpu_active_y = uninitialized;
        int11   gpu_dx = uninitialized;
        int11   gpu_dy = uninitialized;
        int11   gpu_sy = uninitialized;
        int11   gpu_max_x = uninitialized;
        int11   gpu_max_y = uninitialized;
        int11   gpu_numerator = uninitialized;
        int11   gpu_numerator2 = uninitialized;
        int11   gpu_count = uninitialized;
        int11   gpu_max_count = uninitialized;

        // Setup drawing a line from x,y to param0,param1 in colour
        // Ensure LEFT to RIGHT
        ( gpu_active_x ) = min( x, param0 );
        gpu_active_y = ( x < param0 ) ? y : param1;
        // Determine if moving UP or DOWN
        gpu_sy = ( x < param0 ) ? ( ( y < param1 ) ? 1 : -1 ) : ( ( y < param1 ) ? -1 : 1 );
        // Absolute DELTAs
        ( gpu_dx ) = absdelta( x, param0 );
        ( gpu_dy ) = absdelta( y, param1 );
        ++:
        gpu_count = 0;
        gpu_numerator = ( gpu_dx > gpu_dy ) ? ( gpu_dx >> 1 ) : -( gpu_dy >> 1 );
        ( gpu_max_count ) = max( gpu_dx, gpu_dy );
        ++:
        while( gpu_count <= gpu_max_count ) {
            ( bitmap_x_write, bitmap_y_write ) = copycoordinates( gpu_active_x, gpu_active_y );
            bitmap_write = 1;
            gpu_numerator2 = gpu_numerator;
            ++:
            if( gpu_numerator2 > (-gpu_dx) ) {
                gpu_numerator = gpu_numerator - gpu_dy;
                gpu_active_x = gpu_active_x + 1;
                ++:
            }
            if( gpu_numerator2 < gpu_dy ) {
                gpu_numerator = gpu_numerator + gpu_dx;
                gpu_active_y = gpu_active_y + gpu_sy;
            }
            gpu_count = gpu_count + 1;
        }
    }
    //  CIRCLE - OUTPUT PIXELS TO DRAW AN OUTLINE OR FILLED CIRCLE
    subroutine circle(
        reads   gpu_x,
        reads   gpu_y,
        reads   gpu_param0,
        reads   filledcircle,
        writes  bitmap_x_write,
        writes  bitmap_y_write,
        writes  bitmap_write
    ) {
        int11   gpu_active_x = uninitialized;
        int11   gpu_active_y = uninitialized;
        int11   gpu_xc = uninitialized;
        int11   gpu_yc = uninitialized;
        int11   gpu_numerator = uninitialized;
        int11   gpu_count = uninitialised;

        // Setup drawing a filled circle centre x,y or radius param0 in colour
        // Minimum radius is 4, radius is always positive
        gpu_active_x = 0;
        ( gpu_active_y ) = abs( gpu_param0 );
        ( gpu_xc, gpu_yc ) = copycoordinates( gpu_x, gpu_y );
        ++:
        if( filledcircle ) {
            gpu_active_y = ( gpu_active_y < 4 ) ? 4 : gpu_active_y;
            gpu_count = ( gpu_active_y < 4 ) ? 4 : gpu_active_y;
        }
        ++:
        gpu_numerator = 3 - ( { gpu_active_y, 1b0 } );
        while( gpu_active_y >= gpu_active_x ) {
            if( filledcircle ) {
                while( gpu_count != 0 ) {
                    bitmap_x_write = gpu_xc + gpu_active_x;
                    bitmap_y_write = gpu_yc + gpu_count;
                    bitmap_write = 1;
                    ++:
                    bitmap_y_write = gpu_yc - gpu_count;
                    bitmap_write = 1;
                    ++:
                    bitmap_x_write = gpu_xc - gpu_active_x;
                    bitmap_write = 1;
                    ++:
                    bitmap_y_write = gpu_yc + gpu_count;
                    bitmap_write = 1;
                    ++:
                    bitmap_x_write = gpu_xc + gpu_count;
                    bitmap_y_write = gpu_yc + gpu_active_x;
                    bitmap_write = 1;
                    ++:
                    bitmap_y_write = gpu_yc - gpu_active_x;
                    bitmap_write = 1;
                    ++:
                    bitmap_x_write = gpu_xc - gpu_count;
                    bitmap_write = 1;
                    ++:
                    bitmap_y_write = gpu_yc + gpu_active_x;
                    bitmap_write = 1;

                    gpu_count = gpu_count - 1;
                }
            } else {
                bitmap_x_write = gpu_xc + gpu_active_x;
                bitmap_y_write = gpu_yc + gpu_active_y;
                bitmap_write = 1;
                ++:
                bitmap_y_write = gpu_yc - gpu_active_y;
                bitmap_write = 1;
                ++:
                bitmap_x_write = gpu_xc - gpu_active_x;
                bitmap_write = 1;
                ++:
                bitmap_y_write = gpu_yc + gpu_active_y;
                bitmap_write = 1;
                ++:
                bitmap_x_write = gpu_xc + gpu_active_y;
                bitmap_y_write = gpu_yc + gpu_active_x;
                bitmap_write = 1;
                ++:
                bitmap_y_write = gpu_yc - gpu_active_x;
                bitmap_write = 1;
                ++:
                bitmap_x_write = gpu_xc - gpu_active_y;
                bitmap_write = 1;
                ++:
                bitmap_y_write = gpu_yc + gpu_active_x;
                bitmap_write = 1;
            }
            gpu_active_x = gpu_active_x + 1;
            gpu_active_y = ( gpu_numerator > 0 ) ? gpu_active_y - 1 : gpu_active_y;
            gpu_count = ( gpu_numerator > 0 ) ? gpu_active_y - 1 : gpu_active_y;
            ( gpu_numerator ) = updatenumerator( gpu_numerator, gpu_active_x, gpu_active_y );
        }
        if( filledcircle ) {
            bitmap_x_write = gpu_xc;
            bitmap_y_write = gpu_yc;
            bitmap_write = 1;
        }
    }
    //  TRIANGLE - OUTPUT PIXELS TO DRAW A FILLED TRIANGLE
    subroutine triangle(
        reads   gpu_x,
        reads   gpu_y,
        reads   gpu_param0,
        reads   gpu_param1,
        reads   gpu_param2,
        reads   gpu_param3,
        writes  bitmap_x_write,
        writes  bitmap_y_write,
        writes  bitmap_write
    ) {
        // VERTEX COORDINATES
        int11   gpu_active_x = uninitialized;
        int11   gpu_active_y = uninitialized;
        int11   gpu_x1 = uninitialized;
        int11   gpu_y1 = uninitialized;
        int11   gpu_x2 = uninitialized;
        int11   gpu_y2 = uninitialized;

        // BOUNDING BOX
        int11   gpu_min_x = uninitialized;
        int11   gpu_max_x = uninitialized;
        int11   gpu_min_y = uninitialized;
        int11   gpu_max_y = uninitialized;

        // WORK COORDINATES
        int11   gpu_sx = uninitialized;
        int11   gpu_sy = uninitialized;

        // WORK DIRECTION ( == 0 left, == 1 right )
        uint1   gpu_dx = 1;

        // Filled triangle calculations
        // Is the point sx,sy inside the triangle given by active_x,active_y x1,y1 x2,y2?
        uint1   inTriangle = uninitialized;
        uint1   beenInTriangle = uninitialized;

        gpu_dx = 1;
        beenInTriangle = 0;

        // Setup drawing a filled triangle x,y param0, param1, param2, param3
        ( gpu_active_x, gpu_active_y ) = copycoordinates( gpu_x, gpu_y);
        ( gpu_x1, gpu_y1 ) = copycoordinates( gpu_param0, gpu_param1 );
        ( gpu_x2, gpu_y2 ) = copycoordinates( gpu_param2, gpu_param3 );
        ++:
        // Find minimum and maximum of x, x1, x2, y, y1 and y2 for the bounding box
        ( gpu_min_x ) = min3( gpu_active_x, gpu_x1, gpu_x2 );
        ( gpu_min_y ) = min3( gpu_active_y, gpu_y1, gpu_y2 );
        ( gpu_max_x ) = max3( gpu_active_x, gpu_x1, gpu_x2 );
        ( gpu_max_y ) = max3( gpu_active_y, gpu_y1, gpu_y2 );
        ++:
        // Clip to the screen edge
        ( gpu_min_x, gpu_min_y, gpu_max_x, gpu_max_y ) = cropscreen( gpu_min_x, gpu_min_y, gpu_max_x, gpu_max_y );
        ++:
        // Put points in order so that ( gpu_active_x, gpu_active_y ) is at top, then ( gpu_x1, gpu_y1 ) and ( gpu_x2, gpu_y2 ) are clockwise from there
        if( gpu_y1 < gpu_active_y ) {
            ( gpu_active_x, gpu_active_y, gpu_x1, gpu_y1 ) = swapcoordinates( gpu_active_x, gpu_active_y, gpu_x1, gpu_y1 );
            ++:
        }
        if( gpu_y2 < gpu_active_y ) {
            ( gpu_active_x, gpu_active_y, gpu_x2, gpu_y2 ) = swapcoordinates( gpu_active_x, gpu_active_y, gpu_x2, gpu_y2 );
            ++:
        }
        if( gpu_x1 < gpu_x2 ) {
            ( gpu_x1, gpu_y1, gpu_x2, gpu_y2 ) = swapcoordinates( gpu_x1, gpu_y1, gpu_x2, gpu_y2 );
            ++:
        }
        // Start at the top left
        ( gpu_sx, gpu_sy ) = copycoordinates( gpu_min_x, gpu_min_y );
        while( gpu_sy <= gpu_max_y ) {
            // Edge calculations to determine if inside the triangle - converted to DSP blocks
            ( inTriangle ) = insideTriangle( gpu_sx, gpu_sy, gpu_active_x, gpu_active_y, gpu_x1, gpu_y1, gpu_x2, gpu_y2 );
            beenInTriangle = inTriangle ? 1 : beenInTriangle;
            ( bitmap_x_write, bitmap_y_write ) = copycoordinates( gpu_sx, gpu_sy );
            bitmap_write = inTriangle;
            if( beenInTriangle && ~inTriangle ) {
                // Exited the triangle, move to the next line
                beenInTriangle = 0;
                gpu_sy = gpu_sy + 1;
                if( ( gpu_max_x - gpu_sx ) < ( gpu_sx - gpu_min_x ) ) {
                    // Closer to the right
                    gpu_sx = gpu_max_x;
                    gpu_dx = 0;
                } else {
                    // Closer to the left
                    gpu_sx = gpu_min_x;
                    gpu_dx = 1;
                }
            } else {
                switch( gpu_dx ) {
                    case 0: {
                        if( gpu_sx >= gpu_min_x ) {
                            gpu_sx = gpu_sx - 1;
                        } else {
                            gpu_dx = 1;
                            beenInTriangle = 0;
                            gpu_sy = gpu_sy + 1;
                        }
                    }
                    case 1: {
                        if( gpu_sx <= gpu_max_x ) {
                            gpu_sx = gpu_sx + 1;
                        } else {
                            gpu_dx = 0;
                            beenInTriangle = 0;
                            gpu_sy = gpu_sy + 1;
                        }
                    }
                }
            }
        }
    }
    // BLIT - ( tilecharacter == 1 ) OUTPUT PIXELS TO BLIT A 16 x 16 TILE ( PARAM1 == 0 as 16 x 16, == 1 as 32 x 32, == 2 as 64 x 64, == 3 as 128 x 128 )
    // BLIT - ( tilecharacter == 0 ) OUTPUT PIXELS TO BLIT AN 8 x 8 CHARACTER ( PARAM1 == 0 as 8 x 8, == 1 as 16 x 16, == 2 as 32 x 32, == 3 as 64 x 64 )
    subroutine blit(
        reads   gpu_x,
        reads   gpu_y,
        reads   gpu_param0,
        reads   gpu_param1,

        writes  bitmap_x_write,
        writes  bitmap_y_write,
        writes  bitmap_write,
        readwrites blit1tilemap,
    ) {
        // POSITION IN TILE/CHARACTER
        uint8   gpu_active_x = uninitialized;
        uint8   gpu_active_y = uninitialized;

        // POSITION ON THE SCREEN
        int11   gpu_x1 = uninitialized;
        int11   gpu_y1 = uninitialized;
        uint5   gpu_y2 = uninitialised;

        // MULTIPLIER FOR THE SIZE
        uint2   gpu_scale = uninitialised;
        uint8   gpu_max_x = uninitialized;
        uint8   gpu_max_y = uninitialized;

        // TILE/CHARACTER TO BLIT
        uint8   gpu_tile = uninitialized;

        gpu_active_x = 0;
        gpu_active_y = 0;
        ( gpu_x1, gpu_y1 ) = copycoordinates( gpu_x, gpu_y );
        gpu_scale = gpu_param1;
        gpu_max_x = 16 << ( gpu_param1 & 3);
        gpu_max_y = 16;
        gpu_tile = gpu_param0;
        ++:
        while( gpu_active_y < gpu_max_y ) {
            while( gpu_active_x < gpu_max_x ) {
                while( gpu_y2 < ( 1 << gpu_scale ) ) {
                    blit1tilemap.addr0 = { gpu_tile, gpu_active_y[0,4] };
                    ++:
                    bitmap_x_write = gpu_x1 + gpu_active_x;
                    bitmap_y_write = gpu_y1 + ( gpu_active_y << gpu_scale ) + gpu_y2;
                    bitmap_write = blit1tilemap.rdata0[15 - ( gpu_active_x >> gpu_scale ),1];
                    gpu_y2 = gpu_y2 + 1;
                }
                gpu_active_x = gpu_active_x + 1;
                gpu_y2 = 0;
            }
            gpu_active_x = 0;
            gpu_active_y = gpu_active_y + 1;
        }
    }

    // 32 x 16 x 16 1 bit tilemap for blit1tilemap
    simple_dualport_bram uint16 blit1tilemap[ 512 ] = uninitialized;

    // Character ROM 8x8 x 256 for character blitter
    simple_dualport_bram uint8 characterGenerator8x8[] = {
        $include('ROM/characterROM8x8.inc')
    };
    uint1   filledcircle = uninitialised;

    // GPU COLOUR
    uint7 gpu_active_colour = uninitialized;

    // GPU <-> VECTOR DRAWER Communication
    int11 v_gpu_x = uninitialised;
    int11 v_gpu_y = uninitialised;
    uint7 v_gpu_colour = uninitialised;
    int11 v_gpu_param0 = uninitialised;
    int11 v_gpu_param1 = uninitialised;
    uint1 v_gpu_write = uninitialised;

    // BLIT TILE WRITER
    blittilebitmapwriter BTBM(
        blit1_writer_tile <: blit1_writer_tile,
        blit1_writer_line <: blit1_writer_line,
        blit1_writer_bitmap <: blit1_writer_bitmap,
        blit1tilemap <:> blit1tilemap,
    );

    // VECTOR DRAWER UNIT
    vectors vector_drawer (
        vector_block_number <: vector_block_number,
        vector_block_colour <: vector_block_colour,
        vector_block_xc <: vector_block_xc,
        vector_block_yc <: vector_block_yc,
        draw_vector <: draw_vector,
        vertices_writer_block <: vertices_writer_block,
        vertices_writer_vertex <: vertices_writer_vertex,
        vertices_writer_xdelta <: vertices_writer_xdelta,
        vertices_writer_ydelta <: vertices_writer_ydelta,
        vertices_writer_active <: vertices_writer_active,

        vector_block_active :> vector_block_active,

        gpu_x :> v_gpu_x,
        gpu_y :> v_gpu_y,
        gpu_colour :> v_gpu_colour,
        gpu_param0 :> v_gpu_param0,
        gpu_param1 :> v_gpu_param1,
        gpu_write :> v_gpu_write,
        gpu_active <: gpu_active
    );


    // CONTROLS FOR BITMAP PIXEL WRITER
    bitmap_write := 0;
    bitmap_colour_write := gpu_active_colour;

    while(1) {
        if( v_gpu_write ) {
            // DRAW LINE FROM (X,Y) to (PARAM0,PARAM1) from VECTOR BLOCK
            gpu_active_colour = v_gpu_colour;
            gpu_active = 1;
            () <- line <- ( v_gpu_x, v_gpu_y, v_gpu_param0, v_gpu_param1 );
            gpu_active = 0;
        } else {
            gpu_active_colour = gpu_colour;
            switch( gpu_write ) {
                case 1: {
                    // SET PIXEL (X,Y)
                    // NO GPU ACTIVATION
                    bitmap_x_write = gpu_x;
                    bitmap_y_write = gpu_y;
                    bitmap_write = 1;
                }

                case 2: {
                    // DRAW RECTANGLE FROM (X,Y) to (PARAM0,PARAM1)
                    gpu_active = 1;
                    () <- rectangle <- ();
                    gpu_active = 0;
                }

                case 3: {
                    // DRAW LINE FROM (X,Y) to (PARAM0,PARAM1)
                    gpu_active = 1;
                    () <- line <- ( gpu_x, gpu_y, gpu_param0, gpu_param1 );
                    gpu_active = 0;
                }

                case 4: {
                    // DRAW CIRCLE CENTRE (X,Y) with RADIUS PARAM0
                    gpu_active = 1;
                    filledcircle = 0;
                    () <- circle <- ();
                    gpu_active = 0;
                }

                case 5: {
                    // BLIT 16 x 16 TILE PARAM0 TO (X,Y)
                    gpu_active = 1;
                    () <- blit <- ();
                    gpu_active = 0;
                }

                case 6: {
                    // DRAW FILLED CIRCLE CENTRE (X,Y) with RADIUS PARAM0
                    gpu_active = 1;
                    filledcircle = 1;
                    () <- circle <- ();
                    gpu_active = 0;
                }

                case 7: {
                    // DRAW FILLED TRIANGLE WITH VERTICES (X,Y) (PARAM0,PARAM1) (PARAM2,PARAM3)
                    gpu_active = 1;
                    () <- triangle <- ();
                    gpu_active = 0;
                }

                default: { gpu_active = 0; }
            }
        }
    }
}

// Vector Block
// Stores blocks of upto 16 vertices which can be sent to the GPU for line drawing
// Each vertices represents a delta from the centre of the vector
// Deltas are stored as 6 bit 2's complement range -31 to 0 to 31
// Each vertices has an active flag, processing of a vector block stops when the active flag is 0
// Each vector block has a centre x and y coordinate and a colour { rrggbb } when drawn

// Vertex in the vector block
bitfield vectorentry {
    uint1   active,
    uint1   dxsign,
    uint5   dx,
    uint1   dysign,
    uint5   dy
}

algorithm vectors(
    input   uint5   vector_block_number,
    input   uint7   vector_block_colour,
    input   int11   vector_block_xc,
    input   int11   vector_block_yc,
    input   uint1   draw_vector,

    // For setting vertices
    input   uint5   vertices_writer_block,
    input   uint6   vertices_writer_vertex,
    input   int6    vertices_writer_xdelta,
    input   int6    vertices_writer_ydelta,
    input   uint1   vertices_writer_active,

    output  uint1   vector_block_active,

    // Communication with the GPU
    output  int11 gpu_x,
    output  int11 gpu_y,
    output  uint7 gpu_colour,
    output  int11 gpu_param0,
    output  int11 gpu_param1,
    output  uint1 gpu_write,

    input  uint1 gpu_active
) <autorun> {
    // 32 vector blocks each of 16 vertices
    simple_dualport_bram uint13 vertex[512] = uninitialised;

    // Extract deltax and deltay for the present vertices
    int11 deltax := { {6{vectorentry(vertex.rdata0).dxsign}}, vectorentry(vertex.rdata0).dx };
    int11 deltay := { {6{vectorentry(vertex.rdata0).dysign}}, vectorentry(vertex.rdata0).dy };

    // Vertices being processed, plus first coordinate of each line
    uint5 block_number = uninitialised;
    uint5 vertices_number = uninitialised;

    vertexwriter VW(
        vertices_writer_block <: vertices_writer_block,
        vertices_writer_vertex <: vertices_writer_vertex,
        vertices_writer_xdelta <: vertices_writer_xdelta,
        vertices_writer_ydelta <: vertices_writer_ydelta,
        vertices_writer_active <: vertices_writer_active,

        vertex <:> vertex
    );

    // Set read address for the vertices
    vertex.addr0 := { block_number, vertices_number[0,4] };
    gpu_write := 0;

    vector_block_active = 0;
    vertices_number = 0;

    while(1) {
        if( draw_vector ) {
            block_number = vector_block_number;
            gpu_colour = vector_block_colour;
            vertices_number = 0;
            vector_block_active = 1;
            ++:
            ( gpu_x, gpu_y ) = deltacoordinates( vector_block_xc, deltax, vector_block_yc, deltay );
            vertices_number = 1;
            ++:
            while( vectorentry(vertex.rdata0).active && ( vertices_number < 16 ) ) {
                // Dispatch line to GPU
                ( gpu_param0, gpu_param1 ) = deltacoordinates( vector_block_xc, deltax, vector_block_yc, deltay );
                while( gpu_active ) {}
                gpu_write = 1;
                ++:
                // Move onto the next of the vertices
                ( gpu_x, gpu_y ) = copycoordinates( gpu_param0, gpu_param1 );
                vertices_number = vertices_number + 1;
                ++:
            }
            vector_block_active = 0;
        }
    }
}

algorithm blittilebitmapwriter(
    // For setting blit1 tile bitmaps
    input   uint5   blit1_writer_tile,
    input   uint4   blit1_writer_line,
    input   uint16  blit1_writer_bitmap,

    simple_dualport_bram_port1 blit1tilemap,
) <autorun> {
    blit1tilemap.wenable1 := 1;

    while(1) {
        blit1tilemap.addr1 = { blit1_writer_tile, blit1_writer_line };
        blit1tilemap.wdata1 = blit1_writer_bitmap;
    }
}

algorithm vertexwriter(
    // For setting vertices
    input   uint5   vertices_writer_block,
    input   uint6   vertices_writer_vertex,
    input   int6    vertices_writer_xdelta,
    input   int6    vertices_writer_ydelta,
    input   uint1   vertices_writer_active,

    simple_dualport_bram_port1 vertex
) <autorun> {
    vertex.wenable1 := 1;

    while(1) {
        vertex.addr1 = { vertices_writer_block, vertices_writer_vertex };
        vertex.wdata1 = { vertices_writer_active, __unsigned(vertices_writer_xdelta), __unsigned(vertices_writer_ydelta) };
    }
}
