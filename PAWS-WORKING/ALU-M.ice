// ALU - M EXTENSION

// UNSIGNED / SIGNED 32 by 32 bit division giving 32 bit remainder and quotient
algorithm dointdivbit(
    input   uint32  quotient,
    input   uint32  remainder,
    input   uint32  top,
    input   uint32  bottom,
    input   uint6   bit,
    output  uint32  newquotient,
    output  uint32  newremainder,
 ) <autorun> {
    uint32  temporary = uninitialized;
    uint1   bitresult = uninitialised;
    always {
        temporary = { remainder[0,31], top[bit,1] };
        bitresult = __unsigned(temporary) >= __unsigned(bottom);
        newremainder = __unsigned(temporary) - ( bitresult ? __unsigned(bottom) : 0 );
        newquotient = quotient | ( bitresult << bit );
    }
}
algorithm douintdivide(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint32  dividend,
    input   uint32  divisor,
    output  uint32  quotient,
    output  uint32  remainder
) <autorun> {
    dointdivbit DIVBIT(
        quotient <: quotient,
        remainder <: remainder,
        top <: dividend,
        bottom <: divisor,
        bit <: bit
    );
    uint6   bit(63);

    busy := start | ( bit != 63 );
    while(1) {
        if( start ) {
            bit = 31; quotient = 0; remainder = 0;
            while( bit != 63 ) { quotient = DIVBIT.newquotient; remainder = DIVBIT.newremainder; bit = bit - 1; }
        }
    }
}
algorithm aluMdivideremain(
    input   uint1   start,
    output  uint1   busy(0),

    input   uint3   dosign,
    input   uint32  dividend,
    input   uint32  divisor,

    output  uint32  result
) <autorun> {
    uint1   quotientremaindersign <: ~dosign[0,1] ? dividend[31,1] ^ divisor[31,1] : 0;

    douintdivide DODIVIDE();
    DODIVIDE.start := 0; DODIVIDE.dividend := ~dosign[0,1] ? ( dividend[31,1] ? -dividend : dividend ) : dividend; DODIVIDE.divisor := ~dosign[0,1] ? ( divisor[31,1] ? -divisor : divisor ) : divisor;

    while(1) {
        if( start ) {
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
    }
}

// UNSIGNED / SIGNED 32 by 32 bit multiplication giving 64 bit product using DSP blocks
algorithm douintmul(
    input   uint32  factor_1,
    input   uint32  factor_2,
    output  uint64  product
) <autorun> {
    product := factor_1 * factor_2;
}

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
