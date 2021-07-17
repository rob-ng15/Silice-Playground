: drawrectangles
  40 0 do
    i 40 0 colour!
    0 i 4 * 20 i 4 * 20 + rectangle
    i 4 * 0 i 4 * 20 + 20 rectangle
    i 4 * fc i 4 * 20 + 11c rectangle
    fc i 4 * 11c i 4 * 20 + rectangle
    i 4 * i 4 * i 4 * 20 + i 4 * 20 + rectangle
  loop ;
0 terminal!
cs drawrectangles
7d0 sleep
1 terminal!
