( Nucleus: ANS Forth core and ext words      JCB 13:11 08/24/10)

module[ nuc"

32 constant sp
0 constant false ( 6.2.1485 )
: depth dsp h# ff and ;
: true  ( 6.2.2298 ) d# -1 ;
: 1+    d# 1 + ;
: rot   >r swap r> swap ;
: -rot  swap >r swap r> ;
: 0=    d# 0 = ;
: tuck  swap over ;
: 2drop drop drop ;
: ?dup  dup if dup then ;

: split                     ( a m -- a&m a&~m )
    over                    \ a m a
    and                     \ a a&m
    tuck                    \ a&m a a&m
    xor                     \ a&m a&~m
;

: merge ( a b m -- m?b:a )
    >r          \ a b
    over xor    \ a a^b
    r> and      \ a (a^b)&m
    xor         \ ((a^b)&m)^a
;

: c@    dup @ swap d# 1 and if d# 8 rshift else d# 255 and then ;
: c!    ( u c-addr )
        swap h# ff and dup d# 8 lshift or swap
        tuck dup @ swap         ( c-addr u v c-addr )
        d# 1 and d# 0 = h# ff xor
        merge swap !
;
: c!be d# 1 xor c! ;

: looptest  ( -- FIN )
    r>          ( xt )
    r>          ( xt i )
    1+
    r@ over =   ( xt i FIN )
    dup if
        nip r> drop
    else
        swap >r
    then        ( xt FIN )
    swap
    >r
;

\ Stack
: 2dup  over over ;
: +!    tuck @ + swap ! ;

\ Comparisons
: <>        = invert ;
: 0<>       0= invert ;
: 0<        d# 0 < ;
: 0>=       0< invert ;
: 0>        d# 0 ;fallthru
: >         swap < ;
: >=        < invert ;
: <=        > invert ;
: u>        swap u< ;

\ Arithmetic
: negate    invert 1+ ;
: -         negate + ;
: abs       dup 0< if negate then ;
: min       2dup < ;fallthru
: ?:        ( xt xf f -- xt | xf) if drop else nip then ;
: max       2dup > ?: ;
code cells end-code
code addrcells end-code
: 2*        d# 1 lshift ;
code cell+ end-code
code addrcell+ end-code
: 2+        d# 2 + ;
: 2-        1- 1- ;
: 2/        d# 1 rshift ;
: c+!       tuck c@ + swap c! ;

: count     dup 1+ swap c@ ;
: /string   dup >r - swap r> + swap ;
: aligned   1+ h# fffe and ;

: sliteral
    r>
    count
    2dup 
    +
    aligned
;fallthru
: execute >r ;

: 15down down1 ;fallthru
: 14down down1 ;fallthru
: 13down down1 ;fallthru
: 12down down1 ;fallthru
: 11down down1 ;fallthru
: 10down down1 ;fallthru
: 9down down1 ;fallthru
: 8down down1 ;fallthru
: 7down down1 ;fallthru
: 6down down1 ;fallthru
: 5down down1 ;fallthru
: 4down down1 ;fallthru
: 3down down1 ;fallthru
: 2down down1 ;fallthru
: 1down down1 ;fallthru
: 0down copy ;

: 15up up1     ;fallthru
: 14up up1     ;fallthru
: 13up up1     ;fallthru
: 12up up1     ;fallthru
: 11up up1     ;fallthru
: 10up up1     ;fallthru
: 9up up1     ;fallthru
: 8up up1     ;fallthru
: 7up up1     ;fallthru
: 6up up1     ;fallthru
: 5up up1     ;fallthru
: 4up up1     ;fallthru
: 3up up1     ;fallthru
: 2up up1     ;fallthru
: 1up up1     ;fallthru
: 0up         ;

code pickbody
    copy    return
    1down   scall   1up ubranch
    2down   scall   2up ubranch
    3down   scall   3up ubranch
    4down   scall   4up ubranch
    5down   scall   5up ubranch
    6down   scall   6up ubranch
    7down   scall   7up ubranch
    8down   scall   8up ubranch
    9down   scall   9up ubranch
    10down  scall   10up ubranch
    11down  scall   11up ubranch
    12down  scall   12up ubranch
    13down  scall   13up ubranch
    14down  scall   14up ubranch
    15down  scall   15up ubranch
end-code

: pick
    dup 2* 2* ['] pickbody + execute ;

: swapdown
    ]asm
        N     T->N              alu
        T                   d-1 alu
    asm[
;
: swapdowns
    swapdown swapdown swapdown swapdown
    swapdown swapdown swapdown swapdown
    swapdown swapdown swapdown swapdown
    swapdown swapdown swapdown swapdown ;fallthru
: swapdown0 ;
: roll
    2*
    ['] 0up over - >r
    ['] swapdown0 swap - execute
;

\ ========================================================================
\ Double
\ ========================================================================

: d=                        ( a b c d -- f )
    >r                      \ a b c
    rot xor                 \ b a^c
    swap r> xor             \ a^c b^d
    or 0=
;

: 2@                        ( ptr -- lo hi )
    dup @ swap 2+ @
;

: 2!                        ( lo hi ptr -- )
    rot over                \ hi ptr lo ptr
    ! 2+ !
;

: 2over >r >r 2dup r> r> ;fallthru
: 2swap rot >r rot r> ;
: 2nip rot drop rot drop ;
: 2rot ( d1 d2 d3 -- d2 d3 d1 ) 2>r 2swap 2r> 2swap ;
: 2pick
    2* 1+ dup 1+            \  lo hi ... 2k+1 2k+2
    pick                    \  lo hi ... 2k+1 lo
    swap                    \  lo hi ... lo 2k+1
    pick                    \  lo hi ... lo hi
;


: d+                              ( augend . addend . -- sum . )
    rot + >r                      ( augend addend)
    over +                        ( augend sum)
    dup rot                       ( sum sum augend)
    u< if                         ( sum)
        r> 1+
    else
        r>
    then                          ( sum . )
;

: +h ( u1 u2 -- u1+u2/2**16 )
    over +     ( a a+b )
    u> d# 1 and
;

: +1c   \ one's complement add, as in TCP checksum
    2dup +h + +
;

: s>d dup 0< ;
: d1+ d# 1. d+ ;
: dnegate
    invert swap invert swap
    d1+
;
: DABS ( d -- ud ) ( 8.6.1.1160 ) DUP 0< IF DNEGATE THEN ;

: d- dnegate d+ ;

\ Write zero to double
: dz d# 0 dup rot 2! ;

: dxor              \ ( a b c d -- e f )
    rot xor         \ a c b^d
    -rot xor        \ b^d a^c
    swap
;

: dand      rot and -rot and swap ;
: dor       rot or  -rot or  swap ;

: dinvert  invert swap invert swap ;
: d<            \ ( al ah bl bh -- flag )
    rot         \ al bl bh ah
    2dup =
    if
        2drop u<
    else
        2nip >
    then
;

: d> 2swap d< ;
: d0<= d# 0. ;fallthru
: d<= d> invert ;
: d>= d< invert ;
: d0= or 0= ;
: d0< d# 0. d< ;
: d0<> d0= invert ;
: d<> d= invert ;
: d2* 2dup d+ ;
: d2/ dup d# 15 lshift >r 2/ swap 2/ r> or swap ;
: dmax       2over 2over d< if 2swap then 2drop ;

: d1- d# -1. d+ ;

: d+!                   ( v. addr -- )
    dup >r
    2@
    d+
    r>
    2!
;

: move ( addr1 addr2 u -- )
    d# 0 do
        over @ over !
        2+ swap 2+ swap
    loop
    2drop
;

: cmove ( c-addr1 c-addr2 u -- )
    d# 0 do
        over c@ over c!
        1+ swap 1+ swap
    loop
    2drop
;

: bounds ( a n -- a+n a ) OVER + SWAP ;
: fill ( c-addr u char -- ) ( 6.1.1540 )
  >R  bounds
  BEGIN 2dupxor
  WHILE R@ OVER C! 1+
  REPEAT R> DROP 2DROP ;

\ Math

0 [IF]
create scratch d# 2 allot
: um*  ( u1 u2 -- ud )
    scratch !
    d# 0.
    d# 16 0do
        2dup d+
        rot dup 0< if
            2* -rot
            scratch @ d# 0 d+
        else
            2* -rot
        then
    loop
    rot drop
;
[ELSE]
: um*   mult_a ! mult_b ! mult_p 2@ ;
[THEN]

: *         um* drop ;
: abssgn    ( a b -- |a| |b| negf )
        2dup xor 0< >r abs swap abs swap r> ;

: m*    abssgn >r um* r> if dnegate then ;

: divstep
    ( divisor dq hi )
    2*
    over 0< if 1+ then
    swap 2* swap
    rot                     ( dq hi divisor )
    2dup >= if
        tuck                ( dq divisor hi divisor )
        -
        swap                ( dq hi divisor )
        rot 1+              ( hi divisor dq )
        rot                 ( divisor dq hi )
    else
        -rot
    then
    ;

: um/mod ( ud u1 -- u2 u3 ) ( 6.1.2370 )
    -rot 
    divstep divstep divstep divstep
    divstep divstep divstep divstep
    divstep divstep divstep divstep
    divstep divstep divstep divstep
    rot drop swap
;

: /mod  >R S>D R> ;fallthru
: SM/REM ( d n -- r q ) ( 6.1.2214 ) ( symmetric )
  OVER >R >R  DABS R@ ABS UM/MOD
  R> R@ XOR 0< IF NEGATE THEN  R> 0< IF >R NEGATE R> THEN ;
: /     /mod nip ;
: mod   /mod drop ;
: */mod >R M* R> SM/REM ;
: */    */mod nip ;

: t2* over >r >r d2*
    r> 2* r> 0< d# 1 and + ;

variable divisor
: m*/mod
    divisor !
    tuck um* 2swap um*   ( hi. lo. )
                         ( m0 h l m1 )
    swap >r d# 0 d+ r>   ( m h l )
    -rot                 ( l m h )
    d# 32 0do
        t2*
        dup divisor @ >= if
            divisor @ -
            rot 1+ -rot
        then
   loop
;
: m*/ m*/mod drop ;


\ Numeric output - from eforth

variable base
variable hld
create pad 84 allot create pad|

: <# ( -- ) ( 6.1.0490 )( h# 96 ) pad| HLD ! ;
: DIGIT ( u -- c ) d# 9 OVER < d# 7 AND + [CHAR] 0 + ;
: HOLD ( c -- ) ( 6.1.1670 ) HLD @ 1- DUP HLD ! C! ;

: # ( d -- d ) ( 6.1.0030 )
  d# 0 BASE @ UM/MOD >R BASE @ UM/MOD SWAP DIGIT HOLD R> ;

: #S ( d -- d ) ( 6.1.0050 ) BEGIN # 2DUP OR 0= UNTIL ;
: #> ( d -- a u ) ( 6.1.0040 ) 2DROP HLD @ pad| OVER - ;

: SIGN ( n -- ) ( 6.1.2210 ) 0< IF [CHAR] - HOLD THEN ;

\ hex(int((1<<24) * (115200 / 2400.) / (WB_CLOCK_FREQ / 2400.)))
\ d# 42000000 constant WB_CLOCK_FREQ

[ 48000000 17 12 */ ] constant WB_CLOCK_FREQ

0 [IF]
: uartbase
    [ $100000000. 115200 WB_CLOCK_FREQ m*/ drop $ffffff00 and dup swap 16 rshift ] 2literal
;
: emit-uart
    begin uart_0 @ 0= until
    s>d
    uartbase dor
    uart_1 ! uart_0 !
;
[ELSE]
: emit-uart drop ;
[THEN]

create 'emit
meta emit-uart t, target

: emit 'emit @ execute ;
: cr d# 13 emit d# 10 emit ;
d# 32 constant bl
: space bl emit ;
: spaces    begin dup 0> while space 1- repeat drop ;

: hex1 d# 15 and dup d# 10 < if d# 48 else d# 55 then + emit ;
: hex2
    dup 
    d# 4 rshift
    hex1 hex1
;
: hex4
    dup
    d# 8 rshift
    hex2 hex2 ;

: hex8 hex4 hex4 ;

: type
    d# 0 do
        dup c@ emit
        1+
    loop
    drop
;

: dump
    ( addr u )
    0do
        dup d# 15 and 0= if dup cr hex4 [char] : emit space space then
        dup c@ hex2 space 1+
    loop
    cr drop
;

: dump16
    ( addr u )
    0do
        dup hex4 [char] : emit space dup @ hex4 cr 2+
    loop
    drop
;

: decimal d# 10 base ! ;
: hex d# 16 base ! ;

: S.R ( a u n -- ) OVER - SPACES TYPE ;
: D.R ( d n -- ) ( 8.6.1.1070 ) >R DUP >R DABS <# #S R> SIGN #> R> S.R ;
: U.R ( u n -- ) ( 6.2.2330 ) d# 0 SWAP D.R ;
: .R ( n n -- ) ( 6.2.0210 ) >R S>D R> D.R ;

: D. ( d -- ) ( 8.6.1.1060 ) d# 0 D.R SPACE ;
: U. ( u -- ) ( 6.1.2320 ) d# 0 D. ;
: . ( n -- ) ( 6.1.0180 ) BASE @ d# 10 XOR IF U. EXIT THEN S>D D. ;
: ? ( a -- ) ( 15.6.1.0600 ) @ . ;

( Numeric input )

: DIGIT? ( c base -- u f ) ( 0xA3 )
  >R [CHAR] 0 - D# 9 OVER <
  IF D# 7 - DUP D# 10 < OR THEN DUP R> U< ;

: >number ( ud a u -- ud a u ) ( 6.1.0570 )
    begin
        dup 0= if exit then
        over c@ base @ digit? if
            >r 2swap
            drop base @ um*
            r> s>d d+ 2swap
            d# 1 /string >number
        else
            drop exit
        then
    again
;

: .s
    [char] < emit
    depth dup hex2
    [char] > emit

    d# 8 min
    ?dup if
        0do
            i pick hex4 space
        loop
    then
;

build-debug? [IF]
: (assert)
    s" **** ASSERTION FAILED **** " type
    ;fallthru
: (snap)
    type space
    s" LINE " type
    .
    [char] : emit
    space
    .s
    cr
;
[THEN]

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: endian dup d# 8 lshift swap d# 8 rshift or ;
: 2endian endian swap endian ;
: swab endian ;
: typepad ( c-addr u w )    over - >r type r> spaces ;
: even?     d# 1 and 0= ;

\ rise? and fall? act like ! - except that they leave a true
\ if the value rose or fell, respectively.

: rise?   ( u a -- f ) 2dup @ u> >r ! r> ;
: fall?   ( u a -- f ) 2dup @ u< >r ! r> ;

]module
