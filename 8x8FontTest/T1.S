	.file	1 "t1.c"
gcc2_compiled.:
__gnu_compiled_c:
	.rdata
	.align	3
$LC0:
	.ascii	"app = %d\000"
	.text
	.p2align 3
	.globl	test
	.ent	test
test:
	.frame	$fp,80,$31		# vars= 48, regs= 4/0, args= 0, extra= 0
	.mask	0xc0000000,-16
	.fmask	0x00000000,0
	subu	$sp,$sp,80
	sd	$31,64($sp)
	sd	$fp,48($sp)
	move	$fp,$sp
	sw	$4,0($fp)	a
	sw	$5,4($fp)	b
	sw	$6,8($fp)	c
	sw	$7,12($fp)	d
	sw	$8,16($fp)	e
	sw	$9,20($fp)	f
	sw	$10,24($fp)	g
	sw	$11,28($fp)	h
	lw	$4,32($fp)	;buf
	la	$5,$LC0
	lw	$6,36($fp)	;app
	jal	sprintf

	lw	$2,16($fp)	e
	lw	$3,20($fp)	f
	addu	$2,$2,$3	
	sw	$2,0($fp)	a

	lw	$2,24($fp)	g
	lw	$3,28($fp)	h
	addu	$2,$2,$3
	sw	$2,4($fp)	b

	lw	$2,80($fp)	i
	lw	$3,88($fp)	j
	addu	$2,$2,$3
	sw	$2,8($fp)	c
$L2:
	move	$sp,$fp
	ld	$31,64($sp)
	ld	$fp,48($sp)
	addu	$sp,$sp,80
	j	$31
	.end	test
