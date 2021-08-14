// Hardware Accelerated Mathematics For j1eforth

// UNSIGNED / SIGNED 32 by 16 bit division giving 16 bit remainder and quotient
// INPUT divisor from j1eforth is 16 bit expanded to 32 bit
// OUTPUT quotient and remainder are 16 bit
// PERFORM DIVISION AT SPECIFIC BIT, SHARED BETWEEN INTEGER AND  FLOATING POINT DIVISION
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

// PERFORM 32bit/32bit UNSIGNED
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
    uint32  newquotient = uninitialised;
    uint32  newremainder = uninitialised;
    dointdivbit DIVBIT(
        quotient <: quotient,
        remainder <: remainder,
        top <: dividend,
        bottom <: divisor,
        bit <: bit,
        newquotient :> newquotient,
        newremainder :> newremainder
    );
    uint6   bit(63);

    busy := start | ( bit != 63 );
    while(1) {
        if( start ) {
            bit = 31; quotient = 0; remainder = 0;
            while( bit != 63 ) { quotient = newquotient; remainder = newremainder; bit = bit - 1; }
        }
    }
}

// SIGNED/UNSIGNED 32 BIT / 16 BIT TO 16 BIT
algorithm divmod32by16(
    input   uint32  dividend,
    input   uint16  divisor,
    output  uint16  quotient,
    output  uint16  remainder,
    input   uint2   start,
    output  uint1   active(0)
) <autorun> {
    uint3   FSM = uninitialized;

    uint32  dividend_unsigned = uninitialized;
    uint32  divisor_unsigned = uninitialized;
    uint32  result_quotient = uninitialized;
    uint16  result_remainder = uninitialized;
    uint1   result_sign = uninitialized;

    uint1   DODIVIDEstart = uninitialised;
    uint1   DODIVIDEbusy = uninitialised;
    douintdivide DODIVIDE(
        dividend <: dividend_unsigned,
        divisor <: divisor_unsigned,
        quotient :> result_quotient,
        remainder :> result_remainder,
        start <: DODIVIDEstart,
        busy :> DODIVIDEbusy
    );
    DODIVIDEstart := 0;

    while (1) {
        if( start != 0 ) {
            switch( divisor ) {
                case 0: { quotient = 32hffff; remainder = divisor; }
                default: {
                    active = 1;
                    dividend_unsigned = ( start == 2 ) && dividend[31,1] ? -dividend : dividend;
                    divisor_unsigned = ( start == 2 ) && divisor[15,1] ? -divisor : divisor;
                    result_sign = ( start == 2 ) & ( dividend[31,1] ^ divisor[15,1] );
                    DODIVIDEstart = 1; while( DODIVIDEbusy ) {}
                    quotient = result_sign ? -result_quotient[0,16] : result_quotient[0,16];
                    remainder = result_remainder;
                    active = 0;
                }
            }
        }
    }
}

// SIGNED 16 by 16 bit division giving 16 bit remainder and quotient
algorithm divmod16by16(
    input   int16   dividend,
    input   int16   divisor,
    output  int16   quotient,
    output  int16   remainder,
    input   uint1   start,
    output  uint1   active(0)
) <autorun> {
    uint3   FSM = uninitialized;

    uint32  dividend_unsigned = uninitialized;
    uint32  divisor_unsigned = uninitialized;
    uint32  result_quotient = uninitialized;
    int16   result_remainder = uninitialized;
    uint1   result_sign = uninitialized;

    uint1   DODIVIDEstart = uninitialised;
    uint1   DODIVIDEbusy = uninitialised;
    douintdivide DODIVIDE(
        dividend <: dividend_unsigned,
        divisor <: divisor_unsigned,
        quotient :> result_quotient,
        remainder :> result_remainder,
        start <: DODIVIDEstart,
        busy :> DODIVIDEbusy
    );
    DODIVIDEstart := 0;

    while (1) {
        if( start ) {
            switch( divisor ) {
                case 0: { quotient = 16hffff; remainder = divisor; }
                default: {
                    active = 1;
                    dividend_unsigned = dividend[15,1] ? 0-dividend : dividend;
                    divisor_unsigned = divisor[15,1] ? 0-divisor : divisor;
                    result_sign = dividend[15,1] ^ divisor[15,1];
                    DODIVIDEstart = 1; while( DODIVIDEbusy ) {}
                    quotient = result_sign ? -result_quotient : result_quotient;
                    remainder = result_remainder;
                    active = 0;
                }
            }
        }
    }
}

// UNSIGNED / SIGNED 16 by 16 bit multiplication giving 32 bit product
// DSP INFERENCE
algorithm douintmul(
    input   uint16  factor_1,
    input   uint16  factor_2,
    output  uint32  product
) <autorun> {
    product := factor_1 * factor_2;
}

algorithm multi16by16to32DSP(
    input   uint16  factor1,
    input   uint16  factor2,
    output  uint32  product,
    input   uint2   start
) <autorun> {
    uint16  factor1_unsigned = uninitialised;
    uint16  factor2_unsigned = uninitialised;
    uint32  product32 = uninitialised;
    uint1   productsign = uninitialised;
    douintmul UINTMUL( factor_1 <: factor1_unsigned, factor_2 <: factor2_unsigned, product :> product32 );
    while(1) {
        if( start != 0 ) {
            productsign = ( start == 2 ) & ( factor1[15,1] ^ factor2[15,1] );
            switch( start ) {
                default: {}
                case 1: {
                    // UNSIGNED MULTIPLICATION
                    factor1_unsigned = factor1;
                    factor2_unsigned = factor2;
                }
                case 2: {
                    // SIGNED MULTIPLICATION
                    factor1_unsigned = { 2b0, factor1[15,1] ? -factor1 : factor1 };
                    factor2_unsigned = { 2b0, factor2[15,1] ? -factor2 : factor2 };
                }
            }
            // SORT OUT SIGNS
            product = productsign ? -product32 : product32;
        }
    }
}

// Basic double arithmetic for j1eforth
algorithm doubleops(
    input   int32   operand1,
    input   int32   operand2,

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
    int32  operand1negative := -operand1;

    total := operand1 + operand2;
    difference := operand1 - operand2;
    binaryxor := operand1 ^ operand2;
    binaryor := operand1 | operand2;
    binaryand := operand1 & operand2;
    maximum := lessthan[0,1] ? operand2 : operand1;
    minimum := lessthan[0,1] ? operand1 : operand2;
    equal := {16{(operand1 == operand2)}};
    lessthan := {16{(operand1 < operand2)}};
    increment := operand1 + 1;
    decrement := operand1 - 1;
    times2 := { operand1[0,31], 1b0 };
    divide2 := { operand1[31,1], operand1[1,31] };
    negation := operand1negative;
    binaryinvert := ~operand1;
    absolute := ( operand1[31,1] ) ? operand1negative : operand1;
    zeroequal := {16{(operand1 == 0)}};
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
    uint1   ZERO = 0;
    uint1   ONE = 1;

    uint1   ITOFstart = uninitialised;
    uint1   ITOFbusy = uninitialised;
    inttofloat ITOF( a <: a, result :> itof, dounsigned <: ZERO, start <: ITOFstart, busy :> ITOFbusy );

    floattoint FTOI( a <: a, result :> ftoi );

    uint1   FADDstart = uninitialised;
    uint1   FADDbusy = uninitialised;
    floataddsub FADD( a <: a, b <: b, result :> fadd, addsub <: ZERO, start <: FADDstart, busy :> FADDbusy );

    uint1   FSUBstart = uninitialised;
    uint1   FSUBbusy = uninitialised;
    floataddsub FSUB( a <: a, b <: b, result :> fsub, addsub <: ONE, start <: FSUBstart, busy :> FSUBbusy );

    uint1   FMULstart = uninitialised;
    uint1   FMULbusy = uninitialised;
    floatmultiply FMUL( a <: a, b <: b, result :> fmul, start <: FMULstart, busy :> FMULbusy );

    uint1   FDIVstart = uninitialised;
    uint1   FDIVbusy = uninitialised;
    floatdivide FDIV( a <: a, b <: b, result :> fdiv, start <: FDIVstart, busy :> FDIVbusy );

    uint1   FSQRTstart = uninitialised;
    uint1   FSQRTbusy = uninitialised;
    floatsqrt FSQRT( a <: a, result :> fsqrt, start <: FSQRTstart, busy :> FSQRTbusy );

    uint1   FCOMPAREless = uninitialised;
    uint1   FCOMPAREequal = uninitialised;
    floatcompare FCOMPARE( a <: a, b <: b, less :> FCOMPAREless, equal :> FCOMPAREequal );

    busy := ITOFbusy | FADDbusy | FSUBbusy | FMULbusy | FDIVbusy | FSQRTbusy;

    less := { {16{FCOMPAREless}} };
    lessequal := { {16{FCOMPAREless | FCOMPAREequal}} };
    equal := { {16{FCOMPAREequal}} };

    ITOFstart := 0; FADDstart := 0; FSUBstart := 0; FMULstart := 0; FDIVstart := 0; FSQRTstart := 0;

    always {
        switch( start ) {
            default: {}
            case 1: { ITOFstart = 1; }
            case 3: { FADDstart = 1; }
            case 4: { FSUBstart = 1; }
            case 5: { FMULstart = 1; }
            case 6: { FDIVstart = 1; }
            case 7: { FSQRTstart = 1; }
        }
    }
}
