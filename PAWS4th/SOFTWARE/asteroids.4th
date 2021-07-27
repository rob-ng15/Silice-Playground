( asteroids game for testing )
( not ported as of yet )

#INCLUDE/audio.4th
#INCLUDE/display.4th
#INCLUDE/gpu.4th
#INCLUDE/sprites.4th
#INCLUDE/tiles.4th
#INCLUDE/timers.4th
#INCLUDE/tpu.4th

: array create cells allot does> cells + ;

hex

0000 0000 0000 0000
0000 0000 0000 0000
001f 003f 00ff 01ff
03ff 03ff 07ff 07fc
1 tmltile!

1ff1 37c7 279c 33f1
1fc7 011f 00ff 003f
0000 0000 0000 0000
0000 0000 0000 0000
2 tmltile!

0000 0000 0000 0000
0000 0000 0000 0000
c000 f000 f800 ff00
f900 e700 0c00 7400
3 tmltile!

c400 1c00 7c00 f800
f800 f000 e000 8000
0000 0000 0000 0000
0000 0000 0000 0000
4 tmltile!

0000 0000 0000 0000
0000 0000 0001 0003
007e 00c4 0088 0190
0110 0320 03f1 0003
1 tmutile!

0006 0005 0022 0008
0480 0024 0020 0090
0000 0040 0000 0010
0000 0000 0000 0000
2 tmutile!

0000 007e 07e2 1e02
7006 e604 8f0c 198c
1998 0f18 0630 0060
6060 d0c0 a180 4300
3 tmutile!

8600 0a00 3200 c200
8200 9c00 f000 c000
0000 0000 0000 0000
0000 0000 0000 0000
4 tmutile!

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
variable totalasteroids

variable hitasteroid
variable workasteroid
variable spawnasteroid
variable workx
variable worky

c array lasteroidactive
c array hasteroidactive
c array lasteroidtype
c array hasteroidtype
c array lasteroiddirection
c array hasteroiddirection

8 array bulletdirections
1f40 0 bulletdirections !
1f84 1 bulletdirections !
1c60 2 bulletdirections !
1c84 3 bulletdirections !
1cc0 4 bulletdirections !
1c96 5 bulletdirections !
1c1a 6 bulletdirections !
1f96 7 bulletdirections !

c array updatedirections
3e1 0 updatedirections !
21  1 updatedirections !
3f 2 updatedirections !
3ff  3 updatedirections !
3c1 4 updatedirections !
3e2  5 updatedirections !
22  6 updatedirections !
41 7 updatedirections !
5f 8 updatedirections !
3e 9 updatedirections !
3fe  a updatedirections !
3df b updatedirections !

( set ship vector block )
( 1 0 0 0 0 vectorvertex! )
( 1 5 a 0 1 vectorvertex! )
( 1 0 6 0 2 vectorvertex! )
( 1 -5 a 0 3 vectorvertex! )
( 1 0 0 0 4 vectorvertex! )

: shipspritedata
  0100 0100 0380 07c0
  07c0 0fe0 0fe0 0fe0
  1ff0 1ff0 1ff0 3ff8
  3ff8 7efc 783c 0000
  0001 001e 007e 07fe
  1ffe fffc 7ffc 3ff8
  1ff8 07f8 03f8 01f0
  01f0 00e0 0060 0020
  0000 6000 7800 7f00
  7ff0 7ff8 3ff8 1fff
  3ff8 3ff8 7ff0 7ff0
  7800 6000 0000 0000
  0020 0060 00e0 01f0
  01f0 03f8 07f8 1ff8
  3ff8 7ffc fffc 1ffe
  07fe 007e 001e 0001
  0000 3c1e 3f7e 1ffc
  1ffc 0ff8 0ff8 0ff8
  07f0 07f0 07f0 03e0
  03e0 01c0 0080 0080
  0400 0600 0700 0f80
  0f80 1fc0 1fe0 1ff8
  1ffc 3ffe 3fff 7ff8
  7fe0 7e00 7800 8000
  0000 0000 0006 001e
  00fe 07fe 1ffc 3ffc
  fff8 3ffc 1ffc 07fe
  00fe 001e 0006 0000
  8000 7800 7e00 7fe0
  7ff8 3fff 3ffe 1ffc
  1ff8 1fe0 1fc0 0f80
  0f80 0700 0600 0400 ;

: shipcrashdata
  0020 4206 0006 1820
  1800 0081 0400 4010
  0000 0300 0302 6010
  6000 0000 0419 8018
  0000 0300 0302 6010
  6000 0000 0419 8018
  0020 4206 0006 1820
  1800 0081 0400 4010
  0020 4206 0006 1820
  1800 0081 0400 4010
  0000 0300 0302 6010
  6000 0000 0419 8018
  0000 0300 0302 6010
  6000 0000 0419 8018
  0020 4206 0006 1820
  1800 0081 0400 4010
  0020 4206 0006 1820
  1800 0081 0400 4010
  0000 0300 0302 6010
  6000 0000 0419 8018
  0000 0300 0302 6010
  6000 0000 0419 8018
  0020 4206 0006 1820
  1800 0081 0400 4010
  0020 4206 0006 1820
  1800 0081 0400 4010
  0000 0300 0302 6010
  6000 0000 0419 8018
  0000 0300 0302 6010
  6000 0000 0419 8018
  0020 4206 0006 1820
  1800 0081 0400 4010 ;

: bulletspritedata
  2 0 do
    0000 0000 0000 0000
    0000 0100 0100 07c0
    0100 0100 0000 0000
    0000 0000 0000 0000
    0000 0000 0000 0000
    0000 0440 0280 0100
    0280 0440 0000 0000
    0000 0000 0000 0000
    0000 0000 0000 0000
    0000 0100 0380 07c0
    0380 0100 0000 0000
    0000 0000 0000 0000
    0000 0000 0000 0000
    0000 0540 0380 07c0
    0380 0540 0000 0000
    0000 0000 0000 0000
  loop ;

: setshipsprite
  shipspritedata b lspritetile!
  shipspritedata b uspritetile! ;

: setshipcrashsprite
  shipcrashdata b lspritetile!
  shipcrashdata b uspritetile! ;

: setbulletsprite
  bulletspritedata c lspritetile!
  bulletspritedata c uspritetile! ;

: asteroidbitmap
  07f0 0ff8 1ffe 1fff
  3fff ffff fffe fffc
  ffff 7fff 7fff 7ffe
  3ffc 3ffc 0ff8 00f0
  1008 3c1c 7f1e ffff
  7ffe 7ffe 3ff8 3ff0
  1ff8 0ff8 1ffc 7ffe
  ffff 7ffe 3dfc 1878
  0787 1f8e 0fde 67fc
  fffc fffe ffff 7fff
  7ffc 3ff8 3ffc 7ffe
  ffff fffe 3ffc 73f8
  1800 3f98 3ffc 1ffe
  1ffe 1ffe 7ffe ffff
  ffff ffff fffe fffe
  3ffc 1ff0 07c0 0180
  0ff0 1ffc 1ffe 3ffe
  3fff 7fff 7fff ffff
  ffff fffe fffc 7ffc
  3ffc 3ff0 3ff0 07e0
  0000 0000 0000 0180
  03c0 03e0 07f8 07fc
  0ffc 1ffc 1ff8 0ff8
  01f0 0000 0000 0000
  0600 0fe0 1ff8 3ffc
  7ffe fffe 0fff 1fff
  1fff 3fff 7fff 7ffe
  3e7c 3c38 3800 3000
  0020 4206 0006 1820
  1800 0081 0400 4010
  0000 0300 0302 6010
  6000 0000 0419 8018 ;

: newlevel
  c 0 do
    0 i lasteroidactive !
    0 i hasteroidactive !
    0 0 0 0 0 0 i lsprite
    0 0 0 0 0 0 i usprite
  loop
  0 activelasteroids ! 0 activehasteroids !
  3 qrng 1+ 0 do
    7 rng 280 rng a0 rng 20 rng 20 + 1 1
      activelasteroids @ lsprite
    3 qrng activelasteroids @ lasteroiddirection !
    1 activelasteroids @ lasteroidtype !
    1 activelasteroids @ lasteroidactive !
    1 activelasteroids +!
  loop
    7 rng d5 rng 1e0 rng 20 rng 20 + 1 1
      activelasteroids @ lsprite
    3 qrng activelasteroids @ lasteroiddirection !
    1 activelasteroids @ lasteroidtype !
    1 activelasteroids @ lasteroidactive !
    1+ activelasteroids +!
  3 qrng 1+ 0 do
    7 rng 280 rng a0 rng 140 + 20 rng 20 + 1 1
      activehasteroids @ usprite
    3 qrng activehasteroids @ hasteroiddirection !
    1 activehasteroids @ hasteroidtype !
    1 activehasteroids @ hasteroidactive !
    1 activehasteroids +!
  loop
    7 rng d5 rng 1aa + 1e0 rng 20 rng 20 + 1 1
      activehasteroids @ usprite
    3 qrng activehasteroids @ hasteroiddirection !
    1 activehasteroids @ hasteroidtype !
    1 activehasteroids @ hasteroidactive !
    1 activehasteroids +! ;

: setup
  cs tmlcs tmucs tcs 0 0 tpuxy!
  3f 40 tcolour!
  0 terminal!
  timer1hz! 0 lasttimer !
  2a 1 5 background!
  f 0 do
    0 0 0 0 0 0 i lsprite
    0 0 0 0 0 0 i usprite
  loop

    4 4 1 15 40 tml!
    4 5 2 15 40 tml!
    5 4 3 15 40 tml!
    5 5 4 15 40 tml!
    12 e 1 14 40 tml!
    12 f 2 14 40 tml!
    13 e 3 14 40 tml!
    13 f 4 14 40 tml!
    22 1c 1 5 40 tml!
    22 1d 2 5 40 tml!
    23 1c 3 5 40 tml!
    23 1d 4 5 40 tml!
    24 2 1 2a 40 tmu!
    24 3 2 2a 40 tmu!
    25 2 3 2a 40 tmu!
    25 3 4 2a 40 tmu!
    6 1a 1 10 40 tmu!
    6 1b 2 10 40 tmu!
    7 1a 3 10 40 tmu!
    7 1b 4 10 40 tmu!

  0 score !
  3 lives !
  4 counter !
  0 shipdirection !
  138 shipx !
  e8 shipy !
  setshipsprite
  setbulletsprite ;

: setasteroidsprites
  b 0 do
    asteroidbitmap i lspritetile!
    asteroidbitmap i uspritetile!
  loop ;

: finish
 1 terminal! ;

( game start here )
: beepboop
  timer1hz@ lasttimer @ <> if
    5 tmlmove!
    3 tmumove!
    timer1hz@ lasttimer !
    lasttimer @ 3 and
    case
      1 of
        1 0 1 1f4 beep!
      endof
      3 of
        1 0 2 1f4 beep!
        6 tmumove!
        5 tmumove!
      endof
    endcase
  then ;

: countasteroids
  0 totalasteroids !
  b 0 do
    i lasteroidactive @ 0<> if
      1 totalasteroids +! then
    i hasteroidactive @ 0<> if
      1 totalasteroids +! then
  loop ;

: lspawnasteroid
  ff spawnasteroid !
  b 0 do
    i lasteroidactive @ 0= if
      i spawnasteroid ! then
  loop
  spawnasteroid @ ff <> if
    20 rng 20 +
    workx @ 20 rng 10 - +
    worky @ 20 rng 10 - +
    7 rng
    1 0 spawnasteroid @ lsprite
    2 spawnasteroid lasteroidtype !
    c rng spawnasteroid @ lasteroiddirection !
    2 spawnasteroid @ lasteroidtype !
    1 spawnasteroid @ lasteroidactive ! then ;

: lkill
  4 hitasteroid @ lsprite@ workx !
  3 hitasteroid @ lsprite@ worky !

  7 workx @ worky @
  2 hitasteroid @ lsprite@
  1 hitasteroid @ lsprite@
  1 hitasteroid @ lsprite
  2 4 2 1f4 beep! 1f4 sleep
  0 0 0 0 0 0 hitasteroid @ lsprite
  0 hitasteroid @ lasteroidactive !
  hitasteroid @ lasteroidtype @
  case
    1 of
      lspawnasteroid
      lspawnasteroid
    endof
  endcase ;

: hspawnasteroid
  ff spawnasteroid !
  b 0 do
    i hasteroidactive @ 0= if
      i spawnasteroid ! then
  loop
  spawnasteroid @ ff <> if
    20 rng 20 +
    workx @ 20 rng 10 - +
    worky @ 20 rng 10 - +
    7 rng
    1 0 spawnasteroid @ usprite
    2 spawnasteroid hasteroidtype !
    c rng spawnasteroid @ hasteroiddirection !
    2 spawnasteroid @ hasteroidtype !
    1 spawnasteroid @ hasteroidactive ! then ;

: hkill
  4 hitasteroid @ usprite@ workx !
  3 hitasteroid @ usprite@ worky !

  7 workx @ worky @
  2 hitasteroid @ usprite@
  1 hitasteroid @ usprite@
  1 hitasteroid @ usprite
  2 4 2 1f4 beep! 1f4 sleep
  0 0 0 0 0 0 hitasteroid @ usprite
  0 hitasteroid @ hasteroidactive !
  hitasteroid @ hasteroidtype @
  case
    1 of
      hspawnasteroid
      hspawnasteroid
    endof
  endcase ;

: lhit
  1 score +!
  ff hitasteroid !
  b 0 do
    6 i lsprite@ 1000 and 0<> if
      i hitasteroid ! then
  loop
  hitasteroid @ ff <> if
    lkill then
  0 0 0 0 0 0 c lsprite
  0 0 0 0 0 0 c usprite
  countasteroids totalasteroids @
  0= if
    newlevel then ;

: hhit
  1 score +!
  ff hitasteroid !
  b 0 do
    6 i usprite@ 1000 and 0<> if
      i hitasteroid ! then
  loop
  hitasteroid @ ff <> if
    hkill then
  0 0 0 0 0 0 c lsprite
  0 0 0 0 0 0 c usprite
  countasteroids totalasteroids @
  0= if
    newlevel then ;

: drawlives
  cs
  lives @
  case
    1 of
      ( 3f 220 1d0 0 vector! )
    endof
    2 of
      ( 3f 220 1d0 0 vector! )
      ( 3f 240 1d0 0 vector! )
    endof
    3 of
      ( 3f 220 1d0 0 vector! )
      ( 3f 240 1d0 0 vector! )
      ( 3f 260 1d0 0 vector! )
    endof
  endcase ;


: hit?
  6 c lsprite@ 7ff and 0<> if
    lhit then
  6 c usprite@ 7ff and 0<> if
    hhit then ;

: fire?
  ( fire if bullet not active )
  ( bullet exists in lower and upper layers )
  ( for collision detection )
  0 c lsprite@ 0= if
    shipdirection @ bulletdirection !
    shipdirection @
    case
      0 of
        2 shipx @ shipy @ a - 3c 0 1 c lsprite
        0 shipx @ shipy @ a - 30 0 1 c usprite
      endof
      1 of
        2 shipx @ 8 + shipy @ a - 3c 0 1 c lsprite
        0 shipx @ 8 + shipy @ a - 30 0 1 c usprite
      endof
      2 of
        2 shipx @ a + shipy @ 3c 0 1 c lsprite
        0 shipx @ a + shipy @ 30 0 1 c usprite
      endof
      3 of
        2 shipx @ a + shipy @ a + 3c 0 1 c lsprite
        0 shipx @ a + shipy @ a + 30 0 1 c usprite
      endof
      4 of
        2 shipx @ shipy @ a + 3c 0 1 c lsprite
        0 shipx @ shipy @ a + 30 0 1 c usprite
      endof
      5 of
        2 shipx @ a - shipy @ a + 3c 0 1 c lsprite
        0 shipx @ a - shipy @ a + 30 0 1 c usprite
      endof
      6 of
        2 shipx @ a - shipy @ 3c 0 1 c lsprite
        0 shipx @ a - shipy @ 30 0 1 c usprite
      endof
      7 of
        2 shipx @ a - shipy @ a - 3c 0 1 c lsprite
        0 shipx @ a - shipy @ a - 30 0 1 c usprite
      endof
    endcase
    2 4 3d 80 beep! tcs then ;

: drawship
  ( ship exits in lower and upper layers )
  ( for collision detection )
  shipdirection @ shipx @ shipy @ 3f 0 1 b lsprite
  shipdirection @ shipx @ shipy @ 3f 0 1 b usprite ;

: moveasteroids
  b 0 do
    i lasteroiddirection @ updatedirections @
    i lspriteupdate
    i hasteroiddirection @ updatedirections @
    i uspriteupdate
  loop ;

: moveship
  shipdirection @
  case
    0 of
      shipy @ 0> if
        -1 shipy +! then
    endof
    1 of
      shipx @ 270 < if
        1 shipx +! then
      shipy @ 0> if
        -1 shipy +! then
    endof
    2 of
      shipx @ 270 < if
        1 shipx +! then
    endof
    3 of
      shipx @ 270 < if
        1 shipx +! then
      shipy @ 1d0 < if
        1 shipy +! then
    endof
    4 of
      shipy @ 1d0 < if
        1 shipy +! then
    endof
    5 of
      shipx @ 0> if
        -1 shipx +! then
      shipy @ 1d0 < if
        1 shipy +! then
    endof
    6 of
      shipx @ 0> if
        -1 shipx +! then
    endof
    7 of
      shipx @ 0> if
        -1 shipx +! then
      shipy @ 0> if
        -1 shipy +! then
    endof
  endcase ;

: shipleft
  shipdirection @ 0= if
    7 shipdirection !
    else -1 shipdirection +! then ;

: shipright
  shipdirection @ 7 = if
    0 shipdirection !
    else 1 shipdirection +! then ;

: drawscore
  countasteroids totalasteroids @ led!
  40 35 tcolour!
  26 1 tpuxy!
  score @ 4 tpu.r# ;

: crash?
  6 b lsprite@ 7ff and
  6 b usprite@ 7ff and + 0<> if
    setshipcrashsprite
    2 4 1 3e8 beep!

    e000 b uspriteupdate

    10 0 do
      f840 b lspriteupdate
      20 sleep
      vblank?
    loop

    0 0 0 0 0 0 b lsprite
    0 0 0 0 0 0 b usprite

    0 shipdirection !
    138 shipx !
    e8 shipy !
    setshipsprite

    -1 lives +!
    drawlives

    10 0 do
    begin
      shipdirection @ shipx @ shipy @ 15 0 1 b lsprite
      shipdirection @ shipx @ shipy @ 15 0 1 b usprite
      moveasteroids 14 sleep
      6 b lsprite@ 7ff and
      6 b usprite@ and + 0=
    until
    loop

    then ;


: mainloop
    counter @
    case
      0 of
        4 counter !
      endof
      -1 counter +!
    endcase
    a timer1khz!
    beepboop
    bulletdirection @ bulletdirections @
      c lspriteupdate
    bulletdirection @ bulletdirections @
      c uspriteupdate
    vblank?
    moveasteroids drawship drawscore
    timer1khz?
    crash? hit? ;

: demoULX3S
  setup
  setasteroidsprites
  drawlives
  newlevel
  begin
    mainloop
    buttons@ 2 and 0<> if
      fire? then
    buttons@ 8 and 0<> if
      moveship then
    buttons@ 20 and 0<> if
      counter @ 0= if
      shipleft then then
    buttons@ 40 and 0<> if
      counter @ 0= if
      shipright then then
    lives @ 0=
  until finish ;
