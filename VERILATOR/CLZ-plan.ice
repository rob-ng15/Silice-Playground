algorithm cz2(
    input   uint2   bitstream,
    output  uint2   cz2
) <autorun> {
    always {
        switch( bitstream ) {
            case 2b00: { cz2 = 2; }
            case 2b01: { cz2 = 1; }
            default: { cz2 = 0; }
        }
    }
}
algorithm cz4(
    input   uint4   bitstream,
    output  uint3   cz4
) <autorun> {
    uint2   czh = uninitialised; cz2 CZ2H( bitstream <: bitstream[2,2], cz2 :> czh );
    uint2   czl = uninitialised; cz2 CZ2L( bitstream <: bitstream[0,2], cz2 :> czl );

    always {
        if( czh[1,1] ) {
            cz4 = czh + czl;
        } else {
            cz4 = czh;
        }
    }
}
algorithm cz8(
    input   uint8   bitstream,
    output  uint4   cz8
) <autorun> {
    uint3   czh = uninitialised; cz4 CZ4H( bitstream <: bitstream[4,4], cz4 :> czh );
    uint3   czl = uninitialised; cz4 CZ4L( bitstream <: bitstream[0,4], cz4 :> czl );

    always {
        if( czh[2,1] ) {
            cz8 = czh + czl;
        } else {
            cz8 = czh;
        }
    }
}
algorithm cz16(
    input   uint16  bitstream,
    output  uint5   cz16
) <autorun> {
    uint4   czh = uninitialised; cz8 CZ8H( bitstream <: bitstream[8,8], cz8 :> czh );
    uint4   czl = uninitialised; cz8 CZ8L( bitstream <: bitstream[0,8], cz8 :> czl );

    always {
        if( czh[3,1] ) {
            cz16 = czh + czl;
        } else {
            cz16 = czh;
        }
    }
}
algorithm cz32(
    input   uint32  bitstream,
    output  uint6   cz32
) <autorun> {
    uint5   czh = uninitialised; cz16 CZ16H( bitstream <: bitstream[16,16], cz16 :> czh );
    uint5   czl = uninitialised; cz16 CZ16L( bitstream <: bitstream[0,16], cz16 :> czl );

    always {
        if( czh[4,1]) {
            cz32 = czh + czl;
        } else {
            cz32 = czh;
        }
    }
}
algorithm cz48(
    input   uint48  bitstream,
    output  uint6   cz48
) <autorun> {
    uint5   czh = uninitialised; cz16 CZ16H( bitstream <: bitstream[32,16], cz16 :> czh );
    uint6   czl = uninitialised; cz32 CZ32L( bitstream <: bitstream[0,32], cz32 :> czl );

    always {
        if( czh[4,1] ) {
            cz48 = czh + czl;
        } else {
            cz48 = czh;
        }
    }
}

algorithm main(output int8 leds) {
    // CYCLE COUNTER
    uint32  startcycle = uninitialised;
    pulse PULSE();

    uint48  bitstream = 12345678;
    uint48  normalised = uninitialised;
    uint6   cz = uninitialised;
    cz48 CZ48( bitstream <: bitstream, cz48 :> cz );

    normalised = bitstream << cz;
    __display("Input = %b, CLZ = %d", bitstream, cz);
    __display("Output = %b after normalisation", normalised);
}

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}
