// Hardware Accelerated Mathematics For j1eforth

// UNSIGNED / SIGNED 32 by 16 bit division giving 16 bit remainder and quotient
// INPUT divisor from j1eforth is 16 bit expanded to 32 bit
// OUTPUT quotient and remainder are 16 bit
// PERFORM 32bit/32bit UNSIGNED
algorithm douintdivide(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint32  dividend,
    input   uint32  divisor,
    output  uint32  quotient,
    output  uint32  remainder
) <autorun,reginputs> {
    uint32  temporary <:: { remainder[0,31], dividend[bit,1] };
    uint1   bitresult <:: __unsigned(temporary) >= __unsigned(divisor);
    uint6   bit(63);

    busy := start | ( ~&bit );
    always {
        if( ~&bit ) {
            quotient[bit,1] = bitresult;
            remainder = __unsigned(temporary) - ( bitresult ? __unsigned(divisor) : 0 );
            bit = bit - 1;
        }
    }

    if( ~reset ) { bit = 63; }

    while(1) {
        if( start ) {
            bit = 31; quotient = 0; remainder = 0;
        }
    }
}

// SIGNED/UNSIGNED 32 BIT / 16 BIT TO 16 BIT
algorithm divmod32by16(
    input   uint32  dividend,
    input   uint16  divisor,
    output  uint16  quotient,
    output  uint16  remainder,
    input   uint2   start,
    output  uint1   active(0)
) <autorun,reginputs> {
    uint32  dividend_unsigned <:: ( start[1,1] ) & dividend[31,1] ? -dividend : dividend;
    uint32  divisor_unsigned <:: ( start[1,1] ) & divisor[15,1] ? -divisor : divisor;
    uint1   result_sign <:: ( start[1,1] ) & ( dividend[31,1] ^ divisor[15,1] );
    douintdivide DODIVIDE( dividend <: dividend_unsigned, divisor <: divisor_unsigned );

    DODIVIDE.start := 0;
    while (1) {
        if( start != 0 ) {
            if( |divisor ) {
                active = 1;
                DODIVIDE.start = 1; while( DODIVIDE.busy ) {}
                quotient = result_sign ? -DODIVIDE.quotient[0,16] : DODIVIDE.quotient[0,16];
                remainder = DODIVIDE.remainder;
                active = 0;
            } else {
                quotient = 32hffff; remainder = divisor;
            }
        }
    }
}

// SIGNED 16 by 16 bit division giving 16 bit remainder and quotient
algorithm divmod16by16(
    input   int16   dividend,
    input   int16   divisor,
    output  int16   quotient,
    output  int16   remainder,
    input   uint1   start,
    output  uint1   active(0)
) <autorun,reginputs> {
    uint32  dividend_unsigned <:: dividend[15,1] ? -dividend : dividend;
    uint32  divisor_unsigned <:: divisor[15,1] ? -divisor : divisor;
    uint1   result_sign <:: dividend[15,1] ^ divisor[15,1];
    douintdivide DODIVIDE( dividend <: dividend_unsigned, divisor <: divisor_unsigned );

    DODIVIDE.start := 0;
    while (1) {
        if( start ) {
            if( |divisor ) {
                active = 1;
                DODIVIDE.start = 1; while( DODIVIDE.busy ) {}
                quotient = result_sign ? -DODIVIDE.quotient : DODIVIDE.quotient;
                remainder = DODIVIDE.remainder;
                active = 0;
            } else {
                quotient = 16hffff; remainder = divisor;
            }
        }
    }
}

// UNSIGNED / SIGNED 16 by 16 bit multiplication giving 32 bit product
// DSP INFERENCE
algorithm douintmul(
    input   uint16  factor_1,
    input   uint16  factor_2,
    output  uint32  product
) <autorun,reginputs> {
    always {
        product = factor_1 * factor_2;
    }
}

algorithm multi16by16to32DSP(
    input   uint16  factor1,
    input   uint16  factor2,
    output  uint32  product,
    input   uint2   start
) <autorun,reginputs> {
    uint16  factor1_unsigned <:: start[1,1] ? ( factor1[15,1] ? -factor1 : factor1 ) : factor1;
    uint16  factor2_unsigned <:: start[1,1] ? ( factor2[15,1] ? -factor2 : factor2 ) : factor2;
    uint1   productsign <:: start[1,1] & ( factor1[15,1] ^ factor2[15,1] );
    douintmul UINTMUL( factor_1 <: factor1_unsigned, factor_2 <: factor2_unsigned );
    always {
        product = productsign ? -UINTMUL.product : UINTMUL.product;
    }
}

// Basic double arithmetic for j1eforth
algorithm add32(
    input   int32   a,
    input   int32   b,
    output  int32   c
) <autorun,reginputs> {
    always {
        c = a + b;
    }
}
algorithm logic32(
    input   uint32  a,
    input   uint32  b,
    output  uint32  AND,
    output  uint32  OR,
    output  uint32  XOR
) <autorun,reginputs> {
    always {
        AND = a & b;
        OR = a | b;
        XOR = a ^ b;
    }
}
algorithm doubleops(
    input   int32   operand1,
    input   int32   operand2,
    output  int32   total,
    output  int32   difference,
    output  int32   binaryxor,
    output  int32   binaryor,
    output  int32   binaryand,
    output  int32   maximum,
    output  int32   minimum,
    output  int32   increment,
    output  int32   decrement,
    output  int32   times2,
    output  int32   divide2,
    output  int32   negation,
    output  int32   binaryinvert,
    output  int32   absolute,
    output  uint1   equal,
    output  uint1   lessthan,
    output  uint1   zeroequal,
    output  uint1   zeroless
) <autorun,reginputs> {
    int32   operand1negative <:: -operand1;
    int32   operand2negative <:: -operand2;
    int1    operand1voperand2 <:: operand1 < operand2;

    add32 DADD( a <: operand1, b <: operand2, c :> total );
    add32 DSUB( a <: operand1, b <: operand2negative, c :> difference );
    add32 DINC( a <: operand1, c :> increment );
    add32 DDEC( a <: operand1, c :> decrement );
    logic32 DLOGIC( a <: operand1, b <: operand2, AND :> binaryand, OR :> binaryor, XOR :> binaryxor );
    always {
        maximum = operand1voperand2 ? operand2 : operand1;
        minimum = operand1voperand2 ? operand1 : operand2;
        times2 = { operand1[0,31], 1b0 };
        divide2 = { operand1[31,1], operand1[1,31] };
        negation = operand1negative;
        binaryinvert = ~operand1;
        absolute = ( operand1[31,1] ) ? operand1negative : operand1;
        equal = operand1 == operand2;
        lessthan = operand1voperand2;
        zeroequal = ~|operand1;
        zeroless = operand1[31,1];
    }
    DINC.b = 1; DDEC.b = -1;
}

// FLOAT16 ROUTINES
algorithm floatops(
    input   uint16  a,
    input   uint16  b,
    output  uint16  itof,
    output  int16   ftoi,
    output  uint16  fadd,
    output  uint16  fsub,
    output  uint16  fmul,
    output  uint16  fdiv,
    output  uint16  fsqrt,
    output  uint1   less,
    output  uint1   equal,
    output  uint1   lessequal,
    input   uint5   start,
    output  uint1   busy
) <autorun,reginputs> {
    inttofloat ITOF( a <: a, result :> itof );
    floattoint FTOI( a <: a, result :> ftoi );
    floataddsub FADD( a <: a, b <: b, result :> fadd, result :> fsub );
    floatmultiply FMUL( a <: a, b <: b, result :> fmul );
    floatdivide FDIV( a <: a, b <: b, result :> fdiv );
    floatsqrt FSQRT( a <: a, result :> fsqrt );
    floatcompare FCOMPARE( a <: a, b <: b );

    less := FCOMPARE.less;
    lessequal := FCOMPARE.less | FCOMPARE.equal;
    equal := FCOMPARE.equal;

    busy := FADD.busy | FMUL.busy | FDIV.busy | FSQRT.busy;
    FADD.start := |start[0,2]; FMUL.start := start[2,1]; FDIV.start := start[3,1]; FSQRT.start := start[4,1];

    always {
        if( |start ) { FADD.addsub = start[1,1]; }
    }

    ITOF.dounsigned = 0;
}
