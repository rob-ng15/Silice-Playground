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

#define MAX_RANK 8
#define MAX_COLUMN 8

unsigned short blitter_bitmaps[] = {
    0,0,0,0,
    0b0000001100000000,
    0b0000011110000000,
    0b0000011110000000,
    0b0000001100000000,
    0b0000001100000000,
    0b0000001100000000,
    0b0000001100000000,
    0b0000011110000000,
    0b0000011110000000,
    0b0000111111000000,
    0b0001111111100000,
    0,

    0,0,
    0b0001101101100000,
    0b0011101101110000,
    0b0011111111110000,
    0b0011111111110000,
    0b0001111111100000,
    0b0000111111000000,
    0b0000011110000000,
    0b0000011110000000,
    0b0000011110000000,
    0b0000011110000000,
    0b0000011110000000,
    0b0000111111000000,
    0b0001111111100000,
    0,

    0,0,
    0b0000001100000000,
    0b0000001100000000,
    0b0000011110000000,
    0b0000011110000000,
    0b0000111111000000,
    0b0000111111000000,
    0b0000011110000000,
    0b0000001100000000,
    0b0000001100000000,
    0b0000011110000000,
    0b0000011110000000,
    0b0000111111000000,
    0b0001111111100000,
    0,

    0,0,
    0b0000000100000000,
    0b0000011110000000,
    0b0000011110000000,
    0b0000110111000000,
    0b0001111111000000,
    0b0001111111000000,
    0b0000001111100000,
    0b0000001111100000,
    0b0000011111000000,
    0b0000011111000000,
    0b0000011110000000,
    0b0000111111000000,
    0b0001111111100000,
    0,

    0,
    0b0000001100000000,
    0b0000011110000000,
    0b0000001100000000,
    0b0000001100000000,
    0b0000001100000000,
    0b0000011110000000,
    0b0000001100000000,
    0b0000001100000000,
    0b0000001100000000,
    0b0000001100000000,
    0b0000011110000000,
    0b0000011110000000,
    0b0000111111000000,
    0b0001111111100000,
    0,

    0b0000001100000000,
    0b0000011110000000,
    0b0000001100000000,
    0b0000011110000000,
    0b0000111111000000,
    0b0000111111000000,
    0b0000011110000000,
    0b0000001100000000,
    0b0000001100000000,
    0b0000001100000000,
    0b0000001100000000,
    0b0000011110000000,
    0b0000011110000000,
    0b0000111111000000,
    0b0001111111100000
};

void setupscreen( void ) {
    // CLEAR and SET THE BACKGROUND
    gpu_cs();
    tpu_cs();
    set_background( 0, 0, BKG_RAINBOW );

    // SET BLITTER OBJECTS - CHESS PIECES
    for( short i = 0; i < 6; i++ ) {
        set_blitter_bitmap( i + 1, &blitter_bitmaps[ 16 * i ] );
    }
}

void drawboard( void ) {
    // DRAW THE CHESS BOARD + PIECES
    for( int x = 0; x < MAX_RANK; x++ ) {
        for( int y = 0; y < MAX_COLUMN; y++ ) {
            // DRAW THE BOARD
            gpu_rectangle( ( ( x & 1 ) == ( y & 1 ) ) ? GREY1 : GREY2, 40 + x * 30, y * 30, 70 + x * 30, 30  + y * 30 );

            // DRAW THE PIECES
            if( board[x][y].type != NONE )
                gpu_blit( ( board[x][y].colour ) == HOME ? DKBLUE : DKRED, 40 + x * 30, y * 30, board[x][y].type, 1, 0 );
        }
    }
}

void setupboard( void ) {
    // WIPE OUT BOARD
    for( int x = 0; x < MAX_RANK; x++ ) {
        for( int y = 0; y < MAX_COLUMN; y++ ) {
            board[x][y].type = NONE;
            switch( y ) {
                case 7:
                case 6:
                    board[x][y].colour = AWAY;
                    break;
                case 1:
                case 0:
                    board[x][y].colour = HOME;
                    break;
                default:
                    board[x][y].colour = NEITHER;
                    break;
            }
        }
    }

    // PLACE PAWNS
    for( int x = 0; x < MAX_RANK; x++ ) {
        board[x][1].type = PAWN;
        board[x][6].type = PAWN;
    }

    // PLACE ROOKS
    board[0][0].type = ROOK;
    board[0][7].type = ROOK;
    board[7][0].type = ROOK;
    board[7][7].type = ROOK;

    // PLACE KNIGHTS
    board[1][0].type = KNIGHT;
    board[6][0].type = KNIGHT;
    board[1][7].type = KNIGHT;
    board[6][7].type = KNIGHT;

    // PLACE BISHOPS
    board[2][0].type = BISHOP;
    board[5][0].type = BISHOP;
    board[2][7].type = BISHOP;
    board[5][7].type = BISHOP;

    // PLACE QUEENS
    board[3][0].type = QUEEN;
    board[4][7].type = QUEEN;

    // PLACE KINGS
    board[4][0].type = KING;
    board[3][7].type = KING;
}

int main( void ) {
    INITIALISEMEMORY();

    setupscreen();

	// CONTINUE UNTIL FIRE 2 IS PRESSED
    while( !( get_buttons() & 4 ) ) {
        setupboard();
        drawboard();

        while( get_buttons() == 1 ) {}
    }
}
