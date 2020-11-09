: array create cells allot does> cells + ;

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

4 4 1 40 15 tm!
4 5 2 40 15 tm!
5 4 3 40 15 tm!
5 5 4 40 15 tm!

12 e 1 40 14 tm!
12 f 2 40 14 tm!
13 e 3 40 14 tm!
13 f 4 40 14 tm!

22 1c 1 40 5 tm!
22 1d 2 40 5 tm!
23 1c 3 40 5 tm!
23 1d 4 40 5 tm!

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

variable lasttimer
variable shipdirection
variable bulletdirection
variable shipx
variable shipy
variable counter
variable score
variable lives

variable activelasteroids
variable activehasteroids

variable hitasteroid
variable workasteroid
variable spawnasteroid
variable workx
variable worky


c array lasteroidactive c array hasteroidactive
c array lasteroidtype c array hasteroidtype
c array lasteroiddirection c array hasteroiddirection

8 array bulletdirections
20 0 bulletdirections c! 32 1 bulletdirections c!
3 2 bulletdirections c! 12 3 bulletdirections c!
18 4 bulletdirections c! 16 5 bulletdirections c!
4 6 bulletdirections c! 36 7 bulletdirections c!

10 array updatedirections
20 0 updatedirections c! 3  1 updatedirections c!
18 2 updatedirections c! 4  3 updatedirections c!
39 4 updatedirections c! 9  5 updatedirections c!
f  6 updatedirections c! 3f 7 updatedirections c!
31 8 updatedirections c! 3a 9 updatedirections c!
a  a updatedirections c! 11 b updatedirections c!
17 c updatedirections c! e  d updatedirections c!
3e e updatedirections c! 37 f updatedirections c!

( set ship vector block )
1 0 0 0 0 vectorvertex!
1 5 a 0 1 vectorvertex!
1 0 6 0 2 vectorvertex!
1 -5 a 0 3 vectorvertex!
1 0 0 0 4 vectorvertex!

: shipspritedata
    0100 0100 0380 07c0 07c0 0fe0 0fe0 0fe0
    1ff0 1ff0 1ff0 3ff8 3ff8 7efc 783c 0000
    0001 001e 007e 07fe 1ffe fffc 7ffc 3ff8
    1ff8 07f8 03f8 01f0 01f0 00e0 0060 0020
    0000 6000 7800 7f00 7ff0 7ff8 3ff8 1fff
    3ff8 3ff8 7ff0 7ff0 7800 6000 0000 0000
    0020 0060 00e0 01f0 01f0 03f8 07f8 1ff8
    3ff8 7ffc fffc 1ffe 07fe 007e 001e 0001
    0000 3c1e 3f7e 1ffc 1ffc 0ff8 0ff8 0ff8
    07f0 07f0 07f0 03e0 03e0 01c0 0080 0080
    0400 0600 0700 0f80 0f80 1fc0 1fe0 1ff8
    1ffc 3ffe 3fff 7ff8 7fe0 7e00 7800 8000
    0000 0000 0006 001e 00fe 07fe 1ffc 3ffc
    fff8 3ffc 1ffc 07fe 00fe 001e 0006 0000
    8000 7800 7e00 7fe0 7ff8 3fff 3ffe 1ffc
    1ff8 1fe0 1fc0 0f80 0f80 0700 0600 0400 ;

: bulletspritedata
  2 0 do
    0000 0000 0000 0000 0000 0100 0100 07c0
    0100 0100 0000 0000 0000 0000 0000 0000
    0000 0000 0000 0000 0000 0440 0280 0100
    0280 0440 0000 0000 0000 0000 0000 0000
    0000 0000 0000 0000 0000 0100 0380 07c0
    0380 0100 0000 0000 0000 0000 0000 0000
    0000 0000 0000 0000 0000 0540 0380 07c0
    0380 0540 0000 0000 0000 0000 0000 0000
  loop ;

: setshipsprite
  shipspritedata b lsltile!
  shipspritedata b usltile! ;

: setbulletsprite
  bulletspritedata c lsltile!
  bulletspritedata c usltile! ;

: asteroidbitmap
  07f0 0ff8 1ffe 1fff 3fff ffff fffe fffc
  ffff 7fff 7fff 7ffe 3ffc 3ffc 0ff8 00f0
  1008 3c1c 7f1e ffff 7ffe 7ffe 3ff8 3ff0
  1ff8 0ff8 1ffc 7ffe ffff 7ffe 3dfc 1878
  0787 1f8e 0fde 67fc fffc fffe ffff 7fff
  7ffc 3ff8 3ffc 7ffe ffff fffe 3ffc 73f8
  1800 3f98 3ffc 1ffe 1ffe 1ffe 7ffe ffff
  ffff ffff fffe fffe 3ffc 1ff0 07c0 0180
  0ff0 1ffc 1ffe 3ffe 3fff 7fff 7fff ffff
  ffff fffe fffc 7ffc 3ffc 3ff0 3ff0 07e0
  0000 0000 0000 0180 03c0 03e0 07f8 07fc
  0ffc 1ffc 1ff8 0ff8 01f0 0000 0000 0000
  0600 0fe0 1ff8 3ffc 7ffe fffe 0fff 1fff
  1fff 3fff 7fff 7ffe 3e7c 3c38 3800 3000
  0020 4206 0006 1820 1800 0081 0400 4010
  0000 0300 0302 6010 6000 0000 0419 8018 ;

: newlevel
  c 0 do
    0 i lasteroidactive c!
    0 i hasteroidactive c!
    0 0 0 0 0 0 i lslsprite!
    0 0 0 0 0 0 i uslsprite!
  loop
  0 activelasteroids ! 0 activehasteroids !
  4 rng 1+ 0 do
    20 rng 20 + 280 rng a0 rng 7 rng 1 1
      activelasteroids @ lslsprite!
    4 rng 4 + activelasteroids @ lasteroiddirection c!
    1 activelasteroids @ lasteroidtype c!
    1 activelasteroids @ lasteroidactive c!
    1 activelasteroids +!
  loop
    20 rng 20 + d5 rng 1e0 rng 7 rng 1 1
      activelasteroids @ lslsprite!
    4 rng 4 + activelasteroids @ lasteroiddirection c!
    1 activelasteroids @ lasteroidtype c!
    1 activelasteroids @ lasteroidactive c!
    1+ activelasteroids +!
  4 rng 1+ 0 do
    20 rng 20 + 280 rng a0 rng 140 + 7 rng 1 1
      activehasteroids @ uslsprite!
    4 rng 4 + activehasteroids @ hasteroiddirection c!
    1 activehasteroids @ hasteroidtype !
    1 activehasteroids @ hasteroidactive c!
    1 activehasteroids +!
  loop
    20 rng 20 + d5 rng 1aa + 1e0 rng 7 rng 1 1
      activehasteroids @ uslsprite!
    4 rng 4 + activehasteroids @ hasteroiddirection c!
    1 activehasteroids @ hasteroidtype !
    1 activehasteroids @ hasteroidactive c!
    1 activehasteroids +! ;

: setup
  cs! tpucs! tmcs! 0 0 tpuxy!
  3f tpuforeground! 40 tpubackground!
  terminalhide!
  timer1hz! 0 lasttimer !
  2a 1 7 background!
  f 0 do
    0 0 0 0 0 0 i lslsprite!
    0 0 0 0 0 0 i uslsprite!
  loop

    4 4 1 40 15 tm!
    4 5 2 40 15 tm!
    5 4 3 40 15 tm!
    5 5 4 40 15 tm!
    12 e 1 40 14 tm!
    12 f 2 40 14 tm!
    13 e 3 40 14 tm!
    13 f 4 40 14 tm!
    22 1c 1 40 5 tm!
    22 1d 2 40 5 tm!
    23 1c 3 40 5 tm!
    23 1d 4 40 5 tm!
    24 2 5 40 2a tm!
    24 3 6 40 2a tm!
    25 2 7 40 2a tm!
    25 3 8 40 2a tm!
    6 1a 5 40 10 tm!
    6 1b 6 40 10 tm!
    7 1a 7 40 10 tm!
    7 1b 8 40 10 tm!

  0 score !
  3 lives !
  4 counter !
  0 shipdirection !
  138 shipx !
  e8 shipy !
  setshipsprite
  setbulletsprite
  3f 220 1d0 0 vector!
  3f 240 1d0 0 vector!
  3f 260 1d0 0 vector! ;

: setasteroidsprites
  b 0 do
    asteroidbitmap i lsltile!
    asteroidbitmap i usltile!
  loop ;

: finish
 terminalshow! ;
