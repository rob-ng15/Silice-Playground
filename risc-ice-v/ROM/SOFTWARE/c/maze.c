#include "PAWSlibrary.h"

#define MAXWIDTH 40
#define MAXHEIGHT 30
#define MAXLEVEL 4

// WIDTH OF MAZE DEPENDING ON LEVEL
unsigned short levelwidths[] = { 10, 16, 20, 32, 40, 64, 80, 128, 160 };
unsigned short levelheights[] = { 8, 12, 16, 24, 30, 48, 60, 80, 120 };
unsigned short levelgenerationsteps[] = { 1, 1, 1, 2, 4, 16, 32, 64, 128 };

// TOP LEFT COORDINATES FOR THE PERSPECTIVE DRAWING
short perspectivex[] = { 0, 40, 80, 120, 160, 200, 240, 280, 320 };
short perspectivey[] = { 0, 30, 60, 90, 120, 150, 180, 210, 240 };

// DIRECTION STEPS IN X and Y
short directionx[] = { 0, 1, 0, -1 }, leftdirectionx[] = { -1, 0, 1, 0 }, rightdirectionx[] = { 1, 0, -1, 0 };
short directiony[] = { -1, 0, 1, 0 }, leftdirectiony[] = { 0, -1, 0, 1 }, rightdirectiony[] = { 0, 1, 0, -1 };

// STORAGE FOR MAZE and MAP
// WALLS WILL BE '#' '*' GAPS ' ' ENTRANCE 'E' EXIT 'X'
char maze[MAXWIDTH][MAXHEIGHT];
char map[MAXWIDTH][MAXHEIGHT];

// CREATE A BLANK MAZE OF WIDTH x HEIGHT
// ADD ENTRANCE AND EXIT
void initialise_maze( unsigned short width, unsigned short height )
{
    unsigned short x,y;

    // FILL WITH WALLS
    for( x = 0; x < width; x++ ) {
        for( y = 0; y < height; y++ ) {
            maze[x][y] = '#';
            map[x][y] = '#';
        }
    }

    // ADD EXTRANCE
    maze[0][1] = 'E';
    map[0][1] = 'E';

    // ADD EXIT
    maze[ width - 2 ][ height - 3 ] = 'X';
    map[ width - 2 ][ height - 3 ] = 'X';
}

// DRAW THE MAZE FULL SCREEN - USED DURING GENERATION
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
// GENERATE A MAZE OF WIDTH x HEIGHT - DRAW DURING GENERATION
void generate_maze( unsigned short width, unsigned short height, unsigned short steps )
{
    unsigned short currentx, currenty, oldx, oldy, x, y, i, done;

    // Start at random location
    currentx = rng( width - 2 ); if( currentx % 2 == 0 ) currentx++;
    currenty = rng( height - 2 ); if( currenty % 2 == 0 ) currenty++;
    maze[currentx][currenty] = ' ';

    done = 0;

    do {
        display_maze( width, height, currentx, currenty );

        // GENERATE CELLS
        for( i = 0; i < steps; i++ ) {
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

// DRAW THE MAP IN RIGHT CORENER WITH COMPASS
void draw_map( unsigned short width, unsigned short height, unsigned short currentx, unsigned short currenty, unsigned short direction, unsigned char mapmaze, unsigned short mappeeks )
{
    unsigned short x, y;
    unsigned char colour;

    unsigned short boxwidth = 160 / width;
    unsigned short boxheight = 120 / height;

    // DRAW MAP BACKGROUND - PARCHMENT
    gpu_rectangle( ORANGE, 460, 0, 640, 140 );

    for( x = 0; x < width; x++ ) {
        for( y = 0; y < height; y++ ) {
            if( ( currentx == x ) && ( currenty == y ) ) {
                colour = GREEN;
            } else {
                switch( mapmaze ? map[x][y] : maze[x][y] ) {
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
            gpu_rectangle( colour, 475 + x * boxwidth, 10 + y * boxheight, 474 + x * boxwidth + boxwidth, 9 + y * boxheight + boxheight );
        }
    }

    gpu_triangle( BLACK, 468, 1, 473, 10, 463, 10 );
    gpu_triangle( BLACK, 473, 10, 468, 19, 463, 10 );
    switch( direction ) {
        case 0:
            gpu_triangle( GREEN, 468, 1, 473, 10, 463, 10 );
            break;
        case 1:
            gpu_triangle( GREEN, 468, 1, 473, 10, 468, 19 );
            break;
        case 2:
            gpu_triangle( GREEN, 473, 10, 468, 19, 463, 10 );
            break;
        case 3:
            gpu_triangle( GREEN, 468, 1, 468, 19, 463, 10 );
            break;
    }

    switch( mappeeks ) {
        case 2:
            gpu_character_blit( GREEN, 462, 122, 1, 0 );
        case 1:
            gpu_character_blit( GREEN, 462, 130, 1, 0 );
            break;
        default:
            break;
    }
}

// CALCULATE NUMBER OF STEPS TO HIT A WALL
unsigned short counttowall( unsigned short currentx, unsigned short currenty, unsigned short direction )
{
    unsigned short steps = 0, foundwall = 0;

    while( foundwall == 0 ) {
        switch( maze[currentx][currenty] ) {
            case '#':
            case 'E':
            case 'X':
                foundwall = 1;
                break;
            default:
                currentx += directionx[ direction ];
                currenty += directiony[ direction ];
                steps++;
                break;
        }
    }

    return( steps );
}

// FIND WHAT IS TO THE LEFT AT STEPS IN FRONT
unsigned char whatisleft( unsigned short currentx, unsigned short currenty, unsigned short direction, unsigned short steps )
{
    return( maze[currentx + directionx[ direction ] * steps + leftdirectionx[ direction ]][currenty + directiony[ direction ] * steps + leftdirectiony[ direction ]] );
}

// FIND WHAT IS TO THE RIGHT AT STEPS IN FRONT
unsigned char whatisright( unsigned short currentx, unsigned short currenty, unsigned short direction, unsigned short steps )
{
    return( maze[currentx + directionx[ direction ] * steps + rightdirectionx[ direction ]][currenty + directiony[ direction ] * steps + rightdirectiony[ direction ]] );
}


// DRAW LEFT or RIGHT WALLS
void left_wall( unsigned char colour, short steps )
{
    gpu_quadrilateral( colour, perspectivex[ steps ], perspectivey[ steps ], perspectivex[ steps + 1 ], perspectivey[ steps + 1 ],
                                perspectivex[ steps + 1 ], 480 - perspectivey[ steps + 1 ], perspectivex[ steps ], 480 - perspectivey[ steps ] );
}
void right_wall( unsigned char colour, unsigned short steps )
{
    gpu_quadrilateral( colour, 640 - perspectivex[ steps ], perspectivey[ steps ], 640 - perspectivex[ steps  ], 480 - perspectivey[ steps ],
                                640 - perspectivex[ steps + 1 ], 480 - perspectivey[ steps + 1 ], 640 - perspectivex[ steps + 1 ], perspectivey[ steps + 1 ] );
}

// WALK THE MAZE IN 3D
void walk_maze( unsigned short width, unsigned short height )
{
    // SET START LOCATION TO TOP LEFT FACING EAST
    unsigned short newx = 1, newy = 1, direction = 1, newdirection = 1, currentx = 1, currenty = 1, visiblesteps, mappeeks = 2;
    short steps;

    // LOOP UNTIL REACHED THE EXIT
    while( ( currentx != width - 2 ) || ( currenty != height -3 ) ) {
        // SET CURRENT LOCATION TO VISITED
        map[currentx][currenty] = ' ';

        tpu_cs();
        gpu_cs();

        // FIND NUMBER OF STEPS FORWARD TO A WALL
        visiblesteps = counttowall( currentx, currenty, direction );
        if( visiblesteps <= 7 ) {
            // WALL IS NOT AT HORIZON
            switch( maze[currentx + directionx[direction] * visiblesteps][currenty + directiony[direction] * visiblesteps] ) {
                case 'X':
                    gpu_rectangle( YELLOW, 0, perspectivey[ visiblesteps + 1 ], 640, 480 - perspectivey[ visiblesteps + 1 ] );
                    switch( visiblesteps ) {
                        case 1:
                            gpu_character_blit( GREEN, 256, 68, 'E', 2 );
                            gpu_character_blit( GREEN, 288, 68, 'X', 2 );
                            gpu_character_blit( GREEN, 320, 68, 'I', 2 );
                            gpu_character_blit( GREEN, 352, 68, 'T', 2 );
                            break;
                        case 2:
                            gpu_character_blit( GREEN, 288, 94, 'E', 1 );
                            gpu_character_blit( GREEN, 304, 94, 'X', 1 );
                            gpu_character_blit( GREEN, 320, 94, 'I', 1 );
                            gpu_character_blit( GREEN, 336, 94, 'T', 1 );
                            break;
                        case 3:
                            gpu_character_blit( GREEN, 304, 122, 'E', 0 );
                            gpu_character_blit( GREEN, 312, 122, 'X', 0 );
                            gpu_character_blit( GREEN, 320, 122, 'I', 0 );
                            gpu_character_blit( GREEN, 328, 122, 'T', 0 );
                            break;
                        default:
                            break;
                    }
                    break;
                case 'E':
                    gpu_rectangle( MAGENTA, 0, perspectivey[ visiblesteps + 1 ], 640, 480 - perspectivey[ visiblesteps + 1 ] );
                    break;
                case '#':
                    gpu_rectangle( GREY2, 0, perspectivey[ visiblesteps + 1 ], 640, 480 - perspectivey[ visiblesteps + 1 ] );
                    break;
                default:
                    break;
            }
        }

        // MOVE BACKWARDS FROM WALL
        for( steps = min( visiblesteps, 7 ); steps >= 0; steps-- ) {
            switch( whatisleft( currentx, currenty, direction, steps ) ) {
                case 'X':
                    left_wall( YELLOW, steps );
                    break;
                case ' ':
                    // GAP
                    gpu_rectangle( GREY2, 0, perspectivey[ steps + 1 ], perspectivex[ steps + 1 ], 480 - perspectivey[ steps + 1 ] );
                    break;
                case 'E':
                    left_wall( MAGENTA, steps );
                    break;
                case '#':
                    left_wall( GREY1, steps );
                    break;
                default:
                    break;
            }
            switch( whatisright( currentx, currenty, direction, steps ) ) {
                case 'X':
                    right_wall( YELLOW, steps );
                    break;
                case ' ':
                    // GAP
                    gpu_rectangle( GREY2, 640 - perspectivex[ steps + 1 ], perspectivey[ steps + 1 ], 640, 480 - perspectivey[ steps + 1 ] );
                    break;
                case 'E':
                    right_wall( MAGENTA, steps );
                    break;
                case '#':
                    right_wall( GREY1, steps );
                    break;
                default:
                    break;
            }
        }

        draw_map( width, height, currentx, currenty, direction, 1, mappeeks );

        // WAIT FOR INPUT TO MOVE
        while( ( currentx == newx ) && ( currenty == newy ) && ( direction == newdirection ) ) {
            // LEFT
            if( get_buttons() & 32 ) {
                newdirection = ( newdirection == 0 ) ? 3 : newdirection - 1;
                while( get_buttons() & 32 );
            }

            // RIGHT
            if( get_buttons() & 64 ) {
                newdirection = ( newdirection == 3 ) ? 0 : newdirection + 1;
                while( get_buttons() & 64 );
            }

            // FORWARD
            if( get_buttons() & 8 ) {
                if( ( maze[ currentx + directionx[direction] ][ currenty + directiony[direction] ] == ' '  ) || ( maze[ currentx + directionx[direction] ][ currenty + directiony[direction] ] == 'X'  ) ) {
                    newx += directionx[direction];
                    newy += directiony[direction];
                }
                while( get_buttons() & 8 );
            }

            // BACKWARD
            if( get_buttons() & 16 ) {
                if( ( maze[ currentx - directionx[direction] ][ currenty - directiony[direction] ] == ' '  ) || ( maze[ currentx - directionx[direction] ][ currenty - directiony[direction] ] == 'X'  ) ) {
                    newx -= directionx[direction];
                    newy -= directiony[direction];
                }
                while( get_buttons() & 16 );
            }

            // FIRE2 - PEEK ( only 2 goes! )
            if( ( get_buttons() & 4 ) && ( mappeeks != 0 ) ) {
                draw_map( width, height, currentx, currenty, direction, 0, mappeeks );
                while( get_buttons() & 4 );
                mappeeks--;
                draw_map( width, height, currentx, currenty, direction, 1, mappeeks );
            }
        }

        currentx = newx; currenty = newy; direction = newdirection;
    }
}

void main( void )
{
    unsigned short level = 0;
	while(1) {
        // SETUP THE SCREEN BLUE/GREEN BACKGROUND
        tpu_cs();
        terminal_showhide( 0 );
        set_background( DKBLUE, DKGREEN, 8 );

        // GENERATE THE MAZE
        tpu_set( 21, 29, TRANSPARENT, YELLOW ); tpu_outputstring( "Generating Maze - Best to take notes!" );
        tpu_set( 1, 29, TRANSPARENT, BLACK ); tpu_outputstring( "Level: " ); tpu_outputnumber_short( level );
        tpu_set( 60, 29, TRANSPARENT, BLACK ); tpu_outputstring( "Size: " ); tpu_outputnumber_short( levelwidths[level] ); tpu_outputstring( " x " ); tpu_outputnumber_short( levelheights[level] );
        initialise_maze( levelwidths[level], levelheights[level] );
        generate_maze( levelwidths[level], levelheights[level], levelgenerationsteps[level] );
        display_maze( levelwidths[level], levelheights[level], 1, 1 );

        // WAIT TO ENTER THE MAZE
        tpu_set( 21, 29, TRANSPARENT, GREEN ); tpu_outputstring(  "     Press FIRE to walk the maze!    " ); while(  ( get_buttons() & 2 ) == 0 );
        tpu_set( 21, 29, TRANSPARENT, PURPLE ); tpu_outputstring( "             Release FIRE!           " ); while( get_buttons() & 2 );

        // ENTER THE MAZE IN 3D
        walk_maze( levelwidths[level], levelheights[level] );

        // COMPLETED THE MAZE, SET BACKGROUND TO STATIC
        set_background( DKBLUE, DKGREEN, 6 );
        tpu_set( 21, 29, TRANSPARENT, GREEN ); tpu_outputstring( "        Press FIRE to restart!       " ); while(  ( get_buttons() & 2 ) == 0 );
        tpu_set( 21, 29, TRANSPARENT, PURPLE ); tpu_outputstring( "       Release FIRE!      " ); while( get_buttons() & 2  );

        // GO TO THE NEXT LEVEL, OR BACK TO 0
        level = ( level < MAXLEVEL ) ? level + 1 : 0;
    }
}
