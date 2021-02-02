#include "PAWSlibrary.h"

// INCLUDE TOMBSTONE IMAGE
#include "TOMBSTONEPPM.h"
unsigned char *tombstonebitmap;

// INCLUDE CONTROLS IMAGE
#include "ULX3SPPM.h"
unsigned char *ulx3sbitmap;

// MAZE SIZES
#define MAXWIDTH 80
#define MAXHEIGHT 60
#define MAXLEVEL 6

// DRAWING VARIABLES
#define MAXDEPTH 14

// LEVEL - DETERMINES SIZE OF MAZE
unsigned short level = 0;

// WIDTH OF MAZE DEPENDING ON LEVEL
unsigned short levelwidths[] = { 10, 16, 20, 32, 40, 64, 80 };
unsigned short levelheights[] = { 8, 12, 16, 24, 30, 48, 60 };

// TOP LEFT COORDINATES FOR THE PERSPECTIVE DRAWING
short perspectivex[] = { 0, 100, 170, 218, 251, 273, 288, 298, 305, 310, 313, 315, 317, 318, 320 };
short perspectivey[] = { 0,  75, 128, 164, 188, 205, 216, 224, 229, 232, 235, 236, 238, 239, 240 };

// DIRECTION STEPS IN X and Y
short directionx[] = { 0, 1, 0, -1 }, leftdirectionx[] = { -1, 0, 1, 0 }, rightdirectionx[] = { 1, 0, -1, 0 };
short directiony[] = { -1, 0, 1, 0 }, leftdirectiony[] = { 0, -1, 0, 1 }, rightdirectiony[] = { 0, 1, 0, -1 };

// STORAGE FOR MAZE and MAP PLUS ACCESS FUNCTIONS USING A BIT ARRAY
// WALLS WILL BE '#' '*' GAPS ' ' ENTRANCE 'E' EXIT 'X'
unsigned short maze[ MAXWIDTH >> 4 ][MAXHEIGHT];
unsigned short map[ MAXWIDTH >> 4 ][MAXHEIGHT];

// POSITION AND DIRECTION OF THE GOST
unsigned short ghostx[4], ghosty[4], ghostdirection[4];
unsigned short ghosteyes[4][4] = { { 0, 1, 2, 3 }, { 3, 0, 1, 2 }, { 2, 3, 0, 1 }, { 1, 2, 3, 0 } };

// DRAW WELCOME SCREEN
void drawwelcome( void ) {
    gpu_outputstringcentre( YELLOW, 320, 8, "3D MONSTER MAZE", 2 );

    // DISPLAY ULX3 BITMAP
    bitmapblit( ulx3sbitmap, 320, 219, 160, 131, BLUE );

    // DRAW JOYSTICK AND LABEL
    gpu_circle( BLACK, 480, 340, 8, 1 );
    gpu_circle( BLACK, 480, 358, 8, 1 );
    gpu_circle( BLACK, 440, 358, 8, 1 );
    gpu_circle( BLACK, 520, 358, 8, 1 );
    gpu_circle( BLACK, 400, 358, 8, 1 );
    gpu_circle( BLACK, 360, 358, 8, 1 );
    gpu_outputstringcentre( CYAN, 480, 322, "STEP", 0 );
    gpu_outputstringcentre( CYAN, 480, 368, "BACK", 0 );
    gpu_outputstringcentre( CYAN, 440, 368, "TURN", 0 );
    gpu_outputstringcentre( CYAN, 440, 376, "LEFT", 0 );
    gpu_outputstringcentre( CYAN, 520, 368, "TURN", 0 );
    gpu_outputstringcentre( CYAN, 520, 376, "RIGHT", 0 );
    gpu_outputstringcentre( CYAN, 400, 368, "PEEK", 0 );
    gpu_outputstringcentre( CYAN, 360, 368, "POWER", 0 );
}

// RETURN CONTENTS OF == 0 MAZE == 1 MAP at ( X, Y )
unsigned char whatisat( unsigned short x, unsigned short y, unsigned char mapmaze ) {
    if( ( x == 0 ) && ( y == 1 ) ) {
        return( 'E' );
    }
    if( ( ( x == levelwidths[ level ] - 2 ) && ( y == levelheights[ level ] - 3 ) ) ) {
        return( 'X' );
    }
    switch( mapmaze ) {
        case 0:
            return( ( maze[ x >> 4 ][ y ] >> ( x & 0xf ) ) & 1 ? '#' : ' ' );
        case 1:
            return( ( map[ x >> 4 ][ y ] >> ( x & 0xf ) ) & 1 ? '#' : ' ' );
        default:
            return( '?' );
    }
}

// SET THE CONTENTS OF == 0 MAZE == 1 MAP at ( X, Y )
void setat( unsigned short x, unsigned short y, unsigned char value, unsigned char mapmaze ) {
    switch( mapmaze ) {
        case 0:
            switch( value ) {
                case ' ':
                    maze[ x >> 4 ][ y ] &= ~( 1 << ( x & 0x0f ) );
                    break;
                case '#':
                    maze[ x >> 4 ][ y ] |= ( 1 << ( x & 0x0f ) );
                    break;
            }
            break;
        case 1:
            switch( value ) {
                case ' ':
                    map[ x >> 4 ][ y ] &= ~( 1 << ( x & 0x0f ) );
                    break;
                case '#':
                    map[ x >> 4 ][ y ] |= ( 1 << ( x & 0x0f ) );
                    break;
            }
            break;
    }
}

// FIND WHAT IS TO THE FRONT AT STEPS IN FRONT
unsigned char whatisfront( unsigned short currentx, unsigned short currenty, unsigned short direction, unsigned short steps ) {
    return( whatisat( currentx + directionx[ direction ] * steps, currenty + directiony[ direction ] * steps, 0 ) );
}

// FIND WHAT IS BEHIND AT STEPS IN REAR
unsigned char whatisbehind( unsigned short currentx, unsigned short currenty, unsigned short direction, unsigned short steps ) {
    return( whatisat( currentx - directionx[ direction ] * steps, currenty - directiony[ direction ] * steps, 0 ) );
}

// FIND WHAT IS TO THE LEFT AT STEPS IN FRONT
unsigned char whatisleft( unsigned short currentx, unsigned short currenty, unsigned short direction, unsigned short steps ) {
    return( whatisat( currentx + directionx[ direction ] * steps + leftdirectionx[ direction ], currenty + directiony[ direction ] * steps + leftdirectiony[ direction ], 0 ) );
}

// FIND WHAT IS TO THE RIGHT AT STEPS IN FRONT
unsigned char whatisright( unsigned short currentx, unsigned short currenty, unsigned short direction, unsigned short steps ) {
    return( whatisat( currentx + directionx[ direction ] * steps + rightdirectionx[ direction ], currenty + directiony[ direction ] * steps + rightdirectiony[ direction ], 0 ) );
}

// GHOST COLOUR SELECTOR
unsigned char ghostcolour( unsigned short ghost ) {
    switch( ghost ) {
        case 0:
            return( CYAN );
        case 1:
            return( MAGENTA );
        case 2:
            return( ORANGE );
        case 3:
            return( RED );
        default:
            return( BLACK );
    }
}

// DRAW GHOST AT CORRECT DISTANCE
void draw_ghost( unsigned short steps, unsigned short ghostnumber, unsigned short playerdirection ) {
    unsigned short sizechange = ( 320 - perspectivex[ steps ] ) * 3 / 8;

    unsigned short centrex = 320;
    unsigned short centrey = 240;
    unsigned short offsetx = ( sizechange * 2 ) / 6;
    unsigned short eyeoffsetx = ( sizechange + offsetx ) / 2;
    unsigned short eyeoffsety = sizechange / 2;
    unsigned char colour = ghostcolour( ghostnumber );

    // SOLID
    gpu_dither( DITHEROFF );

    // MAIN BODY
    gpu_rectangle( colour, centrex - sizechange, centrey - sizechange, centrex + sizechange, centrey + sizechange );

    // HEAD
    gpu_circle( colour, centrex, centrey - sizechange, sizechange, 1 );

    // FRILLS
    switch( sizechange ) {
        case 1:
        case 2:
        case 3:
        case 6:
            gpu_pixel( colour, centrex - offsetx, centrey + sizechange + 1 );
            gpu_pixel( colour, centrex, centrey + sizechange + 1 );
            gpu_pixel( colour, centrex + offsetx, centrey + sizechange + 1 );
            break;

        default:
            gpu_circle( colour, centrex - ( offsetx * 2 ), centrey + sizechange, offsetx, 1 );
            gpu_circle( colour, centrex, centrey + sizechange, offsetx, 1 );
            gpu_circle( colour, centrex + ( offsetx * 2 ), centrey + sizechange, offsetx, 1 );
            break;
    }

    // EYE WHITES
    if( eyeoffsetx / 2 >= 4 ) {
        switch( ghosteyes[playerdirection][ghostdirection[ ghostnumber ]] ) {
            case 0:
                // SAME DIRECTION, NO EYES
                break;
            case 1:
                // GHOST FACING RIGHT
                gpu_circle( WHITE, centrex + eyeoffsetx, centrey - eyeoffsety, eyeoffsetx / 2, 1 );
                break;
            case 2:
                // GHOST DIRECTLY FACING
                gpu_circle( WHITE, centrex - eyeoffsetx, centrey - eyeoffsety, eyeoffsetx / 2, 1 );
                gpu_circle( WHITE, centrex + eyeoffsetx, centrey - eyeoffsety, eyeoffsetx / 2, 1 );
                break;
            case 3:
                // GHOST FACING LEFT
                gpu_circle( WHITE, centrex - eyeoffsetx, centrey - eyeoffsety, eyeoffsetx / 2, 1 );
                break;
        }
    } else {
        switch( ghosteyes[playerdirection][ghostdirection[ ghostnumber ]] ) {
            case 0:
                break;
            case 1:
                gpu_pixel( WHITE, centrex + eyeoffsetx, centrey - eyeoffsety );
                break;
            case 2:
                gpu_pixel( WHITE, centrex - eyeoffsetx, centrey - eyeoffsety );
                gpu_pixel( WHITE, centrex + eyeoffsetx, centrey - eyeoffsety );
                break;
            case 3:
                gpu_pixel( WHITE, centrex - eyeoffsetx, centrey - eyeoffsety );
                break;
        }
    }

    // EYE PUPILS
    if( eyeoffsetx / 4 >= 4 ) {
        switch( ghosteyes[playerdirection][ghostdirection[ ghostnumber ]] ) {
            case 0:
                // SAME DIRECTION, NO EYES
                break;
            case 1:
                // GHOST FACING RIGHT
                gpu_circle( BLACK, centrex + eyeoffsetx, centrey - eyeoffsety, eyeoffsetx / 4, 1 );
                break;
            case 2:
                // GHOST DIRECTLY FACING
                gpu_circle( BLACK, centrex - eyeoffsetx, centrey - eyeoffsety, eyeoffsetx / 4, 1 );
                gpu_circle( BLACK, centrex + eyeoffsetx, centrey - eyeoffsety, eyeoffsetx / 4, 1 );
                break;
            case 3:
                // GHOST FACING LEFT
                gpu_circle( BLACK, centrex - eyeoffsetx, centrey - eyeoffsety, eyeoffsetx / 4, 1 );
                break;
        }
    } else {
        switch( ghosteyes[playerdirection][ghostdirection[ ghostnumber ]] ) {
            case 0:
                break;
            case 1:
                gpu_pixel( BLACK, centrex + eyeoffsetx, centrey - eyeoffsety );
                break;
            case 2:
                gpu_pixel( BLACK, centrex - eyeoffsetx, centrey - eyeoffsety );
                gpu_pixel( BLACK, centrex + eyeoffsetx, centrey - eyeoffsety );
                break;
            case 3:
                gpu_pixel( BLACK, centrex - eyeoffsetx, centrey - eyeoffsety );
                break;
        }
    }
}

// MOVE A GHOST RANDOMLY IN THE MAZE
void move_ghost( unsigned short ghostnumber) {
    // CHECK IF FACING A BLANK SPACE
    if( whatisfront( ghostx[ ghostnumber ], ghosty[ ghostnumber ], ghostdirection[ ghostnumber ], 1 ) == ' ' ) {
        // DECIDE IF TURNING LEFT
        if( ( whatisleft( ghostx[ ghostnumber ], ghosty[ ghostnumber ], ghostdirection[ ghostnumber ], 0 ) == ' ' ) && ( rng( 4 ) == 0 ) ) {
            // TURN LEFT
            ghostdirection[ ghostnumber ] = ( ghostdirection[ ghostnumber ] == 0 ) ? 3 : ghostdirection[ ghostnumber ] - 1;
        } else {
            // DECIDE IF TURNING RIGHT
            if( ( whatisright( ghostx[ ghostnumber ], ghosty[ ghostnumber ], ghostdirection[ ghostnumber ], 0 ) == ' ' ) && ( rng( 4 ) == 0 ) ) {
                // TURN RIGHT
                ghostdirection[ ghostnumber ] = ( ghostdirection[ ghostnumber ] == 3 ) ? 0 : ghostdirection[ ghostnumber ] + 1;
            } else {
                // MOVE FORWARD OR RANDOMLY TURN
                switch( rng( 16 ) ) {
                    case 0:
                        // RANDOMLY TURN LEFT
                        break;
                    case 1:
                        // RANDOMLY TURN RIGHT
                        break;
                    default:
                        // MOVE FORWARD
                        ghostx[ ghostnumber ] += directionx[ ghostdirection[ ghostnumber ] ];
                        ghosty[ ghostnumber ] += directiony[ ghostdirection[ ghostnumber ] ];
                        break;
                }
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
    unsigned short pillsize = ( 320 - perspectivex[ steps ] ) / 8;

    switch( pillsize ) {
        case 0:
            break;

        case 1:
        case 2:
        case 3:
            gpu_pixel( WHITE, 320, 480 - perspectivey[ steps ] );
            break;

        default:
            gpu_circle( WHITE, 320, 480 - perspectivey[ steps ], pillsize, 1 );
            gpu_circle( GREY2, 320, 480 - perspectivey[ steps ], pillsize, 0 );
            break;
    }
}


// CREATE A BLANK MAZE OF WIDTH x HEIGHT
// ADD ENTRANCE AND EXIT AND GHOSTS
void initialise_maze( unsigned short width, unsigned short height )
{
    unsigned short x,y;

    // FILL WITH WALLS
    for( x = 0; x < width; x++ ) {
        for( y = 0; y < height; y++ ) {
            setat( x, y, '#', 0 );
            setat( x, y, '#', 1 );
        }
    }

    // POSITION GHOSTS AT CENTRE
    unsigned short potentialx, potentialy;

    for( unsigned short ghost = 0; ghost < 4; ghost++ ) {
     // POSITION GHOSTS AT CENTRE - with slight offset
        potentialx = width / 2; potentialy= height / 2;
        switch( rng( 2 ) ) {
            case 0:
                potentialx -= 2 * rng( level );
                break;
            case 1:
                potentialx += 2 * rng( level );
                break;
        }
        if( whatisat( potentialx, potentialy, 0 ) != ' ' )
            potentialx--;
        if( ghost <= level ) {
            // AT CENTRE
            ghostx[ ghost ] = potentialx;
            ghosty[ ghost ] = potentialy;
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
                switch( whatisat( x, y, 0 ) ) {
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
            if( colour != BLUE )
                gpu_rectangle( colour, x * boxwidth, y * boxheight, x * boxwidth + boxwidth - 1, y * boxheight + boxheight - 1 );
        }
    }
}

// ADAPTED FROM https://weblog.jamisbuck.org/2011/2/3/maze-generation-sidewinder-algorithm.html#
// GENERATE A MAZE OF WIDTH x HEIGHT - DRAW DURING GENERATION
void generate_maze( unsigned short width, unsigned short height ) {
    unsigned short x, y;
    unsigned short lastx, count;

    for( y = 1; y < height - 1; y += 2 ) {
        lastx = 1;
        count = 1;

        for( x = 1; x < width - 1; x += 2 ) {
            setat( x, y, ' ', 0 );
            if( y > 1 ) {
                // NOT ON FIRST ROW
                if( x != width - 3 ) {
                    // NOT AT END OF ROW, EITHER MOVE RIGHT, OR STOP AND CONNECT CELLS UP
                    switch( rng( 3 ) ) {
                        case 0:
                        case 1:
                            // CONTINUE RIGHT
                            setat( x + 1, y, ' ', 0 );
                            count++;
                            break;
                        case 2:
                            // STOP AND CONNECT CELLS UP
                            if( count == 1 ) {
                                setat( x, y - 1, ' ', 0 );
                            } else {
                                for( unsigned short connectors = 0; connectors < ( count >> 2 ) + 1; connectors++ ) {
                                    setat( lastx + rng( count ) * 2, y - 1, ' ', 0 );
                                }
                            }
                            lastx = x + 2;
                            count = 0;
                            break;
                    }
                } else {
                    // AT END OF ROW, STOP AND CONNECT CELLS UP
                    if( count == 1 ) {
                        setat( x, y - 1, ' ', 0 );
                    } else {
                        for( unsigned short connectors = 0; connectors < ( count >> 2 ) + 1; connectors++ ) {
                            setat( lastx + rng( count ) * 2, y - 1, ' ', 0 );
                        }
                    }
                }
            } else {
                // FIRST ROW, CONNECT
                if( x != width - 3 ) {
                    setat( x + 1, y, ' ', 0 );
                }
            }
        }
    }
}

// DRAW THE MAP IN RIGHT CORNER WITH COMPASS
void draw_map( unsigned short width, unsigned short height, unsigned short currentx, unsigned short currenty, unsigned short direction, unsigned char mapmaze, unsigned short mappeeks )
{
    unsigned short x, y;
    unsigned char colour;

    unsigned short boxwidth = 160 / width;
    unsigned short boxheight = 120 / height;

    // DRAW MAP BACKGROUND - PARCHMENT
    gpu_rectangle( ORANGE, 460, 0, 640, 140 );
    gpu_rectangle( BLUE, 475, 10, 639 - boxwidth, 130 );

    for( x = 0; x < width; x++ ) {
        for( y = 0; y < height; y++ ) {
            switch( mapmaze ? whatisat( x, y, 1) : whatisat( x, y, 0 ) ) {
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
            if( colour != BLUE )
                gpu_rectangle( colour, 475 + x * boxwidth, 10 + y * boxheight, 474 + x * boxwidth + boxwidth, 9 + y * boxheight + boxheight );
        }
    }

    gpu_rectangle( GREEN, 475 + currentx * boxwidth, 10 + currenty * boxheight, 474 + currentx * boxwidth + boxwidth, 9 + currenty * boxheight + boxheight );
    for( unsigned short ghost = 0; ghost < 4; ghost++ ) {
        if( ghost <= level ) {
            gpu_rectangle( ghostcolour( ghost ), 475 + ghostx[ ghost ] * boxwidth, 10 + ghosty[ ghost ] * boxheight, 474 + ghostx[ ghost ] * boxwidth + boxwidth, 9 + ghosty[ ghost ] * boxheight + boxheight );
        }
    }

    // DRAW COMPASS
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

    // DRAW MAPPEEKS
    for( unsigned peek = 0; peek < mappeeks; peek++ )
        gpu_character_blit( GREEN, 462, 130 - ( peek * 8 ), 1, 0 );
}

// CALCULATE NUMBER OF STEPS TO HIT A WALL
unsigned short counttowall( unsigned short currentx, unsigned short currenty, unsigned short direction )
{
    unsigned short steps = 0, foundwall = 0;

    while( foundwall == 0 ) {
        switch( whatisfront( currentx, currenty, direction, steps ) ) {
            case '#':
            case 'E':
            case 'X':
                foundwall = 1;
                break;
            default:
                steps++;
                break;
        }
    }

    return( steps );
}

// DRAW LEFT or RIGHT WALLS
void left_wall( unsigned char colour, unsigned char colour_alt, short steps )
{
    gpu_dither( DITHERON, colour_alt);
    // USE RECTANGLE + TWO TRIANGLES AS FASTER THAN TWO TRIANGLES FOR LARGE AREAS
    gpu_triangle( colour, perspectivex[ steps ], perspectivey[ steps ], perspectivex[ steps + 1 ], perspectivey[ steps + 1 ], perspectivex[ steps ], perspectivey[ steps + 1 ] );
    gpu_rectangle( colour, perspectivex[ steps ], perspectivey[ steps + 1 ], perspectivex[ steps + 1 ], 480 - perspectivey[ steps + 1 ] );
    gpu_triangle( colour, perspectivex[ steps + 1 ], 480 - perspectivey[ steps + 1 ], perspectivex[ steps ], 480 - perspectivey[ steps ], perspectivex[ steps ], 480 - perspectivey[ steps + 1 ] );
    gpu_dither( DITHEROFF );
    gpu_line( colour, perspectivex[ steps ], perspectivey[ steps ], perspectivex[ steps + 1 ], perspectivey[ steps + 1 ] );
    gpu_line( colour, perspectivex[ steps + 1 ], perspectivey[ steps + 1 ], perspectivex[ steps + 1 ], 480 - perspectivey[ steps + 1 ] );
    gpu_line( colour, perspectivex[ steps + 1 ], 480 - perspectivey[ steps + 1 ], perspectivex[ steps ], 480 - perspectivey[ steps ] );
    gpu_line( colour, perspectivex[ steps ], 480 - perspectivey[ steps ], perspectivex[ steps ], perspectivey[ steps ] );
}
void right_wall( unsigned char colour, unsigned char colour_alt, unsigned short steps )
{
    gpu_dither( DITHERON, colour_alt);
    // USE RECTANGLE + TWO TRIANGLES AS FASTER THAN TWO TRIANGLES FOR LARGE AREAS
    gpu_triangle( colour, 640 - perspectivex[ steps ], perspectivey[ steps ], 640 - perspectivex[ steps ], perspectivey[ steps + 1 ], 640 - perspectivex[ steps + 1 ], perspectivey[ steps + 1 ] );
    gpu_rectangle( colour, 640 - perspectivex[ steps ], perspectivey[ steps + 1 ], 640 - perspectivex[ steps + 1 ], 480 - perspectivey[ steps + 1 ] );
    gpu_triangle( colour, 640 - perspectivex[ steps ], 480 - perspectivey[ steps + 1 ], 640 - perspectivex[ steps  ], 480 - perspectivey[ steps ], 640 - perspectivex[ steps + 1 ], 480 - perspectivey[ steps + 1 ]);
    gpu_dither( DITHEROFF );
    gpu_line( colour, 640 - perspectivex[ steps ], perspectivey[ steps ], 640 - perspectivex[ steps  ], 480 - perspectivey[ steps ] );
    gpu_line( colour, 640 - perspectivex[ steps  ], 480 - perspectivey[ steps ], 640 - perspectivex[ steps + 1 ], 480 - perspectivey[ steps + 1 ] );
    gpu_line( colour, 640 - perspectivex[ steps + 1 ], 480 - perspectivey[ steps + 1 ], 640 - perspectivex[ steps + 1 ], perspectivey[ steps + 1 ] );
    gpu_line( colour, 640 - perspectivex[ steps + 1 ], perspectivey[ steps + 1 ], 640 - perspectivex[ steps ], perspectivey[ steps ] );
}

void drawleft( unsigned short steps, unsigned char totheleft ) {
    // DRAW SIDE WALLS
    switch( totheleft ) {
        case 'X':
            left_wall( YELLOW, DKYELLOW, steps );
            break;
        case ' ':
            // GAP
            gpu_rectangle( GREY2, perspectivex[ steps ], perspectivey[ steps + 1 ], perspectivex[ steps + 1 ], 480 - perspectivey[ steps + 1 ] );
            gpu_line( GREY1, perspectivex[ steps + 1 ], perspectivey[ steps + 1 ], perspectivex[ steps + 1 ], 480- perspectivey[ steps + 1 ] );
            break;
        case 'E':
            left_wall( MAGENTA, DKMAGENTA, steps );
            break;
        case '#':
            left_wall( GREY1, GREY2, steps );
            break;
        default:
            break;
    }
}

void drawright( unsigned short steps, unsigned char totheright ) {
    // DRAW SIDE WALLS
    switch( totheright ) {
        case 'X':
            right_wall( YELLOW, DKYELLOW, steps );
            break;
        case ' ':
            // GAP
            gpu_rectangle( GREY2, 640 - perspectivex[ steps + 1 ], perspectivey[ steps + 1 ], 640 - perspectivex[ steps ], 480 - perspectivey[ steps + 1 ] );
            gpu_line( GREY1, 640 - perspectivex[ steps + 1 ], perspectivey[ steps + 1 ], 640 - perspectivex[ steps + 1 ],  480 - perspectivey[ steps + 1 ] );
            break;
        case 'E':
            right_wall( MAGENTA, DKMAGENTA, steps );
            break;
        case '#':
            right_wall( GREY1, GREY2, steps );
            break;
        default:
            break;
    }
}

// WALK THE MAZE IN 3D
unsigned short walk_maze( unsigned short width, unsigned short height )
{
    // SET START LOCATION TO TOP LEFT FACING EAST
    unsigned short newx = 1, newy = 1, direction = 1, newdirection = 1, currentx = 1, currenty = 1, visiblesteps, mappeeks = 4, dead = 0;
    short steps;
    unsigned char ghostdrawn;

    // LOOP UNTIL REACHED THE EXIT OR DEAD
    while( ( ( currentx != width - 2 ) || ( currenty != height - 3 ) ) && ( dead == 0 ) ) {
        // SET CURRENT LOCATION TO VISITED
        setat( currentx, currenty, ' ', 1 );

        await_vblank();
        tpu_cs();
        gpu_cs();

        // FIND NUMBER OF STEPS FORWARD TO A WALL
        visiblesteps = counttowall( currentx, currenty, direction );
        if( visiblesteps <= MAXDEPTH - 1 ) {
            // WALL IS NOT AT HORIZON
            switch( whatisfront( currentx, currenty, direction, visiblesteps ) ) {
                case 'X':
                    gpu_rectangle( YELLOW, perspectivex[ visiblesteps ], perspectivey[ visiblesteps ], 640 - perspectivex[ visiblesteps ], 480 - perspectivey[ visiblesteps ] );
                    if( visiblesteps <= 4 ) {
                        gpu_outputstringcentre( DKGREEN, 320, perspectivey[ visiblesteps ] + ( 2 << ( 4 - visiblesteps ) ), "EXIT", 4 - visiblesteps );
                    }
                    break;
                case 'E':
                    gpu_rectangle( MAGENTA, perspectivex[ visiblesteps ], perspectivey[ visiblesteps ], 640 - perspectivex[ visiblesteps ], 480 - perspectivey[ visiblesteps ] );
                    break;
                case '#':
                    gpu_rectangle( GREY2, perspectivex[ visiblesteps ], perspectivey[ visiblesteps ], 640 - perspectivex[ visiblesteps ], 480 - perspectivey[ visiblesteps ] );
                    break;
                default:
                    break;
            }
        }

        // MOVE BACKWARDS FROM WALL
        for( steps = min( visiblesteps - 1, MAXDEPTH - 1 ); steps > 0; steps-- ) {
            // DRAW PILL
            if( ( whatisfront( currentx, currenty, direction, steps ) == ' ' ) && ( whatisat( currentx + directionx[ direction ] * steps, currenty + directiony[ direction ] * steps, 1 ) != ' ' ) ) {
                draw_pill( steps );
            }

            // DRAW SIDE WALLS
            drawleft( steps, whatisleft( currentx, currenty, direction, steps ) );
            drawright( steps, whatisright( currentx, currenty, direction, steps ) );
        }

        // DRAW GHOST IF ONE IS VISIBLE
        ghostdrawn = 0;
        for( steps = 1; ( steps <= min( visiblesteps - 1, MAXDEPTH - 1 ) ) && ( ghostdrawn == 0 ); steps++ ) {
            // DRAW GHOST
            for( unsigned ghost = 0; ghost < 4; ghost++ ) {
                if( ghost <= level ) {
                    if( ( currentx + directionx[ direction ] * steps == ghostx[ ghost ] ) && ( currenty + directiony[ direction ] * steps == ghosty[ ghost ] ) ) {
                        draw_ghost( steps, ghost, direction );
                        ghostdrawn = 1;
                    }
                }
            }
        }

        // FINISH UPTO CORNERS
        drawleft( 0, whatisleft( currentx, currenty, direction, 0 ) );
        drawright( 0, whatisright( currentx, currenty, direction, 0 ) );

        draw_map( width, height, currentx, currenty, direction, 1, mappeeks );

        // SET 2 second timeout
        set_timer1khz( 2000, 0 );

        // WAIT FOR INPUT TO MOVE  OR TIMEOUT
        while( ( currentx == newx ) && ( currenty == newy ) && ( direction == newdirection ) && get_timer1khz( 0 ) ) {
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
                switch( whatisfront( currentx, currenty, direction, 1 ) ) {
                    case ' ':
                    case 'X':
                        newx += directionx[direction];
                        newy += directiony[direction];
                        break;
                }
                while( get_buttons() & 8 );
            }

            // BACKWARD
            if( get_buttons() & 16 ) {
                switch( whatisbehind( currentx, currenty, direction, 1 ) ) {
                    case ' ':
                    case 'X':
                        newx -= directionx[direction];
                        newy -= directiony[direction];
                        break;
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
                if( ( ghostx[ ghost ] == currentx ) && ( ghosty[ ghost ] == currenty ) )
                    dead = 1;
                move_ghost( ghost );
                if( ( ghostx[ ghost ] == currentx ) && ( ghosty[ ghost ] == currenty ) )
                    dead = 1;
            }
        }
    }

    return dead;
}

int main( void ) {
    unsigned short firstrun = 1;

    INITIALISEMEMORY();
    set_background( 0, 0, BKG_RAINBOW );

    // DECODE TOMBSTONE PPM TO BITMAP
    tombstonebitmap = memoryspace( 320 * 298 );
    netppm_decoder( &tombstoneppm[0], tombstonebitmap );

    // DECODE CONTROLS PPM TO BITMAP
    ulx3sbitmap = memoryspace( 320 * 219 );
    netppm_decoder( &ulx3sppm[0], ulx3sbitmap );

    unsigned short levelselected;
    level = 0;

	while(1) {
        // SETUP THE SCREEN BLUE/GREEN BACKGROUND
        gpu_cs();
        tpu_cs();
        terminal_showhide( 0 );
        set_background( 0, 0, BKG_RAINBOW );

        if( firstrun ) {
            drawwelcome();
            firstrun = 0;
        }

        levelselected = 0;
        do {
            tpu_outputstringcentre( 26, TRANSPARENT, YELLOW, "Select Level" );
            tpu_outputstringcentre( 27, TRANSPARENT, YELLOW, "Increase/Decrease by LEFT/RIGHT - Select by FIRE" );
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

        tpu_outputstringcentre( 26, TRANSPARENT, YELLOW, "" );
        tpu_outputstringcentre( 27, TRANSPARENT, YELLOW, "" );

        // GENERATE THE MAZE
        gpu_cs();
        tpu_outputstringcentre( 29, TRANSPARENT, YELLOW, "Generating Maze" );
        initialise_maze( levelwidths[level], levelheights[level] );
        generate_maze( levelwidths[level], levelheights[level] );
        display_maze( levelwidths[level], levelheights[level], 1, 1 );

        // WAIT TO ENTER THE MAZE
        tpu_outputstringcentre( 29, TRANSPARENT, GREEN, "Press FIRE to walk the maze!" ); while( ( get_buttons() & 2 ) == 0 );
        tpu_outputstringcentre( 29, TRANSPARENT, PURPLE, "Release FIRE!" ); while( get_buttons() & 2 );

        // ENTER THE MAZE IN 3D
        set_background( DKBLUE, DKGREEN, BKG_5050_V );
        if( walk_maze( levelwidths[level], levelheights[level] ) ) {
            // DISPLAY TOMBSTONE BITMAP AND RESET TO BEGINNING
            gpu_cs();
            bitmapblit( tombstonebitmap, 320, 298, 160, 91, WHITE );
            level = 0;
            firstrun = 1;
        } else {
            // COMPLETED THE MAZE
            set_background( 0, 0, BKG_STATIC );

            // GO TO THE NEXT LEVEL
            level = ( level < MAXLEVEL ) ? level + 1 : MAXLEVEL;
        }

        tpu_outputstringcentre( 29, TRANSPARENT, GREEN, "Press FIRE to restart!" ); while( ( get_buttons() & 2 ) == 0 );
        tpu_outputstringcentre( 29, TRANSPARENT, PURPLE, "Release FIRE!" ); while( get_buttons() & 2  );
    }
}
