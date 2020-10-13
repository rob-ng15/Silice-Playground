( IP networking: headers and wrapup         JCB 13:21 08/24/10)
module[ ip"

: ip-datalength ( -- u ) \ length of current IP packet in words
    ETH.IP.LENGTH packet@
    d# 20 - 2/
;

: ip-isproto ( u -- f ) \ true if packet PROTO is u
    ETH.IP.TTLPROTO packet@ h# ff and =
;

: ip-identification
    ip-id-counter d# 1 over +! @
;

: @ethaddr ( eth-addr -- mac01 mac23 mac45 )
    ?dup
    if
        dup @ swap 2+ 2@
    else
        ethaddr-broadcast
    then
;

: ip-header ( dst-ip src-ip eth-addr protocol -- )
    >r
    mac-pkt-begin

    @ethaddr mac-pkt-3,
    net-my-mac mac-pkt-3,
    h# 800 mac-pkt-,

    h# 4500
    h# 0000                  \  length
    ip-identification
    mac-pkt-3,
    h# 4000                  \  do not fragment
    h# 4000 r> or            \  TTL, protocol
    d# 0                        \  checksum
    mac-pkt-3,
    mac-pkt-2,              \  src ip
    mac-pkt-2,              \  dst ip
;

: ip-wrapup ( bytelen -- )
    \  write IP length
    ETH.IP -
    ETH.IP.LENGTH packetout-off mac!

    \  write IP checksum
    ETH.IP packetout-off d# 10 mac-checksum
    ETH.IP.CHKSUM packetout-off mac!
;

: ip-packet-srcip
    d# 2 ETH.IP.SRCIP mac-inoffset mac@n
;

( ICMP return and originate                  JCB 13:22 08/24/10)

\  Someone pings us, generate a return packet

: icmp-handler
    IP_PROTO_ICMP ip-isproto
    ETH.IP.ICMP.TYPECODE packet@ h# 800 =
    and if
        ip-packet-srcip
        2dup arp-lookup
        ?dup if
            \  transmit ICMP reply
                                    \  dstip *ethaddr
            net-my-ip rot           \  dstip srcip *ethaddr
            d# 1 ip-header

            \  Now the ICMP header
            d# 0 mac-pkt-,

            s" =====> ICMP seq " type
            ETH.IP.ICMP.SEQUENCE mac-inoffset mac@ u. cr

            ETH.IP.ICMP.IDENTIFIER mac-inoffset
            ip-datalength 2-        ( offset n )
            tuck
            mac-checksum mac-pkt-,
            ETH.IP.ICMP.IDENTIFIER mac-pkt-src

            mac-pkt-complete
            ip-wrapup
            mac-send
        else
            2drop
        then
    then
;
    
: ping ( ip. -- ) \ originate
    2dup arp-lookup
    ?dup if
        \  transmit ICMP request
                                \  dstip *ethaddr
        net-my-ip rot           \  dstip srcip *ethaddr
        d# 1 ip-header

        \  Now the ICMP header
        h# 800 mac-pkt-,

        \  id is h# 550b, seq is lo word of time
        h# 550b time@ drop
        2dup +1c h# 800 +1c
        d# 28 begin swap d# 0 +1c swap 1- dup 0= until drop
        invert mac-pkt-,     \  checksum
        mac-pkt-2,
        d# 28 mac-pkt-,0

        mac-pkt-complete
        ip-wrapup
        mac-send
    else
        2drop
    then
;

]module
