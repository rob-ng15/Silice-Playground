	.file	"asteroids.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	1
	.globl	random_colour
	.type	random_colour, @function
random_colour:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s1,4(sp)
	sw	s2,0(sp)
	li	s2,1
.L3:
	li	a0,4
	call	rng
	andi	s0,a0,0xff
	li	a0,4
	call	rng
	andi	s1,a0,0xff
	li	a0,4
	call	rng
	andi	a0,a0,0xff
	bgtu	s0,s2,.L2
	bgtu	s1,s2,.L2
	bleu	a0,s2,.L3
.L2:
	slli	s0,s0,2
	add	s0,s0,s1
	slli	s0,s0,2
	add	a0,a0,s0
	andi	a0,a0,0xff
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	lw	s2,0(sp)
	addi	sp,sp,16
	jr	ra
	.size	random_colour, .-random_colour
	.align	1
	.globl	random_colour_alt
	.type	random_colour_alt, @function
random_colour_alt:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s1,4(sp)
.L7:
	li	a0,1
	call	rng
	mv	s0,a0
	li	a0,1
	call	rng
	mv	s1,a0
	li	a0,1
	call	rng
	andi	a4,a0,0xff
	andi	a5,s0,0xff
	andi	a0,s1,0xff
	add	a3,a5,a0
	add	a3,a3,a4
	beq	a3,zero,.L7
	slli	a5,a5,2
	add	a5,a5,a0
	slli	a5,a5,2
	add	a0,a4,a5
	andi	a0,a0,0xff
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
	.size	random_colour_alt, .-random_colour_alt
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
	j	.L11
.L12:
	mv	s0,a5
.L11:
	addi	a2,s2,%lo(.LANCHOR0)
	call	set_sprite_bitmaps
	addi	a5,s0,1
	andi	a5,a5,0xff
	beq	a5,s1,.L16
	sltiu	a0,a5,10
	xori	a0,a0,1
	mv	a1,a5
	bleu	a5,s3,.L12
	addi	s0,s0,-9
	andi	a1,s0,0xff
	j	.L12
.L16:
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
	bleu	a1,a5,.L26
	addi	a1,a1,-10
	andi	a1,a1,0xff
.L26:
	bne	a4,zero,.L28
	lui	a2,%hi(.LANCHOR0)
	addi	a2,a2,%lo(.LANCHOR0)
.L27:
	call	set_sprite_bitmaps
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
.L28:
	lui	a2,%hi(.LANCHOR0+1024)
	addi	a2,a2,%lo(.LANCHOR0+1024)
	j	.L27
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
	li	s0,0
	li	a0,9
	call	tilemap_scrollwrapclear
	lui	s2,%hi(.LANCHOR0+1536)
	addi	s2,s2,%lo(.LANCHOR0+1536)
	li	s1,0
	li	s3,8
.L33:
	addi	s1,s1,1
	andi	s1,s1,0xff
	mv	a1,s2
	mv	a0,s1
	call	set_tilemap_bitmap
	addi	s2,s2,32
	bne	s1,s3,.L33
	li	s3,0
	li	s5,21
	li	s4,40
	j	.L35
.L34:
	add	s0,a0,s0
	andi	s0,s0,0xff
	li	a0,10
	call	rng
	add	s1,s3,a0
	andi	s1,s1,0xff
	addi	s7,s1,1
	andi	s7,s7,0xff
	call	random_colour_alt
	mv	s2,a0
	mv	a4,a0
	li	a3,64
	li	a2,1
	mv	a1,s7
	mv	a0,s0
	call	set_tilemap_tile
	addi	s1,s1,2
	andi	s1,s1,0xff
	mv	a4,s2
	li	a3,64
	li	a2,2
	mv	a1,s1
	mv	a0,s0
	call	set_tilemap_tile
	addi	s6,s0,1
	andi	s6,s6,0xff
	mv	a4,s2
	li	a3,64
	li	a2,3
	mv	a1,s7
	mv	a0,s6
	call	set_tilemap_tile
	mv	a4,s2
	li	a3,64
	li	a2,4
	mv	a1,s1
	mv	a0,s6
	call	set_tilemap_tile
	addi	s3,s3,10
	andi	s3,s3,0xff
	beq	s3,s4,.L43
.L35:
	li	a0,18
	call	rng
	andi	a0,a0,0xff
	andi	s0,s0,1
	bne	s0,zero,.L34
	mv	s0,s5
	j	.L34
.L43:
	li	s3,0
	li	s4,40
.L37:
	li	a0,18
	call	rng
	andi	s0,s0,1
	neg	s0,s0
	andi	s0,s0,20
	addi	s0,s0,1
	add	s0,a0,s0
	andi	s0,s0,0xff
	li	a0,10
	call	rng
	add	s1,s3,a0
	andi	s1,s1,0xff
	addi	s6,s1,1
	andi	s6,s6,0xff
	call	random_colour_alt
	mv	s2,a0
	mv	a4,a0
	li	a3,64
	li	a2,5
	mv	a1,s6
	mv	a0,s0
	call	set_tilemap_tile
	addi	s1,s1,2
	andi	s1,s1,0xff
	mv	a4,s2
	li	a3,64
	li	a2,6
	mv	a1,s1
	mv	a0,s0
	call	set_tilemap_tile
	addi	s5,s0,1
	andi	s5,s5,0xff
	mv	a4,s2
	li	a3,64
	li	a2,7
	mv	a1,s6
	mv	a0,s5
	call	set_tilemap_tile
	mv	a4,s2
	li	a3,64
	li	a2,8
	mv	a1,s1
	mv	a0,s5
	call	set_tilemap_tile
	addi	s3,s3,10
	andi	s3,s3,0xff
	bne	s3,s4,.L37
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
	.size	set_tilemap, .-set_tilemap
	.align	1
	.globl	game_over
	.type	game_over, @function
game_over:
	addi	sp,sp,-16
	sw	ra,12(sp)
	call	random_colour
	li	a4,2
	li	a3,71
	li	a2,224
	li	a1,176
	call	gpu_character_blit
	call	random_colour
	li	a4,2
	li	a3,65
	li	a2,232
	li	a1,208
	call	gpu_character_blit
	call	random_colour
	li	a4,2
	li	a3,77
	li	a2,224
	li	a1,240
	call	gpu_character_blit
	call	random_colour
	li	a4,2
	li	a3,69
	li	a2,232
	li	a1,272
	call	gpu_character_blit
	call	random_colour
	li	a4,2
	li	a3,79
	li	a2,224
	li	a1,336
	call	gpu_character_blit
	call	random_colour
	li	a4,2
	li	a3,86
	li	a2,232
	li	a1,368
	call	gpu_character_blit
	call	random_colour
	li	a4,2
	li	a3,69
	li	a2,224
	li	a1,400
	call	gpu_character_blit
	call	random_colour
	li	a4,2
	li	a3,82
	li	a2,232
	li	a1,432
	call	gpu_character_blit
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	game_over, .-game_over
	.align	1
	.globl	risc_ice_v_logo
	.type	risc_ice_v_logo, @function
risc_ice_v_logo:
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
	.size	risc_ice_v_logo, .-risc_ice_v_logo
	.align	1
	.globl	drawfuel
	.type	drawfuel, @function
drawfuel:
	addi	sp,sp,-16
	sw	ra,12(sp)
	beq	a0,zero,.L49
	lui	a5,%hi(fuel)
	lhu	a3,%lo(fuel)(a5)
	srli	a3,a3,2
	li	a4,463
	addi	a3,a3,70
	li	a2,456
	li	a1,70
	li	a0,48
	call	gpu_rectangle
	li	a4,0
	li	a3,70
	li	a2,456
	li	a1,30
	li	a0,48
	call	gpu_character_blit
	li	a4,0
	li	a3,85
	li	a2,456
	li	a1,38
	li	a0,48
	call	gpu_character_blit
	li	a4,0
	li	a3,69
	li	a2,456
	li	a1,46
	li	a0,48
	call	gpu_character_blit
	li	a4,0
	li	a3,76
	li	a2,456
	li	a1,54
	li	a0,48
	call	gpu_character_blit
	li	a4,0
	li	a3,58
	li	a2,456
	li	a1,62
	li	a0,48
	call	gpu_character_blit
.L48:
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
.L49:
	lui	a5,%hi(fuel)
	lhu	a1,%lo(fuel)(a5)
	srli	a1,a1,2
	li	a4,463
	li	a3,320
	li	a2,456
	addi	a1,a1,70
	li	a0,64
	call	gpu_rectangle
	j	.L48
	.size	drawfuel, .-drawfuel
	.align	1
	.globl	drawshield
	.type	drawshield, @function
drawshield:
	addi	sp,sp,-16
	sw	ra,12(sp)
	beq	a0,zero,.L53
	lui	a5,%hi(shield)
	lhu	a3,%lo(shield)(a5)
	addi	a3,a3,70
	li	a4,471
	slli	a3,a3,16
	srai	a3,a3,16
	li	a2,464
	li	a1,70
	li	a0,3
	call	gpu_rectangle
	li	a4,0
	li	a3,83
	li	a2,464
	li	a1,14
	li	a0,3
	call	gpu_character_blit
	li	a4,0
	li	a3,72
	li	a2,464
	li	a1,22
	li	a0,3
	call	gpu_character_blit
	li	a4,0
	li	a3,73
	li	a2,464
	li	a1,30
	li	a0,3
	call	gpu_character_blit
	li	a4,0
	li	a3,69
	li	a2,464
	li	a1,38
	li	a0,3
	call	gpu_character_blit
	li	a4,0
	li	a3,76
	li	a2,464
	li	a1,46
	li	a0,3
	call	gpu_character_blit
	li	a4,0
	li	a3,68
	li	a2,464
	li	a1,54
	li	a0,3
	call	gpu_character_blit
	li	a4,0
	li	a3,58
	li	a2,464
	li	a1,62
	li	a0,3
	call	gpu_character_blit
.L52:
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
.L53:
	lui	a5,%hi(shield)
	lhu	a1,%lo(shield)(a5)
	addi	a1,a1,70
	li	a4,471
	li	a3,320
	li	a2,464
	slli	a1,a1,16
	srai	a1,a1,16
	li	a0,64
	call	gpu_rectangle
	j	.L52
	.size	drawshield, .-drawshield
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
	j	.L61
.L57:
	sltiu	a0,a1,13
	xori	a0,a0,1
.L58:
	addi	a1,a1,-13
	li	a7,0
	li	a6,0
	li	a5,0
	li	a4,0
	li	a3,0
	li	a2,0
	andi	a1,a1,0xff
	call	set_sprite
	bgtu	s0,s6,.L60
.L62:
	addi	s1,s1,1
	addi	s0,s0,1
	andi	s0,s0,0xff
	addi	s2,s2,1
	addi	s3,s3,1
.L61:
	andi	a1,s1,0xff
	bgtu	a1,s4,.L57
	sb	zero,0(s2)
	sb	zero,0(s3)
	sltiu	a0,a1,13
	xori	a0,a0,1
	bgtu	a1,s5,.L58
	li	a7,0
	li	a6,0
	li	a5,0
	li	a4,0
	li	a3,0
	li	a2,0
	li	a0,0
	call	set_sprite
	j	.L62
.L60:
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
	lui	a5,%hi(fuel)
	li	a4,1000
	sh	a4,%lo(fuel)(a5)
	lui	a5,%hi(shield)
	li	a4,250
	sh	a4,%lo(shield)(a5)
	li	a0,1
	call	drawfuel
	li	a0,1
	call	drawshield
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
	j	.L68
.L67:
	seqz	a4,a4
	add	a4,a3,a4
	andi	a3,a4,0xff
	addi	a5,a5,1
	andi	a5,a5,0xff
	addi	a2,a2,1
	beq	a5,a1,.L72
.L68:
	lbu	a4,0(a2)
	bne	a4,zero,.L67
	mv	a0,a5
	j	.L67
.L72:
	li	a5,1
	beq	a3,a5,.L73
.L69:
	ret
.L73:
	li	a0,255
	j	.L69
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
	j	.L83
.L92:
	sltiu	a0,s0,10
	xori	a0,a0,1
	li	a5,9
	mv	a1,s1
	bgtu	s0,a5,.L76
	mv	a1,s0
.L76:
	lbu	a5,0(s4)
	slli	a5,a5,1
	add	a5,s5,a5
	lhu	a2,1792(a5)
	call	update_sprite
	j	.L75
.L93:
	sltiu	s10,s0,10
	xori	s10,s10,1
	li	a5,9
	mv	s11,s1
	bgtu	s0,a5,.L78
	mv	s11,s0
.L78:
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
	bne	a0,zero,.L77
	call	set_ufo_sprite
	sb	zero,0(s2)
	sb	s8,%lo(ufo_sprite_number)(s9)
	j	.L80
.L81:
	lbu	a4,0(s2)
	li	a5,5
	beq	a4,a5,.L90
.L80:
	addi	s0,s0,1
	andi	s0,s0,0xff
	addi	s3,s3,1
	addi	s1,s1,1
	andi	s1,s1,0xff
	addi	s4,s4,1
	li	a5,20
	beq	s0,a5,.L91
.L83:
	mv	s2,s3
	lbu	a5,0(s3)
	addi	a5,a5,-1
	andi	a5,a5,0xff
	li	a4,1
	bleu	a5,a4,.L92
.L75:
	lbu	a4,0(s2)
	li	a5,3
	beq	a4,a5,.L93
.L77:
	lbu	a5,0(s2)
	li	a4,5
	bleu	a5,a4,.L81
	addi	a5,a5,-1
	sb	a5,0(s2)
	j	.L81
.L90:
	sb	zero,0(s2)
	sltiu	a0,s0,10
	xori	a0,a0,1
	li	a5,9
	mv	a1,s1
	bgtu	s0,a5,.L82
	mv	a1,s0
.L82:
	li	a7,0
	li	a6,0
	li	a5,0
	li	a4,0
	li	a3,0
	li	a2,0
	call	set_sprite
	j	.L80
.L91:
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
	j	.L96
.L95:
	addi	a4,a4,1
	beq	a4,a2,.L98
.L96:
	lbu	a5,0(a4)
	addi	a5,a5,-1
	andi	a5,a5,0xff
	bgtu	a5,a3,.L95
	addi	a0,a0,1
	slli	a0,a0,16
	srai	a0,a0,16
	j	.L95
.L98:
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
	bgtu	a3,a4,.L101
	slli	a5,a3,2
	lui	a4,%hi(.L104)
	addi	a4,a4,%lo(.L104)
	add	a5,a5,a4
	lw	a5,0(a5)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L104:
	.word	.L111
	.word	.L110
	.word	.L109
	.word	.L108
	.word	.L107
	.word	.L106
	.word	.L105
	.word	.L103
	.text
.L111:
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a4,464
	ble	a5,zero,.L112
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L112:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
	ret
.L110:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a3,623
	li	a4,0
	bgt	a5,a3,.L113
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L113:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a4,464
	ble	a5,zero,.L114
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L114:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
	ret
.L109:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a3,623
	li	a4,0
	bgt	a5,a3,.L115
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L115:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	ret
.L108:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a3,623
	li	a4,0
	bgt	a5,a3,.L116
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L116:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a3,463
	li	a4,0
	bgt	a5,a3,.L117
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L117:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
	ret
.L107:
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a3,463
	li	a4,0
	bgt	a5,a3,.L118
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L118:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
	ret
.L106:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a4,624
	ble	a5,zero,.L119
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L119:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a3,463
	li	a4,0
	bgt	a5,a3,.L120
	addi	a5,a5,1
	slli	a4,a5,16
	srai	a4,a4,16
.L120:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
	ret
.L105:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a4,624
	ble	a5,zero,.L121
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L121:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	ret
.L103:
	lui	a5,%hi(shipx)
	lh	a5,%lo(shipx)(a5)
	li	a4,624
	ble	a5,zero,.L122
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L122:
	lui	a5,%hi(shipx)
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	li	a4,464
	ble	a5,zero,.L123
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L123:
	lui	a5,%hi(shipy)
	sh	a4,%lo(shipy)(a5)
.L101:
	ret
	.size	move_ship, .-move_ship
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"Score "
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
	beq	a5,a4,.L141
	li	a4,3
	beq	a5,a4,.L142
	li	a4,1
	bne	a5,a4,.L140
	j	.L143
.L142:
	li	a3,464
	li	a2,608
	li	a1,63
	li	a0,0
	call	draw_vector_block
.L141:
	li	a3,464
	li	a2,576
	li	a1,63
	li	a0,0
	call	draw_vector_block
.L143:
	li	a3,464
	li	a2,544
	li	a1,63
	li	a0,0
	call	draw_vector_block
.L140:
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
	bgtu	a4,a5,.L147
	slli	a3,a3,2
	lui	a5,%hi(.L149)
	addi	a5,a5,%lo(.L149)
	add	a3,a3,a5
	lw	a5,0(a3)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L149:
	.word	.L156
	.word	.L155
	.word	.L154
	.word	.L153
	.word	.L152
	.word	.L151
	.word	.L150
	.word	.L148
	.text
.L156:
	lui	a5,%hi(shipx)
	lh	s0,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lhu	s1,%lo(shipy)(a5)
	addi	s1,s1,-10
	slli	s1,s1,16
	srai	s1,s1,16
.L147:
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
.L155:
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
	j	.L147
.L154:
	lui	a5,%hi(shipx)
	lhu	s0,%lo(shipx)(a5)
	addi	s0,s0,10
	slli	s0,s0,16
	srai	s0,s0,16
	lui	a5,%hi(shipy)
	lh	s1,%lo(shipy)(a5)
	j	.L147
.L153:
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
	j	.L147
.L152:
	lui	a5,%hi(shipx)
	lh	s0,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	lhu	s1,%lo(shipy)(a5)
	addi	s1,s1,10
	slli	s1,s1,16
	srai	s1,s1,16
	j	.L147
.L151:
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
	j	.L147
.L150:
	lui	a5,%hi(shipx)
	lhu	s0,%lo(shipx)(a5)
	addi	s0,s0,-10
	slli	s0,s0,16
	srai	s0,s0,16
	lui	a5,%hi(shipy)
	lh	s1,%lo(shipy)(a5)
	j	.L147
.L148:
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
	j	.L147
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
.LC1:
	.string	"         Welcome to Risc-ICE-V Asteroids        "
	.align	2
.LC2:
	.string	"By @robng15 (Twitter) from Whitebridge, Scotland"
	.align	2
.LC3:
	.string	"                 Press UP to start              "
	.align	2
.LC4:
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
	bne	s0,a0,.L170
.L160:
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
.L170:
	call	draw_score
	call	get_timer1hz
	lui	s0,%hi(last_timer)
	sh	a0,%lo(last_timer)(s0)
	li	a0,5
	call	tilemap_scrollwrapclear
	lhu	a5,%lo(last_timer)(s0)
	andi	a5,a5,3
	li	a4,2
	beq	a5,a4,.L162
	bgtu	a5,a4,.L163
	beq	a5,zero,.L164
	li	a4,1
	bne	a5,a4,.L160
	lui	a5,%hi(lives)
	lhu	a5,%lo(lives)(a5)
	bne	a5,zero,.L160
	li	a3,15
	li	a2,64
	li	a1,26
	li	a0,16
	call	tpu_set
	lui	a0,%hi(.LC2)
	addi	a0,a0,%lo(.LC2)
	call	tpu_outputstring
	call	game_over
	j	.L160
.L164:
	lui	a5,%hi(lives)
	lhu	a5,%lo(lives)(a5)
	beq	a5,zero,.L166
	li	a3,500
	li	a2,1
	li	a1,0
	li	a0,1
	call	beep
	j	.L160
.L166:
	li	a3,3
	li	a2,64
	li	a1,26
	li	a0,16
	call	tpu_set
	lui	a0,%hi(.LC1)
	addi	a0,a0,%lo(.LC1)
	call	tpu_outputstring
	call	game_over
	j	.L160
.L162:
	lui	a5,%hi(lives)
	lhu	a5,%lo(lives)(a5)
	beq	a5,zero,.L167
	li	a3,500
	li	a2,2
	li	a1,0
	li	a0,1
	call	beep
	j	.L160
.L167:
	li	a3,60
	li	a2,64
	li	a1,26
	li	a0,16
	call	tpu_set
	lui	a0,%hi(.LC3)
	addi	a0,a0,%lo(.LC3)
	call	tpu_outputstring
	call	game_over
	j	.L160
.L163:
	lui	a5,%hi(lives)
	lhu	a5,%lo(lives)(a5)
	beq	a5,zero,.L171
.L168:
	li	a0,6
	call	tilemap_scrollwrapclear
	j	.L160
.L171:
	li	a3,48
	li	a2,64
	li	a1,26
	li	a0,16
	call	tpu_set
	lui	a0,%hi(.LC4)
	addi	a0,a0,%lo(.LC4)
	call	tpu_outputstring
	call	game_over
	j	.L168
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
	beq	a0,a5,.L172
	mv	s0,a0
	mv	s4,a0
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	add	a5,a5,a0
	sb	s1,0(a5)
	li	a5,2
	li	a0,4
	beq	s1,a5,.L174
	li	a0,8
.L174:
	call	rng
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	add	a5,a5,s4
	sb	a0,20(a5)
	sltiu	s6,s0,10
	xori	s6,s6,1
	li	a5,9
	bleu	s0,a5,.L175
	addi	s0,s0,-10
	andi	s0,s0,0xff
.L175:
	call	random_colour
	mv	s7,a0
	li	a0,16
	call	rng
	mv	s4,a0
	li	a0,16
	call	rng
	mv	s5,a0
	li	a0,7
	call	rng
	addi	a7,s1,-2
	addi	a5,s3,-8
	add	a5,s5,a5
	addi	s2,s2,-8
	add	s2,s4,s2
	seqz	a7,a7
	andi	a6,a0,0xff
	slli	a5,a5,16
	srai	a5,a5,16
	slli	a4,s2,16
	srai	a4,a4,16
	mv	a3,s7
	li	a2,1
	mv	a1,s0
	mv	a0,s6
	call	set_sprite
.L172:
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
	bne	a0,zero,.L179
	li	a1,10
	li	a0,1
	call	get_sprite_collision
	andi	a0,a0,1023
	beq	a0,zero,.L178
.L179:
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
	j	.L181
.L182:
	mv	s0,a5
.L181:
	call	get_sprite_collision
	andi	a0,a0,1024
	beq	a0,zero,.L183
	mv	s3,s0
.L183:
	addi	a5,s0,1
	andi	a5,a5,0xff
	beq	a5,s1,.L194
	sltiu	a0,a5,10
	xori	a0,a0,1
	mv	a1,a5
	bleu	a5,s2,.L182
	addi	s0,s0,-9
	andi	a1,s0,0xff
	j	.L182
.L194:
	li	a5,255
	beq	s3,a5,.L178
	mv	s2,s3
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	add	a5,a5,s3
	lbu	a4,0(a5)
	li	a5,2
	bleu	a4,a5,.L195
.L178:
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
.L195:
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
	bleu	s3,a5,.L185
	addi	s3,s3,-10
	andi	s3,s3,0xff
.L185:
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
	beq	a4,a5,.L196
.L186:
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
	j	.L178
.L196:
	lui	a5,%hi(level)
	lhu	a5,%lo(level)(a5)
	mv	s0,a5
	li	a4,2
	bleu	a5,a4,.L187
	li	s0,2
.L187:
	andi	s0,s0,0xff
	li	a4,2
	addi	s6,s0,1
	andi	s6,s6,0xff
	bgtu	a5,a4,.L197
.L190:
	li	s0,0
.L189:
	mv	a2,s5
	mv	a1,s4
	li	a0,1
	call	spawn_asteroid
	addi	s0,s0,1
	blt	s0,s6,.L189
	j	.L186
.L197:
	li	a0,2
	call	rng
	addi	s0,s0,1
	add	s0,s0,a0
	andi	s6,s0,0xff
	bgt	s6,zero,.L190
	j	.L186
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
	li	a1,12
	li	a0,0
	call	get_sprite_collision
	andi	a0,a0,1023
	bne	a0,zero,.L199
	li	a1,12
	li	a0,1
	call	get_sprite_collision
	andi	a0,a0,1023
	beq	a0,zero,.L198
.L199:
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
	j	.L201
.L202:
	mv	s0,a5
.L201:
	call	get_sprite_collision
	and	a0,a0,s2
	slli	a0,a0,16
	srli	a0,a0,16
	beq	a0,zero,.L203
	mv	s4,s0
.L203:
	addi	a5,s0,1
	andi	a5,a5,0xff
	beq	a5,s1,.L224
	sltiu	a0,a5,10
	xori	a0,a0,1
	mv	a1,a5
	bleu	a5,s3,.L202
	addi	a1,s0,-9
	andi	a1,a1,0xff
	j	.L202
.L224:
	li	a5,255
	beq	s4,a5,.L205
	mv	s5,s4
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	add	a5,a5,s4
	lbu	a4,0(a5)
	li	a5,2
	bleu	a4,a5,.L225
.L205:
	mv	s1,s4
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	add	a5,a5,s4
	lbu	a4,0(a5)
	li	a5,3
	beq	a4,a5,.L226
.L198:
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
.L225:
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
	bleu	s4,a5,.L206
	addi	s4,s4,-10
	andi	s4,s4,0xff
.L206:
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
	andi	s6,a0,0xff
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	add	a5,a5,s5
	lbu	a4,0(a5)
	li	a5,2
	beq	a4,a5,.L227
.L207:
	mv	a7,s6
	li	a6,7
	mv	a5,s3
	mv	a4,s2
	li	a3,48
	li	a2,1
	mv	a1,s4
	mv	a0,s1
	call	set_sprite
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	add	a5,a5,s5
	li	a4,32
	sb	a4,0(a5)
	j	.L198
.L227:
	lui	a5,%hi(level)
	lhu	a5,%lo(level)(a5)
	mv	s0,a5
	li	a4,2
	bleu	a5,a4,.L208
	li	s0,2
.L208:
	andi	s0,s0,0xff
	li	a4,2
	addi	s7,s0,1
	andi	s7,s7,0xff
	bgtu	a5,a4,.L228
.L217:
	li	s0,0
.L210:
	mv	a2,s3
	mv	a1,s2
	li	a0,1
	call	spawn_asteroid
	addi	s0,s0,1
	blt	s0,s7,.L210
	j	.L207
.L228:
	li	a0,2
	call	rng
	addi	s0,s0,1
	add	s0,s0,a0
	andi	s7,s0,0xff
	bgt	s7,zero,.L217
	j	.L207
.L226:
	lui	a5,%hi(level)
	lhu	a3,%lo(level)(a5)
	li	a4,1
	li	a5,10
	bleu	a3,a4,.L211
	li	a5,20
.L211:
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
	bleu	s4,a5,.L212
	addi	s4,s4,-10
	andi	s4,s4,0xff
.L212:
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
	lui	a5,%hi(level)
	lhu	a4,%lo(level)(a5)
	li	a5,1
	li	a0,10
	bleu	a4,a5,.L213
	li	a0,40
.L213:
	call	rng
	lui	a4,%hi(fuel)
	lhu	a5,%lo(fuel)(a4)
	addi	a5,a5,10
	add	a5,a0,a5
	mv	a3,a5
	slli	a5,a5,16
	srli	a5,a5,16
	li	a2,1000
	bleu	a5,a2,.L214
	li	a3,1000
.L214:
	sh	a3,%lo(fuel)(a4)
	lui	a5,%hi(level)
	lhu	a4,%lo(level)(a5)
	li	a5,1
	li	a0,5
	bleu	a4,a5,.L215
	li	a0,10
.L215:
	call	rng
	lui	a4,%hi(shield)
	lhu	a5,%lo(shield)(a4)
	addi	a5,a5,5
	add	a5,a0,a5
	mv	a3,a5
	slli	a5,a5,16
	srli	a5,a5,16
	li	a2,250
	bleu	a5,a2,.L216
	li	a3,250
.L216:
	sh	a3,%lo(shield)(a4)
	li	a0,1
	call	drawfuel
	li	a0,1
	call	drawshield
	j	.L198
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
	bne	a0,zero,.L230
	li	a1,11
	li	a0,1
	call	get_sprite_collision
	andi	a0,a0,2047
	beq	a0,zero,.L229
.L230:
	li	a1,10
	li	a0,0
	call	get_sprite_collision
	andi	a0,a0,1
	bne	a0,zero,.L232
	li	a1,10
	li	a0,1
	call	get_sprite_collision
	andi	a0,a0,1
	beq	a0,zero,.L233
.L232:
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
.L233:
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
.L229:
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
	j	.L236
.L237:
	call	inputcharacter
.L236:
	call	inputcharacter_available
	mv	s9,a0
	bne	a0,zero,.L237
	call	setup_game
	li	s1,4
	li	s11,0
	li	s10,0
	lui	s3,%hi(counter)
	lui	s4,%hi(ufo_sprite_number)
	lui	s6,%hi(lives)
	lui	a5,%hi(.LANCHOR1)
	addi	a5,a5,%lo(.LANCHOR1)
	sw	a5,12(sp)
	lui	s5,%hi(level)
	j	.L289
.L319:
	li	a3,32
	li	a2,63
	li	a1,3
	li	a0,2
	call	beep
	j	.L239
.L320:
	li	a0,4
	call	rng
	li	a5,2
	beq	a0,a5,.L242
	bgtu	a0,a5,.L243
	beq	a0,zero,.L310
	li	a0,480
	call	rng
	slli	s11,a0,16
	srai	s11,s11,16
	li	s10,-639
	j	.L247
.L243:
	li	a5,3
	bne	a0,a5,.L247
	li	a0,640
	call	rng
	slli	s10,a0,16
	srai	s10,s10,16
	li	s11,479
	j	.L247
.L310:
	li	a0,480
	call	rng
	slli	s11,a0,16
	srai	s11,s11,16
	li	s10,-31
.L247:
	lw	a5,12(sp)
	add	s2,a5,s0
	li	a5,2
	sb	a5,0(s2)
	li	a0,4
	call	rng
	sb	a0,20(s2)
	sltiu	s2,s0,10
	xori	s2,s2,1
	li	a5,9
	bleu	s0,a5,.L248
	addi	s0,s0,-10
	andi	s0,s0,0xff
.L248:
	call	random_colour
	mv	s7,a0
	li	a0,7
	call	rng
	li	a7,1
	andi	a6,a0,0xff
	mv	a5,s11
	mv	a4,s10
	mv	a3,s7
	li	a2,1
	mv	a1,s0
	mv	a0,s2
	call	set_sprite
	j	.L241
.L242:
	li	a0,640
	call	rng
	slli	s10,a0,16
	srai	s10,s10,16
	li	s11,-31
	j	.L247
.L321:
	lbu	a4,%lo(ufo_sprite_number)(s4)
	li	a5,255
	bne	a4,a5,.L251
	li	a2,0
	li	a1,10
	li	a0,0
	call	get_sprite_attribute
	bne	a0,zero,.L251
	call	find_asteroid_space
	sb	a0,%lo(ufo_sprite_number)(s4)
	li	a5,255
	beq	a0,a5,.L251
	lui	s2,%hi(shipy)
.L253:
	li	a0,384
	call	rng
	addi	s0,a0,32
	slli	s0,s0,16
	srai	s0,s0,16
	lh	a5,%lo(shipy)(s2)
	addi	a4,a5,-64
	blt	s0,a4,.L252
	addi	a5,a5,64
	ble	s0,a5,.L253
.L252:
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
	bleu	a1,a5,.L254
	addi	a1,a1,-10
	andi	a1,a1,0xff
.L254:
	lui	a5,%hi(ufo_leftright)
	lbu	a3,%lo(ufo_leftright)(a5)
	li	a5,1
	li	a4,639
	beq	a3,a5,.L255
	lhu	a3,%lo(level)(s5)
	li	a4,-31
	bleu	a3,a5,.L255
	li	a4,-15
.L255:
	lhu	a7,%lo(level)(s5)
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
	j	.L251
.L322:
	li	a2,0
	li	a1,10
	li	a0,0
	call	get_sprite_attribute
	bne	a0,zero,.L257
	lbu	a4,%lo(ufo_sprite_number)(s4)
	li	a5,255
	beq	a4,a5,.L257
	lhu	a5,%lo(level)(s5)
	bne	a5,zero,.L258
	lhu	a5,%lo(lives)(s6)
	bne	a5,zero,.L259
.L258:
	li	a3,32
	li	a2,63
	li	a1,4
	li	a0,2
	call	beep
	lbu	a1,%lo(ufo_sprite_number)(s4)
	sltiu	a0,a1,10
	xori	a0,a0,1
	li	a5,9
	bleu	a1,a5,.L260
	addi	a1,a1,-10
	andi	a1,a1,0xff
.L260:
	li	a2,3
	call	get_sprite_attribute
	slli	s0,a0,16
	srli	s0,s0,16
	lhu	a3,%lo(level)(s5)
	li	a4,1
	li	a5,16
	bleu	a3,a4,.L261
	li	a5,8
.L261:
	add	s0,s0,a5
	slli	s0,s0,16
	srai	s0,s0,16
	lbu	a1,%lo(ufo_sprite_number)(s4)
	sltiu	a0,a1,10
	xori	a0,a0,1
	li	a5,9
	bleu	a1,a5,.L262
	addi	a1,a1,-10
	andi	a1,a1,0xff
.L262:
	li	a2,4
	call	get_sprite_attribute
	lui	a5,%hi(shipy)
	lh	a5,%lo(shipy)(a5)
	bge	a5,a0,.L263
	addi	a0,a0,-10
	slli	s2,a0,16
	srai	s2,s2,16
.L264:
	lui	a4,%hi(shipx)
	lh	a4,%lo(shipx)(a4)
	blt	a4,s0,.L266
	slt	a5,a5,s2
	neg	a5,a5
	andi	a5,a5,254
	addi	a5,a5,3
	lui	a4,%hi(ufo_bullet_direction)
	sb	a5,%lo(ufo_bullet_direction)(a4)
.L268:
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
	j	.L257
.L263:
	lhu	a2,%lo(level)(s5)
	li	a3,1
	li	a4,20
	bleu	a2,a3,.L265
	li	a4,10
.L265:
	add	a4,a4,a0
	slli	s2,a4,16
	srai	s2,s2,16
	j	.L264
.L259:
	lui	a5,%hi(resetship)
	lh	s0,%lo(resetship)(a5)
	bne	s0,zero,.L270
	lw	a5,%lo(counter)(s3)
	andi	a5,a5,3
	beq	a5,zero,.L311
.L271:
	li	a2,0
	li	a1,12
	li	a0,0
	call	get_sprite_attribute
	beq	a0,zero,.L312
.L275:
	call	get_buttons
	andi	a0,a0,8
	beq	a0,zero,.L276
	lui	a5,%hi(fuel)
	lhu	a5,%lo(fuel)(a5)
	bne	a5,zero,.L313
.L276:
	call	get_buttons
	andi	a0,a0,4
	beq	a0,zero,.L277
	lui	a5,%hi(shield)
	lhu	a5,%lo(shield)(a5)
	beq	a5,zero,.L277
	li	a0,3
	call	draw_ship
	lui	a4,%hi(shield)
	lhu	a5,%lo(shield)(a4)
	addi	a5,a5,-1
	sh	a5,%lo(shield)(a4)
	li	a0,0
	call	drawshield
	j	.L278
.L311:
	call	get_buttons
	andi	a0,a0,32
	beq	a0,zero,.L272
	lui	a5,%hi(shipdirection)
	lh	a5,%lo(shipdirection)(a5)
	li	a4,7
	beq	a5,zero,.L273
	addi	a5,a5,-1
	slli	a4,a5,16
	srai	a4,a4,16
.L273:
	lui	a5,%hi(shipdirection)
	sh	a4,%lo(shipdirection)(a5)
.L272:
	call	get_buttons
	andi	a0,a0,64
	beq	a0,zero,.L271
	lui	a5,%hi(shipdirection)
	lh	a5,%lo(shipdirection)(a5)
	li	a4,7
	beq	a5,a4,.L274
	addi	a5,a5,1
	slli	s0,a5,16
	srai	s0,s0,16
.L274:
	lui	a5,%hi(shipdirection)
	sh	s0,%lo(shipdirection)(a5)
	j	.L271
.L312:
	call	get_buttons
	andi	a0,a0,2
	beq	a0,zero,.L275
	call	fire_bullet
	j	.L275
.L313:
	call	move_ship
	lui	a4,%hi(fuel)
	lhu	a5,%lo(fuel)(a4)
	addi	a5,a5,-1
	sh	a5,%lo(fuel)(a4)
	li	a0,0
	call	drawfuel
	j	.L276
.L277:
	li	a0,63
	call	draw_ship
	call	check_crash
	j	.L278
.L323:
	lui	a5,%hi(.LANCHOR1)
	addi	s1,a5,%lo(.LANCHOR1)
	addi	s2,s1,20
	li	s8,9
	li	s7,20
	j	.L282
.L281:
	li	a3,0
	li	a2,0
	call	set_sprite_attribute
	addi	s0,s0,1
	slli	s0,s0,16
	srli	s0,s0,16
	addi	s1,s1,1
	addi	s2,s2,1
	beq	s0,s7,.L314
.L282:
	sb	zero,0(s1)
	sb	zero,0(s2)
	sltiu	a0,s0,10
	xori	a0,a0,1
	andi	a1,s0,0xff
	bleu	s0,s8,.L281
	addi	a1,s0,-10
	andi	a1,a1,0xff
	j	.L281
.L314:
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
	call	set_tilemap
	sw	zero,%lo(counter)(s3)
	li	a5,4
	sh	a5,%lo(lives)(s6)
	lui	a5,%hi(score)
	sh	zero,%lo(score)(a5)
	sh	zero,%lo(level)(s5)
	lui	a5,%hi(shield)
	li	a4,250
	sh	a4,%lo(shield)(a5)
	lui	a5,%hi(fuel)
	li	a4,1000
	sh	a4,%lo(fuel)(a5)
	li	a0,1
	call	drawfuel
	li	a0,1
	call	drawshield
	lui	a5,%hi(shipx)
	li	a4,312
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	li	a4,232
	sh	a4,%lo(shipy)(a5)
	lui	a5,%hi(shipdirection)
	sh	zero,%lo(shipdirection)(a5)
	lui	a5,%hi(resetship)
	li	a4,16
	sh	a4,%lo(resetship)(a5)
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
	j	.L279
.L317:
	li	a1,11
	li	a0,0
	call	get_sprite_collision
	andi	a0,a0,2047
	bne	a0,zero,.L284
	li	a1,11
	li	a0,1
	call	get_sprite_collision
	andi	a0,a0,2047
	bne	a0,zero,.L284
	lui	a4,%hi(resetship)
	lhu	a5,%lo(resetship)(a4)
	addi	a5,a5,-1
	slli	a5,a5,16
	srai	a5,a5,16
	sh	a5,%lo(resetship)(a4)
	beq	a5,zero,.L315
.L285:
	lhu	a5,%lo(lives)(s6)
	bne	a5,zero,.L284
	call	risc_ice_v_logo
	j	.L284
.L315:
	call	gpu_cs
	lhu	a5,%lo(lives)(s6)
	addi	a5,a5,-1
	sh	a5,%lo(lives)(s6)
	call	draw_lives
	lui	a5,%hi(fuel)
	li	a4,1000
	sh	a4,%lo(fuel)(a5)
	li	a0,1
	call	drawfuel
	li	a0,1
	call	drawshield
	j	.L285
.L318:
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
	beq	a5,a4,.L316
.L288:
	lui	a5,%hi(shipx)
	li	a4,312
	sh	a4,%lo(shipx)(a5)
	lui	a5,%hi(shipy)
	li	a4,232
	sh	a4,%lo(shipy)(a5)
	lui	a5,%hi(shipdirection)
	sh	zero,%lo(shipdirection)(a5)
	j	.L278
.L316:
	li	a0,0
	call	set_ship_sprites
	j	.L288
.L270:
	addi	s0,s0,-1
	slli	s0,s0,16
	srli	s0,s0,16
	li	a5,15
	bgtu	s0,a5,.L284
.L283:
	li	a0,21
	call	draw_ship
	lui	a5,%hi(resetship)
	lhu	a5,%lo(resetship)(a5)
	addi	a5,a5,-1
	slli	a5,a5,16
	srli	a5,a5,16
	li	a4,15
	bleu	a5,a4,.L317
.L284:
	lui	a5,%hi(resetship)
	lh	a4,%lo(resetship)(a5)
	li	a5,16
	bgt	a4,a5,.L318
.L278:
	call	update_bullet
	call	check_hit
	call	check_ufo_bullet_hit
	call	move_asteroids
	call	wait_timer1khz
.L289:
	lw	a5,%lo(counter)(s3)
	addi	a5,a5,1
	sw	a5,%lo(counter)(s3)
	lbu	a3,%lo(ufo_sprite_number)(s4)
	li	a4,255
	mv	a0,s9
	beq	a3,a4,.L238
	slli	a0,a5,26
	srai	a0,a0,31
	andi	a0,a0,0xff
.L238:
	call	set_leds
	lbu	a4,%lo(ufo_sprite_number)(s4)
	li	a5,255
	beq	a4,a5,.L239
	lw	a5,%lo(counter)(s3)
	andi	a5,a5,64
	beq	a5,zero,.L239
	lhu	a5,%lo(lives)(s6)
	bne	a5,zero,.L319
.L239:
	beq	s1,zero,.L240
	call	find_asteroid_space
	mv	s0,a0
	li	a5,255
	bne	a0,a5,.L320
.L241:
	addi	s1,s1,-1
	slli	s1,s1,16
	srli	s1,s1,16
.L240:
	call	count_asteroids
	bne	a0,zero,.L249
	lhu	a5,%lo(level)(s5)
	addi	a5,a5,1
	slli	a5,a5,16
	srli	a5,a5,16
	sh	a5,%lo(level)(s5)
	mv	s1,a5
	li	a4,4
	bleu	a5,a4,.L250
	li	s1,4
.L250:
	addi	s1,s1,4
	slli	s1,s1,16
	srli	s1,s1,16
.L249:
	call	await_vblank
	li	a0,8
	call	set_timer1khz
	call	beepboop
	li	a0,512
	call	rng
	li	a5,1
	beq	a0,a5,.L321
.L251:
	lhu	a0,%lo(level)(s5)
	li	a5,3
	sgtu	a0,a0,a5
	neg	a0,a0
	andi	a0,a0,-64
	addi	a0,a0,128
	call	rng
	li	a5,1
	beq	a0,a5,.L322
.L257:
	lhu	s0,%lo(lives)(s6)
	bne	s0,zero,.L259
	call	get_buttons
	andi	a0,a0,8
	bne	a0,zero,.L323
.L279:
	lui	a5,%hi(resetship)
	lhu	a5,%lo(resetship)(a5)
	addi	a5,a5,-1
	slli	a5,a5,16
	srli	a5,a5,16
	li	a4,15
	bleu	a5,a4,.L283
	lhu	a5,%lo(lives)(s6)
	beq	a5,zero,.L283
	j	.L284
.L266:
	slt	a5,a5,s2
	neg	a5,a5
	andi	a5,a5,-254
	addi	a5,a5,261
	lui	a4,%hi(ufo_bullet_direction)
	sb	a5,%lo(ufo_bullet_direction)(a4)
	j	.L268
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
	.globl	fuel
	.globl	shield
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
	.type	fuel, @object
	.size	fuel, 2
fuel:
	.zero	2
	.type	shield, @object
	.size	shield, 2
shield:
	.zero	2
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
