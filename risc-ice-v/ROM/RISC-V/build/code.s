	.file	"test_uart.c"
	.option nopic
	.attribute arch, "rv32i2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.globl	outputcharacter
	.type	outputcharacter, @function
outputcharacter:
	lui	a5,%hi(UARTSTATUS)
	lw	a4,%lo(UARTSTATUS)(a5)
.L2:
	lw	a5,0(a4)
	andi	a5,a5,2
	bne	a5,zero,.L2
	lui	a5,%hi(UARTDATA)
	lw	a5,%lo(UARTDATA)(a5)
	sb	a0,0(a5)
	lui	a5,%hi(TERMINALOUTPUT)
	lw	a5,%lo(TERMINALOUTPUT)(a5)
	sb	a0,0(a5)
	li	a5,10
	beq	a0,a5,.L9
	ret
.L9:
	addi	sp,sp,-16
	sw	ra,12(sp)
	li	a0,13
	call	outputcharacter
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	outputcharacter, .-outputcharacter
	.align	2
	.globl	outputstring
	.type	outputstring, @function
outputstring:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	mv	s0,a0
	lbu	a0,0(a0)
	beq	a0,zero,.L11
.L12:
	call	outputcharacter
	addi	s0,s0,1
	lbu	a0,0(s0)
	bne	a0,zero,.L12
.L11:
	li	a0,10
	call	outputcharacter
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	outputstring, .-outputstring
	.align	2
	.globl	outputstringnonl
	.type	outputstringnonl, @function
outputstringnonl:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	mv	s0,a0
	lbu	a0,0(a0)
	beq	a0,zero,.L15
.L17:
	call	outputcharacter
	addi	s0,s0,1
	lbu	a0,0(s0)
	bne	a0,zero,.L17
.L15:
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	outputstringnonl, .-outputstringnonl
	.align	2
	.globl	inputcharacter
	.type	inputcharacter, @function
inputcharacter:
	lui	a5,%hi(UARTSTATUS)
	lw	a4,%lo(UARTSTATUS)(a5)
.L21:
	lw	a5,0(a4)
	andi	a5,a5,1
	beq	a5,zero,.L21
	lui	a5,%hi(UARTDATA)
	lw	a5,%lo(UARTDATA)(a5)
	lbu	a0,0(a5)
	ret
	.size	inputcharacter, .-inputcharacter
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s1,4(sp)
	li	a0,10
	call	outputcharacter
	li	a0,82
	call	outputcharacter
	li	a0,73
	call	outputcharacter
	li	a0,83
	call	outputcharacter
	li	a0,67
	call	outputcharacter
	li	a0,45
	call	outputcharacter
	li	a0,73
	call	outputcharacter
	li	a0,67
	call	outputcharacter
	li	a0,69
	call	outputcharacter
	li	a0,45
	call	outputcharacter
	li	a0,86
	call	outputcharacter
	li	a0,32
	call	outputcharacter
	li	a0,67
	call	outputcharacter
	li	a0,80
	call	outputcharacter
	li	a0,85
	call	outputcharacter
	li	a0,13
	call	outputcharacter
	li	a0,10
	call	outputcharacter
	li	a0,62
	call	outputcharacter
	li	a0,32
	call	outputcharacter
	lui	s1,%hi(LEDS)
.L24:
	call	inputcharacter
	mv	s0,a0
	call	outputcharacter
	lw	a5,%lo(LEDS)(s1)
	sw	s0,0(a5)
	j	.L24
	.size	main, .-main
	.globl	TERMINALOUTPUT
	.globl	LEDS
	.globl	BUTTONS
	.globl	UARTDATA
	.globl	UARTSTATUS
	.section	.sdata,"aw"
	.align	2
	.type	TERMINALOUTPUT, @object
	.size	TERMINALOUTPUT, 4
TERMINALOUTPUT:
	.word	33024
	.type	LEDS, @object
	.size	LEDS, 4
LEDS:
	.word	32780
	.type	BUTTONS, @object
	.size	BUTTONS, 4
BUTTONS:
	.word	32776
	.type	UARTDATA, @object
	.size	UARTDATA, 4
UARTDATA:
	.word	32768
	.type	UARTSTATUS, @object
	.size	UARTSTATUS, 4
UARTSTATUS:
	.word	32772
	.ident	"GCC: (Arch Linux Repositories) 10.2.0"
