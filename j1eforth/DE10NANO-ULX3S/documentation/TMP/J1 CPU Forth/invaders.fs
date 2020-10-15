( Space invaders                             JCB 10:43 11/18/10)

: whereis ( t -- x y ) 
    >r
    d# 384 r@ sin* d# 384 +
    r@ d# 4 rshift d# 32 r> 2* sin* +
;

56 constant nsprites

nsprites array invx
nsprites array invy
nsprites array alive
nsprites array invnext
nsprites array anim

: invload ( i -- ) \ load sprite i
    \ s" sprite " type dup . s"  at " type dup invx @ . dup invy @ . cr
    dup invx @ swap
    dup invy @ swap
    dup anim @ swap
    d# 7 and
    tuck cells vga_spritep + !
    sprite!
;

: inv-makedl ( -- )
    erasedl
    nsprites 0do
        \ invy -ve load sprite; +ve gives the dl offset
        i alive @ if
            i invy @ dup 0< if
                drop i invload
            else
                dup d# 512 < if
                    \ dl[y] -> invnext[i]
                    \ i -> dl[y]
                    cells dl + dup
                    @ i invnext !
                    i swap !
                else
                    drop
                then
            then
        then
    loop
;

: inv-chase
    d# 512 0do
        begin vga-line@ i = until
        \ s" line" type i . cr
        i cells dl + @
        begin
            dup d# 0 >=
        while
            dup invload
            invnext @
        repeat
    loop
;

: born ( x y i ) \ sprite i born
    dup alive on
    tuck invy !
    invx !
;

: kill ( i -- ) \ kill sprite i
    d# 512 over invy !
    alive off
;

: isalien   ( u -- f)
    d# 6 and d# 6 <> ;

: moveto ( i -- ) \ move invader i to current position
    dup d# 6 and d# 6 <>
    over alive @ and if
        >r
        frame @ r@ d# 7 and d# 8 * + whereis
        r@ d# 3 rshift d# 40 * +
        r@ invy !
        r> invx !
    else
        drop
    then
;

: bomb ( u -- u ) d# 3 lshift d# 6 + ;
: shot ( u -- u ) d# 3 lshift d# 7 + ;

8 array lowest

: findlowest
    d# 8 0do d# -1 i lowest ! loop
    d# 48 0do
        i alive @ if
            i dup d# 7 and lowest !
        then
    loop
;

create bias 0 , 1 , 2 , 3 , 4 , 5 , 0 , 5 ,
: rand6
    time @ d# 7 and cells bias + @
;

2variable bombalarm
variable nextbomb

2variable shotalarm
variable nextshot

variable playerx
variable lives
2variable score
variable dying

32 constant girth

: 1+mod6 ( a )
    dup @ dup d# 5 = if d# -5 else d# 1 then + swap ! ;

: .status
    'emit @ >r ['] vga-emit 'emit !

    home
    s" LIVES " type lives @ .
    d# 38 d# 0 vga-at-xy
    s" SCORE " type score 2@ <# # # # # # # #> type
    cr

    lives @ 0= if
        ['] vga-bigemit 'emit !
        d# 8 d# 7  vga-at-xy s" GAME" type
        d# 8 d# 17 vga-at-xy s" OVER" type
    then

    r> 'emit !
;

: newlife
    d# -1 lives +! .status
    d# 0 dying !
    d# 100 playerx !
;

: parabolic ( dx dy i -- ) \ move sprite i in parabolic path
    >r
    swap r@ invx +!
    dying @ d# 3 rshift +
    r> invy +!
;

: exploding
    d# 3  d# -4 d# 48 parabolic
    d# -3 d# -4 d# 49 parabolic
    d# -4 d# -3 d# 50 parabolic
    d# 4  d# -3 d# 51 parabolic
    d# -5 d# -2 d# 52 parabolic
    d# 5  d# -2 d# 53 parabolic
    d# 1  d# -2 d# 55 parabolic
;

: @xy ( i -- x y )
    dup invx @ swap invy @ ;

: dist ( u1 u2 )
    invert + dup 0< xor ;

: fall
    d# 6 0do
        i bomb
        d# 4 over invy +!
        @xy d# 470 dist d# 16 < swap
        playerx @ dist girth < and
        dying @ 0= and if
            d# 1 dying !
        then
    loop
;

: trigger \ if shotalarm expired, launch new shot
    shotalarm isalarm if
        d# 400000. shotalarm setalarm
        playerx @ d# 480
        nextshot @ shot born
        nextshot 1+mod6
    then
;

: collide ( x y -- u )
    d# 48 0do
        i isalien i alive @ and if
            over i invx @ dist d# 16 <
            over i invy @ dist d# 16 < and if
                2drop i unloop exit
            then
        then
    loop
    2drop
    d# -1
;

: rise
    d# 6 0do
        i shot >r r@ alive @ if
            d# -5 r@ invy +!
            r@ invy @ d# -30 < if r@ kill then
            r@ @xy collide dup 0< if
                drop
            else
                kill r@ kill
                d# 10. score 2@ d+ score 2!
                .status
            then
        then
        r> drop
    loop
;

: doplayer
    lives @ if
        dying @ 0= if
            buttons >r

            girth 2/ playerx @ <
            r@ pb2 and and if
                d# -4 playerx +!
            then

            playerx @ d# 800 girth 2/ - <
            r@ pb3 and and if
                d# 4 playerx +!
            then

            r> pb4 and if
                trigger
            \ else trigger
            then

            d# 6 0do
                frame @ d# 3 lshift i d# 42 * +
                girth swap sin* playerx @ +
                d# 480
                i d# 48 +
                dup anim on
                born
            loop
            playerx @ d# 470 d# 55 born
        else
            exploding
            d# 1 dying +!
            dying @ d# 100 > if
                newlife
            then
        then
    then
;

create cscheme
    h# 400 ,
    h# 440 ,
    h# 040 ,
    h# 044 ,
    h# 004 ,
    h# 404 ,
    h# 340 ,
    h# 444 ,

: invaders-cold
    vga-page
    d# 16384 0do
        h# 208000. 2/ i s>d d+ flash@
        i vga_spritea !  vga_spriteport !
    loop

    vga_addsprites on
    rainbow

    \ vga_spritep d# 6 cells + on

    \ everything dead
    nsprites 0do
        i kill
    loop

    \ all aliens alive
    d# 48 0do 
        i isalien i alive !
    loop

    d# 500000. bombalarm setalarm
    d# 0 nextbomb !
    d# 100000. shotalarm setalarm
    d# 0 nextshot !
    d# 4 lives !
    d# 0. score 2!

    newlife

    time@ xor seed !
    d# 0 frame !
    d# 48 0do i moveto loop
;

0 [IF]
: escape
    vision isalarm next? or ;
: restart
    vision isalarm sw2_n @ 0= or ;
[ELSE]
: escape
    next? ;
: restart
    sw2_n @ 0= ;
[THEN]

: gameloop
    invaders-cold
    begin
depth if snap then
        inv-makedl
depth if snap then
        inv-chase
depth if snap then
        frame @ 1+ frame !
        d# 48 0do i moveto loop
        findlowest
        bombalarm isalarm if
            d# 800000. bombalarm setalarm
            rand6 lowest @ dup 0< if
                drop
            else
                dup invx @ swap invy @
                dup d# 460 > if d# 1 dying ! then
                nextbomb @ bomb born
                nextbomb 1+mod6
            then
        then
depth if snap then
        fall
depth if snap then
        rise
depth if snap then
        doplayer
depth if snap then
        escape if exit then
    again
;

: invaders-main
    invaders-cold
    d# 9000000. vision setalarm

    gameloop
    snap

    frame @ . s"  frames" type cr
;

