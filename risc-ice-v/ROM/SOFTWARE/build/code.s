	.file	"maze.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	1
	.globl	initialise_maze
	.type	initialise_maze, @function
initialise_maze:
	beq	a0,zero,.L2
	lui	a6,%hi(.LANCHOR0)
	addi	a6,a6,%lo(.LANCHOR0)
	addi	t1,a1,-1
	slli	t1,t1,16
	srli	t1,t1,16
	addi	a2,a6,1201
	add	a2,a2,t1
	addi	a5,a0,-1
	slli	a5,a5,16
	srli	a5,a5,16
	slli	a7,a5,4
	sub	a7,a7,a5
	slli	a7,a7,1
	addi	a5,a6,30
	add	a7,a7,a5
	not	t1,t1
	li	a3,35
	j	.L3
.L4:
	sb	a3,0(a5)
	sb	a3,0(a4)
	addi	a5,a5,1
	addi	a4,a4,1
	bne	a5,a2,.L4
.L6:
	addi	a6,a6,30
	addi	a2,a2,30
	beq	a6,a7,.L2
.L3:
	add	a5,t1,a2
	mv	a4,a6
	bne	a1,zero,.L4
	j	.L6
.L2:
	lui	a5,%hi(.LANCHOR0)
	addi	a5,a5,%lo(.LANCHOR0)
	li	a4,69
	sb	a4,1201(a5)
	sb	a4,1(a5)
	addi	a4,a0,-2
	addi	a1,a1,-3
	slli	a2,a4,4
	sub	a3,a2,a4
	slli	a3,a3,1
	add	a3,a5,a3
	add	a3,a3,a1
	li	a0,88
	sb	a0,1200(a3)
	sb	a0,0(a3)
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
	beq	a0,zero,.L9
	mv	s7,a1
	mv	s6,a2
	li	s2,0
	lui	a5,%hi(.LANCHOR0+1200)
	addi	a5,a5,%lo(.LANCHOR0+1200)
	sw	a5,12(sp)
	sw	zero,8(sp)
	li	s5,0
	addi	a5,a3,-1
	sw	a5,28(sp)
	li	s4,69
	addi	s8,s11,-1
	j	.L11
.L23:
	lw	a5,16(sp)
	bne	a5,s1,.L12
	li	s2,12
	j	.L13
.L24:
	bne	a5,s9,.L13
	li	s2,3
.L13:
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
	beq	s1,s7,.L17
.L15:
	beq	s6,s5,.L23
.L12:
	lbu	a5,0(s3)
	beq	a5,s4,.L19
	bgtu	a5,s4,.L14
	bne	a5,s10,.L24
	li	s2,63
	j	.L13
.L14:
	li	a4,88
	bne	a5,a4,.L13
	li	s2,60
	j	.L13
.L19:
	li	s2,51
	j	.L13
.L17:
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
	beq	a5,s5,.L9
.L11:
	beq	s7,zero,.L17
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
	j	.L15
.L9:
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
	bne	a5,zero,.L26
	addi	s2,a0,1
	slli	s2,s2,16
	srli	s2,s2,16
.L26:
	addi	a0,s11,-2
	slli	a0,a0,16
	srli	a0,a0,16
	call	rng
	mv	s3,a0
	andi	a5,a0,1
	bne	a5,zero,.L27
	addi	s3,a0,1
	slli	s3,s3,16
	srli	s3,s3,16
.L27:
	slli	a5,s2,4
	sub	a5,a5,s2
	slli	a4,a5,1
	lui	a5,%hi(.LANCHOR0)
	addi	a5,a5,%lo(.LANCHOR0)
	add	a5,a5,a4
	add	a5,a5,s3
	li	a4,32
	sb	a4,1200(a5)
	addi	s0,s11,-1
	lw	a5,12(sp)
	addi	s6,a5,-1
	lui	s4,%hi(.LANCHOR0)
	addi	s4,s4,%lo(.LANCHOR0)
	j	.L43
.L30:
	mv	a3,s3
	mv	a4,s2
	bne	a0,s9,.L34
	bleu	s3,s5,.L34
	addi	a3,s3,-2
	slli	a3,a3,16
	srli	a3,a3,16
	j	.L34
.L58:
	addi	a5,s2,2
	bge	a5,s6,.L44
	slli	a4,a5,16
	srli	a4,a4,16
	mv	a3,s3
.L34:
	slli	a5,a4,4
	sub	a5,a5,a4
	slli	a5,a5,1
	add	a5,s4,a5
	add	a5,a5,a3
	lbu	a5,1200(a5)
	beq	a5,s8,.L56
.L35:
	addi	s1,s1,1
	slli	s1,s1,16
	srli	s1,s1,16
	beq	s7,s1,.L57
	mv	s3,a3
	mv	s2,a4
.L36:
	li	a0,4
	call	rng
	beq	a0,s5,.L29
	bgtu	a0,s5,.L30
	beq	a0,zero,.L58
	addi	a5,s3,2
	bge	a5,s0,.L45
	slli	a3,a5,16
	srli	a3,a3,16
	mv	a4,s2
	j	.L34
.L29:
	bleu	s2,s5,.L46
	addi	a4,s2,-2
	slli	a4,a4,16
	srli	a4,a4,16
	mv	a3,s3
	j	.L34
.L44:
	mv	a3,s3
	mv	a4,s2
	j	.L34
.L45:
	mv	a3,s3
	mv	a4,s2
	j	.L34
.L46:
	mv	a3,s3
	mv	a4,s2
	j	.L34
.L56:
	slli	a5,a4,4
	sub	a5,a5,a4
	slli	a5,a5,1
	add	a5,s4,a5
	add	a5,a5,a3
	sb	s10,1200(a5)
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
	sb	s10,1200(a5)
	j	.L35
.L57:
	mv	s3,a3
	mv	s2,a4
.L28:
	li	a5,1
	ble	s6,a5,.L25
	li	a3,1
	li	a0,1
	li	a7,1
	li	a6,1
	li	a1,35
	j	.L37
.L40:
	add	a5,a2,a5
	lbu	a5,1200(a5)
	sub	a5,a5,a1
	snez	a5,a5
	neg	a5,a5
	and	a3,a3,a5
	addi	a4,a4,2
	slli	a4,a4,16
	srli	a4,a4,16
	mv	a5,a4
	blt	a4,s0,.L40
.L42:
	addi	a0,a0,2
	slli	a0,a0,16
	srli	a0,a0,16
	mv	a7,a0
	bge	a0,s6,.L59
.L37:
	mv	a4,a6
	mv	a5,a6
	ble	s0,a6,.L42
	slli	a2,a7,4
	sub	a2,a2,a7
	slli	a2,a2,1
	add	a2,s4,a2
	j	.L40
.L59:
	bne	a3,zero,.L25
.L43:
	mv	a3,s3
	mv	a2,s2
	mv	a1,s11
	lw	a0,12(sp)
	call	display_maze
	beq	s7,zero,.L28
	li	s1,0
	li	s5,2
	li	s9,3
	li	s8,35
	li	s10,32
	j	.L36
.L25:
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
	addi	sp,sp,-112
	sw	ra,108(sp)
	sw	s0,104(sp)
	sw	s1,100(sp)
	sw	s2,96(sp)
	sw	s3,92(sp)
	sw	s4,88(sp)
	sw	s5,84(sp)
	sw	s6,80(sp)
	sw	s7,76(sp)
	sw	s8,72(sp)
	sw	s9,68(sp)
	sw	s10,64(sp)
	sw	s11,60(sp)
	mv	s0,a0
	sw	a0,32(sp)
	mv	s7,a1
	mv	s8,a2
	sw	a3,24(sp)
	sw	a4,40(sp)
	mv	s6,a5
	sw	a6,44(sp)
	li	a5,160
	div	s1,a5,a0
	sw	s1,28(sp)
	li	a5,120
	div	s10,a5,a1
	li	a4,140
	li	a3,640
	li	a2,0
	li	a1,460
	li	a0,56
	call	gpu_rectangle
	sw	zero,20(sp)
	li	a5,475
	sw	a5,16(sp)
	beq	s0,zero,.L62
	li	s2,0
	li	s5,0
	addi	a5,s1,-1
	sw	a5,36(sp)
	li	s4,69
	lui	a5,%hi(.LANCHOR0)
	addi	a5,a5,%lo(.LANCHOR0)
	sw	a5,8(sp)
	addi	a5,a5,1200
	sw	a5,12(sp)
	addi	s11,s10,-1
	j	.L61
.L87:
	lw	a5,24(sp)
	bne	a5,s1,.L63
	li	s2,12
	j	.L64
.L65:
	lw	a5,12(sp)
	add	a5,a5,s3
	lbu	a5,0(a5)
.L66:
	beq	a5,s4,.L81
	bgt	a5,s4,.L67
	li	a4,32
	beq	a5,a4,.L82
	li	a4,35
	bne	a5,a4,.L64
	li	s2,3
.L64:
	addi	s1,s1,1
	slli	s1,s1,16
	srli	s1,s1,16
	add	a4,s0,s11
	slli	a4,a4,16
	srai	a4,a4,16
	lw	a3,4(sp)
	slli	a2,s0,16
	srai	a2,a2,16
	lw	a1,0(sp)
	mv	a0,s2
	call	gpu_rectangle
	add	s0,s10,s0
	slli	s0,s0,16
	srli	s0,s0,16
	addi	s3,s3,1
	beq	s1,s7,.L70
.L68:
	beq	s8,s5,.L87
.L63:
	beq	s6,zero,.L65
	lw	a5,8(sp)
	add	a5,a5,s3
	lbu	a5,0(a5)
	j	.L66
.L67:
	bne	a5,s9,.L64
	li	s2,60
	j	.L64
.L81:
	li	s2,51
	j	.L64
.L82:
	li	s2,63
	j	.L64
.L70:
	addi	s5,s5,1
	slli	s5,s5,16
	srli	s5,s5,16
	lw	a5,28(sp)
	lw	a4,16(sp)
	add	a5,a5,a4
	slli	a5,a5,16
	srli	a5,a5,16
	sw	a5,16(sp)
	lw	a5,20(sp)
	addi	a5,a5,30
	sw	a5,20(sp)
	lw	a5,32(sp)
	beq	a5,s5,.L62
.L61:
	beq	s7,zero,.L70
	lw	a5,16(sp)
	slli	a4,a5,16
	srai	a4,a4,16
	sw	a4,0(sp)
	lw	a4,36(sp)
	add	a5,a5,a4
	slli	a5,a5,16
	srai	a5,a5,16
	sw	a5,4(sp)
	lw	s3,20(sp)
	li	s0,10
	li	s1,0
	li	s9,88
	j	.L68
.L62:
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
	lw	a4,40(sp)
	beq	a4,a5,.L71
	bgtu	a4,a5,.L72
	beq	a4,zero,.L88
	li	a6,19
	li	a5,468
	li	a4,10
	li	a3,473
	li	a2,1
	li	a1,468
	li	a0,12
	call	gpu_triangle
	j	.L76
.L72:
	li	a5,3
	lw	a4,40(sp)
	bne	a4,a5,.L76
	li	a6,10
	li	a5,463
	li	a4,19
	li	a3,468
	li	a2,1
	li	a1,468
	li	a0,12
	call	gpu_triangle
	j	.L76
.L88:
	li	a6,10
	li	a5,463
	li	a4,10
	li	a3,473
	li	a2,1
	li	a1,468
	li	a0,12
	call	gpu_triangle
.L76:
	li	a5,1
	lw	a4,44(sp)
	beq	a4,a5,.L77
	li	a5,2
	bne	a4,a5,.L60
	li	a4,0
	li	a3,1
	li	a2,122
	li	a1,462
	li	a0,12
	call	gpu_character_blit
.L77:
	li	a4,0
	li	a3,1
	li	a2,130
	li	a1,462
	li	a0,12
	call	gpu_character_blit
.L60:
	lw	ra,108(sp)
	lw	s0,104(sp)
	lw	s1,100(sp)
	lw	s2,96(sp)
	lw	s3,92(sp)
	lw	s4,88(sp)
	lw	s5,84(sp)
	lw	s6,80(sp)
	lw	s7,76(sp)
	lw	s8,72(sp)
	lw	s9,68(sp)
	lw	s10,64(sp)
	lw	s11,60(sp)
	addi	sp,sp,112
	jr	ra
.L71:
	li	a6,10
	li	a5,463
	li	a4,19
	li	a3,468
	li	a2,10
	li	a1,473
	li	a0,12
	call	gpu_triangle
	j	.L76
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
.L90:
	mv	a4,t2
	slli	a5,a7,4
	sub	a5,a5,a7
	slli	a5,a5,1
	add	a5,t0,a5
	add	a5,a5,t1
.L91:
	bne	a4,zero,.L98
	lbu	a3,1200(a5)
	mv	a4,a6
	beq	a3,t5,.L91
	beq	a3,t4,.L91
	beq	a3,t3,.L91
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
	j	.L90
.L98:
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
	lbu	a0,1200(a5)
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
	lbu	a0,1200(a5)
	ret
	.size	whatisright, .-whatisright
	.align	1
	.globl	walk_maze
	.type	walk_maze, @function
walk_maze:
	addi	sp,sp,-112
	sw	ra,108(sp)
	sw	s0,104(sp)
	sw	s1,100(sp)
	sw	s2,96(sp)
	sw	s3,92(sp)
	sw	s4,88(sp)
	sw	s5,84(sp)
	sw	s6,80(sp)
	sw	s7,76(sp)
	sw	s8,72(sp)
	sw	s9,68(sp)
	sw	s10,64(sp)
	sw	s11,60(sp)
	sw	a0,36(sp)
	sw	a1,40(sp)
	li	a5,2
	sw	a5,24(sp)
	li	s4,1
	li	s2,1
	li	s3,1
	lui	a5,%hi(.LANCHOR0)
	addi	a5,a5,%lo(.LANCHOR0)
	sw	a5,28(sp)
	lui	s6,%hi(.LANCHOR1)
	addi	s6,s6,%lo(.LANCHOR1)
	lui	a5,%hi(directionx)
	addi	a5,a5,%lo(directionx)
	sw	a5,44(sp)
	j	.L154
.L105:
	slli	a5,a0,1
	add	a5,s6,a5
	lh	a2,0(a5)
	li	a4,480
	sub	a4,a4,a2
	slli	a4,a4,16
	srai	a4,a4,16
	li	a3,640
	li	a1,0
	li	a0,60
	call	gpu_rectangle
	li	a5,2
	beq	s0,a5,.L107
	li	a5,3
	beq	s0,a5,.L108
	li	a5,1
	bne	s0,a5,.L103
	li	a4,2
	li	a3,69
	li	a2,48
	li	a1,256
	li	a0,12
	call	gpu_character_blit
	li	a4,2
	li	a3,88
	li	a2,48
	li	a1,288
	li	a0,12
	call	gpu_character_blit
	li	a4,2
	li	a3,73
	li	a2,48
	li	a1,320
	li	a0,12
	call	gpu_character_blit
	li	a4,2
	li	a3,84
	li	a2,48
	li	a1,352
	li	a0,12
	call	gpu_character_blit
.L109:
	li	a5,8
	ble	s0,a5,.L141
	li	s0,8
.L141:
	slli	s0,s0,16
	srli	s0,s0,16
	j	.L142
.L107:
	li	a4,1
	li	a3,69
	li	a2,84
	li	a1,288
	li	a0,12
	call	gpu_character_blit
	li	a4,1
	li	a3,88
	li	a2,84
	li	a1,304
	li	a0,12
	call	gpu_character_blit
	li	a4,1
	li	a3,73
	li	a2,84
	li	a1,320
	li	a0,12
	call	gpu_character_blit
	li	a4,1
	li	a3,84
	li	a2,84
	li	a1,336
	li	a0,12
	call	gpu_character_blit
	j	.L109
.L108:
	li	a4,0
	li	a3,69
	li	a2,122
	li	a1,304
	li	a0,12
	call	gpu_character_blit
	li	a4,0
	li	a3,88
	li	a2,122
	li	a1,312
	li	a0,12
	call	gpu_character_blit
	li	a4,0
	li	a3,73
	li	a2,122
	li	a1,320
	li	a0,12
	call	gpu_character_blit
	li	a4,0
	li	a3,84
	li	a2,122
	li	a1,328
	li	a0,12
	call	gpu_character_blit
	j	.L109
.L104:
	slli	a5,a0,1
	add	a5,s6,a5
	lh	a2,0(a5)
	li	a4,480
	sub	a4,a4,a2
	slli	a4,a4,16
	srai	a4,a4,16
	li	a3,640
	li	a1,0
	li	a0,51
	call	gpu_rectangle
	j	.L103
.L163:
	slli	a5,a0,1
	add	a5,s6,a5
	lh	a2,0(a5)
	li	a4,480
	sub	a4,a4,a2
	slli	a4,a4,16
	srai	a4,a4,16
	li	a3,640
	li	a1,0
	li	a0,42
	call	gpu_rectangle
	j	.L103
.L113:
	bne	a0,s9,.L116
	addi	a5,s0,-1
	slli	a5,a5,1
	add	a5,s6,a5
	lh	a1,20(a5)
	lh	a2,0(a5)
	slli	a4,s0,1
	add	a4,s6,a4
	lh	a3,20(a4)
	lh	a4,0(a4)
	sub	a6,s5,a4
	sub	a0,s5,a2
	slli	a0,a0,16
	srai	a0,a0,16
	sw	a0,0(sp)
	mv	a7,a1
	slli	a6,a6,16
	srai	a6,a6,16
	mv	a5,a3
	li	a0,60
	call	gpu_quadrilateral
.L116:
	mv	a3,s0
	mv	a2,s4
	mv	a1,s2
	mv	a0,s3
	call	whatisright
	beq	a0,s1,.L117
	bgtu	a0,s1,.L118
	beq	a0,s8,.L119
	bne	a0,s7,.L121
	addi	a5,s0,-1
	slli	a5,a5,1
	add	a5,s6,a5
	lhu	a1,20(a5)
	sub	a1,s10,a1
	slli	a1,a1,16
	srai	a1,a1,16
	lh	a2,0(a5)
	slli	a4,s0,1
	add	a4,s6,a4
	lhu	a5,20(a4)
	sub	a5,s10,a5
	slli	a5,a5,16
	srai	a5,a5,16
	lh	a3,0(a4)
	sub	a6,s5,a3
	sub	a4,s5,a2
	sw	a3,0(sp)
	mv	a7,a5
	slli	a6,a6,16
	srai	a6,a6,16
	slli	a4,a4,16
	srai	a4,a4,16
	mv	a3,a1
	li	a0,21
	call	gpu_quadrilateral
	j	.L121
.L114:
	slli	a5,s0,1
	add	a5,s6,a5
	lh	a2,0(a5)
	sub	a4,s5,a2
	slli	a4,a4,16
	srai	a4,a4,16
	lh	a3,20(a5)
	li	a1,0
	li	a0,42
	call	gpu_rectangle
	j	.L116
.L112:
	addi	a5,s0,-1
	slli	a5,a5,1
	add	a5,s6,a5
	lh	a1,20(a5)
	lh	a2,0(a5)
	slli	a4,s0,1
	add	a4,s6,a4
	lh	a3,20(a4)
	lh	a4,0(a4)
	sub	a6,s5,a4
	sub	a0,s5,a2
	slli	a0,a0,16
	srai	a0,a0,16
	sw	a0,0(sp)
	mv	a7,a1
	slli	a6,a6,16
	srai	a6,a6,16
	mv	a5,a3
	li	a0,51
	call	gpu_quadrilateral
	j	.L116
.L118:
	bne	a0,s9,.L121
	addi	a5,s0,-1
	slli	a5,a5,1
	add	a5,s6,a5
	lhu	a1,20(a5)
	sub	a1,s10,a1
	slli	a1,a1,16
	srai	a1,a1,16
	lh	a2,0(a5)
	slli	a4,s0,1
	add	a4,s6,a4
	lhu	a5,20(a4)
	sub	a5,s10,a5
	slli	a5,a5,16
	srai	a5,a5,16
	lh	a3,0(a4)
	sub	a6,s5,a3
	sub	a4,s5,a2
	sw	a3,0(sp)
	mv	a7,a5
	slli	a6,a6,16
	srai	a6,a6,16
	slli	a4,a4,16
	srai	a4,a4,16
	mv	a3,a1
	li	a0,60
	call	gpu_quadrilateral
.L121:
	addi	s0,s0,-1
	slli	s0,s0,16
	srli	s0,s0,16
	beq	s0,zero,.L111
.L122:
	mv	a3,s0
	mv	a2,s4
	mv	a1,s2
	mv	a0,s3
	call	whatisleft
	beq	a0,s1,.L112
	bgtu	a0,s1,.L113
	beq	a0,s8,.L114
	bne	a0,s7,.L116
	addi	a5,s0,-1
	slli	a5,a5,1
	add	a5,s6,a5
	lh	a1,20(a5)
	lh	a2,0(a5)
	slli	a4,s0,1
	add	a4,s6,a4
	lh	a3,20(a4)
	lh	a4,0(a4)
	sub	a6,s5,a4
	sub	a0,s5,a2
	slli	a0,a0,16
	srai	a0,a0,16
	sw	a0,0(sp)
	mv	a7,a1
	slli	a6,a6,16
	srai	a6,a6,16
	mv	a5,a3
	li	a0,21
	call	gpu_quadrilateral
	j	.L116
.L119:
	slli	a5,s0,1
	add	a5,s6,a5
	lh	a2,0(a5)
	sub	a4,s5,a2
	lhu	a1,20(a5)
	sub	a1,s10,a1
	slli	a4,a4,16
	srai	a4,a4,16
	li	a3,640
	slli	a1,a1,16
	srai	a1,a1,16
	li	a0,42
	call	gpu_rectangle
	j	.L121
.L117:
	addi	a5,s0,-1
	slli	a5,a5,1
	add	a5,s6,a5
	lhu	a1,20(a5)
	sub	a1,s10,a1
	slli	a1,a1,16
	srai	a1,a1,16
	lh	a2,0(a5)
	slli	a4,s0,1
	add	a4,s6,a4
	lhu	a5,20(a4)
	sub	a5,s10,a5
	slli	a5,a5,16
	srai	a5,a5,16
	lh	a3,0(a4)
	sub	a6,s5,a3
	sub	a4,s5,a2
	sw	a3,0(sp)
	mv	a7,a5
	slli	a6,a6,16
	srai	a6,a6,16
	slli	a4,a4,16
	srai	a4,a4,16
	mv	a3,a1
	li	a0,51
	call	gpu_quadrilateral
	j	.L121
.L111:
	lw	a6,24(sp)
	li	a5,1
	mv	a4,s4
	mv	a3,s2
	mv	a2,s3
	lw	a1,40(sp)
	lw	a0,36(sp)
	call	draw_map
	mv	s0,s4
	mv	s5,s2
	mv	s1,s3
	slli	a5,s4,1
	lw	a4,44(sp)
	add	s8,a4,a5
	lui	s7,%hi(directiony)
	addi	s7,s7,%lo(directiony)
	add	s7,s7,a5
	j	.L139
.L158:
	beq	s0,zero,.L143
	addi	s0,s0,-1
	slli	s0,s0,16
	srli	s0,s0,16
.L125:
	call	get_buttons
	andi	a0,a0,32
	bne	a0,zero,.L125
	j	.L123
.L143:
	li	s0,3
	j	.L125
.L159:
	li	a5,3
	beq	s0,a5,.L144
	addi	s0,s0,1
	slli	s0,s0,16
	srli	s0,s0,16
.L128:
	call	get_buttons
	andi	a0,a0,64
	bne	a0,zero,.L128
	j	.L126
.L144:
	li	s0,0
	j	.L128
.L160:
	lh	a3,0(s8)
	lh	a4,0(s7)
	add	a2,a3,s11
	slli	a5,a2,4
	sub	a5,a5,a2
	slli	a5,a5,1
	lw	a2,28(sp)
	add	a5,a2,a5
	lw	a2,32(sp)
	add	a5,a5,a2
	add	a5,a5,a4
	lbu	a5,1200(a5)
	li	a2,32
	beq	a5,a2,.L130
	li	a2,88
	bne	a5,a2,.L132
.L130:
	add	s1,s1,a3
	slli	s1,s1,16
	srli	s1,s1,16
	add	s5,s5,a4
	slli	s5,s5,16
	srli	s5,s5,16
.L132:
	call	get_buttons
	andi	a0,a0,8
	bne	a0,zero,.L132
	j	.L129
.L161:
	lh	a3,0(s8)
	lh	a4,0(s7)
	sub	a2,s11,a3
	lw	a5,32(sp)
	sub	a1,a5,a4
	slli	a5,a2,4
	sub	a5,a5,a2
	slli	a5,a5,1
	lw	a2,28(sp)
	add	a5,a2,a5
	add	a5,a5,a1
	lbu	a5,1200(a5)
	li	a2,32
	beq	a5,a2,.L134
	li	a2,88
	bne	a5,a2,.L136
.L134:
	sub	s1,s1,a3
	slli	s1,s1,16
	srli	s1,s1,16
	sub	s5,s5,a4
	slli	s5,s5,16
	srli	s5,s5,16
.L136:
	call	get_buttons
	andi	a0,a0,16
	bne	a0,zero,.L136
	j	.L133
.L137:
	bne	s1,s3,.L145
	bne	s5,s2,.L146
	bne	s4,s0,.L157
.L139:
	call	get_buttons
	andi	a0,a0,32
	bne	a0,zero,.L158
.L123:
	call	get_buttons
	andi	a0,a0,64
	bne	a0,zero,.L159
.L126:
	call	get_buttons
	andi	a0,a0,8
	bne	a0,zero,.L160
.L129:
	call	get_buttons
	andi	a0,a0,16
	bne	a0,zero,.L161
.L133:
	call	get_buttons
	andi	a0,a0,4
	beq	a0,zero,.L137
	lw	a5,24(sp)
	beq	a5,zero,.L137
	mv	a6,a5
	li	a5,0
	mv	a4,s4
	mv	a3,s2
	mv	a2,s3
	lw	a1,40(sp)
	lw	a0,36(sp)
	call	draw_map
.L138:
	call	get_buttons
	andi	a0,a0,4
	bne	a0,zero,.L138
	lw	a5,24(sp)
	addi	a5,a5,-1
	slli	a5,a5,16
	srli	a5,a5,16
	sw	a5,24(sp)
	mv	a6,a5
	li	a5,1
	mv	a4,s4
	mv	a3,s2
	mv	a2,s3
	lw	a1,40(sp)
	lw	a0,36(sp)
	call	draw_map
	j	.L137
.L157:
	mv	s4,s0
	mv	s2,s5
	mv	s3,s1
	j	.L154
.L145:
	mv	s4,s0
	mv	s2,s5
	mv	s3,s1
.L154:
	mv	s11,s3
	lw	a5,36(sp)
	addi	a5,a5,-2
	bne	s3,a5,.L140
	lw	a5,40(sp)
	addi	a5,a5,-3
	beq	s2,a5,.L162
.L140:
	sw	s2,32(sp)
	slli	a5,s11,4
	sub	a5,a5,s11
	slli	a5,a5,1
	lw	s1,28(sp)
	add	a5,s1,a5
	add	a5,a5,s2
	li	a4,32
	sb	a4,0(a5)
	call	tpu_cs
	call	gpu_cs
	mv	a2,s4
	mv	a1,s2
	mv	a0,s3
	call	counttowall
	mv	s0,a0
	li	a5,8
	bgtu	a0,a5,.L103
	slli	a3,s4,1
	lw	a5,44(sp)
	add	a5,a5,a3
	lh	a5,0(a5)
	mul	a5,a5,a0
	add	a4,a5,s11
	lui	a5,%hi(directiony)
	addi	a5,a5,%lo(directiony)
	add	a5,a5,a3
	lh	a5,0(a5)
	mul	a3,a5,a0
	slli	a5,a4,4
	sub	a5,a5,a4
	slli	a5,a5,1
	add	a5,s1,a5
	add	a5,a5,s2
	add	a5,a5,a3
	lbu	a5,1200(a5)
	li	a4,69
	beq	a5,a4,.L104
	li	a4,88
	beq	a5,a4,.L105
	li	a4,35
	beq	a5,a4,.L163
.L103:
	li	a5,8
	ble	s0,a5,.L110
	li	s0,8
.L110:
	slli	s0,s0,16
	srli	s0,s0,16
	beq	s0,zero,.L111
.L142:
	li	s1,69
	li	s5,480
	li	s9,88
	li	s8,32
	li	s7,35
	li	s10,640
	j	.L122
.L146:
	mv	s4,s0
	mv	s2,s5
	mv	s3,s1
	j	.L154
.L162:
	lw	ra,108(sp)
	lw	s0,104(sp)
	lw	s1,100(sp)
	lw	s2,96(sp)
	lw	s3,92(sp)
	lw	s4,88(sp)
	lw	s5,84(sp)
	lw	s6,80(sp)
	lw	s7,76(sp)
	lw	s8,72(sp)
	lw	s9,68(sp)
	lw	s10,64(sp)
	lw	s11,60(sp)
	addi	sp,sp,112
	jr	ra
	.size	walk_maze, .-walk_maze
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"Generating Maze - Best to take notes!"
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
	.string	"     Press FIRE to walk the maze!    "
	.align	2
.LC5:
	.string	"             Release FIRE!           "
	.align	2
.LC6:
	.string	"        Press FIRE to restart!       "
	.align	2
.LC7:
	.string	"       Release FIRE!      "
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
	sw	s10,0(sp)
	li	s0,0
	lui	s8,%hi(.LC0)
	lui	s7,%hi(.LC1)
	lui	s6,%hi(.LC2)
	lui	s1,%hi(.LANCHOR1)
	addi	s1,s1,%lo(.LANCHOR1)
	lui	s5,%hi(.LC3)
	lui	s4,%hi(.LC4)
	lui	s3,%hi(.LC5)
	lui	s2,%hi(.LC6)
	j	.L165
.L171:
	li	s0,0
.L165:
	call	tpu_cs
	li	a0,0
	call	terminal_showhide
	li	a2,8
	li	a1,8
	li	a0,2
	call	set_background
	li	a3,60
	li	a2,64
	li	a1,29
	li	a0,21
	call	tpu_set
	addi	a0,s8,%lo(.LC0)
	call	tpu_outputstring
	li	a3,0
	li	a2,64
	li	a1,29
	li	a0,1
	call	tpu_set
	addi	a0,s7,%lo(.LC1)
	call	tpu_outputstring
	mv	a0,s0
	call	tpu_outputnumber_short
	li	a3,0
	li	a2,64
	li	a1,29
	li	a0,60
	call	tpu_set
	addi	a0,s6,%lo(.LC2)
	call	tpu_outputstring
	mv	s9,s0
	slli	s10,s0,1
	add	s10,s1,s10
	lhu	a0,40(s10)
	call	tpu_outputnumber_short
	addi	a0,s5,%lo(.LC3)
	call	tpu_outputstring
	lhu	a0,60(s10)
	call	tpu_outputnumber_short
	lhu	a1,60(s10)
	lhu	a0,40(s10)
	call	initialise_maze
	lhu	a2,80(s10)
	lhu	a1,60(s10)
	lhu	a0,40(s10)
	call	generate_maze
	li	a3,1
	li	a2,1
	lhu	a1,60(s10)
	lhu	a0,40(s10)
	call	display_maze
	li	a3,12
	li	a2,64
	li	a1,29
	li	a0,21
	call	tpu_set
	addi	a0,s4,%lo(.LC4)
	call	tpu_outputstring
.L166:
	call	get_buttons
	andi	a0,a0,2
	beq	a0,zero,.L166
	li	a3,19
	li	a2,64
	li	a1,29
	li	a0,21
	call	tpu_set
	addi	a0,s3,%lo(.LC5)
	call	tpu_outputstring
.L167:
	call	get_buttons
	andi	a0,a0,2
	bne	a0,zero,.L167
	slli	s9,s9,1
	add	s9,s1,s9
	lhu	a1,60(s9)
	lhu	a0,40(s9)
	call	walk_maze
	li	a2,6
	li	a1,8
	li	a0,2
	call	set_background
	li	a3,12
	li	a2,64
	li	a1,29
	li	a0,21
	call	tpu_set
	addi	a0,s2,%lo(.LC6)
	call	tpu_outputstring
.L168:
	call	get_buttons
	andi	a0,a0,2
	beq	a0,zero,.L168
	li	a3,19
	li	a2,64
	li	a1,29
	li	a0,21
	call	tpu_set
	lui	a0,%hi(.LC7)
	addi	a0,a0,%lo(.LC7)
	call	tpu_outputstring
.L169:
	call	get_buttons
	andi	a0,a0,2
	bne	a0,zero,.L169
	li	a5,3
	bgtu	s0,a5,.L171
	addi	s0,s0,1
	slli	s0,s0,16
	srli	s0,s0,16
	j	.L165
	.size	main, .-main
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
	.data
	.align	2
	.set	.LANCHOR1,. + 0
	.type	perspectivey, @object
	.size	perspectivey, 18
perspectivey:
	.half	0
	.half	30
	.half	60
	.half	90
	.half	120
	.half	150
	.half	180
	.half	210
	.half	240
	.zero	2
	.type	perspectivex, @object
	.size	perspectivex, 18
perspectivex:
	.half	0
	.half	40
	.half	80
	.half	120
	.half	160
	.half	200
	.half	240
	.half	280
	.half	320
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
	.type	map, @object
	.size	map, 1200
map:
	.zero	1200
	.type	maze, @object
	.size	maze, 1200
maze:
	.zero	1200
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
