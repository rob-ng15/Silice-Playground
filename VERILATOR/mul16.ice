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

algorithm main(output int8 leds) {
    uint2   FSM = uninitialised;

    // BIT Patterns can be obtained from http://weitz.de/ieee/
    // 1/3 = 16h3555
    // 1 = 16h3c00
    // 2 = 16h4000
    // 3 = 16h4200
    // 100 = 16h5640
    uint16  a = 16h36a0;
    uint16  b = 16h63d0;
    uint16  result = uninitialised;

    uint2   classEa = uninitialised;
    uint2   classEb = uninitialised;
    uint1   productsign <: a[15,1] ^ b[15,1];
    uint32  product = uninitialised;
    int8    productexp  = uninitialised;
    uint10  newfraction = uninitialised;

    //while(1) {
        //if( start ) {
            //busy = 1;
            FSM = 1;
            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {
                        ( classEa ) = classE( a );
                        ( classEb ) = classE( b );
                        product = { 6b1, a[0,10] } * { 6b1, b[0,10] };
                        productexp = (floatingpointnumber( a ).exponent - 15) + (floatingpointnumber( b ).exponent - 15) + product[21,1];
                    }
                    case 1: {
                        switch( classEa | classEb ) {
                            case 2b00: {
                                ( product ) = normalise22( product );
                                ( newfraction ) = round22( product );
                                ( productexp ) = adjustexp22( productexp, newfraction, product );
                                ( result ) = combinecomponents( productsign, productexp, newfraction );
                            }
                            case 2b01: { result = { productsign, 15b0 }; }
                            default: { result = { productsign, 5b11111, 10b0 }; }
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
