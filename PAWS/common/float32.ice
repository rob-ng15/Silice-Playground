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

// ALGORITHMS TO DEAL WITH 48 BIT FRACTIONS TO 23 BIT FRACTIONS
// REALIGN A 48 BIT NUMBER SO MSB IS 1
algorithm donormalise48(
    input   uint1   start,
    output  uint1   busy,
    input   uint48  bitstream,
    output  uint48  normalised
) <autorun> {
    busy = 0;
    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                normalised = bitstream; while( ~normalised[47,1] ) { normalised = normalised << 1; }
                busy = 0;
            }
        }
    }
}

// EXTRACT 23 BIT FRACTION FROM LEFT ALIGNED 48 BIT FRACTION WITH ROUNDING
algorithm doround48(
    input   uint48  bitstream,
    output  uint23  roundfraction
) <autorun> {
    roundfraction := bitstream[24,23] + bitstream[23,1];
}

// ADJUST EXPONENT IF ROUNDING FORCES, using newfraction and truncated bit from oldfraction
algorithm doadjustexp48(
    input   uint1   roundbit,
    input   uint23  roundfraction,
    input   int10   exponent,
    output  int10   newexponent
) <autorun> {
    newexponent := 127 + exponent + ( ( roundfraction == 0 ) & roundbit );
}

// COMBINE COMPONENTS INTO FLOATING POINT NUMBER
// UNDERFLOW return 0, OVERFLOW return infinity
algorithm docombinecomponents32(
    input   uint1   sign,
    input   int10   exp,
    input   uint23  fraction,
    output  uint1   OF,
    output  uint1   UF,
    output  uint32  f32
) <autorun> {
    OF := ( exp > 254 ); UF := exp[9,1];
    f32 := UF ? 0 : OF ? { sign, 8b11111111, 23h0 } : { sign, exp[0,8], fraction[0,23] };
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
    uint1   sign <: dounsigned ? 0 : a[31,1];
    uint8   zeros = uninitialised;
    uint32  number = uninitialised;

    uint1 OF = uninitialised; uint1 UF = uninitialised; uint1 NX = uninitialised;
    docombinecomponents32 COMBINE( sign <: sign, fraction <: number );
    COMBINE.exp := 158 - zeros;
    flags := { 4b0, OF, UF, NX };
    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                OF = 0; UF = 0; NX = 0;
                number = dounsigned ? a : ( a[31,1] ? -a : a );
                switch( number ) {
                    case 0: { result = 0; }
                    default: {
                        FSM = 1;
                        while( FSM !=0 ) {
                            onehot( FSM ) {
                                case 0: {
                                    zeros = 0; while( ~number[31-zeros,1] ) { zeros = zeros + 1; } NX = ( zeros < 8 );
                                    number = NX ? number >> ( 8 - zeros ) : ( zeros > 8 ) ? number << ( zeros - 8 ) : number;
                                }
                                case 1: { OF = COMBINE.OF; UF = COMBINE.UF; result = COMBINE.f32; }
                            }
                            FSM = FSM << 1;
                        }
                    }
                }
                busy = 0;
            }
        }
    }
}

// CONVERT FLOAT TO SIGNED INTEGERS
algorithm floattoint(
    input   uint1   start,
    output  uint1   busy,
    input   uint32  a,
    output  uint7   flags,
    output  uint32  result
) <autorun> {
    int10   exp = uninitialised;
    uint33  sig = uninitialised;

    uint1 IF <: A.INF; uint1 NN <: A.sNAN | A.qNAN; uint1 NV = uninitialised;
    classify A( a <: a );
    flags := { IF, NN, NV, 4b0000 };
    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                NV = 0;
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

// CONVERT FLOAT TO UNSIGNED INTEGERS
algorithm floattouint(
    input   uint1   start,
    output  uint1   busy,
    input   uint32  a,
    output  uint7   flags,
    output  uint32  result
) <autorun> {
    int10    exp = uninitialised;
    uint33   sig = uninitialised;

    uint1 IF <: A.INF; uint1 NN <: A.sNAN | A.qNAN; uint1 NV = uninitialised;
    classify A( a <: a );
    flags := { IF, NN, NV, 4b0000 };
    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                NV = 0;
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

// ADDSUB
// ADD/SUBTRACT ( addsub == 0 add, == 1 subtract) TWO FLOATING POINT NUMBERS
algorithm prepaddsub(
    input   uint32  a,
    output  uint1   sign,
    output  int10   exp,
    output  uint48  fraction
) <autorun> {
    sign := floatingpointnumber( a ).sign;
    exp := floatingpointnumber( a ).exponent - 127;
    fraction := { 2b01, floatingpointnumber(a).fraction, 23b0 };
}
algorithm equaliseexpaddsub(
    input   int10   expA,
    input   uint48  sigA,
    input   int10   expB,
    input   uint48  sigB,
    output  int10   newexpA,
    output  uint48  newsigA,
    output  int10   newexpB,
    output  uint48  newsigB
) <autorun> {
    while(1) {
        switch( { expA < expB, expB < expA } ) {
            case 2b10: { newsigA = sigA >> ( expB - expA ); newexpA = expB; newsigB = sigB; newexpB = expB; }
            case 2b01: { newsigB = sigB >> ( expA - expB ); newexpB = expA; newsigA = sigA; newexpA = expA; }
            default: { newsigA = sigA; newexpA = expA; newsigB = sigB; newexpB = expB; }
        }
    }
}
algorithm dofloataddsub(
    input   uint1   signA,
    input   uint48  sigA,
    input   uint1   signB,
    input   uint48  sigB,
    output  uint1   resultsign,
    output  uint48  resultfraction
) <autorun> {
    while(1) {
        switch( { signA, signB } ) {
            // PERFORM + HANDLING SIGNS
            case 2b01: {
                switch( sigB > sigA ) {
                    case 1: { resultsign = 1; resultfraction = sigB - sigA; }
                    case 0: { resultsign = 0; resultfraction = sigA - sigB; }
                }
            }
            case 2b10: {
                switch(  sigA > sigB ) {
                    case 1: { resultsign = 1; resultfraction = sigA - sigB; }
                    case 0: { resultsign = 0; resultfraction = sigB - sigA; }
                }
            }
            default: { resultsign = signA; resultfraction = sigA + sigB; }
        }
    }
}
algorithm normaliseaddsub(
    input   uint1   start,
    output  uint1   busy,
    input   int10   exp,
    input   uint48  fraction,
    output  int10   newexp,
    output  uint48  normalised
) <autorun> {
    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                // NORMALISE AND ROUND
                switch( fraction[47,1] ) {
                    case 1: { newexp = exp + 1; normalised = fraction; }
                    default: {
                        newexp = exp; normalised = fraction; while( ~normalised[46,1] ) { normalised = normalised << 1; newexp = newexp - 1; }
                        normalised = { normalised[0,47], 1b0 };
                    }
                }
                busy = 0;
            }
        }
    }
}

algorithm floataddsub(
    input   uint1   start,
    output  uint1   busy,
    input   uint32  a,
    input   uint32  b,
    input   uint1   addsub,
    output  uint7   flags,
    output  uint32  result
) <autorun> {
    uint2   FSM = uninitialised;
    uint1   signA <: prepA.sign;
    uint1   signB <: addsub ? ~prepB.sign : prepB.sign;

    uint1 IF <: ( A.INF | B.INF ); uint1 NN <: ( A.sNAN | A.qNAN | B.sNAN | B.qNAN ); uint1 NV <: ( A.INF & B.INF) & ( signA != signB ); uint1 OF = uninitialised; uint1 UF = uninitialised;
    classify A( a <: a ); classify B( a <: b ); prepaddsub prepA( a <: a ); prepaddsub prepB( a <: b ); equaliseexpaddsub EQUALISEEXP( ); dofloataddsub ADDSUB( ); normaliseaddsub NORMALISE( );
    doround48 ROUND(); doadjustexp48 ADJUSTEXP(); docombinecomponents32 COMBINE();
    EQUALISEEXP.expA := prepA.exp; EQUALISEEXP.sigA := prepA.fraction; EQUALISEEXP.expB := prepB.exp; EQUALISEEXP.sigB := prepB.fraction;
    ADDSUB.signA := signA; ADDSUB.sigA := EQUALISEEXP.newsigA; ADDSUB.signB := signB; ADDSUB.sigB := EQUALISEEXP.newsigB;
    NORMALISE.start := 0;  NORMALISE.exp := EQUALISEEXP.newexpA; NORMALISE.fraction := ADDSUB.resultfraction;
    ROUND.bitstream := NORMALISE.normalised;
    ADJUSTEXP.roundbit := NORMALISE.normalised[23,1]; ADJUSTEXP.roundfraction := ROUND.roundfraction; ADJUSTEXP.exponent := NORMALISE.newexp;
    COMBINE.sign := ADDSUB.resultsign; COMBINE.exp := ADJUSTEXP.newexponent; COMBINE.fraction := ROUND.roundfraction;
    flags := { IF, NN, NV, 1b0, OF, UF, 1b0 };
    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                FSM = 1;
                OF = 0; UF = 0;
                while( FSM != 0 ) {
                    onehot( FSM ) {
                        case 0: {} // ALLOW 1 CYLE TO PREPARE THE ADDITION/SUBTRACTION, EQUALISE EXPONENTS AND PERFORM THE ADDITION/SUBTRACTION
                        case 1: {
                            switch( { IF | NN, A.ZERO | B.ZERO } ) {
                                case 2b00: {
                                    switch( ADDSUB.resultfraction ) {
                                        case 0: { result = 0; }
                                        default: {
                                            // STEPS: SETUP -> DO ADD/SUB -> NORMALISE -> ROUND -> ADJUSTEXP -> COMBINE
                                            // ADD/SUB REQUIRES NORMALISATION THAT ADJUSTS THE EXP WHEN SHIFTING LEFT
                                            NORMALISE.start = 1; while( NORMALISE.busy ) {}
                                            OF = COMBINE.OF; UF = COMBINE.UF; result = COMBINE.f32;
                                        }
                                    }
                                 }
                                case 2b01: { result = ( B.ZERO ) ? a : addsub ? { ~floatingpointnumber( b ).sign, b[0,31] } : b; }
                                default: {
                                    switch( { IF, NN } ) {
                                        case 2b10: { result = ( A.INF & B.INF) ? ( signA == signB ) ? a : 32hffc00000 : A.INF ? a : b; }
                                        default: { result = 32hffc00000; }
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
    uint2   FSM = uninitialised;

    uint1   productsign <: floatingpointnumber( a ).sign ^ floatingpointnumber( b ).sign;
    uint1 IF <: ( A.INF | B.INF ); uint1 NN <: ( A.sNAN | A.qNAN | B.sNAN | B.qNAN ); uint1 NV <: ( A.sNAN | A.qNAN | B.sNAN | B.qNAN ); uint1 OF = uninitialised; uint1 UF = uninitialised;
    classify A( a <: a ); classify B( a <: b ); douintmul UINTMUL(); donormalise48 NORMALISE( ); doround48 ROUND(); doadjustexp48 ADJUSTEXP(); docombinecomponents32 COMBINE();
    UINTMUL.factor_1 := { 9b1, floatingpointnumber( a ).fraction }; UINTMUL.factor_2 := { 9b1, floatingpointnumber( b ).fraction };
    NORMALISE.start := 0; NORMALISE.bitstream := UINTMUL.product[0,48];
    ROUND.bitstream := NORMALISE.normalised;
    ADJUSTEXP.roundbit := NORMALISE.normalised[23,1]; ADJUSTEXP.roundfraction := ROUND.roundfraction; ADJUSTEXP.exponent := (floatingpointnumber( a ).exponent - 127) + (floatingpointnumber( b ).exponent - 127) + UINTMUL.product[47,1];
    COMBINE.sign := productsign; COMBINE.exp := ADJUSTEXP.newexponent; COMBINE.fraction := ROUND.roundfraction;
    flags := { IF, NN, NV, 1b0, OF, UF, 1b0 };

    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                FSM = 1;
                OF = 0; UF = 0;
                while( FSM != 0 ) {
                    onehot( FSM ) {
                        case 0: {} // ALLOW 1 CYLE TO PERFORM THE MULTIPLICATION
                        case 1: {
                            switch( { IF | NN, A.ZERO | B.ZERO } ) {
                                case 2b00: {
                                    // STEPS: SETUP -> DOMUL -> NORMALISE -> ROUND -> ADJUSTEXP -> COMBINE
                                    NORMALISE.start = 1; while( NORMALISE.busy ) {}
                                    OF = COMBINE.OF; UF = COMBINE.UF; result = COMBINE.f32;
                                }
                                case 2b01: { result = { productsign, 31b0 }; }
                                default: {
                                    switch( { IF, A.ZERO | B.ZERO } ) {
                                        case 2b11: { result = 32hffc00000; }
                                        case 2b10: { result = NN ? 32hffc00000 : { productsign, 8b11111111, 23b0 }; }
                                        default: { result = 32hffc00000; }
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

// DIVIDE TWO FLOATING POINT NUMBERS
algorithm dofloatdivbit(
    input   uint50  quotient,
    input   uint50  remainder,
    input   uint50  top,
    input   uint50  bottom,
    input   uint6   bit,
    output  uint50  newquotient,
    output  uint50  newremainder,
 ) <autorun> {
    uint50  temporary = uninitialized;
    uint1   bitresult = uninitialised;
    while(1) {
        temporary = { remainder[0,49], top[bit,1] };
        //temporary = ( remainder << 1 ) | top[bit,1];
        bitresult = __unsigned(temporary) >= __unsigned(bottom);
        newremainder = __unsigned(temporary) - ( bitresult ? __unsigned(bottom) : 0 );
        newquotient = quotient | ( bitresult << bit );
    }
}
algorithm dofloatdivide(
    input   uint1   start,
    output  uint1   busy,
    input   uint50  sigA,
    input   uint50  sigB,
    output  uint50  quotient
) <autorun> {
    dofloatdivbit DIVBIT(
        quotient <: quotient,
        remainder <: remainder,
        top <: sigA,
        bottom <: sigB,
        bit <: bit
    );
    uint50  remainder = uninitialised;
    uint6   bit = uninitialised;
    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                bit = 49; quotient = 0; remainder = 0;
                while( bit != 63 ) { quotient = DIVBIT.newquotient; remainder = DIVBIT.newremainder; bit = bit - 1; }
                while( quotient[48,2] != 0 ) { quotient = quotient >> 1; }
                busy = 0;
            }
        }
    }
}

algorithm floatdivide(
    input   uint1   start,
    output  uint1   busy,

    input   uint32  a,
    input   uint32  b,

    output  uint7   flags,
    output  uint32  result
) <autorun> {
    uint1   quotientsign <: floatingpointnumber( a ).sign ^ floatingpointnumber( b ).sign;
    uint1 IF <: ( A.INF | B.INF ); uint1 NN <: ( A.sNAN | A.qNAN | B.sNAN | B.qNAN ); uint1 DZ <: B.ZERO; uint1 OF = uninitialised; uint1 UF = uninitialised;
    classify A( a <: a ); classify B( a <: b ); dofloatdivide DODIVIDE( ); donormalise48 NORMALISE(); doround48 ROUND(); doadjustexp48 ADJUSTEXP(); docombinecomponents32 COMBINE();
    DODIVIDE.start := 0; DODIVIDE.sigA := { 1b1, floatingpointnumber(a).fraction, 26b0 }; DODIVIDE.sigB := { 27b1, floatingpointnumber(b).fraction };
    NORMALISE.start := 0; NORMALISE.bitstream := DODIVIDE.quotient[0,48];
    ROUND.bitstream := NORMALISE.normalised;
    ADJUSTEXP.roundbit := NORMALISE.normalised[23,1]; ADJUSTEXP.roundfraction := ROUND.roundfraction; ADJUSTEXP.exponent := ((floatingpointnumber( a ).exponent - 127) - (floatingpointnumber( b ).exponent - 127)) - ( floatingpointnumber(b).fraction > floatingpointnumber(a).fraction );
    COMBINE.sign := quotientsign; COMBINE.exp := ADJUSTEXP.newexponent; COMBINE.fraction := ROUND.roundfraction;
    flags := { IF, NN, 1b0, DZ, OF, UF, 1b0};
    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                OF = 0; UF = 0;
                switch( { IF | NN, A.ZERO | B.ZERO } ) {
                    case 2b00: {
                        DODIVIDE.start = 1; while( DODIVIDE.busy ) {}
                        switch( DODIVIDE.quotient ) {
                            case 0: { result = { quotientsign, 31b0 }; }
                            default: {
                                // STEPS: SETUP -> DODIVIDE -> NORMALISE -> ROUND -> ADJUSTEXP -> COMBINE
                                NORMALISE.start = 1; while( NORMALISE.busy ) {}
                                OF = COMBINE.OF; UF = COMBINE.UF; result = COMBINE.f32;
                            }
                        }
                    }
                    case 2b01: { result = ( A.ZERO & B.ZERO ) ? 32hffc00000 : ( B.ZERO ) ? { quotientsign, 8b11111111, 23b0 } : { quotientsign, 31b0 }; }
                    default: { result = ( A.INF & B.INF ) | NN | B.ZERO ? 32hffc00000 : A.ZERO | B.INF ? { quotientsign, 31b0 } : { quotientsign, 8b11111111, 23b0 }; }
                }
                busy = 0;
            }
        }
    }
}

// ADAPTED FROM https://projectf.io/posts/square-root-in-verilog/
algorithm dofloatsqrtbitt(
    input   uint50  ac,
    input   uint48  x,
    input   uint48  q,
    output  uint50  newac,
    output  uint48  newq,
    output  uint48  newx
 ) <autorun> {
    uint50  test_res = uninitialised;
    while(1) {
        test_res = ac - { q, 2b01 };
        newac = { test_res[49,1] ? ac[0,47] : test_res[0,47], x[46,2] };
        newq = { q[0,47], ~test_res[49,1] };
        newx = { x[0,46], 2b00 };
    }
}
algorithm dofloatsqrt(
    input   uint1   start,
    output  uint1   busy,
    input   uint50  start_ac,
    input   uint48  start_x,
    output  uint48  q
) <autorun> {
    dofloatsqrtbitt SQRTBIT(
        ac <: ac,
        x <: x,
        q <: q
    );

    uint48  x = uninitialised;
    uint50  ac = uninitialised;
    uint6   i = uninitialised;
    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                i = 0; q = 0; ac = start_ac; x = start_x;
                while( i != 47 ) { ac = SQRTBIT.newac; q = SQRTBIT.newq; x = SQRTBIT.newx; i = i + 1; }
                busy = 0;
            }
        }
    }
}

algorithm floatsqrt(
    input   uint1   start,
    output  uint1   busy,

    input   uint32  a,
    output  uint7   flags,
    output  uint32  result
) <autorun> {
    uint1   sign <: floatingpointnumber( a ).sign;              // SIGN OF INPUT
    int10   exp  <: floatingpointnumber( a ).exponent - 127;    // EXPONENT OF INPUT ( used to determine if 1x.xxxxx or 01.xxxxx for fixed point fraction to sqrt )

    uint1 IF <: A.INF; uint1 NN <: A.sNAN | A.qNAN; uint1 NV <: IF | NN | sign; uint1 OF = uninitialised; uint1 UF = uninitialised;
    classify A( a <: a ); dofloatsqrt DOSQRT( ); donormalise48 NORMALISE(); doround48 ROUND(); doadjustexp48 ADJUSTEXP(); docombinecomponents32 COMBINE();
    DOSQRT.start := 0; DOSQRT.start_ac := ~exp[0,1] ? 1 : { 48b0, 1b1, a[22,1] }; DOSQRT.start_x := ~exp[0,1] ? { floatingpointnumber( a ).fraction, 25b0 } : { a[0,22], 26b0 };
    NORMALISE.start := 0; NORMALISE.bitstream := DOSQRT.q;
    ROUND.bitstream := NORMALISE.normalised;
    ADJUSTEXP.roundbit := NORMALISE.normalised[23,1]; ADJUSTEXP.roundfraction := ROUND.roundfraction; ADJUSTEXP.exponent := ( exp >>> 1 );
    COMBINE.sign := 0; COMBINE.exp := ADJUSTEXP.newexponent; COMBINE.fraction := ROUND.roundfraction;
    flags := { IF, NN, NV, 1b0, OF, UF, 1b0 };
    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                OF = 0; UF = 0;
                switch( NN ) {
                    case 1: { result = 32hffc00000; }
                    default: {
                        switch( { IF | NN, A.ZERO } ) {
                            case 2b00: {
                                switch( sign ) {
                                    case 1: { result = 32hffc00000; }
                                    case 0: {
                                        // STEPS: SETUP -> DOSQRT -> NORMALISE -> ROUND -> ADJUSTEXP -> COMBINE
                                        DOSQRT.start = 1; while( DOSQRT.busy ) {}
                                        NORMALISE.start = 1; while( NORMALISE.busy ) {}
                                        OF = COMBINE.OF; UF = COMBINE.UF; result = COMBINE.f32;
                                    }
                                }
                            }
                            case 2b10: {
                                switch( NN ) {
                                    case 1: { result = 32hffc00000; }
                                    case 0: { result = sign ? 32hffc00000 : a; }
                                }
                            }
                            default: { result = sign ? 32hffc00000 : a; }
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
    less := flags[5,1] ? 0 : ( floatingpointnumber( a ).sign != floatingpointnumber( b ).sign ) ? floatingpointnumber( a ).sign & ((( a | b ) << 1) != 0 ) : ( a != b ) & ( floatingpointnumber( a ).sign ^ ( a < b));
    equal := flags[5,1] ? 0 : ( a == b ) | ((( a | b ) << 1) == 0 );
}
