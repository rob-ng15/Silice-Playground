( sprites )
hex
variable _pointer
: sprite!
   _pointer @ ! 20 _pointer @ + _pointer !
   _pointer @ ! 20 _pointer @ + _pointer !
   _pointer @ ! 20 _pointer @ + _pointer !
   swap _pointer @ ! 20 _pointer @ + _pointer !
   _pointer @ ! 20 _pointer @ + _pointer !
   _pointer @ ! 20 _pointer @ + _pointer ! ;
: lsprite 2* c300 + _pointer ! sprite! ;
: usprite 2* c400 + _pointer ! sprite! ;
: lspritetile! c800 ! 80 begin 1- dup c802 ! swap c804 ! dup 0= until drop ;
: uspritetile! c900 ! 80 begin 1- dup c902 ! swap c904 ! dup 0= until drop ;
: lspriteupdate 2* c3c0 + ! ;
: uspriteupdate 2* c4c0 + ! ;
: lsprite@ 2* swap 20 * c300 + + @ ;
: usprite@ 2* swap 20 * c400 + + @ ;
