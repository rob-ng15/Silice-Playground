	.file	"BIOS.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"Reading Sector: "
	.align	2
.LC1:
	.string	"Sector Read   : "
	.text
	.align	1
	.globl	sd_readSector
	.type	sd_readSector, @function
sd_readSector:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s1,4(sp)
	sw	s2,0(sp)
	mv	s0,a0
	mv	s1,a1
	li	a3,48
	li	a2,64
	li	a1,0
	li	a0,48
	call	tpu_set
	lui	a0,%hi(.LC0)
	addi	a0,a0,%lo(.LC0)
	call	tpu_outputstring
	slli	s2,s0,16
	srli	s2,s2,16
	mv	a0,s2
	call	tpu_outputnumber_int
	li	a4,1
	li	a3,2
	li	a2,0
	li	a1,608
	li	a0,48
	call	gpu_blit
	mv	a1,s1
	mv	a0,s0
	call	sdcard_readsector
	li	a3,12
	li	a2,64
	li	a1,0
	li	a0,48
	call	tpu_set
	lui	a0,%hi(.LC1)
	addi	a0,a0,%lo(.LC1)
	call	tpu_outputstring
	mv	a0,s2
	call	tpu_outputnumber_int
	li	a4,1
	li	a3,2
	li	a2,0
	li	a1,608
	li	a0,12
	call	gpu_blit
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	lw	s2,0(sp)
	addi	sp,sp,16
	jr	ra
	.size	sd_readSector, .-sd_readSector
	.align	1
	.globl	sd_readMBR
	.type	sd_readMBR, @function
sd_readMBR:
	addi	sp,sp,-16
	sw	ra,12(sp)
	lui	a1,%hi(.LANCHOR0)
	addi	a1,a1,%lo(.LANCHOR0)
	li	a0,0
	call	sd_readSector
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	sd_readMBR, .-sd_readMBR
	.align	1
	.globl	sd_readFAT
	.type	sd_readFAT, @function
sd_readFAT:
	lui	a5,%hi(.LANCHOR0+534)
	lhu	a2,%lo(.LANCHOR0+534)(a5)
	beq	a2,zero,.L10
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	li	s0,0
	lui	s3,%hi(FAT)
	lui	s2,%hi(PARTITION)
	lui	s1,%hi(.LANCHOR0)
	addi	s1,s1,%lo(.LANCHOR0)
.L7:
	slli	a1,s0,9
	lw	a6,%lo(FAT)(s3)
	lw	a3,%lo(PARTITION)(s2)
	lbu	a4,8(a3)
	lbu	a5,9(a3)
	slli	a5,a5,8
	or	a4,a5,a4
	lbu	a5,10(a3)
	slli	a0,a5,16
	or	a5,a0,a4
	lbu	a0,11(a3)
	slli	a0,a0,24
	or	a0,a0,a5
	lhu	a5,526(s1)
	add	a0,a0,a5
	add	a0,a0,a2
	add	a1,a6,a1
	add	a0,a0,s0
	call	sd_readSector
	addi	s0,s0,1
	slli	s0,s0,16
	srli	s0,s0,16
	lhu	a2,534(s1)
	bgtu	a2,s0,.L7
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	addi	sp,sp,32
	jr	ra
.L10:
	ret
	.size	sd_readFAT, .-sd_readFAT
	.align	1
	.globl	sd_readRootDirectory
	.type	sd_readRootDirectory, @function
sd_readRootDirectory:
	lui	a5,%hi(.LANCHOR0+528)
	lw	a5,%lo(.LANCHOR0+528)(a5)
	srli	a5,a5,8
	slli	a5,a5,16
	srli	a5,a5,16
	slli	a5,a5,5
	li	a4,511
	bleu	a5,a4,.L18
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	li	s0,0
	li	a0,0
	lui	s3,%hi(ROOTDIRECTORY)
	lui	s2,%hi(PARTITION)
	lui	s1,%hi(.LANCHOR0)
	addi	s1,s1,%lo(.LANCHOR0)
.L15:
	slli	a2,s0,9
	lw	a1,%lo(ROOTDIRECTORY)(s3)
	lw	a3,%lo(PARTITION)(s2)
	lbu	a5,8(a3)
	lbu	a4,9(a3)
	slli	a4,a4,8
	or	a4,a4,a5
	lbu	a5,10(a3)
	slli	a5,a5,16
	or	a4,a5,a4
	lbu	a5,11(a3)
	slli	a5,a5,24
	or	a5,a5,a4
	lhu	a4,526(s1)
	add	a5,a5,a4
	lhu	a4,534(s1)
	lbu	a3,528(s1)
	mul	a4,a4,a3
	add	a5,a5,a4
	add	a1,a1,a2
	add	a0,a5,a0
	call	sd_readSector
	addi	s0,s0,1
	slli	s0,s0,16
	srli	s0,s0,16
	mv	a0,s0
	lw	a5,528(s1)
	slli	a5,a5,8
	srli	a5,a5,20
	bltu	s0,a5,.L15
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	addi	sp,sp,32
	jr	ra
.L18:
	ret
	.size	sd_readRootDirectory, .-sd_readRootDirectory
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
	.align	1
	.globl	set_sdcard_bitmap
	.type	set_sdcard_bitmap, @function
set_sdcard_bitmap:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	lui	a1,%hi(.LANCHOR1)
	addi	s0,a1,%lo(.LANCHOR1)
	addi	a1,a1,%lo(.LANCHOR1)
	li	a0,0
	call	set_blitter_bitmap
	addi	a1,s0,32
	li	a0,1
	call	set_blitter_bitmap
	addi	a1,s0,64
	li	a0,2
	call	set_blitter_bitmap
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	set_sdcard_bitmap, .-set_sdcard_bitmap
	.align	1
	.globl	draw_sdcard
	.type	draw_sdcard, @function
draw_sdcard:
	addi	sp,sp,-16
	sw	ra,12(sp)
	li	a4,1
	li	a3,1
	li	a2,0
	li	a1,608
	li	a0,3
	call	gpu_blit
	li	a4,1
	li	a3,0
	li	a2,0
	li	a1,608
	li	a0,63
	call	gpu_blit
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	draw_sdcard, .-draw_sdcard
	.section	.rodata.str1.4
	.align	2
.LC2:
	.string	"Memory Dump"
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
	sw	s4,8(sp)
	sw	s5,4(sp)
	sw	s6,0(sp)
	mv	s5,a0
	mv	s0,a1
	lui	a0,%hi(.LC2)
	addi	a0,a0,%lo(.LC2)
	call	outputstring
	srli	a5,s0,4
	beq	a5,zero,.L27
	addi	s2,s5,16
	slli	a5,a5,4
	add	s6,s5,a5
	li	s3,95
	li	s4,46
	j	.L31
.L29:
	call	outputcharacter
	li	a0,32
	call	outputcharacter
	mv	a0,s1
	call	outputnumber_char
	addi	s0,s0,1
	beq	s0,s2,.L36
.L30:
	lbu	s1,0(s0)
	li	a0,32
	call	outputcharacter
	addi	a5,s1,-32
	andi	a5,a5,0xff
	mv	a0,s1
	bleu	a5,s3,.L29
	mv	a0,s4
	j	.L29
.L36:
	addi	s5,s5,16
	li	a0,100
	call	sleep
	li	a0,10
	call	outputcharacter
	addi	s2,s2,16
	beq	s6,s5,.L27
.L31:
	mv	a0,s5
	call	outputnumber_int
	li	a0,58
	call	outputcharacter
	li	a0,32
	call	outputcharacter
	mv	s0,s5
	j	.L30
.L27:
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
	.size	memorydump, .-memorydump
	.section	.rodata.str1.4
	.align	2
.LC3:
	.string	"Welcome to PAWS a RISC-V RV32IMC CPU"
	.align	2
.LC4:
	.string	"Waiting for SDCARD"
	.align	2
.LC5:
	.string	"Reading Master Boot Record"
	.align	2
.LC6:
	.string	"Read Master Boot Record"
	.align	2
.LC7:
	.string	"Partition : "
	.align	2
.LC8:
	.string	", Type : "
	.align	2
.LC9:
	.string	" No Entry"
	.align	2
.LC10:
	.string	" FAT16 <32MB"
	.align	2
.LC11:
	.string	" FAT16 >32MB"
	.align	2
.LC12:
	.string	" FAT16 LBA"
	.align	2
.LC13:
	.string	" Not FAT16"
	.align	2
.LC14:
	.string	"ERROR: PLEASE INSERT A VALID FAT16 FORMATTED SDCARD AND PRESS RESET"
	.align	2
.LC15:
	.string	"Reading Partition 0 Boot Sector"
	.align	2
.LC16:
	.string	"Read Partition 0 Boot Sector "
	.align	2
.LC17:
	.string	"Sector Size: "
	.align	2
.LC18:
	.string	" Cluster Size: "
	.align	2
.LC19:
	.string	" FATs: "
	.align	2
.LC20:
	.string	" sectors long"
	.align	2
.LC21:
	.string	"Directory Entries: "
	.align	2
.LC22:
	.string	" Total Sectors: "
	.align	2
.LC23:
	.string	"Reading Root Directory"
	.align	2
.LC24:
	.string	"Read Root Directory "
	.align	2
.LC25:
	.string	"\n\n\n\n\n\n\n\nRISC-ICE-V BIOS"
	.align	2
.LC26:
	.string	"> ls *.PAW"
	.align	2
.LC27:
	.string	"Reading File Allocation Table"
	.align	2
.LC28:
	.string	"Read File Allocation Table"
	.align	2
.LC29:
	.string	"\nSDRAM from ROOTDIRECTORY"
	.align	2
.LC30:
	.string	"\nSDCARD from ROOTDIRECTORY"
	.align	2
.LC31:
	.string	"\nSDRAM from FAT"
	.align	2
.LC32:
	.string	"\nTerminal Echo Starting"
	.align	2
.LC33:
	.string	"You pressed : "
	.align	2
.LC34:
	.string	" <-"
	.text
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
	call	terminal_reset
	call	gpu_cs
	call	tpu_cs
	li	a2,0
	li	a1,0
	li	a0,1
	call	set_background
	call	draw_riscv_logo
	call	set_sdcard_bitmap
	call	draw_sdcard
	li	a3,63
	li	a2,64
	li	a1,5
	li	a0,16
	call	tpu_set
	lui	a0,%hi(.LC3)
	addi	a0,a0,%lo(.LC3)
	call	tpu_outputstring
	lui	a3,%hi(.LC4)
	addi	a3,a3,%lo(.LC4)
	li	a2,48
	li	a1,64
	li	a0,7
	call	tpu_outputstringcentre
	li	a0,4096
	addi	a0,a0,-96
	call	sleep
	lui	a3,%hi(.LC5)
	addi	a3,a3,%lo(.LC5)
	li	a2,48
	li	a1,64
	li	a0,7
	call	tpu_outputstringcentre
	lui	a1,%hi(.LANCHOR0)
	addi	s0,a1,%lo(.LANCHOR0)
	addi	a1,a1,%lo(.LANCHOR0)
	li	a0,0
	call	sd_readSector
	lui	a3,%hi(.LC6)
	addi	a3,a3,%lo(.LC6)
	li	a2,12
	li	a1,64
	li	a0,7
	call	tpu_outputstringcentre
	addi	s0,s0,446
	lui	a5,%hi(PARTITION)
	sw	s0,%lo(PARTITION)(a5)
	li	s0,0
	lui	s4,%hi(.LC7)
	lui	s3,%hi(.LC8)
	mv	s2,a5
	lui	s9,%hi(.LC11)
	lui	s8,%hi(.LC13)
	lui	s7,%hi(.LC12)
	lui	s6,%hi(.LC9)
	lui	s5,%hi(.LC10)
	j	.L45
.L39:
	li	a4,14
	bne	a5,a4,.L42
	addi	a0,s7,%lo(.LC12)
	call	tpu_outputstring
	j	.L44
.L40:
	addi	a0,s6,%lo(.LC9)
	call	tpu_outputstring
.L44:
	addi	s0,s0,1
	li	a5,4
	beq	s0,a5,.L68
.L45:
	addi	a1,s0,9
	li	a3,63
	li	a2,64
	andi	a1,a1,0xff
	li	a0,2
	call	tpu_set
	addi	a0,s4,%lo(.LC7)
	call	tpu_outputstring
	slli	a0,s0,16
	srli	a0,a0,16
	call	tpu_outputnumber_short
	addi	a0,s3,%lo(.LC8)
	call	tpu_outputstring
	slli	s1,s0,4
	lw	a5,%lo(PARTITION)(s2)
	add	a5,a5,s1
	lbu	a0,4(a5)
	call	tpu_outputnumber_char
	lw	a5,%lo(PARTITION)(s2)
	add	s1,a5,s1
	lbu	a5,4(s1)
	li	a4,6
	beq	a5,a4,.L38
	bgtu	a5,a4,.L39
	beq	a5,zero,.L40
	li	a4,4
	bne	a5,a4,.L42
	addi	a0,s5,%lo(.LC10)
	call	tpu_outputstring
	j	.L44
.L38:
	addi	a0,s9,%lo(.LC11)
	call	tpu_outputstring
	j	.L44
.L42:
	addi	a0,s8,%lo(.LC13)
	call	tpu_outputstring
	j	.L44
.L68:
	lui	a5,%hi(PARTITION)
	lw	a5,%lo(PARTITION)(a5)
	lbu	a5,4(a5)
	addi	a5,a5,-4
	andi	a5,a5,0xff
	li	a4,10
	bgtu	a5,a4,.L46
	li	a4,1
	sll	a5,a4,a5
	andi	a5,a5,1029
	bne	a5,zero,.L47
.L46:
	lui	a3,%hi(.LC14)
	addi	a3,a3,%lo(.LC14)
	li	a2,48
	li	a1,64
	li	a0,15
	call	tpu_outputstringcentre
.L48:
	j	.L48
.L47:
	lui	a3,%hi(.LC15)
	addi	a3,a3,%lo(.LC15)
	li	a2,48
	li	a1,64
	li	a0,15
	call	tpu_outputstringcentre
	lui	s2,%hi(.LANCHOR0)
	addi	s2,s2,%lo(.LANCHOR0)
	addi	s3,s2,512
	lui	a5,%hi(PARTITION)
	lw	a3,%lo(PARTITION)(a5)
	lbu	a4,8(a3)
	lbu	a5,9(a3)
	slli	a5,a5,8
	or	a4,a5,a4
	lbu	a5,10(a3)
	slli	a5,a5,16
	or	a5,a5,a4
	lbu	a0,11(a3)
	slli	a0,a0,24
	mv	a1,s3
	or	a0,a0,a5
	call	sd_readSector
	lui	a3,%hi(.LC16)
	addi	a3,a3,%lo(.LC16)
	li	a2,12
	li	a1,64
	li	a0,15
	call	tpu_outputstringcentre
	li	a3,63
	li	a2,64
	li	a1,16
	li	a0,0
	call	tpu_set
	li	a0,91
	call	tpu_output_character
	mv	s1,s3
	addi	s2,s2,520
	mv	s0,s3
.L49:
	lbu	a0,3(s0)
	call	tpu_output_character
	addi	s0,s0,1
	bne	s0,s2,.L49
	li	a0,93
	call	tpu_output_character
	li	a0,91
	call	tpu_output_character
	lui	s0,%hi(.LANCHOR0+555)
	addi	s0,s0,%lo(.LANCHOR0+555)
	addi	s3,s3,54
.L50:
	lbu	a0,0(s0)
	call	tpu_output_character
	addi	s0,s0,1
	bne	s0,s3,.L50
	li	a0,93
	call	tpu_output_character
	li	a0,91
	call	tpu_output_character
.L51:
	lbu	a0,54(s1)
	call	tpu_output_character
	addi	s1,s1,1
	bne	s1,s2,.L51
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
	lui	s0,%hi(.LANCHOR0)
	addi	s0,s0,%lo(.LANCHOR0)
	lbu	a0,523(s0)
	lbu	a5,524(s0)
	slli	a5,a5,8
	or	a0,a5,a0
	call	tpu_outputnumber_short
	lui	a0,%hi(.LC18)
	addi	a0,a0,%lo(.LC18)
	call	tpu_outputstring
	lbu	a0,525(s0)
	call	tpu_outputnumber_char
	lui	a0,%hi(.LC19)
	addi	a0,a0,%lo(.LC19)
	call	tpu_outputstring
	lbu	a0,528(s0)
	call	tpu_outputnumber_char
	lhu	a0,534(s0)
	call	tpu_outputnumber_short
	lui	a0,%hi(.LC20)
	addi	a0,a0,%lo(.LC20)
	call	tpu_outputstring
	li	a3,63
	li	a2,64
	li	a1,17
	li	a0,2
	call	tpu_set
	lui	a0,%hi(.LC21)
	addi	a0,a0,%lo(.LC21)
	call	tpu_outputstring
	lw	a0,528(s0)
	srli	a0,a0,8
	slli	a0,a0,16
	srli	a0,a0,16
	call	tpu_outputnumber_short
	lui	a0,%hi(.LC22)
	addi	a0,a0,%lo(.LC22)
	call	tpu_outputstring
	lw	a0,544(s0)
	call	tpu_outputnumber_int
	lui	a3,%hi(.LC23)
	addi	a3,a3,%lo(.LC23)
	li	a2,48
	li	a1,64
	li	a0,19
	call	tpu_outputstringcentre
	lw	a5,528(s0)
	srli	a5,a5,8
	slli	a4,a5,16
	srli	a4,a4,16
	li	a5,9437184
	sub	a5,a5,a4
	slli	a5,a5,5
	lui	a4,%hi(ROOTDIRECTORY)
	sw	a5,%lo(ROOTDIRECTORY)(a4)
	call	sd_readRootDirectory
	lui	a3,%hi(.LC24)
	addi	a3,a3,%lo(.LC24)
	li	a2,12
	li	a1,64
	li	a0,19
	call	tpu_outputstringcentre
	lui	a0,%hi(.LC25)
	addi	a0,a0,%lo(.LC25)
	call	outputstring
	lui	a0,%hi(.LC26)
	addi	a0,a0,%lo(.LC26)
	call	outputstring
	lw	a5,528(s0)
	srli	a5,a5,8
	slli	a5,a5,16
	srli	a5,a5,16
	beq	a5,zero,.L52
	li	s0,0
	lui	s2,%hi(ROOTDIRECTORY)
	li	s3,80
	li	s4,65
	li	s5,87
	li	s6,46
	li	s8,229
	li	s7,8
	lui	s1,%hi(.LANCHOR0)
	addi	s1,s1,%lo(.LANCHOR0)
	j	.L56
.L53:
	addi	s0,s0,1
	slli	s0,s0,16
	srli	s0,s0,16
	lw	a5,528(s1)
	srli	a5,a5,8
	slli	a5,a5,16
	srli	a5,a5,16
	bleu	a5,s0,.L52
.L56:
	slli	s9,s0,5
	lw	a5,%lo(ROOTDIRECTORY)(s2)
	add	a5,a5,s9
	lbu	a4,8(a5)
	bne	a4,s3,.L53
	lbu	a4,9(a5)
	bne	a4,s4,.L53
	lbu	a4,10(a5)
	bne	a4,s5,.L53
	lbu	a5,0(a5)
	beq	a5,s6,.L53
	beq	a5,s8,.L53
	beq	a5,zero,.L53
	li	a0,91
	call	outputcharacter
	li	s10,0
.L54:
	lw	a5,%lo(ROOTDIRECTORY)(s2)
	add	a5,a5,s9
	add	a5,a5,s10
	lbu	a0,0(a5)
	call	outputcharacter
	addi	s10,s10,1
	bne	s10,s7,.L54
	mv	a0,s6
	call	outputcharacter
	li	s10,0
	li	s11,3
.L55:
	lw	a5,%lo(ROOTDIRECTORY)(s2)
	add	a5,a5,s9
	add	a5,a5,s10
	lbu	a0,8(a5)
	call	outputcharacter
	addi	s10,s10,1
	bne	s10,s11,.L55
	li	a0,93
	call	outputcharacter
	j	.L53
.L52:
	lui	a3,%hi(.LC27)
	addi	a3,a3,%lo(.LC27)
	li	a2,48
	li	a1,64
	li	a0,19
	call	tpu_outputstringcentre
	lui	s1,%hi(FAT)
	lui	s2,%hi(ROOTDIRECTORY)
	lui	s0,%hi(.LANCHOR0)
	addi	s0,s0,%lo(.LANCHOR0)
	lhu	a5,534(s0)
	slli	a4,a5,10
	lw	a5,%lo(ROOTDIRECTORY)(s2)
	sub	a5,a5,a4
	sw	a5,%lo(FAT)(s1)
	call	sd_readFAT
	lui	a3,%hi(.LC28)
	addi	a3,a3,%lo(.LC28)
	li	a2,12
	li	a1,64
	li	a0,19
	call	tpu_outputstringcentre
	lui	a0,%hi(.LC29)
	addi	a0,a0,%lo(.LC29)
	call	outputstring
	li	a1,512
	lw	a0,%lo(ROOTDIRECTORY)(s2)
	call	memorydump
	lui	a0,%hi(.LC30)
	addi	a0,a0,%lo(.LC30)
	call	outputstring
	addi	s2,s0,1024
	lui	a5,%hi(PARTITION)
	lw	a3,%lo(PARTITION)(a5)
	lbu	a5,8(a3)
	lbu	a4,9(a3)
	slli	a4,a4,8
	or	a4,a4,a5
	lbu	a5,10(a3)
	slli	a5,a5,16
	or	a4,a5,a4
	lbu	a5,11(a3)
	slli	a5,a5,24
	or	a5,a5,a4
	lhu	a4,526(s0)
	add	a5,a5,a4
	lhu	a0,534(s0)
	lbu	a4,528(s0)
	mul	a0,a0,a4
	mv	a1,s2
	add	a0,a5,a0
	call	sd_readSector
	li	a1,512
	mv	a0,s2
	call	memorydump
	lui	a0,%hi(.LC31)
	addi	a0,a0,%lo(.LC31)
	call	outputstring
	li	a1,512
	lw	a0,%lo(FAT)(s1)
	call	memorydump
	j	.L57
.L58:
	call	inputcharacter
.L57:
	call	inputcharacter_available
	bne	a0,zero,.L58
	lui	a0,%hi(.LC32)
	addi	a0,a0,%lo(.LC32)
	call	outputstring
	lui	s2,%hi(.LC33)
	lui	s1,%hi(.LC34)
.L59:
	call	inputcharacter
	mv	s0,a0
	addi	a0,s2,%lo(.LC33)
	call	outputstringnonl
	mv	a0,s0
	call	outputcharacter
	addi	a0,s1,%lo(.LC34)
	call	outputstring
	mv	a0,s0
	call	set_leds
	j	.L59
	.size	main, .-main
	.globl	BUFFER
	.globl	FAT
	.globl	ROOTDIRECTORY
	.globl	PARTITION
	.globl	BOOTSECTOR
	.globl	MBR
	.globl	sdcardtiles
	.data
	.align	2
	.set	.LANCHOR1,. + 0
	.type	sdcardtiles, @object
	.size	sdcardtiles, 96
sdcardtiles:
	.half	0
	.half	0
	.half	3776
	.half	2208
	.half	3744
	.half	672
	.half	3776
	.half	0
	.half	2656
	.half	2688
	.half	3712
	.half	2688
	.half	2656
	.half	0
	.half	0
	.half	0
	.half	16368
	.half	16376
	.half	16380
	.half	16380
	.half	16380
	.half	16376
	.half	8188
	.half	8188
	.half	16380
	.half	16380
	.half	16380
	.half	16380
	.half	16380
	.half	16380
	.half	16380
	.half	16380
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	24
	.half	24
	.half	0
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
	.type	BUFFER, @object
	.size	BUFFER, 512
BUFFER:
	.zero	512
	.section	.sbss,"aw",@nobits
	.align	2
	.type	FAT, @object
	.size	FAT, 4
FAT:
	.zero	4
	.type	ROOTDIRECTORY, @object
	.size	ROOTDIRECTORY, 4
ROOTDIRECTORY:
	.zero	4
	.type	PARTITION, @object
	.size	PARTITION, 4
PARTITION:
	.zero	4
	.ident	"GCC: (Arch Linux Repositories) 10.2.0"
