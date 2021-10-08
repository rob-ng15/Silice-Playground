algorithm pulsecursor(
    output  uint1   show
) <autorun> {
    uint24  counter25mhz = 0;
    uint1   MAX <:: ( counter25mhz == 12500000 );

    show := MAX ? ~show : show;
    always {
        counter25mhz = MAX ? 0 : counter25mhz + 1;
    }
}

// Create 1hz (1 second counter)
algorithm pulse1hz(
    output  uint16  counter1hz,
    input   uint1   resetCounter
) <autorun> {
    uint25  counter25mhz = 0;
    uint1   MAX <:: ( counter25mhz == 25000000 );

    always {
        counter1hz = resetCounter ? 0 : counter1hz + MAX;
        counter25mhz = resetCounter | MAX ? 0 : counter25mhz + 1;
    }
}

// Create 1khz (1 milli-second counter)
algorithm pulse1khz(
    output  uint16  counter1khz,
    input   uint16  resetCounter
) <autorun> {
    uint15  counter25mhz = 0;
    uint1   MAX <:: ( counter25mhz == 25000 );
    uint1   RESET <:: ( resetCounter != 0 );
    uint1   FINISHED <:: ( counter1khz == 0 );
    always {
        counter1khz = RESET ? resetCounter : FINISHED ? 0 : counter1khz - MAX;
        counter25mhz = RESET | MAX ? 0 : counter25mhz + 1;
    }
}

// 16 bit random number generator
// Translation into Silice of LFSR_Plus.v
algorithm random(
    output  uint16  g_noise_out,
    output  uint16  u_noise_out,
) <autorun> {
    uint16  rand_out <:: rand_ff;
    uint16  rand_ff = 24b011000110111011010011101;
    uint18  rand_en_ff = 24b001100010011011101100101;
    uint16  temp_u_noise3 <:: { rand_out[15,1], rand_out[15,1], rand_out[2,13] };
    uint16  temp_u_noise2 <:: temp_u_noise3;
    uint16  temp_u_noise1 <:: temp_u_noise2;
    uint16  temp_u_noise0 <:: temp_u_noise1;
    uint16  temp_g_noise_nxt <:: __signed(temp_u_noise3) + __signed(temp_u_noise2) + __signed(temp_u_noise1) + __signed(temp_u_noise0) + ( rand_en_ff[9,1] ? __signed(g_noise_out) : 0 );

    always {
        g_noise_out = ( rand_en_ff[17,1] ) ? temp_g_noise_nxt : ( rand_en_ff[10,1] ) ? rand_out : g_noise_out;
        u_noise_out = ( rand_en_ff[17,1] ) ? rand_out : u_noise_out;
        rand_en_ff = { ( rand_en_ff[7,1] ^ rand_en_ff[0,1] ), rand_en_ff[1,17]};
        rand_ff = { ( rand_ff[5,1] ^ rand_ff[3,1] ^ rand_ff[2,1] ^ rand_ff[0,1] ), rand_ff[1,15] };
    }
}
