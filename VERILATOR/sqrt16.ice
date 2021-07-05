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
    uint16  result = uninitialised;

    uint22  x = uninitialised;
    uint22  q = uninitialised;
    uint24  ac = uninitialised;
    uint24  test_res = uninitialised;
    uint6   i = uninitialised;

    uint2   classEa = uninitialised;
    uint1   sign <: floatingpointnumber( a ).sign;
    int8   exp  = uninitialised;
    uint23  newfraction = uninitialised;

    //while(1) {
        //if( start ) {
            //busy = 1;
            FSM = 1;
            ( classEa ) = classE( a );
            if( a[15,1] ) {
                result = { a[15,1], 5b11111, 10h3ff };
                __display("NEGATIVE result = %x { %b %b %b }",result,result[15,1],result[10,5],result[0,10]);
            } else {
                switch( classEa ) {
                    case 2b00: {
                        while( FSM != 0 ) {
                            onehot( FSM ) {
                                case 0: {
                                    i = 0;
                                    q = 0;
                                    exp = floatingpointnumber( a ).exponent - 15;
                                    ac = ~exp[0,1] ? 1 : { 22b0, 1b1, a[9,1] };
                                    x = ~exp[0,1] ? { a[0,10], 12b0 } : { a[0,9], 13b0 };
                                    __display("a = %x  -> { %b %b %b }",a,sign,exp,a[0,10],);
                                    __display("ac = %b x = %b",ac,x);
                                }
                                case 1: {
                                    while( i != 21 ) {
                                        test_res = ac - { q, 2b01 };
                                        ac = { test_res[23,1] ? ac[0,21] : test_res[0,21], x[20,2] };
                                        q = { q[0,21], ~test_res[23,1] };
                                        x = { x[0,20], 2b00 };
                                        __display("  i = %d ac = %x x = %x q = %x",i,ac,x,q);
                                        i = i + 1;
                                    }
                                }
                                case 2: {
                                    ( q ) = normalise22( q );
                                }
                                case 3: {
                                    exp = ( exp >>> 1 ) + 15;
                                    ( newfraction ) = round22( q );
                                    ( result ) = combinecomponents( sign, exp, newfraction );
                                     __display("root = { %b %b %b } -> %x",result[15,1],result[10,5],result[0,10],result);
                                }
                            }
                            FSM = { FSM[0,3], 1b0 };
                        }                    }
                    case 2b01: { result = 0; __display("ZERO"); }
                    default: { result = a; }
                }
            }
            //busy = 0;
        //}
    //}
}
