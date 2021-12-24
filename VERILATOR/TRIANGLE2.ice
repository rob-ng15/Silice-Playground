// COPY COORDINATES
circuitry copycoordinates( input x, input y, output x1, output y1 ) {
    x1 = x;
    y1 = y;
}

// TRIANGLE - OUTPUT PIXELS TO DRAW A FILLED TRIANGLE
algorithm swaponcondition(
    input   int11   x1,
    input   int11   x2,
    input   int11   y1,
    input   int11   y2,
    input   uint1   condition,
    output  int11   nx1,
    output  int11   nx2,
    output  int11   ny1,
    output  int11   ny2
) <autorun,reginputs> {
    always_after {
        if( condition ) {
            nx1 = x2; ny1 = y2;
            nx2 = x1; ny2 = y1;
        } else {
            nx1 = x1; ny1 = y1;
            nx2 = x2; ny2 = y2;
        }
    }
}
algorithm min3(
    input   int11   n1,
    input   int11   n2,
    input   int11   n3,
    output  int11   min
) <autorun> {
    always_after {
        min = ( n1 < n2 ) ? ( ( n1 < n3 ) ? n1 : n3 ) : ( ( n2 < n3 ) ? n2 : n3 );
    }
}
algorithm max3(
    input   int11   n1,
    input   int11   n2,
    input   int11   n3,
    output  int11   max
) <autorun> {
    always_after {
        max = ( n1 > n2 ) ? ( ( n1 > n3 ) ? n1 : n3 ) : ( ( n2 > n3 ) ? n2 : n3 );
    }
}
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
    output  uint9   min_x,
    output  uint8   min_y,
    output  uint9   max_x,
    output  uint8   max_y,
    output  uint1   todraw
) <autorun> {
    swaponcondition SWAP();

    // Find minimum and maximum of x, x1, x2, y, y1 and y2 for the bounding box
    min3 Xmin( n1 <: x1, n2 <: x2, n3 <: x3 );      min3 Ymin( n1 <: y1, n2 <: y2, n3 <: y3 );
    max3 Xmax( n1 <: x1, n2 <: x2, n3 <: x3 );      max3 Ymax( n1 <: y1, n2 <: y2, n3 <: y3 );

    istodraw TODRAW( crop_left <: crop_left, crop_right <: crop_right, crop_top <: crop_top, crop_bottom <: crop_bottom,
                min_x <: min_x, min_y <: min_y, max_x <: max_x, max_y <: max_y );
    todraw := 0;

    while(1) {
        if( start ) {
            busy = 1;
            // Setup drawing a filled triangle x,y param0, param1, param2, param3 ( Copy to x1, y1, x2, y2, x3, y3 )
            ( x1, y1 ) = copycoordinates ( x, y );
            ( x2, y2 ) = copycoordinates ( param0, param1 );
            ( x3, y3 ) = copycoordinates ( param2, param3 );

            // Put points in order so that ( x1, y1 ) is at top, then ( x2, y2 ) and ( x3, y3 ) are clockwise from there
            SWAP.x1 = x2; SWAP.y1 = y2; SWAP.x2 = x3; SWAP.y2 = y3; SWAP.condition = ( y3 < y2 ); ++: x2 = SWAP.nx1; y2 = SWAP.ny1; x3 = SWAP.nx2; y3 = SWAP.ny2;
            SWAP.x1 = x1; SWAP.y1 = y1; SWAP.x2 = x2; SWAP.y2 = y2; SWAP.condition = ( y2 < y1 ); ++: x1 = SWAP.nx1; y1 = SWAP.ny1; x2 = SWAP.nx2; y2 = SWAP.ny2;
            SWAP.x1 = x1; SWAP.y1 = y1; SWAP.x2 = x3; SWAP.y2 = y3; SWAP.condition = ( y3 < y1 ); ++: x1 = SWAP.nx1; y1 = SWAP.ny1; x3 = SWAP.nx2; y3 = SWAP.ny2;
            SWAP.x1 = x2; SWAP.y1 = y2; SWAP.x2 = x3; SWAP.y2 = y3; SWAP.condition = ( y3 < y2 ); ++: x2 = SWAP.nx1; y2 = SWAP.ny1; x3 = SWAP.nx2; y3 = SWAP.ny2;
            SWAP.x1 = x1; SWAP.y1 = y1; SWAP.x2 = x2; SWAP.y2 = y2; SWAP.condition = ( ( y2 == y1 ) & ( x2 < x1 ) ); ++: x1 = SWAP.nx1; y1 = SWAP.ny1; x2 = SWAP.nx2; y2 = SWAP.ny2;
            SWAP.x1 = x2; SWAP.y1 = y2; SWAP.x2 = x3; SWAP.y2 = y3; SWAP.condition = ( ( y2 != y1 ) & ( y3 >= y2 ) & ( x2 < x3 ) ); ++: x2 = SWAP.nx1; y2 = SWAP.ny1; x3 = SWAP.nx2; y3 = SWAP.ny2;

            // Apply cropping rectangle
            min_x = ( Xmin.min < crop_left ) ? crop_left : Xmin.min;
            min_y = ( Ymin.min < crop_top ) ? crop_top : Ymin.min;
            max_x = ( Xmax.max > crop_right ) ? crop_right : Xmax.max;
            max_y = 1 + ( ( Ymax.max > crop_bottom ) ? crop_bottom : Ymax.max );
            ++:
            todraw = TODRAW.draw;
            busy = 0;
        }
    }
}
algorithm intriangle(
    input   int11   x0,
    input   int11   y0,
    input   int11   x1,
    input   int11   y1,
    input   int11   x2,
    input   int11   y2,
    input   int11   px,
    input   int11   py,
    output  uint1   IN
) <autorun> {
    int22   step1 <:: (( x2 - x1 ) * ( py - y1 ) - ( y2 - y1 ) * ( px - x1 ));
    int22   step2 <:: (( x0 - x2 ) * ( py - y2 ) - ( y0 - y2 ) * ( px - x2 ));
    int22   step3 <:: (( x1 - x0 ) * ( py - y0 ) - ( y1 - y0 ) * ( px - x0 ));

    always_after {
        IN =  ~|{ step1[21,1], step2[21,1], step3[21,1] };
    }
}
algorithm drawtriangle(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint9   min_x,
    input   uint8   min_y,
    input   uint9   max_x,
    input   uint8   max_y,
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
    intriangle IS( x0 <: x0, x1 <: x1, x2 <: x2, px <: px, y0 <: y0, y1 <: y1, y2 <: y2, py <: py );
    uint1   beenInTriangle = uninitialized;

    // CLOSER TO LEFT OR RIGHT OF THE BOUNDING BOX
    uint1   leftright <:: ( px - min_x ) < ( max_x - px );

    // WORK COORDINATES AND DIRECTION
    uint9   px = uninitialized;                         uint9   pxNEXT <:: px + ( dx ? 1 : (-1) );
    uint8   py = uninitialized;                         uint8   pyNEXT <:: py + 1;
    uint1   dx = uninitialized;

    // DETECT IF AT LEFT/RIGHT/BOTTOM OF THE BOUNDING BOX
    uint1   stillinline <:: ( dx & ( px != max_x ) ) | ( ~dx & ( px != min_x ));
    uint1   working <:: ( py != max_y );

    bitmap_x_write := px; bitmap_y_write := py; bitmap_write := busy & IS.IN;

    always {
        if( start ) {
            busy = 1; dx = 1; px = min_x; py = min_y;
        } else {
            if( working ) {
                beenInTriangle = IS.IN | beenInTriangle;
                if( beenInTriangle ^ IS.IN ) {
                    // Exited the triangle, move to the next line
                    beenInTriangle = 0; py = pyNEXT; px = pxNEXT; dx = ~dx;
                } else {
                    // MOVE TO THE NEXT PIXEL ON THE LINE LEFT/RIGHT OR DOWN AND SWITCH DIRECTION IF AT END
                    if( stillinline ) { px = pxNEXT; } else { dx = ~dx; beenInTriangle = 0; py = pyNEXT; }
                }
            } else {
                busy = 0;
            }
        }
    }
}
algorithm triangle(
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
    always_after {
        draw = ~|{ ( max_x < crop_left ), ( max_y < crop_top ), ( min_x > crop_right ), ( min_y > crop_bottom ) };
    }
}
