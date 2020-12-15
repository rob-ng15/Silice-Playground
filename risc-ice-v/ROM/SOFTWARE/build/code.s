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
	lui	a2,%hi(maze)
	addi	a2,a2,%lo(maze)
	addi	a4,a2,60
	li	a5,4096
	addi	a5,a5,764
	add	a2,a2,a5
	li	a3,35
	j	.L2
.L6:
	addi	a4,a4,60
	beq	a4,a2,.L1
.L2:
	addi	a5,a4,-60
.L3:
	sb	a3,0(a5)
	addi	a5,a5,1
	bne	a5,a4,.L3
	j	.L6
.L1:
	ret
	.size	initialise_maze, .-initialise_maze
	.align	1
	.globl	display_maze
	.type	display_maze, @function
display_maze:
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
	lui	s1,%hi(maze)
	addi	s1,s1,%lo(maze)
	li	s10,4096
	addi	s10,s10,704
	add	s10,s1,s10
	li	s9,7
	li	s8,0
	li	s5,35
	li	s4,42
	li	s3,32
	li	s2,60
	j	.L8
.L10:
	slli	a2,s0,3
	slli	a2,a2,16
	srli	a2,a2,16
	addi	a4,a2,7
	slli	a4,a4,16
	srai	a4,a4,16
	mv	a3,s6
	slli	a2,a2,16
	srai	a2,a2,16
	mv	a1,s7
	li	a0,48
	call	gpu_rectangle
.L12:
	addi	s0,s0,1
	beq	s0,s2,.L17
.L13:
	add	a5,s1,s0
	lbu	a5,0(a5)
	beq	a5,s5,.L9
	beq	a5,s4,.L10
	bne	a5,s3,.L12
	slli	a2,s0,3
	slli	a2,a2,16
	srli	a2,a2,16
	addi	a4,a2,7
	slli	a4,a4,16
	srai	a4,a4,16
	mv	a3,s6
	slli	a2,a2,16
	srai	a2,a2,16
	mv	a1,s7
	li	a0,63
	call	gpu_rectangle
	j	.L12
.L9:
	slli	a2,s0,3
	slli	a2,a2,16
	srli	a2,a2,16
	addi	a4,a2,7
	slli	a4,a4,16
	srai	a4,a4,16
	mv	a3,s6
	slli	a2,a2,16
	srai	a2,a2,16
	mv	a1,s7
	li	a0,3
	call	gpu_rectangle
	j	.L12
.L17:
	addi	s8,s8,8
	slli	s8,s8,16
	srli	s8,s8,16
	addi	s9,s9,8
	slli	s9,s9,16
	srli	s9,s9,16
	addi	s1,s1,60
	beq	s1,s10,.L14
.L8:
	slli	s7,s8,16
	srai	s7,s7,16
	slli	s6,s9,16
	srai	s6,s6,16
	li	s0,0
	j	.L13
.L14:
	lw	a5,12(sp)
	slli	a1,a5,3
	slli	a1,a1,16
	srli	a1,a1,16
	slli	a2,s11,3
	slli	a2,a2,16
	srli	a2,a2,16
	addi	a4,a2,7
	addi	a3,a1,7
	slli	a4,a4,16
	srai	a4,a4,16
	slli	a3,a3,16
	srai	a3,a3,16
	slli	a2,a2,16
	srai	a2,a2,16
	slli	a1,a1,16
	srai	a1,a1,16
	li	a0,12
	call	gpu_rectangle
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
	li	a0,80
	call	rng
	sw	a0,8(sp)
	andi	a5,a0,1
	bne	a5,zero,.L19
	addi	a5,a0,1
	slli	a5,a5,16
	srli	a5,a5,16
	sw	a5,8(sp)
.L19:
	li	a0,60
	call	rng
	sw	a0,12(sp)
	andi	a5,a0,1
	bne	a5,zero,.L20
	addi	a5,a0,1
	slli	a5,a5,16
	srli	a5,a5,16
	sw	a5,12(sp)
.L20:
	lui	a5,%hi(maze)
	lw	s2,8(sp)
	slli	a4,s2,4
	sub	a4,a4,s2
	slli	a4,a4,2
	addi	a5,a5,%lo(maze)
	add	a5,a5,a4
	lw	s3,12(sp)
	add	a5,a5,s3
	li	a4,32
	sb	a4,0(a5)
	li	s10,32
	li	s6,2
	lui	s7,%hi(maze)
	addi	s7,s7,%lo(maze)
	li	s0,35
	li	s8,4096
	addi	s8,s8,703
	add	s8,s7,s8
	j	.L34
.L35:
	mv	s5,s3
	mv	s4,s2
	j	.L21
.L23:
	mv	s3,s5
	mv	s2,s4
	bne	a0,s9,.L27
	bleu	s5,s6,.L27
	addi	s3,s5,-2
	slli	s3,s3,16
	srli	s3,s3,16
	j	.L27
.L47:
	li	a5,76
	bgtu	s4,a5,.L36
	addi	s2,s4,2
	slli	s2,s2,16
	srli	s2,s2,16
	mv	s3,s5
	j	.L27
.L22:
	bleu	s4,s6,.L38
	addi	s2,s4,-2
	slli	s2,s2,16
	srli	s2,s2,16
	mv	s3,s5
	j	.L27
.L36:
	mv	s3,s5
	mv	s2,s4
.L27:
	slli	a5,s2,4
	sub	a5,a5,s2
	slli	a5,a5,2
	add	a5,s7,a5
	add	a5,a5,s3
	lbu	a5,0(a5)
	beq	a5,s0,.L45
.L28:
	addi	s1,s1,-1
	slli	s1,s1,16
	srli	s1,s1,16
	beq	s1,zero,.L46
	mv	s5,s3
	mv	s4,s2
.L29:
	li	a0,4
	call	rng
	beq	a0,s6,.L22
	bgtu	a0,s6,.L23
	beq	a0,zero,.L47
	bgtu	s5,s11,.L37
	addi	s3,s5,2
	slli	s3,s3,16
	srli	s3,s3,16
	mv	s2,s4
	j	.L27
.L37:
	mv	s3,s5
	mv	s2,s4
	j	.L27
.L38:
	mv	s3,s5
	mv	s2,s4
	j	.L27
.L45:
	slli	a5,s2,4
	sub	a5,a5,s2
	slli	a5,a5,2
	add	a5,s7,a5
	add	a5,a5,s3
	sb	s10,0(a5)
	add	a4,s4,s2
	srli	a5,a4,31
	add	a5,a5,a4
	srai	a4,a5,1
	add	a3,s5,s3
	srli	a5,a3,31
	add	a5,a5,a3
	srai	a3,a5,1
	slli	a5,a4,4
	sub	a5,a5,a4
	slli	a5,a5,2
	add	a5,s7,a5
	add	a5,a5,a3
	sb	s10,0(a5)
	j	.L28
.L46:
	addi	a3,s7,119
	li	a2,1
	j	.L30
.L31:
	addi	a5,a5,2
	beq	a5,a3,.L48
.L32:
	lbu	a4,0(a5)
	bne	a4,s0,.L31
	mv	a2,s1
	j	.L31
.L48:
	addi	a3,a3,120
	beq	a3,s8,.L33
.L30:
	addi	a5,a3,-58
	j	.L32
.L33:
	bne	a2,zero,.L49
.L34:
	mv	a1,s3
	mv	a0,s2
	call	display_maze
	li	a0,0
	call	rng
	beq	a0,zero,.L35
	lw	s5,12(sp)
	lw	s4,8(sp)
.L21:
	mv	s1,s10
	li	s9,3
	li	s11,56
	j	.L29
.L49:
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
	.globl	finalise_maze
	.type	finalise_maze, @function
finalise_maze:
	lui	a5,%hi(maze)
	addi	a4,a5,%lo(maze)
	li	a2,4096
	addi	a2,a2,704
	add	a2,a4,a2
	addi	a5,a5,%lo(maze)
	li	a3,42
.L51:
	sb	a3,0(a5)
	sb	a3,59(a5)
	addi	a5,a5,60
	bne	a5,a2,.L51
	addi	a1,a4,60
	li	a5,42
	li	a2,4096
	addi	a2,a2,644
.L52:
	sb	a5,0(a4)
	add	a3,a4,a2
	sb	a5,0(a3)
	addi	a4,a4,1
	bne	a4,a1,.L52
	ret
	.size	finalise_maze, .-finalise_maze
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"Press FIRE to restart!"
	.text
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	lui	s0,%hi(.LC0)
.L57:
	call	tpu_cs
	li	a0,0
	call	terminal_showhide
	call	initialise_maze
	call	generate_maze
	call	finalise_maze
	li	a1,1
	li	a0,1
	call	display_maze
	li	a3,12
	li	a2,64
	li	a1,0
	li	a0,0
	call	tpu_set
	addi	a0,s0,%lo(.LC0)
	call	tpu_outputstring
.L56:
	call	get_buttons
	andi	a0,a0,2
	beq	a0,zero,.L56
	call	tpu_cs
	j	.L57
	.size	main, .-main
	.globl	maze
	.bss
	.align	2
	.type	maze, @object
	.size	maze, 4800
maze:
	.zero	4800
	.ident	"GCC: (Arch Linux Repositories) 10.2.0"
