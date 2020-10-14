// NOT YET OPERATIONAL
bitfield vectorentry {
    uint1   active,
    uint1   dysign,
    uint5   dy,
    uint1   dxsign,
    uint5   dx
}

// Vector Block
// Stores blocks of upto 16 vertices which can be sent to the GPU for line drawing
// Each vertices represents a delta from the centre of the vector
// Deltas are stored as 6 bit 2's complement range -31 to 0 to 31
// Each vertices has an active flag, processing of a vector block stops when the active flag is 0
// Each vector block has a centre x and y coordinate and a colour { rrggbb }

algorithm vector_block(
    input   uint5   vector_block_number,
    input   uint1   draw_vector,

    // For setting vertices
    input   uint3   vertices_writer_block,
    input   uint6   vertices_writer_vertex,
    input   uint13  vertices_writer_activedeltas,  

    // Communication with the GPU
    output int11 gpu_x,
    output int11 gpu_y,
    output uint8 gpu_colour,
    output int16 gpu_param0,
    output int16 gpu_param1,
    output int16 gpu_param2,
    output int16 gpu_param3,
    output uint3 gpu_write,
    
    input  uint4 gpu_active
) <autorun> {
    // Storage for the vector block x and y coordinates and the colour
    // Stored as registers as needed instantly
    int11 vector_x[32] = uninitialised;
    int11 vector_y[32] = uninitialised;
    uint6 vector_colour[8] = uninitialised;

    // 32 vector blocks each of 16 vertices
    dualport_bram uint13 vertices[512] = uninitialised;    

    // Extract deltax and deltay for the present vertices
    int11 deltax := { {6{vectorentry(vertices.rdata0).dxsign}} , vectorentry(vertices.rdata0).dx };
    int11 deltay := { {6{vectorentry(vertices.rdata0).dysign}} , vectorentry(vertices.rdata0).dy };
    
    // Vertices being processed, plus starting coordinates
    uint4 vertices_number = 0;
    int11 start_x = 0;
    int11 start_y = 0;
    
    uint4 vector_block_active = 0;
    
    // Set read and write address for the vertices
    vertices.addr0 := vector_block_number * 16 + vertices_number;
    vertices.wenable0 := 0;
    vertices.addr1 := vertices_writer_block * 16 + vertices_writer_vertex;
    vertices.wdata1 := vertices_writer_activedeltas;
    vertices.wenable1 := 0;
    
    // Write vertices to the buffer
    always {
    }
    
    while(1) {
        if( draw_vector ) {
        }
        switch( vector_block_active ) {
            case 1: {
                // Read the first vertices
                start_x = vector_x[ vector_block_number ] + deltax;
                start_y = vector_y[ vector_block_number ] + deltay;
                vertices_number = 1;
                vector_block_active = 2;
            }
            case 2: {
                // See if the next vertices is active
                if( vectorentry(vertices.rdata0).active ) {
                    // Wait for GPU
                    if( gpu_active ) {
                        vector_block_active = 2;
                    } else {
                        vector_block_active = 3;
                    }
                } else {
                    // Finished
                    vertices_number = 0;
                    vector_block_active = 0;
                }
            }
            case 3: {
                // Send the line to the GPU
                gpu_x = start_x;
                gpu_y = start_y;
                gpu_colour = vector_colour[ vector_block_number ];
                gpu_param0 = vector_x[ vector_block_number ] + deltax;
                gpu_param1 = vector_y[ vector_block_number ] + deltay;
                gpu_write = 2;
                // Move onto the next vertices
                start_x = vector_x[ vector_block_number ] + deltax;
                start_y = vector_y[ vector_block_number ] + deltay;
                if( vertices_number < 15 ) {
                    vertices_number = vertices_number + 1;
                    vector_block_active = 2;
                } else {
                    vertices_number = 0;
                    vector_block_active = 0;
                }
            }
            default: {
                vertices_number = 0;
                vector_block_active = 0;
            }
        }
    }
}

 
