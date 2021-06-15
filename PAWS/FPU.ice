algorithm fpu(
    input   uint1   start,
    output  uint1   busy,

    input   uint7   opCode,
    input   uint3   function3,
    input   uint7   function7,
    input   uint5   rs1,
    input   uint5   rs2,
    input   uint32  sourceReg1,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    input   uint32  sourceReg3F,

    output uint32  result,
    output uint1   frd
) <autorun> {
    floatclassify FPUclass( sourceReg1F <: sourceReg1F );
    floatcompare FPUcompare( function3 <: function3, function7 <: function7, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F );
    floatsign FPUsign( function3 <: function3, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F );
    floatcalc FPUcalculator( opCode <: opCode, function7 <: function7, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, sourceReg3F <: sourceReg3F );
    floatconvert FPUconvert( function7 <: function7, rs2 <: rs2, sourceReg1 <: sourceReg1, sourceReg1F <: sourceReg1F );

    FPUcalculator.start := 0;
    FPUconvert.start := 0;

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            frd = 1;

            switch( opCode[2,5] ) {
                default: {
                    // FMADD.S FMSUB.S FNMSUB.S FNMADD.S
                    FPUcalculator.start = 1; while( FPUcalculator.busy ) {} result = FPUcalculator.result;
                }
                case 5b10100: {
                    switch( function7[2,5] ) {
                        default: {
                            // FADD.S FSUB.S FMUL.S FDIV.S FSQRT.S
                            FPUcalculator.start = 1; while( FPUcalculator.busy ) {} result = FPUcalculator.result;
                        }
                        case 5b00100: {
                            // FSGNJ.S FNGNJN.S FSGNJX.S
                            result = FPUsign.result;
                        }
                        case 5b00101: {
                            // FMIN.S FMAX.S
                            result = FPUcompare.result;
                        }
                        case 5b10100: {
                            // FEQ.S FLT.S FLE.S
                            frd = 0; result = FPUcompare.result;
                        }
                        case 5b11000: {
                            // FCVT.W.S FCVT.WU.S
                            frd = 0; FPUconvert.start = 1; while( FPUconvert.busy ) {} result = FPUconvert.result;
                        }
                        case 5b11010: {
                            // FCVT.S.W FCVT.S.WU
                            FPUconvert.start = 1; while( FPUconvert.busy ) {} result = FPUconvert.result;
                        }
                        case 5b11100: {
                            // FCLASS.S FMV.X.W
                            frd = 0;
                            result = function3[0,1] ? FPUclass.classification : sourceReg1F;
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
    output  uint1   busy,

    input   uint7   function7,
    input   uint5   rs2,
    input   uint32  sourceReg1,
    input   uint32  sourceReg1F,

    output uint32  result
) <autorun> {
    inttofloat FPUfloat( a <: sourceReg1 );
    floattoint FPUint( a <: sourceReg1F );
    floattouint FPUuint( a <: sourceReg1F );

    FPUfloat.signedunsigned := rs2[0,1]; FPUfloat.start := 0;
    FPUint.start := 0; FPUuint.start := 0;

    while(1) {
        if( start ) {
            busy = 1;

            switch( function7[2,5] ) {
                case 5b11000: {
                    // FCVT.W.S FCVT.WU.S
                    FPUint.start = ~rs2[0,1]; FPUuint.start = rs2[0,1]; while( FPUint.busy || FPUuint.busy ) {}
                    result = rs2[0,1] ? FPUuint.result : FPUint.result;
                }
                case 5b11010: {
                    // FCVT.S.W FCVT.S.WU
                    FPUfloat.start = 1; while( FPUfloat.busy ) {}
                    result = FPUfloat.result;
                }
            }

            busy = 0;
        }
    }
}

// FPU CALCULATION BLOCKS FUSED ADD SUB MUL DIV SQRT
algorithm floatcalc(
    input   uint1   start,
    output  uint1   busy,

    input   uint7   opCode,
    input   uint7   function7,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    input   uint32  sourceReg3F,

    output uint32  result,
) <autorun> {
    uint2   FSM = uninitialised;
    floataddsub FPUaddsub();
    floatmultiply FPUmultiply( b <: sourceReg2F );
    floatdivide FPUdivide();
    floatsqrt FPUsqrt( sourceReg1F <: sourceReg1F );

    FPUaddsub.start := 0;
    FPUmultiply.start := 0;
    FPUdivide.start := 0;

    // SQRT resuses blocks
    FPUsqrt.start := 0;
    FPUsqrt.addResult := FPUaddsub.result; FPUsqrt.divResult := FPUdivide.result;
    FPUsqrt.addBusy := FPUaddsub.busy; FPUsqrt.divBusy := FPUdivide.busy;

    while(1) {
        if( start ) {
            busy = 1;

            switch( opCode[2,5] ) {
                default: {
                    // FMADD.S FMSUB.S FNMSUB.S FNMADD.S
                    FSM = 1;
                    while( FSM != 0 ) {
                        onehot( FSM ) {
                            case 0: {
                                FPUmultiply.a = opCode[3,1] ? { ~sourceReg1F[31,1], sourceReg1F[0,31] } : sourceReg1F;
                                FPUmultiply.start = 1; while( FPUmultiply.busy ) {}
                            }
                            case 1: {
                                FPUaddsub.a = FPUmultiply.result; FPUaddsub.b = sourceReg3F;
                                FPUaddsub.addsub = ( opCode[2,1] ^ opCode[3,1] );
                                FPUaddsub.start = 1; while( FPUaddsub.busy ) {}
                            }
                        }
                        FSM = { FSM[0,1], 1b0 };
                    }
                    result = FPUaddsub.result;
                }
                case 5b10100: {
                    // NON 3 REGISTER FPU OPERATIONS
                    switch( function7[2,5] ) {
                        default: {
                            // FADD.S FSUB.S
                            FPUaddsub.a = sourceReg1F; FPUaddsub.b = sourceReg2F; FPUaddsub.addsub = function7[2,1]; FPUaddsub.start = 1; while( FPUaddsub.busy ) {}
                            result = FPUaddsub.result;
                        }
                        case 5b00010: {
                            // FMUL.S
                            FPUmultiply.a = sourceReg1F; FPUmultiply.start = 1; while( FPUmultiply.busy ) {}
                            result = FPUmultiply.result;
                        }
                        case 5b00011: {
                            // FDIV.S
                            FPUdivide.a = sourceReg1F; FPUdivide.b = sourceReg2F; FPUdivide.start = 1; while( FPUdivide.busy ) {}
                            result = FPUdivide.result;
                        }
                        case 5b01011: {
                            // FSQRT.S
                            FPUsqrt.start = 1;
                            FPUaddsub.addsub = 0;
                            while( FPUsqrt.busy ) {
                                switch( { FPUsqrt.divStart, FPUsqrt.addStart } ) {
                                    case 2b10: { FPUdivide.a = FPUsqrt.divA; FPUdivide.b = FPUsqrt.divB; FPUdivide.start = 1; while( FPUdivide.busy ) {} }
                                    case 2b01: { FPUaddsub.a = FPUsqrt.addA; FPUaddsub.b = FPUsqrt.addB; FPUaddsub.start = 1; while( FPUaddsub.busy ) {} }
                                }
                            }
                            result = FPUsqrt.result;
                        }
                    }
                }
            }
            busy = 0;
        }
    }
}

algorithm floatsqrt(
    input   uint1   start,
    output  uint1   busy,

    input   uint32  sourceReg1F,
    output  uint32  result,

    output  uint32  addA,
    output  uint32  addB,
    input   uint32  addResult,
    output  uint1   addStart,
    input   uint1   addBusy,
    output  uint32  divA,
    output  uint32  divB,
    input   uint32  divResult,
    output  uint1   divStart,
    input   uint1   divBusy,

) <autorun> {
    uint2   FSM = uninitialised;
    uint3   FSM2 = uninitialised;
    uint3   count = uninitialised;
    uint8   exp = uninitialised;

    addStart := 0; addA := result; addB := divResult;
    divStart := 0; divA := sourceReg1F; divB := result;

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            switch( { floatingpointnumber( sourceReg1F ).exponent == 0, sourceReg1F[31,1] } ) {
                case 2b00: {
                    FSM = 1;
                    while( FSM != 0 ) {
                        onehot( FSM ) {
                            case 0: {
                                // FIRST APPROXIMATIONS IS 1
                                result = 32h3f800000;
                            }
                            case 1: {
                                // LOOP UNTIL MANTISSAS ACROSS ITERATIONS ARE APPROXIMATELY EQUAL
                                count = 7;
                                while( count != 0 ) {
                                    FSM2 = 1;
                                    while( FSM2 != 0 ) {
                                        // x(i+1 ) = ( x(i) + n / x(i) ) / 2;
                                        onehot( FSM2 ) {
                                            case 0: {
                                                // DO n/x(i)
                                                divStart = 1; while( divBusy ) {}
                                            }
                                            case 1: {
                                                // DO x(i) + n/x(i)
                                                addStart = 1; while( addBusy ) {}
                                            }
                                            case 2: {
                                                // DO (x(i) + n/x(i))/2
                                                exp = floatingpointnumber( addResult ).exponent - 1;
                                                result = { floatingpointnumber( addResult ).sign, exp, floatingpointnumber( addResult ).fraction };
                                            }
                                        }
                                        FSM2 = { FSM[0,2], 1b0 };
                                    }
                                    count = count - 1;
                                }
                            }
                        }
                        FSM = { FSM[0,1], 1b0 };
                    }
                }
                case 2b10: { result = 0; }
                default: { result = { sourceReg1F[31,1], 8b11111111, 23b0 }; }
            }
            busy = 0;
        }
    }
}

algorithm floatclassify(
    input   uint32  sourceReg1F,
    output  uint32  classification
) <autorun> {
    uint2   classEa = uninitialised;
    uint1   classFa = uninitialised;

    while(1) {
        ( classEa, classFa ) = classEF( sourceReg1F );
        switch( classEa ) {
            case 2b00: { classification = floatingpointnumber(sourceReg1F).sign ? { 23b0, 9b000000010 } : { 23b0, 9b000100000 }; }
            case 2b01: { classification = floatingpointnumber(sourceReg1F).sign ? { 23b0, 9b000001000 } : { 23b0, 9b000010000 }; }
            case 2b10: { classification = classFa ? ( floatingpointnumber(sourceReg1F).sign ? { 23b0, 9b000000001 } : { 23b0, 9b001000000 } ) :
                                            ( floatingpointnumber(sourceReg1F).sign ? { 23b0, 9b100000000 } : { 23b0, 9b010000000 } ); }
        }
    }
}

// COMPARISONS AND MIN MAX
algorithm floatcompare(
    input   uint3   function3,
    input   uint7   function7,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,

    output uint32  result
) <autorun> {
    floatcomparison FPUcomparison( function3 <: function3, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F );

    while(1) {
        switch( function7[2,5] ) {
            case 5b00101: {
                // FMIN.S FMAX.S
                switch( function3[0,1] ) {
                    case 0: { result = FPUcomparison.comparison ? sourceReg1F : sourceReg2F; }
                    case 1: { result = FPUcomparison.comparison ? sourceReg2F : sourceReg1F; }
                }
            }
            case 5b10100: {
                // FEQ.S FLT.S FLE.S
                result = FPUcomparison.comparison;
            }
        }
    }
}
algorithm floatcomparison(
    input   uint3   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    output  uint1   comparison,
) <autorun> {
    uint2   classEa = uninitialised;
    uint1   classFa = uninitialised;
    uint2   classEb = uninitialised;
    uint1   classFb = uninitialised;
    while(1) {
        ( classEa, classFa ) = classEF( sourceReg1F );
        ( classEb, classFb ) = classEF( sourceReg2F );
        switch( classEa | classEb ) {
            default: {
                switch( function3 ) {
                    case 3b000: {
                        // LESS THAN EQUAL OMPARISON OF 2 FLOATING POINT NUMBERS
                        ( comparison ) = floatlessequal( sourceReg1F, sourceReg2F );
                    }
                    case 3b001: {
                        // LESS THAN COMPARISON OF 2 FLOATING POINT NUMBERS
                        ( comparison ) = floatless( sourceReg1F, sourceReg2F );
                    }
                    case 3b010: {
                        // EQUAL COMPARISON OF 2 FLOATING POINT NUMBERS
                        ( comparison ) = floatequal( sourceReg1F, sourceReg2F );
                    }
                }
            }
            case 2b10: { comparison = 0; }
            case 2b11: { comparison = 0; }
        }
    }
}

algorithm floatsign(
    input   uint3   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    output  uint32  result,
) <autorun> {
    while(1) {
        switch( function3 ) {
            default: { result = { sourceReg2F[31,1], sourceReg1F[0,31] }; }                         // FSGNJ.S
            case 3b001: { result = { sourceReg2F[31,1], sourceReg1F[0,31] }; }                      // FSGNJN.S
            case 3b010: { result = { sourceReg1F[31,1] ^ sourceReg2F[31,1], sourceReg1F[0,31] }; }  // FSGNJX.S
        }
    }
}
