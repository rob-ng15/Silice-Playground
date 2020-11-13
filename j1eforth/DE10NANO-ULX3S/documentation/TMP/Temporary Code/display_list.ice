// Display List
// Stores GPU or VECTOR commands
// Each display list entry consists of:
//      active
//      command ( 1 - 7 copy details across to the GPU )
//              ( 14    copy details to the vector drawer )

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

    output   uint1   read_active,
    output   uint4   read_command,
    output   uint7   read_colour,
    output   uint11  read_x,
    output   uint11  read_y,
    output   uint11  read_p0,
    output   uint11  read_p1,
    output   uint11  read_p2,
    output   uint11  read_p3,

    // Communication with the GPU
    output! int11   gpu_x,
    output! int11   gpu_y,
    output! uint7   gpu_colour,
    output! int11   gpu_param0,
    output! int11   gpu_param1,
    output! int11   gpu_param2,
    output! int11   gpu_param3,
    output! uint4   gpu_write,
    input   uint1   gpu_active,

    // Communication with the VECTOR DRAWER
    output! uint5   vector_block_number,
    output! uint7   vector_block_colour,
    output! int11   vector_block_xc,
    output! int11   vector_block_yc,
    output! uint1   draw_vector,
    input   uint1   vector_block_active
) {
    // 32 display list entries
    dualport_bram uint78 dlentries[32] = uninitialised;

    uint5   entry_number = uninitialised;
    uint5   finish_number = uninitialised;

    // Set read address for the display list entry being processed
    dlentries.addr0 := entry_number;
    dlentries.wenable0 := 0;
    dlentries.wenable1 := 1;

    // Dispatch to the VECTOR DRAWER
    draw_vector := 0;

    // Dispatch to the GPU
    gpu_write := 0;

    always {
    }

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
                    while( ( gpu_active != 0 ) || ( vector_block_active != 0 ) ) {}

                    switch( dlentry(dlentries.rdata0).command ) {
                        case 15: {
                            vector_block_colour = dlentry(dlentries.rdata0).colour;
                            vector_block_number = dlentry(dlentries.rdata0).p0;
                            vector_block_xc = dlentry(dlentries.rdata0).x;
                            vector_block_yc = dlentry(dlentries.rdata0).y;
                            draw_vector = 1;
                        }
                        default: {
                            gpu_write = dlentry(dlentries.rdata0).command;
                            gpu_colour = dlentry(dlentries.rdata0).colour;
                            gpu_x = dlentry(dlentries.rdata0).x;
                            gpu_y = dlentry(dlentries.rdata0).y;
                            gpu_param0 = dlentry(dlentries.rdata0).p0;
                            gpu_param1 = dlentry(dlentries.rdata0).p1;
                            gpu_param2 = dlentry(dlentries.rdata0).p2;
                            gpu_param3 = dlentry(dlentries.rdata0).p3;
                        }
                    }
                }

                ++:

                entry_number = entry_number + 1;

                ++:
            }

            display_list_active = 0;
        }
     }
}
