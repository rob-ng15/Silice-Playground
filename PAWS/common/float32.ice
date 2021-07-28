// Rob Shelton ( @robng15 Twitter, @rob-ng15 GitHub )
// Simple 32bit FPU calculation/conversion routines
// Designed for as small as FPGA usage as possible,
// not for speed.
//
// Donated to Silice by @sylefeb
//
// Parameters for calculations: ( 32 bit float { sign, exponent, mantissa } format )
// addsub, multiply and divide a and b ( as floating point numbers ), addsub flag == 0 for add, == 1 for sub
//
// Parameters for conversion:
// intotofloat a as 32 bit integer, dounsigned == 1 dounsigned, == 0 signed conversion
// floattouint and floattoint a as 32 bit float
//
// Control:
// start == 1 to start operation
// busy gives status, == 0 not running or complete, == 1 running
//
// Output:
// result gives result of conversion or calculation
//
// NB: Error states are those required by Risc-V floating point

// BITFIELD FOR FLOATING POINT NUMBER - IEEE-754 32 bit format
bitfield floatingpointnumber{
    uint1   sign,
    uint8   exponent,
    uint23  fraction
}

bitfield floatingpointflags{
    uint1   IF,     // infinity as an argument
    uint1   NN,     // NaN as an argument
    uint1   NV,     // Result is not valid,
    uint1   DZ,     // Divide by zero
    uint1   OF,     // Result overflowed
    uint1   UF,     // Result underflowed
    uint1   NX      // Not exact ( integer to float conversion caused bits to be dropped )
}

// COMBINE COMPONENTS INTO FLOATING POINT NUMBER
// NOTE exp from addsub multiply divide is 16 bit biased ( ie, exp + 127 )
// small numbers return 0, bit numbers return max
circuitry combinecomponents( input sign, input exp, input fraction, output f32, output OF, output UF ) {
    switch( ( exp > 254 ) | ( exp < 0 ) ) {
        case 1: { f32 = ( exp < 0 ) ? 0 : { sign, 8b11111111, 23h0 }; OF = ( exp > 254 ); UF = ( exp < 0 ); }
        case 0: { f32 = { sign, exp[0,8], fraction[0,23] }; OF = 0; UF = 0; }
    }
}

// IDENTIFY infinity, signalling NAN, quiet NAN, ZERO
algorithm classify(
    input   uint32  a,
    output  uint1   INF,
    output  uint1   sNAN,
    output  uint1   qNAN,
    output  uint1   ZERO
) <autorun> {
    uint1   expFF <: ( floatingpointnumber(a).exponent == 8hff );
    INF := expFF & ~a[22,1];
    sNAN := expFF & a[22,1] & a[21,1];
    qNAN := expFF & a[22,1] & ~a[21,1];
    ZERO := ( floatingpointnumber(a).exponent == 0 );
}

// CIRCUITS TO DEAL WITH 48 BIT FRACTIONS TO 23 BIT FRACTIONS
// REALIGN A 48BIT NUMBER SO MSB IS 1
circuitry normalise48( inout bitstream ) {
    while( ~bitstream[47,1] ) {
        bitstream = bitstream << 1;
    }
}
// EXTRACT 23 BIT FRACTION FROM LEFT ALIGNED 48 BIT FRACTION WITH ROUNDING
circuitry round48( input bitstream, output roundfraction ) {
    roundfraction = bitstream[24,23] + bitstream[23,1];
}

// ADJUST EXPONENT IF ROUNDING FORCES, using newfraction and truncated bit from oldfraction
circuitry adjustexp48( inout exponent, input nf, input of ) {
    exponent = 127 + exponent + ( ( nf == 0 ) & of[23,1] );
}

// CONVERT SIGNED/UNSIGNED INTEGERS TO FLOAT
// dounsigned == 1 for signed conversion (31 bit plus sign), == 0 for dounsigned conversion (32 bit)
algorithm inttofloat(
    input   uint1   start,
    output  uint1   busy,

    input   uint32  a,
    input   uint1   dounsigned,

    output  uint7   flags,
    output  uint32  result
) <autorun> {
    uint2   FSM = uninitialised;
    uint2   FSM2 = uninitialised;
    uint1   sign = uninitialised;
    int16   exp = uninitialised;
    uint8   zeros = uninitialised;
    uint32  number = uninitialised;

    uint1 OF = uninitialised; uint1 UF = uninitialised; uint1 NX = uninitialised;
    flags := { 4b0, OF, UF, NX };

    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                FSM = 1;
                OF = 0; UF = 0; NX = 0;
                while( FSM != 0 ) {
                    onehot( FSM ) {
                        case 0: {
                            // SIGNED / UNSIGNED
                            sign = dounsigned ? 0 : floatingpointnumber( a ).sign;
                            number = dounsigned ? a : ( floatingpointnumber( a ).sign ? -a : a );
                        }
                        case 1: {
                            switch( number == 0 ) {
                                case 1: { result = 0; }
                                case 0: {
                                    FSM2 = 1;
                                    while( FSM2 !=0 ) {
                                        onehot( FSM2 ) {
                                            case 0: { zeros = 0; while( ~number[31-zeros,1] ) { zeros = zeros + 1; } }
                                            case 1: {
                                                number = ( zeros < 8 ) ? number >> ( 8 - zeros ) : ( zeros > 8 ) ? number << ( zeros - 8 ) : number;
                                                exp = 158 - zeros;
                                                ( result, OF, UF ) = combinecomponents( sign, exp, number );
                                                NX = ( zeros < 8 );
                                            }
                                        }
                                        FSM2 = FSM2 << 1;
                                    }
                                }
                            }
                        }
                    }
                    FSM = FSM << 1;
                }
                busy = 0;
            }
        }
    }
}

// CONVERT FLOAT TO UNSIGNED/SIGNED INTEGERS
algorithm floattouint(
    input   uint32  a,
    output  uint7   flags,
    output  uint32  result,
    output  uint1   busy,
    input   uint1   start
) <autorun> {
    int16    exp = uninitialised;
    uint33   sig = uninitialised;

    uint1 IF = uninitialised; uint1 NN = uninitialised; uint1 NV = uninitialised;
    classify A( a <: a );
    flags := { IF, NN, NV, 4b0000 };

    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                IF = A.INF; NN = A.sNAN | A.qNAN; NV = 0;
                switch( { IF | NN, A.ZERO } ) {
                    case 2b00: {
                        switch( floatingpointnumber( a ).sign ) {
                            case 1: { result = 0; }
                            default: {
                                exp = floatingpointnumber( a ).exponent - 127;
                                sig = ( exp < 24 ) ? { 9b1, floatingpointnumber( a ).fraction, 1b0 } >> ( 23 - exp ) : { 9b1, floatingpointnumber( a ).fraction, 1b0 } << ( exp - 24);
                                result = ( exp > 31 ) ? 32hffffffff : ( sig[1,32] + sig[0,1] );
                                NV = ( exp > 31 );
                            }
                        }
                    }
                    case 2b01: { result = 0; }
                    default: { NV = 1; result = NN ? 32hffffffff : floatingpointnumber( a ).sign ? 0 : 32hffffffff;  }
                }
                busy = 0;
            }
        }
    }
}
algorithm floattoint(
    input   uint32  a,
    output  uint7   flags,
    output  uint32  result,
    output  uint1   busy,
    input   uint1   start
) <autorun> {
    int16   exp = uninitialised;
    uint33  sig = uninitialised;

    uint1 IF = uninitialised; uint1 NN = uninitialised; uint1 NV = uninitialised;
    classify A( a <: a );
    flags := { IF, NN, NV, 4b0000 };

    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                IF = A.INF; NN = A.sNAN | A.qNAN; NV = 0;
                switch( { IF | NN, A.ZERO } ) {
                    case 2b00: {
                        exp = floatingpointnumber( a ).exponent - 127;
                        sig = ( exp < 24 ) ? { 9b1, floatingpointnumber( a ).fraction, 1b0 } >> ( 23 - exp ) : { 9b1, floatingpointnumber( a ).fraction, 1b0 } << ( exp - 24);
                        result = ( exp > 30 ) ? ( floatingpointnumber( a ).sign ? 32hffffffff : 32h7fffffff ) : floatingpointnumber( a ).sign ? -( sig[1,32] + sig[0,1] ) : ( sig[1,32] + sig[0,1] );
                        NV = ( exp > 30 );
                    }
                    case 2b01: { result = 0; }
                    default: { NV = 1; result = NN ? 32hffffffff : floatingpointnumber( a ).sign ? 32hffffffff : 32h7fffffff; }
                }
                busy = 0;
            }
        }
    }
}

// ADDSUB
// ADD/SUBTRACT ( addsub == 0 add, == 1 subtract) TWO FLOATING POINT NUMBERS
algorithm floataddsub(
    input   uint1   start,
    output  uint1   busy,

    input   uint32  a,
    input   uint32  b,
    input   uint1   addsub,

    output  uint7   flags,
    output  uint32  result
) <autorun> {
    uint6   FSM = uninitialised;
    uint1   sign = uninitialised;
    uint1   signA = uninitialised;
    uint1   signB = uninitialised;
    int16   expA = uninitialised;
    int16   expB = uninitialised;
    uint48  sigA = uninitialised;
    uint48  sigB = uninitialised;
    uint23  newfraction = uninitialised;

    uint1 IF = uninitialised; uint1 NN = uninitialised; uint1 OF = uninitialised; uint1 UF = uninitialised;
    classify A( a <: a ); classify B( a <: b );
    flags := { IF, NN, 1b0, 1b0, OF, UF, 1b0 };

    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                FSM = 1;
                while( FSM != 0 ) {
                    onehot( FSM ) {
                        case 0: {
                            IF = ( A.INF | B.INF ); NN = ( A.sNAN | A.qNAN | B.sNAN | B.qNAN ); OF = 0; UF = 0;
                            __display("");
                            __display("ADD (==0) SUB (==1) %b", addsub);
                            __display("IF = %b NN = %b",IF,NN);
                            __display("");
                        }
                        case 1: {
                            // FOR SUBTRACTION CHANGE SIGN OF SECOND VALUE
                            signA = floatingpointnumber( a ).sign; signB = addsub ? ~floatingpointnumber( b ).sign : floatingpointnumber( b ).sign;
                            __display("a = { %b %b %b } + ",signA,floatingpointnumber( a ).exponent,floatingpointnumber( a ).fraction);
                            __display("b = { %b %b %b }",signB,floatingpointnumber( b ).exponent,floatingpointnumber( b ).fraction);
                            __display("");
                        }
                        case 2: {
                            // EXTRACT COMPONENTS - HOLD TO LEFT TO IMPROVE FRACTIONAL ACCURACY
                            switch( IF | NN ) {
                                case 0: {
                                    expA = floatingpointnumber( a ).exponent - 127;
                                    expB = floatingpointnumber( b ).exponent - 127;
                                    sigA = { 2b01, floatingpointnumber(a).fraction, 23b0 };
                                    sigB = { 2b01, floatingpointnumber(b).fraction, 23b0 };
                                    __display("    { %b %b %b } + ",signA,expA,sigA);
                                    __display("    { %b %b %b }",signB,expB,sigB);
                                    __display("");
                                }
                                case 1: {}
                            }
                        }
                        case 3: {
                            // ADJUST TO EQUAL EXPONENTS
                            switch( IF | NN ) {
                                case 0: {
                                    __display("Equalising Exponents");
                                    switch( { expA < expB, expB < expA } ) {
                                        case 2b10: { sigA = sigA >> ( expB - expA ); expA = expB; }
                                        case 2b01: { sigB = sigB >> ( expA - expB ); expB = expA; }
                                        default: {}
                                    }
                                    __display("    { %b %b %b } + ",signA,expA,sigA);
                                    __display("    { %b %b %b }",signB,expB,sigB);
                                    __display("");
                                }
                                case 1: {}
                            }
                        }
                        case 4: {
                            switch( { IF | NN, A.ZERO | B.ZERO } ) {
                                case 2b00: {
                                    switch( { signA, signB } ) {
                                        // PERFORM + HANDLING SIGNS
                                        case 2b01: {
                                            switch( sigB > sigA ) {
                                                case 1: { sign = 1; sigA = sigB - sigA; }
                                                case 0: { sign = 0; sigA = sigA - sigB; }
                                            }
                                        }
                                        case 2b10: {
                                            switch(  sigA > sigB ) {
                                                case 1: { sign = 1; sigA = sigA - sigB; }
                                                case 0: { sign = 0; sigA = sigB - sigA; }
                                            }
                                        }
                                        default: { sign = signA; sigA = sigA + sigB; }
                                    }
                                }
                                case 2b01: { result = ( B.ZERO ) ? a : addsub ? { ~floatingpointnumber( b ).sign, b[0,31] } : b; }
                                default: {
                                    __display("INF or NaN detected");
                                    switch( { IF, NN } ) {
                                        case 2b10: { result = ( A.INF & B.INF) ? ( signA == signB ) ? { signA, 8b11111111, 23b0 } : 32h7fc00000 : A.INF ? a : { signB, 8b11111111, 23b0 }; }
                                        default: { result = 32h7fc00000; }
                                    }
                                }
                            }
                        }
                        case 5: {
                            switch( { IF | NN, A.ZERO | B.ZERO } ) {
                                case 2b00: {
                                    switch( sigA ) {
                                        case 0: { result = 0; }
                                        default: {
                                            // NORMALISE AND ROUND
                                            switch( sigA[47,1] ) {
                                                case 1: { expA = expA + 1; }
                                                default: {
                                                    while( ~sigA[46,1] ) { sigA = sigA << 1; expA = expA - 1; }
                                                    sigA = sigA << 1;
                                                }
                                            }
                                            ( newfraction ) = round48( sigA );
                                            ( expA ) = adjustexp48( exp, newfraction, sigA );
                                            ( result, OF, UF ) = combinecomponents( sign, expA, newfraction );
                                        }
                                    }
                                }
                                default: {}
                            }
                        }
                    }
                    FSM = FSM << 1;
                }
                __display("R = { %b %b %b }",floatingpointnumber( result ).sign,floatingpointnumber( result ).exponent,floatingpointnumber( result ).fraction);
                __display("FLAGS = { %b }",flags);
                __display("");
                busy = 0;
            }
        }
    }
}

// UNSIGNED / SIGNED 32 by 32 bit multiplication giving 64 bit product using DSP blocks
$$if not uintmul_algo then
$$uintmul_algo = 1
algorithm douintmul(
    input   uint32  factor_1,
    input   uint32  factor_2,
    output  uint64  product
) <autorun> {
    product := factor_1 * factor_2;
}
$$end
algorithm floatmultiply(
    input   uint1   start,
    output  uint1   busy,

    input   uint32  a,
    input   uint32  b,

    output  uint7   flags,
    output  uint32  result
) <autorun> {
    uint3   FSM = uninitialised;

    uint1   productsign <: floatingpointnumber( a ).sign ^ floatingpointnumber( b ).sign;
    uint48  product = uninitialised;
    int16   productexp  = uninitialised;
    uint23  newfraction = uninitialised;

    uint1 IF = uninitialised; uint1 NN = uninitialised; uint1 NV = uninitialised; uint1 OF = uninitialised; uint1 UF = uninitialised;
    douintmul UINTMUL();
    classify A( a <: a ); classify B( a <: b );

    UINTMUL.factor_1 := { 9b1, floatingpointnumber( a ).fraction }; UINTMUL.factor_2 := { 9b1, floatingpointnumber( b ).fraction };
    flags := { IF, NN, NV, 1b0, OF, UF, 1b0 };

    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                FSM = 1;
                while( FSM != 0 ) {
                    onehot( FSM ) {
                        case 0: {
                            IF = ( A.INF | B.INF ); NN = ( A.sNAN | A.qNAN | B.sNAN | B.qNAN ); NV = ( A.INF | B.INF) & ( A.ZERO | B.ZERO ); OF = 0; UF = 0;
                            __display("");
                            __display("MUL");
                            __display("IF = %b NN = %b NV = %b",IF,NN,NV);
                            __display("a = { %b %b %b } x ",floatingpointnumber( a ).sign,floatingpointnumber( a ).exponent,floatingpointnumber( a ).fraction);
                            __display("b = { %b %b %b }",floatingpointnumber( b ).sign,floatingpointnumber( b ).exponent,floatingpointnumber( b ).fraction);
                            __display("---");
                        }
                        case 1: {
                            switch( IF | NN ) {
                                case 0: {
                                    product = UINTMUL.product[0,48];
                                    productexp = (floatingpointnumber( a ).exponent - 127) + (floatingpointnumber( b ).exponent - 127) + product[47,1];
                                    __display("r = { %b %b %b }",productsign,productexp,product);
                                }
                                case 1: {}
                            }
                        }
                        case 2: {
                            switch( { IF | NN, A.ZERO | B.ZERO } ) {
                                case 2b00: {
                                    ( product ) = normalise48( product );
                                    ( newfraction ) = round48( product );
                                    ( productexp ) = adjustexp48( productexp, newfraction, product );
                                    ( result, OF, UF ) = combinecomponents( productsign, productexp, newfraction );
                                }
                                case 2b01: { __display("ZERO detected"); result = { productsign, 31b0 }; }
                                default: {
                                    __display("INF or NaN detected");
                                    switch( { IF, A.ZERO | B.ZERO } ) {
                                        case 2b11: { result = 32h7fc00000; }
                                        case 2b10: { result = NN ? 32h7fc00000 : { productsign, 8b11111111, 23b0 }; }
                                        default: { result = 32h7fc00000; }
                                    }
                                }
                            }
                        }
                    }
                    FSM = FSM << 1;
                }
                __display("R = { %b %b %b }",floatingpointnumber( result ).sign,floatingpointnumber( result ).exponent,floatingpointnumber( result ).fraction);
                __display("FLAGS = { %b }",flags);
                __display("");
                busy = 0;
            }
        }
    }
}

// DIVIDE TWO FLOATING POINT NUMBERS
$$if not divbit_circuit then
$$divbit_circuit = 1
// PERFORM DIVISION AT SPECIFIC BIT, SHARED BETWEEN INTEGER AND  FLOATING POINT DIVISION
circuitry divbit( inout quo, inout rem, input top, input bottom, input x ) {
    sameas( rem ) temp = uninitialized;
    uint1   quobit = uninitialised;

    temp = ( rem << 1 ) | top[x,1];
    quobit = __unsigned(temp) >= __unsigned(bottom);
    rem = __unsigned(temp) - ( quobit ? __unsigned(bottom) : 0 );
    quo[x,1] = quobit;
}
$$end
algorithm floatdivide(
    input   uint1   start,
    output  uint1   busy,

    input   uint32  a,
    input   uint32  b,

    output  uint7   flags,
    output  uint32  result
) <autorun> {
    uint5   FSM = uninitialised;
    uint1   quotientsign <: floatingpointnumber( a ).sign ^ floatingpointnumber( b ).sign;
    int16   quotientexp = uninitialised;
    uint50  quotient = uninitialised;
    uint50  remainder = uninitialised;
    uint6   bit = uninitialised;
    uint50  sigA = uninitialised;
    uint50  sigB = uninitialised;
    uint23  newfraction = uninitialised;

    uint1 IF = uninitialised; uint1 NN = uninitialised; uint1 DZ = uninitialised; uint1 OF = uninitialised; uint1 UF = uninitialised;
    classify A( a <: a ); classify B( a <: b );
    flags := { IF, NN, 1b0, DZ, OF, UF, 1b0};
    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                FSM = 1;
                while( FSM != 0 ) {
                    onehot( FSM ) {
                        case 0: {
                            IF = ( A.INF | B.INF ); NN = ( A.sNAN | A.qNAN | B.sNAN | B.qNAN ); DZ = B.ZERO; OF = 0; UF = 0;
                        }
                        case 1: {
                            sigA = { 1b1, floatingpointnumber(a).fraction, 26b0 };
                            sigB = { 27b1, floatingpointnumber(b).fraction };
                            quotientexp = (floatingpointnumber( a ).exponent - 127) - (floatingpointnumber( b ).exponent - 127);
                            quotient = 0;
                            remainder = 0;
                            bit = 49;
                        }
                        case 2: { while( ~sigB[0,1] ) { sigB = sigB >> 1; } }
                        case 3: {
                            switch( { IF | NN, A.ZERO | B.ZERO } ) {
                                case 2b00: {
                                    while( bit != 63 ) {
                                        ( quotient, remainder ) = divbit( quotient, remainder, sigA, sigB, bit );
                                        bit = bit - 1;
                                    }
                                    while( quotient[48,2] != 0 ) { quotient = quotient >> 1; }
                                }
                                case 2b01: { result = ( A.ZERO & B.ZERO ) ? 32h7fc00000 : ( B.ZERO ) ? { quotientsign, 8b11111111, 23b0 } : { quotientsign, 31b0 }; }
                                default: { result = ( A.INF & B.INF ) | NN | B.ZERO ? 32h7fc00000 : A.ZERO | B.INF ? { quotientsign, 31b0 } : { quotientsign, 8b11111111, 23b0 }; }
                            }
                        }
                        case 4: {
                            switch( { IF | NN, A.ZERO | B.ZERO } ) {
                                case 2b00: {
                                    switch( quotient ) {
                                        case 0: { result = { quotientsign, 31b0 }; }
                                        default: {
                                            ( quotient ) = normalise48( quotient );
                                            ( newfraction ) = round48( quotient );
                                            quotientexp = 127 + quotientexp - ( floatingpointnumber(b).fraction > floatingpointnumber(a).fraction ) + ( ( newfraction == 0 ) & quotient[23,1] );
                                            ( result, OF, UF ) = combinecomponents( quotientsign, quotientexp, newfraction );
                                        }
                                    }
                                }
                                default: {}
                            }
                        }
                    }
                    FSM = FSM << 1;
                }
                busy = 0;
            }
        }
    }
}

// ADAPTED FROM https://projectf.io/posts/square-root-in-verilog/
algorithm floatsqrt(
    input   uint1   start,
    output  uint1   busy,

    input   uint32  a,
    output  uint7   flags,
    output  uint32  result
) <autorun> {
    uint4   FSM = uninitialised;

    uint48  x = uninitialised;
    uint48  q = uninitialised;
    uint50  ac = uninitialised;
    uint50  test_res = uninitialised;
    uint6   i = uninitialised;

    uint1   sign <: floatingpointnumber( a ).sign;
    int16   exp  = uninitialised;
    uint23  newfraction = uninitialised;

    uint1 IF = uninitialised; uint1 NN = uninitialised; uint1 NV = uninitialised; uint1 OF = uninitialised; uint1 UF = uninitialised;
    classify A( a <: a );
    flags := { IF, NN, NV, 1b0, OF, UF, 1b0 };
    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                FSM = 1;
                IF = A.INF; NN = A.sNAN | A.qNAN; NV = sign; OF = 0; UF = 0;
                switch( A.sNAN | A.qNAN ) {
                    case 1: { result = 32h7fc00000; }
                    default: {
                        switch( { IF | NN, A.ZERO } ) {
                            case 2b00: {
                                switch( sign ) {
                                    case 1: { result = 32h7fc00000; }
                                    case 0: {
                                        while( FSM != 0 ) {
                                            onehot( FSM ) {
                                                case 0: {
                                                    i = 0;
                                                    q = 0;
                                                    exp = floatingpointnumber( a ).exponent - 127;
                                                    ac = ~exp[0,1] ? 1 : { 48b0, 1b1, a[22,1] };
                                                    x = ~exp[0,1] ? { floatingpointnumber( a ).fraction, 25b0 } : { a[0,22], 26b0 };
                                                }
                                                case 1: {
                                                    while( i != 47 ) {
                                                        test_res = ac - { q, 2b01 };
                                                        ac = { test_res[49,1] ? ac[0,47] : test_res[0,47], x[46,2] };
                                                        q = { q[0,47], ~test_res[49,1] };
                                                        x = { x[0,46], 2b00 };
                                                        i = i + 1;
                                                    }
                                                }
                                                case 2: {
                                                    ( q ) = normalise48( q );
                                                }
                                                case 3: {
                                                    exp = ( exp >>> 1 ) + 127;
                                                    ( newfraction ) = round48( q );
                                                    ( result, OF, UF ) = combinecomponents( sign, exp, newfraction );
                                                }
                                            }
                                            FSM = FSM << 1;
                                        }
                                    }
                                }
                            }
                            case 2b10: {
                                switch( NN ) {
                                    case 1: { result = 32h7fc00000; }
                                    case 0: { NV = sign; result = sign ? 32h7fc00000 : a; }
                                }
                            }
                            default: { NV = sign; result = sign ? 32h7fc00000 : a; }
                        }
                    }
                }
                busy = 0;
            }
        }
    }
}

// FLOATING POINT COMPARISONS - ADAPTED FROM SOFT-FLOAT

/*============================================================================

This C source file is part of the SoftFloat IEEE Floating-Point Arithmetic
Package, Release 3e, by John R. Hauser.

Copyright 2011, 2012, 2013, 2014 The Regents of the University of California.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice,
    this list of conditions, and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions, and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

 3. Neither the name of the University nor the names of its contributors may
    be used to endorse or promote products derived from this software without
    specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS "AS IS", AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, ARE
DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=============================================================================*/

circuitry floatless( input a, input b, output lessthan ) {
    lessthan = ( floatingpointnumber( a ).sign != floatingpointnumber( b ).sign ) ? floatingpointnumber( a ).sign & ((( a | b ) << 1) != 0 ) : ( a != b ) & ( floatingpointnumber( a ).sign ^ ( a < b));
}
circuitry floatequal( input a, input b, output equalto ) {
    equalto = ( a == b ) | ((( a | b ) << 1) == 0 );
}
circuitry floatlessequal( input a, input b, output lessequalto, ) {
    lessequalto = ( floatingpointnumber( a ).sign != floatingpointnumber( b ).sign ) ? floatingpointnumber( a ).sign | ((( a | b ) << 1) == 0 ) : ( a == b ) | ( floatingpointnumber( a ).sign ^ ( a < b ));
}

algorithm floatcompare(
    input   uint32  a,
    input   uint32  b,
    output  uint1   less,
    output  uint7   flags,
    output  uint1   equal
) <autorun> {
    classify A( a <: a ); classify B( a <: b );

    // IDENTIFY NaN
    flags := { A.INF | B.INF, A.sNAN | B.sNAN | A.qNAN | B.qNAN, A.sNAN | B.sNAN | A.qNAN | B.qNAN, 4b0000 };

    while(1) {
        switch( flags[5,1] ) {
            case 1: { less = 0; equal = 0; }
            case 0: {
                ( less ) = floatless( a, b );
                ( equal ) = floatequal( a, b );
            }
        }
    }
}
