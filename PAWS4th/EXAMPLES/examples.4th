## Output some multi-coloured text

```
: tputest
  3f 0 do
    3f i - tpubackground!
    i tpuforeground!
    i tpuemit
  loop ;
tpucs! tputest

```

## LED and TIMER test

```
: ledtest
    base @ 2 base !
    tpucs! timer1hz!
    10 0 do
        i tpuforeground! 3f i - tpubackground!
        8 1 tpuxy! timer1hz@ dup 5 tpuu.r# tpuspace $" seconds " tpu.$
        led! led@
        8 tpuu.r tpuspace $" LEDs" tpu.$
        3e8 sleep
    loop
   cr 0 led! base ! ;
ledtest

```

## Test multiple features of the display

```
: spritetile
    5555 aaaa 5555 aaaa 5555 aaaa 5555 aaaa
    5555 aaaa 5555 aaaa 5555 aaaa 5555 aaaa
    aaaa 5555 aaaa 5555 aaaa 5555 aaaa 5555
    aaaa 5555 aaaa 5555 aaaa 5555 aaaa 5555
    701c 1830 820 820 ff8 3938 3938 fffe
    dff6 dff6 9c72 d836 c60 c60 ee0 0
    ffff ffff ffff ffff ffff ffff ffff ffff
    ffff ffff ffff ffff ffff ffff ffff ffff
    5555 aaaa 5555 aaaa 5555 aaaa 5555 aaaa
    5555 aaaa 5555 aaaa 5555 aaaa 5555 aaaa
    aaaa 5555 aaaa 5555 aaaa 5555 aaaa 5555
    aaaa 5555 aaaa 5555 aaaa 5555 aaaa 5555
    701c 1830 820 820 ff8 3938 3938 fffe
    dff6 dff6 9c72 d836 c60 c60 ee0 0
    ffff ffff ffff ffff ffff ffff ffff ffff
    ffff ffff ffff ffff ffff ffff ffff ffff ;

: setsprites
  4 0 do
    spritetile i lsltile!
    spritetile i usltile!
  loop ;
setsprites

1 -1f 0 0 0 vectorvertex!
1 0 -1f 0 1 vectorvertex!
1 1f 0 0 2 vectorvertex!
1 0 1f 0 3 vectorvertex!
1 -1f 0 0 4 vectorvertex!

: screentest
  cs! tpucs! timer1hz!
  1 4 1 background!

  15 130 0 150 1e0 rectangle!
  2a 0 e0 280 100 rectangle!
  3f 140 f0 40 fcircle!
  3c 140 f0 80 circle!
  3 0 f0 140 0 line!
  3 140 0 280 f0 line!
  3 280 f0 140 1e0 line!
  3 140 1e0 0 f0 line!

  3 140 e0 150 f0 140 100 triangle!
  3 140 e0 140 100 130 f0 triangle!

  3 140 f0 0 vector!
  c 150 f0 0 vector!
  33 130 f0 0 vector!
  3c 140 e0 0 vector!
  30 140 100 0 vector!

  3  0   0   0 1 0 0 lslsprite!
  c  0   1d0 1 1 0 1 lslsprite!
  30 270 0   2 1 1 2 lslsprite!
  3f 270 1d0 3 1 0 3 lslsprite!
  0  0   e8  0 1 0 0 uslsprite!
  f  138 0   1 1 0 1 uslsprite!
  33 270 e8  2 1 1 2 uslsprite!
  3c 138 1d0 3 1 0 3 uslsprite!

  3f tpubackground! 3 tpuforeground!

  terminalhide! 440 0 do
    0 ff30 !
    14 timer1khz! vblank?
    22 2 tpuxy! $" Counting " tpu.$ timer1hz@ dup led! tpu.#
    20 3 tpuxy! $" Sprite 0 at " tpu.$ ff34 @ 5 tpu.r# ff35 @ 5 tpu.r#

    9 0 lslupdate!
    39 1 lslupdate!
    f 2 lslupdate!
    3f 3 lslupdate!
    1 0 uslupdate!
    8 1 uslupdate!
    7 2 uslupdate!
    38 3 uslupdate!
    timer1khz?
  loop terminalshow! ;
screentest

```

## Button test to move a sprite (ULX3S only at present)

```
: setsprites
  4 0 do
    5555 aaaa 5555 aaaa 5555 aaaa 5555 aaaa
    5555 aaaa 5555 aaaa 5555 aaaa 5555 aaaa
    aaaa 5555 aaaa 5555 aaaa 5555 aaaa 5555
    aaaa 5555 aaaa 5555 aaaa 5555 aaaa 5555
    701c 1830 820 820 ff8 3938 3938 fffe
    dff6 dff6 9c72 d836 c60 c60 ee0 0
    ffff ffff ffff ffff ffff ffff ffff ffff
    ffff ffff ffff ffff ffff ffff ffff ffff
    5555 aaaa 5555 aaaa 5555 aaaa 5555 aaaa
    5555 aaaa 5555 aaaa 5555 aaaa 5555 aaaa
    aaaa 5555 aaaa 5555 aaaa 5555 aaaa 5555
    aaaa 5555 aaaa 5555 aaaa 5555 aaaa 5555
    701c 1830 820 820 ff8 3938 3938 fffe
    dff6 dff6 9c72 d836 c60 c60 ee0 0
    ffff ffff ffff ffff ffff ffff ffff ffff
    ffff ffff ffff ffff ffff ffff ffff ffff
    i lsltile!
  loop ;
setsprites

: buttontest
  cs! tpucs!
  1 4 1 background!

  15 130 0 150 1e0 rectangle!
  2a 0 e0 280 100 rectangle!
  3f 140 f0 40 circle!
  3c 140 f0 80 circle!

  3 0 0 0 1 1 0 lslsprite!

  3f tpubackground! 3 tpuforeground!

  begin
    14 timer1khz! vblank?
    20 2 tpuxy! $" Sprite at " tpu.$ ff34 @ 5 tpu.r# ff35 @ 5 tpu.r#
    buttons@
    dup 2 and 0<> if 40 0 lslupdate! then
    dup 20 and 0<> if 7 0 lslupdate! then
    dup 40 and 0<> if 1 0 lslupdate! then
    dup 8 and 0<> if 38 0 lslupdate! then
    dup 10 and 0<> if 8 0 lslupdate! then
    timer1khz?
    4 and 0<>
  until ;
buttontest

```

## Bitmap Scrolling Test

```
: bitmapscrolling
  cs! tpucs! 5 ff08 !
  100 0 do
    1 ff08 !
    14 timer1khz! vblank?
    40 27f 0  27f 1df line!
    20 rng 20 + 27f 1df rng 27f 1df line!
    timer1khz?
  loop ;
bitmapscrolling

```

## Audio Test (ULX3S only at present)

```
: closeencounters
    1 0 1d 3e8 beep! beep?
    1 0 1e 3e8 beep! beep?
    1 0 19 3e8 beep! beep?
    1 0 d 3e8 beep! beep?
    1 0 14 3e8 beep! beep?
;
closeencounters

```
