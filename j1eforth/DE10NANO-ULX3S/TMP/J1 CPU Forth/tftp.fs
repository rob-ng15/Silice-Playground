( TFTP                                       JCB 09:16 11/11/10)

variable blocknum

: tftp-ack ( -- )
    d# 2 ETH.IP.SRCIP mac-inoffset mac@n arp-lookup if
        ETH.IP.UDP.SOURCEPORT packet@ 
        d# 1077
        d# 2 ETH.IP.SRCIP mac-inoffset mac@n  
        net-my-ip
        2over arp-lookup
        ( dst-port src-port dst-ip src-ip *ethaddr )
        udp-header
        d# 4 mac-pkt-,
        blocknum @ mac-pkt-,
        udp-wrapup mac-send
    then
;

: tftp-handler ( -- )
    IP_PROTO_UDP ip-isproto if
        OFFSET_UDP_DESTPORT packet@ d# 69 = if
            udp-checksum? if
                ETH.IP.UDP.TFTP.OPCODE packet@ 
                s" tftp opcode=" type dup hex4 cr
                dup d# 2 = if
                    s" WRQ filename: " type
                    ETH.IP.UDP.TFTP.RWRQ.FILENAME mac-inoffset d# 32 mac-dump

                    d# 0 blocknum !
                    tftp-ack
                then
                drop
            then
        then
        OFFSET_UDP_DESTPORT packet@ d# 1077 = if
            udp-checksum? if
                ETH.IP.UDP.TFTP.OPCODE packet@ 
                s" tftp opcode=" type dup hex4 cr
                dup d# 3 = if
                    s" tftp recv=" type ETH.IP.UDP.TFTP.DATA.BLOCK packet@ hex4 s"  expected=" type blocknum @ 1+ hex4 cr
                    blocknum @ 1+
                    ETH.IP.UDP.TFTP.DATA.BLOCK packet@ = if
                        \ data at ETH.IP.UDP.TFTP.DATA.DATA
                        ETH.IP.UDP.TFTP.DATA.DATA mac-inoffset
                        blocknum @ d# 9 lshift h# 2000 +
                        d# 256 0do
                            over mac@ h# 5555 xor over h# 3ffe min !
                            2+ swap 2+ swap
                        loop
                        2drop
                        d# 1 blocknum +!
                        tftp-ack
                        ETH.IP.UDP.LENGTH packet@ d# 12 - 0= if
                            h# 2000 h# 100 dump
                            bootloader
                        then
                    else
                        s" unexpected blocknum" type cr
                        tftp-ack
                    then
                then
                drop
            then
        then
    then
;
