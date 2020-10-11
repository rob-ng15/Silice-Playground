 ### Example Code

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
```
: drawblocks
  3f 0 do
    i i i 200 200 rectangle!
  loop ;
cs! drawblocks

```
```
: drawcircles
  3f 0 do
    i 100 100 3f i - 2* circle!
  loop ;
cs! drawcircles

```
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
```
: tputest
  3f 0 do
    40 i - tpubackground!
    i tpuforeground!
    i tpuemit
  loop ;
tpucs! tputest

```
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
```
: setsprites
  7 0 do
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
  1 background! 4 fff1 ! 1 fff2 !

  15 70 0 a0 110 rectangle!
  2a 0 70 110 a0 rectangle!
  3f 90 90 40 circle!

  0 ff30 ! 3 ff33 ! 1 ff31 ! 0 ff32 !
  1 ff30 ! c ff33 ! 1 ff31 ! 1 ff32 !
  2 ff30 ! 30 ff33 ! 1 ff31 ! 2 ff32 !
  3 ff30 ! 3f ff33 ! 1 ff31 ! 3 ff32 !
  0 ff40 ! 0 ff43 ! 1 ff41 ! 0 ff42 !
  1 ff40 ! f ff43 ! 1 ff41 ! 1 ff42 !
  2 ff40 ! 33 ff43 ! 1 ff41 ! 2 ff42 !
  3 ff40 ! 3c ff43 ! 1 ff41 ! 3 ff42 !

  3f tpubackground! 3 tpuforeground!

  100 0 do 
    10 2 tpuxy! $" Counting " tpu.$ timer@ dup led! tpu.#    
    0 ff30 ! i ff34 ! i ff35 !
    1 ff30 ! i ff34 ! 100 i - ff35 !
    2 ff30 ! 100 i - ff34 ! i ff35 !
    3 ff30 ! 100 i - ff34 ! 100 i - ff35 !
    0 ff40 ! i ff44 ! 80 ff45 !
    1 ff40 ! 80 ff44 ! i ff45 !
    2 ff40 ! 100 i - ff44 ! 80 ff45 !
    3 ff40 ! 80 ff44 ! 100 i - ff45 !
    
    2000 0 do loop
  loop ;
screentest

```
