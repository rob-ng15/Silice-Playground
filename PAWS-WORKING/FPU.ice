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
    floatclassify FPUclass( sourceReg1F <: sourceReg1F );
    floatminmax FPUminmax( function3 <: function3, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F );
    floatcomparison FPUcompare( function3 <: function3, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F );
    floatsign FPUsign( function3 <: function3, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F );
    floatcalc FPUcalculator( opCode <: opCode, function7 <: function7, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, sourceReg3F <: sourceReg3F );
    floatconvert FPUconvert( function7 <: function7, rs2 <: rs2, sourceReg1 <: sourceReg1, sourceReg1F <: sourceReg1F );

    FPUcalculator.start := 0; FPUconvert.start := 0;

    while(1) {
        if( start ) {
            busy = 1;
            frd = 1;
            FPUnewflags = FPUflags;

            switch( opCode[2,5] ) {
                default: {
                    // FMADD.S FMSUB.S FNMSUB.S FNMADD.S
                    FPUcalculator.start = 1; while( FPUcalculator.busy ) {} result = FPUcalculator.result;
                    FPUnewflags = FPUflags | FPUcalculator.flags;
                }
                case 5b10100: {
                    switch( function7[2,5] ) {
                        default: {
                            // FADD.S FSUB.S FMUL.S FDIV.S FSQRT.S
                            FPUcalculator.start = 1; while( FPUcalculator.busy ) {} result = FPUcalculator.result;
                            FPUnewflags = FPUflags | FPUcalculator.flags;
                        }
                        case 5b00100: {
                            // FSGNJ.S FSGNJN.S FSGNJX.S
                            result = FPUsign.result;
                        }
                        case 5b00101: {
                            // FMIN.S FMAX.S
                            result = FPUminmax.result;
                            FPUnewflags = FPUflags | FPUminmax.flags;
                        }
                        case 5b10100: {
                            // FEQ.S FLT.S FLE.S
                            frd = 0; result = FPUcompare.result;
                            FPUnewflags = FPUflags | FPUcompare.flags;
                        }
                        case 5b11000: {
                            // FCVT.W.S FCVT.WU.S
                            frd = 0; FPUconvert.start = 1; while( FPUconvert.busy ) {} result = FPUconvert.result;
                            FPUnewflags = FPUflags | FPUconvert.flags;
                        }
                        case 5b11010: {
                            // FCVT.S.W FCVT.S.WU
                            FPUconvert.start = 1; while( FPUconvert.busy ) {} result = FPUconvert.result;
                            FPUnewflags = FPUflags | FPUconvert.flags;
                        }
                        case 5b11100: {
                            // FCLASS.S FMV.X.W
                            frd = 0; result = function3[0,1] ? FPUclass.classification : sourceReg1F;
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
    inttofloat FPUfloat( a <: sourceReg1 );
    floattoint FPUint( a <: sourceReg1F );
    floattouint FPUuint( a <: sourceReg1F );

    FPUfloat.dounsigned := rs2[0,1]; FPUfloat.start := 0;

    while(1) {
        if( start ) {
            busy = 1;
            flags = 0;

            switch( function7[2,5] ) {
                default: {
                    // FCVT.W.S FCVT.WU.S
                    result = rs2[0,1] ? FPUuint.result : FPUint.result; flags = rs2[0,1] ? FPUuint.flags : FPUint.flags;
                }
                case 5b11010: {
                    // FCVT.S.W FCVT.S.WU
                    FPUfloat.start = 1; while( FPUfloat.busy ) {} result = FPUfloat.result; flags = FPUfloat.flags;
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
    floataddsub FPUaddsub();
    floatmultiply FPUmultiply( b <: sourceReg2F );
    floatdivide FPUdivide( a <: sourceReg1F, b <: sourceReg2F );
    floatsqrt FPUsqrt( a <: sourceReg1F );

    FPUaddsub.start := 0;
    FPUmultiply.start := 0;
    FPUdivide.start := 0;
    FPUsqrt.start := 0;

    while(1) {
        if( start ) {
            busy = 1;
            flags = 0;

            switch( opCode[2,5] ) {
                default: {
                    FPUmultiply.a = { opCode[3,1] ? ~sourceReg1F[31,1] : sourceReg1F[31,1], sourceReg1F[0,31] };
                    FPUmultiply.start = 1; while( FPUmultiply.busy ) {} flags = FPUmultiply.flags & 5b10110;
                    FPUaddsub.a = FPUmultiply.result; FPUaddsub.b = sourceReg3F; FPUaddsub.addsub = opCode[2,1];
                    FPUaddsub.start = 1; while( FPUaddsub.busy ) {} flags = flags | ( FPUaddsub.flags & 5b00110 );
                    result = FPUaddsub.result;
                }
                case 5b10100: {
                    // NON 3 REGISTER FPU OPERATIONS
                    switch( function7[2,5] ) {
                        default: {
                            // FADD.S FSUB.S
                            FPUaddsub.a = sourceReg1F; FPUaddsub.b = sourceReg2F; FPUaddsub.addsub = function7[2,1]; FPUaddsub.start = 1; while( FPUaddsub.busy ) {}
                            result = FPUaddsub.result; flags = FPUaddsub.flags & 5b00110;
                        }
                        case 5b00010: {
                            // FMUL.S
                            FPUmultiply.a = sourceReg1F; FPUmultiply.start = 1; while( FPUmultiply.busy ) {}
                            result = FPUmultiply.result; flags = FPUmultiply.flags & 5b00110;
                        }
                        case 5b00011: {
                            // FDIV.S
                            FPUdivide.start = 1; while( FPUdivide.busy ) {}
                            result = FPUdivide.result; flags = FPUdivide.flags & 5b01110;
                        }
                        case 5b01011: {
                            // FSQRT.S
                            FPUsqrt.start = 1; while( FPUsqrt.busy ) {}
                            result = FPUsqrt.result; flags = FPUsqrt.flags & 5b00110;
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
    classify A( a <: sourceReg1F );

    always {
        switch( { A.INF, A.sNAN, A.qNAN, A.ZERO } ) {
            case 4b1000: { classification = floatingpointnumber( sourceReg1F ).sign ? 10b0000000001 : 10b0010000000; }
            case 4b0100: { classification = 10b0100000000; }
            case 4b0010: { classification = 10b1000000000; }
            case 4b0001: { classification = ( sourceReg1F[0,23] == 0 ) ? floatingpointnumber( sourceReg1F ).sign ? 10b0000001000 : 10b0000010000 :
                                                                            floatingpointnumber( sourceReg1F ).sign ? 10b0000000100 : 10b0000100000; }
            default: { classification = floatingpointnumber( sourceReg1F ).sign ? 10b0000000010 : 10b0001000000; }
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
    uint1   less = uninitialised;
    classify A( a <: sourceReg1F ); classify B( a <: sourceReg2F );
    floatcompare FPUlteq( a <: sourceReg1F, b <: sourceReg2F, less :> less );

    always {
        switch( ( A.sNAN | B.sNAN ) | ( A.qNAN & B.qNAN ) ) {
            case 1: { flags = 5b10000; result = 32h7fc00000; } // sNAN or both qNAN
            case 0: {
                switch( function3[0,1] ) {
                    case 0: { result = A.qNAN ? ( B.qNAN ? 32h7fc00000 : sourceReg2F ) : B.qNAN ? sourceReg1F : ( less ? sourceReg1F : sourceReg2F); }
                    case 1: { result = A.qNAN ? ( B.qNAN ? 32h7fc00000 : sourceReg2F ) : B.qNAN ? sourceReg1F : ( less ? sourceReg2F : sourceReg1F); }
                }
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
    uint1   less = uninitialised;
    uint1   equal = uninitialised;
    classify A( a <: sourceReg1F ); classify B( a <: sourceReg2F );
    floatcompare FPUlteq( a <: sourceReg1F, b <: sourceReg2F, less :> less, equal :> equal );

    always {
        switch( function3 ) {
            case 3b000: { flags = ( A.qNAN | A.sNAN | B.qNAN | B.sNAN ) ? 5b10000 : 0; result = ( A.qNAN | A.sNAN | B.qNAN | B.sNAN ) ? 0 : less | equal; }
            case 3b001: { flags = ( A.qNAN | A.sNAN | B.qNAN | B.sNAN ) ? 5b10000 : 0; result = ( A.qNAN | A.sNAN | B.qNAN | B.sNAN ) ? 0 : less; }
            case 3b010: { flags = ( A.sNAN | B.sNAN ) ? 5b10000 : 0; result = ( A.qNAN | A.sNAN | B.qNAN | B.sNAN ) ? 0 : equal; }
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
    result := { function3[1,1] ? sourceReg1F[31,1] ^ sourceReg2F[31,1] : function3[0,1] ? ~sourceReg2F[31,1] : sourceReg2F[31,1], sourceReg1F[0,31] };
}
