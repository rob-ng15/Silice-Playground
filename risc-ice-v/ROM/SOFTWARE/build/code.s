	.file	"asteroids.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	1
	.globl	set_asteroid_sprites
	.type	set_asteroid_sprites, @function
set_asteroid_sprites:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	li	s0,0
	li	a0,0
	li	a1,0
	lui	s2,%hi(.LANCHOR0)
	li	s1,20
	li	s3,9
	j	.L2
.L3:
	mv	s0,a5
.L2:
	addi	a2,s2,%lo(.LANCHOR0)
	call	set_sprite_bitmaps
	addi	a5,s0,1
	andi	a5,a5,0xff
	beq	a5,s1,.L7
	sltiu	a0,a5,10
	xori	a0,a0,1
	mv	a1,a5
	bleu	a5,s3,.L3
	addi	s0,s0,-9
	andi	a1,s0,0xff
	j	.L3
.L7:
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	addi	sp,sp,32
	jr	ra
	.size	set_asteroid_sprites, .-set_asteroid_sprites
	.align	1
	.globl	set_ship_sprites
	.type	set_ship_sprites, @function
set_ship_sprites:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	snez	a0,a0
	lui	s0,%hi(.LANCHOR0+256)
	slli	a0,a0,8
	addi	s0,s0,%lo(.LANCHOR0+256)
	add	s0,s0,a0
	mv	a2,s0
	li	a1,11
	li	a0,0
	call	set_sprite_bitmaps
	mv	a2,s0
	li	a1,11
	li	a0,1
	call	set_sprite_bitmaps
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	set_ship_sprites, .-set_ship_sprites
	.align	1
	.globl	set_ship_vector
	.type	set_ship_vector, @function
set_ship_vector:
	addi	sp,sp,-16
	sw	ra,12(sp)
	li	a4,0
	li	a3,0
	li	a2,1
	li	a1,0
	li	a0,0
	call	set_vector_vertex
	li	a4,10
	li	a3,5
	li	a2,1
	li	a1,1
	li	a0,0
	call	set_vector_vertex
	li	a4,6
	li	a3,0
	li	a2,1
	li	a1,2
	li	a0,0
	call	set_vector_vertex
	li	a4,10
	li	a3,251
	li	a2,1
	li	a1,3
	li	a0,0
	call	set_vector_vertex
	li	a4,0
	li	a3,0
	li	a2,1
	li	a1,4
	li	a0,0
	call	set_vector_vertex
	li	a4,0
	li	a3,0
	li	a2,0
	li	a1,5
	li	a0,0
	call	set_vector_vertex
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	set_ship_vector, .-set_ship_vector
	.align	1
	.globl	set_bullet_sprites
	.type	set_bullet_sprites, @function
set_bullet_sprites:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	lui	s0,%hi(.LANCHOR0+768)
	addi	s0,s0,%lo(.LANCHOR0+768)
	mv	a2,s0
	li	a1,12
	li	a0,0
	call	set_sprite_bitmaps
	mv	a2,s0
	li	a1,12
	li	a0,1
	call	set_sprite_bitmaps
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	set_bullet_sprites, .-set_bullet_sprites
	.align	1
	.globl	set_ufo_sprite
	.type	set_ufo_sprite, @function
set_ufo_sprite:
	addi	sp,sp,-16
	sw	ra,12(sp)
	mv	a4,a0
	lui	a5,%hi(ufo_sprite_number)
	lbu	a1,%lo(ufo_sprite_number)(a5)
	sltiu	a5,a1,10
	xori	a0,a5,1
	li	a5,9
	bleu	a1,a5,.L17
	addi	a1,a1,-10
	andi	a1,a1,0xff
.L17:
	bne	a4,zero,.L19
	lui	a2,%hi(.LANCHOR0)
	addi	a2,a2,%lo(.LANCHOR0)
.L18:
	call	set_sprite_bitmaps
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
.L19:
	lui	a2,%hi(.LANCHOR0+1024)
	addi	a2,a2,%lo(.LANCHOR0+1024)
	j	.L18
	.size	set_ufo_sprite, .-set_ufo_sprite
	.align	1
	.globl	set_ufo_bullet_sprites
	.type	set_ufo_bullet_sprites, @function
set_ufo_bullet_sprites:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	lui	s0,%hi(.LANCHOR0+1280)
	addi	s0,s0,%lo(.LANCHOR0+1280)
	mv	a2,s0
	li	a1,10
	li	a0,0
	call	set_sprite_bitmaps
	mv	a2,s0
	li	a1,10
	li	a0,1
	call	set_sprite_bitmaps
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	set_ufo_bullet_sprites, .-set_ufo_bullet_sprites
	.align	1
	.globl	set_tilemap
	.type	set_tilemap, @function
set_tilemap:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s1,4(sp)
	sw	s2,0(sp)
	li	a0,9
	call	tilemap_scrollwrapclear
	lui	s1,%hi(.LANCHOR0+1536)
	addi	s1,s1,%lo(.LANCHOR0+1536)
	li	s0,0
	li	s2,8
.L24:
	addi	s0,s0,1
	andi	s0,s0,0xff
	mv	a1,s1
	mv	a0,s0
	call	set_tilemap_bitmap
	addi	s1,s1,32
	bne	s0,s2,.L24
	li	a4,21
	li	a3,64
	li	a2,1
	li	a1,4
	li	a0,4
	call	set_tilemap_tile
	li	a4,21
	li	a3,64
	li	a2,2
	li	a1,5
	li	a0,4
	call	set_tilemap_tile
	li	a4,21
	li	a3,64
	li	a2,3
	li	a1,4
	li	a0,5
	call	set_tilemap_tile
	li	a4,21
	li	a3,64
	li	a2,4
	li	a1,5
	li	a0,5
	call	set_tilemap_tile
	li	a4,20
	li	a3,64
	li	a2,1
	li	a1,14
	li	a0,18
	call	set_tilemap_tile
	li	a4,20
	li	a3,64
	li	a2,2
	li	a1,15
	li	a0,18
	call	set_tilemap_tile
	li	a4,20
	li	a3,64
	li	a2,3
	li	a1,14
	li	a0,19
	call	set_tilemap_tile
	li	a4,20
	li	a3,64
	li	a2,4
	li	a1,15
	li	a0,19
	call	set_tilemap_tile
	li	a4,5
	li	a3,64
	li	a2,1
	li	a1,28
	li	a0,34
	call	set_tilemap_tile
	li	a4,5
	li	a3,64
	li	a2,2
	li	a1,29
	li	a0,34
	call	set_tilemap_tile
	li	a4,5
	li	a3,64
	li	a2,3
	li	a1,28
	li	a0,35
	call	set_tilemap_tile
	li	a4,5
	li	a3,64
	li	a2,4
	li	a1,29
	li	a0,35
	call	set_tilemap_tile
	li	a4,42
	li	a3,64
	li	a2,5
	li	a1,2
	li	a0,36
	call	set_tilemap_tile
	li	a4,42
	li	a3,64
	li	a2,6
	li	a1,3
	li	a0,36
	call	set_tilemap_tile
	li	a4,42
	li	a3,64
	li	a2,7
	li	a1,2
	li	a0,37
	call	set_tilemap_tile
	li	a4,42
	li	a3,64
	li	a2,8
	li	a1,3
	li	a0,37
	call	set_tilemap_tile
	li	a4,16
	li	a3,64
	li	a2,5
	li	a1,26
	li	a0,6
	call	set_tilemap_tile
	li	a4,16
	li	a3,64
	li	a2,6
	li	a1,27
	li	a0,6
	call	set_tilemap_tile
	li	a4,16
	li	a3,64
	li	a2,7
	li	a1,26
	li	a0,7
	call	set_tilemap_tile
	li	a4,16
	li	a3,64
	li	a2,8
	li	a1,27
	li	a0,7
	call	set_tilemap_tile
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	lw	s2,0(sp)
	addi	sp,sp,16
	jr	ra
	.size	set_tilemap, .-set_tilemap
	.align	1
	.globl	risc_ice_v_logo
	.type	risc_ice_v_logo, @function
risc_ice_v_logo:
	addi	sp,sp,-16
	sw	ra,12(sp)
	call	gpu_cs
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
	.size	risc_ice_v_logo, .-risc_ice_v_logo
	.align	1
	.globl	setup_game
	.type	setup_game, @function
setup_game:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	sw	s5,4(sp)
	sw	s6,0(sp)
	lui	s2,%hi(.LANCHOR1)
	addi	s2,s2,%lo(.LANCHOR1)
	addi	s3,s2,20
	li	s0,1
	li	s1,0
	li	s4,19
	li	s6,25
	li	s5,12
	j	.L34
.L30:
	sltiu	a0,a1,13
	xori	a0,a0,1
.L31:
	addi	a1,a1,-13
	li	a7,0
	li	a6,0
	li	a5,0
	li	a4,0
	li	a3,0
	li	a2,0
	andi	a1,a1,0xff
	call	set_sprite
	bgtu	s0,s6,.L33
.L35:
	addi	s1,s1,1
	addi	s0,s0,1
	andi	s0,s0,0xff
	addi	s2,s2,1
	addi	s3,s3,1
.L34:
	andi	a1,s1,0xff
	bgtu	a1,s4,.L30
	sb	zero,0(s2)
	sb	zero,0(s3)
	sltiu	a0,a1,13
	xori	a0,a0,1
	bgtu	a1,s5,.L31
	li	a7,0
	li	a6,0
	li	a5,0
	li	a4,0
	li	a3,0
	li	a2,0
	li	a0,0
	call	set_sprite
	j	.L35
.L33:
	call	gpu_cs
	li	a0,0
	call	terminal_showhide
	li	a2,7
	li	a1,1
	li	a0,42
	call	set_background
	call	risc_ice_v_logo
	call	set_tilemap
	call	tpu_cs
	call	set_asteroid_sprites
	li	a0,0
	call	set_ship_sprites
	call	set_ship_vector
	call	set_bullet_sprites
	call	set_ufo_bullet_sprites
	lui	a5,%hi(lives)
	sh	zero,%lo(lives)(a5)
	lui	a5,%hi(score)
	sh	zero,%lo(score)(a5)
	lui	a5,%hi(shipx)
	li	a4,312
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	li	a4,232
	sh	a4,%lo(shipy)(a5)
	lui	a5,%hi(shipdirection)
	sh	zero,%lo(shipdirection)(a5)
	lui	a5,%hi(resetship)
	sh	zero,%lo(resetship)(a5)
	lui	a5,%hi(bulletdirection)
	sh	zero,%lo(bulletdirection)(a5)
	lui	a5,%hi(counter)
	sw	zero,%lo(counter)(a5)
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
	.size	setup_game, .-setup_game
	.align	1
	.globl	find_asteroid_space
	.type	find_asteroid_space, @function
find_asteroid_space:
	lui	a2,%hi(.LANCHOR1)
	addi	a2,a2,%lo(.LANCHOR1)
	li	a5,0
	li	a3,0
	li	a0,255
	li	a1,20
	j	.L41
.L40:
	seqz	a4,a4
	add	a4,a3,a4
	andi	a3,a4,0xff
	addi	a5,a5,1
	andi	a5,a5,0xff
	addi	a2,a2,1
	beq	a5,a1,.L45
.L41:
	lbu	a4,0(a2)
	bne	a4,zero,.L40
	mv	a0,a5
	j	.L40
.L45:
	li	a5,1
	beq	a3,a5,.L46
.L42:
	ret
.L46:
	li	a0,255
	j	.L42
	.size	find_asteroid_space, .-find_asteroid_space
	.align	1
	.globl	move_asteroids
	.type	move_asteroids, @function
move_asteroids:
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
	lui	s3,%hi(.LANCHOR1)
	addi	s3,s3,%lo(.LANCHOR1)
	addi	s4,s3,20
	li	s1,246
	li	s0,0
	lui	s5,%hi(.LANCHOR0)
	addi	s5,s5,%lo(.LANCHOR0)
	lui	s7,%hi(ufo_leftright)
	lui	s6,%hi(ufo_directions)
	addi	s6,s6,%lo(ufo_directions)
	lui	s9,%hi(ufo_sprite_number)
	li	s8,-1
	j	.L56
.L65:
	sltiu	a0,s0,10
	xori	a0,a0,1
	li	a5,9
	mv	a1,s1
	bgtu	s0,a5,.L49
	mv	a1,s0
.L49:
	lbu	a5,0(s4)
	slli	a5,a5,1
	add	a5,s5,a5
	lhu	a2,1792(a5)
	call	update_sprite
	j	.L48
.L66:
	sltiu	s10,s0,10
	xori	s10,s10,1
	li	a5,9
	mv	s11,s1
	bgtu	s0,a5,.L51
	mv	s11,s0
.L51:
	lbu	a5,%lo(ufo_leftright)(s7)
	lui	a4,%hi(level)
	lhu	a4,%lo(level)(a4)
	li	a3,2
	sgtu	a4,a4,a3
	slli	a4,a4,1
	add	a5,a5,a4
	slli	a5,a5,1
	add	a5,s6,a5
	lhu	a2,0(a5)
	mv	a1,s11
	mv	a0,s10
	call	update_sprite
	li	a2,0
	mv	a1,s11
	mv	a0,s10
	call	get_sprite_attribute
	bne	a0,zero,.L50
	call	set_ufo_sprite
	sb	zero,0(s2)
	sb	s8,%lo(ufo_sprite_number)(s9)
	j	.L53
.L54:
	lbu	a4,0(s2)
	li	a5,5
	beq	a4,a5,.L63
.L53:
	addi	s0,s0,1
	andi	s0,s0,0xff
	addi	s3,s3,1
	addi	s1,s1,1
	andi	s1,s1,0xff
	addi	s4,s4,1
	li	a5,20
	beq	s0,a5,.L64
.L56:
	mv	s2,s3
	lbu	a5,0(s3)
	addi	a5,a5,-1
	andi	a5,a5,0xff
	li	a4,1
	bleu	a5,a4,.L65
.L48:
	lbu	a4,0(s2)
	li	a5,3
	beq	a4,a5,.L66
.L50:
	lbu	a5,0(s2)
	li	a4,5
	bleu	a5,a4,.L54
	addi	a5,a5,-1
	sb	a5,0(s2)
	j	.L54
.L63:
	sb	zero,0(s2)
	sltiu	a0,s0,10
	xori	a0,a0,1
	li	a5,9
	mv	a1,s1
	bgtu	s0,a5,.L55
	mv	a1,s0
.L55:
	li	a7,0
	li	a6,0
	li	a5,0
	li	a4,0
	li	a3,0
	li	a2,0
	call	set_sprite
	j	.L53
.L64:
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
	.size	move_asteroids, .-move_asteroids
	.align	1
	.globl	count_asteroids
	.type	count_asteroids, @function
count_asteroids:
	lui	a4,%hi(.LANCHOR1)
	addi	a4,a4,%lo(.LANCHOR1)
	addi	a2,a4,20
	li	a0,0
	li	a3,1
	j	.L69
.L68:
	addi	a4,a4,1
	beq	a4,a2,.L71
.L69:
	lbu	a5,0(a4)
	addi	a5,a5,-1
	andi	a5,a5,0xff
	bgtu	a5,a3,.L68
	addi	a0,a0,1
	slli	a0,a0,16
	srai	a0,a0,16
	j	.L68
.L71:
	slli	a0,a0,16
	srli	a0,a0,16
	ret
	.size	count_asteroids, .-count_asteroids
	.align	1
	.globl	draw_ship
	.type	draw_ship, @function
draw_ship:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	mv	s0,a0
	lui	s3,%hi(shipdirection)
	lui	s2,%hi(shipy)
	lui	s1,%hi(shipx)
	li	a7,0
	lbu	a6,%lo(shipdirection)(s3)
	lh	a5,%lo(shipy)(s2)
	lh	a4,%lo(shipx)(s1)
	mv	a3,a0
	li	a2,1
	li	a1,11
	li	a0,0
	call	set_sprite
	li	a7,0
	lbu	a6,%lo(shipdirection)(s3)
	lh	a5,%lo(shipy)(s2)
	lh	a4,%lo(shipx)(s1)
	mv	a3,s0
	li	a2,1
	li	a1,11
	li	a0,1
	call	set_sprite
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	addi	sp,sp,32
	jr	ra
	.size	draw_ship, .-draw_ship
	.align	1
	.globl	move_ship
	.type	move_ship, @function
move_ship:
	lui	a5,%hi(shipdirection)
	lhu	a3,%lo(shipdirection)(a5)
	li	a4,7
	bgtu	a3,a4,.L74
	slli	a5,a3,2
	lui	a4,%hi(.L77)
	addi	a4,a4,%lo(.L77)
	add	a5,a5,a4
	lw	a5,0(a5)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L77:
	.word	.L84
	.word	.L83
	.word	.L82
	.word	.L81
	.word	.L80
	.word	.L79
	.word	.L78
	.word	.L76
	.text
.L84:
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a4,464
	ble	a5,zero,.L85
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L85:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
	ret
.L83:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a3,623
	li	a4,0
	bgt	a5,a3,.L86
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L86:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a4,464
	ble	a5,zero,.L87
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L87:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
	ret
.L82:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a3,623
	li	a4,0
	bgt	a5,a3,.L88
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L88:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	ret
.L81:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a3,623
	li	a4,0
	bgt	a5,a3,.L89
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L89:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a3,463
	li	a4,0
	bgt	a5,a3,.L90
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L90:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
	ret
.L80:
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a3,463
	li	a4,0
	bgt	a5,a3,.L91
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L91:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
	ret
.L79:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a4,624
	ble	a5,zero,.L92
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L92:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a3,463
	li	a4,0
	bgt	a5,a3,.L93
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L93:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
	ret
.L78:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a4,624
	ble	a5,zero,.L94
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L94:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	ret
.L76:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a4,624
	ble	a5,zero,.L95
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L95:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a4,464
	ble	a5,zero,.L96
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L96:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
.L74:
	ret
	.size	move_ship, .-move_ship
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"Score "
	.align	2
.LC1:
	.string	"Level "
	.text
	.align	1
	.globl	draw_score
	.type	draw_score, @function
draw_score:
	addi	sp,sp,-16
	sw	ra,12(sp)
	lui	a5,%hi(lives)
	lhu	a3,%lo(lives)(a5)
	snez	a3,a3
	neg	a3,a3
	andi	a3,a3,42
	addi	a3,a3,21
	li	a2,64
	li	a1,1
	li	a0,34
	call	tpu_set
	lui	a0,%hi(.LC0)
	addi	a0,a0,%lo(.LC0)
	call	tpu_outputstring
	lui	a5,%hi(score)
	lhu	a0,%lo(score)(a5)
	call	tpu_outputnumber_short
	lui	a5,%hi(lives)
	lhu	a3,%lo(lives)(a5)
	snez	a3,a3
	neg	a3,a3
	andi	a3,a3,42
	addi	a3,a3,21
	li	a2,64
	li	a1,28
	li	a0,1
	call	tpu_set
	lui	a0,%hi(.LC1)
	addi	a0,a0,%lo(.LC1)
	call	tpu_outputstring
	lui	a5,%hi(level)
	lhu	a0,%lo(level)(a5)
	call	tpu_outputnumber_short
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	draw_score, .-draw_score
	.align	1
	.globl	draw_lives
	.type	draw_lives, @function
draw_lives:
	addi	sp,sp,-16
	sw	ra,12(sp)
	lui	a5,%hi(lives)
	lhu	a5,%lo(lives)(a5)
	li	a4,2
	beq	a5,a4,.L116
	li	a4,3
	beq	a5,a4,.L117
	li	a4,1
	bne	a5,a4,.L115
	j	.L118
.L117:
	li	a3,464
	li	a2,608
	li	a1,63
	li	a0,0
	call	draw_vector_block
.L116:
	li	a3,464
	li	a2,576
	li	a1,63
	li	a0,0
	call	draw_vector_block
.L118:
	li	a3,464
	li	a2,544
	li	a1,63
	li	a0,0
	call	draw_vector_block
.L115:
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	draw_lives, .-draw_lives
	.align	1
	.globl	fire_bullet
	.type	fire_bullet, @function
fire_bullet:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s1,4(sp)
	li	s0,0
	li	s1,0
	lui	a5,%hi(shipdirection)
	lh	a3,%lo(shipdirection)(a5)
	lui	a5,%hi(bulletdirection)
	sh	a3,%lo(bulletdirection)(a5)
	slli	a4,a3,16
	srli	a4,a4,16
	li	a5,7
	bgtu	a4,a5,.L122
	slli	a3,a3,2
	lui	a5,%hi(.L124)
	addi	a5,a5,%lo(.L124)
	add	a3,a3,a5
	lw	a5,0(a3)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L124:
	.word	.L131
	.word	.L130
	.word	.L129
	.word	.L128
	.word	.L127
	.word	.L126
	.word	.L125
	.word	.L123
	.text
.L131:
	lui	a5,%hi(shipx)
	lh	s0,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lhu	s1,%lo(shipy)(a5)
	addi	s1,s1,-10
	slli	s1,s1,16
	srai	s1,s1,16
.L122:
	li	a7,0
	li	a6,2
	mv	a5,s1
	mv	a4,s0
	li	a3,60
	li	a2,1
	li	a1,12
	li	a0,0
	call	set_sprite
	li	a7,0
	li	a6,0
	mv	a5,s1
	mv	a4,s0
	li	a3,48
	li	a2,1
	li	a1,12
	li	a0,1
	call	set_sprite
	li	a3,128
	li	a2,61
	li	a1,4
	li	a0,2
	call	beep
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
.L130:
	lui	a5,%hi(shipx)
	lhu	s0,%lo(shipx)(a5)
	addi	s0,s0,8
	slli	s0,s0,16
	srai	s0,s0,16
	lui	a5,%hi(shipy)
	lhu	s1,%lo(shipy)(a5)
	addi	s1,s1,-10
	slli	s1,s1,16
	srai	s1,s1,16
	j	.L122
.L129:
	lui	a5,%hi(shipx)
	lhu	s0,%lo(shipx)(a5)
	addi	s0,s0,10
	slli	s0,s0,16
	srai	s0,s0,16
	lui	a5,%hi(shipy)
	lh	s1,%lo(shipy)(a5)
	j	.L122
.L128:
	lui	a5,%hi(shipx)
	lhu	s0,%lo(shipx)(a5)
	addi	s0,s0,10
	slli	s0,s0,16
	srai	s0,s0,16
	lui	a5,%hi(shipy)
	lhu	s1,%lo(shipy)(a5)
	addi	s1,s1,10
	slli	s1,s1,16
	srai	s1,s1,16
	j	.L122
.L127:
	lui	a5,%hi(shipx)
	lh	s0,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lhu	s1,%lo(shipy)(a5)
	addi	s1,s1,10
	slli	s1,s1,16
	srai	s1,s1,16
	j	.L122
.L126:
	lui	a5,%hi(shipx)
	lhu	s0,%lo(shipx)(a5)
	addi	s0,s0,-10
	slli	s0,s0,16
	srai	s0,s0,16
	lui	a5,%hi(shipy)
	lhu	s1,%lo(shipy)(a5)
	addi	s1,s1,10
	slli	s1,s1,16
	srai	s1,s1,16
	j	.L122
.L125:
	lui	a5,%hi(shipx)
	lhu	s0,%lo(shipx)(a5)
	addi	s0,s0,-10
	slli	s0,s0,16
	srai	s0,s0,16
	lui	a5,%hi(shipy)
	lh	s1,%lo(shipy)(a5)
	j	.L122
.L123:
	lui	a5,%hi(shipx)
	lhu	s0,%lo(shipx)(a5)
	addi	s0,s0,-10
	slli	s0,s0,16
	srai	s0,s0,16
	lui	a5,%hi(shipy)
	lhu	s1,%lo(shipy)(a5)
	addi	s1,s1,-10
	slli	s1,s1,16
	srai	s1,s1,16
	j	.L122
	.size	fire_bullet, .-fire_bullet
	.align	1
	.globl	update_bullet
	.type	update_bullet, @function
update_bullet:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s1,4(sp)
	lui	s0,%hi(.LANCHOR0)
	addi	s0,s0,%lo(.LANCHOR0)
	lui	s1,%hi(bulletdirection)
	lh	a5,%lo(bulletdirection)(s1)
	slli	a5,a5,1
	add	a5,s0,a5
	lhu	a2,1816(a5)
	li	a1,12
	li	a0,0
	call	update_sprite
	lh	a5,%lo(bulletdirection)(s1)
	slli	a5,a5,1
	add	a5,s0,a5
	lhu	a2,1816(a5)
	li	a1,12
	li	a0,1
	call	update_sprite
	lui	s1,%hi(ufo_bullet_direction)
	lbu	a5,%lo(ufo_bullet_direction)(s1)
	slli	a5,a5,1
	add	a5,s0,a5
	lhu	a2,1816(a5)
	li	a1,10
	li	a0,0
	call	update_sprite
	lbu	a5,%lo(ufo_bullet_direction)(s1)
	slli	a5,a5,1
	add	s0,s0,a5
	lhu	a2,1816(s0)
	li	a1,10
	li	a0,1
	call	update_sprite
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
	.size	update_bullet, .-update_bullet
	.section	.rodata.str1.4
	.align	2
.LC2:
	.string	"         Welcome to Risc-ICE-V Asteroids        "
	.align	2
.LC3:
	.string	"By @robng15 (Twitter) from Whitebridge, Scotland"
	.align	2
.LC4:
	.string	"                 Press UP to start              "
	.align	2
.LC5:
	.string	"          Written in Silice by @sylefeb         "
	.text
	.align	1
	.globl	beepboop
	.type	beepboop, @function
beepboop:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	lui	a5,%hi(last_timer)
	lh	s0,%lo(last_timer)(a5)
	call	get_timer1hz
	bne	s0,a0,.L145
.L135:
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
.L145:
	call	draw_score
	call	get_timer1hz
	lui	s0,%hi(last_timer)
	sh	a0,%lo(last_timer)(s0)
	li	a0,5
	call	tilemap_scrollwrapclear
	lhu	a5,%lo(last_timer)(s0)
	andi	a5,a5,3
	li	a4,2
	beq	a5,a4,.L137
	bgtu	a5,a4,.L138
	beq	a5,zero,.L139
	li	a4,1
	bne	a5,a4,.L135
	lui	a5,%hi(lives)
	lhu	a5,%lo(lives)(a5)
	bne	a5,zero,.L135
	li	a3,15
	li	a2,64
	li	a1,18
	li	a0,16
	call	tpu_set
	lui	a0,%hi(.LC3)
	addi	a0,a0,%lo(.LC3)
	call	tpu_outputstring
	j	.L135
.L139:
	lui	a5,%hi(lives)
	lhu	a5,%lo(lives)(a5)
	beq	a5,zero,.L141
	li	a3,500
	li	a2,1
	li	a1,0
	li	a0,1
	call	beep
	j	.L135
.L141:
	li	a3,3
	li	a2,64
	li	a1,18
	li	a0,16
	call	tpu_set
	lui	a0,%hi(.LC2)
	addi	a0,a0,%lo(.LC2)
	call	tpu_outputstring
	j	.L135
.L137:
	lui	a5,%hi(lives)
	lhu	a5,%lo(lives)(a5)
	beq	a5,zero,.L142
	li	a3,500
	li	a2,2
	li	a1,0
	li	a0,1
	call	beep
	j	.L135
.L142:
	li	a3,60
	li	a2,64
	li	a1,18
	li	a0,16
	call	tpu_set
	lui	a0,%hi(.LC4)
	addi	a0,a0,%lo(.LC4)
	call	tpu_outputstring
	j	.L135
.L138:
	lui	a5,%hi(lives)
	lhu	a5,%lo(lives)(a5)
	beq	a5,zero,.L146
.L143:
	li	a0,6
	call	tilemap_scrollwrapclear
	j	.L135
.L146:
	li	a3,48
	li	a2,64
	li	a1,18
	li	a0,16
	call	tpu_set
	lui	a0,%hi(.LC5)
	addi	a0,a0,%lo(.LC5)
	call	tpu_outputstring
	j	.L143
	.size	beepboop, .-beepboop
	.align	1
	.globl	spawn_asteroid
	.type	spawn_asteroid, @function
spawn_asteroid:
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
	mv	s1,a0
	mv	s2,a1
	mv	s3,a2
	call	find_asteroid_space
	li	a5,255
	beq	a0,a5,.L147
	mv	s0,a0
	mv	s4,a0
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	add	a5,a5,a0
	sb	s1,0(a5)
	li	a5,2
	li	a0,4
	beq	s1,a5,.L149
	li	a0,8
.L149:
	call	rng
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	add	a5,a5,s4
	sb	a0,20(a5)
	sltiu	s7,s0,10
	xori	s7,s7,1
	li	a5,9
	bleu	s0,a5,.L150
	addi	s0,s0,-10
	andi	s0,s0,0xff
.L150:
	li	a0,31
	call	rng
	mv	s4,a0
	li	a0,16
	call	rng
	mv	s5,a0
	li	a0,16
	call	rng
	mv	s6,a0
	li	a0,7
	call	rng
	addi	a7,s1,-2
	addi	a5,s3,-8
	add	a5,s6,a5
	addi	s2,s2,-8
	add	s2,s5,s2
	addi	a3,s4,32
	seqz	a7,a7
	andi	a6,a0,0xff
	slli	a5,a5,16
	srai	a5,a5,16
	slli	a4,s2,16
	srai	a4,a4,16
	andi	a3,a3,0xff
	li	a2,1
	mv	a1,s0
	mv	a0,s7
	call	set_sprite
.L147:
	lw	ra,44(sp)
	lw	s0,40(sp)
	lw	s1,36(sp)
	lw	s2,32(sp)
	lw	s3,28(sp)
	lw	s4,24(sp)
	lw	s5,20(sp)
	lw	s6,16(sp)
	lw	s7,12(sp)
	addi	sp,sp,48
	jr	ra
	.size	spawn_asteroid, .-spawn_asteroid
	.align	1
	.globl	check_ufo_bullet_hit
	.type	check_ufo_bullet_hit, @function
check_ufo_bullet_hit:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	sw	s5,4(sp)
	sw	s6,0(sp)
	li	a1,10
	li	a0,0
	call	get_sprite_collision
	andi	a0,a0,1023
	bne	a0,zero,.L154
	li	a1,10
	li	a0,1
	call	get_sprite_collision
	andi	a0,a0,1023
	beq	a0,zero,.L153
.L154:
	li	a3,500
	li	a2,8
	li	a1,4
	li	a0,2
	call	beep
	li	s0,0
	li	s3,255
	li	a0,0
	li	a1,0
	li	s1,20
	li	s2,9
	j	.L156
.L157:
	mv	s0,a5
.L156:
	call	get_sprite_collision
	andi	a0,a0,1024
	beq	a0,zero,.L158
	mv	s3,s0
.L158:
	addi	a5,s0,1
	andi	a5,a5,0xff
	beq	a5,s1,.L169
	sltiu	a0,a5,10
	xori	a0,a0,1
	mv	a1,a5
	bleu	a5,s2,.L157
	addi	s0,s0,-9
	andi	a1,s0,0xff
	j	.L157
.L169:
	li	a5,255
	beq	s3,a5,.L153
	mv	s2,s3
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	add	a5,a5,s3
	lbu	a4,0(a5)
	li	a5,2
	bleu	a4,a5,.L170
.L153:
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
.L170:
	li	a3,0
	li	a2,0
	li	a1,10
	li	a0,0
	call	set_sprite_attribute
	li	a3,0
	li	a2,0
	li	a1,10
	li	a0,1
	call	set_sprite_attribute
	sltiu	s1,s3,10
	xori	s1,s1,1
	li	a5,9
	bleu	s3,a5,.L160
	addi	s3,s3,-10
	andi	s3,s3,0xff
.L160:
	li	a2,3
	mv	a1,s3
	mv	a0,s1
	call	get_sprite_attribute
	mv	s4,a0
	li	a2,4
	mv	a1,s3
	mv	a0,s1
	call	get_sprite_attribute
	mv	s5,a0
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	add	a5,a5,s2
	lbu	a4,0(a5)
	li	a5,2
	beq	a4,a5,.L171
.L161:
	li	a3,7
	li	a2,1
	mv	a1,s3
	mv	a0,s1
	call	set_sprite_attribute
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	add	a5,a5,s2
	li	a4,32
	sb	a4,0(a5)
	j	.L153
.L171:
	lui	a5,%hi(level)
	lhu	a5,%lo(level)(a5)
	mv	s0,a5
	li	a4,2
	bleu	a5,a4,.L162
	li	s0,2
.L162:
	andi	s0,s0,0xff
	li	a4,2
	addi	s6,s0,1
	andi	s6,s6,0xff
	bgtu	a5,a4,.L172
.L165:
	li	s0,0
.L164:
	mv	a2,s5
	mv	a1,s4
	li	a0,1
	call	spawn_asteroid
	addi	s0,s0,1
	blt	s0,s6,.L164
	j	.L161
.L172:
	li	a0,2
	call	rng
	addi	s0,s0,1
	add	s0,s0,a0
	andi	s6,s0,0xff
	bgt	s6,zero,.L165
	j	.L161
	.size	check_ufo_bullet_hit, .-check_ufo_bullet_hit
	.align	1
	.globl	check_hit
	.type	check_hit, @function
check_hit:
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
	li	a1,12
	li	a0,0
	call	get_sprite_collision
	andi	a0,a0,1023
	bne	a0,zero,.L174
	li	a1,12
	li	a0,1
	call	get_sprite_collision
	andi	a0,a0,1023
	beq	a0,zero,.L173
.L174:
	li	a3,500
	li	a2,8
	li	a1,4
	li	a0,2
	call	beep
	li	s0,0
	li	s4,255
	li	a0,0
	li	a1,0
	li	s2,4096
	li	s1,20
	li	s3,9
	j	.L176
.L177:
	mv	s0,a5
.L176:
	call	get_sprite_collision
	and	a0,a0,s2
	slli	a0,a0,16
	srli	a0,a0,16
	beq	a0,zero,.L178
	mv	s4,s0
.L178:
	addi	a5,s0,1
	andi	a5,a5,0xff
	beq	a5,s1,.L193
	sltiu	a0,a5,10
	xori	a0,a0,1
	mv	a1,a5
	bleu	a5,s3,.L177
	addi	a1,s0,-9
	andi	a1,a1,0xff
	j	.L177
.L193:
	li	a5,255
	beq	s4,a5,.L180
	mv	s5,s4
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	add	a5,a5,s4
	lbu	a4,0(a5)
	li	a5,2
	bleu	a4,a5,.L194
.L180:
	mv	s1,s4
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	add	a5,a5,s4
	lbu	a4,0(a5)
	li	a5,3
	beq	a4,a5,.L195
.L173:
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
	addi	sp,sp,48
	jr	ra
.L194:
	li	a3,0
	li	a2,0
	li	a1,12
	li	a0,0
	call	set_sprite_attribute
	li	a3,0
	li	a2,0
	li	a1,12
	li	a0,1
	call	set_sprite_attribute
	lui	a3,%hi(score)
	lhu	a5,%lo(score)(a3)
	addi	a5,a5,3
	lui	a4,%hi(.LANCHOR1)
	addi	a4,a4,%lo(.LANCHOR1)
	add	a4,a4,s4
	lbu	a4,0(a4)
	sub	a5,a5,a4
	sh	a5,%lo(score)(a3)
	sltiu	s1,s4,10
	xori	s1,s1,1
	li	a5,9
	bleu	s4,a5,.L181
	addi	s4,s4,-10
	andi	s4,s4,0xff
.L181:
	li	a2,2
	mv	a1,s4
	mv	a0,s1
	call	get_sprite_attribute
	andi	s6,a0,0xff
	li	a2,3
	mv	a1,s4
	mv	a0,s1
	call	get_sprite_attribute
	mv	s2,a0
	li	a2,4
	mv	a1,s4
	mv	a0,s1
	call	get_sprite_attribute
	mv	s3,a0
	li	a2,5
	mv	a1,s4
	mv	a0,s1
	call	get_sprite_attribute
	andi	s7,a0,0xff
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	add	a5,a5,s5
	lbu	a4,0(a5)
	li	a5,2
	beq	a4,a5,.L196
.L182:
	mv	a7,s7
	li	a6,7
	mv	a5,s3
	mv	a4,s2
	mv	a3,s6
	li	a2,1
	mv	a1,s4
	mv	a0,s1
	call	set_sprite
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	add	a5,a5,s5
	li	a4,32
	sb	a4,0(a5)
	j	.L173
.L196:
	lui	a5,%hi(level)
	lhu	a5,%lo(level)(a5)
	mv	s0,a5
	li	a4,2
	bleu	a5,a4,.L183
	li	s0,2
.L183:
	andi	s0,s0,0xff
	li	a4,2
	addi	s8,s0,1
	andi	s8,s8,0xff
	bgtu	a5,a4,.L197
.L188:
	li	s0,0
.L185:
	mv	a2,s3
	mv	a1,s2
	li	a0,1
	call	spawn_asteroid
	addi	s0,s0,1
	blt	s0,s8,.L185
	j	.L182
.L197:
	li	a0,2
	call	rng
	addi	s0,s0,1
	add	s0,s0,a0
	andi	s8,s0,0xff
	bgt	s8,zero,.L188
	j	.L182
.L195:
	lui	a5,%hi(level)
	lhu	a3,%lo(level)(a5)
	li	a4,1
	li	a5,10
	bleu	a3,a4,.L186
	li	a5,20
.L186:
	lui	a4,%hi(score)
	lhu	a3,%lo(score)(a4)
	add	a5,a5,a3
	sh	a5,%lo(score)(a4)
	li	a3,0
	li	a2,0
	li	a1,12
	li	a0,0
	call	set_sprite_attribute
	li	a3,0
	li	a2,0
	li	a1,12
	li	a0,1
	call	set_sprite_attribute
	sltiu	s0,s4,10
	xori	s0,s0,1
	li	a5,9
	bleu	s4,a5,.L187
	addi	s4,s4,-10
	andi	s4,s4,0xff
.L187:
	li	a2,3
	mv	a1,s4
	mv	a0,s0
	call	get_sprite_attribute
	li	a2,4
	mv	a1,s4
	mv	a0,s0
	call	get_sprite_attribute
	li	a3,7
	li	a2,1
	mv	a1,s4
	mv	a0,s0
	call	set_sprite_attribute
	li	a3,48
	li	a2,2
	mv	a1,s4
	mv	a0,s0
	call	set_sprite_attribute
	li	a0,0
	call	set_ufo_sprite
	lui	a5,%hi(ufo_sprite_number)
	li	a4,-1
	sb	a4,%lo(ufo_sprite_number)(a5)
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	add	a5,a5,s1
	li	a4,32
	sb	a4,0(a5)
	j	.L173
	.size	check_hit, .-check_hit
	.align	1
	.globl	check_crash
	.type	check_crash, @function
check_crash:
	addi	sp,sp,-16
	sw	ra,12(sp)
	li	a1,11
	li	a0,0
	call	get_sprite_collision
	andi	a0,a0,2047
	bne	a0,zero,.L199
	li	a1,11
	li	a0,1
	call	get_sprite_collision
	andi	a0,a0,2047
	beq	a0,zero,.L198
.L199:
	li	a1,10
	li	a0,0
	call	get_sprite_collision
	andi	a0,a0,1
	bne	a0,zero,.L201
	li	a1,10
	li	a0,1
	call	get_sprite_collision
	andi	a0,a0,1
	beq	a0,zero,.L202
.L201:
	li	a3,0
	li	a2,0
	li	a1,10
	li	a0,0
	call	set_sprite_attribute
	li	a3,0
	li	a2,0
	li	a1,10
	li	a0,1
	call	set_sprite_attribute
.L202:
	li	a3,1000
	li	a2,1
	li	a1,4
	li	a0,2
	call	beep
	li	a0,1
	call	set_ship_sprites
	li	a3,0
	li	a2,1
	li	a1,10
	li	a0,0
	call	set_sprite_attribute
	li	a3,1
	li	a2,1
	li	a1,10
	li	a0,1
	call	set_sprite_attribute
	lui	a5,%hi(resetship)
	li	a4,75
	sh	a4,%lo(resetship)(a5)
.L198:
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	check_crash, .-check_crash
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-80
	sw	ra,76(sp)
	sw	s0,72(sp)
	sw	s1,68(sp)
	sw	s2,64(sp)
	sw	s3,60(sp)
	sw	s4,56(sp)
	sw	s5,52(sp)
	sw	s6,48(sp)
	sw	s7,44(sp)
	sw	s8,40(sp)
	sw	s9,36(sp)
	sw	s10,32(sp)
	sw	s11,28(sp)
	j	.L205
.L206:
	call	inputcharacter
.L205:
	call	inputcharacter_available
	mv	s9,a0
	bne	a0,zero,.L206
	call	setup_game
	li	s1,4
	li	s11,0
	li	s10,0
	lui	s3,%hi(counter)
	lui	s4,%hi(ufo_sprite_number)
	lui	s5,%hi(lives)
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	sw	a5,12(sp)
	lui	s6,%hi(level)
	j	.L258
.L287:
	li	a3,32
	li	a2,63
	li	a1,3
	li	a0,2
	call	beep
	j	.L208
.L288:
	li	a0,4
	call	rng
	li	a5,2
	beq	a0,a5,.L211
	bgtu	a0,a5,.L212
	beq	a0,zero,.L280
	li	a0,480
	call	rng
	slli	s11,a0,16
	srai	s11,s11,16
	li	s10,-639
	j	.L216
.L212:
	li	a5,3
	bne	a0,a5,.L216
	li	a0,640
	call	rng
	slli	s10,a0,16
	srai	s10,s10,16
	li	s11,479
	j	.L216
.L280:
	li	a0,480
	call	rng
	slli	s11,a0,16
	srai	s11,s11,16
	li	s10,-31
.L216:
	lw	a5,12(sp)
	add	s2,a5,s0
	li	a5,2
	sb	a5,0(s2)
	li	a0,4
	call	rng
	sb	a0,20(s2)
	sltiu	s7,s0,10
	xori	s7,s7,1
	li	a5,9
	bleu	s0,a5,.L217
	addi	s0,s0,-10
	andi	s0,s0,0xff
.L217:
	li	a0,31
	call	rng
	mv	s2,a0
	li	a0,7
	call	rng
	addi	a3,s2,32
	li	a7,1
	andi	a6,a0,0xff
	mv	a5,s11
	mv	a4,s10
	andi	a3,a3,0xff
	li	a2,1
	mv	a1,s0
	mv	a0,s7
	call	set_sprite
	j	.L210
.L211:
	li	a0,640
	call	rng
	slli	s10,a0,16
	srai	s10,s10,16
	li	s11,-31
	j	.L216
.L289:
	lbu	a4,%lo(ufo_sprite_number)(s4)
	li	a5,255
	bne	a4,a5,.L220
	li	a2,0
	li	a1,10
	li	a0,0
	call	get_sprite_attribute
	bne	a0,zero,.L220
	call	find_asteroid_space
	sb	a0,%lo(ufo_sprite_number)(s4)
	li	a5,255
	beq	a0,a5,.L220
	lui	s2,%hi(shipy)
.L222:
	li	a0,416
	call	rng
	addi	s0,a0,32
	slli	s0,s0,16
	srai	s0,s0,16
	lh	a5,%lo(shipy)(s2)
	addi	a4,a5,-64
	blt	s0,a4,.L221
	addi	a5,a5,64
	ble	s0,a5,.L222
.L221:
	li	a0,2
	call	rng
	lui	a5,%hi(ufo_leftright)
	sb	a0,%lo(ufo_leftright)(a5)
	li	a0,1
	call	set_ufo_sprite
	lbu	a1,%lo(ufo_sprite_number)(s4)
	sltiu	a0,a1,10
	xori	a0,a0,1
	li	a5,9
	bleu	a1,a5,.L223
	addi	a1,a1,-10
	andi	a1,a1,0xff
.L223:
	lui	a5,%hi(ufo_leftright)
	lbu	a3,%lo(ufo_leftright)(a5)
	li	a5,1
	li	a4,639
	beq	a3,a5,.L224
	lhu	a3,%lo(level)(s6)
	li	a4,-31
	bleu	a3,a5,.L224
	li	a4,-15
.L224:
	lhu	a7,%lo(level)(s6)
	sltiu	a7,a7,2
	li	a6,0
	mv	a5,s0
	li	a3,19
	li	a2,1
	call	set_sprite
	lbu	a5,%lo(ufo_sprite_number)(s4)
	lw	a4,12(sp)
	add	a5,a4,a5
	li	a4,3
	sb	a4,0(a5)
	j	.L220
.L290:
	li	a2,0
	li	a1,10
	li	a0,0
	call	get_sprite_attribute
	bne	a0,zero,.L226
	lbu	a4,%lo(ufo_sprite_number)(s4)
	li	a5,255
	beq	a4,a5,.L226
	lhu	a5,%lo(level)(s6)
	bne	a5,zero,.L227
	lhu	a5,%lo(lives)(s5)
	bne	a5,zero,.L228
.L227:
	li	a3,32
	li	a2,63
	li	a1,4
	li	a0,2
	call	beep
	lbu	a1,%lo(ufo_sprite_number)(s4)
	sltiu	a0,a1,10
	xori	a0,a0,1
	li	a5,9
	bleu	a1,a5,.L229
	addi	a1,a1,-10
	andi	a1,a1,0xff
.L229:
	li	a2,3
	call	get_sprite_attribute
	slli	s0,a0,16
	srli	s0,s0,16
	lhu	a3,%lo(level)(s6)
	li	a4,1
	li	a5,16
	bleu	a3,a4,.L230
	li	a5,8
.L230:
	add	s0,s0,a5
	slli	s0,s0,16
	srai	s0,s0,16
	lbu	a1,%lo(ufo_sprite_number)(s4)
	sltiu	a0,a1,10
	xori	a0,a0,1
	li	a5,9
	bleu	a1,a5,.L231
	addi	a1,a1,-10
	andi	a1,a1,0xff
.L231:
	li	a2,4
	call	get_sprite_attribute
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	bge	a5,a0,.L232
	addi	a0,a0,-10
	slli	s2,a0,16
	srai	s2,s2,16
.L233:
	lui	a4,%hi(shipx)
	lh	a4,%lo(shipx)(a4)
	blt	a4,s0,.L235
	slt	a5,a5,s2
	neg	a5,a5
	andi	a5,a5,254
	addi	a5,a5,3
	lui	a4,%hi(ufo_bullet_direction)
	sb	a5,%lo(ufo_bullet_direction)(a4)
.L237:
	li	a7,0
	li	a6,0
	mv	a5,s2
	mv	a4,s0
	li	a3,48
	li	a2,1
	li	a1,10
	li	a0,0
	call	set_sprite
	li	a7,0
	li	a6,1
	mv	a5,s2
	mv	a4,s0
	li	a3,60
	li	a2,1
	li	a1,10
	li	a0,1
	call	set_sprite
	j	.L226
.L232:
	lhu	a2,%lo(level)(s6)
	li	a3,1
	li	a4,20
	bleu	a2,a3,.L234
	li	a4,10
.L234:
	add	a4,a4,a0
	slli	s2,a4,16
	srai	s2,s2,16
	j	.L233
.L228:
	lui	a5,%hi(resetship)
	lh	s0,%lo(resetship)(a5)
	bne	s0,zero,.L239
	lw	a5,%lo(counter)(s3)
	andi	a5,a5,3
	beq	a5,zero,.L281
.L240:
	li	a2,0
	li	a1,12
	li	a0,0
	call	get_sprite_attribute
	beq	a0,zero,.L282
.L244:
	call	get_buttons
	andi	a0,a0,4
	bne	a0,zero,.L283
.L245:
	li	a0,63
	call	draw_ship
	call	check_crash
	j	.L246
.L281:
	call	get_buttons
	andi	a0,a0,32
	beq	a0,zero,.L241
	lui	a5,%hi(shipdirection)
	lh	a5,%lo(shipdirection)(a5)
	li	a4,7
	beq	a5,zero,.L242
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L242:
	lui	a5,%hi(shipdirection)
	sh	a4,%lo(shipdirection)(a5)
.L241:
	call	get_buttons
	andi	a0,a0,64
	beq	a0,zero,.L240
	lui	a5,%hi(shipdirection)
	lh	a5,%lo(shipdirection)(a5)
	li	a4,7
	beq	a5,a4,.L243
	addi	a5,a5,1
	slli	s0,a5,16
	srai	s0,s0,16
.L243:
	lui	a5,%hi(shipdirection)
	sh	s0,%lo(shipdirection)(a5)
	j	.L240
.L282:
	call	get_buttons
	andi	a0,a0,2
	beq	a0,zero,.L244
	call	fire_bullet
	j	.L244
.L283:
	call	move_ship
	j	.L245
.L248:
	li	a3,0
	li	a2,0
	call	set_sprite_attribute
	addi	s0,s0,1
	slli	s0,s0,16
	srli	s0,s0,16
	addi	s1,s1,1
	addi	s2,s2,1
	beq	s0,s7,.L284
.L249:
	sb	zero,0(s1)
	sb	zero,0(s2)
	sltiu	a0,s0,10
	xori	a0,a0,1
	andi	a1,s0,0xff
	bleu	s0,s8,.L248
	addi	a1,s0,-10
	andi	a1,a1,0xff
	j	.L248
.L284:
	li	a3,0
	li	a2,0
	li	a1,10
	li	a0,0
	call	set_sprite_attribute
	li	a3,0
	li	a2,0
	li	a1,10
	li	a0,1
	call	set_sprite_attribute
	li	a3,0
	li	a2,0
	li	a1,12
	li	a0,0
	call	set_sprite_attribute
	li	a3,0
	li	a2,0
	li	a1,12
	li	a0,1
	call	set_sprite_attribute
	call	gpu_cs
	call	tpu_cs
	sw	zero,%lo(counter)(s3)
	li	a5,3
	sh	a5,%lo(lives)(s5)
	lui	a5,%hi(score)
	sh	zero,%lo(score)(a5)
	sh	zero,%lo(level)(s6)
	lui	a5,%hi(shipx)
	li	a4,312
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	li	a4,232
	sh	a4,%lo(shipy)(a5)
	lui	a5,%hi(shipdirection)
	sh	zero,%lo(shipdirection)(a5)
	lui	a5,%hi(resetship)
	sh	zero,%lo(resetship)(a5)
	lui	a5,%hi(bulletdirection)
	sh	zero,%lo(bulletdirection)(a5)
	li	a5,-1
	sb	a5,%lo(ufo_sprite_number)(s4)
	lui	a5,%hi(ufo_leftright)
	sb	zero,%lo(ufo_leftright)(a5)
	call	draw_lives
	call	set_asteroid_sprites
	li	a0,0
	call	set_ship_sprites
	call	set_bullet_sprites
	call	set_ufo_bullet_sprites
	li	s1,4
.L239:
	lui	a5,%hi(resetship)
	lhu	a5,%lo(resetship)(a5)
	addi	a5,a5,-1
	slli	a5,a5,16
	srli	a5,a5,16
	li	a4,15
	bleu	a5,a4,.L250
	lhu	a5,%lo(lives)(s5)
	bne	a5,zero,.L251
.L250:
	li	a0,21
	call	draw_ship
	lui	a5,%hi(resetship)
	lhu	a5,%lo(resetship)(a5)
	addi	a5,a5,-1
	slli	a5,a5,16
	srli	a5,a5,16
	li	a4,15
	bleu	a5,a4,.L285
.L252:
	lui	a5,%hi(resetship)
	lh	a4,%lo(resetship)(a5)
	li	a5,16
	bgt	a4,a5,.L259
.L254:
	lhu	a5,%lo(lives)(s5)
	beq	a5,zero,.L286
.L246:
	call	update_bullet
	call	check_hit
	call	check_ufo_bullet_hit
	call	move_asteroids
	call	wait_timer1khz
.L258:
	lw	a5,%lo(counter)(s3)
	addi	a5,a5,1
	sw	a5,%lo(counter)(s3)
	lbu	a3,%lo(ufo_sprite_number)(s4)
	li	a4,255
	mv	a0,s9
	beq	a3,a4,.L207
	slli	a0,a5,26
	srai	a0,a0,31
	andi	a0,a0,0xff
.L207:
	call	set_leds
	lbu	a4,%lo(ufo_sprite_number)(s4)
	li	a5,255
	beq	a4,a5,.L208
	lw	a5,%lo(counter)(s3)
	andi	a5,a5,64
	beq	a5,zero,.L208
	lhu	a5,%lo(lives)(s5)
	bne	a5,zero,.L287
.L208:
	beq	s1,zero,.L209
	call	find_asteroid_space
	mv	s0,a0
	li	a5,255
	bne	a0,a5,.L288
.L210:
	addi	s1,s1,-1
	slli	s1,s1,16
	srli	s1,s1,16
.L209:
	call	count_asteroids
	bne	a0,zero,.L218
	lhu	a5,%lo(level)(s6)
	addi	a5,a5,1
	slli	a5,a5,16
	srli	a5,a5,16
	sh	a5,%lo(level)(s6)
	mv	s1,a5
	li	a4,4
	bleu	a5,a4,.L219
	li	s1,4
.L219:
	addi	s1,s1,4
	slli	s1,s1,16
	srli	s1,s1,16
.L218:
	call	await_vblank
	li	a0,8
	call	set_timer1khz
	call	beepboop
	li	a0,512
	call	rng
	li	a5,1
	beq	a0,a5,.L289
.L220:
	lhu	a0,%lo(level)(s6)
	li	a5,3
	sgtu	a0,a0,a5
	neg	a0,a0
	andi	a0,a0,-64
	addi	a0,a0,128
	call	rng
	li	a5,1
	beq	a0,a5,.L290
.L226:
	lhu	s0,%lo(lives)(s5)
	bne	s0,zero,.L228
	call	get_buttons
	andi	a0,a0,8
	beq	a0,zero,.L239
	lui	a5,%hi(.LANCHOR1)
	addi	s1,a5,%lo(.LANCHOR1)
	addi	s2,s1,20
	li	s8,9
	li	s7,20
	j	.L249
.L285:
	li	a1,11
	li	a0,0
	call	get_sprite_collision
	andi	a0,a0,2047
	bne	a0,zero,.L252
	li	a1,11
	li	a0,1
	call	get_sprite_collision
	andi	a0,a0,2047
	bne	a0,zero,.L252
	lui	a4,%hi(resetship)
	lhu	a5,%lo(resetship)(a4)
	addi	a5,a5,-1
	slli	a5,a5,16
	srai	a5,a5,16
	sh	a5,%lo(resetship)(a4)
	beq	a5,zero,.L291
.L253:
	lhu	a5,%lo(lives)(s5)
	beq	a5,zero,.L292
.L251:
	lui	a5,%hi(resetship)
	lh	a4,%lo(resetship)(a5)
	li	a5,16
	ble	a4,a5,.L246
.L259:
	li	a2,1024
	li	a1,11
	li	a0,0
	call	update_sprite
	li	a2,1024
	li	a1,11
	li	a0,1
	call	update_sprite
	lw	a3,%lo(counter)(s3)
	andi	a3,a3,1
	neg	a3,a3
	andi	a3,a3,-12
	addi	a3,a3,60
	li	a2,2
	li	a1,11
	li	a0,0
	call	set_sprite_attribute
	lw	a3,%lo(counter)(s3)
	andi	a3,a3,1
	neg	a3,a3
	andi	a3,a3,12
	addi	a3,a3,48
	li	a2,2
	li	a1,11
	li	a0,1
	call	set_sprite_attribute
	lui	a4,%hi(resetship)
	lhu	a5,%lo(resetship)(a4)
	addi	a5,a5,-1
	slli	a5,a5,16
	srai	a5,a5,16
	sh	a5,%lo(resetship)(a4)
	li	a4,16
	beq	a5,a4,.L293
.L257:
	lui	a5,%hi(shipx)
	li	a4,312
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	li	a4,232
	sh	a4,%lo(shipy)(a5)
	lui	a5,%hi(shipdirection)
	sh	zero,%lo(shipdirection)(a5)
	j	.L254
.L291:
	call	gpu_cs
	lhu	a5,%lo(lives)(s5)
	addi	a5,a5,-1
	sh	a5,%lo(lives)(s5)
	call	draw_lives
	j	.L253
.L292:
	call	risc_ice_v_logo
	j	.L252
.L293:
	li	a0,0
	call	set_ship_sprites
	j	.L257
.L286:
	li	a0,3
	call	bitmap_scrollwrap
	li	a0,4
	call	bitmap_scrollwrap
	j	.L246
.L235:
	slt	a5,a5,s2
	neg	a5,a5
	andi	a5,a5,-254
	addi	a5,a5,261
	lui	a4,%hi(ufo_bullet_direction)
	sb	a5,%lo(ufo_bullet_direction)(a4)
	j	.L237
	.size	main, .-main
	.globl	tilemap_bitmap
	.globl	bullet_bitmap
	.globl	ship_bitmap
	.globl	ufo_bullet_bitmap
	.globl	ufo_bitmap
	.globl	asteroid_bitmap
	.globl	ufo_directions
	.globl	asteroid_directions
	.globl	bullet_directions
	.globl	last_timer
	.globl	ufo_bullet_direction
	.globl	ufo_leftright
	.globl	ufo_sprite_number
	.globl	asteroid_direction
	.globl	asteroid_active
	.globl	bulletdirection
	.globl	resetship
	.globl	shipdirection
	.globl	shipy
	.globl	shipx
	.globl	counter
	.globl	level
	.globl	score
	.globl	lives
	.data
	.align	2
	.set	.LANCHOR0,. + 0
	.type	asteroid_bitmap, @object
	.size	asteroid_bitmap, 256
asteroid_bitmap:
	.half	2032
	.half	4088
	.half	8190
	.half	8191
	.half	16383
	.half	-1
	.half	-2
	.half	-4
	.half	-1
	.half	32767
	.half	32767
	.half	32766
	.half	16380
	.half	16380
	.half	4088
	.half	240
	.half	4104
	.half	15388
	.half	32542
	.half	-1
	.half	32766
	.half	32766
	.half	16376
	.half	16368
	.half	8184
	.half	4088
	.half	8188
	.half	32766
	.half	-1
	.half	32766
	.half	15868
	.half	6264
	.half	1927
	.half	8078
	.half	4062
	.half	26620
	.half	-4
	.half	-2
	.half	-1
	.half	32767
	.half	32764
	.half	16376
	.half	16380
	.half	32766
	.half	-1
	.half	-2
	.half	16380
	.half	29688
	.half	6144
	.half	16280
	.half	16380
	.half	8190
	.half	8190
	.half	8190
	.half	32766
	.half	-1
	.half	-1
	.half	-1
	.half	-2
	.half	-2
	.half	16380
	.half	8176
	.half	1984
	.half	384
	.half	4080
	.half	8188
	.half	8190
	.half	16382
	.half	16383
	.half	32767
	.half	32767
	.half	-1
	.half	-1
	.half	-2
	.half	-4
	.half	32764
	.half	16380
	.half	16368
	.half	16368
	.half	2016
	.half	0
	.half	0
	.half	0
	.half	384
	.half	960
	.half	992
	.half	2040
	.half	2044
	.half	4092
	.half	8188
	.half	8184
	.half	4088
	.half	496
	.half	0
	.half	0
	.half	0
	.half	1536
	.half	4064
	.half	8184
	.half	16380
	.half	32766
	.half	-2
	.half	4095
	.half	8191
	.half	8191
	.half	16383
	.half	32767
	.half	32766
	.half	15996
	.half	15416
	.half	14336
	.half	12288
	.half	32
	.half	16902
	.half	6
	.half	6176
	.half	6144
	.half	129
	.half	1024
	.half	16400
	.half	0
	.half	768
	.half	770
	.half	24592
	.half	24576
	.half	0
	.half	1049
	.half	-32744
	.type	ship_bitmap, @object
	.size	ship_bitmap, 512
ship_bitmap:
	.half	256
	.half	256
	.half	896
	.half	1984
	.half	1984
	.half	4064
	.half	4064
	.half	4064
	.half	8176
	.half	8176
	.half	8176
	.half	16376
	.half	16376
	.half	32508
	.half	30780
	.half	0
	.half	1
	.half	30
	.half	126
	.half	2046
	.half	8190
	.half	-4
	.half	32764
	.half	16376
	.half	8184
	.half	2040
	.half	1016
	.half	496
	.half	496
	.half	224
	.half	96
	.half	32
	.half	0
	.half	24576
	.half	30720
	.half	32512
	.half	32752
	.half	32760
	.half	16376
	.half	8191
	.half	16376
	.half	16376
	.half	32752
	.half	32752
	.half	30720
	.half	24576
	.half	0
	.half	0
	.half	32
	.half	96
	.half	224
	.half	496
	.half	496
	.half	1016
	.half	2040
	.half	8184
	.half	16376
	.half	32764
	.half	-4
	.half	8190
	.half	2046
	.half	126
	.half	30
	.half	1
	.half	0
	.half	15390
	.half	16254
	.half	8188
	.half	8188
	.half	4088
	.half	4088
	.half	4088
	.half	2032
	.half	2032
	.half	2032
	.half	992
	.half	992
	.half	448
	.half	128
	.half	128
	.half	1024
	.half	1536
	.half	1792
	.half	3968
	.half	3968
	.half	8128
	.half	8160
	.half	8184
	.half	8188
	.half	16382
	.half	16383
	.half	32760
	.half	32736
	.half	32256
	.half	30720
	.half	-32768
	.half	0
	.half	0
	.half	6
	.half	30
	.half	254
	.half	2046
	.half	8188
	.half	16380
	.half	-8
	.half	16380
	.half	8188
	.half	2046
	.half	254
	.half	30
	.half	6
	.half	0
	.half	-32768
	.half	30720
	.half	32256
	.half	32736
	.half	32760
	.half	16383
	.half	16382
	.half	8188
	.half	8184
	.half	8160
	.half	8128
	.half	3968
	.half	3968
	.half	1792
	.half	1536
	.half	1024
	.half	32
	.half	16902
	.half	6
	.half	6176
	.half	6144
	.half	129
	.half	1024
	.half	16400
	.half	0
	.half	768
	.half	770
	.half	24592
	.half	24576
	.half	0
	.half	1049
	.half	-32744
	.half	0
	.half	768
	.half	770
	.half	24592
	.half	24576
	.half	0
	.half	1049
	.half	-32744
	.half	32
	.half	16902
	.half	6
	.half	6176
	.half	6144
	.half	129
	.half	1024
	.half	16400
	.half	32
	.half	16902
	.half	6
	.half	6176
	.half	6144
	.half	129
	.half	1024
	.half	16400
	.half	0
	.half	768
	.half	770
	.half	24592
	.half	24576
	.half	0
	.half	1049
	.half	-32744
	.half	0
	.half	768
	.half	770
	.half	24592
	.half	24576
	.half	0
	.half	1049
	.half	-32744
	.half	32
	.half	16902
	.half	6
	.half	6176
	.half	6144
	.half	129
	.half	1024
	.half	16400
	.half	32
	.half	16902
	.half	6
	.half	6176
	.half	6144
	.half	129
	.half	1024
	.half	16400
	.half	0
	.half	768
	.half	770
	.half	24592
	.half	24576
	.half	0
	.half	1049
	.half	-32744
	.half	0
	.half	768
	.half	770
	.half	24592
	.half	24576
	.half	0
	.half	1049
	.half	-32744
	.half	32
	.half	16902
	.half	6
	.half	6176
	.half	6144
	.half	129
	.half	1024
	.half	16400
	.half	32
	.half	16902
	.half	6
	.half	6176
	.half	6144
	.half	129
	.half	1024
	.half	16400
	.half	0
	.half	768
	.half	770
	.half	24592
	.half	24576
	.half	0
	.half	1049
	.half	-32744
	.half	0
	.half	768
	.half	770
	.half	24592
	.half	24576
	.half	0
	.half	1049
	.half	-32744
	.half	32
	.half	16902
	.half	6
	.half	6176
	.half	6144
	.half	129
	.half	1024
	.half	16400
	.type	bullet_bitmap, @object
	.size	bullet_bitmap, 256
bullet_bitmap:
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	256
	.half	256
	.half	1984
	.half	256
	.half	256
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
	.half	1088
	.half	640
	.half	256
	.half	640
	.half	1088
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
	.half	256
	.half	896
	.half	1984
	.half	896
	.half	256
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
	.half	1344
	.half	896
	.half	1984
	.half	896
	.half	1344
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
	.half	256
	.half	256
	.half	1984
	.half	256
	.half	256
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
	.half	1088
	.half	640
	.half	256
	.half	640
	.half	1088
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
	.half	256
	.half	896
	.half	1984
	.half	896
	.half	256
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
	.half	1344
	.half	896
	.half	1984
	.half	896
	.half	1344
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.type	ufo_bitmap, @object
	.size	ufo_bitmap, 256
ufo_bitmap:
	.half	0
	.half	0
	.half	960
	.half	960
	.half	1952
	.half	4080
	.half	16380
	.half	32766
	.half	-13
	.half	16380
	.half	8184
	.half	4080
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	960
	.half	960
	.half	1888
	.half	4080
	.half	16380
	.half	32766
	.half	-49
	.half	16380
	.half	8184
	.half	4080
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	960
	.half	960
	.half	1760
	.half	4080
	.half	16380
	.half	32766
	.half	-193
	.half	16380
	.half	8184
	.half	4080
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	960
	.half	960
	.half	1520
	.half	4080
	.half	16380
	.half	32766
	.half	-769
	.half	16380
	.half	8184
	.half	4080
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	960
	.half	960
	.half	1952
	.half	4080
	.half	16380
	.half	32766
	.half	-3073
	.half	16380
	.half	8184
	.half	4080
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	960
	.half	960
	.half	1888
	.half	4080
	.half	16380
	.half	32766
	.half	-12289
	.half	16380
	.half	8184
	.half	4080
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	960
	.half	960
	.half	1760
	.half	4080
	.half	16380
	.half	32766
	.half	-1
	.half	16380
	.half	8184
	.half	4080
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	960
	.half	960
	.half	1520
	.half	4080
	.half	16380
	.half	32766
	.half	-1
	.half	16380
	.half	8184
	.half	4080
	.half	0
	.half	0
	.half	0
	.half	0
	.type	ufo_bullet_bitmap, @object
	.size	ufo_bullet_bitmap, 256
ufo_bullet_bitmap:
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	128
	.half	256
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
	.half	0
	.half	256
	.half	128
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
	.half	0
	.half	128
	.half	256
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
	.half	0
	.half	256
	.half	128
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
	.half	0
	.half	128
	.half	256
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
	.half	0
	.half	256
	.half	128
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
	.half	0
	.half	128
	.half	256
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
	.half	0
	.half	256
	.half	128
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.type	tilemap_bitmap, @object
	.size	tilemap_bitmap, 256
tilemap_bitmap:
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	31
	.half	63
	.half	255
	.half	511
	.half	1023
	.half	1023
	.half	2047
	.half	2044
	.half	8177
	.half	14279
	.half	10140
	.half	13297
	.half	8135
	.half	287
	.half	255
	.half	63
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
	.half	0
	.half	0
	.half	0
	.half	-16384
	.half	-4096
	.half	-2048
	.half	-256
	.half	-1792
	.half	-6400
	.half	3072
	.half	29696
	.half	-15360
	.half	7168
	.half	31744
	.half	-2048
	.half	-2048
	.half	-4096
	.half	-8192
	.half	-32768
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
	.half	0
	.half	1
	.half	3
	.half	126
	.half	196
	.half	136
	.half	400
	.half	272
	.half	800
	.half	1009
	.half	3
	.half	6
	.half	5
	.half	34
	.half	8
	.half	1152
	.half	36
	.half	32
	.half	144
	.half	0
	.half	64
	.half	0
	.half	16
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	126
	.half	2018
	.half	7682
	.half	28678
	.half	-6652
	.half	-28916
	.half	6540
	.half	6552
	.half	3864
	.half	1584
	.half	96
	.half	24672
	.half	-12096
	.half	-24192
	.half	17152
	.half	-31232
	.half	2560
	.half	12800
	.half	-15872
	.half	-32256
	.half	-25600
	.half	-4096
	.half	-16384
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.half	0
	.type	asteroid_directions, @object
	.size	asteroid_directions, 24
asteroid_directions:
	.half	993
	.half	33
	.half	63
	.half	1023
	.half	961
	.half	994
	.half	34
	.half	65
	.half	95
	.half	62
	.half	1022
	.half	991
	.type	bullet_directions, @object
	.size	bullet_directions, 16
bullet_directions:
	.half	8000
	.half	8037
	.half	7174
	.half	7333
	.half	7360
	.half	7355
	.half	7194
	.half	8059
	.bss
	.align	2
	.set	.LANCHOR1,. + 0
	.type	asteroid_active, @object
	.size	asteroid_active, 20
asteroid_active:
	.zero	20
	.type	asteroid_direction, @object
	.size	asteroid_direction, 20
asteroid_direction:
	.zero	20
	.section	.sbss,"aw",@nobits
	.align	2
	.type	last_timer, @object
	.size	last_timer, 2
last_timer:
	.zero	2
	.type	ufo_bullet_direction, @object
	.size	ufo_bullet_direction, 1
ufo_bullet_direction:
	.zero	1
	.type	ufo_leftright, @object
	.size	ufo_leftright, 1
ufo_leftright:
	.zero	1
	.type	bulletdirection, @object
	.size	bulletdirection, 2
bulletdirection:
	.zero	2
	.type	resetship, @object
	.size	resetship, 2
resetship:
	.zero	2
	.type	shipdirection, @object
	.size	shipdirection, 2
shipdirection:
	.zero	2
	.zero	2
	.type	counter, @object
	.size	counter, 4
counter:
	.zero	4
	.type	level, @object
	.size	level, 2
level:
	.zero	2
	.type	score, @object
	.size	score, 2
score:
	.zero	2
	.type	lives, @object
	.size	lives, 2
lives:
	.zero	2
	.section	.sdata,"aw"
	.align	2
	.type	ufo_directions, @object
	.size	ufo_directions, 8
ufo_directions:
	.half	7170
	.half	7198
	.half	7172
	.half	7196
	.type	ufo_sprite_number, @object
	.size	ufo_sprite_number, 1
ufo_sprite_number:
	.byte	-1
	.zero	1
	.type	shipy, @object
	.size	shipy, 2
shipy:
	.half	232
	.type	shipx, @object
	.size	shipx, 2
shipx:
	.half	312
	.ident	"GCC: (Arch Linux Repositories) 10.2.0"
