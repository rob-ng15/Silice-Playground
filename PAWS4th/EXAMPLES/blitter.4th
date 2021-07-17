701c 1830 820 820
ff8 3938 3938 fffe
dff6 dff6 9c72 d836
c60 c60 ee0 0
0 blittile!
: invaders
  3c 0 7 background!
  10 0 do
    i 40 0 colour!
    i 10 0 do
      dup 18 * i 18 * 0 0 blit
    loop  drop
  loop ;
0 terminal!
cs invaders
7d0 sleep
1 terminal!
