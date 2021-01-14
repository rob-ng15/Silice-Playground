// MATHEMATICAL UNITS

// UNSIGNED / SIGNED 32 by 32 bit division giving 32 bit remainder and quotient
algorithm divideremainder (
    input   uint3   function3,

    input   uint32  dividend,
    input   uint32  divisor,

    input   uint1   start,
    output  uint1   active,

    output! uint32  result,
) <autorun> {
    uint32  quotient = uninitialized;
    uint32  remainder = uninitialized;
    uint32  dividend_copy := ~function3[0,1] ? ( dividend[31,1] ? -dividend : dividend ) : dividend;
    uint32  divisor_copy := ~function3[0,1] ? ( divisor[31,1] ? -divisor : divisor ) :divisor;
    uint1   resultsign := ~function3[0,1] ? dividend[31,1] != divisor[31,1] : 0;
    uint6   bit = uninitialized;
    uint6   count = uninitialized;

    uint1   busy = 0;
    active := start ? 1 : busy;

    result := function3[1,1] ? remainder : ( resultsign ? -quotient : quotient );

    while(1) {
        if( start ) {
            busy = 1;
            bit = 31;
            if( divisor == 0 ) {
                // DIVISON by ZERO
                quotient = 32hffffffff;
                remainder = dividend;
                busy = 0;
            } else {
                quotient = 0;
                remainder = 0;
                ++:
                while( bit != 63 ) {
                    if( __unsigned({ remainder[0,31], dividend_copy[bit,1] }) >= __unsigned(divisor_copy) ) {
                        remainder = __unsigned({ remainder[0,31], dividend_copy[bit,1] }) - __unsigned(divisor_copy);
                        quotient[bit,1] = 1;
                    } else {
                        remainder = { remainder[0,31], dividend_copy[bit,1] };
                    }
                    bit = bit - 1;
                }
                ++:
                busy = 0;
            }
        }
    }
}

// UNSIGNED / SIGNED 32 by 32 bit multiplication giving 64 bit product using DSP blocks
algorithm multiplicationDSP (
    input   uint3   function3,

    input   uint32  factor_1,
    input   uint32  factor_2,

    input   uint1   start,
    output  uint1   active,

    output! uint32  result
) <autorun> {
    uint32  factor_1_copy := ( dosigned == 0 ) ? factor_1 : ( ( factor_1[31,1] ) ? -factor_1 : factor_1 );
    uint32  factor_2_copy := ( dosigned != 1 ) ? factor_2 : ( ( factor_2[31,1] ) ? -factor_2 : factor_2 );
    uint64  product = uninitialized;

    // CALCULATION AB * CD
    uint18  A := { 2b0, factor_1_copy[16,16] };
    uint18  B := { 2b0, factor_1_copy[0,16] };
    uint18  C := { 2b0, factor_2_copy[16,16] };
    uint18  D := { 2b0, factor_2_copy[0,16] };

    // FULLY SIGNED / PARTIALLY SIGNED / UNSIGNED and RESULT SIGNED FLAGS
    uint2   dosigned := function3[1,1] ? ( function3[0,1] ? 0 : 2 ) : 1;
    uint1   resultsign := ( dosigned == 0 ) ? 0 : ( ( dosigned == 1 ) ? ( factor_1[31,1] != factor_2[31,1] ) : factor_1[31,1] );

    uint1   busy = 0;
    active := start ? 1 : busy;

    result := ( function3 == 0 ) ? product[0,32] : product[32,32];

    while(1) {
        if( start ) {
            busy = 1;
            ++:
            product = resultsign ? -( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } ) : ( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } );
            ++:
            busy = 0;
        }
    }
}

// PERFORM OPTIONAL SIGN EXTENSION FOR 8 BIT AND 16 BIT READS
algorithm signextender8 (
    input   uint3   function3,
    input!  uint8   nosign,
    output! uint32  withsign
) <autorun> {
    withsign := ~function3[2,1] ? { {24{nosign[7,1]}}, nosign[0,8] } : nosign[0,8];

    while(1) {
    }
}

algorithm signextender16 (
    input   uint3   function3,
    input!  uint16  nosign,
    output! uint32  withsign
) <autorun> {
    withsign := ~function3[2,1] ? { {16{nosign[15,1]}}, nosign[0,16] } : nosign[0,16];

    while(1) {
    }
}

// COMBINE TWO 16 BIT HALF WORDS TO 32 BIT WORD
algorithm halfhalfword (
    input   uint16  HIGH,
    input   uint16  LOW,
    output! int32   HIGHLOW,
    output! int32   ZEROLOW
) <autorun> {
    HIGHLOW := { HIGH, LOW };
    ZEROLOW := { 16b0, LOW };

    while(1) {
    }
}
