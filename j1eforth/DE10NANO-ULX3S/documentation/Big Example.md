( store timer1hz@ to generate a beep/boop every other second )
variable lasttimer

: array create cells allot does> cells + ;

( storage for 12 (c hex) low asteroids )
( storage for 12 (c hex) high asteroids )
c array lasteroidactive c array hasteroidactive
c array lasteroidtype c array hasteroidtype
c array lasteroiddirection c array hasteroiddirection

( directions table for the asteroid sprite update flag)
10 array updatedirections
30 0 updatedirections ! 31 1 updatedirections !
39 2 updatedirections ! 3a 3 updatedirections !
2  4 updatedirections ! a  5 updatedirections !
9  6 updatedirections ! 11 7 updatedirections !
10 8 updatedirections ! 17 9 updatedirections !
f  a updatedirections ! e  b updatedirections !
6  c updatedirections ! 3e d updatedirections !
3f e updatedirections ! 37 f updatedirections !

( store number of active asteroids )
variable activeasteroids

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
  loop c lsltile! c usltile! ;
  
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
  loop d lsltile! d usltile! ;

: placeasteroids
  0 activeasteroids !
;

: setup
  ( hide the terminal )
  terminalhide!
  ( reset the second timer )
  timer1hz! 0 lasttimer !
  ( set the background )
  2a 1 7 background! cs!
  ( hide all sprites )
  f 0 do 
    0 0 0 0 0 0 0 lslsprite!
    0 0 0 0 0 0 0 uslsprite!
  loop
  setshipsprite
  setbulletsprite
  placeasteroids ;

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

: fire?
  ( fire if bullet not active )
  ff41 @ 0= if
     3f 140 ef 0 1 0 d lslsprite!
     3f 140 ef 0 1 0 d uslsprite!
    4 3d 80 beep!
  then ;

: hit?
;

: drawship 
    3f 140 f0 0 1 0 c lslsprite!
    3f 140 f0 0 1 0 c uslsprite!
    ( monitor bullet )
    d ff40 ! d ff30 ! ;

: moveasteroids
  c 0 do
    i lasteroidactive @ 0<> if
      i lasteroiddirection @ updatedirections @
      i lslupdate! then
    i hasteroidactive @ 0<> if
      i hasteroiddirection @ updatedirections @
      i uslupdate! then
  loop ;

: drawasteroids
  d 0 do
  loop ;

: mainloop
    beepboop
    178 d lslupdate!
    178 d uslupdate!
    moveasteroids drawship
    hit? ;

: demoULX3S
  setup
  begin
    14 timer1khz! mainloop
    buttons@ 2 and 0<> if 
      fire? then
    timer1khz?
    buttons@ 4 and 0<>
  until finish ;

: demoDE10NANO
  setup
  begin
    14 timer1khz! mainloop
     buttons@ 2 and 0= if 
      fire? then
   timer1khz?
   buttons@ 1 and 0=
  until finish ;
  
