// https://www.lexaloffle.com/bbs/?tid=35767
#include "PAWSlibrary.h"
#include <math.h>

typedef struct { int ct; float tu; } roadsegment;
#define MAXSEGMENT 6
roadsegment road[]={
    {10,0},
    {6,-0.25},
    {8,0},
    {4,.375},
    {10,0.05},
    {4,0},
    {5,-0.25}
};

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
    return( make_vec3( x* scale + 64, y * scale + 64, scale ) );
}

vec3 skew( float x, float y, float z, float xd, float yd ) {
    return( make_vec3(x+z*xd,y+z*yd,z) );
}

float camcnr = 1, camseg = 1;
float camx = 0, camy = 0, camz = 0;

int main() {
    INITIALISEMEMORY();
    float camang = camz * road[ (int)camcnr ].tu;
    float xd = -camang, yd = 0, zd = 1;
    float cx = skew( camx, camy, camz, xd, yd ).x;;
    float cy = skew( camx, camy, camz, xd, yd ).y;;
    float cz = skew( camx, camy, camz, xd, yd ).z;;
    float x = -cx, y = -cy + 2, z = -cz + 2;
    float width;
    float cnr = camcnr, seg = camseg;
    vec3 p, pp;

    gpu_cs();
    pp = project( x, y, z );

    for( int i = 1; i < 30; i++ ) {
        // move forward
        x+=xd; y+=yd; z+=zd;

        p = project( x, y, z );

        // turn
        xd+=road[(int)cnr].tu;

        // advance along road
        seg++;
        if(seg>road[(int)cnr].ct) {
            seg=1;
            cnr++;
            if(cnr>MAXSEGMENT)cnr=1;
        }

        pp = p;
    }

    while(1) {}
}
