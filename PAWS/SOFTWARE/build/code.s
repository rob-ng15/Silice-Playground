	.file	"tune.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0_a2p0_f2p0_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.section	.text.startup.main,"ax",@progbits
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	sw	s3,12(sp)
	sw	s5,4(sp)
	sw	s6,0(sp)
	lui	s3,%hi(.LANCHOR0)
	lui	s5,%hi(.LANCHOR1)
	li	s6,4096
	sw	s1,20(sp)
	sw	s4,8(sp)
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s2,16(sp)
	addi	s3,s3,%lo(.LANCHOR0)
	call	INITIALISEMEMORY
	addi	s5,s5,%lo(.LANCHOR1)
	li	s4,255
	addi	s6,s6,-96
	li	s1,64
.L6:
	lbu	a5,0(s3)
	beq	a5,s4,.L2
	li	s2,0
	li	s0,0
.L4:
	li	a0,1
	call	get_beep_duration
	add	a5,s3,s0
	bne	a0,zero,.L3
	lbu	a2,0(a5)
	slli	s0,s0,1
	add	s0,s5,s0
	li	a1,0
	li	a0,1
	beq	a2,s4,.L3
	lhu	a3,0(s0)
	addi	s2,s2,1
	slli	s2,s2,16
	slli	a3,a3,4
	slli	a3,a3,16
	srli	a3,a3,16
	call	beep
	srli	s2,s2,16
.L3:
	add	a5,s3,s2
	lbu	a5,0(a5)
	mv	s0,s2
	bne	a5,s4,.L4
.L2:
	li	a1,0
	mv	a0,s6
	call	sleep
	li	a3,256
	li	a2,36
	li	a1,0
	li	a0,1
	call	beep
	li	a0,1
	call	await_beep
	li	a3,256
	li	a2,48
	li	a1,0
	li	a0,1
	call	beep
	li	a0,1
	call	await_beep
	li	a3,256
	li	a2,43
	li	a1,0
	li	a0,1
	call	beep
	li	a0,1
	call	await_beep
	li	a3,256
	li	a2,40
	li	a1,0
	li	a0,1
	call	beep
	li	a0,1
	call	await_beep
	li	a3,128
	li	a2,48
	li	a1,0
	li	a0,1
	call	beep
	li	a0,1
	call	await_beep
	li	a3,128
	li	a2,42
	li	a1,0
	li	a0,1
	call	beep
	li	a0,1
	call	await_beep
	li	a3,512
	li	a2,41
	li	a1,0
	li	a0,1
	call	beep
	li	a0,1
	call	await_beep
	li	a3,384
	li	a2,37
	li	a1,0
	li	a0,1
	call	beep
	li	a0,1
	call	await_beep
	li	a3,256
	li	a2,49
	li	a1,0
	li	a0,1
	call	beep
	li	a0,1
	call	await_beep
	li	a3,256
	li	a2,44
	li	a1,0
	li	a0,1
	call	beep
	li	a0,1
	call	await_beep
	li	a3,256
	li	a2,41
	li	a1,0
	li	a0,1
	call	beep
	li	a0,1
	call	await_beep
	li	a3,512
	li	a2,49
	li	a1,0
	li	a0,1
	call	beep
	li	a0,1
	call	await_beep
	li	a3,384
	li	a2,44
	li	a1,0
	li	a0,1
	call	beep
	li	a0,1
	call	await_beep
	li	a3,512
	li	a2,41
	li	a1,0
	li	a0,1
	call	beep
	li	a0,1
	call	await_beep
	li	a1,0
	mv	a0,s6
	call	sleep
	li	s0,1
.L5:
	mv	a2,s0
	li	a3,500
	li	a1,0
	li	a0,1
	call	beep
	li	a0,1
	call	await_beep
	addi	s0,s0,1
	li	a1,0
	li	a0,250
	andi	s0,s0,0xff
	call	sleep
	bne	s0,s1,.L5
	j	.L6
	.size	main, .-main
	.globl	size_treble
	.globl	tune_treble
	.section	.data.size_treble,"aw"
	.align	2
	.set	.LANCHOR1,. + 0
	.type	size_treble, @object
	.size	size_treble, 30
size_treble:
	.half	16
	.half	16
	.half	16
	.half	16
	.half	8
	.half	8
	.half	32
	.half	24
	.half	16
	.half	16
	.half	16
	.half	32
	.half	24
	.half	32
	.half	255
	.section	.data.tune_treble,"aw"
	.align	2
	.set	.LANCHOR0,. + 0
	.type	tune_treble, @object
	.size	tune_treble, 15
tune_treble:
	.ascii	"$0+(0*)%1,)1,)\377"
	.ident	"GCC: (Arch Linux Repositories) 10.2.0"
