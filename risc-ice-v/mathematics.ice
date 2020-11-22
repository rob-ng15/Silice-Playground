// Hardware Accelerated Multiplication and Division
// UNSIGNED / SIGNED 32 by 32 bit division giving 32 bit remainder and quotient

algorithm divideremainder (
    input   uint32  dividend,
    input   uint32  divisor,
    input   uint1   dosigned,

    output  uint32  quotient,
    output  uint32  remainder
) {
    uint32  dividend_copy = uninitialized;
    uint32  divisor_copy = uninitialized;

    uint1   resultsign = uninitialized;
    uint6   bit = uninitialized;


    bit = 32;

    if( divisor == 0 ) {
        // DIVISON by ZERO
        quotient = 32hffffffff;
        remainder = dividend;
    } else {
        quotient = 0;
        remainder = 0;

        dividend_copy = ( dosigned == 0 ) ? dividend : ( dividend[31,1] ? -dividend : dividend );
        divisor_copy = ( dosigned == 0 ) ? divisor : ( divisor[31,1] ? -divisor : divisor );
        resultsign = ( dosigned == 0 ) ? 0 : dividend[31,1] != divisor[31,1];

        ++:

        while( bit != 0 ) {
            if( __unsigned( { remainder[0,31], dividend_copy[bit - 1,1] } ) >= __unsigned(divisor_copy) ) {
                remainder = { remainder[0,31], dividend_copy[bit - 1,1] } - divisor_copy;
                quotient[bit - 1,1] = 1;
            } else {
                remainder = { remainder[0,31], dividend_copy[bit - 1,1] };
            }
            bit = bit - 1;
        }

        ++:

        quotient = resultsign ? -quotient : quotient;
    }
}

algorithm multiplication (
    input   uint32  factor_1,
    input   uint32  factor_2,
    input   uint2   dosigned,

    output  uint64  product
) {
    uint64  factor_1_copy = uninitialized;
    uint32  factor_2_copy = uninitialized;

    uint1   resultsign = uninitialized;

    factor_1_copy = ( dosigned == 0 ) ? factor_1 : ( ( factor_1[31,1] ) ? -factor_1 : factor_1 );
    factor_2_copy = ( dosigned != 1 ) ? factor_2 : ( ( factor_2[31,1] ) ? -factor_2 : factor_2 );

    resultsign = ( dosigned == 0 ) ? 0 : ( ( dosigned == 1 ) ? ( factor_1[31,1] != factor_2[31,1] ) : factor_1[31,1] );

    ++:

    while( factor_2_copy > 0 ) {
        product = ( factor_2_copy[0,1] ) ? ( resultsign ? product - factor_1_copy : product + factor_1_copy ) : product;
        factor_1_copy = factor_1_copy << 1;
        factor_2_copy = factor_2_copy >> 1;
    }
}
