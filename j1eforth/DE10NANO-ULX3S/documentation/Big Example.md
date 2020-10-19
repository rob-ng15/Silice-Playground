( store timer1hz@ to generate a beep/boop every other second )
variable lasttimer

( helper word to create an array )

: array 
  create cells allot
  does> cells + ;

( helper word to create pseudo random numbers )
( creates random numbers from 0 to stack-1 )

: rng
  ffe0 @ swap /mod drop ;
  
( storage for 32 (20 hex) asteroids )

20 array asteroidactive
20 array asteroidtype
20 array asteroidcolour
20 array asteroidx
20 array asteroidy
20 array asteroiddirection

( store number of active asteroids )
variable activeasteroids

( set directions )
( compass points initially )
8 array directionx
8 array directiony
0 0 directionx ! 1 1 directionx !
1 2 directionx ! 1 3 directionx !
0 4 directionx ! -1 5 directionx !
-1 6 directionx ! -1 7 directionx !

-1 0 directiony ! -1 1 directiony !
0 2 directiony ! 1 3 directiony !
1 4 directiony ! 1 5 directiony !
0 6 directiony ! -1 7 directiony !

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

: placeasteroids
  0 activeasteroids !
  
  ( set initial colour and deactivate all asteroids )
  ( colour is used to detect which asteroid )
  ( the bullet has hit)
  
  20 0 do
    i 10 + i asteroidcolour !
    0 i asteroidactive !
    8 rng i asteroiddirection !
  loop
  
  ( place upto 2 asteroid in the top section )
  3 rng 1+ 0 do
    activeasteroids @
    dup 280 rng swap asteroidx !
    dup a0 rng swap asteroidy !
    dup 3 rng 8 + swap asteroidtype !
    1 swap asteroidactive !
    activeasteroids @ 1+ activeasteroids !
  loop

  ( place upto 2 asteroid in the bottom section )
  3 rng 1+ 0 do
    activeasteroids @
    dup 280 rng swap asteroidx !
    dup a0 rng 140 + swap asteroidy !
    dup 3 rng 8 + swap asteroidtype !
    1 swap asteroidactive !
    activeasteroids @ 1+ activeasteroids !
  loop

  ( place upto 2 asteroid in the left section )
  3 rng 1+ 0 do
    activeasteroids @
    dup d6 rng 1ac + swap asteroidx !
    dup 1e0 rng swap asteroidy !
    dup 3 rng 8 + swap asteroidtype !
    1 swap asteroidactive !
    activeasteroids @ 1+ activeasteroids !
  loop
  
  ( place upto 2 asteroid in the right section )
  3 rng 1+ 0 do
    activeasteroids @
    dup d6 rng swap asteroidx !
    dup 1e0 rng swap asteroidy !
    dup 3 rng 8 + swap asteroidtype !
    1 swap asteroidactive !
    activeasteroids @ 1+ activeasteroids !
  loop
;

: setup
  ( hide the terminal )
  terminalhide!
  ( reset the second timer )
  timer1hz! 0 lasttimer !
  ( set the background )
  2a 1 7 background! cs!
  ( hide usl sprite 0 and set monitoring )
  0 0 0 0 0 0 uslsprite!
  0 ff40 ! 
  ( randomly place asteroids )
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

: drawship 
    3f 140 f0 0 vector!
;

: wrapasteroid
  dup dup asteroidx @ 280 /mod drop
  swap asteroidx !
  dup asteroidy @ 1e0 /mod drop
  swap asteroidy !
  ;

: moveasteroids
;
      
: drawasteroids
  20 0 do
    i asteroidactive @ if
      40
      i asteroidx @
      i asteroidy @
      i asteroidtype @
      vector!
      i asteroiddirection @
      dup directionx @ 
      i asteroidx @ + i asteroidx !
      directiony @
      i asteroidy @ + i asteroidy !
      i wrapasteroid 
      i asteroidcolour @
      i asteroidx @
      i asteroidy @
      i asteroidtype @
      vector!
    then
  loop ;

: mainloop
    beepboop
    138 0 uslupdate!
    ( copy the bullet coordinates )
    ff44 @ ff09 !
    ff45 @ ff0a ! 
    drawasteroids drawship vblank?
    hit? ;

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
  
