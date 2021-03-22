( Packet construction, tx, rx                JCB 13:25 08/24/10)
module[ packet"

: packet@ ( u -- u )
    mac-inoffset mac@ ;

: packetd@ ( u -- ud )
    mac-inoffset dup 2+ mac@ swap mac@ ;


]module
