// LINE - OUTPUT PIXELS TO DRAW A LINE
// ABSOLUTE DELTA ( DIFFERENCE )
circuitry absdelta( input value1, input value2, output delta ) {
    delta = ( __signed(value1) < __signed(value2) ) ? value2 - value1 : value1 - value2;
}
// LINE - OUTPUT PIXELS TO DRAW A LINE
algorithm prepline(
    input   uint1   start,
    output  uint1   todraw,
    input   int11   x,
    input   int11   y,
    input   int11   param0,
    input   int11   param1,
    output  int11   x1,
    output  int11   y1,
    output  int11   dx,
    output  int11   dy,
    output  uint1   dv,
    output  int11   numerator,
    output  int11   max_count
) <autorun> {
    uint1 ylessparam1 <:: ( y < param1 );

    todraw := 0;

    always_after {
        if( start ) {
            // Setup drawing a line from x,y to param0,param1 of width param2 in colour
            // Ensure LEFT to RIGHT AND if moving UP or DOWN
            if( x < param0 ) { x1 = x; y1 = y; dv = ylessparam1; } else { x1 = param0; y1 = param1; dv = ~ylessparam1; }

            // Absolute DELTAs
            ( dx ) = absdelta( x, param0 ); ( dy ) = absdelta( y, param1 );

            // Numerator
            if( dx > dy ) { numerator = ( dx >> 1 ); max_count = dx + 1; } else { numerator = -( dy >> 1 ); max_count = dy + 1; }

            todraw = 1;
        }
    }
}
algorithm drawline(
    input   uint1   start,
    output  uint1   busy(0),
    input   int11   start_x,
    input   int11   start_y,
    input   int11   start_numerator,
    input   int11   dx,
    input   int11   dy,
    input   uint1   dv,
    input   int11   max_count,
    input   uint8   width,
    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    int11   x = uninitialized;                          int11   xNEXT <:: x + n2dx;
    int11   y = uninitialized;                          int11   yNEXT <:: n2dy ? (y + ( dv ? 1 : -1 )) : y;
    int11   numerator = uninitialized;
    int11   numerator2 <:: numerator;                   int11   newnumerator <:: numerator - ( n2dx ? dy : 0 ) + ( n2dy ? dx : 0 );
    uint1   n2dx <:: numerator2 > (-dx);                uint1   n2dy <:: numerator2 < dy;
    uint1   dxdy <:: dx > dy;
    int11   count = uninitialized;                      int11   countNEXT <:: count + 1;
    int11   offset_x = uninitialised;                   int11   offset_xNEXT <:: offset_y + dxdy;
    int11   offset_y = uninitialised;                   int11   offset_yNEXT <:: offset_x + ~dxdy;
    int11   offset_start <:: -( width >> 1 );
    uint8   pixel_count = uninitialised;                uint8   pixel_countNEXT <:: pixel_count + 1;

    bitmap_x_write := x + offset_x; bitmap_y_write := y + offset_y; bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;  x = start_x; y = start_y; numerator = start_numerator; count = 0;
            if( width == 1 ) {
                offset_x = 0; offset_y = 0;
                while( count != max_count ) {
                    bitmap_write = 1;
                    numerator = newnumerator; x = xNEXT; y = yNEXT; count = countNEXT;
                }
            } else {
                while( count != max_count ) {
                    pixel_count = 0; offset_x = dxdy ? 0 : offset_start; offset_y = dxdy ? offset_start : 0;
                    while( pixel_count != width ) {
                        bitmap_write = 1; offset_y = offset_xNEXT; offset_x = offset_yNEXT; pixel_count = pixel_countNEXT;
                    }
                    numerator = newnumerator; x = xNEXT; y = yNEXT; count = countNEXT;
                }
            }
            busy = 0;
        }
    }
}
algorithm line(
    input   uint1   start,
    output  uint1   busy(0),
    input   int11   x,
    input   int11   y,
    input   int11   x1,
    input   int11   y1,
    input   uint8   width,
    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun,reginputs> {
    prepline PREP(
        start <: start,
        x <: x, y <: y, param0 <: x1, param1 <: y1
    );
    drawline LINE(
        start_x <: PREP.x1, start_y <: PREP.y1,
        start_numerator <: PREP.numerator,
        dx <: PREP.dx, dy <: PREP.dy, dv <: PREP.dv,
        max_count <: PREP.max_count, width <: width,
        bitmap_x_write :> bitmap_x_write, bitmap_y_write :> bitmap_y_write,
        bitmap_write :> bitmap_write,
        start <: PREP.todraw
    );
    busy := start | PREP.todraw | LINE.busy;
}

// Test it (make verilator)
algorithm main(output uint8 leds)
{
    pulse PULSE();

    line LINE(); LINE.start := 0;
    LINE.x = 10; LINE.y = 10; LINE.x1 = 20; LINE.y1 = 20; LINE.width = 2;

    ++:

    LINE.start = 1;
    while( LINE.busy ) {
        if( LINE.bitmap_write ) { __display(" @ %d, ( %d, %d )",PULSE.cycles,LINE.bitmap_x_write,LINE.bitmap_y_write); }
    }
}

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}
