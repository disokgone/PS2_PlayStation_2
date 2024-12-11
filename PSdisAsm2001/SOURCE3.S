# PS2 Test code by now3d  http://www.psxdev.freeserve.co.uk/
	.file	1 "new.c"
gcc2_compiled.:
__gnu_compiled_cplusplus:
	.text
	.p2align 3
	.globl	main
$LFB1:
	.ent	main
main:
	.frame	$fp,32,$31		# vars= 0, regs= 4/0, args= 0, extra= 0
	.mask	0xc0000000,-16
	.fmask	0x00000000,0
	subu	$sp,$sp,32
$LCFI0:
	sd	$31,16($sp)
$LCFI1:
	sd	$fp,0($sp)
$LCFI2:
	move	$fp,$sp
$LCFI3:
	jal	__main
	li	$2,5000			# 0x1388
	sw	$2,y
	sw	$0,x
	.p2align 3
$L3:
	lw	$2,x
	addu	$3,$2,1
	move	$2,$3
	sw	$2,x
	li	$3,1			# 0x1
	bne	$2,$3,$L6
	b	$L4
	.p2align 2
$L6:
	li	$2,20			# 0x14
	sw	$2,z
$L5:
	b	$L3
	.p2align 2
$L4:
	move	$2,$0
	b	$L2
	.p2align 2
$L2:
	move	$sp,$fp
	ld	$31,16($sp)
	ld	$fp,0($sp)
	addu	$sp,$sp,32
	j	$31
	.end	main
$LFE1:
	.globl	x
	.sdata
	.align	2
	.type	 x,@object
	.size	 x,4
x:
	.space	4
	.globl	y
	.align	2
	.type	 y,@object
	.size	 y,4
y:
	.space	4
	.globl	z
	.align	2
	.type	 z,@object
	.size	 z,4
z:
	.space	4

	.data
	.align	2
	.globl	_GLOBAL_$F$main
_GLOBAL_$F$main:
__FRAME_BEGIN__:
	.4byte	$LECIE1-$LSCIE1
$LSCIE1:
	.4byte	0x0
	.byte	0x1
	.byte	0x0
	.byte	0x1
	.byte	0x78
	.byte	0x40
	.byte	0xc
	.byte	0x1d
	.byte	0x0
	.byte	0x9
	.byte	0x40
	.byte	0x1f
	.align	2
$LECIE1:
	.4byte	$LEFDE1-$LSFDE1
$LSFDE1:
	.4byte	$LSFDE1-__FRAME_BEGIN__
	.4byte	$LFB1
	.4byte	$LFE1-$LFB1
	.byte	0x4
	.4byte	$LCFI0-$LFB1
	.byte	0xe
	.byte	0x20
	.byte	0x4
	.4byte	$LCFI1-$LCFI0
	.byte	0x5
	.byte	0x40
	.byte	0x2
	.byte	0x4
	.4byte	$LCFI2-$LCFI1
	.byte	0x9e
	.byte	0x4
	.byte	0x4
	.4byte	$LCFI3-$LCFI2
	.byte	0xc
	.byte	0x1e
	.byte	0x20
	.align	2
$LEFDE1:
	.4byte	0x0
	.align	0
