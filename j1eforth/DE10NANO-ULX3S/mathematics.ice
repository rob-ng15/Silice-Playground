// Hardware Accelerated Mathematics For j1eforth

// UNSIGNED / SIGNED 32 by 16 bit division giving 16 bit remainder and quotient
// INPUT divisor from j1eforth is 16 bit expanded to 32 bit
// OUTPUT quotient and remainder are 16 bit

algorithm divmod32by16 (
    input   uint16  dividendh,
    input   uint16  dividendl,
    input   uint16  divisor,
    output  uint16  quotient,
    output  uint16  remainder,
    input   uint2   start,
    output  uint1   active
) <autorun> {
    uint32  dividend_copy = uninitialized;
    uint32  divisor_copy = uninitialized;
    uint32  quotient_copy = uninitialized;
    uint32  remainder_copy = uninitialized;
    uint1   resultsign = uninitialized;
    uint6   bit = uninitialized;

    while (1) {
        if( start != 0 ) {

            if( divisor == 0 ) {
                // DIVIDE BY 0
                quotient_copy = 32hffff;
                remainder_copy = divisor;
            } else {
                bit = 32;
                quotient_copy = 0;
                remainder_copy = 0;

                dividend_copy = ( start == 1 ) ? { dividendh, dividendl } : dividendh[15,1] ? -{ dividendh, dividendl } : { dividendh, dividendl };
                divisor_copy = ( start == 1 ) ? { 16b0, divisor } : divisor[15,1] ? { 16b0, -divisor } : { 16b0, divisor };
                resultsign = ( start == 1 ) ? 0 : dividendh[15,1] != divisor[15,1];

                active = 1;

                ++:

                while( bit != 0 ) {
                    if( __unsigned( { remainder_copy[0,31], dividend_copy[bit - 1,1] } ) >= __unsigned(divisor_copy) ) {
                        remainder_copy = { remainder_copy[0,31], dividend_copy[bit - 1,1] } - divisor_copy;
                        quotient_copy[bit - 1,1] = 1;
                    } else {
                        remainder_copy = { remainder_copy[0,31], dividend_copy[bit - 1,1] };
                    }
                    bit = bit - 1;
                }

                ++:

                quotient = resultsign ? -quotient_copy[0,16] : quotient_copy[0,16];
                remainder = remainder_copy[0,16];
                active = 0;

            }
        }

    }
}

// SIGNED 16 by 16 bit division giving 16 bit remainder and quotient

algorithm divmod16by16 (
    input   uint16  dividend,
    input   uint16  divisor,
    output  uint16  quotient,
    output  uint16  remainder,
    input   uint1   start,
    output  uint1   active
) <autorun> {
    uint16  dividend_copy = uninitialized;
    uint16  divisor_copy = uninitialized;
    uint16  quotient_copy = uninitialized;
    uint16  remainder_copy = uninitialized;
    uint1   resultsign = uninitialized;
    uint6   bit = uninitialized;

    while (1) {
        if( start ) {
            if( divisor != 0 ) {
                bit = 16;
                quotient_copy = 0;
                remainder_copy = 0;
                dividend_copy = dividend[15,1] ? -dividend : dividend;
                divisor_copy = divisor[15,1] ? -divisor : divisor;
                resultsign = dividend[15,1] != divisor[15,1];
                active = 1;

                ++:

                while( bit != 0 ) {
                    if( __unsigned( { remainder_copy[0,15], dividend_copy[bit - 1,1] } ) >= __unsigned(divisor_copy) ) {
                        remainder_copy = { remainder_copy[0,15], dividend_copy[bit - 1,1] } - divisor_copy;
                        quotient_copy[bit - 1,1] = 1;
                    } else {
                        remainder_copy = { remainder_copy[0,15], dividend_copy[bit - 1,1] };
                    }
                    bit = bit - 1;
                }

                ++:

                quotient = resultsign ? -quotient_copy : quotient_copy;
                remainder = remainder_copy;
                active = 0;
            } else {
                quotient_copy = 16hffff;
                remainder_copy = divisor;
            }
        }
    }
}

// UNSIGNED / SIGNED 16 by 16 bit multiplication giving 32 bit product
// DSP INFERENCE

algorithm multi16by16to32DSP (
    input   uint16  factor1,
    input   uint16  factor2,
    output  uint32  product,

    input   uint2   start,
    output  uint1   active
) <autorun> {
    uint18  factor1copy = uninitialized;
    uint18  factor2copy = uninitialized;

    uint32  nosignproduct = uninitialized;
    uint1   productsign = uninitialized;

    while(1) {
        if( start != 0 ) {
            switch( start ) {
                case 1: {
                    // UNSIGNED MULTIPLICATION
                    factor1copy = factor1;
                    factor2copy = factor2;
                    productsign = 0;
                }
                case 2: {
                    // SIGNED MULTIPLICATION
                    product = 0;
                    factor1copy = { 2b0, factor1[15,1] ? -factor1 : factor1 };
                    factor2copy = { 2b0, factor2[15,1] ? -factor2 : factor2 };
                    productsign = factor1[15,1] != factor2[15,1];
                }
            }
            product = 0;
            active = 1;

            ++:

            // PERFORM UNSIGNED MULTIPLICATION
            nosignproduct = factor1copy * factor2copy;

            ++:

            product = productsign ? -nosignproduct : nosignproduct;
            active = 0;
        }
    }
}

// Basic double arithmetic for j1eforth
// 2 input operations

algorithm doubleaddsub2input(
    input   uint16  operand1h,
    input   uint16  operand1l,
    input   uint16  operand2h,
    input   uint16  operand2l,

    output  uint32  total,
    output  uint32  difference,

    output  uint32  binaryxor,
    output  uint32  binaryor,
    output  uint32  binaryand,

    output  uint32  maximum,
    output  uint32  minimum,

    output  uint16  equal,
    output  uint16  lessthan
) <autorun> {
    uint32  operand1 := { operand1h, operand1l };
    uint32  operand2 := { operand2h, operand2l };

    total := operand1 + operand2;
    difference := operand1 - operand2;


    binaryxor := operand1 ^ operand2;
    binaryor := operand1 | operand2;
    binaryand := operand1 & operand2;

    maximum := ( operand1 > operand2 ) ? operand1 : operand2;
    minimum := ( operand1 < operand2 ) ? operand1 : operand2;

    equal := {16{(operand1 == operand2)}};
    lessthan := {16{(operand1 < operand2)}};

    while(1) {}
}

// 1 input operations

algorithm doubleaddsub1input(
    input   uint16  operand1h,
    input   uint16  operand1l,

    output  uint32  increment,
    output  uint32  decrement,

    output  uint32  times2,
    output  uint32  divide2,

    output  uint32  negation,

    output  uint32  binaryinvert,

    output  uint32  absolute,

    output  uint16  zeroequal,
    output  uint16  zeroless
) <autorun> {
    uint32  operand1 := { operand1h, operand1l };

    increment := operand1 + 1;
    decrement := operand1 - 1;

    times2 := operand1 << 1;
    divide2 := { operand1[31,1], operand1[1,31] };

    negation := -operand1;

    binaryinvert := ~operand1;

    absolute := ( operand1[31,1] ) ? -operand1 : operand1;

    zeroequal := {16{(operand1 == 0)}};
    zeroless := {16{(operand1 < 0)}};

    while(1) {}
}
