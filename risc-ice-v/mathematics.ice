// Hardware Accelerated Multiplication and Division
// UNSIGNED / SIGNED 32 by 32 bit division giving 32 bit remainder and quotient

algorithm divideremainder (
    input   uint32  dividend,
    input   uint32  divisor,
    input   uint1   dosigned,

    input   uint1   start,
    output  uint1   active,

    output  uint32  quotient,
    output  uint32  remainder
) <autorun> {
    uint32  dividend_copy = uninitialized;
    uint32  divisor_copy = uninitialized;

    uint1   resultsign = uninitialized;
    uint6   bit = uninitialized;

    active = 0;

    while(1) {
        if( start ) {
            active = 1;
            bit = 32;

            if( divisor == 0 ) {
                // DIVISON by ZERO
                quotient = 32hffffffff;
                remainder = dividend;
                active = 0;
            } else {
                quotient = 0;
                remainder = 0;

                dividend_copy = dosigned ? ( dividend[31,1] ? -dividend : dividend ) : dividend;
                divisor_copy = dosigned ?  ( divisor[31,1] ? -divisor : divisor ) :divisor;
                resultsign = dosigned ?  dividend[31,1] != divisor[31,1] : 0;

                ++:

                while( bit != 0 ) {
                    if( __unsigned( { remainder[0,31], dividend_copy[bit - 1,1] } ) >= __unsigned(divisor_copy) ) {
                        remainder = { remainder[0,31], dividend_copy[bit - 1,1] } - divisor_copy;
                        quotient[bit - 1,1] = 1;
                    } else {
                        remainder = { remainder[0,31], dividend_copy[bit - 1,1] };
                    }
                    bit = bit - 1;
                }

                ++:

                quotient = resultsign ? -quotient : quotient;
                active = 0;
            }
        }
    }
}

// UNSIGNED / SIGNED 32 by 32 bit multiplication giving 64 bit product
// DSP BLOCKS

algorithm multiplicationDSP (
    input   uint32  factor_1,
    input   uint32  factor_2,
    input   uint2   dosigned,

    input   uint1   start,
    output  uint1   active,

    output  uint64  product
) <autorun> {
    uint32  factor_1_copy := ( dosigned == 0 ) ? factor_1 : ( ( factor_1[31,1] ) ? -factor_1 : factor_1 );
    uint32  factor_2_copy := ( dosigned != 1 ) ? factor_2 : ( ( factor_2[31,1] ) ? -factor_2 : factor_2 );

    // CALCULATION AB * CD
    uint18  A := { 2b0, factor_1_copy[16,16] };
    uint18  B := { 2b0, factor_1_copy[0,16] };
    uint18  C := { 2b0, factor_2_copy[16,16] };
    uint18  D := { 2b0, factor_2_copy[0,16] };

    uint1   resultsign := ( dosigned == 0 ) ? 0 : ( ( dosigned == 1 ) ? ( factor_1[31,1] != factor_2[31,1] ) : factor_1[31,1] );

    while(1) {
        if( start ) {
            active = 1;
            ++:
            product = D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 };
            ++:
            product = resultsign ? -product : product;
            active = 0;
        }
    }
}

// SIGNED ADDITION / SUBTRACTION
algorithm additionsubtraction (
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    input   int32   immediateValue,

    input   uint7   opCode,
    input   uint7   function7,

    output  int32   result,
) <autorun> {
    result := sourceReg1 + ( opCode[5,1] ? ( function7[5,1] ? -( sourceReg2 ) : sourceReg2 ) : immediateValue );

    while(1) {
    }
}

// SHIFT OPERATIONS - LOGICAL and ARITHMETIC
algorithm shifter (
    input   int32   sourceReg1,
    input   int32   sourceReg2,

    input   uint32  instruction,
    input   uint7   opCode,
    input   uint7   function7,

    output  int32   shiftLEFT,
    output  int32   shiftRIGHTA,
    output  int32   shiftRIGHTL,
) <autorun> {
    shiftLEFT :=  __unsigned(sourceReg1) << ( opCode[5,1] ? sourceReg2[0,5] : ItypeSHIFT( instruction ).shiftCount );
    shiftRIGHTA := __signed(sourceReg1) >>> ( opCode[5,1] ? sourceReg2[0,5] : ItypeSHIFT( instruction ).shiftCount );
    shiftRIGHTL := __unsigned(sourceReg1) >> ( opCode[5,1] ? sourceReg2[0,5] : ItypeSHIFT( instruction ).shiftCount );

    while(1) {
    }
}

// BINARY LOGIC OPERATIONS
algorithm logical (
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    input   int32   immediateValue,

    input   uint7   opCode,

    output  int32   AND,
    output  int32   OR,
    output  int32   XOR
) <autorun> {
    AND := sourceReg1 & ( opCode[5,1] ? sourceReg2 : immediateValue );
    OR := sourceReg1 | ( opCode[5,1] ? sourceReg2 : immediateValue );
    XOR := sourceReg1 ^ ( opCode[5,1] ? sourceReg2 : immediateValue );

    while(1) {
    }
}

// COMPARISONS
algorithm comparison (
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    input   int32   immediateValue,
    input   uint32  instruction,

    output  uint1   SLT,
    output  uint1   SLTI,
    output  uint1   SLTU,
    output  uint1   SLTUI
) <autorun> {
    SLT := __signed( sourceReg1 ) < __signed(sourceReg2) ? 1 : 0;
    SLTI := __signed( sourceReg1 ) < __signed(immediateValue) ? 1 : 0;
    SLTU := ( Rtype(instruction).sourceReg1 == 0 ) ? ( ( sourceReg2 != 0 ) ? 1 : 0 ) : ( ( __unsigned( sourceReg1 ) < __unsigned( sourceReg2 ) ) ? 1 : 0 );
    SLTUI := ( immediateValue == 1 ) ? ( ( sourceReg1 == 0 ) ? 1 : 0 ) : ( ( __unsigned( sourceReg1 ) < __unsigned( immediateValue ) ) ? 1 : 0 );

    while(1) {
    }
}

// BRANCH COMPARISIONS
algorithm branchcomparison (
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    input   uint3   function3,
    output  uint1   takeBranch
) <autorun> {
    while(1) {
        switch( function3 ) {
            case 3b000: { takeBranch = ( sourceReg1 == sourceReg2 ) ? 1 : 0; }
            case 3b001: { takeBranch = ( sourceReg1 != sourceReg2 ) ? 1 : 0; }
            case 3b100: { takeBranch = ( __signed(sourceReg1) < __signed(sourceReg2) ) ? 1 : 0; }
            case 3b101: { takeBranch = ( __signed(sourceReg1) >= __signed(sourceReg2) )  ? 1 : 0; }
            case 3b110: { takeBranch = ( __unsigned(sourceReg1) < __unsigned(sourceReg2) ) ? 1 : 0; }
            case 3b111: { takeBranch = ( __unsigned(sourceReg1) >= __unsigned(sourceReg2) ) ? 1 : 0; }
            default: { takeBranch = 0; }
        }
    }
}
