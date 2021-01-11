	.file	"template.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"Press a key to test\n"
	.align	2
.LC1:
	.string	"MBR = "
	.align	2
.LC2:
	.string	"BOOTSECTOR = "
	.align	2
.LC3:
	.string	"PARTITION = "
	.align	2
.LC4:
	.string	"ROOTDIRECTORY = "
	.align	2
.LC5:
	.string	"CLUSTERBUFFER = "
	.align	2
.LC6:
	.string	"CLUSTERSIZE = "
	.align	2
.LC7:
	.string	"MEMORYTOP = "
	.align	2
.LC8:
	.string	"ALLOCATE 32K"
	.align	2
.LC9:
	.string	"newbuffer = "
	.align	2
.LC10:
	.string	"Finding File GALAXY.JPG"
	.align	2
.LC11:
	.string	"JPG"
	.align	2
.LC12:
	.string	"GALAXY"
	.align	2
.LC13:
	.string	"FILE NOT FOUND"
	.align	2
.LC14:
	.string	"FILESIZE = "
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
	sw	s10,0(sp)
	call	INITIALISEMEMORY
	lui	s8,%hi(.LC0)
	lui	s7,%hi(.LC1)
	lui	s6,%hi(MBR)
	lui	s5,%hi(.LC2)
	lui	s4,%hi(BOOTSECTOR)
	lui	s3,%hi(.LC3)
	lui	s2,%hi(PARTITION)
	lui	s1,%hi(.LC4)
	j	.L4
.L6:
	lui	a0,%hi(.LC13)
	addi	a0,a0,%lo(.LC13)
	call	outputstring
.L3:
	call	inputcharacter
.L4:
	li	a0,1
	call	terminal_showhide
	addi	a0,s8,%lo(.LC0)
	call	outputstring
	call	inputcharacter
	addi	a0,s7,%lo(.LC1)
	call	outputstringnonl
	lw	a0,%lo(MBR)(s6)
	call	outputnumber_int
	li	a0,10
	call	outputcharacter
	addi	a0,s5,%lo(.LC2)
	call	outputstringnonl
	lw	a0,%lo(BOOTSECTOR)(s4)
	call	outputnumber_int
	li	a0,10
	call	outputcharacter
	addi	a0,s3,%lo(.LC3)
	call	outputstringnonl
	lw	a0,%lo(PARTITION)(s2)
	call	outputnumber_int
	li	a0,10
	call	outputcharacter
	addi	a0,s1,%lo(.LC4)
	call	outputstringnonl
	lui	a5,%hi(ROOTDIRECTORY)
	lw	a0,%lo(ROOTDIRECTORY)(a5)
	call	outputnumber_int
	li	a0,10
	call	outputcharacter
	lui	a0,%hi(.LC5)
	addi	a0,a0,%lo(.LC5)
	call	outputstringnonl
	lui	a5,%hi(CLUSTERBUFFER)
	lw	a0,%lo(CLUSTERBUFFER)(a5)
	call	outputnumber_int
	li	a0,10
	call	outputcharacter
	lui	a0,%hi(.LC6)
	addi	a0,a0,%lo(.LC6)
	call	outputstringnonl
	lui	a5,%hi(CLUSTERSIZE)
	lw	a0,%lo(CLUSTERSIZE)(a5)
	call	outputnumber_int
	li	a0,10
	call	outputcharacter
	li	a0,10
	call	outputcharacter
	lui	s10,%hi(.LC7)
	addi	a0,s10,%lo(.LC7)
	call	outputstringnonl
	lui	s9,%hi(MEMORYTOP)
	lw	a0,%lo(MEMORYTOP)(s9)
	call	outputnumber_int
	li	a0,10
	call	outputcharacter
	lui	a0,%hi(.LC8)
	addi	a0,a0,%lo(.LC8)
	call	outputstring
	li	a0,32768
	call	memoryspace
	mv	s0,a0
	lui	a0,%hi(.LC9)
	addi	a0,a0,%lo(.LC9)
	call	outputstringnonl
	mv	a0,s0
	call	outputnumber_int
	li	a0,10
	call	outputcharacter
	addi	a0,s10,%lo(.LC7)
	call	outputstringnonl
	lw	a0,%lo(MEMORYTOP)(s9)
	call	outputnumber_int
	li	a0,10
	call	outputcharacter
	li	a0,10
	call	outputcharacter
	call	inputcharacter
	lui	a0,%hi(.LC10)
	addi	a0,a0,%lo(.LC10)
	call	outputstring
	lui	a1,%hi(.LC11)
	addi	a1,a1,%lo(.LC11)
	lui	a0,%hi(.LC12)
	addi	a0,a0,%lo(.LC12)
	call	findfilenumber
	mv	s0,a0
	li	a5,65536
	addi	a5,a5,-1
	beq	a0,a5,.L6
	lui	a0,%hi(.LC14)
	addi	a0,a0,%lo(.LC14)
	call	outputstringnonl
	mv	a0,s0
	call	findfilesize
	call	outputnumber_int
	li	a0,10
	call	outputcharacter
	j	.L3
	.size	main, .-main
	.ident	"GCC: (Arch Linux Repositories) 10.2.0"
