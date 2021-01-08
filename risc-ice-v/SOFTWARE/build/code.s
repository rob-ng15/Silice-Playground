	.file	"maze.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	1
	.globl	ghostcolour
	.type	ghostcolour, @function
ghostcolour:
	mv	a5,a0
	li	a4,2
	beq	a0,a4,.L4
	bgtu	a0,a4,.L3
	snez	a0,a0
	neg	a0,a0
	andi	a0,a0,36
	addi	a0,a0,15
	ret
.L3:
	li	a4,3
	li	a0,48
	bne	a5,a4,.L7
.L1:
	ret
.L7:
	ret
.L4:
	li	a0,56
	j	.L1
	.size	ghostcolour, .-ghostcolour
	.align	1
	.globl	draw_ghost
	.type	draw_ghost, @function
draw_ghost:
	addi	sp,sp,-64
	sw	ra,60(sp)
	sw	s0,56(sp)
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
	sw	s11,12(sp)
	mv	s5,a0
	mv	s7,a1
	mv	s6,a2
	li	s0,16
	sub	s0,s0,a0
	slli	a5,s0,1
	add	s0,s0,a5
	slli	s0,s0,1
	slli	s0,s0,16
	srli	s0,s0,16
	addi	s8,s0,240
	slli	s8,s8,16
	srli	s8,s8,16
	li	s1,3
	div	s1,s0,s1
	slli	s3,s1,16
	srli	s3,s3,16
	add	s9,s1,s0
	mv	a0,a1
	call	ghostcolour
	mv	s2,a0
	add	s4,s0,s8
	slli	s11,s4,16
	slli	s4,s4,16
	srai	s4,s4,16
	addi	a3,s0,320
	li	a1,320
	sub	a1,a1,s0
	mv	a4,s4
	slli	a3,a3,16
	srai	a3,a3,16
	li	a2,240
	slli	a1,a1,16
	srai	a1,a1,16
	call	gpu_rectangle
	li	a4,1
	slli	a3,s0,16
	srai	a3,a3,16
	li	a2,240
	li	a1,320
	mv	a0,s2
	call	gpu_circle
	li	a5,14
	bgtu	s5,a5,.L9
	srli	s9,s9,1
	srli	s10,s0,1
	slli	s3,s3,1
	slli	s3,s3,16
	srli	s3,s3,16
	slli	s1,s1,16
	srai	s1,s1,16
	li	a1,320
	sub	a1,a1,s3
	li	a4,1
	mv	a3,s1
	mv	a2,s4
	slli	a1,a1,16
	srai	a1,a1,16
	mv	a0,s2
	call	gpu_circle
	li	a4,1
	mv	a3,s1
	mv	a2,s4
	li	a1,320
	mv	a0,s2
	call	gpu_circle
	addi	s3,s3,320
	li	a4,1
	mv	a3,s1
	mv	a2,s4
	slli	a1,s3,16
	srai	a1,a1,16
	mv	a0,s2
	call	gpu_circle
	lui	a4,%hi(ghostdirection)
	slli	a5,s7,1
	addi	a4,a4,%lo(ghostdirection)
	add	a5,a4,a5
	lhu	a5,0(a5)
	sub	a5,s6,a5
	srai	a4,a5,31
	xor	a5,a4,a5
	sub	a5,a5,a4
	li	a4,2
	beq	a5,a4,.L10
	li	a4,3
	beq	a5,a4,.L11
	li	a4,1
	bne	a5,a4,.L8
	sub	a2,s8,s10
	li	a1,320
	sub	a1,a1,s9
	li	a4,1
	srli	a3,s9,1
	slli	a2,a2,16
	srai	a2,a2,16
	slli	a1,a1,16
	srai	a1,a1,16
	li	a0,63
	call	gpu_circle
.L14:
	li	a5,13
	bgtu	s5,a5,.L8
	lui	a5,%hi(ghostdirection)
	slli	s7,s7,1
	addi	a5,a5,%lo(ghostdirection)
	add	s7,a5,s7
	lhu	a2,0(s7)
	sub	s6,s6,a2
	srai	a5,s6,31
	xor	s6,a5,s6
	sub	s6,s6,a5
	li	a5,2
	bne	s6,a5,.L18
	sub	s8,s8,s10
	slli	s8,s8,16
	srai	s8,s8,16
	srli	s0,s9,2
	li	a1,320
	sub	a1,a1,s9
	li	a4,1
	mv	a3,s0
	mv	a2,s8
	slli	a1,a1,16
	srai	a1,a1,16
	li	a0,0
	call	gpu_circle
	addi	a1,s9,320
	li	a4,1
	mv	a3,s0
	mv	a2,s8
	slli	a1,a1,16
	srai	a1,a1,16
	li	a0,0
	call	gpu_circle
	j	.L8
.L9:
	srli	s11,s11,16
	addi	s0,s11,1
	slli	s0,s0,16
	srai	s0,s0,16
	li	a1,320
	sub	a1,a1,s3
	mv	a2,s0
	slli	a1,a1,16
	srai	a1,a1,16
	mv	a0,s2
	call	gpu_pixel
	mv	a2,s0
	li	a1,320
	mv	a0,s2
	call	gpu_pixel
	addi	a1,s3,320
	mv	a2,s0
	slli	a1,a1,16
	srai	a1,a1,16
	mv	a0,s2
	call	gpu_pixel
.L8:
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
	lw	s10,16(sp)
	lw	s11,12(sp)
	addi	sp,sp,64
	jr	ra
.L10:
	sub	s0,s8,s10
	slli	s0,s0,16
	srai	s0,s0,16
	srli	s1,s9,1
	li	a1,320
	sub	a1,a1,s9
	li	a4,1
	mv	a3,s1
	mv	a2,s0
	slli	a1,a1,16
	srai	a1,a1,16
	li	a0,63
	call	gpu_circle
	addi	a1,s9,320
	li	a4,1
	mv	a3,s1
	mv	a2,s0
	slli	a1,a1,16
	srai	a1,a1,16
	li	a0,63
	call	gpu_circle
	j	.L14
.L11:
	sub	a2,s8,s10
	addi	a1,s9,320
	li	a4,1
	srli	a3,s9,1
	slli	a2,a2,16
	srai	a2,a2,16
	slli	a1,a1,16
	srai	a1,a1,16
	li	a0,63
	call	gpu_circle
	j	.L14
.L18:
	li	a5,3
	bne	s6,a5,.L19
	sub	a2,s8,s10
	addi	a1,s9,320
	li	a4,1
	srli	a3,s9,2
	slli	a2,a2,16
	srai	a2,a2,16
	slli	a1,a1,16
	srai	a1,a1,16
	li	a0,0
	call	gpu_circle
	j	.L8
.L19:
	li	a5,1
	bne	s6,a5,.L8
	sub	a2,s8,s10
	li	a1,320
	sub	a1,a1,s9
	li	a4,1
	srli	a3,s9,2
	slli	a2,a2,16
	srai	a2,a2,16
	slli	a1,a1,16
	srai	a1,a1,16
	li	a0,0
	call	gpu_circle
	j	.L8
	.size	draw_ghost, .-draw_ghost
	.align	1
	.globl	move_ghost
	.type	move_ghost, @function
move_ghost:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	mv	s0,a0
	lui	a4,%hi(ghostx)
	slli	a3,a0,1
	addi	a4,a4,%lo(ghostx)
	add	a4,a4,a3
	lhu	a2,0(a4)
	lui	a4,%hi(ghostdirection)
	addi	a4,a4,%lo(ghostdirection)
	add	a4,a4,a3
	lhu	a1,0(a4)
	lui	a5,%hi(ghosty)
	addi	a5,a5,%lo(ghosty)
	add	a5,a5,a3
	lhu	a0,0(a5)
	lui	a5,%hi(directionx)
	slli	a6,a1,1
	addi	a5,a5,%lo(directionx)
	add	a5,a5,a6
	lh	a4,0(a5)
	add	a4,a4,a2
	lui	a3,%hi(directiony)
	addi	a3,a3,%lo(directiony)
	add	a3,a3,a6
	lh	a3,0(a3)
	slli	a5,a4,4
	sub	a5,a5,a4
	slli	a4,a5,1
	lui	a5,%hi(.LANCHOR0)
	addi	a5,a5,%lo(.LANCHOR0)
	add	a5,a5,a4
	add	a5,a5,a0
	add	a5,a5,a3
	lbu	a4,0(a5)
	li	a5,32
	bne	a4,a5,.L21
	lui	a5,%hi(leftdirectionx)
	addi	a5,a5,%lo(leftdirectionx)
	add	a1,a5,a6
	lh	a4,0(a1)
	add	a2,a2,a4
	slli	a5,a2,4
	sub	a2,a5,a2
	slli	a2,a2,1
	lui	a5,%hi(.LANCHOR0)
	addi	a5,a5,%lo(.LANCHOR0)
	add	a5,a5,a2
	add	a5,a5,a0
	add	a5,a5,a4
	lbu	a4,0(a5)
	li	a5,32
	beq	a4,a5,.L34
.L22:
	lui	a5,%hi(rightdirectionx)
	lui	a4,%hi(ghostdirection)
	slli	a3,s0,1
	addi	a4,a4,%lo(ghostdirection)
	mv	a2,a3
	add	a4,a4,a3
	lhu	a4,0(a4)
	slli	a4,a4,1
	addi	a5,a5,%lo(rightdirectionx)
	add	a5,a5,a4
	lh	a1,0(a5)
	lui	a4,%hi(ghostx)
	addi	a4,a4,%lo(ghostx)
	add	a4,a4,a3
	lhu	a5,0(a4)
	add	a5,a5,a1
	lui	a3,%hi(ghosty)
	addi	a3,a3,%lo(ghosty)
	add	a3,a3,a2
	lhu	a3,0(a3)
	slli	a4,a5,4
	sub	a5,a4,a5
	slli	a4,a5,1
	lui	a5,%hi(.LANCHOR0)
	addi	a5,a5,%lo(.LANCHOR0)
	add	a5,a5,a4
	add	a5,a5,a1
	add	a5,a5,a3
	lbu	a4,0(a5)
	li	a5,32
	beq	a4,a5,.L35
.L25:
	lui	a5,%hi(ghostdirection)
	slli	s0,s0,1
	addi	a5,a5,%lo(ghostdirection)
	add	a5,a5,s0
	lhu	a3,0(a5)
	lui	a5,%hi(ghostx)
	addi	a5,a5,%lo(ghostx)
	add	a5,a5,s0
	lui	a4,%hi(directionx)
	slli	a3,a3,1
	addi	a4,a4,%lo(directionx)
	add	a4,a4,a3
	lhu	a2,0(a5)
	lhu	a4,0(a4)
	add	a4,a2,a4
	sh	a4,0(a5)
	lui	a5,%hi(ghosty)
	addi	a5,a5,%lo(ghosty)
	add	s0,a5,s0
	lui	a5,%hi(directiony)
	addi	a5,a5,%lo(directiony)
	add	a5,a5,a3
	lhu	a4,0(s0)
	lhu	a5,0(a5)
	add	a5,a4,a5
	sh	a5,0(s0)
.L20:
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
.L34:
	li	a0,32
	call	rng
	bne	a0,zero,.L22
	lui	a4,%hi(ghostdirection)
	slli	a5,s0,1
	addi	a4,a4,%lo(ghostdirection)
	add	a5,a4,a5
	lhu	a5,0(a5)
	li	a4,3
	beq	a5,zero,.L23
	addi	a5,a5,-1
	slli	a4,a5,16
	srli	a4,a4,16
.L23:
	lui	a5,%hi(ghostdirection)
	slli	s0,s0,1
	addi	a5,a5,%lo(ghostdirection)
	add	s0,a5,s0
	sh	a4,0(s0)
	j	.L20
.L35:
	li	a0,32
	call	rng
	bne	a0,zero,.L25
	lui	a4,%hi(ghostdirection)
	slli	a5,s0,1
	addi	a4,a4,%lo(ghostdirection)
	add	a5,a4,a5
	lhu	a5,0(a5)
	li	a4,3
	beq	a5,a4,.L26
	addi	a0,a5,1
	slli	a0,a0,16
	srli	a0,a0,16
.L26:
	lui	a5,%hi(ghostdirection)
	slli	s0,s0,1
	addi	a5,a5,%lo(ghostdirection)
	add	s0,a5,s0
	sh	a0,0(s0)
	j	.L20
.L21:
	li	a0,2
	call	rng
	bne	a0,zero,.L27
	lui	a4,%hi(ghostdirection)
	slli	a5,s0,1
	addi	a4,a4,%lo(ghostdirection)
	add	a5,a4,a5
	lhu	a5,0(a5)
	li	a4,3
	beq	a5,zero,.L28
	addi	a5,a5,-1
	slli	a4,a5,16
	srli	a4,a4,16
.L28:
	lui	a5,%hi(ghostdirection)
	slli	s0,s0,1
	addi	a5,a5,%lo(ghostdirection)
	add	s0,a5,s0
	sh	a4,0(s0)
	j	.L20
.L27:
	lui	a4,%hi(ghostdirection)
	slli	a5,s0,1
	addi	a4,a4,%lo(ghostdirection)
	add	a5,a4,a5
	lhu	a5,0(a5)
	li	a3,3
	li	a4,0
	beq	a5,a3,.L29
	addi	a5,a5,1
	slli	a4,a5,16
	srli	a4,a4,16
.L29:
	lui	a5,%hi(ghostdirection)
	slli	s0,s0,1
	addi	a5,a5,%lo(ghostdirection)
	add	s0,a5,s0
	sh	a4,0(s0)
	j	.L20
	.size	move_ghost, .-move_ghost
	.align	1
	.globl	draw_pill
	.type	draw_pill, @function
draw_pill:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s1,4(sp)
	li	s0,16
	sub	a5,s0,a0
	slli	s0,a5,4
	sub	s0,s0,a5
	addi	s0,s0,225
	slli	s0,s0,16
	srai	s0,s0,16
	li	s1,18
	sub	s1,s1,a0
	slli	s1,s1,1
	slli	s1,s1,16
	srai	s1,s1,16
	li	a4,1
	mv	a3,s1
	mv	a2,s0
	li	a1,320
	li	a0,63
	call	gpu_circle
	li	a4,0
	mv	a3,s1
	mv	a2,s0
	li	a1,320
	li	a0,42
	call	gpu_circle
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
	.size	draw_pill, .-draw_pill
	.align	1
	.globl	initialise_maze
	.type	initialise_maze, @function
initialise_maze:
	beq	a0,zero,.L39
	lui	a5,%hi(.LANCHOR0)
	addi	a5,a5,%lo(.LANCHOR0)
	addi	a6,a5,1260
	addi	t1,a1,-1
	slli	t1,t1,16
	srli	t1,t1,16
	addi	a2,a5,1
	add	a2,a2,t1
	addi	a4,a0,-1
	slli	a4,a4,16
	srli	a4,a4,16
	slli	a7,a4,4
	sub	a7,a7,a4
	slli	a7,a7,1
	addi	a5,a5,1290
	add	a7,a7,a5
	not	t1,t1
	li	a3,35
	j	.L40
.L41:
	sb	a3,0(a5)
	sb	a3,0(a4)
	addi	a5,a5,1
	addi	a4,a4,1
	bne	a5,a2,.L41
.L43:
	addi	a6,a6,30
	addi	a2,a2,30
	beq	a6,a7,.L39
.L40:
	add	a5,t1,a2
	mv	a4,a6
	bne	a1,zero,.L41
	j	.L43
.L39:
	lui	a5,%hi(.LANCHOR0)
	addi	a5,a5,%lo(.LANCHOR0)
	li	a4,69
	sb	a4,1(a5)
	sb	a4,1261(a5)
	addi	a2,a0,-2
	addi	a7,a1,-3
	slli	a3,a2,4
	sub	a4,a3,a2
	slli	a4,a4,1
	add	a4,a5,a4
	add	a4,a4,a7
	li	a6,88
	sb	a6,0(a4)
	sub	a4,a3,a2
	slli	a4,a4,1
	add	a5,a5,a4
	add	a5,a5,a7
	sb	a6,1260(a5)
	lui	a5,%hi(level)
	lhu	t1,%lo(level)(a5)
	lui	a2,%hi(ghostx)
	addi	a2,a2,%lo(ghostx)
	lui	a3,%hi(ghosty)
	addi	a3,a3,%lo(ghosty)
	lui	a4,%hi(ghostdirection)
	addi	a4,a4,%lo(ghostdirection)
	li	a5,0
	addi	t3,a0,1
	mv	a1,a7
	li	a7,3
	addi	a0,a0,-3
	li	a6,4
	j	.L46
.L44:
	sh	t3,0(a2)
	sh	a1,0(a3)
	sh	a7,0(a4)
.L45:
	addi	a5,a5,1
	slli	a5,a5,16
	srli	a5,a5,16
	addi	a2,a2,2
	addi	a3,a3,2
	addi	a4,a4,2
	beq	a5,a6,.L50
.L46:
	bltu	t1,a5,.L44
	sh	a0,0(a2)
	sh	a1,0(a3)
	sh	a7,0(a4)
	j	.L45
.L50:
	ret
	.size	initialise_maze, .-initialise_maze
	.align	1
	.globl	display_maze
	.type	display_maze, @function
display_maze:
	addi	sp,sp,-96
	sw	ra,92(sp)
	sw	s0,88(sp)
	sw	s1,84(sp)
	sw	s2,80(sp)
	sw	s3,76(sp)
	sw	s4,72(sp)
	sw	s5,68(sp)
	sw	s6,64(sp)
	sw	s7,60(sp)
	sw	s8,56(sp)
	sw	s9,52(sp)
	sw	s10,48(sp)
	sw	s11,44(sp)
	sw	a0,24(sp)
	sw	a3,16(sp)
	li	a5,640
	div	a3,a5,a0
	sw	a3,20(sp)
	li	s11,480
	div	s11,s11,a1
	beq	a0,zero,.L51
	mv	s7,a1
	mv	s6,a2
	li	s2,0
	lui	a5,%hi(.LANCHOR0)
	addi	a5,a5,%lo(.LANCHOR0)
	sw	a5,12(sp)
	sw	zero,8(sp)
	li	s5,0
	addi	a5,a3,-1
	sw	a5,28(sp)
	li	s4,69
	addi	s8,s11,-1
	j	.L53
.L65:
	lw	a5,16(sp)
	bne	a5,s1,.L54
	li	s2,12
	j	.L55
.L66:
	bne	a5,s9,.L55
	li	s2,3
.L55:
	addi	s1,s1,1
	slli	s1,s1,16
	srli	s1,s1,16
	add	a4,s0,s8
	slli	a4,a4,16
	srai	a4,a4,16
	lw	a3,4(sp)
	slli	a2,s0,16
	srai	a2,a2,16
	lw	a1,0(sp)
	mv	a0,s2
	call	gpu_rectangle
	add	s0,s11,s0
	slli	s0,s0,16
	srli	s0,s0,16
	addi	s3,s3,1
	beq	s1,s7,.L59
.L57:
	beq	s6,s5,.L65
.L54:
	lbu	a5,0(s3)
	beq	a5,s4,.L61
	bgtu	a5,s4,.L56
	bne	a5,s10,.L66
	li	s2,63
	j	.L55
.L56:
	li	a4,88
	bne	a5,a4,.L55
	li	s2,60
	j	.L55
.L61:
	li	s2,51
	j	.L55
.L59:
	addi	s5,s5,1
	slli	s5,s5,16
	srli	s5,s5,16
	lw	a5,20(sp)
	lw	a4,8(sp)
	add	a5,a5,a4
	slli	a5,a5,16
	srli	a5,a5,16
	sw	a5,8(sp)
	lw	a5,12(sp)
	addi	a5,a5,30
	sw	a5,12(sp)
	lw	a5,24(sp)
	beq	a5,s5,.L51
.L53:
	beq	s7,zero,.L59
	lw	a5,8(sp)
	slli	a4,a5,16
	srai	a4,a4,16
	sw	a4,0(sp)
	lw	a4,28(sp)
	add	a5,a5,a4
	slli	a5,a5,16
	srai	a5,a5,16
	sw	a5,4(sp)
	lw	s3,12(sp)
	li	s0,0
	li	s1,0
	li	s10,32
	li	s9,35
	j	.L57
.L51:
	lw	ra,92(sp)
	lw	s0,88(sp)
	lw	s1,84(sp)
	lw	s2,80(sp)
	lw	s3,76(sp)
	lw	s4,72(sp)
	lw	s5,68(sp)
	lw	s6,64(sp)
	lw	s7,60(sp)
	lw	s8,56(sp)
	lw	s9,52(sp)
	lw	s10,48(sp)
	lw	s11,44(sp)
	addi	sp,sp,96
	jr	ra
	.size	display_maze, .-display_maze
	.align	1
	.globl	generate_maze
	.type	generate_maze, @function
generate_maze:
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
	sw	a0,12(sp)
	mv	s11,a1
	mv	s7,a2
	addi	a0,a0,-2
	slli	a0,a0,16
	srli	a0,a0,16
	call	rng
	mv	s2,a0
	andi	a5,a0,1
	bne	a5,zero,.L68
	addi	s2,a0,1
	slli	s2,s2,16
	srli	s2,s2,16
.L68:
	addi	a0,s11,-2
	slli	a0,a0,16
	srli	a0,a0,16
	call	rng
	mv	s3,a0
	andi	a5,a0,1
	bne	a5,zero,.L69
	addi	s3,a0,1
	slli	s3,s3,16
	srli	s3,s3,16
.L69:
	slli	a5,s2,4
	sub	a5,a5,s2
	slli	a4,a5,1
	lui	a5,%hi(.LANCHOR0)
	addi	a5,a5,%lo(.LANCHOR0)
	add	a5,a5,a4
	add	a5,a5,s3
	li	a4,32
	sb	a4,0(a5)
	addi	s0,s11,-1
	lw	a5,12(sp)
	addi	s6,a5,-1
	lui	s4,%hi(.LANCHOR0)
	addi	s4,s4,%lo(.LANCHOR0)
	j	.L85
.L72:
	mv	a3,s3
	mv	a4,s2
	bne	a0,s9,.L76
	bleu	s3,s5,.L76
	addi	a3,s3,-2
	slli	a3,a3,16
	srli	a3,a3,16
	j	.L76
.L100:
	addi	a5,s2,2
	bge	a5,s6,.L86
	slli	a4,a5,16
	srli	a4,a4,16
	mv	a3,s3
.L76:
	slli	a5,a4,4
	sub	a5,a5,a4
	slli	a5,a5,1
	add	a5,s4,a5
	add	a5,a5,a3
	lbu	a5,0(a5)
	beq	a5,s8,.L98
.L77:
	addi	s1,s1,1
	slli	s1,s1,16
	srli	s1,s1,16
	beq	s7,s1,.L99
	mv	s3,a3
	mv	s2,a4
.L78:
	li	a0,4
	call	rng
	beq	a0,s5,.L71
	bgtu	a0,s5,.L72
	beq	a0,zero,.L100
	addi	a5,s3,2
	bge	a5,s0,.L87
	slli	a3,a5,16
	srli	a3,a3,16
	mv	a4,s2
	j	.L76
.L71:
	bleu	s2,s5,.L88
	addi	a4,s2,-2
	slli	a4,a4,16
	srli	a4,a4,16
	mv	a3,s3
	j	.L76
.L86:
	mv	a3,s3
	mv	a4,s2
	j	.L76
.L87:
	mv	a3,s3
	mv	a4,s2
	j	.L76
.L88:
	mv	a3,s3
	mv	a4,s2
	j	.L76
.L98:
	slli	a5,a4,4
	sub	a5,a5,a4
	slli	a5,a5,1
	add	a5,s4,a5
	add	a5,a5,a3
	sb	s10,0(a5)
	add	a2,s2,a4
	srli	a5,a2,31
	add	a5,a5,a2
	srai	a2,a5,1
	add	a1,s3,a3
	srli	a5,a1,31
	add	a5,a5,a1
	srai	a1,a5,1
	slli	a5,a2,4
	sub	a5,a5,a2
	slli	a5,a5,1
	add	a5,s4,a5
	add	a5,a5,a1
	sb	s10,0(a5)
	j	.L77
.L99:
	mv	s3,a3
	mv	s2,a4
.L70:
	li	a5,1
	ble	s6,a5,.L67
	li	a3,1
	li	a0,1
	li	a7,1
	li	a6,1
	li	a1,35
	j	.L79
.L82:
	add	a5,a2,a5
	lbu	a5,0(a5)
	sub	a5,a5,a1
	snez	a5,a5
	neg	a5,a5
	and	a3,a3,a5
	addi	a4,a4,2
	slli	a4,a4,16
	srli	a4,a4,16
	mv	a5,a4
	blt	a4,s0,.L82
.L84:
	addi	a0,a0,2
	slli	a0,a0,16
	srli	a0,a0,16
	mv	a7,a0
	bge	a0,s6,.L101
.L79:
	mv	a4,a6
	mv	a5,a6
	ble	s0,a6,.L84
	slli	a2,a7,4
	sub	a2,a2,a7
	slli	a2,a2,1
	add	a2,s4,a2
	j	.L82
.L101:
	bne	a3,zero,.L67
.L85:
	mv	a3,s3
	mv	a2,s2
	mv	a1,s11
	lw	a0,12(sp)
	call	display_maze
	beq	s7,zero,.L70
	li	s1,0
	li	s5,2
	li	s9,3
	li	s8,35
	li	s10,32
	j	.L78
.L67:
	lw	ra,76(sp)
	lw	s0,72(sp)
	lw	s1,68(sp)
	lw	s2,64(sp)
	lw	s3,60(sp)
	lw	s4,56(sp)
	lw	s5,52(sp)
	lw	s6,48(sp)
	lw	s7,44(sp)
	lw	s8,40(sp)
	lw	s9,36(sp)
	lw	s10,32(sp)
	lw	s11,28(sp)
	addi	sp,sp,80
	jr	ra
	.size	generate_maze, .-generate_maze
	.align	1
	.globl	draw_map
	.type	draw_map, @function
draw_map:
	addi	sp,sp,-128
	sw	ra,124(sp)
	sw	s0,120(sp)
	sw	s1,116(sp)
	sw	s2,112(sp)
	sw	s3,108(sp)
	sw	s4,104(sp)
	sw	s5,100(sp)
	sw	s6,96(sp)
	sw	s7,92(sp)
	sw	s8,88(sp)
	sw	s9,84(sp)
	sw	s10,80(sp)
	sw	s11,76(sp)
	mv	s0,a0
	mv	s1,a1
	sw	a1,28(sp)
	sw	a2,56(sp)
	sw	a3,60(sp)
	sw	a4,48(sp)
	mv	s5,a5
	sw	a6,52(sp)
	li	a5,160
	div	s3,a5,a0
	sw	s3,24(sp)
	li	a5,120
	div	s11,a5,a1
	li	a4,140
	li	a3,640
	li	a2,0
	li	a1,460
	li	a0,56
	call	gpu_rectangle
	beq	s0,zero,.L103
	li	s2,0
	addi	a3,s1,-1
	slli	a3,a3,16
	srli	a3,a3,16
	lui	a4,%hi(.LANCHOR0)
	addi	a5,a4,%lo(.LANCHOR0)
	addi	a5,a5,1261
	add	s9,a5,a3
	addi	a2,a4,%lo(.LANCHOR0)
	sw	a2,20(sp)
	addi	a5,s0,-1
	slli	a5,a5,16
	srli	a5,a5,16
	slli	a4,a5,4
	sub	a5,a4,a5
	slli	a5,a5,1
	addi	a4,a2,30
	add	a5,a5,a4
	sw	a5,32(sp)
	li	a5,475
	sw	a5,16(sp)
	addi	a5,s3,-1
	sw	a5,36(sp)
	addi	a5,s11,9
	sw	a5,40(sp)
	not	a5,a3
	sw	a5,44(sp)
	li	a5,1
	sub	s10,a5,s11
	j	.L104
.L105:
	lbu	a5,0(s3)
.L106:
	beq	a5,s4,.L125
	bgt	a5,s4,.L108
	beq	a5,s7,.L126
	bne	a5,s6,.L107
	li	s2,3
.L107:
	add	a2,s0,s10
	slli	a4,s0,16
	srai	a4,a4,16
	lw	a3,12(sp)
	slli	a2,a2,16
	srai	a2,a2,16
	lw	a1,8(sp)
	mv	a0,s2
	call	gpu_rectangle
	add	s0,s0,s11
	slli	s0,s0,16
	srli	s0,s0,16
	addi	s1,s1,1
	addi	s3,s3,1
	beq	s1,s9,.L111
.L109:
	beq	s5,zero,.L105
	lbu	a5,0(s1)
	j	.L106
.L108:
	bne	a5,s8,.L107
	li	s2,60
	j	.L107
.L125:
	li	s2,51
	j	.L107
.L126:
	li	s2,63
	j	.L107
.L111:
	lw	a5,24(sp)
	lw	a4,16(sp)
	add	a5,a5,a4
	slli	a5,a5,16
	srli	a5,a5,16
	sw	a5,16(sp)
	addi	s9,s9,30
	lw	a5,20(sp)
	addi	a5,a5,30
	sw	a5,20(sp)
	lw	a4,32(sp)
	beq	a5,a4,.L103
.L104:
	lw	a5,28(sp)
	beq	a5,zero,.L111
	lw	a5,16(sp)
	slli	a4,a5,16
	srai	a4,a4,16
	sw	a4,8(sp)
	lw	a4,36(sp)
	add	a5,a5,a4
	slli	a5,a5,16
	srai	a5,a5,16
	sw	a5,12(sp)
	lw	s0,40(sp)
	lw	a5,44(sp)
	add	s1,a5,s9
	lw	s3,20(sp)
	li	s4,69
	li	s8,88
	li	s7,32
	li	s6,35
	j	.L109
.L103:
	lw	s5,24(sp)
	lw	a5,56(sp)
	mul	a5,s5,a5
	slli	a5,a5,16
	srli	a5,a5,16
	lw	a4,60(sp)
	mul	a2,s11,a4
	slli	a2,a2,16
	srli	a2,a2,16
	add	a4,a2,s11
	addi	a4,a4,9
	add	a3,a5,s5
	addi	a3,a3,474
	addi	a2,a2,10
	addi	a5,a5,475
	slli	a4,a4,16
	srai	a4,a4,16
	slli	a3,a3,16
	srai	a3,a3,16
	slli	a2,a2,16
	srai	a2,a2,16
	slli	a1,a5,16
	srai	a1,a1,16
	li	a0,12
	call	gpu_rectangle
	lui	s2,%hi(ghostx)
	addi	s2,s2,%lo(ghostx)
	lui	s1,%hi(ghosty)
	addi	s1,s1,%lo(ghosty)
	li	s0,0
	lui	s4,%hi(level)
	li	s3,4
	j	.L113
.L112:
	addi	s0,s0,1
	slli	s0,s0,16
	srli	s0,s0,16
	addi	s2,s2,2
	addi	s1,s1,2
	beq	s0,s3,.L132
.L113:
	lhu	a5,%lo(level)(s4)
	bltu	a5,s0,.L112
	mv	a0,s0
	call	ghostcolour
	lhu	a1,0(s2)
	mul	a1,s5,a1
	slli	a1,a1,16
	srli	a1,a1,16
	lhu	a2,0(s1)
	mul	a2,s11,a2
	slli	a2,a2,16
	srli	a2,a2,16
	add	a4,a2,s11
	addi	a4,a4,9
	add	a3,a1,s5
	addi	a3,a3,474
	addi	a2,a2,10
	addi	a1,a1,475
	slli	a4,a4,16
	srai	a4,a4,16
	slli	a3,a3,16
	srai	a3,a3,16
	slli	a2,a2,16
	srai	a2,a2,16
	slli	a1,a1,16
	srai	a1,a1,16
	call	gpu_rectangle
	j	.L112
.L132:
	li	a6,10
	li	a5,463
	li	a4,10
	li	a3,473
	li	a2,1
	li	a1,468
	li	a0,0
	call	gpu_triangle
	li	a6,10
	li	a5,463
	li	a4,19
	li	a3,468
	li	a2,10
	li	a1,473
	li	a0,0
	call	gpu_triangle
	li	a5,2
	lw	a4,48(sp)
	beq	a4,a5,.L114
	bgtu	a4,a5,.L115
	beq	a4,zero,.L133
	li	a6,19
	li	a5,468
	li	a4,10
	li	a3,473
	li	a2,1
	li	a1,468
	li	a0,12
	call	gpu_triangle
	j	.L119
.L115:
	li	a5,3
	lw	a4,48(sp)
	bne	a4,a5,.L119
	li	a6,10
	li	a5,463
	li	a4,19
	li	a3,468
	li	a2,1
	li	a1,468
	li	a0,12
	call	gpu_triangle
	j	.L119
.L133:
	li	a6,10
	li	a5,463
	li	a4,10
	li	a3,473
	li	a2,1
	li	a1,468
	li	a0,12
	call	gpu_triangle
.L119:
	li	a5,3
	lw	a4,52(sp)
	beq	a4,a5,.L120
	bgtu	a4,a5,.L121
	li	a5,1
	beq	a4,a5,.L122
	li	a5,2
	bne	a4,a5,.L102
.L123:
	li	a4,0
	li	a3,1
	li	a2,122
	li	a1,462
	li	a0,12
	call	gpu_character_blit
.L122:
	li	a4,0
	li	a3,1
	li	a2,130
	li	a1,462
	li	a0,12
	call	gpu_character_blit
.L102:
	lw	ra,124(sp)
	lw	s0,120(sp)
	lw	s1,116(sp)
	lw	s2,112(sp)
	lw	s3,108(sp)
	lw	s4,104(sp)
	lw	s5,100(sp)
	lw	s6,96(sp)
	lw	s7,92(sp)
	lw	s8,88(sp)
	lw	s9,84(sp)
	lw	s10,80(sp)
	lw	s11,76(sp)
	addi	sp,sp,128
	jr	ra
.L114:
	li	a6,10
	li	a5,463
	li	a4,19
	li	a3,468
	li	a2,10
	li	a1,473
	li	a0,12
	call	gpu_triangle
	j	.L119
.L121:
	li	a5,4
	lw	a4,52(sp)
	bne	a4,a5,.L102
	li	a4,0
	li	a3,1
	li	a2,106
	li	a1,462
	li	a0,12
	call	gpu_character_blit
.L120:
	li	a4,0
	li	a3,1
	li	a2,114
	li	a1,462
	li	a0,12
	call	gpu_character_blit
	j	.L123
	.size	draw_map, .-draw_map
	.align	1
	.globl	counttowall
	.type	counttowall, @function
counttowall:
	mv	a7,a0
	mv	t1,a1
	li	a0,0
	li	t2,0
	lui	t0,%hi(.LANCHOR0)
	addi	t0,t0,%lo(.LANCHOR0)
	li	a6,1
	li	t5,69
	li	t4,88
	li	t3,35
	lui	t6,%hi(directionx)
	addi	t6,t6,%lo(directionx)
	slli	a5,a2,1
	add	t6,t6,a5
	lui	a2,%hi(directiony)
	addi	a2,a2,%lo(directiony)
	add	a2,a2,a5
.L135:
	mv	a4,t2
	slli	a5,a7,4
	sub	a5,a5,a7
	slli	a5,a5,1
	add	a5,t0,a5
	add	a5,a5,t1
.L136:
	bne	a4,zero,.L143
	lbu	a3,0(a5)
	mv	a4,a6
	beq	a3,t5,.L136
	beq	a3,t4,.L136
	beq	a3,t3,.L136
	lhu	a5,0(t6)
	add	a7,a7,a5
	slli	a7,a7,16
	srli	a7,a7,16
	lhu	a1,0(a2)
	add	a1,t1,a1
	slli	t1,a1,16
	srli	t1,t1,16
	addi	a0,a0,1
	slli	a0,a0,16
	srli	a0,a0,16
	j	.L135
.L143:
	ret
	.size	counttowall, .-counttowall
	.align	1
	.globl	whatisleft
	.type	whatisleft, @function
whatisleft:
	lui	a4,%hi(directionx)
	slli	a2,a2,1
	addi	a4,a4,%lo(directionx)
	add	a4,a4,a2
	lh	a5,0(a4)
	mul	a5,a5,a3
	lui	a4,%hi(leftdirectionx)
	addi	a4,a4,%lo(leftdirectionx)
	add	a4,a4,a2
	lh	a4,0(a4)
	add	a0,a0,a5
	add	a0,a0,a4
	lui	a4,%hi(directiony)
	addi	a4,a4,%lo(directiony)
	add	a4,a4,a2
	lh	a5,0(a4)
	mul	a3,a5,a3
	lui	a4,%hi(leftdirectiony)
	addi	a4,a4,%lo(leftdirectiony)
	add	a2,a4,a2
	lh	a2,0(a2)
	slli	a4,a0,4
	sub	a0,a4,a0
	slli	a0,a0,1
	lui	a5,%hi(.LANCHOR0)
	addi	a5,a5,%lo(.LANCHOR0)
	add	a5,a5,a0
	add	a5,a5,a1
	add	a5,a5,a3
	add	a5,a5,a2
	lbu	a0,0(a5)
	ret
	.size	whatisleft, .-whatisleft
	.align	1
	.globl	whatisright
	.type	whatisright, @function
whatisright:
	lui	a4,%hi(directionx)
	slli	a2,a2,1
	addi	a4,a4,%lo(directionx)
	add	a4,a4,a2
	lh	a5,0(a4)
	mul	a5,a5,a3
	lui	a4,%hi(rightdirectionx)
	addi	a4,a4,%lo(rightdirectionx)
	add	a4,a4,a2
	lh	a4,0(a4)
	add	a0,a0,a5
	add	a0,a0,a4
	lui	a4,%hi(directiony)
	addi	a4,a4,%lo(directiony)
	add	a4,a4,a2
	lh	a5,0(a4)
	mul	a3,a5,a3
	lui	a4,%hi(rightdirectiony)
	addi	a4,a4,%lo(rightdirectiony)
	add	a2,a4,a2
	lh	a2,0(a2)
	slli	a4,a0,4
	sub	a0,a4,a0
	slli	a0,a0,1
	lui	a5,%hi(.LANCHOR0)
	addi	a5,a5,%lo(.LANCHOR0)
	add	a5,a5,a0
	add	a5,a5,a1
	add	a5,a5,a3
	add	a5,a5,a2
	lbu	a0,0(a5)
	ret
	.size	whatisright, .-whatisright
	.align	1
	.globl	left_wall
	.type	left_wall, @function
left_wall:
	addi	sp,sp,-32
	sw	ra,28(sp)
	mv	a5,a1
	lui	a4,%hi(.LANCHOR1)
	addi	a4,a4,%lo(.LANCHOR1)
	slli	a3,a1,1
	add	a3,a4,a3
	lh	a1,0(a3)
	lh	a2,36(a3)
	addi	a5,a5,1
	slli	a5,a5,1
	add	a4,a4,a5
	lh	a3,0(a4)
	lh	a4,36(a4)
	li	t1,480
	sub	a6,t1,a4
	sub	t1,t1,a2
	slli	t1,t1,16
	srai	t1,t1,16
	sw	t1,0(sp)
	mv	a7,a1
	slli	a6,a6,16
	srai	a6,a6,16
	mv	a5,a3
	call	gpu_quadrilateral
	lw	ra,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	left_wall, .-left_wall
	.align	1
	.globl	right_wall
	.type	right_wall, @function
right_wall:
	addi	sp,sp,-32
	sw	ra,28(sp)
	mv	a5,a1
	lui	a6,%hi(.LANCHOR1)
	addi	a6,a6,%lo(.LANCHOR1)
	slli	a3,a1,1
	add	a3,a6,a3
	li	a4,640
	lhu	a1,0(a3)
	sub	a1,a4,a1
	slli	a1,a1,16
	srai	a1,a1,16
	lh	a2,36(a3)
	addi	a5,a5,1
	slli	a5,a5,1
	add	a6,a6,a5
	lhu	a5,0(a6)
	sub	a5,a4,a5
	slli	a5,a5,16
	srai	a5,a5,16
	lh	a3,36(a6)
	li	a4,480
	sub	a6,a4,a3
	sub	a4,a4,a2
	sw	a3,0(sp)
	mv	a7,a5
	slli	a6,a6,16
	srai	a6,a6,16
	slli	a4,a4,16
	srai	a4,a4,16
	mv	a3,a1
	call	gpu_quadrilateral
	lw	ra,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	right_wall, .-right_wall
	.align	1
	.globl	walk_maze
	.type	walk_maze, @function
walk_maze:
	addi	sp,sp,-144
	sw	ra,140(sp)
	sw	s0,136(sp)
	sw	s1,132(sp)
	sw	s2,128(sp)
	sw	s3,124(sp)
	sw	s4,120(sp)
	sw	s5,116(sp)
	sw	s6,112(sp)
	sw	s7,108(sp)
	sw	s8,104(sp)
	sw	s9,100(sp)
	sw	s10,96(sp)
	sw	s11,92(sp)
	sw	a0,60(sp)
	sw	a1,64(sp)
	li	a5,4
	sw	a5,68(sp)
	li	a5,1
	sw	a5,56(sp)
	li	s10,1
	li	s11,1
	lui	a5,%hi(.LANCHOR0)
	addi	a5,a5,%lo(.LANCHOR0)
	sw	a5,32(sp)
	lui	a5,%hi(directionx)
	addi	a5,a5,%lo(directionx)
	sw	a5,36(sp)
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	sw	a5,72(sp)
	addi	a5,a5,36
	sw	a5,76(sp)
	j	.L151
.L154:
	addi	s0,a0,1
	slli	a5,s0,1
	lw	a4,72(sp)
	add	a5,a4,a5
	lh	a2,36(a5)
	li	a4,480
	sub	a4,a4,a2
	slli	a4,a4,16
	srai	a4,a4,16
	li	a3,640
	li	a1,0
	li	a0,60
	call	gpu_rectangle
	li	a5,3
	beq	s3,a5,.L156
	bgtu	s3,a5,.L157
	li	a5,1
	beq	s3,a5,.L158
	li	a5,2
	bne	s3,a5,.L152
	slli	s0,s0,1
	lw	a5,72(sp)
	add	s0,a5,s0
	lhu	a2,36(s0)
	addi	a2,a2,8
	li	a4,2
	li	a3,69
	slli	a2,a2,16
	srai	a2,a2,16
	li	a1,256
	li	a0,12
	call	gpu_character_blit
	lhu	a2,36(s0)
	addi	a2,a2,8
	li	a4,2
	li	a3,88
	slli	a2,a2,16
	srai	a2,a2,16
	li	a1,288
	li	a0,12
	call	gpu_character_blit
	lhu	a2,36(s0)
	addi	a2,a2,8
	li	a4,2
	li	a3,73
	slli	a2,a2,16
	srai	a2,a2,16
	li	a1,320
	li	a0,12
	call	gpu_character_blit
	lhu	a2,36(s0)
	addi	a2,a2,8
	li	a4,2
	li	a3,84
	slli	a2,a2,16
	srai	a2,a2,16
	li	a1,352
	li	a0,12
	call	gpu_character_blit
	j	.L152
.L157:
	li	a5,4
	bne	s3,a5,.L152
	slli	s0,s0,1
	lw	a5,72(sp)
	add	s0,a5,s0
	lhu	a2,36(s0)
	addi	a2,a2,2
	li	a4,0
	li	a3,69
	slli	a2,a2,16
	srai	a2,a2,16
	li	a1,304
	li	a0,12
	call	gpu_character_blit
	lhu	a2,36(s0)
	addi	a2,a2,2
	li	a4,0
	li	a3,88
	slli	a2,a2,16
	srai	a2,a2,16
	li	a1,312
	li	a0,12
	call	gpu_character_blit
	lhu	a2,36(s0)
	addi	a2,a2,2
	li	a4,0
	li	a3,73
	slli	a2,a2,16
	srai	a2,a2,16
	li	a1,320
	li	a0,12
	call	gpu_character_blit
	lhu	a2,36(s0)
	addi	a2,a2,2
	li	a4,0
	li	a3,84
	slli	a2,a2,16
	srai	a2,a2,16
	li	a1,328
	li	a0,12
	call	gpu_character_blit
	j	.L152
.L158:
	slli	s0,s0,1
	lw	a5,72(sp)
	add	s0,a5,s0
	lhu	a2,36(s0)
	addi	a2,a2,16
	li	a4,3
	li	a3,69
	slli	a2,a2,16
	srai	a2,a2,16
	li	a1,192
	li	a0,12
	call	gpu_character_blit
	lhu	a2,36(s0)
	addi	a2,a2,16
	li	a4,3
	li	a3,88
	slli	a2,a2,16
	srai	a2,a2,16
	li	a1,256
	li	a0,12
	call	gpu_character_blit
	lhu	a2,36(s0)
	addi	a2,a2,16
	li	a4,3
	li	a3,73
	slli	a2,a2,16
	srai	a2,a2,16
	li	a1,320
	li	a0,12
	call	gpu_character_blit
	lhu	a2,36(s0)
	addi	a2,a2,16
	li	a4,3
	li	a3,84
	slli	a2,a2,16
	srai	a2,a2,16
	li	a1,384
	li	a0,12
	call	gpu_character_blit
	j	.L152
.L156:
	slli	s0,s0,1
	lw	a5,72(sp)
	add	s0,a5,s0
	lhu	a2,36(s0)
	addi	a2,a2,4
	li	a4,1
	li	a3,69
	slli	a2,a2,16
	srai	a2,a2,16
	li	a1,288
	li	a0,12
	call	gpu_character_blit
	lhu	a2,36(s0)
	addi	a2,a2,4
	li	a4,1
	li	a3,88
	slli	a2,a2,16
	srai	a2,a2,16
	li	a1,304
	li	a0,12
	call	gpu_character_blit
	lhu	a2,36(s0)
	addi	a2,a2,4
	li	a4,1
	li	a3,73
	slli	a2,a2,16
	srai	a2,a2,16
	li	a1,320
	li	a0,12
	call	gpu_character_blit
	lhu	a2,36(s0)
	addi	a2,a2,4
	li	a4,1
	li	a3,84
	slli	a2,a2,16
	srai	a2,a2,16
	li	a1,336
	li	a0,12
	call	gpu_character_blit
	j	.L152
.L153:
	addi	a5,a0,1
	slli	a5,a5,1
	lw	a4,72(sp)
	add	a5,a4,a5
	lh	a2,36(a5)
	li	a4,480
	sub	a4,a4,a2
	slli	a4,a4,16
	srai	a4,a4,16
	li	a3,640
	li	a1,0
	li	a0,51
	call	gpu_rectangle
	j	.L152
.L221:
	addi	a5,a0,1
	slli	a5,a5,1
	lw	a4,72(sp)
	add	a5,a4,a5
	lh	a2,36(a5)
	li	a4,480
	sub	a4,a4,a2
	slli	a4,a4,16
	srai	a4,a4,16
	li	a3,640
	li	a1,0
	li	a0,42
	call	gpu_rectangle
	j	.L152
.L213:
	slli	a5,a4,4
	sub	a4,a5,a4
	slli	a4,a4,1
	lw	a5,32(sp)
	add	a4,a5,a4
	add	a3,a4,a3
	lbu	a4,1260(a3)
	li	a5,32
	beq	a4,a5,.L162
	mv	a0,s6
	call	draw_pill
	j	.L162
.L163:
	addi	s0,s0,1
	addi	s2,s2,2
	addi	s1,s1,2
	li	a5,4
	beq	s0,a5,.L211
.L164:
	lhu	a5,%lo(level)(s4)
	bltu	a5,s0,.L163
	lh	a5,0(s11)
	mul	a5,a5,s7
	add	a5,a5,s5
	lhu	a4,0(s1)
	bne	a5,a4,.L163
	lh	a5,0(s10)
	mul	a5,a5,s7
	lw	a4,24(sp)
	add	a5,a5,a4
	lhu	a4,0(s2)
	bne	a5,a4,.L163
	lw	a2,12(sp)
	slli	a1,s0,16
	srli	a1,a1,16
	mv	a0,s6
	call	draw_ghost
	j	.L163
.L211:
	mv	a3,s6
	lw	a2,12(sp)
	lw	a1,20(sp)
	lw	a0,16(sp)
	call	whatisleft
	li	a5,69
	beq	a0,a5,.L165
	bgtu	a0,a5,.L166
	li	a5,32
	beq	a0,a5,.L167
	li	a5,35
	bne	a0,a5,.L169
	lw	a1,28(sp)
	li	a0,21
	call	left_wall
	j	.L169
.L166:
	li	a5,88
	bne	a0,a5,.L169
	lw	a1,28(sp)
	li	a0,60
	call	left_wall
.L169:
	mv	a3,s6
	lw	a2,12(sp)
	lw	a1,20(sp)
	lw	a0,16(sp)
	call	whatisright
	li	a5,69
	beq	a0,a5,.L170
	bgtu	a0,a5,.L171
	li	a5,32
	beq	a0,a5,.L172
	li	a5,35
	bne	a0,a5,.L174
	mv	a1,s6
	li	a0,21
	call	right_wall
	j	.L174
.L167:
	lh	a2,0(s9)
	li	a4,480
	sub	a4,a4,a2
	slli	a4,a4,16
	srai	a4,a4,16
	lh	a3,0(s8)
	li	a1,0
	li	a0,42
	call	gpu_rectangle
	j	.L169
.L165:
	lw	a1,28(sp)
	li	a0,51
	call	left_wall
	j	.L169
.L171:
	li	a5,88
	bne	a0,a5,.L174
	mv	a1,s6
	li	a0,60
	call	right_wall
.L174:
	addi	s3,s3,-1
	addi	s8,s8,-2
	addi	s9,s9,-2
	slli	a5,s3,16
	blt	a5,zero,.L212
.L175:
	slli	s6,s3,16
	srli	s6,s6,16
	slli	a5,s3,16
	srai	a5,a5,16
	sw	a5,28(sp)
	mv	s7,s3
	lw	a5,36(sp)
	lw	a4,40(sp)
	add	a5,a5,a4
	lh	a4,0(a5)
	mul	a4,a4,s3
	add	a4,a4,s5
	lw	a5,48(sp)
	lh	a3,0(a5)
	mul	a3,a3,s3
	lw	a5,24(sp)
	add	a3,a3,a5
	slli	a5,a4,4
	sub	a5,a5,a4
	slli	a5,a5,1
	lw	a2,32(sp)
	add	a5,a2,a5
	add	a5,a5,a3
	lbu	a2,0(a5)
	li	a5,32
	beq	a2,a5,.L213
.L162:
	lui	a5,%hi(ghosty)
	addi	s2,a5,%lo(ghosty)
	lui	s1,%hi(ghostx)
	addi	s1,s1,%lo(ghostx)
	li	s0,0
	lui	s4,%hi(level)
	lw	a5,44(sp)
	lw	a4,52(sp)
	add	s10,a5,a4
	j	.L164
.L172:
	lh	a2,0(s9)
	li	a4,480
	sub	a4,a4,a2
	lhu	a5,0(s8)
	li	a1,640
	sub	a1,a1,a5
	slli	a4,a4,16
	srai	a4,a4,16
	li	a3,640
	slli	a1,a1,16
	srai	a1,a1,16
	li	a0,42
	call	gpu_rectangle
	j	.L174
.L170:
	mv	a1,s6
	li	a0,51
	call	right_wall
	j	.L174
.L212:
	lw	s11,16(sp)
	lw	s10,20(sp)
	lw	s7,68(sp)
	mv	a6,s7
	li	a5,1
	lw	s6,56(sp)
	mv	a4,s6
	mv	a3,s10
	mv	a2,s11
	lw	a1,64(sp)
	lw	a0,60(sp)
	call	draw_map
	mv	s2,s6
	mv	s1,s10
	mv	s0,s11
	lw	a5,12(sp)
	slli	a5,a5,1
	lw	a4,36(sp)
	add	s4,a4,a5
	lui	s3,%hi(directiony)
	addi	s3,s3,%lo(directiony)
	add	s3,s3,a5
	lw	s8,24(sp)
	lw	s9,32(sp)
	j	.L193
.L215:
	beq	s2,zero,.L196
	addi	s2,s2,-1
	slli	s2,s2,16
	srli	s2,s2,16
.L178:
	call	get_buttons
	andi	a0,a0,32
	bne	a0,zero,.L178
	j	.L176
.L196:
	li	s2,3
	j	.L178
.L216:
	li	a5,3
	beq	s2,a5,.L197
	addi	s2,s2,1
	slli	s2,s2,16
	srli	s2,s2,16
.L181:
	call	get_buttons
	andi	a0,a0,64
	bne	a0,zero,.L181
	j	.L179
.L197:
	li	s2,0
	j	.L181
.L217:
	lh	a3,0(s4)
	lh	a4,0(s3)
	add	a2,a3,s5
	slli	a5,a2,4
	sub	a5,a5,a2
	slli	a5,a5,1
	add	a5,s9,a5
	add	a5,a5,s8
	add	a5,a5,a4
	lbu	a5,0(a5)
	li	a2,32
	beq	a5,a2,.L183
	li	a2,88
	bne	a5,a2,.L185
.L183:
	add	s0,s0,a3
	slli	s0,s0,16
	srli	s0,s0,16
	add	s1,s1,a4
	slli	s1,s1,16
	srli	s1,s1,16
.L185:
	call	get_buttons
	andi	a0,a0,8
	bne	a0,zero,.L185
	j	.L182
.L218:
	lh	a3,0(s4)
	lh	a4,0(s3)
	sub	a2,s5,a3
	sub	a1,s8,a4
	slli	a5,a2,4
	sub	a5,a5,a2
	slli	a5,a5,1
	add	a5,s9,a5
	add	a5,a5,a1
	lbu	a5,0(a5)
	li	a2,32
	beq	a5,a2,.L187
	li	a2,88
	bne	a5,a2,.L189
.L187:
	sub	s0,s0,a3
	slli	s0,s0,16
	srli	s0,s0,16
	sub	s1,s1,a4
	slli	s1,s1,16
	srli	s1,s1,16
.L189:
	call	get_buttons
	andi	a0,a0,16
	bne	a0,zero,.L189
	j	.L186
.L190:
	bne	s0,s11,.L198
	bne	s1,s10,.L199
	bne	s6,s2,.L214
.L193:
	call	get_buttons
	andi	a0,a0,32
	bne	a0,zero,.L215
.L176:
	call	get_buttons
	andi	a0,a0,64
	bne	a0,zero,.L216
.L179:
	call	get_buttons
	andi	a0,a0,8
	bne	a0,zero,.L217
.L182:
	call	get_buttons
	andi	a0,a0,16
	bne	a0,zero,.L218
.L186:
	call	get_buttons
	andi	a0,a0,4
	beq	a0,zero,.L190
	beq	s7,zero,.L190
	mv	a6,s7
	li	a5,0
	mv	a4,s6
	mv	a3,s10
	mv	a2,s11
	lw	a1,64(sp)
	lw	a0,60(sp)
	call	draw_map
.L191:
	call	get_buttons
	andi	a0,a0,4
	bne	a0,zero,.L191
	addi	s7,s7,-1
	slli	s7,s7,16
	srli	s7,s7,16
	mv	a6,s7
	li	a5,1
	mv	a4,s6
	mv	a3,s10
	mv	a2,s11
	lw	a1,64(sp)
	lw	a0,60(sp)
	call	draw_map
	j	.L190
.L214:
	sw	s7,68(sp)
	li	s3,0
	j	.L192
.L198:
	sw	s7,68(sp)
	li	s3,0
.L192:
	lui	s5,%hi(level)
	li	s4,4
	j	.L200
.L199:
	sw	s7,68(sp)
	li	s3,0
	j	.L192
.L194:
	addi	s3,s3,1
	slli	s3,s3,16
	srli	s3,s3,16
	beq	s3,s4,.L219
.L200:
	lhu	a5,%lo(level)(s5)
	bltu	a5,s3,.L194
	mv	a0,s3
	call	move_ghost
	j	.L194
.L219:
	sw	s2,56(sp)
	mv	s10,s1
	mv	s11,s0
.L151:
	mv	s5,s11
	lw	a5,60(sp)
	addi	a5,a5,-2
	bne	s11,a5,.L195
	lw	a5,64(sp)
	addi	a5,a5,-3
	beq	s10,a5,.L220
.L195:
	sw	s10,24(sp)
	slli	a5,s5,4
	sub	a5,a5,s5
	slli	a5,a5,1
	lw	s0,32(sp)
	add	a5,s0,a5
	add	a5,a5,s10
	li	a4,32
	sb	a4,1260(a5)
	call	tpu_cs
	call	gpu_cs
	lw	s1,56(sp)
	mv	a2,s1
	mv	a1,s10
	mv	a0,s11
	call	counttowall
	mv	s3,a0
	li	a5,15
	bgtu	a0,a5,.L152
	slli	a3,s1,1
	lw	a5,36(sp)
	add	a5,a5,a3
	lh	a5,0(a5)
	mul	a5,a5,a0
	add	a4,a5,s5
	lui	a5,%hi(directiony)
	addi	a5,a5,%lo(directiony)
	add	a5,a5,a3
	lh	a5,0(a5)
	mul	a3,a5,a0
	slli	a5,a4,4
	sub	a5,a5,a4
	slli	a5,a5,1
	add	a5,s0,a5
	add	a5,a5,s10
	add	a5,a5,a3
	lbu	a5,0(a5)
	li	a4,69
	beq	a5,a4,.L153
	li	a4,88
	beq	a5,a4,.L154
	li	a4,35
	beq	a5,a4,.L221
.L152:
	li	a5,15
	ble	s3,a5,.L161
	li	s3,15
.L161:
	slli	s3,s3,16
	srai	s3,s3,16
	addi	a5,s3,1
	slli	a5,a5,16
	srai	a5,a5,16
	slli	a5,a5,1
	lw	a4,72(sp)
	add	s8,a4,a5
	lw	a4,76(sp)
	add	s9,a4,a5
	lw	a5,56(sp)
	sw	a5,12(sp)
	slli	a3,a5,1
	sw	a3,40(sp)
	lui	a5,%hi(directiony)
	addi	a5,a5,%lo(directiony)
	sw	a5,44(sp)
	add	a5,a5,a3
	sw	a5,48(sp)
	sw	a3,52(sp)
	lw	a4,36(sp)
	add	a5,a4,a3
	sw	s11,16(sp)
	sw	s10,20(sp)
	mv	s11,a5
	j	.L175
.L220:
	lw	ra,140(sp)
	lw	s0,136(sp)
	lw	s1,132(sp)
	lw	s2,128(sp)
	lw	s3,124(sp)
	lw	s4,120(sp)
	lw	s5,116(sp)
	lw	s6,112(sp)
	lw	s7,108(sp)
	lw	s8,104(sp)
	lw	s9,100(sp)
	lw	s10,96(sp)
	lw	s11,92(sp)
	addi	sp,sp,144
	jr	ra
	.size	walk_maze, .-walk_maze
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"Select Level"
	.align	2
.LC1:
	.string	"Level: "
	.align	2
.LC2:
	.string	"Size: "
	.align	2
.LC3:
	.string	" x "
	.align	2
.LC4:
	.string	"Release FIRE!"
	.align	2
.LC5:
	.string	"Press FIRE to restart!"
	.align	2
.LC6:
	.string	"Generating Maze - Best to take notes!"
	.align	2
.LC7:
	.string	"Press FIRE to walk the maze!"
	.text
	.align	1
	.globl	main
	.type	main, @function
main:
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
	lui	s6,%hi(.LC0)
	lui	s5,%hi(.LC1)
	lui	s1,%hi(level)
	lui	s4,%hi(.LC2)
	lui	s2,%hi(.LANCHOR1)
	addi	s2,s2,%lo(.LANCHOR1)
	lui	s3,%hi(.LC3)
	lui	s7,%hi(.LC6)
	j	.L238
.L225:
	call	get_buttons
	andi	a0,a0,32
	bne	a0,zero,.L225
	lhu	a5,%lo(level)(s1)
	mv	a4,s9
	beq	a5,zero,.L226
	addi	a5,a5,-1
	slli	a4,a5,16
	srli	a4,a4,16
.L226:
	sh	a4,%lo(level)(s1)
	j	.L224
.L228:
	call	get_buttons
	andi	a0,a0,64
	bne	a0,zero,.L228
	lhu	a5,%lo(level)(s1)
	li	a4,0
	bgtu	a5,s8,.L229
	addi	a5,a5,1
	slli	a4,a5,16
	srli	a4,a4,16
.L229:
	sh	a4,%lo(level)(s1)
	j	.L227
.L237:
	sh	a4,%lo(level)(s1)
.L238:
	call	gpu_cs
	call	tpu_cs
	li	a0,0
	call	terminal_showhide
	li	a2,4
	li	a1,0
	li	a0,0
	call	set_background
	li	s9,4
	li	s8,3
.L230:
	addi	a3,s6,%lo(.LC0)
	li	a2,60
	li	a1,64
	li	a0,29
	call	tpu_outputstringcentre
	li	a3,0
	li	a2,64
	li	a1,29
	li	a0,1
	call	tpu_set
	addi	a0,s5,%lo(.LC1)
	call	tpu_outputstring
	lhu	a0,%lo(level)(s1)
	call	tpu_outputnumber_short
	li	a3,0
	li	a2,64
	li	a1,29
	li	a0,60
	call	tpu_set
	addi	a0,s4,%lo(.LC2)
	call	tpu_outputstring
	lhu	a5,%lo(level)(s1)
	slli	a5,a5,1
	add	a5,s2,a5
	lhu	a0,72(a5)
	call	tpu_outputnumber_short
	addi	a0,s3,%lo(.LC3)
	call	tpu_outputstring
	lhu	a5,%lo(level)(s1)
	slli	a5,a5,1
	add	a5,s2,a5
	lhu	a0,92(a5)
	call	tpu_outputnumber_short
	li	s0,1
.L223:
	call	get_buttons
	beq	a0,s0,.L223
	call	get_buttons
	andi	a0,a0,32
	bne	a0,zero,.L225
.L224:
	call	get_buttons
	andi	a0,a0,64
	bne	a0,zero,.L228
.L227:
	call	get_buttons
	andi	a0,a0,2
	beq	a0,zero,.L230
.L231:
	call	get_buttons
	andi	a0,a0,2
	bne	a0,zero,.L231
	addi	a3,s7,%lo(.LC6)
	li	a2,60
	li	a1,64
	li	a0,29
	call	tpu_outputstringcentre
	lhu	a5,%lo(level)(s1)
	slli	a5,a5,1
	add	a5,s2,a5
	lhu	a1,92(a5)
	lhu	a0,72(a5)
	call	initialise_maze
	lhu	a5,%lo(level)(s1)
	slli	a5,a5,1
	add	a5,s2,a5
	lhu	a2,112(a5)
	lhu	a1,92(a5)
	lhu	a0,72(a5)
	call	generate_maze
	lhu	a5,%lo(level)(s1)
	slli	a5,a5,1
	add	a5,s2,a5
	li	a3,1
	li	a2,1
	lhu	a1,92(a5)
	lhu	a0,72(a5)
	call	display_maze
	lui	a3,%hi(.LC7)
	addi	a3,a3,%lo(.LC7)
	li	a2,12
	li	a1,64
	li	a0,29
	call	tpu_outputstringcentre
.L233:
	call	get_buttons
	andi	a0,a0,2
	beq	a0,zero,.L233
	lui	a3,%hi(.LC4)
	addi	a3,a3,%lo(.LC4)
	li	a2,19
	li	a1,64
	li	a0,29
	call	tpu_outputstringcentre
.L234:
	call	get_buttons
	andi	a0,a0,2
	bne	a0,zero,.L234
	li	a2,1
	li	a1,8
	li	a0,2
	call	set_background
	lhu	a5,%lo(level)(s1)
	slli	a5,a5,1
	add	a5,s2,a5
	lhu	a1,92(a5)
	lhu	a0,72(a5)
	call	walk_maze
	li	a2,6
	li	a1,0
	li	a0,0
	call	set_background
	lui	a3,%hi(.LC5)
	addi	a3,a3,%lo(.LC5)
	li	a2,12
	li	a1,64
	li	a0,29
	call	tpu_outputstringcentre
.L235:
	call	get_buttons
	andi	a0,a0,2
	beq	a0,zero,.L235
	lui	a3,%hi(.LC4)
	addi	a3,a3,%lo(.LC4)
	li	a2,19
	li	a1,64
	li	a0,29
	call	tpu_outputstringcentre
.L236:
	call	get_buttons
	andi	a0,a0,2
	bne	a0,zero,.L236
	lhu	a5,%lo(level)(s1)
	li	a3,3
	li	a4,0
	bgtu	a5,a3,.L237
	addi	a5,a5,1
	slli	a4,a5,16
	srli	a4,a4,16
	j	.L237
	.size	main, .-main
	.globl	ghostdirection
	.globl	ghosty
	.globl	ghostx
	.globl	map
	.globl	maze
	.globl	rightdirectiony
	.globl	leftdirectiony
	.globl	directiony
	.globl	rightdirectionx
	.globl	leftdirectionx
	.globl	directionx
	.globl	perspectivey
	.globl	perspectivex
	.globl	levelgenerationsteps
	.globl	levelheights
	.globl	levelwidths
	.globl	level
	.data
	.align	2
	.set	.LANCHOR1,. + 0
	.type	perspectivex, @object
	.size	perspectivex, 34
perspectivex:
	.half	0
	.half	20
	.half	40
	.half	60
	.half	80
	.half	100
	.half	120
	.half	140
	.half	160
	.half	180
	.half	200
	.half	220
	.half	240
	.half	260
	.half	280
	.half	300
	.half	320
	.zero	2
	.type	perspectivey, @object
	.size	perspectivey, 34
perspectivey:
	.half	0
	.half	15
	.half	30
	.half	45
	.half	60
	.half	75
	.half	90
	.half	105
	.half	120
	.half	135
	.half	150
	.half	165
	.half	180
	.half	195
	.half	210
	.half	225
	.half	240
	.zero	2
	.type	levelwidths, @object
	.size	levelwidths, 18
levelwidths:
	.half	10
	.half	16
	.half	20
	.half	32
	.half	40
	.half	64
	.half	80
	.half	128
	.half	160
	.zero	2
	.type	levelheights, @object
	.size	levelheights, 18
levelheights:
	.half	8
	.half	12
	.half	16
	.half	24
	.half	30
	.half	48
	.half	60
	.half	80
	.half	120
	.zero	2
	.type	levelgenerationsteps, @object
	.size	levelgenerationsteps, 18
levelgenerationsteps:
	.half	1
	.half	1
	.half	1
	.half	2
	.half	4
	.half	16
	.half	32
	.half	64
	.half	128
	.bss
	.align	2
	.set	.LANCHOR0,. + 0
	.type	maze, @object
	.size	maze, 1260
maze:
	.zero	1260
	.type	map, @object
	.size	map, 1260
map:
	.zero	1260
	.section	.sbss,"aw",@nobits
	.align	2
	.type	ghostdirection, @object
	.size	ghostdirection, 8
ghostdirection:
	.zero	8
	.type	ghosty, @object
	.size	ghosty, 8
ghosty:
	.zero	8
	.type	ghostx, @object
	.size	ghostx, 8
ghostx:
	.zero	8
	.type	level, @object
	.size	level, 2
level:
	.zero	2
	.section	.sdata,"aw"
	.align	2
	.type	rightdirectiony, @object
	.size	rightdirectiony, 8
rightdirectiony:
	.half	0
	.half	1
	.half	0
	.half	-1
	.type	leftdirectiony, @object
	.size	leftdirectiony, 8
leftdirectiony:
	.half	0
	.half	-1
	.half	0
	.half	1
	.type	directiony, @object
	.size	directiony, 8
directiony:
	.half	-1
	.half	0
	.half	1
	.half	0
	.type	rightdirectionx, @object
	.size	rightdirectionx, 8
rightdirectionx:
	.half	1
	.half	0
	.half	-1
	.half	0
	.type	leftdirectionx, @object
	.size	leftdirectionx, 8
leftdirectionx:
	.half	-1
	.half	0
	.half	1
	.half	0
	.type	directionx, @object
	.size	directionx, 8
directionx:
	.half	0
	.half	1
	.half	0
	.half	-1
	.ident	"GCC: (Arch Linux Repositories) 10.2.0"
