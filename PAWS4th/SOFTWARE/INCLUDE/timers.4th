( Timers )
hex
: clock@ e01c @ ;
: timer1hz! 1 e010 ! ;
: timer1hz@ e010 @ ;
: timer1khz! e014 ! ;
: timer1khz@ e014 @ ;
: timer1khz? begin e014 @ 0= until ;
: sleep e018 ! begin e018 @ 0= until ;
: rng e000 @ swap /mod drop ;
: qrng e000 @ swap and ;
