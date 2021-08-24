// HELPER CIRCUITS

// MIN[U] MAX[U] curcuits
circuitry min( input value1, input value2, output minimum ) {
    minimum = ( __signed(value1) < __signed(value2) ) ? value1 : value2;
}
circuitry minu( input value1, input value2, output minimum
) {
    minimum = ( __unsigned(value1) < __unsigned(value2) ) ? value1 : value2;
}
circuitry max( input value1, input value2, output maximum
) {
    maximum = ( __signed(value1) > __signed(value2) ) ? value1 : value2;
}
circuitry maxu( input value1, input value2, output maximum
) {
    maximum = ( __unsigned(value1) > __unsigned(value2) ) ? value1 : value2;
}

// MINIMUM OF 3 VALUES
circuitry min3( input value1, input value2, input value3, output minimum ) {
    minimum = ( value1 < value2 ) ? ( value1 < value3 ? value1 : value3 ) : ( value2 < value3 ? value2 : value3 );
}

// MAXIMUM OF 3 VALUES
circuitry max3( input value1, input value2, input value3, output maximum ) {
    maximum = ( value1 > value2 ) ? ( value1 > value3 ? value1 : value3 ) : ( value2 > value3 ? value2 : value3 );
}

// ABSOLUTE VALUE
circuitry abs( input   value1, output  absolute ) {
    absolute = ( __signed(value1) < __signed(0) ) ? -value1 : value1;
}

// ABSOLUTE DELTA ( DIFFERENCE )
circuitry absdelta( input value1, input value2, output delta ) {
    delta = ( __signed(value1) < __signed(value2) ) ? value2 - value1 : value1 - value2;
}

// COPY COORDINATES
circuitry copycoordinates( input x, input y, output x1, output y1 ) {
    x1 = x;
    y1 = y;
}

// SWAP COORDINATES
circuitry swapcoordinates( input x, input y, input x1, input y1, output x2, output y2, output x3, output y3 ) {
    x2 = x1;
    y2 = y1;
    x3 = x;
    y3 = y;
}

// CROP COORDINATES TO SCREEN RANGE
circuitry cropleft( input x, output x1 ) {
    x1 = ( __signed(x) < __signed(0) ) ? 0 : x;
}
circuitry croptop( input y, output y1 ) {
    y1 = ( __signed(y) < __signed(0) ) ? 0 : y;
}
circuitry cropright( input x, output x1 ) {
    x1 = ( x > 319 ) ? 319 : x;
}
circuitry cropbottom( input y, output y1 ) {
    y1 = ( y > 239 ) ? 239 : y;
}

// CROP (x1,y1) to left and top, (x2,y2) to right and bottom
circuitry cropscreen( input x1, input y1, input x2, input y2, output newx1, output newy1, output newx2, output newy2 ) {
    newx1 = ( x1 < 0 ) ? 0 : x1;
    newy1 = ( y1 < 0 ) ? 0 : y1;
    newx2 = ( x2 > 319 ) ? 319 : x2;
    newy2 = ( y1 > 239 ) ? 239 : y2;
}

// INCREASE BY 1 IF SECOND INPUT IS 0
circuitry incrementifzero( input x, input z, output x1 ) {
    x1 = x + ( z == 0 );
}

// DECREASE BY 1 IF SECOND INPUT IS 0
circuitry decrementifzero( input x, input z, output x1 ) {
    x1 = x - ( z == 0 );
}

// IF 0 RESET ELSE DECREASE BY 1
circuitry decrementorreset( input x, input r, output x1 ) {
    x1 = ( x != 0 ) ? x - 1 : r;
}
