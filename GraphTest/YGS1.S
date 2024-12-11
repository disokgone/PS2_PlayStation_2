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
	subu	$29, $29, 0x10
	sd	$31, 0($29)

	li	$4, 0x0000FF00		# 清除了 low 8 bits
	ld	$2, csr
	dsrl	$2, 16
	andi	$2, 0xFF
	jal	GsPutIMR
	daddu	$2, $0, $0	# return 0

	ld	$31, 0($29)
	jr	$31
	addiu	$29, $29, 0x10
.end gs_set_imr

#------------------------------------------------------------------------
# void Init_GS(int intlace, int ntscpal, int framefield);
#	// intlace : 0=非交錯, 1=交錯
#	// ntscpal : 2=NTSC, 3=PAL
#	// framefield : 1=frame, 2=field
#------------------------------------------------------------------------
Init_GS:
	subu	$29, $29, 0x10
	sd	$31, 0($29)

	addu	$17, $4, $0
	addu	$18, $5, $0
	addu	$19, $6, $0

	la	$2, csr
	li	$3, 0x200
	sd	$3, 0($2)		# reset GS !

	ori	$4, $0, 0xFF00
	ld	$2, 0($2)
	dsrl	$2, $2, 16
	andi	$2, $2, 0xFF
	jal	GsPutIMR		# <syscall $71>  PutIMR(int maskBits) <set to GS.csr>
	nop

	andi	$4, $17, 1
	andi	$5, $18, 0xFF
	andi	$6, $19, 1
	jal	SetGsCrt		# <syscall $02> SetGsCrt(?, ?, ?)
	nop

	ld	$31, 0($29)
	jr	$31
	addiu	$29, $29, 0x10

#------------------------------------------------------------------------
# void SetVideoMode(void);
#------------------------------------------------------------------------
SetVideoMode:
	lui	$2, 0x1200
	ori	$3, $0, 0xFF62
	sd	$3, 0($2)		# GS.pmode = 0x00FF62

	addiu	$3, $0, 2
	sd	$3, 0x20($2)		# GS.smode = { INT=0, FFMD=1, DPMS=0 }

	addiu	$3, $0, 0x1400
	sd	$3, 0x90($2)		# GS.dispfb2 = 0x1400

	li	$3, 0x000DF9FF01824290
	sd	$3, 0xA0($2)		# GS.display2 = ..
	jr	$31
	nop

#------------------------------------------------------------------------
