#include "PAWSlibrary.h"

// MAZE SIZES
#define MAXWIDTH 160
#define MAXHEIGHT 120
#define MAXLEVEL 8

// DRAWING VARIABLES
#define MAXDEPTH 16

// LEVEL - DETERMINES SIZE OF MAZE
unsigned short level = 0;

// WIDTH OF MAZE DEPENDING ON LEVEL
unsigned short levelwidths[] = { 10, 16, 20, 32, 40, 64, 80, 128, 160 };
unsigned short levelheights[] = { 8, 12, 16, 24, 30, 48, 60, 80, 120 };
unsigned short levelgenerationsteps[] = { 1, 2, 4, 4, 8, 16, 64, 128, 512 };

// TOP LEFT COORDINATES FOR THE PERSPECTIVE DRAWING
//short perspectivex[] = { 0, 40, 80, 120, 160, 200, 240, 280, 320 };       // MAXDEPTH 8
//short perspectivey[] = { 0, 30, 60, 90, 120, 150, 180, 210, 240 };        // MAXDEPTH 8
short perspectivex[] = { 0, 20, 40, 60, 80, 100, 120, 140, 160, 180, 200, 220, 240, 260, 280, 300, 320 };
short perspectivey[] = { 0, 15, 30, 45, 60, 75, 90, 105, 120, 135, 150, 165, 180, 195, 210, 225, 240 };

// DIRECTION STEPS IN X and Y
short directionx[] = { 0, 1, 0, -1 }, leftdirectionx[] = { -1, 0, 1, 0 }, rightdirectionx[] = { 1, 0, -1, 0 };
short directiony[] = { -1, 0, 1, 0 }, leftdirectiony[] = { 0, -1, 0, 1 }, rightdirectiony[] = { 0, 1, 0, -1 };

// STORAGE FOR MAZE and MAP
// WALLS WILL BE '#' '*' GAPS ' ' ENTRANCE 'E' EXIT 'X'
char maze[MAXWIDTH+2][MAXHEIGHT];
char map[MAXWIDTH+2][MAXHEIGHT];

// POSITION AND DIRECTION OF THE GOST
unsigned short ghostx[4], ghosty[4], ghostdirection[4];

// GHOST COLOUR SELECTOR
unsigned char ghostcolour( unsigned short ghost ) {
    switch( ghost ) {
        case 0:
            return( CYAN );
            break;
        case 1:
            return( MAGENTA );
            break;
        case 2:
            return( ORANGE );
            break;
        case 3:
            return( RED );
            break;
    }
}

// DRAW GHOST AT CORRECT DISTANCE
void draw_ghost( unsigned short steps, unsigned short ghostnumber, unsigned short playerdirection ) {
    unsigned short sizechangex = ( MAXDEPTH - steps ) * 6;
    unsigned short sizechangey = ( MAXDEPTH - steps ) * 6;

    unsigned short centrex = 320;
    unsigned short centrey = 240 + sizechangey;
    unsigned short offsetx = ( sizechangex * 2 ) / 6;
    unsigned short eyeoffsetx = ( sizechangex + offsetx ) / 2;
    unsigned short eyeoffsety = sizechangey / 2;
    unsigned char colour = ghostcolour( ghostnumber );

    // MAIN BODY
    gpu_rectangle( colour, centrex - sizechangex, centrey - sizechangey, centrex + sizechangex, centrey + sizechangey );

    // HEAD
    gpu_circle( colour, centrex, centrey - sizechangey, sizechangex, 1 );

    // FRILLS
    if( steps < ( MAXDEPTH - 1 ) ) {
        gpu_circle( colour, centrex - ( offsetx * 2 ), centrey + sizechangey, offsetx, 1 );
        gpu_circle( colour, centrex, centrey + sizechangey, offsetx, 1 );
        gpu_circle( colour, centrex + ( offsetx * 2 ), centrey + sizechangey, offsetx, 1 );
    } else {
        gpu_pixel( colour, centrex - offsetx, centrey + sizechangey + 1 );
        gpu_pixel( colour, centrex, centrey + sizechangey + 1 );
        gpu_pixel( colour, centrex + offsetx, centrey + sizechangey + 1 );
    }

    // EYE WHITES
    if( steps < ( MAXDEPTH - 1 ) ) {
        switch( abs( playerdirection - ghostdirection[ ghostnumber ] ) ) {
            case 0:
                // SAME DIRECTION, NO EYES
                break;
            case 1:
                gpu_circle( WHITE, centrex - eyeoffsetx, centrey - eyeoffsety, eyeoffsetx / 2, 1 );
                // GHOST FACING LEFT
                break;
            case 2:
                // GHOST DIRECTLY FACING
                gpu_circle( WHITE, centrex - eyeoffsetx, centrey - eyeoffsety, eyeoffsetx / 2, 1 );
                gpu_circle( WHITE, centrex + eyeoffsetx, centrey - eyeoffsety, eyeoffsetx / 2, 1 );
                break;
            case 3:
                // GHOST FACING RIGHT
                gpu_circle( WHITE, centrex + eyeoffsetx, centrey - eyeoffsety, eyeoffsetx / 2, 1 );
                break;
        }
    }

    // EYE PUPILS
    if( steps < ( MAXDEPTH - 2 ) ) {
        switch( abs( playerdirection - ghostdirection[ ghostnumber ] ) ) {
            case 0:
                // SAME DIRECTION, NO EYES
                break;
            case 1:
                gpu_circle( BLACK, centrex - eyeoffsetx, centrey - eyeoffsety, eyeoffsetx / 4, 1 );
                // GHOST FACING LEFT
                break;
            case 2:
                // GHOST DIRECTLY FACING
                gpu_circle( BLACK, centrex - eyeoffsetx, centrey - eyeoffsety, eyeoffsetx / 4, 1 );
                gpu_circle( BLACK, centrex + eyeoffsetx, centrey - eyeoffsety, eyeoffsetx / 4, 1 );
                break;
            case 3:
                // GHOST FACING RIGHT
                gpu_circle( BLACK, centrex + eyeoffsetx, centrey - eyeoffsety, eyeoffsetx / 4, 1 );
                break;
        }
    }
}

// MOVE A GHOST RANDOMLY IN THE MAZE
void move_ghost( unsigned short ghostnumber) {
    // CHECK IF FACING A BLANK SPACE
    if( maze[ ghostx[ ghostnumber ] + directionx[ ghostdirection[ ghostnumber ] ] ][ ghosty[ ghostnumber ] + directiony[ ghostdirection[ ghostnumber ] ] ] == ' ' ) {
        // DECIDE IF TURNING LEFT
        if( maze[ ghostx[ ghostnumber ] + leftdirectionx[ ghostdirection[ ghostnumber ] ] ][ ghosty[ ghostnumber ] + leftdirectionx[ ghostdirection[ ghostnumber ] ] ] == ' ' && ( rng( 32 ) == 0 ) ) {
            // TURN LEFT
            ghostdirection[ ghostnumber ] = ( ghostdirection[ ghostnumber ] == 0 ) ? 3 : ghostdirection[ ghostnumber ] - 1;
        } else {
            // DECIDE IF TURNING RIGHT
            if( maze[ ghostx[ ghostnumber ] + rightdirectionx[ ghostdirection[ ghostnumber ] ] ][ ghosty[ ghostnumber ] + rightdirectionx[ ghostdirection[ ghostnumber ] ] ] == ' ' && ( rng( 32 ) == 0 ) ) {
                // TURN RIGHT
                ghostdirection[ ghostnumber ] = ( ghostdirection[ ghostnumber ] == 3 ) ? 0 : ghostdirection[ ghostnumber ] + 1;
            } else {
                // MOVE FORWARD
                ghostx[ ghostnumber ] += directionx[ ghostdirection[ ghostnumber ] ];
                ghosty[ ghostnumber ] += directiony[ ghostdirection[ ghostnumber ] ];
            }
        }
    } else {
        // RANDOM TURN AS AT A WALL
        if( rng( 2 ) == 0 ) {
            // TURN LEFT
            ghostdirection[ ghostnumber ] = ( ghostdirection[ ghostnumber ] == 0 ) ? 3 : ghostdirection[ ghostnumber ] - 1;
        } else {
            // TURN RIGHT
            ghostdirection[ ghostnumber ] = ( ghostdirection[ ghostnumber ] == 3 ) ? 0 : ghostdirection[ ghostnumber ] + 1;
        }
    }
}


// DRAW A PILL
void draw_pill( unsigned short steps ) {
    gpu_circle( WHITE, 320, 225 + 15 * ( MAXDEPTH - steps ), 4 + 2 * ( MAXDEPTH - steps ), 1 );
    gpu_circle( GREY2, 320, 225 + 15 * ( MAXDEPTH - steps ), 4 + 2 * ( MAXDEPTH - steps ), 0 );
}


// CREATE A BLANK MAZE OF WIDTH x HEIGHT
// ADD ENTRANCE AND EXIT AND GHOSTS
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

    // POSITION GHOSTS AT CENTRE
    for( unsigned short ghost = 0; ghost < 4; ghost++ ) {
        if( ghost <= level ) {
            // AT EXIT
            ghostx[ ghost ] = width / 2;
            ghosty[ ghost ] = height / 2;
            ghostdirection[ ghost ] = ghost;
        } else {
            // OFF MAP
            ghostx[ ghost ] = width + 1;
            ghosty[ ghost ] = height - 3;
            ghostdirection[ ghost ] = ghost;
        }
    }
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
            gpu_rectangle( colour, 475 + x * boxwidth, 10 + y * boxheight, 474 + x * boxwidth + boxwidth, 9 + y * boxheight + boxheight );
        }
    }

    gpu_rectangle( GREEN, 475 + currentx * boxwidth, 10 + currenty * boxheight, 474 + currentx * boxwidth + boxwidth, 9 + currenty * boxheight + boxheight );
    for( unsigned short ghost = 0; ghost < 4; ghost++ ) {
        if( ghost <= level ) {
            gpu_rectangle( ghostcolour( ghost ), 475 + ghostx[ ghost ] * boxwidth, 10 + ghosty[ ghost ] * boxheight, 474 + ghostx[ ghost ] * boxwidth + boxwidth, 9 + ghosty[ ghost ] * boxheight + boxheight );
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
        case 4:
            gpu_character_blit( GREEN, 462, 106, 1, 0 );
        case 3:
            gpu_character_blit( GREEN, 462, 114, 1, 0 );
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
    unsigned short newx = 1, newy = 1, direction = 1, newdirection = 1, currentx = 1, currenty = 1, visiblesteps, mappeeks = 4;
    short steps;

    // LOOP UNTIL REACHED THE EXIT
    while( ( currentx != width - 2 ) || ( currenty != height -3 ) ) {
        // SET CURRENT LOCATION TO VISITED
        map[currentx][currenty] = ' ';

        tpu_cs();
        gpu_cs();

        // FIND NUMBER OF STEPS FORWARD TO A WALL
        visiblesteps = counttowall( currentx, currenty, direction );
        if( visiblesteps <= MAXDEPTH - 1 ) {
            // WALL IS NOT AT HORIZON
            switch( maze[currentx + directionx[direction] * visiblesteps][currenty + directiony[direction] * visiblesteps] ) {
                case 'X':
                    gpu_rectangle( YELLOW, 0, perspectivey[ visiblesteps + 1 ], 640, 480 - perspectivey[ visiblesteps + 1 ] );
                    switch( visiblesteps ) {
                        case 1:
                            gpu_character_blit( GREEN, 192, perspectivey[ visiblesteps + 1 ] + 16, 'E', 3 );
                            gpu_character_blit( GREEN, 256, perspectivey[ visiblesteps + 1 ] + 16, 'X', 3 );
                            gpu_character_blit( GREEN, 320, perspectivey[ visiblesteps + 1 ] + 16, 'I', 3 );
                            gpu_character_blit( GREEN, 384, perspectivey[ visiblesteps + 1 ] + 16, 'T', 3 );
                            break;
                        case 2:
                            gpu_character_blit( GREEN, 256, perspectivey[ visiblesteps + 1 ] + 8, 'E', 2 );
                            gpu_character_blit( GREEN, 288, perspectivey[ visiblesteps + 1 ] + 8, 'X', 2 );
                            gpu_character_blit( GREEN, 320, perspectivey[ visiblesteps + 1 ] + 8, 'I', 2 );
                            gpu_character_blit( GREEN, 352, perspectivey[ visiblesteps + 1 ] + 8, 'T', 2 );
                            break;
                        case 3:
                            gpu_character_blit( GREEN, 288, perspectivey[ visiblesteps + 1 ] + 4, 'E', 1 );
                            gpu_character_blit( GREEN, 304, perspectivey[ visiblesteps + 1 ] + 4, 'X', 1 );
                            gpu_character_blit( GREEN, 320, perspectivey[ visiblesteps + 1 ] + 4, 'I', 1 );
                            gpu_character_blit( GREEN, 336, perspectivey[ visiblesteps + 1 ] + 4, 'T', 1 );
                            break;
                        case 4:
                            gpu_character_blit( GREEN, 304, perspectivey[ visiblesteps + 1 ] + 2, 'E', 0 );
                            gpu_character_blit( GREEN, 312, perspectivey[ visiblesteps + 1 ] + 2, 'X', 0 );
                            gpu_character_blit( GREEN, 320, perspectivey[ visiblesteps + 1 ] + 2, 'I', 0 );
                            gpu_character_blit( GREEN, 328, perspectivey[ visiblesteps + 1 ] + 2, 'T', 0 );
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
        for( steps = min( visiblesteps, MAXDEPTH - 1 ); steps >= 0; steps-- ) {
            // DRAW PILL
            if( maze[ currentx + directionx[ direction ] * steps ][ currenty + directiony[ direction ] * steps ] == ' ' && map[ currentx + directionx[ direction ] * steps ][ currenty + directiony[ direction ] * steps ] != ' ' ) {
                draw_pill( steps );
            }

            // DRAW GHOST
            for( unsigned ghost = 0; ghost < 4; ghost++ ) {
                if( ghost <= level ) {
                    if( ( currentx + directionx[ direction ] * steps == ghostx[ ghost ] ) && ( currenty + directiony[ direction ] * steps == ghosty[ ghost ] ) ) {
                        draw_ghost( steps, ghost, direction );
                    }
                }
            }

            // DRAW SIDE WALLS
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

        // SET 2 second timeout
        set_timer1khz( 2000 );

        // WAIT FOR INPUT TO MOVE  OR TIMEOUT
        while( ( currentx == newx ) && ( currenty == newy ) && ( direction == newdirection ) && get_timer1khz() ) {
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

            // FIRE2 - PEEK ( only 4 goes! )
            if( ( get_buttons() & 4 ) && ( mappeeks != 0 ) ) {
                draw_map( width, height, currentx, currenty, direction, 0, mappeeks );
                while( get_buttons() & 4 );
                mappeeks--;
                draw_map( width, height, currentx, currenty, direction, 1, mappeeks );
            }
        }

        currentx = newx; currenty = newy; direction = newdirection;
        for( unsigned short ghost = 0; ghost < 4; ghost++ ) {
            if( ghost <= level ) {
                move_ghost( ghost );
            }
        }
    }
}

void main( void )
{
    unsigned short levelselected;

	while(1) {
        // SETUP THE SCREEN BLUE/GREEN BACKGROUND
        gpu_cs();
        tpu_cs();
        terminal_showhide( 0 );
        set_background( 0, 0, BKG_RAINBOW );

        levelselected = 0;
        do {
            tpu_outputstringcentre( 29, TRANSPARENT, YELLOW, "Select Level" );
            tpu_set( 1, 29, TRANSPARENT, BLACK ); tpu_outputstring( "Level: " ); tpu_outputnumber_short( level );
            tpu_set( 60, 29, TRANSPARENT, BLACK ); tpu_outputstring( "Size: " ); tpu_outputnumber_short( levelwidths[level] ); tpu_outputstring( " x " ); tpu_outputnumber_short( levelheights[level] );

            while( get_buttons() == 1 );
            // LEFT / RIGHT to change level, FIRE to select
            if( get_buttons() & 32 ) {
                while( get_buttons() & 32 );
                level = ( level == 0 ) ? MAXLEVEL : level - 1;
            }
            if( get_buttons() & 64 ) {
                while( get_buttons() & 64 );
                level = ( level < MAXLEVEL ) ? level + 1 : 0;
            }
            if( get_buttons() & 2 ) {
                while( get_buttons() & 2 );
                levelselected = 1;
            }
        } while( levelselected == 0 );

        // GENERATE THE MAZE
        tpu_outputstringcentre( 29, TRANSPARENT, YELLOW, "Generating Maze - Best to take notes!" );
        initialise_maze( levelwidths[level], levelheights[level] );
        generate_maze( levelwidths[level], levelheights[level], levelgenerationsteps[level] );
        display_maze( levelwidths[level], levelheights[level], 1, 1 );

        // WAIT TO ENTER THE MAZE
        tpu_outputstringcentre( 29, TRANSPARENT, GREEN, "Press FIRE to walk the maze!" ); while( ( get_buttons() & 2 ) == 0 );
        tpu_outputstringcentre( 29, TRANSPARENT, PURPLE, "Release FIRE!" ); while( get_buttons() & 2 );

        // ENTER THE MAZE IN 3D
        set_background( DKBLUE, DKGREEN, BKG_5050_V );
        walk_maze( levelwidths[level], levelheights[level] );

        // COMPLETED THE MAZE
        set_background( 0, 0, BKG_STATIC );
        tpu_outputstringcentre( 29, TRANSPARENT, GREEN, "Press FIRE to restart!" ); while( ( get_buttons() & 2 ) == 0 );
        tpu_outputstringcentre( 29, TRANSPARENT, PURPLE, "Release FIRE!" ); while( get_buttons() & 2  );

        // GO TO THE NEXT LEVEL, OR BACK TO 0
        level = ( level < MAXLEVEL ) ? level + 1 : 0;
    }
}
