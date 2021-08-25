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
circuitry swapcoordinates( input x, input y, input x1, input y1, output x2, output y2, output x3, output y3 ) {
    sameas(x) tx = uninitialised; sameas(y) ty = uninitialised;
    sameas(x1) tx1 = uninitialised; sameas(y1) ty1 = uninitialised;
    tx = x; ty = y; tx1 = x1; ty1 = y1;
    x2 = tx1; y2 = ty1; x3 = tx; y3 = ty;
    ++:
}

// CROP (x1,y1) to left and top, (x2,y2) to right and bottom
circuitry cropscreen( input x1, input y1, input x2, input y2, output newx1, output newy1, output newx2, output newy2 ) {
    newx1 = ( x1 < 0 ) ? 0 : x1;
    newy1 = ( y1 < 0 ) ? 0 : y1;
    newx2 = ( x2 > 319 ) ? 319 : x2;
    newy2 = ( y1 > 239 ) ? 239 : y2;
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

    int10   x = 120;
    int10   y = 120;
    int10   param0 = 80;
    int10   param1 = 120;
    int10   param2 = 100;
    int10   param3 = 100;

    int10   gpu_active_x = uninitialised;
    int10   gpu_active_y = uninitialised;
    int10   gpu_x1 = uninitialised;
    int10   gpu_y1 = uninitialised;
    int10   gpu_x2 = uninitialised;
    int10   gpu_y2 = uninitialised;
    int10   gpu_min_x = uninitialised;
    int10   gpu_min_y = uninitialised;
    int10   gpu_max_x = uninitialised;
    int10   gpu_max_y = uninitialised;

    // CLOCK CYCLES TO ALLOW SIGNALS TO PROPOGATE - REQUIRED FOR VERILATOR
    ++: ++:
    startcycle = PULSE.cycles;
    __display("TRIANGLE VERTICES SORTING");
    __display("INPUT (%0d,%0d), (%0d,%0d), (%0d,%0d)",x,y,param0,param1,param2,param3);

    // Setup drawing a filled triangle x,y param0, param1, param2, param3
    ( gpu_active_x, gpu_active_y ) = copycoordinates( x, y);
    ( gpu_x1, gpu_y1 ) = copycoordinates( param0, param1 );
    ( gpu_x2, gpu_y2 ) = copycoordinates( param2, param3 );
    // Find minimum and maximum of x, x1, x2, y, y1 and y2 for the bounding box
    ( gpu_min_x ) = min3( gpu_active_x, gpu_x1, gpu_x2 );
    ( gpu_min_y ) = min3( gpu_active_y, gpu_y1, gpu_y2 );
    ( gpu_max_x ) = max3( gpu_active_x, gpu_x1, gpu_x2 );
    ( gpu_max_y ) = max3( gpu_active_y, gpu_y1, gpu_y2 );
    ++:
    // Clip to the screen edge
    ( gpu_min_x, gpu_min_y, gpu_max_x, gpu_max_y ) = cropscreen( gpu_min_x, gpu_min_y, gpu_max_x, gpu_max_y );

    // Put points in order so that ( gpu_active_x, gpu_active_y ) is at top, then ( gpu_x1, gpu_y1 ) and ( gpu_x2, gpu_y2 ) are clockwise from there
    __display("gpu_y1 < gpu_active_y = %b y1 = %0d, active_y = %0d",gpu_y1 < gpu_active_y, gpu_y1, gpu_active_y);
    if( gpu_y1 < gpu_active_y ) { ( gpu_active_x, gpu_active_y, gpu_x1, gpu_y1 ) = swapcoordinates( gpu_active_x, gpu_active_y, gpu_x1, gpu_y1 ); __display("SWAPPED"); }

    __display("gpu_y2 < gpu_active_y = %b y1 = %0d, active_y = %0d",gpu_y2 < gpu_active_y, gpu_y2, gpu_active_y);
    if( gpu_y2 < gpu_active_y ) { ( gpu_active_x, gpu_active_y, gpu_x2, gpu_y2 ) = swapcoordinates( gpu_active_x, gpu_active_y, gpu_x2, gpu_y2 ); __display("SWAPPED"); }

    __display("gpu_x1 < gpu_x2 = %b x1 = %0d, x2 = %0d",gpu_x1 < gpu_x2, gpu_x1, gpu_x2);
    if( gpu_x1 < gpu_x2 ) { ( gpu_x1, gpu_y1, gpu_x2, gpu_y2 ) = swapcoordinates( gpu_x1, gpu_y1, gpu_x2, gpu_y2 ); __display("SWAPPED"); }
    ++:
    gpu_max_y = gpu_max_y + 1;
    __display("SORTED CLOCKWISE FROM TOP (%0d,%0d), (%0d,%0d), (%0d,%0d)",gpu_active_x,gpu_active_y,gpu_x1,gpu_y1,gpu_x2,gpu_y2);
}
