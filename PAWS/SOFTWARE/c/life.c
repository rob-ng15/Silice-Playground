#include "PAWSlibrary.h"

// http://www.rosettacode.org/wiki/Conway%27s_Game_of_Life#C

#define for_x for (int x = 0; x < w; x++)
#define for_y for (int y = 0; y < h; y++)
#define for_xy for_x for_y
#define WIDTH 160
#define HEIGHT 120
#define SIZE 2

unsigned char universe[HEIGHT][WIDTH], new[HEIGHT][WIDTH], framebuffer = 0;
int w = WIDTH, h = HEIGHT;

void show( void ) {
    bitmap_draw( 1 - framebuffer );
    gpu_cs();

    for_y for_x
        if( universe[y][x] )
            gpu_rectangle( BLACK, x * SIZE, y * SIZE, x * SIZE + (SIZE-1), y * SIZE + (SIZE-1) );

    if( !(systemclock() & 0xf ) ) {
            gpu_printf_centre( WHITE, 160, 2, 0, 0, "Press FIRE 1 to RESTART" );
            gpu_printf_centre( WHITE, 160, 230, 0, 0, "Press FIRE 2 to EXIT" );
    }

    // SWITCH THE FRAMEBUFFER
    framebuffer = 1 - framebuffer;
    bitmap_display( framebuffer );
}

void evolve( void) {
	for_y for_x {
		int n = 0;
		for (int y1 = y - 1; y1 <= y + 1; y1++)
			for (int x1 = x - 1; x1 <= x + 1; x1++)
				if (universe[(y1 + h) % h][(x1 + w) % w])
					n++;

		if (universe[y][x]) n--;
		new[y][x] = (n == 3 || (n == 2 && universe[y][x]));
	}
	for_y for_x universe[y][x] = new[y][x];
}

void game( void ) {
	for_xy universe[y][x] = rng( 2 );

    // HOLD FIRE 1 TO REGENERATE STARTING POSITION
	while( get_buttons() == 1 ) {
		evolve();
        show();
        sleep( 10, 0 );
	}
}

int main( void ) {
    INITIALISEMEMORY();

    gpu_cs();
    tpu_cs();
    set_background( BLACK, BLACK, BKG_RAINBOW );

    // CONTINUE UNTIL FIRE 2 IS PRESSED
    while( !( get_buttons() & 4 ) ) {
        game();
    }
}
