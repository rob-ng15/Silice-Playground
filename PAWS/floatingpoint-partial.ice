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
    // COUNT LEADING 0s 32 bit
    subroutine countleadingzeros32( input uint32 a, output uint8 count ) {
        uint32  bitstream = uninitialised;

        bitstream = a;
        switch( bitstream ) {
            case 0: { count = 32; }
            default: {
                count = 0;
                while( ~bitstream[31,1] ) {
                    count = count + 1;
                    bitstream = { bitstream[1,31], 1b0 };
                }
            }
        }
    }
    // COUNT LEADING 0s 64 bit
    subroutine countleadingzeros64( input uint64 a, output uint16 count ) {
        uint64  bitstream = uninitialised;

        bitstream = a;
        switch( bitstream ) {
            case 0: { count = 64; }
            default: {
                count = 0;
                while( ~bitstream[63,1] ) {
                    count = count + 1;
                    bitstream = { bitstream[1,63], 1b0 };
                }
            }
        }
    }
    // NORMALISE A 64BT MANTISSA WITH 16BIT EXPONENT
    subroutine normalise64( input uint1 sign, input int16 exp, input uint64 number, output uint32 F32, calls countleadingzeros64 ) {
        int16   expA = uninitialised;
        uint64  a = uninitialised;

        if( number == 0 ) {
            F32 = { sign, 31b0 };
        } else {
            ( expA ) <- countleadingzeros64 <- ( number );
            ++:
            if( expA > 56 ) {
                a = number >> ( expA - 56 );
            } else {
                if( expA < 56 ) {
                    a = number << ( 56 - expA );
                }
            }
            expA = exp + ( expA - 56 ) + 127;
            F32 = { sign, expA[0,8], a[0,23] };
        }
    }

    // CONVERT SIGNED/UNSIGNED INTEGERS TO FLOAT
    subroutine inttofloat( input uint32 a, output uint32 F32, reads rs2, calls countleadingzeros32 ) {
        uint1   sign = uninitialised;
        int8    exp = uninitialised;
        uint32  number = uninitialised;

        switch( rs2[0,1] ) {
            case 0: {
                // SIGNED
                sign = a[31,1];
                number = a[31,1] ? -a : a;
            }
            case 1: {
                // UNSIGNED
                sign = 0;
                number = a;
            }
        }

        if( number == 0 ) {
            F32 = { sign, 31b0 };
        } else {
            ( exp ) <- countleadingzeros32 <- ( number );
            ++:
            exp = 31 - exp;
            if( exp > 24 ) {
                number = number >> ( exp - 24 );
            } else {
                if( exp < 24 ) {
                    number = number << ( 24 - exp );
                }
            }
            ++:
            exp = exp + 127;
            F32 = { sign, exp[0,8], number[0,23] };
        }
    }

    // SIGNED MULTIPLY OF 2 FLOATING POINT NUMBERS
    subroutine floatmultiply( input uint32 a, input uint32 b, output uint32 F32, calls normalise64 ) {
        uint1   productsign = uninitialised;
        uint64  product = uninitialised;
        int16   productexp = uninitialised;

        int16   expA = uninitialised;
        int16   expB = uninitialised;

        // Calculation is split into 4 18 x 18 multiplications for DSP
        uint18  A = uninitialized;
        uint18  B = uninitialized;
        uint18  C = uninitialized;
        uint18  D = uninitialized;

        expA = floatingpointnumber( a ).exponent;
        expB = floatingpointnumber( b ).exponent;
        productsign = a[31,1] ^ b[31,1];
        ++:
        if( ( expA == 0 ) || ( expB == 0 ) ) {
            F32 = { productsign, 31b0 };
        } else {
            expA = expA - 127;
            expB = expB - 127;
            A = { 10b0, 1b1, a[16,7] };
            B = { 2b0, a[0,16] };
            C = { 10b0, 1b1, b[16,7] };
            D = { 2b0, b[0,16] };
            ++:
            product = ( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } );
            productexp = expA + expB;
            ++:
            ( F32 ) <- normalise64 <- ( productsign, productexp, product );
        }
    }

    // SIGNED DIVISION OF 2 FLOATING POINT NUMBERS
    subroutine floatdivide( input uint32 a, input uint32 b, output uint32 F32, calls normalise64 ) {
        uint1   productsign = uninitialised;
        uint64  product = uninitialised;
        int16   productexp = uninitialised;

        int16   expA = uninitialised;
        int16   expB = uninitialised;

        // Calculation is split into 4 18 x 18 multiplications for DSP
        uint18  A = uninitialized;
        uint18  B = uninitialized;
        uint18  C = uninitialized;
        uint18  D = uninitialized;

        expA = floatingpointnumber( a ).exponent;
        expB = floatingpointnumber( b ).exponent;
        productsign = a[31,1] ^ b[31,1];
        ++:
        if(  expB == 0 ) {
            // DIVIDE BY ZERO
            F32 = { productsign, 8b11111111, 23b0 };
        } else {
            if( expA == 0 ) {
                F32 = { productsign, 31b0 };
            } else {
                expA = expA - 127;
                expB = expB - 127;
                A = { 10b0, 1b1, a[16,7] };
                B = { 2b0, a[0,16] };
                C = { 10b0, 1b1, b[16,7] };
                D = { 2b0, b[0,16] };
                ++:
                product = ( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } );
                productexp = expA - expB;
                ++:
                ( F32 ) <- normalise64 <- ( productsign, productexp, product );
            }
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
                            busy = 1;
                            ( result ) <- floatmultiply <- ( sourceReg1F, sourceReg2F );
                            busy = 0;
                        }
                        case 5b00011: {
                            // FDIV.S
                            frd = 1;
                            busy = 1;
                            ( result ) <- floatdivide <- ( sourceReg1F, sourceReg2F );
                            busy = 0;
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
                            busy = 1;
                            ( result ) <- inttofloat <- ( sourceReg1 );
                            busy = 0;
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
