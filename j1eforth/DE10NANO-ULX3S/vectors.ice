// Vector Block
// Stores blocks of upto 16 vertices which can be sent to the GPU for line drawing
// Each vertices represents a delta from the centre of the vector
// Deltas are stored as 6 bit 2's complement range -31 to 0 to 31
// Each vertices has an active flag, processing of a vector block stops when the active flag is 0
// Each vector block has a centre x and y coordinate and a colour { rrggbb } when drawn

algorithm vectors(
    input   uint5   vector_block_number,
    input   uint7   vector_block_colour,
    input   int11   vector_block_xc,
    input   int11   vector_block_yc,
    
    input   uint1   draw_vector,

    // For setting vertices
    input   uint5   vertices_writer_block,
    input   uint6   vertices_writer_vertex,
    input   int6    vertices_writer_xdelta,  
    input   int6    vertices_writer_ydelta,
    input   uint1   vertices_writer_active,
    input   uint1   vertices_writer_write,
    
    output  uint3   vector_block_active,
    
    // Communication with the GPU via j1eforth always{} block
    output  int11 gpu_x,
    output  int11 gpu_y,
    output  uint7 gpu_colour,
    output  int11 gpu_param0,
    output  int11 gpu_param1,
    output  uint4 gpu_write,
    
    input  uint4 gpu_active
) <autorun> {
    // 32 vector blocks each of 16 vertices
    dualport_bram uint1 A[512] = uninitialised;    
    dualport_bram int6 dy[512] = uninitialised;    
    dualport_bram int6 dx[512] = uninitialised;    

    // Extract deltax and deltay for the present vertices
    int11 deltax := { {6{dx.rdata0[5,1]}}, dx.rdata0[0,5] };
    int11 deltay := { {6{dy.rdata0[5,1]}}, dy.rdata0[0,5]  };
    
    // Vertices being processed, plus starting coordinates
    uint4 vertices_number = 0;
    int11 start_x = 0;
    int11 start_y = 0;
    
    // Set read and write address for the vertices
    A.addr0 := vector_block_number * 16 + vertices_number;
    A.wenable0 := 0;
    A.addr1 := vertices_writer_block * 16 + vertices_writer_vertex;
    A.wdata1 := vertices_writer_active;
    A.wenable1 := vertices_writer_write;
    
    dx.addr0 := vector_block_number * 16 + vertices_number;
    dx.wenable0 := 0;
    dx.addr1 := vertices_writer_block * 16 + vertices_writer_vertex;
    dx.wdata1 := vertices_writer_xdelta;
    dx.wenable1 := vertices_writer_write;
    
    dy.addr0 := vector_block_number * 16 + vertices_number;
    dy.wenable0 := 0;
    dy.addr1 := vertices_writer_block * 16 + vertices_writer_vertex;
    dy.wdata1 := vertices_writer_ydelta;
    dy.wenable1 := vertices_writer_write;

    gpu_write := 0;

    always {
        if( draw_vector ) {
            vector_block_active = 1;
        }
    }
    
    vector_block_active = 0;
    vertices_number = 0;
    
    while(1) {
        switch( vector_block_active ) {
            case 1: {
                // Delay to allow reading of the first vertex
                vector_block_active = 2;
            }
            case 2: {
                // Read the first of the vertices
                start_x = vector_block_xc + deltax;
                start_y = vector_block_yc + deltay;
                vertices_number = 1;
                vector_block_active = 3;
            }
            case 3: {
                // Delay to allow reading of the next vertices
                vector_block_active = 4;
            }
            case 4: {
                // See if the next of the vertices is active and await the GPU
                vector_block_active = ( A.rdata0 ) ? ( gpu_active ) ? 4 : 5 : 0;
                vertices_number = ( A.rdata0 ) ? vertices_number : 0;
            }
            case 5: {
                // Send the line to the GPU
                gpu_x = start_x;
                gpu_y = start_y;
                gpu_colour = vector_block_colour;
                gpu_param0 = vector_block_xc + deltax;
                gpu_param1 = vector_block_yc + deltay;
                gpu_write = 3;
                
                // Move onto the next of the vertices
                start_x = vector_block_xc + deltax;
                start_y = vector_block_yc + deltay;
                vertices_number = ( vertices_number < 15 ) ? vertices_number + 1 : 0;
                vector_block_active = ( vertices_number < 15 ) ? 3 : 0;
            }
            default: {
                vertices_number = 0;
                vector_block_active = 0;
            }
        }
    }
}

 
