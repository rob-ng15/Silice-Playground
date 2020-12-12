	.file	"BIOS.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	1
	.globl	memcpy
	.type	memcpy, @function
memcpy:
	ret
	.size	memcpy, .-memcpy
	.align	1
	.globl	outputcharacter
	.type	outputcharacter, @function
outputcharacter:
	lui	a2,%hi(UART_STATUS)
	lui	a1,%hi(UART_DATA)
	lui	a6,%hi(TERMINAL_STATUS)
	lui	a3,%hi(TERMINAL_OUTPUT)
	li	a4,10
.L5:
	lw	a7,%lo(UART_STATUS)(a2)
.L3:
	lbu	a5,0(a7)
	andi	a5,a5,2
	bne	a5,zero,.L3
	lw	a5,%lo(UART_DATA)(a1)
	sb	a0,0(a5)
	lw	a7,%lo(TERMINAL_STATUS)(a6)
.L4:
	lbu	a5,0(a7)
	andi	a5,a5,0xff
	bne	a5,zero,.L4
	lw	a5,%lo(TERMINAL_OUTPUT)(a3)
	sb	a0,0(a5)
	beq	a0,a4,.L6
	ret
.L6:
	li	a0,13
	j	.L5
	.size	outputcharacter, .-outputcharacter
	.align	1
	.globl	outputstring
	.type	outputstring, @function
outputstring:
	addi	sp,sp,-16
	sw	s0,8(sp)
	sw	ra,12(sp)
	mv	s0,a0
.L10:
	lbu	a0,0(s0)
	bne	a0,zero,.L11
	lw	s0,8(sp)
	lw	ra,12(sp)
	li	a0,10
	addi	sp,sp,16
	tail	outputcharacter
.L11:
	call	outputcharacter
	addi	s0,s0,1
	j	.L10
	.size	outputstring, .-outputstring
	.align	1
	.globl	outputstringnonl
	.type	outputstringnonl, @function
outputstringnonl:
	addi	sp,sp,-16
	sw	s0,8(sp)
	sw	ra,12(sp)
	mv	s0,a0
.L14:
	lbu	a0,0(s0)
	bne	a0,zero,.L15
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
.L15:
	call	outputcharacter
	addi	s0,s0,1
	j	.L14
	.size	outputstringnonl, .-outputstringnonl
	.align	1
	.globl	outputnumber_char
	.type	outputnumber_char, @function
outputnumber_char:
	li	a5,3153920
	addi	sp,sp,-32
	addi	a5,a5,32
	sw	a5,12(sp)
	sw	ra,28(sp)
	li	a5,0
	li	a2,10
	li	a1,2
.L18:
	bne	a0,zero,.L19
	addi	a0,sp,12
	call	outputstringnonl
	lw	ra,28(sp)
	addi	sp,sp,32
	jr	ra
.L19:
	remu	a3,a0,a2
	sub	a4,a1,a5
	addi	a6,sp,16
	add	a4,a6,a4
	addi	a5,a5,1
	andi	a5,a5,0xff
	addi	a3,a3,48
	divu	a0,a0,a2
	sb	a3,-4(a4)
	j	.L18
	.size	outputnumber_char, .-outputnumber_char
	.align	1
	.globl	outputnumber_short
	.type	outputnumber_short, @function
outputnumber_short:
	li	a5,538976256
	addi	sp,sp,-32
	addi	a5,a5,32
	sw	a5,8(sp)
	li	a5,48
	sh	a5,12(sp)
	sw	ra,28(sp)
	li	a5,0
	li	a2,10
	li	a1,4
.L22:
	bne	a0,zero,.L23
	addi	a0,sp,8
	call	outputstringnonl
	lw	ra,28(sp)
	addi	sp,sp,32
	jr	ra
.L23:
	remu	a3,a0,a2
	sub	a4,a1,a5
	addi	a6,sp,16
	addi	a5,a5,1
	add	a4,a6,a4
	slli	a5,a5,16
	srli	a5,a5,16
	addi	a3,a3,48
	divu	a0,a0,a2
	sb	a3,-8(a4)
	j	.L22
	.size	outputnumber_short, .-outputnumber_short
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"         0"
	.text
	.align	1
	.globl	outputnumber_int
	.type	outputnumber_int, @function
outputnumber_int:
	addi	sp,sp,-32
	lui	a1,%hi(.LC0)
	sw	s0,24(sp)
	li	a2,11
	addi	a1,a1,%lo(.LC0)
	mv	s0,a0
	addi	a0,sp,4
	sw	ra,28(sp)
	call	memcpy
	li	a5,10
	li	a1,-1
	li	a2,10
.L26:
	beq	s0,zero,.L27
	addi	a5,a5,-1
	bne	a5,a1,.L28
.L27:
	addi	a0,sp,4
	call	outputstringnonl
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
.L28:
	remu	a3,s0,a2
	addi	a4,sp,4
	add	a4,a4,a5
	addi	a3,a3,48
	divu	s0,s0,a2
	sb	a3,0(a4)
	j	.L26
	.size	outputnumber_int, .-outputnumber_int
	.align	1
	.globl	inputcharacter
	.type	inputcharacter, @function
inputcharacter:
	lui	a5,%hi(UART_STATUS)
	lw	a4,%lo(UART_STATUS)(a5)
.L34:
	lbu	a5,0(a4)
	andi	a5,a5,1
	beq	a5,zero,.L34
	lui	a5,%hi(UART_DATA)
	lw	a5,%lo(UART_DATA)(a5)
	lbu	a0,0(a5)
	ret
	.size	inputcharacter, .-inputcharacter
	.align	1
	.globl	gpu_rectangle
	.type	gpu_rectangle, @function
gpu_rectangle:
	lui	a5,%hi(GPU_STATUS)
	lw	a6,%lo(GPU_STATUS)(a5)
.L38:
	lbu	a5,0(a6)
	andi	a5,a5,0xff
	bne	a5,zero,.L38
	lui	a5,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a5)
	sb	a0,0(a5)
	lui	a5,%hi(GPU_X)
	lw	a5,%lo(GPU_X)(a5)
	sh	a1,0(a5)
	lui	a5,%hi(GPU_Y)
	lw	a5,%lo(GPU_Y)(a5)
	sh	a2,0(a5)
	lui	a5,%hi(GPU_PARAM0)
	lw	a5,%lo(GPU_PARAM0)(a5)
	sh	a3,0(a5)
	lui	a5,%hi(GPU_PARAM1)
	lw	a5,%lo(GPU_PARAM1)(a5)
	sh	a4,0(a5)
	lui	a5,%hi(GPU_WRITE)
	lw	a5,%lo(GPU_WRITE)(a5)
	li	a4,2
	sb	a4,0(a5)
	ret
	.size	gpu_rectangle, .-gpu_rectangle
	.align	1
	.globl	gpu_cs
	.type	gpu_cs, @function
gpu_cs:
	li	a4,479
	li	a3,639
	li	a2,0
	li	a1,0
	li	a0,64
	tail	gpu_rectangle
	.size	gpu_cs, .-gpu_cs
	.align	1
	.globl	gpu_fillcircle
	.type	gpu_fillcircle, @function
gpu_fillcircle:
	lui	a5,%hi(GPU_STATUS)
	lw	a4,%lo(GPU_STATUS)(a5)
.L42:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L42
	lui	a5,%hi(GPU_COLOUR)
	lw	a5,%lo(GPU_COLOUR)(a5)
	li	a4,6
	sb	a0,0(a5)
	lui	a5,%hi(GPU_X)
	lw	a5,%lo(GPU_X)(a5)
	sh	a1,0(a5)
	lui	a5,%hi(GPU_Y)
	lw	a5,%lo(GPU_Y)(a5)
	sh	a2,0(a5)
	lui	a5,%hi(GPU_PARAM0)
	lw	a5,%lo(GPU_PARAM0)(a5)
	sh	a3,0(a5)
	lui	a5,%hi(GPU_WRITE)
	lw	a5,%lo(GPU_WRITE)(a5)
	sb	a4,0(a5)
	ret
	.size	gpu_fillcircle, .-gpu_fillcircle
	.align	1
	.globl	gpu_triangle
	.type	gpu_triangle, @function
gpu_triangle:
	lui	a7,%hi(GPU_STATUS)
	lw	t1,%lo(GPU_STATUS)(a7)
.L45:
	lbu	a7,0(t1)
	andi	a7,a7,0xff
	bne	a7,zero,.L45
	lui	a7,%hi(GPU_COLOUR)
	lw	a7,%lo(GPU_COLOUR)(a7)
	sb	a0,0(a7)
	lui	a0,%hi(GPU_X)
	lw	a0,%lo(GPU_X)(a0)
	sh	a1,0(a0)
	lui	a1,%hi(GPU_Y)
	lw	a1,%lo(GPU_Y)(a1)
	sh	a2,0(a1)
	lui	a2,%hi(GPU_PARAM0)
	lw	a2,%lo(GPU_PARAM0)(a2)
	sh	a3,0(a2)
	lui	a3,%hi(GPU_PARAM1)
	lw	a3,%lo(GPU_PARAM1)(a3)
	sh	a4,0(a3)
	lui	a4,%hi(GPU_PARAM2)
	lw	a4,%lo(GPU_PARAM2)(a4)
	sh	a5,0(a4)
	lui	a5,%hi(GPU_PARAM3)
	lw	a5,%lo(GPU_PARAM3)(a5)
	li	a4,7
	sh	a6,0(a5)
	lui	a5,%hi(GPU_WRITE)
	lw	a5,%lo(GPU_WRITE)(a5)
	sb	a4,0(a5)
	ret
	.size	gpu_triangle, .-gpu_triangle
	.align	1
	.globl	tpu_cs
	.type	tpu_cs, @function
tpu_cs:
	lui	a5,%hi(TPU_COMMIT)
	lw	a4,%lo(TPU_COMMIT)(a5)
.L48:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L48
	li	a5,3
	sb	a5,0(a4)
	ret
	.size	tpu_cs, .-tpu_cs
	.align	1
	.globl	tpu_set
	.type	tpu_set, @function
tpu_set:
	lui	a5,%hi(TPU_X)
	lw	a5,%lo(TPU_X)(a5)
	li	a4,1
	sb	a0,0(a5)
	lui	a5,%hi(TPU_Y)
	lw	a5,%lo(TPU_Y)(a5)
	sb	a1,0(a5)
	lui	a5,%hi(TPU_BACKGROUND)
	lw	a5,%lo(TPU_BACKGROUND)(a5)
	sb	a2,0(a5)
	lui	a5,%hi(TPU_FOREGROUND)
	lw	a5,%lo(TPU_FOREGROUND)(a5)
	sb	a3,0(a5)
	lui	a5,%hi(TPU_COMMIT)
	lw	a5,%lo(TPU_COMMIT)(a5)
	sb	a4,0(a5)
	ret
	.size	tpu_set, .-tpu_set
	.align	1
	.globl	tpu_output_character
	.type	tpu_output_character, @function
tpu_output_character:
	lui	a5,%hi(TPU_COMMIT)
	lw	a3,%lo(TPU_COMMIT)(a5)
.L52:
	lbu	a4,0(a3)
	andi	a4,a4,0xff
	bne	a4,zero,.L52
	lui	a4,%hi(TPU_CHARACTER)
	lw	a4,%lo(TPU_CHARACTER)(a4)
	sb	a0,0(a4)
	lw	a5,%lo(TPU_COMMIT)(a5)
	li	a4,2
	sb	a4,0(a5)
	ret
	.size	tpu_output_character, .-tpu_output_character
	.align	1
	.globl	tpu_outputstring
	.type	tpu_outputstring, @function
tpu_outputstring:
	addi	sp,sp,-16
	sw	s0,8(sp)
	sw	s1,4(sp)
	sw	ra,12(sp)
	mv	s0,a0
	lui	s1,%hi(TPU_COMMIT)
.L55:
	lbu	a0,0(s0)
	bne	a0,zero,.L57
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
.L57:
	lw	a4,%lo(TPU_COMMIT)(s1)
.L56:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	bne	a5,zero,.L56
	call	tpu_output_character
	addi	s0,s0,1
	j	.L55
	.size	tpu_outputstring, .-tpu_outputstring
	.align	1
	.globl	tpu_outputnumber_char
	.type	tpu_outputnumber_char, @function
tpu_outputnumber_char:
	li	a5,3153920
	addi	sp,sp,-32
	addi	a5,a5,32
	sw	a5,12(sp)
	sw	ra,28(sp)
	li	a5,0
	li	a2,10
	li	a1,2
.L61:
	bne	a0,zero,.L62
	addi	a0,sp,12
	call	tpu_outputstring
	lw	ra,28(sp)
	addi	sp,sp,32
	jr	ra
.L62:
	remu	a3,a0,a2
	sub	a4,a1,a5
	addi	a6,sp,16
	add	a4,a6,a4
	addi	a5,a5,1
	andi	a5,a5,0xff
	addi	a3,a3,48
	divu	a0,a0,a2
	sb	a3,-4(a4)
	j	.L61
	.size	tpu_outputnumber_char, .-tpu_outputnumber_char
	.align	1
	.globl	tpu_outputnumber_short
	.type	tpu_outputnumber_short, @function
tpu_outputnumber_short:
	li	a5,538976256
	addi	sp,sp,-32
	addi	a5,a5,32
	sw	a5,8(sp)
	li	a5,48
	sh	a5,12(sp)
	sw	ra,28(sp)
	li	a5,0
	li	a2,10
	li	a1,4
.L65:
	bne	a0,zero,.L66
	addi	a0,sp,8
	call	tpu_outputstring
	lw	ra,28(sp)
	addi	sp,sp,32
	jr	ra
.L66:
	remu	a3,a0,a2
	sub	a4,a1,a5
	addi	a6,sp,16
	addi	a5,a5,1
	add	a4,a6,a4
	slli	a5,a5,16
	srli	a5,a5,16
	addi	a3,a3,48
	divu	a0,a0,a2
	sb	a3,-8(a4)
	j	.L65
	.size	tpu_outputnumber_short, .-tpu_outputnumber_short
	.align	1
	.globl	tpu_outputnumber_int
	.type	tpu_outputnumber_int, @function
tpu_outputnumber_int:
	addi	sp,sp,-32
	lui	a1,%hi(.LC0)
	sw	s0,24(sp)
	li	a2,11
	addi	a1,a1,%lo(.LC0)
	mv	s0,a0
	addi	a0,sp,4
	sw	ra,28(sp)
	call	memcpy
	li	a5,10
	li	a1,-1
	li	a2,10
.L69:
	beq	s0,zero,.L70
	addi	a5,a5,-1
	bne	a5,a1,.L71
.L70:
	addi	a0,sp,4
	call	tpu_outputstring
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
.L71:
	remu	a3,s0,a2
	addi	a4,sp,4
	add	a4,a4,a5
	addi	a3,a3,48
	divu	s0,s0,a2
	sb	a3,0(a4)
	j	.L69
	.size	tpu_outputnumber_int, .-tpu_outputnumber_int
	.section	.rodata.str1.4
	.align	2
.LC1:
	.string	"Reading Sector: "
	.align	2
.LC2:
	.string	"Sector Read    : "
	.text
	.align	1
	.globl	sd_readSector
	.type	sd_readSector, @function
sd_readSector:
	addi	sp,sp,-16
	li	a3,48
	li	a2,64
	sw	s0,8(sp)
	sw	s1,4(sp)
	mv	s0,a0
	mv	s1,a1
	li	a0,40
	li	a1,0
	sw	ra,12(sp)
	call	tpu_set
	lui	a0,%hi(.LC1)
	addi	a0,a0,%lo(.LC1)
	call	tpu_outputstring
	mv	a0,s0
	call	tpu_outputnumber_int
	lui	a5,%hi(SDCARD_READY)
	lw	a3,%lo(SDCARD_READY)(a5)
.L77:
	lbu	a4,0(a3)
	andi	a4,a4,0xff
	beq	a4,zero,.L77
	lui	a4,%hi(SDCARD_SECTOR_HIGH)
	lw	a4,%lo(SDCARD_SECTOR_HIGH)(a4)
	srli	a3,s0,16
	sh	a3,0(a4)
	lui	a4,%hi(SDCARD_SECTOR_LOW)
	lw	a4,%lo(SDCARD_SECTOR_LOW)(a4)
	slli	a3,s0,16
	srli	a3,a3,16
	sh	a3,0(a4)
	lui	a4,%hi(SDCARD_START)
	lw	a4,%lo(SDCARD_START)(a4)
	li	a3,1
	sb	a3,0(a4)
	lw	a4,%lo(SDCARD_READY)(a5)
.L78:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	beq	a5,zero,.L78
	li	a1,0
	li	a3,12
	li	a2,64
	li	a0,40
	call	tpu_set
	lui	a0,%hi(.LC2)
	addi	a0,a0,%lo(.LC2)
	call	tpu_outputstring
	mv	a0,s0
	call	tpu_outputnumber_int
	li	a5,0
	lui	a0,%hi(SDCARD_ADDRESS)
	lui	a1,%hi(SDCARD_DATA)
	li	a4,512
.L79:
	lw	a3,%lo(SDCARD_ADDRESS)(a0)
	slli	a2,a5,16
	srli	a2,a2,16
	sh	a2,0(a3)
	lw	a3,%lo(SDCARD_DATA)(a1)
	lbu	a2,0(a3)
	add	a3,s1,a5
	addi	a5,a5,1
	sb	a2,0(a3)
	bne	a5,a4,.L79
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
	.size	sd_readSector, .-sd_readSector
	.align	1
	.globl	sd_readMBR
	.type	sd_readMBR, @function
sd_readMBR:
	lui	a1,%hi(.LANCHOR0)
	addi	a1,a1,%lo(.LANCHOR0)
	li	a0,0
	tail	sd_readSector
	.size	sd_readMBR, .-sd_readMBR
	.align	1
	.globl	sd_readRootDirectory
	.type	sd_readRootDirectory, @function
sd_readRootDirectory:
	addi	sp,sp,-32
	sw	s1,20(sp)
	lui	s1,%hi(.LANCHOR0)
	sw	s0,24(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	ra,28(sp)
	li	s0,0
	addi	s1,s1,%lo(.LANCHOR0)
	lui	s2,%hi(ROOTDIRECTORY)
	lui	s3,%hi(PARTITION)
.L88:
	lw	a5,528(s1)
	slli	a5,a5,8
	srli	a5,a5,20
	bltu	s0,a5,.L89
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	addi	sp,sp,32
	jr	ra
.L89:
	lw	a4,%lo(PARTITION)(s3)
	lw	a1,%lo(ROOTDIRECTORY)(s2)
	slli	a3,s0,9
	lbu	a0,9(a4)
	lbu	a5,8(a4)
	addi	s0,s0,1
	slli	a0,a0,8
	or	a0,a0,a5
	lbu	a5,10(a4)
	add	a1,a1,a3
	slli	s0,s0,16
	slli	a5,a5,16
	or	a0,a5,a0
	lbu	a5,11(a4)
	lbu	a4,528(s1)
	srli	s0,s0,16
	slli	a5,a5,24
	or	a5,a5,a0
	lhu	a0,526(s1)
	add	a5,a5,a0
	lhu	a0,534(s1)
	addi	a5,a5,-1
	mul	a0,a0,a4
	add	a0,a5,a0
	call	sd_readSector
	j	.L88
	.size	sd_readRootDirectory, .-sd_readRootDirectory
	.section	.rodata.str1.4
	.align	2
.LC3:
	.string	"Welcome to RISC-ICE-V a RISC-V RV32IMC CPU"
	.align	2
.LC4:
	.string	"Waiting for SDCARD"
	.align	2
.LC5:
	.string	"SCARD Detected    "
	.align	2
.LC6:
	.string	"Reading Master Boot Record"
	.align	2
.LC7:
	.string	"Read Master Boot Record   "
	.align	2
.LC8:
	.string	"Partition : "
	.align	2
.LC9:
	.string	", Type : "
	.align	2
.LC10:
	.string	" No Entry"
	.align	2
.LC11:
	.string	" FAT16 <32MB"
	.align	2
.LC12:
	.string	" FAT16 >32MB"
	.align	2
.LC13:
	.string	" FAT16 LBA"
	.align	2
.LC14:
	.string	" Not FAT16"
	.align	2
.LC15:
	.string	"Reading Partition 0 Boot Sector"
	.align	2
.LC16:
	.string	"Read Partition 0 Boot Sector   "
	.align	2
.LC17:
	.string	"Sector Size: "
	.align	2
.LC18:
	.string	" Cluster Size: "
	.align	2
.LC19:
	.string	" Total Sectors: "
	.align	2
.LC20:
	.string	"Reading Root Directory"
	.align	2
.LC21:
	.string	"Read Root Directory   "
	.align	2
.LC22:
	.string	"\n\n\n\n\n\n\n\nRISC-ICE-V BIOS"
	.align	2
.LC23:
	.string	"> ls"
	.align	2
.LC24:
	.string	"ERROR: PLEASE INSERT A VALID FAT16 FORMATTED SDCARD AND PRESS RESET"
	.align	2
.LC25:
	.string	"[deleted]"
	.align	2
.LC26:
	.string	"[directory]"
	.align	2
.LC27:
	.string	"\nTerminal Echo Starting"
	.align	2
.LC28:
	.string	"You pressed : "
	.align	2
.LC29:
	.string	" <-"
	.section	.text.startup,"ax",@progbits
	.align	1
	.globl	main
	.type	main, @function
main:
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
	call	gpu_cs
	call	tpu_cs
	li	a4,479
	li	a3,639
	li	a2,0
	li	a1,0
	li	a0,64
	call	gpu_rectangle
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
	li	a3,26
	li	a2,25
	li	a1,25
	li	a0,63
	call	gpu_fillcircle
	li	a4,12
	li	a3,25
	li	a2,0
	li	a1,0
	li	a0,63
	call	gpu_rectangle
	li	a3,12
	li	a2,25
	li	a1,25
	li	a0,2
	call	gpu_fillcircle
	li	a6,100
	li	a5,0
	li	a4,100
	li	a3,67
	li	a2,33
	li	a1,0
	li	a0,63
	call	gpu_triangle
	li	a5,0
	li	a6,100
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
	li	a3,63
	li	a2,64
	li	a1,5
	li	a0,16
	call	tpu_set
	lui	a0,%hi(.LC3)
	addi	a0,a0,%lo(.LC3)
	call	tpu_outputstring
	li	a3,48
	li	a2,64
	li	a1,7
	li	a0,0
	call	tpu_set
	lui	a0,%hi(.LC4)
	addi	a0,a0,%lo(.LC4)
	call	tpu_outputstring
	lui	a5,%hi(SDCARD_READY)
	lw	a4,%lo(SDCARD_READY)(a5)
.L92:
	lbu	a5,0(a4)
	andi	a5,a5,0xff
	beq	a5,zero,.L92
	li	a3,12
	li	a2,64
	li	a1,7
	li	a0,0
	call	tpu_set
	lui	a0,%hi(.LC5)
	addi	a0,a0,%lo(.LC5)
	call	tpu_outputstring
	li	a3,48
	li	a2,64
	li	a1,8
	li	a0,0
	call	tpu_set
	lui	a0,%hi(.LC6)
	addi	a0,a0,%lo(.LC6)
	call	tpu_outputstring
	lui	s0,%hi(.LANCHOR0)
	addi	a1,s0,%lo(.LANCHOR0)
	li	a0,0
	call	sd_readSector
	addi	s1,s0,%lo(.LANCHOR0)
	addi	s1,s1,446
	li	a3,12
	li	a2,64
	li	a1,8
	li	a0,0
	lui	s2,%hi(PARTITION)
	sw	s1,%lo(PARTITION)(s2)
	call	tpu_set
	lui	a0,%hi(.LC7)
	addi	a0,a0,%lo(.LC7)
	call	tpu_outputstring
	li	s1,0
	addi	s0,s0,%lo(.LANCHOR0)
	lui	s4,%hi(.LC8)
	lui	s5,%hi(.LC9)
	lui	s6,%hi(.LC12)
	lui	s7,%hi(.LC14)
	lui	s8,%hi(.LC13)
	lui	s9,%hi(.LC10)
	li	s3,4
	lui	s10,%hi(.LC11)
.L100:
	addi	a1,s1,10
	li	a3,63
	li	a2,64
	andi	a1,a1,0xff
	li	a0,2
	call	tpu_set
	addi	a0,s4,%lo(.LC8)
	call	tpu_outputstring
	slli	a0,s1,16
	srli	a0,a0,16
	call	tpu_outputnumber_short
	addi	a0,s5,%lo(.LC9)
	call	tpu_outputstring
	lw	a5,%lo(PARTITION)(s2)
	slli	s11,s1,4
	add	a5,a5,s11
	lbu	a0,4(a5)
	call	tpu_outputnumber_char
	lw	a5,%lo(PARTITION)(s2)
	li	a4,6
	addi	a0,s6,%lo(.LC12)
	add	s11,a5,s11
	lbu	a5,4(s11)
	beq	a5,a4,.L133
	bgtu	a5,a4,.L94
	addi	a0,s9,%lo(.LC10)
	beq	a5,zero,.L133
	addi	a0,s10,%lo(.LC11)
	beq	a5,s3,.L133
.L97:
	addi	a0,s7,%lo(.LC14)
	j	.L133
.L94:
	li	a4,14
	addi	a0,s8,%lo(.LC13)
	bne	a5,a4,.L97
.L133:
	addi	s1,s1,1
	call	tpu_outputstring
	bne	s1,s3,.L100
	lw	a5,%lo(PARTITION)(s2)
	li	a4,10
	li	a3,48
	lbu	a5,4(a5)
	li	a2,64
	li	a1,15
	addi	a5,a5,-4
	andi	a5,a5,0xff
	li	a0,0
	bgtu	a5,a4,.L101
	li	a4,1
	sll	a5,a4,a5
	andi	a5,a5,1029
	beq	a5,zero,.L101
	call	tpu_set
	lui	a0,%hi(.LC15)
	addi	a0,a0,%lo(.LC15)
	call	tpu_outputstring
	lw	a4,%lo(PARTITION)(s2)
	addi	s1,s0,512
	mv	a1,s1
	lbu	a0,9(a4)
	lbu	a5,8(a4)
	mv	s2,s1
	slli	a0,a0,8
	or	a0,a0,a5
	lbu	a5,10(a4)
	addi	s4,s0,520
	mv	s3,s1
	slli	a5,a5,16
	or	a5,a5,a0
	lbu	a0,11(a4)
	slli	a0,a0,24
	or	a0,a0,a5
	call	sd_readSector
	li	a3,12
	li	a2,64
	li	a1,15
	li	a0,0
	call	tpu_set
	lui	a0,%hi(.LC16)
	addi	a0,a0,%lo(.LC16)
	call	tpu_outputstring
	li	a0,91
	call	tpu_output_character
.L102:
	lbu	a0,3(s3)
	addi	s3,s3,1
	call	tpu_output_character
	bne	s3,s4,.L102
	li	a0,93
	call	tpu_output_character
	li	a0,91
	call	tpu_output_character
	addi	s3,s1,11
.L103:
	lbu	a0,43(s1)
	addi	s1,s1,1
	call	tpu_output_character
	bne	s3,s1,.L103
	li	a0,93
	call	tpu_output_character
	li	a0,91
	call	tpu_output_character
.L104:
	lbu	a0,54(s2)
	addi	s2,s2,1
	call	tpu_output_character
	bne	s2,s4,.L104
	li	a0,93
	call	tpu_output_character
	li	a3,63
	li	a2,64
	li	a1,16
	li	a0,2
	call	tpu_set
	lui	a0,%hi(.LC17)
	addi	a0,a0,%lo(.LC17)
	call	tpu_outputstring
	lbu	a5,524(s0)
	lbu	a0,523(s0)
	lui	s2,%hi(ROOTDIRECTORY)
	slli	a5,a5,8
	or	a0,a5,a0
	call	tpu_outputnumber_short
	lui	a0,%hi(.LC18)
	addi	a0,a0,%lo(.LC18)
	call	tpu_outputstring
	lbu	a0,525(s0)
	li	s1,0
	li	s3,46
	call	tpu_outputnumber_char
	lui	a0,%hi(.LC19)
	addi	a0,a0,%lo(.LC19)
	call	tpu_outputstring
	lw	a0,544(s0)
	lui	s4,%hi(.LC26)
	li	s5,229
	call	tpu_outputnumber_int
	lw	a5,528(s0)
	li	a3,48
	li	a2,64
	srli	a5,a5,8
	slli	a4,a5,16
	srli	a4,a4,16
	li	a5,9437184
	sub	a5,a5,a4
	slli	a5,a5,5
	li	a1,18
	li	a0,0
	sw	a5,%lo(ROOTDIRECTORY)(s2)
	call	tpu_set
	lui	a0,%hi(.LC20)
	addi	a0,a0,%lo(.LC20)
	call	tpu_outputstring
	call	sd_readRootDirectory
	li	a3,12
	li	a2,64
	li	a1,18
	li	a0,0
	call	tpu_set
	lui	a0,%hi(.LC21)
	addi	a0,a0,%lo(.LC21)
	call	tpu_outputstring
	lui	a0,%hi(.LC22)
	addi	a0,a0,%lo(.LC22)
	call	outputstring
	lui	a0,%hi(.LC23)
	addi	a0,a0,%lo(.LC23)
	call	outputstring
	lui	s6,%hi(.LC25)
	li	s7,8
	li	s8,3
.L105:
	lw	a5,528(s0)
	srli	a5,a5,8
	slli	a5,a5,16
	srli	a5,a5,16
	bgtu	a5,s1,.L113
	lui	s0,%hi(UART_STATUS)
.L114:
	lw	a5,%lo(UART_STATUS)(s0)
	lbu	a5,0(a5)
	andi	a5,a5,1
	bne	a5,zero,.L115
	lui	a0,%hi(.LC27)
	addi	a0,a0,%lo(.LC27)
	call	outputstring
	lui	s3,%hi(.LC28)
	lui	s2,%hi(.LC29)
	lui	s1,%hi(LEDS)
.L116:
	call	inputcharacter
	mv	s0,a0
	addi	a0,s3,%lo(.LC28)
	call	outputstringnonl
	mv	a0,s0
	call	outputcharacter
	addi	a0,s2,%lo(.LC29)
	call	outputstring
	lw	a5,%lo(LEDS)(s1)
	sb	s0,0(a5)
	j	.L116
.L101:
	call	tpu_set
	lui	a0,%hi(.LC24)
	addi	a0,a0,%lo(.LC24)
	call	tpu_outputstring
.L106:
	j	.L106
.L113:
	lw	a5,%lo(ROOTDIRECTORY)(s2)
	slli	s9,s1,5
	add	a5,a5,s9
	lbu	a5,0(a5)
	beq	a5,s3,.L107
	beq	a5,s5,.L108
	bne	a5,zero,.L131
.L109:
	addi	s1,s1,1
	slli	s1,s1,16
	srli	s1,s1,16
	j	.L105
.L108:
	addi	a0,s6,%lo(.LC25)
.L134:
	call	outputstringnonl
	j	.L109
.L107:
	addi	a0,s4,%lo(.LC26)
	j	.L134
.L131:
	li	a0,91
	call	outputcharacter
	li	s10,0
.L111:
	lw	a5,%lo(ROOTDIRECTORY)(s2)
	add	a5,a5,s9
	add	a5,a5,s10
	lbu	a0,0(a5)
	addi	s10,s10,1
	call	outputcharacter
	bne	s10,s7,.L111
	li	a0,46
	call	outputcharacter
	li	s10,0
.L112:
	lw	a5,%lo(ROOTDIRECTORY)(s2)
	add	a5,a5,s9
	add	a5,a5,s10
	lbu	a0,8(a5)
	addi	s10,s10,1
	call	outputcharacter
	bne	s10,s8,.L112
	li	a0,91
	call	outputcharacter
	j	.L109
.L115:
	call	inputcharacter
	j	.L114
	.size	main, .-main
	.globl	ROOTDIRECTORY
	.globl	PARTITION
	.globl	BOOTSECTOR
	.globl	MBR
	.globl	VBLANK
	.globl	SLEEPTIMER
	.globl	TIMER1KHZ
	.globl	TIMER1HZ
	.globl	ALT_RNG
	.globl	RNG
	.globl	AUDIO_R_START
	.globl	AUDIO_R_DURATION
	.globl	AUDIO_R_NOTE
	.globl	AUDIO_R_WAVEFORM
	.globl	AUDIO_L_START
	.globl	AUDIO_L_DURATION
	.globl	AUDIO_L_NOTE
	.globl	AUDIO_L_WAVEFORM
	.globl	TPU_COMMIT
	.globl	TPU_FOREGROUND
	.globl	TPU_BACKGROUND
	.globl	TPU_CHARACTER
	.globl	TPU_Y
	.globl	TPU_X
	.globl	UPPER_SPRITE_COLLISION_BASE
	.globl	UPPER_SPRITE_WRITER_BITMAP
	.globl	UPPER_SPRITE_WRITER_LINE
	.globl	UPPER_SPRITE_WRITER_NUMBER
	.globl	UPPER_SPRITE_UPDATE
	.globl	UPPER_SPRITE_DOUBLE
	.globl	UPPER_SPRITE_Y
	.globl	UPPER_SPRITE_X
	.globl	UPPER_SPRITE_COLOUR
	.globl	UPPER_SPRITE_TILE
	.globl	UPPER_SPRITE_ACTIVE
	.globl	UPPER_SPRITE_NUMBER
	.globl	LOWER_SPRITE_COLLISION_BASE
	.globl	LOWER_SPRITE_WRITER_BITMAP
	.globl	LOWER_SPRITE_WRITER_LINE
	.globl	LOWER_SPRITE_WRITER_NUMBER
	.globl	LOWER_SPRITE_UPDATE
	.globl	LOWER_SPRITE_DOUBLE
	.globl	LOWER_SPRITE_Y
	.globl	LOWER_SPRITE_X
	.globl	LOWER_SPRITE_COLOUR
	.globl	LOWER_SPRITE_TILE
	.globl	LOWER_SPRITE_ACTIVE
	.globl	LOWER_SPRITE_NUMBER
	.globl	BITMAP_SCROLLWRAP
	.globl	VECTOR_WRITER_DELTAY
	.globl	VECTOR_WRITER_DELTAX
	.globl	VECTOR_WRITER_ACTIVE
	.globl	VECTOR_WRITER_VERTEX
	.globl	VECTOR_WRITER_BLOCK
	.globl	VECTOR_DRAW_STATUS
	.globl	VECTOR_DRAW_START
	.globl	VECTOR_DRAW_YC
	.globl	VECTOR_DRAW_XC
	.globl	VECTOR_DRAW_COLOUR
	.globl	VECTOR_DRAW_BLOCK
	.globl	GPU_STATUS
	.globl	GPU_WRITE
	.globl	GPU_PARAM3
	.globl	GPU_PARAM2
	.globl	GPU_PARAM1
	.globl	GPU_PARAM0
	.globl	GPU_COLOUR
	.globl	GPU_Y
	.globl	GPU_X
	.globl	TM_STATUS
	.globl	TM_SCROLLWRAPCLEAR
	.globl	TM_WRITER_BITMAP
	.globl	TM_WRITER_LINE_NUMBER
	.globl	TM_WRITER_TILE_NUMBER
	.globl	TM_COMMIT
	.globl	TM_FOREGROUND
	.globl	TM_BACKGROUND
	.globl	TM_TILE
	.globl	TM_Y
	.globl	TM_X
	.globl	BACKGROUND_MODE
	.globl	BACKGROUND_ALTCOLOUR
	.globl	BACKGROUND_COLOUR
	.globl	TERMINAL_STATUS
	.globl	TERMINAL_SHOWHIDE
	.globl	TERMINAL_OUTPUT
	.globl	SDCARD_DATA
	.globl	SDCARD_ADDRESS
	.globl	SDCARD_SECTOR_HIGH
	.globl	SDCARD_SECTOR_LOW
	.globl	SDCARD_START
	.globl	SDCARD_READY
	.globl	LEDS
	.globl	BUTTONS
	.globl	UART_DATA
	.globl	UART_STATUS
	.bss
	.align	2
	.set	.LANCHOR0,. + 0
	.type	MBR, @object
	.size	MBR, 512
MBR:
	.zero	512
	.type	BOOTSECTOR, @object
	.size	BOOTSECTOR, 512
BOOTSECTOR:
	.zero	512
	.section	.sbss,"aw",@nobits
	.align	2
	.type	ROOTDIRECTORY, @object
	.size	ROOTDIRECTORY, 4
ROOTDIRECTORY:
	.zero	4
	.type	PARTITION, @object
	.size	PARTITION, 4
PARTITION:
	.zero	4
	.section	.sdata,"aw"
	.align	2
	.type	VBLANK, @object
	.size	VBLANK, 4
VBLANK:
	.word	36848
	.type	SLEEPTIMER, @object
	.size	SLEEPTIMER, 4
SLEEPTIMER:
	.word	35120
	.type	TIMER1KHZ, @object
	.size	TIMER1KHZ, 4
TIMER1KHZ:
	.word	35104
	.type	TIMER1HZ, @object
	.size	TIMER1HZ, 4
TIMER1HZ:
	.word	35088
	.type	ALT_RNG, @object
	.size	ALT_RNG, 4
ALT_RNG:
	.word	35076
	.type	RNG, @object
	.size	RNG, 4
RNG:
	.word	35072
	.type	AUDIO_R_START, @object
	.size	AUDIO_R_START, 4
AUDIO_R_START:
	.word	34844
	.type	AUDIO_R_DURATION, @object
	.size	AUDIO_R_DURATION, 4
AUDIO_R_DURATION:
	.word	34840
	.type	AUDIO_R_NOTE, @object
	.size	AUDIO_R_NOTE, 4
AUDIO_R_NOTE:
	.word	34836
	.type	AUDIO_R_WAVEFORM, @object
	.size	AUDIO_R_WAVEFORM, 4
AUDIO_R_WAVEFORM:
	.word	34832
	.type	AUDIO_L_START, @object
	.size	AUDIO_L_START, 4
AUDIO_L_START:
	.word	34828
	.type	AUDIO_L_DURATION, @object
	.size	AUDIO_L_DURATION, 4
AUDIO_L_DURATION:
	.word	34824
	.type	AUDIO_L_NOTE, @object
	.size	AUDIO_L_NOTE, 4
AUDIO_L_NOTE:
	.word	34820
	.type	AUDIO_L_WAVEFORM, @object
	.size	AUDIO_L_WAVEFORM, 4
AUDIO_L_WAVEFORM:
	.word	34816
	.type	TPU_COMMIT, @object
	.size	TPU_COMMIT, 4
TPU_COMMIT:
	.word	34324
	.type	TPU_FOREGROUND, @object
	.size	TPU_FOREGROUND, 4
TPU_FOREGROUND:
	.word	34320
	.type	TPU_BACKGROUND, @object
	.size	TPU_BACKGROUND, 4
TPU_BACKGROUND:
	.word	34316
	.type	TPU_CHARACTER, @object
	.size	TPU_CHARACTER, 4
TPU_CHARACTER:
	.word	34312
	.type	TPU_Y, @object
	.size	TPU_Y, 4
TPU_Y:
	.word	34308
	.type	TPU_X, @object
	.size	TPU_X, 4
TPU_X:
	.word	34304
	.type	UPPER_SPRITE_COLLISION_BASE, @object
	.size	UPPER_SPRITE_COLLISION_BASE, 4
UPPER_SPRITE_COLLISION_BASE:
	.word	34096
	.type	UPPER_SPRITE_WRITER_BITMAP, @object
	.size	UPPER_SPRITE_WRITER_BITMAP, 4
UPPER_SPRITE_WRITER_BITMAP:
	.word	34088
	.type	UPPER_SPRITE_WRITER_LINE, @object
	.size	UPPER_SPRITE_WRITER_LINE, 4
UPPER_SPRITE_WRITER_LINE:
	.word	34084
	.type	UPPER_SPRITE_WRITER_NUMBER, @object
	.size	UPPER_SPRITE_WRITER_NUMBER, 4
UPPER_SPRITE_WRITER_NUMBER:
	.word	34080
	.type	UPPER_SPRITE_UPDATE, @object
	.size	UPPER_SPRITE_UPDATE, 4
UPPER_SPRITE_UPDATE:
	.word	34076
	.type	UPPER_SPRITE_DOUBLE, @object
	.size	UPPER_SPRITE_DOUBLE, 4
UPPER_SPRITE_DOUBLE:
	.word	34072
	.type	UPPER_SPRITE_Y, @object
	.size	UPPER_SPRITE_Y, 4
UPPER_SPRITE_Y:
	.word	34068
	.type	UPPER_SPRITE_X, @object
	.size	UPPER_SPRITE_X, 4
UPPER_SPRITE_X:
	.word	34064
	.type	UPPER_SPRITE_COLOUR, @object
	.size	UPPER_SPRITE_COLOUR, 4
UPPER_SPRITE_COLOUR:
	.word	34060
	.type	UPPER_SPRITE_TILE, @object
	.size	UPPER_SPRITE_TILE, 4
UPPER_SPRITE_TILE:
	.word	34056
	.type	UPPER_SPRITE_ACTIVE, @object
	.size	UPPER_SPRITE_ACTIVE, 4
UPPER_SPRITE_ACTIVE:
	.word	34052
	.type	UPPER_SPRITE_NUMBER, @object
	.size	UPPER_SPRITE_NUMBER, 4
UPPER_SPRITE_NUMBER:
	.word	34048
	.type	LOWER_SPRITE_COLLISION_BASE, @object
	.size	LOWER_SPRITE_COLLISION_BASE, 4
LOWER_SPRITE_COLLISION_BASE:
	.word	33584
	.type	LOWER_SPRITE_WRITER_BITMAP, @object
	.size	LOWER_SPRITE_WRITER_BITMAP, 4
LOWER_SPRITE_WRITER_BITMAP:
	.word	33576
	.type	LOWER_SPRITE_WRITER_LINE, @object
	.size	LOWER_SPRITE_WRITER_LINE, 4
LOWER_SPRITE_WRITER_LINE:
	.word	33572
	.type	LOWER_SPRITE_WRITER_NUMBER, @object
	.size	LOWER_SPRITE_WRITER_NUMBER, 4
LOWER_SPRITE_WRITER_NUMBER:
	.word	33568
	.type	LOWER_SPRITE_UPDATE, @object
	.size	LOWER_SPRITE_UPDATE, 4
LOWER_SPRITE_UPDATE:
	.word	33564
	.type	LOWER_SPRITE_DOUBLE, @object
	.size	LOWER_SPRITE_DOUBLE, 4
LOWER_SPRITE_DOUBLE:
	.word	33560
	.type	LOWER_SPRITE_Y, @object
	.size	LOWER_SPRITE_Y, 4
LOWER_SPRITE_Y:
	.word	33556
	.type	LOWER_SPRITE_X, @object
	.size	LOWER_SPRITE_X, 4
LOWER_SPRITE_X:
	.word	33552
	.type	LOWER_SPRITE_COLOUR, @object
	.size	LOWER_SPRITE_COLOUR, 4
LOWER_SPRITE_COLOUR:
	.word	33548
	.type	LOWER_SPRITE_TILE, @object
	.size	LOWER_SPRITE_TILE, 4
LOWER_SPRITE_TILE:
	.word	33544
	.type	LOWER_SPRITE_ACTIVE, @object
	.size	LOWER_SPRITE_ACTIVE, 4
LOWER_SPRITE_ACTIVE:
	.word	33540
	.type	LOWER_SPRITE_NUMBER, @object
	.size	LOWER_SPRITE_NUMBER, 4
LOWER_SPRITE_NUMBER:
	.word	33536
	.type	BITMAP_SCROLLWRAP, @object
	.size	BITMAP_SCROLLWRAP, 4
BITMAP_SCROLLWRAP:
	.word	33888
	.type	VECTOR_WRITER_DELTAY, @object
	.size	VECTOR_WRITER_DELTAY, 4
VECTOR_WRITER_DELTAY:
	.word	33856
	.type	VECTOR_WRITER_DELTAX, @object
	.size	VECTOR_WRITER_DELTAX, 4
VECTOR_WRITER_DELTAX:
	.word	33852
	.type	VECTOR_WRITER_ACTIVE, @object
	.size	VECTOR_WRITER_ACTIVE, 4
VECTOR_WRITER_ACTIVE:
	.word	33860
	.type	VECTOR_WRITER_VERTEX, @object
	.size	VECTOR_WRITER_VERTEX, 4
VECTOR_WRITER_VERTEX:
	.word	33848
	.type	VECTOR_WRITER_BLOCK, @object
	.size	VECTOR_WRITER_BLOCK, 4
VECTOR_WRITER_BLOCK:
	.word	33844
	.type	VECTOR_DRAW_STATUS, @object
	.size	VECTOR_DRAW_STATUS, 4
VECTOR_DRAW_STATUS:
	.word	33864
	.type	VECTOR_DRAW_START, @object
	.size	VECTOR_DRAW_START, 4
VECTOR_DRAW_START:
	.word	33840
	.type	VECTOR_DRAW_YC, @object
	.size	VECTOR_DRAW_YC, 4
VECTOR_DRAW_YC:
	.word	33836
	.type	VECTOR_DRAW_XC, @object
	.size	VECTOR_DRAW_XC, 4
VECTOR_DRAW_XC:
	.word	33832
	.type	VECTOR_DRAW_COLOUR, @object
	.size	VECTOR_DRAW_COLOUR, 4
VECTOR_DRAW_COLOUR:
	.word	33828
	.type	VECTOR_DRAW_BLOCK, @object
	.size	VECTOR_DRAW_BLOCK, 4
VECTOR_DRAW_BLOCK:
	.word	33824
	.type	GPU_STATUS, @object
	.size	GPU_STATUS, 4
GPU_STATUS:
	.word	33820
	.type	GPU_WRITE, @object
	.size	GPU_WRITE, 4
GPU_WRITE:
	.word	33820
	.type	GPU_PARAM3, @object
	.size	GPU_PARAM3, 4
GPU_PARAM3:
	.word	33816
	.type	GPU_PARAM2, @object
	.size	GPU_PARAM2, 4
GPU_PARAM2:
	.word	33812
	.type	GPU_PARAM1, @object
	.size	GPU_PARAM1, 4
GPU_PARAM1:
	.word	33808
	.type	GPU_PARAM0, @object
	.size	GPU_PARAM0, 4
GPU_PARAM0:
	.word	33804
	.type	GPU_COLOUR, @object
	.size	GPU_COLOUR, 4
GPU_COLOUR:
	.word	33800
	.type	GPU_Y, @object
	.size	GPU_Y, 4
GPU_Y:
	.word	33796
	.type	GPU_X, @object
	.size	GPU_X, 4
GPU_X:
	.word	33792
	.type	TM_STATUS, @object
	.size	TM_STATUS, 4
TM_STATUS:
	.word	33332
	.type	TM_SCROLLWRAPCLEAR, @object
	.size	TM_SCROLLWRAPCLEAR, 4
TM_SCROLLWRAPCLEAR:
	.word	33328
	.type	TM_WRITER_BITMAP, @object
	.size	TM_WRITER_BITMAP, 4
TM_WRITER_BITMAP:
	.word	33320
	.type	TM_WRITER_LINE_NUMBER, @object
	.size	TM_WRITER_LINE_NUMBER, 4
TM_WRITER_LINE_NUMBER:
	.word	33316
	.type	TM_WRITER_TILE_NUMBER, @object
	.size	TM_WRITER_TILE_NUMBER, 4
TM_WRITER_TILE_NUMBER:
	.word	33312
	.type	TM_COMMIT, @object
	.size	TM_COMMIT, 4
TM_COMMIT:
	.word	33300
	.type	TM_FOREGROUND, @object
	.size	TM_FOREGROUND, 4
TM_FOREGROUND:
	.word	33296
	.type	TM_BACKGROUND, @object
	.size	TM_BACKGROUND, 4
TM_BACKGROUND:
	.word	33292
	.type	TM_TILE, @object
	.size	TM_TILE, 4
TM_TILE:
	.word	33288
	.type	TM_Y, @object
	.size	TM_Y, 4
TM_Y:
	.word	33284
	.type	TM_X, @object
	.size	TM_X, 4
TM_X:
	.word	33280
	.type	BACKGROUND_MODE, @object
	.size	BACKGROUND_MODE, 4
BACKGROUND_MODE:
	.word	33032
	.type	BACKGROUND_ALTCOLOUR, @object
	.size	BACKGROUND_ALTCOLOUR, 4
BACKGROUND_ALTCOLOUR:
	.word	33028
	.type	BACKGROUND_COLOUR, @object
	.size	BACKGROUND_COLOUR, 4
BACKGROUND_COLOUR:
	.word	33024
	.type	TERMINAL_STATUS, @object
	.size	TERMINAL_STATUS, 4
TERMINAL_STATUS:
	.word	34560
	.type	TERMINAL_SHOWHIDE, @object
	.size	TERMINAL_SHOWHIDE, 4
TERMINAL_SHOWHIDE:
	.word	34564
	.type	TERMINAL_OUTPUT, @object
	.size	TERMINAL_OUTPUT, 4
TERMINAL_OUTPUT:
	.word	34560
	.type	SDCARD_DATA, @object
	.size	SDCARD_DATA, 4
SDCARD_DATA:
	.word	36624
	.type	SDCARD_ADDRESS, @object
	.size	SDCARD_ADDRESS, 4
SDCARD_ADDRESS:
	.word	36624
	.type	SDCARD_SECTOR_HIGH, @object
	.size	SDCARD_SECTOR_HIGH, 4
SDCARD_SECTOR_HIGH:
	.word	36612
	.type	SDCARD_SECTOR_LOW, @object
	.size	SDCARD_SECTOR_LOW, 4
SDCARD_SECTOR_LOW:
	.word	36616
	.type	SDCARD_START, @object
	.size	SDCARD_START, 4
SDCARD_START:
	.word	36608
	.type	SDCARD_READY, @object
	.size	SDCARD_READY, 4
SDCARD_READY:
	.word	36608
	.type	LEDS, @object
	.size	LEDS, 4
LEDS:
	.word	32780
	.type	BUTTONS, @object
	.size	BUTTONS, 4
BUTTONS:
	.word	32776
	.type	UART_DATA, @object
	.size	UART_DATA, 4
UART_DATA:
	.word	32768
	.type	UART_STATUS, @object
	.size	UART_STATUS, 4
UART_STATUS:
	.word	32772
	.ident	"GCC: (Arch Linux Repositories) 10.2.0"
