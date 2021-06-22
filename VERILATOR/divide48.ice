bitfield floatingpointnumber{
    uint1   sign,
    uint8   exponent,
    uint23  fraction
}

circuitry combinecomponents( input sign, input exp, input fraction, output f32 ) {
    if( ( exp > 254 ) || ( exp < 0 ) ) {
        f32 = ( exp < 0 ) ? 0 : { sign, 8b01111111, 23h7fffff };
    } else {
        f32 = { sign, exp[0,8], fraction[0,23] };
    }
}
circuitry classEF( output E, output F, input N ) {
    E = { ( floatingpointnumber(N).exponent ) == 8hff, ( floatingpointnumber(N).exponent ) == 8h00 };
    F = ( floatingpointnumber(N).fraction ) == 23h0000;
}
circuitry classE( output E, input N ) {
    E = { ( floatingpointnumber(N).exponent ) == 8hff, ( floatingpointnumber(N).exponent ) == 8h00 };
}

circuitry divbit( inout rem, inout quo, input top, input bottom, input x  ) {
    sameas(rem) temp= uninitialised;

    temp = ( rem << 1 ) + top[bit,1];
    switch( __unsigned(temp) >= __unsigned(bottom) ) {
        case 1: { rem = __unsigned(temp) - __unsigned(bottom); quo[bit,1] = 1; }
        case 0: { rem = temp; }
    }
}

algorithm main(output int8 leds) {
    uint4   FSM = uninitialised;

    // BIT Patterns can be obtained from http://weitz.de/ieee/
    // 1/3 = 32h3eaaaaab
    // 1 = 32h3F800000
    // 2 = 32h40000000
    // 3 = 32h40400000
    // 100 = 32h42C80000
    uint32  a = 32h3F800000;
    uint32  b = 32h3eaaaaab;
    uint32  result = uninitialised;

    uint2   classEa = uninitialised;
    uint2   classEb = uninitialised;
    uint1   quotientsign = uninitialised;
    int16   quotientexp = uninitialised;
    uint48  quotient = uninitialised;
    uint48  remainder = uninitialised;
    uint6   bit = uninitialised;
    uint48  sigA = uninitialised;
    uint48  sigB = uninitialised;
    uint23  newfraction = uninitialised;

    //while(1) {
        //if( start ) {
            //busy = 1;
            FSM = 1;

            __display("a = %x -> { %b %b %b } b = %x -> { %b %b %b }",a,a[31,1],a[23,8],sigA,b,b[31,1],b[23,8],sigB);

            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {
                        ( classEa ) = classE( a );
                        ( classEb ) = classE( b );
                        sigA = { 1b1, floatingpointnumber(a).fraction, 24b0 };
                        sigB = { 25b1, floatingpointnumber(b).fraction };
                        quotientsign = a[31,1] ^ b[31,1];
                        quotientexp = (floatingpointnumber( a ).exponent - 127) - (floatingpointnumber( b ).exponent - 127);
                        quotient = 0;
                        remainder = 0;
                        bit = 47;
                    }
                    case 1: { while( ~sigB[0,1] ) { sigB = { 1b0, sigB[1,31] }; } __display("  Doing %b / %b",sigA,sigB); }
                    case 2: {
                        switch( classEa | classEb ) {
                            case 2b00: {
                                while( bit != 63 ) {
                                    ( quotient, remainder ) = divbit( quotient, remainder, sigA, sigB, bit );
                                    __display("  bit = %d quotient = %b remainder = %b",bit, quotient,remainder);
                                    bit = bit - 1;
                                }
                            }
                            case 2b01: { result = ( classEb == 2b01 ) ? { quotientsign, 8b11111111, 23b0 } : { quotientsign, 31b0 }; }
                            default: { result = { quotientsign, 8b11111111, 23b0 }; }
                        }
                    }
                    case 3: {
                        switch( classEa | classEb ) {
                            case 2b00: {
                                switch( quotient ) {
                                    case 0: { result = { quotientsign, 31b0 }; }
                                    default: {
                                        while( ~quotient[47,1] ) {
                                            quotient = { quotient[0,47], 1b0 };
                                        }
                                        newfraction = quotient[24,23] + quotient[23,1];
                                        quotientexp = 127 + quotientexp - ( floatingpointnumber(b).fraction > floatingpointnumber(a).fraction ) + ( ( newfraction == 0 ) & quotient[23,1] );
                                        ( result ) = combinecomponents( quotientsign, quotientexp, newfraction );
                                        __display("VALID RESULT = %x { %b %b %b }",result,quotientsign,quotientexp,newfraction);
                                    }
                                }
                            }
                        }
                    }
                }
                FSM = { FSM[0,3], 1b0 };
            }
            //busy = 0;
        //}
    //}
}
