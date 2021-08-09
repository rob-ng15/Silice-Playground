algorithm fpu(
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
) {
    uint32  calculatorresult = uninitialised;
    uint5   calculatorflags = uninitialised;
    floatcalc FPUcalculator( opCode <: opCode, function7 <: function7, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, sourceReg3F <: sourceReg3F, result :> calculatorresult, flags :> calculatorflags );

    uint32  signresult = uninitialised;
    floatsign FPUsign( function3 <: function3, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, result :> signresult );

    uint32  minmaxresult = uninitialised;
    uint5   minmaxflags = uninitialised;
    floatminmax FPUminmax( function3 <: function3, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, result :> minmaxresult, flags :> minmaxflags );

    uint32  compareresult = uninitialised;
    uint5   compareflags = uninitialised;
    floatcomparison FPUcompare( function3 <: function3, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, result :> compareresult, flags :> compareflags );

    uint32  convertresult = uninitialised;
    uint5   convertflags = uninitialised;
    floatconvert FPUconvert( function7 <: function7, rs2 <: rs2, sourceReg1 <: sourceReg1, sourceReg1F <: sourceReg1F, result :> convertresult, flags :> convertflags );

    uint10  classification = uninitialised;
    floatclassify FPUclass( sourceReg1F <: sourceReg1F, classification :> classification );

    frd = 1;
    FPUnewflags = FPUflags;

    switch( opCode[2,5] ) {
        default: {
            // FMADD.S FMSUB.S FNMSUB.S FNMADD.S
            () <- FPUcalculator <- (); result = calculatorresult; FPUnewflags = FPUflags | calculatorflags;
        }
        case 5b10100: {
            switch( function7[2,5] ) {
                default: {
                    // FADD.S FSUB.S FMUL.S FDIV.S FSQRT.S
                    () <- FPUcalculator <- (); result = calculatorresult; FPUnewflags = FPUflags | calculatorflags;
                }
                case 5b00100: {
                    // FSGNJ.S FSGNJN.S FSGNJX.S
                    () <- FPUsign <- (); result = signresult;
                }
                case 5b00101: {
                    // FMIN.S FMAX.S
                    () <- FPUminmax <- (); result = minmaxresult; FPUnewflags = FPUflags | minmaxflags;
                }
                case 5b10100: {
                    // FEQ.S FLT.S FLE.S
                    frd = 0; () <- FPUcompare <- (); result = compareresult; FPUnewflags = FPUflags | compareflags;
                }
                case 5b11000: {
                    // FCVT.W.S FCVT.WU.S
                    frd = 0; () <- FPUconvert <- (); result = convertresult; FPUnewflags = FPUflags | convertflags;
                }
                case 5b11010: {
                    // FCVT.S.W FCVT.S.WU
                    () <- FPUconvert <- (); result = convertresult; FPUnewflags = FPUflags | convertflags;
                }
                case 5b11100: {
                    // FCLASS.S FMV.X.W
                    frd = 0;
                    switch( function3[0,1] ) {
                        case 1: { () <- FPUclass <- (); result = classification; }
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
}

// CONVERSION BETWEEN FLOAT AND SIGNED/UNSIGNED INTEGERS
algorithm floatconvert(
    input   uint7   function7,
    input   uint5   rs2,
    input   uint32  sourceReg1,
    input   uint32  sourceReg1F,

    output  uint5   flags,
    output  uint32  result
) {
    uint1   dounsigned <: rs2[0,1];
    uint32  floatresult = uninitialised;
    uint5   floatflags = uninitialised;
    inttofloat FPUfloat( a <: sourceReg1, dounsigned <: dounsigned, result :> floatresult, flags :> floatflags );

    int32   intresult = uninitialised;
    uint5   intflags = uninitialised;
    floattoint FPUint( a <: sourceReg1F, result :> intresult, flags :> intflags );

    uint32  uintresult = uninitialised;
    uint5   uintflags = uninitialised;
    floattouint FPUuint( a <: sourceReg1F, result :> uintresult, flags :> uintflags );

    flags = 0;
    switch( function7[2,5] ) {
        default: {
            // FCVT.W.S FCVT.WU.S
            switch( rs2[0,1] ) {
                case 0: { () <- FPUint <- (); }
                case 1: { () <- FPUuint <- (); }
            }
            result = rs2[0,1] ? uintresult : intresult; flags = rs2[0,1] ? uintflags : intflags;
        }
        case 5b11010: {
            // FCVT.S.W FCVT.S.WU
            () <- FPUfloat <- (); result = floatresult; flags = floatflags;
        }
    }
}

// FPU CALCULATION BLOCKS FUSED ADD SUB MUL DIV SQRT
algorithm floatcalc(
    input   uint7   opCode,
    input   uint7   function7,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    input   uint32  sourceReg3F,

    output  uint5   flags,
    output  uint32  result,
) {
    uint1   addsub = uninitialised;
    uint32  addsourceReg1F = uninitialised;
    uint32  addsourceReg2F = uninitialised;
    uint32  addsubresult = uninitialised;
    uint5   addsubflags = uninitialised;
    floataddsub FPUaddsub( a <: addsourceReg1F, b <: addsourceReg2F, addsub <: addsub, result :> addsubresult, flags :> addsubflags );

    uint32  mulsourceReg1F = uninitialised;
    uint32  multiplyresult = uninitialised;
    uint5   multiplyflags = uninitialised;
    floatmultiply FPUmultiply( a <: mulsourceReg1F, b <: sourceReg2F, result :> multiplyresult, flags :> multiplyflags );

    uint32  divideresult = uninitialised;
    uint5   divideflags = uninitialised;
    floatdivide FPUdivide( a <: sourceReg1F, b <: sourceReg2F, result :> divideresult, flags :> divideflags );

    uint32  sqrtresult = uninitialised;
    uint5   sqrtflags = uninitialised;
    floatsqrt FPUsqrt( a <: sourceReg1F, result :> sqrtresult, flags :> sqrtflags );

    flags = 0;
    switch( opCode[2,5] ) {
        default: {
            // 3 REGISTER FUSED FPU OPERATIONS
            mulsourceReg1F = { opCode[3,1] ? ~sourceReg1F[31,1] : sourceReg1F[31,1], sourceReg1F[0,31] }; () <- FPUmultiply <- (); flags = multiplyflags & 5b10110;
            addsourceReg1F = multiplyresult; addsourceReg2F = sourceReg3F; addsub = opCode[2,1]; () <- FPUaddsub <- (); flags = flags | ( addsubflags & 5b00110 ); result = addsubresult;
        }
        case 5b10100: {
            // NON 3 REGISTER FPU OPERATIONS
            switch( function7[2,5] ) {
                default: {
                    // FADD.S FSUB.S
                    addsourceReg1F = sourceReg1F; addsourceReg2F = sourceReg2F; addsub = function7[2,1]; () <- FPUaddsub <- (); result = addsubresult; flags = addsubflags & 5b00110;
                }
                case 5b00010: {
                    // FMUL.S
                    mulsourceReg1F = sourceReg1F; () <- FPUmultiply <- (); result = multiplyresult; flags = multiplyflags & 5b00110;
                }
                case 5b00011: {
                    // FDIV.S
                    () <- FPUdivide <- (); result = divideresult; flags = divideflags & 5b01110;
                }
                case 5b01011: {
                    // FSQRT.S
                    () <- FPUsqrt <- (); result = sqrtresult; flags = sqrtflags & 5b00110;
                }
            }
        }
    }
}

algorithm floatclassify(
    input   uint32  sourceReg1F,
    output  uint10  classification
) {
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
    //always {
        switch( { aINF, asNAN, aqNAN, aZERO } ) {
            case 4b1000: { classification = floatingpointnumber( sourceReg1F ).sign ? 10b0000000001 : 10b0010000000; }
            case 4b0100: { classification = 10b0100000000; }
            case 4b0010: { classification = 10b1000000000; }
            case 4b0001: { classification = ( sourceReg1F[0,23] == 0 ) ? floatingpointnumber( sourceReg1F ).sign ? 10b0000001000 : 10b0000010000 :
                                                                            floatingpointnumber( sourceReg1F ).sign ? 10b0000000100 : 10b0000100000; }
            default: { classification = floatingpointnumber( sourceReg1F ).sign ? 10b0000000010 : 10b0001000000; }
        }
    //}
}

algorithm floatminmax(
    input   uint3   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,

    output  uint5   flags,
    output  uint32  result
) {
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

    //always {
        switch( ( asNAN | bsNAN ) | ( aqNAN & bqNAN ) ) {
            case 1: { flags = 5b10000; result = 32h7fc00000; } // sNAN or both qNAN
            case 0: {
                switch( function3[0,1] ) {
                    case 0: { result = aqNAN ? ( bqNAN ? 32h7fc00000 : sourceReg2F ) : bqNAN ? sourceReg1F : ( less ? sourceReg1F : sourceReg2F); }
                    case 1: { result = aqNAN ? ( bqNAN ? 32h7fc00000 : sourceReg2F ) : bqNAN ? sourceReg1F : ( less ? sourceReg2F : sourceReg1F); }
                }
            }
        }
    //}
}

// COMPARISONS
algorithm floatcomparison(
    input   uint3   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,

    output  uint5   flags,
    output  uint1  result
) {
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
    uint1   equal = uninitialised;
    floatcompare FPUlteq( a <: sourceReg1F, b <: sourceReg2F, less :> less, equal :> equal );

    //always {
        switch( function3 ) {
            case 3b000: { flags = ( aqNAN | asNAN | bqNAN | bsNAN ) ? 5b10000 : 0; result = flags[4,1] ? 0 : less | equal; }
            case 3b001: { flags = ( aqNAN | asNAN | bqNAN | bsNAN ) ? 5b10000 : 0; result = flags[4,1] ? 0 : less; }
            case 3b010: { flags = ( asNAN | bsNAN ) ? 5b10000 : 0; result = ( aqNAN | asNAN | bqNAN | bsNAN ) ? 0 : equal; }
            default: { result = 0; }
        }
    //}
}

algorithm floatsign(
    input   uint3   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    output  uint32  result,
) {
    result = { function3[1,1] ? sourceReg1F[31,1] ^ sourceReg2F[31,1] : function3[0,1] ? ~sourceReg2F[31,1] : sourceReg2F[31,1], sourceReg1F[0,31] };
}
