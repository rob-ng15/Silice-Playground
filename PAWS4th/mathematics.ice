// Hardware Accelerated Mathematics For j1eforth

// UNSIGNED / SIGNED 32 by 16 bit division giving 16 bit remainder and quotient
// INPUT divisor from j1eforth is 16 bit expanded to 32 bit
// OUTPUT quotient and remainder are 16 bit
// PERFORM DIVISION AT SPECIFIC BIT, SHARED BETWEEN INTEGER AND  FLOATING POINT DIVISION
algorithm divbit32(
    input   uint32  quo,
    input   uint32  rem,
    input   uint32  top,
    input   uint32  bottom,
    input   uint6   x,
    output  uint32  newquotient,
    output  uint32  newremainder
) <autorun> {
    uint32  temp = uninitialised;
    uint1   quobit = uninitialised;
    while(1) {
        temp = ( rem << 1 ) + top[x,1];
        quobit = __unsigned(temp) >= __unsigned(bottom);
        newremainder = __unsigned(temp) - ( quobit ? __unsigned(bottom) : 0 );
        newquotient = quo | ( quobit << x );
    }
}
algorithm divmod32by16(
    input   uint16  dividendh,
    input   uint16  dividendl,
    input   uint16  divisor,
    output  uint16  quotient,
    output  uint16  remainder,
    input   uint2   start,
    output  uint1   active
) <autorun> {
    uint3   FSM = uninitialized;

    uint32  dividend_copy = uninitialized;
    uint32  divisor_copy = uninitialized;
    uint32  quotient_copy = uninitialized;
    uint32  remainder_copy = uninitialized;
    uint1   resultsign = uninitialized;
    uint6   bit = uninitialized;

    divbit32 DIVBIT( quo <: quotient_copy, rem <: remainder_copy, top <: dividend_copy, bottom <: divisor_copy, x <: bit );

    while (1) {
        switch( start ) {
            case 0: {}
            default: {
                switch( divisor ) {
                    case 0: { quotient_copy = 32hffff; remainder_copy = divisor; }
                    default: {
                        active = 1;

                        FSM = 1;
                        while( FSM != 0 ) {
                            onehot( FSM ) {
                                case 0: {
                                    bit = 31;
                                    quotient_copy = 0;
                                    remainder_copy = 0;

                                    dividend_copy = ( start == 1 ) ? { dividendh, dividendl } : dividendh[15,1] ? -{ dividendh, dividendl } : { dividendh, dividendl };
                                    divisor_copy = ( start == 1 ) ? { 16b0, divisor } : divisor[15,1] ? { 16b0, -divisor } : { 16b0, divisor };
                                    resultsign = ( start == 1 ) ? 0 : dividendh[15,1] != divisor[15,1];
                                }
                                case 1: {
                                    while( bit != 63 ) {
                                        quotient_copy = DIVBIT.newquotient; remainder_copy = DIVBIT.newremainder;
                                        bit = bit - 1;
                                    }
                                }
                                case 2: {
                                    quotient = resultsign ? -quotient_copy[0,16] : quotient_copy[0,16];
                                    remainder = remainder_copy[0,16];
                                }
                            }
                            FSM = { FSM[0,2], 1b0 };
                        }

                        active = 0;
                    }
                }
            }
        }
    }
}

// SIGNED 16 by 16 bit division giving 16 bit remainder and quotient
algorithm divbit16(
    input   uint16  quo,
    input   uint16  rem,
    input   uint16  top,
    input   uint16  bottom,
    input   uint5   x,
    output  uint16  newquotient,
    output  uint16  newremainder
) <autorun> {
    uint16  temp = uninitialised;
    uint1   quobit = uninitialised;
    while(1) {
        temp = ( rem << 1 ) + top[x,1];
        quobit = __unsigned(temp) >= __unsigned(bottom);
        newremainder = __unsigned(temp) - ( quobit ? __unsigned(bottom) : 0 );
        newquotient = quo | ( quobit << x );
    }
}
algorithm divmod16by16(
    input   uint16  dividend,
    input   uint16  divisor,
    output  uint16  quotient,
    output  uint16  remainder,
    input   uint1   start,
    output  uint1   active
) <autorun> {
    uint3   FSM = uninitialized;

    uint16  dividend_copy = uninitialized;
    uint16  divisor_copy = uninitialized;
    uint16  quotient_copy = uninitialized;
    uint16  remainder_copy = uninitialized;
    uint1   resultsign = uninitialized;
    uint5   bit = uninitialized;

    divbit16 DIVBIT( quo <: quotient_copy, rem <: remainder_copy, top <: dividend_copy, bottom <: divisor_copy, x <: bit );

    while (1) {
        switch( start ) {
            case 0: {}
            case 1: {
                switch( divisor ) {
                    case 0: { quotient_copy = 16hffff; remainder_copy = divisor; }
                    default: {
                        active = 1;

                        FSM = 1;
                        while( FSM != 0 ) {
                            onehot( FSM ) {
                                case 0: {
                                    bit = 15;
                                    quotient_copy = 0;
                                    remainder_copy = 0;
                                    dividend_copy = dividend[15,1] ? -dividend : dividend;
                                    divisor_copy = divisor[15,1] ? -divisor : divisor;
                                    resultsign = dividend[15,1] != divisor[15,1];
                                }
                                case 1: {
                                    while( bit != 31 ) {
                                        quotient_copy = DIVBIT.newquotient; remainder_copy = DIVBIT.newremainder;
                                        bit = bit - 1;
                                    }
                                }
                                case 2: {
                                    quotient = resultsign ? -quotient_copy : quotient_copy;
                                    remainder = remainder_copy;
                                }
                            }
                            FSM = { FSM[0,2], 1b0 };
                        }

                        active = 0;
                    }
                }
            }
        }
    }
}

// UNSIGNED / SIGNED 16 by 16 bit multiplication giving 32 bit product
// DSP INFERENCE
algorithm multi16by16to32DSP(
    input   uint16  factor1,
    input   uint16  factor2,
    output  uint32  product,
    input   uint2   start,
) <autorun> {
    uint18  factor1copy = uninitialized;
    uint18  factor2copy = uninitialized;
    uint32  nosignproduct = uninitialized;
    uint1   productsign = uninitialized;

    while(1) {
        switch( start ) {
            case 0: {}
            default: {
                switch( start ) {
                    default: {}
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
                // PERFORM UNSIGNED MULTIPLICATION
                nosignproduct = factor1copy * factor2copy;
                // SORT OUT SIGNS
                product = productsign ? -nosignproduct : nosignproduct;
            }
        }
    }
}

// Basic double arithmetic for j1eforth
// Basic double arithmetic for j1eforth
algorithm doubleops(
    input   uint16  operand1h,
    input   uint16  operand1l,
    input   uint16  operand2h,
    input   uint16  operand2l,

    output  int32   total,
    output  int32   difference,
    output  int32   binaryxor,
    output  int32   binaryor,
    output  int32   binaryand,
    output  int32   maximum,
    output  int32   minimum,
    output  int16   equal,
    output  int16   lessthan,
    output  int32   increment,
    output  int32   decrement,
    output  int32   times2,
    output  int32   divide2,
    output  int32   negation,
    output  int32   binaryinvert,
    output  int32   absolute,
    output  int16   zeroequal,
    output  int16   zeroless
) <autorun> {
    int32  operand1 := { operand1h, operand1l };
    int32  operand2 := { operand2h, operand2l };

    dadd DADD( operand1 <: operand1, operand2 <: operand2, total :> total );
    dsub DSUB( operand1 <: operand1, operand2 <: operand2, difference :> difference );
    dxor DXOR( operand1 <: operand1, operand2 <: operand2, binaryxor :> binaryxor );
    dor DOR( operand1 <: operand1, operand2 <: operand2, binaryor :> binaryor );
    dand DAND( operand1 <: operand1, operand2 <: operand2, binaryand :> binaryand );
    dmax DMAX( operand1 <: operand1, operand2 <: operand2, maximum :> maximum );
    dmin DMIN( operand1 <: operand1, operand2 <: operand2, minimum :> minimum );
    dequal DEQUAL( operand1 <: operand1, operand2 <: operand2, equal :> equal );
    dless DLESS( operand1 <: operand1, operand2 <: operand2, lessthan :> lessthan );

    dinc DINC( operand1 <: operand1, increment :> increment );
    ddec DDEC( operand1 <: operand1, decrement :> decrement );
    ddouble DDOUBLE( operand1 <: operand1, times2 :> times2 );
    dhalf DHALF( operand1 <: operand1, divide2 :> divide2 );
    dneg DNEG( operand1 <: operand1, negation :> negation );
    dinv DINV( operand1 <: operand1, binaryinvert :> binaryinvert );
    dabs DABS( operand1 <: operand1, absolute :> absolute );
    d0e D0E( operand1 <: operand1, zeroequal :> zeroequal );
    d0l D0L( operand1 <: operand1, zeroless :> zeroless );
}

algorithm dadd(
    input   int32   operand1,
    input   int32   operand2,
    output  int32   total
) <autorun> {
    total := operand1 + operand2;
}
algorithm dsub(
    input   int32   operand1,
    input   int32   operand2,
    output  int32   difference
) <autorun> {
    difference := operand1 - operand2;
}
algorithm dxor(
    input   int32   operand1,
    input   int32   operand2,
    output  int32   binaryxor
) <autorun> {
    binaryxor := operand1 ^ operand2;
}
algorithm dor(
    input   int32   operand1,
    input   int32   operand2,
    output  int32   binaryor
) <autorun> {
    binaryor := operand1 | operand2;
}
algorithm dand(
    input   int32   operand1,
    input   int32   operand2,
    output  int32   binaryand
) <autorun> {
    binaryand := operand1 & operand2;
}
algorithm dmax(
    input   int32   operand1,
    input   int32   operand2,
    output  int32   maximum
) <autorun> {
    maximum := ( operand1 > operand2 ) ? operand1 : operand2;
}
algorithm dmin(
    input   int32   operand1,
    input   int32   operand2,
    output  int32   minimum
) <autorun> {
    minimum := ( operand1 < operand2 ) ? operand1 : operand2;
}
algorithm dequal(
    input   int32   operand1,
    input   int32   operand2,
    output  int16   equal
) <autorun> {
    equal := {16{(operand1 == operand2)}};
}
algorithm dless(
    input   int32   operand1,
    input   int32   operand2,
    output  int16   lessthan
) <autorun> {
    lessthan := {16{(operand1 < operand2)}};
}
algorithm dinc(
    input   int32   operand1,
    output  int32   increment
) <autorun> {
    increment := operand1 + 1;
}
algorithm ddec(
    input   int32   operand1,
    output  int32   decrement
) <autorun> {
    decrement := operand1 - 1;
}
algorithm ddouble(
    input   int32   operand1,
    output  int32   times2
) <autorun> {
    times2 := { operand1[0,31], 1b0 };
}
algorithm dhalf(
    input   int32   operand1,
    output  int32   divide2
) <autorun> {
    divide2 := { operand1[31,1], operand1[1,31] };
}
algorithm dneg(
    input   int32   operand1,
    output  int32   negation
) <autorun> {
    negation := -operand1;
}
algorithm dinv(
    input   int32   operand1,
    output  int32   binaryinvert
) <autorun> {
    binaryinvert := ~operand1;
}
algorithm dabs(
    input   int32   operand1,
    output  int32   absolute
) <autorun> {
    absolute := ( operand1[31,1] ) ? -operand1 : operand1;
}
algorithm d0e(
    input   int32   operand1,
    output  int16   zeroequal
) <autorun> {
    zeroequal := {16{(operand1 == 0)}};
}
algorithm d0l(
    input   int32   operand1,
    output  int16   zeroless
) <autorun> {
    zeroless := {16{operand1[31,1]}};
}

// FLOAT16 ROUTINES
algorithm floatops(
    input   uint16  a,
    input   uint16  b,
    output  uint16  itof,
    output  int16   ftoi,
    output  uint16  fadd,
    output  uint16  fsub,
    output  uint16  fmul,
    output  uint16  fdiv,
    output  uint16  fsqrt,
    output  int16   less,
    output  int16   equal,
    output  int16   lessequal,
    input   uint3   start,
    output  uint1   busy
) <autorun> {
    inttofloat ITOF( a <: a, result :> itof );
    floattoint FTOI( a <: a, result :> ftoi );
    floataddsub FADD( a <: a, b <: b, result :> fadd );
    floataddsub FSUB( a <: a, b <: b, result :> fsub );
    floatmultiply FMUL( a <: a, b <: b, result :> fmul );
    floatdivide FDIV( a <: a, b <: b, result :> fdiv );
    floatsqrt FSQRT( a <: a, result :> fsqrt );
    floatcompare FCOMPARE( a <: a, b <: b );

    busy := ITOF.busy | FTOI.busy | FADD.busy | FSUB.busy | FMUL.busy | FDIV.busy | FSQRT.busy;

    less := { {16{FCOMPARE.less}} };
    lessequal := { {16{FCOMPARE.lessequal}} };
    equal := { {16{FCOMPARE.equal}} };

    ITOF.start := 0; FTOI.start := 0;
    FADD.start := 0; FSUB.start := 0;
    FMUL.start := 0; FDIV.start := 0;
    FSQRT.start := 0;

    ITOF.dounsigned = 0; FADD.addsub = 0; FSUB.addsub = 1;

    while(1) {
        switch( start ) {
            default: {}
            case 1: { ITOF.start = 1; }
            case 2: { FTOI.start = 1; }
            case 3: { FADD.start = 1; }
            case 4: { FSUB.start = 1; }
            case 5: { FMUL.start = 1; }
            case 6: { FDIV.start = 1; }
            case 7: { FSQRT.start = 1; }
        }
    }
}
