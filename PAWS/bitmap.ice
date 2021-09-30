algorithm bitmap(
    simple_dualport_bram_port0 bitmap_0A,
    simple_dualport_bram_port0 bitmap_1A,
    simple_dualport_bram_port0 bitmap_0R,
    simple_dualport_bram_port0 bitmap_1R,
    simple_dualport_bram_port0 bitmap_0G,
    simple_dualport_bram_port0 bitmap_1G,
    simple_dualport_bram_port0 bitmap_0B,
    simple_dualport_bram_port0 bitmap_1B,
    input   uint1   framebuffer,
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel,
    output! uint1   bitmap_display,

    // Pixel reader
    input   int11   bitmap_x_read,
    input   int11   bitmap_y_read,
    output  uint7   bitmap_colour_read
) <autorun> {
    // Pixel x and y fetching 1 in advance due to bram latency
    uint9   x_plus_one <: pix_x[1,9] + pix_x[0,1];
    uint8   y_line <: pix_vblank ? 0 : pix_y[1,9];
    uint9   x_pixel <: pix_active ? x_plus_one : 0;

    uint17  address <: y_line * 320 + x_pixel;

    // Pixel being read?
    bitmap_colour_read := ( pix_x[1,9] == bitmap_x_read ) & ( pix_y[1,9] == bitmap_y_read ) ?
                            ( framebuffer ? { bitmap_1A.rdata0, bitmap_1R.rdata0, bitmap_1G.rdata0, bitmap_1B.rdata0 } : { bitmap_0A.rdata0, bitmap_0R.rdata0, bitmap_0G.rdata0, bitmap_0B.rdata0 } )
                            : bitmap_colour_read;

    // Setup the address in the bitmap for the pixel being rendered
    // Use pre-fetching of the next pixel ready for the next cycle
    // y_line * 320 + x_pixel
    bitmap_0A.addr0 := address; bitmap_0R.addr0 := address; bitmap_0G.addr0 := address; bitmap_0B.addr0 := address;
    bitmap_1A.addr0 := address; bitmap_1R.addr0 := address; bitmap_1G.addr0 := address; bitmap_1B.addr0 := address;

    // RENDER - Default to transparent
    bitmap_display := pix_active & ~( framebuffer ? bitmap_1A.rdata0 : bitmap_0A.rdata0 );
    pixel := framebuffer ? { bitmap_1R.rdata0, bitmap_1G.rdata0, bitmap_1B.rdata0 } : { bitmap_0R.rdata0, bitmap_0G.rdata0, bitmap_0B.rdata0 };
}

algorithm bitmapwriter(
    // GPU Parameters
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

    // CROP RECTANGLE
    input   uint9   crop_left,
    input   uint9   crop_right,
    input   uint8   crop_top,
    input   uint8   crop_bottom,

    // For setting blit1 tile bitmaps
    input   uint5   blit1_writer_tile,
    input   uint4   blit1_writer_line,
    input   uint16  blit1_writer_bitmap,

    // For setting character generator bitmaps
    input   uint8   character_writer_character,
    input   uint3   character_writer_line,
    input   uint8   character_writer_bitmap,

    // For set colourblit tile bitmaps
    input   uint5   colourblit_writer_tile,
    input   uint4   colourblit_writer_line,
    input   uint4   colourblit_writer_pixel,
    input   uint7   colourblit_writer_colour,

    // Colours for the pixelblock
    input   uint7   pb_colour7,
    input   uint8   pb_colour8r,
    input   uint8   pb_colour8g,
    input   uint8   pb_colour8b,
    input   uint2   pb_newpixel,

    // VECTOR BLOCK
    input   uint5   vector_block_number,
    input   uint7   vector_block_colour,
    input   int11   vector_block_xc,
    input   int11   vector_block_yc,
    input   uint3   vector_block_scale,
    input   uint3   vector_block_action,
    input   uint1   draw_vector,
    // For setting vertices
    input   uint5   vertices_writer_block,
    input   uint6   vertices_writer_vertex,
    input   int6    vertices_writer_xdelta,
    input   int6    vertices_writer_ydelta,
    input   uint1   vertices_writer_active,

    output  uint1   gpu_queue_full,
    output  uint1   gpu_queue_complete,
    output  uint1   vector_block_active,

    input   uint1   static1bit,
    input   uint6   static6bit,

    // BITMAP TO WRITE
    input   uint1   framebuffer,
    simple_dualport_bram_port1 bitmap_0A,
    simple_dualport_bram_port1 bitmap_1A,
    simple_dualport_bram_port1 bitmap_0R,
    simple_dualport_bram_port1 bitmap_1R,
    simple_dualport_bram_port1 bitmap_0G,
    simple_dualport_bram_port1 bitmap_1G,
    simple_dualport_bram_port1 bitmap_0B,
    simple_dualport_bram_port1 bitmap_1B,
) <autorun> {
    // From GPU to set a pixel
    int11   bitmap_x_write = uninitialized;
    int11   bitmap_y_write = uninitialized;
    uint9   bitmap_crop_left = uninitialised;
    uint9   bitmap_crop_right = uninitialised;
    uint8   bitmap_crop_top = uninitialised;
    uint8   bitmap_crop_bottom = uninitialised;
    uint7   bitmap_colour_write = uninitialized;
    uint7   bitmap_colour_write_alt = uninitialized;
    uint4   dithermode = uninitialized;
    uint1   bitmap_write = uninitialized;
    gpu_queue QUEUE(
        bitmap_x_write :> bitmap_x_write,
        bitmap_y_write :> bitmap_y_write,
        bitmap_crop_left :> bitmap_crop_left,
        bitmap_crop_right :> bitmap_crop_right,
        bitmap_crop_top :> bitmap_crop_top,
        bitmap_crop_bottom :> bitmap_crop_bottom,
        bitmap_colour_write :> bitmap_colour_write,
        bitmap_colour_write_alt :> bitmap_colour_write_alt,
        bitmap_write :> bitmap_write,
        gpu_active_dithermode :> dithermode,
        crop_left <: crop_left,
        crop_right <: crop_right,
        crop_top <: crop_top,
        crop_bottom <: crop_bottom,
        gpu_x <: gpu_x,
        gpu_y <: gpu_y,
        gpu_colour <: gpu_colour,
        gpu_colour_alt <: gpu_colour_alt,
        gpu_param0 <: gpu_param0,
        gpu_param1 <: gpu_param1,
        gpu_param2 <: gpu_param2,
        gpu_param3 <: gpu_param3,
        gpu_param4 <: gpu_param4,
        gpu_param5 <: gpu_param5,
        gpu_write <: gpu_write,
        gpu_dithermode <: gpu_dithermode,
        blit1_writer_tile <: blit1_writer_tile,
        blit1_writer_line <: blit1_writer_line,
        blit1_writer_bitmap <: blit1_writer_bitmap,
        character_writer_character <: character_writer_character,
        character_writer_line <: character_writer_line,
        character_writer_bitmap <: character_writer_bitmap,
        colourblit_writer_tile <: colourblit_writer_tile,
        colourblit_writer_line <: colourblit_writer_line,
        colourblit_writer_pixel <: colourblit_writer_pixel,
        colourblit_writer_colour <: colourblit_writer_colour,
        pb_colour7 <: pb_colour7,
        pb_colour8r <: pb_colour8r,
        pb_colour8g <: pb_colour8g,
        pb_colour8b <: pb_colour8b,
        pb_newpixel <: pb_newpixel,
        vector_block_number <: vector_block_number,
        vector_block_colour <: vector_block_colour,
        vector_block_xc <: vector_block_xc,
        vector_block_yc <: vector_block_yc,
        vector_block_scale <: vector_block_scale,
        vector_block_action <: vector_block_action,
        draw_vector <: draw_vector,
        vertices_writer_block <: vertices_writer_block,
        vertices_writer_vertex <: vertices_writer_vertex,
        vertices_writer_xdelta <: vertices_writer_xdelta,
        vertices_writer_ydelta <: vertices_writer_ydelta,
        vertices_writer_active <: vertices_writer_active,
        vector_block_active :> vector_block_active,
        queue_full :> gpu_queue_full,
        queue_complete :> gpu_queue_complete
    );

    uint1   condition = uninitialised;
    uint7   pixeltowrite = uninitialised;
    dither DODITHER(
        bitmap_x_write <: bitmap_x_write,
        bitmap_y_write <: bitmap_y_write,
        dithermode <: dithermode,
        static1bit <: static1bit,
        condition :> condition
    );

    // Write in range?
    uint1 write_pixel <:: ( bitmap_x_write >= bitmap_crop_left ) & ( bitmap_x_write <= bitmap_crop_right ) & ( bitmap_y_write >= bitmap_crop_top ) & ( bitmap_y_write <= bitmap_crop_bottom ) & bitmap_write;

    // Bitmap write access for the GPU
    uint17  address <:: bitmap_y_write[0,8] * 320 + bitmap_x_write[0,9];
    bitmap_0A.wenable1 := 1; bitmap_0R.wenable1 := 1; bitmap_0G.wenable1 := 1; bitmap_0B.wenable1 := 1;
    bitmap_1A.wenable1 := 1; bitmap_1R.wenable1 := 1; bitmap_1G.wenable1 := 1; bitmap_1B.wenable1 := 1;

    always {
        if( write_pixel ) {
            // SELECT ACTUAL COLOUR
            switch( dithermode ) {
                case 14: { pixeltowrite = static6bit; }
                default: { pixeltowrite = condition ? bitmap_colour_write : bitmap_colour_write_alt; }
            }
            // SET PIXEL ADDRESSS bitmap_y_write * 320 + bitmap_x_write
            if( framebuffer ) {
                bitmap_1A.addr1 = address; bitmap_1A.wdata1 = pixeltowrite[6,1];
                bitmap_1R.addr1 = address; bitmap_1R.wdata1 = pixeltowrite[4,2];
                bitmap_1G.addr1 = address; bitmap_1G.wdata1 = pixeltowrite[2,2];
                bitmap_1B.addr1 = address; bitmap_1B.wdata1 = pixeltowrite[0,2];
            } else {
                bitmap_0A.addr1 = address; bitmap_0A.wdata1 = pixeltowrite[6,1];
                bitmap_0R.addr1 = address; bitmap_0R.wdata1 = pixeltowrite[4,2];
                bitmap_0G.addr1 = address; bitmap_0G.wdata1 = pixeltowrite[2,2];
                bitmap_0B.addr1 = address; bitmap_0B.wdata1 = pixeltowrite[0,2];
            }
        }
    }
}

algorithm dither(
    input   uint9   bitmap_x_write,
    input   uint8   bitmap_y_write,
    input   uint4   dithermode,
    input   uint1   static1bit,
    output! uint1   condition
) <autorun> {
    always {
        // DITHER PATTERNS
        // == 0 SOLID == 1 SMALL CHECKERBOARD == 2 MED CHECKERBOARD == 3 LARGE CHECKERBOARD
        // == 4 VERTICAL STRIPES == 5 HORIZONTAL STRIPES == 6 CROSSHATCH == 7 LEFT SLOPE
        // == 8 RIGHT SLOPE == 9 LEFT TRIANGLE == 10 RIGHT TRIANGLE == 11 ENCLOSED
        // == 12 OCTRAGON == 13 BRICK == 14 COLOUR STATIC == 15 STATIC
        switch( dithermode ) {
            case 0: { condition = 1; }                                                                          // SOLID
            default: { condition = ( bitmap_x_write[dithermode - 1,1] == bitmap_y_write[dithermode - 1,1] ); }  // CHECKERBOARDS 1 2 AND 3
            case 4: { condition = bitmap_x_write[0,1]; }                                                        // VERTICAL STRIPES
            case 5: { condition = bitmap_y_write[0,1]; }                                                        // HORIZONTAL STRIPES
            case 6: { condition = ( bitmap_x_write[0,1] | bitmap_y_write[0,1] ); }                              // CROSSHATCH
            case 7: { condition = ( bitmap_x_write[0,2] == bitmap_y_write[0,2] ); }                             // LEFT SLOPE
            case 8: { condition = ( bitmap_x_write[0,2] == ~bitmap_y_write[0,2] ); }                            // RIGHT SLOPE
            case 9: {                                                                                           // LEFT TRIANGLE
                switch( bitmap_y_write[0,2] ) {
                    case 2b00: { condition = ( bitmap_x_write[0,2] == 2b00 ); }
                    case 2b01: { condition = ( ~bitmap_x_write[1,1] ); }
                    case 2b10: { condition = ( bitmap_x_write[0,2] != 2b11 ); }
                    case 2b11: { condition = 1; }
                }
            }
            case 10: {                                                                                          // RIGHT TRIANGLE
                switch( bitmap_y_write[0,2] ) {
                    case 2b00: { condition = ( bitmap_x_write[0,2] == 2b11 ); }
                    case 2b01: { condition = ( bitmap_x_write[1,1] ); }
                    case 2b10: { condition = ( bitmap_x_write[0,2] != 2b00 ); }
                    case 2b11: { condition = 1; }
                }
            }
            case 11: {                                                                                          // ENCLOSED
                if( bitmap_y_write[0,1] ^ bitmap_y_write[1,1] ) {
                    condition = ( bitmap_x_write[0,1] == bitmap_x_write[1,1] );
                } else {
                    condition = 1;
                }
            }
            case 12: {                                                                                          // OCTAGON
                if( bitmap_y_write[0,1] ^ bitmap_y_write[1,1] ) {
                    condition = ( bitmap_x_write[0,1] == bitmap_x_write[1,1] );
                } else {
                    condition = 1;
                }
            }
            case 13: {                                                                                          // BRICK
                if( bitmap_y_write[0,2] == 2b00) {
                    condition = 1;
                } else {
                    condition = ( bitmap_x_write[0,2] == { bitmap_y_write[2,1], 1b0 } );
                }
            }
            case 14: { condition = 1; }                                                                         // COLOUR STATIC
            case 15: { condition = static1bit; }                                                                // STATIC
        }
    }
}
