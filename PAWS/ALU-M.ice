// ALU - M EXTENSION

// UNSIGNED / SIGNED 32 by 32 bit division giving 32 bit remainder and quotient

$$if not divbit_circuit then
$$divbit_circuit = 1
// PERFORM DIVISION AT SPECIFIC BIT, SHARED BETWEEN INTEGER AND  FLOATING POINT DIVISION
circuitry divbit( inout quo, inout rem, input top, input bottom, input x ) {
    sameas( rem ) temp = uninitialized;
    uint1   quobit = uninitialised;

    temp = ( rem << 1 ) | top[x,1];
    quobit = __unsigned(temp) >= __unsigned(bottom);
    rem = __unsigned(temp) - ( quobit ? __unsigned(bottom) : 0 );
    quo[x,1] = quobit;
}
$$end
algorithm douintdivide(
    input   uint1   start,
    output  uint1   busy,
    input   uint32  dividend,
    input   uint32  divisor,
    output  uint32  quotient,
    output  uint32  remainder
) <autorun> {
    uint6   bit = uninitialised;
    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                bit = 31; quotient = 0; remainder = 0;
                while( bit != 63 ) { ( quotient, remainder ) = divbit( quotient, remainder, dividend, divisor, bit ); bit = bit - 1; }
                busy = 0;
            }
        }
    }
}

algorithm aluMdivideremain(
    input   uint1   start,
    output  uint1   busy,

    input   uint3   dosign,
    input   uint32  dividend,
    input   uint32  divisor,

    output  uint32  result
) <autorun> {
    uint1   quotientremaindersign <: ~dosign[0,1] ? dividend[31,1] ^ divisor[31,1] : 0;

    douintdivide DODIVIDE();
    DODIVIDE.start := 0; DODIVIDE.dividend := ~dosign[0,1] ? ( dividend[31,1] ? -dividend : dividend ) : dividend; DODIVIDE.divisor := ~dosign[0,1] ? ( divisor[31,1] ? -divisor : divisor ) : divisor;
    busy = 0;

    while(1) {
        switch( start ) {
            case 1: {
                busy = 1;
                switch( divisor ) {
                    case 0: { result = dosign[1,1] ? dividend : 32hffffffff; }
                    default: {
                        DODIVIDE.start = 1; while( DODIVIDE.busy ) {}
                        result = dosign[1,1] ? DODIVIDE.remainder : ( quotientremaindersign ? -DODIVIDE.quotient : DODIVIDE.quotient );
                    }
                }
                busy = 0;
            }
            default: {}
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
    product := factor_1 * factor_2;
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

    result := product[ ( dosign == 0 ) ? 0 : 32, 32 ];
}
