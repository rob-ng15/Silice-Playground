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

    // Communication with the GPU
    output  int11 gpu_x,
    output  int11 gpu_y,
    output  uint7 gpu_colour,
    output  int11 gpu_param0,
    output  int11 gpu_param1,
    output  uint4 gpu_write,

    // Communication with the VECTOR DRAWER
    output  uint5   vector_block_number,
    output  uint7   vector_block_colour,
    output  int11   vector_block_xc,
    output  int11   vector_block_yc,
    output  uint1   draw_vector,
    
    output  uint3   display_list_active,
    input   uint4   gpu_active,
    input   uint3   vector_block_active
) {
    // 256 display list entries
    dualport_bram uint1 A[256] = { 1, 1, pad(uninitialised) };    
    dualport_bram uint4 command[256] = { 2, 4, pad(uninitialised) };    
    dualport_bram uint7 colour[256] = { 63, 3, pad(uninitialised) };    
    dualport_bram int11 x[256] = { 10, 100, pad(uninitialised) };    
    dualport_bram int11 y[256] = { 10, 100, pad(uninitialised) };    
    dualport_bram int11 p0[256] = { 20, 50, pad(uninitialised) };    
    dualport_bram int11 p1[256] = { 20, pad(uninitialised) };    

    uint8   entry_number = uninitialised;
    uint8   finish_number = uninitialised;
    
    // Set read address for the display list entry being processed
    A.addr0 := entry_number;
    A.wenable0 := 0;
    A.addr1 := writer_entry_number;
    A.wenable1 := 0;

    command.addr0 := entry_number;
    command.wenable0 := 0;
    command.addr1 := writer_entry_number;
    command.wenable1 := 0;

    colour.addr0 := entry_number;
    colour.wenable0 := 0;
    colour.addr1 := writer_entry_number;
    colour.wenable1 := 0;

    x.addr0 := entry_number;
    x.wenable0 := 0;
    x.addr1 := writer_entry_number;
    x.wenable1 := 0;

    y.addr0 := entry_number;
    y.wenable0 := 0;
    y.addr1 := writer_entry_number;
    y.wenable1 := 0;

    p0.addr0 := entry_number;
    p0.wenable0 := 0;
    p0.addr1 := writer_entry_number;
    p0.wenable1 := 0;

    p1.addr0 := entry_number;
    p1.wenable0 := 0;
    p1.addr1 := writer_entry_number;
    p1.wenable1 := 0;

    gpu_write := 0;
    draw_vector := 0;
    
    always {
        switch( writer_write ) {
            case 1: {
                // Replace entry
                A.wenable1 = 1;
                command.wenable1 = 1;
                colour.wenable1 = 1;
                x.wenable1 = 1;
                y.wenable1 = 1;
                p0.wenable1 = 1;
                p1.wenable1 = 1;
            }
            case 2: {
                // Update entry according to update flag { 6-bit y-delta, 6-bit x-delta range -31 to 0 to 31 }
                // NB: deltas for rectangles move x, y, p0, p1
                // Vector blocks will wrap when offscreen ( 32 pixels )
            }
            // Update individual components
            case 3: { A.wenable1 = 1; }
            case 4: { colour.wenable1 = 1; }
            case 5: { x.wenable1 = 1; }
            case 6: { y.wenable1 = 1; }
            case 7: { p0.wenable1 = 1; }
            case 8: { p1.wenable1 = 1; }
        }
    }
    
    while(1) {
        switch( display_list_active ) {
            case 0: {
                entry_number = start_entry;
                finish_number = finish_entry;
                if( start_displaylist == 1 ) {
                    display_list_active = 1;
                }
            }
            case 1: {
                // Start the start and finish position
                entry_number = start_entry;
                finish_number = finish_entry;
                display_list_active = 2;
            }
            case 2: {
                // Delay to allow reading of the next entry
                display_list_active = 3;
            }
            case 3: {
                // Delay to allow reading of the next entry
                display_list_active = 4;
            }
            case 4: {
                if( A.rdata0  ) {
                    // Await GPU and VECTOR DRAWER
                    display_list_active = ( ( gpu_active > 0)  | ( vector_block_active > 0 ) ) ? 4 : 5;
                } else {
                    // Move to the next entry
                    entry_number = ( entry_number == finish_number ) ?  start_entry : entry_number + 1;
                    display_list_active = ( entry_number == finish_number ) ? 2 : 0;
                }
            }
            case 5: {
                // Dispatch entry to GPU or vector block
                switch( command.rdata0 ) {
                    case 14: {
                        // VECTOR BLOCK COMMAND
                        vector_block_number = __unsigned(p0.rdata0[0,5]);
                        vector_block_colour = colour.rdata0;
                        vector_block_xc = x.rdata0;
                        vector_block_yc = y.rdata0;
                        draw_vector = 1;
                    }
                    default: {
                        // GPU Command
                        gpu_write = command.rdata0;
                        gpu_colour = colour.rdata0;
                        gpu_x = x.rdata0;
                        gpu_y = y.rdata0;
                        gpu_param0 = p0.rdata0;
                        gpu_param1 = p1.rdata0;
                    }
                }
                // Move to the next entry
                entry_number = ( entry_number == finish_number ) ? start_entry : entry_number + 1;
                display_list_active = ( entry_number == finish_number ) ? 0 : 2;
            }
            default: {
                display_list_active = 0;
            }
        }
    }
}
