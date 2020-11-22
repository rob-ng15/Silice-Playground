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
.L7:
	lhu	a5,0(a4)
	slli	a5,a5,16
	srai	a5,a5,16
	bne	a5,zero,.L7
	ret
	.size	wait_timer1khz, .-wait_timer1khz
	.align	2
	.globl	beep
	.type	beep, @function
beep:
	andi	a5,a0,1
	beq	a5,zero,.L10
	lui	a5,%hi(AUDIO_L_WAVEFORM)
	lw	a5,%lo(AUDIO_L_WAVEFORM)(a5)
	sb	a2,0(a5)
	lui	a5,%hi(AUDIO_L_NOTE)
	lw	a5,%lo(AUDIO_L_NOTE)(a5)
	sb	a3,0(a5)
	lui	a5,%hi(AUDIO_L_DURATION)
	lw	a5,%lo(AUDIO_L_DURATION)(a5)
	sh	a4,0(a5)
	lui	a5,%hi(AUDIO_L_START)
	lw	a6,%lo(AUDIO_L_START)(a5)
	addi	a5,a1,1
	andi	a5,a5,0xff
	sb	a5,0(a6)
.L10:
	andi	a0,a0,2
	beq	a0,zero,.L9
	lui	a5,%hi(AUDIO_R_WAVEFORM)
	lw	a5,%lo(AUDIO_R_WAVEFORM)(a5)
	sb	a2,0(a5)
	lui	a5,%hi(AUDIO_R_NOTE)
	lw	a5,%lo(AUDIO_R_NOTE)(a5)
	sb	a3,0(a5)
	lui	a5,%hi(AUDIO_R_DURATION)
	lw	a5,%lo(AUDIO_R_DURATION)(a5)
	sh	a4,0(a5)
	lui	a5,%hi(AUDIO_R_START)
	lw	a5,%lo(AUDIO_R_START)(a5)
	addi	a1,a1,1
	andi	a1,a1,0xff
	sb	a1,0(a5)
.L9:
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
.L15:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	beq	a5,zero,.L15
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
.L20:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L20
	lui	a5,%hi(TM_SCROLLWRAPCLEAR)
	lw	a5,%lo(TM_SCROLLWRAPCLEAR)(a5)
	sb	a0,0(a5)
	ret
	.size	tilemap_scrollwrapclear, .-tilemap_scrollwrapclear
	.align	2
	.globl	wait_gpu
	.type	wait_gpu, @function
wait_gpu:
	lui	a5,%hi(GPU_STATUS)
	lw	a4,%lo(GPU_STATUS)(a5)
.L23:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L23
	ret
	.size	wait_gpu, .-wait_gpu
	.align	2
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
	.align	2
	.globl	gpu_rectangle
	.type	gpu_rectangle, @function
gpu_rectangle:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	mv	s4,a0
	mv	s3,a1
	mv	s2,a2
	mv	s1,a3
	mv	s0,a4
	call	wait_gpu
	lui	a5,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a5)
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
	li	a4,2
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
	.align	2
	.globl	gpu_cs
	.type	gpu_cs, @function
gpu_cs:
	addi	sp,sp,-16
	sw	ra,12(sp)
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
	.align	2
	.globl	gpu_line
	.type	gpu_line, @function
gpu_line:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	mv	s4,a0
	mv	s3,a1
	mv	s2,a2
	mv	s1,a3
	mv	s0,a4
	call	wait_gpu
	lui	a5,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a5)
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
	li	a4,3
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
	.align	2
	.globl	gpu_circle
	.type	gpu_circle, @function
gpu_circle:
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
	call	wait_gpu
	lui	a5,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a5)
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
	li	a4,4
	sb	a4,0(a5)
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	addi	sp,sp,32
	jr	ra
	.size	gpu_circle, .-gpu_circle
	.align	2
	.globl	gpu_fillcircle
	.type	gpu_fillcircle, @function
gpu_fillcircle:
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
	call	wait_gpu
	lui	a5,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a5)
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
	li	a4,6
	sb	a4,0(a5)
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	addi	sp,sp,32
	jr	ra
	.size	gpu_fillcircle, .-gpu_fillcircle
	.align	2
	.globl	gpu_triangle
	.type	gpu_triangle, @function
gpu_triangle:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	sw	s5,4(sp)
	sw	s6,0(sp)
	mv	s6,a0
	mv	s5,a1
	mv	s4,a2
	mv	s3,a3
	mv	s2,a4
	mv	s1,a5
	mv	s0,a6
	call	wait_gpu
	lui	a5,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a5)
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
	li	a4,7
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
	.align	2
	.globl	draw_vector_block
	.type	draw_vector_block, @function
draw_vector_block:
	lui	a5,%hi(VECTOR_DRAW_START)
	lw	a4,%lo(VECTOR_DRAW_START)(a5)
.L40:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L40
	lui	a5,%hi(VECTOR_DRAW_BLOCK)
	lw	a5,%lo(VECTOR_DRAW_BLOCK)(a5)
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
	li	a4,1
	sb	a4,0(a5)
	ret
	.size	draw_vector_block, .-draw_vector_block
	.align	2
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
	lui	a5,%hi(VECTOR_WRITER_COMMIT)
	lw	a5,%lo(VECTOR_WRITER_COMMIT)(a5)
	li	a4,1
	sb	a4,0(a5)
	ret
	.size	set_vector_vertex, .-set_vector_vertex
	.align	2
	.globl	set_sprite
	.type	set_sprite, @function
set_sprite:
	beq	a0,zero,.L44
	li	t1,1
	beq	a0,t1,.L45
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
	lw	a3,%lo(LOWER_SPRITE_X)(a3)
	sh	a4,0(a3)
	lui	a4,%hi(LOWER_SPRITE_Y)
	lw	a4,%lo(LOWER_SPRITE_Y)(a4)
	sh	a5,0(a4)
	lui	a5,%hi(LOWER_SPRITE_DOUBLE)
	lw	a5,%lo(LOWER_SPRITE_DOUBLE)(a5)
	sb	a7,0(a5)
	ret
.L45:
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
	.align	2
	.globl	get_sprite_attribute
	.type	get_sprite_attribute, @function
get_sprite_attribute:
	bne	a0,zero,.L48
	lui	a5,%hi(LOWER_SPRITE_NUMBER)
	lw	a5,%lo(LOWER_SPRITE_NUMBER)(a5)
	sb	a1,0(a5)
	li	a5,5
	bgtu	a2,a5,.L49
	slli	a2,a2,2
	lui	a5,%hi(.L51)
	addi	a5,a5,%lo(.L51)
	add	a2,a2,a5
	lw	a5,0(a2)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L51:
	.word	.L56
	.word	.L55
	.word	.L54
	.word	.L53
	.word	.L52
	.word	.L50
	.text
.L56:
	lui	a5,%hi(LOWER_SPRITE_ACTIVE)
	lw	a5,%lo(LOWER_SPRITE_ACTIVE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L55:
	lui	a5,%hi(LOWER_SPRITE_TILE)
	lw	a5,%lo(LOWER_SPRITE_TILE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L54:
	lui	a5,%hi(LOWER_SPRITE_COLOUR)
	lw	a5,%lo(LOWER_SPRITE_COLOUR)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L53:
	lui	a5,%hi(LOWER_SPRITE_X)
	lw	a5,%lo(LOWER_SPRITE_X)(a5)
	lhu	a0,0(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
.L52:
	lui	a5,%hi(LOWER_SPRITE_Y)
	lw	a5,%lo(LOWER_SPRITE_Y)(a5)
	lhu	a0,0(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
.L50:
	lui	a5,%hi(LOWER_SPRITE_DOUBLE)
	lw	a5,%lo(LOWER_SPRITE_DOUBLE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L48:
	lui	a5,%hi(UPPER_SPRITE_NUMBER)
	lw	a5,%lo(UPPER_SPRITE_NUMBER)(a5)
	sb	a1,0(a5)
	li	a5,5
	bgtu	a2,a5,.L49
	slli	a2,a2,2
	lui	a5,%hi(.L59)
	addi	a5,a5,%lo(.L59)
	add	a2,a2,a5
	lw	a5,0(a2)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L59:
	.word	.L64
	.word	.L63
	.word	.L62
	.word	.L61
	.word	.L60
	.word	.L58
	.text
.L64:
	lui	a5,%hi(UPPER_SPRITE_ACTIVE)
	lw	a5,%lo(UPPER_SPRITE_ACTIVE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L63:
	lui	a5,%hi(UPPER_SPRITE_TILE)
	lw	a5,%lo(UPPER_SPRITE_TILE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L62:
	lui	a5,%hi(UPPER_SPRITE_COLOUR)
	lw	a5,%lo(UPPER_SPRITE_COLOUR)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L61:
	lui	a5,%hi(UPPER_SPRITE_X)
	lw	a5,%lo(UPPER_SPRITE_X)(a5)
	lhu	a0,0(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
.L60:
	lui	a5,%hi(UPPER_SPRITE_Y)
	lw	a5,%lo(UPPER_SPRITE_Y)(a5)
	lhu	a0,0(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
.L58:
	lui	a5,%hi(UPPER_SPRITE_DOUBLE)
	lw	a5,%lo(UPPER_SPRITE_DOUBLE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L49:
	ret
	.size	get_sprite_attribute, .-get_sprite_attribute
	.align	2
	.globl	update_sprite
	.type	update_sprite, @function
update_sprite:
	beq	a0,zero,.L66
	li	a5,1
	beq	a0,a5,.L67
	ret
.L66:
	lui	a5,%hi(LOWER_SPRITE_NUMBER)
	lw	a5,%lo(LOWER_SPRITE_NUMBER)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(LOWER_SPRITE_UPDATE)
	lw	a5,%lo(LOWER_SPRITE_UPDATE)(a5)
	andi	a2,a2,0xff
	sb	a2,0(a5)
	ret
.L67:
	lui	a5,%hi(UPPER_SPRITE_NUMBER)
	lw	a5,%lo(UPPER_SPRITE_NUMBER)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(UPPER_SPRITE_UPDATE)
	lw	a5,%lo(UPPER_SPRITE_UPDATE)(a5)
	andi	a2,a2,0xff
	sb	a2,0(a5)
	ret
	.size	update_sprite, .-update_sprite
	.align	2
	.globl	set_sprite_line
	.type	set_sprite_line, @function
set_sprite_line:
	beq	a0,zero,.L70
	li	a5,1
	beq	a0,a5,.L71
	ret
.L70:
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
.L71:
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
	.size	set_sprite_line, .-set_sprite_line
	.align	2
	.globl	set_asteroid_sprites
	.type	set_asteroid_sprites, @function
set_asteroid_sprites:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	sw	s1,36(sp)
	sw	s2,32(sp)
	sw	s3,28(sp)
	sw	s4,24(sp)
	sw	s5,20(sp)
	sw	s6,16(sp)
	sw	s7,12(sp)
	li	s5,0
	lui	s7,%hi(.LANCHOR0)
	li	s3,0
	li	s4,128
	li	s6,12
.L74:
	addi	s1,s7,%lo(.LANCHOR0)
	mv	s0,s3
	andi	s2,s5,0xff
.L75:
	lhu	a3,0(s1)
	mv	a2,s0
	mv	a1,s2
	mv	a0,s3
	call	set_sprite_line
	lhu	a3,0(s1)
	mv	a2,s0
	mv	a1,s2
	li	a0,1
	call	set_sprite_line
	addi	s0,s0,1
	andi	s0,s0,0xff
	addi	s1,s1,2
	bne	s0,s4,.L75
	addi	s5,s5,1
	slli	s5,s5,16
	srai	s5,s5,16
	bne	s5,s6,.L74
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
	.size	set_asteroid_sprites, .-set_asteroid_sprites
	.align	2
	.globl	set_ship_sprites
	.type	set_ship_sprites, @function
set_ship_sprites:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s1,4(sp)
	sw	s2,0(sp)
	lui	a5,%hi(.LANCHOR0+256)
	snez	s1,a0
	slli	s1,s1,8
	addi	a5,a5,%lo(.LANCHOR0+256)
	add	s1,a5,s1
	li	s0,0
	li	s2,128
.L82:
	lhu	a3,0(s1)
	mv	a2,s0
	li	a1,11
	li	a0,0
	call	set_sprite_line
	lhu	a3,0(s1)
	mv	a2,s0
	li	a1,11
	li	a0,1
	call	set_sprite_line
	addi	s0,s0,1
	andi	s0,s0,0xff
	addi	s1,s1,2
	bne	s0,s2,.L82
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	lw	s2,0(sp)
	addi	sp,sp,16
	jr	ra
	.size	set_ship_sprites, .-set_ship_sprites
	.align	2
	.globl	set_ship_vector
	.type	set_ship_vector, @function
set_ship_vector:
	addi	sp,sp,-16
	sw	ra,12(sp)
	li	a4,0
	li	a3,0
	li	a2,1
	li	a1,0
	li	a0,0
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
	li	a4,0
	li	a3,0
	li	a2,0
	li	a1,5
	li	a0,0
	call	set_vector_vertex
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	set_ship_vector, .-set_ship_vector
	.align	2
	.globl	set_bullet_sprites
	.type	set_bullet_sprites, @function
set_bullet_sprites:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s1,4(sp)
	sw	s2,0(sp)
	lui	s1,%hi(.LANCHOR0+768)
	addi	s1,s1,%lo(.LANCHOR0+768)
	li	s0,0
	li	s2,64
.L88:
	lhu	a3,0(s1)
	mv	a2,s0
	li	a1,12
	li	a0,0
	call	set_sprite_line
	lhu	a3,128(s1)
	mv	a2,s0
	li	a1,12
	li	a0,0
	call	set_sprite_line
	lhu	a3,0(s1)
	mv	a2,s0
	li	a1,12
	li	a0,1
	call	set_sprite_line
	lhu	a3,128(s1)
	mv	a2,s0
	li	a1,12
	li	a0,1
	call	set_sprite_line
	addi	s0,s0,1
	andi	s0,s0,0xff
	addi	s1,s1,2
	bne	s0,s2,.L88
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	lw	s2,0(sp)
	addi	sp,sp,16
	jr	ra
	.size	set_bullet_sprites, .-set_bullet_sprites
	.align	2
	.globl	set_tilemap
	.type	set_tilemap, @function
set_tilemap:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	sw	s5,4(sp)
	sw	s6,0(sp)
	li	a0,9
	call	tilemap_scrollwrapclear
	lui	s4,%hi(.LANCHOR0+896)
	addi	s4,s4,%lo(.LANCHOR0+896)
	li	s2,1
	li	s6,0
	li	s3,16
	li	s5,9
.L92:
	mv	s1,s4
	mv	s0,s6
.L93:
	lhu	a2,0(s1)
	mv	a1,s0
	mv	a0,s2
	call	set_tilemap_line
	addi	s0,s0,1
	andi	s0,s0,0xff
	addi	s1,s1,2
	bne	s0,s3,.L93
	addi	s2,s2,1
	andi	s2,s2,0xff
	addi	s4,s4,32
	bne	s2,s5,.L92
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
	li	a4,16
	li	a3,64
	li	a2,8
	li	a1,27
	li	a0,7
	call	set_tilemap_tile
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
	.size	set_tilemap, .-set_tilemap
	.align	2
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
	li	a4,100
	li	a3,8
	li	a2,37
	li	a1,0
	li	a0,2
	call	gpu_rectangle
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	risc_ice_v_logo, .-risc_ice_v_logo
	.align	2
	.globl	setup_game
	.type	setup_game, @function
setup_game:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	sw	s5,4(sp)
	sw	s6,0(sp)
	lui	s2,%hi(.LANCHOR1)
	addi	s2,s2,%lo(.LANCHOR1)
	addi	s3,s2,24
	li	s0,1
	li	s1,0
	li	s4,21
	li	s6,25
	li	s5,12
	j	.L104
.L100:
	sltiu	a0,a1,13
	xori	a0,a0,1
.L101:
	addi	a1,a1,-13
	li	a7,0
	li	a6,0
	li	a5,0
	li	a4,0
	li	a3,0
	li	a2,0
	andi	a1,a1,0xff
	call	set_sprite
	bgtu	s0,s6,.L103
.L105:
	addi	s1,s1,1
	addi	s0,s0,1
	andi	s0,s0,0xff
	addi	s2,s2,1
	addi	s3,s3,1
.L104:
	andi	a1,s1,0xff
	bgtu	a1,s4,.L100
	sb	zero,0(s2)
	sb	zero,0(s3)
	sltiu	a0,a1,13
	xori	a0,a0,1
	bgtu	a1,s5,.L101
	li	a7,0
	li	a6,0
	li	a5,0
	li	a4,0
	li	a3,0
	li	a2,0
	li	a0,0
	call	set_sprite
	j	.L105
.L103:
	call	gpu_cs
	lui	a5,%hi(TERMINAL_SHOWHIDE)
	lw	a5,%lo(TERMINAL_SHOWHIDE)(a5)
	sb	zero,0(a5)
	li	a2,7
	li	a1,1
	li	a0,42
	call	set_background
	call	risc_ice_v_logo
	li	a0,9
	call	tilemap_scrollwrapclear
	call	set_tilemap
	call	set_asteroid_sprites
	li	a0,0
	call	set_ship_sprites
	call	set_ship_vector
	lui	a5,%hi(lives)
	sw	zero,%lo(lives)(a5)
	lui	a5,%hi(score)
	sw	zero,%lo(score)(a5)
	lui	a5,%hi(shipx)
	li	a4,312
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	li	a4,232
	sh	a4,%lo(shipy)(a5)
	lui	a5,%hi(shipdirection)
	sh	zero,%lo(shipdirection)(a5)
	lui	a5,%hi(resetship)
	sh	zero,%lo(resetship)(a5)
	lui	a5,%hi(bulletdirection)
	sh	zero,%lo(bulletdirection)(a5)
	lui	a5,%hi(counter)
	sw	zero,%lo(counter)(a5)
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
	.size	setup_game, .-setup_game
	.align	2
	.globl	find_asteroid_space
	.type	find_asteroid_space, @function
find_asteroid_space:
	lui	a4,%hi(.LANCHOR1)
	addi	a4,a4,%lo(.LANCHOR1)
	li	a5,0
	li	a0,255
	li	a2,22
	j	.L111
.L110:
	addi	a5,a5,1
	andi	a5,a5,0xff
	addi	a4,a4,1
	beq	a5,a2,.L114
.L111:
	lbu	a3,0(a4)
	bne	a3,zero,.L110
	mv	a0,a5
	j	.L110
.L114:
	ret
	.size	find_asteroid_space, .-find_asteroid_space
	.align	2
	.globl	new_asteroid
	.type	new_asteroid, @function
new_asteroid:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	mv	s0,a0
	call	find_asteroid_space
	li	a5,255
	beq	a0,a5,.L115
	mv	a1,a0
	lui	a5,%hi(RNG)
	lw	a2,%lo(RNG)(a5)
	lui	a5,%hi(shipx)
	lh	a6,%lo(shipx)(a5)
	addi	t3,a6,-64
	addi	a6,a6,64
	lui	a5,%hi(shipy)
	lh	a0,%lo(shipy)(a5)
	addi	t4,a0,-64
	addi	a0,a0,64
	li	t1,640
	li	a7,480
.L118:
	lhu	a4,0(a2)
	slli	a4,a4,16
	srai	a4,a4,16
	rem	a4,a4,t1
	lhu	a5,0(a2)
	slli	a5,a5,16
	srai	a5,a5,16
	rem	a5,a5,a7
	andi	a3,a4,255
	bgt	t3,a3,.L117
	blt	a6,a3,.L117
	andi	a3,a5,255
	bgt	t4,a3,.L117
	bge	a0,a3,.L118
.L117:
	mv	a7,a1
	lui	a0,%hi(.LANCHOR1)
	addi	a0,a0,%lo(.LANCHOR1)
	add	a0,a0,a1
	sb	s0,0(a0)
	li	a3,2
	li	a6,4
	beq	s0,a3,.L119
	li	a6,8
.L119:
	lhu	a0,0(a2)
	slli	a0,a0,16
	srai	a0,a0,16
	lui	a3,%hi(.LANCHOR1)
	addi	a3,a3,%lo(.LANCHOR1)
	add	a3,a3,a7
	rem	a0,a0,a6
	sb	a0,24(a3)
	sltiu	a0,a1,11
	xori	a0,a0,1
	li	a3,10
	bleu	a1,a3,.L120
	addi	a1,a1,-11
	andi	a1,a1,0xff
.L120:
	lhu	a3,0(a2)
	slli	a3,a3,16
	srai	a3,a3,16
	lhu	a6,0(a2)
	slli	a6,a6,16
	srai	a6,a6,16
	addi	a7,s0,-2
	li	a2,7
	rem	a6,a6,a2
	srai	a2,a3,31
	srli	a2,a2,27
	add	a3,a3,a2
	andi	a3,a3,31
	sub	a3,a3,a2
	addi	a3,a3,32
	seqz	a7,a7
	andi	a6,a6,0xff
	andi	a5,a5,0xff
	andi	a4,a4,0xff
	andi	a3,a3,0xff
	li	a2,1
	call	set_sprite
.L115:
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	new_asteroid, .-new_asteroid
	.align	2
	.globl	new_level
	.type	new_level, @function
new_level:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	lui	s1,%hi(.LANCHOR1)
	addi	s1,s1,%lo(.LANCHOR1)
	addi	s2,s1,24
	li	s0,0
	li	s3,22
.L125:
	sb	zero,0(s1)
	sb	zero,0(s2)
	li	a7,0
	li	a6,0
	li	a5,0
	li	a4,0
	li	a3,0
	li	a2,0
	mv	a1,s0
	li	a0,0
	call	set_sprite
	li	a7,0
	li	a6,0
	li	a5,0
	li	a4,0
	li	a3,0
	li	a2,0
	mv	a1,s0
	li	a0,1
	call	set_sprite
	addi	s0,s0,1
	andi	s0,s0,0xff
	addi	s1,s1,1
	addi	s2,s2,1
	bne	s0,s3,.L125
	lui	a5,%hi(RNG)
	lw	a5,%lo(RNG)(a5)
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
	li	s0,0
.L126:
	li	a0,2
	call	new_asteroid
	addi	s0,s0,1
	andi	s0,s0,0xff
	bgtu	s1,s0,.L126
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	addi	sp,sp,32
	jr	ra
	.size	new_level, .-new_level
	.align	2
	.globl	move_asteroids
	.type	move_asteroids, @function
move_asteroids:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	sw	s5,4(sp)
	lui	s1,%hi(.LANCHOR1)
	addi	s1,s1,%lo(.LANCHOR1)
	addi	s2,s1,24
	li	s0,0
	li	s5,10
	lui	s4,%hi(.LANCHOR0)
	addi	s4,s4,%lo(.LANCHOR0)
	li	s3,22
	j	.L133
.L132:
	lbu	a5,0(s2)
	slli	a5,a5,1
	add	a5,s4,a5
	lh	a2,1152(a5)
	call	update_sprite
.L131:
	addi	s0,s0,1
	andi	s0,s0,0xff
	addi	s1,s1,1
	addi	s2,s2,1
	beq	s0,s3,.L137
.L133:
	lbu	a5,0(s1)
	beq	a5,zero,.L131
	sltiu	a0,s0,11
	xori	a0,a0,1
	mv	a1,s0
	bleu	s0,s5,.L132
	addi	a1,s0,-11
	andi	a1,a1,0xff
	j	.L132
.L137:
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	lw	s4,8(sp)
	lw	s5,4(sp)
	addi	sp,sp,32
	jr	ra
	.size	move_asteroids, .-move_asteroids
	.align	2
	.globl	count_asteroids
	.type	count_asteroids, @function
count_asteroids:
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	addi	a3,a5,22
	li	a0,0
	j	.L140
.L139:
	addi	a5,a5,1
	beq	a5,a3,.L142
.L140:
	lbu	a4,0(a5)
	beq	a4,zero,.L139
	addi	a0,a0,1
	slli	a0,a0,16
	srai	a0,a0,16
	j	.L139
.L142:
	slli	a0,a0,16
	srli	a0,a0,16
	ret
	.size	count_asteroids, .-count_asteroids
	.align	2
	.globl	draw_ship
	.type	draw_ship, @function
draw_ship:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	mv	s0,a0
	lui	s3,%hi(shipdirection)
	lui	s2,%hi(shipy)
	lui	s1,%hi(shipx)
	li	a7,0
	lbu	a6,%lo(shipdirection)(s3)
	lh	a5,%lo(shipy)(s2)
	lh	a4,%lo(shipx)(s1)
	mv	a3,a0
	li	a2,1
	li	a1,11
	li	a0,0
	call	set_sprite
	li	a7,0
	lbu	a6,%lo(shipdirection)(s3)
	lh	a5,%lo(shipy)(s2)
	lh	a4,%lo(shipx)(s1)
	mv	a3,s0
	li	a2,1
	li	a1,11
	li	a0,1
	call	set_sprite
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	addi	sp,sp,32
	jr	ra
	.size	draw_ship, .-draw_ship
	.align	2
	.globl	move_ship
	.type	move_ship, @function
move_ship:
	lui	a5,%hi(shipdirection)
	lhu	a3,%lo(shipdirection)(a5)
	li	a4,7
	bgtu	a3,a4,.L145
	slli	a5,a3,2
	lui	a4,%hi(.L148)
	addi	a4,a4,%lo(.L148)
	add	a5,a5,a4
	lw	a5,0(a5)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L148:
	.word	.L155
	.word	.L154
	.word	.L153
	.word	.L152
	.word	.L151
	.word	.L150
	.word	.L149
	.word	.L147
	.text
.L155:
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a4,464
	ble	a5,zero,.L156
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L156:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
	ret
.L154:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a3,623
	li	a4,0
	bgt	a5,a3,.L157
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L157:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a4,464
	ble	a5,zero,.L158
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L158:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
	ret
.L153:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a3,623
	li	a4,0
	bgt	a5,a3,.L159
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L159:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	ret
.L152:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a3,623
	li	a4,0
	bgt	a5,a3,.L160
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L160:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a3,463
	li	a4,0
	bgt	a5,a3,.L161
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L161:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
	ret
.L151:
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a3,463
	li	a4,0
	bgt	a5,a3,.L162
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L162:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
	ret
.L150:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a4,624
	ble	a5,zero,.L163
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L163:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a3,463
	li	a4,0
	bgt	a5,a3,.L164
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L164:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
	ret
.L149:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a4,624
	ble	a5,zero,.L165
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L165:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	ret
.L147:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a4,624
	ble	a5,zero,.L166
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L166:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a4,464
	ble	a5,zero,.L167
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L167:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
.L145:
	ret
	.size	move_ship, .-move_ship
	.align	2
	.globl	draw_lives
	.type	draw_lives, @function
draw_lives:
	addi	sp,sp,-16
	sw	ra,12(sp)
	lui	a5,%hi(lives)
	lw	a5,%lo(lives)(a5)
	li	a4,2
	beq	a5,a4,.L181
	li	a4,3
	beq	a5,a4,.L182
	li	a4,1
	bne	a5,a4,.L180
	j	.L183
.L182:
	li	a3,464
	li	a2,608
	li	a1,63
	li	a0,0
	call	draw_vector_block
.L181:
	li	a3,464
	li	a2,576
	li	a1,63
	li	a0,0
	call	draw_vector_block
.L183:
	li	a3,464
	li	a2,544
	li	a1,63
	li	a0,0
	call	draw_vector_block
.L180:
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	draw_lives, .-draw_lives
	.align	2
	.globl	fire_bullet
	.type	fire_bullet, @function
fire_bullet:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s1,4(sp)
	li	s0,0
	li	s1,0
	lui	a5,%hi(shipdirection)
	lh	a3,%lo(shipdirection)(a5)
	lui	a5,%hi(bulletdirection)
	sh	a3,%lo(bulletdirection)(a5)
	slli	a4,a3,16
	srli	a4,a4,16
	li	a5,7
	bgtu	a4,a5,.L187
	slli	a3,a3,2
	lui	a5,%hi(.L189)
	addi	a5,a5,%lo(.L189)
	add	a3,a3,a5
	lw	a5,0(a3)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L189:
	.word	.L196
	.word	.L195
	.word	.L194
	.word	.L193
	.word	.L192
	.word	.L191
	.word	.L190
	.word	.L188
	.text
.L196:
	lui	a5,%hi(shipx)
	lh	s0,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lhu	s1,%lo(shipy)(a5)
	addi	s1,s1,-10
	slli	s1,s1,16
	srai	s1,s1,16
.L187:
	li	a7,0
	li	a6,2
	mv	a5,s1
	mv	a4,s0
	li	a3,60
	li	a2,1
	li	a1,12
	li	a0,0
	call	set_sprite
	li	a7,0
	li	a6,0
	mv	a5,s1
	mv	a4,s0
	li	a3,48
	li	a2,1
	li	a1,12
	li	a0,1
	call	set_sprite
	li	a4,128
	li	a3,61
	li	a2,4
	li	a1,2
	li	a0,3
	call	beep
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
.L195:
	lui	a5,%hi(shipx)
	lhu	s0,%lo(shipx)(a5)
	addi	s0,s0,8
	slli	s0,s0,16
	srai	s0,s0,16
	lui	a5,%hi(shipy)
	lhu	s1,%lo(shipy)(a5)
	addi	s1,s1,-10
	slli	s1,s1,16
	srai	s1,s1,16
	j	.L187
.L194:
	lui	a5,%hi(shipx)
	lhu	s0,%lo(shipx)(a5)
	addi	s0,s0,10
	slli	s0,s0,16
	srai	s0,s0,16
	lui	a5,%hi(shipy)
	lh	s1,%lo(shipy)(a5)
	j	.L187
.L193:
	lui	a5,%hi(shipx)
	lhu	s0,%lo(shipx)(a5)
	addi	s0,s0,10
	slli	s0,s0,16
	srai	s0,s0,16
	lui	a5,%hi(shipy)
	lhu	s1,%lo(shipy)(a5)
	addi	s1,s1,10
	slli	s1,s1,16
	srai	s1,s1,16
	j	.L187
.L192:
	lui	a5,%hi(shipx)
	lh	s0,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lhu	s1,%lo(shipy)(a5)
	addi	s1,s1,10
	slli	s1,s1,16
	srai	s1,s1,16
	j	.L187
.L191:
	lui	a5,%hi(shipx)
	lhu	s0,%lo(shipx)(a5)
	addi	s0,s0,-10
	slli	s0,s0,16
	srai	s0,s0,16
	lui	a5,%hi(shipy)
	lhu	s1,%lo(shipy)(a5)
	addi	s1,s1,10
	slli	s1,s1,16
	srai	s1,s1,16
	j	.L187
.L190:
	lui	a5,%hi(shipx)
	lhu	s0,%lo(shipx)(a5)
	addi	s0,s0,-10
	slli	s0,s0,16
	srai	s0,s0,16
	lui	a5,%hi(shipy)
	lh	s1,%lo(shipy)(a5)
	j	.L187
.L188:
	lui	a5,%hi(shipx)
	lhu	s0,%lo(shipx)(a5)
	addi	s0,s0,-10
	slli	s0,s0,16
	srai	s0,s0,16
	lui	a5,%hi(shipy)
	lhu	s1,%lo(shipy)(a5)
	addi	s1,s1,-10
	slli	s1,s1,16
	srai	s1,s1,16
	j	.L187
	.size	fire_bullet, .-fire_bullet
	.align	2
	.globl	update_bullet
	.type	update_bullet, @function
update_bullet:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s1,4(sp)
	lui	s0,%hi(.LANCHOR0)
	addi	s0,s0,%lo(.LANCHOR0)
	lui	s1,%hi(bulletdirection)
	lh	a5,%lo(bulletdirection)(s1)
	slli	a5,a5,1
	add	a5,s0,a5
	lhu	a2,1176(a5)
	addi	a2,a2,384
	slli	a2,a2,16
	srai	a2,a2,16
	li	a1,12
	li	a0,0
	call	update_sprite
	lh	a5,%lo(bulletdirection)(s1)
	slli	a5,a5,1
	add	s0,s0,a5
	lhu	a2,1176(s0)
	addi	a2,a2,384
	slli	a2,a2,16
	srai	a2,a2,16
	li	a1,12
	li	a0,1
	call	update_sprite
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
	.size	update_bullet, .-update_bullet
	.align	2
	.globl	beepboop
	.type	beepboop, @function
beepboop:
	lui	a5,%hi(TIMER1HZ)
	lw	a4,%lo(TIMER1HZ)(a5)
	lhu	a5,0(a4)
	slli	a5,a5,16
	srai	a5,a5,16
	lui	a3,%hi(last_timer)
	lh	a3,%lo(last_timer)(a3)
	bne	a3,a5,.L208
	ret
.L208:
	addi	sp,sp,-16
	sw	ra,12(sp)
	lhu	a4,0(a4)
	lui	a5,%hi(last_timer)
	sh	a4,%lo(last_timer)(a5)
	li	a0,5
	call	tilemap_scrollwrapclear
	lui	a5,%hi(TIMER1HZ)
	lw	a5,%lo(TIMER1HZ)(a5)
	lhu	a5,0(a5)
	andi	a5,a5,3
	li	a4,2
	beq	a5,a4,.L202
	li	a4,3
	beq	a5,a4,.L203
	beq	a5,zero,.L209
.L200:
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
.L209:
	li	a4,500
	li	a3,1
	li	a2,0
	li	a1,1
	li	a0,1
	call	beep
	j	.L200
.L202:
	li	a4,500
	li	a3,2
	li	a2,0
	li	a1,1
	li	a0,2
	call	beep
	j	.L200
.L203:
	li	a0,6
	call	tilemap_scrollwrapclear
	j	.L200
	.size	beepboop, .-beepboop
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	sw	s5,4(sp)
	sw	s6,0(sp)
	lui	a5,%hi(UART_STATUS)
	lw	a5,%lo(UART_STATUS)(a5)
	lbu	a5,0(a5)
	andi	a5,a5,1
	beq	a5,zero,.L211
	lui	s0,%hi(UART_STATUS)
.L212:
	call	inputcharacter
	lw	a5,%lo(UART_STATUS)(s0)
	lbu	a5,0(a5)
	andi	a5,a5,1
	bne	a5,zero,.L212
.L211:
	call	setup_game
	lui	s0,%hi(counter)
	lui	s1,%hi(BUTTONS)
	lui	s2,%hi(lives)
	li	s5,3
	lui	s4,%hi(shipx)
	li	s3,312
	j	.L223
.L228:
	call	new_level
	j	.L213
.L229:
	call	fire_bullet
	j	.L220
.L230:
	call	move_ship
	j	.L221
.L214:
	bne	a5,zero,.L215
	lw	a5,%lo(BUTTONS)(s1)
	lbu	a5,0(a5)
	andi	a5,a5,4
	bne	a5,zero,.L227
.L215:
	li	a0,21
	call	draw_ship
	li	a7,0
	li	a6,0
	li	a5,0
	li	a4,0
	li	a3,0
	li	a2,0
	li	a1,12
	li	a0,0
	call	set_sprite
	li	a7,0
	li	a6,0
	li	a5,0
	li	a4,0
	li	a3,0
	li	a2,0
	li	a1,12
	li	a0,1
	call	set_sprite
.L222:
	call	move_asteroids
	call	wait_timer1khz
.L223:
	lw	a5,%lo(counter)(s0)
	addi	a5,a5,1
	sw	a5,%lo(counter)(s0)
	lw	a5,%lo(BUTTONS)(s1)
	lui	a4,%hi(LEDS)
	lw	a4,%lo(LEDS)(a4)
	lbu	a5,0(a5)
	andi	a5,a5,0xff
	sb	a5,0(a4)
	call	count_asteroids
	beq	a0,zero,.L228
.L213:
	call	await_vblank
	lui	a5,%hi(TIMER1KHZ)
	lw	a5,%lo(TIMER1KHZ)(a5)
	li	a4,4
	sh	a4,0(a5)
	lw	a5,%lo(lives)(s2)
	ble	a5,zero,.L214
	lui	a5,%hi(resetship)
	lh	s6,%lo(resetship)(a5)
	bne	s6,zero,.L215
	call	beepboop
	lw	a5,%lo(counter)(s0)
	andi	a5,a5,3
	bne	a5,zero,.L216
	lw	a4,%lo(BUTTONS)(s1)
	lbu	a5,0(a4)
	andi	a5,a5,32
	beq	a5,zero,.L217
	lui	a5,%hi(shipdirection)
	lh	a5,%lo(shipdirection)(a5)
	li	a3,7
	beq	a5,zero,.L218
	addi	a5,a5,-1
	slli	a3,a5,16
	srai	a3,a3,16
.L218:
	lui	a5,%hi(shipdirection)
	sh	a3,%lo(shipdirection)(a5)
.L217:
	lbu	a5,0(a4)
	andi	a5,a5,64
	beq	a5,zero,.L216
	lui	a5,%hi(shipdirection)
	lh	a5,%lo(shipdirection)(a5)
	li	a4,7
	beq	a5,a4,.L219
	addi	a5,a5,1
	slli	s6,a5,16
	srai	s6,s6,16
.L219:
	lui	a5,%hi(shipdirection)
	sh	s6,%lo(shipdirection)(a5)
.L216:
	lw	a5,%lo(BUTTONS)(s1)
	lbu	a5,0(a5)
	andi	a5,a5,2
	bne	a5,zero,.L229
.L220:
	lw	a5,%lo(BUTTONS)(s1)
	lbu	a5,0(a5)
	andi	a5,a5,8
	bne	a5,zero,.L230
.L221:
	li	a0,63
	call	draw_ship
	call	update_bullet
	j	.L222
.L227:
	call	gpu_cs
	sw	zero,%lo(counter)(s0)
	sw	s5,%lo(lives)(s2)
	lui	a5,%hi(score)
	sw	zero,%lo(score)(a5)
	sh	s3,%lo(shipx)(s4)
	lui	a5,%hi(shipy)
	li	a4,232
	sh	a4,%lo(shipy)(a5)
	lui	a5,%hi(shipdirection)
	sh	zero,%lo(shipdirection)(a5)
	lui	a5,%hi(resetship)
	sh	zero,%lo(resetship)(a5)
	lui	a5,%hi(bulletdirection)
	sh	zero,%lo(bulletdirection)(a5)
	call	draw_lives
	call	new_level
	j	.L215
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
	.globl	VECTOR_WRITER_COMMIT
	.globl	VECTOR_WRITER_DELTAY
	.globl	VECTOR_WRITER_DELTAX
	.globl	VECTOR_WRITER_ACTIVE
	.globl	VECTOR_WRITER_VERTEX
	.globl	VECTOR_WRITER_BLOCK
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
	.type	VECTOR_WRITER_COMMIT, @object
	.size	VECTOR_WRITER_COMMIT, 4
VECTOR_WRITER_COMMIT:
	.word	33864
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
