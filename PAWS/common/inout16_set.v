module inout16_set(     
  inout  [15:0] io_pin,
  input  [15:0] io_write,
  output [15:0] io_read,
  input         io_write_enable,
  input         clock
);

`ifdef DE10NANO

  //altiobuf_bidir #(
  //   .number_of_channels(16),
  //   .enable_bus_hold("FALSE")
  // ) iobuf(.datain(io_write), .dataout(io_read), .dataio(io_pin), .oe({16{io_write_enable}}));

`else

  reg [15:0] ff_read;
  reg [15:0] ff_write;

  always @(posedge clock) begin
    ff_read  <= io_pin;
    ff_write <= io_write;
  end

  assign io_pin  = io_write_enable ? ff_write : 16'hZZ;
  assign io_read = ff_read; 
  
`endif

endmodule
