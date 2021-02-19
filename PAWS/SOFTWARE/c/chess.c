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

void setupscreen( void ) {
    // CLEAR and SET THE BACKGROUND
    gpu_cs();
    tpu_cs();
    set_background( 0, 0, BKG_RAINBOW );

    // CLEAR THE SCREEN AND DRAW THE FRAME
    gpu_rectangle( BLACK, 104, 24, 536, 456 );
    gpu_rectangle( WHITE, 112, 32, 528, 448 );
}

void drawboard( void ) {
    // DRAW THE CHESS BOARD + PIECES
    for( int x = 0; x < MAX_RANK; x++ ) {
        for( int y = 0; y < MAX_COLUMN; y++ ) {
            // DRAW THE BOARD
            if( ( x & 1 ) == ( y & 1 ) ) {
                gpu_rectangle( GREY1, 120 + x*50, 40 + y*50, 170 + x*50, 90 + y*50 );
            } else {
                gpu_rectangle( GREY2, 120 + x*50, 40 + y*50, 170 + x*50, 90 + y*50 );
            }

            // DRAW THE PIECES
            if( board[x][y].type != NONE )
                gpu_character_blit( ( board[x][y].colour ) == HOME ? DKBLUE : DKRED, 129 + x*50, 49 + y*50, '0' + board[x][y].type, 2 );
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

void main( void ) {
    INITIALISEMEMORY();

    setupscreen();

	while(1) {
        setupboard();
        drawboard();

        (void)uartinputcharacter();
    }
}
