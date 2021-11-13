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
) <autorun>{
$$if not SIMULATION then
    // UART CONTROLLER, CONTAINS BUFFERS FOR INPUT/OUTPUT
    uint2   UARTinread = 0;                                                                                                         // 2 BIT LATCH ( bit 0 is the signal ) due to clock boundary change
    uint2   UARToutwrite = 0;                                                                                                       // 2 BIT LATCH ( bit 0 is the signal )
    uart UART <@clock_25mhz> ( uart_tx :> uart_tx, uart_rx <: uart_rx, inread <: UARTinread[0,1], outwrite <: UARToutwrite[0,1] );

    // PS2 CONTROLLER, CONTAINS BUFFERS FOR INPUT/OUTPUT
    uint2   PS2inread = 0;                                                                                                          // 2 BIT LATCH ( bit 0 is the signal )
    ps2buffer PS2 <@clock_25mhz> ( us2_bd_dp <: us2_bd_dp, us2_bd_dn <: us2_bd_dn, inread <: PS2inread[0,1] );

    // SDCARD AND BUFFER
    uint1   SDCARDreadsector = uninitialized;
    uint32  SDCARDsectoraddress = uninitialized;
    uint9   SDCARDbufferaddress = uninitialized;
    sdcardbuffer SDCARD( sd_clk :> sd_clk, sd_mosi :> sd_mosi, sd_csn :> sd_csn, sd_miso <: sd_miso , readsector <: SDCARDreadsector, sectoraddress <: SDCARDsectoraddress, bufferaddress <: SDCARDbufferaddress );

    // I/O FLAGS
    SDCARDreadsector := 0;
$$end
     always {
$$if not SIMULATION then
        // UPDATE LATCHES
        UARTinread = UARTinread[1,1]; UARToutwrite = UARToutwrite[1,1]; PS2inread = PS2inread[1,1];
$$end

        // READ IO Memory
        if( memoryRead ) {
            switch( memoryAddress[4,4] ) {
                $$if not SIMULATION then
                case 4h0: {
                    if( memoryAddress[1,1] ) {
                        readData = { 14b0, UART.outfull, UART.inavailable };
                    } else {
                        readData = { 8b0, UART.inchar }; UARTinread = 2b11;
                    }
                }
                case 4h1: {
                    if( memoryAddress[1,1] ) {
                        if( PS2.inavailable ) {
                            readData = PS2.inchar; PS2inread = 2b11;
                        } else {
                            readData = 0;
                        }
                    } else {
                        readData = PS2.inavailable;
                    }
                }
                case 4h2: { readData = PS2.outputascii ? { $16-NUM_BTNS$b0, btns[0,$NUM_BTNS$] } : { $16-NUM_BTNS$b0, btns[0,$NUM_BTNS$] } | PS2.joystick; }
                case 4h4: { readData = SDCARD.ready; }
                case 4h5: { readData = SDCARD.bufferdata; }
                $$end
                case 4h3: { readData = leds; }
                case 4hf: { readData = SMTRUNNING; }
                default: { readData = 0;}
            }
        }

        // WRITE IO Memory
        if( memoryWrite ) {
            switch( memoryAddress[4,4] ) {
                $$if not SIMULATION then
                case 4h0: { UART.outchar = writeData[0,8]; UARToutwrite = 2b11; }
                case 4h1: { PS2.outputascii = writeData; }
                case 4h4: {
                    switch( memoryAddress[1,2] ) {
                        case 2h0: { SDCARDreadsector = 1; }
                        default: { SDCARDsectoraddress[ { memoryAddress[1,1], 4b0000 }, 16 ] = writeData; }
                    }
                }
                case 4h5: { SDCARDbufferaddress = writeData; }
                $$end
                case 4h3: { leds = writeData; }
                case 4hf: {
                    switch( memoryAddress[2,1] ) {
                        case 1b0: { SMTSTARTPC[ { ~memoryAddress[1,1], 4b0000 }, 16 ] = writeData; }
                        case 1b1: { SMTRUNNING = writeData; }
                    }
                }
                default: {}
            }
        }
    }

    // DISBLE SMT ON STARTUP, KEYBOARD DEFAULTS TO JOYSTICK MODE
    if( ~reset ) {
        SMTRUNNING = 0;
        SMTSTARTPC = 0;

        $$if not SIMULATION then
        PS2.outputascii = 0;
        $$end
    }

}

algorithm timers_memmap(
    // CLOCKS
    input   uint1   clock_25mhz,

    // Memory access
    input   uint9   memoryAddress,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,
    input   uint16  writeData,
    output  uint16  readData,

    // RNG
    output  uint16  static16bit
) <autorun,reginputs> {
    // TIMERS and RNG
    timers_rng timers <@clock_25mhz> ( g_noise_out :> static16bit );
    uint3   timerreset <:: memoryAddress[1,3] + 1;
    uint32  floatrng <:: { 1b0, 5b01111, &timers.u_noise_out[0,3] ? 3b110 : timers.u_noise_out[0,3], timers.g_noise_out[0,16], timers.u_noise_out[3,7] };

    // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always {
        // READ IO Memory
        if( memoryRead ) {
            switch( memoryAddress[1,4] ) {
                // RNG ( 2 interger, 1 float 0 <= fng < 1 ) and TIMERS
                case 4h0: { readData = timers.g_noise_out; }
                case 4h1: { readData = timers.u_noise_out; }
                case 4h2: { readData = floatrng[0,16]; }
                case 4h3: { readData = floatrng[16,16]; }
                case 4h8: { readData = timers.timer1hz0; }
                case 4h9: { readData = timers.timer1hz1; }
                case 4ha: { readData = timers.timer1khz0; }
                case 4hb: { readData = timers.timer1khz1; }
                case 4hc: { readData = timers.sleepTimer0; }
                case 4hd: { readData = timers.sleepTimer1; }
                case 4he: { readData = timers.systemclock; }
                // RETURN NULL VALUE
                default: { readData = 0; }
            }
        }
        // WRITE IO Memory
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: { timers.counter = writeData; timers.resetcounter = timerreset; }
            case 2b00: { timers.resetcounter = 0; }
            default: {}
        }
        LATCHmemoryWrite = memoryWrite;
    }
}

algorithm audio_memmap(
    // CLOCKS
    input   uint1   clock_25mhz,

    // Memory access
    input   uint9   memoryAddress,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,
    input   uint16  writeData,
    output  uint16  readData,

    // AUDIO
    output  uint4   audio_l,
    output  uint4   audio_r,

    // RNG
    input  uint4   static4bit
) <autorun,reginputs> {
    // Left and Right audio channels
    audio apu_processor <@clock_25mhz> ( staticGenerator <: static4bit, audio_l :> audio_l, audio_r :> audio_r );

    // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always {
        // READ IO Memory
        if( memoryRead ) { readData = memoryAddress[1,1] ? apu_processor.audio_active_r : apu_processor.audio_active_l; }

        // WRITE IO Memory
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                switch( memoryAddress[1,2] ) {
                    case 2h0: { apu_processor.waveform = writeData; }
                    case 2h1: { apu_processor.frequency = writeData; }
                    case 2h2: { apu_processor.duration = writeData; }
                    case 2h3: { apu_processor.apu_write = writeData; }
                }
            }
            case 2b00: { apu_processor.apu_write = 0; }
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
) <autorun,reginputs> {
    // RNG random number generator
    random rng( u_noise_out :> u_noise_out,  g_noise_out :> g_noise_out );

    // 1hz timers (P1 used for systemClock, T1hz0 and T1hz1 for user purposes)
    pulse1hz P1( counter1hz :> systemclock );
    pulse1hz T1hz0( counter1hz :> timer1hz0 );
    pulse1hz T1hz1( counter1hz :> timer1hz1 );

    // 1khz timers (sleepTimers used for sleep command, timer1khzs for user purposes)
    pulse1khz T0khz0( counter1khz :> timer1khz0 );
    pulse1khz T1khz1( counter1khz :> timer1khz1 );
    pulse1khz STimer0( counter1khz :> sleepTimer0 );
    pulse1khz STimer1( counter1khz :> sleepTimer1 );

    T1hz0.resetCounter := 0; T1hz1.resetCounter := 0;
    T0khz0.resetCounter := 0; T1khz1.resetCounter := 0;
    STimer0.resetCounter := 0; STimer1.resetCounter := 0;

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

    P1.resetCounter = 0;
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
) <autorun,reginputs> {
    // Left and Right audio channels
    apu apu_processor_L(
        staticGenerator <: staticGenerator,
        audio_output :> audio_l,
        audio_active :> audio_active_l,
        waveform <: waveform,
        frequency <: frequency,
        duration <: duration,
        apu_write <: apu_write[0,1]
    );
    apu apu_processor_R(
        staticGenerator <: staticGenerator,
        audio_output :> audio_r,
        audio_active :> audio_active_r,
        waveform <: waveform,
        frequency <: frequency,
        duration <: duration,
        apu_write <: apu_write[1,1]
    );
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
) <autorun,reginputs> {
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
    uint1   OUTread <: OUT.available & !uo.busy;
    fifo8 OUT(
        full :> outfull,
        last <: outchar,
        write <: outwrite,
        first :> uodata_in,
        read <: OUTread
    );
    uo.data_in := uodata_in;
    uo.data_in_ready := OUT.available & ( !uo.busy );
}

// PS2 BUFFER CONTROLLER
// 9 bit 256 entry FIFO buffer
algorithm fifo9(
    output  uint1   available,
    input   uint1   read,
    input   uint1   write,
    output  uint9   first,
    input   uint9   last
) <autorun,reginputs> {
    simple_dualport_bram uint9 queue[256] = uninitialized;
    uint8   top = 0;
    uint8   next = 0;

    available := ( top != next );
    queue.addr0 := next; first := queue.rdata0;
    queue.wenable1 := 1;

    always {
        if( write ) { queue.addr1 = top; queue.wdata1 = last; }
        top = top + write;
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
    // PS/2 input FIFO (256 character) - 9 bit to deal with special characters
    fifo9 FIFO( available :> inavailable, read <: inread, write <: PS2.asciivalid, first :> inchar, last <: PS2.ascii );

    // PS 2 KEYCODE TO ASCII CONVERTER AND JOYSTICK EMULATION MAPPER
    ps2ascii PS2( us2_bd_dp <: us2_bd_dp, us2_bd_dn <: us2_bd_dn, outputascii <: outputascii, joystick :> joystick );
}

// SDCARD AND BUFFER CONTROLLER
algorithm sdcardbuffer(
    // SDCARD
    output  uint1   sd_clk,
    output  uint1   sd_mosi,
    output  uint1   sd_csn,
    input   uint1   sd_miso,

    input   uint1   readsector,
    input   uint32  sectoraddress,
    input   uint9   bufferaddress,
    output  uint1   ready,
    output  uint8   bufferdata
) <autorun> {
    // SDCARD - Code for the SDCARD from @sylefeb
    simple_dualport_bram uint8 sdbuffer[512] = uninitialized;
    sdcardio sdcio;
    sdcard sd( sd_clk :> sd_clk, sd_mosi :> sd_mosi, sd_csn :> sd_csn, sd_miso <: sd_miso, io <:> sdcio, store <:> sdbuffer );

    // SDCARD Commands
    sdcio.read_sector := readsector;
    sdcio.addr_sector := sectoraddress;
    sdbuffer.addr0 := bufferaddress;
    ready := sdcio.ready;
    bufferdata := sdbuffer.rdata0;
}
