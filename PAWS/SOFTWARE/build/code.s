	.file	"terminal-test.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0_a2p0_f2p0_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.section	.rodata.main.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"Terminal Test: Colour <%d>\n"
	.align	2
.LC1:
	.string	"\nFloating Point Tests:\n\n"
	.globl	__extendsfdf2
	.align	2
.LC2:
	.string	"j = %d, k = %d, x = %f, y = %f\n\n"
	.align	2
.LC3:
	.string	"x %f, y %f\n    + = %f, - = %f, * = %f, / = %f\n    =%d <%d <=%d    "
	.align	2
.LC4:
	.string	"x + 2 , y - 2\n"
	.align	2
.LC6:
	.string	"x - 2 , y + 2\n"
	.align	2
.LC7:
	.string	"x * 2 , y / 2\n"
	.align	2
.LC9:
	.string	"x / 2 , y * 2\n"
	.align	2
.LC10:
	.string	"TIME <%u> INSN <%u> CYCLES <%u> CYCLES per INSN <%u>"
	.align	2
.LC11:
	.string	"MEMORY TOP OLD <%u> BLOCK <%u> TOP NEW <%u>"
	.align	2
.LC12:
	.string	"LAST CHARACTER <%2x> <%c>"
	.section	.text.startup.main,"ax",@progbits
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-144
	sw	ra,140(sp)
	sw	s2,128(sp)
	sw	s5,116(sp)
	sw	s6,112(sp)
	fsw	fs2,68(sp)
	fsw	fs3,64(sp)
	sw	s0,136(sp)
	sw	s1,132(sp)
	sw	s3,124(sp)
	sw	s4,120(sp)
	sw	s7,108(sp)
	sw	s8,104(sp)
	sw	s9,100(sp)
	sw	s10,96(sp)
	sw	s11,92(sp)
	fsw	fs0,76(sp)
	fsw	fs1,72(sp)
	call	INITIALISEMEMORY
	call	initscr
	call	start_color
	lui	a5,%hi(MEMORYTOP)
	lw	a5,%lo(MEMORYTOP)(a5)
	li	a0,77824
	addi	a0,a0,-1024
	sw	a5,56(sp)
	call	malloc
	lui	a5,%hi(.LC8)
	flw	fs3,%lo(.LC8)(a5)
	lui	a5,%hi(.LC5)
	flw	fs2,%lo(.LC5)(a5)
	sw	a0,60(sp)
	li	s5,0
	lui	s2,%hi(.LC0)
	lui	s6,%hi(.LC3)
.L15:
	call	clear
	li	a1,0
	li	a0,0
	call	move
	li	s1,1
	li	s0,8
.L2:
	mv	a0,s1
	call	attron
	mv	a1,s1
	addi	a0,s2,%lo(.LC0)
	addi	s1,s1,1
	call	printw
	bne	s1,s0,.L2
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	printw
	li	a0,32
	call	rng
	mv	s3,a0
	li	a0,32
	call	rng
	addi	s10,a0,-16
	fcvt.s.w	fs1,s10
	addi	s3,s3,-16
	fcvt.s.w	fs0,s3
	fmv.s	fa0,fs1
	li	s0,4
	li	s1,2
	call	__extendsfdf2
	fmv.s	fa0,fs0
	mv	s9,a0
	mv	s11,a1
	call	__extendsfdf2
	lui	a3,%hi(.LC2)
	mv	a4,a0
	mv	a5,a1
	mv	a6,s9
	mv	a7,s11
	mv	a2,s10
	mv	a1,s3
	addi	a0,a3,%lo(.LC2)
	li	s4,3
	call	printw
.L9:
	fadd.s	fa0,fs0,fs1
	call	__extendsfdf2
	fmv.s	fa0,fs1
	mv	s8,a0
	mv	s10,a1
	call	__extendsfdf2
	fmv.s	fa0,fs0
	mv	s7,a0
	mv	s9,a1
	call	__extendsfdf2
	fdiv.s	fa0,fs0,fs1
	fle.s	a6,fs0,fs1
	flt.s	a4,fs0,fs1
	feq.s	a5,fs0,fs1
	sw	a6,32(sp)
	sw	a4,28(sp)
	sw	a5,24(sp)
	mv	s11,a0
	mv	s3,a1
	call	__extendsfdf2
	fmul.s	fa0,fs0,fs1
	sw	a0,16(sp)
	sw	a1,20(sp)
	call	__extendsfdf2
	fsub.s	fa0,fs0,fs1
	sw	a0,8(sp)
	sw	a1,12(sp)
	call	__extendsfdf2
	sw	a0,0(sp)
	mv	a6,s8
	mv	a4,s7
	mv	a2,s11
	mv	a7,s10
	mv	a5,s9
	mv	a3,s3
	sw	a1,4(sp)
	addi	a0,s6,%lo(.LC3)
	call	printw
	li	a0,4
	call	rng
	beq	a0,s1,.L3
	bgtu	a0,s1,.L4
	beq	a0,zero,.L25
	lui	a5,%hi(.LC6)
	addi	a0,a5,%lo(.LC6)
	call	printw
	fsub.s	fs0,fs0,fs2
	fadd.s	fs1,fs1,fs2
.L8:
	addi	s0,s0,-1
	bne	s0,zero,.L9
	call	CSRtime
	mv	s1,a0
	call	CSRcycles
	mv	s0,a0
	call	CSRinstructions
	divu	a6,s0,a0
	lui	a5,%hi(.LC10)
	mv	a4,a0
	addi	a2,a5,%lo(.LC10)
	li	a1,0
	mv	a5,s0
	mv	a3,s1
	li	a0,25
	call	mvprintw
	lw	a5,56(sp)
	lw	a4,60(sp)
	lui	a2,%hi(.LC11)
	mv	a3,a5
	addi	a2,a2,%lo(.LC11)
	li	a1,0
	li	a0,27
	call	mvprintw
	call	ps2_character_available
	bne	a0,zero,.L26
.L10:
	li	a1,0
	li	a0,1000
	call	set_timer1khz
	li	s0,63
	beq	s5,zero,.L13
	mv	s0,s5
.L13:
	li	a0,0
	call	get_timer1khz
	mv	a5,a0
	lui	a2,%hi(.LC12)
	mv	a4,s0
	mv	a3,s5
	addi	a2,a2,%lo(.LC12)
	li	a1,0
	li	a0,29
	beq	a5,zero,.L15
	call	mvprintw
	call	refresh
	j	.L13
.L4:
	bne	a0,s4,.L8
	lui	a5,%hi(.LC9)
	addi	a0,a5,%lo(.LC9)
	call	printw
	fmul.s	fs0,fs0,fs3
	fadd.s	fs1,fs1,fs1
	j	.L8
.L3:
	lui	a5,%hi(.LC7)
	addi	a0,a5,%lo(.LC7)
	call	printw
	fadd.s	fs0,fs0,fs0
	fmul.s	fs1,fs1,fs3
	j	.L8
.L25:
	lui	a5,%hi(.LC4)
	addi	a0,a5,%lo(.LC4)
	call	printw
	fadd.s	fs0,fs0,fs2
	fsub.s	fs1,fs1,fs2
	j	.L8
.L26:
	call	ps2_inputcharacter
	mv	s5,a0
	j	.L10
	.size	main, .-main
	.section	.srodata.cst4,"aM",@progbits,4
	.align	2
.LC5:
	.word	1073741824
	.align	2
.LC8:
	.word	1056964608
	.ident	"GCC: (Arch Linux Repositories) 10.2.0"
