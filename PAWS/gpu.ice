algorithm gpu_queue(
    output int10   bitmap_x_write,
    output int10   bitmap_y_write,
    output uint7   bitmap_colour_write,
    output uint7   bitmap_colour_write_alt,
    output uint1   bitmap_write,
    output uint4   gpu_active_dithermode,

    input   int10   gpu_x,
    input   int10   gpu_y,
    input   uint7   gpu_colour,
    input   uint7   gpu_colour_alt,
    input   int10   gpu_param0,
    input   int10   gpu_param1,
    input   int10   gpu_param2,
    input   int10   gpu_param3,
    input   uint4   gpu_write,
    input   uint4   gpu_dithermode,

    input   uint5   blit1_writer_tile,
    input   uint4   blit1_writer_line,
    input   uint16  blit1_writer_bitmap,

    input   uint8   character_writer_character,
    input   uint3   character_writer_line,
    input   uint8   character_writer_bitmap,

    input   uint5   colourblit_writer_tile,
    input   uint4   colourblit_writer_line,
    input   uint4   colourblit_writer_pixel,
    input   uint7   colourblit_writer_colour,

    input   uint7   pb_colour7,
    input   uint8   pb_colour8r,
    input   uint8   pb_colour8g,
    input   uint8   pb_colour8b,
    input   uint2   pb_newpixel,

    input   uint5   vector_block_number,
    input   uint7   vector_block_colour,
    input   int10   vector_block_xc,
    input   int10   vector_block_yc,
    input   uint3   vector_block_scale,
    input   uint1   draw_vector,
    input   uint5   vertices_writer_block,
    input   uint6   vertices_writer_vertex,
    input   int6    vertices_writer_xdelta,
    input   int6    vertices_writer_ydelta,
    input   uint1   vertices_writer_active,

    output  uint1   queue_full,
    output  uint1   queue_complete,
    output  uint1   vector_block_active
) <autorun> {
    // 32 x 16 x 16 1 bit tilemap for blit1tilemap
    simple_dualport_bram uint16 blit1tilemap <input!> [ 512 ] = uninitialized;
    // Character ROM 8x8 x 256 for character blitter
    simple_dualport_bram uint8 characterGenerator8x8 <input!> [] = {
        $include('ROM/characterROM8x8.inc')
    };
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
    // 32 x 16 x 16 7 bit tilemap for colour
    simple_dualport_bram uint7 colourblittilemap <input!> [ 8192 ] = uninitialized;
    // COLOURBLIT TILE WRITER
    colourblittilebitmapwriter CBTBM(
        colourblit_writer_tile <: colourblit_writer_tile,
        colourblit_writer_line <: colourblit_writer_line,
        colourblit_writer_pixel <: colourblit_writer_pixel,
        colourblit_writer_colour <: colourblit_writer_colour,
        colourblittilemap <:> colourblittilemap,
    );

    // 32 vector blocks each of 16 vertices
    simple_dualport_bram uint13 vertex <input!> [512] = uninitialised;
    // VECTOR DRAWER UNIT
    vectors vector_drawer(
        vector_block_number <: vector_block_number,
        vector_block_xc <: vector_block_xc,
        vector_block_yc <: vector_block_yc,
        vector_block_scale <: vector_block_scale,
        draw_vector <: draw_vector,
        vector_block_active :> vector_block_active,
        vertex <:> vertex,
        gpu_active <: gpu_active
    );
    vertexwriter VW(
        vertices_writer_block <: vertices_writer_block,
        vertices_writer_vertex <: vertices_writer_vertex,
        vertices_writer_xdelta <: vertices_writer_xdelta,
        vertices_writer_ydelta <: vertices_writer_ydelta,
        vertices_writer_active <: vertices_writer_active,
        vertex <:> vertex
    );

    int10   x = uninitialised;
    int10   y = uninitialised;
    uint7   colour = uninitialised;
    uint7   colour_alt = uninitialised;
    int10   param0 = uninitialised;
    int10   param1 = uninitialised;
    int10   param2 = uninitialised;
    int10   param3 = uninitialised;
    uint4   dithermode = uninitialised;
    uint1   gpu_active = uninitialised;
    gpu GPU(
        gpu_x <: x,
        gpu_y <: y,
        gpu_colour <: colour,
        gpu_colour_alt <: colour_alt,
        gpu_param0 <: param0,
        gpu_param1 <: param1,
        gpu_param2 <: param2,
        gpu_param3 <: param3,
        gpu_dithermode <: dithermode,
        blit1tilemap <:> blit1tilemap,
        characterGenerator8x8 <:> characterGenerator8x8,
        colourblittilemap <:> colourblittilemap,
        bitmap_x_write :> bitmap_x_write,
        bitmap_y_write :> bitmap_y_write,
        bitmap_colour_write :> bitmap_colour_write,
        bitmap_colour_write_alt :> bitmap_colour_write_alt,
        bitmap_write :> bitmap_write,
        gpu_active_dithermode :> gpu_active_dithermode,
        pb_colour7 <: pb_colour7,
        pb_colour8r <: pb_colour8r,
        pb_colour8g <: pb_colour8g,
        pb_colour8b <: pb_colour8b,
        pb_newpixel <: pb_newpixel,
        gpu_active :> gpu_active
    );

    queue_full := gpu_active | vector_block_active; queue_complete := ~( gpu_active | vector_block_active );
    GPU.gpu_write := ( gpu_write != 0 ) ? gpu_write : vector_drawer.gpu_write ? 2 : 0;

    always {
        switch( gpu_write ) {
            case 0: {
                if( vector_drawer.gpu_write ) {
                    x = vector_drawer.gpu_x;
                    y = vector_drawer.gpu_y;
                    colour = vector_block_colour;
                    colour_alt = 0;
                    param0 = vector_drawer.gpu_param0;
                    param1 = vector_drawer.gpu_param1;
                    param2 = 0;
                    param3 = 0;
                    dithermode = 0;
                }
            }
            default: {
                x = gpu_x;
                y = gpu_y;
                colour = gpu_colour;
                colour_alt = gpu_colour_alt;
                param0 = gpu_param0;
                param1 = gpu_param1;
                param2 = gpu_param2;
                param3 = gpu_param3;
                dithermode = gpu_dithermode;
            }
        }
    }
}

algorithm gpu(
    simple_dualport_bram_port0 blit1tilemap,
    simple_dualport_bram_port0 characterGenerator8x8,
    simple_dualport_bram_port0 colourblittilemap,

    // GPU to SET and GET pixels
    output int10   bitmap_x_write,
    output int10   bitmap_y_write,
    output uint7   bitmap_colour_write,
    output uint7   bitmap_colour_write_alt,
    output uint1   bitmap_write,
    output uint4   gpu_active_dithermode,

    input   int10   gpu_x,
    input   int10   gpu_y,
    input   uint7   gpu_colour,
    input   uint7   gpu_colour_alt,
    input   int10   gpu_param0,
    input   int10   gpu_param1,
    input   int10   gpu_param2,
    input   int10   gpu_param3,
    input   uint4   gpu_write,
    input   uint4   gpu_dithermode,

    input   uint7   pb_colour7,
    input   uint8   pb_colour8r,
    input   uint8   pb_colour8g,
    input   uint8   pb_colour8b,
    input   uint2   pb_newpixel,

    output  uint1   gpu_active(0),
) <autorun> {
    // GPU COLOUR
    uint7   gpu_active_colour = uninitialized;
    uint7   gpu_active_colour_alt = uninitialized;

    // GPU SUBUNITS
    uint7  gpu_busy_flags = uninitialised;
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
        param0 <: gpu_param0,
        param1 <: gpu_param1
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
        blit1tilemap <:> blit1tilemap,
        characterGenerator8x8 <:> characterGenerator8x8,
        x <: gpu_x,
        y <: gpu_y,
        param0 <: gpu_param0,
        param1 <: gpu_param1
    );
    colourblit GPUcolourblit(
        colourblittilemap <:> colourblittilemap,
        x <: gpu_x,
        y <: gpu_y,
        param0 <: gpu_param0,
        param1 <: gpu_param1
    );
    pixelblock GPUpixelblock(
        x <: gpu_x,
        y <: gpu_y,
        param0 <: gpu_param0,
        param1 <: gpu_param1,
        colour7 <: pb_colour7,
        colour8r <: pb_colour8r,
        colour8g <: pb_colour8g,
        colour8b <: pb_colour8b,
        newpixel <: pb_newpixel
    );

    // CONTROLS FOR BITMAP PIXEL WRITER
    bitmap_write := 0; bitmap_colour_write := gpu_active_colour; bitmap_colour_write_alt := gpu_active_colour_alt;

    // CONTROLS FOR GPU SUBUNITS
    GPUrectangle.start := 0; GPUline.start := 0; GPUcircle.start := 0; GPUtriangle.start := 0; GPUblit.start := 0; GPUcolourblit.start := 0; GPUpixelblock.start := 0;

    while(1) {
        gpu_active_colour = ( gpu_write != 0 ) ? gpu_colour : gpu_active_colour;
        gpu_active_colour_alt = ( gpu_write != 0 ) ? gpu_colour_alt : gpu_active_colour_alt;
        switch( gpu_write ) {
            case 0: {}
            case 1: {
                // SET PIXEL (X,Y) NO GPU ACTIVATION
                gpu_active_dithermode = 0; bitmap_x_write = gpu_x; bitmap_y_write = gpu_y; bitmap_write = 1;
            }
            default: {
                // START THE GPU DRAWING UNIT
                gpu_active = 1;
                switch( gpu_write ) {
                    default: {}
                    case 2: { gpu_active_dithermode = 0; GPUline.start = 1; } // DRAW LINE FROM (X,Y) to (PARAM0,PARAM1)
                    case 3: { gpu_active_dithermode = gpu_dithermode; GPUrectangle.start = 1; } // DRAW RECTANGLE FROM (X,Y) to (PARAM0,PARAM1)
                    case 4: { gpu_active_dithermode = 0; GPUcircle.filledcircle = 0; GPUcircle.start = 1; } // DRAW CIRCLE CENTRE (X,Y) with RADIUS PARAM0
                    case 5: { gpu_active_dithermode = gpu_dithermode; GPUcircle.filledcircle = 1; GPUcircle.start = 1; } // DRAW FILLED CIRCLE CENTRE (X,Y) with RADIUS PARAM0
                    case 6: { gpu_active_dithermode = gpu_dithermode; GPUtriangle.start = 1; } // DRAW FILLED TRIANGLE WITH VERTICES (X,Y) (PARAM0,PARAM1) (PARAM2,PARAM3)
                    case 7: { gpu_active_dithermode = 0; GPUblit.tilecharacter = 1; GPUblit.start = 1; } // BLIT 16 x 16 TILE PARAM0 TO (X,Y)
                    case 8: { gpu_active_dithermode = 0; GPUblit.tilecharacter = 0; GPUblit.start = 1; } // BLIT 8 x 8 CHARACTER PARAM0 TO (X,Y) as 8 x 8
                    case 9: { gpu_active_dithermode = 0; GPUcolourblit.start = 1; } // BLIT 16 x 16 COLOUR TILE PARAM0 TO (X,Y) as 16 x 16
                    case 10: { gpu_active_dithermode = 0; GPUpixelblock.start = 1; } // START THE PIXELBLOCK WRITER AT (x,y) WITH WIDTH PARAM0, IGNORE COLOUR PARAM1
                }
                while( GPUline.busy || GPUrectangle.busy ||  GPUcircle.busy || GPUtriangle.busy ||  GPUblit.busy || GPUcolourblit.busy || GPUpixelblock.busy ) {
                    gpu_busy_flags =  { GPUpixelblock.busy, GPUcolourblit.busy, GPUblit.busy, GPUtriangle.busy, GPUcircle.busy, GPUrectangle.busy, GPUline.busy };
                    onehot( gpu_busy_flags ) {
                        case 0: { bitmap_x_write = GPUline.bitmap_x_write; bitmap_y_write = GPUline.bitmap_y_write; }
                        case 1: { bitmap_x_write = GPUrectangle.bitmap_x_write; bitmap_y_write = GPUrectangle.bitmap_y_write; }
                        case 2: { bitmap_x_write = GPUcircle.bitmap_x_write; bitmap_y_write = GPUcircle.bitmap_y_write; }
                        case 3: { bitmap_x_write = GPUtriangle.bitmap_x_write; bitmap_y_write = GPUtriangle.bitmap_y_write; }
                        case 4: { bitmap_x_write = GPUblit.bitmap_x_write; bitmap_y_write = GPUblit.bitmap_y_write; }
                        case 5: { bitmap_x_write = GPUcolourblit.bitmap_x_write; bitmap_y_write = GPUcolourblit.bitmap_y_write; bitmap_colour_write = GPUcolourblit.bitmap_colour_write; }
                        case 6: { bitmap_x_write = GPUpixelblock.bitmap_x_write; bitmap_y_write = GPUpixelblock.bitmap_y_write; bitmap_colour_write = GPUpixelblock.bitmap_colour_write; }
                    }
                    bitmap_write = GPUline.bitmap_write | GPUrectangle.bitmap_write | GPUcircle.bitmap_write | GPUtriangle.bitmap_write | GPUblit.bitmap_write | GPUcolourblit.bitmap_write | GPUpixelblock.bitmap_write;
                }
                gpu_active = 0;
            }
        }
    }
}

// RECTANGLE - OUTPUT PIXELS TO DRAW A RECTANGLE
algorithm preprectangle(
    input   int10   x,
    input   int10   y,
    input   int10   param0,
    input   int10   param1,
    output  int10   gpu_active_x,
    output  int10   gpu_active_y,
    output  int10   gpu_max_x,
    output  int10   gpu_max_y
) {
    ( gpu_active_x ) = min( x, param0 );
    ( gpu_active_y ) = min( y, param1 );
    ( gpu_max_x ) = max( x, param0 );
    ( gpu_max_y ) = max( y, param1 );
    ++:
    ( gpu_active_x, gpu_active_y, gpu_max_x, gpu_max_y ) = cropscreen( gpu_active_x, gpu_active_y, gpu_max_x, gpu_max_y );
}
algorithm drawrectangle(
    input   uint1   start,
    output  uint1   busy(0),
    input   int10   start_x,
    input   int10   start_y,
    input   int10   max_x,
    input   int10   max_y,
    output  int10   bitmap_x_write,
    output  int10   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    int10   x = uninitialized;
    int10   y = uninitialized;

    bitmap_x_write := x; bitmap_y_write := y; bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            x = start_x; y = start_y;
            while( y <= max_y ) {
                while( x <= max_x ) {
                    bitmap_write = 1;
                    x = x + 1;
                }
                x = start_x;
                y = y + 1;
            }
            busy = 0;
        }
    }
}
algorithm rectangle (
    input   uint1   start,
    output  uint1   busy(0),
    input   int10   x,
    input   int10   y,
    input   int10   param0,
    input   int10   param1,

    output  int10   bitmap_x_write,
    output  int10   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    int10   gpu_active_x = uninitialized;
    int10   gpu_active_y = uninitialized;
    int10   gpu_max_x = uninitialized;
    int10   gpu_max_y = uninitialized;
    preprectangle PREP(
        x <: x,
        y <: y,
        param0 <: param0,
        param1 <: param1,
        gpu_active_x :> gpu_active_x,
        gpu_active_y :> gpu_active_y,
        gpu_max_x :> gpu_max_x,
        gpu_max_y :> gpu_max_y
    );
    drawrectangle RECTANGLE(
        start_x <: gpu_active_x,
        start_y <: gpu_active_y,
        max_x <: gpu_max_x,
        max_y <: gpu_max_y,
        bitmap_x_write :> bitmap_x_write,
        bitmap_y_write :> bitmap_y_write,
        bitmap_write :> bitmap_write
    );

    RECTANGLE.start := 0;
    while(1) {
        if( start ) {
            busy = 1;
            () <- PREP <- ();
            RECTANGLE.start = 1; while( RECTANGLE.busy ) {}
            busy = 0;
        }
    }
}

// LINE - OUTPUT PIXELS TO DRAW A LINE
algorithm prepline(
    input   int10   x,
    input   int10   y,
    input   int10   param0,
    input   int10   param1,
    output  int10   gpu_active_x,
    output  int10   gpu_active_y,
    output  int10   gpu_dx,
    output  int10   gpu_dy,
    output  int10   gpu_sy,
    output  int10   gpu_numerator,
    output  int10   gpu_max_count
) {
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
    gpu_numerator = ( gpu_dx > gpu_dy ) ? ( gpu_dx >> 1 ) : -( gpu_dy >> 1 );
    ( gpu_max_count ) = max( gpu_dx, gpu_dy );
    ++:
    gpu_max_count = gpu_max_count + 1;
}
algorithm drawline(
    input   uint1   start,
    output  uint1   busy(0),
    input   int10   start_x,
    input   int10   start_y,
    input   int10   start_numerator,
    input   int10   dx,
    input   int10   dy,
    input   int10   sy,
    input   int10   max_count,
    output  int10   bitmap_x_write,
    output  int10   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    int10   x = uninitialized;
    int10   y = uninitialized;
    int10   numerator = uninitialized;
    int10   numerator2 = uninitialized;
    int10   count = uninitialized;

    bitmap_x_write := x;
    bitmap_y_write := y;
    bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            x = start_x; y = start_y; numerator = start_numerator; count = 0;
            while( count != max_count ) {
                bitmap_write = 1;
                numerator2 = numerator;
                ++:
                switch( numerator2 > (-dx) ) {
                    case 1: { numerator = numerator - dy; x = x + 1; }
                    default: {}
                }
                ++:
                switch( numerator2 < dy ) {
                    case 1: { numerator = numerator + dx; y = y + sy; }
                    default: {}
                }
                count = count + 1;
            }
            busy = 0;
        }
    }
}
algorithm line (
    input   uint1   start,
    output  uint1   busy(0),
    input   int10   x,
    input   int10   y,
    input   int10   param0,
    input   int10   param1,
    output  int10   bitmap_x_write,
    output  int10   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    int10   gpu_active_x = uninitialized;
    int10   gpu_active_y = uninitialized;
    int10   gpu_dx = uninitialized;
    int10   gpu_dy = uninitialized;
    int10   gpu_sy = uninitialized;
    int10   gpu_numerator = uninitialized;
    int10   gpu_max_count = uninitialized;
    prepline PREP(
        x <: x,
        y <: y,
        param0 <: param0,
        param1 <: param1,
        gpu_active_x :> gpu_active_x,
        gpu_active_y :> gpu_active_y,
        gpu_dx :> gpu_dx,
        gpu_dy :> gpu_dy,
        gpu_sy :> gpu_sy,
        gpu_numerator :> gpu_numerator,
        gpu_max_count :> gpu_max_count
    );
    drawline LINE(
        start_x <: gpu_active_x,
        start_y <: gpu_active_y,
        start_numerator <: gpu_numerator,
        dx <: gpu_dx,
        dy <: gpu_dy,
        sy <: gpu_sy,
        max_count <: gpu_max_count,
        bitmap_x_write :> bitmap_x_write,
        bitmap_y_write :> bitmap_y_write,
        bitmap_write :> bitmap_write
    );

    LINE.start := 0;
    while(1) {
        if( start ) {
            busy = 1;
            () <- PREP <- ();
            LINE.start = 1; while( LINE.busy ) {}
            busy = 0;
        }
    }
}

//  CIRCLE - OUTPUT PIXELS TO DRAW AN OUTLINE OR FILLED CIRCLE
// UPDATE THE NUMERATOR FOR THE CIRCLE BEING DRAWN
algorithm prepcircle(
    input   int10   x,
    input   int10   y,
    input   int10   param0,
    input   int10   param1,
    output  int10   gpu_xc,
    output  int10   gpu_yc,
    output  int10   radius,
    output  int10   gpu_numerator,
    output  uint8   draw_sectors
) {
    // Setup drawing a circle centre x,y or radius param0 in colour
    ( radius ) = abs( param0 );
    ( gpu_xc, gpu_yc ) = copycoordinates( x, y );
    draw_sectors = param1;
    ++:
    gpu_numerator = 3 - ( { radius, 1b0 } );
}
algorithm updatenumerator(
    input   int10   gpu_numerator,
    input   int10   gpu_active_x,
    input   int10   gpu_active_y,
    output  int10   new_numerator
) <autorun> {
    always {
        switch( gpu_numerator[9,1] ) {
            case 0: { new_numerator = gpu_numerator + { (gpu_active_x - gpu_active_y), 2b00 } + 10; }
            case 1: { new_numerator = gpu_numerator + { gpu_active_x, 2b00 } + 6; }
        }
    }
}
algorithm drawcircle(
    input   uint1   start,
    output  uint1   busy(0),
    input   int10   xc,
    input   int10   yc,
    input   int10   radius,
    input   int10   start_numerator,
    input   uint8   draw_sectors,
    input   uint1   filledcircle,
    output  int10   bitmap_x_write,
    output  int10   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    updatenumerator UN(
        gpu_numerator <: numerator,
        gpu_active_x <: active_x,
        gpu_active_y <: active_y
    );

    uint8   PIXELOUTPUT = uninitialised;
    uint8   PIXELMASK <:: PIXELOUTPUT;
    int10   active_x = uninitialized;
    int10   active_y = uninitialized;
    int10   count = uninitialised;
    int10   min_count = uninitialised;
    int10   numerator = uninitialised;

    bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            active_x = 0; active_y = radius; count = radius; numerator = start_numerator;
            min_count = (-1);
            while( active_y >= active_x ) {
                while( count != min_count ) {
                    PIXELOUTPUT = 8b000000001;
                    while( PIXELOUTPUT != 0 ) {
                        // OUTPUT PIXELS IN THE 8 SEGMENTS/ARCS
                        onehot( PIXELOUTPUT ) {
                            case 0: { bitmap_x_write = xc + active_x; bitmap_y_write = yc + count; }
                            case 1: { bitmap_y_write = yc - count; }
                            case 2: { bitmap_x_write = xc - active_x; }
                            case 3: { bitmap_y_write = yc + count; }
                            case 4: { bitmap_x_write = xc + count; bitmap_y_write = yc + active_x; }
                            case 5: { bitmap_y_write = yc - active_x; }
                            case 6: { bitmap_x_write = xc - count; }
                            case 7: { bitmap_y_write = yc + active_x; }
                        }
                        bitmap_write = ( draw_sectors & PIXELMASK ) != 0;
                        PIXELOUTPUT = PIXELOUTPUT << 1;
                    }
                    count = filledcircle ? count - 1 : min_count;
                }
                active_x = active_x + 1;
                active_y = active_y - ( numerator > 0 );
                count = active_y - ( numerator > 0 );
                min_count = min_count + 1;
                numerator = UN.new_numerator;
            }
            busy = 0;
        }
    }
}
algorithm circle(
    input   uint1   start,
    output  uint1   busy(0),
    input   int10   x,
    input   int10   y,
    input   int10   param0,
    input   uint8   param1,
    input   uint1   filledcircle,

    output  int10  bitmap_x_write,
    output  int10  bitmap_y_write,
    output  uint1  bitmap_write
) <autorun> {
    int10   radius = uninitialized;
    int10   gpu_xc = uninitialized;
    int10   gpu_yc = uninitialized;
    int10   gpu_numerator = uninitialized;
    uint8   draw_sectors = uninitialised;
    prepcircle PREP(
        x <: x,
        y <: y,
        param0 <: param0,
        param1 <: param1,
        gpu_xc :> gpu_xc,
        gpu_yc :> gpu_yc,
        radius :> radius,
        gpu_numerator :> gpu_numerator,
        draw_sectors :> draw_sectors
    );
    drawcircle CIRCLE(
        xc <: gpu_xc,
        yc <: gpu_yc,
        radius <: radius,
        start_numerator <: gpu_numerator,
        draw_sectors <: draw_sectors,
        filledcircle <: filledcircle,
        bitmap_x_write :> bitmap_x_write,
        bitmap_y_write :> bitmap_y_write,
        bitmap_write :> bitmap_write
    );

    CIRCLE.start := 0;
    while(1) {
        if( start ) {
            busy = 1;
            () <- PREP <- ();
            CIRCLE.start = 1; while( CIRCLE.busy ) {}
            busy = 0;
        }
    }
}

// TRIANGLE - OUTPUT PIXELS TO DRAW A FILLED TRIANGLE
// CALCULATE IF A PIXEL IS INSIDE THE TRIANGLE BEING DRAWN
algorithm preptriangle(
    input   int10   x,
    input   int10   y,
    input   int10   param0,
    input   int10   param1,
    input   int10   param2,
    input   int10   param3,
    output  int10   gpu_active_x,
    output  int10   gpu_active_y,
    output  int10   gpu_x1,
    output  int10   gpu_y1,
    output  int10   gpu_x2,
    output  int10   gpu_y2,
    output  int10   gpu_min_x,
    output  int10   gpu_min_y,
    output  int10   gpu_max_x,
    output  int10   gpu_max_y
) {
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
    // Put points in order so that ( gpu_active_x, gpu_active_y ) is at top, then ( gpu_x1, gpu_y1 ) and ( gpu_x2, gpu_y2 ) are clockwise from there
    if( gpu_y1 < gpu_active_y ) { ( gpu_active_x, gpu_active_y, gpu_x1, gpu_y1 ) = swapcoordinates( gpu_active_x, gpu_active_y, gpu_x1, gpu_y1 ); ++: }
    if( gpu_y2 < gpu_active_y ) { ( gpu_active_x, gpu_active_y, gpu_x2, gpu_y2 ) = swapcoordinates( gpu_active_x, gpu_active_y, gpu_x2, gpu_y2 ); ++: }
    if( gpu_x1 < gpu_x2 ) { ( gpu_x1, gpu_y1, gpu_x2, gpu_y2 ) = swapcoordinates( gpu_x1, gpu_y1, gpu_x2, gpu_y2 ); ++: }
    ++:
    gpu_max_y = gpu_max_y + 1;
}
algorithm insideTriangle(
    input   int10   sx,
    input   int10   sy,
    input   int10   x,
    input   int10   y,
    input   int10   x1,
    input   int10   y1,
    input   int10   x2,
    input   int10   y2,
    output  uint1   inside
) <autorun> {
    inside := ( (( x2 - x1 ) * ( sy - y1 ) - ( y2 - y1 ) * ( sx - x1 )) >= 0 ) &
                ( (( x - x2 ) * ( sy - y2 ) - ( y - y2 ) * ( sx - x2 )) >= 0 ) &
                ( (( x1 - x ) * ( sy - y ) - ( y1 - y ) * ( sx - x )) >= 0 );
}
algorithm drawtriangle(
    input   uint1   start,
    output  uint1   busy(0),
    input   int10   min_x,
    input   int10   min_y,
    input   int10   max_x,
    input   int10   max_y,
    input   int10   x0,
    input   int10   y0,
    input   int10   x1,
    input   int10   y1,
    input   int10   x2,
    input   int10   y2,
    output  int10   bitmap_x_write,
    output  int10   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    // Filled triangle calculations
    // Is the point sx,sy inside the triangle given by active_x,active_y x1,y1 x2,y2?
    uint1   inTriangle = uninitialized;
    uint1   beenInTriangle = uninitialized;
    uint1   EXIT = uninitialised;
    insideTriangle IN(
        sx <: sx,
        sy <: sy,
        x <: x0,
        y <: y0,
        x1 <: x1,
        y1 <: y1,
        x2 <: x2,
        y2 <: y2,
        inside :> inTriangle
    );
    // WORK COORDINATES
    int10   sx = uninitialized;
    int10   sy = uninitialized;
    // WORK DIRECTION ( == 0 left, == 1 right )
    uint1   dx = uninitialized;

    bitmap_x_write := sx;
    bitmap_y_write := sy;
    bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            dx = 1; beenInTriangle = 0; sx = min_x; sy = min_y;
            while( sy != max_y ) {
                // Edge calculations to determine if inside the triangle - converted to DSP blocks
                beenInTriangle = inTriangle ? 1 : beenInTriangle;
                bitmap_write = inTriangle;
                EXIT = ( beenInTriangle & ~inTriangle );
                switch( EXIT ) {
                    case 1: {
                        // Exited the triangle, move to the next line
                        beenInTriangle = 0;
                        sy = sy + 1;
                        switch( ( max_x - sx ) < ( sx - min_x ) ) {
                            // Closer to the right
                            case 1: { sx = max_x; dx = 0; }
                            // Closer to the left
                            case 0: { sx = min_x; dx = 1; }
                        }
                    }
                    case 0: {
                        switch( dx ) {
                            case 0: {
                                switch( sx >= min_x ) {
                                    case 1: { sx = sx - 1; }
                                    case 0: { dx = 1; beenInTriangle = 0; sy = sy + 1; }
                                }
                            }
                            case 1: {
                                switch( sx <= max_x ) {
                                    case 1: { sx = sx + 1; }
                                    case 0: { dx = 0; beenInTriangle = 0; sy = sy + 1; }
                                }
                            }
                        }
                    }
                }
            }
            busy = 0;
        }
    }
}
algorithm triangle(
    input   uint1   start,
    output  uint1   busy(0),
    input   int10   x,
    input   int10   y,
    input   int10   param0,
    input   int10   param1,
    input   int10   param2,
    input   int10   param3,
    output  int10   bitmap_x_write,
    output  int10   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    // VERTEX COORDINATES AND BOUNDING BOX
    int10   gpu_active_x = uninitialized;
    int10   gpu_active_y = uninitialized;
    int10   gpu_x1 = uninitialized;
    int10   gpu_y1 = uninitialized;
    int10   gpu_x2 = uninitialized;
    int10   gpu_y2 = uninitialized;
    int10   gpu_min_x = uninitialized;
    int10   gpu_max_x = uninitialized;
    int10   gpu_min_y = uninitialized;
    int10   gpu_max_y = uninitialized;
    preptriangle PREP(
        x <: x,
        y <: y,
        param0 <: param0,
        param1 <: param1,
        param2 <: param2,
        param3 <: param3,
        gpu_active_x :> gpu_active_x,
        gpu_active_y :> gpu_active_y,
        gpu_x1 :> gpu_x1,
        gpu_y1 :> gpu_y1,
        gpu_x2 :> gpu_x2,
        gpu_y2 :> gpu_y2,
        gpu_min_x :> gpu_min_x,
        gpu_min_y :> gpu_min_y,
        gpu_max_x :> gpu_max_x,
        gpu_max_y :> gpu_max_y
    );
    drawtriangle TRIANGLE(
        min_x <: gpu_min_x,
        max_x <: gpu_max_x,
        min_y <: gpu_min_y,
        max_y <: gpu_max_y,
        x0 <: gpu_active_x,
        y0 <: gpu_active_y,
        x1 <: gpu_x1,
        y1 <: gpu_y1,
        x2 <: gpu_x2,
        y2 <: gpu_y2,
        bitmap_x_write :> bitmap_x_write,
        bitmap_y_write :> bitmap_y_write,
        bitmap_write :> bitmap_write
    );

    TRIANGLE.start := 0;
    while(1) {
        if( start ) {
            busy = 1;
            () <- PREP <- ();
            TRIANGLE.start = 1; while( TRIANGLE.busy ) {}
            busy = 0;
        }
    }
}

// BLIT - ( tilecharacter == 1 ) OUTPUT PIXELS TO BLIT A 16 x 16 TILE ( PARAM1 == 0 as 16 x 16, == 1 as 32 x 32, == 2 as 64 x 64, == 3 as 128 x 128 )
// BLIT - ( tilecharacter == 0 ) OUTPUT PIXELS TO BLIT AN 8 x 8 CHARACTER ( PARAM1 == 0 as 8 x 8, == 1 as 16 x 16, == 2 as 32 x 32, == 3 as 64 x 64 )
algorithm blittilebitmapwriter(
    // For setting blit1 tile bitmaps
    input   uint5   blit1_writer_tile,
    input   uint4   blit1_writer_line,
    input   uint16  blit1_writer_bitmap,

    // For setting character generator bitmaps
    input   uint8   character_writer_character,
    input   uint3   character_writer_line,
    input   uint8   character_writer_bitmap,

    simple_dualport_bram_port1 blit1tilemap,
    simple_dualport_bram_port1 characterGenerator8x8
) <autorun> {
    blit1tilemap.wenable1 := 1;
    characterGenerator8x8.wenable1 := 1;
    blit1tilemap.addr1 := { blit1_writer_tile, blit1_writer_line };
    blit1tilemap.wdata1 := blit1_writer_bitmap;
    characterGenerator8x8.addr1 := { character_writer_character, character_writer_line };
    characterGenerator8x8.wdata1 := character_writer_bitmap;
}

algorithm blit (
    input   uint1   start,
    output  uint1   busy(0),
    simple_dualport_bram_port0 blit1tilemap,
    simple_dualport_bram_port0 characterGenerator8x8,

    // For setting blit1 tile bitmaps
    input   uint5   blit1_writer_tile,
    input   uint4   blit1_writer_line,
    input   uint16  blit1_writer_bitmap,

    // For setting character generator bitmaps
    input   uint8   character_writer_character,
    input   uint3   character_writer_line,
    input   uint8   character_writer_bitmap,

    input   int10   x,
    input   int10   y,
    input   uint8   param0,
    input   uint2   param1,

    output  int10   bitmap_x_write,
    output  int10   bitmap_y_write,
    output  uint1   bitmap_write,

    input   uint1   tilecharacter
) <autorun> {
    // POSITION IN TILE/CHARACTER
    uint7   gpu_active_x = uninitialized;
    uint7   gpu_active_y = uninitialized;

    // POSITION ON THE SCREEN
    int10   gpu_x1 = uninitialized;
    int10   gpu_y1 = uninitialized;
    uint5   gpu_y2 = uninitialised;

    // MULTIPLIER FOR THE SIZE
    uint2   gpu_param1 = uninitialised;
    uint7   gpu_max_x = uninitialized;
    uint7   gpu_max_y = uninitialized;

    // TILE/CHARACTER TO BLIT
    uint8   gpu_tile = uninitialized;

    // tile and character bitmap addresses
    blit1tilemap.addr0 := { gpu_tile, gpu_active_y[0,4] };
    characterGenerator8x8.addr0 := { gpu_tile, gpu_active_y[0,3] };

    bitmap_x_write := gpu_x1 + gpu_active_x;
    bitmap_y_write := gpu_y1 + ( gpu_active_y << gpu_param1 ) + gpu_y2;
    bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            gpu_active_x = 0;
            gpu_active_y = 0;
            ( gpu_x1, gpu_y1 ) = copycoordinates( x, y );
            gpu_param1 = param1;
            gpu_max_x = ( tilecharacter ? 16 : 8 ) << ( param1 & 3);
            gpu_max_y = tilecharacter ? 16 : 8;
            gpu_tile = param0;
            ++:
            while( gpu_active_y != gpu_max_y ) {
                while( gpu_active_x != gpu_max_x ) {
                    while( gpu_y2 != ( 1 << gpu_param1 ) ) {
                        bitmap_write = tilecharacter ? blit1tilemap.rdata0[15 - ( gpu_active_x >> gpu_param1 ),1] : characterGenerator8x8.rdata0[7 - ( gpu_active_x >> gpu_param1 ),1];
                        gpu_y2 = gpu_y2 + 1;
                    }
                    gpu_active_x = gpu_active_x + 1;
                    gpu_y2 = 0;
                }
                gpu_active_x = 0;
                gpu_active_y = gpu_active_y + 1;
            }
            busy = 0;
        }
    }
}

// COLOURBLIT - OUTPUT PIXELS TO BLIT A 16 x 16 TILE ( PARAM1 == 0 as 16 x 16, == 1 as 32 x 32, == 2 as 64 x 64, == 3 as 128 x 128 )
algorithm colourblittilebitmapwriter(
    // For setting  colourblit tile bitmaps
    input   uint5   colourblit_writer_tile,
    input   uint4   colourblit_writer_line,
    input   uint4   colourblit_writer_pixel,
    input   uint7   colourblit_writer_colour,

    simple_dualport_bram_port1 colourblittilemap,
) <autorun> {
    colourblittilemap.wenable1 := 1;
    colourblittilemap.addr1 := { colourblit_writer_tile, colourblit_writer_line, colourblit_writer_pixel };
    colourblittilemap.wdata1 := colourblit_writer_colour;
}
algorithm colourblit(
    input   uint1   start,
    output  uint1   busy(0),
    simple_dualport_bram_port0 colourblittilemap,

    // For setting blit1 tile bitmaps
    input   uint5   colourblit_writer_tile,
    input   uint4   colourblit_writer_line,
    input   uint4   colourblit_writer_pixel,
    input   uint7   colourblit_writer_colour,
    input   int10   x,
    input   int10   y,
    input   uint8   param0,
    input   uint2   param1,

    output  int10   bitmap_x_write,
    output  int10   bitmap_y_write,
    output  uint7   bitmap_colour_write,
    output  uint1   bitmap_write
) <autorun> {
    // POSITION IN TILE/CHARACTER
    uint7   gpu_active_x = uninitialized;
    uint7   gpu_active_y = uninitialized;

    // POSITION ON THE SCREEN
    int10   gpu_x1 = uninitialized;
    int10   gpu_y1 = uninitialized;
    uint5   gpu_x2 = uninitialised;
    uint5   gpu_y2 = uninitialised;

    // MULTIPLIER FOR THE SIZE
    uint2   gpu_param1 = uninitialised;

    // TILE/CHARACTER TO BLIT
    uint5   gpu_tile = uninitialized;

    // tile and character bitmap addresses
    colourblittilemap.addr0 := { gpu_tile, gpu_active_y[0,4], gpu_active_x[0,4] };

    bitmap_x_write := gpu_x1 + ( gpu_active_x << gpu_param1 ) + gpu_x2;
    bitmap_y_write := gpu_y1 + ( gpu_active_y << gpu_param1 ) + gpu_y2;
    bitmap_colour_write := colourblittilemap.rdata0;
    bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            gpu_active_x = 0;
            gpu_active_y = 0;
            ( gpu_x1, gpu_y1 ) = copycoordinates( x, y );
            ( gpu_tile, gpu_param1 ) = copycoordinates( param0, param1 );
            ++:
            while( gpu_active_y != 16 ) {
                    gpu_y2 = 0;
                    while( gpu_y2 != ( 1 << gpu_param1 ) ) {
                        while( gpu_active_x != 16 ) {
                            gpu_x2 = 0;
                            while( gpu_x2 < ( 1 << gpu_param1 ) ) {
                                // OUTPUT IF NOT TRANSPARENT
                                bitmap_write = ~colourblittilemap.rdata0[6,1];
                                gpu_x2 = gpu_x2 + 1;
                            }
                            gpu_active_x = gpu_active_x + 1;
                        }
                        gpu_y2 = gpu_y2 + 1;
                        gpu_active_x = 0;
                    }
                    gpu_active_y = gpu_active_y + 1;
                }
            busy = 0;
        }
    }
}

// PIXELBLOCK - OUTPUT PIXELS TO RECTANGLE START AT X, Y WITH WIDTH PARAM0, PIXELS PROVIDED SEQUENTIALLY BY CPU, MOVE ALONG RECTANGLE UNTIL STOP RECEIVED
// CAN HANDLE 7bit ( ARRGGBB ) colours, with one defined as transparent or 24bit RGB colours, scaling to the PAWS colour map
algorithm pixelblock(
    input   uint1   start,
    output  uint1   busy(0),

    input   int10   x,
    input   int10   y,
    input   int10   param0,
    input   uint7   param1,

    input   uint7   colour7,
    input   uint8   colour8r,
    input   uint8   colour8g,
    input   uint8   colour8b,
    input   uint2   newpixel,

    output  int10   bitmap_x_write,
    output  int10   bitmap_y_write,
    output  uint7   bitmap_colour_write,
    output  uint1   bitmap_write
) <autorun> {
    uint2   FSM = uninitialised;

    // POSITION ON THE SCREEN
    int10   gpu_max_x = uninitialized;
    int10   gpu_x1 = uninitialized;
    int10   gpu_x = uninitialised;
    int10   gpu_y = uninitialised;
    uint7   ignorecolour = uninitialised;

    bitmap_x_write := gpu_x;
    bitmap_y_write := gpu_y;
    bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;

            gpu_x = x; gpu_x1 = x; gpu_y = y; gpu_max_x = x + param0;
            ignorecolour = param1;
            while( busy ) {
                switch( newpixel ) {
                    case 0: {}
                    case 1: { bitmap_colour_write = colour7; bitmap_write = ( colour7 != ignorecolour ); }
                    case 2: { bitmap_colour_write = { 1b0, colour8r[6,2], colour8g[6,2], colour8b[6,2] }; bitmap_write = 1; }
                    case 3: { busy = 0; }
                }
                switch( gpu_x != gpu_max_x ) {
                    case 1: { gpu_x = gpu_x + ( newpixel != 0 ); }
                    case 0: { gpu_x = gpu_x1; gpu_y = gpu_y + 1; }
                }
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

// ADJUST COORDINATES BY DELTAS AND SCALE
circuitry deltacoordinates( input x, input dx, input y, input dy, input scale, output xdx, output ydy ) {
    xdx = x + ( scale[2,1] ? ( __signed(dx) >>> scale[0,2] ) : ( dx << scale[0,2] ) );
    ydy = y + ( scale[2,1] ? ( __signed(dy) >>> scale[0,2] ) : ( dy << scale[0,2] ) );
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
    vertex.addr1 := { vertices_writer_block, vertices_writer_vertex };
    vertex.wdata1 := { vertices_writer_active, __unsigned(vertices_writer_xdelta), __unsigned(vertices_writer_ydelta) };
}
algorithm vectors(
    simple_dualport_bram_port0 vertex,
    input   uint5   vector_block_number,
    input   int10   vector_block_xc,
    input   int10   vector_block_yc,
    input   uint3   vector_block_scale,
    input   uint1   draw_vector,
    output  uint1   vector_block_active(0),

    // Communication with the GPU
    output  int10   gpu_x,
    output  int10   gpu_y,
    output  int10   gpu_param0,
    output  int10   gpu_param1,
    output  uint1   gpu_write,
    input   uint1   gpu_active
) <autorun> {
    // Extract deltax and deltay for the present vertices
    int10 deltax := { {5{vectorentry(vertex.rdata0).dxsign}}, vectorentry(vertex.rdata0).dx };
    int10 deltay := { {5{vectorentry(vertex.rdata0).dysign}}, vectorentry(vertex.rdata0).dy };

    // Vertices being processed, plus first coordinate of each line
    uint5 block_number = 0;
    uint5 vertices_number = 0;
    int10 start_x = uninitialised;
    int10 start_y = uninitialised;

    // Set read address for the vertices
    vertex.addr0 := { block_number, vertices_number };

    gpu_write := 0;

    while(1) {
        if( draw_vector ) {
            vector_block_active = 1;
            block_number = vector_block_number;
            vertices_number = 0;
            ++:
            ( start_x, start_y ) = deltacoordinates( vector_block_xc, deltax, vector_block_yc, deltay, vector_block_scale );
            vertices_number = 1;
            ++:
            while( vectorentry(vertex.rdata0).active && ( vertices_number != 16 ) ) {
                // Dispatch line to GPU
                ( gpu_x, gpu_y ) = copycoordinates( start_x, start_y );
                ( gpu_param0, gpu_param1 ) = deltacoordinates( vector_block_xc, deltax, vector_block_yc, deltay, vector_block_scale );
                ++:
                while( gpu_active ) {} gpu_write = 1;
                ++:
                // Move onto the next of the vertices
                ( start_x, start_y ) = copycoordinates( gpu_param0, gpu_param1 );
                vertices_number = vertices_number + 1;
            }
            vector_block_active = 0;
        }
    }
}
