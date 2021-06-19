// ALU - M EXTENSION

// UNSIGNED / SIGNED 32 by 32 bit division giving 32 bit remainder and quotient
algorithm aluMdivideremain(
    input   uint1   start,
    output  uint1   busy,

    input   uint3   dosign,
    input   uint32  dividend,
    input   uint32  divisor,

    output  uint32  result
) <autorun> {
    uint2   FSM = uninitialized;
    uint1   FSM2 = uninitialized;

    uint32  temporary = uninitialized;
    uint32  quotient = uninitialized;
    uint32  remainder = uninitialized;
    uint32  dividend_copy = uninitialized;
    uint32  divisor_copy = uninitialized;
    uint1   quotientremaindersign = uninitialized;
    uint6   bit = uninitialized;

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            FSM = 1;
            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {
                        dividend_copy = ~dosign[0,1] ? ( dividend[31,1] ? -dividend : dividend ) : dividend;
                        divisor_copy = ~dosign[0,1] ? ( divisor[31,1] ? -divisor : divisor ) : divisor;
                        quotientremaindersign = ~dosign[0,1] ? dividend[31,1] ^ divisor[31,1] : 0;
                        quotient = 0;
                        remainder = 0;
                        bit = 31;
                    }
                    case 1: {
                        switch( divisor ) {
                            case 0: { result = dosign[1,1] ? dividend : 32hffffffff; }
                            default: {
                                while( bit != 63 ) {
                                    temporary = { remainder[0,31], dividend_copy[bit,1] };
                                    FSM2 = __unsigned(temporary) >= __unsigned(divisor_copy);
                                    switch( FSM2 ) {
                                        case 1: { remainder = __unsigned(temporary) - __unsigned(divisor_copy); quotient[bit,1] = 1; }
                                        case 0: { remainder = temporary; }
                                    }
                                   bit = bit - 1;
                                }
                                result = dosign[1,1] ? remainder : ( quotientremaindersign ? -quotient : quotient );
                            }
                        }
                    }
                }
                FSM = { FSM[0,1], 1b0 };
            }
            busy = 0;
        }
    }
}

// UNSIGNED / SIGNED 32 by 32 bit multiplication giving 64 bit product using DSP blocks
algorithm aluMmultiply(
    input   uint3   dosign,
    input   uint32  factor_1,
    input   uint32  factor_2,

    output  uint32  result
) <autorun> {
    uint2   dosigned = uninitialized;
    uint1   productsign = uninitialized;
    uint32  factor_1_copy = uninitialized;
    uint32  factor_2_copy = uninitialized;
    uint64  product = uninitialized;

    // Calculation is split into 4 18 x 18 multiplications for DSP
    uint18  A = uninitialized;
    uint18  B = uninitialized;
    uint18  C = uninitialized;
    uint18  D = uninitialized;
    while(1) {
        dosigned = dosign[1,1] ? ( dosign[0,1] ? 0 : 2 ) : 1;
        productsign = ( dosigned == 0 ) ? 0 : ( ( dosigned == 1 ) ? ( factor_1[31,1] ^ factor_2[31,1] ) : factor_1[31,1] );
        factor_1_copy = ( dosigned == 0 ) ? factor_1 : ( ( factor_1[31,1] ) ? -factor_1 : factor_1 );
        factor_2_copy = ( dosigned != 1 ) ? factor_2 : ( ( factor_2[31,1] ) ? -factor_2 : factor_2 );
        A = { 2b0, factor_1_copy[16,16] };
        B = { 2b0, factor_1_copy[0,16] };
        C = { 2b0, factor_2_copy[16,16] };
        D = { 2b0, factor_2_copy[0,16] };
        product = productsign ? -( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } ) : ( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } );
        result = ( dosign == 0 ) ? product[0,32] : product[32,32];
    }
}
