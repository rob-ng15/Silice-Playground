#include "PAWSlibrary.h"

#define MAXWIDTH 80
#define MAXHEIGHT 60
#define MAXLEVEL 6

unsigned short levelwidths[] = { 10, 16, 20, 32, 40, 64, 80, 128, 160 };
unsigned short levelheights[] = { 8, 12, 16, 24, 32, 48, 60, 80, 120 };

// STORAGE FOR MAZE
// WALLS WILL BE '#' GAPS ' '
char maze[MAXWIDTH][MAXHEIGHT];

void initialise_maze( unsigned short width, unsigned short height )
{
    unsigned short x,y;

    // FILL WITH WALLS
    for( x = 0; x < width; x++ ) {
        for( y = 0; y < height; y++ ) {
            maze[x][y] = '#';
        }
    }

    // ADD BORDERS
    for( x = 0; x < width; x++ ) {
        maze[x][0] = '*';
        maze[x][ height - 1 ] = '*';
        maze[x][ height - 2 ] = '*';
    }
    for( y = 0; y < height; y++ ) {
        maze[0][y] = '*';
        maze[ width - 1][y] = '*';
        maze[ width - 2][y] = '*';
    }

    // ADD EXTRANCE
    maze[0][1] = 'E';

    // ADD EXIT
    maze[ width - 2 ][ height - 3 ] = 'X';
}

void display_maze( unsigned short width, unsigned short height, unsigned short currentx, unsigned short currenty )
{
    unsigned short x, y;
    unsigned char colour;

    unsigned short boxwidth = 640 / width;
    unsigned short boxheight = 480 / height;

    for( x = 0; x < width; x++ ) {
        for( y = 0; y < height; y++ ) {
            if( ( currentx == x ) && ( currenty == y ) ) {
                colour = GREEN;
            } else {
                switch( maze[x][y] ) {
                    case '*':
                        colour = RED;
                        break;
                    case '#':
                        colour = BLUE;
                        break;
                    case ' ':
                        colour = WHITE;
                        break;
                case 'E':
                        colour = MAGENTA;
                        break;
                    case 'X':
                        colour = YELLOW;
                        break;
                }
            }
            gpu_rectangle( colour, x * boxwidth, y * boxheight, x * boxwidth + boxwidth - 1, y * boxheight + boxheight - 1 );
        }
    }
}

// ADAPTED FROM https://rosettacode.org/wiki/Maze_generation#BASIC
void generate_maze( unsigned short width, unsigned short height )
{
    unsigned short currentx, currenty, oldx, oldy, x, y, i, done;

    // Start at random location
    currentx = rng( width - 2 ); if( currentx % 2 == 0 ) currentx++;
    currenty = rng( height - 2 ); if( currenty % 2 == 0 ) currenty++;
    maze[currentx][currenty] = ' ';

    done = 0;

    do {
        display_maze( width, height, currentx, currenty );

        // GENERATE 32 CELLS
        for( i = 0; i < 32; i++ ) {
            // RECORD PRESENT LOCATION
            oldx = currentx;
            oldy = currenty;

            // Move in a random direction
            switch( rng(4) ) {
                case 0:
                    if( currentx + 2 < width - 1 ) currentx += 2;
                    break;
                case 1:
                    if( currenty + 2 < height - 1 ) currenty += 2;
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
        for( x = 1; x < width - 1; x += 2 ) {
            for( y = 1; y < height - 1; y += 2 ) {
                if( maze[x][y] == '#' ) done = 0;
            }
        }
    } while( done == 0 );
}

void main( void )
{
    unsigned short level = 0;
	while(1) {
        tpu_cs();
        terminal_showhide( 0 );

        initialise_maze( levelwidths[level], levelheights[level] );
        tpu_set( 21, 29, TRANSPARENT, YELLOW ); tpu_outputstring( "Generating Maze - Best to take notes!" );
        tpu_set( 1, 29, TRANSPARENT, BLACK ); tpu_outputstring( "Level: " ); tpu_outputnumber_short( level );
        tpu_set( 60, 29, TRANSPARENT, BLACK ); tpu_outputstring( "Size: " ); tpu_outputnumber_short( levelwidths[level] ); tpu_outputstring( " x " ); tpu_outputnumber_short( levelheights[level] );
        generate_maze( levelwidths[level], levelheights[level] );
        display_maze( levelwidths[level], levelheights[level], 1, 1 );

        tpu_set( 21, 29, TRANSPARENT, GREEN ); tpu_outputstring( "        Press FIRE to restart!       " );
        while(  ( get_buttons() & 2 ) == 0 );
        tpu_set( 21, 29, TRANSPARENT, PURPLE ); tpu_outputstring( "       Release FIRE to restart!      " );
        while( get_buttons() & 2  );
        tpu_cs();
        level = ( level < MAXLEVEL ) ? level + 1 : 0;
    }
}
