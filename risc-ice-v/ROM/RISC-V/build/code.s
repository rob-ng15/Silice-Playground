	.file	"test_uart.c"
	.option nopic
	.attribute arch, "rv32i2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-16
	sw	zero,12(sp)
	li	a4,4096
	addi	a3,a4,2
	j	.L3
.L6:
	lw	a5,0(a4)
	sw	a5,4(a4)
	sw	a5,8(a4)
.L3:
	lhu	a5,0(a3)
	andi	a5,a5,1
.L2:
	beq	a5,zero,.L2
	j	.L6
	.size	main, .-main
	.ident	"GCC: (Arch Linux Repositories) 10.2.0"
