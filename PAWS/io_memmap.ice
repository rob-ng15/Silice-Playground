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

    // Memory access
    input   uint12  memoryAddress,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,

    input   uint16  writeData,
    output  uint16  readData,

    // SMT STATUS
    output  uint1   SMTRUNNING(0),
    output  uint32  SMTSTARTPC(0)
) <autorun> {
$$if not SIMULATION then
    // UART CONTROLLER, CONTAINS BUFFERS FOR INPUT/OUTPUT
    uint8   Uinchar = uninitialized;
    uint8   Uoutchar = uninitialized;
    uart UART(
        uart_tx :> uart_tx,
        uart_rx <: uart_rx,
        inchar :> Uinchar,
        outchar <: Uoutchar
    );

    // PS2 CONTROLLER, CONTAINS BUFFERS FOR INPUT/OUTPUT
    uint8   Pinchar = uninitialized;
    ps2buffer PS2(
        clock_25mhz <: clock_25mhz,
        us2_bd_dp <: us2_bd_dp,
        us2_bd_dn <: us2_bd_dn,
        inchar :> Pinchar
    );

    // SDCARD AND BUFFER
    uint16  sectoraddressH = uninitialized;
    uint16  sectoraddressL = uninitialized;
    uint9   bufferaddress = uninitialized;
    uint8   bufferdata = uninitialized;
    sdcardbuffer SDCARD(
        sd_clk :> sd_clk,
        sd_mosi :> sd_mosi,
        sd_csn :> sd_csn,
        sd_miso <: sd_miso,
        sectoraddressH <: sectoraddressH,
        sectoraddressL <: sectoraddressL,
        bufferaddress <: bufferaddress,
        bufferdata :> bufferdata
    );

    // I/O FLAGS
    UART.inread := 0; UART.outwrite := 0;
    PS2.inread := 0;
    SDCARD.readsector := 0;
$$end
     always {
        // READ IO Memory
        switch( memoryRead ) {
            case 1: {
                switch( memoryAddress ) {
                    // UART, LEDS, BUTTONS and CLOCK
    $$if not SIMULATION then
                    case 12h100: { readData = { 8b0, Uinchar }; UART.inread = 1; }
                    case 12h102: { readData = { 14b0, UART.outfull, UART.inavailable }; }
                    case 12h120: { readData = { $16-NUM_BTNS$b0, btns[0,$NUM_BTNS$] }; }
    $$end
                    case 12h130: { readData = leds; }
    $$if not SIMULATION then
                    // PS2
                    case 12h110: { readData = PS2.inavailable; }
                    case 12h112: {
                        switch( PS2.inavailable ) {
                            case 1: { readData = Pinchar; PS2.inread = 1; }
                            case 0: { readData = 0; }
                        }
                    }

                    // SDCARD
                    case 12h140: { readData = SDCARD.ready; }
                    case 12h150: { readData = bufferdata; }
    $$end

                    // SMT STATUS
                    case 12hffe: { readData = SMTRUNNING; }

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
                    case 12h100: { Uoutchar = writeData[0,8]; UART.outwrite = 1; }

                    // SDCARD
                    case 12h140: { SDCARD.readsector = 1; }
                    case 12h142: { sectoraddressH = writeData; }
                    case 12h144: { sectoraddressL = writeData; }
                    case 12h150: { bufferaddress = writeData; }
    $$end
                    // SMT STATUS
                    case 12hff0: { SMTSTARTPC[16,16] = writeData; }
                    case 12hff2: { SMTSTARTPC[0,16] = writeData; }
                    case 12hffe: { SMTRUNNING = writeData; }
                    default: {}
                }
            }
            default: {}
        }
    }

    // DISBLE SMT ON STARTUP
    SMTRUNNING = 0;
    SMTSTARTPC = 0;
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
    timers_rng timers <@clock_25mhz> (
        systemclock :> systemclock,
        timer1hz0 :> timer1hz0,
        timer1hz1 :> timer1hz1,
        timer1khz0 :> timer1khz0,
        timer1khz1 :> timer1khz1,
        sleepTimer0 :> sleepTimer0,
        sleepTimer1 :> sleepTimer1,
        u_noise_out :> u_noise_out,
        g_noise_out :> g_noise_out
    );

    // Left and Right audio channels
    uint1   audio_active_l = uninitialized;
    uint1   audio_active_r = uninitialized;
    audio apu_processor <@clock_25mhz> (
        staticGenerator <: static4bit,
        audio_l :> audio_l,
        audio_active_l :> audio_active_l,
        audio_r :> audio_r,
        audio_active_r :> audio_active_r
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
                    case 12h010: { timers.resetcounter = 1; }
                    case 12h012: { timers.resetcounter = 2; }
                    case 12h020: { timers.counter = writeData; timers.resetcounter = 3; }
                    case 12h022: { timers.counter = writeData; timers.resetcounter = 4; }
                    case 12h030: { timers.counter = writeData; timers.resetcounter = 5; }
                    case 12h032: { timers.counter = writeData; timers.resetcounter = 6; }

                    // AUDIO
                    case 12h100: { apu_processor.waveform = writeData; }
                    case 12h102: { apu_processor.note = writeData; }
                    case 12h104: { apu_processor.duration = writeData; }
                    case 12h106: { apu_processor.apu_write = writeData; }
                    default: {}
                }
            }
            case 2b00: {
                // RESET TIMER and AUDIO Co-Processor Controls
                timers.resetcounter = 0;
                apu_processor.apu_write = 0;
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
    pulse1hz P1( counter1hz :> systemclock );
    pulse1hz T1hz0( counter1hz :> timer1hz0 );
    pulse1hz T1hz1( counter1hz :> timer1hz1 );

    // 1khz timers (sleepTimers used for sleep command, timer1khzs for user purposes)
    pulse1khz T0khz0( counter1khz :> timer1khz0 );
    pulse1khz T1khz1( counter1khz :> timer1khz1 );
    pulse1khz STimer0( counter1khz :> sleepTimer0 );
    pulse1khz STimer1( counter1khz :> sleepTimer1 );

    P1.resetCounter := 0;
    T1hz0.resetCounter := 0;
    T1hz1.resetCounter := 0;
    T0khz0.resetCounter := 0;
    T1khz1.resetCounter := 0;
    STimer0.resetCounter := 0;
    STimer1.resetCounter := 0;

    always {
        switch( resetcounter ) {
        default: {}
            case 1: { T1hz0.resetCounter = 1; }
            case 2: { T1hz1.resetCounter = 1; }
            case 3: { T0khz0.resetCounter = counter; }
            case 4: { T1khz1.resetCounter = counter; }
            case 5: { STimer0.resetCounter = counter; }
            case 6: { STimer1.resetCounter = counter; }
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
    apu apu_processor_L(
        staticGenerator <: staticGenerator,
        audio_output :> audio_l,
        audio_active :> audio_active_l
    );
    apu apu_processor_R(
        staticGenerator <: staticGenerator,
        audio_output :> audio_r,
        audio_active :> audio_active_r
    );

    apu_processor_L.apu_write := 0;
    apu_processor_R.apu_write := 0;

    always {
        switch( apu_write ) {
            default: {}
            case 1: {
                apu_processor_L.waveform = waveform;
                apu_processor_L.note = note;
                apu_processor_L.duration = duration;
                apu_processor_L.apu_write = 1;
            }
            case 2: {
                apu_processor_R.waveform = waveform;
                apu_processor_R.note = note;
                apu_processor_R.duration = duration;
                apu_processor_R.apu_write = 1;
            }
            case 3: {
                apu_processor_L.waveform = waveform;
                apu_processor_L.note = note;
                apu_processor_L.duration = duration;
                apu_processor_L.apu_write = 1;
                apu_processor_R.waveform = waveform;
                apu_processor_R.note = note;
                apu_processor_R.duration = duration;
                apu_processor_R.apu_write = 1;
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

    // UART input FIFO (256 character) as dualport bram (code from @sylefeb)
    simple_dualport_bram uint8 uartInBuffer <input!> [256] = uninitialized;
    uint8  uartInBufferNext = 0;
    uint8  uartInBufferTop = 0;

    // UART output FIFO (256 character) as dualport bram (code from @sylefeb)
    simple_dualport_bram uint8 uartOutBuffer <input!> [256] = uninitialized;
    uint8   uartOutBufferNext = 0;
    uint8   uartOutBufferTop = 0;
    uint8   newuartOutBufferTop = 0;

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
    uint1   update = uninitialized;

    // PS/2 input FIFO (256 character) as dualport bram (code from @sylefeb)
    simple_dualport_bram uint8 ps2Buffer <input!> [256] = uninitialized;
    uint8  ps2BufferNext = 0;
    uint7  ps2BufferTop = 0;

    // PS 2 ASCII
    ps2ascii PS2(
        clock_25mhz <: clock_25mhz,
        us2_bd_dp <: us2_bd_dp,
        us2_bd_dn <: us2_bd_dn,
    );

    // PS2 Buffers
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
