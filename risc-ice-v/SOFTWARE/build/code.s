	.file	"chess.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	1
	.globl	setupscreen
	.type	setupscreen, @function
setupscreen:
	addi	sp,sp,-16
	sw	ra,12(sp)
	call	gpu_cs
	call	tpu_cs
	li	a0,0
	call	terminal_showhide
	li	a2,4
	li	a1,0
	li	a0,0
	call	set_background
	li	a4,456
	li	a3,536
	li	a2,24
	li	a1,104
	li	a0,0
	call	gpu_rectangle
	li	a4,448
	li	a3,528
	li	a2,32
	li	a1,112
	li	a0,63
	call	gpu_rectangle
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	setupscreen, .-setupscreen
	.align	1
	.globl	drawboard
	.type	drawboard, @function
drawboard:
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
	lui	s11,%hi(.LANCHOR0)
	addi	s11,s11,%lo(.LANCHOR0)
	li	a5,170
	sw	a5,12(sp)
	li	s9,120
	li	s3,0
	li	s10,1
	li	s7,2
	li	s4,8
	j	.L4
.L5:
	addi	a4,s0,50
	slli	a4,a4,16
	srai	a4,a4,16
	mv	a3,s5
	slli	a2,s0,16
	srai	a2,a2,16
	mv	a1,s6
	li	a0,42
	call	gpu_rectangle
	j	.L6
.L8:
	addi	a3,a3,48
	addi	a2,s0,9
	mv	a4,s7
	andi	a3,a3,0xff
	slli	a2,a2,16
	srai	a2,a2,16
	mv	a1,s8
	call	gpu_character_blit
.L7:
	addi	s1,s1,1
	addi	s2,s2,8
	addi	s0,s0,50
	slli	s0,s0,16
	srli	s0,s0,16
	beq	s1,s4,.L14
.L9:
	xor	a5,s3,s1
	andi	a5,a5,1
	bne	a5,zero,.L5
	addi	a4,s0,50
	slli	a4,a4,16
	srai	a4,a4,16
	mv	a3,s5
	slli	a2,s0,16
	srai	a2,a2,16
	mv	a1,s6
	li	a0,21
	call	gpu_rectangle
.L6:
	lw	a3,0(s2)
	beq	a3,zero,.L7
	lw	a5,4(s2)
	mv	a0,s7
	beq	a5,s10,.L8
	li	a0,32
	j	.L8
.L14:
	addi	s3,s3,1
	addi	s9,s9,50
	slli	s9,s9,16
	srli	s9,s9,16
	lw	a5,12(sp)
	addi	a5,a5,50
	slli	a5,a5,16
	srli	a5,a5,16
	sw	a5,12(sp)
	addi	s11,s11,64
	beq	s3,s4,.L3
.L4:
	slli	s6,s9,16
	srai	s6,s6,16
	lh	s5,12(sp)
	addi	s8,s9,9
	slli	s8,s8,16
	srai	s8,s8,16
	mv	s2,s11
	li	s0,40
	li	s1,0
	j	.L9
.L3:
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
	.size	drawboard, .-drawboard
	.align	1
	.globl	setupboard
	.type	setupboard, @function
setupboard:
	lui	a7,%hi(.LANCHOR0)
	addi	a6,a7,%lo(.LANCHOR0)
	addi	t4,a6,512
	addi	a7,a7,%lo(.LANCHOR0)
	li	a3,1
	li	a0,8
	li	t3,3
	li	t1,2
	j	.L16
.L28:
	bge	a5,zero,.L26
.L19:
	sw	t3,4(a2)
.L20:
	addi	a5,a5,1
	addi	a4,a4,8
	beq	a5,a0,.L27
.L23:
	mv	a2,a4
	sw	zero,0(a4)
	ble	a5,a3,.L28
	addi	a1,a5,-6
	bgtu	a1,a3,.L19
	sw	t1,4(a4)
	j	.L20
.L26:
	sw	a3,4(a4)
	addi	a5,a5,1
	addi	a4,a4,8
	j	.L23
.L27:
	addi	a7,a7,64
	beq	a7,t4,.L29
.L16:
	mv	a4,a7
	li	a5,0
	j	.L23
.L29:
	li	a5,1
.L22:
	sw	a5,8(a6)
	sw	a5,48(a6)
	addi	a6,a6,64
	bne	a6,t4,.L22
	lui	a5,%hi(.LANCHOR0)
	addi	a5,a5,%lo(.LANCHOR0)
	li	a4,2
	sw	a4,0(a5)
	sw	a4,56(a5)
	sw	a4,448(a5)
	sw	a4,504(a5)
	li	a4,4
	sw	a4,64(a5)
	sw	a4,384(a5)
	sw	a4,120(a5)
	sw	a4,440(a5)
	li	a4,3
	sw	a4,128(a5)
	sw	a4,320(a5)
	sw	a4,184(a5)
	sw	a4,376(a5)
	li	a4,5
	sw	a4,192(a5)
	sw	a4,312(a5)
	li	a4,6
	sw	a4,256(a5)
	sw	a4,248(a5)
	ret
	.size	setupboard, .-setupboard
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-16
	sw	ra,12(sp)
	call	INITIALISEMEMORY
	call	setupscreen
.L31:
	call	setupboard
	call	drawboard
	call	inputcharacter
	j	.L31
	.size	main, .-main
	.globl	board
	.bss
	.align	2
	.set	.LANCHOR0,. + 0
	.type	board, @object
	.size	board, 512
board:
	.zero	512
	.ident	"GCC: (Arch Linux Repositories) 10.2.0"
