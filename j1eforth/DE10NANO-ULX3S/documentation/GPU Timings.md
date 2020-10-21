# GPU Timings

The GPU within the j1eforth implementation on the DE10NANO and the ULX3S runs at 25MHz, the same rate as the video pixel clock. The GPU runs at every pixel clock, even during vblank and hblank.

## Setup and render cycles per pixel

Operation | Setup Cycles | Per Pixel | Notes
:----: | ---- | ----- | -----
PIXEL | 0 | 1 | The pixel is sent directly to the BITMAP, the GPU does not activate. The BITMAP checks if the pixel is in range before rendering.
RECTANGLE | 1 | 1 | Total time is 1 + 1 cycle per pixel, so for a 10 x 10 rectangle, 101 cycles.
LINE | 2 | 3 | Initial setup is 2 cycles. Total time is 2 + 3 x ( number of pixels - 1 ) + 1. For the line 10,10 to 15, 20 a total of 11 pixels, 33 cycles.
CIRCLE | 1 | 8 | Calculates 1 pixel on 1st arc of the circle, then renders each of the 8 arcs.
