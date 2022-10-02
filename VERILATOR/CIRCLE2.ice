//  CIRCLE - OUTPUT PIXELS TO DRAW AN OUTLINE OR FILLED CIRCLE
algorithm arccoords(
    input   int11   xc,
    input   int11   yc,
    input   int11   active_x,
    input   int11   count,
    input   uint3   arc,
    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   centrepixel
) <autorun> {
    // PLUS OR MINUS OFFSETS
    int11   xcpax <: xc + active_x;                     int11   xcnax <: xc - active_x;
    int11   xcpc <: xc + count;                         int11   xcnc <: xc - count;
    int11   ycpax <: yc + active_x;                     int11   ycnax <: yc - active_x;
    int11   ycpc <: yc + count;                         int11   ycnc <: yc - count;

    centrepixel := ( ~|count & ~|active_x );

    always {
        if( centrepixel ) {
            bitmap_x_write = xc; bitmap_y_write = yc;
        } else {
            switch( arc ) {
                case 0: { bitmap_x_write = xcpax; bitmap_y_write = ycpc; }
                case 1: { bitmap_y_write = ycnc; }
                case 2: { bitmap_x_write = xcnax; }
                case 3: { bitmap_y_write = ycpc; }
                case 4: { bitmap_x_write = xcpc; bitmap_y_write = ycpax; }
                case 5: { bitmap_y_write = ycnax; }
                case 6: { bitmap_x_write = xcnc; }
                case 7: { bitmap_y_write = ycpax; }
            }
        }
    }
}
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
    int11   numerator = uninitialised;                  int11   new_numerator <:: numerator[10,1] ? numerator + { active_x, 2b00 } + 6 : numerator + { (active_x - active_y), 2b00 } + 10;
    uint1   positivenumerator <:: ~numerator[10,1] & ( |numerator );
    int11   active_x = uninitialized;                   int11   active_xNEXT <:: active_x + 1;
    int11   active_y = uninitialized;                   int11   active_yNEXT <:: active_y - positivenumerator;
    int11   count = uninitialised;                      int11   countNEXT <:: filledcircle ? count - 1 : min_count;
    int11   min_count = uninitialised;                  int11   min_countNEXT <:: min_count + 1;
    uint1   drawingcircle <:: ( active_y >= active_x ); uint1   finishsegment <:: ( countNEXT == min_count );

    uint4   arc = uninitialised;                        uint4   arcNEXT <:: arc + 1;
    arccoords ARC( xc <: xc, yc <: yc, active_x <: active_x, count <: count, arc <: arc );

    bitmap_x_write := ARC.centrepixel ? xc : ARC.bitmap_x_write;
    bitmap_y_write := ARC.centrepixel ? yc : ARC.bitmap_y_write;
    bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            active_x = 0; active_y = radius; count = radius; min_count = (-1); numerator = start_numerator;
            while( drawingcircle ) {
                if( ARC.centrepixel ) {
                    // DETECT IF CENTRE PIXEL, OUTPUT ONCE
                    bitmap_write = |draw_sectors;
                } else {
                    arc = 0; while( ~arc[3,1] ) {
                        // OUTPUT PIXELS IN THE 8 SEGMENTS/ARCS AS PER MASK
                        bitmap_write = draw_sectors[arc,1]; arc = arcNEXT;
                    }
                }
                if( finishsegment ) {
                    active_x = active_xNEXT; active_y = active_yNEXT; count = active_y; min_count = min_countNEXT; numerator = new_numerator;
                } else {
                    count = countNEXT;
                }
            }
            busy = 0;
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
) <autorun,reginputs> {
    int11   absradius <:: radius[10,1] ? -radius : radius;
    int11   gpu_numerator <:: 3 - ( { absradius, 1b0 } );
    uint8   draw_sectors <:: { sectormask[5,1], sectormask[6,1], sectormask[1,1], sectormask[2,1], sectormask[4,1], sectormask[7,1], sectormask[0,1], sectormask[3,1] };

    drawcircle CIRCLE(
        xc <: x, yc <: y,
        radius <: absradius,
        start_numerator <: gpu_numerator,
        draw_sectors <: draw_sectors,
        filledcircle <: filledcircle,
        bitmap_x_write :> bitmap_x_write, bitmap_y_write :> bitmap_y_write, bitmap_write :> bitmap_write,
        start <: start
    );
    busy := start | CIRCLE.busy;
}

// Test it (make verilator)
algorithm main(output uint8 leds)
{
    uint32  startcycle = uninitialized;
    pulse PULSE();
    uint16  pixels = 0;

    circle CIRCLE(); CIRCLE.start := 0;
    CIRCLE.x = 20; CIRCLE.y = 20; CIRCLE.radius = 2; CIRCLE.sectormask = 8hff; CIRCLE.filledcircle = 1;

    ++:
    startcycle = PULSE.cycles;
    CIRCLE.start = 1;
    while( CIRCLE.busy ) {
        if( CIRCLE.bitmap_write ) {
            pixels = pixels + 1;
            __display("pixel %3d, cycle %3d @ ( %3d, %3d )",pixels,PULSE.cycles-startcycle,CIRCLE.bitmap_x_write,CIRCLE.bitmap_y_write);
        }
    }
}

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}
