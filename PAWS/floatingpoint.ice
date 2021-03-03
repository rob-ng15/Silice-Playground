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
    // ALIGN A 32 BIT BINARY NUMBER TO THE RIGHT FOR DIVISOR IN DIVISION
    subroutine alignright32( input uint32 number, output uint32 alignedright ) {
        alignedright = number;
        ++:
        while( ~alignedright[0,1] ) {
            alignedright = alignedright >> 1;
        }
    }

    // COUNT LEADING 0s 32 BIT AND 64 BIT
    subroutine countleadingzeros32( input uint32 a, output uint8 count ) {
        uint32  bitstream = uninitialised;

        if( a == 0 ) {
            count = 32;
        } else {
            bitstream = a;
            count = 0;
            ++:
            while( ~bitstream[31,1] ) {
                bitstream = bitstream << 1;
                count = count + 1;
            }
        }
    }

    // NORMALISE A 32BT MANTISSA, ADJUST EXPONENT FOR ADD AND SUBTRACT
    subroutine normalise32adjexp( input uint1 sign, input int16 exp, input uint32 number, output uint32 F32, calls countleadingzeros32 ) {
        uint8  zeros = uninitialised;
        int16   expA = uninitialised;
        uint32  a = uninitialised;

        if( number == 0 ) {
            F32 = { sign, 31b0 };
        } else {
            ( zeros ) <- countleadingzeros32 <- ( number );
            if( zeros < 8 ) {
                a = number >> ( 8 - zeros );
                expA = exp + ( 8 - zeros ) + 127;
            } else {
                if( zeros > 8 ) {
                    a = number << ( zeros - 8 );
                    expA = exp - ( zeros - 8 ) + 127;
                }
            }
            F32 = { sign, expA[0,8], a[0,23] };
        }
    }
    // NORMALISE A 32BT MANTISSA FOR DIVIDE
    subroutine normalise32( input uint1 sign, input int16 exp, input uint32 number, output uint32 F32, calls countleadingzeros32 ) {
        uint8  zeros = uninitialised;
        int16   expA = uninitialised;
        uint32  a = uninitialised;

        if( number == 0 ) {
            F32 = { sign, 31b0 };
        } else {
            ( zeros ) <- countleadingzeros32 <- ( number );
            expA = exp + 127;
            ++:
            if( zeros < 8 ) {
                a = number >> ( 8 - zeros );
            } else {
                if( zeros > 8 ) {
                    a = number << ( zeros - 8 );
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
        int16    expA = uninitialised;
        int16    expB = uninitialised;
        uint32  sigA = uninitialised;
        uint32  sigB = uninitialised;
        uint32  total = uninitialised;

        expA = floatingpointnumber( a ).exponent;
        expB = floatingpointnumber( b ).exponent;
        sigA = { 9b1, a[0,23] };
        sigB = { 9b1, b[0,23] };
        sign = a[31,1];
        ++:

        if( ( expA | expB ) == 0 ) {
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
        int16   expA = uninitialised;
        int16   expB = uninitialised;
        uint32  sigA = uninitialised;
        uint32  sigB = uninitialised;
        uint32  total = uninitialised;

        expA = floatingpointnumber( a ).exponent;
        expB = floatingpointnumber( b ).exponent;
        sigA = { 9b1, a[0,23] };
        sigB = { 9b1, b[0,23] };
        sign = a[31,1];
        ++:

        if( ( expA | expB ) == 0 ) {
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
            expA = expA - 127;
            ++:
            if( total[23,8] != 0 ) {
                sign = ~sign;
                total = -total;
            }
            ++:
            ( F32 ) <- normalise32adjexp <- ( sign, expA, total );
        }
    }

    // SIGNED MULTIPLY OF 2 FLOATING POINT NUMBERS
    subroutine floatmultiply( input uint32 a, input uint32 b, output uint32 F32, calls normalise32 ) {
        uint1   productsign = uninitialised;
        uint64  product = uninitialised;
        uint32  product32 = uninitialised;
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
        A = { 10b0, 1b1, a[16,7] };
        B = { 2b0, a[0,16] };
        C = { 10b0, 1b1, b[16,7] };
        D = { 2b0, b[0,16] };
        ++:
        if( ( expA == 0 ) || ( expB == 0 ) ) {
            F32 = { productsign, 31b0 };
        } else {
            productsign = a[31,1] ^ b[31,1];
            product = ( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } );
            productexp = expA + expB - 254;
            ++:
            product32 = product[16,32];
            ( F32 ) <- normalise32 <- ( productsign, productexp, product32 );
        }
    }

    // SIGNED DIVISION OF 2 FLOATING POINT NUMBERS
    subroutine floatdivide( input uint32 a, input uint32 b, output uint32 F32, calls normalise32, calls alignright32 ) {
        uint1   quotientsign = uninitialised;
        int16   quotientexp = uninitialised;
        uint32  quotient = uninitialised;
        uint32  remainder = uninitialised;
        uint6   bit = uninitialised;

        int16   expA = uninitialised;
        int16   expB = uninitialised;
        uint32  sigA = uninitialised;
        uint32  sigB = uninitialised;

        // LEFT ALIGN DIVIDEND AND RIGHT ALIGN DIVISOR
        sigA = { 1b1, a[0,23], 8b0 };
        sigB = { 9b1, b[0,23] };
        quotientsign = a[31,1] ^ b[31,1];
        quotient = 0;
        remainder = 0;
        bit = 31;
        expA = floatingpointnumber( a ).exponent;
        expB = floatingpointnumber( b ).exponent;
        ++:
        ( sigB ) <- alignright32 <- ( sigB );
        if(  expB == 0 ) {
            // DIVIDE BY ZERO
            F32 = { quotientsign, 8b11111111, 23b0 };
        } else {
            if( expA == 0 ) {
                F32 = { quotientsign, 31b0 };
            } else {
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

    // SQUARE ROOT OF A POSITIVE NUMBER BY NEWTON-RAPHSON APPROXIMATION
    subroutine floatsquareroot( input uint32 a, output uint32 F32, calls floatadd, calls floatdivide ) {
        uint32  ONE = uninitialised;
        uint32  TWO = uninitialised;
        uint32  F32next = uninitialised;
        uint32  F32last = uninitialised;
        int16   expA = uninitialised;

        expA = floatingpointnumber( a ).exponent;

        ONE = 32h3f800000;
        TWO = 32h40000000;

        // FIRST APPROXIMATION IS 1
        F32 = 32h3f800000;
        F32last = 32hffffffff;

        if( ( expA == 0 ) || ( a[31,1] ) ) {
            if( a[31,1] ) {
                // NEGATIVE
                F32 = { a[31,1], 8b11111111, 23b0 };
            } else {
                // ZERO
                F32 = 0;
            }
        } else {
            // LOOP UNTIL MANTISSAS ACROSS ITERATIONS ARE APPROXIMATELY EQUAL
            while( F32[1,22] != F32last[1,22] ) {
                ( F32next ) <- floatadd <- ( F32, a );
                ( F32next ) <- floatdivide <- ( F32next, F32 );
                ( F32 ) <- floatdivide <- ( F32next, TWO );
            }
        }
    }

    // PERFORM ADD OR SUBTRACT BY APPROPRIATE SWITCHING OF SIGNS AND CHANGING TO ADD OR SUBTRACT
    subroutine doadd( input uint32 a, input uint32 b, output uint32 F32, calls floatadd, calls floatsub ) {
        uint32  aswapsign = uninitialised;
        uint32  bswapsign = uninitialised;

        switch( { a[31,1], b[31,1] } ) {
            case 2b00: { ( F32 ) <- floatadd <- ( a, b ); }
            case 2b01: {
                bswapsign = { ~b[31,1], b[0,31] };
                ( F32 ) <- floatsub <- ( a, bswapsign );
            }
            case 2b10: {
                aswapsign = { ~a[31,1], a[0,31] };
                ( F32 ) <- floatsub <- ( b, aswapsign );
            }
            case 2b11: { ( F32 ) <- floatadd <- ( a, b ); }
        }
    }
    subroutine dosub( input uint32 a, input uint32 b, output uint32 F32, calls floatadd, calls floatsub ) {
        uint32  aswapsign = uninitialised;
        uint32  bswapsign = uninitialised;

        switch( { a[31,1], b[31,1] } ) {
            case 2b00: { ( F32 ) <- floatsub <- ( a, b ); }
            case 2b01: {
                bswapsign = { ~b[31,1], b[0,31] };
                ( F32 ) <- floatadd <- ( a, bswapsign );
            }
            case 2b10: {
                aswapsign = { ~a[31,1], a[0,31] };
                ( F32 ) <- floatsub <- ( b, aswapsign );
            }
            case 2b11: {
                aswapsign = { ~a[31,1], a[0,31] };
                bswapsign = { ~b[31,1], b[0,31] };
                ( F32 ) <- floatsub <- ( bswapsign, aswapsign );
            }
        }
    }

    // TEMPORARY STORAGE FFOR FUSED MUL / ADD / SUB OPERATIONS AND COMPARISIONS
    uint32  workingresult = uninitialised;
    uint1   comparison = uninitialised;

    while(1) {
        if( start ) {
            busy = 1;

            switch( opCode[2,5] ) {
                case 5b10000: {
                    // FMADD.S
                    frd = 1;
                    ( workingresult ) <- floatmultiply <- ( sourceReg1F, sourceReg2F );
                    ( result ) <- doadd <- ( workingresult, sourceReg3F );
                }
                case 5b10001: {
                    // FMSUB.S
                    frd = 1;
                    ( workingresult ) <- floatmultiply <- ( sourceReg1F, sourceReg2F );
                    ( result ) <- dosub <- ( workingresult, sourceReg3F );
                }
                case 5b10010: {
                    // FNMSUB.S
                    frd = 1;
                    workingresult = { ~sourceReg1F[31,1], sourceReg1F[0,31] };
                    ( workingresult ) <- floatmultiply <- ( workingresult, sourceReg2F );
                    ( result ) <- dosub <- ( workingresult, sourceReg3F );
                }
                case 5b10011: {
                    // FNMADD.S
                    frd = 1;
                    workingresult = { ~sourceReg1F[31,1], sourceReg1F[0,31] };
                    ( workingresult ) <- floatmultiply <- ( workingresult, sourceReg2F );
                    ( result ) <- doadd <- ( workingresult, sourceReg3F );
                }
                case 5b10100: {
                    // NON 3 REGISTER FPU OPERATIONS
                    switch( function7[2,5] ) {
                        case 5b00000: {
                            // FADD.S
                            frd = 1;
                            ( result ) <- doadd <- ( sourceReg1F, sourceReg2F );
                        }
                        case 5b00001: {
                            // FSUB.S
                            frd = 1;
                            ( result ) <- dosub <- ( sourceReg1F, sourceReg2F );
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
                            ( result ) <- floatsquareroot <- ( sourceReg1F );
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
                            comparison = ( sourceReg1F[31,1] != sourceReg2F[31,1] ) ? sourceReg1F[31,1] && ((( sourceReg1F | sourceReg2F ) << 1) != 0 ) : ( sourceReg1F != sourceReg2F ) && ( sourceReg1F[31,1] ^ ( sourceReg1F < sourceReg2F));
                            switch( function3[0,1] ) {
                                case 0: { result = comparison ? sourceReg1F : sourceReg2F; }
                                case 1: { result = comparison ? sourceReg2F : sourceReg1F; }
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
                                case 3b000: {
                                    // LESS THAN EQUAL OMPARISON OF 2 FLOATING POINT NUMBERS
                                    comparison = ( sourceReg1F[31,1] != sourceReg2F[31,1] ) ? sourceReg1F[31,1] || ((( sourceReg1F | sourceReg2F ) << 1) == 0 ) : ( sourceReg1F == sourceReg2F ) || ( sourceReg1F[31,1] ^ ( sourceReg1F < sourceReg2F ));
                                }
                                case 3b001: {
                                    // LESS THAN COMPARISON OF 2 FLOATING POINT NUMBERS
                                    comparison = ( sourceReg1F[31,1] != sourceReg2F[31,1] ) ? sourceReg1F[31,1] && ((( sourceReg1F | sourceReg2F ) << 1) != 0 ) : ( sourceReg1F != sourceReg2F ) && ( sourceReg1F[31,1] ^ ( sourceReg1F < sourceReg2F));
                                }
                                case 3b010: {
                                    // EQUAL COMPARISON OF 2 FLOATING POINT NUMBERS
                                    comparison = ( sourceReg1F == sourceReg2F ) || ((( sourceReg1F | sourceReg2F ) << 1) == 0 );
                                }
                            }
                            result = { 31b0, comparison };
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
