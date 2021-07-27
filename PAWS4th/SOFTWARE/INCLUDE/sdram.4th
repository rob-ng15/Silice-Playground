( sdram )
hex
: ram? begin ff02 @ 0= until ;
: ramaddr! ram? ff04 d! ;
: ram! ramaddr! ff00 ! 2 ff02 ! ;
: ram@ ramaddr! 1 ff02 ! ram? ff00 @ ;
