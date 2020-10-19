( store timer1hz@ to generate a beep/boop every other second )
variable lasttimer

( helper word to create an array )

: array 
  create cells allot
  does> cells + ;

( storage for 32 (20 hex) asteroids )

20 array asteroidtype
20 array asteroidx
20 array asteroidy
  
( set bullet sprite )
8000 0000 0000 0000 0000 0000 0000 0000
0000 0000 0000 0000 0000 0000 0000 0000
0000 0000 0000 0000 0000 0000 0000 0000
0000 0000 0000 0000 0000 0000 0000 0000
0000 0000 0000 0000 0000 0000 0000 0000
0000 0000 0000 0000 0000 0000 0000 0000
0000 0000 0000 0000 0000 0000 0000 0000
0000 0000 0000 0000 0000 0000 0000 0000
0 usltile!

( set ship vector block )
1 0 0 0 0 vectorvertex!
1 5 a 0 1 vectorvertex!
1 0 6 0 2 vectorvertex!
1 -5 a 0 3 vectorvertex!
1 0 0 0 4 vectorvertex!

( set big asteroid 1 block )
1 0 0 8 0 vectorvertex!
1 -7 -a 8 1 vectorvertex!
1 -4 -c 8 2 vectorvertex!
1 13 -a 8 3 vectorvertex!
1 12 4 8 4 vectorvertex!
1 9 4 8 5 vectorvertex!
1 13 10 8 6 vectorvertex!
1 a 13 8 7 vectorvertex!
1 0 e 8 8 vectorvertex!
1 -a 14 8 9 vectorvertex!
1 -10 6 8 a vectorvertex!
1 -c -4 8 b vectorvertex!
1 0 0 8 c vectorvertex!

( set big asteroid 2 block )
1 0 -10 9 0 vectorvertex!
1 8 -15 9 1 vectorvertex!
1 c -e 9 2 vectorvertex!
1 7 -d 9 3 vectorvertex!
1 11 -1 9 4 vectorvertex!
1 7 e 9 5 vectorvertex!
1 0 b 9 6 vectorvertex!
1 -6 f 9 7 vectorvertex!
1 -c b 9 8 vectorvertex!
1 -8 7 9 9 vectorvertex!
1 -8 2 9 a vectorvertex!
1 -f -9 9 b vectorvertex!
1 -a -13 9 c vectorvertex!
1 0 -10 9 d vectorvertex!

( set big asteroid 3 block )
1 -6 -14 a 0 vectorvertex!
1 8 -f a 1 vectorvertex!
1 8 -1 a 2 vectorvertex!
1 f -6 a 3 vectorvertex!
1 12 2 a 4 vectorvertex!
1 8 7 a 5 vectorvertex!
1 b c a 6 vectorvertex!
1 -4 14 a 7 vectorvertex!
1 -d 14 a 8 vectorvertex!
1 -11 11 a 9 vectorvertex!
1 -11 0 a a vectorvertex!
1 -10 -7 a b vectorvertex!
1 -6 -14 a c vectorvertex!

: setup
  ( hide the terminal )
  terminalhide!
  ( reset the second timer )
  timer1hz! 0 lasttimer !
  ( set the background )
  2a 1 7 background! cs!
  ( hide usl sprite 0 and set monitoring )
  0 0 0 0 0 0 uslsprite!
  0 ff40 ! ;

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
    140 ef 3f 0 1 0 uslsprite!
    4 3d 80 beep!
  then ;

: hit?
  ( see if the bullet has hit the background )
  ff47 @ 8000 and if
    ( explode )
    1 19 80 beep!
    ( deactivate the bullet )
    0 0 0 0 0 0 uslsprite!
  then ;
    
: mainloop
    beepboop
    14 timer1khz! cs!
    138 0 uslupdate!
    ( copy the bullet coordinates )
    ff44 @ ff09 !
    ff45 @ ff0a ! 
    3f 140 f0 0 vector!
    3 140 80 8 vector!
    c 50 50 9 vector!
    33 200 f0 a vector!
    hit? ;

: demoULX3S
  setup
  begin
    mainloop
    buttons@ 2 and 0<> if 
      fire? then
    timer1khz? vblank?
    buttons@ 4 and 0<>
  until finish ;

: demoDE10NANO
  setup
  begin
    mainloop
    buttons@ 2 and 0= if 
      fire? then
    timer1khz? vblank?
    buttons@ 1 and 0=
  until finish ;
  
