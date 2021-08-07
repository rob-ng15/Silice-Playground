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
    output  uint1   busy(0),
    input   uint48  bitstream,
    output  uint48  normalised
) <autorun> {
    uint4   shiftcount <:: { normalised[33,15] == 0, normalised[41,7] == 0, normalised[45,3] == 0, 1b1 };
    busy := start | ~normalised[47,1];
    while(1) {
        if( start ) {
            busy = 1;
            __display("  NORMALISING THE RESULT MANTISSA");
            normalised = bitstream;
            __display("  %b",normalised);
            // NORMALISE BY SHIFT 1, 3, 7 OR 15 ZEROS LEFT
            while( ~normalised[47,1] ) {
                normalised = normalised << shiftcount;
                __display("  %b AFTER SHIFT LEFT %d",normalised,shiftcount);
            }
            busy = 0;
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
    output  uint1   busy(0),
    input   uint32  a,
    input   uint1   dounsigned,
    output  uint7   flags,
    output  uint32  result
) <autorun> {
    uint2   FSM = uninitialised;
    uint1   sign <: dounsigned ? 0 : a[31,1];
    uint8   zeros = uninitialised;
    uint32  number <: dounsigned ? a : ( a[31,1] ? -a : a );

    uint1 OF = uninitialised; uint1 UF = uninitialised; uint1 NX = uninitialised;
    docombinecomponents32 COMBINE( sign <: sign );
    COMBINE.exp := 158 - zeros;
    flags := { 4b0, OF, UF, NX };

    while(1) {
        if( start ) {
            busy = 1;
            OF = 0; UF = 0; NX = 0;
            switch( number ) {
                case 0: { result = 0; }
                default: {
                    FSM = 1;
                    while( FSM !=0 ) {
                        onehot( FSM ) {
                            case 0: {
                                zeros = number[8,24] == 0 ? 24 : number[16,16] == 0 ? 16 : number[24,8] == 0 ? 8 : 0; while( ~number[31-zeros,1] ) {
                                    zeros = zeros + 1;
                                    __display("  LEADING ZEROS = %x",zeros);
                                }
                                NX = ( zeros < 8 );
                                COMBINE.fraction = NX ? number >> ( 8 - zeros ) : ( zeros > 8 ) ? number << ( zeros - 8 ) : number;
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

// CONVERT FLOAT TO SIGNED INTEGERS
algorithm floattoint(
    input   uint32  a,
    output  uint7   flags,
    output  uint32  result
) <autorun> {
    int10   exp = uninitialised;
    uint33  sig = uninitialised;

    uint1 IF <: A.INF; uint1 NN <: A.sNAN | A.qNAN; uint1 NV = uninitialised;
    classify A( a <: a );
    flags := { IF, NN, NV, 4b0000 };

    always {
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
    }
}

// CONVERT FLOAT TO UNSIGNED INTEGERS
algorithm floattouint(
    input   uint32  a,
    output  uint7   flags,
    output  uint32  result
) <autorun> {
    int10    exp = uninitialised;
    uint33   sig = uninitialised;

    uint1 IF <: A.INF; uint1 NN <: A.sNAN | A.qNAN; uint1 NV = uninitialised;
    classify A( a <: a );
    flags := { IF, NN, NV, 4b0000 };

    always {
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
    always {
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
    always {
        // PERFORM ADDITION HANDLING SIGNS
        switch( { signA, signB } ) {
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
    output  uint1   busy(0),
    input   int10   exp,
    input   uint48  fraction,
    output  int10   newexp,
    output  uint48  normalised
) <autorun> {
    uint2   shiftcount <:: { normalised[44,3] == 0, 1b1 };
    while(1) {
        if( start ) {
            busy = 1;
            // NORMALISE AND ROUND
            __display("  NORMALISING THE RESULT MANTISSA, ADJUSTING EXPONENT");
            __display("  %b %b (RESULT EXP AND MANTISSA)",exp,fraction);
            switch( fraction[47,1] ) {
                case 1: {
                    newexp = exp + 1; normalised = fraction;
                    __display("  %b %b (INCREASE EXP AS LARGE RESULT)",newexp,normalised);
                }
                default: {
                    newexp = exp; normalised = fraction;
                    while( ~normalised[46,1] ) {
                        normalised = normalised << shiftcount; newexp = newexp - shiftcount;
                        __display("  %b %b (DECREASE EXP AS SMALL RESULT) AFTER SHIFT LEFT %d",newexp,normalised,shiftcount);
                    }
                    normalised = { normalised[0,47], 1b0 };
                    __display("  %b %b (FULLY NORMALISED)",newexp,normalised);
                }
            }
            busy = 0;
        }
    }
}

algorithm floataddsub(
    input   uint1   start,
    output  uint1   busy(0),
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

    while(1) {
        if( start ) {
            busy = 1;
            FSM = 1;
            OF = 0; UF = 0;
            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {
                        // ALLOW 1 CYLE TO PREPARE THE ADDITION/SUBTRACTION, EQUALISE EXPONENTS AND PERFORM THE ADDITION/SUBTRACTION
                        __display("");
                        __display("  a = { %b %b %b } INPUT",floatingpointnumber( a ).sign,floatingpointnumber( a ).exponent,floatingpointnumber( a ).fraction);
                        __display("  b = { %b %b %b } INPUT",floatingpointnumber( b ).sign,floatingpointnumber( b ).exponent,floatingpointnumber( b ).fraction);
                        __display("  IF = %b NN = %b",IF,NN);
                        __display("");
                        __display("  IF SUBTRACTION SWITCH SIGN OF B FROM %b TO %b",b[31,1],signB);
                        __display("  ADD HIDDEN 1 TO MANTISSA AND EXPAND TO 48 BITS, ALIGNED AT BIT 46, REMOVE BIAS FROM EXPONENT AND EXTEND TO 10 BITS");
                        __display("  a = { %b %b %b }",signA,prepA.exp,prepA.fraction);
                        __display("  b = { %b %b %b }",signB,prepB.exp,prepB.fraction);
                        __display("");
                     }
                    case 1: {
                        __display("  EQUALISE EXPONENTS (SHIFTING MANTISSA)");
                        __display("  a = { %b %b %b }",signA,EQUALISEEXP.newexpA,EQUALISEEXP.newsigA);
                        __display("  b = { %b %b %b }",signB,EQUALISEEXP.newexpA,EQUALISEEXP.newsigB);
                        __display("");
                        __display("  CALCULATING");
                        __display("  { %b %b %b } +",signA,EQUALISEEXP.newexpA,EQUALISEEXP.newsigA);
                        __display("  { %b %b %b }",signB,EQUALISEEXP.newexpA,EQUALISEEXP.newsigB);
                        __display(" ={ %b %b %b }",ADDSUB.resultsign,EQUALISEEXP.newexpA,ADDSUB.resultfraction);
                        __display("");
                        switch( { IF | NN, A.ZERO | B.ZERO } ) {
                            case 2b00: {
                                switch( ADDSUB.resultfraction ) {
                                    case 0: {
                                        __display("");
                                        __display("  ZERO RESULT");
                                        result = 0;
                                    }
                                    default: {
                                        // STEPS: SETUP -> DO ADD/SUB -> NORMALISE -> ROUND -> ADJUSTEXP -> COMBINE
                                        // ADD/SUB REQUIRES NORMALISATION THAT ADJUSTS THE EXP WHEN SHIFTING LEFT
                                        NORMALISE.start = 1; while( NORMALISE.busy ) {}
                                        __display("");
                                        __display("  ADD BIAS TO EXPONENT, ROUND AND TRUNCATE MANTISSA");
                                        __display("  %b %b (ROUND BIT = %b)",ADJUSTEXP.newexponent,ROUND.roundfraction,NORMALISE.normalised[23,1]);
                                        OF = COMBINE.OF; UF = COMBINE.UF; result = COMBINE.f32;
                                        __display("");
                                        __display("  TRUNCATE EXP AND COMBINE TO FINAL RESULT");
                                    }
                                }
                            }
                            case 2b01: {
                                result = ( A.ZERO & B.ZERO ) ? 0 : ( B.ZERO ) ? a : addsub ? { ~floatingpointnumber( b ).sign, b[0,31] } : b;
                                __display("");
                                __display("  ZERO AS INPUT");
                                __display("  SELECT FINAL RESULT");
                            }
                            default: {
                                switch( { IF, NN } ) {
                                    case 2b10: { result = ( A.INF & B.INF) ? ( signA == signB ) ? a : 32hffc00000 : A.INF ? a : b; }
                                    default: { result = 32hffc00000; }
                                }
                                __display("");
                                __display("  INF OR NAN AS INPUT");
                                __display("  SELECT FINAL RESULT");
                            }
                        }
                    }
                }
                FSM = FSM << 1;
            }
            __display("  { %b %b %b }",result[31,1],result[23,8],result[0,23]);
            __display("  { IF NN NV DZ OF UF NX = %b }",flags);
            busy = 0;
        }
    }
}

// UNSIGNED / SIGNED 24 by 24 bit multiplication giving 48 bit product using DSP blocks
algorithm dofloatmul(
    input   uint24  factor_1,
    input   uint24  factor_2,
    output  uint48  product
) <autorun> {
    product := factor_1 * factor_2;
}
algorithm floatmultiply(
    input   uint1   start,
    output  uint1   busy(0),

    input   uint32  a,
    input   uint32  b,

    output  uint7   flags,
    output  uint32  result
) <autorun> {
    uint2   FSM = uninitialised;

    uint1   productsign <: floatingpointnumber( a ).sign ^ floatingpointnumber( b ).sign;
    uint1 IF <: ( A.INF | B.INF ); uint1 NN <: ( A.sNAN | A.qNAN | B.sNAN | B.qNAN ); uint1 NV <: ( A.sNAN | A.qNAN | B.sNAN | B.qNAN ); uint1 OF = uninitialised; uint1 UF = uninitialised;
    classify A( a <: a ); classify B( a <: b ); dofloatmul UINTMUL(); donormalise48 NORMALISE( ); doround48 ROUND(); doadjustexp48 ADJUSTEXP(); docombinecomponents32 COMBINE();
    UINTMUL.factor_1 := { 1b1, floatingpointnumber( a ).fraction }; UINTMUL.factor_2 := { 1b1, floatingpointnumber( b ).fraction };
    NORMALISE.start := 0; NORMALISE.bitstream := UINTMUL.product;
    ROUND.bitstream := NORMALISE.normalised;
    ADJUSTEXP.roundbit := NORMALISE.normalised[23,1]; ADJUSTEXP.roundfraction := ROUND.roundfraction; ADJUSTEXP.exponent := (floatingpointnumber( a ).exponent - 127) + (floatingpointnumber( b ).exponent - 127) + UINTMUL.product[47,1];
    COMBINE.sign := productsign; COMBINE.exp := ADJUSTEXP.newexponent; COMBINE.fraction := ROUND.roundfraction;
    flags := { IF, NN, NV, 1b0, OF, UF, 1b0 };

    while(1) {
        if( start ) {
            busy = 1;
            FSM = 1;
            OF = 0; UF = 0;
            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {
                        // ALLOW 1 CYLE TO PERFORM THE MULTIPLICATION
                        __display("");
                        __display("  a = { %b %b %b } INPUT",floatingpointnumber( a ).sign,floatingpointnumber( a ).exponent,floatingpointnumber( a ).fraction);
                        __display("  b = { %b %b %b } INPUT",floatingpointnumber( b ).sign,floatingpointnumber( b ).exponent,floatingpointnumber( b ).fraction);
                        __display("  IF = %b NN = %b NV = %b",IF,NN,NV);
                        __display("");
                    }
                    case 1: {
                        __display("  CALCULATING, ADDING EXPONENTS AFTER REMOVING BIAS");
                        __display("  { %b %b %b } x",a[31,1],(floatingpointnumber( a ).exponent - 127),{ 1b1, floatingpointnumber( a ).fraction });
                        __display("  { %b %b %b }",b[31,1],(floatingpointnumber( b ).exponent - 127),{ 1b1, floatingpointnumber( b ).fraction });
                        __display(" ={ %b %b %b }",productsign,(floatingpointnumber( a ).exponent - 127) + (floatingpointnumber( b ).exponent - 127),UINTMUL.product);
                        __display("");
                        switch( { IF | NN, A.ZERO | B.ZERO } ) {
                            case 2b00: {
                                // STEPS: SETUP -> DOMUL -> NORMALISE -> ROUND -> ADJUSTEXP -> COMBINE
                                NORMALISE.start = 1; while( NORMALISE.busy ) {}
                                __display("");
                                __display("  ADD BIAS TO EXPONENT, ROUND AND TRUNCATE MANTISSA");
                                __display("  %b %b (ROUND BIT = %b) (LARGE RESULT + 1 TO EXPONENT == %b)",ADJUSTEXP.newexponent,ROUND.roundfraction,NORMALISE.normalised[23,1],UINTMUL.product[47,1]);
                                OF = COMBINE.OF; UF = COMBINE.UF; result = COMBINE.f32;
                                __display("");
                                __display("  TRUNCATE EXP AND COMBINE TO FINAL RESULT");
                            }
                            case 2b01: {
                                result = { productsign, 31b0 };
                                __display("");
                                __display("  ZERO AS INPUT");
                                __display("  SELECT FINAL RESULT");
                            }
                            default: {
                                switch( { IF, A.ZERO | B.ZERO } ) {
                                    case 2b11: { result = 32hffc00000; }
                                    case 2b10: { result = NN ? 32hffc00000 : { productsign, 8b11111111, 23b0 }; }
                                    default: { result = 32hffc00000; }
                                }
                                __display("");
                                __display("  INF OR NAN AS INPUT");
                                __display("  SELECT FINAL RESULT");
                            }
                        }
                    }
                }
                FSM = FSM << 1;
            }
            __display("  { %b %b %b }",result[31,1],result[23,8],result[0,23]);
            __display("  { IF NN NV DZ OF UF NX = %b }",flags);
            busy = 0;
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
    uint50  temporary = uninitialised;
    uint1   bitresult = uninitialised;
    always {
        temporary = { remainder[0,49], top[bit,1] };
        bitresult = __unsigned(temporary) >= __unsigned(bottom);
        newremainder = __unsigned(temporary) - ( bitresult ? __unsigned(bottom) : 0 );
        newquotient = quotient | ( bitresult << bit );
    }
}
algorithm dofloatdivide(
    input   uint1   start,
    output  uint1   busy(0),
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
    uint50  remainder <: start ? 0 : DIVBIT.newremainder;
    uint6   bit(63);

    busy := start | ( bit != 63 ) | ( quotient[48,2] != 0 );
    while(1) {
        if( start ) {
            bit = 49; quotient = 0;
            while( bit != 63 ) { quotient = DIVBIT.newquotient; bit = bit - 1; }
            while( quotient[48,2] != 0 ) { quotient = quotient >> 1; }
        }
    }
}

algorithm floatdivide(
    input   uint1   start,
    output  uint1   busy(0),

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

    while(1) {
        if( start ) {
            busy = 1;
            __display("");
            __display("  a = { %b %b %b } INPUT",floatingpointnumber( a ).sign,floatingpointnumber( a ).exponent,floatingpointnumber( a ).fraction);
            __display("  b = { %b %b %b } INPUT",floatingpointnumber( b ).sign,floatingpointnumber( b ).exponent,floatingpointnumber( b ).fraction);
            __display("  IF = %b NN = %b DZ = %b",IF,NN,DZ);
            __display("");
            OF = 0; UF = 0;
            __display("  CALCULATING");
            __display("  ALIGN DIVIDEND TO LEFT, DIVISOR TO THE RIGHT");
            __display("  SUBTRACTING EXPONENTS AFTER REMOVING BIAS");
            __display("  { %b %b %b } /",a[31,1],(floatingpointnumber( a ).exponent - 127),{ 1b1, floatingpointnumber(a).fraction, 26b0 });
            __display("  { %b %b %b }",b[31,1],(floatingpointnumber( b ).exponent - 127),{ 27b1, floatingpointnumber(b).fraction });
            switch( { IF | NN, A.ZERO | B.ZERO } ) {
                case 2b00: {
                    DODIVIDE.start = 1; while( DODIVIDE.busy ) {}
                    __display(" ={ %b %b %b }",quotientsign,((floatingpointnumber( a ).exponent - 127) - (floatingpointnumber( b ).exponent - 127)),DODIVIDE.quotient);
                    __display("");
                    switch( DODIVIDE.quotient ) {
                        case 0: {
                            result = { quotientsign, 31b0 };
                            __display(" ={ 0 }");
                        }
                        default: {
                            // STEPS: SETUP -> DODIVIDE -> NORMALISE -> ROUND -> ADJUSTEXP -> COMBINE
                            NORMALISE.start = 1; while( NORMALISE.busy ) {}
                            __display("");
                            __display("  ADD BIAS TO EXPONENT, ROUND AND TRUNCATE MANTISSA");
                            __display("  %b %b (ROUND BIT = %b) (DIVISOR SMALLER THAN DIVIDEND -1 FROM EXPONENT == %b)",ADJUSTEXP.newexponent,ROUND.roundfraction,NORMALISE.normalised[23,1],floatingpointnumber(b).fraction > floatingpointnumber(a).fraction);
                            OF = COMBINE.OF; UF = COMBINE.UF; result = COMBINE.f32;
                            __display("");
                            __display("  TRUNCATE EXP AND COMBINE TO FINAL RESULT");
                        }
                    }
                }
                case 2b01: {
                    result = ( A.ZERO & B.ZERO ) ? 32hffc00000 : ( B.ZERO ) ? { quotientsign, 8b11111111, 23b0 } : { quotientsign, 31b0 };
                    __display("");
                    __display("  ZERO AS INPUT");
                    __display("  SELECT FINAL RESULT");
                }
                default: {
                    result = ( A.INF & B.INF ) | NN | B.ZERO ? 32hffc00000 : A.ZERO | B.INF ? { quotientsign, 31b0 } : { quotientsign, 8b11111111, 23b0 };
                    __display("");
                    __display("  INF OR NAN AS INPUT");
                    __display("  SELECT FINAL RESULT");
                }
            }
            __display("  { %b %b %b }",result[31,1],result[23,8],result[0,23]);
            __display("  { IF NN NV DZ OF UF NX = %b }",flags);
            busy = 0;
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
    uint50  test_res <: ac - { q, 2b01 };
    always {
        newac = { test_res[49,1] ? ac[0,47] : test_res[0,47], x[46,2] };
        newq = { q[0,47], ~test_res[49,1] };
        newx = { x[0,46], 2b00 };
    }
}
algorithm dofloatsqrt(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint50  start_ac,
    input   uint48  start_x,
    output  uint48  q
) <autorun> {
    dofloatsqrtbitt SQRTBIT(
        ac <: ac,
        x <: x,
        q <: q
    );

    uint48  x <: start ? start_x : SQRTBIT.newx;
    uint50  ac <: start ? start_ac : SQRTBIT.newac;
    uint6   i(47);

    busy := start | ( i != 47 );
    while(1) {
        if( start ) {
            i = 0; q = 0;
            while( i != 47 ) { q = SQRTBIT.newq; i = i + 1; }
        }
    }
}

algorithm floatsqrt(
    input   uint1   start,
    output  uint1   busy(0),

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

    while(1) {
        if( start ) {
            busy = 1;
            __display("");
            __display("  a = { %b %b %b } INPUT",floatingpointnumber( a ).sign,floatingpointnumber( a ).exponent,floatingpointnumber( a ).fraction);
            __display("  IF = %b NN = %b NV = %b",IF,NN,NV);
            __display("");
            OF = 0; UF = 0;
            switch( { IF | NN, A.ZERO } ) {
                case 2b00: {
                    switch( sign ) {
                        case 1: {
                            result = 32hffc00000;
                            __display("");
                            __display("  NEGATIVE AS INPUT");
                            __display("  SELECT FINAL RESULT");
                        }
                        case 0: {
                            // STEPS: SETUP -> DOSQRT -> NORMALISE -> ROUND -> ADJUSTEXP -> COMBINE
                            __display("  CALCULATING REMOVE BIAS FROM EXPONENT");
                            __display("  SQRT OF { %b %b %b } ",a[31,1],(floatingpointnumber( a ).exponent - 127),{ 1b1, floatingpointnumber(a).fraction });
                            __display("  AC = { %b }",~exp[0,1] ? 1 : { 48b0, 1b1, a[22,1] });
                            __display("  X  = { %b }",~exp[0,1] ? { floatingpointnumber( a ).fraction, 25b0 } : { a[0,22], 26b0 });
                            DOSQRT.start = 1; while( DOSQRT.busy ) {}
                            __display("  HALVE THE EXPONENT");
                            __display(" ={ 0 %b %b }",( exp >>> 1 ),DOSQRT.q);
                            __display("");
                            NORMALISE.start = 1; while( NORMALISE.busy ) {}
                            __display("");
                            __display("  ADD BIAS TO EXPONENT, ROUND AND TRUNCATE MANTISSA");
                            __display("  %b %b (ROUND BIT = %b)",ADJUSTEXP.newexponent,ROUND.roundfraction,NORMALISE.normalised[23,1]);
                            OF = COMBINE.OF; UF = COMBINE.UF; result = COMBINE.f32;
                            __display("");
                            __display("  TRUNCATE EXP AND COMBINE TO FINAL RESULT");
                        }
                    }
                }
                default: {
                    result = sign ? 32hffc00000 : a;
                    __display("");
                    __display("  INF, NAN OR ZERO AS INPUT");
                    __display("  SELECT FINAL RESULT");

                }
            }
            __display("  { %b %b %b }",result[31,1],result[23,8],result[0,23]);
            __display("  { IF NN NV DZ OF UF NX = %b }",flags);
            busy = 0;
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

// Risc-V FPU STARTS HERE
// Uses float32 for actual floating point routines

// CONVERSION BETWEEN FLOAT AND SIGNED/UNSIGNED INTEGERS
algorithm floatconvert(
    input   uint1   start,
    output  uint1   busy(0),

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

    while(1) {
        if( start ) {
            busy = 1;
            flags = 0;

            switch( function7[2,5] ) {
                default: {
                    // FCVT.W.S FCVT.WU.S
                    result = rs2[0,1] ? FPUuint.result : FPUint.result; flags = rs2[0,1] ? FPUuint.flags : FPUint.flags;
                }
                case 5b11010: {
                    // FCVT.S.W FCVT.S.WU
                    FPUfloat.start = 1; while( FPUfloat.busy ) {} result = FPUfloat.result; flags = FPUfloat.flags;
                }
            }

            busy = 0;
        }
    }
}

// FPU CALCULATION BLOCKS FUSED ADD SUB MUL DIV SQRT
algorithm floatcalc(
    input   uint1   start,
    output  uint1   busy(0),

    input   uint7   opCode,
    input   uint7   function7,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    input   uint32  sourceReg3F,

    output  uint5   flags,
    output  uint32  result,
) <autorun> {
    floataddsub FPUaddsub();
    floatmultiply FPUmultiply( b <: sourceReg2F );
    floatdivide FPUdivide( a <: sourceReg1F, b <: sourceReg2F );
    floatsqrt FPUsqrt( a <: sourceReg1F );

    FPUaddsub.start := 0;
    FPUmultiply.start := 0;
    FPUdivide.start := 0;
    FPUsqrt.start := 0;

    while(1) {
        if( start ) {
            busy = 1;
            flags = 0;

            switch( opCode[2,5] ) {
                default: {
                    __display(" MULTIPLY STAGE");
                    FPUmultiply.a = { opCode[3,1] ? ~sourceReg1F[31,1] : sourceReg1F[31,1], sourceReg1F[0,31] };
                    FPUmultiply.start = 1; while( FPUmultiply.busy ) {} flags = FPUmultiply.flags & 5b10110;
                    __display("");
                    __display(" ADDITION/SUBTRACTION STAGE");
                    FPUaddsub.a = FPUmultiply.result; FPUaddsub.b = sourceReg3F; FPUaddsub.addsub = opCode[2,1];
                    FPUaddsub.start = 1; while( FPUaddsub.busy ) {} flags = flags | ( FPUaddsub.flags & 5b00110 );
                    result = FPUaddsub.result;
                }
                case 5b10100: {
                    // NON 3 REGISTER FPU OPERATIONS
                    switch( function7[2,5] ) {
                        default: {
                            __display("ADD (==0) SUB (==1) %b",function7[2,1]);
                            // FADD.S FSUB.S
                            FPUaddsub.a = sourceReg1F; FPUaddsub.b = sourceReg2F; FPUaddsub.addsub = function7[2,1]; FPUaddsub.start = 1; while( FPUaddsub.busy ) {}
                            result = FPUaddsub.result; flags = FPUaddsub.flags & 5b00110;
                        }
                        case 5b00010: {
                            __display("MUL");
                            // FMUL.S
                            FPUmultiply.a = sourceReg1F; FPUmultiply.start = 1; while( FPUmultiply.busy ) {}
                            result = FPUmultiply.result; flags = FPUmultiply.flags & 5b00110;
                        }
                        case 5b00011: {
                            __display("FDIV");
                            // FDIV.S
                            FPUdivide.start = 1; while( FPUdivide.busy ) {}
                            result = FPUdivide.result; flags = FPUdivide.flags & 5b01110;
                        }
                        case 5b01011: {
                            __display("FSQRT");
                            // FSQRT.S
                            FPUsqrt.start = 1; while( FPUsqrt.busy ) {}
                            result = FPUsqrt.result; flags = FPUsqrt.flags & 5b00110;
                        }
                    }
                }
            }
            busy = 0;
        }
    }
}

algorithm floatclassify(
    input   uint32  sourceReg1F,
    output  uint10  classification
) <autorun> {
    classify A( a <: sourceReg1F );

    always {
        switch( { A.INF, A.sNAN, A.qNAN, A.ZERO } ) {
            case 4b1000: { classification = floatingpointnumber( sourceReg1F ).sign ? 10b0000000001 : 10b0010000000; }
            case 4b0100: { classification = 10b0100000000; }
            case 4b0010: { classification = 10b1000000000; }
            case 4b0001: { classification = ( sourceReg1F[0,23] == 0 ) ? floatingpointnumber( sourceReg1F ).sign ? 10b0000001000 : 10b0000010000 :
                                                                            floatingpointnumber( sourceReg1F ).sign ? 10b0000000100 : 10b0000100000; }
            default: { classification = floatingpointnumber( sourceReg1F ).sign ? 10b0000000010 : 10b0001000000; }
        }
    }
}

algorithm floatminmax(
    input   uint3   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,

    output  uint5   flags,
    output  uint32  result
) <autorun> {
    uint1   less = uninitialised;
    classify A( a <: sourceReg1F ); classify B( a <: sourceReg2F );
    floatcompare FPUlteq( a <: sourceReg1F, b <: sourceReg2F, less :> less );

    always {
        switch( ( A.sNAN | B.sNAN ) | ( A.qNAN & B.qNAN ) ) {
            case 1: { flags = 5b10000; result = 32h7fc00000; } // sNAN or both qNAN
            case 0: {
                switch( function3[0,1] ) {
                    case 0: { result = A.qNAN ? ( B.qNAN ? 32h7fc00000 : sourceReg2F ) : B.qNAN ? sourceReg1F : ( less ? sourceReg1F : sourceReg2F); }
                    case 1: { result = A.qNAN ? ( B.qNAN ? 32h7fc00000 : sourceReg2F ) : B.qNAN ? sourceReg1F : ( less ? sourceReg2F : sourceReg1F); }
                }
            }
        }
    }
}

// COMPARISONS
algorithm floatcomparison(
    input   uint3   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,

    output  uint5   flags,
    output  uint1  result
) <autorun> {
    uint1   less = uninitialised;
    uint1   equal = uninitialised;
    classify A( a <: sourceReg1F ); classify B( a <: sourceReg2F );
    floatcompare FPUlteq( a <: sourceReg1F, b <: sourceReg2F, less :> less, equal :> equal );

    always {
        switch( function3 ) {
            case 3b000: { flags = ( A.qNAN | A.sNAN | B.qNAN | B.sNAN ) ? 5b10000 : 0; result = ( A.qNAN | A.sNAN | B.qNAN | B.sNAN ) ? 0 : less | equal; }
            case 3b001: { flags = ( A.qNAN | A.sNAN | B.qNAN | B.sNAN ) ? 5b10000 : 0; result = ( A.qNAN | A.sNAN | B.qNAN | B.sNAN ) ? 0 : less; }
            case 3b010: { flags = ( A.sNAN | B.sNAN ) ? 5b10000 : 0; result = ( A.qNAN | A.sNAN | B.qNAN | B.sNAN ) ? 0 : equal; }
            default: { result = 0; }
        }
    }
}

algorithm floatsign(
    input   uint3   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    output  uint32  result,
) <autorun> {
    result := { function3[1,1] ? sourceReg1F[31,1] ^ sourceReg2F[31,1] : function3[0,1] ? ~sourceReg2F[31,1] : sourceReg2F[31,1], sourceReg1F[0,31] };
}


// RISC-V FPU CONTROLLER

algorithm main(output int8 leds) {
    uint7   opCode = 7b1010011; // ALL OTHER FPU OPERATIONS
    // uint7   opCode = 7b1000011; // FMADD
    // uint7   opCode = 7b1000111; // FMSUB
    // uint7   opCode = 7b1001011; // FNMSUB
    // uint7   opCode = 7b1001111; // FNMADD

    uint7   function7 = 7b0001100; // OPERATION SWITCH
    // ADD = 7b0000000 SUB = 7b0000100 MUL = 7b0001000 DIV = 7b0001100 SQRT = 7b0101100
    // FSGNJ[N][X] = 7b0010000 function3 == 000 FSGNJ == 001 FSGNJN == 010 FSGNJX
    // MIN MAX = 7b0010100 function3 == 000 MIN == 001 MAX
    // FCVT.W[U].S floatto[u]int = 7b1100000 rs2 == 00000 FCVT.W.S == 00001 FCVT.WU.S
    // FCVT.S.W[U] [u]inttofloat = 7b1101000 rs2 == 00000 FCVT.S.W == 00001 FCVT.S.WU

    uint3   function3 = 3b000; // ROUNDING MODE OR SWITCH
    uint5   rs1 = 5b00000; // SOURCEREG1 number
    uint5   rs2 = 5b00000; // SOURCEREG2 number OR SWITCH

    uint32  sourceReg1 = 32h00000001; // INTEGER SOURCEREG1

    // -5 = 32hC0A00000
    // -0 = 32h80000000
    // 0 = 0
    // 0.85471 = 32h3F5ACE46
    // 1/3 = 32h3eaaaaab
    // 1 = 32h3F800000
    // 2 = 32h40000000
    // 3 = 32h40400000
    // 50 = 32h42480000
    // 99 = 32h42C60000
    // 100 = 32h42C80000
    // 2.658456E38 = 32h7F480000
    // NaN = 32hffffffff
    // qNaN = 32hffc00000
    // INF = 32h7F800000
    // -INF = 32hFF800000
    uint32  sourceReg1F = 32h40000000;
    uint32  sourceReg2F = 32h3F5ACE46;
    uint32  sourceReg3F = 32h3eaaaaab;

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

    FPUcalculator.start := 0; FPUconvert.start := 0;

    ++: // REQUIRED FOR VERILATOR TO ALLOW SIGNALS TO PROPAGATE
    ++:

    __display("");
    __display("RISC-V FPU SIMULATION");
    __display("");
    __display("I1 = %x -> { %b %b %b }",sourceReg1,sourceReg1[31,1],sourceReg1[23,8],sourceReg1[0,23]);
    __display("F1 = %x -> { %b %b %b }",sourceReg1F,sourceReg1F[31,1],sourceReg1F[23,8],sourceReg1F[0,23]);
    __display("F2 = %x -> { %b %b %b }",sourceReg2F,sourceReg2F[31,1],sourceReg2F[23,8],sourceReg2F[0,23]);
    __display("F3 = %x -> { %b %b %b }",sourceReg2F,sourceReg3F[31,1],sourceReg3F[23,8],sourceReg3F[0,23]);
    __display("OPCODE = %b FUNCTION7 = %b FUNCTION3 = %b RS1 = %b RS2 = %b",opCode, function7, function3, rs1, rs2);
    __display("");

    //while(1) {
        //if( start ) {
            //busy = 1;
            frd = 1;
            FPUnewflags = FPUflags;

            switch( opCode[2,5] ) {
                default: {
                    // FMADD.S FMSUB.S FNMSUB.S FNMADD.S
                    __display("FUSED OPERATION");
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
                            __display("SIGN MANIPULATION");
                            // FSGNJ.S FSGNJN.S FSGNJX.S
                            result = FPUsign.result;
                        }
                        case 5b00101: {
                            __display("MIN MAX");
                            // FMIN.S FMAX.S
                            result = FPUminmax.result;
                            FPUnewflags = FPUflags | FPUminmax.flags;
                        }
                        case 5b10100: {
                            __display("COMPARISON");
                            // FEQ.S FLT.S FLE.S
                            frd = 0; result = FPUcompare.result;
                            FPUnewflags = FPUflags | FPUcompare.flags;
                        }
                        case 5b11000: {
                            __display("CONVERSION FLOAT TO INT");
                            // FCVT.W.S FCVT.WU.S
                            frd = 0; FPUconvert.start = 1; while( FPUconvert.busy ) {} result = FPUconvert.result;
                            FPUnewflags = FPUflags | FPUconvert.flags;
                        }
                        case 5b11010: {
                            __display("CONVERSION INT TO FLOAT");
                            // FCVT.S.W FCVT.S.WU
                            FPUconvert.start = 1; while( FPUconvert.busy ) {} result = FPUconvert.result;
                            FPUnewflags = FPUflags | FPUconvert.flags;
                        }
                        case 5b11100: {
                            __display("CLASSIFY or MOVE BITMAP FROM FLOAT TO INT");
                            // FCLASS.S FMV.X.W
                            frd = 0; result = function3[0,1] ? FPUclass.classification : sourceReg1F;
                        }
                        case 5b11110: {
                            __display("MOVE BITMAP FROM INT TO FLOAT");
                            // FMV.W.X
                            result = sourceReg1;
                        }
                    }
                }
            }

            __display("");
            __display("FRD = %b RESULT = %x -> { %b %b %b }",frd,result,result[31,1],result[23,8],result[0,23]);
            __display("FLAGS = { %b }",FPUnewflags);
            __display("");
            //busy = 0;
        //}
    //}
}
