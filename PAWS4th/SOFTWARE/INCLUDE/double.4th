( double maths )
hex
: 2over >r >r 2dup r> r> rot >r rot r> ;
: 2swap rot >r rot r> ;
: 2nip rot drop rot drop ;
: 2rot 2>r 2swap 2r> 2swap ;
: d2! d002 d! d1! ;
: d0= d1! d01c @ ;
: d= d2! d01e @ ;
: d< d2! d01f @ ;
: d+ d2! d000 d@ ;
: d- d2! d002 d@ ;
: s>d dup 0< ;
: d1+ d1! d004 d@ ;
: d1- d1! d006 d@ ;
: dxor d2! d010 d@ ;
: dand d2! d012 d@ ;
: dor d2! d014 d@  ;
: dinvert d1! d00e d@ ;
: d2* d1! d008 d@ ;
: d2/ d1! d00a d@ ;
: dabs d1! d016 d@ ;
: dmax d2! d018 d@ ;
: dmin d2! d01a d@ ;
