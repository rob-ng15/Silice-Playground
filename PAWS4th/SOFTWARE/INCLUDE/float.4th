( float maths )
hex
: fpu1! d100 ! ;
: fpu2! d101 ! fpu1! ;
: fpu? begin d102 @ 0= until ;
: fpu! d102 ! ;
: fpu@ swap fpu! fpu? @ ;
: s>f fpu1! d110 @ ;
: f>s fpu1! d111 @ ;
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
   dup a s>f f* f>s a /
   dup 0 .r 2e emit
   s>f f- 3e8 s>f f* f>s
   dup 64 < if 30 emit then
   dup a < if 30 emit then
   0 .r
   base ! ;
: tpu? begin c50a @ 0= until ;
: tpu! tpu? c50a ! ;
: tpuemit c504 ! 2 tpu! ;
: tpuspace bl tpuemit ;
: tpuspaces 0 max for aft tpuspace then next ;
: tputype for aft count tpuemit then next drop ;
: tpu.r >r str r> over - tpuspaces tputype ;
: tpuf.# base @ swap decimal
   bl tpuemit
   dup a s>f f* f>s a /
   dup 0 tpu.r 2e tpuemit
   s>f f- 3e8 s>f f* f>s
   dup 64 < if 30 tpuemit then
   dup a < if 30 tpuemit then
   0 tpu.r
   base ! ;

