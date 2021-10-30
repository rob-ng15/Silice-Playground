algorithm fpufast(
    input   uint3   function3,
    input   uint7   function7,
    input   uint5   rs2,
    input   uint32  sourceReg1,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,

    output  uint32  result,
    output  uint1   frd,
    input   uint5   FPUflags,
    output  uint5   FPUnewflags
) <autorun,reginputs> {
    // GENERATE LESS AND EQUAL FLAGS FOR MIN/MAX AND COMPARISONS
    floatcompare FPUlteq( a <: sourceReg1F, b <: sourceReg2F );
    floatminmax FPUminmax( sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, less <: FPUlteq.less, function3 <: function3[0,1] );
    floatcomparison FPUcompare( sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, less <: FPUlteq.less, equal <: FPUlteq.equal, function3 <: function3[0,2], );
    floatclassify FPUclass( sourceReg1F <: sourceReg1F );
    floatsign FPUsign( function3 <: function3[0,2], sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F );

    always {
        frd = 1;
        switch( function7[2,5] ) {
            default: {
                // FSGNJ.S FSGNJN.S FSGNJX.S
                result = FPUsign.result; FPUnewflags = FPUflags;
            }
            case 5b00101: {
                // FMIN.S FMAX.S
                result = FPUminmax.result; FPUnewflags = FPUflags | FPUminmax.flags;
            }
            case 5b10100: {
                // FEQ.S FLT.S FLE.S
                frd = 0; result = FPUcompare.result; FPUnewflags = FPUflags | FPUcompare.flags;
            }
            case 5b11100: {
                // FCLASS.S FMV.X.W
                frd = 0; result = function3[0,1] ? FPUclass.classification : sourceReg1F; FPUnewflags = FPUflags;
            }
            case 5b11110: {
                // FMV.W.X
                result = sourceReg1; FPUnewflags = FPUflags;
            }
        }
    }
}

algorithm fpuslow(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint5   opCode,
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
) <autorun,reginputs> {
    floatcalc FPUcalculator( sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, sourceReg3F <: sourceReg3F, opCode <: opCode, function7 <: function7[2,5] );
    floatconvert FPUconvert( sourceReg1 <: sourceReg1, sourceReg1F <: sourceReg1F, direction <: function7[3,1], rs2 <: rs2[0,1], );

    FPUcalculator.start := 0; FPUconvert.start := 0;

    while(1) {
        if( start ) {
            busy = 1;
            frd = 1;
            if( opCode[2,1] ) {
                switch( function7[2,5] ) {
                    default: {
                        // FADD.S FSUB.S FMUL.S FDIV.S FSQRT.S
                        FPUcalculator.start = 1; while( FPUcalculator.busy ) {} result = FPUcalculator.result; FPUnewflags = FPUflags | FPUcalculator.flags;
                    }
                    case 5b11000: {
                        // FCVT.W.S FCVT.WU.S
                        frd = 0; FPUconvert.start = 1; while( FPUconvert.busy ) {} result = FPUconvert.result; FPUnewflags = FPUflags | FPUconvert.flags;
                    }
                    case 5b11010: {
                        // FCVT.S.W FCVT.S.WU
                        FPUconvert.start = 1; while( FPUconvert.busy ) {} result = FPUconvert.result; FPUnewflags = FPUflags | FPUconvert.flags;
                    }
                }
            } else {
                // FMADD.S FMSUB.S FNMSUB.S FNMADD.S
                FPUcalculator.start = 1; while( FPUcalculator.busy ) {} result = FPUcalculator.result; FPUnewflags = FPUflags | FPUcalculator.flags;
            }
            busy = 0;
        }
    }
}

// CONVERSION BETWEEN FLOAT AND SIGNED/UNSIGNED INTEGERS
algorithm floatconvert(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint1   direction,
    input   uint1   rs2,
    input   uint32  sourceReg1,
    input   uint32  sourceReg1F,

    output  uint5   flags,
    output  uint32  result
) <autorun,reginputs> {
    inttofloat FPUfloat( a <: sourceReg1, dounsigned <: rs2[0,1] );
    floattoint FPUint( a <: sourceReg1F );
    floattouint FPUuint( a <: sourceReg1F );

    always {
        if( start ) {
            busy = 1;
            if( direction ) {
                // FCVT.S.W FCVT.S.WU
                result = FPUfloat.result; flags = FPUfloat.flags;
            } else {
                // FCVT.W.S FCVT.WU.S
                result = rs2 ? FPUuint.result : FPUint.result; flags = rs2 ? FPUuint.flags : FPUint.flags;
            }
            busy = 0;
        }
    }
}

// FPU CALCULATION BLOCKS FUSED ADD SUB MUL DIV SQRT
algorithm floatcalc(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint5   opCode,
    input   uint5   function7,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    input   uint32  sourceReg3F,

    output  uint5   flags,
    output  uint32  result,
) <autorun,reginputs> {
    // ADD/SUB/MULT have changeable inputs due to 2 input and 3 input fused operations
    floataddsub FPUaddsub();
    floatmultiply FPUmultiply( b <: sourceReg2F );
    floatdivide FPUdivide( a <: sourceReg1F, b <: sourceReg2F );
    floatsqrt FPUsqrt( a <: sourceReg1F );

    FPUaddsub.start := 0; FPUmultiply.start := 0; FPUdivide.start := 0; FPUsqrt.start := 0;

    always {
        // PREPARE INPUTS FOR ADDITION/SUBTRACTION AND MULTIPLICATION
        if( opCode[2,1] ) {
            FPUaddsub.a = sourceReg1F; FPUaddsub.b = sourceReg2F; FPUaddsub.addsub = function7[0,1];
        } else {
            FPUmultiply.a = { opCode[1,1] ? ~sourceReg1F[31,1] : sourceReg1F[31,1], sourceReg1F[0,31] };
            FPUaddsub.a = FPUmultiply.result; FPUaddsub.b = sourceReg3F; FPUaddsub.addsub = opCode[0,1];
        }
    }

    while(1) {
        if( start ) {
            busy = 1;
            if( opCode[2,1] ) {
                // NON 3 REGISTER FPU OPERATIONS
                switch( function7[0,2] ) {
                    case 2b11: {
                        if( function7[3,1] ) {
                            // FSQRT.S
                            FPUsqrt.start = 1; while( FPUsqrt.busy ) {} result = FPUsqrt.result; flags = FPUsqrt.flags & 5b00110;
                        } else {
                            // FDIV.S
                            FPUdivide.start = 1; while( FPUdivide.busy ) {} result = FPUdivide.result; flags = FPUdivide.flags & 5b01110;
                        }
                    }
                    default: {
                        if( function7[1,1] ) {
                            // FMUL.S
                            FPUmultiply.a = sourceReg1F; FPUmultiply.start = 1; while( FPUmultiply.busy ) {} result = FPUmultiply.result; flags = FPUmultiply.flags & 5b00110;
                        } else {
                            // FADD.S FSUB.S
                            FPUaddsub.start = 1; while( FPUaddsub.busy ) {} result = FPUaddsub.result; flags = FPUaddsub.flags & 5b00110;
                        }
                    }
                }
            } else {
                // 3 REGISTER FUSED FPU OPERATIONS - MULTIPLY then ADD/SUB
                FPUmultiply.start = 1; while( FPUmultiply.busy ) {} FPUaddsub.start = 1; while( FPUaddsub.busy ) {} result = FPUaddsub.result;
                flags = ( FPUmultiply.flags & 5b10110 ) | ( FPUaddsub.flags & 5b00110 );
            }
            busy = 0;
        }
    }
}

algorithm floatclassify(
    input   uint32  sourceReg1F,
    output  uint10  classification
) <autorun,reginputs> {
    // CLASSIFY THE INPUT AND FLAG INFINITY, NAN, ZERO
    classify A( a <: sourceReg1F );
    uint4   class <:: { A.INF, A.sNAN, A.qNAN, A.ZERO };

    always {
        if( |class ) {
            onehot( class ) {
                case 0: { classification = ( ~|sourceReg1F[0,23] ) ? { 5b00000, ~fp32( sourceReg1F ).sign, fp32( sourceReg1F ).sign, 3b000 } :
                                                                    { 4b0000, ~fp32( sourceReg1F ).sign, 2b00, fp32( sourceReg1F ).sign, 2b00 }; }
                case 1: { classification = 10b1000000000; }
                case 2: { classification = 10b0100000000; }
                case 3: { classification = { 2b00, ~fp32( sourceReg1F ).sign, 6b000000, fp32( sourceReg1F ).sign }; }
            }
        } else {
            classification = { 3b000, ~fp32( sourceReg1F ).sign, 4b0000, fp32( sourceReg1F ).sign, 1b0 };
        }
    }
}

algorithm floatminmax(
    input   uint1   less,
    input   uint1   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    output  uint5   flags,
    output  uint32  result
) <autorun,reginputs> {
    // CLASSIFY THE INPUTS AND FLAG NAN
    classify A( a <: sourceReg1F );
    classify B( a <: sourceReg2F );
    uint1   NAN <:: ( A.sNAN | B.sNAN ) | ( A.qNAN & B.qNAN );

    flags := { NAN, 4b0000 };
    always {
        if( NAN ) {
            // sNAN or both qNAN
            result = 32h7fc00000;
        } else {
            if( function3 ) {
                result = A.qNAN ? ( B.qNAN ? 32h7fc00000 : sourceReg2F ) : B.qNAN ? sourceReg1F : ( less ? sourceReg2F : sourceReg1F );
            } else {
                result = A.qNAN ? ( B.qNAN ? 32h7fc00000 : sourceReg2F ) : B.qNAN ? sourceReg1F : ( less ? sourceReg1F : sourceReg2F );
            }
        }
    }
}

// COMPARISONS
algorithm floatcomparison(
    input   uint1   less,
    input   uint1   equal,
    input   uint2   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    output  uint5   flags,
    output  uint1  result
) <autorun,reginputs> {
    // CLASSIFY THE INPUTS AND FLAG INFINITY, NAN
    classify A( a <: sourceReg1F );
    classify B( a <: sourceReg2F );
    uint1   NAN <:: ( A.qNAN | A.sNAN | B.qNAN | B.sNAN );

    always {
        switch( function3 ) {
            case 2b00: { flags = { NAN, 4b0000 }; result = ~NAN & ( less | equal ); }
            case 2b01: { flags = { NAN, 4b0000 }; result = ~NAN & less; }
            case 2b10: { flags = { ( A.sNAN | B.sNAN ), 4b0000 }; result = ~NAN & equal; }
            default: { result = 0; }
        }
    }
}

algorithm floatsign(
    input   uint2   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    output  uint32  result,
) <autorun,reginputs> {
    uint1   sign <:: function3[1,1] ? sourceReg1F[31,1] ^ sourceReg2F[31,1] : function3[0,1] ? ~sourceReg2F[31,1] : sourceReg2F[31,1];
    always {
        result = { sign, sourceReg1F[0,31] };
    }
}
