// Create 1hz (1 second counter, also can output the baseline 50MHz counter)
algorithm pulse1hz(
    output! uint16  counter1hz,
    input   uint1   resetCounter
) <autorun> {
    uint26  counter50mhz = 0;
    counter1hz = 0;

    while (1) {
        if( resetCounter == 1) {
            counter1hz = 0;
            counter50mhz = 0;
        } else {
            counter1hz = ( counter50mhz == 50000000 ) ? counter1hz + 1 : counter1hz;
            counter50mhz = ( counter50mhz == 50000000 ) ? 0 : counter50mhz + 1;
        }
    }
}

// Create 1khz (1 milli-second counter)
algorithm pulse1khz(
    output! uint16  counter1khz,
    input   uint16  resetCount
) <autorun> {
    uint16 counter50mhz = 0;

    while (1) {
        if( resetCount != 0 ) {
            counter1khz = resetCount;
            counter50mhz = 0;
        } else {
            counter1khz = ( counter1khz == 0 ) ? 0 : ( counter50mhz == 50000 ) ? counter1khz - 1 : counter1khz;
            counter50mhz = ( counter50mhz == 50000 ) ? 0 : counter50mhz + 1;
        }
    }
}

// 16 bit random number generator
// Translation into Silice of LFSR_Plus.v
algorithm random(
    output! uint16  g_noise_out,
    output! uint16  u_noise_out,
) <autorun> {
    uint16  rand_out = 0;
    uint16  rand_ff = 24b011000110111011010011101;
    uint18  rand_en_ff = 24b001100010011011101100101;
    uint16  temp_u_noise3 = 0;
    uint16  temp_u_noise2 = 0;
    uint16  temp_u_noise1 = 0;
    uint16  temp_u_noise0 = 0;
    uint16  temp_g_noise_nxt = uninitialized;

    g_noise_out := ( rand_en_ff[17,1] ) ? temp_g_noise_nxt : ( rand_en_ff[10,1] ) ? rand_out : g_noise_out;
    u_noise_out := ( rand_en_ff[17,1] ) ? rand_out : u_noise_out;

    while(1) {
        rand_en_ff = {(rand_en_ff[7,1] ^ rand_en_ff[0,1]) , rand_en_ff[1,17]};
        rand_ff = { ( rand_ff[5,1] ^ rand_ff[3,1] ^ rand_ff[2,1] ^ rand_ff[0,1]) , rand_ff[1,15] };
        rand_out = rand_ff;
        temp_u_noise3 = { rand_out[15,1], rand_out[15,1], rand_out[2,13] };
        temp_u_noise2 = temp_u_noise3;
        temp_u_noise1 = temp_u_noise2;
        temp_u_noise0 = temp_u_noise1;
        temp_g_noise_nxt =  __signed(temp_u_noise3) + __signed(temp_u_noise2) + __signed(temp_u_noise1) + __signed(temp_u_noise0) + ( rand_en_ff[9,1] ? __signed(g_noise_out) : 0 );
    }
}
