	.file	"test_leds.c"
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
	li	a5,2
	li	a1,4096
	li	a3,65536
	li	a2,8
	j	.L2
.L3:
	slli	a5,a5,1
	ble	a5,a2,.L2
	li	a5,1
.L2:
	ori	a4,a5,16
	sw	a4,4(a1)
	sw	zero,12(sp)
	lw	a4,12(sp)
	bge	a4,a3,.L3
.L4:
	lw	a4,12(sp)
	addi	a4,a4,1
	sw	a4,12(sp)
	lw	a4,12(sp)
	blt	a4,a3,.L4
	j	.L3
	.size	main, .-main
	.ident	"GCC: (Arch Linux Repositories) 10.2.0"
