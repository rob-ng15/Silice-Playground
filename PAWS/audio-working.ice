// Runs at 25MHz
algorithm apu(
    input   uint4   waveform,
    input   uint16  frequency,
    input   uint16  duration,
    output  uint1   audio_active,
    input   uint1   apu_write,
    output  uint4   audio_output,
    input   uint4   staticGenerator
) <autorun> {
    // LATCH SELECTED FREQUENCY, WAVEFORM AND DURATION ON APU_WRITE
    uint16  selected_frequency = uninitialised;
    uint4   selected_waveform = uninitialised;
    uint16  selected_duration = uninitialised;

    // POSITION IN THE WAVEFORM AND TIMERS FOR FREQUENCY AND DURATION
    uint5   point = uninitialised;
    uint16  counter25mhz = uninitialised;
    uint16  counter1khz = uninitialised;

    audio_active := ( selected_duration != 0 );

    always {
        if( audio_active && ( counter25mhz == 0 ) ) {
            switch( selected_waveform ) {
                case 0: { audio_output = { {4{~point[4,1]}} }; }                        // SQUARE
                case 1: { audio_output = point[1,4]; }                                  // SAWTOOTH
                case 2: { audio_output = point[4,1] ? 15 - point[0,4] : point[0,4]; }   // TRIANGLE
                case 3: { audio_output = point[4,1] ? 15 - point[1,3] : point[1,3]; }   // SINE
                default: { audio_output = staticGenerator; }                            // WHITE NOISE
            }
        }
        if( apu_write ) {
            selected_waveform = waveform;
            selected_frequency = frequency;
            selected_duration = duration;
            point = 0;
            counter25mhz = 0;
            counter1khz = 25000;
        } else {
            if( selected_duration != 0 ) {
                counter25mhz = ( counter25mhz != 0 ) ? counter25mhz - 1 : selected_frequency;
                point = point + ( counter25mhz == 0 );
                counter1khz = ( counter1khz != 0 ) ? counter1khz - 1 : 25000;
                selected_duration = selected_duration - ( counter1khz == 0 );
            }
        }
    }
}
