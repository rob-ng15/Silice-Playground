#include "PAWSlibrary.h"

int main( void ) {
    INITIALISEMEMORY();

    // QUICK TEST OF THE TERMINAL WINDOW
    terminal_showhide( 1 );
    terminal_cs();

    terminal_print("Hello, I'm the little blue terminal window!\n");
    sleep( 4000, 0 );
    for( int i = 0; i < 16; i++ ) {
        terminal_printf("Counting %d, Floating Point Random Number %f\n",i,frng());
        sleep( 500, 0 );
    }
    terminal_printf("\nBye!");
    sleep( 4000, 0 );
    terminal_showhide( 0 );
}

// EXIT WILL RETURN TO BIOS
