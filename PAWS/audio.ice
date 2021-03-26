// Runs at 25MHz
algorithm apu(
    // Waveform selected 0 = square, 1 = sawtooth, 2 = triangle, 3 = sine wave, 4 = noise
    input   uint4   waveform,
    // Note selected 0 = silence, 1 - x = Deep C through to Double High D (gives 64 distint notes)
    input   uint7   note,

    // Duration in ms, 1000 = 1 second,
    input   uint16  duration,
    output  uint1   audio_active,

    // Activate the APU (select the channel, 1, 2 or 3(?) )
    input   uint1   apu_write,

    output! uint4   audio_output,

    input uint4    staticGenerator
) <autorun> {
    // Calculated as 25MHz / note frequency / 32 to give 32 step points per note
    brom uint16 frequencytable[128] = {
        0,
        23889, 22548, 21283, 20088, 18961, 17897, 16892, 15944, 15049, 14205, 13407, 12655,     // 1 = C 2 or Deep C
        11945, 11274, 10641, 10044, 9480, 8948, 8446, 7972, 7525, 7102, 6704, 6327,             // 13 = C 3
        5972, 5637, 5321, 5022, 4740, 4474, 4223, 3986, 3762, 3551, 3352, 3164,                 // 25 = C 4 or Middle C
        2896, 2819, 2660, 2511, 2370, 2237, 2112, 1993, 1881, 1776, 1676, 1582,                 // 37 = C 5 or Tenor C
        1493, 1409, 1330, 1256, 1185, 1119, 1056, 997, 941, 888, 838, 791,                      // 49 = C 6 or Soprano C
        747, 705, 665, pad(1024)                                                                // 61 = C 7 or Double High C
    };

    // LATCH SELECTED WAVEFORM NOTE AND DURATION ON APU_WRITE
    uint4   selected_waveform = uninitialised;
    uint7   selected_note = uninitialised;
    uint16  selected_duration = uninitialised;

    // POSITION IN THE WAVETABLE AND TIMERS FOR FREQUENCY AND DURATION
    uint5   point = uninitialised;
    uint16  counter25mhz = uninitialised;
    uint16  counter1khz = uninitialised;

    // WIRES FOR DECREMENT OR RESET
    uint16  onesecond := 25000;
    uint16  notefrequency := frequencytable.rdata;
    frequencytable.addr := selected_note;
    audio_active := ( selected_duration > 0 );

    while(1) {
        if( apu_write ) {
            selected_waveform = waveform;
            selected_note = note;
            selected_duration = duration;
            point = 0;
            counter25mhz = 0;
            counter1khz = 25000;
        } else {
            if( selected_duration != 0 ) {
                if( counter25mhz == 0 ) {
                    switch( selected_waveform ) {
                        case 0: {
                            // SQUARE
                            audio_output = { {4{~point[4,1]}} };
                        }
                        case 1: {
                            // SAWTOOTH
                            audio_output = point[1,4];
                        }
                        case 2: {
                            // TRIANGLE
                            audio_output = point[4,1] ? 15 - point[0,4] : point[0,4];
                        }
                        case 3: {
                            // SINE
                            audio_output = point[4,1] ? 15 - point[1,3] : point[1,3];
                        }
                        case 4: {
                            // WHITE NOISE
                            audio_output = staticGenerator;
                        }
                    }
                }
                ( counter25mhz ) = decrementorreset( counter25mhz, notefrequency );
                ( point ) = incrementifzero( point, counter25mhz );
                ( counter1khz ) = decrementorreset( counter1khz, onesecond );
                ( selected_duration ) = decrementifzero( selected_duration, counter1khz );
            }
        }
    }
}
