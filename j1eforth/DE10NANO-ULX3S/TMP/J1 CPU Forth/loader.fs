( LOADER PROTOCOL                            JCB 09:16 11/11/10)

947 constant PORT

: response0 ( -- )
    ETH.IP.UDP.SOURCEPORT packet@ 
    PORT
    d# 2 ETH.IP.SRCIP mac-inoffset mac@n  
    net-my-ip
    2over arp-lookup
    ( dst-port src-port dst-ip src-ip *ethaddr )
    udp-header
    d# 0 mac-pkt-,
    ETH.IP.UDP.LOADER.SEQNO packet@ mac-pkt-,
;

: response1
    udp-wrapup mac-send
;

: respond
    response0
    response1
;

: ramread
    response0
    ETH.IP.UDP.LOADER.RAMREAD.ADDR packet@
    d# 128 bounds begin
        dup @ mac-pkt-,
        cell+
        2dup=
    until
    2drop
    response1
;

: ramwrite
    ETH.IP.UDP.LOADER.RAMWRITE.ADDR packet@ 
    d# 64 0do
        ETH.IP.UDP.LOADER.RAMWRITE.DATA i cells + packet@
        over !
        cell+
    loop
    drop
    respond
;

: reboot
    respond bootloader ;

: flashread
    response0
    ETH.IP.UDP.LOADER.FLASHREAD.ADDR packetd@ d2/
    flash-reset
    d# 64 0do
        2dup flash@
        mac-pkt-,
        d1+
    loop
    2drop
    response1
;

: flasherase
    respond flash-chiperase ;

: flashdone
    response0
    ETH.IP.UDP.LOADER.FLASHREAD.ADDR packetd@ d2/
    flash-erased mac-pkt-,
    response1
;

: flashwrite
    ETH.IP.UDP.LOADER.FLASHWRITE.ADDR packetd@ d2/
    d# 64 0do
        2dup
        ETH.IP.UDP.LOADER.FLASHWRITE.DATA i cells + packet@
        -rot flash!
        d1+
    loop
    2drop
    respond
;

: flashsectorerase
    ETH.IP.UDP.LOADER.FLASHWRITE.ADDR packetd@ d2/
    flash-sectorerase
    respond
;

jumptable opcodes
( 0 ) | ramread
( 1 ) | ramwrite
( 2 ) | reboot
( 3 ) | flashread
( 4 ) | flasherase
( 5 ) | flashdone
( 6 ) | flashwrite
( 7 ) | flashsectorerase

: loader-handler ( -- )
    IP_PROTO_UDP ip-isproto if
        ETH.IP.UDP.DESTPORT packet@ PORT =
        d# 2 ETH.IP.SRCIP mac-inoffset mac@n arp-lookup 0<> and if
            udp-checksum? if
                ETH.IP.UDP.LOADER.OPCODE packet@ 
                \ s" loader opcode=" type dup hex4 cr
                opcodes execute
            then
        then
    then
;
