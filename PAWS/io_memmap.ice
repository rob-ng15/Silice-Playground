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
    uint8   UARTinchar = uninitialized;
    uint8   UARToutchar = uninitialized;
    uint1   UARTinavailable = uninitialized;
    uint1   UARToutfull = uninitialized;
    uint2   UARTinread = 0;                                 // 2 BIT LATCH ( bit 0 is the signal )
    uint2   UARToutwrite = 0;                               // 2 BIT LATCH ( bit 0 is the signal )
    uart UART <@clock_25mhz> (
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
    uint9   PS2inchar = uninitialized;
    uint1   PS2inavailable = uninitialized;
    uint2   PS2inread = 0;                                  // 2 BIT LATCH ( bit 0 is the signal )
    uint1   PS2outputascii = uninitialized;                 // DEFAULT TO JOYSTICK MODE ( AT BASE OF ALGORITHM )
    uint16  PS2joystick = uninitialized;
    ps2buffer PS2 <@clock_25mhz> (
        us2_bd_dp <: us2_bd_dp,
        us2_bd_dn <: us2_bd_dn,
        inchar :> PS2inchar,
        inavailable :> PS2inavailable,
        inread <: PS2inread,
        joystick :> PS2joystick,
        outputascii <: PS2outputascii
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
    SDCARDreadsector := 0;
$$end
     always {
        // UPDATE LATCHES
$$if not SIMULATION then
        UARTinread = UARTinread >> 1; UARToutwrite = UARToutwrite >> 1; PS2inread = PS2inread >> 1;
$$end

        // READ IO Memory
        if( memoryRead ) {
            switch( memoryAddress ) {
                // UART, LEDS, BUTTONS and CLOCK
                $$if not SIMULATION then
                case 12h100: { readData = { 8b0, UARTinchar }; UARTinread = 2b11; }
                case 12h102: { readData = { 14b0, UARToutfull, UARTinavailable }; }
                case 12h120: { readData = PS2outputascii ? { $16-NUM_BTNS$b0, btns[0,$NUM_BTNS$] } : { $16-NUM_BTNS$b0, btns[0,$NUM_BTNS$] } | PS2joystick; } // ULX3S BUTTONS AND/OR KEYBOARD AS A JOYSTICK
                // PS2
                case 12h110: { readData = PS2inavailable; }
                case 12h112: {
                    switch( PS2inavailable ) {
                        case 1: { readData = PS2inchar; PS2inread = 2b11; }
                        case 0: { readData = 0; }
                    }
                }

                // SDCARD
                case 12h140: { readData = SDCARDready; }
                case 12h150: { readData = bufferdata; }
$$end
                case 12h130: { readData = leds; }

                // SMT STATUS
                case 12hffe: { readData = SMTRUNNING; }

                // RETURN NULL VALUE
                default: { readData = 0; }
            }
        }

        // WRITE IO Memory
        if( memoryWrite ) {
            switch( memoryAddress ) {
                // UART, LEDS
                case 12h130: { leds = writeData; }
                $$if not SIMULATION then
                case 12h100: { UARToutchar = writeData[0,8]; UARToutwrite = 2b11; }
                case 12h110: { PS2outputascii = writeData; }

                // SDCARD
                case 12h140: { SDCARDreadsector = 1; }
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
    }

    // DISBLE SMT ON STARTUP
    if( ~reset ) {
        SMTRUNNING = 0;
        SMTSTARTPC = 0;
    }

$$if not SIMULATION then
    // KEYBOARD DEFAULTS TO JOYSTICK MODE
    PS2outputascii = 0;
$$end
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
    uint16  frequency = uninitialized;
    uint16  duration = uninitialized;
    uint2   apu_write = uninitialized;
    audio apu_processor <@clock_25mhz> (
        staticGenerator <: static4bit,
        audio_l :> audio_l,
        audio_active_l :> audio_active_l,
        audio_r :> audio_r,
        audio_active_r :> audio_active_r,
        waveform <: waveform,
        frequency <: frequency,
        duration <: duration,
        apu_write <: apu_write
    );

    // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always {
        // READ IO Memory
        if( memoryRead ) {
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
                    case 12h102: { frequency = writeData; }
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
    input   uint16  frequency,
    input   uint16  duration,
    input   uint2   apu_write,
    output  uint4   audio_l,
    output  uint1   audio_active_l,
    output  uint4   audio_r,
    output  uint1   audio_active_r
) <autorun> {
    // Left and Right audio channels
    uint4   Lwaveform = uninitialized;
    uint16  Lfrequency = uninitialized;
    uint16  Lduration = uninitialized;
    uint1   Lapu_write = uninitialized;
    apu apu_processor_L(
        staticGenerator <: staticGenerator,
        audio_output :> audio_l,
        audio_active :> audio_active_l,
        waveform <: Lwaveform,
        frequency <: Lfrequency,
        duration <: Lduration,
        apu_write <: Lapu_write
    );
    uint4   Rwaveform = uninitialized;
    uint16  Rfrequency = uninitialized;
    uint16  Rduration = uninitialized;
    uint1   Rapu_write = uninitialized;
    apu apu_processor_R(
        staticGenerator <: staticGenerator,
        audio_output :> audio_r,
        audio_active :> audio_active_r,
        waveform <: Rwaveform,
        frequency <: Rfrequency,
        duration <: Rduration,
        apu_write <: Rapu_write
    );

    Lapu_write := 0; Rapu_write := 0;

    always {
        switch( apu_write ) {
            default: {}
            case 1: {
                Lwaveform = waveform;
                Lfrequency = frequency;
                Lduration = duration;
                Lapu_write = 1;
            }
            case 2: {
                Rwaveform = waveform;
                Rfrequency = frequency;
                Rduration = duration;
                Rapu_write = 1;
            }
            case 3: {
                Lwaveform = waveform;
                Lfrequency = frequency;
                Lduration = duration;
                Lapu_write = 1;
                Rwaveform = waveform;
                Rfrequency = frequency;
                Rduration = duration;
                Rapu_write = 1;
            }
        }
    }
}

// UART BUFFER CONTROLLER
// 256 entry FIFO queue
algorithm fifo8(
    output  uint1   available,
    output  uint1   full,
    input   uint1   read,
    input   uint1   write,
    output  uint8   first,
    input   uint8   last
) <autorun> {
    simple_dualport_bram uint8 queue[256] = uninitialized;
    uint1   update = uninitialized;
    uint8   top = 0;
    uint8   next = 0;

    available := ( top != next ); full := ( top + 1 == next );
    queue.addr0 := next; first := queue.rdata0;
    queue.wenable1 := 1;

    always {
        if( write ) {
            queue.addr1 = top; queue.wdata1 = last;
            update = 1;
        } else {
            if( update ) {
                top = top + 1;
                update = 0;
            }
        }
        next = next + read;
    }
}
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
    uart_in ui; uart_receiver urecv( io <:> ui, uart_rx <: uart_rx );
    uint8   uidata_out <: ui.data_out;
    uint1   uidata_out_ready <: ui.data_out_ready;
    fifo8 IN(
        available :> inavailable,
        first :> inchar,
        read <: inread,
        last <: uidata_out,
        write <: uidata_out_ready
    );

    uart_out uo; uart_sender usend( io <:> uo, uart_tx :> uart_tx );
    uint8   uodata_in = uninitialized;
    uint1   OUTavailable = uninitialized;
    uint1   OUTread <: OUTavailable & !uo.busy;
    fifo8 OUT(
        available :> OUTavailable,
        full :> outfull,
        last <: outchar,
        write <: outwrite,
        first :> uodata_in,
        read <: OUTread
    );
    uo.data_in := uodata_in;
    uo.data_in_ready := OUTavailable & ( !uo.busy );
}

// PS2 BUFFER CONTROLLER
// 9 bit 256 entry FIFO buffer
algorithm fifo9(
    output  uint1   available,
    output  uint1   full,
    input   uint1   read,
    input   uint1   write,
    output  uint9   first,
    input   uint9   last
) <autorun> {
    simple_dualport_bram uint9 queue[256] = uninitialized;
    uint1   update = uninitialized;
    uint8   top = 0;
    uint8   next = 0;

    available := ( top != next ); full := ( top + 1 == next );
    queue.addr0 := next; first := queue.rdata0;
    queue.wenable1 := 1;

    always {
        if( write ) {
            queue.addr1 = top; queue.wdata1 = last;
            update = 1;
        } else {
            if( update ) {
                top = top + 1;
                update = 0;
            }
        }
        next = next + read;
    }
}
algorithm ps2buffer(
    // USB for PS/2
    input   uint1   us2_bd_dp,
    input   uint1   us2_bd_dn,
    output  uint9   inchar,
    output  uint1   inavailable,
    input   uint1   inread,
    input   uint1   outputascii,
    output  uint16  joystick
) <autorun> {
    // PS/2 input FIFO (256 character)
    fifo9 FIFO(
        available :> inavailable,
        read <: inread,
        write <: PS2asciivalid,
        first :> inchar,
        last <: PS2ascii
    );

    // PS 2 ASCII
    uint1   PS2asciivalid = uninitialized;
    uint9   PS2ascii = uninitialized;
    ps2ascii PS2(
        us2_bd_dp <: us2_bd_dp,
        us2_bd_dn <: us2_bd_dn,
        asciivalid :> PS2asciivalid,
        ascii :> PS2ascii,
        outputascii <: outputascii,
        joystick :> joystick
    );
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
    simple_dualport_bram uint8 sdbuffer[512] = uninitialized;
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
