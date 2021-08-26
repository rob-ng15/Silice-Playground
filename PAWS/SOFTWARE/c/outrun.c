// https://www.lexaloffle.com/bbs/?tid=35767
#include "PAWSlibrary.h"
#include <math.h>
#include <stdio.h>

// DELAY BETWEEN FRAMES
#define DELAY 2000

// ROADSIDE ITEMS - AS DRAWLISTS FOR EASIER PLACEMENT AND SCALING
#define NONE 0
#define TREE 1
#define SIGN 2
#define HOUSE 3
#define BEAMS 4
struct DrawList2D LEFTCHEVRON[] = {
    { DLRECT, GREY2, GREY2, DITHERSOLID, { -4, 0 }, { 4, -32 }, },
    { DLRECT, BLACK, BLACK, DITHERSOLID, { -32, -32 }, { 32, -64 }, },
    { DLLINE, WHITE, WHITE, DITHERSOLID, { 0, -32 }, { -16, -48 }, { 17, 0 } },
    { DLLINE, WHITE, WHITE, DITHERSOLID, { -16, -48 }, { 0, -64 }, { 17, 0 } },
};
struct DrawList2D RIGHTCHEVRON[] = {
    { DLRECT, GREY2, GREY2, DITHERSOLID, { -4, 0 }, { 4, -32 }, },
    { DLRECT, BLACK, BLACK, DITHERSOLID, { -32, -32 }, { 32, -64 }, },
    { DLLINE, WHITE, WHITE, DITHERSOLID, { 0, -32 }, { 16, -48 }, { 17, 0 } },
    { DLLINE, WHITE, WHITE, DITHERSOLID, { 16, -48 }, { 0, -64 }, { 17, 0 } },
};

struct DrawList2D PINETREE[] = {
    { DLRECT, BROWN, DKBROWN, DITHERCHECK1, { -8, 0 }, { 8, -32 }, },
    { DLTRI, VDKGREEN, VDKGREEN, DITHERSOLID, { 0, -96 }, { 32, -32 }, { -32, -32 } },
};

struct DrawList2D LEFTBEAM[] = {
    { DLLINE, DKRED, DKRED, DITHERSOLID, { 0, 0 }, { 0, -128 }, { 9, 0 } },
    { DLLINE, DKRED, DKRED, DITHERSOLID, { -32, 0 }, { -32, -128 }, { 9, 0 } },
    { DLLINE, DKRED, DKRED, DITHERSOLID, { -32, -128 }, { 160, -128 }, { 9, 0 } },
    { DLLINE, VDKRED, DKRED, DITHERSOLID, { 0, -128 }, { -32, -96 }, { 5, 0 } },
    { DLLINE, VDKRED, DKRED, DITHERSOLID, { -32, -128 }, { 0, -96 }, { 5, 0 } },
    { DLLINE, VDKRED, DKRED, DITHERSOLID, { 0, -64 }, { -32, -32 }, { 5, 0 } },
    { DLLINE, VDKRED, DKRED, DITHERSOLID, { -32, -64 }, { 0, -32 }, { 5, 0 } },
    { DLRECT, BLACK, BLACK, DITHERSOLID, { 112, -136}, { 96, -120 }, },
    { DLTRI, GREEN, GREEN, DITHERSOLID, { 97, -121 }, { 97, -128 }, { 104, -121 } },
    { DLLINE, GREEN, GREEN, DITHERSOLID, { 97, -121 }, { 111, -135 }, { 3, 0 } }
};

struct DrawList2D RIGHTBEAM[] = {
    { DLRECT, BLACK, BLACK, DITHERSOLID, { -112, -136 }, { -96, -120 }, },
    { DLLINE, DKRED, DKRED, DITHERSOLID, { 0, 0 }, { 0, -128 }, { 9, 0 } },
    { DLLINE, DKRED, DKRED, DITHERSOLID, { 32, 0 }, { 32, -128 }, { 9, 0 } },
    { DLLINE, DKRED, DKRED, DITHERSOLID, { 32, -128 }, { -160, -128 }, { 9, 0 } },
    { DLLINE, VDKRED, DKRED, DITHERSOLID, { 0, -128 }, { 32, -96 }, { 5, 0 } },
    { DLLINE, VDKRED, DKRED, DITHERSOLID, { 32, -128 }, { 0, -96 }, { 5, 0 } },
    { DLLINE, VDKRED, DKRED, DITHERSOLID, { 0, -64 }, { 32, -32 }, { 5, 0 } },
    { DLLINE, VDKRED, DKRED, DITHERSOLID, { 32, -64 }, { 0, -32 }, { 5, 0 } },
};

// ROAD SEGMENTS, DEFINING NUMBER OF SECTIONS BEFORE NEXT TURN, TURN ANGLE, AND SIDE OBJECTS
#define MAXSEGMENT 10
typedef struct {
    int     ct;
    float   tu;
    int     bgl;
    int     bgr;
} roadsegment;

roadsegment road[]={
    {10,0,TREE,TREE},
    {6,-.25,TREE,SIGN},
    {8,0,TREE,TREE},
    {4,.375,SIGN,TREE},
    {10,0.05,TREE,NONE},
    {4,0,TREE,TREE},
    {5,-.25,TREE,SIGN},
    {15,0,BEAMS,BEAMS},
    {12,0,HOUSE,HOUSE},
    {8,-.5,HOUSE,SIGN},
    {8,.5,SIGN,HOUSE}
};
int corner[MAXSEGMENT];

// VECTOR HELPERS FOR 2D to 3D PROJECTION
static inline float max(float x, float y) { return x>y?x:y; }
static inline float min(float x, float y) { return x<y?x:y; }

typedef struct { float x,y,z; }   vec3;
typedef struct { float x,y,z,w; } vec4;

static inline vec3 make_vec3(float x, float y, float z) {
  vec3 V;
  V.x = x; V.y = y; V.z = z;
  return V;
}

static inline vec4 make_vec4(float x, float y, float z, float w ) {
  vec4 V;
  V.x = x; V.y = y; V.z = z; V.w = w;
  return V;
}

// PROJECT - TO HORIZONTAL CENTRE OF THE SCREEN, MOVE SLIGHTLY DOWN FOR VERTICAL CENTRE
vec3 project( float x, float y, float z ) {
    float scale = 120/z;
    return( make_vec3( x * scale + 160, y * scale + 120, scale ) );
}

vec3 skew( float x, float y, float z, float xd, float yd ) {
    return( make_vec3( x+z*xd, y+z*yd, z ) );
}

int iterations = 0;
int camcnr = 0, camseg = 0;
float camx = 0, camy = 0, camz = 0;

void init( void ) {
    int sumct = 0;
    for( int i = 0; i < MAXSEGMENT; i++ ) {
        corner[i] = sumct;
        sumct += road[i].ct;
    }
}

void advance( int *cnr, int *seg ) {
    *seg = *seg + 1;
    if( *seg > road[ *cnr ].ct ) {
        *seg = 0;
        *cnr = *cnr + 1;
        if( *cnr > MAXSEGMENT ) {
            *cnr = 0;
        }
    }
}

void update() {
    camz += 0.1;
    if( camz > 1 ) {
        camz = 0;
        advance( &camcnr, &camseg );
    }
}

// NUMBER OF SEGMENTS TO DRAW EACH ITERATION
#define DRAWSEGMENTS 16
void drawtrapezium( unsigned char colour, float x1, float y1, float w1, float x2, float y2, float w2 ) {
    gpu_quadrilateral( colour, x1-w1, y1, x1+w1, y1, x2+w2, y2, x2-w2, y2 );
}

void drawroad( float x1, float y1, float scale1, float x2, float y2, float scale2, int sumct ) {
    float w1 = 3 * scale1, w2 = 3 * scale2;
    drawtrapezium( GREY1, x1, y1, w1, x2, y2, w2 );

    // CENTRE LINE MARKINGS
    if( !(sumct % 4 ) ) {
        float mw1 = .1 * scale1, mw2 = .1 * scale2;
        drawtrapezium( WHITE, x1, y1, mw1, x2, y2, mw2 );
    }

    // SHOULDER MARKINGS
    float sw1 = .2 * scale1, sw2 = .2 * scale2;
    drawtrapezium( (sumct%2) ? WHITE : RED, x1-w1, y1, sw1 ,x2-w2 , y2, sw2 );
    drawtrapezium( (sumct%2) ? WHITE : RED, x1+w1, y1, sw1, x2+w2, y2, sw2 );
}

void draw() {
    float camang = camz * road[camcnr].tu;
    float xd = -camang, yd = 0, zd = 1;
    float x, y, z;

    int cnr = camcnr, seg = camseg, sumct;
    vec3 c, p, pp;

    // SPRIATES TO DRAW, ALONG WITH
    int lsprites[ DRAWSEGMENTS ], rsprites[ DRAWSEGMENTS ];
    vec3 lspritesxyz[DRAWSEGMENTS], rspritesxyz[DRAWSEGMENTS];

    // SKEY CAMERA TO ACCOUNT FOR DIRECTION
    c = skew( camx, camy, camz, xd, yd );
    x = -c.x; y =-c.y+2; z = -c.z + 2;

    pp = project( x, y, z );

    gpu_cs();

    for( int i = 0; i < DRAWSEGMENTS; i++ ) {
        x += xd; y += yd; z += zd;
        p = project( x, y, z );
        sumct = corner[cnr] + seg - 1;
        drawroad( p.x, p.y, p.z, pp.x, pp.y, pp.z, sumct );

        // ATTEMPT TO LIMIT THE NUMBER OF BEAMS DRAWN, SINGLE BEAM AT THE START OF THE SECTION
        switch( road[cnr].bgl ) {
            case BEAMS:
                if( !seg ) {
                    lsprites[ i ] = road[cnr].bgl; lspritesxyz[i] = p;
                } else {
                    lsprites[ i ] = NONE;
                }
                break;
            default:
                lsprites[ i ] = road[cnr].bgl; lspritesxyz[i] = p;
        }
        switch( road[cnr].bgr ) {
            case BEAMS:
                if( !seg ) {
                    rsprites[ i ] = road[cnr].bgr; rspritesxyz[i] = p;
                } else {
                    rsprites[ i ] = NONE;
                }
                break;
            default:
                rsprites[ i ] = road[cnr].bgr; rspritesxyz[i] = p;
        }

        xd += road[cnr].tu;
        advance( &cnr, &seg );
        pp = p;
    }

    for( int i = DRAWSEGMENTS -1; i >= 0; i-- ) {
        // DRAW SPRITES IN REVERSE ORDER
        float scale = lspritesxyz[i].z / 36, offset = 3 * lspritesxyz[i].z + ( 32 * scale );
        switch( lsprites[i] ) {
            case TREE:
                DoDrawList2Dscale( PINETREE, 2, lspritesxyz[i].x - offset, lspritesxyz[i].y, scale );
                break;
            case SIGN:
                DoDrawList2Dscale( RIGHTCHEVRON, 4, lspritesxyz[i].x - offset, lspritesxyz[i].y, scale );
                break;
            case BEAMS:
                DoDrawList2Dscale( LEFTBEAM, 10, lspritesxyz[i].x - offset, lspritesxyz[i].y, scale );
                break;
            default:
        }
        switch( rsprites[i] ) {
            case TREE:
                DoDrawList2Dscale( PINETREE, 2, lspritesxyz[i].x + offset, lspritesxyz[i].y, scale );
                break;
            case SIGN:
                DoDrawList2Dscale( LEFTCHEVRON, 4, lspritesxyz[i].x + offset, lspritesxyz[i].y, scale );
                break;
            case BEAMS:
                DoDrawList2Dscale( RIGHTBEAM, 8, lspritesxyz[i].x + offset, lspritesxyz[i].y, scale );
                break;
            default:
        }
    }
}

void set_background_generator( void ) {
    set_copper_cpuinput( 16 );
    copper_startstop( 0 );
    copper_program( 0, COPPER_WAIT_VBLANK, 7, 0, BKG_HATCH, DKBLUE, BLUE );
    copper_program( 1, COPPER_WAIT_X, 7, 0, BKG_HATCH, DKBLUE, BLUE );
    copper_program( 2, COPPER_JUMP, COPPER_JUMP_IF_Y_LESS, COPPER_USE_CPU_INPUT, 0, 0, 1 );
    copper_program( 3, COPPER_WAIT_X, 7, 0, BKG_HATCH, DKGREEN, GREEN );
    copper_program( 4, COPPER_JUMP, COPPER_JUMP_ON_VBLANK_EQUAL, 0, 0, 0, 3 );
    copper_program( 5, COPPER_JUMP, COPPER_JUMP_ALWAYS, 0, 0, 0, 1 );
    copper_startstop( 1 );
    set_copper_cpuinput( 266 );
}

int main() {
    INITIALISEMEMORY;

    bitmap_draw( 0 ); gpu_cs();
    bitmap_draw( 1 ); gpu_cs();
    bitmap_display(0);
    set_background_generator();

    init();

    unsigned char framebuffer = 0;
    while( !( get_buttons() & 4 ) ) {
        bitmap_draw( !framebuffer );
        draw();
        update();
        framebuffer = !framebuffer;
        bitmap_display( framebuffer );
    }

}
