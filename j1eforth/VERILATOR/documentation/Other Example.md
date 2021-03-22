: setup
  cs! tpucs!
  0 0 5 background!
  terminalhide! ;
  
: finish
  terminalshow! ;
  
: mainloop
  ;
  
: demoULX3S
  setup
    begin
      mainloop
      buttons@ 4 and 0<>
    until finish ;
  
