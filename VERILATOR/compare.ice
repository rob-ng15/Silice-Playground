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
    uint32  a = 32h3F59490E;
    uint32  b = 32h3eaaaaab;
    uint1   less = uninitialised;
    uint1   lessequal = uninitialised;
    uint1   equal = uninitialised;

    ( less ) = floatless( a, b );
    ( lessequal ) = floatlessequal( a, b );
    ( equal ) = floatequal( a, b );

    __display("a<b = %b, a<=b = %b, a==b = %b",less,lessequal,equal);
}
