( Sine and cosine                            JCB 18:29 11/18/10)

create sintab

meta

: mksin
    65 0 do
        i s>d d>f 128e0 f/ pi f* fsin
        32767e0 f* f>d drop
        t,
    loop
;
mksin

target

: sin ( th -- v )
    dup d# 128 and >r
    d# 127 and
    dup d# 63 > if
        invert d# 129 + \ 64->64, 65->63
    then
    cells sintab + @
    r> if
        negate
    then
;

: cos d# 64 + sin ;

: sin* ( s th -- sinth * s )
    sin swap 2* m* nip ;

: cos* ( s th -- costh * s )
    cos swap 2* m* nip ;
