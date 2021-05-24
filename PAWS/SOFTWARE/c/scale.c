#include "PAWSlibrary.h"

int main( void ) {
    INITIALISEMEMORY();

    // CURRENT FRAMEBUFFER
    unsigned short framebuffer = 0;

    // SCALE AND DIRECTION
    float scale;
    int value;

    while(1) {
        scale = 0.1;
        // MULTIPLIER TEST
        for( short count = 0; count < 20; count++ ) {
            // DRAW TO HIDDEN FRAME BUFFER
            bitmap_draw( !framebuffer ); gpu_cs();
            value = 80 * scale;
            gpu_rectangle( GREY1, 160 - value, 120 - value, 160 + value, 120 + value );
            tpu_printf_centre( 29, TRANSPARENT, LTBLUE, "scale = %f, 80 * scale = %f, integer = %d", scale, 80*scale, value );

            scale = scale + 0.1;

            // SWITCH THE FRAMEBUFFER
            framebuffer = !framebuffer;
            bitmap_display( framebuffer );

            sleep( 500, 0 );
        }

        // DIVIDER TEST
        scale = 0.5;
        for( short count = 0; count < 12; count++ ) {
            // DRAW TO HIDDEN FRAME BUFFER
            bitmap_draw( !framebuffer ); gpu_cs();
            value = 80 / scale;
            gpu_rectangle( GREY2, 160 - value, 120 - value, 160 + value, 120 + value );
            tpu_printf_centre( 29, TRANSPARENT, LTRED, "scale = %f, 80 / scale = %f, integer = %d", scale, 80 / scale, value );

            scale = scale + 0.1;

            // SWITCH THE FRAMEBUFFER
            framebuffer = !framebuffer;
            bitmap_display( framebuffer );

            sleep( 1000, 0 );
        }
    }
}
