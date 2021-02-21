	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p0_m2p0_a2p0_c2p0"
	.file	"PAWSlibrary.c"
	.section	.text.CSRcycles,"ax",@progbits
	.globl	CSRcycles                       # -- Begin function CSRcycles
	.p2align	1
	.type	CSRcycles,@function
CSRcycles:                              # @CSRcycles
# %bb.0:
	#APP
	rdcycle	a0
	#NO_APP
	ret
.Lfunc_end0:
	.size	CSRcycles, .Lfunc_end0-CSRcycles
                                        # -- End function
	.section	.text.CSRinstructions,"ax",@progbits
	.globl	CSRinstructions                 # -- Begin function CSRinstructions
	.p2align	1
	.type	CSRinstructions,@function
CSRinstructions:                        # @CSRinstructions
# %bb.0:
	#APP
	rdinstret	a0
	#NO_APP
	ret
.Lfunc_end1:
	.size	CSRinstructions, .Lfunc_end1-CSRinstructions
                                        # -- End function
	.section	.text.CSRtime,"ax",@progbits
	.globl	CSRtime                         # -- Begin function CSRtime
	.p2align	1
	.type	CSRtime,@function
CSRtime:                                # @CSRtime
# %bb.0:
	#APP
	rdtime	a0
	#NO_APP
	ret
.Lfunc_end2:
	.size	CSRtime, .Lfunc_end2-CSRtime
                                        # -- End function
	.section	.text.outputcharacter,"ax",@progbits
	.globl	outputcharacter                 # -- Begin function outputcharacter
	.p2align	1
	.type	outputcharacter,@function
outputcharacter:                        # @outputcharacter
# %bb.0:
	lui	a1, %hi(UART_STATUS)
	lw	a1, %lo(UART_STATUS)(a1)
.LBB3_1:                                # =>This Inner Loop Header: Depth=1
	lbu	a2, 0(a1)
	andi	a2, a2, 2
	bnez	a2, .LBB3_1
# %bb.2:
	lui	a1, %hi(UART_DATA)
	lw	a1, %lo(UART_DATA)(a1)
	addi	a2, zero, 10
	sb	a0, 0(a1)
	bne	a0, a2, .LBB3_6
# %bb.3:
	lui	a0, %hi(UART_STATUS)
	lw	a0, %lo(UART_STATUS)(a0)
.LBB3_4:                                # =>This Inner Loop Header: Depth=1
	lbu	a1, 0(a0)
	andi	a1, a1, 2
	bnez	a1, .LBB3_4
# %bb.5:
	lui	a0, %hi(UART_DATA)
	lw	a0, %lo(UART_DATA)(a0)
	addi	a1, zero, 13
	sb	a1, 0(a0)
.LBB3_6:
	ret
.Lfunc_end3:
	.size	outputcharacter, .Lfunc_end3-outputcharacter
                                        # -- End function
	.section	.text.character_available,"ax",@progbits
	.globl	character_available             # -- Begin function character_available
	.p2align	1
	.type	character_available,@function
character_available:                    # @character_available
# %bb.0:
	lui	a0, %hi(UART_STATUS)
	lw	a0, %lo(UART_STATUS)(a0)
	lbu	a0, 0(a0)
	andi	a0, a0, 1
	ret
.Lfunc_end4:
	.size	character_available, .Lfunc_end4-character_available
                                        # -- End function
	.section	.text.inputcharacter,"ax",@progbits
	.globl	inputcharacter                  # -- Begin function inputcharacter
	.p2align	1
	.type	inputcharacter,@function
inputcharacter:                         # @inputcharacter
# %bb.0:
	lui	a0, %hi(UART_STATUS)
	lw	a0, %lo(UART_STATUS)(a0)
.LBB5_1:                                # =>This Inner Loop Header: Depth=1
	lbu	a1, 0(a0)
	andi	a1, a1, 1
	beqz	a1, .LBB5_1
# %bb.2:
	lui	a0, %hi(UART_DATA)
	lw	a0, %lo(UART_DATA)(a0)
	lbu	a0, 0(a0)
	ret
.Lfunc_end5:
	.size	inputcharacter, .Lfunc_end5-inputcharacter
                                        # -- End function
	.section	.text.rng,"ax",@progbits
	.globl	rng                             # -- Begin function rng
	.p2align	1
	.type	rng,@function
rng:                                    # @rng
# %bb.0:
	addi	a1, zero, 255
	blt	a1, a0, .LBB6_6
# %bb.1:
	addi	a1, zero, 63
	blt	a1, a0, .LBB6_13
# %bb.2:
	addi	a1, a0, -1
	addi	a2, zero, 31
	bltu	a2, a1, .LBB6_21
# %bb.3:
	addi	a2, zero, 1
	sll	a1, a2, a1
	lui	a2, 524296
	addi	a2, a2, 136
	and	a2, a2, a1
	bnez	a2, .LBB6_19
# %bb.4:
	andi	a1, a1, 3
	beqz	a1, .LBB6_21
# %bb.5:
	lui	a0, %hi(ALT_RNG)
	lw	a0, %lo(ALT_RNG)(a0)
	lhu	a0, 0(a0)
	andi	a1, a0, 1
	j	.LBB6_20
.LBB6_6:
	lui	a1, 1
	addi	a1, a1, -1
	blt	a1, a0, .LBB6_10
# %bb.7:
	addi	a1, zero, 1023
	blt	a1, a0, .LBB6_15
# %bb.8:
	addi	a1, zero, 256
	beq	a0, a1, .LBB6_19
# %bb.9:
	addi	a1, zero, 512
	beq	a0, a1, .LBB6_19
	j	.LBB6_23
.LBB6_10:
	lui	a1, 4
	addi	a2, a1, -1
	blt	a2, a0, .LBB6_17
# %bb.11:
	lui	a1, 1
	beq	a0, a1, .LBB6_19
# %bb.12:
	lui	a1, 2
	beq	a0, a1, .LBB6_19
	j	.LBB6_23
.LBB6_13:
	addi	a1, zero, 64
	beq	a0, a1, .LBB6_19
# %bb.14:
	addi	a1, zero, 128
	beq	a0, a1, .LBB6_19
	j	.LBB6_23
.LBB6_15:
	addi	a1, zero, 1024
	beq	a0, a1, .LBB6_19
# %bb.16:
	lui	a1, 1
	addi	a1, a1, -2048
	beq	a0, a1, .LBB6_19
	j	.LBB6_23
.LBB6_17:
	beq	a0, a1, .LBB6_19
# %bb.18:
	lui	a1, 8
	bne	a0, a1, .LBB6_23
.LBB6_19:
	lui	a1, %hi(ALT_RNG)
	lw	a1, %lo(ALT_RNG)(a1)
	lh	a1, 0(a1)
	addi	a0, a0, -1
	and	a1, a1, a0
.LBB6_20:
	lui	a0, 16
	addi	a0, a0, -1
	and	a0, a0, a1
	ret
.LBB6_21:
	bnez	a0, .LBB6_23
# %bb.22:
	add	a1, zero, a0
	j	.LBB6_20
.LBB6_23:
	lui	a1, %hi(RNG)
	lw	a2, %lo(RNG)(a1)
	lui	a1, %hi(ALT_RNG)
	lw	a3, %lo(ALT_RNG)(a1)
	sltiu	a4, a0, 256
	j	.LBB6_25
.LBB6_24:                               #   in Loop: Header=BB6_25 Depth=1
	lhu	a1, 0(a2)
	bltu	a1, a0, .LBB6_20
.LBB6_25:                               # =>This Inner Loop Header: Depth=1
	beqz	a4, .LBB6_24
# %bb.26:                               #   in Loop: Header=BB6_25 Depth=1
	lhu	a1, 0(a3)
	andi	a1, a1, 255
	bgeu	a1, a0, .LBB6_25
	j	.LBB6_20
.Lfunc_end6:
	.size	rng, .Lfunc_end6-rng
                                        # -- End function
	.section	.text.sleep,"ax",@progbits
	.globl	sleep                           # -- Begin function sleep
	.p2align	1
	.type	sleep,@function
sleep:                                  # @sleep
# %bb.0:
	addi	a2, zero, 1
	beq	a1, a2, .LBB7_4
# %bb.1:
	bnez	a1, .LBB7_6
# %bb.2:
	lui	a1, %hi(SLEEPTIMER0)
	lw	a1, %lo(SLEEPTIMER0)(a1)
	sh	a0, 0(a1)
.LBB7_3:                                # =>This Inner Loop Header: Depth=1
	lhu	a0, 0(a1)
	bnez	a0, .LBB7_3
	j	.LBB7_6
.LBB7_4:
	lui	a1, %hi(SLEEPTIMER1)
	lw	a1, %lo(SLEEPTIMER1)(a1)
	sh	a0, 0(a1)
.LBB7_5:                                # =>This Inner Loop Header: Depth=1
	lhu	a0, 0(a1)
	bnez	a0, .LBB7_5
.LBB7_6:
	ret
.Lfunc_end7:
	.size	sleep, .Lfunc_end7-sleep
                                        # -- End function
	.section	.text.set_timer1khz,"ax",@progbits
	.globl	set_timer1khz                   # -- Begin function set_timer1khz
	.p2align	1
	.type	set_timer1khz,@function
set_timer1khz:                          # @set_timer1khz
# %bb.0:
	beqz	a1, .LBB8_3
# %bb.1:
	addi	a2, zero, 1
	bne	a1, a2, .LBB8_5
# %bb.2:
	lui	a1, %hi(TIMER1KHZ1)
	addi	a1, a1, %lo(TIMER1KHZ1)
	j	.LBB8_4
.LBB8_3:
	lui	a1, %hi(TIMER1KHZ0)
	addi	a1, a1, %lo(TIMER1KHZ0)
.LBB8_4:
	lw	a1, 0(a1)
	sh	a0, 0(a1)
.LBB8_5:
	ret
.Lfunc_end8:
	.size	set_timer1khz, .Lfunc_end8-set_timer1khz
                                        # -- End function
	.section	.text.get_timer1khz,"ax",@progbits
	.globl	get_timer1khz                   # -- Begin function get_timer1khz
	.p2align	1
	.type	get_timer1khz,@function
get_timer1khz:                          # @get_timer1khz
# %bb.0:
	beqz	a0, .LBB9_2
# %bb.1:
	lui	a0, %hi(TIMER1KHZ1)
	addi	a0, a0, %lo(TIMER1KHZ1)
	j	.LBB9_3
.LBB9_2:
	lui	a0, %hi(TIMER1KHZ0)
	addi	a0, a0, %lo(TIMER1KHZ0)
.LBB9_3:
	lw	a0, 0(a0)
	lhu	a0, 0(a0)
	ret
.Lfunc_end9:
	.size	get_timer1khz, .Lfunc_end9-get_timer1khz
                                        # -- End function
	.section	.text.wait_timer1khz,"ax",@progbits
	.globl	wait_timer1khz                  # -- Begin function wait_timer1khz
	.p2align	1
	.type	wait_timer1khz,@function
wait_timer1khz:                         # @wait_timer1khz
# %bb.0:
	beqz	a0, .LBB10_2
# %bb.1:
	lui	a0, %hi(TIMER1KHZ1)
	addi	a0, a0, %lo(TIMER1KHZ1)
	j	.LBB10_3
.LBB10_2:
	lui	a0, %hi(TIMER1KHZ0)
	addi	a0, a0, %lo(TIMER1KHZ0)
.LBB10_3:
	lw	a0, 0(a0)
.LBB10_4:                               # =>This Inner Loop Header: Depth=1
	lhu	a1, 0(a0)
	bnez	a1, .LBB10_4
# %bb.5:
	ret
.Lfunc_end10:
	.size	wait_timer1khz, .Lfunc_end10-wait_timer1khz
                                        # -- End function
	.section	.text.get_timer1hz,"ax",@progbits
	.globl	get_timer1hz                    # -- Begin function get_timer1hz
	.p2align	1
	.type	get_timer1hz,@function
get_timer1hz:                           # @get_timer1hz
# %bb.0:
	beqz	a0, .LBB11_2
# %bb.1:
	lui	a0, %hi(TIMER1HZ1)
	addi	a0, a0, %lo(TIMER1HZ1)
	j	.LBB11_3
.LBB11_2:
	lui	a0, %hi(TIMER1HZ0)
	addi	a0, a0, %lo(TIMER1HZ0)
.LBB11_3:
	lw	a0, 0(a0)
	lhu	a0, 0(a0)
	ret
.Lfunc_end11:
	.size	get_timer1hz, .Lfunc_end11-get_timer1hz
                                        # -- End function
	.section	.text.reset_timer1hz,"ax",@progbits
	.globl	reset_timer1hz                  # -- Begin function reset_timer1hz
	.p2align	1
	.type	reset_timer1hz,@function
reset_timer1hz:                         # @reset_timer1hz
# %bb.0:
	beqz	a0, .LBB12_3
# %bb.1:
	addi	a1, zero, 1
	bne	a0, a1, .LBB12_5
# %bb.2:
	lui	a0, %hi(TIMER1HZ1)
	addi	a0, a0, %lo(TIMER1HZ1)
	j	.LBB12_4
.LBB12_3:
	lui	a0, %hi(TIMER1HZ0)
	addi	a0, a0, %lo(TIMER1HZ0)
.LBB12_4:
	lw	a0, 0(a0)
	addi	a1, zero, 1
	sh	a1, 0(a0)
.LBB12_5:
	ret
.Lfunc_end12:
	.size	reset_timer1hz, .Lfunc_end12-reset_timer1hz
                                        # -- End function
	.section	.text.systemclock,"ax",@progbits
	.globl	systemclock                     # -- Begin function systemclock
	.p2align	1
	.type	systemclock,@function
systemclock:                            # @systemclock
# %bb.0:
	lui	a0, %hi(SYSTEMCLOCK)
	lw	a0, %lo(SYSTEMCLOCK)(a0)
	lhu	a0, 0(a0)
	ret
.Lfunc_end13:
	.size	systemclock, .Lfunc_end13-systemclock
                                        # -- End function
	.section	.text.beep,"ax",@progbits
	.globl	beep                            # -- Begin function beep
	.p2align	1
	.type	beep,@function
beep:                                   # @beep
# %bb.0:
	andi	a4, a0, 1
	bnez	a4, .LBB14_3
# %bb.1:
	andi	a0, a0, 2
	bnez	a0, .LBB14_4
.LBB14_2:
	ret
.LBB14_3:
	lui	a4, %hi(AUDIO_L_WAVEFORM)
	lw	a4, %lo(AUDIO_L_WAVEFORM)(a4)
	sb	a1, 0(a4)
	lui	a4, %hi(AUDIO_L_NOTE)
	lw	a4, %lo(AUDIO_L_NOTE)(a4)
	sb	a2, 0(a4)
	lui	a4, %hi(AUDIO_L_DURATION)
	lw	a4, %lo(AUDIO_L_DURATION)(a4)
	sh	a3, 0(a4)
	lui	a4, %hi(AUDIO_L_START)
	lw	a4, %lo(AUDIO_L_START)(a4)
	addi	a5, zero, 1
	sb	a5, 0(a4)
	andi	a0, a0, 2
	beqz	a0, .LBB14_2
.LBB14_4:
	lui	a0, %hi(AUDIO_R_WAVEFORM)
	lw	a0, %lo(AUDIO_R_WAVEFORM)(a0)
	sb	a1, 0(a0)
	lui	a0, %hi(AUDIO_R_NOTE)
	lw	a0, %lo(AUDIO_R_NOTE)(a0)
	sb	a2, 0(a0)
	lui	a0, %hi(AUDIO_R_DURATION)
	lw	a0, %lo(AUDIO_R_DURATION)(a0)
	sh	a3, 0(a0)
	lui	a0, %hi(AUDIO_R_START)
	lw	a0, %lo(AUDIO_R_START)(a0)
	addi	a1, zero, 1
	sb	a1, 0(a0)
	ret
.Lfunc_end14:
	.size	beep, .Lfunc_end14-beep
                                        # -- End function
	.section	.text.await_beep,"ax",@progbits
	.globl	await_beep                      # -- Begin function await_beep
	.p2align	1
	.type	await_beep,@function
await_beep:                             # @await_beep
# %bb.0:
	andi	a1, a0, 1
	beqz	a1, .LBB15_3
# %bb.1:
	lui	a1, %hi(AUDIO_L_DURATION)
	lw	a1, %lo(AUDIO_L_DURATION)(a1)
.LBB15_2:                               # =>This Inner Loop Header: Depth=1
	lhu	a2, 0(a1)
	bnez	a2, .LBB15_2
.LBB15_3:
	andi	a0, a0, 2
	beqz	a0, .LBB15_6
# %bb.4:
	lui	a0, %hi(AUDIO_R_DURATION)
	lw	a0, %lo(AUDIO_R_DURATION)(a0)
.LBB15_5:                               # =>This Inner Loop Header: Depth=1
	lhu	a1, 0(a0)
	bnez	a1, .LBB15_5
.LBB15_6:
	ret
.Lfunc_end15:
	.size	await_beep, .Lfunc_end15-await_beep
                                        # -- End function
	.section	.text.get_beep_duration,"ax",@progbits
	.globl	get_beep_duration               # -- Begin function get_beep_duration
	.p2align	1
	.type	get_beep_duration,@function
get_beep_duration:                      # @get_beep_duration
# %bb.0:
	andi	a0, a0, 1
	beqz	a0, .LBB16_2
# %bb.1:
	lui	a0, %hi(AUDIO_L_DURATION)
	addi	a0, a0, %lo(AUDIO_L_DURATION)
	j	.LBB16_3
.LBB16_2:
	lui	a0, %hi(AUDIO_R_DURATION)
	addi	a0, a0, %lo(AUDIO_R_DURATION)
.LBB16_3:
	lw	a0, 0(a0)
	lhu	a0, 0(a0)
	ret
.Lfunc_end16:
	.size	get_beep_duration, .Lfunc_end16-get_beep_duration
                                        # -- End function
	.section	.text.sdcard_wait,"ax",@progbits
	.globl	sdcard_wait                     # -- Begin function sdcard_wait
	.p2align	1
	.type	sdcard_wait,@function
sdcard_wait:                            # @sdcard_wait
# %bb.0:
	lui	a0, %hi(SDCARD_READY)
	lw	a0, %lo(SDCARD_READY)(a0)
.LBB17_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, 0(a0)
	beqz	a1, .LBB17_1
# %bb.2:
	ret
.Lfunc_end17:
	.size	sdcard_wait, .Lfunc_end17-sdcard_wait
                                        # -- End function
	.section	.text.sdcard_readsector,"ax",@progbits
	.globl	sdcard_readsector               # -- Begin function sdcard_readsector
	.p2align	1
	.type	sdcard_readsector,@function
sdcard_readsector:                      # @sdcard_readsector
# %bb.0:
	lui	a2, %hi(SDCARD_READY)
	lw	a2, %lo(SDCARD_READY)(a2)
.LBB18_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a3, 0(a2)
	beqz	a3, .LBB18_1
# %bb.2:
	lui	a2, %hi(SDCARD_SECTOR_HIGH)
	lw	a2, %lo(SDCARD_SECTOR_HIGH)(a2)
	srli	a3, a0, 16
	sh	a3, 0(a2)
	lui	a2, %hi(SDCARD_SECTOR_LOW)
	lw	a2, %lo(SDCARD_SECTOR_LOW)(a2)
	sh	a0, 0(a2)
	lui	a0, %hi(SDCARD_START)
	lw	a0, %lo(SDCARD_START)(a0)
	addi	a2, zero, 1
	sb	a2, 0(a0)
	lui	a0, %hi(SDCARD_READY)
	lw	a0, %lo(SDCARD_READY)(a0)
.LBB18_3:                               # =>This Inner Loop Header: Depth=1
	lbu	a2, 0(a0)
	beqz	a2, .LBB18_3
# %bb.4:
	mv	a0, zero
	lui	a6, %hi(SDCARD_ADDRESS)
	lui	a3, %hi(SDCARD_DATA)
	addi	a4, zero, 512
.LBB18_5:                               # =>This Inner Loop Header: Depth=1
	lw	a5, %lo(SDCARD_ADDRESS)(a6)
	sh	a0, 0(a5)
	lw	a5, %lo(SDCARD_DATA)(a3)
	lb	a5, 0(a5)
	add	a2, a1, a0
	addi	a0, a0, 1
	sb	a5, 0(a2)
	bne	a0, a4, .LBB18_5
# %bb.6:
	ret
.Lfunc_end18:
	.size	sdcard_readsector, .Lfunc_end18-sdcard_readsector
                                        # -- End function
	.section	.text.set_leds,"ax",@progbits
	.globl	set_leds                        # -- Begin function set_leds
	.p2align	1
	.type	set_leds,@function
set_leds:                               # @set_leds
# %bb.0:
	lui	a1, %hi(LEDS)
	lw	a1, %lo(LEDS)(a1)
	sb	a0, 0(a1)
	ret
.Lfunc_end19:
	.size	set_leds, .Lfunc_end19-set_leds
                                        # -- End function
	.section	.text.get_buttons,"ax",@progbits
	.globl	get_buttons                     # -- Begin function get_buttons
	.p2align	1
	.type	get_buttons,@function
get_buttons:                            # @get_buttons
# %bb.0:
	lui	a0, %hi(BUTTONS)
	lw	a0, %lo(BUTTONS)(a0)
	lbu	a0, 0(a0)
	ret
.Lfunc_end20:
	.size	get_buttons, .Lfunc_end20-get_buttons
                                        # -- End function
	.section	.text.await_vblank,"ax",@progbits
	.globl	await_vblank                    # -- Begin function await_vblank
	.p2align	1
	.type	await_vblank,@function
await_vblank:                           # @await_vblank
# %bb.0:
	lui	a0, %hi(VBLANK)
	lw	a0, %lo(VBLANK)(a0)
.LBB21_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, 0(a0)
	beqz	a1, .LBB21_1
# %bb.2:
	ret
.Lfunc_end21:
	.size	await_vblank, .Lfunc_end21-await_vblank
                                        # -- End function
	.section	.text.screen_mode,"ax",@progbits
	.globl	screen_mode                     # -- Begin function screen_mode
	.p2align	1
	.type	screen_mode,@function
screen_mode:                            # @screen_mode
# %bb.0:
	lui	a1, %hi(SCREENMODE)
	lw	a1, %lo(SCREENMODE)(a1)
	sb	a0, 0(a1)
	ret
.Lfunc_end22:
	.size	screen_mode, .Lfunc_end22-screen_mode
                                        # -- End function
	.section	.text.set_background,"ax",@progbits
	.globl	set_background                  # -- Begin function set_background
	.p2align	1
	.type	set_background,@function
set_background:                         # @set_background
# %bb.0:
	lui	a3, %hi(BACKGROUND_COLOUR)
	lw	a3, %lo(BACKGROUND_COLOUR)(a3)
	sb	a0, 0(a3)
	lui	a0, %hi(BACKGROUND_ALTCOLOUR)
	lw	a0, %lo(BACKGROUND_ALTCOLOUR)(a0)
	sb	a1, 0(a0)
	lui	a0, %hi(BACKGROUND_MODE)
	lw	a0, %lo(BACKGROUND_MODE)(a0)
	sb	a2, 0(a0)
	ret
.Lfunc_end23:
	.size	set_background, .Lfunc_end23-set_background
                                        # -- End function
	.section	.text.set_tilemap_tile,"ax",@progbits
	.globl	set_tilemap_tile                # -- Begin function set_tilemap_tile
	.p2align	1
	.type	set_tilemap_tile,@function
set_tilemap_tile:                       # @set_tilemap_tile
# %bb.0:
	lui	a5, %hi(TM_STATUS)
	lw	a6, %lo(TM_STATUS)(a5)
.LBB24_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a5, 0(a6)
	bnez	a5, .LBB24_1
# %bb.2:
	lui	a5, %hi(TM_X)
	lw	a5, %lo(TM_X)(a5)
	sb	a0, 0(a5)
	lui	a0, %hi(TM_Y)
	lw	a0, %lo(TM_Y)(a0)
	sb	a1, 0(a0)
	lui	a0, %hi(TM_TILE)
	lw	a0, %lo(TM_TILE)(a0)
	sb	a2, 0(a0)
	lui	a0, %hi(TM_BACKGROUND)
	lw	a0, %lo(TM_BACKGROUND)(a0)
	sb	a3, 0(a0)
	lui	a0, %hi(TM_FOREGROUND)
	lw	a0, %lo(TM_FOREGROUND)(a0)
	sb	a4, 0(a0)
	lui	a0, %hi(TM_COMMIT)
	lw	a0, %lo(TM_COMMIT)(a0)
	addi	a1, zero, 1
	sb	a1, 0(a0)
	ret
.Lfunc_end24:
	.size	set_tilemap_tile, .Lfunc_end24-set_tilemap_tile
                                        # -- End function
	.section	.text.set_tilemap_bitmap,"ax",@progbits
	.globl	set_tilemap_bitmap              # -- Begin function set_tilemap_bitmap
	.p2align	1
	.type	set_tilemap_bitmap,@function
set_tilemap_bitmap:                     # @set_tilemap_bitmap
# %bb.0:
	lui	a2, %hi(TM_WRITER_TILE_NUMBER)
	lw	a2, %lo(TM_WRITER_TILE_NUMBER)(a2)
	sb	a0, 0(a2)
	lui	a0, %hi(TM_WRITER_LINE_NUMBER)
	lw	a2, %lo(TM_WRITER_LINE_NUMBER)(a0)
	sb	zero, 0(a2)
	lh	a3, 0(a1)
	lui	a2, %hi(TM_WRITER_BITMAP)
	lw	a4, %lo(TM_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(TM_WRITER_LINE_NUMBER)(a0)
	addi	a4, zero, 1
	sb	a4, 0(a3)
	lh	a3, 2(a1)
	lw	a4, %lo(TM_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(TM_WRITER_LINE_NUMBER)(a0)
	addi	a4, zero, 2
	sb	a4, 0(a3)
	lh	a3, 4(a1)
	lw	a4, %lo(TM_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(TM_WRITER_LINE_NUMBER)(a0)
	addi	a4, zero, 3
	sb	a4, 0(a3)
	lh	a3, 6(a1)
	lw	a4, %lo(TM_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(TM_WRITER_LINE_NUMBER)(a0)
	addi	a4, zero, 4
	sb	a4, 0(a3)
	lh	a3, 8(a1)
	lw	a4, %lo(TM_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(TM_WRITER_LINE_NUMBER)(a0)
	addi	a4, zero, 5
	sb	a4, 0(a3)
	lh	a3, 10(a1)
	lw	a4, %lo(TM_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(TM_WRITER_LINE_NUMBER)(a0)
	addi	a4, zero, 6
	sb	a4, 0(a3)
	lh	a3, 12(a1)
	lw	a4, %lo(TM_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(TM_WRITER_LINE_NUMBER)(a0)
	addi	a4, zero, 7
	sb	a4, 0(a3)
	lh	a3, 14(a1)
	lw	a4, %lo(TM_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(TM_WRITER_LINE_NUMBER)(a0)
	addi	a4, zero, 8
	sb	a4, 0(a3)
	lh	a3, 16(a1)
	lw	a4, %lo(TM_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(TM_WRITER_LINE_NUMBER)(a0)
	addi	a4, zero, 9
	sb	a4, 0(a3)
	lh	a3, 18(a1)
	lw	a4, %lo(TM_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(TM_WRITER_LINE_NUMBER)(a0)
	addi	a4, zero, 10
	sb	a4, 0(a3)
	lh	a3, 20(a1)
	lw	a4, %lo(TM_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(TM_WRITER_LINE_NUMBER)(a0)
	addi	a4, zero, 11
	sb	a4, 0(a3)
	lh	a3, 22(a1)
	lw	a4, %lo(TM_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(TM_WRITER_LINE_NUMBER)(a0)
	addi	a4, zero, 12
	sb	a4, 0(a3)
	lh	a3, 24(a1)
	lw	a4, %lo(TM_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(TM_WRITER_LINE_NUMBER)(a0)
	addi	a4, zero, 13
	sb	a4, 0(a3)
	lh	a3, 26(a1)
	lw	a4, %lo(TM_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(TM_WRITER_LINE_NUMBER)(a0)
	addi	a4, zero, 14
	sb	a4, 0(a3)
	lh	a3, 28(a1)
	lw	a4, %lo(TM_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a0, %lo(TM_WRITER_LINE_NUMBER)(a0)
	addi	a3, zero, 15
	sb	a3, 0(a0)
	lh	a0, 30(a1)
	lw	a1, %lo(TM_WRITER_BITMAP)(a2)
	sh	a0, 0(a1)
	ret
.Lfunc_end25:
	.size	set_tilemap_bitmap, .Lfunc_end25-set_tilemap_bitmap
                                        # -- End function
	.section	.text.tilemap_scrollwrapclear,"ax",@progbits
	.globl	tilemap_scrollwrapclear         # -- Begin function tilemap_scrollwrapclear
	.p2align	1
	.type	tilemap_scrollwrapclear,@function
tilemap_scrollwrapclear:                # @tilemap_scrollwrapclear
# %bb.0:
	lui	a1, %hi(TM_STATUS)
	lw	a1, %lo(TM_STATUS)(a1)
.LBB26_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a2, 0(a1)
	bnez	a2, .LBB26_1
# %bb.2:
	lui	a1, %hi(TM_SCROLLWRAPCLEAR)
	lw	a2, %lo(TM_SCROLLWRAPCLEAR)(a1)
	sb	a0, 0(a2)
	lw	a0, %lo(TM_SCROLLWRAPCLEAR)(a1)
	lbu	a0, 0(a0)
	ret
.Lfunc_end26:
	.size	tilemap_scrollwrapclear, .Lfunc_end26-tilemap_scrollwrapclear
                                        # -- End function
	.section	.text.wait_gpu,"ax",@progbits
	.globl	wait_gpu                        # -- Begin function wait_gpu
	.p2align	1
	.type	wait_gpu,@function
wait_gpu:                               # @wait_gpu
# %bb.0:
	lui	a0, %hi(GPU_STATUS)
	lw	a0, %lo(GPU_STATUS)(a0)
.LBB27_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, 0(a0)
	bnez	a1, .LBB27_1
# %bb.2:
	ret
.Lfunc_end27:
	.size	wait_gpu, .Lfunc_end27-wait_gpu
                                        # -- End function
	.section	.text.bitmap_scrollwrap,"ax",@progbits
	.globl	bitmap_scrollwrap               # -- Begin function bitmap_scrollwrap
	.p2align	1
	.type	bitmap_scrollwrap,@function
bitmap_scrollwrap:                      # @bitmap_scrollwrap
# %bb.0:
	lui	a1, %hi(GPU_STATUS)
	lw	a1, %lo(GPU_STATUS)(a1)
.LBB28_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a2, 0(a1)
	bnez	a2, .LBB28_1
# %bb.2:
	lui	a1, %hi(BITMAP_SCROLLWRAP)
	lw	a1, %lo(BITMAP_SCROLLWRAP)(a1)
	sb	a0, 0(a1)
	ret
.Lfunc_end28:
	.size	bitmap_scrollwrap, .Lfunc_end28-bitmap_scrollwrap
                                        # -- End function
	.section	.text.gpu_dither,"ax",@progbits
	.globl	gpu_dither                      # -- Begin function gpu_dither
	.p2align	1
	.type	gpu_dither,@function
gpu_dither:                             # @gpu_dither
# %bb.0:
	lui	a2, %hi(GPU_COLOUR_ALT)
	lw	a2, %lo(GPU_COLOUR_ALT)(a2)
	sb	a1, 0(a2)
	lui	a1, %hi(GPU_DITHERMODE)
	lw	a1, %lo(GPU_DITHERMODE)(a1)
	sb	a0, 0(a1)
	ret
.Lfunc_end29:
	.size	gpu_dither, .Lfunc_end29-gpu_dither
                                        # -- End function
	.section	.text.gpu_pixel,"ax",@progbits
	.globl	gpu_pixel                       # -- Begin function gpu_pixel
	.p2align	1
	.type	gpu_pixel,@function
gpu_pixel:                              # @gpu_pixel
# %bb.0:
	lui	a3, %hi(GPU_STATUS)
	lw	a3, %lo(GPU_STATUS)(a3)
.LBB30_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a4, 0(a3)
	bnez	a4, .LBB30_1
# %bb.2:
	lui	a3, %hi(GPU_COLOUR)
	lw	a3, %lo(GPU_COLOUR)(a3)
	sb	a0, 0(a3)
	lui	a0, %hi(GPU_X)
	lw	a0, %lo(GPU_X)(a0)
	sh	a1, 0(a0)
	lui	a0, %hi(GPU_Y)
	lw	a0, %lo(GPU_Y)(a0)
	sh	a2, 0(a0)
	lui	a0, %hi(GPU_WRITE)
	lw	a0, %lo(GPU_WRITE)(a0)
	addi	a1, zero, 1
	sb	a1, 0(a0)
	ret
.Lfunc_end30:
	.size	gpu_pixel, .Lfunc_end30-gpu_pixel
                                        # -- End function
	.section	.text.gpu_line,"ax",@progbits
	.globl	gpu_line                        # -- Begin function gpu_line
	.p2align	1
	.type	gpu_line,@function
gpu_line:                               # @gpu_line
# %bb.0:
	lui	a5, %hi(GPU_COLOUR)
	lw	a5, %lo(GPU_COLOUR)(a5)
	sb	a0, 0(a5)
	lui	a0, %hi(GPU_X)
	lw	a0, %lo(GPU_X)(a0)
	sh	a1, 0(a0)
	lui	a0, %hi(GPU_Y)
	lw	a0, %lo(GPU_Y)(a0)
	sh	a2, 0(a0)
	lui	a0, %hi(GPU_PARAM0)
	lw	a0, %lo(GPU_PARAM0)(a0)
	sh	a3, 0(a0)
	lui	a0, %hi(GPU_PARAM1)
	lw	a0, %lo(GPU_PARAM1)(a0)
	sh	a4, 0(a0)
	lui	a0, %hi(GPU_STATUS)
	lw	a0, %lo(GPU_STATUS)(a0)
.LBB31_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, 0(a0)
	bnez	a1, .LBB31_1
# %bb.2:
	lui	a0, %hi(GPU_WRITE)
	lw	a0, %lo(GPU_WRITE)(a0)
	addi	a1, zero, 2
	sb	a1, 0(a0)
	ret
.Lfunc_end31:
	.size	gpu_line, .Lfunc_end31-gpu_line
                                        # -- End function
	.section	.text.gpu_box,"ax",@progbits
	.globl	gpu_box                         # -- Begin function gpu_box
	.p2align	1
	.type	gpu_box,@function
gpu_box:                                # @gpu_box
# %bb.0:
	lui	a5, %hi(GPU_COLOUR)
	lw	a5, %lo(GPU_COLOUR)(a5)
	sb	a0, 0(a5)
	lui	a5, %hi(GPU_X)
	lw	a5, %lo(GPU_X)(a5)
	sh	a1, 0(a5)
	lui	a5, %hi(GPU_Y)
	lw	a5, %lo(GPU_Y)(a5)
	sh	a2, 0(a5)
	lui	a5, %hi(GPU_PARAM0)
	lw	a5, %lo(GPU_PARAM0)(a5)
	sh	a3, 0(a5)
	lui	a5, %hi(GPU_PARAM1)
	lw	a5, %lo(GPU_PARAM1)(a5)
	sh	a2, 0(a5)
	lui	a5, %hi(GPU_STATUS)
	lw	a6, %lo(GPU_STATUS)(a5)
.LBB32_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a5, 0(a6)
	bnez	a5, .LBB32_1
# %bb.2:
	lui	a5, %hi(GPU_WRITE)
	lw	a6, %lo(GPU_WRITE)(a5)
	addi	a5, zero, 2
	sb	a5, 0(a6)
	lui	a5, %hi(GPU_COLOUR)
	lw	a5, %lo(GPU_COLOUR)(a5)
	sb	a0, 0(a5)
	lui	a5, %hi(GPU_X)
	lw	a5, %lo(GPU_X)(a5)
	sh	a3, 0(a5)
	lui	a5, %hi(GPU_Y)
	lw	a5, %lo(GPU_Y)(a5)
	sh	a2, 0(a5)
	lui	a5, %hi(GPU_PARAM0)
	lw	a5, %lo(GPU_PARAM0)(a5)
	sh	a3, 0(a5)
	lui	a5, %hi(GPU_PARAM1)
	lw	a5, %lo(GPU_PARAM1)(a5)
	sh	a4, 0(a5)
	lui	a5, %hi(GPU_STATUS)
	lw	a6, %lo(GPU_STATUS)(a5)
.LBB32_3:                               # =>This Inner Loop Header: Depth=1
	lbu	a5, 0(a6)
	bnez	a5, .LBB32_3
# %bb.4:
	lui	a5, %hi(GPU_WRITE)
	lw	a6, %lo(GPU_WRITE)(a5)
	addi	a5, zero, 2
	sb	a5, 0(a6)
	lui	a5, %hi(GPU_COLOUR)
	lw	a5, %lo(GPU_COLOUR)(a5)
	sb	a0, 0(a5)
	lui	a5, %hi(GPU_X)
	lw	a5, %lo(GPU_X)(a5)
	sh	a3, 0(a5)
	lui	a3, %hi(GPU_Y)
	lw	a3, %lo(GPU_Y)(a3)
	sh	a4, 0(a3)
	lui	a3, %hi(GPU_PARAM0)
	lw	a3, %lo(GPU_PARAM0)(a3)
	sh	a1, 0(a3)
	lui	a3, %hi(GPU_PARAM1)
	lw	a3, %lo(GPU_PARAM1)(a3)
	sh	a4, 0(a3)
	lui	a3, %hi(GPU_STATUS)
	lw	a3, %lo(GPU_STATUS)(a3)
.LBB32_5:                               # =>This Inner Loop Header: Depth=1
	lbu	a5, 0(a3)
	bnez	a5, .LBB32_5
# %bb.6:
	lui	a3, %hi(GPU_WRITE)
	lw	a3, %lo(GPU_WRITE)(a3)
	addi	a5, zero, 2
	sb	a5, 0(a3)
	lui	a3, %hi(GPU_COLOUR)
	lw	a3, %lo(GPU_COLOUR)(a3)
	sb	a0, 0(a3)
	lui	a0, %hi(GPU_X)
	lw	a0, %lo(GPU_X)(a0)
	sh	a1, 0(a0)
	lui	a0, %hi(GPU_Y)
	lw	a0, %lo(GPU_Y)(a0)
	sh	a4, 0(a0)
	lui	a0, %hi(GPU_PARAM0)
	lw	a0, %lo(GPU_PARAM0)(a0)
	sh	a1, 0(a0)
	lui	a0, %hi(GPU_PARAM1)
	lw	a0, %lo(GPU_PARAM1)(a0)
	sh	a2, 0(a0)
	lui	a0, %hi(GPU_STATUS)
	lw	a0, %lo(GPU_STATUS)(a0)
.LBB32_7:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, 0(a0)
	bnez	a1, .LBB32_7
# %bb.8:
	lui	a0, %hi(GPU_WRITE)
	lw	a0, %lo(GPU_WRITE)(a0)
	addi	a1, zero, 2
	sb	a1, 0(a0)
	ret
.Lfunc_end32:
	.size	gpu_box, .Lfunc_end32-gpu_box
                                        # -- End function
	.section	.text.gpu_rectangle,"ax",@progbits
	.globl	gpu_rectangle                   # -- Begin function gpu_rectangle
	.p2align	1
	.type	gpu_rectangle,@function
gpu_rectangle:                          # @gpu_rectangle
# %bb.0:
	lui	a5, %hi(GPU_COLOUR)
	lw	a5, %lo(GPU_COLOUR)(a5)
	sb	a0, 0(a5)
	lui	a0, %hi(GPU_X)
	lw	a0, %lo(GPU_X)(a0)
	sh	a1, 0(a0)
	lui	a0, %hi(GPU_Y)
	lw	a0, %lo(GPU_Y)(a0)
	sh	a2, 0(a0)
	lui	a0, %hi(GPU_PARAM0)
	lw	a0, %lo(GPU_PARAM0)(a0)
	sh	a3, 0(a0)
	lui	a0, %hi(GPU_PARAM1)
	lw	a0, %lo(GPU_PARAM1)(a0)
	sh	a4, 0(a0)
	lui	a0, %hi(GPU_STATUS)
	lw	a0, %lo(GPU_STATUS)(a0)
.LBB33_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, 0(a0)
	bnez	a1, .LBB33_1
# %bb.2:
	lui	a0, %hi(GPU_WRITE)
	lw	a0, %lo(GPU_WRITE)(a0)
	addi	a1, zero, 3
	sb	a1, 0(a0)
	ret
.Lfunc_end33:
	.size	gpu_rectangle, .Lfunc_end33-gpu_rectangle
                                        # -- End function
	.section	.text.gpu_cs,"ax",@progbits
	.globl	gpu_cs                          # -- Begin function gpu_cs
	.p2align	1
	.type	gpu_cs,@function
gpu_cs:                                 # @gpu_cs
# %bb.0:
	lui	a0, %hi(GPU_STATUS)
	lw	a0, %lo(GPU_STATUS)(a0)
.LBB34_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, 0(a0)
	bnez	a1, .LBB34_1
# %bb.2:
	lui	a0, %hi(BITMAP_SCROLLWRAP)
	lw	a0, %lo(BITMAP_SCROLLWRAP)(a0)
	addi	a1, zero, 5
	sb	a1, 0(a0)
	lui	a0, %hi(GPU_COLOUR)
	lw	a0, %lo(GPU_COLOUR)(a0)
	addi	a1, zero, 64
	sb	a1, 0(a0)
	lui	a0, %hi(GPU_X)
	lw	a0, %lo(GPU_X)(a0)
	sh	zero, 0(a0)
	lui	a0, %hi(GPU_Y)
	lw	a0, %lo(GPU_Y)(a0)
	sh	zero, 0(a0)
	lui	a0, %hi(GPU_PARAM0)
	lw	a0, %lo(GPU_PARAM0)(a0)
	addi	a1, zero, 639
	sh	a1, 0(a0)
	lui	a0, %hi(GPU_PARAM1)
	lw	a0, %lo(GPU_PARAM1)(a0)
	addi	a1, zero, 479
	sh	a1, 0(a0)
	lui	a0, %hi(GPU_STATUS)
	lw	a0, %lo(GPU_STATUS)(a0)
.LBB34_3:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, 0(a0)
	bnez	a1, .LBB34_3
# %bb.4:
	lui	a0, %hi(GPU_WRITE)
	lw	a0, %lo(GPU_WRITE)(a0)
	addi	a1, zero, 3
	sb	a1, 0(a0)
	ret
.Lfunc_end34:
	.size	gpu_cs, .Lfunc_end34-gpu_cs
                                        # -- End function
	.section	.text.gpu_circle,"ax",@progbits
	.globl	gpu_circle                      # -- Begin function gpu_circle
	.p2align	1
	.type	gpu_circle,@function
gpu_circle:                             # @gpu_circle
# %bb.0:
	lui	a5, %hi(GPU_COLOUR)
	lw	a5, %lo(GPU_COLOUR)(a5)
	sb	a0, 0(a5)
	lui	a0, %hi(GPU_X)
	lw	a0, %lo(GPU_X)(a0)
	sh	a1, 0(a0)
	lui	a0, %hi(GPU_Y)
	lw	a0, %lo(GPU_Y)(a0)
	sh	a2, 0(a0)
	lui	a0, %hi(GPU_PARAM0)
	lw	a0, %lo(GPU_PARAM0)(a0)
	sh	a3, 0(a0)
	lui	a0, %hi(GPU_STATUS)
	lw	a0, %lo(GPU_STATUS)(a0)
.LBB35_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, 0(a0)
	bnez	a1, .LBB35_1
# %bb.2:
	lui	a0, %hi(GPU_WRITE)
	lw	a0, %lo(GPU_WRITE)(a0)
	seqz	a1, a4
	addi	a2, zero, 5
	sub	a1, a2, a1
	sb	a1, 0(a0)
	ret
.Lfunc_end35:
	.size	gpu_circle, .Lfunc_end35-gpu_circle
                                        # -- End function
	.section	.text.gpu_blit,"ax",@progbits
	.globl	gpu_blit                        # -- Begin function gpu_blit
	.p2align	1
	.type	gpu_blit,@function
gpu_blit:                               # @gpu_blit
# %bb.0:
	lui	a5, %hi(GPU_COLOUR)
	lw	a5, %lo(GPU_COLOUR)(a5)
	sb	a0, 0(a5)
	lui	a0, %hi(GPU_X)
	lw	a0, %lo(GPU_X)(a0)
	sh	a1, 0(a0)
	lui	a0, %hi(GPU_Y)
	lw	a0, %lo(GPU_Y)(a0)
	sh	a2, 0(a0)
	lui	a0, %hi(GPU_PARAM0)
	lw	a0, %lo(GPU_PARAM0)(a0)
	sh	a3, 0(a0)
	lui	a0, %hi(GPU_PARAM1)
	lw	a0, %lo(GPU_PARAM1)(a0)
	sh	a4, 0(a0)
	lui	a0, %hi(GPU_STATUS)
	lw	a0, %lo(GPU_STATUS)(a0)
.LBB36_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, 0(a0)
	bnez	a1, .LBB36_1
# %bb.2:
	lui	a0, %hi(GPU_WRITE)
	lw	a0, %lo(GPU_WRITE)(a0)
	addi	a1, zero, 7
	sb	a1, 0(a0)
	ret
.Lfunc_end36:
	.size	gpu_blit, .Lfunc_end36-gpu_blit
                                        # -- End function
	.section	.text.gpu_character_blit,"ax",@progbits
	.globl	gpu_character_blit              # -- Begin function gpu_character_blit
	.p2align	1
	.type	gpu_character_blit,@function
gpu_character_blit:                     # @gpu_character_blit
# %bb.0:
	lui	a5, %hi(GPU_COLOUR)
	lw	a5, %lo(GPU_COLOUR)(a5)
	sb	a0, 0(a5)
	lui	a0, %hi(GPU_X)
	lw	a0, %lo(GPU_X)(a0)
	sh	a1, 0(a0)
	lui	a0, %hi(GPU_Y)
	lw	a0, %lo(GPU_Y)(a0)
	sh	a2, 0(a0)
	lui	a0, %hi(GPU_PARAM0)
	lw	a0, %lo(GPU_PARAM0)(a0)
	sh	a3, 0(a0)
	lui	a0, %hi(GPU_PARAM1)
	lw	a0, %lo(GPU_PARAM1)(a0)
	sh	a4, 0(a0)
	lui	a0, %hi(GPU_STATUS)
	lw	a0, %lo(GPU_STATUS)(a0)
.LBB37_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, 0(a0)
	bnez	a1, .LBB37_1
# %bb.2:
	lui	a0, %hi(GPU_WRITE)
	lw	a0, %lo(GPU_WRITE)(a0)
	addi	a1, zero, 8
	sb	a1, 0(a0)
	ret
.Lfunc_end37:
	.size	gpu_character_blit, .Lfunc_end37-gpu_character_blit
                                        # -- End function
	.section	.text.set_blitter_bitmap,"ax",@progbits
	.globl	set_blitter_bitmap              # -- Begin function set_blitter_bitmap
	.p2align	1
	.type	set_blitter_bitmap,@function
set_blitter_bitmap:                     # @set_blitter_bitmap
# %bb.0:
	lui	a2, %hi(BLIT_WRITER_TILE)
	lw	a2, %lo(BLIT_WRITER_TILE)(a2)
	sb	a0, 0(a2)
	lui	a0, %hi(BLIT_WRITER_LINE)
	lw	a2, %lo(BLIT_WRITER_LINE)(a0)
	sb	zero, 0(a2)
	lh	a3, 0(a1)
	lui	a2, %hi(BLIT_WRITER_BITMAP)
	lw	a4, %lo(BLIT_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(BLIT_WRITER_LINE)(a0)
	addi	a4, zero, 1
	sb	a4, 0(a3)
	lh	a3, 2(a1)
	lw	a4, %lo(BLIT_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(BLIT_WRITER_LINE)(a0)
	addi	a4, zero, 2
	sb	a4, 0(a3)
	lh	a3, 4(a1)
	lw	a4, %lo(BLIT_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(BLIT_WRITER_LINE)(a0)
	addi	a4, zero, 3
	sb	a4, 0(a3)
	lh	a3, 6(a1)
	lw	a4, %lo(BLIT_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(BLIT_WRITER_LINE)(a0)
	addi	a4, zero, 4
	sb	a4, 0(a3)
	lh	a3, 8(a1)
	lw	a4, %lo(BLIT_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(BLIT_WRITER_LINE)(a0)
	addi	a4, zero, 5
	sb	a4, 0(a3)
	lh	a3, 10(a1)
	lw	a4, %lo(BLIT_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(BLIT_WRITER_LINE)(a0)
	addi	a4, zero, 6
	sb	a4, 0(a3)
	lh	a3, 12(a1)
	lw	a4, %lo(BLIT_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(BLIT_WRITER_LINE)(a0)
	addi	a4, zero, 7
	sb	a4, 0(a3)
	lh	a3, 14(a1)
	lw	a4, %lo(BLIT_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(BLIT_WRITER_LINE)(a0)
	addi	a4, zero, 8
	sb	a4, 0(a3)
	lh	a3, 16(a1)
	lw	a4, %lo(BLIT_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(BLIT_WRITER_LINE)(a0)
	addi	a4, zero, 9
	sb	a4, 0(a3)
	lh	a3, 18(a1)
	lw	a4, %lo(BLIT_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(BLIT_WRITER_LINE)(a0)
	addi	a4, zero, 10
	sb	a4, 0(a3)
	lh	a3, 20(a1)
	lw	a4, %lo(BLIT_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(BLIT_WRITER_LINE)(a0)
	addi	a4, zero, 11
	sb	a4, 0(a3)
	lh	a3, 22(a1)
	lw	a4, %lo(BLIT_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(BLIT_WRITER_LINE)(a0)
	addi	a4, zero, 12
	sb	a4, 0(a3)
	lh	a3, 24(a1)
	lw	a4, %lo(BLIT_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(BLIT_WRITER_LINE)(a0)
	addi	a4, zero, 13
	sb	a4, 0(a3)
	lh	a3, 26(a1)
	lw	a4, %lo(BLIT_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a3, %lo(BLIT_WRITER_LINE)(a0)
	addi	a4, zero, 14
	sb	a4, 0(a3)
	lh	a3, 28(a1)
	lw	a4, %lo(BLIT_WRITER_BITMAP)(a2)
	sh	a3, 0(a4)
	lw	a0, %lo(BLIT_WRITER_LINE)(a0)
	addi	a3, zero, 15
	sb	a3, 0(a0)
	lh	a0, 30(a1)
	lw	a1, %lo(BLIT_WRITER_BITMAP)(a2)
	sh	a0, 0(a1)
	ret
.Lfunc_end38:
	.size	set_blitter_bitmap, .Lfunc_end38-set_blitter_bitmap
                                        # -- End function
	.section	.text.gpu_triangle,"ax",@progbits
	.globl	gpu_triangle                    # -- Begin function gpu_triangle
	.p2align	1
	.type	gpu_triangle,@function
gpu_triangle:                           # @gpu_triangle
# %bb.0:
	lui	a7, %hi(GPU_COLOUR)
	lw	a7, %lo(GPU_COLOUR)(a7)
	sb	a0, 0(a7)
	lui	a0, %hi(GPU_X)
	lw	a0, %lo(GPU_X)(a0)
	sh	a1, 0(a0)
	lui	a0, %hi(GPU_Y)
	lw	a0, %lo(GPU_Y)(a0)
	sh	a2, 0(a0)
	lui	a0, %hi(GPU_PARAM0)
	lw	a0, %lo(GPU_PARAM0)(a0)
	sh	a3, 0(a0)
	lui	a0, %hi(GPU_PARAM1)
	lw	a0, %lo(GPU_PARAM1)(a0)
	sh	a4, 0(a0)
	lui	a0, %hi(GPU_PARAM2)
	lw	a0, %lo(GPU_PARAM2)(a0)
	sh	a5, 0(a0)
	lui	a0, %hi(GPU_PARAM3)
	lw	a0, %lo(GPU_PARAM3)(a0)
	sh	a6, 0(a0)
	lui	a0, %hi(GPU_STATUS)
	lw	a0, %lo(GPU_STATUS)(a0)
.LBB39_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, 0(a0)
	bnez	a1, .LBB39_1
# %bb.2:
	lui	a0, %hi(GPU_WRITE)
	lw	a0, %lo(GPU_WRITE)(a0)
	addi	a1, zero, 6
	sb	a1, 0(a0)
	ret
.Lfunc_end39:
	.size	gpu_triangle, .Lfunc_end39-gpu_triangle
                                        # -- End function
	.section	.text.gpu_quadrilateral,"ax",@progbits
	.globl	gpu_quadrilateral               # -- Begin function gpu_quadrilateral
	.p2align	1
	.type	gpu_quadrilateral,@function
gpu_quadrilateral:                      # @gpu_quadrilateral
# %bb.0:
	lui	t0, %hi(GPU_COLOUR)
	lw	t0, %lo(GPU_COLOUR)(t0)
	sb	a0, 0(t0)
	lui	t0, %hi(GPU_X)
	lw	t0, %lo(GPU_X)(t0)
	sh	a1, 0(t0)
	lui	t0, %hi(GPU_Y)
	lw	t0, %lo(GPU_Y)(t0)
	sh	a2, 0(t0)
	lui	t0, %hi(GPU_PARAM0)
	lw	t0, %lo(GPU_PARAM0)(t0)
	sh	a3, 0(t0)
	lui	a3, %hi(GPU_PARAM1)
	lw	a3, %lo(GPU_PARAM1)(a3)
	sh	a4, 0(a3)
	lui	a3, %hi(GPU_PARAM2)
	lw	a3, %lo(GPU_PARAM2)(a3)
	sh	a5, 0(a3)
	lui	a3, %hi(GPU_PARAM3)
	lw	a4, %lo(GPU_PARAM3)(a3)
	lw	t0, 0(sp)
	sh	a6, 0(a4)
	lui	a4, %hi(GPU_STATUS)
	lw	a4, %lo(GPU_STATUS)(a4)
.LBB40_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a3, 0(a4)
	bnez	a3, .LBB40_1
# %bb.2:
	lui	a3, %hi(GPU_WRITE)
	lw	a3, %lo(GPU_WRITE)(a3)
	addi	a4, zero, 6
	sb	a4, 0(a3)
	lui	a3, %hi(GPU_COLOUR)
	lw	a3, %lo(GPU_COLOUR)(a3)
	sb	a0, 0(a3)
	lui	a0, %hi(GPU_X)
	lw	a0, %lo(GPU_X)(a0)
	sh	a1, 0(a0)
	lui	a0, %hi(GPU_Y)
	lw	a0, %lo(GPU_Y)(a0)
	sh	a2, 0(a0)
	lui	a0, %hi(GPU_PARAM0)
	lw	a0, %lo(GPU_PARAM0)(a0)
	sh	a5, 0(a0)
	lui	a0, %hi(GPU_PARAM1)
	lw	a0, %lo(GPU_PARAM1)(a0)
	sh	a6, 0(a0)
	lui	a0, %hi(GPU_PARAM2)
	lw	a0, %lo(GPU_PARAM2)(a0)
	sh	a7, 0(a0)
	lui	a0, %hi(GPU_PARAM3)
	lw	a0, %lo(GPU_PARAM3)(a0)
	sh	t0, 0(a0)
	lui	a0, %hi(GPU_STATUS)
	lw	a0, %lo(GPU_STATUS)(a0)
.LBB40_3:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, 0(a0)
	bnez	a1, .LBB40_3
# %bb.4:
	lui	a0, %hi(GPU_WRITE)
	lw	a0, %lo(GPU_WRITE)(a0)
	addi	a1, zero, 6
	sb	a1, 0(a0)
	ret
.Lfunc_end40:
	.size	gpu_quadrilateral, .Lfunc_end40-gpu_quadrilateral
                                        # -- End function
	.section	.text.gpu_printf,"ax",@progbits
	.globl	gpu_printf                      # -- Begin function gpu_printf
	.p2align	1
	.type	gpu_printf,@function
gpu_printf:                             # @gpu_printf
# %bb.0:
	addi	sp, sp, -48
	sw	ra, 28(sp)
	sw	s0, 24(sp)
	sw	s1, 20(sp)
	sw	s2, 16(sp)
	sw	s3, 12(sp)
	sw	s4, 8(sp)
	sw	s5, 4(sp)
	add	s3, zero, a3
	add	s2, zero, a2
	add	s1, zero, a1
	add	s4, zero, a0
	sw	a7, 44(sp)
	sw	a6, 40(sp)
	sw	a5, 36(sp)
	addi	a3, sp, 36
	sw	a3, 0(sp)
	lui	s5, %hi(gpu_printf.buffer)
	addi	s0, s5, %lo(gpu_printf.buffer)
	addi	a1, zero, 80
	add	a0, zero, s0
	add	a2, zero, a4
	call	vsnprintf
	lbu	a5, %lo(gpu_printf.buffer)(s5)
	beqz	a5, .LBB41_5
# %bb.1:
	addi	a7, zero, 8
	sll	a1, a7, s3
	lui	a6, %hi(GPU_COLOUR)
	lui	t0, %hi(GPU_X)
	lui	t1, %hi(GPU_Y)
	lui	t2, %hi(GPU_PARAM0)
	lui	a0, %hi(GPU_PARAM1)
	lui	a3, %hi(GPU_STATUS)
	lui	a4, %hi(GPU_WRITE)
.LBB41_2:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB41_3 Depth 2
	lw	a2, %lo(GPU_COLOUR)(a6)
	sb	s4, 0(a2)
	lw	a2, %lo(GPU_X)(t0)
	sh	s1, 0(a2)
	lw	a2, %lo(GPU_Y)(t1)
	sh	s2, 0(a2)
	lw	a2, %lo(GPU_PARAM0)(t2)
	andi	a5, a5, 255
	sh	a5, 0(a2)
	lw	a2, %lo(GPU_PARAM1)(a0)
	sh	s3, 0(a2)
	lw	a5, %lo(GPU_STATUS)(a3)
.LBB41_3:                               #   Parent Loop BB41_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lbu	a2, 0(a5)
	bnez	a2, .LBB41_3
# %bb.4:                                #   in Loop: Header=BB41_2 Depth=1
	lw	a2, %lo(GPU_WRITE)(a4)
	sb	a7, 0(a2)
	lbu	a5, 1(s0)
	addi	s0, s0, 1
	add	s1, s1, a1
	bnez	a5, .LBB41_2
.LBB41_5:
	lw	s5, 4(sp)
	lw	s4, 8(sp)
	lw	s3, 12(sp)
	lw	s2, 16(sp)
	lw	s1, 20(sp)
	lw	s0, 24(sp)
	lw	ra, 28(sp)
	addi	sp, sp, 48
	ret
.Lfunc_end41:
	.size	gpu_printf, .Lfunc_end41-gpu_printf
                                        # -- End function
	.section	.text.gpu_printf_centre,"ax",@progbits
	.globl	gpu_printf_centre               # -- Begin function gpu_printf_centre
	.p2align	1
	.type	gpu_printf_centre,@function
gpu_printf_centre:                      # @gpu_printf_centre
# %bb.0:
	addi	sp, sp, -64
	sw	ra, 44(sp)
	sw	s0, 40(sp)
	sw	s1, 36(sp)
	sw	s2, 32(sp)
	sw	s3, 28(sp)
	sw	s4, 24(sp)
	sw	s5, 20(sp)
	sw	s6, 16(sp)
	sw	s7, 12(sp)
	add	s6, zero, a3
	add	s2, zero, a2
	add	s4, zero, a1
	add	s3, zero, a0
	sw	a7, 60(sp)
	sw	a6, 56(sp)
	sw	a5, 52(sp)
	addi	a3, sp, 52
	sw	a3, 8(sp)
	lui	s0, %hi(gpu_printf_centre.buffer)
	addi	s1, s0, %lo(gpu_printf_centre.buffer)
	addi	a1, zero, 80
	add	a0, zero, s1
	add	a2, zero, a4
	call	vsnprintf
	lbu	s0, %lo(gpu_printf_centre.buffer)(s0)
	beqz	s0, .LBB42_5
# %bb.1:
	addi	s5, zero, 8
	sll	s7, s5, s6
	add	a0, zero, s1
	call	strlen
	mul	a0, a0, s7
	srli	a0, a0, 1
	sub	a0, s4, a0
	lui	a6, %hi(GPU_COLOUR)
	lui	a7, %hi(GPU_X)
	lui	t0, %hi(GPU_Y)
	lui	a4, %hi(GPU_PARAM0)
	lui	a5, %hi(GPU_PARAM1)
	lui	a1, %hi(GPU_STATUS)
	lui	a2, %hi(GPU_WRITE)
.LBB42_2:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB42_3 Depth 2
	lw	a3, %lo(GPU_COLOUR)(a6)
	sb	s3, 0(a3)
	lw	a3, %lo(GPU_X)(a7)
	sh	a0, 0(a3)
	lw	a3, %lo(GPU_Y)(t0)
	sh	s2, 0(a3)
	lw	a3, %lo(GPU_PARAM0)(a4)
	andi	s0, s0, 255
	sh	s0, 0(a3)
	lw	a3, %lo(GPU_PARAM1)(a5)
	sh	s6, 0(a3)
	lw	s0, %lo(GPU_STATUS)(a1)
.LBB42_3:                               #   Parent Loop BB42_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lbu	a3, 0(s0)
	bnez	a3, .LBB42_3
# %bb.4:                                #   in Loop: Header=BB42_2 Depth=1
	lw	a3, %lo(GPU_WRITE)(a2)
	sb	s5, 0(a3)
	lbu	s0, 1(s1)
	addi	s1, s1, 1
	add	a0, a0, s7
	bnez	s0, .LBB42_2
.LBB42_5:
	lw	s7, 12(sp)
	lw	s6, 16(sp)
	lw	s5, 20(sp)
	lw	s4, 24(sp)
	lw	s3, 28(sp)
	lw	s2, 32(sp)
	lw	s1, 36(sp)
	lw	s0, 40(sp)
	lw	ra, 44(sp)
	addi	sp, sp, 64
	ret
.Lfunc_end42:
	.size	gpu_printf_centre, .Lfunc_end42-gpu_printf_centre
                                        # -- End function
	.section	.text.wait_vector_block,"ax",@progbits
	.globl	wait_vector_block               # -- Begin function wait_vector_block
	.p2align	1
	.type	wait_vector_block,@function
wait_vector_block:                      # @wait_vector_block
# %bb.0:
	lui	a0, %hi(VECTOR_DRAW_STATUS)
	lw	a0, %lo(VECTOR_DRAW_STATUS)(a0)
.LBB43_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, 0(a0)
	bnez	a1, .LBB43_1
# %bb.2:
	ret
.Lfunc_end43:
	.size	wait_vector_block, .Lfunc_end43-wait_vector_block
                                        # -- End function
	.section	.text.draw_vector_block,"ax",@progbits
	.globl	draw_vector_block               # -- Begin function draw_vector_block
	.p2align	1
	.type	draw_vector_block,@function
draw_vector_block:                      # @draw_vector_block
# %bb.0:
	lui	a4, %hi(VECTOR_DRAW_STATUS)
	lw	a4, %lo(VECTOR_DRAW_STATUS)(a4)
.LBB44_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a5, 0(a4)
	bnez	a5, .LBB44_1
# %bb.2:
	lui	a4, %hi(VECTOR_DRAW_BLOCK)
	lw	a4, %lo(VECTOR_DRAW_BLOCK)(a4)
	sb	a0, 0(a4)
	lui	a0, %hi(VECTOR_DRAW_COLOUR)
	lw	a0, %lo(VECTOR_DRAW_COLOUR)(a0)
	sb	a1, 0(a0)
	lui	a0, %hi(VECTOR_DRAW_XC)
	lw	a0, %lo(VECTOR_DRAW_XC)(a0)
	sh	a2, 0(a0)
	lui	a0, %hi(VECTOR_DRAW_YC)
	lw	a0, %lo(VECTOR_DRAW_YC)(a0)
	sh	a3, 0(a0)
	lui	a0, %hi(VECTOR_DRAW_START)
	lw	a0, %lo(VECTOR_DRAW_START)(a0)
	addi	a1, zero, 1
	sb	a1, 0(a0)
	ret
.Lfunc_end44:
	.size	draw_vector_block, .Lfunc_end44-draw_vector_block
                                        # -- End function
	.section	.text.set_vector_vertex,"ax",@progbits
	.globl	set_vector_vertex               # -- Begin function set_vector_vertex
	.p2align	1
	.type	set_vector_vertex,@function
set_vector_vertex:                      # @set_vector_vertex
# %bb.0:
	lui	a5, %hi(VECTOR_WRITER_BLOCK)
	lw	a5, %lo(VECTOR_WRITER_BLOCK)(a5)
	sb	a0, 0(a5)
	lui	a0, %hi(VECTOR_WRITER_VERTEX)
	lw	a0, %lo(VECTOR_WRITER_VERTEX)(a0)
	sb	a1, 0(a0)
	lui	a0, %hi(VECTOR_WRITER_ACTIVE)
	lw	a0, %lo(VECTOR_WRITER_ACTIVE)(a0)
	sb	a2, 0(a0)
	lui	a0, %hi(VECTOR_WRITER_DELTAX)
	lw	a0, %lo(VECTOR_WRITER_DELTAX)(a0)
	sb	a3, 0(a0)
	lui	a0, %hi(VECTOR_WRITER_DELTAY)
	lw	a0, %lo(VECTOR_WRITER_DELTAY)(a0)
	sb	a4, 0(a0)
	ret
.Lfunc_end45:
	.size	set_vector_vertex, .Lfunc_end45-set_vector_vertex
                                        # -- End function
	.section	.text.set_sprite_bitmaps,"ax",@progbits
	.globl	set_sprite_bitmaps              # -- Begin function set_sprite_bitmaps
	.p2align	1
	.type	set_sprite_bitmaps,@function
set_sprite_bitmaps:                     # @set_sprite_bitmaps
# %bb.0:
	beqz	a0, .LBB46_3
# %bb.1:
	addi	a3, zero, 1
	bne	a0, a3, .LBB46_5
# %bb.2:
	lui	a3, %hi(UPPER_SPRITE_WRITER_NUMBER)
	addi	a3, a3, %lo(UPPER_SPRITE_WRITER_NUMBER)
	j	.LBB46_4
.LBB46_3:
	lui	a3, %hi(LOWER_SPRITE_WRITER_NUMBER)
	addi	a3, a3, %lo(LOWER_SPRITE_WRITER_NUMBER)
.LBB46_4:
	lw	a3, 0(a3)
	sb	a1, 0(a3)
.LBB46_5:
	mv	a1, zero
	lui	a3, %hi(LOWER_SPRITE_WRITER_BITMAP)
	addi	t2, a3, %lo(LOWER_SPRITE_WRITER_BITMAP)
	lui	a3, %hi(LOWER_SPRITE_WRITER_LINE)
	addi	a5, a3, %lo(LOWER_SPRITE_WRITER_LINE)
	addi	t1, zero, 128
	addi	a6, zero, 1
	lui	a3, %hi(UPPER_SPRITE_WRITER_BITMAP)
	addi	a7, a3, %lo(UPPER_SPRITE_WRITER_BITMAP)
	lui	a3, %hi(UPPER_SPRITE_WRITER_LINE)
	addi	t0, a3, %lo(UPPER_SPRITE_WRITER_LINE)
	j	.LBB46_9
.LBB46_6:                               #   in Loop: Header=BB46_9 Depth=1
	add	a4, zero, t0
	add	a3, zero, a7
.LBB46_7:                               #   in Loop: Header=BB46_9 Depth=1
	lw	a4, 0(a4)
	sb	a1, 0(a4)
	lh	a4, 0(a2)
	lw	a3, 0(a3)
	sh	a4, 0(a3)
.LBB46_8:                               #   in Loop: Header=BB46_9 Depth=1
	addi	a1, a1, 1
	addi	a2, a2, 2
	beq	a1, t1, .LBB46_11
.LBB46_9:                               # =>This Inner Loop Header: Depth=1
	add	a4, zero, a5
	add	a3, zero, t2
	beqz	a0, .LBB46_7
# %bb.10:                               #   in Loop: Header=BB46_9 Depth=1
	beq	a0, a6, .LBB46_6
	j	.LBB46_8
.LBB46_11:
	ret
.Lfunc_end46:
	.size	set_sprite_bitmaps, .Lfunc_end46-set_sprite_bitmaps
                                        # -- End function
	.section	.text.set_sprite,"ax",@progbits
	.globl	set_sprite                      # -- Begin function set_sprite
	.p2align	1
	.type	set_sprite,@function
set_sprite:                             # @set_sprite
# %bb.0:
	beqz	a0, .LBB47_3
# %bb.1:
	addi	t0, zero, 1
	bne	a0, t0, .LBB47_5
# %bb.2:
	lui	a0, %hi(UPPER_SPRITE_DOUBLE)
	addi	t0, a0, %lo(UPPER_SPRITE_DOUBLE)
	lui	a0, %hi(UPPER_SPRITE_Y)
	addi	t1, a0, %lo(UPPER_SPRITE_Y)
	lui	a0, %hi(UPPER_SPRITE_X)
	addi	t2, a0, %lo(UPPER_SPRITE_X)
	lui	a0, %hi(UPPER_SPRITE_COLOUR)
	addi	t3, a0, %lo(UPPER_SPRITE_COLOUR)
	lui	a0, %hi(UPPER_SPRITE_TILE)
	addi	t4, a0, %lo(UPPER_SPRITE_TILE)
	lui	a0, %hi(UPPER_SPRITE_ACTIVE)
	addi	t5, a0, %lo(UPPER_SPRITE_ACTIVE)
	lui	a0, %hi(UPPER_SPRITE_NUMBER)
	addi	a0, a0, %lo(UPPER_SPRITE_NUMBER)
	j	.LBB47_4
.LBB47_3:
	lui	a0, %hi(LOWER_SPRITE_DOUBLE)
	addi	t0, a0, %lo(LOWER_SPRITE_DOUBLE)
	lui	a0, %hi(LOWER_SPRITE_Y)
	addi	t1, a0, %lo(LOWER_SPRITE_Y)
	lui	a0, %hi(LOWER_SPRITE_X)
	addi	t2, a0, %lo(LOWER_SPRITE_X)
	lui	a0, %hi(LOWER_SPRITE_COLOUR)
	addi	t3, a0, %lo(LOWER_SPRITE_COLOUR)
	lui	a0, %hi(LOWER_SPRITE_TILE)
	addi	t4, a0, %lo(LOWER_SPRITE_TILE)
	lui	a0, %hi(LOWER_SPRITE_ACTIVE)
	addi	t5, a0, %lo(LOWER_SPRITE_ACTIVE)
	lui	a0, %hi(LOWER_SPRITE_NUMBER)
	addi	a0, a0, %lo(LOWER_SPRITE_NUMBER)
.LBB47_4:
	lw	a0, 0(a0)
	sb	a1, 0(a0)
	lw	a0, 0(t5)
	sb	a2, 0(a0)
	lw	a0, 0(t4)
	sb	a6, 0(a0)
	lw	a0, 0(t3)
	sb	a3, 0(a0)
	lw	a0, 0(t2)
	sh	a4, 0(a0)
	lw	a0, 0(t1)
	sh	a5, 0(a0)
	lw	a0, 0(t0)
	sb	a7, 0(a0)
.LBB47_5:
	ret
.Lfunc_end47:
	.size	set_sprite, .Lfunc_end47-set_sprite
                                        # -- End function
	.section	.text.set_sprite_attribute,"ax",@progbits
	.globl	set_sprite_attribute            # -- Begin function set_sprite_attribute
	.p2align	1
	.type	set_sprite_attribute,@function
set_sprite_attribute:                   # @set_sprite_attribute
# %bb.0:
	beqz	a0, .LBB48_6
# %bb.1:
	lui	a0, %hi(UPPER_SPRITE_NUMBER)
	lw	a0, %lo(UPPER_SPRITE_NUMBER)(a0)
	addi	a4, zero, 2
	sb	a1, 0(a0)
	blt	a4, a2, .LBB48_11
# %bb.2:
	beqz	a2, .LBB48_19
# %bb.3:
	addi	a0, zero, 1
	beq	a2, a0, .LBB48_20
# %bb.4:
	addi	a0, zero, 2
	bne	a2, a0, .LBB48_28
# %bb.5:
	lui	a0, %hi(UPPER_SPRITE_COLOUR)
	lw	a0, %lo(UPPER_SPRITE_COLOUR)(a0)
	sb	a3, 0(a0)
	ret
.LBB48_6:
	lui	a0, %hi(LOWER_SPRITE_NUMBER)
	lw	a0, %lo(LOWER_SPRITE_NUMBER)(a0)
	addi	a4, zero, 2
	sb	a1, 0(a0)
	blt	a4, a2, .LBB48_15
# %bb.7:
	beqz	a2, .LBB48_23
# %bb.8:
	addi	a0, zero, 1
	beq	a2, a0, .LBB48_25
# %bb.9:
	addi	a0, zero, 2
	bne	a2, a0, .LBB48_28
# %bb.10:
	lui	a0, %hi(LOWER_SPRITE_COLOUR)
	lw	a0, %lo(LOWER_SPRITE_COLOUR)(a0)
	sb	a3, 0(a0)
	ret
.LBB48_11:
	addi	a0, zero, 3
	beq	a2, a0, .LBB48_21
# %bb.12:
	addi	a0, zero, 4
	beq	a2, a0, .LBB48_22
# %bb.13:
	addi	a0, zero, 5
	bne	a2, a0, .LBB48_28
# %bb.14:
	lui	a0, %hi(UPPER_SPRITE_DOUBLE)
	lw	a0, %lo(UPPER_SPRITE_DOUBLE)(a0)
	sb	a3, 0(a0)
	ret
.LBB48_15:
	addi	a0, zero, 3
	beq	a2, a0, .LBB48_24
# %bb.16:
	addi	a0, zero, 4
	beq	a2, a0, .LBB48_26
# %bb.17:
	addi	a0, zero, 5
	bne	a2, a0, .LBB48_28
# %bb.18:
	lui	a0, %hi(LOWER_SPRITE_DOUBLE)
	lw	a0, %lo(LOWER_SPRITE_DOUBLE)(a0)
	sb	a3, 0(a0)
	ret
.LBB48_19:
	lui	a0, %hi(UPPER_SPRITE_ACTIVE)
	lw	a0, %lo(UPPER_SPRITE_ACTIVE)(a0)
	sb	a3, 0(a0)
	ret
.LBB48_20:
	lui	a0, %hi(UPPER_SPRITE_TILE)
	lw	a0, %lo(UPPER_SPRITE_TILE)(a0)
	sb	a3, 0(a0)
	ret
.LBB48_21:
	lui	a0, %hi(UPPER_SPRITE_X)
	lw	a0, %lo(UPPER_SPRITE_X)(a0)
	j	.LBB48_27
.LBB48_22:
	lui	a0, %hi(UPPER_SPRITE_Y)
	lw	a0, %lo(UPPER_SPRITE_Y)(a0)
	j	.LBB48_27
.LBB48_23:
	lui	a0, %hi(LOWER_SPRITE_ACTIVE)
	lw	a0, %lo(LOWER_SPRITE_ACTIVE)(a0)
	sb	a3, 0(a0)
	ret
.LBB48_24:
	lui	a0, %hi(LOWER_SPRITE_X)
	lw	a0, %lo(LOWER_SPRITE_X)(a0)
	j	.LBB48_27
.LBB48_25:
	lui	a0, %hi(LOWER_SPRITE_TILE)
	lw	a0, %lo(LOWER_SPRITE_TILE)(a0)
	sb	a3, 0(a0)
	ret
.LBB48_26:
	lui	a0, %hi(LOWER_SPRITE_Y)
	lw	a0, %lo(LOWER_SPRITE_Y)(a0)
.LBB48_27:
	sh	a3, 0(a0)
.LBB48_28:
	ret
.Lfunc_end48:
	.size	set_sprite_attribute, .Lfunc_end48-set_sprite_attribute
                                        # -- End function
	.section	.text.get_sprite_attribute,"ax",@progbits
	.globl	get_sprite_attribute            # -- Begin function get_sprite_attribute
	.p2align	1
	.type	get_sprite_attribute,@function
get_sprite_attribute:                   # @get_sprite_attribute
# %bb.0:
	beqz	a0, .LBB49_6
# %bb.1:
	lui	a0, %hi(UPPER_SPRITE_NUMBER)
	lw	a3, %lo(UPPER_SPRITE_NUMBER)(a0)
	mv	a0, zero
	addi	a4, zero, 2
	sb	a1, 0(a3)
	blt	a4, a2, .LBB49_11
# %bb.2:
	beqz	a2, .LBB49_19
# %bb.3:
	addi	a1, zero, 1
	beq	a2, a1, .LBB49_20
# %bb.4:
	addi	a1, zero, 2
	bne	a2, a1, .LBB49_28
# %bb.5:
	lui	a0, %hi(UPPER_SPRITE_COLOUR)
	lw	a0, %lo(UPPER_SPRITE_COLOUR)(a0)
	lbu	a0, 0(a0)
	j	.LBB49_28
.LBB49_6:
	lui	a0, %hi(LOWER_SPRITE_NUMBER)
	lw	a3, %lo(LOWER_SPRITE_NUMBER)(a0)
	mv	a0, zero
	addi	a4, zero, 2
	sb	a1, 0(a3)
	blt	a4, a2, .LBB49_15
# %bb.7:
	beqz	a2, .LBB49_23
# %bb.8:
	addi	a1, zero, 1
	beq	a2, a1, .LBB49_25
# %bb.9:
	addi	a1, zero, 2
	bne	a2, a1, .LBB49_28
# %bb.10:
	lui	a0, %hi(LOWER_SPRITE_COLOUR)
	lw	a0, %lo(LOWER_SPRITE_COLOUR)(a0)
	lbu	a0, 0(a0)
	j	.LBB49_28
.LBB49_11:
	addi	a1, zero, 3
	beq	a2, a1, .LBB49_21
# %bb.12:
	addi	a1, zero, 4
	beq	a2, a1, .LBB49_22
# %bb.13:
	addi	a1, zero, 5
	bne	a2, a1, .LBB49_28
# %bb.14:
	lui	a0, %hi(UPPER_SPRITE_DOUBLE)
	lw	a0, %lo(UPPER_SPRITE_DOUBLE)(a0)
	lbu	a0, 0(a0)
	j	.LBB49_28
.LBB49_15:
	addi	a1, zero, 3
	beq	a2, a1, .LBB49_24
# %bb.16:
	addi	a1, zero, 4
	beq	a2, a1, .LBB49_26
# %bb.17:
	addi	a1, zero, 5
	bne	a2, a1, .LBB49_28
# %bb.18:
	lui	a0, %hi(LOWER_SPRITE_DOUBLE)
	lw	a0, %lo(LOWER_SPRITE_DOUBLE)(a0)
	lbu	a0, 0(a0)
	j	.LBB49_28
.LBB49_19:
	lui	a0, %hi(UPPER_SPRITE_ACTIVE)
	lw	a0, %lo(UPPER_SPRITE_ACTIVE)(a0)
	lbu	a0, 0(a0)
	j	.LBB49_28
.LBB49_20:
	lui	a0, %hi(UPPER_SPRITE_TILE)
	lw	a0, %lo(UPPER_SPRITE_TILE)(a0)
	lbu	a0, 0(a0)
	j	.LBB49_28
.LBB49_21:
	lui	a0, %hi(UPPER_SPRITE_X)
	lw	a0, %lo(UPPER_SPRITE_X)(a0)
	j	.LBB49_27
.LBB49_22:
	lui	a0, %hi(UPPER_SPRITE_Y)
	lw	a0, %lo(UPPER_SPRITE_Y)(a0)
	j	.LBB49_27
.LBB49_23:
	lui	a0, %hi(LOWER_SPRITE_ACTIVE)
	lw	a0, %lo(LOWER_SPRITE_ACTIVE)(a0)
	lbu	a0, 0(a0)
	j	.LBB49_28
.LBB49_24:
	lui	a0, %hi(LOWER_SPRITE_X)
	lw	a0, %lo(LOWER_SPRITE_X)(a0)
	j	.LBB49_27
.LBB49_25:
	lui	a0, %hi(LOWER_SPRITE_TILE)
	lw	a0, %lo(LOWER_SPRITE_TILE)(a0)
	lbu	a0, 0(a0)
	j	.LBB49_28
.LBB49_26:
	lui	a0, %hi(LOWER_SPRITE_Y)
	lw	a0, %lo(LOWER_SPRITE_Y)(a0)
.LBB49_27:
	lhu	a0, 0(a0)
.LBB49_28:
	slli	a0, a0, 16
	srai	a0, a0, 16
	ret
.Lfunc_end49:
	.size	get_sprite_attribute, .Lfunc_end49-get_sprite_attribute
                                        # -- End function
	.section	.text.get_sprite_collision,"ax",@progbits
	.globl	get_sprite_collision            # -- Begin function get_sprite_collision
	.p2align	1
	.type	get_sprite_collision,@function
get_sprite_collision:                   # @get_sprite_collision
# %bb.0:
	beqz	a0, .LBB50_2
# %bb.1:
	lui	a0, %hi(UPPER_SPRITE_COLLISION_BASE)
	addi	a0, a0, %lo(UPPER_SPRITE_COLLISION_BASE)
	j	.LBB50_3
.LBB50_2:
	lui	a0, %hi(LOWER_SPRITE_COLLISION_BASE)
	addi	a0, a0, %lo(LOWER_SPRITE_COLLISION_BASE)
.LBB50_3:
	lw	a0, 0(a0)
	slli	a1, a1, 1
	add	a0, a0, a1
	lhu	a0, 0(a0)
	ret
.Lfunc_end50:
	.size	get_sprite_collision, .Lfunc_end50-get_sprite_collision
                                        # -- End function
	.section	.text.update_sprite,"ax",@progbits
	.globl	update_sprite                   # -- Begin function update_sprite
	.p2align	1
	.type	update_sprite,@function
update_sprite:                          # @update_sprite
# %bb.0:
	beqz	a0, .LBB51_3
# %bb.1:
	addi	a3, zero, 1
	bne	a0, a3, .LBB51_5
# %bb.2:
	lui	a0, %hi(UPPER_SPRITE_UPDATE)
	addi	a0, a0, %lo(UPPER_SPRITE_UPDATE)
	lui	a3, %hi(UPPER_SPRITE_NUMBER)
	addi	a3, a3, %lo(UPPER_SPRITE_NUMBER)
	j	.LBB51_4
.LBB51_3:
	lui	a0, %hi(LOWER_SPRITE_UPDATE)
	addi	a0, a0, %lo(LOWER_SPRITE_UPDATE)
	lui	a3, %hi(LOWER_SPRITE_NUMBER)
	addi	a3, a3, %lo(LOWER_SPRITE_NUMBER)
.LBB51_4:
	lw	a3, 0(a3)
	sb	a1, 0(a3)
	lw	a0, 0(a0)
	sh	a2, 0(a0)
.LBB51_5:
	ret
.Lfunc_end51:
	.size	update_sprite, .Lfunc_end51-update_sprite
                                        # -- End function
	.section	.text.set_sprite_SMT,"ax",@progbits
	.globl	set_sprite_SMT                  # -- Begin function set_sprite_SMT
	.p2align	1
	.type	set_sprite_SMT,@function
set_sprite_SMT:                         # @set_sprite_SMT
# %bb.0:
	beqz	a0, .LBB52_3
# %bb.1:
	addi	t0, zero, 1
	bne	a0, t0, .LBB52_5
# %bb.2:
	lui	a0, %hi(UPPER_SPRITE_DOUBLE_SMT)
	addi	t0, a0, %lo(UPPER_SPRITE_DOUBLE_SMT)
	lui	a0, %hi(UPPER_SPRITE_Y_SMT)
	addi	t1, a0, %lo(UPPER_SPRITE_Y_SMT)
	lui	a0, %hi(UPPER_SPRITE_X_SMT)
	addi	t2, a0, %lo(UPPER_SPRITE_X_SMT)
	lui	a0, %hi(UPPER_SPRITE_COLOUR_SMT)
	addi	t3, a0, %lo(UPPER_SPRITE_COLOUR_SMT)
	lui	a0, %hi(UPPER_SPRITE_TILE_SMT)
	addi	t4, a0, %lo(UPPER_SPRITE_TILE_SMT)
	lui	a0, %hi(UPPER_SPRITE_ACTIVE_SMT)
	addi	t5, a0, %lo(UPPER_SPRITE_ACTIVE_SMT)
	lui	a0, %hi(UPPER_SPRITE_NUMBER_SMT)
	addi	a0, a0, %lo(UPPER_SPRITE_NUMBER_SMT)
	j	.LBB52_4
.LBB52_3:
	lui	a0, %hi(LOWER_SPRITE_DOUBLE_SMT)
	addi	t0, a0, %lo(LOWER_SPRITE_DOUBLE_SMT)
	lui	a0, %hi(LOWER_SPRITE_Y_SMT)
	addi	t1, a0, %lo(LOWER_SPRITE_Y_SMT)
	lui	a0, %hi(LOWER_SPRITE_X_SMT)
	addi	t2, a0, %lo(LOWER_SPRITE_X_SMT)
	lui	a0, %hi(LOWER_SPRITE_COLOUR_SMT)
	addi	t3, a0, %lo(LOWER_SPRITE_COLOUR_SMT)
	lui	a0, %hi(LOWER_SPRITE_TILE_SMT)
	addi	t4, a0, %lo(LOWER_SPRITE_TILE_SMT)
	lui	a0, %hi(LOWER_SPRITE_ACTIVE_SMT)
	addi	t5, a0, %lo(LOWER_SPRITE_ACTIVE_SMT)
	lui	a0, %hi(LOWER_SPRITE_NUMBER_SMT)
	addi	a0, a0, %lo(LOWER_SPRITE_NUMBER_SMT)
.LBB52_4:
	lw	a0, 0(a0)
	sb	a1, 0(a0)
	lw	a0, 0(t5)
	sb	a2, 0(a0)
	lw	a0, 0(t4)
	sb	a6, 0(a0)
	lw	a0, 0(t3)
	sb	a3, 0(a0)
	lw	a0, 0(t2)
	sh	a4, 0(a0)
	lw	a0, 0(t1)
	sh	a5, 0(a0)
	lw	a0, 0(t0)
	sb	a7, 0(a0)
.LBB52_5:
	ret
.Lfunc_end52:
	.size	set_sprite_SMT, .Lfunc_end52-set_sprite_SMT
                                        # -- End function
	.section	.text.set_sprite_attribute_SMT,"ax",@progbits
	.globl	set_sprite_attribute_SMT        # -- Begin function set_sprite_attribute_SMT
	.p2align	1
	.type	set_sprite_attribute_SMT,@function
set_sprite_attribute_SMT:               # @set_sprite_attribute_SMT
# %bb.0:
	beqz	a0, .LBB53_6
# %bb.1:
	lui	a0, %hi(UPPER_SPRITE_NUMBER_SMT)
	lw	a0, %lo(UPPER_SPRITE_NUMBER_SMT)(a0)
	addi	a4, zero, 2
	sb	a1, 0(a0)
	blt	a4, a2, .LBB53_11
# %bb.2:
	beqz	a2, .LBB53_19
# %bb.3:
	addi	a0, zero, 1
	beq	a2, a0, .LBB53_20
# %bb.4:
	addi	a0, zero, 2
	bne	a2, a0, .LBB53_28
# %bb.5:
	lui	a0, %hi(UPPER_SPRITE_COLOUR_SMT)
	lw	a0, %lo(UPPER_SPRITE_COLOUR_SMT)(a0)
	sb	a3, 0(a0)
	ret
.LBB53_6:
	lui	a0, %hi(LOWER_SPRITE_NUMBER_SMT)
	lw	a0, %lo(LOWER_SPRITE_NUMBER_SMT)(a0)
	addi	a4, zero, 2
	sb	a1, 0(a0)
	blt	a4, a2, .LBB53_15
# %bb.7:
	beqz	a2, .LBB53_23
# %bb.8:
	addi	a0, zero, 1
	beq	a2, a0, .LBB53_25
# %bb.9:
	addi	a0, zero, 2
	bne	a2, a0, .LBB53_28
# %bb.10:
	lui	a0, %hi(LOWER_SPRITE_COLOUR_SMT)
	lw	a0, %lo(LOWER_SPRITE_COLOUR_SMT)(a0)
	sb	a3, 0(a0)
	ret
.LBB53_11:
	addi	a0, zero, 3
	beq	a2, a0, .LBB53_21
# %bb.12:
	addi	a0, zero, 4
	beq	a2, a0, .LBB53_22
# %bb.13:
	addi	a0, zero, 5
	bne	a2, a0, .LBB53_28
# %bb.14:
	lui	a0, %hi(UPPER_SPRITE_DOUBLE_SMT)
	lw	a0, %lo(UPPER_SPRITE_DOUBLE_SMT)(a0)
	sb	a3, 0(a0)
	ret
.LBB53_15:
	addi	a0, zero, 3
	beq	a2, a0, .LBB53_24
# %bb.16:
	addi	a0, zero, 4
	beq	a2, a0, .LBB53_26
# %bb.17:
	addi	a0, zero, 5
	bne	a2, a0, .LBB53_28
# %bb.18:
	lui	a0, %hi(LOWER_SPRITE_DOUBLE_SMT)
	lw	a0, %lo(LOWER_SPRITE_DOUBLE_SMT)(a0)
	sb	a3, 0(a0)
	ret
.LBB53_19:
	lui	a0, %hi(UPPER_SPRITE_ACTIVE_SMT)
	lw	a0, %lo(UPPER_SPRITE_ACTIVE_SMT)(a0)
	sb	a3, 0(a0)
	ret
.LBB53_20:
	lui	a0, %hi(UPPER_SPRITE_TILE_SMT)
	lw	a0, %lo(UPPER_SPRITE_TILE_SMT)(a0)
	sb	a3, 0(a0)
	ret
.LBB53_21:
	lui	a0, %hi(UPPER_SPRITE_X_SMT)
	lw	a0, %lo(UPPER_SPRITE_X_SMT)(a0)
	j	.LBB53_27
.LBB53_22:
	lui	a0, %hi(UPPER_SPRITE_Y_SMT)
	lw	a0, %lo(UPPER_SPRITE_Y_SMT)(a0)
	j	.LBB53_27
.LBB53_23:
	lui	a0, %hi(LOWER_SPRITE_ACTIVE_SMT)
	lw	a0, %lo(LOWER_SPRITE_ACTIVE_SMT)(a0)
	sb	a3, 0(a0)
	ret
.LBB53_24:
	lui	a0, %hi(LOWER_SPRITE_X_SMT)
	lw	a0, %lo(LOWER_SPRITE_X_SMT)(a0)
	j	.LBB53_27
.LBB53_25:
	lui	a0, %hi(LOWER_SPRITE_TILE_SMT)
	lw	a0, %lo(LOWER_SPRITE_TILE_SMT)(a0)
	sb	a3, 0(a0)
	ret
.LBB53_26:
	lui	a0, %hi(LOWER_SPRITE_Y_SMT)
	lw	a0, %lo(LOWER_SPRITE_Y_SMT)(a0)
.LBB53_27:
	sh	a3, 0(a0)
.LBB53_28:
	ret
.Lfunc_end53:
	.size	set_sprite_attribute_SMT, .Lfunc_end53-set_sprite_attribute_SMT
                                        # -- End function
	.section	.text.get_sprite_attribute_SMT,"ax",@progbits
	.globl	get_sprite_attribute_SMT        # -- Begin function get_sprite_attribute_SMT
	.p2align	1
	.type	get_sprite_attribute_SMT,@function
get_sprite_attribute_SMT:               # @get_sprite_attribute_SMT
# %bb.0:
	beqz	a0, .LBB54_6
# %bb.1:
	lui	a0, %hi(UPPER_SPRITE_NUMBER_SMT)
	lw	a3, %lo(UPPER_SPRITE_NUMBER_SMT)(a0)
	mv	a0, zero
	addi	a4, zero, 2
	sb	a1, 0(a3)
	blt	a4, a2, .LBB54_11
# %bb.2:
	beqz	a2, .LBB54_19
# %bb.3:
	addi	a1, zero, 1
	beq	a2, a1, .LBB54_20
# %bb.4:
	addi	a1, zero, 2
	bne	a2, a1, .LBB54_28
# %bb.5:
	lui	a0, %hi(UPPER_SPRITE_COLOUR_SMT)
	lw	a0, %lo(UPPER_SPRITE_COLOUR_SMT)(a0)
	lbu	a0, 0(a0)
	j	.LBB54_28
.LBB54_6:
	lui	a0, %hi(LOWER_SPRITE_NUMBER_SMT)
	lw	a3, %lo(LOWER_SPRITE_NUMBER_SMT)(a0)
	mv	a0, zero
	addi	a4, zero, 2
	sb	a1, 0(a3)
	blt	a4, a2, .LBB54_15
# %bb.7:
	beqz	a2, .LBB54_23
# %bb.8:
	addi	a1, zero, 1
	beq	a2, a1, .LBB54_25
# %bb.9:
	addi	a1, zero, 2
	bne	a2, a1, .LBB54_28
# %bb.10:
	lui	a0, %hi(LOWER_SPRITE_COLOUR_SMT)
	lw	a0, %lo(LOWER_SPRITE_COLOUR_SMT)(a0)
	lbu	a0, 0(a0)
	j	.LBB54_28
.LBB54_11:
	addi	a1, zero, 3
	beq	a2, a1, .LBB54_21
# %bb.12:
	addi	a1, zero, 4
	beq	a2, a1, .LBB54_22
# %bb.13:
	addi	a1, zero, 5
	bne	a2, a1, .LBB54_28
# %bb.14:
	lui	a0, %hi(UPPER_SPRITE_DOUBLE_SMT)
	lw	a0, %lo(UPPER_SPRITE_DOUBLE_SMT)(a0)
	lbu	a0, 0(a0)
	j	.LBB54_28
.LBB54_15:
	addi	a1, zero, 3
	beq	a2, a1, .LBB54_24
# %bb.16:
	addi	a1, zero, 4
	beq	a2, a1, .LBB54_26
# %bb.17:
	addi	a1, zero, 5
	bne	a2, a1, .LBB54_28
# %bb.18:
	lui	a0, %hi(LOWER_SPRITE_DOUBLE_SMT)
	lw	a0, %lo(LOWER_SPRITE_DOUBLE_SMT)(a0)
	lbu	a0, 0(a0)
	j	.LBB54_28
.LBB54_19:
	lui	a0, %hi(UPPER_SPRITE_ACTIVE_SMT)
	lw	a0, %lo(UPPER_SPRITE_ACTIVE_SMT)(a0)
	lbu	a0, 0(a0)
	j	.LBB54_28
.LBB54_20:
	lui	a0, %hi(UPPER_SPRITE_TILE_SMT)
	lw	a0, %lo(UPPER_SPRITE_TILE_SMT)(a0)
	lbu	a0, 0(a0)
	j	.LBB54_28
.LBB54_21:
	lui	a0, %hi(UPPER_SPRITE_X_SMT)
	lw	a0, %lo(UPPER_SPRITE_X_SMT)(a0)
	j	.LBB54_27
.LBB54_22:
	lui	a0, %hi(UPPER_SPRITE_Y_SMT)
	lw	a0, %lo(UPPER_SPRITE_Y_SMT)(a0)
	j	.LBB54_27
.LBB54_23:
	lui	a0, %hi(LOWER_SPRITE_ACTIVE_SMT)
	lw	a0, %lo(LOWER_SPRITE_ACTIVE_SMT)(a0)
	lbu	a0, 0(a0)
	j	.LBB54_28
.LBB54_24:
	lui	a0, %hi(LOWER_SPRITE_X_SMT)
	lw	a0, %lo(LOWER_SPRITE_X_SMT)(a0)
	j	.LBB54_27
.LBB54_25:
	lui	a0, %hi(LOWER_SPRITE_TILE_SMT)
	lw	a0, %lo(LOWER_SPRITE_TILE_SMT)(a0)
	lbu	a0, 0(a0)
	j	.LBB54_28
.LBB54_26:
	lui	a0, %hi(LOWER_SPRITE_Y_SMT)
	lw	a0, %lo(LOWER_SPRITE_Y_SMT)(a0)
.LBB54_27:
	lhu	a0, 0(a0)
.LBB54_28:
	slli	a0, a0, 16
	srai	a0, a0, 16
	ret
.Lfunc_end54:
	.size	get_sprite_attribute_SMT, .Lfunc_end54-get_sprite_attribute_SMT
                                        # -- End function
	.section	.text.update_sprite_SMT,"ax",@progbits
	.globl	update_sprite_SMT               # -- Begin function update_sprite_SMT
	.p2align	1
	.type	update_sprite_SMT,@function
update_sprite_SMT:                      # @update_sprite_SMT
# %bb.0:
	beqz	a0, .LBB55_3
# %bb.1:
	addi	a3, zero, 1
	bne	a0, a3, .LBB55_5
# %bb.2:
	lui	a0, %hi(UPPER_SPRITE_UPDATE_SMT)
	addi	a0, a0, %lo(UPPER_SPRITE_UPDATE_SMT)
	lui	a3, %hi(UPPER_SPRITE_NUMBER_SMT)
	addi	a3, a3, %lo(UPPER_SPRITE_NUMBER_SMT)
	j	.LBB55_4
.LBB55_3:
	lui	a0, %hi(LOWER_SPRITE_UPDATE_SMT)
	addi	a0, a0, %lo(LOWER_SPRITE_UPDATE_SMT)
	lui	a3, %hi(LOWER_SPRITE_NUMBER_SMT)
	addi	a3, a3, %lo(LOWER_SPRITE_NUMBER_SMT)
.LBB55_4:
	lw	a3, 0(a3)
	sb	a1, 0(a3)
	lw	a0, 0(a0)
	sh	a2, 0(a0)
.LBB55_5:
	ret
.Lfunc_end55:
	.size	update_sprite_SMT, .Lfunc_end55-update_sprite_SMT
                                        # -- End function
	.section	.text.tpu_cs,"ax",@progbits
	.globl	tpu_cs                          # -- Begin function tpu_cs
	.p2align	1
	.type	tpu_cs,@function
tpu_cs:                                 # @tpu_cs
# %bb.0:
	lui	a0, %hi(TPU_COMMIT)
	lw	a0, %lo(TPU_COMMIT)(a0)
.LBB56_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, 0(a0)
	bnez	a1, .LBB56_1
# %bb.2:
	addi	a1, zero, 3
	sb	a1, 0(a0)
	ret
.Lfunc_end56:
	.size	tpu_cs, .Lfunc_end56-tpu_cs
                                        # -- End function
	.section	.text.tpu_clearline,"ax",@progbits
	.globl	tpu_clearline                   # -- Begin function tpu_clearline
	.p2align	1
	.type	tpu_clearline,@function
tpu_clearline:                          # @tpu_clearline
# %bb.0:
	lui	a1, %hi(TPU_COMMIT)
	lw	a1, %lo(TPU_COMMIT)(a1)
.LBB57_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a2, 0(a1)
	bnez	a2, .LBB57_1
# %bb.2:
	lui	a1, %hi(TPU_Y)
	lw	a1, %lo(TPU_Y)(a1)
	sb	a0, 0(a1)
	lui	a0, %hi(TPU_COMMIT)
	lw	a0, %lo(TPU_COMMIT)(a0)
	addi	a1, zero, 4
	sb	a1, 0(a0)
	ret
.Lfunc_end57:
	.size	tpu_clearline, .Lfunc_end57-tpu_clearline
                                        # -- End function
	.section	.text.tpu_set,"ax",@progbits
	.globl	tpu_set                         # -- Begin function tpu_set
	.p2align	1
	.type	tpu_set,@function
tpu_set:                                # @tpu_set
# %bb.0:
	lui	a4, %hi(TPU_COMMIT)
	lw	a4, %lo(TPU_COMMIT)(a4)
.LBB58_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a5, 0(a4)
	bnez	a5, .LBB58_1
# %bb.2:
	lui	a4, %hi(TPU_X)
	lw	a4, %lo(TPU_X)(a4)
	sb	a0, 0(a4)
	lui	a0, %hi(TPU_Y)
	lw	a0, %lo(TPU_Y)(a0)
	sb	a1, 0(a0)
	lui	a0, %hi(TPU_BACKGROUND)
	lw	a0, %lo(TPU_BACKGROUND)(a0)
	sb	a2, 0(a0)
	lui	a0, %hi(TPU_FOREGROUND)
	lw	a0, %lo(TPU_FOREGROUND)(a0)
	sb	a3, 0(a0)
	lui	a0, %hi(TPU_COMMIT)
	lw	a0, %lo(TPU_COMMIT)(a0)
	addi	a1, zero, 1
	sb	a1, 0(a0)
	ret
.Lfunc_end58:
	.size	tpu_set, .Lfunc_end58-tpu_set
                                        # -- End function
	.section	.text.tpu_output_character,"ax",@progbits
	.globl	tpu_output_character            # -- Begin function tpu_output_character
	.p2align	1
	.type	tpu_output_character,@function
tpu_output_character:                   # @tpu_output_character
# %bb.0:
	lui	a1, %hi(TPU_COMMIT)
	lw	a1, %lo(TPU_COMMIT)(a1)
.LBB59_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a2, 0(a1)
	bnez	a2, .LBB59_1
# %bb.2:
	lui	a1, %hi(TPU_CHARACTER)
	lw	a1, %lo(TPU_CHARACTER)(a1)
	sb	a0, 0(a1)
	lui	a0, %hi(TPU_COMMIT)
	lw	a0, %lo(TPU_COMMIT)(a0)
	addi	a1, zero, 2
	sb	a1, 0(a0)
	ret
.Lfunc_end59:
	.size	tpu_output_character, .Lfunc_end59-tpu_output_character
                                        # -- End function
	.section	.text.tpu_outputstring,"ax",@progbits
	.globl	tpu_outputstring                # -- Begin function tpu_outputstring
	.p2align	1
	.type	tpu_outputstring,@function
tpu_outputstring:                       # @tpu_outputstring
# %bb.0:
	lbu	a1, 0(a0)
	beqz	a1, .LBB60_5
# %bb.1:
	lui	a2, %hi(TPU_COMMIT)
	lui	a6, %hi(TPU_CHARACTER)
	addi	a4, zero, 2
.LBB60_2:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB60_3 Depth 2
	lw	a5, %lo(TPU_COMMIT)(a2)
.LBB60_3:                               #   Parent Loop BB60_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lbu	a3, 0(a5)
	bnez	a3, .LBB60_3
# %bb.4:                                #   in Loop: Header=BB60_2 Depth=1
	lw	a3, %lo(TPU_CHARACTER)(a6)
	sb	a1, 0(a3)
	lw	a1, %lo(TPU_COMMIT)(a2)
	sb	a4, 0(a1)
	lbu	a1, 1(a0)
	addi	a0, a0, 1
	bnez	a1, .LBB60_2
.LBB60_5:
	ret
.Lfunc_end60:
	.size	tpu_outputstring, .Lfunc_end60-tpu_outputstring
                                        # -- End function
	.section	.text.tpu_printf,"ax",@progbits
	.globl	tpu_printf                      # -- Begin function tpu_printf
	.p2align	1
	.type	tpu_printf,@function
tpu_printf:                             # @tpu_printf
# %bb.0:
	addi	sp, sp, -48
	sw	ra, 12(sp)
	sw	s0, 8(sp)
	sw	s1, 4(sp)
	add	t0, zero, a0
	sw	a7, 44(sp)
	sw	a6, 40(sp)
	sw	a5, 36(sp)
	sw	a4, 32(sp)
	sw	a3, 28(sp)
	sw	a2, 24(sp)
	sw	a1, 20(sp)
	addi	a3, sp, 20
	sw	a3, 0(sp)
	lui	s1, %hi(tpu_printf.buffer)
	addi	s0, s1, %lo(tpu_printf.buffer)
	addi	a1, zero, 1023
	add	a0, zero, s0
	add	a2, zero, t0
	call	vsnprintf
	lbu	a0, %lo(tpu_printf.buffer)(s1)
	beqz	a0, .LBB61_5
# %bb.1:
	lui	a1, %hi(TPU_COMMIT)
	lui	a2, %hi(TPU_CHARACTER)
	addi	a3, zero, 2
.LBB61_2:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB61_3 Depth 2
	lw	a4, %lo(TPU_COMMIT)(a1)
.LBB61_3:                               #   Parent Loop BB61_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lbu	a5, 0(a4)
	bnez	a5, .LBB61_3
# %bb.4:                                #   in Loop: Header=BB61_2 Depth=1
	lw	a4, %lo(TPU_CHARACTER)(a2)
	sb	a0, 0(a4)
	lw	a0, %lo(TPU_COMMIT)(a1)
	sb	a3, 0(a0)
	lbu	a0, 1(s0)
	addi	s0, s0, 1
	bnez	a0, .LBB61_2
.LBB61_5:
	lw	s1, 4(sp)
	lw	s0, 8(sp)
	lw	ra, 12(sp)
	addi	sp, sp, 48
	ret
.Lfunc_end61:
	.size	tpu_printf, .Lfunc_end61-tpu_printf
                                        # -- End function
	.section	.text.tpu_printf_centre,"ax",@progbits
	.globl	tpu_printf_centre               # -- Begin function tpu_printf_centre
	.p2align	1
	.type	tpu_printf_centre,@function
tpu_printf_centre:                      # @tpu_printf_centre
# %bb.0:
	addi	sp, sp, -48
	sw	ra, 28(sp)
	sw	s0, 24(sp)
	sw	s1, 20(sp)
	sw	s2, 16(sp)
	sw	s3, 12(sp)
	add	s1, zero, a3
	add	s2, zero, a2
	add	s3, zero, a1
	add	s0, zero, a0
	sw	a7, 44(sp)
	sw	a6, 40(sp)
	sw	a5, 36(sp)
	sw	a4, 32(sp)
	addi	a3, sp, 32
	sw	a3, 8(sp)
	lui	a0, %hi(tpu_printf_centre.buffer)
	addi	a0, a0, %lo(tpu_printf_centre.buffer)
	addi	a1, zero, 80
	add	a2, zero, s1
	call	vsnprintf
	lui	a0, %hi(TPU_COMMIT)
	lw	a0, %lo(TPU_COMMIT)(a0)
.LBB62_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, 0(a0)
	bnez	a1, .LBB62_1
# %bb.2:
	lui	a0, %hi(TPU_Y)
	lw	a0, %lo(TPU_Y)(a0)
	sb	s0, 0(a0)
	lui	s1, %hi(TPU_COMMIT)
	lw	a0, %lo(TPU_COMMIT)(s1)
	addi	a1, zero, 4
	sb	a1, 0(a0)
	lui	a0, %hi(tpu_printf_centre.buffer)
	addi	a0, a0, %lo(tpu_printf_centre.buffer)
	call	strlen
	lw	a1, %lo(TPU_COMMIT)(s1)
	srli	a0, a0, 1
.LBB62_3:                               # =>This Inner Loop Header: Depth=1
	lbu	a2, 0(a1)
	bnez	a2, .LBB62_3
# %bb.4:
	lui	a1, %hi(TPU_X)
	lw	a1, %lo(TPU_X)(a1)
	addi	a2, zero, 40
	sub	a0, a2, a0
	sb	a0, 0(a1)
	lui	a0, %hi(TPU_Y)
	lw	a0, %lo(TPU_Y)(a0)
	sb	s0, 0(a0)
	lui	a0, %hi(TPU_BACKGROUND)
	lw	a0, %lo(TPU_BACKGROUND)(a0)
	sb	s3, 0(a0)
	lui	a0, %hi(TPU_FOREGROUND)
	lw	a0, %lo(TPU_FOREGROUND)(a0)
	sb	s2, 0(a0)
	lui	a0, %hi(TPU_COMMIT)
	lw	a1, %lo(TPU_COMMIT)(a0)
	addi	a2, zero, 1
	sb	a2, 0(a1)
	lui	a2, %hi(tpu_printf_centre.buffer)
	lbu	a1, %lo(tpu_printf_centre.buffer)(a2)
	beqz	a1, .LBB62_9
# %bb.5:
	addi	a4, a2, %lo(tpu_printf_centre.buffer)
	lui	a2, %hi(TPU_CHARACTER)
	addi	a3, zero, 2
.LBB62_6:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB62_7 Depth 2
	lw	a5, %lo(TPU_COMMIT)(a0)
.LBB62_7:                               #   Parent Loop BB62_6 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lbu	s1, 0(a5)
	bnez	s1, .LBB62_7
# %bb.8:                                #   in Loop: Header=BB62_6 Depth=1
	lw	a5, %lo(TPU_CHARACTER)(a2)
	sb	a1, 0(a5)
	lw	a1, %lo(TPU_COMMIT)(a0)
	sb	a3, 0(a1)
	lbu	a1, 1(a4)
	addi	a4, a4, 1
	bnez	a1, .LBB62_6
.LBB62_9:
	lw	s3, 12(sp)
	lw	s2, 16(sp)
	lw	s1, 20(sp)
	lw	s0, 24(sp)
	lw	ra, 28(sp)
	addi	sp, sp, 48
	ret
.Lfunc_end62:
	.size	tpu_printf_centre, .Lfunc_end62-tpu_printf_centre
                                        # -- End function
	.section	.text.sdcard_findfilenumber,"ax",@progbits
	.globl	sdcard_findfilenumber           # -- Begin function sdcard_findfilenumber
	.p2align	1
	.type	sdcard_findfilenumber,@function
sdcard_findfilenumber:                  # @sdcard_findfilenumber
# %bb.0:
	addi	sp, sp, -32
	sw	s0, 28(sp)
	sw	s1, 24(sp)
	sw	s2, 20(sp)
	sw	s3, 16(sp)
	sw	s4, 12(sp)
	lui	a2, %hi(BOOTSECTOR)
	lw	a2, %lo(BOOTSECTOR)(a2)
	lbu	a3, 18(a2)
	lbu	a2, 17(a2)
	slli	a3, a3, 8
	or	t2, a3, a2
	lui	a7, 16
	addi	a6, a7, -1
	add	s0, zero, a6
	beqz	t2, .LBB63_24
# %bb.1:
	mv	s3, zero
	lui	a2, %hi(ROOTDIRECTORY)
	lw	t3, %lo(ROOTDIRECTORY)(a2)
	addi	a4, a7, -1
	addi	t0, zero, 45
	addi	t1, zero, 5
	addi	t6, zero, 8
	addi	s2, zero, 3
	addi	t4, zero, 46
	addi	t5, zero, 229
	j	.LBB63_3
.LBB63_2:                               #   in Loop: Header=BB63_3 Depth=1
	addi	s3, s3, 1
	sltu	a2, s3, t2
	and	a3, s0, a4
	xor	a3, a3, a4
	seqz	a3, a3
	and	a2, a2, a3
	beqz	a2, .LBB63_24
.LBB63_3:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB63_10 Depth 2
                                        #     Child Loop BB63_17 Depth 2
	slli	a2, s3, 5
	add	a2, a2, t3
	lbu	s1, 0(a2)
	blt	t0, s1, .LBB63_6
# %bb.4:                                #   in Loop: Header=BB63_3 Depth=1
	add	s0, zero, a4
	beqz	s1, .LBB63_2
# %bb.5:                                #   in Loop: Header=BB63_3 Depth=1
	add	s0, zero, a4
	beq	s1, t1, .LBB63_2
	j	.LBB63_8
.LBB63_6:                               #   in Loop: Header=BB63_3 Depth=1
	add	s0, zero, a4
	beq	s1, t4, .LBB63_2
# %bb.7:                                #   in Loop: Header=BB63_3 Depth=1
	add	s0, zero, a4
	beq	s1, t5, .LBB63_2
.LBB63_8:                               #   in Loop: Header=BB63_3 Depth=1
	mv	s1, zero
	addi	s4, zero, 1
	j	.LBB63_10
.LBB63_9:                               #   in Loop: Header=BB63_10 Depth=2
	addi	s1, s1, 1
.LBB63_10:                              #   Parent Loop BB63_3 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	and	a3, s1, a4
	add	a5, a0, a3
	lbu	s0, 0(a5)
	bgeu	a3, t6, .LBB63_12
# %bb.11:                               #   in Loop: Header=BB63_10 Depth=2
	add	a5, zero, s0
	j	.LBB63_13
.LBB63_12:                              #   in Loop: Header=BB63_10 Depth=2
	mv	a5, zero
	bnez	s0, .LBB63_15
.LBB63_13:                              #   in Loop: Header=BB63_10 Depth=2
	add	a3, a3, a2
	lbu	a3, 0(a3)
	xor	a5, a5, a3
	seqz	a5, a5
	addi	a3, a3, -32
	seqz	a3, a3
	or	a3, a3, a5
	bnez	a3, .LBB63_9
# %bb.14:                               #   in Loop: Header=BB63_10 Depth=2
	mv	s4, zero
	j	.LBB63_9
.LBB63_15:                              #   in Loop: Header=BB63_3 Depth=1
	mv	s1, zero
	j	.LBB63_17
.LBB63_16:                              #   in Loop: Header=BB63_17 Depth=2
	addi	s1, s1, 1
.LBB63_17:                              #   Parent Loop BB63_3 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	and	a3, s1, a4
	add	a5, a1, a3
	lbu	s0, 0(a5)
	bgeu	a3, s2, .LBB63_19
# %bb.18:                               #   in Loop: Header=BB63_17 Depth=2
	add	a5, zero, s0
	j	.LBB63_20
.LBB63_19:                              #   in Loop: Header=BB63_17 Depth=2
	mv	a5, zero
	bnez	s0, .LBB63_22
.LBB63_20:                              #   in Loop: Header=BB63_17 Depth=2
	add	a3, a3, a2
	lbu	a3, 8(a3)
	xor	a5, a5, a3
	seqz	a5, a5
	addi	a3, a3, -32
	seqz	a3, a3
	or	a3, a3, a5
	bnez	a3, .LBB63_16
# %bb.21:                               #   in Loop: Header=BB63_17 Depth=2
	mv	s4, zero
	j	.LBB63_16
.LBB63_22:                              #   in Loop: Header=BB63_3 Depth=1
	addi	a2, a7, -1
	and	a2, s4, a2
	addi	s0, zero, -1
	beqz	a2, .LBB63_2
# %bb.23:                               #   in Loop: Header=BB63_3 Depth=1
	add	s0, zero, s3
	j	.LBB63_2
.LBB63_24:
	and	a0, s0, a6
	lw	s4, 12(sp)
	lw	s3, 16(sp)
	lw	s2, 20(sp)
	lw	s1, 24(sp)
	lw	s0, 28(sp)
	addi	sp, sp, 32
	ret
.Lfunc_end63:
	.size	sdcard_findfilenumber, .Lfunc_end63-sdcard_findfilenumber
                                        # -- End function
	.section	.text.sdcard_findfilesize,"ax",@progbits
	.globl	sdcard_findfilesize             # -- Begin function sdcard_findfilesize
	.p2align	1
	.type	sdcard_findfilesize,@function
sdcard_findfilesize:                    # @sdcard_findfilesize
# %bb.0:
	lui	a1, %hi(ROOTDIRECTORY)
	lw	a1, %lo(ROOTDIRECTORY)(a1)
	slli	a0, a0, 5
	add	a0, a0, a1
	lbu	a1, 29(a0)
	lbu	a2, 28(a0)
	lbu	a3, 31(a0)
	lbu	a0, 30(a0)
	slli	a1, a1, 8
	or	a1, a1, a2
	slli	a2, a3, 8
	or	a0, a0, a2
	slli	a0, a0, 16
	or	a0, a0, a1
	ret
.Lfunc_end64:
	.size	sdcard_findfilesize, .Lfunc_end64-sdcard_findfilesize
                                        # -- End function
	.section	.text.sdcard_readcluster,"ax",@progbits
	.globl	sdcard_readcluster              # -- Begin function sdcard_readcluster
	.p2align	1
	.type	sdcard_readcluster,@function
sdcard_readcluster:                     # @sdcard_readcluster
# %bb.0:
	addi	sp, sp, -32
	sw	s0, 28(sp)
	sw	s1, 24(sp)
	sw	s2, 20(sp)
	sw	s3, 16(sp)
	sw	s4, 12(sp)
	sw	s5, 8(sp)
	lui	a6, %hi(BOOTSECTOR)
	lw	a1, %lo(BOOTSECTOR)(a6)
	lbu	a1, 13(a1)
	beqz	a1, .LBB65_9
# %bb.1:
	mv	a3, zero
	mv	a2, zero
	addi	t5, a0, -2
	lui	a0, 16
	addi	s2, a0, -1
	lui	a7, %hi(DATASTARTSECTOR)
	lui	t0, %hi(CLUSTERBUFFER)
	lui	t6, %hi(SDCARD_READY)
	lui	t1, %hi(SDCARD_SECTOR_HIGH)
	lui	t2, %hi(SDCARD_SECTOR_LOW)
	lui	t3, %hi(SDCARD_START)
	addi	t4, zero, 1
	lui	a4, %hi(SDCARD_ADDRESS)
	lui	a5, %hi(SDCARD_DATA)
	addi	a0, zero, 512
.LBB65_2:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB65_3 Depth 2
                                        #     Child Loop BB65_5 Depth 2
                                        #     Child Loop BB65_7 Depth 2
	and	s0, a2, s2
	lw	s5, %lo(DATASTARTSECTOR)(a7)
	lw	s3, %lo(CLUSTERBUFFER)(t0)
	lw	s1, %lo(SDCARD_READY)(t6)
	slli	s4, s0, 9
	mul	a1, a1, t5
	add	a1, a1, a3
.LBB65_3:                               #   Parent Loop BB65_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lbu	a3, 0(s1)
	beqz	a3, .LBB65_3
# %bb.4:                                #   in Loop: Header=BB65_2 Depth=1
	lw	a3, %lo(SDCARD_SECTOR_HIGH)(t1)
	add	a1, a1, s5
	srli	s0, a1, 16
	sh	s0, 0(a3)
	lw	a3, %lo(SDCARD_SECTOR_LOW)(t2)
	sh	a1, 0(a3)
	lw	a1, %lo(SDCARD_START)(t3)
	sb	t4, 0(a1)
	lw	a1, %lo(SDCARD_READY)(t6)
.LBB65_5:                               #   Parent Loop BB65_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lbu	a3, 0(a1)
	beqz	a3, .LBB65_5
# %bb.6:                                #   in Loop: Header=BB65_2 Depth=1
	mv	a1, zero
	add	a3, s3, s4
.LBB65_7:                               #   Parent Loop BB65_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lw	s0, %lo(SDCARD_ADDRESS)(a4)
	sh	a1, 0(s0)
	lw	s0, %lo(SDCARD_DATA)(a5)
	lb	s0, 0(s0)
	add	s1, a3, a1
	addi	a1, a1, 1
	sb	s0, 0(s1)
	bne	a1, a0, .LBB65_7
# %bb.8:                                #   in Loop: Header=BB65_2 Depth=1
	lw	a1, %lo(BOOTSECTOR)(a6)
	lbu	a1, 13(a1)
	addi	a2, a2, 1
	and	a3, a2, s2
	bltu	a3, a1, .LBB65_2
.LBB65_9:
	lw	s5, 8(sp)
	lw	s4, 12(sp)
	lw	s3, 16(sp)
	lw	s2, 20(sp)
	lw	s1, 24(sp)
	lw	s0, 28(sp)
	addi	sp, sp, 32
	ret
.Lfunc_end65:
	.size	sdcard_readcluster, .Lfunc_end65-sdcard_readcluster
                                        # -- End function
	.section	.text.sdcard_readfile,"ax",@progbits
	.globl	sdcard_readfile                 # -- Begin function sdcard_readfile
	.p2align	1
	.type	sdcard_readfile,@function
sdcard_readfile:                        # @sdcard_readfile
# %bb.0:
	addi	sp, sp, -48
	sw	s0, 44(sp)
	sw	s1, 40(sp)
	sw	s2, 36(sp)
	sw	s3, 32(sp)
	sw	s4, 28(sp)
	sw	s5, 24(sp)
	sw	s6, 20(sp)
	sw	s7, 16(sp)
	sw	s8, 12(sp)
	sw	s9, 8(sp)
	lui	a2, %hi(ROOTDIRECTORY)
	lw	a2, %lo(ROOTDIRECTORY)(a2)
	slli	a0, a0, 5
	add	a0, a0, a2
	lbu	a2, 27(a0)
	lbu	a0, 26(a0)
	slli	a2, a2, 8
	or	s1, a2, a0
	lui	t4, %hi(BOOTSECTOR)
	lw	s0, %lo(BOOTSECTOR)(t4)
	lui	a6, %hi(FAT)
	lui	a0, 16
	addi	s4, a0, -1
	lui	t5, %hi(CLUSTERBUFFER)
	lui	a7, %hi(DATASTARTSECTOR)
	lui	s2, %hi(SDCARD_READY)
	lui	t0, %hi(SDCARD_SECTOR_HIGH)
	lui	t1, %hi(SDCARD_SECTOR_LOW)
	lui	t2, %hi(SDCARD_START)
	addi	t3, zero, 1
	lui	a5, %hi(SDCARD_ADDRESS)
	lui	a0, %hi(SDCARD_DATA)
	addi	a4, zero, 512
	j	.LBB66_2
.LBB66_1:                               #   in Loop: Header=BB66_2 Depth=1
	lw	a2, %lo(FAT)(a6)
	slli	a3, t6, 1
	add	a2, a2, a3
	lhu	s1, 0(a2)
	beq	s1, s4, .LBB66_16
.LBB66_2:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB66_4 Depth 2
                                        #       Child Loop BB66_5 Depth 3
                                        #       Child Loop BB66_7 Depth 3
                                        #       Child Loop BB66_9 Depth 3
                                        #     Child Loop BB66_14 Depth 2
	lbu	s8, 13(s0)
	and	t6, s1, s4
	beqz	s8, .LBB66_12
# %bb.3:                                #   in Loop: Header=BB66_2 Depth=1
	mv	a3, zero
	mv	s9, zero
	addi	s3, t6, -2
.LBB66_4:                               #   Parent Loop BB66_2 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB66_5 Depth 3
                                        #       Child Loop BB66_7 Depth 3
                                        #       Child Loop BB66_9 Depth 3
	lw	s7, %lo(DATASTARTSECTOR)(a7)
	lw	s5, %lo(CLUSTERBUFFER)(t5)
	lw	s0, %lo(SDCARD_READY)(s2)
	and	a2, s9, s4
	slli	s6, a2, 9
	mul	s8, s8, s3
.LBB66_5:                               #   Parent Loop BB66_2 Depth=1
                                        #     Parent Loop BB66_4 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	lbu	a2, 0(s0)
	beqz	a2, .LBB66_5
# %bb.6:                                #   in Loop: Header=BB66_4 Depth=2
	lw	a2, %lo(SDCARD_SECTOR_HIGH)(t0)
	add	a3, a3, s8
	add	a3, a3, s7
	srli	s0, a3, 16
	sh	s0, 0(a2)
	lw	a2, %lo(SDCARD_SECTOR_LOW)(t1)
	sh	a3, 0(a2)
	lw	a2, %lo(SDCARD_START)(t2)
	sb	t3, 0(a2)
	lw	a2, %lo(SDCARD_READY)(s2)
.LBB66_7:                               #   Parent Loop BB66_2 Depth=1
                                        #     Parent Loop BB66_4 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	lbu	a3, 0(a2)
	beqz	a3, .LBB66_7
# %bb.8:                                #   in Loop: Header=BB66_4 Depth=2
	mv	a2, zero
	add	a3, s5, s6
.LBB66_9:                               #   Parent Loop BB66_2 Depth=1
                                        #     Parent Loop BB66_4 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	lw	s0, %lo(SDCARD_ADDRESS)(a5)
	sh	a2, 0(s0)
	lw	s0, %lo(SDCARD_DATA)(a0)
	lb	s0, 0(s0)
	add	s1, a3, a2
	addi	a2, a2, 1
	sb	s0, 0(s1)
	bne	a2, a4, .LBB66_9
# %bb.10:                               #   in Loop: Header=BB66_4 Depth=2
	lw	s0, %lo(BOOTSECTOR)(t4)
	lbu	s8, 13(s0)
	addi	s9, s9, 1
	and	a3, s9, s4
	bltu	a3, s8, .LBB66_4
# %bb.11:                               #   in Loop: Header=BB66_2 Depth=1
	bnez	s8, .LBB66_13
	j	.LBB66_1
.LBB66_12:                              #   in Loop: Header=BB66_2 Depth=1
	lbu	s8, 13(s0)
	beqz	s8, .LBB66_1
.LBB66_13:                              #   in Loop: Header=BB66_2 Depth=1
	mv	a2, zero
.LBB66_14:                              #   Parent Loop BB66_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lw	a3, %lo(CLUSTERBUFFER)(t5)
	add	a3, a3, a2
	lb	a3, 0(a3)
	add	s0, a1, a2
	sb	a3, 0(s0)
	lw	s0, %lo(BOOTSECTOR)(t4)
	lbu	a3, 13(s0)
	addi	a2, a2, 1
	slli	a3, a3, 9
	bltu	a2, a3, .LBB66_14
# %bb.15:                               #   in Loop: Header=BB66_2 Depth=1
	add	a1, a1, a2
	j	.LBB66_1
.LBB66_16:
	lw	s9, 8(sp)
	lw	s8, 12(sp)
	lw	s7, 16(sp)
	lw	s6, 20(sp)
	lw	s5, 24(sp)
	lw	s4, 28(sp)
	lw	s3, 32(sp)
	lw	s2, 36(sp)
	lw	s1, 40(sp)
	lw	s0, 44(sp)
	addi	sp, sp, 48
	ret
.Lfunc_end66:
	.size	sdcard_readfile, .Lfunc_end66-sdcard_readfile
                                        # -- End function
	.section	.text.skipcomment,"ax",@progbits
	.globl	skipcomment                     # -- Begin function skipcomment
	.p2align	1
	.type	skipcomment,@function
skipcomment:                            # @skipcomment
# %bb.0:
	addi	a2, zero, 10
.LBB67_1:                               # =>This Inner Loop Header: Depth=1
	add	a3, a0, a1
	lbu	a3, 0(a3)
	addi	a1, a1, 1
	bne	a3, a2, .LBB67_1
# %bb.2:
	add	a0, zero, a1
	ret
.Lfunc_end67:
	.size	skipcomment, .Lfunc_end67-skipcomment
                                        # -- End function
	.section	.text.netppm_display,"ax",@progbits
	.globl	netppm_display                  # -- Begin function netppm_display
	.p2align	1
	.type	netppm_display,@function
netppm_display:                         # @netppm_display
# %bb.0:
	addi	sp, sp, -16
	sw	s0, 12(sp)
	sw	s1, 8(sp)
	sw	s2, 4(sp)
	lbu	a2, 0(a0)
	addi	a3, zero, 80
	bne	a2, a3, .LBB68_18
# %bb.1:
	lbu	a2, 1(a0)
	addi	a3, zero, 54
	bne	a2, a3, .LBB68_18
# %bb.2:
	lbu	a2, 2(a0)
	addi	a3, zero, 10
	bne	a2, a3, .LBB68_18
# %bb.3:
	lbu	a2, 3(a0)
	addi	a3, zero, 35
	addi	a5, zero, 3
	bne	a2, a3, .LBB68_8
# %bb.4:
	addi	a5, zero, 4
	addi	a4, zero, 10
	j	.LBB68_6
.LBB68_5:                               #   in Loop: Header=BB68_6 Depth=1
	addi	a5, a5, 1
.LBB68_6:                               # =>This Inner Loop Header: Depth=1
	add	a2, a0, a5
	lbu	s1, -1(a2)
	bne	s1, a4, .LBB68_5
# %bb.7:                                #   in Loop: Header=BB68_6 Depth=1
	lbu	a2, 0(a2)
	beq	a2, a3, .LBB68_5
.LBB68_8:
	lui	a3, 16
	addi	a6, zero, 32
	addi	t1, a3, -48
	mv	t6, zero
	beq	a2, a6, .LBB68_11
# %bb.9:
	addi	t0, a0, 1
	addi	a7, zero, 10
	addi	a3, t1, 47
	add	a4, zero, a5
.LBB68_10:                              # =>This Inner Loop Header: Depth=1
	andi	a5, a2, 255
	mul	s1, t6, a7
	add	a2, t0, a4
	lbu	a2, 0(a2)
	add	s1, s1, t1
	add	s1, s1, a5
	addi	a5, a4, 1
	and	t6, s1, a3
	add	a4, zero, a5
	bne	a2, a6, .LBB68_10
.LBB68_11:
	add	a2, a5, a0
	lbu	a3, 1(a2)
	mv	a7, zero
	addi	a6, zero, 10
	beq	a3, a6, .LBB68_14
# %bb.12:
	addi	t0, a0, 2
	addi	a2, t1, 47
.LBB68_13:                              # =>This Inner Loop Header: Depth=1
	andi	a4, a3, 255
	mul	s1, a7, a6
	add	a3, t0, a5
	lbu	a3, 0(a3)
	add	s1, s1, t1
	add	a4, a4, s1
	and	a7, a4, a2
	addi	a5, a5, 1
	bne	a3, a6, .LBB68_13
.LBB68_14:
	add	a2, a5, a0
	lbu	a3, 2(a2)
	beq	a3, a6, .LBB68_18
# %bb.15:
	mv	a2, zero
	addi	a5, a5, 3
	addi	a6, zero, 10
	addi	a4, t1, 47
.LBB68_16:                              # =>This Inner Loop Header: Depth=1
	andi	s1, a3, 255
	mul	a2, a2, a6
	add	a3, a0, a5
	lbu	a3, 0(a3)
	add	a2, a2, t1
	add	a2, a2, s1
	and	a2, a2, a4
	addi	a5, a5, 1
	bne	a3, a6, .LBB68_16
# %bb.17:
	addi	a2, a2, -255
	snez	a2, a2
	seqz	a3, a7
	or	a2, a2, a3
	beqz	a2, .LBB68_19
.LBB68_18:
	lw	s2, 4(sp)
	lw	s1, 8(sp)
	lw	s0, 12(sp)
	addi	sp, sp, 16
	ret
.LBB68_19:
	mv	s2, zero
	seqz	a6, t6
	lui	a2, 16
	addi	a3, a2, -1
	lui	t0, %hi(GPU_STATUS)
	lui	t1, %hi(GPU_COLOUR)
	lui	t2, %hi(GPU_X)
	lui	t3, %hi(GPU_Y)
	lui	t4, %hi(GPU_WRITE)
	addi	t5, zero, 1
	j	.LBB68_21
.LBB68_20:                              #   in Loop: Header=BB68_21 Depth=1
	addi	s2, s2, 1
	and	a2, s2, a3
	bgeu	a2, a7, .LBB68_18
.LBB68_21:                              # =>This Loop Header: Depth=1
                                        #     Child Loop BB68_24 Depth 2
                                        #       Child Loop BB68_26 Depth 3
	bnez	a6, .LBB68_20
# %bb.22:                               #   in Loop: Header=BB68_21 Depth=1
	mv	a2, zero
	j	.LBB68_24
.LBB68_23:                              #   in Loop: Header=BB68_24 Depth=2
	addi	a2, a2, 1
	and	a4, a2, a3
	addi	a5, a5, 3
	bgeu	a4, t6, .LBB68_20
.LBB68_24:                              #   Parent Loop BB68_21 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB68_26 Depth 3
	add	s0, a0, a5
	lb	s1, 0(s0)
	lb	a4, 1(s0)
	srli	s1, s1, 2
	andi	s1, s1, 48
	lbu	s0, 2(s0)
	srli	a4, a4, 4
	andi	a4, a4, 12
	or	a4, a4, s1
	srli	s0, s0, 6
	or	s0, s0, a4
	beq	s0, a1, .LBB68_23
# %bb.25:                               #   in Loop: Header=BB68_24 Depth=2
	lw	s1, %lo(GPU_STATUS)(t0)
.LBB68_26:                              #   Parent Loop BB68_21 Depth=1
                                        #     Parent Loop BB68_24 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	lbu	a4, 0(s1)
	bnez	a4, .LBB68_26
# %bb.27:                               #   in Loop: Header=BB68_24 Depth=2
	lw	a4, %lo(GPU_COLOUR)(t1)
	sb	s0, 0(a4)
	lw	a4, %lo(GPU_X)(t2)
	sh	a2, 0(a4)
	lw	a4, %lo(GPU_Y)(t3)
	sh	s2, 0(a4)
	lw	a4, %lo(GPU_WRITE)(t4)
	sb	t5, 0(a4)
	j	.LBB68_23
.Lfunc_end68:
	.size	netppm_display, .Lfunc_end68-netppm_display
                                        # -- End function
	.section	.text.netppm_decoder,"ax",@progbits
	.globl	netppm_decoder                  # -- Begin function netppm_decoder
	.p2align	1
	.type	netppm_decoder,@function
netppm_decoder:                         # @netppm_decoder
# %bb.0:
	lbu	a2, 0(a0)
	addi	a3, zero, 80
	bne	a2, a3, .LBB69_18
# %bb.1:
	lbu	a2, 1(a0)
	addi	a3, zero, 54
	bne	a2, a3, .LBB69_18
# %bb.2:
	lbu	a2, 2(a0)
	addi	a3, zero, 10
	bne	a2, a3, .LBB69_18
# %bb.3:
	lbu	a3, 3(a0)
	addi	a6, zero, 35
	addi	a5, zero, 3
	bne	a3, a6, .LBB69_8
# %bb.4:
	addi	a5, zero, 4
	addi	a4, zero, 10
	j	.LBB69_6
.LBB69_5:                               #   in Loop: Header=BB69_6 Depth=1
	addi	a5, a5, 1
.LBB69_6:                               # =>This Inner Loop Header: Depth=1
	add	a3, a0, a5
	lbu	a2, -1(a3)
	bne	a2, a4, .LBB69_5
# %bb.7:                                #   in Loop: Header=BB69_6 Depth=1
	lbu	a3, 0(a3)
	beq	a3, a6, .LBB69_5
.LBB69_8:
	lui	a2, 16
	addi	a6, zero, 32
	addi	t3, a2, -48
	mv	t1, zero
	beq	a3, a6, .LBB69_11
# %bb.9:
	addi	t0, a0, 1
	addi	a7, zero, 10
	addi	t2, t3, 47
	add	a2, zero, a5
.LBB69_10:                              # =>This Inner Loop Header: Depth=1
	andi	a4, a3, 255
	mul	a5, t1, a7
	add	a3, t0, a2
	lbu	a3, 0(a3)
	add	a5, a5, t3
	add	a4, a4, a5
	addi	a5, a2, 1
	and	t1, a4, t2
	add	a2, zero, a5
	bne	a3, a6, .LBB69_10
.LBB69_11:
	add	a2, a5, a0
	lbu	a2, 1(a2)
	mv	a7, zero
	addi	a6, zero, 10
	beq	a2, a6, .LBB69_14
# %bb.12:
	addi	t0, a0, 2
	addi	t2, t3, 47
.LBB69_13:                              # =>This Inner Loop Header: Depth=1
	andi	a4, a2, 255
	mul	a3, a7, a6
	add	a2, t0, a5
	lbu	a2, 0(a2)
	add	a3, a3, t3
	add	a3, a3, a4
	and	a7, a3, t2
	addi	a5, a5, 1
	bne	a2, a6, .LBB69_13
.LBB69_14:
	add	a2, a5, a0
	lbu	a2, 2(a2)
	beq	a2, a6, .LBB69_18
# %bb.15:
	mv	a3, zero
	addi	t4, a5, 3
	addi	a6, zero, 10
	addi	t0, t3, 47
.LBB69_16:                              # =>This Inner Loop Header: Depth=1
	andi	a4, a2, 255
	mul	a3, a3, a6
	add	a2, a0, t4
	lbu	a2, 0(a2)
	add	a3, a3, t3
	add	a3, a3, a4
	and	a3, a3, t0
	addi	t4, t4, 1
	bne	a2, a6, .LBB69_16
# %bb.17:
	addi	a2, a3, -255
	snez	a2, a2
	seqz	a3, a7
	or	a2, a2, a3
	beqz	a2, .LBB69_19
.LBB69_18:
	ret
.LBB69_19:
	mv	t0, zero
	mv	a3, zero
	seqz	a6, t1
	addi	t2, a0, 2
	lui	a0, 16
	addi	t3, a0, -1
	j	.LBB69_22
.LBB69_20:                              #   in Loop: Header=BB69_22 Depth=1
	add	a4, zero, a3
.LBB69_21:                              #   in Loop: Header=BB69_22 Depth=1
	addi	t0, t0, 1
	and	a2, t0, t3
	add	a3, zero, a4
	bgeu	a2, a7, .LBB69_18
.LBB69_22:                              # =>This Loop Header: Depth=1
                                        #     Child Loop BB69_24 Depth 2
	bnez	a6, .LBB69_20
# %bb.23:                               #   in Loop: Header=BB69_22 Depth=1
	mv	a2, zero
.LBB69_24:                              #   Parent Loop BB69_22 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	add	a4, t2, t4
	lb	a0, -2(a4)
	lb	a5, -1(a4)
	srli	a0, a0, 2
	andi	a0, a0, 48
	srli	a5, a5, 4
	lbu	a4, 0(a4)
	andi	a5, a5, 12
	or	a0, a0, a5
	addi	t4, t4, 3
	srli	a4, a4, 6
	or	a0, a0, a4
	addi	a4, a3, 1
	add	a3, a3, a1
	addi	a2, a2, 1
	and	a5, a2, t3
	sb	a0, 0(a3)
	add	a3, zero, a4
	bltu	a5, t1, .LBB69_24
	j	.LBB69_21
.Lfunc_end69:
	.size	netppm_decoder, .Lfunc_end69-netppm_decoder
                                        # -- End function
	.section	.text.bitmapblit,"ax",@progbits
	.globl	bitmapblit                      # -- Begin function bitmapblit
	.p2align	1
	.type	bitmapblit,@function
bitmapblit:                             # @bitmapblit
# %bb.0:
	addi	sp, sp, -16
	sw	s0, 12(sp)
	sw	s1, 8(sp)
	sw	s2, 4(sp)
	lui	a6, %hi(GPU_STATUS)
	lw	a6, %lo(GPU_STATUS)(a6)
.LBB70_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a7, 0(a6)
	bnez	a7, .LBB70_1
# %bb.2:
	lui	a6, 16
	addi	a6, a6, -1
	and	t0, a4, a6
	add	a7, a4, a2
	bge	t0, a7, .LBB70_8
# %bb.3:
	mv	t6, zero
	and	a2, a3, a6
	add	t2, a3, a1
	slt	t0, a2, t2
	lui	t1, %hi(GPU_Y)
	lui	t3, %hi(GPU_COLOUR)
	lui	t4, %hi(GPU_X)
	lui	t5, %hi(GPU_WRITE)
	j	.LBB70_5
.LBB70_4:                               #   in Loop: Header=BB70_5 Depth=1
	addi	a4, a4, 1
	and	a1, a4, a6
	bge	a1, a7, .LBB70_8
.LBB70_5:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB70_7 Depth 2
	lw	a1, %lo(GPU_Y)(t1)
	sh	a4, 0(a1)
	beqz	t0, .LBB70_4
# %bb.6:                                #   in Loop: Header=BB70_5 Depth=1
	slli	a1, t6, 1
	add	a1, a1, a0
	add	a2, zero, a3
.LBB70_7:                               #   Parent Loop BB70_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lhu	s0, 0(a1)
	lw	s1, %lo(GPU_COLOUR)(t3)
	sb	s0, 0(s1)
	lw	s1, %lo(GPU_X)(t4)
	sh	a2, 0(s1)
	lw	s2, %lo(GPU_WRITE)(t5)
	andi	s1, s0, 255
	xor	s1, s1, a5
	snez	s1, s1
	sb	s1, 0(s2)
	lw	s1, %lo(GPU_COLOUR)(t3)
	srli	s0, s0, 8
	sb	s0, 0(s1)
	lw	s2, %lo(GPU_X)(t4)
	addi	s1, a2, 1
	sh	s1, 0(s2)
	lw	s1, %lo(GPU_WRITE)(t5)
	xor	s0, s0, a5
	snez	s0, s0
	sb	s0, 0(s1)
	addi	t6, t6, 1
	addi	a2, a2, 2
	and	s0, a2, a6
	addi	a1, a1, 2
	blt	s0, t2, .LBB70_7
	j	.LBB70_4
.LBB70_8:
	lw	s2, 4(sp)
	lw	s1, 8(sp)
	lw	s0, 12(sp)
	addi	sp, sp, 16
	ret
.Lfunc_end70:
	.size	bitmapblit, .Lfunc_end70-bitmapblit
                                        # -- End function
	.section	.text.SMTSTOP,"ax",@progbits
	.globl	SMTSTOP                         # -- Begin function SMTSTOP
	.p2align	1
	.type	SMTSTOP,@function
SMTSTOP:                                # @SMTSTOP
# %bb.0:
	lui	a0, %hi(SMTSTATUS)
	lw	a0, %lo(SMTSTATUS)(a0)
	sb	zero, 0(a0)
	ret
.Lfunc_end71:
	.size	SMTSTOP, .Lfunc_end71-SMTSTOP
                                        # -- End function
	.section	.text.SMTSTART,"ax",@progbits
	.globl	SMTSTART                        # -- Begin function SMTSTART
	.p2align	1
	.type	SMTSTART,@function
SMTSTART:                               # @SMTSTART
# %bb.0:
	lui	a1, %hi(SMTPCH)
	lw	a1, %lo(SMTPCH)(a1)
	srli	a2, a0, 16
	sw	a2, 0(a1)
	lui	a1, %hi(SMTPCL)
	lw	a1, %lo(SMTPCL)(a1)
	lui	a2, 16
	addi	a2, a2, -1
	and	a0, a0, a2
	sw	a0, 0(a1)
	lui	a0, %hi(SMTSTATUS)
	lw	a0, %lo(SMTSTATUS)(a0)
	addi	a1, zero, 1
	sb	a1, 0(a0)
	ret
.Lfunc_end72:
	.size	SMTSTART, .Lfunc_end72-SMTSTART
                                        # -- End function
	.section	.text.SMTSTATE,"ax",@progbits
	.globl	SMTSTATE                        # -- Begin function SMTSTATE
	.p2align	1
	.type	SMTSTATE,@function
SMTSTATE:                               # @SMTSTATE
# %bb.0:
	lui	a0, %hi(SMTSTATUS)
	lw	a0, %lo(SMTSTATUS)(a0)
	lbu	a0, 0(a0)
	ret
.Lfunc_end73:
	.size	SMTSTATE, .Lfunc_end73-SMTSTATE
                                        # -- End function
	.section	.text.initscr,"ax",@progbits
	.globl	initscr                         # -- Begin function initscr
	.p2align	1
	.type	initscr,@function
initscr:                                # @initscr
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)
	sw	s0, 8(sp)
	lui	a0, %hi(__curses_character)
	addi	a0, a0, %lo(__curses_character)
	lui	a1, 1
	addi	s0, a1, -1696
	mv	a1, zero
	add	a2, zero, s0
	call	memset
	lui	a0, %hi(__curses_background)
	addi	a0, a0, %lo(__curses_background)
	addi	a1, zero, 64
	add	a2, zero, s0
	call	memset
	lui	a0, %hi(__curses_foreground)
	addi	a0, a0, %lo(__curses_foreground)
	mv	a1, zero
	add	a2, zero, s0
	call	memset
	lui	a0, %hi(__curses_x)
	sh	zero, %lo(__curses_x)(a0)
	lui	a0, %hi(__curses_y)
	sh	zero, %lo(__curses_y)(a0)
	lui	a0, %hi(__curses_fore)
	addi	a1, zero, 63
	sh	a1, %lo(__curses_fore)(a0)
	lui	a0, %hi(__curses_back)
	sh	zero, %lo(__curses_back)(a0)
	lui	a0, %hi(__curses_cursor)
	addi	a1, zero, 1
	sb	a1, %lo(__curses_cursor)(a0)
	lui	a0, %hi(__curses_scroll)
	sb	a1, %lo(__curses_scroll)(a0)
	lw	s0, 8(sp)
	lw	ra, 12(sp)
	addi	sp, sp, 16
	ret
.Lfunc_end74:
	.size	initscr, .Lfunc_end74-initscr
                                        # -- End function
	.section	.text.endwin,"ax",@progbits
	.globl	endwin                          # -- Begin function endwin
	.p2align	1
	.type	endwin,@function
endwin:                                 # @endwin
# %bb.0:
	addi	a0, zero, 1
	ret
.Lfunc_end75:
	.size	endwin, .Lfunc_end75-endwin
                                        # -- End function
	.section	.text.refresh,"ax",@progbits
	.globl	refresh                         # -- Begin function refresh
	.p2align	1
	.type	refresh,@function
refresh:                                # @refresh
# %bb.0:
	addi	sp, sp, -48
	sw	s0, 44(sp)
	sw	s1, 40(sp)
	sw	s2, 36(sp)
	sw	s3, 32(sp)
	sw	s4, 28(sp)
	sw	s5, 24(sp)
	sw	s6, 20(sp)
	sw	s7, 16(sp)
	sw	s8, 12(sp)
	sw	s9, 8(sp)
	sw	s10, 4(sp)
	sw	s11, 0(sp)
	mv	a0, zero
	lui	t3, %hi(__curses_x)
	lui	a1, 16
	addi	s11, a1, -1
	lui	t1, %hi(__curses_y)
	lui	t2, %hi(__curses_cursor)
	lui	t0, %hi(SYSTEMCLOCK)
	lui	a6, %hi(__curses_fore)
	lui	a7, %hi(__curses_back)
	lui	a5, %hi(TPU_COMMIT)
	addi	s2, zero, 30
	lui	a1, %hi(__curses_background)
	addi	s8, a1, %lo(__curses_background)
	lui	a1, %hi(__curses_foreground)
	addi	s9, a1, %lo(__curses_foreground)
	lui	t4, %hi(TPU_X)
	lui	t5, %hi(TPU_Y)
	lui	t6, %hi(TPU_BACKGROUND)
	lui	s3, %hi(TPU_FOREGROUND)
	addi	s4, zero, 1
	lui	a1, %hi(__curses_character)
	addi	s10, a1, %lo(__curses_character)
	lui	s5, %hi(TPU_CHARACTER)
	addi	s6, zero, 2
	addi	s7, zero, 80
	j	.LBB76_2
.LBB76_1:                               #   in Loop: Header=BB76_2 Depth=1
	addi	a0, a0, 1
	beq	a0, s2, .LBB76_13
.LBB76_2:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB76_3 Depth 2
                                        #       Child Loop BB76_12 Depth 3
                                        #       Child Loop BB76_7 Depth 3
                                        #       Child Loop BB76_9 Depth 3
	mv	s1, zero
.LBB76_3:                               #   Parent Loop BB76_2 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB76_12 Depth 3
                                        #       Child Loop BB76_7 Depth 3
                                        #       Child Loop BB76_9 Depth 3
	lhu	a1, %lo(__curses_x)(t3)
	and	a3, s1, s11
	mul	s0, s1, s2
	bne	a1, a3, .LBB76_6
# %bb.4:                                #   in Loop: Header=BB76_3 Depth=2
	lhu	a1, %lo(__curses_y)(t1)
	lbu	a3, %lo(__curses_cursor)(t2)
	and	a4, a0, s11
	xor	a1, a1, a4
	snez	a1, a1
	seqz	a3, a3
	or	a1, a1, a3
	bnez	a1, .LBB76_6
# %bb.5:                                #   in Loop: Header=BB76_3 Depth=2
	lw	a1, %lo(SYSTEMCLOCK)(t0)
	lhu	a1, 0(a1)
	andi	a1, a1, 1
	bnez	a1, .LBB76_11
.LBB76_6:                               #   in Loop: Header=BB76_3 Depth=2
	add	a1, s0, a0
	add	a2, a1, s8
	lbu	a4, 0(a2)
	add	a1, a1, s9
	lbu	a1, 0(a1)
	lw	a3, %lo(TPU_COMMIT)(a5)
.LBB76_7:                               #   Parent Loop BB76_2 Depth=1
                                        #     Parent Loop BB76_3 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	lbu	a2, 0(a3)
	bnez	a2, .LBB76_7
.LBB76_8:                               #   in Loop: Header=BB76_3 Depth=2
	lw	a2, %lo(TPU_X)(t4)
	sb	s1, 0(a2)
	lw	a2, %lo(TPU_Y)(t5)
	sb	a0, 0(a2)
	lw	a2, %lo(TPU_BACKGROUND)(t6)
	sb	a4, 0(a2)
	lw	a2, %lo(TPU_FOREGROUND)(s3)
	sb	a1, 0(a2)
	lw	a1, %lo(TPU_COMMIT)(a5)
	sb	s4, 0(a1)
	add	a1, s0, a0
	add	a1, a1, s10
	lbu	a1, 0(a1)
	lw	a3, %lo(TPU_COMMIT)(a5)
.LBB76_9:                               #   Parent Loop BB76_2 Depth=1
                                        #     Parent Loop BB76_3 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	lbu	a2, 0(a3)
	bnez	a2, .LBB76_9
# %bb.10:                               #   in Loop: Header=BB76_3 Depth=2
	lw	a2, %lo(TPU_CHARACTER)(s5)
	sb	a1, 0(a2)
	lw	a1, %lo(TPU_COMMIT)(a5)
	addi	s1, s1, 1
	sb	s6, 0(a1)
	bne	s1, s7, .LBB76_3
	j	.LBB76_1
.LBB76_11:                              #   in Loop: Header=BB76_3 Depth=2
	lhu	a4, %lo(__curses_fore)(a6)
	lhu	a1, %lo(__curses_back)(a7)
	lw	a3, %lo(TPU_COMMIT)(a5)
.LBB76_12:                              #   Parent Loop BB76_2 Depth=1
                                        #     Parent Loop BB76_3 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	lbu	a2, 0(a3)
	bnez	a2, .LBB76_12
	j	.LBB76_8
.LBB76_13:
	addi	a0, zero, 1
	lw	s11, 0(sp)
	lw	s10, 4(sp)
	lw	s9, 8(sp)
	lw	s8, 12(sp)
	lw	s7, 16(sp)
	lw	s6, 20(sp)
	lw	s5, 24(sp)
	lw	s4, 28(sp)
	lw	s3, 32(sp)
	lw	s2, 36(sp)
	lw	s1, 40(sp)
	lw	s0, 44(sp)
	addi	sp, sp, 48
	ret
.Lfunc_end76:
	.size	refresh, .Lfunc_end76-refresh
                                        # -- End function
	.section	.text.clear,"ax",@progbits
	.globl	clear                           # -- Begin function clear
	.p2align	1
	.type	clear,@function
clear:                                  # @clear
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)
	sw	s0, 8(sp)
	lui	a0, %hi(__curses_character)
	addi	a0, a0, %lo(__curses_character)
	lui	a1, 1
	addi	s0, a1, -1696
	mv	a1, zero
	add	a2, zero, s0
	call	memset
	lui	a0, %hi(__curses_background)
	addi	a0, a0, %lo(__curses_background)
	addi	a1, zero, 64
	add	a2, zero, s0
	call	memset
	lui	a0, %hi(__curses_foreground)
	addi	a0, a0, %lo(__curses_foreground)
	mv	a1, zero
	add	a2, zero, s0
	call	memset
	lui	a0, %hi(__curses_x)
	sh	zero, %lo(__curses_x)(a0)
	lui	a0, %hi(__curses_y)
	sh	zero, %lo(__curses_y)(a0)
	lui	a0, %hi(__curses_fore)
	addi	a1, zero, 63
	sh	a1, %lo(__curses_fore)(a0)
	lui	a0, %hi(__curses_cursor)
	addi	a1, zero, 1
	sb	a1, %lo(__curses_cursor)(a0)
	lui	a0, %hi(__curses_scroll)
	sb	a1, %lo(__curses_scroll)(a0)
	lui	a1, %hi(__curses_back)
	addi	a0, zero, 1
	sh	zero, %lo(__curses_back)(a1)
	lw	s0, 8(sp)
	lw	ra, 12(sp)
	addi	sp, sp, 16
	ret
.Lfunc_end77:
	.size	clear, .Lfunc_end77-clear
                                        # -- End function
	.section	.text.cbreak,"ax",@progbits
	.globl	cbreak                          # -- Begin function cbreak
	.p2align	1
	.type	cbreak,@function
cbreak:                                 # @cbreak
# %bb.0:
	ret
.Lfunc_end78:
	.size	cbreak, .Lfunc_end78-cbreak
                                        # -- End function
	.section	.text.echo,"ax",@progbits
	.globl	echo                            # -- Begin function echo
	.p2align	1
	.type	echo,@function
echo:                                   # @echo
# %bb.0:
	ret
.Lfunc_end79:
	.size	echo, .Lfunc_end79-echo
                                        # -- End function
	.section	.text.noecho,"ax",@progbits
	.globl	noecho                          # -- Begin function noecho
	.p2align	1
	.type	noecho,@function
noecho:                                 # @noecho
# %bb.0:
	ret
.Lfunc_end80:
	.size	noecho, .Lfunc_end80-noecho
                                        # -- End function
	.section	.text.curs_set,"ax",@progbits
	.globl	curs_set                        # -- Begin function curs_set
	.p2align	1
	.type	curs_set,@function
curs_set:                               # @curs_set
# %bb.0:
	lui	a1, %hi(__curses_cursor)
	sb	a0, %lo(__curses_cursor)(a1)
	ret
.Lfunc_end81:
	.size	curs_set, .Lfunc_end81-curs_set
                                        # -- End function
	.section	.text.start_color,"ax",@progbits
	.globl	start_color                     # -- Begin function start_color
	.p2align	1
	.type	start_color,@function
start_color:                            # @start_color
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)
	sw	s0, 8(sp)
	sw	s1, 4(sp)
	sw	s2, 0(sp)
	lui	s0, %hi(__curses_foregroundcolours)
	addi	s1, s0, %lo(__curses_foregroundcolours)
	sb	zero, 14(s1)
	sb	zero, 13(s1)
	sb	zero, 12(s1)
	sb	zero, 11(s1)
	sb	zero, 10(s1)
	sb	zero, 9(s1)
	sb	zero, 8(s1)
	lui	a0, %hi(__curses_backgroundcolours)
	addi	a0, a0, %lo(__curses_backgroundcolours)
	addi	a2, zero, 15
	addi	s2, zero, 15
	mv	a1, zero
	call	memset
	sb	zero, %lo(__curses_foregroundcolours)(s0)
	addi	a0, zero, 48
	sb	a0, 1(s1)
	addi	a0, zero, 12
	sb	a0, 2(s1)
	addi	a0, zero, 60
	sb	a0, 3(s1)
	addi	a0, zero, 3
	sb	a0, 4(s1)
	addi	a0, zero, 51
	sb	a0, 5(s1)
	sb	s2, 6(s1)
	addi	a1, zero, 63
	addi	a0, zero, 1
	sb	a1, 7(s1)
	lw	s2, 0(sp)
	lw	s1, 4(sp)
	lw	s0, 8(sp)
	lw	ra, 12(sp)
	addi	sp, sp, 16
	ret
.Lfunc_end82:
	.size	start_color, .Lfunc_end82-start_color
                                        # -- End function
	.section	.text.has_colors,"ax",@progbits
	.globl	has_colors                      # -- Begin function has_colors
	.p2align	1
	.type	has_colors,@function
has_colors:                             # @has_colors
# %bb.0:
	addi	a0, zero, 1
	ret
.Lfunc_end83:
	.size	has_colors, .Lfunc_end83-has_colors
                                        # -- End function
	.section	.text.can_change_color,"ax",@progbits
	.globl	can_change_color                # -- Begin function can_change_color
	.p2align	1
	.type	can_change_color,@function
can_change_color:                       # @can_change_color
# %bb.0:
	addi	a0, zero, 1
	ret
.Lfunc_end84:
	.size	can_change_color, .Lfunc_end84-can_change_color
                                        # -- End function
	.section	.text.init_pair,"ax",@progbits
	.globl	init_pair                       # -- Begin function init_pair
	.p2align	1
	.type	init_pair,@function
init_pair:                              # @init_pair
# %bb.0:
	lui	a3, %hi(__curses_foregroundcolours)
	addi	a3, a3, %lo(__curses_foregroundcolours)
	add	a3, a3, a0
	sb	a1, 0(a3)
	lui	a1, %hi(__curses_backgroundcolours)
	addi	a1, a1, %lo(__curses_backgroundcolours)
	add	a1, a1, a0
	addi	a0, zero, 1
	sb	a2, 0(a1)
	ret
.Lfunc_end85:
	.size	init_pair, .Lfunc_end85-init_pair
                                        # -- End function
	.section	.text.move,"ax",@progbits
	.globl	move                            # -- Begin function move
	.p2align	1
	.type	move,@function
move:                                   # @move
# %bb.0:
	addi	a3, zero, 79
	add	a2, zero, a0
	blt	a1, a3, .LBB86_2
# %bb.1:
	addi	a1, zero, 79
.LBB86_2:
	bgtz	a1, .LBB86_4
# %bb.3:
	mv	a1, zero
.LBB86_4:
	lui	a0, %hi(__curses_x)
	addi	a3, zero, 29
	sh	a1, %lo(__curses_x)(a0)
	blt	a2, a3, .LBB86_6
# %bb.5:
	addi	a2, zero, 29
.LBB86_6:
	bgtz	a2, .LBB86_8
# %bb.7:
	mv	a2, zero
.LBB86_8:
	lui	a1, %hi(__curses_y)
	addi	a0, zero, 1
	sh	a2, %lo(__curses_y)(a1)
	ret
.Lfunc_end86:
	.size	move, .Lfunc_end86-move
                                        # -- End function
	.section	.text.__scroll,"ax",@progbits
	.globl	__scroll                        # -- Begin function __scroll
	.p2align	1
	.type	__scroll,@function
__scroll:                               # @__scroll
# %bb.0:
	mv	a7, zero
	lui	a0, %hi(__curses_foreground+1)
	addi	t0, a0, %lo(__curses_foreground+1)
	lui	a0, %hi(__curses_character+1)
	addi	t1, a0, %lo(__curses_character+1)
	lui	a1, %hi(__curses_background+1)
	addi	t2, a1, %lo(__curses_background+1)
	addi	a6, zero, 29
.LBB87_1:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB87_2 Depth 2
	addi	a7, a7, 1
	addi	a5, zero, 80
	add	a3, zero, t2
	add	a2, zero, t1
	add	a1, zero, t0
.LBB87_2:                               #   Parent Loop BB87_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lb	t3, 0(a2)
	lb	a4, 0(a3)
	lb	a0, 0(a1)
	sb	t3, -1(a2)
	sb	a4, -1(a3)
	sb	a0, -1(a1)
	addi	a5, a5, -1
	addi	a1, a1, 30
	addi	a2, a2, 30
	addi	a3, a3, 30
	bnez	a5, .LBB87_2
# %bb.3:                                #   in Loop: Header=BB87_1 Depth=1
	addi	t0, t0, 1
	addi	t1, t1, 1
	addi	t2, t2, 1
	bne	a7, a6, .LBB87_1
# %bb.4:
	ret
.Lfunc_end87:
	.size	__scroll, .Lfunc_end87-__scroll
                                        # -- End function
	.section	.text.addch,"ax",@progbits
	.globl	addch                           # -- Begin function addch
	.p2align	1
	.type	addch,@function
addch:                                  # @addch
# %bb.0:
	addi	a1, zero, 13
	beq	a0, a1, .LBB88_5
# %bb.1:
	addi	a1, zero, 10
	beq	a0, a1, .LBB88_6
# %bb.2:
	addi	a1, zero, 8
	bne	a0, a1, .LBB88_12
# %bb.3:
	lui	a0, %hi(__curses_x)
	lhu	a1, %lo(__curses_x)(a0)
	beqz	a1, .LBB88_21
# %bb.4:
	addi	a1, a1, -1
	j	.LBB88_23
.LBB88_5:
	lui	a0, %hi(__curses_x)
	sh	zero, %lo(__curses_x)(a0)
	addi	a0, zero, 1
	ret
.LBB88_6:
	lui	a0, %hi(__curses_y)
	lhu	a1, %lo(__curses_y)(a0)
	lui	a2, %hi(__curses_x)
	addi	a3, zero, 29
	sh	zero, %lo(__curses_x)(a2)
	bne	a1, a3, .LBB88_19
# %bb.7:
	lui	a0, %hi(__curses_scroll)
	lbu	a0, %lo(__curses_scroll)(a0)
	beqz	a0, .LBB88_25
# %bb.8:
	mv	a7, zero
	lui	a0, %hi(__curses_character+1)
	addi	t0, a0, %lo(__curses_character+1)
	lui	a0, %hi(__curses_foreground+1)
	addi	t1, a0, %lo(__curses_foreground+1)
	lui	a1, %hi(__curses_background+1)
	addi	t2, a1, %lo(__curses_background+1)
	addi	a6, zero, 29
.LBB88_9:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB88_10 Depth 2
	addi	a7, a7, 1
	addi	a5, zero, 80
	add	a3, zero, t2
	add	a2, zero, t1
	add	a1, zero, t0
.LBB88_10:                              #   Parent Loop BB88_9 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lb	t3, 0(a1)
	lb	a4, 0(a3)
	lb	a0, 0(a2)
	sb	t3, -1(a1)
	sb	a4, -1(a3)
	sb	a0, -1(a2)
	addi	a5, a5, -1
	addi	a1, a1, 30
	addi	a2, a2, 30
	addi	a3, a3, 30
	bnez	a5, .LBB88_10
# %bb.11:                               #   in Loop: Header=BB88_9 Depth=1
	addi	t0, t0, 1
	addi	t1, t1, 1
	addi	t2, t2, 1
	bne	a7, a6, .LBB88_9
	j	.LBB88_24
.LBB88_12:
	lui	a1, %hi(__curses_x)
	lhu	a3, %lo(__curses_x)(a1)
	lui	a2, %hi(__curses_y)
	lhu	a2, %lo(__curses_y)(a2)
	addi	a4, zero, 30
	mul	a4, a3, a4
	lui	a5, %hi(__curses_character)
	addi	a5, a5, %lo(__curses_character)
	add	a4, a4, a2
	add	a5, a5, a4
	sb	a0, 0(a5)
	lui	a0, %hi(__curses_back)
	lb	a0, %lo(__curses_back)(a0)
	lui	a5, %hi(__curses_background)
	addi	a5, a5, %lo(__curses_background)
	add	a5, a5, a4
	sb	a0, 0(a5)
	lui	a0, %hi(__curses_fore)
	lb	a0, %lo(__curses_fore)(a0)
	lui	a5, %hi(__curses_foreground)
	addi	a5, a5, %lo(__curses_foreground)
	add	a4, a4, a5
	addi	a5, zero, 79
	sb	a0, 0(a4)
	bne	a3, a5, .LBB88_20
# %bb.13:
	addi	a0, zero, 29
	sh	zero, %lo(__curses_x)(a1)
	bne	a2, a0, .LBB88_26
# %bb.14:
	lui	a0, %hi(__curses_scroll)
	lbu	a0, %lo(__curses_scroll)(a0)
	beqz	a0, .LBB88_25
# %bb.15:
	mv	a7, zero
	lui	a0, %hi(__curses_character+1)
	addi	t0, a0, %lo(__curses_character+1)
	lui	a0, %hi(__curses_foreground+1)
	addi	t1, a0, %lo(__curses_foreground+1)
	lui	a1, %hi(__curses_background+1)
	addi	t2, a1, %lo(__curses_background+1)
	addi	a6, zero, 29
.LBB88_16:                              # =>This Loop Header: Depth=1
                                        #     Child Loop BB88_17 Depth 2
	addi	a7, a7, 1
	addi	a5, zero, 80
	add	a3, zero, t2
	add	a2, zero, t1
	add	a1, zero, t0
.LBB88_17:                              #   Parent Loop BB88_16 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lb	t3, 0(a1)
	lb	a4, 0(a3)
	lb	a0, 0(a2)
	sb	t3, -1(a1)
	sb	a4, -1(a3)
	sb	a0, -1(a2)
	addi	a5, a5, -1
	addi	a1, a1, 30
	addi	a2, a2, 30
	addi	a3, a3, 30
	bnez	a5, .LBB88_17
# %bb.18:                               #   in Loop: Header=BB88_16 Depth=1
	addi	t0, t0, 1
	addi	t1, t1, 1
	addi	t2, t2, 1
	bne	a7, a6, .LBB88_16
	j	.LBB88_24
.LBB88_19:
	addi	a1, a1, 1
	sh	a1, %lo(__curses_y)(a0)
	addi	a0, zero, 1
	ret
.LBB88_20:
	addi	a0, a3, 1
	addi	a1, a1, %lo(__curses_x)
	sh	a0, 0(a1)
	addi	a0, zero, 1
	ret
.LBB88_21:
	lui	a0, %hi(__curses_y)
	lhu	a1, %lo(__curses_y)(a0)
	beqz	a1, .LBB88_24
# %bb.22:
	addi	a1, a1, -1
	sh	a1, %lo(__curses_y)(a0)
	lui	a0, %hi(__curses_x)
	addi	a1, zero, 79
.LBB88_23:
	sh	a1, %lo(__curses_x)(a0)
	addi	a0, zero, 1
	ret
.LBB88_24:
	addi	a0, zero, 1
	ret
.LBB88_25:
	lui	a0, %hi(__curses_y)
	sh	zero, %lo(__curses_y)(a0)
	addi	a0, zero, 1
	ret
.LBB88_26:
	addi	a0, a2, 1
	lui	a1, %hi(__curses_y)
	sh	a0, %lo(__curses_y)(a1)
	addi	a0, zero, 1
	ret
.Lfunc_end88:
	.size	addch, .Lfunc_end88-addch
                                        # -- End function
	.section	.text.mvaddch,"ax",@progbits
	.globl	mvaddch                         # -- Begin function mvaddch
	.p2align	1
	.type	mvaddch,@function
mvaddch:                                # @mvaddch
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)
	addi	a3, zero, 79
	blt	a1, a3, .LBB89_2
# %bb.1:
	addi	a1, zero, 79
.LBB89_2:
	bgtz	a1, .LBB89_4
# %bb.3:
	mv	a1, zero
.LBB89_4:
	lui	a3, %hi(__curses_x)
	addi	a4, zero, 29
	sh	a1, %lo(__curses_x)(a3)
	blt	a0, a4, .LBB89_6
# %bb.5:
	addi	a0, zero, 29
.LBB89_6:
	bgtz	a0, .LBB89_8
# %bb.7:
	mv	a0, zero
.LBB89_8:
	lui	a1, %hi(__curses_y)
	sh	a0, %lo(__curses_y)(a1)
	add	a0, zero, a2
	call	addch
	addi	a0, zero, 1
	lw	ra, 12(sp)
	addi	sp, sp, 16
	ret
.Lfunc_end89:
	.size	mvaddch, .Lfunc_end89-mvaddch
                                        # -- End function
	.section	.text.__curses_print_string,"ax",@progbits
	.globl	__curses_print_string           # -- Begin function __curses_print_string
	.p2align	1
	.type	__curses_print_string,@function
__curses_print_string:                  # @__curses_print_string
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)
	sw	s0, 8(sp)
	lbu	a1, 0(a0)
	beqz	a1, .LBB90_3
# %bb.1:
	addi	s0, a0, 1
.LBB90_2:                               # =>This Inner Loop Header: Depth=1
	andi	a0, a1, 255
	call	addch
	lbu	a1, 0(s0)
	addi	s0, s0, 1
	bnez	a1, .LBB90_2
.LBB90_3:
	lw	s0, 8(sp)
	lw	ra, 12(sp)
	addi	sp, sp, 16
	ret
.Lfunc_end90:
	.size	__curses_print_string, .Lfunc_end90-__curses_print_string
                                        # -- End function
	.section	.text.printw,"ax",@progbits
	.globl	printw                          # -- Begin function printw
	.p2align	1
	.type	printw,@function
printw:                                 # @printw
# %bb.0:
	addi	sp, sp, -48
	sw	ra, 12(sp)
	sw	s0, 8(sp)
	sw	s1, 4(sp)
	add	t0, zero, a0
	sw	a7, 44(sp)
	sw	a6, 40(sp)
	sw	a5, 36(sp)
	sw	a4, 32(sp)
	sw	a3, 28(sp)
	sw	a2, 24(sp)
	sw	a1, 20(sp)
	addi	a3, sp, 20
	sw	a3, 0(sp)
	lui	s1, %hi(printw.buffer)
	addi	s0, s1, %lo(printw.buffer)
	addi	a1, zero, 1023
	add	a0, zero, s0
	add	a2, zero, t0
	call	vsnprintf
	lbu	a0, %lo(printw.buffer)(s1)
	beqz	a0, .LBB91_3
# %bb.1:
	addi	s0, s0, 1
.LBB91_2:                               # =>This Inner Loop Header: Depth=1
	andi	a0, a0, 255
	call	addch
	lbu	a0, 0(s0)
	addi	s0, s0, 1
	bnez	a0, .LBB91_2
.LBB91_3:
	addi	a0, zero, 1
	lw	s1, 4(sp)
	lw	s0, 8(sp)
	lw	ra, 12(sp)
	addi	sp, sp, 48
	ret
.Lfunc_end91:
	.size	printw, .Lfunc_end91-printw
                                        # -- End function
	.section	.text.mvprintw,"ax",@progbits
	.globl	mvprintw                        # -- Begin function mvprintw
	.p2align	1
	.type	mvprintw,@function
mvprintw:                               # @mvprintw
# %bb.0:
	addi	sp, sp, -48
	sw	ra, 20(sp)
	sw	s0, 16(sp)
	sw	s1, 12(sp)
	sw	s2, 8(sp)
	add	s1, zero, a1
	add	s0, zero, a0
	sw	a7, 44(sp)
	sw	a6, 40(sp)
	sw	a5, 36(sp)
	sw	a4, 32(sp)
	sw	a3, 28(sp)
	addi	a3, sp, 28
	sw	a3, 4(sp)
	lui	s2, %hi(mvprintw.buffer)
	addi	a0, s2, %lo(mvprintw.buffer)
	addi	a1, zero, 1023
	call	vsnprintf
	addi	a0, zero, 79
	blt	s1, a0, .LBB92_2
# %bb.1:
	addi	s1, zero, 79
.LBB92_2:
	bgtz	s1, .LBB92_4
# %bb.3:
	mv	s1, zero
.LBB92_4:
	lui	a0, %hi(__curses_x)
	addi	a1, zero, 29
	sh	s1, %lo(__curses_x)(a0)
	blt	s0, a1, .LBB92_6
# %bb.5:
	addi	s0, zero, 29
.LBB92_6:
	bgtz	s0, .LBB92_8
# %bb.7:
	mv	s0, zero
.LBB92_8:
	lbu	a0, %lo(mvprintw.buffer)(s2)
	lui	a1, %hi(__curses_y)
	sh	s0, %lo(__curses_y)(a1)
	beqz	a0, .LBB92_11
# %bb.9:
	lui	a1, %hi(mvprintw.buffer+1)
	addi	s0, a1, %lo(mvprintw.buffer+1)
.LBB92_10:                              # =>This Inner Loop Header: Depth=1
	andi	a0, a0, 255
	call	addch
	lbu	a0, 0(s0)
	addi	s0, s0, 1
	bnez	a0, .LBB92_10
.LBB92_11:
	addi	a0, zero, 1
	lw	s2, 8(sp)
	lw	s1, 12(sp)
	lw	s0, 16(sp)
	lw	ra, 20(sp)
	addi	sp, sp, 48
	ret
.Lfunc_end92:
	.size	mvprintw, .Lfunc_end92-mvprintw
                                        # -- End function
	.section	.text.attron,"ax",@progbits
	.globl	attron                          # -- Begin function attron
	.p2align	1
	.type	attron,@function
attron:                                 # @attron
# %bb.0:
	lui	a1, %hi(__curses_foregroundcolours)
	addi	a1, a1, %lo(__curses_foregroundcolours)
	add	a1, a1, a0
	lbu	a1, 0(a1)
	lui	a2, %hi(__curses_fore)
	lui	a3, %hi(__curses_backgroundcolours)
	addi	a3, a3, %lo(__curses_backgroundcolours)
	add	a0, a0, a3
	lbu	a3, 0(a0)
	sh	a1, %lo(__curses_fore)(a2)
	lui	a1, %hi(__curses_back)
	addi	a0, zero, 1
	sh	a3, %lo(__curses_back)(a1)
	ret
.Lfunc_end93:
	.size	attron, .Lfunc_end93-attron
                                        # -- End function
	.section	.text.deleteln,"ax",@progbits
	.globl	deleteln                        # -- Begin function deleteln
	.p2align	1
	.type	deleteln,@function
deleteln:                               # @deleteln
# %bb.0:
	lui	a0, %hi(__curses_y)
	lhu	a0, %lo(__curses_y)(a0)
	addi	a1, zero, 29
	bne	a0, a1, .LBB94_3
# %bb.1:
	lui	a0, %hi(__curses_back)
	lhu	a0, %lo(__curses_back)(a0)
	lui	a1, %hi(__curses_fore)
	lhu	a1, %lo(__curses_fore)(a1)
	addi	a2, zero, 80
	lui	a3, %hi(__curses_foreground+29)
	addi	a3, a3, %lo(__curses_foreground+29)
	lui	a4, %hi(__curses_background+29)
	addi	a4, a4, %lo(__curses_background+29)
	lui	a5, %hi(__curses_character+29)
	addi	a5, a5, %lo(__curses_character+29)
.LBB94_2:                               # =>This Inner Loop Header: Depth=1
	sb	zero, 0(a5)
	sb	a0, 0(a4)
	sb	a1, 0(a3)
	addi	a3, a3, 30
	addi	a4, a4, 30
	addi	a2, a2, -1
	addi	a5, a5, 30
	bnez	a2, .LBB94_2
	j	.LBB94_10
.LBB94_3:
	andi	a7, a0, 255
	addi	a0, zero, 28
	bltu	a0, a7, .LBB94_8
# %bb.4:
	lui	a0, %hi(__curses_foreground)
	addi	a0, a0, %lo(__curses_foreground)
	add	a0, a0, a7
	addi	t0, a0, 1
	lui	a0, %hi(__curses_character)
	addi	a0, a0, %lo(__curses_character)
	add	a0, a0, a7
	addi	t1, a0, 1
	lui	a1, %hi(__curses_background)
	addi	a1, a1, %lo(__curses_background)
	add	a1, a1, a7
	addi	t2, a1, 1
	addi	a6, zero, 29
.LBB94_5:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB94_6 Depth 2
	addi	a7, a7, 1
	addi	a5, zero, 80
	add	a3, zero, t2
	add	a2, zero, t1
	add	a1, zero, t0
.LBB94_6:                               #   Parent Loop BB94_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lb	t3, 0(a2)
	lb	a4, 0(a3)
	lb	a0, 0(a1)
	sb	t3, -1(a2)
	sb	a4, -1(a3)
	sb	a0, -1(a1)
	addi	a5, a5, -1
	addi	a1, a1, 30
	addi	a2, a2, 30
	addi	a3, a3, 30
	bnez	a5, .LBB94_6
# %bb.7:                                #   in Loop: Header=BB94_5 Depth=1
	addi	t0, t0, 1
	addi	t1, t1, 1
	addi	t2, t2, 1
	bne	a7, a6, .LBB94_5
.LBB94_8:
	lui	a0, %hi(__curses_back)
	lhu	a0, %lo(__curses_back)(a0)
	lui	a1, %hi(__curses_fore)
	lhu	a1, %lo(__curses_fore)(a1)
	addi	a2, zero, 80
	lui	a3, %hi(__curses_foreground+29)
	addi	a3, a3, %lo(__curses_foreground+29)
	lui	a4, %hi(__curses_background+29)
	addi	a4, a4, %lo(__curses_background+29)
	lui	a5, %hi(__curses_character+29)
	addi	a5, a5, %lo(__curses_character+29)
.LBB94_9:                               # =>This Inner Loop Header: Depth=1
	sb	zero, 0(a5)
	sb	a0, 0(a4)
	sb	a1, 0(a3)
	addi	a3, a3, 30
	addi	a4, a4, 30
	addi	a2, a2, -1
	addi	a5, a5, 30
	bnez	a2, .LBB94_9
.LBB94_10:
	addi	a0, zero, 1
	ret
.Lfunc_end94:
	.size	deleteln, .Lfunc_end94-deleteln
                                        # -- End function
	.section	.text.clrtoeol,"ax",@progbits
	.globl	clrtoeol                        # -- Begin function clrtoeol
	.p2align	1
	.type	clrtoeol,@function
clrtoeol:                               # @clrtoeol
# %bb.0:
	lui	a0, %hi(__curses_x)
	lhu	a3, %lo(__curses_x)(a0)
	addi	a2, zero, 79
	bltu	a2, a3, .LBB95_5
# %bb.1:
	lui	a0, %hi(__curses_y)
	lhu	a6, %lo(__curses_y)(a0)
	lui	a0, %hi(__curses_back)
	lhu	a0, %lo(__curses_back)(a0)
	lui	a1, %hi(__curses_fore)
	lhu	a1, %lo(__curses_fore)(a1)
	add	a5, zero, a3
	bltu	a2, a3, .LBB95_3
# %bb.2:
	addi	a5, zero, 79
.LBB95_3:
	sub	a2, a5, a3
	addi	a2, a2, 1
	addi	a5, zero, 30
	mul	a3, a3, a5
	lui	a5, %hi(__curses_character)
	addi	a4, a5, %lo(__curses_character)
	add	a6, a6, a3
	add	a3, a6, a4
	lui	a4, %hi(__curses_background)
	addi	a4, a4, %lo(__curses_background)
	add	a4, a4, a6
	lui	a5, %hi(__curses_foreground)
	addi	a5, a5, %lo(__curses_foreground)
	add	a5, a5, a6
.LBB95_4:                               # =>This Inner Loop Header: Depth=1
	sb	zero, 0(a3)
	sb	a0, 0(a4)
	sb	a1, 0(a5)
	addi	a2, a2, -1
	addi	a3, a3, 30
	addi	a4, a4, 30
	addi	a5, a5, 30
	bnez	a2, .LBB95_4
.LBB95_5:
	addi	a0, zero, 1
	ret
.Lfunc_end95:
	.size	clrtoeol, .Lfunc_end95-clrtoeol
                                        # -- End function
	.section	.text._sbrk,"ax",@progbits
	.globl	_sbrk                           # -- Begin function _sbrk
	.p2align	1
	.type	_sbrk,@function
_sbrk:                                  # @_sbrk
# %bb.0:
	lui	a2, %hi(_heap)
	lw	a1, %lo(_heap)(a2)
	beqz	a1, .LBB96_4
# %bb.1:
	bltz	a0, .LBB96_3
.LBB96_2:
	add	a0, a0, a1
	lui	a2, %hi(_heap)
	sw	a0, %lo(_heap)(a2)
.LBB96_3:
	add	a0, zero, a1
	ret
.LBB96_4:
	lui	a1, %hi(MEMORYTOP)
	lw	a1, %lo(MEMORYTOP)(a1)
	lui	a3, 1044480
	addi	a3, a3, -32
	add	a1, a1, a3
	sw	a1, %lo(_heap)(a2)
	bgez	a0, .LBB96_2
	j	.LBB96_3
.Lfunc_end96:
	.size	_sbrk, .Lfunc_end96-_sbrk
                                        # -- End function
	.section	.text._write,"ax",@progbits
	.globl	_write                          # -- Begin function _write
	.p2align	1
	.type	_write,@function
_write:                                 # @_write
# %bb.0:
	beqz	a2, .LBB97_10
# %bb.1:
	sltiu	a0, a0, 3
	lui	t0, %hi(UART_STATUS)
	lui	t1, %hi(UART_DATA)
	addi	a7, zero, 10
	addi	a6, zero, 13
	j	.LBB97_3
.LBB97_2:                               #   in Loop: Header=BB97_3 Depth=1
	beqz	a2, .LBB97_10
.LBB97_3:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB97_5 Depth 2
                                        #     Child Loop BB97_8 Depth 2
	addi	a2, a2, -1
	beqz	a0, .LBB97_2
# %bb.4:                                #   in Loop: Header=BB97_3 Depth=1
	lbu	a5, 0(a1)
	lw	a3, %lo(UART_STATUS)(t0)
.LBB97_5:                               #   Parent Loop BB97_3 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lbu	a4, 0(a3)
	andi	a4, a4, 2
	bnez	a4, .LBB97_5
# %bb.6:                                #   in Loop: Header=BB97_3 Depth=1
	lw	a3, %lo(UART_DATA)(t1)
	addi	a1, a1, 1
	sb	a5, 0(a3)
	bne	a5, a7, .LBB97_2
# %bb.7:                                #   in Loop: Header=BB97_3 Depth=1
	lw	a3, %lo(UART_STATUS)(t0)
.LBB97_8:                               #   Parent Loop BB97_3 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lbu	a4, 0(a3)
	andi	a4, a4, 2
	bnez	a4, .LBB97_8
# %bb.9:                                #   in Loop: Header=BB97_3 Depth=1
	lw	a3, %lo(UART_DATA)(t1)
	sb	a6, 0(a3)
	j	.LBB97_2
.LBB97_10:
	ret
.Lfunc_end97:
	.size	_write, .Lfunc_end97-_write
                                        # -- End function
	.section	.text._read,"ax",@progbits
	.globl	_read                           # -- Begin function _read
	.p2align	1
	.type	_read,@function
_read:                                  # @_read
# %bb.0:
	beqz	a2, .LBB98_7
# %bb.1:
	sltiu	a0, a0, 3
	lui	a6, %hi(UART_STATUS)
	lui	a4, %hi(UART_DATA)
	j	.LBB98_3
.LBB98_2:                               #   in Loop: Header=BB98_3 Depth=1
	beqz	a2, .LBB98_7
.LBB98_3:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB98_5 Depth 2
	addi	a2, a2, -1
	beqz	a0, .LBB98_2
# %bb.4:                                #   in Loop: Header=BB98_3 Depth=1
	lw	a5, %lo(UART_STATUS)(a6)
.LBB98_5:                               #   Parent Loop BB98_3 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lbu	a3, 0(a5)
	andi	a3, a3, 1
	beqz	a3, .LBB98_5
# %bb.6:                                #   in Loop: Header=BB98_3 Depth=1
	lw	a3, %lo(UART_DATA)(a4)
	lb	a3, 0(a3)
	addi	a5, a1, 1
	sb	a3, 0(a1)
	add	a1, zero, a5
	j	.LBB98_2
.LBB98_7:
	ret
.Lfunc_end98:
	.size	_read, .Lfunc_end98-_read
                                        # -- End function
	.section	.text._open,"ax",@progbits
	.globl	_open                           # -- Begin function _open
	.p2align	1
	.type	_open,@function
_open:                                  # @_open
# %bb.0:
	addi	a0, zero, -1
	ret
.Lfunc_end99:
	.size	_open, .Lfunc_end99-_open
                                        # -- End function
	.section	.text._close,"ax",@progbits
	.globl	_close                          # -- Begin function _close
	.p2align	1
	.type	_close,@function
_close:                                 # @_close
# %bb.0:
	addi	a0, zero, -1
	ret
.Lfunc_end100:
	.size	_close, .Lfunc_end100-_close
                                        # -- End function
	.section	.text._fstat,"ax",@progbits
	.globl	_fstat                          # -- Begin function _fstat
	.p2align	1
	.type	_fstat,@function
_fstat:                                 # @_fstat
# %bb.0:
	mv	a0, zero
	ret
.Lfunc_end101:
	.size	_fstat, .Lfunc_end101-_fstat
                                        # -- End function
	.section	.text._isatty,"ax",@progbits
	.globl	_isatty                         # -- Begin function _isatty
	.p2align	1
	.type	_isatty,@function
_isatty:                                # @_isatty
# %bb.0:
	mv	a0, zero
	ret
.Lfunc_end102:
	.size	_isatty, .Lfunc_end102-_isatty
                                        # -- End function
	.section	.text._lseek,"ax",@progbits
	.globl	_lseek                          # -- Begin function _lseek
	.p2align	1
	.type	_lseek,@function
_lseek:                                 # @_lseek
# %bb.0:
	mv	a0, zero
	ret
.Lfunc_end103:
	.size	_lseek, .Lfunc_end103-_lseek
                                        # -- End function
	.section	.text._getpid,"ax",@progbits
	.globl	_getpid                         # -- Begin function _getpid
	.p2align	1
	.type	_getpid,@function
_getpid:                                # @_getpid
# %bb.0:
	mv	a0, zero
	ret
.Lfunc_end104:
	.size	_getpid, .Lfunc_end104-_getpid
                                        # -- End function
	.section	.text._kill,"ax",@progbits
	.globl	_kill                           # -- Begin function _kill
	.p2align	1
	.type	_kill,@function
_kill:                                  # @_kill
# %bb.0:
	addi	a0, zero, -1
	ret
.Lfunc_end105:
	.size	_kill, .Lfunc_end105-_kill
                                        # -- End function
	.section	.text._exit,"ax",@progbits
	.globl	_exit                           # -- Begin function _exit
	.p2align	1
	.type	_exit,@function
_exit:                                  # @_exit
# %bb.0:
.Lfunc_end106:
	.size	_exit, .Lfunc_end106-_exit
                                        # -- End function
	.section	.text.filemalloc,"ax",@progbits
	.globl	filemalloc                      # -- Begin function filemalloc
	.p2align	1
	.type	filemalloc,@function
filemalloc:                             # @filemalloc
# %bb.0:
	lui	a1, %hi(CLUSTERSIZE)
	lw	a1, %lo(CLUSTERSIZE)(a1)
	divu	a2, a0, a1
	mul	a3, a2, a1
	sub	a0, a0, a3
	snez	a0, a0
	add	a0, a0, a2
	mul	a0, a0, a1
	tail	malloc
.Lfunc_end107:
	.size	filemalloc, .Lfunc_end107-filemalloc
                                        # -- End function
	.section	.text.INITIALISEMEMORY,"ax",@progbits
	.globl	INITIALISEMEMORY                # -- Begin function INITIALISEMEMORY
	.p2align	1
	.type	INITIALISEMEMORY,@function
INITIALISEMEMORY:                       # @INITIALISEMEMORY
# %bb.0:
	lui	a0, %hi(MBR)
	lui	a6, 73728
	addi	a2, a6, -512
	sw	a2, %lo(MBR)(a0)
	lui	a0, %hi(BOOTSECTOR)
	lui	a2, 73600
	sw	a2, %lo(BOOTSECTOR)(a0)
	lui	a0, %hi(PARTITION)
	addi	a3, a6, -66
	sw	a3, %lo(PARTITION)(a0)
	lbu	a0, 18(a2)
	lbu	a3, 17(a2)
	slli	a0, a0, 8
	or	a7, a0, a3
	slli	a3, a7, 5
	addi	a4, a6, -1024
	sub	a3, a4, a3
	lui	a4, %hi(ROOTDIRECTORY)
	sw	a3, %lo(ROOTDIRECTORY)(a4)
	lhu	a4, 22(a2)
	slli	a5, a4, 10
	sub	a3, a3, a5
	lui	a5, %hi(FAT)
	sw	a3, %lo(FAT)(a5)
	lbu	a5, 13(a2)
	slli	a5, a5, 9
	sub	a3, a3, a5
	lui	a1, %hi(CLUSTERBUFFER)
	sw	a3, %lo(CLUSTERBUFFER)(a1)
	lui	a1, %hi(CLUSTERSIZE)
	sw	a5, %lo(CLUSTERSIZE)(a1)
	lhu	a1, -56(a6)
	lhu	a5, -58(a6)
	lbu	a0, 16(a2)
	slli	a1, a1, 16
	or	a1, a1, a5
	lhu	a2, 14(a2)
	mul	a0, a0, a4
	srli	a4, a7, 4
	add	a1, a1, a4
	add	a1, a1, a2
	add	a0, a0, a1
	lui	a1, %hi(DATASTARTSECTOR)
	sw	a0, %lo(DATASTARTSECTOR)(a1)
	lui	a0, %hi(MEMORYTOP)
	sw	a3, %lo(MEMORYTOP)(a0)
	lui	a0, %hi(_heap)
	sw	zero, %lo(_heap)(a0)
	ret
.Lfunc_end108:
	.size	INITIALISEMEMORY, .Lfunc_end108-INITIALISEMEMORY
                                        # -- End function
	.section	.text.njInit,"ax",@progbits
	.globl	njInit                          # -- Begin function njInit
	.p2align	1
	.type	njInit,@function
njInit:                                 # @njInit
# %bb.0:
	lui	a0, %hi(nj)
	addi	a0, a0, %lo(nj)
	lui	a1, 128
	addi	a2, a1, 712
	mv	a1, zero
	tail	memset
.Lfunc_end109:
	.size	njInit, .Lfunc_end109-njInit
                                        # -- End function
	.section	.text.njDone,"ax",@progbits
	.globl	njDone                          # -- Begin function njDone
	.p2align	1
	.type	njDone,@function
njDone:                                 # @njDone
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)
	sw	s0, 8(sp)
	sw	s1, 4(sp)
	lui	a0, %hi(nj)
	addi	s0, a0, %lo(nj)
	lw	a0, 84(s0)
	beqz	a0, .LBB110_2
# %bb.1:
	call	free
.LBB110_2:
	lw	a0, 128(s0)
	beqz	a0, .LBB110_4
# %bb.3:
	call	free
.LBB110_4:
	lui	a0, %hi(nj)
	addi	s1, a0, %lo(nj)
	lw	a0, 172(s1)
	beqz	a0, .LBB110_6
# %bb.5:
	call	free
.LBB110_6:
	lui	s0, 128
	addi	a0, s0, 708
	add	a0, a0, s1
	lw	a0, 0(a0)
	beqz	a0, .LBB110_8
# %bb.7:
	call	free
.LBB110_8:
	lui	a0, %hi(nj)
	addi	a0, a0, %lo(nj)
	addi	a2, s0, 712
	mv	a1, zero
	lw	s1, 4(sp)
	lw	s0, 8(sp)
	lw	ra, 12(sp)
	addi	sp, sp, 16
	tail	memset
.Lfunc_end110:
	.size	njDone, .Lfunc_end110-njDone
                                        # -- End function
	.section	.text.njDecode,"ax",@progbits
	.globl	njDecode                        # -- Begin function njDecode
	.p2align	1
	.type	njDecode,@function
njDecode:                               # @njDecode
# %bb.0:
	addi	sp, sp, -144
	sw	ra, 140(sp)
	sw	s0, 136(sp)
	sw	s1, 132(sp)
	sw	s2, 128(sp)
	sw	s3, 124(sp)
	sw	s4, 120(sp)
	sw	s5, 116(sp)
	sw	s6, 112(sp)
	sw	s7, 108(sp)
	sw	s8, 104(sp)
	sw	s9, 100(sp)
	sw	s10, 96(sp)
	sw	s11, 92(sp)
	lui	a2, %hi(nj)
	addi	s0, a2, %lo(nj)
	lw	a2, 84(s0)
	add	s3, zero, a1
	add	s2, zero, a0
	beqz	a2, .LBB111_2
# %bb.1:
	add	a0, zero, a2
	call	free
.LBB111_2:
	lw	a0, 128(s0)
	beqz	a0, .LBB111_4
# %bb.3:
	call	free
.LBB111_4:
	lui	a0, %hi(nj)
	addi	s0, a0, %lo(nj)
	lw	a0, 172(s0)
	beqz	a0, .LBB111_6
# %bb.5:
	call	free
.LBB111_6:
	lui	s1, 128
	addi	a0, s1, 708
	add	a0, a0, s0
	lw	a0, 0(a0)
	beqz	a0, .LBB111_8
# %bb.7:
	call	free
.LBB111_8:
	lui	a0, %hi(nj)
	addi	s0, a0, %lo(nj)
	addi	a2, s1, 712
	add	a0, zero, s0
	mv	a1, zero
	call	memset
	sw	s2, 4(s0)
	lui	a0, 524288
	addi	a0, a0, -1
	and	a1, s3, a0
	sw	a1, 8(s0)
	addi	a2, zero, 2
	addi	a0, zero, 1
	bgeu	a1, a2, .LBB111_9
	j	.LBB111_341
.LBB111_9:
	lbu	a2, 1(s2)
	lbu	a3, 0(s2)
	xori	a2, a2, 216
	xori	a3, a3, 255
	or	a2, a2, a3
	beqz	a2, .LBB111_10
	j	.LBB111_341
.LBB111_10:
	mv	s4, zero
	mv	s5, zero
	mv	s3, zero
	mv	a6, zero
	mv	a0, zero
	addi	a3, s2, 2
	lui	s8, %hi(nj)
	addi	s7, s8, %lo(nj)
	sw	a3, 4(s7)
	addi	a1, a1, -2
	sw	a1, 8(s7)
	addi	a1, zero, -2
	sw	a1, 12(s7)
	addi	t6, zero, 2
	addi	ra, zero, 255
	addi	s9, zero, 218
	addi	t0, zero, 192
	addi	t4, zero, 3
	addi	t5, zero, 10
	addi	t2, zero, 8
	lui	a1, 16
	addi	t3, a1, -1
	addi	t1, zero, 1
	lui	a7, 128
	addi	a1, a7, 708
	sw	a1, 72(sp)
	lui	a1, %hi(njDecodeDHT.counts)
	addi	a1, a1, %lo(njDecodeDHT.counts)
	sw	a1, 88(sp)
	lui	a1, 1048575
	addi	a1, a1, 79
	sw	a1, 84(sp)
	lui	a1, 1
	addi	a1, a1, -1820
	sw	a1, 80(sp)
	lui	a1, %hi(njZZ)
	addi	a1, a1, %lo(njZZ)
	sw	a1, 76(sp)
	addi	s11, zero, 64
	j	.LBB111_12
.LBB111_11:                             #   in Loop: Header=BB111_12 Depth=1
	addi	s4, zero, 5
	sw	s4, %lo(nj)(s8)
	addi	s5, zero, 5
	addi	s3, zero, 5
	addi	a6, zero, 5
	addi	a0, zero, 5
.LBB111_12:                             # =>This Loop Header: Depth=1
                                        #     Child Loop BB111_74 Depth 2
                                        #       Child Loop BB111_76 Depth 3
                                        #     Child Loop BB111_90 Depth 2
                                        #     Child Loop BB111_127 Depth 2
                                        #       Child Loop BB111_129 Depth 3
                                        #         Child Loop BB111_131 Depth 4
                                        #           Child Loop BB111_133 Depth 5
                                        #             Child Loop BB111_146 Depth 6
                                        #             Child Loop BB111_165 Depth 6
                                        #             Child Loop BB111_170 Depth 6
                                        #     Child Loop BB111_48 Depth 2
                                        #       Child Loop BB111_55 Depth 3
                                        #         Child Loop BB111_60 Depth 4
                                        #           Child Loop BB111_62 Depth 5
                                        #       Child Loop BB111_65 Depth 3
                                        #     Child Loop BB111_108 Depth 2
                                        #     Child Loop BB111_225 Depth 2
	beqz	a0, .LBB111_13
	j	.LBB111_237
.LBB111_13:                             #   in Loop: Header=BB111_12 Depth=1
	lw	a3, 8(s7)
	addi	a0, zero, 5
	bge	a3, t6, .LBB111_14
	j	.LBB111_341
.LBB111_14:                             #   in Loop: Header=BB111_12 Depth=1
	lw	a1, 4(s7)
	lbu	a4, 0(a1)
	beq	a4, ra, .LBB111_15
	j	.LBB111_341
.LBB111_15:                             #   in Loop: Header=BB111_12 Depth=1
	addi	s0, a1, 2
	lw	a0, 12(s7)
	sw	s0, 4(s7)
	addi	a5, a3, -2
	sw	a5, 8(s7)
	addi	a4, a0, -2
	sw	a4, 12(s7)
	lbu	a0, 1(a1)
	blt	s9, a0, .LBB111_24
# %bb.16:                               #   in Loop: Header=BB111_12 Depth=1
	beq	a0, t0, .LBB111_31
# %bb.17:                               #   in Loop: Header=BB111_12 Depth=1
	addi	a2, zero, 196
	beq	a0, a2, .LBB111_44
# %bb.18:                               #   in Loop: Header=BB111_12 Depth=1
	bne	a0, s9, .LBB111_27
# %bb.19:                               #   in Loop: Header=BB111_12 Depth=1
	bge	t4, a3, .LBB111_11
# %bb.20:                               #   in Loop: Header=BB111_12 Depth=1
	addi	a0, a7, 704
	lbu	a2, 2(a1)
	lbu	a4, 3(a1)
	add	s10, s7, a0
	lw	s1, 0(s10)
	slli	a0, a2, 8
	or	s0, a0, a4
	sw	s0, 12(s7)
	blt	a5, s0, .LBB111_11
# %bb.21:                               #   in Loop: Header=BB111_12 Depth=1
	addi	a4, a1, 4
	sw	a4, 4(s7)
	addi	a0, a3, -4
	sw	a0, 8(s7)
	addi	a5, s0, -2
	sw	a5, 12(s7)
	add	a0, zero, a6
	bnez	a6, .LBB111_12
# %bb.22:                               #   in Loop: Header=BB111_12 Depth=1
	lui	s4, 128
	lw	a7, 40(s7)
	slli	a0, a7, 1
	addi	a0, a0, 4
	bge	a5, a0, .LBB111_84
# %bb.23:                               #   in Loop: Header=BB111_12 Depth=1
	addi	s4, zero, 5
	sw	s4, %lo(nj)(s8)
	addi	s5, zero, 5
	addi	s3, zero, 5
	addi	a6, zero, 5
	addi	a0, zero, 5
	lui	a7, 128
	j	.LBB111_12
.LBB111_24:                             #   in Loop: Header=BB111_12 Depth=1
	addi	a2, zero, 219
	beq	a0, a2, .LBB111_39
# %bb.25:                               #   in Loop: Header=BB111_12 Depth=1
	addi	a2, zero, 221
	beq	a0, a2, .LBB111_68
# %bb.26:                               #   in Loop: Header=BB111_12 Depth=1
	addi	a2, zero, 254
	beq	a0, a2, .LBB111_28
.LBB111_27:                             #   in Loop: Header=BB111_12 Depth=1
	andi	a0, a0, 240
	addi	a2, zero, 224
	beq	a0, a2, .LBB111_28
	j	.LBB111_330
.LBB111_28:                             #   in Loop: Header=BB111_12 Depth=1
	bge	t4, a3, .LBB111_30
# %bb.29:                               #   in Loop: Header=BB111_12 Depth=1
	lbu	a0, 2(a1)
	lbu	a2, 3(a1)
	slli	a0, a0, 8
	or	a4, a0, a2
	sw	a4, 12(s7)
	bge	a5, a4, .LBB111_79
.LBB111_30:                             #   in Loop: Header=BB111_12 Depth=1
	addi	s4, zero, 5
	sw	s4, %lo(nj)(s8)
	addi	a3, zero, 2
	addi	s5, zero, 5
	addi	s3, zero, 5
	addi	a6, zero, 5
	addi	a0, zero, 5
	j	.LBB111_80
.LBB111_31:                             #   in Loop: Header=BB111_12 Depth=1
	bge	t4, a3, .LBB111_11
# %bb.32:                               #   in Loop: Header=BB111_12 Depth=1
	lbu	a0, 2(a1)
	lbu	a2, 3(a1)
	slli	a0, a0, 8
	or	a4, a0, a2
	sw	a4, 12(s7)
	blt	a5, a4, .LBB111_11
# %bb.33:                               #   in Loop: Header=BB111_12 Depth=1
	addi	a5, a1, 4
	sw	a5, 4(s7)
	addi	a0, a3, -4
	sw	a0, 8(s7)
	addi	a0, a4, -2
	sw	a0, 12(s7)
	add	s5, zero, s4
	add	s3, zero, s4
	add	a6, zero, s4
	add	a0, zero, s4
	bnez	s4, .LBB111_12
# %bb.34:                               #   in Loop: Header=BB111_12 Depth=1
	bgeu	t5, a4, .LBB111_11
# %bb.35:                               #   in Loop: Header=BB111_12 Depth=1
	lbu	a0, 0(a5)
	bne	a0, t2, .LBB111_94
# %bb.36:                               #   in Loop: Header=BB111_12 Depth=1
	lbu	a0, 5(a1)
	lbu	a2, 6(a1)
	slli	a0, a0, 8
	or	s2, a0, a2
	sw	s2, 20(s7)
	lb	a0, 7(a1)
	lbu	a2, 8(a1)
	slli	a0, a0, 8
	or	a0, a0, a2
	and	s10, a0, t3
	snez	a0, s10
	snez	a2, s2
	and	a0, a0, a2
	sw	s10, 16(s7)
	beqz	a0, .LBB111_11
# %bb.37:                               #   in Loop: Header=BB111_12 Depth=1
	addi	s6, zero, 1
	lbu	a2, 9(a1)
	sw	a2, 40(s7)
	addi	a0, a1, 10
	sw	a0, 4(s7)
	addi	a0, zero, 9
	addi	t1, a3, -10
	sw	t1, 8(s7)
	addi	a6, a4, -8
	sw	a6, 12(s7)
	blt	a0, a3, .LBB111_96
# %bb.38:                               #   in Loop: Header=BB111_12 Depth=1
	addi	s4, zero, 5
	sw	s4, %lo(nj)(s8)
	j	.LBB111_97
.LBB111_39:                             #   in Loop: Header=BB111_12 Depth=1
	bge	t4, a3, .LBB111_11
# %bb.40:                               #   in Loop: Header=BB111_12 Depth=1
	lbu	a0, 2(a1)
	lbu	a2, 3(a1)
	slli	a0, a0, 8
	or	s0, a0, a2
	sw	s0, 12(s7)
	blt	a5, s0, .LBB111_11
# %bb.41:                               #   in Loop: Header=BB111_12 Depth=1
	addi	a4, a1, 4
	sw	a4, 4(s7)
	addi	s1, a3, -4
	sw	s1, 8(s7)
	addi	a3, s0, -2
	sw	a3, 12(s7)
	add	a6, zero, s3
	add	a0, zero, s3
	bnez	s3, .LBB111_12
# %bb.42:                               #   in Loop: Header=BB111_12 Depth=1
	mv	s3, zero
	mv	a6, zero
	addi	a0, zero, 67
	bltu	s0, a0, .LBB111_83
# %bb.43:                               #   in Loop: Header=BB111_12 Depth=1
	addi	a0, a1, 5
	addi	s2, zero, 129
	j	.LBB111_74
.LBB111_44:                             #   in Loop: Header=BB111_12 Depth=1
	bge	t4, a3, .LBB111_11
# %bb.45:                               #   in Loop: Header=BB111_12 Depth=1
	lbu	a0, 2(a1)
	lbu	a2, 3(a1)
	slli	a0, a0, 8
	or	a4, a0, a2
	sw	a4, 12(s7)
	blt	a5, a4, .LBB111_11
# %bb.46:                               #   in Loop: Header=BB111_12 Depth=1
	addi	s6, a1, 4
	sw	s6, 4(s7)
	addi	s10, a3, -4
	sw	s10, 8(s7)
	addi	s2, a4, -2
	sw	s2, 12(s7)
	add	s3, zero, s5
	add	a6, zero, s5
	add	a0, zero, s5
	bnez	s5, .LBB111_12
# %bb.47:                               #   in Loop: Header=BB111_12 Depth=1
	mv	s5, zero
	mv	s3, zero
	addi	a0, zero, 19
	bltu	a4, a0, .LBB111_67
.LBB111_48:                             #   Parent Loop BB111_12 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB111_55 Depth 3
                                        #         Child Loop BB111_60 Depth 4
                                        #           Child Loop BB111_62 Depth 5
                                        #       Child Loop BB111_65 Depth 3
	lbu	a0, 0(s6)
	andi	a1, a0, 236
	bnez	a1, .LBB111_11
# %bb.49:                               #   in Loop: Header=BB111_48 Depth=2
	andi	a1, a0, 2
	bnez	a1, .LBB111_94
# %bb.50:                               #   in Loop: Header=BB111_48 Depth=2
	add	s1, zero, t3
	srli	a1, a0, 3
	or	s0, a1, a0
	addi	a1, s6, 1
	addi	a2, zero, 16
	lw	a0, 88(sp)
	call	memcpy
	andi	a0, s0, 3
	addi	s6, s6, 17
	sw	s6, 4(s7)
	addi	a1, s10, -17
	sw	a1, 8(s7)
	addi	s2, s2, -17
	sw	s2, 12(s7)
	addi	a2, zero, 16
	blt	a2, s10, .LBB111_52
# %bb.51:                               #   in Loop: Header=BB111_48 Depth=2
	addi	s4, zero, 5
	sw	s4, %lo(nj)(s8)
	addi	s5, zero, 5
	addi	s3, zero, 5
.LBB111_52:                             #   in Loop: Header=BB111_48 Depth=2
	slli	a0, a0, 17
	add	a0, a0, s7
	addi	a0, a0, 440
	lui	s0, 16
	addi	a3, zero, 1
	add	s10, zero, a1
	lui	a6, 16
	addi	t6, zero, 2
	addi	ra, zero, 255
	addi	t0, zero, 192
	addi	t4, zero, 3
	addi	t5, zero, 10
	addi	t2, zero, 8
	add	t3, zero, s1
	addi	t1, zero, 1
	lui	a7, 128
	j	.LBB111_55
.LBB111_53:                             #   in Loop: Header=BB111_55 Depth=3
	add	s6, s6, a4
	sw	s6, 4(s7)
	sub	s10, s10, a4
	sw	s10, 8(s7)
	sub	s2, s2, a4
	sw	s2, 12(s7)
	addi	a1, zero, -1
	bge	a1, s10, .LBB111_63
.LBB111_54:                             #   in Loop: Header=BB111_55 Depth=3
	addi	a3, a3, 1
	addi	a1, zero, 17
	beq	a3, a1, .LBB111_64
.LBB111_55:                             #   Parent Loop BB111_12 Depth=1
                                        #     Parent Loop BB111_48 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB111_60 Depth 4
                                        #           Child Loop BB111_62 Depth 5
	lw	a1, 88(sp)
	add	a1, a1, a3
	lbu	a4, -1(a1)
	srai	s0, s0, 1
	beqz	a4, .LBB111_54
# %bb.56:                               #   in Loop: Header=BB111_55 Depth=3
	blt	s2, a4, .LBB111_11
# %bb.57:                               #   in Loop: Header=BB111_55 Depth=3
	addi	a1, zero, 16
	sub	a1, a1, a3
	sll	a1, a4, a1
	sub	a6, a6, a1
	bltz	a6, .LBB111_11
# %bb.58:                               #   in Loop: Header=BB111_55 Depth=3
	mv	a5, zero
	seqz	s1, s0
	j	.LBB111_60
.LBB111_59:                             #   in Loop: Header=BB111_60 Depth=4
	addi	a5, a5, 1
	beq	a5, a4, .LBB111_53
.LBB111_60:                             #   Parent Loop BB111_12 Depth=1
                                        #     Parent Loop BB111_48 Depth=2
                                        #       Parent Loop BB111_55 Depth=3
                                        # =>      This Loop Header: Depth=4
                                        #           Child Loop BB111_62 Depth 5
	bnez	s1, .LBB111_59
# %bb.61:                               #   in Loop: Header=BB111_60 Depth=4
	add	a1, s6, a5
	lbu	a1, 0(a1)
	add	a2, zero, s0
.LBB111_62:                             #   Parent Loop BB111_12 Depth=1
                                        #     Parent Loop BB111_48 Depth=2
                                        #       Parent Loop BB111_55 Depth=3
                                        #         Parent Loop BB111_60 Depth=4
                                        # =>        This Inner Loop Header: Depth=5
	sb	a3, 0(a0)
	sb	a1, 1(a0)
	addi	a2, a2, -1
	addi	a0, a0, 2
	bnez	a2, .LBB111_62
	j	.LBB111_59
.LBB111_63:                             #   in Loop: Header=BB111_55 Depth=3
	addi	s4, zero, 5
	sw	s4, %lo(nj)(s8)
	addi	s5, zero, 5
	addi	s3, zero, 5
	j	.LBB111_54
.LBB111_64:                             #   in Loop: Header=BB111_48 Depth=2
	beqz	a6, .LBB111_66
.LBB111_65:                             #   Parent Loop BB111_12 Depth=1
                                        #     Parent Loop BB111_48 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	addi	a6, a6, -1
	sb	zero, 0(a0)
	addi	a0, a0, 2
	bnez	a6, .LBB111_65
.LBB111_66:                             #   in Loop: Header=BB111_48 Depth=2
	addi	a0, zero, 17
	bge	s2, a0, .LBB111_48
.LBB111_67:                             #   in Loop: Header=BB111_12 Depth=1
	add	a6, zero, s3
	add	a0, zero, s3
	beqz	s2, .LBB111_12
	j	.LBB111_11
.LBB111_68:                             #   in Loop: Header=BB111_12 Depth=1
	bge	t4, a3, .LBB111_11
# %bb.69:                               #   in Loop: Header=BB111_12 Depth=1
	lbu	a0, 2(a1)
	lbu	a2, 3(a1)
	slli	a0, a0, 8
	or	a4, a0, a2
	sw	a4, 12(s7)
	blt	a5, a4, .LBB111_11
# %bb.70:                               #   in Loop: Header=BB111_12 Depth=1
	addi	a0, a1, 4
	sw	a0, 4(s7)
	addi	a3, a3, -4
	sw	a3, 8(s7)
	addi	a5, a4, -2
	sw	a5, 12(s7)
	add	a0, zero, a6
	bnez	a6, .LBB111_12
# %bb.71:                               #   in Loop: Header=BB111_12 Depth=1
	bgeu	t4, a4, .LBB111_11
# %bb.72:                               #   in Loop: Header=BB111_12 Depth=1
	lbu	a2, 4(a1)
	lbu	a1, 5(a1)
	mv	a6, zero
	mv	a0, zero
	slli	a2, a2, 8
	or	a1, a1, a2
	addi	a2, a7, 704
	add	a2, a2, s7
	sw	a1, 0(a2)
	add	a1, s0, a4
	sw	a1, 4(s7)
	sub	a1, a3, a5
	j	.LBB111_81
.LBB111_73:                             #   in Loop: Header=BB111_74 Depth=2
	addi	a0, a0, 65
	add	s1, zero, a5
	bge	s2, a1, .LBB111_83
.LBB111_74:                             #   Parent Loop BB111_12 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB111_76 Depth 3
	lbu	a5, 0(a4)
	andi	s0, a5, 252
	bnez	s0, .LBB111_11
# %bb.75:                               #   in Loop: Header=BB111_74 Depth=2
	add	a1, zero, a3
	lw	s0, 180(s7)
	mv	a3, zero
	sll	a2, t1, a5
	or	a2, a2, s0
	sw	a2, 180(s7)
	slli	a2, a5, 6
	add	a2, a2, s7
	addi	a5, a2, 184
.LBB111_76:                             #   Parent Loop BB111_12 Depth=1
                                        #     Parent Loop BB111_74 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	add	a2, a0, a3
	lb	a2, 0(a2)
	addi	s0, a3, 1
	add	a3, a3, a5
	sb	a2, 0(a3)
	add	a3, zero, s0
	bne	s0, s11, .LBB111_76
# %bb.77:                               #   in Loop: Header=BB111_74 Depth=2
	addi	a4, a4, 65
	sw	a4, 4(s7)
	addi	a5, s1, -65
	sw	a5, 8(s7)
	addi	a3, a1, -65
	sw	a3, 12(s7)
	blt	s11, s1, .LBB111_73
# %bb.78:                               #   in Loop: Header=BB111_74 Depth=2
	addi	s4, zero, 5
	sw	s4, %lo(nj)(s8)
	addi	s5, zero, 5
	addi	s3, zero, 5
	addi	a6, zero, 5
	j	.LBB111_73
.LBB111_79:                             #   in Loop: Header=BB111_12 Depth=1
	mv	a0, zero
	addi	a2, a1, 4
	sw	a2, 4(s7)
	addi	a5, a3, -4
	sw	a5, 8(s7)
	addi	a4, a4, -2
	sw	a4, 12(s7)
	addi	a3, zero, 4
.LBB111_80:                             #   in Loop: Header=BB111_12 Depth=1
	add	a1, a1, a3
	add	a1, a1, a4
	sw	a1, 4(s7)
	sub	a1, a5, a4
.LBB111_81:                             #   in Loop: Header=BB111_12 Depth=1
	sw	a1, 8(s7)
	sw	zero, 12(s7)
.LBB111_82:                             #   in Loop: Header=BB111_12 Depth=1
	addi	a2, zero, -1
	blt	a2, a1, .LBB111_12
	j	.LBB111_11
.LBB111_83:                             #   in Loop: Header=BB111_12 Depth=1
	add	a0, zero, a6
	beqz	a3, .LBB111_12
	j	.LBB111_11
.LBB111_84:                             #   in Loop: Header=BB111_12 Depth=1
	lbu	a0, 0(a4)
	bne	a7, a0, .LBB111_104
# %bb.85:                               #   in Loop: Header=BB111_12 Depth=1
	addi	a2, a1, 5
	sw	a2, 4(s7)
	addi	a0, a3, -5
	sw	a0, 8(s7)
	addi	a6, s0, -3
	sw	a6, 12(s7)
	addi	a4, zero, 4
	addi	s5, zero, 5
	blt	a4, a3, .LBB111_87
# %bb.86:                               #   in Loop: Header=BB111_12 Depth=1
	sw	s5, 0(s7)
.LBB111_87:                             #   in Loop: Header=BB111_12 Depth=1
	lbu	a4, 0(a2)
	blt	a7, t1, .LBB111_101
# %bb.88:                               #   in Loop: Header=BB111_12 Depth=1
	add	s6, zero, s1
	addi	s3, zero, 1
	add	s2, zero, t3
	mv	a5, zero
	addi	t0, s0, -5
	addi	t1, a3, -5
	addi	t2, a3, -7
	addi	t3, zero, 7
	addi	a2, s7, 44
	add	a0, zero, a7
	j	.LBB111_90
.LBB111_89:                             #   in Loop: Header=BB111_90 Depth=2
	lbu	a4, 0(a4)
	addi	a5, a5, -2
	addi	t3, t3, 2
	addi	a0, a0, -1
	addi	a2, a2, 44
	beqz	a0, .LBB111_100
.LBB111_90:                             #   Parent Loop BB111_12 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lw	s1, 0(a2)
	andi	a4, a4, 255
	bne	s1, a4, .LBB111_95
# %bb.91:                               #   in Loop: Header=BB111_90 Depth=2
	add	a4, a1, t3
	lbu	s1, -1(a4)
	andi	s0, s1, 238
	bnez	s0, .LBB111_95
# %bb.92:                               #   in Loop: Header=BB111_90 Depth=2
	srli	s1, s1, 4
	sw	s1, 32(a2)
	lbu	s1, -1(a4)
	add	s0, t1, a5
	andi	s1, s1, 1
	ori	s1, s1, 2
	sw	s1, 28(a2)
	sw	a4, 4(s7)
	add	s1, t2, a5
	sw	s1, 8(s7)
	add	s1, t0, a5
	sw	s1, 12(s7)
	blt	s3, s0, .LBB111_89
# %bb.93:                               #   in Loop: Header=BB111_90 Depth=2
	sw	s5, 0(s7)
	j	.LBB111_89
.LBB111_94:                             #   in Loop: Header=BB111_12 Depth=1
	addi	s4, zero, 2
	sw	s4, %lo(nj)(s8)
	addi	s5, zero, 2
	addi	s3, zero, 2
	addi	a6, zero, 2
	addi	a0, zero, 2
	j	.LBB111_12
.LBB111_95:                             #   in Loop: Header=BB111_12 Depth=1
	addi	s4, zero, 5
	sw	s4, %lo(nj)(s8)
	addi	s5, zero, 5
	addi	s3, zero, 5
	addi	a6, zero, 5
	addi	a0, zero, 5
	addi	t0, zero, 192
	addi	t2, zero, 8
	add	t3, zero, s2
	j	.LBB111_123
.LBB111_96:                             #   in Loop: Header=BB111_12 Depth=1
	mv	s4, zero
.LBB111_97:                             #   in Loop: Header=BB111_12 Depth=1
	ori	a0, a2, 2
	bne	a0, t4, .LBB111_105
# %bb.98:                               #   in Loop: Header=BB111_12 Depth=1
	mul	a0, a2, t4
	bge	a6, a0, .LBB111_106
# %bb.99:                               #   in Loop: Header=BB111_12 Depth=1
	addi	s4, zero, 5
	sw	s4, %lo(nj)(s8)
	addi	s5, zero, 5
	addi	s3, zero, 5
	addi	a6, zero, 5
	addi	a0, zero, 5
	addi	t1, zero, 1
	j	.LBB111_12
.LBB111_100:                            #   in Loop: Header=BB111_12 Depth=1
	add	a6, a6, a5
	add	a0, a3, a5
	addi	a0, a0, -5
	sub	a1, a1, a5
	addi	a2, a1, 5
	addi	t0, zero, 192
	addi	t2, zero, 8
	add	t3, zero, s2
	addi	t1, zero, 1
	add	s1, zero, s6
.LBB111_101:                            #   in Loop: Header=BB111_12 Depth=1
	bnez	a4, .LBB111_104
# %bb.102:                              #   in Loop: Header=BB111_12 Depth=1
	lbu	a1, 1(a2)
	addi	a3, zero, 63
	bne	a1, a3, .LBB111_104
# %bb.103:                              #   in Loop: Header=BB111_12 Depth=1
	lbu	a1, 2(a2)
	beqz	a1, .LBB111_124
.LBB111_104:                            #   in Loop: Header=BB111_12 Depth=1
	addi	s4, zero, 2
	sw	s4, %lo(nj)(s8)
	addi	s5, zero, 2
	addi	s3, zero, 2
	addi	a6, zero, 2
	addi	a0, zero, 2
	lui	a7, 128
	j	.LBB111_12
.LBB111_105:                            #   in Loop: Header=BB111_12 Depth=1
	addi	s4, zero, 2
	sw	s4, %lo(nj)(s8)
	addi	s5, zero, 2
	addi	s3, zero, 2
	addi	a6, zero, 2
	addi	a0, zero, 2
	addi	t1, zero, 1
	j	.LBB111_12
.LBB111_106:                            #   in Loop: Header=BB111_12 Depth=1
	sw	t3, 40(sp)
	mv	a5, zero
	mv	t2, zero
	mv	t3, zero
	sw	a2, 52(sp)
	add	t4, zero, a2
	addi	a7, a4, -11
	addi	t0, a3, -13
	addi	t5, zero, 10
	addi	a2, s7, 44
	sw	t4, 48(sp)
	j	.LBB111_108
.LBB111_107:                            #   in Loop: Header=BB111_108 Depth=2
	addi	a5, a5, -3
	addi	t5, t5, 3
	addi	t4, t4, -1
	addi	a2, a2, 44
	add	t2, zero, s3
	add	t3, zero, s5
	beqz	t4, .LBB111_222
.LBB111_108:                            #   Parent Loop BB111_12 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	add	s0, a1, t5
	lbu	s1, 0(s0)
	sw	s1, 0(a2)
	lbu	s1, 1(s0)
	srli	s5, s1, 4
	sw	s5, 4(a2)
	beqz	s5, .LBB111_119
# %bb.109:                              #   in Loop: Header=BB111_108 Depth=2
	addi	s1, s5, -1
	and	s1, s1, s5
	bnez	s1, .LBB111_120
# %bb.110:                              #   in Loop: Header=BB111_108 Depth=2
	lbu	s1, 1(s0)
	andi	s3, s1, 15
	sw	s3, 8(a2)
	beqz	s3, .LBB111_119
# %bb.111:                              #   in Loop: Header=BB111_108 Depth=2
	addi	s1, s3, -1
	and	s1, s1, s3
	bnez	s1, .LBB111_120
# %bb.112:                              #   in Loop: Header=BB111_108 Depth=2
	lbu	s1, 2(s0)
	andi	a0, s1, 252
	sw	s1, 24(a2)
	bnez	a0, .LBB111_119
# %bb.113:                              #   in Loop: Header=BB111_108 Depth=2
	add	a0, t1, a5
	addi	s0, s0, 3
	sw	s0, 4(s7)
	add	s0, t0, a5
	sw	s0, 8(s7)
	add	s0, a7, a5
	sw	s0, 12(s7)
	blt	t6, a0, .LBB111_115
# %bb.114:                              #   in Loop: Header=BB111_108 Depth=2
	addi	s4, zero, 5
	sw	s4, %lo(nj)(s8)
.LBB111_115:                            #   in Loop: Header=BB111_108 Depth=2
	lw	a0, 176(s7)
	sll	s1, s6, s1
	or	a0, a0, s1
	sw	a0, 176(s7)
	bltu	t3, s5, .LBB111_117
# %bb.116:                              #   in Loop: Header=BB111_108 Depth=2
	add	s5, zero, t3
.LBB111_117:                            #   in Loop: Header=BB111_108 Depth=2
	bltu	t2, s3, .LBB111_107
# %bb.118:                              #   in Loop: Header=BB111_108 Depth=2
	add	s3, zero, t2
	j	.LBB111_107
.LBB111_119:                            #   in Loop: Header=BB111_12 Depth=1
	addi	s4, zero, 5
	sw	s4, %lo(nj)(s8)
	addi	s5, zero, 5
	addi	s3, zero, 5
	addi	a6, zero, 5
	addi	a0, zero, 5
	j	.LBB111_121
.LBB111_120:                            #   in Loop: Header=BB111_12 Depth=1
	addi	s4, zero, 2
	sw	s4, %lo(nj)(s8)
	addi	s5, zero, 2
	addi	s3, zero, 2
	addi	a6, zero, 2
	addi	a0, zero, 2
.LBB111_121:                            #   in Loop: Header=BB111_12 Depth=1
	addi	t0, zero, 192
	addi	t4, zero, 3
.LBB111_122:                            #   in Loop: Header=BB111_12 Depth=1
	addi	t5, zero, 10
	addi	t2, zero, 8
	lw	t3, 40(sp)
.LBB111_123:                            #   in Loop: Header=BB111_12 Depth=1
	addi	t1, zero, 1
	lui	a7, 128
	j	.LBB111_12
.LBB111_124:                            #   in Loop: Header=BB111_12 Depth=1
	add	a1, a2, a6
	sw	a1, 4(s7)
	sub	a0, a0, a6
	sw	a0, 8(s7)
	sw	zero, 12(s7)
	addi	a1, zero, -1
	addi	s5, zero, 5
	blt	a1, a0, .LBB111_126
# %bb.125:                              #   in Loop: Header=BB111_12 Depth=1
	sw	s5, 0(s7)
.LBB111_126:                            #   in Loop: Header=BB111_12 Depth=1
	sw	zero, 32(sp)
	sw	zero, 24(sp)
	sw	zero, 12(sp)
	sw	t3, 40(sp)
.LBB111_127:                            #   Parent Loop BB111_12 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB111_129 Depth 3
                                        #         Child Loop BB111_131 Depth 4
                                        #           Child Loop BB111_133 Depth 5
                                        #             Child Loop BB111_146 Depth 6
                                        #             Child Loop BB111_165 Depth 6
                                        #             Child Loop BB111_170 Depth 6
	blt	a7, t1, .LBB111_213
# %bb.128:                              #   in Loop: Header=BB111_127 Depth=2
	sw	zero, 20(sp)
	addi	s0, s7, 44
	sw	s1, 16(sp)
.LBB111_129:                            #   Parent Loop BB111_12 Depth=1
                                        #     Parent Loop BB111_127 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB111_131 Depth 4
                                        #           Child Loop BB111_133 Depth 5
                                        #             Child Loop BB111_146 Depth 6
                                        #             Child Loop BB111_165 Depth 6
                                        #             Child Loop BB111_170 Depth 6
	lw	a1, 8(s0)
	blt	a1, t1, .LBB111_212
# %bb.130:                              #   in Loop: Header=BB111_129 Depth=3
	lw	a2, 4(s0)
	sw	zero, 28(sp)
	lui	a7, 128
	sw	s0, 60(sp)
.LBB111_131:                            #   Parent Loop BB111_12 Depth=1
                                        #     Parent Loop BB111_127 Depth=2
                                        #       Parent Loop BB111_129 Depth=3
                                        # =>      This Loop Header: Depth=4
                                        #           Child Loop BB111_133 Depth 5
                                        #             Child Loop BB111_146 Depth 6
                                        #             Child Loop BB111_165 Depth 6
                                        #             Child Loop BB111_170 Depth 6
	blt	a2, t1, .LBB111_210
# %bb.132:                              #   in Loop: Header=BB111_131 Depth=4
	sw	zero, 36(sp)
.LBB111_133:                            #   Parent Loop BB111_12 Depth=1
                                        #     Parent Loop BB111_127 Depth=2
                                        #       Parent Loop BB111_129 Depth=3
                                        #         Parent Loop BB111_131 Depth=4
                                        # =>        This Loop Header: Depth=5
                                        #             Child Loop BB111_146 Depth 6
                                        #             Child Loop BB111_165 Depth 6
                                        #             Child Loop BB111_170 Depth 6
	sw	a2, 56(sp)
	sw	a1, 64(sp)
	lw	a0, 40(s0)
	sw	a0, 52(sp)
	lw	a0, 20(s0)
	sw	a0, 48(sp)
	addi	a0, a7, 448
	sw	a0, 68(sp)
	add	s2, s7, a0
	addi	a2, zero, 256
	add	a0, zero, s2
	mv	a1, zero
	lui	s4, 128
	call	memset
	lw	s0, 32(s0)
	addi	a0, zero, 16
	call	njShowBits
	slli	a1, s0, 17
	slli	a0, a0, 1
	add	a0, a0, a1
	add	s1, s7, a0
	lbu	s3, 440(s1)
	beqz	s3, .LBB111_141
# %bb.134:                              #   in Loop: Header=BB111_133 Depth=5
	addi	a0, s4, 444
	add	s0, s7, a0
	lw	a0, 0(s0)
	bge	a0, s3, .LBB111_136
# %bb.135:                              #   in Loop: Header=BB111_133 Depth=5
	add	a0, zero, s3
	call	njShowBits
	lw	a0, 0(s0)
.LBB111_136:                            #   in Loop: Header=BB111_133 Depth=5
	sub	a0, a0, s3
	sw	a0, 0(s0)
	lbu	a0, 441(s1)
	andi	s3, a0, 15
	lw	s6, 76(sp)
	beqz	s3, .LBB111_142
# %bb.137:                              #   in Loop: Header=BB111_133 Depth=5
	add	a0, zero, s3
	call	njShowBits
	lw	a1, 0(s0)
	add	s1, zero, a0
	bge	a1, s3, .LBB111_139
# %bb.138:                              #   in Loop: Header=BB111_133 Depth=5
	add	a0, zero, s3
	call	njShowBits
	lw	a1, 0(s0)
.LBB111_139:                            #   in Loop: Header=BB111_133 Depth=5
	sub	a0, a1, s3
	addi	a1, s3, -1
	addi	a2, zero, 1
	sll	a1, a2, a1
	sw	a0, 0(s0)
	blt	s1, a1, .LBB111_143
# %bb.140:                              #   in Loop: Header=BB111_133 Depth=5
	mv	a0, zero
	j	.LBB111_144
.LBB111_141:                            #   in Loop: Header=BB111_133 Depth=5
	mv	a0, zero
	sw	s5, %lo(nj)(s8)
	lw	s6, 76(sp)
	lw	s3, 60(sp)
	j	.LBB111_145
.LBB111_142:                            #   in Loop: Header=BB111_133 Depth=5
	mv	a0, zero
	lw	s3, 60(sp)
	j	.LBB111_145
.LBB111_143:                            #   in Loop: Header=BB111_133 Depth=5
	addi	a0, zero, -1
	sll	a0, a0, s3
	ori	a0, a0, 1
.LBB111_144:                            #   in Loop: Header=BB111_133 Depth=5
	lw	s3, 60(sp)
	add	a0, a0, s1
.LBB111_145:                            #   in Loop: Header=BB111_133 Depth=5
	lw	a1, 36(s3)
	lw	a2, 24(s3)
	add	a0, a0, a1
	sw	a0, 36(s3)
	slli	a1, a2, 6
	add	a1, a1, s7
	lbu	a1, 184(a1)
	mv	s5, zero
	mv	s0, zero
	mul	a0, a0, a1
	sw	a0, 0(s2)
.LBB111_146:                            #   Parent Loop BB111_12 Depth=1
                                        #     Parent Loop BB111_127 Depth=2
                                        #       Parent Loop BB111_129 Depth=3
                                        #         Parent Loop BB111_131 Depth=4
                                        #           Parent Loop BB111_133 Depth=5
                                        # =>          This Inner Loop Header: Depth=6
	lw	s1, 28(s3)
	addi	a0, zero, 16
	call	njShowBits
	slli	a1, s1, 17
	slli	a0, a0, 1
	add	a0, a0, a1
	add	s1, s7, a0
	lbu	s2, 440(s1)
	beqz	s2, .LBB111_154
# %bb.147:                              #   in Loop: Header=BB111_146 Depth=6
	lui	a7, 128
	addi	a0, a7, 444
	add	s4, s7, a0
	lw	a0, 0(s4)
	bge	a0, s2, .LBB111_149
# %bb.148:                              #   in Loop: Header=BB111_146 Depth=6
	add	a0, zero, s2
	call	njShowBits
	lui	a7, 128
	lw	a0, 0(s4)
.LBB111_149:                            #   in Loop: Header=BB111_146 Depth=6
	sub	a0, a0, s2
	sw	a0, 0(s4)
	lbu	s5, 441(s1)
	andi	s3, s5, 15
	beqz	s3, .LBB111_155
# %bb.150:                              #   in Loop: Header=BB111_146 Depth=6
	add	a0, zero, s3
	call	njShowBits
	lw	a1, 0(s4)
	add	s2, zero, a0
	bge	a1, s3, .LBB111_152
# %bb.151:                              #   in Loop: Header=BB111_146 Depth=6
	add	a0, zero, s3
	call	njShowBits
	lw	a1, 0(s4)
.LBB111_152:                            #   in Loop: Header=BB111_146 Depth=6
	sub	a0, a1, s3
	addi	a1, s3, -1
	addi	t1, zero, 1
	sll	a1, t1, a1
	sw	a0, 0(s4)
	blt	s2, a1, .LBB111_156
# %bb.153:                              #   in Loop: Header=BB111_146 Depth=6
	mv	a0, zero
	j	.LBB111_157
.LBB111_154:                            #   in Loop: Header=BB111_146 Depth=6
	mv	a0, zero
	addi	a1, zero, 5
	sw	a1, %lo(nj)(s8)
	addi	t6, zero, 2
	addi	ra, zero, 255
	addi	t0, zero, 192
	addi	t4, zero, 3
	addi	t5, zero, 10
	addi	t2, zero, 8
	lw	t3, 40(sp)
	addi	t1, zero, 1
	lui	a7, 128
	j	.LBB111_158
.LBB111_155:                            #   in Loop: Header=BB111_146 Depth=6
	mv	a0, zero
	addi	t6, zero, 2
	addi	ra, zero, 255
	addi	t0, zero, 192
	addi	t4, zero, 3
	addi	t5, zero, 10
	addi	t2, zero, 8
	lw	t3, 40(sp)
	addi	t1, zero, 1
	lw	s3, 60(sp)
	j	.LBB111_158
.LBB111_156:                            #   in Loop: Header=BB111_146 Depth=6
	addi	a0, zero, -1
	sll	a0, a0, s3
	ori	a0, a0, 1
.LBB111_157:                            #   in Loop: Header=BB111_146 Depth=6
	addi	t6, zero, 2
	addi	ra, zero, 255
	addi	t0, zero, 192
	addi	t4, zero, 3
	addi	t5, zero, 10
	addi	t2, zero, 8
	lw	t3, 40(sp)
	lui	a7, 128
	lw	s3, 60(sp)
	add	a0, a0, s2
.LBB111_158:                            #   in Loop: Header=BB111_146 Depth=6
	andi	a1, s5, 255
	beqz	a1, .LBB111_162
# %bb.159:                              #   in Loop: Header=BB111_146 Depth=6
	andi	a2, s5, 15
	snez	a2, a2
	addi	a1, a1, -240
	seqz	a1, a1
	or	a1, a1, a2
	beqz	a1, .LBB111_11
# %bb.160:                              #   in Loop: Header=BB111_146 Depth=6
	andi	a1, s5, 240
	srli	a1, a1, 4
	add	a1, a1, s0
	addi	s0, a1, 1
	bgeu	s0, s11, .LBB111_11
# %bb.161:                              #   in Loop: Header=BB111_146 Depth=6
	lw	a1, 24(s3)
	slli	a1, a1, 6
	add	a1, a1, s0
	add	a1, a1, s7
	lbu	a1, 184(a1)
	add	a2, s0, s6
	lbu	a2, 0(a2)
	mul	a0, a0, a1
	slli	a1, a2, 2
	add	a1, a1, s7
	lw	a2, 68(sp)
	add	a1, a1, a2
	sw	a0, 0(a1)
	addi	a0, zero, 63
	bne	s0, a0, .LBB111_146
.LBB111_162:                            #   in Loop: Header=BB111_133 Depth=5
	addi	t0, zero, -8
	addi	a1, a7, 476
	add	a1, a1, s7
	addi	s2, zero, 5
	addi	t5, zero, 56
	j	.LBB111_165
.LBB111_163:                            #   in Loop: Header=BB111_165 Depth=6
	slli	a0, a3, 11
	ori	t3, a0, 128
	add	a3, s0, a2
	addi	a0, zero, 565
	mul	a3, a3, a0
	lw	a4, 80(sp)
	mul	a2, a2, a4
	add	t1, a3, a2
	lw	a0, 84(sp)
	addi	a2, a0, 611
	mul	a2, s0, a2
	add	t2, a3, a2
	add	a3, s1, a5
	addi	s0, a4, 132
	mul	a3, a3, s0
	addi	a2, zero, -799
	mul	a5, a5, a2
	add	a5, a5, a3
	mul	s1, s1, a0
	add	a3, a3, s1
	add	s1, t3, t4
	sub	t3, t3, t4
	add	a4, a7, a6
	addi	a2, zero, 1108
	mul	a4, a4, a2
	addi	s0, a0, 233
	mul	s0, a6, s0
	add	s0, s0, a4
	addi	a0, zero, 1568
	mul	a2, a7, a0
	add	a2, a2, a4
	add	a6, a5, t1
	sub	a5, t1, a5
	addi	t1, zero, 1
	add	a4, a3, t2
	sub	a3, t2, a3
	add	a7, s1, a2
	sub	a2, s1, a2
	add	s1, t3, s0
	sub	a0, t3, s0
	add	s0, a5, a3
	addi	t2, zero, 181
	mul	s0, s0, t2
	addi	s0, s0, 128
	srai	s0, s0, 8
	sub	a3, a5, a3
	mul	a3, a3, t2
	addi	a3, a3, 128
	srai	a3, a3, 8
	add	a5, a7, a6
	srai	a5, a5, 8
	sw	a5, -28(a1)
	add	a5, s0, s1
	srai	a5, a5, 8
	sw	a5, -24(a1)
	add	a5, a3, a0
	srai	a5, a5, 8
	sw	a5, -20(a1)
	add	a5, a2, a4
	srai	a5, a5, 8
	sw	a5, -16(a1)
	sub	a2, a2, a4
	srai	a2, a2, 8
	sw	a2, -12(a1)
	sub	a0, a0, a3
	srai	a0, a0, 8
	sw	a0, -8(a1)
	sub	a0, s1, s0
	srai	a0, a0, 8
	sw	a0, -4(a1)
	sub	a0, a7, a6
	srai	a0, a0, 8
	sw	a0, 0(a1)
.LBB111_164:                            #   in Loop: Header=BB111_165 Depth=6
	addi	t0, t0, 8
	addi	a1, a1, 32
	bgeu	t0, t5, .LBB111_167
.LBB111_165:                            #   Parent Loop BB111_12 Depth=1
                                        #     Parent Loop BB111_127 Depth=2
                                        #       Parent Loop BB111_129 Depth=3
                                        #         Parent Loop BB111_131 Depth=4
                                        #           Parent Loop BB111_133 Depth=5
                                        # =>          This Inner Loop Header: Depth=6
	lw	a2, -12(a1)
	lw	a6, -4(a1)
	lw	a7, -20(a1)
	slli	t4, a2, 11
	lw	a2, -24(a1)
	or	a3, t4, a6
	or	a3, a3, a7
	lw	s0, 0(a1)
	or	a3, a3, a2
	lw	a5, -8(a1)
	lw	s1, -16(a1)
	or	a0, a3, s0
	lw	a3, -28(a1)
	or	a0, a0, a5
	or	a0, a0, s1
	bnez	a0, .LBB111_163
# %bb.166:                              #   in Loop: Header=BB111_165 Depth=6
	slli	a0, a3, 3
	sw	a0, 0(a1)
	sw	a0, -4(a1)
	sw	a0, -8(a1)
	sw	a0, -12(a1)
	sw	a0, -16(a1)
	sw	a0, -20(a1)
	sw	a0, -24(a1)
	sw	a0, -28(a1)
	j	.LBB111_164
.LBB111_167:                            #   in Loop: Header=BB111_133 Depth=5
	mv	t5, zero
	lw	a0, 32(sp)
	lw	a1, 56(sp)
	mul	a1, a0, a1
	lw	a0, 36(sp)
	add	a1, a1, a0
	lw	a0, 24(sp)
	lw	a2, 64(sp)
	mul	a2, a0, a2
	lw	a0, 28(sp)
	add	a2, a2, a0
	lw	a0, 48(sp)
	mul	a2, a0, a2
	add	a1, a1, a2
	slli	a1, a1, 3
	lw	a0, 52(sp)
	add	t2, a0, a1
	lui	a0, 128
	addi	a1, a0, 672
	add	t3, s7, a1
	j	.LBB111_170
.LBB111_168:                            #   in Loop: Header=BB111_170 Depth=6
	xori	a1, a1, 128
	sb	a1, 0(a3)
	addi	s2, zero, 5
.LBB111_169:                            #   in Loop: Header=BB111_170 Depth=6
	addi	t5, t5, 1
	addi	t3, t3, 4
	addi	a0, zero, 8
	beq	t5, a0, .LBB111_208
.LBB111_170:                            #   Parent Loop BB111_12 Depth=1
                                        #     Parent Loop BB111_127 Depth=2
                                        #       Parent Loop BB111_129 Depth=3
                                        #         Parent Loop BB111_131 Depth=4
                                        #           Parent Loop BB111_133 Depth=5
                                        # =>          This Inner Loop Header: Depth=6
	add	s3, t2, t5
	lw	a1, -96(t3)
	lw	a7, -32(t3)
	lw	a6, -160(t3)
	lw	a0, 60(sp)
	lw	a4, 20(a0)
	slli	t0, a1, 8
	or	a1, t0, a7
	or	a5, a1, a6
	lw	a3, -192(t3)
	lw	a1, 0(t3)
	lw	s0, -64(t3)
	lw	s1, -128(t3)
	or	a5, a5, a3
	or	a5, a5, a1
	or	a5, a5, s0
	or	a2, a5, s1
	lw	a5, -224(t3)
	add	s4, t5, a4
	slli	t4, a4, 1
	addi	a0, zero, 3
	mul	a0, a4, a0
	sw	a0, 64(sp)
	slli	a0, a4, 2
	sw	a0, 68(sp)
	mul	s6, a4, s2
	addi	a0, zero, 6
	mul	s5, a4, a0
	addi	a0, zero, 7
	mul	a0, a4, a0
	beqz	a2, .LBB111_203
# %bb.171:                              #   in Loop: Header=BB111_170 Depth=6
	sw	s6, 48(sp)
	sw	s5, 52(sp)
	sw	a0, 56(sp)
	slli	a2, a5, 8
	lui	a0, 2
	add	t6, a2, a0
	add	a4, a1, a3
	addi	a0, zero, 565
	mul	a4, a4, a0
	addi	a4, a4, 4
	lw	a2, 80(sp)
	mul	a3, a3, a2
	add	a3, a3, a4
	srai	a3, a3, 3
	lw	a0, 84(sp)
	addi	a5, a0, 611
	mul	a1, a1, a5
	add	a1, a1, a4
	srai	ra, a1, 3
	add	a1, s1, s0
	addi	a4, a2, 132
	mul	a1, a1, a4
	ori	a1, a1, 4
	addi	a2, zero, -799
	mul	a4, s0, a2
	add	a4, a4, a1
	srai	a5, a4, 3
	mul	a4, s1, a0
	add	a1, a1, a4
	srai	s6, a1, 3
	add	t1, t6, t0
	sub	t0, t6, t0
	add	a1, a6, a7
	addi	a2, zero, 1108
	mul	a1, a1, a2
	addi	a1, a1, 4
	addi	a2, a0, 233
	mul	a2, a7, a2
	add	a2, a2, a1
	srai	a4, a2, 3
	addi	a0, zero, 1568
	mul	a2, a6, a0
	add	a1, a1, a2
	srai	a7, a1, 3
	add	s0, a5, a3
	sub	a1, a3, a5
	sub	a3, ra, s6
	add	a2, t1, a7
	add	a5, a1, a3
	addi	a0, zero, 181
	mul	s1, a5, a0
	sub	a5, a1, a3
	sw	s0, 44(sp)
	add	a1, s0, a2
	srai	a3, a1, 14
	addi	s5, zero, 127
	addi	a1, s1, 128
	blt	a3, s5, .LBB111_173
# %bb.172:                              #   in Loop: Header=BB111_170 Depth=6
	addi	a3, zero, 127
.LBB111_173:                            #   in Loop: Header=BB111_170 Depth=6
	addi	a0, zero, 181
	mul	a5, a5, a0
	add	t6, t0, a4
	addi	a6, zero, -128
	srai	s2, a1, 8
	blt	a6, a3, .LBB111_175
# %bb.174:                              #   in Loop: Header=BB111_170 Depth=6
	addi	a3, zero, -128
.LBB111_175:                            #   in Loop: Header=BB111_170 Depth=6
	addi	a1, a5, 128
	xori	a3, a3, 128
	add	a5, s2, t6
	srai	s1, a5, 14
	sb	a3, 0(s3)
	lw	s3, 56(sp)
	blt	s1, s5, .LBB111_177
# %bb.176:                              #   in Loop: Header=BB111_170 Depth=6
	addi	s1, zero, 127
.LBB111_177:                            #   in Loop: Header=BB111_170 Depth=6
	sub	a3, t0, a4
	srai	a5, a1, 8
	add	a1, t2, s4
	blt	a6, s1, .LBB111_179
# %bb.178:                              #   in Loop: Header=BB111_170 Depth=6
	addi	s1, zero, -128
.LBB111_179:                            #   in Loop: Header=BB111_170 Depth=6
	xori	a4, s1, 128
	sb	a4, 0(a1)
	add	a1, a5, a3
	srai	a1, a1, 14
	add	s0, t5, t4
	blt	a1, s5, .LBB111_181
# %bb.180:                              #   in Loop: Header=BB111_170 Depth=6
	addi	a1, zero, 127
.LBB111_181:                            #   in Loop: Header=BB111_170 Depth=6
	add	a4, s6, ra
	sub	s1, t1, a7
	add	s0, s0, t2
	blt	a6, a1, .LBB111_183
# %bb.182:                              #   in Loop: Header=BB111_170 Depth=6
	addi	a1, zero, -128
.LBB111_183:                            #   in Loop: Header=BB111_170 Depth=6
	xori	a1, a1, 128
	sb	a1, 0(s0)
	add	a1, a4, s1
	srai	a1, a1, 14
	lw	a0, 64(sp)
	add	s0, t5, a0
	addi	ra, zero, 255
	addi	t1, zero, 1
	lui	a7, 128
	lw	a0, 48(sp)
	blt	a1, s5, .LBB111_185
# %bb.184:                              #   in Loop: Header=BB111_170 Depth=6
	addi	a1, zero, 127
.LBB111_185:                            #   in Loop: Header=BB111_170 Depth=6
	add	s0, s0, t2
	addi	t4, zero, 3
	blt	a6, a1, .LBB111_187
# %bb.186:                              #   in Loop: Header=BB111_170 Depth=6
	addi	a1, zero, -128
.LBB111_187:                            #   in Loop: Header=BB111_170 Depth=6
	xori	a1, a1, 128
	sb	a1, 0(s0)
	sub	a1, s1, a4
	srai	a1, a1, 14
	lw	a4, 68(sp)
	add	a4, a4, t5
	blt	a1, s5, .LBB111_189
# %bb.188:                              #   in Loop: Header=BB111_170 Depth=6
	addi	a1, zero, 127
.LBB111_189:                            #   in Loop: Header=BB111_170 Depth=6
	add	a4, a4, t2
	blt	a6, a1, .LBB111_191
# %bb.190:                              #   in Loop: Header=BB111_170 Depth=6
	addi	a1, zero, -128
.LBB111_191:                            #   in Loop: Header=BB111_170 Depth=6
	xori	a1, a1, 128
	sb	a1, 0(a4)
	sub	a1, a3, a5
	srai	a1, a1, 14
	add	a3, t5, a0
	blt	a1, s5, .LBB111_193
# %bb.192:                              #   in Loop: Header=BB111_170 Depth=6
	addi	a1, zero, 127
.LBB111_193:                            #   in Loop: Header=BB111_170 Depth=6
	add	a3, a3, t2
	blt	a6, a1, .LBB111_195
# %bb.194:                              #   in Loop: Header=BB111_170 Depth=6
	addi	a1, zero, -128
.LBB111_195:                            #   in Loop: Header=BB111_170 Depth=6
	xori	a1, a1, 128
	sb	a1, 0(a3)
	sub	a1, t6, s2
	srai	a1, a1, 14
	lw	a3, 52(sp)
	add	a3, a3, t5
	blt	a1, s5, .LBB111_197
# %bb.196:                              #   in Loop: Header=BB111_170 Depth=6
	addi	a1, zero, 127
.LBB111_197:                            #   in Loop: Header=BB111_170 Depth=6
	add	a3, a3, t2
	addi	t6, zero, 2
	blt	a6, a1, .LBB111_199
# %bb.198:                              #   in Loop: Header=BB111_170 Depth=6
	addi	a1, zero, -128
.LBB111_199:                            #   in Loop: Header=BB111_170 Depth=6
	xori	a1, a1, 128
	sb	a1, 0(a3)
	lw	a0, 44(sp)
	sub	a1, a2, a0
	srai	a1, a1, 14
	add	a3, t5, s3
	blt	a1, s5, .LBB111_201
# %bb.200:                              #   in Loop: Header=BB111_170 Depth=6
	addi	a1, zero, 127
.LBB111_201:                            #   in Loop: Header=BB111_170 Depth=6
	add	a3, a3, t2
	blt	a6, a1, .LBB111_168
# %bb.202:                              #   in Loop: Header=BB111_170 Depth=6
	addi	a1, zero, -128
	j	.LBB111_168
.LBB111_203:                            #   in Loop: Header=BB111_170 Depth=6
	addi	a1, a5, 32
	srai	a1, a1, 6
	addi	a2, zero, 127
	blt	a1, a2, .LBB111_205
# %bb.204:                              #   in Loop: Header=BB111_170 Depth=6
	addi	a1, zero, 127
.LBB111_205:                            #   in Loop: Header=BB111_170 Depth=6
	addi	a2, zero, -128
	lui	a7, 128
	blt	a2, a1, .LBB111_207
# %bb.206:                              #   in Loop: Header=BB111_170 Depth=6
	addi	a1, zero, -128
.LBB111_207:                            #   in Loop: Header=BB111_170 Depth=6
	xori	a1, a1, -128
	sb	a1, 0(s3)
	add	a2, t2, s4
	sb	a1, 0(a2)
	add	a2, t5, t4
	add	a2, a2, t2
	sb	a1, 0(a2)
	lw	a2, 64(sp)
	add	a2, a2, t5
	add	a2, a2, t2
	sb	a1, 0(a2)
	lw	a2, 68(sp)
	add	a2, a2, t5
	add	a2, a2, t2
	sb	a1, 0(a2)
	add	a2, t5, s6
	add	a2, a2, t2
	sb	a1, 0(a2)
	add	a2, t5, s5
	add	a2, a2, t2
	sb	a1, 0(a2)
	add	a2, t5, a0
	add	a2, a2, t2
	sb	a1, 0(a2)
	addi	t4, zero, 3
	j	.LBB111_169
.LBB111_208:                            #   in Loop: Header=BB111_133 Depth=5
	lw	s4, %lo(nj)(s8)
	add	s5, zero, s4
	add	s3, zero, s4
	add	a6, zero, s4
	add	a0, zero, s4
	addi	t0, zero, 192
	addi	t5, zero, 10
	addi	t2, zero, 8
	lw	t3, 40(sp)
	lw	s1, 16(sp)
	bnez	s4, .LBB111_12
# %bb.209:                              #   in Loop: Header=BB111_133 Depth=5
	lw	s0, 60(sp)
	lw	a2, 4(s0)
	lw	a1, 8(s0)
	lw	a0, 36(sp)
	addi	a0, a0, 1
	addi	s5, zero, 5
	sw	a0, 36(sp)
	blt	a0, a2, .LBB111_133
.LBB111_210:                            #   in Loop: Header=BB111_131 Depth=4
	lw	a0, 28(sp)
	addi	a0, a0, 1
	sw	a0, 28(sp)
	blt	a0, a1, .LBB111_131
# %bb.211:                              #   in Loop: Header=BB111_129 Depth=3
	lui	s4, 128
	lw	a7, 40(s7)
	addi	t6, zero, 2
	addi	ra, zero, 255
	addi	t0, zero, 192
	addi	t4, zero, 3
	addi	t5, zero, 10
	addi	t2, zero, 8
	lw	t3, 40(sp)
.LBB111_212:                            #   in Loop: Header=BB111_129 Depth=3
	lw	a0, 20(sp)
	addi	a0, a0, 1
	addi	s0, s0, 44
	sw	a0, 20(sp)
	blt	a0, a7, .LBB111_129
.LBB111_213:                            #   in Loop: Header=BB111_127 Depth=2
	lw	a0, 24(s7)
	lw	a1, 32(sp)
	addi	a1, a1, 1
	sw	a1, 32(sp)
	blt	a1, a0, .LBB111_216
# %bb.214:                              #   in Loop: Header=BB111_127 Depth=2
	lw	a0, 28(s7)
	lw	a1, 24(sp)
	addi	a1, a1, 1
	sw	a1, 24(sp)
	bge	a1, a0, .LBB111_235
# %bb.215:                              #   in Loop: Header=BB111_127 Depth=2
	sw	zero, 32(sp)
.LBB111_216:                            #   in Loop: Header=BB111_127 Depth=2
	lw	a0, 0(s10)
	beqz	a0, .LBB111_127
# %bb.217:                              #   in Loop: Header=BB111_127 Depth=2
	addi	s1, s1, -1
	bnez	s1, .LBB111_127
# %bb.218:                              #   in Loop: Header=BB111_127 Depth=2
	add	s6, zero, t3
	addi	a0, s4, 444
	add	s0, s7, a0
	lw	a0, 0(s0)
	andi	a0, a0, 248
	sw	a0, 0(s0)
	addi	a0, zero, 16
	call	njShowBits
	lw	a1, 0(s0)
	add	s2, zero, a0
	addi	a0, zero, 15
	blt	a0, a1, .LBB111_220
# %bb.219:                              #   in Loop: Header=BB111_127 Depth=2
	addi	a0, zero, 16
	call	njShowBits
	lw	a1, 0(s0)
.LBB111_220:                            #   in Loop: Header=BB111_127 Depth=2
	addi	a0, a1, -16
	lui	a2, 16
	addi	a1, a2, -8
	and	a1, s2, a1
	addi	a2, a2, -48
	xor	a1, a1, a2
	andi	a2, s2, 7
	lw	a3, 12(sp)
	xor	a2, a2, a3
	or	a1, a1, a2
	sw	a0, 0(s0)
	bnez	a1, .LBB111_236
# %bb.221:                              #   in Loop: Header=BB111_127 Depth=2
	lw	a0, 12(sp)
	addi	a0, a0, 1
	lw	s1, 0(s10)
	sw	zero, 80(s7)
	lw	a7, 40(s7)
	sw	zero, 124(s7)
	sw	zero, 168(s7)
	andi	a0, a0, 7
	sw	a0, 12(sp)
	addi	t6, zero, 2
	addi	ra, zero, 255
	addi	t0, zero, 192
	addi	t4, zero, 3
	addi	t5, zero, 10
	addi	t2, zero, 8
	add	t3, zero, s6
	addi	t1, zero, 1
	addi	s5, zero, 5
	j	.LBB111_127
.LBB111_222:                            #   in Loop: Header=BB111_12 Depth=1
	add	a2, a4, a5
	add	a0, a3, a5
	sub	a1, a1, a5
	addi	t1, zero, 1
	lw	a3, 52(sp)
	bne	a3, t1, .LBB111_224
# %bb.223:                              #   in Loop: Header=BB111_12 Depth=1
	addi	s5, zero, 1
	sw	s5, 52(s7)
	sw	s5, 48(s7)
	addi	s3, zero, 1
.LBB111_224:                            #   in Loop: Header=BB111_12 Depth=1
	addi	a2, a2, -5
	sw	a2, 44(sp)
	add	s6, a6, a5
	addi	a0, a0, -10
	sw	a0, 36(sp)
	addi	a0, a1, 7
	sw	a0, 32(sp)
	slli	a0, s5, 3
	sw	a0, 32(s7)
	slli	a1, s3, 3
	sw	a1, 36(s7)
	add	a2, s10, a0
	addi	a2, a2, -1
	div	a0, a2, a0
	sw	a0, 24(s7)
	add	a2, s2, a1
	addi	a2, a2, -1
	div	a1, a2, a1
	sw	a1, 28(s7)
	addi	a2, s5, -1
	sw	a2, 68(sp)
	addi	a2, s3, -1
	sw	a2, 64(sp)
	slli	a0, a0, 3
	sw	a0, 60(sp)
	slli	a0, a1, 3
	sw	a0, 56(sp)
	addi	s0, s7, 48
	addi	t0, zero, 192
	addi	t5, zero, 10
	lw	t3, 40(sp)
	lui	a7, 128
	lw	s1, 48(sp)
.LBB111_225:                            #   Parent Loop BB111_12 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lw	a3, 0(s0)
	mul	a1, a3, s10
	lw	a0, 4(s0)
	lw	a2, 68(sp)
	add	a1, a1, a2
	div	a4, a1, s5
	sw	a4, 8(s0)
	mul	a1, a0, s2
	lw	a2, 64(sp)
	add	a1, a1, a2
	div	a2, a1, s3
	sw	a2, 12(s0)
	lw	a1, 60(sp)
	mul	a1, a3, a1
	slti	a4, a4, 3
	xor	a3, a3, s5
	snez	a3, a3
	and	a3, a3, a4
	sw	a1, 16(s0)
	bnez	a3, .LBB111_232
# %bb.226:                              #   in Loop: Header=BB111_225 Depth=2
	slt	a2, t6, a2
	xor	a3, a0, s3
	seqz	a3, a3
	or	a2, a2, a3
	beqz	a2, .LBB111_232
# %bb.227:                              #   in Loop: Header=BB111_225 Depth=2
	lw	a2, 56(sp)
	mul	a1, a2, a1
	mul	a0, a1, a0
	call	malloc
	sw	a0, 36(s0)
	beqz	a0, .LBB111_233
# %bb.228:                              #   in Loop: Header=BB111_225 Depth=2
	addi	s1, s1, -1
	addi	s0, s0, 44
	addi	t6, zero, 2
	addi	t0, zero, 192
	addi	t5, zero, 10
	lw	t3, 40(sp)
	addi	t1, zero, 1
	lui	a7, 128
	bnez	s1, .LBB111_225
# %bb.229:                              #   in Loop: Header=BB111_12 Depth=1
	addi	t4, zero, 3
	lw	a0, 52(sp)
	bne	a0, t4, .LBB111_231
# %bb.230:                              #   in Loop: Header=BB111_12 Depth=1
	mul	a0, s2, s10
	mul	a0, a0, t4
	call	malloc
	addi	t4, zero, 3
	lw	a1, 72(sp)
	add	a1, a1, s7
	sw	a0, 0(a1)
	beqz	a0, .LBB111_234
.LBB111_231:                            #   in Loop: Header=BB111_12 Depth=1
	lw	a0, 44(sp)
	lw	a1, 32(sp)
	add	a0, a0, a1
	sw	a0, 4(s7)
	lw	a0, 36(sp)
	sub	a1, a0, s6
	sw	a1, 8(s7)
	sw	zero, 12(s7)
	add	s5, zero, s4
	add	s3, zero, s4
	add	a6, zero, s4
	add	a0, zero, s4
	addi	t6, zero, 2
	addi	ra, zero, 255
	addi	t0, zero, 192
	addi	t5, zero, 10
	addi	t2, zero, 8
	lw	t3, 40(sp)
	addi	t1, zero, 1
	lui	a7, 128
	j	.LBB111_82
.LBB111_232:                            #   in Loop: Header=BB111_12 Depth=1
	addi	s4, zero, 2
	sw	s4, %lo(nj)(s8)
	addi	s5, zero, 2
	addi	s3, zero, 2
	addi	a6, zero, 2
	addi	a0, zero, 2
	addi	ra, zero, 255
	addi	t4, zero, 3
	addi	t2, zero, 8
	j	.LBB111_12
.LBB111_233:                            #   in Loop: Header=BB111_12 Depth=1
	addi	s4, zero, 3
	sw	s4, %lo(nj)(s8)
	addi	s5, zero, 3
	addi	s3, zero, 3
	addi	a6, zero, 3
	addi	a0, zero, 3
	addi	t6, zero, 2
	addi	ra, zero, 255
	j	.LBB111_121
.LBB111_234:                            #   in Loop: Header=BB111_12 Depth=1
	addi	s4, zero, 3
	sw	s4, %lo(nj)(s8)
	addi	s5, zero, 3
	addi	s3, zero, 3
	addi	a6, zero, 3
	addi	a0, zero, 3
	addi	t6, zero, 2
	addi	ra, zero, 255
	addi	t0, zero, 192
	j	.LBB111_122
.LBB111_235:                            #   in Loop: Header=BB111_12 Depth=1
	addi	s4, zero, 6
	sw	s4, %lo(nj)(s8)
	addi	s5, zero, 6
	addi	s3, zero, 6
	addi	a6, zero, 6
	addi	a0, zero, 6
	lui	a7, 128
	j	.LBB111_12
.LBB111_236:                            #   in Loop: Header=BB111_12 Depth=1
	addi	s4, zero, 5
	sw	s4, %lo(nj)(s8)
	addi	s5, zero, 5
	addi	s3, zero, 5
	addi	a6, zero, 5
	addi	a0, zero, 5
	addi	t6, zero, 2
	addi	ra, zero, 255
	addi	t0, zero, 192
	addi	t4, zero, 3
	addi	t5, zero, 10
	addi	t2, zero, 8
	add	t3, zero, s6
	j	.LBB111_123
.LBB111_237:
	addi	a1, zero, 6
	bne	a0, a1, .LBB111_341
# %bb.238:
	lui	a0, %hi(nj)
	sw	zero, %lo(nj)(a0)
	addi	a4, a0, %lo(nj)
	lw	a0, 40(a4)
	addi	a1, zero, 1
	blt	a0, a1, .LBB111_335
# %bb.239:
	mv	a1, zero
	sw	zero, 64(sp)
	addi	s9, a4, 44
	addi	s4, zero, -3
	addi	s6, zero, -9
	addi	s2, zero, 111
	addi	s5, zero, 29
	sw	a4, 68(sp)
	j	.LBB111_241
.LBB111_240:                            #   in Loop: Header=BB111_241 Depth=1
	mv	a1, zero
	bnez	zero, .LBB111_340
.LBB111_241:                            # =>This Loop Header: Depth=1
                                        #     Child Loop BB111_246 Depth 2
                                        #       Child Loop BB111_261 Depth 3
                                        #     Child Loop BB111_291 Depth 2
                                        #       Child Loop BB111_306 Depth 3
	lw	s7, 12(s9)
	lw	a2, 16(a4)
	lw	s8, 16(s9)
	bge	s7, a2, .LBB111_281
# %bb.242:                              #   in Loop: Header=BB111_241 Depth=1
	slli	s0, s7, 1
	mul	a0, s8, s0
	call	malloc
	beqz	a0, .LBB111_331
# %bb.243:                              #   in Loop: Header=BB111_241 Depth=1
	add	s11, zero, a0
	beqz	s8, .LBB111_284
# %bb.244:                              #   in Loop: Header=BB111_241 Depth=1
	lw	t1, 40(s9)
	addi	a0, zero, 3
	slt	a7, a0, s7
	addi	a6, s7, -3
	add	t0, zero, s11
	addi	t2, zero, 139
	addi	t3, zero, -11
	addi	t4, zero, 104
	addi	t5, zero, 27
	addi	t6, zero, 28
	addi	s3, zero, 109
	j	.LBB111_246
.LBB111_245:                            #   in Loop: Header=BB111_246 Depth=2
	addi	s8, s8, -1
	sb	a1, -1(t0)
	beqz	s8, .LBB111_283
.LBB111_246:                            #   Parent Loop BB111_241 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB111_261 Depth 3
	lbu	a1, 0(t1)
	lbu	a2, 1(t1)
	mul	a1, a1, t2
	mul	a2, a2, t3
	add	a1, a1, a2
	addi	a1, a1, 64
	srai	a4, a1, 7
	addi	a2, zero, 255
	blt	a4, a2, .LBB111_248
# %bb.247:                              #   in Loop: Header=BB111_246 Depth=2
	addi	a4, zero, 255
.LBB111_248:                            #   in Loop: Header=BB111_246 Depth=2
	bgtz	a4, .LBB111_250
# %bb.249:                              #   in Loop: Header=BB111_246 Depth=2
	mv	a4, zero
.LBB111_250:                            #   in Loop: Header=BB111_246 Depth=2
	sb	a4, 0(t0)
	lbu	a1, 0(t1)
	lbu	a4, 1(t1)
	lbu	a5, 2(t1)
	mul	a1, a1, t4
	mul	a4, a4, t5
	mul	a5, a5, s4
	add	a1, a1, a4
	add	a1, a1, a5
	addi	a1, a1, 64
	srai	a1, a1, 7
	blt	a1, a2, .LBB111_252
# %bb.251:                              #   in Loop: Header=BB111_246 Depth=2
	addi	a1, zero, 255
.LBB111_252:                            #   in Loop: Header=BB111_246 Depth=2
	bgtz	a1, .LBB111_254
# %bb.253:                              #   in Loop: Header=BB111_246 Depth=2
	mv	a1, zero
.LBB111_254:                            #   in Loop: Header=BB111_246 Depth=2
	sb	a1, 1(t0)
	lbu	a1, 0(t1)
	lbu	a4, 1(t1)
	lbu	a5, 2(t1)
	mul	a1, a1, t6
	mul	a4, a4, s3
	mul	a5, a5, s6
	add	a1, a1, a4
	add	a1, a1, a5
	addi	a1, a1, 64
	srai	a1, a1, 7
	blt	a1, a2, .LBB111_257
# %bb.255:                              #   in Loop: Header=BB111_246 Depth=2
	addi	a1, zero, 255
	blez	a1, .LBB111_258
.LBB111_256:                            #   in Loop: Header=BB111_246 Depth=2
	sb	a1, 2(t0)
	bnez	a7, .LBB111_259
	j	.LBB111_269
.LBB111_257:                            #   in Loop: Header=BB111_246 Depth=2
	bgtz	a1, .LBB111_256
.LBB111_258:                            #   in Loop: Header=BB111_246 Depth=2
	mv	a1, zero
	sb	a1, 2(t0)
	beqz	a7, .LBB111_269
.LBB111_259:                            #   in Loop: Header=BB111_246 Depth=2
	addi	a4, t0, 4
	addi	a5, t1, 3
	add	a2, zero, a6
	j	.LBB111_261
.LBB111_260:                            #   in Loop: Header=BB111_261 Depth=3
	sb	a1, 0(a4)
	addi	a2, a2, -1
	addi	a4, a4, 2
	addi	a5, a5, 1
	beqz	a2, .LBB111_269
.LBB111_261:                            #   Parent Loop BB111_241 Depth=1
                                        #     Parent Loop BB111_246 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	lbu	a1, -3(a5)
	lbu	s0, -2(a5)
	lbu	s1, -1(a5)
	lbu	a3, 0(a5)
	mul	a1, a1, s6
	mul	s0, s0, s2
	mul	s1, s1, s5
	mul	a3, a3, s4
	add	a1, a1, s0
	add	a1, a1, s1
	add	a1, a1, a3
	addi	a1, a1, 64
	srai	a1, a1, 7
	addi	s0, zero, 255
	blt	a1, s0, .LBB111_263
# %bb.262:                              #   in Loop: Header=BB111_261 Depth=3
	addi	a1, zero, 255
.LBB111_263:                            #   in Loop: Header=BB111_261 Depth=3
	bgtz	a1, .LBB111_265
# %bb.264:                              #   in Loop: Header=BB111_261 Depth=3
	mv	a1, zero
.LBB111_265:                            #   in Loop: Header=BB111_261 Depth=3
	sb	a1, -1(a4)
	lbu	a1, -3(a5)
	lbu	a3, -2(a5)
	lbu	s1, -1(a5)
	lbu	a0, 0(a5)
	mul	a1, a1, s4
	mul	a3, a3, s5
	mul	s1, s1, s2
	mul	a0, a0, s6
	add	a1, a1, a3
	add	a1, a1, s1
	add	a0, a0, a1
	addi	a0, a0, 64
	srai	a1, a0, 7
	blt	a1, s0, .LBB111_267
# %bb.266:                              #   in Loop: Header=BB111_261 Depth=3
	addi	a1, zero, 255
.LBB111_267:                            #   in Loop: Header=BB111_261 Depth=3
	bgtz	a1, .LBB111_260
# %bb.268:                              #   in Loop: Header=BB111_261 Depth=3
	mv	a1, zero
	j	.LBB111_260
.LBB111_269:                            #   in Loop: Header=BB111_246 Depth=2
	lw	a0, 20(s9)
	add	t1, t1, a0
	lbu	a0, -1(t1)
	lbu	a1, -2(t1)
	lbu	a2, -3(t1)
	lw	a3, 12(s9)
	mul	a0, a0, t6
	mul	a1, a1, s3
	mul	a2, a2, s6
	add	a0, a0, a1
	add	a0, a0, a2
	addi	a0, a0, 64
	srai	a4, a0, 7
	addi	a2, zero, 255
	slli	a1, a3, 1
	blt	a4, a2, .LBB111_271
# %bb.270:                              #   in Loop: Header=BB111_246 Depth=2
	addi	a4, zero, 255
.LBB111_271:                            #   in Loop: Header=BB111_246 Depth=2
	add	t0, t0, a1
	bgtz	a4, .LBB111_273
# %bb.272:                              #   in Loop: Header=BB111_246 Depth=2
	mv	a4, zero
.LBB111_273:                            #   in Loop: Header=BB111_246 Depth=2
	sb	a4, -3(t0)
	lbu	a0, -1(t1)
	lbu	a1, -2(t1)
	lbu	a3, -3(t1)
	mul	a0, a0, t4
	mul	a1, a1, t5
	mul	a3, a3, s4
	add	a0, a0, a1
	add	a0, a0, a3
	addi	a0, a0, 64
	srai	a1, a0, 7
	blt	a1, a2, .LBB111_275
# %bb.274:                              #   in Loop: Header=BB111_246 Depth=2
	addi	a1, zero, 255
.LBB111_275:                            #   in Loop: Header=BB111_246 Depth=2
	bgtz	a1, .LBB111_277
# %bb.276:                              #   in Loop: Header=BB111_246 Depth=2
	mv	a1, zero
.LBB111_277:                            #   in Loop: Header=BB111_246 Depth=2
	sb	a1, -2(t0)
	lbu	a0, -1(t1)
	lbu	a1, -2(t1)
	mul	a0, a0, t2
	mul	a1, a1, t3
	add	a0, a0, a1
	addi	a0, a0, 64
	srai	a1, a0, 7
	blt	a1, a2, .LBB111_279
# %bb.278:                              #   in Loop: Header=BB111_246 Depth=2
	addi	a1, zero, 255
.LBB111_279:                            #   in Loop: Header=BB111_246 Depth=2
	bgtz	a1, .LBB111_245
# %bb.280:                              #   in Loop: Header=BB111_246 Depth=2
	mv	a1, zero
	j	.LBB111_245
.LBB111_281:                            #   in Loop: Header=BB111_241 Depth=1
	lw	a0, 20(a4)
	blt	s8, a0, .LBB111_285
# %bb.282:                              #   in Loop: Header=BB111_241 Depth=1
	lw	a3, 40(a4)
	lw	a5, 64(sp)
	addi	a5, a5, 1
	addi	s9, s9, 44
	sw	a5, 64(sp)
	blt	a5, a3, .LBB111_241
	j	.LBB111_332
.LBB111_283:                            #   in Loop: Header=BB111_241 Depth=1
	lw	a0, 12(s9)
	slli	s0, a0, 1
.LBB111_284:                            #   in Loop: Header=BB111_241 Depth=1
	lw	a0, 40(s9)
	sw	s0, 12(s9)
	sw	s0, 20(s9)
	call	free
	sw	s11, 40(s9)
	lui	a0, %hi(nj)
	lw	a1, %lo(nj)(a0)
	lw	a4, 68(sp)
.LBB111_285:                            #   in Loop: Header=BB111_241 Depth=1
	bnez	a1, .LBB111_340
# %bb.286:                              #   in Loop: Header=BB111_241 Depth=1
	lw	s10, 16(s9)
	lw	a0, 20(a4)
	bge	s10, a0, .LBB111_240
# %bb.287:                              #   in Loop: Header=BB111_241 Depth=1
	lw	s7, 12(s9)
	lw	s8, 20(s9)
	slli	s0, s10, 1
	mul	a0, s7, s0
	call	malloc
	sw	a0, 88(sp)
	beqz	a0, .LBB111_331
# %bb.288:                              #   in Loop: Header=BB111_241 Depth=1
	addi	a0, zero, 1
	blt	s7, a0, .LBB111_329
# %bb.289:                              #   in Loop: Header=BB111_241 Depth=1
	mv	t4, zero
	slli	t2, s8, 1
	neg	a0, t2
	sw	a0, 84(sp)
	slli	a0, s7, 2
	lw	a2, 88(sp)
	add	a0, a0, a2
	sw	a0, 80(sp)
	slli	t3, s7, 1
	addi	a1, zero, 3
	mul	a0, s7, a1
	add	a0, a0, a2
	sw	a0, 76(sp)
	mul	a0, s8, a1
	sw	a0, 72(sp)
	addi	a6, zero, 139
	addi	a7, zero, -11
	addi	t0, zero, 104
	addi	t6, zero, 27
	addi	s3, zero, 28
	addi	s11, zero, 109
	j	.LBB111_291
.LBB111_290:                            #   in Loop: Header=BB111_291 Depth=2
	lw	s10, 16(s9)
	addi	t4, t4, 1
	sb	a1, 0(a0)
	beq	t4, s7, .LBB111_328
.LBB111_291:                            #   Parent Loop BB111_241 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB111_306 Depth 3
	lw	t5, 40(s9)
	add	a2, t5, t4
	lbu	a0, 0(a2)
	add	a3, a2, s8
	lbu	a1, 0(a3)
	mul	a0, a0, a6
	mul	a1, a1, a7
	add	a0, a0, a1
	addi	a0, a0, 64
	srai	a4, a0, 7
	addi	a1, zero, 255
	blt	a4, a1, .LBB111_293
# %bb.292:                              #   in Loop: Header=BB111_291 Depth=2
	addi	a4, zero, 255
.LBB111_293:                            #   in Loop: Header=BB111_291 Depth=2
	lw	a0, 88(sp)
	add	a0, a0, t4
	bgtz	a4, .LBB111_295
# %bb.294:                              #   in Loop: Header=BB111_291 Depth=2
	mv	a4, zero
.LBB111_295:                            #   in Loop: Header=BB111_291 Depth=2
	sb	a4, 0(a0)
	lbu	a5, 0(a2)
	lbu	s1, 0(a3)
	add	a4, a2, t2
	lbu	s0, 0(a4)
	mul	a5, a5, t0
	mul	s1, s1, t6
	mul	s0, s0, s4
	add	a5, a5, s1
	add	a5, a5, s0
	addi	a5, a5, 64
	srai	a5, a5, 7
	blt	a5, a1, .LBB111_297
# %bb.296:                              #   in Loop: Header=BB111_291 Depth=2
	addi	a5, zero, 255
.LBB111_297:                            #   in Loop: Header=BB111_291 Depth=2
	add	a0, a0, s7
	bgtz	a5, .LBB111_299
# %bb.298:                              #   in Loop: Header=BB111_291 Depth=2
	mv	a5, zero
.LBB111_299:                            #   in Loop: Header=BB111_291 Depth=2
	sb	a5, 0(a0)
	lbu	a2, 0(a2)
	lbu	a5, 0(a3)
	lbu	a4, 0(a4)
	mul	a2, a2, s3
	mul	a5, a5, s11
	mul	a4, a4, s6
	add	a2, a2, a5
	add	a2, a2, a4
	addi	a2, a2, 64
	srai	a2, a2, 7
	blt	a2, a1, .LBB111_301
# %bb.300:                              #   in Loop: Header=BB111_291 Depth=2
	addi	a2, zero, 255
.LBB111_301:                            #   in Loop: Header=BB111_291 Depth=2
	add	a0, a0, s7
	bgtz	a2, .LBB111_303
# %bb.302:                              #   in Loop: Header=BB111_291 Depth=2
	mv	a2, zero
.LBB111_303:                            #   in Loop: Header=BB111_291 Depth=2
	addi	t1, s10, -3
	sb	a2, 0(a0)
	beqz	t1, .LBB111_315
# %bb.304:                              #   in Loop: Header=BB111_291 Depth=2
	add	s11, t5, s8
	lw	a0, 72(sp)
	add	a2, t5, a0
	add	a1, t5, t2
	lw	s0, 76(sp)
	lw	a4, 80(sp)
	j	.LBB111_306
.LBB111_305:                            #   in Loop: Header=BB111_306 Depth=3
	sb	a0, 0(s1)
	addi	t1, t1, -1
	add	a4, a4, t3
	add	s0, s0, t3
	add	s11, s11, s8
	add	a2, a2, s8
	add	a1, a1, s8
	add	t5, t5, s8
	beqz	t1, .LBB111_314
.LBB111_306:                            #   Parent Loop BB111_241 Depth=1
                                        #     Parent Loop BB111_291 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	add	t6, s11, t4
	add	s10, t5, t4
	lbu	a0, 0(s10)
	lbu	s1, 0(t6)
	add	t0, a1, t4
	lbu	a5, 0(t0)
	add	s3, a2, t4
	lbu	a3, 0(s3)
	mul	a0, a0, s6
	mul	s1, s1, s2
	mul	a5, a5, s5
	mul	a3, a3, s4
	add	a0, a0, s1
	add	a0, a0, a5
	add	a0, a0, a3
	addi	a0, a0, 64
	srai	a6, a0, 7
	addi	ra, zero, 255
	blt	a6, ra, .LBB111_308
# %bb.307:                              #   in Loop: Header=BB111_306 Depth=3
	addi	a6, zero, 255
.LBB111_308:                            #   in Loop: Header=BB111_306 Depth=3
	add	a7, s0, t4
	bgtz	a6, .LBB111_310
# %bb.309:                              #   in Loop: Header=BB111_306 Depth=3
	mv	a6, zero
.LBB111_310:                            #   in Loop: Header=BB111_306 Depth=3
	sb	a6, 0(a7)
	lbu	a0, 0(s10)
	lbu	a3, 0(t6)
	lbu	a5, 0(t0)
	lbu	s1, 0(s3)
	mul	a0, a0, s4
	mul	a3, a3, s5
	mul	a5, a5, s2
	mul	s1, s1, s6
	add	a0, a0, a3
	add	a0, a0, a5
	add	a0, a0, s1
	addi	a0, a0, 64
	srai	a0, a0, 7
	blt	a0, ra, .LBB111_312
# %bb.311:                              #   in Loop: Header=BB111_306 Depth=3
	addi	a0, zero, 255
.LBB111_312:                            #   in Loop: Header=BB111_306 Depth=3
	add	s1, a4, t4
	bgtz	a0, .LBB111_305
# %bb.313:                              #   in Loop: Header=BB111_306 Depth=3
	mv	a0, zero
	j	.LBB111_305
.LBB111_314:                            #   in Loop: Header=BB111_291 Depth=2
	add	a1, s0, t4
	add	a3, s11, t4
	addi	a6, zero, 139
	addi	a7, zero, -11
	addi	t0, zero, 104
	addi	t6, zero, 27
	addi	s3, zero, 28
	addi	s11, zero, 109
	j	.LBB111_316
.LBB111_315:                            #   in Loop: Header=BB111_291 Depth=2
	add	a1, a0, s7
.LBB111_316:                            #   in Loop: Header=BB111_291 Depth=2
	add	a2, a3, s8
	lbu	a4, 0(a2)
	lbu	a5, 0(a3)
	lw	a0, 84(sp)
	add	a0, a0, a2
	lbu	s1, 0(a0)
	mul	a4, a4, s3
	mul	a5, a5, s11
	mul	s1, s1, s6
	add	a4, a4, a5
	add	a4, a4, s1
	addi	a4, a4, 64
	srai	a5, a4, 7
	addi	a4, zero, 255
	blt	a5, a4, .LBB111_318
# %bb.317:                              #   in Loop: Header=BB111_291 Depth=2
	addi	a5, zero, 255
.LBB111_318:                            #   in Loop: Header=BB111_291 Depth=2
	bgtz	a5, .LBB111_320
# %bb.319:                              #   in Loop: Header=BB111_291 Depth=2
	mv	a5, zero
.LBB111_320:                            #   in Loop: Header=BB111_291 Depth=2
	sb	a5, 0(a1)
	lbu	a5, 0(a2)
	lbu	s1, 0(a3)
	lbu	a0, 0(a0)
	mul	a5, a5, t0
	mul	s1, s1, t6
	mul	a0, a0, s4
	add	a5, a5, s1
	add	a0, a0, a5
	addi	a0, a0, 64
	srai	a5, a0, 7
	blt	a5, a4, .LBB111_322
# %bb.321:                              #   in Loop: Header=BB111_291 Depth=2
	addi	a5, zero, 255
.LBB111_322:                            #   in Loop: Header=BB111_291 Depth=2
	add	a0, a1, s7
	bgtz	a5, .LBB111_324
# %bb.323:                              #   in Loop: Header=BB111_291 Depth=2
	mv	a5, zero
.LBB111_324:                            #   in Loop: Header=BB111_291 Depth=2
	sb	a5, 0(a0)
	lbu	a1, 0(a2)
	lbu	a2, 0(a3)
	mul	a1, a1, a6
	mul	a2, a2, a7
	add	a1, a1, a2
	addi	a1, a1, 64
	srai	a1, a1, 7
	blt	a1, a4, .LBB111_326
# %bb.325:                              #   in Loop: Header=BB111_291 Depth=2
	addi	a1, zero, 255
.LBB111_326:                            #   in Loop: Header=BB111_291 Depth=2
	add	a0, a0, s7
	bgtz	a1, .LBB111_290
# %bb.327:                              #   in Loop: Header=BB111_291 Depth=2
	mv	a1, zero
	j	.LBB111_290
.LBB111_328:                            #   in Loop: Header=BB111_241 Depth=1
	lw	s7, 12(s9)
	slli	s0, s10, 1
.LBB111_329:                            #   in Loop: Header=BB111_241 Depth=1
	lw	a0, 40(s9)
	sw	s0, 16(s9)
	sw	s7, 20(s9)
	call	free
	lw	a0, 88(sp)
	sw	a0, 40(s9)
	lui	a0, %hi(nj)
	lw	a1, %lo(nj)(a0)
	lw	a4, 68(sp)
	beqz	a1, .LBB111_241
	j	.LBB111_340
.LBB111_330:
	addi	a0, zero, 2
	j	.LBB111_341
.LBB111_331:
	lui	a0, %hi(nj)
	addi	a1, zero, 3
	sw	a1, %lo(nj)(a0)
	j	.LBB111_340
.LBB111_332:
	addi	a1, zero, 3
	bne	a3, a1, .LBB111_335
# %bb.333:
	beqz	a0, .LBB111_340
# %bb.334:
	lui	a1, %hi(nj)
	addi	t3, a1, %lo(nj)
	lw	t4, 172(t3)
	lw	t5, 128(t3)
	lw	t6, 84(t3)
	lui	a1, 128
	addi	a1, a1, 708
	add	a1, a1, t3
	lw	a5, 0(a1)
	addi	a6, zero, 1
	addi	a7, zero, 359
	addi	t0, zero, -88
	addi	t1, zero, -183
	addi	t2, zero, 454
	addi	s2, zero, 255
	j	.LBB111_344
.LBB111_335:
	lw	a2, 56(a4)
	lw	a0, 64(a4)
	beq	a2, a0, .LBB111_340
# %bb.336:
	lui	a1, %hi(nj)
	addi	s2, a1, %lo(nj)
	lw	a1, 60(s2)
	addi	s3, a1, -1
	beqz	s3, .LBB111_339
# %bb.337:
	lw	a1, 84(s2)
	add	s0, a1, a2
	add	s1, a1, a0
.LBB111_338:                            # =>This Inner Loop Header: Depth=1
	add	a0, zero, s0
	add	a1, zero, s1
	call	memcpy
	lw	a0, 64(s2)
	lw	a2, 56(s2)
	add	s1, s1, a0
	addi	s3, s3, -1
	add	s0, s0, a2
	bnez	s3, .LBB111_338
.LBB111_339:
	sw	a2, 64(s2)
.LBB111_340:
	lui	a0, %hi(nj)
	lw	a0, %lo(nj)(a0)
.LBB111_341:
	lw	s11, 92(sp)
	lw	s10, 96(sp)
	lw	s9, 100(sp)
	lw	s8, 104(sp)
	lw	s7, 108(sp)
	lw	s6, 112(sp)
	lw	s5, 116(sp)
	lw	s4, 120(sp)
	lw	s3, 124(sp)
	lw	s2, 128(sp)
	lw	s1, 132(sp)
	lw	s0, 136(sp)
	lw	ra, 140(sp)
	addi	sp, sp, 144
	ret
.LBB111_342:                            #   in Loop: Header=BB111_344 Depth=1
	add	a5, zero, a1
.LBB111_343:                            #   in Loop: Header=BB111_344 Depth=1
	lw	a1, 64(t3)
	lw	a3, 108(t3)
	lw	a4, 152(t3)
	add	t6, t6, a1
	add	t5, t5, a3
	addi	a0, a0, -1
	add	t4, t4, a4
	beqz	a0, .LBB111_340
.LBB111_344:                            # =>This Loop Header: Depth=1
                                        #     Child Loop BB111_347 Depth 2
	blt	a2, a6, .LBB111_343
# %bb.345:                              #   in Loop: Header=BB111_344 Depth=1
	mv	s1, zero
	j	.LBB111_347
.LBB111_346:                            #   in Loop: Header=BB111_347 Depth=2
	sb	a2, 2(a5)
	lw	a2, 16(t3)
	addi	a1, a5, 3
	addi	s1, s1, 1
	add	a5, zero, a1
	bge	s1, a2, .LBB111_342
.LBB111_347:                            #   Parent Loop BB111_344 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	add	a1, t6, s1
	lbu	a1, 0(a1)
	add	a2, t4, s1
	lbu	a3, 0(a2)
	slli	a1, a1, 8
	add	a2, t5, s1
	lbu	a2, 0(a2)
	addi	a3, a3, -128
	mul	a4, a3, a7
	ori	s0, a1, 128
	add	a1, a4, s0
	srai	a4, a1, 8
	blt	a4, s2, .LBB111_349
# %bb.348:                              #   in Loop: Header=BB111_347 Depth=2
	addi	a4, zero, 255
.LBB111_349:                            #   in Loop: Header=BB111_347 Depth=2
	addi	a2, a2, -128
	bgtz	a4, .LBB111_351
# %bb.350:                              #   in Loop: Header=BB111_347 Depth=2
	mv	a4, zero
.LBB111_351:                            #   in Loop: Header=BB111_347 Depth=2
	mul	a1, a2, t0
	mul	a3, a3, t1
	add	a1, a1, s0
	add	a1, a1, a3
	srai	a3, a1, 8
	sb	a4, 0(a5)
	blt	a3, s2, .LBB111_353
# %bb.352:                              #   in Loop: Header=BB111_347 Depth=2
	addi	a3, zero, 255
.LBB111_353:                            #   in Loop: Header=BB111_347 Depth=2
	bgtz	a3, .LBB111_355
# %bb.354:                              #   in Loop: Header=BB111_347 Depth=2
	mv	a3, zero
.LBB111_355:                            #   in Loop: Header=BB111_347 Depth=2
	mul	a1, a2, t2
	add	a1, a1, s0
	srai	a2, a1, 8
	sb	a3, 1(a5)
	blt	a2, s2, .LBB111_357
# %bb.356:                              #   in Loop: Header=BB111_347 Depth=2
	addi	a2, zero, 255
.LBB111_357:                            #   in Loop: Header=BB111_347 Depth=2
	bgtz	a2, .LBB111_346
# %bb.358:                              #   in Loop: Header=BB111_347 Depth=2
	mv	a2, zero
	j	.LBB111_346
.Lfunc_end111:
	.size	njDecode, .Lfunc_end111-njDecode
                                        # -- End function
	.section	.text.njGetWidth,"ax",@progbits
	.globl	njGetWidth                      # -- Begin function njGetWidth
	.p2align	1
	.type	njGetWidth,@function
njGetWidth:                             # @njGetWidth
# %bb.0:
	lui	a0, %hi(nj+16)
	lw	a0, %lo(nj+16)(a0)
	ret
.Lfunc_end112:
	.size	njGetWidth, .Lfunc_end112-njGetWidth
                                        # -- End function
	.section	.text.njGetHeight,"ax",@progbits
	.globl	njGetHeight                     # -- Begin function njGetHeight
	.p2align	1
	.type	njGetHeight,@function
njGetHeight:                            # @njGetHeight
# %bb.0:
	lui	a0, %hi(nj+20)
	lw	a0, %lo(nj+20)(a0)
	ret
.Lfunc_end113:
	.size	njGetHeight, .Lfunc_end113-njGetHeight
                                        # -- End function
	.section	.text.njIsColor,"ax",@progbits
	.globl	njIsColor                       # -- Begin function njIsColor
	.p2align	1
	.type	njIsColor,@function
njIsColor:                              # @njIsColor
# %bb.0:
	lui	a0, %hi(nj+40)
	lw	a0, %lo(nj+40)(a0)
	addi	a0, a0, -1
	snez	a0, a0
	ret
.Lfunc_end114:
	.size	njIsColor, .Lfunc_end114-njIsColor
                                        # -- End function
	.section	.text.njGetImage,"ax",@progbits
	.globl	njGetImage                      # -- Begin function njGetImage
	.p2align	1
	.type	njGetImage,@function
njGetImage:                             # @njGetImage
# %bb.0:
	lui	a0, %hi(nj)
	addi	a0, a0, %lo(nj)
	lw	a1, 40(a0)
	addi	a2, zero, 1
	beq	a1, a2, .LBB115_2
# %bb.1:
	lui	a1, 128
	addi	a1, a1, 708
	add	a0, a0, a1
	lw	a0, 0(a0)
	ret
.LBB115_2:
	addi	a0, a0, 84
	lw	a0, 0(a0)
	ret
.Lfunc_end115:
	.size	njGetImage, .Lfunc_end115-njGetImage
                                        # -- End function
	.section	.text.njGetImageSize,"ax",@progbits
	.globl	njGetImageSize                  # -- Begin function njGetImageSize
	.p2align	1
	.type	njGetImageSize,@function
njGetImageSize:                         # @njGetImageSize
# %bb.0:
	lui	a0, %hi(nj)
	addi	a0, a0, %lo(nj)
	lw	a1, 16(a0)
	lw	a2, 20(a0)
	lw	a0, 40(a0)
	mul	a1, a2, a1
	mul	a0, a1, a0
	ret
.Lfunc_end116:
	.size	njGetImageSize, .Lfunc_end116-njGetImageSize
                                        # -- End function
	.section	.text.njShowBits,"ax",@progbits
	.p2align	1                               # -- Begin function njShowBits
	.type	njShowBits,@function
njShowBits:                             # @njShowBits
# %bb.0:
	addi	sp, sp, -16
	sw	s0, 12(sp)
	sw	s1, 8(sp)
	lui	a1, 128
	addi	a2, a1, 444
	lui	t1, %hi(nj)
	addi	t5, t1, %lo(nj)
	add	t3, t5, a2
	lw	a4, 0(t3)
	bge	a4, a0, .LBB117_17
# %bb.1:
	lw	s1, 8(t5)
	addi	a1, a1, 440
	add	t4, t5, a1
	addi	t2, zero, 255
	addi	a6, zero, 5
	addi	a7, zero, 217
	addi	t0, zero, 208
	add	a2, zero, a4
	j	.LBB117_4
.LBB117_2:                              #   in Loop: Header=BB117_4 Depth=1
	add	s1, zero, a5
.LBB117_3:                              #   in Loop: Header=BB117_4 Depth=1
	add	a2, zero, a4
	bge	a4, a0, .LBB117_18
.LBB117_4:                              # =>This Inner Loop Header: Depth=1
	blez	s1, .LBB117_11
# %bb.5:                                #   in Loop: Header=BB117_4 Depth=1
	lw	a1, 4(t5)
	addi	a4, a1, 1
	sw	a4, 4(t5)
	lbu	s0, 0(a1)
	addi	a5, s1, -1
	sw	a5, 8(t5)
	addi	a4, a2, 8
	sw	a4, 0(t3)
	lw	a3, 0(t4)
	slli	a3, a3, 8
	or	t6, a3, s0
	sw	t6, 0(t4)
	bne	s0, t2, .LBB117_2
# %bb.6:                                #   in Loop: Header=BB117_4 Depth=1
	beqz	a5, .LBB117_13
# %bb.7:                                #   in Loop: Header=BB117_4 Depth=1
	addi	a3, a1, 2
	sw	a3, 4(t5)
	lbu	a1, 1(a1)
	addi	s1, s1, -2
	sw	s1, 8(t5)
	beqz	a1, .LBB117_3
# %bb.8:                                #   in Loop: Header=BB117_4 Depth=1
	beq	a1, t2, .LBB117_3
# %bb.9:                                #   in Loop: Header=BB117_4 Depth=1
	bne	a1, a7, .LBB117_14
# %bb.10:                               #   in Loop: Header=BB117_4 Depth=1
	mv	s1, zero
	sw	zero, 8(t5)
	j	.LBB117_3
.LBB117_11:                             #   in Loop: Header=BB117_4 Depth=1
	lw	a1, 0(t4)
	slli	a1, a1, 8
	ori	t6, a1, 255
	sw	t6, 0(t4)
	addi	a4, a2, 8
.LBB117_12:                             #   in Loop: Header=BB117_4 Depth=1
	sw	a4, 0(t3)
	j	.LBB117_3
.LBB117_13:                             #   in Loop: Header=BB117_4 Depth=1
	mv	s1, zero
	sw	a6, %lo(nj)(t1)
	j	.LBB117_3
.LBB117_14:                             #   in Loop: Header=BB117_4 Depth=1
	andi	a3, a1, 248
	bne	a3, t0, .LBB117_16
# %bb.15:                               #   in Loop: Header=BB117_4 Depth=1
	slli	a3, t6, 8
	or	t6, a3, a1
	sw	t6, 0(t4)
	addi	a4, a2, 16
	j	.LBB117_12
.LBB117_16:                             #   in Loop: Header=BB117_4 Depth=1
	sw	a6, %lo(nj)(t1)
	j	.LBB117_3
.LBB117_17:
	addi	a1, a1, 440
	add	a1, a1, t5
	lw	t6, 0(a1)
.LBB117_18:
	sub	a1, a4, a0
	sra	a1, t6, a1
	addi	a2, zero, -1
	sll	a0, a2, a0
	not	a0, a0
	and	a0, a0, a1
	lw	s1, 8(sp)
	lw	s0, 12(sp)
	addi	sp, sp, 16
	ret
.Lfunc_end117:
	.size	njShowBits, .Lfunc_end117-njShowBits
                                        # -- End function
	.type	UART_STATUS,@object             # @UART_STATUS
	.section	.sdata,"aw",@progbits
	.globl	UART_STATUS
	.p2align	2
UART_STATUS:
	.word	32772
	.size	UART_STATUS, 4

	.type	UART_DATA,@object               # @UART_DATA
	.globl	UART_DATA
	.p2align	2
UART_DATA:
	.word	32768
	.size	UART_DATA, 4

	.type	BUTTONS,@object                 # @BUTTONS
	.globl	BUTTONS
	.p2align	2
BUTTONS:
	.word	32776
	.size	BUTTONS, 4

	.type	LEDS,@object                    # @LEDS
	.globl	LEDS
	.p2align	2
LEDS:
	.word	32780
	.size	LEDS, 4

	.type	SYSTEMCLOCK,@object             # @SYSTEMCLOCK
	.globl	SYSTEMCLOCK
	.p2align	2
SYSTEMCLOCK:
	.word	32784
	.size	SYSTEMCLOCK, 4

	.type	USBHID_VALID,@object            # @USBHID_VALID
	.globl	USBHID_VALID
	.p2align	2
USBHID_VALID:
	.word	32896
	.size	USBHID_VALID, 4

	.type	USBHID_MODIFIERS,@object        # @USBHID_MODIFIERS
	.globl	USBHID_MODIFIERS
	.p2align	2
USBHID_MODIFIERS:
	.word	32898
	.size	USBHID_MODIFIERS, 4

	.type	USBHID_KEYS12,@object           # @USBHID_KEYS12
	.globl	USBHID_KEYS12
	.p2align	2
USBHID_KEYS12:
	.word	32900
	.size	USBHID_KEYS12, 4

	.type	USBHID_KEYS34,@object           # @USBHID_KEYS34
	.globl	USBHID_KEYS34
	.p2align	2
USBHID_KEYS34:
	.word	32902
	.size	USBHID_KEYS34, 4

	.type	USBHID_KEYS56,@object           # @USBHID_KEYS56
	.globl	USBHID_KEYS56
	.p2align	2
USBHID_KEYS56:
	.word	32904
	.size	USBHID_KEYS56, 4

	.type	SDCARD_READY,@object            # @SDCARD_READY
	.globl	SDCARD_READY
	.p2align	2
SDCARD_READY:
	.word	36608
	.size	SDCARD_READY, 4

	.type	SDCARD_START,@object            # @SDCARD_START
	.globl	SDCARD_START
	.p2align	2
SDCARD_START:
	.word	36608
	.size	SDCARD_START, 4

	.type	SDCARD_SECTOR_LOW,@object       # @SDCARD_SECTOR_LOW
	.globl	SDCARD_SECTOR_LOW
	.p2align	2
SDCARD_SECTOR_LOW:
	.word	36616
	.size	SDCARD_SECTOR_LOW, 4

	.type	SDCARD_SECTOR_HIGH,@object      # @SDCARD_SECTOR_HIGH
	.globl	SDCARD_SECTOR_HIGH
	.p2align	2
SDCARD_SECTOR_HIGH:
	.word	36612
	.size	SDCARD_SECTOR_HIGH, 4

	.type	SDCARD_ADDRESS,@object          # @SDCARD_ADDRESS
	.globl	SDCARD_ADDRESS
	.p2align	2
SDCARD_ADDRESS:
	.word	36624
	.size	SDCARD_ADDRESS, 4

	.type	SDCARD_DATA,@object             # @SDCARD_DATA
	.globl	SDCARD_DATA
	.p2align	2
SDCARD_DATA:
	.word	36624
	.size	SDCARD_DATA, 4

	.type	BACKGROUND_COLOUR,@object       # @BACKGROUND_COLOUR
	.globl	BACKGROUND_COLOUR
	.p2align	2
BACKGROUND_COLOUR:
	.word	33024
	.size	BACKGROUND_COLOUR, 4

	.type	BACKGROUND_ALTCOLOUR,@object    # @BACKGROUND_ALTCOLOUR
	.globl	BACKGROUND_ALTCOLOUR
	.p2align	2
BACKGROUND_ALTCOLOUR:
	.word	33028
	.size	BACKGROUND_ALTCOLOUR, 4

	.type	BACKGROUND_MODE,@object         # @BACKGROUND_MODE
	.globl	BACKGROUND_MODE
	.p2align	2
BACKGROUND_MODE:
	.word	33032
	.size	BACKGROUND_MODE, 4

	.type	TM_X,@object                    # @TM_X
	.globl	TM_X
	.p2align	2
TM_X:
	.word	33280
	.size	TM_X, 4

	.type	TM_Y,@object                    # @TM_Y
	.globl	TM_Y
	.p2align	2
TM_Y:
	.word	33284
	.size	TM_Y, 4

	.type	TM_TILE,@object                 # @TM_TILE
	.globl	TM_TILE
	.p2align	2
TM_TILE:
	.word	33288
	.size	TM_TILE, 4

	.type	TM_BACKGROUND,@object           # @TM_BACKGROUND
	.globl	TM_BACKGROUND
	.p2align	2
TM_BACKGROUND:
	.word	33292
	.size	TM_BACKGROUND, 4

	.type	TM_FOREGROUND,@object           # @TM_FOREGROUND
	.globl	TM_FOREGROUND
	.p2align	2
TM_FOREGROUND:
	.word	33296
	.size	TM_FOREGROUND, 4

	.type	TM_COMMIT,@object               # @TM_COMMIT
	.globl	TM_COMMIT
	.p2align	2
TM_COMMIT:
	.word	33300
	.size	TM_COMMIT, 4

	.type	TM_WRITER_TILE_NUMBER,@object   # @TM_WRITER_TILE_NUMBER
	.globl	TM_WRITER_TILE_NUMBER
	.p2align	2
TM_WRITER_TILE_NUMBER:
	.word	33312
	.size	TM_WRITER_TILE_NUMBER, 4

	.type	TM_WRITER_LINE_NUMBER,@object   # @TM_WRITER_LINE_NUMBER
	.globl	TM_WRITER_LINE_NUMBER
	.p2align	2
TM_WRITER_LINE_NUMBER:
	.word	33316
	.size	TM_WRITER_LINE_NUMBER, 4

	.type	TM_WRITER_BITMAP,@object        # @TM_WRITER_BITMAP
	.globl	TM_WRITER_BITMAP
	.p2align	2
TM_WRITER_BITMAP:
	.word	33320
	.size	TM_WRITER_BITMAP, 4

	.type	TM_SCROLLWRAPCLEAR,@object      # @TM_SCROLLWRAPCLEAR
	.globl	TM_SCROLLWRAPCLEAR
	.p2align	2
TM_SCROLLWRAPCLEAR:
	.word	33328
	.size	TM_SCROLLWRAPCLEAR, 4

	.type	TM_STATUS,@object               # @TM_STATUS
	.globl	TM_STATUS
	.p2align	2
TM_STATUS:
	.word	33332
	.size	TM_STATUS, 4

	.type	GPU_X,@object                   # @GPU_X
	.globl	GPU_X
	.p2align	2
GPU_X:
	.word	33792
	.size	GPU_X, 4

	.type	GPU_Y,@object                   # @GPU_Y
	.globl	GPU_Y
	.p2align	2
GPU_Y:
	.word	33796
	.size	GPU_Y, 4

	.type	GPU_COLOUR,@object              # @GPU_COLOUR
	.globl	GPU_COLOUR
	.p2align	2
GPU_COLOUR:
	.word	33800
	.size	GPU_COLOUR, 4

	.type	GPU_COLOUR_ALT,@object          # @GPU_COLOUR_ALT
	.globl	GPU_COLOUR_ALT
	.p2align	2
GPU_COLOUR_ALT:
	.word	33801
	.size	GPU_COLOUR_ALT, 4

	.type	GPU_DITHERMODE,@object          # @GPU_DITHERMODE
	.globl	GPU_DITHERMODE
	.p2align	2
GPU_DITHERMODE:
	.word	33802
	.size	GPU_DITHERMODE, 4

	.type	GPU_PARAM0,@object              # @GPU_PARAM0
	.globl	GPU_PARAM0
	.p2align	2
GPU_PARAM0:
	.word	33804
	.size	GPU_PARAM0, 4

	.type	GPU_PARAM1,@object              # @GPU_PARAM1
	.globl	GPU_PARAM1
	.p2align	2
GPU_PARAM1:
	.word	33808
	.size	GPU_PARAM1, 4

	.type	GPU_PARAM2,@object              # @GPU_PARAM2
	.globl	GPU_PARAM2
	.p2align	2
GPU_PARAM2:
	.word	33812
	.size	GPU_PARAM2, 4

	.type	GPU_PARAM3,@object              # @GPU_PARAM3
	.globl	GPU_PARAM3
	.p2align	2
GPU_PARAM3:
	.word	33816
	.size	GPU_PARAM3, 4

	.type	GPU_WRITE,@object               # @GPU_WRITE
	.globl	GPU_WRITE
	.p2align	2
GPU_WRITE:
	.word	33820
	.size	GPU_WRITE, 4

	.type	GPU_STATUS,@object              # @GPU_STATUS
	.globl	GPU_STATUS
	.p2align	2
GPU_STATUS:
	.word	33820
	.size	GPU_STATUS, 4

	.type	BLIT_WRITER_TILE,@object        # @BLIT_WRITER_TILE
	.globl	BLIT_WRITER_TILE
	.p2align	2
BLIT_WRITER_TILE:
	.word	33872
	.size	BLIT_WRITER_TILE, 4

	.type	BLIT_WRITER_LINE,@object        # @BLIT_WRITER_LINE
	.globl	BLIT_WRITER_LINE
	.p2align	2
BLIT_WRITER_LINE:
	.word	33876
	.size	BLIT_WRITER_LINE, 4

	.type	BLIT_WRITER_BITMAP,@object      # @BLIT_WRITER_BITMAP
	.globl	BLIT_WRITER_BITMAP
	.p2align	2
BLIT_WRITER_BITMAP:
	.word	33880
	.size	BLIT_WRITER_BITMAP, 4

	.type	VECTOR_DRAW_BLOCK,@object       # @VECTOR_DRAW_BLOCK
	.globl	VECTOR_DRAW_BLOCK
	.p2align	2
VECTOR_DRAW_BLOCK:
	.word	33824
	.size	VECTOR_DRAW_BLOCK, 4

	.type	VECTOR_DRAW_COLOUR,@object      # @VECTOR_DRAW_COLOUR
	.globl	VECTOR_DRAW_COLOUR
	.p2align	2
VECTOR_DRAW_COLOUR:
	.word	33828
	.size	VECTOR_DRAW_COLOUR, 4

	.type	VECTOR_DRAW_XC,@object          # @VECTOR_DRAW_XC
	.globl	VECTOR_DRAW_XC
	.p2align	2
VECTOR_DRAW_XC:
	.word	33832
	.size	VECTOR_DRAW_XC, 4

	.type	VECTOR_DRAW_YC,@object          # @VECTOR_DRAW_YC
	.globl	VECTOR_DRAW_YC
	.p2align	2
VECTOR_DRAW_YC:
	.word	33836
	.size	VECTOR_DRAW_YC, 4

	.type	VECTOR_DRAW_START,@object       # @VECTOR_DRAW_START
	.globl	VECTOR_DRAW_START
	.p2align	2
VECTOR_DRAW_START:
	.word	33840
	.size	VECTOR_DRAW_START, 4

	.type	VECTOR_DRAW_STATUS,@object      # @VECTOR_DRAW_STATUS
	.globl	VECTOR_DRAW_STATUS
	.p2align	2
VECTOR_DRAW_STATUS:
	.word	33864
	.size	VECTOR_DRAW_STATUS, 4

	.type	VECTOR_WRITER_BLOCK,@object     # @VECTOR_WRITER_BLOCK
	.globl	VECTOR_WRITER_BLOCK
	.p2align	2
VECTOR_WRITER_BLOCK:
	.word	33844
	.size	VECTOR_WRITER_BLOCK, 4

	.type	VECTOR_WRITER_VERTEX,@object    # @VECTOR_WRITER_VERTEX
	.globl	VECTOR_WRITER_VERTEX
	.p2align	2
VECTOR_WRITER_VERTEX:
	.word	33848
	.size	VECTOR_WRITER_VERTEX, 4

	.type	VECTOR_WRITER_ACTIVE,@object    # @VECTOR_WRITER_ACTIVE
	.globl	VECTOR_WRITER_ACTIVE
	.p2align	2
VECTOR_WRITER_ACTIVE:
	.word	33860
	.size	VECTOR_WRITER_ACTIVE, 4

	.type	VECTOR_WRITER_DELTAX,@object    # @VECTOR_WRITER_DELTAX
	.globl	VECTOR_WRITER_DELTAX
	.p2align	2
VECTOR_WRITER_DELTAX:
	.word	33852
	.size	VECTOR_WRITER_DELTAX, 4

	.type	VECTOR_WRITER_DELTAY,@object    # @VECTOR_WRITER_DELTAY
	.globl	VECTOR_WRITER_DELTAY
	.p2align	2
VECTOR_WRITER_DELTAY:
	.word	33856
	.size	VECTOR_WRITER_DELTAY, 4

	.type	BITMAP_SCROLLWRAP,@object       # @BITMAP_SCROLLWRAP
	.globl	BITMAP_SCROLLWRAP
	.p2align	2
BITMAP_SCROLLWRAP:
	.word	33888
	.size	BITMAP_SCROLLWRAP, 4

	.type	BITMAP_PIXEL_READ,@object       # @BITMAP_PIXEL_READ
	.globl	BITMAP_PIXEL_READ
	.p2align	2
BITMAP_PIXEL_READ:
	.word	33904
	.size	BITMAP_PIXEL_READ, 4

	.type	BITMAP_X_READ,@object           # @BITMAP_X_READ
	.globl	BITMAP_X_READ
	.p2align	2
BITMAP_X_READ:
	.word	33904
	.size	BITMAP_X_READ, 4

	.type	BITMAP_Y_READ,@object           # @BITMAP_Y_READ
	.globl	BITMAP_Y_READ
	.p2align	2
BITMAP_Y_READ:
	.word	33908
	.size	BITMAP_Y_READ, 4

	.type	LOWER_SPRITE_NUMBER,@object     # @LOWER_SPRITE_NUMBER
	.globl	LOWER_SPRITE_NUMBER
	.p2align	2
LOWER_SPRITE_NUMBER:
	.word	33536
	.size	LOWER_SPRITE_NUMBER, 4

	.type	LOWER_SPRITE_ACTIVE,@object     # @LOWER_SPRITE_ACTIVE
	.globl	LOWER_SPRITE_ACTIVE
	.p2align	2
LOWER_SPRITE_ACTIVE:
	.word	33540
	.size	LOWER_SPRITE_ACTIVE, 4

	.type	LOWER_SPRITE_TILE,@object       # @LOWER_SPRITE_TILE
	.globl	LOWER_SPRITE_TILE
	.p2align	2
LOWER_SPRITE_TILE:
	.word	33544
	.size	LOWER_SPRITE_TILE, 4

	.type	LOWER_SPRITE_COLOUR,@object     # @LOWER_SPRITE_COLOUR
	.globl	LOWER_SPRITE_COLOUR
	.p2align	2
LOWER_SPRITE_COLOUR:
	.word	33548
	.size	LOWER_SPRITE_COLOUR, 4

	.type	LOWER_SPRITE_X,@object          # @LOWER_SPRITE_X
	.globl	LOWER_SPRITE_X
	.p2align	2
LOWER_SPRITE_X:
	.word	33552
	.size	LOWER_SPRITE_X, 4

	.type	LOWER_SPRITE_Y,@object          # @LOWER_SPRITE_Y
	.globl	LOWER_SPRITE_Y
	.p2align	2
LOWER_SPRITE_Y:
	.word	33556
	.size	LOWER_SPRITE_Y, 4

	.type	LOWER_SPRITE_DOUBLE,@object     # @LOWER_SPRITE_DOUBLE
	.globl	LOWER_SPRITE_DOUBLE
	.p2align	2
LOWER_SPRITE_DOUBLE:
	.word	33560
	.size	LOWER_SPRITE_DOUBLE, 4

	.type	LOWER_SPRITE_UPDATE,@object     # @LOWER_SPRITE_UPDATE
	.globl	LOWER_SPRITE_UPDATE
	.p2align	2
LOWER_SPRITE_UPDATE:
	.word	33564
	.size	LOWER_SPRITE_UPDATE, 4

	.type	LOWER_SPRITE_WRITER_NUMBER,@object # @LOWER_SPRITE_WRITER_NUMBER
	.globl	LOWER_SPRITE_WRITER_NUMBER
	.p2align	2
LOWER_SPRITE_WRITER_NUMBER:
	.word	33568
	.size	LOWER_SPRITE_WRITER_NUMBER, 4

	.type	LOWER_SPRITE_WRITER_LINE,@object # @LOWER_SPRITE_WRITER_LINE
	.globl	LOWER_SPRITE_WRITER_LINE
	.p2align	2
LOWER_SPRITE_WRITER_LINE:
	.word	33572
	.size	LOWER_SPRITE_WRITER_LINE, 4

	.type	LOWER_SPRITE_WRITER_BITMAP,@object # @LOWER_SPRITE_WRITER_BITMAP
	.globl	LOWER_SPRITE_WRITER_BITMAP
	.p2align	2
LOWER_SPRITE_WRITER_BITMAP:
	.word	33576
	.size	LOWER_SPRITE_WRITER_BITMAP, 4

	.type	LOWER_SPRITE_COLLISION_BASE,@object # @LOWER_SPRITE_COLLISION_BASE
	.globl	LOWER_SPRITE_COLLISION_BASE
	.p2align	2
LOWER_SPRITE_COLLISION_BASE:
	.word	33584
	.size	LOWER_SPRITE_COLLISION_BASE, 4

	.type	LOWER_SPRITE_NUMBER_SMT,@object # @LOWER_SPRITE_NUMBER_SMT
	.globl	LOWER_SPRITE_NUMBER_SMT
	.p2align	2
LOWER_SPRITE_NUMBER_SMT:
	.word	37632
	.size	LOWER_SPRITE_NUMBER_SMT, 4

	.type	LOWER_SPRITE_ACTIVE_SMT,@object # @LOWER_SPRITE_ACTIVE_SMT
	.globl	LOWER_SPRITE_ACTIVE_SMT
	.p2align	2
LOWER_SPRITE_ACTIVE_SMT:
	.word	37636
	.size	LOWER_SPRITE_ACTIVE_SMT, 4

	.type	LOWER_SPRITE_TILE_SMT,@object   # @LOWER_SPRITE_TILE_SMT
	.globl	LOWER_SPRITE_TILE_SMT
	.p2align	2
LOWER_SPRITE_TILE_SMT:
	.word	37640
	.size	LOWER_SPRITE_TILE_SMT, 4

	.type	LOWER_SPRITE_COLOUR_SMT,@object # @LOWER_SPRITE_COLOUR_SMT
	.globl	LOWER_SPRITE_COLOUR_SMT
	.p2align	2
LOWER_SPRITE_COLOUR_SMT:
	.word	37644
	.size	LOWER_SPRITE_COLOUR_SMT, 4

	.type	LOWER_SPRITE_X_SMT,@object      # @LOWER_SPRITE_X_SMT
	.globl	LOWER_SPRITE_X_SMT
	.p2align	2
LOWER_SPRITE_X_SMT:
	.word	37648
	.size	LOWER_SPRITE_X_SMT, 4

	.type	LOWER_SPRITE_Y_SMT,@object      # @LOWER_SPRITE_Y_SMT
	.globl	LOWER_SPRITE_Y_SMT
	.p2align	2
LOWER_SPRITE_Y_SMT:
	.word	37652
	.size	LOWER_SPRITE_Y_SMT, 4

	.type	LOWER_SPRITE_DOUBLE_SMT,@object # @LOWER_SPRITE_DOUBLE_SMT
	.globl	LOWER_SPRITE_DOUBLE_SMT
	.p2align	2
LOWER_SPRITE_DOUBLE_SMT:
	.word	37656
	.size	LOWER_SPRITE_DOUBLE_SMT, 4

	.type	LOWER_SPRITE_UPDATE_SMT,@object # @LOWER_SPRITE_UPDATE_SMT
	.globl	LOWER_SPRITE_UPDATE_SMT
	.p2align	2
LOWER_SPRITE_UPDATE_SMT:
	.word	37660
	.size	LOWER_SPRITE_UPDATE_SMT, 4

	.type	UPPER_SPRITE_NUMBER,@object     # @UPPER_SPRITE_NUMBER
	.globl	UPPER_SPRITE_NUMBER
	.p2align	2
UPPER_SPRITE_NUMBER:
	.word	34048
	.size	UPPER_SPRITE_NUMBER, 4

	.type	UPPER_SPRITE_ACTIVE,@object     # @UPPER_SPRITE_ACTIVE
	.globl	UPPER_SPRITE_ACTIVE
	.p2align	2
UPPER_SPRITE_ACTIVE:
	.word	34052
	.size	UPPER_SPRITE_ACTIVE, 4

	.type	UPPER_SPRITE_TILE,@object       # @UPPER_SPRITE_TILE
	.globl	UPPER_SPRITE_TILE
	.p2align	2
UPPER_SPRITE_TILE:
	.word	34056
	.size	UPPER_SPRITE_TILE, 4

	.type	UPPER_SPRITE_COLOUR,@object     # @UPPER_SPRITE_COLOUR
	.globl	UPPER_SPRITE_COLOUR
	.p2align	2
UPPER_SPRITE_COLOUR:
	.word	34060
	.size	UPPER_SPRITE_COLOUR, 4

	.type	UPPER_SPRITE_X,@object          # @UPPER_SPRITE_X
	.globl	UPPER_SPRITE_X
	.p2align	2
UPPER_SPRITE_X:
	.word	34064
	.size	UPPER_SPRITE_X, 4

	.type	UPPER_SPRITE_Y,@object          # @UPPER_SPRITE_Y
	.globl	UPPER_SPRITE_Y
	.p2align	2
UPPER_SPRITE_Y:
	.word	34068
	.size	UPPER_SPRITE_Y, 4

	.type	UPPER_SPRITE_DOUBLE,@object     # @UPPER_SPRITE_DOUBLE
	.globl	UPPER_SPRITE_DOUBLE
	.p2align	2
UPPER_SPRITE_DOUBLE:
	.word	34072
	.size	UPPER_SPRITE_DOUBLE, 4

	.type	UPPER_SPRITE_UPDATE,@object     # @UPPER_SPRITE_UPDATE
	.globl	UPPER_SPRITE_UPDATE
	.p2align	2
UPPER_SPRITE_UPDATE:
	.word	34076
	.size	UPPER_SPRITE_UPDATE, 4

	.type	UPPER_SPRITE_WRITER_NUMBER,@object # @UPPER_SPRITE_WRITER_NUMBER
	.globl	UPPER_SPRITE_WRITER_NUMBER
	.p2align	2
UPPER_SPRITE_WRITER_NUMBER:
	.word	34080
	.size	UPPER_SPRITE_WRITER_NUMBER, 4

	.type	UPPER_SPRITE_WRITER_LINE,@object # @UPPER_SPRITE_WRITER_LINE
	.globl	UPPER_SPRITE_WRITER_LINE
	.p2align	2
UPPER_SPRITE_WRITER_LINE:
	.word	34084
	.size	UPPER_SPRITE_WRITER_LINE, 4

	.type	UPPER_SPRITE_WRITER_BITMAP,@object # @UPPER_SPRITE_WRITER_BITMAP
	.globl	UPPER_SPRITE_WRITER_BITMAP
	.p2align	2
UPPER_SPRITE_WRITER_BITMAP:
	.word	34088
	.size	UPPER_SPRITE_WRITER_BITMAP, 4

	.type	UPPER_SPRITE_COLLISION_BASE,@object # @UPPER_SPRITE_COLLISION_BASE
	.globl	UPPER_SPRITE_COLLISION_BASE
	.p2align	2
UPPER_SPRITE_COLLISION_BASE:
	.word	34096
	.size	UPPER_SPRITE_COLLISION_BASE, 4

	.type	UPPER_SPRITE_NUMBER_SMT,@object # @UPPER_SPRITE_NUMBER_SMT
	.globl	UPPER_SPRITE_NUMBER_SMT
	.p2align	2
UPPER_SPRITE_NUMBER_SMT:
	.word	38144
	.size	UPPER_SPRITE_NUMBER_SMT, 4

	.type	UPPER_SPRITE_ACTIVE_SMT,@object # @UPPER_SPRITE_ACTIVE_SMT
	.globl	UPPER_SPRITE_ACTIVE_SMT
	.p2align	2
UPPER_SPRITE_ACTIVE_SMT:
	.word	38148
	.size	UPPER_SPRITE_ACTIVE_SMT, 4

	.type	UPPER_SPRITE_TILE_SMT,@object   # @UPPER_SPRITE_TILE_SMT
	.globl	UPPER_SPRITE_TILE_SMT
	.p2align	2
UPPER_SPRITE_TILE_SMT:
	.word	38152
	.size	UPPER_SPRITE_TILE_SMT, 4

	.type	UPPER_SPRITE_COLOUR_SMT,@object # @UPPER_SPRITE_COLOUR_SMT
	.globl	UPPER_SPRITE_COLOUR_SMT
	.p2align	2
UPPER_SPRITE_COLOUR_SMT:
	.word	38156
	.size	UPPER_SPRITE_COLOUR_SMT, 4

	.type	UPPER_SPRITE_X_SMT,@object      # @UPPER_SPRITE_X_SMT
	.globl	UPPER_SPRITE_X_SMT
	.p2align	2
UPPER_SPRITE_X_SMT:
	.word	38160
	.size	UPPER_SPRITE_X_SMT, 4

	.type	UPPER_SPRITE_Y_SMT,@object      # @UPPER_SPRITE_Y_SMT
	.globl	UPPER_SPRITE_Y_SMT
	.p2align	2
UPPER_SPRITE_Y_SMT:
	.word	38164
	.size	UPPER_SPRITE_Y_SMT, 4

	.type	UPPER_SPRITE_DOUBLE_SMT,@object # @UPPER_SPRITE_DOUBLE_SMT
	.globl	UPPER_SPRITE_DOUBLE_SMT
	.p2align	2
UPPER_SPRITE_DOUBLE_SMT:
	.word	38168
	.size	UPPER_SPRITE_DOUBLE_SMT, 4

	.type	UPPER_SPRITE_UPDATE_SMT,@object # @UPPER_SPRITE_UPDATE_SMT
	.globl	UPPER_SPRITE_UPDATE_SMT
	.p2align	2
UPPER_SPRITE_UPDATE_SMT:
	.word	38172
	.size	UPPER_SPRITE_UPDATE_SMT, 4

	.type	TPU_X,@object                   # @TPU_X
	.globl	TPU_X
	.p2align	2
TPU_X:
	.word	34304
	.size	TPU_X, 4

	.type	TPU_Y,@object                   # @TPU_Y
	.globl	TPU_Y
	.p2align	2
TPU_Y:
	.word	34308
	.size	TPU_Y, 4

	.type	TPU_CHARACTER,@object           # @TPU_CHARACTER
	.globl	TPU_CHARACTER
	.p2align	2
TPU_CHARACTER:
	.word	34312
	.size	TPU_CHARACTER, 4

	.type	TPU_BACKGROUND,@object          # @TPU_BACKGROUND
	.globl	TPU_BACKGROUND
	.p2align	2
TPU_BACKGROUND:
	.word	34316
	.size	TPU_BACKGROUND, 4

	.type	TPU_FOREGROUND,@object          # @TPU_FOREGROUND
	.globl	TPU_FOREGROUND
	.p2align	2
TPU_FOREGROUND:
	.word	34320
	.size	TPU_FOREGROUND, 4

	.type	TPU_COMMIT,@object              # @TPU_COMMIT
	.globl	TPU_COMMIT
	.p2align	2
TPU_COMMIT:
	.word	34324
	.size	TPU_COMMIT, 4

	.type	AUDIO_L_WAVEFORM,@object        # @AUDIO_L_WAVEFORM
	.globl	AUDIO_L_WAVEFORM
	.p2align	2
AUDIO_L_WAVEFORM:
	.word	34816
	.size	AUDIO_L_WAVEFORM, 4

	.type	AUDIO_L_NOTE,@object            # @AUDIO_L_NOTE
	.globl	AUDIO_L_NOTE
	.p2align	2
AUDIO_L_NOTE:
	.word	34820
	.size	AUDIO_L_NOTE, 4

	.type	AUDIO_L_DURATION,@object        # @AUDIO_L_DURATION
	.globl	AUDIO_L_DURATION
	.p2align	2
AUDIO_L_DURATION:
	.word	34824
	.size	AUDIO_L_DURATION, 4

	.type	AUDIO_L_START,@object           # @AUDIO_L_START
	.globl	AUDIO_L_START
	.p2align	2
AUDIO_L_START:
	.word	34828
	.size	AUDIO_L_START, 4

	.type	AUDIO_R_WAVEFORM,@object        # @AUDIO_R_WAVEFORM
	.globl	AUDIO_R_WAVEFORM
	.p2align	2
AUDIO_R_WAVEFORM:
	.word	34832
	.size	AUDIO_R_WAVEFORM, 4

	.type	AUDIO_R_NOTE,@object            # @AUDIO_R_NOTE
	.globl	AUDIO_R_NOTE
	.p2align	2
AUDIO_R_NOTE:
	.word	34836
	.size	AUDIO_R_NOTE, 4

	.type	AUDIO_R_DURATION,@object        # @AUDIO_R_DURATION
	.globl	AUDIO_R_DURATION
	.p2align	2
AUDIO_R_DURATION:
	.word	34840
	.size	AUDIO_R_DURATION, 4

	.type	AUDIO_R_START,@object           # @AUDIO_R_START
	.globl	AUDIO_R_START
	.p2align	2
AUDIO_R_START:
	.word	34844
	.size	AUDIO_R_START, 4

	.type	RNG,@object                     # @RNG
	.globl	RNG
	.p2align	2
RNG:
	.word	35072
	.size	RNG, 4

	.type	ALT_RNG,@object                 # @ALT_RNG
	.globl	ALT_RNG
	.p2align	2
ALT_RNG:
	.word	35076
	.size	ALT_RNG, 4

	.type	TIMER1HZ0,@object               # @TIMER1HZ0
	.globl	TIMER1HZ0
	.p2align	2
TIMER1HZ0:
	.word	35088
	.size	TIMER1HZ0, 4

	.type	TIMER1KHZ0,@object              # @TIMER1KHZ0
	.globl	TIMER1KHZ0
	.p2align	2
TIMER1KHZ0:
	.word	35104
	.size	TIMER1KHZ0, 4

	.type	SLEEPTIMER0,@object             # @SLEEPTIMER0
	.globl	SLEEPTIMER0
	.p2align	2
SLEEPTIMER0:
	.word	35120
	.size	SLEEPTIMER0, 4

	.type	TIMER1HZ1,@object               # @TIMER1HZ1
	.globl	TIMER1HZ1
	.p2align	2
TIMER1HZ1:
	.word	35092
	.size	TIMER1HZ1, 4

	.type	TIMER1KHZ1,@object              # @TIMER1KHZ1
	.globl	TIMER1KHZ1
	.p2align	2
TIMER1KHZ1:
	.word	35108
	.size	TIMER1KHZ1, 4

	.type	SLEEPTIMER1,@object             # @SLEEPTIMER1
	.globl	SLEEPTIMER1
	.p2align	2
SLEEPTIMER1:
	.word	35124
	.size	SLEEPTIMER1, 4

	.type	VBLANK,@object                  # @VBLANK
	.globl	VBLANK
	.p2align	2
VBLANK:
	.word	36848
	.size	VBLANK, 4

	.type	SCREENMODE,@object              # @SCREENMODE
	.globl	SCREENMODE
	.p2align	2
SCREENMODE:
	.word	36848
	.size	SCREENMODE, 4

	.type	SMTSTATUS,@object               # @SMTSTATUS
	.globl	SMTSTATUS
	.p2align	2
SMTSTATUS:
	.word	65535
	.size	SMTSTATUS, 4

	.type	SMTPCH,@object                  # @SMTPCH
	.globl	SMTPCH
	.p2align	2
SMTPCH:
	.word	65520
	.size	SMTPCH, 4

	.type	SMTPCL,@object                  # @SMTPCL
	.globl	SMTPCL
	.p2align	2
SMTPCL:
	.word	65522
	.size	SMTPCL, 4

	.type	MEMORYHEAP,@object              # @MEMORYHEAP
	.globl	MEMORYHEAP
	.p2align	2
MEMORYHEAP:
	.word	276824064
	.size	MEMORYHEAP, 4

	.type	MEMORYHEAPTOP,@object           # @MEMORYHEAPTOP
	.globl	MEMORYHEAPTOP
	.p2align	2
MEMORYHEAPTOP:
	.word	276824064
	.size	MEMORYHEAPTOP, 4

	.type	gpu_printf.buffer,@object       # @gpu_printf.buffer
	.section	.bss.gpu_printf.buffer,"aw",@nobits
gpu_printf.buffer:
	.zero	81
	.size	gpu_printf.buffer, 81

	.type	gpu_printf_centre.buffer,@object # @gpu_printf_centre.buffer
	.section	.bss.gpu_printf_centre.buffer,"aw",@nobits
gpu_printf_centre.buffer:
	.zero	81
	.size	gpu_printf_centre.buffer, 81

	.type	tpu_printf.buffer,@object       # @tpu_printf.buffer
	.section	.bss.tpu_printf.buffer,"aw",@nobits
tpu_printf.buffer:
	.zero	1024
	.size	tpu_printf.buffer, 1024

	.type	tpu_printf_centre.buffer,@object # @tpu_printf_centre.buffer
	.section	.bss.tpu_printf_centre.buffer,"aw",@nobits
tpu_printf_centre.buffer:
	.zero	811
	.size	tpu_printf_centre.buffer, 811

	.type	BOOTSECTOR,@object              # @BOOTSECTOR
	.section	.sbss,"aw",@nobits
	.globl	BOOTSECTOR
	.p2align	2
BOOTSECTOR:
	.word	0
	.size	BOOTSECTOR, 4

	.type	ROOTDIRECTORY,@object           # @ROOTDIRECTORY
	.globl	ROOTDIRECTORY
	.p2align	2
ROOTDIRECTORY:
	.word	0
	.size	ROOTDIRECTORY, 4

	.type	DATASTARTSECTOR,@object         # @DATASTARTSECTOR
	.globl	DATASTARTSECTOR
	.p2align	2
DATASTARTSECTOR:
	.word	0                               # 0x0
	.size	DATASTARTSECTOR, 4

	.type	CLUSTERBUFFER,@object           # @CLUSTERBUFFER
	.globl	CLUSTERBUFFER
	.p2align	2
CLUSTERBUFFER:
	.word	0
	.size	CLUSTERBUFFER, 4

	.type	FAT,@object                     # @FAT
	.globl	FAT
	.p2align	2
FAT:
	.word	0
	.size	FAT, 4

	.type	__curses_cursor,@object         # @__curses_cursor
	.section	.sdata,"aw",@progbits
	.globl	__curses_cursor
__curses_cursor:
	.byte	1                               # 0x1
	.size	__curses_cursor, 1

	.type	__curses_scroll,@object         # @__curses_scroll
	.globl	__curses_scroll
__curses_scroll:
	.byte	1                               # 0x1
	.size	__curses_scroll, 1

	.type	__curses_x,@object              # @__curses_x
	.section	.sbss,"aw",@nobits
	.globl	__curses_x
	.p2align	1
__curses_x:
	.half	0                               # 0x0
	.size	__curses_x, 2

	.type	__curses_y,@object              # @__curses_y
	.globl	__curses_y
	.p2align	1
__curses_y:
	.half	0                               # 0x0
	.size	__curses_y, 2

	.type	__curses_fore,@object           # @__curses_fore
	.section	.sdata,"aw",@progbits
	.globl	__curses_fore
	.p2align	1
__curses_fore:
	.half	63                              # 0x3f
	.size	__curses_fore, 2

	.type	__curses_back,@object           # @__curses_back
	.section	.sbss,"aw",@nobits
	.globl	__curses_back
	.p2align	1
__curses_back:
	.half	0                               # 0x0
	.size	__curses_back, 2

	.type	__curses_character,@object      # @__curses_character
	.section	.bss.__curses_character,"aw",@nobits
	.globl	__curses_character
__curses_character:
	.zero	2400
	.size	__curses_character, 2400

	.type	__curses_background,@object     # @__curses_background
	.section	.bss.__curses_background,"aw",@nobits
	.globl	__curses_background
__curses_background:
	.zero	2400
	.size	__curses_background, 2400

	.type	__curses_foreground,@object     # @__curses_foreground
	.section	.bss.__curses_foreground,"aw",@nobits
	.globl	__curses_foreground
__curses_foreground:
	.zero	2400
	.size	__curses_foreground, 2400

	.type	__curses_foregroundcolours,@object # @__curses_foregroundcolours
	.section	.bss.__curses_foregroundcolours,"aw",@nobits
	.globl	__curses_foregroundcolours
__curses_foregroundcolours:
	.zero	16
	.size	__curses_foregroundcolours, 16

	.type	__curses_backgroundcolours,@object # @__curses_backgroundcolours
	.section	.bss.__curses_backgroundcolours,"aw",@nobits
	.globl	__curses_backgroundcolours
__curses_backgroundcolours:
	.zero	16
	.size	__curses_backgroundcolours, 16

	.type	printw.buffer,@object           # @printw.buffer
	.section	.bss.printw.buffer,"aw",@nobits
printw.buffer:
	.zero	1024
	.size	printw.buffer, 1024

	.type	mvprintw.buffer,@object         # @mvprintw.buffer
	.section	.bss.mvprintw.buffer,"aw",@nobits
mvprintw.buffer:
	.zero	1024
	.size	mvprintw.buffer, 1024

	.type	_heap,@object                   # @_heap
	.section	.sbss,"aw",@nobits
	.globl	_heap
	.p2align	2
_heap:
	.word	0
	.size	_heap, 4

	.type	MEMORYTOP,@object               # @MEMORYTOP
	.globl	MEMORYTOP
	.p2align	2
MEMORYTOP:
	.word	0
	.size	MEMORYTOP, 4

	.type	CLUSTERSIZE,@object             # @CLUSTERSIZE
	.globl	CLUSTERSIZE
	.p2align	2
CLUSTERSIZE:
	.word	0                               # 0x0
	.size	CLUSTERSIZE, 4

	.type	MBR,@object                     # @MBR
	.globl	MBR
	.p2align	2
MBR:
	.word	0
	.size	MBR, 4

	.type	PARTITION,@object               # @PARTITION
	.globl	PARTITION
	.p2align	2
PARTITION:
	.word	0
	.size	PARTITION, 4

	.type	nj,@object                      # @nj
	.section	.bss.nj,"aw",@nobits
	.p2align	2
nj:
	.zero	525000
	.size	nj, 525000

	.type	njDecodeDHT.counts,@object      # @njDecodeDHT.counts
	.section	.bss.njDecodeDHT.counts,"aw",@nobits
njDecodeDHT.counts:
	.zero	16
	.size	njDecodeDHT.counts, 16

	.type	njZZ,@object                    # @njZZ
	.section	.rodata.njZZ,"a",@progbits
njZZ:
	.ascii	"\000\001\b\020\t\002\003\n\021\030 \031\022\013\004\005\f\023\032!(0)\"\033\024\r\006\007\016\025\034#*1892+$\035\026\017\027\036%,3:;4-&\037'.5<=6/7>?"
	.size	njZZ, 64

	.ident	"clang version 11.1.0"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym gpu_printf.buffer
	.addrsig_sym gpu_printf_centre.buffer
	.addrsig_sym tpu_printf.buffer
	.addrsig_sym tpu_printf_centre.buffer
	.addrsig_sym printw.buffer
	.addrsig_sym mvprintw.buffer
