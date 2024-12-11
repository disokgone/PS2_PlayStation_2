	.file	1 "S01.s"
	.text
	.p2align 3

	.globl	EnableIntc
#	.globl	IntHandler0A
	.globl	testVBlank
	.globl	trySetVideo
	.ent	testVBlank

#-------------------------------
# byte ret(byte[$16A018]);	at $11B330	-- paddle
#-------------------------------
#	lui	$v1, unk
#	lbu	$v0, unk($v1)
	jr	$ra

#-------------------------------
# int IntHandler0A(void);	at $11B340
# 傳回 0x00FF	(應是 VSync 中斷)
#-------------------------------
IntHandler0A:
	lui	$a0, 0x1000		
	la	$a1, VSyncCount
	ld	$v0, 0($a1)	# v0 = V-Sync count (= [$16A028])
	lw	$v1, 0x0810($a0)
	daddiu	$v0, $v0, 1
	ori	$v1, $v1, 0x0400
	sd	$v0, VSyncCount($a1)	# (V-Sync count) ++
	sw	$v1, 0($a0)		# int[$10000810] |= 0x0400
	.word	0x000F			# sync 0
	.word	0x42000038
	addiu	$v0, $zero, 0x00FF
	jr	$ra

#-------------------------------
# int trySetVideo();		at $11B448
# 傳回 fVSyncUsable 值 (= [$16A030])
#-------------------------------
trySetVideo:
	subiu	$sp, $sp, 16
	lui	$v0, 0x1000
	sd	$ra, 0($sp)
	addiu	$a0, $zero, 0x01C2
	sw	$a0, 0x0810($v0)	# int[$10000810] = 0x1C2;
	sw	$zero, 0x0800($v0)	# int[$10000800] = 0
	addiu	$v1, $zero, 0x024A
	sw	$v1, 0x0820($v0)	# int[$10000820] = 0x24A;

	addiu	$a0, $zero, 0x000A
	la	$a1, IntHandler0A	# a1 = $11B340 (= Interrupt Handler $0A)
	daddu	$a2, $zero, $zero
	jal	AddIntcHandler		# AddIntcHandler(int IntNo, void *IntrHandler, int code);

	addiu	$a0, $zero, 0x000A
	jal	EnableIntc		# EnableIntc(int IntrNo);

	la	$v1, fVSyncUsable	# [$16A030] = 1 (代表 VSync 中斷已安裝並致能)
	addiu	$v0, $zero, 1
	sw	$v0, 0($v1)
	ld	$ra, 0($sp)
	addiu	$sp, $sp, 16
	jr	$ra

#-------------------------------
# long testVBlank();	at $11B4B0
# 傳回 VSync count 值 (= [$16A028])
#-------------------------------
testVBlank:
	la	$v0, fVSyncUsable
	subiu	$sp, $sp, 16
	lw	$v1, 0($v0)
	bne	$v1, $zero, _VB_usable	# 1 = 代表 VSync 中斷已安裝並致能

	sd	$ra, 0($sp)
	jal	trySetVideo		# 若未安裝, 則嘗試重新設立視訊中斷

	b	_ResetFailed
	daddu	$v0, $zero, $zero	# 剛安裝, 傳回 0

_VB_usable:
	la	$v1, VSyncCount
	ld	$v0, 0($v1)		# 傳回 VSync count 值

_ResetFailed:
	ld	$ra, 0($sp)
	addiu	$sp, $sp, 16
	jr	$ra

#-------------------------------
# EnableIntc()		at $0C1134
#-------------------------------
EnableIntc:
	subiu     $sp, $sp, 32
	sd	  $ra, 16($sp)
	sd	  $s0, 0($sp)
	mfc0	  $s0, $12
	lui	  $v0, 1
	and	  $s0, $s0, $v0
	beq	  $s0, $zero, $L_EnableIntc
	lui	  $v1, 1		# if (DS.DE == 0) ResetEE

$L_Retry:
	.word	0x42000039
	.word	0x000F			# sync	0
	mfc0	$v0, $12
	and	$v0, $v0, $v1
	nop
	bne	$v0, $zero, $L_Retry	# if (DS.DE == 1) [記憶體錯誤不產生例外]

$L_EnableIntc:
	addiu   $v1, $zero, 0x0014
	syscall 0
	.word	0x000F			# sync	0
	beq	$s0, $zero, $L_ret
	ld	$ra, 16($sp)
	.word	0x42000038
	ld	$ra, 16($sp)

$L_ret:
	ld	$s0, 0($sp)
	addiu	$sp, $sp, 32
	jr	$ra

	.end	testVBlank
