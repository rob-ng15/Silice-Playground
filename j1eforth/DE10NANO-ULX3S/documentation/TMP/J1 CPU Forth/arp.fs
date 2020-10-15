( ARP: Address Resolution Protocol           JCB 13:12 08/24/10)
module[ arp"

\  ARP uses a small cache of entries.  Each entry has an age counter; new
\  entries have an age of 0, any entry with an age >N is old.
\ 


d# 12 constant arp-cache-entry-size
d# 5 constant arp-cache-entries
TARGET? [IF]
    meta
    arp-cache-entry-size arp-cache-entries * d# 64 max
    target
    constant arp-size
    create arp-cache arp-size allot
    meta
    arp-cache-entries 1- arp-cache-entry-size * arp-cache +
    target
    constant arp-cache-last
[ELSE]
    arp-cache-entry-size arp-cache-entries * d# 64 max constant arp-size
    create arp-cache arp-size allot
    arp-cache-entries 1- arp-cache-entry-size * arp-cache + constant arp-cache-last
[THEN]

: arp-foreach                       \  (func -- )
    arp-cache-last 2>r
    begin
        2r@ swap            \  ptr func
        execute
        r> dup arp-cache-entry-size - >r
        arp-cache =
    until
    2r> 2drop
;

build-debug? [IF]
: arp-.
    dup @ hex4 space              \  age
    dup 2+ dup @ swap d# 2 + dup @ swap d# 2 + @ ethaddr-pretty space
    d# 8 + 2@ ip-pretty
    cr
;

: arp-dump
    ['] arp-. arp-foreach
;
[THEN]

: arp-del   h# ff swap !  ;
: arp-reset ['] arp-del arp-foreach ;
: used?     @ h# ff <> ;
: arp-age-1 dup used? d# 1 and swap +!  ;
: arp-age   ['] arp-age-1 arp-foreach ;
: arp-cmp   ( ptr0 ptr1 -- ptr) over @ over @ > ?: ;
: arp-oldest \  return the address of the oldest ARP entry
    arp-cache ['] arp-cmp arp-foreach ;

\  ARP offsets
\  d# 28 sender ethaddr
\  d# 34 sender ip
\  d# 38 target ethaddr
\  d# 44 target ip

d# 20 constant OFFSET_ARP_OPCODE
d# 22 constant OFFSET_ARP_SRC_ETH
d# 28 constant OFFSET_ARP_SRC_IP
d# 32 constant OFFSET_ARP_DST_ETH
d# 38 constant OFFSET_ARP_DST_IP

: arp-is-response
    OFFSET_ETH_TYPE packet@ h# 806 =
    OFFSET_ARP_OPCODE packet@ d# 2 =
    and
;

\  write the current arp response into the cache, replacing the oldest entry
: !--                   \  ( val ptr -- ptr-2 )
    tuck                \  ptr val ptr
    !
    2-
;

\  Current packet is an ARP response; write it to the given slot in the ARP cache, ageing all others

: arp-cache-write   \  ( ptr -- )
    arp-age         \  because this new entry will have age d# 0
    d# 0 over !        \  age d# 0
    >r

    d# 3 OFFSET_ARP_SRC_ETH mac-inoffset mac@n 
    r@ d# 6 + !-- !-- !-- drop
    d# 2 OFFSET_ARP_SRC_IP mac-inoffset mac@n 
    r> d# 8 + 2!

;

\  Comparison of IP
: arp-cmpip         \  (ip01 ip23 ptr/0 ptr -- ip01 ip23 ptr)
    dup used? if
        dup d# 8 + 2@ d# 2 2pick d<> ?:
    else
        drop
    then
;

: arp-cache-find ( ip01 ip23 -- ip01 ip23 ptr )
\  Find an IP.  Zero if the IP was not found in the cache, ptr to entry otherwise
    d# 0 ['] arp-cmpip arp-foreach ;


: arp-issue-whohas      \  (ip01 ip23 -- ptr)
    mac-pkt-begin
    ethaddr-broadcast mac-pkt-3,
    net-my-mac mac-pkt-3,
    h# 806                   \  frame type
    d# 1                       \  hard type
    h# 800                   \  prot type
    mac-pkt-3,
    h# 0604                  \  hard size, prot size
    d# 1                       \  op (1=request)
    mac-pkt-2,
    net-my-mac mac-pkt-3,
    net-my-ip mac-pkt-2,
    ethaddr-broadcast mac-pkt-3,
    mac-pkt-2,
    mac-pkt-complete drop
    mac-send
;

\  Look up ethaddr for given IP.
\  If found, return pointer to the 6-byte ethaddr
\  If not found, issue an ARP request and return d# 0.

: arp-lookup    \  ( ip01 ip23 -- ptr)
    2dup 
    ip-router 2@ dxor ip-subnetmask 2@ dand
    d0<>
    if
        2drop
        ip-router 2@
    then
    arp-cache-find          \  ip01 ip23 ptr
    dup 0= if
        -rot                \  d# 0 ip01 ip23
        arp-issue-whohas    \  d# 0
    else
        nip nip 2+          \  ptr
    then
;

\  If the current packet is an ARP request for our IP, answer it
: arp-responder
    \  is destination ff:ff:ff:ff:ff:ff or my mac
    d# 3 OFFSET_ETH_DST mac-inoffset mac@n
    and and invert 0=

    net-my-mac              \  a b c
    d# 2 OFFSET_ETH_DST 2+ mac-inoffset mac@n
    d= swap                 \  F a
    OFFSET_ETH_DST packet@ = and

    or
    OFFSET_ETH_TYPE packet@ h# 806 = and
    \  is target IP mine?
    d# 2 OFFSET_ARP_DST_IP mac-inoffset mac@n net-my-ip d= and
    if
        mac-pkt-begin

        d# 3 OFFSET_ARP_SRC_ETH mac-pkt-src
        net-my-mac mac-pkt-3,
        h# 806                \  frame type
        d# 1                  \  hard type
        h# 800                \  prot type
        mac-pkt-3,
        h# 0604               \  hard size, prot size
        d# 2                  \  op (2=reply)
        mac-pkt-2,
        net-my-mac mac-pkt-3,
        net-my-ip mac-pkt-2,
        d# 3 OFFSET_ARP_SRC_ETH mac-pkt-src
        d# 2 OFFSET_ARP_SRC_IP mac-pkt-src

        mac-pkt-complete drop
        mac-send
    then
;

: arp-announce
    mac-pkt-begin

    ethaddr-broadcast mac-pkt-3,
    net-my-mac mac-pkt-3,
    h# 806                \  frame type
    d# 1                  \  hard type
    h# 800                \  prot type
    mac-pkt-3,
    h# 0604               \  hard size, prot size
    d# 2                  \  op (2=reply)
    mac-pkt-2,
    net-my-mac mac-pkt-3,
    net-my-ip mac-pkt-2,
    ethaddr-broadcast mac-pkt-3,
    net-my-ip mac-pkt-2,

    mac-pkt-complete drop
    mac-send
    
;

: arp-handler
    arp-responder
    arp-is-response
    if
        d# 2 OFFSET_ARP_SRC_IP mac-inoffset mac@n 
        arp-cache-find nip nip
        dup 0= if
            drop arp-oldest
        then
        arp-cache-write
    then
;

]module
