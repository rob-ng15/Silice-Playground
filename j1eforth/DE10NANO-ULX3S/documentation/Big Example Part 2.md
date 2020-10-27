( game start here )
: beepboop
  timer1hz@ lasttimer @ <>
  if
    timer1hz@ lasttimer !
    lasttimer @ 3 and 1 = if
      1 0 1 1f4 beepL! 
      5 ff99 ! then
    lasttimer @ 3 and 3 = if
      1 0 2 1f4 beepR! 
      6 ff99 ! then
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
    2 4 3d 80 beep!
  then ;
    
: hit?
  ff5e @ 1fff and 0<> if
    3 4 19 1f4 beep!
    lhit
    0 0 0 0 0 0 e lslsprite!
    0 0 0 0 0 0 e uslsprite!
  then
  ff6e @ 1fff and 0<> if
    3 4 19 1f4 beep!
    uhit
    0 0 0 0 0 0 e lslsprite!
    0 0 0 0 0 0 e uslsprite!
  then ;

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

  
