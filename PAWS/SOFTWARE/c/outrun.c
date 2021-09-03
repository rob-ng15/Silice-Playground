// PSEUDO 3D RACER BASED UPON:
// https://www.lexaloffle.com/bbs/?tid=35767

#include "PAWSlibrary.h"
#include <math.h>
#include <stdio.h>

// ROADSIDE ITEMS - AS DRAWLISTS FOR EASIER PLACEMENT AND SCALING
#define NONE 0
#define TREE 1
#define SIGN 2
#define BILLBOARD 3
#define BILLBOARD1 4
#define BILLBOARD2 5
#define BILLBOARD3 6
#define BILLBOARD4 7
#define BEAMS 8
#define TALLBEAM 9
#define SMALLBEAM 10

struct DrawList2D LEFTCHEVRON[] = {
    { DLRECT, GREY2, DITHERSOLID, { -4, 0 }, { 4, -32 }, },
    { DLRECT, BLACK, DITHERSOLID, { -32, -32 }, { 32, -64 }, },
    { DLQUAD, WHITE, DITHERSOLID, { -16, -48 }, { 0, -48 }, { 8, -32 }, { -8, -32 } },
    { DLQUAD, WHITE, DITHERSOLID, { -8, -64 }, { 8, -64 }, { 0, -48 }, { -16, -48 } },
};
struct DrawList2D RIGHTCHEVRON[] = {
    { DLRECT, GREY2, DITHERSOLID, { -4, 0 }, { 4, -32 }, },
    { DLRECT, BLACK, DITHERSOLID, { -32, -32 }, { 32, -64 }, },
    { DLQUAD, WHITE, DITHERSOLID, { 0, -48 }, { 16, -48 }, { 8, -32 }, { -8, -32 } },
    { DLQUAD, WHITE, DITHERSOLID, { -8, -64 }, { 8, -64 }, { 16, -48 }, { 0, -48 } },
};

struct DrawList2D PINETREE[] = {
    { DLRECT, BROWN, DKBROWN, DITHERCHECK1, { -8, 0 }, { 8, -32 }, },
    { DLTRI, VDKGREEN, DITHERSOLID, { 0, -96 }, { 32, -32 }, { -32, -32 } },
};

struct DrawList2D LEFTBEAM[] = {
    { DLRECT, DKORANGE, DITHERSOLID, { -4, 0 }, { 4, -128 } },
    { DLRECT, DKORANGE, DITHERSOLID, { -36, 0 }, { -28, -128 } },
    { DLRECT, DKORANGE, DITHERSOLID, { -36, -124 }, { 160, -132 } },
    { DLLINE, DKRED, DITHERSOLID, { 0, -128 }, { -32, -96 }, { 5, 0 } },
    { DLLINE, DKRED, DITHERSOLID, { -32, -128 }, { 0, -96 }, { 5, 0 } },
    { DLLINE, DKRED, DITHERSOLID, { 0, -64 }, { -32, -32 }, { 5, 0 } },
    { DLLINE, DKRED, DITHERSOLID, { -32, -64 }, { 0, -32 }, { 5, 0 } },
    { DLRECT, BLACK, DITHERSOLID, { 112, -136}, { 96, -120 }, },
    { DLTRI, GREEN, DITHERSOLID, { 95, -128 }, { 111, -128 }, { 103, -121 } },
    { DLLINE, GREEN, DITHERSOLID, { 103, -128 }, { 103, -135 }, { 3, 0 } }
};

struct DrawList2D LEFTBEAMSMALL[] = {
    { DLRECT, DKORANGE, DITHERSOLID, { -4, 0 }, { 4, -32 } },
};

struct DrawList2D RIGHTBEAM[] = {
    { DLRECT, BLACK, DITHERSOLID, { -112, -136 }, { -96, -120 }, },
    { DLRECT, DKORANGE, DITHERSOLID, { -4, 0 }, { 4, -128 } },
    { DLRECT, DKORANGE, DITHERSOLID, { 28, 0 }, { 36, -128 } },
    { DLRECT, DKORANGE, DITHERSOLID, { -160, -124 }, { 36, -132 } },
    { DLLINE, DKRED, DITHERSOLID, { 0, -128 }, { 32, -96 }, { 5, 0 } },
    { DLLINE, DKRED, DITHERSOLID, { 32, -128 }, { 0, -96 }, { 5, 0 } },
    { DLLINE, DKRED, DITHERSOLID, { 0, -64 }, { 32, -32 }, { 5, 0 } },
    { DLLINE, DKRED, DITHERSOLID, { 32, -64 }, { 0, -32 }, { 5, 0 } },
};

struct DrawList2D RIGHTBEAMSMALL[] = {
    { DLRECT, DKORANGE, DITHERSOLID, { -4, 0 }, { 4, -32 } },
};

// BILLBOARD - 4 DESIGNS, TO BE DISPLAYED IN ORDER
struct DrawList2D LEFTBILLBOARD1[] = {
    { DLRECT, 0x2f, DITHERSOLID, { 0, 0 }, { -128, -96 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 0, 0 }, { 0, -96 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 0, -96 }, { -128, -96 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { -128, -96 }, { -128, 0 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { -128, 0 }, { 0, 0 }, { 3, 0 }, },
    { DLCIRC, YELLOW, DITHERSOLID, { -92, -48 }, { 32, 0b11111001 }, },
    { DLCIRC, WHITE, DITHERSOLID, { -60, -48 }, { 8, 0xff }, }
};
struct DrawList2D LEFTBILLBOARD2[] = {
    { DLRECT, 0x2f, DITHERSOLID, { 0, 0 }, { -128, -96 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 0, 0 }, { 0, -96 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 0, -96 }, { -128, -96 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { -128, -96 }, { -128, 0 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { -128, 0 }, { 0, 0 }, { 3, 0 }, },
    { DLRECT, RED, DITHERSOLID, { -40, -30 }, { -88, -66 }, },
    { DLCIRC, RED, DITHERSOLID, { -64, -66 }, { 24, 0b11000011 }, },
    { DLCIRC, RED, DITHERSOLID, { -80, -30 }, { 8, 0b00111100 }, },
    { DLCIRC, RED, DITHERSOLID, { -64, -30 }, { 8, 0b00111100 }, },
    { DLCIRC, RED, DITHERSOLID, { -48, -30 }, { 8, 0b00111100 }, },
    { DLCIRC, WHITE, DITHERSOLID, { -80, -56 }, { 8, 0xff }, },
    { DLCIRC, BLUE, DITHERSOLID, { -80, -56 }, { 4, 0xff }, },
    { DLCIRC, WHITE, DITHERSOLID, { -48, -56 }, { 8, 0xff }, },
    { DLCIRC, BLUE, DITHERSOLID, { -48, -56 }, { 4, 0xff }, },
};
struct DrawList2D LEFTBILLBOARD3[] = {
    { DLRECT, 0x2f, DITHERSOLID, { 0, 0 }, { -128, -96 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 0, 0 }, { 0, -96 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 0, -96 }, { -128, -96 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { -128, -96 }, { -128, 0 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { -128, 0 }, { 0, 0 }, { 3, 0 }, },
    { DLCIRC, YELLOW, DITHERSOLID, { -60, -48 }, { 32, 0xff }, },
};
struct DrawList2D LEFTBILLBOARD4[] = {
    { DLRECT, 0x2f, DITHERSOLID, { 0, 0 }, { -128, -96 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 0, 0 }, { 0, -96 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 0, -96 }, { -128, -96 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { -128, -96 }, { -128, 0 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { -128, 0 }, { 0, 0 }, { 3, 0 }, },
    { DLRECT, DKBLUE, DITHERSOLID, { -40, -30 }, { -88, -66 }, },
    { DLCIRC, DKBLUE, DITHERSOLID, { -64, -66 }, { 24, 0b11000011 }, },
    { DLCIRC, DKBLUE, DITHERSOLID, { -80, -30 }, { 8, 0b00111100 }, },
    { DLCIRC, DKBLUE, DITHERSOLID, { -64, -30 }, { 8, 0b00111100 }, },
    { DLCIRC, DKBLUE, DITHERSOLID, { -48, -30 }, { 8, 0b00111100 }, },
    { DLARC, PINK, DITHERSOLID, { -80, -39 }, { 4, 0b11000011 }, },
    { DLARC, PINK, DITHERSOLID, { -72, -39 }, { 4, 0b00111100 }, },
    { DLARC, PINK, DITHERSOLID, { -64, -39 }, { 4, 0b11000011 }, },
    { DLARC, PINK, DITHERSOLID, { -56, -39 }, { 4, 0b00111100 }, },
    { DLARC, PINK, DITHERSOLID, { -48, -39 }, { 4, 0b11000011 }, },
    { DLLINE, PINK, DITHERSOLID, { -84, -52 }, { -76, -60 }, { 1, 0 }, },
    { DLLINE, PINK, DITHERSOLID, { -84, -60 }, { -76, -52 }, { 1, 0 }, },
    { DLLINE, PINK, DITHERSOLID, { -52, -52 }, { -44, -60 }, { 1, 0 }, },
    { DLLINE, PINK, DITHERSOLID, { -52, -60 }, { -44, -52 }, { 1, 0 }, },
};

struct DrawList2D RIGHTBILLBOARD1[] = {
    { DLRECT, 0x2f, DITHERSOLID, { 0, 0 }, { 128, -96 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 0, 0 }, { 0, -96 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 0, -96 }, { 128, -96 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 128, -96 }, { 128, 0 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 128, 0 }, { 0, 0 }, { 3, 0 }, },
    { DLCIRC, YELLOW, DITHERSOLID, { 92, -48 }, { 32, 0b10011111 }, },
    { DLCIRC, WHITE, DITHERSOLID, { 60, -48 }, { 8, 0xff }, }
};
struct DrawList2D RIGHTBILLBOARD2[] = {
    { DLRECT, 0x2f, DITHERSOLID, { 0, 0 }, { 128, -96 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 0, 0 }, { 0, -96 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 0, -96 }, { 128, -96 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 128, -96 }, { 128, 0 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 128, 0 }, { 0, 0 }, { 3, 0 }, },
    { DLRECT, PEACH, DITHERSOLID, { 40, -30 }, { 88, -66 }, },
    { DLCIRC, PEACH, DITHERSOLID, { 64, -66 }, { 24, 0b11000011 }, },
    { DLCIRC, PEACH, DITHERSOLID, { 80, -30 }, { 8, 0b00111100 }, },
    { DLCIRC, PEACH, DITHERSOLID, { 64, -30 }, { 8, 0b00111100 }, },
    { DLCIRC, PEACH, DITHERSOLID, { 48, -30 }, { 8, 0b00111100 }, },
    { DLCIRC, WHITE, DITHERSOLID, { 80, -56 }, { 8, 0xff }, },
    { DLCIRC, BLUE, DITHERSOLID, { 80, -56 }, { 4, 0xff }, },
    { DLCIRC, WHITE, DITHERSOLID, { 48, -56 }, { 8, 0xff }, },
    { DLCIRC, BLUE, DITHERSOLID, { 48, -56 }, { 4, 0xff }, },
};
struct DrawList2D RIGHTBILLBOARD3[] = {
    { DLRECT, 0x2f, DITHERSOLID, { 0, 0 }, { 128, -96 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 0, 0 }, { 0, -96 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 0, -96 }, { 128, -96 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 128, -96 }, { 128, 0 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 128, 0 }, { 0, 0 }, { 3, 0 }, },
    { DLCIRC, YELLOW, DITHERSOLID, { 60, -48 }, { 32, 0xff }, }
};
struct DrawList2D RIGHTBILLBOARD4[] = {
    { DLRECT, 0x2f, DITHERSOLID, { 0, 0 }, { 128, -96 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 0, 0 }, { 0, -96 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 0, -96 }, { 128, -96 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 128, -96 }, { 128, 0 }, { 3, 0 }, },
    { DLLINE, LTCYAN, DITHERSOLID, { 128, 0 }, { 0, 0 }, { 3, 0 }, },
    { DLRECT, DKBLUE, DITHERSOLID, { 40, -30 }, { 88, -66 }, },
    { DLCIRC, DKBLUE, DITHERSOLID, { 64, -66 }, { 24, 0b11000011 }, },
    { DLCIRC, DKBLUE, DITHERSOLID, { 80, -30 }, { 8, 0b00111100 }, },
    { DLCIRC, DKBLUE, DITHERSOLID, { 64, -30 }, { 8, 0b00111100 }, },
    { DLCIRC, DKBLUE, DITHERSOLID, { 48, -30 }, { 8, 0b00111100 }, },
    { DLARC, PINK, DITHERSOLID, { 80, -39 }, { 4, 0b11000011 }, },
    { DLARC, PINK, DITHERSOLID, { 72, -39 }, { 4, 0b00111100 }, },
    { DLARC, PINK, DITHERSOLID, { 64, -39 }, { 4, 0b11000011 }, },
    { DLARC, PINK, DITHERSOLID, { 56, -39 }, { 4, 0b00111100 }, },
    { DLARC, PINK, DITHERSOLID, { 48, -39 }, { 4, 0b11000011 }, },
    { DLLINE, PINK, DITHERSOLID, { 84, -52 }, { 76, -60 }, { 1, 0 }, },
    { DLLINE, PINK, DITHERSOLID, { 84, -60 }, { 76, -52 }, { 1, 0 }, },
    { DLLINE, PINK, DITHERSOLID, { 52, -52 }, { 44, -60 }, { 1, 0 }, },
    { DLLINE, PINK, DITHERSOLID, { 52, -60 }, { 44, -52 }, { 1, 0 }, },
};

// ROAD SEGMENTS, DEFINING NUMBER OF SECTIONS BEFORE NEXT TURN, TURN ANGLE, AND SIDE OBJECTS
#define MAXSEGMENT 17
typedef struct {
    int     ct;
    float   tu;
    float   pi;
    int     tnl;
    int     bgl;
    int     bgr;
} roadsegment;

roadsegment road[]={
    {10,0,0,0,TREE,TREE},
    {6,-.25,0,0,TREE,SIGN},
    {8,0,-0.75,0,TREE,TREE},

    { 4,0,0,1, NONE, NONE },
    { 8,0,0.75,1, NONE, NONE },
    { 8,-0.50,0.75,1, NONE, NONE },
    { 4,0,0,1, NONE, NONE },
    { 8,0.5,0,1, NONE, NONE },
    { 4,0,-0.5,1,NONE, NONE },
    { 8,0,-0.5,1, NONE, NONE },

    {4,.375,0,0,SIGN,TREE},
    {10,0.05,0.75,0,TREE,NONE},
    {4,0,0,0,TREE,TREE},
    {5,-.25,0,0,TREE,SIGN},
    {15,0,-0.5,0,BEAMS,BEAMS},
    {12,0,0,0,BILLBOARD,BILLBOARD},
    {8,-.5,0,0,BILLBOARD,SIGN},
    {8,.5,0,0,SIGN,BILLBOARD}
};
int corner[MAXSEGMENT]; float pitch[MAXSEGMENT], slope[MAXSEGMENT];

// VECTOR HELPERS FOR 2D to 3D PROJECTION
#define min(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a < _b ? _a : _b; })
#define max(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a > _b ? _a : _b; })

typedef struct { float x,y,z; }   vec3;
typedef struct { short x,y,z; }   ivec3;
typedef struct { float x,y,z,w; } vec4;
typedef struct { short x,y,z,w; } ivec4;

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
    int sumct = 0; float pi, nextpi, dpi;
    for( int i = 0; i < MAXSEGMENT; i++ ) {
        corner[i] = sumct; sumct += road[i].ct;
        pi = road[i].pi; nextpi = road[ i%MAXSEGMENT + 1 ].pi;
        pitch[i] = pi; slope[i] = ( nextpi - pi ) / road[i].ct;
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
#define DRAWSEGMENTS 30
void drawtrapezium( unsigned char colour, short x1, short y1, short w1, short x2, short y2, short w2 ) {
    gpu_quadrilateral( colour, x1-w1, y1, x1+w1, y1, x2+w2, y2, x2-w2, y2 );
}

void gettunnelrectangle( float px, float py, float scale, short *x1, short *y1, short *x2, short *y2 )  {
    short w = 6.4 * scale, h = 4 * scale;
    *x1 = px - w/2;
    *y1 = py -h;
    *x2 = px + w/2;
    *y2 = py;
}

void drawtunnelface( float px, float py, float scale ) {
    short x1, y1, x2, y2;
    gettunnelrectangle( px, py, scale, &x1, &y1, &x2, &y2 );
    short wh = 4.5 * scale, wy = py - wh;
    gpu_dither( DITHERBRICK, BROWN );
    if( y1 > 0 ) gpu_rectangle( DKBROWN, 0, wy, 319, y1 - 1 );
    if( x1 > 0 ) gpu_rectangle( DKBROWN, 0, y1, x1 -1, y2 - 1 );
    if( x2 < 319 ) gpu_rectangle( DKBROWN, x2, y1, 319, y2 - 1 );
    gpu_dither( DITHEROFF );
}

void drawroad( float x1, float y1, float scale1, float x2, float y2, float scale2, int sumct ) {
    short w1 = 3 * scale1, w2 = 3 * scale2;
    drawtrapezium( GREY1, x1, y1, w1, x2, y2, w2 );

    // CENTRE LINE MARKINGS
    if( !(sumct % 4 ) ) {
        short mw1 = .1 * scale1, mw2 = .1 * scale2;
        drawtrapezium( WHITE, x1, y1, mw1, x2, y2, mw2 );
    }

    // SHOULDER MARKINGS AND GRASS
    short sw1 = .2 * scale1, sw2 = .2 * scale2;
    drawtrapezium( (sumct%2) ? WHITE : RED, x1-w1, y1, sw1 ,x2-w2 , y2, sw2 );
    drawtrapezium( (sumct%2) ? WHITE : RED, x1+w1, y1, sw1, x2+w2, y2, sw2 );
}

void draw() {
    float camang = camz * road[camcnr].tu;
    float xd = -camang, yd = road[camcnr].pi + slope[camcnr]*(camseg-1), zd = 1;
    float x, y, z;

    int cnr = camcnr, seg = camseg, sumct;
    vec3 c, p, pp;

    // SPRIATES TO DRAW, ALONG WITH
    int lsprites[ DRAWSEGMENTS ], rsprites[ DRAWSEGMENTS ];
    vec3 spritesxyz[DRAWSEGMENTS];
    short spriteclip[DRAWSEGMENTS][4];

    // SKEY CAMERA TO ACCOUNT FOR DIRECTION
    c = skew( camx, camy, camz, xd, yd );
    x = -c.x; y =-c.y+2; z = -c.z + 2;

    // CROPPING RECTANGLE
    short crop[4] = { CROPFULLSCREEN }; gpu_crop( CROPFULLSCREEN ); gpu_cs();
    short x1, y1, x2, y2, px1, py1, px2, py2;

    pp = project( x, y, z );

    int ptnl = road[cnr ].tnl, tnl;

    for( int i = 0; i < DRAWSEGMENTS; i++ ) {
        x += xd; y += yd; z += zd;
        p = project( x, y, z );

        tnl = road[cnr].tnl;
        if( tnl && !ptnl ) {
            drawtunnelface( pp.x, pp.y, pp.z );
            gettunnelrectangle( pp.x, pp.y, pp.z, &x1, &y1, &x2, &y2 );
            crop[0] = max( crop[0], x1 );
            crop[1] = max( crop[1], y1 );
            crop[2] = min( crop[2], x2 );
            crop[3] = min( crop[3], y2 );
            gpu_crop( crop[0], crop[1], crop[2], crop[3] );
        }

        sumct = corner[cnr] + seg - 1;
        if( tnl ) {
            unsigned char wallcol = ( sumct % 4 < 2 ) ? VDKBLUE : BLACK;
            gettunnelrectangle( p.x, p.y, p.z, &x1, &y1, &x2, &y2 );
            gettunnelrectangle( pp.x, pp.y, pp.z, &px2, &py1, &px2, &py2 );
            if( y1 > py1 ) gpu_rectangle( wallcol, px1, py1, px2-1, y1-1 );
            if( x1 > px1 ) gpu_rectangle( wallcol, px1, y1,x1-1,py2-1 );
            if( x2 < px2 ) gpu_rectangle( wallcol, x2, y1, px2-1,py2-1 );
        }
        drawroad( p.x, p.y, p.z, pp.x, pp.y, pp.z, sumct );

        // ADD BACKGROUND GRAPHICS, BEAMS ONLY AT START OF SECTION, SIGNS EVERY OTHER GAP, BILLBOARDS EVERY 4th GAP
        spriteclip[i][0] = crop[0]; spriteclip[i][1] = crop[1]; spriteclip[i][2] = crop[2]; spriteclip[i][3] = crop[3]; spritesxyz[i] = p;
        lsprites[i] = NONE; rsprites[i] = NONE;
        switch( road[cnr].bgl ) {
            case BEAMS:
                lsprites[ i ] = ( !seg ) ? TALLBEAM : SMALLBEAM;
                break;
            case SIGN:
                if( seg & 1 ) {
                   lsprites[ i ] = road[cnr].bgl;
                }
                break;
            case BILLBOARD:
                if( !( seg & 3 ) ) {
                    lsprites[ i ] = BILLBOARD1 + ((seg&12)>>2);
                }
                break;
            default:
                lsprites[ i ] = road[cnr].bgl;
        }
        switch( road[cnr].bgr ) {
            case BEAMS:
                rsprites[ i ] = ( !seg ) ? TALLBEAM : SMALLBEAM;
                break;
            case SIGN:
                if( seg & 1 ) {
                   rsprites[ i ] = road[cnr].bgr;
                }
                break;
            case BILLBOARD:
                if( !( seg & 3 ) ) {
                    rsprites[ i ] = BILLBOARD1 + ((seg&12)>>2);
                }
                break;
            default:
                rsprites[ i ] = road[cnr].bgr;
        }

        xd += road[cnr].tu; yd += slope[cnr];
        advance( &cnr, &seg );
        pp = p;
        ptnl = tnl;

        if( tnl ) {
            gettunnelrectangle( p.x, p.y, p.z, &x1, &y1, &x2, &y2 );
            crop[0] = max( crop[0], x1 );
            crop[1] = max( crop[1], y1 );
            crop[2] = min( crop[2], x2 );
            crop[3] = min( crop[3], y2 );
        } else {
            crop[3] = min( crop[3], p.y );
        }
        gpu_crop( crop[0], crop[1], crop[2], crop[3] );
    }

    for( int i = DRAWSEGMENTS -1; i >= 0; i-- ) {
        // DRAW SPRITES IN REVERSE ORDER
        float scale = spritesxyz[i].z / 36, offset = 3 * spritesxyz[i].z + ( 32 * scale );
        gpu_crop( spriteclip[i][0], spriteclip[i][1], spriteclip[i][2], spriteclip[i][3] );
        switch( lsprites[i] ) {
            case TREE:
                DoDrawList2Dscale( PINETREE, 2, spritesxyz[i].x - offset, spritesxyz[i].y, scale );
                break;
            case SIGN:
                DoDrawList2Dscale( RIGHTCHEVRON, 4, spritesxyz[i].x - offset, spritesxyz[i].y, scale );
                break;
            case TALLBEAM:
                DoDrawList2Dscale( LEFTBEAM, 10, spritesxyz[i].x - offset, spritesxyz[i].y, scale );
                break;
            case SMALLBEAM:
                    DoDrawList2Dscale( LEFTBEAMSMALL, 1, spritesxyz[i].x - offset, spritesxyz[i].y, scale );
                 break;
            case BILLBOARD1:
                DoDrawList2Dscale( LEFTBILLBOARD1, 7, spritesxyz[i].x - offset, spritesxyz[i].y, scale );
                break;
            case BILLBOARD2:
                DoDrawList2Dscale( LEFTBILLBOARD2, 14, spritesxyz[i].x - offset, spritesxyz[i].y, scale );
                break;
            case BILLBOARD3:
                DoDrawList2Dscale( LEFTBILLBOARD3, 6, spritesxyz[i].x - offset, spritesxyz[i].y, scale );
                break;
            case BILLBOARD4:
                DoDrawList2Dscale( LEFTBILLBOARD4, 19, spritesxyz[i].x - offset, spritesxyz[i].y, scale );
                break;
            default:
        }
        switch( rsprites[i] ) {
            case TREE:
                DoDrawList2Dscale( PINETREE, 2, spritesxyz[i].x + offset, spritesxyz[i].y, scale );
                break;
            case SIGN:
                DoDrawList2Dscale( LEFTCHEVRON, 4, spritesxyz[i].x + offset, spritesxyz[i].y, scale );
                break;
            case TALLBEAM:
                DoDrawList2Dscale( RIGHTBEAM, 8, spritesxyz[i].x + offset, spritesxyz[i].y, scale );
                break;
            case SMALLBEAM:
                DoDrawList2Dscale( RIGHTBEAMSMALL, 1, spritesxyz[i].x + offset, spritesxyz[i].y, scale );
                break;
            case BILLBOARD1:
                DoDrawList2Dscale( RIGHTBILLBOARD1, 7, spritesxyz[i].x + offset, spritesxyz[i].y, scale );
                break;
            case BILLBOARD2:
                DoDrawList2Dscale( RIGHTBILLBOARD2, 14, spritesxyz[i].x + offset, spritesxyz[i].y, scale );
                break;
            case BILLBOARD3:
                DoDrawList2Dscale( RIGHTBILLBOARD3, 6, spritesxyz[i].x + offset, spritesxyz[i].y, scale );
                break;
            case BILLBOARD4:
                DoDrawList2Dscale( RIGHTBILLBOARD4, 19, spritesxyz[i].x + offset, spritesxyz[i].y, scale );
                break;
            default:
        }
    }

    set_copper_cpuinput( 2 * crop[3] );
}

void set_background_generator( void ) {
    copper_startstop( 0 );
    copper_program( 0, COPPER_WAIT_VBLANK, 7, 0, BKG_HATCH, DKBLUE, BLUE );
    copper_program( 1, COPPER_WAIT_X, 7, 0, BKG_HATCH, DKBLUE, BLUE );
    copper_program( 2, COPPER_JUMP, COPPER_JUMP_IF_Y_LESS, COPPER_USE_CPU_INPUT, 0, 0, 1 );
    copper_program( 3, COPPER_WAIT_X, 7, 0, BKG_HATCH, DKGREEN, GREEN );
    copper_program( 4, COPPER_JUMP, COPPER_JUMP_ON_VBLANK_EQUAL, 0, 0, 0, 3 );
    copper_program( 5, COPPER_JUMP, COPPER_JUMP_ALWAYS, 0, 0, 0, 1 );
    copper_startstop( 1 );
}

int main() {
    INITIALISEMEMORY;

    // SETUP SCREEN
    bitmap_draw( 0 ); gpu_cs();
    bitmap_draw( 1 ); gpu_cs();
    bitmap_display(0);
    set_background_generator();

    // PREPARE ROAD
    init();

    unsigned char framebuffer = 0;
    while( !( get_buttons() & 4 ) ) {
        bitmap_draw( !framebuffer );
        draw();
        update();
        if( !(systemclock()&15) ) {
            tpu_print_centre( 1, TRANSPARENT, WHITE, 1, "Based upon https://www.lexaloffle.com/bbs/?tid=35767" );
            tpu_print_centre( 2, TRANSPARENT, WHITE, 1, "Written by @tommulgrew" );
        } else {
            if( systemclock()&3 ) tpu_cs();
        }
        framebuffer = !framebuffer;
        bitmap_display( framebuffer );
    }
}
