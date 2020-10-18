algorithm gpu(
    // GPU to SET and GET pixels
    output! int11 bitmap_x_write,
    output! int11 bitmap_y_write,
    output! uint7 bitmap_colour_write,
    output! uint2 bitmap_write,
    output! uint3 bitmapcolour_fade,

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
    input   uint4 v_gpu_write,

    // From DISPLAY LIST DRAWER
    input   int11 dl_gpu_x,
    input   int11 dl_gpu_y,
    input   uint8 dl_gpu_colour,
    input   int16 dl_gpu_param0,
    input   int16 dl_gpu_param1,
    input   uint4 dl_gpu_write,

    output  uint4 gpu_active
) <autorun> {
    // 256 x 16 x 16 1 bit tilemap for blit1tilemap
    dualport_bram uint16 blit1tilemap[ 4096 ] = uninitialized;
    
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
    int11 gpu_numerator = uninitialized;
    int11 gpu_numerator2 = uninitialized;
    //int11 gpu_radius = uninitialized;
    int11 gpu_count = uninitialized;
    int11 gpu_max_count = uninitialized;
    uint8 gpu_tile = uninitialized;

    // blit1tilemap read access for the blit1tilemap
    blit1tilemap.addr0 := gpu_tile * 16 + gpu_active_y;
    blit1tilemap.wenable0 := 0;
        
    // blit1tilemap write access for the GPU to load tilemaps
    blit1tilemap.addr1 := gpu_param0 * 16 + gpu_param1;
    blit1tilemap.wdata1 := gpu_param2;
    blit1tilemap.wenable1 := 0;

    bitmap_write := 0;
    
    always {
        gpu_active_colour = ( gpu_write > 0 ) ? gpu_colour : ( v_gpu_write > 0 ) ? v_gpu_colour : ( dl_gpu_write > 0 ) ? dl_gpu_colour : gpu_active_colour;
    }
    
    while(1) {
        switch( gpu_active ) {
            // GPU Inactive, allow a new operation to start
            case 0: {
                // Start the GPU from j1eforth
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
                        gpu_active_x = ( gpu_x < gpu_param0 ) ? ( gpu_x < 0 ? 0 : gpu_x ) : ( gpu_param0 < 0 ? 0 : gpu_param0 );                // left
                        gpu_active_y = ( gpu_y < gpu_param1 ) ? ( gpu_y < 0 ? 0 : gpu_y ) : ( gpu_param1 < 0 ? 0 : gpu_param1 );                 // top
                        gpu_x2 = ( gpu_x < gpu_param0 ) ? ( gpu_x < 0 ? 0 : gpu_x )  : ( gpu_param0 < 0 ? 0 : gpu_param0 );                       // left - for next line
                        gpu_x1 = ( gpu_x < gpu_param0 ) ? ( gpu_param0 > 639 ? 639 : gpu_param0 ) : ( gpu_x > 639 ? 639 : gpu_x );                        // right - at end of line
                        gpu_y1 = ( gpu_y < gpu_param1 ) ? ( gpu_param1 > 479 ? 479 : gpu_param1 ) : ( gpu_y > 479 ? 479 : gpu_y );                        // bottom - at end of rectangle
                        gpu_active = 1; 
                    }
                    case 3: {
                        // Setup drawing a line from x,y to param0,param1 in colour
                        // Ensure LEFT to RIGHT
                        gpu_active_x = ( gpu_x < gpu_param0 ) ? gpu_x : gpu_param0;
                        gpu_active_y = ( gpu_x < gpu_param0 ) ? gpu_y : gpu_param1;
                        // Absolute DELTAs
                        gpu_dx = ( gpu_param0 < gpu_x ) ? gpu_x - gpu_param0 : gpu_param0 - gpu_x;
                        gpu_dy = ( gpu_param1 < gpu_y )? gpu_y - gpu_param1 : gpu_param1 - gpu_y;
                        // Shift X is always POSITIVE
                        gpu_sx = 1;
                        // Shift Y is NEGATIVE or POSITIVE
                        gpu_sy = ( gpu_x < gpu_param0 ) ? ( gpu_y < gpu_param1 ) ? 1 : -1 : ( gpu_y < gpu_param1 ) ? -1 : 1;
                        gpu_count = 0;
                        gpu_active = 2; 
                    }
                    case 4: {
                        // Setup drawing a circle centre x,y or radius param0 in colour
                        gpu_active_x = 0;
                        gpu_active_y = gpu_param0;
                        gpu_xc = gpu_x;
                        gpu_yc = gpu_y;
                        gpu_numerator = 3 - ( 2 * gpu_param0 );
                        gpu_active = 6;
                    }
                    case 5: {
                        // Setup 1 bit 16x16 blitter starting at x,y in colour of tile param0
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
                
                // Start the GPU from the VECTOR DRAWER
                switch( v_gpu_write ) {
                    case 3: {
                        // Setup drawing a line from x,y to param0,param1 in colour
                        // Ensure LEFT to RIGHT
                        gpu_active_x = ( v_gpu_x < v_gpu_param0 ) ? v_gpu_x : v_gpu_param0;
                        gpu_active_y = ( v_gpu_x < v_gpu_param0 ) ? v_gpu_y : v_gpu_param1;
                        // Absolute DELTAs
                        gpu_dx = ( v_gpu_param0 < v_gpu_x ) ? v_gpu_x - v_gpu_param0 : v_gpu_param0 - v_gpu_x;
                        gpu_dy = ( v_gpu_param1 < v_gpu_y )? v_gpu_y - v_gpu_param1 : v_gpu_param1 - v_gpu_y;
                        // Shift X is always POSITIVE
                        gpu_sx = 1;
                        // Shift Y is NEGATIVE or POSITIVE
                        gpu_sy = ( v_gpu_x < v_gpu_param0 ) ? ( v_gpu_y < v_gpu_param1 ) ? 1 : -1 : ( v_gpu_y < v_gpu_param1 ) ? -1 : 1;
                        gpu_count = 0;
                        gpu_active = 2; 
                    }
                    default: {}
                }
                
                // Start the GPU from the DISPLAY LIST DRAWER
                switch( dl_gpu_write ) {
                    case 1: {
                        // Setup writing a pixel colour to x,y 
                        // Done directly, does not activate the GPU
                        bitmap_x_write = dl_gpu_x;
                        bitmap_y_write = dl_gpu_y;
                        bitmap_colour_write = dl_gpu_colour;
                        bitmap_write = 1;
                    }
                    case 2: {
                        // Setup drawing a rectangle from x,y to param0,param1 in colour
                        // Ensures that works left to right, top to bottom
                        // Cut out pixels out of 0 <= x <= 639 , 0 <= y <= 479
                        gpu_active_x = ( dl_gpu_x < dl_gpu_param0 ) ? ( dl_gpu_x < 0 ? 0 : dl_gpu_x ) : ( dl_gpu_param0 < 0 ? 0 : dl_gpu_param0 );       // left
                        gpu_active_y = ( dl_gpu_y < dl_gpu_param1 ) ? ( dl_gpu_y < 0 ? 0 : dl_gpu_y ) : ( dl_gpu_param1 < 0 ? 0 : dl_gpu_param1 );       // top
                        gpu_x2 = ( dl_gpu_x < dl_gpu_param0 ) ? ( dl_gpu_x < 0 ? 0 : dl_gpu_x )  : ( dl_gpu_param0 < 0 ? 0 : dl_gpu_param0 );            // left - for next line
                        gpu_x1 = ( dl_gpu_x < dl_gpu_param0 ) ? ( dl_gpu_param0 > 639 ? 639 : dl_gpu_param0 ) : ( dl_gpu_x > 639 ? 639 : dl_gpu_x );     // right - at end of line
                        gpu_y1 = ( dl_gpu_y < dl_gpu_param1 ) ? ( dl_gpu_param1 > 479 ? 479 : dl_gpu_param1 ) : ( dl_gpu_y > 479 ? 479 : dl_gpu_y );     // bottom - at end of rectangle
                        gpu_active = 1; 
                    }
                    case 3: {
                        // Setup drawing a line from x,y to param0,param1 in colour
                        // Ensure LEFT to RIGHT
                        gpu_active_x = ( dl_gpu_x < dl_gpu_param0 ) ? dl_gpu_x : dl_gpu_param0;
                        gpu_active_y = ( dl_gpu_x < dl_gpu_param0 ) ? dl_gpu_y : dl_gpu_param1;
                        // Absolute DELTAs
                        gpu_dx = ( dl_gpu_param0 < dl_gpu_x ) ? dl_gpu_x - dl_gpu_param0 : dl_gpu_param0 - dl_gpu_x;
                        gpu_dy = ( dl_gpu_param1 < dl_gpu_y ) ? dl_gpu_y - dl_gpu_param1 : dl_gpu_param1 - dl_gpu_y;
                        // Shift X is always POSITIVE
                        gpu_sx = 1;
                        // Shift Y is NEGATIVE or POSITIVE
                        gpu_sy = ( dl_gpu_x < dl_gpu_param0 ) ? ( dl_gpu_y < dl_gpu_param1 ) ? 1 : -1 : ( dl_gpu_y < dl_gpu_param1 ) ? -1 : 1;
                        gpu_count = 0;
                        gpu_active = 2; 
                    }
                    case 4: {
                        // Setup drawing a circle centre x,y or radius param0 in colour
                        gpu_active_x = 0;
                        gpu_active_y = dl_gpu_param0;
                        gpu_xc = dl_gpu_x;
                        gpu_yc = dl_gpu_y;
                        gpu_numerator = 3 - ( 2 * dl_gpu_param0 );
                        gpu_active = 6;
                    }
                    case 5: {
                        // Setup 1 bit 16x16 blitter starting at x,y in colour of tile param0
                        gpu_active_x = 0;
                        gpu_active_y = 0;
                        gpu_x1 = dl_gpu_x;
                        gpu_y1 = dl_gpu_y;
                        gpu_w = 15;
                        gpu_h = 15;
                        gpu_tile = dl_gpu_param0;                       
                        gpu_active = 14;
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
                gpu_active = ( ( gpu_active_x == gpu_x1) & ( gpu_active_y == gpu_y1 ) ) ? 0 : 1;
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
                bitmap_colour_write = gpu_active_colour;
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
                if( blit1tilemap.rdata0[15 -gpu_active_x,1] ) {
                    bitmap_x_write = gpu_x1 + gpu_active_x;
                    bitmap_y_write = gpu_y1 + gpu_active_y;
                    bitmap_colour_write = gpu_active_colour;
                    bitmap_write = 1;
                }
                gpu_active = ( gpu_active_y < gpu_h ) ? 14 : ( gpu_active_x < gpu_w ) ? 14 : 0;
                gpu_active_x = ( gpu_active_x < gpu_w ) ? gpu_active_x + 1 : 0;
                gpu_active_y = ( gpu_active_x < gpu_w ) ? gpu_active_y : gpu_active_y + 1;
            }
            default: {gpu_active = 0;}
        }
    }
}
