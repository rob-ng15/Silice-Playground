	.file	"PAWSlibrary.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0_a2p0_c2p0_b0p93"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.section	.text.njShowBits.part.0,"ax",@progbits
	.align	1
	.type	njShowBits.part.0, @function
njShowBits.part.0:
	lui	a4,%hi(nj)
	addi	a4,a4,%lo(nj)
	li	a6,524288
	add	a6,a4,a6
	lw	a3,444(a6)
	lw	a5,440(a6)
	ble	a0,a3,.L2
	li	t4,255
	li	t5,5
	li	t0,217
	li	t6,253
	li	t2,208
.L9:
	lw	a2,8(a4)
	addi	a1,a3,8
	slli	a5,a5,8
	ble	a2,zero,.L15
	lw	a7,4(a4)
	addi	t3,a2,-1
	addi	t1,a7,1
	sw	t1,4(a4)
	lbu	t1,0(a7)
	sw	t3,8(a4)
	sw	a1,444(a6)
	or	a5,t1,a5
	sw	a5,440(a6)
	beq	t1,t4,.L16
.L11:
	mv	a3,a1
	bgt	a0,a3,.L9
.L2:
	li	a4,1
	sub	a3,a3,a0
	sll	a0,a4,a0
	sra	a5,a5,a3
	addi	a0,a0,-1
	and	a0,a5,a0
	ret
.L16:
	beq	t3,zero,.L5
	addi	t1,a7,2
	sw	t1,4(a4)
	lbu	a7,1(a7)
	addi	a2,a2,-2
	sw	a2,8(a4)
	beq	a7,t0,.L6
	addi	a2,a7,-1
	andi	a2,a2,0xff
	bgtu	a2,t6,.L11
	andi	a2,a7,248
	beq	a2,t2,.L8
.L5:
	sw	t5,0(a4)
	mv	a3,a1
	bgt	a0,a3,.L9
	j	.L2
.L15:
	ori	a5,a5,255
	sw	a5,440(a6)
	sw	a1,444(a6)
	mv	a3,a1
	bgt	a0,a3,.L9
	j	.L2
.L6:
	sw	zero,8(a4)
	mv	a3,a1
	bgt	a0,a3,.L9
	j	.L2
.L8:
	slli	a5,a5,8
	or	a5,a5,a7
	addi	a3,a3,16
	sw	a5,440(a6)
	sw	a3,444(a6)
	bgt	a0,a3,.L9
	j	.L2
	.size	njShowBits.part.0, .-njShowBits.part.0
	.section	.text.njGetVLC,"ax",@progbits
	.align	1
	.type	njGetVLC, @function
njGetVLC:
	addi	sp,sp,-32
	sw	s0,24(sp)
	mv	s0,a0
	li	a0,16
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	ra,28(sp)
	sw	s3,12(sp)
	mv	s2,a1
	call	njShowBits.part.0
	slli	a0,a0,1
	add	s0,s0,a0
	lbu	s1,0(s0)
	bne	s1,zero,.L18
	lui	a5,%hi(nj)
	li	a4,5
	sw	a4,%lo(nj)(a5)
.L17:
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	mv	a0,s1
	lw	s1,20(sp)
	addi	sp,sp,32
	jr	ra
.L18:
	lui	s3,%hi(nj+524288)
	addi	s3,s3,%lo(nj+524288)
	lw	a5,444(s3)
	ble	s1,a5,.L20
	mv	a0,s1
	call	njShowBits.part.0
	lw	a5,444(s3)
.L20:
	sub	a5,a5,s1
	sw	a5,444(s3)
	lbu	s0,1(s0)
	beq	s2,zero,.L21
	sb	s0,0(s2)
.L21:
	andi	s0,s0,15
	li	s1,0
	beq	s0,zero,.L17
	mv	a0,s0
	call	njShowBits.part.0
	lw	a5,444(s3)
	mv	s1,a0
	ble	s0,a5,.L22
	mv	a0,s0
	call	njShowBits.part.0
	lw	a5,444(s3)
.L22:
	sub	a5,a5,s0
	addi	a4,s0,-1
	sw	a5,444(s3)
	li	a5,1
	sll	a5,a5,a4
	ble	a5,s1,.L17
	li	a5,-1
	lw	ra,28(sp)
	sll	a5,a5,s0
	lw	s0,24(sp)
	addi	a5,a5,1
	add	s1,s1,a5
	lw	s2,16(sp)
	lw	s3,12(sp)
	mv	a0,s1
	lw	s1,20(sp)
	addi	sp,sp,32
	jr	ra
	.size	njGetVLC, .-njGetVLC
	.section	.text.njDecodeLength,"ax",@progbits
	.align	1
	.type	njDecodeLength, @function
njDecodeLength:
	lui	a5,%hi(nj)
	addi	a5,a5,%lo(nj)
	lw	a2,8(a5)
	li	a4,1
	ble	a2,a4,.L32
	lw	a1,4(a5)
	lbu	a4,1(a1)
	lbu	a3,0(a1)
	slli	a4,a4,8
	or	a4,a4,a3
	slli	a3,a4,8
	srli	a4,a4,8
	or	a4,a3,a4
	slli	a4,a4,16
	srli	a4,a4,16
	sw	a4,12(a5)
	bge	a2,a4,.L33
.L32:
	li	a4,5
	sw	a4,0(a5)
	ret
.L33:
	addi	a1,a1,2
	addi	a2,a2,-2
	addi	a4,a4,-2
	sw	a1,4(a5)
	sw	a2,8(a5)
	sw	a4,12(a5)
	ret
	.size	njDecodeLength, .-njDecodeLength
	.section	.text.CSRisa,"ax",@progbits
	.align	1
	.globl	CSRisa
	.type	CSRisa, @function
CSRisa:
 #APP
# 25 "c/PAWSlibrary.c" 1
	csrr a0, 0x301
# 0 "" 2
 #NO_APP
	ret
	.size	CSRisa, .-CSRisa
	.section	.text.CSRcycles,"ax",@progbits
	.align	1
	.globl	CSRcycles
	.type	CSRcycles, @function
CSRcycles:
 #APP
# 31 "c/PAWSlibrary.c" 1
	rdcycle a0
# 0 "" 2
 #NO_APP
	ret
	.size	CSRcycles, .-CSRcycles
	.section	.text.CSRinstructions,"ax",@progbits
	.align	1
	.globl	CSRinstructions
	.type	CSRinstructions, @function
CSRinstructions:
 #APP
# 37 "c/PAWSlibrary.c" 1
	rdinstret a0
# 0 "" 2
 #NO_APP
	ret
	.size	CSRinstructions, .-CSRinstructions
	.section	.text.CSRtime,"ax",@progbits
	.align	1
	.globl	CSRtime
	.type	CSRtime, @function
CSRtime:
 #APP
# 43 "c/PAWSlibrary.c" 1
	rdtime a0
# 0 "" 2
 #NO_APP
	ret
	.size	CSRtime, .-CSRtime
	.section	.text.outputcharacter,"ax",@progbits
	.align	1
	.globl	outputcharacter
	.type	outputcharacter, @function
outputcharacter:
	lui	a2,%hi(.LANCHOR0)
	lui	a3,%hi(.LANCHOR1)
	addi	a2,a2,%lo(.LANCHOR0)
	addi	a3,a3,%lo(.LANCHOR1)
	li	a1,10
.L40:
	lw	a4,0(a2)
.L39:
	lbu	a5,0(a4)
	andi	a5,a5,2
	bne	a5,zero,.L39
	lw	a5,0(a3)
	sb	a0,0(a5)
	bne	a0,a1,.L43
	li	a0,13
	j	.L40
.L43:
	ret
	.size	outputcharacter, .-outputcharacter
	.section	.text.character_available,"ax",@progbits
	.align	1
	.globl	character_available
	.type	character_available, @function
character_available:
	lui	a5,%hi(.LANCHOR0)
	lw	a5,%lo(.LANCHOR0)(a5)
	lbu	a0,0(a5)
	andi	a0,a0,1
	ret
	.size	character_available, .-character_available
	.section	.text.inputcharacter,"ax",@progbits
	.align	1
	.globl	inputcharacter
	.type	inputcharacter, @function
inputcharacter:
	lui	a5,%hi(.LANCHOR0)
	lw	a4,%lo(.LANCHOR0)(a5)
.L46:
	lbu	a5,0(a4)
	andi	a5,a5,1
	beq	a5,zero,.L46
	lui	a5,%hi(.LANCHOR1)
	lw	a5,%lo(.LANCHOR1)(a5)
	lbu	a0,0(a5)
	ret
	.size	inputcharacter, .-inputcharacter
	.section	.text.ps2_character_available,"ax",@progbits
	.align	1
	.globl	ps2_character_available
	.type	ps2_character_available, @function
ps2_character_available:
	lui	a5,%hi(.LANCHOR2)
	lw	a5,%lo(.LANCHOR2)(a5)
	lbu	a0,0(a5)
	ret
	.size	ps2_character_available, .-ps2_character_available
	.section	.text.ps2_inputcharacter,"ax",@progbits
	.align	1
	.globl	ps2_inputcharacter
	.type	ps2_inputcharacter, @function
ps2_inputcharacter:
	lui	a5,%hi(.LANCHOR2)
	lw	a4,%lo(.LANCHOR2)(a5)
.L51:
	lbu	a5,0(a4)
	beq	a5,zero,.L51
	lui	a5,%hi(.LANCHOR3)
	lw	a5,%lo(.LANCHOR3)(a5)
	lbu	a0,0(a5)
	ret
	.size	ps2_inputcharacter, .-ps2_inputcharacter
	.section	.text.rng,"ax",@progbits
	.align	1
	.globl	rng
	.type	rng, @function
rng:
	li	a4,8
	mv	a5,a0
	beq	a0,a4,.L55
	bleu	a0,a4,.L73
	li	a4,32
	beq	a0,a4,.L60
	li	a4,64
	bne	a0,a4,.L74
	lui	a5,%hi(.LANCHOR4)
	lw	a5,%lo(.LANCHOR4)(a5)
	lhu	a0,0(a5)
	andi	a0,a0,63
	ret
.L73:
	li	a0,0
	beq	a5,zero,.L57
	addi	a4,a5,-1
	slli	a4,a4,16
	srli	a4,a4,16
	li	a3,1
	bgtu	a4,a3,.L66
	lui	a5,%hi(.LANCHOR4)
	lw	a5,%lo(.LANCHOR4)(a5)
	lhu	a0,0(a5)
	andi	a0,a0,1
	ret
.L66:
	li	a4,255
.L58:
	lui	a3,%hi(.LANCHOR5)
	lw	a3,%lo(.LANCHOR5)(a3)
.L63:
	lhu	a0,0(a3)
	and	a0,a0,a4
	bleu	a5,a0,.L63
.L57:
	ret
.L60:
	lui	a5,%hi(.LANCHOR4)
	lw	a5,%lo(.LANCHOR4)(a5)
	lhu	a0,0(a5)
	andi	a0,a0,31
	ret
.L55:
	lui	a5,%hi(.LANCHOR4)
	lw	a5,%lo(.LANCHOR4)(a5)
	lhu	a0,0(a5)
	andi	a0,a0,7
	ret
.L74:
	li	a4,255
	bleu	a0,a4,.L66
	li	a4,511
	bleu	a0,a4,.L58
	li	a4,1023
	bleu	a0,a4,.L58
	li	a4,65536
	addi	a4,a4,-1
	j	.L58
	.size	rng, .-rng
	.section	.text.sleep,"ax",@progbits
	.align	1
	.globl	sleep
	.type	sleep, @function
sleep:
	beq	a1,zero,.L76
	li	a5,1
	bne	a1,a5,.L84
	lui	a5,%hi(.LANCHOR7)
	lw	a4,%lo(.LANCHOR7)(a5)
	sh	a0,0(a4)
.L80:
	lhu	a5,0(a4)
	bne	a5,zero,.L80
	ret
.L84:
	ret
.L76:
	lui	a5,%hi(.LANCHOR6)
	lw	a4,%lo(.LANCHOR6)(a5)
	sh	a0,0(a4)
.L79:
	lhu	a5,0(a4)
	bne	a5,zero,.L79
	ret
	.size	sleep, .-sleep
	.section	.text.set_timer1khz,"ax",@progbits
	.align	1
	.globl	set_timer1khz
	.type	set_timer1khz, @function
set_timer1khz:
	beq	a1,zero,.L86
	li	a5,1
	bne	a1,a5,.L89
	lui	a5,%hi(.LANCHOR9)
	lw	a5,%lo(.LANCHOR9)(a5)
	sh	a0,0(a5)
	ret
.L89:
	ret
.L86:
	lui	a5,%hi(.LANCHOR8)
	lw	a5,%lo(.LANCHOR8)(a5)
	sh	a0,0(a5)
	ret
	.size	set_timer1khz, .-set_timer1khz
	.section	.text.get_timer1khz,"ax",@progbits
	.align	1
	.globl	get_timer1khz
	.type	get_timer1khz, @function
get_timer1khz:
	beq	a0,zero,.L91
	lui	a5,%hi(.LANCHOR9)
	lw	a5,%lo(.LANCHOR9)(a5)
	lhu	a0,0(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
.L91:
	lui	a5,%hi(.LANCHOR8)
	lw	a5,%lo(.LANCHOR8)(a5)
	lhu	a0,0(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
	.size	get_timer1khz, .-get_timer1khz
	.section	.text.wait_timer1khz,"ax",@progbits
	.align	1
	.globl	wait_timer1khz
	.type	wait_timer1khz, @function
wait_timer1khz:
	lui	a5,%hi(.LANCHOR8)
	lw	a3,%lo(.LANCHOR8)(a5)
	lui	a5,%hi(.LANCHOR9)
	lw	a4,%lo(.LANCHOR9)(a5)
.L97:
	beq	a0,zero,.L94
	lhu	a5,0(a4)
	bne	a5,zero,.L97
	ret
.L94:
	lhu	a5,0(a3)
	bne	a5,zero,.L94
	ret
	.size	wait_timer1khz, .-wait_timer1khz
	.section	.text.get_timer1hz,"ax",@progbits
	.align	1
	.globl	get_timer1hz
	.type	get_timer1hz, @function
get_timer1hz:
	beq	a0,zero,.L99
	lui	a5,%hi(.LANCHOR10)
	lw	a5,%lo(.LANCHOR10)(a5)
	lhu	a0,0(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
.L99:
	lui	a5,%hi(.LANCHOR11)
	lw	a5,%lo(.LANCHOR11)(a5)
	lhu	a0,0(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
	.size	get_timer1hz, .-get_timer1hz
	.section	.text.reset_timer1hz,"ax",@progbits
	.align	1
	.globl	reset_timer1hz
	.type	reset_timer1hz, @function
reset_timer1hz:
	beq	a0,zero,.L102
	li	a5,1
	bne	a0,a5,.L105
	lui	a5,%hi(.LANCHOR10)
	lw	a5,%lo(.LANCHOR10)(a5)
	sh	a0,0(a5)
	ret
.L105:
	ret
.L102:
	lui	a5,%hi(.LANCHOR11)
	lw	a5,%lo(.LANCHOR11)(a5)
	li	a4,1
	sh	a4,0(a5)
	ret
	.size	reset_timer1hz, .-reset_timer1hz
	.section	.text.systemclock,"ax",@progbits
	.align	1
	.globl	systemclock
	.type	systemclock, @function
systemclock:
	lui	a5,%hi(.LANCHOR12)
	lw	a5,%lo(.LANCHOR12)(a5)
	lhu	a0,0(a5)
	ret
	.size	systemclock, .-systemclock
	.section	.text.beep,"ax",@progbits
	.align	1
	.globl	beep
	.type	beep, @function
beep:
	lui	a5,%hi(.LANCHOR13)
	lw	a5,%lo(.LANCHOR13)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(.LANCHOR14)
	lw	a5,%lo(.LANCHOR14)(a5)
	sb	a2,0(a5)
	lui	a5,%hi(.LANCHOR15)
	lw	a4,%lo(.LANCHOR15)(a5)
	lui	a5,%hi(.LANCHOR16)
	lw	a5,%lo(.LANCHOR16)(a5)
	sh	a3,0(a4)
	sb	a0,0(a5)
	ret
	.size	beep, .-beep
	.section	.text.await_beep,"ax",@progbits
	.align	1
	.globl	await_beep
	.type	await_beep, @function
await_beep:
	lui	a5,%hi(.LANCHOR17)
	lw	a2,%lo(.LANCHOR17)(a5)
	lui	a5,%hi(.LANCHOR18)
	lw	a3,%lo(.LANCHOR18)(a5)
	andi	a5,a0,1
	andi	a0,a0,2
.L117:
	beq	a5,zero,.L109
.L119:
	lbu	a4,0(a2)
	beq	a4,zero,.L109
	beq	a0,zero,.L117
	lbu	a4,0(a3)
	bne	a5,zero,.L119
.L109:
	beq	a0,zero,.L120
	lbu	a4,0(a3)
	bne	a4,zero,.L117
	ret
.L120:
	ret
	.size	await_beep, .-await_beep
	.section	.text.get_beep_active,"ax",@progbits
	.align	1
	.globl	get_beep_active
	.type	get_beep_active, @function
get_beep_active:
	andi	a4,a0,1
	mv	a5,a0
	li	a0,0
	beq	a4,zero,.L122
	lui	a4,%hi(.LANCHOR17)
	lw	a4,%lo(.LANCHOR17)(a4)
	lbu	a0,0(a4)
	snez	a0,a0
.L122:
	andi	a5,a5,2
	beq	a5,zero,.L123
	lui	a5,%hi(.LANCHOR18)
	lw	a5,%lo(.LANCHOR18)(a5)
	lbu	a5,0(a5)
	beq	a5,zero,.L123
	li	a0,1
.L123:
	ret
	.size	get_beep_active, .-get_beep_active
	.section	.text.sdcard_wait,"ax",@progbits
	.align	1
	.globl	sdcard_wait
	.type	sdcard_wait, @function
sdcard_wait:
	lui	a5,%hi(.LANCHOR19)
	lw	a4,%lo(.LANCHOR19)(a5)
.L131:
	lbu	a5,0(a4)
	beq	a5,zero,.L131
	ret
	.size	sdcard_wait, .-sdcard_wait
	.section	.text.sdcard_readsector,"ax",@progbits
	.align	1
	.globl	sdcard_readsector
	.type	sdcard_readsector, @function
sdcard_readsector:
	lui	a3,%hi(.LANCHOR19)
	addi	a3,a3,%lo(.LANCHOR19)
	lw	a4,0(a3)
.L135:
	lbu	a5,0(a4)
	beq	a5,zero,.L135
	lui	a5,%hi(.LANCHOR20)
	lw	a2,%lo(.LANCHOR20)(a5)
	lui	a5,%hi(.LANCHOR21)
	lw	a4,%lo(.LANCHOR21)(a5)
	lui	a5,%hi(.LANCHOR22)
	lw	a5,%lo(.LANCHOR22)(a5)
	srli	a6,a0,16
	slli	a0,a0,16
	sh	a6,0(a2)
	srli	a0,a0,16
	sh	a0,0(a4)
	li	a4,1
	sb	a4,0(a5)
	lw	a4,0(a3)
.L136:
	lbu	a5,0(a4)
	beq	a5,zero,.L136
	lui	a6,%hi(.LANCHOR23)
	lui	a0,%hi(.LANCHOR24)
	li	a5,0
	addi	a6,a6,%lo(.LANCHOR23)
	addi	a0,a0,%lo(.LANCHOR24)
	li	a7,512
.L137:
	lw	a3,0(a6)
	lw	a4,0(a0)
	slli	a2,a5,16
	srli	a2,a2,16
	sh	a2,0(a3)
	lbu	a3,0(a4)
	add	a4,a1,a5
	addi	a5,a5,1
	sb	a3,0(a4)
	bne	a5,a7,.L137
	ret
	.size	sdcard_readsector, .-sdcard_readsector
	.section	.text.set_leds,"ax",@progbits
	.align	1
	.globl	set_leds
	.type	set_leds, @function
set_leds:
	lui	a5,%hi(.LANCHOR25)
	lw	a5,%lo(.LANCHOR25)(a5)
	sb	a0,0(a5)
	ret
	.size	set_leds, .-set_leds
	.section	.text.get_buttons,"ax",@progbits
	.align	1
	.globl	get_buttons
	.type	get_buttons, @function
get_buttons:
	lui	a5,%hi(.LANCHOR26)
	lw	a5,%lo(.LANCHOR26)(a5)
	lbu	a0,0(a5)
	ret
	.size	get_buttons, .-get_buttons
	.section	.text.wait_gpu,"ax",@progbits
	.align	1
	.globl	wait_gpu
	.type	wait_gpu, @function
wait_gpu:
	lui	a5,%hi(.LANCHOR27)
	lw	a4,%lo(.LANCHOR27)(a5)
.L146:
	lbu	a5,0(a4)
	bne	a5,zero,.L146
	ret
	.size	wait_gpu, .-wait_gpu
	.section	.text.await_vblank,"ax",@progbits
	.align	1
	.globl	await_vblank
	.type	await_vblank, @function
await_vblank:
	lui	a5,%hi(.LANCHOR28)
	lw	a4,%lo(.LANCHOR28)(a5)
.L149:
	lbu	a5,0(a4)
	beq	a5,zero,.L149
	ret
	.size	await_vblank, .-await_vblank
	.section	.text.screen_mode,"ax",@progbits
	.align	1
	.globl	screen_mode
	.type	screen_mode, @function
screen_mode:
	lui	a5,%hi(.LANCHOR29)
	lw	a5,%lo(.LANCHOR29)(a5)
	sb	a0,0(a5)
	ret
	.size	screen_mode, .-screen_mode
	.section	.text.bitmap_display,"ax",@progbits
	.align	1
	.globl	bitmap_display
	.type	bitmap_display, @function
bitmap_display:
	lui	a5,%hi(.LANCHOR28)
	lw	a4,%lo(.LANCHOR28)(a5)
.L154:
	lbu	a5,0(a4)
	beq	a5,zero,.L154
	lui	a5,%hi(.LANCHOR30)
	lw	a5,%lo(.LANCHOR30)(a5)
	sb	a0,0(a5)
	ret
	.size	bitmap_display, .-bitmap_display
	.section	.text.bitmap_draw,"ax",@progbits
	.align	1
	.globl	bitmap_draw
	.type	bitmap_draw, @function
bitmap_draw:
	lui	a5,%hi(.LANCHOR31)
	lw	a4,%lo(.LANCHOR31)(a5)
.L158:
	lbu	a5,0(a4)
	beq	a5,zero,.L158
	lui	a5,%hi(.LANCHOR32)
	lw	a5,%lo(.LANCHOR32)(a5)
	sb	a0,0(a5)
	ret
	.size	bitmap_draw, .-bitmap_draw
	.section	.text.set_background,"ax",@progbits
	.align	1
	.globl	set_background
	.type	set_background, @function
set_background:
	lui	a5,%hi(.LANCHOR33)
	lw	a5,%lo(.LANCHOR33)(a5)
	sb	zero,0(a5)
	lui	a5,%hi(.LANCHOR34)
	lw	a5,%lo(.LANCHOR34)(a5)
	sb	a0,0(a5)
	lui	a5,%hi(.LANCHOR35)
	lw	a5,%lo(.LANCHOR35)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(.LANCHOR36)
	lw	a5,%lo(.LANCHOR36)(a5)
	sb	a2,0(a5)
	ret
	.size	set_background, .-set_background
	.section	.text.copper_startstop,"ax",@progbits
	.align	1
	.globl	copper_startstop
	.type	copper_startstop, @function
copper_startstop:
	lui	a5,%hi(.LANCHOR33)
	lw	a5,%lo(.LANCHOR33)(a5)
	sb	a0,0(a5)
	ret
	.size	copper_startstop, .-copper_startstop
	.section	.text.copper_program,"ax",@progbits
	.align	1
	.globl	copper_program
	.type	copper_program, @function
copper_program:
	lui	a7,%hi(.LANCHOR37)
	lw	a7,%lo(.LANCHOR37)(a7)
	sb	a0,0(a7)
	lui	a0,%hi(.LANCHOR38)
	lw	a0,%lo(.LANCHOR38)(a0)
	sb	a1,0(a0)
	lui	a1,%hi(.LANCHOR39)
	lw	a1,%lo(.LANCHOR39)(a1)
	sb	a2,0(a1)
	lui	a2,%hi(.LANCHOR40)
	lw	a1,%lo(.LANCHOR40)(a2)
	lui	a2,%hi(.LANCHOR41)
	lw	a2,%lo(.LANCHOR41)(a2)
	sh	a3,0(a1)
	sb	a4,0(a2)
	lui	a4,%hi(.LANCHOR42)
	lw	a4,%lo(.LANCHOR42)(a4)
	sb	a5,0(a4)
	lui	a5,%hi(.LANCHOR43)
	lw	a5,%lo(.LANCHOR43)(a5)
	li	a4,1
	sb	a6,0(a5)
	lui	a5,%hi(.LANCHOR44)
	lw	a5,%lo(.LANCHOR44)(a5)
	sb	a4,0(a5)
	ret
	.size	copper_program, .-copper_program
	.section	.text.set_tilemap_tile,"ax",@progbits
	.align	1
	.globl	set_tilemap_tile
	.type	set_tilemap_tile, @function
set_tilemap_tile:
	beq	a0,zero,.L165
	li	a6,1
	bne	a0,a6,.L172
	lui	a0,%hi(.LANCHOR52)
	lw	a6,%lo(.LANCHOR52)(a0)
.L169:
	lbu	a0,0(a6)
	bne	a0,zero,.L169
	lui	a0,%hi(.LANCHOR53)
	lw	a0,%lo(.LANCHOR53)(a0)
	sb	a1,0(a0)
	lui	a1,%hi(.LANCHOR54)
	lw	a1,%lo(.LANCHOR54)(a1)
	sb	a2,0(a1)
	lui	a2,%hi(.LANCHOR55)
	lw	a2,%lo(.LANCHOR55)(a2)
	sb	a3,0(a2)
	lui	a3,%hi(.LANCHOR56)
	lw	a3,%lo(.LANCHOR56)(a3)
	sb	a4,0(a3)
	lui	a4,%hi(.LANCHOR57)
	lw	a4,%lo(.LANCHOR57)(a4)
	sb	a5,0(a4)
	lui	a5,%hi(.LANCHOR58)
	lw	a5,%lo(.LANCHOR58)(a5)
	li	a4,1
	sb	a4,0(a5)
	ret
.L172:
	ret
.L165:
	lui	a0,%hi(.LANCHOR45)
	lw	a6,%lo(.LANCHOR45)(a0)
.L168:
	lbu	a0,0(a6)
	bne	a0,zero,.L168
	lui	a0,%hi(.LANCHOR46)
	lw	a0,%lo(.LANCHOR46)(a0)
	sb	a1,0(a0)
	lui	a1,%hi(.LANCHOR47)
	lw	a1,%lo(.LANCHOR47)(a1)
	sb	a2,0(a1)
	lui	a2,%hi(.LANCHOR48)
	lw	a2,%lo(.LANCHOR48)(a2)
	sb	a3,0(a2)
	lui	a3,%hi(.LANCHOR49)
	lw	a3,%lo(.LANCHOR49)(a3)
	sb	a4,0(a3)
	lui	a4,%hi(.LANCHOR50)
	lw	a4,%lo(.LANCHOR50)(a4)
	sb	a5,0(a4)
	lui	a5,%hi(.LANCHOR51)
	lw	a5,%lo(.LANCHOR51)(a5)
	li	a4,1
	sb	a4,0(a5)
	ret
	.size	set_tilemap_tile, .-set_tilemap_tile
	.section	.text.set_tilemap_bitmap,"ax",@progbits
	.align	1
	.globl	set_tilemap_bitmap
	.type	set_tilemap_bitmap, @function
set_tilemap_bitmap:
	beq	a0,zero,.L174
	li	a5,1
	bne	a0,a5,.L182
	lui	a5,%hi(.LANCHOR62)
	lw	a5,%lo(.LANCHOR62)(a5)
	lui	a0,%hi(.LANCHOR63)
	addi	a0,a0,%lo(.LANCHOR63)
	sb	a1,0(a5)
	lui	a1,%hi(.LANCHOR64)
	li	a5,0
	addi	a1,a1,%lo(.LANCHOR64)
	li	a6,16
.L178:
	lw	a4,0(a0)
	andi	a3,a5,0xff
	addi	a5,a5,1
	sb	a3,0(a4)
	lhu	a3,0(a2)
	lw	a4,0(a1)
	addi	a2,a2,2
	sh	a3,0(a4)
	bne	a5,a6,.L178
	ret
.L182:
	ret
.L174:
	lui	a5,%hi(.LANCHOR59)
	lw	a5,%lo(.LANCHOR59)(a5)
	lui	a0,%hi(.LANCHOR60)
	addi	a0,a0,%lo(.LANCHOR60)
	sb	a1,0(a5)
	lui	a1,%hi(.LANCHOR61)
	li	a5,0
	addi	a1,a1,%lo(.LANCHOR61)
	li	a6,16
.L177:
	lw	a4,0(a0)
	andi	a3,a5,0xff
	addi	a5,a5,1
	sb	a3,0(a4)
	lhu	a3,0(a2)
	lw	a4,0(a1)
	addi	a2,a2,2
	sh	a3,0(a4)
	bne	a5,a6,.L177
	ret
	.size	set_tilemap_bitmap, .-set_tilemap_bitmap
	.section	.text.tilemap_scrollwrapclear,"ax",@progbits
	.align	1
	.globl	tilemap_scrollwrapclear
	.type	tilemap_scrollwrapclear, @function
tilemap_scrollwrapclear:
	beq	a0,zero,.L184
	li	a5,1
	bne	a0,a5,.L194
	lui	a5,%hi(.LANCHOR52)
	lw	a4,%lo(.LANCHOR52)(a5)
.L189:
	lbu	a5,0(a4)
	bne	a5,zero,.L189
	lui	a5,%hi(.LANCHOR66)
	addi	a5,a5,%lo(.LANCHOR66)
.L193:
	lw	a4,0(a5)
	sb	a1,0(a4)
	lw	a5,0(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L194:
	lui	a5,%hi(.LANCHOR66)
	addi	a5,a5,%lo(.LANCHOR66)
	lw	a5,0(a5)
	lbu	a0,0(a5)
	andi	a0,a0,0xff
	ret
.L184:
	lui	a5,%hi(.LANCHOR45)
	lw	a4,%lo(.LANCHOR45)(a5)
.L187:
	lbu	a5,0(a4)
	bne	a5,zero,.L187
	lui	a5,%hi(.LANCHOR65)
	addi	a5,a5,%lo(.LANCHOR65)
	j	.L193
	.size	tilemap_scrollwrapclear, .-tilemap_scrollwrapclear
	.section	.text.bitmap_scrollwrap,"ax",@progbits
	.align	1
	.globl	bitmap_scrollwrap
	.type	bitmap_scrollwrap, @function
bitmap_scrollwrap:
	lui	a5,%hi(.LANCHOR27)
	lw	a4,%lo(.LANCHOR27)(a5)
.L196:
	lbu	a5,0(a4)
	bne	a5,zero,.L196
	lui	a5,%hi(.LANCHOR67)
	lw	a5,%lo(.LANCHOR67)(a5)
	sb	a0,0(a5)
	ret
	.size	bitmap_scrollwrap, .-bitmap_scrollwrap
	.section	.text.gpu_dither,"ax",@progbits
	.align	1
	.globl	gpu_dither
	.type	gpu_dither, @function
gpu_dither:
	lui	a5,%hi(.LANCHOR68)
	lw	a5,%lo(.LANCHOR68)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(.LANCHOR69)
	lw	a5,%lo(.LANCHOR69)(a5)
	sb	a0,0(a5)
	ret
	.size	gpu_dither, .-gpu_dither
	.section	.text.gpu_pixel,"ax",@progbits
	.align	1
	.globl	gpu_pixel
	.type	gpu_pixel, @function
gpu_pixel:
	lui	a5,%hi(.LANCHOR70)
	lw	a5,%lo(.LANCHOR70)(a5)
	lui	a4,%hi(.LANCHOR27)
	sb	a0,0(a5)
	lui	a5,%hi(.LANCHOR71)
	lw	a3,%lo(.LANCHOR71)(a5)
	lui	a5,%hi(.LANCHOR72)
	lw	a5,%lo(.LANCHOR72)(a5)
	lw	a4,%lo(.LANCHOR27)(a4)
	sh	a1,0(a3)
	sh	a2,0(a5)
.L200:
	lbu	a5,0(a4)
	bne	a5,zero,.L200
	lui	a5,%hi(.LANCHOR73)
	lw	a5,%lo(.LANCHOR73)(a5)
	li	a4,1
	sb	a4,0(a5)
	ret
	.size	gpu_pixel, .-gpu_pixel
	.section	.text.gpu_line,"ax",@progbits
	.align	1
	.globl	gpu_line
	.type	gpu_line, @function
gpu_line:
	lui	a5,%hi(.LANCHOR70)
	lw	a5,%lo(.LANCHOR70)(a5)
	sb	a0,0(a5)
	lui	a5,%hi(.LANCHOR71)
	lw	a5,%lo(.LANCHOR71)(a5)
	lui	a0,%hi(.LANCHOR72)
	lw	a6,%lo(.LANCHOR72)(a0)
	lui	a0,%hi(.LANCHOR74)
	lw	a0,%lo(.LANCHOR74)(a0)
	sh	a1,0(a5)
	lui	a5,%hi(.LANCHOR75)
	lw	a5,%lo(.LANCHOR75)(a5)
	sh	a2,0(a6)
	lui	a2,%hi(.LANCHOR27)
	lw	a2,%lo(.LANCHOR27)(a2)
	sh	a3,0(a0)
	sh	a4,0(a5)
.L203:
	lbu	a5,0(a2)
	bne	a5,zero,.L203
	lui	a5,%hi(.LANCHOR73)
	lw	a5,%lo(.LANCHOR73)(a5)
	li	a4,2
	sb	a4,0(a5)
	ret
	.size	gpu_line, .-gpu_line
	.section	.text.gpu_box,"ax",@progbits
	.align	1
	.globl	gpu_box
	.type	gpu_box, @function
gpu_box:
	lui	t0,%hi(.LANCHOR70)
	addi	t0,t0,%lo(.LANCHOR70)
	lw	a5,0(t0)
	lui	t6,%hi(.LANCHOR71)
	addi	t6,t6,%lo(.LANCHOR71)
	sb	a0,0(a5)
	lui	t5,%hi(.LANCHOR72)
	lw	a5,0(t6)
	addi	t5,t5,%lo(.LANCHOR72)
	lui	t4,%hi(.LANCHOR74)
	lw	a6,0(t5)
	addi	t4,t4,%lo(.LANCHOR74)
	lui	t3,%hi(.LANCHOR75)
	lw	a7,0(t4)
	addi	t3,t3,%lo(.LANCHOR75)
	sh	a1,0(a5)
	lui	t1,%hi(.LANCHOR27)
	lw	a5,0(t3)
	addi	t1,t1,%lo(.LANCHOR27)
	sh	a2,0(a6)
	lw	a6,0(t1)
	sh	a3,0(a7)
	sh	a2,0(a5)
.L206:
	lbu	a5,0(a6)
	bne	a5,zero,.L206
	lui	a7,%hi(.LANCHOR73)
	addi	a7,a7,%lo(.LANCHOR73)
	lw	a5,0(a7)
	li	a6,2
	sb	a6,0(a5)
	lw	a5,0(t0)
	sb	a0,0(a5)
	lw	a5,0(t6)
	lw	a6,0(t5)
	lw	t2,0(t4)
	sh	a3,0(a5)
	lw	a5,0(t3)
	sh	a2,0(a6)
	lw	a6,0(t1)
	sh	a3,0(t2)
	sh	a4,0(a5)
.L207:
	lbu	a5,0(a6)
	bne	a5,zero,.L207
	lw	a5,0(a7)
	li	a6,2
	sb	a6,0(a5)
	lw	a5,0(t0)
	sb	a0,0(a5)
	lw	a5,0(t6)
	lw	t2,0(t5)
	lw	a6,0(t4)
	sh	a3,0(a5)
	lw	a5,0(t3)
	sh	a4,0(t2)
	lw	a3,0(t1)
	sh	a1,0(a6)
	sh	a4,0(a5)
.L208:
	lbu	a5,0(a3)
	bne	a5,zero,.L208
	lw	a5,0(a7)
	li	a3,2
	sb	a3,0(a5)
	lw	a5,0(t0)
	sb	a0,0(a5)
	lw	a5,0(t6)
	lw	a0,0(t5)
	lw	a3,0(t4)
	sh	a1,0(a5)
	lw	a5,0(t3)
	sh	a4,0(a0)
	lw	a4,0(t1)
	sh	a1,0(a3)
	sh	a2,0(a5)
.L209:
	lbu	a5,0(a4)
	bne	a5,zero,.L209
	lw	a5,0(a7)
	li	a4,2
	sb	a4,0(a5)
	ret
	.size	gpu_box, .-gpu_box
	.section	.text.gpu_rectangle,"ax",@progbits
	.align	1
	.globl	gpu_rectangle
	.type	gpu_rectangle, @function
gpu_rectangle:
	lui	a5,%hi(.LANCHOR70)
	lw	a5,%lo(.LANCHOR70)(a5)
	sb	a0,0(a5)
	lui	a5,%hi(.LANCHOR71)
	lw	a5,%lo(.LANCHOR71)(a5)
	lui	a0,%hi(.LANCHOR72)
	lw	a6,%lo(.LANCHOR72)(a0)
	lui	a0,%hi(.LANCHOR74)
	lw	a0,%lo(.LANCHOR74)(a0)
	sh	a1,0(a5)
	lui	a5,%hi(.LANCHOR75)
	lw	a5,%lo(.LANCHOR75)(a5)
	sh	a2,0(a6)
	lui	a2,%hi(.LANCHOR27)
	lw	a2,%lo(.LANCHOR27)(a2)
	sh	a3,0(a0)
	sh	a4,0(a5)
.L215:
	lbu	a5,0(a2)
	bne	a5,zero,.L215
	lui	a5,%hi(.LANCHOR73)
	lw	a5,%lo(.LANCHOR73)(a5)
	li	a4,3
	sb	a4,0(a5)
	ret
	.size	gpu_rectangle, .-gpu_rectangle
	.section	.text.gpu_cs,"ax",@progbits
	.align	1
	.globl	gpu_cs
	.type	gpu_cs, @function
gpu_cs:
	lui	a3,%hi(.LANCHOR27)
	addi	a3,a3,%lo(.LANCHOR27)
	lw	a4,0(a3)
.L218:
	lbu	a5,0(a4)
	bne	a5,zero,.L218
	lui	a5,%hi(.LANCHOR67)
	lw	a5,%lo(.LANCHOR67)(a5)
	li	a4,5
	lui	a2,%hi(.LANCHOR74)
	sb	a4,0(a5)
	lui	a5,%hi(.LANCHOR70)
	lw	a5,%lo(.LANCHOR70)(a5)
	li	a4,64
	sb	a4,0(a5)
	lui	a5,%hi(.LANCHOR71)
	lw	a5,%lo(.LANCHOR71)(a5)
	lui	a4,%hi(.LANCHOR72)
	lw	a4,%lo(.LANCHOR72)(a4)
	lw	a2,%lo(.LANCHOR74)(a2)
	sh	zero,0(a5)
	lui	a5,%hi(.LANCHOR75)
	lw	a5,%lo(.LANCHOR75)(a5)
	sh	zero,0(a4)
	lw	a4,0(a3)
	li	a3,319
	sh	a3,0(a2)
	li	a3,239
	sh	a3,0(a5)
.L219:
	lbu	a5,0(a4)
	bne	a5,zero,.L219
	lui	a5,%hi(.LANCHOR73)
	lw	a5,%lo(.LANCHOR73)(a5)
	li	a4,3
	sb	a4,0(a5)
	ret
	.size	gpu_cs, .-gpu_cs
	.section	.text.gpu_circle,"ax",@progbits
	.align	1
	.globl	gpu_circle
	.type	gpu_circle, @function
gpu_circle:
	lui	a6,%hi(.LANCHOR70)
	lw	a6,%lo(.LANCHOR70)(a6)
	sb	a0,0(a6)
	lui	a0,%hi(.LANCHOR71)
	lw	a7,%lo(.LANCHOR71)(a0)
	lui	a0,%hi(.LANCHOR72)
	lw	a6,%lo(.LANCHOR72)(a0)
	lui	a0,%hi(.LANCHOR74)
	lw	a0,%lo(.LANCHOR74)(a0)
	sh	a1,0(a7)
	lui	a1,%hi(.LANCHOR75)
	lw	a1,%lo(.LANCHOR75)(a1)
	sh	a2,0(a6)
	lui	a2,%hi(.LANCHOR27)
	lw	a2,%lo(.LANCHOR27)(a2)
	sh	a3,0(a0)
	sh	a4,0(a1)
.L223:
	lbu	a4,0(a2)
	bne	a4,zero,.L223
	lui	a4,%hi(.LANCHOR73)
	lw	a4,%lo(.LANCHOR73)(a4)
	snez	a5,a5
	addi	a5,a5,4
	sb	a5,0(a4)
	ret
	.size	gpu_circle, .-gpu_circle
	.section	.text.gpu_blit,"ax",@progbits
	.align	1
	.globl	gpu_blit
	.type	gpu_blit, @function
gpu_blit:
	lui	a5,%hi(.LANCHOR70)
	lw	a5,%lo(.LANCHOR70)(a5)
	sb	a0,0(a5)
	lui	a5,%hi(.LANCHOR71)
	lw	a5,%lo(.LANCHOR71)(a5)
	lui	a0,%hi(.LANCHOR72)
	lw	a6,%lo(.LANCHOR72)(a0)
	lui	a0,%hi(.LANCHOR74)
	lw	a0,%lo(.LANCHOR74)(a0)
	sh	a1,0(a5)
	lui	a5,%hi(.LANCHOR75)
	lw	a5,%lo(.LANCHOR75)(a5)
	sh	a2,0(a6)
	lui	a2,%hi(.LANCHOR27)
	lw	a2,%lo(.LANCHOR27)(a2)
	sh	a3,0(a0)
	sh	a4,0(a5)
.L228:
	lbu	a5,0(a2)
	bne	a5,zero,.L228
	lui	a5,%hi(.LANCHOR73)
	lw	a5,%lo(.LANCHOR73)(a5)
	li	a4,7
	sb	a4,0(a5)
	ret
	.size	gpu_blit, .-gpu_blit
	.section	.text.gpu_character_blit,"ax",@progbits
	.align	1
	.globl	gpu_character_blit
	.type	gpu_character_blit, @function
gpu_character_blit:
	lui	a5,%hi(.LANCHOR70)
	lw	a5,%lo(.LANCHOR70)(a5)
	sb	a0,0(a5)
	lui	a5,%hi(.LANCHOR71)
	lw	a5,%lo(.LANCHOR71)(a5)
	lui	a0,%hi(.LANCHOR72)
	lw	a6,%lo(.LANCHOR72)(a0)
	lui	a0,%hi(.LANCHOR74)
	lw	a0,%lo(.LANCHOR74)(a0)
	sh	a1,0(a5)
	lui	a5,%hi(.LANCHOR75)
	lw	a5,%lo(.LANCHOR75)(a5)
	sh	a2,0(a6)
	lui	a2,%hi(.LANCHOR27)
	lw	a2,%lo(.LANCHOR27)(a2)
	sh	a3,0(a0)
	sh	a4,0(a5)
.L231:
	lbu	a5,0(a2)
	bne	a5,zero,.L231
	lui	a5,%hi(.LANCHOR73)
	lw	a5,%lo(.LANCHOR73)(a5)
	li	a4,8
	sb	a4,0(a5)
	ret
	.size	gpu_character_blit, .-gpu_character_blit
	.section	.text.gpu_colourblit,"ax",@progbits
	.align	1
	.globl	gpu_colourblit
	.type	gpu_colourblit, @function
gpu_colourblit:
	lui	a5,%hi(.LANCHOR71)
	lw	a5,%lo(.LANCHOR71)(a5)
	lui	a4,%hi(.LANCHOR72)
	lw	a4,%lo(.LANCHOR72)(a4)
	lui	a6,%hi(.LANCHOR74)
	lw	a6,%lo(.LANCHOR74)(a6)
	sh	a0,0(a5)
	lui	a5,%hi(.LANCHOR75)
	lw	a5,%lo(.LANCHOR75)(a5)
	sh	a1,0(a4)
	lui	a4,%hi(.LANCHOR27)
	lw	a4,%lo(.LANCHOR27)(a4)
	sh	a2,0(a6)
	sh	a3,0(a5)
.L234:
	lbu	a5,0(a4)
	bne	a5,zero,.L234
	lui	a5,%hi(.LANCHOR73)
	lw	a5,%lo(.LANCHOR73)(a5)
	li	a4,9
	sb	a4,0(a5)
	ret
	.size	gpu_colourblit, .-gpu_colourblit
	.section	.text.set_blitter_bitmap,"ax",@progbits
	.align	1
	.globl	set_blitter_bitmap
	.type	set_blitter_bitmap, @function
set_blitter_bitmap:
	lui	a5,%hi(.LANCHOR76)
	lw	a5,%lo(.LANCHOR76)(a5)
	lui	a2,%hi(.LANCHOR78)
	addi	a2,a2,%lo(.LANCHOR78)
	sb	a0,0(a5)
	lui	a0,%hi(.LANCHOR77)
	li	a5,0
	addi	a0,a0,%lo(.LANCHOR77)
	li	a6,16
.L237:
	lw	a4,0(a0)
	andi	a3,a5,0xff
	addi	a5,a5,1
	sb	a3,0(a4)
	lhu	a3,0(a1)
	lw	a4,0(a2)
	addi	a1,a1,2
	sh	a3,0(a4)
	bne	a5,a6,.L237
	ret
	.size	set_blitter_bitmap, .-set_blitter_bitmap
	.section	.text.set_blitter_chbitmap,"ax",@progbits
	.align	1
	.globl	set_blitter_chbitmap
	.type	set_blitter_chbitmap, @function
set_blitter_chbitmap:
	lui	a5,%hi(.LANCHOR79)
	lw	a5,%lo(.LANCHOR79)(a5)
	lui	a6,%hi(.LANCHOR80)
	addi	a6,a6,%lo(.LANCHOR80)
	sb	a0,0(a5)
	lui	a0,%hi(.LANCHOR81)
	li	a5,0
	addi	a0,a0,%lo(.LANCHOR81)
	li	a7,8
.L240:
	lw	a4,0(a6)
	andi	a2,a5,0xff
	add	a3,a1,a5
	sb	a2,0(a4)
	lw	a4,0(a0)
	lbu	a3,0(a3)
	addi	a5,a5,1
	sb	a3,0(a4)
	bne	a5,a7,.L240
	ret
	.size	set_blitter_chbitmap, .-set_blitter_chbitmap
	.section	.text.set_colourblitter_bitmap,"ax",@progbits
	.align	1
	.globl	set_colourblitter_bitmap
	.type	set_colourblitter_bitmap, @function
set_colourblitter_bitmap:
	lui	a5,%hi(.LANCHOR82)
	lw	a5,%lo(.LANCHOR82)(a5)
	lui	t3,%hi(.LANCHOR83)
	lui	a6,%hi(.LANCHOR84)
	sb	a0,0(a5)
	lui	a0,%hi(.LANCHOR85)
	li	t1,0
	addi	t3,t3,%lo(.LANCHOR83)
	addi	a6,a6,%lo(.LANCHOR84)
	addi	a0,a0,%lo(.LANCHOR85)
	li	a7,16
.L244:
	lw	a3,0(t3)
	andi	a4,t1,0xff
	li	a5,0
	sb	a4,0(a3)
.L243:
	lw	a4,0(a6)
	andi	a2,a5,0xff
	add	a3,a1,a5
	sb	a2,0(a4)
	lw	a4,0(a0)
	lbu	a3,0(a3)
	addi	a5,a5,1
	sb	a3,0(a4)
	bne	a5,a7,.L243
	addi	t1,t1,1
	addi	a1,a1,16
	bne	t1,a5,.L244
	ret
	.size	set_colourblitter_bitmap, .-set_colourblitter_bitmap
	.section	.text.gpu_triangle,"ax",@progbits
	.align	1
	.globl	gpu_triangle
	.type	gpu_triangle, @function
gpu_triangle:
	lui	a7,%hi(.LANCHOR70)
	lw	a7,%lo(.LANCHOR70)(a7)
	sb	a0,0(a7)
	lui	a0,%hi(.LANCHOR71)
	lw	t1,%lo(.LANCHOR71)(a0)
	lui	a0,%hi(.LANCHOR72)
	lw	a7,%lo(.LANCHOR72)(a0)
	lui	a0,%hi(.LANCHOR74)
	lw	a0,%lo(.LANCHOR74)(a0)
	sh	a1,0(t1)
	lui	a1,%hi(.LANCHOR75)
	lw	a1,%lo(.LANCHOR75)(a1)
	sh	a2,0(a7)
	lui	a2,%hi(.LANCHOR86)
	lw	a2,%lo(.LANCHOR86)(a2)
	sh	a3,0(a0)
	lui	a3,%hi(.LANCHOR87)
	lw	a3,%lo(.LANCHOR87)(a3)
	sh	a4,0(a1)
	lui	a4,%hi(.LANCHOR27)
	lw	a4,%lo(.LANCHOR27)(a4)
	sh	a5,0(a2)
	sh	a6,0(a3)
.L248:
	lbu	a5,0(a4)
	bne	a5,zero,.L248
	lui	a5,%hi(.LANCHOR73)
	lw	a5,%lo(.LANCHOR73)(a5)
	li	a4,6
	sb	a4,0(a5)
	ret
	.size	gpu_triangle, .-gpu_triangle
	.section	.text.gpu_quadrilateral,"ax",@progbits
	.align	1
	.globl	gpu_quadrilateral
	.type	gpu_quadrilateral, @function
gpu_quadrilateral:
	addi	sp,sp,-16
	sw	s0,12(sp)
	lui	s0,%hi(.LANCHOR70)
	addi	s0,s0,%lo(.LANCHOR70)
	lw	t1,0(s0)
	sw	s1,8(sp)
	sw	s2,4(sp)
	sw	s3,0(sp)
	lui	t2,%hi(.LANCHOR71)
	sb	a0,0(t1)
	addi	t2,t2,%lo(.LANCHOR71)
	lui	t0,%hi(.LANCHOR72)
	lw	t4,0(t2)
	addi	t0,t0,%lo(.LANCHOR72)
	lw	t3,0(t0)
	lui	t6,%hi(.LANCHOR74)
	addi	t6,t6,%lo(.LANCHOR74)
	lui	t5,%hi(.LANCHOR75)
	lw	t1,0(t6)
	addi	t5,t5,%lo(.LANCHOR75)
	sh	a1,0(t4)
	lui	t4,%hi(.LANCHOR86)
	lw	s3,0(t5)
	addi	t4,t4,%lo(.LANCHOR86)
	sh	a2,0(t3)
	lui	t3,%hi(.LANCHOR87)
	lw	s2,0(t4)
	addi	t3,t3,%lo(.LANCHOR87)
	sh	a3,0(t1)
	lw	s1,0(t3)
	lui	t1,%hi(.LANCHOR27)
	sh	a4,0(s3)
	addi	t1,t1,%lo(.LANCHOR27)
	lw	a3,0(t1)
	sh	a5,0(s2)
	sh	a6,0(s1)
.L251:
	lbu	a4,0(a3)
	bne	a4,zero,.L251
	lui	a3,%hi(.LANCHOR73)
	addi	a3,a3,%lo(.LANCHOR73)
	lw	a4,0(a3)
	li	s1,6
	sb	s1,0(a4)
	lw	a4,0(s0)
	sb	a0,0(a4)
	lw	a4,0(t2)
	lw	t0,0(t0)
	lw	a0,0(t6)
	sh	a1,0(a4)
	lw	a4,0(t5)
	sh	a2,0(t0)
	lw	a2,0(t4)
	sh	a5,0(a0)
	lw	a5,0(t3)
	sh	a6,0(a4)
	lw	a4,0(t1)
	sh	a7,0(a2)
	lh	a2,16(sp)
	sh	a2,0(a5)
.L252:
	lbu	a5,0(a4)
	bne	a5,zero,.L252
	lw	a5,0(a3)
	li	a4,6
	sb	a4,0(a5)
	lw	s0,12(sp)
	lw	s1,8(sp)
	lw	s2,4(sp)
	lw	s3,0(sp)
	addi	sp,sp,16
	jr	ra
	.size	gpu_quadrilateral, .-gpu_quadrilateral
	.section	.text.gpu_printf,"ax",@progbits
	.align	1
	.globl	gpu_printf
	.type	gpu_printf, @function
gpu_printf:
	addi	sp,sp,-64
	addi	t1,sp,52
	sw	s0,40(sp)
	sw	s1,36(sp)
	sw	s2,32(sp)
	sw	s3,28(sp)
	mv	s1,a0
	mv	s0,a1
	mv	s2,a2
	mv	s3,a3
	mv	a2,a4
	mv	a3,t1
	li	a1,80
	li	a0,4096
	sw	a5,52(sp)
	sw	ra,44(sp)
	sw	a6,56(sp)
	sw	a7,60(sp)
	sw	t1,12(sp)
	call	vsnprintf
	li	a5,4096
	lbu	a5,0(a5)
	beq	a5,zero,.L256
	li	t1,8
	sll	t1,t1,s3
	slli	t1,t1,16
	slli	a3,s3,16
	lui	t0,%hi(.LANCHOR70)
	lui	t6,%hi(.LANCHOR71)
	lui	t5,%hi(.LANCHOR72)
	lui	t4,%hi(.LANCHOR74)
	lui	t3,%hi(.LANCHOR75)
	lui	a0,%hi(.LANCHOR27)
	lui	a2,%hi(.LANCHOR73)
	srli	t1,t1,16
	srai	a3,a3,16
	li	a1,4096
	addi	t0,t0,%lo(.LANCHOR70)
	addi	t6,t6,%lo(.LANCHOR71)
	addi	t5,t5,%lo(.LANCHOR72)
	addi	t4,t4,%lo(.LANCHOR74)
	addi	t3,t3,%lo(.LANCHOR75)
	addi	a0,a0,%lo(.LANCHOR27)
	addi	a2,a2,%lo(.LANCHOR73)
	li	t2,8
.L259:
	lw	a4,0(t0)
	slli	a5,a5,16
	srai	a5,a5,16
	sb	s1,0(a4)
	lw	a6,0(t6)
	lw	a4,0(t5)
	lw	a7,0(t4)
	sh	s0,0(a6)
	lw	a6,0(t3)
	sh	s2,0(a4)
	lw	a4,0(a0)
	sh	a5,0(a7)
	addi	a1,a1,1
	sh	a3,0(a6)
.L258:
	lbu	a5,0(a4)
	bne	a5,zero,.L258
	lw	a5,0(a2)
	add	s0,t1,s0
	slli	s0,s0,16
	sb	t2,0(a5)
	lbu	a5,0(a1)
	srai	s0,s0,16
	bne	a5,zero,.L259
.L256:
	lw	ra,44(sp)
	lw	s0,40(sp)
	lw	s1,36(sp)
	lw	s2,32(sp)
	lw	s3,28(sp)
	addi	sp,sp,64
	jr	ra
	.size	gpu_printf, .-gpu_printf
	.section	.text.gpu_printf_centre,"ax",@progbits
	.align	1
	.globl	gpu_printf_centre
	.type	gpu_printf_centre, @function
gpu_printf_centre:
	addi	sp,sp,-64
	addi	t1,sp,52
	sw	s0,40(sp)
	sw	s1,36(sp)
	sw	s2,32(sp)
	sw	s3,28(sp)
	mv	s2,a1
	mv	s3,a3
	li	a1,80
	mv	a3,t1
	mv	s0,a0
	mv	s1,a2
	li	a0,4096
	mv	a2,a4
	sw	a5,52(sp)
	sw	ra,44(sp)
	sw	a6,56(sp)
	sw	a7,60(sp)
	sw	t1,12(sp)
	call	vsnprintf
	li	a0,4096
	call	strlen
	li	t3,8
	sll	t3,t3,s3
	mul	a4,t3,a0
	li	a5,4096
	lbu	a5,0(a5)
	srli	a4,a4,1
	sub	a1,s2,a4
	beq	a5,zero,.L264
	slli	a1,a1,16
	slli	t3,t3,16
	slli	a3,s3,16
	lui	t2,%hi(.LANCHOR70)
	lui	t0,%hi(.LANCHOR71)
	lui	t6,%hi(.LANCHOR72)
	lui	t5,%hi(.LANCHOR74)
	lui	t4,%hi(.LANCHOR75)
	lui	a0,%hi(.LANCHOR27)
	lui	a2,%hi(.LANCHOR73)
	srai	a1,a1,16
	srli	t3,t3,16
	srai	a3,a3,16
	li	t1,4096
	addi	t2,t2,%lo(.LANCHOR70)
	addi	t0,t0,%lo(.LANCHOR71)
	addi	t6,t6,%lo(.LANCHOR72)
	addi	t5,t5,%lo(.LANCHOR74)
	addi	t4,t4,%lo(.LANCHOR75)
	addi	a0,a0,%lo(.LANCHOR27)
	addi	a2,a2,%lo(.LANCHOR73)
	li	s2,8
.L267:
	lw	a4,0(t2)
	slli	a5,a5,16
	srai	a5,a5,16
	sb	s0,0(a4)
	lw	a6,0(t0)
	lw	a4,0(t6)
	lw	a7,0(t5)
	sh	a1,0(a6)
	lw	a6,0(t4)
	sh	s1,0(a4)
	lw	a4,0(a0)
	sh	a5,0(a7)
	addi	t1,t1,1
	sh	a3,0(a6)
.L266:
	lbu	a5,0(a4)
	bne	a5,zero,.L266
	lw	a5,0(a2)
	add	a1,t3,a1
	slli	a1,a1,16
	sb	s2,0(a5)
	lbu	a5,0(t1)
	srai	a1,a1,16
	bne	a5,zero,.L267
.L264:
	lw	ra,44(sp)
	lw	s0,40(sp)
	lw	s1,36(sp)
	lw	s2,32(sp)
	lw	s3,28(sp)
	addi	sp,sp,64
	jr	ra
	.size	gpu_printf_centre, .-gpu_printf_centre
	.section	.text.gpu_pixelblock7,"ax",@progbits
	.align	1
	.globl	gpu_pixelblock7
	.type	gpu_pixelblock7, @function
gpu_pixelblock7:
	mul	a3,a2,a3
	lui	a6,%hi(.LANCHOR71)
	lw	t1,%lo(.LANCHOR71)(a6)
	lui	a6,%hi(.LANCHOR72)
	lw	a7,%lo(.LANCHOR72)(a6)
	lui	a6,%hi(.LANCHOR74)
	lw	a6,%lo(.LANCHOR74)(a6)
	sh	a0,0(t1)
	lui	a0,%hi(.LANCHOR75)
	lw	a0,%lo(.LANCHOR75)(a0)
	slli	a2,a2,16
	sh	a1,0(a7)
	srai	a2,a2,16
	lui	a1,%hi(.LANCHOR27)
	lw	a1,%lo(.LANCHOR27)(a1)
	sh	a2,0(a6)
	add	a3,a5,a3
	sh	a4,0(a0)
.L273:
	lbu	a4,0(a1)
	bne	a4,zero,.L273
	lui	a4,%hi(.LANCHOR73)
	lw	a4,%lo(.LANCHOR73)(a4)
	li	a2,10
	sb	a2,0(a4)
	bgeu	a5,a3,.L274
	lui	a1,%hi(.LANCHOR88)
	addi	a1,a1,%lo(.LANCHOR88)
.L275:
	lbu	a2,0(a5)
	lw	a4,0(a1)
	addi	a5,a5,1
	sb	a2,0(a4)
	bne	a3,a5,.L275
.L274:
	lui	a5,%hi(.LANCHOR89)
	lw	a5,%lo(.LANCHOR89)(a5)
	li	a4,3
	sb	a4,0(a5)
	ret
	.size	gpu_pixelblock7, .-gpu_pixelblock7
	.section	.text.gpu_pixelblock24,"ax",@progbits
	.align	1
	.globl	gpu_pixelblock24
	.type	gpu_pixelblock24, @function
gpu_pixelblock24:
	mul	a3,a2,a3
	lui	a5,%hi(.LANCHOR71)
	lw	a5,%lo(.LANCHOR71)(a5)
	lui	a6,%hi(.LANCHOR72)
	lw	a7,%lo(.LANCHOR72)(a6)
	lui	a6,%hi(.LANCHOR74)
	lw	a6,%lo(.LANCHOR74)(a6)
	slli	a2,a2,16
	sh	a0,0(a5)
	lui	a0,%hi(.LANCHOR27)
	slli	a5,a3,1
	lw	a0,%lo(.LANCHOR27)(a0)
	add	a5,a5,a3
	sh	a1,0(a7)
	srai	a2,a2,16
	add	a1,a4,a5
	sh	a2,0(a6)
.L279:
	lbu	a5,0(a0)
	bne	a5,zero,.L279
	lui	a5,%hi(.LANCHOR73)
	lw	a5,%lo(.LANCHOR73)(a5)
	li	a3,10
	sb	a3,0(a5)
	bgeu	a4,a1,.L280
	lui	a6,%hi(.LANCHOR90)
	lui	a0,%hi(.LANCHOR91)
	lui	a2,%hi(.LANCHOR92)
	addi	a6,a6,%lo(.LANCHOR90)
	addi	a0,a0,%lo(.LANCHOR91)
	addi	a2,a2,%lo(.LANCHOR92)
.L281:
	lbu	a3,0(a4)
	lw	a5,0(a6)
	addi	a4,a4,3
	sb	a3,0(a5)
	lbu	a3,-2(a4)
	lw	a5,0(a0)
	sb	a3,0(a5)
	lw	a5,0(a2)
	lbu	a3,-1(a4)
	sb	a3,0(a5)
	bgtu	a1,a4,.L281
.L280:
	lui	a5,%hi(.LANCHOR89)
	lw	a5,%lo(.LANCHOR89)(a5)
	li	a4,3
	sb	a4,0(a5)
	ret
	.size	gpu_pixelblock24, .-gpu_pixelblock24
	.section	.text.draw_vector_block,"ax",@progbits
	.align	1
	.globl	draw_vector_block
	.type	draw_vector_block, @function
draw_vector_block:
	lui	a5,%hi(.LANCHOR93)
	lw	a6,%lo(.LANCHOR93)(a5)
.L285:
	lbu	a5,0(a6)
	bne	a5,zero,.L285
	lui	a5,%hi(.LANCHOR94)
	lw	a5,%lo(.LANCHOR94)(a5)
	sb	a0,0(a5)
	lui	a5,%hi(.LANCHOR95)
	lw	a5,%lo(.LANCHOR95)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(.LANCHOR96)
	lw	a0,%lo(.LANCHOR96)(a5)
	lui	a5,%hi(.LANCHOR97)
	lw	a1,%lo(.LANCHOR97)(a5)
	lui	a5,%hi(.LANCHOR98)
	lw	a5,%lo(.LANCHOR98)(a5)
	sh	a2,0(a0)
	sh	a3,0(a1)
	sb	a4,0(a5)
	lui	a5,%hi(.LANCHOR99)
	lw	a5,%lo(.LANCHOR99)(a5)
	li	a4,1
	sb	a4,0(a5)
	ret
	.size	draw_vector_block, .-draw_vector_block
	.section	.text.set_vector_vertex,"ax",@progbits
	.align	1
	.globl	set_vector_vertex
	.type	set_vector_vertex, @function
set_vector_vertex:
	lui	a5,%hi(.LANCHOR100)
	lw	a5,%lo(.LANCHOR100)(a5)
	sb	a0,0(a5)
	lui	a5,%hi(.LANCHOR101)
	lw	a5,%lo(.LANCHOR101)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(.LANCHOR102)
	lw	a5,%lo(.LANCHOR102)(a5)
	sb	a2,0(a5)
	lui	a5,%hi(.LANCHOR103)
	lw	a5,%lo(.LANCHOR103)(a5)
	sb	a3,0(a5)
	lui	a5,%hi(.LANCHOR104)
	lw	a5,%lo(.LANCHOR104)(a5)
	sb	a4,0(a5)
	ret
	.size	set_vector_vertex, .-set_vector_vertex
	.section	.text.set_sprite_bitmaps,"ax",@progbits
	.align	1
	.globl	set_sprite_bitmaps
	.type	set_sprite_bitmaps, @function
set_sprite_bitmaps:
	beq	a0,zero,.L289
	li	a5,1
	bne	a0,a5,.L291
	lui	a5,%hi(.LANCHOR106)
	lw	a5,%lo(.LANCHOR106)(a5)
	sb	a1,0(a5)
.L291:
	li	a5,0
	lui	t4,%hi(.LANCHOR107)
	lui	t3,%hi(.LANCHOR108)
	li	a1,1
	lui	t1,%hi(.LANCHOR109)
	lui	a7,%hi(.LANCHOR110)
	li	a3,128
.L292:
	beq	a0,zero,.L293
	andi	a4,a5,0xff
	bne	a0,a1,.L295
	lw	a6,%lo(.LANCHOR109)(t1)
	sb	a4,0(a6)
	lhu	a6,0(a2)
	lw	a4,%lo(.LANCHOR110)(a7)
	sh	a6,0(a4)
.L295:
	addi	a5,a5,1
	addi	a2,a2,2
	bne	a5,a3,.L292
	ret
.L293:
	lw	a4,%lo(.LANCHOR107)(t4)
	andi	a6,a5,0xff
	sb	a6,0(a4)
	lw	a4,%lo(.LANCHOR108)(t3)
	lhu	a6,0(a2)
	sh	a6,0(a4)
	j	.L295
.L289:
	lui	a5,%hi(.LANCHOR105)
	lw	a5,%lo(.LANCHOR105)(a5)
	lui	t4,%hi(.LANCHOR107)
	lui	t3,%hi(.LANCHOR108)
	sb	a1,0(a5)
	lui	t1,%hi(.LANCHOR109)
	li	a5,0
	li	a1,1
	lui	a7,%hi(.LANCHOR110)
	li	a3,128
	j	.L292
	.size	set_sprite_bitmaps, .-set_sprite_bitmaps
	.section	.text.set_sprite,"ax",@progbits
	.align	1
	.globl	set_sprite
	.type	set_sprite, @function
set_sprite:
	beq	a0,zero,.L298
	li	t1,1
	bne	a0,t1,.L302
	lui	a0,%hi(.LANCHOR117)
	lw	a0,%lo(.LANCHOR117)(a0)
	lui	t1,%hi(.LANCHOR118)
	lw	t4,%lo(.LANCHOR118)(t1)
	slli	a1,a1,1
	lui	t1,%hi(.LANCHOR119)
	slli	a2,a2,16
	lw	t3,%lo(.LANCHOR119)(t1)
	add	a0,a0,a1
	srli	a2,a2,16
	lui	t1,%hi(.LANCHOR120)
	lw	t1,%lo(.LANCHOR120)(t1)
	slli	a6,a6,16
	sh	a2,0(a0)
	lui	a2,%hi(.LANCHOR121)
	lw	a0,%lo(.LANCHOR121)(a2)
	srli	a6,a6,16
	add	a2,t4,a1
	sh	a6,0(a2)
	lui	a2,%hi(.LANCHOR122)
	lw	a2,%lo(.LANCHOR122)(a2)
.L301:
	slli	a3,a3,16
	srli	a3,a3,16
	add	a6,t3,a1
	sh	a3,0(a6)
	add	a3,t1,a1
	sh	a4,0(a3)
	slli	a7,a7,16
	add	a4,a0,a1
	sh	a5,0(a4)
	srli	a7,a7,16
	add	a5,a2,a1
	sh	a7,0(a5)
	ret
.L302:
	ret
.L298:
	lui	a0,%hi(.LANCHOR111)
	lw	a0,%lo(.LANCHOR111)(a0)
	lui	t1,%hi(.LANCHOR112)
	lw	t4,%lo(.LANCHOR112)(t1)
	slli	a1,a1,1
	lui	t1,%hi(.LANCHOR113)
	slli	a2,a2,16
	lw	t3,%lo(.LANCHOR113)(t1)
	add	a0,a0,a1
	srli	a2,a2,16
	lui	t1,%hi(.LANCHOR114)
	lw	t1,%lo(.LANCHOR114)(t1)
	slli	a6,a6,16
	sh	a2,0(a0)
	lui	a2,%hi(.LANCHOR115)
	lw	a0,%lo(.LANCHOR115)(a2)
	srli	a6,a6,16
	add	a2,t4,a1
	sh	a6,0(a2)
	lui	a2,%hi(.LANCHOR116)
	lw	a2,%lo(.LANCHOR116)(a2)
	j	.L301
	.size	set_sprite, .-set_sprite
	.section	.text.set_sprite_attribute,"ax",@progbits
	.align	1
	.globl	set_sprite_attribute
	.type	set_sprite_attribute, @function
set_sprite_attribute:
	li	a5,5
	bne	a0,zero,.L304
	bgtu	a2,a5,.L303
	lui	a5,%hi(.L307)
	addi	a5,a5,%lo(.L307)
	slli	a2,a2,2
	add	a2,a2,a5
	lw	a5,0(a2)
	jr	a5
	.section	.rodata.set_sprite_attribute,"a",@progbits
	.align	2
	.align	2
.L307:
	.word	.L312
	.word	.L311
	.word	.L310
	.word	.L309
	.word	.L308
	.word	.L306
	.section	.text.set_sprite_attribute
.L313:
	lui	a5,%hi(.LANCHOR122)
	lw	a5,%lo(.LANCHOR122)(a5)
	slli	a1,a1,1
	andi	a3,a3,0xff
	add	a5,a5,a1
	sh	a3,0(a5)
.L303:
	ret
.L304:
	bgtu	a2,a5,.L303
	lui	a5,%hi(.L314)
	addi	a5,a5,%lo(.L314)
	slli	a2,a2,2
	add	a2,a2,a5
	lw	a5,0(a2)
	jr	a5
	.section	.rodata.set_sprite_attribute
	.align	2
	.align	2
.L314:
	.word	.L319
	.word	.L318
	.word	.L317
	.word	.L316
	.word	.L315
	.word	.L313
	.section	.text.set_sprite_attribute
.L315:
	lui	a5,%hi(.LANCHOR121)
	lw	a5,%lo(.LANCHOR121)(a5)
	slli	a1,a1,1
	add	a5,a5,a1
	sh	a3,0(a5)
	ret
.L306:
	lui	a5,%hi(.LANCHOR116)
	lw	a5,%lo(.LANCHOR116)(a5)
	slli	a1,a1,1
	andi	a3,a3,0xff
	add	a5,a5,a1
	sh	a3,0(a5)
	ret
.L312:
	lui	a5,%hi(.LANCHOR111)
	lw	a5,%lo(.LANCHOR111)(a5)
	slli	a1,a1,1
	andi	a3,a3,0xff
	add	a5,a5,a1
	sh	a3,0(a5)
	ret
.L311:
	lui	a5,%hi(.LANCHOR112)
	lw	a5,%lo(.LANCHOR112)(a5)
	slli	a1,a1,1
	andi	a3,a3,0xff
	add	a5,a5,a1
	sh	a3,0(a5)
	ret
.L310:
	lui	a5,%hi(.LANCHOR113)
	lw	a5,%lo(.LANCHOR113)(a5)
	slli	a1,a1,1
	andi	a3,a3,0xff
	add	a5,a5,a1
	sh	a3,0(a5)
	ret
.L309:
	lui	a5,%hi(.LANCHOR114)
	lw	a5,%lo(.LANCHOR114)(a5)
	slli	a1,a1,1
	add	a5,a5,a1
	sh	a3,0(a5)
	ret
.L308:
	lui	a5,%hi(.LANCHOR115)
	lw	a5,%lo(.LANCHOR115)(a5)
	slli	a1,a1,1
	add	a5,a5,a1
	sh	a3,0(a5)
	ret
.L319:
	lui	a5,%hi(.LANCHOR117)
	lw	a5,%lo(.LANCHOR117)(a5)
	slli	a1,a1,1
	andi	a3,a3,0xff
	add	a5,a5,a1
	sh	a3,0(a5)
	ret
.L318:
	lui	a5,%hi(.LANCHOR118)
	lw	a5,%lo(.LANCHOR118)(a5)
	slli	a1,a1,1
	andi	a3,a3,0xff
	add	a5,a5,a1
	sh	a3,0(a5)
	ret
.L317:
	lui	a5,%hi(.LANCHOR119)
	lw	a5,%lo(.LANCHOR119)(a5)
	slli	a1,a1,1
	andi	a3,a3,0xff
	add	a5,a5,a1
	sh	a3,0(a5)
	ret
.L316:
	lui	a5,%hi(.LANCHOR120)
	lw	a5,%lo(.LANCHOR120)(a5)
	slli	a1,a1,1
	add	a5,a5,a1
	sh	a3,0(a5)
	ret
	.size	set_sprite_attribute, .-set_sprite_attribute
	.section	.text.get_sprite_attribute,"ax",@progbits
	.align	1
	.globl	get_sprite_attribute
	.type	get_sprite_attribute, @function
get_sprite_attribute:
	li	a5,5
	bne	a0,zero,.L321
	bgtu	a2,a5,.L338
	lui	a5,%hi(.L324)
	addi	a5,a5,%lo(.L324)
	slli	a2,a2,2
	add	a2,a2,a5
	lw	a5,0(a2)
	jr	a5
	.section	.rodata.get_sprite_attribute,"a",@progbits
	.align	2
	.align	2
.L324:
	.word	.L329
	.word	.L328
	.word	.L327
	.word	.L326
	.word	.L325
	.word	.L323
	.section	.text.get_sprite_attribute
.L321:
	bgtu	a2,a5,.L338
	lui	a5,%hi(.L331)
	addi	a5,a5,%lo(.L331)
	slli	a2,a2,2
	add	a2,a2,a5
	lw	a5,0(a2)
	jr	a5
	.section	.rodata.get_sprite_attribute
	.align	2
	.align	2
.L331:
	.word	.L336
	.word	.L335
	.word	.L334
	.word	.L333
	.word	.L332
	.word	.L330
	.section	.text.get_sprite_attribute
.L332:
	lui	a5,%hi(.LANCHOR121)
	lw	a5,%lo(.LANCHOR121)(a5)
.L339:
	slli	a1,a1,1
	add	a5,a5,a1
	lhu	a0,0(a5)
	slli	a0,a0,16
	srai	a0,a0,16
	ret
.L323:
	lui	a5,%hi(.LANCHOR116)
	lw	a5,%lo(.LANCHOR116)(a5)
	j	.L339
.L329:
	lui	a5,%hi(.LANCHOR111)
	lw	a5,%lo(.LANCHOR111)(a5)
	j	.L339
.L328:
	lui	a5,%hi(.LANCHOR112)
	lw	a5,%lo(.LANCHOR112)(a5)
	j	.L339
.L327:
	lui	a5,%hi(.LANCHOR113)
	lw	a5,%lo(.LANCHOR113)(a5)
	j	.L339
.L326:
	lui	a5,%hi(.LANCHOR114)
	lw	a5,%lo(.LANCHOR114)(a5)
	j	.L339
.L325:
	lui	a5,%hi(.LANCHOR115)
	lw	a5,%lo(.LANCHOR115)(a5)
	j	.L339
.L330:
	lui	a5,%hi(.LANCHOR122)
	lw	a5,%lo(.LANCHOR122)(a5)
	j	.L339
.L336:
	lui	a5,%hi(.LANCHOR117)
	lw	a5,%lo(.LANCHOR117)(a5)
	j	.L339
.L335:
	lui	a5,%hi(.LANCHOR118)
	lw	a5,%lo(.LANCHOR118)(a5)
	j	.L339
.L334:
	lui	a5,%hi(.LANCHOR119)
	lw	a5,%lo(.LANCHOR119)(a5)
	j	.L339
.L333:
	lui	a5,%hi(.LANCHOR120)
	lw	a5,%lo(.LANCHOR120)(a5)
	j	.L339
.L338:
	li	a0,0
	ret
	.size	get_sprite_attribute, .-get_sprite_attribute
	.section	.text.get_sprite_collision,"ax",@progbits
	.align	1
	.globl	get_sprite_collision
	.type	get_sprite_collision, @function
get_sprite_collision:
	slli	a1,a1,1
	bne	a0,zero,.L341
	lui	a5,%hi(.LANCHOR123)
	lw	a5,%lo(.LANCHOR123)(a5)
	add	a5,a5,a1
	lhu	a0,0(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
.L341:
	lui	a5,%hi(.LANCHOR124)
	lw	a5,%lo(.LANCHOR124)(a5)
	add	a5,a5,a1
	lhu	a0,0(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
	.size	get_sprite_collision, .-get_sprite_collision
	.section	.text.get_sprite_layer_collision,"ax",@progbits
	.align	1
	.globl	get_sprite_layer_collision
	.type	get_sprite_layer_collision, @function
get_sprite_layer_collision:
	slli	a1,a1,1
	bne	a0,zero,.L344
	lui	a5,%hi(.LANCHOR125)
	lw	a5,%lo(.LANCHOR125)(a5)
	add	a5,a5,a1
	lhu	a0,0(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
.L344:
	lui	a5,%hi(.LANCHOR126)
	lw	a5,%lo(.LANCHOR126)(a5)
	add	a5,a5,a1
	lhu	a0,0(a5)
	slli	a0,a0,16
	srli	a0,a0,16
	ret
	.size	get_sprite_layer_collision, .-get_sprite_layer_collision
	.section	.text.update_sprite,"ax",@progbits
	.align	1
	.globl	update_sprite
	.type	update_sprite, @function
update_sprite:
	beq	a0,zero,.L347
	li	a5,1
	bne	a0,a5,.L350
	lui	a5,%hi(.LANCHOR128)
	lw	a5,%lo(.LANCHOR128)(a5)
	slli	a1,a1,1
	add	a5,a5,a1
	sh	a2,0(a5)
	ret
.L350:
	ret
.L347:
	lui	a5,%hi(.LANCHOR127)
	lw	a5,%lo(.LANCHOR127)(a5)
	slli	a1,a1,1
	add	a5,a5,a1
	sh	a2,0(a5)
	ret
	.size	update_sprite, .-update_sprite
	.section	.text.tpu_cs,"ax",@progbits
	.align	1
	.globl	tpu_cs
	.type	tpu_cs, @function
tpu_cs:
	lui	a5,%hi(.LANCHOR129)
	lw	a4,%lo(.LANCHOR129)(a5)
.L352:
	lbu	a5,0(a4)
	bne	a5,zero,.L352
	li	a5,3
	sb	a5,0(a4)
	ret
	.size	tpu_cs, .-tpu_cs
	.section	.text.tpu_clearline,"ax",@progbits
	.align	1
	.globl	tpu_clearline
	.type	tpu_clearline, @function
tpu_clearline:
	lui	a3,%hi(.LANCHOR129)
	addi	a3,a3,%lo(.LANCHOR129)
	lw	a4,0(a3)
.L355:
	lbu	a5,0(a4)
	bne	a5,zero,.L355
	lui	a5,%hi(.LANCHOR130)
	lw	a5,%lo(.LANCHOR130)(a5)
	li	a4,4
	sb	a0,0(a5)
	lw	a5,0(a3)
	sb	a4,0(a5)
	ret
	.size	tpu_clearline, .-tpu_clearline
	.section	.text.tpu_set,"ax",@progbits
	.align	1
	.globl	tpu_set
	.type	tpu_set, @function
tpu_set:
	lui	a6,%hi(.LANCHOR129)
	addi	a6,a6,%lo(.LANCHOR129)
	lw	a4,0(a6)
.L358:
	lbu	a5,0(a4)
	bne	a5,zero,.L358
	lui	a5,%hi(.LANCHOR131)
	lw	a5,%lo(.LANCHOR131)(a5)
	li	a4,1
	sb	a0,0(a5)
	lui	a5,%hi(.LANCHOR130)
	lw	a5,%lo(.LANCHOR130)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(.LANCHOR132)
	lw	a5,%lo(.LANCHOR132)(a5)
	sb	a2,0(a5)
	lui	a5,%hi(.LANCHOR133)
	lw	a5,%lo(.LANCHOR133)(a5)
	sb	a3,0(a5)
	lw	a5,0(a6)
	sb	a4,0(a5)
	ret
	.size	tpu_set, .-tpu_set
	.section	.text.tpu_output_character,"ax",@progbits
	.align	1
	.globl	tpu_output_character
	.type	tpu_output_character, @function
tpu_output_character:
	lui	a3,%hi(.LANCHOR129)
	addi	a3,a3,%lo(.LANCHOR129)
	lw	a4,0(a3)
.L361:
	lbu	a5,0(a4)
	bne	a5,zero,.L361
	lui	a5,%hi(.LANCHOR134)
	lw	a5,%lo(.LANCHOR134)(a5)
	li	a4,2
	sb	a0,0(a5)
	lw	a5,0(a3)
	sb	a4,0(a5)
	ret
	.size	tpu_output_character, .-tpu_output_character
	.section	.text.tpu_outputstring,"ax",@progbits
	.align	1
	.globl	tpu_outputstring
	.type	tpu_outputstring, @function
tpu_outputstring:
	lbu	a3,0(a0)
	beq	a3,zero,.L363
	lui	a2,%hi(.LANCHOR129)
	lui	a1,%hi(.LANCHOR134)
	addi	a2,a2,%lo(.LANCHOR129)
	addi	a1,a1,%lo(.LANCHOR134)
	li	a6,2
.L366:
	lw	a4,0(a2)
.L365:
	lbu	a5,0(a4)
	bne	a5,zero,.L365
	lw	a5,0(a1)
	addi	a0,a0,1
	sb	a3,0(a5)
	lw	a5,0(a2)
	sb	a6,0(a5)
	lbu	a3,0(a0)
	bne	a3,zero,.L366
.L363:
	ret
	.size	tpu_outputstring, .-tpu_outputstring
	.section	.text.tpu_printf,"ax",@progbits
	.align	1
	.globl	tpu_printf
	.type	tpu_printf, @function
tpu_printf:
	addi	sp,sp,-64
	addi	t1,sp,36
	sw	a1,36(sp)
	sw	a2,40(sp)
	sw	a3,44(sp)
	mv	a2,a0
	mv	a3,t1
	li	a1,1023
	li	a0,4096
	sw	a5,52(sp)
	sw	ra,28(sp)
	sw	a4,48(sp)
	sw	a6,56(sp)
	sw	a7,60(sp)
	sw	t1,12(sp)
	call	vsnprintf
	li	a5,4096
	lbu	a3,0(a5)
	beq	a3,zero,.L372
	lui	a1,%hi(.LANCHOR129)
	lui	a0,%hi(.LANCHOR134)
	li	a2,4096
	addi	a1,a1,%lo(.LANCHOR129)
	addi	a0,a0,%lo(.LANCHOR134)
	li	a6,2
.L375:
	lw	a4,0(a1)
.L374:
	lbu	a5,0(a4)
	bne	a5,zero,.L374
	lw	a5,0(a0)
	addi	a2,a2,1
	sb	a3,0(a5)
	lw	a5,0(a1)
	sb	a6,0(a5)
	lbu	a3,0(a2)
	bne	a3,zero,.L375
.L372:
	lw	ra,28(sp)
	addi	sp,sp,64
	jr	ra
	.size	tpu_printf, .-tpu_printf
	.section	.text.tpu_printf_centre,"ax",@progbits
	.align	1
	.globl	tpu_printf_centre
	.type	tpu_printf_centre, @function
tpu_printf_centre:
	addi	sp,sp,-64
	mv	t1,a3
	sw	s0,40(sp)
	sw	s1,36(sp)
	sw	s3,28(sp)
	sw	s4,24(sp)
	addi	a3,sp,48
	mv	s1,a0
	mv	s4,a1
	mv	s3,a2
	li	a1,80
	mv	a2,t1
	li	a0,4096
	lui	s0,%hi(.LANCHOR129)
	sw	a4,48(sp)
	sw	ra,44(sp)
	sw	s2,32(sp)
	sw	a5,52(sp)
	sw	a6,56(sp)
	sw	a7,60(sp)
	sw	a3,12(sp)
	addi	s0,s0,%lo(.LANCHOR129)
	call	vsnprintf
	lw	a4,0(s0)
.L383:
	lbu	a5,0(a4)
	bne	a5,zero,.L383
	lui	s2,%hi(.LANCHOR130)
	addi	s2,s2,%lo(.LANCHOR130)
	lw	a5,0(s2)
	li	a4,4
	li	a0,4096
	sb	s1,0(a5)
	lw	a5,0(s0)
	sb	a4,0(a5)
	call	strlen
	srli	a5,a0,1
	li	a3,40
	lw	a4,0(s0)
	sub	a3,a3,a5
	andi	a3,a3,0xff
.L384:
	lbu	a5,0(a4)
	bne	a5,zero,.L384
	lui	a5,%hi(.LANCHOR131)
	lw	a5,%lo(.LANCHOR131)(a5)
	li	a4,1
	sb	a3,0(a5)
	lw	a5,0(s2)
	sb	s1,0(a5)
	lui	a5,%hi(.LANCHOR132)
	lw	a5,%lo(.LANCHOR132)(a5)
	sb	s4,0(a5)
	lui	a5,%hi(.LANCHOR133)
	lw	a5,%lo(.LANCHOR133)(a5)
	sb	s3,0(a5)
	lw	a5,0(s0)
	sb	a4,0(a5)
	li	a5,4096
	lbu	a3,0(a5)
	beq	a3,zero,.L382
	lui	a1,%hi(.LANCHOR134)
	li	a2,4096
	addi	a1,a1,%lo(.LANCHOR134)
	li	a0,2
.L387:
	lw	a4,0(s0)
.L386:
	lbu	a5,0(a4)
	bne	a5,zero,.L386
	lw	a5,0(a1)
	addi	a2,a2,1
	sb	a3,0(a5)
	lw	a5,0(s0)
	sb	a0,0(a5)
	lbu	a3,0(a2)
	bne	a3,zero,.L387
.L382:
	lw	ra,44(sp)
	lw	s0,40(sp)
	lw	s1,36(sp)
	lw	s2,32(sp)
	lw	s3,28(sp)
	lw	s4,24(sp)
	addi	sp,sp,64
	jr	ra
	.size	tpu_printf_centre, .-tpu_printf_centre
	.section	.text.sdcard_findfilenumber,"ax",@progbits
	.align	1
	.globl	sdcard_findfilenumber
	.type	sdcard_findfilenumber, @function
sdcard_findfilenumber:
	lui	a5,%hi(.LANCHOR135)
	lw	a4,%lo(.LANCHOR135)(a5)
	lbu	a5,18(a4)
	lbu	a4,17(a4)
	slli	a5,a5,8
	or	t6,a5,a4
	beq	t6,zero,.L406
	addi	sp,sp,-16
	lui	a5,%hi(.LANCHOR136)
	sw	s0,12(sp)
	lw	s0,%lo(.LANCHOR136)(a5)
	sw	s1,8(sp)
	sw	s2,4(sp)
	sw	s3,0(sp)
	mv	s1,a1
	mv	t3,a0
	li	t5,0
	li	t0,46
	li	s3,32
	li	t4,7
	li	s2,2
	li	a1,229
	li	t2,5
.L414:
	slli	t1,t5,5
	add	t1,s0,t1
	lbu	a3,0(t1)
	addi	a5,t5,1
	mv	a0,t5
	slli	t5,a5,16
	srli	t5,t5,16
	beq	a3,t0,.L426
	bgtu	a3,t0,.L399
	beq	a3,zero,.L426
	bne	a3,t2,.L407
.L426:
	bgtu	t6,t5,.L414
	li	a0,65536
	addi	a0,a0,-1
.L397:
	lw	s0,12(sp)
	lw	s1,8(sp)
	lw	s2,4(sp)
	lw	s3,0(sp)
	addi	sp,sp,16
	jr	ra
.L399:
	beq	a3,a1,.L426
.L407:
	li	a5,0
	li	a7,1
	mv	a4,t3
.L419:
	lbu	a6,0(a4)
	addi	a5,a5,1
	addi	a4,a3,-32
	slli	a5,a5,16
	seqz	a4,a4
	srli	a5,a5,16
	add	a2,t1,a5
	neg	a4,a4
	beq	a6,a3,.L402
	and	a7,a7,a4
.L402:
	add	a4,t3,a5
	bgtu	a5,t4,.L427
.L403:
	lbu	a3,0(a2)
	j	.L419
.L406:
	li	a0,65536
	addi	a0,a0,-1
	ret
.L427:
	lbu	a3,0(a4)
	beq	a3,zero,.L403
	li	a5,0
	mv	a4,s1
.L415:
	add	a3,t1,a5
	lbu	a2,0(a4)
	addi	a5,a5,1
	lbu	a3,8(a3)
	slli	a5,a5,16
	srli	a5,a5,16
	add	a4,s1,a5
	beq	a2,a3,.L404
	beq	a3,s3,.L404
	li	a7,0
.L404:
	lbu	a3,0(a4)
	bleu	a5,s2,.L415
	beq	a3,zero,.L415
	bne	a7,zero,.L397
	j	.L426
	.size	sdcard_findfilenumber, .-sdcard_findfilenumber
	.section	.text.sdcard_findfilesize,"ax",@progbits
	.align	1
	.globl	sdcard_findfilesize
	.type	sdcard_findfilesize, @function
sdcard_findfilesize:
	lui	a5,%hi(.LANCHOR136)
	lw	a5,%lo(.LANCHOR136)(a5)
	slli	a0,a0,5
	add	a5,a5,a0
	lbu	a4,29(a5)
	lbu	a2,28(a5)
	lbu	a0,30(a5)
	lbu	a3,31(a5)
	slli	a4,a4,8
	or	a4,a4,a2
	slli	a5,a0,16
	or	a5,a5,a4
	slli	a0,a3,24
	or	a0,a0,a5
	ret
	.size	sdcard_findfilesize, .-sdcard_findfilesize
	.section	.text.sdcard_readcluster,"ax",@progbits
	.align	1
	.globl	sdcard_readcluster
	.type	sdcard_readcluster, @function
sdcard_readcluster:
	addi	sp,sp,-32
	sw	s2,16(sp)
	lui	s2,%hi(.LANCHOR135)
	addi	s2,s2,%lo(.LANCHOR135)
	lw	a5,0(s2)
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	lbu	a5,13(a5)
	beq	a5,zero,.L429
	lui	s4,%hi(.LANCHOR137)
	lui	s3,%hi(.LANCHOR138)
	addi	s1,a0,-2
	li	s0,0
	addi	s4,s4,%lo(.LANCHOR137)
	addi	s3,s3,%lo(.LANCHOR138)
.L431:
	mul	a5,a5,s1
	lw	a4,0(s3)
	lw	a1,0(s4)
	slli	a3,s0,9
	add	a1,a1,a3
	add	a5,a5,a4
	add	a0,a5,s0
	call	sdcard_readsector
	lw	a5,0(s2)
	addi	s0,s0,1
	slli	a4,s0,16
	lbu	a5,13(a5)
	srli	a4,a4,16
	bgtu	a5,a4,.L431
.L429:
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	lw	s4,8(sp)
	addi	sp,sp,32
	jr	ra
	.size	sdcard_readcluster, .-sdcard_readcluster
	.section	.text.sdcard_readfile,"ax",@progbits
	.align	1
	.globl	sdcard_readfile
	.type	sdcard_readfile, @function
sdcard_readfile:
	lui	a5,%hi(.LANCHOR136)
	lw	a5,%lo(.LANCHOR136)(a5)
	addi	sp,sp,-48
	slli	a4,a0,5
	sw	s1,36(sp)
	sw	s2,32(sp)
	sw	s3,28(sp)
	sw	s4,24(sp)
	sw	s5,20(sp)
	sw	s6,16(sp)
	sw	s7,12(sp)
	sw	ra,44(sp)
	sw	s0,40(sp)
	sw	s8,8(sp)
	sw	s9,4(sp)
	sw	s10,0(sp)
	add	a5,a5,a4
	lbu	a4,27(a5)
	lbu	a5,26(a5)
	lui	s7,%hi(.LANCHOR135)
	slli	a4,a4,8
	lui	s3,%hi(.LANCHOR139)
	li	s2,65536
	mv	s6,a1
	or	s1,a4,a5
	addi	s7,s7,%lo(.LANCHOR135)
	addi	s3,s3,%lo(.LANCHOR139)
	lui	s5,%hi(.LANCHOR137)
	lui	s4,%hi(.LANCHOR138)
	addi	s2,s2,-1
.L439:
	lw	a5,0(s7)
	lbu	a0,13(a5)
	beq	a0,zero,.L436
	addi	s8,s1,-2
	li	s0,0
	addi	s9,s5,%lo(.LANCHOR137)
	addi	s10,s4,%lo(.LANCHOR138)
.L437:
	mul	a0,a0,s8
	lw	a5,0(s10)
	lw	a1,0(s9)
	slli	a4,s0,9
	add	a1,a1,a4
	add	a0,a0,a5
	add	a0,a0,s0
	call	sdcard_readsector
	lw	a4,0(s7)
	addi	s0,s0,1
	slli	a5,s0,16
	lbu	a0,13(a4)
	srli	a5,a5,16
	bgtu	a0,a5,.L437
	beq	a0,zero,.L436
	li	a5,0
.L438:
	lw	a4,0(s9)
	addi	s6,s6,1
	add	a4,a4,a5
	lbu	a4,0(a4)
	addi	a5,a5,1
	sb	a4,-1(s6)
	lw	a4,0(s7)
	lbu	a4,13(a4)
	slli	a4,a4,9
	bgt	a4,a5,.L438
.L436:
	lw	a5,0(s3)
	slli	s1,s1,1
	add	a5,a5,s1
	lhu	s1,0(a5)
	bne	s1,s2,.L439
	lw	ra,44(sp)
	lw	s0,40(sp)
	lw	s1,36(sp)
	lw	s2,32(sp)
	lw	s3,28(sp)
	lw	s4,24(sp)
	lw	s5,20(sp)
	lw	s6,16(sp)
	lw	s7,12(sp)
	lw	s8,8(sp)
	lw	s9,4(sp)
	lw	s10,0(sp)
	addi	sp,sp,48
	jr	ra
	.size	sdcard_readfile, .-sdcard_readfile
	.section	.text.skipcomment,"ax",@progbits
	.align	1
	.globl	skipcomment
	.type	skipcomment, @function
skipcomment:
	add	a5,a0,a1
	lbu	a4,0(a5)
	li	a5,10
	beq	a4,a5,.L451
	li	a4,10
.L452:
	addi	a1,a1,1
	add	a5,a0,a1
	lbu	a5,0(a5)
	bne	a5,a4,.L452
.L451:
	addi	a0,a1,1
	ret
	.size	skipcomment, .-skipcomment
	.section	.text.netppm_display,"ax",@progbits
	.align	1
	.globl	netppm_display
	.type	netppm_display, @function
netppm_display:
	lbu	a4,0(a0)
	li	a5,80
	beq	a4,a5,.L488
.L485:
	ret
.L488:
	lbu	a4,1(a0)
	li	a5,54
	bne	a4,a5,.L485
	lbu	a4,2(a0)
	li	a5,10
	bne	a4,a5,.L485
	lbu	a7,3(a0)
	li	a5,35
	bne	a7,a5,.L470
	li	a5,3
	li	a2,10
	li	a6,35
.L457:
	mv	a3,a5
	addi	a5,a5,1
	add	a4,a0,a5
	lbu	a4,0(a4)
	bne	a4,a2,.L457
	addi	a5,a3,2
	add	a4,a0,a5
	lbu	a7,0(a4)
	beq	a7,a6,.L457
	addi	a4,a3,3
	addi	a3,a3,4
.L456:
	li	a2,32
	li	a6,0
	beq	a7,a2,.L459
	li	t1,32
.L460:
	slli	a4,a6,2
	add	a4,a6,a4
	mv	a3,a5
	addi	a5,a5,1
	slli	a4,a4,1
	add	a2,a0,a5
	add	a4,a4,a7
	lbu	a7,0(a2)
	addi	a4,a4,-48
	slli	a6,a4,16
	srli	a6,a6,16
	bne	a7,t1,.L460
	addi	a4,a3,2
	addi	a3,a3,3
.L459:
	add	a5,a0,a4
	lbu	a2,0(a5)
	li	a5,10
	li	a7,0
	beq	a2,a5,.L461
	li	t1,10
.L462:
	slli	a5,a7,2
	add	a5,a7,a5
	mv	a3,a4
	addi	a4,a4,1
	add	a7,a0,a4
	slli	a5,a5,1
	add	a5,a5,a2
	lbu	a2,0(a7)
	addi	a5,a5,-48
	slli	a7,a5,16
	srli	a7,a7,16
	bne	a2,t1,.L462
	addi	a3,a3,2
.L461:
	add	a5,a0,a3
	lbu	a4,0(a5)
	li	a5,10
	beq	a4,a5,.L485
	li	a5,0
	li	t1,10
.L463:
	slli	a2,a5,2
	add	a5,a5,a2
	mv	t3,a3
	addi	a3,a3,1
	slli	a5,a5,1
	add	a2,a0,a3
	add	a5,a5,a4
	lbu	a4,0(a2)
	addi	a5,a5,-48
	slli	a5,a5,16
	srli	a5,a5,16
	bne	a4,t1,.L463
	li	a4,255
	bne	a5,a4,.L485
	beq	a7,zero,.L485
	addi	a5,a6,-1
	slli	a5,a5,16
	srli	a5,a5,16
	addi	sp,sp,-32
	addi	a5,a5,1
	sw	s2,20(sp)
	slli	s2,a5,1
	sw	s0,28(sp)
	sw	s1,24(sp)
	sw	s3,16(sp)
	sw	s4,12(sp)
	addi	t3,t3,2
	li	t1,0
	lui	s1,%hi(.LANCHOR70)
	lui	s0,%hi(.LANCHOR71)
	lui	t2,%hi(.LANCHOR72)
	lui	t0,%hi(.LANCHOR27)
	lui	t6,%hi(.LANCHOR73)
	li	t5,1
	add	s2,s2,a5
.L464:
	slli	t4,t1,16
	add	a2,a0,t3
	li	a3,0
	srai	t4,t4,16
	beq	a6,zero,.L469
.L467:
	lbu	a5,0(a2)
	lbu	a4,1(a2)
	lbu	s3,2(a2)
	srai	a5,a5,2
	srai	a4,a4,4
	andi	a4,a4,12
	andi	a5,a5,48
	or	a5,a5,a4
	srai	a4,s3,6
	add	a5,a5,a4
	beq	a5,a1,.L465
	lw	a4,%lo(.LANCHOR70)(s1)
	slli	s3,a3,16
	srai	s3,s3,16
	sb	a5,0(a4)
	mv	a5,s3
	lw	s3,%lo(.LANCHOR71)(s0)
	lw	s4,%lo(.LANCHOR72)(t2)
	lw	a4,%lo(.LANCHOR27)(t0)
	sh	a5,0(s3)
	sh	t4,0(s4)
.L466:
	lbu	a5,0(a4)
	bne	a5,zero,.L466
	lw	a5,%lo(.LANCHOR73)(t6)
	sb	t5,0(a5)
.L465:
	addi	a3,a3,1
	slli	a3,a3,16
	srli	a3,a3,16
	addi	a2,a2,3
	bne	a3,a6,.L467
	add	t3,t3,s2
.L469:
	addi	t1,t1,1
	slli	t1,t1,16
	srli	t1,t1,16
	bne	t1,a7,.L464
	lw	s0,28(sp)
	lw	s1,24(sp)
	lw	s2,20(sp)
	lw	s3,16(sp)
	lw	s4,12(sp)
	addi	sp,sp,32
	jr	ra
.L470:
	li	a3,5
	li	a4,4
	li	a5,3
	j	.L456
	.size	netppm_display, .-netppm_display
	.section	.text.netppm_decoder,"ax",@progbits
	.align	1
	.globl	netppm_decoder
	.type	netppm_decoder, @function
netppm_decoder:
	lbu	a4,0(a0)
	li	a5,80
	beq	a4,a5,.L519
.L516:
	ret
.L519:
	lbu	a4,1(a0)
	li	a5,54
	bne	a4,a5,.L516
	lbu	a4,2(a0)
	li	a5,10
	bne	a4,a5,.L516
	lbu	a6,3(a0)
	li	a5,35
	bne	a6,a5,.L503
	li	a5,3
	li	a2,10
	li	a7,35
.L492:
	mv	a3,a5
	addi	a5,a5,1
	add	a4,a0,a5
	lbu	a4,0(a4)
	bne	a4,a2,.L492
	addi	a5,a3,2
	add	a4,a0,a5
	lbu	a6,0(a4)
	beq	a6,a7,.L492
	addi	a4,a3,3
	addi	a3,a3,4
.L491:
	li	a2,32
	li	a7,0
	beq	a6,a2,.L494
	li	t1,32
.L495:
	slli	a4,a7,2
	add	a4,a7,a4
	mv	a3,a5
	addi	a5,a5,1
	slli	a4,a4,1
	add	a2,a0,a5
	add	a4,a4,a6
	lbu	a6,0(a2)
	addi	a4,a4,-48
	slli	a7,a4,16
	srli	a7,a7,16
	bne	a6,t1,.L495
	addi	a4,a3,2
	addi	a3,a3,3
.L494:
	add	a5,a0,a4
	lbu	a2,0(a5)
	li	a5,10
	li	t1,0
	beq	a2,a5,.L496
	li	t3,10
.L497:
	slli	a5,t1,2
	add	a5,t1,a5
	mv	a3,a4
	addi	a4,a4,1
	slli	a5,a5,1
	add	a6,a0,a4
	add	a5,a5,a2
	lbu	a2,0(a6)
	addi	a5,a5,-48
	slli	t1,a5,16
	srli	t1,t1,16
	bne	a2,t3,.L497
	addi	a3,a3,2
.L496:
	add	a5,a0,a3
	lbu	a4,0(a5)
	li	a5,10
	beq	a4,a5,.L516
	li	a5,0
	li	a6,10
.L498:
	slli	a2,a5,2
	add	a5,a5,a2
	mv	t3,a3
	addi	a3,a3,1
	slli	a5,a5,1
	add	a2,a0,a3
	add	a5,a5,a4
	lbu	a4,0(a2)
	addi	a5,a5,-48
	slli	a5,a5,16
	srli	a5,a5,16
	bne	a4,a6,.L498
	li	a4,255
	bne	a5,a4,.L516
	beq	t1,zero,.L516
	addi	a5,a7,-1
	slli	a5,a5,16
	srli	a5,a5,16
	addi	sp,sp,-16
	sw	s0,12(sp)
	addi	s0,a5,1
	addi	t0,a1,1
	slli	t2,s0,1
	addi	t6,t3,2
	li	t4,0
	li	t5,0
	add	t0,t0,a5
	add	t2,t2,s0
.L499:
	add	a3,a0,t6
	add	a2,a1,t5
	add	t3,t0,t5
	beq	a7,zero,.L502
.L500:
	lbu	a5,0(a3)
	lbu	a4,1(a3)
	lbu	a6,2(a3)
	srai	a5,a5,2
	srai	a4,a4,4
	andi	a4,a4,12
	andi	a5,a5,48
	or	a5,a5,a4
	srai	a4,a6,6
	add	a5,a5,a4
	sb	a5,0(a2)
	addi	a2,a2,1
	addi	a3,a3,3
	bne	t3,a2,.L500
	add	t6,t6,t2
	add	t5,t5,s0
.L502:
	addi	t4,t4,1
	slli	t4,t4,16
	srli	t4,t4,16
	bne	t4,t1,.L499
	lw	s0,12(sp)
	addi	sp,sp,16
	jr	ra
.L503:
	li	a3,5
	li	a4,4
	li	a5,3
	j	.L491
	.size	netppm_decoder, .-netppm_decoder
	.section	.text.SMTSTOP,"ax",@progbits
	.align	1
	.globl	SMTSTOP
	.type	SMTSTOP, @function
SMTSTOP:
	lui	a5,%hi(.LANCHOR140)
	lw	a5,%lo(.LANCHOR140)(a5)
	sb	zero,0(a5)
	ret
	.size	SMTSTOP, .-SMTSTOP
	.section	.text.SMTSTART,"ax",@progbits
	.align	1
	.globl	SMTSTART
	.type	SMTSTART, @function
SMTSTART:
	lui	a5,%hi(.LANCHOR141)
	lw	a3,%lo(.LANCHOR141)(a5)
	lui	a5,%hi(.LANCHOR142)
	lw	a4,%lo(.LANCHOR142)(a5)
	lui	a5,%hi(.LANCHOR140)
	lw	a5,%lo(.LANCHOR140)(a5)
	srli	a2,a0,16
	slli	a0,a0,16
	sw	a2,0(a3)
	srli	a0,a0,16
	sw	a0,0(a4)
	li	a4,1
	sb	a4,0(a5)
	ret
	.size	SMTSTART, .-SMTSTART
	.section	.text.SMTSTATE,"ax",@progbits
	.align	1
	.globl	SMTSTATE
	.type	SMTSTATE, @function
SMTSTATE:
	lui	a5,%hi(.LANCHOR140)
	lw	a5,%lo(.LANCHOR140)(a5)
	lbu	a0,0(a5)
	ret
	.size	SMTSTATE, .-SMTSTATE
	.section	.text.__position_curses,"ax",@progbits
	.align	1
	.globl	__position_curses
	.type	__position_curses, @function
__position_curses:
	lui	a3,%hi(.LANCHOR129)
	addi	a3,a3,%lo(.LANCHOR129)
	lw	a4,0(a3)
.L524:
	lbu	a5,0(a4)
	bne	a5,zero,.L524
	lui	a5,%hi(.LANCHOR131)
	lw	a5,%lo(.LANCHOR131)(a5)
	andi	a0,a0,0xff
	andi	a1,a1,0xff
	sb	a0,0(a5)
	lui	a5,%hi(.LANCHOR130)
	lw	a5,%lo(.LANCHOR130)(a5)
	li	a4,1
	sb	a1,0(a5)
	lw	a5,0(a3)
	sb	a4,0(a5)
	ret
	.size	__position_curses, .-__position_curses
	.section	.text.__read_curses_cell,"ax",@progbits
	.align	1
	.globl	__read_curses_cell
	.type	__read_curses_cell, @function
__read_curses_cell:
	lui	a3,%hi(.LANCHOR129)
	addi	a3,a3,%lo(.LANCHOR129)
	lw	a4,0(a3)
.L527:
	lbu	a5,0(a4)
	bne	a5,zero,.L527
	lui	a5,%hi(.LANCHOR131)
	lw	a5,%lo(.LANCHOR131)(a5)
	andi	a0,a0,0xff
	andi	a1,a1,0xff
	sb	a0,0(a5)
	lui	a5,%hi(.LANCHOR130)
	lw	a5,%lo(.LANCHOR130)(a5)
	li	a4,1
	sb	a1,0(a5)
	lw	a5,0(a3)
	lui	a3,%hi(.LANCHOR133)
	sb	a4,0(a5)
	lui	a5,%hi(.LANCHOR134)
	lw	a4,%lo(.LANCHOR134)(a5)
	lui	a5,%hi(.LANCHOR132)
	lw	a5,%lo(.LANCHOR132)(a5)
	lw	a3,%lo(.LANCHOR133)(a3)
	lbu	a4,0(a4)
	lbu	a5,0(a5)
	lbu	a0,0(a3)
	slli	a4,a4,11
	andi	a5,a5,127
	slli	a5,a5,19
	or	a5,a5,a4
	slli	a0,a0,26
	or	a0,a5,a0
	ret
	.size	__read_curses_cell, .-__read_curses_cell
	.section	.text.__write_curses_cell,"ax",@progbits
	.align	1
	.globl	__write_curses_cell
	.type	__write_curses_cell, @function
__write_curses_cell:
	lui	a3,%hi(.LANCHOR129)
	addi	a3,a3,%lo(.LANCHOR129)
	lw	a5,0(a3)
.L530:
	lbu	a4,0(a5)
	bne	a4,zero,.L530
.L531:
	lbu	a4,0(a5)
	bne	a4,zero,.L531
	lui	a5,%hi(.LANCHOR131)
	lw	a5,%lo(.LANCHOR131)(a5)
	andi	a0,a0,0xff
	andi	a1,a1,0xff
	sb	a0,0(a5)
	lui	a5,%hi(.LANCHOR130)
	lw	a5,%lo(.LANCHOR130)(a5)
	sb	a1,0(a5)
	lw	a4,0(a3)
	li	a1,1
	srli	a5,a2,11
	sb	a1,0(a4)
	lui	a4,%hi(.LANCHOR134)
	lw	a4,%lo(.LANCHOR134)(a4)
	andi	a5,a5,0xff
	sb	a5,0(a4)
	lui	a5,%hi(.LANCHOR132)
	lw	a4,%lo(.LANCHOR132)(a5)
	srli	a5,a2,19
	andi	a5,a5,127
	sb	a5,0(a4)
	lui	a5,%hi(.LANCHOR133)
	lw	a5,%lo(.LANCHOR133)(a5)
	srli	a2,a2,26
	li	a4,5
	sb	a2,0(a5)
	lw	a5,0(a3)
	sb	a4,0(a5)
	ret
	.size	__write_curses_cell, .-__write_curses_cell
	.section	.text.initscr,"ax",@progbits
	.align	1
	.globl	initscr
	.type	initscr, @function
initscr:
	lui	a5,%hi(.LANCHOR129)
	lw	a4,%lo(.LANCHOR129)(a5)
.L535:
	lbu	a5,0(a4)
	bne	a5,zero,.L535
	li	a5,6
	sb	a5,0(a4)
	lui	a4,%hi(.LANCHOR143)
	sh	zero,%lo(.LANCHOR143)(a4)
	lui	a4,%hi(.LANCHOR144)
	sh	zero,%lo(.LANCHOR144)(a4)
	li	a3,63
	lui	a4,%hi(.LANCHOR145)
	sh	a3,%lo(.LANCHOR145)(a4)
	lui	a4,%hi(.LANCHOR146)
	li	a5,1
	sh	zero,%lo(.LANCHOR146)(a4)
	lui	a4,%hi(.LANCHOR147)
	sb	a5,%lo(.LANCHOR147)(a4)
	lui	a4,%hi(.LANCHOR148)
	sb	a5,%lo(.LANCHOR148)(a4)
	ret
	.size	initscr, .-initscr
	.section	.text.endwin,"ax",@progbits
	.align	1
	.globl	endwin
	.type	endwin, @function
endwin:
	li	a0,1
	ret
	.size	endwin, .-endwin
	.section	.text.refresh,"ax",@progbits
	.align	1
	.globl	refresh
	.type	refresh, @function
refresh:
	lui	a5,%hi(.LANCHOR129)
	lw	a4,%lo(.LANCHOR129)(a5)
.L539:
	lbu	a5,0(a4)
	bne	a5,zero,.L539
	li	a5,7
	sb	a5,0(a4)
	li	a0,1
	ret
	.size	refresh, .-refresh
	.section	.text.clear,"ax",@progbits
	.align	1
	.globl	clear
	.type	clear, @function
clear:
	lui	a5,%hi(.LANCHOR129)
	lw	a4,%lo(.LANCHOR129)(a5)
.L542:
	lbu	a5,0(a4)
	bne	a5,zero,.L542
	li	a5,6
	sb	a5,0(a4)
	lui	a5,%hi(.LANCHOR143)
	sh	zero,%lo(.LANCHOR143)(a5)
	lui	a5,%hi(.LANCHOR144)
	sh	zero,%lo(.LANCHOR144)(a5)
	li	a4,63
	lui	a5,%hi(.LANCHOR145)
	sh	a4,%lo(.LANCHOR145)(a5)
	lui	a5,%hi(.LANCHOR146)
	sh	zero,%lo(.LANCHOR146)(a5)
	li	a0,1
	ret
	.size	clear, .-clear
	.section	.text.cbreak,"ax",@progbits
	.align	1
	.globl	cbreak
	.type	cbreak, @function
cbreak:
	ret
	.size	cbreak, .-cbreak
	.section	.text.echo,"ax",@progbits
	.align	1
	.globl	echo
	.type	echo, @function
echo:
	ret
	.size	echo, .-echo
	.section	.text.noecho,"ax",@progbits
	.align	1
	.globl	noecho
	.type	noecho, @function
noecho:
	ret
	.size	noecho, .-noecho
	.section	.text.scroll,"ax",@progbits
	.align	1
	.globl	scroll
	.type	scroll, @function
scroll:
	lui	a5,%hi(.LANCHOR148)
	li	a4,1
	sb	a4,%lo(.LANCHOR148)(a5)
	ret
	.size	scroll, .-scroll
	.section	.text.noscroll,"ax",@progbits
	.align	1
	.globl	noscroll
	.type	noscroll, @function
noscroll:
	lui	a5,%hi(.LANCHOR148)
	sb	zero,%lo(.LANCHOR148)(a5)
	ret
	.size	noscroll, .-noscroll
	.section	.text.curs_set,"ax",@progbits
	.align	1
	.globl	curs_set
	.type	curs_set, @function
curs_set:
	lui	a5,%hi(.LANCHOR147)
	sb	a0,%lo(.LANCHOR147)(a5)
	ret
	.size	curs_set, .-curs_set
	.section	.text.start_color,"ax",@progbits
	.align	1
	.globl	start_color
	.type	start_color, @function
start_color:
	lui	a5,%hi(.LANCHOR149)
	lui	a4,%hi(.LANCHOR150)
	addi	a5,a5,%lo(.LANCHOR149)
	addi	a4,a4,%lo(.LANCHOR150)
	sw	zero,0(a5)
	sw	zero,0(a4)
	sw	zero,4(a4)
	sw	zero,8(a4)
	sh	zero,12(a4)
	sb	zero,14(a4)
	li	a4,48
	sb	a4,1(a5)
	li	a4,16384
	addi	a4,a4,-1012
	sh	a4,2(a5)
	li	a4,1057959936
	addi	a4,a4,771
	sw	zero,8(a5)
	sh	zero,12(a5)
	sb	zero,14(a5)
	sw	a4,4(a5)
	li	a0,1
	ret
	.size	start_color, .-start_color
	.section	.text.has_colors,"ax",@progbits
	.align	1
	.globl	has_colors
	.type	has_colors, @function
has_colors:
	li	a0,1
	ret
	.size	has_colors, .-has_colors
	.section	.text.can_change_color,"ax",@progbits
	.align	1
	.globl	can_change_color
	.type	can_change_color, @function
can_change_color:
	li	a0,1
	ret
	.size	can_change_color, .-can_change_color
	.section	.text.init_pair,"ax",@progbits
	.align	1
	.globl	init_pair
	.type	init_pair, @function
init_pair:
	lui	a4,%hi(.LANCHOR149)
	lui	a5,%hi(.LANCHOR150)
	addi	a5,a5,%lo(.LANCHOR150)
	addi	a4,a4,%lo(.LANCHOR149)
	add	a4,a4,a0
	add	a0,a5,a0
	sb	a2,0(a0)
	sb	a1,0(a4)
	li	a0,1
	ret
	.size	init_pair, .-init_pair
	.section	.text.move,"ax",@progbits
	.align	1
	.globl	move
	.type	move, @function
move:
	li	a5,79
	lui	a3,%hi(.LANCHOR143)
	ble	a1,a5,.L555
	li	a1,79
	sh	a1,%lo(.LANCHOR143)(a3)
	li	a5,29
	lui	a4,%hi(.LANCHOR144)
	ble	a0,a5,.L557
.L559:
	li	a0,29
	sh	a0,%lo(.LANCHOR144)(a4)
	li	a0,1
	ret
.L555:
	not	a5,a1
	srai	a5,a5,31
	and	a1,a1,a5
	sh	a1,%lo(.LANCHOR143)(a3)
	li	a5,29
	lui	a4,%hi(.LANCHOR144)
	bgt	a0,a5,.L559
.L557:
	not	a5,a0
	srai	a5,a5,31
	and	a0,a0,a5
	sh	a0,%lo(.LANCHOR144)(a4)
	li	a0,1
	ret
	.size	move, .-move
	.section	.text.__scroll,"ax",@progbits
	.align	1
	.globl	__scroll
	.type	__scroll, @function
__scroll:
	addi	sp,sp,-32
	lui	a0,%hi(.LANCHOR129)
	lui	t6,%hi(.LANCHOR131)
	lui	t5,%hi(.LANCHOR130)
	lui	t4,%hi(.LANCHOR134)
	lui	t3,%hi(.LANCHOR132)
	lui	t1,%hi(.LANCHOR133)
	sw	s1,24(sp)
	sw	s2,20(sp)
	sw	s3,16(sp)
	sw	s4,12(sp)
	sw	s0,28(sp)
	li	s3,0
	addi	a0,a0,%lo(.LANCHOR129)
	addi	t6,t6,%lo(.LANCHOR131)
	addi	t5,t5,%lo(.LANCHOR130)
	addi	t4,t4,%lo(.LANCHOR134)
	addi	t3,t3,%lo(.LANCHOR132)
	addi	t1,t1,%lo(.LANCHOR133)
	li	t0,1
	li	s2,5
	li	s1,80
	li	s4,29
.L561:
	addi	s3,s3,1
	andi	s0,s3,0xff
	addi	t2,s0,-1
	slli	s3,s3,16
	srli	s3,s3,16
	andi	t2,t2,0xff
	li	a3,0
.L565:
	lw	a4,0(a0)
.L562:
	lbu	a5,0(a4)
	bne	a5,zero,.L562
	lw	a5,0(t6)
	andi	a7,a3,0xff
	sb	a7,0(a5)
	lw	a5,0(t5)
	sb	s0,0(a5)
	lw	a5,0(a0)
	sb	t0,0(a5)
	lw	a2,0(t4)
	lw	a5,0(t1)
	lw	a4,0(t3)
	lbu	a6,0(a2)
	lbu	a4,0(a4)
	lbu	a2,0(a5)
	lw	a5,0(a0)
	andi	a6,a6,0xff
	andi	a1,a4,0xff
	andi	a2,a2,0xff
.L563:
	lbu	a4,0(a5)
	bne	a4,zero,.L563
.L564:
	lbu	a4,0(a5)
	bne	a4,zero,.L564
	andi	a5,a2,63
	lw	a2,0(t6)
	andi	a4,a1,127
	addi	a3,a3,1
	sb	a7,0(a2)
	lw	a2,0(t5)
	slli	a3,a3,16
	srli	a3,a3,16
	sb	t2,0(a2)
	lw	a2,0(a0)
	sb	t0,0(a2)
	lw	a2,0(t4)
	sb	a6,0(a2)
	lw	a2,0(t3)
	sb	a4,0(a2)
	lw	a4,0(t1)
	sb	a5,0(a4)
	lw	a5,0(a0)
	sb	s2,0(a5)
	bne	a3,s1,.L565
	bne	s3,s4,.L561
	lw	s0,28(sp)
	lw	s1,24(sp)
	lw	s2,20(sp)
	lw	s3,16(sp)
	lw	s4,12(sp)
	addi	sp,sp,32
	jr	ra
	.size	__scroll, .-__scroll
	.section	.text.addch,"ax",@progbits
	.align	1
	.globl	addch
	.type	addch, @function
addch:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s1,4(sp)
	li	a5,10
	beq	a0,a5,.L573
	li	a5,13
	beq	a0,a5,.L574
	li	a5,8
	beq	a0,a5,.L592
	lui	a5,%hi(.LANCHOR146)
	lhu	a5,%lo(.LANCHOR146)(a5)
	lui	a4,%hi(.LANCHOR145)
	lhu	a2,%lo(.LANCHOR145)(a4)
	lui	s0,%hi(.LANCHOR144)
	lui	s1,%hi(.LANCHOR143)
	addi	s1,s1,%lo(.LANCHOR143)
	andi	a5,a5,127
	addi	s0,s0,%lo(.LANCHOR144)
	slli	a4,a5,19
	lhu	a1,0(s0)
	slli	a5,a0,11
	lhu	a0,0(s1)
	or	a5,a4,a5
	slli	a2,a2,26
	or	a2,a5,a2
	call	__write_curses_cell
	lhu	a5,0(s1)
	li	a4,79
	beq	a5,a4,.L593
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	a5,a5,1
	sh	a5,0(s1)
	li	a0,1
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
.L592:
	lui	a5,%hi(.LANCHOR143)
	addi	a5,a5,%lo(.LANCHOR143)
	lhu	a4,0(a5)
	bne	a4,zero,.L594
	lui	a4,%hi(.LANCHOR144)
	addi	a4,a4,%lo(.LANCHOR144)
	lhu	a3,0(a4)
	beq	a3,zero,.L577
	addi	a3,a3,-1
	sh	a3,0(a4)
	li	a4,79
	sh	a4,0(a5)
	j	.L577
.L574:
	lui	a5,%hi(.LANCHOR143)
	sh	zero,%lo(.LANCHOR143)(a5)
.L577:
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	li	a0,1
	addi	sp,sp,16
	jr	ra
.L573:
	lui	s0,%hi(.LANCHOR144)
	addi	s0,s0,%lo(.LANCHOR144)
	lhu	a5,0(s0)
	lui	a4,%hi(.LANCHOR143)
	sh	zero,%lo(.LANCHOR143)(a4)
	li	a4,29
	beq	a5,a4,.L591
.L581:
	addi	a5,a5,1
	lw	ra,12(sp)
	sh	a5,0(s0)
	lw	s0,8(sp)
	lw	s1,4(sp)
	li	a0,1
	addi	sp,sp,16
	jr	ra
.L594:
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	a4,a4,-1
	sh	a4,0(a5)
	lw	s1,4(sp)
	li	a0,1
	addi	sp,sp,16
	jr	ra
.L593:
	lhu	a5,0(s0)
	sh	zero,0(s1)
	li	a4,29
	bne	a5,a4,.L581
.L591:
	lui	a5,%hi(.LANCHOR148)
	lbu	a5,%lo(.LANCHOR148)(a5)
	bne	a5,zero,.L595
	sh	zero,0(s0)
	j	.L577
.L595:
	call	__scroll
	j	.L577
	.size	addch, .-addch
	.section	.text.mvaddch,"ax",@progbits
	.align	1
	.globl	mvaddch
	.type	mvaddch, @function
mvaddch:
	li	a4,79
	mv	a5,a0
	lui	a6,%hi(.LANCHOR143)
	mv	a0,a2
	ble	a1,a4,.L597
	li	a1,79
	sh	a1,%lo(.LANCHOR143)(a6)
	li	a4,29
	lui	a3,%hi(.LANCHOR144)
	ble	a5,a4,.L599
.L601:
	li	a5,29
	sh	a5,%lo(.LANCHOR144)(a3)
	tail	addch
.L597:
	not	a4,a1
	srai	a4,a4,31
	and	a1,a1,a4
	sh	a1,%lo(.LANCHOR143)(a6)
	li	a4,29
	lui	a3,%hi(.LANCHOR144)
	bgt	a5,a4,.L601
.L599:
	not	a4,a5
	srai	a4,a4,31
	and	a5,a5,a4
	sh	a5,%lo(.LANCHOR144)(a3)
	tail	addch
	.size	mvaddch, .-mvaddch
	.section	.text.__curses_print_string,"ax",@progbits
	.align	1
	.globl	__curses_print_string
	.type	__curses_print_string, @function
__curses_print_string:
	addi	sp,sp,-16
	sw	s0,8(sp)
	sw	ra,12(sp)
	mv	s0,a0
	lbu	a0,0(a0)
	beq	a0,zero,.L602
.L604:
	addi	s0,s0,1
	call	addch
	lbu	a0,0(s0)
	bne	a0,zero,.L604
.L602:
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	__curses_print_string, .-__curses_print_string
	.section	.text.printw,"ax",@progbits
	.align	1
	.globl	printw
	.type	printw, @function
printw:
	addi	sp,sp,-64
	addi	t1,sp,36
	sw	a1,36(sp)
	sw	a2,40(sp)
	sw	a3,44(sp)
	mv	a2,a0
	mv	a3,t1
	li	a1,1023
	li	a0,4096
	sw	a5,52(sp)
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	a4,48(sp)
	sw	a6,56(sp)
	sw	a7,60(sp)
	sw	t1,12(sp)
	call	vsnprintf
	li	a5,4096
	lbu	a0,0(a5)
	beq	a0,zero,.L611
	li	s0,4096
.L612:
	addi	s0,s0,1
	call	addch
	lbu	a0,0(s0)
	bne	a0,zero,.L612
.L611:
	lw	ra,28(sp)
	lw	s0,24(sp)
	li	a0,1
	addi	sp,sp,64
	jr	ra
	.size	printw, .-printw
	.section	.text.mvprintw,"ax",@progbits
	.align	1
	.globl	mvprintw
	.type	mvprintw, @function
mvprintw:
	addi	sp,sp,-64
	addi	t1,sp,44
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	a3,44(sp)
	mv	s0,a0
	mv	a3,t1
	mv	s1,a1
	li	a0,4096
	li	a1,1023
	sw	a5,52(sp)
	sw	ra,28(sp)
	sw	a4,48(sp)
	sw	a6,56(sp)
	sw	a7,60(sp)
	sw	t1,12(sp)
	call	vsnprintf
	li	a5,79
	lui	a3,%hi(.LANCHOR143)
	ble	s1,a5,.L619
	li	s1,79
.L620:
	sh	s1,%lo(.LANCHOR143)(a3)
	li	a5,29
	lui	a4,%hi(.LANCHOR144)
	ble	s0,a5,.L621
	li	s0,29
.L622:
	sh	s0,%lo(.LANCHOR144)(a4)
	li	a5,4096
	lbu	a0,0(a5)
	beq	a0,zero,.L623
	li	s0,4096
.L624:
	addi	s0,s0,1
	call	addch
	lbu	a0,0(s0)
	bne	a0,zero,.L624
.L623:
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	li	a0,1
	addi	sp,sp,64
	jr	ra
.L621:
	not	a5,s0
	srai	a5,a5,31
	and	s0,s0,a5
	j	.L622
.L619:
	not	a5,s1
	srai	a5,a5,31
	and	s1,s1,a5
	j	.L620
	.size	mvprintw, .-mvprintw
	.section	.text.attron,"ax",@progbits
	.align	1
	.globl	attron
	.type	attron, @function
attron:
	lui	a4,%hi(.LANCHOR149)
	addi	a4,a4,%lo(.LANCHOR149)
	lui	a5,%hi(.LANCHOR150)
	add	a4,a4,a0
	addi	a5,a5,%lo(.LANCHOR150)
	lbu	a3,0(a4)
	add	a0,a5,a0
	lbu	a4,0(a0)
	lui	a5,%hi(.LANCHOR145)
	sh	a3,%lo(.LANCHOR145)(a5)
	lui	a5,%hi(.LANCHOR146)
	sh	a4,%lo(.LANCHOR146)(a5)
	li	a0,1
	ret
	.size	attron, .-attron
	.section	.text.deleteln,"ax",@progbits
	.align	1
	.globl	deleteln
	.type	deleteln, @function
deleteln:
	lui	a5,%hi(.LANCHOR144)
	lhu	t0,%lo(.LANCHOR144)(a5)
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	li	a5,29
	beq	t0,a5,.L652
	andi	t0,t0,0xff
	li	a5,28
	bgtu	t0,a5,.L640
	lui	a6,%hi(.LANCHOR129)
	lui	t5,%hi(.LANCHOR131)
	lui	t4,%hi(.LANCHOR130)
	lui	t3,%hi(.LANCHOR134)
	lui	t1,%hi(.LANCHOR132)
	lui	a7,%hi(.LANCHOR133)
	addi	a6,a6,%lo(.LANCHOR129)
	addi	t5,t5,%lo(.LANCHOR131)
	addi	t4,t4,%lo(.LANCHOR130)
	addi	t3,t3,%lo(.LANCHOR134)
	addi	t1,t1,%lo(.LANCHOR132)
	addi	a7,a7,%lo(.LANCHOR133)
	li	t6,1
	li	ra,5
	li	t2,80
	li	s1,29
.L634:
	addi	a5,t0,1
	mv	s0,t0
	li	a3,0
	andi	t0,a5,0xff
.L639:
	lw	a4,0(a6)
.L636:
	lbu	a5,0(a4)
	bne	a5,zero,.L636
	lw	a5,0(t5)
	andi	s3,s3,2047
	sb	a3,0(a5)
	lw	a5,0(t4)
	sb	t0,0(a5)
	lw	a5,0(a6)
	sb	t6,0(a5)
	lw	a4,0(t1)
	lw	a2,0(t3)
	lw	a5,0(a7)
	lbu	a2,0(a2)
	lbu	a0,0(a4)
	lbu	a1,0(a5)
	slli	a5,a2,11
	andi	a4,a0,127
	slli	a4,a4,19
	slli	s2,a1,26
	or	a4,a4,a5
	lw	a5,0(a6)
	or	a4,a4,s2
	andi	a1,a1,0xff
	andi	s2,a2,0xff
	andi	a0,a0,127
	or	s3,a4,s3
.L637:
	lbu	a4,0(a5)
	bne	a4,zero,.L637
.L638:
	lbu	a4,0(a5)
	bne	a4,zero,.L638
	lw	a5,0(t5)
	andi	a0,a0,0xff
	andi	a1,a1,63
	sb	a3,0(a5)
	lw	a5,0(t4)
	addi	a3,a3,1
	andi	a3,a3,0xff
	sb	s0,0(a5)
	lw	a5,0(a6)
	sb	t6,0(a5)
	lw	a5,0(t3)
	sb	s2,0(a5)
	lw	a5,0(t1)
	sb	a0,0(a5)
	lw	a5,0(a7)
	sb	a1,0(a5)
	lw	a5,0(a6)
	sb	ra,0(a5)
	bne	a3,t2,.L639
	bne	t0,s1,.L634
.L640:
	lui	a5,%hi(.LANCHOR146)
	lhu	a5,%lo(.LANCHOR146)(a5)
	lui	a4,%hi(.LANCHOR145)
	lhu	a4,%lo(.LANCHOR145)(a4)
	andi	a5,a5,127
	slli	a5,a5,19
	slli	a4,a4,26
	or	a5,a5,a4
	andi	s3,s3,2047
	or	s3,a5,s3
	li	s0,0
	li	s1,80
.L635:
	slli	a0,s0,16
	srli	a0,a0,16
	addi	s0,s0,1
	mv	a2,s3
	li	a1,29
	call	__write_curses_cell
	bne	s0,s1,.L635
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	li	a0,1
	addi	sp,sp,32
	jr	ra
.L652:
	lui	a5,%hi(.LANCHOR146)
	lhu	s3,%lo(.LANCHOR146)(a5)
	lui	a5,%hi(.LANCHOR145)
	lhu	a5,%lo(.LANCHOR145)(a5)
	andi	s3,s3,127
	slli	s3,s3,19
	slli	a5,a5,26
	or	s3,s3,a5
	li	s0,0
	li	s1,80
.L633:
	slli	a0,s0,16
	srli	a0,a0,16
	addi	s0,s0,1
	mv	a2,s3
	li	a1,29
	call	__write_curses_cell
	bne	s0,s1,.L633
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	li	a0,1
	addi	sp,sp,32
	jr	ra
	.size	deleteln, .-deleteln
	.section	.text.clrtoeol,"ax",@progbits
	.align	1
	.globl	clrtoeol
	.type	clrtoeol, @function
clrtoeol:
	addi	sp,sp,-32
	lui	a5,%hi(.LANCHOR146)
	sw	s1,20(sp)
	lhu	s1,%lo(.LANCHOR146)(a5)
	lui	a5,%hi(.LANCHOR145)
	lui	a4,%hi(.LANCHOR143)
	lhu	a5,%lo(.LANCHOR145)(a5)
	sw	s0,24(sp)
	lhu	s0,%lo(.LANCHOR143)(a4)
	andi	s1,s1,127
	slli	s1,s1,19
	slli	a5,a5,26
	sw	ra,28(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	li	a4,79
	or	s1,s1,a5
	bgt	s0,a4,.L654
	lui	s2,%hi(.LANCHOR144)
	addi	s2,s2,%lo(.LANCHOR144)
	li	s3,80
.L655:
	lhu	a1,0(s2)
	slli	a0,s0,16
	srli	a0,a0,16
	addi	s0,s0,1
	mv	a2,s1
	call	__write_curses_cell
	bne	s0,s3,.L655
.L654:
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	li	a0,1
	addi	sp,sp,32
	jr	ra
	.size	clrtoeol, .-clrtoeol
	.section	.text._sbrk,"ax",@progbits
	.align	1
	.globl	_sbrk
	.type	_sbrk, @function
_sbrk:
	lui	a5,%hi(.LANCHOR151)
	addi	a5,a5,%lo(.LANCHOR151)
	lw	a4,0(a5)
	beq	a4,zero,.L661
.L659:
	blt	a0,zero,.L658
	add	a0,a4,a0
	sw	a0,0(a5)
.L658:
	mv	a0,a4
	ret
.L661:
	lui	a4,%hi(.LANCHOR152)
	lw	a4,%lo(.LANCHOR152)(a4)
	li	a3,-16777216
	addi	a3,a3,-32
	add	a4,a4,a3
	sw	a4,0(a5)
	j	.L659
	.size	_sbrk, .-_sbrk
	.section	.text._write,"ax",@progbits
	.align	1
	.globl	_write
	.type	_write, @function
_write:
	addi	t1,a2,-1
	beq	a2,zero,.L673
	li	t4,2
	lui	t6,%hi(.LANCHOR0)
	lui	t5,%hi(.LANCHOR1)
	li	a7,10
	li	t3,-1
.L667:
	bleu	a0,t4,.L674
.L664:
	addi	t1,t1,-1
	bne	t1,t3,.L667
.L673:
	li	a0,0
	ret
.L674:
	lbu	a3,0(a1)
	addi	a6,t6,%lo(.LANCHOR0)
	addi	a1,a1,1
	addi	a2,t5,%lo(.LANCHOR1)
.L666:
	lw	a4,0(a6)
.L665:
	lbu	a5,0(a4)
	andi	a5,a5,2
	bne	a5,zero,.L665
	lw	a5,0(a2)
	sb	a3,0(a5)
	bne	a3,a7,.L664
	li	a3,13
	j	.L666
	.size	_write, .-_write
	.section	.text._read,"ax",@progbits
	.align	1
	.globl	_read
	.type	_read, @function
_read:
	addi	a4,a2,-1
	beq	a2,zero,.L685
	li	a6,2
	lui	t3,%hi(.LANCHOR0)
	lui	t1,%hi(.LANCHOR1)
	li	a2,-1
.L679:
	bleu	a0,a6,.L686
.L677:
	addi	a4,a4,-1
	bne	a4,a2,.L679
.L685:
	li	a0,0
	ret
.L686:
	lw	a3,%lo(.LANCHOR0)(t3)
	addi	a7,a1,1
.L678:
	lbu	a5,0(a3)
	andi	a5,a5,1
	beq	a5,zero,.L678
	lw	a5,%lo(.LANCHOR1)(t1)
	lbu	a5,0(a5)
	sb	a5,0(a1)
	mv	a1,a7
	j	.L677
	.size	_read, .-_read
	.section	.text._open,"ax",@progbits
	.align	1
	.globl	_open
	.type	_open, @function
_open:
	li	a0,-1
	ret
	.size	_open, .-_open
	.section	.text._close,"ax",@progbits
	.align	1
	.globl	_close
	.type	_close, @function
_close:
	li	a0,-1
	ret
	.size	_close, .-_close
	.section	.text._fstat,"ax",@progbits
	.align	1
	.globl	_fstat
	.type	_fstat, @function
_fstat:
	li	a0,0
	ret
	.size	_fstat, .-_fstat
	.section	.text._isatty,"ax",@progbits
	.align	1
	.globl	_isatty
	.type	_isatty, @function
_isatty:
	li	a0,0
	ret
	.size	_isatty, .-_isatty
	.section	.text._lseek,"ax",@progbits
	.align	1
	.globl	_lseek
	.type	_lseek, @function
_lseek:
	li	a0,0
	ret
	.size	_lseek, .-_lseek
	.section	.text._getpid,"ax",@progbits
	.align	1
	.globl	_getpid
	.type	_getpid, @function
_getpid:
	li	a0,0
	ret
	.size	_getpid, .-_getpid
	.section	.text._kill,"ax",@progbits
	.align	1
	.globl	_kill
	.type	_kill, @function
_kill:
	li	a0,-1
	ret
	.size	_kill, .-_kill
	.section	.text._exit,"ax",@progbits
	.align	1
	.globl	_exit
	.type	_exit, @function
_exit:
	addi	sp,sp,-16
	sw	ra,12(sp)
	li	a5,0
	jalr	a5
.L695:
	j	.L695
	.size	_exit, .-_exit
	.section	.text.filemalloc,"ax",@progbits
	.align	1
	.globl	filemalloc
	.type	filemalloc, @function
filemalloc:
	lui	a5,%hi(.LANCHOR153)
	lw	a5,%lo(.LANCHOR153)(a5)
	remu	a4,a0,a5
	divu	a0,a0,a5
	snez	a4,a4
	add	a0,a0,a4
	mul	a0,a5,a0
	tail	malloc
	.size	filemalloc, .-filemalloc
	.section	.text.INITIALISEMEMORY,"ax",@progbits
	.align	1
	.globl	INITIALISEMEMORY
	.type	INITIALISEMEMORY, @function
INITIALISEMEMORY:
	li	a5,301989888
	addi	a0,a5,-66
	lui	a4,%hi(.LANCHOR154)
	addi	a5,a5,-512
	li	a2,301465600
	sw	a5,%lo(.LANCHOR154)(a4)
	lui	a5,%hi(.LANCHOR135)
	sw	a2,%lo(.LANCHOR135)(a5)
	lui	a5,%hi(.LANCHOR155)
	sw	a0,%lo(.LANCHOR155)(a5)
	lw	a4,16(a2)
	li	a5,9437184
	lhu	a6,22(a2)
	srli	a4,a4,8
	slli	a4,a4,16
	srli	a4,a4,16
	addi	a5,a5,-32
	sub	a5,a5,a4
	slli	a5,a5,5
	lui	a3,%hi(.LANCHOR136)
	sw	a5,%lo(.LANCHOR136)(a3)
	slli	a3,a6,10
	sub	a5,a5,a3
	lui	a3,%hi(.LANCHOR139)
	sw	a5,%lo(.LANCHOR139)(a3)
	lbu	a1,13(a2)
	srli	a3,a4,4
	slli	a4,a1,9
	sub	a5,a5,a4
	lui	a1,%hi(.LANCHOR137)
	sw	a5,%lo(.LANCHOR137)(a1)
	lui	a1,%hi(.LANCHOR153)
	sw	a4,%lo(.LANCHOR153)(a1)
	lbu	a1,16(a2)
	lhu	a4,10(a0)
	lhu	a0,8(a0)
	mul	a1,a1,a6
	lhu	a2,14(a2)
	slli	a4,a4,16
	or	a4,a4,a0
	add	a4,a4,a2
	lui	a2,%hi(.LANCHOR152)
	sw	a5,%lo(.LANCHOR152)(a2)
	lui	a5,%hi(.LANCHOR151)
	sw	zero,%lo(.LANCHOR151)(a5)
	add	a5,a4,a1
	add	a5,a5,a3
	lui	a4,%hi(.LANCHOR138)
	sw	a5,%lo(.LANCHOR138)(a4)
	ret
	.size	INITIALISEMEMORY, .-INITIALISEMEMORY
	.section	.text.njInit,"ax",@progbits
	.align	1
	.globl	njInit
	.type	njInit, @function
njInit:
	li	a2,524288
	lui	a0,%hi(nj)
	addi	a2,a2,712
	li	a1,0
	addi	a0,a0,%lo(nj)
	tail	memset
	.size	njInit, .-njInit
	.section	.text.njDone,"ax",@progbits
	.align	1
	.globl	njDone
	.type	njDone, @function
njDone:
	addi	sp,sp,-32
	sw	s2,16(sp)
	lui	s2,%hi(nj)
	sw	s1,20(sp)
	addi	s1,s2,%lo(nj)
	sw	s0,24(sp)
	sw	s3,12(sp)
	sw	ra,28(sp)
	addi	s0,s2,%lo(nj)
	addi	s3,s1,132
.L705:
	lw	a0,84(s0)
	addi	s0,s0,44
	beq	a0,zero,.L704
	call	free
.L704:
	bne	s0,s3,.L705
	li	a5,524288
	add	s1,s1,a5
	lw	a0,708(s1)
	beq	a0,zero,.L706
	call	free
.L706:
	lw	s0,24(sp)
	lw	ra,28(sp)
	lw	s1,20(sp)
	lw	s3,12(sp)
	addi	a0,s2,%lo(nj)
	lw	s2,16(sp)
	li	a2,524288
	addi	a2,a2,712
	li	a1,0
	addi	sp,sp,32
	tail	memset
	.size	njDone, .-njDone
	.section	.text.njDecode,"ax",@progbits
	.align	1
	.globl	njDecode
	.type	njDecode, @function
njDecode:
	addi	sp,sp,-128
	sw	s0,120(sp)
	sw	s1,116(sp)
	mv	s0,a1
	mv	s1,a0
	sw	s4,104(sp)
	sw	ra,124(sp)
	sw	s2,112(sp)
	sw	s3,108(sp)
	sw	s5,100(sp)
	sw	s6,96(sp)
	sw	s7,92(sp)
	sw	s8,88(sp)
	sw	s9,84(sp)
	sw	s10,80(sp)
	sw	s11,76(sp)
	call	njDone
	li	a5,-2147483648
	xori	a3,a5,-1
	lui	a4,%hi(nj)
	addi	s4,a4,%lo(nj)
	and	a3,s0,a3
	xori	a5,a5,-2
	sw	s1,4(s4)
	sw	a3,8(s4)
	and	s0,s0,a5
	li	a0,1
	beq	s0,zero,.L715
	lbu	a5,0(s1)
	lbu	a4,1(s1)
	li	a0,1
	not	a5,a5
	xori	a4,a4,-40
	or	a5,a5,a4
	andi	a5,a5,0xff
	beq	a5,zero,.L996
.L715:
	lw	ra,124(sp)
	lw	s0,120(sp)
	lw	s1,116(sp)
	lw	s2,112(sp)
	lw	s3,108(sp)
	lw	s4,104(sp)
	lw	s5,100(sp)
	lw	s6,96(sp)
	lw	s7,92(sp)
	lw	s8,88(sp)
	lw	s9,84(sp)
	lw	s10,80(sp)
	lw	s11,76(sp)
	addi	sp,sp,128
	jr	ra
.L996:
	lw	a5,12(s4)
	addi	s1,s1,2
	addi	a3,a3,-2
	addi	a5,a5,-2
	sw	s1,4(s4)
	sw	a3,8(s4)
	sw	a5,12(s4)
	blt	a3,zero,.L784
	lw	a0,0(s4)
	bne	a0,zero,.L718
	lui	s0,%hi(.L722)
	li	s2,524288
	lui	s3,%hi(nj+44)
	addi	s0,s0,%lo(.L722)
	add	s2,s4,s2
	lui	s1,%hi(.LANCHOR156)
.L810:
	li	a5,1
	ble	a3,a5,.L864
.L997:
	lw	a5,4(s4)
	li	a4,255
	lbu	s5,0(a5)
	bne	s5,a4,.L864
	lw	a4,12(s4)
	addi	a2,a5,2
	addi	a1,a3,-2
	addi	a4,a4,-2
	sw	a4,12(s4)
	sw	a2,4(s4)
	sw	a1,8(s4)
	lbu	a2,1(a5)
	li	a4,221
	bgtu	a2,a4,.L719
	li	a4,191
	bleu	a2,a4,.L887
	addi	a4,a2,64
	andi	a4,a4,0xff
	li	a0,29
	bgtu	a4,a0,.L720
	slli	a4,a4,2
	add	a4,a4,s0
	lw	a4,0(a4)
	jr	a4
	.section	.rodata.njDecode,"a",@progbits
	.align	2
	.align	2
.L722:
	.word	.L726
	.word	.L720
	.word	.L720
	.word	.L720
	.word	.L725
	.word	.L720
	.word	.L720
	.word	.L720
	.word	.L720
	.word	.L720
	.word	.L720
	.word	.L720
	.word	.L720
	.word	.L720
	.word	.L720
	.word	.L720
	.word	.L720
	.word	.L720
	.word	.L720
	.word	.L720
	.word	.L720
	.word	.L720
	.word	.L720
	.word	.L720
	.word	.L720
	.word	.L720
	.word	.L724
	.word	.L723
	.word	.L720
	.word	.L721
	.section	.text.njDecode
.L719:
	li	a5,254
	beq	a2,a5,.L993
.L720:
	andi	a2,a2,240
	li	a5,224
	bne	a2,a5,.L887
.L993:
	call	njDecodeLength
	lw	a3,12(s4)
	lw	a4,4(s4)
	lw	a5,8(s4)
	sw	zero,12(s4)
	add	a4,a4,a3
	sub	a5,a5,a3
	sw	a4,4(s4)
	sw	a5,8(s4)
	blt	a5,zero,.L784
.L751:
	lw	a0,0(s4)
	bne	a0,zero,.L718
	lw	a3,8(s4)
	li	a5,1
	bgt	a3,a5,.L997
.L864:
	li	a0,5
	j	.L715
.L721:
	call	njDecodeLength
	lw	a0,0(s4)
	bne	a0,zero,.L718
	lw	a1,12(s4)
	li	a5,1
	ble	a1,a5,.L784
	lw	a4,4(s4)
	lw	a3,8(s4)
	lbu	a5,1(a4)
	lbu	a2,0(a4)
	sub	a3,a3,a1
	slli	a5,a5,8
	or	a5,a5,a2
	slli	a2,a5,8
	srli	a5,a5,8
	or	a5,a2,a5
	slli	a5,a5,16
	add	a4,a4,a1
	srli	a5,a5,16
	sw	a5,704(s2)
	sw	a4,4(s4)
	sw	a3,8(s4)
	sw	zero,12(s4)
	bge	a3,zero,.L810
.L784:
	li	a5,5
	sw	a5,0(s4)
	li	a0,5
	j	.L715
.L723:
	call	njDecodeLength
	lw	a0,0(s4)
	bne	a0,zero,.L718
	lw	a5,12(s4)
	li	a0,64
	li	a6,1
	li	a1,65
	li	a7,5
.L770:
	ble	a5,a0,.L998
.L771:
	lw	a4,4(s4)
	lbu	a5,0(a4)
	andi	a3,a5,252
	bne	a3,zero,.L784
	lw	a3,180(s4)
	sll	a2,a6,a5
	slli	a5,a5,6
	or	a3,a3,a2
	sw	a3,180(s4)
	addi	a2,a5,184
	li	a5,1
	j	.L769
.L999:
	lw	a4,4(s4)
.L769:
	add	a4,a4,a5
	lbu	a3,0(a4)
	add	a4,a2,a5
	add	a4,s4,a4
	sb	a3,-1(a4)
	addi	a5,a5,1
	bne	a5,a1,.L999
	lw	a3,4(s4)
	lw	a4,8(s4)
	lw	a5,12(s4)
	addi	a3,a3,65
	addi	a4,a4,-65
	addi	a5,a5,-65
	sw	a3,4(s4)
	sw	a4,8(s4)
	sw	a5,12(s4)
	bge	a4,zero,.L770
	sw	a7,0(s4)
	bgt	a5,a0,.L771
.L998:
	beq	a5,zero,.L751
	j	.L784
.L724:
	li	a5,524288
	add	s3,s4,a5
	lw	a5,704(s3)
	sw	a5,4(sp)
	call	njDecodeLength
	lw	a0,0(s4)
	bne	a0,zero,.L718
	lw	a4,40(s4)
	lw	a1,12(s4)
	addi	a5,a4,2
	slli	a5,a5,1
	blt	a1,a5,.L784
	lw	a3,4(s4)
	lbu	a5,0(a3)
	beq	a4,a5,.L1000
.L994:
	li	a5,2
	sw	a5,0(s4)
	li	a0,2
	j	.L715
.L725:
	li	a4,1
	ble	a1,a4,.L784
	lbu	a4,3(a5)
	lbu	a2,2(a5)
	slli	a4,a4,8
	or	a4,a4,a2
	slli	s10,a4,8
	srli	a4,a4,8
	or	s10,s10,a4
	slli	s10,s10,16
	srli	s10,s10,16
	sw	s10,12(s4)
	blt	a1,s10,.L784
	lw	a0,0(s4)
	addi	s5,a5,4
	addi	a3,a3,-4
	addi	s10,s10,-2
	sw	s5,4(s4)
	sw	a3,8(s4)
	sw	s10,12(s4)
	bne	a0,zero,.L718
	li	a5,16
	ble	s10,a5,.L754
	li	s7,16
	li	s8,5
	li	s6,17
.L766:
	lbu	a5,0(s5)
	andi	a4,a5,236
	bne	a4,zero,.L784
	andi	a4,a5,2
	bne	a4,zero,.L994
	srai	s9,a5,3
	li	a2,16
	addi	a1,s5,1
	addi	a0,s1,%lo(.LANCHOR156)
	or	s9,s9,a5
	call	memcpy
	lw	a4,8(s4)
	addi	a5,s5,17
	addi	s10,s10,-17
	addi	a4,a4,-17
	sw	a5,4(s4)
	sw	a4,8(s4)
	sw	s10,12(s4)
	andi	s9,s9,3
	bge	a4,zero,.L755
	sw	s8,0(s4)
.L755:
	slli	a5,s9,17
	addi	a5,a5,440
	add	a5,s4,a5
	li	t5,65536
	li	a6,1
	li	a0,65536
	addi	t6,s1,%lo(.LANCHOR156)
	j	.L760
.L756:
	addi	a6,a6,1
	beq	a6,s6,.L1001
.L760:
	add	a4,t6,a6
	lbu	t1,-1(a4)
	srai	a0,a0,1
	beq	t1,zero,.L756
	lw	t4,12(s4)
	bgt	t1,t4,.L784
	sub	a4,s7,a6
	sll	a4,t1,a4
	sub	t5,t5,a4
	blt	t5,zero,.L784
	lw	a1,4(s4)
	slli	t3,a0,1
	andi	a2,a6,0xff
	add	a7,t1,a1
.L759:
	lbu	a4,0(a1)
	beq	a0,zero,.L757
	add	a3,a5,t3
.L758:
	sb	a2,0(a5)
	sb	a4,1(a5)
	addi	a5,a5,2
	bne	a5,a3,.L758
.L757:
	addi	a1,a1,1
	bne	a7,a1,.L759
	lw	a4,8(s4)
	sub	t4,t4,t1
	sw	a7,4(s4)
	sub	a4,a4,t1
	sw	a4,8(s4)
	sw	t4,12(s4)
	bge	a4,zero,.L756
	sw	s8,0(s4)
	addi	a6,a6,1
	bne	a6,s6,.L760
.L1001:
	slli	a4,t5,1
	add	a4,a5,a4
	beq	t5,zero,.L765
.L764:
	sb	zero,0(a5)
	addi	a5,a5,2
	bne	a5,a4,.L764
.L765:
	lw	s10,12(s4)
	ble	s10,s7,.L1002
	lw	s5,4(s4)
	j	.L766
.L726:
	li	a4,1
	ble	a1,a4,.L784
	lbu	a4,3(a5)
	lbu	a2,2(a5)
	slli	a4,a4,8
	or	a4,a4,a2
	slli	a2,a4,8
	srli	a4,a4,8
	or	a4,a2,a4
	slli	a4,a4,16
	srli	a4,a4,16
	sw	a4,12(s4)
	blt	a1,a4,.L784
	lw	a0,0(s4)
	addi	a6,a5,4
	addi	a2,a3,-4
	addi	a1,a4,-2
	sw	a6,4(s4)
	sw	a2,8(s4)
	sw	a1,12(s4)
	bne	a0,zero,.L718
	li	a2,8
	ble	a1,a2,.L784
	lbu	a1,4(a5)
	bne	a1,a2,.L994
	lbu	a2,6(a5)
	lbu	a1,5(a5)
	slli	a2,a2,8
	or	a2,a2,a1
	slli	s7,a2,8
	srli	a2,a2,8
	or	s7,s7,a2
	slli	s7,s7,16
	srli	s7,s7,16
	sw	s7,20(s4)
	lbu	a2,8(a5)
	lbu	a1,7(a5)
	slli	a2,a2,8
	or	a2,a2,a1
	slli	s8,a2,8
	srli	a2,a2,8
	or	s8,s8,a2
	slli	s8,s8,16
	srli	s8,s8,16
	sw	s8,16(s4)
	beq	s8,zero,.L784
	beq	s7,zero,.L784
	lbu	s6,9(a5)
	addi	s5,a5,10
	addi	a3,a3,-10
	addi	a4,a4,-8
	sw	s6,40(s4)
	sw	s5,4(s4)
	sw	a3,8(s4)
	sw	a4,12(s4)
	bge	a3,zero,.L736
	li	a5,5
	sw	a5,0(s4)
.L736:
	andi	a5,s6,253
	li	a3,1
	bne	a5,a3,.L994
	slli	a5,s6,1
	add	a5,a5,s6
	bgt	a5,a4,.L784
	li	a6,0
	li	a2,0
	li	a1,0
	addi	a3,s3,%lo(nj+44)
	li	t4,5
	li	t3,1
.L742:
	lbu	a5,0(s5)
	sw	a5,0(a3)
	lbu	a4,1(s5)
	srli	a4,a4,4
	sw	a4,4(a3)
	beq	a4,zero,.L784
	addi	a5,a4,-1
	and	a5,a5,a4
	bne	a5,zero,.L994
	lbu	a5,1(s5)
	andi	a5,a5,15
	sw	a5,8(a3)
	beq	a5,zero,.L784
	addi	t1,a5,-1
	and	t1,t1,a5
	bne	t1,zero,.L994
	lbu	a0,2(s5)
	sw	a0,24(a3)
	andi	a7,a0,252
	bne	a7,zero,.L784
	lw	s9,8(s4)
	lw	s10,12(s4)
	addi	s5,s5,3
	addi	a7,s9,-3
	addi	s11,s10,-3
	sw	s5,4(s4)
	sw	a7,8(s4)
	sw	s11,12(s4)
	bge	a7,zero,.L739
	sw	t4,0(s4)
.L739:
	lw	a7,176(s4)
	sll	a0,t3,a0
	or	a0,a7,a0
	sw	a0,176(s4)
	bge	a1,a4,.L740
	mv	a1,a4
.L740:
	bge	a2,a5,.L741
	mv	a2,a5
.L741:
	addi	a6,a6,1
	addi	a3,a3,44
	bgt	s6,a6,.L742
	li	a5,1
	bne	s6,a5,.L743
	sw	s6,52(s4)
	sw	s6,48(s4)
	li	a2,1
	li	a1,1
.L743:
	slli	a5,a1,3
	slli	a4,a2,3
	add	a7,s8,a5
	add	a6,s7,a4
	addi	a7,a7,-1
	addi	a6,a6,-1
	div	a7,a7,a5
	sw	a5,32(s4)
	lui	a5,%hi(nj+44)
	sw	a4,36(s4)
	addi	a5,a5,%lo(nj+44)
	li	t3,2
	div	a6,a6,a4
	sw	a7,24(s4)
	sw	a6,28(s4)
.L748:
	lw	t4,4(a5)
	lw	a0,8(a5)
	mul	t5,s8,t4
	mul	a3,s7,a0
	add	t5,t5,a1
	addi	t5,t5,-1
	add	a3,a3,a2
	addi	a3,a3,-1
	div	t5,t5,a1
	div	a3,a3,a2
	sw	t5,12(a5)
	mul	a4,a7,t4
	sw	a3,16(a5)
	slli	a4,a4,3
	sw	a4,20(a5)
	bgt	t5,t3,.L744
	bne	a1,t4,.L994
.L744:
	bgt	a3,t3,.L745
	bne	a2,a0,.L994
.L745:
	mul	a4,a6,a4
	sw	a5,20(sp)
	sw	t1,16(sp)
	sw	a7,12(sp)
	sw	a2,8(sp)
	sw	a1,4(sp)
	sw	a6,0(sp)
	mul	a0,a4,a0
	slli	a0,a0,3
	call	malloc
	lw	a5,20(sp)
	lw	a6,0(sp)
	lw	a1,4(sp)
	sw	a0,40(a5)
	lw	a2,8(sp)
	lw	a7,12(sp)
	lw	t1,16(sp)
	li	t3,2
	beq	a0,zero,.L832
	addi	t1,t1,1
	addi	a5,a5,44
	bgt	s6,t1,.L748
	li	a5,3
	beq	s6,a5,.L1003
.L749:
	add	a5,s5,s11
	sub	s9,s9,s10
	sw	a5,4(s4)
	sw	s9,8(s4)
	sw	zero,12(s4)
	bge	s9,zero,.L751
	j	.L784
.L887:
	li	a0,2
	j	.L715
.L1000:
	lw	a2,8(s4)
	addi	a5,a3,1
	addi	a1,a1,-1
	addi	a2,a2,-1
	sw	a5,4(s4)
	sw	a2,8(s4)
	sw	a1,12(s4)
	blt	a2,zero,.L1004
.L773:
	beq	a4,zero,.L774
	slli	a4,a4,1
	addi	a4,a4,1
	add	a1,a3,a4
	lui	a4,%hi(nj+44)
	addi	a4,a4,%lo(nj+44)
	li	a0,5
	j	.L776
.L1005:
	lbu	a3,1(a5)
	andi	a2,a3,238
	bne	a2,zero,.L784
	srli	a3,a3,4
	sw	a3,32(a4)
	lbu	a3,1(a5)
	addi	a5,a5,2
	andi	a3,a3,1
	ori	a3,a3,2
	sw	a3,28(a4)
	lw	a3,8(s4)
	lw	a2,12(s4)
	sw	a5,4(s4)
	addi	a3,a3,-2
	addi	a2,a2,-2
	sw	a3,8(s4)
	sw	a2,12(s4)
	bge	a3,zero,.L775
	sw	a0,0(s4)
.L775:
	addi	a4,a4,44
	beq	a5,a1,.L774
.L776:
	lbu	a2,0(a5)
	lw	a3,0(a4)
	beq	a2,a3,.L1005
	j	.L784
.L1004:
	li	a2,5
	sw	a2,0(s4)
	j	.L773
.L774:
	lbu	a4,0(a5)
	bne	a4,zero,.L994
	lbu	a3,1(a5)
	li	a4,63
	bne	a3,a4,.L994
	lbu	a4,2(a5)
	bne	a4,zero,.L994
	lw	a3,12(s4)
	lw	a4,8(s4)
	sw	zero,12(s4)
	add	a5,a5,a3
	sub	a4,a4,a3
	sw	a5,4(s4)
	sw	a4,8(s4)
	bge	a4,zero,.L777
	li	a5,5
	sw	a5,0(s4)
.L777:
	lui	a5,%hi(.LANCHOR157)
	li	s10,0
	addi	a5,a5,%lo(.LANCHOR157)
	mv	s2,s10
	sw	zero,12(sp)
	li	s6,0
	sw	a5,20(sp)
	mv	s10,s5
.L778:
	lw	a5,40(s4)
	ble	a5,zero,.L780
	li	a5,524288
	lui	a4,%hi(nj+44)
	addi	a5,a5,480
	addi	s5,a4,%lo(nj+44)
	add	a5,s4,a5
	sw	zero,8(sp)
	sw	a5,44(sp)
	mv	s7,s10
	sw	s2,24(sp)
	mv	s8,s5
	sw	s6,28(sp)
.L779:
	lw	s9,8(s8)
	ble	s9,zero,.L803
	lw	s10,4(s8)
	mv	s5,s7
	sw	zero,0(sp)
	mv	s6,s8
	mv	s7,s9
.L805:
	ble	s10,zero,.L804
	li	a5,131072
	addi	a5,a5,112
	li	s8,0
	sw	a5,16(sp)
.L802:
	lui	a5,%hi(nj+524736)
	addi	a0,a5,%lo(nj+524736)
	lw	a5,40(s6)
	li	a2,256
	li	a1,0
	sw	a5,32(sp)
	lw	a5,20(s6)
	sb	zero,63(sp)
	li	s2,0
	sw	a5,36(sp)
	call	memset
	lw	a0,32(s6)
	li	a1,0
	li	s1,240
	slli	a0,a0,17
	addi	a0,a0,440
	add	a0,s4,a0
	call	njGetVLC
	lw	a4,36(s6)
	lw	a5,24(s6)
	li	s0,63
	add	a4,a0,a4
	slli	a5,a5,6
	sw	a4,36(s6)
	add	a5,s4,a5
	lbu	a5,184(a5)
	mul	a5,a5,a4
	sw	a5,448(s3)
	j	.L785
.L781:
	andi	a4,a5,15
	bne	a4,zero,.L783
	bne	a5,s1,.L784
.L783:
	srli	a5,a5,4
	addi	a5,a5,1
	add	s2,s2,a5
	bgt	s2,s0,.L784
	lw	a4,24(s6)
	lw	a5,20(sp)
	lw	a3,16(sp)
	slli	a4,a4,6
	add	a4,s4,a4
	add	a4,a4,s2
	lbu	a4,184(a4)
	add	a5,a5,s2
	lbu	a5,0(a5)
	mul	a4,a4,a0
	add	a5,a5,a3
	slli	a5,a5,2
	add	a5,s4,a5
	sw	a4,0(a5)
	beq	s2,s0,.L786
.L785:
	lw	a0,28(s6)
	addi	a1,sp,63
	slli	a0,a0,17
	addi	a0,a0,440
	add	a0,s4,a0
	call	njGetVLC
	lbu	a5,63(sp)
	bne	a5,zero,.L781
.L786:
	li	a4,-4096
	lui	a5,%hi(nj+524736)
	li	t6,4096
	addi	a2,a5,%lo(nj+524736)
	addi	s1,a4,690
	addi	a4,a4,312
	addi	s2,t6,-1820
	addi	s11,a2,256
	addi	a5,a5,%lo(nj+524736)
	li	s9,565
	addi	t6,t6,-1688
	sw	a4,40(sp)
	li	t2,181
	j	.L782
.L787:
	add	a4,a1,a6
	mul	a4,a4,s9
	slli	t3,t3,11
	addi	t3,t3,128
	add	t4,t0,t3
	sub	t3,t3,t0
	add	s0,t1,a0
	add	t5,a3,a7
	mul	a1,a1,s2
	mul	t0,a6,s1
	add	a6,a4,a1
	li	a1,-799
	mul	t1,t1,a1
	li	a1,-4096
	addi	a1,a1,79
	add	a4,a4,t0
	mul	s0,s0,t6
	mul	a0,a0,a1
	add	t1,s0,t1
	sub	a1,a6,t1
	add	a6,a6,t1
	add	t1,s0,a0
	sub	t0,a4,t1
	add	t1,a4,t1
	lw	a4,40(sp)
	li	s0,1108
	mul	t5,t5,s0
	add	a0,a1,t0
	sub	a1,a1,t0
	mul	a4,a3,a4
	li	a3,1568
	mul	a7,a7,a3
	add	a4,t5,a4
	add	a3,t3,a4
	sub	a4,t3,a4
	mul	a0,a0,t2
	add	t5,t5,a7
	add	a7,t4,t5
	sub	t4,t4,t5
	add	t5,a6,a7
	add	t3,t1,t4
	sub	t4,t4,t1
	srai	t1,t5,8
	sub	a7,a7,a6
	sw	t1,0(a5)
	mul	a1,a1,t2
	addi	a0,a0,128
	srai	a0,a0,8
	srai	a6,t3,8
	add	t3,a3,a0
	sub	a3,a3,a0
	srai	t4,t4,8
	srai	a0,t3,8
	srai	a3,a3,8
	srai	a7,a7,8
	addi	a1,a1,128
	srai	a1,a1,8
	add	t1,a4,a1
	sub	a4,a4,a1
	srai	a4,a4,8
	srai	a1,t1,8
	sw	a0,4(a5)
	sw	a1,8(a5)
	sw	a6,12(a5)
	sw	t4,16(a5)
	sw	a4,20(a5)
	sw	a3,24(a5)
	sw	a7,28(a5)
.L788:
	addi	a5,a5,32
	beq	s11,a5,.L1006
.L782:
	lw	a3,24(a5)
	lw	a7,8(a5)
	lw	a1,4(a5)
	lw	a6,28(a5)
	lw	t1,20(a5)
	or	a4,a3,a7
	lw	t0,16(a5)
	lw	a0,12(a5)
	or	a4,a4,a1
	or	a4,a4,a6
	or	a4,a4,t1
	slli	t0,t0,11
	or	a4,a4,a0
	or	a4,a4,t0
	lw	t3,0(a5)
	bne	a4,zero,.L787
	slli	a4,t3,3
	sw	a4,28(a5)
	sw	a4,24(a5)
	sw	a4,20(a5)
	sw	a4,16(a5)
	sw	a4,12(a5)
	sw	a4,8(a5)
	sw	a4,4(a5)
	sw	a4,0(a5)
	j	.L788
.L754:
	beq	s10,zero,.L810
	j	.L784
.L1006:
	lw	a5,24(sp)
	li	t6,4096
	addi	a4,t6,-1688
	mul	a1,a5,s7
	sw	a4,40(sp)
	lw	a4,0(sp)
	li	a5,-4096
	addi	s0,a5,690
	addi	a5,a5,312
	li	s9,8192
	li	s2,565
	addi	s1,t6,-1820
	li	t2,181
	add	a1,a1,a4
	lw	a4,36(sp)
	sw	a5,36(sp)
	lw	a5,28(sp)
	mul	a1,a1,a4
	li	t4,255
	mul	s10,a5,s10
	lw	a5,32(sp)
	add	a1,a1,s10
	add	a1,a1,s8
	slli	a1,a1,3
	add	a1,a5,a1
.L801:
	lw	a5,192(a2)
	lw	a4,64(a2)
	lw	t3,32(a2)
	lw	t1,224(a2)
	lw	a0,160(a2)
	or	t5,a5,a4
	lw	s10,128(a2)
	lw	a6,96(a2)
	or	t5,t5,t3
	or	t5,t5,t1
	or	t5,t5,a0
	slli	s10,s10,8
	or	t5,t5,a6
	or	t5,t5,s10
	lw	a7,20(s6)
	lw	a3,0(a2)
	mv	t0,a1
	beq	t5,zero,.L1007
	lw	t6,40(sp)
	add	t0,a0,a6
	add	s7,t3,t1
	mul	t0,t0,t6
	li	t6,-799
	add	t5,a5,a4
	slli	a3,a3,8
	add	a3,a3,s9
	add	s11,s10,a3
	sub	a3,a3,s10
	li	s10,0
	mul	a0,a0,t6
	li	t6,-4096
	addi	t6,t6,79
	addi	t0,t0,4
	mul	s7,s7,s2
	add	a0,a0,t0
	srai	a0,a0,3
	mul	t3,t3,s1
	addi	s7,s7,4
	mul	t1,t1,s0
	add	t3,t3,s7
	srai	t3,t3,3
	mul	a6,a6,t6
	add	t1,t1,s7
	srai	t1,t1,3
	sub	s7,t3,a0
	add	a0,t3,a0
	li	t3,1108
	add	a6,a6,t0
	srai	t0,a6,3
	sub	a6,t1,t0
	mul	t5,t5,t3
	add	t0,t1,t0
	li	t1,1568
	add	t3,s7,a6
	sub	a6,s7,a6
	mul	a4,a4,t1
	lw	t1,36(sp)
	addi	t5,t5,4
	mul	a5,a5,t1
	add	a4,a4,t5
	srai	a4,a4,3
	add	t1,s11,a4
	add	s7,a0,t1
	srai	s7,s7,14
	addi	s7,s7,128
	sub	a4,s11,a4
	mul	t3,t3,t2
	add	a5,a5,t5
	srai	a5,a5,3
	add	t5,a3,a5
	sub	a3,a3,a5
	mul	a6,a6,t2
	addi	t3,t3,128
	srai	t3,t3,8
	addi	a6,a6,128
	srai	a6,a6,8
	blt	s7,zero,.L793
	mv	s10,s5
	bgt	s7,t4,.L793
	andi	s10,s7,0xff
.L793:
	add	a5,t5,t3
	srai	a5,a5,14
	sb	s10,0(a1)
	addi	s10,a5,128
	li	s7,0
	add	a5,a1,a7
	blt	s10,zero,.L794
	mv	s7,s5
	bgt	s10,t4,.L794
	andi	s7,s10,0xff
.L794:
	add	s10,a3,a6
	srai	s10,s10,14
	sb	s7,0(a5)
	addi	s10,s10,128
	add	a5,a5,a7
	li	s7,0
	blt	s10,zero,.L795
	mv	s7,s5
	bgt	s10,t4,.L795
	andi	s7,s10,0xff
.L795:
	add	s10,t0,a4
	srai	s10,s10,14
	sb	s7,0(a5)
	addi	s10,s10,128
	add	a5,a5,a7
	li	s7,0
	blt	s10,zero,.L796
	mv	s7,s5
	bgt	s10,t4,.L796
	andi	s7,s10,0xff
.L796:
	sub	a4,a4,t0
	srai	a4,a4,14
	sb	s7,0(a5)
	addi	a4,a4,128
	add	a5,a5,a7
	li	t0,0
	blt	a4,zero,.L797
	mv	t0,s5
	bgt	a4,t4,.L797
	andi	t0,a4,0xff
.L797:
	sub	a4,a3,a6
	srai	a4,a4,14
	sb	t0,0(a5)
	addi	a4,a4,128
	add	a5,a5,a7
	li	a3,0
	blt	a4,zero,.L798
	mv	a3,s5
	bgt	a4,t4,.L798
	andi	a3,a4,0xff
.L798:
	sub	a4,t5,t3
	srai	a4,a4,14
	sb	a3,0(a5)
	addi	a4,a4,128
	add	a5,a5,a7
	li	a3,0
	blt	a4,zero,.L799
	mv	a3,s5
	bgt	a4,t4,.L799
	andi	a3,a4,0xff
.L799:
	sub	a4,t1,a0
	srai	a4,a4,14
	sb	a3,0(a5)
	addi	a4,a4,128
	add	a5,a5,a7
	li	a3,0
	blt	a4,zero,.L800
	mv	a3,s5
	bgt	a4,t4,.L800
	andi	a3,a4,0xff
.L800:
	sb	a3,0(a5)
.L792:
	lw	a5,44(sp)
	addi	a2,a2,4
	addi	a1,a1,1
	bne	a5,a2,.L801
	lw	a0,0(s4)
	bne	a0,zero,.L718
	lw	s10,4(s6)
	addi	s8,s8,1
	lw	s7,8(s6)
	bgt	s10,s8,.L802
.L804:
	lw	a5,0(sp)
	addi	a5,a5,1
	sw	a5,0(sp)
	blt	a5,s7,.L805
	mv	s7,s5
	mv	s8,s6
.L803:
	lw	a4,8(sp)
	lw	a5,40(s4)
	addi	s8,s8,44
	addi	a4,a4,1
	sw	a4,8(sp)
	blt	a4,a5,.L779
	lw	s2,24(sp)
	lw	s6,28(sp)
	mv	s10,s7
.L780:
	lw	a5,24(s4)
	addi	s6,s6,1
	blt	s6,a5,.L806
	lw	a5,28(s4)
	addi	s2,s2,1
	bge	s2,a5,.L807
	li	s6,0
.L806:
	lw	a5,704(s3)
	beq	a5,zero,.L778
	lw	a5,4(sp)
	addi	a5,a5,-1
	sw	a5,4(sp)
	bne	a5,zero,.L778
	lw	a5,444(s3)
	li	a0,16
	andi	a5,a5,248
	sw	a5,444(s3)
	call	njShowBits.part.0
	lw	a4,444(s3)
	li	a5,15
	mv	s0,a0
	bgt	a4,a5,.L809
	li	a0,16
	call	njShowBits.part.0
.L809:
	lw	a3,444(s3)
	li	a5,65536
	addi	a4,a5,-8
	addi	a3,a3,-16
	sw	a3,444(s3)
	and	a4,s0,a4
	addi	a5,a5,-48
	bne	a4,a5,.L784
	lw	a5,12(sp)
	andi	s0,s0,7
	bne	s0,a5,.L784
	lw	a4,704(s3)
	addi	a5,a5,1
	andi	a5,a5,7
	sw	a4,4(sp)
	sw	a5,12(sp)
	sw	zero,80(s4)
	sw	zero,124(s4)
	sw	zero,168(s4)
	j	.L778
.L1007:
	addi	a5,a3,32
	srai	a5,a5,6
	addi	a5,a5,128
	li	a4,0
	blt	a5,zero,.L790
	mv	a4,s5
	bgt	a5,t4,.L790
	andi	a4,a5,0xff
.L790:
	li	a5,8
.L791:
	sb	a4,0(t0)
	addi	a5,a5,-1
	add	t0,t0,a7
	bne	a5,zero,.L791
	j	.L792
.L718:
	li	a5,6
	bne	a0,a5,.L715
.L807:
	lw	a5,40(s4)
	sw	zero,0(s4)
	ble	a5,zero,.L811
	lw	a4,16(s4)
	lui	a5,%hi(nj+44)
	sw	zero,24(sp)
	addi	s7,a5,%lo(nj+44)
	li	s10,255
.L812:
	lw	s9,12(s7)
	lw	s5,16(s7)
	li	s8,109
	bge	s9,a4,.L1008
.L847:
	mul	a0,s9,s5
	slli	a0,a0,1
	call	malloc
	mv	s0,a0
	beq	a0,zero,.L832
	lw	a0,40(s7)
	slli	t5,s9,1
	beq	s5,zero,.L830
	lw	t4,20(s7)
	add	a1,a0,s9
	addi	a1,a1,-3
	mv	a6,s0
	mv	a2,a0
	li	t3,139
	li	t1,-11
	li	a7,104
	li	t6,3
.L829:
	lbu	a5,0(a2)
	lbu	a4,1(a2)
	li	a3,0
	mul	a5,a5,t3
	mul	a4,a4,t1
	add	a5,a5,a4
	addi	a5,a5,64
	srai	a4,a5,7
	blt	a5,zero,.L817
	li	a3,255
	bgt	a4,s10,.L817
	andi	a3,a4,0xff
.L817:
	sb	a3,0(a6)
	lbu	a5,0(a2)
	lbu	t0,1(a2)
	lbu	a3,2(a2)
	mul	a5,a5,a7
	slli	a4,t0,3
	sub	a4,a4,t0
	slli	a4,a4,2
	sub	a4,a4,t0
	slli	t0,a3,2
	sub	a3,a3,t0
	li	t0,0
	add	a5,a5,a4
	add	a5,a5,a3
	addi	a5,a5,64
	srai	a4,a5,7
	blt	a5,zero,.L818
	li	t0,255
	bgt	a4,s10,.L818
	andi	t0,a4,0xff
.L818:
	sb	t0,1(a6)
	lbu	a3,1(a2)
	lbu	a4,0(a2)
	lbu	t0,2(a2)
	mul	a3,a3,s8
	slli	a5,a4,3
	sub	a5,a5,a4
	slli	a5,a5,2
	slli	a4,t0,3
	add	a4,a4,t0
	li	t0,0
	add	a5,a5,a3
	sub	a5,a5,a4
	addi	a5,a5,64
	srai	a4,a5,7
	blt	a5,zero,.L819
	li	t0,255
	bgt	a4,s10,.L819
	andi	t0,a4,0xff
.L819:
	sb	t0,2(a6)
	mv	a4,a2
	addi	a3,a6,3
	ble	s9,t6,.L826
.L825:
	lbu	s2,1(a4)
	lbu	ra,2(a4)
	lbu	s3,0(a4)
	slli	a5,s2,3
	lbu	t2,3(a4)
	slli	t0,ra,3
	sub	a5,a5,s2
	sub	t0,t0,ra
	slli	s1,s3,3
	slli	a5,a5,4
	add	s1,s1,s3
	sub	a5,a5,s2
	slli	t0,t0,2
	add	t0,t0,ra
	sub	a5,a5,s1
	slli	ra,t2,2
	add	a5,a5,t0
	sub	t2,t2,ra
	add	a5,a5,t2
	addi	a5,a5,64
	srai	t2,a5,7
	li	t0,0
	blt	a5,zero,.L823
	li	t0,255
	bgt	t2,s10,.L823
	andi	t0,t2,0xff
.L823:
	sb	t0,0(a3)
	lbu	s2,1(a4)
	lbu	s1,2(a4)
	lbu	a5,0(a4)
	slli	ra,s2,3
	lbu	t2,3(a4)
	sub	ra,ra,s2
	slli	t0,s1,3
	slli	s3,a5,2
	slli	ra,ra,2
	sub	t0,t0,s1
	add	ra,ra,s2
	sub	a5,a5,s3
	slli	t0,t0,4
	add	a5,a5,ra
	sub	t0,t0,s1
	slli	ra,t2,3
	add	a5,a5,t0
	add	t0,ra,t2
	sub	a5,a5,t0
	addi	a5,a5,64
	srai	t2,a5,7
	li	t0,0
	blt	a5,zero,.L824
	li	t0,255
	bgt	t2,s10,.L824
	andi	t0,t2,0xff
.L824:
	sb	t0,1(a3)
	addi	a4,a4,1
	addi	a3,a3,2
	bne	a1,a4,.L825
.L826:
	add	a2,a2,t4
	lbu	a3,-2(a2)
	lbu	a4,-1(a2)
	lbu	t0,-3(a2)
	mul	a3,a3,s8
	slli	a5,a4,3
	sub	a5,a5,a4
	slli	a5,a5,2
	slli	a4,t0,3
	add	a4,a4,t0
	add	a6,a6,t5
	add	a5,a5,a3
	sub	a5,a5,a4
	addi	a5,a5,64
	srai	a4,a5,7
	blt	a5,zero,.L1009
	li	a5,255
	bgt	a4,s10,.L822
	andi	a5,a4,0xff
.L822:
	sb	a5,-3(a6)
	lbu	a5,-1(a2)
	lbu	t0,-2(a2)
	lbu	a3,-3(a2)
	mul	a5,a5,a7
	slli	a4,t0,3
	sub	a4,a4,t0
	slli	a4,a4,2
	sub	a4,a4,t0
	slli	t0,a3,2
	sub	a3,a3,t0
	li	t0,0
	add	a5,a5,a4
	add	a5,a5,a3
	addi	a5,a5,64
	srai	a4,a5,7
	blt	a5,zero,.L827
	li	t0,255
	bgt	a4,s10,.L827
	andi	t0,a4,0xff
.L827:
	sb	t0,-2(a6)
	lbu	a5,-1(a2)
	lbu	a4,-2(a2)
	li	a3,0
	mul	a5,a5,t3
	mul	a4,a4,t1
	add	a5,a5,a4
	addi	a5,a5,64
	srai	a4,a5,7
	blt	a5,zero,.L828
	li	a3,255
	bgt	a4,s10,.L828
	andi	a3,a4,0xff
.L828:
	sb	a3,-1(a6)
	addi	s5,s5,-1
	add	a1,a1,t4
	bne	s5,zero,.L829
.L830:
	sw	t5,12(s7)
	sw	t5,20(s7)
	call	free
	lw	a0,0(s4)
	sw	s0,40(s7)
	bne	a0,zero,.L715
	lw	s5,16(s7)
	lw	a5,20(s4)
	lw	s9,12(s7)
	blt	s5,a5,.L860
	lw	a4,16(s4)
.L1011:
	blt	s9,a4,.L847
.L1008:
	lw	a3,20(s4)
	ble	a3,s5,.L1010
	lw	a0,0(s4)
	bne	a0,zero,.L715
.L860:
	mul	a0,s5,s9
	lw	s0,20(s7)
	slli	a5,s0,1
	sw	a5,4(sp)
	slli	a0,a0,1
	call	malloc
	sw	a0,28(sp)
	beq	a0,zero,.L832
	lw	a5,40(s7)
	sw	a5,32(sp)
	ble	s9,zero,.L846
	addi	a4,s5,-4
	mul	a3,a4,s0
	lw	a4,32(sp)
	addi	a5,s5,-2
	addi	s3,s5,-3
	add	t6,a4,s0
	mv	t2,a4
	add	a4,a4,s9
	sw	a4,20(sp)
	slli	a4,s0,1
	lw	s2,28(sp)
	add	a4,a3,a4
	mul	a5,a5,s9
	sw	a4,8(sp)
	sw	a3,12(sp)
	add	s1,t6,s0
	add	ra,s2,s9
	slli	t0,s9,1
	li	s6,139
	mul	a4,s3,s0
	slli	a5,a5,1
	sw	a5,16(sp)
	sw	a4,0(sp)
.L845:
	lbu	a5,0(t2)
	lbu	a3,0(t6)
	li	a0,-11
	mul	a5,a5,s6
	mv	a2,t2
	mv	a1,t6
	li	a4,0
	mul	a3,a3,a0
	add	a5,a5,a3
	addi	a5,a5,64
	srai	a3,a5,7
	blt	a5,zero,.L835
	li	a4,255
	bgt	a3,s10,.L835
	andi	a4,a3,0xff
.L835:
	sb	a4,0(s2)
	lbu	a5,0(t2)
	li	a3,104
	lbu	a4,0(t6)
	mul	a5,a5,a3
	lbu	a0,0(s1)
	slli	a6,a4,3
	sub	a6,a6,a4
	slli	a6,a6,2
	sub	a6,a6,a4
	slli	a4,a0,2
	sub	a0,a0,a4
	li	a3,0
	mv	a4,s1
	add	a5,a5,a6
	add	a5,a5,a0
	addi	a5,a5,64
	srai	a0,a5,7
	blt	a5,zero,.L836
	li	a3,255
	bgt	a0,s10,.L836
	andi	a3,a0,0xff
.L836:
	sb	a3,0(ra)
	lbu	a6,0(t6)
	lbu	a0,0(t2)
	lbu	a3,0(s1)
	mul	a6,a6,s8
	slli	a5,a0,3
	sub	a5,a5,a0
	slli	a5,a5,2
	slli	a0,a3,3
	add	a0,a0,a3
	li	a3,0
	add	a5,a5,a6
	sub	a5,a5,a0
	addi	a5,a5,64
	srai	a0,a5,7
	blt	a5,zero,.L837
	li	a3,255
	bgt	a0,s10,.L837
	andi	a3,a0,0xff
.L837:
	add	a5,ra,s9
	sb	a3,0(a5)
	add	a3,t0,ra
	beq	s3,zero,.L838
	lw	a5,4(sp)
	mv	a6,t2
	mv	a0,t6
	add	a7,t6,a5
	mv	t4,s3
.L841:
	lbu	t5,0(a0)
	add	a1,a1,s0
	lbu	t1,0(a1)
	lbu	s11,0(a6)
	slli	a5,t5,3
	lbu	a2,0(a7)
	slli	a4,t1,3
	sub	a5,a5,t5
	sub	a4,a4,t1
	slli	t3,s11,3
	slli	a5,a5,4
	add	t3,t3,s11
	sub	a5,a5,t5
	slli	a4,a4,2
	add	a4,a4,t1
	sub	a5,a5,t3
	slli	t1,a2,2
	add	a5,a5,a4
	sub	a2,a2,t1
	add	a5,a5,a2
	addi	a5,a5,64
	srai	a2,a5,7
	li	a4,0
	blt	a5,zero,.L839
	li	a4,255
	bgt	a2,s10,.L839
	andi	a4,a2,0xff
.L839:
	sb	a4,0(a3)
	lbu	t5,0(a0)
	lbu	t3,0(a1)
	lbu	a5,0(a6)
	slli	t1,t5,3
	lbu	a2,0(a7)
	sub	t1,t1,t5
	slli	a4,t3,3
	slli	s11,a5,2
	slli	t1,t1,2
	sub	a4,a4,t3
	add	t1,t1,t5
	sub	a5,a5,s11
	slli	a4,a4,4
	add	a5,a5,t1
	sub	a4,a4,t3
	slli	t1,a2,3
	add	a5,a5,a4
	add	a4,t1,a2
	sub	a5,a5,a4
	addi	a5,a5,64
	srai	a2,a5,7
	li	a4,0
	blt	a5,zero,.L840
	li	a4,255
	bgt	a2,s10,.L840
	andi	a4,a2,0xff
.L840:
	add	a5,a3,s9
	sb	a4,0(a5)
	addi	t4,t4,-1
	add	a3,a3,t0
	add	a0,a0,s0
	add	a6,a6,s0
	add	a7,a7,s0
	bne	t4,zero,.L841
	lw	a5,0(sp)
	add	a1,a5,t6
	lw	a5,8(sp)
	add	a4,a5,t6
	lw	a5,16(sp)
	add	a3,a5,ra
	lw	a5,12(sp)
	add	a2,a5,t6
.L838:
	lbu	a6,0(a1)
	lbu	a0,0(a4)
	lbu	a7,0(a2)
	mul	a6,a6,s8
	slli	a5,a0,3
	sub	a5,a5,a0
	slli	a5,a5,2
	slli	a0,a7,3
	add	a0,a0,a7
	li	a7,0
	add	a5,a5,a6
	sub	a5,a5,a0
	addi	a5,a5,64
	srai	a0,a5,7
	blt	a5,zero,.L842
	li	a7,255
	bgt	a0,s10,.L842
	andi	a7,a0,0xff
.L842:
	sb	a7,0(a3)
	lbu	a5,0(a4)
	lbu	a0,0(a2)
	li	a2,104
	mul	a5,a5,a2
	lbu	a6,0(a1)
	add	a3,a3,s9
	slli	a2,a6,3
	sub	a2,a2,a6
	slli	a2,a2,2
	sub	a2,a2,a6
	slli	a6,a0,2
	sub	a0,a0,a6
	add	a5,a5,a2
	add	a5,a5,a0
	addi	a5,a5,64
	li	a6,0
	srai	a2,a5,7
	blt	a5,zero,.L843
	li	a6,255
	bgt	a2,s10,.L843
	andi	a6,a2,0xff
.L843:
	sb	a6,0(a3)
	lbu	a5,0(a4)
	lbu	a4,0(a1)
	li	a1,-11
	mul	a5,a5,s6
	add	a3,a3,s9
	li	a2,0
	mul	a4,a4,a1
	add	a5,a5,a4
	addi	a5,a5,64
	srai	a4,a5,7
	blt	a5,zero,.L844
	li	a2,255
	bgt	a4,s10,.L844
	andi	a2,a4,0xff
.L844:
	lw	a5,20(sp)
	sb	a2,0(a3)
	addi	t2,t2,1
	addi	t6,t6,1
	addi	s1,s1,1
	addi	ra,ra,1
	addi	s2,s2,1
	bne	a5,t2,.L845
.L846:
	lw	a0,32(sp)
	slli	s5,s5,1
	sw	s5,16(s7)
	sw	s9,20(s7)
	call	free
	lw	a5,28(sp)
	lw	a0,0(s4)
	sw	a5,40(s7)
	bne	a0,zero,.L715
	lw	s5,16(s7)
	lw	s9,12(s7)
	lw	a4,16(s4)
	j	.L1011
.L1009:
	li	a5,0
	j	.L822
.L811:
	lw	a2,56(s4)
	lw	s1,64(s4)
	beq	a2,s1,.L995
	lw	s0,60(s4)
	lw	a5,84(s4)
	addi	s0,s0,-1
	add	s1,a5,s1
	add	a5,a5,a2
	beq	s0,zero,.L859
.L858:
	mv	a1,s1
	mv	a0,a5
	call	memcpy
	lw	a4,64(s4)
	lw	a2,56(s4)
	addi	s0,s0,-1
	add	s1,s1,a4
	add	a5,a0,a2
	bne	s0,zero,.L858
.L859:
	lw	a5,56(s4)
	lw	a0,0(s4)
	sw	a5,64(s4)
	j	.L715
.L1010:
	lw	a2,24(sp)
	lw	a5,40(s4)
	addi	s7,s7,44
	addi	a2,a2,1
	sw	a2,24(sp)
	blt	a2,a5,.L812
	li	a4,3
	bne	a5,a4,.L811
	li	a5,524288
	add	a5,s4,a5
	lw	a0,708(a5)
	lw	a7,84(s4)
	lw	t1,128(s4)
	lw	t3,172(s4)
	beq	a3,zero,.L995
	li	t0,359
	li	a6,255
	li	t6,-88
	li	t5,-183
	li	t4,454
.L851:
	lw	a5,16(s4)
	li	a2,0
	ble	a5,zero,.L856
.L855:
	add	a5,t3,a2
	lbu	a1,0(a5)
	add	a5,a7,a2
	lbu	t2,0(a5)
	addi	a1,a1,-128
	mul	a5,a1,t0
	add	a4,t1,a2
	lbu	a4,0(a4)
	slli	t2,t2,8
	li	s0,0
	addi	a4,a4,-128
	add	a5,a5,t2
	addi	a5,a5,128
	srai	s1,a5,8
	blt	a5,zero,.L852
	li	s0,255
	bgt	s1,a6,.L852
	andi	s0,s1,0xff
.L852:
	mul	a5,a4,t6
	sb	s0,0(a0)
	li	s0,0
	mul	a1,a1,t5
	add	a5,a5,t2
	add	a5,a5,a1
	addi	a5,a5,128
	srai	a1,a5,8
	blt	a5,zero,.L853
	li	s0,255
	bgt	a1,a6,.L853
	andi	s0,a1,0xff
.L853:
	mul	a5,a4,t4
	sb	s0,1(a0)
	li	a4,0
	addi	a0,a0,3
	add	a5,a5,t2
	addi	a5,a5,128
	srai	a1,a5,8
	blt	a5,zero,.L854
	li	a4,255
	bgt	a1,a6,.L854
	andi	a4,a1,0xff
.L854:
	sb	a4,-1(a0)
	lw	a5,16(s4)
	addi	a2,a2,1
	blt	a2,a5,.L855
.L856:
	lw	a2,64(s4)
	lw	a4,108(s4)
	lw	a5,152(s4)
	addi	a3,a3,-1
	add	a7,a7,a2
	add	t1,t1,a4
	add	t3,t3,a5
	bne	a3,zero,.L851
.L995:
	lw	a0,0(s4)
	j	.L715
.L1002:
	beq	s10,zero,.L751
	j	.L784
.L1003:
	mul	a0,s7,s8
	mul	a0,a0,s6
	call	malloc
	sw	a0,708(s2)
	bne	a0,zero,.L749
.L832:
	li	a5,3
	sw	a5,0(s4)
	li	a0,3
	j	.L715
	.size	njDecode, .-njDecode
	.section	.text.njGetWidth,"ax",@progbits
	.align	1
	.globl	njGetWidth
	.type	njGetWidth, @function
njGetWidth:
	lui	a5,%hi(nj+16)
	lw	a0,%lo(nj+16)(a5)
	ret
	.size	njGetWidth, .-njGetWidth
	.section	.text.njGetHeight,"ax",@progbits
	.align	1
	.globl	njGetHeight
	.type	njGetHeight, @function
njGetHeight:
	lui	a5,%hi(nj+20)
	lw	a0,%lo(nj+20)(a5)
	ret
	.size	njGetHeight, .-njGetHeight
	.section	.text.njIsColor,"ax",@progbits
	.align	1
	.globl	njIsColor
	.type	njIsColor, @function
njIsColor:
	lui	a5,%hi(nj+40)
	lw	a0,%lo(nj+40)(a5)
	addi	a0,a0,-1
	snez	a0,a0
	ret
	.size	njIsColor, .-njIsColor
	.section	.text.njGetImage,"ax",@progbits
	.align	1
	.globl	njGetImage
	.type	njGetImage, @function
njGetImage:
	lui	a5,%hi(nj)
	addi	a5,a5,%lo(nj)
	lw	a3,40(a5)
	li	a4,1
	beq	a3,a4,.L1018
	li	a4,524288
	add	a5,a5,a4
	lw	a0,708(a5)
	ret
.L1018:
	lw	a0,84(a5)
	ret
	.size	njGetImage, .-njGetImage
	.section	.text.njGetImageSize,"ax",@progbits
	.align	1
	.globl	njGetImageSize
	.type	njGetImageSize, @function
njGetImageSize:
	lui	a5,%hi(nj)
	addi	a5,a5,%lo(nj)
	lw	a4,16(a5)
	lw	a3,20(a5)
	lw	a0,40(a5)
	mul	a4,a4,a3
	mul	a0,a4,a0
	ret
	.size	njGetImageSize, .-njGetImageSize
	.globl	_heap
	.globl	__curses_back
	.globl	__curses_fore
	.globl	__curses_y
	.globl	__curses_x
	.globl	__curses_scroll
	.globl	__curses_cursor
	.globl	__curses_foregroundcolours
	.globl	__curses_backgroundcolours
	.globl	MEMORYTOP
	.globl	DATASTARTSECTOR
	.globl	CLUSTERSIZE
	.globl	CLUSTERBUFFER
	.globl	FAT
	.globl	ROOTDIRECTORY
	.globl	PARTITION
	.globl	BOOTSECTOR
	.globl	MBR
	.globl	SMTPCL
	.globl	SMTPCH
	.globl	SMTSTATUS
	.globl	SYSTEMCLOCK
	.globl	SLEEPTIMER1
	.globl	SLEEPTIMER0
	.globl	TIMER1KHZ1
	.globl	TIMER1KHZ0
	.globl	TIMER1HZ1
	.globl	TIMER1HZ0
	.globl	ALT_RNG
	.globl	RNG
	.globl	AUDIO_R_ACTIVE
	.globl	AUDIO_L_ACTIVE
	.globl	AUDIO_START
	.globl	AUDIO_DURATION
	.globl	AUDIO_NOTE
	.globl	AUDIO_WAVEFORM
	.globl	TPU_COMMIT
	.globl	TPU_FOREGROUND
	.globl	TPU_BACKGROUND
	.globl	TPU_CHARACTER
	.globl	TPU_Y
	.globl	TPU_X
	.globl	UPPER_SPRITE_WRITER_BITMAP
	.globl	UPPER_SPRITE_WRITER_LINE
	.globl	UPPER_SPRITE_WRITER_NUMBER
	.globl	UPPER_SPRITE_LAYER_COLLISION_BASE
	.globl	UPPER_SPRITE_COLLISION_BASE
	.globl	UPPER_SPRITE_UPDATE
	.globl	UPPER_SPRITE_TILE
	.globl	UPPER_SPRITE_Y
	.globl	UPPER_SPRITE_X
	.globl	UPPER_SPRITE_COLOUR
	.globl	UPPER_SPRITE_DOUBLE
	.globl	UPPER_SPRITE_ACTIVE
	.globl	LOWER_SPRITE_WRITER_BITMAP
	.globl	LOWER_SPRITE_WRITER_LINE
	.globl	LOWER_SPRITE_WRITER_NUMBER
	.globl	LOWER_SPRITE_LAYER_COLLISION_BASE
	.globl	LOWER_SPRITE_COLLISION_BASE
	.globl	LOWER_SPRITE_UPDATE
	.globl	LOWER_SPRITE_TILE
	.globl	LOWER_SPRITE_Y
	.globl	LOWER_SPRITE_X
	.globl	LOWER_SPRITE_COLOUR
	.globl	LOWER_SPRITE_DOUBLE
	.globl	LOWER_SPRITE_ACTIVE
	.globl	FRAMEBUFFER_DRAW
	.globl	FRAMEBUFFER_DISPLAY
	.globl	BITMAP_SCROLLWRAP
	.globl	BITMAP_PIXEL_READ
	.globl	BITMAP_Y_READ
	.globl	BITMAP_X_READ
	.globl	PB_STOP
	.globl	PB_COLOUR8B
	.globl	PB_COLOUR8G
	.globl	PB_COLOUR8R
	.globl	PB_COLOUR7
	.globl	COLOURBLIT_WRITER_COLOUR
	.globl	COLOURBLIT_WRITER_PIXEL
	.globl	COLOURBLIT_WRITER_LINE
	.globl	COLOURBLIT_WRITER_TILE
	.globl	BLIT_CHWRITER_BITMAP
	.globl	BLIT_CHWRITER_LINE
	.globl	BLIT_CHWRITER_TILE
	.globl	BLIT_WRITER_BITMAP
	.globl	BLIT_WRITER_LINE
	.globl	BLIT_WRITER_TILE
	.globl	VECTOR_WRITER_ACTIVE
	.globl	VECTOR_WRITER_DELTAY
	.globl	VECTOR_WRITER_DELTAX
	.globl	VECTOR_WRITER_VERTEX
	.globl	VECTOR_WRITER_BLOCK
	.globl	VECTOR_DRAW_STATUS
	.globl	VECTOR_DRAW_START
	.globl	VECTOR_DRAW_SCALE
	.globl	VECTOR_DRAW_YC
	.globl	VECTOR_DRAW_XC
	.globl	VECTOR_DRAW_COLOUR
	.globl	VECTOR_DRAW_BLOCK
	.globl	GPU_FINISHED
	.globl	GPU_STATUS
	.globl	GPU_WRITE
	.globl	GPU_PARAM3
	.globl	GPU_PARAM2
	.globl	GPU_PARAM1
	.globl	GPU_PARAM0
	.globl	GPU_DITHERMODE
	.globl	GPU_COLOUR_ALT
	.globl	GPU_COLOUR
	.globl	GPU_Y
	.globl	GPU_X
	.globl	UPPER_TM_STATUS
	.globl	UPPER_TM_SCROLLWRAPCLEAR
	.globl	UPPER_TM_WRITER_BITMAP
	.globl	UPPER_TM_WRITER_LINE_NUMBER
	.globl	UPPER_TM_WRITER_TILE_NUMBER
	.globl	UPPER_TM_COMMIT
	.globl	UPPER_TM_FOREGROUND
	.globl	UPPER_TM_BACKGROUND
	.globl	UPPER_TM_TILE
	.globl	UPPER_TM_Y
	.globl	UPPER_TM_X
	.globl	LOWER_TM_STATUS
	.globl	LOWER_TM_SCROLLWRAPCLEAR
	.globl	LOWER_TM_WRITER_BITMAP
	.globl	LOWER_TM_WRITER_LINE_NUMBER
	.globl	LOWER_TM_WRITER_TILE_NUMBER
	.globl	LOWER_TM_COMMIT
	.globl	LOWER_TM_FOREGROUND
	.globl	LOWER_TM_BACKGROUND
	.globl	LOWER_TM_TILE
	.globl	LOWER_TM_Y
	.globl	LOWER_TM_X
	.globl	BACKGROUND_COPPER_COLOUR
	.globl	BACKGROUND_COPPER_ALT
	.globl	BACKGROUND_COPPER_MODE
	.globl	BACKGROUND_COPPER_COORDINATE
	.globl	BACKGROUND_COPPER_CONDITION
	.globl	BACKGROUND_COPPER_COMMAND
	.globl	BACKGROUND_COPPER_ADDRESS
	.globl	BACKGROUND_COPPER_STARTSTOP
	.globl	BACKGROUND_COPPER_PROGRAM
	.globl	BACKGROUND_MODE
	.globl	BACKGROUND_ALTCOLOUR
	.globl	BACKGROUND_COLOUR
	.globl	SCREENMODE
	.globl	VBLANK
	.globl	SDCARD_DATA
	.globl	SDCARD_ADDRESS
	.globl	SDCARD_SECTOR_HIGH
	.globl	SDCARD_SECTOR_LOW
	.globl	SDCARD_START
	.globl	SDCARD_READY
	.globl	PS2_DATA
	.globl	PS2_AVAILABLE
	.globl	LEDS
	.globl	BUTTONS
	.globl	UART_STATUS
	.globl	UART_DATA
	.section	.bss.__curses_backgroundcolours,"aw",@nobits
	.align	2
	.set	.LANCHOR150,. + 0
	.type	__curses_backgroundcolours, @object
	.size	__curses_backgroundcolours, 16
__curses_backgroundcolours:
	.zero	16
	.section	.bss.__curses_foregroundcolours,"aw",@nobits
	.align	2
	.set	.LANCHOR149,. + 0
	.type	__curses_foregroundcolours, @object
	.size	__curses_foregroundcolours, 16
__curses_foregroundcolours:
	.zero	16
	.section	.bss.counts.0,"aw",@nobits
	.align	2
	.set	.LANCHOR156,. + 0
	.type	counts.0, @object
	.size	counts.0, 16
counts.0:
	.zero	16
	.section	.bss.nj,"aw",@nobits
	.align	2
	.type	nj, @object
	.size	nj, 525000
nj:
	.zero	525000
	.section	.rodata.njZZ,"a"
	.align	2
	.set	.LANCHOR157,. + 0
	.type	njZZ, @object
	.size	njZZ, 64
njZZ:
	.string	""
	.ascii	"\001\b\020\t\002\003\n\021\030 \031\022\013\004\005\f\023\032"
	.ascii	"!(0)\"\033\024\r\006\007\016\025\034#*1892+$\035\026\017\027"
	.ascii	"\036%,3:;4-&\037'.5<=6/7>?"
	.section	.sbss.BOOTSECTOR,"aw",@nobits
	.align	2
	.set	.LANCHOR135,. + 0
	.type	BOOTSECTOR, @object
	.size	BOOTSECTOR, 4
BOOTSECTOR:
	.zero	4
	.section	.sbss.CLUSTERBUFFER,"aw",@nobits
	.align	2
	.set	.LANCHOR137,. + 0
	.type	CLUSTERBUFFER, @object
	.size	CLUSTERBUFFER, 4
CLUSTERBUFFER:
	.zero	4
	.section	.sbss.CLUSTERSIZE,"aw",@nobits
	.align	2
	.set	.LANCHOR153,. + 0
	.type	CLUSTERSIZE, @object
	.size	CLUSTERSIZE, 4
CLUSTERSIZE:
	.zero	4
	.section	.sbss.DATASTARTSECTOR,"aw",@nobits
	.align	2
	.set	.LANCHOR138,. + 0
	.type	DATASTARTSECTOR, @object
	.size	DATASTARTSECTOR, 4
DATASTARTSECTOR:
	.zero	4
	.section	.sbss.FAT,"aw",@nobits
	.align	2
	.set	.LANCHOR139,. + 0
	.type	FAT, @object
	.size	FAT, 4
FAT:
	.zero	4
	.section	.sbss.MBR,"aw",@nobits
	.align	2
	.set	.LANCHOR154,. + 0
	.type	MBR, @object
	.size	MBR, 4
MBR:
	.zero	4
	.section	.sbss.MEMORYTOP,"aw",@nobits
	.align	2
	.set	.LANCHOR152,. + 0
	.type	MEMORYTOP, @object
	.size	MEMORYTOP, 4
MEMORYTOP:
	.zero	4
	.section	.sbss.PARTITION,"aw",@nobits
	.align	2
	.set	.LANCHOR155,. + 0
	.type	PARTITION, @object
	.size	PARTITION, 4
PARTITION:
	.zero	4
	.section	.sbss.ROOTDIRECTORY,"aw",@nobits
	.align	2
	.set	.LANCHOR136,. + 0
	.type	ROOTDIRECTORY, @object
	.size	ROOTDIRECTORY, 4
ROOTDIRECTORY:
	.zero	4
	.section	.sbss.__curses_back,"aw",@nobits
	.align	1
	.set	.LANCHOR146,. + 0
	.type	__curses_back, @object
	.size	__curses_back, 2
__curses_back:
	.zero	2
	.section	.sbss.__curses_x,"aw",@nobits
	.align	1
	.set	.LANCHOR143,. + 0
	.type	__curses_x, @object
	.size	__curses_x, 2
__curses_x:
	.zero	2
	.section	.sbss.__curses_y,"aw",@nobits
	.align	1
	.set	.LANCHOR144,. + 0
	.type	__curses_y, @object
	.size	__curses_y, 2
__curses_y:
	.zero	2
	.section	.sbss._heap,"aw",@nobits
	.align	2
	.set	.LANCHOR151,. + 0
	.type	_heap, @object
	.size	_heap, 4
_heap:
	.zero	4
	.section	.sdata.ALT_RNG,"aw"
	.align	2
	.set	.LANCHOR4,. + 0
	.type	ALT_RNG, @object
	.size	ALT_RNG, 4
ALT_RNG:
	.word	57346
	.section	.sdata.AUDIO_DURATION,"aw"
	.align	2
	.set	.LANCHOR15,. + 0
	.type	AUDIO_DURATION, @object
	.size	AUDIO_DURATION, 4
AUDIO_DURATION:
	.word	57604
	.section	.sdata.AUDIO_L_ACTIVE,"aw"
	.align	2
	.set	.LANCHOR17,. + 0
	.type	AUDIO_L_ACTIVE, @object
	.size	AUDIO_L_ACTIVE, 4
AUDIO_L_ACTIVE:
	.word	57616
	.section	.sdata.AUDIO_NOTE,"aw"
	.align	2
	.set	.LANCHOR14,. + 0
	.type	AUDIO_NOTE, @object
	.size	AUDIO_NOTE, 4
AUDIO_NOTE:
	.word	57602
	.section	.sdata.AUDIO_R_ACTIVE,"aw"
	.align	2
	.set	.LANCHOR18,. + 0
	.type	AUDIO_R_ACTIVE, @object
	.size	AUDIO_R_ACTIVE, 4
AUDIO_R_ACTIVE:
	.word	57618
	.section	.sdata.AUDIO_START,"aw"
	.align	2
	.set	.LANCHOR16,. + 0
	.type	AUDIO_START, @object
	.size	AUDIO_START, 4
AUDIO_START:
	.word	57606
	.section	.sdata.AUDIO_WAVEFORM,"aw"
	.align	2
	.set	.LANCHOR13,. + 0
	.type	AUDIO_WAVEFORM, @object
	.size	AUDIO_WAVEFORM, 4
AUDIO_WAVEFORM:
	.word	57600
	.section	.sdata.BACKGROUND_ALTCOLOUR,"aw"
	.align	2
	.set	.LANCHOR35,. + 0
	.type	BACKGROUND_ALTCOLOUR, @object
	.size	BACKGROUND_ALTCOLOUR, 4
BACKGROUND_ALTCOLOUR:
	.word	32770
	.section	.sdata.BACKGROUND_COLOUR,"aw"
	.align	2
	.set	.LANCHOR34,. + 0
	.type	BACKGROUND_COLOUR, @object
	.size	BACKGROUND_COLOUR, 4
BACKGROUND_COLOUR:
	.word	32768
	.section	.sdata.BACKGROUND_COPPER_ADDRESS,"aw"
	.align	2
	.set	.LANCHOR37,. + 0
	.type	BACKGROUND_COPPER_ADDRESS, @object
	.size	BACKGROUND_COPPER_ADDRESS, 4
BACKGROUND_COPPER_ADDRESS:
	.word	32800
	.section	.sdata.BACKGROUND_COPPER_ALT,"aw"
	.align	2
	.set	.LANCHOR42,. + 0
	.type	BACKGROUND_COPPER_ALT, @object
	.size	BACKGROUND_COPPER_ALT, 4
BACKGROUND_COPPER_ALT:
	.word	32810
	.section	.sdata.BACKGROUND_COPPER_COLOUR,"aw"
	.align	2
	.set	.LANCHOR43,. + 0
	.type	BACKGROUND_COPPER_COLOUR, @object
	.size	BACKGROUND_COPPER_COLOUR, 4
BACKGROUND_COPPER_COLOUR:
	.word	32812
	.section	.sdata.BACKGROUND_COPPER_COMMAND,"aw"
	.align	2
	.set	.LANCHOR38,. + 0
	.type	BACKGROUND_COPPER_COMMAND, @object
	.size	BACKGROUND_COPPER_COMMAND, 4
BACKGROUND_COPPER_COMMAND:
	.word	32802
	.section	.sdata.BACKGROUND_COPPER_CONDITION,"aw"
	.align	2
	.set	.LANCHOR39,. + 0
	.type	BACKGROUND_COPPER_CONDITION, @object
	.size	BACKGROUND_COPPER_CONDITION, 4
BACKGROUND_COPPER_CONDITION:
	.word	32804
	.section	.sdata.BACKGROUND_COPPER_COORDINATE,"aw"
	.align	2
	.set	.LANCHOR40,. + 0
	.type	BACKGROUND_COPPER_COORDINATE, @object
	.size	BACKGROUND_COPPER_COORDINATE, 4
BACKGROUND_COPPER_COORDINATE:
	.word	32806
	.section	.sdata.BACKGROUND_COPPER_MODE,"aw"
	.align	2
	.set	.LANCHOR41,. + 0
	.type	BACKGROUND_COPPER_MODE, @object
	.size	BACKGROUND_COPPER_MODE, 4
BACKGROUND_COPPER_MODE:
	.word	32808
	.section	.sdata.BACKGROUND_COPPER_PROGRAM,"aw"
	.align	2
	.set	.LANCHOR44,. + 0
	.type	BACKGROUND_COPPER_PROGRAM, @object
	.size	BACKGROUND_COPPER_PROGRAM, 4
BACKGROUND_COPPER_PROGRAM:
	.word	32784
	.section	.sdata.BACKGROUND_COPPER_STARTSTOP,"aw"
	.align	2
	.set	.LANCHOR33,. + 0
	.type	BACKGROUND_COPPER_STARTSTOP, @object
	.size	BACKGROUND_COPPER_STARTSTOP, 4
BACKGROUND_COPPER_STARTSTOP:
	.word	32786
	.section	.sdata.BACKGROUND_MODE,"aw"
	.align	2
	.set	.LANCHOR36,. + 0
	.type	BACKGROUND_MODE, @object
	.size	BACKGROUND_MODE, 4
BACKGROUND_MODE:
	.word	32772
	.section	.sdata.BITMAP_PIXEL_READ,"aw"
	.align	2
	.type	BITMAP_PIXEL_READ, @object
	.size	BITMAP_PIXEL_READ, 4
BITMAP_PIXEL_READ:
	.word	34516
	.section	.sdata.BITMAP_SCROLLWRAP,"aw"
	.align	2
	.set	.LANCHOR67,. + 0
	.type	BITMAP_SCROLLWRAP, @object
	.size	BITMAP_SCROLLWRAP, 4
BITMAP_SCROLLWRAP:
	.word	34528
	.section	.sdata.BITMAP_X_READ,"aw"
	.align	2
	.type	BITMAP_X_READ, @object
	.size	BITMAP_X_READ, 4
BITMAP_X_READ:
	.word	34512
	.section	.sdata.BITMAP_Y_READ,"aw"
	.align	2
	.type	BITMAP_Y_READ, @object
	.size	BITMAP_Y_READ, 4
BITMAP_Y_READ:
	.word	34514
	.section	.sdata.BLIT_CHWRITER_BITMAP,"aw"
	.align	2
	.set	.LANCHOR81,. + 0
	.type	BLIT_CHWRITER_BITMAP, @object
	.size	BLIT_CHWRITER_BITMAP, 4
BLIT_CHWRITER_BITMAP:
	.word	34388
	.section	.sdata.BLIT_CHWRITER_LINE,"aw"
	.align	2
	.set	.LANCHOR80,. + 0
	.type	BLIT_CHWRITER_LINE, @object
	.size	BLIT_CHWRITER_LINE, 4
BLIT_CHWRITER_LINE:
	.word	34386
	.section	.sdata.BLIT_CHWRITER_TILE,"aw"
	.align	2
	.set	.LANCHOR79,. + 0
	.type	BLIT_CHWRITER_TILE, @object
	.size	BLIT_CHWRITER_TILE, 4
BLIT_CHWRITER_TILE:
	.word	34384
	.section	.sdata.BLIT_WRITER_BITMAP,"aw"
	.align	2
	.set	.LANCHOR78,. + 0
	.type	BLIT_WRITER_BITMAP, @object
	.size	BLIT_WRITER_BITMAP, 4
BLIT_WRITER_BITMAP:
	.word	34372
	.section	.sdata.BLIT_WRITER_LINE,"aw"
	.align	2
	.set	.LANCHOR77,. + 0
	.type	BLIT_WRITER_LINE, @object
	.size	BLIT_WRITER_LINE, 4
BLIT_WRITER_LINE:
	.word	34370
	.section	.sdata.BLIT_WRITER_TILE,"aw"
	.align	2
	.set	.LANCHOR76,. + 0
	.type	BLIT_WRITER_TILE, @object
	.size	BLIT_WRITER_TILE, 4
BLIT_WRITER_TILE:
	.word	34368
	.section	.sdata.BUTTONS,"aw"
	.align	2
	.set	.LANCHOR26,. + 0
	.type	BUTTONS, @object
	.size	BUTTONS, 4
BUTTONS:
	.word	61728
	.section	.sdata.COLOURBLIT_WRITER_COLOUR,"aw"
	.align	2
	.set	.LANCHOR85,. + 0
	.type	COLOURBLIT_WRITER_COLOUR, @object
	.size	COLOURBLIT_WRITER_COLOUR, 4
COLOURBLIT_WRITER_COLOUR:
	.word	34406
	.section	.sdata.COLOURBLIT_WRITER_LINE,"aw"
	.align	2
	.set	.LANCHOR83,. + 0
	.type	COLOURBLIT_WRITER_LINE, @object
	.size	COLOURBLIT_WRITER_LINE, 4
COLOURBLIT_WRITER_LINE:
	.word	34402
	.section	.sdata.COLOURBLIT_WRITER_PIXEL,"aw"
	.align	2
	.set	.LANCHOR84,. + 0
	.type	COLOURBLIT_WRITER_PIXEL, @object
	.size	COLOURBLIT_WRITER_PIXEL, 4
COLOURBLIT_WRITER_PIXEL:
	.word	34404
	.section	.sdata.COLOURBLIT_WRITER_TILE,"aw"
	.align	2
	.set	.LANCHOR82,. + 0
	.type	COLOURBLIT_WRITER_TILE, @object
	.size	COLOURBLIT_WRITER_TILE, 4
COLOURBLIT_WRITER_TILE:
	.word	34400
	.section	.sdata.FRAMEBUFFER_DISPLAY,"aw"
	.align	2
	.set	.LANCHOR30,. + 0
	.type	FRAMEBUFFER_DISPLAY, @object
	.size	FRAMEBUFFER_DISPLAY, 4
FRAMEBUFFER_DISPLAY:
	.word	34544
	.section	.sdata.FRAMEBUFFER_DRAW,"aw"
	.align	2
	.set	.LANCHOR32,. + 0
	.type	FRAMEBUFFER_DRAW, @object
	.size	FRAMEBUFFER_DRAW, 4
FRAMEBUFFER_DRAW:
	.word	34546
	.section	.sdata.GPU_COLOUR,"aw"
	.align	2
	.set	.LANCHOR70,. + 0
	.type	GPU_COLOUR, @object
	.size	GPU_COLOUR, 4
GPU_COLOUR:
	.word	34308
	.section	.sdata.GPU_COLOUR_ALT,"aw"
	.align	2
	.set	.LANCHOR68,. + 0
	.type	GPU_COLOUR_ALT, @object
	.size	GPU_COLOUR_ALT, 4
GPU_COLOUR_ALT:
	.word	34310
	.section	.sdata.GPU_DITHERMODE,"aw"
	.align	2
	.set	.LANCHOR69,. + 0
	.type	GPU_DITHERMODE, @object
	.size	GPU_DITHERMODE, 4
GPU_DITHERMODE:
	.word	34312
	.section	.sdata.GPU_FINISHED,"aw"
	.align	2
	.set	.LANCHOR31,. + 0
	.type	GPU_FINISHED, @object
	.size	GPU_FINISHED, 4
GPU_FINISHED:
	.word	34324
	.section	.sdata.GPU_PARAM0,"aw"
	.align	2
	.set	.LANCHOR74,. + 0
	.type	GPU_PARAM0, @object
	.size	GPU_PARAM0, 4
GPU_PARAM0:
	.word	34314
	.section	.sdata.GPU_PARAM1,"aw"
	.align	2
	.set	.LANCHOR75,. + 0
	.type	GPU_PARAM1, @object
	.size	GPU_PARAM1, 4
GPU_PARAM1:
	.word	34316
	.section	.sdata.GPU_PARAM2,"aw"
	.align	2
	.set	.LANCHOR86,. + 0
	.type	GPU_PARAM2, @object
	.size	GPU_PARAM2, 4
GPU_PARAM2:
	.word	34318
	.section	.sdata.GPU_PARAM3,"aw"
	.align	2
	.set	.LANCHOR87,. + 0
	.type	GPU_PARAM3, @object
	.size	GPU_PARAM3, 4
GPU_PARAM3:
	.word	34320
	.section	.sdata.GPU_STATUS,"aw"
	.align	2
	.set	.LANCHOR27,. + 0
	.type	GPU_STATUS, @object
	.size	GPU_STATUS, 4
GPU_STATUS:
	.word	34322
	.section	.sdata.GPU_WRITE,"aw"
	.align	2
	.set	.LANCHOR73,. + 0
	.type	GPU_WRITE, @object
	.size	GPU_WRITE, 4
GPU_WRITE:
	.word	34322
	.section	.sdata.GPU_X,"aw"
	.align	2
	.set	.LANCHOR71,. + 0
	.type	GPU_X, @object
	.size	GPU_X, 4
GPU_X:
	.word	34304
	.section	.sdata.GPU_Y,"aw"
	.align	2
	.set	.LANCHOR72,. + 0
	.type	GPU_Y, @object
	.size	GPU_Y, 4
GPU_Y:
	.word	34306
	.section	.sdata.LEDS,"aw"
	.align	2
	.set	.LANCHOR25,. + 0
	.type	LEDS, @object
	.size	LEDS, 4
LEDS:
	.word	61744
	.section	.sdata.LOWER_SPRITE_ACTIVE,"aw"
	.align	2
	.set	.LANCHOR111,. + 0
	.type	LOWER_SPRITE_ACTIVE, @object
	.size	LOWER_SPRITE_ACTIVE, 4
LOWER_SPRITE_ACTIVE:
	.word	33536
	.section	.sdata.LOWER_SPRITE_COLLISION_BASE,"aw"
	.align	2
	.set	.LANCHOR123,. + 0
	.type	LOWER_SPRITE_COLLISION_BASE, @object
	.size	LOWER_SPRITE_COLLISION_BASE, 4
LOWER_SPRITE_COLLISION_BASE:
	.word	33728
	.section	.sdata.LOWER_SPRITE_COLOUR,"aw"
	.align	2
	.set	.LANCHOR113,. + 0
	.type	LOWER_SPRITE_COLOUR, @object
	.size	LOWER_SPRITE_COLOUR, 4
LOWER_SPRITE_COLOUR:
	.word	33600
	.section	.sdata.LOWER_SPRITE_DOUBLE,"aw"
	.align	2
	.set	.LANCHOR116,. + 0
	.type	LOWER_SPRITE_DOUBLE, @object
	.size	LOWER_SPRITE_DOUBLE, 4
LOWER_SPRITE_DOUBLE:
	.word	33568
	.section	.sdata.LOWER_SPRITE_LAYER_COLLISION_BASE,"aw"
	.align	2
	.set	.LANCHOR125,. + 0
	.type	LOWER_SPRITE_LAYER_COLLISION_BASE, @object
	.size	LOWER_SPRITE_LAYER_COLLISION_BASE, 4
LOWER_SPRITE_LAYER_COLLISION_BASE:
	.word	33760
	.section	.sdata.LOWER_SPRITE_TILE,"aw"
	.align	2
	.set	.LANCHOR112,. + 0
	.type	LOWER_SPRITE_TILE, @object
	.size	LOWER_SPRITE_TILE, 4
LOWER_SPRITE_TILE:
	.word	33696
	.section	.sdata.LOWER_SPRITE_UPDATE,"aw"
	.align	2
	.set	.LANCHOR127,. + 0
	.type	LOWER_SPRITE_UPDATE, @object
	.size	LOWER_SPRITE_UPDATE, 4
LOWER_SPRITE_UPDATE:
	.word	33728
	.section	.sdata.LOWER_SPRITE_WRITER_BITMAP,"aw"
	.align	2
	.set	.LANCHOR108,. + 0
	.type	LOWER_SPRITE_WRITER_BITMAP, @object
	.size	LOWER_SPRITE_WRITER_BITMAP, 4
LOWER_SPRITE_WRITER_BITMAP:
	.word	34820
	.section	.sdata.LOWER_SPRITE_WRITER_LINE,"aw"
	.align	2
	.set	.LANCHOR107,. + 0
	.type	LOWER_SPRITE_WRITER_LINE, @object
	.size	LOWER_SPRITE_WRITER_LINE, 4
LOWER_SPRITE_WRITER_LINE:
	.word	34818
	.section	.sdata.LOWER_SPRITE_WRITER_NUMBER,"aw"
	.align	2
	.set	.LANCHOR105,. + 0
	.type	LOWER_SPRITE_WRITER_NUMBER, @object
	.size	LOWER_SPRITE_WRITER_NUMBER, 4
LOWER_SPRITE_WRITER_NUMBER:
	.word	34816
	.section	.sdata.LOWER_SPRITE_X,"aw"
	.align	2
	.set	.LANCHOR114,. + 0
	.type	LOWER_SPRITE_X, @object
	.size	LOWER_SPRITE_X, 4
LOWER_SPRITE_X:
	.word	33632
	.section	.sdata.LOWER_SPRITE_Y,"aw"
	.align	2
	.set	.LANCHOR115,. + 0
	.type	LOWER_SPRITE_Y, @object
	.size	LOWER_SPRITE_Y, 4
LOWER_SPRITE_Y:
	.word	33664
	.section	.sdata.LOWER_TM_BACKGROUND,"aw"
	.align	2
	.set	.LANCHOR49,. + 0
	.type	LOWER_TM_BACKGROUND, @object
	.size	LOWER_TM_BACKGROUND, 4
LOWER_TM_BACKGROUND:
	.word	33030
	.section	.sdata.LOWER_TM_COMMIT,"aw"
	.align	2
	.set	.LANCHOR51,. + 0
	.type	LOWER_TM_COMMIT, @object
	.size	LOWER_TM_COMMIT, 4
LOWER_TM_COMMIT:
	.word	33034
	.section	.sdata.LOWER_TM_FOREGROUND,"aw"
	.align	2
	.set	.LANCHOR50,. + 0
	.type	LOWER_TM_FOREGROUND, @object
	.size	LOWER_TM_FOREGROUND, 4
LOWER_TM_FOREGROUND:
	.word	33032
	.section	.sdata.LOWER_TM_SCROLLWRAPCLEAR,"aw"
	.align	2
	.set	.LANCHOR65,. + 0
	.type	LOWER_TM_SCROLLWRAPCLEAR, @object
	.size	LOWER_TM_SCROLLWRAPCLEAR, 4
LOWER_TM_SCROLLWRAPCLEAR:
	.word	33056
	.section	.sdata.LOWER_TM_STATUS,"aw"
	.align	2
	.set	.LANCHOR45,. + 0
	.type	LOWER_TM_STATUS, @object
	.size	LOWER_TM_STATUS, 4
LOWER_TM_STATUS:
	.word	33058
	.section	.sdata.LOWER_TM_TILE,"aw"
	.align	2
	.set	.LANCHOR48,. + 0
	.type	LOWER_TM_TILE, @object
	.size	LOWER_TM_TILE, 4
LOWER_TM_TILE:
	.word	33028
	.section	.sdata.LOWER_TM_WRITER_BITMAP,"aw"
	.align	2
	.set	.LANCHOR61,. + 0
	.type	LOWER_TM_WRITER_BITMAP, @object
	.size	LOWER_TM_WRITER_BITMAP, 4
LOWER_TM_WRITER_BITMAP:
	.word	33044
	.section	.sdata.LOWER_TM_WRITER_LINE_NUMBER,"aw"
	.align	2
	.set	.LANCHOR60,. + 0
	.type	LOWER_TM_WRITER_LINE_NUMBER, @object
	.size	LOWER_TM_WRITER_LINE_NUMBER, 4
LOWER_TM_WRITER_LINE_NUMBER:
	.word	33042
	.section	.sdata.LOWER_TM_WRITER_TILE_NUMBER,"aw"
	.align	2
	.set	.LANCHOR59,. + 0
	.type	LOWER_TM_WRITER_TILE_NUMBER, @object
	.size	LOWER_TM_WRITER_TILE_NUMBER, 4
LOWER_TM_WRITER_TILE_NUMBER:
	.word	33040
	.section	.sdata.LOWER_TM_X,"aw"
	.align	2
	.set	.LANCHOR46,. + 0
	.type	LOWER_TM_X, @object
	.size	LOWER_TM_X, 4
LOWER_TM_X:
	.word	33024
	.section	.sdata.LOWER_TM_Y,"aw"
	.align	2
	.set	.LANCHOR47,. + 0
	.type	LOWER_TM_Y, @object
	.size	LOWER_TM_Y, 4
LOWER_TM_Y:
	.word	33026
	.section	.sdata.PB_COLOUR7,"aw"
	.align	2
	.set	.LANCHOR88,. + 0
	.type	PB_COLOUR7, @object
	.size	PB_COLOUR7, 4
PB_COLOUR7:
	.word	34416
	.section	.sdata.PB_COLOUR8B,"aw"
	.align	2
	.set	.LANCHOR92,. + 0
	.type	PB_COLOUR8B, @object
	.size	PB_COLOUR8B, 4
PB_COLOUR8B:
	.word	34422
	.section	.sdata.PB_COLOUR8G,"aw"
	.align	2
	.set	.LANCHOR91,. + 0
	.type	PB_COLOUR8G, @object
	.size	PB_COLOUR8G, 4
PB_COLOUR8G:
	.word	34420
	.section	.sdata.PB_COLOUR8R,"aw"
	.align	2
	.set	.LANCHOR90,. + 0
	.type	PB_COLOUR8R, @object
	.size	PB_COLOUR8R, 4
PB_COLOUR8R:
	.word	34418
	.section	.sdata.PB_STOP,"aw"
	.align	2
	.set	.LANCHOR89,. + 0
	.type	PB_STOP, @object
	.size	PB_STOP, 4
PB_STOP:
	.word	34424
	.section	.sdata.PS2_AVAILABLE,"aw"
	.align	2
	.set	.LANCHOR2,. + 0
	.type	PS2_AVAILABLE, @object
	.size	PS2_AVAILABLE, 4
PS2_AVAILABLE:
	.word	61712
	.section	.sdata.PS2_DATA,"aw"
	.align	2
	.set	.LANCHOR3,. + 0
	.type	PS2_DATA, @object
	.size	PS2_DATA, 4
PS2_DATA:
	.word	61714
	.section	.sdata.RNG,"aw"
	.align	2
	.set	.LANCHOR5,. + 0
	.type	RNG, @object
	.size	RNG, 4
RNG:
	.word	57344
	.section	.sdata.SCREENMODE,"aw"
	.align	2
	.set	.LANCHOR29,. + 0
	.type	SCREENMODE, @object
	.size	SCREENMODE, 4
SCREENMODE:
	.word	36608
	.section	.sdata.SDCARD_ADDRESS,"aw"
	.align	2
	.set	.LANCHOR23,. + 0
	.type	SDCARD_ADDRESS, @object
	.size	SDCARD_ADDRESS, 4
SDCARD_ADDRESS:
	.word	61776
	.section	.sdata.SDCARD_DATA,"aw"
	.align	2
	.set	.LANCHOR24,. + 0
	.type	SDCARD_DATA, @object
	.size	SDCARD_DATA, 4
SDCARD_DATA:
	.word	61776
	.section	.sdata.SDCARD_READY,"aw"
	.align	2
	.set	.LANCHOR19,. + 0
	.type	SDCARD_READY, @object
	.size	SDCARD_READY, 4
SDCARD_READY:
	.word	61760
	.section	.sdata.SDCARD_SECTOR_HIGH,"aw"
	.align	2
	.set	.LANCHOR20,. + 0
	.type	SDCARD_SECTOR_HIGH, @object
	.size	SDCARD_SECTOR_HIGH, 4
SDCARD_SECTOR_HIGH:
	.word	61762
	.section	.sdata.SDCARD_SECTOR_LOW,"aw"
	.align	2
	.set	.LANCHOR21,. + 0
	.type	SDCARD_SECTOR_LOW, @object
	.size	SDCARD_SECTOR_LOW, 4
SDCARD_SECTOR_LOW:
	.word	61764
	.section	.sdata.SDCARD_START,"aw"
	.align	2
	.set	.LANCHOR22,. + 0
	.type	SDCARD_START, @object
	.size	SDCARD_START, 4
SDCARD_START:
	.word	61760
	.section	.sdata.SLEEPTIMER0,"aw"
	.align	2
	.set	.LANCHOR6,. + 0
	.type	SLEEPTIMER0, @object
	.size	SLEEPTIMER0, 4
SLEEPTIMER0:
	.word	57392
	.section	.sdata.SLEEPTIMER1,"aw"
	.align	2
	.set	.LANCHOR7,. + 0
	.type	SLEEPTIMER1, @object
	.size	SLEEPTIMER1, 4
SLEEPTIMER1:
	.word	57394
	.section	.sdata.SMTPCH,"aw"
	.align	2
	.set	.LANCHOR141,. + 0
	.type	SMTPCH, @object
	.size	SMTPCH, 4
SMTPCH:
	.word	65520
	.section	.sdata.SMTPCL,"aw"
	.align	2
	.set	.LANCHOR142,. + 0
	.type	SMTPCL, @object
	.size	SMTPCL, 4
SMTPCL:
	.word	65522
	.section	.sdata.SMTSTATUS,"aw"
	.align	2
	.set	.LANCHOR140,. + 0
	.type	SMTSTATUS, @object
	.size	SMTSTATUS, 4
SMTSTATUS:
	.word	65534
	.section	.sdata.SYSTEMCLOCK,"aw"
	.align	2
	.set	.LANCHOR12,. + 0
	.type	SYSTEMCLOCK, @object
	.size	SYSTEMCLOCK, 4
SYSTEMCLOCK:
	.word	57408
	.section	.sdata.TIMER1HZ0,"aw"
	.align	2
	.set	.LANCHOR11,. + 0
	.type	TIMER1HZ0, @object
	.size	TIMER1HZ0, 4
TIMER1HZ0:
	.word	57360
	.section	.sdata.TIMER1HZ1,"aw"
	.align	2
	.set	.LANCHOR10,. + 0
	.type	TIMER1HZ1, @object
	.size	TIMER1HZ1, 4
TIMER1HZ1:
	.word	57362
	.section	.sdata.TIMER1KHZ0,"aw"
	.align	2
	.set	.LANCHOR8,. + 0
	.type	TIMER1KHZ0, @object
	.size	TIMER1KHZ0, 4
TIMER1KHZ0:
	.word	57376
	.section	.sdata.TIMER1KHZ1,"aw"
	.align	2
	.set	.LANCHOR9,. + 0
	.type	TIMER1KHZ1, @object
	.size	TIMER1KHZ1, 4
TIMER1KHZ1:
	.word	57378
	.section	.sdata.TPU_BACKGROUND,"aw"
	.align	2
	.set	.LANCHOR132,. + 0
	.type	TPU_BACKGROUND, @object
	.size	TPU_BACKGROUND, 4
TPU_BACKGROUND:
	.word	34054
	.section	.sdata.TPU_CHARACTER,"aw"
	.align	2
	.set	.LANCHOR134,. + 0
	.type	TPU_CHARACTER, @object
	.size	TPU_CHARACTER, 4
TPU_CHARACTER:
	.word	34052
	.section	.sdata.TPU_COMMIT,"aw"
	.align	2
	.set	.LANCHOR129,. + 0
	.type	TPU_COMMIT, @object
	.size	TPU_COMMIT, 4
TPU_COMMIT:
	.word	34058
	.section	.sdata.TPU_FOREGROUND,"aw"
	.align	2
	.set	.LANCHOR133,. + 0
	.type	TPU_FOREGROUND, @object
	.size	TPU_FOREGROUND, 4
TPU_FOREGROUND:
	.word	34056
	.section	.sdata.TPU_X,"aw"
	.align	2
	.set	.LANCHOR131,. + 0
	.type	TPU_X, @object
	.size	TPU_X, 4
TPU_X:
	.word	34048
	.section	.sdata.TPU_Y,"aw"
	.align	2
	.set	.LANCHOR130,. + 0
	.type	TPU_Y, @object
	.size	TPU_Y, 4
TPU_Y:
	.word	34050
	.section	.sdata.UART_DATA,"aw"
	.align	2
	.set	.LANCHOR1,. + 0
	.type	UART_DATA, @object
	.size	UART_DATA, 4
UART_DATA:
	.word	61696
	.section	.sdata.UART_STATUS,"aw"
	.align	2
	.set	.LANCHOR0,. + 0
	.type	UART_STATUS, @object
	.size	UART_STATUS, 4
UART_STATUS:
	.word	61698
	.section	.sdata.UPPER_SPRITE_ACTIVE,"aw"
	.align	2
	.set	.LANCHOR117,. + 0
	.type	UPPER_SPRITE_ACTIVE, @object
	.size	UPPER_SPRITE_ACTIVE, 4
UPPER_SPRITE_ACTIVE:
	.word	33792
	.section	.sdata.UPPER_SPRITE_COLLISION_BASE,"aw"
	.align	2
	.set	.LANCHOR124,. + 0
	.type	UPPER_SPRITE_COLLISION_BASE, @object
	.size	UPPER_SPRITE_COLLISION_BASE, 4
UPPER_SPRITE_COLLISION_BASE:
	.word	33984
	.section	.sdata.UPPER_SPRITE_COLOUR,"aw"
	.align	2
	.set	.LANCHOR119,. + 0
	.type	UPPER_SPRITE_COLOUR, @object
	.size	UPPER_SPRITE_COLOUR, 4
UPPER_SPRITE_COLOUR:
	.word	33856
	.section	.sdata.UPPER_SPRITE_DOUBLE,"aw"
	.align	2
	.set	.LANCHOR122,. + 0
	.type	UPPER_SPRITE_DOUBLE, @object
	.size	UPPER_SPRITE_DOUBLE, 4
UPPER_SPRITE_DOUBLE:
	.word	33824
	.section	.sdata.UPPER_SPRITE_LAYER_COLLISION_BASE,"aw"
	.align	2
	.set	.LANCHOR126,. + 0
	.type	UPPER_SPRITE_LAYER_COLLISION_BASE, @object
	.size	UPPER_SPRITE_LAYER_COLLISION_BASE, 4
UPPER_SPRITE_LAYER_COLLISION_BASE:
	.word	34016
	.section	.sdata.UPPER_SPRITE_TILE,"aw"
	.align	2
	.set	.LANCHOR118,. + 0
	.type	UPPER_SPRITE_TILE, @object
	.size	UPPER_SPRITE_TILE, 4
UPPER_SPRITE_TILE:
	.word	33952
	.section	.sdata.UPPER_SPRITE_UPDATE,"aw"
	.align	2
	.set	.LANCHOR128,. + 0
	.type	UPPER_SPRITE_UPDATE, @object
	.size	UPPER_SPRITE_UPDATE, 4
UPPER_SPRITE_UPDATE:
	.word	33984
	.section	.sdata.UPPER_SPRITE_WRITER_BITMAP,"aw"
	.align	2
	.set	.LANCHOR110,. + 0
	.type	UPPER_SPRITE_WRITER_BITMAP, @object
	.size	UPPER_SPRITE_WRITER_BITMAP, 4
UPPER_SPRITE_WRITER_BITMAP:
	.word	34836
	.section	.sdata.UPPER_SPRITE_WRITER_LINE,"aw"
	.align	2
	.set	.LANCHOR109,. + 0
	.type	UPPER_SPRITE_WRITER_LINE, @object
	.size	UPPER_SPRITE_WRITER_LINE, 4
UPPER_SPRITE_WRITER_LINE:
	.word	34834
	.section	.sdata.UPPER_SPRITE_WRITER_NUMBER,"aw"
	.align	2
	.set	.LANCHOR106,. + 0
	.type	UPPER_SPRITE_WRITER_NUMBER, @object
	.size	UPPER_SPRITE_WRITER_NUMBER, 4
UPPER_SPRITE_WRITER_NUMBER:
	.word	34832
	.section	.sdata.UPPER_SPRITE_X,"aw"
	.align	2
	.set	.LANCHOR120,. + 0
	.type	UPPER_SPRITE_X, @object
	.size	UPPER_SPRITE_X, 4
UPPER_SPRITE_X:
	.word	33888
	.section	.sdata.UPPER_SPRITE_Y,"aw"
	.align	2
	.set	.LANCHOR121,. + 0
	.type	UPPER_SPRITE_Y, @object
	.size	UPPER_SPRITE_Y, 4
UPPER_SPRITE_Y:
	.word	33920
	.section	.sdata.UPPER_TM_BACKGROUND,"aw"
	.align	2
	.set	.LANCHOR56,. + 0
	.type	UPPER_TM_BACKGROUND, @object
	.size	UPPER_TM_BACKGROUND, 4
UPPER_TM_BACKGROUND:
	.word	33286
	.section	.sdata.UPPER_TM_COMMIT,"aw"
	.align	2
	.set	.LANCHOR58,. + 0
	.type	UPPER_TM_COMMIT, @object
	.size	UPPER_TM_COMMIT, 4
UPPER_TM_COMMIT:
	.word	33290
	.section	.sdata.UPPER_TM_FOREGROUND,"aw"
	.align	2
	.set	.LANCHOR57,. + 0
	.type	UPPER_TM_FOREGROUND, @object
	.size	UPPER_TM_FOREGROUND, 4
UPPER_TM_FOREGROUND:
	.word	33288
	.section	.sdata.UPPER_TM_SCROLLWRAPCLEAR,"aw"
	.align	2
	.set	.LANCHOR66,. + 0
	.type	UPPER_TM_SCROLLWRAPCLEAR, @object
	.size	UPPER_TM_SCROLLWRAPCLEAR, 4
UPPER_TM_SCROLLWRAPCLEAR:
	.word	33312
	.section	.sdata.UPPER_TM_STATUS,"aw"
	.align	2
	.set	.LANCHOR52,. + 0
	.type	UPPER_TM_STATUS, @object
	.size	UPPER_TM_STATUS, 4
UPPER_TM_STATUS:
	.word	33314
	.section	.sdata.UPPER_TM_TILE,"aw"
	.align	2
	.set	.LANCHOR55,. + 0
	.type	UPPER_TM_TILE, @object
	.size	UPPER_TM_TILE, 4
UPPER_TM_TILE:
	.word	33284
	.section	.sdata.UPPER_TM_WRITER_BITMAP,"aw"
	.align	2
	.set	.LANCHOR64,. + 0
	.type	UPPER_TM_WRITER_BITMAP, @object
	.size	UPPER_TM_WRITER_BITMAP, 4
UPPER_TM_WRITER_BITMAP:
	.word	33300
	.section	.sdata.UPPER_TM_WRITER_LINE_NUMBER,"aw"
	.align	2
	.set	.LANCHOR63,. + 0
	.type	UPPER_TM_WRITER_LINE_NUMBER, @object
	.size	UPPER_TM_WRITER_LINE_NUMBER, 4
UPPER_TM_WRITER_LINE_NUMBER:
	.word	33298
	.section	.sdata.UPPER_TM_WRITER_TILE_NUMBER,"aw"
	.align	2
	.set	.LANCHOR62,. + 0
	.type	UPPER_TM_WRITER_TILE_NUMBER, @object
	.size	UPPER_TM_WRITER_TILE_NUMBER, 4
UPPER_TM_WRITER_TILE_NUMBER:
	.word	33296
	.section	.sdata.UPPER_TM_X,"aw"
	.align	2
	.set	.LANCHOR53,. + 0
	.type	UPPER_TM_X, @object
	.size	UPPER_TM_X, 4
UPPER_TM_X:
	.word	33280
	.section	.sdata.UPPER_TM_Y,"aw"
	.align	2
	.set	.LANCHOR54,. + 0
	.type	UPPER_TM_Y, @object
	.size	UPPER_TM_Y, 4
UPPER_TM_Y:
	.word	33282
	.section	.sdata.VBLANK,"aw"
	.align	2
	.set	.LANCHOR28,. + 0
	.type	VBLANK, @object
	.size	VBLANK, 4
VBLANK:
	.word	36608
	.section	.sdata.VECTOR_DRAW_BLOCK,"aw"
	.align	2
	.set	.LANCHOR94,. + 0
	.type	VECTOR_DRAW_BLOCK, @object
	.size	VECTOR_DRAW_BLOCK, 4
VECTOR_DRAW_BLOCK:
	.word	34336
	.section	.sdata.VECTOR_DRAW_COLOUR,"aw"
	.align	2
	.set	.LANCHOR95,. + 0
	.type	VECTOR_DRAW_COLOUR, @object
	.size	VECTOR_DRAW_COLOUR, 4
VECTOR_DRAW_COLOUR:
	.word	34338
	.section	.sdata.VECTOR_DRAW_SCALE,"aw"
	.align	2
	.set	.LANCHOR98,. + 0
	.type	VECTOR_DRAW_SCALE, @object
	.size	VECTOR_DRAW_SCALE, 4
VECTOR_DRAW_SCALE:
	.word	34344
	.section	.sdata.VECTOR_DRAW_START,"aw"
	.align	2
	.set	.LANCHOR99,. + 0
	.type	VECTOR_DRAW_START, @object
	.size	VECTOR_DRAW_START, 4
VECTOR_DRAW_START:
	.word	34346
	.section	.sdata.VECTOR_DRAW_STATUS,"aw"
	.align	2
	.set	.LANCHOR93,. + 0
	.type	VECTOR_DRAW_STATUS, @object
	.size	VECTOR_DRAW_STATUS, 4
VECTOR_DRAW_STATUS:
	.word	34346
	.section	.sdata.VECTOR_DRAW_XC,"aw"
	.align	2
	.set	.LANCHOR96,. + 0
	.type	VECTOR_DRAW_XC, @object
	.size	VECTOR_DRAW_XC, 4
VECTOR_DRAW_XC:
	.word	34340
	.section	.sdata.VECTOR_DRAW_YC,"aw"
	.align	2
	.set	.LANCHOR97,. + 0
	.type	VECTOR_DRAW_YC, @object
	.size	VECTOR_DRAW_YC, 4
VECTOR_DRAW_YC:
	.word	34342
	.section	.sdata.VECTOR_WRITER_ACTIVE,"aw"
	.align	2
	.set	.LANCHOR102,. + 0
	.type	VECTOR_WRITER_ACTIVE, @object
	.size	VECTOR_WRITER_ACTIVE, 4
VECTOR_WRITER_ACTIVE:
	.word	34360
	.section	.sdata.VECTOR_WRITER_BLOCK,"aw"
	.align	2
	.set	.LANCHOR100,. + 0
	.type	VECTOR_WRITER_BLOCK, @object
	.size	VECTOR_WRITER_BLOCK, 4
VECTOR_WRITER_BLOCK:
	.word	34352
	.section	.sdata.VECTOR_WRITER_DELTAX,"aw"
	.align	2
	.set	.LANCHOR103,. + 0
	.type	VECTOR_WRITER_DELTAX, @object
	.size	VECTOR_WRITER_DELTAX, 4
VECTOR_WRITER_DELTAX:
	.word	34356
	.section	.sdata.VECTOR_WRITER_DELTAY,"aw"
	.align	2
	.set	.LANCHOR104,. + 0
	.type	VECTOR_WRITER_DELTAY, @object
	.size	VECTOR_WRITER_DELTAY, 4
VECTOR_WRITER_DELTAY:
	.word	34358
	.section	.sdata.VECTOR_WRITER_VERTEX,"aw"
	.align	2
	.set	.LANCHOR101,. + 0
	.type	VECTOR_WRITER_VERTEX, @object
	.size	VECTOR_WRITER_VERTEX, 4
VECTOR_WRITER_VERTEX:
	.word	34354
	.section	.sdata.__curses_cursor,"aw"
	.set	.LANCHOR147,. + 0
	.type	__curses_cursor, @object
	.size	__curses_cursor, 1
__curses_cursor:
	.byte	1
	.section	.sdata.__curses_fore,"aw"
	.align	1
	.set	.LANCHOR145,. + 0
	.type	__curses_fore, @object
	.size	__curses_fore, 2
__curses_fore:
	.half	63
	.section	.sdata.__curses_scroll,"aw"
	.set	.LANCHOR148,. + 0
	.type	__curses_scroll, @object
	.size	__curses_scroll, 1
__curses_scroll:
	.byte	1
	.ident	"GCC: (Arch Linux Repositories) 11.1.0"
