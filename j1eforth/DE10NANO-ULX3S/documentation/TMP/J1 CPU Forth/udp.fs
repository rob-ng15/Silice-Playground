( UDP header and wrapup                      JCB 13:22 08/24/10)

: udp-header ( dst-port src-port dst-ip src-ip *ethaddr -- )
    h# 11 ip-header
    mac-pkt-,              \  src port
    mac-pkt-,              \  dst port
    d# 2 mac-pkt-,0        \  length and checksum
;

variable packetbase
: packet packetbase @ + ;

: udp-checksum ( addr -- u ) \ compute UDP checksum on packet
    packetbase !
    ETH.IP.UDP.LENGTH packet @ d# 1 and if
        ETH.IP.UDP ETH.IP.UDP.LENGTH packet @ + packet
        dup @ h# ff00 and swap !
    then
    ETH.IP.UDP packet
    ETH.IP.UDP.LENGTH packet @ 1+ 2/
    mac-checksum invert
    d# 4 ETH.IP.SRCIP packet mac@n
    +1c +1c +1c +1c
    IP_PROTO_UDP +1c
    ETH.IP.UDP.LENGTH packet @ +1c
    invert
;

: udp-checksum? true ;
    \ incoming udp-checksum 0= ;

: udp-wrapup
    mac-pkt-complete dup
    ip-wrapup

    OFFSET_UDP -
    OFFSET_UDP_LENGTH packetout-off mac!

    \ outgoing udp-checksum ETH.IP.UDP.CHECKSUM packetout-off !
;

