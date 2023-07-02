circuitry copycoordinates( input x, input y, output x1, output y1 ) { x1 = x; y1 = y; }                                         // COPY COORDINATES CIRCUIT

// HELPER - DECIDE IF MIN/MAX ARE WITHIN CROP
unit istodraw(
    input   int11   crop_left,
    input   int11   crop_right,
    input   int11   crop_top,
    input   int11   crop_bottom,
    input   int11   min_x,
    input   int11   min_y,
    input   int11   max_x,
    input   int11   max_y,
    output  uint1   draw
) <reginputs> {
    always_after {
        draw = ~|{ ( max_x < crop_left ), ( max_y < crop_top ), ( min_x > crop_right ), ( min_y > crop_bottom ) };
    }
}

// HELPER - APPLY CROPPING RECTANGLE FOR RECTANGLES AND TRIANGLES
unit applycrop(
    input   int11   crop_left,
    input   int11   crop_right,
    input   int11   crop_top,
    input   int11   crop_bottom,
    input   int11   x1,
    input   int11   y1,
    input   int11   x2,
    input   int11   y2,
    output  int11   min_x,
    output  int11   min_y,
    output  int11   max_x,
    output  int11   max_y
) <reginputs> {
    always_after {
        min_x = ( x1 < crop_left ) ? crop_left : x1;
        max_x = ( ( x2 > crop_right ) ? crop_right : x2 );
        min_y = ( y1 < crop_top ) ? crop_top : y1;
        max_y = 1 + ( ( y2 > crop_bottom ) ? crop_bottom : y2 );
    }
}

unit swaponcondition(
    input   int11   x1,
    input   int11   x2,
    input   int11   y1,
    input   int11   y2,
    input   uint1   condition,
    output  int11   nx1,
    output  int11   nx2,
    output  int11   ny1,
    output  int11   ny2
) <reginputs> {
    always_after {
        nx1 = condition ? x2 : x1;
        nx2 = condition ? x1 : x2;
        ny1 = condition ? y2 : y1;
        ny2 = condition ? y1 : y2;
    }
}
unit minmax3(
    input   int11   n1,
    input   int11   n2,
    input   int11   n3,
    output  int11   min,
    output  int11   max
) <reginputs> {
    always_after {
        min = ( n1 < n2 ) ? ( ( n1 < n3 ) ? n1 : n3 ) : ( ( n2 < n3 ) ? n2 : n3 );
        max = ( n1 > n2 ) ? ( ( n1 > n3 ) ? n1 : n3 ) : ( ( n2 > n3 ) ? n2 : n3 );
    }
}
unit checkslope(
    input   int11   x1,
    input   int11   y1,
    input   int11   x2,
    input   int11   y2,
    input   int11   x3,
    input   int11   y3,
    output  uint1   needsswap
) <reginputs> {
    int22   slope1 <:: ( y2 - y1 ) * ( x3 - x2 );
    int22   slope2 <:: ( y3 - y2 ) * ( x2 - x1 );

    always_after {
        needsswap = ( slope1 >= slope2 );
    }
}
unit preptriangle(
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
) <reginputs> {
    swaponcondition SWAP1( x1 <: param0, y1 <: param1, x2 <: param2, y2 <: param3 );                                                            // -> ( x2, y2 ) and ( x3, y3 )
    swaponcondition SWAP2( x1 <: x, y1 <: y, x2 <: SWAP1.nx1, y2 <: SWAP1.ny1 );                                                                // -> ( x1, y1 ) and ( x2, y2 )
    swaponcondition SWAP3( x1 <: SWAP2.nx1, y1 <: SWAP2.ny1, x2 <: SWAP1.nx2, y2 <: SWAP1.ny2 );                                                // -> ( x1, y1 ) and ( x3, y3 )
    swaponcondition SWAP4( x1 <: SWAP2.nx2, y1 <: SWAP2.ny2, x2 <: SWAP3.nx2, y2 <: SWAP3.ny2 );                                                // -> ( x2, y2 ) and ( x3, y3 )
    swaponcondition SWAP5( x1 <: SWAP3.nx1, y1 <: SWAP3.ny1, x2 <: SWAP4.nx1, y2 <: SWAP4.ny1, nx1 :> x1, ny1 :> y1 );                          // -> ( x1, y1 ) and ( x2, y2 )
    swaponcondition SWAP6( x1 <: SWAP5.nx2, y1 <: SWAP5.ny2, x2 <: SWAP4.nx2, y2 <: SWAP4.ny2, nx1 :> x2, ny1 :> y2, nx2 :> x3, ny2 :> y3, condition <: MAKECLOCKWISE.needsswap );    // -> ( x2, y2 ) and ( x3, y3 )
    checkslope MAKECLOCKWISE( x1 <: SWAP5.nx1, y1 <: SWAP5.ny1, x2 <: SWAP5.nx2, y2 <: SWAP5.ny2, x3 <: SWAP4.nx2, y3 <: SWAP4.ny2 );
    // Find minimum and maximum of x, x1, x2, y, y1 and y2 for the bounding box
    minmax3 X( n1 <: x1, n2 <: x2, n3 <: x3 );      minmax3 Y( n1 <: y1, n2 <: y2, n3 <: y3 );

    applycrop CROP( crop_left <: crop_left, crop_right <: crop_right, crop_top <: crop_top, crop_bottom <: crop_bottom,
                    x1 <: X.min, y1 <: Y.min, x2 <: X.max, y2 <: Y.max, min_x :> min_x, min_y :> min_y, max_x :> max_x, max_y :> max_y );

    istodraw TODRAW( crop_left <: crop_left, crop_right <: crop_right, crop_top <: crop_top, crop_bottom <: crop_bottom,
                min_x <: CROP.min_x, min_y <: CROP.min_y, max_x <: CROP.max_x, max_y <: CROP.max_y );

    todraw := 0;

    algorithm <autorun> {
        while(1) {
            if( start ) {
                busy = 1;
                // Setup drawing a filled triangle x,y param0, param1, param2, param3
                // Allow the cascade for the coordinates
                 ++: ++: ++: ++: ++: ++: ++:                                                                                     // ( x1, y1 ) ARE TOP LEFT, THEN CLOCKWISE
                todraw = TODRAW.draw;
                busy = 0;
            }
        }
    }

    always_after {
        SWAP1.condition = ( param3 < param1 );                                                                                                   // ( y3 < y2 )
        SWAP2.condition = ( SWAP1.ny1 < y );                                                                                                     // ( y2 < y1 )
        SWAP3.condition = ( SWAP1.ny2 < SWAP2.ny1 );                                                                                             // ( y3 < y1 )
        SWAP4.condition = ( SWAP3.ny2 < SWAP2.ny2 );                                                                                             // ( y3 < y2 )
        SWAP5.condition = ( SWAP4.ny1 == SWAP3.ny1 ) & ( SWAP4.nx1 < SWAP3.nx1 ) ;                                                               // ( y2 == y1 ) & ( x2 < x1 )
    }
}
unit intriangle(
    input   int11   x0,
    input   int11   y0,
    input   int11   x1,
    input   int11   y1,
    input   int11   x2,
    input   int11   y2,
    input   int11   px,
    input   int11   py,
    output  uint1   IN
) <reginputs> {
    int23   step1 <:: (( x2 - x1 ) * ( py - y1 ) - ( y2 - y1 ) * ( px - x1 ));
    int23   step2 <:: (( x0 - x2 ) * ( py - y2 ) - ( y0 - y2 ) * ( px - x2 ));
    int23   step3 <:: (( x1 - x0 ) * ( py - y0 ) - ( y1 - y0 ) * ( px - x0 ));

    always_after {
        IN =  ~|{ step1[22,1], step2[22,1], step3[22,1] };
    }
}
unit drawtriangle(
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
    output  uint9   bitmap_x_write,
    output  uint8   bitmap_y_write,
    output  uint1   bitmap_write
) <reginputs> {
    // Filled triangle calculations
    // Is the point px,py inside the triangle given by x0,x1 x1,y1 x2,y2?
    intriangle IS( x0 <: x0, x1 <: x1, x2 <: x2, px <: px, y0 <: y0, y1 <: y1, y2 <: y2, py <: py );
    uint1   beenInTriangle = uninitialized;

    // WORK COORDINATES AND DIRECTION
    uint9   px = uninitialized;                         uint9   pxNEXT <:: px + ( dx ? 1 : (-1) );
    uint8   py = uninitialized;                         uint8   pyNEXT <:: py + 1;
    uint1   dx = uninitialized;
    uint1   eol <:: px == ( dx ? max_x : min_x );

    uint2   state = uninitialised;                  uint9   sx = uninitialised;

    bitmap_x_write := px; bitmap_y_write := py; bitmap_write := busy & IS.IN;

    always_after {
        if( start ) {
            busy = 1; dx = 1; py = min_y; state = 0;
            __display("TRI ( %3d, %3d ) ( %3d, %3d ) ( %3d, %3d )",x0,y0,x1,y1,x2,y2);
           __display("BOX ( %3d, %3d ) -> ( %3d, %3d )",min_x,min_y,max_x,max_y);
            if( ( y0 == min_y ) & ( x0 > min_x ) & ( x0 <= max_x ) ) { px = x0 - 1; } else { px = min_x; }
         } else {
            if( py != max_y ) {
                beenInTriangle = IS.IN | beenInTriangle;                                                                        // SET TO 1 IF EVER BEEN IN TRIANGLE ON THIS LINE
                switch( state ) {
                    case 0: {                                                                                                   // NORMAL STATE, MOVE UNTIL IN THEN OUT OF TRIANGLE
                        if( beenInTriangle ^ IS.IN ) {
                            beenInTriangle = 0; py = pyNEXT; state = 3;                                                         // LEFT THE TRIANGLE, MOVE TO NEXT LINE AND CHANGE STATE TO CHECK
                        } else {
                            if( eol )  {
                                dx = ~dx; beenInTriangle = 0; py = pyNEXT;                                                      // AT END OF LINE, SWITCH DIRECTION AND MOVE TO THE NEXT LINE
                            } else {
                                px = pxNEXT;                                                                    // MOVE TO THE NEXT PIXEL
                            }
                        }
                    }
                    case 1: {                                                                                                   // SECONDARY STATE, MOVED DOWN AND WAS IN TRIANGLE
                        if( ( beenInTriangle ^ IS.IN ) | eol ) {
                            px = sx; dx = ~dx; state = 0;                                                                       // LEFT THE TRIANGLE OR EOL, GOT TO SAVED POSITION, SWITCH DIRECTION, GO TO NORMAL STATE
                            __display("LOAD x = %d, TO STATE 0",px);
                        } else {
                            px = pxNEXT;                                                                    // MOVE TO THE NEXT PIXEL
                        }
                    }
                    case 2: {
                    }
                    case 3: {
                        if( IS.IN ) {
                            sx =  px + ( dx ? (-1) : 1 ); px = pxNEXT; state = 1;                               // MOVED DOWN AND IN TRIANGLE, SAVE AND MOVE TO NEXT PIXEL
                            __display("SAVED x = %d MOVE TO x = %d, TO STATE 1",sx,px);
                        } else {
                            dx = ~dx; state = 0;                                                                                // MOVED DOWN AND OUTSIDE THE TRIANGLE, SWITCH DIRECTION
                            __display("OUTSIDE, TO STATE 0");
                        }
                    }
                }
            } else {
                busy = 0;
            }
        }
    }
}
unit triangle(
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
    output  uint9   bitmap_x_write,
    output  uint8   bitmap_y_write,
    output  uint1   bitmap_write
) <reginputs> {
    // VERTEX COORDINATES AND BOUNDING BOX
    preptriangle PREP(
        start <: start,
        crop_left <: crop_left, crop_right <: crop_right, crop_top <: crop_top, crop_bottom <: crop_bottom,
        x <: x, y <: y, param0 <: x1, param1 <: y1, param2 <: x2, param3 <: y2
    );

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
    TRIANGLE.x = 188; TRIANGLE.y = 196; TRIANGLE.x1 = 329; TRIANGLE.y1 = 232; TRIANGLE.x2 = 27; TRIANGLE.y2 = 14;

    ++:
    startcycle = PULSE.cycles;
    TRIANGLE.start = 1;
    while( TRIANGLE.busy ) {
        if( TRIANGLE.bitmap_write ) {
            pixels = pixels + 1;
            __display(" %3d @ %3d, ( %3d, %3d )",pixels,PULSE.cycles-startcycle,TRIANGLE.bitmap_x_write,TRIANGLE.bitmap_y_write);
        } else {
            __display("-----------( %3d, %3d )",TRIANGLE.bitmap_x_write,TRIANGLE.bitmap_y_write);
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
