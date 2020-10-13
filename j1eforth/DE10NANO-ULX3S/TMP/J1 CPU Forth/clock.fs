( Clock                                      JCB 10:54 11/17/10)

variable seconds
variable minutes
variable hours
variable days
variable months
variable years
variable weekday

: show2 ( a -- ) @ s>d <# # # #> type ;

: setdate ( ud -- )
    [ -8 3600 * ] literal s>d d+
    d# 1 d# 60 m*/mod seconds !
    d# 1 d# 60 m*/mod minutes !
    d# 1 d# 24 m*/mod hours !
    d# 59. d- \ Days since Mar 1 1900
    2dup d# 1 d# 7 m*/mod weekday ! 2drop
    d# 365 um/mod ( days years )
    dup d# 1900 + years !
    d# 4 / 1- - \ subtract leaps ( daynum 0-365 )
    dup d# 5 * d# 308 + d# 153 / d# 2 - months !
    months @ d# 4 + d# 153 d# 5 */ - d# 122 + days !

    home
    'emit @ >r
    ['] vga-bigemit 'emit !

    s" ThuFriSatSunMonTueWed" drop
    weekday @ d# 3 * + d# 3 type cr
    s" MarAprMayJunJulAugSepOctNovDecJanFeb" drop
    months @ d# 3 * + d# 3 type
    space days @ d# 0 .r cr
    years @ . cr

    true if
        hours show2
        minutes show2
        seconds show2
        home
    then

    r> 'emit !
;

: setdelay ( ud -- )
    'emit @ >r
    ['] vga-emit 'emit !
    d# 32 d# 0 vga-at-xy
    s" ntp " type <# # # # [char] . hold #s #> type
    s"  ms " type
    r> 'emit !
;

include ntp.fs

2variable ntp-alarm

: clock-main
    vga-page
    d# 1000000. ntp-alarm setalarm
    begin
        begin
            mac-fullness
        while
            arp-handler
            OFFSET_ETH_TYPE packet@ h# 800 =
            if
                d# 2 OFFSET_IP_DSTIP mac-inoffset mac@n net-my-ip d=
                if
                    icmp-handler
                then
                loader-handler
                ntp-handler
            then

            depth if .s cr then
            mac-consume
        repeat

        ntp-alarm isalarm if
            ntp-request
            d# 1000000. ntp-alarm setalarm
        then

        next?
    until
;

