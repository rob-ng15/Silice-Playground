// RECTANGLE - OUTPUT PIXELS TO DRAW A RECTANGLE
algorithm preprectangle(
    input   uint1   start,
    output  uint1   busy(0),
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
    uint1   xcompareparam0 <:: ( x < param0 );          uint1   ycompareparam1 <:: ( y < param1 );
    int11   x1 <:: xcompareparam0 ? x : param0;         int11   y1 <:: ycompareparam1 ? y : param1;
    int11   x2 <:: xcompareparam0 ? param0 : x;         int11   y2 <:: ycompareparam1 ? param1 : y;
    istodraw TODRAW( crop_left <: crop_left, crop_right <: crop_right, crop_top <: crop_top, crop_bottom <: crop_bottom,
                min_x <: min_x, min_y <: min_y, max_x <: max_x, max_y <: max_y );
    todraw := 0;

    while(1) {
        if( start ) {
            busy = 1;
            min_x = ( x1 < crop_left ) ? crop_left : x1;
            min_y = ( y1 < crop_top ) ? crop_top : y1;
            max_x = 1 + ( ( x2 > crop_right ) ? crop_right : x2 );
            max_y = 1 + ( ( y2 > crop_bottom ) ? crop_bottom : y2 );
            ++:
            todraw = TODRAW.draw;
            busy = 0;
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
    uint9   x = uninitialized;                          uint8   y = uninitialized;
    bitmap_x_write := x; bitmap_y_write := y; bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            y = min_y;
            while( y != max_y ) {
                x = min_x;
                while( x != max_x ) { bitmap_write = 1; x = x + 1; }
                y = y + 1;
            }
            busy = 0;
        }
    }
}
algorithm rectangle (
    input   uint1   start,
    output  uint1   busy(0),
    input   uint9   crop_left,
    input   uint9   crop_right,
    input   uint8   crop_top,
    input   uint8   crop_bottom,
    input   int11   x,
    input   int11   y,
    input   int11   x1,
    input   int11   y1,

    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun,reginputs> {
    preprectangle PREP(
        start <: start,
        crop_left <: crop_left, crop_right <: crop_right, crop_top <: crop_top, crop_bottom <: crop_bottom,
        x <: x, y <: y, param0 <: x1, param1 <: y1
    );

    drawrectangle RECTANGLE(
        min_x <: PREP.min_x, min_y <: PREP.min_y, max_x <: PREP.max_x, max_y <: PREP.max_y,
        bitmap_x_write :> bitmap_x_write, bitmap_y_write :> bitmap_y_write, bitmap_write :> bitmap_write,
        start <: PREP.todraw
    );

    busy := start | PREP.busy | PREP.todraw | RECTANGLE.busy;
}

// Test it (make verilator)
algorithm main(output uint8 leds)
{
    uint32  startcycle = uninitialized;
    pulse PULSE();
    uint16  pixels = 0;

    rectangle RECTANGLE(); RECTANGLE.start := 0;
    RECTANGLE.crop_left = 12; RECTANGLE.crop_right = 18; RECTANGLE.crop_top = 12; RECTANGLE.crop_bottom = 18;
    RECTANGLE.x = 10; RECTANGLE.y = 10; RECTANGLE.x1 = 20; RECTANGLE.y1 = 20;

    ++:
    startcycle = PULSE.cycles;
    RECTANGLE.start = 1;
    while( RECTANGLE.busy ) {
        if( RECTANGLE.bitmap_write ) {
            pixels = pixels + 1;
            __display(" %d @ %d, ( %d, %d )",pixels,PULSE.cycles-startcycle,RECTANGLE.bitmap_x_write,RECTANGLE.bitmap_y_write);
        }
    }
}

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}

// HELPER - DECIDE IF MIN/MAX ARE WITHIN CROP
algorithm istodraw(
    input   int11   crop_left,
    input   int11   crop_right,
    input   int11   crop_top,
    input   int11   crop_bottom,
    input   int11   min_x,
    input   int11   min_y,
    input   int11   max_x,
    input   int11   max_y,
    output  uint1   draw
) <autorun> {
    always_after {
        draw = ~|{ ( max_x < crop_left ), ( max_y < crop_top ), ( min_x > crop_right ), ( min_y > crop_bottom ) };
    }
}
