algorithm fpu(
    input   uint1   start,
    output! uint1   busy,

    input   uint7   opCode,
    input   uint3   function3,
    input   uint7   function7,
    input   uint5   rs1,
    input   uint5   rs2,
    input   uint32  sourceReg1,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    input   uint32  sourceReg3F,

    output! uint32  result,
    output  uint1   frd
) <autorun> {
    // FLOATING POINT FUNCTION UNITS
    inttofloat INTTOFLOAT(
        rs2 <: rs2,
        source <: sourceReg1
    );
    floattoint FLOATTOINT(
        rs2 <: rs2,
        source <: sourceReg1F
    );
    floatminmax MINMAX(
    );
    floatcompare COMPARE(
    );
    floatadd ADD(
    );
    floatsub SUB(
    );
    floatmul MUL(
    );
    floatdiv DIV(
    );
    floatsqrt SQRT(
    );
    floatclassify CLASS(
    );
    floatfusedops FUSED(
    );

    INTTOFLOAT.start := 0;
    FLOATTOINT.start := 0;
    MINMAX.start := 0;
    COMPARE.start := 0;
    ADD.start := 0;
    SUB.start := 0;
    MUL.start := 0;
    DIV.start := 0;
    SQRT.start := 0;
    CLASS.start := 0;
    FUSED.start := 0;

    while(1) {
        if( start ) {
            busy = 1;

            switch( opCode[2,5] ) {
                case 5b10000: {
                    // FMADD.S
                    frd = 1;
                    FUSED.start = 1;
                    while( FUSED.busy ) {}
                    result = FUSED.result;
                }
                case 5b10001: {
                    // FMSUB.S
                    frd = 1;
                    FUSED.start = 1;
                    while( FUSED.busy ) {}
                    result = FUSED.result;
                }
                case 5b10010: {
                    // FNMSUB.S
                    frd = 1;
                    FUSED.start = 1;
                    while( FUSED.busy ) {}
                    result = FUSED.result;
                }
                case 5b10011: {
                    // FNMADD.S
                    frd = 1;
                    FUSED.start = 1;
                    while( FUSED.busy ) {}
                    result = FUSED.result;
                }
                case 5b10100: {
                    // NON 3 REGISTER FPU OPERATIONS
                    switch( function7[2,5] ) {
                        case 5b00000: {
                            // FADD.S
                            frd = 1;
                            ADD.start = 1;
                            while( ADD.busy ) {}
                            result = ADD.result;
                        }
                        case 5b00001: {
                            // FSUB.S
                            frd = 1;
                            SUB.start = 1;
                            while( SUB.busy ) {}
                            result = SUB.result;
                        }
                        case 5b00010: {
                            // FMUL.S
                            frd = 1;
                            MUL.start = 1;
                            while( MUL.busy ) {}
                            result = MUL.result;
                        }
                        case 5b00011: {
                            // FDIV.S
                            frd = 1;
                            DIV.start = 1;
                            while( DIV.busy ) {}
                            result = DIV.result;
                        }
                        case 5b010011: {
                            // FSQRT.S
                            frd = 1;
                            SQRT.start = 1;
                            while( SQRT.busy ) {}
                            result = SQRT.result;
                        }
                        case 5b00100: {
                            // FSGNJ.S FNGNJN.S FSGNJX.S
                            frd = 1;
                            switch( function3 ) {
                                case 3b000: {
                                    // FSGNJ.S
                                    result = { sourceReg2F[31,1] ? 1b1 : 1b0, sourceReg1F[0,31] };
                                }
                                case 3b001: {
                                    // FSGNJN.S
                                    result = { sourceReg2F[31,1] ? 1b0 : 1b1, sourceReg1F[0,31] };
                                }
                                case 3b010: {
                                    // FSGNJX.S
                                    result = { sourceReg1F[31,1] ^ sourceReg2F[31,1], sourceReg1F[0,31] };
                                }
                            }
                        }
                        case 5b00101: {
                            // FMIN.S FMAX.S
                            frd = 1;
                            MINMAX.start = 1;
                            while( MINMAX.busy ) {}
                            result = MINMAX.result;
                        }
                        case 5b11000: {
                            // FCVT.W.S FCVT.WU.S
                            frd = 1;
                            INTTOFLOAT.start = 1;
                            while( INTTOFLOAT.busy ) {}
                            result = INTTOFLOAT.result;
                        }
                        case 5b11100: {
                            // FMV.X.W
                            frd = 0;
                            result = sourceReg1F;
                        }
                        case 5b10100: {
                            // FEQ.S FLT.S FLE.S
                            frd = 0;
                            COMPARE.start = 1;
                            while( COMPARE.busy ) {}
                            result = COMPARE.result;
                        }
                        case 5b11100: {
                            // FCLASS.S
                            frd = 0;
                            CLASS.start = 1;
                            while( CLASS.busy ) {}
                            result = CLASS.result;
                        }
                        case 5b11010: {
                            // FCVT.S.W FCVT.S.WU
                            frd = 0;
                            FLOATTOINT.start = 1;
                            while( FLOATTOINT.busy ) {}
                            result = FLOATTOINT.result;
                        }
                        case 5b11110: {
                            // FMV.W.X
                            frd = 1;
                            result = sourceReg1;
                        }
                    }
                }
            }

            busy = 0;
        }
    }
}

// FLOATING POINT SUB UNITS
algorithm inttofloat(
    input   uint1   start,
    output! uint1   busy,

    input   uint5   rs2,
    input   uint32  source,

    output! uint32  result
) <autorun> {
    uint1   sign = uninitialised;
    uint32  number = uninitialised;

    while(1) {
        if( start) {
            busy = 1;

            switch( rs2[0,1] ) {
                case 1b0: {
                    // SIGNED
                    sign = source[31,1];
                    number = source[31,1] ? -source : source;
                }
                case 1b1: {
                    // UNSIGNED
                    sign = 0;
                    number = source;
                }
            }
            ++:
            if( number == 0 ) {
            } else {
            }

            busy = 0;
        }
    }
}
algorithm floattoint(
    input   uint1   start,
    output! uint1   busy,

    input   uint5   rs2,
    input   uint32  source,

    output! uint32  result
) <autorun> {
    while(1) {
        if( start) {
            busy = 1;

            busy = 0;
        }
    }
}
algorithm floatminmax(
    input   uint1   start,
    output! uint1   busy,

    output! uint32  result
) <autorun> {
    while(1) {
        if( start) {
            busy = 1;

            busy = 0;
        }
    }
}
algorithm floatcompare(
    input   uint1   start,
    output! uint1   busy,

    output! uint32  result
) <autorun> {
    while(1) {
        if( start) {
            busy = 1;

            busy = 0;
        }
    }
}
algorithm floatadd(
    input   uint1   start,
    output! uint1   busy,

    output! uint32  result
) <autorun> {
    while(1) {
        if( start) {
            busy = 1;

            busy = 0;
        }
    }
}
algorithm floatsub(
    input   uint1   start,
    output! uint1   busy,

    output! uint32  result
) <autorun> {
    while(1) {
        if( start) {
            busy = 1;

            busy = 0;
        }
    }
}
algorithm floatmul(
    input   uint1   start,
    output! uint1   busy,

    output! uint32  result
) <autorun> {
    while(1) {
        if( start) {
            busy = 1;

            busy = 0;
        }
    }
}
algorithm floatdiv(
    input   uint1   start,
    output! uint1   busy,

    output! uint32  result
) <autorun> {
    while(1) {
        if( start) {
            busy = 1;

            busy = 0;
        }
    }
}
algorithm floatsqrt(
    input   uint1   start,
    output! uint1   busy,

    output! uint32  result
) <autorun> {
    while(1) {
        if( start) {
            busy = 1;

            busy = 0;
        }
    }
}
algorithm floatclassify(
    input   uint1   start,
    output! uint1   busy,

    output! uint32  result
) <autorun> {
    while(1) {
        if( start) {
            busy = 1;

            busy = 0;
        }
    }
}
algorithm floatfusedops(
    input   uint1   start,
    output! uint1   busy,

    output! uint32  result
) <autorun> {
    while(1) {
        if( start) {
            busy = 1;

            busy = 0;
        }
    }
}
