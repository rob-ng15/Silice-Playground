#include "PAWSlibrary.h"

#define WIDTH 80
#define HEIGHT 60

// STORAGE FOR MAZE
// WALLS WILL BE '#' GAPS ' '
char maze[WIDTH][HEIGHT];

void initialise_maze( void )
{
    unsigned short x,y;

    // FILL WITH WALLS
    for( x = 0; x < WIDTH; x++ ) {
        for( y = 0; y < HEIGHT; y++ ) {
            maze[x][y] = '#';
        }
    }

    // ADD BORDERS
    for( x = 0; x < WIDTH; x++ ) {
        maze[x][0] = '*';
        maze[x][ HEIGHT - 1 ] = '*';
        maze[x][ HEIGHT - 2 ] = '*';
    }
    for( y = 0; y < HEIGHT; y++ ) {
        maze[0][y] = '*';
        maze[ WIDTH - 1][y] = '*';
        maze[ WIDTH - 2][y] = '*';
    }

    // ADD EXTRANCE
    maze[0][1] = 'E';

    // ADD EXIT
    maze[ WIDTH - 2 ][ HEIGHT - 3 ] = 'X';
}

void display_maze( unsigned short currentx, unsigned short currenty )
{
    unsigned short x, y;

    for( x = 0; x < WIDTH; x++ ) {
        for( y = 0; y < HEIGHT; y++ ) {
            switch( maze[x][y] ) {
                case '*':
                    gpu_rectangle( 0x30, x * 8, y * 8, x * 8 + 7, y * 8 + 7 );
                    break;
                case '#':
                    gpu_rectangle( 0x03, x * 8, y * 8, x * 8 + 7, y * 8 + 7 );
                    break;
                case ' ':
                case 'E':
                    gpu_rectangle( 0x3f, x * 8, y * 8, x * 8 + 7, y * 8 + 7 );
                    break;
                case 'X':
                    gpu_rectangle( 0x3c, x * 8, y * 8, x * 8 + 7, y * 8 + 7 );
                    break;
            }
        }
    }

    gpu_rectangle( 0x0c, currentx * 8, currenty * 8, currentx * 8 + 7, currenty * 8 + 7 );
}

// ADAPTED FROM https://rosettacode.org/wiki/Maze_generation#BASIC
void generate_maze( void )
{
    unsigned short currentx, currenty, oldx, oldy, x, y, done, i;

    // Start at random location
    currentx = rng( WIDTH ); if( currentx % 2 == 0 ) currentx++;
    currenty = rng( HEIGHT ); if( currenty % 2 == 0 ) currenty++;
    maze[currentx][currenty] = ' ';

    done = 0;

    do {
        display_maze( currentx, currenty );
        // GENERATE 32 CELLS
        for( i = 0; i < 32; i++ ) {
            // RECORD PRESENT LOCATION
            oldx = currentx;
            oldy = currenty;

            // Move in a random direction
            switch( rng(4) ) {
                case 0:
                    if( currentx + 2 < WIDTH - 1 ) currentx += 2;
                    break;
                case 1:
                    if( currenty + 2 < HEIGHT - 1 ) currenty += 2;
                    break;
                case 2:
                    if( currentx - 2 > 0 ) currentx -= 2;
                    break;
                case 3:
                    if( currenty - 2 > 0 ) currenty -= 2;
                    break;
            }

            // Connect cell if not visited
            if( maze[currentx][currenty] == '#' ) {
                maze[currentx][currenty] = ' ';
                maze[ ( currentx + oldx ) / 2 ][ ( currenty + oldy ) / 2 ] = ' ';
            }
        }

        // Check if all cells visited
        done = 1;
        for( x = 1; x < WIDTH - 1; x += 2 ) {
            for( y = 1; y < HEIGHT - 1; y += 2 ) {
                if( maze[x][y] == '#' ) done = 0;
            }
        }
    } while( done == 0 );
}

void finalise_maze( void )
{
    unsigned short x, y;

}

void main( void )
{
	while(1) {
        tpu_cs();
        terminal_showhide( 0 );

        initialise_maze();
        generate_maze();

        display_maze( 1, 1 );

        tpu_set( 0, 0, 0x40, 0x0c ); tpu_outputstring( "Press FIRE to restart!" );
        while(  ( get_buttons() & 2 ) == 0 );
        tpu_cs();
    }
}
