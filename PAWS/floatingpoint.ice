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

    inttofloat FPUfloat( a <: sourceReg1, rs2 <: rs2 );
    floataddsub FPUaddsub();
    floatmultiply FPUmultiply();
    floatdivide FPUdivide();

    // TEMPORARY STORAGE FFOR FUSED MUL / ADD / SUB OPERATIONS AND COMPARISIONS
    uint32  workingresult = uninitialised;
    uint1   comparison = uninitialised;

    FPUfloat.start := 0;
    FPUaddsub.start := 0;
    FPUmultiply.start := 0;
    FPUdivide.start := 0;

    while(1) {
        if( start ) {
            busy = 1;

            switch( opCode[2,5] ) {
                case 5b10100: {
                    // NON 3 REGISTER FPU OPERATIONS
                    switch( function7[2,5] ) {
                        case 5b00000: {
                            // FADD.S
                            frd = 1;
                            FPUaddsub.addsub = 0;
                            FPUaddsub.a = sourceReg1F;
                            FPUaddsub.b = sourceReg2F;
                            FPUaddsub.start = 1;
                            while( FPUaddsub.busy ) {}
                            result = FPUaddsub.result;
                        }
                        case 5b00001: {
                            // FSUB.S
                            frd = 1;
                            FPUaddsub.addsub = 1;
                            FPUaddsub.a = sourceReg1F;
                            FPUaddsub.b = sourceReg2F;
                            FPUaddsub.start = 1;
                            while( FPUaddsub.busy ) {}
                            result = FPUaddsub.result;
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
                                while( result[1,31] != workingresult[1,31] ) {
                                    // x(i+1 ) = ( x(i) + n / x(i) ) / 2;
                                    // DO n/x(i)
                                    FPUdivide.a = sourceReg1F;
                                    FPUdivide.b = result;
                                    FPUdivide.start = 1;
                                    while( FPUdivide.busy ) {}
                                    workingresult = FPUdivide.result;

                                    // DO x(i) + n/x(i)
                                    FPUaddsub.addsub = 0;
                                    FPUaddsub.a = result;
                                    FPUaddsub.b = workingresult;
                                    FPUaddsub.start = 1;
                                    while( FPUaddsub.busy ) {}
                                    result = FPUaddsub.result;

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
                        default: {
                            // FMADD.S FMSUB.S FNMSUB.S FNMADD.S
                            frd = 1;
                            FPUmultiply.a = function7[3,1] ? { ~sourceReg1F[31,1], sourceReg1F[0,31] } : sourceReg1F;
                            FPUmultiply.b = sourceReg2F;
                            FPUmultiply.start = 1;
                            while( FPUmultiply.busy ) {}
                            workingresult = FPUmultiply.result;

                            FPUaddsub.addsub = ( function7[2,1] == function7[3,1] ) ? 0 : 1;
                            FPUaddsub.a = workingresult;
                            FPUaddsub.b = sourceReg3F;
                            FPUaddsub.start = 1;
                            while( FPUaddsub.busy ) {}
                            result = FPUaddsub.result;
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
    while( ~alignedright[0,1] && ( alignedright != 0 ) ) {
        alignedright = alignedright >> 1;
    }
}

// COUNT LEADING 0s
circuitry countleadingzeros( input a, output count ) {
    uint32  bitstream = uninitialised;
    bitstream = a;
    count = 0;
    ++:
    if( bitstream == 0 ) {
        count = 32;
    } else {
        while( ~bitstream[31,1] ) {
            bitstream = bitstream << 1;
            count = count + 1;
        }
    }
}

// NORMALISE A 32BT MANTISSA with or without adjusting exponent
circuitry normalise( input sign, input exp, input number, output F32 ) {
    uint8  zeros = uninitialised;
    int16  expA = uninitialised;
    uint32  bitstream = uninitialised;

    if( number == 0 ) {
        F32 = { sign, 31b0 };
    } else {
        ( zeros ) = countleadingzeros( number );
        bitstream = ( zeros < 8 ) ? number >> ( 8 - zeros ) : ( zeros > 8 ) ? number << ( zeros - 8 ) : number;
        expA = exp + 127;
        F32 = { sign, expA[0,8], bitstream[0,23] };
    }
}
circuitry normaliseexp( input sign, input exp, input number, output F32 ) {
    uint8  zeros = uninitialised;
    int16  expA = uninitialised;
    uint32  bitstream = uninitialised;

    if( number == 0 ) {
        F32 = { sign, 31b0 };
    } else {
        ( zeros ) = countleadingzeros( number );
        bitstream = ( zeros < 8 ) ? number >> ( 8 - zeros ) : ( zeros > 8 ) ? number << ( zeros - 8 ) : number;
        expA = ( zeros == 8 ) ? exp + 127 : exp + 135 - zeros;
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

            // SIGNED / UNSIGNED
            sign = rs2[0,1] ? 0 : a[31,1];
            number = rs2[0,1] ? a : ( a[31,1] ? -a : a );
            ++:
            if( number == 0 ) {
                result = { sign, 31b0 };
            } else {
                ( zeros ) = countleadingzeros( number );
                number = ( zeros < 8 ) ? number >> ( 8 - zeros ) : ( zeros > 8 ) ? number << ( zeros - 8 ) : number;
                exp = 158 - zeros;
                result = { sign, exp[0,8], number[0,23] };
            }

            busy = 0;
        }
    }
}

algorithm floataddsub(
    input   uint1   start,
    output! uint1   busy,

    input   uint32  a,
    input   uint32  b,
    input   uint1   addsub,

    output! uint32  result
) <autorun> {
    uint1   sign = uninitialised;
    int16   expA = uninitialised;
    int16   expB = uninitialised;
    uint32  sigA = uninitialised;
    uint32  sigB = uninitialised;
    uint32  totaldifference = uninitialised;
    uint6   bitcount = uninitialised;

    // == 0 ADD == 1 SUB
    uint1   operation = uninitialised;
    uint32  value1 = uninitialised;
    uint32  value2 = uninitialised;
    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;

            operation = ( a[31,1] == b[31,1] ) ? addsub : ~addsub;
            bitcount = 31;

            switch( addsub ) {
                case 0: {
                    switch( { a[31,1], b[31,1] } ) {
                        case 2b01: {
                            value1 = a;
                            value2 = { ~b[31,1], b[0,31] };
                        }
                        case 2b10: {
                            value1 = b;
                            value2 = { ~a[31,1], a[0,31] };
                         }
                        default: {
                            value1 = a;
                            value2 = b;
                        }
                    }
                }
                case 1: {
                    switch( { a[31,1], b[31,1] } ) {
                        case 2b00: {
                            value1 = a;
                            value2 = b;
                        }
                        case 2b11: {
                            value1 = { ~b[31,1], b[0,31] };
                            value2 = { ~a[31,1], a[0,31] };
                        }
                        default: {
                            value1 = a;
                            value2 = ( { a[31,1], b[31,1] } == 2b10 ) ? b : { ~b[31,1], b[0,31] };
                        }
                    }
                }
            }

            expA = floatingpointnumber( value1 ).exponent;
            expB = floatingpointnumber( value2 ).exponent;
            sigA = { 9b1, value1[0,23] };
            sigB = { 9b1, value2[0,23] };
            sign = value1[31,1];
            ++:
            if( ( expA | expB ) == 0 ) {
                result = ( expB == 0 ) ? value1 : ( operation == 0 ) ? value2 : { ~value2[31,1], value2[0,31] };
            } else {
                // ADJUST TO EQUAL EXPONENTS
                if( expA < expB ) {
                    sigA = sigA >> ( expB - expA );
                    expA = expB;
                    ++:
                } else {
                    if( expB < expA ) {
                        sigB = sigB >> ( expA - expB );
                        expB = expA;
                        ++:
                    }
                }
                expA = expA - 127;
                switch( operation ) {
                    case 0: { totaldifference = sigA + sigB; }
                    case 1: {
                        totaldifference = sigA - sigB;
                        if( totaldifference[31,1] ) {
                            // DEAL WITH SIGN SWAP AND ADD BACK IN THE MSB IN CORRECT LOCATION
                            sign = ~sign;
                            while( totaldifference[bitcount,1 ] && ( bitcount != 63 ) ) {
                                bitcount = bitcount - 1;
                            }
                            if( bitcount != 63 ) {
                                totaldifference = ( -totaldifference ) | ( 1 << ( bitcount +1 ) );
                            } else {
                                totaldifference = 0;
                            }
                        }
                    }
                }
                if( totaldifference == 0 ) {
                    result = { sign, 31b0 };
                } else {
                    ( result ) = normaliseexp( sign, expA, totaldifference );
                }
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

            ++:
            if( ( expA | expB ) == 0 ) {
                result = { productsign, 31b0 };
            } else {
                if( product32 == 0 ) {
                    result = { productsign, 31b0 };
                } else {
                    ( result ) = normalise( productsign, productexp, product32 );
                }
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
    int16   quotientexp = uninitialised;
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

            quotientexp = expA - expB;
            sigA = { 1b1, a[0,23], 8b0 };
            sigB = { 9b1, b[0,23] };
            quotient = 0;
            remainder = 0;
            bit = 31;
            ++:
            ( sigB ) = alignright( sigB );
            if( ( expA | expB ) == 0 ) {
                // DIVIDE BY ZERO
                result = ( expA == 0 ) ? { quotientsign, 31b0 } : { quotientsign, 8b11111111, 23b0 };
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
                if( quotient == 0 ) {
                    result = { quotientsign, 31b0 };
                } else {
                    while( quotient[30,2] == 0 ) {
                        quotient = quotient << 1;
                        quotientexp = quotientexp - 1;
                    }
                    ( result ) = normalise( quotientsign, quotientexp, quotient );
                }
            }

            busy = 0;
        }
    }
}
