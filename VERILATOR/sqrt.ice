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

algorithm main(output int8 leds) {
    uint4   FSM = uninitialised;

    // BIT Patterns can be obtained from http://weitz.de/ieee/
    // 1 = 32h3F800000 -> 32h3F800000
    // 2 = 32h40000000 -> 32h3fb504f3
    // 100 = 32h42C80000 -> 32h41200000 ( actual answer returned is 32411cc470 = 9.797958 )
    uint32  a = 32h42C80000;
    uint32  result = uninitialised;
    uint32  x = uninitialised;
    uint32  q = uninitialised;
    uint34  ac = uninitialised;
    uint34  test_res = uninitialised;
    uint6   i = uninitialised;

    uint2   classEa = uninitialised;
    uint1   sign = uninitialised;
    uint8   exp  = uninitialised;
    uint23  fraction = uninitialised;

    //while(1) {
        //if( start ) {
            //busy = 1;
            FSM = 1;
            if( ( a == 0 ) || ( a[31,1] ) ) {
                result = ( a == 0 ) ? 0 : { a[31,1], 8b11111111, 23b0 };
            } else {
                while( FSM != 0 ) {
                    onehot( FSM ) {
                        case 0: {
                            i = 0;
                            q = 0;
                            sign = floatingpointnumber( a ).sign;
                            exp = floatingpointnumber( a ).exponent;
                            fraction = floatingpointnumber( a ).fraction;

                            if( exp[0,1] ) {
                                ac = 1;
                                x = { floatingpointnumber( a ).fraction, 9b0 };
                            } else {
                                ac = { 32b0, 1b1, fraction[22,1] };
                                x = { fraction[0,22], 10b0 };
                            }

                            __display("a = %x -> { %b %b %b } ac = %x x = %x",a,sign,exp,fraction,ac,x);
                        }
                        case 1: {
                            while( i != 31 ) {
                                test_res = ac - { q, 2b01 };
                                if( test_res[32,1] == 0 ) {
                                    ac = { test_res[0,31], x[30,2] };
                                    x = { x[0,30], 2b00 };
                                    q = { q[0,30], 1b1 };
                                } else {
                                    ac = { ac[0,31], x[0,2] };
                                    x = { x[0,30], 2b00 };
                                    q = q << 1;
                                }
                                __display("  i = %d ac = %x x = %x q = %x",i,ac,x,q);
                                i = i + 1;
                            }
                        }
                        case 2: {
                            exp = exp - 127;
                            while( ~q[31,1] ) {
                                q = { q[0,31], 1b0 };
                            }
                    }
                        case 3: {
                            exp = ( exp >>> 1 ) + 127;
                            fraction = q[8,23];
                            ( result ) = combinecomponents( sign, exp, fraction );
                            __display("root = { %b %b %b } -> %x",sign,exp,fraction,result);
                        }
                    }
                    FSM = { FSM[0,3], 1b0 };
                }
            }
            // busy = 0;
        //}
    //}
}
