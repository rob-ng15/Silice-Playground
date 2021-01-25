#include "PAWSlibrary.h"

// http://www.rosettacode.org/wiki/Conway%27s_Game_of_Life#C

#define for_x for (int x = 0; x < w; x++)
#define for_y for (int y = 0; y < h; y++)
#define for_xy for_x for_y

unsigned char universe[60][80];
unsigned char new[60][80];

void show(int w, int h) {
	for_y for_x
        gpu_rectangle( universe[y][x] ? BLACK : TRANSPARENT, x * 8, y * 8, x * 8 + 7, y * 8 + 7 );
}

void evolve(int w, int h) {
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

void game(int w, int h) {
	for_xy universe[y][x] = rng( 2 );
	while ( get_buttons() == 1 ) {
		show(w, h);
		evolve(w, h);
		sleep( 200 );
	}
}

void main( void ) {
    INITIALISEMEMORY();

    gpu_cs();
    tpu_cs();
    terminal_showhide( 0 );
    set_background( BLACK, BLACK, BKG_RAINBOW );

    while(1) {
        game( 80, 60 );
    }
}
