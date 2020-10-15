( Main for WGE firmware                      JCB 13:24 08/24/10)

\ warnings off
\ require tags.fs

include crossj1.fs
meta
    : TARGET? 1 ;
    : build-debug? 1 ;

include basewords.fs
target
include hwdefs.fs

0 [IF]
    h# 1f80 org
    \ the RAM Bootloader copies 2000-3f80 to 0-1f80, then branches to zero
    : bootloader
        h# 1f80 h# 0
        begin
            2dupxor
        while
            dup h# 2000 + @
            over !
            d# 2 +
        repeat

        begin dsp h# ff and while drop repeat
        d# 0 >r
    ;
[ELSE]
    h# 3f80 org
    \ the Flash Bootloader copies 0x190000 to 0-3f80, then branches to zero
    : bootloader
        h# c flash_a_hi !
        h# 0 begin
            dup h# 8000 + flash_a !
            d# 0 flash_oe_n !
            flash_d @
            d# 1 flash_oe_n !
            over dup + !
            d# 1 +
            dup h# 1fc0 =
        until

        begin dsp h# ff and while drop repeat
        d# 0 >r
    ;
[THEN]

4 org
module[ everything"
include nuc.fs

include version.fs

\ 33333333 / 115200 = 289, half cycle is 144

: pause144
    d# 0 d# 45
    begin
        1-
        2dup=
    until
    2drop
;

: serout ( u -- )
    h# 300 or   \ 1 stop bits
    2*          \ 0 start bit
    \ Start bit
    begin
        dup RS232_TXD ! 2/
        pause144
        pause144
        dup 0=
    until
    drop
    pause144 pause144
    pause144 pause144
;

: frac ( ud u -- d1 u1 ) \ d1+u1 is ud
    >r 2dup d# 1 r@ m*/ 2swap 2over r> d# 1 m*/ d- drop ;
: .2  s>d <# # # #> type ;
: build.
    decimal
    builddate drop
    [ -8 3600 * ] literal s>d d+
    d# 1 d# 60 m*/mod >r
    d# 1 d# 60 m*/mod >r
    d# 1 d# 24 m*/mod >r
    2drop
    r> .2 [char] : emit
    r> .2 [char] : emit
    r> .2 ;

: net-my-mac h# 1234 h# 5677 h# 7777 ;

include doc.fs
include time.fs
include eth-ax88796.fs
include packet.fs
include ip0.fs
include defines_tcpip.fs
include defines_tcpip2.fs
include arp.fs
include ip.fs
include udp.fs
include dhcp.fs

code in end-code
: on ( a -- ) d# 1 swap ! ;
code out end-code
: off ( a -- ) d# 0 swap ! ;

: flash-reset
    flash_rst_n   off
    flash_rst_n   on
;

: flash-cold
    flash_ddir    on
    flash_ce_n    off
    flash_oe_n    on
    flash_we_n    on
    flash_byte_n  on
    flash_rdy     on
    flash-reset
;

: flash-w ( u a -- )
    flash_a !
    flash_d !
    flash_ddir off
    flash_we_n off
    flash_we_n on
    flash_ddir on
;

: flash-r ( a -- u )
    flash_a !
    flash_oe_n off
    flash_d @
    flash_oe_n on
;

: flash-unlock ( -- )
    h# aa h# 555 flash-w
    h# 55 h# 2aa flash-w
;

: flash! ( u da. -- )
    flash-unlock
    h# a0 h# 555 flash-w
    flash_a 2+ !    ( u a )
    2dup            ( u a u a)
    flash-w         ( u a )
    begin
        2dup flash-r xor
        h# 80 and 0=
    until
    2drop
    flash-reset
;

: flash@ ( da. -- u )
    flash_a 2+ !    ( u a )
    flash-r
;

: flash-chiperase
    flash-unlock
    h# 80 h# 555 flash-w
    h# aa h# 555 flash-w
    h# 55 h# 2aa flash-w
    h# 10 h# 555 flash-w
;

: flash-sectorerase ( da -- ) \ erase one sector
    flash-unlock
    h# 80 h# 555 flash-w
    h# aa h# 555 flash-w
    h# 55 h# 2aa flash-w
    flash_a 2+ ! h# 30 swap flash-w
;

: flash-erased ( a -- f )
    flash@ h# 80 and 0<> ;

: flash-dump ( da u -- )
    0do
        2dup flash@ hex4 space
        d1+
    loop cr
    2drop
;

: flashc@
    over d# 15 lshift flash_d !
    d2/ flash@
;

: flash-bytes
    s" BYTES: " type
    flash_byte_n  off
    h# 0.
    d# 1024 0do
        i d# 15 and 0= if
            cr
            2dup hex8 space space
        then
        2dup flashc@ hex2 space
        d1+
    loop cr
    2drop
    flash_byte_n  on
;

0 [IF]
: flash-demo
    flash-unlock
    h# 90 h# 555 flash-w
    h# 00 flash-r hex4 cr
    flash-reset

    false if
        flash-unlock
        h# a0 h# 555 flash-w
        h# 0947 h# 5 flash-w
        sleep1
        flash-reset
    then

    \ h# dead d# 11. flash!

    h# 100 0do
        i flash-r hex4 space
    loop cr
    cr cr
    d# 0. h# 80 flash-dump
    cr cr

    flash-bytes

    exit
    flash-unlock
    h# 80 h# 555 flash-w
    h# aa h# 555 flash-w
    h# 55 h# 2aa flash-w
    h# 10 h# 555 flash-w
    s" waiting for erase" type cr
    begin
        h# 0 flash-r dup hex4 cr
        h# 80 and
    until

    h# 100 0do
        i flash-r hex4 space
    loop cr
;
[THEN]

include sprite.fs

variable cursory \ ptr to start of line in video memory
variable cursorx \ offset to char

64 constant width
50 constant wrapcolumn

: vga-at-xy ( u1 u2 )
    cursory !
    cursorx !
;

: home  d# 0 vga_scroll ! d# 0 d# 0 vga-at-xy ;

: vga-line ( -- a ) \ address of current line
    cursory @ vga_scroll @ + d# 31 and d# 6 lshift 
    h# 8000 or
;

: vga-erase ( a u -- )
    bounds begin
        2dupxor
    while
        h# 00 over ! 1+
    repeat 2drop
;

: vga-page
    home vga-line d# 2048 vga-erase
    hide
;

: down1
    cursory @ d# 31 <> if
        d# 1 cursory +!
    else
        false if
            d# 1 vga_scroll +!
            vga-line width vga-erase
        else
            home
        then
    then
;

: vga-emit ( c -- )
    dup d# 13 = if
        drop d# 0 cursorx !
    else
        dup d# 10 = if
            drop down1
        else
            d# -32 +
            vga-line cursorx @ + !
            d# 1 cursorx +!
            cursorx @ wrapcolumn = if
                d# 0 cursorx !
                down1
            then
        then
    then
;

: flash>ram ( d. a -- ) \ copy 2K from flash d to a
    >r d2/ r>
    d# 1024 0do
        >r
        2dup flash@
        r> ( d. u a )
        over swab over !
        1+
        tuck !
        1+
        >r d1+ r>
    loop
    drop 2drop
;

: vga-cold
    h# f800 h# f000 do
        d# 0 i !
    loop

    vga-page

    \ pic: Copy 2048 bytes from 180000 to 8000
    \ chr: Copy 2048 bytes from 180800 to f000
    h# 180000. h# 8000 flash>ram
    h# 180800. h# f000 flash>ram

    \ ['] vga-emit 'emit !
;

create glyph 8 allot
: wide1 ( c -- )
    swab
    d# 8 0do
        dup 0<
        if d# 127 else sp then
        \ if [char] * else [char] . then
        vga-emit
        2*
    loop drop
;

: vga-bigemit ( c -- )
    dup d# 13 = if
        drop d# 0 cursorx !
    else
        dup d# 10 = if
            drop d# 8 0do down1 loop
        else
            sp - d# 8 * s>d
            h# 00180800. d+ d2/
            d# 4 0do
                2dup flash@ swab
                i cells glyph + !
                d1+
            loop 2drop

            d# 7 0do
                i glyph + c@ wide1
                d# -8 cursorx +! down1
            loop
            d# 7 glyph + c@ wide1

            d# -7 cursory +!
        then
    then
;

( Demo utilities                             JCB 10:56 12/05/10)

: statusline ( a u -- ) \ display string on the status line
    d# 0 d# 31 2dup vga-at-xy
    d# 50 spaces
    vga-at-xy type
;

( Game stuff                                 JCB 15:20 11/15/10)

variable seed
: random  ( -- u )
    seed @ d# 23947 * d# 57711 xor dup seed ! ;   


\ Each line is 20.8 us, so 1000 instructions

include sincos.fs

( Stars                                      JCB 15:23 11/15/10)

2variable vision
variable frame
128 constant nstars
create stars 1024 allot

: star 2* cells stars + ;
: 15.*  m* d2* nip ;

\ >>> math.cos(math.pi / 180) * 32767
\ 32762.009427189474
\ >>> math.sin(math.pi / 180) * 32767
\ 571.8630017304688

[ pi 128e0 f/ fcos 32767e0 f* f>d drop ] constant COSa
[ pi 128e0 f/ fsin 32767e0 f* f>d drop ] constant SINa

: rotate ( i -- ) \ rotate star i
    star dup 2@ ( x y )
    over SINa 15.* over COSa 15.* + >r
    swap COSa 15.* swap SINa 15.* - r>
    rot 2!
;

: rotateall
    d# 256 0do i rotate loop ;

: scatterR
    nstars 0do
        random d# 0 i star 2!
        rotateall
        rotateall
        rotateall
        rotateall
    loop
;

: scatterSpiral
    nstars 0do
        i d# 3 and 1+ d# 8000 *
        d# 0 i star 2!
        rotateall
        rotateall
        rotateall
        rotateall
    loop
;

: scatter
    nstars 0do
        \ d# 0 random
        d# 0 i sin
        i star 2!
        i random d# 255 and 0do
            dup rotate
        loop drop
    loop
;

: /128  dup 0< h# fe00 and swap d# 7 rshift or ;
: tx    /128 [ 400 ] literal + ;
: ty    /128 [ 256 ] literal + ;

: plot ( i s ) \ plot star i in sprite s
    >r
    dup star @ tx swap d# 2 lshift
    r> sprite!
;

( Display list                               JCB 16:10 11/15/10)

create dl 1026 allot

: erasedl
    dl d# 1024 bounds begin
        d# -1 over !
        cell+ 2dup=
    until 2drop
;

: makedl
    erasedl

    nstars 0do
        i d# 2 lshift
        cells dl +
        \ cell occupied, use one below
        \ dup @ 0< invert if cell+ then
        i swap !
    loop
;

variable lastsp
: stars-chasebeam
    hide
    d# 0 lastsp !
    d# 512 0do
        begin vga-line@ i = until
        i cells dl + @ dup 0< if
            drop
        else
            lastsp @ 1+ d# 7 and dup lastsp ! plot
        then
        i nstars < if i rotate then
    loop
;



: loadcolors
    d# 8 0do
        dup @
        i cells vga_spritec + !
        cell+
    loop
    drop
;
create cpastels
h# 423 ,
h# 243 ,
h# 234 ,
h# 444 ,
h# 324 ,
h# 432 ,
h# 342 ,
h# 244 ,
: pastels cpastels loadcolors ;

create crainbow
h# 400 ,
h# 440 ,
h# 040 ,
h# 044 ,
h# 004 ,
h# 404 ,
h# 444 ,
h# 444 ,
: rainbow crainbow loadcolors ;

variable prev_sw3_n

: next? ( -- f ) \ has user requested next screen
    sw3_n @ prev_sw3_n fall?
;

: loadsprites ( da -- )
    2/
    d# 16384 0do
        2dup i s>d d+ flash@
        i vga_spritea !  vga_spriteport !
    loop
    2drop
;

: stars-main
    vga-page
    d# 16384 0do
        h# 204000. 2/ i s>d d+ flash@
        i vga_spritea !  vga_spriteport !
    loop

    vga_addsprites on
    rainbow

    time@ xor seed !
    seed off
    scatter

    d# 7000000. vision setalarm
    d# 0 frame !
    begin
        makedl
        stars-chasebeam
        \ d# 256 0do i i plot loop
        \ rotateall
        frame @ 1+ frame !
        next?
    until
    frame @ . s"  frames" type cr
;

: buttons ( -- u ) \ pb4 pb3 pb2
    pb_a_dir on
    pb_a @ d# 7 xor
    pb_a_dir off
;

include loader.fs
include dns.fs

: preip-handler
    begin
        mac-fullness
    while
        OFFSET_ETH_TYPE packet@ h# 800 = if
            dhcp-wait-offer
        then
        mac-consume
    repeat
;

: haveip-handler
    \ time@ begin ether_irq @ until time@ 2swap d- d. cr
    \ begin ether_irq @ until
    begin
        mac-fullness
    while
        arp-handler
        OFFSET_ETH_TYPE packet@ h# 800 =
        if
            d# 2 OFFSET_IP_DSTIP mac-inoffset mac@n net-my-ip d=
            if
                icmp-handler
            then
            loader-handler
        then
        depth if .s cr then
        mac-consume
    repeat
;

include invaders.fs

: uptime
    time@
    d# 1 d# 1000 m*/
    d# 1 d# 1000 m*/
;

( IP address formatting                      JCB 14:50 10/26/10)

: #ip1  h# ff and s>d #s 2drop ;
: #.    [char] . hold ;
: #ip2  dup #ip1 #. d# 8 rshift #ip1 ;
: #ip   ( ip -- c-addr u) dup #ip2 #. over #ip2 ;

variable prev_sw2_n
: sw2?  sw2_n @ prev_sw2_n fall? ;

include ps2kb.fs

: istab?
    key? dup if key TAB = and then
;
        
: welcome-main
    vga-cold
    home
    s" F1 to set up network, TAB for next demo" statusline

    rainbow
    h# 200000. loadsprites
    'emit @ >r
    d# 6 d# 26 vga-at-xy s" Softcore Forth CPU" type

    d# 32 d# 6 vga-at-xy  s" version " type version type
    d# 32 d# 8 vga-at-xy  s" built   " type build.

    kb-cold
    home
    begin
        kbfifo-proc
        d# 32 d# 10 vga-at-xy net-my-ip <# #ip #> type space space
        d# 32 d# 12 vga-at-xy s" uptime  " type uptime d.
        haveip-handler

        d# 8 0do
            frame @ i d# 32 * + invert >r
            d# 100 r@ sin* d# 600 +
            d# 100 r> cos* d# 334 +
            i sprite!
        loop

        waitblank
        d# 1 frame +!
        next?
        istab? or
    until
    r> 'emit !
;

include clock.fs

: frob
    flash_ce_n    on
    flash_ddir off
    d# 32 0do
        d# 1 i d# 7 and lshift
        flash_d !
        d# 30000. sleepus
    loop
    flash_ddir on
;

: main
    decimal
    ['] serout 'emit !
    \ sleep1

    frob

    d# 60 0do cr loop
    s" Welcome! Built " type build. cr 
    snap

    flash-cold
    \ flash-demo
    \ flash-bytes
    vga-cold
    ['] vga-emit 'emit !
    s" Waiting for Ethernet NIC" statusline
    mac-cold
    nicwork
    h# decafbad. dhcp-xid!
    d# 3000000. dhcp-alarm setalarm
    false if
        ip-addr dz
        begin
            net-my-ip d0=
        while
            dhcp-alarm isalarm if
                dhcp-discover
                s" DISCOVER" type cr
                d# 3000000. dhcp-alarm setalarm
            then
            preip-handler
        repeat
    else
        ip# 192.168.0.99 ip-addr 2!
        ip# 255.255.255.0 ip-subnetmask 2!
        ip# 192.168.0.1 ip-router 2!
        \ ip# 192.168.2.201 ip-addr 2!
        \ ip# 255.255.255.0 ip-subnetmask 2!
        \ ip# 192.168.2.1 ip-router 2!
    then
    dhcp-status
    arp-reset

    begin
        welcome-main        sleep.1
        clock-main          sleep.1
        stars-main          sleep.1
        invaders-main       sleep.1
        s" looping" type cr
    again

    begin
        haveip-handler
    again
;


]module

0 org

code 0jump
    \ h# 3e00 ubranch
    main ubranch
    main ubranch
end-code

meta

hex

: create-output-file w/o create-file throw to outfile ;

\ .mem is a memory dump formatted for use with the Xilinx
\ data2mem tool.
s" j1.mem" create-output-file
:noname
    s" @ 20000" type cr
    4000 0 do i t@ s>d <# # # # # #> type cr 2 +loop
; execute

\ .bin is a big-endian binary memory dump
s" j1.bin" create-output-file
:noname 4000 0 do i t@ dup 8 rshift emit emit 2 +loop ; execute

\ .lst file is a human-readable disassembly 
s" j1.lst" create-output-file
d# 0
h# 2000 disassemble-block
