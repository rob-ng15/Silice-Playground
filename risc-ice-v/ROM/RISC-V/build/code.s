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
	.globl	qrng
	.type	qrng, @function
qrng:
	lui	a5,%hi(RNG)
	lw	a5,%lo(RNG)(a5)
	lhu	a5,0(a5)
	slli	a5,a5,16
	srai	a5,a5,16
	and	a0,a5,a0
	ret
	.size	qrng, .-qrng
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
.L8:
	lhu	a5,0(a4)
	slli	a5,a5,16
	srai	a5,a5,16
	bne	a5,zero,.L8
	ret
	.size	wait_timer1khz, .-wait_timer1khz
	.align	2
	.globl	beep
	.type	beep, @function
beep:
	andi	a5,a0,1
	beq	a5,zero,.L11
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
	lw	a5,%lo(AUDIO_L_START)(a5)
	sb	a1,0(a5)
.L11:
	andi	a0,a0,2
	beq	a0,zero,.L10
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
	sb	a1,0(a5)
.L10:
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
.L16:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	beq	a5,zero,.L16
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
.L21:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L21
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
.L24:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L24
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
	lui	a5,%hi(VECTOR_DRAW_STATUS)
	lw	a4,%lo(VECTOR_DRAW_STATUS)(a5)
.L41:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L41
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
	beq	a0,zero,.L45
	li	t1,1
	beq	a0,t1,.L46
	ret
.L45:
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
.L46:
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
	.globl	get_sprite_collision
	.type	get_sprite_collision, @function
get_sprite_collision:
	bne	a0,zero,.L49
	slli	a1,a1,1
	lui	a5,%hi(LOWER_SPRITE_COLLISION_BASE)
	lw	a5,%lo(LOWER_SPRITE_COLLISION_BASE)(a5)
	add	a1,a5,a1
	lhu	a0,0(a1)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
.L49:
	slli	a1,a1,1
	lui	a5,%hi(UPPER_SPRITE_COLLISION_BASE)
	lw	a5,%lo(UPPER_SPRITE_COLLISION_BASE)(a5)
	add	a1,a5,a1
	lhu	a0,0(a1)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
	.size	get_sprite_collision, .-get_sprite_collision
	.align	2
	.globl	get_sprite_attribute
	.type	get_sprite_attribute, @function
get_sprite_attribute:
	bne	a0,zero,.L52
	lui	a5,%hi(LOWER_SPRITE_NUMBER)
	lw	a5,%lo(LOWER_SPRITE_NUMBER)(a5)
	sb	a1,0(a5)
	li	a5,5
	bgtu	a2,a5,.L53
	slli	a2,a2,2
	lui	a5,%hi(.L55)
	addi	a5,a5,%lo(.L55)
	add	a2,a2,a5
	lw	a5,0(a2)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L55:
	.word	.L60
	.word	.L59
	.word	.L58
	.word	.L57
	.word	.L56
	.word	.L54
	.text
.L60:
	lui	a5,%hi(LOWER_SPRITE_ACTIVE)
	lw	a5,%lo(LOWER_SPRITE_ACTIVE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L59:
	lui	a5,%hi(LOWER_SPRITE_TILE)
	lw	a5,%lo(LOWER_SPRITE_TILE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L58:
	lui	a5,%hi(LOWER_SPRITE_COLOUR)
	lw	a5,%lo(LOWER_SPRITE_COLOUR)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L57:
	lui	a5,%hi(LOWER_SPRITE_X)
	lw	a5,%lo(LOWER_SPRITE_X)(a5)
	lhu	a0,0(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
.L56:
	lui	a5,%hi(LOWER_SPRITE_Y)
	lw	a5,%lo(LOWER_SPRITE_Y)(a5)
	lhu	a0,0(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
.L54:
	lui	a5,%hi(LOWER_SPRITE_DOUBLE)
	lw	a5,%lo(LOWER_SPRITE_DOUBLE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L52:
	lui	a5,%hi(UPPER_SPRITE_NUMBER)
	lw	a5,%lo(UPPER_SPRITE_NUMBER)(a5)
	sb	a1,0(a5)
	li	a5,5
	bgtu	a2,a5,.L53
	slli	a2,a2,2
	lui	a5,%hi(.L63)
	addi	a5,a5,%lo(.L63)
	add	a2,a2,a5
	lw	a5,0(a2)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L63:
	.word	.L68
	.word	.L67
	.word	.L66
	.word	.L65
	.word	.L64
	.word	.L62
	.text
.L68:
	lui	a5,%hi(UPPER_SPRITE_ACTIVE)
	lw	a5,%lo(UPPER_SPRITE_ACTIVE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L67:
	lui	a5,%hi(UPPER_SPRITE_TILE)
	lw	a5,%lo(UPPER_SPRITE_TILE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L66:
	lui	a5,%hi(UPPER_SPRITE_COLOUR)
	lw	a5,%lo(UPPER_SPRITE_COLOUR)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L65:
	lui	a5,%hi(UPPER_SPRITE_X)
	lw	a5,%lo(UPPER_SPRITE_X)(a5)
	lhu	a0,0(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
.L64:
	lui	a5,%hi(UPPER_SPRITE_Y)
	lw	a5,%lo(UPPER_SPRITE_Y)(a5)
	lhu	a0,0(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
.L62:
	lui	a5,%hi(UPPER_SPRITE_DOUBLE)
	lw	a5,%lo(UPPER_SPRITE_DOUBLE)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L53:
	ret
	.size	get_sprite_attribute, .-get_sprite_attribute
	.align	2
	.globl	update_sprite
	.type	update_sprite, @function
update_sprite:
	beq	a0,zero,.L70
	li	a5,1
	beq	a0,a5,.L71
	ret
.L70:
	lui	a5,%hi(LOWER_SPRITE_NUMBER)
	lw	a5,%lo(LOWER_SPRITE_NUMBER)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(LOWER_SPRITE_UPDATE)
	lw	a5,%lo(LOWER_SPRITE_UPDATE)(a5)
	sh	a2,0(a5)
	ret
.L71:
	lui	a5,%hi(UPPER_SPRITE_NUMBER)
	lw	a5,%lo(UPPER_SPRITE_NUMBER)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(UPPER_SPRITE_UPDATE)
	lw	a5,%lo(UPPER_SPRITE_UPDATE)(a5)
	sh	a2,0(a5)
	ret
	.size	update_sprite, .-update_sprite
	.align	2
	.globl	set_sprite_line
	.type	set_sprite_line, @function
set_sprite_line:
	beq	a0,zero,.L74
	li	a5,1
	beq	a0,a5,.L75
	ret
.L74:
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
.L75:
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
	.globl	tpu_cs
	.type	tpu_cs, @function
tpu_cs:
	lui	a5,%hi(TPU_COMMIT)
	lw	a4,%lo(TPU_COMMIT)(a5)
.L78:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L78
	li	a5,3
	sb	a5,0(a4)
	ret
	.size	tpu_cs, .-tpu_cs
	.align	2
	.globl	tpu_outputstring
	.type	tpu_outputstring, @function
tpu_outputstring:
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
	li	a3,1
	sb	a3,0(a5)
	lbu	a2,0(a4)
	beq	a2,zero,.L80
	lui	a1,%hi(TPU_COMMIT)
	lui	a6,%hi(TPU_CHARACTER)
	li	a0,2
.L83:
	lw	a3,%lo(TPU_COMMIT)(a1)
.L82:
	lbu	a5,0(a3)
	andi	a5,a5,0xff
	bne	a5,zero,.L82
	lw	a5,%lo(TPU_CHARACTER)(a6)
	sb	a2,0(a5)
	lw	a5,%lo(TPU_COMMIT)(a1)
	sb	a0,0(a5)
	addi	a4,a4,1
	lbu	a2,0(a4)
	bne	a2,zero,.L83
.L80:
	ret
	.size	tpu_outputstring, .-tpu_outputstring
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
.L87:
	addi	s1,s7,%lo(.LANCHOR0)
	mv	s0,s3
	andi	s2,s5,0xff
.L88:
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
	bne	s0,s4,.L88
	addi	s5,s5,1
	slli	s5,s5,16
	srai	s5,s5,16
	bne	s5,s6,.L87
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
.L95:
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
	bne	s0,s2,.L95
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
	li	s2,128
.L101:
	lhu	a3,0(s1)
	mv	a2,s0
	li	a1,12
	li	a0,0
	call	set_sprite_line
	lhu	a3,0(s1)
	mv	a2,s0
	li	a1,12
	li	a0,1
	call	set_sprite_line
	addi	s0,s0,1
	andi	s0,s0,0xff
	addi	s1,s1,2
	bne	s0,s2,.L101
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
	lui	s4,%hi(.LANCHOR0+1024)
	addi	s4,s4,%lo(.LANCHOR0+1024)
	li	s2,1
	li	s6,0
	li	s3,16
	li	s5,9
.L105:
	mv	s1,s4
	mv	s0,s6
.L106:
	lhu	a2,0(s1)
	mv	a1,s0
	mv	a0,s2
	call	set_tilemap_line
	addi	s0,s0,1
	andi	s0,s0,0xff
	addi	s1,s1,2
	bne	s0,s3,.L106
	addi	s2,s2,1
	andi	s2,s2,0xff
	addi	s4,s4,32
	bne	s2,s5,.L105
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
	j	.L117
.L113:
	sltiu	a0,a1,13
	xori	a0,a0,1
.L114:
	addi	a1,a1,-13
	li	a7,0
	li	a6,0
	li	a5,0
	li	a4,0
	li	a3,0
	li	a2,0
	andi	a1,a1,0xff
	call	set_sprite
	bgtu	s0,s6,.L116
.L118:
	addi	s1,s1,1
	addi	s0,s0,1
	andi	s0,s0,0xff
	addi	s2,s2,1
	addi	s3,s3,1
.L117:
	andi	a1,s1,0xff
	bgtu	a1,s4,.L113
	sb	zero,0(s2)
	sb	zero,0(s3)
	sltiu	a0,a1,13
	xori	a0,a0,1
	bgtu	a1,s5,.L114
	li	a7,0
	li	a6,0
	li	a5,0
	li	a4,0
	li	a3,0
	li	a2,0
	li	a0,0
	call	set_sprite
	j	.L118
.L116:
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
	call	tpu_cs
	call	set_asteroid_sprites
	li	a0,0
	call	set_ship_sprites
	call	set_ship_vector
	call	set_bullet_sprites
	lui	a5,%hi(lives)
	sh	zero,%lo(lives)(a5)
	lui	a5,%hi(score)
	sh	zero,%lo(score)(a5)
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
	j	.L124
.L123:
	addi	a5,a5,1
	andi	a5,a5,0xff
	addi	a4,a4,1
	beq	a5,a2,.L127
.L124:
	lbu	a3,0(a4)
	bne	a3,zero,.L123
	mv	a0,a5
	j	.L123
.L127:
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
	beq	a0,a5,.L128
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
.L131:
	lhu	a4,0(a2)
	slli	a4,a4,16
	srai	a4,a4,16
	rem	a4,a4,t1
	lhu	a5,0(a2)
	slli	a5,a5,16
	srai	a5,a5,16
	rem	a5,a5,a7
	andi	a3,a4,255
	bgt	t3,a3,.L130
	blt	a6,a3,.L130
	andi	a3,a5,255
	bgt	t4,a3,.L130
	bge	a0,a3,.L131
.L130:
	mv	a7,a1
	lui	a0,%hi(.LANCHOR1)
	addi	a0,a0,%lo(.LANCHOR1)
	add	a0,a0,a1
	sb	s0,0(a0)
	li	a3,2
	li	a0,3
	beq	s0,a3,.L132
	li	a0,7
.L132:
	lhu	a6,0(a2)
	lui	a3,%hi(.LANCHOR1)
	addi	a3,a3,%lo(.LANCHOR1)
	add	a3,a3,a7
	and	a0,a0,a6
	sb	a0,24(a3)
	sltiu	a0,a1,11
	xori	a0,a0,1
	li	a3,10
	bleu	a1,a3,.L133
	addi	a1,a1,-11
	andi	a1,a1,0xff
.L133:
	lhu	a3,0(a2)
	lhu	a6,0(a2)
	slli	a6,a6,16
	srai	a6,a6,16
	addi	a7,s0,-2
	li	a2,7
	rem	a6,a6,a2
	andi	a3,a3,31
	seqz	a7,a7
	andi	a6,a6,0xff
	andi	a5,a5,0xff
	andi	a4,a4,0xff
	addi	a3,a3,32
	li	a2,1
	call	set_sprite
.L128:
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
.L138:
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
	bne	s0,s3,.L138
	lui	a5,%hi(level)
	lhu	s1,%lo(level)(a5)
	slli	a4,s1,16
	srli	a4,a4,16
	li	a5,4
	bleu	a4,a5,.L139
	li	s1,4
.L139:
	addi	s1,s1,4
	andi	s1,s1,0xff
	li	s0,0
.L140:
	li	a0,2
	call	new_asteroid
	addi	s0,s0,1
	andi	s0,s0,0xff
	bgtu	s1,s0,.L140
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
	sw	s8,8(sp)
	sw	s9,4(sp)
	sw	s10,0(sp)
	lui	s2,%hi(.LANCHOR1)
	addi	s2,s2,%lo(.LANCHOR1)
	addi	s4,s2,24
	li	s1,245
	li	s0,0
	li	s8,1
	li	s9,10
	lui	s10,%hi(.LANCHOR0)
	addi	s10,s10,%lo(.LANCHOR0)
	li	s7,2
	li	s6,3
	li	s5,22
	j	.L150
.L157:
	sltiu	a0,s0,11
	xori	a0,a0,1
	mv	a1,s1
	bgtu	s0,s9,.L146
	mv	a1,s0
.L146:
	lbu	a5,0(s4)
	slli	a5,a5,1
	add	a5,s10,a5
	lhu	a2,1280(a5)
	call	update_sprite
	j	.L145
.L147:
	lbu	a5,0(s3)
	beq	a5,s6,.L155
.L148:
	addi	s0,s0,1
	andi	s0,s0,0xff
	addi	s2,s2,1
	addi	s1,s1,1
	andi	s1,s1,0xff
	addi	s4,s4,1
	beq	s0,s5,.L156
.L150:
	mv	s3,s2
	lbu	a5,0(s2)
	addi	a5,a5,-1
	andi	a5,a5,0xff
	bleu	a5,s8,.L157
.L145:
	lbu	a5,0(s3)
	bleu	a5,s7,.L147
	addi	a5,a5,-1
	sb	a5,0(s3)
	j	.L147
.L155:
	sb	zero,0(s3)
	sltiu	a0,s0,11
	xori	a0,a0,1
	mv	a1,s1
	bgtu	s0,s9,.L149
	mv	a1,s0
.L149:
	li	a7,0
	li	a6,0
	li	a5,0
	li	a4,0
	li	a3,0
	li	a2,0
	call	set_sprite
	j	.L148
.L156:
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
	lw	s9,4(sp)
	lw	s10,0(sp)
	addi	sp,sp,48
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
	j	.L160
.L159:
	addi	a5,a5,1
	beq	a5,a3,.L162
.L160:
	lbu	a4,0(a5)
	beq	a4,zero,.L159
	addi	a0,a0,1
	slli	a0,a0,16
	srai	a0,a0,16
	j	.L159
.L162:
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
	bgtu	a3,a4,.L165
	slli	a5,a3,2
	lui	a4,%hi(.L168)
	addi	a4,a4,%lo(.L168)
	add	a5,a5,a4
	lw	a5,0(a5)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L168:
	.word	.L175
	.word	.L174
	.word	.L173
	.word	.L172
	.word	.L171
	.word	.L170
	.word	.L169
	.word	.L167
	.text
.L175:
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a4,464
	ble	a5,zero,.L176
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L176:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
	ret
.L174:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a3,623
	li	a4,0
	bgt	a5,a3,.L177
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L177:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a4,464
	ble	a5,zero,.L178
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L178:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
	ret
.L173:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a3,623
	li	a4,0
	bgt	a5,a3,.L179
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L179:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	ret
.L172:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a3,623
	li	a4,0
	bgt	a5,a3,.L180
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L180:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a3,463
	li	a4,0
	bgt	a5,a3,.L181
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L181:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
	ret
.L171:
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a3,463
	li	a4,0
	bgt	a5,a3,.L182
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L182:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
	ret
.L170:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a4,624
	ble	a5,zero,.L183
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L183:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a3,463
	li	a4,0
	bgt	a5,a3,.L184
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L184:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
	ret
.L169:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a4,624
	ble	a5,zero,.L185
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L185:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	ret
.L167:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a4,624
	ble	a5,zero,.L186
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L186:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a4,464
	ble	a5,zero,.L187
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L187:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
.L165:
	ret
	.size	move_ship, .-move_ship
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"Score 000000"
	.text
	.align	2
	.globl	draw_score
	.type	draw_score, @function
draw_score:
	addi	sp,sp,-32
	sw	ra,28(sp)
	lui	a5,%hi(.LC0)
	addi	a5,a5,%lo(.LC0)
	lw	a2,0(a5)
	lw	a3,4(a5)
	lw	a4,8(a5)
	sw	a2,0(sp)
	sw	a3,4(sp)
	sw	a4,8(sp)
	lbu	a5,12(a5)
	sb	a5,12(sp)
	lui	a5,%hi(score)
	lhu	a3,%lo(score)(a5)
	addi	a5,sp,11
	addi	a1,sp,6
	li	a2,10
.L201:
	remu	a4,a3,a2
	divu	a3,a3,a2
	addi	a4,a4,48
	sb	a4,0(a5)
	addi	a5,a5,-1
	bne	a5,a1,.L201
	lui	a5,%hi(lives)
	lhu	a3,%lo(lives)(a5)
	snez	a3,a3
	neg	a3,a3
	andi	a3,a3,42
	mv	a4,sp
	addi	a3,a3,21
	li	a2,64
	li	a1,1
	li	a0,34
	call	tpu_outputstring
	lw	ra,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	draw_score, .-draw_score
	.align	2
	.globl	draw_lives
	.type	draw_lives, @function
draw_lives:
	addi	sp,sp,-16
	sw	ra,12(sp)
	lui	a5,%hi(lives)
	lhu	a5,%lo(lives)(a5)
	li	a4,2
	beq	a5,a4,.L207
	li	a4,3
	beq	a5,a4,.L208
	li	a4,1
	bne	a5,a4,.L206
	j	.L209
.L208:
	li	a3,464
	li	a2,608
	li	a1,63
	li	a0,0
	call	draw_vector_block
.L207:
	li	a3,464
	li	a2,576
	li	a1,63
	li	a0,0
	call	draw_vector_block
.L209:
	li	a3,464
	li	a2,544
	li	a1,63
	li	a0,0
	call	draw_vector_block
.L206:
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
	bgtu	a4,a5,.L213
	slli	a3,a3,2
	lui	a5,%hi(.L215)
	addi	a5,a5,%lo(.L215)
	add	a3,a3,a5
	lw	a5,0(a3)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L215:
	.word	.L222
	.word	.L221
	.word	.L220
	.word	.L219
	.word	.L218
	.word	.L217
	.word	.L216
	.word	.L214
	.text
.L222:
	lui	a5,%hi(shipx)
	lh	s0,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lhu	s1,%lo(shipy)(a5)
	addi	s1,s1,-10
	slli	s1,s1,16
	srai	s1,s1,16
.L213:
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
.L221:
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
	j	.L213
.L220:
	lui	a5,%hi(shipx)
	lhu	s0,%lo(shipx)(a5)
	addi	s0,s0,10
	slli	s0,s0,16
	srai	s0,s0,16
	lui	a5,%hi(shipy)
	lh	s1,%lo(shipy)(a5)
	j	.L213
.L219:
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
	j	.L213
.L218:
	lui	a5,%hi(shipx)
	lh	s0,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lhu	s1,%lo(shipy)(a5)
	addi	s1,s1,10
	slli	s1,s1,16
	srai	s1,s1,16
	j	.L213
.L217:
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
	j	.L213
.L216:
	lui	a5,%hi(shipx)
	lhu	s0,%lo(shipx)(a5)
	addi	s0,s0,-10
	slli	s0,s0,16
	srai	s0,s0,16
	lui	a5,%hi(shipy)
	lh	s1,%lo(shipy)(a5)
	j	.L213
.L214:
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
	j	.L213
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
	lhu	a2,1304(a5)
	li	a1,12
	li	a0,0
	call	update_sprite
	lh	a5,%lo(bulletdirection)(s1)
	slli	a5,a5,1
	add	s0,s0,a5
	lhu	a2,1304(s0)
	li	a1,12
	li	a0,1
	call	update_sprite
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
	.size	update_bullet, .-update_bullet
	.section	.rodata.str1.4
	.align	2
.LC1:
	.string	"         Welcome to Risc-ICE-V Asteroids        "
	.align	2
.LC2:
	.string	"By @robng15 (Twitter) from Whitebridge, Scotland"
	.align	2
.LC3:
	.string	"                 Press UP to start              "
	.align	2
.LC4:
	.string	"          Written in Silice by @sylefeb         "
	.text
	.align	2
	.globl	beepboop
	.type	beepboop, @function
beepboop:
	lui	a5,%hi(TIMER1HZ)
	lw	a5,%lo(TIMER1HZ)(a5)
	lhu	a5,0(a5)
	slli	a5,a5,16
	srai	a5,a5,16
	lui	a4,%hi(last_timer)
	lh	a4,%lo(last_timer)(a4)
	bne	a4,a5,.L239
	ret
.L239:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	call	draw_score
	lui	s0,%hi(TIMER1HZ)
	lw	a5,%lo(TIMER1HZ)(s0)
	lhu	a4,0(a5)
	lui	a5,%hi(last_timer)
	sh	a4,%lo(last_timer)(a5)
	li	a0,5
	call	tilemap_scrollwrapclear
	lw	a5,%lo(TIMER1HZ)(s0)
	lhu	a5,0(a5)
	andi	a5,a5,3
	li	a4,2
	beq	a5,a4,.L228
	bgtu	a5,a4,.L229
	beq	a5,zero,.L230
	li	a4,1
	bne	a5,a4,.L226
	lui	a5,%hi(lives)
	lhu	a5,%lo(lives)(a5)
	bne	a5,zero,.L226
	lui	a4,%hi(.LC2)
	addi	a4,a4,%lo(.LC2)
	li	a3,15
	li	a2,64
	li	a1,18
	li	a0,16
	call	tpu_outputstring
	j	.L226
.L230:
	lui	a5,%hi(lives)
	lhu	a5,%lo(lives)(a5)
	beq	a5,zero,.L232
	li	a4,500
	li	a3,1
	li	a2,0
	li	a1,1
	li	a0,1
	call	beep
	j	.L226
.L232:
	lui	a4,%hi(.LC1)
	addi	a4,a4,%lo(.LC1)
	li	a3,3
	li	a2,64
	li	a1,18
	li	a0,16
	call	tpu_outputstring
	j	.L226
.L228:
	lui	a5,%hi(lives)
	lhu	a5,%lo(lives)(a5)
	beq	a5,zero,.L233
	li	a4,500
	li	a3,2
	li	a2,0
	li	a1,1
	li	a0,2
	call	beep
	j	.L226
.L233:
	lui	a4,%hi(.LC3)
	addi	a4,a4,%lo(.LC3)
	li	a3,60
	li	a2,64
	li	a1,18
	li	a0,16
	call	tpu_outputstring
	j	.L226
.L229:
	lui	a5,%hi(lives)
	lhu	a5,%lo(lives)(a5)
	beq	a5,zero,.L240
.L234:
	li	a0,6
	call	tilemap_scrollwrapclear
.L226:
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
.L240:
	lui	a4,%hi(.LC4)
	addi	a4,a4,%lo(.LC4)
	li	a3,48
	li	a2,64
	li	a1,18
	li	a0,16
	call	tpu_outputstring
	j	.L234
	.size	beepboop, .-beepboop
	.align	2
	.globl	spawn_asteroid
	.type	spawn_asteroid, @function
spawn_asteroid:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s1,4(sp)
	sw	s2,0(sp)
	mv	s0,a0
	mv	s1,a1
	mv	s2,a2
	call	find_asteroid_space
	li	a5,255
	beq	a0,a5,.L241
	mv	a1,a0
	mv	a2,a0
	lui	a4,%hi(.LANCHOR1)
	addi	a4,a4,%lo(.LANCHOR1)
	add	a4,a4,a0
	sb	s0,0(a4)
	li	a5,2
	li	a4,3
	beq	s0,a5,.L243
	li	a4,7
.L243:
	lui	a5,%hi(RNG)
	lw	a6,%lo(RNG)(a5)
	lhu	a3,0(a6)
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	add	a5,a5,a2
	and	a4,a4,a3
	sb	a4,24(a5)
	sltiu	a0,a1,11
	xori	a0,a0,1
	li	a5,10
	bleu	a1,a5,.L244
	addi	a1,a1,-11
	andi	a1,a1,0xff
.L244:
	lhu	a3,0(a6)
	lhu	a4,0(a6)
	lhu	a5,0(a6)
	lhu	a6,0(a6)
	slli	a6,a6,16
	srai	a6,a6,16
	addi	a7,s0,-2
	li	a2,7
	rem	a6,a6,a2
	andi	a5,a5,15
	add	a5,a5,s2
	addi	a5,a5,-8
	andi	a4,a4,15
	addi	a4,a4,-8
	add	a4,a4,s1
	andi	a3,a3,31
	seqz	a7,a7
	andi	a6,a6,0xff
	slli	a5,a5,16
	srai	a5,a5,16
	slli	a4,a4,16
	srai	a4,a4,16
	addi	a3,a3,32
	li	a2,1
	call	set_sprite
.L241:
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	lw	s2,0(sp)
	addi	sp,sp,16
	jr	ra
	.size	spawn_asteroid, .-spawn_asteroid
	.align	2
	.globl	check_hit
	.type	check_hit, @function
check_hit:
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
	sw	s8,8(sp)
	li	a1,12
	li	a0,0
	call	get_sprite_collision
	andi	a0,a0,2047
	bne	a0,zero,.L248
	li	a1,12
	li	a0,1
	call	get_sprite_collision
	andi	a0,a0,2047
	beq	a0,zero,.L247
.L248:
	li	a4,500
	li	a3,8
	li	a2,4
	li	a1,2
	li	a0,3
	call	beep
	li	s0,0
	li	s4,255
	li	a0,0
	li	a1,0
	li	s2,4096
	li	s1,22
	li	s3,10
	j	.L250
.L264:
	addi	a1,s0,-10
	andi	a1,a1,0xff
.L251:
	mv	s0,a5
.L250:
	call	get_sprite_collision
	and	a0,a0,s2
	slli	a0,a0,16
	srli	a0,a0,16
	beq	a0,zero,.L252
	mv	s4,s0
.L252:
	addi	a5,s0,1
	andi	a5,a5,0xff
	beq	a5,s1,.L263
	sltiu	a0,a5,11
	xori	a0,a0,1
	mv	a1,a5
	bgtu	a5,s3,.L264
	j	.L251
.L263:
	li	a5,255
	beq	s4,a5,.L247
	mv	s5,s4
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	add	a5,a5,s4
	lbu	a4,0(a5)
	li	a5,2
	bleu	a4,a5,.L265
.L247:
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
.L265:
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
	lui	a3,%hi(score)
	lhu	a5,%lo(score)(a3)
	addi	a5,a5,3
	lui	a4,%hi(.LANCHOR1)
	addi	a4,a4,%lo(.LANCHOR1)
	add	a4,a4,s4
	lbu	a4,0(a4)
	sub	a5,a5,a4
	sh	a5,%lo(score)(a3)
	sltiu	s1,s4,11
	xori	s1,s1,1
	li	a5,10
	bleu	s4,a5,.L254
	addi	s4,s4,-11
	andi	s4,s4,0xff
.L254:
	li	a2,2
	mv	a1,s4
	mv	a0,s1
	call	get_sprite_attribute
	andi	s7,a0,0xff
	li	a2,3
	mv	a1,s4
	mv	a0,s1
	call	get_sprite_attribute
	slli	s2,a0,16
	srai	s2,s2,16
	li	a2,4
	mv	a1,s4
	mv	a0,s1
	call	get_sprite_attribute
	slli	s3,a0,16
	srai	s3,s3,16
	li	a2,5
	mv	a1,s4
	mv	a0,s1
	call	get_sprite_attribute
	andi	s8,a0,0xff
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	add	a5,a5,s5
	lbu	a4,0(a5)
	li	a5,2
	beq	a4,a5,.L266
.L255:
	mv	a7,s8
	li	a6,7
	mv	a5,s3
	mv	a4,s2
	mv	a3,s7
	li	a2,1
	mv	a1,s4
	mv	a0,s1
	call	set_sprite
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	add	a5,a5,s5
	li	a4,25
	sb	a4,0(a5)
	j	.L247
.L266:
	lui	a5,%hi(level)
	lhu	a4,%lo(level)(a5)
	mv	a5,a4
	li	a3,2
	bleu	a4,a3,.L256
	li	a5,2
.L256:
	andi	s6,a5,0xff
	li	a3,2
	li	a5,0
	bgtu	a4,a3,.L267
.L257:
	addi	s6,s6,1
	add	a5,a5,s6
	andi	s6,a5,0xff
	li	s0,0
.L258:
	mv	a2,s3
	mv	a1,s2
	li	a0,1
	call	spawn_asteroid
	addi	s0,s0,1
	bne	s6,s0,.L258
	j	.L255
.L267:
	lui	a5,%hi(RNG)
	lw	a5,%lo(RNG)(a5)
	lhu	a5,0(a5)
	andi	a5,a5,1
	j	.L257
	.size	check_hit, .-check_hit
	.align	2
	.globl	check_crash
	.type	check_crash, @function
check_crash:
	addi	sp,sp,-16
	sw	ra,12(sp)
	li	a1,11
	li	a0,0
	call	get_sprite_collision
	andi	a0,a0,2047
	bne	a0,zero,.L269
	li	a1,11
	li	a0,1
	call	get_sprite_collision
	andi	a0,a0,2047
	beq	a0,zero,.L268
.L269:
	li	a4,1000
	li	a3,1
	li	a2,4
	li	a1,2
	li	a0,3
	call	beep
	li	a0,1
	call	set_ship_sprites
	lui	a5,%hi(resetship)
	li	a4,75
	sh	a4,%lo(resetship)(a5)
.L268:
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	check_crash, .-check_crash
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
	beq	a5,zero,.L273
	lui	s0,%hi(UART_STATUS)
.L274:
	call	inputcharacter
	lw	a5,%lo(UART_STATUS)(s0)
	lbu	a5,0(a5)
	andi	a5,a5,1
	bne	a5,zero,.L274
.L273:
	call	setup_game
	lui	s0,%hi(counter)
	lui	s2,%hi(LEDS)
	lui	s1,%hi(lives)
	li	s5,3
	lui	s4,%hi(shipx)
	li	s3,312
	j	.L289
.L296:
	lui	a4,%hi(level)
	lhu	a5,%lo(level)(a4)
	addi	a5,a5,1
	sh	a5,%lo(level)(a4)
	call	new_level
	j	.L275
.L297:
	call	fire_bullet
	j	.L282
.L298:
	call	move_ship
	j	.L283
.L276:
	lui	a5,%hi(BUTTONS)
	lw	a5,%lo(BUTTONS)(a5)
	lbu	a5,0(a5)
	andi	a5,a5,8
	bne	a5,zero,.L293
.L285:
	li	a0,21
	call	draw_ship
	lui	a5,%hi(resetship)
	lhu	a5,%lo(resetship)(a5)
	addi	a5,a5,-1
	slli	a5,a5,16
	srli	a5,a5,16
	li	a4,15
	bleu	a5,a4,.L294
.L286:
	lui	a5,%hi(resetship)
	lh	a4,%lo(resetship)(a5)
	li	a5,16
	bgt	a4,a5,.L295
.L288:
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
.L284:
	call	move_asteroids
	call	wait_timer1khz
.L289:
	lw	a5,%lo(counter)(s0)
	addi	a5,a5,1
	sw	a5,%lo(counter)(s0)
	call	count_asteroids
	lw	a4,%lo(LEDS)(s2)
	lui	a5,%hi(last_timer)
	lhu	a5,%lo(last_timer)(a5)
	andi	a5,a5,7
	sll	a0,a0,a5
	andi	a0,a0,0xff
	sb	a0,0(a4)
	call	count_asteroids
	beq	a0,zero,.L296
.L275:
	call	await_vblank
	lui	a5,%hi(TIMER1KHZ)
	lw	a5,%lo(TIMER1KHZ)(a5)
	li	a4,8
	sh	a4,0(a5)
	call	beepboop
	lhu	a5,%lo(lives)(s1)
	beq	a5,zero,.L276
	lui	a5,%hi(resetship)
	lh	a5,%lo(resetship)(a5)
	bne	a5,zero,.L277
	lw	a4,%lo(counter)(s0)
	andi	a4,a4,3
	bne	a4,zero,.L278
	lui	a4,%hi(BUTTONS)
	lw	a3,%lo(BUTTONS)(a4)
	lbu	a4,0(a3)
	andi	a4,a4,32
	beq	a4,zero,.L279
	lui	a4,%hi(shipdirection)
	lh	a4,%lo(shipdirection)(a4)
	li	a2,7
	beq	a4,zero,.L280
	addi	a4,a4,-1
	slli	a2,a4,16
	srai	a2,a2,16
.L280:
	lui	a4,%hi(shipdirection)
	sh	a2,%lo(shipdirection)(a4)
.L279:
	lbu	a4,0(a3)
	andi	a4,a4,64
	beq	a4,zero,.L278
	lui	a4,%hi(shipdirection)
	lh	a4,%lo(shipdirection)(a4)
	li	a3,7
	beq	a4,a3,.L281
	addi	a5,a4,1
	slli	a5,a5,16
	srai	a5,a5,16
.L281:
	lui	a4,%hi(shipdirection)
	sh	a5,%lo(shipdirection)(a4)
.L278:
	li	a2,0
	li	a1,12
	li	a0,0
	call	get_sprite_attribute
	bne	a0,zero,.L282
	lui	a5,%hi(BUTTONS)
	lw	a5,%lo(BUTTONS)(a5)
	lbu	a5,0(a5)
	andi	a5,a5,2
	bne	a5,zero,.L297
.L282:
	lui	a5,%hi(BUTTONS)
	lw	a5,%lo(BUTTONS)(a5)
	lbu	a5,0(a5)
	andi	a5,a5,4
	bne	a5,zero,.L298
.L283:
	li	a0,63
	call	draw_ship
	call	update_bullet
	call	check_hit
	call	check_crash
	j	.L284
.L293:
	call	gpu_cs
	call	tpu_cs
	sw	zero,%lo(counter)(s0)
	sh	s5,%lo(lives)(s1)
	lui	a5,%hi(score)
	sh	zero,%lo(score)(a5)
	lui	a5,%hi(level)
	sh	zero,%lo(level)(a5)
	sh	s3,%lo(shipx)(s4)
	lui	a5,%hi(shipy)
	li	a4,232
	sh	a4,%lo(shipy)(a5)
	lui	a5,%hi(shipdirection)
	sh	zero,%lo(shipdirection)(a5)
	lui	s6,%hi(resetship)
	sh	zero,%lo(resetship)(s6)
	lui	a5,%hi(bulletdirection)
	sh	zero,%lo(bulletdirection)(a5)
	call	draw_lives
	call	new_level
	lhu	a5,%lo(resetship)(s6)
	addi	a5,a5,-1
	slli	a5,a5,16
	srli	a5,a5,16
	li	a4,15
	bleu	a5,a4,.L285
	lhu	a5,%lo(lives)(s1)
	beq	a5,zero,.L285
	j	.L286
.L294:
	li	a1,11
	li	a0,0
	call	get_sprite_collision
	andi	a0,a0,2047
	bne	a0,zero,.L286
	li	a1,11
	li	a0,1
	call	get_sprite_collision
	andi	a0,a0,2047
	bne	a0,zero,.L286
	lui	a4,%hi(resetship)
	lhu	a5,%lo(resetship)(a4)
	addi	a5,a5,-1
	slli	a5,a5,16
	srai	a5,a5,16
	sh	a5,%lo(resetship)(a4)
	beq	a5,zero,.L299
.L287:
	lhu	a5,%lo(lives)(s1)
	bne	a5,zero,.L286
	call	risc_ice_v_logo
	j	.L286
.L299:
	call	gpu_cs
	lhu	a5,%lo(lives)(s1)
	addi	a5,a5,-1
	sh	a5,%lo(lives)(s1)
	call	draw_lives
	j	.L287
.L295:
	li	a2,57344
	li	a1,11
	li	a0,0
	call	update_sprite
	li	a2,65536
	addi	a2,a2,-1984
	li	a1,11
	li	a0,1
	call	update_sprite
	lui	a4,%hi(resetship)
	lhu	a5,%lo(resetship)(a4)
	addi	a5,a5,-1
	slli	a5,a5,16
	srai	a5,a5,16
	sh	a5,%lo(resetship)(a4)
	li	a4,16
	bne	a5,a4,.L288
	li	a0,0
	call	set_ship_sprites
	j	.L288
.L277:
	addi	a5,a5,-1
	slli	a5,a5,16
	srli	a5,a5,16
	li	a4,15
	bgtu	a5,a4,.L286
	j	.L285
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
	.globl	level
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
	.globl	VECTOR_WRITER_COMMIT
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
	.half	416
	.half	434
	.half	387
	.half	402
	.half	408
	.half	406
	.half	388
	.half	438
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
