// PAWS implementation of http://nicktasios.nl/posts/space-invaders-from-scratch-part-1.html

#include "PAWSlibrary.h"

#define MAXALIENS 55

// CURRENT FRAMEBUFFER
unsigned char framebuffer = 0;

struct Alien
{
    size_t x, y;
    uint8  type;
};

struct Player
{
    size_t x, y;
    size_t life;
};

struct Game
{
    size_t width, height;
    size_t num_aliens;
    struct Alien aliens[55];
    struct Player player;
};

void initialise( void ) {
    struct Game game;
    game.width = 320;
    game.height = 240;
    game.num_aliens = MAXALIENS;

    game.player.x = 112 - 5;
    game.player.y = 32;

    game.player.life = 3;

    for(size_t yi = 0; yi < 5; ++yi) {
        for(size_t xi = 0; xi < 11; ++xi) {
            game.aliens[yi * 11 + xi].x = 16 * xi + 20;
            game.aliens[yi * 11 + xi].y = 17 * yi + 128;
        }
    }
}

void play( void ) {
    initialise();
    while( game.life != 0 ) {

    }
}

int main( void ) {
    INITIALISEMEMORY();

    while(1) {
    }
}
