algorithm gpu(
    // GPU to SET and GET pixels
    output! int11 bitmap_x_write,
    output! int11 bitmap_y_write,
    output! uint7 bitmap_colour_write,
    output! uint2 bitmap_write,
    output! uint3 bitmapcolour_fade,
    
    input int11 gpu_x,
    input int11 gpu_y,
    input uint8 gpu_colour,
    input int16 gpu_param0,
    input int16 gpu_param1,
    input int16 gpu_param2,
    input int16 gpu_param3,
    input uint3 gpu_write,
    
    output  uint4 gpu_active
) <autorun> {
    // 256 x 16 x 16 1 bit tilemap for blit1tilemap
    dualport_bram uint16 blit1tilemap[ 4096 ] = uninitialized;
    
    // GPU work variable storage
    // Present GPU pixel and colour
    int11 gpu_active_x = 0;
    int11 gpu_active_y = 0;
    uint7 gpu_active_colour = 0;
    
    // Temporary storage for GPU operations with meaningful names centre coordinates, end coordinates, width, height, deltas, radius, etc
    int11 gpu_xc = 0;
    int11 gpu_yc = 0;
    int11 gpu_x1 = 0;
    int11 gpu_y1 = 0;
    int11 gpu_x2 = 0;
    int11 gpu_y2 = 0;
    int11 gpu_w = 0;
    int11 gpu_h = 0;
    int11 gpu_dx = 0;
    int11 gpu_sx = 0;
    int11 gpu_dy = 0;
    int11 gpu_sy = 0;
    int11 gpu_numerator = 0;
    int11 gpu_numerator2 = 0;
    int11 gpu_radius = 0;
    uint11 gpu_count = 0;
    uint11 gpu_max_count = 0;
    uint8 gpu_tile = 0;

    // blit1tilemap read access for the blit1tilemap
    blit1tilemap.addr0 := gpu_tile * 16 + gpu_active_y;
    blit1tilemap.wenable0 := 0;
        
    // blit1tilemap write access for the GPU to load tilemaps
    blit1tilemap.addr1 := gpu_param0 * 16 + gpu_param1;
    blit1tilemap.wdata1 := gpu_param2;
    blit1tilemap.wenable1 := 0;

    bitmap_write := 0;
    
    while(1) {
        switch( gpu_active ) {
            case 0: {
                // SETUP GPU 
                // gpu_write controls actions
                // 1 = plot pixel
                // 2 = draw rectangle
                // 3 = draw line
                // 4 = draw_circle
                // 5 = 1 bit 16x16 blit in gpu_colour from 1 bit 16x16 tilemap
                // 6 = 10 bit 16x16 blit from 10 bit 16x16 tilemap
                switch( gpu_write ) {
                    case 1: {
                        // Setup writing a pixel colour to x,y 
                        // Done directly, does not activate the GPU
                        bitmap_x_write = gpu_x;
                        bitmap_y_write = gpu_y;
                        bitmap_colour_write = gpu_colour;
                        bitmap_write = 1;
                    }
                    case 2: {
                        // Setup drawing a rectangle from x,y to param0,param1 in colour
                        // Ensures that works left to right, top to bottom
                        // Cut out pixels out of 0 <= x <= 639 , 0 <= y <= 479
                        gpu_active_colour = gpu_colour;
                        gpu_active_x = ( gpu_x < gpu_param0 ) ? ( gpu_x < 0 ? 0 : gpu_x ) : ( gpu_param0 < 0 ? 0 : gpu_param0 );                // left
                        gpu_active_y = ( gpu_y < gpu_param1 ) ? ( gpu_y < 0 ? 0 : gpu_y ) : ( gpu_param1 < 0 ? 0 : gpu_param1 );                 // top
                        gpu_x2 = ( gpu_x < gpu_param0 ) ? ( gpu_x < 0 ? 0 : gpu_x )  : ( gpu_param0 < 0 ? 0 : gpu_param0 );                       // left - for next line
                        gpu_w = ( gpu_x < gpu_param0 ) ? ( gpu_param0 > 639 ? 639 : gpu_param0 ) : ( gpu_x > 639 ? 639 : gpu_x );                        // right - at end of line
                        gpu_h = ( gpu_y < gpu_param1 ) ? ( gpu_param1 > 479 ? 479 : gpu_param1 ) : ( gpu_y > 479 ? 479 : gpu_y );                        // bottom - at end of rectangle
                        gpu_active = 1; 
                    }
                    case 3: {
                        // Setup drawing a line from x,y to param0,param1 in colour
                        // Ensures that works left to right
                        gpu_active_colour = gpu_colour;
                        gpu_active_x = gpu_x;
                        gpu_active_y = gpu_y;
                        gpu_x1 = gpu_param0;
                        gpu_y1 = gpu_param1;
                        gpu_dx = ( gpu_param0 < gpu_x ) ? gpu_x - gpu_param0 : gpu_param0 - gpu_x;
                        gpu_dy = ( gpu_param1 < gpu_y )? gpu_y - gpu_param1 : gpu_param1 - gpu_x;
                        gpu_sx = ( gpu_x < gpu_param0 ) ? 1 : -1;
                        gpu_sy = ( gpu_y < gpu_param1 ) ? 1 : -1;
                        gpu_count = 0;
                        gpu_active = 2; 
                    }
                    case 4: {
                        // Setup drawing a circle centre x,y or radius param0 in colour
                        gpu_active_colour = gpu_colour;
                        gpu_active_x = 0;
                        gpu_active_y = gpu_param0;
                        gpu_xc = gpu_x;
                        gpu_yc = gpu_y;
                        gpu_numerator = 3 - ( 2 * gpu_param0 );
                        gpu_active = 6;
                    }
                    case 5: {
                        // Setup 1 bit 16x16 blitter starting at x,y in colour of tile param0
                        gpu_active_colour = gpu_colour;
                        gpu_active_x = 0;
                        gpu_active_y = 0;
                        gpu_x1 = gpu_x;
                        gpu_y1 = gpu_y;
                        gpu_w = 15;
                        gpu_h = 15;
                        gpu_tile = gpu_param0;                       
                        gpu_active = 14;
                    }
                    case 6: {
                        // Write to tilemap param0 line param1 value gpu_param2
                        // Done directly, does not activate the GPU
                        blit1tilemap.wenable1 = 1;
                    }
                    case 7: {
                        // Set the bitmap fade level
                        bitmapcolour_fade = gpu_param0;
                        bitmap_write = 2;
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
                bitmap_colour_write = gpu_active_colour;
                bitmap_write = 1;
                // Move to next pixel
                if( gpu_active_x == gpu_w ) {
                    // End of line
                    if( gpu_active_y == gpu_h ) {
                        // Reached bottom right
                        gpu_active = 0;
                    } else {
                        // Next line
                        gpu_active_y = gpu_active_y + 1;
                    }
                    gpu_active_x = gpu_x2;
                } else {
                    gpu_active_x = gpu_active_x + 1;
                }
            }
            case 2: {
                // Bresenham's Line Drawing Algorithm
                gpu_numerator = ( gpu_dx > gpu_dy ) ? ( gpu_dx >> 1) : -( gpu_dy >> 1);
                gpu_max_count = ( gpu_dx > gpu_dy ) ? gpu_dx : gpu_dy;
                gpu_active = 3;
            }
            case 3: {
                // Bresenham's Line Drawing Algorithm.
                // Draw the line
                bitmap_x_write = gpu_active_x;
                bitmap_y_write = gpu_active_y;
                bitmap_colour_write = gpu_active_colour;
                bitmap_write = 1;
                
                // Check if done
                if( gpu_count < gpu_max_count ) {
                    gpu_numerator2 = gpu_numerator;
                    gpu_active = 4;
                } else {
                    gpu_active = 0;
                }
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
                bitmap_colour_write = gpu_active_colour;
                bitmap_write = 1;
                gpu_active = 7;
            }
            case 7: {
                // Bresenham's Circle Drawing Algorithm - Arc 1
                bitmap_x_write = gpu_xc - gpu_active_x;
                bitmap_y_write = gpu_yc + gpu_active_y;
                bitmap_colour_write = gpu_active_colour;
                bitmap_write = 1;
                gpu_active = 8;
            }
            case 8: {
                // Bresenham's Circle Drawing Algorithm - Arc 2
                bitmap_x_write = gpu_xc + gpu_active_x;
                bitmap_y_write = gpu_yc - gpu_active_y;
                bitmap_colour_write = gpu_active_colour;
                bitmap_write = 1;
                gpu_active = 9;
            }
            case 9: {
                // Bresenham's Circle Drawing Algorithm - Arc 3
                bitmap_x_write = gpu_xc - gpu_active_x;
                bitmap_y_write = gpu_yc - gpu_active_y;
                bitmap_colour_write = gpu_active_colour;
                bitmap_write = 1;
                gpu_active = 10;
            }
            case 10: {
                // Bresenham's Circle Drawing Algorithm - Arc 4
                bitmap_x_write = gpu_xc + gpu_active_y;
                bitmap_y_write = gpu_yc + gpu_active_x;
                bitmap_colour_write = gpu_active_colour;
                bitmap_write = 1;
                gpu_active = 11;
            }
            case 11: {
                // Bresenham's Circle Drawing Algorithm - Arc 5
                bitmap_x_write = gpu_xc - gpu_active_y;
                bitmap_y_write = gpu_yc + gpu_active_x;
                bitmap_colour_write = gpu_active_colour;
                bitmap_write = 1;
                gpu_active = 12;
            }
            case 12: {
                // Bresenham's Circle Drawing Algorithm - Arc 6
                bitmap_x_write = gpu_xc + gpu_active_y;
                bitmap_y_write = gpu_yc - gpu_active_x;
                bitmap_colour_write = gpu_active_colour;
                bitmap_write = 1;
                gpu_active = 13;
            }
            case 13: {
                // Bresenham's Circle Drawing Algorithm - Arc 7
                bitmap_x_write = gpu_xc - gpu_active_y;
                bitmap_y_write = gpu_yc - gpu_active_x;
                bitmap_colour_write = gpu_active_colour;
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
                if( (( blit1tilemap.rdata0 << gpu_active_x ) >> 15) & 1 ) {
                    bitmap_x_write = gpu_x1 + gpu_active_x;
                    bitmap_y_write = gpu_y1 + gpu_active_y;
                    bitmap_colour_write = gpu_active_colour;
                    bitmap_write = 1;
                }
                if( gpu_active_x < gpu_w ) {
                    gpu_active_x = gpu_active_x + 1;
                } else {
                    gpu_active_x = 0;
                    // Move to next line and fetch line from blit 1 bit tile map
                    if( gpu_active_y < gpu_h ) {
                        gpu_active_y = gpu_active_y + 1;
                        gpu_active = 14;
                    } else {
                        // FINISHED
                        gpu_active = 0;
                    }
                }
            }
            default: {gpu_active = 0;}
        }
    }
}
