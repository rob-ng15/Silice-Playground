circuitry min3( input value1, input value2, input value3, output minimum ) {
    minimum = ( value1 < value2 ) ? ( value1 < value3 ? value1 : value3 ) : ( value2 < value3 ? value2 : value3 );
}

// MAXIMUM OF 3 VALUES
circuitry max3( input value1, input value2, input value3, output maximum ) {
    maximum = ( value1 > value2 ) ? ( value1 > value3 ? value1 : value3 ) : ( value2 > value3 ? value2 : value3 );
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
    ++:
}

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}

algorithm main(output int8 leds) {
    // CYCLE COUNTER
    uint32  startcycle = uninitialised;
    pulse PULSE();

    int16   x = 40;
    int16   y = 100;
    int16   param0 = 80;
    int16   param1 = 100;
    int16   param2 = 100;
    int16   param3 = 120;

    int16   x1 = uninitialised;
    int16   y1 = uninitialised;
    int16   x2 = uninitialised;
    int16   y2 = uninitialised;
    int16   x3 = uninitialised;
    int16   y3 = uninitialised;
    int16   min_x = uninitialised;
    int16   min_y = uninitialised;
    int16   max_x = uninitialised;
    int16   max_y = uninitialised;

    int16   crop_left = 0;
    int16   crop_right = 319;
    int16   crop_top = 0;
    int16   crop_bottom = 239;
    uint1   todraw = uninitialised;

    // CLOCK CYCLES TO ALLOW SIGNALS TO PROPOGATE - REQUIRED FOR VERILATOR
    ++: ++:
    startcycle = PULSE.cycles;
    __display("TRIANGLE VERTICES SORTING");
    __display("INPUT (%0d,%0d), (%0d,%0d), (%0d,%0d)",x,y,param0,param1,param2,param3);

    // Setup drawing a filled triangle x,y param0, param1, param2, param3
    ( x1, y1 ) = copycoordinates( x, y);
    ( x2, y2 ) = copycoordinates( param0, param1 );
    ( x3, y3 ) = copycoordinates( param2, param3 );
    __display("COORDINATES (x1,y1)=(%0d,%0d), (x2,y2)=(%0d,%0d), (x3,y3)=(%0d,%0d)",x1,y1,x2,y2,x3,y3);

    // Find minimum and maximum of x, x1, x2, y, y1 and y2 for the bounding box
    ( min_x ) = min3( x1, x2, x3 );
    ( min_y ) = min3( y1, y2, y3 );
    ( max_x ) = max3( x1, x2, x3 );
    ( max_y ) = max3( y1, y2, y3 );
    __display("BOUNDING BOX (%0d,%0d) to (%0d,%0d)",min_x,min_y,max_x,max_y);
    //++:
    if( ( max_x < crop_left ) || ( max_y < crop_top ) || ( min_x > crop_right ) || ( min_y > crop_bottom ) ) {
        todraw = 0;
    } else {
        todraw = 1;
        if( min_x < crop_left ) { min_x = crop_left; }
        if( min_y < crop_top ) { min_y = crop_top; }
        if( max_x > crop_right ) { max_x = crop_right; }
        if( max_y > crop_bottom ) { max_y = crop_bottom; }

        // Put points in order so that ( x1, y1 ) is at top, then ( x2, y2 ) and ( x3, y3 ) are clockwise from there
        if( y3 < y2 ) { ( x2, y2, x3, y3 ) = swapcoordinates( x2, y2, x3, y3 ); __display("SWAP 2&3 1"); }
        if( y2 < y1 ) { ( x1, y1, x2, y2 ) = swapcoordinates( x1, y1, x2, y2 ); __display("SWAP 1&2 1"); }
        if( y3 < y1 ) { ( x1, y1, x3, y3 ) = swapcoordinates( x1, y1, x3, y3 ); __display("SWAP 3&1"); }
        if( y3 < y2 ) { ( x2, y2, x3, y3 ) = swapcoordinates( x2, y2, x3, y3 ); __display("SWAP 2&3 2"); }
        if( ( y2 == y1 ) && ( x2 < x1 ) ) { ( x1, y1, x2, y2 ) = swapcoordinates( x1, y1, x2, y2 ); __display("SWAP 1&2 2"); }
        if( ( y2 != y1 ) && ( y3 >= y2 ) && ( x2 < x3 ) ) { ( x2, y2, x3, y3 ) = swapcoordinates( x2, y2, x3, y3 ); __display("SWAP 2&3 3"); }
    }

    __display("SORTED CLOCKWISE FROM TOP (x1,y1)=(%0d,%0d), (x2,y2)=(%0d,%0d), (x3,y3)=(%0d,%0d)",x1,y1,x2,y2,x3,y3);
    __display("BOUNDING BOX (%0d,%0d) to (%0d,%0d)",min_x,min_y,max_x,max_y);
    __display("todraw = %b",todraw);

    __display("");
    __display("CYCLES = %0d",PULSE.cycles - startcycle);
}
