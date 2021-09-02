algorithm main(output int8 leds) {
    // CYCLE COUNTER
    uint32  startcycle = uninitialised;
    pulse PULSE();

    int16   x = 100;
    int16   y = 100;
    int16   param0 = 2;
    uint8   param1 = 8hff;
    uint1   filledcircle = 1;

    int16  bitmap_x_write = uninitialised;
    int16  bitmap_y_write = uninitialised;
    uint1  bitmap_write = uninitialised;

    int16   radius <:: param0[15,1] ? -param0 : param0;
    int16   gpu_numerator <:: 3 - ( { radius, 1b0 } );
    uint8   draw_sectors <:: { param1[5,1], param1[6,1], param1[1,1], param1[2,1], param1[4,1], param1[7,1], param1[0,1], param1[3,1] };

    uint1   CIRCLEstart = uninitialised;
    uint1   CIRCLEbusy = uninitialised;
    drawcircle CIRCLE(
        xc <: x,
        yc <: y,
        radius <: radius,
        start_numerator <: gpu_numerator,
        draw_sectors <: draw_sectors,
        filledcircle <: filledcircle,
        bitmap_x_write :> bitmap_x_write,
        bitmap_y_write :> bitmap_y_write,
        bitmap_write :> bitmap_write,
        start <: CIRCLEstart,
        busy :> CIRCLEbusy
    );
    CIRCLEstart := 0;

    // CLOCK CYCLES TO ALLOW SIGNALS TO PROPOGATE - REQUIRED FOR VERILATOR
    ++: ++:
    startcycle = PULSE.cycles;

    CIRCLEstart = 1; while( CIRCLEbusy ) {
        if( bitmap_write == 1 ) { __display("PIXEL (%0d,%0d)",bitmap_x_write,bitmap_y_write); }
    }

    __display("");
    __display("CYCLES = %0d",PULSE.cycles - startcycle);
}

//  CIRCLE - OUTPUT PIXELS TO DRAW AN OUTLINE OR FILLED CIRCLE
algorithm drawcircle(
    input   uint1   start,
    output  uint1   busy(0),
    input   int16   xc,
    input   int16   yc,
    input   int16   radius,
    input   int16   start_numerator,
    input   uint8   draw_sectors,
    input   uint1   filledcircle,
    output  int16   bitmap_x_write,
    output  int16   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    int16   new_numerator <:: numerator[9,1] ? numerator + { active_x, 2b00 } + 6 : numerator + { (active_x - active_y), 2b00 } + 10;
    int16   active_x = uninitialized;
    int16   active_y = uninitialized;
    int16   count = uninitialised;
    int16   min_count = uninitialised;
    int16   numerator = uninitialised;
    uint1   positivenumerator <:: ~numerator[15,1] & ( numerator != 0 );
    bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            active_x = 0; active_y = radius; count = radius; numerator = start_numerator;
            min_count = (-1);
            while( active_y >= active_x ) {
                while( count != min_count ) {
                        // OUTPUT PIXELS IN THE 8 SEGMENTS/ARCS
                    { bitmap_write = draw_sectors[0,1]; bitmap_x_write = xc + active_x; bitmap_y_write = yc + count; } ->
                    { bitmap_write = draw_sectors[1,1]; bitmap_y_write = yc - count; } ->
                    { bitmap_write = draw_sectors[2,1]; bitmap_x_write = xc - active_x; } ->
                    { bitmap_write = draw_sectors[3,1]; bitmap_y_write = yc + count; } ->
                    { bitmap_write = draw_sectors[4,1]; bitmap_x_write = xc + count; bitmap_y_write = yc + active_x; } ->
                    { bitmap_write = draw_sectors[5,1]; bitmap_y_write = yc - active_x; } ->
                    { bitmap_write = draw_sectors[6,1]; bitmap_x_write = xc - count; } ->
                    { bitmap_write = draw_sectors[7,1]; bitmap_y_write = yc + active_x; } ->
                    { count = filledcircle ? count - 1 : min_count; }
                }
                active_x = active_x + 1;
                active_y = active_y - positivenumerator;
                count = active_y - positivenumerator;
                min_count = min_count + 1;
                numerator = new_numerator;
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
