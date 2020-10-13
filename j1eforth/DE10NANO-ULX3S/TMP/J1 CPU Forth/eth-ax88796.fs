( Low-level MAC actions                      JCB 13:23 08/24/10)

================================================================

Initialization:
    mac-cold

Packet reception and reading:
    mac-fullness
    mac-inoffset
    mac@
    macc@
    mac@n
    mac-consume

Packet construction and transmission:
    mac-pkt-begin
    mac-pkt-,
    mac-pkt-c,
    mac-pkt-d,
    mac-pkt-2,
    mac-pkt-3,
    mac-pkt-,0
    mac-pkt-s,
    mac-pkt-src
    packetout-off
    mac!
    macc!
    mac-complete
    mac-checksum
    mac-send

================================================================

( NE2K                                       JCB 10:23 11/08/10)

: ne2sel
    false ether_cs_n ! ;
: ne2unsel
    true ether_cs_n ! ;
: ne2a ( a -- )
    pb_a ! ;

: ne2rc@ ( a -- u ) \ NE2 byte reg read
    true ether_bhe_n !
    true ether_aen !
    ne2sel
    ne2a
    false pb_rd_n !
    \ pause144
    pb_d @ h# ff and
    true pb_rd_n !
    \ false ether_aen ! 
    \ ne2unsel
;

: ne2rc! ( u a -- )
    \ over hex2 s"  -> " type dup hex2 cr

    true ether_bhe_n !

    ne2sel
    ne2a
    pb_d !
    d# 0 ddir !
    false pb_wr_n !
    true pb_wr_n !
    \ ne2unsel
    d# 1 ddir !
;

: ne2r! ( u a -- )
    over d# 8 rshift over 1+ ne2rc! ne2rc! ;

: ne2r. \ dump registers
    d# 16 0do
        d# 1000 0do pause144 loop
        i hex2 space
        i ne2rc@ hex4 cr
    loop
;

h# 00 constant ne2-CR       
h# 01 constant ne2-PSTART   
h# 01 constant ne2-PAR0     
h# 03 constant ne2-PAR2     
h# 05 constant ne2-PAR4     
h# 01 constant ne2-CR9346   
h# 02 constant ne2-PSTOP    
h# 03 constant ne2-BNRY     
h# 04 constant ne2-TSR      
h# 04 constant ne2-TPSR     
h# 05 constant ne2-TBCR0    
h# 05 constant ne2-NCR      
h# 06 constant ne2-CPR      
h# 06 constant ne2-TBCR1    
h# 07 constant ne2-ISR      
h# 07 constant ne2-CURR     
h# 08 constant ne2-RSAR0    
h# 08 constant ne2-CRDA0    
h# 09 constant ne2-RSAR1    
h# 09 constant ne2-CRDA1    
h# 0A constant ne2-RBCR0    
h# 0B constant ne2-RBCR1    
h# 0C constant ne2-RSR      
h# 0C constant ne2-RCR      
h# 0D constant ne2-TCR      
h# 0D constant ne2-CNTR0    
h# 0E constant ne2-DCR      
h# 0E constant ne2-CNTR1    
h# 0F constant ne2-IMR      
h# 0F constant ne2-CNTR2    
h# 10 constant ne2-RDMAPORT 
h# 14 constant ne2-MIIEEP
h# 15 constant ne2-TR  
h# 17 constant ne2-GPOC  
h# 17 constant ne2-GPI
h# 1F constant ne2-RSTPORT  

: ne2-page0 h# 22 ne2-CR ne2rc!  ;
: ne2-page1 h# 62 ne2-CR ne2rc!  ;

: ne2-clrisr \ clear the ISR
    h# ff ne2-ISR    ne2rc! ; 


: ne2r.2
    s" Page 0" type cr
    ne2-page0
    ne2r.
    s" Page 1" type cr
    ne2-page1
    ne2r.
    ne2-page0 ;

( The MII interface                          JCB 12:47 11/09/10)

h# 08 constant MII_EEP_MDO
h# 04 constant MII_EEP_MDI
h# 01 constant MII_EEP_MDC

: eep-on  ( u ) ne2-MIIEEP ne2rc@ or ne2-MIIEEP ne2rc! ;
: eep-off ( u ) invert ne2-MIIEEP ne2rc@ and ne2-MIIEEP ne2rc! ;

: miix ( u c -- u ) \ Send c bit data u
    tuck
    d# 16 swap - lshift
    swap
    0do
        MII_EEP_MDO over 0< if
            eep-on
        else
            eep-off
        then
        MII_EEP_MDC eep-on \ clock up
        2*
        ne2-MIIEEP ne2rc@ MII_EEP_MDI and if 1+ then
        MII_EEP_MDC eep-off \ clock down
    loop
;

: phy@ ( a -- u )
    h# ffff d# 16 miix drop
    h# ffff d# 16 miix drop
    h# 0d0 d# 9 miix drop
          d# 5 miix drop
    h# 0 d# 1 miix drop
    h# 0 d# 16 miix
;

: phy! ( u a -- )
    h# ffff d# 16 miix drop
    h# ffff d# 16 miix drop
    h# 0b0 d# 9 miix drop
          d# 5 miix drop
    h# 2 d# 2 miix drop
         d# 16 miix drop
;

: phy.
    d# 32 0do
        i hex2 space i phy@ hex4 cr
    loop
    cr
;

: phy-cold
    \ h# b000 d# 0 phy! 
    h# 0800 d# 0 phy!
    s" PHY power down for 2.5s" type cr
    d# 2500000. sleepus
    \ h# 1200 d# 0 phy!
    h# 0000 d# 0 phy!
    exit
    sleep1 
    sleep1 
    sleep1 
    sleep1 
    sleep1 
    sleep1 

    \ h# 6030 d# 30 phy!

    phy. sleep1
    cr
    phy. 
;

: mac-cold   ( ethaddr -- )

    false RESET_TRIGGER !
    sleep1
    true RESET_TRIGGER !
    sleep1

    true pb_rd_n !
    true pb_wr_n !
    true ether_cs_n !
    false ether_aen !
    true ether_bhe_n !
    d# 0 pb_a !
    d# 1 ddir !

    \ d# 4 0do ne2-RSTPORT ne2rc@ ne2-RSTPORT ne2rc!  sleep1 loop

    phy-cold

    \ Wait for TR RST_B to go low and GPI link up
    s" TR   GPI" type cr
    begin
        ne2-TR ne2rc@ hex2 d# 3 spaces
        ne2-GPI ne2rc@ hex2 d# 3 spaces
        sleep.1
        cr
        ne2-TR ne2rc@ d# 2 and 0=
        ne2-GPI ne2rc@ d# 1 and 0<> and
    until

    \ Wait for TR RST_B to go low
\   begin
\       sleep1
\       ne2-TR ne2rc@ dup hex2 cr
\       d# 2 and 0=
\   until

    true if
        h# 21 ne2-CR     ne2rc! \ Stop the NIC, abort DMA, page 0
        h# 00 ne2-DCR    ne2rc! \ Selects byte-wide DMA transfers
        h# 00 ne2-RBCR0  ne2rc! \ Load data byte count for remote DMA
        h# 00 ne2-RBCR1  ne2rc!
        h# 20 ne2-RCR    ne2rc! \ Temporarily set receiver to monitor mode
        h# 02 ne2-TCR    ne2rc! \ Transmitter set to internal loopback mode
        \ Initialize Receive Buffer Ring: Boundary Pointer
        \ (BNDRY), Page Start (PSTART), and Page Stop
        \ (PSTOP)
        h# 46 ne2-PSTART ne2rc!
        h# 46 ne2-BNRY   ne2rc!
        h# 80 ne2-PSTOP  ne2rc!
        h# ff ne2-ISR    ne2rc! \ Clear Interrupt Status Register (ISR) by writing 0FFh to it.
        h# 01 ne2-IMR    ne2rc! \ Initialize interrupt mask
        h# 61 ne2-CR     ne2rc! \ Stop the NIC, abort DMA, page 1
        h# 12 d# 1       ne2rc! \ Set Physical Address
        h# 34 d# 2       ne2rc!
        h# 56 d# 3       ne2rc!
        h# 77 d# 4       ne2rc!
        h# 77 d# 5       ne2rc!
        h# 77 d# 6       ne2rc!
        d# 16 d# 8 do           \ Set multicast address
            h# 00 i ne2rc!
        loop

        h# 47 ne2-CURR   ne2rc! \ Initialize CURRent pointer
        h# 22 ne2-CR     ne2rc! \ Start the NIC, Abort DMA, page 0
        h# 10 ne2-GPOC   ne2rc! \ Select media interface
        s" GPI = " type ne2-GPI ne2rc@ hex2 cr
        h# 00 ne2-TCR    ne2rc! \ Transmitter full duplex
        h# 04 ne2-RCR    ne2rc! \ Enable receiver and set accept broadcast
    else
        h# 21 ne2-CR     ne2rc! \ Stop the NIC, abort DMA, page 0
        sleep.1

        h# 00 ne2-DCR    ne2rc! \ Selects word-wide DMA transfers
        h# 00 ne2-RBCR0  ne2rc! \ Load data byte count for remote DMA
        h# 00 ne2-RBCR1  ne2rc!

        h# 20 ne2-RCR    ne2rc! \ Temporarily set receiver to monitor mode
        h# 02 ne2-TCR    ne2rc! \ Transmitter set to internal loopback mode

        h# 40 ne2-TPSR   ne2rc! \ Set Tx start page
        \ Initialize Receive Buffer Ring: Boundary Pointer
        \ (BNDRY), Page Start (PSTART), and Page Stop
        \ (PSTOP)
        h# 46 ne2-PSTART ne2rc!
        h# 46 ne2-BNRY   ne2rc!
        h# 80 ne2-PSTOP  ne2rc!
        h# ff ne2-ISR    ne2rc! \ Clear Interrupt Status Register (ISR) by writing 0FFh to it.
        h# 01 ne2-IMR    ne2rc! \ Initialize interrupt mask

        h# 61 ne2-CR     ne2rc! \ Stop the NIC, abort DMA, page 1
        sleep.1
        h# 12 d# 1       ne2rc! \ Set Physical Address
        h# 34 d# 2       ne2rc!
        h# 56 d# 3       ne2rc!
        h# 77 d# 4       ne2rc!
        h# 77 d# 5       ne2rc!
        h# 77 d# 6       ne2rc!
        d# 16 d# 8 do           \ Set multicast address
            h# ff i ne2rc!
        loop

        h# 47 ne2-CURR   ne2rc! \ Initialize CURRent pointer

        h# 20 ne2-CR     ne2rc! \ DMA abort, page 0

        h# 10 ne2-GPOC   ne2rc! \ Select media interface
        s" GPI = " type ne2-GPI ne2rc@ hex2 cr
        h# 1c ne2-RCR    ne2rc! \ Enable receiver and set accept broadcast
        h# 00 ne2-TCR    ne2rc! \ Transmitter full duplex

        h# ff ne2-ISR    ne2rc! \ Clear Interrupt Status Register (ISR) by writing 0FFh to it.
        h# 22 ne2-CR     ne2rc! \ Start the NIC, Abort DMA, page 0
    then
;

: NicCompleteDma
    h# 22 ne2-CR     ne2rc! \ Complete remote DMA
;

: maca ( a -- ) \ set DMA address a
    dup d# 8 rshift ne2-RSAR1 ne2rc!  ne2-RSAR0 ne2rc! ;
: mac1b \ set DMA transfer for 1 byte
    h# 01 ne2-RBCR0 ne2rc!
    h# 00 ne2-RBCR1 ne2rc! ;
: mac2b \ set DMA transfer for 2 bytes
    h# 02 ne2-RBCR0 ne2rc!
    h# 00 ne2-RBCR1 ne2rc! ;
: macc@ ( a -- u )
    maca mac1b
    h# 0a ne2-CR     ne2rc! \ running, DMA read
    ne2-RDMAPORT ne2rc@
    NicCompleteDma ;
: macc! ( u a -- )
    maca mac1b
    h# 12 ne2-CR    ne2rc! \ running, DMA write
    ne2-RDMAPORT ne2rc! ;
: mac@ ( a -- u )
    maca mac2b
    h# 0a ne2-CR     ne2rc! \ running, DMA read
    ne2-RDMAPORT ne2rc@ d# 8 lshift ne2-RDMAPORT ne2rc@ or
    NicCompleteDma ;
: mac! ( u a -- )
    maca mac2b
    h# 12 ne2-CR    ne2rc! \ running, DMA write
    dup d# 8 rshift ne2-RDMAPORT ne2rc! ne2-RDMAPORT ne2rc! ;

: mac-dump ( a u -- )
    bounds
    begin
        2dup u>
    while
        dup h# f and 0= if
            cr dup hex4 [char] : emit space
        then
        dup mac@ hex4 space
        2+
    repeat 2drop cr ;

variable currpkt

: mac-inoffset ( u -- u ) \ compute offset into current incoming packet
    currpkt @ +
    dup 0< if
        h# 8000 -
        h# 4600 +
    then
;

: mac@n ( n addr -- d0 .. dn )
    swap 0do dup mac@ swap 2+ loop drop ; 


( words for constructing packet data         JCB 07:01 08/20/10)
variable writer

: mac-pkt-begin h# 4000 writer !  ;
: bump  ( n -- ) writer +! ;
: mac-pkt-c,    ( n -- ) writer @ macc! d# 1 bump ;
: mac-pkt-,     ( n -- ) writer @ mac! d# 2 bump ;
: mac-pkt-d,    ( d -- ) mac-pkt-, mac-pkt-, ;
: mac-pkt-2,    ( n0 n1 -- ) swap mac-pkt-, mac-pkt-, ;
: mac-pkt-3,    rot mac-pkt-, mac-pkt-2, ;
: mac-pkt-,0    ( n -- ) 0do d# 0 mac-pkt-, loop ;
: mac-pkt-s,    ( caddr u -- )
    0do
        dup c@
        mac-pkt-c,
        1+
    loop
    drop
;

: mac-pkt-src ( n offset -- ) \ copy n words from incoming+offset
    swap 0do
        dup mac-inoffset mac@ mac-pkt-,
        2+
    loop
    drop
;

: mac-pkt-complete ( -- length ) \ set up size
    writer @ h# 4000 -
    \ h# 4000 over mac-dump
    dup ne2-TBCR0 ne2r!  ;

: mac-checksum ( addr nwords -- sum )
    d# 0 swap
    0do
        over mac@       ( addr sum v )
        +1c
        swap 2+ swap
    loop
    nip
    invert
;

: mac-snap
    s" CR     PSTART PSTOP  BNRY   TSR    NCR    CPR    ISR    CRDA0  CRDA1  -      -      RSR    CNTR0  CNTR1  CNTR2" type cr
    d# 16 0do
        i ne2rc@ hex2 d# 5 spaces
    loop
;

: mac-fullness ( -- f )
    ether_irq @ if
        ne2-BNRY ne2rc@ 1+ ne2-CPR ne2rc@ <> dup if
            \ mac-snap
            ne2-BNRY ne2rc@ 1+ d# 8 lshift d# 4 + currpkt !
            \ s" currpkt=" type currpkt @ hex4 space
            \ currpkt @ d# 4 - macc@ hex2 
            \ cr
            \ currpkt @ d# 4 - d# 16 mac-dump
        else
            ne2-clrisr
        then
    else
        false
    then
;

: mac-consume ( -- ) \ finished with current packet, move on
    ne2-BNRY ne2rc@ 1+ d# 8 lshift 1+ macc@ \ next pkt
    1- ne2-BNRY ne2rc!
;

variable ne2cold

: mac-send
    ne2cold @ 0= if
        h# 21 ne2-CR ne2rc!
        h# 22 ne2-CR ne2rc!
        true ne2cold !
    then

    h# 40 ne2-TPSR ne2rc!
    h# 26 ne2-CR ne2rc! \ START
    ;

: packetout-off           \  compute offset in output packet
    h# 4000 + ;

: nicwork

    \ ISA mode

    \ begin
        s" TR= " type h# 15 ne2rc@ hex2 space
        s" ether_irq=" type ether_irq @ hex1 space
        s" ISR=" type ne2-ISR ne2rc@ hex2 space
        cr
    \ again

    false if
        h# 0000 ne2-RSAR0 ne2r!
        cr
        d# 16 0do
            ne2-RDMAPORT ne2rc@ hex2 space
        loop
        cr
    then

    s" CR     PSTART PSTOP  BNRY   TSR    NCR    CPR    ISR    CRDA0  CRDA1  -      -      RSR    CNTR0  CNTR1  CNTR2" type cr
    begin
        d# 16 0do
            i ne2rc@ hex2 d# 5 spaces
        loop
        ether_irq @ hex1
        cr 
        sleep1
        ne2-CPR ne2rc@ h# 47 <>
    until

    \ h# 4700 h# 100 mac-dump
    \ cr
    \ h# 0947 h# 4700 mac!
    \ h# 4700 h# 100 mac-dump
;
