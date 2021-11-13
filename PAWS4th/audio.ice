// Runs at 25MHz
algorithm apu(
    input   uint4   waveform,
    input   uint7   note,
    input   uint16  duration,
    output  uint1   audio_active,
    input   uint1   apu_write,
    output  uint4   audio_output,
    input   uint4   staticGenerator
) <autorun> {
    uint5   point = uninitialised;
    uint4   level = uninitialised;
    uint1   updatepoint = uninitialised;
    waveform WAVEFORM( point <: point, staticGenerator <: staticGenerator, audio_output :> level );
    audiocounter COUNTER( active :> audio_active, updatepoint :> updatepoint );

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
    frequencytable.addr := note;

    COUNTER.start := 0;

    always {
        if( updatepoint ) { audio_output = level; }
        if( apu_write ) {
            point = 0;
            WAVEFORM.selected_waveform = waveform;
            COUNTER.selected_frequency = frequencytable.rdata;
            COUNTER.selected_duration = duration;
            COUNTER.start = 1;
        } else {
            point = point + updatepoint;
        }
    }
}

algorithm waveform(
    input   uint5   point,
    input   uint4   selected_waveform,
    input   uint4   staticGenerator,
    output  uint4   audio_output
) <autorun,reginputs> {
    uint4   triangle <:: point[4,1] ? 15 - point[0,4] : point[0,4];
    uint4   sine <:: point[4,1] ? 15 - point[1,4] : point[1,4];
    always {
        switch( selected_waveform ) {
            case 0: { audio_output = { {4{point[4,1]}} }; }     // SQUARE
            case 1: { audio_output = point[1,4]; }              // SAWTOOTH
            case 2: { audio_output = triangle; }                // TRIANGLE
            case 3: { audio_output = sine; }                    // SINE
            default: { audio_output = staticGenerator; }        // WHITE NOISE
        }
    }
}

algorithm audiocounter(
    input   uint1   start,
    input   uint16  selected_frequency,
    input   uint16  selected_duration,
    output  uint1   updatepoint,
    output  uint1   active
) <autorun,reginputs> {
    uint16  counter25mhz = uninitialised;
    uint16  nextcounter25mhz <:: counter25mhz - 1;
    uint16  counter1khz = uninitialised;
    uint16  nextcounter1khz <:: counter1khz - 1;
    uint16  duration = uninitialised;
    uint1   updateduration <:: active & ( ~|counter1khz );

    active := ( |duration ); updatepoint := active & ( ~|counter25mhz );

    always {
        if( start ) {
            counter25mhz = 0;
            counter1khz = 25000;
            duration = selected_duration;
        } else {
            counter25mhz = updatepoint ? selected_frequency : nextcounter25mhz;
            counter1khz = updateduration ? 25000 : nextcounter1khz;
            duration = duration - updateduration;
        }
    }

    // STOP AUDIO ON RESET
    if( ~reset ) { duration = 0; }
}
