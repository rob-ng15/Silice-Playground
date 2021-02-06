// ALU - BASE - M EXTENSION - B EXTENSION

// UNSIGNED / SIGNED 32 by 32 bit division giving 32 bit remainder and quotient
circuitry divideremainder(
    input   function3,
    input   dividend,
    input   divisor,
    output  result,
) {
    uint32  quotient = uninitialized;
    uint32  remainder = uninitialized;
    uint32  dividend_copy = uninitialized;
    uint32  divisor_copy = uninitialized;
    uint1   resultsign = uninitialized;
    uint6   bit = 31;

    quotient = ( divisor == 0 ) ? 32hffffffff : 0;
    remainder = ( divisor == 0 ) ? dividend : 0;
    dividend_copy = ~function3[0,1] ? ( dividend[31,1] ? -dividend : dividend ) : dividend;
    divisor_copy = ~function3[0,1] ? ( divisor[31,1] ? -divisor : divisor ) :divisor;
    resultsign = ~function3[0,1] ? dividend[31,1] != divisor[31,1] : 0;
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
    }
    result = function3[1,1] ? remainder : ( resultsign ? -quotient : quotient );
}

// UNSIGNED / SIGNED 32 by 32 bit multiplication giving 64 bit product using DSP blocks
circuitry multiplication(
    input   function3,
    input   factor_1,
    input   factor_2,
    output  result
) {
    // FULLY SIGNED / PARTIALLY SIGNED / UNSIGNED and RESULT SIGNED FLAGS
    uint2   dosigned = uninitialized;
    uint1   resultsign = uninitialized;
    uint32  factor_1_copy = uninitialized;
    uint32  factor_2_copy = uninitialized;
    uint64  product = uninitialized;

    uint18  A = uninitialized;
    uint18  B = uninitialized;
    uint18  C = uninitialized;
    uint18  D = uninitialized;

    dosigned = function3[1,1] ? ( function3[0,1] ? 0 : 2 ) : 1;
    ++:
    resultsign = ( dosigned == 0 ) ? 0 : ( ( dosigned == 1 ) ? ( factor_1[31,1] != factor_2[31,1] ) : factor_1[31,1] );
    factor_1_copy = ( dosigned == 0 ) ? factor_1 : ( ( factor_1[31,1] ) ? -factor_1 : factor_1 );
    factor_2_copy = ( dosigned != 1 ) ? factor_2 : ( ( factor_2[31,1] ) ? -factor_2 : factor_2 );
    ++:
    // CALCULATION AB * CD
    A = { 2b0, factor_1_copy[16,16] };
    B = { 2b0, factor_1_copy[0,16] };
    C = { 2b0, factor_2_copy[16,16] };
    D = { 2b0, factor_2_copy[0,16] };
    ++:
    product = resultsign ? -( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } ) : ( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } );
    ++:
    result = ( function3 == 0 ) ? product[0,32] : product[32,32];
}

// BIT MANIPULATION CIRCUITS

// BARREL SHIFTERS / ROTATORS
circuitry LEFTshifter(
    input   sourceReg1,
    input   shiftcount,
    input   function7,
    output  result
) {
    switch( shiftcount[0,5] ) {
        case 0: { result = sourceReg1; }
        $$for i = 1, 31 do
            $$ remain = 32 - i
            case $i$: { result = { sourceReg1[ 0, $remain$ ], {$i${ function7[4,1] }} }; }
        $$end
    }
}
circuitry ROL(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    switch( shiftcount[0,5] ) {
        case 0: { result = sourceReg1; }
        $$for i = 1, 31 do
            $$ remain = 32 - i
            case $i$: { result = { sourceReg1[ 0, $remain$ ], sourceReg1[ $remain$, $i$ ] }; }
        $$end
    }
}
circuitry RIGHTshifter(
    input   sourceReg1,
    input   shiftcount,
    input   function7,
    output  result
) {
    uint1   bit = uninitialised;
    switch( function7[4,2] ) {
        case 2b00: { bit = 0; }
        case 2b01: { bit = 1; }
        case 2b10: { bit = sourceReg1[31,1]; }
    }
    switch( shiftcount[0,5] ) {
        case 0: { result = sourceReg1; }
        $$for i = 1, 31 do
            $$ remain = 32 - i
            case $i$: { result = { {$i${bit}}, sourceReg1[ $i$, $remain$ ] }; }
        $$end
    }
}

circuitry ROR(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    switch( shiftcount[0,5] ) {
        case 0: { result = sourceReg1; }
        $$for i = 1, 31 do
            $$ remain = 32 - i
            case $i$: { result = { sourceReg1[ $remain$, $i$ ], sourceReg1[ $i$, $remain$ ] }; }
        $$end
    }
}

// BIT SET CLR INV EXTRACT
circuitry SBSetClrInv(
    input   sourceReg1,
    input   shiftcount,
    input   function7,
    output  result
) {
    uint1   bit = uninitialised;
    switch( function7[4,2] ) {
        case 2b01: { bit = 1; }
        case 2b10: { bit = 0; }
        case 2b11: { bit = ~sourceReg1[shiftcount,1]; }
    }
    switch( shiftcount[0,5] ) {
        case 0: { result = { sourceReg1[ 1, 31 ], bit }; }
        $$for i = 1, 30 do
        $$j = i + 1
        $$remain = 31 - i;
            case $i$: { result = { sourceReg1[ $j$, $remain$ ], bit, sourceReg1[ 0, $i$ ] }; }
        $$end
        case 31: { result = { bit, sourceReg1[0, 31 ] }; }
    }
}
circuitry SBEXT(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    result = sourceReg1[ shiftcount[0,5], 1 ];
}

// GENERAL REVERSE / GENERAL OR CONDITIONAL
circuitry GREV(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    result = sourceReg1;
    ++:
    if( shiftcount[0,1] ) { result = ( ( result & 32h55555555 ) << 1 ) | ( ( result & 32haaaaaaaa ) >> 1 ); ++: }
    if( shiftcount[1,1] ) { result = ( ( result & 32h33333333 ) << 2 ) | ( ( result & 32hcccccccc ) >> 2 ); ++: }
    if( shiftcount[2,1] ) { result = ( ( result & 32h0f0f0f0f ) << 4 ) | ( ( result & 32hf0f0f0f0 ) >> 4 ); ++: }
    if( shiftcount[3,1] ) { result = ( ( result & 32h00ff00ff ) << 8 ) | ( ( result & 32hff00ff00 ) >> 8 ); ++: }
    if( shiftcount[4,1] ) { result = ( ( result & 32h0000ffff ) << 16 ) | ( ( result & 32hffff0000 ) >> 16 ); }
}
circuitry GORC(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    result = sourceReg1;
    ++:
    if( shiftcount[0,1] ) { result = result | ( ( result & 32h55555555 ) << 1 ) | ( ( result & 32haaaaaaaa ) >> 1 ); ++: }
    if( shiftcount[1,1] ) { result = result | ( ( result & 32h33333333 ) << 2 ) | ( ( result & 32hcccccccc ) >> 2 ); ++: }
    if( shiftcount[2,1] ) { result = result | ( ( result & 32h0f0f0f0f ) << 4 ) | ( ( result & 32hf0f0f0f0 ) >> 4 ); ++: }
    if( shiftcount[3,1] ) { result = result | ( ( result & 32h00ff00ff ) << 8 ) | ( ( result & 32hff00ff00 ) >> 8 ); ++: }
    if( shiftcount[4,1] ) { result = result | ( ( result & 32h0000ffff ) << 16 ) | ( ( result & 32hffff0000 ) >> 16 ); }
}

// SHUFFLE / UNSHUFFLE
circuitry shuffle32_stage(
    input   src,
    input   maskL,
    input   maskR,
    input   N,
    output  x
) {
    uint32  A = uninitialised;
    uint32  B = uninitialised;

    x = src & ~( maskL | maskR );
    A = src << N;
    B = src >> N;
    ++:
    x = x | ( A & maskL ) | ( B & maskR );
}
circuitry SHFL(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    uint4   N8 = 8; uint32 N8A = 32h00ff0000; uint32 N8B = 32h0000ff00;
    uint4   N4 = 4; uint32 N4A = 32h0f000f00; uint32 N4B = 32h00f000f0;
    uint4   N2 = 2; uint32 N2A = 32h30303030; uint32 N2B = 32h0c0c0c0c;
    uint4   N1 = 1; uint32 N1A = 32h44444444; uint32 N1B = 32h22222222;

    result = sourceReg1;
    ++:
    if( shiftcount[3,1] ) { ( result ) = shuffle32_stage( result, N8A, N8B, N8 ); }
    if( shiftcount[2,1] ) { ( result ) = shuffle32_stage( result, N4A, N4B, N4 ); }
    if( shiftcount[1,1] ) { ( result ) = shuffle32_stage( result, N2A, N2B, N2 ); }
    if( shiftcount[0,1] ) { ( result ) = shuffle32_stage( result, N1A, N1B, N1 ); }
}
circuitry UNSHFL(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    uint4   N8 = 8; uint32 N8A = 32h00ff0000; uint32 N8B = 32h0000ff00;
    uint4   N4 = 4; uint32 N4A = 32h0f000f00; uint32 N4B = 32h00f000f0;
    uint4   N2 = 2; uint32 N2A = 32h30303030; uint32 N2B = 32h0c0c0c0c;
    uint4   N1 = 1; uint32 N1A = 32h44444444; uint32 N1B = 32h22222222;

    result = sourceReg1;
    ++:
    if( shiftcount[0,1] ) { ( result ) = shuffle32_stage( result, N1A, N1B, N1 ); }
    if( shiftcount[1,1] ) { ( result ) = shuffle32_stage( result, N2A, N2B, N2 ); }
    if( shiftcount[2,1] ) { ( result ) = shuffle32_stage( result, N4A, N4B, N4 ); }
    if( shiftcount[3,1] ) { ( result ) = shuffle32_stage( result, N8A, N8B, N8 ); }
}

// CARRYLESS MULTIPLY
circuitry CLMUL(
    input   sourceReg1,
    input   sourceReg2,
    input   function3,
    output  result
) {
    uint6   i = uninitialised;
    i = ( function3 == 3b011 ) ? 1 : 0;
    result = 0;
    ++:
    while( i < 32 ) {
        if( sourceReg2[i,1] ) {
            switch( function3 ) {
                case 3b001: { result = result ^ ( sourceReg1 << i ); }
                case 3b010: { result = result ^ ( sourceReg1 << ( 32 - i ) ); }
                case 3b011: { result = result ^ ( sourceReg1 << ( 31 - i ) ); }
            }
        }
        i = i + 1;
    }
}

// BITS EXTRACT / DEPOSIT
circuitry BEXT(
    input   sourceReg1,
    input   sourceReg2,
    output  result
) {
    uint6   i = 0;
    uint6   j = 0;
    result = 0;
    ++:
    while( i < 32 ) {
        if( sourceReg2[i,1] ) {
            if( sourceReg1[ i, 1] ) {
                result[ j, 1 ] = 1b1;
            }
            j = j + 1;
        }
        i = i + 1;
    }
}
circuitry BDEP(
    input   sourceReg1,
    input   sourceReg2,
    output  result
) {
    uint6   i = 0;
    uint6   j = 0;
    result = 0;
    ++:
    while( i < 32 ) {
        if( sourceReg2[i,1] ) {
            if( sourceReg1[ j, 1] ) {
                result[ j, 1 ] = 1b1;
            }
            j = j + 1;
        }
        i = i + 1;
    }
}
circuitry BFP(
    input   sourceReg1,
    input   sourceReg2,
    output  result
) {
    uint5   length = uninitialised;
    uint6   offset = uninitialised;
    uint32  mask = 0;

    length = ( sourceReg2[24,4] == 0 ) ? 16 : sourceReg2[24,4];
    offset = sourceReg2[16,5];
    ++:
    mask = ~(~mask << offset);
    ++:
    result = ( ( sourceReg2 << offset ) & mask ) | ( sourceReg1 & ~mask );
}

// XPERM for nibble, byte and half-word
// CALCULATE result = result | ( ( sourceReg1 >> pos ) & mask ) << i
circuitry xperm(
    input   sourceReg1,
    input   sourceReg2,
    input   sz_log2,
    output  result
) {
    uint6   sz = uninitialised;
    uint32  mask = uninitialised;
    uint32  pos = uninitialised;
    uint6   i = uninitialised;

    sz = 1 << sz_log2;
    mask = ( 1 << ( 1 << sz_log2 ) ) - 1;
    result = 0;
    i = 0;
    ++:
    while( i < 32 ) {
        pos = ( ( sourceReg2 >> i ) & mask ) << sz_log2;
        ++:
        if( pos < 32 ) {
            result = result | (( sourceReg1 >> pos ) & mask ) << i;
        }
        i = i + sz;
    }
}
circuitry XPERM(
    input   sourceReg1,
    input   sourceReg2,
    input   function3,
    output  result
) {
    uint3   sz_log2 = uninitialised;
    switch( function3 ) {
        case 3b010: { sz_log2 = 2; }
        case 3b100: { sz_log2 = 3; }
        case 3b110: { sz_log2 = 4; }
    }
    ( result ) = xperm( sourceReg1, sourceReg2, sz_log2 );
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
                        case 7b0010000: { result = { sourceReg[1,31], 1b0 } + sourceReg2; }
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
                        case 7b0010000: { result = { sourceReg[3,29], 3b000 } + sourceReg2; }
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

// ATOMIC A EXTENSION ALU
circuitry aluA (
    input   function7,
    input   memoryinput,
    input   sourceReg2,

    output  result
) {
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
