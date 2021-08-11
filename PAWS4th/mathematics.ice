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

algorithm divmod32by16(
    input   uint16  dividendh,
    input   uint16  dividendl,
    input   uint16  divisor,
    output  uint16  quotient,
    output  uint16  remainder,
    input   uint2   start,
    output  uint1   active(0)
) <autorun> {
    uint3   FSM = uninitialized;

    uint32  dividend_copy = uninitialized;
    uint32  divisor_copy = uninitialized;
    uint32  quotient_copy = uninitialized;
    uint32  remainder_copy = uninitialized;
    uint1   resultsign = uninitialized;
    uint6   bit = uninitialized;

    while (1) {
        if( start != 0 ) {
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
                                    ( quotient_copy, remainder_copy ) = divbit( quotient_copy, remainder_copy, dividend_copy, divisor_copy, bit );
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

// SIGNED 16 by 16 bit division giving 16 bit remainder and quotient
algorithm divmod16by16(
    input   uint16  dividend,
    input   uint16  divisor,
    output  uint16  quotient,
    output  uint16  remainder,
    input   uint1   start,
    output  uint1   active(0)
) <autorun> {
    uint3   FSM = uninitialized;

    uint16  dividend_copy = uninitialized;
    uint16  divisor_copy = uninitialized;
    uint16  quotient_copy = uninitialized;
    uint16  remainder_copy = uninitialized;
    uint1   resultsign = uninitialized;
    uint5   bit = uninitialized;

    while (1) {
        if( start ) {
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
                                    ( quotient_copy, remainder_copy ) = divbit( quotient_copy, remainder_copy, dividend_copy, divisor_copy, bit );
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

// UNSIGNED / SIGNED 16 by 16 bit multiplication giving 32 bit product
// DSP INFERENCE
algorithm multi16by16to32DSP(
    input   uint16  factor1,
    input   uint16  factor2,
    output  uint32  product,
    input   uint2   start
) <autorun> {
    uint18  factor1copy = uninitialized;
    uint18  factor2copy = uninitialized;
    uint32  nosignproduct = uninitialized;
    uint1   productsign = uninitialized;

    while(1) {
        if( start != 0 ) {
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

    uint1   FTOIstart = uninitialised;
    uint1   FTOIbusy = uninitialised;
    floattoint FTOI( a <: a, result :> ftoi, start <: FTOIstart, busy :> FTOIbusy );

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

    busy := ITOFbusy | FTOIbusy | FADDbusy | FSUBbusy | FMULbusy | FDIVbusy | FSQRTbusy;

    less := { {16{FCOMPAREless}} };
    lessequal := { {16{FCOMPAREless | FCOMPAREequal}} };
    equal := { {16{FCOMPAREequal}} };

    ITOFstart := 0; FTOIstart := 0;
    FADDstart := 0; FSUBstart := 0;
    FMULstart := 0; FDIVstart := 0;
    FSQRTstart := 0;

    always {
        switch( start ) {
            default: {}
            case 1: { ITOFstart = 1; }
            case 2: { FTOIstart = 1; }
            case 3: { FADDstart = 1; }
            case 4: { FSUBstart = 1; }
            case 5: { FMULstart = 1; }
            case 6: { FDIVstart = 1; }
            case 7: { FSQRTstart = 1; }
        }
    }
}
