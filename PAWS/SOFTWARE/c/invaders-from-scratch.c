// PAWS implementation of http://nicktasios.nl/posts/space-invaders-from-scratch-part-1.html

#include "PAWSlibrary.h"
#include <stdio.h>

#define min(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a < _b ? _a : _b; })

#define max(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a > _b ? _a : _b; })

// GRAPHICS
// ALIENS ARE BLITTER OBJECTS, 2 DESIGNS PER ALIEN TYPE FOR ANIMATION, 2 FOR EXPLOSION, 2 FOR UFO, 2 FOR BUNKERS
unsigned short blitter_bitmaps[] = {
    0b0000011000000000,
    0b0000111110000000,
    0b0001111111000000,
    0b0011011011000000,
    0b0011111111000000,
    0b0001011010000000,
    0b0010000001000000,
    0b0001000010000000,
    0,0,0,0,0,0,0,0,

    0b0000011000000000,
    0b0000111110000000,
    0b0001111111000000,
    0b0011011011000000,
    0b0011111111000000,
    0b0000100100000000,
    0b0001011010000000,
    0b0010100101000000,
    0,0,0,0,0,0,0,0,

    0b0010000010000000,
    0b0001000100000000,
    0b0011111110000000,
    0b0110111011000000,
    0b1111111111100000,
    0b1011111110100000,
    0b1010000010100000,
    0b0001101100000000,
    0,0,0,0,0,0,0,0,

    0b0010000010000000,
    0b1001000100100000,
    0b1011111110100000,
    0b1110111011100000,
    0b1111111111100000,
    0b0111111111000000,
    0b0010000010000000,
    0b0100000001000000,
    0,0,0,0,0,0,0,0,

    0b0000111100000000,
    0b0111111111100000,
    0b1111111111110000,
    0b1110011001110000,
    0b1111111111110000,
    0b0011100111000000,
    0b0110011001100000,
    0b0011000011000000,
    0,0,0,0,0,0,0,0,

    0b0000111100000000,
    0b0111111111100000,
    0b1111111111110000,
    0b1110011001110000,
    0b1111111111110000,
    0b0001100110000000,
    0b0011011011000000,
    0b1100000000110000,
    0,0,0,0,0,0,0,0,

    0b0100100010010000,
    0b0010010100100000,
    0b0001000001000000,
    0b1100000000011000,
    0b0001000001000000,
    0b0010010100100000,
    0b0100100010010000,
    0,0,0,0,0,0,0,0,0,

    0b1000100010001000,
    0b0100100010010000,
    0b0010001000100000,
    0b0110011100110000,
    0b0010001000100000,
    0b0100100010010000,
    0b1000100010001000,
    0,0,0,0,0,0,0,0,0,

    0b0000011111000000,
    0b0001111111110000,
    0b0011111111111000,
    0b0110101010101100,
    0b1111111111111110,
    0b0011101110111000,
    0b0001000000010000,
    0,0,0,0,0,0,0,0,0,

    0b0000011111000000,
    0b0001111111110000,
    0b0011111111111000,
    0b0110111011101100,
    0b1111111111111110,
    0b0011101110111000,
    0b0001000000010000,
    0,0,0,0,0,0,0,0,0,

    0b0000011111111111,
    0b0000111111111111,
    0b0001111111111111,
    0b0011111111111111,
    0b0111111111111111,
    0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff,
    0b1111111111111100,
    0b1111111111110000,
    0b1111111111000000,
    0b1111111111000000,

    0b1111111111100000,
    0b1111111111110000,
    0b1111111111111000,
    0b1111111111111100,
    0b1111111111111110,
    0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff,
    0b0011111111111111,
    0b0000111111111111,
    0b0000001111111111,
    0b0000001111111111,

    0b1110101110000000,
    0b0111111100000000,
    0b0011111000000000,
    0b1111111110000000,
    0b0011111000000000,
    0b0111111100000000,
    0b1110101110000000,
    0,0,0,0,0,0,0,0,0
};

// PLAYER IS A SPRITE, 1 DESIGN FOR THE SHIP
unsigned short player_bitmaps[128] = {
    0b0000010000000000,
    0b0000111000000000,
    0b0000111000000000,
    0b0111111111000000,
    0b1111111111100000,
    0b1111111111100000,
    0b1111111111100000,
    0,0,0,0,0,0,0,0,0,
};

// BULLET IS A SPRITE, 8 FRAMES OF ANIMATION
unsigned short bullet_bitmaps[] = {
    0b0100000000000000, 0b0010000000000000, 0b0100000000000000, 0b1000000000000000, 0b0100000000000000, 0,0,0,0,0,0,0,0,0,0,0,
    0b0100000000000000, 0b0100000000000000, 0b0100000000000000, 0b0100000000000000, 0b0100000000000000, 0,0,0,0,0,0,0,0,0,0,0,
    0b0100000000000000, 0b1000000000000000, 0b0100000000000000, 0b0010000000000000, 0b0100000000000000, 0,0,0,0,0,0,0,0,0,0,0,
    0b0100000000000000, 0b0100000000000000, 0b0100000000000000, 0b0100000000000000, 0b0100000000000000, 0,0,0,0,0,0,0,0,0,0,0,
    0b0100000000000000, 0b0010000000000000, 0b0100000000000000, 0b1000000000000000, 0b0100000000000000, 0,0,0,0,0,0,0,0,0,0,0,
    0b0100000000000000, 0b0100000000000000, 0b0100000000000000, 0b0100000000000000, 0b0100000000000000, 0,0,0,0,0,0,0,0,0,0,0,
    0b0100000000000000, 0b1000000000000000, 0b0100000000000000, 0b0010000000000000, 0b0100000000000000, 0,0,0,0,0,0,0,0,0,0,0,
    0b0100000000000000, 0b0100000000000000, 0b0100000000000000, 0b0100000000000000, 0b0100000000000000, 0,0,0,0,0,0,0,0,0,0,0,
};

// NUMBER BITMAPS FOR SCORE / HI-SCORE AND LIVES LEFT + PLAYER FOR LIFE COUNT
unsigned short number_bitmaps[] = {
    0xfffe, 0xfffe, 0xc006, 0xc006, 0xc006, 0xc006, 0xc006, 0xc006,
    0xc006, 0xc006, 0xc006, 0xc006, 0xc006, 0xfffe, 0xfffe, 0x0000,

    0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0006,
    0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0000,

    0xfffe, 0xfffe, 0x0006, 0x0006, 0x0006, 0x0006, 0xfffe, 0xfffe,
    0xc000, 0xc000, 0xc000, 0xc000, 0xc000, 0xfffe, 0xfffe, 0x0000,

    0xfffe, 0xfffe, 0x0006, 0x0006, 0x0006, 0x0006, 0x3ffe, 0x3ffe,
    0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0xfffe, 0xfffe, 0x0000,

    0xc006, 0xc006, 0xc006, 0xc006, 0xc006, 0xc006, 0xfffe, 0xfffe,
    0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0000,

    0xfffe, 0xfffe, 0xc000, 0xc000, 0xc000, 0xc000, 0xfffe, 0xfffe,
    0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0xfffe, 0xfffe, 0x0000,

    0xc000, 0xc000, 0xc000, 0xc000, 0xc000, 0xc000, 0xfffe, 0xfffe,
    0xc006, 0xc006, 0xc006, 0xc006, 0xc006, 0xfffe, 0xfffe, 0x0000,

    0xfffe, 0xfffe, 0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0006,
    0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0000,

    0xfffe, 0xfffe, 0xc006, 0xc006, 0xc006, 0xc006, 0xfffe, 0xfffe,
    0xc006, 0xc006, 0xc006, 0xc006, 0xc006, 0xfffe, 0xfffe, 0x0000,

    0xfffe, 0xfffe, 0xc006, 0xc006, 0xc006, 0xc006, 0xfffe, 0xfffe,
    0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0000,

    0,0,0,0,0,0,0,0,0,
    0b0000010000000000,
    0b0000111000000000,
    0b0000111000000000,
    0b0111111111000000,
    0b1111111111100000,
    0b1111111111100000,
    0b1111111111100000,
};

#define MAXALIENS 55
struct Alien {
    short x, y;
    short type, animation_count;
};
struct Alien Aliens[ MAXALIENS ];

struct Swarm {
    short leftcolumn, rightcolumn, toprow, bottomrow, bottompixel;
    short row, column, direction, newdirection;
    short lastbombtimer;
};
struct Swarm AlienSwarm;

#define UFOONSCREEN 1
#define UFOEXPLODE 2
struct Ufo {
    short active, score;
    short counter;
    short x, direction;
    short lastufo;
};
struct Ufo UFO;

// CURRENT FRAMEBUFFER
unsigned short framebuffer = 0;

// PLAYER
#define SHIPPLAY 0
#define SHIPRESET 1
#define SHIPEXPLODE 2
struct Player {
    int score;
    short x, y;
    short level, life;
    short state, counter;
};
struct Player Ship;

void initialise_graphics( void ) {
    // SET BLITTER OBJECTS - ALIENS, EXPLOSIONS, UFO AND BUNKERS
    for( short i = 0; i < 15; i++ ) {
        set_blitter_bitmap( i + 2, &blitter_bitmaps[ 16 * i ] );
    }

    // SET SPRITES - 0:0 is player, 0:1-12 are bullets
    set_sprite_bitmaps( 0, 0, &player_bitmaps[0] );
    for( short i = 1; i < 13; i++ ) {
        set_sprite_bitmaps( 0, i, &bullet_bitmaps[0] );
    }

    // SET TILEMAP TILES - NUMBERS AND SHIP GRAPHIC
    for( short i = 0; i < 11; i++ ) {
        set_tilemap_bitmap( i + 1, &number_bitmaps[ 16 * i ] );
    }
}

void reset_aliens( void ) {
    bitmap_draw( 0 ); gpu_cs();
    bitmap_draw( 1 ); gpu_cs();

    // SET THE ALIENS
    for( short y = 0; y < 5; y++ ) {
        for( short x = 0; x < 11; x++ ) {
            Aliens[ y * 11 + x ].x = 16 * x + 8;
            Aliens[ y * 11 + x ].y = 16 * ( ( Ship.level < 4 ) ? Ship.level : 4 ) + 16 * y + 24;
            switch( y ) {
                case 0:
                    Aliens[ y * 11 + x ].type = 1;
                    break;
                case 1:
                case 2:
                    Aliens[ y * 11 + x ].type = 2;
                    break;
                default:
                    Aliens[ y * 11 + x ].type = 3;
                    break;
            }
            Aliens[ y * 11 + x ].animation_count = 0;
        }
    }

    AlienSwarm.leftcolumn = 0;
    AlienSwarm.rightcolumn = 10;
    AlienSwarm.toprow = 0;
    AlienSwarm.bottomrow = 4;
    AlienSwarm.row = 0;
    AlienSwarm.column = 10;
    AlienSwarm.direction = 1;
    AlienSwarm.newdirection = 1;
    AlienSwarm.lastbombtimer = 0;

    // REMOVE THE PLAYER, MISSILE AND BOMBS
    for( short i = 0; i < 13; i++ ) {
        set_sprite_attribute( 0, i, 0, 0 );
    }

    // DRAW BUNKERS
    for( short i = 0; i < 2; i++ ) {
        bitmap_draw( i );
        for( short j = 0; j < 4; j++ ) {
            gpu_blit( GREEN, 24 + j * 80, 208, 12, 0 );
            gpu_blit( GREEN, 40 + j * 80, 208, 13, 0 );
        }
    }

    bitmap_draw( !framebuffer );
}

void reset_player( void ) {
    Ship.state = SHIPRESET;
    Ship.counter = 32;
    Ship.x = 320 - 12;
    Ship.y = 465;
}

void reset_game( void ) {
    // SET THE PLAYER
    reset_player();
    Ship.score = 0;
    Ship.level = 0;
    Ship.life = 3;

    reset_aliens();
    UFO.active = 0;
    UFO.lastufo = 1000;
}

short count_aliens( void ) {
    short total = 0;

    for( short y = 0; y < 5; y++ ) {
        for( short x = 0; x < 11; x++ ) {
            switch( Aliens[ y * 11 + x ].type ) {
                case 0:
                    break;
                default:
                    total++;
            }
        }
    }
    return( total );
}

void trim_aliens( void ) {
    // DEBUG
    set_tilemap_tile( 1, 30, 9, TRANSPARENT, GREY2 );

    short left = 10, right = 0, top = 4, bottom = 0, pixel = 16;

    // CHECK IF ANY ALIENS LEFT
    if( !count_aliens() ) {
        reset_aliens();
        Ship.level++;
    }

    // TRIM SWARM
    for( short y = 0; y < 5; y++ ) {
        for( short x = 0; x < 11; x++ ) {
            switch( Aliens[ y * 11 + x ].type ) {
                case 0:
                    break;
                case 4:
                    Aliens[ y * 11 + x ].type = 0;
                default:
                    left = min( left, x );
                    right = max( right, x );
                    top = min( top, y );
                    bottom = max( bottom, y );
                    pixel =  max( pixel, Aliens[ y * 11 + x ].y + 7 );
            }
        }
    }
    AlienSwarm.leftcolumn = left;
    AlienSwarm.rightcolumn = right;
    AlienSwarm.toprow = top;
    AlienSwarm.bottomrow = bottom;
    AlienSwarm.bottompixel = pixel;
}

void draw_aliens( void ) {
    // DEBUG
    set_tilemap_tile( 1, 30, 8, TRANSPARENT, GREY2 );

    // DRAW ALIEN SWARM
    for( short y = AlienSwarm.toprow; y <= AlienSwarm.bottomrow; y++ ) {
        for( short x = AlienSwarm.leftcolumn; x <= AlienSwarm.rightcolumn; x++ ) {
            switch( Aliens[ y * 11 + x ].type ) {
                case 0:
                    break;
                case 1:
                case 2:
                case 3:
                    gpu_blit( WHITE, Aliens[ y * 11 + x ].x, Aliens[ y * 11 + x ].y, Aliens[ y * 11 + x ].type * 2 +  Aliens[ y * 11 + x ].animation_count, 0 );
                    break;
                case 4:
                    break;
                case 5:
                case 6:
                    Aliens[ y * 11 + x ].type--;
                    break;
                default:
                    gpu_blit( RED, Aliens[ y * 11 + x ].x, Aliens[ y * 11 + x ].y, 8 + framebuffer, 0 );
                    Aliens[ y * 11 + x ].type--;
                    break;
            }
        }
    }

    // DRAW UFO
    switch( UFO.active ) {
        case UFOONSCREEN:
            gpu_blit( MAGENTA, UFO.x, 16, 10 + framebuffer, 0 );
            break;
        case UFOEXPLODE:
            gpu_printf_centre( framebuffer ? RED : LTRED, UFO.x + 7, 16, 0, "%d", UFO.score );
            break;
        default:
            break;
    }
}

void move_aliens( void ) {
    // DEBUG
    set_tilemap_tile( 1, 30, 7, TRANSPARENT, GREY2 );

    // FIND AN ALIEN
    if( ( Aliens[ AlienSwarm.row * 11 + AlienSwarm.column ].type != 0 ) && ( AlienSwarm.newdirection ) ) {
        AlienSwarm.newdirection = 0;
    } else {
        do {
            // DEBUG
            set_tilemap_tile( 1, 30, 7, TRANSPARENT, PURPLE );
            switch( AlienSwarm.direction ) {
                case 1:
                    AlienSwarm.column--;
                    if( AlienSwarm.column < AlienSwarm.leftcolumn ) {
                        AlienSwarm.column = AlienSwarm.rightcolumn;
                        AlienSwarm.row++;
                    }
                    if( AlienSwarm.row > AlienSwarm.bottomrow ) {
                        beep( 1, 0, 1, 100 );
                        AlienSwarm.row = AlienSwarm.toprow;
                        AlienSwarm.column = AlienSwarm.rightcolumn;
                        for( short y = AlienSwarm.toprow; y <= AlienSwarm.bottomrow; y++ ) {
                            if( ( Aliens[ y * 11 + AlienSwarm.rightcolumn ].x >= 304 ) && ( Aliens[ y * 11 + AlienSwarm.rightcolumn ].type != 0 ) ) {
                                AlienSwarm.direction = 2;
                                AlienSwarm.column = AlienSwarm.leftcolumn;
                            }
                        }
                    }
                    break;
                case 0:
                    AlienSwarm.column++;
                    if( AlienSwarm.column > AlienSwarm.rightcolumn ) {
                        AlienSwarm.column = AlienSwarm.leftcolumn;
                        AlienSwarm.row++;
                    }
                    if( AlienSwarm.row > AlienSwarm.bottomrow ) {
                        beep( 1, 0, 1, 100 );
                        AlienSwarm.row = AlienSwarm.toprow;
                        AlienSwarm.column = AlienSwarm.leftcolumn;
                        for( short y = AlienSwarm.toprow; y <= AlienSwarm.bottomrow; y++ ) {
                            if( ( Aliens[ y * 11 + AlienSwarm.leftcolumn ].x <= 8 ) && ( Aliens[ y * 11 + AlienSwarm.leftcolumn ].type != 0 ) ) {
                                AlienSwarm.direction = 3;
                                AlienSwarm.column = AlienSwarm.rightcolumn;
                            }
                        }
                    }
                    break;
                default:
                    break;
            }
        } while( ( Aliens[ AlienSwarm.row * 11 + AlienSwarm.column ].type == 0 ) && ( AlienSwarm.direction < 2 ) );
    }

    // DEBUG
    set_tilemap_tile( 1, 30, 7, TRANSPARENT, ORANGE );
    switch( AlienSwarm.direction ) {
        // MOVE LEFT OR RIGHT
        case 0:
        case 1:
            Aliens[ AlienSwarm.row * 11 + AlienSwarm.column ].x += ( AlienSwarm.direction == 1 ) ? 8 : -8;
            Aliens[ AlienSwarm.row * 11 + AlienSwarm.column ].animation_count = !Aliens[ AlienSwarm.row * 11 + AlienSwarm.column ].animation_count;
            break;

        // MOVE DOWN AND CHANGE DIRECTION
        case 2:
        case 3:
            // DEBUG
            set_tilemap_tile( 1, 30, 7, TRANSPARENT, YELLOW );
            for( short y = AlienSwarm.toprow; y <= AlienSwarm.bottomrow; y++ ) {
                for( short x = AlienSwarm.leftcolumn; x <= AlienSwarm.rightcolumn; x++ ) {
                    Aliens[ y * 11 + x ].y += 8;
                }
            }
            AlienSwarm.direction -= 2;
            AlienSwarm.newdirection = 1;
            break;
    }
}

void ufo_actions( void ) {
    // DEBUG
    set_tilemap_tile( 1, 30, 6, TRANSPARENT, GREY2 );

    switch( UFO.active ) {
        case 0:
            if( !UFO.lastufo ) {
                if( !rng(8) ) {
                    UFO.active = UFOONSCREEN;
                    switch( rng(1) ) {
                        case 0:
                            UFO.x = -15;
                            UFO.direction = 1;
                            break;
                        case 1:
                            UFO.x = 320;
                            UFO.direction = 0;
                            break;
                    }
                }
            } else {
                UFO.lastufo--;
            }
            break;
        case UFOONSCREEN:
            // MOVE THE UFO
            UFO.x += ( ( UFO.direction ) ? 1 : -1 ) * ( ( Ship.level > 0 ) ? 1 : framebuffer );
            if( ( UFO.x < -15 ) || ( UFO.x > 320 ) ) {
                UFO.active = 0;
                UFO.lastufo = 1000;
            }
            break;
        case UFOEXPLODE:
            if( !UFO.counter ) {
                UFO.active = 0;
                UFO.lastufo = 1000;
            } else {
                UFO.counter--;
            }
            break;
    }
}


void bomb_actions( void ) {
    short bombdropped = 0, bombcolumn, bombrow, attempts = 8;
    short bomb_x, bomb_y;

    // DEBUG
    set_tilemap_tile( 1, 30, 5, TRANSPARENT, GREY2 );

    // CHECK IF HIT AND MOVE BOMBS
    for( short i = 2; i < 13; i++ ) {
        // DEBUG
        set_tilemap_tile( 1, 30, 5, TRANSPARENT, PURPLE );
        if( get_sprite_collision( 0, i ) & 0x8000 ) {
            // HIT THE BUNKER
            bomb_x = get_sprite_attribute( 0, i , 3 ) / 2 - rng(4) + 2;
            bomb_y = get_sprite_attribute( 0, i , 4 ) / 2 + rng(2) + 1;
            set_sprite_attribute( 0, i, 0, 0 );
            bitmap_draw( 0 ); gpu_blit( TRANSPARENT, bomb_x, bomb_y, 14, 0 );
            bitmap_draw( 1 ); gpu_blit( TRANSPARENT, bomb_x, bomb_y, 14, 0 );
            bitmap_draw( !framebuffer );
        } else {
            update_sprite( 0, i, 0b1110010000000 );
        }
        if( get_sprite_collision( 0, i ) & 2 ) {
            // HIT THE PLAYER MISSILE
            set_sprite_attribute( 0, i, 0, 0 );
            set_sprite_attribute( 0, 1, 0, 0 );
        }
        if( get_sprite_collision( 0,i ) & 1 ) {
            // HIT THE PLAYER
            Ship.state = SHIPEXPLODE;
            Ship.counter = 100;
            for( short i = 1; i < 13; i++ ) {
                set_sprite_attribute( 0, i, 0, 0 );
            }
        }
    }

    // CHECK IF FIRING
    AlienSwarm.lastbombtimer -= ( AlienSwarm.lastbombtimer ) > 0 ? 1 : 0;
    if( !AlienSwarm.lastbombtimer && !rng(4) ) {
        // DEBUG
        set_tilemap_tile( 1, 30, 5, TRANSPARENT, ORANGE );
        for( short i = 2; ( i < 13 ) && !bombdropped; i++ ) {
            if( !get_sprite_attribute( 0, i, 0 ) ) {
                // BOMB SLOT FOUND
                // FIND A COLUMN AND BOTTOM ROW ALIEN
                while( !bombdropped && attempts ) {
                    bombcolumn = rng(11);
                    for( bombrow = 4; ( bombrow >= 0 ) && attempts && !bombdropped; bombrow-- ) {
                        switch( Aliens[ bombrow * 11 + bombcolumn ].type ) {
                            case 1:
                            case 2:
                            case 3:
                                set_sprite( 0, i, 1, LTRED, 2 * Aliens[ bombrow * 11 + bombcolumn ].x + 4, 2 * Aliens[ bombrow * 11 + bombcolumn ].y + 12, 0, 1 );
                                AlienSwarm.lastbombtimer = ( Ship.level == 0 ) ? 32 : ( Ship.level > 2 ) ? 8 : 16;
                                bombdropped = 1;
                                break;
                            default:
                                break;
                        }
                        attempts--;
                    }
                }
            }
        }
    }
}

short missile_actions( void ) {
    // DEBUG
    set_tilemap_tile( 1, 30, 4, TRANSPARENT, GREY2 );

    short missile_x, missile_y, alien_hit = 0, points = 0;

    // CHECK IF PLAYER MISSILE HAS HIT
    if( get_sprite_collision( 0, 1 ) & 0x8000 ) {
        missile_x = get_sprite_attribute( 0, 1, 3 ) / 2;
        missile_y = get_sprite_attribute( 0, 1, 4 ) / 2;
        for( short y = AlienSwarm.toprow; y <= AlienSwarm.bottomrow && !alien_hit; y++ ) {
            for( short x = AlienSwarm.leftcolumn; x <= AlienSwarm.rightcolumn && !alien_hit; x++ ) {
                switch( Aliens[ y * 11 + x ].type ) {
                    case 1:
                    case 2:
                    case 3:
                        if( ( missile_x >= Aliens[ y * 11 + x ].x - 3 ) && ( missile_x <= Aliens[ y * 11 + x ].x + 13 ) && ( missile_y >= Aliens[ y * 11 + x ].y - 4 ) && ( missile_y <= Aliens[ y * 11 + x ].y + 12 ) ) {
                            beep( 2, 4, 8, 500 );
                            points = ( 4 - Aliens[ y * 11 + x ].type ) * 10;
                            set_sprite_attribute( 0, 1, 0, 0 );
                            Aliens[ y * 11 + x ].type = 16;
                            alien_hit = 1;
                        }
                        break;
                    default:
                        break;
                }
            }
        }
        if( !alien_hit ) {
            set_sprite_attribute( 0, 1, 0, 0 );
            if( missile_y > 24 ) {
                // HIT A BUNKER
                missile_x = missile_x - rng(4) + 2;
                missile_y = missile_y - rng(2) - 1;
                bitmap_draw( 0 ); gpu_blit( TRANSPARENT, missile_x, missile_y, 14, 0 );
                bitmap_draw( 1 ); gpu_blit( TRANSPARENT, missile_x, missile_y, 14, 0 );
                bitmap_draw( !framebuffer );
            } else {
                // HIT UFO
                UFO.active = UFOEXPLODE;
                UFO.counter = 100;
                UFO.score = ( rng(3) + 1 ) * 50;
                points = UFO.score;
            }
        }
    }

    // FIRE? OR MOVE MISSILE
    if( !get_sprite_attribute( 0, 1, 0 ) ) {
        // NO MISSILE, CHECK IF FIRE
        if( get_buttons() & 2  ) {
            set_sprite( 0, 1, 1, GREEN, Ship.x + 8, Ship.y - 10, 0, 1 );
            beep( 2, 4, 61, 128 );
        }
    } else {
        // MOVE MISSILE
        update_sprite( 0, 1, 0b1111101000000 );
    }

    return( points );
}

void player_actions( void ) {
    // DEBUG
    set_tilemap_tile( 1, 30, 3, TRANSPARENT, GREY2 );

    if( ( get_sprite_collision( 0, 0 ) & 0x8000 ) && ( Ship.state != SHIPEXPLODE ) ) {
        // ALIEN HAS HIT SHIP
        Ship.state = SHIPEXPLODE;
        Ship.counter = 100;
        for( short i = 1; i < 13; i++ ) {
            set_sprite_attribute( 0, i, 0, 0 );
        }
    }
    switch( Ship.state ) {
        case SHIPPLAY:
            if( ( get_buttons() & 32 ) && ( Ship.x > 0 ) )
                Ship.x -= 2;
            if( ( get_buttons() & 64 ) && ( Ship.x < 617 ) )
                Ship.x += 2;
            set_sprite( 0, 0, 1, GREEN, Ship.x, Ship.y, 0, 1 );
            break;
        case SHIPRESET:
            // RESET
            set_sprite( 0, 0, 0, DKGREEN, Ship.x, Ship.y, 0, 1 );
            Ship.counter--;
            if( !Ship.counter ) Ship.state = SHIPPLAY;
            break;
        case SHIPEXPLODE:
            // EXPLODE
            set_sprite( 0, 0, 1, RED, Ship.x, Ship.y, 0, 1 );
            Ship.counter--;
            if( !Ship.counter ) {
                Ship.life--;
                if( get_sprite_collision( 0, 0 ) & 0x8000 ) {
                    // SHIP HIT BY ALIEN, NOT MISSILE
                    reset_aliens();
                }
                reset_player();
            }
           break;
    }
}

void draw_status( void ) {
    char scorestring[9];

    // DEBUG
    set_tilemap_tile( 1, 30, 2, TRANSPARENT, GREY2 );

    // GENERATE THE SCORE STRING
    sprintf( &scorestring[0], "%8u", Ship.score );

    // PRINT THE SCORE
    for( short i = 0; i < 8; i++ ) {
        set_tilemap_tile( 17 + i, 1,  ( scorestring[i] == ' ' ) ? 1 : scorestring[i] - 47, TRANSPARENT, GREY2 );
    }
    // PRINT THE LIVES LEFT
    set_tilemap_tile( 35, 1,  Ship.life + 1, TRANSPARENT, GREY2 );
    for( short i = 0; i < 3; i++ ) {
        set_tilemap_tile( 37 + i, 1,  ( i < Ship.life ) ? 11 : 0, TRANSPARENT, GREY2 );
    }
    // PRINT THE LEVEL ( 2 DIGITS )
    set_tilemap_tile( 2, 1,  ( Ship.level / 10 ) + 1, TRANSPARENT, GREY2 );
    set_tilemap_tile( 3, 1,  ( Ship.level % 10 ) + 1, TRANSPARENT, GREY2 );
}

void play( void ) {
    initialise_graphics();
    reset_game();

    while( Ship.life > 0 ) {
        // DEBUG
        set_tilemap_tile( 1, 30, 1, TRANSPARENT, GREY2 );

        // DRAW TO HIDDEN FRAME BUFFER
        bitmap_draw( !framebuffer );

        // ADJUST SIZE OF ALIEN GRID
        trim_aliens();
        if( Ship.state != SHIPEXPLODE ) {
            // MOVE ALIENS
            move_aliens();
            // HANDLE MISSILES AND BOMBS
            Ship.score += missile_actions();
            bomb_actions();
        }

        player_actions();
        ufo_actions();

        // UPDATE THE SCREEN
        gpu_rectangle( TRANSPARENT, 0, 16, 319, AlienSwarm.bottompixel );
        draw_aliens();

        // SWITCH THE FRAMEBUFFER
        await_vblank();
        framebuffer = !framebuffer;
        bitmap_display( framebuffer );

        draw_status();
    }
}

int main( void ) {
    INITIALISEMEMORY();
    set_background( GREY2, DKBLUE - 1, BKG_SNOW );

    // CLEAR THE TILEMAP
    tilemap_scrollwrapclear( 9 );

    while(1) {
        bitmap_draw( 0 );gpu_cs();
        bitmap_draw( 1 );gpu_cs();

        play();
        sleep( 8000, 0 );
    }
}
