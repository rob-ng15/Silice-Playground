algorithm memmap_io (
    // LEDS (8 of)
    output  uint8   leds,
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

    // AUDIO
    output  uint4   audio_l,
    output  uint4   audio_r,

    // SDCARD
    output  uint1   sd_clk,
    output  uint1   sd_mosi,
    output  uint1   sd_csn,
    input   uint1   sd_miso,

    // HDMI OUTPUT
    output  uint4   gpdi_dp,

    // CLOCKS
    input   uint1   clock_25mhz,
    input   uint1   video_clock,
    input   uint1   video_reset,
    input   uint1   gpu_clock,
    input   uint1   clock_usb,

    // Memory access
    input   uint32  memoryAddress,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,

    input   uint16  writeData,
    output  uint16  readData,

    // SMT STATUS
    output  uint1   SMTRUNNING,
    output  uint32  SMTSTARTPC
) <autorun> {
    // 16bit and 8bit addresses
    uint8   address8l <: memoryAddress[0,8];
    uint8   address8h <: memoryAddress[8,8];
    uint16  address16 <: memoryAddress[0,16];

    // TIMERS and RANDOM NUMBER GENERATOR
    uint16  staticGenerator = uninitialized;
    uint16  staticGeneratorALT = uninitialized;
    uint1   static1bit <: staticGenerator[0,1];
    uint2   static2bit <: staticGenerator[0,2];
    uint4   static4bit <: staticGenerator[0,4];
    uint6   static6bit <: staticGenerator[0,6];
    timers_memory TIMERS(
        clock_25mhz <: clock_25mhz,
        memoryAddress <: address8l,
        writeData <: writeData
    );

    // AUDIO
    audio_memory AUDIO(
        clock_25mhz <: clock_25mhz,
        static4bit <: static4bit,
        memoryAddress <: address8l,
        writeData <: writeData,
        audio_l :> audio_l,
        audio_r :> audio_r
    );

    // IO
    io_memory IO(
        clock_25mhz <: clock_25mhz,
        memoryAddress <: address8l,
        writeData <: writeData,

        uart_rx <: uart_rx,
        uart_tx :> uart_tx,
        us2_bd_dp <: us2_bd_dp,
        us2_bd_dn <: us2_bd_dn,

        sd_clk :> sd_clk,
        sd_mosi :> sd_mosi,
        sd_csn :> sd_csn,
        sd_miso <: sd_miso,

        leds :> leds,
        btns <:: btns
    );

    // HDMI driver
    // Status of the screen, if in range, if in vblank, actual pixel x and y
    uint1   vblank = uninitialized;
    uint1   pix_active = uninitialized;
    uint10  pix_x  = uninitialized;
    uint10  pix_y  = uninitialized;
    uint8   video_r = uninitialized;
    uint8   video_g = uninitialized;
    uint8   video_b = uninitialized;
    hdmi video<@clock_25mhz,!reset> (
        vblank  :> vblank,
        active  :> pix_active,
        x       :> pix_x,
        y       :> pix_y,
        gpdi_dp :> gpdi_dp,
        red     <: video_r,
        green   <: video_g,
        blue    <: video_b
    );

    // CREATE DISPLAY LAYERS
    // BACKGROUND
    uint2   background_r = uninitialized;
    uint2   background_g = uninitialized;
    uint2   background_b = uninitialized;
    background_memory BACKGROUND(
        video_clock <: video_clock,
        video_reset <: video_reset,
        memoryAddress <: address8l,
        writeData <: writeData,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pix_red    :> background_r,
        pix_green  :> background_g,
        pix_blue   :> background_b,
        staticGenerator <: static2bit
    );

    // Tilemaps - Lower and Upper
    uint2   lower_tilemap_r = uninitialized;
    uint2   lower_tilemap_g = uninitialized;
    uint2   lower_tilemap_b = uninitialized;
    uint1   lower_tilemap_display = uninitialized;
    uint2   upper_tilemap_r = uninitialized;
    uint2   upper_tilemap_g = uninitialized;
    uint2   upper_tilemap_b = uninitialized;
    uint1   upper_tilemap_display = uninitialized;
    tilemap_memory LOWER_TILEMAP(
        video_clock <: video_clock,
        video_reset <: video_reset,
        memoryAddress <: address8l,
        writeData <: writeData,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pix_red    :> lower_tilemap_r,
        pix_green  :> lower_tilemap_g,
        pix_blue   :> lower_tilemap_b,
        pix_display :> lower_tilemap_display,
    );
    tilemap_memory UPPER_TILEMAP(
        video_clock <: video_clock,
        video_reset <: video_reset,
        memoryAddress <: address8l,
        writeData <: writeData,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pix_red    :> upper_tilemap_r,
        pix_green  :> upper_tilemap_g,
        pix_blue   :> upper_tilemap_b,
        pix_display :> upper_tilemap_display,
    );

    // Bitmap Window with GPU
    uint1   bitmap_display = uninitialized;
    uint2   bitmap_r = uninitialized;
    uint2   bitmap_g = uninitialized;
    uint2   bitmap_b = uninitialized;
    bitmap_memory BITMAP(
        video_clock <: video_clock,
        video_reset <: video_reset,
        memoryAddress <: address8l,
        writeData <: writeData,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pix_red    :> bitmap_r,
        pix_green  :> bitmap_g,
        pix_blue   :> bitmap_b,
        pix_display :> bitmap_display,
        static1bit <: static1bit,
        static6bit <: static6bit
   );

    // Sprite Layers - Lower and Upper
    uint2   lower_sprites_r = uninitialized;
    uint2   lower_sprites_g = uninitialized;
    uint2   lower_sprites_b = uninitialized;
    uint1   lower_sprites_display = uninitialized;
    uint2   upper_sprites_r = uninitialized;
    uint2   upper_sprites_g = uninitialized;
    uint2   upper_sprites_b = uninitialized;
    uint1   upper_sprites_display = uninitialized;
    sprite_memory LOWER_SPRITES(
        video_clock <: video_clock,
        video_reset <: video_reset,
        memoryAddress <: address8l,
        writeData <: writeData,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pix_red    :> lower_sprites_r,
        pix_green  :> lower_sprites_g,
        pix_blue   :> lower_sprites_b,
        pix_display :> lower_sprites_display,
        bitmap_display <: bitmap_display,
        lower_tilemap_display <: lower_tilemap_display,
        upper_tilemap_display <: upper_tilemap_display,
        other_spritelayer_display <: upper_sprites_display
    );
    sprite_memory UPPER_SPRITES(
        video_clock <: video_clock,
        video_reset <: video_reset,
        memoryAddress <: address8l,
        writeData <: writeData,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pix_red    :> upper_sprites_r,
        pix_green  :> upper_sprites_g,
        pix_blue   :> upper_sprites_b,
        pix_display :> upper_sprites_display,
        bitmap_display <: bitmap_display,
        lower_tilemap_display <: lower_tilemap_display,
        upper_tilemap_display <: upper_tilemap_display,
        other_spritelayer_display <: lower_sprites_display
    );

    // Character Map Window
    uint2   character_map_r = uninitialized;
    uint2   character_map_g = uninitialized;
    uint2   character_map_b = uninitialized;
    uint1   character_map_display = uninitialized;
    charactermap_memory CHARACTERMAP(
        video_clock <: video_clock,
        video_reset <: video_reset,
        memoryAddress <: address8l,
        writeData <: writeData,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pix_red    :> character_map_r,
        pix_green  :> character_map_g,
        pix_blue   :> character_map_b,
        pix_display :> character_map_display
    );

    // Combine the display layers for display
    multiplex_display display <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pix_red    :> video_r,
        pix_green  :> video_g,
        pix_blue   :> video_b,

        background_r <: background_r,
        background_g <: background_g,
        background_b <: background_b,

        lower_tilemap_r <: lower_tilemap_r,
        lower_tilemap_g <: lower_tilemap_g,
        lower_tilemap_b <: lower_tilemap_b,
        lower_tilemap_display <: lower_tilemap_display,

        upper_tilemap_r <: upper_tilemap_r,
        upper_tilemap_g <: upper_tilemap_g,
        upper_tilemap_b <: upper_tilemap_b,
        upper_tilemap_display <: upper_tilemap_display,

        lower_sprites_r <: lower_sprites_r,
        lower_sprites_g <: lower_sprites_g,
        lower_sprites_b <: lower_sprites_b,
        lower_sprites_display <: lower_sprites_display,

        upper_sprites_r <: upper_sprites_r,
        upper_sprites_g <: upper_sprites_g,
        upper_sprites_b <: upper_sprites_b,
        upper_sprites_display <: upper_sprites_display,

        bitmap_r <: bitmap_r,
        bitmap_g <: bitmap_g,
        bitmap_b <: bitmap_b,
        bitmap_display <: bitmap_display,

        character_map_r <: character_map_r,
        character_map_g <: character_map_g,
        character_map_b <: character_map_b,
        character_map_display <: character_map_display
    );

    // MEMORY MAPPED I/O FLAGS
    BACKGROUND.memoryWrite := 0; BACKGROUND.memoryRead := 0;
    LOWER_TILEMAP.memoryWrite := 0; LOWER_TILEMAP.memoryRead := 0;
    UPPER_TILEMAP.memoryWrite := 0; UPPER_TILEMAP.memoryRead := 0;
    LOWER_SPRITES.memoryWrite := 0; LOWER_SPRITES.memoryRead := 0;
    UPPER_SPRITES.memoryWrite := 0; UPPER_SPRITES.memoryRead := 0;
    CHARACTERMAP.memoryWrite := 0; CHARACTERMAP.memoryRead := 0;
    BITMAP.memoryWrite := 0; BITMAP.memoryRead := 0;
    TIMERS.memoryWrite := 0; TIMERS.memoryRead := 0;
    IO.memoryWrite := 0; IO.memoryRead := 0;
    AUDIO.memoryWrite := 0; AUDIO.memoryRead := 0;

    // DISBLE SMT ON STARTUP
    SMTRUNNING = 0;
    SMTSTARTPC = 0;

    while(1) {
        // READ IO Memory
        switch( address8h ) {
            case 8h81: { LOWER_TILEMAP.memoryRead = 1; readData = LOWER_TILEMAP.readData; }
            case 8h82: { UPPER_TILEMAP.memoryRead = 1; readData = UPPER_TILEMAP.readData;  }
            case 8h83: { LOWER_SPRITES.memoryRead = 1; readData = LOWER_SPRITES.readData; }
            case 8h84: { UPPER_SPRITES.memoryRead = 1; readData = UPPER_SPRITES.readData; }
            case 8h85: { CHARACTERMAP.memoryRead = 1; readData = CHARACTERMAP.readData; }
            case 8h86: { BITMAP.memoryRead = 1; readData = BITMAP.readData; }
            case 8hf0: { TIMERS.memoryRead = 1; readData = TIMERS.readData; }
            case 8hf1: { IO.memoryRead = 1; readData = IO.readData; }
            case 8hf2: { AUDIO.memoryRead = 1; readData = AUDIO.readData; }
            case 8hf8: { readData = vblank; }
            case 8hff: { readData = SMTRUNNING; }
            default: { readData = 0; }
        }

        // WRITE IO Memory
        switch( address8h ) {
            case 8h80: { BACKGROUND.memoryWrite = 1; }
            case 8h81: { LOWER_TILEMAP.memoryWrite = 1; }
            case 8h82: { UPPER_TILEMAP.memoryWrite = 1; }
            case 8h83: { LOWER_SPRITES.memoryWrite = 1; }
            case 8h84: { UPPER_SPRITES.memoryWrite = 1; }
            case 8h85: { CHARACTERMAP.memoryWrite = 1; }
            case 8h86: { BITMAP.memoryWrite = 1; }
            case 8hf0: { TIMERS.memoryWrite = 1; }
            case 8hf1: { IO.memoryWrite = 1; }
            case 8hf2: { AUDIO.memoryWrite = 1; }
            case 8hf8: { display.display_order = writeData; }
            case 8hff: {
                switch( address16 ) {
                    case 16hfff0: { SMTSTARTPC[16,16] = writeData; }
                    case 16hfff2: { SMTSTARTPC[0,16] = writeData; }
                    case 16hfffe: { SMTRUNNING = writeData; }
                }
            }
            default: { readData = 0; }
        }
    } // while(1)
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
    inavailable := ( uartInBufferNext != uartInBufferTop ) ? 1b1 : 1b0;
    outfull := ( uartOutBufferTop + 1 == uartOutBufferNext ) ? 1b1 : 1b0;
    inchar := uartInBuffer.rdata0;

    // UART Buffers ( code from @sylefeb )
    uartInBuffer.wenable1 := 1;  // always write on port 1
    uartInBuffer.addr0 := uartInBufferNext; // FIFO reads on next
    uartInBuffer.addr1 := uartInBufferTop;  // FIFO writes on top
    uartOutBuffer.wenable1 := 1; // always write on port 1
    uartOutBuffer.addr0 := uartOutBufferNext; // FIFO reads on next
    uartOutBuffer.addr1 := uartOutBufferTop;  // FIFO writes on top
    uartInBuffer.wdata1 := ui.data_out;
    uartInBufferTop := ui.data_out_ready ? uartInBufferTop + 1 : uartInBufferTop;
    uo.data_in := uartOutBuffer.rdata0;
    uo.data_in_ready := ( uartOutBufferNext != uartOutBufferTop ) && ( !uo.busy );
    uartOutBufferNext := ( (uartOutBufferNext != uartOutBufferTop) && ( !uo.busy ) ) ? uartOutBufferNext + 1 : uartOutBufferNext;

    while(1) {
        if( inread ) {
            uartInBufferNext = uartInBufferNext + 1;
        }
        if( outwrite ) {
            uartOutBuffer.wdata1 = outchar;
            uartOutBufferTop = uartOutBufferTop + 1;
        }
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
    ps2Buffer.addr1 := ps2BufferTop;  // FIFO writes on top
    ps2Buffer.wdata1 := PS2.ascii;
    ps2BufferTop := PS2.asciivalid ? ps2BufferTop + 1 : ps2BufferTop;

    // FLAGS
    inavailable := ( ps2BufferNext != ps2BufferTop ) ? 1 : 0;
    inchar := ps2Buffer.rdata0;

    while(1) {
        if( inread ) {
            ps2BufferNext = ps2BufferNext + 1;
        }
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

// MEMORY MAP CONTROLLER FOR TIMERS + RNG
algorithm timers_memory(
    input   uint1   clock_25mhz,
    output  uint16  staticGenerator,
    output  uint16  staticGeneratorALT,

    // Memory access
    input   uint8   memoryAddress,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,

    input   uint16  writeData,
    output  uint16  readData
) <autorun> {
    // 1hz timers (p1hz used for systemClock, timer1hz for user purposes)
    pulse1hz p1hz <@clock_25mhz> ( );
    pulse1hz timer1hz0 <@clock_25mhz> ( );
    pulse1hz timer1hz1 <@clock_25mhz> ( );

    // 1khz timers (sleepTimers used for sleep command, timer1khzs for user purposes)
    pulse1khz sleepTimer0 <@clock_25mhz> ( );
    pulse1khz timer1khz0 <@clock_25mhz> ( );
    pulse1khz sleepTimer1 <@clock_25mhz> ( );
    pulse1khz timer1khz1 <@clock_25mhz> ( );

    // RNG random number generator
    random rng <@clock_25mhz> (
        g_noise_out :> staticGenerator,
        u_noise_out :> staticGeneratorALT
    );

    // LATCH MEMORYREAD MEMORYWRITE
    uint1   LATCHmemoryRead = uninitialized;
    uint1   LATCHmemoryWrite = uninitialized;

    while(1) {
        // READ IO Memory
        if( memoryRead && ~LATCHmemoryRead ) {
            switch( memoryAddress ) {
                case 8h00: { readData = staticGenerator; }
                case 8h02: { readData = staticGeneratorALT; }
                case 8h10: { readData = timer1hz0.counter1hz; }
                case 8h12: { readData = timer1hz1.counter1hz; }
                case 8h20: { readData = timer1khz0.counter1khz; }
                case 8h22: { readData = timer1khz1.counter1khz; }
                case 8h30: { readData = sleepTimer0.counter1khz; }
                case 8h32: { readData = sleepTimer1.counter1khz; }
                case 8h40: { readData = p1hz.counter1hz; }
            }
        }
        // WRITE IO Memory
        if( memoryWrite && ~LATCHmemoryWrite ) {
            switch( memoryAddress ) {
                case 8h10: { timer1hz0.resetCounter = 1; }
                case 8h12: { timer1hz1.resetCounter = 1; }
                case 8h20: { timer1khz0.resetCount = writeData; }
                case 8h22: { timer1khz1.resetCount = writeData; }
                case 8h30: { sleepTimer0.resetCount = writeData; }
                case 8h32: { sleepTimer1.resetCount = writeData; }
            }
        }
        if( ~memoryWrite && ~LATCHmemoryWrite ) {
            p1hz.resetCounter = 0;
            timer1hz0.resetCounter = 0;
            sleepTimer0.resetCount = 0;
            timer1khz0.resetCount = 0;
            timer1hz1.resetCounter = 0;
            sleepTimer1.resetCount = 0;
            timer1khz1.resetCount = 0;
        }

        LATCHmemoryRead = memoryRead;
        LATCHmemoryWrite = memoryWrite;
    } // while(1)
}

// MEMORY MAP CONTROLLER FOR IO
algorithm io_memory(
    input   uint1   clock_25mhz,

    input   uint1   uart_rx,
    output  uint1   uart_tx,

    input   uint1   us2_bd_dp,
    input   uint1   us2_bd_dn,

    output  uint1   sd_clk,
    output  uint1   sd_mosi,
    output  uint1   sd_csn,
    input   uint1   sd_miso,

    output  uint8   leds,
    input   uint$NUM_BTNS$ btns,

    // Memory access
    input   uint8   memoryAddress,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,

    input   uint16  writeData,
    output  uint16  readData
) <autorun> {
    uart UART(
        uart_tx :> uart_tx,
        uart_rx <: uart_rx
    );
    ps2buffer PS2 <@clock_25mhz> (
        clock_25mhz <: clock_25mhz,
        us2_bd_dp <: us2_bd_dp,
        us2_bd_dn <: us2_bd_dn
    );
    sdcardbuffer SDCARD(
        sd_clk :> sd_clk,
        sd_mosi :> sd_mosi,
        sd_csn :> sd_csn,
        sd_miso <: sd_miso
    );

    // LATCH MEMORYREAD MEMORYWRITE
    uint1   LATCHmemoryRead = uninitialized;
    uint1   LATCHmemoryWrite = uninitialized;

    // UART FLAGS
    UART.inread := 0;
    UART.outwrite := 0;

    // SDCARD FLAGS
    SDCARD.readsector := 0;

    while(1) {
        // READ IO Memory
        if( memoryRead && ~LATCHmemoryRead ) {
            switch( memoryAddress ) {
                case 8h00: { readData = { 8b0, UART.inchar }; UART.inread = 1; }
                case 8h02: { readData = { 14b0, UART.outfull, UART.inavailable }; }
                case 8h10: { readData = PS2.inchar; PS2.inread = 1; }
                case 8h12: { readData = PS2.inavailable; }
                case 8h20: { readData = { $16-NUM_BTNS$b0, btns[0,$NUM_BTNS$] }; }
                case 8h30: { readData = leds; }
                case 8h40: { readData = SDCARD.ready; }
                case 8h50: { readData = SDCARD.bufferdata; }
             }
        }
        // WRITE IO Memory
        if( memoryWrite && ~LATCHmemoryWrite ) {
            switch( memoryAddress ) {
                case 8h00: { UART.outchar = writeData[0,8]; UART.outwrite = 1; }
                case 8h30: { leds = writeData; }
                case 8h40: { SDCARD.readsector = 1; }
                case 8h42: { SDCARD.sectoraddressH = writeData; }
                case 8h44: { SDCARD.sectoraddressL = writeData; }
                case 8h50: { SDCARD.bufferaddress = writeData; }
            }
        }
        if( ~memoryWrite && ~LATCHmemoryWrite ) {
            PS2.inread = 0;
        }

        LATCHmemoryRead = memoryRead;
        LATCHmemoryWrite = memoryWrite;
    } // while(1)
}

// MEMORY MAP CONTROLLER FOR AUDIO
algorithm audio_memory(
    input   uint1   clock_25mhz,
    input   uint4   static4bit,
    output  uint4   audio_l,
    output  uint4   audio_r,

    // Memory access
    input   uint8   memoryAddress,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,

    input   uint16  writeData,
    output  uint16  readData
) <autorun> {
    apu apu_processor_L <@clock_25mhz> (
        staticGenerator <: static4bit,
        audio_output :> audio_l
    );
    apu apu_processor_R <@clock_25mhz> (
        staticGenerator <: static4bit,
        audio_output :> audio_r
    );

    // LATCH MEMORYREAD MEMORYWRITE
    uint1   LATCHmemoryRead = uninitialized;
    uint1   LATCHmemoryWrite = uninitialized;

    while(1) {
        // READ IO Memory
        if( memoryRead && ~LATCHmemoryRead ) {
            switch( memoryAddress ) {
                case 8h04: { readData = apu_processor_L.audio_active; }
                case 8h14: { readData = apu_processor_R.audio_active; }
             }
        }
        // WRITE IO Memory
        if( memoryWrite && ~LATCHmemoryWrite ) {
            switch( memoryAddress ) {
                case 8h00: { apu_processor_L.waveform = writeData; }
                case 8h02: { apu_processor_L.note = writeData; }
                case 8h04: { apu_processor_L.duration = writeData; }
                case 8h06: { apu_processor_L.apu_write = writeData; }
                case 8h10: { apu_processor_R.waveform = writeData; }
                case 8h12: { apu_processor_R.note = writeData; }
                case 8h14: { apu_processor_R.duration = writeData; }
                case 8h16: { apu_processor_R.apu_write = writeData; }
            }
        }
        if( ~memoryWrite && ~LATCHmemoryWrite ) {
            apu_processor_L.apu_write = 0;
            apu_processor_R.apu_write = 0;
        }

        LATCHmemoryRead = memoryRead;
        LATCHmemoryWrite = memoryWrite;
    } // while(1)
}

// MEMORY MAP CONTROLLERS FOR DISPLAY LAYERS
algorithm background_memory(
    input   uint1   video_clock,
    input   uint1   video_reset,

    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint2   pix_red,
    output! uint2   pix_green,
    output! uint2   pix_blue,
    input   uint2   staticGenerator,

    // Memory access
    input   uint8   memoryAddress,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,

    input   uint16  writeData,
    output  uint16  readData
) <autorun> {
    background background_generator <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
        pix_red    :> pix_red,
        pix_green  :> pix_green,
        pix_blue   :> pix_blue,
        staticGenerator <: staticGenerator
    );

    // LATCH MEMORYREAD MEMORYWRITE
    uint1   LATCHmemoryRead = uninitialized;
    uint1   LATCHmemoryWrite = uninitialized;

    while(1) {
        // READ IO Memory
        if( memoryRead && ~LATCHmemoryRead ) {
            switch( memoryAddress ) {
            }
        }
        // WRITE IO Memory
        if( memoryWrite && ~LATCHmemoryWrite ) {
            switch( memoryAddress ) {
                case 8h00: { background_generator.backgroundcolour = writeData; background_generator.background_update = 1; }
                case 8h02: { background_generator.backgroundcolour_alt = writeData; background_generator.background_update = 2; }
                case 8h04: { background_generator.backgroundcolour_mode = writeData; background_generator.background_update = 3; }
                case 8h10: { background_generator.copper_program = writeData; }
                case 8h12: { background_generator.copper_status = writeData; }
                case 8h20: { background_generator.copper_address = writeData; }
                case 8h22: { background_generator.copper_command = writeData; }
                case 8h24: { background_generator.copper_condition = writeData; }
                case 8h26: { background_generator.copper_coordinate = writeData; }
                case 8h28: { background_generator.copper_mode = writeData; }
                case 8h2a: { background_generator.copper_alt = writeData; }
                case 8h2c: { background_generator.copper_colour = writeData; }
            }
        }
        if( ~memoryWrite && ~LATCHmemoryWrite ) {
            background_generator.background_update = 0;
            background_generator.copper_program = 0;
        }

        LATCHmemoryRead = memoryRead;
        LATCHmemoryWrite = memoryWrite;
    } // while(1)
}
algorithm tilemap_memory(
    input   uint1   video_clock,
    input   uint1   video_reset,

    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint2   pix_red,
    output! uint2   pix_green,
    output! uint2   pix_blue,
    output! uint1   pix_display,

    // Memory access
    input   uint8   memoryAddress,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,

    input   uint16  writeData,
    output  uint16  readData
) <autorun> {
    tilemap TM <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
        pix_red    :> pix_red,
        pix_green  :> pix_green,
        pix_blue   :> pix_blue,
        tilemap_display :> pix_display,
    );

    // LATCH MEMORYREAD MEMORYWRITE
    uint1   LATCHmemoryRead = uninitialized;
    uint1   LATCHmemoryWrite = uninitialized;

    while(1) {
        // READ IO Memory
        if( memoryRead && ~LATCHmemoryRead ) {
            switch( memoryAddress ) {
                case 8h20: { readData = TM.tm_lastaction; }
                case 8h22: { readData = TM.tm_active; }
            }
        }
        // WRITE IO Memory
        if( memoryWrite && ~LATCHmemoryWrite ) {
            switch( memoryAddress ) {
                case 8h00: { TM.tm_x = writeData; }
                case 8h02: { TM.tm_y = writeData; }
                case 8h04: { TM.tm_character = writeData; }
                case 8h06: { TM.tm_background = writeData; }
                case 8h08: { TM.tm_foreground = writeData; }
                case 8h0a: { TM.tm_write = 1; }
                case 8h10: { TM.tile_writer_tile = writeData; }
                case 8h12: { TM.tile_writer_line = writeData; }
                case 8h14: { TM.tile_writer_bitmap = writeData; }
                case 8h20: { TM.tm_scrollwrap = writeData; }
            }
        }
        if( ~memoryWrite && ~LATCHmemoryWrite ) {
            TM.tm_write = 0;
            TM.tm_scrollwrap = 0;
        }

        LATCHmemoryRead = memoryRead;
        LATCHmemoryWrite = memoryWrite;
    } // while(1)
}
algorithm bitmap_memory(
    input   uint1   video_clock,
    input   uint1   video_reset,

    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint2   pix_red,
    output! uint2   pix_green,
    output! uint2   pix_blue,
    output! uint1   pix_display,

    // STATIC GENERATOR
    input   uint1   static1bit,
    input   uint6   static6bit,

    // Memory access
    input   uint8   memoryAddress,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,

    input   uint16  writeData,
    output  uint16  readData
) <autorun> {
    bitmap BM <@video_clock,!video_reset> (
        static1bit <: static1bit,
        static6bit <: static6bit,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
        pix_red    :> pix_red,
        pix_green  :> pix_green,
        pix_blue   :> pix_blue,
        bitmap_display :> pix_display
    );

    // LATCH MEMORYREAD MEMORYWRITE
    uint1   LATCHmemoryRead = uninitialized;
    uint1   LATCHmemoryWrite = uninitialized;

    while(1) {
        // READ IO Memory
        if( memoryRead && ~LATCHmemoryRead ) {
            switch( memoryAddress ) {
                case 8h12: { readData = ( BM.gpu_active || BM.vector_block_active ) ? 1 : 0; }
                case 8h2a: { readData = BM.vector_block_active ? 1 : 0; }
                case 8h74: { readData = BM.bitmap_colour_read; }
            }
        }
        // WRITE IO Memory
        if( memoryWrite && ~LATCHmemoryWrite ) {
            switch( memoryAddress ) {
                case 8h00: { BM.gpu_x = writeData; }
                case 8h02: { BM.gpu_y = writeData; }
                case 8h04: { BM.gpu_colour = writeData; }
                case 8h06: { BM.gpu_colour_alt = writeData; }
                case 8h08: { BM.gpu_dithermode = writeData; }
                case 8h0a: { BM.gpu_param0 = writeData; }
                case 8h0c: { BM.gpu_param1 = writeData; }
                case 8h0e: { BM.gpu_param2 = writeData; }
                case 8h10: { BM.gpu_param3 = writeData; }
                case 8h12: { BM.gpu_write = writeData; }

                case 8h20: { BM.vector_block_number = writeData; }
                case 8h22: { BM.vector_block_colour = writeData; }
                case 8h24: { BM.vector_block_xc = writeData; }
                case 8h26: { BM.vector_block_yc = writeData; }
                case 8h28: { BM.vector_block_scale = writeData; }
                case 8h2a: { BM.draw_vector = 1; }

                case 8h30: { BM.vertices_writer_block = writeData; }
                case 8h32: { BM.vertices_writer_vertex = writeData; }
                case 8h34: { BM.vertices_writer_active = writeData; }
                case 8h36: { BM.vertices_writer_xdelta = writeData; }
                case 8h38: { BM.vertices_writer_ydelta = writeData; }

                case 8h40: { BM.blit1_writer_tile = writeData; }
                case 8h42: { BM.blit1_writer_line = writeData; }
                case 8h44: { BM.blit1_writer_bitmap = writeData; }

                case 8h50: { BM.character_writer_character = writeData; }
                case 8h52: { BM.character_writer_line = writeData; }
                case 8h54: { BM.character_writer_bitmap = writeData; }

                case 8h60: { BM.colourblit_writer_tile = writeData; }
                case 8h62: { BM.colourblit_writer_line = writeData; }
                case 8h64: { BM.colourblit_writer_pixel = writeData; }
                case 8h66: { BM.colourblit_writer_colour = writeData; }

                case 8h70: { BM.bitmap_x_read = writeData; }
                case 8h72: { BM.bitmap_y_read = writeData; }

                case 8h80: { BM.bitmap_write_offset = writeData; }

                case 8h90: { BM.framebuffer = writeData; }
                case 8h92: { BM.writer_framebuffer = writeData; }
            }
        }
        if( ~memoryWrite && ~LATCHmemoryWrite ) {
            BM.bitmap_write_offset = 0;
            BM.gpu_write = 0;
            BM.draw_vector = 0;
        }

        LATCHmemoryRead = memoryRead;
        LATCHmemoryWrite = memoryWrite;
    } // while(1)
}
algorithm charactermap_memory(
    input   uint1   video_clock,
    input   uint1   video_reset,

    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint2   pix_red,
    output! uint2   pix_green,
    output! uint2   pix_blue,
    output! uint1   pix_display,

    // Memory access
    input   uint8   memoryAddress,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,

    input   uint16  writeData,
    output  uint16  readData
) <autorun> {
    character_map CM <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
        pix_red    :> pix_red,
        pix_green  :> pix_green,
        pix_blue   :> pix_blue,
        character_map_display :> pix_display
    );

    // LATCH MEMORYREAD MEMORYWRITE
    uint1   LATCHmemoryRead = uninitialized;
    uint1   LATCHmemoryWrite = uninitialized;

    while(1) {
        // READ IO Memory
        if( memoryRead && ~LATCHmemoryRead ) {
            switch( memoryAddress ) {
                case 8h04: { readData = CM.curses_character; }
                case 8h06: { readData = CM.curses_background; }
                case 8h08: { readData = CM.curses_foreground; }
                case 8h0a: { readData = CM.tpu_active; }
            }
        }
        // WRITE IO Memory
        if( memoryWrite && ~LATCHmemoryWrite ) {
            switch( memoryAddress ) {
                case 8h00: { CM.tpu_x = writeData; }
                case 8h02: { CM.tpu_y = writeData; }
                case 8h04: { CM.tpu_character = writeData; }
                case 8h06: { CM.tpu_background = writeData; }
                case 8h08: { CM.tpu_foreground = writeData; }
                case 8h0a: { CM.tpu_write = writeData; }
            }
        }
        if( ~memoryWrite && ~LATCHmemoryWrite ) {
            CM.tpu_write = 0;
        }

        LATCHmemoryRead = memoryRead;
        LATCHmemoryWrite = memoryWrite;
    } // while(1)
}
algorithm sprite_memory(
    input   uint1   video_clock,
    input   uint1   video_reset,

    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint2   pix_red,
    output! uint2   pix_green,
    output! uint2   pix_blue,
    output! uint1   pix_display,

    // COLLISION LAYER INPUT
    input   uint1   bitmap_display,
    input   uint1   lower_tilemap_display,
    input   uint1   upper_tilemap_display,
    input   uint1   other_spritelayer_display,

    // Memory access
    input   uint8   memoryAddress,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,

    input   uint16  writeData,
    output  uint16  readData
) <autorun> {
    sprite_layer SL <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
        pix_red    :> pix_red,
        pix_green  :> pix_green,
        pix_blue   :> pix_blue,
        sprite_layer_display :> pix_display,
        collision_layer_1 <: bitmap_display,
        collision_layer_2 <: lower_tilemap_display,
        collision_layer_3 <: upper_tilemap_display,
        collision_layer_4 <: other_spritelayer_display
    );

    // LATCH MEMORYREAD MEMORYWRITE
    uint1   LATCHmemoryRead = uninitialized;
    uint1   LATCHmemoryWrite = uninitialized;

    while(1) {
        // READ IO Memory
        if( memoryRead && ~LATCHmemoryRead ) {
            switch( memoryAddress ) {
                case 8h02: { readData = SL.sprite_read_active; }
                case 8h04: { readData = SL.sprite_read_tile; }
                case 8h06: { readData = SL.sprite_read_colour; }
                case 8h08: { readData = __unsigned(SL.sprite_read_x); }
                case 8h0a: { readData = __unsigned(SL.sprite_read_y); }
                case 8h0c: { readData = SL.sprite_read_double; }

                case 8h12: { readData = SL.sprite_read_active_SMT; }
                case 8h14: { readData = SL.sprite_read_tile_SMT; }
                case 8h16: { readData = SL.sprite_read_colour_SMT; }
                case 8h18: { readData = __unsigned(SL.sprite_read_x_SMT); }
                case 8h1a: { readData = __unsigned(SL.sprite_read_y_SMT); }
                case 8h1c: { readData = SL.sprite_read_double_SMT; }

                case 8h30: { readData = SL.collision_0; }
                case 8h32: { readData = SL.collision_1; }
                case 8h34: { readData = SL.collision_2; }
                case 8h36: { readData = SL.collision_3; }
                case 8h38: { readData = SL.collision_4; }
                case 8h3a: { readData = SL.collision_5; }
                case 8h3c: { readData = SL.collision_6; }
                case 8h3e: { readData = SL.collision_7; }
                case 8h40: { readData = SL.collision_8; }
                case 8h42: { readData = SL.collision_9; }
                case 8h44: { readData = SL.collision_10; }
                case 8h46: { readData = SL.collision_11; }
                case 8h48: { readData = SL.collision_12; }
                case 8h4a: { readData = SL.collision_13; }
                case 8h4c: { readData = SL.collision_14; }
                case 8h4e: { readData = SL.collision_15; }
                case 8h50: { readData = SL.layer_collision_0; }
                case 8h52: { readData = SL.layer_collision_1; }
                case 8h54: { readData = SL.layer_collision_2; }
                case 8h56: { readData = SL.layer_collision_3; }
                case 8h58: { readData = SL.layer_collision_4; }
                case 8h5a: { readData = SL.layer_collision_5; }
                case 8h5c: { readData = SL.layer_collision_6; }
                case 8h5e: { readData = SL.layer_collision_7; }
                case 8h60: { readData = SL.layer_collision_8; }
                case 8h62: { readData = SL.layer_collision_9; }
                case 8h64: { readData = SL.layer_collision_10; }
                case 8h66: { readData = SL.layer_collision_11; }
                case 8h68: { readData = SL.layer_collision_12; }
                case 8h6a: { readData = SL.layer_collision_13; }
                case 8h6c: { readData = SL.layer_collision_14; }
                case 8h6e: { readData = SL.layer_collision_15; }
            }
        }
        // WRITE IO Memory
        if( memoryWrite && ~LATCHmemoryWrite ) {
            switch( memoryAddress ) {
                case 8h00: { SL.sprite_set_number = writeData; }
                case 8h02: { SL.sprite_set_active = writeData; SL.sprite_layer_write = 1; }
                case 8h04: { SL.sprite_set_tile = writeData; SL.sprite_layer_write = 2; }
                case 8h06: { SL.sprite_set_colour = writeData; SL.sprite_layer_write = 3; }
                case 8h08: { SL.sprite_set_x = writeData; SL.sprite_layer_write = 4; }
                case 8h0a: { SL.sprite_set_y = writeData; SL.sprite_layer_write = 5; }
                case 8h0c: { SL.sprite_set_double = writeData; SL.sprite_layer_write = 6; }
                case 8h0e: { SL.sprite_update = writeData; SL.sprite_layer_write = 10; }

                case 8h10: { SL.sprite_set_number_SMT = writeData; }
                case 8h12: { SL.sprite_set_active_SMT = writeData; SL.sprite_layer_write_SMT = 1; }
                case 8h14: { SL.sprite_set_tile_SMT = writeData; SL.sprite_layer_write_SMT = 2; }
                case 8h16: { SL.sprite_set_colour_SMT = writeData; SL.sprite_layer_write_SMT = 3; }
                case 8h18: { SL.sprite_set_x_SMT = writeData; SL.sprite_layer_write_SMT = 4; }
                case 8h1a: { SL.sprite_set_y_SMT = writeData; SL.sprite_layer_write_SMT = 5; }
                case 8h1c: { SL.sprite_set_double_SMT = writeData; SL.sprite_layer_write_SMT = 6; }
                case 8h1e: { SL.sprite_update_SMT = writeData; SL.sprite_layer_write_SMT = 10; }

                case 8h20: { SL.sprite_writer_sprite = writeData; }
                case 8h22: { SL.sprite_writer_line = writeData; }
                case 8h24: { SL.sprite_writer_bitmap = writeData; SL.sprite_writer_active = 1; }
            }
        }
        if( ~memoryWrite && ~LATCHmemoryWrite ) {
            SL.sprite_layer_write = 0;
            SL.sprite_layer_write_SMT = 0;
            SL.sprite_writer_active = 0;
        }

        LATCHmemoryRead = memoryRead;
        LATCHmemoryWrite = memoryWrite;
    } // while(1)
}
