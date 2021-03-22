( Variables for IP networking                JCB 13:21 08/24/10)

module[ ip0"
create ip-id-counter    d# 2 allot
create ip-addr          d# 4 allot
create ip-router        d# 4 allot
create ip-subnetmask    d# 4 allot
create ip-dns           d# 4 allot
create icmp-alarm-ptr   d# 1 allot

: ethaddr-broadcast
    h# ffff dup dup
;

: net-my-ip
    ip-addr 2@
;

: ethaddr-pretty-w
    dup endian hex2
    [char] : emit
    hex2
;

: ethaddr-pretty
    swap rot
    ethaddr-pretty-w [char] : emit
    ethaddr-pretty-w [char] : emit
    ethaddr-pretty-w
;

: ip-pretty-byte
    h# ff and
    \ d# 0 u.r
    hex2
;

: ip-pretty-2
    dup swab ip-pretty-byte [char] . emit ip-pretty-byte
;

: ip-pretty
    swap
    ip-pretty-2 [char] . emit
    ip-pretty-2
;

( IP address literals                        JCB 14:30 10/26/10)

================================================================

It is neat to write IP address literals e.g.
ip# 192.168.0.1

================================================================

meta

: octet# ( c -- u ) 0. rot parse >number throw 2drop ;

: ip# 
    [char] . octet# 8 lshift
    [char] . octet# or do-number
    [char] . octet# 8 lshift
    bl octet#       or do-number
;

target

]module
