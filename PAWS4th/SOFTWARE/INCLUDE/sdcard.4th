( sdcard )
hex
: sdready? begin f140 @ 0<> until ;
: sdreadsector sdready? f142 d! 1 f140 ! sdready? ;
: sd@ f150 ! f150 @ ;
