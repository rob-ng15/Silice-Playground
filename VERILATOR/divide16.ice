// BITFIELD FOR FLOATING POINT NUMBER - IEEE-754 32 bit format
bitfield floatingpointnumber{
    uint1   sign,
    uint5   exponent,
    uint10  fraction
}

// COMBINE COMPONENTS INTO FLOATING POINT NUMBER
// NOTE exp from addsub multiply divide is 8 bit biased ( ie, exp + 15 )
// small numbers return 0, bit numbers return max
circuitry combinecomponents( input sign, input exp, input fraction, output f16 ) {
    if( ( exp > 30 ) || ( exp < 0 ) ) {
        f16 = ( exp < 0 ) ? 0 : { sign, 5b01111, 10h3ff };
    } else {
        f16 = { sign, exp[0,5], fraction[0,10] };
    }
}

// CLASSIFY EXPONENT AND FRACTION or EXPONENT
circuitry classEF( output E, output F, input N ) {
    E = { ( floatingpointnumber(N).exponent ) == 5h1f, ( floatingpointnumber(N).exponent ) == 5h0 };
    F = ( floatingpointnumber(N).fraction ) == 0;
}
circuitry classE( output E, input N ) {
    E = { ( floatingpointnumber(N).exponent ) == 5h1f, ( floatingpointnumber(N).exponent ) == 5h0 };
}

// REALIGN A 22BIT NUMBER SO MSB IS 1
circuitry normalise22( inout bitstream ) {
    while( ~bitstream[21,1] ) {
        bitstream = { bitstream[0,21], 1b0 };
    }
}
// EXTRACT 10 BIT FRACTION FROM LEFT ALIGNED 22 BIT FRACTION WITH ROUNDING
circuitry round22( input bitstream, output roundfraction ) {
    roundfraction = bitstream[11,10] + bitstream[10,1];
}

// ADJUST EXPONENT IF ROUNDING FORCES, using newfraction and truncated bit from oldfraction
circuitry adjustexp22( inout exponent, input nf, input of ) {
    exponent = 15 + exponent + ( ( nf == 0 ) & of[10,1] );
}

circuitry divbit( inout quo, inout rem, input top, input bottom, input x ) {
    sameas( rem ) temp = uninitialized;
    uint1   quobit = uninitialised;

    temp = ( rem << 1 ) + top[x,1];
    quobit = __unsigned(temp) >= __unsigned(bottom);
    rem = __unsigned(temp) - ( quobit ? __unsigned(bottom) : 0 );
    quo[x,1] = quobit;
}

algorithm main(output int8 leds) {
    uint4   FSM = uninitialised;

    // BIT Patterns can be obtained from http://weitz.de/ieee/
    // 1/3 = 16h3555
    // 1 = 16h3c00
    // 2 = 16h4000
    // 3 = 16h4200
    // 100 = 16h5640
    uint16  a = 16h5640;
    uint16  b = 16h4200;
    uint16  result = uninitialised;

    uint2   classEa = uninitialised;
    uint2   classEb = uninitialised;
    uint1   quotientsign <: a[31,1] ^ b[31,1];
    int8    quotientexp = uninitialised;
    uint22  quotient = uninitialised;
    uint22  remainder = uninitialised;
    uint5   bit = uninitialised;
    uint22  sigA = uninitialised;
    uint22  sigB = uninitialised;
    uint10  newfraction = uninitialised;

    //while(1) {
        //if( start ) {
            //busy = 1;
            FSM = 1;

            __display("a = %x -> { %b %b %b } b = %x -> { %b %b %b }",a,a[15,1],a[10,5],a[0,10],b,b[15,1],b[10,5],b[0,10]);

            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {
                        ( classEa ) = classE( a );
                        ( classEb ) = classE( b );
                        sigA = { 1b1, floatingpointnumber(a).fraction, 11b0 };
                        sigB = { 12b1, floatingpointnumber(b).fraction };
                        quotientexp = (floatingpointnumber( a ).exponent - 15) - (floatingpointnumber( b ).exponent - 15);
                        quotient = 0;
                        remainder = 0;
                        bit = 21;
                    }
                    case 1: { while( ~sigB[0,1] ) { sigB = { 1b0, sigB[1,21] }; } }
                    case 2: {
                        __display("  Doing %b / %b",sigA,sigB);
                        switch( classEa | classEb ) {
                            case 2b00: {
                                while( bit != 31 ) {
                                    ( quotient, remainder ) = divbit( quotient, remainder, sigA, sigB, bit );
                                    __display("  bit = %d quotient = %b remainder = %b",bit, quotient,remainder);
                                    bit = bit - 1;
                                }
                            }
                            case 2b01: { result = ( classEb == 2b01 ) ? { quotientsign, 5b11111, 10b0 } : { quotientsign, 15b0 }; }
                            default: { result = { quotientsign, 5b11111, 10b0 }; }
                        }
                    }
                    case 3: {
                        if( ( classEa | classEb ) == 0 ) {
                            if( quotient == 0 ) {
                                result = { quotientsign, 15b0 };
                            } else {
                                ( quotient ) = normalise22( quotient );
                                ( newfraction ) = round22( quotient );
                                quotientexp = 15 + quotientexp - ( floatingpointnumber(b).fraction > floatingpointnumber(a).fraction ) + ( ( newfraction == 0 ) & quotient[12,1] );
                                ( result ) = combinecomponents( quotientsign, quotientexp, newfraction );
                                __display("VALID RESULT = %x { %b %b %b }",result,quotientsign,quotientexp,newfraction);
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
