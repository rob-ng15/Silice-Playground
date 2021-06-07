#include "PAWSlibrary.h"

int main( void ) {
    INITIALISEMEMORY();

    unsigned char framebuffer = 0, drawsector[] = { 0b11111111, 0b11111001, 0b10011001, 0b00001001, 0b00000000 };

    while(1) {
        for( unsigned char i = 0; i < 5; i++ ) {
            bitmap_draw( 1 - framebuffer );
            gpu_cs();

            gpu_circle( YELLOW, 160, 120, 80, drawsector[i], 1 );

            // SWITCH THE FRAMEBUFFER
            framebuffer = 1 - framebuffer;
            bitmap_display( framebuffer );

            sleep( 1000, 0 );
        }
        for( unsigned char i = 0; i < 5; i++ ) {
            bitmap_draw( 1 - framebuffer );
            gpu_cs();

            gpu_circle( YELLOW, 160, 120, 80, drawsector[4 - i], 1 );

            // SWITCH THE FRAMEBUFFER
            framebuffer = 1 - framebuffer;
            bitmap_display( framebuffer );

            sleep( 1000, 0 );
        }
    }
}
