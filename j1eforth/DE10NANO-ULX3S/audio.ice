// Runs at 25MHz, using the video clock
algorithm apu(
    // Waveform selected 0 = square, 1 = sawtooth, 2 = triangle, 3 = sine wave, 4 = noise
    input   uint3   waveform,
    // Note selected 0 = silence, 1 - x = Deep C through to Double High D (gives 64 distint notes)
    input   uint6   note,

    // Duration in ms, 1000 = 1 second,
    input   uint16  duration,
    output! uint1   audio_active,

    // Activate the APU (select the channel, 1, 2 or 3(?) )
    input   uint2   apu_write,

    output! uint4   audio_output,

    input uint16 staticGenerator
) <autorun> {
    // 32 step points per waveform
    uint4 waveformtable[] = {
        // Square wave
        15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

        // Sawtooth wave
        0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7,
        8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13, 14, 14, 15, 15,

        // Triangle wave,
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
        15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,

        // Sine wave,
        7, 8, 10, 11, 12, 13, 13, 14, 15, 14, 13, 13, 12, 11, 10, 8,
        7, 6, 4, 3, 2, 1, 1, 0, 0, 0, 1, 1, 2, 3, 4, 6
    };

    // Calculated as 25MHz / note frequency / 32 to give 32 step points per note
    uint16 frequencytable[64] = {
        0,
        23889, 22548, 21283, 20088, 18961, 17897, 16892, 15944, 15049, 14205, 13407, 12655,     // 1 = C 2 or Deep C
        11945, 11274, 10641, 10044, 9480, 8948, 8446, 7972, 7525, 7102, 6704, 6327,             // 13 = C 3
        5972, 5637, 5321, 5022, 4740, 4474, 4223, 3986, 3762, 3551, 3352, 3164,                 // 25 = C 4 or Middle C
        2896, 2819, 2660, 2511, 2370, 2237, 2112, 1993, 1881, 1776, 1676, 1582,                 // 37 = C 5 or Tenor C
        1493, 1409, 1330, 1256, 1185, 1119, 1056, 997, 941, 888, 838, 791,                      // 49 = C 6 or Soprano C
        747, 705, 665                                                                           // 61 = C 7 or Double High C
    };

    uint3   waveform_1 = uninitialized;
    uint6   note_1 = uninitialized;
    uint5   point_1 = uninitialized;
    uint16  counter25mhz_1 = uninitialized;
    uint16  counter1khz_1 = uninitialized;
    uint16  milliseconds_1 = uninitialized;
    uint3   waveform_2 = uninitialized;
    uint6   note_2 = uninitialized;
    uint5   point_2 = uninitialized;
    uint16  counter25mhz_2 = uninitialized;
    uint16  counter1khz_2 = uninitialized;
    uint16  milliseconds_2 = uninitialized;

    uint16  duration_1 = uninitialized;
    uint16  duration_2 = uninitialized;

    uint4   audio_output_1 := waveformtable[waveform_1 * 32 + point_1];
    uint16  note_1_frequency := frequencytable[note_1];
    uint4   audio_output_2 := waveformtable[waveform_2 * 32 + point_2];
    uint16  note_2_frequency := frequencytable[note_2];

    audio_active := ( duration_1 > 0) || ( duration_2 > 0 );

    always {
        if( ( note_1 != 0 ) && ( counter25mhz_1 == 0 ) ) {
            audio_output = ( waveform_1 == 4 ) ? staticGenerator : audio_output_1;
        }
        if( ( note_2 != 0 ) && ( counter25mhz_2 == 0 ) ) {
            audio_output = ( waveform_2 == 4 ) ? staticGenerator : audio_output_2;
        }
    }

    while(1) {
        switch( apu_write) {
            case 1: {
                // Latch the selected note, waveform and duration
                waveform_1 = waveform;
                note_1 = note;
                duration_1 = duration;
                milliseconds_1 = 0;
                point_1 = 0;
                counter25mhz_1 = 0;
                counter1khz_1 = 25000;
            }
            case 2: {
                // Latch the selected note, waveform and duration
                waveform_2 = waveform;
                note_2 = note;
                duration_2 = duration;
                milliseconds_2 = 0;
                point_2 = 0;
                counter25mhz_2 = 0;
                counter1khz_2 = 25000;
            }
            default: {
                if( duration_1 != 0 ) {
                    counter25mhz_1 = ( counter25mhz_1 != 0 ) ? counter25mhz_1 - 1 : note_1_frequency;
                    point_1 = ( counter25mhz_1 != 0 ) ? point_1 : point_1 + 1;
                    counter1khz_1 = ( counter1khz_1 != 0 ) ? counter1khz_1 - 1 : 25000;
                    duration_1 = ( counter1khz_1 != 0 ) ? duration_1 : duration_1 - 1;
                } else {
                    note_1 = 0;
                }
                if( duration_2 != 0 ) {
                    counter25mhz_2 = ( counter25mhz_2 != 0 ) ? counter25mhz_2 - 1 : note_2_frequency;
                    point_2 = ( counter25mhz_2 != 0 ) ? point_2 : point_2 + 1;
                    counter1khz_2 = ( counter1khz_2 != 0 ) ? counter1khz_2 - 1 : 25000;
                    duration_2 = ( counter1khz_2 != 0 ) ? duration_2 : duration_2 - 1;
                } else {
                    note_2 = 0;
                }
            }
        }
   }
}
