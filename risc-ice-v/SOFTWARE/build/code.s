	.file	"life.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	1
	.globl	show
	.type	show, @function
show:
	ble	a2,zero,.L11
	addi	sp,sp,-64
	sw	ra,60(sp)
	sw	s0,56(sp)
	sw	s1,52(sp)
	sw	s2,48(sp)
	sw	s3,44(sp)
	sw	s4,40(sp)
	sw	s5,36(sp)
	sw	s6,32(sp)
	sw	s7,28(sp)
	sw	s8,24(sp)
	sw	s9,20(sp)
	sw	s10,16(sp)
	sw	s11,12(sp)
	mv	s4,a1
	mv	s9,a2
	slli	s10,a1,2
	mv	s7,a0
	li	s6,0
	li	s8,0
	li	s11,0
	j	.L3
.L6:
	slli	s5,s6,16
	srai	s5,s5,16
	addi	s3,s6,7
	slli	s3,s3,16
	srai	s3,s3,16
	mv	s2,s7
	mv	s0,s11
	li	s1,0
.L5:
	lw	a0,0(s2)
	seqz	a0,a0
	addi	a3,s0,7
	mv	a4,s3
	slli	a3,a3,16
	srai	a3,a3,16
	mv	a2,s5
	slli	a1,s0,16
	srai	a1,a1,16
	slli	a0,a0,6
	call	gpu_rectangle
	addi	s1,s1,1
	addi	s2,s2,4
	addi	s0,s0,8
	slli	s0,s0,16
	srli	s0,s0,16
	bne	s4,s1,.L5
.L7:
	addi	s8,s8,1
	addi	s6,s6,8
	slli	s6,s6,16
	srli	s6,s6,16
	add	s7,s7,s10
	beq	s9,s8,.L1
.L3:
	bgt	s4,zero,.L6
	j	.L7
.L1:
	lw	ra,60(sp)
	lw	s0,56(sp)
	lw	s1,52(sp)
	lw	s2,48(sp)
	lw	s3,44(sp)
	lw	s4,40(sp)
	lw	s5,36(sp)
	lw	s6,32(sp)
	lw	s7,28(sp)
	lw	s8,24(sp)
	lw	s9,20(sp)
	lw	s10,16(sp)
	lw	s11,12(sp)
	addi	sp,sp,64
	jr	ra
.L11:
	ret
	.size	show, .-show
	.align	1
	.globl	evolve
	.type	evolve, @function
evolve:
	addi	sp,sp,-48
	sw	s0,44(sp)
	sw	s1,40(sp)
	sw	s2,36(sp)
	sw	s3,32(sp)
	sw	s4,28(sp)
	sw	s5,24(sp)
	sw	s6,20(sp)
	sw	s7,16(sp)
	sw	s8,12(sp)
	sw	s9,8(sp)
	sw	s10,4(sp)
	addi	s0,sp,48
	mul	a5,a1,a2
	slli	a5,a5,2
	addi	a5,a5,15
	andi	a5,a5,-16
	sub	sp,sp,a5
	ble	a2,zero,.L14
	mv	t6,a0
	mv	a6,a1
	mv	t4,a2
	slli	t1,a1,2
	mv	s6,sp
	addi	t3,a2,2
	addi	t2,a2,-1
	mv	s8,s6
	mv	s7,a0
	addi	s10,a2,1
	slli	s10,s10,1
	addi	s1,a1,1
	slli	s1,s1,1
	mv	s9,a0
	li	s3,3
	li	s2,1
	li	s5,2
	li	s4,0
	j	.L23
.L40:
	addi	a1,a1,1
	beq	a1,t3,.L39
.L19:
	rem	a3,a1,t4
	mul	a3,a3,t1
	add	a3,t6,a3
	mv	a4,a7
.L18:
	rem	a5,a4,a6
	slli	a5,a5,2
	add	a5,a3,a5
	lw	a5,0(a5)
	snez	a5,a5
	add	a2,a2,a5
	addi	a4,a4,1
	bne	a4,a0,.L18
	j	.L40
.L39:
	lw	a4,0(t0)
	snez	a5,a4
	sub	a2,a2,a5
	mv	a5,s2
	beq	a2,s3,.L21
	mv	a5,s4
	beq	a2,s5,.L41
.L21:
	sw	a5,0(t5)
	addi	t5,t5,4
	addi	t0,t0,4
	addi	a0,a0,1
	addi	a7,a7,1
	beq	a0,s1,.L26
.L22:
	mv	a1,t2
	li	a2,0
	j	.L19
.L41:
	snez	a5,a4
	j	.L21
.L26:
	addi	t3,t3,1
	addi	t2,t2,1
	add	s6,s6,t1
	add	s9,s9,t1
	beq	t3,s10,.L42
.L23:
	ble	a6,zero,.L26
	addi	a0,a6,2
	addi	a7,a6,-1
	mv	t0,s9
	mv	t5,s6
	j	.L22
.L42:
	li	a1,0
	j	.L24
.L28:
	addi	a1,a1,1
	add	s8,s8,t1
	add	s7,s7,t1
	beq	t4,a1,.L14
.L24:
	mv	a3,s7
	mv	a4,s8
	li	a5,0
	ble	a6,zero,.L28
.L27:
	lw	a2,0(a4)
	sw	a2,0(a3)
	addi	a5,a5,1
	addi	a4,a4,4
	addi	a3,a3,4
	bne	a6,a5,.L27
	j	.L28
.L14:
	addi	sp,s0,-48
	lw	s0,44(sp)
	lw	s1,40(sp)
	lw	s2,36(sp)
	lw	s3,32(sp)
	lw	s4,28(sp)
	lw	s5,24(sp)
	lw	s6,20(sp)
	lw	s7,16(sp)
	lw	s8,12(sp)
	lw	s9,8(sp)
	lw	s10,4(sp)
	addi	sp,sp,48
	jr	ra
	.size	evolve, .-evolve
	.align	1
	.globl	game
	.type	game, @function
game:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	sw	s5,4(sp)
	sw	s6,0(sp)
	addi	s0,sp,32
	mv	s6,a0
	mv	s2,a1
	mul	a5,a1,a0
	slli	a5,a5,2
	addi	a5,a5,15
	andi	a5,a5,-16
	sub	sp,sp,a5
	mv	s4,sp
	ble	a0,zero,.L44
	slli	s5,a0,2
	srli	s5,s5,2
	li	s3,0
	j	.L45
.L46:
	li	a0,2
	call	rng
	mul	a5,s5,s1
	add	a5,a5,s3
	slli	a5,a5,2
	add	a5,s4,a5
	sw	a0,0(a5)
	addi	s1,s1,1
	bne	s2,s1,.L46
.L47:
	addi	s3,s3,1
	beq	s6,s3,.L44
.L45:
	li	s1,0
	bgt	s2,zero,.L46
	j	.L47
.L44:
	li	s1,1
	j	.L48
.L49:
	mv	a2,s2
	mv	a1,s6
	mv	a0,s4
	call	show
	mv	a2,s2
	mv	a1,s6
	mv	a0,s4
	call	evolve
	li	a0,200
	call	sleep
.L48:
	call	get_buttons
	beq	a0,s1,.L49
	addi	sp,s0,-32
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	lw	s4,8(sp)
	lw	s5,4(sp)
	lw	s6,0(sp)
	addi	sp,sp,32
	jr	ra
	.size	game, .-game
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-16
	sw	ra,12(sp)
	call	INITIALISEMEMORY
	call	gpu_cs
	call	tpu_cs
	li	a0,0
	call	terminal_showhide
	li	a2,4
	li	a1,0
	li	a0,0
	call	set_background
.L55:
	li	a1,60
	li	a0,80
	call	game
	j	.L55
	.size	main, .-main
	.ident	"GCC: (Arch Linux Repositories) 10.2.0"
