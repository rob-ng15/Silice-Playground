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
// type == 0 SLL == 1 SLO == 3 ROL
circuitry LSHIFT(
    input   sourceReg1,
    input   shiftcount,
    input   type,
    output  result
) {
    switch( type ) {
        case 0: { result = __unsigned(sourceReg1) << shiftcount[0,5]; }
        case 1: { result = ~( ~sourceReg1 << shiftcount[0,5] ); }
        case 3: { result = ( sourceReg1 << shiftcount[0,5] ) | ( sourceReg1 >> ( ( 32 - shiftcount[0,5] ) & 31 ) ); }
    }

}

// type == 0 SRL == 1 SRO == 2 SRA == 3 ROR
circuitry RSHIFT(
    input   sourceReg1,
    input   shiftcount,
    input   type,
    output  result
) {
    switch( type ) {
        case 0: { result = __unsigned(sourceReg1) >> shiftcount[0,5]; }
        case 1: { result = ~( ~sourceReg1 >> shiftcount[0,5] ); }
        case 2: { result = __signed(sourceReg1) >>> shiftcount[0,5]; }
        case 3: { result = ( sourceReg1 >> shiftcount[0,5] ) | ( sourceReg1 << ( ( 32 - shiftcount[0,5] ) & 31 ) ); }
    }

}

circuitry SBSET(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    result = sourceReg1 | ( 1 << shiftcount );
}

circuitry SBCLR(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    result = sourceReg1 & ~( 1 << shiftcount );
}

circuitry SBINV(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    result = sourceReg1 ^ ( 1 << shiftcount );
}

circuitry SBEXT(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    result = sourceReg1[shiftcount,1];
}

// type == 0 GREV == 1 GORC
circuitry GREVGORC(
    input   sourceReg1,
    input   shiftcount,
    input   type,
    output  result
) {
    result = sourceReg1;
    ++:
    if( shiftcount[0,1] ) { result = ( type == 1 ) ? result : 0 | ( ( result & 32h55555555 ) << 1 ) | ( ( result & 32haaaaaaaa ) >> 1 ); }
    ++:
    if( shiftcount[1,1] ) { result = ( type == 1 ) ? result : 0 | ( ( result & 32h33333333 ) << 2 ) | ( ( result & 32hcccccccc ) >> 2 ); }
    ++:
    if( shiftcount[2,1] ) { result = ( type == 1 ) ? result : 0 | ( ( result & 32h0f0f0f0f ) << 4 ) | ( ( result & 32hf0f0f0f0 ) >> 4 ); }
    ++:
    if( shiftcount[3,1] ) { result = ( type == 1 ) ? result : 0 | ( ( result & 32h00ff00ff ) << 8 ) | ( ( result & 32hff00ff00 ) >> 8 ); }
    ++:
    if( shiftcount[4,1] ) { result = ( type == 1 ) ? result : 0 | ( ( result & 32h0000ffff ) << 16 ) | ( ( result & 32hffff0000 ) >> 16 ); }
}

circuitry shuffle32_stage(
    input   src,
    input   maskL,
    input   maskR,
    input   N,
    output  x
) {
    x = src & ~( maskL | maskR );
    ++:
    x = x | ( ( src << N ) & maskL ) | ( ( src >> N ) & maskR );
}

circuitry SHUFFLE(
    input   sourceReg1,
    input   sourceReg2,
    input   type,
    output  result
) {
    uint4   N8 = 8; uint32 N8A = 32h00ff0000; uint32 N8B = 32h0000ff00;
    uint4   N4 = 4; uint32 N4A = 32h0f000f00; uint32 N4B = 32h00f000f0;
    uint4   N2 = 2; uint32 N2A = 32h30303030; uint32 N2B = 32h0c0c0c0c;
    uint4   N1 = 1; uint32 N1A = 32h44444444; uint32 N1B = 32h22222222;

    result = sourceReg1;
    ++:
    switch( type ) {
        case 0: {
            if( sourceReg2[3,1] ) { ( result ) = shuffle32_stage( result, N8A, N8B, N8 ); }
            if( sourceReg2[2,1] ) { ( result ) = shuffle32_stage( result, N4A, N4B, N4 ); }
            if( sourceReg2[1,1] ) { ( result ) = shuffle32_stage( result, N2A, N2B, N2 ); }
            if( sourceReg2[0,1] ) { ( result ) = shuffle32_stage( result, N1A, N1B, N1 ); }
        }
        case 1: {
            if( sourceReg2[0,1] ) { ( result ) = shuffle32_stage( result, N1A, N1B, N1 ); }
            if( sourceReg2[1,1] ) { ( result ) = shuffle32_stage( result, N2A, N2B, N2 ); }
            if( sourceReg2[2,1] ) { ( result ) = shuffle32_stage( result, N4A, N4B, N4 ); }
            if( sourceReg2[3,1] ) { ( result ) = shuffle32_stage( result, N8A, N8B, N8 ); }
        }
    }
}

circuitry FSHIFT(
    input   sourceReg1,
    input   sourceReg3,
    input   shiftcount,
    input   type,
    output  result
) {
    uint32  A = uninitialised;
    uint32  B = uninitialised;
    uint32  C = uninitialised;

    if( shiftcount >= 32 ) {
        C = shiftcount - 32;
        A = sourceReg3;
        B = sourceReg1;
    } else {
        A = sourceReg1;
        B = sourceReg3;
    }
    ++:
    result = ( C > 0 ) ? ( ( type == 0 ) ? ( ( A << C ) | ( B >> ( 32 - C ) ) ) : ( ( A >> C ) | ( B << ( 32 - C ) ) ) ) : A;
}

circuitry CMOV(
    input   sourceReg1,
    input   sourceReg2,
    input   sourceReg3,
    output  result
) {
    result = ( sourceReg2 != 0 ) ? sourceReg1 : sourceReg3;
}

circuitry CMIX(
    input   sourceReg1,
    input   sourceReg2,
    input   sourceReg3,
    output  result
) {
    result = ( sourceReg1 & sourceReg2 ) | ( sourceReg3 & ~sourceReg2 );
}

// CLMUL type == 0 CLMUL == 1 CLMULH == 2 CLMULR
circuitry CLMUL(
    input   sourceReg1,
    input   sourceReg2,
    input   type,
    output  result
) {
    uint6   i = uninitialised;
    i = ( type == 1 ) ? 1 : 0;
    result = 0;
    ++:
    while( i < 32 ) {
        if( sourceReg2[i,1] ) {
            switch( type ) {
                case 0: { result = result ^ ( sourceReg1 << i ); }
                case 1: { result = result ^ ( sourceReg1 << ( 32 - i ) ); }
                case 2: { result = result ^ ( sourceReg1 << ( 31 - i ) ); }
            }
        }
        i = i + 1;
    }
}

// type == 0 BEXT == 1 BDEP
circuitry BEXTBDEP(
    input   sourceReg1,
    input   sourceReg2,
    input   type,
    output  result
) {
    uint6   i = 0;
    uint6   j = 0;
    result = 0;
    ++:
    while( i < 32 ) {
        if( sourceReg2[i,1] ) {
            if( sourceReg1[ ( type == 1 ) ? j : i, 1] ) {
                result = result | ( 1 << j );
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
    mask = ~( 32hffffffff << offset );
    ++:
    result = ( ( sourceReg2 << offset ) & mask ) | ( sourceReg1 & ~mask );
}

circuitry XPERM(
    input   sourceReg1,
    input   sourceReg2,
    input   size,
    output  result
) {
    uint6   i = 0;
    uint32  sz = uninitialised;
    uint32  mask = uninitialised;
    uint32  pos = uninitialised;

    result = 0;
    sz = 1 << size;
    mask = ( 1 << ( 1<< size ) ) - 1;
    ++:
    while( i < 32 ) {
        pos = ( ( sourceReg2 >> i ) & mask ) << size;
        ++:
        if( pos < 32 ) {
            result = result | ( ( sourceReg1 >> pos ) & mask ) << i;
        }
        i = i + sz;
    }
}

// type == 0 CRC32 == 1 CRC32C
circuitry CRC32(
    input   sourceReg1,
    input   nbits,
    input   type,
    output  result
) {
    uint6   i = 0;
    result = sourceReg1;
    ++:
    while( i < nbits ) {
        switch( type ) {
            case 0: { result = ( result >> 1 ) ^ ( 32hedb88320 & ~( ( sourceReg1 & 1 ) - 1 ) ); }
            case 1: { result = ( result >> 1 ) ^ ( 32h82f63b78 & ~( ( sourceReg1 & 1 ) - 1 ) ); }
        }
        i = i + 1;
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
    input   sourceReg3,

    output  result
) {
    uint8   N = uninitialised;
    uint8   T = uninitialised;

    switch( function3 ) {
        case 3b000: { result = sourceReg1 + immediateValue; }
        case 3b001: {
            switch( function7 ) {
                case 7b0000000: { T = 0; ( result ) = LSHIFT( sourceReg1, IshiftCount, T ); }
                case 7b0010000: { T = 1; ( result ) = LSHIFT( sourceReg1, IshiftCount, T ); }
                case 7b0010100: { ( result ) = SBSET( sourceReg1, IshiftCount ); }
                case 7b0100100: { ( result ) = SBCLR( sourceReg1, IshiftCount ); }
                case 7b0000100: { T = 0; ( result ) = SHUFFLE( sourceReg1, IshiftCount, T ); }
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
                                    sourceReg1 = sourceReg1 << 1;
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
                                    sourceReg1 = sourceReg1 >> 1;
                                }
                            }
                        }
                        case 5b00010: {
                            // PCNT
                            result = 0;
                            while( sourceReg1 != 0 ) {
                                result = sourceReg1[0,1] ? result + 1 : result;
                                sourceReg1 = sourceReg1 >> 1;
                            }
                        }
                        case 5b00100: { result = { {24{sourceReg1[7,1]}}, sourceReg1[0, 8] }; }     // SEXT.B
                        case 5b00101: { result = { {16{sourceReg1[15,1]}}, sourceReg1[0, 16] }; }   // SEXT.H
                        case 5b10000: { N = 8; T = 0; ( result ) = CRC32( sourceReg1, N, T ); }
                        case 5b10001: { N = 16; T = 0; ( result ) = CRC32( sourceReg1, N, T ); }
                        case 5b10010: { N = 32; T = 0; ( result ) = CRC32( sourceReg1, N, T ); }
                        case 5b11000: { N = 8; T = 1; ( result ) = CRC32( sourceReg1, N, T ); }
                        case 5b11001: { N = 16; T = 1; ( result ) = CRC32( sourceReg1, N, T ); }
                        case 5b11010: { N = 32; T = 1; ( result ) = CRC32( sourceReg1, N, T ); }
                    }
                }
                case 7b0110100: { ( result ) = SBINV( sourceReg1, IshiftCount ); }
            }
        }
        case 3b010: { result = __signed( sourceReg1 ) < __signed(immediateValue) ? 32b1 : 32b0; }
        case 3b011: { result = ( immediateValue == 1 ) ? ( ( sourceReg1 == 0 ) ? 32b1 : 32b0 ) : ( ( __unsigned( sourceReg1 ) < __unsigned( immediateValue ) ) ? 32b1 : 32b0 ); }
        case 3b100: { result = sourceReg1 ^ immediateValue; }
        case 3b101: {
            if( function7[1,1] ) {
                T = 0; ( result ) = FSHIFT( sourceReg1, sourceReg3, IshiftCount, T );
            } else {
                switch( function7 ) {
                    case 7b0000000: { T = 0; ( result ) = RSHIFT( sourceReg1, IshiftCount, T ); }
                    case 7b0000100: { T = 1; ( result ) = SHUFFLE( sourceReg1, IshiftCount, T ); }
                    case 7b0010000: { T = 1; ( result ) = RSHIFT( sourceReg1, IshiftCount, T ); }
                    case 7b0010100: { T = 1; ( result ) = GREVGORC( sourceReg1, IshiftCount, T ); }
                    case 7b0100000: { T = 2; ( result ) = RSHIFT( sourceReg1, IshiftCount, T ); }
                    case 7b0100100: { ( result ) = SBEXT( sourceReg1, IshiftCount ); }
                    case 7b0110000: { T = 3; ( result ) = RSHIFT( sourceReg1, IshiftCount, T );  }
                    case 7b0110100: { T = 0; ( result ) = GREVGORC( sourceReg1, IshiftCount, T ); }
                }
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
    input   sourceReg3,

    output  result
) {
    uint8   N = uninitialised;
    uint8   T = uninitialised;

    switch( function3 ) {
        case 3b000: { result = sourceReg1 + ( function7[5,1] ? -( sourceReg2 ) : sourceReg2 ); }
        case 3b001: {
            switch( function7[0,2] ) {
                case 2b11: { ( result) = CMIX( sourceReg1, sourceReg2, sourceReg3 ); }
                case 2b10: { T = 1; ( result ) = FSHIFT( sourceReg1, sourceReg3, sourceReg2, T ); }
                default: {
                    switch( function7 ) {
                        case 7b0000000: { T = 0; ( result ) = LSHIFT( sourceReg1, sourceReg2, T ); }
                        case 7b0000100: { T = 0; ( result ) = SHUFFLE( sourceReg1, sourceReg2, T ); }
                        case 7b0000101: { N = 0; ( result ) = CLMUL( sourceReg1, sourceReg2, N ); }
                        case 7b0010000: { T = 1; ( result ) = LSHIFT( sourceReg1, sourceReg2, T ); }
                        case 7b0010100: { ( result ) = SBSET( sourceReg1, sourceReg2 ); }
                        case 7b0100100: { ( result ) = SBCLR( sourceReg1, sourceReg2 ); }
                        case 7b0110000: { T = 3; ( result ) = LSHIFT( sourceReg1, sourceReg2, T ); }
                        case 7b0110100: { ( result ) = SBINV( sourceReg1, sourceReg2 ); }
                    }
                }
            }
        }
        case 3b010: {
            switch( function7 ) {
                case 7b0000000: { result = __signed( sourceReg1 ) < __signed(sourceReg2) ? 32b1 : 32b0; }
                case 7b0000101: { N = 2; ( result ) = CLMUL( sourceReg1, sourceReg2, N ); }
                case 7b0010000: { result = ( sourceReg1 << 1 ) + sourceReg2; }
            }
        }
        case 3b011: {
            switch( function7 ) {
                case 7b0000000: {result = ( rs1 == 0 ) ? ( ( sourceReg2 != 0 ) ? 32b1 : 32b0 ) : ( ( __unsigned( sourceReg1 ) < __unsigned( sourceReg2 ) ) ? 32b1 : 32b0 ); }
                case 7b0000101: { N = 1; ( result ) = CLMUL( sourceReg1, sourceReg2, N ); }
                case 7b0010100: { N = 2; ( result ) = XPERM( sourceReg1, sourceReg2, N ); }
            }
        }
        case 3b100: {
            switch( function7 ) {
                // XOR PACK MIN SH2ADD XNOR PACKU
                case 7b0000000: { result = sourceReg1 ^ sourceReg2; }
                case 7b0000100: { result = { sourceReg2[0,16], sourceReg1[0,16] }; }
                case 7b0000101: { result = ( __signed( sourceReg1 ) < __signed( sourceReg2 ) ) ? sourceReg1 : sourceReg2; }
                case 7b0010000: { result = ( sourceReg1 << 2 ) + sourceReg2; }
                case 7b0010100: { N = 3; ( result ) = XPERM( sourceReg1, sourceReg2, N ); }
                case 7b0100000: { result = sourceReg1 ^ ~sourceReg2; }
                case 7b0100100: { result = { sourceReg2[16,16], sourceReg1[16,16] }; }
            }
        }
        case 3b101: {
            switch( function7[0,2] ) {
                case 2b11: { ( result ) = CMOV( sourceReg1, sourceReg2, sourceReg3 ); }
                case 2b10: { T = 0; ( result ) = FSHIFT( sourceReg1, sourceReg3, sourceReg2, T ); }
                default: {
                    switch( function7 ) {
                        case 7b0000000: { T = 0; ( result ) = RSHIFT( sourceReg1, sourceReg2, T ); }
                        case 7b0000100: { T = 1; ( result ) = SHUFFLE( sourceReg1, sourceReg2, T ); }
                        case 7b0000101: { result = ( __unsigned( sourceReg1 ) < __unsigned( sourceReg2 ) ) ? sourceReg1 : sourceReg2; }
                        case 7b0010000: { T = 1; ( result ) = RSHIFT( sourceReg1, sourceReg2, T ); }
                        case 7b0010100: { T = 1; ( result ) = GREVGORC( sourceReg1, sourceReg2, T ); }
                        case 7b0100000: { T = 2; ( result ) = RSHIFT( sourceReg1, sourceReg2, T ); }
                        case 7b0100100: { ( result ) = SBEXT( sourceReg1, sourceReg2 ); }
                        case 7b0110000: { T = 3; ( result ) = RSHIFT( sourceReg1, sourceReg2, T ); }
                        case 7b0110100: { T = 0; ( result ) = GREVGORC( sourceReg1, sourceReg2, T ); }
                    }
                }
            }
        }
        case 3b110: {
            switch( function7 ) {
                // OR BEXT MAX SH3ADD ORN BDEP
                case 7b0000000: { result = sourceReg1 | sourceReg2; }
                case 7b0000100: { N = 0; ( result ) = BEXTBDEP( sourceReg1, sourceReg2, N ); }
                case 7b0000101: { result = ( __signed( sourceReg1 ) > __signed( sourceReg2 ) ) ? sourceReg1 : sourceReg2; }
                case 7b0010000: { result = ( sourceReg1 << 3 ) + sourceReg2; }
                case 7b0010100: { N = 4; ( result ) = XPERM( sourceReg1, sourceReg2, N ); }
                case 7b0100000: { result = sourceReg1 | ~sourceReg2; }
                case 7b0100100: { N = 1; ( result ) = BEXTBDEP( sourceReg1, sourceReg2, N ); }
            }
        }
        case 3b111: {
            switch( function7 ) {
                // AND PACKH MAXU ANDN BFP
                case 7b0000000: { result = sourceReg1 & sourceReg2; }
                case 7b0000100: { result = { 16b0, sourceReg2[0,8], sourceReg1[0,8] }; }
                case 7b0000101: { result = ( __unsigned( sourceReg1 ) > __unsigned( sourceReg2 ) ) ? sourceReg1 : sourceReg2; }
                case 7b0100000: { result = sourceReg1 & ~sourceReg2; }
                case 7b0100100: { ( result ) = BFP( sourceReg1, sourceReg2 ); }
            }
        }
    }
}
