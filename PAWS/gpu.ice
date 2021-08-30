algorithm gpu_queue(
    output int16   bitmap_x_write,
    output int16   bitmap_y_write,
    output uint7   bitmap_colour_write,
    output uint7   bitmap_colour_write_alt,
    output uint1   bitmap_write,
    output uint4   gpu_active_dithermode,

    input   uint9   crop_left,
    input   uint9   crop_right,
    input   uint8   crop_top,
    input   uint8   crop_bottom,

    input   int16   gpu_x,
    input   int16   gpu_y,
    input   uint7   gpu_colour,
    input   uint7   gpu_colour_alt,
    input   int16   gpu_param0,
    input   int16   gpu_param1,
    input   int16   gpu_param2,
    input   int16   gpu_param3,
    input   int16   gpu_param4,
    input   int16   gpu_param5,
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
    input   int16   vector_block_xc,
    input   int16   vector_block_yc,
    input   uint3   vector_block_scale,
    input   uint3   vector_block_action,
    input   uint1   draw_vector,
    input   uint5   vertices_writer_block,
    input   uint6   vertices_writer_vertex,
    input   int6    vertices_writer_xdelta,
    input   int6    vertices_writer_ydelta,
    input   uint1   vertices_writer_active,

    output  uint1   queue_full(0),
    output  uint1   queue_complete(1),
    output  uint1   vector_block_active(0)
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
        vector_block_action <: vector_block_action,
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

    int16   x = uninitialised;
    int16   y = uninitialised;
    uint7   colour = uninitialised;
    uint7   colour_alt = uninitialised;
    int16   param0 = uninitialised;
    int16   param1 = uninitialised;
    int16   param2 = uninitialised;
    int16   param3 = uninitialised;
    int16   param4 = uninitialised;
    int16   param5 = uninitialised;
    uint4   dithermode = uninitialised;
    uint1   gpu_active = uninitialised;
    uint4   write = uninitialised;
    gpu GPU(
        crop_left <: crop_left,
        crop_right <: crop_right,
        crop_top <: crop_top,
        crop_bottom <: crop_bottom,
        gpu_x <: x,
        gpu_y <: y,
        gpu_colour <: colour,
        gpu_colour_alt <: colour_alt,
        gpu_param0 <: param0,
        gpu_param1 <: param1,
        gpu_param2 <: param2,
        gpu_param3 <: param3,
        gpu_dithermode <: dithermode,
        gpu_write <: write,
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
    uint1   queue_busy = 0;
    int16   queue_x = uninitialised;
    int16   queue_y = uninitialised;
    uint7   queue_colour = uninitialised;
    uint7   queue_colour_alt = uninitialised;
    int16   queue_param0 = uninitialised;
    int16   queue_param1 = uninitialised;
    int16   queue_param2 = uninitialised;
    int16   queue_param3 = uninitialised;
    int16   queue_param4 = uninitialised;
    int16   queue_param5 = uninitialised;
    uint4   queue_dithermode = uninitialised;
    uint4   queue_write = uninitialised;
    write := 0; queue_full := vector_block_active | queue_busy ; queue_complete := ~( gpu_active | queue_full );

    while(1) {
        switch( gpu_write ) {
            case 0: {
                if( vector_drawer.gpu_write ) {
                    x = vector_drawer.gpu_x;
                    y = vector_drawer.gpu_y;
                    colour = vector_block_colour;
                    colour_alt = 0;
                    param0 = vector_drawer.gpu_param0;
                    param1 = vector_drawer.gpu_param1;
                    param2 = 1;
                    param3 = 0;
                    dithermode = 0;
                    write = 2;
                }
            }
            default: {
                queue_busy = 1;
                queue_x = gpu_x;
                queue_y = gpu_y;
                queue_colour = gpu_colour;
                queue_colour_alt = gpu_colour_alt;
                queue_param0 = gpu_param0;
                queue_param1 = gpu_param1;
                queue_param2 = gpu_param2;
                queue_param3 = gpu_param3;
                queue_dithermode = gpu_dithermode;
                queue_write = gpu_write;
                while( gpu_active ) {}
                x = queue_x;
                y = queue_y;
                colour = queue_colour;
                colour_alt = queue_colour_alt;
                param0 = queue_param0;
                param1 = queue_param1;
                param2 = queue_param2;
                param3 = queue_param3;
                dithermode = queue_dithermode;
                write = queue_write;
                queue_busy = 0;
            }
            case 15: {
                queue_busy = 1;
                queue_x = gpu_x;
                queue_y = gpu_y;
                queue_colour = gpu_colour;
                queue_colour_alt = gpu_colour_alt;
                queue_param0 = gpu_param0;
                queue_param1 = gpu_param1;
                queue_param2 = gpu_param2;
                queue_param3 = gpu_param3;
                queue_param4 = gpu_param4;
                queue_param5 = gpu_param5;
                queue_dithermode = gpu_dithermode;
                // QUADRILATERAL BY SPLITTING INTO 2 TRIANGLES
                while( gpu_active ) {}
                x = queue_x;
                y = queue_y;
                colour = queue_colour;
                colour_alt = queue_colour_alt;
                param0 = queue_param0;
                param1 = queue_param1;
                param2 = queue_param2;
                param3 = queue_param3;
                dithermode = queue_dithermode;
                dithermode = gpu_dithermode;
                write = 6; while( gpu_active ) {}
                param0 = queue_param4; param1 = queue_param5;
                write = 6;
                queue_busy = 0;
            }
        }
    }
}

algorithm gpu(
    simple_dualport_bram_port0 blit1tilemap,
    simple_dualport_bram_port0 characterGenerator8x8,
    simple_dualport_bram_port0 colourblittilemap,

    // GPU to SET and GET pixels
    output int16   bitmap_x_write,
    output int16   bitmap_y_write,
    output uint7   bitmap_colour_write,
    output uint7   bitmap_colour_write_alt,
    output uint1   bitmap_write,
    output uint4   gpu_active_dithermode,

    input   uint9   crop_left,
    input   uint9   crop_right,
    input   uint8   crop_top,
    input   uint8   crop_bottom,

    input   int16   gpu_x,
    input   int16   gpu_y,
    input   uint7   gpu_colour,
    input   uint7   gpu_colour_alt,
    input   int16   gpu_param0,
    input   int16   gpu_param1,
    input   int16   gpu_param2,
    input   int16   gpu_param3,
    input   int16   gpu_param4,
    input   int16   gpu_param5,
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
    uint7   gpu_busy_flags <:: { GPUpixelblockbusy, GPUcolourblitbusy, GPUblitbusy, GPUtrianglebusy, GPUcirclebusy, GPUrectanglebusy, GPUlinebusy };

    uint1   GPUrectanglestart = uninitialised;
    uint1   GPUrectanglebusy = uninitialised;
    int16   GPUrectanglebitmap_x_write = uninitialised;
    int16   GPUrectanglebitmap_y_write = uninitialised;
    uint1   GPUrectanglebitmap_write = uninitialised;
    rectangle GPUrectangle(
        crop_left <: crop_left,
        crop_right <: crop_right,
        crop_top <: crop_top,
        crop_bottom <: crop_bottom,
        x <: gpu_x,
        y <: gpu_y,
        param0 <: gpu_param0,
        param1 <: gpu_param1,
        start <: GPUrectanglestart,
        busy :> GPUrectanglebusy,
        bitmap_x_write :> GPUrectanglebitmap_x_write,
        bitmap_y_write :> GPUrectanglebitmap_y_write,
        bitmap_write :> GPUrectanglebitmap_write
    );
    uint1   GPUlinestart = uninitialised;
    uint1   GPUlinebusy = uninitialised;
    int16   GPUlinebitmap_x_write = uninitialised;
    int16   GPUlinebitmap_y_write = uninitialised;
    uint1   GPUlinebitmap_write = uninitialised;
    line GPUline(
        x <: gpu_x,
        y <: gpu_y,
        param0 <: gpu_param0,
        param1 <: gpu_param1,
        param2 <: gpu_param2,
        start <: GPUlinestart,
        busy :> GPUlinebusy,
        bitmap_x_write :> GPUlinebitmap_x_write,
        bitmap_y_write :> GPUlinebitmap_y_write,
        bitmap_write :> GPUlinebitmap_write
    );
    uint1   GPUcirclestart = uninitialised;
    uint1   GPUcirclebusy = uninitialised;
    int16   GPUcirclebitmap_x_write = uninitialised;
    int16   GPUcirclebitmap_y_write = uninitialised;
    uint1   GPUcirclebitmap_write = uninitialised;
    uint1   GPUcirclefilledcircle = uninitialised;
    circle GPUcircle(
        x <: gpu_x,
        y <: gpu_y,
        param0 <: gpu_param0,
        param1 <: gpu_param1,
        start <: GPUcirclestart,
        busy :> GPUcirclebusy,
        bitmap_x_write :> GPUcirclebitmap_x_write,
        bitmap_y_write :> GPUcirclebitmap_y_write,
        bitmap_write :> GPUcirclebitmap_write,
        filledcircle <: GPUcirclefilledcircle
    );
    uint1   GPUtrianglestart = uninitialised;
    uint1   GPUtrianglebusy = uninitialised;
    int16   GPUtrianglebitmap_x_write = uninitialised;
    int16   GPUtrianglebitmap_y_write = uninitialised;
    uint1   GPUtrianglebitmap_write = uninitialised;
    triangle GPUtriangle(
        crop_left <: crop_left,
        crop_right <: crop_right,
        crop_top <: crop_top,
        crop_bottom <: crop_bottom,
        x <: gpu_x,
        y <: gpu_y,
        param0 <: gpu_param0,
        param1 <: gpu_param1,
        param2 <: gpu_param2,
        param3 <: gpu_param3,
        start <: GPUtrianglestart,
        busy :> GPUtrianglebusy,
        bitmap_x_write :> GPUtrianglebitmap_x_write,
        bitmap_y_write :> GPUtrianglebitmap_y_write,
        bitmap_write :> GPUtrianglebitmap_write
    );
    uint1   GPUblitstart = uninitialised;
    uint1   GPUblitbusy = uninitialised;
    int16   GPUblitbitmap_x_write = uninitialised;
    int16   GPUblitbitmap_y_write = uninitialised;
    uint1   GPUblitbitmap_write = uninitialised;
    uint1   GPUblittilecharacter = uninitialised;
    blit GPUblit(
        blit1tilemap <:> blit1tilemap,
        characterGenerator8x8 <:> characterGenerator8x8,
        x <: gpu_x,
        y <: gpu_y,
        param0 <: gpu_param0,
        param1 <: gpu_param1,
        param2 <: gpu_param2,
        start <: GPUblitstart,
        busy :> GPUblitbusy,
        bitmap_x_write :> GPUblitbitmap_x_write,
        bitmap_y_write :> GPUblitbitmap_y_write,
        bitmap_write :> GPUblitbitmap_write,
        tilecharacter <: GPUblittilecharacter
    );
    uint1   GPUcolourblitstart = uninitialised;
    uint1   GPUcolourblitbusy = uninitialised;
    int16   GPUcolourblitbitmap_x_write = uninitialised;
    int16   GPUcolourblitbitmap_y_write = uninitialised;
    uint1   GPUcolourblitbitmap_write = uninitialised;
    uint7   GPUcolourblitbitmap_colour_write = uninitialised;
    colourblit GPUcolourblit(
        colourblittilemap <:> colourblittilemap,
        x <: gpu_x,
        y <: gpu_y,
        param0 <: gpu_param0,
        param1 <: gpu_param1,
        param2 <: gpu_param2,
        start <: GPUcolourblitstart,
        busy :> GPUcolourblitbusy,
        bitmap_x_write :> GPUcolourblitbitmap_x_write,
        bitmap_y_write :> GPUcolourblitbitmap_y_write,
        bitmap_write :> GPUcolourblitbitmap_write,
        bitmap_colour_write :> GPUcolourblitbitmap_colour_write
    );
    uint1   GPUpixelblockstart = uninitialised;
    uint1   GPUpixelblockbusy = uninitialised;
    int16   GPUpixelblockbitmap_x_write = uninitialised;
    int16   GPUpixelblockbitmap_y_write = uninitialised;
    uint1   GPUpixelblockbitmap_write = uninitialised;
    uint7   GPUpixelblockbitmap_colour_write = uninitialised;
    pixelblock GPUpixelblock(
        x <: gpu_x,
        y <: gpu_y,
        param0 <: gpu_param0,
        param1 <: gpu_param1,
        colour7 <: pb_colour7,
        colour8r <: pb_colour8r,
        colour8g <: pb_colour8g,
        colour8b <: pb_colour8b,
        newpixel <: pb_newpixel,
        start <: GPUpixelblockstart,
        busy :> GPUpixelblockbusy,
        bitmap_x_write :> GPUpixelblockbitmap_x_write,
        bitmap_y_write :> GPUpixelblockbitmap_y_write,
        bitmap_write :> GPUpixelblockbitmap_write,
        bitmap_colour_write :> GPUpixelblockbitmap_colour_write
    );

    // CONTROLS FOR BITMAP PIXEL WRITER
    bitmap_write := 0; bitmap_colour_write := gpu_active_colour; bitmap_colour_write_alt := gpu_active_colour_alt;

    // CONTROLS FOR GPU SUBUNITS
    GPUrectanglestart := 0; GPUlinestart := 0; GPUcirclestart := 0; GPUtrianglestart := 0; GPUblitstart := 0; GPUcolourblitstart := 0; GPUpixelblockstart := 0;

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
                    case 2: { gpu_active_dithermode = 0; GPUlinestart = 1; } // DRAW LINE FROM (X,Y) to (PARAM0,PARAM1)
                    case 3: { gpu_active_dithermode = gpu_dithermode; GPUrectanglestart = 1; } // DRAW RECTANGLE FROM (X,Y) to (PARAM0,PARAM1)
                    case 4: { gpu_active_dithermode = 0; GPUcirclefilledcircle = 0; GPUcirclestart = 1; } // DRAW CIRCLE CENTRE (X,Y) with RADIUS PARAM0
                    case 5: { gpu_active_dithermode = gpu_dithermode; GPUcirclefilledcircle = 1; GPUcirclestart = 1; } // DRAW FILLED CIRCLE CENTRE (X,Y) with RADIUS PARAM0
                    case 6: { gpu_active_dithermode = gpu_dithermode; GPUtrianglestart = 1; } // DRAW FILLED TRIANGLE WITH VERTICES (X,Y) (PARAM0,PARAM1) (PARAM2,PARAM3)
                    case 7: { gpu_active_dithermode = 0; GPUblittilecharacter = 1; GPUblitstart = 1; } // BLIT 16 x 16 TILE PARAM0 TO (X,Y)
                    case 8: { gpu_active_dithermode = 0; GPUblittilecharacter = 0; GPUblitstart = 1; } // BLIT 8 x 8 CHARACTER PARAM0 TO (X,Y) as 8 x 8
                    case 9: { gpu_active_dithermode = 0; GPUcolourblitstart = 1; } // BLIT 16 x 16 COLOUR TILE PARAM0 TO (X,Y) as 16 x 16
                    case 10: { gpu_active_dithermode = 0; GPUpixelblockstart = 1; } // START THE PIXELBLOCK WRITER AT (x,y) WITH WIDTH PARAM0, IGNORE COLOUR PARAM1
                }
                while( gpu_busy_flags != 0 ) {
                    onehot( gpu_busy_flags ) {
                        case 0: { bitmap_x_write = GPUlinebitmap_x_write; bitmap_y_write = GPUlinebitmap_y_write; }
                        case 1: { bitmap_x_write = GPUrectanglebitmap_x_write; bitmap_y_write = GPUrectanglebitmap_y_write; }
                        case 2: { bitmap_x_write = GPUcirclebitmap_x_write; bitmap_y_write = GPUcirclebitmap_y_write; }
                        case 3: { bitmap_x_write = GPUtrianglebitmap_x_write; bitmap_y_write = GPUtrianglebitmap_y_write; }
                        case 4: { bitmap_x_write = GPUblitbitmap_x_write; bitmap_y_write = GPUblitbitmap_y_write; }
                        case 5: { bitmap_x_write = GPUcolourblitbitmap_x_write; bitmap_y_write = GPUcolourblitbitmap_y_write; bitmap_colour_write = GPUcolourblitbitmap_colour_write; }
                        case 6: { bitmap_x_write = GPUpixelblockbitmap_x_write; bitmap_y_write = GPUpixelblockbitmap_y_write; bitmap_colour_write = GPUpixelblockbitmap_colour_write; }
                    }
                    bitmap_write = GPUlinebitmap_write | GPUrectanglebitmap_write | GPUcirclebitmap_write |
                                    GPUtrianglebitmap_write | GPUblitbitmap_write | GPUcolourblitbitmap_write | GPUpixelblockbitmap_write;
                }
                gpu_active = 0;
            }
        }
    }
}

// CROP TO CROPPING RECTANGLE
// ASSUMES POINTS ARE TOPLEFT (x1,y1) AND BOTTOMRIGHT (x2,y2)
algorithm performcrop(
    input   int16   crop_left,
    input   int16   crop_right,
    input   int16   crop_top,
    input   int16   crop_bottom,
    input   int16   x1,
    input   int16   y1,
    input   int16   x2,
    input   int16   y2,
    output  uint9   min_x,
    output  uint8   min_y,
    output  uint9   max_x,
    output  uint8   max_y,
) <autorun> {
    always {
        min_x = ( x1 < crop_left ) ? crop_left : x1;
        min_y = ( y1 < crop_top ) ? crop_top : y1;
        max_x = ( x2 > crop_right ) ? crop_right : x2;
        max_y = ( y2 > crop_bottom ) ? crop_bottom : y2;
    }
}

// DETERMINE IF ANYTHING TO DRAW
// ASSUMES POINTS ARE TOPLEFT (x1,y1) AND BOTTOMRIGHT (x2,y2)
algorithm   isinrange(
    input   int16   crop_left,
    input   int16   crop_right,
    input   int16   crop_top,
    input   int16   crop_bottom,
    input   int16   x1,
    input   int16   y1,
    input   int16   x2,
    input   int16   y2,
    output  uint1   todraw
) <autorun> {
    always {
        todraw = ~( ( x2 < crop_left ) || ( y2 < crop_top ) || ( x1 > crop_right ) || ( y1 > crop_bottom ) );
    }
}

// RECTANGLE - OUTPUT PIXELS TO DRAW A RECTANGLE
algorithm preprectangle(
    input   int16   crop_left,
    input   int16   crop_right,
    input   int16   crop_top,
    input   int16   crop_bottom,
    input   int16   x,
    input   int16   y,
    input   int16   param0,
    input   int16   param1,
    output  uint9   min_x,
    output  uint8   min_y,
    output  uint9   max_x,
    output  uint8   max_y,
    output  uint1   todraw
) {
    int16   x1 = uninitialized; int16   y1 = uninitialized; int16   x2 = uninitialized; int16   y2 = uninitialized;
    performcrop CROP(
        crop_left <: crop_left,
        crop_right <: crop_right,
        crop_top <: crop_top,
        crop_bottom <: crop_bottom,
        x1 <: x1,
        y1 <: y1,
        x2 <: x2,
        y2 <: y2,
        min_x :> min_x,
        min_y :> min_y,
        max_x :> max_x,
        max_y :> max_y
    );
    isinrange TODRAW(
        crop_left <: crop_left,
        crop_right <: crop_right,
        crop_top <: crop_top,
        crop_bottom <: crop_bottom,
        x1 <: x1,
        y1 <: y1,
        x2 <: x2,
        y2 <: y2,
        todraw :> todraw
    );
    ( x1 ) = min( x, param0 ); ( y1 ) = min( y, param1 ); ( x2 ) = max( x, param0 ); ( y2 ) = max( y, param1 );
    ++:
}
algorithm drawrectangle(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint9   min_x,
    input   uint8   min_y,
    input   uint9   max_x,
    input   uint8   max_y,
    output  int16   bitmap_x_write,
    output  int16   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    uint9   x = uninitialized; uint8   y = uninitialized;
    bitmap_x_write := x; bitmap_y_write := y; bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            x = min_x; y = min_y;
            while( y <= max_y ) { while( x <= max_x ) { bitmap_write = 1; x = x + 1; } x = min_x; y = y + 1; }
            busy = 0;
        }
    }
}
algorithm rectangle (
    input   uint1   start,
    output  uint1   busy(0),
    input   int16   crop_left,
    input   int16   crop_right,
    input   int16   crop_top,
    input   int16   crop_bottom,
    input   int16   x,
    input   int16   y,
    input   int16   param0,
    input   int16   param1,

    output  int16   bitmap_x_write,
    output  int16   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    uint9   min_x = uninitialized;
    uint8   min_y = uninitialized;
    uint9   max_x = uninitialized;
    uint8   max_y = uninitialized;
    uint1   todraw = uninitialized;
    preprectangle PREP(
        crop_left <: crop_left,
        crop_right <: crop_right,
        crop_top <: crop_top,
        crop_bottom <: crop_bottom,
        x <: x,
        y <: y,
        param0 <: param0,
        param1 <: param1,
        min_x :> min_x,
        min_y :> min_y,
        max_x :> max_x,
        max_y :> max_y,
        todraw :> todraw
    );

    uint1   RECTANGLEstart = uninitialized;
    uint1   RECTANGLEbusy = uninitialized;
    drawrectangle RECTANGLE(
        min_x <: min_x,
        min_y <: min_y,
        max_x <: max_x,
        max_y <: max_y,
        bitmap_x_write :> bitmap_x_write,
        bitmap_y_write :> bitmap_y_write,
        bitmap_write :> bitmap_write,
        start <: RECTANGLEstart,
        busy :> RECTANGLEbusy
    );

    RECTANGLEstart := 0;
    while(1) {
        if( start ) {
            busy = 1;
            () <- PREP <- ();
            RECTANGLEstart = todraw; while( RECTANGLEbusy ) {}
            busy = 0;
        }
    }
}

// LINE - OUTPUT PIXELS TO DRAW A LINE
algorithm prepline(
    input   int16   x,
    input   int16   y,
    input   int16   param0,
    input   int16   param1,
    input   int16   param2,
    output  int16   x1,
    output  int16   y1,
    output  int16   dx,
    output  int16   dy,
    output  uint1   dv,
    output  int16   numerator,
    output  int16   max_count,
    output  uint8   width
) {
    // Setup drawing a line from x,y to param0,param1 of width param2 in colour
    // Ensure LEFT to RIGHT
    ( x1 ) = min( x, param0 );
    y1 = ( x < param0 ) ? y : param1;

    // Determine if moving UP or DOWN
    dv = ( x < param0 ) ? ( y < param1 ) : ~( y < param1 );

    // Absolute DELTAs
    ( dx ) = absdelta( x, param0 );
    ( dy ) = absdelta( y, param1 );
    ( width ) = abs( param2 );

    // Numerator
    numerator = ( dx > dy ) ? ( dx >> 1 ) : -( dy >> 1 );
    ( max_count ) = max( dx, dy );
}
algorithm drawline(
    input   uint1   start,
    output  uint1   busy(0),
    input   int16   start_x,
    input   int16   start_y,
    input   int16   start_numerator,
    input   int16   dx,
    input   int16   dy,
    input   uint1   dv,
    input   int16   max_count,
    input   uint8   width,
    output  int16   bitmap_x_write,
    output  int16   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    int16   x = uninitialized;
    int16   y = uninitialized;
    int16   numerator = uninitialized;
    int16   numerator2 <:: numerator;
    uint1   n2dx <:: numerator2 > (-dx);
    uint1   n2dy <:: numerator2 < dy;
    uint1   dxdy <:: dx > dy;
    int16   newnumerator <:: numerator - ( n2dx ? dy : 0 ) + ( n2dy ? dx : 0 );
    int16   count = uninitialized;
    int16   offset_x = uninitialised;
    int16   offset_y = uninitialised;
    int16   offset_start <:: -( width >> 1 );
    uint8   pixel_count = uninitialised;

    bitmap_x_write := x + offset_x; bitmap_y_write := y + offset_y; bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            x = start_x; y = start_y; numerator = start_numerator; count = 0; offset_x = 0; offset_y = 0;
            while( count <= max_count ) {
                // OUTPUT PIXELS
                if( width == 1 ) {
                    // SINGLE PIXEL
                    bitmap_write = 1;
                } else {
                    // MULTIPLE WIDTH PIXELS
                    offset_y = dxdy ? offset_start : 0; offset_x = dxdy ? 0 : offset_start;
                    // DRAW WIDTH PIXELS
                    pixel_count = 0;
                    while( pixel_count != width ) {
                        bitmap_write = 1;
                        offset_y = offset_y + dxdy; offset_x = offset_x + ~dxdy;
                        pixel_count = pixel_count + 1;
                    }
                }
                numerator = newnumerator;
                x = x + n2dx; y = n2dy ? (y + ( dv ? 1 : -1 )) : y;
                count = count + 1;
            }
            busy = 0;
        }
    }
}
algorithm line (
    input   uint1   start,
    output  uint1   busy(0),
    input   int16   x,
    input   int16   y,
    input   int16   param0,
    input   int16   param1,
    input   int16   param2,
    output  int16   bitmap_x_write,
    output  int16   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    int16   x1 = uninitialized;
    int16   y1 = uninitialized;
    int16   dx = uninitialized;
    int16   dy = uninitialized;
    uint1   dv = uninitialized;
    int16   numerator = uninitialized;
    int16   max_count = uninitialized;
    uint8   width = uninitialised;
    prepline PREP(
        x <: x,
        y <: y,
        param0 <: param0,
        param1 <: param1,
        param2 <: param2,
        x1 :> x1,
        y1 :> y1,
        dx :> dx,
        dy :> dy,
        dv :> dv,
        numerator :> numerator,
        max_count :> max_count,
        width :> width
    );
    uint1   LINEstart = uninitialised;
    uint1   LINEbusy = uninitialised;
    drawline LINE(
        start_x <: x1,
        start_y <: y1,
        start_numerator <: numerator,
        dx <: dx,
        dy <: dy,
        dv <: dv,
        max_count <: max_count,
        width <: width,
        bitmap_x_write :> bitmap_x_write,
        bitmap_y_write :> bitmap_y_write,
        bitmap_write :> bitmap_write,
        start <: LINEstart,
        busy :> LINEbusy
    );
    LINEstart := 0;

    while(1) {
        if( start ) {
            busy = 1;
            () <- PREP <- ();
            LINEstart = 1; while( LINEbusy ) {}
            busy = 0;
        }
    }
}

//  CIRCLE - OUTPUT PIXELS TO DRAW AN OUTLINE OR FILLED CIRCLE
// UPDATE THE NUMERATOR FOR THE CIRCLE BEING DRAWN
algorithm prepcircle(
    input   int16   x,
    input   int16   y,
    input   int16   param0,
    input   int16   param1,
    output  int16   gpu_xc,
    output  int16   gpu_yc,
    output  int16   radius,
    output  int16   gpu_numerator,
    output  uint8   draw_sectors
) {
    // Setup drawing a circle centre x,y or radius param0 in colour
    ( radius ) = abs( param0 );
    ( gpu_xc, gpu_yc ) = copycoordinates( x, y );
    gpu_numerator = 3 - ( { radius, 1b0 } );

    // SHUFFLE SECTOR MAP TO LOGICALLY GO CLOCKWISE AROUND THE CIRCLE
    draw_sectors = { param1[5,1], param1[6,1], param1[1,1], param1[2,1], param1[4,1], param1[7,1], param1[0,1], param1[3,1] };
}
algorithm updatecirclenumerator(
    input   int16   gpu_numerator,
    input   int16   gpu_active_x,
    input   int16   gpu_active_y,
    output  int16   new_numerator
) <autorun> {
    always {
        if( gpu_numerator[9,1] ) {
            new_numerator = gpu_numerator + { gpu_active_x, 2b00 } + 6;
        } else {
            new_numerator = gpu_numerator + { (gpu_active_x - gpu_active_y), 2b00 } + 10;
        }
    }
}
algorithm drawcircle(
    input   uint1   start,
    output  uint1   busy(0),
    input   int16   xc,
    input   int16   yc,
    input   int16   radius,
    input   int16   start_numerator,
    input   uint8   draw_sectors,
    input   uint1   filledcircle,
    output  int16   bitmap_x_write,
    output  int16   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    int16   new_numerator = uninitialised;
    updatecirclenumerator UN(
        gpu_numerator <: numerator,
        gpu_active_x <: active_x,
        gpu_active_y <: active_y,
        new_numerator :> new_numerator
    );

    uint8   PIXELOUTPUT = uninitialised;
    uint8   PIXELMASK <:: PIXELOUTPUT;
    int16   active_x = uninitialized;
    int16   active_y = uninitialized;
    int16   count = uninitialised;
    int16   min_count = uninitialised;
    int16   numerator = uninitialised;

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
                numerator = new_numerator;
            }
            busy = 0;
        }
    }
}
algorithm circle(
    input   uint1   start,
    output  uint1   busy(0),
    input   int16   x,
    input   int16   y,
    input   int16   param0,
    input   uint8   param1,
    input   uint1   filledcircle,

    output  int16  bitmap_x_write,
    output  int16  bitmap_y_write,
    output  uint1  bitmap_write
) <autorun> {
    int16   radius = uninitialized;
    int16   gpu_xc = uninitialized;
    int16   gpu_yc = uninitialized;
    int16   gpu_numerator = uninitialized;
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
    uint1   CIRCLEstart = uninitialised;
    uint1   CIRCLEbusy = uninitialised;
    drawcircle CIRCLE(
        xc <: gpu_xc,
        yc <: gpu_yc,
        radius <: radius,
        start_numerator <: gpu_numerator,
        draw_sectors <: draw_sectors,
        filledcircle <: filledcircle,
        bitmap_x_write :> bitmap_x_write,
        bitmap_y_write :> bitmap_y_write,
        bitmap_write :> bitmap_write,
        start <: CIRCLEstart,
        busy :> CIRCLEbusy
    );
    CIRCLEstart := 0;

    while(1) {
        if( start ) {
            busy = 1;
            () <- PREP <- ();
            CIRCLEstart = 1; while( CIRCLEbusy ) {}
            busy = 0;
        }
    }
}

// TRIANGLE - OUTPUT PIXELS TO DRAW A FILLED TRIANGLE
// CALCULATE IF A PIXEL IS INSIDE THE TRIANGLE BEING DRAWN
algorithm preptriangle(
    input   int16   crop_left,
    input   int16   crop_right,
    input   int16   crop_top,
    input   int16   crop_bottom,
    input   int16   x,
    input   int16   y,
    input   int16   param0,
    input   int16   param1,
    input   int16   param2,
    input   int16   param3,
    output  int16   x1,
    output  int16   y1,
    output  int16   x2,
    output  int16   y2,
    output  int16   x3,
    output  int16   y3,
    output  int16   min_x,
    output  int16   min_y,
    output  int16   max_x,
    output  int16   max_y,
    output  uint1   todraw
) {
    int16   mx1 = uninitialized; int16   my1 = uninitialized; int16   mx2 = uninitialized; int16   my2 = uninitialized;
    performcrop CROP(
        crop_left <: crop_left,
        crop_right <: crop_right,
        crop_top <: crop_top,
        crop_bottom <: crop_bottom,
        x1 <: mx1,
        y1 <: my1,
        x2 <: mx2,
        y2 <: my2,
        min_x :> min_x,
        min_y :> min_y,
        max_x :> max_x,
        max_y :> max_y
    );
    isinrange TODRAW(
        crop_left <: crop_left,
        crop_right <: crop_right,
        crop_top <: crop_top,
        crop_bottom <: crop_bottom,
        x1 <: mx1,
        y1 <: my1,
        x2 <: mx2,
        y2 <: my2,
        todraw :> todraw
    );
    // Setup drawing a filled triangle x,y param0, param1, param2, param3
    ( x1, y1 ) = copycoordinates( x, y);
    ( x2, y2 ) = copycoordinates( param0, param1 );
    ( x3, y3 ) = copycoordinates( param2, param3 );
    // Find minimum and maximum of x, x1, x2, y, y1 and y2 for the bounding box
    ( mx1 ) = min3( x1, x2, x3 );
    ( my1 ) = min3( y1, y2, y3 );
    ( mx2 ) = max3( x1, x2, x3 );
    ( my2 ) = max3( y1, y2, y3 );
    ++:
    // Put points in order so that ( x1, y1 ) is at top, then ( x2, y2 ) and ( x3, y3 ) are clockwise from there
    if( y3 < y2 ) { ( x2, y2, x3, y3 ) = swapcoordinates( x2, y2, x3, y3 ); }
    if( y2 < y1 ) { ( x1, y1, x2, y2 ) = swapcoordinates( x1, y1, x2, y2 ); }
    if( y3 < y1 ) { ( x1, y1, x3, y3 ) = swapcoordinates( x1, y1, x3, y3 ); }
    if( y3 < y2 ) { ( x2, y2, x3, y3 ) = swapcoordinates( x2, y2, x3, y3 ); }
    if( ( y2 == y1 ) && ( x2 < x1 ) ) { ( x1, y1, x2, y2 ) = swapcoordinates( x1, y1, x2, y2 ); }
    if( ( y2 != y1 ) && ( y3 >= y2 ) && ( x2 < x3 ) ) { ( x2, y2, x3, y3 ) = swapcoordinates( x2, y2, x3, y3 ); }
}
algorithm insideTriangle(
    input   int16   px,
    input   int16   py,
    input   int16   x,
    input   int16   y,
    input   int16   x1,
    input   int16   y1,
    input   int16   x2,
    input   int16   y2,
    output  uint1   inside
) <autorun> {
    always {
        inside = ( (( x2 - x1 ) * ( py - y1 ) - ( y2 - y1 ) * ( px - x1 )) >= 0 ) &
                    ( (( x - x2 ) * ( py - y2 ) - ( y - y2 ) * ( px - x2 )) >= 0 ) &
                    ( (( x1 - x ) * ( py - y ) - ( y1 - y ) * ( px - x )) >= 0 );
    }
}
algorithm drawtriangle(
    input   uint1   start,
    output  uint1   busy(0),
    input   int16   min_x,
    input   int16   min_y,
    input   int16   max_x,
    input   int16   max_y,
    input   int16   x0,
    input   int16   y0,
    input   int16   x1,
    input   int16   y1,
    input   int16   x2,
    input   int16   y2,
    output  int16   bitmap_x_write,
    output  int16   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    // Filled triangle calculations
    // Is the point px,py inside the triangle given by active_x,active_y x1,y1 x2,y2?
    uint1   inTriangle = uninitialized;
    uint1   beenInTriangle = uninitialized;
    uint1   EXIT = uninitialised;
    uint1   rightleft <:: ( max_x - px ) < ( px - min_x );
    insideTriangle IN(
        px <: px,
        py <: py,
        x <: x0,
        y <: y0,
        x1 <: x1,
        y1 <: y1,
        x2 <: x2,
        y2 <: y2,
        inside :> inTriangle
    );
    // WORK COORDINATES
    int16   px = uninitialized;
    int16   py = uninitialized;
    // WORK DIRECTION ( == 0 left, == 1 right )
    uint1   dx = uninitialized;

    bitmap_x_write := px; bitmap_y_write := py; bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            dx = 1; beenInTriangle = 0; px = min_x; py = min_y;
            while( py <= max_y ) {
                // Edge calculations to determine if inside the triangle - converted to DSP blocks
                beenInTriangle = inTriangle | beenInTriangle;
                bitmap_write = inTriangle;
                EXIT = ( beenInTriangle & ~inTriangle );
                if( EXIT ) {
                    // Exited the triangle, move to the next line
                    beenInTriangle = 0;
                    py = py + 1;
                    if( rightleft ) {
                        // Closer to the right
                        px = max_x; dx = 0;
                    } else {
                        // Closer to the left
                        px = min_x; dx = 1;
                    }
                } else {
                    if( dx ) {
                        if( px <= max_x ) {
                            px = px + 1;
                        } else {
                            dx = 0; beenInTriangle = 0; py = py + 1;
                        }
                    } else {
                        if( px >= min_x ) {
                            px = px - 1;
                        } else {
                            dx = 1; beenInTriangle = 0; py = py + 1;
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
    input   int16   crop_left,
    input   int16   crop_right,
    input   int16   crop_top,
    input   int16   crop_bottom,
    input   int16   x,
    input   int16   y,
    input   int16   param0,
    input   int16   param1,
    input   int16   param2,
    input   int16   param3,
    output  int16   bitmap_x_write,
    output  int16   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    // VERTEX COORDINATES AND BOUNDING BOX
    int16   x1 = uninitialized;
    int16   y1 = uninitialized;
    int16   x2 = uninitialized;
    int16   y2 = uninitialized;
    int16   x3 = uninitialized;
    int16   y3 = uninitialized;
    int16   min_x = uninitialized;
    int16   max_x = uninitialized;
    int16   min_y = uninitialized;
    int16   max_y = uninitialized;
    uint1   todraw = uninitialised;
    preptriangle PREP(
        crop_left <: crop_left,
        crop_right <: crop_right,
        crop_top <: crop_top,
        crop_bottom <: crop_bottom,
        x <: x,
        y <: y,
        param0 <: param0,
        param1 <: param1,
        param2 <: param2,
        param3 <: param3,
        x1 :> x1,
        y1 :> y1,
        x2 :> x2,
        y2 :> y2,
        x3 :> x3,
        y3 :> y3,
        min_x :> min_x,
        min_y :> min_y,
        max_x :> max_x,
        max_y :> max_y,
        todraw :> todraw
    );

    uint1   TRIANGLEstart = uninitialised;
    uint1   TRIANGLEbusy = uninitialised;
    drawtriangle TRIANGLE(
        min_x <: min_x,
        max_x <: max_x,
        min_y <: min_y,
        max_y <: max_y,
        x0 <: x1,
        y0 <: y1,
        x1 <: x2,
        y1 <: y2,
        x2 <: x3,
        y2 <: y3,
        bitmap_x_write :> bitmap_x_write,
        bitmap_y_write :> bitmap_y_write,
        bitmap_write :> bitmap_write,
        start <: TRIANGLEstart,
        busy :> TRIANGLEbusy
    );
    TRIANGLEstart := 0;

    while(1) {
        if( start ) {
            busy = 1;
            () <- PREP <- ();
            TRIANGLEstart = todraw; while( TRIANGLEbusy ) {}
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

algorithm blit(
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

    input   int16   x,
    input   int16   y,
    input   uint8   param0,
    input   uint2   param1,
    input   uint3   param2,

    output  int16   bitmap_x_write,
    output  int16   bitmap_y_write,
    output  uint1   bitmap_write,

    input   uint1   tilecharacter
) <autorun> {
    // POSITION IN TILE/CHARACTER
    uint5   gpu_active_x = uninitialized;
    uint5   gpu_active_y = uninitialized;

    // POSITION ON THE SCREEN
    int16   gpu_x1 = uninitialized;
    uint5   gpu_x2 = uninitialised;
    int16   gpu_y1 = uninitialized;
    uint5   gpu_y2 = uninitialised;

    // MULTIPLIER FOR THE SIZE
    uint2   gpu_param1 = uninitialised;
    uint5   gpu_max_x = uninitialized;
    uint5   gpu_max_y = uninitialized;

    // REFLECTION FLAGS - { reflecty, reflectx }
    uint3   gpu_param2 = uninitialised;

    // TILE/CHARACTER TO BLIT
    uint8   gpu_tile = uninitialized;

    // tile and character bitmap addresses
    // tile bitmap and charactermap addresses - handling rotation or reflection - find y and x positions, then concert to address
    uint4   yinblittile <: gpu_param2[2,1] ? ( gpu_param2[0,2] == 2b00 ) ? gpu_active_y[0,4] :
                                        ( gpu_param2[0,2] == 2b01 ) ? gpu_active_x[0,4] :
                                        ( gpu_param2[0,2] == 2b10 ) ? 4b1111 - gpu_active_y[0,4] :
                                        4b1111 - gpu_active_x[0,4] :
                                        gpu_param2[1,1] ? 4b1111 - gpu_active_y[0,4] :  gpu_active_y[0,4];
    uint4   xinblittile <: gpu_param2[2,1] ?  ( gpu_param2[0,2] == 2b00 ) ? gpu_active_x[0,4] :
                                        ( gpu_param2[0,2] == 2b01 ) ? 4b1111 - gpu_active_y[0,4] :
                                        ( gpu_param2[0,2] == 2b10 ) ? 4b1111 - gpu_active_x[0,4] :
                                        gpu_active_y[0,4] :
                                        gpu_param2[0,1] ? 4b1111 - gpu_active_x[0,4] :  gpu_active_x[0,4];
    uint3   yinchartile <: gpu_param2[2,1] ? ( gpu_param2[0,2] == 2b00 ) ? gpu_active_y[0,3] :
                                        ( gpu_param2[0,2] == 2b01 ) ? gpu_active_x[0,3] :
                                        ( gpu_param2[0,2] == 2b10 ) ? 3b111 - gpu_active_y[0,3] :
                                        3b111 - gpu_active_x[0,3] :
                                        gpu_param2[1,1] ? 3b111 - gpu_active_y[0,3] :  gpu_active_y[0,3];
    uint3   xinchartile <: gpu_param2[2,1] ?  ( gpu_param2[0,2] == 2b00 ) ? gpu_active_x[0,3] :
                                        ( gpu_param2[0,2] == 2b01 ) ? 3b111 - gpu_active_y[0,3] :
                                        ( gpu_param2[0,2] == 2b10 ) ? 3b111 - gpu_active_x[0,3] :
                                        gpu_active_y[0,3] :
                                        gpu_param2[0,1] ? 3b111 - gpu_active_x[0,3] :  gpu_active_x[0,3];
    blit1tilemap.addr0 := { gpu_tile, yinblittile };
    characterGenerator8x8.addr0 := { gpu_tile, yinchartile };

    bitmap_x_write := gpu_x1 + ( gpu_active_x << gpu_param1 ) + gpu_x2; bitmap_y_write := gpu_y1 + ( gpu_active_y << gpu_param1 ) + gpu_y2; bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            gpu_active_x = 0;
            gpu_active_y = 0;
            ( gpu_x1, gpu_y1 ) = copycoordinates( x, y );
            ( gpu_param1, gpu_param2 ) = copycoordinates( param1, param2 );
            gpu_max_x = tilecharacter ? 16 : 8;
            gpu_max_y = tilecharacter ? 16 : 8;
            gpu_tile = param0;
            while( gpu_active_y != gpu_max_y ) {
                while( gpu_active_x != gpu_max_x ) {
                    gpu_y2 = 0;
                    while( gpu_y2 != ( 1 << gpu_param1 ) ) {
                        gpu_x2 = 0;
                        while( gpu_x2 != ( 1 << gpu_param1 ) ) {
                            bitmap_write = tilecharacter ? blit1tilemap.rdata0[4b1111 - xinblittile, 1] : characterGenerator8x8.rdata0[7 - xinchartile, 1];
                            gpu_x2 = gpu_x2 + 1;
                        }
                        gpu_y2 = gpu_y2 + 1;
                    }
                    gpu_active_x = gpu_active_x + 1;
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
    input   int16   x,
    input   int16   y,
    input   uint5   param0,
    input   uint2   param1,
    input   uint3   param2,

    output  int16   bitmap_x_write,
    output  int16   bitmap_y_write,
    output  uint7   bitmap_colour_write,
    output  uint1   bitmap_write
) <autorun> {
    // POSITION IN TILE/CHARACTER
    uint7   gpu_active_x = uninitialized;
    uint7   gpu_active_y = uninitialized;

    // POSITION ON THE SCREEN
    int16   gpu_x1 = uninitialized;
    int16   gpu_y1 = uninitialized;
    uint5   gpu_x2 = uninitialised;
    uint5   gpu_y2 = uninitialised;

    // MULTIPLIER FOR THE SIZE
    uint2   gpu_param1 = uninitialised;

    // ACTION - REFLECTION OR ROTATION
    uint4   gpu_param2 = uninitialised;

    // TILE/CHARACTER TO BLIT
    uint5   gpu_tile = uninitialized;

    // tile bitmap addresses - handling rotation or reflection - find y and x positions, then concert to address
    uint4   yintile <: gpu_param2[2,1] ? ( gpu_param2[0,2] == 2b00 ) ? gpu_active_y[0,4] :
                                        ( gpu_param2[0,2] == 2b01 ) ? gpu_active_x[0,4] :
                                        ( gpu_param2[0,2] == 2b10 ) ? 4b1111 - gpu_active_y[0,4] :
                                        4b1111 - gpu_active_x[0,4] :
                                        gpu_param2[1,1] ? 4b1111 - gpu_active_y[0,4] :  gpu_active_y[0,4];
    uint4   xintile <: gpu_param2[2,1] ?  ( gpu_param2[0,2] == 2b00 ) ? gpu_active_x[0,4] :
                                        ( gpu_param2[0,2] == 2b01 ) ? 4b1111 - gpu_active_y[0,4] :
                                        ( gpu_param2[0,2] == 2b10 ) ? 4b1111 - gpu_active_x[0,4] :
                                        gpu_active_y[0,4] :
                                        gpu_param2[0,1] ? 4b1111 - gpu_active_x[0,4] :  gpu_active_x[0,4];
    colourblittilemap.addr0 := { gpu_tile, yintile, xintile };

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
            gpu_param2 = param2;
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

    input   int16   x,
    input   int16   y,
    input   int16   param0,
    input   uint7   param1,

    input   uint7   colour7,
    input   uint8   colour8r,
    input   uint8   colour8g,
    input   uint8   colour8b,
    input   uint2   newpixel,

    output  int16   bitmap_x_write,
    output  int16   bitmap_y_write,
    output  uint7   bitmap_colour_write,
    output  uint1   bitmap_write
) <autorun> {
    // POSITION ON THE SCREEN
    int16   min_x = uninitialized;
    int16   max_x = uninitialized;
    int16   x1 = uninitialised;
    int16   y1 = uninitialised;
    uint7   ignorecolour = uninitialised;

    bitmap_x_write := x1;
    bitmap_y_write := y1;
    bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            x1 = x; y1 = y; max_x = x + param0; ignorecolour = param1;
            while( busy ) {
                switch( newpixel ) {
                    case 0: {}
                    case 1: { bitmap_colour_write = colour7; bitmap_write = ( colour7 != ignorecolour ); }
                    case 2: { bitmap_colour_write = { 1b0, colour8r[6,2], colour8g[6,2], colour8b[6,2] }; bitmap_write = 1; }
                    case 3: { busy = 0; }
                }
                if( x1 != max_x ) {
                    x1 = x1 + ( newpixel != 0 );
                } else {
                    x1 = x; y1 = y1 + 1;
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
algorithm centreplusdelta(
    input   int16   xc,
    input   uint6   dx,
    input   int16   yc,
    input   uint6   dy,
    input   uint3   scale,
    input   uint3   action,
    output  int16   xdx,
    output  int16   ydy
) <autorun> {
    int16 deltax <:: { {11{dx[5,1]}}, dx };
    int16 deltay <:: { {11{dy[5,1]}}, dy };

    always {
        if( action[2,1] ) {
            // ROTATION
            switch( action[0,2] ) {
                case 0: {
                    xdx = xc + ( scale[2,1] ? ( __signed(deltax) >>> scale[0,2] ) : ( deltax << scale[0,2] ) );
                    ydy = yc + ( scale[2,1] ? ( __signed(deltay) >>> scale[0,2] ) : ( deltay << scale[0,2] ) );
                }
                case 1: {
                    xdx = xc - ( scale[2,1] ? ( __signed(deltay) >>> scale[0,2] ) : ( deltay << scale[0,2] ) );
                    ydy = yc + ( scale[2,1] ? ( __signed(deltax) >>> scale[0,2] ) : ( deltax << scale[0,2] ) );
                }
                case 2: {
                    xdx = xc - ( scale[2,1] ? ( __signed(deltax) >>> scale[0,2] ) : ( deltax << scale[0,2] ) );
                    ydy = yc - ( scale[2,1] ? ( __signed(deltay) >>> scale[0,2] ) : ( deltay << scale[0,2] ) );
                }
                case 3: {
                    xdx = xc + ( scale[2,1] ? ( __signed(deltay) >>> scale[0,2] ) : ( deltay << scale[0,2] ) );
                    ydy = yc - ( scale[2,1] ? ( __signed(deltax) >>> scale[0,2] ) : ( deltax << scale[0,2] ) );
                }
            }
        } else {
            // REFLECTION
            xdx = action[0,1] ? xc - ( scale[2,1] ? ( __signed(deltax) >>> scale[0,2] ) : ( deltax << scale[0,2] ) ) : xc + ( scale[2,1] ? ( __signed(deltax) >>> scale[0,2] ) : ( deltax << scale[0,2] ) );
            ydy = action[1,1] ? yc - ( scale[2,1] ? ( __signed(deltay) >>> scale[0,2] ) : ( deltay << scale[0,2] ) ) : yc + ( scale[2,1] ? ( __signed(deltay) >>> scale[0,2] ) : ( deltay << scale[0,2] ) );
        }
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
    vertex.addr1 := { vertices_writer_block, vertices_writer_vertex };
    vertex.wdata1 := { vertices_writer_active, __unsigned(vertices_writer_xdelta), __unsigned(vertices_writer_ydelta) };
}
algorithm vectors(
    simple_dualport_bram_port0 vertex,
    input   uint5   vector_block_number,
    input   int16   vector_block_xc,
    input   int16   vector_block_yc,
    input   uint3   vector_block_scale,
    input   uint3   vector_block_action,
    input   uint1   draw_vector,
    output  uint1   vector_block_active(0),

    // Communication with the GPU
    output  int16   gpu_x,
    output  int16   gpu_y,
    output  int16   gpu_param0,
    output  int16   gpu_param1,
    output  uint1   gpu_write,
    input   uint1   gpu_active
) <autorun> {
    // Add present deltas to the centres
    uint6   deltax <:: { vectorentry(vertex.rdata0).dxsign, vectorentry(vertex.rdata0).dx };
    uint6   deltay <:: { vectorentry(vertex.rdata0).dysign, vectorentry(vertex.rdata0).dy };
    int16   xdx = uninitialised;
    int16   ydy = uninitialised;
    centreplusdelta CENTREPLUSDELTA(
        xc <: vector_block_xc,
        yc <: vector_block_yc,
        dx <: deltax,
        dy <: deltay,
        scale <: vector_block_scale,
        action <: vector_block_action,
        xdx :> xdx,
        ydy :> ydy
    );

    // Vertices being processed, plus first coordinate of each line
    uint5 block_number = 0;
    uint5 vertices_number = 0;
    int16 start_x = uninitialised;
    int16 start_y = uninitialised;

    // Set read address for the vertices
    vertex.addr0 := { block_number, vertices_number };

    gpu_write := 0;

    while(1) {
        if( draw_vector ) {
            vector_block_active = 1;
            block_number = vector_block_number;
            vertices_number = 0;
            ++:
            // Start with the first vertex
            ( start_x, start_y ) = copycoordinates( xdx, ydy );
            vertices_number = 1;
            ++:
            // Continue until an inactive or last vertex
            while( vectorentry(vertex.rdata0).active && ( vertices_number != 16 ) ) {
                // Dispatch line to GPU
                ( gpu_x, gpu_y ) = copycoordinates( start_x, start_y );
                ( gpu_param0, gpu_param1 ) = copycoordinates( xdx, ydy );
                ++:
                while( gpu_active ) {} gpu_write = 1;
                ++:
                // Move onto the next vertex
                ( start_x, start_y ) = copycoordinates( gpu_param0, gpu_param1 );
                vertices_number = vertices_number + 1;
            }
            vector_block_active = 0;
        }
    }
}
