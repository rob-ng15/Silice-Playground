( Timers )
hex
: clock@ e040 @ ;
: timer1hz! 1 e010 ! ;
: timer1hz@ e010 @ ;
: timer1khz! e020 ! ;
: timer1khz@ e020 @ ;
: timer1khz? begin e020 @ 0= until ;
: sleep e030 ! begin e030 @ 0= until ;
: rng e000 @ swap /mod drop ;
: qrng e000 @ swap and ;
