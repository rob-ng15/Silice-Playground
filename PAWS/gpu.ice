algorithm gpu(
    // GPU to SET and GET pixels
    output! int11   bitmap_x_write,
    output! int11   bitmap_y_write,
    output! uint7   bitmap_colour_write,
    output! uint7   bitmap_colour_write_alt,
    output! uint1   bitmap_write,
    output! uint4   gpu_active_dithermode,

    input   int11   gpu_x,
    input   int11   gpu_y,
    input   uint7   gpu_colour,
    input   uint7   gpu_colour_alt,
    input   int11   gpu_param0,
    input   int11   gpu_param1,
    input   int11   gpu_param2,
    input   int11   gpu_param3,
    input   uint4   gpu_write,
    input   uint4   gpu_dithermode,

    // For setting blit1 tile bitmaps
    input   uint5   blit1_writer_tile,
    input   uint4   blit1_writer_line,
    input   uint16  blit1_writer_bitmap,

    // For setting character generator bitmaps
    input   uint8   character_writer_character,
    input   uint3   character_writer_line,
    input   uint8   character_writer_bitmap,

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
    simple_dualport_bram uint16 blit1tilemap <input!> [ 512 ] = uninitialized;

    // Character ROM 8x8 x 256 for character blitter
    simple_dualport_bram uint8 characterGenerator8x8 <input!> [] = {
        $include('ROM/characterROM8x8.inc')
    };

    // GPU COLOUR
    uint7   gpu_active_colour = uninitialized;
    uint7   gpu_active_colour_alt = uninitialized;

    // GPU <-> VECTOR DRAWER Communication
    int11 v_gpu_x = uninitialised;
    int11 v_gpu_y = uninitialised;
    int11 v_gpu_param0 = uninitialised;
    int11 v_gpu_param1 = uninitialised;
    uint1 v_gpu_write = uninitialised;

    // BLIT TILE WRITER
    blittilebitmapwriter BTBM(
        blit1_writer_tile <: blit1_writer_tile,
        blit1_writer_line <: blit1_writer_line,
        blit1_writer_bitmap <: blit1_writer_bitmap,

        character_writer_character <: character_writer_character,
        character_writer_line <: character_writer_line,
        character_writer_bitmap <: character_writer_bitmap,

        blit1tilemap <:> blit1tilemap,
        characterGenerator8x8 <:> characterGenerator8x8
    );

    // VECTOR DRAWER UNIT
    vectors vector_drawer (
        vector_block_number <: vector_block_number,
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
        blit1tilemap <:> blit1tilemap,
        characterGenerator8x8 <:> characterGenerator8x8
    );

    // DRAW A LINE FROM VECTOR BLOCK OUTPUT
    line VECTORline(
        x <: v_gpu_x,
        y <: v_gpu_y,
        param0 <: v_gpu_param0,
        param1 <: v_gpu_param1
    );

    // CONTROLS FOR BITMAP PIXEL WRITER
    bitmap_write := 0;
    bitmap_colour_write := gpu_active_colour;
    bitmap_colour_write_alt := gpu_active_colour_alt;

    // CONTROLS FOR GPU SUBUNITS
    GPUrectangle.start := 0;
    GPUline.start := 0;
    GPUcircle.start := 0;
    GPUdisc.start := 0;
    GPUtriangle.start := 0;
    GPUblit.start := 0;
    VECTORline.start := 0;

    while(1) {
        if( v_gpu_write ) {
            // DRAW LINE FROM (X,Y) to (PARAM0,PARAM1) from VECTOR BLOCK
            gpu_active_colour = vector_block_colour;
            gpu_active_dithermode = 0;
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
            gpu_active_colour_alt = gpu_colour_alt;
            switch( gpu_write ) {
                case 1: {
                    // SET PIXEL (X,Y)
                    // NO GPU ACTIVATION
                    gpu_active_dithermode = 0;
                    bitmap_x_write = gpu_x;
                    bitmap_y_write = gpu_y;
                    bitmap_write = 1;
                }

                case 2: {
                    // DRAW LINE FROM (X,Y) to (PARAM0,PARAM1)
                    gpu_active = 1;
                    gpu_active_dithermode = 0;
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
                    gpu_active_dithermode = gpu_dithermode;
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
                    gpu_active_dithermode = 0;
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
                    gpu_active_dithermode = gpu_dithermode;
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
                    gpu_active_dithermode = gpu_dithermode;
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
                    gpu_active_dithermode = 0;
                    GPUblit.tilecharacter = 1;
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
                    gpu_active_dithermode = 0;
                    GPUblit.tilecharacter = 0;
                    GPUblit.start = 1;
                    while( GPUblit.busy ) {
                        bitmap_x_write = GPUblit.bitmap_x_write;
                        bitmap_y_write = GPUblit.bitmap_y_write;
                        bitmap_write = GPUblit.bitmap_write;
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

    bitmap_x_write := gpu_active_x;
    bitmap_y_write := gpu_active_y;
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
            ( gpu_active_x, gpu_active_y, gpu_max_x, gpu_max_y ) = cropscreen( gpu_active_x, gpu_active_y, gpu_max_x, gpu_max_y );
            ( gpu_x1 ) = cropleft( gpu_active_x );
            ++:
            while( gpu_active_y <= gpu_max_y ) {
                while( gpu_active_x <= gpu_max_x ) {
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

    bitmap_x_write := gpu_active_x;
    bitmap_y_write := gpu_active_y;
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
            active = 0;
        }
    }
}

// CIRCLE - OUTPUT PIXELS TO DRAW AN OUTLINE CIRCLE
circuitry updatenumerator(
    output  new_numerator,
    input   gpu_numerator,
    input   gpu_active_x,
    input   gpu_active_y
) {
    if( gpu_numerator > 0 ) {
        new_numerator = gpu_numerator + { (gpu_active_x - gpu_active_y), 2b00 } + 10;
    } else {
        new_numerator = gpu_numerator + { gpu_active_x, 2b00 } + 6;
    }
}

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
            gpu_numerator = 3 - ( { gpu_active_y, 1b0 } );
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
                gpu_active_y = ( gpu_numerator > 0 ) ? gpu_active_y - 1 : gpu_active_y;
                ( gpu_numerator ) = updatenumerator( gpu_numerator, gpu_active_x, gpu_active_y );
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
            gpu_count = ( gpu_active_y < 4 ) ? 4 : gpu_active_y;
            ++:
            gpu_numerator = 3 - ( { gpu_active_y, 1b0 } );
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
                gpu_active_y = ( gpu_numerator > 0 ) ? gpu_active_y - 1 : gpu_active_y;
                gpu_count = ( gpu_numerator > 0 ) ? gpu_active_y - 1 : gpu_active_y;
                ( gpu_numerator ) = updatenumerator( gpu_numerator, gpu_active_x, gpu_active_y );
            }
            bitmap_x_write = gpu_xc;
            bitmap_y_write = gpu_yc;
            bitmap_write = 1;
            active = 0;
        }
    }
}

//  TRIANGLE - OUTPUT PIXELS TO DRAW A FILLED TRIANGLE
circuitry insideTriangle(
    input   sx,
    input   sy,
    input   x,
    input   y,
    input   x1,
    input   y1,
    input   x2,
    input   y2,
    output  inside
) {
    inside = ( (( x2 - x1 ) * ( sy - y1 ) - ( y2 - y1 ) * ( sx - x1 )) >= 0 ) &&
             ( (( x - x2 ) * ( sy - y2 ) - ( y - y2 ) * ( sx - x2 )) >= 0 ) &&
             ( (( x1 - x ) * ( sy - y ) - ( y1 - y ) * ( sx - x )) >= 0 );
}

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

    uint1   active = 0;
    busy := start ? 1 : active;

    // PIXEL TO OUTPUT
    bitmap_x_write := gpu_sx;
    bitmap_y_write := gpu_sy;
    bitmap_write := 0;

    while(1) {
        if( start ) {
            active = 1;
            gpu_dx = 1;
            beenInTriangle = 0;

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
            active = 0;
        }
    }
}

// BLIT - ( tilecharacter == 1 ) OUTPUT PIXELS TO BLIT A 16 x 16 TILE ( PARAM1 == 0 as 16 x 16, == 1 as 32 x 32, == 2 as 64 x 64, == 3 as 128 x 128 )
// BLIT - ( tilecharacter == 0 ) OUTPUT PIXELS TO BLIT AN 8 x 8 CHARACTER ( PARAM1 == 0 as 8 x 8, == 1 as 16 x 16, == 2 as 32 x 32, == 3 as 64 x 64 )
algorithm blit (
    input   int11   x,
    input   int11   y,
    input   int11   param0,
    input   uint2   param1,

    output  uint11  bitmap_x_write,
    output  uint11  bitmap_y_write,
    output  uint1   bitmap_write,

    input   uint1   start,
    input   uint1   tilecharacter,
    output  uint1   busy,

    simple_dualbram_port0 blit1tilemap,
    simple_dualbram_port0 characterGenerator8x8
) <autorun> {
    // POSITION IN TILE/CHARACTER
    uint8   gpu_active_x = uninitialized;
    uint8   gpu_active_y = uninitialized;

    // POSITION ON THE SCREEN
    int11   gpu_x1 = uninitialized;
    int11   gpu_y1 = uninitialized;
    uint5   gpu_y2 = uninitialised;

    // MULTIPLIER FOR THE SIZE
    uint2   gpu_param1 = uninitialised;
    uint8   gpu_max_x = uninitialized;
    uint8   gpu_max_y = uninitialized;

    // TILE/CHARACTER TO BLIT
    uint8   gpu_tile = uninitialized;

    uint1   active = 0;
    busy := start ? 1 : active;

    // tile and character bitmap addresses
    blit1tilemap.addr0 := { gpu_tile, gpu_active_y[0,4] };
    characterGenerator8x8.addr0 := { gpu_tile, gpu_active_y[0,3] };

    bitmap_x_write := gpu_x1 + gpu_active_x;
    bitmap_y_write := gpu_y1 + ( gpu_active_y << gpu_param1 ) + gpu_y2;
    bitmap_write := 0;

    while(1) {
        if( start ) {
            active = 1;
            gpu_active_x = 0;
            gpu_active_y = 0;
            ( gpu_x1, gpu_y1 ) = copycoordinates( x, y );
            gpu_param1 = param1;
            gpu_max_x = ( tilecharacter ? 16 : 8 ) << ( param1 & 3);
            gpu_max_y = tilecharacter ? 16 : 8;
            gpu_tile = param0;
            ++:
            while( gpu_active_y < gpu_max_y ) {
                while( gpu_active_x < gpu_max_x ) {
                    while( gpu_y2 < ( 1 << gpu_param1 ) ) {
                        bitmap_write = tilecharacter ? blit1tilemap.rdata0[15 - ( gpu_active_x >> gpu_param1 ),1] : characterGenerator8x8.rdata0[7 - ( gpu_active_x >> gpu_param1 ),1];
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
algorithm vectors(
    input   uint5   vector_block_number,
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
    output  int11 gpu_param0,
    output  int11 gpu_param1,
    output  uint1 gpu_write,

    input  uint1 gpu_active
) <autorun> {
    // 32 vector blocks each of 16 vertices
    simple_dualport_bram uint13 vertex <input!> [512] = uninitialised;

    // Extract deltax and deltay for the present vertices
    int11 deltax := { {6{vectorentry(vertex.rdata0).dxsign}}, vectorentry(vertex.rdata0).dx };
    int11 deltay := { {6{vectorentry(vertex.rdata0).dysign}}, vectorentry(vertex.rdata0).dy };

    // Vertices being processed, plus first coordinate of each line
    uint5 block_number = uninitialised;
    uint5 vertices_number = uninitialised;
    int11 start_x = uninitialised;
    int11 start_y = uninitialised;

    vertexwriter VW(
        vertices_writer_block <: vertices_writer_block,
        vertices_writer_vertex <: vertices_writer_vertex,
        vertices_writer_xdelta <: vertices_writer_xdelta,
        vertices_writer_ydelta <: vertices_writer_ydelta,
        vertices_writer_active <: vertices_writer_active,

        vertex <:> vertex
    );

    // Set read address for the vertices
    vertex.addr0 := { block_number, vertices_number };

    gpu_write := 0;

    vector_block_active = 0;
    vertices_number = 0;

    while(1) {
        if( draw_vector ) {
            vector_block_active = 1;
            block_number = vector_block_number;
            vertices_number = 0;
            ++:
            ( start_x, start_y ) = deltacoordinates( vector_block_xc, deltax, vector_block_yc, deltay );
            vertices_number = 1;
            ++:
            while( vectorentry(vertex.rdata0).active && ( vertices_number < 16 ) ) {
                // Dispatch line to GPU
                ( gpu_x, gpu_y ) = copycoordinates( start_x, start_y );
                ( gpu_param0, gpu_param1 ) = deltacoordinates( vector_block_xc, deltax, vector_block_yc, deltay );
                while( gpu_active ) {}
                gpu_write = 1;
                // Move onto the next of the vertices
                ( start_x, start_y ) = deltacoordinates( vector_block_xc, deltax, vector_block_yc, deltay );
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

    // For setting character generator bitmaps
    input   uint8   character_writer_character,
    input   uint3   character_writer_line,
    input   uint8   character_writer_bitmap,

    simple_dualbram_port1 blit1tilemap,
    simple_dualbram_port1 characterGenerator8x8
) <autorun> {
    blit1tilemap.wenable1 := 1;
    characterGenerator8x8.wenable1 := 1;

    while(1) {
        blit1tilemap.addr1 = { blit1_writer_tile, blit1_writer_line };
        blit1tilemap.wdata1 = blit1_writer_bitmap;

        characterGenerator8x8.addr1 = { character_writer_character, character_writer_line };
        characterGenerator8x8.wdata1 = character_writer_bitmap;
    }
}

algorithm vertexwriter(
    // For setting vertices
    input   uint5   vertices_writer_block,
    input   uint6   vertices_writer_vertex,
    input   int6    vertices_writer_xdelta,
    input   int6    vertices_writer_ydelta,
    input   uint1   vertices_writer_active,

    simple_dualbram_port1 vertex
) <autorun> {
    vertex.wenable1 := 1;

    while(1) {
        vertex.addr1 = { vertices_writer_block, vertices_writer_vertex };
        vertex.wdata1 = { vertices_writer_active, __unsigned(vertices_writer_xdelta), __unsigned(vertices_writer_ydelta) };
    }
}
