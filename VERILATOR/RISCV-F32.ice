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
// NORMALISE A 48 BIT MANTISSA SO THAT THE MSB IS ONE
// FOR ADDSUB ALSO DECREMENT THE EXPONENT FOR EACH SHIFT LEFT
algorithm donormalise48(
    input   uint1   start,
    output  uint1   busy(0),
    input   int10   exp,
    input   uint48  bitstream,
    output  int10   newexp,
    output  uint48  normalised
) <autorun> {
    uint4   shiftcount <:: { normalised[33,15] == 0, normalised[41,7] == 0, normalised[45,3] == 0, 1b1 };
    while(1) {
        if( start ) {
            __display("  NORMALISING THE RESULT MANTISSA, ADJUSTING EXPONENT FOR ADDSUB");
            busy = 1;
            normalised = bitstream; newexp = exp;
            __display("  { x %b %b } (ALREADY NORMALISED == %b)",newexp,normalised,normalised[47,1]);
            // NORMALISE BY SHIFT 1, 3, 7 OR 15 ZEROS LEFT
            while( ~normalised[47,1] ) {
                normalised = normalised << shiftcount; newexp = newexp - shiftcount;
                __display("  { x %b %b } AFTER SHIFT LEFT %d",newexp,normalised,shiftcount);
            }
            busy = 0;
        }
    }
}

// EXTRACT 23 BIT FRACTION FROM LEFT ALIGNED 48 BIT FRACTION WITH ROUNDING
// ADJUST EXPONENT IF ROUNDING FORCES
algorithm doround48(
    input   uint48  bitstream,
    input   int10   exponent,
    output  uint23  roundfraction,
    output  int10   newexponent
) <autorun> {
    always {
        roundfraction = bitstream[24,23] + bitstream[23,1];
        newexponent = 127 + exponent + ( ( roundfraction == 0 ) & bitstream[23,1] );
    }
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
    uint1   OF = uninitialised; uint1 UF = uninitialised; uint1 NX = uninitialised;
    uint1   sign <: dounsigned ? 0 : a[31,1];
    uint8   zeros = uninitialised;
    uint32  number <: dounsigned ? a : ( a[31,1] ? -a : a );
    uint32  fraction <: NX ? number >> ( 8 - zeros ) : ( zeros > 8 ) ? number << ( zeros - 8 ) : number;
    int10   exponent <: 158 - zeros;

    uint1   cOF = uninitialised;
    uint1   cUF = uninitialised;
    uint32  f32 = uninitialised;
    docombinecomponents32 COMBINE(
        sign <: sign,
        exp <: exponent,
        fraction <: fraction,
        OF :> cOF,
        UF :> cUF,
        f32 :> f32
    );
    flags := { 4b0, OF, UF, NX };

    while(1) {
        if( start ) {
            busy = 1;
            OF = 0; UF = 0; NX = 0;
            switch( number ) {
                case 0: { result = 0; }
                default: {
                    // CHECK FOR 24, 16 OR 8 LEADING ZEROS, CONTINUE COUNTING FROM THERE
                    __display("  i = { %b %b } = %d",sign,number,number);
                    zeros = number[8,24] == 0 ? 24 : number[16,16] == 0 ? 16 : number[24,8] == 0 ? 8 : 0;
                    __display("  STARTING AT %d LEADING ZEROS",zeros);
                    while( ~number[31-zeros,1] ) { zeros = zeros + 1; } NX = ( zeros < 8 );
                    __display("  LEADING ZEROS = %d",zeros);
                    __display("");
                    ++:
                    OF = cOF; UF = cUF; result = f32;
                }
            }
            __display("  { %b %b %b }",result[31,1],result[23,8],result[0,23]);
            __display("  { IF NN NV DZ OF UF NX = %b }",flags);
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
    int10   exp <: floatingpointnumber( a ).exponent - 127;
    uint33  sig = uninitialised;
    uint1   IF <: aINF;
    uint1   NN <: asNAN | aqNAN;
    uint1   NV = uninitialised;

    uint1   aINF = uninitialised;
    uint1   asNAN = uninitialised;
    uint1   aqNAN = uninitialised;
    uint1   aZERO = uninitialised;
    classify A(
        a <: a,
        INF :> aINF,
        sNAN :> asNAN,
        qNAN :> aqNAN,
        ZERO :> aZERO
    );

    flags := { IF, NN, NV, 4b0000 };

    always {
        NV = 0;
        switch( { IF | NN, aZERO } ) {
            case 2b00: {
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
    int10   exp <: floatingpointnumber( a ).exponent - 127;
    uint33  sig = uninitialised;
    uint1   IF <: aINF;
    uint1   NN <: asNAN | aqNAN;
    uint1   NV = uninitialised;

    uint1   aINF = uninitialised;
    uint1   asNAN = uninitialised;
    uint1   aqNAN = uninitialised;
    uint1   aZERO = uninitialised;
    classify A(
        a <: a,
        INF :> aINF,
        sNAN :> asNAN,
        qNAN :> aqNAN,
        ZERO :> aZERO
    );

    flags := { IF, NN, NV, 4b0000 };

    always {
        NV = 0;
        switch( { IF | NN, aZERO } ) {
            case 2b00: {
                switch( floatingpointnumber( a ).sign ) {
                    case 1: { result = 0; }
                    default: {
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

// ADDSUB ADD/SUBTRACT ( addsub == 0 add, == 1 subtract) TWO FLOATING POINT NUMBERS
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
        // EQUALISE THE EXPONENTS BY SHIFT SMALLER NUMBER FRACTION PART TO THE RIGHT
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

algorithm floataddsub(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint32  a,
    input   uint32  b,
    input   uint1   addsub,
    output  uint7   flags,
    output  uint32  result
) <autorun> {
    // BREAK DOWN INITIAL float32 INPUTS - SWITCH SIGN OF B IF SUBTRACTION
    uint1   signA <: a[31,1];
    int10   expA <: floatingpointnumber( a ).exponent - 127;
    uint48  sigA <: { 2b01, floatingpointnumber(a).fraction, 23b0 };
    uint1   signB <: addsub ? ~b[31,1] : b[31,1];
    int10   expB <: floatingpointnumber( b ).exponent - 127;
    uint48  sigB <: { 2b01, floatingpointnumber(b).fraction, 23b0 };

    // CLASSIFY THE INPUTS AND FLAG INFINITY, NAN, ZERO AND INVALID ( INF - INF )
    uint1   IF <: ( aINF | bINF );
    uint1   NN <: ( asNAN | aqNAN | bsNAN | bqNAN );
    uint1   NV <: ( aINF & bINF) & ( signA != signB );
    uint1   OF = uninitialised;
    uint1   UF = uninitialised;

    uint1   aINF = uninitialised;
    uint1   asNAN = uninitialised;
    uint1   aqNAN = uninitialised;
    uint1   aZERO = uninitialised;
    classify A(
        a <: a,
        INF :> aINF,
        sNAN :> asNAN,
        qNAN :> aqNAN,
        ZERO :> aZERO
    );
    uint1   bINF = uninitialised;
    uint1   bsNAN = uninitialised;
    uint1   bqNAN = uninitialised;
    uint1   bZERO = uninitialised;
    classify B(
        a <: b,
        INF :> bINF,
        sNAN :> bsNAN,
        qNAN :> bqNAN,
        ZERO :> bZERO
    );

    // EQUALISE THE EXPONENTS
    int10   eqexpA = uninitialised;
    uint48  eqsigA = uninitialised;
    int10   eqexpB = uninitialised;
    uint48  eqsigB = uninitialised;
    equaliseexpaddsub EQUALISEEXP(
        expA <: expA,
        sigA <: sigA,
        expB <: expB,
        sigB <: sigB,
        newexpA :> eqexpA,
        newsigA :> eqsigA,
        newexpB :> eqexpB,
        newsigB :> eqsigB
    );

    // PERFORM THE ADDITION/SUBTRACION USING THE EQUALISED FRACTIONS, 1 IS ADDED TO THE EXPONENT IN CASE OF OVERFLOW - NORMALISING WILL ADJUST WHEN SHIFTING
    uint1   resultsign = uninitialised;
    int10   resultexp <: eqexpA + 1;
    uint48  resultfraction = uninitialised;
    dofloataddsub ADDSUB(
        signA <: signA,
        sigA <: eqsigA,
        signB <: signB,
        sigB <: eqsigB,
        resultsign :> resultsign,
        resultfraction :> resultfraction
    );

    // NORMALISE THE RESULTING FRACTION AND ADJUST THE EXPONENT IF SMALLER ( ie, MSB is not 1 )
    int10   normalexp = uninitialised;
    uint48  normalfraction = uninitialised;
    donormalise48 NORMALISE(
        exp <: resultexp,
        bitstream <: resultfraction,
        newexp :> normalexp,
        normalised :> normalfraction
    );

    // ROUND THE NORMALISED FRACTION AND ADJUST EXPONENT IF OVERFLOW
    int10   roundexponent = uninitialised;
    uint48  roundfraction = uninitialised;
    doround48 ROUND(
        exponent <: normalexp,
        bitstream <: normalfraction,
        newexponent :> roundexponent,
        roundfraction :> roundfraction
    );

    // COMBINE TO FINAL float32
    uint1   cOF = uninitialised;
    uint1   cUF = uninitialised;
    uint32  f32 = uninitialised;
    docombinecomponents32 COMBINE(
        sign <: resultsign,
        exp <: roundexponent,
        fraction <: roundfraction,
        OF :> cOF,
        UF :> cUF,
        f32 :> f32
    );

    NORMALISE.start := 0;
    flags := { IF, NN, NV, 1b0, OF, UF, 1b0 };

    while(1) {
        if( start ) {
            busy = 1;
            OF = 0; UF = 0;
            ++: // ALLOW 2 CYCLES FOR EQUALISING EXPONENTS AND TO PERFORM THE ADDITION/SUBTRACTION
            ++:
            __display("");
            __display("  a = { %b %b %b } INPUT",floatingpointnumber( a ).sign,floatingpointnumber( a ).exponent,floatingpointnumber( a ).fraction);
            __display("  b = { %b %b %b } INPUT",floatingpointnumber( b ).sign,floatingpointnumber( b ).exponent,floatingpointnumber( b ).fraction);
            __display("  IF = %b NN = %b",IF,NN);
            __display("");
            __display("  IF SUBTRACTION SWITCH SIGN OF B FROM %b TO %b",b[31,1],signB);
            __display("  ADD HIDDEN 1 TO MANTISSA AND EXPAND TO 48 BITS, ALIGNED AT BIT 46, REMOVE BIAS FROM EXPONENT AND EXTEND TO 10 BITS");
            __display("  a = { %b %10b %48b }",signA,expA,sigA);
            __display("  b = { %b %10b %48b }",signB,expB,sigB);
            __display("");
            __display("  EQUALISE EXPONENTS (SHIFTING MANTISSA)");
            __display("  a = { %b %b %b }",signA,eqexpA,eqsigA);
            __display("  b = { %b %b %b }",signB,eqexpB,eqsigB);
            __display("");
            __display("  CALCULATING");
            __display("  { %b %b %b } +",signA,eqexpA,eqsigA);
            __display("  { %b %b %b }",signB,eqexpB,eqsigB);
            __display(" ={ %b %b %b }",resultsign,resultexp,resultfraction);
            __display("");
            switch( { IF | NN, aZERO | bZERO } ) {
                case 2b00: {
                    switch( ADDSUB.resultfraction ) {
                        case 0: { result = 0; }
                        default: {
                            NORMALISE.start = 1; while( NORMALISE.busy ) {}
                            __display("");
                            __display("  ADD BIAS TO EXPONENT, ROUND AND TRUNCATE MANTISSA");
                            __display("  { %b %b %b } (ROUND BIT = %b)",resultsign,roundexponent,roundfraction,normalfraction[23,1]);
                            OF = cOF; UF = cUF; result = f32;
                            __display("");
                            __display("  TRUNCATE EXP AND COMBINE TO FINAL RESULT");
                        }
                    }
                }
                case 2b01: {
                    result = ( aZERO & bZERO ) ? 0 : ( bZERO ) ? a : addsub ? { ~floatingpointnumber( b ).sign, b[0,31] } : b;
                    __display("");
                    __display("  ZERO AS INPUT");
                    __display("  SELECT FINAL RESULT");
                }
                default: {
                    __display("");
                    __display("  INF OR NAN AS INPUT");
                    __display("  SELECT FINAL RESULT");
                    switch( { IF, NN } ) {
                        case 2b10: { result = ( aINF & bINF) ? ( signA == signB ) ? a : 32hffc00000 : aINF ? a : b; }
                        default: { result = 32hffc00000; }
                    }
                }
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
    // BREAK DOWN INITIAL float32 INPUTS AND FIND SIGN OF RESULT AND EXPONENT OF PRODUCT ( + 1 IF PRODUCT OVERFLOWS, MSB == 1 )
    uint1   productsign <: floatingpointnumber( a ).sign ^ floatingpointnumber( b ).sign;
    int10   productexp <: (floatingpointnumber( a ).exponent - 127) + (floatingpointnumber( b ).exponent - 127) + product[47,1];
    int10   expA <: floatingpointnumber( a ).exponent - 127;
    uint24  sigA <: { 1b1, floatingpointnumber( a ).fraction };
    int10   expB <: floatingpointnumber( b ).exponent - 127;
    uint24  sigB <: { 1b1, floatingpointnumber( b ).fraction };

    // CLASSIFY THE INPUTS AND FLAG INFINITY, NAN, ZERO AND INVALID ( INF x ZERO )
    uint1   IF <: ( aINF | bINF );
    uint1   NN <: ( asNAN | aqNAN | bsNAN | bqNAN );
    uint1   NV <: ( aINF | bINF ) & ( aZERO | bZERO );
    uint1   OF = uninitialised;
    uint1   UF = uninitialised;

    uint1   aINF = uninitialised;
    uint1   asNAN = uninitialised;
    uint1   aqNAN = uninitialised;
    uint1   aZERO = uninitialised;
    classify A(
        a <: a,
        INF :> aINF,
        sNAN :> asNAN,
        qNAN :> aqNAN,
        ZERO :> aZERO
    );
    uint1   bINF = uninitialised;
    uint1   bsNAN = uninitialised;
    uint1   bqNAN = uninitialised;
    uint1   bZERO = uninitialised;
    classify B(
        a <: b,
        INF :> bINF,
        sNAN :> bsNAN,
        qNAN :> bqNAN,
        ZERO :> bZERO
    );

    uint48  product = uninitialised;
    dofloatmul UINTMUL(
        factor_1 <: sigA,
        factor_2 <: sigB,
        product :> product
    );

    uint48  normalfraction = uninitialised;
    donormalise48 NORMALISE(
        bitstream <: product,
        normalised :> normalfraction
    );

    int10   roundexponent = uninitialised;
    uint48  roundfraction = uninitialised;
    doround48 ROUND(
        exponent <: productexp,
        bitstream <: normalfraction,
        newexponent :> roundexponent,
        roundfraction :> roundfraction
    );

    // COMBINE TO FINAL float32
    uint1   cOF = uninitialised;
    uint1   cUF = uninitialised;
    uint32  f32 = uninitialised;
    docombinecomponents32 COMBINE(
        sign <: productsign,
        exp <: roundexponent,
        fraction <: roundfraction,
        OF :> cOF,
        UF :> cUF,
        f32 :> f32
    );

    NORMALISE.start := 0;
    flags := { IF, NN, NV, 1b0, OF, UF, 1b0 };

    while(1) {
        if( start ) {
            busy = 1;
            OF = 0; UF = 0;
            ++: // ALLOW 1 CYLE TO PERFORM THE MULTIPLICATION
            __display("");
            __display("  a = { %b %b %b } INPUT",a[31,1],a[23,8],a[0,23]);
            __display("  b = { %b %b %b } INPUT",b[31,1],b[23,8],b[0,23]);
            __display("  IF = %b NN = %b NV = %b",IF,NN,NV);
            __display("");
            __display("  CALCULATING, ADDING EXPONENTS AFTER REMOVING BIAS");
            __display("  { %b %b %b } x",a[31,1],expA,sigA);
            __display("  { %b %b %b }",b[31,1],expB,sigB);
            __display(" ={ %b %b %b }",productsign,productexp,product);
            __display("");
            switch( { IF | NN, aZERO | bZERO } ) {
                case 2b00: {
                    // STEPS: SETUP -> DOMUL -> NORMALISE -> ROUND -> ADJUSTEXP -> COMBINE
                    NORMALISE.start = 1; while( NORMALISE.busy ) {}
                    __display("");
                    __display("  ADD BIAS TO EXPONENT, ROUND AND TRUNCATE MANTISSA");
                    __display("  %b %b (ROUND BIT = %b) (LARGE RESULT + 1 TO EXPONENT = %b)",roundexponent,roundfraction,normalfraction[23,1],product[47,1]);
                    OF = cOF; UF = cUF; result = f32;
                    __display("");
                    __display("  TRUNCATE EXP AND COMBINE TO FINAL RESULT");
                }
                case 2b01: {
                    __display("");
                    __display("  ZERO AS INPUT");
                    __display("  SELECT FINAL RESULT");
                    result = { productsign, 31b0 };
                }
                default: {
                    __display("");
                    __display("  INF OR NAN AS INPUT");
                    __display("  SELECT FINAL RESULT");
                    switch( { IF, aZERO | bZERO } ) {
                        case 2b11: { result = 32hffc00000; }
                        case 2b10: { result = NN ? 32hffc00000 : { productsign, 8b11111111, 23b0 }; }
                        default: { result = 32hffc00000; }
                    }
                }
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
    uint50  remainder <: start ? 0 : newremainder;
    uint50  newquotient = uninitialised;
    uint59  newremainder = uninitialised;
    dofloatdivbit DIVBIT(
        quotient <: quotient,
        remainder <: remainder,
        top <: sigA,
        bottom <: sigB,
        bit <: bit,
        newquotient :> newquotient,
        newremainder :> newremainder
    );
    uint6   bit(63);

    busy := start | ( bit != 63 ) | ( quotient[48,2] != 0 );
    while(1) {
        // FIND QUOTIENT AND ENSURE 48 BIT FRACTION ( ie BITS 48 and 49 clear )
        if( start ) {
            bit = 49; quotient = 0; while( bit != 63 ) { quotient = newquotient; bit = bit - 1; } while( quotient[48,2] != 0 ) { quotient = quotient >> 1; }
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
    // BREAK DOWN INITIAL float32 INPUTS AND FIND SIGN OF RESULT AND EXPONENT OF QUOTIENT ( -1 IF DIVISOR > DIVIDEND )
    uint1   quotientsign <: floatingpointnumber( a ).sign ^ floatingpointnumber( b ).sign;
    int10   quotientexp <: ((floatingpointnumber( a ).exponent - 127) - (floatingpointnumber( b ).exponent - 127)) - ( floatingpointnumber(b).fraction > floatingpointnumber(a).fraction );
    uint50  sigA <: { 1b1, floatingpointnumber(a).fraction, 26b0 };
    uint50  sigB <: { 27b1, floatingpointnumber(b).fraction };

    // CLASSIFY THE INPUTS AND FLAG INFINITY, NAN, ZERO AND DIVIDE ZERO
    uint1   IF <: ( aINF | bINF );
    uint1   NN <: ( asNAN | aqNAN | bsNAN | bqNAN );
    uint1   NV = uninitialised;
    uint1   DZ <: bZERO;
    uint1   OF = uninitialised;
    uint1   UF = uninitialised;

    uint1   aINF = uninitialised;
    uint1   asNAN = uninitialised;
    uint1   aqNAN = uninitialised;
    uint1   aZERO = uninitialised;
    classify A(
        a <: a,
        INF :> aINF,
        sNAN :> asNAN,
        qNAN :> aqNAN,
        ZERO :> aZERO
    );
    uint1   bINF = uninitialised;
    uint1   bsNAN = uninitialised;
    uint1   bqNAN = uninitialised;
    uint1   bZERO = uninitialised;
    classify B(
        a <: b,
        INF :> bINF,
        sNAN :> bsNAN,
        qNAN :> bqNAN,
        ZERO :> bZERO
    );

    uint48  quotient = uninitialised;
    dofloatdivide DODIVIDE(
        sigA <: sigA,
        sigB <: sigB,
        quotient :> quotient
    );

    uint48  normalfraction = uninitialised;
    donormalise48 NORMALISE(
        bitstream <: quotient,
        normalised :> normalfraction
    );

    int10   roundexponent = uninitialised;
    uint48  roundfraction = uninitialised;
    doround48 ROUND(
        exponent <: quotientexp,
        bitstream <: normalfraction,
        newexponent :> roundexponent,
        roundfraction :> roundfraction
    );

    // COMBINE TO FINAL float32
    uint1   cOF = uninitialised;
    uint1   cUF = uninitialised;
    uint32  f32 = uninitialised;
    docombinecomponents32 COMBINE(
        sign <: quotientsign,
        exp <: roundexponent,
        fraction <: roundfraction,
        OF :> cOF,
        UF :> cUF,
        f32 :> f32
    );

    DODIVIDE.start := 0; NORMALISE.start := 0;
    flags := { IF, NN, 1b0, DZ, OF, UF, 1b0};

    while(1) {
        if( start ) {
            busy = 1;
            OF = 0; UF = 0;
            __display("");
            __display("  a = { %b %b %b } INPUT",a[31,1],a[23,8],a[0,23]);
            __display("  b = { %b %b %b } INPUT",b[31,1],b[23,8],b[0,23]);
            __display("  IF = %b NN = %b DZ = %b",IF,NN,DZ);
            __display("");
            __display("  CALCULATING");
            __display("  ALIGN DIVIDEND TO LEFT, DIVISOR TO THE RIGHT");
            __display("  SUBTRACTING EXPONENTS AFTER REMOVING BIAS");
            __display("  { %b %b %b } /",a[31,1],floatingpointnumber( a ).exponent - 127,sigA);
            __display("  { %b %b %b }",b[31,1],floatingpointnumber( b ).exponent - 127,sigB);
            __display(" ={ %b %b %b }",quotientsign,quotientexp,quotient);
            __display("");
            switch( { IF | NN, aZERO | bZERO } ) {
                case 2b00: {
                    DODIVIDE.start = 1; while( DODIVIDE.busy ) {}
                    switch( quotient ) {
                        case 0: {
                            result = { quotientsign, 31b0 };
                            __display(" ={ 0 }");
                        }
                        default: {
                            NORMALISE.start = 1; while( NORMALISE.busy ) {}
                            __display("");
                            __display("  ADD BIAS TO EXPONENT, ROUND AND TRUNCATE MANTISSA");
                            __display("  %b %b (ROUND BIT = %b) (DIVISOR SMALLER THAN DIVIDEND -1 FROM EXPONENT == %b)",roundexponent,roundfraction,normalfraction[23,1],( floatingpointnumber(b).fraction > floatingpointnumber(a).fraction ));
                            OF = cOF; UF = cUF; result = f32;
                            __display("");
                            __display("  TRUNCATE EXP AND COMBINE TO FINAL RESULT");
                        }
                    }
                }
                case 2b01: {
                    result = ( aZERO & bZERO ) ? 32hffc00000 : ( bZERO ) ? { quotientsign, 8b11111111, 23b0 } : { quotientsign, 31b0 };
                    __display("");
                    __display("  ZERO AS INPUT");
                    __display("  SELECT FINAL RESULT");
                }
                default: {
                    result = ( aINF &bINF ) | NN | bZERO ? 32hffc00000 : aZERO | bINF ? { quotientsign, 31b0 } : { quotientsign, 8b11111111, 23b0 };
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
    uint50  test_res = uninitialised;
    always {
        test_res = ac - { q, 2b01 };
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
    uint50  ac <: start ? start_ac : newac;
    uint48  x <:  start ? start_x : newx;
    uint50  newac = uninitialised;
    uint48  newq = uninitialised;
    uint48  newx = uninitialised;
    dofloatsqrtbitt SQRTBIT( ac <: ac, x <: x, q <: q, newac :> newac, newx :> newx, newq :> newq );

    uint6   i(47);
    busy := start | ( i != 47 );
    while(1) {
        if( start ) {
            i = 0; q = 0; while( i != 47 ) { q = newq; i = i + 1; }
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

    // CLASSIFY THE INPUTS AND FLAG INFINITY, NAN, ZERO AND NOT VALID
    uint1   IF <: aINF;
    uint1   NN <: asNAN | aqNAN;
    uint1   NV <: IF | NN | sign;
    uint1   OF = uninitialised;
    uint1   UF = uninitialised;

    uint1   aINF = uninitialised;
    uint1   asNAN = uninitialised;
    uint1   aqNAN = uninitialised;
    uint1   aZERO = uninitialised;
    classify A(
        a <: a,
        INF :> aINF,
        sNAN :> asNAN,
        qNAN :> aqNAN,
        ZERO :> aZERO
    );

    // SQUARE ROOT EXPONENT IS HALF OF INPUT EXPONENT
    uint50  start_ac <: ~exp[0,1] ? 1 : { 48b0, 1b1, a[22,1] };
    uint48  start_x <: ~exp[0,1] ? { floatingpointnumber( a ).fraction, 25b0 } : { a[0,22], 26b0 };
    uint48  squareroot = uninitialised;
    int10   squarerootexp <: ( exp >>> 1 );
    dofloatsqrt DOSQRT(
        start_ac <: start_ac,
        start_x <: start_x,
        q :> squareroot
    );

    uint48  normalfraction = uninitialised;
    donormalise48 NORMALISE(
        bitstream <: squareroot,
        normalised :> normalfraction
    );

    int10   roundexponent = uninitialised;
    uint48  roundfraction = uninitialised;
    doround48 ROUND(
        exponent <: squarerootexp,
        bitstream <: normalfraction,
        newexponent :> roundexponent,
        roundfraction :> roundfraction
    );

    // COMBINE TO FINAL float32
    uint1   cOF = uninitialised;
    uint1   cUF = uninitialised;
    uint32  f32 = uninitialised;
    docombinecomponents32 COMBINE(
        sign <: sign,
        exp <: roundexponent,
        fraction <: roundfraction,
        OF :> cOF,
        UF :> cUF,
        f32 :> f32
    );

    DOSQRT.start := 0; NORMALISE.start := 0;
    flags := { IF, NN, NV, 1b0, OF, UF, 1b0 };

    while(1) {
        if( start ) {
            busy = 1;
            OF = 0; UF = 0;
            __display("");
            __display("  a = { %b %b %b } INPUT",a[31,1],a[23,8],a[0,23]);
            __display("  IF = %b NN = %b NV = %b",IF,NN,NV);
            __display("");
            switch( { IF | NN, aZERO } ) {
                case 2b00: {
                    switch( sign ) {
                        // DETECT NEGATIVE -> qNAN
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
                            __display("  AC = { %b }",start_ac);
                            __display("  X  = { %b }",start_x);
                            DOSQRT.start = 1; while( DOSQRT.busy ) {}
                            __display("");
                            __display("  HALVE THE EXPONENT");
                            __display(" ={ 0 %b %b }",squarerootexp,squareroot);
                            __display("");
                            NORMALISE.start = 1; while( NORMALISE.busy ) {}
                            __display("");
                            __display("  ADD BIAS TO EXPONENT, ROUND AND TRUNCATE MANTISSA");
                            __display("  %b %b (ROUND BIT = %b)",roundexponent,roundfraction,normalfraction[23,1]);
                            OF = cOF; UF = cUF; result = f32;
                            __display("");
                            __display("  TRUNCATE EXP AND COMBINE TO FINAL RESULT");
                        }
                    }
                }
                // DETECT sNAN, qNAN, -INF, -0 -> qNAN AND  INF -> INF, 0 -> 0
                default: {
                    result = sign ? 32hffc00000 : a;
                    __display("");
                    __display("  INF, NAN OR ZERO AS INPUT");
                    __display("  SELECT FINAL RESULT");
                }
            }
            busy = 0;
            __display("  { %b %b %b }",result[31,1],result[23,8],result[0,23]);
            __display("  { IF NN NV DZ OF UF NX = %b }",flags);
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
    uint1   aINF = uninitialised;
    uint1   asNAN = uninitialised;
    uint1   aqNAN = uninitialised;
    uint1   aZERO = uninitialised;
    classify A(
        a <: a,
        INF :> aINF,
        sNAN :> asNAN,
        qNAN :> aqNAN,
        ZERO :> aZERO
    );
    uint1   bINF = uninitialised;
    uint1   bsNAN = uninitialised;
    uint1   bqNAN = uninitialised;
    uint1   bZERO = uninitialised;
    classify B(
        a <: b,
        INF :> bINF,
        sNAN :> bsNAN,
        qNAN :> bqNAN,
        ZERO :> bZERO
    );

    // IDENTIFY NaN, RETURN 0 IF NAN, OTHERWISE RESULT OF COMPARISONS
    flags := { aINF | bINF, asNAN | bsNAN | aqNAN | bqNAN, asNAN | bsNAN | aqNAN | bqNAN, 4b0000 };
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
    uint1   dounsigned <: rs2[0,1];
    uint32  floatresult = uninitialised;
    uint5   floatflags = uninitialised;
    inttofloat FPUfloat( a <: sourceReg1, dounsigned <: dounsigned, result :> floatresult, flags :> floatflags );

    int32   intresult = uninitialised;
    uint5   intflags = uninitialised;
    floattoint FPUint( a <: sourceReg1F, result :> intresult, flags :> intflags );

    uint32  uintresult = uninitialised;
    uint5   uintflags = uninitialised;
    floattouint FPUuint( a <: sourceReg1F, result :> uintresult, flags :> uintflags );

    FPUfloat.start := 0;

    while(1) {
        if( start ) {
            busy = 1;
            flags = 0;
            switch( function7[2,5] ) {
                default: {
                    // FCVT.W.S FCVT.WU.S
                    result = rs2[0,1] ? uintresult : intresult; flags = rs2[0,1] ? uintflags : intflags;
                }
                case 5b11010: {
                    // FCVT.S.W FCVT.S.WU
                    FPUfloat.start = 1; while( FPUfloat.busy ) {} result = floatresult; flags = floatflags;
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
    uint1   addsub = uninitialised;
    uint32  addsourceReg1F = uninitialised;
    uint32  addsourceReg2F = uninitialised;
    uint32  addsubresult = uninitialised;
    uint5   addsubflags = uninitialised;
    floataddsub FPUaddsub( a <: addsourceReg1F, b <: addsourceReg2F, addsub <: addsub, result :> addsubresult, flags :> addsubflags );

    uint32  mulsourceReg1F = uninitialised;
    uint32  multiplyresult = uninitialised;
    uint5   multiplyflags = uninitialised;
    floatmultiply FPUmultiply( a <: mulsourceReg1F, b <: sourceReg2F, result :> multiplyresult, flags :> multiplyflags );

    uint32  divideresult = uninitialised;
    uint5   divideflags = uninitialised;
    floatdivide FPUdivide( a <: sourceReg1F, b <: sourceReg2F, result :> divideresult, flags :> divideflags );

    uint32  sqrtresult = uninitialised;
    uint5   sqrtflags = uninitialised;
    floatsqrt FPUsqrt( a <: sourceReg1F, result :> sqrtresult, flags :> sqrtflags );

    FPUaddsub.start := 0; FPUmultiply.start := 0; FPUdivide.start := 0; FPUsqrt.start := 0;

    while(1) {
        if( start ) {
            busy = 1;
            flags = 0;
            switch( opCode[2,5] ) {
                default: {
                    // 3 REGISTER FUSED FPU OPERATIONS
                    mulsourceReg1F = { opCode[3,1] ? ~sourceReg1F[31,1] : sourceReg1F[31,1], sourceReg1F[0,31] };
                    FPUmultiply.start = 1; while( FPUmultiply.busy ) {} flags = multiplyflags & 5b10110;
                    addsourceReg1F = multiplyresult; addsourceReg2F = sourceReg3F; addsub = opCode[2,1];
                    FPUaddsub.start = 1; while( FPUaddsub.busy ) {} result = addsubresult; flags = flags | ( addsubflags & 5b00110 );
                }
                case 5b10100: {
                    // NON 3 REGISTER FPU OPERATIONS
                    switch( function7[2,5] ) {
                        default: {
                            // FADD.S FSUB.S
                            addsourceReg1F = sourceReg1F; addsourceReg2F = sourceReg2F; addsub = function7[2,1];FPUaddsub.start = 1; while( FPUaddsub.busy ) {} result = addsubresult; flags = addsubflags & 5b00110;
                        }
                        case 5b00010: {
                            // FMUL.S
                            mulsourceReg1F = sourceReg1F; FPUmultiply.start = 1; while( FPUmultiply.busy ) {} result = multiplyresult; flags = multiplyflags & 5b00110;
                        }
                        case 5b00011: {
                            // FDIV.S
                            FPUdivide.start = 1; while( FPUdivide.busy ) {} result = divideresult; flags = divideflags & 5b01110;
                        }
                        case 5b01011: {
                            // FSQRT.S
                            FPUsqrt.start = 1; while( FPUsqrt.busy ) {} result = sqrtresult; flags = sqrtflags & 5b00110;
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
    // CLASSIFY THE INPUTS AND FLAG INFINITY, NAN, ZERO
    uint1   aINF = uninitialised;
    uint1   asNAN = uninitialised;
    uint1   aqNAN = uninitialised;
    uint1   aZERO = uninitialised;
    classify A(
        a <: sourceReg1F,
        INF :> aINF,
        sNAN :> asNAN,
        qNAN :> aqNAN,
        ZERO :> aZERO
    );

    always {
        switch( { aINF, asNAN, aqNAN, aZERO } ) {
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
    // CLASSIFY THE INPUTS AND FLAG INFINITY, NAN
    uint1   aINF = uninitialised;
    uint1   asNAN = uninitialised;
    uint1   aqNAN = uninitialised;
    classify A(
        a <: sourceReg1F,
        INF :> aINF,
        sNAN :> asNAN,
        qNAN :> aqNAN
    );
    uint1   bINF = uninitialised;
    uint1   bsNAN = uninitialised;
    uint1   bqNAN = uninitialised;
    classify B(
        a <: sourceReg2F,
        INF :> bINF,
        sNAN :> bsNAN,
        qNAN :> bqNAN
    );

    uint1   less = uninitialised;
    floatcompare FPUlteq( a <: sourceReg1F, b <: sourceReg2F, less :> less );

    always {
        switch( ( asNAN | bsNAN ) | ( aqNAN & bqNAN ) ) {
            case 1: { flags = 5b10000; result = 32h7fc00000; } // sNAN or both qNAN
            case 0: {
                switch( function3[0,1] ) {
                    case 0: { result = aqNAN ? ( bqNAN ? 32h7fc00000 : sourceReg2F ) : bqNAN ? sourceReg1F : ( less ? sourceReg1F : sourceReg2F); }
                    case 1: { result = aqNAN ? ( bqNAN ? 32h7fc00000 : sourceReg2F ) : bqNAN ? sourceReg1F : ( less ? sourceReg2F : sourceReg1F); }
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
    // CLASSIFY THE INPUTS AND FLAG INFINITY, NAN
    uint1   aINF = uninitialised;
    uint1   asNAN = uninitialised;
    uint1   aqNAN = uninitialised;
    classify A(
        a <: sourceReg1F,
        INF :> aINF,
        sNAN :> asNAN,
        qNAN :> aqNAN
    );
    uint1   bINF = uninitialised;
    uint1   bsNAN = uninitialised;
    uint1   bqNAN = uninitialised;
    classify B(
        a <: sourceReg2F,
        INF :> bINF,
        sNAN :> bsNAN,
        qNAN :> bqNAN
    );

    uint1   less = uninitialised;
    uint1   equal = uninitialised;
    floatcompare FPUlteq( a <: sourceReg1F, b <: sourceReg2F, less :> less, equal :> equal );

    always {
        switch( function3 ) {
            case 3b000: { flags = ( aqNAN | asNAN | bqNAN | bsNAN ) ? 5b10000 : 0; result = flags[4,1] ? 0 : less | equal; }
            case 3b001: { flags = ( aqNAN | asNAN | bqNAN | bsNAN ) ? 5b10000 : 0; result = flags[4,1] ? 0 : less; }
            case 3b010: { flags = ( asNAN | bsNAN ) ? 5b10000 : 0; result = ( aqNAN | asNAN | bqNAN | bsNAN ) ? 0 : equal; }
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

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}

// RISC-V FPU CONTROLLER

algorithm main(output int8 leds) {
    // CYCLE COUNTER
    uint32  startcycle = uninitialised;
    pulse PULSE();

    uint7   opCode = 7b1010011; // ALL OTHER FPU OPERATIONS
    // uint7   opCode = 7b1000011; // FMADD
    // uint7   opCode = 7b1000111; // FMSUB
    // uint7   opCode = 7b1001011; // FNMSUB
    // uint7   opCode = 7b1001111; // FNMADD

    uint7   function7 = 7b0101100; // OPERATION SWITCH
    // ADD = 7b0000000 SUB = 7b0000100 MUL = 7b0001000 DIV = 7b0001100 SQRT = 7b0101100
    // FSGNJ[N][X] = 7b0010000 function3 == 000 FSGNJ == 001 FSGNJN == 010 FSGNJX
    // MIN MAX = 7b0010100 function3 == 000 MIN == 001 MAX
    // FCVT.W[U].S floatto[u]int = 7b1100000 rs2 == 00000 FCVT.W.S == 00001 FCVT.WU.S
    // FCVT.S.W[U] [u]inttofloat = 7b1101000 rs2 == 00000 FCVT.S.W == 00001 FCVT.S.WU

    uint3   function3 = 3b000; // ROUNDING MODE OR SWITCH
    uint5   rs1 = 5b00000; // SOURCEREG1 number
    uint5   rs2 = 5b00000; // SOURCEREG2 number OR SWITCH

    uint32  sourceReg1 = 100; // INTEGER SOURCEREG1

    // -5 = 32hC0A00000
    // -0 = 32h80000000
    // 0 = 0
    // 0.85471 = 32h3F5ACE46
    // 1/3 = 32h3eaaaaab
    // 1 = 32h3F800000
    // 2 = 32h40000000
    // 3 = 32h40400000
    // 10 = 3241200000
    // 50 = 32h42480000
    // 99 = 32h42C60000
    // 100 = 32h42C80000
    // 2.658456E38 = 32h7F480000
    // NaN = 32hffffffff
    // qNaN = 32hffc00000
    // INF = 32h7F800000
    // -INF = 32hFF800000
    uint32  sourceReg1F = 32h42C80000;
    uint32  sourceReg2F = 32h42C60000;
    uint32  sourceReg3F = 32h3eaaaaab;

    uint32  result = uninitialised;
    uint1   frd = uninitialised;

    uint5   FPUflags = 5b00000;
    uint5   FPUnewflags = uninitialised;

    uint32  calculatorresult = uninitialised;
    uint5   calculatorflags = uninitialised;
    floatcalc FPUcalculator( opCode <: opCode, function7 <: function7, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, sourceReg3F <: sourceReg3F, result :> calculatorresult, flags :> calculatorflags );

    uint32  signresult = uninitialised;
    floatsign FPUsign( function3 <: function3, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, result :> signresult );

    uint32  minmaxresult = uninitialised;
    uint5   minmaxflags = uninitialised;
    floatminmax FPUminmax( function3 <: function3, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, result :> minmaxresult, flags :> minmaxflags );

    uint32  compareresult = uninitialised;
    uint5   compareflags = uninitialised;
    floatcomparison FPUcompare( function3 <: function3, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, result :> compareresult, flags :> compareflags );

    uint32  convertresult = uninitialised;
    uint5   convertflags = uninitialised;
    floatconvert FPUconvert( function7 <: function7, rs2 <: rs2, sourceReg1 <: sourceReg1, sourceReg1F <: sourceReg1F, result :> convertresult, flags :> convertflags );

    uint10  classification = uninitialised;
    floatclassify FPUclass( sourceReg1F <: sourceReg1F, classification :> classification );

    FPUcalculator.start := 0; FPUconvert.start := 0;

    // CLOCK CYCLES TO ALLOW SIGNALS TO PROPOGATE - REQUIRED FOR VERILATOR
    ++: ++:
    startcycle = PULSE.cycles;
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
                    FPUcalculator.start = 1; while( FPUcalculator.busy ) {} result = calculatorresult; FPUnewflags = FPUflags | calculatorflags;
                }
                case 5b10100: {
                    switch( function7[2,5] ) {
                        default: {
                            // FADD.S FSUB.S FMUL.S FDIV.S FSQRT.S
                            __display("ADD SUB MUL DIV SQRT");
                            FPUcalculator.start = 1; while( FPUcalculator.busy ) {} result = calculatorresult; FPUnewflags = FPUflags | calculatorflags;
                        }
                        case 5b00100: {
                            // FSGNJ.S FSGNJN.S FSGNJX.S
                            __display("SIGN MANIPULATION");
                            result = signresult;
                        }
                        case 5b00101: {
                            // FMIN.S FMAX.S
                            __display("MIN MAX");
                            result = minmaxresult; FPUnewflags = FPUflags | minmaxflags;
                        }
                        case 5b10100: {
                            // FEQ.S FLT.S FLE.S
                            __display("COMPARISON");
                            frd = 0; result = compareresult; FPUnewflags = FPUflags | compareflags;
                        }
                        case 5b11000: {
                            // FCVT.W.S FCVT.WU.S
                            __display("CONVERSION FLOAT TO INT");
                            frd = 0; FPUconvert.start = 1; while( FPUconvert.busy ) {} result = convertresult; FPUnewflags = FPUflags | convertflags;
                        }
                        case 5b11010: {
                            // FCVT.S.W FCVT.S.WU
                            __display("CONVERSION INT TO FLOAT");
                            FPUconvert.start = 1; while( FPUconvert.busy ) {} result = convertresult; FPUnewflags = FPUflags | convertflags;
                        }
                        case 5b11100: {
                            // FCLASS.S FMV.X.W
                            __display("CLASSIFY or MOVE BITMAP FROM FLOAT TO INT");
                            frd = 0;
                            switch( function3[0,1] ) {
                                case 1: { result = classification; }
                                case 0: { result = sourceReg1F; }
                            }
                        }
                        case 5b11110: {
                            // FMV.W.X
                            __display("MOVE BITMAP FROM INT TO FLOAT");
                            result = sourceReg1;
                        }
                    }
                }
            }
            __display("");
            __display("FRD = %b RESULT = %x -> { %b %b %b }",frd,result,result[31,1],result[23,8],result[0,23]);
            __display("FLAGS = { %b }",FPUnewflags);
            __display("");
            __display("TOTAL OF %0d CLOCK CYCLES",PULSE.cycles - startcycle);
            __display("");
            //busy = 0;
        //}
    //}
}
