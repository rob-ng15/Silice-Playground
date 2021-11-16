// RECTANGLE - OUTPUT PIXELS TO DRAW A RECTANGLE
algorithm preprectangle(
    input   uint1   start,
    input   int11   crop_left,
    input   int11   crop_right,
    input   int11   crop_top,
    input   int11   crop_bottom,
    input   int11   x,
    input   int11   y,
    input   int11   param0,
    input   int11   param1,
    output  int11   min_x,
    output  int11   min_y,
    output  int11   max_x,
    output  int11   max_y,
    output  uint1   todraw
) <autorun> {
    uint1   xcompareparam0 <:: ( x < param0 );
    uint1   ycompareparam1 <:: ( y < param1 );

    int11   x1 <:: xcompareparam0 ? x : param0;
    int11   y1 <:: ycompareparam1 ? y : param1;
    int11   x2 <:: xcompareparam0 ? param0 : x;
    int11   y2 <:: ycompareparam1 ? param1 : y;

    todraw := 0;

    always {
        if( start ) {
            min_x = ( x1 < crop_left ) ? crop_left : x1;
            min_y = ( y1 < crop_top ) ? crop_top : y1;
            max_x = 1 + ( ( x2 > crop_right ) ? crop_right : x2 );
            max_y = 1 + ( ( y2 > crop_bottom ) ? crop_bottom : y2 );
            todraw = ~( ( max_x < crop_left ) | ( max_y < crop_top ) | ( min_x > crop_right ) | ( min_y > crop_bottom ) );
        }
    }
}
algorithm drawrectangle(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint9   min_x,
    input   uint8   min_y,
    input   uint9   max_x,
    input   uint8   max_y,
    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    uint9   x = uninitialized;
    uint8   y = uninitialized;
    bitmap_x_write := x; bitmap_y_write := y; bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            y = min_y; x = min_x;
            while( y != max_y ) {
                if( x != max_x ) { bitmap_write = 1; x = x + 1; } else { x = min_x; y = y + 1; }
            }
            busy = 0;
        }
    }
}
algorithm rectangle (
    input   uint1   start,
    output  uint1   busy(0),
    input   int11   crop_left,
    input   int11   crop_right,
    input   int11   crop_top,
    input   int11   crop_bottom,
    input   int11   x,
    input   int11   y,
    input   int11   x1,
    input   int11   y1,

    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    preprectangle PREP(
        start <: start,
        crop_left <: crop_left, crop_right <: crop_right, crop_top <: crop_top, crop_bottom <: crop_bottom,
        x <: x, y <: y,
        param0 <: x1, param1 <: y1
    );

    drawrectangle RECTANGLE(
        min_x <: PREP.min_x, min_y <: PREP.min_y, max_x <: PREP.max_x, max_y <: PREP.max_y,
        bitmap_x_write :> bitmap_x_write, bitmap_y_write :> bitmap_y_write,
        bitmap_write :> bitmap_write,
        start <: PREP.todraw
    );

    busy := start | PREP.todraw | RECTANGLE.busy;
}

// Test it (make verilator)
algorithm main(output uint8 leds)
{
    pulse PULSE();

    rectangle RECTANGLE(); RECTANGLE.start := 0;
    RECTANGLE.crop_left = 0; RECTANGLE.crop_right = 319; RECTANGLE.crop_top = 0; RECTANGLE.crop_bottom = 239;
    RECTANGLE.x = 10; RECTANGLE.y = 10; RECTANGLE.x1 = 20; RECTANGLE.y1 = 20;

    ++:

    RECTANGLE.start = 1;
    while( RECTANGLE.busy ) {
        if( RECTANGLE.bitmap_write ) { __display(" @ %d, ( %d, %d )",PULSE.cycles,RECTANGLE.bitmap_x_write,RECTANGLE.bitmap_y_write); }
    }
}

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}
