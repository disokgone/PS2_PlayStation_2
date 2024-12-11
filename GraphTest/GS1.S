	.set noreorder
csr	=	0x12001000

	.text
	.align	3	# 8 bytes
	.global 	gs_set_imr
	.global 	Init_GS
	.global 	SetVideoMode

#------------------------------------------------------------------------
# void gs_set_imr(void);
#------------------------------------------------------------------------
.ent gs_set_imr
gs_set_imr:
	subu	$sp, $sp, 0x10
	sd	$ra, 0($sp)

	li	$a0, 0x0000FF00		# 清除了 low 8 bits
	ld	$v0, csr
	dsrl	$v0, 16
	andi	$v0, 0xFF
	jal	GsPutIMR
	daddu	$v0, $zero, $zero	# return 0

	ld	$ra, 0($sp)
	jr	$ra
	addiu	$sp, $sp, 0x10
.end gs_set_imr

#------------------------------------------------------------------------
# void Init_GS(int intlace, int ntscpal, int framefield);
#	// intlace : 0=非交錯, 1=交錯
#	// ntscpal : 2=NTSC, 3=PAL
#	// framefield : 1=frame, 2=field
#------------------------------------------------------------------------
Init_GS:
	subu	$sp, $sp, 0x10
	sd	$ra, 0($sp)

	addu	$s1, $a0, $zero
	addu	$s2, $a1, $zero
	addu	$s3, $a2, $zero

	la	$v0, csr
	li	$v1, 0x200
	sd	$v1, 0($v0)		# reset GS !

	ori	$a0, $zero, 0xFF00
	ld	$v0, 0($v0)
	dsrl	$v0, $v0, 16
	andi	$v0, $v0, 0xFF
	jal	GsPutIMR		# <syscall $71>  PutIMR(int maskBits) <set to GS.csr>
	nop

	andi	$a0, $s1, 1
	andi	$a1, $s2, 0xFF
	andi	$a2, $s3, 1
	jal	SetGsCrt		# <syscall $02> SetGsCrt(?, ?, ?)
	nop

	ld	$ra, 0($sp)
	jr	$ra
	addiu	$sp, $sp, 0x10

#------------------------------------------------------------------------
# void SetVideoMode(void);
#------------------------------------------------------------------------
SetVideoMode:
	lui	$v0, 0x1200
	ori	$v1, $zero, 0xFF62
	sd	$v1, 0($v0)		# GS.pmode = 0x00FF62

	addiu	$v1, $zero, 2
	sd	$v1, 0x20($v0)		# GS.smode = { INT=0, FFMD=1, DPMS=0 }

	addiu	$v1, $zero, 0x1400
	sd	$v1, 0x90($v0)		# GS.dispfb2 = 0x1400

	li	$v1, 0x000DF9FF01824290
	sd	$v1, 0xA0($v0)		# GS.display2 = ..
	jr	$ra
	nop

#------------------------------------------------------------------------
