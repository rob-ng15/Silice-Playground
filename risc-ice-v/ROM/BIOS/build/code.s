	.file	"BIOS.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	1
	.globl	sd_readSector
	.type	sd_readSector, @function
sd_readSector:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s1,4(sp)
	mv	s0,a0
	mv	s1,a1
	li	a4,2
	li	a3,2
	li	a2,4
	li	a1,576
	li	a0,48
	call	gpu_blit
	mv	a1,s1
	mv	a0,s0
	call	sdcard_readsector
	li	a4,2
	li	a3,2
	li	a2,4
	li	a1,576
	li	a0,12
	call	gpu_blit
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
	addi	sp,sp,-16
	sw	ra,12(sp)
	lui	a5,%hi(MBR)
	lw	a1,%lo(MBR)(a5)
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
	lui	a5,%hi(BOOTSECTOR)
	lw	a3,%lo(BOOTSECTOR)(a5)
	lbu	a5,22(a3)
	lbu	a0,23(a3)
	slli	a0,a0,8
	or	a5,a0,a5
	beq	a5,zero,.L10
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	li	s0,0
	lui	s3,%hi(FAT)
	lui	s2,%hi(PARTITION)
	lui	s1,%hi(BOOTSECTOR)
.L7:
	slli	a1,s0,9
	lw	a6,%lo(FAT)(s3)
	lw	a2,%lo(PARTITION)(s2)
	lbu	a0,8(a2)
	lbu	a4,9(a2)
	slli	a4,a4,8
	or	a4,a4,a0
	lbu	a0,10(a2)
	slli	a0,a0,16
	or	a4,a0,a4
	lbu	a0,11(a2)
	slli	a0,a0,24
	or	a0,a0,a4
	lbu	a2,14(a3)
	lbu	a4,15(a3)
	slli	a4,a4,8
	or	a4,a4,a2
	add	a0,a0,a4
	add	a0,a0,a5
	add	a1,a6,a1
	add	a0,a0,s0
	call	sd_readSector
	addi	s0,s0,1
	slli	s0,s0,16
	srli	s0,s0,16
	lw	a3,%lo(BOOTSECTOR)(s1)
	lbu	a5,22(a3)
	lbu	a0,23(a3)
	slli	a0,a0,8
	or	a5,a0,a5
	bgtu	a5,s0,.L7
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
	lui	a5,%hi(BOOTSECTOR)
	lw	a4,%lo(BOOTSECTOR)(a5)
	lbu	a3,17(a4)
	lbu	a5,18(a4)
	slli	a5,a5,8
	or	a5,a5,a3
	slli	a5,a5,5
	li	a3,511
	bleu	a5,a3,.L18
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
	lui	s1,%hi(BOOTSECTOR)
.L15:
	slli	a1,s0,9
	lw	a6,%lo(ROOTDIRECTORY)(s3)
	lw	a2,%lo(PARTITION)(s2)
	lbu	a5,8(a2)
	lbu	a3,9(a2)
	slli	a3,a3,8
	or	a3,a3,a5
	lbu	a5,10(a2)
	slli	a5,a5,16
	or	a3,a5,a3
	lbu	a5,11(a2)
	slli	a5,a5,24
	or	a5,a5,a3
	lbu	a2,14(a4)
	lbu	a3,15(a4)
	slli	a3,a3,8
	or	a3,a3,a2
	add	a5,a5,a3
	lbu	a2,22(a4)
	lbu	a3,23(a4)
	slli	a3,a3,8
	or	a3,a3,a2
	lbu	a4,16(a4)
	mul	a4,a3,a4
	add	a5,a5,a4
	add	a1,a6,a1
	add	a0,a5,a0
	call	sd_readSector
	addi	s0,s0,1
	slli	s0,s0,16
	srli	s0,s0,16
	mv	a0,s0
	lw	a4,%lo(BOOTSECTOR)(s1)
	lbu	a3,17(a4)
	lbu	a5,18(a4)
	slli	a5,a5,8
	or	a5,a5,a3
	srli	a5,a5,4
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
	.globl	sd_readCluster
	.type	sd_readCluster, @function
sd_readCluster:
	lui	a5,%hi(BOOTSECTOR)
	lw	a5,%lo(BOOTSECTOR)(a5)
	lbu	a5,13(a5)
	beq	a5,zero,.L26
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	li	s0,0
	lui	s4,%hi(CLUSTERBUFFER)
	addi	s1,a0,-2
	lui	s3,%hi(DATASTARTSECTOR)
	lui	s2,%hi(BOOTSECTOR)
.L23:
	slli	a4,s0,9
	lw	a1,%lo(CLUSTERBUFFER)(s4)
	mul	a5,s1,a5
	lw	a0,%lo(DATASTARTSECTOR)(s3)
	add	a0,a5,a0
	add	a1,a1,a4
	add	a0,a0,s0
	call	sd_readSector
	addi	s0,s0,1
	slli	s0,s0,16
	srli	s0,s0,16
	lw	a5,%lo(BOOTSECTOR)(s2)
	lbu	a5,13(a5)
	slli	a4,a5,16
	srli	a4,a4,16
	bgtu	a4,s0,.L23
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	lw	s4,8(sp)
	addi	sp,sp,32
	jr	ra
.L26:
	ret
	.size	sd_readCluster, .-sd_readCluster
	.align	1
	.globl	sd_findNextFile
	.type	sd_findNextFile, @function
sd_findNextFile:
	lui	a5,%hi(SELECTEDFILE)
	lhu	a3,%lo(SELECTEDFILE)(a5)
	li	a5,65536
	addi	a5,a5,-1
	li	a4,0
	beq	a3,a5,.L30
	addi	a4,a3,1
	slli	a4,a4,16
	srli	a4,a4,16
.L30:
	lui	a5,%hi(ROOTDIRECTORY)
	lw	a0,%lo(ROOTDIRECTORY)(a5)
	lui	a5,%hi(BOOTSECTOR)
	lw	a2,%lo(BOOTSECTOR)(a5)
	li	a1,80
	li	a7,65
	li	t1,87
	li	a6,0
	j	.L33
.L32:
	lbu	a3,17(a2)
	lbu	a5,18(a2)
	slli	a5,a5,8
	or	a5,a5,a3
	bgtu	a5,a4,.L38
	mv	a4,a6
.L33:
	slli	a5,a4,5
	add	a5,a0,a5
	lbu	a3,8(a5)
	bne	a3,a1,.L32
	lbu	a3,9(a5)
	bne	a3,a7,.L32
	lbu	a5,10(a5)
	bne	a5,t1,.L32
	lui	a5,%hi(SELECTEDFILE)
	sh	a4,%lo(SELECTEDFILE)(a5)
	ret
.L38:
	addi	a4,a4,1
	slli	a4,a4,16
	srli	a4,a4,16
	j	.L33
	.size	sd_findNextFile, .-sd_findNextFile
	.align	1
	.globl	sd_readFile
	.type	sd_readFile, @function
sd_readFile:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	sw	s5,4(sp)
	mv	s0,a1
	lui	a5,%hi(ROOTDIRECTORY)
	lw	a5,%lo(ROOTDIRECTORY)(a5)
	slli	a0,a0,5
	add	a5,a5,a0
	lbu	a4,26(a5)
	lbu	s3,27(a5)
	slli	s3,s3,8
	or	s3,s3,a4
	lui	s1,%hi(BOOTSECTOR)
	lui	s2,%hi(CLUSTERBUFFER)
	lui	s5,%hi(FAT)
	li	s4,65536
	addi	s4,s4,-1
.L42:
	mv	a0,s3
	call	sd_readCluster
	lw	a5,%lo(BOOTSECTOR)(s1)
	lbu	a5,13(a5)
	beq	a5,zero,.L40
	li	a5,0
.L41:
	lw	a4,%lo(CLUSTERBUFFER)(s2)
	add	a4,a4,a5
	lbu	a4,0(a4)
	sb	a4,0(s0)
	addi	s0,s0,1
	addi	a5,a5,1
	lw	a4,%lo(BOOTSECTOR)(s1)
	lbu	a4,13(a4)
	slli	a4,a4,9
	bgt	a4,a5,.L41
.L40:
	slli	s3,s3,1
	lw	a5,%lo(FAT)(s5)
	add	s3,a5,s3
	lhu	s3,0(s3)
	bne	s3,s4,.L42
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	lw	s4,8(sp)
	lw	s5,4(sp)
	addi	sp,sp,32
	jr	ra
	.size	sd_readFile, .-sd_readFile
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
	lui	a1,%hi(.LANCHOR0)
	addi	s0,a1,%lo(.LANCHOR0)
	addi	a1,a1,%lo(.LANCHOR0)
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
	li	a4,2
	li	a3,1
	li	a2,4
	li	a1,576
	li	a0,3
	call	gpu_blit
	li	a4,2
	li	a3,0
	li	a2,4
	li	a1,576
	li	a0,63
	call	gpu_blit
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	draw_sdcard, .-draw_sdcard
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"Welcome to PAWS a RISC-V RV32IMC CPU"
	.align	2
.LC1:
	.string	"Waiting for SDCARD"
	.align	2
.LC2:
	.string	"SDCARD READY"
	.align	2
.LC3:
	.string	"ERROR: PLEASE INSERT A VALID FAT16 FORMATTED SDCARD AND PRESS RESET"
	.align	2
.LC4:
	.string	"SELECT FILE FOR LOADING"
	.align	2
.LC5:
	.string	"SCROLL USING FIRE 2, SELECT USING FIRE 1"
	.align	2
.LC6:
	.string	"NO PAW FILES FOUND"
	.align	2
.LC7:
	.string	"PAW FILE:"
	.align	2
.LC8:
	.string	"FILE SELECTED"
	.align	2
.LC9:
	.string	"PREPARING TO LOAD"
	.align	2
.LC10:
	.string	"LOADING"
	.align	2
.LC11:
	.string	"FILE LOADED"
	.align	2
.LC12:
	.string	"PREPARING TO LAUNCH"
	.text
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	sw	s5,4(sp)
	sw	s6,0(sp)
	li	a0,0
	call	terminal_showhide
	call	terminal_reset
	call	gpu_cs
	call	tpu_cs
	li	a0,9
	call	tilemap_scrollwrapclear
	li	a2,0
	li	a1,0
	li	a0,1
	call	set_background
	li	s0,0
	li	s2,13
.L53:
	andi	s1,s0,0xff
	li	a7,0
	li	a6,0
	li	a5,0
	li	a4,0
	li	a3,0
	li	a2,0
	mv	a1,s1
	li	a0,0
	call	set_sprite
	li	a7,0
	li	a6,0
	li	a5,0
	li	a4,0
	li	a3,0
	li	a2,0
	mv	a1,s1
	li	a0,1
	call	set_sprite
	addi	s0,s0,1
	slli	s0,s0,16
	srli	s0,s0,16
	bne	s0,s2,.L53
	call	draw_riscv_logo
	call	set_sdcard_bitmap
	call	draw_sdcard
	li	a3,63
	li	a2,64
	li	a1,5
	li	a0,16
	call	tpu_set
	lui	a0,%hi(.LC0)
	addi	a0,a0,%lo(.LC0)
	call	tpu_outputstring
	lui	a3,%hi(.LC1)
	addi	a3,a3,%lo(.LC1)
	li	a2,48
	li	a1,64
	li	a0,7
	call	tpu_outputstringcentre
	li	a0,2000
	call	sleep
	lui	a3,%hi(.LC2)
	addi	a3,a3,%lo(.LC2)
	li	a2,12
	li	a1,64
	li	a0,7
	call	tpu_outputstringcentre
	lui	s0,%hi(MBR)
	lw	a1,%lo(MBR)(s0)
	li	a0,0
	call	sd_readSector
	lw	a3,%lo(MBR)(s0)
	addi	a4,a3,446
	lui	a5,%hi(PARTITION)
	sw	a4,%lo(PARTITION)(a5)
	lbu	a5,450(a3)
	addi	a5,a5,-4
	andi	a5,a5,0xff
	li	a4,10
	bgtu	a5,a4,.L54
	li	a4,1
	sll	a5,a4,a5
	andi	a5,a5,1029
	bne	a5,zero,.L55
.L54:
	lui	a3,%hi(.LC3)
	addi	a3,a3,%lo(.LC3)
	li	a2,48
	li	a1,64
	li	a0,15
	call	tpu_outputstringcentre
.L56:
	j	.L56
.L55:
	lui	s0,%hi(BOOTSECTOR)
	lbu	a4,454(a3)
	lbu	a5,455(a3)
	slli	a5,a5,8
	or	a4,a5,a4
	lbu	a5,456(a3)
	slli	a5,a5,16
	or	a5,a5,a4
	lbu	a0,457(a3)
	slli	a0,a0,24
	lw	a1,%lo(BOOTSECTOR)(s0)
	or	a0,a0,a5
	call	sd_readSector
	lui	s1,%hi(ROOTDIRECTORY)
	lw	a5,%lo(BOOTSECTOR)(s0)
	lbu	a4,17(a5)
	lbu	a5,18(a5)
	slli	a5,a5,8
	or	a4,a5,a4
	li	a5,9437184
	addi	a5,a5,-32
	sub	a5,a5,a4
	slli	a5,a5,5
	sw	a5,%lo(ROOTDIRECTORY)(s1)
	call	sd_readRootDirectory
	lui	s2,%hi(FAT)
	lw	a5,%lo(BOOTSECTOR)(s0)
	lbu	a4,22(a5)
	lbu	a5,23(a5)
	slli	a5,a5,8
	or	a5,a5,a4
	slli	a5,a5,10
	lw	a4,%lo(ROOTDIRECTORY)(s1)
	sub	a5,a4,a5
	sw	a5,%lo(FAT)(s2)
	call	sd_readFAT
	lw	a4,%lo(BOOTSECTOR)(s0)
	lbu	a5,13(a4)
	slli	a3,a5,9
	lw	a5,%lo(FAT)(s2)
	sub	a5,a5,a3
	lui	a3,%hi(CLUSTERBUFFER)
	sw	a5,%lo(CLUSTERBUFFER)(a3)
	lui	a5,%hi(PARTITION)
	lw	a2,%lo(PARTITION)(a5)
	lbu	a5,8(a2)
	lbu	a3,9(a2)
	slli	a3,a3,8
	or	a3,a3,a5
	lbu	a5,10(a2)
	slli	a5,a5,16
	or	a3,a5,a3
	lbu	a5,11(a2)
	slli	a5,a5,24
	or	a5,a5,a3
	lbu	a2,14(a4)
	lbu	a3,15(a4)
	slli	a3,a3,8
	or	a3,a3,a2
	add	a5,a5,a3
	lbu	a2,22(a4)
	lbu	a3,23(a4)
	slli	a3,a3,8
	or	a3,a3,a2
	lbu	a2,16(a4)
	mul	a3,a3,a2
	add	a5,a5,a3
	lbu	a3,17(a4)
	lbu	a4,18(a4)
	slli	a4,a4,8
	or	a4,a4,a3
	srli	a4,a4,4
	add	a5,a5,a4
	lui	a4,%hi(DATASTARTSECTOR)
	sw	a5,%lo(DATASTARTSECTOR)(a4)
	lui	a3,%hi(.LC4)
	addi	a3,a3,%lo(.LC4)
	li	a2,63
	li	a1,64
	li	a0,7
	call	tpu_outputstringcentre
	lui	a3,%hi(.LC5)
	addi	a3,a3,%lo(.LC5)
	li	a2,63
	li	a1,64
	li	a0,8
	call	tpu_outputstringcentre
	lui	a3,%hi(.LC6)
	addi	a3,a3,%lo(.LC6)
	li	a2,48
	li	a1,64
	li	a0,10
	call	tpu_outputstringcentre
	lui	a5,%hi(SELECTEDFILE)
	li	a4,-1
	sh	a4,%lo(SELECTEDFILE)(a5)
	mv	s2,a5
	li	s5,65536
	addi	s5,s5,-1
	lui	s6,%hi(.LC7)
	mv	s4,s1
	li	s3,8
	j	.L67
.L59:
	call	get_buttons
	andi	a0,a0,4
	bne	a0,zero,.L59
	call	sd_findNextFile
	addi	a3,s6,%lo(.LC7)
	li	a2,63
	li	a1,64
	li	a0,10
	call	tpu_outputstringcentre
	li	a4,272
	li	a3,576
	li	a2,208
	li	a1,64
	li	a0,64
	call	gpu_rectangle
	li	s0,64
	li	s1,0
.L60:
	lhu	a4,%lo(SELECTEDFILE)(s2)
	lw	a5,%lo(ROOTDIRECTORY)(s4)
	slli	a4,a4,5
	add	a5,a5,a4
	add	a5,a5,s1
	li	a4,3
	lbu	a3,0(a5)
	li	a2,208
	slli	a1,s0,16
	srai	a1,a1,16
	li	a0,63
	call	gpu_character_blit
	addi	s1,s1,1
	addi	s0,s0,64
	slli	s0,s0,16
	srli	s0,s0,16
	bne	s1,s3,.L60
.L58:
	call	get_buttons
	andi	a0,a0,2
	beq	a0,zero,.L67
	lhu	a5,%lo(SELECTEDFILE)(s2)
	bne	a5,s5,.L62
.L67:
	call	get_buttons
	andi	a0,a0,4
	bne	a0,zero,.L59
	lhu	a5,%lo(SELECTEDFILE)(s2)
	bne	a5,s5,.L58
	j	.L59
.L62:
	call	get_buttons
	andi	a0,a0,2
	bne	a0,zero,.L62
	lui	a3,%hi(.LC8)
	addi	a3,a3,%lo(.LC8)
	li	a2,63
	li	a1,64
	li	a0,7
	call	tpu_outputstringcentre
	lui	a3,%hi(.LC9)
	addi	a3,a3,%lo(.LC9)
	li	a2,63
	li	a1,64
	li	a0,8
	call	tpu_outputstringcentre
	li	a0,2000
	call	sleep
	lui	a3,%hi(.LC10)
	addi	a3,a3,%lo(.LC10)
	li	a2,63
	li	a1,64
	li	a0,8
	call	tpu_outputstringcentre
	li	a1,268435456
	lui	a5,%hi(SELECTEDFILE)
	lhu	a0,%lo(SELECTEDFILE)(a5)
	call	sd_readFile
	lui	a3,%hi(.LC11)
	addi	a3,a3,%lo(.LC11)
	li	a2,63
	li	a1,64
	li	a0,7
	call	tpu_outputstringcentre
	lui	a3,%hi(.LC12)
	addi	a3,a3,%lo(.LC12)
	li	a2,63
	li	a1,64
	li	a0,8
	call	tpu_outputstringcentre
	li	a0,2000
	call	sleep
	li	a5,268435456
	jalr	a5
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
	.size	main, .-main
	.globl	SELECTEDFILE
	.globl	DATASTARTSECTOR
	.globl	CLUSTERBUFFER
	.globl	FAT
	.globl	ROOTDIRECTORY
	.globl	PARTITION
	.globl	BOOTSECTOR
	.globl	MBR
	.globl	sdcardtiles
	.data
	.align	2
	.set	.LANCHOR0,. + 0
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
	.section	.sbss,"aw",@nobits
	.align	2
	.type	DATASTARTSECTOR, @object
	.size	DATASTARTSECTOR, 4
DATASTARTSECTOR:
	.zero	4
	.type	CLUSTERBUFFER, @object
	.size	CLUSTERBUFFER, 4
CLUSTERBUFFER:
	.zero	4
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
	.section	.sdata,"aw"
	.align	2
	.type	SELECTEDFILE, @object
	.size	SELECTEDFILE, 2
SELECTEDFILE:
	.half	-1
	.zero	2
	.type	BOOTSECTOR, @object
	.size	BOOTSECTOR, 4
BOOTSECTOR:
	.word	301465600
	.type	MBR, @object
	.size	MBR, 4
MBR:
	.word	301989376
	.ident	"GCC: (Arch Linux Repositories) 10.2.0"
