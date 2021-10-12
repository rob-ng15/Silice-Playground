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
    uint2   bitstreamh <:: bitstream[2,2];
    uint2   bitstreaml <:: bitstream[0,2];
    uint2   czh = uninitialised; cz2 CZ2H( bitstream <: bitstreamh, cz2 :> czh );
    uint2   czl = uninitialised; cz2 CZ2L( bitstream <: bitstreaml, cz2 :> czl );

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
    uint4   bitstreamh <:: bitstream[4,4];
    uint4   bitstreaml <:: bitstream[0,4];
    uint3   czh = uninitialised; cz4 CZ4H( bitstream <: bitstreamh, cz4 :> czh );
    uint3   czl = uninitialised; cz4 CZ4L( bitstream <: bitstreaml, cz4 :> czl );

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
    uint8   bitstreamh <:: bitstream[8,8];
    uint8   bitstreaml <:: bitstream[0,8];
    uint4   czh = uninitialised; cz8 CZ8H( bitstream <: bitstreamh, cz8 :> czh );
    uint4   czl = uninitialised; cz8 CZ8L( bitstream <: bitstreaml, cz8 :> czl );

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
    uint16  bitstreamh <:: bitstream[16,16];
    uint16  bitstreaml <:: bitstream[0,16];
    uint5   czh = uninitialised; cz16 CZ16H( bitstream <: bitstreamh, cz16 :> czh );
    uint5   czl = uninitialised; cz16 CZ16L( bitstream <: bitstreaml, cz16 :> czl );

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
    output  uint7   cz48
) <autorun> {
    uint16  bitstreamh <:: bitstream[32,16];
    uint32  bitstreaml <:: bitstream[0,32];
    uint5   czh = uninitialised; cz16 CZ16H( bitstream <: bitstreamh, cz16 :> czh );
    uint6   czl = uninitialised; cz32 CZ32L( bitstream <: bitstreaml, cz32 :> czl );

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

    uint48  bitstream = 0;
    uint48  normalised = uninitialised;
    uint7   cz = uninitialised;
    cz48 CZ48( bitstream <: bitstream, cz48 :> cz );

    normalised = bitstream << cz;
    __display("Input = %b, CLZ = %d", bitstream, cz);
    __display("Output = %b", normalised);
}

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}
