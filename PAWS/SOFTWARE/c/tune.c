#include "PAWSlibrary.h"

unsigned char tune_treble[] = {  36, 48, 43, 40, 48, 42, 41, 37, 49, 44, 41, 49, 44, 41, 0xff };
unsigned short size_treble[] = { 16, 16, 16, 16,  8,  8, 32, 24, 16, 16, 16, 32, 24, 32, 0xff };

int main( void ) {
    INITIALISEMEMORY();

    unsigned short trebleposition = 0;

    for( int i = 0; i < 4; i++ ) {
        trebleposition = 0;

        while( tune_treble[ trebleposition ] != 0xff ) {
            if( !get_beep_active( 1 ) ) {
                if( tune_treble[ trebleposition ] != 0xff ) {
                    beep( 1, 0, tune_treble[ trebleposition ], size_treble[ trebleposition ] << 4 );
                    trebleposition++;
                }
            }
        }

        sleep( 4000, 0 );

        beep( 1, 0, 36, 16 << 4 ); await_beep( 1 );
        beep( 1, 0, 48, 16 << 4 ); await_beep( 1 );
        beep( 1, 0, 43, 16 << 4 ); await_beep( 1 );
        beep( 1, 0, 40, 16 << 4 ); await_beep( 1 );
        beep( 1, 0, 48, 8 << 4 ); await_beep( 1 );
        beep( 1, 0, 42, 8 << 4 ); await_beep( 1 );
        beep( 1, 0, 41, 32 << 4 ); await_beep( 1 );
        beep( 1, 0, 37, 24 << 4 ); await_beep( 1 );
        beep( 1, 0, 49, 16 << 4 ); await_beep( 1 );
        beep( 1, 0, 44, 16 << 4 ); await_beep( 1 );
        beep( 1, 0, 41, 16 << 4 ); await_beep( 1 );
        beep( 1, 0, 49, 32 << 4 ); await_beep( 1 );
        beep( 1, 0, 44, 24 << 4 ); await_beep( 1 );
        beep( 1, 0, 41, 32 << 4 ); await_beep( 1 );

        sleep( 4000, 0 );

        for( unsigned char note = 1; note < 64; note++ ) {
            beep( 1, 0 , note, 500 );
            await_beep( 1 );
            sleep( 250, 0 );
        }
    }
}
