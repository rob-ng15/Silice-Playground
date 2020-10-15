( Main file for pure ANS forth               JCB 13:53 11/27/10)

: parse-word
    bl word count ;

: defer create                    ( "name" -- )
    ['] abort ,  does> @ execute ;

: include                         ( "filename" -- )
    bl word count included  decimal ;

: is                              ( xt "name" -- )
    '                               ( xt xt2)
    state @ if
        postpone literal  postpone >body  postpone !
    else
        >body !
    then ; immediate


: include                         ( "filename" -- )
    bl parse included  decimal ;

    : Do-Vocabulary                   ( -- )
        DOES>  @ >R                     ( )( R: widnew)
            GET-ORDER  SWAP DROP        ( wid_n ... wid_2 n)
        R> SWAP SET-ORDER ;

: VOCABULARY                      ( "name" -- )
    WORDLIST CREATE ,  Do-Vocabulary ;

: -rot      rot rot ;
: nstime     0. ;
: <=        > invert ;
: >=        < invert ;
: d0<>      d0= invert ;

: f>        fswap f< ;
: f<=       f> invert ;
: f>=       f< invert ;
: f=        0e0 f~ ;
: f<>       f= invert ;

3.1415926e0 fconstant pi

include main.fs
