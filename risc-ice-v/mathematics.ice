// Hardware Accelerated Multiplication and Division
// UNSIGNED / SIGNED 32 by 32 bit division giving 32 bit remainder and quotient

algorithm divideremainder (
    input   uint3   function3,

    input   uint32  dividend,
    input   uint32  divisor,

    input   uint1   start,
    output  uint1   active,

    output  uint32  result,
) <autorun> {
    uint32  quotient = uninitialized;
    uint32  remainder = uninitialized;
    uint32  dividend_copy = uninitialized;
    uint32  divisor_copy = uninitialized;

    uint1   dosigned := function3[0,1] ? 0 : 1;
    uint1   resultsign = uninitialized;
    uint6   bit = uninitialized;
    uint6   count = uninitialized;

    uint1   busy = 0;

    active := start ? 1 : busy;
    result := function3[1,1] ? remainder : ( resultsign ? -quotient : quotient );

    while(1) {
        if( start ) {
            busy = 1;
            bit = 31;


            if( divisor == 0 ) {
                // DIVISON by ZERO
                quotient = 32hffffffff;
                remainder = dividend;
                busy = 0;
            } else {
                quotient = 0;
                remainder = 0;
                dividend_copy = dosigned ? ( dividend[31,1] ? -dividend : dividend ) : dividend;
                divisor_copy = dosigned ?  ( divisor[31,1] ? -divisor : divisor ) :divisor;
                resultsign = dosigned ?  dividend[31,1] != divisor[31,1] : 0;
                ++:
                while( bit != 63 ) {
                    if( __unsigned({ remainder[0,31], dividend_copy[bit,1] }) >= __unsigned(divisor_copy) ) {
                        remainder = __unsigned({ remainder[0,31], dividend_copy[bit,1] }) - __unsigned(divisor_copy);
                        quotient[bit,1] = 1;
                    } else {
                        remainder = { remainder[0,31], dividend_copy[bit,1] };
                    }
                    bit = bit - 1;
                }
                ++:
                busy = 0;
            }
        }
    }
}

// UNSIGNED / SIGNED 32 by 32 bit multiplication giving 64 bit product
// DSP BLOCKS

algorithm multiplicationDSP (
    input   uint3   function3,

    input   uint32  factor_1,
    input   uint32  factor_2,

    input   uint1   start,
    output  uint1   active,

    output  uint32  result
) <autorun> {
    uint32  factor_1_copy := ( dosigned == 0 ) ? factor_1 : ( ( factor_1[31,1] ) ? -factor_1 : factor_1 );
    uint32  factor_2_copy := ( dosigned != 1 ) ? factor_2 : ( ( factor_2[31,1] ) ? -factor_2 : factor_2 );
    uint64  product = uninitialized;
    uint1   busy = 0;

    // CALCULATION AB * CD
    uint18  A := { 2b0, factor_1_copy[16,16] };
    uint18  B := { 2b0, factor_1_copy[0,16] };
    uint18  C := { 2b0, factor_2_copy[16,16] };
    uint18  D := { 2b0, factor_2_copy[0,16] };

    // FULLY SIGNED / PARTIALLY SIGNED / UNSIGNED and RESULT SIGNED FLAGS
    uint2   dosigned := function3[1,1] ? ( function3[0,1] ? 0 : 2 ) : 1;
    uint1   resultsign := ( dosigned == 0 ) ? 0 : ( ( dosigned == 1 ) ? ( factor_1[31,1] != factor_2[31,1] ) : factor_1[31,1] );

    active := start ? 1 : busy;
    result := ( function3 == 0 ) ? product[0,32] : product[32,32];

    while(1) {
        if( start ) {
            busy = 1;
            ++:
            product = D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 };
            ++:
            product = resultsign ? -product : product;
            ++:
            busy = 0;
        }
    }
}
