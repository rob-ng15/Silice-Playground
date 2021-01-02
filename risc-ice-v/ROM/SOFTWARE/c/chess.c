#include "PAWSlibrary.h"

// Ideas from:
// https://codereview.stackexchange.com/questions/234619/chess-game-in-c
// https://www.quora.com/How-can-I-make-a-simple-console-chess-game-with-C-read-details

enum Type {
    NONE = 0,
    PAWN,
    ROOK,
    BISHOP,
    KNIGHT,
    QUEEN,
    KING,
};

enum Colour {
    HOME = 1,
    AWAY,
    NEITHER
};

struct Piece {
    enum Type type;
    enum Colour colour;
};

struct Piece board[8][8];

#define MAX_RANK 7
#define MAX_COLUMN 7

void setupboard( void ) {

    // WIPE OUT BOARD
    for( int x = 0; x <= MAX_RANK; x++ ) {
        for( int y = 0; y <= MAX_COLUMN; y++ ) {
            struct Piece board[x][y] = { .type = NONE, .colour = NEITHER };
        }
    }
}

void main( void ) {

    setupboard();

	while(1) {
    }
}
