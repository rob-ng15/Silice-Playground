// TRIANGLE - OUTPUT PIXELS TO DRAW A FILLED TRIANGLE
algorithm preptriangle(
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
    input   int11   param2,
    input   int11   param3,
    output  int11   x1,
    output  int11   y1,
    output  int11   x2,
    output  int11   y2,
    output  int11   x3,
    output  int11   y3,
    output  int11   min_x,
    output  int11   min_y,
    output  int11   max_x,
    output  int11   max_y,
    output  uint1   todraw
) <autorun> {
    // TEMPORARY STORAGE FOR SWAPPING VARIABLES
    int11   tx = uninitialised;                     int11   ty = uninitialised;

    uint1   x1x2 <:: ( x1 < x2 );                   uint1   y1y2 <:: ( y1 < y2 );                       uint1   y1ey2 <:: ( y1 == y2 );
    uint1   x1x3 <:: ( x1 < x3 );                   uint1   y1y3 <:: ( y1 < y3 );
    uint1   x2x3 <:: ( x2 < x3 );                   uint1   y2y3 <:: ( y2 < y3 );

    istodraw TODRAW( crop_left <: crop_left, crop_right <: crop_right, crop_top <: crop_top, crop_bottom <: crop_bottom,
                min_x <: min_x, min_y <: min_y, max_x <: max_x, max_y <: max_y );
    todraw := 0;

    while(1) {
        if( start ) {
            busy = 1;
            // Setup drawing a filled triangle x,y param0, param1, param2, param3
            x1 = x; y1 = y;
            x2 = param0; y2 = param1;
            x3 = param2; y3 = param3;
            ++:
            // Put points in order so that ( x1, y1 ) is at top, then ( x2, y2 ) and ( x3, y3 ) are clockwise from there
            if( ~y2y3 ) { tx = x2; ty = y2; x2 = x3; y2 = y3; x3 = tx; y3 = ty; ++: }
            if( ~y1y2 ) { tx = x1; ty = y1; x1 = x2; y1 = y2; x2 = tx; y2 = ty; ++: }
            if( ~y1y3 ) { tx = x1; ty = y1; x1 = x3; y1 = y3; x3 = tx; y3 = ty; ++: }
            if( ~y2y3 ) { tx = x2; ty = y2; x2 = x3; y2 = y3; x3 = tx; y3 = ty; ++: }
            if( ( y1ey2 ) & ( ~x1x2 ) ) { tx = x1; ty = y1; x1 = x2; y1 = y2; x2 = tx; y2 = ty; ++: }
            if( ( ~y1ey2 ) & ( ~y2y3 ) & ( x2x3 ) ) { tx = x2; ty = y2; x2 = x3; y2 = y3; x3 = tx; y3 = ty; ++:}

            // Find minimum and maximum of x, x1, x2, y, y1 and y2 for the bounding box
            min_x = x1x2 ? ( x1x3 ? x1 : x3 ) : ( x2x3 ? x2 : x3 ); ++:
            max_x = x1x2 ? ( x2x3 ? x3 : x2 ) : ( x1x3 ? x3 : x1 ); ++:
            min_y = y1y2 ? ( y1y3 ? y1 : y3 ) : ( y2y3 ? y2 : y3 ); ++:
            max_y = y1y2 ? ( y2y3 ? y3 : y2 ) : ( y1y3 ? y3 : y1 ); ++:
            ++:
            // Apply cropping rectangle
            min_x = ( min_x < crop_left ) ? crop_left : min_x;
            min_y = ( min_y < crop_top ) ? crop_top : min_y;
            max_x = ( max_x > crop_right ) ? crop_right : max_x;
            max_y = 1 + ( ( max_y > crop_bottom ) ? crop_bottom : max_y );
            ++:
            todraw = TODRAW.draw;
            busy = 0;
        }
    }
}
algorithm drawtriangle(
    input   uint1   start,
    output  uint1   busy(0),
    input   int11   min_x,
    input   int11   min_y,
    input   int11   max_x,
    input   int11   max_y,
    input   int11   x0,
    input   int11   y0,
    input   int11   x1,
    input   int11   y1,
    input   int11   x2,
    input   int11   y2,
    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun> {
    // Filled triangle calculations
    // Is the point px,py inside the triangle given by x0,x1 x1,y1 x2,y2?
    uint1   inTriangle <:: ( (( x2 - x1 ) * ( py - y1 ) - ( y2 - y1 ) * ( px - x1 )) >= 0 ) &
                            ( (( x0 - x2 ) * ( py - y2 ) - ( y0 - y2 ) * ( px - x2 )) >= 0 ) &
                            ( (( x1 - x0 ) * ( py - y0 ) - ( y1 - y0 ) * ( px - x0 )) >= 0 );
    uint1   beenInTriangle = uninitialized;

    // CLOSER TO LEFT OR RIGHT OF THE BOUNDING BOX
    uint1   leftright <:: ( px - min_x ) < ( max_x - px );

    // WORK COORDINATES AND DIRECTION
    int11   px = uninitialized;                         int11   pxNEXT <:: px + ( dx ? 1 : (-1) );
    int11   py = uninitialized;                         int11   pyNEXT <:: py + 1;
    uint1   dx = uninitialized;

    // DETECT IF AT LEFT/RIGHT/BOTTOM OF THE BOUNDING BOX
    uint1   stillinline <:: ( dx & ( px != max_x ) ) | ( ~dx & ( px != min_x ));
    uint1   working <:: ( py != max_y );

    bitmap_x_write := px; bitmap_y_write := py; bitmap_write := busy & inTriangle;

    while(1) {
        if( start ) {
            busy = 1;
            dx = 1; px = min_x; py = min_y;
            while( working ) {
                beenInTriangle = inTriangle | beenInTriangle;
                if( beenInTriangle ^ inTriangle ) {
                    // Exited the triangle, move to the next line
                    beenInTriangle = 0; py = pyNEXT; px = leftright ? min_x : max_x; dx = leftright;
                } else {
                    // MOVE TO THE NEXT PIXEL ON THE LINE LEFT/RIGHT OR DOWN AND SWITCH DIRECTION IF AT END
                    if( stillinline ) { px = pxNEXT; } else { dx = ~dx; beenInTriangle = 0; py = pyNEXT; }
                }
            }
            busy = 0;
        }
    }
}
algorithm triangle(
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
    input   int11   x2,
    input   int11   y2,
    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   bitmap_write
) <autorun,reginputs> {
    // VERTEX COORDINATES AND BOUNDING BOX
    preptriangle PREP(
        start <: start,
        crop_left <: crop_left, crop_right <: crop_right, crop_top <: crop_top, crop_bottom <: crop_bottom,
        x <: x, y <: y, param0 <: x1, param1 <: y1, param2 <: x2, param3 <: y2
    );

    uint1   TRIANGLEbusy = uninitialised;
    drawtriangle TRIANGLE(
        min_x <: PREP.min_x, max_x <: PREP.max_x, min_y <: PREP.min_y, max_y <: PREP.max_y,
        x0 <: PREP.x1, y0 <: PREP.y1, x1 <: PREP.x2, y1 <: PREP.y2, x2 <: PREP.x3, y2 <: PREP.y3,
        bitmap_x_write :> bitmap_x_write, bitmap_y_write :> bitmap_y_write, bitmap_write :> bitmap_write,
        start <: PREP.todraw
    );

    busy := start | PREP.busy | PREP.todraw | TRIANGLE.busy;
}

// Test it (make verilator)
algorithm main(output uint8 leds)
{
    uint32  startcycle = uninitialised;
    pulse PULSE();
    uint16  pixels = 0;

    triangle TRIANGLE(); TRIANGLE.start := 0;
    TRIANGLE.crop_left = 0; TRIANGLE.crop_right = 319; TRIANGLE.crop_top = 0; TRIANGLE.crop_bottom = 239;
    TRIANGLE.x = -5; TRIANGLE.y = 10; TRIANGLE.x1 = 20; TRIANGLE.y1 = 10; TRIANGLE.x2 = 15; TRIANGLE.y2 = 15;

    ++:
    startcycle = PULSE.cycles;
    TRIANGLE.start = 1;
    while( TRIANGLE.busy ) {
        if( TRIANGLE.bitmap_write ) {
            pixels = pixels + 1;
            __display(" %3d @ %3d, ( %3d, %3d )",pixels,PULSE.cycles-startcycle,TRIANGLE.bitmap_x_write,TRIANGLE.bitmap_y_write);
        } else {
            __display("            ( %3d, %3d )",TRIANGLE.bitmap_x_write,TRIANGLE.bitmap_y_write);
        }
    }
}

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    uint32  plus1 <:: cycles + 1;
    always {
        cycles = plus1;
    }
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
    always {
        draw = ~( ( max_x < crop_left ) | ( max_y < crop_top ) | ( min_x > crop_right ) | ( min_y > crop_bottom ) );
    }
}
