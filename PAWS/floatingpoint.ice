// ROUNDING MODES
$$ RNE = 0
$$ RTZ = 1
$$ RDN = 2
$$ RUP = 3
$$ RMM = 4

// EXCEPTIONS FLAGS
$$ NX = 1
$$ UF = 2
$$ OF = 4
$$ DZ = 8
$$ NV = 16

// BITFIELD FOR FLOATING POINT NUMBER
bitfield floatingpointnumber{
    uint1   sign,
    uint8   exponent,
    uint23  fraction
}

// BITFIELD FOR FLOATING POINT CSR REGISTER
bitfield floatingpointcsr{
    uint24  reserved,
    uint3   frm,
    uint5   fflags
}

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
    subroutine countLeadingZeros32( input uint32 a, output uint8 count) {
        uint32  bitstream = uninitialised;

        bitstream = a;
        count = 0;
        while( bitstream[31,1] == 0 ) {
            count = count + 1;
            bitstream = { bitstream[1,31], 1b0 };
        }
    }

    subroutine packToF32UI( input uint1 sign, input int8 exp, input uint32 sig, output uint32 F32UI ) {
        F32UI = { sign, exp, sig[0,23] };
    }

    subroutine roundPackToF32( input uint1 sign, input int8 exp, input uint32 sig, output uint32 F32UI ) {
    }

    subroutine normRoundPackToF32( input uint1 sign, input int8 exp, input uint32 sig, output uint32 F32UI, calls countLeadingZeros32, calls packToF32UI, calls roundPackToF32 ) {
        int8    shiftDist = uninitialised;
        int8    expA = uninitialised;
        uint32  sigA = uninitialised;

        ( shiftDist ) <- countLeadingZeros32 <- ( sig );
        shiftDist = shiftDist - 1;
        expA = exp - shiftDist;
        if( ( 7<= shiftDist ) && (__unsigned(expA) < 8hfd ) ) {
            sigA = sig << ( shiftDist - 7 );
            ( F32UI ) <- packToF32UI <- ( sign, expA, sigA );
        } else {
            sigA = sig << shiftDist;
            ( F32UI ) <- roundPackToF32 <- ( sign, expA, sigA );
        }
    }

    while(1) {
        if( start ) {
            busy = 1;

            switch( opCode[2,5] ) {
                case 5b10000: {
                    // FMADD.S
                    frd = 1;
                }
                case 5b10001: {
                    // FMSUB.S
                    frd = 1;
                }
                case 5b10010: {
                    // FNMSUB.S
                    frd = 1;
                }
                case 5b10011: {
                    // FNMADD.S
                    frd = 1;
                }
                case 5b10100: {
                    // NON 3 REGISTER FPU OPERATIONS
                    switch( function7[2,5] ) {
                        case 5b00000: {
                            // FADD.S
                            frd = 1;
                            result = sourceReg1F + sourceReg2F;
                        }
                        case 5b00001: {
                            // FSUB.S
                            frd = 1;
                            result = sourceReg1F - sourceReg2F;
                        }
                        case 5b00010: {
                            // FMUL.S
                            frd = 1;
                            result = sourceReg1F | sourceReg2F;
                        }
                        case 5b00011: {
                            // FDIV.S
                            frd = 1;
                            result = sourceReg1F & sourceReg2F;
                        }
                        case 5b010011: {
                            // FSQRT.S
                            frd = 1;
                            result = sourceReg1F ^ sourceReg2F;
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
                            switch( function3[0,1] ) {
                                case 0: { result = ( sourceReg1F < sourceReg2F ) ? sourceReg1F : sourceReg2F; }
                                case 1: { result = ( sourceReg1F > sourceReg2F ) ? sourceReg1F : sourceReg2F; }
                            }
                        }
                        case 5b11000: {
                            // FCVT.W.S FCVT.WU.S
                            frd = 0;
                            result = sourceReg1F;
                        }
                        case 5b11100: {
                            // FMV.X.W
                            frd = 0;
                            result = sourceReg1F;
                        }
                        case 5b10100: {
                            // FEQ.S FLT.S FLE.S
                            frd = 0;
                            switch( function3 ) {
                                case 3b000: { result = ( sourceReg1F <= sourceReg2F ) ? 1 : 0; }
                                case 3b001: { result = ( sourceReg1F < sourceReg2F ) ? 1 : 0; }
                                case 3b010: { result = ( sourceReg1F == sourceReg2F ) ? 1 : 0; }
                            }
                        }
                        case 5b11100: {
                            // FCLASS.S
                            frd = 0;
                            result = { 23b0, 9b000100000 };
                        }
                        case 5b11010: {
                            // FCVT.S.W FCVT.S.WU
                            frd = 1;
                            result = sourceReg1;
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
