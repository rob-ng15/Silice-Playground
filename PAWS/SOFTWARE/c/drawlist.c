#include "PAWSlibrary.h"

int main( void ) {
    INITIALISEMEMORY();

    struct DrawList2D LEFTCHEVRON[] = {
        { DLRECT, GREY2, GREY2, DITHERSOLID, { -4, 0 }, { 4, -32 }, },
        { DLRECT, GREY1, GREY1, DITHERSOLID, { -32, -32 }, { 32, -64 }, },
        { DLQUAD, WHITE, WHITE, DITHERSOLID, { -8, -64 }, { 8, -64 }, { -16, -48 }, { -32, -48 } }
    };
    struct DrawList2D RIGHTCHEVRON[] = {
        { DLRECT, GREY2, GREY2, DITHERSOLID, { -4, 0 }, { 4, -32 }, },
        { DLRECT, GREY1, GREY1, DITHERSOLID, { -32, -32 }, { 32, -64 }, },
        { DLQUAD, WHITE, WHITE, DITHERSOLID, { -8, -64 }, { 8, -64 }, { 32, -48 }, { 16, -48 } }
    };

    gpu_cs();
    DoDrawList2D( LEFTCHEVRON, 3, 80, 120, 1 ); DoDrawList2D( RIGHTCHEVRON, 3, 240, 120, 1 );
    sleep( 2000, 0 );
    gpu_cs();
    DoDrawList2D( LEFTCHEVRON, 3, 80, 120, 0.5 ); DoDrawList2D( RIGHTCHEVRON, 3, 240, 120, 0.5 );
    sleep( 2000, 0 );
}

// EXIT WILL RETURN TO BIOS
