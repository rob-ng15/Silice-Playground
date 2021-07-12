variable x
variable dx
variable wx
variable jx
variable tx
variable y
variable dy
variable wy
variable jy
variable ty
variable k
variable r
140 constant xres
f0 constant yres
c033 constant xmin ( -2.1 )
38cd constant xmax ( 0.6 )
bd66 constant ymin ( -1.35 )
3d66 constant ymax ( 1.35 )
2 s>f constant ftwo ( 2.0 )
4 s>f constant ffour ( 4.0 )

: calcdx xmax xmin f- xres s>f f/ dx ! ;
: calcdy ymax ymin f- yres s>f f/ dy ! ;
: calcjy y @ s>f dy @ f* ymin f+ jy ! ;
: calcjx x @ s>f dx @ f* xmin f+ jx ! ;
: calctx wx @ dup f* wy @ dup f* f- jx @ f+ tx ! ;
: calcty wx @ wy @ f* ftwo f* jy @ f+ ty ! ;
: calcr wx @ dup f* wy @ dup f* f+ r ! ;

: calculate
    calctx
    calcty
    tx @ wx ! ty @ wy !
    calcr
    1 k +! ;

: newpixel 0 k ! 0 wx ! 0 wy ! ;
: calculatepixel
    newpixel
    begin
        calculate
        r @ ffour f<
        k @ 40 < and
    0= until
    k @ ;

: xloop 140 0 do i x ! calcjx calculatepixel pbpixel! loop ;
: yloop f0 0 do i y ! calcjy xloop loop ;
: mandel
    timer1hz!
    0 terminal!
    cs
    0 0 140 40 pbstart!
    calcdx calcdy
    yloop
    timer1hz@ .
    pbstop!
    fa0 sleep 1 terminal! ;

mandel
