#include "PAWSlibrary.h"

int main( void ) {
    INITIALISEMEMORY();

    struct DrawList2D LEFTCHEVRON[] = {
        { DLRECT, GREY2, GREY2, DITHERSOLID, { -4, 0 }, { 4, -32 }, },
        { DLRECT, GREY1, GREY1, DITHERSOLID, { -32, -32 }, { 32, -64 }, },
        { DLLINE, WHITE, WHITE, DITHERSOLID, { 0, -32 }, { -16, -48 }, { 17, 0 } },
        { DLLINE, WHITE, WHITE, DITHERSOLID, { -16, -48 }, { 0, -64 }, { 17, 0 } },
    };
    struct DrawList2D RIGHTCHEVRON[] = {
        { DLRECT, GREY2, GREY2, DITHERSOLID, { -4, 0 }, { 4, -32 }, },
        { DLRECT, GREY1, GREY1, DITHERSOLID, { -32, -32 }, { 32, -64 }, },
        { DLLINE, WHITE, WHITE, DITHERSOLID, { 0, -32 }, { 16, -48 }, { 17, 0 } },
        { DLLINE, WHITE, WHITE, DITHERSOLID, { 16, -48 }, { 0, -64 }, { 17, 0 } },
    };

    gpu_cs();
    DoDrawList2D( LEFTCHEVRON, 4, 80, 120, 1 ); DoDrawList2D( RIGHTCHEVRON, 4, 240, 120, 1 );
    sleep( 4000, 0 );

    gpu_cs();
    DoDrawList2D( LEFTCHEVRON, 4, 80, 120, 0.5 ); DoDrawList2D( RIGHTCHEVRON, 4, 240, 120, 0.5 );
    sleep( 4000, 0 );
}

// EXIT WILL RETURN TO BIOS
