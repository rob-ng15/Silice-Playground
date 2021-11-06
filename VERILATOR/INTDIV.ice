// From recursive Verilog module
// https://electronics.stackexchange.com/questions/196914/verilog-synthesize-high-speed-leading-zero-count


algorithm main(output uint8 leds)
{
    uint32  dividend = 100;
    uint32  divisor = 9;
    uint32  quotient = uninitialised;
    uint32 remainder = uninitialised;

    uint32  temporary <:: { remainder[0,31], dividend[bit,1] };
    uint1   bitresult <:: __unsigned(temporary) >= __unsigned(divisor);
    uint6   bit(63);

    always {
        if( ~&bit ) {
            quotient[bit,1] = bitresult;
            remainder = __unsigned(temporary) - ( bitresult ? __unsigned(divisor) : 0 );
            bit = bit - 1;
        }
    }

    __display("%d / %d",dividend,divisor);
    bit = 31; quotient = 0; remainder = 0;

    while( ~&bit ) {}
    __display("%d / %d = %d with %d remainder",dividend,divisor,quotient,remainder);
}

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}
