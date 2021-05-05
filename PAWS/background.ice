algorithm background(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint2   pix_red,
    output! uint2   pix_green,
    output! uint2   pix_blue,

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
    // BACKGROUND CO-PROCESSOR PROGRAM STORAGE
    // { 3 bit command, 3 bit mask, 10 bit coordinate, 4 bit mode, 6 bit colour 2, 6 bit colour 1 }
    // COMMANDS - 0 = goto, 1 = wait vblank, 2 = wait hblank, 3 = wait ypos, 4 = wait xpos, 5 = , 6 =, 7 =
    // MASK { change mode, change colour  2, change colour 1 }
    simple_dualport_bram uint32 copper [ 64 ] = { 0, pad(0) };
    uint1   copper_execute = uninitialised;
    uint1   copper_branch = uninitialised;
    uint10  copper_variable = uninitialised;
    uint6   PC = 0;

    // MODE AND COLOUR DEFAULTS
    uint6   b_colour = 0;
    uint6   b_alt = 0;
    uint4   b_mode = 0;

    // Variables for SNOW (from @sylefeb)
    int10   dotpos = 0;
    int2    speed = 0;
    int2    inv_speed = 0;
    int12   rand_x = 0;
    int32   frame = 0;

    uint1   tophalf <: ( pix_y < 240 );
    uint1   lefthalf <: ( pix_x < 320 );

    // COPPER PROGRAM FLAGS
    copper.addr0 := PC;
    copper.wenable1 := 1;

    // Increment frame number for the snow/star field
    frame := ( ( pix_x == 639 ) && ( pix_y == 470 ) ) ? frame + 1 : frame;

    always {
        // CHANGE A PROGRAM LINE IN THE COPPER MEMORY
        if( copper_program ) {
            copper.addr1 = copper_address;
            copper.wdata1 = { copper_command[0,3], copper_condition[0,3], copper_coordinate[0,10], copper_mode[0,4], copper_alt[0,6], copper_colour[0,6] };
        }

        // RENDER
        if( pix_active ) {
            switch( b_mode ) {
                case 0: {
                    // SOLID
                    pix_red = colour6(b_colour).red;
                    pix_green = colour6(b_colour).green;
                    pix_blue = colour6(b_colour).blue;
                }
                case 1: {
                    // 50:50 HORIZONTAL SPLIT
                    pix_red = ( tophalf ) ? colour6(b_colour).red : colour6(b_alt).red;
                    pix_green = ( tophalf ) ? colour6(b_colour).green : colour6(b_alt).green;
                    pix_blue = ( tophalf ) ? colour6(b_colour).blue : colour6(b_alt).blue;
                }
                case 2: {
                // 50:50 VERTICAL SPLIT
                    pix_red = ( lefthalf ) ? colour6(b_colour).red : colour6(b_alt).red;
                    pix_green = ( lefthalf ) ? colour6(b_colour).green : colour6(b_alt).green;
                    pix_blue = ( lefthalf ) ? colour6(b_colour).blue : colour6(b_alt).blue;
                }
                case 3: {
                // QUARTERS
                    pix_red = ( lefthalf == tophalf ) ? colour6(b_colour).red : colour6(b_alt).red;
                    pix_green = ( lefthalf == tophalf ) ? colour6(b_colour).green : colour6(b_alt).green;
                    pix_blue = ( lefthalf == tophalf ) ? colour6(b_colour).blue : colour6(b_alt).blue;
                }
                case 4: {
                    // 8 colour rainbow
                    switch( pix_y[6,3] ) {
                        case 3b000: { pix_red = 2; pix_green = 0; pix_blue = 0; }
                        case 3b001: { pix_red = 3; pix_green = 0; pix_blue = 0; }
                        case 3b010: { pix_red = 3; pix_green = 2; pix_blue = 0; }
                        case 3b011: { pix_red = 3; pix_green = 3; pix_blue = 0; }
                        case 3b100: { pix_red = 0; pix_green = 3; pix_blue = 0; }
                        case 3b101: { pix_red = 0; pix_green = 0; pix_blue = 3; }
                        case 3b110: { pix_red = 1; pix_green = 0; pix_blue = 2; }
                        case 3b111: { pix_red = 1; pix_green = 2; pix_blue = 3; }
                    }
                }
                case 5: {
                    // SNOW (from @sylefeb)
                    rand_x = ( pix_x == 0)  ? 1 : rand_x * 31421 + 6927;
                    speed  = rand_x[10,2];
                    dotpos = ( frame >> speed ) + rand_x;
                    pix_red   = (pix_y == dotpos) ? colour6(b_colour).red : colour6(b_alt).red;
                    pix_green = (pix_y == dotpos) ? colour6(b_colour).green : colour6(b_alt).green;
                    pix_blue  = (pix_y == dotpos) ? colour6(b_colour).blue : colour6(b_alt).blue;
                }
                case 6: {
                    // STATIC
                    pix_red = staticGenerator;
                    pix_green = staticGenerator;
                    pix_blue = staticGenerator;
                }
                case 11: {
                    // CROSSHATCH
                    pix_red   = ( pix_x[0,1] || pix_y[0,1] ) ? colour6(b_colour).red : colour6(b_alt).red;
                    pix_green = ( pix_x[0,1] || pix_y[0,1] ) ? colour6(b_colour).green : colour6(b_alt).green;
                    pix_blue  = ( pix_x[0,1] || pix_y[0,1] ) ? colour6(b_colour).blue : colour6(b_alt).blue;
                }
                case 12: {
                    // LSLOPE
                    pix_red   = ( pix_x[0,2] == pix_y[0,2] ) ? colour6(b_colour).red : colour6(b_alt).red;
                    pix_green = ( pix_x[0,2] == pix_y[0,2] ) ? colour6(b_colour).green : colour6(b_alt).green;
                    pix_blue  = ( pix_x[0,2] == pix_y[0,2] ) ? colour6(b_colour).blue : colour6(b_alt).blue;
                }
                case 13: {
                    // RSLOPE
                    pix_red   = ( pix_x[0,2] == ~pix_y[0,2] ) ? colour6(b_colour).red : colour6(b_alt).red;
                    pix_green = ( pix_x[0,2] == ~pix_y[0,2] ) ? colour6(b_colour).green : colour6(b_alt).green;
                    pix_blue  = ( pix_x[0,2] == ~pix_y[0,2] ) ? colour6(b_colour).blue : colour6(b_alt).blue;
                }
                case 14: {
                    // VSTRIPES
                    pix_red   = pix_x[0,1] ? colour6(b_colour).red : colour6(b_alt).red;
                    pix_green = pix_x[0,1] ? colour6(b_colour).green : colour6(b_alt).green;
                    pix_blue  = pix_x[0,1] ? colour6(b_colour).blue : colour6(b_alt).blue;
                }
                case 15: {
                    // HSTRIPES
                    pix_red   = pix_y[0,1] ? colour6(b_colour).red : colour6(b_alt).red;
                    pix_green = pix_y[0,1] ? colour6(b_colour).green : colour6(b_alt).green;
                    pix_blue  = pix_y[0,1] ? colour6(b_colour).blue : colour6(b_alt).blue;
                }
                default: {
                    // CHECKERBOARDS
                    pix_red = ( pix_x[b_mode-7,1] == pix_y[b_mode-7,1] ) ? colour6(b_colour).red : colour6(b_alt).red;
                    pix_green = ( pix_x[b_mode-7,1] == pix_y[b_mode-7,1] ) ? colour6(b_colour).green : colour6(b_alt).green;
                    pix_blue = ( pix_x[b_mode-7,1] == pix_y[b_mode-7,1] ) ? colour6(b_colour).blue : colour6(b_alt).blue;
                }
            }
        }
    }

    while(1) {
        copper_execute = 0;
        copper_branch = 0;

        switch( background_update ) {
            case 2b00: {
                // UPDATE THE BACKGROUND GENERATOR FROM THE COPPER
                if( copper_status ) {
                    switch( copper.rdata0[29,3] ) {
                        case 3b000: {
                            // JUMP ON CONDITION
                            switch( copper.rdata0[26,3] ) {
                                case 3b000: { copper_branch = 1; }
                                case 3b001: { copper_branch = pix_vblank ? 0 : 1; }
                                case 3b010: { copper_branch = pix_active ? 0 : 1; }
                                case 3b011: { copper_branch = ( pix_y < copper.rdata0[16,10] ) ? 1 : 0; }
                                case 3b100: { copper_branch = ( pix_x < copper.rdata0[16,10] ) ? 1 : 0; }
                                case 3b101: { copper_branch = ( copper_variable < copper.rdata0[16,10] ) ? 1 : 0; }
                            }
                            PC = copper_branch ? copper.rdata0[0,6] : PC + 1;
                        }
                        default: {
                            switch( copper.rdata0[29,3] ) {
                                case 3b001: { copper_execute = pix_vblank ? 1 : 0; }
                                case 3b010: { copper_execute = pix_active ? 0 : 1; }
                                case 3b011: { copper_execute = ( pix_y == copper.rdata0[16,10] ) ? 1 : 0; }
                                case 3b100: { copper_execute = ( pix_x == copper.rdata0[16,10] ) ? 1 : 0; }
                                case 3b101: { copper_execute = ( copper_variable == ( copper.rdata0[16,1] ? pix_x : pix_y ) ) ? 1 : 0; }
                                case 3b110: {
                                    switch( copper.rdata0[26,3] ) {
                                        case 3b001: { copper_variable = copper.rdata0[16,10]; }
                                        case 3b010: { copper_variable = copper_variable + copper.rdata0[16,10]; }
                                        case 3b100: { copper_variable = copper_variable - copper.rdata0[16,10]; }
                                    }
                                    copper_branch = 1;
                                }
                                case 3b111: {
                                    switch( copper.rdata0[26,1] ) { case 1: { { b_colour = copper_variable; } } }
                                    switch( copper.rdata0[27,1] ) { case 1: { { b_alt = copper_variable; } } }
                                    switch( copper.rdata0[28,1] ) { case 1: { { b_mode = copper_variable; } } }
                                    copper_branch = 1;
                                }
                            }
                            switch( copper_execute ) {
                                case 1: {
                                    switch( copper.rdata0[26,1] ) { case 1: { { b_colour = copper.rdata0[0,6]; } } }
                                    switch( copper.rdata0[27,1] ) { case 1: { { b_alt = copper.rdata0[6,6]; } } }
                                    switch( copper.rdata0[28,1] ) { case 1: { { b_mode = copper.rdata0[12,4]; } } }
                                    copper_branch = 1;
                                }
                            }
                            PC = PC + copper_branch;
                        }
                    }
                } else {
                    PC = 0;
                }
            }
            // UPDATE THE BACKGROUND FROM RISC-V
            case 2b01: { b_colour = backgroundcolour; }
            case 2b10: { b_alt = backgroundcolour_alt; }
            case 2b11: { b_mode = backgroundcolour_mode; }
        }
    }
}
