algorithm cz8(
    input   uint8   bitstream,
    output  uint4   cz
) <autorun> {
    always {
        if( bitstream == 0 ) {
            cz = 8;
        } else {
            if( bitstream[1,7] == 0 ) {
                cz = 7;
            } else {
                if( bitstream[2,6] == 0 ) {
                    cz = 6;
                } else {
                    if( bitstream[3,5] == 0 ) {
                        cz = 5;
                    } else {
                        if( bitstream[4,4] == 0 ) {
                            cz = 4;
                        } else {
                            if( bitstream[5,3] == 0 ) {
                                cz = 3;
                            } else {
                                if( bitstream[6,2] == 0 ) {
                                    cz = 2;
                                } else {
                                    cz = bitstream[7,1] ? 0 : 1;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
algorithm cz32(
    input   uint32  bitstream,
    output  uint6   cz
) <autorun> {
    uint8   block0 <:: bitstream[24,8];
    uint8   block1 <:: bitstream[16,8];
    uint8   block2 <:: bitstream[8,8];
    uint8   block3 <:: bitstream[0,8];
    uint4   cz0 = uninitialised; cz8 CZ80( bitstream <: block0, cz :> cz0 );
    uint4   cz1 = uninitialised; cz8 CZ81( bitstream <: block1, cz :> cz1 );
    uint4   cz2 = uninitialised; cz8 CZ82( bitstream <: block2, cz :> cz2 );
    uint4   cz3 = uninitialised; cz8 CZ83( bitstream <: block3, cz :> cz3 );

    always {
        if( cz0[3,1] ) {
            if( cz1[3,1] ) {
                if( cz2[3,1] ) {
                    if( cz3[3,1] ) {
                        cz = 32;
                    } else {
                        cz = 24 + cz3;
                    }
                } else {
                    cz = 16 + cz2;
                }
            } else {
                cz = 8 + cz1;
            }
        } else {
            cz = cz0;
        }
    }
}
algorithm cz48(
    input   uint48  bitstream,
    output  uint6   cz
) <autorun> {
    uint8   block0 <:: bitstream[40,8];
    uint8   block1 <:: bitstream[32,8];
    uint8   block2 <:: bitstream[24,8];
    uint8   block3 <:: bitstream[16,8];
    uint8   block4 <:: bitstream[8,8];
    uint8   block5 <:: bitstream[0,8];
    uint4   cz0 = uninitialised; cz8 CZ80( bitstream <: block0, cz :> cz0 );
    uint4   cz1 = uninitialised; cz8 CZ81( bitstream <: block1, cz :> cz1 );
    uint4   cz2 = uninitialised; cz8 CZ82( bitstream <: block2, cz :> cz2 );
    uint4   cz3 = uninitialised; cz8 CZ83( bitstream <: block3, cz :> cz3 );
    uint4   cz4 = uninitialised; cz8 CZ84( bitstream <: block4, cz :> cz4 );
    uint4   cz5 = uninitialised; cz8 CZ85( bitstream <: block5, cz :> cz5 );

    always {
        if( cz0[3,1] ) {
            if( cz1[3,1] ) {
                if( cz2[3,1] ) {
                    if( cz3[3,1] ) {
                        if( cz4[3,1] ) {
                            if( cz[5,1] ) {
                                cz = 48;
                            } else {
                                cz = 40 + cz5;
                            }
                        } else {
                            cz = 32 + cz4;
                        }
                    } else {
                        cz = 24 + cz3;
                    }
                } else {
                    cz = 16 + cz2;
                }
            } else {
                cz = 8 + cz1;
            }
        } else {
            cz = cz0;
        }
    }
}

algorithm main(output int8 leds) {
    // CYCLE COUNTER
    uint32  startcycle = uninitialised;
    pulse PULSE();

    uint48  bitstream = 32768;
    uint48  normalised = uninitialised;
    uint7   cz = uninitialised;
    cz48 CZ48( bitstream <: bitstream, cz :> cz );

    normalised = bitstream << cz;
    __display("Input = %b, CLZ = %d", bitstream, cz);
    __display("Output = %b", normalised);
}

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}
