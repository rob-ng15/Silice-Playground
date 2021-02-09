#include "PAWSlibrary.h"

// http://www.rosettacode.org/wiki/Conway%27s_Game_of_Life#C

#define for_x for (short x = 0; x < w; x++)
#define for_y for (short y = 0; y < h; y++)
#define for_xy for_x for_y

#define WIDTH 160
#define HEIGHT 120

unsigned short universe[HEIGHT][WIDTH >> 4];
unsigned short new[HEIGHT][WIDTH >> 4];
short w = WIDTH, h = HEIGHT;

// GET/SET CONTENTS OF == 0 UNIVERSE == 1 NEW at ( X, Y )
unsigned char getbit( short x, short y, unsigned char universenew ) {
    switch( universenew ) {
        case 0: { return( universe[ y ][ x >> 4 ] >> ( x & 0x0f ) ); }
        case 1: { return( new[ y ][ x >> 4 ] >> ( x & 0x0f ) ); }
    }
}

// SET THE CONTENTS OF == 0 MAZE == 1 MAP at ( X, Y )
void setbit( short x, short y, unsigned char value, unsigned char universenew ) {
    switch( universenew ) {
        case 0:
            switch( value ) {
                case 0:
                    universe[ y ][ x >> 4 ] &= ~( 1 << ( x & 0x0f ) );
                    break;
                case 1:
                    universe[ y ][ x >> 4 ] |= ( 1 << ( x & 0x0f ) );
                    break;
            }
            break;
        case 1:
            switch( value ) {
                case 0:
                    new[ y ][ x >> 4 ] &= ~( 1 << ( x & 0x0f ) );
                    break;
                case 1:
                    new[ y ][ x >> 4 ] |= ( 1 << ( x & 0x0f ) );
                    break;
            }
            break;
    }
}

void show( void ) {
    // SET STACK
    await_vblank();
    for_y for_x
        gpu_rectangle( getbit( x, y, 0 ) ? BLACK : TRANSPARENT, x * 4, y * 4, x * 4 + 7, y * 4 + 7 );
}

void evolve( void) {
	for_y for_x {
		short n = 0;
		for (short y1 = y - 1; y1 <= y + 1; y1++)
			for (short x1 = x - 1; x1 <= x + 1; x1++)
				if (getbit( (x1 + w) % w, (y1 + h) % h, 0 ))
					n++;

		if (getbit( x, y, 0 )) n--;
		setbit( x, y, (n == 3 || (n == 2 && getbit( x, y, 0 ))), 1 );
	}

	// COPY NEW TO UNIVERSE
	for( short y = 0; y < h; y++ )
        for( short x = 0; x < ( w >> 4 ); x++ )
            universe[y][x] = new[y][x];
}

void game( void ) {
	for_xy setbit( x, y, rng(2), 0 );
	while ( get_buttons() == 1 ) {
		evolve();
        show();
		sleep( 50, 0 );
	}
}

void main( void ) {
    INITIALISEMEMORY();

    gpu_cs();
    tpu_cs();
    terminal_showhide( 0 );
    set_background( BLACK, BLACK, BKG_RAINBOW );

    while(1) {
        game();
    }
}
