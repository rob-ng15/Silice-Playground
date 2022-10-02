// FIXED FLOAT 16.16 DIVISION ACCELERATOR
algorithm do_fixed_t_divide(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint48  dividend,
    input   uint48  divisor,
    output  uint48  quotient
) <reginputs> {
    uint48  remainder = uninitialised;
    uint6   bit(63);
    uint6   bitNEXT <:: bit - 1;
    uint48  temporary <:: { remainder[0,47], dividend[bit,1] };
    uint1   bitresult <:: __unsigned(temporary) >= __unsigned(divisor);

    busy := start | ( ~&bit );

    always_after {
        if( &bit ) {
            if( start ) {
                bit = 47; quotient = 0; remainder = 0;
                __display("%b / %b",dividend,divisor);
            }
        } else {
            quotient[bit,1] = bitresult;
            remainder = __unsigned(temporary) - ( bitresult ? __unsigned(divisor) : 0 );
            bit = bitNEXT;
        }
    }
}

algorithm fixed_t_divide(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint32  fixed_t_a,
    input   uint32  fixed_t_b,
    output  uint32  result
) <reginputs> {
    uint32  absA <:: fixed_t_a[31,1] ? -fixed_t_a : fixed_t_a;
    uint32  absB <:: fixed_t_b[31,1] ? -fixed_t_b : fixed_t_b;
    do_fixed_t_divide DOFIXEDDIVIDE();

    DOFIXEDDIVIDE.dividend := { absA, 16b0 };
    DOFIXEDDIVIDE.divisor := { 16b0, absB };
    DOFIXEDDIVIDE.start := start & |fixed_t_b; busy := start | DOFIXEDDIVIDE.busy;

    // START DIVIDER AND EXTRACT RESULT
    always_after {
        if( busy ) {
            result = ( ~|fixed_t_b ) ? 32hffffffff : fixed_t_a[31,1] ^ fixed_t_b[31,1] ? -DOFIXEDDIVIDE.quotient : DOFIXEDDIVIDE.quotient;
        }
    }
}

algorithm main(output uint8 leds)
{
    fixed_t_divide DIVIDER();
    DIVIDER.start := 0;

    DIVIDER.fixed_t_a = 32h40000;       // 4.0
    DIVIDER.fixed_t_b = 32h8000;        // 0.5


    ++: ++:

    DIVIDER.start = 1; while( DIVIDER.busy ) {}
    __display("a (%x) / b (%x) = %x",DIVIDER.fixed_t_a,DIVIDER.fixed_t_b,DIVIDER.result);
}
