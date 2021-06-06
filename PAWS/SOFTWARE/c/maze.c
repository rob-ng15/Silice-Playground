#include "PAWSlibrary.h"
#include <stdlib.h>
#define min(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a < _b ? _a : _b; })

// INCLUDE TOMBSTONE IMAGE
#include "TOMBSTONE_BMP.h"

// INCLUDE CONTROLS IMAGE
#include "ULX3S_BMP.h"

// INCLUDE 3D PACMAN BACKDROP
#include "3DPACMAN_BMP.h"

// MAZE SIZES
#define MAXWIDTH 80
#define MAXHEIGHT 60
#define MAXLEVEL 6

// DRAWING VARIABLES
#define MAXDEPTH 12

// CURRENT FRAMEBUFFER
unsigned char framebuffer = 0;

// LEVEL - DETERMINES SIZE OF MAZE
unsigned short level = 0;

// POWER STATUS
unsigned short powerstatus = 0, powerpills = 0;

// WIDTH OF MAZE DEPENDING ON LEVEL
unsigned short levelwidths[] = {  10, 16, 16, 20, 20, 40, 40 };
unsigned short levelheights[] = { 10, 10, 12, 12, 20, 20, 30 };

// TOP LEFT COORDINATES FOR THE PERSPECTIVE DRAWING
short perspectivex[] = { 0, 50, 85, 109, 125, 136, 144, 149, 152, 155, 157, 159, 160 };
short perspectivey[] = { 0, 37, 64,  82,  94, 102, 108, 112, 114, 116, 118, 119, 120 };

// DIRECTION STEPS IN X and Y
short directionx[] = { 0, 1, 0, -1 }, leftdirectionx[] = { -1, 0, 1, 0 }, rightdirectionx[] = { 1, 0, -1, 0 };
short directiony[] = { -1, 0, 1, 0 }, leftdirectiony[] = { 0, -1, 0, 1 }, rightdirectiony[] = { 0, 1, 0, -1 };

// STORAGE FOR MAZE and MAP PLUS ACCESS FUNCTIONS USING A BIT ARRAY
// WALLS WILL BE '#' '*' GAPS ' ' ENTRANCE 'E' EXIT 'X'
unsigned int maze[ MAXWIDTH >> 5 ][MAXHEIGHT];
unsigned int map[ MAXWIDTH >> 5 ][MAXHEIGHT];

// POSITION AND DIRECTION OF THE GOST
unsigned short ghostx[4], ghosty[4], ghostdirection[4];
unsigned short ghosteyes[4][4] = { { 0, 1, 2, 3 }, { 3, 0, 1, 2 }, { 2, 3, 0, 1 }, { 1, 2, 3, 0 } };

// DRAW WELCOME SCREEN
void drawwelcome( void ) {
    // DISPLAY ULX3 BITMAP
    gpu_pixelblock7( 0, 10, 320, 219, BLUE, ulx3sbitmap );
    gpu_printf_centre( YELLOW, 160, 8, 1, "3D MONSTER MAZE" );

    // DRAW JOYSTICK AND LABEL
    gpu_printf_centre( YELLOW, 229, 102, 0, "STEP" );
    gpu_printf_centre( YELLOW, 242, 123, 0, "BACK" );
    gpu_printf_centre( YELLOW, 211, 135, 0, "LEFT" );
    gpu_printf_centre( YELLOW, 272, 109, 0, "RIGHT" );
    gpu_printf_centre( YELLOW, 98, 128, 0, "PEEK" );
    gpu_printf_centre( YELLOW, 66, 142, 0, "POWER" );
}

// RETURN CONTENTS OF == 0 MAZE == 1 MAP at ( X, Y )
unsigned char whatisat( unsigned short x, unsigned short y, unsigned char mapmaze ) {
    if( ( x == 0 ) && ( y == 1 ) ) {
        return( 'E' );
    }
    if( ( ( x == levelwidths[ level ] - 2 ) && ( y == levelheights[ level ] - 3 ) ) ) {
        return( 'X' );
    }
    if( ( x < MAXWIDTH ) && ( y < MAXHEIGHT ) ) {
        switch( mapmaze ) {
            case 0:
                return( ( maze[ x >> 5 ][ y ] >> ( x & 0x1f ) ) & 1 ? '#' : ' ' );
            case 1:
                return( ( map[ x >> 5 ][ y ] >> ( x & 0x1f ) ) & 1 ? '#' : ' ' );
            default:
                return( '?' );
        }
    } else {
        return( '#' );
    }
}

// SET THE CONTENTS OF == 0 MAZE == 1 MAP at ( X, Y )
void setat( unsigned short x, unsigned short y, unsigned char value, unsigned char mapmaze ) {
    switch( mapmaze ) {
        case 0:
            switch( value ) {
                case ' ':
                    maze[ x >> 5 ][ y ] &= ~( 1 << ( x & 0x1f ) );
                    break;
                case '#':
                    maze[ x >> 5 ][ y ] |= ( 1 << ( x & 0x1f ) );
                    break;
            }
            break;
        case 1:
            switch( value ) {
                case ' ':
                    map[ x >> 5 ][ y ] &= ~( 1 << ( x & 0x1f ) );
                    break;
                case '#':
                    map[ x >> 5 ][ y ] |= ( 1 << ( x & 0x1f ) );
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
    unsigned short sizechange = ( 160 - perspectivex[ steps ] ) * 3 / 8;

    unsigned short centrex = 160;
    unsigned short centrey = 120;
    unsigned short offsetx = ( sizechange * 2 ) / 6;
    unsigned short eyeoffsetx = ( sizechange + offsetx ) / 2;
    unsigned short eyeoffsety = sizechange / 2;
    unsigned char colour = powerstatus ? DKPURPLE : ghostcolour( ghostnumber );

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
    if( !powerstatus ) {
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
    unsigned short pillsize = ( 160 - perspectivex[ steps ] ) / 8;

    switch( pillsize ) {
        case 0:
            break;

        case 1:
        case 2:
        case 3:
            gpu_pixel( WHITE, 160, 240 - perspectivey[ steps ] );
            break;

        default:
            gpu_circle( WHITE, 160, 240 - perspectivey[ steps ], pillsize, 1 );
            gpu_circle( GREY2, 160, 240 - perspectivey[ steps ], pillsize, 0 );
            break;
    }
}

// ADAPTED FROM https://weblog.jamisbuck.org/2011/2/3/maze-generation-sidewinder-algorithm.html#
// GENERATE A MAZE OF WIDTH x HEIGHT - DRAW DURING GENERATION
void generate_maze( unsigned short width, unsigned short height ) {
    unsigned short x, y;
    unsigned short lastx, count;

    // FILL WITH WALLS
    for( x = 0; x < width; x++ ) {
        for( y = 0; y < height; y++ ) {
            setat( x, y, '#', 0 );
            setat( x, y, '#', 1 );
        }
    }

    // WORK DOWN LINE BY LINE
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

    // POSITION 2,3,4 GHOSTS AT CENTRE 1 AT EXIT
    unsigned short potentialx, potentialy;

    for( unsigned short ghost = 0; ghost < 4; ghost++ ) {
     // POSITION GHOSTS AT CENTRE - with slight offset
        potentialx = width / 2; potentialy= height / 2;
        if( ghost == 0 ) {
           ghostx[ ghost ] = width - 3;
           ghosty[ ghost ] = height - 3;
           ghostdirection[ ghost ] = 3;
        } else {
            switch( rng( 2 ) ) {
                case 0:
                    potentialx -= 2 * rng( level );
                    potentialy += rng( level );
                    break;
                case 1:
                    potentialx += 2 * rng( level );
                    potentialy -= rng( level );
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
}

// DRAW THE MAP IN RIGHT CORNER WITH COMPASS
void draw_map( unsigned short width, unsigned short height, unsigned short currentx, unsigned short currenty, unsigned short direction, unsigned char mapmaze, unsigned short mappeeks )
{
    short x, y, dox, doy;
    unsigned char colour;

    unsigned short boxwidth = 80 / width;
    unsigned short boxheight = 60 / height;

    // DRAW MAP BACKGROUND - PARCHMENT
    gpu_rectangle( ORANGE, 225, 0, 319, 63 );
    gpu_rectangle( BLUE, 237, 2, 317, 61 );

    switch( mapmaze ) {
        case 0:
            // DRAW WHOLE MAP
            for( x = 0; x < width; x++ ) {
                for( y = 0; y < height; y++ ) {
                    switch( whatisat( x, y, 0 ) ) {
                        case ' ':
                            colour = WHITE;
                            break;
                        case 'E':
                            colour = MAGENTA;
                            break;
                        case 'X':
                            colour = YELLOW;
                            break;
                        default:
                            colour = BLUE;
                            break;
                    }
                    if( colour != BLUE )
                        switch( boxwidth ) {
                            case 1:
                                gpu_pixel( colour, 237 + x, 2 + y );
                                break;
                            default:
                                gpu_rectangle( colour, 237 + x * boxwidth, 2 + y * boxheight, 236 + x * boxwidth + boxwidth, 1 + y * boxheight + boxheight );
                        }
                }
            }
            // DRAW CURRENT LOCATION AND GHOSTS
            gpu_rectangle( GREEN, 237 + currentx * boxwidth, 2 + currenty * boxheight, 236 + currentx * boxwidth + boxwidth, 1 + currenty * boxheight + boxheight );
            for( unsigned short ghost = 0; ghost < 4; ghost++ ) {
                if( ghost <= level ) {
                    gpu_rectangle( ( powerstatus ? DKPURPLE : ghostcolour( ghost ) ), 237 + ghostx[ ghost ] * boxwidth, 2 + ghosty[ ghost ] * boxheight, 236 + ghostx[ ghost ] * boxwidth + boxwidth, 1 + ghosty[ ghost ] * boxheight + boxheight );
                }
            }
            break;

        case 1:
            // DRAW LOCAL MAP
            for( x = 0; x < 15; x++ ) {
                for( y = 0; y < 12; y++ ) {
                    if( ( currentx - 8 ) < 0 ) {
                        dox = x;
                    } else {
                        dox = currentx - 8 + x;
                    }
                    if( ( currenty - 5 ) < 0 ) {
                        doy = y;
                    } else {
                        doy = currenty - 5 + y;
                    }

                    if( ( dox >=0 ) && ( dox < width ) && ( doy >= 0 ) && ( doy < height ) ) {
                        switch( whatisat( dox, doy, 1 ) ) {
                            case ' ':
                                colour = WHITE;
                                break;
                            case 'E':
                                colour = MAGENTA;
                                break;
                            case 'X':
                                colour = YELLOW;
                                break;
                            default:
                                colour = BLUE;
                                break;
                        }
                        gpu_rectangle( colour, 237 + x * 5, 2 + y * 5, 241 + x * 5, 6 + y * 5 );

                        // DRAW CURRENT LOCATION AND GHOSTS
                        if( ( dox == currentx ) && ( doy == currenty ) )
                            gpu_rectangle( GREEN, 237 + x * 5, 2 + y * 5, 241 + x * 5, 6 + y * 5 );

                        for( unsigned short ghost = 0; ghost < 4; ghost++ ) {
                            if( ( ghost <= level ) && ( ghostx[ ghost ] == dox ) && ( ghosty[ ghost ] == doy ) ) {
                                gpu_rectangle( ( powerstatus ? DKPURPLE : ghostcolour( ghost ) ), 237 + x * 5, 2 + y * 5, 241 + x * 5, 6 + y * 5 );
                            }
                        }
                    }
                }
            }
            break;
    }


    // DRAW COMPASS
    switch( direction ) {
        case 0:
            gpu_character_blit( GREEN, 226, 1, 30, 0 );
            break;
        case 1:
            gpu_character_blit( GREEN, 226, 1, 16, 0 );
            break;
        case 2:
            gpu_character_blit( GREEN, 226, 1, 31, 0 );
            break;
        case 3:
            gpu_character_blit( GREEN, 226, 1, 17, 0 );
            break;
    }

    // DRAW MAPPEEKS
    for( unsigned peek = 0; peek < mappeeks; peek++ )
        gpu_character_blit( GREEN, 226, 53 - ( peek * 6 ), 1, 0 );

    // DRAW POWER PILLS
    for( unsigned power = 0; power < powerpills; power++ )
        gpu_character_blit( DKPURPLE, 226, 29 - ( power * 6 ), 4, 0 );
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
    switch( colour ) {
        case YELLOW:
            gpu_dither( DITHERLSLOPE, colour_alt);
            break;
        case MAGENTA:
            gpu_dither( DITHERLSLOPE, colour_alt);
            break;
        default:
            gpu_dither( DITHERCHECK1, colour_alt);
            break;
    }
    // USE RECTANGLE + TWO TRIANGLES AS FASTER THAN TWO TRIANGLES FOR LARGE AREAS
    gpu_triangle( colour, perspectivex[ steps ], perspectivey[ steps ], perspectivex[ steps + 1 ], perspectivey[ steps + 1 ], perspectivex[ steps ], perspectivey[ steps + 1 ] );
    gpu_rectangle( colour, perspectivex[ steps ], perspectivey[ steps + 1 ], perspectivex[ steps + 1 ], 240 - perspectivey[ steps + 1 ] );
    gpu_triangle( colour, perspectivex[ steps + 1 ], 240 - perspectivey[ steps + 1 ], perspectivex[ steps ], 240 - perspectivey[ steps ], perspectivex[ steps ], 240 - perspectivey[ steps + 1 ] );
    gpu_dither( DITHEROFF );
    gpu_line( colour, perspectivex[ steps ], perspectivey[ steps ], perspectivex[ steps + 1 ], perspectivey[ steps + 1 ] );
    //gpu_line( colour, perspectivex[ steps + 1 ], perspectivey[ steps + 1 ], perspectivex[ steps + 1 ], 240 - perspectivey[ steps + 1 ] );
    gpu_line( colour, perspectivex[ steps + 1 ], 240 - perspectivey[ steps + 1 ], perspectivex[ steps ], 240 - perspectivey[ steps ] );
    //gpu_line( colour, perspectivex[ steps ], 240 - perspectivey[ steps ], perspectivex[ steps ], perspectivey[ steps ] );
}
void right_wall( unsigned char colour, unsigned char colour_alt, unsigned short steps )
{
    switch( colour ) {
        case YELLOW:
            gpu_dither( DITHERRSLOPE, colour_alt);
            break;
        case MAGENTA:
            gpu_dither( DITHERRSLOPE, colour_alt);
            break;
        default:
            gpu_dither( DITHERCHECK1, colour_alt);
            break;
    }
    // USE RECTANGLE + TWO TRIANGLES AS FASTER THAN TWO TRIANGLES FOR LARGE AREAS
    gpu_triangle( colour, 320 - perspectivex[ steps ], perspectivey[ steps ], 320 - perspectivex[ steps ], perspectivey[ steps + 1 ], 320 - perspectivex[ steps + 1 ], perspectivey[ steps + 1 ] );
    gpu_rectangle( colour, 320 - perspectivex[ steps ], perspectivey[ steps + 1 ], 320 - perspectivex[ steps + 1 ], 240 - perspectivey[ steps + 1 ] );
    gpu_triangle( colour, 320 - perspectivex[ steps ], 240 - perspectivey[ steps + 1 ], 320 - perspectivex[ steps  ], 240 - perspectivey[ steps ], 320 - perspectivex[ steps + 1 ], 240 - perspectivey[ steps + 1 ]);
    gpu_dither( DITHEROFF );
    //gpu_line( colour, 320 - perspectivex[ steps ], perspectivey[ steps ], 320 - perspectivex[ steps  ], 240 - perspectivey[ steps ] );
    gpu_line( colour, 320 - perspectivex[ steps  ], 240 - perspectivey[ steps ], 320 - perspectivex[ steps + 1 ], 240 - perspectivey[ steps + 1 ] );
    //gpu_line( colour, 320 - perspectivex[ steps + 1 ], 240 - perspectivey[ steps + 1 ], 320 - perspectivex[ steps + 1 ], perspectivey[ steps + 1 ] );
    gpu_line( colour, 320 - perspectivex[ steps + 1 ], perspectivey[ steps + 1 ], 320 - perspectivex[ steps ], perspectivey[ steps ] );
}

void drawleft( unsigned short steps, unsigned char totheleft ) {
    // DRAW SIDE WALLS
    switch( totheleft ) {
        case 'X':
            left_wall( YELLOW, DKYELLOW, steps );
            break;
        case ' ':
            // GAP
            gpu_rectangle( GREY2, perspectivex[ steps ], perspectivey[ steps + 1 ], perspectivex[ steps + 1 ], 240 - perspectivey[ steps + 1 ] );
            gpu_line( GREY1, perspectivex[ steps + 1 ], perspectivey[ steps + 1 ], perspectivex[ steps + 1 ], 240- perspectivey[ steps + 1 ] );
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
            gpu_rectangle( GREY2, 320 - perspectivex[ steps + 1 ], perspectivey[ steps + 1 ], 320 - perspectivex[ steps ], 240 - perspectivey[ steps + 1 ] );
            gpu_line( GREY1, 320 - perspectivex[ steps + 1 ], perspectivey[ steps + 1 ], 320 - perspectivex[ steps + 1 ],  240 - perspectivey[ steps + 1 ] );
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
    unsigned short newx = 1, newy = 1, direction = 1, newdirection = 1, currentx = 1, currenty = 1, visiblesteps, mappeeks = 4, peekactive = 100, dead = 0;
    short steps;
    unsigned char ghostdrawn;

    // SET move timers - timer 0 100th second for player, timer 1 1 second for ghosts
    set_timer1khz( 100, 0 ); set_timer1khz( 1000, 0 );

    tpu_cs();
    // LOOP UNTIL REACHED THE EXIT OR DEAD
    while( ( ( currentx != width - 2 ) || ( currenty != height - 3 ) ) && ( dead == 0 ) ) {
        // SET CURRENT LOCATION TO VISITED
        setat( currentx, currenty, ' ', 1 );

        // SWITCH TO ALTERNATE FRAMEBUFFER FOR DRAWING
        bitmap_draw( 1 - framebuffer );
        gpu_cs();

        // FIND NUMBER OF STEPS FORWARD TO A WALL
        visiblesteps = counttowall( currentx, currenty, direction );
        if( visiblesteps <= MAXDEPTH - 1 ) {
            // WALL IS NOT AT HORIZON
            switch( whatisfront( currentx, currenty, direction, visiblesteps ) ) {
                case 'X':
                    gpu_rectangle( YELLOW, perspectivex[ visiblesteps ], perspectivey[ visiblesteps ], 320 - perspectivex[ visiblesteps ], 240 - perspectivey[ visiblesteps ] );
                    if( visiblesteps <= 4 ) {
                        gpu_printf_centre( DKGREEN, 160, perspectivey[ visiblesteps ] + ( 2 << ( 4 - visiblesteps ) ), 4 - visiblesteps, "EXIT" );
                    }
                    break;
                case 'E':
                    gpu_rectangle( MAGENTA, perspectivex[ visiblesteps ], perspectivey[ visiblesteps ], 320 - perspectivex[ visiblesteps ], 240 - perspectivey[ visiblesteps ] );
                    break;
                case '#':
                    gpu_rectangle( GREY2, perspectivex[ visiblesteps ], perspectivey[ visiblesteps ], 320 - perspectivex[ visiblesteps ], 240 - perspectivey[ visiblesteps ] );
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

        draw_map( width, height, currentx, currenty, direction, peekactive ? 0 : 1, mappeeks );

        // SWITCH THE FRAMEBUFFER
        framebuffer = 1 - framebuffer;
        bitmap_display( framebuffer );

        // CHECK IF PLAYER MOVE ALLOWED
        if( get_timer1khz( 0 ) == 0 ) {
            // POWER UP
            if( ( get_buttons() & 2 ) && ( powerpills > 0 ) ) {
                powerstatus += 200;
                powerpills--;
            }

            // LEFT
            if( get_buttons() & 32 ) {
                newdirection = ( newdirection == 0 ) ? 3 : newdirection - 1;
            }

            // RIGHT
            if( get_buttons() & 64 ) {
                newdirection = ( newdirection == 3 ) ? 0 : newdirection + 1;
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
            }

            // FIRE2 - PEEK ( only 4 goes! )
            if( ( get_buttons() & 4 ) && ( mappeeks != 0 ) ) {
                peekactive = peekactive + 200;
                mappeeks--;
            }

            set_timer1khz( 100, 0 );
        }

        currentx = newx; currenty = newy; direction = newdirection;
        if( powerstatus == 0 ) {
            for( unsigned short ghost = 0; ghost < 4; ghost++ ) {
                if( ghost <= level ) {
                    if( ( ghostx[ ghost ] == currentx ) && ( ghosty[ ghost ] == currenty ) )
                        dead = 1;
                    if( get_timer1khz( 1 ) == 0 ) {
                        move_ghost( ghost );
                        if( ( ghostx[ ghost ] == currentx ) && ( ghosty[ ghost ] == currenty ) )
                            dead = 1;
                    }
                }
            }
            if( get_timer1khz( 1 ) == 0 )
                set_timer1khz( 1000, 1 );
        }

        powerstatus = ( powerstatus > 0 ) ? powerstatus - 1 : 0;
        peekactive = ( peekactive > 0 ) ? peekactive - 1 : 0;
    }

    return dead;
}

int main( void ) {
    unsigned short firstrun = 1;

    INITIALISEMEMORY();
    set_background( 0, 0, BKG_RAINBOW );

    unsigned short levelselected;

	while(1) {
        // SETUP THE SCREEN BLUE/GREEN BACKGROUND
        gpu_cs();
        tpu_cs();
        set_background( 0, 0, BKG_RAINBOW );

        if( firstrun ) {
            drawwelcome();
            firstrun = 0;
        } else {
            // DISPLAY 3D PACMAN BITMAP
            gpu_pixelblock7( 0, 0, 320, 240, BLACK, pacman3dbitmap );
        }

        // RESET POWER PILL STATUS
        powerstatus = 0;

        levelselected = 0;
        do {
            tpu_printf_centre( 26, TRANSPARENT, YELLOW, "Select Level" );
            tpu_printf_centre( 27, TRANSPARENT, YELLOW, "Increase/Decrease by LEFT/RIGHT - Select by FIRE" );
            tpu_set( 1, 29, TRANSPARENT, BLACK ); tpu_printf( "Level: %3d", level );
            tpu_set( 60, 29, TRANSPARENT, BLACK ); tpu_printf( "Size: %5d x %5d", levelwidths[level], levelheights[level] );

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

        tpu_printf_centre( 26, TRANSPARENT, YELLOW, "" );
        tpu_printf_centre( 27, TRANSPARENT, YELLOW, "" );

        // GENERATE THE MAZE
        generate_maze( levelwidths[level], levelheights[level] );

        // SET NUMBER OF POWER PILLS
        powerpills = ( level < 4 ) ? level + 1 : 4;

        // ENTER THE MAZE IN 3D
        set_background( DKBLUE, DKGREEN, BKG_5050_V );
        if( walk_maze( levelwidths[level], levelheights[level] ) ) {
            // DISPLAY TOMBSTONE BITMAP AND RESET TO BEGINNING
            gpu_cs();
            gpu_pixelblock7( 0, 0, 320, 298, WHITE, tombstonebitmap );
            level = 0;
            firstrun = 1;
        } else {
            // COMPLETED THE MAZE
            set_background( 0, 0, BKG_STATIC );

            // GO TO THE NEXT LEVEL
            level = ( level < MAXLEVEL ) ? level + 1 : MAXLEVEL;
        }

        tpu_printf_centre( 29, TRANSPARENT, GREEN, "Press FIRE to restart!" ); while( ( get_buttons() & 2 ) == 0 );
        tpu_printf_centre( 29, TRANSPARENT, PURPLE, "Release FIRE!" ); while( get_buttons() & 2  );
    }
}
