// MATHEMATICAL UNITS

// UNSIGNED / SIGNED 32 by 32 bit division giving 32 bit remainder and quotient
circuitry divideremainder(
    input   function3,
    input   dividend,
    input   divisor,
    output  result,
) {
    uint32  quotient = uninitialized;
    uint32  remainder = uninitialized;
    uint32  dividend_copy = uninitialized;
    uint32  divisor_copy = uninitialized;
    uint1   resultsign = uninitialized;
    uint6   bit = 31;

    quotient = ( divisor == 0 ) ? 32hffffffff : 0;
    remainder = ( divisor == 0 ) ? dividend : 0;
    dividend_copy = ~function3[0,1] ? ( dividend[31,1] ? -dividend : dividend ) : dividend;
    divisor_copy = ~function3[0,1] ? ( divisor[31,1] ? -divisor : divisor ) :divisor;
    resultsign = ~function3[0,1] ? dividend[31,1] != divisor[31,1] : 0;
    ++:
    if( divisor != 0 ) {
        while( bit != 63 ) {
            if( __unsigned({ remainder[0,31], dividend_copy[bit,1] }) >= __unsigned(divisor_copy) ) {
                remainder = __unsigned({ remainder[0,31], dividend_copy[bit,1] }) - __unsigned(divisor_copy);
                quotient[bit,1] = 1;
            } else {
                remainder = { remainder[0,31], dividend_copy[bit,1] };
            }
            bit = bit - 1;
        }
    }
    result = function3[1,1] ? remainder : ( resultsign ? -quotient : quotient );
}

// UNSIGNED / SIGNED 32 by 32 bit multiplication giving 64 bit product using DSP blocks
circuitry multiplication(
    input   function3,
    input   factor_1,
    input   factor_2,
    output  result
) {
    // FULLY SIGNED / PARTIALLY SIGNED / UNSIGNED and RESULT SIGNED FLAGS
    uint2   dosigned = uninitialized;
    uint1   resultsign = uninitialized;
    uint32  factor_1_copy = uninitialized;
    uint32  factor_2_copy = uninitialized;
    uint64  product = uninitialized;

    uint18  A = uninitialized;
    uint18  B = uninitialized;
    uint18  C = uninitialized;
    uint18  D = uninitialized;

    dosigned = function3[1,1] ? ( function3[0,1] ? 0 : 2 ) : 1;
    ++:
    resultsign = ( dosigned == 0 ) ? 0 : ( ( dosigned == 1 ) ? ( factor_1[31,1] != factor_2[31,1] ) : factor_1[31,1] );
    factor_1_copy = ( dosigned == 0 ) ? factor_1 : ( ( factor_1[31,1] ) ? -factor_1 : factor_1 );
    factor_2_copy = ( dosigned != 1 ) ? factor_2 : ( ( factor_2[31,1] ) ? -factor_2 : factor_2 );
    ++:
    // CALCULATION AB * CD
    A = { 2b0, factor_1_copy[16,16] };
    B = { 2b0, factor_1_copy[0,16] };
    C = { 2b0, factor_2_copy[16,16] };
    D = { 2b0, factor_2_copy[0,16] };
    ++:
    product = resultsign ? -( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } ) : ( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } );
    ++:
    result = ( function3 == 0 ) ? product[0,32] : product[32,32];
}
