// COPY COORDINATES
circuitry copycoordinates( input x, input y, output x1, output y1 ) {
    x1 = x;
    y1 = y;
}

// SWAP COORDINATES
circuitry swapcoordinates( input ix, input iy, input ix1, input iy1, output ox, output oy, output ox1, output oy1 ) {
    sameas(ix) tx = uninitialised; sameas(iy) ty = uninitialised;
    sameas(ix1) tx1 = uninitialised; sameas(iy1) ty1 = uninitialised;
    tx = ix; ty = iy; tx1 = ix1; ty1 = iy1;
    ox = tx1; oy = ty1; ox1 = tx; oy1 = ty;
    ++:
}

// MINIMUM OF 3 VALUES
circuitry min3( input value1, input value2, input value3, output minimum ) {
    minimum = ( value1 < value2 ) ? ( value1 < value3 ? value1 : value3 ) : ( value2 < value3 ? value2 : value3 );
}

// MAXIMUM OF 3 VALUES
circuitry max3( input value1, input value2, input value3, output maximum ) {
    maximum = ( value1 > value2 ) ? ( value1 > value3 ? value1 : value3 ) : ( value2 > value3 ? value2 : value3 );
}

algorithm main(output int8 leds) {
    // CYCLE COUNTER
    uint32  startcycle = uninitialised;
    pulse PULSE();

    int16   x = 100;
    int16   y = 100;
    int16   param0 = 102;
    int16   param1 = 102;
    int16   param2 = 98;
    int16   param3 = 102;
    int16   crop_left = 0;
    int16   crop_right = 319;
    int16   crop_top = 0;
    int16   crop_bottom = 239;

    int16  bitmap_x_write = uninitialised;
    int16  bitmap_y_write = uninitialised;
    uint1  bitmap_write = uninitialised;

    // VERTEX COORDINATES AND BOUNDING BOX
    int16   x1 = uninitialized;
    int16   y1 = uninitialized;
    int16   x2 = uninitialized;
    int16   y2 = uninitialized;
    int16   x3 = uninitialized;
    int16   y3 = uninitialized;
    int16   min_x = uninitialized;
    int16   max_x = uninitialized;
    int16   min_y = uninitialized;
    int16   max_y = uninitialized;
    uint1   todraw = uninitialised;
    preptriangle PREP(
        crop_left <: crop_left,
        crop_right <: crop_right,
        crop_top <: crop_top,
        crop_bottom <: crop_bottom,
        x <: x,
        y <: y,
        param0 <: param0,
        param1 <: param1,
        param2 <: param2,
        param3 <: param3,
        x1 :> x1,
        y1 :> y1,
        x2 :> x2,
        y2 :> y2,
        x3 :> x3,
        y3 :> y3,
        min_x :> min_x,
        min_y :> min_y,
        max_x :> max_x,
        max_y :> max_y,
        todraw :> todraw
    );

    uint1   TRIANGLEstart = uninitialised;
    uint1   TRIANGLEbusy = uninitialised;
    drawtriangle TRIANGLE(
        min_x <: min_x,
        max_x <: max_x,
        min_y <: min_y,
        max_y <: max_y,
        x0 <: x1,
        y0 <: y1,
        x1 <: x2,
        y1 <: y2,
        x2 <: x3,
        y2 <: y3,
        bitmap_x_write :> bitmap_x_write,
        bitmap_y_write :> bitmap_y_write,
        bitmap_write :> bitmap_write,
        start <: TRIANGLEstart,
        busy :> TRIANGLEbusy
    );
    TRIANGLEstart := 0;


    // CLOCK CYCLES TO ALLOW SIGNALS TO PROPOGATE - REQUIRED FOR VERILATOR
    ++: ++:
    startcycle = PULSE.cycles;

    __display("TRIANGLE (%0d,%0d) to (%0d,%0d) to (%0d,%0d)",x,y,param0,param1,param2,param3);
    () <- PREP <- ();
    __display("TRIANGLE SORTED (%0d,%0d) to (%0d,%0d) to (%0d,%0d)",x1,y1,x2,y2,x3,y3);
    __display("DRAWING (%0d,%0d) to (%0d,%0d) DO = %b",min_x,min_y,max_x,max_y,todraw);
    TRIANGLEstart = todraw; while( TRIANGLEbusy ) {
        if( bitmap_write == 1 ) {
            __display("PIXEL (%0d,%0d)",bitmap_x_write,bitmap_y_write);
        } else {
            __display("IGNORE (%0d,%0d)",bitmap_x_write,bitmap_y_write);
        }
    }

    __display("");
    __display("CYCLES = %0d",PULSE.cycles - startcycle);
}

// TRIANGLE - OUTPUT PIXELS TO DRAW A FILLED TRIANGLE
algorithm preptriangle(
    input   int16   crop_left,
    input   int16   crop_right,
    input   int16   crop_top,
    input   int16   crop_bottom,
    input   int16   x,
    input   int16   y,
    input   int16   param0,
    input   int16   param1,
    input   int16   param2,
    input   int16   param3,
    output  int16   x1,
    output  int16   y1,
    output  int16   x2,
    output  int16   y2,
    output  int16   x3,
    output  int16   y3,
    output  int16   min_x,
    output  int16   min_y,
    output  int16   max_x,
    output  int16   max_y,
    output  uint1   todraw
) {
    int16   mx1 = uninitialized; int16   my1 = uninitialized; int16   mx2 = uninitialized; int16   my2 = uninitialized;
    performcrop CROP(
        crop_left <: crop_left,
        crop_right <: crop_right,
        crop_top <: crop_top,
        crop_bottom <: crop_bottom,
        x1 <: mx1,
        y1 <: my1,
        x2 <: mx2,
        y2 <: my2,
        min_x :> min_x,
        min_y :> min_y,
        max_x :> max_x,
        max_y :> max_y
    );
    isinrange TODRAW(
        crop_left <: crop_left,
        crop_right <: crop_right,
        crop_top <: crop_top,
        crop_bottom <: crop_bottom,
        x1 <: mx1,
        y1 <: my1,
        x2 <: mx2,
        y2 <: my2,
        todraw :> todraw
    );
    // Setup drawing a filled triangle x,y param0, param1, param2, param3
    ( x1, y1 ) = copycoordinates( x, y);
    ( x2, y2 ) = copycoordinates( param0, param1 );
    ( x3, y3 ) = copycoordinates( param2, param3 );
    // Find minimum and maximum of x, x1, x2, y, y1 and y2 for the bounding box
    ( mx1 ) = min3( x1, x2, x3 );
    ( my1 ) = min3( y1, y2, y3 );
    ( mx2 ) = max3( x1, x2, x3 );
    ( my2 ) = max3( y1, y2, y3 );
    // Put points in order so that ( x1, y1 ) is at top, then ( x2, y2 ) and ( x3, y3 ) are clockwise from there
    if( y3 < y2 ) { ( x2, y2, x3, y3 ) = swapcoordinates( x2, y2, x3, y3 ); }
    if( y2 < y1 ) { ( x1, y1, x2, y2 ) = swapcoordinates( x1, y1, x2, y2 ); }
    if( y3 < y1 ) { ( x1, y1, x3, y3 ) = swapcoordinates( x1, y1, x3, y3 ); }
    if( y3 < y2 ) { ( x2, y2, x3, y3 ) = swapcoordinates( x2, y2, x3, y3 ); }
    if( ( y2 == y1 ) && ( x2 < x1 ) ) { ( x1, y1, x2, y2 ) = swapcoordinates( x1, y1, x2, y2 ); }
    if( ( y2 != y1 ) && ( y3 >= y2 ) && ( x2 < x3 ) ) { ( x2, y2, x3, y3 ) = swapcoordinates( x2, y2, x3, y3 ); }
}
algorithm drawtriangle(
    input   uint1   start,
    output  uint1   busy(0),
    input   int16   min_x,
    input   int16   min_y,
    input   int16   max_x,
    input   int16   max_y,
    input   int16   x0,
    input   int16   y0,
    input   int16   x1,
    input   int16   y1,
    input   int16   x2,
    input   int16   y2,
    output  int16   bitmap_x_write,
    output  int16   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    // Filled triangle calculations
    // Is the point px,py inside the triangle given by px,py x1,y1 x2,y2?
    uint1   inTriangle <:: ( (( x2 - x1 ) * ( py - y1 ) - ( y2 - y1 ) * ( px - x1 )) >= 0 ) &
                            ( (( x0 - x2 ) * ( py - y2 ) - ( y0 - y2 ) * ( px - x2 )) >= 0 ) &
                            ( (( x1 - x0 ) * ( py - y0 ) - ( y1 - y0 ) * ( px - x0 )) >= 0 );
    uint1   beenInTriangle = uninitialized;
    uint1   EXIT = uninitialised;
    uint1   rightleft <:: ( max_x - px ) < ( px - min_x );
    // WORK COORDINATES AND DIRECTION
    int16   px = uninitialized;
    int16   py = uninitialized;
    uint1   dx = uninitialized;

    bitmap_x_write := px; bitmap_y_write := py; bitmap_write := busy & inTriangle;

    while(1) {
        if( start ) {
            busy = 1;
            dx = 1; beenInTriangle = 0; px = min_x; py = min_y;
            while( py <= max_y ) {
                beenInTriangle = inTriangle | beenInTriangle;
                //bitmap_write = inTriangle;
                EXIT = ( beenInTriangle & ~inTriangle );
                if( EXIT ) {
                    // Exited the triangle, move to the next line
                    beenInTriangle = 0;
                    py = py + 1;
                    if( rightleft ) {
                        // Closer to the right
                        __display("  RESTART RIGHT");
                        px = max_x; dx = 0;
                    } else {
                        // Closer to the left
                        __display("  RESTART LEFT");
                        px = min_x; dx = 1;
                    }
                } else {
                    if( dx ) {
                        if( px <= max_x ) {
                            px = px + 1;
                        } else {
                            dx = 0; beenInTriangle = 0; py = py + 1;
                        }
                    } else {
                        if( px >= min_x ) {
                            px = px - 1;
                        } else {
                            dx = 1; beenInTriangle = 0; py = py + 1;
                        }
                    }
                }
            }
            busy = 0;
        }
    }
}

// CROP TO CROPPING RECTANGLE
// ASSUMES POINTS ARE TOPLEFT (x1,y1) AND BOTTOMRIGHT (x2,y2)
algorithm performcrop(
    input   int16   crop_left,
    input   int16   crop_right,
    input   int16   crop_top,
    input   int16   crop_bottom,
    input   int16   x1,
    input   int16   y1,
    input   int16   x2,
    input   int16   y2,
    output  uint9   min_x,
    output  uint8   min_y,
    output  uint9   max_x,
    output  uint8   max_y,
) <autorun> {
    always {
        min_x = ( x1 < crop_left ) ? crop_left : x1;
        min_y = ( y1 < crop_top ) ? crop_top : y1;
        max_x = ( x2 > crop_right ) ? crop_right : x2;
        max_y = ( y2 > crop_bottom ) ? crop_bottom : y2;
    }
}

// DETERMINE IF ANYTHING TO DRAW
// ASSUMES POINTS ARE TOPLEFT (x1,y1) AND BOTTOMRIGHT (x2,y2)
algorithm   isinrange(
    input   int16   crop_left,
    input   int16   crop_right,
    input   int16   crop_top,
    input   int16   crop_bottom,
    input   int16   x1,
    input   int16   y1,
    input   int16   x2,
    input   int16   y2,
    output  uint1   todraw
) <autorun> {
    always {
        todraw = ~( ( x2 < crop_left ) || ( y2 < crop_top ) || ( x1 > crop_right ) || ( y1 > crop_bottom ) );
    }
}

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}
