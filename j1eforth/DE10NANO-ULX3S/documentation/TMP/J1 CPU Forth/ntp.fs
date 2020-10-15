( NTP                                        JCB 09:54 11/17/10)

: ntp-server 
   \ h# 02830a00.
   \ ip# 91.189.94.4 \ time.ubuntu
   ip# 17.151.16.20  \ time.apple.com
;

: ntp-request
    d# 123 d# 9999
    ntp-server
    net-my-ip
    2over arp-lookup
    ( dst-port src-port dst-ip src-ip *ethaddr )
    udp-header
    h# 2304 mac-pkt-, h# 04ec mac-pkt-, 
    d# 6 mac-pkt-,0

    d# 4 mac-pkt-,0 \ originate
    d# 4 mac-pkt-,0 \ reference
    d# 4 mac-pkt-,0 \ receive
    \ d# 4 mac-pkt-,0 \ transmit
    time@ mac-pkt-d, d# 2 mac-pkt-,0
    udp-wrapup mac-send
;

: ntp-handler
    IP_PROTO_UDP ip-isproto
    ETH.IP.UDP.SOURCEPORT packet@ d# 123 = and
    ETH.IP.UDP.DESTPORT packet@ d# 9999 = and
    if
        ETH.IP.UDP.NTP.TRANSMIT packetd@ setdate
        time@ ETH.IP.UDP.NTP.ORIGINATE packetd@ d- setdelay
    then
;

