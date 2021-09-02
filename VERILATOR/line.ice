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
// ABSOLUTE VALUE
circuitry abs( input value1, output  absolute ) {
    absolute = ( __signed(value1) < __signed(0) ) ? -value1 : value1;
}

// ABSOLUTE DELTA ( DIFFERENCE )
circuitry absdelta( input value1, input value2, output delta ) {
    delta = ( __signed(value1) < __signed(value2) ) ? value2 - value1 : value1 - value2;
}

algorithm main(output int8 leds) {
    // CYCLE COUNTER
    uint32  startcycle = uninitialised;
    pulse PULSE();

    int16   x = 100;
    int16   y = 100;
    int16   param0 = 102;
    int16   param1 = 102;
    uint8   param2 = 2;

    int16  bitmap_x_write = uninitialised;
    int16  bitmap_y_write = uninitialised;
    uint1  bitmap_write = uninitialised;

    int16   x1 = uninitialized;
    int16   y1 = uninitialized;
    int16   dx = uninitialized;
    int16   dy = uninitialized;
    uint1   dv = uninitialized;
    int16   numerator = uninitialized;
    int16   max_count = uninitialized;
    uint8   width <:: param2;
    prepline PREP(
        x <: x,
        y <: y,
        param0 <: param0,
        param1 <: param1,
        param2 <: param2,
        x1 :> x1,
        y1 :> y1,
        dx :> dx,
        dy :> dy,
        dv :> dv,
        numerator :> numerator,
        max_count :> max_count
    );
    uint1   LINEstart = uninitialised;
    uint1   LINEbusy = uninitialised;
    drawline LINE(
        start_x <: x1,
        start_y <: y1,
        start_numerator <: numerator,
        dx <: dx,
        dy <: dy,
        dv <: dv,
        max_count <: max_count,
        width <: width,
        bitmap_x_write :> bitmap_x_write,
        bitmap_y_write :> bitmap_y_write,
        bitmap_write :> bitmap_write,
        start <: LINEstart,
        busy :> LINEbusy
    );
    LINEstart := 0;

    // CLOCK CYCLES TO ALLOW SIGNALS TO PROPOGATE - REQUIRED FOR VERILATOR
    ++: ++:
    startcycle = PULSE.cycles;

    __display("LINE (%0d,%0d) to (%0d,%0d) of width = %0d",x,y,param0,param1,param2);
    () <- PREP <- ();
    LINEstart = 1; while( LINEbusy ) {
        if( bitmap_write == 1 ) { __display("PIXEL (%0d,%0d)",bitmap_x_write,bitmap_y_write); }
    }


    __display("");
    __display("CYCLES = %0d",PULSE.cycles - startcycle);
}

algorithm prepline(
    input   int16   x,
    input   int16   y,
    input   int16   param0,
    input   int16   param1,
    input   int16   param2,
    output  int16   x1,
    output  int16   y1,
    output  int16   dx,
    output  int16   dy,
    output  uint1   dv,
    output  int16   numerator,
    output  int16   max_count,
) {
    // Setup drawing a line from x,y to param0,param1 of width param2 in colour
    // Ensure LEFT to RIGHT AND if moving UP or DOWN
    ( x1 ) = min( x, param0 );
    if( x < param0 ) {
        y1 = y;
        dv = ( y < param1 );
    } else {
        y1 = param1;
        dv = ~( y < param1 );
    }
    // Absolute DELTAs
    ( dx ) = absdelta( x, param0 ); ( dy ) = absdelta( y, param1 );

    // Numerator
    if( dx > dy ) {
        numerator = ( dx >> 1 );
        max_count = dx + 1;
    } else {
        numerator = -( dy >> 1 );
        max_count = dy + 1;
    }
}
algorithm drawline(
    input   uint1   start,
    output  uint1   busy(0),
    input   int16   start_x,
    input   int16   start_y,
    input   int16   start_numerator,
    input   int16   dx,
    input   int16   dy,
    input   uint1   dv,
    input   int16   max_count,
    input   uint8   width,
    output  int16   bitmap_x_write,
    output  int16   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    int16   x = uninitialized;
    int16   y = uninitialized;
    int16   numerator = uninitialized;
    int16   numerator2 <:: numerator;
    int16   newnumerator <:: numerator - ( n2dx ? dy : 0 ) + ( n2dy ? dx : 0 );
    uint1   n2dx <:: numerator2 > (-dx);
    uint1   n2dy <:: numerator2 < dy;
    uint1   dxdy <:: dx > dy;
    int16   count = uninitialized;
    int16   offset_x = uninitialised;
    int16   offset_y = uninitialised;
    int16   offset_start <:: -( width >> 1 );
    uint8   pixel_count = uninitialised;

    bitmap_x_write := x + offset_x; bitmap_y_write := y + offset_y; bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            x = start_x; y = start_y; numerator = start_numerator; count = 0; offset_x = 0; offset_y = 0;
            while( count != max_count ) {
                // OUTPUT PIXELS
                if( width == 1 ) {
                    // SINGLE PIXEL
                    bitmap_write = 1;
                } else {
                    // MULTIPLE WIDTH PIXELS
                    offset_y = dxdy ? offset_start : 0; offset_x = dxdy ? 0 : offset_start;
                    // DRAW WIDTH PIXELS
                    pixel_count = 0;
                    while( pixel_count != width ) {
                        bitmap_write = 1;
                        offset_y = offset_y + dxdy; offset_x = offset_x + ~dxdy;
                        pixel_count = pixel_count + 1;
                    }
                }
                numerator = newnumerator;
                x = x + n2dx; y = n2dy ? (y + ( dv ? 1 : -1 )) : y;
                count = count + 1;
            }
            busy = 0;
        }
    }
}

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}
