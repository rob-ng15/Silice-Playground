( character map )
hex
: tpu? begin c50a @ 0= until ;
: tpu! tpu? c50a ! ;
: tcolour! c506 ! c508 ! ;
: tpuxy! c502 ! c500 ! 1 tpu! ;
: tpuemit c504 ! 2 tpu! ;
: tpuspace bl tpuemit ;
: tpuspaces 0 max for aft tpuspace then next ;
: tputype for aft count tpuemit then next drop ;
: tpu.$ count tputype ;
: tpu.r >r str r> over - tpuspaces tputype ;
: tpuu.r >r <# #s #> r> over - tpuspaces tputype ;
: tpuu. <# #s #> tpuspace tputype ;
: tpu. base @ a xor if tpuu. exit then str tpuspace tputype ;
: tpu.# base @ swap decimal tpu. base ! ;
: tpuu.# base @ swap decimal <# #s #> tpuspace tputype base ! ;
: tpuu.r# base @ rot rot decimal >r <# #s #> r> over - tpuspaces tputype base ! ;
: tpu.r# base @ rot rot decimal >r str r> over - tpuspaces tputype base ! ;
: tcs 3 tpu! 0 3f tcolour! ;
