// ALU FOR CARRYLESS MULTIPLY FROM B-EXTENSION
unit aluCLMUL(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint2   function3,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    output  uint32  result
) <reginputs> {
    uint6   startat <:: &function3;
    uint6   stopat <:: function3[0,1] ? 32 : 31;
    uint6   count = uninitialised;
    uint1   update = uninitialised;
    uint32  resultNEXT <:: result ^ ( ( function3[1,1] ) ? ( sourceReg1 >> ( ( function3[0,1] ? 31 : 32 ) - count ) ) : ( sourceReg1 << count ) );
    update := 0;

    algorithm <autorun> {
        while(1) {
            if( start ) { busy = 1; while( count != stopat ) { update = 1; } busy = 0; }
        }
    }

    always_after {
        { if( start ) { result = 0; } else { if( update ) { if( sourceReg2[ count, 1 ] ) { result = resultNEXT; } } } }
        { count = start ? startat : count + update; }
    }
}

algorithm main(output uint8 leds)
{
    aluCLMUL CLMUL();
    CLMUL.start := 0;

    CLMUL.sourceReg1 = 32h00001234;
    CLMUL.sourceReg2 = 32h00005678;

    ++: ++:

    CLMUL.start = 1; while( CLMUL.busy ) {}
    __display("a (%x) clmul b (%x) = %x",CLMUL.sourceReg1,CLMUL.sourceReg2,CLMUL.result);
}
