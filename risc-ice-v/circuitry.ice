// HELPER CIRCUITS

// MINIMUM OF 2 VALUES
circuitry min(
    input   value1,
    input   value2,
    output  minimum
) {
    minimum = ( value1 < value2 ) ? value1 : value2;
}

// MINIMUM OF 3 VALUES
circuitry min3(
    input   value1,
    input   value2,
    input   value3,
    output  minimum
) {
    minimum = ( value1 < value2 ) ? ( value1 < value3 ? value1 : value3 ) : ( value2 < value3 ? value2 : value3 );
}

// MAXIMUM OF 2 VALUES
circuitry max(
    input   value1,
    input   value2,
    output  maximum
) {
    maximum = ( value1 > value2 ) ? value1 : value2;
}

// MAXIMUM OF 3 VALUES
circuitry max3(
    input   value1,
    input   value2,
    input   value3,
    output  maximum
) {
    maximum = ( value1 > value2 ) ? ( value1 > value3 ? value1 : value3 ) : ( value2 > value3 ? value2 : value3 );
}

// ABSOLUTE VALUE
circuitry abs(
    input   value1,
    output  absolute
) {
    absolute = ( value1 < 0 ) ? -value1 : value1;
}

// ABSOLUTE DELTA ( DIFFERENCE )
circuitry absdelta(
    input   value1,
    input   value2,
    output  delta
) {
    delta = ( value1 < value2 ) ? value2 - value1 : value1 - value2;
}

// COPY COORDINATES
circuitry copycoordinates(
    input   x,
    input   y,
    output  x1,
    output  y1
) {
    x1 = x;
    y1 = y;
}

// SWAP COORDINATES
circuitry swapcoordinates(
    input   x,
    input   y,
    input   x1,
    input   y1,
    output  x2,
    output  y2,
    output  x3,
    output  y3
) {
    x2 = x1;
    y2 = y1;
    x3 = x;
    y3 = y;
}

// ADJUST COORDINATES BY DELTAS
circuitry deltacoordinates(
    input   x,
    input   dx,
    input   y,
    input   dy,
    output  xdx,
    output  ydy
) {
    xdx = x + dx;
    ydy = y + dy;
}

// CROP COORDINATES TO SCREEN RANGE
circuitry cropleft(
    input   x,
    output  x1
) {
    x1 = ( x < 0 ) ? 0 : x;
}
circuitry croptop(
    input   y,
    output  y1
) {
    y1 = ( y < 0 ) ? 0 : y;
}
circuitry cropright(
    input   x,
    output  x1
) {
    x1 = ( x > 639 ) ? 639 : x;
}
circuitry cropbottom(
    input   y,
    output  y1
) {
    y1 = ( y > 479 ) ? 479 : y;
}

// INCREASE BY 1 IF SECOND INPUT IS 0
circuitry incrementifzero(
    input   x,
    input   z,
    output  x1
) {
    x1 = ( z == 0 ) ? x + 1 : x;
}

// DECREASE BY 1 IF SECOND INPUT IS 0
circuitry decrementifzero(
    input   x,
    input   z,
    output  x1
) {
    x1 = ( z == 0 ) ? x - 1 : x;
}

// IF 0 RESET ELSE DECREASE BY 1
circuitry decrementorreset(
    input   x,
    input   r,
    output  x1
) {
    x1 = ( x != 0 ) ? x - 1 : r;
}

// BIT MANIPULATION CIRCUITS
circuitry SLL(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    result = __unsigned(sourceReg1) << shiftcount[0,5];
}

circuitry SLO(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    result = ~( ~sourceReg1 << shiftcount[0,5] );
}

circuitry ROL(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    result = ( sourceReg1 << shiftcount[0,5] ) | ( sourceReg1 >> ( ( 32 - shiftcount[0,5] ) & 31 ) );
}

circuitry SRL(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    result = __unsigned(sourceReg1) >> shiftcount[0,5];
}

circuitry SRA(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    result = __signed(sourceReg1) >>> shiftcount[0,5];
}

circuitry SRO(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    result = ~( ~sourceReg1 >> shiftcount[0,5] );
}

circuitry ROR(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    result = ( sourceReg1 >> shiftcount[0,5] ) | ( sourceReg1 << ( ( 32 - shiftcount[0,5] ) & 31 ) );
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
    result = 1 & ( sourceReg1 >> shiftcount );
}

circuitry GREV(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    result = sourceReg1;
    ++:
    if( shiftcount[0,1] ) { result = ( ( result & 32h55555555 ) << 1 ) | ( ( result & 32haaaaaaaa ) >> 1 ); }
    ++:
    if( shiftcount[1,1] ) { result = ( ( result & 32h33333333 ) << 2 ) | ( ( result & 32hcccccccc ) >> 2 ); }
    ++:
    if( shiftcount[2,1] ) { result = ( ( result & 32h0f0f0f0f ) << 4 ) | ( ( result & 32hf0f0f0f0 ) >> 4 ); }
    ++:
    if( shiftcount[3,1] ) { result = ( ( result & 32h00ff00ff ) << 8 ) | ( ( result & 32hff00ff00 ) >> 8 ); }
    ++:
    if( shiftcount[4,1] ) { result = ( ( result & 32h0000ffff ) << 16 ) | ( ( result & 32hffff0000 ) >> 16 );  }
}

circuitry GORC(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    result = sourceReg1;
    ++:
    if( shiftcount[0,1] ) { result = result | ( ( result & 32h55555555 ) << 1 ) | ( ( result & 32haaaaaaaa ) >> 1 ); }
    ++:
    if( shiftcount[1,1] ) { result = result | ( ( result & 32h33333333 ) << 2 ) | ( ( result & 32hcccccccc ) >> 2 ); }
    ++:
    if( shiftcount[2,1] ) { result = result | ( ( result & 32h0f0f0f0f ) << 4 ) | ( ( result & 32hf0f0f0f0 ) >> 4 ); }
    ++:
    if( shiftcount[3,1] ) { result = result | ( ( result & 32h00ff00ff ) << 8 ) | ( ( result & 32hff00ff00 ) >> 8 ); }
    ++:
    if( shiftcount[4,1] ) { result = result | ( ( result & 32h0000ffff ) << 16 ) | ( ( result & 32hffff0000 ) >> 16 ); }
}

