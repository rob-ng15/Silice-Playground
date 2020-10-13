( Sprite low-level                           JCB 15:23 11/15/10)

: vga-line@
    begin
        vga_line @
        vga_line @
        over xor
    while
        drop
    repeat
;

: waitblank begin vga-line@ d# 512 = until ;

: sprite! ( x y spr -- )
    2* cells vga_spritey + tuck ! 2- ! ;

: hide  \ hide all the sprites at (800,800)
    d# 8 0do d# 800 dup i sprite! loop ;

