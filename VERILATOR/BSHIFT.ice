algorithm bshiftleft(
    input   uint32  bitstream,
    input   uint5   shiftcount,
    output  uint32  result
) <autorun> {
    always {
        switch( shiftcount ) {
            case 0: { result = bitstream; }
            $$for i=1,31 do
            case $i$: { result = { bitstream[ 0, $32-i$ ], $i$b0 }; }
            $$end
        }
    }
}
algorithm bshiftright(
    input   uint32  bitstream,
    input   uint5   shiftcount,
    input   uint1   LA,
    output  uint32  result
) <autorun> {
    uint1   shiftin <:: LA & bitstream[31,1];
    always {
        switch( shiftcount ) {
            case 0: { result = bitstream; }
            $$for i=1,31 do
            case $i$: { result = { {$i${shiftin}}, bitstream[ $i$, $32-i$ ] }; }
            $$end
        }
    }
}

// Test it (make verilator)
algorithm main(output uint8 leds)
{
    pulse PULSE();

    uint32  bitstream = 32h80000001; uint5 shift = 5;
    bshiftleft SLL( bitstream <: bitstream , shiftcount <: shift );
    bshiftright SRL( bitstream <: bitstream, shiftcount <: shift );
    bshiftright SRA( bitstream <: bitstream, shiftcount <: shift );
    SRL.LA = 0; SRA.LA = 1;
    ++:
    __display("IN = %b, shift = %0d,  LEFT L = %b",bitstream,shift,SLL.result);
    __display("IN = %b, shift = %0d, RIGHT L = %b",bitstream,shift,SRL.result);
    __display("IN = %b, shift = %0d, RIGHT A = %b",bitstream,shift,SRA.result);
    __display("PULSES = %0d",PULSE.cycles);
}

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}
