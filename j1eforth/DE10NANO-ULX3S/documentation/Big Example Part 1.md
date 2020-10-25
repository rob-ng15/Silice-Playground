( variables and setup code)

( store timer1hz@ to generate a beep/boop every other second )
variable lasttimer

: array create cells allot does> cells + ;

( set tile map tiles )

: tmtile! ff96 ! 10 0 do
  f i - ff97 ! ff98 !
  loop ;

: tm! ff94 ! ff93 ! ff92 ! ff91 ! ff90 ! 1 ff95 ! ;

0000 0000 0000 0000 0000 0000 0000 0000
001f 003f 00ff 01ff 03ff 03ff 07ff 07fc
1 tmtile!

1ff1 37c7 279c 33f1 1fc7 011f 00ff 003f
0000 0000 0000 0000 0000 0000 0000 0000
2 tmtile!

0000 0000 0000 0000 0000 0000 0000 0000
c000 f000 f800 ff00 f900 e700 0c00 7400
3 tmtile!

c400 1c00 7c00 f800 f800 f000 e000 8000
0000 0000 0000 0000 0000 0000 0000 0000
4 tmtile!

4 4 1 40 21 tm!
4 5 2 40 21 tm!
5 4 3 40 21 tm!
5 5 4 40 21 tm!

22 e 1 40 20 tm!
22 f 2 40 20 tm!
23 e 3 40 20 tm!
23 f 4 40 20 tm!

1 1c 1 40 11 tm!
1 1d 2 40 11 tm!
2 1c 3 40 11 tm!
2 1d 4 40 11 tm!

0000 0000 0000 0000 0000 0000 0001 0003
007e 00c4 0088 0190 0110 0320 03f1 0003
5 tmtile!

0006 0005 0022 0008 0480 0024 0020 0090
0000 0040 0000 0010 0000 0000 0000 0000
6 tmtile!

0000 007e 07e2 1e02 7006 e604 8f0c 198c
1998 0f18 0630 0060 6060 d0c0 a180 4300
7 tmtile!

8600 0a00 3200 c200 8200 9c00 f000 c000
0000 0000 0000 0000 0000 0000 0000 0000
8 tmtile!

24 2 5 40 42 tm!
24 3 6 40 42 tm!
25 2 7 40 42 tm!
25 3 8 40 42 tm!

variable hitasteroid

( storage for 12 (c hex) low asteroids )
( storage for 12 (c hex) high asteroids )
c array lasteroidactive c array hasteroidactive
c array lasteroidtype c array hasteroidtype
c array lasteroiddirection c array hasteroiddirection

( directions table for the asteroid sprite update flag)
10 array updatedirections
30 0 updatedirections c! 2  1 updatedirections c!
10 2 updatedirections c! 6  3 updatedirections c!
39 4 updatedirections c! 9  5 updatedirections c!
f  6 updatedirections c! 3f 7 updatedirections c!
31 8 updatedirections c! 3a 9 updatedirections c!
a  a updatedirections c! 11 b updatedirections c!
17 c updatedirections c! e  d updatedirections c!
3e e updatedirections c! 37 f updatedirections c!

( store number of active asteroids )
variable activelasteroids
variable activehasteroids

( asteroid temporary )
variable workasteroid

( set ship vector block )
1 0 0 0 0 vectorvertex!
1 5 a 0 1 vectorvertex!
1 0 6 0 2 vectorvertex!
1 -5 a 0 3 vectorvertex!
1 0 0 0 4 vectorvertex!

: setshipsprite
  2 0 do
    0100 0100 0380 07c0 07c0 0fe0 0fe0 0fe0
    1ff0 1ff0 1ff0 3ff8 3ff8 7efc 783c 0000
    0000 6000 7800 7f00 7ff0 7ff8 3ff8 1fff
    3ff8 3ff8 7ff0 7ff0 7800 6000 0000 0000
    0000 3c1e 3f7e 1ffc 1ffc 0ff8 0ff8 0ff8
    07f0 07f0 07f0 03e0 03e0 01c0 0080 0080
    0000 0000 0006 001e 00fe 07fe 1ffc 3ffc
    fff8 3ffc 1ffc 07fe 00fe 001e 0006 0000
  loop d lsltile! d usltile! ;
  
: setbulletsprite
  2 0 do
    0000 0000 0000 0000 0000 0100 0100 07c0
    0100 0100 0000 0000 0000 0000 0000 0000
    0000 0000 0000 0000 0000 0440 0280 0100
    0280 0440 0000 0000 0000 0000 0000 0000
    0000 0000 0000 0000 0000 0100 0380 07c0
    0380 0100 0000 0000 0000 0000 0000 0000
    0000 0000 0000 0000 0000 0540 0380 07c0
    0380 0540 0000 0000 0000 0000 0000 0000
  loop e lsltile! e usltile! ;
  
: largeasteroidbitmap
  07f0 07f8 0ffe 0fff 3f0f ff6e 7f0c 3ffc
  1fff 3fff 7fff 7ffe 1ffc 07fc 01f8 00f0
  1008 3c1c 7f1e ffff 7ffe 7ffe 3ff8 3ff0
  1ff8 0ff8 1ffc 7ffe ffff 7ffe 3dfc 1878
  0787 1f8e 0fde 67fc fffc fffe ffff 7fff 
  7ffc 3ff8 3ffc 7ffe ffff fffe 3ffc 73f8 
  0020 4206 0006 1820 1800 0081 0400 4010
  0000 0300 0302 6010 6000 0000 0419 8018 ;  
  
: setlargelasteroid
  workasteroid !
  largeasteroidbitmap
  workasteroid @ lsltile! ;

  : setlargehasteroid
  workasteroid !
  largeasteroidbitmap
  workasteroid @ usltile! ;

( place initial large asteroids )
( always away from the centre )
( lower layer, top and left )
( upper layer, bottom and right )
( move single diagonal )
: placeasteroids
  ( clear asteroids )
  c 0 do
    0 i lasteroidactive c!
    0 i hasteroidactive c!
  loop
  0 activelasteroids ! 0 activehasteroids !
  4 rng 1+ 0 do
    3f 20 + 280 rng a0 rng 3 rng 1 1
      activelasteroids @ lslsprite!
    4 rng 4 + activelasteroids @ lasteroiddirection c!
    activelasteroids @ setlargelasteroid
    1 activelasteroids @ lasteroidtype c!
    1 activelasteroids @ lasteroidactive c!
    activelasteroids @ 1+ activelasteroids !
  loop
    3f 20 + d5 rng 1e0 rng 3 rng 1 1
      activelasteroids @ lslsprite!
    4 rng 4 + activelasteroids @ lasteroiddirection c!
    activelasteroids @ setlargelasteroid
    1 activelasteroids @ lasteroidtype c!
    1 activelasteroids @ lasteroidactive c!
    activelasteroids @ 1+ activelasteroids !
  4 rng 1+ 0 do
    3c 20 + 280 rng a0 rng 140 + 3 rng 1 1
      activehasteroids @ uslsprite!
    4 rng 4 + activehasteroids @ hasteroiddirection c!
    activehasteroids @ setlargehasteroid
    1 activehasteroids @ hasteroidtype !
    1 activehasteroids @ hasteroidactive c!
    activehasteroids @ 1+ activehasteroids !
  loop
    3c 20 + d5 rng 1aa + 1e0 rng 3 rng 1 1
      activehasteroids @ uslsprite!
    4 rng 4 + activehasteroids @ hasteroiddirection c!
    activehasteroids @ setlargehasteroid
    1 activehasteroids @ hasteroidtype !
    1 activehasteroids @ hasteroidactive c!
    activehasteroids @ 1+ activehasteroids ! ;

: setup
  ( clear the screen )
  cs! tpucs! 0 0 tpuxy!
  3f tpuforeground! 40 tpubackground!
  ( hide the terminal )
  terminalhide!
  ( reset the second timer )
  timer1hz! 0 lasttimer !
  ( set the background )
  2a 1 7 background!
  ( hide all sprites )
  f 0 do 
    0 0 0 0 0 0 i lslsprite!
    0 0 0 0 0 0 i uslsprite!
  loop
  setshipsprite
  setbulletsprite
  placeasteroids 
  ( draw lives )
  3f 220 1d0 0 vector!
  3f 240 1d0 0 vector!
  3f 260 1d0 0 vector! ;

: finish
 terminalshow! ;
