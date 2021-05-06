#include "PAWSlibrary.h"

int main( void ) {
    INITIALISEMEMORY();

    // CURRENT FRAMEBUFFER
    unsigned short framebuffer = 0;

    // SCALE AND DIRECTION
    short direction = 1;
    float scale = 0.1;

    while(1) {
        // DRAW TO HIDDEN FRAME BUFFER
        bitmap_draw( !framebuffer ); gpu_cs();
        gpu_rectangle( WHITE, 160 - 80 * scale, 120 - 80 * scale, 160 + 80 * scale, 120 + 80 * scale );

        if( direction ) {
            scale = scale + 0.1;
            if( scale > 2.0 ) direction = 0;
        } else {
            scale = scale - 0.1;
            if( scale < 0.1 ) direction = 1;
        }

        // SWITCH THE FRAMEBUFFER
        await_vblank();
        framebuffer = !framebuffer;
        bitmap_display( framebuffer );

        sleep( 500, 0 );
    }
}
