( game start here )
: beepboop
  timer1hz@ lasttimer @ <> if
    5 tmmove!
    timer1hz@ lasttimer !
    lasttimer @ 3 and
    case
      1 of
        1 0 1 1f4 beepL!
      endof
      3 of
        1 0 2 1f4 beepR!
        6 tmmove!
      endof
    endcase
  then ;

: lkill
  hitasteroid @ ff30 !
  ff33 @ ff34 @ ff35 @ 7 1 ff36 @
  hitasteroid @ lslsprite!
  2 4 1 1f4 beep! 1f4 sleep
  0 0 0 0 0 0 hitasteroid @ lslsprite!
  0 hitasteroid @ lasteroidactive c!
  -1 activelasteroids +! ;

: hkill
  hitasteroid @ ff40 !
  ff43 @ ff44 @ ff45 @ 7 1 ff46 @
  hitasteroid @ uslsprite!
  2 4 1 1f4 beep! 1f4 sleep
  0 0 0 0 0 0 hitasteroid @ uslsprite!
  0 hitasteroid @ hasteroidactive c!
  -1 activehasteroids +! ;

: lhit
  1 score +!
  $" LHIT " tpu.$
  ff hitasteroid !
  b 0 do
    i ff50 + @ 1000 and 0<> if
      i hitasteroid !
      i tpu. then
  loop
  hitasteroid @ ff <> if
    lkill then
  0 0 0 0 0 0 c lslsprite!
  0 0 0 0 0 0 c uslsprite! ;

: hhit
  1 score +!
  $" HHIT " tpu.$
  ff hitasteroid !
  b 0 do
    i ff60 + @ 1000 and 0<> if
      i hitasteroid !
      i tpu. then
  loop
  hitasteroid @ ff <> if
    hkill then
  0 0 0 0 0 0 c lslsprite!
  0 0 0 0 0 0 c uslsprite! ;

: crash?
  ff5b @ 7ff and
  ff6b @ 7ff and + 0<> if
    newlevel
    then ;

: hit?
  ff5c @ 7ff and 0<> if
    lhit then
  ff6c @ 7ff and 0<> if
    hhit then ;

: fire?
  ( fire if bullet not active )
  ( bullet exists in lower and upper layers )
  ( for collision detection )
  c ff40 ! ff41 @ 0= if
    shipdirection @ bulletdirection !
    3c shipx @ 4 + shipy @ 4 + 2 1 0 c lslsprite!
    30 shipx @ 4 + shipy @ 4 + 0 1 0 c uslsprite!
    2 4 3d 80 beep! tpucs! then ;

: drawship
  ( ship exits in lower and upper layers )
  ( for collision detection )
  3f shipx @ shipy @ shipdirection @ 1 0 b lslsprite!
  3f shipx @ shipy @ shipdirection @ 1 0 b uslsprite! ;

: moveasteroids
  b 0 do
    i lasteroiddirection c@ updatedirections c@
    i lslupdate!
    i hasteroiddirection c@ updatedirections c@
    i uslupdate!
  loop ;

: moveship
  shipdirection @
  case
    0 of
      shipy @ 0> if
        shipy @ 1- shipy ! then
    endof
    1 of
      shipx @ 270 < if
        shipx @ 1+ shipx ! then
    endof
    2 of
      shipy @ 1d0 < if
        shipy @ 1+ shipy ! then
    endof
    3 of
      shipx @ 0> if
        shipx @ 1- shipx ! then
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
  40 tpubackground!
  3f tpuforeground!
  26 1 tpuxy!
  score @ 4 tpu.r# ;

: mainloop
    counter @
    case
      0 of
        4 counter !
      endof
      -1 counter +!
    endcase
    14 timer1khz!
    beepboop
    bulletdirection @ bulletdirections c@ 180 +
      c lslupdate!
    bulletdirection @ bulletdirections c@ 180 +
      c uslupdate!
    vblank?
    moveasteroids drawship drawscore
    timer1khz?
    crash? hit? ;

: demoULX3S
  setup
  setasteroidsprites
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
    buttons@ 4 and 0<>
  until finish ;

: demoDE10NANO
  setup
  setasteroidsprites
  newlevel
  begin
     mainloop
     buttons@ 2 and 0= if
      fire? then
    buttons@ 4 and 0= if
      counter @ 0= if
      shipleft then then
   buttons@ 1 and 0=
  until finish ;


