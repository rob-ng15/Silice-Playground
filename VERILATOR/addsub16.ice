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
    uint5   FSM = uninitialised;

    // BIT Patterns can be obtained from http://weitz.de/ieee/
    // 1/3 = 16h3555
    // 1 = 16h3c00
    // 2 = 16h4000
    // 3 = 16h4200
    // 100 = 16h5640
    uint16  a = 16h3da8;
    uint16  b = 16h3c00;
    uint1   addsub = 1;
    uint16  result = uninitialised;

    uint2   classEa = uninitialised;
    uint2   classEb = uninitialised;
    uint1   sign = uninitialised;
    uint1   signA = uninitialised;
    uint1   signB = uninitialised;
    int8    expA = uninitialised;
    int8    expB = uninitialised;
    uint22  sigA = uninitialised;
    uint22  sigB = uninitialised;
    uint22  newfraction = uninitialised;
    uint1   round = uninitialised;

    //busy = 0;

    //while(1) {
        //if( start ) {
            //busy = 1;
            FSM = 1;
            round = 1;
            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {
                        // FOR SUBTRACTION CHANGE SIGN OF SECOND VALUE
                        signA = a[15,1]; signB = addsub ? ~b[15,1] : b[15,1];
                        ( classEa ) = classE( a );
                        ( classEb ) = classE( b );
                        __display("DOING a { %b %b %b } + b { %b %b %b }",a[15,1],a[10,5],a[0,10],b[15,1],b[10,5],b[0,10]);
                    }
                    case 1: {
                        // EXTRACT COMPONENTS - HOLD TO LEFT TO IMPROVE FRACTIONAL ACCURACY
                        expA = floatingpointnumber( a ).exponent - 15;
                        expB = floatingpointnumber( b ).exponent - 15;
                        sigA = { 2b01, floatingpointnumber(a).fraction, 10b0 };
                        sigB = { 2b01, floatingpointnumber(b).fraction, 10b0 };
                        sign = floatingpointnumber(a).sign;
                        __display("a  %b",sigA);
                        __display("b  %b",sigB);
                    }
                    case 2: {
                        // ADJUST TO EQUAL EXPONENTS
                        if( expA < expB ) {
                            sigA = sigA >> ( expB - expA );
                            expA = expB;
                        } else {
                            if( expB < expA ) {
                                sigB = sigB >> ( expA - expB );
                                expB = expA;
                            }
                        }
                        __display("a  %b",sigA);
                        __display("b  %b",sigB);
                    }
                    case 3: {
                        switch( classEa | classEb ) {
                            case 2b00: {
                                switch( { signA, signB } ) {
                                    // PERFORM + HANDLING SIGNS
                                    case 2b01: {
                                        if( sigB > sigA ) {
                                            sign = 1;
                                            round = ( sigA != 0 );
                                            sigA = sigB - ( ~round ? 1 : sigA );
                                        } else {
                                            sign = 0;
                                            round = ( sigB != 0 );
                                            sigA = sigA - ( ~round ? 1 : sigB );
                                        }
                                    }
                                    case 2b10: {
                                        if(  sigA > sigB ) {
                                            sign = 1;
                                            round = ( sigB != 0 );
                                            sigA = sigA - ( ~round ? 1 : sigB );
                                        } else {
                                            sign = 0;
                                            round = ( sigA != 0 );
                                            sigA = sigB - ( ~round ? 1 : sigA );
                                        }
                                    }
                                    default: { sign = signA; sigA = sigA + sigB; }
                                }
                            }
                            case 2b01: { result = ( classEb == 2b01 ) ? a : addsub ? { ~b[15,1], b[0,15] } : b; }
                            default: { result = { 1b0, 5b11111, 10b0 }; }
                        }
                    }
                    case 4: {
                        if( ( classEa | classEb ) == 0 ) {
                            if( sigA == 0 ) {
                                result = 0;
                            } else {
                                // NORMALISE AND ROUND
                                if( sigA[21,1] ) {
                                    expA = expA + 1;
                                } else {
                                    while( ~sigA[20,1] ) {
                                        sigA = { sigA[0,21], 1b0 };
                                        expA = expA - 1;
                                    }
                                    sigA = { sigA[0,21], 1b0 };
                                }
                                sigA[10,1] = sigA[10,1] & round;
                                ( newfraction ) = round22( sigA );
                                ( expA ) = adjustexp22( exp, newfraction, sigA );
                                ( result ) = combinecomponents( sign, expA, newfraction );
                                __display("RESULT { %b %b %b } -> %x",result[15,1],result[10,5],result[0,10],result);
                            }
                        }
                    }
                }
                FSM = { FSM[0,5], 1b0 };
            }
            //busy = 0;
        //}
    //}
}
