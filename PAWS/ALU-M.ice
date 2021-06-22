// ALU - M EXTENSION

// UNSIGNED / SIGNED 32 by 32 bit division giving 32 bit remainder and quotient

$$if not divbit_circuit then
$$divbit_circuit = 1
// PERFORM DIVISION AT SPECIFIC BIT, SHARED BETWEEN INTEGER AND  FLOATING POINT DIVISION
circuitry divbit( inout quo, inout rem, input top, input bottom, input x ) {
    sameas( rem ) temp = uninitialized;
    uint1   quobit = uninitialised;

    temp = ( rem << 1 ) + top[x,1];
    quobit = __unsigned(temp) >= __unsigned(bottom);
    rem = __unsigned(temp) - ( quobit ? __unsigned(bottom) : 0 );
    quo[x,1] = quobit;
}
$$end

algorithm aluMdivideremain(
    input   uint1   start,
    output  uint1   busy,

    input   uint3   dosign,
    input   uint32  dividend,
    input   uint32  divisor,

    output  uint32  result
) <autorun> {
    uint2   FSM = uninitialized;

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
                                    ( quotient, remainder ) = divbit( quotient, remainder, dividend_copy, divisor_copy, bit );
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

$$if not uintmul_algo then
$$uintmul_algo = 1
algorithm douintmul(
    input   uint32  factor_1,
    input   uint32  factor_2,
    output  uint64  product
) <autorun> {
    uint18    A <: { 2b0, factor_1[16,16] };
    uint18    B <: { 2b0, factor_1[0,16] };
    uint18    C <: { 2b0, factor_2[16,16] };
    uint18    D <: { 2b0, factor_2[0,16] };
    product := ( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } );
}
$$end

algorithm aluMmultiply(
    input   uint3   dosign,
    input   uint32  factor_1,
    input   uint32  factor_2,

    output  uint32  result
) <autorun> {
    uint2   dosigned <: dosign[1,1] ? ( dosign[0,1] ? 0 : 2 ) : 1;
    uint1   productsign <: ( dosigned == 0 ) ? 0 : ( ( dosigned == 1 ) ? ( factor_1[31,1] ^ factor_2[31,1] ) : factor_1[31,1] );
    uint64  product <: productsign ? -UINTMUL.product : UINTMUL.product;

    douintmul UINTMUL();
    UINTMUL.factor_1 := ( dosigned == 0 ) ? factor_1 : ( ( factor_1[31,1] ) ? -factor_1 : factor_1 );
    UINTMUL.factor_2 := ( dosigned != 1 ) ? factor_2 : ( ( factor_2[31,1] ) ? -factor_2 : factor_2 );

    result := ( dosign == 0 ) ? product[0,32] : product[32,32];
}
