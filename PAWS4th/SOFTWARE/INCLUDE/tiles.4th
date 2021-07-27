( tile map )
hex
: tml? begin c122 @ 0= until ;
: tmu? begin c222 @ 0= until ;
: tmlmove! tml? c120 ! ;
: tmumove! tmu? c220 ! ;
: tmlcs 9 tmlmove! ;
: tmucs 9 tmumove! ;
: tmltile! c110 ! 10 begin 1- dup c112 ! swap c114 ! dup 0= until drop ;
: tmutile! c210 ! 10 begin 1- dup c212 ! swap c214 ! dup 0= until drop ;
: tml! c106 ! c108 ! c104 ! c102 ! c100 ! 1 c10a ! ;
: tmu! c206 ! c208 ! c204 ! c202 ! c200 ! 1 c20a ! ;
