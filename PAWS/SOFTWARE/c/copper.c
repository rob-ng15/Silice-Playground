#include "PAWSlibrary.h"

int main( void ) {
    INITIALISEMEMORY();

    set_copper_cpuinput( 16 );
    copper_startstop( 0 );
    copper_program( 0, COPPER_WAIT_VBLANK, 7, 0, BKG_SNOW, BLACK, WHITE );
    copper_program( 1, COPPER_WAIT_X, 7, 0, BKG_SNOW, BLACK, YELLOW );
    copper_program( 2, COPPER_JUMP, COPPER_JUMP_IF_Y_LESS, 64, 0, 0, 2 );
    copper_program( 3, COPPER_WAIT_X, 7, 0, BKG_SNOW, WHITE, BLACK );
    copper_program( 4, COPPER_JUMP, COPPER_JUMP_ON_VBLANK_EQUAL, 0, 0, 0, 4 );
    copper_program( 5, COPPER_JUMP, COPPER_JUMP_ALWAYS, 0, 0, 0, 1 );
    copper_startstop( 1 );

    for( unsigned short i = 16; i < 240; i++ ) {
        await_vblank();
        set_copper_cpuinput( i );
    }
    sleep( 4000, 0 );
}
