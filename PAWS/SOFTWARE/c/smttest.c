#include "PAWSlibrary.h"

void smtthread( void ) {
    // SETUP STACKPOINTER FOR THE SMT THREAD
    asm volatile ("li sp ,0x4000");
    while(1) {
        gpu_rectangle( rng( 64 ), rng( 640 ), rng( 432 ), rng( 640 ), rng( 432 ) );
        sleep( 500, 1 );
    }
}

int main( void ) {
    INITIALISEMEMORY();

    tpu_printf_centre( 57, TRANSPARENT, GREEN, 1, "SMT Test" );
    tpu_printf_centre( 58, TRANSPARENT, YELLOW, 0, "I'm Just Sitting Here Doing Nothing" );
    tpu_printf_centre( 59, TRANSPARENT, BLUE, 0, "The SMT Thread Is Drawing Rectangles!" );
    SMTSTART( (unsigned int )smtthread );

    for( int loop = 0; loop < 32; loop++ ) {
        tpu_set( 1, 1, TRANSPARENT, WHITE );
        tpu_printf( 1, "Main Thread Counting Away: %d", systemclock() );
        sleep( 1000, 0 );
    }
}
