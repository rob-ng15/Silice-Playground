	.file	"chess.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	1
	.globl	setupboard
	.type	setupboard, @function
setupboard:
	lui	a6,%hi(.LANCHOR0)
	addi	a6,a6,%lo(.LANCHOR0)
	addi	t3,a6,512
	li	a3,1
	li	a0,8
	li	t1,3
	li	a7,2
	j	.L2
.L12:
	bge	a5,zero,.L10
.L5:
	sw	t1,4(a2)
.L6:
	addi	a5,a5,1
	addi	a4,a4,8
	beq	a5,a0,.L11
.L9:
	mv	a2,a4
	sw	zero,0(a4)
	ble	a5,a3,.L12
	addi	a1,a5,-6
	bgtu	a1,a3,.L5
	sw	a7,4(a4)
	j	.L6
.L10:
	sw	a3,4(a4)
	addi	a5,a5,1
	addi	a4,a4,8
	j	.L9
.L11:
	addi	a6,a6,64
	beq	a6,t3,.L1
.L2:
	mv	a4,a6
	li	a5,0
	j	.L9
.L1:
	ret
	.size	setupboard, .-setupboard
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-16
	sw	ra,12(sp)
	call	setupboard
.L14:
	j	.L14
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
