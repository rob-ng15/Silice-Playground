	.file	"asteroids.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.globl	inputcharacter
	.type	inputcharacter, @function
inputcharacter:
	lui	a5,%hi(UART_STATUS)
	lw	a4,%lo(UART_STATUS)(a5)
.L2:
	lbu	a5,0(a4)
	andi	a5,a5,1
	beq	a5,zero,.L2
	lui	a5,%hi(UART_DATA)
	lw	a5,%lo(UART_DATA)(a5)
	lbu	a0,0(a5)
	ret
	.size	inputcharacter, .-inputcharacter
	.align	2
	.globl	rng
	.type	rng, @function
rng:
	lui	a5,%hi(RNG)
	lw	a5,%lo(RNG)(a5)
	lhu	a5,0(a5)
	slli	a5,a5,16
	srai	a5,a5,16
	rem	a0,a5,a0
	slli	a0,a0,16
	srai	a0,a0,16
	ret
	.size	rng, .-rng
	.align	2
	.globl	set_timer1khz
	.type	set_timer1khz, @function
set_timer1khz:
	lui	a5,%hi(TIMER1KHZ)
	lw	a5,%lo(TIMER1KHZ)(a5)
	sh	a0,0(a5)
	ret
	.size	set_timer1khz, .-set_timer1khz
	.align	2
	.globl	wait_timer1khz
	.type	wait_timer1khz, @function
wait_timer1khz:
	lui	a5,%hi(TIMER1KHZ)
	lw	a4,%lo(TIMER1KHZ)(a5)
.L9:
	lhu	a5,0(a4)
	slli	a5,a5,16
	srai	a5,a5,16
	bne	a5,zero,.L9
	ret
	.size	wait_timer1khz, .-wait_timer1khz
	.align	2
	.globl	beep
	.type	beep, @function
beep:
	andi	a5,a0,1
	beq	a5,zero,.L12
	lui	a5,%hi(AUDIO_L_WAVEFORM)
	lw	a5,%lo(AUDIO_L_WAVEFORM)(a5)
	sb	a2,0(a5)
	lui	a5,%hi(AUDIO_L_NOTE)
	lw	a6,%lo(AUDIO_L_NOTE)(a5)
	addi	a5,a1,1
	andi	a5,a5,0xff
	sb	a3,0(a6)
	lui	a6,%hi(AUDIO_L_DURATION)
	lw	a7,%lo(AUDIO_L_DURATION)(a6)
	lui	a6,%hi(AUDIO_L_START)
	lw	a6,%lo(AUDIO_L_START)(a6)
	sh	a4,0(a7)
	sb	a5,0(a6)
.L12:
	andi	a0,a0,2
	beq	a0,zero,.L11
	lui	a5,%hi(AUDIO_R_WAVEFORM)
	lw	a5,%lo(AUDIO_R_WAVEFORM)(a5)
	addi	a1,a1,1
	andi	a1,a1,0xff
	sb	a2,0(a5)
	lui	a5,%hi(AUDIO_R_NOTE)
	lw	a5,%lo(AUDIO_R_NOTE)(a5)
	sb	a3,0(a5)
	lui	a5,%hi(AUDIO_R_DURATION)
	lw	a3,%lo(AUDIO_R_DURATION)(a5)
	lui	a5,%hi(AUDIO_R_START)
	lw	a5,%lo(AUDIO_R_START)(a5)
	sh	a4,0(a3)
	sb	a1,0(a5)
.L11:
	ret
	.size	beep, .-beep
	.align	2
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
	.align	2
	.globl	terminal_showhide
	.type	terminal_showhide, @function
terminal_showhide:
	lui	a5,%hi(TERMINAL_SHOWHIDE)
	lw	a5,%lo(TERMINAL_SHOWHIDE)(a5)
	sb	a0,0(a5)
	ret
	.size	terminal_showhide, .-terminal_showhide
	.align	2
	.globl	await_vblank
	.type	await_vblank, @function
await_vblank:
	lui	a5,%hi(VBLANK)
	lw	a4,%lo(VBLANK)(a5)
.L23:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	beq	a5,zero,.L23
	ret
	.size	await_vblank, .-await_vblank
	.align	2
	.globl	set_tilemap_tile
	.type	set_tilemap_tile, @function
set_tilemap_tile:
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
	.align	2
	.globl	set_tilemap_line
	.type	set_tilemap_line, @function
set_tilemap_line:
	lui	a5,%hi(TM_WRITER_TILE_NUMBER)
	lw	a5,%lo(TM_WRITER_TILE_NUMBER)(a5)
	sb	a0,0(a5)
	lui	a5,%hi(TM_WRITER_LINE_NUMBER)
	lw	a5,%lo(TM_WRITER_LINE_NUMBER)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(TM_WRITER_BITMAP)
	lw	a5,%lo(TM_WRITER_BITMAP)(a5)
	sh	a2,0(a5)
	ret
	.size	set_tilemap_line, .-set_tilemap_line
	.align	2
	.globl	tilemap_scrollwrapclear
	.type	tilemap_scrollwrapclear, @function
tilemap_scrollwrapclear:
	lui	a5,%hi(TM_STATUS)
	lw	a4,%lo(TM_STATUS)(a5)
.L29:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L29
	lui	a5,%hi(TM_SCROLLWRAPCLEAR)
	lw	a5,%lo(TM_SCROLLWRAPCLEAR)(a5)
	sb	a0,0(a5)
	ret
	.size	tilemap_scrollwrapclear, .-tilemap_scrollwrapclear
	.align	2
	.globl	gpu_rectangle
	.type	gpu_rectangle, @function
gpu_rectangle:
	lui	a5,%hi(GPU_STATUS)
	lw	a6,%lo(GPU_STATUS)(a5)
.L32:
	lbu	a5,0(a6)
	andi	a5,a5,0xff
	bne	a5,zero,.L32
	lui	a5,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a5)
	sb	a0,0(a5)
	lui	a5,%hi(GPU_X)
	lw	a6,%lo(GPU_X)(a5)
	lui	a5,%hi(GPU_Y)
	lw	a5,%lo(GPU_Y)(a5)
	lui	a0,%hi(GPU_PARAM0)
	lw	a0,%lo(GPU_PARAM0)(a0)
	sh	a1,0(a6)
	lui	a1,%hi(GPU_PARAM1)
	lw	a1,%lo(GPU_PARAM1)(a1)
	sh	a2,0(a5)
	lui	a5,%hi(GPU_WRITE)
	lw	a5,%lo(GPU_WRITE)(a5)
	sh	a3,0(a0)
	sh	a4,0(a1)
	li	a4,2
	sb	a4,0(a5)
	ret
	.size	gpu_rectangle, .-gpu_rectangle
	.align	2
	.globl	gpu_cs
	.type	gpu_cs, @function
gpu_cs:
	lui	a5,%hi(GPU_STATUS)
	lw	a4,%lo(GPU_STATUS)(a5)
.L35:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L35
	lui	a5,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a5)
	li	a4,64
	lui	a3,%hi(GPU_PARAM0)
	sb	a4,0(a5)
	lui	a5,%hi(GPU_X)
	lw	a4,%lo(GPU_X)(a5)
	lui	a5,%hi(GPU_Y)
	lw	a5,%lo(GPU_Y)(a5)
	lw	a3,%lo(GPU_PARAM0)(a3)
	sh	zero,0(a4)
	lui	a4,%hi(GPU_PARAM1)
	lw	a4,%lo(GPU_PARAM1)(a4)
	sh	zero,0(a5)
	lui	a5,%hi(GPU_WRITE)
	lw	a5,%lo(GPU_WRITE)(a5)
	li	a2,639
	sh	a2,0(a3)
	li	a3,479
	sh	a3,0(a4)
	li	a4,2
	sb	a4,0(a5)
	ret
	.size	gpu_cs, .-gpu_cs
	.align	2
	.globl	gpu_fillcircle
	.type	gpu_fillcircle, @function
gpu_fillcircle:
	lui	a5,%hi(GPU_STATUS)
	lw	a4,%lo(GPU_STATUS)(a5)
.L38:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L38
	lui	a5,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a5)
	lui	a4,%hi(GPU_Y)
	sb	a0,0(a5)
	lui	a5,%hi(GPU_X)
	lw	a5,%lo(GPU_X)(a5)
	lw	a0,%lo(GPU_Y)(a4)
	lui	a4,%hi(GPU_PARAM0)
	lw	a4,%lo(GPU_PARAM0)(a4)
	sh	a1,0(a5)
	lui	a5,%hi(GPU_WRITE)
	lw	a5,%lo(GPU_WRITE)(a5)
	sh	a2,0(a0)
	sh	a3,0(a4)
	li	a4,6
	sb	a4,0(a5)
	ret
	.size	gpu_fillcircle, .-gpu_fillcircle
	.align	2
	.globl	gpu_triangle
	.type	gpu_triangle, @function
gpu_triangle:
	lui	a7,%hi(GPU_STATUS)
	lw	t1,%lo(GPU_STATUS)(a7)
.L41:
	lbu	a7,0(t1)
	andi	a7,a7,0xff
	bne	a7,zero,.L41
	lui	a7,%hi(GPU_COLOUR)
	lw	a7,%lo(GPU_COLOUR)(a7)
	sb	a0,0(a7)
	lui	a0,%hi(GPU_X)
	lw	t1,%lo(GPU_X)(a0)
	lui	a0,%hi(GPU_Y)
	lw	a7,%lo(GPU_Y)(a0)
	lui	a0,%hi(GPU_PARAM0)
	lw	a0,%lo(GPU_PARAM0)(a0)
	sh	a1,0(t1)
	lui	a1,%hi(GPU_PARAM1)
	lw	a1,%lo(GPU_PARAM1)(a1)
	sh	a2,0(a7)
	lui	a2,%hi(GPU_PARAM2)
	lw	a2,%lo(GPU_PARAM2)(a2)
	sh	a3,0(a0)
	lui	a3,%hi(GPU_PARAM3)
	lw	a3,%lo(GPU_PARAM3)(a3)
	sh	a4,0(a1)
	lui	a4,%hi(GPU_WRITE)
	lw	a4,%lo(GPU_WRITE)(a4)
	sh	a5,0(a2)
	sh	a6,0(a3)
	li	a5,7
	sb	a5,0(a4)
	ret
	.size	gpu_triangle, .-gpu_triangle
	.align	2
	.globl	set_sprite
	.type	set_sprite, @function
set_sprite:
	beq	a0,zero,.L44
	li	t1,1
	bne	a0,t1,.L47
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
	lw	a1,%lo(UPPER_SPRITE_X)(a3)
	lui	a3,%hi(UPPER_SPRITE_Y)
	lw	a2,%lo(UPPER_SPRITE_Y)(a3)
	lui	a3,%hi(UPPER_SPRITE_DOUBLE)
	lw	a3,%lo(UPPER_SPRITE_DOUBLE)(a3)
	sh	a4,0(a1)
	sh	a5,0(a2)
	sb	a7,0(a3)
	ret
.L47:
	ret
.L44:
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
	lw	a1,%lo(LOWER_SPRITE_X)(a3)
	lui	a3,%hi(LOWER_SPRITE_Y)
	lw	a2,%lo(LOWER_SPRITE_Y)(a3)
	lui	a3,%hi(LOWER_SPRITE_DOUBLE)
	lw	a3,%lo(LOWER_SPRITE_DOUBLE)(a3)
	sh	a4,0(a1)
	sh	a5,0(a2)
	sb	a7,0(a3)
	ret
	.size	set_sprite, .-set_sprite
	.align	2
	.globl	get_sprite_attribute
	.type	get_sprite_attribute, @function
get_sprite_attribute:
	bne	a0,zero,.L49
	lui	a5,%hi(LOWER_SPRITE_NUMBER)
	lw	a4,%lo(LOWER_SPRITE_NUMBER)(a5)
	li	a5,5
	sb	a1,0(a4)
	bgtu	a2,a5,.L50
	lui	a5,%hi(.L52)
	addi	a5,a5,%lo(.L52)
	slli	a2,a2,2
	add	a2,a2,a5
	lw	a5,0(a2)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L52:
	.word	.L57
	.word	.L56
	.word	.L55
	.word	.L54
	.word	.L53
	.word	.L51
	.text
.L49:
	lui	a5,%hi(UPPER_SPRITE_NUMBER)
	lw	a4,%lo(UPPER_SPRITE_NUMBER)(a5)
	li	a5,5
	sb	a1,0(a4)
	bgtu	a2,a5,.L50
	lui	a5,%hi(.L60)
	addi	a5,a5,%lo(.L60)
	slli	a2,a2,2
	add	a2,a2,a5
	lw	a5,0(a2)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L60:
	.word	.L65
	.word	.L64
	.word	.L63
	.word	.L62
	.word	.L61
	.word	.L59
	.text
.L61:
	lui	a5,%hi(UPPER_SPRITE_Y)
	lw	a5,%lo(UPPER_SPRITE_Y)(a5)
	lhu	a0,0(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
.L51:
	lui	a5,%hi(LOWER_SPRITE_DOUBLE)
	lw	a5,%lo(LOWER_SPRITE_DOUBLE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L57:
	lui	a5,%hi(LOWER_SPRITE_ACTIVE)
	lw	a5,%lo(LOWER_SPRITE_ACTIVE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L56:
	lui	a5,%hi(LOWER_SPRITE_TILE)
	lw	a5,%lo(LOWER_SPRITE_TILE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L55:
	lui	a5,%hi(LOWER_SPRITE_COLOUR)
	lw	a5,%lo(LOWER_SPRITE_COLOUR)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L54:
	lui	a5,%hi(LOWER_SPRITE_X)
	lw	a5,%lo(LOWER_SPRITE_X)(a5)
	lhu	a0,0(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
.L53:
	lui	a5,%hi(LOWER_SPRITE_Y)
	lw	a5,%lo(LOWER_SPRITE_Y)(a5)
	lhu	a0,0(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
.L59:
	lui	a5,%hi(UPPER_SPRITE_DOUBLE)
	lw	a5,%lo(UPPER_SPRITE_DOUBLE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L65:
	lui	a5,%hi(UPPER_SPRITE_ACTIVE)
	lw	a5,%lo(UPPER_SPRITE_ACTIVE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L64:
	lui	a5,%hi(UPPER_SPRITE_TILE)
	lw	a5,%lo(UPPER_SPRITE_TILE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L63:
	lui	a5,%hi(UPPER_SPRITE_COLOUR)
	lw	a5,%lo(UPPER_SPRITE_COLOUR)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L62:
	lui	a5,%hi(UPPER_SPRITE_X)
	lw	a5,%lo(UPPER_SPRITE_X)(a5)
	lhu	a0,0(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
.L50:
	ret
	.size	get_sprite_attribute, .-get_sprite_attribute
	.align	2
	.globl	update_sprite
	.type	update_sprite, @function
update_sprite:
	beq	a0,zero,.L67
	li	a5,1
	bne	a0,a5,.L70
	lui	a5,%hi(UPPER_SPRITE_NUMBER)
	lw	a5,%lo(UPPER_SPRITE_NUMBER)(a5)
	andi	a2,a2,0xff
	sb	a1,0(a5)
	lui	a5,%hi(UPPER_SPRITE_UPDATE)
	lw	a5,%lo(UPPER_SPRITE_UPDATE)(a5)
	sb	a2,0(a5)
	ret
.L70:
	ret
.L67:
	lui	a5,%hi(LOWER_SPRITE_NUMBER)
	lw	a5,%lo(LOWER_SPRITE_NUMBER)(a5)
	andi	a2,a2,0xff
	sb	a1,0(a5)
	lui	a5,%hi(LOWER_SPRITE_UPDATE)
	lw	a5,%lo(LOWER_SPRITE_UPDATE)(a5)
	sb	a2,0(a5)
	ret
	.size	update_sprite, .-update_sprite
	.align	2
	.globl	set_sprite_line
	.type	set_sprite_line, @function
set_sprite_line:
	beq	a0,zero,.L72
	li	a5,1
	bne	a0,a5,.L75
	lui	a5,%hi(UPPER_SPRITE_WRITER_NUMBER)
	lw	a5,%lo(UPPER_SPRITE_WRITER_NUMBER)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(UPPER_SPRITE_WRITER_LINE)
	lw	a5,%lo(UPPER_SPRITE_WRITER_LINE)(a5)
	sb	a2,0(a5)
	lui	a5,%hi(UPPER_SPRITE_WRITER_BITMAP)
	lw	a5,%lo(UPPER_SPRITE_WRITER_BITMAP)(a5)
	sh	a3,0(a5)
	ret
.L75:
	ret
.L72:
	lui	a5,%hi(LOWER_SPRITE_WRITER_NUMBER)
	lw	a5,%lo(LOWER_SPRITE_WRITER_NUMBER)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(LOWER_SPRITE_WRITER_LINE)
	lw	a5,%lo(LOWER_SPRITE_WRITER_LINE)(a5)
	sb	a2,0(a5)
	lui	a5,%hi(LOWER_SPRITE_WRITER_BITMAP)
	lw	a5,%lo(LOWER_SPRITE_WRITER_BITMAP)(a5)
	sh	a3,0(a5)
	ret
	.size	set_sprite_line, .-set_sprite_line
	.align	2
	.globl	set_asteroid_sprites
	.type	set_asteroid_sprites, @function
set_asteroid_sprites:
	addi	sp,sp,-16
	sw	s0,12(sp)
	lui	s0,%hi(.LANCHOR0)
	sw	s1,8(sp)
	li	t2,0
	lui	t0,%hi(LOWER_SPRITE_WRITER_NUMBER)
	lui	t6,%hi(LOWER_SPRITE_WRITER_LINE)
	lui	t5,%hi(LOWER_SPRITE_WRITER_BITMAP)
	lui	t4,%hi(UPPER_SPRITE_WRITER_NUMBER)
	lui	t3,%hi(UPPER_SPRITE_WRITER_LINE)
	lui	t1,%hi(UPPER_SPRITE_WRITER_BITMAP)
	addi	s0,s0,%lo(.LANCHOR0)
	li	a7,128
	li	s1,12
.L77:
	andi	a3,t2,0xff
	mv	a4,s0
	li	a5,0
.L78:
	lw	a2,%lo(LOWER_SPRITE_WRITER_NUMBER)(t0)
	lhu	a6,0(a4)
	addi	a4,a4,2
	sb	a3,0(a2)
	lw	a2,%lo(LOWER_SPRITE_WRITER_LINE)(t6)
	addi	a0,a5,1
	sb	a5,0(a2)
	lw	a1,%lo(LOWER_SPRITE_WRITER_BITMAP)(t5)
	lw	a2,%lo(UPPER_SPRITE_WRITER_NUMBER)(t4)
	sh	a6,0(a1)
	lhu	a1,-2(a4)
	sb	a3,0(a2)
	lw	a2,%lo(UPPER_SPRITE_WRITER_LINE)(t3)
	sb	a5,0(a2)
	lw	a2,%lo(UPPER_SPRITE_WRITER_BITMAP)(t1)
	andi	a5,a0,0xff
	sh	a1,0(a2)
	bne	a5,a7,.L78
	addi	t2,t2,1
	slli	a5,t2,16
	srli	a5,a5,16
	slli	t2,t2,16
	srai	t2,t2,16
	bne	a5,s1,.L77
	lw	s0,12(sp)
	lw	s1,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	set_asteroid_sprites, .-set_asteroid_sprites
	.align	2
	.globl	set_ship_sprites
	.type	set_ship_sprites, @function
set_ship_sprites:
	snez	a5,a0
	lui	a4,%hi(.LANCHOR0+256)
	slli	a5,a5,8
	addi	a4,a4,%lo(.LANCHOR0+256)
	add	a4,a4,a5
	lui	t0,%hi(LOWER_SPRITE_WRITER_NUMBER)
	li	a5,0
	lui	t6,%hi(LOWER_SPRITE_WRITER_LINE)
	lui	t5,%hi(LOWER_SPRITE_WRITER_BITMAP)
	lui	t4,%hi(UPPER_SPRITE_WRITER_NUMBER)
	lui	t3,%hi(UPPER_SPRITE_WRITER_LINE)
	lui	t1,%hi(UPPER_SPRITE_WRITER_BITMAP)
	li	a3,11
	li	a7,128
.L85:
	lw	a2,%lo(LOWER_SPRITE_WRITER_NUMBER)(t0)
	lhu	a6,0(a4)
	addi	a4,a4,2
	sb	a3,0(a2)
	lw	a2,%lo(LOWER_SPRITE_WRITER_LINE)(t6)
	addi	a0,a5,1
	sb	a5,0(a2)
	lw	a1,%lo(LOWER_SPRITE_WRITER_BITMAP)(t5)
	lw	a2,%lo(UPPER_SPRITE_WRITER_NUMBER)(t4)
	sh	a6,0(a1)
	lhu	a1,-2(a4)
	sb	a3,0(a2)
	lw	a2,%lo(UPPER_SPRITE_WRITER_LINE)(t3)
	sb	a5,0(a2)
	lw	a2,%lo(UPPER_SPRITE_WRITER_BITMAP)(t1)
	andi	a5,a0,0xff
	sh	a1,0(a2)
	bne	a5,a7,.L85
	ret
	.size	set_ship_sprites, .-set_ship_sprites
	.align	2
	.globl	set_bullet_sprites
	.type	set_bullet_sprites, @function
set_bullet_sprites:
	lui	a4,%hi(.LANCHOR0+768)
	addi	a4,a4,%lo(.LANCHOR0+768)
	li	a5,0
	lui	t3,%hi(LOWER_SPRITE_WRITER_NUMBER)
	lui	t1,%hi(LOWER_SPRITE_WRITER_LINE)
	lui	a7,%hi(LOWER_SPRITE_WRITER_BITMAP)
	lui	a6,%hi(UPPER_SPRITE_WRITER_NUMBER)
	lui	a0,%hi(UPPER_SPRITE_WRITER_LINE)
	lui	a1,%hi(UPPER_SPRITE_WRITER_BITMAP)
	li	a3,12
	li	t2,64
.L88:
	lw	a2,%lo(LOWER_SPRITE_WRITER_NUMBER)(t3)
	lhu	t6,0(a4)
	addi	a4,a4,2
	sb	a3,0(a2)
	lw	a2,%lo(LOWER_SPRITE_WRITER_LINE)(t1)
	addi	t5,a5,1
	sb	a5,0(a2)
	lw	a2,%lo(LOWER_SPRITE_WRITER_BITMAP)(a7)
	lw	t4,%lo(LOWER_SPRITE_WRITER_NUMBER)(t3)
	sh	t6,0(a2)
	lhu	a2,126(a4)
	sb	a3,0(t4)
	lw	t4,%lo(LOWER_SPRITE_WRITER_LINE)(t1)
	sb	a5,0(t4)
	lw	t6,%lo(LOWER_SPRITE_WRITER_BITMAP)(a7)
	lw	t4,%lo(UPPER_SPRITE_WRITER_NUMBER)(a6)
	sh	a2,0(t6)
	lhu	t0,-2(a4)
	sb	a3,0(t4)
	lw	t4,%lo(UPPER_SPRITE_WRITER_LINE)(a0)
	sb	a5,0(t4)
	lw	t6,%lo(UPPER_SPRITE_WRITER_BITMAP)(a1)
	lw	t4,%lo(UPPER_SPRITE_WRITER_NUMBER)(a6)
	sh	t0,0(t6)
	sb	a3,0(t4)
	lw	t4,%lo(UPPER_SPRITE_WRITER_LINE)(a0)
	sb	a5,0(t4)
	lw	t4,%lo(UPPER_SPRITE_WRITER_BITMAP)(a1)
	andi	a5,t5,0xff
	sh	a2,0(t4)
	bne	a5,t2,.L88
	ret
	.size	set_bullet_sprites, .-set_bullet_sprites
	.align	2
	.globl	set_tilemap
	.type	set_tilemap, @function
set_tilemap:
	lui	a5,%hi(TM_STATUS)
	lw	a4,%lo(TM_STATUS)(a5)
	addi	sp,sp,-48
	sw	s0,44(sp)
	sw	s1,40(sp)
	sw	s2,36(sp)
	sw	s3,32(sp)
	sw	s4,28(sp)
	sw	s5,24(sp)
	sw	s6,20(sp)
	sw	s7,16(sp)
	sw	s8,12(sp)
	sw	s9,8(sp)
	sw	s10,4(sp)
	sw	s11,0(sp)
.L91:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L91
	lui	a5,%hi(TM_SCROLLWRAPCLEAR)
	lw	a5,%lo(TM_SCROLLWRAPCLEAR)(a5)
	li	a4,9
	lui	t4,%hi(.LANCHOR0+896)
	sb	a4,0(a5)
	addi	t4,t4,%lo(.LANCHOR0+896)
	li	a4,0
	lui	t3,%hi(TM_WRITER_TILE_NUMBER)
	lui	t1,%hi(TM_WRITER_LINE_NUMBER)
	lui	a7,%hi(TM_WRITER_BITMAP)
	li	a6,16
	li	t5,8
.L92:
	addi	a4,a4,1
	andi	a4,a4,0xff
	mv	a3,t4
	li	a5,0
.L93:
	lw	a2,%lo(TM_WRITER_TILE_NUMBER)(t3)
	lhu	a1,0(a3)
	addi	a0,a5,1
	sb	a4,0(a2)
	lw	a2,%lo(TM_WRITER_LINE_NUMBER)(t1)
	addi	a3,a3,2
	sb	a5,0(a2)
	lw	a2,%lo(TM_WRITER_BITMAP)(a7)
	andi	a5,a0,0xff
	sh	a1,0(a2)
	bne	a5,a6,.L93
	addi	t4,t4,32
	bne	a4,t5,.L92
	lui	t3,%hi(TM_X)
	lw	a3,%lo(TM_X)(t3)
	li	t5,4
	lui	t1,%hi(TM_Y)
	sb	t5,0(a3)
	lw	a2,%lo(TM_Y)(t1)
	lui	a7,%hi(TM_TILE)
	li	a3,1
	sb	t5,0(a2)
	lw	a2,%lo(TM_TILE)(a7)
	lui	a6,%hi(TM_BACKGROUND)
	li	a0,64
	sb	a3,0(a2)
	lw	a2,%lo(TM_BACKGROUND)(a6)
	lui	a1,%hi(TM_FOREGROUND)
	li	s3,21
	sb	a0,0(a2)
	lw	t6,%lo(TM_FOREGROUND)(a1)
	lui	a2,%hi(TM_COMMIT)
	li	t4,5
	sb	s3,0(t6)
	lw	t2,%lo(TM_COMMIT)(a2)
	li	t0,2
	li	t6,3
	sb	a3,0(t2)
	lw	t2,%lo(TM_X)(t3)
	li	s10,18
	li	s9,14
	sb	t5,0(t2)
	lw	t2,%lo(TM_Y)(t1)
	li	s2,20
	li	s7,15
	sb	t4,0(t2)
	lw	t2,%lo(TM_TILE)(a7)
	li	s8,19
	li	s6,34
	sb	t0,0(t2)
	lw	t2,%lo(TM_BACKGROUND)(a6)
	li	s5,28
	li	s11,29
	sb	a0,0(t2)
	lw	t2,%lo(TM_FOREGROUND)(a1)
	li	s1,42
	li	s0,6
	sb	s3,0(t2)
	lw	t2,%lo(TM_COMMIT)(a2)
	sb	a3,0(t2)
	lw	s4,%lo(TM_X)(t3)
	li	t2,7
	sb	t4,0(s4)
	lw	s4,%lo(TM_Y)(t1)
	sb	t5,0(s4)
	lw	s4,%lo(TM_TILE)(a7)
	sb	t6,0(s4)
	lw	s4,%lo(TM_BACKGROUND)(a6)
	sb	a0,0(s4)
	lw	s4,%lo(TM_FOREGROUND)(a1)
	sb	s3,0(s4)
	lw	s4,%lo(TM_COMMIT)(a2)
	sb	a3,0(s4)
	lw	s4,%lo(TM_X)(t3)
	sb	t4,0(s4)
	lw	s4,%lo(TM_Y)(t1)
	sb	t4,0(s4)
	lw	s4,%lo(TM_TILE)(a7)
	sb	t5,0(s4)
	lw	s4,%lo(TM_BACKGROUND)(a6)
	sb	a0,0(s4)
	lw	s4,%lo(TM_FOREGROUND)(a1)
	sb	s3,0(s4)
	lw	s3,%lo(TM_COMMIT)(a2)
	sb	a3,0(s3)
	lw	s3,%lo(TM_X)(t3)
	sb	s10,0(s3)
	lw	s3,%lo(TM_Y)(t1)
	sb	s9,0(s3)
	lw	s3,%lo(TM_TILE)(a7)
	sb	a3,0(s3)
	lw	s3,%lo(TM_BACKGROUND)(a6)
	sb	a0,0(s3)
	lw	s3,%lo(TM_FOREGROUND)(a1)
	sb	s2,0(s3)
	lw	s3,%lo(TM_COMMIT)(a2)
	sb	a3,0(s3)
	lw	s3,%lo(TM_X)(t3)
	sb	s10,0(s3)
	lw	s3,%lo(TM_Y)(t1)
	sb	s7,0(s3)
	lw	s3,%lo(TM_TILE)(a7)
	sb	t0,0(s3)
	lw	s3,%lo(TM_BACKGROUND)(a6)
	sb	a0,0(s3)
	lw	s3,%lo(TM_FOREGROUND)(a1)
	sb	s2,0(s3)
	lw	s3,%lo(TM_COMMIT)(a2)
	sb	a3,0(s3)
	lw	s3,%lo(TM_X)(t3)
	sb	s8,0(s3)
	lw	s3,%lo(TM_Y)(t1)
	sb	s9,0(s3)
	lw	s3,%lo(TM_TILE)(a7)
	sb	t6,0(s3)
	lw	s3,%lo(TM_BACKGROUND)(a6)
	sb	a0,0(s3)
	lw	s3,%lo(TM_FOREGROUND)(a1)
	sb	s2,0(s3)
	lw	s3,%lo(TM_COMMIT)(a2)
	sb	a3,0(s3)
	lw	s3,%lo(TM_X)(t3)
	sb	s8,0(s3)
	lw	s3,%lo(TM_Y)(t1)
	sb	s7,0(s3)
	lw	s3,%lo(TM_TILE)(a7)
	sb	t5,0(s3)
	lw	s3,%lo(TM_BACKGROUND)(a6)
	sb	a0,0(s3)
	lw	s3,%lo(TM_FOREGROUND)(a1)
	sb	s2,0(s3)
	lw	s2,%lo(TM_COMMIT)(a2)
	li	s3,35
	sb	a3,0(s2)
	lw	s2,%lo(TM_X)(t3)
	sb	s6,0(s2)
	lw	s2,%lo(TM_Y)(t1)
	sb	s5,0(s2)
	lw	s2,%lo(TM_TILE)(a7)
	sb	a3,0(s2)
	lw	s2,%lo(TM_BACKGROUND)(a6)
	sb	a0,0(s2)
	lw	s2,%lo(TM_FOREGROUND)(a1)
	sb	t4,0(s2)
	lw	s2,%lo(TM_COMMIT)(a2)
	sb	a3,0(s2)
	lw	s2,%lo(TM_X)(t3)
	sb	s6,0(s2)
	lw	s2,%lo(TM_Y)(t1)
	sb	s11,0(s2)
	lw	s2,%lo(TM_TILE)(a7)
	sb	t0,0(s2)
	lw	s2,%lo(TM_BACKGROUND)(a6)
	sb	a0,0(s2)
	lw	s2,%lo(TM_FOREGROUND)(a1)
	sb	t4,0(s2)
	lw	s2,%lo(TM_COMMIT)(a2)
	sb	a3,0(s2)
	lw	s2,%lo(TM_X)(t3)
	sb	s3,0(s2)
	lw	s2,%lo(TM_Y)(t1)
	sb	s5,0(s2)
	lw	s2,%lo(TM_TILE)(a7)
	sb	t6,0(s2)
	lw	s2,%lo(TM_BACKGROUND)(a6)
	sb	a0,0(s2)
	lw	s2,%lo(TM_FOREGROUND)(a1)
	sb	t4,0(s2)
	lw	s2,%lo(TM_COMMIT)(a2)
	sb	a3,0(s2)
	lw	s2,%lo(TM_X)(t3)
	sb	s3,0(s2)
	lw	s2,%lo(TM_Y)(t1)
	sb	s11,0(s2)
	lw	s2,%lo(TM_TILE)(a7)
	sb	t5,0(s2)
	lw	t5,%lo(TM_BACKGROUND)(a6)
	li	s2,36
	sb	a0,0(t5)
	lw	t5,%lo(TM_FOREGROUND)(a1)
	sb	t4,0(t5)
	lw	t5,%lo(TM_COMMIT)(a2)
	sb	a3,0(t5)
	lw	t5,%lo(TM_X)(t3)
	sb	s2,0(t5)
	lw	t5,%lo(TM_Y)(t1)
	sb	t0,0(t5)
	lw	t5,%lo(TM_TILE)(a7)
	sb	t4,0(t5)
	lw	t5,%lo(TM_BACKGROUND)(a6)
	sb	a0,0(t5)
	lw	t5,%lo(TM_FOREGROUND)(a1)
	sb	s1,0(t5)
	lw	t5,%lo(TM_COMMIT)(a2)
	sb	a3,0(t5)
	lw	t5,%lo(TM_X)(t3)
	sb	s2,0(t5)
	lw	t5,%lo(TM_Y)(t1)
	li	s2,37
	sb	t6,0(t5)
	lw	t5,%lo(TM_TILE)(a7)
	sb	s0,0(t5)
	lw	t5,%lo(TM_BACKGROUND)(a6)
	sb	a0,0(t5)
	lw	t5,%lo(TM_FOREGROUND)(a1)
	sb	s1,0(t5)
	lw	t5,%lo(TM_COMMIT)(a2)
	sb	a3,0(t5)
	lw	t5,%lo(TM_X)(t3)
	sb	s2,0(t5)
	lw	t5,%lo(TM_Y)(t1)
	sb	t0,0(t5)
	lw	t5,%lo(TM_TILE)(a7)
	sb	t2,0(t5)
	lw	t5,%lo(TM_BACKGROUND)(a6)
	sb	a0,0(t5)
	lw	t5,%lo(TM_FOREGROUND)(a1)
	sb	s1,0(t5)
	lw	t5,%lo(TM_COMMIT)(a2)
	sb	a3,0(t5)
	lw	t5,%lo(TM_X)(t3)
	sb	s2,0(t5)
	lw	t5,%lo(TM_Y)(t1)
	sb	t6,0(t5)
	lw	t5,%lo(TM_TILE)(a7)
	li	t6,26
	sb	a4,0(t5)
	lw	t5,%lo(TM_BACKGROUND)(a6)
	sb	a0,0(t5)
	lw	t5,%lo(TM_FOREGROUND)(a1)
	sb	s1,0(t5)
	lw	t5,%lo(TM_COMMIT)(a2)
	sb	a3,0(t5)
	lw	t5,%lo(TM_X)(t3)
	sb	s0,0(t5)
	lw	t5,%lo(TM_Y)(t1)
	sb	t6,0(t5)
	lw	t5,%lo(TM_TILE)(a7)
	sb	t4,0(t5)
	lw	t4,%lo(TM_BACKGROUND)(a6)
	li	t5,27
	sb	a0,0(t4)
	lw	t4,%lo(TM_FOREGROUND)(a1)
	sb	a5,0(t4)
	lw	t4,%lo(TM_COMMIT)(a2)
	sb	a3,0(t4)
	lw	t4,%lo(TM_X)(t3)
	sb	s0,0(t4)
	lw	t4,%lo(TM_Y)(t1)
	sb	t5,0(t4)
	lw	t4,%lo(TM_TILE)(a7)
	sb	s0,0(t4)
	lw	t4,%lo(TM_BACKGROUND)(a6)
	sb	a0,0(t4)
	lw	t4,%lo(TM_FOREGROUND)(a1)
	sb	a5,0(t4)
	lw	t4,%lo(TM_COMMIT)(a2)
	sb	a3,0(t4)
	lw	t4,%lo(TM_X)(t3)
	sb	t2,0(t4)
	lw	t4,%lo(TM_Y)(t1)
	sb	t6,0(t4)
	lw	t4,%lo(TM_TILE)(a7)
	sb	t2,0(t4)
	lw	t4,%lo(TM_BACKGROUND)(a6)
	sb	a0,0(t4)
	lw	t4,%lo(TM_FOREGROUND)(a1)
	sb	a5,0(t4)
	lw	t4,%lo(TM_COMMIT)(a2)
	sb	a3,0(t4)
	lw	t3,%lo(TM_X)(t3)
	sb	t2,0(t3)
	lw	t1,%lo(TM_Y)(t1)
	sb	t5,0(t1)
	lw	a7,%lo(TM_TILE)(a7)
	sb	a4,0(a7)
	lw	a4,%lo(TM_BACKGROUND)(a6)
	sb	a0,0(a4)
	lw	a4,%lo(TM_FOREGROUND)(a1)
	sb	a5,0(a4)
	lw	a5,%lo(TM_COMMIT)(a2)
	sb	a3,0(a5)
	lw	s0,44(sp)
	lw	s1,40(sp)
	lw	s2,36(sp)
	lw	s3,32(sp)
	lw	s4,28(sp)
	lw	s5,24(sp)
	lw	s6,20(sp)
	lw	s7,16(sp)
	lw	s8,12(sp)
	lw	s9,8(sp)
	lw	s10,4(sp)
	lw	s11,0(sp)
	addi	sp,sp,48
	jr	ra
	.size	set_tilemap, .-set_tilemap
	.align	2
	.globl	risc_ice_v_logo
	.type	risc_ice_v_logo, @function
risc_ice_v_logo:
	lui	a7,%hi(GPU_STATUS)
	lw	a4,%lo(GPU_STATUS)(a7)
.L99:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L99
	lui	a0,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a0)
	li	a4,64
	lui	a1,%hi(GPU_X)
	sb	a4,0(a5)
	lw	a4,%lo(GPU_X)(a1)
	lui	a2,%hi(GPU_Y)
	lw	a5,%lo(GPU_Y)(a2)
	lui	a3,%hi(GPU_PARAM0)
	lw	t3,%lo(GPU_PARAM0)(a3)
	lui	a6,%hi(GPU_PARAM1)
	lw	t1,%lo(GPU_PARAM1)(a6)
	sh	zero,0(a4)
	lui	a4,%hi(GPU_WRITE)
	sh	zero,0(a5)
	li	t4,639
	lw	a5,%lo(GPU_WRITE)(a4)
	sh	t4,0(t3)
	li	t3,479
	sh	t3,0(t1)
	li	t1,2
	sb	t1,0(a5)
	lw	t1,%lo(GPU_STATUS)(a7)
.L100:
	lbu	a5,0(t1)
	andi	a5,a5,0xff
	bne	a5,zero,.L100
	lw	t1,%lo(GPU_COLOUR)(a0)
	li	t3,56
	li	a5,100
	sb	t3,0(t1)
	lw	t3,%lo(GPU_X)(a1)
	lw	t1,%lo(GPU_Y)(a2)
	lw	t4,%lo(GPU_PARAM0)(a3)
	sh	zero,0(t3)
	lw	t3,%lo(GPU_PARAM1)(a6)
	sh	zero,0(t1)
	lw	t1,%lo(GPU_WRITE)(a4)
	sh	a5,0(t4)
	sh	a5,0(t3)
	li	a5,2
	sb	a5,0(t1)
	lw	t1,%lo(GPU_STATUS)(a7)
.L101:
	lbu	a5,0(t1)
	andi	a5,a5,0xff
	bne	a5,zero,.L101
	lw	t1,%lo(GPU_COLOUR)(a0)
	li	t3,63
	li	a5,100
	sb	t3,0(t1)
	lw	t1,%lo(GPU_X)(a1)
	lw	t3,%lo(GPU_Y)(a2)
	lw	t5,%lo(GPU_PARAM0)(a3)
	li	t6,33
	sh	a5,0(t1)
	lui	t4,%hi(GPU_PARAM2)
	lw	t1,%lo(GPU_PARAM1)(a6)
	sh	t6,0(t3)
	lw	t6,%lo(GPU_PARAM2)(t4)
	lui	t3,%hi(GPU_PARAM3)
	sh	a5,0(t5)
	lw	t5,%lo(GPU_PARAM3)(t3)
	li	t0,50
	sh	a5,0(t1)
	lw	t1,%lo(GPU_WRITE)(a4)
	sh	t0,0(t6)
	sh	a5,0(t5)
	li	a5,7
	sb	a5,0(t1)
	lw	t1,%lo(GPU_STATUS)(a7)
.L102:
	lbu	a5,0(t1)
	andi	a5,a5,0xff
	bne	a5,zero,.L102
	lw	t1,%lo(GPU_COLOUR)(a0)
	li	t5,2
	li	a5,100
	sb	t5,0(t1)
	lw	t1,%lo(GPU_X)(a1)
	lw	t6,%lo(GPU_Y)(a2)
	lw	t5,%lo(GPU_PARAM0)(a3)
	li	t0,50
	sh	a5,0(t1)
	lw	t1,%lo(GPU_PARAM1)(a6)
	sh	t0,0(t6)
	lw	t6,%lo(GPU_PARAM2)(t4)
	sh	a5,0(t5)
	lw	t5,%lo(GPU_PARAM3)(t3)
	li	t0,66
	sh	a5,0(t1)
	lw	t1,%lo(GPU_WRITE)(a4)
	sh	t0,0(t6)
	sh	a5,0(t5)
	li	a5,7
	sb	a5,0(t1)
	lw	t1,%lo(GPU_STATUS)(a7)
.L103:
	lbu	a5,0(t1)
	andi	a5,a5,0xff
	bne	a5,zero,.L103
	lw	t1,%lo(GPU_COLOUR)(a0)
	li	a5,2
	li	t0,33
	sb	a5,0(t1)
	lw	t5,%lo(GPU_X)(a1)
	lw	t1,%lo(GPU_Y)(a2)
	lw	t6,%lo(GPU_PARAM0)(a3)
	sh	zero,0(t5)
	lw	t5,%lo(GPU_PARAM1)(a6)
	sh	zero,0(t1)
	lw	t1,%lo(GPU_WRITE)(a4)
	sh	t0,0(t6)
	li	t6,50
	sh	t6,0(t5)
	sb	a5,0(t1)
	lw	t1,%lo(GPU_STATUS)(a7)
.L104:
	lbu	a5,0(t1)
	andi	a5,a5,0xff
	bne	a5,zero,.L104
	lw	t1,%lo(GPU_COLOUR)(a0)
	li	t5,63
	li	a5,25
	sb	t5,0(t1)
	lw	t1,%lo(GPU_X)(a1)
	lw	t6,%lo(GPU_Y)(a2)
	lw	t5,%lo(GPU_PARAM0)(a3)
	sh	a5,0(t1)
	lw	t1,%lo(GPU_WRITE)(a4)
	sh	a5,0(t6)
	li	a5,26
	sh	a5,0(t5)
	li	a5,6
	sb	a5,0(t1)
	lw	t1,%lo(GPU_STATUS)(a7)
.L105:
	lbu	a5,0(t1)
	andi	a5,a5,0xff
	bne	a5,zero,.L105
	lw	a5,%lo(GPU_COLOUR)(a0)
	li	t1,63
	li	t6,25
	sb	t1,0(a5)
	lw	t1,%lo(GPU_X)(a1)
	lw	a5,%lo(GPU_Y)(a2)
	lw	t5,%lo(GPU_PARAM0)(a3)
	sh	zero,0(t1)
	lw	t1,%lo(GPU_PARAM1)(a6)
	sh	zero,0(a5)
	lw	a5,%lo(GPU_WRITE)(a4)
	sh	t6,0(t5)
	li	t5,12
	sh	t5,0(t1)
	li	t1,2
	sb	t1,0(a5)
	lw	t1,%lo(GPU_STATUS)(a7)
.L106:
	lbu	a5,0(t1)
	andi	a5,a5,0xff
	bne	a5,zero,.L106
	lw	t1,%lo(GPU_COLOUR)(a0)
	li	t5,2
	li	a5,25
	sb	t5,0(t1)
	lw	t1,%lo(GPU_X)(a1)
	lw	t6,%lo(GPU_Y)(a2)
	lw	t5,%lo(GPU_PARAM0)(a3)
	sh	a5,0(t1)
	lw	t1,%lo(GPU_WRITE)(a4)
	sh	a5,0(t6)
	li	a5,12
	sh	a5,0(t5)
	li	a5,6
	sb	a5,0(t1)
	lw	t1,%lo(GPU_STATUS)(a7)
.L107:
	lbu	a5,0(t1)
	andi	a5,a5,0xff
	bne	a5,zero,.L107
	lw	a5,%lo(GPU_COLOUR)(a0)
	li	t1,63
	li	t6,33
	sb	t1,0(a5)
	lw	t1,%lo(GPU_X)(a1)
	lw	t5,%lo(GPU_Y)(a2)
	lw	a5,%lo(GPU_PARAM0)(a3)
	sh	zero,0(t1)
	lw	t1,%lo(GPU_PARAM1)(a6)
	sh	t6,0(t5)
	lw	t6,%lo(GPU_PARAM2)(t4)
	li	t5,67
	sh	t5,0(a5)
	lw	t5,%lo(GPU_PARAM3)(t3)
	li	a5,100
	sh	a5,0(t1)
	lw	t1,%lo(GPU_WRITE)(a4)
	sh	zero,0(t6)
	sh	a5,0(t5)
	li	a5,7
	sb	a5,0(t1)
	lw	t1,%lo(GPU_STATUS)(a7)
.L108:
	lbu	a5,0(t1)
	andi	a5,a5,0xff
	bne	a5,zero,.L108
	lw	t1,%lo(GPU_COLOUR)(a0)
	li	t5,2
	li	a5,50
	sb	t5,0(t1)
	lw	t1,%lo(GPU_X)(a1)
	lw	t6,%lo(GPU_Y)(a2)
	lw	t5,%lo(GPU_PARAM0)(a3)
	sh	zero,0(t1)
	lw	t1,%lo(GPU_PARAM1)(a6)
	lw	t4,%lo(GPU_PARAM2)(t4)
	sh	a5,0(t6)
	sh	a5,0(t5)
	lw	t3,%lo(GPU_PARAM3)(t3)
	li	a5,100
	sh	a5,0(t1)
	lw	t1,%lo(GPU_WRITE)(a4)
	sh	zero,0(t4)
	sh	a5,0(t3)
	li	a5,7
	sb	a5,0(t1)
	lw	t1,%lo(GPU_STATUS)(a7)
.L109:
	lbu	a5,0(t1)
	andi	a5,a5,0xff
	bne	a5,zero,.L109
	lw	t1,%lo(GPU_COLOUR)(a0)
	li	a5,2
	li	t5,12
	sb	a5,0(t1)
	lw	t3,%lo(GPU_X)(a1)
	lw	t1,%lo(GPU_Y)(a2)
	lw	t4,%lo(GPU_PARAM0)(a3)
	sh	zero,0(t3)
	lw	t3,%lo(GPU_PARAM1)(a6)
	sh	t5,0(t1)
	lw	t1,%lo(GPU_WRITE)(a4)
	li	t5,25
	sh	t5,0(t4)
	li	t4,37
	sh	t4,0(t3)
	sb	a5,0(t1)
	lw	a7,%lo(GPU_STATUS)(a7)
.L110:
	lbu	a5,0(a7)
	andi	a5,a5,0xff
	bne	a5,zero,.L110
	lw	a0,%lo(GPU_COLOUR)(a0)
	li	a5,2
	sb	a5,0(a0)
	lw	a0,%lo(GPU_X)(a1)
	lw	a1,%lo(GPU_Y)(a2)
	lw	a2,%lo(GPU_PARAM0)(a3)
	sh	zero,0(a0)
	lw	a3,%lo(GPU_PARAM1)(a6)
	li	a0,37
	sh	a0,0(a1)
	lw	a4,%lo(GPU_WRITE)(a4)
	li	a1,8
	sh	a1,0(a2)
	li	a2,100
	sh	a2,0(a3)
	sb	a5,0(a4)
	ret
	.size	risc_ice_v_logo, .-risc_ice_v_logo
	.align	2
	.globl	setup_game
	.type	setup_game, @function
setup_game:
	lui	a3,%hi(.LANCHOR1)
	addi	sp,sp,-32
	addi	a3,a3,%lo(.LANCHOR1)
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	sw	s5,4(sp)
	sw	s6,0(sp)
	addi	a2,a3,24
	li	a5,0
	lui	ra,%hi(UPPER_SPRITE_NUMBER)
	lui	t2,%hi(UPPER_SPRITE_ACTIVE)
	lui	t0,%hi(UPPER_SPRITE_TILE)
	lui	t6,%hi(UPPER_SPRITE_COLOUR)
	lui	t5,%hi(UPPER_SPRITE_X)
	lui	t4,%hi(UPPER_SPRITE_Y)
	lui	t3,%hi(UPPER_SPRITE_DOUBLE)
	li	a6,21
	li	t1,26
	li	a7,12
	lui	s6,%hi(LOWER_SPRITE_NUMBER)
	lui	s5,%hi(LOWER_SPRITE_ACTIVE)
	lui	s4,%hi(LOWER_SPRITE_TILE)
	lui	s3,%hi(LOWER_SPRITE_COLOUR)
	lui	s2,%hi(LOWER_SPRITE_X)
	lui	s1,%hi(LOWER_SPRITE_Y)
	lui	s0,%hi(LOWER_SPRITE_DOUBLE)
.L127:
	addi	a4,a5,-13
	andi	a4,a4,0xff
	addi	a1,a5,1
	bgtu	a5,a6,.L124
.L135:
	sb	zero,0(a3)
	sb	zero,0(a2)
	bgtu	a5,a7,.L124
	lw	a4,%lo(LOWER_SPRITE_NUMBER)(s6)
	addi	a3,a3,1
	addi	a2,a2,1
	sb	a5,0(a4)
	lw	a4,%lo(LOWER_SPRITE_ACTIVE)(s5)
	andi	a5,a1,0xff
	sb	zero,0(a4)
	lw	a4,%lo(LOWER_SPRITE_TILE)(s4)
	sb	zero,0(a4)
	lw	a4,%lo(LOWER_SPRITE_COLOUR)(s3)
	sb	zero,0(a4)
	lw	a0,%lo(LOWER_SPRITE_X)(s2)
	lw	a1,%lo(LOWER_SPRITE_Y)(s1)
	lw	a4,%lo(LOWER_SPRITE_DOUBLE)(s0)
	sh	zero,0(a0)
	sh	zero,0(a1)
	sb	zero,0(a4)
	addi	a4,a5,-13
	andi	a4,a4,0xff
	addi	a1,a5,1
	bleu	a5,a6,.L135
.L124:
	lw	a0,%lo(UPPER_SPRITE_NUMBER)(ra)
	andi	a5,a1,0xff
	addi	a3,a3,1
	sb	a4,0(a0)
	lw	a4,%lo(UPPER_SPRITE_ACTIVE)(t2)
	addi	a2,a2,1
	sb	zero,0(a4)
	lw	a4,%lo(UPPER_SPRITE_TILE)(t0)
	sb	zero,0(a4)
	lw	a4,%lo(UPPER_SPRITE_COLOUR)(t6)
	sb	zero,0(a4)
	lw	a0,%lo(UPPER_SPRITE_X)(t5)
	lw	a1,%lo(UPPER_SPRITE_Y)(t4)
	lw	a4,%lo(UPPER_SPRITE_DOUBLE)(t3)
	sh	zero,0(a0)
	sh	zero,0(a1)
	sb	zero,0(a4)
	bne	a5,t1,.L127
	lui	a5,%hi(GPU_STATUS)
	lw	a4,%lo(GPU_STATUS)(a5)
.L128:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L128
	lui	a5,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a5)
	li	a4,64
	lui	a3,%hi(GPU_PARAM0)
	sb	a4,0(a5)
	lui	a5,%hi(GPU_X)
	lw	a4,%lo(GPU_X)(a5)
	lui	a5,%hi(GPU_Y)
	lw	a5,%lo(GPU_Y)(a5)
	lw	a3,%lo(GPU_PARAM0)(a3)
	sh	zero,0(a4)
	lui	a4,%hi(GPU_PARAM1)
	lw	a4,%lo(GPU_PARAM1)(a4)
	sh	zero,0(a5)
	lui	a5,%hi(GPU_WRITE)
	lw	a5,%lo(GPU_WRITE)(a5)
	li	a2,639
	sh	a2,0(a3)
	li	a3,479
	sh	a3,0(a4)
	li	a4,2
	sb	a4,0(a5)
	lui	a5,%hi(TERMINAL_SHOWHIDE)
	lw	a5,%lo(TERMINAL_SHOWHIDE)(a5)
	li	a4,42
	sb	zero,0(a5)
	lui	a5,%hi(BACKGROUND_COLOUR)
	lw	a5,%lo(BACKGROUND_COLOUR)(a5)
	sb	a4,0(a5)
	lui	a5,%hi(BACKGROUND_ALTCOLOUR)
	lw	a5,%lo(BACKGROUND_ALTCOLOUR)(a5)
	li	a4,1
	sb	a4,0(a5)
	lui	a5,%hi(BACKGROUND_MODE)
	lw	a5,%lo(BACKGROUND_MODE)(a5)
	li	a4,7
	sb	a4,0(a5)
	call	risc_ice_v_logo
	lui	a5,%hi(TM_STATUS)
	lw	a4,%lo(TM_STATUS)(a5)
.L129:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L129
	lui	a5,%hi(TM_SCROLLWRAPCLEAR)
	lw	a5,%lo(TM_SCROLLWRAPCLEAR)(a5)
	li	a4,9
	sb	a4,0(a5)
	call	set_tilemap
	call	set_asteroid_sprites
	li	a0,0
	call	set_ship_sprites
	lui	a5,%hi(lives)
	sw	zero,%lo(lives)(a5)
	lui	a5,%hi(score)
	sw	zero,%lo(score)(a5)
	li	a4,312
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	li	a4,232
	sh	a4,%lo(shipy)(a5)
	lui	a5,%hi(shipdirection)
	sh	zero,%lo(shipdirection)(a5)
	lui	a5,%hi(resetship)
	lw	ra,28(sp)
	lw	s0,24(sp)
	sh	zero,%lo(resetship)(a5)
	lui	a5,%hi(bulletdirection)
	sh	zero,%lo(bulletdirection)(a5)
	lui	a5,%hi(counter)
	sw	zero,%lo(counter)(a5)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	lw	s4,8(sp)
	lw	s5,4(sp)
	lw	s6,0(sp)
	addi	sp,sp,32
	jr	ra
	.size	setup_game, .-setup_game
	.align	2
	.globl	find_asteroid_space
	.type	find_asteroid_space, @function
find_asteroid_space:
	lui	a4,%hi(.LANCHOR1)
	addi	a4,a4,%lo(.LANCHOR1)
	li	a5,0
	li	a0,255
	li	a1,22
.L138:
	lbu	a2,0(a4)
	addi	a3,a5,1
	addi	a4,a4,1
	bne	a2,zero,.L137
	mv	a0,a5
.L137:
	andi	a5,a3,0xff
	bne	a5,a1,.L138
	ret
	.size	find_asteroid_space, .-find_asteroid_space
	.align	2
	.globl	new_asteroid
	.type	new_asteroid, @function
new_asteroid:
	lui	a4,%hi(.LANCHOR1)
	addi	t6,a4,%lo(.LANCHOR1)
	mv	t3,a0
	addi	a4,a4,%lo(.LANCHOR1)
	li	a1,255
	li	a5,0
	li	a6,22
.L143:
	lbu	a2,0(a4)
	addi	a3,a5,1
	addi	a4,a4,1
	bne	a2,zero,.L142
	mv	a1,a5
.L142:
	andi	a5,a3,0xff
	bne	a5,a6,.L143
	li	a5,255
	beq	a1,a5,.L141
	lui	a5,%hi(shipx)
	lh	a6,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lh	a7,%lo(shipy)(a5)
	lui	a5,%hi(RNG)
	addi	t4,a6,-64
	addi	t5,a7,-64
	lw	a2,%lo(RNG)(a5)
	addi	a6,a6,64
	addi	a7,a7,64
	li	a0,640
	li	t1,480
	j	.L146
.L153:
	blt	a6,a3,.L145
	andi	a3,a5,255
	bgt	t5,a3,.L145
	blt	a7,a3,.L145
.L146:
	lhu	a4,0(a2)
	lhu	a5,0(a2)
	slli	a4,a4,16
	srai	a4,a4,16
	rem	a4,a4,a0
	slli	a5,a5,16
	srai	a5,a5,16
	andi	a3,a4,255
	rem	a5,a5,t1
	ble	t4,a3,.L153
.L145:
	add	a3,t6,a1
	sb	t3,0(a3)
	li	a3,2
	li	a7,4
	beq	t3,a3,.L147
	li	a7,8
.L147:
	lhu	a3,0(a2)
	add	a6,t6,a1
	sltiu	a0,a1,11
	slli	a3,a3,16
	srai	a3,a3,16
	rem	a3,a3,a7
	li	a7,10
	xori	a0,a0,1
	sb	a3,24(a6)
	bleu	a1,a7,.L148
	addi	a1,a1,-11
	andi	a1,a1,0xff
.L148:
	lhu	a3,0(a2)
	lhu	a6,0(a2)
	li	a2,7
	slli	a3,a3,16
	slli	a6,a6,16
	srai	a6,a6,16
	rem	a6,a6,a2
	srai	a3,a3,16
	srai	a2,a3,31
	srli	a2,a2,27
	add	a3,a3,a2
	andi	a3,a3,31
	sub	a3,a3,a2
	addi	a7,t3,-2
	addi	a3,a3,32
	seqz	a7,a7
	andi	a5,a5,0xff
	andi	a4,a4,0xff
	andi	a3,a3,0xff
	li	a2,1
	andi	a6,a6,0xff
	tail	set_sprite
.L141:
	ret
	.size	new_asteroid, .-new_asteroid
	.align	2
	.globl	new_level
	.type	new_level, @function
new_level:
	lui	a4,%hi(.LANCHOR1)
	addi	sp,sp,-32
	addi	a4,a4,%lo(.LANCHOR1)
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	sw	s5,4(sp)
	addi	a3,a4,24
	li	a5,0
	lui	s4,%hi(LOWER_SPRITE_NUMBER)
	lui	s3,%hi(LOWER_SPRITE_ACTIVE)
	lui	s2,%hi(LOWER_SPRITE_TILE)
	lui	s1,%hi(LOWER_SPRITE_COLOUR)
	lui	s0,%hi(LOWER_SPRITE_X)
	lui	ra,%hi(LOWER_SPRITE_Y)
	lui	t2,%hi(LOWER_SPRITE_DOUBLE)
	lui	t0,%hi(UPPER_SPRITE_NUMBER)
	lui	t6,%hi(UPPER_SPRITE_ACTIVE)
	lui	t5,%hi(UPPER_SPRITE_TILE)
	lui	t4,%hi(UPPER_SPRITE_COLOUR)
	lui	t3,%hi(UPPER_SPRITE_X)
	lui	t1,%hi(UPPER_SPRITE_Y)
	lui	a7,%hi(UPPER_SPRITE_DOUBLE)
	li	a6,22
.L155:
	lw	a2,%lo(LOWER_SPRITE_NUMBER)(s4)
	sb	zero,0(a4)
	sb	zero,0(a3)
	sb	a5,0(a2)
	lw	a2,%lo(LOWER_SPRITE_ACTIVE)(s3)
	addi	a1,a5,1
	addi	a4,a4,1
	sb	zero,0(a2)
	lw	a2,%lo(LOWER_SPRITE_TILE)(s2)
	addi	a3,a3,1
	sb	zero,0(a2)
	lw	a2,%lo(LOWER_SPRITE_COLOUR)(s1)
	sb	zero,0(a2)
	lw	s5,%lo(LOWER_SPRITE_X)(s0)
	lw	a0,%lo(LOWER_SPRITE_Y)(ra)
	lw	a2,%lo(LOWER_SPRITE_DOUBLE)(t2)
	sh	zero,0(s5)
	sh	zero,0(a0)
	sb	zero,0(a2)
	lw	a2,%lo(UPPER_SPRITE_NUMBER)(t0)
	sb	a5,0(a2)
	lw	a2,%lo(UPPER_SPRITE_ACTIVE)(t6)
	andi	a5,a1,0xff
	sb	zero,0(a2)
	lw	a2,%lo(UPPER_SPRITE_TILE)(t5)
	sb	zero,0(a2)
	lw	a2,%lo(UPPER_SPRITE_COLOUR)(t4)
	sb	zero,0(a2)
	lw	a0,%lo(UPPER_SPRITE_X)(t3)
	lw	a1,%lo(UPPER_SPRITE_Y)(t1)
	lw	a2,%lo(UPPER_SPRITE_DOUBLE)(a7)
	sh	zero,0(a0)
	sh	zero,0(a1)
	sb	zero,0(a2)
	bne	a5,a6,.L155
	lui	a5,%hi(RNG)
	lw	a5,%lo(RNG)(a5)
	li	s0,0
	lhu	a5,0(a5)
	slli	a5,a5,16
	srai	a5,a5,16
	srai	s1,a5,31
	srli	a4,s1,30
	add	s1,a5,a4
	andi	s1,s1,3
	sub	s1,s1,a4
	addi	s1,s1,4
	andi	s1,s1,0xff
.L156:
	addi	s0,s0,1
	li	a0,2
	andi	s0,s0,0xff
	call	new_asteroid
	bgtu	s1,s0,.L156
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	lw	s4,8(sp)
	lw	s5,4(sp)
	addi	sp,sp,32
	jr	ra
	.size	new_level, .-new_level
	.align	2
	.globl	move_asteroids
	.type	move_asteroids, @function
move_asteroids:
	lui	a4,%hi(.LANCHOR1)
	addi	a4,a4,%lo(.LANCHOR1)
	lui	t1,%hi(.LANCHOR0)
	addi	a1,a4,24
	li	a5,0
	li	a6,22
	addi	t1,t1,%lo(.LANCHOR0)
	li	t3,10
	lui	t0,%hi(LOWER_SPRITE_NUMBER)
	lui	t6,%hi(LOWER_SPRITE_UPDATE)
	lui	t5,%hi(UPPER_SPRITE_NUMBER)
	lui	t4,%hi(UPPER_SPRITE_UPDATE)
.L164:
	lbu	a3,0(a4)
	addi	a0,a5,1
	beq	a3,zero,.L161
	lbu	a3,0(a1)
	addi	a2,a5,-11
	andi	a2,a2,0xff
	slli	a3,a3,1
	add	a3,t1,a3
	lbu	a3,1152(a3)
	bleu	a5,t3,.L162
	lw	a5,%lo(UPPER_SPRITE_NUMBER)(t5)
	sb	a2,0(a5)
	lw	a5,%lo(UPPER_SPRITE_UPDATE)(t4)
	sb	a3,0(a5)
.L161:
	andi	a5,a0,0xff
	addi	a4,a4,1
	addi	a1,a1,1
	bne	a5,a6,.L164
	ret
.L162:
	lw	a2,%lo(LOWER_SPRITE_NUMBER)(t0)
	addi	a4,a4,1
	addi	a1,a1,1
	sb	a5,0(a2)
	lw	a2,%lo(LOWER_SPRITE_UPDATE)(t6)
	andi	a5,a0,0xff
	sb	a3,0(a2)
	j	.L164
	.size	move_asteroids, .-move_asteroids
	.align	2
	.globl	count_asteroids
	.type	count_asteroids, @function
count_asteroids:
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	addi	a1,a5,22
	li	a2,0
.L171:
	lbu	a3,0(a5)
	slli	a0,a2,16
	srli	a0,a0,16
	addi	a5,a5,1
	addi	a4,a0,1
	beq	a3,zero,.L170
	slli	a0,a4,16
	slli	a2,a4,16
	srli	a0,a0,16
	srai	a2,a2,16
.L170:
	bne	a5,a1,.L171
	ret
	.size	count_asteroids, .-count_asteroids
	.align	2
	.globl	draw_ship
	.type	draw_ship, @function
draw_ship:
	lui	a5,%hi(LOWER_SPRITE_NUMBER)
	lw	a5,%lo(LOWER_SPRITE_NUMBER)(a5)
	li	a4,11
	lui	a1,%hi(shipx)
	lui	a2,%hi(shipy)
	lui	a3,%hi(shipdirection)
	lbu	a7,%lo(shipdirection)(a3)
	lh	t4,%lo(shipx)(a1)
	lh	t1,%lo(shipy)(a2)
	sb	a4,0(a5)
	lui	a5,%hi(LOWER_SPRITE_ACTIVE)
	lw	a6,%lo(LOWER_SPRITE_ACTIVE)(a5)
	li	a5,1
	sb	a5,0(a6)
	lui	a6,%hi(LOWER_SPRITE_TILE)
	lw	a6,%lo(LOWER_SPRITE_TILE)(a6)
	sb	a7,0(a6)
	lui	a6,%hi(LOWER_SPRITE_COLOUR)
	lw	a6,%lo(LOWER_SPRITE_COLOUR)(a6)
	sb	a0,0(a6)
	lui	a6,%hi(LOWER_SPRITE_X)
	lw	t3,%lo(LOWER_SPRITE_X)(a6)
	lui	a6,%hi(LOWER_SPRITE_Y)
	lw	a7,%lo(LOWER_SPRITE_Y)(a6)
	lui	a6,%hi(LOWER_SPRITE_DOUBLE)
	lw	a6,%lo(LOWER_SPRITE_DOUBLE)(a6)
	sh	t4,0(t3)
	sh	t1,0(a7)
	sb	zero,0(a6)
	lui	a6,%hi(UPPER_SPRITE_NUMBER)
	lw	a6,%lo(UPPER_SPRITE_NUMBER)(a6)
	lh	a1,%lo(shipx)(a1)
	lh	a2,%lo(shipy)(a2)
	lbu	a3,%lo(shipdirection)(a3)
	sb	a4,0(a6)
	lui	a4,%hi(UPPER_SPRITE_ACTIVE)
	lw	a4,%lo(UPPER_SPRITE_ACTIVE)(a4)
	sb	a5,0(a4)
	lui	a5,%hi(UPPER_SPRITE_TILE)
	lw	a5,%lo(UPPER_SPRITE_TILE)(a5)
	sb	a3,0(a5)
	lui	a5,%hi(UPPER_SPRITE_COLOUR)
	lw	a5,%lo(UPPER_SPRITE_COLOUR)(a5)
	sb	a0,0(a5)
	lui	a5,%hi(UPPER_SPRITE_X)
	lw	a4,%lo(UPPER_SPRITE_X)(a5)
	lui	a5,%hi(UPPER_SPRITE_Y)
	lw	a5,%lo(UPPER_SPRITE_Y)(a5)
	sh	a1,0(a4)
	sh	a2,0(a5)
	lui	a5,%hi(UPPER_SPRITE_DOUBLE)
	lw	a5,%lo(UPPER_SPRITE_DOUBLE)(a5)
	sb	zero,0(a5)
	ret
	.size	draw_ship, .-draw_ship
	.align	2
	.globl	move_ship
	.type	move_ship, @function
move_ship:
	lui	a5,%hi(shipdirection)
	lh	a3,%lo(shipdirection)(a5)
	li	a5,7
	slli	a4,a3,16
	srli	a4,a4,16
	bgtu	a4,a5,.L177
	lui	a4,%hi(.L180)
	slli	a5,a3,2
	addi	a4,a4,%lo(.L180)
	add	a5,a5,a4
	lw	a5,0(a5)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L180:
	.word	.L187
	.word	.L186
	.word	.L185
	.word	.L184
	.word	.L183
	.word	.L182
	.word	.L181
	.word	.L179
	.text
.L179:
	lui	a4,%hi(shipx)
	lh	a5,%lo(shipx)(a4)
	li	a2,624
	ble	a5,zero,.L198
	addi	a5,a5,-1
	slli	a2,a5,16
	srai	a2,a2,16
.L198:
	lui	a5,%hi(shipy)
	lh	a3,%lo(shipy)(a5)
	sh	a2,%lo(shipx)(a4)
	li	a4,0
	ble	a3,zero,.L199
	addi	a3,a3,-1
	slli	a4,a3,16
	srai	a4,a4,16
.L199:
	sh	a4,%lo(shipy)(a5)
.L177:
	ret
.L181:
	lui	a4,%hi(shipx)
	lh	a5,%lo(shipx)(a4)
	li	a3,624
	ble	a5,zero,.L197
	addi	a5,a5,-1
	slli	a3,a5,16
	srai	a3,a3,16
.L197:
	sh	a3,%lo(shipx)(a4)
	ret
.L187:
	lui	a5,%hi(shipy)
	lh	a4,%lo(shipy)(a5)
	ble	a4,zero,.L194
	addi	a4,a4,-1
	slli	a3,a4,16
	srai	a3,a3,16
.L194:
	sh	a3,%lo(shipy)(a5)
	ret
.L186:
	lui	a4,%hi(shipx)
	lh	a5,%lo(shipx)(a4)
	li	a3,623
	li	a2,624
	bgt	a5,a3,.L198
	addi	a5,a5,1
	slli	a2,a5,16
	srai	a2,a2,16
	j	.L198
.L185:
	lui	a4,%hi(shipx)
	lh	a5,%lo(shipx)(a4)
	li	a2,623
	li	a3,624
	bgt	a5,a2,.L197
	addi	a5,a5,1
	slli	a3,a5,16
	srai	a3,a3,16
	j	.L197
.L184:
	lui	a4,%hi(shipx)
	lh	a5,%lo(shipx)(a4)
	li	a3,623
	li	a2,624
	bgt	a5,a3,.L195
	addi	a5,a5,1
	slli	a2,a5,16
	srai	a2,a2,16
.L195:
	lui	a5,%hi(shipy)
	lh	a3,%lo(shipy)(a5)
	sh	a2,%lo(shipx)(a4)
	li	a2,463
	li	a4,464
	bgt	a3,a2,.L199
	addi	a3,a3,1
	slli	a4,a3,16
	srai	a4,a4,16
	j	.L199
.L183:
	lui	a5,%hi(shipy)
	lh	a4,%lo(shipy)(a5)
	li	a2,463
	li	a3,464
	bgt	a4,a2,.L194
	addi	a4,a4,1
	slli	a3,a4,16
	srai	a3,a3,16
	j	.L194
.L182:
	lui	a4,%hi(shipx)
	lh	a5,%lo(shipx)(a4)
	li	a2,624
	ble	a5,zero,.L195
	addi	a5,a5,-1
	slli	a2,a5,16
	srai	a2,a2,16
	j	.L195
	.size	move_ship, .-move_ship
	.align	2
	.globl	draw_lives
	.type	draw_lives, @function
draw_lives:
	ret
	.size	draw_lives, .-draw_lives
	.align	2
	.globl	fire_bullet
	.type	fire_bullet, @function
fire_bullet:
	lui	a5,%hi(shipdirection)
	lh	a5,%lo(shipdirection)(a5)
	lui	a4,%hi(bulletdirection)
	li	a2,7
	slli	a1,a5,16
	sh	a5,%lo(bulletdirection)(a4)
	srli	a1,a1,16
	li	a3,0
	li	a4,0
	bgtu	a1,a2,.L217
	lui	a4,%hi(.L219)
	slli	a5,a5,2
	addi	a4,a4,%lo(.L219)
	add	a5,a5,a4
	lw	a5,0(a5)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L219:
	.word	.L226
	.word	.L225
	.word	.L224
	.word	.L223
	.word	.L222
	.word	.L221
	.word	.L220
	.word	.L218
	.text
.L218:
	lui	a5,%hi(shipx)
	lhu	a3,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lhu	a4,%lo(shipy)(a5)
	addi	a3,a3,-10
.L227:
	addi	a4,a4,-10
	slli	a3,a3,16
	slli	a4,a4,16
	srai	a3,a3,16
	srai	a4,a4,16
.L217:
	lui	a5,%hi(LOWER_SPRITE_NUMBER)
	lw	a5,%lo(LOWER_SPRITE_NUMBER)(a5)
	li	a2,12
	li	a0,2
	sb	a2,0(a5)
	lui	a5,%hi(LOWER_SPRITE_ACTIVE)
	lw	a1,%lo(LOWER_SPRITE_ACTIVE)(a5)
	li	a5,1
	sb	a5,0(a1)
	lui	a1,%hi(LOWER_SPRITE_TILE)
	lw	a1,%lo(LOWER_SPRITE_TILE)(a1)
	sb	a0,0(a1)
	lui	a1,%hi(LOWER_SPRITE_COLOUR)
	lw	a1,%lo(LOWER_SPRITE_COLOUR)(a1)
	li	a0,60
	sb	a0,0(a1)
	lui	a1,%hi(LOWER_SPRITE_X)
	lw	a6,%lo(LOWER_SPRITE_X)(a1)
	lui	a1,%hi(LOWER_SPRITE_Y)
	lw	a0,%lo(LOWER_SPRITE_Y)(a1)
	lui	a1,%hi(LOWER_SPRITE_DOUBLE)
	lw	a1,%lo(LOWER_SPRITE_DOUBLE)(a1)
	sh	a3,0(a6)
	sh	a4,0(a0)
	sb	zero,0(a1)
	lui	a1,%hi(UPPER_SPRITE_NUMBER)
	lw	a1,%lo(UPPER_SPRITE_NUMBER)(a1)
	sb	a2,0(a1)
	lui	a2,%hi(UPPER_SPRITE_ACTIVE)
	lw	a2,%lo(UPPER_SPRITE_ACTIVE)(a2)
	sb	a5,0(a2)
	lui	a5,%hi(UPPER_SPRITE_TILE)
	lw	a5,%lo(UPPER_SPRITE_TILE)(a5)
	li	a2,48
	sb	zero,0(a5)
	lui	a5,%hi(UPPER_SPRITE_COLOUR)
	lw	a5,%lo(UPPER_SPRITE_COLOUR)(a5)
	sb	a2,0(a5)
	lui	a5,%hi(UPPER_SPRITE_X)
	lw	a1,%lo(UPPER_SPRITE_X)(a5)
	lui	a5,%hi(UPPER_SPRITE_Y)
	lw	a2,%lo(UPPER_SPRITE_Y)(a5)
	lui	a5,%hi(UPPER_SPRITE_DOUBLE)
	lw	a5,%lo(UPPER_SPRITE_DOUBLE)(a5)
	sh	a3,0(a1)
	sh	a4,0(a2)
	sb	zero,0(a5)
	ret
.L220:
	lui	a5,%hi(shipx)
	lhu	a3,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lh	a4,%lo(shipy)(a5)
	addi	a3,a3,-10
	slli	a3,a3,16
	srai	a3,a3,16
	j	.L217
.L226:
	lui	a5,%hi(shipy)
	lhu	a4,%lo(shipy)(a5)
	lui	a5,%hi(shipx)
	lh	a3,%lo(shipx)(a5)
	addi	a4,a4,-10
	slli	a4,a4,16
	srai	a4,a4,16
	j	.L217
.L225:
	lui	a5,%hi(shipx)
	lhu	a3,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lhu	a4,%lo(shipy)(a5)
	addi	a3,a3,8
	j	.L227
.L224:
	lui	a5,%hi(shipx)
	lhu	a3,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lh	a4,%lo(shipy)(a5)
	addi	a3,a3,10
	slli	a3,a3,16
	srai	a3,a3,16
	j	.L217
.L223:
	lui	a5,%hi(shipx)
	lhu	a3,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lhu	a4,%lo(shipy)(a5)
	addi	a3,a3,10
.L228:
	addi	a4,a4,10
	slli	a3,a3,16
	slli	a4,a4,16
	srai	a3,a3,16
	srai	a4,a4,16
	j	.L217
.L222:
	lui	a5,%hi(shipy)
	lhu	a4,%lo(shipy)(a5)
	lui	a5,%hi(shipx)
	lh	a3,%lo(shipx)(a5)
	addi	a4,a4,10
	slli	a4,a4,16
	srai	a4,a4,16
	j	.L217
.L221:
	lui	a5,%hi(shipx)
	lhu	a3,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lhu	a4,%lo(shipy)(a5)
	addi	a3,a3,-10
	j	.L228
	.size	fire_bullet, .-fire_bullet
	.align	2
	.globl	update_bullet
	.type	update_bullet, @function
update_bullet:
	lui	a5,%hi(bulletdirection)
	lh	a5,%lo(bulletdirection)(a5)
	lui	a4,%hi(LOWER_SPRITE_NUMBER)
	lw	a3,%lo(LOWER_SPRITE_NUMBER)(a4)
	slli	a4,a5,1
	lui	a5,%hi(.LANCHOR0)
	addi	a5,a5,%lo(.LANCHOR0)
	add	a5,a5,a4
	lhu	a5,1176(a5)
	li	a4,12
	sb	a4,0(a3)
	lui	a4,%hi(LOWER_SPRITE_UPDATE)
	lw	a4,%lo(LOWER_SPRITE_UPDATE)(a4)
	addi	a5,a5,384
	andi	a5,a5,0xff
	sb	a5,0(a4)
	ret
	.size	update_bullet, .-update_bullet
	.align	2
	.globl	beepboop
	.type	beepboop, @function
beepboop:
	lui	a5,%hi(TIMER1HZ)
	lw	a4,%lo(TIMER1HZ)(a5)
	lui	a3,%hi(last_timer)
	lh	a2,%lo(last_timer)(a3)
	lhu	a5,0(a4)
	slli	a5,a5,16
	srai	a5,a5,16
	beq	a2,a5,.L230
	lhu	a5,0(a4)
	li	a2,2
	sh	a5,%lo(last_timer)(a3)
	lhu	a5,0(a4)
	andi	a5,a5,3
	beq	a5,a2,.L232
	li	a4,3
	beq	a5,a4,.L233
	li	a4,1
	beq	a5,a4,.L234
	lui	a5,%hi(AUDIO_L_WAVEFORM)
	lw	a5,%lo(AUDIO_L_WAVEFORM)(a5)
	li	a3,500
	sb	zero,0(a5)
	lui	a5,%hi(AUDIO_L_NOTE)
	lw	a5,%lo(AUDIO_L_NOTE)(a5)
	sb	a4,0(a5)
	lui	a5,%hi(AUDIO_L_DURATION)
	lw	a4,%lo(AUDIO_L_DURATION)(a5)
	lui	a5,%hi(AUDIO_L_START)
	lw	a5,%lo(AUDIO_L_START)(a5)
	sh	a3,0(a4)
	sb	a2,0(a5)
.L234:
	lui	a5,%hi(TM_STATUS)
	lw	a4,%lo(TM_STATUS)(a5)
.L235:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L235
	lui	a5,%hi(TM_SCROLLWRAPCLEAR)
	lw	a5,%lo(TM_SCROLLWRAPCLEAR)(a5)
	li	a4,5
	sb	a4,0(a5)
	ret
.L233:
	lui	a5,%hi(TM_STATUS)
	lw	a4,%lo(TM_STATUS)(a5)
.L236:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L236
	lui	a5,%hi(TM_SCROLLWRAPCLEAR)
	lw	a5,%lo(TM_SCROLLWRAPCLEAR)(a5)
	li	a4,6
	sb	a4,0(a5)
.L230:
	ret
.L232:
	lui	a4,%hi(AUDIO_R_WAVEFORM)
	lw	a4,%lo(AUDIO_R_WAVEFORM)(a4)
	li	a2,500
	sb	zero,0(a4)
	lui	a4,%hi(AUDIO_R_NOTE)
	lw	a4,%lo(AUDIO_R_NOTE)(a4)
	sb	a5,0(a4)
	lui	a4,%hi(AUDIO_R_DURATION)
	lw	a3,%lo(AUDIO_R_DURATION)(a4)
	lui	a4,%hi(AUDIO_R_START)
	lw	a4,%lo(AUDIO_R_START)(a4)
	sh	a2,0(a3)
	sb	a5,0(a4)
	ret
	.size	beepboop, .-beepboop
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
	lui	a5,%hi(UART_STATUS)
	lw	a4,%lo(UART_STATUS)(a5)
	addi	sp,sp,-80
	sw	ra,76(sp)
	sw	s0,72(sp)
	sw	s1,68(sp)
	sw	s2,64(sp)
	sw	s3,60(sp)
	sw	s4,56(sp)
	sw	s5,52(sp)
	sw	s6,48(sp)
	sw	s7,44(sp)
	sw	s8,40(sp)
	sw	s9,36(sp)
	sw	s10,32(sp)
	sw	s11,28(sp)
	lbu	a5,0(a4)
	andi	a5,a5,1
	beq	a5,zero,.L290
.L242:
	lbu	a5,0(a4)
	andi	a5,a5,1
	beq	a5,zero,.L242
	lbu	a5,0(a4)
	andi	a5,a5,1
	bne	a5,zero,.L242
.L290:
	call	setup_game
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	sw	a5,4(sp)
	lui	a5,%hi(.LANCHOR0)
	lui	a1,%hi(.LANCHOR1+22)
	addi	a5,a5,%lo(.LANCHOR0)
	lui	s0,%hi(counter)
	addi	s4,a1,%lo(.LANCHOR1+22)
	lui	s1,%hi(TIMER1KHZ)
	sw	a5,12(sp)
	lui	s3,%hi(LOWER_SPRITE_NUMBER)
	lui	s11,%hi(LOWER_SPRITE_ACTIVE)
	lui	s10,%hi(LOWER_SPRITE_TILE)
	lui	s9,%hi(LOWER_SPRITE_COLOUR)
	lui	s8,%hi(LOWER_SPRITE_X)
	lui	s7,%hi(UPPER_SPRITE_NUMBER)
	lui	s6,%hi(UPPER_SPRITE_ACTIVE)
	lui	s5,%hi(UPPER_SPRITE_TILE)
	li	s2,12
.L241:
	lw	a4,%lo(counter)(s0)
	lw	a5,4(sp)
	li	a3,0
	addi	a4,a4,1
	sw	a4,%lo(counter)(s0)
.L245:
	lbu	a4,0(a5)
	addi	a2,a3,1
	addi	a5,a5,1
	beq	a4,zero,.L244
	slli	a3,a2,16
	srai	a3,a3,16
.L244:
	bne	s4,a5,.L245
	beq	a3,zero,.L291
.L246:
	lui	a5,%hi(VBLANK)
	lw	a4,%lo(VBLANK)(a5)
.L247:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	beq	a5,zero,.L247
	lw	a4,%lo(TIMER1KHZ)(s1)
	lui	a5,%hi(lives)
	lw	a5,%lo(lives)(a5)
	li	a3,20
	sh	a3,0(a4)
	ble	a5,zero,.L248
	lui	a5,%hi(resetship)
	lh	a5,%lo(resetship)(a5)
	beq	a5,zero,.L292
.L249:
	li	a0,21
	call	draw_ship
	lw	a5,%lo(LOWER_SPRITE_NUMBER)(s3)
	sb	s2,0(a5)
	lw	a5,%lo(LOWER_SPRITE_ACTIVE)(s11)
	sb	zero,0(a5)
	lw	a5,%lo(LOWER_SPRITE_TILE)(s10)
	sb	zero,0(a5)
	lw	a5,%lo(LOWER_SPRITE_COLOUR)(s9)
	sb	zero,0(a5)
	lw	a3,%lo(LOWER_SPRITE_X)(s8)
	lui	a5,%hi(LOWER_SPRITE_Y)
	lw	a4,%lo(LOWER_SPRITE_Y)(a5)
	lui	a5,%hi(LOWER_SPRITE_DOUBLE)
	lw	a5,%lo(LOWER_SPRITE_DOUBLE)(a5)
	sh	zero,0(a3)
	sh	zero,0(a4)
	sb	zero,0(a5)
	lw	a5,%lo(UPPER_SPRITE_NUMBER)(s7)
	sb	s2,0(a5)
	lw	a5,%lo(UPPER_SPRITE_ACTIVE)(s6)
	sb	zero,0(a5)
	lw	a5,%lo(UPPER_SPRITE_TILE)(s5)
	sb	zero,0(a5)
	lui	a5,%hi(UPPER_SPRITE_COLOUR)
	lw	a5,%lo(UPPER_SPRITE_COLOUR)(a5)
	sb	zero,0(a5)
	lui	a5,%hi(UPPER_SPRITE_X)
	lw	a3,%lo(UPPER_SPRITE_X)(a5)
	lui	a5,%hi(UPPER_SPRITE_Y)
	lw	a4,%lo(UPPER_SPRITE_Y)(a5)
	lui	a5,%hi(UPPER_SPRITE_DOUBLE)
	lw	a5,%lo(UPPER_SPRITE_DOUBLE)(a5)
	sh	zero,0(a3)
	sh	zero,0(a4)
	sb	zero,0(a5)
.L257:
	call	move_asteroids
	lw	a4,%lo(TIMER1KHZ)(s1)
.L258:
	lhu	a5,0(a4)
	slli	a5,a5,16
	srai	a5,a5,16
	bne	a5,zero,.L258
	j	.L241
.L248:
	bne	a5,zero,.L249
	lui	a5,%hi(BUTTONS)
	lw	a5,%lo(BUTTONS)(a5)
	lbu	a5,0(a5)
	andi	a5,a5,4
	beq	a5,zero,.L249
	lui	a5,%hi(lives)
	li	a4,3
	sw	a4,%lo(lives)(a5)
	lui	a5,%hi(score)
	li	a4,312
	sw	zero,%lo(score)(a5)
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	li	a4,232
	sh	a4,%lo(shipy)(a5)
	lui	a5,%hi(shipdirection)
	sh	zero,%lo(shipdirection)(a5)
	lui	a5,%hi(resetship)
	sh	zero,%lo(resetship)(a5)
	lui	a5,%hi(bulletdirection)
	sw	zero,%lo(counter)(s0)
	sh	zero,%lo(bulletdirection)(a5)
	call	new_level
	j	.L249
.L291:
	call	new_level
	j	.L246
.L292:
	sw	a5,8(sp)
	call	beepboop
	lui	a5,%hi(BUTTONS)
	lw	a3,%lo(BUTTONS)(a5)
	lw	a5,8(sp)
	lbu	a4,0(a3)
	andi	a4,a4,2
	bne	a4,zero,.L293
.L250:
	lbu	a4,0(a3)
	andi	a4,a4,8
	bne	a4,zero,.L294
.L251:
	lw	a4,%lo(counter)(s0)
	andi	a4,a4,3
	bne	a4,zero,.L253
	lui	a4,%hi(BUTTONS)
	lw	a3,%lo(BUTTONS)(a4)
	lbu	a4,0(a3)
	andi	a4,a4,32
	beq	a4,zero,.L254
	lui	a4,%hi(shipdirection)
	lh	a4,%lo(shipdirection)(a4)
	li	a2,7
	beq	a4,zero,.L255
	addi	a4,a4,-1
	slli	a2,a4,16
	srai	a2,a2,16
.L255:
	lui	a4,%hi(shipdirection)
	sh	a2,%lo(shipdirection)(a4)
.L254:
	lbu	a4,0(a3)
	andi	a4,a4,64
	beq	a4,zero,.L253
	lui	a4,%hi(shipdirection)
	lh	a4,%lo(shipdirection)(a4)
	li	a3,7
	beq	a4,a3,.L256
	addi	a5,a4,1
	slli	a5,a5,16
	srai	a5,a5,16
.L256:
	lui	a4,%hi(shipdirection)
	sh	a5,%lo(shipdirection)(a4)
.L253:
	li	a0,63
	call	draw_ship
	lui	a5,%hi(bulletdirection)
	lh	a5,%lo(bulletdirection)(a5)
	lw	a3,12(sp)
	lw	a4,%lo(LOWER_SPRITE_NUMBER)(s3)
	slli	a5,a5,1
	add	a5,a3,a5
	lhu	a5,1176(a5)
	sb	s2,0(a4)
	lui	a4,%hi(LOWER_SPRITE_UPDATE)
	lw	a4,%lo(LOWER_SPRITE_UPDATE)(a4)
	addi	a5,a5,384
	andi	a5,a5,0xff
	sb	a5,0(a4)
	j	.L257
.L294:
	sw	a5,8(sp)
	call	move_ship
	lw	a5,8(sp)
	j	.L251
.L293:
	call	fire_bullet
	lui	a5,%hi(AUDIO_L_WAVEFORM)
	lw	a2,%lo(AUDIO_L_WAVEFORM)(a5)
	li	a5,4
	li	a3,61
	sb	a5,0(a2)
	lui	a2,%hi(AUDIO_L_NOTE)
	lw	a2,%lo(AUDIO_L_NOTE)(a2)
	li	a4,128
	sb	a3,0(a2)
	lui	a2,%hi(AUDIO_L_DURATION)
	lw	a1,%lo(AUDIO_L_DURATION)(a2)
	lui	a2,%hi(AUDIO_L_START)
	lw	a2,%lo(AUDIO_L_START)(a2)
	sh	a4,0(a1)
	li	a1,3
	sb	a1,0(a2)
	lui	a2,%hi(AUDIO_R_WAVEFORM)
	lw	a2,%lo(AUDIO_R_WAVEFORM)(a2)
	sb	a5,0(a2)
	lui	a5,%hi(AUDIO_R_NOTE)
	lw	a2,%lo(AUDIO_R_NOTE)(a5)
	lui	a5,%hi(AUDIO_R_DURATION)
	sb	a3,0(a2)
	lw	a2,%lo(AUDIO_R_DURATION)(a5)
	lui	a5,%hi(AUDIO_R_START)
	lw	a3,%lo(AUDIO_R_START)(a5)
	sh	a4,0(a2)
	lui	a5,%hi(BUTTONS)
	sb	a1,0(a3)
	lw	a3,%lo(BUTTONS)(a5)
	lw	a5,8(sp)
	j	.L250
	.size	main, .-main
	.globl	tilemap_bitmap
	.globl	bullet_bitmap
	.globl	ship_bitmap
	.globl	asteroid_bitmap
	.globl	asteroid_directions
	.globl	bullet_directions
	.globl	last_timer
	.globl	asteroid_direction
	.globl	asteroid_active
	.globl	bulletdirection
	.globl	resetship
	.globl	shipdirection
	.globl	shipy
	.globl	shipx
	.globl	counter
	.globl	score
	.globl	lives
	.globl	VBLANK
	.globl	SLEEPTIMER
	.globl	TIMER1KHZ
	.globl	TIMER1HZ
	.globl	RNG
	.globl	AUDIO_R_START
	.globl	AUDIO_R_DURATION
	.globl	AUDIO_R_NOTE
	.globl	AUDIO_R_WAVEFORM
	.globl	AUDIO_L_START
	.globl	AUDIO_L_DURATION
	.globl	AUDIO_L_NOTE
	.globl	AUDIO_L_WAVEFORM
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
	.globl	LEDS
	.globl	BUTTONS
	.globl	UART_DATA
	.globl	UART_STATUS
	.data
	.align	2
	.set	.LANCHOR0,. + 0
	.type	asteroid_bitmap, @object
	.size	asteroid_bitmap, 256
asteroid_bitmap:
	.half	2032
	.half	4088
	.half	8190
	.half	8191
	.half	16383
	.half	-1
	.half	-2
	.half	-4
	.half	-1
	.half	32767
	.half	32767
	.half	32766
	.half	16380
	.half	16380
	.half	4088
	.half	240
	.half	4104
	.half	15388
	.half	32542
	.half	-1
	.half	32766
	.half	32766
	.half	16376
	.half	16368
	.half	8184
	.half	4088
	.half	8188
	.half	32766
	.half	-1
	.half	32766
	.half	15868
	.half	6264
	.half	1927
	.half	8078
	.half	4062
	.half	26620
	.half	-4
	.half	-2
	.half	-1
	.half	32767
	.half	32764
	.half	16376
	.half	16380
	.half	32766
	.half	-1
	.half	-2
	.half	16380
	.half	29688
	.half	6144
	.half	16280
	.half	16380
	.half	8190
	.half	8190
	.half	8190
	.half	32766
	.half	-1
	.half	-1
	.half	-1
	.half	-2
	.half	-2
	.half	16380
	.half	8176
	.half	1984
	.half	384
	.half	4080
	.half	8188
	.half	8190
	.half	16382
	.half	16383
	.half	32767
	.half	32767
	.half	-1
	.half	-1
	.half	-2
	.half	-4
	.half	32764
	.half	16380
	.half	16368
	.half	16368
	.half	2016
	.half	0
	.half	0
	.half	0
	.half	384
	.half	960
	.half	992
	.half	2040
	.half	2044
	.half	4092
	.half	8188
	.half	8184
	.half	4088
	.half	496
	.half	0
	.half	0
	.half	0
	.half	1536
	.half	4064
	.half	8184
	.half	16380
	.half	32766
	.half	-2
	.half	4095
	.half	8191
	.half	8191
	.half	16383
	.half	32767
	.half	32766
	.half	15996
	.half	15416
	.half	14336
	.half	12288
	.half	32
	.half	16902
	.half	6
	.half	6176
	.half	6144
	.half	129
	.half	1024
	.half	16400
	.half	0
	.half	768
	.half	770
	.half	24592
	.half	24576
	.half	0
	.half	1049
	.half	-32744
	.type	ship_bitmap, @object
	.size	ship_bitmap, 512
ship_bitmap:
	.half	256
	.half	256
	.half	896
	.half	1984
	.half	1984
	.half	4064
	.half	4064
	.half	4064
	.half	8176
	.half	8176
	.half	8176
	.half	16376
	.half	16376
	.half	32508
	.half	30780
	.half	0
	.half	1
	.half	30
	.half	126
	.half	2046
	.half	8190
	.half	-4
	.half	32764
	.half	16376
	.half	8184
	.half	2040
	.half	1016
	.half	496
	.half	496
	.half	224
	.half	96
	.half	32
	.half	0
	.half	24576
	.half	30720
	.half	32512
	.half	32752
	.half	32760
	.half	16376
	.half	8191
	.half	16376
	.half	16376
	.half	32752
	.half	32752
	.half	30720
	.half	24576
	.half	0
	.half	0
	.half	32
	.half	96
	.half	224
	.half	496
	.half	496
	.half	1016
	.half	2040
	.half	8184
	.half	16376
	.half	32764
	.half	-4
	.half	8190
	.half	2046
	.half	126
	.half	30
	.half	1
	.half	0
	.half	15390
	.half	16254
	.half	8188
	.half	8188
	.half	4088
	.half	4088
	.half	4088
	.half	2032
	.half	2032
	.half	2032
	.half	992
	.half	992
	.half	448
	.half	128
	.half	128
	.half	1024
	.half	1536
	.half	1792
	.half	3968
	.half	3968
	.half	8128
	.half	8160
	.half	8184
	.half	8188
	.half	16382
	.half	16383
	.half	32760
	.half	32736
	.half	32256
	.half	30720
	.half	-32768
	.half	0
	.half	0
	.half	6
	.half	30
	.half	254
	.half	2046
	.half	8188
	.half	16380
	.half	-8
	.half	16380
	.half	8188
	.half	2046
	.half	254
	.half	30
	.half	6
	.half	0
	.half	-32768
	.half	30720
	.half	32256
	.half	32736
	.half	32760
	.half	16383
	.half	16382
	.half	8188
	.half	8184
	.half	8160
	.half	8128
	.half	3968
	.half	3968
	.half	1792
	.half	1536
	.half	1024
	.half	32
	.half	16902
	.half	6
	.half	6176
	.half	6144
	.half	129
	.half	1024
	.half	16400
	.half	0
	.half	768
	.half	770
	.half	24592
	.half	24576
	.half	0
	.half	1049
	.half	-32744
	.half	0
	.half	768
	.half	770
	.half	24592
	.half	24576
	.half	0
	.half	1049
	.half	-32744
	.half	32
	.half	16902
	.half	6
	.half	6176
	.half	6144
	.half	129
	.half	1024
	.half	16400
	.half	32
	.half	16902
	.half	6
	.half	6176
	.half	6144
	.half	129
	.half	1024
	.half	16400
	.half	0
	.half	768
	.half	770
	.half	24592
	.half	24576
	.half	0
	.half	1049
	.half	-32744
	.half	0
	.half	768
	.half	770
	.half	24592
	.half	24576
	.half	0
	.half	1049
	.half	-32744
	.half	32
	.half	16902
	.half	6
	.half	6176
	.half	6144
	.half	129
	.half	1024
	.half	16400
	.half	32
	.half	16902
	.half	6
	.half	6176
	.half	6144
	.half	129
	.half	1024
	.half	16400
	.half	0
	.half	768
	.half	770
	.half	24592
	.half	24576
	.half	0
	.half	1049
	.half	-32744
	.half	0
	.half	768
	.half	770
	.half	24592
	.half	24576
	.half	0
	.half	1049
	.half	-32744
	.half	32
	.half	16902
	.half	6
	.half	6176
	.half	6144
	.half	129
	.half	1024
	.half	16400
	.half	32
	.half	16902
	.half	6
	.half	6176
	.half	6144
	.half	129
	.half	1024
	.half	16400
	.half	0
	.half	768
	.half	770
	.half	24592
	.half	24576
	.half	0
	.half	1049
	.half	-32744
	.half	0
	.half	768
	.half	770
	.half	24592
	.half	24576
	.half	0
	.half	1049
	.half	-32744
	.half	32
	.half	16902
	.half	6
	.half	6176
	.half	6144
	.half	129
	.half	1024
	.half	16400
	.type	bullet_bitmap, @object
	.size	bullet_bitmap, 128
bullet_bitmap:
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	256
	.half	256
	.half	1984
	.half	256
	.half	256
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	1088
	.half	640
	.half	256
	.half	640
	.half	1088
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	256
	.half	896
	.half	1984
	.half	896
	.half	256
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	1344
	.half	896
	.half	1984
	.half	896
	.half	1344
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.type	tilemap_bitmap, @object
	.size	tilemap_bitmap, 256
tilemap_bitmap:
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	31
	.half	63
	.half	255
	.half	511
	.half	1023
	.half	1023
	.half	2047
	.half	2044
	.half	8177
	.half	14279
	.half	10140
	.half	13297
	.half	8135
	.half	287
	.half	255
	.half	63
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	-16384
	.half	-4096
	.half	-2048
	.half	-256
	.half	-1792
	.half	-6400
	.half	3072
	.half	29696
	.half	-15360
	.half	7168
	.half	31744
	.half	-2048
	.half	-2048
	.half	-4096
	.half	-8192
	.half	-32768
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	1
	.half	3
	.half	126
	.half	196
	.half	136
	.half	400
	.half	272
	.half	800
	.half	1009
	.half	3
	.half	6
	.half	5
	.half	34
	.half	8
	.half	1152
	.half	36
	.half	32
	.half	144
	.half	0
	.half	64
	.half	0
	.half	16
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	126
	.half	2018
	.half	7682
	.half	28678
	.half	-6652
	.half	-28916
	.half	6540
	.half	6552
	.half	3864
	.half	1584
	.half	96
	.half	24672
	.half	-12096
	.half	-24192
	.half	17152
	.half	-31232
	.half	2560
	.half	12800
	.half	-15872
	.half	-32256
	.half	-25600
	.half	-4096
	.half	-16384
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.type	asteroid_directions, @object
	.size	asteroid_directions, 24
asteroid_directions:
	.half	57
	.half	9
	.half	15
	.half	63
	.half	49
	.half	58
	.half	10
	.half	17
	.half	23
	.half	14
	.half	62
	.half	55
	.type	bullet_directions, @object
	.size	bullet_directions, 16
bullet_directions:
	.half	32
	.half	50
	.half	3
	.half	18
	.half	24
	.half	22
	.half	4
	.half	54
	.bss
	.align	2
	.set	.LANCHOR1,. + 0
	.type	asteroid_active, @object
	.size	asteroid_active, 22
asteroid_active:
	.zero	22
	.zero	2
	.type	asteroid_direction, @object
	.size	asteroid_direction, 22
asteroid_direction:
	.zero	22
	.section	.sbss,"aw",@nobits
	.align	2
	.type	last_timer, @object
	.size	last_timer, 2
last_timer:
	.zero	2
	.type	bulletdirection, @object
	.size	bulletdirection, 2
bulletdirection:
	.zero	2
	.type	resetship, @object
	.size	resetship, 2
resetship:
	.zero	2
	.type	shipdirection, @object
	.size	shipdirection, 2
shipdirection:
	.zero	2
	.type	counter, @object
	.size	counter, 4
counter:
	.zero	4
	.type	score, @object
	.size	score, 4
score:
	.zero	4
	.type	lives, @object
	.size	lives, 4
lives:
	.zero	4
	.section	.sdata,"aw"
	.align	2
	.type	shipy, @object
	.size	shipy, 2
shipy:
	.half	232
	.type	shipx, @object
	.size	shipx, 2
shipx:
	.half	312
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
