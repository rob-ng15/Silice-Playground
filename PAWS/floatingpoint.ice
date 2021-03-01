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
    output! uint1   frd
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
                    bitstream = { bitstream[0,31], 1b0 };
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
                    bitstream = { bitstream[0,63], 1b0 };
                }
            }
        }
    }
    // NORMALISE A 32BT MANTISSA, ADJUST EXPONENT
    subroutine normalise32adjexp( input uint1 sign, input int8 exp, input uint32 number, output uint32 F32, calls countleadingzeros32 ) {
        uint8  zeros = uninitialised;
        int8   expA = uninitialised;
        uint32  a = uninitialised;

        if( number == 0 ) {
            F32 = { sign, 31b0 };
        } else {
            ( zeros ) <- countleadingzeros32 <- ( number );
            expA = exp;
            ++:
            if( zeros < 8 ) {
                a = number >> ( zeros - 8 );
                expA = expA + ( zeros - 8 );
            } else {
                if( zeros > 8 ) {
                    a = number << ( 8 - zeros );
                    expA = expA - ( 8 - zeros );
                }
            }
            ++:
            expA = expA + 127;
            F32 = { sign, expA[0,8], a[0,23] };
        }
    }
    // NORMALISE A 32BT MANTISSA, LEAVE EXPONENT
    subroutine normalise32( input uint1 sign, input int8 exp, input uint32 number, output uint32 F32, calls countleadingzeros32 ) {
        uint8  zeros = uninitialised;
        int8   expA = uninitialised;
        uint32  a = uninitialised;

        if( number == 0 ) {
            F32 = { sign, 31b0 };
        } else {
            ( zeros ) <- countleadingzeros32 <- ( number );
            expA = exp + 127;
            ++:
            if( zeros < 8 ) {
                a = number >> ( zeros - 8 );
            } else {
                if( zeros > 8 ) {
                    a = number << ( 8 - zeros );
                }
            }
            F32 = { sign, expA[0,8], a[0,23] };
        }
    }
    // NORMALISE A 64BT MANTISSA WITH 16BIT EXPONENT
    subroutine normalise64( input uint1 sign, input int16 exp, input uint64 number, output uint32 F32, calls countleadingzeros64 ) {
        uint8   zeros = uninitialised;
        int16   expA = uninitialised;
        uint64  a = uninitialised;

        if( number == 0 ) {
            F32 = { sign, 31b0 };
        } else {
            ( zeros ) <- countleadingzeros64 <- ( number );
            expA = exp + 127;
            ++:
            if( zeros < 40 ) {
                a = number >> ( zeros - 40 );
            } else {
                if( zeros > 40 ) {
                    a = number << ( 40 - zeros );
                }
            }
            F32 = { sign, expA[0,8], a[0,23] };
        }
    }

    // CONVERT SIGNED/UNSIGNED INTEGERS TO FLOAT
    subroutine inttofloat( input uint32 a, output uint32 F32, reads rs2, calls countleadingzeros32 ) {
        uint1   sign = uninitialised;
        uint8   exp = uninitialised;
        uint8   zeros = uninitialised;
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
            ( zeros ) <- countleadingzeros32 <- ( number );
            ++:
            if( zeros < 8 ) {
                number = number >> ( 8 - zeros );
            } else {
                if( zeros > 8 ) {
                    number = number << ( zeros - 8 );
                }
            }
            ++:
            exp = 158 - zeros;
            F32 = { sign, exp[0,8], number[0,23] };
        }
    }

    // ADDITION OF 2 FLOATING POINT NUMBERS - SAME SIGN
    subroutine floatadd( input uint32 a, input uint32 b, output uint32 F32, calls normalise32adjexp ) {
        uint1   sign = uninitialised;
        int8    expA = uninitialised;
        int8    expB = uninitialised;
        uint32  sigA = uninitialised;
        uint32  sigB = uninitialised;
        uint32  total = uninitialised;

        expA = floatingpointnumber( a ).exponent;
        expB = floatingpointnumber( b ).exponent;
        sigA = { 9b1, a[0,23] };
        sigB = { 9b1, b[0,23] };
        sign = a[31,1];
        ++:

        if( ( expA == 0 ) || ( expB == 0 ) ) {
            if( expA == 0 ) {
                F32 = b;
            } else {
                F32 = a;
            }
        } else {
            // ADJUST TO EQUAL EXPONENTS
            if( expA < expB ) {
                sigA = sigA >> ( expB - expA );
                expA = expB;
            }
            if( expB < expA ) {
                sigB = sigB >> ( expA - expB );
                expB = expA;
            }
            ++:
            total = sigA + sigB;
            expA = expA - 127;
            ++:
            ( F32 ) <- normalise32adjexp <- ( sign, expA, total );
        }
    }

    // SUBTRACTION OF 2 FLOATING POINT NUMBERS
    subroutine floatsub( input uint32 a, input uint32 b, output uint32 F32, calls normalise32adjexp ) {
        uint1   sign = uninitialised;
        int8    expA = uninitialised;
        int8    expB = uninitialised;
        uint32  sigA = uninitialised;
        uint32  sigB = uninitialised;
        uint32  total = uninitialised;

        expA = floatingpointnumber( a ).exponent;
        expB = floatingpointnumber( b ).exponent;
        sigA = { 9b1, a[0,23] };
        sigB = { 9b1, b[0,23] };
        sign = a[31,1];
        ++:

        if( ( expA == 0 ) || ( expB == 0 ) ) {
            if( expA == 0 ) {
                F32 = { ~b[31,1], b[0,31] };
            } else {
                F32 = a;
            }
        } else {
            // ADJUST TO EQUAL EXPONENTS
            if( expA < expB ) {
                sigA = sigA >> ( expB - expA );
                expA = expB;
            }
            if( expB < expA ) {
                sigB = sigB >> ( expA - expB );
                expB = expA;
            }
            ++:
            total = sigA - sigB;
            ++:
            if( total[23,8] != 0 ) {
                sign = ~sign;
                total = -total;
            }
            expA = expA - 127;
            ++:
            ( F32 ) <- normalise32adjexp <- ( sign, expA, total );
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
        ++:
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
    subroutine floatdivide( input uint32 a, input uint32 b, output uint32 F32, calls normalise32 ) {
        uint1   quotientsign = uninitialised;
        int8    quotientexp = uninitialised;
        uint32  quotient = uninitialised;
        uint32  remainder = uninitialised;
        uint6   bit = uninitialised;

        int8    expA = uninitialised;
        int8    expB = uninitialised;
        uint32  sigA = uninitialised;
        uint32  sigB = uninitialised;

        expA = floatingpointnumber( a ).exponent;
        expB = floatingpointnumber( b ).exponent;
        quotientsign = a[31,1] ^ b[31,1];
        ++:
        if(  expB == 0 ) {
            // DIVIDE BY ZERO
            F32 = { quotientsign, 8b11111111, 23b0 };
        } else {
            if( expA == 0 ) {
                F32 = { quotientsign, 31b0 };
            } else {
                expA = expA - 127;
                expB = expB - 127;
                sigA = { 9b1, a[0,23] };
                sigB = { 9b1, b[0,23] };
                bit = 31;
                quotient = 0;
                remainder = 0;
                ++:
                quotientexp = expA - expB;
                while( bit != 63 ) {
                    if( __unsigned({ remainder[0,31], sigA[bit,1] }) >= __unsigned(sigB) ) {
                            remainder = __unsigned({ remainder[0,31], sigA[bit,1] }) - __unsigned(sigB);
                            quotient[bit,1] = 1;
                    } else {
                        remainder = { remainder[0,31], sigA[bit,1] };
                    }
                    bit = bit - 1;
                }
                ( F32 ) <- normalise32 <- ( quotientsign, quotientexp, quotient );
            }
        }
    }

    // LESS THAN COMPARISON OF 2 FLOATING POINT NUMBERS
    subroutine floatless( input uint32 a, input uint32 b, output uint32 lessthan ) {
        uint1   signA = uninitialised;
        uint1   signB = uninitialised;

        signA = floatingpointnumber( a ).sign;
        signB = floatingpointnumber( b ).sign;
        ++:
        lessthan = ( signA != signB ) ? signA && ((( a | b ) << 1) != 0 ) : ( a != b ) && ( signA ^ ( a < b));
    }
    // LESS THAN EQUAL OMPARISON OF 2 FLOATING POINT NUMBERS
    subroutine floatlessequal( input uint32 a, input uint32 b, output uint32 equalto ) {
        uint1   signA = uninitialised;
        uint1   signB = uninitialised;

        signA = floatingpointnumber( a ).sign;
        signB = floatingpointnumber( b ).sign;
        ++:
        equalto = ( a == b ) || (((a | b) << 1) == 0 );
    }
    // EQUAL COMPARISON OF 2 FLOATING POINT NUMBERS
    subroutine floatequal( input uint32 a, input uint32 b, output uint32 lessthanequal ) {
        uint1   signA = uninitialised;
        uint1   signB = uninitialised;

        signA = floatingpointnumber( a ).sign;
        signB = floatingpointnumber( b ).sign;
        ++:
        lessthanequal = ( signA != signB ) ? signA || ((( a | b ) << 1) != 0 ) : ( a != b ) || ( signA ^ ( a < b));
    }

    // CHANGE SIGN OF A PACKED FLOATING POINT NUMBER
    subroutine changesign( input uint32 a, output uint32 F32 ) {
        F32 = a;
        ++:
        F32[31,1] = ~F32[31,1];
    }

    uint32  sourceReg1Falt = uninitialised;
    uint32  sourceReg2Falt = uninitialised;
    uint32  sourceReg3Falt = uninitialised;
    uint32  workingresult = uninitialised;

    while(1) {
        if( start ) {
            busy = 1;

            switch( opCode[2,5] ) {
                case 5b10000: {
                    // FMADD.S
                    frd = 1;
                    ( workingresult ) <- floatmultiply <- ( sourceReg1F, sourceReg2F );
                    switch( { workingresult[31,1], sourceReg3F[31,1] } ) {
                        case 2b00: { ( result ) <- floatadd <- ( workingresult, sourceReg3F ); }
                        case 2b01: {
                            ( sourceReg3Falt ) <- changesign <- ( sourceReg3F );
                            ( result ) <- floatsub <- ( workingresult, sourceReg3Falt );
                        }
                        case 2b10: {
                            ( sourceReg1Falt ) <- changesign <- ( workingresult );
                            ( result ) <- floatsub <- ( sourceReg3F, sourceReg1Falt );
                        }
                        case 2b11: { ( result ) <- floatadd <- ( workingresult, sourceReg3F ); }
                    }
                }
                case 5b10001: {
                    // FMSUB.S
                    frd = 1;
                    ( workingresult ) <- floatmultiply <- ( sourceReg1F, sourceReg2F );
                    switch( { workingresult[31,1], sourceReg3F[31,1] } ) {
                        case 2b00: { ( result ) <- floatsub <- ( workingresult, sourceReg3F ); }
                        case 2b01: {
                            ( sourceReg3Falt ) <- changesign <- ( sourceReg3F );
                            ( result ) <- floatadd <- ( workingresult, sourceReg3Falt );
                        }
                        case 2b10: {
                            ( sourceReg1Falt ) <- changesign <- ( workingresult );
                            ( result ) <- floatsub <- ( sourceReg3F, sourceReg1Falt );
                        }
                        case 2b11: {
                            ( sourceReg1Falt ) <- changesign <- ( workingresult );
                            ( sourceReg3Falt ) <- changesign <- ( sourceReg3F );
                            ( result ) <- floatadd <- ( sourceReg3Falt, sourceReg1Falt );
                        }
                    }
                }
                case 5b10010: {
                    // FNMSUB.S
                    frd = 1;
                    ( sourceReg1Falt ) <- changesign <- ( sourceReg1F );
                    ( workingresult ) <- floatmultiply <- ( sourceReg1Falt, sourceReg2F );
                    switch( { workingresult[31,1], sourceReg3F[31,1] } ) {
                        case 2b00: { ( result ) <- floatsub <- ( workingresult, sourceReg3F ); }
                        case 2b01: {
                            ( sourceReg3Falt ) <- changesign <- ( sourceReg3F );
                            ( result ) <- floatadd <- ( workingresult, sourceReg3Falt );
                        }
                        case 2b10: {
                            ( sourceReg1Falt ) <- changesign <- ( workingresult );
                            ( result ) <- floatsub <- ( sourceReg3F, sourceReg1Falt );
                        }
                        case 2b11: {
                            ( sourceReg1Falt ) <- changesign <- ( workingresult );
                            ( sourceReg3Falt ) <- changesign <- ( sourceReg3F );
                            ( result ) <- floatadd <- ( sourceReg3Falt, sourceReg1Falt );
                        }
                    }
                }
                case 5b10011: {
                    // FNMADD.S
                    frd = 1;
                    ( sourceReg1Falt ) <- changesign <- ( sourceReg1F );
                    ( workingresult ) <- floatmultiply <- ( sourceReg1Falt, sourceReg2F );
                    switch( { workingresult[31,1], sourceReg3F[31,1] } ) {
                        case 2b00: { ( result ) <- floatadd <- ( workingresult, sourceReg3F ); }
                        case 2b01: {
                            ( sourceReg3Falt ) <- changesign <- ( sourceReg3F );
                            ( result ) <- floatsub <- ( workingresult, sourceReg3Falt );
                        }
                        case 2b10: {
                            ( sourceReg1Falt ) <- changesign <- ( workingresult );
                            ( result ) <- floatsub <- ( sourceReg3F, sourceReg1Falt );
                        }
                        case 2b11: { ( result ) <- floatadd <- ( workingresult, sourceReg3F ); }
                    }
                }
                case 5b10100: {
                    // NON 3 REGISTER FPU OPERATIONS
                    switch( function7[2,5] ) {
                        case 5b00000: {
                            // FADD.S
                            frd = 1;
                            switch( { sourceReg1F[31,1], sourceReg2F[31,1] } ) {
                                case 2b00: { ( result ) <- floatadd <- ( sourceReg1F, sourceReg2F ); }
                                case 2b01: {
                                    ( sourceReg2Falt ) <- changesign <- ( sourceReg2F );
                                    ( result ) <- floatsub <- ( sourceReg1F, sourceReg2Falt );
                                }
                                case 2b10: {
                                    ( sourceReg1Falt ) <- changesign <- ( sourceReg1F );
                                    ( result ) <- floatsub <- ( sourceReg2F, sourceReg1Falt );
                                }
                                case 2b11: { ( result ) <- floatadd <- ( sourceReg1F, sourceReg2F ); }
                            }
                        }
                        case 5b00001: {
                            // FSUB.S
                            frd = 1;
                            switch( { sourceReg1F[31,1], sourceReg2F[31,1] } ) {
                                case 2b00: { ( result ) <- floatsub <- ( sourceReg1F, sourceReg2F ); }
                                case 2b01: {
                                    ( sourceReg2Falt ) <- changesign <- ( sourceReg2F );
                                    ( result ) <- floatadd <- ( sourceReg1F, sourceReg2Falt );
                                }
                                case 2b10: {
                                    ( sourceReg1Falt ) <- changesign <- ( sourceReg1F );
                                    ( result ) <- floatsub <- ( sourceReg2F, sourceReg1Falt );
                                }
                                case 2b11: {
                                    ( sourceReg1Falt ) <- changesign <- ( sourceReg1F );
                                    ( sourceReg2Falt ) <- changesign <- ( sourceReg2F );
                                    ( result ) <- floatadd <- ( sourceReg2Falt, sourceReg1Falt );
                                }
                            }
                        }
                        case 5b00010: {
                            // FMUL.S
                            frd = 1;
                            ( result ) <- floatmultiply <- ( sourceReg1F, sourceReg2F );
                        }
                        case 5b00011: {
                            // FDIV.S
                            frd = 1;
                            ( result ) <- floatdivide <- ( sourceReg1F, sourceReg2F );
                        }
                        case 5b010011: {
                            // FSQRT.S
                            frd = 1;
                            result = sourceReg1F;
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
                                case 3b000: { ( result ) <- floatlessequal <- ( sourceReg1F, sourceReg2F ); }
                                case 3b001: { ( result ) <- floatless <- ( sourceReg1F, sourceReg2F ); }
                                case 3b010: {( result ) <- floatequal <- ( sourceReg1F, sourceReg2F ); }
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
                            ( result ) <- inttofloat <- ( sourceReg1 );
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
