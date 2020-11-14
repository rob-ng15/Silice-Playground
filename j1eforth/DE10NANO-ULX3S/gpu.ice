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
    input   uint1   vertices_writer_write,

    output  uint1   vector_block_active,

    // Communication with the GPU
    output  int11 gpu_x,
    output  int11 gpu_y,
    output  uint7 gpu_colour,
    output  int11 gpu_param0,
    output  int11 gpu_param1,
    output  uint4 gpu_write,

    input  uint1 gpu_active
) <autorun> {
    // 32 vector blocks each of 16 vertices
    dualport_bram uint13 vertex[512] = uninitialised;

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
    vertex.wenable0 := 0;
    vertex.wenable1 := 1;

    gpu_write := 0;

    vector_block_active = 0;
    vertices_number = 0;

    while(1) {
        if( vertices_writer_write ) {
            vertex.addr1 = vertices_writer_block * 16 + vertices_writer_vertex;
            vertex.wdata1 = { vertices_writer_active, vertices_writer_xdelta, vertices_writer_ydelta };
        }

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
                gpu_x = start_x;
                gpu_y = start_y;
                gpu_param0 = vector_block_xc + deltax;
                gpu_param1 = vector_block_yc + deltay;

                while( gpu_active ) {}

                gpu_write = 3;

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

// Display List
// Stores GPU or VECTOR commands
// Each display list entry consists of:
//      active
//      command ( 1 - 7 copy details across to the GPU )
//      x y p0 p1 p2 p3 parameters for the GPU command

bitfield dlentry {
    uint1   active,
    uint4   command,
    uint7   colour,
    uint11  x,
    uint11  y,
    uint11  p0,
    uint11  p1,
    uint11  p2,
    uint11  p3
}

algorithm displaylist(
    input   uint5   start_entry,
    input   uint5   finish_entry,
    input   uint1   start_displaylist,
    output  uint1   display_list_active,

    input   uint5   writer_entry_number,
    input   uint1   writer_active,
    input   uint4   writer_command,
    input   uint7   writer_colour,
    input   uint11  writer_x,
    input   uint11  writer_y,
    input   uint11  writer_p0,
    input   uint11  writer_p1,
    input   uint11  writer_p2,
    input   uint11  writer_p3,
    input   uint4   writer_write,

    // Communication with the GPU
    output int11   gpu_x,
    output int11   gpu_y,
    output uint7   gpu_colour,
    output int11   gpu_param0,
    output int11   gpu_param1,
    output int11   gpu_param2,
    output int11   gpu_param3,
    output uint4   gpu_write,
    input  uint1   gpu_active,
) {
    // 32 display list entries
    dualport_bram uint78 dlentries[32] = uninitialised;

    uint5   entry_number = uninitialised;
    uint5   finish_number = uninitialised;

    // Set read address for the display list entry being processed
    dlentries.addr0 := entry_number;
    dlentries.wenable0 := 0;
    dlentries.wenable1 := 1;

    // Dispatch to the GPU
    gpu_write = 0;

    while(1) {
        switch( writer_write ) {
            case 1: {
                dlentries.addr1 = writer_entry_number;
                dlentries.wdata1 = { writer_active, writer_command, writer_colour, writer_x, writer_y, writer_p0, writer_p1, writer_p2, writer_p3 };
            }
        }

        if( start_displaylist ) {
            entry_number = start_entry;
            finish_number = finish_entry;
            display_list_active = 1;
            ++:
            while( entry_number <= finish_number ) {
                ++:
                if( dlentry(dlentries.rdata0).active ) {
                    while( gpu_active != 0 ) {}
                    ++:
                    gpu_write = dlentry(dlentries.rdata0).command;
                    gpu_colour = dlentry(dlentries.rdata0).colour;
                    gpu_x = dlentry(dlentries.rdata0).x;
                    gpu_y = dlentry(dlentries.rdata0).y;
                    gpu_param0 = dlentry(dlentries.rdata0).p0;
                    gpu_param1 = dlentry(dlentries.rdata0).p1;
                    gpu_param2 = dlentry(dlentries.rdata0).p2;
                    gpu_param3 = dlentry(dlentries.rdata0).p3;
                    ++:
                    ++:
                    gpu_write = 0;
                }
                entry_number = entry_number + 1;
                ++:
            }
            display_list_active = 0;
        }
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
    input   int16 gpu_param0,
    input   int16 gpu_param1,
    input   int16 gpu_param2,
    input   int16 gpu_param3,
    input   uint4 gpu_write,

    // For setting blit1 tile bitmaps
    input   uint5   blit1_writer_tile,
    input   uint4   blit1_writer_line,
    input   uint16  blit1_writer_bitmap,
    input   uint1   blit1_writer_active,

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
    input   uint1   vertices_writer_write,

    // DISPLAY LISTS
    input   uint5   dl_start_entry,
    input   uint5   dl_finish_entry,
    input   uint1   dl_start,
    // For setting entries
    input   uint5   dl_writer_entry_number,
    input   uint1   dl_writer_active,
    input   uint4   dl_writer_command,
    input   uint7   dl_writer_colour,
    input   uint11  dl_writer_x,
    input   uint11  dl_writer_y,
    input   uint11  dl_writer_p0,
    input   uint11  dl_writer_p1,
    input   uint11  dl_writer_p2,
    input   uint11  dl_writer_p3,
    input   uint4   dl_writer_write,

    output  uint1   gpu_active,
    output  uint1   vector_block_active,
    output  uint1   display_list_active
) <autorun> {
    // 32 x 16 x 16 1 bit tilemap for blit1tilemap
    dualport_bram uint16 blit1tilemap[ 512 ] = uninitialized;

    // GPU work variable storage
    // Present GPU pixel and colour
    int11 gpu_active_x = uninitialized;
    int11 gpu_active_y = uninitialized;
    uint7 gpu_active_colour = uninitialized;

    // Temporary storage for GPU operations with meaningful names centre coordinates, end coordinates, width, height, deltas, radius, etc
    int11 gpu_xc = uninitialized;
    int11 gpu_yc = uninitialized;
    int11 gpu_x1 = uninitialized;
    int11 gpu_y1 = uninitialized;
    int11 gpu_x2 = uninitialized;
    int11 gpu_y2 = uninitialized;
    int11 gpu_dx = uninitialized;
    int11 gpu_sx = uninitialized;
    int11 gpu_dy = uninitialized;
    int11 gpu_sy = uninitialized;
    int11 gpu_min_x = uninitialized;
    int11 gpu_max_x = uninitialized;
    int11 gpu_min_y = uninitialized;
    int11 gpu_max_y = uninitialized;
    int11 gpu_numerator = uninitialized;
    int11 gpu_numerator2 = uninitialized;
    int11 gpu_count = uninitialized;
    int11 gpu_max_count = uninitialized;
    uint6 gpu_tile = uninitialized;

    // Filled triangle calculations
    // Is the point sx,sy inside the triangle given by active_x,active_y x1,y1 x2,y2?
    uint1 w0 = uninitialized;
    uint1 w1 = uninitialized;
    uint1 w2 = uninitialized;

    // GPU inputs, copied to according to Forth, VECTOR or DISPLAY LISTS
    int11   x = uninitialized;
    int11   y = uninitialized;
    int16   param0 = uninitialized;
    int16   param1 = uninitialized;
    int16   param2 = uninitialized;
    int16   param3 = uninitialized;
    uint4   write = uninitialized;

    // GPU <-> VECTOR DRAWER Communication
    int11 v_gpu_x = uninitialised;
    int11 v_gpu_y = uninitialised;
    uint7 v_gpu_colour = uninitialised;
    int11 v_gpu_param0 = uninitialised;
    int11 v_gpu_param1 = uninitialised;
    uint4 v_gpu_write = uninitialised;

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
        vertices_writer_write <: vertices_writer_write,

        vector_block_active :> vector_block_active,

        gpu_x :> v_gpu_x,
        gpu_y :> v_gpu_y,
        gpu_colour :> v_gpu_colour,
        gpu_param0 :> v_gpu_param0,
        gpu_param1 :> v_gpu_param1,
        gpu_write :> v_gpu_write,
        gpu_active <: gpu_active
    );

    // GPU <-> DISPLAY LIST COMMUNICATION
    int11 dl_gpu_x = uninitialised;
    int11 dl_gpu_y = uninitialised;
    uint7 dl_gpu_colour = uninitialised;
    int11 dl_gpu_param0 = uninitialised;
    int11 dl_gpu_param1 = uninitialised;
    int11 dl_gpu_param2 = uninitialised;
    int11 dl_gpu_param3 = uninitialised;
    uint4 dl_gpu_write = uninitialised;

    displaylist displaylist_drawer (
        start_entry <: dl_start_entry,
        finish_entry <: dl_finish_entry,
        start_displaylist <: dl_start,

        writer_entry_number <: dl_writer_entry_number,
        writer_active <: dl_writer_active,
        writer_command <: dl_writer_command,
        writer_colour <: dl_writer_colour,
        writer_x <: dl_writer_x,
        writer_y <: dl_writer_y,
        writer_p0 <: dl_writer_p0,
        writer_p1 <: dl_writer_p1,
        writer_p2 <: dl_writer_p2,
        writer_p3 <: dl_writer_p3,
        writer_write <: dl_writer_write,

        display_list_active :> display_list_active,

        gpu_x :> dl_gpu_x,
        gpu_y :> dl_gpu_y,
        gpu_colour :> dl_gpu_colour,
        gpu_param0 :> dl_gpu_param0,
        gpu_param1 :> dl_gpu_param1,
        gpu_param2 :> dl_gpu_param2,
        gpu_param3 :> dl_gpu_param3,
        gpu_write :> dl_gpu_write,
        gpu_active <: gpu_active
    );

    // blit1tilemap read access for the blit1tilemap
    blit1tilemap.addr0 := gpu_tile * 16 + gpu_active_y;
    blit1tilemap.wenable0 := 0;

    // blit1tilemap write access for the GPU to load tilemaps
    blit1tilemap.wenable1 := 1;

    bitmap_write := 0;
    bitmap_colour_write := gpu_active_colour;


    always {
        if( blit1_writer_active ) {
            blit1tilemap.addr1 = blit1_writer_tile * 16 + blit1_writer_line;
            blit1tilemap.wdata1 = blit1_writer_bitmap;
        }
    }

    while(1) {
        if( ( dl_gpu_write != 0 ) || ( v_gpu_write != 0 ) || ( gpu_write != 0 ) ) {
            if( dl_gpu_write != 0 ) {
                x = dl_gpu_x;
                y = dl_gpu_y;
                gpu_active_colour = dl_gpu_colour;
                param0 = dl_gpu_param0;
                param1 = dl_gpu_param1;
                param2 = dl_gpu_param2;
                param3 = dl_gpu_param3;
                write = dl_gpu_write;
            } else {
                if( v_gpu_write != 0 ) {
                    x = v_gpu_x;
                    y = v_gpu_y;
                    gpu_active_colour = v_gpu_colour;
                    param0 = v_gpu_param0;
                    param1 = v_gpu_param1;
                    write = v_gpu_write;
                } else {
                    if( gpu_write != 0 ) {
                        x = gpu_x;
                        y = gpu_y;
                        gpu_active_colour = gpu_colour;
                        param0 = gpu_param0;
                        param1 = gpu_param1;
                        param2 = gpu_param2;
                        param3 = gpu_param3;
                        write = gpu_write;
                    } else {
                        write = 0;
                    }
                }
            }

            ++:

            switch( write ) {
                case 1: {
                    // Setup writing a pixel colour to x,y
                    // Done directly, does not activate the GPU
                    bitmap_x_write = x;
                    bitmap_y_write = y;
                    bitmap_write = 1;
                }

                case 2: {
                    // Setup drawing a rectangle from x,y to param0,param1 in colour
                    // Ensures that works left to right, top to bottom
                    // Cut out pixels out of 0 <= x <= 639 , 0 <= y <= 479
                    gpu_active_x = ( x < param0 ) ? ( x < 0 ? 0 : x ) : ( param0 < 0 ? 0 : param0 );                // left
                    gpu_active_y = ( y < param1 ) ? ( y < 0 ? 0 : y ) : ( param1 < 0 ? 0 : param1 );                // top
                    gpu_x1 = ( x < param0 ) ? ( x < 0 ? 0 : x )  : ( param0 < 0 ? 0 : param0 );                     // left - for next line
                    gpu_max_x = ( x < param0 ) ? ( param0 > 639 ? 639 : param0 ) : ( x > 639 ? 639 : x );              // right - at end of line
                    gpu_max_y = ( y < param1 ) ? ( param1 > 479 ? 479 : param1 ) : ( y > 479 ? 479 : y );              // bottom - at end of rectangle
                    gpu_active = 1;

                    ++:

                    while( ( gpu_active_x <= gpu_max_x ) && ( gpu_active_y <= gpu_max_y ) ) {
                        bitmap_x_write = gpu_active_x;
                        bitmap_y_write = gpu_active_y;
                        bitmap_write = 1;
                        gpu_active_x = ( gpu_active_x == gpu_max_x ) ? gpu_x1 : gpu_active_x + 1;
                        gpu_active_y = ( gpu_active_x == gpu_max_x ) ? gpu_active_y + 1 : gpu_active_y;
                    }

                    gpu_active = 0;
                }

                case 3: {
                    // Setup drawing a line from x,y to param0,param1 in colour
                    // Ensure LEFT to RIGHT
                    gpu_active_x = ( x < param0 ) ? x : param0;
                    gpu_active_y = ( x < param0 ) ? y : param1;

                    // Absolute DELTAs
                    gpu_dx = ( param0 < x ) ? x - param0 : param0 - x;
                    gpu_dy = ( param1 < y ) ? y - param1 : param1 - y;

                    // Shift X is always POSITIVE
                    gpu_sx = 1;

                    // Shift Y is NEGATIVE or POSITIVE
                    gpu_sy = ( x < param0 ) ? ( ( y < param1 ) ? 1 : -1 ) : ( ( y < param1 ) ? -1 : 1 );

                    gpu_count = 0;
                    gpu_active = 1;

                    ++:

                    gpu_numerator = ( gpu_dx > gpu_dy ) ? ( gpu_dx >> 1 ) : -( gpu_dy >> 1 );
                    gpu_max_count = ( gpu_dx > gpu_dy ) ? gpu_dx : gpu_dy;

                    ++:

                    while( gpu_count <= gpu_max_count ) {
                        bitmap_x_write = gpu_active_x;
                        bitmap_y_write = gpu_active_y;
                        bitmap_write = 1;

                        gpu_numerator2 = gpu_numerator;

                        ++:

                        if ( gpu_numerator2 > (-gpu_dx) ) {
                            gpu_numerator = gpu_numerator - gpu_dy;
                            gpu_active_x = gpu_active_x + gpu_sx;
                        }

                        ++:

                        if( gpu_numerator2 < gpu_dy ) {
                            gpu_numerator = gpu_numerator + gpu_dx;
                            gpu_active_y = gpu_active_y + gpu_sy;
                        }

                        gpu_count = gpu_count + 1;
                    }

                    gpu_active = 0;
                }

                case 4: {
                    // Setup drawing a circle centre x,y or radius param0 in colour
                    gpu_active_x = 0;
                    gpu_active_y = ( ( param0 < 0 ) ? -param0 : param0 );
                    gpu_xc = x;
                    gpu_yc = y;
                    gpu_numerator = 3 - ( 2 * ( ( param0 < 0 ) ? -param0 : param0 ) );

                    gpu_active = 1;

                    ++:

                    while( gpu_active_y >= gpu_active_x ) {
                        bitmap_x_write = gpu_xc + gpu_active_x;
                        bitmap_y_write = gpu_yc + gpu_active_y;
                        bitmap_write = 1;
                        ++:
                        bitmap_x_write = gpu_xc - gpu_active_x;
                        bitmap_y_write = gpu_yc + gpu_active_y;
                        bitmap_write = 1;
                        ++:
                        bitmap_x_write = gpu_xc + gpu_active_x;
                        bitmap_y_write = gpu_yc - gpu_active_y;
                        bitmap_write = 1;
                        ++:
                        bitmap_x_write = gpu_xc - gpu_active_x;
                        bitmap_y_write = gpu_yc - gpu_active_y;
                        bitmap_write = 1;
                        ++:
                        bitmap_x_write = gpu_xc + gpu_active_y;
                        bitmap_y_write = gpu_yc + gpu_active_x;
                        bitmap_write = 1;
                        ++:
                        bitmap_x_write = gpu_xc - gpu_active_y;
                        bitmap_y_write = gpu_yc + gpu_active_x;
                        bitmap_write = 1;
                        ++:
                        bitmap_x_write = gpu_xc + gpu_active_y;
                        bitmap_y_write = gpu_yc - gpu_active_x;
                        bitmap_write = 1;
                        ++:
                        bitmap_x_write = gpu_xc - gpu_active_y;
                        bitmap_y_write = gpu_yc - gpu_active_x;
                        bitmap_write = 1;

                        gpu_active_x = gpu_active_x + 1;

                        if( gpu_numerator > 0 ) {
                            gpu_numerator = gpu_numerator + 4 * (gpu_active_x - gpu_active_y) + 10;
                            gpu_active_y = gpu_active_y - 1;
                        } else {
                            gpu_numerator = gpu_numerator + 4 * gpu_active_x + 6;
                        }
                    }

                    gpu_active = 0;
                }

                case 5: {
                    // Setup 1 bit 16x16 blitter starting at x,y in colour of tile param0
                    gpu_active_x = 0;
                    gpu_active_y = 0;
                    gpu_x1 = x;
                    gpu_y1 = y;
                    gpu_max_x = 15;
                    gpu_max_y = 15;
                    gpu_tile = param0;

                    gpu_active = 1;

                    ++:

                    while( gpu_active_y < gpu_max_y ) {
                        while( gpu_active_x < gpu_max_x ) {
                            if( blit1tilemap.rdata0[15 -gpu_active_x,1] ) {
                                bitmap_x_write = gpu_x1 + gpu_active_x;
                                bitmap_y_write = gpu_y1 + gpu_active_y;
                                bitmap_write = 1;
                            }
                            gpu_active_x = gpu_active_x + 1;
                        }
                        gpu_active_x = 0;
                        gpu_active_y = gpu_active_y + 1;
                    }

                    gpu_active = 0;
                }

                case 6: {
                    // Setup drawing a filled circle centre x,y or radius param0 in colour
                    // Minimum radius is 4, radius is always positive
                    gpu_active_x = 0;
                    gpu_active_y = ( ( param0 < 0 ) ? ( ( param0 < -4 ) ? 4 : -param0 ) : ( ( param0 < 4 ) ? 4 : param0 ) );
                    gpu_xc = x;
                    gpu_yc = y;
                    gpu_count = ( ( param0 < 0 ) ? ( ( param0 < -4 ) ? 4 : -param0 ) : ( ( param0 < 4 ) ? 4 : param0 ) );
                    gpu_numerator = 3 - ( 2 * ( ( param0 < 0 ) ? ( ( param0 < -4 ) ? 4 : -param0 ) : ( ( param0 < 4 ) ? 4 : param0 ) ) );

                    gpu_active = 1;

                    ++:

                    while( gpu_active_y >= gpu_active_x ) {
                        while( gpu_count != 0 ) {
                            bitmap_x_write = gpu_xc + gpu_active_x;
                            bitmap_y_write = gpu_yc + gpu_count;
                            bitmap_write = 1;
                            ++:
                            bitmap_x_write = gpu_xc + gpu_active_x;
                            bitmap_y_write = gpu_yc - gpu_count;
                            bitmap_write = 1;
                            ++:
                            bitmap_x_write = gpu_xc - gpu_active_x;
                            bitmap_y_write = gpu_yc + gpu_count;
                            bitmap_write = 1;
                            ++:
                            bitmap_x_write = gpu_xc - gpu_active_x;
                            bitmap_y_write = gpu_yc - gpu_count;
                            bitmap_write = 1;
                            ++:
                            bitmap_x_write = gpu_xc + gpu_count;
                            bitmap_y_write = gpu_yc + gpu_active_x;
                            bitmap_write = 1;
                            ++:
                            bitmap_x_write = gpu_xc - gpu_count;
                            bitmap_y_write = gpu_yc + gpu_active_x;
                            bitmap_write = 1;
                            ++:
                            bitmap_x_write = gpu_xc + gpu_count;
                            bitmap_y_write = gpu_yc - gpu_active_x;
                            bitmap_write = 1;
                            ++:
                            bitmap_x_write = gpu_xc - gpu_count;
                            bitmap_y_write = gpu_yc - gpu_active_x;
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

                    gpu_active = 0;
                }

                case 7: {
                    // Setup drawing a filled triangle x,y param0, param1, param2, param3
                    gpu_active_x = x;
                    gpu_active_y = y;
                    gpu_x1 = param0;
                    gpu_y1 = param1;
                    gpu_x2 = param2;
                    gpu_y2 = param3;

                    gpu_active = 1;

                    ++:

                    // Find minimum and maximum of x, x1 and x2 for the bounding box
                    // Find minimum and maximum of y, y1 and y2 for the bounding box
                    gpu_min_x = ( gpu_active_x < gpu_x1 ) ? ( ( gpu_active_x < gpu_x2 ) ? gpu_active_x : gpu_x2 ) : ( ( gpu_x1 < gpu_x2 ) ? gpu_x1: gpu_x2 );
                    gpu_min_y = ( gpu_active_y < gpu_y1 ) ? ( ( gpu_active_y < gpu_y2 ) ? gpu_active_y : gpu_y2 ) : ( ( gpu_y1 < gpu_y2 ) ? gpu_y1: gpu_y2 );
                    gpu_max_x = ( gpu_active_x > gpu_x1 ) ? ( ( gpu_active_x > gpu_x2 ) ? gpu_active_x : gpu_x2 ) : ( ( gpu_x1 > gpu_x2 ) ? gpu_x1 : gpu_x2 );
                    gpu_max_y = ( gpu_active_y > gpu_y1 ) ? ( ( gpu_active_y > gpu_y2 ) ? gpu_active_y : gpu_y2 ) : ( ( gpu_y1 > gpu_y2 ) ? gpu_y1 : gpu_y2 );

                    ++:

                    // Clip to the screen edge
                    gpu_min_x = ( gpu_min_x < 0 ) ? 0 : gpu_min_x;
                    gpu_min_y = ( gpu_min_y < 0 ) ? 0 : gpu_min_y;
                    gpu_max_x = ( gpu_min_x > 639 ) ? 639 : gpu_max_x;
                    gpu_max_y = ( gpu_min_y > 479 ) ? 479 : gpu_max_y;

                    ++:

                    // Find the point closest to the top of the screen
                    if( gpu_y1 < gpu_active_y ) {
                        gpu_active_x = gpu_x1;
                        gpu_active_y = gpu_y1;
                        gpu_x1 = gpu_active_x;
                        gpu_y1 = gpu_active_y;
                    }

                    ++:

                    if( gpu_y2 < gpu_active_y ) {
                        gpu_active_x = gpu_x2;
                        gpu_active_y = gpu_y2;
                        gpu_x2 = gpu_active_x;
                        gpu_y2 = gpu_active_y;
                    }

                    ++:

                    // Point order is top of screen then down to the right
                    if( gpu_x1 < gpu_x2 ) {
                        gpu_x2 = gpu_x1;
                        gpu_y2 = gpu_y1;
                        gpu_x1 = gpu_x2;
                        gpu_y1 = gpu_y2;
                    }

                    ++:

                    // Start at the top left
                    gpu_sx = gpu_min_x;
                    gpu_sy = gpu_min_y;
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

                        if( ( gpu_count == 1 ) && ~( w0 && w1 && w2 ) ) {
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

                    gpu_active = 0;
                }
            }
        }
    }
}
