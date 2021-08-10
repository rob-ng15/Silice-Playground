algorithm background(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel,

    input   uint2  staticGenerator,

    input   uint6   backgroundcolour,
    input   uint6   backgroundcolour_alt,
    input   uint4   backgroundcolour_mode,
    input   uint2   background_update,

    input   uint1   copper_status,
    input   uint1   copper_program,
    input   uint6   copper_address,
    input   uint3   copper_command,
    input   uint3   copper_condition,
    input   uint10  copper_coordinate,
    input   uint4   copper_mode,
    input   uint6   copper_alt,
    input   uint6   copper_colour
) <autorun> {
    uint6   BACKGROUNDcolour = uninitialised;
    uint6   BACKGROUNDalt = uninitialised;
    uint4   BACKGROUNDmode = uninitialised;
    background_display BACKGROUND(
        pix_x <: pix_x,
        pix_y <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
        pixel :> pixel,
        staticGenerator <: staticGenerator,
        b_colour <: BACKGROUNDcolour,
        b_alt <: BACKGROUNDalt,
        b_mode <: BACKGROUNDmode
    );

    // BACKGROUND CO-PROCESSOR PROGRAM STORAGE
    // { 3 bit command, 3 bit mask, 10 bit coordinate, 4 bit mode, 6 bit colour 2, 6 bit colour 1 }
    // COMMANDS - 0 = goto, 1 = wait vblank, 2 = wait hblank, 3 = wait ypos, 4 = wait xpos, 5 = , 6 =, 7 =
    // MASK { change mode, change colour  2, change colour 1 }
    simple_dualport_bram uint32 copper <input!> [ 64 ] = { 0, pad(0) };
    uint1   copper_execute = uninitialised;
    uint1   copper_branch = uninitialised;
    uint10  copper_variable = uninitialised;
    uint6   PC = 0;

    // COPPER PROGRAM FLAGS
    copper.addr0 := PC;
    copper.wenable1 := 1;

    always {
        copper_execute = 0;
        copper_branch = 0;

        switch( background_update ) {
            case 2b00: {
                // UPDATE THE BACKGROUND GENERATOR FROM THE COPPER
                switch( copper_status ) {
                    case 1: {
                        switch( copper.rdata0[29,3] ) {
                            case 3b000: {
                                // JUMP ON CONDITION
                                switch( copper.rdata0[26,3] ) {
                                    default: { copper_branch = 1; }
                                    case 3b001: { copper_branch = ( pix_vblank == copper.rdata0[16,1] ); }
                                    case 3b010: { copper_branch = ( pix_active == copper.rdata0[16,1] ); }
                                    case 3b011: { copper_branch = ( pix_y < copper.rdata0[16,10] ); }
                                    case 3b100: { copper_branch = ( pix_x < copper.rdata0[16,10] ); }
                                    case 3b101: { copper_branch = ( copper_variable < copper.rdata0[16,10] ); }
                                }
                                PC = copper_branch ? copper.rdata0[0,6] : PC + 1;
                            }
                            default: {
                                switch( copper.rdata0[29,3] ) {
                                    case 3b001: { copper_execute = pix_vblank; }
                                    case 3b010: { copper_execute = ~pix_active; }
                                    case 3b011: { copper_execute = ( pix_y == copper.rdata0[16,10] ); }
                                    case 3b100: { copper_execute = ( pix_x == copper.rdata0[16,10] ); }
                                    case 3b101: { copper_execute = ( copper_variable == ( copper.rdata0[16,1] ? pix_x : pix_y ) ); }
                                    case 3b110: {
                                        switch( copper.rdata0[26,3] ) {
                                            case 3b001: { copper_variable = copper.rdata0[16,10]; }
                                            case 3b010: { copper_variable = copper_variable + copper.rdata0[16,10]; }
                                            default: { copper_variable = copper_variable - copper.rdata0[16,10]; }
                                        }
                                        copper_branch = 1;
                                    }
                                    default: {
                                        switch( copper.rdata0[26,1] ) { case 1: { BACKGROUNDcolour = copper_variable; } case 0: {} }
                                        switch( copper.rdata0[27,1] ) { case 1: { BACKGROUNDalt = copper_variable; } case 0: {} }
                                        switch( copper.rdata0[28,1] ) { case 1: { BACKGROUNDmode = copper_variable; } case 0: {} }
                                        copper_branch = 1;
                                    }
                                }
                                switch( copper_execute ) {
                                    case 1: {
                                        switch( copper.rdata0[26,1] ) { case 1: { BACKGROUNDcolour = copper.rdata0[0,6]; }  case 0: {} }
                                        switch( copper.rdata0[27,1] ) { case 1: { BACKGROUNDalt = copper.rdata0[6,6]; } case 0: {} }
                                        switch( copper.rdata0[28,1] ) { case 1: { BACKGROUNDmode = copper.rdata0[12,4]; } case 0: {} }
                                        copper_branch = 1;
                                    }
                                    case 0: {}
                                }
                                PC = PC + copper_branch;
                            }
                        }
                    }
                    case 0: {
                        // CHANGE A PROGRAM LINE IN THE COPPER MEMORY
                        switch( copper_program ) {
                            case 1: {
                                copper.addr1 = copper_address;
                                copper.wdata1 = { copper_command[0,3], copper_condition[0,3], copper_coordinate[0,10], copper_mode[0,4], copper_alt[0,6], copper_colour[0,6] };
                            }
                            case 0: {}
                        }
                        PC = 0;
                    }
                }
            }
            // UPDATE THE BACKGROUND FROM RISC-V
            case 2b01: { BACKGROUNDcolour = backgroundcolour; }
            case 2b10: { BACKGROUNDalt = backgroundcolour_alt; }
            case 2b11: { BACKGROUNDmode = backgroundcolour_mode; }
        }
    }
}

algorithm background_display(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel,

    input   uint2  staticGenerator,

    input   uint6   b_colour,
    input   uint6   b_alt,
    input   uint4   b_mode
) <autorun> {
    // Variables for SNOW (from @sylefeb)
    int10   dotpos = 0;
    int2    speed = 0;
    int2    inv_speed = 0;
    int12   rand_x = 0;
    int32   frame = 0;

    uint1   tophalf <: ( pix_y < 240 );
    uint1   lefthalf <: ( pix_x < 320 );

    // Increment frame number for the snow/star field
    frame := frame + ( ( pix_x == 639 ) & ( pix_y == 470 ) );

    always {
        // RENDER
        if( pix_active ) {
            switch( b_mode ) {
                case 0: {
                    // SOLID
                    pixel = b_colour;
                }
                case 1: {
                    // 50:50 HORIZONTAL SPLIT
                    pixel = ( tophalf ) ? b_colour : b_alt;
                }
                case 2: {
                // 50:50 VERTICAL SPLIT
                    pixel = ( lefthalf ) ? b_colour : b_alt;
                }
                case 3: {
                // QUARTERS
                    pixel = ( lefthalf == tophalf ) ? b_colour : b_alt;
                }
                case 4: {
                    // 8 colour rainbow
                    switch( pix_y[6,3] ) {
                        case 3b000: { pixel = 6b100000; }
                        case 3b001: { pixel = 6b110000; }
                        case 3b010: { pixel = 6b111000; }
                        case 3b011: { pixel = 6b111100; }
                        case 3b100: { pixel = 6b001100; }
                        case 3b101: { pixel = 6b000011; }
                        case 3b110: { pixel = 6b010010; }
                        case 3b111: { pixel = 6b011011; }
                    }
                }
                case 5: {
                    // SNOW (from @sylefeb)
                    rand_x = ( pix_x == 0)  ? 1 : rand_x * 31421 + 6927;
                    speed  = rand_x[10,2];
                    dotpos = ( frame >> speed ) + rand_x;
                    pixel   = (pix_y == dotpos) ? b_colour : b_alt;
                }
                case 6: {
                    // STATIC
                    pixel = { {3{staticGenerator}} };
                }
                case 11: {
                    // CROSSHATCH
                    pixel   = ( pix_x[0,1] || pix_y[0,1] ) ? b_colour : b_alt;
                }
                case 12: {
                    // LSLOPE
                    pixel   = ( pix_x[0,2] == pix_y[0,2] ) ? b_colour : b_alt;
                }
                case 13: {
                    // RSLOPE
                    pixel   = ( pix_x[0,2] == ~pix_y[0,2] ) ? b_colour : b_alt;
                }
                case 14: {
                    // VSTRIPES
                    pixel   = pix_x[0,1] ? b_colour : b_alt;
                }
                case 15: {
                    // HSTRIPES
                    pixel   = pix_y[0,1] ? b_colour : b_alt;
                }
                default: {
                    // CHECKERBOARDS
                    pixel = ( pix_x[b_mode-7,1] == pix_y[b_mode-7,1] ) ? b_colour : b_alt;
                }
            }
        }
    }
}
