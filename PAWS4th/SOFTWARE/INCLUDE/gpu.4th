( GPU )
hex
: gpu? begin c612 @ 0= until ;
: gpu! gpu? c612 ! ;
: fullscreen! 0 0 13f ef ;
: coords2! c602 ! c600 ! ;
: coords4! c60c ! c60a ! coords2! ;
: coords6! c610 ! c60e ! coords4! ;
: colour! c608 ! c606 ! c604 ! ;
: pixel coords2! 1 gpu! ;
: line coords4! 2 gpu! ;
: rectangle coords4! 3 gpu! ;
: circle coords4! 4 gpu! ;
: fcircle coords4! 5 gpu! ;
: triangle coords6! 6 gpu! ;
: blit coords4! 7 gpu! ;
: blittile! c640 ! 10 begin 1- dup c642 ! swap c644 ! dup 0= until drop ;
: charblit coords4! 8 gpu! ;
: colblit coords4! 9 gpu! ;
: pbstart! coords4! a gpu! ;
: pbpixel! c670 ! ;
: pbstop! 3 c678 ! ;
: bmmove! gpu? c6e0 ! ;
: cs 40 0 0 colour! fullscreen! rectangle 5 bmmove! ;

