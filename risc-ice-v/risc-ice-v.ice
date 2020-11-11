// SL 2020-06-12 @sylefeb
//
// Fun with RISC-V!
// Given a DISPLAY and UART
//
// (can be further reduced!)
//
// RV32I cpu, see README.txt
//
//      GNU AFFERO GENERAL PUBLIC LICENSE
//        Version 3, 19 November 2007
//
//  A copy of the license full text is included in
//  the distribution, please refer to it for details.

// --------------------------------------------------
// pre-compilation script, embeds compile code within BRAM
$$dofile('pre_include_asm.lua')

// bitfields for easier decoding of instructions ; these
// define views on a uint32, that are used upon
// access, avoiding hard coded values in part-selects
bitfield Itype {
  uint12 imm,
  uint5  rs1,
  uint3  funct3,
  uint5  rd,
  uint7  opcode
}

bitfield Stype {
  uint7  imm11_5,
  uint5  rs2,
  uint5  rs1,
  uint3  funct3,
  uint5  imm4_0,
  uint7  opcode
}

bitfield Rtype {
  uint1  unused_2,
  uint1  select2,
  uint5  unused_1,
  uint5  rs2,
  uint5  rs1,
  uint3  funct3,
  uint5  rd,
  uint7  opcode
}

bitfield Utype {
  uint20  imm31_12,
  uint12  zero
}

bitfield Jtype {
  uint1  imm20,
  uint10 imm10_1,
  uint1  imm11,
  uint8  imm_19_12,
  uint5  rd,
  uint7  opcode
}

bitfield Btype {
  uint1  imm12,
  uint6  imm10_5,
  uint5  rs2,
  uint5  rs1,
  uint3  funct3,
  uint4  imm4_1,
  uint1  imm11,
  uint7  opcode
}

algorithm main(
    // LEDS (8 of)
    output  uint8   leds,
    input   uint$NUM_BTNS$ btns,

$$if ULX3S then
    output  uint4   gpdi_dp,
    output  uint4   gpdi_dn,
$$end
$$if DE10NANO then
    // VGA
    output! uint6   video_r,
    output! uint6   video_g,
    output! uint6   video_b,
    output! uint1   video_hs,
    output! uint1   video_vs,
$$end

    // UART
    output! uint1   uart_tx,
    input   uint1   uart_rx,

    // AUDIO
    output! uint4   audio_l,
    output! uint4   audio_r

)
$$if ULX3S then
<@clock_50mhz>
$$end
{
    // VGA/HDMI Display
    uint1   video_reset = uninitialized;
    uint1   video_clock = uninitialized;
    uint1   pll_lock = uninitialized;

    // Generate the 100MHz SDRAM and 25MHz VIDEO clocks
$$if DE10NANO then
    uint1 sdram_clock = uninitialized;
    uint1 clock_50mhz = uninitialized;

    de10nano_clk_100_25 clk_gen (
        refclk    <: clock,
        outclk_0  :> sdram_clock,
        outclk_1  :> video_clock,
        locked    :> pll_lock,
        rst       <: reset
    );
$$end
$$if ULX3S then
    uint1 clock_50mhz = uninitialized;
    ulx3s_clk_50_25 clk_gen (
        clkin    <: clock,
        clkout0  :> clock_50mhz,
        clkout1  :> video_clock,
        locked   :> pll_lock
    );
$$end

    // Video Reset
    reset_conditioner vga_rstcond (
        rcclk <: video_clock ,
        in  <: reset,
        out :> video_reset
    );

    // Status of the screen, if in range, if in vblank, actual pixel x and y
    uint1   vblank = uninitialized;
    uint1   pix_active = uninitialized;
    uint10  pix_x  = uninitialized;
    uint10  pix_y  = uninitialized;

    // VGA or HDMI driver
$$if DE10NANO then
    vga vga_driver <@video_clock,!video_reset> (
        vga_hs :> video_hs,
        vga_vs :> video_vs,
        vblank :> vblank,
        active :> pix_active,
        vga_x  :> pix_x,
        vga_y  :> pix_y
    );
$$end

$$if ULX3S then
    uint8   video_r = uninitialized;
    uint8   video_g = uninitialized;
    uint8   video_b = uninitialized;

    hdmi video<@clock,!reset> (
        vblank  :> vblank,
        active  :> pix_active,
        x       :> pix_x,
        y       :> pix_y,
        gpdi_dp :> gpdi_dp,
        gpdi_dn :> gpdi_dn,
        red     <: video_r,
        green   <: video_g,
        blue    <: video_b
    );
$$end

    // Setup Memory Mapped I/O
    memmap_io IO_Map
$$if ULX3S then
<@clock_50mhz,!reset>
$$end
    (
        leds :> leds,
        btns <: btns,

        // UART
        uart_tx :> uart_tx,
        uart_rx <: uart_rx,

        // AUDIO
        audio_l :> audio_l,
        audio_r :> audio_r,

        // VGA/HDMI
        video_r :> video_r,
        video_g :> video_g,
        video_b :> video_b,
        vblank <: vblank,
        pix_active <: pix_active,
        pix_x <: pix_x,
        pix_y <: pix_y,

        // CLOCKS
        clock_50mhz <: clock_50mhz,
        video_clock <:video_clock,
        video_reset <: video_reset,

        // Memory Address/Data
        //memoryAddress <: stackTop,
        //writeData <: stackNext
    );

    // ram
    bram uint32 mem<input!>[8192] = {
        $include('ROM/BIOS.inc')
        , pad(uninitialized)
    };

    uint11  wide_addr = uninitialized;
    uint1   icememoryWrite = uninitialized;
    uint1   icememoryRead = uninitialized;
    uint32  icememoryWriteData = uninitialized;
    uint32  icememoryReadData = uninitialized;

    // cpu
    rv32i_cpu cpu(
        mem_addr  :> wide_addr,
        mem_rdata <: icememoryReadData,
        mem_wdata :> icememoryWriteData,
        mem_wen   :> icememoryWrite,
        mem_ren   :> icememoryRead,
    );

    // Memory Read / Write Flags
    // Latch lower 10 bits of the memory address
    mem.addr := wide_addr[0,10];
    mem.wdata := icememoryWriteData;
    mem.wenable := icememoryWrite && ( wide_addr[10,1] == 0);

    // IO Map Read / Write Flags
    IO_Map.writeData := icememoryWriteData;
    IO_Map.memoryWrite := icememoryWrite && wide_addr[10,1];
    IO_Map.memoryRead := icememoryRead && wide_addr[10,1];

    $$if DE10NANO then
        // 50MHz clock specifically named for de10nano
        clock_50mhz := clock;
    $$end

    // Select memory read or i/o read
    always {
        switch( wide_addr[10,1] ) {
            case 1b0: { icememoryReadData = mem.rdata; }
            case 1b1: { icememoryReadData = IO_Map.readData; }
        }
    }

    // run the CPU
    () <- cpu <- ();

    while(1) {
    }
}

// --------------------------------------------------
// The Risc-V RV32I CPU itself

algorithm rv32i_cpu(
  output! uint12 mem_addr,
  input   uint32 mem_rdata,
  output! uint32 mem_wdata,
  output! uint1  mem_wen,
  output! uint1  mem_ren,
) <onehot> {

  //                 |--------- indicates we don't want the bram inputs to be latched
  //                 v          writes have to be setup during the same clock cycle
  bram int32 xregsA<input!>[32] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
  bram int32 xregsB<input!>[32] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

  uint1  cmp         = uninitialized;

  uint5  write_rd    = uninitialized;
  uint1  jump        = uninitialized;
  uint1  branch      = uninitialized;

  uint1  load_store  = uninitialized;
  uint1  store       = uninitialized;

  uint3 select       = uninitialized;
  uint1 select2      = uninitialized;

  uint32 instr       = uninitialized;
  uint12 pc          = uninitialized;

  uint12 next_pc   ::= pc+1; // next_pc tracks the expression 'pc + 1' using the
                             // value of pc from the last clock edge (due to ::)

  uint3 funct3    := Btype(instr).funct3;

  int32  alu_out     = uninitialized;
  uint1  alu_working = uninitialized;
  uint1  alu_enable  = uninitialized;
  intops alu(
    enable  <: alu_enable,
    pc      <: pc,
    xa      <: xregsA.rdata,
    xb      <: xregsB.rdata,
    imm     <: imm,
    forceZero   <: forceZero,
    regOrPc     <: regOrPc,
    regOrImm    <: regOrImm,
    r       :> alu_out,
    select  <: select,
    select2 <: select2,
    working :> alu_working
  );

  int32 imm         = uninitialized;
  uint1 forceZero   = uninitialized;
  uint1 regOrPc     = uninitialized;
  uint1 regOrImm    = uninitialized;
  uint3 loadStoreOp = uninitialized;
  decode dec(
    instr       <:: instr,    // the <:: indicates we bind the variable as it was at the last
    write_rd    :> write_rd,  // clock edge (as opposed to its value being modified in this cycle)
    jump        :> jump,
    branch      :> branch,
    load_store  :> load_store,
    store       :> store,
    loadStoreOp :> loadStoreOp,
    select      :> select,
    select2     :> select2,
    imm         :> imm,
    forceZero   :> forceZero,
    regOrPc     :> regOrPc,
    regOrImm    :> regOrImm
  );

 intcmp cmps(
    a      <: xregsA.rdata,
    b      <: xregsB.rdata,
    select <: funct3,
    enable <: branch,
    j      :> cmp
  );

  // maintain write/read enable low (pulses high when needed)
  mem_wen        := 0;
  mem_ren       := 0;
  // maintain alu enable low (pulses high when needed)
  alu_enable     := 0;
  // maintain read registers (no latched, see bram parameter)
  xregsA.wenable := 0;
  xregsB.wenable := 0;
  xregsA.addr    := Rtype(instr).rs1;
  xregsB.addr    := Rtype(instr).rs2;

  // boot at 0x00
  mem_addr        = 0;
  mem_ren         = 1;
// __display("pc %d",mem_addr);

    // mem_data is now available
    instr = mem_rdata;
    pc    = mem_addr;
    // update register immediately
    xregsA.addr = Rtype(instr).rs1;
    xregsB.addr = Rtype(instr).rs2;

++: // decode

    // decode is now available, ALU is running
    alu_enable = 1;

    while (1) {

        // load/store?
        // What happens here: we always load, and mask and store on SB,SH,SW.
        // the reason being that the BRAM design currently does not support
        // write masks (likely to evolve, but have to worry about compatibility
        // across architectures).
        if (load_store) {
          // load data (NOTE: could skip if followed by SW)
          mem_addr    = alu_out>>2;
          mem_ren     = 1;
++: // wait data
          if (~store) {
            uint32 tmp = uninitialized;
            switch ( loadStoreOp[0,2] ) {
              case 2b00: { // LB / LBU
                  switch (alu_out[0,2]) {
                    case 2b00: { tmp = { {24{loadStoreOp[2,1]&mem_rdata[ 7,1]}},mem_rdata[ 0,8]}; }
                    case 2b01: { tmp = { {24{loadStoreOp[2,1]&mem_rdata[15,1]}},mem_rdata[ 8,8]}; }
                    case 2b10: { tmp = { {24{loadStoreOp[2,1]&mem_rdata[23,1]}},mem_rdata[16,8]}; }
                    case 2b11: { tmp = { {24{loadStoreOp[2,1]&mem_rdata[31,1]}},mem_rdata[24,8]}; }
                    default:   { tmp = 0; }
                  }
              }
              case 2b01: { // LH / LHU
                  switch (alu_out[1,1]) {
                    case 1b0: { tmp = { {16{loadStoreOp[2,1]&mem_rdata[15,1]}},mem_rdata[ 0,16]}; }
                    case 1b1: { tmp = { {16{loadStoreOp[2,1]&mem_rdata[31,1]}},mem_rdata[16,16]}; }
                    default:  { tmp = 0; }
                  }
              }
              case 2b10: { // LW
                tmp = mem_rdata;
              }
              default: { tmp = 0; }
            }
//__display("LOAD addr: %h (%b) op: %b read: %h / %h", mem_addr, alu_out, loadStoreOp, mem_rdata, tmp);
            // commit result
            xregsA.wenable = 1;
            xregsB.wenable = 1;
            xregsA.wdata   = tmp;
            xregsB.wdata   = tmp;
            xregsA.addr    = write_rd;
            xregsB.addr    = write_rd;

          } else {

//__display("STORE1 addr: %h (%b) op: %b d: %h",mem_addr,alu_out,loadStoreOp,mem_rdata);
            switch (loadStoreOp) {
              case 3b000: { // SB
                  switch (alu_out[0,2]) {
                    case 2b00: { mem_wdata = { mem_rdata[ 8,24] , xregsB.rdata[ 0,8] };              }
                    case 2b01: { mem_wdata = { mem_rdata[16,16] , xregsB.rdata[ 0,8] , mem_rdata[0, 8] }; }
                    case 2b10: { mem_wdata = { mem_rdata[24, 8] , xregsB.rdata[ 0,8] , mem_rdata[0,16] }; }
                    case 2b11: { mem_wdata = {     xregsB.rdata[ 0,8] , mem_rdata[0,24] };           }
                  }
              }
              case 3b001: { // SH
                  switch (alu_out[1,1]) {
                    case 1b0: { mem_wdata = {   mem_rdata[16,16] , xregsB.rdata[ 0,16] }; }
                    case 1b1: { mem_wdata = { xregsB.rdata[0,16] , mem_rdata[0,16] }; }
                  }
              }
              case 3b010: { // SW
                mem_wdata   = xregsB.rdata;
              }
            }
//__display("STORE2 addr: %h op: %b write: %h",mem_addr,loadStoreOp,mem_wdata);
            mem_addr    = alu_out>>2;
            mem_wen     = 1;
++: // wait write

          }

          mem_addr = next_pc;

          break;

        } else {

          if (alu_working == 0) { // ALU done?

            // next instruction
            mem_addr     = (jump | cmp) ? alu_out[2,12]  : next_pc;
            // what do we write in register (pc or alu, load is handled above)
            xregsA.wdata = (jump | cmp) ? (next_pc) << 2 : alu_out;
            xregsB.wdata = (jump | cmp) ? (next_pc) << 2 : alu_out;

            // store result
            if (write_rd) {
              // commit result
              xregsA.wenable = 1;
              xregsB.wenable = 1;
              xregsA.addr    = write_rd;
              xregsB.addr    = write_rd;
            }

            break;
          }
        }
      }
  }


// --------------------------------------------------
// decode next instruction

algorithm decode(
  input   uint32  instr,
  output! uint5   write_rd,
  output! uint1   jump,
  output! uint1   branch,
  output! uint1   load_store,
  output! uint1   store,
  output! uint3   loadStoreOp,
  output! uint3   select,
  output! uint1   select2,
  output! int32   imm,
  output! uint1   forceZero,
  output! uint1   regOrPc,
  output! uint1   regOrImm
) {
  always {
    switch (instr[ 0, 7])
    {
      case 7b0010111: { // AUIPC
        //__display("AUIPC");
        write_rd    = Rtype(instr).rd;
        jump        = 0;
        branch      = 0;
        load_store  = 0;
        store       = 0;
        select      = 0;
        select2     = 0;
        imm         = {Utype(instr).imm31_12,12b0};
        forceZero   = 1;
        regOrPc     = 1; // pc
        regOrImm    = 1; // imm
      }

      case 7b0110111: { // LUI
        //__display("LUI");
        write_rd    = Rtype(instr).rd;
        jump        = 0;
        branch      = 0;
        load_store  = 0;
        store       = 0;
        select      = 0;
        select2     = 0;
        imm         = {Utype(instr).imm31_12,12b0};
        forceZero   = 0; // force x0
        regOrPc     = 0; // reg
        regOrImm    = 1; // imm
      }

      case 7b1101111: { // JAL
        //__display("JAL");
        write_rd    = Rtype(instr).rd;
        jump        = 1;
        branch      = 0;
        load_store  = 0;
        store       = 0;
        select      = 0;
        select2     = 0;
        imm         = {
           {12{Jtype(instr).imm20}},
           Jtype(instr).imm_19_12,
           Jtype(instr).imm11,
           Jtype(instr).imm10_1,
           1b0};
        forceZero   = 1;
        regOrPc     = 1; // pc
        regOrImm    = 1; // imm
      }

      case 7b1100111: { // JALR
        //__display("JALR");
        write_rd    = Rtype(instr).rd;
        jump        = 1;
        branch      = 0;
        load_store  = 0;
        store       = 0;
        select      = 0;
        select2     = 0;
        imm         = {{20{instr[31,1]}},Itype(instr).imm};
        forceZero   = 1;
        regOrPc     = 0; // reg
        regOrImm    = 1; // imm
      }

      case 7b1100011: { // branch
        // __display("BR*");
        write_rd    = 0;
        jump        = 0;
        branch      = 1;
        load_store  = 0;
        store       = 0;
        select      = 0;
        select2     = 0;
        imm         = {
            {20{Btype(instr).imm12}},
            Btype(instr).imm11,
            Btype(instr).imm10_5,
            Btype(instr).imm4_1,
            1b0
            };
        forceZero   = 1;
        regOrPc     = 1; // pc
        regOrImm    = 1; // imm
      }

      case 7b0000011: { // load
        // __display("LOAD");
        write_rd    = Rtype(instr).rd;
        jump        = 0;
        branch      = 1;
        load_store  = 1;
        store       = 0;
        loadStoreOp = Itype(instr).funct3;
        select      = 0;
        select2     = 0;
        imm         = {{20{instr[31,1]}},Itype(instr).imm};
        forceZero   = 1;
        regOrPc     = 0; // reg
        regOrImm    = 1; // imm
      }

      case 7b0100011: { // store
        // __display("STORE");
        write_rd    = 0;
        jump        = 0;
        branch      = 0;
        load_store  = 1;
        store       = 1;
        loadStoreOp = Itype(instr).funct3;
        select      = 0;
        select2     = 0;
        imm         = {{20{instr[31,1]}},Stype(instr).imm11_5,Stype(instr).imm4_0};
        forceZero   = 1;
        regOrPc     = 0; // reg
        regOrImm    = 1; // imm
      }

      case 7b0010011: { // integer, immediate
        write_rd    = Rtype(instr).rd;
        jump        = 0;
        branch      = 0;
        load_store  = 0;
        store       = 0;
        select      = Itype(instr).funct3;
        select2     = instr[30,1] /*SRLI/SRAI*/ & (Itype(instr).funct3 != 3b000) /*not ADD*/;
        imm         = {{20{instr[31,1]}},Itype(instr).imm};
        forceZero   = 1;
        regOrPc     = 0; // reg
        regOrImm    = 1; // imm
      }

      case 7b0110011: { // integer, registers
        // __display("REGOPS");
        write_rd    = Rtype(instr).rd;
        jump        = 0;
        branch      = 0;
        load_store  = 0;
        store       = 0;
        select      = Itype(instr).funct3;
        select2     = Rtype(instr).select2;
        imm         = 0;
        forceZero   = 1;
        regOrPc     = 0; // reg
        regOrImm    = 0; // reg
      }

      default: {
        write_rd    = 0;
        jump        = 0;
        branch      = 0;
        load_store  = 0;
        store       = 0;
        select      = 0;
        select2     = 0;
        imm         = 0;
        forceZero   = 0;
        regOrPc     = 0; // reg
        regOrImm    = 0; // reg
      }
    }
  }
}

// --------------------------------------------------
// Performs integer computations

algorithm intops(
  input!  uint1  enable,  // input! tells the compiler that the input does not
  input!  uint12 pc,      // need to be latched, so we can save registers
  input!  int32  xa,      // caller has to ensure consistency
  input!  int32  xb,
  input!  int32  imm,
  input!  uint3  select,
  input!  uint1  select2,
  input!  uint1  forceZero,
  input!  uint1  regOrPc,
  input!  uint1  regOrImm,
  output  int32  r,
  output  uint1  working,
) {
  uint1 signed = 0;
  uint1 dir    = 0;
  uint5 shamt  = 0;

  int32 a := regOrPc  ? __signed({20b0,pc[0,10],2b0}) : (forceZero ? xa : __signed(32b0));
  int32 b := regOrImm ? imm : (xb);
  //      ^^
  // using := during a declaration means that the variable now constantly tracks
  // the declared expression (but it is no longer assignable)
  // In other words, this is a wire!

  always { // this part of the algorithm is executed every clock

    if (shamt > 0) {

      // process the shift one bit at a time
      r     = dir ? (signed ? {r[31,1],r[1,31]} : {__signed(1b0),r[1,31]}) : {r[0,31],__signed(1b0)};
      shamt = shamt - 1;

    } else {

      if (enable) {
        switch (select) {
          case 3b000: { // ADD / SUB
            int32 tmp = uninitialized;
            if (select2) { tmp = -b; } else { tmp = b; }
            r = a + tmp;
          }
          case 3b010: { // SLTI
            if (__signed(a) < __signed(b)) { r = 32b1; } else { r = 32b0; }
          }
          case 3b011: { // SLTU
            if (__unsigned(a) < __unsigned(b)) { r = 32b1; } else { r = 32b0; }
          }
          case 3b100: { r = a ^ b;} // XOR
          case 3b110: { r = a | b;} // OR
          case 3b111: { r = a & b;} // AND
          case 3b001: { // SLLI
            r       = a;
            shamt   = __unsigned(b[0,5]);
            signed  = select2;
            dir     = 0;
          }
          case 3b101: { // SRLI / SRAI
            r       = a;
            shamt   = __unsigned(b[0,5]);
            signed  = select2;
            dir     = 1;
          }
        }
      }

    }

    working = (shamt > 0);

  }

}

// --------------------------------------------------
// Performs integer comparisons

algorithm intcmp(
  input!  int32 a,
  input!  int32 b,
  input!  uint3 select,
  input!  uint1 enable,
  output! uint1 j,
) {
  always {
    switch (select) {
      case 3b000: { j = enable & (a == b); } // BEQ
      case 3b001: { j = enable & (a != b); } // BNE
      case 3b100: { j = enable & (__signed(a)   <  __signed(b));   } // BLT
      case 3b110: { j = enable & (__unsigned(a) <  __unsigned(b)); } // BLTU
      case 3b101: { j = enable & (__signed(a)   >= __signed(b));   } // BGE
      case 3b111: { j = enable & (__unsigned(a) >= __unsigned(b)); } // BGEU
      default:    { j = 0; }
    }
  }
}
