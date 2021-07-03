variable x
variable wx
variable jx
variable tx
variable y
variable wy
variable jy
variable ty
variable k
variable r

c033 constant xmin
38cd constant xmax
bd66 constant ymin
3d66 constant ymax

4000 constant ftwo
4400 constant ffour

2052 constant dx
21c3 constant dy

: drawpixel x @ y @ pixel ;

: calcjy y @ s>f dy f* ymin f+ jy ! ;
: calcjx x @ s>f dx f* xmin f+ jx ! ;

: calctx wx @ dup f* wy @ dup f* f- jx @ f+ tx ! ;
: calcty wx @ wy @ f* ftwo f* jy @ f+ ty ! ;

: calcr wx @ dup f* wy @ dup f* f+ r ! ;

: newpixel 0 k ! 0 wx ! 0 wy ! ;
: calculate
    calctx tx @ wx !
    calcty ty @ wy !
    calcr
    k @ 1+ k ! ;

: calculatepixel
    newpixel
    begin
        calculate
        r @ ffour f<
        k @ 3f < and
    0= until
    k @ 1+ 0 0 colour! drawpixel
    ;

: yloop f0 0 do i y ! calcjy calculatepixel drawpixel loop ;
: xloop 140 0 do i x ! calcjx yloop loop ;
: mandel xloop ;
