// Runs at 25MHz
algorithm apu(
    input   uint4   waveform,
    input   uint16  frequency,
    input   uint16  duration,
    input   uint1   apu_write,
    input   uint4   staticGenerator,
    output  uint1   audio_active,
    output  uint4   audio_output
) <autorun,reginputs> {
    uint5   point = uninitialised;                  uint4   level = uninitialised;
    uint1   updatepoint = uninitialised;

    waveform WAVEFORM( point <: point, staticGenerator <: staticGenerator, audio_output :> level );
    audiocounter COUNTER( active :> audio_active, updatepoint :> updatepoint );

    COUNTER.start := 0;

    always_before {
        if( updatepoint ) { audio_output = level; }
    }
    always_after {
        if( apu_write ) {
            point = 0;
            WAVEFORM.selected_waveform = waveform;
            COUNTER.selected_frequency = frequency;
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
    brom uint4 level[128] = {
        15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15,     // SQUARE WAVE ( 0 )
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

        0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7,                     // SAWTOOTH WAVE ( 1 )
        8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13, 14, 14, 15, 15,

        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,               // TRIANGLE WAVE ( 2 )
        15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,

        8, 9, 10, 12, 13, 14, 14, 15, 15, 15, 14, 14, 13, 12, 10, 9,        // SINE WAVE ( 3 )
        8, 6, 5, 4, 2, 1, 1, 0, 0, 0, 1, 1, 2, 3, 5, 6
    };
    level.addr := { selected_waveform[0,2], point };

    always_after {
        if( selected_waveform[2,1] ) {
             audio_output = staticGenerator;
        } else {
             audio_output = level.rdata;
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
    uint16  counter25mhz = uninitialised;           uint16  counter1khz = uninitialised;                uint16  duration = uninitialised;
    uint1   updateduration <:: active & ( ~|counter1khz );

    active := ( |duration ); updatepoint := active & ( ~|counter25mhz );

    always_after {
        if( start ) {
            counter25mhz = 0;
            counter1khz = 25000;
            duration = selected_duration;
        } else {
            counter25mhz = updatepoint ? selected_frequency : counter25mhz - 1;
            counter1khz = updateduration ? 25000 : counter1khz - 1;
            duration = duration - updateduration;
        }
    }
}
