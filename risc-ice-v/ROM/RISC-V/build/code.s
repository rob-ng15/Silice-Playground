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
	li	a5,32768
	li	a4,66
	sw	a4,256(a5)
	li	a4,105
	sw	a4,256(a5)
	li	a4,111
	sw	a4,256(a5)
	li	a4,115
	sw	a4,256(a5)
	li	a4,10
	sw	a4,256(a5)
	li	a4,13
	sw	a4,256(a5)
	li	a4,62
	sw	a4,256(a5)
	li	a4,32768
	j	.L2
.L5:
	lw	a5,0(a4)
	sw	a5,0(a4)
	sw	a5,256(a4)
	sw	a5,12(a4)
.L2:
	lw	a5,4(a4)
	andi	a5,a5,1
	beq	a5,zero,.L2
	j	.L5
	.size	main, .-main
	.ident	"GCC: (Arch Linux Repositories) 10.2.0"
