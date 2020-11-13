// Vector Block
// Stores blocks of upto 16 vertices which can be sent to the GPU for line drawing
// Each vertices represents a delta from the centre of the vector
// Deltas are stored as 6 bit 2's complement range -31 to 0 to 31
// Each vertices has an active flag, processing of a vector block stops when the active flag is 0
// Each vector block has a centre x and y coordinate and a colour { rrggbb } when drawn

bitfield vectorentry {
    uint1   active,
    uint1   dxsign,
    uint5   dx,
    uint1   dysign,
    uint5   dy
}

algorithm vectors(
    input   uint4   vector_block_number,
    input   uint7   vector_block_colour,
    input   int11   vector_block_xc,
    input   int11   vector_block_yc,

    input   uint1   draw_vector,

    // For setting vertices
    input   uint4   vertices_writer_block,
    input   uint6   vertices_writer_vertex,
    input   int6    vertices_writer_xdelta,
    input   int6    vertices_writer_ydelta,
    input   uint1   vertices_writer_active,
    input   uint1   vertices_writer_write,

    output!  uint1   vector_block_active,

    // Communication with the GPU
    output  int11 gpu_x,
    output  int11 gpu_y,
    output  uint7 gpu_colour,
    output  int11 gpu_param0,
    output  int11 gpu_param1,
    output  uint4 gpu_write,

    input  uint1 gpu_active
) <autorun> {
    // 16 vector blocks each of 16 vertices
    dualport_bram uint13 vertex[256] = uninitialised;

    // Extract deltax and deltay for the present vertices
    int11 deltax := { {6{vectorentry(vertex.rdata0).dxsign}}, vectorentry(vertex.rdata0).dx };
    int11 deltay := { {6{vectorentry(vertex.rdata0).dysign}}, vectorentry(vertex.rdata0).dy };

    // Vertices being processed, plus first coordinate of each line
    uint5 block_number = uninitialised;
    uint5 vertices_number = uninitialised;
    int11 start_x = uninitialised;
    int11 start_y = uninitialised;

    // Set read and write address for the vertices
    vertex.addr0 := block_number * 16 + vertices_number;
    vertex.wenable0 := 0;
    vertex.wenable1 := 1;

    gpu_write := 0;

    vector_block_active = 0;
    vertices_number = 0;

    while(1) {
        if( vertices_writer_write ) {
            vertex.addr1 = vertices_writer_block * 16 + vertices_writer_vertex;
            vertex.wdata1 = { vertices_writer_active, vertices_writer_xdelta, vertices_writer_ydelta };
        }

        if( draw_vector ) {
            block_number = vector_block_number;
            gpu_colour = vector_block_colour;

            vertices_number = 0;

            vector_block_active = 1;

            ++:

            start_x = vector_block_xc + deltax;
            start_y = vector_block_yc + deltay;

            vertices_number = 1;

            ++:

            while( vectorentry(vertex.rdata0).active && ( vertices_number < 16 ) ) {
                gpu_x = start_x;
                gpu_y = start_y;
                gpu_param0 = vector_block_xc + deltax;
                gpu_param1 = vector_block_yc + deltay;

                while( gpu_active ) {}

                gpu_write = 3;

                // Move onto the next of the vertices
                start_x = vector_block_xc + deltax;
                start_y = vector_block_yc + deltay;
                vertices_number = vertices_number + 1;
                ++:
            }

            vector_block_active = 0;
        }
    }
}


