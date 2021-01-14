#include "PAWSlibrary.h"

// http://www.rosettacode.org/wiki/Conway%27s_Game_of_Life#C

#define for_x for (int x = 0; x < w; x++)
#define for_y for (int y = 0; y < h; y++)
#define for_xy for_x for_y

void show(void *u, int w, int h) {
	int (*univ)[w] = u;
	for_y for_x
        gpu_rectangle( univ[y][x] ? BLACK : TRANSPARENT, x * 8, y * 8, x * 8 + 7, y * 8 + 7 );
}

void evolve(void *u, int w, int h) {
	unsigned (*univ)[w] = u;
	unsigned new[h][w];

	for_y for_x {
		int n = 0;
		for (int y1 = y - 1; y1 <= y + 1; y1++)
			for (int x1 = x - 1; x1 <= x + 1; x1++)
				if (univ[(y1 + h) % h][(x1 + w) % w])
					n++;

		if (univ[y][x]) n--;
		new[y][x] = (n == 3 || (n == 2 && univ[y][x]));
	}
	for_y for_x univ[y][x] = new[y][x];
}

void game(int w, int h) {
	unsigned univ[h][w];
	for_xy univ[y][x] = rng( 2 );
	while (1) {
		show(univ, w, h);
		evolve(univ, w, h);
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
