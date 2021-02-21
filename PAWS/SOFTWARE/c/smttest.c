#include "PAWSlibrary.h"

void smtthread( void ) {
    // SETUP STACKPOINTER FOR THE SMT THREAD
    asm volatile ("li sp ,0x2000");
    while(1) {
        gpu_rectangle( rng( 64 ), rng( 640 ), rng( 432 ), rng( 640 ), rng( 432 ) );
        sleep( 500, 1 );
    }
}

int main( void ) {
    INITIALISEMEMORY();

    tpu_printf_centre( 27, TRANSPARENT, GREEN, "SMT Test" );
    tpu_printf_centre( 28, TRANSPARENT, YELLOW, "I'm Just Sitting Here Doing Nothing" );
    tpu_printf_centre( 29, TRANSPARENT, BLUE, "The SMT Thread Is Drawing Rectangles!" );
    SMTSTART( (unsigned int )smtthread );

    while(1) {
        tpu_set( 1, 1, TRANSPARENT, WHITE );
        tpu_printf( "Main Thread Counting Away: %d", systemclock() );
        sleep( 1000, 0 );
    }
}
