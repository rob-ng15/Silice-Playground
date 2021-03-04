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
        int16   expA = uninitialised;
        int16   expB = uninitialised;
        uint32  sigA = uninitialised;
        uint32  sigB = uninitialised;
        uint32  difference = uninitialised;

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
            difference = sigA - sigB;
            expA = expA - 127;
            ++:
            if( difference[31,1] ) {
                sign = ~sign;
                difference = -difference;
            }
            ++:
            ( F32 ) <- normalise32adjexp <- ( sign, expA, difference );
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

    inttofloat FPUfloat( a <: sourceReg1, rs2 <: rs2 );
    floatmultiply FPUmultiply();
    floatdivide FPUdivide();

    // TEMPORARY STORAGE FFOR FUSED MUL / ADD / SUB OPERATIONS AND COMPARISIONS
    uint32  workingresult = uninitialised;
    uint1   comparison = uninitialised;

    FPUfloat.start := 0;
    FPUmultiply.start := 0;
    FPUdivide.start := 0;

    while(1) {
        if( start ) {
            busy = 1;

            switch( opCode[2,5] ) {
                case 5b10000: {
                    // FMADD.S
                    frd = 1;
                    FPUmultiply.a = sourceReg1F;
                    FPUmultiply.b = sourceReg2F;
                    FPUmultiply.start = 1;
                    while( FPUmultiply.busy ) {}
                    workingresult = FPUmultiply.result;
                    ( result ) <- doadd <- ( workingresult, sourceReg3F );
                }
                case 5b10001: {
                    // FMSUB.S
                    frd = 1;
                    FPUmultiply.a = sourceReg1F;
                    FPUmultiply.b = sourceReg2F;
                    FPUmultiply.start = 1;
                    while( FPUmultiply.busy ) {}
                    workingresult = FPUmultiply.result;
                    ( result ) <- dosub <- ( workingresult, sourceReg3F );
                }
                case 5b10010: {
                    // FNMSUB.S
                    frd = 1;
                    FPUmultiply.a = { ~sourceReg1F[31,1], sourceReg1F[0,31] };
                    FPUmultiply.b = sourceReg2F;
                    FPUmultiply.start = 1;
                    while( FPUmultiply.busy ) {}
                    workingresult = FPUmultiply.result;
                    ( result ) <- dosub <- ( workingresult, sourceReg3F );
                }
                case 5b10011: {
                    // FNMADD.S
                    frd = 1;
                    FPUmultiply.a = { ~sourceReg1F[31,1], sourceReg1F[0,31] };
                    FPUmultiply.b = sourceReg2F;
                    FPUmultiply.start = 1;
                    while( FPUmultiply.busy ) {}
                    workingresult = FPUmultiply.result;
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
                            FPUmultiply.a = sourceReg1F;
                            FPUmultiply.b = sourceReg2F;
                            FPUmultiply.start = 1;
                            while( FPUmultiply.busy ) {}
                            result = FPUmultiply.result;
                        }
                        case 5b00011: {
                            // FDIV.S
                            frd = 1;
                            FPUdivide.a = sourceReg1F;
                            FPUdivide.b = sourceReg2F;
                            FPUdivide.start = 1;
                            while( FPUdivide.busy ) {}
                            result = FPUdivide.result;
                        }
                        case 5b010011: {
                            // FSQRT.S
                            frd = 1;
                            if( ( floatingpointnumber( sourceReg1F ).exponent == 0 ) || ( sourceReg1F[31,1] ) ) {
                                if( sourceReg1F[31,1] ) {
                                    // NEGATIVE
                                    result = { sourceReg1F[31,1], 8b11111111, 23b0 };
                                } else {
                                    // ZERO
                                    result = 0;
                                }
                            } else {
                            // FIRST APPROXIMATIONS IS 1
                                result = 32h3f800000;
                                workingresult = sourceReg1F;
                                ++:
                                // LOOP UNTIL MANTISSAS ACROSS ITERATIONS ARE APPROXIMATELY EQUAL
                                while( result[1,22] != workingresult[1,22] ) {
                                    // x(i+1 ) = ( x(i) + n / x(i) ) / 2;
                                    // DO n/x(i)
                                    FPUdivide.a = sourceReg1F;
                                    FPUdivide.b = result;
                                    FPUdivide.start = 1;
                                    while( FPUdivide.busy ) {}
                                    workingresult = FPUdivide.result;

                                    // DO x(i) + n/x(i)
                                    ( workingresult ) <- doadd <- ( result, workingresult );

                                    // DO (x(i) + n/x(i))/2
                                    FPUdivide.a = workingresult;
                                    FPUdivide.b = 32h40000000;
                                    FPUdivide.start = 1;
                                    while( FPUdivide.busy ) {}
                                    result = FPUdivide.result;
                                }
                            }
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
                            FPUfloat.start = 1;
                            while( FPUfloat.busy ) {}
                            result = FPUfloat.result;
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

// ALIGN TO THE RIGHT ( remove trailing 0s )
circuitry alignright( input number, output alignedright ) {
    alignedright = number;
    ++:
    while( ~alignedright[0,1] ) {
        alignedright = alignedright >> 1;
    }
}

// COUNT LEADING 0s
circuitry countleadingzeros( input a, output count ) {
    uint32  bitstream = uninitialised;
    bitstream = a;
    ++:
    if( bitstream == 0 ) {
        count = 32;
    } else {
        count = 0;
        ++:
        while( ~bitstream[31,1] ) {
            bitstream = bitstream << 1;
            count = count + 1;
        }
    }
}

// NORMALISE A 32BT MANTISSA
circuitry normalise( input sign, input exp, input number, output F32 ) {
    uint8  zeros = uninitialised;
    int16  expA = uninitialised;
    uint32  bitstream = uninitialised;

    if( number == 0 ) {
        F32 = { sign, 31b0 };
    } else {
       ( zeros ) = countleadingzeros( number );
        expA = exp + 127;
        ++:
        if( zeros < 8 ) {
            bitstream = number >> ( 8 - zeros );
        } else {
            if( zeros > 8 ) {
                bitstream = number << ( zeros - 8 );
            }
        }
        F32 = { sign, expA[0,8], bitstream[0,23] };
    }
}

// CONVERT SIGNED/UNSIGNED INTEGERS TO FLOAT
algorithm inttofloat(
    input   uint1   start,
    output! uint1   busy,

    input   uint32  a,
    input   uint5   rs2,

    output! uint32  result
) <autorun> {
    uint1   sign = uninitialised;
    uint8   exp = uninitialised;
    uint8   zeros = uninitialised;
    uint32  number = uninitialised;

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;

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
                result = { sign, 31b0 };
            } else {
                ( zeros ) = countleadingzeros( number );
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
                result = { sign, exp[0,8], number[0,23] };
            }

            busy = 0;
        }
    }
}

algorithm floatmultiply(
    input   uint1   start,
    output! uint1   busy,

    input   uint32  a,
    input   uint32  b,

    output! uint32  result
) <autorun> {
    uint1   productsign := a[31,1] ^ b[31,1];
    uint64  product := ( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } );
    uint32  product32 := product[16,32];
    int16   productexp := expA + expB - 254;

    int16   expA := floatingpointnumber( a ).exponent;
    int16   expB := floatingpointnumber( b ).exponent;

    // Calculation is split into 4 18 x 18 multiplications for DSP
    uint18  A := { 10b0, 1b1, a[16,7] };
    uint18  B := { 2b0, a[0,16] };
    uint18  C := { 10b0, 1b1, b[16,7] };
    uint18  D := { 2b0, b[0,16] };

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;

            if( ( expA == 0 ) || ( expB == 0 ) ) {
                result = { productsign, 31b0 };
            } else {
                 ++:
                ( result ) = normalise( productsign, productexp, product32 );
            }

            busy = 0;
        }
    }
}

algorithm floatdivide(
    input   uint1   start,
    output! uint1   busy,

    input   uint32  a,
    input   uint32  b,

    output! uint32  result
) <autorun> {
    uint1   quotientsign := a[31,1] ^ b[31,1];
    int16   quotientexp := expA - expB;
    uint32  quotient = uninitialised;
    uint32  remainder = uninitialised;
    uint6   bit = uninitialised;

    int16   expA := floatingpointnumber( a ).exponent;
    int16   expB := floatingpointnumber( b ).exponent;
    uint32  sigA = uninitialised;
    uint32  sigB = uninitialised;

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;

            sigA = { 1b1, a[0,23], 8b0 };
            sigB = { 9b1, b[0,23] };
            quotient = 0;
            remainder = 0;
            bit = 31;
            ++:
            ( sigB ) = alignright( sigB );
            if(  expB == 0 ) {
                // DIVIDE BY ZERO
                result = { quotientsign, 8b11111111, 23b0 };
            } else {
                if( expA == 0 ) {
                    result = { quotientsign, 31b0 };
                } else {
                    while( bit != 63 ) {
                        if( __unsigned({ remainder[0,31], sigA[bit,1] }) >= __unsigned(sigB) ) {
                                remainder = __unsigned({ remainder[0,31], sigA[bit,1] }) - __unsigned(sigB);
                                quotient[bit,1] = 1;
                        } else {
                            remainder = { remainder[0,31], sigA[bit,1] };
                        }
                        bit = bit - 1;
                    }
                   ( result ) = normalise( quotientsign, quotientexp, quotient );
                }
            }

            busy = 0;
        }
    }
}
