( Audio )
hex
: beep? 2* e110 + begin dup @ 0= until drop ;
: beep! e104 ! e102 ! e100 ! e106 ! ;

