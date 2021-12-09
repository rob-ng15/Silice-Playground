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
    uint1   sdramwriteflag = uninitialized;
    uint1   sdramreadflag = uninitialized;
    // SDRAM and BRAM (for BIOS)
    // FUNCTION3 controls byte read/writes
    sdramcontroller sdram(
        sio <:> sio,
        address <: sdramaddress,
        writedata <: sdramwritedata,
        writeflag <: sdramwriteflag,
        readflag <: sdramreadflag
    );

$$if not SIMULATION then
    // UART CONTROLLER, CONTAINS BUFFERS FOR INPUT/OUTPUT
    uint2   UARTinread = 0;                                                                                                         // 2 BIT LATCH ( bit 0 is the signal ) due to clock boundary change
    uint2   UARToutwrite = 0;                                                                                                       // 2 BIT LATCH ( bit 0 is the signal )
    uart_IN UART_IN <@clock_25mhz> ( uart_rx <: uart_rx, inread <: UARTinread[0,1] );
    uart_OUT UART_OUT <@clock_25mhz> ( uart_tx :> uart_tx, outwrite <: UARToutwrite[0,1] );

    // PS2 CONTROLLER, CONTAINS BUFFERS FOR INPUT/OUTPUT
    uint2   PS2inread = 0;
    ps2buffer PS2 <@clock_25mhz> (
        us2_bd_dp <: us2_bd_dp,
        us2_bd_dn <: us2_bd_dn,
        inread <: PS2inread[0,1]
    );

    // SDCARD AND BUFFER
    uint16  sectoraddressH = uninitialized;
    uint16  sectoraddressL = uninitialized;
    uint9   bufferaddress = uninitialized;
    uint1   SDCARDreadsector = uninitialized;
    sdcardbuffer SDCARD(
        sd_clk :> sd_clk,
        sd_mosi :> sd_mosi,
        sd_csn :> sd_csn,
        sd_miso <: sd_miso,
        sectoraddressH <: sectoraddressH,
        sectoraddressL <: sectoraddressL,
        bufferaddress <: bufferaddress,
        readsector <: SDCARDreadsector
    );
    SDCARDreadsector := 0;
$$end

    sdramwriteflag := 0; sdramreadflag := 0;

    always_before {
$$if not SIMULATION then
        // UPDATE LATCHES
        UARTinread = UARTinread[1,1]; UARToutwrite = UARToutwrite[1,1]; PS2inread = PS2inread[1,1];
$$end
        // READ IO Memory
        if( memoryRead ) {
            switch( memoryAddress ) {
                // UART/PS2, LEDS, BUTTONS
                $$if not SIMULATION then
                case 12h100: {
                    switch( { PS2.inavailable, UART_IN.inavailable } ) {
                        case 2b00: { readData = 0; }
                        case 2b01: { readData = { 8b0, UART_IN.inchar }; UARTinread = 2b11; }
                        default: { readData = { 8b0, PS2.inchar }; PS2inread = 2b11; }
                    }
                }
                case 12h102: { readData = { 14b0, UART_OUT.outfull, ( UART_IN.inavailable | PS2.inavailable ) }; }
                case 12h120: { readData = { $16-NUM_BTNS$b0, btns[0,$NUM_BTNS$] }; }

                // SDCARD
                case 12h140: { readData = SDCARD.ready; }
                case 12h150: { readData = SDCARD.bufferdata; }
                $$end
                case 12h130: { readData = leds; }
                // SDRAM
                case 12hf00: { readData = sdram.readdata; }
                case 12hf02: { readData = sdram.busy; }

                // RETURN NULL VALUE
                default: { readData = 0; }
            }
        }
    }
    always_after {
        // WRITE IO Memory
        if( memoryWrite ) {
            switch( memoryAddress ) {
                // UART, LEDS
                case 12h130: { leds = writeData; }
                $$if not SIMULATION then
                case 12h100: { UART_OUT.outchar = writeData[0,8]; UARToutwrite = 2b11; }

                // SDCARD
                case 12h140: { SDCARDreadsector = 1; }
                case 12h142: { sectoraddressH = writeData; }
                case 12h144: { sectoraddressL = writeData; }
                case 12h150: { bufferaddress = writeData; }
                $$end
                // SDRAM
                case 12hf00: { sdramwritedata = writeData; }
                case 12hf02: { sdramreadflag = writeData[0,1]; sdramwriteflag = writeData[1,1]; }
                case 12hf04: { sdramaddress[16,8] = writeData; }
                case 12hf05: { sdramaddress[0,16] = writeData; }
                default: {}
            }
        }
    }
    if( ~reset ) {
        $$if not SIMULATION then
        PS2.outputascii = 1;
        $$end
    }
}

algorithm copro_memmap(
    // Memory access
    input   uint12  memoryAddress,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,

    input   uint16  writeData,
    output  uint16  readData
) <autorun,reginputs> {
    // HIGH LOW ADDRESS SWITCH
    uint5   hilow <:: { ~memoryAddress[0,1], 4b0000 };

    // Mathematics Co-Processors
    divmod32by16 divmod32by16to16qr(); divmod16by16 divmod16by16to16qr(); multi16by16to32DSP multiplier16by16to32(); doubleops doperations(); floatops fpu();

    // RESET Mathematics Co-Processor Controls
    divmod32by16to16qr.start := 0; divmod16by16to16qr.start := 0; multiplier16by16to32.start := 0; fpu.start := 0;

    always_before {
        // READ IO Memory
        if( memoryRead ) {
            if( memoryAddress[8,1] ) {
                switch( memoryAddress[0,5] ) {
                    case 5h02: { readData = fpu.busy; }
                    case 5h10: { readData = fpu.itof; }
                    case 5h11: { readData = fpu.ftoi; }
                    case 5h12: { readData = fpu.fadd; }
                    case 5h13: { readData = fpu.fsub; }
                    case 5h14: { readData = fpu.fmul; }
                    case 5h15: { readData = fpu.fdiv; }
                    case 5h16: { readData = fpu.fsqrt; }
                    case 5h17: { readData = fpu.less; }
                    case 5h18: { readData = fpu.equal; }
                    case 5h19: { readData = fpu.lessequal; }
                    default: { readData = 0; }
                }
            } else {
                switch( memoryAddress[4,3] ) {
                    case 3h0: {
                        switch( memoryAddress[1,3] ) {
                            case 3h0: { readData = doperations.total[ hilow, 16 ]; }
                            case 3h1: { readData = doperations.difference[ hilow, 16 ]; }
                            case 3h2: { readData = doperations.increment[ hilow, 16 ]; }
                            case 3h3: { readData = doperations.decrement[ hilow, 16 ]; }
                            case 3h4: { readData = doperations.times2[ hilow, 16 ]; }
                            case 3h5: { readData = doperations.divide2[ hilow, 16 ]; }
                            case 3h6: { readData = doperations.negation[ hilow, 16 ]; }
                            case 3h7: { readData = doperations.binaryinvert[ hilow, 16 ]; }
                        }
                    }
                    case 3h1: {
                        switch( memoryAddress[1,3] ) {
                            case 3h0: { readData = doperations.binaryxor[ hilow, 16 ]; }
                            case 3h1: { readData = doperations.binaryand[ hilow, 16 ]; }
                            case 3h2: { readData = doperations.binaryor[ hilow, 16 ]; }
                            case 3h3: { readData = doperations.absolute[ hilow, 16 ]; }
                            case 3h4: { readData = doperations.maximum[ hilow, 16 ]; }
                            case 3h5: { readData = doperations.minimum[ hilow, 16 ]; }
                            case 3h6: { readData = memoryAddress[0,1] ? doperations.zeroless : doperations.zeroequal; }
                            case 3h7: { readData = memoryAddress[0,1] ? doperations.lessthan : doperations.equal; }
                        }
                    }
                    case 3h2: {
                        switch( memoryAddress[0,3] ) {
                            case 3h0: { readData = divmod32by16to16qr.quotient[0,16]; }
                            case 3h1: { readData = divmod32by16to16qr.remainder[0,16]; }
                            case 3h3: { readData = divmod32by16to16qr.active; }
                            case 3h4: { readData = divmod16by16to16qr.quotient; }
                            case 3h5: { readData = divmod16by16to16qr.remainder; }
                            case 3h6: { readData = divmod16by16to16qr.active; }
                            default: { readData = 0; }
                        }
                    }
                    case 3h3: { readData = multiplier16by16to32.product[ hilow, 16 ]; }
                    default: {}
                }
            }
        }
    }
    always_after {
        // WRITE IO Memory
        if( memoryWrite ) {
            if( memoryAddress[8,1] ) {
                switch( memoryAddress[0,2] ) {
                    case 2h0: { fpu.a = writeData; }
                    case 2h1: { fpu.b = writeData; }
                    case 2h2: { fpu.start = writeData; }
                    default: {}
                }
            } else {
                switch( memoryAddress[4,2] ) {
                    case 2h0: {
                        if( memoryAddress[1,1] ) {
                            doperations.operand2[ hilow, 16 ] = writeData;
                        } else {
                            doperations.operand1[ hilow, 16 ] = writeData;
                        }
                    }
                    case 2h1: {}
                    case 2h2: {
                        switch( memoryAddress[0,3] ) {
                            case 3h0: { divmod32by16to16qr.dividend[16,16] = writeData; }
                            case 3h1: { divmod32by16to16qr.dividend[0,16] = writeData; }
                            case 3h2: { divmod32by16to16qr.divisor = writeData; }
                            case 3h3: { divmod32by16to16qr.start = writeData; }
                            case 3h4: { divmod16by16to16qr.dividend = writeData; }
                            case 3h5: { divmod16by16to16qr.divisor = writeData; }
                            case 3h6: { divmod16by16to16qr.start = writeData; }
                            default: {}
                        }
                    }
                    case 2h3: {
                        switch( memoryAddress[0,2] ) {
                            case 2h0: { multiplier16by16to32.factor1 = writeData; }
                            case 2h1: { multiplier16by16to32.factor2 = writeData; }
                            case 2h2: { multiplier16by16to32.start = writeData; }
                            default: {}
                        }
                    }
                }
            }
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
) <autorun,reginputs> {
    // TIMERS and RNG
    timers_rng timers <@clock_25mhz> ();

    // Left and Right audio channels
    audio apu_processor <@clock_25mhz> ( staticGenerator <: timers.u_noise_out[0,4], audio_l :> audio_l, audio_r :> audio_r );

    // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always_before {
        // READ IO Memory
        if( memoryRead ) {
            if( memoryAddress[8,1] ) {
                readData = memoryAddress[1,1] ? apu_processor.audio_active_r : apu_processor.audio_active_l;
            } else {
                switch( memoryAddress[1,4] ) {
                    // RNG ( 2 interger ) and TIMERS
                    case 4h0: { readData = timers.g_noise_out; }
                    case 4h1: { readData = timers.u_noise_out; }
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
        }
    }
    always_after {
        // WRITE IO Memory
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                if( memoryAddress[8,1] ) {
                    // AUDIO
                    switch( memoryAddress[1,2] ) {
                        case 2h0: { apu_processor.waveform = writeData; }
                        case 2h1: { apu_processor.note = writeData; }
                        case 2h2: { apu_processor.duration = writeData; }
                        case 2h3: { apu_processor.apu_write = writeData; }
                    }
                } else {
                    // TIMERS and RNG
                     timers.counter = writeData; timers.resetcounter = memoryAddress[1,3] + 1;
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

    always_after {
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
    input   uint7   note,
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
        note <: note,
        duration <: duration,
        apu_write <: apu_write[0,1]
    );
    apu apu_processor_R(
        staticGenerator <: staticGenerator,
        audio_output :> audio_r,
        audio_active :> audio_active_r,
        waveform <: waveform,
        note <: note,
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
algorithm uart_IN(
    // UART
    input   uint1   uart_rx,
    output  uint1   inavailable,
    output  uint8   inchar,
    input   uint1   inread
) <autorun> {
    uart_in ui; uart_receiver urecv( io <:> ui, uart_rx <: uart_rx );
    fifo8 IN(
        available :> inavailable,
        first :> inchar,
        read <: inread,
        last <: ui.data_out,
        write <: ui.data_out_ready
    );
}
algorithm uart_OUT(
    // UART
    output  uint1   uart_tx,
    output  uint1   outfull,
    input   uint8   outchar,
    input   uint1   outwrite
) <autorun> {
    uart_out uo; uart_sender usend( io <:> uo, uart_tx :> uart_tx );
    fifo8 OUT(
        full :> outfull,
        last <: outchar,
        write <: outwrite,
        first :> uo.data_in
    );
    OUT.read := OUT.available & !uo.busy;
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
) <autorun> {
    simple_dualport_bram uint9 queue[256] = uninitialized;
    uint8   top = 0;
    uint8   next = 0;

    available := ( top != next );
    queue.addr0 := next; first := queue.rdata0;
    queue.wenable1 := 1;

    always_after {
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
    input   uint16  sectoraddressH,
    input   uint16  sectoraddressL,
    input   uint9   bufferaddress,
    output  uint1   ready,
    output  uint8   bufferdata
) <autorun> {
    // SDCARD - Code for the SDCARD from @sylefeb
    simple_dualport_bram uint8 sdbuffer[512] = uninitialized;
    sdcardio sdcio; sdcard sd( sd_clk :> sd_clk, sd_mosi :> sd_mosi, sd_csn :> sd_csn, sd_miso <: sd_miso, io <:> sdcio, store <:> sdbuffer );

    // SDCARD Commands
    always_after {
        sdcio.read_sector = readsector;
        sdcio.addr_sector = { sectoraddressH, sectoraddressL };
        sdbuffer.addr0 = bufferaddress;
        ready = sdcio.ready;
        bufferdata = sdbuffer.rdata0;
    }
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
    sio.addr := { address, 1b0 }; sio.in_valid := ( readflag | writeflag );
    sio.data_in := writedata; sio.rw := writeflag;
    readdata := sio.data_out;

    always {
        if( readflag | writeflag ) { busy = 1; }
        if( sio.done ) { busy = 0; }
    }
}
