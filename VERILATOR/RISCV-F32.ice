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
                    default: { NV = 1; result = NN ? 32h7fffffff : floatingpointnumber( a ).sign ? 32hffffffff : 32h7fffffff; }
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

// Risc-V FPU STARTS HERE
// Uses float32 for actual floating point routines

// CONVERSION BETWEEN FLOAT AND SIGNED/UNSIGNED INTEGERS
algorithm floatconvert(
    input   uint1   start,
    output  uint1   busy,

    input   uint7   function7,
    input   uint5   rs2,
    input   uint32  sourceReg1,
    input   uint32  sourceReg1F,

    output  uint5   flags,
    output  uint32  result
) <autorun> {
    inttofloat FPUfloat( a <: sourceReg1 );
    floattoint FPUint( a <: sourceReg1F );
    floattouint FPUuint( a <: sourceReg1F );

    FPUfloat.dounsigned := rs2[0,1]; FPUfloat.start := 0;
    FPUint.start := 0; FPUuint.start := 0;

    while(1) {
        switch( start ) {
            case 1: {
                busy = 1;
                flags = 0;

                switch( function7[2,5] ) {
                    default: {
                        // FCVT.W.S FCVT.WU.S
                        FPUint.start = ~rs2[0,1]; FPUuint.start = rs2[0,1]; while( FPUint.busy || FPUuint.busy ) {}
                        result = rs2[0,1] ? FPUuint.result : FPUint.result; flags = rs2[0,1] ? FPUuint.flags : FPUint.flags;
                    }
                    case 5b11010: {
                        // FCVT.S.W FCVT.S.WU
                        FPUfloat.start = 1; while( FPUfloat.busy ) {}
                        result = FPUfloat.result; flags = FPUfloat.flags;
                    }
                }

                busy = 0;
            }
            default: {}
        }
    }
}

// FPU CALCULATION BLOCKS FUSED ADD SUB MUL DIV SQRT
algorithm floatcalc(
    input   uint1   start,
    output  uint1   busy,

    input   uint7   opCode,
    input   uint7   function7,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    input   uint32  sourceReg3F,

    output  uint5   flags,
    output  uint32  result,
) <autorun> {
    uint2   FSM = uninitialised;
    floataddsub FPUaddsub();
    floatmultiply FPUmultiply( b <: sourceReg2F );
    floatdivide FPUdivide( a <: sourceReg1F, b <: sourceReg2F );
    floatsqrt FPUsqrt( a <: sourceReg1F );

    FPUaddsub.start := 0;
    FPUmultiply.start := 0;
    FPUdivide.start := 0;
    FPUsqrt.start := 0;

    while(1) {
        switch( start ) {
            case 1: {
                busy = 1;
                flags = 0;

                switch( opCode[2,5] ) {
                    default: {
                        // FMADD.S FMSUB.S FNMSUB.S FNMADD.S
                        __display("FUSED OPCODE = %b",opCode);
                        FSM = 1;
                        while( FSM != 0 ) {
                            onehot( FSM ) {
                                case 0: {
                                    FPUmultiply.a = { opCode[3,1] ? ~sourceReg1F[31,1] : sourceReg1F[31,1], sourceReg1F[0,31] };
                                    FPUmultiply.start = 1; while( FPUmultiply.busy ) {} flags = FPUmultiply.flags & 5b10110;
                                    __display("FUSED MULTIPLY RESULT = %x -> { %b %b %b }",FPUmultiply.result,FPUmultiply.result[31,1],FPUmultiply.result[23,8],FPUmultiply.result[0,23]);
                                }
                                case 1: {
                                    __display("FUSED ADD (==0) SUB (==1) %b",( opCode[2,1] ^ opCode[3,1] ));
                                    FPUaddsub.a = FPUmultiply.result; FPUaddsub.b = sourceReg3F;
                                    FPUaddsub.addsub = opCode[2,1];
                                    FPUaddsub.start = 1; while( FPUaddsub.busy ) {} flags = flags | ( FPUaddsub.flags & 5b00110 );
                                }
                            }
                            FSM = { FSM[0,1], 1b0 };
                        }
                        result = FPUaddsub.result;
                    }
                    case 5b10100: {
                        // NON 3 REGISTER FPU OPERATIONS
                        switch( function7[2,5] ) {
                            default: {
                                // FADD.S FSUB.S
                                FPUaddsub.a = sourceReg1F; FPUaddsub.b = sourceReg2F; FPUaddsub.addsub = function7[2,1]; FPUaddsub.start = 1; while( FPUaddsub.busy ) {}
                                result = FPUaddsub.result; flags = FPUaddsub.flags & 5b00110;
                            }
                            case 5b00010: {
                                // FMUL.S
                                FPUmultiply.a = sourceReg1F; FPUmultiply.start = 1; while( FPUmultiply.busy ) {}
                                result = FPUmultiply.result; flags = FPUmultiply.flags & 5b00110;
                            }
                            case 5b00011: {
                                // FDIV.S
                                FPUdivide.start = 1; while( FPUdivide.busy ) {}
                                result = FPUdivide.result; flags = FPUdivide.flags & 5b01110;
                            }
                            case 5b01011: {
                                // FSQRT.S
                                FPUsqrt.start = 1; while( FPUsqrt.busy ) {}
                                result = FPUsqrt.result; flags = FPUsqrt.flags & 5b00110;
                            }
                        }
                    }
                }
                busy = 0;
            }
            default: {}
        }
    }
}

algorithm floatclassify(
    input   uint1   start,
    output  uint1   busy,
    input   uint32  sourceReg1F,
    output  uint10  classification
) <autorun> {
    classify A( a <: sourceReg1F );

    while(1) {
        switch( start ) {
            case 1: {
                busy = 1;
                __display("CLASSIFY %x { %b }",sourceReg1F,{ A.INF, A.sNAN, A.qNAN, A.ZERO });
                switch( { A.INF, A.sNAN, A.qNAN, A.ZERO } ) {
                    case 4b1000: { classification = floatingpointnumber( sourceReg1F ).sign ? 10b0000000001 : 10b0010000000; }
                    case 4b0100: { classification = 10b0100000000; }
                    case 4b0010: { classification = 10b1000000000; }
                    case 4b0001: { classification = ( sourceReg1F[0,23] == 0 ) ? floatingpointnumber( sourceReg1F ).sign ? 10b0000001000 : 10b0000010000 :
                                                                                    floatingpointnumber( sourceReg1F ).sign ? 10b0000000100 : 10b0000100000; }
                    default: { classification = floatingpointnumber( sourceReg1F ).sign ? 10b0000000010 : 10b0001000000; }
                }
                __display("CLASSIFICATION = %b",classification);
                busy = 0;
            }
            case 0: {}
        }
    }
}

algorithm floatminmax(
    input   uint1   start,
    output  uint1   busy,

    input   uint3   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,

    output  uint5   flags,
    output  uint32  result
) <autorun> {
    uint1   less = uninitialised;

    classify A( a <: sourceReg1F ); classify B( a <: sourceReg2F );
    floatcompare FPUlteq( a <: sourceReg1F, b <: sourceReg2F, less :> less );

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                __display("%x < %x = %b",sourceReg1F,sourceReg2F,less);
                switch( ( A.sNAN | B.sNAN ) | ( A.qNAN & B.qNAN ) ) {
                    case 1: { flags = 5b10000; result = 32h7fc00000; } // sNAN or both qNAN
                    case 0: {
                        switch( function3[0,1] ) {
                            case 0: { __display("MIN"); result = A.qNAN ? ( B.qNAN ? 32h7fc00000 : sourceReg2F ) : B.qNAN ? sourceReg1F : ( less ? sourceReg1F : sourceReg2F); }
                            case 1: { __display("MAX"); result = A.qNAN ? ( B.qNAN ? 32h7fc00000 : sourceReg2F ) : B.qNAN ? sourceReg1F : ( less ? sourceReg2F : sourceReg1F); }
                        }
                    }
                }
                busy = 0;
            }
        }
    }
}

// COMPARISONS
algorithm floatcomparison(
    input   uint1   start,
    output  uint1   busy,

    input   uint3   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,

    output  uint5   flags,
    output   uint1  result
) <autorun> {
    uint2   FSM = uninitialised;

    uint1   less = uninitialised;
    uint1   equal = uninitialised;

    classify A( a <: sourceReg1F ); classify B( a <: sourceReg2F );
    floatcompare FPUlteq( a <: sourceReg1F, b <: sourceReg2F, less :> less, equal :> equal );

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                switch( function3 ) {
                    case 3b000: { __display("LESS/EQUAL"); flags = ( A.qNAN | A.sNAN | B.qNAN | B.sNAN ) ? 5b10000 : 0; result = ( A.qNAN | A.sNAN | B.qNAN | B.sNAN ) ? 0 : less | equal; }
                    case 3b001: { __display("LESS"); flags = ( A.qNAN | A.sNAN | B.qNAN | B.sNAN ) ? 5b10000 : 0; result = ( A.qNAN | A.sNAN | B.qNAN | B.sNAN ) ? 0 : less; }
                    case 3b010: { __display("EQUAL"); flags = ( A.sNAN | B.sNAN ) ? 5b10000 : 0; result = ( A.qNAN | A.sNAN | B.qNAN | B.sNAN ) ? 0 : equal; }
                    default: { result = 0; }
                }
                __display("LE LT EQ = %b",result);
                busy = 0;
            }
        }
    }
}

algorithm floatsign(
    input   uint3   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    output  uint32  result,
) <autorun> {
    while(1) {
        switch( function3 ) {
            default: { result = { sourceReg2F[31,1], sourceReg1F[0,31] }; }                         // FSGNJ.S
            case 3b001: { result = { ~sourceReg2F[31,1], sourceReg1F[0,31] }; }                     // FSGNJN.S
            case 3b010: { result = { sourceReg1F[31,1] ^ sourceReg2F[31,1], sourceReg1F[0,31] }; }  // FSGNJX.S
        }
    }
}

algorithm main(output int8 leds) {
    // uint7   opCode = 7b1010011; // ALL OTHER FPU OPERATIONS
    // uint7   opCode = 7b1000011; // FMADD
    // uint7   opCode = 7b1000111; // FMSUB
    // uint7   opCode = 7b1001011; // FNMSUB
    uint7   opCode = 7b1001111; // FNMADD

    uint7   function7 = 7b0000000; // OPERATION SWITCH
    uint3   function3 = 3b000; // ROUNDING MODE OR SWITCH
    uint5   rs1 = 5b00000; // SOURCEREG1 number
    uint5   rs2 = 5b00000; // SOURCEREG2 number OR SWITCH

    uint32  sourceReg1 = 32h00000001; // INTEGER SOURCEREG1

    // -0 = 32h80000000
    // 0 = 0
    // 0.85471 = 32h3F5ACE46
    // 1/3 = 32h3eaaaaab
    // 1 = 32h3F800000
    // 2 = 32h40000000
    // 3 = 32h40400000
    // 100 = 32h42C80000
    // 2.658456E38 = 32h7F480000
    // NaN = 32hffffffff
    // qNaN = 32h7fc00000
    // INF = 32h7F800000
    // -INF = 32hFF800000
    uint32  sourceReg1F = 32h40000000;
    uint32  sourceReg2F = 32h40000000;
    uint32  sourceReg3F = 32h40000000;

    uint32  result = uninitialised;
    uint1   frd = uninitialised;

    uint5   FPUflags = 5b00000;
    uint5   FPUnewflags = uninitialised;

    floatclassify FPUclass( sourceReg1F <: sourceReg1F );
    floatminmax FPUminmax( function3 <: function3, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F );
    floatcomparison FPUcompare( function3 <: function3, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F );
    floatsign FPUsign( function3 <: function3, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F );
    floatcalc FPUcalculator( opCode <: opCode, function7 <: function7, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, sourceReg3F <: sourceReg3F );
    floatconvert FPUconvert( function7 <: function7, rs2 <: rs2, sourceReg1 <: sourceReg1, sourceReg1F <: sourceReg1F );

    FPUclass.start := 0;
    FPUcalculator.start := 0;
    FPUconvert.start := 0;
    FPUminmax.start := 0;
    FPUcompare.start := 0;

    ++:  // REQUIRED UNDER VERILATOR TO ALLOW SIGNALS TO PROPAGATE
    ++:

    //while(1) {
        //switch( start ) {
            //case 1: {
                //busy = 1;
                __display("I1 = %x -> { %b %b %b }",sourceReg1,sourceReg1[31,1],sourceReg1[23,8],sourceReg1[0,23]);
                __display("F1 = %x -> { %b %b %b }",sourceReg1F,sourceReg1F[31,1],sourceReg1F[23,8],sourceReg1F[0,23]);
                __display("F2 = %x -> { %b %b %b }",sourceReg2F,sourceReg2F[31,1],sourceReg2F[23,8],sourceReg2F[0,23]);
                __display("F3 = %x -> { %b %b %b }",sourceReg2F,sourceReg3F[31,1],sourceReg3F[23,8],sourceReg3F[0,23]);
                __display("OPCODE = %b FUNCTION7 = %b FUNCTION3 = %b RS1 = %b RS2 = %b",opCode, function7, function3, rs1, rs2);

                frd = 1;
                FPUnewflags = FPUflags;

                switch( opCode[2,5] ) {
                    default: {
                        // FMADD.S FMSUB.S FNMSUB.S FNMADD.S
                        __display("FUSED");
                        FPUcalculator.start = 1; while( FPUcalculator.busy ) {} result = FPUcalculator.result;
                        FPUnewflags = FPUflags | FPUcalculator.flags;
                    }
                    case 5b10100: {
                        switch( function7[2,5] ) {
                            default: {
                                __display("ADD SUB MUL DIV SQRT");
                                // FADD.S FSUB.S FMUL.S FDIV.S FSQRT.S
                                FPUcalculator.start = 1; while( FPUcalculator.busy ) {} result = FPUcalculator.result;
                                FPUnewflags = FPUflags | FPUcalculator.flags;
                            }
                            case 5b00100: {
                                __display("SIGN");
                                // FSGNJ.S FNGNJN.S FSGNJX.S
                                result = FPUsign.result;
                            }
                            case 5b00101: {
                                __display("MIN MAX");
                                // FMIN.S FMAX.S
                                FPUminmax.start = 1; while( FPUminmax.busy ) {} result = FPUminmax.result;
                                FPUnewflags = FPUflags | FPUminmax.flags;
                            }
                            case 5b10100: {
                                __display("LE LT EQ");
                                // FEQ.S FLT.S FLE.S
                                frd = 0; FPUcompare.start = 1; while( FPUcompare.busy ) {} result = FPUcompare.result;
                                FPUnewflags = FPUflags | FPUcompare.flags;
                            }
                            case 5b11000: {
                                __display("FLOAT TO (U)INT");
                                // FCVT.W.S FCVT.WU.S
                                frd = 0; FPUconvert.start = 1; while( FPUconvert.busy ) {} result = FPUconvert.result;
                                FPUnewflags = FPUflags | FPUconvert.flags;
                            }
                            case 5b11010: {
                                __display("(U)INT TO FLOAT");
                                // FCVT.S.W FCVT.S.WU
                                FPUconvert.start = 1; while( FPUconvert.busy ) {} result = FPUconvert.result;
                                FPUnewflags = FPUflags | FPUconvert.flags;
                            }
                            case 5b11100: {
                                // FCLASS.S FMV.X.W
                                frd = 0;
                                switch( function3[0,1] ) {
                                    case 1: { __display("CLASS"); FPUclass.start = 1; while( FPUclass.busy ) {} result = FPUclass.classification; }
                                    case 0: { __display("TO I-REG"); result = sourceReg1F; }
                                }
                            }
                            case 5b11110: {
                                __display("MOVE TO F-REG");
                                // FMV.W.X
                                result = sourceReg1;
                            }
                        }
                    }
                }
                __display("FRD = %b RESULT = %x -> { %b %b %b }",frd,result,result[31,1],result[23,8],result[0,23]);
                __display("FLAGS = { %b }",FPUnewflags);

                //busy = 0;
            //}
            //default: {}
        //}
    //}
}
