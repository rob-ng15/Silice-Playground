// 16 bit random number generator
// Translation into Silice of LFSR_Plus.v
algorithm random(
    output  uint16  g_noise_out,
    output  uint16  u_noise_out,
) <autorun> {
    uint16  rand_out <: rand_ff;
    uint16  rand_ff = 24b011000110111011010011101;
    uint18  rand_en_ff = 24b001100010011011101100101;
    uint16  temp_u_noise3 <: { rand_out[15,1], rand_out[15,1], rand_out[2,13] };
    uint16  temp_u_noise2 <: temp_u_noise3;
    uint16  temp_u_noise1 <: temp_u_noise2;
    uint16  temp_u_noise0 <: temp_u_noise1;
    uint16  temp_g_noise_nxt <:: __signed(temp_u_noise3) + __signed(temp_u_noise2) + __signed(temp_u_noise1) + __signed(temp_u_noise0) + ( rand_en_ff[9,1] ? __signed(g_noise_out) : 0 );

    g_noise_out := ( rand_en_ff[17,1] ) ? temp_g_noise_nxt : ( rand_en_ff[10,1] ) ? rand_out : g_noise_out;
    u_noise_out := ( rand_en_ff[17,1] ) ? rand_out : u_noise_out;
    rand_en_ff := { ( rand_en_ff[7,1] ^ rand_en_ff[0,1] ), rand_en_ff[1,17]};
    rand_ff := { ( rand_ff[5,1] ^ rand_ff[3,1] ^ rand_ff[2,1] ^ rand_ff[0,1] ), rand_ff[1,15] };
}

// Test it (make verilator)
algorithm main(output uint8 leds)
{
    pulse PULSE();
    random RNG();

    uint5 count = 0;
    while( count < 16 ) {
        __display("%d and %d",RNG.g_noise_out,RNG.u_noise_out);
        count = count + 1;
    }
}

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}
