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

    simple_dualport_bram_port0 blit1tilemap,
    simple_dualport_bram_port0 characterGenerator8x8,
    simple_dualport_bram_port0 colourblittilemap,

    input   uint7   pb_colour7,
    input   uint8   pb_colour8r,
    input   uint8   pb_colour8g,
    input   uint8   pb_colour8b,
    input   uint2   pb_newpixel,

    input   uint7   vector_block_colour,
    input   int11   vector_drawer_gpu_x,
    input   int11   vector_drawer_gpu_y,
    input   int11   vector_drawer_gpu_param0,
    input   int11   vector_drawer_gpu_param1,
    input   uint1   vector_drawer_gpu_write,
    input   uint1   vector_block_active,

    output  uint1   queue_full(0),
    output  uint1   queue_complete(1),
    output  uint1   gpu_active
) <autorun,reginputs> {
    gpu GPU(
        blit1tilemap <:> blit1tilemap,
        characterGenerator8x8 <:> characterGenerator8x8,
        colourblittilemap <:> colourblittilemap,
        bitmap_x_write :> bitmap_x_write, bitmap_y_write :> bitmap_y_write,
        bitmap_colour_write :> bitmap_colour_write, bitmap_colour_write_alt :> bitmap_colour_write_alt,
        bitmap_write :> bitmap_write,
        gpu_active_dithermode :> gpu_active_dithermode,
        pb_colour7 <: pb_colour7, pb_colour8r <: pb_colour8r, pb_colour8g <: pb_colour8g, pb_colour8b <: pb_colour8b, pb_newpixel <: pb_newpixel,
        gpu_active :> gpu_active
    );

    // QUEUE STORAGE
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

    GPU.gpu_write := 0; queue_full := vector_block_active | queue_busy ; queue_complete := ~( gpu_active | queue_full );
    bitmap_crop_left := GPU.crop_left; bitmap_crop_right := GPU.crop_right; bitmap_crop_top := GPU.crop_top; bitmap_crop_bottom := GPU.crop_bottom;

    always {
        if( |gpu_write ) {
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
            GPU.gpu_dithermode = 0; GPU.gpu_colour = vector_block_colour; GPU.gpu_colour_alt = 0;
            GPU.gpu_x = vector_drawer_gpu_x; GPU.gpu_y = vector_drawer_gpu_y;
            GPU.gpu_param0 = vector_drawer_gpu_param0; GPU.gpu_param1 = vector_drawer_gpu_param1;
            GPU.gpu_param2 = 1; GPU.gpu_param3 = 0;
            GPU.crop_left = crop_left; GPU.crop_right = crop_right; GPU.crop_top = crop_top; GPU.crop_bottom = crop_bottom;
            GPU.gpu_write = 2;
        }
    }

    while(1) {
        if( |gpu_write ) {
            if( &gpu_write ) {
                // COMMAND QUEUE FOR QUADRILATERALS, SPLIT INTO TWO TRIANGLES THEN DISPATCH
                queue_busy = 1;
                while( gpu_active ) {}
                GPU.gpu_dithermode = queue_dithermode; GPU.gpu_colour = queue_colour; GPU.gpu_colour_alt = queue_colour_alt;
                GPU.gpu_x = queue_x; GPU.gpu_y = queue_y;
                GPU.gpu_param0 = queue_param0; GPU.gpu_param1 = queue_param1;
                GPU.gpu_param2 = queue_param2; GPU.gpu_param3 = queue_param3;
                GPU.crop_left = queue_cropL; GPU.crop_right = queue_cropR;
                GPU.crop_top = queue_cropT; GPU.crop_bottom = queue_cropB;
                GPU.gpu_write = 6; while( gpu_active ) {}
                // SECOND TRIANGLE
                GPU.gpu_param0 = queue_param4; GPU.gpu_param1 = queue_param5;
                GPU.gpu_write = 6;
                queue_busy = 0;
            } else {
                // COMMAND QUEUE, LATCH AND WAIT FOR GPU THEN DISPATCH
                queue_busy = 1;
                while( gpu_active ) {}
                GPU.gpu_colour = queue_colour; GPU.gpu_colour_alt = queue_colour_alt; GPU.gpu_dithermode = queue_dithermode;
                GPU.gpu_x = queue_x; GPU.gpu_y = queue_y;
                GPU.gpu_param0 = queue_param0; GPU.gpu_param1 = queue_param1;
                GPU.gpu_param2 = queue_param2; GPU.gpu_param3 = queue_param3;
                GPU.crop_left = queue_cropL; GPU.crop_right = queue_cropR; GPU.crop_top = queue_cropT; GPU.crop_bottom = queue_cropB;
                GPU.gpu_write = queue_write;
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
) <autorun,reginputs> {
    // GPU SUBUNITS
    rectangle GPUrectangle(
        crop_left <: crop_left, crop_right <: crop_right, crop_top <: crop_top, crop_bottom <: crop_bottom,
        x <: gpu_x, y <: gpu_y, x1 <: gpu_param0, y1 <: gpu_param1
    );
    line GPUline(
        x <: gpu_x, y <: gpu_y, x1 <: gpu_param0, y1 <: gpu_param1,
        width <: gpu_param2[0,8]
    );
    circle GPUcircle(
        x <: gpu_x, y <: gpu_y, radius <: gpu_param0, sectormask <: gpu_param1
    );
    triangle GPUtriangle(
        crop_left <: crop_left, crop_right <: crop_right, crop_top <: crop_top, crop_bottom <: crop_bottom,
        x <: gpu_x, y <: gpu_y, x1 <: gpu_param0, y1 <: gpu_param1, x2 <: gpu_param2, y2 <: gpu_param3
    );
    blit GPUblit(
        blit1tilemap <:> blit1tilemap,
        characterGenerator8x8 <:> characterGenerator8x8,
        x <: gpu_x, y <: gpu_y,
        tile <: gpu_param0[0,9], scale <: gpu_param1[0,2], action <: gpu_param2[0,3]
    );
    colourblit GPUcolourblit(
        colourblittilemap <:> colourblittilemap,
        x <: gpu_x, y <: gpu_y,
        tile <: gpu_param0[0,6], scale <: gpu_param1[0,2],  action <: gpu_param2[0,3]
    );
    pixelblock GPUpixelblock(
        x <: gpu_x, y <: gpu_y, width <: gpu_param0,
        ignorecolour <: gpu_param1, colour7 <: pb_colour7,
        colour8r <: pb_colour8r, colour8g <: pb_colour8g, colour8b <: pb_colour8b,
        newpixel <: pb_newpixel
    );

    // GPU UNIT BUSY FLAGS
    uint7   gpu_busy_flags <:: { GPUpixelblock.busy, GPUcolourblit.busy, GPUblit.busy, GPUtriangle.busy, GPUcircle.busy, GPUrectangle.busy, GPUline.busy };
    uint1   gpu_busy <: ( |gpu_busy_flags );

    // CONTROLS FOR BITMAP PIXEL WRITER AND GPU SUBUNITS
    bitmap_write := GPUline.bitmap_write | GPUrectangle.bitmap_write | GPUcircle.bitmap_write |
                                    GPUtriangle.bitmap_write | GPUblit.bitmap_write | GPUcolourblit.bitmap_write | GPUpixelblock.bitmap_write;

    GPUrectangle.start := 0; GPUline.start := 0; GPUcircle.start := 0; GPUtriangle.start := 0; GPUblit.start := 0; GPUcolourblit.start := 0; GPUpixelblock.start := 0;
    gpu_active := ( |gpu_write[1,3] ) | gpu_busy;

    always {
        switch( gpu_write ) {
            case 0: {}
            case 1: {
                // SET PIXEL (X,Y) NO GPU ACTIVATION
                gpu_active_dithermode = 0; bitmap_colour_write = gpu_colour; ( bitmap_x_write, bitmap_y_write ) = copycoordinates(  gpu_x, gpu_y ); bitmap_write = 1;
            }
            default: {
                // START THE GPU DRAWING UNIT - RESET DITHERMODE TO 0 (most common)
                gpu_active_dithermode = 0; bitmap_colour_write = gpu_colour; bitmap_colour_write_alt = gpu_colour_alt;
                switch( gpu_write ) {
                    default: {}
                    case 2: { GPUline.start = 1; }                                                                          // DRAW LINE FROM (X,Y) to (PARAM0,PARAM1)
                    case 3: { gpu_active_dithermode = gpu_dithermode; GPUrectangle.start = 1; }                             // DRAW RECTANGLE FROM (X,Y) to (PARAM0,PARAM1)
                    case 4: { GPUcircle.filledcircle = 0; GPUcircle.start = 1; }                                            // DRAW CIRCLE CENTRE (X,Y) with RADIUS PARAM0
                    case 5: { gpu_active_dithermode = gpu_dithermode; GPUcircle.filledcircle = 1; GPUcircle.start = 1; }    // DRAW FILLED CIRCLE CENTRE (X,Y) with RADIUS PARAM0
                    case 6: { gpu_active_dithermode = gpu_dithermode; GPUtriangle.start = 1; }                              // DRAW FILLED TRIANGLE WITH VERTICES (X,Y) (PARAM0,PARAM1) (PARAM2,PARAM3)
                    case 7: { GPUblit.tilecharacter = 1; GPUblit.start = 1; }                                               // BLIT 16 x 16 TILE PARAM0 TO (X,Y)
                    case 8: { GPUblit.tilecharacter = 0; GPUblit.start = 1; }                                               // BLIT 8 x 8 CHARACTER PARAM0 TO (X,Y) as 8 x 8
                    case 9: { GPUcolourblit.start = 1; }                                                                    // BLIT 16 x 16 COLOUR TILE PARAM0 TO (X,Y) as 16 x 16
                    case 10: { GPUpixelblock.start = 1; }                                                                   // START THE PIXELBLOCK WRITER AT (x,y) WITH WIDTH PARAM0, IGNORE COLOUR PARAM1
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
                case 0: { ( bitmap_x_write, bitmap_y_write ) = copycoordinates(  GPUline.bitmap_x_write, GPUline.bitmap_y_write ); }
                case 1: { ( bitmap_x_write, bitmap_y_write ) = copycoordinates(  GPUrectangle.bitmap_x_write, GPUrectangle.bitmap_y_write ); }
                case 2: { ( bitmap_x_write, bitmap_y_write ) = copycoordinates(  GPUcircle.bitmap_x_write, GPUcircle.bitmap_y_write ); }
                case 3: { ( bitmap_x_write, bitmap_y_write ) = copycoordinates(  GPUtriangle.bitmap_x_write, GPUtriangle.bitmap_y_write ); }
                case 4: { ( bitmap_x_write, bitmap_y_write ) = copycoordinates(  GPUblit.bitmap_x_write, GPUblit.bitmap_y_write ); }
                case 5: { ( bitmap_x_write, bitmap_y_write ) = copycoordinates(  GPUcolourblit.bitmap_x_write, GPUcolourblit.bitmap_y_write ); bitmap_colour_write = GPUcolourblit.bitmap_colour_write; }
                case 6: { ( bitmap_x_write, bitmap_y_write ) = copycoordinates(  GPUpixelblock.bitmap_x_write, GPUpixelblock.bitmap_y_write ); bitmap_colour_write = GPUpixelblock.bitmap_colour_write; }
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
    uint1   xcompareparam0 <:: ( x < param0 );          uint1   ycompareparam1 <:: ( y < param1 );
    int11   x1 <:: xcompareparam0 ? x : param0;         int11   y1 <:: ycompareparam1 ? y : param1;
    int11   x2 <:: xcompareparam0 ? param0 : x;         int11   y2 <:: ycompareparam1 ? param1 : y;

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
    uint9   x = uninitialized;                          uint9 xNEXT <:: x + 1;
    uint8   y = uninitialized;                          uint8 yNEXT <:: y + 1;

    bitmap_x_write := x; bitmap_y_write := y; bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            y = min_y;
            while( y != max_y ) {
                x = min_x;
                while( x != max_x ) {
                    bitmap_write = 1; x = xNEXT;
                }
                y = yNEXT;
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
    input   int11   x1,
    input   int11   y1,

    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun,reginputs> {
    preprectangle PREP(
        start <: start,
        crop_left <: crop_left, crop_right <: crop_right, crop_top <: crop_top, crop_bottom <: crop_bottom,
        x <: x, y <: y, param0 <: x1, param1 <: y1
    );

    drawrectangle RECTANGLE(
        min_x <: PREP.min_x, min_y <: PREP.min_y, max_x <: PREP.max_x, max_y <: PREP.max_y,
        bitmap_x_write :> bitmap_x_write, bitmap_y_write :> bitmap_y_write, bitmap_write :> bitmap_write,
        start <: PREP.todraw
    );

    busy := start | PREP.todraw | RECTANGLE.busy;
}

// LINE - OUTPUT PIXELS TO DRAW A LINE
algorithm prepline(
    input   uint1   start,
    output  uint1   todraw,
    input   int11   x,
    input   int11   y,
    input   int11   param0,
    input   int11   param1,
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
                x1 = x; y1 = y; dv = ylessparam1;
            } else {
                x1 = param0; y1 = param1; dv = ~ylessparam1;
            }

            // Absolute DELTAs
            ( dx ) = absdelta( x, param0 ); ( dy ) = absdelta( y, param1 );

            // Numerator
            if( dx > dy ) {
                numerator = ( dx >> 1 ); max_count = dx + 1;
            } else {
                numerator = -( dy >> 1 ); max_count = dy + 1;
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
    int11   x = uninitialized;                          int11   xNEXT <:: x + n2dx;
    int11   y = uninitialized;                          int11   yNEXT <:: n2dy ? (y + ( dv ? 1 : -1 )) : y;
    int11   numerator = uninitialized;
    int11   numerator2 <:: numerator;                   int11   newnumerator <:: numerator - ( n2dx ? dy : 0 ) + ( n2dy ? dx : 0 );
    uint1   n2dx <:: numerator2 > (-dx);                uint1   n2dy <:: numerator2 < dy;
    uint1   dxdy <:: dx > dy;
    int11   count = uninitialized;                      int11   countNEXT <:: count + 1;
    int11   offset_x = uninitialised;                   int11   offset_xNEXT <:: offset_y + dxdy;
    int11   offset_y = uninitialised;                   int11   offset_yNEXT <:: offset_x + ~dxdy;
    int11   offset_start <:: -( width >> 1 );
    uint8   pixel_count = uninitialised;                uint8   pixel_countNEXT <:: pixel_count + 1;

    bitmap_x_write := x + offset_x; bitmap_y_write := y + offset_y; bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;  x = start_x; y = start_y; numerator = start_numerator; count = 0;
            while( count != max_count ) {
                pixel_count = 0; offset_x = dxdy ? 0 : offset_start; offset_y = dxdy ? offset_start : 0;
                while( pixel_count != width ) {
                    bitmap_write = 1; offset_y = offset_xNEXT; offset_x = offset_yNEXT; pixel_count = pixel_countNEXT;
                }
                numerator = newnumerator; x = xNEXT; y = yNEXT; count = countNEXT;
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
    input   int11   x1,
    input   int11   y1,
    input   uint8   width,
    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun,reginputs> {
    prepline PREP(
        start <: start,
        x <: x, y <: y, param0 <: x1, param1 <: y1
    );
    drawline LINE(
        start_x <: PREP.x1, start_y <: PREP.y1,
        start_numerator <: PREP.numerator,
        dx <: PREP.dx, dy <: PREP.dy, dv <: PREP.dv,
        max_count <: PREP.max_count, width <: width,
        bitmap_x_write :> bitmap_x_write, bitmap_y_write :> bitmap_y_write,
        bitmap_write :> bitmap_write,
        start <: PREP.todraw
    );
    busy := start | PREP.todraw | LINE.busy;
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
    int11   numerator = uninitialised;                  int11   new_numerator <:: numerator[10,1] ? numerator + { active_x, 2b00 } + 6 : numerator + { (active_x - active_y), 2b00 } + 10;
    uint1   positivenumerator <:: ~numerator[10,1] & ( |numerator );
    int11   active_x = uninitialized;                   int11   active_xNEXT <:: active_x + 1;
    int11   active_y = uninitialized;                   int11   active_yNEXT <:: active_y - positivenumerator;
    int11   count = uninitialised;                      int11   countNEXT <:: filledcircle ? count - 1 : min_count;
    int11   min_count = uninitialised;                  int11   min_countNEXT <:: min_count + 1;
    uint1   drawingcircle <:: ( active_y >= active_x ); uint1   drawingsegment <:: ( count != min_count );

    // PLUS OR MINUS OFFSETS
    int11   xcpax <:: xc + active_x;                    int11   xcnax <:: xc - active_x;
    int11   xcpc <:: xc + count;                        int11   xcnc <:: xc - count;
    int11   ycpax <:: yc + active_x;                    int11   ycnax <:: yc - active_x;
    int11   ycpc <:: yc + count;                        int11   ycnc <:: yc - count;

    bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            active_x = 0; active_y = radius; count = radius; min_count = (-1); numerator = start_numerator;
            while( drawingcircle ) {
                while( drawingsegment ) {
                    // OUTPUT PIXELS IN THE 8 SEGMENTS/ARCS AS PER MASK
                    bitmap_x_write = xcpax; bitmap_y_write = ycpc;      if( draw_sectors[0,1] ) { bitmap_write = 1; ++: }
                    bitmap_y_write = ycnc;                              if( draw_sectors[1,1] ) { bitmap_write = 1; ++: }
                    bitmap_x_write = xcnax;                             if( draw_sectors[2,1] ) { bitmap_write = 1; ++: }
                    bitmap_y_write = ycpc;                              if( draw_sectors[3,1] ) { bitmap_write = 1; ++: }
                    bitmap_x_write = xcpc; bitmap_y_write = ycpax;      if( draw_sectors[4,1] ) { bitmap_write = 1; ++: }
                    bitmap_y_write = ycnax;                             if( draw_sectors[5,1] ) { bitmap_write = 1; ++: }
                    bitmap_x_write = xcnc;                              if( draw_sectors[6,1] ) { bitmap_write = 1; ++: }
                    bitmap_y_write = ycpax;                             if( draw_sectors[7,1] ) { bitmap_write = 1; }
                    count = countNEXT;
                }
                active_x = active_xNEXT; active_y = active_yNEXT; count = active_y; min_count = min_countNEXT; numerator = new_numerator;
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
    input   int11   radius,
    input   uint8   sectormask,
    input   uint1   filledcircle,

    output  int11  bitmap_x_write,
    output  int11  bitmap_y_write,
    output  uint1  bitmap_write
) <autorun,reginputs> {
    int11   absradius <:: radius[10,1] ? -radius : radius;
    int11   gpu_numerator <:: 3 - ( { absradius, 1b0 } );
    uint8   draw_sectors <:: { sectormask[5,1], sectormask[6,1], sectormask[1,1], sectormask[2,1], sectormask[4,1], sectormask[7,1], sectormask[0,1], sectormask[3,1] };

    drawcircle CIRCLE(
        xc <: x, yc <: y,
        radius <: absradius,
        start_numerator <: gpu_numerator,
        draw_sectors <: draw_sectors,
        filledcircle <: filledcircle,
        bitmap_x_write :> bitmap_x_write, bitmap_y_write :> bitmap_y_write, bitmap_write :> bitmap_write,
        start <: start
    );
    busy := start | CIRCLE.busy;
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
            if( ( y2 != y1 ) & ( y3 >= y2 ) & ( x2 < x3 ) ) { tx = x2; ty = y2; x2 = x3; y2 = y3; x3 = tx; y3 = ty; ++:}

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
    uint1   rightleft <:: ( max_x - px ) < ( px - min_x );

    // WORK COORDINATES AND DIRECTION
    int11   px = uninitialized;                         int11   pxNEXT <:: px + ( dx ? 1 : (-1) );
    int11   py = uninitialized;                         int11   pyNEXT <:: py + 1;
    uint1   dx = uninitialized;
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
                if( beenInTriangle ^ inTriangle ) {
                    // Exited the triangle, move to the next line
                    beenInTriangle = 0; py = pyNEXT; px = rightleft ? max_x : min_x; dx = ~rightleft;
                } else {
                    // MOVE TO THE NEXT PIXEL ON THE LINE LEFT/RIGHT OR DOWN AND SWITCH DIRECTION IF AT END
                    if( stillinline ) { px = pxNEXT; } else { dx = ~dx; beenInTriangle = 0; py = pyNEXT; }
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
    input   int11   x1,
    input   int11   y1,
    input   int11   x2,
    input   int11   y2,
    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun,reginputs> {
    // VERTEX COORDINATES AND BOUNDING BOX
    preptriangle PREP(
        start <: start,
        crop_left <: crop_left, crop_right <: crop_right, crop_top <: crop_top, crop_bottom <: crop_bottom,
        x <: x, y <: y, param0 <: x1, param1 <: y1, param2 <: x2, param3 <: y2
    );

    uint1   TRIANGLEbusy = uninitialised;
    drawtriangle TRIANGLE(
        min_x <: PREP.min_x, max_x <: PREP.max_x, min_y <: PREP.min_y, max_y <: PREP.max_y,
        x0 <: PREP.x1, y0 <: PREP.y1, x1 <: PREP.x2, y1 <: PREP.y2, x2 <: PREP.x3, y2 <: PREP.y3,
        bitmap_x_write :> bitmap_x_write, bitmap_y_write :> bitmap_y_write, bitmap_write :> bitmap_write,
        start <: PREP.todraw
    );

    busy := start | PREP.busy | PREP.todraw | TRIANGLE.busy;
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
) <autorun,reginputs> {
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
) <autorun,reginputs> {
    // START POSITION ON THE SCREEN, POSITION IN TILE/CHARACTER AND PIXEL COUNT FOR SCALING
    int11   x1 = uninitialized;
    int11   y1 = uninitialized;
    uint7   px = uninitialized;                         uint7   pxNEXT <:: px + 1;
    uint7   py = uninitialized;                         uint7   pyNEXT <:: py + 1;
    uint5   x2 = uninitialised;                         uint5   x2NEXT <:: x2 + 1;
    uint5   y2 = uninitialised;                         uint5   y2NEXT <:: y2 + 1;
    uint5   maxcount <:: ( 1 << scale );

    // MULTIPLIER FOR THE SIZE
    uint5   max_pixels <:: tilecharacter ? 16 : 8;

    // tile and character bitmap addresses
    // tile bitmap and charactermap addresses - handling rotation or reflection - find y and x positions, then concert to address
    uint4   revx4 <:: 4b1111 - px[0,4];
    uint4   revy4 <:: 4b1111 - py[0,4];
    uint3   revx3 <:: 3b111 - px[0,3];
    uint3   revy3 <:: 3b111 - py[0,3];

    uint1   action00 <:: ( ~|action[0,2] );
    uint1   action01 <:: ( action[0,2] == 2b01 );
    uint1   action10 <:: ( action[0,2] == 2b10 );

    uint4   yinblittile <:: action[2,1] ? action00 ? py[0,4] :
                                        action01 ? px[0,4] :
                                        action10 ? revy4 : revx4 :
                                        action[1,1] ? revy4 :  py[0,4];
    uint4   xinblittile <:: 15 - ( action[2,1] ?  action00 ? px[0,4] :
                                        action01 ? revy4 :
                                        action10 ? revx4 : py[0,4] :
                                        action[0,1] ? revx4 :  px[0,4] );
    uint3   yinchartile <:: action[2,1] ? action00 ? py[0,3] :
                                        action01 ? px[0,3] :
                                        action10 ? revy3 : revx3 :
                                        action[1,1] ? revy3 :  py[0,3];
    uint3   xinchartile <:: 7 - ( action[2,1] ?  action00 ? px[0,3] :
                                        action01 ? revy3 :
                                        action10 ? revx3 : py[0,3] :
                                        action[0,1] ? revx3 :  px[0,3] );
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
                            bitmap_write = tilecharacter ? blit1tilemap.rdata0[xinblittile, 1] : characterGenerator8x8.rdata0[xinchartile, 1];
                            x2 = x2NEXT;
                        }
                        y2 = y2NEXT;
                    }
                    px = pxNEXT;
                }
                py = pyNEXT;
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
) <autorun,reginputs> {
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
) <autorun,reginputs> {
    // START POSITION ON THE SCREEN, POSITION IN TILE/CHARACTER AND PIXEL COUNT FOR SCALING
    int11   x1 = uninitialized;
    int11   y1 = uninitialized;
    uint7   px = uninitialized;                         uint7   pxNEXT <:: px + 1;
    uint7   py = uninitialized;                         uint7   pyNEXT <:: py + 1;
    uint5   x2 = uninitialised;                         uint5   x2NEXT <:: x2 + 1;
    uint5   y2 = uninitialised;                         uint5   y2NEXT <:: y2 + 1;
    uint5   maxcount <:: ( 1 << scale );

    uint4   revx <:: 4b1111 - px[0,4];
    uint4   revy <:: 4b1111 - py[0,4];

    uint1   action00 <:: ( ~|action[0,2] );
    uint1   action01 <:: ( action[0,2] == 2b01 );
    uint1   action10 <:: ( action[0,2] == 2b10 );

    // tile bitmap addresses - handling rotation or reflection - find y and x positions, then concert to address
    uint4   yintile <:: action[2,1] ? action00 ? py[0,4] :
                                        action01 ? px[0,4] :
                                        action10 ? revy : revx :
                                        action[1,1] ? revy :  py[0,4];
    uint4   xintile <:: action[2,1] ?  action00 ? px[0,4] :
                                        action01 ? revy :
                                        action10 ? revx : py[0,4] :
                                        action[0,1] ? revx :  px[0,4];
    colourblittilemap.addr0 := { tile, yintile, xintile };

    bitmap_x_write := x1 + ( px << scale ) + x2; bitmap_y_write := y1 + ( py << scale ) + y2; bitmap_colour_write := colourblittilemap.rdata0;  bitmap_write := 0;

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
                        while( y2 != maxcount ) { bitmap_write = ~colourblittilemap.rdata0[6,1]; y2 = y2NEXT; }
                        x2 = x2NEXT;
                    }
                    px = pxNEXT;
                }
                py = pyNEXT;
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
    input   int11   width,
    input   uint7   ignorecolour,

    input   uint7   colour7,
    input   uint8   colour8r,
    input   uint8   colour8g,
    input   uint8   colour8b,
    input   uint2   newpixel,

    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint7   bitmap_colour_write,
    output  uint1   bitmap_write
) <autorun,reginputs> {
    // POSITION ON THE SCREEN
    int11   x1 = uninitialised;                         int11   x1NEXT <:: x1 + 1;
    int11   y1 = uninitialised;                         int11   y1NEXT <:: y1 + 1;
    int11   max_x <:: x + width;

    bitmap_x_write := x1; bitmap_y_write := y1; bitmap_write := ( ( newpixel == 1 ) & ( colour7 != ignorecolour ) ) | ( newpixel == 2 );
    bitmap_colour_write := ( newpixel == 1 ) ? colour7 : { 1b0, colour8r[6,2], colour8g[6,2], colour8b[6,2] };

    while(1) {
        if( start ) {
            busy = 1;
            x1 = x; y1 = y;
            while( busy ) {
                if( &newpixel ) { busy = 0; }
                if( x1 != max_x ) {
                    if( |newpixel ) { x1 = x1NEXT; }
                } else {
                    x1 = x; y1 = y1NEXT;
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

// SIGN EXTEND 6 BIT DELTA TO 11 BIT
algorithm vdeltasignextend(
    input   uint6   d,
    output  int11   delta
) <autorun> {
    always {
        delta = { {11{d[5,1]}}, d };
    }
}
// SCALE A DELTA USING THE SCALE ATTRIBUTE
algorithm scaledetla(
    input   uint3   scale,
    input   int11   delta,
    output  int11   scaled
) <autorun> {
    always {
        scaled = ( scale[2,1] ? ( __signed(delta) >>> scale[0,2] ) : ( delta << scale[0,2] ) );
    }
}
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
    // SIGN EXTEND DELTAS AND APPLY SCALE
    vdeltasignextend DX( d <: dx ); vdeltasignextend DY( d <: dy );
    scaledetla SDX( scale <: scale, delta <: DX.delta ); scaledetla SDY( scale <: scale, delta <: DY.delta );

    // PLUS OR MINUS SCALE
    int11   xcpdx <:: xc + SDX.scaled;                  int11   xcndx <:: xc - SDX.scaled;
    int11   ycpdy <:: yc + SDY.scaled;                  int11   ycndy <:: yc - SDY.scaled;
    int11   xcpdy <:: xc + SDY.scaled;                  int11   xcndy <:: xc - SDY.scaled;
    int11   ycpdx <:: yc + SDX.scaled;                  int11   ycndx <:: yc - SDX.scaled;

    always {
        if( action[2,1] ) {
            // ROTATION
            switch( action[0,2] ) {
                case 0: { xdx = xcpdx; ydy = ycpdy; }
                case 1: { xdx = xcndy; ydy = ycpdx; }
                case 2: { xdx = xcndx; ydy = ycndy; }
                case 3: { xdx = xcpdy; ydy = ycndx; }
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
) <autorun,reginputs> {
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
) <autorun,reginputs> {
    // Add deltas to the centres
    centreplusdelta CENTREPLUSDELTA(
        xc <: vector_block_xc, yc <: vector_block_yc,
        dx <: vectorentry(vertex.rdata0).dx, dy <: vectorentry(vertex.rdata0).dy,
        scale <: vector_block_scale, action <: vector_block_action,
        xdx :> gpu_param0, ydy :> gpu_param1
    );

    // Vertices being processed, plus first coordinate of each line
    uint5   vertex = uninitialised;                     uint5   vertexNEXT <:: vertex + 1;
    uint1   working <:: vectorentry(vertex.rdata0).active & ( ~vertex[4,1] );

    // Set read address for the vertices
    vertex.addr0 := { vector_block_number, vertex };

    gpu_write := 0;

    while(1) {
        if( draw_vector ) {
            vector_block_active = 1;
            vertex = 0;
            ++:
            // Start with the first vertex
            ( gpu_x, gpu_y ) = copycoordinates( gpu_param0, gpu_param1 );
            vertex = 1;
            ++:
            // Continue until an inactive or last vertex
            while( working ) {
                // Move to the next vertex
                ++:
                // Dispatch line to GPU
                while( gpu_active ) {} gpu_write = 1;
                ++:
                // Move onto the next vertex
                ( gpu_x, gpu_y ) = copycoordinates( gpu_param0, gpu_param1 );
                vertex = vertexNEXT;
            }
            vector_block_active = 0;
        }
    }
}
