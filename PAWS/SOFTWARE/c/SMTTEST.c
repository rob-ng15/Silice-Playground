#include "PAWSlibrary.h"

void smtthread( void ) {
    // SETUP STACKPOINTER FOR THE SMT THREAD
    asm volatile ("li sp ,0x3000");
    while(1) {
        gpu_rectangle( rng( 64 ), rng( 640 ), rng( 432 ), rng( 640 ), rng( 432 ) );
        sleep( 1000 );
    }
}

void main( void ) {
    INITIALISEMEMORY();

    tpu_outputstringcentre( 27, TRANSPARENT, GREEN, "SMT Test" );
    tpu_outputstringcentre( 28, TRANSPARENT, YELLOW, "I'm Just Sitting Here Doing Nothing" );
    tpu_outputstringcentre( 29, TRANSPARENT, BLUE, "The SMT Thread Is Drawing Rectangles!" );
    SMTSTART( (unsigned int )smtthread );
    while(1) {
    }
}
