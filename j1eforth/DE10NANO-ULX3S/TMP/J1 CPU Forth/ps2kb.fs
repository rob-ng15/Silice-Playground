( PS/2 keyboard handler                      JCB 18:29 11/21/10)

================================================================

Keycodes represent raw keypresses.  Need to map these to
ASCII characters.  Each key can generate several ASCII
codes depending on the state of the SHIFT/CTRL keys.

Could use table giving keycode->ascii, but most keys
generate two codes, so would need word for each.
Keycodes 00-83.  Storage 262 bytes.

Table of N ascii codes, each entry specifies a keycode
and shift state

================================================================

module[ ps2kb"

meta

create asciikb 144 allot
asciikb 144 erase

\ 1 word for each key.
\ if high bit is zero, then 

h# 84 constant nscancodes
create scanmap nscancodes cells allot
scanmap nscancodes cells 2constant scanmap_
scanmap_ erase

: scanmap! ( n u -- ) \ write n to cell u in scanmap
    cells scanmap + !
;

\ knowkey   plain xx                            f0xx
\ knowkey-n plain 3x, yy numlock                exyy
\ knowkey-h shift mask yy                       d0yy
\ knowkey-s plain xx, shifted^caps yy           xxyy

h# f000 constant plainmask
h# e000 constant numlockmask
h# d000 constant shiftmask

: wordval   bl word count evaluate ;

: knowkey
    wordval
    plainmask or
    swap scanmap!
;
: knowkey-s
    \ dup char asciikb + c!
    \ 128 or
    \ char asciikb + c!
    char 8 lshift char or
    swap scanmap!
;
: knowkey-h
    wordval shiftmask or
    swap scanmap!
;
: knowkey-n
    \ dup char asciikb + c!
    \ 128 or
    \ char asciikb + c!
    char [char] . - 8 lshift wordval or
    numlockmask or
    swap scanmap!
;

h# 01 constant SHIFTL
h# 02 constant SHIFTR
h# 04 constant CONTROL
h# 08 constant ALT
char * constant ASTERISK
char - constant MINUS
char + constant PLUS
char 5 constant FIVE

include keycodes.fs

h# 76 knowkey ESC
h# 05 knowkey KF1
h# 06 knowkey KF2
h# 04 knowkey KF3
h# 0c knowkey KF4
h# 03 knowkey KF5
h# 0b knowkey KF6
h# 83 knowkey KF7
h# 0a knowkey KF8
h# 01 knowkey KF9
h# 09 knowkey KF10
h# 78 knowkey KF11
h# 07 knowkey KF12

h# 0e knowkey-s ` ~ 
h# 16 knowkey-s 1 ! 
h# 1e knowkey-s 2 @ 
h# 26 knowkey-s 3 # 
h# 25 knowkey-s 4 $ 
h# 2e knowkey-s 5 % 
h# 36 knowkey-s 6 ^ 
h# 3d knowkey-s 7 & 
h# 3e knowkey-s 8 * 
h# 46 knowkey-s 9 ( 
h# 45 knowkey-s 0 ) 
h# 4e knowkey-s - _ 
h# 55 knowkey-s = + 
h# 5d knowkey-s \ | 
h# 66 knowkey KDEL

h# 0d knowkey TAB
h# 15 knowkey-s q Q
h# 1d knowkey-s w W
h# 24 knowkey-s e E
h# 2d knowkey-s r R
h# 2c knowkey-s t T
h# 35 knowkey-s y Y
h# 3c knowkey-s u U
h# 43 knowkey-s i I
h# 44 knowkey-s o O
h# 4d knowkey-s p P
h# 54 knowkey-s [ {
h# 5b knowkey-s ] }
h# 5a knowkey ENTER

h# 58 knowkey -1
h# 1c knowkey-s a A
h# 1b knowkey-s s S
h# 23 knowkey-s d D
h# 2b knowkey-s f F
h# 34 knowkey-s g G
h# 33 knowkey-s h H
h# 3b knowkey-s j J
h# 42 knowkey-s k K
h# 4b knowkey-s l L
h# 4c knowkey-s ; :
h# 52 knowkey-s ' "

h# 1a knowkey-s z Z
h# 22 knowkey-s x X
h# 21 knowkey-s c C
h# 2a knowkey-s v V
h# 32 knowkey-s b B
h# 31 knowkey-s n N
h# 3a knowkey-s m M
h# 41 knowkey-s , <
h# 49 knowkey-s . >
h# 4a knowkey-s / ?

h# 29 knowkey BL

h# 12 knowkey-h SHIFTL
h# 59 knowkey-h SHIFTR
h# 14 knowkey-h CONTROL
h# 11 knowkey-h ALT

h# 70 knowkey-n 0 KINS
h# 71 knowkey-n . KDEL
h# 69 knowkey-n 1 KEND
h# 72 knowkey-n 2 KDOWN
h# 7a knowkey-n 3 KPGDN
h# 6b knowkey-n 4 KLEFT
h# 73 knowkey     FIVE 
h# 74 knowkey-n 6 KRIGHT
h# 6c knowkey-n 7 KHOME
h# 75 knowkey-n 8 KUP
h# 7d knowkey-n 9 KPGUP
h# 77 knowkey -2
h# 7c knowkey     ASTERISK
h# 7b knowkey     MINUS
h# 79 knowkey     PLUS

: t,c ( c-addr u -- ) \ compile u cells into target memory
    0 do
        dup @ t, cell+
    loop
    drop
;

target create scanmap meta
scanmap nscancodes t,c

target

include keycodes.fs

: scanmap@ ( u - u ) \ return scanmap entry u
    cells scanmap + @ ;

variable kbread         \ read ptr into 64-bit KB fifo
variable kbstate        \ accumulates 11-bit code

: ps2listening
    ps2_clk_dir in
    ps2_dat_dir in
;
: kbfifo@ ( u -- f )    \ read bit u from 64-bit KB fifo
    dup d# 4 rshift 2* kbfifo + @
    swap d# 15 and rshift d# 1 and
;
: kbnew ( -- ) \ start accumulating new code
    h# 800 kbstate !
;
: kbfifo-cold
    kbfifocount @ kbread !
    kbnew
;
: kbfifo-fullness ( -- u ) \ how many unread bits in the kbfifo
    kbfifocount @ kbread @ - h# ff and
;

variable ps2_clk'
: waitfall \ wait for falling edge on ps2_clk
    begin ps2_clk @ ps2_clk' fall? until ;

: ps2-out1 ( u -- ) \ send lsb of u to keyboard
    ps2_dat ! waitfall ;

: oddparity ( u1 -- u2 ) \ u2 is odd parity of u1
    dup d# 4 rshift xor
    dup d# 2 rshift xor
    dup 2/ xor
;

: kb-request
    ps2_clk_dir out ps2_clk off \ clock low
    d# 60. sleepus
    ps2_dat_dir out ps2_dat off \ dat low
    ps2_clk_dir in              \ release clock

    begin ps2_clk @ until
    ps2_clk' on

    \ bad keyboard hangs here
    false ps2-out1              \ start

    dup 
    d# 8 0do
        dup ps2-out1 2/
    loop
    drop

    oddparity ps2-out1          \ parity
    true ps2-out1               \ stop

    ps2listening \ waitfall
    kbfifo-cold
;

: kbbit
    d# 11 lshift kbstate @ 2/ or
    kbstate !
;
: rawready? ( -- f) \ is the raw keycode ready?
    kbstate @ d# 1 and ;

: kbraw ( -- u ) \ get the current raw keycode
    kbstate @ d# 2 rshift h# ff and
    kbnew
;

variable lock

: rawloop
    begin
        kbfifocount @ lock !
        kbfifo-fullness 0<>
        rawready? 0= and
    while
        kbfifo-fullness 1- kbfifo@
        kbfifocount @ lock @ = if
            kbbit d# 1 kbread +!
        else
            drop
        then
    repeat
;

: oneraw
    begin
        rawloop
        rawready?
    until
    kbraw
;

: >leds ( u -- ) \ set keyboard leds (CAPS NUM SCROLL)
    h# ed kb-request
    oneraw drop
    kb-request
;

( Decoding                                   JCB 19:25 12/04/10)

variable capslock
variable numlock
variable isrelease  \ is this is key release
variable ise0       \ is this an E0-prefix key
0 value mods        \ bitmask of modifier keys
                    \ RALT RCTRL -- -- LALT LCTRL RSHIFT LSHIFT

: lrshift? ( -- f ) \ is either shift pressed?
    mods h# 03 and ;
: lrcontrol?
    mods h# 44 and ;
: lralt?
    mods h# 88 and ;

variable curkey

: append ( u -- ) \ join u with mods write to curkey
    h# ff and mods d# 8 lshift or
    curkey !
;

: shiftmask
    h# ff and
    ise0 @ if d# 4 lshift then
;
: shift-press ( u -- ) \ a shift key was pressed
    shiftmask mods or to mods ;
: shift-release ( u -- ) \ a shift key was released
    shiftmask invert mods and to mods ;

: shiftable-press ( u -- ) \ a shiftable key was pressed
    mods d# 3 and 0= capslock @ xor if
        d# 8 rshift
    then
    append
;
: ignore drop ;

: myleds \ compute led values from caps/numlock, send to KB
    numlock @ d# 2 and
    capslock @ d# 4 and
    or
    >leds 
;

: toggle ( a -- ) \ invert cell at a
    dup @ invert swap ! ;

: plain-press ( u -- )
    dup d# -1 = if
        drop capslock toggle myleds
    else
        dup d# -2 = if
            drop numlock toggle myleds
        else
            append
        then
    then
;

: num-press
    \ if e0 prefix, low code, else hi code or 30
    \ e0  numlock
    \ 0   0         cursor
    \ 0   1         num
    \ 1   0         cursor
    \ 1   1         cursor
    ise0 @ 0= numlock @ and if
        d# 8 rshift h# f and [char] . +
    then
    append
;

jumptable keyhandler
\          PRESS                RELEASE
( 0 )    | shiftable-press      | ignore
( d )    | shift-press          | shift-release
( e )    | num-press            | ignore
( f )    | plain-press          | ignore

: handle-raw ( u -- )
    dup h# e0 = if
        drop ise0 on
    else
        dup h# f0 = if
            drop isrelease on
        else
            dup h# 84 < if
                scanmap@
                \ hi 4 bits,
                \     1100 -> 0
                \     1101 -> 1
                \     1110 -> 2
                \     1111 -> 3
                \
                dup d# 12 rshift d# 12 - d# 0 max

                2* isrelease @ + keyhandler execute

                isrelease off
                ise0 off
            else
                drop
            then
        then
    then
;

( kb: high-level keyboard                    JCB 19:45 12/04/10)

: kb-cold
    ps2listening kbfifo-cold
    h# 7 >leds
    sleep.1
    h# 0 >leds

    numlock off
    capslock off
    curkey off
;

: kbfifo-proc
    rawloop
    rawready? if
        kbraw handle-raw
    then
;

: key?  ( -- flag )
    kbfifo-proc
    curkey @ 0<> ;
: key   ( -- u )
    begin key? until
    curkey @ curkey off ;

]module

