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

// ABSOLUTE DELTA ( DIFFERENCE )
circuitry absdelta( input value1, input value2, output delta ) {
    delta = ( __signed(value1) < __signed(value2) ) ? value2 - value1 : value1 - value2;
}

// COPY COORDINATES
circuitry copycoordinates( input x, input y, output x1, output y1 ) {
    x1 = x;
    y1 = y;
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
