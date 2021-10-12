algorithm gpu_queue(
    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint7   bitmap_colour_write,
    output  uint7   bitmap_colour_write_alt,
    output  uint1   bitmap_write,
    output  uint9   bitmap_crop_left,
    output  uint9   bitmap_crop_right,
    output  uint8   bitmap_crop_top,
    output  uint8   bitmap_crop_bottom,
    output  uint4   gpu_active_dithermode,

    input   uint9   crop_left,
    input   uint9   crop_right,
    input   uint8   crop_top,
    input   uint8   crop_bottom,

    input   int11   gpu_x,
    input   int11   gpu_y,
    input   uint7   gpu_colour,
    input   uint7   gpu_colour_alt,
    input   int11   gpu_param0,
    input   int11   gpu_param1,
    input   int11   gpu_param2,
    input   int11   gpu_param3,
    input   int11   gpu_param4,
    input   int11   gpu_param5,
    input   uint4   gpu_write,
    input   uint4   gpu_dithermode,

    input   uint6   blit1_writer_tile,
    input   uint4   blit1_writer_line,
    input   uint16  blit1_writer_bitmap,

    input   uint9   character_writer_character,
    input   uint3   character_writer_line,
    input   uint8   character_writer_bitmap,

    input   uint6   colourblit_writer_tile,
    input   uint4   colourblit_writer_line,
    input   uint4   colourblit_writer_pixel,
    input   uint7   colourblit_writer_colour,

    input   uint7   pb_colour7,
    input   uint8   pb_colour8r,
    input   uint8   pb_colour8g,
    input   uint8   pb_colour8b,
    input   uint2   pb_newpixel,

    input   uint6   vector_block_number,
    input   uint7   vector_block_colour,
    input   int11   vector_block_xc,
    input   int11   vector_block_yc,
    input   uint3   vector_block_scale,
    input   uint3   vector_block_action,
    input   uint1   draw_vector,
    input   uint6   vertices_writer_block,
    input   uint6   vertices_writer_vertex,
    input   int6    vertices_writer_xdelta,
    input   int6    vertices_writer_ydelta,
    input   uint1   vertices_writer_active,

    output  uint1   queue_full(0),
    output  uint1   queue_complete(1),
    output  uint1   vector_block_active(0)
) <autorun> {
    // 32 x 16 x 16 1 bit tilemap for blit1tilemap
    simple_dualport_bram uint16 blit1tilemap[ 1024 ] = uninitialized;
    // Character ROM 8x8 x 256 for character blitter
    simple_dualport_bram uint8 characterGenerator8x8[] = {
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
    simple_dualport_bram uint7 colourblittilemap[ 16384 ] = uninitialized;
    // COLOURBLIT TILE WRITER
    colourblittilebitmapwriter CBTBM(
        colourblit_writer_tile <: colourblit_writer_tile,
        colourblit_writer_line <: colourblit_writer_line,
        colourblit_writer_pixel <: colourblit_writer_pixel,
        colourblit_writer_colour <: colourblit_writer_colour,
        colourblittilemap <:> colourblittilemap,
    );

    // 32 vector blocks each of 16 vertices
    simple_dualport_bram uint13 vertex[1024] = uninitialised;
    // VECTOR DRAWER UNIT
    int11   vector_drawer_gpu_x = uninitialised;
    int11   vector_drawer_gpu_y = uninitialised;
    int11   vector_drawer_gpu_param0 = uninitialised;
    int11   vector_drawer_gpu_param1 = uninitialised;
    uint1   vector_drawer_gpu_write = uninitialised;
    vectors vector_drawer(
        gpu_x :> vector_drawer_gpu_x,
        gpu_y :> vector_drawer_gpu_y,
        gpu_param0 :> vector_drawer_gpu_param0,
        gpu_param1 :> vector_drawer_gpu_param1,
        gpu_write :> vector_drawer_gpu_write,
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

    int11   x = uninitialised;
    int11   y = uninitialised;
    uint7   colour = uninitialised;
    uint7   colour_alt = uninitialised;
    int11   param0 = uninitialised;
    int11   param1 = uninitialised;
    int11   param2 = uninitialised;
    int11   param3 = uninitialised;
    int11   param4 = uninitialised;
    int11   param5 = uninitialised;
    uint4   dithermode = uninitialised;
    uint1   gpu_active = uninitialised;
    uint4   write = uninitialised;
    uint9   cropL = uninitialised;
    uint8   cropT = uninitialised;
    uint9   cropR = uninitialised;
    uint8   cropB = uninitialised;
    gpu GPU(
        crop_left <: cropL,
        crop_right <: cropR,
        crop_top <: cropT,
        crop_bottom <: cropB,
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

    // QUEUE GPU PARAMETERS, INCLUDING DITHERMODE AND CROP
    uint1   queue_busy = 0;
    int11   queue_x = uninitialised;
    int11   queue_y = uninitialised;
    uint7   queue_colour = uninitialised;
    uint7   queue_colour_alt = uninitialised;
    int11   queue_param0 = uninitialised;
    int11   queue_param1 = uninitialised;
    int11   queue_param2 = uninitialised;
    int11   queue_param3 = uninitialised;
    int11   queue_param4 = uninitialised;
    int11   queue_param5 = uninitialised;
    uint4   queue_dithermode = uninitialised;
    uint4   queue_write = uninitialised;
    uint9   queue_cropL = uninitialised;
    uint8   queue_cropT = uninitialised;
    uint9   queue_cropR = uninitialised;
    uint8   queue_cropB = uninitialised;
    write := 0; queue_full := vector_block_active | queue_busy ; queue_complete := ~( gpu_active | queue_full );
    bitmap_crop_left := cropL; bitmap_crop_right := cropR; bitmap_crop_top := cropT; bitmap_crop_bottom := cropB;

    always {
        if( gpu_write != 0 ) {
            queue_dithermode = gpu_dithermode; queue_colour = gpu_colour; queue_colour_alt = gpu_colour_alt;
            queue_x = gpu_x; queue_y = gpu_y;
            queue_param0 = gpu_param0; queue_param1 = gpu_param1;
            queue_param2 = gpu_param2; queue_param3 = gpu_param3;
            queue_param4 = gpu_param4; queue_param5 = gpu_param5;
            queue_write = gpu_write;
            queue_cropL = crop_left; queue_cropR = crop_right;
            queue_cropT = crop_top; queue_cropB = crop_bottom;
        }
        if( vector_drawer_gpu_write ) {
            dithermode = 0; colour = vector_block_colour; colour_alt = 0;
            x = vector_drawer_gpu_x; y = vector_drawer_gpu_y;
            param0 = vector_drawer_gpu_param0; param1 = vector_drawer_gpu_param1;
            param2 = 1; param3 = 0;
            cropL = crop_left; cropR = crop_right; cropT = crop_top; cropB = crop_bottom;
            write = 2;
        }
    }

    while(1) {
        switch( gpu_write ) {
            case 0: {}
            default: {
                // COMMAND QUEUE, LATCH AND WAIT FOR GPU THEN DISPATCH
                queue_busy = 1;
                while( gpu_active ) {}
                colour = queue_colour; colour_alt = queue_colour_alt; dithermode = queue_dithermode;
                x = queue_x; y = queue_y;
                param0 = queue_param0; param1 = queue_param1;
                param2 = queue_param2; param3 = queue_param3;
                cropL = queue_cropL; cropR = queue_cropR; cropT = queue_cropT; cropB = queue_cropB;
                write = queue_write;
                queue_busy = 0;
            }
            case 15: {
                // COMMAND QUEUE FOR QUADRILATERALS, SPLIT INTO TWO TRIANGLES THEN DISPATCH
                queue_busy = 1;
                // QUADRILATERAL BY SPLITTING INTO 2 TRIANGLES
                while( gpu_active ) {}
                dithermode = queue_dithermode;colour = queue_colour; colour_alt = queue_colour_alt;
                x = queue_x; y = queue_y;
                param0 = queue_param0; param1 = queue_param1;
                param2 = queue_param2; param3 = queue_param3;
                cropL = queue_cropL; cropR = queue_cropR;
                cropT = queue_cropT; cropB = queue_cropB;
                write = 6; while( gpu_active ) {}
                // SECOND TRIANGLE
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
    output int11   bitmap_x_write,
    output int11   bitmap_y_write,
    output uint7   bitmap_colour_write,
    output uint7   bitmap_colour_write_alt,
    output uint1   bitmap_write,
    output uint4   gpu_active_dithermode,

    input   uint9   crop_left,
    input   uint9   crop_right,
    input   uint8   crop_top,
    input   uint8   crop_bottom,

    input   int11   gpu_x,
    input   int11   gpu_y,
    input   uint7   gpu_colour,
    input   uint7   gpu_colour_alt,
    input   int11   gpu_param0,
    input   int11   gpu_param1,
    input   int11   gpu_param2,
    input   int11   gpu_param3,
    input   int11   gpu_param4,
    input   int11   gpu_param5,
    input   uint4   gpu_write,
    input   uint4   gpu_dithermode,

    input   uint7   pb_colour7,
    input   uint8   pb_colour8r,
    input   uint8   pb_colour8g,
    input   uint8   pb_colour8b,
    input   uint2   pb_newpixel,

    output  uint1   gpu_active(0),
) <autorun> {
    // GPU SUBUNITS
    uint1   GPUrectanglestart = uninitialised;
    uint1   GPUrectanglebusy = uninitialised;
    int11   GPUrectanglebitmap_x_write = uninitialised;
    int11   GPUrectanglebitmap_y_write = uninitialised;
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
    int11   GPUlinebitmap_x_write = uninitialised;
    int11   GPUlinebitmap_y_write = uninitialised;
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
    int11   GPUcirclebitmap_x_write = uninitialised;
    int11   GPUcirclebitmap_y_write = uninitialised;
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
    int11   GPUtrianglebitmap_x_write = uninitialised;
    int11   GPUtrianglebitmap_y_write = uninitialised;
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
    int11   GPUblitbitmap_x_write = uninitialised;
    int11   GPUblitbitmap_y_write = uninitialised;
    uint1   GPUblitbitmap_write = uninitialised;
    uint1   GPUblittilecharacter = uninitialised;
    blit GPUblit(
        blit1tilemap <:> blit1tilemap,
        characterGenerator8x8 <:> characterGenerator8x8,
        x <: gpu_x,
        y <: gpu_y,
        tile <: gpu_param0,
        scale <: gpu_param1,
        action <: gpu_param2,
        start <: GPUblitstart,
        busy :> GPUblitbusy,
        bitmap_x_write :> GPUblitbitmap_x_write,
        bitmap_y_write :> GPUblitbitmap_y_write,
        bitmap_write :> GPUblitbitmap_write,
        tilecharacter <: GPUblittilecharacter
    );
    uint1   GPUcolourblitstart = uninitialised;
    uint1   GPUcolourblitbusy = uninitialised;
    int11   GPUcolourblitbitmap_x_write = uninitialised;
    int11   GPUcolourblitbitmap_y_write = uninitialised;
    uint1   GPUcolourblitbitmap_write = uninitialised;
    uint7   GPUcolourblitbitmap_colour_write = uninitialised;
    colourblit GPUcolourblit(
        colourblittilemap <:> colourblittilemap,
        x <: gpu_x,
        y <: gpu_y,
        tile <: gpu_param0,
        scale <: gpu_param1,
        action <: gpu_param2,
        start <: GPUcolourblitstart,
        busy :> GPUcolourblitbusy,
        bitmap_x_write :> GPUcolourblitbitmap_x_write,
        bitmap_y_write :> GPUcolourblitbitmap_y_write,
        bitmap_write :> GPUcolourblitbitmap_write,
        bitmap_colour_write :> GPUcolourblitbitmap_colour_write
    );
    uint1   GPUpixelblockstart = uninitialised;
    uint1   GPUpixelblockbusy = uninitialised;
    int11   GPUpixelblockbitmap_x_write = uninitialised;
    int11   GPUpixelblockbitmap_y_write = uninitialised;
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

    // GPU UNIT BUSY FLAGS
    uint7   gpu_busy_flags <:: { GPUpixelblockbusy, GPUcolourblitbusy, GPUblitbusy, GPUtrianglebusy, GPUcirclebusy, GPUrectanglebusy, GPUlinebusy };
    uint1   gpu_busy <: ( gpu_busy_flags != 0 );

    // CONTROLS FOR BITMAP PIXEL WRITER AND GPU SUBUNITS
    bitmap_write := GPUlinebitmap_write | GPUrectanglebitmap_write | GPUcirclebitmap_write |
                                    GPUtrianglebitmap_write | GPUblitbitmap_write | GPUcolourblitbitmap_write | GPUpixelblockbitmap_write;

    GPUrectanglestart := 0; GPUlinestart := 0; GPUcirclestart := 0; GPUtrianglestart := 0; GPUblitstart := 0; GPUcolourblitstart := 0; GPUpixelblockstart := 0;
    gpu_active := ( gpu_write[1,3] != 0 ) | gpu_busy;

    always {
        switch( gpu_write ) {
            case 0: {}
            case 1: {
                // SET PIXEL (X,Y) NO GPU ACTIVATION
                gpu_active_dithermode = 0; bitmap_colour_write = gpu_colour; bitmap_x_write = gpu_x; bitmap_y_write = gpu_y; bitmap_write = 1;
            }
            default: {
                // START THE GPU DRAWING UNIT - RESET DITHERMODE TO 0 (most common)
                gpu_active_dithermode = 0; bitmap_colour_write = gpu_colour; bitmap_colour_write_alt = gpu_colour_alt;
                switch( gpu_write ) {
                    default: {}
                    case 2: { GPUlinestart = 1; }                                                                       // DRAW LINE FROM (X,Y) to (PARAM0,PARAM1)
                    case 3: { gpu_active_dithermode = gpu_dithermode; GPUrectanglestart = 1; }                          // DRAW RECTANGLE FROM (X,Y) to (PARAM0,PARAM1)
                    case 4: { GPUcirclefilledcircle = 0; GPUcirclestart = 1; }                                          // DRAW CIRCLE CENTRE (X,Y) with RADIUS PARAM0
                    case 5: { gpu_active_dithermode = gpu_dithermode; GPUcirclefilledcircle = 1; GPUcirclestart = 1; }  // DRAW FILLED CIRCLE CENTRE (X,Y) with RADIUS PARAM0
                    case 6: { gpu_active_dithermode = gpu_dithermode; GPUtrianglestart = 1; }                           // DRAW FILLED TRIANGLE WITH VERTICES (X,Y) (PARAM0,PARAM1) (PARAM2,PARAM3)
                    case 7: { GPUblittilecharacter = 1; GPUblitstart = 1; }                                             // BLIT 16 x 16 TILE PARAM0 TO (X,Y)
                    case 8: { GPUblittilecharacter = 0; GPUblitstart = 1; }                                             // BLIT 8 x 8 CHARACTER PARAM0 TO (X,Y) as 8 x 8
                    case 9: { GPUcolourblitstart = 1; }                                                                 // BLIT 16 x 16 COLOUR TILE PARAM0 TO (X,Y) as 16 x 16
                    case 10: { GPUpixelblockstart = 1; }                                                                // START THE PIXELBLOCK WRITER AT (x,y) WITH WIDTH PARAM0, IGNORE COLOUR PARAM1
                    // 11
                    // 12
                    // 13
                    // 14
                    // 15 is quadrilateral, handled by the queue
                }
            }
        }
    }
    while(1) {
        if( gpu_busy ) {
            // COPY OUTPUT TO THE BITMAP WRITER
            onehot( gpu_busy_flags ) {
                case 0: { bitmap_x_write = GPUlinebitmap_x_write; bitmap_y_write = GPUlinebitmap_y_write; }
                case 1: { bitmap_x_write = GPUrectanglebitmap_x_write; bitmap_y_write = GPUrectanglebitmap_y_write; }
                case 2: { bitmap_x_write = GPUcirclebitmap_x_write; bitmap_y_write = GPUcirclebitmap_y_write; }
                case 3: { bitmap_x_write = GPUtrianglebitmap_x_write; bitmap_y_write = GPUtrianglebitmap_y_write; }
                case 4: { bitmap_x_write = GPUblitbitmap_x_write; bitmap_y_write = GPUblitbitmap_y_write; }
                case 5: { bitmap_x_write = GPUcolourblitbitmap_x_write; bitmap_y_write = GPUcolourblitbitmap_y_write; bitmap_colour_write = GPUcolourblitbitmap_colour_write; }
                case 6: { bitmap_x_write = GPUpixelblockbitmap_x_write; bitmap_y_write = GPUpixelblockbitmap_y_write; bitmap_colour_write = GPUpixelblockbitmap_colour_write; }
            }
        }
    }
}

// RECTANGLE - OUTPUT PIXELS TO DRAW A RECTANGLE
algorithm preprectangle(
    input   uint1   start,
    input   int11   crop_left,
    input   int11   crop_right,
    input   int11   crop_top,
    input   int11   crop_bottom,
    input   int11   x,
    input   int11   y,
    input   int11   param0,
    input   int11   param1,
    output  int11   min_x,
    output  int11   min_y,
    output  int11   max_x,
    output  int11   max_y,
    output  uint1   todraw
) <autorun> {
    uint1   xcompareparam0 <:: ( x < param0 );
    uint1   ycompareparam1 <:: ( y < param1 );

    int11   x1 <:: xcompareparam0 ? x : param0;
    int11   y1 <:: ycompareparam1 ? y : param1;
    int11   x2 <:: xcompareparam0 ? param0 : x;
    int11   y2 <:: ycompareparam1 ? param1 : y;

    todraw := 0;

    always {
        if( start ) {
            min_x = ( x1 < crop_left ) ? crop_left : x1;
            min_y = ( y1 < crop_top ) ? crop_top : y1;
            max_x = 1 + ( ( x2 > crop_right ) ? crop_right : x2 );
            max_y = 1 + ( ( y2 > crop_bottom ) ? crop_bottom : y2 );
            todraw = ~( ( max_x < crop_left ) | ( max_y < crop_top ) | ( min_x > crop_right ) | ( min_y > crop_bottom ) );
        }
    }
}
algorithm drawrectangle(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint9   min_x,
    input   uint8   min_y,
    input   uint9   max_x,
    input   uint8   max_y,
    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    uint9   x = uninitialized;
    uint8   y = uninitialized;
    bitmap_x_write := x; bitmap_y_write := y; bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            y = min_y;
            while( y != max_y ) {
                x = min_x;
                while( x != max_x ) {
                    bitmap_write = 1; x = x + 1;
                }
                y = y + 1;
            }
            busy = 0;
        }
    }
}
algorithm rectangle (
    input   uint1   start,
    output  uint1   busy(0),
    input   int11   crop_left,
    input   int11   crop_right,
    input   int11   crop_top,
    input   int11   crop_bottom,
    input   int11   x,
    input   int11   y,
    input   int11   param0,
    input   int11   param1,

    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    uint9   min_x = uninitialised;
    uint8   min_y = uninitialised;
    uint9   max_x = uninitialised;
    uint8   max_y = uninitialised;
    uint1   todraw = uninitialised;
    preprectangle PREP(
        start <: start,
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
        start <: todraw,
        busy :> RECTANGLEbusy
    );

    busy := start | todraw | RECTANGLEbusy;
}

// LINE - OUTPUT PIXELS TO DRAW A LINE
algorithm prepline(
    input   uint1   start,
    output  uint1   todraw,
    input   int11   x,
    input   int11   y,
    input   int11   param0,
    input   int11   param1,
    input   int11   param2,
    output  int11   x1,
    output  int11   y1,
    output  int11   dx,
    output  int11   dy,
    output  uint1   dv,
    output  int11   numerator,
    output  int11   max_count
) <autorun> {
    uint1 ylessparam1 <:: ( y < param1 );
    todraw := 0;

    always {
        if( start ) {
            // Setup drawing a line from x,y to param0,param1 of width param2 in colour
            // Ensure LEFT to RIGHT AND if moving UP or DOWN
            if( x < param0 ) {
                x1 = x;
                y1 = y;
                dv = ylessparam1;
            } else {
                x1 = param0;
                y1 = param1;
                dv = ~ylessparam1;
            }

            // Absolute DELTAs
            ( dx ) = absdelta( x, param0 ); ( dy ) = absdelta( y, param1 );

            // Numerator
            if( dx > dy ) {
                numerator = ( dx >> 1 );
                max_count = dx + 1;
            } else {
                numerator = -( dy >> 1 );
                max_count = dy + 1;
            }
            todraw = 1;
        }
    }
}
algorithm drawline(
    input   uint1   start,
    output  uint1   busy(0),
    input   int11   start_x,
    input   int11   start_y,
    input   int11   start_numerator,
    input   int11   dx,
    input   int11   dy,
    input   uint1   dv,
    input   int11   max_count,
    input   uint8   width,
    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    int11   x = uninitialized;
    int11   y = uninitialized;
    int11   numerator = uninitialized;
    int11   numerator2 <:: numerator;
    int11   newnumerator <:: numerator - ( n2dx ? dy : 0 ) + ( n2dy ? dx : 0 );
    uint1   n2dx <:: numerator2 > (-dx);
    uint1   n2dy <:: numerator2 < dy;
    uint1   dxdy <:: dx > dy;
    int11   count = uninitialized;
    int11   offset_x = uninitialised;
    int11   offset_y = uninitialised;
    int11   offset_start <:: -( width >> 1 );
    uint8   pixel_count = uninitialised;

    bitmap_x_write := x + offset_x; bitmap_y_write := y + offset_y; bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            x = start_x; y = start_y; numerator = start_numerator; count = 0;
            while( count != max_count ) {
                pixel_count = 0; offset_x = dxdy ? 0 : offset_start; offset_y = dxdy ? offset_start : 0;
                while( pixel_count != width ) {
                    bitmap_write = 1;
                    offset_y = offset_y + dxdy; offset_x = offset_x + ~dxdy;
                    pixel_count = pixel_count + 1;
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
    input   int11   x,
    input   int11   y,
    input   int11   param0,
    input   int11   param1,
    input   int11   param2,
    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    int11   x1 = uninitialized;
    int11   y1 = uninitialized;
    int11   dx = uninitialized;
    int11   dy = uninitialized;
    uint1   dv = uninitialized;
    int11   numerator = uninitialized;
    int11   max_count = uninitialized;
    uint8   width <:: param2;
    uint1   todraw = uninitialised;
    prepline PREP(
        start <: start,
        todraw :> todraw,
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
    );
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
        start <: todraw,
        busy :> LINEbusy
    );
    busy := start | todraw | LINEbusy;
}

//  CIRCLE - OUTPUT PIXELS TO DRAW AN OUTLINE OR FILLED CIRCLE
algorithm drawcircle(
    input   uint1   start,
    output  uint1   busy(0),
    input   int11   xc,
    input   int11   yc,
    input   int11   radius,
    input   int11   start_numerator,
    input   uint8   draw_sectors,
    input   uint1   filledcircle,
    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    int11   numerator = uninitialised;
    int11   new_numerator <:: numerator[10,1] ? numerator + { active_x, 2b00 } + 6 : numerator + { (active_x - active_y), 2b00 } + 10;
    uint1   positivenumerator <:: ~numerator[10,1] & ( numerator != 0 );
    int11   active_x = uninitialized;
    int11   active_y = uninitialized;
    int11   count = uninitialised;
    int11   min_count = uninitialised;
    uint1   drawingcircle <:: ( active_y >= active_x );
    uint1   drawingsegment <:: ( count != min_count );
    bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            active_x = 0; active_y = radius; count = radius; numerator = start_numerator;
            min_count = (-1);
            while( drawingcircle ) {
                while( drawingsegment ) {
                    // OUTPUT PIXELS IN THE 8 SEGMENTS/ARCS
                    bitmap_write = draw_sectors[0,1]; bitmap_x_write = xc + active_x; bitmap_y_write = yc + count; ++:
                    bitmap_write = draw_sectors[1,1]; bitmap_y_write = yc - count; ++:
                    bitmap_write = draw_sectors[2,1]; bitmap_x_write = xc - active_x; ++:
                    bitmap_write = draw_sectors[3,1]; bitmap_y_write = yc + count; ++:
                    bitmap_write = draw_sectors[4,1]; bitmap_x_write = xc + count; bitmap_y_write = yc + active_x; ++:
                    bitmap_write = draw_sectors[5,1]; bitmap_y_write = yc - active_x; ++:
                    bitmap_write = draw_sectors[6,1]; bitmap_x_write = xc - count; ++:
                    bitmap_write = draw_sectors[7,1]; bitmap_y_write = yc + active_x;
                    count = filledcircle ? count - 1 : min_count;
                }
                active_x = active_x + 1;
                active_y = active_y - positivenumerator;
                count = active_y;
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
    input   int11   x,
    input   int11   y,
    input   int11   param0,
    input   uint8   param1,
    input   uint1   filledcircle,

    output  int11  bitmap_x_write,
    output  int11  bitmap_y_write,
    output  uint1  bitmap_write
) <autorun> {
    int11   radius <:: param0[10,1] ? -param0 : param0;
    int11   gpu_numerator <:: 3 - ( { radius, 1b0 } );
    uint8   draw_sectors <:: { param1[5,1], param1[6,1], param1[1,1], param1[2,1], param1[4,1], param1[7,1], param1[0,1], param1[3,1] };

    uint1   CIRCLEbusy = uninitialised;
    drawcircle CIRCLE(
        xc <: x,
        yc <: y,
        radius <: radius,
        start_numerator <: gpu_numerator,
        draw_sectors <: draw_sectors,
        filledcircle <: filledcircle,
        bitmap_x_write :> bitmap_x_write,
        bitmap_y_write :> bitmap_y_write,
        bitmap_write :> bitmap_write,
        start <: start,
        busy :> CIRCLEbusy
    );
    busy := start | CIRCLEbusy;
}

// TRIANGLE - OUTPUT PIXELS TO DRAW A FILLED TRIANGLE
algorithm preptriangle(
    input   uint1   start,
    output  uint1   busy(0),
    input   int11   crop_left,
    input   int11   crop_right,
    input   int11   crop_top,
    input   int11   crop_bottom,
    input   int11   x,
    input   int11   y,
    input   int11   param0,
    input   int11   param1,
    input   int11   param2,
    input   int11   param3,
    output  int11   x1,
    output  int11   y1,
    output  int11   x2,
    output  int11   y2,
    output  int11   x3,
    output  int11   y3,
    output  int11   min_x,
    output  int11   min_y,
    output  int11   max_x,
    output  int11   max_y,
    output  uint1   todraw
) <autorun> {
    int16 tx = uninitialised; int16 ty = uninitialised;
    uint1   x1x2 <: ( x1 < x2 );
    uint1   y1y2 <: ( y1 < y2 );
    uint1   x1x3 <: ( x1 < x3 );
    uint1   y1y3 <: ( y1 < y3 );
    uint1   x2x3 <: ( x2 < x3 );
    uint1   y2y3 <: ( y2 < y3 );

    todraw := 0;

    while(1) {
        if( start ) {
            busy = 1;
            // Setup drawing a filled triangle x,y param0, param1, param2, param3
            x1 = x; y1 = y;
            x2 = param0; y2 = param1;
            x3 = param2; y3 = param3;
            ++:
            // Put points in order so that ( x1, y1 ) is at top, then ( x2, y2 ) and ( x3, y3 ) are clockwise from there
            if( y3 < y2 ) { tx = x2; ty = y2; x2 = x3; y2 = y3; x3 = tx; y3 = ty; ++: }
            if( y2 < y1 ) { tx = x1; ty = y1; x1 = x2; y1 = y2; x2 = tx; y2 = ty; ++: }
            if( y3 < y1 ) { tx = x1; ty = y1; x1 = x3; y1 = y3; x3 = tx; y3 = ty; ++: }
            if( y3 < y2 ) { tx = x2; ty = y2; x2 = x3; y2 = y3; x3 = tx; y3 = ty; ++: }
            if( ( y2 == y1 ) & ( x2 < x1 ) ) { tx = x1; ty = y1; x1 = x2; y1 = y2; x2 = tx; y2 = ty; ++: }
            if( ( y2 != y1 ) & ( y3 >= y2 ) & ( x2 < x3 ) ) { tx = x2; ty = y2; x2 = x3; y2 = y3; x3 = tx; y3 = ty;}
            // Find minimum and maximum of x, x1, x2, y, y1 and y2 for the bounding box
            min_x = x1x2 ? ( x1x3 ? x1 : x3 ) : ( x2x3 ? x2 : x3 );
            max_x = x1x2 ? ( x2x3 ? x3 : x2 ) : ( x1x3 ? x3 : x1 );
            min_y = y1y2 ? ( y1y3 ? y1 : y3 ) : ( y2y3 ? y2 : y3 );
            max_y = y1y2 ? ( y2y3 ? y3 : y2 ) : ( y1y3 ? y3 : y1 );
            ++:
            // Apply cropping rectangle
            min_x = ( min_x < crop_left ) ? crop_left : min_x;
            min_y = ( min_y < crop_top ) ? crop_top : min_y;
            max_x = ( max_x > crop_right ) ? crop_right : max_x;
            max_y = 1 + ( ( max_y > crop_bottom ) ? crop_bottom : max_y );
            ++:
            todraw = ~( ( max_x < crop_left ) | ( max_y < crop_top ) | ( min_x > crop_right ) | ( min_y > crop_bottom ) );
            busy = 0;
        }
    }
}
algorithm drawtriangle(
    input   uint1   start,
    output  uint1   busy(0),
    input   int11   min_x,
    input   int11   min_y,
    input   int11   max_x,
    input   int11   max_y,
    input   int11   x0,
    input   int11   y0,
    input   int11   x1,
    input   int11   y1,
    input   int11   x2,
    input   int11   y2,
    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    // Filled triangle calculations
    // Is the point px,py inside the triangle given by px,py x1,y1 x2,y2?
    uint1   inTriangle <:: ( (( x2 - x1 ) * ( py - y1 ) - ( y2 - y1 ) * ( px - x1 )) >= 0 ) &
                            ( (( x0 - x2 ) * ( py - y2 ) - ( y0 - y2 ) * ( px - x2 )) >= 0 ) &
                            ( (( x1 - x0 ) * ( py - y0 ) - ( y1 - y0 ) * ( px - x0 )) >= 0 );
    uint1   beenInTriangle = uninitialized;
    uint1   EXIT = uninitialised;
    uint1   rightleft <:: ( max_x - px ) < ( px - min_x );

    // WORK COORDINATES AND DIRECTION
    int11   px = uninitialized;
    int11   py = uninitialized;
    int11   nextpy <:: py + 1;
    uint1   dx = uninitialized;
    int11   nextpx <:: px + ( dx ? 1 : (-1) );
    uint1   stillinline <:: ( dx & ( px != max_x ) ) | ( ~dx & ( px != min_x ));
    uint1   working <:: ( py != max_y );

    bitmap_x_write := px; bitmap_y_write := py; bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            dx = 1; px = min_x; py = min_y;
            while( working ) {
                beenInTriangle = inTriangle | beenInTriangle;
                bitmap_write = inTriangle;
                EXIT = ( beenInTriangle & ~inTriangle );
                if( EXIT ) {
                    // Exited the triangle, move to the next line
                    beenInTriangle = 0;
                    py = nextpy;
                    px = rightleft ? max_x : min_x;
                    dx = ~rightleft;
                } else {
                    // MOVE TO THE NEXT PIXEL ON THE LINE LEFT/RIGHT OR DOWN IF AT END
                    if( stillinline ) {
                        px = nextpx;
                    } else {
                        dx = ~dx; beenInTriangle = 0; py = nextpy;
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
    input   int11   crop_left,
    input   int11   crop_right,
    input   int11   crop_top,
    input   int11   crop_bottom,
    input   int11   x,
    input   int11   y,
    input   int11   param0,
    input   int11   param1,
    input   int11   param2,
    input   int11   param3,
    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    // VERTEX COORDINATES AND BOUNDING BOX
    uint1   PREPbusy = uninitialised;
    int11   x1 = uninitialized;
    int11   y1 = uninitialized;
    int11   x2 = uninitialized;
    int11   y2 = uninitialized;
    int11   x3 = uninitialized;
    int11   y3 = uninitialized;
    int11   min_x = uninitialized;
    int11   max_x = uninitialized;
    int11   min_y = uninitialized;
    int11   max_y = uninitialized;
    uint1   todraw = uninitialised;
    preptriangle PREP(
        start <: start,
        busy :> PREPbusy,
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
        start <: todraw,
        busy :> TRIANGLEbusy
    );
    busy := start | PREPbusy | todraw | TRIANGLEbusy;
}

// BLIT - ( tilecharacter == 0 ) OUTPUT PIXELS TO BLIT AN 8 x 8 CHARACTER ( PARAM1 == 0 as 8 x 8, == 1 as 16 x 16, == 2 as 32 x 32, == 3 as 64 x 64 )
algorithm blittilebitmapwriter(
    // For setting blit1 tile bitmaps
    input   uint6   blit1_writer_tile,
    input   uint4   blit1_writer_line,
    input   uint16  blit1_writer_bitmap,

    // For setting character generator bitmaps
    input   uint9   character_writer_character,
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

    input   int11   x,
    input   int11   y,
    input   uint9   tile,
    input   uint2   scale,
    input   uint3   action,

    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   bitmap_write,

    input   uint1   tilecharacter
) <autorun> {
    // POSITION IN TILE/CHARACTER
    uint5   px = uninitialized;
    uint5   py = uninitialized;

    // POSITION ON THE SCREEN AND WITHIN THE PIXEL COUNT FOR SCALING
    int11   x1 = uninitialized;
    uint5   x2 = uninitialised;
    int11   y1 = uninitialized;
    uint5   y2 = uninitialised;
    uint5   maxcount <:: ( 1 << scale );

    // MULTIPLIER FOR THE SIZE
    uint5   max_pixels <:: tilecharacter ? 16 : 8;

    // tile and character bitmap addresses
    // tile bitmap and charactermap addresses - handling rotation or reflection - find y and x positions, then concert to address
    uint4   revx4 <:: 4b1111 - px[0,4];
    uint4   revy4 <:: 4b1111 - py[0,4];
    uint3   revx3 <:: 3b111 - px[0,3];
    uint3   revy3 <:: 3b111 - py[0,3];

    uint4   yinblittile <:: action[2,1] ? ( action[0,2] == 2b00 ) ? py[0,4] :
                                        ( action[0,2] == 2b01 ) ? px[0,4] :
                                        ( action[0,2] == 2b10 ) ? revy4 :
                                        revx4 :
                                        action[1,1] ? revy4 :  py[0,4];
    uint4   xinblittile <:: action[2,1] ?  ( action[0,2] == 2b00 ) ? px[0,4] :
                                        ( action[0,2] == 2b01 ) ? revy4 :
                                        ( action[0,2] == 2b10 ) ? revx4 :
                                        py[0,4] :
                                        action[0,1] ? revx4 :  px[0,4];
    uint3   yinchartile <:: action[2,1] ? ( action[0,2] == 2b00 ) ? py[0,3] :
                                        ( action[0,2] == 2b01 ) ? px[0,3] :
                                        ( action[0,2] == 2b10 ) ? revy3 :
                                        revx3 :
                                        action[1,1] ? revy3 :  py[0,3];
    uint3   xinchartile <:: action[2,1] ?  ( action[0,2] == 2b00 ) ? px[0,3] :
                                        ( action[0,2] == 2b01 ) ? revy3 :
                                        ( action[0,2] == 2b10 ) ? revx3 :
                                        py[0,3] :
                                        action[0,1] ? revx3 :  px[0,3];
    blit1tilemap.addr0 := { tile, yinblittile };
    characterGenerator8x8.addr0 := { tile, yinchartile };

    bitmap_x_write := x1 + ( px << scale ) + x2; bitmap_y_write := y1 + ( py << scale ) + y2; bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            py = 0; ( x1, y1 ) = copycoordinates( x, y );
            while( py != max_pixels ) {
                px = 0;
                while( px != max_pixels ) {
                    y2 = 0;
                    while( y2 != maxcount ) {
                        x2 = 0;
                        while( x2 != maxcount ) {
                            bitmap_write = tilecharacter ? blit1tilemap.rdata0[4b1111 - xinblittile, 1] : characterGenerator8x8.rdata0[7 - xinchartile, 1];
                            x2 = x2 + 1;
                        }
                        y2 = y2 + 1;
                    }
                    px = px + 1;
                }
                py = py + 1;
            }
            busy = 0;
        }
    }
}



// COLOURBLIT - OUTPUT PIXELS TO BLIT A 16 x 16 TILE ( PARAM1 == 0 as 16 x 16, == 1 as 32 x 32, == 2 as 64 x 64, == 3 as 128 x 128 )
algorithm colourblittilebitmapwriter(
    // For setting  colourblit tile bitmaps
    input   uint6   colourblit_writer_tile,
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

    input   int11   x,
    input   int11   y,
    input   uint6   tile,
    input   uint2   scale,
    input   uint3   action,

    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint7   bitmap_colour_write,
    output  uint1   bitmap_write
) <autorun> {
    // POSITION IN TILE/CHARACTER
    uint7   px = uninitialized;
    uint7   py = uninitialized;

    // POSITION ON THE SCREEN AND WITHIN THE PIXEL COUNT FOR SCALING
    int11   x1 = uninitialized;
    int11   y1 = uninitialized;
    uint5   x2 = uninitialised;
    uint5   y2 = uninitialised;
    uint5   maxcount <:: ( 1 << scale );

    uint4   revx <:: 4b1111 - px[0,4];
    uint4   revy <:: 4b1111 - py[0,4];

    // tile bitmap addresses - handling rotation or reflection - find y and x positions, then concert to address
    uint4   yintile <:: action[2,1] ? ( action[0,2] == 2b00 ) ? py[0,4] :
                                        ( action[0,2] == 2b01 ) ? px[0,4] :
                                        ( action[0,2] == 2b10 ) ? revy :
                                        revx :
                                        action[1,1] ? revy :  py[0,4];
    uint4   xintile <:: action[2,1] ?  ( action[0,2] == 2b00 ) ? px[0,4] :
                                        ( action[0,2] == 2b01 ) ? revy :
                                        ( action[0,2] == 2b10 ) ? revx :
                                        py[0,4] :
                                        action[0,1] ? revx :  px[0,4];
    colourblittilemap.addr0 := { tile, yintile, xintile };

    bitmap_x_write := x1 + ( px << scale ) + x2;
    bitmap_y_write := y1 + ( py << scale ) + y2;
    bitmap_colour_write := colourblittilemap.rdata0;
    bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            px = 0; py = 0; x2 = 0; y2 = 0; ( x1, y1 ) = copycoordinates( x, y );
            while( ~py[4,1] ) {
                px = 0;
                while( ~px[4,1] ) {
                    x2 = 0;
                    while( x2 != maxcount ) {
                        y2 = 0;
                        while( y2 != maxcount ) {
                            bitmap_write = ~colourblittilemap.rdata0[6,1];
                            y2 = y2 + 1;
                        }
                        x2 = x2 + 1;
                    }
                    px = px + 1;
                }
                py = py + 1;
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

    input   int11   x,
    input   int11   y,
    input   int11   param0,
    input   uint7   param1,

    input   uint7   colour7,
    input   uint8   colour8r,
    input   uint8   colour8g,
    input   uint8   colour8b,
    input   uint2   newpixel,

    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint7   bitmap_colour_write,
    output  uint1   bitmap_write
) <autorun> {
    // POSITION ON THE SCREEN
    int11   x1 = uninitialised;
    int11   y1 = uninitialised;
    int11   max_x <:: x + param0;
    uint7   ignorecolour <:: param1;

    bitmap_x_write := x1;
    bitmap_y_write := y1;
    bitmap_write := ( ( newpixel == 1 ) & ( colour7 != ignorecolour ) ) | ( newpixel == 2 );
    bitmap_colour_write := ( newpixel == 1 ) ? colour7 : { 1b0, colour8r[6,2], colour8g[6,2], colour8b[6,2] };

    while(1) {
        if( start ) {
            busy = 1;
            x1 = x; y1 = y;
            while( busy ) {
                if( newpixel == 3 ) {
                    busy = 0;
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
    input   int11   xc,
    input   uint6   dx,
    input   int11   yc,
    input   uint6   dy,
    input   uint3   scale,
    input   uint3   action,
    output  int11   xdx,
    output  int11   ydy
) <autorun> {
    int11   deltax <:: { {11{dx[5,1]}}, dx };
    int11   deltay <:: { {11{dy[5,1]}}, dy };

    // SELECT SCALE
    int11   dodeltax <:: ( scale[2,1] ? ( __signed(deltax) >>> scale[0,2] ) : ( deltax << scale[0,2] ) );
    int11   dodeltay <:: ( scale[2,1] ? ( __signed(deltay) >>> scale[0,2] ) : ( deltay << scale[0,2] ) );

    // ADD PLUS
    int11   xcpdx <: xc + dodeltax;
    int11   xcndx <: xc - dodeltax;
    int11   ycpdy <: yc + dodeltay;
    int11   ycndy <: yc - dodeltay;

    always {
        if( action[2,1] ) {
            // ROTATION
            switch( action[0,2] ) {
                case 0: {
                    xdx = xcpdx;
                    ydy = ycpdy;
                }
                case 1: {
                    xdx = xc - dodeltay;
                    ydy = yc + dodeltax;
                }
                case 2: {
                    xdx = xcndx;
                    ydy = ycndy;
                }
                case 3: {
                    xdx = xc + dodeltay;
                    ydy = yc - dodeltax;
                }
            }
        } else {
            // REFLECTION
            xdx = action[0,1] ? xcndx : xcpdx;
            ydy = action[1,1] ? ycndy : ycpdy;
        }
    }
}
algorithm vertexwriter(
    // For setting vertices
    input   uint6   vertices_writer_block,
    input   uint4   vertices_writer_vertex,
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
    input   uint6   vector_block_number,
    input   int11   vector_block_xc,
    input   int11   vector_block_yc,
    input   uint3   vector_block_scale,
    input   uint3   vector_block_action,
    input   uint1   draw_vector,
    output  uint1   vector_block_active(0),

    // Communication with the GPU
    output  int11   gpu_x,
    output  int11   gpu_y,
    output  int11   gpu_param0,
    output  int11   gpu_param1,
    output  uint1   gpu_write,
    input   uint1   gpu_active
) <autorun> {
    // Add present deltas to the centres
    uint6   deltax <:: { vectorentry(vertex.rdata0).dxsign, vectorentry(vertex.rdata0).dx };
    uint6   deltay <:: { vectorentry(vertex.rdata0).dysign, vectorentry(vertex.rdata0).dy };
    centreplusdelta CENTREPLUSDELTA(
        xc <: vector_block_xc,
        yc <: vector_block_yc,
        dx <: deltax,
        dy <: deltay,
        scale <: vector_block_scale,
        action <: vector_block_action,
        xdx :> gpu_param0,
        ydy :> gpu_param1
    );

    // Vertices being processed, plus first coordinate of each line
    uint5 vertices_number = uninitialised;
    int11 start_x = uninitialised;
    int11 start_y = uninitialised;

    // Set read address for the vertices
    vertex.addr0 := { vector_block_number, vertices_number };

    gpu_write := 0; gpu_x := start_x; gpu_y := start_y;

    while(1) {
        if( draw_vector ) {
            vector_block_active = 1;
            vertices_number = 0;
            ++:
            // Start with the first vertex
            ( start_x, start_y ) = copycoordinates( gpu_param0, gpu_param1 );
            vertices_number = 1;
            ++:
            // Continue until an inactive or last vertex
            while( vectorentry(vertex.rdata0).active & ( vertices_number != 16 ) ) {
                // Move to the next vertex
                ++:
                // Dispatch line to GPU
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
