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

: countasteroids
  0 totalasteroids !
  b 0 do
    i lasteroidactive c@ 0<> if
      1 totalasteroids +! then
    i hasteroidactive c@ 0<> if
      1 totalasteroids +! then
  loop ;

: lspawnasteroid
  ff spawnasteroid !
  b 0 do
    i lasteroidactive c@ 0= if
      i spawnasteroid ! then
  loop
  spawnasteroid @ ff <> if
    20 rng 20 +
    workx @ 20 rng 10 - +
    worky @ 20 rng 10 - +
    7 rng
    1 0 spawnasteroid @ lslsprite!
    2 spawnasteroid lasteroidtype c!
    8 rng 4 + spawnasteroid @ lasteroiddirection c!
    2 spawnasteroid @ lasteroidtype c!
    1 spawnasteroid @ lasteroidactive c! then ;

: lkill
  hitasteroid @ ff30 !
  ff34 @ workx !
  ff35 @ worky !
  ff33 @ workx @ worky @ 7 1 ff36 @
  hitasteroid @ lslsprite!
  2 4 2 1f4 beep! 1f4 sleep
  0 0 0 0 0 0 hitasteroid @ lslsprite!
  0 hitasteroid @ lasteroidactive c!
  hitasteroid @ lasteroidtype c@
  case
    1 of
      lspawnasteroid
      lspawnasteroid
    endof
  endcase ;

: hspawnasteroid
  ff spawnasteroid !
  b 0 do
    i hasteroidactive c@ 0= if
      i spawnasteroid ! then
  loop
  spawnasteroid @ ff <> if
    20 rng 20 +
    workx @ 20 rng 10 - +
    worky @ 20 rng 10 - +
    7 rng
    1 0 spawnasteroid @ uslsprite!
    2 spawnasteroid hasteroidtype c!
    8 rng 4 + spawnasteroid @ hasteroiddirection c!
    2 spawnasteroid @ hasteroidtype c!
    1 spawnasteroid @ hasteroidactive c! then ;

: hkill
  hitasteroid @ ff40 !
  ff44 @ workx !
  ff45 @ worky !
  ff43 @ workx @ worky @ 7 1 ff46 @
  hitasteroid @ uslsprite!
  2 4 2 1f4 beep! 1f4 sleep
  0 0 0 0 0 0 hitasteroid @ uslsprite!
  0 hitasteroid @ hasteroidactive c!
  hitasteroid @ hasteroidtype c@
  case
    1 of
      hspawnasteroid
      hspawnasteroid
    endof
  endcase ;

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
  0 0 0 0 0 0 c uslsprite!
  countasteroids totalasteroids @
  0= if
    newlevel then ;

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
  0 0 0 0 0 0 c uslsprite!
  countasteroids totalasteroids @
  0= if
    newlevel then ;

: drawlives
  cs!
  lives @
  case
    1 of
      3f 220 1d0 0 vector!
    endof
    2 of
      3f 220 1d0 0 vector!
      3f 240 1d0 0 vector!
    endof
    3 of
      3f 220 1d0 0 vector!
      3f 240 1d0 0 vector!
      3f 260 1d0 0 vector!
    endof
  endcase ;


: crash?
  ff5b @ 7ff and
  ff6b @ 7ff and + 0<> if
    setshipcrashsprite
    2 4 1 3e8 beep!

    e000 b uslupdate!

    10 0 do
      f840 b lslupdate!
      20 sleep
      vblank?
    loop

    0 0 0 0 0 0 b lslsprite!
    0 0 0 0 0 0 b uslsprite!

    0 shipdirection !
    138 shipx !
    e8 shipy !
    setshipsprite

    -1 lives +!
    newlevel
    drawlives
    then ;

: hit?
  0 1d tpuxy!
  ff5c @ ff6c @ 2 base !
  18 tpuu.r 18 tpuu.r hex
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
    shipdirection @
    case
      0 of
        3c shipx @ shipy @ a - 2 1 0 c lslsprite!
        30 shipx @ shipy @ a - 0 1 0 c uslsprite!
      endof
      1 of
        3c shipx @ 8 + shipy @ a - 2 1 0 c lslsprite!
        30 shipx @ 8 + shipy @ a - 0 1 0 c uslsprite!
      endof
      2 of
        3c shipx @ a + shipy @ 2 1 0 c lslsprite!
        30 shipx @ a + shipy @ 0 1 0 c uslsprite!
      endof
      3 of
        3c shipx @ a + shipy @ a + 2 1 0 c lslsprite!
        30 shipx @ a + shipy @ a + 0 1 0 c uslsprite!
      endof
      4 of
        3c shipx @ shipy @ a + 2 1 0 c lslsprite!
        30 shipx @ shipy @ a + 0 1 0 c uslsprite!
      endof
      5 of
        3c shipx @ a - shipy @ a + 2 1 0 c lslsprite!
        30 shipx @ a - shipy @ a + 0 1 0 c uslsprite!
      endof
      6 of
        3c shipx @ a - shipy @ 2 1 0 c lslsprite!
        30 shipx @ a - shipy @ 0 1 0 c uslsprite!
      endof
      7 of
        3c shipx @ a - shipy @ a - 2 1 0 c lslsprite!
        30 shipx @ a - shipy @ a - 0 1 0 c uslsprite!
      endof
    endcase
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
      shipy @ 1e0 < if
        1 shipy +! then
    endof
    4 of
      shipy @ 1e0 < if
        1 shipy +! then
    endof
    5 of
      shipx @ 0> if
        -1 shipx +! then
      shipy @ 1e0 < if
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
   buttons@ 1 and 0= if
      counter @ 0= if
      shipright then then
   lives @ 0=
  until finish ;
