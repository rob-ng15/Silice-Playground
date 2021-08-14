algorithm io_memmap(
    // LEDS (8 of)
    output  uint8   leds,

$$if not SIMULATION then
    input   uint$NUM_BTNS$ btns,

    // GPIO
    input   uint28  gn,
    output  uint28  gp,

    // UART
    output  uint1   uart_tx,
    input   uint1   uart_rx,

    // USB for PS/2
    input   uint1   us2_bd_dp,
    input   uint1   us2_bd_dn,

    // SDCARD
    output  uint1   sd_clk,
    output  uint1   sd_mosi,
    output  uint1   sd_csn,
    input   uint1   sd_miso,
$$end

    // CLOCKS
    input   uint1   clock_25mhz,

    // SDRAM ACCESS
    sdram_user      sio,

    // Memory access
    input   uint12  memoryAddress,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,

    input   uint16  writeData,
    output  uint16  readData
) <autorun> {
    uint24  sdramaddress = uninitialized;
    uint16  sdramwritedata = uninitialized;
    uint16  sdramreaddata = uninitialized;
    uint1   sdramwriteflag = uninitialized;
    uint1   sdramreadflag = uninitialized;
    // SDRAM and BRAM (for BIOS)
    // FUNCTION3 controls byte read/writes
    sdramcontroller sdram(
        sio <:> sio,
        address <: sdramaddress,
        writedata <: sdramwritedata,
        writeflag <: sdramwriteflag,
        readdata :> sdramreaddata,
        readflag <: sdramreadflag
    );

$$if not SIMULATION then
    // UART CONTROLLER, CONTAINS BUFFERS FOR INPUT/OUTPUT
    uint8   UARTinchar = uninitialized;
    uint8   UARToutchar = uninitialized;
    uint1   UARTinavailable = uninitialized;
    uint1   UARTinread = uninitialized;
    uint1   UARToutfull = uninitialized;
    uint1   UARToutwrite = uninitialized;
    uart UART(
        uart_tx :> uart_tx,
        uart_rx <: uart_rx,
        inchar :> UARTinchar,
        outchar <: UARToutchar,
        inavailable :> UARTinavailable,
        inread <: UARTinread,
        outfull :> UARToutfull,
        outwrite <: UARToutwrite
    );

    // PS2 CONTROLLER, CONTAINS BUFFERS FOR INPUT/OUTPUT
    uint8   PS2inchar = uninitialized;
    uint1   PS2inavailable = uninitialized;
    uint1   PS2inread = uninitialized;
    ps2buffer PS2(
        clock_25mhz <: clock_25mhz,
        us2_bd_dp <: us2_bd_dp,
        us2_bd_dn <: us2_bd_dn,
        inchar :> PS2inchar,
        inavailable :> PS2inavailable,
        inread <: PS2inread
    );

    // SDCARD AND BUFFER
    uint16  sectoraddressH = uninitialized;
    uint16  sectoraddressL = uninitialized;
    uint9   bufferaddress = uninitialized;
    uint8   bufferdata = uninitialized;
    uint1   SDCARDready = uninitialized;
    uint1   SDCARDreadsector = uninitialized;
    sdcardbuffer SDCARD(
        sd_clk :> sd_clk,
        sd_mosi :> sd_mosi,
        sd_csn :> sd_csn,
        sd_miso <: sd_miso,
        sectoraddressH <: sectoraddressH,
        sectoraddressL <: sectoraddressL,
        bufferaddress <: bufferaddress,
        bufferdata :> bufferdata,
        readsector <: SDCARDreadsector,
        ready :> SDCARDready
    );

    // I/O FLAGS
    UARTinread := 0; UARToutwrite := 0; PS2inread := 0; SDCARDreadsector := 0;
$$end

    sdramwriteflag := 0; sdramreadflag := 0;

    always {
        // READ IO Memory
        switch( memoryRead ) {
            case 1: {
                switch( memoryAddress ) {
                    // UART, LEDS, BUTTONS and CLOCK
                    case 12h130: { readData = leds; }
                    $$if not SIMULATION then
                    case 12h100: {
                        switch( { PS2inavailable, UARTinavailable } ) {
                            case 2b00: { readData = 0; }
                            case 2b01: { readData = { 8b0, UARTinchar }; UARTinread = 1; }
                            default: { readData = { 8b0, PS2inchar }; PS2inread = 1; }
                        }
                    }
                    case 12h102: { readData = { 14b0, UARToutfull ? 1b1 : 1b0, ( UARTinavailable || PS2inavailable ) ? 1b1: 1b0 }; }
                    case 12h120: { readData = { $16-NUM_BTNS$b0, btns[0,$NUM_BTNS$] }; }

                    // SDCARD
                    case 12h140: { readData = SDCARDready; }
                    case 12h150: { readData = bufferdata; }
                    $$end
                    // SDRAM
                    case 12hf00: { readData = sdramreaddata; }
                    case 12hf02: { readData = sdram.busy; }

                    // RETURN NULL VALUE
                    default: { readData = 0; }
                }
            }
            default: {}
        }

        // WRITE IO Memory
        switch( memoryWrite ) {
            case 1: {
                switch( memoryAddress ) {
                    // UART, LEDS
                    case 12h130: { leds = writeData; }
                    $$if not SIMULATION then
                    case 12h100: { UARToutchar = writeData[0,8]; UARToutwrite = 1; }

                    // SDCARD
                    case 12h140: { SDCARDreadsector = 1; }
                    case 12h142: { sectoraddressH = writeData; }
                    case 12h144: { sectoraddressL = writeData; }
                    case 12h150: { bufferaddress = writeData; }
                    $$end
                    // SDRAM
                    case 12hf00: { sdramwritedata = writeData; }
                    case 12hf02: {
                        switch( writeData ) {
                            case 1: { sdramreadflag = 1; }
                            case 2: { sdramwriteflag = 1; }
                            default: {}
                        }
                    }
                    case 12hf04: { sdramaddress[16,8] = writeData; }
                    case 12hf05: { sdramaddress[0,16] = writeData; }
                    default: {}
                }
            }
            default: {}
        }
    }
}

algorithm copro_memmap(
    // Memory access
    input   uint12  memoryAddress,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,

    input   uint16  writeData,
    output  uint16  readData
) <autorun> {
    // Mathematics Co-Processors
    divmod32by16 divmod32by16to16qr();
    divmod16by16 divmod16by16to16qr();
    multi16by16to32DSP multiplier16by16to32();

    int32   doperand1 = uninitialized;
    int32   doperand2 = uninitialized;
    int32   dtotal = uninitialized;
    int32   ddifference = uninitialized;
    int32   dincrement = uninitialized;
    int32   ddecrememt = uninitialized;
    int32   dtimes2 = uninitialized;
    int32   ddivide2 = uninitialized;
    int32   dnegation = uninitialized;
    int32   dinvert = uninitialized;
    int32   dxor = uninitialized;
    int32   dand = uninitialized;
    int32   dor = uninitialized;
    int32   dabsolute = uninitialized;
    int32   dmaximum = uninitialized;
    int32   dminimum = uninitialized;
    int16   dzeroequal = uninitialized;
    int16   dzeroless = uninitialized;
    int16   dequal = uninitialized;
    int16   dlessthan = uninitialized;
    doubleops doperations(
        operand1 <: doperand1,
        operand2 <: doperand2,
        total :> dtotal,
        difference :> ddifference,
        increment :> dincrement,
        decrement :> ddecrememt,
        times2 :> dtimes2,
        divide2 :> ddivide2,
        negation :> dnegation,
        binaryinvert :> dinvert,
        binaryxor :> dxor,
        binaryand :> dand,
        binaryor :> dor,
        absolute :> dabsolute,
        maximum :> dmaximum,
        minimum :> dminimum,
        zeroequal :> dzeroequal,
        zeroless :> dzeroless,
        equal :> dequal,
        lessthan :> dlessthan
    );

    uint16  fpua = uninitialized;
    uint16  fpub = uninitialized;
    uint16  fpuitof = uninitialized;
    uint16  fpuftoi = uninitialized;
    uint16  fpufadd = uninitialized;
    uint16  fpufsub = uninitialized;
    uint16  fpufmul = uninitialized;
    uint16  fpufdiv = uninitialized;
    uint16  fpufsqrt = uninitialized;
    int16   fpuless = uninitialized;
    int16   fpuequal = uninitialized;
    int16   fpulessequal = uninitialized;
    uint3   fpustart = uninitialized;
    uint1   fpubusy = uninitialized;
    floatops fpu(
        a <: fpua,
        b <: fpub,
        itof :> fpuitof,
        ftoi :> fpuftoi,
        fadd :> fpufadd,
        fsub :> fpufsub,
        fmul :> fpufmul,
        fdiv :> fpufdiv,
        fsqrt :> fpufsqrt,
        less :> fpuless,
        equal :> fpuequal,
        lessequal :> fpulessequal,
        start <: fpustart,
        busy :> fpubusy
    );

    // RESET Mathematics Co-Processor Controls
    divmod32by16to16qr.start := 0;
    divmod16by16to16qr.start := 0;
    multiplier16by16to32.start := 0;
    fpustart := 0;

    always {
        // READ IO Memory
        switch( memoryRead ) {
            case 1: {
                switch( memoryAddress ) {
                    case 12h000: { readData = words(dtotal).hword; }
                    case 12h001: { readData = words(dtotal).lword; }
                    case 12h002: { readData = words(ddifference).hword; }
                    case 12h003: { readData = words(ddifference).lword; }
                    case 12h004: { readData = words(dincrement).hword; }
                    case 12h005: { readData = words(dincrement).lword; }
                    case 12h006: { readData = words(ddecrememt).hword; }
                    case 12h007: { readData = words(ddecrememt).lword; }
                    case 12h008: { readData = words(dtimes2).hword; }
                    case 12h009: { readData = words(dtimes2).lword; }
                    case 12h00a: { readData = words(ddivide2).hword; }
                    case 12h00b: { readData = words(ddivide2).lword; }
                    case 12h00c: { readData = words(dnegation).hword; }
                    case 12h00d: { readData = words(dnegation).lword; }
                    case 12h00e: { readData = words(dinvert).hword; }
                    case 12h00f: { readData = words(dinvert).lword; }
                    case 12h010: { readData = words(dxor).hword; }
                    case 12h011: { readData = words(dxor).lword; }
                    case 12h012: { readData = words(dand).hword; }
                    case 12h013: { readData = words(dand).lword; }
                    case 12h014: { readData = words(dor).hword; }
                    case 12h015: { readData = words(dor).lword; }
                    case 12h016: { readData = words(dabsolute).hword; }
                    case 12h017: { readData = words(dabsolute).lword; }
                    case 12h018: { readData = words(dmaximum).hword; }
                    case 12h019: { readData = words(dmaximum).lword; }
                    case 12h01a: { readData = words(dminimum).hword; }
                    case 12h01b: { readData = words(dminimum).lword; }
                    case 12h01c: { readData = dzeroequal; }
                    case 12h01d: { readData = dzeroless; }
                    case 12h01e: { readData = dequal; }
                    case 12h01f: { readData = dlessthan; }
                    case 12h020: { readData = divmod32by16to16qr.quotient[0,16]; }
                    case 12h021: { readData = divmod32by16to16qr.remainder[0,16]; }
                    case 12h023: { readData = divmod32by16to16qr.active; }
                    case 12h024: { readData = divmod16by16to16qr.quotient; }
                    case 12h025: { readData = divmod16by16to16qr.remainder; }
                    case 12h026: { readData = divmod16by16to16qr.active; }
                    case 12h027: { readData = multiplier16by16to32.product[16,16]; }
                    case 12h028: { readData = multiplier16by16to32.product[0,16]; }

                    case 12h102: { readData = fpubusy; }
                    case 12h110: { readData = fpuitof; }
                    case 12h111: { readData = fpuftoi; }
                    case 12h112: { readData = fpufadd; }
                    case 12h113: { readData = fpufsub; }
                    case 12h114: { readData = fpufmul; }
                    case 12h115: { readData = fpufdiv; }
                    case 12h116: { readData = fpufsqrt; }
                    case 12h117: { readData = fpuless; }
                    case 12h118: { readData = fpuequal; }
                    case 12h119: { readData = fpulessequal; }

                    // RETURN NULL VALUE
                    default: { readData = 0; }
                }
            }
            default: {}
        }

        // WRITE IO Memory
        switch( memoryWrite ) {
            case 1: {
                switch( memoryAddress ) {
                    case 12h000: { doperand1[16,16] = writeData; }
                    case 12h001: { doperand1[0,16] = writeData; }
                    case 12h002: { doperand2[16,16] = writeData; }
                    case 12h003: { doperand2[0,16] = writeData; }
                    case 12h020: { divmod32by16to16qr.dividend[16,16] = writeData; }
                    case 12h021: { divmod32by16to16qr.dividend[0,16] = writeData; }
                    case 12h022: { divmod32by16to16qr.divisor = writeData; }
                    case 12h023: { divmod32by16to16qr.start = writeData; }
                    case 12h024: { divmod16by16to16qr.dividend = writeData; }
                    case 12h025: { divmod16by16to16qr.divisor = writeData; }
                    case 12h026: { divmod16by16to16qr.start = writeData; }
                    case 12h027: { multiplier16by16to32.factor1 = writeData; }
                    case 12h028: { multiplier16by16to32.factor2 = writeData; }
                    case 12h029: { multiplier16by16to32.start = writeData; }

                    case 12h100: { fpua = writeData; }
                    case 12h101: { fpub = writeData; }
                    case 12h102: { fpustart = writeData; }

                    default: {}
                }
            }
            default: {}
        }
    } // while(1)
}

algorithm audiotimers_memmap(
    // CLOCKS
    input   uint1   clock_25mhz,

    // Memory access
    input   uint12  memoryAddress,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,
    input   uint16  writeData,
    output  uint16  readData,

    // AUDIO
    output  uint4   audio_l,
    output  uint4   audio_r
) <autorun> {
    // TIMERS and RNG
    uint16  systemclock = uninitialized;
    uint16  timer1hz0 = uninitialized;
    uint16  timer1hz1 = uninitialized;
    uint16  timer1khz0 = uninitialized;
    uint16  timer1khz1 = uninitialized;
    uint16  sleepTimer0 = uninitialized;
    uint16  sleepTimer1 = uninitialized;
    uint16  u_noise_out = uninitialized;
    uint16  g_noise_out = uninitialized;
    uint4   static4bit <: u_noise_out[0,4];
    uint16  counter = uninitialized;
    uint3   resetcounter = uninitialized;
    timers_rng timers <@clock_25mhz> (
        systemclock :> systemclock,
        timer1hz0 :> timer1hz0,
        timer1hz1 :> timer1hz1,
        timer1khz0 :> timer1khz0,
        timer1khz1 :> timer1khz1,
        sleepTimer0 :> sleepTimer0,
        sleepTimer1 :> sleepTimer1,
        u_noise_out :> u_noise_out,
        g_noise_out :> g_noise_out,
        counter <: counter,
        resetcounter <: resetcounter
    );

    // Left and Right audio channels
    uint1   audio_active_l = uninitialized;
    uint1   audio_active_r = uninitialized;
    uint4   waveform = uninitialized;
    uint7   note = uninitialized;
    uint16  duration = uninitialized;
    uint2   apu_write = uninitialized;
    audio apu_processor <@clock_25mhz> (
        staticGenerator <: static4bit,
        audio_l :> audio_l,
        audio_active_l :> audio_active_l,
        audio_r :> audio_r,
        audio_active_r :> audio_active_r,
        waveform <: waveform,
        note <: note,
        duration <: duration,
        apu_write <: apu_write
    );

    // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always {
        // READ IO Memory
        switch( memoryRead ) {
            case 1: {
                switch( memoryAddress ) {
                    // TIMERS and RNG
                    case 12h000: { readData = g_noise_out; }
                    case 12h002: { readData = u_noise_out; }
                    case 12h010: { readData = timer1hz0; }
                    case 12h012: { readData = timer1hz1; }
                    case 12h020: { readData = timer1khz0; }
                    case 12h022: { readData = timer1khz1; }
                    case 12h030: { readData = sleepTimer0; }
                    case 12h032: { readData = sleepTimer1; }
                    case 12h040: { readData = systemclock; }

                    // AUDIO
                    case 12h110: { readData = audio_active_l; }
                    case 12h112: { readData = audio_active_r; }

                    // RETURN NULL VALUE
                    default: { readData = 0; }
                }
            }
            default: {}
        }
        // WRITE IO Memory
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                switch( memoryAddress ) {
                // TIMERS and RNG
                    case 12h010: { resetcounter = 1; }
                    case 12h012: { resetcounter = 2; }
                    case 12h020: { counter = writeData; resetcounter = 3; }
                    case 12h022: { counter = writeData; resetcounter = 4; }
                    case 12h030: { counter = writeData; resetcounter = 5; }
                    case 12h032: { counter = writeData; resetcounter = 6; }

                    // AUDIO
                    case 12h100: { waveform = writeData; }
                    case 12h102: { note = writeData; }
                    case 12h104: { duration = writeData; }
                    case 12h106: { apu_write = writeData; }
                    default: {}
                }
            }
            case 2b00: {
                // RESET TIMER and AUDIO Co-Processor Controls
                resetcounter = 0;
                apu_write = 0;
            }
            default: {}
        }
        LATCHmemoryWrite = memoryWrite;
    }
}

// TIMERS and RNG Controllers
algorithm timers_rng(
    output  uint16  systemclock,
    output  uint16  timer1hz0,
    output  uint16  timer1hz1,
    output  uint16  timer1khz0,
    output  uint16  timer1khz1,
    output  uint16  sleepTimer0,
    output  uint16  sleepTimer1,
    output  uint16  u_noise_out,
    output  uint16  g_noise_out,
    input   uint16  counter,
    input   uint3   resetcounter
) <autorun> {
    // RNG random number generator
    random rng( u_noise_out :> u_noise_out,  g_noise_out :> g_noise_out );

    // 1hz timers (p1hz used for systemClock, timer1hz for user purposes)
    uint1   P1resetCounter = uninitialized;
    pulse1hz P1( counter1hz :> systemclock, resetCounter <: P1resetCounter );

    uint1   T1hz0resetCounter = uninitialized;
    uint1   T1hz1resetCounter = uninitialized;
    pulse1hz T1hz0( counter1hz :> timer1hz0, resetCounter <: T1hz0resetCounter );
    pulse1hz T1hz1( counter1hz :> timer1hz1, resetCounter <: T1hz1resetCounter );

    // 1khz timers (sleepTimers used for sleep command, timer1khzs for user purposes)
    uint16  T0khz0resetCounter = uninitialized;
    uint16  T1khz1resetCounter = uninitialized;
    uint16  STimer0resetCounter = uninitialized;
    uint16  STimer1resetCounter = uninitialized;
    pulse1khz T0khz0( counter1khz :> timer1khz0, resetCounter <: T0khz0resetCounter );
    pulse1khz T1khz1( counter1khz :> timer1khz1, resetCounter <: T1khz1resetCounter );
    pulse1khz STimer0( counter1khz :> sleepTimer0, resetCounter <: STimer0resetCounter );
    pulse1khz STimer1( counter1khz :> sleepTimer1, resetCounter <: STimer1resetCounter );

    P1resetCounter := 0;
    T1hz0resetCounter := 0;
    T1hz1resetCounter := 0;
    T0khz0resetCounter := 0;
    T1khz1resetCounter := 0;
    STimer0resetCounter := 0;
    STimer1resetCounter := 0;

    always {
        switch( resetcounter ) {
        default: {}
            case 1: { T1hz0resetCounter = 1; }
            case 2: { T1hz1resetCounter = 1; }
            case 3: { T0khz0resetCounter = counter; }
            case 4: { T1khz1resetCounter = counter; }
            case 5: { STimer0resetCounter = counter; }
            case 6: { STimer1resetCounter = counter; }
        }
    }
}

// AUDIO L&R Controller
algorithm audio(
    input   uint4   staticGenerator,
    input   uint4   waveform,
    input   uint7   note,
    input   uint16  duration,
    input   uint2   apu_write,
    output  uint4   audio_l,
    output  uint1   audio_active_l,
    output  uint4   audio_r,
    output  uint1   audio_active_r
) <autorun> {
    // Left and Right audio channels
    uint4   Lwaveform = uninitialized;
    uint7   Lnote = uninitialized;
    uint16  Lduration = uninitialized;
    uint1   Lapu_write = uninitialized;
    apu apu_processor_L(
        staticGenerator <: staticGenerator,
        audio_output :> audio_l,
        audio_active :> audio_active_l,
        waveform <: Lwaveform,
        note <: Lnote,
        duration <: Lduration,
        apu_write <: Lapu_write
    );
    uint4   Rwaveform = uninitialized;
    uint7   Rnote = uninitialized;
    uint16  Rduration = uninitialized;
    uint1   Rapu_write = uninitialized;
    apu apu_processor_R(
        staticGenerator <: staticGenerator,
        audio_output :> audio_r,
        audio_active :> audio_active_r,
        waveform <: Rwaveform,
        note <: Rnote,
        duration <: Rduration,
        apu_write <: Rapu_write
    );

    Lapu_write := 0; Rapu_write := 0;

    always {
        switch( apu_write ) {
            default: {}
            case 1: {
                Lwaveform = waveform;
                Lnote = note;
                Lduration = duration;
                Lapu_write = 1;
            }
            case 2: {
                Rwaveform = waveform;
                Rnote = note;
                Rduration = duration;
                Rapu_write = 1;
            }
            case 3: {
                Lwaveform = waveform;
                Lnote = note;
                Lduration = duration;
                Lapu_write = 1;
                Rwaveform = waveform;
                Rnote = note;
                Rduration = duration;
                Rapu_write = 1;
            }
        }
    }
}

// UART BUFFER CONTROLLER
algorithm uart(
    // UART
    output  uint1   uart_tx,
    input   uint1   uart_rx,

    output  uint1   inavailable,
    output  uint1   outfull,

    output  uint8   inchar,
    input   uint1   inread,
    input   uint8   outchar,
    input   uint1   outwrite
) <autorun> {
    uint1   update = uninitialized;

    // UART tx and rx
    // UART written in Silice by https://github.com/sylefeb/Silice
    uart_out uo;
    uart_sender usend(
        io      <:> uo,
        uart_tx :>  uart_tx
    );
    uart_in ui;
    uart_receiver urecv(
        io      <:> ui,
        uart_rx <:  uart_rx
    );

    // UART input FIFO (4096 character) as dualport bram (code from @sylefeb)
    simple_dualport_bram uint8 uartInBuffer <input!> [4096] = uninitialized;
    uint13  uartInBufferNext = 0;
    uint13  uartInBufferTop = 0;

    // UART output FIFO (4096 character) as dualport bram (code from @sylefeb)
    simple_dualport_bram uint8 uartOutBuffer <input!> [4096] = uninitialized;
    uint13   uartOutBufferNext = 0;
    uint13   uartOutBufferTop = 0;
    uint13   newuartOutBufferTop = 0;

    // FLAGS
    inavailable := ( uartInBufferNext != uartInBufferTop );
    outfull := ( uartOutBufferTop + 1 == uartOutBufferNext );
    inchar := uartInBuffer.rdata0;

    // UART Buffers ( code from @sylefeb )
    uartInBuffer.wenable1 := 1;  // always write on port 1
    uartInBuffer.addr0 := uartInBufferNext; // FIFO reads on next
    uartInBuffer.addr1 := uartInBufferTop;  // FIFO writes on top
    uartOutBuffer.wenable1 := 1; // always write on port 1
    uartOutBuffer.addr0 := uartOutBufferNext; // FIFO reads on next
    uartInBuffer.wdata1 := ui.data_out;
    uartInBufferTop := uartInBufferTop + ui.data_out_ready;
    uo.data_in := uartOutBuffer.rdata0;
    uo.data_in_ready := ( uartOutBufferNext != uartOutBufferTop ) && ( !uo.busy );
    uartOutBufferNext :=  uartOutBufferNext + ( (uartOutBufferNext != uartOutBufferTop) && ( !uo.busy ) );

    always {
        if( outwrite ) {
                uartOutBuffer.addr1 = uartOutBufferTop;
                uartOutBuffer.wdata1 = outchar;
                update = 1;
        } else {
            if( update ) { uartOutBufferTop = uartOutBufferTop + 1; update = 0; }
        }
        uartInBufferNext = uartInBufferNext + inread;
    }
}

// PS2 BUFFER CONTROLLER
algorithm ps2buffer(
    input   uint1   clock_25mhz,

    // USB for PS/2
    input   uint1   us2_bd_dp,
    input   uint1   us2_bd_dn,

    output  uint1   inavailable,
    output  uint8   inchar,
    input   uint1   inread
) <autorun> {
    // PS/2 input FIFO (256 character) as dualport bram (code from @sylefeb)
    simple_dualport_bram uint8 ps2Buffer[256] = uninitialized;
    uint8  ps2BufferNext = 0;
    uint7  ps2BufferTop = 0;

    // PS 2 ASCII
    //uint1   PS2asciivalid = uninitialized;
    //uint8   PS2ascii = uninitialized;
    ps2ascii PS2(
        clock_25mhz <: clock_25mhz,
        us2_bd_dp <: us2_bd_dp,
        us2_bd_dn <: us2_bd_dn,
        //asciivalid :> PS2asciivalid,
        //ascii :> PS2ascii
    );

    // PS2 Buffers
    uint1   update = uninitialized;
    ps2Buffer.wenable1 := 1;  // always write on port 1
    ps2Buffer.addr0 := ps2BufferNext; // FIFO reads on next

    // FLAGS
    inavailable := ( ps2BufferNext != ps2BufferTop );
    inchar := ps2Buffer.rdata0;

    always {
        if( PS2.asciivalid ) {
            ps2Buffer.addr1 = ps2BufferTop;
            ps2Buffer.wdata1 = PS2.ascii;
            update = 1;
        } else {
            if( update ) { ps2BufferTop = ps2BufferTop + 1; update = 0; }
        }
        ps2BufferNext = ps2BufferNext + inread;
    }
}

// SDCARD AND BUFFER CONTROLLER
algorithm sdcardbuffer(
    // SDCARD
    output  uint1   sd_clk,
    output  uint1   sd_mosi,
    output  uint1   sd_csn,
    input   uint1   sd_miso,

    input   uint1   readsector,
    input   uint16  sectoraddressH,
    input   uint16  sectoraddressL,
    input   uint9   bufferaddress,
    output  uint1   ready,
    output  uint8   bufferdata
) <autorun> {
    // SDCARD - Code for the SDCARD from @sylefeb
    simple_dualport_bram uint8 sdbuffer <input!> [512] = uninitialized;
    sdcardio sdcio;
    sdcard sd(
        // pins
        sd_clk      :> sd_clk,
        sd_mosi     :> sd_mosi,
        sd_csn      :> sd_csn,
        sd_miso     <: sd_miso,
        // io
        io          <:> sdcio,
        // bram port
        store       <:> sdbuffer
    );

    // SDCARD Commands
    sdcio.read_sector := readsector;
    sdcio.addr_sector := { sectoraddressH, sectoraddressL };
    sdbuffer.addr0 := bufferaddress;
    ready := sdcio.ready;
    bufferdata := sdbuffer.rdata0;
}

algorithm sdramcontroller(
    sdram_user      sio,

    input   uint24  address,

    input   uint1   writeflag,
    input   uint16  writedata,

    input   uint1   readflag,
    output  uint16  readdata,

    output  uint1   busy(0)
) <autorun> {
    // MEMORY ACCESS FLAGS
    sio.addr := { address, 1b0 }; sio.in_valid := 0;
    readdata := sio.data_out;

    while(1) {
        switch( { readflag, writeflag } ) {
            case 2b10: {
                busy = 1;
                // READ FROM SDRAM
                sio.rw = 0;
                sio.in_valid = 1;
                while( !sio.done ) {}
                busy = 0;
            }
            case 2b01: {
                busy = 1;
                // WRITE TO SDRAM
                sio.data_in = writedata;
                sio.rw = 1;
                sio.in_valid = 1;
                while( !sio.done ) {}
                busy = 0;
            }
            default: {}
        }
    }
}
