algorithm gpu(
    // GPU to SET and GET pixels
    output! int11 bitmap_x_write,
    output! int11 bitmap_y_write,
    output! uint7 bitmap_colour_write,
    output! uint2 bitmap_write,

    // From j1eforth
    input   int11 gpu_x,
    input   int11 gpu_y,
    input   uint8 gpu_colour,
    input   int16 gpu_param0,
    input   int16 gpu_param1,
    input   int16 gpu_param2,
    input   int16 gpu_param3,
    input   uint4 gpu_write,

    // From VECTOR DRAWER
    input   int11 v_gpu_x,
    input   int11 v_gpu_y,
    input   uint7 v_gpu_colour,
    input   int11 v_gpu_param0,
    input   int11 v_gpu_param1,
    input   int11 v_gpu_param2,
    input   int11 v_gpu_param3,
    input   uint4 v_gpu_write,

    // From DISPLAY LIST DRAWER
    input   int11 dl_gpu_x,
    input   int11 dl_gpu_y,
    input   uint8 dl_gpu_colour,
    input   int16 dl_gpu_param0,
    input   int16 dl_gpu_param1,
    input   int16 dl_gpu_param2,
    input   int16 dl_gpu_param3,
    input   uint4 dl_gpu_write,

    // For setting blit1 tile bitmaps
    input   uint6   blit1_writer_tile,
    input   uint4   blit1_writer_line,
    input   uint16  blit1_writer_bitmap,  
    input   uint1   blit1_writer_active,

    output  uint6 gpu_active
) <autorun> {
    // 64 x 16 x 16 1 bit tilemap for blit1tilemap
    dualport_bram uint16 blit1tilemap[ 1024 ] = uninitialized;
    
    // GPU work variable storage
    // Present GPU pixel and colour
    int11 gpu_active_x = uninitialized;
    int11 gpu_active_y = uninitialized;
    uint7 gpu_active_colour = uninitialized;
    
    // Temporary storage for GPU operations with meaningful names centre coordinates, end coordinates, width, height, deltas, radius, etc
    int11 gpu_xc = uninitialized;
    int11 gpu_yc = uninitialized;
    int11 gpu_x1 = uninitialized;
    int11 gpu_y1 = uninitialized;
    int11 gpu_x2 = uninitialized;
    int11 gpu_y2 = uninitialized;
    int11 gpu_w = uninitialized;
    int11 gpu_h = uninitialized;
    int11 gpu_dx = uninitialized;
    int11 gpu_sx = uninitialized;
    int11 gpu_dy = uninitialized;
    int11 gpu_sy = uninitialized;
    int11 gpu_min_x = uninitialized;
    int11 gpu_max_x = uninitialized;
    int11 gpu_min_y = uninitialized;
    int11 gpu_max_y = uninitialized;
    int11 gpu_numerator = uninitialized;
    int11 gpu_numerator2 = uninitialized;
    int11 gpu_count = uninitialized;
    int11 gpu_max_count = uninitialized;
    uint6 gpu_tile = uninitialized;
    // Filled triangle calculations
    uint1 w0 = uninitialized;
    uint1 w1 = uninitialized;
    uint1 w2 = uninitialized;
    
    // GPU inputs, copied to according to Forth, VECTOR or DISPLAY LISTS
    int11   x = uninitialized;
    int11   y = uninitialized;
    int16   param0 = uninitialized;
    int16   param1 = uninitialized;
    int16   param2 = uninitialized;
    int16   param3 = uninitialized;
    uint4   write = uninitialized;

    // blit1tilemap read access for the blit1tilemap
    blit1tilemap.addr0 := gpu_tile * 16 + gpu_active_y;
    blit1tilemap.wenable0 := 0;
        
    // blit1tilemap write access for the GPU to load tilemaps
    blit1tilemap.addr1 := blit1_writer_tile * 16 + blit1_writer_line;
    blit1tilemap.wdata1 := blit1_writer_bitmap;
    blit1tilemap.wenable1 := blit1_writer_active;

    bitmap_write := 0;
    bitmap_colour_write := gpu_active_colour;
    
    always {
        if( dl_gpu_write != 0 ) {
            x = dl_gpu_x;
            y = dl_gpu_y;
            gpu_active_colour = dl_gpu_colour;
            param0 = dl_gpu_param0;
            param1 = dl_gpu_param1;
            param2 = dl_gpu_param2;
            param3 = dl_gpu_param3;
            write = dl_gpu_write;
        } else {
            if( v_gpu_write != 0 ) {
                x = v_gpu_x;
                y = v_gpu_y;
                gpu_active_colour = v_gpu_colour;
                param0 = v_gpu_param0;
                param1 = v_gpu_param1;
                param2 = v_gpu_param2;
                param3 = v_gpu_param3;
                write = v_gpu_write;
            } else {
                if( gpu_write != 0 ) {
                    x = gpu_x;
                    y = gpu_y;
                    gpu_active_colour = gpu_colour;
                    param0 = gpu_param0;
                    param1 = gpu_param1;
                    param2 = gpu_param2;
                    param3 = gpu_param3;
                    write = gpu_write;
                } else {
                    write = 0;
                }
            }
        }
    }
    
    while(1) {
        switch( gpu_active ) {
            // GPU Inactive, allow a new operation to start
            case 0: {
                // Start the GPU from j1eforth
                switch( write ) {
                    case 1: {
                        // Setup writing a pixel colour to x,y 
                        // Done directly, does not activate the GPU
                        bitmap_x_write = x;
                        bitmap_y_write = y;
                        bitmap_write = 1;
                    }
                    case 2: {
                        // Setup drawing a rectangle from x,y to param0,param1 in colour
                        // Ensures that works left to right, top to bottom
                        // Cut out pixels out of 0 <= x <= 639 , 0 <= y <= 479
                        gpu_active_x = ( x < param0 ) ? ( x < 0 ? 0 : x ) : ( param0 < 0 ? 0 : param0 );                // left
                        gpu_active_y = ( y < param1 ) ? ( y < 0 ? 0 : y ) : ( param1 < 0 ? 0 : param1 );                // top
                        gpu_x2 = ( x < param0 ) ? ( x < 0 ? 0 : x )  : ( param0 < 0 ? 0 : param0 );                     // left - for next line
                        gpu_x1 = ( x < param0 ) ? ( param0 > 639 ? 639 : param0 ) : ( x > 639 ? 639 : x );              // right - at end of line
                        gpu_y1 = ( y < param1 ) ? ( param1 > 479 ? 479 : param1 ) : ( y > 479 ? 479 : y );              // bottom - at end of rectangle
                        gpu_active = 1; 
                    }
                    case 3: {
                        // Setup drawing a line from x,y to param0,param1 in colour
                        // Ensure LEFT to RIGHT
                        gpu_active_x = ( x < param0 ) ? x : param0;
                        gpu_active_y = ( x < param0 ) ? y : param1;
                        // Absolute DELTAs
                        gpu_dx = ( param0 < x ) ? x - param0 : param0 - x;
                        gpu_dy = ( param1 < y ) ? y - param1 : param1 - y;
                        // Shift X is always POSITIVE
                        gpu_sx = 1;
                        // Shift Y is NEGATIVE or POSITIVE
                        gpu_sy = ( x < param0 ) ? ( ( y < param1 ) ? 1 : -1 ) : ( ( y < param1 ) ? -1 : 1 );
                        gpu_count = 0;
                        gpu_active = 2; 
                    }
                    case 4: {
                        // Setup drawing a circle centre x,y or radius param0 in colour
                        gpu_active_x = 0;
                        gpu_active_y = param0;
                        gpu_xc = x;
                        gpu_yc = y;
                        gpu_numerator = 3 - ( 2 * param0 );
                        gpu_active = 6;
                    }
                    case 5: {
                        // Setup 1 bit 16x16 blitter starting at x,y in colour of tile param0
                        gpu_active_x = 0;
                        gpu_active_y = 0;
                        gpu_x1 = x;
                        gpu_y1 = y;
                        gpu_w = 15;
                        gpu_h = 15;
                        gpu_tile = param0;                       
                        gpu_active = 14;
                    }
                    case 6: {
                        // Setup drawing a filled circle centre x,y or radius param0 in colour
                        // Minimum radius is 4
                        gpu_active_x = 0;
                        gpu_active_y = ( param0 < 4 ) ? 4 : param0;
                        gpu_xc = x;
                        gpu_yc = y;
                        gpu_count = ( param0 < 4 ) ? 4 : param0;
                        gpu_numerator = 3 - ( 2 * ( ( param0 < 4 ) ? 4 : param0 ) );
                        gpu_active = 16;
                    }
                    case 7: {
                        // Setup drawing a filled triangle x,y param0, param1, param2, param3
                        gpu_active_x = x;
                        gpu_active_y = y;
                        gpu_x1 = param0;
                        gpu_y1 = param1;
                        gpu_x2 = param2;
                        gpu_y2 = param3;
                        gpu_active = 25;
                    }
                    default: {}
                }
            }
                
            // Perform GPU Operation
            // GPU functions 1 pixel per cycle, even during hblank and vblank
            case 1: {
                // Rectangle of colour at x,y top left to param0, param1 bottom right
                bitmap_x_write = gpu_active_x;
                bitmap_y_write = gpu_active_y;
                bitmap_write = 1;
                // Move to next pixel
                gpu_active = ( ( gpu_active_x == gpu_x1) && ( gpu_active_y == gpu_y1 ) ) ? 0 : 1;
                gpu_active_x = ( gpu_active_x == gpu_x1 ) ? gpu_x2 : gpu_active_x + 1;
                gpu_active_y = ( gpu_active_x == gpu_x1 ) ? gpu_active_y + 1 : gpu_active_y;
            }

            case 2: {
                // Bresenham's Line Drawing Algorithm
                gpu_numerator = ( gpu_dx > gpu_dy ) ? ( gpu_dx >> 1 ) : -( gpu_dy >> 1 );
                gpu_max_count = ( gpu_dx > gpu_dy ) ? gpu_dx : gpu_dy;
                gpu_active = 3;
            }
            case 3: {
                // Bresenham's Line Drawing Algorithm.
                // Draw the line
                bitmap_x_write = gpu_active_x;
                bitmap_y_write = gpu_active_y;
                bitmap_write = 1;
                
                // Check if done
                gpu_active = ( gpu_count < gpu_max_count ) ? 4 : 0;
                gpu_numerator2 = gpu_numerator;
            }
            case 4: {          
                // Bresenham's Line Drawing Algorithm.
                if ( gpu_numerator2 > (-gpu_dx) ) {
                    gpu_numerator = gpu_numerator - gpu_dy;
                    gpu_active_x = gpu_active_x + gpu_sx;
                }
                gpu_active = 5;                
            }
            case 5: {
                // Bresenham's Line Drawing Algorithm
                if( gpu_numerator2 < gpu_dy ) {
                    gpu_numerator = gpu_numerator + gpu_dx;
                    gpu_active_y = gpu_active_y + gpu_sy;
                }
                gpu_count = gpu_count + 1;
                gpu_active = 3;
            }
            
            case 6: {
                // Bresenham's Circle Drawing Algorithm - Arc 0
                bitmap_x_write = gpu_xc + gpu_active_x;
                bitmap_y_write = gpu_yc + gpu_active_y;
                bitmap_write = 1;
                gpu_active = 7;
            }
            case 7: {
                // Bresenham's Circle Drawing Algorithm - Arc 1
                bitmap_x_write = gpu_xc - gpu_active_x;
                bitmap_y_write = gpu_yc + gpu_active_y;
                bitmap_write = 1;
                gpu_active = 8;
            }
            case 8: {
                // Bresenham's Circle Drawing Algorithm - Arc 2
                bitmap_x_write = gpu_xc + gpu_active_x;
                bitmap_y_write = gpu_yc - gpu_active_y;
                bitmap_write = 1;
                gpu_active = 9;
            }
            case 9: {
                // Bresenham's Circle Drawing Algorithm - Arc 3
                bitmap_x_write = gpu_xc - gpu_active_x;
                bitmap_y_write = gpu_yc - gpu_active_y;
                bitmap_write = 1;
                gpu_active = 10;
            }
            case 10: {
                // Bresenham's Circle Drawing Algorithm - Arc 4
                bitmap_x_write = gpu_xc + gpu_active_y;
                bitmap_y_write = gpu_yc + gpu_active_x;
                bitmap_write = 1;
                gpu_active = 11;
            }
            case 11: {
                // Bresenham's Circle Drawing Algorithm - Arc 5
                bitmap_x_write = gpu_xc - gpu_active_y;
                bitmap_y_write = gpu_yc + gpu_active_x;
                bitmap_write = 1;
                gpu_active = 12;
            }
            case 12: {
                // Bresenham's Circle Drawing Algorithm - Arc 6
                bitmap_x_write = gpu_xc + gpu_active_y;
                bitmap_y_write = gpu_yc - gpu_active_x;
                bitmap_write = 1;
                gpu_active = 13;
            }
            case 13: {
                // Bresenham's Circle Drawing Algorithm - Arc 7
                bitmap_x_write = gpu_xc - gpu_active_y;
                bitmap_y_write = gpu_yc - gpu_active_x;
                bitmap_write = 1;
                if( gpu_active_y >= gpu_active_x ) {
                    gpu_active_x = gpu_active_x + 1;
                    if( gpu_numerator > 0 ) {
                        gpu_numerator = gpu_numerator + 4 * (gpu_active_x - gpu_active_y) + 10;
                        gpu_active_y = gpu_active_y - 1;
                    } else {
                        gpu_numerator = gpu_numerator + 4 * gpu_active_x + 6;
                    }
                    gpu_active = 6;
                } else {
                    gpu_active = 0;
                }
            }

            case 14: {
                // 1 bit blitter
                // delay to read 1 line from blit1tilemap memory
                gpu_active = 15;
            }
            case 15: {
                // 1 bit BLITTER
                // Draw pixel, move to next pixel
                if( blit1tilemap.rdata0[15 -gpu_active_x,1] ) {
                    bitmap_x_write = gpu_x1 + gpu_active_x;
                    bitmap_y_write = gpu_y1 + gpu_active_y;
                    bitmap_write = 1;
                }
                gpu_active = ( gpu_active_x < gpu_w ) ? 15 : ( ( gpu_active_y < gpu_h ) ? 14 : 0 );
                gpu_active_x = ( gpu_active_x < gpu_w ) ? gpu_active_x + 1 : 0;
                gpu_active_y = ( gpu_active_x < gpu_w ) ? gpu_active_y : gpu_active_y + 1;
            }

            case 16: {
                // Bresenham's Circle Drawing Algorithm
                // Filled circles
                bitmap_x_write = gpu_xc + gpu_active_x;
                bitmap_y_write = gpu_yc + gpu_count;
                bitmap_write = 1;
                gpu_active = 17;
            }
            case 17: {
                bitmap_x_write = gpu_xc + gpu_active_x;
                bitmap_y_write = gpu_yc - gpu_count;
                bitmap_write = 1;
                gpu_active = 18;
            }
            case 18: {
                bitmap_x_write = gpu_xc - gpu_active_x;
                bitmap_y_write = gpu_yc + gpu_count;
                bitmap_write = 1;
                gpu_active = 19;
            }
            case 19: {
                bitmap_x_write = gpu_xc - gpu_active_x;
                bitmap_y_write = gpu_yc - gpu_count;
                bitmap_write = 1;
                gpu_active = 20;
           }
            case 20: {
                bitmap_x_write = gpu_xc + gpu_count;
                bitmap_y_write = gpu_yc + gpu_active_x;
                bitmap_write = 1;
                gpu_active = 21;
            }
            case 21: {
                // Bresenham's Circle Drawing Algorithm
                bitmap_x_write = gpu_xc - gpu_count;
                bitmap_y_write = gpu_yc + gpu_active_x;
                bitmap_write = 1;
                gpu_active = 22;
            }
            case 22: {
                bitmap_x_write = gpu_xc + gpu_count;
                bitmap_y_write = gpu_yc - gpu_active_x;
                bitmap_write = 1;
                gpu_active = 23;
            }
            case 23: {
                bitmap_x_write = gpu_xc - gpu_count;
                bitmap_y_write = gpu_yc - gpu_active_x;
                bitmap_write = 1;
                gpu_count = gpu_count - 1;
                gpu_active = ( gpu_count == 0 ) ? 24 : 16;
            }
            case 24: {
                // Calculate the next part of the circle
                if( gpu_active_y >= gpu_active_x ) {
                    gpu_active_x = gpu_active_x + 1;
                    if( gpu_numerator > 0 ) {
                        gpu_numerator = gpu_numerator + 4 * (gpu_active_x - gpu_active_y) + 10;
                        gpu_active_y = gpu_active_y - 1;
                        gpu_count = gpu_active_y - 1;
                    } else {
                        gpu_numerator = gpu_numerator + 4 * gpu_active_x + 6;
                        gpu_count = gpu_active_y;
                    }
                    gpu_active = 16;
                } else {
                    bitmap_x_write = gpu_xc;
                    bitmap_y_write = gpu_yc;
                    bitmap_write = 1;
                    gpu_active = 0;
                }
            }

            case 25: {
                // Brute force filled triangle
                // Find minimum and maximum of x, x1 and x2 for the bounding box
                // Find minimum and maximum of y, y1 and y2 for the bounding box
                gpu_min_x = ( gpu_active_x < gpu_x1 ) ? ( ( gpu_active_x < gpu_x2 ) ? gpu_active_x : gpu_x2 ) : ( ( gpu_x1 < gpu_x2 ) ? gpu_x1: gpu_x2 );
                gpu_min_y = ( gpu_active_y < gpu_y1 ) ? ( ( gpu_active_y < gpu_y2 ) ? gpu_active_y : gpu_y2 ) : ( ( gpu_y1 < gpu_y2 ) ? gpu_y1: gpu_y2 );
                gpu_max_x = ( gpu_active_x > gpu_x1 ) ? ( ( gpu_active_x > gpu_x2 ) ? gpu_active_x : gpu_x2 ) : ( ( gpu_x1 > gpu_x2 ) ? gpu_x1 : gpu_x2 );
                gpu_max_y = ( gpu_active_y > gpu_y1 ) ? ( ( gpu_active_y > gpu_y2 ) ? gpu_active_y : gpu_y2 ) : ( ( gpu_y1 > gpu_y2 ) ? gpu_y1 : gpu_y2 );
                gpu_active = 26;
            }
            case 26: {
                // Clip to the screen edge
                gpu_min_x = ( gpu_min_x < 0 ) ? 0 : gpu_min_x;
                gpu_min_y = ( gpu_min_y < 0 ) ? 0 : gpu_min_y;
                gpu_max_x = ( gpu_min_x > 639 ) ? 639 : gpu_max_x;
                gpu_max_y = ( gpu_min_y > 479 ) ? 479 : gpu_max_y;
                gpu_active = 27;
            }
            case 27: {
                // Find the point closest to the top of the screen
                if( gpu_y1 < gpu_active_y ) {
                    gpu_active_x = gpu_x1;
                    gpu_active_y = gpu_y1;
                    gpu_x1 = gpu_active_x;
                    gpu_y1 = gpu_active_y;
                }
                gpu_active = 28;
            }
            case 28: {
                if( gpu_y2 < gpu_active_y ) {
                    gpu_active_x = gpu_x2;
                    gpu_active_y = gpu_y2;
                    gpu_x2 = gpu_active_x;
                    gpu_y2 = gpu_active_y;
                }
                gpu_active = 29;
            }
            case 29: {
                // Point order is top of screen then down to the right
                if( gpu_x1 < gpu_x2 ) {
                    gpu_x2 = gpu_x1;
                    gpu_y2 = gpu_y1;
                    gpu_x1 = gpu_x2;
                    gpu_y1 = gpu_y2;
                }
                gpu_active = 30;
            }
            case 30: {
                // Start at the top left
                gpu_sx = gpu_min_x;
                gpu_sy = gpu_min_y;
                gpu_count = 0;
                gpu_active = 31;
            }
            case 31: {
                // Calculate 2 x 2 determinant of the pixels in the bounding box to see if in the triangle
                w0 = (( gpu_x2 - gpu_x1 ) * ( gpu_sy - gpu_y1 ) - ( gpu_y2 - gpu_y1 ) * ( gpu_sx - gpu_x1 )) >= 0;
                w1 = (( gpu_active_x - gpu_x2 ) * ( gpu_sy - gpu_y2 ) - ( gpu_active_y - gpu_y2 ) * ( gpu_sx - gpu_x2 )) >= 0;
                w2 = (( gpu_x1 - gpu_active_x ) * ( gpu_sy - gpu_active_y ) - ( gpu_y1 - gpu_active_y ) * ( gpu_sx - gpu_active_x )) >= 0;
                gpu_active = 32;
            }
            case 32: {
                // Draw the pixel if inside the triangle
                bitmap_x_write = gpu_sx;
                bitmap_y_write = gpu_sy;
                bitmap_write = ( w0 && w1 && w2 );
                gpu_count = ( w0 && w1 && w2 ) ? 1 : gpu_count;
                
                if( gpu_sx < gpu_max_x ) {
                    if( ( gpu_count == 1 ) && ~( w0 && w1 && w2 ) ) {
                        // Moved backoutside the triangle, move to the next line
                        gpu_count = 0;
                        gpu_sx = gpu_min_x;
                        gpu_sy = gpu_sy + 1;
                    } else {
                        gpu_sx = gpu_sx + 1;
                    }
                } else {
                    gpu_count = 0;
                    gpu_sx = gpu_min_x;
                    gpu_sy = gpu_sy + 1;
                }
                gpu_active = ( gpu_sy <= gpu_max_y ) ? 31 : 0;
            }
            
            default: {gpu_active = 0;}
        }
    }
}
