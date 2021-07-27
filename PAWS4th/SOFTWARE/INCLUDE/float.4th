( float maths )
hex
: fpu1! d100 ! ;
: fpu2! d101 ! fpu1! ;
: fpu? begin d102 @ 0= until ;
: fpu! d102 ! ;
: fpu@ swap fpu! fpu? @ ;
: s>f fpu1! 1 d110 fpu@ ;
: f>s fpu1! 2 d111 fpu@ ;
: f+ fpu2! 3 d112 fpu@ ;
: f- fpu2! 4 d113 fpu@ ;
: f* fpu2! 5 d114 fpu@ ;
: f/ fpu2! 6 d115 fpu@ ;
: fsqrt fpu1! 7 d116 fpu@ ;
: f< fpu2! d117 @ ;
: f= fpu2! d118 @ ;
: f<= fpu2! d119 @ ;
: f.# base @ swap decimal
   bl emit
   dup f>s dup 0 .r 2e emit
   s>f f- 3e8 s>f f* f>s
   dup 64 < if 30 emit then
   dup a < if 30 emit then
   0 .r
   base ! ;
: tpuf.# base @ swap decimal
   bl tpuemit
   dup f>s dup 0 tpu.r 2e tpuemit
   s>f f- 3e8 s>f f* f>s
   dup 64 < if 30 tpuemit then
   dup a < if 30 tpuemit then
   0 tpu.r
   base ! ;

