	.file	"asteroids.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	1
	.type	beep.part.0, @function
beep.part.0:
	lui	a5,%hi(AUDIO_R_WAVEFORM)
	lw	a5,%lo(AUDIO_R_WAVEFORM)(a5)
	li	a4,1
	sb	a0,0(a5)
	lui	a5,%hi(AUDIO_R_NOTE)
	lw	a5,%lo(AUDIO_R_NOTE)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(AUDIO_R_DURATION)
	lw	a5,%lo(AUDIO_R_DURATION)(a5)
	sh	a2,0(a5)
	lui	a5,%hi(AUDIO_R_START)
	lw	a5,%lo(AUDIO_R_START)(a5)
	sb	a4,0(a5)
	ret
	.size	beep.part.0, .-beep.part.0
	.align	1
	.globl	memcpy
	.type	memcpy, @function
memcpy:
	ret
	.size	memcpy, .-memcpy
	.align	1
	.globl	outputcharacter
	.type	outputcharacter, @function
outputcharacter:
	lui	a1,%hi(UART_STATUS)
	lui	a2,%hi(UART_DATA)
	lui	a3,%hi(TERMINAL_OUTPUT)
	li	a4,10
.L5:
	lw	a6,%lo(UART_STATUS)(a1)
.L4:
	lbu	a5,0(a6)
	andi	a5,a5,2
	bne	a5,zero,.L4
	lw	a5,%lo(UART_DATA)(a2)
	sb	a0,0(a5)
	lw	a5,%lo(TERMINAL_OUTPUT)(a3)
	sb	a0,0(a5)
	beq	a0,a4,.L6
	ret
.L6:
	li	a0,13
	j	.L5
	.size	outputcharacter, .-outputcharacter
	.align	1
	.globl	outputstring
	.type	outputstring, @function
outputstring:
	addi	sp,sp,-16
	sw	s0,8(sp)
	sw	ra,12(sp)
	mv	s0,a0
.L9:
	lbu	a0,0(s0)
	bne	a0,zero,.L10
	lw	s0,8(sp)
	lw	ra,12(sp)
	li	a0,10
	addi	sp,sp,16
	tail	outputcharacter
.L10:
	call	outputcharacter
	addi	s0,s0,1
	j	.L9
	.size	outputstring, .-outputstring
	.align	1
	.globl	outputstringnonl
	.type	outputstringnonl, @function
outputstringnonl:
	addi	sp,sp,-16
	sw	s0,8(sp)
	sw	ra,12(sp)
	mv	s0,a0
.L13:
	lbu	a0,0(s0)
	bne	a0,zero,.L14
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
.L14:
	call	outputcharacter
	addi	s0,s0,1
	j	.L13
	.size	outputstringnonl, .-outputstringnonl
	.align	1
	.globl	inputcharacter
	.type	inputcharacter, @function
inputcharacter:
	lui	a5,%hi(UART_STATUS)
	lw	a4,%lo(UART_STATUS)(a5)
.L17:
	lbu	a5,0(a4)
	andi	a5,a5,1
	beq	a5,zero,.L17
	lui	a5,%hi(UART_DATA)
	lw	a5,%lo(UART_DATA)(a5)
	lbu	a0,0(a5)
	ret
	.size	inputcharacter, .-inputcharacter
	.align	1
	.globl	rng
	.type	rng, @function
rng:
	li	a5,1
	mv	a4,a0
	bgtu	a0,a5,.L21
	li	a0,0
	beq	a4,zero,.L22
	lui	a5,%hi(RNG)
	lw	a5,%lo(RNG)(a5)
	lhu	a0,0(a5)
	andi	a0,a0,1
	ret
.L21:
	lui	a5,%hi(RNG)
	lw	a3,%lo(RNG)(a5)
	li	a5,255
	bgtu	a0,a5,.L23
	lhu	a5,0(a3)
	slli	a5,a5,16
	srli	a5,a5,16
	remu	a0,a5,a0
	ret
.L23:
	lhu	a5,0(a3)
	slli	a0,a5,16
	srli	a0,a0,16
	bleu	a4,a0,.L23
.L22:
	ret
	.size	rng, .-rng
	.align	1
	.globl	set_timer1khz
	.type	set_timer1khz, @function
set_timer1khz:
	lui	a5,%hi(TIMER1KHZ)
	lw	a5,%lo(TIMER1KHZ)(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	sh	a0,0(a5)
	ret
	.size	set_timer1khz, .-set_timer1khz
	.align	1
	.globl	wait_timer1khz
	.type	wait_timer1khz, @function
wait_timer1khz:
	lui	a5,%hi(TIMER1KHZ)
	lw	a4,%lo(TIMER1KHZ)(a5)
.L30:
	lhu	a5,0(a4)
	slli	a5,a5,16
	srli	a5,a5,16
	bne	a5,zero,.L30
	ret
	.size	wait_timer1khz, .-wait_timer1khz
	.align	1
	.globl	beep
	.type	beep, @function
beep:
	mv	a5,a0
	andi	a4,a5,1
	mv	a0,a1
	mv	a1,a2
	mv	a2,a3
	beq	a4,zero,.L33
	lui	a4,%hi(AUDIO_L_WAVEFORM)
	lw	a4,%lo(AUDIO_L_WAVEFORM)(a4)
	sb	a0,0(a4)
	lui	a4,%hi(AUDIO_L_NOTE)
	lw	a4,%lo(AUDIO_L_NOTE)(a4)
	sb	a1,0(a4)
	lui	a4,%hi(AUDIO_L_DURATION)
	lw	a4,%lo(AUDIO_L_DURATION)(a4)
	sh	a3,0(a4)
	lui	a4,%hi(AUDIO_L_START)
	lw	a4,%lo(AUDIO_L_START)(a4)
	li	a3,1
	sb	a3,0(a4)
.L33:
	andi	a5,a5,2
	beq	a5,zero,.L32
	tail	beep.part.0
.L32:
	ret
	.size	beep, .-beep
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
	.globl	terminal_showhide
	.type	terminal_showhide, @function
terminal_showhide:
	lui	a5,%hi(TERMINAL_SHOWHIDE)
	lw	a5,%lo(TERMINAL_SHOWHIDE)(a5)
	sb	a0,0(a5)
	ret
	.size	terminal_showhide, .-terminal_showhide
	.align	1
	.globl	await_vblank
	.type	await_vblank, @function
await_vblank:
	lui	a5,%hi(VBLANK)
	lw	a4,%lo(VBLANK)(a5)
.L41:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	beq	a5,zero,.L41
	ret
	.size	await_vblank, .-await_vblank
	.align	1
	.globl	set_tilemap_tile
	.type	set_tilemap_tile, @function
set_tilemap_tile:
	lui	a5,%hi(TM_STATUS)
	lw	a6,%lo(TM_STATUS)(a5)
.L45:
	lbu	a5,0(a6)
	andi	a5,a5,0xff
	bne	a5,zero,.L45
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
	.globl	set_tilemap_line
	.type	set_tilemap_line, @function
set_tilemap_line:
	lui	a5,%hi(TM_STATUS)
	lw	a4,%lo(TM_STATUS)(a5)
.L48:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L48
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
	.align	1
	.globl	tilemap_scrollwrapclear
	.type	tilemap_scrollwrapclear, @function
tilemap_scrollwrapclear:
	lui	a5,%hi(TM_STATUS)
	lw	a4,%lo(TM_STATUS)(a5)
.L51:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L51
	lui	a5,%hi(TM_SCROLLWRAPCLEAR)
	lw	a5,%lo(TM_SCROLLWRAPCLEAR)(a5)
	sb	a0,0(a5)
	ret
	.size	tilemap_scrollwrapclear, .-tilemap_scrollwrapclear
	.align	1
	.globl	wait_gpu
	.type	wait_gpu, @function
wait_gpu:
	lui	a5,%hi(GPU_STATUS)
	lw	a4,%lo(GPU_STATUS)(a5)
.L54:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L54
	ret
	.size	wait_gpu, .-wait_gpu
	.align	1
	.globl	gpu_pixel
	.type	gpu_pixel, @function
gpu_pixel:
	addi	sp,sp,-16
	sw	s0,8(sp)
	sw	s1,4(sp)
	sw	s2,0(sp)
	sw	ra,12(sp)
	mv	s2,a0
	mv	s1,a1
	mv	s0,a2
	call	wait_gpu
	lui	a5,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a5)
	li	a4,1
	sb	s2,0(a5)
	lui	a5,%hi(GPU_X)
	lw	a5,%lo(GPU_X)(a5)
	sh	s1,0(a5)
	lui	a5,%hi(GPU_Y)
	lw	a5,%lo(GPU_Y)(a5)
	sh	s0,0(a5)
	lui	a5,%hi(GPU_WRITE)
	lw	a5,%lo(GPU_WRITE)(a5)
	sb	a4,0(a5)
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	lw	s2,0(sp)
	addi	sp,sp,16
	jr	ra
	.size	gpu_pixel, .-gpu_pixel
	.align	1
	.globl	gpu_rectangle
	.type	gpu_rectangle, @function
gpu_rectangle:
	addi	sp,sp,-32
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	sw	ra,28(sp)
	mv	s0,a4
	mv	s4,a0
	mv	s3,a1
	mv	s2,a2
	mv	s1,a3
	call	wait_gpu
	lui	a5,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a5)
	li	a4,2
	sb	s4,0(a5)
	lui	a5,%hi(GPU_X)
	lw	a5,%lo(GPU_X)(a5)
	sh	s3,0(a5)
	lui	a5,%hi(GPU_Y)
	lw	a5,%lo(GPU_Y)(a5)
	sh	s2,0(a5)
	lui	a5,%hi(GPU_PARAM0)
	lw	a5,%lo(GPU_PARAM0)(a5)
	sh	s1,0(a5)
	lui	a5,%hi(GPU_PARAM1)
	lw	a5,%lo(GPU_PARAM1)(a5)
	sh	s0,0(a5)
	lui	a5,%hi(GPU_WRITE)
	lw	a5,%lo(GPU_WRITE)(a5)
	sb	a4,0(a5)
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	lw	s4,8(sp)
	addi	sp,sp,32
	jr	ra
	.size	gpu_rectangle, .-gpu_rectangle
	.align	1
	.globl	gpu_cs
	.type	gpu_cs, @function
gpu_cs:
	li	a4,479
	li	a3,639
	li	a2,0
	li	a1,0
	li	a0,64
	tail	gpu_rectangle
	.size	gpu_cs, .-gpu_cs
	.align	1
	.globl	gpu_line
	.type	gpu_line, @function
gpu_line:
	addi	sp,sp,-32
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	sw	ra,28(sp)
	mv	s0,a4
	mv	s4,a0
	mv	s3,a1
	mv	s2,a2
	mv	s1,a3
	call	wait_gpu
	lui	a5,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a5)
	li	a4,3
	sb	s4,0(a5)
	lui	a5,%hi(GPU_X)
	lw	a5,%lo(GPU_X)(a5)
	sh	s3,0(a5)
	lui	a5,%hi(GPU_Y)
	lw	a5,%lo(GPU_Y)(a5)
	sh	s2,0(a5)
	lui	a5,%hi(GPU_PARAM0)
	lw	a5,%lo(GPU_PARAM0)(a5)
	sh	s1,0(a5)
	lui	a5,%hi(GPU_PARAM1)
	lw	a5,%lo(GPU_PARAM1)(a5)
	sh	s0,0(a5)
	lui	a5,%hi(GPU_WRITE)
	lw	a5,%lo(GPU_WRITE)(a5)
	sb	a4,0(a5)
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	lw	s4,8(sp)
	addi	sp,sp,32
	jr	ra
	.size	gpu_line, .-gpu_line
	.align	1
	.globl	gpu_circle
	.type	gpu_circle, @function
gpu_circle:
	addi	sp,sp,-32
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	ra,28(sp)
	mv	s3,a0
	mv	s2,a1
	mv	s1,a2
	mv	s0,a3
	call	wait_gpu
	lui	a5,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a5)
	li	a4,4
	sb	s3,0(a5)
	lui	a5,%hi(GPU_X)
	lw	a5,%lo(GPU_X)(a5)
	sh	s2,0(a5)
	lui	a5,%hi(GPU_Y)
	lw	a5,%lo(GPU_Y)(a5)
	sh	s1,0(a5)
	lui	a5,%hi(GPU_PARAM0)
	lw	a5,%lo(GPU_PARAM0)(a5)
	sh	s0,0(a5)
	lui	a5,%hi(GPU_WRITE)
	lw	a5,%lo(GPU_WRITE)(a5)
	sb	a4,0(a5)
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	addi	sp,sp,32
	jr	ra
	.size	gpu_circle, .-gpu_circle
	.align	1
	.globl	gpu_fillcircle
	.type	gpu_fillcircle, @function
gpu_fillcircle:
	addi	sp,sp,-32
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	ra,28(sp)
	mv	s3,a0
	mv	s2,a1
	mv	s1,a2
	mv	s0,a3
	call	wait_gpu
	lui	a5,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a5)
	li	a4,6
	sb	s3,0(a5)
	lui	a5,%hi(GPU_X)
	lw	a5,%lo(GPU_X)(a5)
	sh	s2,0(a5)
	lui	a5,%hi(GPU_Y)
	lw	a5,%lo(GPU_Y)(a5)
	sh	s1,0(a5)
	lui	a5,%hi(GPU_PARAM0)
	lw	a5,%lo(GPU_PARAM0)(a5)
	sh	s0,0(a5)
	lui	a5,%hi(GPU_WRITE)
	lw	a5,%lo(GPU_WRITE)(a5)
	sb	a4,0(a5)
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	addi	sp,sp,32
	jr	ra
	.size	gpu_fillcircle, .-gpu_fillcircle
	.align	1
	.globl	gpu_triangle
	.type	gpu_triangle, @function
gpu_triangle:
	addi	sp,sp,-32
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	sw	s5,4(sp)
	sw	s6,0(sp)
	sw	ra,28(sp)
	mv	s2,a4
	mv	s1,a5
	mv	s6,a0
	mv	s5,a1
	mv	s4,a2
	mv	s3,a3
	mv	s0,a6
	call	wait_gpu
	lui	a5,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a5)
	li	a4,7
	sb	s6,0(a5)
	lui	a5,%hi(GPU_X)
	lw	a5,%lo(GPU_X)(a5)
	sh	s5,0(a5)
	lui	a5,%hi(GPU_Y)
	lw	a5,%lo(GPU_Y)(a5)
	sh	s4,0(a5)
	lui	a5,%hi(GPU_PARAM0)
	lw	a5,%lo(GPU_PARAM0)(a5)
	sh	s3,0(a5)
	lui	a5,%hi(GPU_PARAM1)
	lw	a5,%lo(GPU_PARAM1)(a5)
	sh	s2,0(a5)
	lui	a5,%hi(GPU_PARAM2)
	lw	a5,%lo(GPU_PARAM2)(a5)
	sh	s1,0(a5)
	lui	a5,%hi(GPU_PARAM3)
	lw	a5,%lo(GPU_PARAM3)(a5)
	sh	s0,0(a5)
	lui	a5,%hi(GPU_WRITE)
	lw	a5,%lo(GPU_WRITE)(a5)
	sb	a4,0(a5)
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	lw	s4,8(sp)
	lw	s5,4(sp)
	lw	s6,0(sp)
	addi	sp,sp,32
	jr	ra
	.size	gpu_triangle, .-gpu_triangle
	.align	1
	.globl	draw_vector_block
	.type	draw_vector_block, @function
draw_vector_block:
	lui	a5,%hi(VECTOR_DRAW_STATUS)
	lw	a4,%lo(VECTOR_DRAW_STATUS)(a5)
.L70:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L70
	lui	a5,%hi(VECTOR_DRAW_BLOCK)
	lw	a5,%lo(VECTOR_DRAW_BLOCK)(a5)
	li	a4,1
	sb	a0,0(a5)
	lui	a5,%hi(VECTOR_DRAW_COLOUR)
	lw	a5,%lo(VECTOR_DRAW_COLOUR)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(VECTOR_DRAW_XC)
	lw	a5,%lo(VECTOR_DRAW_XC)(a5)
	sh	a2,0(a5)
	lui	a5,%hi(VECTOR_DRAW_YC)
	lw	a5,%lo(VECTOR_DRAW_YC)(a5)
	sh	a3,0(a5)
	lui	a5,%hi(VECTOR_DRAW_START)
	lw	a5,%lo(VECTOR_DRAW_START)(a5)
	sb	a4,0(a5)
	ret
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
	.globl	bitmap_scrollwrap
	.type	bitmap_scrollwrap, @function
bitmap_scrollwrap:
	addi	sp,sp,-16
	sw	s0,8(sp)
	sw	ra,12(sp)
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
	.globl	set_sprite
	.type	set_sprite, @function
set_sprite:
	beq	a0,zero,.L76
	li	t1,1
	beq	a0,t1,.L77
	ret
.L76:
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
.L79:
	sb	a7,0(a5)
	ret
.L77:
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
	j	.L79
	.size	set_sprite, .-set_sprite
	.align	1
	.globl	get_sprite_collision
	.type	get_sprite_collision, @function
get_sprite_collision:
	slli	a1,a1,1
	bne	a0,zero,.L81
	lui	a5,%hi(LOWER_SPRITE_COLLISION_BASE)
	lw	a5,%lo(LOWER_SPRITE_COLLISION_BASE)(a5)
.L83:
	add	a1,a5,a1
	lhu	a0,0(a1)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
.L81:
	lui	a5,%hi(UPPER_SPRITE_COLLISION_BASE)
	lw	a5,%lo(UPPER_SPRITE_COLLISION_BASE)(a5)
	j	.L83
	.size	get_sprite_collision, .-get_sprite_collision
	.align	1
	.globl	get_sprite_attribute
	.type	get_sprite_attribute, @function
get_sprite_attribute:
	bne	a0,zero,.L85
	lui	a5,%hi(LOWER_SPRITE_NUMBER)
	lw	a5,%lo(LOWER_SPRITE_NUMBER)(a5)
	sb	a1,0(a5)
	li	a5,5
	bgtu	a2,a5,.L86
	lui	a5,%hi(.L88)
	addi	a5,a5,%lo(.L88)
	slli	a2,a2,2
	add	a2,a2,a5
	lw	a5,0(a2)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L88:
	.word	.L93
	.word	.L92
	.word	.L91
	.word	.L90
	.word	.L89
	.word	.L87
	.text
.L93:
	lui	a5,%hi(LOWER_SPRITE_ACTIVE)
	lw	a5,%lo(LOWER_SPRITE_ACTIVE)(a5)
.L102:
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L92:
	lui	a5,%hi(LOWER_SPRITE_TILE)
	lw	a5,%lo(LOWER_SPRITE_TILE)(a5)
	j	.L102
.L91:
	lui	a5,%hi(LOWER_SPRITE_COLOUR)
	lw	a5,%lo(LOWER_SPRITE_COLOUR)(a5)
	j	.L102
.L90:
	lui	a5,%hi(LOWER_SPRITE_X)
	lw	a5,%lo(LOWER_SPRITE_X)(a5)
.L103:
	lhu	a0,0(a5)
	slli	a0,a0,16
	srai	a0,a0,16
	ret
.L89:
	lui	a5,%hi(LOWER_SPRITE_Y)
	lw	a5,%lo(LOWER_SPRITE_Y)(a5)
	j	.L103
.L87:
	lui	a5,%hi(LOWER_SPRITE_DOUBLE)
	lw	a5,%lo(LOWER_SPRITE_DOUBLE)(a5)
	j	.L102
.L85:
	lui	a5,%hi(UPPER_SPRITE_NUMBER)
	lw	a5,%lo(UPPER_SPRITE_NUMBER)(a5)
	sb	a1,0(a5)
	li	a5,5
	bgtu	a2,a5,.L86
	lui	a5,%hi(.L96)
	addi	a5,a5,%lo(.L96)
	slli	a2,a2,2
	add	a2,a2,a5
	lw	a5,0(a2)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L96:
	.word	.L101
	.word	.L100
	.word	.L99
	.word	.L98
	.word	.L97
	.word	.L95
	.text
.L101:
	lui	a5,%hi(UPPER_SPRITE_ACTIVE)
	lw	a5,%lo(UPPER_SPRITE_ACTIVE)(a5)
	j	.L102
.L100:
	lui	a5,%hi(UPPER_SPRITE_TILE)
	lw	a5,%lo(UPPER_SPRITE_TILE)(a5)
	j	.L102
.L99:
	lui	a5,%hi(UPPER_SPRITE_COLOUR)
	lw	a5,%lo(UPPER_SPRITE_COLOUR)(a5)
	j	.L102
.L98:
	lui	a5,%hi(UPPER_SPRITE_X)
	lw	a5,%lo(UPPER_SPRITE_X)(a5)
	j	.L103
.L97:
	lui	a5,%hi(UPPER_SPRITE_Y)
	lw	a5,%lo(UPPER_SPRITE_Y)(a5)
	j	.L103
.L95:
	lui	a5,%hi(UPPER_SPRITE_DOUBLE)
	lw	a5,%lo(UPPER_SPRITE_DOUBLE)(a5)
	j	.L102
.L86:
	ret
	.size	get_sprite_attribute, .-get_sprite_attribute
	.align	1
	.globl	set_sprite_attribute
	.type	set_sprite_attribute, @function
set_sprite_attribute:
	bne	a0,zero,.L105
	lui	a5,%hi(LOWER_SPRITE_NUMBER)
	lw	a5,%lo(LOWER_SPRITE_NUMBER)(a5)
	sb	a1,0(a5)
	li	a5,5
	bgtu	a2,a5,.L104
	lui	a5,%hi(.L108)
	addi	a5,a5,%lo(.L108)
	slli	a2,a2,2
	add	a2,a2,a5
	lw	a5,0(a2)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L108:
	.word	.L113
	.word	.L112
	.word	.L111
	.word	.L110
	.word	.L109
	.word	.L107
	.text
.L113:
	lui	a5,%hi(LOWER_SPRITE_ACTIVE)
	lw	a5,%lo(LOWER_SPRITE_ACTIVE)(a5)
.L122:
	andi	a3,a3,0xff
	sb	a3,0(a5)
.L104:
	ret
.L112:
	lui	a5,%hi(LOWER_SPRITE_TILE)
	lw	a5,%lo(LOWER_SPRITE_TILE)(a5)
	j	.L122
.L111:
	lui	a5,%hi(LOWER_SPRITE_COLOUR)
	lw	a5,%lo(LOWER_SPRITE_COLOUR)(a5)
	j	.L122
.L110:
	lui	a5,%hi(LOWER_SPRITE_X)
	lw	a5,%lo(LOWER_SPRITE_X)(a5)
.L123:
	sh	a3,0(a5)
	ret
.L109:
	lui	a5,%hi(LOWER_SPRITE_Y)
	lw	a5,%lo(LOWER_SPRITE_Y)(a5)
	j	.L123
.L107:
	lui	a5,%hi(LOWER_SPRITE_DOUBLE)
	lw	a5,%lo(LOWER_SPRITE_DOUBLE)(a5)
	j	.L122
.L105:
	lui	a5,%hi(UPPER_SPRITE_NUMBER)
	lw	a5,%lo(UPPER_SPRITE_NUMBER)(a5)
	sb	a1,0(a5)
	li	a5,5
	bgtu	a2,a5,.L104
	lui	a5,%hi(.L116)
	addi	a5,a5,%lo(.L116)
	slli	a2,a2,2
	add	a2,a2,a5
	lw	a5,0(a2)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L116:
	.word	.L121
	.word	.L120
	.word	.L119
	.word	.L118
	.word	.L117
	.word	.L115
	.text
.L121:
	lui	a5,%hi(UPPER_SPRITE_ACTIVE)
	lw	a5,%lo(UPPER_SPRITE_ACTIVE)(a5)
	j	.L122
.L120:
	lui	a5,%hi(UPPER_SPRITE_TILE)
	lw	a5,%lo(UPPER_SPRITE_TILE)(a5)
	j	.L122
.L119:
	lui	a5,%hi(UPPER_SPRITE_COLOUR)
	lw	a5,%lo(UPPER_SPRITE_COLOUR)(a5)
	j	.L122
.L118:
	lui	a5,%hi(UPPER_SPRITE_X)
	lw	a5,%lo(UPPER_SPRITE_X)(a5)
	j	.L123
.L117:
	lui	a5,%hi(UPPER_SPRITE_Y)
	lw	a5,%lo(UPPER_SPRITE_Y)(a5)
	j	.L123
.L115:
	lui	a5,%hi(UPPER_SPRITE_DOUBLE)
	lw	a5,%lo(UPPER_SPRITE_DOUBLE)(a5)
	j	.L122
	.size	set_sprite_attribute, .-set_sprite_attribute
	.align	1
	.globl	update_sprite
	.type	update_sprite, @function
update_sprite:
	beq	a0,zero,.L125
	li	a5,1
	beq	a0,a5,.L126
	ret
.L125:
	lui	a5,%hi(LOWER_SPRITE_NUMBER)
	lw	a5,%lo(LOWER_SPRITE_NUMBER)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(LOWER_SPRITE_UPDATE)
	lw	a5,%lo(LOWER_SPRITE_UPDATE)(a5)
.L128:
	sh	a2,0(a5)
	ret
.L126:
	lui	a5,%hi(UPPER_SPRITE_NUMBER)
	lw	a5,%lo(UPPER_SPRITE_NUMBER)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(UPPER_SPRITE_UPDATE)
	lw	a5,%lo(UPPER_SPRITE_UPDATE)(a5)
	j	.L128
	.size	update_sprite, .-update_sprite
	.align	1
	.globl	set_sprite_line
	.type	set_sprite_line, @function
set_sprite_line:
	beq	a0,zero,.L130
	li	a5,1
	beq	a0,a5,.L131
	ret
.L130:
	lui	a5,%hi(LOWER_SPRITE_WRITER_NUMBER)
	lw	a5,%lo(LOWER_SPRITE_WRITER_NUMBER)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(LOWER_SPRITE_WRITER_LINE)
	lw	a5,%lo(LOWER_SPRITE_WRITER_LINE)(a5)
	sb	a2,0(a5)
	lui	a5,%hi(LOWER_SPRITE_WRITER_BITMAP)
	lw	a5,%lo(LOWER_SPRITE_WRITER_BITMAP)(a5)
.L133:
	sh	a3,0(a5)
	ret
.L131:
	lui	a5,%hi(UPPER_SPRITE_WRITER_NUMBER)
	lw	a5,%lo(UPPER_SPRITE_WRITER_NUMBER)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(UPPER_SPRITE_WRITER_LINE)
	lw	a5,%lo(UPPER_SPRITE_WRITER_LINE)(a5)
	sb	a2,0(a5)
	lui	a5,%hi(UPPER_SPRITE_WRITER_BITMAP)
	lw	a5,%lo(UPPER_SPRITE_WRITER_BITMAP)(a5)
	j	.L133
	.size	set_sprite_line, .-set_sprite_line
	.align	1
	.globl	tpu_cs
	.type	tpu_cs, @function
tpu_cs:
	lui	a5,%hi(TPU_COMMIT)
	lw	a4,%lo(TPU_COMMIT)(a5)
.L135:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L135
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
	li	a4,1
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
	sb	a4,0(a5)
	ret
	.size	tpu_set, .-tpu_set
	.align	1
	.globl	tpu_output_character
	.type	tpu_output_character, @function
tpu_output_character:
	lui	a5,%hi(TPU_COMMIT)
	lw	a3,%lo(TPU_COMMIT)(a5)
.L139:
	lbu	a4,0(a3)
	andi	a4,a4,0xff
	bne	a4,zero,.L139
	lui	a4,%hi(TPU_CHARACTER)
	lw	a4,%lo(TPU_CHARACTER)(a4)
	sb	a0,0(a4)
	lw	a5,%lo(TPU_COMMIT)(a5)
	li	a4,2
	sb	a4,0(a5)
	ret
	.size	tpu_output_character, .-tpu_output_character
	.align	1
	.globl	tpu_outputstring
	.type	tpu_outputstring, @function
tpu_outputstring:
	lui	a3,%hi(TPU_COMMIT)
	lui	a2,%hi(TPU_CHARACTER)
	li	a1,2
.L142:
	lbu	a4,0(a0)
	bne	a4,zero,.L144
	ret
.L144:
	lw	a6,%lo(TPU_COMMIT)(a3)
.L143:
	lbu	a5,0(a6)
	andi	a5,a5,0xff
	bne	a5,zero,.L143
	lw	a5,%lo(TPU_CHARACTER)(a2)
	addi	a0,a0,1
	sb	a4,0(a5)
	lw	a5,%lo(TPU_COMMIT)(a3)
	sb	a1,0(a5)
	j	.L142
	.size	tpu_outputstring, .-tpu_outputstring
	.align	1
	.globl	tpu_outputnumber_char
	.type	tpu_outputnumber_char, @function
tpu_outputnumber_char:
	li	a5,3158016
	addi	sp,sp,-32
	addi	a5,a5,48
	sw	a5,12(sp)
	li	a5,10
	remu	a4,a0,a5
	sw	ra,28(sp)
	divu	a0,a0,a5
	addi	a4,a4,48
	sb	a4,14(sp)
	remu	a0,a0,a5
	addi	a0,a0,48
	sb	a0,13(sp)
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
	li	a5,808464384
	addi	sp,sp,-32
	addi	a5,a5,48
	sw	a5,8(sp)
	li	a5,48
	sh	a5,12(sp)
	sw	ra,28(sp)
	li	a5,4
	li	a3,10
.L149:
	remu	a4,a0,a3
	addi	a2,sp,8
	add	a2,a2,a5
	addi	a5,a5,-1
	addi	a4,a4,48
	sb	a4,0(a2)
	divu	a0,a0,a3
	bne	a5,zero,.L149
	addi	a0,sp,8
	call	tpu_outputstring
	lw	ra,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	tpu_outputnumber_short, .-tpu_outputnumber_short
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"0000000000"
	.text
	.align	1
	.globl	tpu_outputnumber_int
	.type	tpu_outputnumber_int, @function
tpu_outputnumber_int:
	addi	sp,sp,-32
	lui	a1,%hi(.LC0)
	sw	s0,24(sp)
	li	a2,11
	mv	s0,a0
	addi	a1,a1,%lo(.LC0)
	addi	a0,sp,4
	sw	ra,28(sp)
	call	memcpy
	li	a5,9
	li	a3,10
.L153:
	remu	a4,s0,a3
	addi	a2,sp,4
	add	a2,a2,a5
	addi	a5,a5,-1
	addi	a4,a4,48
	sb	a4,0(a2)
	divu	s0,s0,a3
	bne	a5,zero,.L153
	addi	a0,sp,4
	call	tpu_outputstring
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	tpu_outputnumber_int, .-tpu_outputnumber_int
	.align	1
	.globl	set_asteroid_sprites
	.type	set_asteroid_sprites, @function
set_asteroid_sprites:
	addi	sp,sp,-48
	sw	s0,40(sp)
	sw	s5,20(sp)
	sw	s6,16(sp)
	sw	s7,12(sp)
	sw	s8,8(sp)
	sw	ra,44(sp)
	sw	s1,36(sp)
	sw	s2,32(sp)
	sw	s3,28(sp)
	sw	s4,24(sp)
	li	s0,0
	li	s8,9
	lui	s5,%hi(.LANCHOR0)
	li	s6,128
	li	s7,20
.L157:
	mv	a1,s0
	bleu	s0,s8,.L161
	addi	a1,s0,-10
.L161:
	sltiu	s3,s0,10
	andi	s2,a1,0xff
	addi	s4,s5,%lo(.LANCHOR0)
	li	s1,0
	xori	s3,s3,1
.L158:
	lhu	a3,0(s4)
	mv	a2,s1
	addi	s1,s1,1
	mv	a1,s2
	mv	a0,s3
	andi	s1,s1,0xff
	call	set_sprite_line
	addi	s4,s4,2
	bne	s1,s6,.L158
	addi	s0,s0,1
	andi	s0,s0,0xff
	bne	s0,s7,.L157
	lw	ra,44(sp)
	lw	s0,40(sp)
	lw	s1,36(sp)
	lw	s2,32(sp)
	lw	s3,28(sp)
	lw	s4,24(sp)
	lw	s5,20(sp)
	lw	s6,16(sp)
	lw	s7,12(sp)
	lw	s8,8(sp)
	addi	sp,sp,48
	jr	ra
	.size	set_asteroid_sprites, .-set_asteroid_sprites
	.align	1
	.globl	set_ship_sprites
	.type	set_ship_sprites, @function
set_ship_sprites:
	addi	sp,sp,-32
	sw	s0,24(sp)
	lui	a5,%hi(.LANCHOR0+256)
	snez	s0,a0
	slli	s0,s0,8
	addi	a5,a5,%lo(.LANCHOR0+256)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	sw	s5,4(sp)
	sw	s6,0(sp)
	sw	ra,28(sp)
	add	s0,a5,s0
	li	s1,0
	lui	s6,%hi(LOWER_SPRITE_WRITER_NUMBER)
	li	s5,11
	lui	s4,%hi(LOWER_SPRITE_WRITER_LINE)
	lui	s3,%hi(LOWER_SPRITE_WRITER_BITMAP)
	li	s2,128
.L167:
	lw	a5,%lo(LOWER_SPRITE_WRITER_NUMBER)(s6)
	lhu	a4,0(s0)
	mv	a2,s1
	sb	s5,0(a5)
	lw	a5,%lo(LOWER_SPRITE_WRITER_LINE)(s4)
	li	a1,11
	li	a0,1
	sb	s1,0(a5)
	lw	a5,%lo(LOWER_SPRITE_WRITER_BITMAP)(s3)
	addi	s1,s1,1
	andi	s1,s1,0xff
	sh	a4,0(a5)
	lhu	a3,0(s0)
	addi	s0,s0,2
	call	set_sprite_line
	bne	s1,s2,.L167
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	lw	s4,8(sp)
	lw	s5,4(sp)
	lw	s6,0(sp)
	addi	sp,sp,32
	jr	ra
	.size	set_ship_sprites, .-set_ship_sprites
	.align	1
	.globl	set_ship_vector
	.type	set_ship_vector, @function
set_ship_vector:
	addi	sp,sp,-16
	li	a4,0
	li	a3,0
	li	a2,1
	li	a1,0
	li	a0,0
	sw	ra,12(sp)
	call	set_vector_vertex
	li	a4,10
	li	a3,5
	li	a2,1
	li	a1,1
	li	a0,0
	call	set_vector_vertex
	li	a4,6
	li	a3,0
	li	a2,1
	li	a1,2
	li	a0,0
	call	set_vector_vertex
	li	a4,10
	li	a3,251
	li	a2,1
	li	a1,3
	li	a0,0
	call	set_vector_vertex
	li	a4,0
	li	a3,0
	li	a2,1
	li	a1,4
	li	a0,0
	call	set_vector_vertex
	lw	ra,12(sp)
	li	a4,0
	li	a3,0
	li	a2,0
	li	a1,5
	li	a0,0
	addi	sp,sp,16
	tail	set_vector_vertex
	.size	set_ship_vector, .-set_ship_vector
	.align	1
	.globl	set_bullet_sprites
	.type	set_bullet_sprites, @function
set_bullet_sprites:
	addi	sp,sp,-32
	sw	s1,20(sp)
	lui	s1,%hi(.LANCHOR0+768)
	sw	s0,24(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	sw	s5,4(sp)
	sw	s6,0(sp)
	sw	ra,28(sp)
	addi	s1,s1,%lo(.LANCHOR0+768)
	li	s0,0
	lui	s6,%hi(LOWER_SPRITE_WRITER_NUMBER)
	li	s5,12
	lui	s4,%hi(LOWER_SPRITE_WRITER_LINE)
	lui	s3,%hi(LOWER_SPRITE_WRITER_BITMAP)
	li	s2,128
.L173:
	lw	a5,%lo(LOWER_SPRITE_WRITER_NUMBER)(s6)
	lhu	a4,0(s1)
	mv	a2,s0
	sb	s5,0(a5)
	lw	a5,%lo(LOWER_SPRITE_WRITER_LINE)(s4)
	li	a1,12
	li	a0,1
	sb	s0,0(a5)
	lw	a5,%lo(LOWER_SPRITE_WRITER_BITMAP)(s3)
	addi	s0,s0,1
	andi	s0,s0,0xff
	sh	a4,0(a5)
	lhu	a3,0(s1)
	addi	s1,s1,2
	call	set_sprite_line
	bne	s0,s2,.L173
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	lw	s4,8(sp)
	lw	s5,4(sp)
	lw	s6,0(sp)
	addi	sp,sp,32
	jr	ra
	.size	set_bullet_sprites, .-set_bullet_sprites
	.align	1
	.globl	set_ufo_sprite
	.type	set_ufo_sprite, @function
set_ufo_sprite:
	addi	sp,sp,-32
	sw	s1,20(sp)
	lui	s1,%hi(.LANCHOR0)
	sw	s2,16(sp)
	addi	s2,s1,%lo(.LANCHOR0)
	sw	s0,24(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	sw	s5,4(sp)
	sw	s6,0(sp)
	sw	ra,28(sp)
	mv	s3,a0
	addi	s2,s2,1024
	addi	s1,s1,%lo(.LANCHOR0)
	li	s0,0
	lui	s5,%hi(ufo_sprite_number)
	li	s6,9
	li	s4,128
.L180:
	lbu	a1,%lo(ufo_sprite_number)(s5)
	sltiu	a5,a1,10
	xori	a0,a5,1
	bleu	a1,s6,.L177
	addi	a1,a1,-10
	andi	a1,a1,0xff
.L177:
	beq	s3,zero,.L178
	lhu	a3,0(s2)
.L179:
	mv	a2,s0
	addi	s0,s0,1
	andi	s0,s0,0xff
	call	set_sprite_line
	addi	s2,s2,2
	addi	s1,s1,2
	bne	s0,s4,.L180
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	lw	s4,8(sp)
	lw	s5,4(sp)
	lw	s6,0(sp)
	addi	sp,sp,32
	jr	ra
.L178:
	lhu	a3,0(s1)
	j	.L179
	.size	set_ufo_sprite, .-set_ufo_sprite
	.align	1
	.globl	set_ufo_bullet_sprites
	.type	set_ufo_bullet_sprites, @function
set_ufo_bullet_sprites:
	addi	sp,sp,-32
	sw	s1,20(sp)
	lui	s1,%hi(.LANCHOR0+1280)
	sw	s0,24(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	sw	s5,4(sp)
	sw	s6,0(sp)
	sw	ra,28(sp)
	addi	s1,s1,%lo(.LANCHOR0+1280)
	li	s0,0
	lui	s6,%hi(LOWER_SPRITE_WRITER_NUMBER)
	li	s5,10
	lui	s4,%hi(LOWER_SPRITE_WRITER_LINE)
	lui	s3,%hi(LOWER_SPRITE_WRITER_BITMAP)
	li	s2,128
.L184:
	lw	a5,%lo(LOWER_SPRITE_WRITER_NUMBER)(s6)
	lhu	a4,0(s1)
	mv	a2,s0
	sb	s5,0(a5)
	lw	a5,%lo(LOWER_SPRITE_WRITER_LINE)(s4)
	li	a1,10
	li	a0,1
	sb	s0,0(a5)
	lw	a5,%lo(LOWER_SPRITE_WRITER_BITMAP)(s3)
	addi	s0,s0,1
	andi	s0,s0,0xff
	sh	a4,0(a5)
	lhu	a3,0(s1)
	addi	s1,s1,2
	call	set_sprite_line
	bne	s0,s2,.L184
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	lw	s4,8(sp)
	lw	s5,4(sp)
	lw	s6,0(sp)
	addi	sp,sp,32
	jr	ra
	.size	set_ufo_bullet_sprites, .-set_ufo_bullet_sprites
	.align	1
	.globl	set_tilemap
	.type	set_tilemap, @function
set_tilemap:
	addi	sp,sp,-32
	li	a0,9
	sw	s2,16(sp)
	sw	s5,4(sp)
	sw	s6,0(sp)
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	lui	s2,%hi(.LANCHOR0+1536)
	call	tilemap_scrollwrapclear
	addi	s2,s2,%lo(.LANCHOR0+1536)
	li	a5,0
	li	s5,16
	li	s6,8
.L188:
	addi	s0,a5,1
	mv	s3,s2
	li	s1,0
	andi	s4,s0,0xff
.L189:
	lhu	a2,0(s3)
	mv	a1,s1
	addi	s1,s1,1
	mv	a0,s4
	andi	s1,s1,0xff
	call	set_tilemap_line
	addi	s3,s3,2
	bne	s1,s5,.L189
	mv	a5,s0
	addi	s2,s2,32
	bne	s0,s6,.L188
	li	a4,21
	li	a3,64
	li	a2,1
	li	a1,4
	li	a0,4
	call	set_tilemap_tile
	li	a4,21
	li	a3,64
	li	a2,2
	li	a1,5
	li	a0,4
	call	set_tilemap_tile
	li	a4,21
	li	a3,64
	li	a2,3
	li	a1,4
	li	a0,5
	call	set_tilemap_tile
	li	a4,21
	li	a3,64
	li	a2,4
	li	a1,5
	li	a0,5
	call	set_tilemap_tile
	li	a4,20
	li	a3,64
	li	a2,1
	li	a1,14
	li	a0,18
	call	set_tilemap_tile
	li	a4,20
	li	a3,64
	li	a2,2
	li	a1,15
	li	a0,18
	call	set_tilemap_tile
	li	a4,20
	li	a3,64
	li	a2,3
	li	a1,14
	li	a0,19
	call	set_tilemap_tile
	li	a4,20
	li	a3,64
	li	a2,4
	li	a1,15
	li	a0,19
	call	set_tilemap_tile
	li	a4,5
	li	a3,64
	li	a2,1
	li	a1,28
	li	a0,34
	call	set_tilemap_tile
	li	a4,5
	li	a3,64
	li	a2,2
	li	a1,29
	li	a0,34
	call	set_tilemap_tile
	li	a4,5
	li	a3,64
	li	a2,3
	li	a1,28
	li	a0,35
	call	set_tilemap_tile
	li	a4,5
	li	a3,64
	li	a2,4
	li	a1,29
	li	a0,35
	call	set_tilemap_tile
	li	a4,42
	li	a3,64
	li	a2,5
	li	a1,2
	li	a0,36
	call	set_tilemap_tile
	li	a4,42
	li	a3,64
	li	a2,6
	li	a1,3
	li	a0,36
	call	set_tilemap_tile
	li	a4,42
	li	a3,64
	li	a2,7
	li	a1,2
	li	a0,37
	call	set_tilemap_tile
	li	a4,42
	li	a3,64
	li	a2,8
	li	a1,3
	li	a0,37
	call	set_tilemap_tile
	li	a4,16
	li	a3,64
	li	a2,5
	li	a1,26
	li	a0,6
	call	set_tilemap_tile
	li	a4,16
	li	a3,64
	li	a2,6
	li	a1,27
	li	a0,6
	call	set_tilemap_tile
	li	a4,16
	li	a3,64
	li	a2,7
	li	a1,26
	li	a0,7
	call	set_tilemap_tile
	lw	s0,24(sp)
	lw	ra,28(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	lw	s4,8(sp)
	lw	s5,4(sp)
	lw	s6,0(sp)
	li	a4,16
	li	a3,64
	li	a2,8
	li	a1,27
	li	a0,7
	addi	sp,sp,32
	tail	set_tilemap_tile
	.size	set_tilemap, .-set_tilemap
	.align	1
	.globl	risc_ice_v_logo
	.type	risc_ice_v_logo, @function
risc_ice_v_logo:
	addi	sp,sp,-16
	sw	ra,12(sp)
	call	gpu_cs
	li	a4,100
	li	a3,100
	li	a2,0
	li	a1,0
	li	a0,56
	call	gpu_rectangle
	li	a6,100
	li	a5,50
	li	a4,100
	li	a3,100
	li	a2,33
	li	a1,100
	li	a0,63
	call	gpu_triangle
	li	a6,100
	li	a5,66
	li	a4,100
	li	a3,100
	li	a2,50
	li	a1,100
	li	a0,2
	call	gpu_triangle
	li	a4,50
	li	a3,33
	li	a2,0
	li	a1,0
	li	a0,2
	call	gpu_rectangle
	li	a3,26
	li	a2,25
	li	a1,25
	li	a0,63
	call	gpu_fillcircle
	li	a4,12
	li	a3,25
	li	a2,0
	li	a1,0
	li	a0,63
	call	gpu_rectangle
	li	a3,12
	li	a2,25
	li	a1,25
	li	a0,2
	call	gpu_fillcircle
	li	a6,100
	li	a5,0
	li	a4,100
	li	a3,67
	li	a2,33
	li	a1,0
	li	a0,63
	call	gpu_triangle
	li	a6,100
	li	a5,0
	li	a4,100
	li	a3,50
	li	a2,50
	li	a1,0
	li	a0,2
	call	gpu_triangle
	li	a4,37
	li	a3,25
	li	a2,12
	li	a1,0
	li	a0,2
	call	gpu_rectangle
	lw	ra,12(sp)
	li	a4,100
	li	a3,8
	li	a2,37
	li	a1,0
	li	a0,2
	addi	sp,sp,16
	tail	gpu_rectangle
	.size	risc_ice_v_logo, .-risc_ice_v_logo
	.align	1
	.globl	setup_game
	.type	setup_game, @function
setup_game:
	addi	sp,sp,-32
	sw	s1,20(sp)
	lui	s1,%hi(.LANCHOR1)
	addi	s1,s1,%lo(.LANCHOR1)
	sw	s0,24(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	sw	s5,4(sp)
	sw	ra,28(sp)
	li	s0,0
	li	s3,19
	addi	s5,s1,20
	li	s4,12
	li	s2,26
.L198:
	andi	a1,s0,0xff
	bgtu	s0,s3,.L196
	add	a5,s1,s0
	sb	zero,0(a5)
	add	a5,s5,s0
	sb	zero,0(a5)
.L196:
	sltiu	a0,a1,13
	xori	a0,a0,1
	bleu	a1,s4,.L197
	addi	a1,a1,-13
	andi	a1,a1,0xff
.L197:
	li	a7,0
	li	a6,0
	li	a5,0
	li	a4,0
	li	a3,0
	li	a2,0
	addi	s0,s0,1
	call	set_sprite
	bne	s0,s2,.L198
	call	gpu_cs
	lui	a5,%hi(TERMINAL_SHOWHIDE)
	lw	a5,%lo(TERMINAL_SHOWHIDE)(a5)
	li	a2,7
	li	a1,1
	sb	zero,0(a5)
	li	a0,42
	call	set_background
	call	risc_ice_v_logo
	li	a0,9
	call	tilemap_scrollwrapclear
	call	set_tilemap
	call	tpu_cs
	call	set_asteroid_sprites
	li	a0,0
	call	set_ship_sprites
	call	set_ship_vector
	call	set_bullet_sprites
	call	set_ufo_bullet_sprites
	lui	a5,%hi(lives)
	sh	zero,%lo(lives)(a5)
	lui	a5,%hi(score)
	sh	zero,%lo(score)(a5)
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
	addi	sp,sp,32
	jr	ra
	.size	setup_game, .-setup_game
	.align	1
	.globl	find_asteroid_space
	.type	find_asteroid_space, @function
find_asteroid_space:
	lui	a2,%hi(.LANCHOR1)
	li	a4,0
	li	a5,0
	li	a0,255
	addi	a2,a2,%lo(.LANCHOR1)
	li	a1,20
.L203:
	add	a3,a2,a4
	lbu	a3,0(a3)
	andi	a6,a4,0xff
	bne	a3,zero,.L202
	mv	a0,a6
.L202:
	seqz	a3,a3
	add	a5,a5,a3
	addi	a4,a4,1
	andi	a5,a5,0xff
	bne	a4,a1,.L203
	li	a4,1
	bne	a5,a4,.L204
	li	a0,255
.L204:
	ret
	.size	find_asteroid_space, .-find_asteroid_space
	.align	1
	.globl	move_asteroids
	.type	move_asteroids, @function
move_asteroids:
	addi	sp,sp,-64
	sw	s4,40(sp)
	sw	s5,36(sp)
	lui	s4,%hi(.LANCHOR1)
	sw	s6,32(sp)
	lui	s5,%hi(.LANCHOR0)
	lui	s6,%hi(ufo_directions)
	sw	s1,52(sp)
	sw	s2,48(sp)
	sw	s3,44(sp)
	sw	s7,28(sp)
	sw	s8,24(sp)
	sw	s9,20(sp)
	addi	s1,s4,%lo(.LANCHOR1)
	sw	ra,60(sp)
	sw	s0,56(sp)
	li	s2,246
	li	s3,0
	addi	s4,s4,%lo(.LANCHOR1)
	addi	s5,s5,%lo(.LANCHOR0)
	lui	s7,%hi(ufo_leftright)
	addi	s6,s6,%lo(ufo_directions)
	lui	s8,%hi(ufo_sprite_number)
	li	s9,-1
.L218:
	lbu	a5,0(s1)
	li	a4,1
	andi	s0,s3,0xff
	addi	a5,a5,-1
	andi	a5,a5,0xff
	bgtu	a5,a4,.L208
	sltiu	a0,s0,10
	li	a5,9
	xori	a0,a0,1
	mv	a1,s0
	bleu	s0,a5,.L209
	mv	a1,s2
.L209:
	add	a5,s4,s3
	lbu	a5,20(a5)
	slli	a5,a5,1
	add	a5,s5,a5
	lhu	a2,1792(a5)
	call	update_sprite
.L208:
	lbu	a4,0(s1)
	li	a5,3
	bne	a4,a5,.L211
	sltiu	a0,s0,10
	li	a5,9
	xori	a0,a0,1
	mv	a1,s0
	bleu	s0,a5,.L212
	mv	a1,s2
.L212:
	lui	a4,%hi(level)
	lhu	a4,%lo(level)(a4)
	lbu	a5,%lo(ufo_leftright)(s7)
	li	a3,2
	sgtu	a4,a4,a3
	slli	a4,a4,1
	add	a5,a5,a4
	slli	a5,a5,1
	add	a5,s6,a5
	lhu	a2,0(a5)
	sw	a1,12(sp)
	sw	a0,8(sp)
	call	update_sprite
	lw	a1,12(sp)
	lw	a0,8(sp)
	li	a2,0
	call	get_sprite_attribute
	bne	a0,zero,.L211
	call	set_ufo_sprite
	sb	zero,0(s1)
	sb	s9,%lo(ufo_sprite_number)(s8)
.L211:
	lbu	a5,0(s1)
	li	a4,5
	bleu	a5,a4,.L215
	addi	a5,a5,-1
	sb	a5,0(s1)
.L215:
	lbu	a4,0(s1)
	li	a5,5
	bne	a4,a5,.L216
	sltiu	a0,s0,10
	sb	zero,0(s1)
	li	a5,9
	xori	a0,a0,1
	bleu	s0,a5,.L217
	mv	s0,s2
.L217:
	li	a7,0
	li	a6,0
	li	a5,0
	li	a4,0
	li	a3,0
	li	a2,0
	mv	a1,s0
	call	set_sprite
.L216:
	addi	s2,s2,1
	addi	s3,s3,1
	li	a5,20
	addi	s1,s1,1
	andi	s2,s2,0xff
	bne	s3,a5,.L218
	lw	ra,60(sp)
	lw	s0,56(sp)
	lw	s1,52(sp)
	lw	s2,48(sp)
	lw	s3,44(sp)
	lw	s4,40(sp)
	lw	s5,36(sp)
	lw	s6,32(sp)
	lw	s7,28(sp)
	lw	s8,24(sp)
	lw	s9,20(sp)
	addi	sp,sp,64
	jr	ra
	.size	move_asteroids, .-move_asteroids
	.align	1
	.globl	count_asteroids
	.type	count_asteroids, @function
count_asteroids:
	lui	a3,%hi(.LANCHOR1)
	li	a4,0
	li	a0,0
	addi	a3,a3,%lo(.LANCHOR1)
	li	a1,1
	li	a2,20
.L226:
	add	a5,a3,a4
	lbu	a5,0(a5)
	addi	a5,a5,-1
	andi	a5,a5,0xff
	bgtu	a5,a1,.L225
	addi	a0,a0,1
	slli	a0,a0,16
	srai	a0,a0,16
.L225:
	addi	a4,a4,1
	bne	a4,a2,.L226
	slli	a0,a0,16
	srli	a0,a0,16
	ret
	.size	count_asteroids, .-count_asteroids
	.align	1
	.globl	draw_ship
	.type	draw_ship, @function
draw_ship:
	addi	sp,sp,-32
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	lui	s1,%hi(shipy)
	lui	s2,%hi(shipdirection)
	lui	s0,%hi(shipx)
	lbu	a6,%lo(shipdirection)(s2)
	lh	a5,%lo(shipy)(s1)
	lh	a4,%lo(shipx)(s0)
	mv	a3,a0
	sw	a0,12(sp)
	li	a7,0
	li	a2,1
	li	a1,11
	li	a0,0
	sw	ra,28(sp)
	call	set_sprite
	lh	a4,%lo(shipx)(s0)
	lw	s0,24(sp)
	lbu	a6,%lo(shipdirection)(s2)
	lh	a5,%lo(shipy)(s1)
	lw	a3,12(sp)
	lw	ra,28(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	li	a7,0
	li	a2,1
	li	a1,11
	li	a0,1
	addi	sp,sp,32
	tail	set_sprite
	.size	draw_ship, .-draw_ship
	.align	1
	.globl	move_ship
	.type	move_ship, @function
move_ship:
	lui	a5,%hi(shipdirection)
	lhu	a5,%lo(shipdirection)(a5)
	li	a4,7
	bgtu	a5,a4,.L230
	lui	a4,%hi(.L233)
	slli	a5,a5,2
	addi	a4,a4,%lo(.L233)
	add	a5,a5,a4
	lw	a5,0(a5)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L233:
	.word	.L269
	.word	.L239
	.word	.L238
	.word	.L237
	.word	.L273
	.word	.L235
	.word	.L234
	.word	.L232
	.text
.L239:
	lui	a5,%hi(shipx)
	lh	a4,%lo(shipx)(a5)
	li	a2,623
	li	a3,0
	bgt	a4,a2,.L251
	addi	a4,a4,1
.L275:
	slli	a3,a4,16
	srai	a3,a3,16
.L251:
	sh	a3,%lo(shipx)(a5)
.L269:
	lui	a5,%hi(shipy)
	lh	a4,%lo(shipy)(a5)
	li	a3,464
	ble	a4,zero,.L252
	addi	a4,a4,-1
	j	.L267
.L238:
	lui	a5,%hi(shipx)
	lh	a4,%lo(shipx)(a5)
	li	a2,623
	li	a3,0
	bgt	a4,a2,.L250
	addi	a4,a4,1
.L265:
	slli	a3,a4,16
	srai	a3,a3,16
.L250:
	sh	a3,%lo(shipx)(a5)
	ret
.L237:
	lui	a5,%hi(shipx)
	lh	a4,%lo(shipx)(a5)
	li	a2,623
	li	a3,0
	bgt	a4,a2,.L248
	addi	a4,a4,1
.L276:
	slli	a3,a4,16
	srai	a3,a3,16
.L248:
	sh	a3,%lo(shipx)(a5)
.L273:
	lui	a5,%hi(shipy)
	lh	a4,%lo(shipy)(a5)
	li	a2,463
	li	a3,0
	bgt	a4,a2,.L252
	addi	a4,a4,1
.L267:
	slli	a3,a4,16
	srai	a3,a3,16
.L252:
	sh	a3,%lo(shipy)(a5)
.L230:
	ret
.L235:
	lui	a5,%hi(shipx)
	lh	a4,%lo(shipx)(a5)
	li	a3,624
	ble	a4,zero,.L248
	addi	a4,a4,-1
	j	.L276
.L234:
	lui	a5,%hi(shipx)
	lh	a4,%lo(shipx)(a5)
	li	a3,624
	ble	a4,zero,.L250
	addi	a4,a4,-1
	j	.L265
.L232:
	lui	a5,%hi(shipx)
	lh	a4,%lo(shipx)(a5)
	li	a3,624
	ble	a4,zero,.L251
	addi	a4,a4,-1
	j	.L275
	.size	move_ship, .-move_ship
	.section	.rodata.str1.4
	.align	2
.LC1:
	.string	"Score "
	.align	2
.LC2:
	.string	"Level "
	.text
	.align	1
	.globl	draw_score
	.type	draw_score, @function
draw_score:
	lui	a5,%hi(lives)
	lhu	a4,%lo(lives)(a5)
	addi	sp,sp,-16
	sw	s0,8(sp)
	sw	ra,12(sp)
	mv	s0,a5
	li	a3,21
	beq	a4,zero,.L278
	li	a3,63
.L278:
	li	a2,64
	li	a1,1
	li	a0,34
	call	tpu_set
	lui	a0,%hi(.LC1)
	addi	a0,a0,%lo(.LC1)
	call	tpu_outputstring
	lui	a5,%hi(score)
	lhu	a0,%lo(score)(a5)
	call	tpu_outputnumber_short
	lhu	a5,%lo(lives)(s0)
	li	a3,63
	bne	a5,zero,.L279
	li	a3,21
.L279:
	li	a2,64
	li	a1,28
	li	a0,1
	call	tpu_set
	lui	a0,%hi(.LC2)
	addi	a0,a0,%lo(.LC2)
	call	tpu_outputstring
	lui	a5,%hi(level)
	lw	s0,8(sp)
	lw	ra,12(sp)
	lhu	a0,%lo(level)(a5)
	addi	sp,sp,16
	tail	tpu_outputnumber_short
	.size	draw_score, .-draw_score
	.align	1
	.globl	draw_lives
	.type	draw_lives, @function
draw_lives:
	lui	a5,%hi(lives)
	lhu	a5,%lo(lives)(a5)
	addi	sp,sp,-16
	sw	ra,12(sp)
	li	a4,2
	beq	a5,a4,.L285
	li	a4,3
	beq	a5,a4,.L286
	li	a4,1
	bne	a5,a4,.L289
.L287:
	lw	ra,12(sp)
	li	a3,464
	li	a2,544
	li	a1,63
	li	a0,0
	addi	sp,sp,16
	tail	draw_vector_block
.L286:
	li	a3,464
	li	a2,608
	li	a1,63
	li	a0,0
	call	draw_vector_block
.L285:
	li	a3,464
	li	a2,576
	li	a1,63
	li	a0,0
	call	draw_vector_block
	j	.L287
.L289:
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	draw_lives, .-draw_lives
	.align	1
	.globl	fire_bullet
	.type	fire_bullet, @function
fire_bullet:
	lui	a3,%hi(shipdirection)
	lh	a3,%lo(shipdirection)(a3)
	lui	a2,%hi(bulletdirection)
	addi	sp,sp,-32
	slli	a1,a3,16
	sh	a3,%lo(bulletdirection)(a2)
	sw	ra,28(sp)
	srli	a1,a1,16
	li	a2,7
	li	a4,0
	li	a5,0
	bgtu	a1,a2,.L292
	lui	a5,%hi(.L294)
	addi	a5,a5,%lo(.L294)
	slli	a3,a3,2
	add	a3,a3,a5
	lw	a3,0(a3)
	lui	a4,%hi(shipx)
	lui	a5,%hi(shipy)
	jr	a3
	.section	.rodata
	.align	2
	.align	2
.L294:
	.word	.L301
	.word	.L300
	.word	.L299
	.word	.L298
	.word	.L297
	.word	.L296
	.word	.L295
	.word	.L293
	.text
.L301:
	lh	a4,%lo(shipx)(a4)
.L303:
	lhu	a5,%lo(shipy)(a5)
	addi	a5,a5,-10
	j	.L305
.L300:
	lhu	a4,%lo(shipx)(a4)
	addi	a4,a4,8
.L304:
	slli	a4,a4,16
	srai	a4,a4,16
	j	.L303
.L299:
	lhu	a4,%lo(shipx)(a4)
	addi	a4,a4,10
.L306:
	lh	a5,%lo(shipy)(a5)
	slli	a4,a4,16
	srai	a4,a4,16
.L292:
	li	a7,0
	li	a6,2
	li	a3,60
	li	a2,1
	li	a1,12
	li	a0,0
	sw	a5,12(sp)
	sw	a4,8(sp)
	call	set_sprite
	lw	a5,12(sp)
	lw	a4,8(sp)
	li	a2,1
	li	a1,12
	li	a0,1
	li	a7,0
	li	a6,0
	li	a3,48
	call	set_sprite
	lw	ra,28(sp)
	li	a2,128
	li	a1,61
	li	a0,4
	addi	sp,sp,32
	tail	beep.part.0
.L298:
	lhu	a4,%lo(shipx)(a4)
	addi	a4,a4,10
.L308:
	slli	a4,a4,16
	srai	a4,a4,16
	j	.L307
.L297:
	lh	a4,%lo(shipx)(a4)
.L307:
	lhu	a5,%lo(shipy)(a5)
	addi	a5,a5,10
.L305:
	slli	a5,a5,16
	srai	a5,a5,16
	j	.L292
.L296:
	lhu	a4,%lo(shipx)(a4)
	addi	a4,a4,-10
	j	.L308
.L295:
	lhu	a4,%lo(shipx)(a4)
	addi	a4,a4,-10
	j	.L306
.L293:
	lhu	a4,%lo(shipx)(a4)
	addi	a4,a4,-10
	j	.L304
	.size	fire_bullet, .-fire_bullet
	.align	1
	.globl	update_bullet
	.type	update_bullet, @function
update_bullet:
	lui	a1,%hi(bulletdirection)
	lh	a4,%lo(bulletdirection)(a1)
	lui	a5,%hi(.LANCHOR0)
	addi	a5,a5,%lo(.LANCHOR0)
	slli	a4,a4,1
	add	a4,a5,a4
	lui	a2,%hi(LOWER_SPRITE_NUMBER)
	lhu	a0,1816(a4)
	lw	a4,%lo(LOWER_SPRITE_NUMBER)(a2)
	li	a3,12
	lui	a6,%hi(LOWER_SPRITE_UPDATE)
	sb	a3,0(a4)
	lw	a4,%lo(LOWER_SPRITE_UPDATE)(a6)
	sh	a0,0(a4)
	lh	a4,%lo(bulletdirection)(a1)
	lui	a1,%hi(UPPER_SPRITE_NUMBER)
	slli	a4,a4,1
	add	a4,a5,a4
	lhu	a0,1816(a4)
	lw	a4,%lo(UPPER_SPRITE_NUMBER)(a1)
	sb	a3,0(a4)
	lui	a3,%hi(UPPER_SPRITE_UPDATE)
	lw	a4,%lo(UPPER_SPRITE_UPDATE)(a3)
	sh	a0,0(a4)
	lui	a0,%hi(ufo_bullet_direction)
	lbu	a4,%lo(ufo_bullet_direction)(a0)
	slli	a4,a4,1
	add	a4,a5,a4
	lhu	a7,1816(a4)
	lw	a4,%lo(LOWER_SPRITE_NUMBER)(a2)
	li	a2,10
	sb	a2,0(a4)
	lw	a4,%lo(LOWER_SPRITE_UPDATE)(a6)
	sh	a7,0(a4)
	lbu	a4,%lo(ufo_bullet_direction)(a0)
	slli	a4,a4,1
	add	a5,a5,a4
	lhu	a4,1816(a5)
	lw	a5,%lo(UPPER_SPRITE_NUMBER)(a1)
	sb	a2,0(a5)
	lw	a5,%lo(UPPER_SPRITE_UPDATE)(a3)
	sh	a4,0(a5)
	ret
	.size	update_bullet, .-update_bullet
	.section	.rodata.str1.4
	.align	2
.LC3:
	.string	"         Welcome to Risc-ICE-V Asteroids        "
	.align	2
.LC4:
	.string	"By @robng15 (Twitter) from Whitebridge, Scotland"
	.align	2
.LC5:
	.string	"                 Press UP to start              "
	.align	2
.LC6:
	.string	"          Written in Silice by @sylefeb         "
	.text
	.align	1
	.globl	beepboop
	.type	beepboop, @function
beepboop:
	addi	sp,sp,-16
	sw	s0,8(sp)
	lui	s0,%hi(TIMER1HZ)
	lw	a5,%lo(TIMER1HZ)(s0)
	sw	s1,4(sp)
	lui	s1,%hi(last_timer)
	lhu	a5,0(a5)
	lh	a4,%lo(last_timer)(s1)
	sw	ra,12(sp)
	slli	a5,a5,16
	srli	a5,a5,16
	beq	a4,a5,.L310
	call	draw_score
	lw	a5,%lo(TIMER1HZ)(s0)
	li	a0,5
	lhu	a5,0(a5)
	sh	a5,%lo(last_timer)(s1)
	call	tilemap_scrollwrapclear
	lw	a5,%lo(TIMER1HZ)(s0)
	li	a3,2
	lui	a4,%hi(lives)
	lhu	a5,0(a5)
	andi	a5,a5,3
	beq	a5,a3,.L313
	li	a3,3
	beq	a5,a3,.L314
	li	a3,1
	beq	a5,a3,.L315
	lhu	a5,%lo(lives)(a4)
	beq	a5,zero,.L316
	li	a3,500
	li	a2,1
.L321:
	lw	s0,8(sp)
	lw	ra,12(sp)
	lw	s1,4(sp)
	li	a1,0
	li	a0,1
	addi	sp,sp,16
	tail	beep
.L316:
	li	a0,16
	li	a3,3
	li	a2,64
	li	a1,18
	call	tpu_set
	lui	a0,%hi(.LC3)
	addi	a0,a0,%lo(.LC3)
.L322:
	lw	s0,8(sp)
	lw	ra,12(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	tail	tpu_outputstring
.L315:
	lhu	a5,%lo(lives)(a4)
	bne	a5,zero,.L310
	li	a0,16
	li	a3,15
	li	a2,64
	li	a1,18
	call	tpu_set
	lui	a0,%hi(.LC4)
	addi	a0,a0,%lo(.LC4)
	j	.L322
.L313:
	lhu	a5,%lo(lives)(a4)
	beq	a5,zero,.L318
	li	a3,500
	li	a2,2
	j	.L321
.L318:
	li	a0,16
	li	a3,60
	li	a2,64
	li	a1,18
	call	tpu_set
	lui	a0,%hi(.LC5)
	addi	a0,a0,%lo(.LC5)
	j	.L322
.L314:
	lhu	a5,%lo(lives)(a4)
	bne	a5,zero,.L319
	li	a0,16
	li	a3,48
	li	a2,64
	li	a1,18
	call	tpu_set
	lui	a0,%hi(.LC6)
	addi	a0,a0,%lo(.LC6)
	call	tpu_outputstring
.L319:
	lw	s0,8(sp)
	lw	ra,12(sp)
	lw	s1,4(sp)
	li	a0,6
	addi	sp,sp,16
	tail	tilemap_scrollwrapclear
.L310:
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
	.size	beepboop, .-beepboop
	.align	1
	.globl	spawn_asteroid
	.type	spawn_asteroid, @function
spawn_asteroid:
	addi	sp,sp,-32
	sw	s1,20(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s2,16(sp)
	mv	s1,a0
	mv	s3,a1
	mv	s4,a2
	call	find_asteroid_space
	li	a5,255
	beq	a0,a5,.L323
	lui	a3,%hi(.LANCHOR1)
	addi	a5,a3,%lo(.LANCHOR1)
	add	a5,a5,a0
	sb	s1,0(a5)
	li	a5,2
	mv	s0,a0
	addi	s2,a3,%lo(.LANCHOR1)
	li	a0,4
	beq	s1,a5,.L325
	li	a0,8
.L325:
	call	rng
	add	a3,s2,s0
	sb	a0,20(a3)
	li	a5,9
	sltiu	a0,s0,10
	xori	a0,a0,1
	bleu	s0,a5,.L326
	addi	s0,s0,-10
	andi	s0,s0,0xff
.L326:
	lui	a5,%hi(RNG)
	lw	a2,%lo(RNG)(a5)
	li	a1,31
	li	a6,7
	lhu	a3,0(a2)
	lhu	a4,0(a2)
	lhu	a5,0(a2)
	lhu	a2,0(a2)
	slli	a3,a3,16
	srli	a3,a3,16
	slli	a2,a2,16
	remu	a3,a3,a1
	srli	a2,a2,16
	andi	a5,a5,15
	andi	a4,a4,15
	addi	a5,a5,-8
	addi	a4,a4,-8
	mv	a1,s0
	lw	s0,24(sp)
	lw	ra,28(sp)
	lw	s2,16(sp)
	addi	a7,s1,-2
	add	a5,a5,s4
	lw	s1,20(sp)
	lw	s4,8(sp)
	add	a4,a4,s3
	lw	s3,12(sp)
	slli	a5,a5,16
	slli	a4,a4,16
	seqz	a7,a7
	srai	a5,a5,16
	srai	a4,a4,16
	addi	sp,sp,32
	remu	a6,a2,a6
	addi	a3,a3,32
	li	a2,1
	tail	set_sprite
.L323:
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	lw	s4,8(sp)
	addi	sp,sp,32
	jr	ra
	.size	spawn_asteroid, .-spawn_asteroid
	.align	1
	.globl	check_ufo_bullet_hit
	.type	check_ufo_bullet_hit, @function
check_ufo_bullet_hit:
	lui	a5,%hi(LOWER_SPRITE_COLLISION_BASE)
	lw	a5,%lo(LOWER_SPRITE_COLLISION_BASE)(a5)
	lhu	a5,20(a5)
	andi	a5,a5,1023
	bne	a5,zero,.L330
	lui	a5,%hi(UPPER_SPRITE_COLLISION_BASE)
	lw	a5,%lo(UPPER_SPRITE_COLLISION_BASE)(a5)
	lhu	a5,20(a5)
	andi	a5,a5,1023
	beq	a5,zero,.L349
.L330:
	addi	sp,sp,-48
	li	a2,500
	li	a1,8
	li	a0,4
	sw	s0,40(sp)
	sw	s1,36(sp)
	sw	s2,32(sp)
	sw	s3,28(sp)
	sw	ra,44(sp)
	sw	s4,24(sp)
	sw	s5,20(sp)
	sw	s6,16(sp)
	sw	s7,12(sp)
	li	s0,255
	call	beep.part.0
	li	s1,0
	li	s3,9
	li	s2,20
.L334:
	sltiu	a0,s1,10
	xori	a0,a0,1
	mv	a1,s1
	bleu	s1,s3,.L332
	addi	a1,s1,-10
	andi	a1,a1,0xff
.L332:
	call	get_sprite_collision
	andi	a0,a0,1024
	beq	a0,zero,.L333
	mv	s0,s1
.L333:
	addi	s1,s1,1
	andi	s1,s1,0xff
	bne	s1,s2,.L334
	li	a5,255
	beq	s0,a5,.L329
	lui	s2,%hi(.LANCHOR1)
	addi	a5,s2,%lo(.LANCHOR1)
	add	a5,a5,s0
	lbu	a4,0(a5)
	li	a5,2
	mv	s5,s0
	addi	s2,s2,%lo(.LANCHOR1)
	bgtu	a4,a5,.L329
	lui	a5,%hi(LOWER_SPRITE_NUMBER)
	lw	a4,%lo(LOWER_SPRITE_NUMBER)(a5)
	li	a5,10
	sltiu	s3,s0,10
	sb	a5,0(a4)
	lui	a4,%hi(LOWER_SPRITE_ACTIVE)
	lw	a4,%lo(LOWER_SPRITE_ACTIVE)(a4)
	xori	s3,s3,1
	sb	zero,0(a4)
	lui	a4,%hi(UPPER_SPRITE_NUMBER)
	lw	a4,%lo(UPPER_SPRITE_NUMBER)(a4)
	sb	a5,0(a4)
	lui	a5,%hi(UPPER_SPRITE_ACTIVE)
	lw	a5,%lo(UPPER_SPRITE_ACTIVE)(a5)
	sb	zero,0(a5)
	li	a5,9
	bleu	s0,a5,.L336
	addi	s0,s0,-10
	andi	s0,s0,0xff
.L336:
	li	a2,3
	mv	a1,s0
	mv	a0,s3
	call	get_sprite_attribute
	mv	s4,a0
	li	a2,4
	mv	a1,s0
	mv	a0,s3
	call	get_sprite_attribute
	add	a5,s2,s5
	lbu	a5,0(a5)
	li	a4,2
	mv	s7,a0
	bne	a5,a4,.L337
	lui	a4,%hi(level)
	lhu	a4,%lo(level)(a4)
	mv	s1,a4
	bleu	a4,a5,.L338
	li	s1,2
.L338:
	li	a3,2
	andi	s1,s1,0xff
	li	a5,0
	bleu	a4,a3,.L339
	lui	a5,%hi(RNG)
	lw	a5,%lo(RNG)(a5)
	lhu	a5,0(a5)
	andi	a5,a5,1
.L339:
	addi	s1,s1,1
	add	a5,a5,s1
	andi	s1,a5,0xff
	li	s6,0
.L340:
	mv	a2,s7
	mv	a1,s4
	li	a0,1
	addi	s6,s6,1
	call	spawn_asteroid
	blt	s6,s1,.L340
.L337:
	li	a3,7
	li	a2,1
	mv	a1,s0
	mv	a0,s3
	call	set_sprite_attribute
	add	s2,s2,s5
	li	a5,32
	sb	a5,0(s2)
.L329:
	lw	ra,44(sp)
	lw	s0,40(sp)
	lw	s1,36(sp)
	lw	s2,32(sp)
	lw	s3,28(sp)
	lw	s4,24(sp)
	lw	s5,20(sp)
	lw	s6,16(sp)
	lw	s7,12(sp)
	addi	sp,sp,48
	jr	ra
.L349:
	ret
	.size	check_ufo_bullet_hit, .-check_ufo_bullet_hit
	.align	1
	.globl	check_hit
	.type	check_hit, @function
check_hit:
	lui	a5,%hi(LOWER_SPRITE_COLLISION_BASE)
	lw	a5,%lo(LOWER_SPRITE_COLLISION_BASE)(a5)
	lhu	a5,24(a5)
	andi	a5,a5,1023
	bne	a5,zero,.L352
	lui	a5,%hi(UPPER_SPRITE_COLLISION_BASE)
	lw	a5,%lo(UPPER_SPRITE_COLLISION_BASE)(a5)
	lhu	a5,24(a5)
	andi	a5,a5,1023
	beq	a5,zero,.L376
.L352:
	addi	sp,sp,-64
	li	a2,500
	li	a1,8
	li	a0,4
	sw	s0,56(sp)
	sw	s1,52(sp)
	sw	s2,48(sp)
	sw	s3,44(sp)
	sw	s4,40(sp)
	sw	ra,60(sp)
	sw	s5,36(sp)
	sw	s6,32(sp)
	sw	s7,28(sp)
	sw	s8,24(sp)
	li	s0,255
	call	beep.part.0
	li	s1,0
	li	s3,9
	li	s4,4096
	li	s2,20
.L356:
	sltiu	a0,s1,10
	xori	a0,a0,1
	mv	a1,s1
	bleu	s1,s3,.L354
	addi	a1,s1,-10
	andi	a1,a1,0xff
.L354:
	call	get_sprite_collision
	and	a0,a0,s4
	slli	a0,a0,16
	srli	a0,a0,16
	beq	a0,zero,.L355
	mv	s0,s1
.L355:
	addi	s1,s1,1
	andi	s1,s1,0xff
	bne	s1,s2,.L356
	lui	s1,%hi(.LANCHOR1)
	addi	a4,s1,%lo(.LANCHOR1)
	add	a4,a4,s0
	li	a3,255
	lbu	a5,0(a4)
	mv	s4,s0
	addi	s1,s1,%lo(.LANCHOR1)
	beq	s0,a3,.L357
	li	a3,2
	bgtu	a5,a3,.L357
	lui	a5,%hi(LOWER_SPRITE_NUMBER)
	lw	a3,%lo(LOWER_SPRITE_NUMBER)(a5)
	li	a5,12
	sltiu	s3,s0,10
	sb	a5,0(a3)
	lui	a3,%hi(LOWER_SPRITE_ACTIVE)
	lw	a3,%lo(LOWER_SPRITE_ACTIVE)(a3)
	xori	s3,s3,1
	sb	zero,0(a3)
	lui	a3,%hi(UPPER_SPRITE_NUMBER)
	lw	a3,%lo(UPPER_SPRITE_NUMBER)(a3)
	sb	a5,0(a3)
	lui	a5,%hi(UPPER_SPRITE_ACTIVE)
	lw	a5,%lo(UPPER_SPRITE_ACTIVE)(a5)
	lui	a3,%hi(score)
	sb	zero,0(a5)
	lhu	a5,%lo(score)(a3)
	lbu	a4,0(a4)
	addi	a5,a5,3
	sub	a5,a5,a4
	sh	a5,%lo(score)(a3)
	li	a5,9
	bleu	s0,a5,.L358
	addi	s0,s0,-10
	andi	s0,s0,0xff
.L358:
	li	a2,2
	mv	a1,s0
	mv	a0,s3
	call	get_sprite_attribute
	li	a2,3
	mv	a1,s0
	andi	s7,a0,0xff
	mv	a0,s3
	call	get_sprite_attribute
	li	a2,4
	mv	a1,s0
	mv	s5,a0
	mv	a0,s3
	call	get_sprite_attribute
	mv	s6,a0
	li	a2,5
	mv	a1,s0
	mv	a0,s3
	call	get_sprite_attribute
	add	a5,s1,s4
	lbu	a4,0(a5)
	li	a5,2
	andi	a7,a0,0xff
	beq	a4,a5,.L359
.L363:
	li	a6,7
	mv	a5,s6
	mv	a4,s5
	mv	a3,s7
	li	a2,1
	mv	a1,s0
	mv	a0,s3
	call	set_sprite
.L378:
	add	s1,s1,s4
	li	a5,32
	sb	a5,0(s1)
.L351:
	lw	ra,60(sp)
	lw	s0,56(sp)
	lw	s1,52(sp)
	lw	s2,48(sp)
	lw	s3,44(sp)
	lw	s4,40(sp)
	lw	s5,36(sp)
	lw	s6,32(sp)
	lw	s7,28(sp)
	lw	s8,24(sp)
	addi	sp,sp,64
	jr	ra
.L359:
	lui	a5,%hi(level)
	lhu	a5,%lo(level)(a5)
	mv	s2,a5
	bleu	a5,a4,.L360
	li	s2,2
.L360:
	li	a4,2
	andi	s2,s2,0xff
	li	a6,0
	bleu	a5,a4,.L361
	lui	a5,%hi(RNG)
	lw	a5,%lo(RNG)(a5)
	lhu	a6,0(a5)
	andi	a6,a6,1
.L361:
	addi	s2,s2,1
	add	a6,a6,s2
	andi	s2,a6,0xff
	li	s8,0
.L362:
	mv	a2,s6
	mv	a1,s5
	li	a0,1
	sw	a7,12(sp)
	addi	s8,s8,1
	call	spawn_asteroid
	lw	a7,12(sp)
	blt	s8,s2,.L362
	j	.L363
.L357:
	li	a4,3
	bne	a5,a4,.L351
	lui	a5,%hi(level)
	lhu	a3,%lo(level)(a5)
	li	a4,1
	li	a5,10
	bleu	a3,a4,.L365
	li	a5,20
.L365:
	lui	a4,%hi(score)
	lhu	a3,%lo(score)(a4)
	sltiu	s2,s0,10
	xori	s2,s2,1
	add	a5,a5,a3
	sh	a5,%lo(score)(a4)
	lui	a5,%hi(LOWER_SPRITE_NUMBER)
	lw	a4,%lo(LOWER_SPRITE_NUMBER)(a5)
	li	a5,12
	sb	a5,0(a4)
	lui	a4,%hi(LOWER_SPRITE_ACTIVE)
	lw	a4,%lo(LOWER_SPRITE_ACTIVE)(a4)
	sb	zero,0(a4)
	lui	a4,%hi(UPPER_SPRITE_NUMBER)
	lw	a4,%lo(UPPER_SPRITE_NUMBER)(a4)
	sb	a5,0(a4)
	lui	a5,%hi(UPPER_SPRITE_ACTIVE)
	lw	a5,%lo(UPPER_SPRITE_ACTIVE)(a5)
	sb	zero,0(a5)
	li	a5,9
	bleu	s0,a5,.L366
	addi	s0,s0,-10
	andi	s0,s0,0xff
.L366:
	li	a2,3
	mv	a1,s0
	mv	a0,s2
	call	get_sprite_attribute
	li	a2,4
	mv	a1,s0
	mv	a0,s2
	call	get_sprite_attribute
	li	a3,7
	li	a2,1
	mv	a1,s0
	mv	a0,s2
	call	set_sprite_attribute
	li	a3,48
	li	a2,2
	mv	a1,s0
	mv	a0,s2
	call	set_sprite_attribute
	li	a0,0
	call	set_ufo_sprite
	lui	a5,%hi(ufo_sprite_number)
	li	a4,-1
	sb	a4,%lo(ufo_sprite_number)(a5)
	j	.L378
.L376:
	ret
	.size	check_hit, .-check_hit
	.align	1
	.globl	check_crash
	.type	check_crash, @function
check_crash:
	lui	a5,%hi(LOWER_SPRITE_COLLISION_BASE)
	lw	a4,%lo(LOWER_SPRITE_COLLISION_BASE)(a5)
	lhu	a5,22(a4)
	andi	a5,a5,2047
	bne	a5,zero,.L380
	lui	a5,%hi(UPPER_SPRITE_COLLISION_BASE)
	lw	a5,%lo(UPPER_SPRITE_COLLISION_BASE)(a5)
	lhu	a5,22(a5)
	andi	a5,a5,2047
	beq	a5,zero,.L391
.L380:
	lhu	a5,20(a4)
	addi	sp,sp,-16
	sw	s0,8(sp)
	sw	s1,4(sp)
	sw	ra,12(sp)
	andi	a5,a5,1
	lui	s1,%hi(LOWER_SPRITE_NUMBER)
	lui	s0,%hi(UPPER_SPRITE_NUMBER)
	bne	a5,zero,.L382
	lui	a5,%hi(UPPER_SPRITE_COLLISION_BASE)
	lw	a5,%lo(UPPER_SPRITE_COLLISION_BASE)(a5)
	lhu	a5,20(a5)
	andi	a5,a5,1
	beq	a5,zero,.L383
.L382:
	lw	a4,%lo(LOWER_SPRITE_NUMBER)(s1)
	li	a5,10
	sb	a5,0(a4)
	lui	a4,%hi(LOWER_SPRITE_ACTIVE)
	lw	a4,%lo(LOWER_SPRITE_ACTIVE)(a4)
	sb	zero,0(a4)
	lw	a4,%lo(UPPER_SPRITE_NUMBER)(s0)
	sb	a5,0(a4)
	lui	a5,%hi(UPPER_SPRITE_ACTIVE)
	lw	a5,%lo(UPPER_SPRITE_ACTIVE)(a5)
	sb	zero,0(a5)
.L383:
	li	a2,1000
	li	a1,1
	li	a0,4
	call	beep.part.0
	li	a0,1
	call	set_ship_sprites
	lw	a4,%lo(LOWER_SPRITE_NUMBER)(s1)
	li	a5,10
	sb	a5,0(a4)
	lui	a4,%hi(LOWER_SPRITE_TILE)
	lw	a4,%lo(LOWER_SPRITE_TILE)(a4)
	sb	zero,0(a4)
	lw	a4,%lo(UPPER_SPRITE_NUMBER)(s0)
	sb	a5,0(a4)
	lui	a5,%hi(UPPER_SPRITE_TILE)
	lw	a5,%lo(UPPER_SPRITE_TILE)(a5)
	li	a4,1
	sb	a4,0(a5)
	lw	ra,12(sp)
	lw	s0,8(sp)
	lui	a5,%hi(resetship)
	li	a4,75
	sh	a4,%lo(resetship)(a5)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
.L391:
	ret
	.size	check_crash, .-check_crash
	.section	.text.startup,"ax",@progbits
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-64
	sw	s0,56(sp)
	sw	ra,60(sp)
	sw	s1,52(sp)
	sw	s2,48(sp)
	sw	s3,44(sp)
	sw	s4,40(sp)
	sw	s5,36(sp)
	sw	s6,32(sp)
	sw	s7,28(sp)
	sw	s8,24(sp)
	sw	s9,20(sp)
	sw	s10,16(sp)
	lui	s0,%hi(UART_STATUS)
.L394:
	lw	a5,%lo(UART_STATUS)(s0)
	lbu	a5,0(a5)
	andi	a5,a5,1
	bne	a5,zero,.L395
	lui	s6,%hi(.LANCHOR1)
	addi	s6,s6,%lo(.LANCHOR1)
	call	setup_game
	li	s0,4
	lui	s3,%hi(lives)
	lui	s5,%hi(level)
	lui	s7,%hi(shipx)
	li	s8,312
	addi	s9,s6,20
.L455:
	lui	s4,%hi(counter)
	lw	a5,%lo(counter)(s4)
	lui	s1,%hi(ufo_sprite_number)
	lbu	a2,%lo(ufo_sprite_number)(s1)
	addi	a5,a5,1
	sw	a5,%lo(counter)(s4)
	li	a3,255
	li	a4,0
	beq	a2,a3,.L396
	slli	a5,a5,26
	srai	a5,a5,31
	andi	a4,a5,0xff
.L396:
	lui	a5,%hi(LEDS)
	lw	a5,%lo(LEDS)(a5)
	sb	a4,0(a5)
	lbu	a4,%lo(ufo_sprite_number)(s1)
	li	a5,255
	beq	a4,a5,.L397
	lw	a5,%lo(counter)(s4)
	andi	a5,a5,64
	beq	a5,zero,.L397
	lhu	a5,%lo(lives)(s3)
	beq	a5,zero,.L397
	li	a2,32
	li	a1,63
	li	a0,3
	call	beep.part.0
.L397:
	beq	s0,zero,.L398
	call	find_asteroid_space
	li	a5,255
	mv	s2,a0
	beq	a0,a5,.L399
	lui	s10,%hi(RNG)
	lw	a5,%lo(RNG)(s10)
	li	a4,2
	lhu	a5,0(a5)
	andi	a5,a5,3
	beq	a5,a4,.L400
	li	a4,3
	beq	a5,a4,.L401
	li	a4,1
	li	a0,480
	beq	a5,a4,.L402
	call	rng
	slli	a5,a0,16
	srai	a5,a5,16
	li	a4,-31
.L403:
	add	a3,s6,s2
	li	a2,2
	sb	a2,0(a3)
	lw	a2,%lo(RNG)(s10)
	sltiu	a0,s2,10
	xori	a0,a0,1
	lhu	a1,0(a2)
	andi	a1,a1,3
	sb	a1,20(a3)
	li	a3,9
	bleu	s2,a3,.L404
	addi	s2,s2,-10
	andi	s2,s2,0xff
.L404:
	lhu	a3,0(a2)
	lhu	a2,0(a2)
	li	a1,31
	slli	a3,a3,16
	srli	a3,a3,16
	slli	a2,a2,16
	remu	a3,a3,a1
	srli	a2,a2,16
	li	a6,7
	li	a7,1
	mv	a1,s2
	remu	a6,a2,a6
	addi	a3,a3,32
	li	a2,1
	call	set_sprite
.L399:
	addi	s0,s0,-1
	slli	s0,s0,16
	srli	s0,s0,16
.L398:
	call	count_asteroids
	bne	a0,zero,.L405
	lhu	a5,%lo(level)(s5)
	li	a4,4
	addi	a5,a5,1
	slli	a5,a5,16
	srli	a5,a5,16
	sh	a5,%lo(level)(s5)
	mv	s0,a5
	bleu	a5,a4,.L406
	li	s0,4
.L406:
	addi	s0,s0,4
	slli	s0,s0,16
	srli	s0,s0,16
.L405:
	call	await_vblank
	lui	a5,%hi(TIMER1KHZ)
	lw	a5,%lo(TIMER1KHZ)(a5)
	li	a4,8
	sh	a4,0(a5)
	call	beepboop
	li	a0,512
	call	rng
	li	a5,1
	bne	a0,a5,.L408
	lbu	s2,%lo(ufo_sprite_number)(s1)
	li	a5,255
	bne	s2,a5,.L408
	lui	a5,%hi(LOWER_SPRITE_NUMBER)
	lw	a5,%lo(LOWER_SPRITE_NUMBER)(a5)
	li	a4,10
	sb	a4,0(a5)
	lui	a5,%hi(LOWER_SPRITE_ACTIVE)
	lw	a5,%lo(LOWER_SPRITE_ACTIVE)(a5)
	lbu	a5,0(a5)
	andi	a5,a5,0xff
	bne	a5,zero,.L408
	call	find_asteroid_space
	sb	a0,%lo(ufo_sprite_number)(s1)
	beq	a0,s2,.L408
	lui	s2,%hi(shipy)
.L411:
	li	a0,416
	call	rng
	lh	a4,%lo(shipy)(s2)
	addi	a5,a0,32
	slli	a5,a5,16
	srai	a5,a5,16
	addi	a3,a4,-64
	blt	a5,a3,.L410
	addi	a4,a4,64
	ble	a5,a4,.L411
.L410:
	lui	a4,%hi(RNG)
	lw	a4,%lo(RNG)(a4)
	li	a0,1
	lui	s2,%hi(ufo_leftright)
	lhu	a4,0(a4)
	sw	a5,12(sp)
	andi	a4,a4,1
	sb	a4,%lo(ufo_leftright)(s2)
	call	set_ufo_sprite
	lbu	a1,%lo(ufo_sprite_number)(s1)
	li	a4,9
	lw	a5,12(sp)
	sltiu	a0,a1,10
	xori	a0,a0,1
	bleu	a1,a4,.L412
	addi	a1,a1,-10
	andi	a1,a1,0xff
.L412:
	lbu	a2,%lo(ufo_leftright)(s2)
	li	a3,1
	lhu	a7,%lo(level)(s5)
	li	a4,639
	beq	a2,a3,.L413
	li	a4,-15
	bgtu	a7,a3,.L413
	li	a4,-31
.L413:
	sltiu	a7,a7,2
	li	a6,0
	li	a3,19
	li	a2,1
	call	set_sprite
	lbu	a5,%lo(ufo_sprite_number)(s1)
	li	a4,3
	add	a5,s6,a5
	sb	a4,0(a5)
.L408:
	lhu	a4,%lo(level)(s5)
	li	a5,3
	li	a0,64
	bgtu	a4,a5,.L414
	li	a0,128
.L414:
	call	rng
	li	a5,1
	bne	a0,a5,.L416
	lui	a5,%hi(LOWER_SPRITE_NUMBER)
	lw	a5,%lo(LOWER_SPRITE_NUMBER)(a5)
	li	a4,10
	sb	a4,0(a5)
	lui	a5,%hi(LOWER_SPRITE_ACTIVE)
	lw	a5,%lo(LOWER_SPRITE_ACTIVE)(a5)
	lbu	a5,0(a5)
	andi	a5,a5,0xff
	bne	a5,zero,.L416
	lbu	a4,%lo(ufo_sprite_number)(s1)
	li	a5,255
	beq	a4,a5,.L416
	lhu	a5,%lo(level)(s5)
	bne	a5,zero,.L418
	lhu	a5,%lo(lives)(s3)
	beq	a5,zero,.L418
.L432:
	lui	a5,%hi(resetship)
	lh	a2,%lo(resetship)(a5)
	beq	a2,zero,.L419
.L420:
	lui	s1,%hi(resetship)
	lhu	a5,%lo(resetship)(s1)
	li	a4,15
	addi	a5,a5,-1
	slli	a5,a5,16
	srli	a5,a5,16
	bleu	a5,a4,.L445
	lhu	a5,%lo(lives)(s3)
	bne	a5,zero,.L446
.L445:
	li	a0,21
	call	draw_ship
	lhu	a5,%lo(resetship)(s1)
	li	a4,15
	addi	a5,a5,-1
	slli	a5,a5,16
	srli	a5,a5,16
	bgtu	a5,a4,.L446
	lui	a4,%hi(LOWER_SPRITE_COLLISION_BASE)
	lw	a4,%lo(LOWER_SPRITE_COLLISION_BASE)(a4)
	lhu	a4,22(a4)
	andi	a4,a4,2047
	bne	a4,zero,.L449
	lui	a4,%hi(UPPER_SPRITE_COLLISION_BASE)
	lw	a4,%lo(UPPER_SPRITE_COLLISION_BASE)(a4)
	lhu	a4,22(a4)
	andi	a4,a4,2047
	bne	a4,zero,.L449
	sh	a5,%lo(resetship)(s1)
	bne	a5,zero,.L451
	call	gpu_cs
	lhu	a5,%lo(lives)(s3)
	addi	a5,a5,-1
	sh	a5,%lo(lives)(s3)
	call	draw_lives
.L451:
	lhu	a5,%lo(lives)(s3)
	bne	a5,zero,.L446
	call	risc_ice_v_logo
.L446:
	lh	a4,%lo(resetship)(s1)
	li	a5,16
	ble	a4,a5,.L449
	lui	a4,%hi(LOWER_SPRITE_NUMBER)
	lw	a5,%lo(LOWER_SPRITE_NUMBER)(a4)
	li	a2,11
	li	a3,1024
	sb	a2,0(a5)
	lui	a5,%hi(LOWER_SPRITE_UPDATE)
	lw	a5,%lo(LOWER_SPRITE_UPDATE)(a5)
	sh	a3,0(a5)
	lui	a5,%hi(UPPER_SPRITE_NUMBER)
	lw	a1,%lo(UPPER_SPRITE_NUMBER)(a5)
	sb	a2,0(a1)
	lui	a2,%hi(UPPER_SPRITE_UPDATE)
	lw	a2,%lo(UPPER_SPRITE_UPDATE)(a2)
	sh	a3,0(a2)
	lw	a2,%lo(counter)(s4)
	mv	a3,a4
	mv	a4,a5
	andi	a2,a2,1
	li	a5,48
	bne	a2,zero,.L452
	li	a5,60
.L452:
	lw	a3,%lo(LOWER_SPRITE_NUMBER)(a3)
	li	a2,11
	andi	a5,a5,0xff
	sb	a2,0(a3)
	lui	a3,%hi(LOWER_SPRITE_COLOUR)
	lw	a3,%lo(LOWER_SPRITE_COLOUR)(a3)
	sb	a5,0(a3)
	lw	a3,%lo(counter)(s4)
	li	a5,60
	andi	a3,a3,1
	bne	a3,zero,.L453
	li	a5,48
.L453:
	lw	a4,%lo(UPPER_SPRITE_NUMBER)(a4)
	li	a3,11
	andi	a5,a5,0xff
	sb	a3,0(a4)
	lui	a4,%hi(UPPER_SPRITE_COLOUR)
	lw	a4,%lo(UPPER_SPRITE_COLOUR)(a4)
	sb	a5,0(a4)
	lhu	a5,%lo(resetship)(s1)
	li	a4,16
	addi	a5,a5,-1
	slli	a5,a5,16
	srai	a5,a5,16
	sh	a5,%lo(resetship)(s1)
	bne	a5,a4,.L454
	li	a0,0
	call	set_ship_sprites
.L454:
	lui	a5,%hi(shipy)
	li	a4,232
	sh	a4,%lo(shipy)(a5)
	lui	a5,%hi(shipdirection)
	sh	s8,%lo(shipx)(s7)
	sh	zero,%lo(shipdirection)(a5)
.L449:
	lhu	a5,%lo(lives)(s3)
	bne	a5,zero,.L442
	li	a0,3
	call	bitmap_scrollwrap
	li	a0,4
	call	bitmap_scrollwrap
	j	.L442
.L395:
	call	inputcharacter
	j	.L394
.L402:
	call	rng
	slli	a5,a0,16
	srai	a5,a5,16
	li	a4,-639
	j	.L403
.L400:
	li	a0,640
	call	rng
	slli	a4,a0,16
	srai	a4,a4,16
	li	a5,-31
	j	.L403
.L401:
	li	a0,640
	call	rng
	slli	a4,a0,16
	srai	a4,a4,16
	li	a5,479
	j	.L403
.L418:
	li	a1,63
	li	a0,4
	li	a2,32
	call	beep.part.0
	lbu	a1,%lo(ufo_sprite_number)(s1)
	li	a5,9
	sltiu	a0,a1,10
	xori	a0,a0,1
	bleu	a1,a5,.L421
	addi	a1,a1,-10
	andi	a1,a1,0xff
.L421:
	li	a2,3
	call	get_sprite_attribute
	lhu	a3,%lo(level)(s5)
	slli	s2,a0,16
	li	a5,1
	srli	s2,s2,16
	li	a4,16
	bleu	a3,a5,.L422
	li	a4,8
.L422:
	lbu	a1,%lo(ufo_sprite_number)(s1)
	add	s2,s2,a4
	slli	s2,s2,16
	sltiu	a0,a1,10
	li	a5,9
	srai	s2,s2,16
	xori	a0,a0,1
	bleu	a1,a5,.L423
	addi	a1,a1,-10
	andi	a1,a1,0xff
.L423:
	li	a2,4
	call	get_sprite_attribute
	lui	a5,%hi(shipy)
	lh	a2,%lo(shipy)(a5)
	addi	a5,a0,-10
	blt	a2,a0,.L503
	lhu	a4,%lo(level)(s5)
	li	a5,1
	li	a3,20
	bleu	a4,a5,.L426
	li	a3,10
.L426:
	add	a5,a3,a0
.L503:
	lh	a4,%lo(shipx)(s7)
	slli	a5,a5,16
	srai	a5,a5,16
	lui	a3,%hi(ufo_bullet_direction)
	bge	a4,s2,.L427
	li	a4,1
	blt	a2,a5,.L428
	li	a4,255
.L428:
	addi	a4,a4,6
	j	.L504
.L427:
	li	a4,255
	blt	a2,a5,.L430
	li	a4,1
.L430:
	addi	a4,a4,2
.L504:
	sb	a4,%lo(ufo_bullet_direction)(a3)
	li	a7,0
	li	a6,0
	mv	a4,s2
	li	a3,48
	li	a2,1
	li	a1,10
	li	a0,0
	sw	a5,12(sp)
	call	set_sprite
	lw	a5,12(sp)
	li	a7,0
	li	a6,1
	mv	a4,s2
	li	a3,60
	li	a2,1
	li	a1,10
	li	a0,1
	call	set_sprite
.L416:
	lhu	a5,%lo(lives)(s3)
	bne	a5,zero,.L432
	lui	a5,%hi(BUTTONS)
	lw	a5,%lo(BUTTONS)(a5)
	lbu	a5,0(a5)
	andi	a5,a5,8
	beq	a5,zero,.L420
	li	s0,0
	li	s10,9
	li	s2,20
.L444:
	add	a5,s6,s0
	sb	zero,0(a5)
	add	a5,s9,s0
	sb	zero,0(a5)
	slli	a5,s0,16
	srli	a5,a5,16
	sltiu	a0,a5,10
	xori	a0,a0,1
	andi	a1,s0,0xff
	bleu	a5,s10,.L443
	addi	a1,a1,-10
	andi	a1,a1,0xff
.L443:
	li	a3,0
	li	a2,0
	addi	s0,s0,1
	call	set_sprite_attribute
	bne	s0,s2,.L444
	lui	a4,%hi(LOWER_SPRITE_NUMBER)
	lw	a3,%lo(LOWER_SPRITE_NUMBER)(a4)
	li	a5,10
	lui	a2,%hi(LOWER_SPRITE_ACTIVE)
	sb	a5,0(a3)
	lw	a3,%lo(LOWER_SPRITE_ACTIVE)(a2)
	li	s0,4
	sb	zero,0(a3)
	lui	a3,%hi(UPPER_SPRITE_NUMBER)
	lw	a1,%lo(UPPER_SPRITE_NUMBER)(a3)
	sb	a5,0(a1)
	lui	a5,%hi(UPPER_SPRITE_ACTIVE)
	lw	a1,%lo(UPPER_SPRITE_ACTIVE)(a5)
	sb	zero,0(a1)
	lw	a1,%lo(LOWER_SPRITE_NUMBER)(a4)
	li	a4,12
	sb	a4,0(a1)
	lw	a2,%lo(LOWER_SPRITE_ACTIVE)(a2)
	sb	zero,0(a2)
	lw	a3,%lo(UPPER_SPRITE_NUMBER)(a3)
	sb	a4,0(a3)
	lw	a5,%lo(UPPER_SPRITE_ACTIVE)(a5)
	sb	zero,0(a5)
	call	gpu_cs
	call	tpu_cs
	li	a5,3
	sh	a5,%lo(lives)(s3)
	lui	a5,%hi(score)
	li	a4,232
	sh	zero,%lo(score)(a5)
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
	lui	a5,%hi(shipdirection)
	sh	zero,%lo(shipdirection)(a5)
	lui	a5,%hi(resetship)
	sh	zero,%lo(resetship)(a5)
	lui	a5,%hi(bulletdirection)
	sh	zero,%lo(bulletdirection)(a5)
	li	a5,-1
	sb	a5,%lo(ufo_sprite_number)(s1)
	lui	a5,%hi(ufo_leftright)
	sb	zero,%lo(ufo_leftright)(a5)
	sw	zero,%lo(counter)(s4)
	sh	zero,%lo(level)(s5)
	sh	s8,%lo(shipx)(s7)
	call	draw_lives
	call	set_asteroid_sprites
	li	a0,0
	call	set_ship_sprites
	call	set_bullet_sprites
	call	set_ufo_bullet_sprites
	j	.L420
.L419:
	lw	a5,%lo(counter)(s4)
	lui	s1,%hi(BUTTONS)
	andi	a5,a5,3
	bne	a5,zero,.L435
	lw	a4,%lo(BUTTONS)(s1)
	lbu	a5,0(a4)
	andi	a5,a5,32
	beq	a5,zero,.L436
	lui	a5,%hi(shipdirection)
	lh	a3,%lo(shipdirection)(a5)
	li	a1,7
	beq	a3,zero,.L437
	addi	a3,a3,-1
	slli	a1,a3,16
	srai	a1,a1,16
.L437:
	sh	a1,%lo(shipdirection)(a5)
.L436:
	lbu	a5,0(a4)
	andi	a5,a5,64
	beq	a5,zero,.L435
	lui	a5,%hi(shipdirection)
	lh	a4,%lo(shipdirection)(a5)
	li	a3,7
	beq	a4,a3,.L439
	addi	a4,a4,1
	slli	a2,a4,16
	srai	a2,a2,16
.L439:
	sh	a2,%lo(shipdirection)(a5)
.L435:
	lui	a5,%hi(LOWER_SPRITE_NUMBER)
	lw	a5,%lo(LOWER_SPRITE_NUMBER)(a5)
	li	a4,12
	sb	a4,0(a5)
	lui	a5,%hi(LOWER_SPRITE_ACTIVE)
	lw	a5,%lo(LOWER_SPRITE_ACTIVE)(a5)
	lbu	a5,0(a5)
	andi	a5,a5,0xff
	bne	a5,zero,.L440
	lw	a5,%lo(BUTTONS)(s1)
	lbu	a5,0(a5)
	andi	a5,a5,2
	beq	a5,zero,.L440
	call	fire_bullet
.L440:
	lw	a5,%lo(BUTTONS)(s1)
	lbu	a5,0(a5)
	andi	a5,a5,4
	beq	a5,zero,.L441
	call	move_ship
.L441:
	li	a0,63
	call	draw_ship
	call	check_crash
.L442:
	call	update_bullet
	call	check_hit
	call	check_ufo_bullet_hit
	call	move_asteroids
	call	wait_timer1khz
	j	.L455
	.size	main, .-main
	.globl	tilemap_bitmap
	.globl	bullet_bitmap
	.globl	ship_bitmap
	.globl	ufo_bullet_bitmap
	.globl	ufo_bitmap
	.globl	asteroid_bitmap
	.globl	ufo_directions
	.globl	asteroid_directions
	.globl	bullet_directions
	.globl	last_timer
	.globl	ufo_bullet_direction
	.globl	ufo_leftright
	.globl	ufo_sprite_number
	.globl	asteroid_direction
	.globl	asteroid_active
	.globl	bulletdirection
	.globl	resetship
	.globl	shipdirection
	.globl	shipy
	.globl	shipx
	.globl	counter
	.globl	level
	.globl	score
	.globl	lives
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
	.size	bullet_bitmap, 256
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
	.type	ufo_bitmap, @object
	.size	ufo_bitmap, 256
ufo_bitmap:
	.half	0
	.half	0
	.half	960
	.half	960
	.half	1952
	.half	4080
	.half	16380
	.half	32766
	.half	-13
	.half	16380
	.half	8184
	.half	4080
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	960
	.half	960
	.half	1888
	.half	4080
	.half	16380
	.half	32766
	.half	-49
	.half	16380
	.half	8184
	.half	4080
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	960
	.half	960
	.half	1760
	.half	4080
	.half	16380
	.half	32766
	.half	-193
	.half	16380
	.half	8184
	.half	4080
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	960
	.half	960
	.half	1520
	.half	4080
	.half	16380
	.half	32766
	.half	-769
	.half	16380
	.half	8184
	.half	4080
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	960
	.half	960
	.half	1952
	.half	4080
	.half	16380
	.half	32766
	.half	-3073
	.half	16380
	.half	8184
	.half	4080
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	960
	.half	960
	.half	1888
	.half	4080
	.half	16380
	.half	32766
	.half	-12289
	.half	16380
	.half	8184
	.half	4080
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	960
	.half	960
	.half	1760
	.half	4080
	.half	16380
	.half	32766
	.half	-1
	.half	16380
	.half	8184
	.half	4080
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	960
	.half	960
	.half	1520
	.half	4080
	.half	16380
	.half	32766
	.half	-1
	.half	16380
	.half	8184
	.half	4080
	.half	0
	.half	0
	.half	0
	.half	0
	.type	ufo_bullet_bitmap, @object
	.size	ufo_bullet_bitmap, 256
ufo_bullet_bitmap:
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	128
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
	.half	0
	.half	0
	.half	0
	.half	256
	.half	128
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
	.half	128
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
	.half	0
	.half	0
	.half	0
	.half	256
	.half	128
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
	.half	128
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
	.half	0
	.half	0
	.half	0
	.half	256
	.half	128
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
	.half	128
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
	.half	0
	.half	0
	.half	0
	.half	256
	.half	128
	.half	0
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
	.half	993
	.half	33
	.half	63
	.half	1023
	.half	961
	.half	994
	.half	34
	.half	65
	.half	95
	.half	62
	.half	1022
	.half	991
	.type	bullet_directions, @object
	.size	bullet_directions, 16
bullet_directions:
	.half	8000
	.half	8037
	.half	7174
	.half	7333
	.half	7360
	.half	7355
	.half	7194
	.half	8059
	.bss
	.align	2
	.set	.LANCHOR1,. + 0
	.type	asteroid_active, @object
	.size	asteroid_active, 20
asteroid_active:
	.zero	20
	.type	asteroid_direction, @object
	.size	asteroid_direction, 20
asteroid_direction:
	.zero	20
	.section	.sbss,"aw",@nobits
	.align	2
	.type	last_timer, @object
	.size	last_timer, 2
last_timer:
	.zero	2
	.type	ufo_bullet_direction, @object
	.size	ufo_bullet_direction, 1
ufo_bullet_direction:
	.zero	1
	.type	ufo_leftright, @object
	.size	ufo_leftright, 1
ufo_leftright:
	.zero	1
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
	.zero	2
	.type	counter, @object
	.size	counter, 4
counter:
	.zero	4
	.type	level, @object
	.size	level, 2
level:
	.zero	2
	.type	score, @object
	.size	score, 2
score:
	.zero	2
	.type	lives, @object
	.size	lives, 2
lives:
	.zero	2
	.section	.sdata,"aw"
	.align	2
	.type	ufo_directions, @object
	.size	ufo_directions, 8
ufo_directions:
	.half	7170
	.half	7198
	.half	7172
	.half	7196
	.type	ufo_sprite_number, @object
	.size	ufo_sprite_number, 1
ufo_sprite_number:
	.byte	-1
	.zero	1
	.type	shipy, @object
	.size	shipy, 2
shipy:
	.half	232
	.type	shipx, @object
	.size	shipx, 2
shipx:
	.half	312
	.zero	2
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
