( Time access                                JCB 13:27 08/24/10)

variable prevth     \ previous high time
2variable timeh     \ high 32 bits of time

: time@  ( -- time. )
    begin
        time 2@
        time 2@
        2over d<>
    while
        2drop
    repeat

\   dup prevth fall? if
\       d# 1. timeh d+!
\   then
;

: timeq     ( -- d d ) \ 64-bit time
    time@ timeh 2@ ;

: setalarm ( d a -- ) \ set alarm a for d microseconds hence
    >r time@ d+ r> 2! ;
: isalarm ( a -- f )
    2@ time@ d- d0<= ;

2variable sleeper
: sleepus   sleeper setalarm begin sleeper isalarm until ;
: sleep.1   d# 100000. sleepus ;
: sleep1    d# 1000000. sleepus ;

: took ( d -- ) time@ 2swap d- s" took " type d. cr ;
