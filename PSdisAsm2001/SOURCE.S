# PS2 Test code by now3d  http://www.psxdev.freeserve.co.uk/
	.file	1 "new.c"
gcc2_compiled.:
__gnu_compiled_c:
	.text
	.p2align 3
	.globl	main
	.ent	main
main:
	.frame	$fp,32,$31		# vars= 0, regs= 4/0, args= 0, extra= 0
	.mask	0xc0000000,-16
	.fmask	0x00000000,0
	subu	$sp,$sp,32
	sd	$31,16($sp)
	sd	$fp,0($sp)
	move	$fp,$sp
	jal	__main
$L2:
	move	$sp,$fp
	ld	$31,16($sp)
	ld	$fp,0($sp)
	addu	$sp,$sp,32
	j	$31
	.end	main
