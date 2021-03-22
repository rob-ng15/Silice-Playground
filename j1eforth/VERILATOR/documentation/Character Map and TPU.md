# Character Map with TPU

* 80 x 30 64 colour character map display, using IBM 8x16 256 character ROM
    * Includes a simple TPU to draw characters on the display (will be expanded)
    * Each character map cell has 3 attributes
        * Character code
        * Foreground colour { rrggbb }
        * Background colour { Arrggbb ) if A (ALPHA) is 1, then the lower layers are displayed.

## Memory Map for the Character Map Layer and TPU

Hexadecima<br>Address | Write | Read
:-----: | ----- | -----
ff10 | Set the TPU x coordinate |
ff11 | Set the TPU y coordinate |
ff12 | Set the TPU character code |
ff13 | Set the TPU background colour |
ff14 | Set the TPU foreground colour |
ff15 | Start TPU<br>1 - Move to x,y<br>2 - Write character code in foreground colour, background colour to x,y and move to the next position<br>3 - Clear the character map | TPU busy

### j1eforth Character Map Layer and TPU words

CHARACTER MAP and TPU<br>Word | Usage
----- | -----
tpucs! | Example ```tpucs!``` clears the character map (sets to transparent)
tpuxy! | Example ```0 0 tpuxy!``` moves the TPU cursor to 0,0 (top left)
tpuforeground! | Example ```3f tpuforeground!``` sets the TPU foreground to colour 3f (white)
tpubackground! | Example ```3 tpubackground!``` sets the TPU background to colour 3 (blue)
tpuemit | Equivalent to ```emit``` for the TPU and character map
tputype | Equivalent ```type``` for the TPU and character map
tpuspace<br>tpuspaces | Equivalent to ```space``` and ```spaces``` for the TPU and character map
tpu.r<br>tpu!u.r<br>tpuu.<br>tpu.<br>tpu.#<br>tpuu.#<br>tpuu.r#<br>tpu.r#<br>tpu.$ | Equivalent to ```.r``` ```u.r``` ```u.``` ```.``` ```.#``` ```u.#``` ```u.r#``` ```.r#``` ```.$``` for the TPU and character map
