algorithm fpu(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint7   opCode,
    input   uint3   function3,
    input   uint7   function7,
    input   uint5   rs1,
    input   uint5   rs2,
    input   uint32  sourceReg1,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    input   uint32  sourceReg3F,

    output  uint32  result,
    output  uint1   frd,
    input   uint5   FPUflags,
    output  uint5   FPUnewflags
) <autorun> {
    uint32  calculatorresult = uninitialised;
    uint5   calculatorflags = uninitialised;
    uint1   FPUcalculatorstart = uninitialised;
    uint1   FPUcalculatorbusy = uninitialised;
    floatcalc FPUcalculator(
        opCode <: opCode,
        function7 <: function7,
        sourceReg1F <: sourceReg1F,
        sourceReg2F <: sourceReg2F,
        sourceReg3F <: sourceReg3F,
        result :> calculatorresult,
        flags :> calculatorflags,
        start <: FPUcalculatorstart,
        busy :> FPUcalculatorbusy
    );

    uint32  signresult = uninitialised;
    floatsign FPUsign( function3 <: function3, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, result :> signresult );

    uint32  minmaxresult = uninitialised;
    uint5   minmaxflags = uninitialised;
    floatminmax FPUminmax(
        function3 <: function3,
        sourceReg1F <: sourceReg1F,
        sourceReg2F <: sourceReg2F,
        result :> minmaxresult,
        flags :> minmaxflags
    );

    uint32  compareresult = uninitialised;
    uint5   compareflags = uninitialised;
    floatcomparison FPUcompare(
        function3 <: function3,
        sourceReg1F <: sourceReg1F,
        sourceReg2F <: sourceReg2F,
        result :> compareresult,
        flags :> compareflags
    );

    uint32  convertresult = uninitialised;
    uint5   convertflags = uninitialised;
    uint1   FPUconvertstart = uninitialised;
    uint1   FPUconvertbusy = uninitialised;
    floatconvert FPUconvert(
        function7 <: function7,
        rs2 <: rs2,
        sourceReg1 <: sourceReg1,
        sourceReg1F <: sourceReg1F,
        result :> convertresult,
        flags :> convertflags,
        start <: FPUconvertstart,
        busy :> FPUconvertbusy
    );

    uint10  classification = uninitialised;
    floatclassify FPUclass( sourceReg1F <: sourceReg1F, classification :> classification );

    FPUcalculatorstart := 0; FPUconvertstart := 0;

    while(1) {
        if( start ) {
            busy = 1;
            frd = 1;
            FPUnewflags = FPUflags;

            switch( opCode[2,5] ) {
                default: {
                    // FMADD.S FMSUB.S FNMSUB.S FNMADD.S
                    FPUcalculatorstart = 1; while( FPUcalculatorbusy ) {} result = calculatorresult; FPUnewflags = FPUflags | calculatorflags;
                }
                case 5b10100: {
                    switch( function7[2,5] ) {
                        default: {
                            // FADD.S FSUB.S FMUL.S FDIV.S FSQRT.S
                            FPUcalculatorstart = 1; while( FPUcalculatorbusy ) {} result = calculatorresult; FPUnewflags = FPUflags | calculatorflags;
                        }
                        case 5b00100: {
                            // FSGNJ.S FSGNJN.S FSGNJX.S
                            result = signresult;
                        }
                        case 5b00101: {
                            // FMIN.S FMAX.S
                            result = minmaxresult; FPUnewflags = FPUflags | minmaxflags;
                        }
                        case 5b10100: {
                            // FEQ.S FLT.S FLE.S
                            frd = 0; result = compareresult; FPUnewflags = FPUflags | compareflags;
                        }
                        case 5b11000: {
                            // FCVT.W.S FCVT.WU.S
                            frd = 0; FPUconvertstart = 1; while( FPUconvertbusy ) {} result = convertresult; FPUnewflags = FPUflags | convertflags;
                        }
                        case 5b11010: {
                            // FCVT.S.W FCVT.S.WU
                            FPUconvertstart = 1; while( FPUconvertbusy ) {} result = convertresult; FPUnewflags = FPUflags | convertflags;
                        }
                        case 5b11100: {
                            // FCLASS.S FMV.X.W
                            frd = 0;
                            switch( function3[0,1] ) {
                                case 1: { result = classification; }
                                case 0: { result = sourceReg1F; }
                            }
                        }
                        case 5b11110: {
                            // FMV.W.X
                            result = sourceReg1;
                        }
                    }
                }
            }
            busy = 0;
        }
    }
}

// CONVERSION BETWEEN FLOAT AND SIGNED/UNSIGNED INTEGERS
algorithm floatconvert(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint7   function7,
    input   uint5   rs2,
    input   uint32  sourceReg1,
    input   uint32  sourceReg1F,

    output  uint5   flags,
    output  uint32  result
) <autorun> {
    uint1   dounsigned <:: rs2[0,1];
    uint32  floatresult = uninitialised;
    uint5   floatflags = uninitialised;
    uint1   FPUfloatstart = uninitialised;
    uint1   FPUfloatbusy = uninitialised;
    inttofloat FPUfloat( a <: sourceReg1, dounsigned <: dounsigned, result :> floatresult, flags :> floatflags, start <: FPUfloatstart, busy :> FPUfloatbusy );

    int32   intresult = uninitialised;
    uint5   intflags = uninitialised;
    floattoint FPUint( a <: sourceReg1F, result :> intresult, flags :> intflags );

    uint32  uintresult = uninitialised;
    uint5   uintflags = uninitialised;
    floattouint FPUuint( a <: sourceReg1F, result :> uintresult, flags :> uintflags );

    FPUfloatstart := 0;

    while(1) {
        if( start ) {
            busy = 1;
            flags = 0;
            switch( function7[2,5] ) {
                default: {
                    // FCVT.W.S FCVT.WU.S
                    result = rs2[0,1] ? uintresult : intresult; flags = rs2[0,1] ? uintflags : intflags;
                }
                case 5b11010: {
                    // FCVT.S.W FCVT.S.WU
                    FPUfloatstart = 1; while( FPUfloatbusy ) {} result = floatresult; flags = floatflags;
                }
            }
            busy = 0;
        }
    }
}

// FPU CALCULATION BLOCKS FUSED ADD SUB MUL DIV SQRT
algorithm floatcalc(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint7   opCode,
    input   uint7   function7,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    input   uint32  sourceReg3F,

    output  uint5   flags,
    output  uint32  result,
) <autorun> {
    uint1   addsub = uninitialised;
    uint32  addsourceReg1F = uninitialised;
    uint32  addsourceReg2F = uninitialised;
    uint32  addsubresult = uninitialised;
    uint5   addsubflags = uninitialised;
    uint1   FPUaddsubstart = uninitialised;
    uint1   FPUaddsubbusy = uninitialised;
    floataddsub FPUaddsub( a <: addsourceReg1F, b <: addsourceReg2F, addsub <: addsub, result :> addsubresult, flags :> addsubflags, start <: FPUaddsubstart, busy :> FPUaddsubbusy );

    uint32  mulsourceReg1F = uninitialised;
    uint32  multiplyresult = uninitialised;
    uint5   multiplyflags = uninitialised;
    uint1   FPUmultiplystart = uninitialised;
    uint1   FPUmultiplybusy = uninitialised;
    floatmultiply FPUmultiply( a <: mulsourceReg1F, b <: sourceReg2F, result :> multiplyresult, flags :> multiplyflags, start <: FPUmultiplystart, busy :> FPUmultiplybusy );

    uint32  divideresult = uninitialised;
    uint5   divideflags = uninitialised;
    uint1   FPUdividestart = uninitialised;
    uint1   FPUdividebusy = uninitialised;
    floatdivide FPUdivide( a <: sourceReg1F, b <: sourceReg2F, result :> divideresult, flags :> divideflags, start <: FPUdividestart, busy :> FPUdividebusy );

    uint32  sqrtresult = uninitialised;
    uint5   sqrtflags = uninitialised;
    uint1   FPUsqrtstart = uninitialised;
    uint1   FPUsqrtbusy = uninitialised;
    floatsqrt FPUsqrt( a <: sourceReg1F, result :> sqrtresult, flags :> sqrtflags, start <: FPUsqrtstart, busy :> FPUsqrtbusy );

    FPUaddsubstart := 0; FPUmultiplystart := 0; FPUdividestart := 0; FPUsqrtstart := 0;

    while(1) {
        if( start ) {
            busy = 1;
            //flags = 0;
            switch( opCode[2,5] ) {
                default: {
                    // 3 REGISTER FUSED FPU OPERATIONS
                    mulsourceReg1F = { opCode[3,1] ? ~sourceReg1F[31,1] : sourceReg1F[31,1], sourceReg1F[0,31] };
                    FPUmultiplystart = 1; while( FPUmultiplybusy ) {} flags = multiplyflags & 5b10110;
                    addsourceReg1F = multiplyresult; addsourceReg2F = sourceReg3F; addsub = opCode[2,1];
                    FPUaddsubstart = 1; while( FPUaddsubbusy ) {} result = addsubresult; flags = flags | ( addsubflags & 5b00110 );
                }
                case 5b10100: {
                    // NON 3 REGISTER FPU OPERATIONS
                    switch( function7[2,5] ) {
                        default: {
                            // FADD.S FSUB.S
                            addsourceReg1F = sourceReg1F; addsourceReg2F = sourceReg2F; addsub = function7[2,1]; FPUaddsubstart = 1; while( FPUaddsubbusy ) {} result = addsubresult; flags = addsubflags & 5b00110;
                        }
                        case 5b00010: {
                            // FMUL.S
                            mulsourceReg1F = sourceReg1F; FPUmultiplystart = 1; while( FPUmultiplybusy ) {} result = multiplyresult; flags = multiplyflags & 5b00110;
                        }
                        case 5b00011: {
                            // FDIV.S
                            FPUdividestart = 1; while( FPUdividebusy ) {} result = divideresult; flags = divideflags & 5b01110;
                        }
                        case 5b01011: {
                            // FSQRT.S
                            FPUsqrtstart = 1; while( FPUsqrtbusy ) {} result = sqrtresult; flags = sqrtflags & 5b00110;
                        }
                    }
                }
            }
            busy = 0;
        }
    }
}

algorithm floatclassify(
    input   uint32  sourceReg1F,
    output  uint10  classification
) <autorun> {
    // CLASSIFY THE INPUTS AND FLAG INFINITY, NAN, ZERO
    uint1   aINF = uninitialised;
    uint1   asNAN = uninitialised;
    uint1   aqNAN = uninitialised;
    uint1   aZERO = uninitialised;
    classify A(
        a <: sourceReg1F,
        INF :> aINF,
        sNAN :> asNAN,
        qNAN :> aqNAN,
        ZERO :> aZERO
    );

    always {
        switch( { aINF, asNAN, aqNAN, aZERO } ) {
            case 4b1000: { classification = fp32( sourceReg1F ).sign ? 10b0000000001 : 10b0010000000; }
            case 4b0100: { classification = 10b0100000000; }
            case 4b0010: { classification = 10b1000000000; }
            case 4b0001: { classification = ( sourceReg1F[0,23] == 0 ) ? fp32( sourceReg1F ).sign ? 10b0000001000 : 10b0000010000 :
                                                                            fp32( sourceReg1F ).sign ? 10b0000000100 : 10b0000100000; }
            default: { classification = fp32( sourceReg1F ).sign ? 10b0000000010 : 10b0001000000; }
        }
    }
}

algorithm floatminmax(
    input   uint3   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,

    output  uint5   flags,
    output  uint32  result
) <autorun> {
    // CLASSIFY THE INPUTS AND FLAG INFINITY, NAN
    uint1   aINF = uninitialised;
    uint1   asNAN = uninitialised;
    uint1   aqNAN = uninitialised;
    classify A(
        a <: sourceReg1F,
        INF :> aINF,
        sNAN :> asNAN,
        qNAN :> aqNAN
    );
    uint1   bINF = uninitialised;
    uint1   bsNAN = uninitialised;
    uint1   bqNAN = uninitialised;
    classify B(
        a <: sourceReg2F,
        INF :> bINF,
        sNAN :> bsNAN,
        qNAN :> bqNAN
    );

    uint1   less = uninitialised;
    floatcompare FPUlteq( a <: sourceReg1F, b <: sourceReg2F, less :> less );

    flags ::= { ( asNAN | bsNAN ) | ( aqNAN & bqNAN ), 4b0000 };
    always {
        if( ( asNAN | bsNAN ) | ( aqNAN & bqNAN ) ) {
            // sNAN or both qNAN
            result = 32h7fc00000;
        } else {
            if( function3[0,1] ) {
                result = aqNAN ? ( bqNAN ? 32h7fc00000 : sourceReg2F ) : bqNAN ? sourceReg1F : ( less ? sourceReg2F : sourceReg1F);
            } else {
                result = aqNAN ? ( bqNAN ? 32h7fc00000 : sourceReg2F ) : bqNAN ? sourceReg1F : ( less ? sourceReg1F : sourceReg2F);
            }
        }
    }
}

// COMPARISONS
algorithm floatcomparison(
    input   uint3   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,

    output  uint5   flags,
    output  uint1  result
) <autorun> {
    // CLASSIFY THE INPUTS AND FLAG INFINITY, NAN
    uint1   asNAN = uninitialised;
    uint1   aqNAN = uninitialised;
    classify A(
        a <: sourceReg1F,
        sNAN :> asNAN,
        qNAN :> aqNAN
    );
    uint1   bsNAN = uninitialised;
    uint1   bqNAN = uninitialised;
    classify B(
        a <: sourceReg2F,
        sNAN :> bsNAN,
        qNAN :> bqNAN
    );
    uint1   NAN <:: ( aqNAN | asNAN | bqNAN | bsNAN );

    uint1   less = uninitialised;
    uint1   equal = uninitialised;
    floatcompare FPUlteq( a <: sourceReg1F, b <: sourceReg2F, less :> less, equal :> equal );

    always {
        switch( function3 ) {
            case 3b000: { flags = NAN ? 5b10000 : 0; result = NAN ? 0 : less | equal; }
            case 3b001: { flags = NAN ? 5b10000 : 0; result = NAN ? 0 : less; }
            case 3b010: { flags = ( asNAN | bsNAN ) ? 5b10000 : 0; result = NAN ? 0 : equal; }
            default: { result = 0; }
        }
    }
}

algorithm floatsign(
    input   uint3   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    output  uint32  result,
) <autorun> {
    always {
        result = { function3[1,1] ? sourceReg1F[31,1] ^ sourceReg2F[31,1] : function3[0,1] ? ~sourceReg2F[31,1] : sourceReg2F[31,1], sourceReg1F[0,31] };
    }
}
