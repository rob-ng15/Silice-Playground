algorithm main(output int8 leds) {
    // CYCLE COUNTER
    uint32  startcycle = uninitialised;
    pulse PULSE();

    int16   x = 100;
    int16   y = 100;
    int16   param0 = 102;
    int16   param1 = 102;
    int16   crop_left = 0;
    int16   crop_right = 319;
    int16   crop_top = 0;
    int16   crop_bottom = 239;

    int16  bitmap_x_write = uninitialised;
    int16  bitmap_y_write = uninitialised;
    uint1  bitmap_write = uninitialised;

    int16   x1 = uninitialised;
    int16   y1 = uninitialised;
    int16   x2 = uninitialised;
    int16   y2 = uninitialised;

    int16   min_x = uninitialised;
    int16   min_y = uninitialised;
    int16   max_x = uninitialised;
    int16   max_y = uninitialised;
    uint1   todraw = uninitialised;
    preprectangle PREP(
        crop_left <: crop_left,
        crop_right <: crop_right,
        crop_top <: crop_top,
        crop_bottom <: crop_bottom,
        x <: x,
        y <: y,
        param0 <: param0,
        param1 <: param1,
        min_x :> min_x,
        min_y :> min_y,
        max_x :> max_x,
        max_y :> max_y,
        todraw :> todraw
    );

    uint1   RECTANGLEstart = uninitialized;
    uint1   RECTANGLEbusy = uninitialized;
    drawrectangle RECTANGLE(
        min_x <: min_x,
        min_y <: min_y,
        max_x <: max_x,
        max_y <: max_y,
        bitmap_x_write :> bitmap_x_write,
        bitmap_y_write :> bitmap_y_write,
        bitmap_write :> bitmap_write,
        start <: RECTANGLEstart,
        busy :> RECTANGLEbusy
    );

    RECTANGLEstart := 0;

    // CLOCK CYCLES TO ALLOW SIGNALS TO PROPOGATE - REQUIRED FOR VERILATOR
    ++: ++:
    startcycle = PULSE.cycles;

    __display("RECTANGLE (%0d,%0d) to (%0d,%0d)",x,y,param0,param1);
    () <- PREP <- ();
    __display("DRAWING (%0d,%0d) to (%0d,%0d) DO = %b",min_x,min_y,max_x,max_y,todraw);
    RECTANGLEstart = todraw; while( RECTANGLEbusy ) { if( bitmap_write == 1 ) { __display("PIXEL (%0d,%0d)",bitmap_x_write,bitmap_y_write); } }

    __display("");
    __display("CYCLES = %0d",PULSE.cycles - startcycle);
}

// RECTANGLE - OUTPUT PIXELS TO DRAW A RECTANGLE
algorithm preprectangle(
    input   int16   crop_left,
    input   int16   crop_right,
    input   int16   crop_top,
    input   int16   crop_bottom,
    input   int16   x,
    input   int16   y,
    input   int16   param0,
    input   int16   param1,
    output  int16   min_x,
    output  int16   min_y,
    output  int16   max_x,
    output  int16   max_y,
    output  uint1   todraw
) {
    int16   x1 <:: ( x < param0 ) ? x : param0;
    int16   y1 <:: ( y < param1 ) ? y : param1;
    int16   x2 <:: ( x > param0 ) ? x : param0;
    int16   y2 <:: ( y > param1 ) ? y : param1;

    min_x = ( x1 < crop_left ) ? crop_left : x1;
    min_y = ( y1 < crop_top ) ? crop_top : y1;
    max_x = 1 + ( ( x2 > crop_right ) ? crop_right : x2 );
    max_y = 1 + ( ( y2 > crop_bottom ) ? crop_bottom : y2 );
    todraw = ~( ( max_x < crop_left ) || ( max_y < crop_top ) || ( min_x > crop_right ) || ( min_y > crop_bottom ) );
}

algorithm drawrectangle(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint9   min_x,
    input   uint8   min_y,
    input   uint9   max_x,
    input   uint8   max_y,
    output  int16   bitmap_x_write,
    output  int16   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    uint9   x = uninitialized; uint8   y = uninitialized;
    bitmap_x_write := x; bitmap_y_write := y; bitmap_write := 0;

    while(1) {
        if( start ) {
            busy = 1;
            x = min_x; y = min_y;
            while( y != max_y ) {
                if( x != max_x ) {
                    bitmap_write = 1; x = x + 1;
                } else {
                    x = min_x; y = y + 1;
                }
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
