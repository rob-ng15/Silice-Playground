#Example Code

## Draw multi-coloured rectangles

```
: drawrectangles
  3f 0 do
    i 0 i 4 * 20 i 4 * 20 + rectangle!
    i i 10 * 0 i 10 * 20 + 20 rectangle!
    i i 10 * 1ff i 10 * 20 + 21f rectangle!
    i 1ff i 10 * 21f i 10 * 20 + rectangle!
    i i 10 * i 10 * i 10 * 20 + i 10 * 20 + rectangle!
  loop ;
cs! drawrectangles

```

## Draw multi-coloured circles

```
: drawcircles
  3f 0 do
    i 100 100 3f i - 2* circle!
  loop ;
cs! drawcircles

```

## Blitter set tile and blit multi-coloured space invader pictures

```
701c 1830 820 820
ff8 3938 3938 fffe
dff6 dff6 9c72 d836
c60 c60 ee0 0
0 blit1tile!
: invaders
  10 0 do
    i 10 0 do
      dup 3f i - swap 0 swap 18 * i 18 * blit1!
    loop  drop
  loop ;
cs! invaders

```

## Output some multi-coloured text

```
: tputest
  3f 0 do
    40 i - tpubackground!
    i tpuforeground!
    i tpuemit
  loop ;
tpucs! tputest

```

## LED and TIMER test

```
: ledtest
    base @ 2 base !
    tpucs!
    40 0 do
        i tpuforeground! 3f i - tpubackground!
        8 1 tpuxy! timer@ dup 5 tpuu.r# tpuspace $" seconds " tpu.$
        led! led@ 
        8 tpuu.r tpuspace $" LEDs" tpu.$ 
        8000 0 do loop 
    loop
   cr 0 led! base ! ;
ledtest

```

## Test multiple features of the display

```
: setsprites
  3 0 do
    5555 a0a0 5555 a0a0 5555 a0a0 5555 a0a0
    5555 a0a0 5555 a0a0 5555 a0a0 5555 a0a0
    a0a0 5555 a0a0 5555 a0a0 5555 a0a0 5555
    a0a0 5555 a0a0 5555 a0a0 5555 a0a0 5555
    701c 1830 820 820 ff8 3938 3938 fffe
    dff6 dff6 9c72 d836 c60 c60 ee0 0
    ffff ffff ffff ffff ffff ffff ffff ffff
    ffff ffff ffff ffff ffff ffff ffff ffff 
    i lsltile!
    5555 a0a0 5555 a0a0 5555 a0a0 5555 a0a0
    5555 a0a0 5555 a0a0 5555 a0a0 5555 a0a0
    a0a0 5555 a0a0 5555 a0a0 5555 a0a0 5555
    a0a0 5555 a0a0 5555 a0a0 5555 a0a0 5555
    701c 1830 820 820 ff8 3938 3938 fffe
    dff6 dff6 9c72 d836 c60 c60 ee0 0
    ffff ffff ffff ffff ffff ffff ffff ffff
    ffff ffff ffff ffff ffff ffff ffff ffff 
    i usltile!
  loop ;
setsprites

: screentest
  cs! tpucs!
  1 4 1 background!

  15 70 0 a0 110 rectangle!
  2a 0 70 110 a0 rectangle!
  3f 90 90 40 circle!

  0 0 3 1 1 0 lslsprite!
  0 100 c 1 1 1 lslsprite!
  100 0 30 2 1 2 lslsprite!
  100 100 3f 2 1 3 lslsprite!
  0 80 0 0 1 0 uslsprite!
  80 0 f 1 1 1 uslsprite!
  100 80 33 2 1 2 uslsprite!
  80 100 3c 2 1 3 uslsprite!

  3f tpubackground! 3 tpuforeground!

  200 0 do 
    a 2 tpuxy! $" Counting " tpu.$ timer@ dup led! tpu.#
    9 0 lslupdate!
    39 1 lslupdate!
    f 2 lslupdate!
    3f 3 lslupdate!
    1 0 uslupdate!
    8 1 uslupdate!
    7 2 uslupdate!
    38 3 uslupdate!
    2000 0 do loop vblank
  loop ;
screentest

```
