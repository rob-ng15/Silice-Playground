// From recursive Verilog module
// https://electronics.stackexchange.com/questions/196914/verilog-synthesize-high-speed-leading-zero-count

// Create a LUA pre-processor function that recursively writes
// circuitries counting the number of leading zeros in variables
// of decreasing width.
// Note: this could also be made in-place without wrapping in a
// circuitry, directly outputting a hierarchical set of trackers (<:)
$$function generate_clz(name,w_in,recurse)
$$ local w_out = clog2(w_in)
$$ local w_h   = w_in//2
$$ if w_in > 2 then generate_clz(name,w_in//2,1) end
circuitry $name$_$w_in$ (input in,output out)
{
$$ if w_in == 2 then
   out = !in[1,1];
$$ else
   uint$clog2(w_in)-1$ half_count = uninitialized;
   uint$w_h$           lhs        <: in[$w_h$,$w_h$];
   uint$w_h$           rhs        <: in[    0,$w_h$];
   uint$w_h$           select     <: left_empty ? rhs : lhs;
   uint1               left_empty <: ~|lhs;
   (half_count) = $name$_$w_h$(select);
   out          = {left_empty,half_count};
$$ end
}
$$end

$$function generate_ctz(name,w_in,recurse)
$$ local w_out = clog2(w_in)
$$ local w_h   = w_in//2
$$ if w_in > 2 then generate_ctz(name,w_in//2,1) end
circuitry $name$_$w_in$ (input in,output out)
{
$$ if w_in == 2 then
   out = !in[0,1];
$$ else
   uint$clog2(w_in)-1$ half_count = uninitialized;
   uint$w_h$           lhs        <: in[$w_h$,$w_h$];
   uint$w_h$           rhs        <: in[    0,$w_h$];
   uint$w_h$           select     <: right_empty ? lhs : rhs;
   uint1               right_empty <: ~|rhs;
   (half_count) = $name$_$w_h$(select);
   out          = {right_empty,half_count};
$$ end
}
$$end

$$function generate_cpop(name,w_in,recurse)
$$ local w_out = clog2(w_in)
$$ local w_h   = w_in//2
$$ if w_in > 2 then generate_cpop(name,w_in//2,1) end
circuitry $name$_$w_in$ (input in,output out)
{
$$ if w_in == 2 then
   out = in[0,1] + in[1,1];
$$ else
   uint$clog2(w_in)$   left_count = uninitialized;
   uint$clog2(w_in)$   right_count = uninitialized;
   uint$w_h$           lhs        <: in[$w_h$,$w_h$];
   uint$w_h$           rhs        <: in[    0,$w_h$];
   (left_count) = $name$_$w_h$(lhs);
   (right_count) = $name$_$w_h$(rhs);
   out          = left_count + right_count;
$$ end
}
$$end

// Produce circuits for 32 bits numbers
$$generate_clz('clz_silice',32)
$$generate_ctz('ctz_silice',32)
$$generate_cpop('cpop_silice',32)

// Test it (make verilator)
algorithm main(output uint8 leds)
{
  uint32 test(32hffffffff);
  uint2  test2(2b01);
  uint6  cnt = uninitialized;

  (cnt)      = clz_silice_32(test);
  __display("clz %b -> %d",test,cnt);
  (cnt)      = clz_silice_2(test2);
  __display("clz %b -> %d",test2,cnt);

  (cnt)      = ctz_silice_32(test);
  __display("ctz %b -> %d",test,cnt);
  (cnt)      = ctz_silice_2(test2);
  __display("ctz %b -> %d",test2,cnt);

  (cnt)      = cpop_silice_32(test);
  __display("cpop %b -> %d",test,cnt);
  (cnt)      = cpop_silice_2(test2);
  __display("cpop %b -> %d",test2,cnt);

}

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}
