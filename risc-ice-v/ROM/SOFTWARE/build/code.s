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
	lui	a2,%hi(maze)
	addi	a6,a2,%lo(maze)
	addi	a4,a1,-1
	slli	a4,a4,16
	srli	a4,a4,16
	addi	a5,a6,1
	add	a4,a4,a5
	addi	a5,a0,-1
	slli	a5,a5,16
	srli	a5,a5,16
	slli	a7,a5,4
	sub	a7,a7,a5
	slli	a7,a7,2
	addi	a5,a6,60
	add	a7,a7,a5
	addi	a2,a2,%lo(maze)
	li	a3,35
	j	.L3
.L4:
	sb	a3,0(a5)
	addi	a5,a5,1
	bne	a5,a4,.L4
.L6:
	addi	a2,a2,60
	addi	a4,a4,60
	beq	a2,a7,.L5
.L3:
	mv	a5,a2
	bne	a1,zero,.L4
	j	.L6
.L5:
	addi	a5,a1,-2
	lui	a4,%hi(maze)
	addi	a4,a4,%lo(maze)
	add	a5,a5,a4
	li	a4,42
.L7:
	sb	a4,0(a6)
	sb	a4,1(a5)
	sb	a4,0(a5)
	addi	a6,a6,60
	addi	a5,a5,60
	bne	a6,a7,.L7
.L2:
	beq	a1,zero,.L8
	lui	a4,%hi(maze)
	addi	a4,a4,%lo(maze)
	slli	a5,a0,4
	sub	a5,a5,a0
	slli	a5,a5,2
	add	a5,a5,a4
	addi	a2,a4,1
	addi	a3,a1,-1
	slli	a3,a3,16
	srli	a3,a3,16
	add	a2,a2,a3
	li	a3,42
.L9:
	sb	a3,0(a4)
	sb	a3,-60(a5)
	sb	a3,-120(a5)
	addi	a4,a4,1
	addi	a5,a5,1
	bne	a2,a4,.L9
.L8:
	lui	a5,%hi(maze)
	addi	a5,a5,%lo(maze)
	li	a4,69
	sb	a4,1(a5)
	addi	a0,a0,-2
	slli	a4,a0,4
	sub	a0,a4,a0
	slli	a4,a0,2
	add	a5,a5,a4
	add	a1,a5,a1
	li	a5,88
	sb	a5,-3(a1)
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
	beq	a0,zero,.L15
	mv	s7,a1
	mv	s6,a2
	li	s2,0
	lui	a5,%hi(maze)
	addi	a5,a5,%lo(maze)
	sw	a5,12(sp)
	sw	zero,8(sp)
	li	s5,0
	addi	a5,a3,-1
	sw	a5,28(sp)
	li	s4,42
	addi	s8,s11,-1
	j	.L17
.L30:
	lw	a5,16(sp)
	bne	a5,s1,.L18
	li	s2,12
	j	.L19
.L31:
	beq	a5,s9,.L26
	li	a4,35
	bne	a5,a4,.L19
	li	s2,3
.L19:
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
	beq	s1,s7,.L23
.L21:
	beq	s6,s5,.L30
.L18:
	lbu	a5,0(s3)
	beq	a5,s4,.L25
	bleu	a5,s4,.L31
	li	a4,69
	beq	a5,a4,.L27
	bne	a5,s10,.L19
	li	s2,60
	j	.L19
.L25:
	li	s2,48
	j	.L19
.L26:
	li	s2,63
	j	.L19
.L27:
	li	s2,51
	j	.L19
.L23:
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
	addi	a5,a5,60
	sw	a5,12(sp)
	lw	a5,24(sp)
	beq	a5,s5,.L15
.L17:
	beq	s7,zero,.L23
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
	li	s10,88
	li	s9,32
	j	.L21
.L15:
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
	sw	a1,8(sp)
	addi	a0,a0,-2
	slli	a0,a0,16
	srli	a0,a0,16
	call	rng
	mv	s1,a0
	andi	a5,a0,1
	bne	a5,zero,.L33
	addi	s1,a0,1
	slli	s1,s1,16
	srli	s1,s1,16
.L33:
	lw	a5,8(sp)
	addi	a0,a5,-2
	slli	a0,a0,16
	srli	a0,a0,16
	call	rng
	mv	s2,a0
	andi	a5,a0,1
	bne	a5,zero,.L34
	addi	s2,a0,1
	slli	s2,s2,16
	srli	s2,s2,16
.L34:
	lui	a5,%hi(maze)
	slli	a4,s1,4
	sub	a4,a4,s1
	slli	a4,a4,2
	addi	a5,a5,%lo(maze)
	add	a5,a5,a4
	add	a5,a5,s2
	li	a4,32
	sb	a4,0(a5)
	li	s10,32
	lw	a5,8(sp)
	addi	s5,a5,-1
	lw	a5,12(sp)
	addi	s11,a5,-1
	lui	s7,%hi(maze)
	addi	s7,s7,%lo(maze)
	j	.L49
.L36:
	mv	s2,s4
	mv	s1,s3
	bne	a0,s9,.L40
	bleu	s4,s6,.L40
	addi	s2,s4,-2
	slli	s2,s2,16
	srli	s2,s2,16
	j	.L40
.L64:
	addi	a5,s3,2
	bge	a5,s11,.L50
	slli	s1,a5,16
	srli	s1,s1,16
	mv	s2,s4
	j	.L40
.L35:
	bleu	s3,s6,.L52
	addi	s1,s3,-2
	slli	s1,s1,16
	srli	s1,s1,16
	mv	s2,s4
	j	.L40
.L50:
	mv	s2,s4
	mv	s1,s3
.L40:
	slli	a5,s1,4
	sub	a5,a5,s1
	slli	a5,a5,2
	add	a5,s7,a5
	add	a5,a5,s2
	lbu	a5,0(a5)
	beq	a5,s8,.L62
.L41:
	addi	s0,s0,-1
	slli	s0,s0,16
	srli	s0,s0,16
	beq	s0,zero,.L63
	mv	s4,s2
	mv	s3,s1
.L42:
	li	a0,4
	call	rng
	beq	a0,s6,.L35
	bgtu	a0,s6,.L36
	beq	a0,zero,.L64
	addi	a5,s4,2
	bge	a5,s5,.L51
	slli	s2,a5,16
	srli	s2,s2,16
	mv	s1,s3
	j	.L40
.L51:
	mv	s2,s4
	mv	s1,s3
	j	.L40
.L52:
	mv	s2,s4
	mv	s1,s3
	j	.L40
.L62:
	slli	a5,s1,4
	sub	a5,a5,s1
	slli	a5,a5,2
	add	a5,s7,a5
	add	a5,a5,s2
	sb	s10,0(a5)
	add	s3,s3,s1
	srli	a5,s3,31
	add	a5,a5,s3
	srai	s3,a5,1
	add	a5,s4,s2
	srli	s4,a5,31
	add	s4,s4,a5
	srai	s4,s4,1
	slli	a5,s3,4
	sub	a5,a5,s3
	slli	a5,a5,2
	add	a5,s7,a5
	add	a5,a5,s4
	sb	s10,0(a5)
	j	.L41
.L63:
	li	a5,1
	ble	s11,a5,.L32
	li	a6,1
	li	a1,1
	li	a7,1
	li	a0,1
	li	a2,35
	j	.L43
.L45:
	addi	a5,a5,2
	slli	a5,a5,16
	srli	a5,a5,16
	mv	a4,a5
	bge	a5,s5,.L48
.L46:
	add	a4,a3,a4
	lbu	a4,0(a4)
	bne	a4,a2,.L45
	mv	a6,s0
	j	.L45
.L48:
	addi	a1,a1,2
	slli	a1,a1,16
	srli	a1,a1,16
	mv	a7,a1
	bge	a1,s11,.L65
.L43:
	mv	a5,a0
	mv	a4,a0
	ble	s5,a0,.L48
	slli	a3,a7,4
	sub	a3,a3,a7
	slli	a3,a3,2
	add	a3,s7,a3
	j	.L46
.L65:
	bne	a6,zero,.L32
.L49:
	mv	a3,s2
	mv	a2,s1
	lw	a1,8(sp)
	lw	a0,12(sp)
	call	display_maze
	mv	s4,s2
	mv	s3,s1
	mv	s0,s10
	li	s6,2
	li	s9,3
	li	s8,35
	j	.L42
.L32:
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
	.string	"        Press FIRE to restart!       "
	.align	2
.LC5:
	.string	"       Release FIRE to restart!      "
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
	li	s0,0
	lui	s1,%hi(.LANCHOR0)
	addi	s1,s1,%lo(.LANCHOR0)
	lui	s8,%hi(.LC0)
	lui	s7,%hi(.LC1)
	lui	s6,%hi(.LC2)
	lui	s5,%hi(.LC3)
	lui	s4,%hi(.LC4)
	lui	s3,%hi(.LC5)
	li	s2,5
	j	.L67
.L71:
	li	s0,0
.L67:
	call	tpu_cs
	li	a0,0
	call	terminal_showhide
	slli	s9,s0,1
	add	s9,s1,s9
	lhu	a1,0(s9)
	lhu	a0,20(s9)
	call	initialise_maze
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
	lhu	a0,20(s9)
	call	tpu_outputnumber_short
	addi	a0,s5,%lo(.LC3)
	call	tpu_outputstring
	lhu	a0,0(s9)
	call	tpu_outputnumber_short
	lhu	a1,0(s9)
	lhu	a0,20(s9)
	call	generate_maze
	li	a3,1
	li	a2,1
	lhu	a1,0(s9)
	lhu	a0,20(s9)
	call	display_maze
	li	a3,12
	li	a2,64
	li	a1,29
	li	a0,21
	call	tpu_set
	addi	a0,s4,%lo(.LC4)
	call	tpu_outputstring
.L68:
	call	get_buttons
	andi	a0,a0,2
	beq	a0,zero,.L68
	li	a3,19
	li	a2,64
	li	a1,29
	li	a0,21
	call	tpu_set
	addi	a0,s3,%lo(.LC5)
	call	tpu_outputstring
.L69:
	call	get_buttons
	andi	a0,a0,2
	bne	a0,zero,.L69
	call	tpu_cs
	bgtu	s0,s2,.L71
	addi	s0,s0,1
	slli	s0,s0,16
	srli	s0,s0,16
	j	.L67
	.size	main, .-main
	.globl	maze
	.globl	levelheights
	.globl	levelwidths
	.data
	.align	2
	.set	.LANCHOR0,. + 0
	.type	levelheights, @object
	.size	levelheights, 18
levelheights:
	.half	8
	.half	12
	.half	16
	.half	24
	.half	32
	.half	48
	.half	60
	.half	80
	.half	120
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
	.bss
	.align	2
	.type	maze, @object
	.size	maze, 4800
maze:
	.zero	4800
	.ident	"GCC: (Arch Linux Repositories) 10.2.0"
