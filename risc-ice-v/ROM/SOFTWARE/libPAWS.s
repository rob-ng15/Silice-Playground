	.file	"PAWSlibrary.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	1
	.globl	chartostring
	.type	chartostring, @function
chartostring:
	beq	a0,zero,.L1
	li	a5,0
	li	a2,10
	li	t1,2
	li	a7,9
.L3:
	remu	a3,a0,a2
	mv	a6,a0
	divu	a0,a0,a2
	sub	a4,t1,a5
	add	a4,a1,a4
	addi	a3,a3,48
	sb	a3,0(a4)
	addi	a5,a5,1
	andi	a5,a5,0xff
	bgtu	a6,a7,.L3
.L1:
	ret
	.size	chartostring, .-chartostring
	.align	1
	.globl	shorttostring
	.type	shorttostring, @function
shorttostring:
	beq	a0,zero,.L5
	li	a5,0
	li	a2,10
	li	t1,4
	li	a7,9
.L7:
	remu	a3,a0,a2
	mv	a6,a0
	divu	a0,a0,a2
	sub	a4,t1,a5
	add	a4,a1,a4
	addi	a3,a3,48
	sb	a3,0(a4)
	addi	a5,a5,1
	andi	a5,a5,0xff
	bgtu	a6,a7,.L7
.L5:
	ret
	.size	shorttostring, .-shorttostring
	.align	1
	.globl	inttostring
	.type	inttostring, @function
inttostring:
	beq	a0,zero,.L9
	li	a5,0
	li	a6,10
	li	a2,9
.L11:
	remu	a3,a0,a6
	mv	a7,a0
	divu	a0,a0,a6
	sub	a4,a2,a5
	add	a4,a1,a4
	addi	a3,a3,48
	sb	a3,0(a4)
	addi	a5,a5,1
	andi	a5,a5,0xff
	bgtu	a7,a2,.L11
.L9:
	ret
	.size	inttostring, .-inttostring
	.align	1
	.globl	outputcharacter
	.type	outputcharacter, @function
outputcharacter:
	lui	a5,%hi(UART_STATUS)
	lw	a4,%lo(UART_STATUS)(a5)
.L14:
	lbu	a5,0(a4)
	andi	a5,a5,2
	bne	a5,zero,.L14
	lui	a5,%hi(UART_DATA)
	lw	a5,%lo(UART_DATA)(a5)
	sb	a0,0(a5)
	lui	a5,%hi(TERMINAL_STATUS)
	lw	a4,%lo(TERMINAL_STATUS)(a5)
.L15:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L15
	lui	a5,%hi(TERMINAL_OUTPUT)
	lw	a5,%lo(TERMINAL_OUTPUT)(a5)
	sb	a0,0(a5)
	li	a5,10
	beq	a0,a5,.L23
	ret
.L23:
	addi	sp,sp,-16
	sw	ra,12(sp)
	li	a0,13
	call	outputcharacter
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	outputcharacter, .-outputcharacter
	.align	1
	.globl	outputstring
	.type	outputstring, @function
outputstring:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	mv	s0,a0
	lbu	a0,0(a0)
	beq	a0,zero,.L25
.L26:
	call	outputcharacter
	addi	s0,s0,1
	lbu	a0,0(s0)
	bne	a0,zero,.L26
.L25:
	li	a0,10
	call	outputcharacter
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	outputstring, .-outputstring
	.align	1
	.globl	outputstringnonl
	.type	outputstringnonl, @function
outputstringnonl:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	mv	s0,a0
	lbu	a0,0(a0)
	beq	a0,zero,.L29
.L31:
	call	outputcharacter
	addi	s0,s0,1
	lbu	a0,0(s0)
	bne	a0,zero,.L31
.L29:
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	outputstringnonl, .-outputstringnonl
	.align	1
	.globl	outputnumber_char
	.type	outputnumber_char, @function
outputnumber_char:
	addi	sp,sp,-32
	sw	ra,28(sp)
	li	a5,3153920
	addi	a5,a5,32
	sw	a5,12(sp)
	addi	a1,sp,12
	call	chartostring
	addi	a0,sp,12
	call	outputstringnonl
	lw	ra,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	outputnumber_char, .-outputnumber_char
	.align	1
	.globl	outputnumber_short
	.type	outputnumber_short, @function
outputnumber_short:
	addi	sp,sp,-32
	sw	ra,28(sp)
	li	a5,538976256
	addi	a5,a5,32
	sw	a5,8(sp)
	li	a5,48
	sh	a5,12(sp)
	addi	a1,sp,8
	call	shorttostring
	addi	a0,sp,8
	call	outputstringnonl
	lw	ra,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	outputnumber_short, .-outputnumber_short
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"         0"
	.text
	.align	1
	.globl	outputnumber_int
	.type	outputnumber_int, @function
outputnumber_int:
	addi	sp,sp,-32
	sw	ra,28(sp)
	lui	a5,%hi(.LC0)
	addi	a5,a5,%lo(.LC0)
	lw	a3,0(a5)
	lw	a4,4(a5)
	sw	a3,4(sp)
	sw	a4,8(sp)
	lhu	a4,8(a5)
	sh	a4,12(sp)
	lbu	a5,10(a5)
	sb	a5,14(sp)
	addi	a1,sp,4
	call	inttostring
	addi	a0,sp,4
	call	outputstringnonl
	lw	ra,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	outputnumber_int, .-outputnumber_int
	.align	1
	.globl	inputcharacter_available
	.type	inputcharacter_available, @function
inputcharacter_available:
	lui	a5,%hi(UART_STATUS)
	lw	a5,%lo(UART_STATUS)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,1
	ret
	.size	inputcharacter_available, .-inputcharacter_available
	.align	1
	.globl	inputcharacter
	.type	inputcharacter, @function
inputcharacter:
	addi	sp,sp,-16
	sw	ra,12(sp)
.L42:
	call	inputcharacter_available
	beq	a0,zero,.L42
	lui	a5,%hi(UART_DATA)
	lw	a5,%lo(UART_DATA)(a5)
	lbu	a0,0(a5)
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	inputcharacter, .-inputcharacter
	.align	1
	.globl	rng
	.type	rng, @function
rng:
	mv	a5,a0
	li	a4,32
	bgtu	a0,a4,.L46
	bgtu	a0,a4,.L47
	slli	a4,a0,2
	lui	a3,%hi(.L49)
	addi	a3,a3,%lo(.L49)
	add	a4,a4,a3
	lw	a4,0(a4)
	jr	a4
	.section	.rodata
	.align	2
	.align	2
.L49:
	.word	.L58
	.word	.L50
	.word	.L50
	.word	.L47
	.word	.L48
	.word	.L47
	.word	.L47
	.word	.L47
	.word	.L48
	.word	.L47
	.word	.L47
	.word	.L47
	.word	.L47
	.word	.L47
	.word	.L47
	.word	.L47
	.word	.L48
	.word	.L47
	.word	.L47
	.word	.L47
	.word	.L47
	.word	.L47
	.word	.L47
	.word	.L47
	.word	.L47
	.word	.L47
	.word	.L47
	.word	.L47
	.word	.L47
	.word	.L47
	.word	.L47
	.word	.L47
	.word	.L48
	.text
.L46:
	addi	a4,a0,-2048
	beq	a4,zero,.L48
	li	a4,4096
	addi	a4,a4,-2048
	bleu	a0,a4,.L60
	li	a4,16384
	beq	a0,a4,.L48
	bleu	a0,a4,.L61
	li	a4,32768
	bne	a0,a4,.L47
.L48:
	lui	a4,%hi(ALT_RNG)
	lw	a4,%lo(ALT_RNG)(a4)
	lhu	a0,0(a4)
	slli	a4,a0,16
	srli	a4,a4,16
	addi	a0,a5,-1
	and	a0,a0,a4
	ret
.L60:
	li	a4,256
	beq	a0,a4,.L48
	bleu	a0,a4,.L62
	addi	a4,a0,-512
	andi	a4,a4,-513
	slli	a4,a4,16
	srli	a4,a4,16
	bne	a4,zero,.L47
	j	.L48
.L62:
	addi	a4,a0,-64
	andi	a4,a4,-65
	slli	a4,a4,16
	srli	a4,a4,16
	beq	a4,zero,.L48
.L47:
	lui	a4,%hi(RNG)
	lw	a2,%lo(RNG)(a4)
	lui	a4,%hi(ALT_RNG)
	lw	a3,%lo(ALT_RNG)(a4)
	li	a4,255
	j	.L57
.L61:
	li	a4,-4096
	add	a4,a0,a4
	li	a3,-4096
	addi	a3,a3,-1
	and	a4,a4,a3
	slli	a4,a4,16
	srli	a4,a4,16
	bne	a4,zero,.L47
	j	.L48
.L50:
	lui	a5,%hi(ALT_RNG)
	lw	a5,%lo(ALT_RNG)(a5)
	lhu	a0,0(a5)
	andi	a0,a0,1
	ret
.L64:
	lhu	a0,0(a3)
	andi	a0,a0,0xff
.L56:
	bltu	a0,a5,.L63
.L57:
	bleu	a5,a4,.L64
	lhu	a0,0(a2)
	slli	a0,a0,16
	srli	a0,a0,16
	j	.L56
.L63:
	ret
.L58:
	ret
	.size	rng, .-rng
	.align	1
	.globl	sleep
	.type	sleep, @function
sleep:
	lui	a5,%hi(SLEEPTIMER)
	lw	a4,%lo(SLEEPTIMER)(a5)
	sh	a0,0(a4)
	lw	a4,%lo(SLEEPTIMER)(a5)
.L66:
	lhu	a5,0(a4)
	slli	a5,a5,16
	srli	a5,a5,16
	bne	a5,zero,.L66
	ret
	.size	sleep, .-sleep
	.align	1
	.globl	set_timer1khz
	.type	set_timer1khz, @function
set_timer1khz:
	lui	a5,%hi(TIMER1KHZ)
	lw	a5,%lo(TIMER1KHZ)(a5)
	sh	a0,0(a5)
	ret
	.size	set_timer1khz, .-set_timer1khz
	.align	1
	.globl	get_timer1khz
	.type	get_timer1khz, @function
get_timer1khz:
	lui	a5,%hi(TIMER1KHZ)
	lw	a5,%lo(TIMER1KHZ)(a5)
	lhu	a0,0(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
	.size	get_timer1khz, .-get_timer1khz
	.align	1
	.globl	wait_timer1khz
	.type	wait_timer1khz, @function
wait_timer1khz:
	lui	a5,%hi(TIMER1KHZ)
	lw	a4,%lo(TIMER1KHZ)(a5)
.L71:
	lhu	a5,0(a4)
	slli	a5,a5,16
	srli	a5,a5,16
	bne	a5,zero,.L71
	ret
	.size	wait_timer1khz, .-wait_timer1khz
	.align	1
	.globl	get_timer1hz
	.type	get_timer1hz, @function
get_timer1hz:
	lui	a5,%hi(TIMER1HZ)
	lw	a5,%lo(TIMER1HZ)(a5)
	lhu	a0,0(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
	.size	get_timer1hz, .-get_timer1hz
	.align	1
	.globl	reset_timer1hz
	.type	reset_timer1hz, @function
reset_timer1hz:
	lui	a5,%hi(TIMER1HZ)
	lw	a5,%lo(TIMER1HZ)(a5)
	li	a4,1
	sh	a4,0(a5)
	ret
	.size	reset_timer1hz, .-reset_timer1hz
	.align	1
	.globl	beep
	.type	beep, @function
beep:
	andi	a5,a0,1
	beq	a5,zero,.L76
	lui	a5,%hi(AUDIO_L_WAVEFORM)
	lw	a5,%lo(AUDIO_L_WAVEFORM)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(AUDIO_L_NOTE)
	lw	a5,%lo(AUDIO_L_NOTE)(a5)
	sb	a2,0(a5)
	lui	a5,%hi(AUDIO_L_DURATION)
	lw	a5,%lo(AUDIO_L_DURATION)(a5)
	sh	a3,0(a5)
	lui	a5,%hi(AUDIO_L_START)
	lw	a5,%lo(AUDIO_L_START)(a5)
	li	a4,1
	sb	a4,0(a5)
.L76:
	andi	a0,a0,2
	beq	a0,zero,.L75
	lui	a5,%hi(AUDIO_R_WAVEFORM)
	lw	a5,%lo(AUDIO_R_WAVEFORM)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(AUDIO_R_NOTE)
	lw	a5,%lo(AUDIO_R_NOTE)(a5)
	sb	a2,0(a5)
	lui	a5,%hi(AUDIO_R_DURATION)
	lw	a5,%lo(AUDIO_R_DURATION)(a5)
	sh	a3,0(a5)
	lui	a5,%hi(AUDIO_R_START)
	lw	a5,%lo(AUDIO_R_START)(a5)
	li	a4,1
	sb	a4,0(a5)
.L75:
	ret
	.size	beep, .-beep
	.align	1
	.globl	sdcard_wait
	.type	sdcard_wait, @function
sdcard_wait:
	lui	a5,%hi(SDCARD_READY)
	lw	a4,%lo(SDCARD_READY)(a5)
.L79:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	beq	a5,zero,.L79
	ret
	.size	sdcard_wait, .-sdcard_wait
	.align	1
	.globl	sdcard_readsector
	.type	sdcard_readsector, @function
sdcard_readsector:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s1,4(sp)
	mv	s1,a0
	mv	s0,a1
	call	sdcard_wait
	lui	a5,%hi(SDCARD_SECTOR_HIGH)
	lw	a5,%lo(SDCARD_SECTOR_HIGH)(a5)
	srli	a4,s1,16
	sh	a4,0(a5)
	lui	a5,%hi(SDCARD_SECTOR_LOW)
	lw	a5,%lo(SDCARD_SECTOR_LOW)(a5)
	slli	s1,s1,16
	srli	s1,s1,16
	sh	s1,0(a5)
	lui	a5,%hi(SDCARD_START)
	lw	a5,%lo(SDCARD_START)(a5)
	li	a4,1
	sb	a4,0(a5)
	call	sdcard_wait
	li	a5,0
	lui	a0,%hi(SDCARD_ADDRESS)
	lui	a1,%hi(SDCARD_DATA)
	li	a2,512
.L82:
	slli	a3,a5,16
	srli	a3,a3,16
	lw	a4,%lo(SDCARD_ADDRESS)(a0)
	sh	a3,0(a4)
	lw	a4,%lo(SDCARD_DATA)(a1)
	lbu	a3,0(a4)
	add	a4,s0,a5
	sb	a3,0(a4)
	addi	a5,a5,1
	bne	a5,a2,.L82
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
	.size	sdcard_readsector, .-sdcard_readsector
	.align	1
	.globl	set_leds
	.type	set_leds, @function
set_leds:
	lui	a5,%hi(LEDS)
	lw	a5,%lo(LEDS)(a5)
	sb	a0,0(a5)
	ret
	.size	set_leds, .-set_leds
	.align	1
	.globl	get_buttons
	.type	get_buttons, @function
get_buttons:
	lui	a5,%hi(BUTTONS)
	lw	a5,%lo(BUTTONS)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
	.size	get_buttons, .-get_buttons
	.align	1
	.globl	await_vblank
	.type	await_vblank, @function
await_vblank:
	lui	a5,%hi(VBLANK)
	lw	a4,%lo(VBLANK)(a5)
.L88:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	beq	a5,zero,.L88
	ret
	.size	await_vblank, .-await_vblank
	.align	1
	.globl	set_background
	.type	set_background, @function
set_background:
	lui	a5,%hi(BACKGROUND_COLOUR)
	lw	a5,%lo(BACKGROUND_COLOUR)(a5)
	sb	a0,0(a5)
	lui	a5,%hi(BACKGROUND_ALTCOLOUR)
	lw	a5,%lo(BACKGROUND_ALTCOLOUR)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(BACKGROUND_MODE)
	lw	a5,%lo(BACKGROUND_MODE)(a5)
	sb	a2,0(a5)
	ret
	.size	set_background, .-set_background
	.align	1
	.globl	set_tilemap_tile
	.type	set_tilemap_tile, @function
set_tilemap_tile:
	lui	a5,%hi(TM_STATUS)
	lw	a6,%lo(TM_STATUS)(a5)
.L92:
	lbu	a5,0(a6)
	andi	a5,a5,0xff
	bne	a5,zero,.L92
	lui	a5,%hi(TM_X)
	lw	a5,%lo(TM_X)(a5)
	sb	a0,0(a5)
	lui	a5,%hi(TM_Y)
	lw	a5,%lo(TM_Y)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(TM_TILE)
	lw	a5,%lo(TM_TILE)(a5)
	sb	a2,0(a5)
	lui	a5,%hi(TM_BACKGROUND)
	lw	a5,%lo(TM_BACKGROUND)(a5)
	sb	a3,0(a5)
	lui	a5,%hi(TM_FOREGROUND)
	lw	a5,%lo(TM_FOREGROUND)(a5)
	sb	a4,0(a5)
	lui	a5,%hi(TM_COMMIT)
	lw	a5,%lo(TM_COMMIT)(a5)
	li	a4,1
	sb	a4,0(a5)
	ret
	.size	set_tilemap_tile, .-set_tilemap_tile
	.align	1
	.globl	set_tilemap_bitmap
	.type	set_tilemap_bitmap, @function
set_tilemap_bitmap:
	lui	a5,%hi(TM_WRITER_TILE_NUMBER)
	lw	a5,%lo(TM_WRITER_TILE_NUMBER)(a5)
	sb	a0,0(a5)
	li	a5,0
	lui	a6,%hi(TM_WRITER_LINE_NUMBER)
	lui	a0,%hi(TM_WRITER_BITMAP)
	li	a2,16
.L95:
	lw	a4,%lo(TM_WRITER_LINE_NUMBER)(a6)
	andi	a3,a5,0xff
	sb	a3,0(a4)
	lw	a4,%lo(TM_WRITER_BITMAP)(a0)
	lhu	a3,0(a1)
	sh	a3,0(a4)
	addi	a5,a5,1
	addi	a1,a1,2
	bne	a5,a2,.L95
	ret
	.size	set_tilemap_bitmap, .-set_tilemap_bitmap
	.align	1
	.globl	tilemap_scrollwrapclear
	.type	tilemap_scrollwrapclear, @function
tilemap_scrollwrapclear:
	lui	a5,%hi(TM_STATUS)
	lw	a4,%lo(TM_STATUS)(a5)
.L98:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L98
	lui	a5,%hi(TM_SCROLLWRAPCLEAR)
	lw	a4,%lo(TM_SCROLLWRAPCLEAR)(a5)
	sb	a0,0(a4)
	lw	a5,%lo(TM_SCROLLWRAPCLEAR)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
	.size	tilemap_scrollwrapclear, .-tilemap_scrollwrapclear
	.align	1
	.globl	wait_gpu
	.type	wait_gpu, @function
wait_gpu:
	lui	a5,%hi(GPU_STATUS)
	lw	a4,%lo(GPU_STATUS)(a5)
.L101:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L101
	ret
	.size	wait_gpu, .-wait_gpu
	.align	1
	.globl	gpu_pixel
	.type	gpu_pixel, @function
gpu_pixel:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s1,4(sp)
	sw	s2,0(sp)
	mv	s2,a0
	mv	s1,a1
	mv	s0,a2
	call	wait_gpu
	lui	a5,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a5)
	sb	s2,0(a5)
	lui	a5,%hi(GPU_X)
	lw	a5,%lo(GPU_X)(a5)
	sh	s1,0(a5)
	lui	a5,%hi(GPU_Y)
	lw	a5,%lo(GPU_Y)(a5)
	sh	s0,0(a5)
	lui	a5,%hi(GPU_WRITE)
	lw	a5,%lo(GPU_WRITE)(a5)
	li	a4,1
	sb	a4,0(a5)
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	lw	s2,0(sp)
	addi	sp,sp,16
	jr	ra
	.size	gpu_pixel, .-gpu_pixel
	.align	1
	.globl	bitmap_scrollwrap
	.type	bitmap_scrollwrap, @function
bitmap_scrollwrap:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	mv	s0,a0
	call	wait_gpu
	lui	a5,%hi(BITMAP_SCROLLWRAP)
	lw	a5,%lo(BITMAP_SCROLLWRAP)(a5)
	sb	s0,0(a5)
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	bitmap_scrollwrap, .-bitmap_scrollwrap
	.align	1
	.globl	gpu_rectangle
	.type	gpu_rectangle, @function
gpu_rectangle:
	addi	sp,sp,-16
	sw	ra,12(sp)
	lui	a5,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a5)
	sb	a0,0(a5)
	lui	a5,%hi(GPU_X)
	lw	a5,%lo(GPU_X)(a5)
	sh	a1,0(a5)
	lui	a5,%hi(GPU_Y)
	lw	a5,%lo(GPU_Y)(a5)
	sh	a2,0(a5)
	lui	a5,%hi(GPU_PARAM0)
	lw	a5,%lo(GPU_PARAM0)(a5)
	sh	a3,0(a5)
	lui	a5,%hi(GPU_PARAM1)
	lw	a5,%lo(GPU_PARAM1)(a5)
	sh	a4,0(a5)
	call	wait_gpu
	lui	a5,%hi(GPU_WRITE)
	lw	a5,%lo(GPU_WRITE)(a5)
	li	a4,2
	sb	a4,0(a5)
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	gpu_rectangle, .-gpu_rectangle
	.align	1
	.globl	gpu_cs
	.type	gpu_cs, @function
gpu_cs:
	addi	sp,sp,-16
	sw	ra,12(sp)
	li	a0,5
	call	bitmap_scrollwrap
	li	a4,479
	li	a3,639
	li	a2,0
	li	a1,0
	li	a0,64
	call	gpu_rectangle
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	gpu_cs, .-gpu_cs
	.align	1
	.globl	gpu_line
	.type	gpu_line, @function
gpu_line:
	addi	sp,sp,-16
	sw	ra,12(sp)
	lui	a5,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a5)
	sb	a0,0(a5)
	lui	a5,%hi(GPU_X)
	lw	a5,%lo(GPU_X)(a5)
	sh	a1,0(a5)
	lui	a5,%hi(GPU_Y)
	lw	a5,%lo(GPU_Y)(a5)
	sh	a2,0(a5)
	lui	a5,%hi(GPU_PARAM0)
	lw	a5,%lo(GPU_PARAM0)(a5)
	sh	a3,0(a5)
	lui	a5,%hi(GPU_PARAM1)
	lw	a5,%lo(GPU_PARAM1)(a5)
	sh	a4,0(a5)
	call	wait_gpu
	lui	a5,%hi(GPU_WRITE)
	lw	a5,%lo(GPU_WRITE)(a5)
	li	a4,3
	sb	a4,0(a5)
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	gpu_line, .-gpu_line
	.align	1
	.globl	gpu_circle
	.type	gpu_circle, @function
gpu_circle:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	mv	s0,a4
	lui	a5,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a5)
	sb	a0,0(a5)
	lui	a5,%hi(GPU_X)
	lw	a5,%lo(GPU_X)(a5)
	sh	a1,0(a5)
	lui	a5,%hi(GPU_Y)
	lw	a5,%lo(GPU_Y)(a5)
	sh	a2,0(a5)
	lui	a5,%hi(GPU_PARAM0)
	lw	a5,%lo(GPU_PARAM0)(a5)
	sh	a3,0(a5)
	call	wait_gpu
	snez	a4,s0
	slli	a4,a4,1
	addi	a4,a4,4
	lui	a5,%hi(GPU_WRITE)
	lw	a5,%lo(GPU_WRITE)(a5)
	sb	a4,0(a5)
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	gpu_circle, .-gpu_circle
	.align	1
	.globl	gpu_blit
	.type	gpu_blit, @function
gpu_blit:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	mv	s0,a4
	lui	a5,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a5)
	sb	a0,0(a5)
	lui	a5,%hi(GPU_X)
	lw	a5,%lo(GPU_X)(a5)
	sh	a1,0(a5)
	lui	a5,%hi(GPU_Y)
	lw	a5,%lo(GPU_Y)(a5)
	sh	a2,0(a5)
	lui	a5,%hi(GPU_PARAM0)
	lw	a5,%lo(GPU_PARAM0)(a5)
	sh	a3,0(a5)
	call	wait_gpu
	snez	a5,s0
	neg	a5,a5
	andi	a5,a5,3
	addi	a5,a5,5
	lui	a4,%hi(GPU_WRITE)
	lw	a4,%lo(GPU_WRITE)(a4)
	sb	a5,0(a4)
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	gpu_blit, .-gpu_blit
	.align	1
	.globl	set_blitter_bitmap
	.type	set_blitter_bitmap, @function
set_blitter_bitmap:
	lui	a5,%hi(BLIT_WRITER_TILE)
	lw	a5,%lo(BLIT_WRITER_TILE)(a5)
	sb	a0,0(a5)
	li	a5,0
	lui	a6,%hi(BLIT_WRITER_LINE)
	lui	a0,%hi(BLIT_WRITER_BITMAP)
	li	a2,16
.L122:
	lw	a4,%lo(BLIT_WRITER_LINE)(a6)
	andi	a3,a5,0xff
	sb	a3,0(a4)
	lw	a4,%lo(BLIT_WRITER_BITMAP)(a0)
	lhu	a3,0(a1)
	sh	a3,0(a4)
	addi	a5,a5,1
	addi	a1,a1,2
	bne	a5,a2,.L122
	ret
	.size	set_blitter_bitmap, .-set_blitter_bitmap
	.align	1
	.globl	gpu_triangle
	.type	gpu_triangle, @function
gpu_triangle:
	addi	sp,sp,-16
	sw	ra,12(sp)
	lui	a7,%hi(GPU_COLOUR)
	lw	a7,%lo(GPU_COLOUR)(a7)
	sb	a0,0(a7)
	lui	a0,%hi(GPU_X)
	lw	a0,%lo(GPU_X)(a0)
	sh	a1,0(a0)
	lui	a1,%hi(GPU_Y)
	lw	a1,%lo(GPU_Y)(a1)
	sh	a2,0(a1)
	lui	a2,%hi(GPU_PARAM0)
	lw	a2,%lo(GPU_PARAM0)(a2)
	sh	a3,0(a2)
	lui	a3,%hi(GPU_PARAM1)
	lw	a3,%lo(GPU_PARAM1)(a3)
	sh	a4,0(a3)
	lui	a4,%hi(GPU_PARAM2)
	lw	a4,%lo(GPU_PARAM2)(a4)
	sh	a5,0(a4)
	lui	a5,%hi(GPU_PARAM3)
	lw	a5,%lo(GPU_PARAM3)(a5)
	sh	a6,0(a5)
	call	wait_gpu
	lui	a5,%hi(GPU_WRITE)
	lw	a5,%lo(GPU_WRITE)(a5)
	li	a4,7
	sb	a4,0(a5)
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	gpu_triangle, .-gpu_triangle
	.align	1
	.globl	wait_vector_block
	.type	wait_vector_block, @function
wait_vector_block:
	lui	a5,%hi(VECTOR_DRAW_STATUS)
	lw	a4,%lo(VECTOR_DRAW_STATUS)(a5)
.L127:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L127
	ret
	.size	wait_vector_block, .-wait_vector_block
	.align	1
	.globl	draw_vector_block
	.type	draw_vector_block, @function
draw_vector_block:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	mv	s3,a0
	mv	s2,a1
	mv	s1,a2
	mv	s0,a3
	call	wait_vector_block
	lui	a5,%hi(VECTOR_DRAW_BLOCK)
	lw	a5,%lo(VECTOR_DRAW_BLOCK)(a5)
	sb	s3,0(a5)
	lui	a5,%hi(VECTOR_DRAW_COLOUR)
	lw	a5,%lo(VECTOR_DRAW_COLOUR)(a5)
	sb	s2,0(a5)
	lui	a5,%hi(VECTOR_DRAW_XC)
	lw	a5,%lo(VECTOR_DRAW_XC)(a5)
	sh	s1,0(a5)
	lui	a5,%hi(VECTOR_DRAW_YC)
	lw	a5,%lo(VECTOR_DRAW_YC)(a5)
	sh	s0,0(a5)
	lui	a5,%hi(VECTOR_DRAW_START)
	lw	a5,%lo(VECTOR_DRAW_START)(a5)
	li	a4,1
	sb	a4,0(a5)
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	addi	sp,sp,32
	jr	ra
	.size	draw_vector_block, .-draw_vector_block
	.align	1
	.globl	set_vector_vertex
	.type	set_vector_vertex, @function
set_vector_vertex:
	lui	a5,%hi(VECTOR_WRITER_BLOCK)
	lw	a5,%lo(VECTOR_WRITER_BLOCK)(a5)
	sb	a0,0(a5)
	lui	a5,%hi(VECTOR_WRITER_VERTEX)
	lw	a5,%lo(VECTOR_WRITER_VERTEX)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(VECTOR_WRITER_ACTIVE)
	lw	a5,%lo(VECTOR_WRITER_ACTIVE)(a5)
	sb	a2,0(a5)
	lui	a5,%hi(VECTOR_WRITER_DELTAX)
	lw	a5,%lo(VECTOR_WRITER_DELTAX)(a5)
	sb	a3,0(a5)
	lui	a5,%hi(VECTOR_WRITER_DELTAY)
	lw	a5,%lo(VECTOR_WRITER_DELTAY)(a5)
	sb	a4,0(a5)
	ret
	.size	set_vector_vertex, .-set_vector_vertex
	.align	1
	.globl	set_sprite_bitmaps
	.type	set_sprite_bitmaps, @function
set_sprite_bitmaps:
	beq	a0,zero,.L133
	li	a5,1
	beq	a0,a5,.L134
.L135:
	li	a5,0
	lui	t4,%hi(LOWER_SPRITE_WRITER_LINE)
	lui	t3,%hi(LOWER_SPRITE_WRITER_BITMAP)
	li	a3,1
	lui	t1,%hi(UPPER_SPRITE_WRITER_LINE)
	lui	a7,%hi(UPPER_SPRITE_WRITER_BITMAP)
	li	a4,128
	j	.L136
.L133:
	lui	a5,%hi(LOWER_SPRITE_WRITER_NUMBER)
	lw	a5,%lo(LOWER_SPRITE_WRITER_NUMBER)(a5)
	sb	a1,0(a5)
	j	.L135
.L134:
	lui	a5,%hi(UPPER_SPRITE_WRITER_NUMBER)
	lw	a5,%lo(UPPER_SPRITE_WRITER_NUMBER)(a5)
	sb	a1,0(a5)
	j	.L135
.L137:
	lw	a1,%lo(LOWER_SPRITE_WRITER_LINE)(t4)
	andi	a6,a5,0xff
	sb	a6,0(a1)
	lw	a1,%lo(LOWER_SPRITE_WRITER_BITMAP)(t3)
	lhu	a6,0(a2)
	sh	a6,0(a1)
.L139:
	addi	a5,a5,1
	addi	a2,a2,2
	beq	a5,a4,.L141
.L136:
	beq	a0,zero,.L137
	bne	a0,a3,.L139
	lw	a1,%lo(UPPER_SPRITE_WRITER_LINE)(t1)
	andi	a6,a5,0xff
	sb	a6,0(a1)
	lw	a1,%lo(UPPER_SPRITE_WRITER_BITMAP)(a7)
	lhu	a6,0(a2)
	sh	a6,0(a1)
	j	.L139
.L141:
	ret
	.size	set_sprite_bitmaps, .-set_sprite_bitmaps
	.align	1
	.globl	set_sprite
	.type	set_sprite, @function
set_sprite:
	beq	a0,zero,.L143
	li	t1,1
	beq	a0,t1,.L144
	ret
.L143:
	lui	a0,%hi(LOWER_SPRITE_NUMBER)
	lw	a0,%lo(LOWER_SPRITE_NUMBER)(a0)
	sb	a1,0(a0)
	lui	a1,%hi(LOWER_SPRITE_ACTIVE)
	lw	a1,%lo(LOWER_SPRITE_ACTIVE)(a1)
	sb	a2,0(a1)
	lui	a2,%hi(LOWER_SPRITE_TILE)
	lw	a2,%lo(LOWER_SPRITE_TILE)(a2)
	sb	a6,0(a2)
	lui	a2,%hi(LOWER_SPRITE_COLOUR)
	lw	a2,%lo(LOWER_SPRITE_COLOUR)(a2)
	sb	a3,0(a2)
	lui	a3,%hi(LOWER_SPRITE_X)
	lw	a3,%lo(LOWER_SPRITE_X)(a3)
	sh	a4,0(a3)
	lui	a4,%hi(LOWER_SPRITE_Y)
	lw	a4,%lo(LOWER_SPRITE_Y)(a4)
	sh	a5,0(a4)
	lui	a5,%hi(LOWER_SPRITE_DOUBLE)
	lw	a5,%lo(LOWER_SPRITE_DOUBLE)(a5)
	sb	a7,0(a5)
	ret
.L144:
	lui	a0,%hi(UPPER_SPRITE_NUMBER)
	lw	a0,%lo(UPPER_SPRITE_NUMBER)(a0)
	sb	a1,0(a0)
	lui	a1,%hi(UPPER_SPRITE_ACTIVE)
	lw	a1,%lo(UPPER_SPRITE_ACTIVE)(a1)
	sb	a2,0(a1)
	lui	a2,%hi(UPPER_SPRITE_TILE)
	lw	a2,%lo(UPPER_SPRITE_TILE)(a2)
	sb	a6,0(a2)
	lui	a2,%hi(UPPER_SPRITE_COLOUR)
	lw	a2,%lo(UPPER_SPRITE_COLOUR)(a2)
	sb	a3,0(a2)
	lui	a3,%hi(UPPER_SPRITE_X)
	lw	a3,%lo(UPPER_SPRITE_X)(a3)
	sh	a4,0(a3)
	lui	a4,%hi(UPPER_SPRITE_Y)
	lw	a4,%lo(UPPER_SPRITE_Y)(a4)
	sh	a5,0(a4)
	lui	a5,%hi(UPPER_SPRITE_DOUBLE)
	lw	a5,%lo(UPPER_SPRITE_DOUBLE)(a5)
	sb	a7,0(a5)
	ret
	.size	set_sprite, .-set_sprite
	.align	1
	.globl	set_sprite_attribute
	.type	set_sprite_attribute, @function
set_sprite_attribute:
	bne	a0,zero,.L147
	lui	a5,%hi(LOWER_SPRITE_NUMBER)
	lw	a5,%lo(LOWER_SPRITE_NUMBER)(a5)
	sb	a1,0(a5)
	li	a5,5
	bgtu	a2,a5,.L146
	slli	a2,a2,2
	lui	a5,%hi(.L150)
	addi	a5,a5,%lo(.L150)
	add	a2,a2,a5
	lw	a5,0(a2)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L150:
	.word	.L155
	.word	.L154
	.word	.L153
	.word	.L152
	.word	.L151
	.word	.L149
	.text
.L155:
	lui	a5,%hi(LOWER_SPRITE_ACTIVE)
	lw	a5,%lo(LOWER_SPRITE_ACTIVE)(a5)
	andi	a3,a3,0xff
	sb	a3,0(a5)
	ret
.L154:
	lui	a5,%hi(LOWER_SPRITE_TILE)
	lw	a5,%lo(LOWER_SPRITE_TILE)(a5)
	andi	a3,a3,0xff
	sb	a3,0(a5)
	ret
.L153:
	lui	a5,%hi(LOWER_SPRITE_COLOUR)
	lw	a5,%lo(LOWER_SPRITE_COLOUR)(a5)
	andi	a3,a3,0xff
	sb	a3,0(a5)
	ret
.L152:
	lui	a5,%hi(LOWER_SPRITE_X)
	lw	a5,%lo(LOWER_SPRITE_X)(a5)
	sh	a3,0(a5)
	ret
.L151:
	lui	a5,%hi(LOWER_SPRITE_Y)
	lw	a5,%lo(LOWER_SPRITE_Y)(a5)
	sh	a3,0(a5)
	ret
.L149:
	lui	a5,%hi(LOWER_SPRITE_DOUBLE)
	lw	a5,%lo(LOWER_SPRITE_DOUBLE)(a5)
	andi	a3,a3,0xff
	sb	a3,0(a5)
	ret
.L147:
	lui	a5,%hi(UPPER_SPRITE_NUMBER)
	lw	a5,%lo(UPPER_SPRITE_NUMBER)(a5)
	sb	a1,0(a5)
	li	a5,5
	bgtu	a2,a5,.L146
	slli	a2,a2,2
	lui	a5,%hi(.L157)
	addi	a5,a5,%lo(.L157)
	add	a2,a2,a5
	lw	a5,0(a2)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L157:
	.word	.L162
	.word	.L161
	.word	.L160
	.word	.L159
	.word	.L158
	.word	.L156
	.text
.L162:
	lui	a5,%hi(UPPER_SPRITE_ACTIVE)
	lw	a5,%lo(UPPER_SPRITE_ACTIVE)(a5)
	andi	a3,a3,0xff
	sb	a3,0(a5)
	ret
.L161:
	lui	a5,%hi(UPPER_SPRITE_TILE)
	lw	a5,%lo(UPPER_SPRITE_TILE)(a5)
	andi	a3,a3,0xff
	sb	a3,0(a5)
	ret
.L160:
	lui	a5,%hi(UPPER_SPRITE_COLOUR)
	lw	a5,%lo(UPPER_SPRITE_COLOUR)(a5)
	andi	a3,a3,0xff
	sb	a3,0(a5)
	ret
.L159:
	lui	a5,%hi(UPPER_SPRITE_X)
	lw	a5,%lo(UPPER_SPRITE_X)(a5)
	sh	a3,0(a5)
	ret
.L158:
	lui	a5,%hi(UPPER_SPRITE_Y)
	lw	a5,%lo(UPPER_SPRITE_Y)(a5)
	sh	a3,0(a5)
	ret
.L156:
	lui	a5,%hi(UPPER_SPRITE_DOUBLE)
	lw	a5,%lo(UPPER_SPRITE_DOUBLE)(a5)
	andi	a3,a3,0xff
	sb	a3,0(a5)
.L146:
	ret
	.size	set_sprite_attribute, .-set_sprite_attribute
	.align	1
	.globl	get_sprite_attribute
	.type	get_sprite_attribute, @function
get_sprite_attribute:
	bne	a0,zero,.L164
	lui	a5,%hi(LOWER_SPRITE_NUMBER)
	lw	a5,%lo(LOWER_SPRITE_NUMBER)(a5)
	sb	a1,0(a5)
	li	a5,5
	bgtu	a2,a5,.L165
	slli	a2,a2,2
	lui	a5,%hi(.L167)
	addi	a5,a5,%lo(.L167)
	add	a2,a2,a5
	lw	a5,0(a2)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L167:
	.word	.L172
	.word	.L171
	.word	.L170
	.word	.L169
	.word	.L168
	.word	.L166
	.text
.L172:
	lui	a5,%hi(LOWER_SPRITE_ACTIVE)
	lw	a5,%lo(LOWER_SPRITE_ACTIVE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L171:
	lui	a5,%hi(LOWER_SPRITE_TILE)
	lw	a5,%lo(LOWER_SPRITE_TILE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L170:
	lui	a5,%hi(LOWER_SPRITE_COLOUR)
	lw	a5,%lo(LOWER_SPRITE_COLOUR)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L169:
	lui	a5,%hi(LOWER_SPRITE_X)
	lw	a5,%lo(LOWER_SPRITE_X)(a5)
	lhu	a0,0(a5)
	slli	a0,a0,16
	srai	a0,a0,16
	ret
.L168:
	lui	a5,%hi(LOWER_SPRITE_Y)
	lw	a5,%lo(LOWER_SPRITE_Y)(a5)
	lhu	a0,0(a5)
	slli	a0,a0,16
	srai	a0,a0,16
	ret
.L166:
	lui	a5,%hi(LOWER_SPRITE_DOUBLE)
	lw	a5,%lo(LOWER_SPRITE_DOUBLE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L164:
	lui	a5,%hi(UPPER_SPRITE_NUMBER)
	lw	a5,%lo(UPPER_SPRITE_NUMBER)(a5)
	sb	a1,0(a5)
	li	a5,5
	bgtu	a2,a5,.L165
	slli	a2,a2,2
	lui	a5,%hi(.L175)
	addi	a5,a5,%lo(.L175)
	add	a2,a2,a5
	lw	a5,0(a2)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L175:
	.word	.L180
	.word	.L179
	.word	.L178
	.word	.L177
	.word	.L176
	.word	.L174
	.text
.L180:
	lui	a5,%hi(UPPER_SPRITE_ACTIVE)
	lw	a5,%lo(UPPER_SPRITE_ACTIVE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L179:
	lui	a5,%hi(UPPER_SPRITE_TILE)
	lw	a5,%lo(UPPER_SPRITE_TILE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L178:
	lui	a5,%hi(UPPER_SPRITE_COLOUR)
	lw	a5,%lo(UPPER_SPRITE_COLOUR)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L177:
	lui	a5,%hi(UPPER_SPRITE_X)
	lw	a5,%lo(UPPER_SPRITE_X)(a5)
	lhu	a0,0(a5)
	slli	a0,a0,16
	srai	a0,a0,16
	ret
.L176:
	lui	a5,%hi(UPPER_SPRITE_Y)
	lw	a5,%lo(UPPER_SPRITE_Y)(a5)
	lhu	a0,0(a5)
	slli	a0,a0,16
	srai	a0,a0,16
	ret
.L174:
	lui	a5,%hi(UPPER_SPRITE_DOUBLE)
	lw	a5,%lo(UPPER_SPRITE_DOUBLE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L165:
	ret
	.size	get_sprite_attribute, .-get_sprite_attribute
	.align	1
	.globl	get_sprite_collision
	.type	get_sprite_collision, @function
get_sprite_collision:
	bne	a0,zero,.L182
	slli	a1,a1,1
	lui	a5,%hi(LOWER_SPRITE_COLLISION_BASE)
	lw	a5,%lo(LOWER_SPRITE_COLLISION_BASE)(a5)
	add	a1,a5,a1
	lhu	a0,0(a1)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
.L182:
	slli	a1,a1,1
	lui	a5,%hi(UPPER_SPRITE_COLLISION_BASE)
	lw	a5,%lo(UPPER_SPRITE_COLLISION_BASE)(a5)
	add	a1,a5,a1
	lhu	a0,0(a1)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
	.size	get_sprite_collision, .-get_sprite_collision
	.align	1
	.globl	update_sprite
	.type	update_sprite, @function
update_sprite:
	beq	a0,zero,.L185
	li	a5,1
	beq	a0,a5,.L186
	ret
.L185:
	lui	a5,%hi(LOWER_SPRITE_NUMBER)
	lw	a5,%lo(LOWER_SPRITE_NUMBER)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(LOWER_SPRITE_UPDATE)
	lw	a5,%lo(LOWER_SPRITE_UPDATE)(a5)
	sh	a2,0(a5)
	ret
.L186:
	lui	a5,%hi(UPPER_SPRITE_NUMBER)
	lw	a5,%lo(UPPER_SPRITE_NUMBER)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(UPPER_SPRITE_UPDATE)
	lw	a5,%lo(UPPER_SPRITE_UPDATE)(a5)
	sh	a2,0(a5)
	ret
	.size	update_sprite, .-update_sprite
	.align	1
	.globl	tpu_cs
	.type	tpu_cs, @function
tpu_cs:
	lui	a5,%hi(TPU_COMMIT)
	lw	a4,%lo(TPU_COMMIT)(a5)
.L189:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L189
	li	a5,3
	sb	a5,0(a4)
	ret
	.size	tpu_cs, .-tpu_cs
	.align	1
	.globl	tpu_set
	.type	tpu_set, @function
tpu_set:
	lui	a5,%hi(TPU_X)
	lw	a5,%lo(TPU_X)(a5)
	sb	a0,0(a5)
	lui	a5,%hi(TPU_Y)
	lw	a5,%lo(TPU_Y)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(TPU_BACKGROUND)
	lw	a5,%lo(TPU_BACKGROUND)(a5)
	sb	a2,0(a5)
	lui	a5,%hi(TPU_FOREGROUND)
	lw	a5,%lo(TPU_FOREGROUND)(a5)
	sb	a3,0(a5)
	lui	a5,%hi(TPU_COMMIT)
	lw	a5,%lo(TPU_COMMIT)(a5)
	li	a4,1
	sb	a4,0(a5)
	ret
	.size	tpu_set, .-tpu_set
	.align	1
	.globl	tpu_output_character
	.type	tpu_output_character, @function
tpu_output_character:
	lui	a5,%hi(TPU_COMMIT)
	lw	a4,%lo(TPU_COMMIT)(a5)
.L193:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L193
	lui	a5,%hi(TPU_CHARACTER)
	lw	a5,%lo(TPU_CHARACTER)(a5)
	sb	a0,0(a5)
	lui	a5,%hi(TPU_COMMIT)
	lw	a5,%lo(TPU_COMMIT)(a5)
	li	a4,2
	sb	a4,0(a5)
	ret
	.size	tpu_output_character, .-tpu_output_character
	.align	1
	.globl	tpu_outputstring
	.type	tpu_outputstring, @function
tpu_outputstring:
	lbu	a3,0(a0)
	beq	a3,zero,.L195
	lui	a2,%hi(TPU_COMMIT)
	lui	a6,%hi(TPU_CHARACTER)
	li	a1,2
.L198:
	lw	a4,%lo(TPU_COMMIT)(a2)
.L197:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L197
	lw	a5,%lo(TPU_CHARACTER)(a6)
	sb	a3,0(a5)
	lw	a5,%lo(TPU_COMMIT)(a2)
	sb	a1,0(a5)
	addi	a0,a0,1
	lbu	a3,0(a0)
	bne	a3,zero,.L198
.L195:
	ret
	.size	tpu_outputstring, .-tpu_outputstring
	.align	1
	.globl	tpu_outputnumber_char
	.type	tpu_outputnumber_char, @function
tpu_outputnumber_char:
	addi	sp,sp,-32
	sw	ra,28(sp)
	li	a5,3153920
	addi	a5,a5,32
	sw	a5,12(sp)
	addi	a1,sp,12
	call	chartostring
	addi	a0,sp,12
	call	tpu_outputstring
	lw	ra,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	tpu_outputnumber_char, .-tpu_outputnumber_char
	.align	1
	.globl	tpu_outputnumber_short
	.type	tpu_outputnumber_short, @function
tpu_outputnumber_short:
	addi	sp,sp,-32
	sw	ra,28(sp)
	li	a5,538976256
	addi	a5,a5,32
	sw	a5,8(sp)
	li	a5,48
	sh	a5,12(sp)
	addi	a1,sp,8
	call	shorttostring
	addi	a0,sp,8
	call	tpu_outputstring
	lw	ra,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	tpu_outputnumber_short, .-tpu_outputnumber_short
	.align	1
	.globl	tpu_outputnumber_int
	.type	tpu_outputnumber_int, @function
tpu_outputnumber_int:
	addi	sp,sp,-32
	sw	ra,28(sp)
	lui	a5,%hi(.LC0)
	addi	a5,a5,%lo(.LC0)
	lw	a3,0(a5)
	lw	a4,4(a5)
	sw	a3,4(sp)
	sw	a4,8(sp)
	lhu	a4,8(a5)
	sh	a4,12(sp)
	lbu	a5,10(a5)
	sb	a5,14(sp)
	addi	a1,sp,4
	call	inttostring
	addi	a0,sp,4
	call	tpu_outputstring
	lw	ra,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	tpu_outputnumber_int, .-tpu_outputnumber_int
	.align	1
	.globl	terminal_showhide
	.type	terminal_showhide, @function
terminal_showhide:
	lui	a5,%hi(TERMINAL_SHOWHIDE)
	lw	a5,%lo(TERMINAL_SHOWHIDE)(a5)
	sb	a0,0(a5)
	ret
	.size	terminal_showhide, .-terminal_showhide
	.globl	VBLANK
	.globl	SLEEPTIMER
	.globl	TIMER1KHZ
	.globl	TIMER1HZ
	.globl	ALT_RNG
	.globl	RNG
	.globl	AUDIO_R_START
	.globl	AUDIO_R_DURATION
	.globl	AUDIO_R_NOTE
	.globl	AUDIO_R_WAVEFORM
	.globl	AUDIO_L_START
	.globl	AUDIO_L_DURATION
	.globl	AUDIO_L_NOTE
	.globl	AUDIO_L_WAVEFORM
	.globl	TPU_COMMIT
	.globl	TPU_FOREGROUND
	.globl	TPU_BACKGROUND
	.globl	TPU_CHARACTER
	.globl	TPU_Y
	.globl	TPU_X
	.globl	UPPER_SPRITE_COLLISION_BASE
	.globl	UPPER_SPRITE_WRITER_BITMAP
	.globl	UPPER_SPRITE_WRITER_LINE
	.globl	UPPER_SPRITE_WRITER_NUMBER
	.globl	UPPER_SPRITE_UPDATE
	.globl	UPPER_SPRITE_DOUBLE
	.globl	UPPER_SPRITE_Y
	.globl	UPPER_SPRITE_X
	.globl	UPPER_SPRITE_COLOUR
	.globl	UPPER_SPRITE_TILE
	.globl	UPPER_SPRITE_ACTIVE
	.globl	UPPER_SPRITE_NUMBER
	.globl	LOWER_SPRITE_COLLISION_BASE
	.globl	LOWER_SPRITE_WRITER_BITMAP
	.globl	LOWER_SPRITE_WRITER_LINE
	.globl	LOWER_SPRITE_WRITER_NUMBER
	.globl	LOWER_SPRITE_UPDATE
	.globl	LOWER_SPRITE_DOUBLE
	.globl	LOWER_SPRITE_Y
	.globl	LOWER_SPRITE_X
	.globl	LOWER_SPRITE_COLOUR
	.globl	LOWER_SPRITE_TILE
	.globl	LOWER_SPRITE_ACTIVE
	.globl	LOWER_SPRITE_NUMBER
	.globl	BITMAP_Y_READ
	.globl	BITMAP_X_READ
	.globl	BITMAP_PIXEL_READ
	.globl	BITMAP_SCROLLWRAP
	.globl	VECTOR_WRITER_DELTAY
	.globl	VECTOR_WRITER_DELTAX
	.globl	VECTOR_WRITER_ACTIVE
	.globl	VECTOR_WRITER_VERTEX
	.globl	VECTOR_WRITER_BLOCK
	.globl	VECTOR_DRAW_STATUS
	.globl	VECTOR_DRAW_START
	.globl	VECTOR_DRAW_YC
	.globl	VECTOR_DRAW_XC
	.globl	VECTOR_DRAW_COLOUR
	.globl	VECTOR_DRAW_BLOCK
	.globl	BLIT_WRITER_BITMAP
	.globl	BLIT_WRITER_LINE
	.globl	BLIT_WRITER_TILE
	.globl	GPU_STATUS
	.globl	GPU_WRITE
	.globl	GPU_PARAM3
	.globl	GPU_PARAM2
	.globl	GPU_PARAM1
	.globl	GPU_PARAM0
	.globl	GPU_COLOUR
	.globl	GPU_Y
	.globl	GPU_X
	.globl	TM_STATUS
	.globl	TM_SCROLLWRAPCLEAR
	.globl	TM_WRITER_BITMAP
	.globl	TM_WRITER_LINE_NUMBER
	.globl	TM_WRITER_TILE_NUMBER
	.globl	TM_COMMIT
	.globl	TM_FOREGROUND
	.globl	TM_BACKGROUND
	.globl	TM_TILE
	.globl	TM_Y
	.globl	TM_X
	.globl	BACKGROUND_MODE
	.globl	BACKGROUND_ALTCOLOUR
	.globl	BACKGROUND_COLOUR
	.globl	TERMINAL_STATUS
	.globl	TERMINAL_SHOWHIDE
	.globl	TERMINAL_OUTPUT
	.globl	SDCARD_DATA
	.globl	SDCARD_ADDRESS
	.globl	SDCARD_SECTOR_HIGH
	.globl	SDCARD_SECTOR_LOW
	.globl	SDCARD_START
	.globl	SDCARD_READY
	.globl	LEDS
	.globl	BUTTONS
	.globl	UART_DATA
	.globl	UART_STATUS
	.section	.sdata,"aw"
	.align	2
	.type	VBLANK, @object
	.size	VBLANK, 4
VBLANK:
	.word	36848
	.type	SLEEPTIMER, @object
	.size	SLEEPTIMER, 4
SLEEPTIMER:
	.word	35120
	.type	TIMER1KHZ, @object
	.size	TIMER1KHZ, 4
TIMER1KHZ:
	.word	35104
	.type	TIMER1HZ, @object
	.size	TIMER1HZ, 4
TIMER1HZ:
	.word	35088
	.type	ALT_RNG, @object
	.size	ALT_RNG, 4
ALT_RNG:
	.word	35076
	.type	RNG, @object
	.size	RNG, 4
RNG:
	.word	35072
	.type	AUDIO_R_START, @object
	.size	AUDIO_R_START, 4
AUDIO_R_START:
	.word	34844
	.type	AUDIO_R_DURATION, @object
	.size	AUDIO_R_DURATION, 4
AUDIO_R_DURATION:
	.word	34840
	.type	AUDIO_R_NOTE, @object
	.size	AUDIO_R_NOTE, 4
AUDIO_R_NOTE:
	.word	34836
	.type	AUDIO_R_WAVEFORM, @object
	.size	AUDIO_R_WAVEFORM, 4
AUDIO_R_WAVEFORM:
	.word	34832
	.type	AUDIO_L_START, @object
	.size	AUDIO_L_START, 4
AUDIO_L_START:
	.word	34828
	.type	AUDIO_L_DURATION, @object
	.size	AUDIO_L_DURATION, 4
AUDIO_L_DURATION:
	.word	34824
	.type	AUDIO_L_NOTE, @object
	.size	AUDIO_L_NOTE, 4
AUDIO_L_NOTE:
	.word	34820
	.type	AUDIO_L_WAVEFORM, @object
	.size	AUDIO_L_WAVEFORM, 4
AUDIO_L_WAVEFORM:
	.word	34816
	.type	TPU_COMMIT, @object
	.size	TPU_COMMIT, 4
TPU_COMMIT:
	.word	34324
	.type	TPU_FOREGROUND, @object
	.size	TPU_FOREGROUND, 4
TPU_FOREGROUND:
	.word	34320
	.type	TPU_BACKGROUND, @object
	.size	TPU_BACKGROUND, 4
TPU_BACKGROUND:
	.word	34316
	.type	TPU_CHARACTER, @object
	.size	TPU_CHARACTER, 4
TPU_CHARACTER:
	.word	34312
	.type	TPU_Y, @object
	.size	TPU_Y, 4
TPU_Y:
	.word	34308
	.type	TPU_X, @object
	.size	TPU_X, 4
TPU_X:
	.word	34304
	.type	UPPER_SPRITE_COLLISION_BASE, @object
	.size	UPPER_SPRITE_COLLISION_BASE, 4
UPPER_SPRITE_COLLISION_BASE:
	.word	34096
	.type	UPPER_SPRITE_WRITER_BITMAP, @object
	.size	UPPER_SPRITE_WRITER_BITMAP, 4
UPPER_SPRITE_WRITER_BITMAP:
	.word	34088
	.type	UPPER_SPRITE_WRITER_LINE, @object
	.size	UPPER_SPRITE_WRITER_LINE, 4
UPPER_SPRITE_WRITER_LINE:
	.word	34084
	.type	UPPER_SPRITE_WRITER_NUMBER, @object
	.size	UPPER_SPRITE_WRITER_NUMBER, 4
UPPER_SPRITE_WRITER_NUMBER:
	.word	34080
	.type	UPPER_SPRITE_UPDATE, @object
	.size	UPPER_SPRITE_UPDATE, 4
UPPER_SPRITE_UPDATE:
	.word	34076
	.type	UPPER_SPRITE_DOUBLE, @object
	.size	UPPER_SPRITE_DOUBLE, 4
UPPER_SPRITE_DOUBLE:
	.word	34072
	.type	UPPER_SPRITE_Y, @object
	.size	UPPER_SPRITE_Y, 4
UPPER_SPRITE_Y:
	.word	34068
	.type	UPPER_SPRITE_X, @object
	.size	UPPER_SPRITE_X, 4
UPPER_SPRITE_X:
	.word	34064
	.type	UPPER_SPRITE_COLOUR, @object
	.size	UPPER_SPRITE_COLOUR, 4
UPPER_SPRITE_COLOUR:
	.word	34060
	.type	UPPER_SPRITE_TILE, @object
	.size	UPPER_SPRITE_TILE, 4
UPPER_SPRITE_TILE:
	.word	34056
	.type	UPPER_SPRITE_ACTIVE, @object
	.size	UPPER_SPRITE_ACTIVE, 4
UPPER_SPRITE_ACTIVE:
	.word	34052
	.type	UPPER_SPRITE_NUMBER, @object
	.size	UPPER_SPRITE_NUMBER, 4
UPPER_SPRITE_NUMBER:
	.word	34048
	.type	LOWER_SPRITE_COLLISION_BASE, @object
	.size	LOWER_SPRITE_COLLISION_BASE, 4
LOWER_SPRITE_COLLISION_BASE:
	.word	33584
	.type	LOWER_SPRITE_WRITER_BITMAP, @object
	.size	LOWER_SPRITE_WRITER_BITMAP, 4
LOWER_SPRITE_WRITER_BITMAP:
	.word	33576
	.type	LOWER_SPRITE_WRITER_LINE, @object
	.size	LOWER_SPRITE_WRITER_LINE, 4
LOWER_SPRITE_WRITER_LINE:
	.word	33572
	.type	LOWER_SPRITE_WRITER_NUMBER, @object
	.size	LOWER_SPRITE_WRITER_NUMBER, 4
LOWER_SPRITE_WRITER_NUMBER:
	.word	33568
	.type	LOWER_SPRITE_UPDATE, @object
	.size	LOWER_SPRITE_UPDATE, 4
LOWER_SPRITE_UPDATE:
	.word	33564
	.type	LOWER_SPRITE_DOUBLE, @object
	.size	LOWER_SPRITE_DOUBLE, 4
LOWER_SPRITE_DOUBLE:
	.word	33560
	.type	LOWER_SPRITE_Y, @object
	.size	LOWER_SPRITE_Y, 4
LOWER_SPRITE_Y:
	.word	33556
	.type	LOWER_SPRITE_X, @object
	.size	LOWER_SPRITE_X, 4
LOWER_SPRITE_X:
	.word	33552
	.type	LOWER_SPRITE_COLOUR, @object
	.size	LOWER_SPRITE_COLOUR, 4
LOWER_SPRITE_COLOUR:
	.word	33548
	.type	LOWER_SPRITE_TILE, @object
	.size	LOWER_SPRITE_TILE, 4
LOWER_SPRITE_TILE:
	.word	33544
	.type	LOWER_SPRITE_ACTIVE, @object
	.size	LOWER_SPRITE_ACTIVE, 4
LOWER_SPRITE_ACTIVE:
	.word	33540
	.type	LOWER_SPRITE_NUMBER, @object
	.size	LOWER_SPRITE_NUMBER, 4
LOWER_SPRITE_NUMBER:
	.word	33536
	.type	BITMAP_Y_READ, @object
	.size	BITMAP_Y_READ, 4
BITMAP_Y_READ:
	.word	33908
	.type	BITMAP_X_READ, @object
	.size	BITMAP_X_READ, 4
BITMAP_X_READ:
	.word	33904
	.type	BITMAP_PIXEL_READ, @object
	.size	BITMAP_PIXEL_READ, 4
BITMAP_PIXEL_READ:
	.word	33904
	.type	BITMAP_SCROLLWRAP, @object
	.size	BITMAP_SCROLLWRAP, 4
BITMAP_SCROLLWRAP:
	.word	33888
	.type	VECTOR_WRITER_DELTAY, @object
	.size	VECTOR_WRITER_DELTAY, 4
VECTOR_WRITER_DELTAY:
	.word	33856
	.type	VECTOR_WRITER_DELTAX, @object
	.size	VECTOR_WRITER_DELTAX, 4
VECTOR_WRITER_DELTAX:
	.word	33852
	.type	VECTOR_WRITER_ACTIVE, @object
	.size	VECTOR_WRITER_ACTIVE, 4
VECTOR_WRITER_ACTIVE:
	.word	33860
	.type	VECTOR_WRITER_VERTEX, @object
	.size	VECTOR_WRITER_VERTEX, 4
VECTOR_WRITER_VERTEX:
	.word	33848
	.type	VECTOR_WRITER_BLOCK, @object
	.size	VECTOR_WRITER_BLOCK, 4
VECTOR_WRITER_BLOCK:
	.word	33844
	.type	VECTOR_DRAW_STATUS, @object
	.size	VECTOR_DRAW_STATUS, 4
VECTOR_DRAW_STATUS:
	.word	33864
	.type	VECTOR_DRAW_START, @object
	.size	VECTOR_DRAW_START, 4
VECTOR_DRAW_START:
	.word	33840
	.type	VECTOR_DRAW_YC, @object
	.size	VECTOR_DRAW_YC, 4
VECTOR_DRAW_YC:
	.word	33836
	.type	VECTOR_DRAW_XC, @object
	.size	VECTOR_DRAW_XC, 4
VECTOR_DRAW_XC:
	.word	33832
	.type	VECTOR_DRAW_COLOUR, @object
	.size	VECTOR_DRAW_COLOUR, 4
VECTOR_DRAW_COLOUR:
	.word	33828
	.type	VECTOR_DRAW_BLOCK, @object
	.size	VECTOR_DRAW_BLOCK, 4
VECTOR_DRAW_BLOCK:
	.word	33824
	.type	BLIT_WRITER_BITMAP, @object
	.size	BLIT_WRITER_BITMAP, 4
BLIT_WRITER_BITMAP:
	.word	33880
	.type	BLIT_WRITER_LINE, @object
	.size	BLIT_WRITER_LINE, 4
BLIT_WRITER_LINE:
	.word	33876
	.type	BLIT_WRITER_TILE, @object
	.size	BLIT_WRITER_TILE, 4
BLIT_WRITER_TILE:
	.word	33872
	.type	GPU_STATUS, @object
	.size	GPU_STATUS, 4
GPU_STATUS:
	.word	33820
	.type	GPU_WRITE, @object
	.size	GPU_WRITE, 4
GPU_WRITE:
	.word	33820
	.type	GPU_PARAM3, @object
	.size	GPU_PARAM3, 4
GPU_PARAM3:
	.word	33816
	.type	GPU_PARAM2, @object
	.size	GPU_PARAM2, 4
GPU_PARAM2:
	.word	33812
	.type	GPU_PARAM1, @object
	.size	GPU_PARAM1, 4
GPU_PARAM1:
	.word	33808
	.type	GPU_PARAM0, @object
	.size	GPU_PARAM0, 4
GPU_PARAM0:
	.word	33804
	.type	GPU_COLOUR, @object
	.size	GPU_COLOUR, 4
GPU_COLOUR:
	.word	33800
	.type	GPU_Y, @object
	.size	GPU_Y, 4
GPU_Y:
	.word	33796
	.type	GPU_X, @object
	.size	GPU_X, 4
GPU_X:
	.word	33792
	.type	TM_STATUS, @object
	.size	TM_STATUS, 4
TM_STATUS:
	.word	33332
	.type	TM_SCROLLWRAPCLEAR, @object
	.size	TM_SCROLLWRAPCLEAR, 4
TM_SCROLLWRAPCLEAR:
	.word	33328
	.type	TM_WRITER_BITMAP, @object
	.size	TM_WRITER_BITMAP, 4
TM_WRITER_BITMAP:
	.word	33320
	.type	TM_WRITER_LINE_NUMBER, @object
	.size	TM_WRITER_LINE_NUMBER, 4
TM_WRITER_LINE_NUMBER:
	.word	33316
	.type	TM_WRITER_TILE_NUMBER, @object
	.size	TM_WRITER_TILE_NUMBER, 4
TM_WRITER_TILE_NUMBER:
	.word	33312
	.type	TM_COMMIT, @object
	.size	TM_COMMIT, 4
TM_COMMIT:
	.word	33300
	.type	TM_FOREGROUND, @object
	.size	TM_FOREGROUND, 4
TM_FOREGROUND:
	.word	33296
	.type	TM_BACKGROUND, @object
	.size	TM_BACKGROUND, 4
TM_BACKGROUND:
	.word	33292
	.type	TM_TILE, @object
	.size	TM_TILE, 4
TM_TILE:
	.word	33288
	.type	TM_Y, @object
	.size	TM_Y, 4
TM_Y:
	.word	33284
	.type	TM_X, @object
	.size	TM_X, 4
TM_X:
	.word	33280
	.type	BACKGROUND_MODE, @object
	.size	BACKGROUND_MODE, 4
BACKGROUND_MODE:
	.word	33032
	.type	BACKGROUND_ALTCOLOUR, @object
	.size	BACKGROUND_ALTCOLOUR, 4
BACKGROUND_ALTCOLOUR:
	.word	33028
	.type	BACKGROUND_COLOUR, @object
	.size	BACKGROUND_COLOUR, 4
BACKGROUND_COLOUR:
	.word	33024
	.type	TERMINAL_STATUS, @object
	.size	TERMINAL_STATUS, 4
TERMINAL_STATUS:
	.word	34560
	.type	TERMINAL_SHOWHIDE, @object
	.size	TERMINAL_SHOWHIDE, 4
TERMINAL_SHOWHIDE:
	.word	34564
	.type	TERMINAL_OUTPUT, @object
	.size	TERMINAL_OUTPUT, 4
TERMINAL_OUTPUT:
	.word	34560
	.type	SDCARD_DATA, @object
	.size	SDCARD_DATA, 4
SDCARD_DATA:
	.word	36624
	.type	SDCARD_ADDRESS, @object
	.size	SDCARD_ADDRESS, 4
SDCARD_ADDRESS:
	.word	36624
	.type	SDCARD_SECTOR_HIGH, @object
	.size	SDCARD_SECTOR_HIGH, 4
SDCARD_SECTOR_HIGH:
	.word	36612
	.type	SDCARD_SECTOR_LOW, @object
	.size	SDCARD_SECTOR_LOW, 4
SDCARD_SECTOR_LOW:
	.word	36616
	.type	SDCARD_START, @object
	.size	SDCARD_START, 4
SDCARD_START:
	.word	36608
	.type	SDCARD_READY, @object
	.size	SDCARD_READY, 4
SDCARD_READY:
	.word	36608
	.type	LEDS, @object
	.size	LEDS, 4
LEDS:
	.word	32780
	.type	BUTTONS, @object
	.size	BUTTONS, 4
BUTTONS:
	.word	32776
	.type	UART_DATA, @object
	.size	UART_DATA, 4
UART_DATA:
	.word	32768
	.type	UART_STATUS, @object
	.size	UART_STATUS, 4
UART_STATUS:
	.word	32772
	.ident	"GCC: (Arch Linux Repositories) 10.2.0"
