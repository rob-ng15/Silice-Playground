// https://www.lexaloffle.com/bbs/?tid=35767
#include "PAWSlibrary.h"
#include <math.h>

typedef struct { int ct; float tu; } roadsegment;
#define MAXSEGMENT 6
roadsegment road[]={
    {10,0},
    {6,-1},
    {8,0},
    {4,1.5},
    {10,0.2},
    {4,0},
    {5,-1}
};

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
    return( make_vec3( x* scale + 160, y * scale + 120, scale ) );
}

void advance( int *cnr, int *seg ) {
    *seg = *seg + 1;
    if( *seg > road[ *cnr ].ct ) {
        *seg = 1;
        *cnr = *cnr + 1;
        if( *cnr > MAXSEGMENT ) {
            cnr = 0;
        }
    }
}

void update() {
    camz += 0.1;
    if( camz > 1 ) {
        camz -= 1;
        advance( &camcnr, &camseg );
    }
}

void draw() {
    float x = 0, y = 1, z = 1;
    float camang = camz * road[camcnr].tu;
    float xd = -camang, yd = 0, zd = 1;

    int cnr = camcnr, seg = camseg;
    float width;
    vec3 p;

    gpu_cs();

    for( int i = 1; i < 30; i++ ) {
        p = project( x, y, z );
        width = 3 * p.z;
        gpu_line( WHITE, p.x - width, p.y, p.x + width, p.y );

        x += xd;
        y += yd;
        z += zd;

        xd+=road[cnr].tu;
        advance( &cnr, &seg );
    }
}

int main() {
    INITIALISEMEMORY;
    while(1) {
        await_vblank();
        draw();
        update();
        sleep( 10, 0 );
    }

}
