# DEMO Mini Asteroids Type Game

### NOTE PASTE AS TWO BLOCKS AS THIS FILE IS GETTING LARGE
```
( store timer1hz@ to generate a beep/boop every other second )
variable lasttimer

: array create cells allot does> cells + ;

variable hitasteroid

( storage for 12 (c hex) low asteroids )
( storage for 12 (c hex) high asteroids )
c array lasteroidactive c array hasteroidactive
c array lasteroidtype c array hasteroidtype
c array lasteroiddirection c array hasteroiddirection

( directions table for the asteroid sprite update flag)
10 array updatedirections
30 0 updatedirections c! 31 1 updatedirections c!
39 2 updatedirections c! 3a 3 updatedirections c!
2  4 updatedirections c! a  5 updatedirections c!
9  6 updatedirections c! 11 7 updatedirections c!
10 8 updatedirections c! 17 9 updatedirections c!
f  a updatedirections c! e  b updatedirections c!
6  c updatedirections c! 3e d updatedirections c!
3f e updatedirections c! 37 f updatedirections c!

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
: placeasteroids
  ( clear asteroids )
  c 0 do
    0 i lasteroidactive c!
    0 i hasteroidactive c!
  loop
  0 activelasteroids ! 0 activehasteroids !
  4 rng 1+ 0 do
    20 rng 20 + 280 rng a0 rng 3 rng 1 1
      activelasteroids @ lslsprite!
    10 rng activelasteroids @ lasteroiddirection c!
    activelasteroids @ setlargelasteroid
    1 activelasteroids @ lasteroidtype c!
    1 activelasteroids @ lasteroidactive c!
    activelasteroids @ 1+ activelasteroids !
  loop
    20 rng 20 + d5 rng 1e0 rng 3 rng 1 1
      activelasteroids @ lslsprite!
    10 rng activelasteroids @ lasteroiddirection c!
    activelasteroids @ setlargelasteroid
    1 activelasteroids @ lasteroidtype c!
    1 activelasteroids @ lasteroidactive c!
    activelasteroids @ 1+ activelasteroids !
  4 rng 1+ 0 do
    20 rng 20 + 280 rng a0 rng 140 + 3 rng 1 1
      activehasteroids @ uslsprite!
    10 rng activehasteroids @ hasteroiddirection c!
    activehasteroids @ setlargehasteroid
    1 activehasteroids @ hasteroidtype !
    1 activehasteroids @ hasteroidactive c!
    activehasteroids @ 1+ activehasteroids !
  loop
    20 rng 20 + d5 rng 1aa + 1e0 rng 3 rng 1 1
      activehasteroids @ uslsprite!
    10 rng activehasteroids @ hasteroiddirection c!
    activehasteroids @ setlargehasteroid
    1 activehasteroids @ hasteroidtype !
    1 activehasteroids @ hasteroidactive c!
    activehasteroids @ 1+ activehasteroids ! ;
```
```
: setup
  ( clear the screen )
  cs! tpucs!
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

: beepboop
  timer1hz@ lasttimer @ <>
  if
    timer1hz@ lasttimer !
    lasttimer @ 3 and 1 = if
      0 1 1f4 beepL! then
    lasttimer @ 3 and 3 = if
      0 2 1f4 beepR! then
  then ;

: killlhit
  ( set to explosion tile )
  hitasteroid @ ff30 !
  3 ff32 ! fa timer1khz! timer1khz?
  0 ff31 ! ;

  : killhhit
  ( set to explosion tile )
  hitasteroid @ ff40 !
  3 ff42 ! fa timer1khz! timer1khz?
  0 ff41 ! ;
  
: lhit
  ( find hit asteroid )
  0 hitasteroid !
  c 0 do
  ff50 i + @ 4000 and 0<> if
    i hitasteroid ! then
  loop
  hitasteroid @ 0<> if
    killlhit then 
  activelasteroids @ 1- activelasteroids !
  hitasteroid @ lasteroidtype c@ 3 = if
    ( small wipe )
    0 hitasteroid @ lasteroidtype c!
    then
  hitasteroid @ lasteroidtype c@ 2 = if
    ( medium spawn 2 small )
    then
  hitasteroid @ lasteroidtype c@ 1 = if
    ( large spawn 2 medium )
    then ;
    
: uhit
  ( find hit asteroid )
  0 hitasteroid !
  c 0 do
  ff60 i + @ 4000 and 0<> if
    i hitasteroid ! then
  loop
  hitasteroid @ 0<> if
    killhhit then 
  activehasteroids @ 1- activehasteroids !
  hitasteroid @ hasteroidtype c@ 3 = if
    ( small wipe )
    0 hitasteroid @ hasteroidtype c!
    then
  hitasteroid @ hasteroidtype c@ 2 = if
    ( medium spawn 2 small )
    then
  hitasteroid @ hasteroidtype c@ 1 = if
    ( large spawn 2 medium )
    then ;
    
: fire?
  ( fire if bullet not active )
  ( bullet exists in lower and upper layers )
  ( for collision detection )
  e ff40 ! ff41 @ 0= if
    3c 140 e6 2 1 0 e lslsprite!
    30 140 e6 0 1 0 e uslsprite!
    4 3d 80 beep!
  then ;
    
: hit?
  ff5e @ 1fff and 0<> if
    4 19 1f4 beep!
    lhit
    0 0 0 0 0 0 e lslsprite!
    0 0 0 0 0 0 e uslsprite!
  then
  ff6e @ 1fff and 0<> if
    4 19 1f4 beep!
    uhit
    0 0 0 0 0 0 e lslsprite!
    0 0 0 0 0 0 e uslsprite!
  then ;

: crash?
  ff5d @ 1fff and 0<> if
    4 1 1f4 beep!
    setup
  then
  ff6d @ 1fff and 0<> if
    4 1 1f4 beep!
    setup
  then ;
  
: drawship
  ( ship exits in lower and upper layers )
  ( for collision detection )
  3f 140 f0 0 1 0 d lslsprite!
  3f 140 f0 0 1 0 d uslsprite! ;

: moveasteroids
  d 0 do
    i lasteroidactive @ 0<> if
      i lasteroiddirection c@ updatedirections c@
      i lslupdate! then
    i hasteroidactive c@ 0<> if
      i hasteroiddirection c@ updatedirections c@
      i uslupdate! then
  loop ;

: mainloop
    14 timer1khz!
    beepboop
    vblank?
    178 e lslupdate!
    178 e uslupdate! hit?
    moveasteroids drawship
    178 e lslupdate!
    178 e uslupdate! hit?
    crash? timer1khz? ;

: demoULX3S
  setup
  begin
    mainloop
    buttons@ 2 and 0<> if 
      fire? then
    buttons@ 4 and 0<>
  until finish ;

: demoDE10NANO
  setup
  begin
     mainloop
     buttons@ 2 and 0= if 
      fire? then
   buttons@ 1 and 0=
  until finish ;
```  
