algorithm fpufast(
    input   uint2   function3,
    input   uint5   function7,
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

    always_after {
        switch( function7[3,2] ) {
            case 2b00: {
                // FMIN.S FMAX.S FSGNJ.S FSGNJN.S FSGNJX.S
                frd = 1; result = function7[0,1] ? FPUminmax.result : FPUsign.result; FPUnewflags = FPUflags | ( function7[0,1] ? FPUminmax.flags : 0 );
            }
            case 2b10: {
                // FEQ.S FLT.S FLE.S
                frd = 0; result = FPUcompare.result; FPUnewflags = FPUflags | FPUcompare.flags;
            }
            default: {
                // FCLASS.S FMV.X.W FMV.W.X
                frd = function7[1,1]; result = function7[1,1] ? sourceReg1 : function3[0,1] ? FPUclass.classification : sourceReg1F; FPUnewflags = FPUflags;
            }
        }
    }
}

algorithm fpuslow(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint5   opCode,
    input   uint5   function7,
    input   uint1   rs2,
    input   uint32  sourceReg1,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    input   uint32  sourceReg3F,

    output  uint32  result,
    output  uint1   frd,
    input   uint5   FPUflags,
    output  uint5   FPUnewflags
) <autorun,reginputs> {
    floatcalc FPUcalculator( sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, sourceReg3F <: sourceReg3F, opCode <: opCode, function7 <: function7 );
    floatconvert FPUconvert( sourceReg1 <: sourceReg1, sourceReg1F <: sourceReg1F, direction <: function7[1,1], rs2 <: rs2, );

    FPUcalculator.start := start & ~( opCode[2,1] & function7[4,1] );

    while(1) {
        if( start ) {
            busy = 1;
            if( opCode[2,1] && function7[4,1] ) {
                // FCVT.W.S FCVT.WU.S  FCVT.S.W FCVT.S.WU
                if( function7[1,1] ) { frd = 1; ++: } else { frd = 0; } result = FPUconvert.result; FPUnewflags = FPUflags | FPUconvert.flags;
            } else {
                // FMADD.S FMSUB.S FNMSUB.S FNMADD.S FADD.S FSUB.S FMUL.S FDIV.S FSQRT.S
                frd = 1; while( FPUcalculator.busy ) {} result = FPUcalculator.result; FPUnewflags = FPUflags | FPUcalculator.flags;
            }
            busy = 0;
        }
    }
}

// CONVERSION BETWEEN FLOAT AND SIGNED/UNSIGNED INTEGERS
algorithm floatconvert(
    input   uint1   direction,
    input   uint1   rs2,
    input   uint32  sourceReg1,
    input   uint32  sourceReg1F,

    output  uint5   flags,
    output  uint32  result
) <autorun,reginputs> {
    inttofloat FPUfloat( a <: sourceReg1, dounsigned <: rs2[0,1] );
    floattoint FPUint( a <: sourceReg1F, dounsigned <: rs2[0,1] );

    always_after {
        // FCVT.S.W FCVT.S.WU FCVT.W.S FCVT.WU.S
        result = direction ? FPUfloat.result : FPUint.result; flags = direction ? FPUfloat.flags : FPUint.flags;
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
            FPUmultiply.a = sourceReg1F;
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
                    default: {
                        // FADD.S FSUB.S
                        FPUaddsub.start = 1; while( FPUaddsub.busy ) {} result = FPUaddsub.result; flags = FPUaddsub.flags & 5b00110;
                    }
                    case 2b10: {
                        // FMUL.S
                        FPUmultiply.start = 1; while( FPUmultiply.busy ) {} result = FPUmultiply.result; flags = FPUmultiply.flags & 5b00110;
                    }
                    case 2b11: {
                        if( function7[3,1] ) {
                            // FSQRT.S
                            FPUsqrt.start = 1; while( FPUsqrt.busy ) {} result = FPUsqrt.result; flags = FPUsqrt.flags & 5b00110;
                        } else {
                            // FDIV.S
                            FPUdivide.start = 1; while( FPUdivide.busy ) {} result = FPUdivide.result; flags = FPUdivide.flags & 5b01110;
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
) <autorun> {
    // CLASSIFY THE INPUT AND FLAG INFINITY, NAN, ZERO
    classify A( a <: sourceReg1F );                 uint4   classA <:: { A.INF, A.sNAN, A.qNAN, A.ZERO };
    uint4   bit = uninitialised;

    always_after {
        if( |classA ) {
            // INFINITY, NAN OR ZERO
            onehot( classA ) {
                case 0: { bit = ~|sourceReg1F[0,23] ? fp32( sourceReg1F ).sign ? 3 : 4 : fp32( sourceReg1F ).sign ? 2 : 5; }
                case 1: { bit = 9; }
                case 2: { bit = 8; }
                case 3: { bit = fp32( sourceReg1F ).sign ? 0 : 7; }
            }
        } else {
            // NUMBER
            bit = fp32( sourceReg1F ).sign ? 1 : 6;
        }
        classification = 1 << bit;
    }
}

algorithm floatminmax(
    input   uint1   less,
    input   uint1   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    output  uint5   flags,
    output  uint32  result
) <autorun> {
    // CLASSIFY THE INPUTS AND FLAG NAN
    classify A( a <: sourceReg1F );                 classify B( a <: sourceReg2F );
    uint1   NAN <:: ( A.sNAN | B.sNAN ) | ( A.qNAN & B.qNAN );

    flags := { NAN, 4b0000 };
    always_after {
        result = NAN ? 32h7fc00000 : A.qNAN ? ( B.qNAN ? 32h7fc00000 : sourceReg2F ) : B.qNAN | ( function3 ^ less ) ? sourceReg1F : sourceReg2F;
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
) <autorun> {
    // CLASSIFY THE INPUTS AND FLAG INFINITY, NAN
    classify A( a <: sourceReg1F );                 classify B( a <: sourceReg2F );
    uint1   NAN <:: ( A.qNAN | A.sNAN | B.qNAN | B.sNAN );
    uint4   comparison <:: { 1b0, equal, less, less | equal };
    flags := { function3[1,1] ? ( A.sNAN | B.sNAN ) : NAN, 4b0000 }; result := 0;
    always_after {
        result = ~NAN & comparison[ function3, 1 ];
    }
}

algorithm floatsign(
    input   uint2   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    output  uint32  result,
) <autorun> {
    uint1   sign <:: function3[1,1] ? sourceReg1F[31,1] ^ sourceReg2F[31,1] : function3[0,1] ^ sourceReg2F[31,1];
    always_after {
        result = { sign, sourceReg1F[0,31] };
    }
}
