// PAWS implementation of http://nicktasios.nl/posts/space-invaders-from-scratch-part-1.html

#include "PAWSlibrary.h"

// GRAPHICS
// ALIENS ARE BLITTER OBJECTS, 2 DESIGNS PER ALIEN TYPE FOR ANIMATION
unsigned short invaders_bitmaps[] = {
    0b0001100000000000,
    0b0011111000000000,
    0b0111111100000000,
    0b1101101100000000,
    0b1111111100000000,
    0b0101101000000000,
    0b1000000100000000,
    0b0100001000000000,
    0,0,0,0,0,0,0,0,

    0b0001100000000000,
    0b0011111000000000,
    0b0111111100000000,
    0b1101101100000000,
    0b1111111100000000,
    0b0010010000000000,
    0b0101101000000000,
    0b1010010100000000,
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
    0,0,0,0,0,0,0,0
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

#define MAXALIENS 55
struct Alien {
    short x, y;
    short type;
};
struct Alien Aliens[ MAXALIENS ];
unsigned short animation_count = 0;

struct Swarm {
    short leftcolumn, rightcolumn, toprow, bottomrow;
};
struct Swarm AlienSwarm;

// CURRENT FRAMEBUFFER
unsigned short framebuffer = 0;

// PLAYER
struct Player {
    short x, y;
    short life;
};
struct Player Ship;

void initialise_graphics( void ) {
    // SET BLITTER OBJECTS - ALIENS
    for( short i = 0; i < 6; i++ ) {
        set_blitter_bitmap( i, &invaders_bitmaps[ 16 * i ] );
    }

    // SET SPRITES - 0:0 is player, 0:1-12 are bullets
    set_sprite_bitmaps( 0, 0, &player_bitmaps[0] );
    for( short i = 1; i < 13; i++ ) {
        set_sprite_bitmaps( 0, i, &bullet_bitmaps[0] );
    }
}

void reset_game( void ) {
    // SET THE ALIENS
    for( short y = 0; y < 5; y++ ) {
        for( short x = 0; x < 11; x++ ) {
            Aliens[ y * 11 + x ].x = 16 * x + 20;
            Aliens[ y * 11 + x ].y = 17 * y + 32;
            switch( y ) {
                case 0:
                    Aliens[ y * 11 + x ].type = 0;
                    break;
                case 1:
                case 2:
                    Aliens[ y * 11 + x ].type = 1;
                    break;
                default:
                    Aliens[ y * 11 + x ].type = 2;
                    break;
            }
        }
    }

    AlienSwarm.leftcolumn = 0;
    AlienSwarm.rightcolumn = 10;
    AlienSwarm.toprow = 0;
    AlienSwarm.bottomrow = 4;

    // SET THE PLAYER
    Ship.x = 320 - 12;
    Ship.y = 437;
    Ship.life = 3;
}

void play( void ) {
    short row = 0, column = 10, direction = 1;

    initialise_graphics();
    reset_game();

    while(1) {
        // DRAW TO HIDDEN FRAME BUFFER
        bitmap_draw( 1 - framebuffer );
        gpu_cs();

        // DUMMY DISPLAY CODE
        for( short y = 0; y < 5; y++ ) {
            for( short x = 0; x < 11; x++ ) {
                gpu_blit( WHITE, Aliens[ y * 11 + x ].x, Aliens[ y * 11 + x ].y, Aliens[ y * 11 + x ].type * 2 + animation_count, 0 );
            }
        }
        // SWITCH THE FRAMEBUFFER
        await_vblank();
        framebuffer = 1 - framebuffer;
        bitmap_display( framebuffer );

        // SET PLAYER AND MISSILE
        set_sprite( 0, 0, 1, GREEN, Ship.x, Ship.y, 0, 1 );
        if( !get_sprite_attribute( 0, 1, 0 ) ) {
            set_sprite( 0, 1, 1, GREEN, Ship.x + 8, Ship.y - 10, 0, 1 );
        } else {
            update_sprite( 0, 1, 0b1111111000000 );
        }

        // UPDATE THE ALIENS
        switch( direction ) {
            case 1:
                // MOVE RIGHT
                Aliens[ row * 11 + column ].x += 8;
                column--;
                if( column < AlienSwarm.leftcolumn ) {
                    column = AlienSwarm.rightcolumn;
                    row++;
                    animation_count = 1 - animation_count;
                }
                if( row > AlienSwarm.bottomrow ) {
                    row = AlienSwarm.toprow;
                   if( Aliens[ AlienSwarm.toprow * 11 + AlienSwarm.rightcolumn ].x >= 319 - 30 ) {
                        direction = 0;
                        column = AlienSwarm.leftcolumn;
                    }
                }
                break;

            case 0:
                // MOVE LEFT
                Aliens[ row * 11 + column ].x -= 8;
                column++;
                if( column > AlienSwarm.rightcolumn ) {
                    column = AlienSwarm.leftcolumn;
                    row++;
                    animation_count = 1 - animation_count;
                }
                if( row > AlienSwarm.bottomrow ) {
                    row = AlienSwarm.toprow;
                    if( Aliens[ AlienSwarm.toprow * 11 + AlienSwarm.leftcolumn ].x <= 20 ) {
                        direction = 1;
                        column = AlienSwarm.rightcolumn;
                    }
                }
                break;
        }
    }
}

int main( void ) {
    INITIALISEMEMORY();

    play();

    while(1) {
    }
}
