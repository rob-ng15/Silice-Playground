// STRUCTURE OF A COPPER PROGRAM ENTRY
bitfield CU{
    uint3   command,
    uint3   flag,
    uint1   valueflag,
    uint10  value,
    uint4   mode,
    uint6   colour_alt,
    uint6   colour
}

algorithm background_writer(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,

    input   uint6   backgroundcolour,
    input   uint6   backgroundcolour_alt,
    input   uint4   backgroundcolour_mode,
    input   uint2   background_update,

    input   uint1   copper_status,
    input   uint1   copper_program,
    input   uint6   copper_address,
    input   uint3   copper_command,
    input   uint3   copper_condition,
    input   uint11  copper_coordinate,
    input   uint10  copper_cpu_input,
    input   uint4   copper_mode,
    input   uint6   copper_alt,
    input   uint6   copper_colour,

    output  uint6   BACKGROUNDcolour,
    output  uint6   BACKGROUNDalt,
    output  uint4   BACKGROUNDmode
) <autorun> {
    // BACKGROUND CO-PROCESSOR PROGRAM STORAGE
    // { 3 bit command, 3 bit mask, { 1 bit for cpuinput flag, 10 bit coordinate }, 4 bit mode, 6 bit colour 2, 6 bit colour 1 }
    simple_dualport_bram uint33 copper[ 64 ] = uninitialised;
    uint1   copper_execute = uninitialised;
    uint1   copper_branch = uninitialised;
    uint10  copper_variable = uninitialised;
    uint6   PC = 0;

    // COPPER PROGRAM ENTRY
    uint3   command <: CU(copper.rdata0).command;
    uint3   flag <: CU(copper.rdata0).flag;
    uint10  value <: CU(copper.rdata0).valueflag ? copper_cpu_input : CU(copper.rdata0).value;
    uint1   bitvalue <: CU(copper.rdata0).value;

    // COPPER PROGRAM FLAGS
    copper.addr0 := PC; copper.wenable1 := 1;

    always {
        switch( background_update ) {
            case 2b00: {
                // UPDATE THE BACKGROUND GENERATOR FROM THE COPPER
                if( copper_status ) {
                    copper_execute = 0; copper_branch = 0;
                    switch( command ) {
                        case 3b000: {
                            // JUMP ON CONDITION
                            switch( flag ) {
                                default: { copper_branch = 1; }
                                case 3b001: { copper_branch = ( pix_vblank == bitvalue ); }
                                case 3b010: { copper_branch = ( pix_active == bitvalue ); }
                                case 3b011: { copper_branch = ( pix_y < value ); }
                                case 3b100: { copper_branch = ( pix_x < value ); }
                                case 3b101: { copper_branch = ( copper_variable < value ); }
                            }
                            PC = copper_branch ? CU(copper.rdata0).colour : PC + 1;
                        }
                        default: {
                            switch( command ) {
                                case 3b001: { copper_execute = pix_vblank; }
                                case 3b010: { copper_execute = ~pix_active; }
                                case 3b011: { copper_execute = ( pix_y == value ); }
                                case 3b100: { copper_execute = ( pix_x == value ); }
                                case 3b101: { copper_execute = ( copper_variable == ( bitvalue ? pix_x : pix_y ) ); }
                                case 3b110: {
                                    onehot( flag ) {
                                        case 0: { copper_variable = value; }
                                        case 1: { copper_variable = copper_variable + value; }
                                        case 2: { copper_variable = copper_variable - value; }
                                    }
                                    copper_branch = 1;
                                }
                                default: {
                                    if( flag[0,1] ) { BACKGROUNDcolour = copper_variable; }
                                    if( flag[1,1] ) { BACKGROUNDalt = copper_variable; }
                                    if( flag[2,1] ) { BACKGROUNDmode = copper_variable;}
                                    copper_branch = 1;
                                }
                            }
                            if( copper_execute ) {
                                if( flag[0,1] ) { BACKGROUNDcolour = CU(copper.rdata0).colour; }
                                if( flag[1,1] ) { BACKGROUNDalt = CU(copper.rdata0).colour_alt; }
                                if( flag[2,1] ) { BACKGROUNDmode = CU(copper.rdata0).mode; }
                                copper_branch = 1;
                            }
                            PC = PC + copper_branch;
                        }
                    }
                } else{
                    // CHANGE A PROGRAM LINE IN THE COPPER MEMORY
                    if( copper_program ) {
                        copper.addr1 = copper_address;
                        copper.wdata1 = { copper_command[0,3], copper_condition[0,3], copper_coordinate[0,11], copper_mode[0,4], copper_alt[0,6], copper_colour[0,6] };
                    }
                    PC = 0;
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
    // TRUE FOR COLOUR, FALSE FOR ALT
    uint1   condition = uninitialised;
    pattern PATTERN(
        pix_x <: pix_x,
        pix_y <: pix_y,
        b_mode <: b_mode,
        condition :> condition
    );

    always {
        // RENDER
        if( pix_active ) {
            // SELECT ACTUAL COLOUR
            switch( b_mode ) {
                case 4: {                                                               // RAINBOW
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
                case 6: { pixel = {3{staticGenerator}}; }                               // STATIC
                default: { pixel = condition ? b_colour : b_alt; }                     // EVERYTHING ELSE
            }
        }
    }
}

algorithm pattern(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint4   b_mode,
    output! uint1   condition
) <autorun> {
    uint1   tophalf <: ( pix_y < 240 );
    uint1   lefthalf <: ( pix_x < 320 );

    // Variables for SNOW (from @sylefeb)
    int10   dotpos = 0;
    int2    speed = 0;
    int2    inv_speed = 0;
    int12   rand_x = 0;
    int12   new_rand_x <:: rand_x * 31421 + 6927;
    int32   frame = 0;

    // Increment frame number for the snow/star field
    frame ::= frame + ( ( pix_x == 639 ) & ( pix_y == 479 ) );

    always {
        // SELECT COLOUR OR ALT
        switch( b_mode ) {
            case 0: { condition = 1; }                                              // SOLID
            case 1: { condition = tophalf; }                                        // 50:50 HORIZONTAL SPLIT
            case 2: { condition = ( lefthalf ); }                                   // 50:50 VERTICAL SPLIT
            case 3: { condition = ( lefthalf == tophalf ); }                        // QUARTERS
            case 4: { condition = 1; }                                              // RAINBOW (placeholder, done in main)
            case 5: {                                                               // SNOW (from @sylefeb)
                rand_x = ( pix_x == 0 )  ? 1 : new_rand_x;
                speed  = rand_x[10,2];
                dotpos = ( frame >> speed ) + rand_x;
                condition   = ( pix_y == dotpos );
            }
            case 6: { condition = 1; }                                              // STATIC (placeholder, done in main)
            default: { condition = ( pix_x[b_mode-7,1] == pix_y[b_mode-7,1] ); }    // CHECKERBOARDS (7,8,9,10)
            case 11: { condition = ( pix_x[0,1] | pix_y[0,1] ); }                   // CROSSHATCH
            case 12: { condition = ( pix_x[0,2] == pix_y[0,2] ); }                  // LSLOPE
            case 13: { condition = ( pix_x[0,2] == ~pix_y[0,2] ); }                 // RSLOPE
            case 14: { condition = pix_x[0,1]; }                                    // VSTRIPES
            case 15: { condition = pix_y[0,1]; }                                    // HSTRIPES
        }
    }
}
