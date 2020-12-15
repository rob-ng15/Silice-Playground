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
	li	a1,4096
	addi	a1,a1,764
	add	a1,a2,a1
	li	a3,35
	j	.L2
.L10:
	addi	a4,a4,60
	beq	a4,a1,.L4
.L2:
	addi	a5,a4,-60
.L3:
	sb	a3,0(a5)
	addi	a5,a5,1
	bne	a5,a4,.L3
	j	.L10
.L4:
	li	a3,4096
	addi	a3,a3,704
	add	a3,a2,a3
	mv	a5,a2
	li	a4,42
.L5:
	sb	a4,0(a5)
	sb	a4,59(a5)
	sb	a4,58(a5)
	addi	a5,a5,60
	bne	a5,a3,.L5
	lui	a5,%hi(maze+4680)
	addi	a5,a5,%lo(maze+4680)
	li	a4,4096
	addi	a4,a4,644
	add	a2,a2,a4
	li	a1,-4096
	addi	a1,a1,-584
	li	a4,42
.L6:
	add	a3,a5,a1
	sb	a4,0(a3)
	sb	a4,60(a5)
	sb	a4,0(a5)
	addi	a5,a5,1
	bne	a5,a2,.L6
	lui	a5,%hi(maze)
	addi	a5,a5,%lo(maze)
	li	a4,69
	sb	a4,1(a5)
	li	a4,4096
	add	a5,a5,a4
	li	a4,88
	sb	a4,641(a5)
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
	sw	a0,8(sp)
	sw	a1,12(sp)
	lui	a5,%hi(maze)
	addi	a5,a5,%lo(maze)
	sw	a5,4(sp)
	li	a5,7
	sw	a5,0(sp)
	li	s11,0
	li	s3,42
	li	s8,69
	li	s7,88
	li	s6,32
	j	.L12
.L14:
	beq	a5,s8,.L15
	bne	a5,s7,.L17
	slli	a4,s1,16
	srai	a4,a4,16
	mv	a3,s9
	slli	a2,s0,16
	srai	a2,a2,16
	mv	a1,s10
	li	a0,60
	call	gpu_rectangle
	j	.L17
.L13:
	slli	a4,s1,16
	srai	a4,a4,16
	mv	a3,s9
	slli	a2,s0,16
	srai	a2,a2,16
	mv	a1,s10
	li	a0,48
	call	gpu_rectangle
.L17:
	addi	s2,s2,1
	addi	s0,s0,8
	slli	s0,s0,16
	srli	s0,s0,16
	addi	s1,s1,8
	slli	s1,s1,16
	srli	s1,s1,16
	beq	s0,s4,.L23
.L19:
	lbu	a5,0(s2)
	beq	a5,s3,.L13
	bgtu	a5,s3,.L14
	beq	a5,s6,.L15
	bne	a5,s5,.L17
	slli	a4,s1,16
	srai	a4,a4,16
	mv	a3,s9
	slli	a2,s0,16
	srai	a2,a2,16
	mv	a1,s10
	li	a0,3
	call	gpu_rectangle
	j	.L17
.L15:
	slli	a4,s1,16
	srai	a4,a4,16
	mv	a3,s9
	slli	a2,s0,16
	srai	a2,a2,16
	mv	a1,s10
	li	a0,63
	call	gpu_rectangle
	j	.L17
.L23:
	addi	s11,s11,8
	slli	s11,s11,16
	srli	s11,s11,16
	lw	a5,0(sp)
	addi	a5,a5,8
	slli	a5,a5,16
	srli	a5,a5,16
	sw	a5,0(sp)
	lw	a5,4(sp)
	addi	a5,a5,60
	sw	a5,4(sp)
	li	a5,640
	beq	s11,a5,.L20
.L12:
	slli	s10,s11,16
	srai	s10,s10,16
	lh	s9,0(sp)
	lw	s2,4(sp)
	li	s1,7
	li	s0,0
	li	s5,35
	li	s4,480
	j	.L19
.L20:
	lw	a5,8(sp)
	slli	a1,a5,3
	slli	a1,a1,16
	srli	a1,a1,16
	lw	a5,12(sp)
	slli	a2,a5,3
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
	li	a0,80
	call	rng
	mv	s2,a0
	andi	a5,a0,1
	bne	a5,zero,.L25
	addi	s2,a0,1
	slli	s2,s2,16
	srli	s2,s2,16
.L25:
	li	a0,60
	call	rng
	mv	s3,a0
	andi	a5,a0,1
	bne	a5,zero,.L26
	addi	s3,a0,1
	slli	s3,s3,16
	srli	s3,s3,16
.L26:
	lui	a5,%hi(maze)
	slli	a4,s2,4
	sub	a4,a4,s2
	slli	a4,a4,2
	addi	a5,a5,%lo(maze)
	add	a5,a5,a4
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
	j	.L39
.L28:
	mv	s3,s5
	mv	s2,s4
	bne	a0,s9,.L32
	bleu	s5,s6,.L32
	addi	s3,s5,-2
	slli	s3,s3,16
	srli	s3,s3,16
	j	.L32
.L51:
	li	a5,76
	bgtu	s4,a5,.L40
	addi	s2,s4,2
	slli	s2,s2,16
	srli	s2,s2,16
	mv	s3,s5
	j	.L32
.L27:
	bleu	s4,s6,.L42
	addi	s2,s4,-2
	slli	s2,s2,16
	srli	s2,s2,16
	mv	s3,s5
	j	.L32
.L40:
	mv	s3,s5
	mv	s2,s4
.L32:
	slli	a5,s2,4
	sub	a5,a5,s2
	slli	a5,a5,2
	add	a5,s7,a5
	add	a5,a5,s3
	lbu	a5,0(a5)
	beq	a5,s0,.L49
.L33:
	addi	s1,s1,-1
	slli	s1,s1,16
	srli	s1,s1,16
	beq	s1,zero,.L50
	mv	s5,s3
	mv	s4,s2
.L34:
	li	a0,4
	call	rng
	beq	a0,s6,.L27
	bgtu	a0,s6,.L28
	beq	a0,zero,.L51
	bgtu	s5,s11,.L41
	addi	s3,s5,2
	slli	s3,s3,16
	srli	s3,s3,16
	mv	s2,s4
	j	.L32
.L41:
	mv	s3,s5
	mv	s2,s4
	j	.L32
.L42:
	mv	s3,s5
	mv	s2,s4
	j	.L32
.L49:
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
	j	.L33
.L50:
	addi	a3,s7,119
	li	a2,1
	j	.L35
.L36:
	addi	a5,a5,2
	beq	a5,a3,.L52
.L37:
	lbu	a4,0(a5)
	bne	a4,s0,.L36
	mv	a2,s1
	j	.L36
.L52:
	addi	a3,a3,120
	beq	a3,s8,.L38
.L35:
	addi	a5,a3,-58
	j	.L37
.L38:
	bne	a2,zero,.L53
.L39:
	mv	a1,s3
	mv	a0,s2
	call	display_maze
	mv	s5,s3
	mv	s4,s2
	mv	s1,s10
	li	s9,3
	li	s11,56
	j	.L34
.L53:
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
	.size	generate_maze, .-generate_maze
	.align	1
	.globl	finalise_maze
	.type	finalise_maze, @function
finalise_maze:
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
