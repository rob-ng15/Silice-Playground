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
algorithm $name$_$w_in$ (
    input   uint$w_in$ in,
    output! uint$clog2(w_in)$ out) <autorun>
{
$$ if w_in == 2 then
   out = ~in[1,1];
$$ else
   uint$clog2(w_in)$   half_count = uninitialized;
   uint$w_h$           lhs        <: in[$w_h$,$w_h$];
   uint$w_h$           rhs        <: in[    0,$w_h$];
   uint$w_h$           select     <: left_empty ? rhs : lhs;
   uint1               left_empty <: ~|lhs;
   clz_silice_$w_h$ cz_half( in <: select, out :> half_count );
   out          := {left_empty,half_count};
$$ end
}
$$end

// Produce a circuit for 32 bits numbers
$$generate_clz('clz_silice',32)

// Test it (make verilator)
algorithm main(output uint8 leds)
{
  uint32 test(32b00000000000000000000000001001101);
  uint6  cnt = uninitialized;
  clz_silice_32 CZ32( in <: test, out :> cnt );
  __display("%b = %d",test, cnt);
}
