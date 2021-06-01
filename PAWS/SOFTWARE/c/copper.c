#include "PAWSlibrary.h"

int main( void ) {
    INITIALISEMEMORY();

    while(1) {
        copper_startstop( 0 );
        copper_program( 0, COPPER_WAIT_VBLANK, 7, 0, BKG_SNOW, BLACK, WHITE );
        copper_program( 1, COPPER_WAIT_Y, 7, 64, BKG_SNOW, BLACK, RED );
        copper_program( 2, COPPER_WAIT_Y, 7, 128, BKG_SNOW, BLACK, ORANGE );
        copper_program( 3, COPPER_WAIT_Y, 7, 160, BKG_SNOW, BLACK, YELLOW );
        copper_program( 4, COPPER_WAIT_Y, 7, 192, BKG_SNOW, BLACK, GREEN );
        copper_program( 5, COPPER_WAIT_Y, 7, 224, BKG_SNOW, BLACK, LTBLUE );
        copper_program( 6, COPPER_WAIT_Y, 7, 256, BKG_SNOW, BLACK, PURPLE );
        copper_program( 7, COPPER_WAIT_Y, 7, 288, BKG_SNOW, BLACK, MAGENTA );
        copper_program( 8, COPPER_JUMP, COPPER_JUMP_ON_VBLANK_EQUAL, 0, 0, 0, 8 );
        copper_program( 9, COPPER_JUMP, COPPER_JUMP_ALWAYS, 0, 0, 0, 0 );
        copper_startstop( 1 );
        sleep( 4000, 0 );

        copper_startstop( 0 );
        copper_program( 0, COPPER_WAIT_VBLANK, 7, 0, BKG_SNOW, BLACK, WHITE );
        copper_program( 1, COPPER_VARIABLE, COPPER_SET_VARIABLE, 1, 0, 0, 0 );
        copper_program( 2, COPPER_SET_FROM_VARIABLE, 1, 0, 0, 0, 0 );
        copper_program( 3, COPPER_VARIABLE, COPPER_ADD_VARIABLE, 1, 0, 0, 0 );
        copper_program( 4, COPPER_JUMP, COPPER_JUMP_ALWAYS, 0, 0, 0, 2 );
        copper_startstop( 1 );
        sleep( 4000, 0 );
    }
}
