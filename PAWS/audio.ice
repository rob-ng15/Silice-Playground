// Runs at 25MHz
algorithm apu(
    input   uint4   waveform,
    input   uint16  frequency,
    input   uint16  duration,
    input   uint1   apu_write,
    input   uint4   staticGenerator,
    output  uint1   audio_active,
    output  uint4   audio_output
) <autorun> {
    // LATCH SELECTED FREQUENCY, WAVEFORM AND DURATION ON APU_WRITE
    uint16  selected_frequency = uninitialised;
    uint4   selected_waveform = uninitialised;
    uint16  selected_duration = uninitialised;

    // POSITION IN THE WAVEFORM
    uint5   point = uninitialised;
    uint4   level = uninitialised;
    waveform WAVEFORM(
        selected_waveform <: selected_waveform,
        point <: point,
        staticGenerator <: staticGenerator,
        audio_output :> level
    );

    uint1   start = uninitialised;
    uint1   updatepoint = uninitialised;
    uint1   updateduration = uninitialised;
    audiocounter COUNTER(
        start <: start,
        active <: audio_active,
        selected_frequency <: selected_frequency,
        updatepoint :> updatepoint,
        updateduration :> updateduration
    );

    start := 0; audio_active ::= ( selected_duration != 0 );

    always {
        if( updatepoint ) {
            audio_output = level;
        }
        if( apu_write ) {
            selected_waveform = waveform;
            selected_frequency = frequency;
            selected_duration = duration;
            point = 0;
            start = 1;
        } else {
            point = point + ( updatepoint & audio_active );
            selected_duration = selected_duration - ( updateduration & audio_active );
        }
    }
}

algorithm waveform(
    input   uint4   selected_waveform,
    input   uint5   point,
    input   uint4   staticGenerator,
    output  uint4   audio_output
) <autorun> {
    always {
        switch( selected_waveform ) {
            case 0: { audio_output = { {4{~point[4,1]}} }; }                        // SQUARE
            case 1: { audio_output = point[1,4]; }                                  // SAWTOOTH
            case 2: { audio_output = point[4,1] ? 15 - point[0,4] : point[0,4]; }   // TRIANGLE
            case 3: { audio_output = point[4,1] ? 15 - point[1,3] : point[1,3]; }   // SINE
            default: { audio_output = staticGenerator; }                            // WHITE NOISE
        }
    }
}

algorithm audiocounter(
    input   uint1   start,
    input   uint1   active,
    input   uint16  selected_frequency,
    output  uint1   updatepoint,
    output  uint1   updateduration
) <autorun> {
    uint16  counter25mhz = 0;
    uint16  counter1khz = 0;

    updatepoint := active & ( counter25mhz == 0 );
    updateduration := active & ( counter1khz == 0 );

    always {
        if( start ) {
            counter25mhz = 0;
            counter1khz = 25000;
        } else {
            if( active ) {
                counter25mhz = ( counter25mhz != 0 ) ? counter25mhz - 1 : selected_frequency;
                counter1khz = ( counter1khz != 0 ) ? counter1khz - 1 : 25000;
            }
        }
    }
}
