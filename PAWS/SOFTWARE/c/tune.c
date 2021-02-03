#include "PAWSlibrary.h"

unsigned char tune_treble[] = { 36, 48, 43, 40, 48, 42, 41, 37, 49, 44, 41, 49, 44, 41, 0xff };
unsigned short size_treble[] = { 16, 16, 16, 16,  8,  8, 32, 24, 16, 16, 16, 32, 24, 32, 0xff };

void main( void ) {
    INITIALISEMEMORY();

    unsigned short trebleposition = 0;

    while(1) {
        if( !get_beep_duration( 1 ) ) {
            if( tune_treble[ trebleposition ] != 0xff ) {
                beep( 1, 2, tune_treble[ trebleposition ], size_treble[ trebleposition ] << 4 );
                trebleposition++;
            }
        }
    }
}
