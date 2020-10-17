// Runs at 25MHz, using the video clock
algorithm apu(
    // Waveform selected 0 = square, 1 = sawtooth, 2 = triangle, 3 = sine wave, 4 = noise
    input   uint3   waveform,
    // Note selected 0 = silence, 1 - x = Deep C through to Double High D (gives 64 distint notes) 
    input   uint6   note,
    
    // Duration in ms, 1000 = 1 second,
    input   uint16  duration,
    output!  uint16  selected_duration,
    
    // Activate the APU
    input   uint1   apu_write,
    
    output! uint4   audio_output,
) <autorun> {
    // 32 step points per waveform
    brom uint4 waveformtable[] = {
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
         7, 6, 4, 3, 2, 1, 1, 0, 0, 0, 1, 1, 2, 3, 4, 6,

        // Noise
        15, 12, 2, 7, 7, 14, 11, 11, 14, 13, 6, 4, 4, 7, 12, 0,
        5, 9, 6, 4, 1, 6, 0, 7, 3, 6, 9, 3, 4, 12, 1, 10
    };
    
    // Calculated as 25MHz / note frequency / 32 to give 32 step points per note
    brom uint16 frequencytable[64] = {
        0,
        23889, 22548, 21283, 20088, 18961, 17897, 16892, 15944, 15049, 14205, 13407, 12655,     // 1 = C 2 or Deep C
        11945, 11274, 10641, 10044, 9480, 8948, 8446, 7972, 7525, 7102, 6704, 6327,             // 13 = C 3
        5972, 5637, 5321, 5022, 4740, 4474, 4223, 3986, 3762, 3551, 3352, 3164,                 // 25 = C 4 or Middle C
        2896, 2819, 2660, 2511, 2370, 2237, 2112, 1993, 1881, 1776, 1676, 1582,                 // 37 = C 5 or Tenor C
        1493, 1409, 1330, 1256, 1185, 1119, 1056, 997, 941, 888, 838, 791,                      // 49 = C 6 or Soprano C
        747, 705, 665,                                                                          // 61 = C 7 or Double High C
    };
    
    uint3   selected_waveform = uninitialized;
    uint6   selected_note = uninitialized;
    uint5   step_point = uninitialized;   
    uint16  counter25mhz = uninitialized;
    uint16  counter1khz = uninitialized;
    uint16  milliseconds = uninitialized;
    
    uint4   selected_audio_output := waveformtable.rdata;
    uint16  selected_note_frequency := frequencytable.rdata;

    waveformtable.addr := selected_waveform * 32 + step_point;
    frequencytable.addr := selected_note;
    
    always {
        if( ( selected_note > 0 ) & ( counter25mhz == 0 ) ) {
            audio_output = selected_audio_output;
        }
    }
    
    while(1) {
        switch( apu_write) {
            case 1: {
                // Latch the selected note, waveform and duration
                selected_waveform = waveform;
                selected_note = note;
                selected_duration = duration;
                milliseconds = 0;
                step_point = 0;
                counter25mhz = 0;
                counter1khz = 25000;
            }
            default: {
                if( selected_duration ) {
                    counter25mhz = ( counter25mhz ) ? counter25mhz - 1 : selected_note_frequency;
                    step_point = ( counter25mhz ) ? step_point : step_point + 1;
                    counter1khz = ( counter1khz ) ? counter1khz - 1 : 25000;
                    selected_duration = ( counter1khz) ? selected_duration : selected_duration - 1;
                }
                selected_note = ( selected_duration ) ? selected_note : 0;
            }
        }
    }
}
