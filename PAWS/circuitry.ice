// ABSOLUTE DELTA ( DIFFERENCE )
circuitry absdelta( input value1, input value2, output delta ) {
    delta = ( __signed(value1) < __signed(value2) ) ? value2 - value1 : value1 - value2;
}

// COPY COORDINATES
circuitry copycoordinates( input x, input y, output x1, output y1 ) {
    x1 = x;
    y1 = y;
}
