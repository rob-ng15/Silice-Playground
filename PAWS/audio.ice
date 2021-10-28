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
    uint5   point = uninitialised;
    uint4   level = uninitialised;
    uint1   updatepoint = uninitialised;
    waveform WAVEFORM( point <: point, staticGenerator <: staticGenerator, audio_output :> level );
    audiocounter COUNTER( active :> audio_active, updatepoint :> updatepoint );

    COUNTER.start := 0;

    always {
        if( updatepoint ) { audio_output = level; }
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
    always {
        switch( selected_waveform ) {
            case 0: { audio_output = { {4{point[4,1]}} }; }                                 // SQUARE
            case 1: { audio_output = point[1,4]; }                                          // SAWTOOTH
            case 2: { audio_output = point[4,1] ? 15 - point[0,4] : point[0,4]; }           // TRIANGLE
            case 3: { audio_output = point[4,1] ? 15 - point[1,4] : point[1,4]; }           // SINE
            default: { audio_output = staticGenerator; }                                    // WHITE NOISE
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
    uint16  counter1khz = uninitialised;
    uint16  duration = uninitialised;
    uint1   updateduration <:: active & ( ~|counter1khz );

    active := ( |duration ); updatepoint := active & ( ~|counter25mhz );

    always {
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

    // STOP AUDIO ON RESET
    if( ~reset ) { duration = 0; }
}
