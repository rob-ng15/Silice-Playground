// FIXED FLOAT 16.16 DIVISION ACCELERATOR
unit fixed_t_divide(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint32  fixed_t_a,
    input   uint32  fixed_t_b,
    output  uint32  result
) <reginputs> {
    uint48  quotient = uninitialised;
    uint48  remainder = uninitialised;
    uint48  dividend <:: { fixed_t_a[31,1] ? -fixed_t_a : fixed_t_a, 16b0 };                                                   // LEFT ALIGN ABSOLUTE VALUE OF DIVIDEND
    uint48  divisor <:: { 16b0, fixed_t_b[31,1] ? -fixed_t_b : fixed_t_b };                                                               // RIGHT ALIGN ABSOLUTE VALUE OF DIVISOR
    uint48  temporary <:: { remainder[0,47], dividend[bit,1] };
    uint1   bitresult <:: __unsigned(temporary) >= __unsigned(divisor);
    uint6   bit = uninitialised;
    uint1   update = uninitialised;
    uint1   notdivzero <:: |fixed_t_b;

    update := 0;

    algorithm <autorun> {
        while(1) {
            if( start & notdivzero ) {
                __display("%x / %x",dividend,divisor);
                busy = 1; while( ~&bit ) { update = 1; } busy = 0;
            }                                     // ONLY RUN IF DIVISOR != 0
        }
    }

    // START DIVIDER AND EXTRACT RESULT
    always_after {
        { if( start ) { quotient = 0; } else { if( update ) { quotient[bit,1] = bitresult; } } }
        { if( start ) { remainder = 0; } else { if( update ) { remainder = __unsigned(temporary) - ( bitresult ? __unsigned(divisor) : 0 ); } } }
        { bit = start ? 47 : bit - update; }
        {
                result = notdivzero ? ( fixed_t_a[31,1] ^ fixed_t_b[31,1] ? -quotient : quotient ) : 32hffffffff;               // RESULT CORRECTLY SIGNED OR -1 FOR /0
        }
    }
}

algorithm main(output uint8 leds)
{
    fixed_t_divide DIVIDER();
    DIVIDER.start := 0;

    //DIVIDER.fixed_t_a = 32hFFFE8000;        // -1.5
    //DIVIDER.fixed_t_b = 32h8000;            // 0.5
                                            // RESULT -3 = FFFD0000

    DIVIDER.fixed_t_a = 32h00030000;        // 3
    DIVIDER.fixed_t_b = 32hFFFE8000;        // -1.5
                                            // RESULT -2 = FFFE0000

    ++: ++:

    DIVIDER.start = 1; while( DIVIDER.busy ) {}
    __display("a (%x) / b (%x) = %x",DIVIDER.fixed_t_a,DIVIDER.fixed_t_b,DIVIDER.result);
}
