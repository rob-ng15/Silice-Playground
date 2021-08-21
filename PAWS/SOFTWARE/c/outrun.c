// https://www.lexaloffle.com/bbs/?tid=35767
#include "PAWSlibrary.h"
#include <math.h>

typedef struct {
    int     ct;
    float   tu;
    int     bgl;
    int     bgr;
} roadsegment;

// DELAY BETWEEN FRAMES
#define DELAY 500

#define MAXSEGMENT 10
#define NONE 0
#define TREE 1
#define SIGN 2
#define HOUSE 3
#define BEAMS 4
roadsegment road[]={
    {10,0,TREE,TREE},
    {6,-.25,TREE,SIGN},
    {8,0,TREE,TREE},
    {4,.375,SIGN,TREE},
    {10,0.05,TREE},
    {4,0,TREE,TREE},
    {5,-.25,TREE,SIGN},
    {15,0,BEAMS,BEAMS},
    {12,0,HOUSE,HOUSE},
    {8,-.5,HOUSE,SIGN},
    {8,.5,SIGN,HOUSE}
};
int corner[MAXSEGMENT];

int iterations = 0;
int camcnr = 0, camseg = 0;
float camx = 0, camy = 0, camz = 0;

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

vec3 project( float x, float y, float z ) {
    float scale = 64/z;
    return( make_vec3( x * scale + 160, y * scale + 120, scale ) );
}

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
// SEGMENTS TO DRAW - IN FAST BRAM ABOVE SOFTWARE VECTOR BUFFER
vec3 *DRAWBUFFER = (vec3 *)0x1500;

void draw() {
    gpu_cs();

    for( int i = 0; i < DRAWSEGMENTS - 1; i++ ) {
        float width1 = 2 * DRAWBUFFER[ i + 1 ].z, width0 = 2 * DRAWBUFFER[ i ].z;

        gpu_triangle( i & 1 ? GREY1 : GREY2,
                           DRAWBUFFER[ i + 1 ].x - width1, DRAWBUFFER[ i + 1].y, DRAWBUFFER[ i + 1 ].x + width1, DRAWBUFFER[ i + 1].y,
                           DRAWBUFFER[ i ].x - width0, DRAWBUFFER[i].y );
        gpu_triangle( i & 1 ? GREY1 : GREY2,
                           DRAWBUFFER[ i + 1 ].x + width1, DRAWBUFFER[ i + 1].y,
                           DRAWBUFFER[ i ].x + width0, DRAWBUFFER[i].y, DRAWBUFFER[ i ].x - width0, DRAWBUFFER[i].y );
    }
}

void calculate() {
    float x = 0, y = 1, z = 1;
    float camang = camz * road[camcnr].tu;
    float xd = -camang, yd = 0, zd = 1;

    int cnr = camcnr, seg = camseg;
    float width;
    vec3 p;

    for( int i = 0; i < DRAWSEGMENTS; i++ ) {
        p = project( x, y, z );
        width = 2 * p.z;
        DRAWBUFFER[i] = p;

        x += xd;
        y += yd;
        z += zd;

        xd+=road[cnr].tu;
        advance( &cnr, &seg );
    }
}

int main() {
    INITIALISEMEMORY;
    init();

    while(1) {
        await_vblank();
        calculate(); draw();
        update();
        sleep( DELAY, 0 );
        iterations++;
    }

}
