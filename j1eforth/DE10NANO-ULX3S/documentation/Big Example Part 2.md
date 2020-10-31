( game start here )
: beepboop
  timer1hz@ lasttimer @ <> if
    5 tmmove! 
    timer1hz@ lasttimer !
    lasttimer @ 3 and 1 = if
      1 0 1 1f4 beepL! 
      then
    lasttimer @ 3 and 3 = if
      1 0 2 1f4 beepR! 
      6 tmmove!
      then
  then ;

: lfindblank
  ff spawnasteroid !
  d 0 do
    i lasteroidactive c@ 0= if
      i spawnasteroid ! then
  loop ;

: lsetmedium
    1 spawnasteroid @ lasteroidactive c!
    2 spawnasteroid @ lasteroidtype c!
    8 rng 4 + spawnasteroid @ lasteroiddirection c!
    20 rng 20 + workx @ worky @ 3 rng 1 0
      spawnasteroid @ lslsprite!
    spawnasteroid @ setlargelasteroid
    activelasteroids @ 1+ activelasteroids ! ;
    
: lspawnmedium
  hitasteroid @ ff30 !
  ff34 @ 10 rng - workx !
  ff35 @ 10 rng - worky !
  lfindblank spawnasteroid @ ff <> if
    lsetmedium then
  lfindblank spawnasteroid @ ff <> if
    lsetmedium then ;
: lfindblank
  ff spawnasteroid !
  d 0 do
    i lasteroidactive c@ 0= if
      i spawnasteroid ! then
  loop ;

: hfindblank
  ff spawnasteroid !
  d 0 do
    i hasteroidactive c@ 0= if
      i spawnasteroid ! then
  loop ;
 
: hsetmedium
    1 spawnasteroid @ hasteroidactive c!
    2 spawnasteroid @ hasteroidtype c!
    8 rng 4 + spawnasteroid @ hasteroiddirection c!
    20 rng 20 + workx @ worky @ 3 rng 1 0
      spawnasteroid @ uslsprite!
    spawnasteroid @ setlargehasteroid
    activehasteroids @ 1+ activehasteroids ! ;
    
: hspawnmedium
  hitasteroid @ ff40 !
  ff44 @ 10 rng + workx !
  ff45 @ 10 rng + worky !
  hfindblank spawnasteroid @ ff <> if
    hsetmedium then
  lfindblank spawnasteroid @ ff <> if
    hsetmedium then ;

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
  ff hitasteroid !
  c 0 do
  ff50 i + @ 4000 and 0<> if
    i hitasteroid ! then
  loop
  hitasteroid @ ff <> if
    killlhit
    activelasteroids @ 1- activelasteroids !
    hitasteroid @ lasteroidtype c@ 2 = if
        ( medium  kill )
        0 hitasteroid @ lasteroidtype c!
        then
    hitasteroid @ lasteroidtype c@ 1 = if
        lspawnmedium
        ( large spawn 2 medium )
    then 
  then ;
    
: uhit
  ( find hit asteroid )
  ff hitasteroid !
  c 0 do
    ff60 i + @ 4000 and 0<> if
    i hitasteroid ! then
  loop
  hitasteroid @ ff <> if
    activehasteroids @ 1- activehasteroids !
    hitasteroid @ hasteroidtype c@ 2 = if
        ( medium kill )
        0 hitasteroid @ lasteroidtype c!
        then
    hitasteroid @ hasteroidtype c@ 1 = if
        hspawnmedium
        ( large spawn 2 medium )
    then 
  then ;
    
: fire?
  ( fire if bullet not active )
  ( bullet exists in lower and upper layers )
  ( for collision detection )
  e ff40 ! ff41 @ 0= if
    shipdirection @ bulletdirection !
    3c shipx @ 4 + shipy @ 4 + 2 1 0 e lslsprite!
    30 shipx @ 4 + shipy @ 4 + 0 1 0 e uslsprite!
    2 4 3d 80 beep! then ;
    
: hit?
  ff5e @ 1fff and 0<> if
    3 4 19 1f4 beep!
    lhit
    0 0 0 0 0 0 e lslsprite!
    0 0 0 0 0 0 e uslsprite!
    score @ 1+ score !
  then
  ff6e @ 1fff and 0<> if
    3 4 19 1f4 beep!
    uhit
    0 0 0 0 0 0 e lslsprite!
    0 0 0 0 0 0 e uslsprite!
    score @ 1+ score !
  then 
  activehasteroids @ activelasteroids @ +
  0= if
    placeasteroids then ;

: crash?
  ff5d @ 1fff and 0<> if
    2 4 1 1f4 beep!
    setup
  then
  ff6d @ 1fff and 0<> if
    2 4 1 1f4 beep!
    setup
  then ;
  
: drawship
  ( ship exits in lower and upper layers )
  ( for collision detection )
  3f shipx @ shipy @ shipdirection @ 1 0 d lslsprite!
  3f shipx @ shipy @ shipdirection @ 1 0 d uslsprite! ;

: moveasteroids
  d 0 do
    i lasteroidactive @ 0<> if
      i lasteroiddirection c@ updatedirections c@
      i lslupdate! then
    i hasteroidactive c@ 0<> if
      i hasteroiddirection c@ updatedirections c@
      i uslupdate! then
  loop ;

: moveship
  shipdirection @ 0= if
    shipy @ 0> if
      shipy @ 1- shipy ! then then
  shipdirection @ 1 = if
    shipx @ 270 < if
      shipx @ 1+ shipx ! then then
  shipdirection @ 2 = if
    shipy @ 1d0 < if
      shipy @ 1+ shipy ! then then
  shipdirection @ 3 = if
    shipx @ 0> if
      shipx @ 1- shipx ! then then ;

: shipleft
  shipdirection @ 0= if
    3 shipdirection !
    else shipdirection @ 1- shipdirection ! then ;

: shipright
  shipdirection @ 3 = if
    0 shipdirection !
    else  shipdirection @ 1+ shipdirection ! then ;

: drawscore
  40 tpubackground!
  3f tpuforeground!
  26 1 tpuxy!
  score @ 4 tpu.r# ;
    
: mainloop
    counter @ 0= if
      4 counter !
      else counter @ 1- counter !
      then
    14 timer1khz!
    beepboop
    bulletdirection @ updatedirections c@ 180 + 
      e lslupdate!
    bulletdirection @ updatedirections c@ 180 + 
      e uslupdate!
    vblank?
    hit?
    moveasteroids drawship drawscore
    crash? timer1khz? ;

: demoULX3S
  setup
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
    buttons@ 4 and 0<>
  until finish ;

: demoDE10NANO
  setup
  begin
     mainloop
     buttons@ 2 and 0= if 
      fire? then
    buttons@ 4 and 0= if
      counter @ 0= if
      shipleft then then
   buttons@ 1 and 0=
  until finish ;

  
