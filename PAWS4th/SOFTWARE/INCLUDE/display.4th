( DISPLAY helper words )
hex
: vblank? begin cf00 @ 0<> until ;
: screen! cf00 ! ;
: framebuffer! begin c614 @ 0= until vblank? c6f2 ! c6f0 ! ;
: terminal! c702 ! ;
: background! c004 ! c002 ! c000 ! ;
