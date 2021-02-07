// ALU - BASE - M EXTENSION - B EXTENSION

// UNSIGNED / SIGNED 32 by 32 bit division giving 32 bit remainder and quotient
algorithm aluMdivideremain(
    input   uint1   start,
    output  uint1   busy,

    input   uint3   function3,
    input   uint32  dividend,
    input   uint32  divisor,

    output  uint32  result
) <autorun> {
    uint32  quotient = uninitialized;
    uint32  remainder = uninitialized;
    uint32  dividend_copy = uninitialized;
    uint32  divisor_copy = uninitialized;
    uint1   resultsign = uninitialized;
    uint6   bit = uninitialized;

    uint1   active = 0;
    busy := start ? 1 : active;

    while(1) {
        if( start ) {
            active = 1;
            dividend_copy = ~function3[0,1] ? ( dividend[31,1] ? -dividend : dividend ) : dividend;
            divisor_copy = ~function3[0,1] ? ( divisor[31,1] ? -divisor : divisor ) : divisor;
            resultsign = ~function3[0,1] ? dividend[31,1] != divisor[31,1] : 0;
            quotient = 0;
            remainder = 0;
            bit = 31;
            ++:

            if( divisor != 0 ) {
                while( bit != 63 ) {
                    if( __unsigned({ remainder[0,31], dividend_copy[bit,1] }) >= __unsigned(divisor_copy) ) {
                        remainder = __unsigned({ remainder[0,31], dividend_copy[bit,1] }) - __unsigned(divisor_copy);
                        quotient[bit,1] = 1;
                    } else {
                        remainder = { remainder[0,31], dividend_copy[bit,1] };
                    }
                    bit = bit - 1;
                }
                result = function3[1,1] ? remainder : ( resultsign ? -quotient : quotient );
            } else {
                result = function3[1,1] ? dividend : 32hffffffff;
            }

            active = 0;
        }
    }
}

// UNSIGNED / SIGNED 32 by 32 bit multiplication giving 64 bit product using DSP blocks
algorithm aluMmultiply(
    input   uint1   start,
    output  uint1   busy,

    input   uint3   function3,
    input   uint32  factor_1,
    input   uint32  factor_2,

    output  uint32  result
) <autorun> {
    // FULLY SIGNED / PARTIALLY SIGNED / UNSIGNED and RESULT SIGNED FLAGS
    uint2   dosigned = uninitialized;
    uint1   resultsign = uninitialized;
    uint32  factor_1_copy = uninitialized;
    uint32  factor_2_copy = uninitialized;
    uint64  product = uninitialized;

    // Calculation is split into 4 18 x 18 multiplications for DSP
    uint18  A = uninitialized;
    uint18  B = uninitialized;
    uint18  C = uninitialized;
    uint18  D = uninitialized;

    uint1   active = 0;
    busy := start ? 1 : active;

    while(1) {
        if( start ) {
            active = 1;

            dosigned = function3[1,1] ? ( function3[0,1] ? 0 : 2 ) : 1;
            resultsign = ( dosigned == 0 ) ? 0 : ( ( dosigned == 1 ) ? ( factor_1[31,1] != factor_2[31,1] ) : factor_1[31,1] );
            factor_1_copy = ( dosigned == 0 ) ? factor_1 : ( ( factor_1[31,1] ) ? -factor_1 : factor_1 );
            factor_2_copy = ( dosigned != 1 ) ? factor_2 : ( ( factor_2[31,1] ) ? -factor_2 : factor_2 );
            ++:
            A = { 2b0, factor_1_copy[16,16] };
            B = { 2b0, factor_1_copy[0,16] };
            C = { 2b0, factor_2_copy[16,16] };
            D = { 2b0, factor_2_copy[0,16] };
            ++:
            product = resultsign ? -( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } ) : ( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } );
            ++:
            result = ( function3 == 0 ) ? product[0,32] : product[32,32];

            active = 0;
        }

    }
}


// BASE IMMEDIATE - with some B extensions
circuitry aluI (
    input   opCode,
    input   function3,
    input   function7,
    input   immediateValue,
    input   IshiftCount,
    input   sourceReg1,

    output  result
) {
    switch( function3 ) {
        case 3b000: { result = sourceReg1 + immediateValue; }
        case 3b001: {
            switch( function7 ) {
                case 7b0110000: {
                    switch( IshiftCount ) {
                        case 5b00000: {
                            // CLZ
                            if( sourceReg1 == 0 ) {
                                result = 32;
                            } else {
                                result = 0;
                                while( ~sourceReg1[31,1] ) {
                                    result = result + 1;
                                    sourceReg1 = { sourceReg1[0,31], 1b0 };
                                }
                            }
                        }
                        case 5b00001: {
                            // CTZ
                            if( sourceReg1 == 0 ) {
                                result = 32;
                            } else {
                                result = 0;
                                while( ~sourceReg1[0,1] ) {
                                    result = result + 1;
                                    sourceReg1 = { 1b0, sourceReg1[1,31] };
                                }
                            }
                        }
                        case 5b00010: {
                            // PCNT
                            result = 0;
                            while( sourceReg1 != 0 ) {
                                result = result + sourceReg1[0,1];
                                sourceReg1 = { 1b0, sourceReg1[1,31] };
                            }
                        }
                        case 5b00100: { result = { {24{sourceReg1[7,1]}}, sourceReg1[0, 8] }; }     // SEXT.B
                        case 5b00101: { result = { {16{sourceReg1[15,1]}}, sourceReg1[0, 16] }; }   // SEXT.H
                    }
                }
                case 7b0000100: { ( result ) = SHFL( sourceReg1, IshiftCount ); }
                default: {
                    switch( function7[2,1] ) {
                        case 0: { ( result ) = LEFTshifter( sourceReg1, IshiftCount, function7 ); }
                        case 1: { ( result ) = SBSetClrInv( sourceReg1, IshiftCount, function7 ); }
                    }
                }
            }
        }
        case 3b010: { result = __signed( sourceReg1 ) < __signed(immediateValue) ? 32b1 : 32b0; }
        case 3b011: { result = ( immediateValue == 1 ) ? ( ( sourceReg1 == 0 ) ? 32b1 : 32b0 ) : ( ( __unsigned( sourceReg1 ) < __unsigned( immediateValue ) ) ? 32b1 : 32b0 ); }
        case 3b100: { result = sourceReg1 ^ immediateValue; }
        case 3b101: {
            switch( function7 ) {
                case 7b0000100: { ( result ) = UNSHFL( sourceReg1, IshiftCount ); }
                case 7b0010100: { ( result ) = GORC( sourceReg1, IshiftCount ); }
                case 7b0100100: { ( result ) = SBEXT( sourceReg1, IshiftCount ); }
                case 7b0110000: { ( result ) = ROR( sourceReg1, IshiftCount );  }
                case 7b0110100: { ( result ) = GREV( sourceReg1, IshiftCount ); }
                default: {  ( result ) = RIGHTshifter( sourceReg1, IshiftCount, function7 ); }
            }
        }
        case 3b110: { result = sourceReg1 | immediateValue; }
        case 3b111: { result = sourceReg1 & immediateValue; }
    }
}

// BASE REGISTER - with some B extensions
circuitry aluR (
    input   opCode,
    input   function3,
    input   function7,
    input   rs1,
    input   sourceReg1,
    input   sourceReg2,

    output  result
) {
    uint5   RshiftCount = uninitialised;
    RshiftCount = sourceReg2[0,5];

    switch( function7 ) {
        case 7b0010100: {
            switch( function3 ) {
                case 3b101: { ( result ) = GORC( sourceReg1, RshiftCount ); }
                default: { ( result ) = XPERM( sourceReg1, sourceReg2, function3 ); }
            }
        }
        case 7b0000101: {
            switch( function3 ) {
                case 3b100: { result = ( __signed( sourceReg1 ) < __signed( sourceReg2 ) ) ? sourceReg1 : sourceReg2; }
                case 3b101: { result = ( __unsigned( sourceReg1 ) < __unsigned( sourceReg2 ) ) ? sourceReg1 : sourceReg2; }
                case 3b110: { result = ( __signed( sourceReg1 ) > __signed( sourceReg2 ) ) ? sourceReg1 : sourceReg2; }
                case 3b111: { result = ( __unsigned( sourceReg1 ) > __unsigned( sourceReg2 ) ) ? sourceReg1 : sourceReg2; }
                default: { ( result ) = CLMUL( sourceReg1, sourceReg2, function3 ); }
            }
        }
        default: {
            switch( function3 ) {
                case 3b000: { result = sourceReg1 + ( function7[5,1] ? -( sourceReg2 ) : sourceReg2 ); }
                case 3b001: {
                    switch( function7 ) {
                        case 7b0000100: { ( result ) = SHFL( sourceReg1, RshiftCount ); }
                        case 7b0110000: { ( result ) = ROL( sourceReg1, RshiftCount ); }
                        default: {
                            switch( function7[2,1] ) {
                                case 0: { ( result ) = LEFTshifter( sourceReg1, RshiftCount, function7 ); }
                                case 1: { ( result ) = SBSetClrInv( sourceReg1, RshiftCount, function7 ); }
                            }
                        }
                    }
                }
                case 3b010: {
                    switch( function7 ) {
                        case 7b0000000: { result = __signed( sourceReg1 ) < __signed(sourceReg2) ? 32b1 : 32b0; }
                        case 7b0010000: { result = { sourceReg1[1,31], 1b0 } + sourceReg2; }
                    }
                }
                case 3b011: { result = ( rs1 == 0 ) ? ( ( sourceReg2 != 0 ) ? 32b1 : 32b0 ) : ( ( __unsigned( sourceReg1 ) < __unsigned( sourceReg2 ) ) ? 32b1 : 32b0 ); }
                case 3b100: {
                    switch( function7 ) {
                        // XOR PACK MIN SH2ADD XNOR PACKU
                        case 7b0000100: { result = { sourceReg2[0,16], sourceReg1[0,16] }; }
                        case 7b0010000: { result = { sourceReg1[2,30], 2b00 } + sourceReg2; }
                        case 7b0100100: { result = { sourceReg2[16,16], sourceReg1[16,16] }; }
                        default: { result = sourceReg1 ^ ( function7[5,1] ? ~sourceReg2 : sourceReg2 ); }
                    }
                }
                case 3b101: {
                    switch( function7 ) {
                        case 7b0000100: { ( result ) = UNSHFL( sourceReg1, RshiftCount ); }
                        case 7b0100100: { ( result ) = SBEXT( sourceReg1, RshiftCount ); }
                        case 7b0110000: { ( result ) = ROR( sourceReg1, RshiftCount ); }
                        case 7b0110100: { ( result ) = GREV( sourceReg1, RshiftCount ); }
                        default:  { ( result ) = RIGHTshifter( sourceReg1, RshiftCount, function3 ); }
                    }
                }
                case 3b110: {
                    switch( function7 ) {
                        // OR BEXT MAX SH3ADD ORN BDEP
                        case 7b0000100: { ( result ) = BEXT( sourceReg1, sourceReg2 ); }
                        case 7b0010000: { result = { sourceReg1[3,29], 3b000 } + sourceReg2; }
                        case 7b0100100: { ( result ) = BDEP( sourceReg1, sourceReg2 ); }
                        default: { result = sourceReg1 | ( function7[5,1] ? ~sourceReg2 : sourceReg2 ); }
                    }
                }
                case 3b111: {
                    switch( function7 ) {
                        // AND PACKH MAXU ANDN BFP
                        case 7b0000100: { result = { 16b0, sourceReg2[0,8], sourceReg1[0,8] }; }
                        case 7b0100100: { ( result ) = BFP( sourceReg1, sourceReg2 ); }
                        default: { result = sourceReg1 & ( function7[5,1] ? ~sourceReg2 : sourceReg2 ); }
                    }
                }
            }
        }
    }
}
// RISC-V MANDATORY CSR REGISTERS
algorithm CSRblock(
    input   uint32  instruction,
    input   uint1   incCSRinstret,
    input   uint1   SMT,
    output  uint32  result
) <autorun> {
    // RDCYCLE[H] and RDTIME[H] are equivalent on PAWSCPU
    uint64  CSRtimer = 0;
    uint64  CSRcycletime = 0;
    uint64  CSRcycletimeSMT = 0;
    uint64  CSRinstret = 0;
    uint64  CSRinstretSMT = 0;

    CSRtimer := CSRtimer + 1;
    CSRcycletime := CSRcycletime + ~SMT;
    CSRinstret := CSRinstret + ( incCSRinstret & (~SMT) );
    CSRcycletimeSMT := CSRcycletime + SMT;
    CSRinstretSMT := CSRinstret + ( incCSRinstret & (SMT) );

    while(1) {
        if( ( CSR(instruction).opcode == 7b1110011 ) && ( CSR(instruction).rs1 == 0 ) && ( CSR(instruction).function3 == 3b010 ) ) {
            switch( CSR(instruction).csr ) {
                case 12hc00: { result = SMT ? CSRcycletimeSMT[0,32] : CSRcycletime[0,32]; }
                case 12hc80: { result = SMT ? CSRcycletimeSMT[32,32] :  CSRcycletime[32,32]; }
                case 12hc01: { result = CSRtimer[0,32]; }
                case 12hc81: { result = CSRtimer[32,32]; }
                case 12hc02: { result = SMT ? CSRinstretSMT[0,32] : CSRinstret[0,32]; }
                case 12hc82: { result = SMT ? CSRinstretSMT[32,32] : CSRinstret[32,32]; }
                case 12hf14: { result = SMT; }
                default: { result = 0; }
            }
        }
    }
}

// ATOMIC A EXTENSION ALU
algorithm aluA (
    input   uint7   opCode,
    input   uint7   function7,
    input   uint32  memoryinput,
    input   uint32  sourceReg2,

    output  uint32  result
) <autorun> {
    while(1) {
        if( opCode == 7b0101111 ) {
            switch( function7[2,5] ) {
                case 5b00000: { result = memoryinput + sourceReg2; }                                                        // AMOADD
                case 5b00001: { result = sourceReg2; }                                                                      // AMOSWAP
                case 5b00100: { result = memoryinput ^ sourceReg2; }                                                        // AMOXOR
                case 5b01000: { result = memoryinput | sourceReg2; }                                                        // AMOOR
                case 5b01100: { result = memoryinput & sourceReg2; }                                                        // AMOAND
                case 5b10000: { result = __signed( memoryinput ) < __signed( sourceReg2 ) ? memoryinput : sourceReg2; }     // AMOMIN
                case 5b10100: { result = __signed( memoryinput ) > __signed( sourceReg2 ) ? memoryinput : sourceReg2; }     // AMOMAX
                case 5b11000: { result = __unsigned( memoryinput ) < __unsigned( sourceReg2 ) ? memoryinput : sourceReg2; } // AMOMINU
                case 5b11100: { result = __unsigned( memoryinput ) > __unsigned( sourceReg2 ) ? memoryinput : sourceReg2; } // AMOMAXU
            }
        }
    }
}
