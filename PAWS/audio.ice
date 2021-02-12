// Runs at 50MHz
algorithm apu(
    // Waveform selected 0 = square, 1 = sawtooth, 2 = triangle, 3 = sine wave, 4 = noise
    input   uint4   waveform,
    // Note selected 0 = silence, 1 - x = Deep C through to Double High D (gives 64 distint notes)
    input   uint7   note,

    // Duration in ms, 1000 = 1 second,
    input   uint16  duration,
    output! uint1   audio_active,

    // Activate the APU (select the channel, 1, 2 or 3(?) )
    input   uint1   apu_write,

    output! uint4   audio_output,

    input uint4    staticGenerator
) <autorun> {
    // 32 step points per waveform
    brom uint4 waveformtable[512] = {
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
        ,pad(1)
    };

    // Calculated as 50MHz / note frequency / 32 to give 32 step points per note
    brom uint16 frequencytable[128] = {
        0,
        47778, 45097, 42566, 40177, 37922, 35793, 33784, 31888, 30098, 28409, 26815, 25310,     // 1 = C 2 or Deep C
        23889, 22548, 21283, 20088, 18961, 17897, 16892, 15944, 15049, 14205, 13407, 12655,     // 13 = C 3
        11945, 11274, 10641, 10044, 9480, 8948, 8446, 7972, 7525, 7102, 6704, 6327,             // 25 = C 4 or Middle C
        5972, 5637, 5321, 5022, 4740, 4474, 4223, 3986, 3762, 3551, 3352, 3164,                 // 37 = C 5 or Tenor C
        2896, 2819, 2660, 2511, 2370, 2237, 2112, 1993, 1881, 1776, 1676, 1582,                 // 49 = C 6 or Soprano C
        1493, 1409, 1330, pad(1024)                                                             // 61 = C 7 or Double High C
    };

    // LATCH SELECTED WAVEFORM NOTE AND DURATION ON APU_WRITE
    uint4   selected_waveform = uninitialised;
    uint7   selected_note = uninitialised;
    uint16  selected_duration = uninitialised;

    // POSITION IN THE WAVETABLE AND TIMERS FOR FREQUENCY AND DURATION
    uint5   point = uninitialised;
    uint16  counter50mhz = uninitialised;
    uint16  counter1khz = uninitialised;

    // WIRES FOR DECREMENT OR RESET
    uint16  onesecond := 50000;
    uint16  notefrequency := frequencytable.rdata;

    waveformtable.addr := selected_waveform * 32 + point;
    frequencytable.addr := selected_note;

    audio_active := ( selected_duration > 0 );

    while(1) {
        if( apu_write ) {
            selected_waveform = waveform;
            selected_note = note;
            selected_duration = duration;
            point = 0;
            counter50mhz = 0;
            counter1khz = 50000;
        } else {
            if( selected_duration != 0 ) {
                if( counter50mhz == 0 ) {
                    audio_output = ( selected_waveform == 4 ) ? staticGenerator : waveformtable.rdata;
                }
                ( counter50mhz ) = decrementorreset( counter50mhz, notefrequency );
                ( point ) = incrementifzero( point, counter50mhz );
                ( counter1khz ) = decrementorreset( counter1khz, onesecond );
                ( selected_duration ) = decrementifzero( selected_duration, counter1khz );
            }
        }
    }
}
