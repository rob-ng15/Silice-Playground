// ECHO A
16h8041,        // 41                           L
16h8ffe,        // 0ffe                         L
16h6600,        // invert                       ~
16h6c00,        // read [T]                     u s or m
16h8002,        // 2                            L
16h6303,        // &        0 -1                &
16h4010,        // call 0= @ 20                 C
16h2001,        // 0branch                      0
16h8fff,        // 0fff                         L
16h6600,        // invert                       ~
16h6023,        // [T]                          o or w
16h610f,        // N        -1 -1               N
16h0000,        // branch 0                     B
16h0000,
16h0000,
16h0000,
16h8000,        // 0                            L
16h770f         // = and return                 =
