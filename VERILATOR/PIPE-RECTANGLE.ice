unit rectangle(
    input   uint1   start,
    output  uint1   busy(0),

    input   int11   x1,
    input   int11   y1,
    input   int11   x2,
    input   int11   y2,

    output  int11   bitmap_x_write,
    output  int11   bitmap_y_write,
    output  uint1   bitmap_write
) <reginputs> {

    algorithm <autorun> {
        while(1) {

            {
                if( start ) {
                    busy = 1;
                }
            } -> {
            } -> {
            } -> {
                if( finished ) {
                    busy = 0;
                }
            }

        }
    }
}

// Test it (make verilator)
algorithm main(output uint8 leds)
{
    uint32  startcycle = uninitialized;
    pulse PULSE();


}

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}
