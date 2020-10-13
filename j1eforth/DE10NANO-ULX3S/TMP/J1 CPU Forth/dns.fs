( DNS                                        JCB 19:44 11/27/10)
module[ dns"

: ip-dns@ ip-dns 2@ ;

\ ( offset -- offset' ) advance pointer past DNS label
\ 0     means end
\ >h# c0 means ptr to end
\ N     means word of N bytes

: dns-skiplabel
    begin
        dup 1+ swap mac-inoffset macc@        \  offset+1 v
        dup 0= if
            drop exit
        then
        dup h# c0 >= if
            drop 1+ exit
        then
        +
    again
;

\ Query DNS. xt is a word that appends domainname to packet.  id is DNS
\ id field, used to route responses.

: dns-query ( xt id -- )
    >r
    \ dst-port src-port dst-ip src-ip *ethaddr
    d# 53 d# 31947 
    ip-dns@
    net-my-ip
    ip-dns@ arp-lookup
    udp-header
    r>          \ IDENTIFICATION
    h# 0100     \ FLAGS
    d# 1        \ NOQ
    mac-pkt-3,
    d# 3 mac-pkt-,0
    
    execute

    d# 1        \ query type A
    dup         \ query class internet
    mac-pkt-2,
    udp-wrapup

    ip-dns@ arp-lookup if
        mac-send
    then
;

: dns-handler ( srcport dstport  -- 0 / ip. id 1 )
    d# 53 d# 31947 d=
    OFFSET_DNS_FLAGS packet@ 0< and
    OFFSET_DNS_NOA packet@ 0<> and
    if
        OFFSET_DNS_QUERY
        dns-skiplabel
        d# 4 +
        dns-skiplabel
        d# 10 +
        mac-inoffset d# 2 swap mac@n
        OFFSET_DNS_IDENTIFICATION packet@
        d# 1
    else
        d# 0
    then
;

: dns-appendname        ( str -- )
    dup mac-pkt-c,
    mac-pkt-s,
;

: dns-append.com        ( str -- )
    dns-appendname
    s" com" dns-appendname
    d# 0 mac-pkt-c,
;
]module
