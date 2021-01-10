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

// READ FROM SDRAM
circuitry SDRAMread(
    inout   sd
) {
    sd.rw = 0;
    sd.in_valid = 1;
    while( !sd.done ) {}
}

// WRITE TO SDRAM
circuitry SDRAMwrite(
    inout   sd,
    input   writedata
) {
    sd.data_in = writedata;
    sd.rw = 1;
    sd.in_valid = 1;
    while( !sd.done ) {}
}
