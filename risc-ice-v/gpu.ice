// HELPER CIRCUITS
circuitry min(
    input   value1,
    input   value2,
    output  minimum
) {
    minimum = ( value1 < value2 ) ? value1 : value2;
}

circuitry min3(
    input   value1,
    input   value2,
    input   value3,
    output  minimum
) {
    minimum = ( value1 < value2 ) ? ( value1 < value3 ? value1 : value3 ) : ( value2 < value3 ? value2 : value3 );
}

circuitry max(
    input   value1,
    input   value2,
    output  maximum
) {
    maximum = ( value1 > value2 ) ? value1 : value2;
}

circuitry max3(
    input   value1,
    input   value2,
    input   value3,
    output  maximum
) {
    maximum = ( value1 > value2 ) ? ( value1 > value3 ? value1 : value3 ) : ( value2 > value3 ? value2 : value3 );
}

circuitry abs(
    input   value1,
    output  absolute
) {
    absolute = ( value1 < 0 ) ? -value1 : value1;
}

circuitry absdelta(
    input   value1,
    input   value2,
    output  delta
) {
    delta = ( value1 < value2 ) ? value2 - value1 : value1 - value2;
}

circuitry copycoordinates(
    input   x,
    input   y,
    output  x1,
    output  y1
) {
    x1 = x;
    y1 = y;
}

circuitry swapcoordinates(
    input   x,
    input   y,
    input   x1,
    input   y1,
    output  x2,
    output  y2,
    output  x3,
    output  y3
) {
    x2 = x1;
    y2 = y1;
    x3 = x;
    y3 = y;
}

circuitry cropleft(
    input   x,
    output  x1
) {
    x1 = ( x < 0 ) ? 0 : x;
}

circuitry croptop(
    input   y,
    output  y1
) {
    y1 = ( y < 0 ) ? 0 : y;
}

circuitry cropright(
    input   x,
    output  x1
) {
    x1 = ( x > 639 ) ? 639 : x;
}

circuitry cropbottom(
    input   y,
    output  y1
) {
    y1 = ( y > 479 ) ? 479 : y;
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
    // 32 x 16 x 16 1 bit tilemap for blit1tilemap
    simple_dualport_bram uint16 blit1tilemap[ 512 ] = uninitialized;

    // Character ROM 8x8 x 256 for character blitter
    simple_dualport_bram uint8 characterGenerator8x8[] = {
        $include('ROM/characterROM8x8.inc')
    };

    // GPU COLOUR
    uint7 gpu_active_colour = uninitialized;

    // GPU <-> VECTOR DRAWER Communication
    int11 v_gpu_x = uninitialised;
    int11 v_gpu_y = uninitialised;
    uint7 v_gpu_colour = uninitialised;
    int11 v_gpu_param0 = uninitialised;
    int11 v_gpu_param1 = uninitialised;
    uint1 v_gpu_write = uninitialised;

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

    // GPU SUBUNITS
    rectangle GPUrectangle(
        x <: gpu_x,
        y <: gpu_y,
        param0 <: gpu_param0,
        param1 <: gpu_param1
    );
    line GPUline(
        x <: gpu_x,
        y <: gpu_y,
        param0 <: gpu_param0,
        param1 <: gpu_param1
    );
    circle GPUcircle(
        x <: gpu_x,
        y <: gpu_y,
        param0 <: gpu_param0
    );
    disc GPUdisc(
        x <: gpu_x,
        y <: gpu_y,
        param0 <: gpu_param0
    );
    triangle GPUtriangle(
        x <: gpu_x,
        y <: gpu_y,
        param0 <: gpu_param0,
        param1 <: gpu_param1,
        param2 <: gpu_param2,
        param3 <: gpu_param3,
    );
    blit GPUblit(
        x <: gpu_x,
        y <: gpu_y,
        param0 <: gpu_param0,
        param1 <: gpu_param1,
        blit1tilemap <:> blit1tilemap
    );
    characterblit GPUcharacterblit(
        x <: gpu_x,
        y <: gpu_y,
        param0 <: gpu_param0,
        param1 <: gpu_param1,
        characterGenerator8x8 <:> characterGenerator8x8
    );

    // DRAW A LINE FROM VECTOR BLOCK OUTPUT
    line VECTORline(
        x <: v_gpu_x,
        y <: v_gpu_y,
        param0 <: v_gpu_param0,
        param1 <: v_gpu_param1
    );

    // blit1tilemap write access for the GPU to load tilemaps
    blit1tilemap.addr1 := blit1_writer_tile * 16 + blit1_writer_line;
    blit1tilemap.wdata1 := blit1_writer_bitmap;
    blit1tilemap.wenable1 := 1;

    // CONTROLS FOR BITMAP PIXEL WRITER
    bitmap_write := 0;
    bitmap_colour_write := gpu_active_colour;

    // CONTROLS FOR GPU SUBUNITS
    GPUrectangle.start := 0;
    GPUline.start := 0;
    GPUcircle.start := 0;
    GPUdisc.start := 0;
    GPUtriangle.start := 0;
    GPUblit.start := 0;
    GPUcharacterblit.start := 0;
    VECTORline.start := 0;

    while(1) {
        if( v_gpu_write ) {
            // DRAW LINE FROM (X,Y) to (PARAM0,PARAM1) from VECTOR BLOCK
            gpu_active_colour = v_gpu_colour;
            gpu_active = 1;
            VECTORline.start = 1;
            while( VECTORline.busy ) {
                bitmap_x_write = VECTORline.bitmap_x_write;
                bitmap_y_write = VECTORline.bitmap_y_write;
                bitmap_write = VECTORline.bitmap_write;
            }
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
                    // DRAW LINE FROM (X,Y) to (PARAM0,PARAM1)
                    gpu_active = 1;
                    GPUline.start = 1;
                    while( GPUline.busy ) {
                        bitmap_x_write = GPUline.bitmap_x_write;
                        bitmap_y_write = GPUline.bitmap_y_write;
                        bitmap_write = GPUline.bitmap_write;
                    }
                    gpu_active = 0;
                }

                case 3: {
                    // DRAW RECTANGLE FROM (X,Y) to (PARAM0,PARAM1)
                    gpu_active = 1;
                    GPUrectangle.start = 1;
                    while( GPUrectangle.busy ) {
                        bitmap_x_write = GPUrectangle.bitmap_x_write;
                        bitmap_y_write = GPUrectangle.bitmap_y_write;
                        bitmap_write = GPUrectangle.bitmap_write;
                    }
                    gpu_active = 0;
                }

                case 4: {
                    // DRAW CIRCLE CENTRE (X,Y) with RADIUS PARAM0
                    gpu_active = 1;
                    GPUcircle.start = 1;
                    while( GPUcircle.busy ) {
                        bitmap_x_write = GPUcircle.bitmap_x_write;
                        bitmap_y_write = GPUcircle.bitmap_y_write;
                        bitmap_write = GPUcircle.bitmap_write;
                    }
                    gpu_active = 0;
                }

                case 5: {
                    // DRAW FILLED CIRCLE CENTRE (X,Y) with RADIUS PARAM0
                    gpu_active = 1;
                    GPUdisc.start = 1;
                    while( GPUdisc.busy ) {
                        bitmap_x_write = GPUdisc.bitmap_x_write;
                        bitmap_y_write = GPUdisc.bitmap_y_write;
                        bitmap_write = GPUdisc.bitmap_write;
                    }
                    gpu_active = 0;
                }

                case 6: {
                    // DRAW FILLED TRIANGLE WITH VERTICES (X,Y) (PARAM0,PARAM1) (PARAM2,PARAM3)
                    gpu_active = 1;
                    GPUtriangle.start = 1;
                    while( GPUtriangle.busy ) {
                        bitmap_x_write = GPUtriangle.bitmap_x_write;
                        bitmap_y_write = GPUtriangle.bitmap_y_write;
                        bitmap_write = GPUtriangle.bitmap_write;
                    }
                    gpu_active = 0;
                }

                case 7: {
                    // BLIT 16 x 16 TILE PARAM0 TO (X,Y)
                    gpu_active = 1;
                    GPUblit.start = 1;
                    while( GPUblit.busy ) {
                        bitmap_x_write = GPUblit.bitmap_x_write;
                        bitmap_y_write = GPUblit.bitmap_y_write;
                        bitmap_write = GPUblit.bitmap_write;
                    }
                    gpu_active = 0;
                }


                case 8: {
                    // BLIT 8 x 8 CHARACTER PARAM0 TO (X,Y) as 8 x 8
                    gpu_active = 1;
                    GPUcharacterblit.start = 1;
                    while( GPUcharacterblit.busy ) {
                        bitmap_x_write = GPUcharacterblit.bitmap_x_write;
                        bitmap_y_write = GPUcharacterblit.bitmap_y_write;
                        bitmap_write = GPUcharacterblit.bitmap_write;
                    }
                    gpu_active = 0;
                }

                default: { gpu_active = 0; }
            }
        }
    }
}

// RECTANGLE - OUTPUT PIXELS TO DRAW A RECTANGLE
algorithm rectangle (
    input   int11   x,
    input   int11   y,
    input   int11   param0,
    input   int11   param1,

    output!  uint11  bitmap_x_write,
    output!  uint11  bitmap_y_write,
    output!  uint1   bitmap_write,

    input   uint1   start,
    output  uint1   busy
) <autorun> {
    int11   gpu_active_x = uninitialized;
    int11   gpu_active_y = uninitialized;
    int11   gpu_x1 = uninitialized;
    int11   gpu_max_x = uninitialized;
    int11   gpu_max_y = uninitialized;
    uint1   active = 0;

    busy := start ? 1 : active;
    bitmap_write := 0;

    while(1) {
        if( start ) {
            active = 1;
            // Setup drawing a rectangle from x,y to param0,param1 in colour
            // Ensures that works left to right, top to bottom, crop to screen edges
            ( gpu_active_x ) = min( x, param0 );
            ( gpu_active_y ) = min( y, param1 );
            ( gpu_max_x ) = max( x, param0 );
            ( gpu_max_y ) = max( y, param1 );
            ++:
            ( gpu_active_x ) = cropleft( gpu_active_x );
            ( gpu_x1 ) = cropleft( gpu_active_x );
            ( gpu_active_y ) = croptop( gpu_active_y );
            ( gpu_max_x ) = cropright( gpu_max_x );
            ( gpu_max_y ) = cropbottom( gpu_max_y );
            ++:
            while( gpu_active_y <= gpu_max_y ) {
                bitmap_y_write = gpu_active_y;
                while( gpu_active_x <= gpu_max_x ) {
                    bitmap_x_write = gpu_active_x;
                    bitmap_write = 1;
                    gpu_active_x = gpu_active_x + 1;
                }
                gpu_active_x = gpu_x1;
                gpu_active_y = gpu_active_y + 1;
            }
            active = 0;
        }
    }
}

// LINE - OUTPUT PIXELS TO DRAW A LINE
algorithm line (
    input   int11   x,
    input   int11   y,
    input   int11   param0,
    input   int11   param1,

    output!  uint11  bitmap_x_write,
    output!  uint11  bitmap_y_write,
    output!  uint1   bitmap_write,

    input   uint1   start,
    output  uint1   busy
) <autorun> {
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
    uint1   active = 0;

    busy := start ? 1 : active;
    bitmap_write := 0;

    while(1) {
        if( start ) {
            active = 1;
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
                bitmap_x_write = gpu_active_x;
                bitmap_y_write = gpu_active_y;
                bitmap_write = 1;
                gpu_numerator2 = gpu_numerator;
                ++:
                if( gpu_numerator2 > (-gpu_dx) ) {
                    gpu_numerator = gpu_numerator - gpu_dy;
                    gpu_active_x = gpu_active_x + 1;
                }
                ++:
                if( gpu_numerator2 < gpu_dy ) {
                    gpu_numerator = gpu_numerator + gpu_dx;
                    gpu_active_y = gpu_active_y + gpu_sy;
                }
                gpu_count = gpu_count + 1;
            }
            active = 0;
        }
    }
}

// CIRCLE - OUTPUT PIXELS TO DRAW AN OUTLINE CIRCLE
algorithm circle (
    input   int11   x,
    input   int11   y,
    input   int11   param0,

    output  uint11  bitmap_x_write,
    output  uint11  bitmap_y_write,
    output  uint1   bitmap_write,

    input   uint1   start,
    output  uint1   busy
) <autorun> {
    int11   gpu_active_x = uninitialized;
    int11   gpu_active_y = uninitialized;
    int11   gpu_xc = uninitialized;
    int11   gpu_yc = uninitialized;
    int11   gpu_numerator = uninitialized;
    uint1   active = 0;

    busy := start ? 1 : active;
    bitmap_write := 0;

    while(1) {
        if( start ) {
            active = 1;
            // Setup drawing a circle centre x,y or radius param0 in colour
            gpu_active_x = 0;
            ( gpu_active_y ) = abs( param0 );
            ( gpu_xc, gpu_yc ) = copycoordinates( x, y );
            ++:
            gpu_numerator = 3 - ( 2 * gpu_active_y );
            ++:
            while( gpu_active_y >= gpu_active_x ) {
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

                gpu_active_x = gpu_active_x + 1;
                if( gpu_numerator > 0 ) {
                    gpu_numerator = gpu_numerator + 4 * (gpu_active_x - gpu_active_y) + 10;
                    gpu_active_y = gpu_active_y - 1;
                } else {
                    gpu_numerator = gpu_numerator + 4 * gpu_active_x + 6;
                }
            }
            active = 0;
        }
    }
}

//  DISC - OUTPUT PIXELS TO DRAW A FILLED CIRCLE
algorithm disc (
    input   int11   x,
    input   int11   y,
    input   int11   param0,

    output  uint11  bitmap_x_write,
    output  uint11  bitmap_y_write,
    output  uint1   bitmap_write,

    input   uint1   start,
    output  uint1   busy
) <autorun> {
    int11   gpu_active_x = uninitialized;
    int11   gpu_active_y = uninitialized;
    int11   gpu_xc = uninitialized;
    int11   gpu_yc = uninitialized;
    int11   gpu_numerator = uninitialized;
    int11   gpu_count = uninitialised;
    uint1   active = 0;

    busy := start ? 1 : active;
    bitmap_write := 0;

    while(1) {
        if( start ) {
            active = 1;
            // Setup drawing a filled circle centre x,y or radius param0 in colour
            // Minimum radius is 4, radius is always positive
            gpu_active_x = 0;
            ( gpu_active_y ) = abs( param0 );
            ( gpu_xc, gpu_yc ) = copycoordinates( x, y );
            ++:
            gpu_active_y = ( gpu_active_y < 4 ) ? 4 : gpu_active_y;
            ++:
            gpu_count = gpu_active_y;
            gpu_numerator = 3 - ( 2 * gpu_active_y );
            ++:
            while( gpu_active_y >= gpu_active_x ) {
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
                gpu_active_x = gpu_active_x + 1;
                if( gpu_numerator > 0 ) {
                    gpu_numerator = gpu_numerator + 4 * (gpu_active_x - gpu_active_y) + 10;
                    gpu_active_y = gpu_active_y - 1;
                    gpu_count = gpu_active_y - 1;
                } else {
                    gpu_numerator = gpu_numerator + 4 * gpu_active_x + 6;
                    gpu_count = gpu_active_y;
                }
            }
            bitmap_x_write = gpu_xc;
            bitmap_y_write = gpu_yc;
            bitmap_write = 1;
            active = 0;
        }
    }
}

//  TRIANGLE - OUTPUT PIXELS TO DRAW A FILLED TRIANGLE
algorithm triangle (
    input   int11   x,
    input   int11   y,
    input   int11   param0,
    input   int11   param1,
    input   int11   param2,
    input   int11   param3,

    output  uint11  bitmap_x_write,
    output  uint11  bitmap_y_write,
    output  uint1   bitmap_write,

    input   uint1   start,
    output  uint1   busy
) <autorun> {
    int11   gpu_active_x = uninitialized;
    int11   gpu_active_y = uninitialized;
    int11   gpu_x1 = uninitialized;
    int11   gpu_y1 = uninitialized;
    int11   gpu_x2 = uninitialized;
    int11   gpu_y2 = uninitialized;
    int11   gpu_dx = uninitialized;
    int11   gpu_sx = uninitialized;
    int11   gpu_dy = uninitialized;
    int11   gpu_sy = uninitialized;
    int11   gpu_min_x = uninitialized;
    int11   gpu_max_x = uninitialized;
    int11   gpu_min_y = uninitialized;
    int11   gpu_max_y = uninitialized;
    uint1   gpu_count = uninitialized;
    uint1   active = 0;

    // Filled triangle calculations
    // Is the point sx,sy inside the triangle given by active_x,active_y x1,y1 x2,y2?
    uint1 w0 = uninitialized;
    uint1 w1 = uninitialized;
    uint1 w2 = uninitialized;

    busy := start ? 1 : active;
    bitmap_write := 0;

    while(1) {
        if( start ) {
            active = 1;
            // Setup drawing a filled triangle x,y param0, param1, param2, param3
            ( gpu_active_x, gpu_active_y ) = copycoordinates( x, y);
            ( gpu_x1, gpu_y1 ) = copycoordinates( param0, param1 );
            ( gpu_x2, gpu_y2 ) = copycoordinates( param2, param3 );
            ++:
            // Find minimum and maximum of x, x1, x2, y, y1 and y2 for the bounding box
            ( gpu_min_x ) = min3( gpu_active_x, gpu_x1, gpu_x2 );
            ( gpu_min_y ) = min3( gpu_active_y, gpu_y1, gpu_y2 );
            ( gpu_max_x ) = max3( gpu_active_x, gpu_x1, gpu_x2 );
            ( gpu_max_y ) = max3( gpu_active_y, gpu_y1, gpu_y2 );
            ++:
            // Clip to the screen edge
            ( gpu_min_x ) = cropleft( gpu_min_x );
            ( gpu_max_x ) = cropright( gpu_max_x );
            ( gpu_min_y ) = croptop( gpu_min_y );
            ( gpu_max_y ) = cropbottom( gpu_max_y );
            ++:
            // Find the point closest to the top of the screen ( put into gpu_active_x and gpu_active_y )
            if( gpu_y1 < gpu_active_y ) {
                ( gpu_active_x, gpu_active_y, gpu_x1, gpu_y1 ) = swapcoordinates( gpu_active_x, gpu_active_y, gpu_x1, gpu_y1 );
            }
            ++:
            if( gpu_y2 < gpu_active_y ) {
                ( gpu_active_x, gpu_active_y, gpu_x2, gpu_y2 ) = swapcoordinates( gpu_active_x, gpu_active_y, gpu_x2, gpu_y2 );
            }
            ++:
            // Point order is top of screen then down to the right
            if( gpu_x1 < gpu_x2 ) {
                ( gpu_x1, gpu_y1, gpu_x2, gpu_y2 ) = swapcoordinates( gpu_x1, gpu_y1, gpu_x2, gpu_y2 );
            }
            ++:
            // Start at the top left
            ( gpu_sx, gpu_sy ) = copycoordinates( gpu_min_x, gpu_min_y );
            gpu_dx = 1;
            gpu_count = 0;
            ++:
            while( gpu_sy <= gpu_max_y ) {
                ++:
                // Edge calculations to determine if inside the triangle - converted to DSP blocks
                w0 = (( gpu_x2 - gpu_x1 ) * ( gpu_sy - gpu_y1 ) - ( gpu_y2 - gpu_y1 ) * ( gpu_sx - gpu_x1 )) >= 0;
                w1 = (( gpu_active_x - gpu_x2 ) * ( gpu_sy - gpu_y2 ) - ( gpu_active_y - gpu_y2 ) * ( gpu_sx - gpu_x2 )) >= 0;
                w2 = (( gpu_x1 - gpu_active_x ) * ( gpu_sy - gpu_active_y ) - ( gpu_y1 - gpu_active_y ) * ( gpu_sx - gpu_active_x )) >= 0;
                ++:
                bitmap_x_write = gpu_sx;
                bitmap_y_write = gpu_sy;
                bitmap_write = ( w0 && w1 && w2 );
                gpu_count = ( w0 && w1 && w2 ) ? 1 : gpu_count;
                ++:
                if( gpu_count && ~( w0 && w1 && w2 ) ) {
                    // Exited the triangle, move to the next line
                    gpu_count = 0;
                    gpu_sy = gpu_sy + 1;
                    if( ( gpu_max_x - gpu_sx ) < ( gpu_sx - gpu_min_x ) ) {
                        // Closer to the right
                        gpu_sx = gpu_max_x;
                        gpu_dx = -1;
                    } else {
                        // Closer to the left
                        gpu_sx = gpu_min_x;
                        gpu_dx = 1;
                    }
                } else {
                    switch( gpu_dx ) {
                        case 1: {
                            if( gpu_sx < gpu_max_x ) {
                                gpu_sx = gpu_sx + 1;
                            } else {
                                gpu_dx = -1;
                                gpu_count = 0;
                                gpu_sy = gpu_sy + 1;
                            }
                        }
                        default: {
                            if( gpu_sx > gpu_min_x ) {
                                gpu_sx = gpu_sx - 1;
                            } else {
                                gpu_dx = 1;
                                gpu_count = 0;
                                gpu_sy = gpu_sy + 1;
                            }
                        }
                    }
                }
            }
            active = 0;
        }
    }
}

// BLIT - OUTPUT PIXELS TO BLIT A 16 x 16 TILE ( PARAM1 == 0 as 16 x 16, == 1 as 32 x 32 )
algorithm blit (
    input   int11   x,
    input   int11   y,
    input   int11   param0,
    input   uint1   param1,

    output  uint11  bitmap_x_write,
    output  uint11  bitmap_y_write,
    output  uint1   bitmap_write,

    input   uint1   start,
    output  uint1   busy,

    simple_dualbram_port0 blit1tilemap
) <autorun> {
    int11   gpu_active_x = uninitialized;
    int11   gpu_active_y = uninitialized;
    int11   gpu_x1 = uninitialized;
    int11   gpu_y1 = uninitialized;
    int11   gpu_y2 = uninitialised;
    int11   gpu_max_x = uninitialized;
    int11   gpu_max_y = uninitialized;
    uint5   gpu_tile = uninitialized;

    uint1   active = 0;

    // blit1tilemap read access for the blit1tilemap
    blit1tilemap.addr0 := gpu_tile * 16 + gpu_active_y;

    busy := start ? 1 : active;
    bitmap_write := 0;

    while(1) {
        if( start ) {
            active = 1;
            gpu_active_x = 0;
            gpu_active_y = 0;
            ( gpu_x1, gpu_y1 ) = copycoordinates( x, y );
            gpu_max_x = 16 << param1;
            gpu_max_y = 16;
            gpu_tile = param0;
            ++:
            while( gpu_active_y < gpu_max_y ) {
                while( gpu_active_x < gpu_max_x ) {
                    bitmap_x_write = gpu_x1 + gpu_active_x;
                    while( gpu_y2 < ( 1 << param1 ) ) {
                        bitmap_y_write = gpu_y1 + ( gpu_active_y << param1 ) + gpu_y2;
                        bitmap_write = blit1tilemap.rdata0[15 - ( gpu_active_x >> param1 ),1];
                        gpu_y2 = gpu_y2 + 1;
                    }
                    gpu_active_x = gpu_active_x + 1;
                    gpu_y2 = 0;
                }
                gpu_active_x = 0;
                gpu_active_y = gpu_active_y + 1;
            }
            active = 0;
        }
    }
}

// BLIT - OUTPUT PIXELS TO BLIT AN 8 x 8 CHARACTER ( PARAM1 == 0 as 8 x 8, == 1 as 16 x 16, == 2 as 32 x 32, == 3 as 64 x 64 )
algorithm characterblit (
    input   int11   x,
    input   int11   y,
    input   int11   param0,
    input   uint2   param1,

    output  uint11  bitmap_x_write,
    output  uint11  bitmap_y_write,
    output  uint1   bitmap_write,

    input   uint1   start,
    output  uint1   busy,

    simple_dualbram_port0 characterGenerator8x8
) <autorun> {
    int11   gpu_active_x = uninitialized;
    int11   gpu_active_y = uninitialized;
    int11   gpu_x1 = uninitialized;
    int11   gpu_y1 = uninitialized;
    int11   gpu_y2 = uninitialised;
    int11   gpu_max_x = uninitialized;
    int11   gpu_max_y = uninitialized;
    uint8   gpu_tile = uninitialized;

    uint1   active = 0;

    // characterGenerator8x8 read access for the character blitter
    characterGenerator8x8.addr0 := gpu_tile * 8 + gpu_active_y;

    busy := start ? 1 : active;
    bitmap_write := 0;

    while(1) {
        if( start ) {
            active = 1;
            gpu_active_x = 0;
            gpu_active_y = 0;
            ( gpu_x1, gpu_y1 ) = copycoordinates( x, y );
            gpu_max_x = 8 << param1;
            gpu_max_y = 8;
            gpu_tile = param0;
            ++:
            while( gpu_active_y < gpu_max_y ) {
                while( gpu_active_x < gpu_max_x ) {
                    bitmap_x_write = gpu_x1 + gpu_active_x;
                    while( gpu_y2 < ( 1 << param1 ) ) {
                        bitmap_y_write = gpu_y1 + ( gpu_active_y << param1 ) + gpu_y2;
                        bitmap_write = characterGenerator8x8.rdata0[7 - ( gpu_active_x >> param1 ),1];
                        gpu_y2 = gpu_y2 + 1;
                    }
                    gpu_active_x = gpu_active_x + 1;
                    gpu_y2 = 0;
                }
                gpu_active_x = 0;
                gpu_active_y = gpu_active_y + 1;
            }
            active = 0;
        }
    }
}

// Vector Block
// Stores blocks of upto 16 vertices which can be sent to the GPU for line drawing
// Each vertices represents a delta from the centre of the vector
// Deltas are stored as 6 bit 2's complement range -31 to 0 to 31
// Each vertices has an active flag, processing of a vector block stops when the active flag is 0
// Each vector block has a centre x and y coordinate and a colour { rrggbb } when drawn

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
    int11 start_x = uninitialised;
    int11 start_y = uninitialised;

    // Set read and write address for the vertices
    vertex.addr0 := block_number * 16 + vertices_number;
    vertex.addr1 := vertices_writer_block * 16 + vertices_writer_vertex;
    vertex.wdata1 := { vertices_writer_active, __unsigned(vertices_writer_xdelta), __unsigned(vertices_writer_ydelta) };
    vertex.wenable1 := 1;

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
            start_x = vector_block_xc + deltax;
            start_y = vector_block_yc + deltay;
            vertices_number = 1;
            ++:
            while( vectorentry(vertex.rdata0).active && ( vertices_number < 16 ) ) {
                // Dispatch line to GPU
                gpu_x = start_x;
                gpu_y = start_y;
                gpu_param0 = vector_block_xc + deltax;
                gpu_param1 = vector_block_yc + deltay;
                while( gpu_active ) {}
                gpu_write = 1;
                // Move onto the next of the vertices
                start_x = vector_block_xc + deltax;
                start_y = vector_block_yc + deltay;
                vertices_number = vertices_number + 1;
                ++:
            }
            vector_block_active = 0;
        }
    }
}

