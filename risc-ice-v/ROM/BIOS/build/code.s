	.file	"memtest.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	1
	.globl	draw_riscv_logo
	.type	draw_riscv_logo, @function
draw_riscv_logo:
	addi	sp,sp,-16
	sw	ra,12(sp)
	li	a4,100
	li	a3,100
	li	a2,0
	li	a1,0
	li	a0,56
	call	gpu_rectangle
	li	a6,100
	li	a5,50
	li	a4,100
	li	a3,100
	li	a2,33
	li	a1,100
	li	a0,63
	call	gpu_triangle
	li	a6,100
	li	a5,66
	li	a4,100
	li	a3,100
	li	a2,50
	li	a1,100
	li	a0,2
	call	gpu_triangle
	li	a4,50
	li	a3,33
	li	a2,0
	li	a1,0
	li	a0,2
	call	gpu_rectangle
	li	a4,1
	li	a3,26
	li	a2,25
	li	a1,25
	li	a0,63
	call	gpu_circle
	li	a4,12
	li	a3,25
	li	a2,0
	li	a1,0
	li	a0,63
	call	gpu_rectangle
	li	a4,1
	li	a3,12
	li	a2,25
	li	a1,25
	li	a0,2
	call	gpu_circle
	li	a6,100
	li	a5,0
	li	a4,100
	li	a3,67
	li	a2,33
	li	a1,0
	li	a0,63
	call	gpu_triangle
	li	a6,100
	li	a5,0
	li	a4,100
	li	a3,50
	li	a2,50
	li	a1,0
	li	a0,2
	call	gpu_triangle
	li	a4,37
	li	a3,25
	li	a2,12
	li	a1,0
	li	a0,2
	call	gpu_rectangle
	li	a4,100
	li	a3,8
	li	a2,37
	li	a1,0
	li	a0,2
	call	gpu_rectangle
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	draw_riscv_logo, .-draw_riscv_logo
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"Memory Dump 8 bit"
	.text
	.align	1
	.globl	memorydump
	.type	memorydump, @function
memorydump:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	mv	s2,a0
	mv	s0,a1
	lui	a0,%hi(.LC0)
	addi	a0,a0,%lo(.LC0)
	call	outputstring
	srli	a5,s0,4
	beq	a5,zero,.L3
	addi	s1,s2,16
	slli	a5,a5,4
	add	s3,s2,a5
.L6:
	mv	a0,s2
	call	outputnumber_int
	li	a0,58
	call	outputcharacter
	li	a0,32
	call	outputcharacter
	mv	s0,s2
.L5:
	lbu	a0,0(s0)
	call	outputnumber_char
	li	a0,32
	call	outputcharacter
	addi	s0,s0,1
	bne	s0,s1,.L5
	addi	s2,s2,16
	li	a0,10
	call	outputcharacter
	li	a0,500
	call	sleep
	addi	s1,s1,16
	bne	s3,s2,.L6
.L3:
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	addi	sp,sp,32
	jr	ra
	.size	memorydump, .-memorydump
	.section	.rodata.str1.4
	.align	2
.LC1:
	.string	"Memory Dump 16 bit"
	.text
	.align	1
	.globl	memorydump16
	.type	memorydump16, @function
memorydump16:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	mv	s2,a0
	mv	s0,a1
	lui	a0,%hi(.LC1)
	addi	a0,a0,%lo(.LC1)
	call	outputstring
	srli	a5,s0,4
	beq	a5,zero,.L10
	addi	s1,s2,32
	slli	a5,a5,5
	add	s3,s2,a5
.L13:
	mv	a0,s2
	call	outputnumber_int
	li	a0,58
	call	outputcharacter
	li	a0,32
	call	outputcharacter
	mv	s0,s2
.L12:
	lhu	a0,0(s0)
	call	outputnumber_short
	li	a0,32
	call	outputcharacter
	addi	s0,s0,2
	bne	s0,s1,.L12
	addi	s2,s2,32
	li	a0,10
	call	outputcharacter
	li	a0,500
	call	sleep
	addi	s1,s1,32
	bne	s3,s2,.L13
.L10:
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	addi	sp,sp,32
	jr	ra
	.size	memorydump16, .-memorydump16
	.section	.rodata.str1.4
	.align	2
.LC2:
	.string	"Welcome to PAWS a RISC-V RV32IMC CPU"
	.align	2
.LC3:
	.string	"\nMEMORY DUMP FROM 0x10000000 CACHE"
	.align	2
.LC4:
	.string	"\n\nMEMORY DUMP 16 FROM 0x10000100 CACHE"
	.align	2
.LC5:
	.string	"\nREPEAT MEMORY DUMPS\n"
	.align	2
.LC6:
	.string	"\nMEMORY DUMP FROM 0x10000000 SDRAM via CACHE"
	.align	2
.LC7:
	.string	"\n\nMEMORY DUMP 16 FROM 0x10000100 SDRAM via CACHE"
	.align	2
.LC8:
	.string	"\nCLOCK CYCLES: "
	.align	2
.LC9:
	.string	" INSTRUCTIONS: "
	.align	2
.LC10:
	.string	"\n\nTerminal Echo Starting"
	.align	2
.LC11:
	.string	"You pressed : "
	.align	2
.LC12:
	.string	" <-"
	.text
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s1,4(sp)
	sw	s2,0(sp)
	call	terminal_reset
	call	gpu_cs
	call	tpu_cs
	li	a2,0
	li	a1,0
	li	a0,1
	call	set_background
	call	draw_riscv_logo
	li	a3,63
	li	a2,64
	li	a1,5
	li	a0,16
	call	tpu_set
	lui	a0,%hi(.LC2)
	addi	a0,a0,%lo(.LC2)
	call	tpu_outputstring
	li	a0,4096
	addi	a0,a0,-96
	call	sleep
	li	s0,268435456
	li	a5,268435456
	addi	a5,a5,256
.L18:
	sb	s0,0(s0)
	addi	s0,s0,1
	bne	s0,a5,.L18
	mv	a4,s0
	li	a5,0
	li	a3,256
.L19:
	sh	a5,0(a4)
	addi	a5,a5,1
	slli	a5,a5,16
	srli	a5,a5,16
	addi	a4,a4,2
	bne	a5,a3,.L19
	lui	a0,%hi(.LC3)
	addi	a0,a0,%lo(.LC3)
	call	outputstring
	li	a1,256
	li	a0,268435456
	call	memorydump
	lui	a0,%hi(.LC4)
	addi	a0,a0,%lo(.LC4)
	call	outputstring
	li	a1,256
	li	a0,268435456
	addi	a0,a0,256
	call	memorydump16
	li	a5,0
	li	a4,4096
.L20:
	sh	a5,0(s0)
	addi	a5,a5,1
	slli	a5,a5,16
	srli	a5,a5,16
	addi	s0,s0,2
	bne	a5,a4,.L20
	lui	a0,%hi(.LC5)
	addi	a0,a0,%lo(.LC5)
	call	outputstring
	lui	a0,%hi(.LC6)
	addi	a0,a0,%lo(.LC6)
	call	outputstring
	li	a1,256
	li	a0,268435456
	call	memorydump
	lui	a0,%hi(.LC7)
	addi	a0,a0,%lo(.LC7)
	call	outputstring
	li	a1,256
	li	a0,268435456
	addi	a0,a0,256
	call	memorydump16
	call	CSRcycles
	mv	s1,a0
	call	CSRinstructions
	mv	s0,a0
	lui	a0,%hi(.LC8)
	addi	a0,a0,%lo(.LC8)
	call	outputstringnonl
	mv	a0,s1
	call	outputnumber_int
	lui	a0,%hi(.LC9)
	addi	a0,a0,%lo(.LC9)
	call	outputstringnonl
	mv	a0,s0
	call	outputnumber_int
	j	.L21
.L22:
	call	inputcharacter
.L21:
	call	inputcharacter_available
	bne	a0,zero,.L22
	lui	a0,%hi(.LC10)
	addi	a0,a0,%lo(.LC10)
	call	outputstring
	lui	s2,%hi(.LC11)
	lui	s1,%hi(.LC12)
.L23:
	call	inputcharacter
	mv	s0,a0
	addi	a0,s2,%lo(.LC11)
	call	outputstringnonl
	mv	a0,s0
	call	outputcharacter
	addi	a0,s1,%lo(.LC12)
	call	outputstring
	mv	a0,s0
	call	set_leds
	j	.L23
	.size	main, .-main
	.ident	"GCC: (Arch Linux Repositories) 10.2.0"
