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
    uint2   FSM = uninitialised;
    uint2   FSM2 = uninitialised;

    int16  a = -7;
    uint16  result = uninitialised;

    uint1   sign = uninitialised;
    int8    exp = uninitialised;
    uint8   zeros = uninitialised;
    uint16  number = uninitialised;

    //busy = 0;

    //while(1) {
        //if( start ) {
            //busy = 1;
            FSM = 1;
            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {
                        // SIGNED / UNSIGNED
                        __display("a = %d",a);
                        sign = a[15,1];
                        number = a[15,1] ? -a : a ;
                        __display(" sign = %b number = %d",sign,number);
                    }
                    case 1: {
                        if( number == 0 ) {
                            result = 0;
                        } else {
                            FSM2 = 1;
                            while( FSM2 !=0 ) {
                                onehot( FSM2 ) {
                                    case 0: { zeros = 0; while( ~number[ 15-zeros, 1 ] ) { zeros = zeros + 1; } }
                                    case 1: {
                                        number = ( zeros < 5 ) ? number >> ( 5 - zeros ) : ( zeros > 5 ) ? number << ( zeros - 5 ) : number;
                                        exp = 30 - zeros;
                                        ( result ) = combinecomponents( sign, exp, number );
                                    }
                                }
                                FSM2 = { FSM2[0,1], 1b0 };
                            }
                        }
                    }
                }
                FSM = { FSM[0,1], 1b0 };
            }
            __display("RESULT = { %b %b %b } -> %x",result[15,1],result[10,5],result[0,10],result);
            //busy = 0;
        //}
    //}
}
