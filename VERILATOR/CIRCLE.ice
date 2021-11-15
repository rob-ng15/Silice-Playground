//  CIRCLE - OUTPUT PIXELS TO DRAW AN OUTLINE OR FILLED CIRCLE
algorithm drawcircle(
    input   uint1   start,
    output  uint1   busy(0),
    input   int11   xc,
    input   int11   yc,
    input   int11   radius,
    input   int11   start_numerator,
    input   uint8   draw_sectors,
    input   uint1   filledcircle,
    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    int11   numerator = uninitialised;
    int11   new_numerator <:: numerator[10,1] ? numerator + { active_x, 2b00 } + 6 : numerator + { (active_x - active_y), 2b00 } + 10;
    uint1   positivenumerator <:: ~numerator[10,1] & ( |numerator );
    int11   active_x = uninitialized;
    int11   active_y = uninitialized;
    int11   count = uninitialised;
    int11   min_count = uninitialised;
    uint1   drawingcircle <:: ( active_y >= active_x );
    uint1   drawingsegment <:: ( count != min_count );

    bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1; active_x = 0; active_y = radius; count = radius; numerator = start_numerator;
            min_count = (-1);
        } else {
            if( drawingcircle ) {
                if( drawingsegment ) {
                    // OUTPUT PIXELS IN THE 8 SEGMENTS/ARCS AS PER MASK
                    bitmap_x_write = xc + active_x; bitmap_y_write = yc + count;    if( draw_sectors[0,1] ) { bitmap_write = 1; ++: }
                    bitmap_y_write = yc - count;                                    if( draw_sectors[1,1] ) { bitmap_write = 1; ++: }
                    bitmap_x_write = xc - active_x;                                 if( draw_sectors[2,1] ) { bitmap_write = 1; ++: }
                    bitmap_y_write = yc + count;                                    if( draw_sectors[3,1] ) { bitmap_write = 1; ++: }
                    bitmap_x_write = xc + count; bitmap_y_write = yc + active_x;    if( draw_sectors[4,1] ) { bitmap_write = 1; ++: }
                    bitmap_y_write = yc - active_x;                                 if( draw_sectors[5,1] ) { bitmap_write = 1; ++: }
                    bitmap_x_write = xc - count;                                    if( draw_sectors[6,1] ) { bitmap_write = 1; ++: }
                    bitmap_y_write = yc + active_x;                                 if( draw_sectors[7,1] ) { bitmap_write = 1; }
                    count = filledcircle ? count - 1 : min_count;
                } else {
                    active_x = active_x + 1;
                    active_y = active_y - positivenumerator;
                    count = active_y;
                    min_count = min_count + 1;
                    numerator = new_numerator;
                }
            } else {
                busy = 0;
            }
        }
    }
}
algorithm circle(
    input   uint1   start,
    output  uint1   busy(0),
    input   int11   x,
    input   int11   y,
    input   int11   radius,
    input   uint8   sectormask,
    input   uint1   filledcircle,

    output  int11  bitmap_x_write,
    output  int11  bitmap_y_write,
    output  uint1  bitmap_write
) <autorun> {
    int11   absradius <:: radius[10,1] ? -radius : radius;
    int11   gpu_numerator <:: 3 - ( { absradius, 1b0 } );
    uint8   draw_sectors <:: { sectormask[5,1], sectormask[6,1], sectormask[1,1], sectormask[2,1], sectormask[4,1], sectormask[7,1], sectormask[0,1], sectormask[3,1] };

    drawcircle CIRCLE(
        xc <: x, yc <: y,
        radius <: absradius,
        start_numerator <: gpu_numerator,
        draw_sectors <: draw_sectors,
        filledcircle <: filledcircle,
        bitmap_x_write :> bitmap_x_write, bitmap_y_write :> bitmap_y_write,
        bitmap_write :> bitmap_write,
        start <: start
    );
    busy := start | CIRCLE.busy;
}

// Test it (make verilator)
algorithm main(output uint8 leds)
{
    pulse PULSE();

    circle CIRCLE(); CIRCLE.start := 0;
    CIRCLE.x = 20; CIRCLE.y = 20; CIRCLE.radius = 5; CIRCLE.sectormask = 8h55; CIRCLE.filledcircle = 0;

    ++:

    CIRCLE.start = 1;
    while( CIRCLE.busy ) {
        if( CIRCLE.bitmap_write ) { __display(" @ %d, ( %d, %d )",PULSE.cycles,CIRCLE.bitmap_x_write,CIRCLE.bitmap_y_write); }
    }
}

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}
