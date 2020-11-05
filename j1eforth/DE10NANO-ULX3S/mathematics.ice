// Hardware Accelerated Mathematics For j1eforth

// UNSIGNED 32 by 16 bit division giving 16 bit remainder and quotient
// INPUT divisor from j1eforth is 16 bit expanded to 32 bit
// OUTPUT quotient and remainder are 32 bit, truncated by j1eforth

algorithm unsigneddiv(
    input   uint16  dividendh,
    input   uint16  dividendl,
    input   uint16  divisor,
    output  uint32  quotient,
    output  uint32  remainder,
    input   uint1   start,
    output  uint1   active
) <autorun> {
    uint32  dividend_copy = 0;
    uint32  divisor_copy = 0;
    uint5   bit = 0;

    while (1) {
        switch( active ) {
            case 0: {
                if( start ) {
                    if( divisor != 0 ) {
                        bit = 32;
                        quotient = 0;
                        remainder = 0;
                        dividend_copy = { dividendh, dividendl };
                        divisor_copy = { 16b0, divisor };
                        active = 1;
                    } else {
                        quotient = 32hffff;
                        remainder = 32hffff;
                    }
                }
            }

            case 1: {
                if( __unsigned( { remainder[0,31], dividend_copy[bit - 1,1] } ) >= __unsigned(divisor_copy) ) {
                    remainder = { remainder[0,31], dividend_copy[bit - 1,1] } - divisor_copy;
                    quotient[bit - 1,1] = 1;
                } else {
                    remainder = { remainder[0,31], dividend_copy[bit - 1,1] };
                }
                bit = bit - 1;
                active = ( bit != 0 ) ? 1 : 0;
            }
        }
    }
}

// SIGNED 32 by 16 bit division giving 16 bit remainder and quotient
// INPUT divisor from j1eforth is 16 bit expanded to 32 bit
// OUTPUT quotient and remainder are 32 bit, truncated by j1eforth

algorithm signeddiv(
    input   uint16  dividendh,
    input   uint16  dividendl,
    input   uint16  divisor,
    output  uint32  quotient,
    output  uint32  remainder,
    input   uint1   start,
    output  uint1   active
) <autorun> {
    uint32  dividend_copy = 0;
    uint32  divisor_copy = 0;
    uint32  quotient_copy = 0;
    uint32  remainder_copy = 0;
    uint1   resultsign = 0;
    uint5   bit = 0;

    quotient := resultsign ? -quotient_copy : quotient_copy;
    remainder := remainder_copy;

    while (1) {
        switch( active ) {
            case 0: {
                if( start ) {
                    if( divisor != 0 ) {
                        bit = 32;
                        quotient_copy = 0;
                        remainder_copy = 0;
                        dividend_copy = dividendh[15,1] ? -{ dividendh, dividendl } : { dividendh, dividendl };
                        divisor_copy = divisor[15,1] ? { 16b0, -divisor } : { 16b0, divisor };
                        resultsign = dividendh[15,1] != divisor[15,1];
                        active = 1;
                    } else {
                        resultsign = 0;
                        quotient_copy = 32hffff;
                        remainder_copy = 32hffff;
                    }
                }
            }

            case 1: {
                if( __unsigned( { remainder_copy[0,31], dividend_copy[bit - 1,1] } ) >= __unsigned(divisor_copy) ) {
                    remainder_copy = { remainder_copy[0,31], dividend_copy[bit - 1,1] } - divisor_copy;
                    quotient_copy[bit - 1,1] = 1;
                } else {
                    remainder_copy = { remainder_copy[0,31], dividend_copy[bit - 1,1] };
                }
                bit = bit - 1;
                active = ( bit != 0 ) ? 1 : 0;
            }
        }
    }
}

// SIGNED 16 by 16 bit division giving 16 bit remainder and quotient

algorithm signeddiv16bit(
    input   uint16  dividend,
    input   uint16  divisor,
    output  uint16  quotient,
    output  uint16  remainder,
    input   uint1   start,
    output  uint1   active
) <autorun> {
    uint16  dividend_copy = 0;
    uint16  divisor_copy = 0;
    uint16  quotient_copy = 0;
    uint16  remainder_copy = 0;
    uint1   resultsign = 0;
    uint5   bit = 0;

    quotient := resultsign ? -quotient_copy : quotient_copy;
    remainder := remainder_copy;

    while (1) {
        switch( active ) {
            case 0: {
                if( start ) {
                    if( divisor != 0 ) {
                        bit = 16;
                        quotient_copy = 0;
                        remainder_copy = 0;
                        dividend_copy = dividend[15,1] ? -dividend : dividend;
                        divisor_copy = divisor[15,1] ? -divisor : divisor;
                        resultsign = dividend[15,1] != divisor[15,1];
                        active = 1;
                    } else {
                        resultsign = 0;
                        quotient_copy = 16hffff;
                        remainder_copy = 16hffff;
                    }
                }
            }

            case 1: {
                if( __unsigned( { remainder_copy[0,15], dividend_copy[bit - 1,1] } ) >= __unsigned(divisor_copy) ) {
                    remainder_copy = { remainder_copy[0,15], dividend_copy[bit - 1,1] } - divisor_copy;
                    quotient_copy[bit - 1,1] = 1;
                } else {
                    remainder_copy = { remainder_copy[0,15], dividend_copy[bit - 1,1] };
                }
                bit = bit - 1;
                active = ( bit != 0 ) ? 1 : 0;
            }
        }
    }
}

// UNSIGNED 16 by 16 bit multiplication giving 32 bit product

algorithm unsignmult(
    input   uint16  factor1,
    input   uint16  factor2,
    output  uint32  product,

    input   uint1   start,
    output  uint1   active
) <autorun> {
    uint32  factor1copy = 0;
    uint16  factor2copy = 0;
    while(1) {
        switch( active ) {
            case 0: {
                if( start ) {
                    product = 0;
                    factor1copy = { 16b0, factor1 };
                    factor2copy = factor2;
                    active = 1;
                }
            }

            case 1: {
                if( factor2copy[0,1] ) {
                    product = product + factor1copy;
                }
                factor1copy = factor1copy << 1;
                factor2copy = factor2copy >> 1;
                active = ( factor2copy != 0 ) ? 1 : 0;
            }
        }
    }
}

// SIGNED 16 by 16 bit multiplication giving 32 bit product

algorithm signmult(
    input   uint16  factor1,
    input   uint16  factor2,
    output  uint32  product,

    input   uint1   start,
    output  uint1   active
) <autorun> {
    uint32  factor1copy = 0;
    uint16  factor2copy = 0;
    uint1   productsign = 0;

    while(1) {
        switch( active ) {
            case 0: {
                if( start ) {
                    product = 0;
                    factor1copy = factor1[15,1] ? { 16b0, -factor1 } : { 16b0, factor1 };
                    factor2copy = factor2[15,1] ? -factor2 : factor2;
                    productsign = factor1[15,1] != factor2[15,1];
                    active = 1;
                }
            }

            case 1: {
                if( factor2copy[0,1] ) {
                    product = ( productsign ) ? product - factor1copy : product + factor1copy;
                }
                factor1copy = factor1copy << 1;
                factor2copy = factor2copy >> 1;
                active = ( factor2copy != 0 ) ? 1 : 0;
            }
        }
    }
}

// Basic double arithmetic for j1eforth

algorithm doubleaddsub(
    input   uint16  operand1h,
    input   uint16  operand1l,
    input   uint16  operand2h,
    input   uint16  operand2l,

    output  uint32  total,
    output  uint32  difference,
    output  uint32  increment,
    output  uint32  decrement,
    output  uint32  times2,
    output  uint32  divide2,

    output  uint32  negation,
    output  uint32  binaryinvert,
    output  uint32  binaryxor,
    output  uint32  binaryor,
    output  uint32  binaryand,

    output  uint32  absolute,
    output  uint32  maximum,
    output  uint32  minimum,

    output  uint16  zeroequal,
    output  uint16  zeroless,
    output  uint16  equal,
    output  uint16  lessthan,
) <autorun> {
    uint32  operand1 := { operand1h, operand1l };
    uint32  operand2 := { operand2h, operand2l };

    total := operand1 + operand2;
    difference := operand1 - operand2;

    increment := operand1 + 1;
    decrement := operand1 - 1;

    times2 := operand1 << 1;
    divide2 := { operand1[31,1], operand1[1,31] };

    negation := -operand1;
    binaryinvert := ~operand1;

    binaryxor := operand1 ^ operand2;
    binaryor := operand1 | operand2;
    binaryand := operand1 & operand2;

    absolute := ( operand1[31,1] ) ? -operand1 : operand1;
    maximum := ( operand1 > operand2 ) ? operand1 : operand2;
    minimum := ( operand1 < operand2 ) ? operand1 : operand2;

    zeroequal := {16{(operand1 == 0)}};
    zeroless := {16{(operand1 < 0)}};
    equal := {16{(operand1 == operand2)}};
    lessthan := {16{(operand1 < operand2)}};

    while(1) {}
}
