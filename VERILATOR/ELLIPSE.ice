//  ELLIPSE - OUTPUT PIXELS TO DRAW AN OUTLINE OR FILLED ELLIPSE
unit drawellipse(
    input   uint1   start,
    output  uint1   busy(0),
    input   int11   xc,
    input   int11   yc,
    input   int11   radius_x,
    input   int11   radius_y,
    input   uint1   filledellipse,
    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   bitmap_write
) <reginputs> {
    uint11  Xsquare <:: radius_x * radius_x;            uint11  Ysquare <:: radius_y * radius_y;
    uint11  Asquare2 <:: 2 * Xsquare;                   uint11  Bsquare2 <:: 2 * Ysquare;
    int11   Xchange = uninitialised;                    int11   Ychange = uninitialised;
    int11   Xstop = uninitialised;                      int11   Ystop = uninitialised;
    int11   elliposeERROR = uninitialised;

    int11   active_x = uninitialized;
    int11   active_y = uninitialized;

    bitmap_write := 0;

    algorithm <autorun> {
        while(1) {
            if( start ) {
                busy = 1;

                active_x = radius_x;
                active_y = 0;
                Xchange = Ysquare * ( 1 - 2 * radius_x );
                Ychange = Xsquare;
                Xstop = Bsquare2 * radius_x;
                Ystop = 0;
                elliposeERROR = 0;

                while( Xstop >= Ystop ) {
                    bitmap_write = 1;
                    active_y = active_y + 1;
                    Ystop = Ystop + Asquare2;
                    elliposeERROR = elliposeERROR + Ychange;
                    Ychange = Ychange + Asquare2;
                    if( ( 2 * elliposeERROR + Xchange ) > 0 ) {
                        ++:
                        active_x = active_x - 1;
                        Xstop = Xstop - Bsquare2;
                        elliposeERROR = elliposeERROR + Xchange;
                        Xchange = Xchange + Bsquare2;
                    }
                }

                active_x = 0;
                active_y = radius_y;
                Xchange = Ysquare;
                Ychange = Xsquare * ( 1 - 2 * radius_y );
                Xstop = 0;
                Ystop = Asquare2 * radius_y;
                elliposeERROR = 0;

                while( Xstop <= Ystop ) {
                    bitmap_write = 1;
                    active_x = active_x + 1;
                    Xstop = Xstop + Bsquare2;
                    elliposeERROR = elliposeERROR + Xchange;
                    Xchange = Xchange + Bsquare2;
                    if( ( 2 * elliposeERROR + Ychange ) > 0 ) {
                        ++:
                        active_y = active_y - 1;
                        Ystop = Xstop - Asquare2;
                        elliposeERROR = elliposeERROR + Ychange;
                        Ychange = Ychange + Asquare2;
                    }
                }

                busy = 0;
            }
        }
    }

    always_after {
        { bitmap_x_write = xc + active_x; }
        { bitmap_y_write = yc + active_y; }
    }
}
unit ellipse(
    input   uint1   start,
    output  uint1   busy(0),
    input   int11   x,
    input   int11   y,
    input   int11   radius_x,
    input   int11   radius_y,
    input   uint1   filledellipse,

    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   bitmap_write
) <reginputs> {
    int11   absradius_x <:: radius_x[10,1] ? -radius_x : radius_x;
    int11   absradius_y <:: radius_y[10,1] ? -radius_y : radius_y;

    drawellipse ELLIPSE(
        xc <: x, yc <: y,
        radius_x <: absradius_x, radius_y <: absradius_y,
        filledellipse <: filledellipse,
        bitmap_x_write :> bitmap_x_write, bitmap_y_write :> bitmap_y_write, bitmap_write :> bitmap_write,
        start <: start
    );
    busy := start | ELLIPSE.busy;
}



// Test it (make verilator)
algorithm main(output uint8 leds)
{
    uint32  startcycle = uninitialized;
    pulse PULSE();
    uint16  pixels = 0;
    ellipse ELLIPSE(); ELLIPSE.start := 0;
    ELLIPSE.x = 20; ELLIPSE.y = 20; ELLIPSE.radius_x = 4; ELLIPSE.radius_y = 8; ELLIPSE.filledellipse = 1;

    ++:
    startcycle = PULSE.cycles;
    ELLIPSE.start = 1;
    while( ELLIPSE.busy ) {
        if( ELLIPSE.bitmap_write ) {
            pixels = pixels + 1;
            __display("pixel %3d, cycle %3d @ ( %3d, %3d )",pixels,PULSE.cycles-startcycle,ELLIPSE.bitmap_x_write,ELLIPSE.bitmap_y_write);
        }
    }
}

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}
