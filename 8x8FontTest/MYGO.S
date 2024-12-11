	.file	1 "mygo.c"
gcc2_compiled.:
__gnu_compiled_c:
	.globl	eg14
	.rdata
	.align	3
$LC0:
	.ascii	"cdrom0:\\PS2_%02X.EXE;1\000"
	.sdata
	.align	2
	.type	 eg14,@object
	.size	 eg14,4
eg14:
	.word	$LC0
	.text
	.p2align 3
	.globl	myGo
	.ent	myGo
myGo:
	.frame	$fp,96,$31		# vars= 64, regs= 4/0, args= 0, extra= 0
	.mask	0xc0000000,-16
	.fmask	0x00000000,0
	subu	$sp,$sp,96
	sd	$31,80($sp)
	sd	$fp,64($sp)
	move	$fp,$sp
	jal	testVBlank
	sw	$0,dumpmode
	li	$2,1441792			# 0x160000
	ori	$2,$2,0xb5e8
	sw	$2,dumploc
	jal	Ar2Sys
	sw	$2,ctrl
	lw	$3,ctrl
	addu	$2,$3,8
	lw	$3,0($2)
	sw	$3,x
	lw	$3,ctrl
	addu	$2,$3,12
	lw	$3,0($2)
	sw	$3,xlen
	lw	$4,pkt
	lw	$5,x
	li	$6,8			# 0x8
	lw	$7,xlen
	li	$8,256			# 0x100
	move	$9,$0
	jal	drawFrame
	li	$4,10240			# 0x2800
	jal	malloc
	sw	$2,pkt
	li	$4,8			# 0x8
	jal	malloc
	sw	$2,ctrl
	lw	$4,pkt
	lw	$5,ctrl
	jal	beginPacket
	move	$4,$0
	jal	sceCdDiskReady
	sw	$2,60($fp)
	move	$4,$fp
	la	$5,fn1
	jal	sceCdSearchFile
	sw	$2,48($fp)
	move	$4,$fp
	la	$5,fn2
	jal	sceCdSearchFile
	sw	$2,52($fp)
	move	$4,$fp
	la	$5,fn3
	jal	sceCdSearchFile
	sw	$2,56($fp)
	move	$4,$fp
	la	$5,mess1
	lw	$6,60($fp)
	lw	$7,48($fp)
	lw	$8,52($fp)
	lw	$9,56($fp)
	lw	$10,x
	lw	$11,xlen
	jal	sprintf
	lw	$4,pkt
	li	$5,16			# 0x10
	li	$6,48			# 0x30
	move	$7,$fp
	jal	drawBitMap
	la	$4,fn1
	la	$5,fn2
	la	$6,fn3
	jal	messageBox3
	jal	ExecGame
$L2:
	move	$sp,$fp
	ld	$31,80($sp)
	ld	$fp,64($sp)
	addu	$sp,$sp,96
	j	$31
	.end	myGo
	.p2align 3
	.globl	ExecGame
	.ent	ExecGame
ExecGame:
	.frame	$fp,144,$31		# vars= 112, regs= 4/0, args= 0, extra= 0
	.mask	0xc0000000,-16
	.fmask	0x00000000,0
	subu	$sp,$sp,144
	sd	$31,128($sp)
	sd	$fp,112($sp)
	move	$fp,$sp
	move	$4,$0
	jal	sceCdDiskReady
	sw	$2,108($fp)
	lw	$4,pkt
	lw	$5,x
	li	$6,8			# 0x8
	lw	$7,xlen
	li	$8,256			# 0x100
	move	$9,$0
	jal	drawFrame
	sw	$0,100($fp)
	sw	$0,104($fp)
	.p2align 3
$L4:
	addu	$2,$fp,48
	move	$4,$2
	la	$5,eg01
	lw	$6,104($fp)
	jal	sprintf
	lw	$4,pkt
	li	$5,24			# 0x18
	li	$6,120			# 0x78
	move	$7,$fp
	jal	drawBitMap
	lw	$4,100($fp)
	jal	waitPad
	sw	$2,100($fp)
	lw	$2,100($fp)
	li	$3,4096			# 0x1000
	bne	$2,$3,$L7
	lw	$2,104($fp)
	addu	$3,$2,-1
	sw	$3,104($fp)
	lw	$2,104($fp)
	bgez	$2,$L7
	li	$2,999			# 0x3e7
	sw	$2,104($fp)
$L8:
$L7:
	lw	$2,100($fp)
	li	$3,16384			# 0x4000
	bne	$2,$3,$L6
	lw	$2,104($fp)
	addu	$3,$2,1
	sw	$3,104($fp)
	lw	$2,104($fp)
	slt	$3,$2,1000
	bne	$3,$0,$L6
	sw	$0,104($fp)
$L10:
$L9:
$L6:
	lw	$2,100($fp)
	li	$3,2048			# 0x800
	bne	$2,$3,$L11
	b	$L5
	.p2align 2
$L11:
	b	$L4
	.p2align 2
$L5:
	addu	$2,$fp,48
	move	$4,$fp
	move	$5,$2
	jal	sceCdSearchFile
	sw	$2,96($fp)
	move	$4,$fp
	la	$5,eg02
	lw	$6,96($fp)
	jal	sprintf
	addu	$2,$fp,48
	la	$4,eg03
	move	$5,$2
	move	$6,$fp
	jal	messageBox3
	move	$4,$fp
	la	$5,eg04
	lw	$6,104($fp)
	jal	sprintf
	li	$4,1507328			# 0x170000
	ori	$4,$4,0x4560
	move	$5,$fp
	jal	ustrcpy
	li	$4,1			# 0x1
	move	$5,$0
	jal	loadRunELF_Program
$L3:
	move	$sp,$fp
	ld	$31,128($sp)
	ld	$fp,112($sp)
	addu	$sp,$sp,144
	j	$31
	.end	ExecGame
