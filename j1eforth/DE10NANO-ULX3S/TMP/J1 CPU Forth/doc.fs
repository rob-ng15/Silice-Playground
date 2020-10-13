( Documentation conventions                  JCB 14:37 10/26/10)

meta

: getword ( -- a u )
    begin
        bl word count dup 0=
    while
        2drop refill true <> abort" Failed to find word"
    repeat
;

: ================================================================
    begin
        getword
        nip 64 =
    until
;

target
