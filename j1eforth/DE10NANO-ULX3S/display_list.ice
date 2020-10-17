bitfield displaylistentry {
    uint1   active,
    uint4   command,            // 1 pixel, 2 rectangle, 3 line, 4 circle, 5 blit1, 14 vector
    uint7   colour,
    uint11  x,
    uint11  y,
    uint11  p0,                 // CIRCLES = RADIUS, BLIT1 = TILE NUMBER, RECTANGLES = x1, VECTOR = BLOCK NUMBER
    uint11  p1                  // RECTANGLES = y1
}

// Display List
// Stores GPU or VECTOR commands
// Each display list entry consists of:
//      active
//      command ( 1 - 7 copy details across to the GPU )
//              ( 14    copy details to the vector drawer )

algorithm displaylist(
    input   uint8   start_entry,
    input   uint8   finish_entry,
    input   uint1   start_displaylist,
    
    input   uint8   writer_entry_number,
    input   uint1   writer_active,
    input   uint4   writer_command,
    input   uint7   writer_colour,
    input   uint11  writer_x,
    input   uint11  writer_y,
    input   uint11  writer_p0,
    input   uint11  writer_p1,
    input   uint4   writer_write,

    // Communication with the GPU via j1eforth always{} block
    output!  int11 gpu_x,
    output!  int11 gpu_y,
    output!  uint8 gpu_colour,
    output!  int16 gpu_param0,
    output!  int16 gpu_param1,
    output!  uint3 gpu_write,

    // Communication with the VECTOR DRAWER via j1eforth always{} block
    output!  uint5   vector_block_number,
    output!  uint7   vector_block_colour,
    output!  int11   vector_block_xc,
    output!  int11   vector_block_yc,
    output!  uint1   draw_vector,
    
    output   uint3   display_list_active,
    input    uint4   gpu_active,
    input    uint3   vector_block_active
) {
    // 256 display list entries - 56 bits wide, decoded using the displaylistentry bitfield
    dualport_bram uint56 entries[256] = uninitialised;    

    uint8   entry_number = 0;
    uint8   finish_number = 0;
    
    // Set read address for the display list entry being processed
    entries.addr0 := entry_number;
    entries.wenable0 := 0;
    entries.addr1 := writer_entry_number;
    entries.wenable1 := 0;

    gpu_write := 0;
    draw_vector := 0;
    
    always {
        switch( writer_write ) {
            case 1: {
                // Replace entry
                entries.wdata1 = { writer_active, writer_command, writer_colour, writer_x, writer_y, writer_p0, writer_p1 }   ;
                entries.wenable1 = 1;
            }
            case 2: {
                // Update entry according to update flag { wrap, Arrggbb, 4-bit y-delta, 4-bit x-delta }
                // NB: deltas for rectangles move x, y, p0, p1
            }
            case 3: {
                // Update active
                entries.wdata1 = { writer_active, displaylistentry( entries.rdata1 ).command, displaylistentry( entries.rdata1 ).colour, displaylistentry( entries.rdata1 ).x, displaylistentry( entries.rdata1 ).y, displaylistentry( entries.rdata1 ).p0, displaylistentry( entries.rdata1 ).p1};
                entries.wenable1 = 1;
            }
            case 4: {
                // Update colour
                entries.wdata1 = { displaylistentry( entries.rdata1 ).active, displaylistentry( entries.rdata1 ).command, writer_colour, displaylistentry( entries.rdata1 ).x, displaylistentry( entries.rdata1 ).y, displaylistentry( entries.rdata1 ).p0, displaylistentry( entries.rdata1 ).p1 };
                entries.wenable1 = 1;
            }
            case 5: {
                // Update X
                entries.wdata1 = { displaylistentry( entries.rdata1 ).active, displaylistentry( entries.rdata1 ).command, displaylistentry( entries.rdata1 ).colour, writer_x, displaylistentry( entries.rdata1 ).y, displaylistentry( entries.rdata1 ).p0, displaylistentry( entries.rdata1 ).p1 };
                entries.wenable1 = 1;
            }
            case 6: {
                // Update Y
                entries.wdata1 = { displaylistentry( entries.rdata1 ).active, displaylistentry( entries.rdata1 ).command, displaylistentry( entries.rdata1 ).colour, displaylistentry( entries.rdata1 ).x, writer_y, displaylistentry( entries.rdata1 ).p0, displaylistentry( entries.rdata1 ).p1 };
                entries.wenable1 = 1;
            }
            case 7: {
                // Update p0
                entries.wdata1 = { displaylistentry( entries.rdata1 ).active, displaylistentry( entries.rdata1 ).command, displaylistentry( entries.rdata1 ).colour, displaylistentry( entries.rdata1 ).x, displaylistentry( entries.rdata1 ).y, writer_p0, displaylistentry( entries.rdata1 ).p1 };
                entries.wenable1 = 1;
            }
            case 8: {
                // Update p1
                entries.wdata1 = { displaylistentry( entries.rdata1 ).active, displaylistentry( entries.rdata1 ).command, displaylistentry( entries.rdata1 ).colour, displaylistentry( entries.rdata1 ).x, displaylistentry( entries.rdata1 ).y, displaylistentry( entries.rdata1 ).p0, writer_p1 };
                entries.wenable1 = 1;
            }
        }
        
        if( start_displaylist ) {
            finish_number = finish_entry;
            display_list_active = 1;
        }
    }
    
    while(1) {
        switch( display_list_active ) {
            case 1: {
                // Delay to allow reading of the next entry
                display_list_active = 2;
            }
            case 2: {
                if( displaylistentry( entries.rdata0 ).active ) {
                    // Await GPU and VECTOR DRAWER
                    display_list_active = ( gpu_active | vector_block_active ) ? 2 : 3;
                } else {
                    // Move to the next entry
                    entry_number = ( entry_number == finish_number ) ? 0 : entry_number + 1;
                    display_list_active = ( entry_number == finish_number ) ? 0 : 1;
                }
            }
            case 3: {
                // Dispatch entry to GPU or vector block
                switch( displaylistentry( entries.rdata0 ).command ) {
                    case 14: {
                        // VECTOR BLOCK COMMAND
                        vector_block_number = displaylistentry( entries.rdata0 ).p0;
                        vector_block_colour = displaylistentry( entries.rdata0 ).colour;
                        vector_block_xc = displaylistentry( entries.rdata0 ).x;
                        vector_block_yc = displaylistentry( entries.rdata0 ).y;
                        draw_vector = 1;
                    }
                    default: {
                        // GPU Command
                        gpu_write = displaylistentry( entries.rdata0 ).command;
                        gpu_colour = displaylistentry( entries.rdata0 ).colour;
                        gpu_x = displaylistentry( entries.rdata0 ).x;
                        gpu_y = displaylistentry( entries.rdata0 ).y;
                        gpu_param0 = displaylistentry( entries.rdata0 ).p0;
                        gpu_param1 = displaylistentry( entries.rdata0 ).p1;
                    }
                }
                // Move to the next entry
                entry_number = ( entry_number == finish_number ) ? 0 : entry_number + 1;
                display_list_active = ( entry_number == finish_number ) ? 0 : 1;
            }
            default: {
                display_list_active = 0;
                entry_number = start_entry;
            }
        }
    }
}
