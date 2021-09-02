circuitry copycoordinates( input x, input y, output x1, output y1 ) {
    x1 = x;
    y1 = y;
}

algorithm main(output int8 leds) {
    // CYCLE COUNTER
    uint32  startcycle = uninitialised;
    pulse PULSE();

    int16  bitmap_x_write = uninitialised;
    int16  bitmap_y_write = uninitialised;
    uint1  bitmap_write = uninitialised;

    int16   x = 100;
    int16   y = 100;
    uint8   tile = 102;
    uint2   scale = 0;
    uint3   action = 2;
    uint1   tilecharacter = 1;

    // POSITION IN TILE/CHARACTER
    uint5   px = uninitialized;
    uint5   py = uninitialized;

    // POSITION ON THE SCREEN AND WITHIN THE PIXEL COUNT FOR SCALING
    int16   x1 = uninitialized;
    uint5   x2 = uninitialised;
    int16   y1 = uninitialized;
    uint5   y2 = uninitialised;
    uint5   maxcount <:: ( 1 << scale );

    // MULTIPLIER FOR THE SIZE
    uint5   max_pixels <:: tilecharacter ? 16 : 8;

    bitmap_x_write := x1 + ( px << scale ) + x2; bitmap_y_write := y1 + ( py << scale ) + y2; bitmap_write := 0;

    // CLOCK CYCLES TO ALLOW SIGNALS TO PROPOGATE - REQUIRED FOR VERILATOR
    ++: ++:
    startcycle = PULSE.cycles;

    __display("BLIT TILE = %0d of %d pixels to (%0d,%0d) at scale = %0d with action = %d",tile,max_pixels,x,y,scale,action);
    px = 0; py = 0; y2 = 0; x2 = 0;
    ( x1, y1 ) = copycoordinates( x, y );
    switch( maxcount ) {
        case 1: {
            while( py != max_pixels ) {
                if( px != max_pixels ) {
                    bitmap_write = tilecharacter ? blit1tilemap.rdata0[4b1111 - xinblittile, 1] : characterGenerator8x8.rdata0[7 - xinchartile, 1];
                    px = px + 1;
                } else {
                    px = 0;
                    py = py + 1;
                }
            }
        }
        default: {
            while( py != max_pixels ) {
                if( px != max_pixels ) {
                    if( y2 != maxcount ) {
                        if( x2 != maxcount ) {
                            bitmap_write = tilecharacter ? blit1tilemap.rdata0[4b1111 - xinblittile, 1] : characterGenerator8x8.rdata0[7 - xinchartile, 1];
                            x2 = x2 + 1;
                        } else {
                            y2 = y2 + 1;
                            x2 = 0;
                        }
                    } else {
                        px = px + 1;
                        y2 = 0;
                    }
                } else {
                    px = 0;
                    py = py + 1;
                }
            }
        }
    }

    __display("");
    __display("CYCLES = %0d",PULSE.cycles - startcycle);
}

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}
