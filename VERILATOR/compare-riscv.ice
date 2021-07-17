bitfield floatingpointnumber{
    uint1   sign,
    uint8   exponent,
    uint23  fraction
}

circuitry floatless( input a, input b, output lessthan ) {
    switch( b ) {
        case 0: { lessthan = a[31,1]; }
        default: { lessthan = ( a[31,1] != b[31,1] ) ? a[31,1] & ((( a | b ) << 1) != 0 ) : ( a != b ) & ( a[31,1] ^ ( a < b)); }
    }
}
circuitry floatequal( input a, input b, output equalto ) {
    equalto = ( a == b ) | ((( a | b ) << 1) == 0 );
}
circuitry floatlessequal( input a, input b, output lessequal, ) {
    switch( b ) {
        case 0: { lessequal = a[31,1]; }
        default: { lessequal = ( a[31,1] != b[31,1] ) ? a[31,1] | ((( a | b ) << 1) == 0 ) : ( a == b ) | ( a[31,1] ^ ( a < b )); }
    }
}


algorithm main(output int8 leds) {
    uint4   FSM = uninitialised;

    // BIT Patterns can be obtained from http://weitz.de/ieee/
    // 0.848771 = 32h3F59490E
    // 1/3 = 32h3eaaaaab
    // 1 = 32h3F800000
    // 2 = 32h40000000
    // 3 = 32h40400000
    // 100 = 32h42C80000
    uint32  sourceReg1F = 32h3F59490E;
    uint32  sourceReg2F = 32h3F800000;
    uint32  result = 1;

    uint1   less = uninitialised;
    uint1   lessequal = uninitialised;
    uint1   equal = uninitialised;

    // MIN MAX function7 = 7b0010100 function3 = 000 min == 001 max
    // LT EQ LE function7 = 7b1010000 function3 = 000 le = 001 lt 010 eq
    uint3   function3 = 3b001;
    uint7   function7 = 7b1010000;

        ( less ) = floatless( sourceReg1F, sourceReg2F );
        ( equal ) = floatequal( sourceReg1F, sourceReg2F );
        ( lessequal ) = floatlessequal( sourceReg1F, sourceReg2F );
                switch( function7[2,5] ) {
                    case 5b00101: {
                        // FMIN.S FMAX.S
                        switch( function3[0,1] ) {
                            case 0: { result = less ? sourceReg1F : sourceReg2F; }
                            case 1: { result = less ? sourceReg2F : sourceReg1F; }
                        }
                    }
                    default: {
                        // FEQ.S FLT.S FLE.S
                        switch( function3 ) {
                            case 3b000: { result = lessequal; }
                            case 3b001: { result = less; }
                            case 3b010: { result = equal; }
                            default: { result = 0; }
                        }
                    }
                }

    __display("sourceReg1F = %b sourceReg2F = %b",sourceReg1F,sourceReg2F);
    __display("function7 = %b function3 = %b result = %b",function7,function3,result);
    __display("a<b = %b, a<=b = %b, a==b = %b",less,lessequal,equal);
}
