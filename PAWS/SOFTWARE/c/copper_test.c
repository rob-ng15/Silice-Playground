#include "PAWSlibrary.h"

void displayreset( void ) {
    // RESET THE DISPLAY
    gpu_cs();
    tpu_cs();
    tilemap_scrollwrapclear( LOWER_LAYER, 9 );
    tilemap_scrollwrapclear( UPPER_LAYER, 9 );
    set_background( BLACK, BLACK, BKG_SOLID );
}

int main( void ) {
    INITIALISEMEMORY();
    displayreset();

    while(1) {
        // PROGRAM THE COPPER - SET 1
        copper_startstop( 0 );
        copper_program( 0, COPPER_WAIT_VBLANK, 7, 0, BKG_SOLID, GREEN, GREEN );
        copper_program( 1, COPPER_JUMP, COPPER_JUMP_ALWAYS, 0, 0, 0, 0 );
        copper_startstop( 1 );
        sleep( 8000, 0 );

        // PROGRAM THE COPPER - SET 2
        copper_startstop( 0 );
        copper_program( 0, COPPER_WAIT_Y, 7, 0, BKG_SOLID, BLUE, BLUE );
        copper_program( 1, COPPER_WAIT_Y, 7, 120, BKG_SOLID, RED, RED );
        copper_program( 2, COPPER_JUMP, COPPER_JUMP_ALWAYS, 0, 0, 0, 0 );
        copper_startstop( 1 );
        sleep( 8000, 0 );

        // PROGRAM THE COPPER - SET 3
        copper_startstop( 0 );
        copper_program( 0, COPPER_WAIT_Y, 7, 0, BKG_SNOW, DKBLUE, WHITE );
        copper_program( 1, COPPER_WAIT_X, 7, 0, BKG_SNOW, DKBLUE, WHITE );
        copper_program( 2, COPPER_JUMP, COPPER_JUMP_IF_Y_LESS, 32, 0, 0, 1 );
        copper_program( 3, COPPER_WAIT_X, 7, 0, BKG_SNOW, DKBLUE - 1, RED );
        copper_program( 4, COPPER_JUMP, COPPER_JUMP_IF_Y_LESS, 64, 0, 0, 3 );
        copper_program( 5, COPPER_WAIT_X, 7, 0, BKG_SNOW, DKBLUE - 1, ORANGE );
        copper_program( 6, COPPER_JUMP, COPPER_JUMP_IF_Y_LESS, 96, 0, 0, 5 );
        copper_program( 7, COPPER_WAIT_X, 7, 0, BKG_SNOW, DKBLUE - 1, YELLOW );
        copper_program( 8, COPPER_JUMP, COPPER_JUMP_IF_Y_LESS, 128, 0, 0, 7 );
        copper_program( 9, COPPER_WAIT_X, 7, 0, BKG_SNOW, DKBLUE - 1, GREEN );
        copper_program( 10, COPPER_JUMP, COPPER_JUMP_IF_Y_LESS, 160, 0, 0, 9 );
        copper_program( 11, COPPER_WAIT_X, 7, 0, BKG_SNOW, DKBLUE - 1, BLUE );
        copper_program( 12, COPPER_JUMP, COPPER_JUMP_IF_Y_LESS, 192, 0, 0, 11 );
        copper_program( 13, COPPER_WAIT_X, 7, 0, BKG_SNOW, DKBLUE - 1, DKPURPLE );
        copper_program( 14, COPPER_JUMP, COPPER_JUMP_IF_Y_LESS, 224, 0, 0, 13 );
        copper_program( 15, COPPER_WAIT_X, 7, 0, BKG_SNOW, DKBLUE - 1, MAGENTA );
        copper_program( 16, COPPER_JUMP, COPPER_JUMP_IF_NOT_VBLANK, 0, 0, 0, 15 );
        copper_program( 17, COPPER_JUMP, COPPER_JUMP_ALWAYS, 0, 0, 0, 1 );
        copper_startstop( 1 );
        sleep( 8000, 0 );

        // PROGRAM THE COPPER - SET 4
        copper_startstop( 0 );
        copper_program( 0, COPPER_WAIT_Y, 7, 0, BKG_SOLID, DKBLUE, BLUE );
        copper_program( 1, COPPER_WAIT_X, 7, 0, BKG_SOLID, DKBLUE, BLUE );
        copper_program( 2, COPPER_WAIT_X, 7, 80, BKG_RAINBOW, DKCYAN, CYAN );
        copper_program( 3, COPPER_WAIT_X, 7, 160, BKG_SNOW, WHITE, BLACK );
        copper_program( 4, COPPER_WAIT_X, 7, 240, BKG_STATIC, DKPURPLE, PURPLE );
        copper_program( 5, COPPER_JUMP, COPPER_JUMP_IF_Y_LESS, 160, 0, 0, 1 );
        copper_program( 6, COPPER_WAIT_HBLANK, 7, 0, BKG_LSLOPE, DKORANGE, ORANGE );
        copper_program( 7, COPPER_WAIT_X, 7, 320, BKG_RSLOPE, DKORANGE, ORANGE );
        copper_program( 8, COPPER_JUMP, COPPER_JUMP_IF_Y_LESS, 320, 0, 0, 6 );
        copper_program( 9, COPPER_WAIT_HBLANK, 7, 0, BKG_CHKBRD_2, BLACK, WHITE );
        copper_program( 10, COPPER_WAIT_X, 7, 320, BKG_CHKBRD_3, WHITE, BLACK );
        copper_program( 11, COPPER_JUMP, COPPER_JUMP_IF_NOT_VBLANK, 0, 0, 0, 9 );
        copper_program( 12, COPPER_JUMP, COPPER_JUMP_ALWAYS, 0, 0, 0, 0 );
        copper_startstop( 1 );
        sleep( 8000, 0 );


    }
}
