( double maths )
t: 2over >r >r 2dup r> r> rot >r rot r> t;
t: 2swap rot >r rot r> t;
t: 2nip rot drop rot drop t;
t: 2rot 2>r 2swap 2r> 2swap t;
t: d0= or 0= t;
t: d= >r rot xor swap r> xor or 0= t;
t: d+ rot + >r over + dup rot u< if r> 1+ else r> then t;
t: d- dnegate d+ t;
t: s>d dup 0< t;
t: d1+ 1 literal s>d d+ t;
t: d1- 1 literal s>d dnegate d+ t;
t: dxor rot xor -rot xor swap t;
t: dand rot and -rot and swap t;
t: dor rot or -rot or swap t;
t: dinvert invert swap invert swap t;
t: d2* 2dup d+ t;
t: d2/ dup f literal lshift >r 2/ swap 2/ r> or swap t;

( Buttons and LEDs )
t: led@ f002 literal @ t;
t: led! f002 literal ! t;
t: buttons@ f003 literal @ t;

( Audio )
t: beep! dup ffe2 literal ! ffe6 literal ! dup ffe1 literal ! ffe5 literal ! dup ffe0 literal ! ffe4 literal ! 
  dup ffe3 literal ! ffe7 literal ! t;
t: beep? begin ffe3 literal @ 0= until begin ffe7 literal @ 0= until t;
t: beepL! ffe2 literal ! ffe1 literal ! ffe0 literal ! ffe3 literal ! t;
t: beepR! ffe6 literal ! ffe5 literal ! ffe4 literal ! ffe7 literal ! t;
t: beepL? begin ffe3 literal @ 0= until t;
t: beepR? begin ffe7 literal @ 0= until t;

( Timers )
t: clock@ f004 literal @ t;
t: timer1hz! 1 literal ffed literal ! t;
t: timer1hz@ ffed literal @ t;
t: timer1khz! ffee literal ! t;
t: timer1hz@ ffee literal @ t;
t: timer1khz? begin ffee literal @ 0= until t;
t: sleep ffef literal ! begin ffef literal @ 0= until t;
t: rng ffe0 literal @ swap /mod drop t;

( DISPLAY helper words )
t: vblank? begin ffff literal @ 0<> until t;

t: background! fff2 literal ! fff1 literal ! fff0 literal ! t;

t: gpu? begin ff07 literal @ 0= until t;
t: gpu! gpu? ff07 literal ! t;
t: pixel! ff01 literal ! ff00 literal ! ff02 literal ! 1 literal gpu! t;
t: rectangle! ff04 literal ! ff03 literal ! ff01 literal ! ff00 literal ! ff02 literal ! 2 literal gpu! t;
t: line! ff04 literal ! ff03 literal ! ff01 literal ! ff00 literal ! ff02 literal ! 3 literal gpu! t;
t: circle! ff03 literal ! ff01 literal ! ff00 literal ! ff02 literal ! 4 literal gpu! t;
t: fcircle! ff03 literal ! ff01 literal ! ff00 literal ! ff02 literal ! 6 literal gpu! t;
t: triangle! ff06 literal ! ff05 literal ! ff04 literal ! ff03 literal ! ff01 literal ! ff00 literal ! ff02 literal ! 7 literal gpu! t;
t: blit1! ff01 literal ! ff00 literal ! ff03 literal ! ff02 literal ! 5 literal gpu! t;
t: blit1tile! ff0b literal ! 10 literal begin 1- dup ff0c literal ! swap ff0d literal ! dup 0= until drop t;
t: cs! 40 literal 0 literal 0 literal 2f7 literal 1df literal rectangle! t;

t: lsltile! ff38 literal ! 40 literal begin 1- dup ff39 literal ! swap ff3a literal ! dup 0= until drop t;
t: lslsprite! ( colour x y tile active double number ) ff30 literal ! ff36 literal ! ff31 literal ! ff32 literal ! ff35 literal ! ff34 literal ! ff33 literal ! t;
t: lslupdate! ff30 literal ! ff3e literal ! t;
t: usltile! ff48 literal ! 40 literal begin 1- dup ff49 literal ! swap ff4a literal ! dup 0= until drop t;
t: uslsprite! ( colour x y tile active double number ) ff40 literal ! ff46 literal ! ff41 literal ! ff42 literal ! ff45 literal ! ff44 literal ! ff43 literal ! t;
t: uslupdate! ff40 literal ! ff4e literal ! t;

t: vectorvertex! ff76 literal ! ff75 literal ! ff78 literal ! ff77 literal ! ff79 literal ! 1 literal ff7a literal ! t;
t: vector? begin ff74 literal @ 0= until t;
t: vector! vector? ff70 literal ! ff73 literal ! ff72 literal ! ff71 literal ! 1 literal ff74 literal ! t;

t: dlentry! ff83 literal ! ff8c literal ! ff8b literal ! ff8a literal ! ff89 literal ! ff88 literal ! ff87 literal ! ff86 literal ! ff85 literal ! ff84 literal ! 1 literal ff8d literal ! t;
t: dlstart! ff81 literal ! ff80 literal ! 1 literal ff82 literal ! t;
t: dl? begin ff82 literal @ 0= until t;

t: tpu! ff15 literal ! t;
t: tpuxy! ( x y ) ff11 literal ! ff10 literal ! 1 literal tpu! t;
t: tpuforeground! ( foreground ) ff14 literal ! t;
t: tpubackground! ( background ) ff13 literal ! t;
t: tpuemit ( character ) ff12 literal ! 2 literal tpu! t;
t: tpucs!
    0 literal 0 literal tpuxy!
    0 literal tpuforeground!
    40 literal tpubackground!
    960 literal for aft 0 literal tpuemit then next 
    0 literal 0 literal tpuxy! t;
t: tpuspace bl tpuemit t;
t: tpuspaces 0 literal max for aft tpuspace then next t;
t: tputype for aft count tpuemit then next drop t;
t: tpu.$ count tputype t;
t: tpu.r >r str r> over - tpuspaces tputype t;
t: tpuu.r >r <# #s #> r> over - tpuspaces tputype t;
t: tpuu. <# #s #> tpuspace tputype t;
t: tpu. base @ a literal xor if tpuu. exit then str tpuspace tputype t;
t: tpu.# base @ swap decimal tpu. base ! t;
t: tpuu.# base @ swap decimal <# #s #> tpuspace tputype base ! t;
t: tpuu.r# base @ rot rot decimal >r <# #s #> r> over - tpuspaces tputype base ! t;
t: tpu.r# base @ rot rot decimal >r str r> over - tpuspaces tputype base ! t;

t: tmtile! ff96 literal ! 10 literal begin 1- dup ff97 literal ! swap ff98 literal ! dup 0= until drop t;
t: tm! ff94 literal ! ff93 literal ! ff92 literal ! ff91 literal ! ff90 literal ! 1 literal ff95 literal ! t;
t: tmmove! begin ff9a literal @ 0= until ff99 literal ! t;

t: terminalshow! 1 literal ff21 literal ! t;
t: terminalhide! 0 literal ff21 literal ! t;
