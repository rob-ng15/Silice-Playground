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
circuitry swapcoordinates( input ix, input iy, input ix1, input iy1, output ox, output oy, output ox1, output oy1 ) {
    sameas(ix) tx = uninitialised; sameas(iy) ty = uninitialised;
    sameas(ix1) tx1 = uninitialised; sameas(iy1) ty1 = uninitialised;
    tx = ix; ty = iy; tx1 = ix1; ty1 = iy1;
    ox = tx1; oy = ty1; ox1 = tx; oy1 = ty;
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
