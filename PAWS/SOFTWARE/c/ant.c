#include "PAWSlibrary.h"

// http://http://www.rosettacode.org/wiki/Langton%27s_ant

#define for_x for (int x = 0; x < w; x++)
#define for_y for (int y = 0; y < h; y++)
#define for_xy for_x for_y
#define WIDTH 160
#define HEIGHT 120
#define SIZE 2

unsigned char universe[HEIGHT][WIDTH], framebuffer = 0;
int w = WIDTH, h = HEIGHT, x, y, d;

void show( void ) {
    bitmap_draw( 1 - framebuffer );
    gpu_cs();

    for_y for_x
        if( universe[y][x] )
            gpu_rectangle( BLACK, x * SIZE, y * SIZE, x * SIZE + (SIZE-1), y * SIZE + (SIZE-1) );

    if( !(systemclock() & 0xf ) ) {
            gpu_print_centre( WHITE, 160, 2, BOLD, 0, 0, "Press FIRE 1 to RESTART" );
            gpu_print_centre( WHITE, 160, 230, BOLD, 0, 0, "Press FIRE 2 to EXIT" );
    }

    // SWITCH THE FRAMEBUFFER
    framebuffer = 1 - framebuffer;
    bitmap_display( framebuffer );
}

void walk( void) {
    if( !universe[y][x] ) { universe[y][x] = 1; d -= 1; } else { universe[y][x] = 0; d += 1; }
    d = ( d + 4 ) % 4;

    // MOVE ANT, WRAPS AROUND IF MOVES OFF THE SCREEN
    switch(d) {
        case 0: y = ( y == HEIGHT - 1 ) ? 0 : y + 1;
            break;
        case 1: x = ( x == WIDTH - 1 ) ? 0 : x + 1;
            break;
        case 2: y = ( y == 0 ) ? ( HEIGHT - 1 ) : y - 1;
            break;
        case 3: x = ( x == 0 ) ? ( WIDTH - 1 ) : x - 1;
            break;
    }
}

void game( void ) {
	for_xy universe[y][x] = ( get_buttons() == 1 ) ? 0 : ( y & 1 ) ^ ( x & 1 );
    show();
    while( get_buttons() != 1 );

    // HOLD FIRE 1 TO REGENERATE STARTING POSITION
	while( get_buttons() == 1 ) {
		walk();
        show();
        gpu_rectangle( WHITE, x * SIZE, y * SIZE, x * SIZE + (SIZE-1), y * SIZE + (SIZE-1) );
	}
}

int main( void ) {
    INITIALISEMEMORY();

    gpu_cs();
    tpu_cs();
    set_background( BLACK, BLACK, BKG_RAINBOW );

    // CONTINUE UNTIL FIRE 2 IS PRESSED
    while( !( get_buttons() & 4 ) ) {
        x = WIDTH/2; y = HEIGHT / 2; d = 0;
        game();
    }
}
