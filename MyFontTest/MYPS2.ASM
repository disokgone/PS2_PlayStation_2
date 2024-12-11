	.file	1 "myps2.c"
gcc2_compiled.:
__gnu_compiled_c:
	.globl	errX
	.sdata
	.align	2
	.type	 errX,@object
	.size	 errX,4
errX:
	.word	1
	.globl	errY
	.align	2
	.type	 errY,@object
	.size	 errY,4
errY:
	.word	13
	.globl	old_pad
	.align	2
	.type	 old_pad,@object
	.size	 old_pad,4
old_pad:
	.word	0
	.globl	usable
	.data
	.align	3
	.type	 usable,@object
	.size	 usable,34
usable:
	.ascii	" @#$%:!?,<=>+-*/0123456789ABCDEF\000"
	.space	1
	.globl	hex
	.align	3
	.type	 hex,@object
	.size	 hex,18
hex:
	.ascii	"0123456789ABCDEF\000"
	.space	1
	.globl	chinmode
	.sdata
	.type	 chinmode,@object
	.size	 chinmode,1
chinmode:
	.byte	0
	.align	3
$LC0:
	.ascii	"Go ! \n\000"
	.rdata
	.align	3
$LC1:
	.ascii	"pFont2 = %X\000"
	.align	3
$LC2:
	.ascii	"ABCDEF :\000"
	.align	3
$LC3:
	.ascii	"readChineseFont = %d\000"
	.align	3
$LC4:
	.ascii	"Go : %d, pFont1 = %X\n\000"
	.sdata
	.align	3
$LC5:
	.ascii	"Bye ! \n\000"
	.text
	.align	3
	.globl	_main
	.text
	.ent	_main
_main:
	.frame	$sp,32,$31		# vars= 0, regs= 4/0, args= 0, extra= 0
	.mask	0x80010000,-16
	.fmask	0x00000000,0
	subu	$sp,$sp,32
	sd	$16,0($sp)
	sd	$31,16($sp)
	.set	noreorder
	.set	nomacro
	jal	init_Screen
	li	$16,4325376			# 0x420000
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	sif_rpc_init
	move	$4,$0
	.set	macro
	.set	reorder

	jal	install_VRstart_handler
	jal	iHookEERW
	lui	$4,%hi($LC0) # high
	.set	noreorder
	.set	nomacro
	jal	nputs
	addiu	$4,$4,%lo($LC0) # low
	.set	macro
	.set	reorder

	lui	$4,%hi($LC1) # high
	lw	$5,pFont
	.set	noreorder
	.set	nomacro
	jal	nprintf
	addiu	$4,$4,%lo($LC1) # low
	.set	macro
	.set	reorder

	jal	go_down
	jal	do_pad_init
	sw	$16,pFont1
	.set	noreorder
	.set	nomacro
	jal	readMyFont
	li	$4,4325376			# 0x420000
	.set	macro
	.set	reorder

	jal	loadfontA
	li	$2,41280			# 0xa140
	li	$3,4096			# 0x1000
	li	$5,4			# 0x4
	sw	$16,dumpAddr
	sw	$2,nchi
	li	$4,4325376			# 0x420000
	sw	$3,dumpLen
	sw	$5,TimeSlic
	sw	$0,scrY
	.set	noreorder
	.set	nomacro
	jal	dump
	sw	$0,scrX
	.set	macro
	.set	reorder

	lw	$3,dumpLen
	lui	$6,%hi($LC2) # high
	sw	$2,dumpAddr
	addiu	$6,$6,%lo($LC2) # low
	addu	$3,$3,-64
	move	$4,$0
	sw	$3,dumpLen
	.set	noreorder
	.set	nomacro
	jal	gputs
	move	$5,$0
	.set	macro
	.set	reorder

	lbu	$4,nowDraw
	#nop
	addu	$4,$4,48
	sll	$4,$4,24
	.set	noreorder
	.set	nomacro
	jal	gputc
	sra	$4,$4,24
	.set	macro
	.set	reorder

	jal	go_down
	jal	readChineseFont
	lui	$4,%hi($LC3) # high
	move	$5,$2
	addiu	$4,$4,%lo($LC3) # low
	.set	noreorder
	.set	nomacro
	jal	nprintf
	sw	$2,fd
	.set	macro
	.set	reorder

	lui	$4,%hi($LC4) # high
	li	$5,66			# 0x42
	la	$6,pFont1
	.set	noreorder
	.set	nomacro
	jal	nprintf
	addiu	$4,$4,%lo($LC4) # low
	.set	macro
	.set	reorder

	jal	mainLoop
	lui	$4,%hi($LC5) # high
	.set	noreorder
	.set	nomacro
	jal	nputs
	addiu	$4,$4,%lo($LC5) # low
	.set	macro
	.set	reorder

	jal	go_down
	ld	$31,16($sp)
	move	$2,$0
	ld	$16,0($sp)
	#nop
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$sp,$sp,32
	.set	macro
	.set	reorder

	.end	_main
	.sdata
	.align	3
$LC6:
	.ascii	"   $\000"
	.align	3
$LC7:
	.ascii	" --\000"
	.text
	.align	3
	.globl	init_Screen
	.text
	.ent	init_Screen
init_Screen:
	.frame	$sp,16,$31		# vars= 0, regs= 2/0, args= 0, extra= 0
	.mask	0x80000000,-16
	.fmask	0x00000000,0
	subu	$sp,$sp,16
	sd	$31,0($sp)
	jal	gs_is_ntsc
	beq	$2,$0,$L18
	.set	noreorder
	.set	nomacro
	jal	g2_init
	li	$4,9			# 0x9
	.set	macro
	.set	reorder

	b	$L19
	.align	2
$L18:
	.set	noreorder
	.set	nomacro
	jal	g2_init
	li	$4,4			# 0x4
	.set	macro
	.set	reorder

$L19:
	jal	g2_get_max_x
	.set	noreorder
	.set	nomacro
	jal	g2_get_max_y
	sw	$2,maxx
	.set	macro
	.set	reorder

	sw	$2,maxy
	.set	noreorder
	.set	nomacro
	jal	g2_set_active_frame
	move	$4,$0
	.set	macro
	.set	reorder

	move	$4,$0
	move	$5,$0
	.set	noreorder
	.set	nomacro
	jal	g2_set_fill_color
	move	$6,$0
	.set	macro
	.set	reorder

	lh	$6,maxx
	move	$4,$0
	lh	$7,maxy
	.set	noreorder
	.set	nomacro
	jal	g2_fill_rect
	move	$5,$0
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	g2_set_visible_frame
	move	$4,$0
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	g2_set_active_frame
	li	$4,1			# 0x1
	.set	macro
	.set	reorder

	move	$4,$0
	move	$5,$0
	.set	noreorder
	.set	nomacro
	jal	g2_set_fill_color
	move	$6,$0
	.set	macro
	.set	reorder

	lh	$6,maxx
	move	$4,$0
	lh	$7,maxy
	.set	noreorder
	.set	nomacro
	jal	g2_fill_rect
	move	$5,$0
	.set	macro
	.set	reorder

	ld	$31,0($sp)
	sw	$0,nowDraw
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$sp,$sp,16
	.set	macro
	.set	reorder

	.end	init_Screen
	.rdata
	.align	3
$LC8:
	.ascii	"cdrom0:\\NAPLINK.ELF;1\000"
	.align	3
$LC9:
	.ascii	"cdrom0:\\3_STARS.EXE;1\000"
	.text
	.align	3
	.globl	mainLoop
	.text
	.ent	mainLoop
mainLoop:
	.frame	$sp,192,$31		# vars= 32, regs= 20/0, args= 0, extra= 0
	.mask	0xc0ff0000,-16
	.fmask	0x00000000,0
	subu	$sp,$sp,192
	sd	$fp,160($sp)
	sd	$23,144($sp)
	lui	$fp,%hi($LC8) # high
	sd	$22,128($sp)
	li	$23,1			# 0x1
	sd	$21,112($sp)
	move	$22,$0
	sd	$20,96($sp)
	li	$21,99			# 0x63
	sd	$31,176($sp)
	move	$20,$0
	sd	$19,80($sp)
	sd	$18,64($sp)
	sd	$17,48($sp)
	sd	$16,32($sp)
	.align	3
$L23:
	.set	noreorder
	.set	nomacro
	jal	SetDrawTo
	lw	$4,nowDraw
	.set	macro
	.set	reorder

	lw	$2,nowDraw
	move	$4,$0
	move	$5,$0
	move	$6,$0
	xori	$2,$2,0x1
	.set	noreorder
	.set	nomacro
	jal	g2_set_fill_color
	sw	$2,nowDraw
	.set	macro
	.set	reorder

	move	$4,$0
	move	$5,$0
	li	$6,639			# 0x27f
	.set	noreorder
	.set	nomacro
	jal	g2_fill_rect
	li	$7,200			# 0xc8
	.set	macro
	.set	reorder

	lui	$2,%hi($LC6) # high
	lw	$17,dumpAddr
	li	$4,3			# 0x3
	li	$5,1			# 0x1
	addiu	$6,$2,%lo($LC6) # low
	.set	noreorder
	.set	nomacro
	jal	gputs
	addu	$19,$17,64
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	prtInt
	move	$4,$17
	.set	macro
	.set	reorder

	lui	$3,%hi($LC7) # high
	li	$4,15			# 0xf
	li	$5,1			# 0x1
	.set	noreorder
	.set	nomacro
	jal	gputs
	addiu	$6,$3,%lo($LC7) # low
	.set	macro
	.set	reorder

	move	$3,$0
	addu	$2,$3,2
	.align	3
$L51:
	sw	$23,scrX
	sw	$2,scrY
	addu	$18,$3,1
	li	$16,7			# 0x7
	lbu	$4,0($17)
	.align	3
$L50:
	addu	$16,$16,-1
	.set	noreorder
	.set	nomacro
	jal	prtByte
	addu	$17,$17,1
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	gputc
	li	$4,32			# 0x20
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	bgezl	$16,$L50
	lbu	$4,0($17)
	.set	macro
	.set	reorder

	move	$3,$18
	slt	$2,$3,8
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L51
	addu	$2,$3,2
	.set	macro
	.set	reorder

	lw	$2,dumpLen
	lui	$3,%hi($LC2) # high
	move	$4,$0
	sw	$19,dumpAddr
	addu	$2,$2,-64
	move	$5,$0
	addiu	$6,$3,%lo($LC2) # low
	.set	noreorder
	.set	nomacro
	jal	gputs
	sw	$2,dumpLen
	.set	macro
	.set	reorder

	lbu	$4,nowDraw
	#nop
	addu	$4,$4,48
	sll	$4,$4,24
	.set	noreorder
	.set	nomacro
	jal	gputc
	sra	$4,$4,24
	.set	macro
	.set	reorder

	li	$4,255			# 0xff
	li	$5,255			# 0xff
	.set	noreorder
	.set	nomacro
	jal	g2_set_color
	li	$6,255			# 0xff
	.set	macro
	.set	reorder

	move	$4,$0
	move	$5,$0
	li	$6,639			# 0x27f
	.set	noreorder
	.set	nomacro
	jal	g2_line
	li	$7,223			# 0xdf
	.set	macro
	.set	reorder

	li	$4,255			# 0xff
	li	$5,255			# 0xff
	.set	noreorder
	.set	nomacro
	jal	g2_set_color
	move	$6,$0
	.set	macro
	.set	reorder

	li	$4,4			# 0x4
	move	$5,$0
	li	$6,600			# 0x258
	.set	noreorder
	.set	nomacro
	jal	g2_line
	move	$7,$0
	.set	macro
	.set	reorder

	li	$4,255			# 0xff
	move	$5,$0
	.set	noreorder
	.set	nomacro
	jal	g2_set_color
	li	$6,255			# 0xff
	.set	macro
	.set	reorder

	li	$4,600			# 0x258
	move	$5,$0
	li	$6,600			# 0x258
	.set	noreorder
	.set	nomacro
	jal	g2_line
	li	$7,223			# 0xdf
	.set	macro
	.set	reorder

	move	$4,$0
	li	$5,255			# 0xff
	.set	noreorder
	.set	nomacro
	jal	g2_set_color
	li	$6,255			# 0xff
	.set	macro
	.set	reorder

	li	$4,600			# 0x258
	li	$5,223			# 0xdf
	li	$6,4			# 0x4
	.set	noreorder
	.set	nomacro
	jal	g2_line
	li	$7,223			# 0xdf
	.set	macro
	.set	reorder

	li	$4,255			# 0xff
	li	$5,220			# 0xdc
	.set	noreorder
	.set	nomacro
	jal	g2_set_color
	li	$6,128			# 0x80
	.set	macro
	.set	reorder

	li	$4,4			# 0x4
	li	$5,223			# 0xdf
	li	$6,4			# 0x4
	.set	noreorder
	.set	nomacro
	jal	g2_line
	move	$7,$0
	.set	macro
	.set	reorder

	li	$4,145			# 0x91
	li	$5,230			# 0xe6
	.set	noreorder
	.set	nomacro
	jal	g2_set_fill_color
	li	$6,98			# 0x62
	.set	macro
	.set	reorder

	li	$4,60			# 0x3c
	li	$5,30			# 0x1e
	li	$6,560			# 0x230
	.set	noreorder
	.set	nomacro
	jal	g2_fill_rect
	li	$7,60			# 0x3c
	.set	macro
	.set	reorder

	move	$4,$0
	move	$5,$0
	li	$6,186			# 0xba
	.set	noreorder
	.set	nomacro
	jal	g2_fill_rect
	li	$7,16			# 0x10
	.set	macro
	.set	reorder

	li	$4,126			# 0x7e
	li	$5,158			# 0x9e
	li	$6,320			# 0x140
	.set	noreorder
	.set	nomacro
	jal	g2_fill_rect
	li	$7,176			# 0xb0
	.set	macro
	.set	reorder

	move	$4,$0
	.set	noreorder
	.set	nomacro
	jal	setDisplayOfs
	move	$5,$20
	.set	macro
	.set	reorder

	move	$4,$0
	move	$5,$0
	.set	noreorder
	.set	nomacro
	jal	padRead
	move	$6,$sp
	.set	macro
	.set	reorder

	sll	$2,$2,24
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L28
	lbu	$2,2($sp)
	.set	macro
	.set	reorder

	move	$16,$0
	lbu	$4,3($sp)
	sll	$2,$2,8
	lw	$3,old_pad
	or	$2,$2,$4
	xori	$2,$2,0xffff
	nor	$3,$0,$3
	move	$4,$2
	and	$5,$4,$3
	andi	$2,$5,0x4
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L48
	move	$6,$4
	.set	macro
	.set	reorder

	sw	$5,new_pad
	addiu	$4,$fp,%lo($LC8) # low
	sw	$6,paddata
	move	$5,$0
	sw	$6,old_pad
	.set	noreorder
	.set	nomacro
	jal	LoadExecPS2
	move	$6,$0
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	Exit
	move	$4,$0
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	b	$L49
	lw	$5,new_pad
	.set	macro
	.set	reorder

	.align	2
$L48:
	#nop
	sw	$5,new_pad
	sw	$4,old_pad
	sw	$4,paddata
	lw	$5,new_pad
$L49:
	andi	$2,$5,0x1
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L52
	andi	$2,$5,0x8
	.set	macro
	.set	reorder

 #APP
	 j 0xA0000
 #NO_APP
	andi	$2,$5,0x8
$L52:
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L31
	lui	$2,%hi($LC9) # high
	.set	macro
	.set	reorder

	move	$5,$0
	addiu	$4,$2,%lo($LC9) # low
	.set	noreorder
	.set	nomacro
	jal	LoadExecPS2
	move	$6,$0
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	Exit
	move	$4,$0
	.set	macro
	.set	reorder

	lw	$5,new_pad
$L31:
	andi	$2,$5,0x800
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L53
	lw	$4,paddata
	.set	macro
	.set	reorder

	li	$16,32			# 0x20
	move	$20,$0
$L53:
	andi	$2,$4,0x1000
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L33
	li	$2,-1			# 0xffffffffffffffff
	.set	macro
	.set	reorder

	addu	$20,$20,-8
	slt	$2,$2,$20
	li	$3,2040			# 0x7f8
	movz	$20,$3,$2
	li	$16,4			# 0x4
$L33:
	andi	$2,$4,0x4000
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L54
	andi	$2,$4,0x2000
	.set	macro
	.set	reorder

	addu	$20,$20,8
	li	$16,8			# 0x8
	slt	$2,$20,2041
	movz	$20,$0,$2
	andi	$2,$4,0x2000
$L54:
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L37
	xori	$2,$21,0x1
	.set	macro
	.set	reorder

	movn	$16,$23,$2
$L37:
	andi	$2,$4,0x8000
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L39
	li	$3,2			# 0x2
	.set	macro
	.set	reorder

	xori	$2,$21,0x2
	movn	$16,$3,$2
$L39:
	andi	$2,$5,0x100
	beq	$2,$0,$L41
	.set	noreorder
	.set	nomacro
	jal	mainLoop2
	li	$16,16			# 0x10
	.set	macro
	.set	reorder

$L41:
	.set	noreorder
	.set	nomacro
	beq	$16,$0,$L42
	addu	$22,$22,1
	.set	macro
	.set	reorder

	move	$21,$16
	move	$22,$0
$L42:
	slt	$2,$22,9
	bne	$2,$0,$L28
	li	$21,99			# 0x63
	move	$22,$0
$L28:
	.set	noreorder
	.set	nomacro
	jal	WaitForNextVRstart
	li	$4,1			# 0x1
	.set	macro
	.set	reorder

	b	$L23
	.end	mainLoop
	.align	3
	.globl	mainLoop2
	.text
	.ent	mainLoop2
mainLoop2:
	.frame	$sp,112,$31		# vars= 32, regs= 10/0, args= 0, extra= 0
	.mask	0x800f0000,-16
	.fmask	0x00000000,0
	subu	$sp,$sp,112
	move	$4,$0
	sd	$19,80($sp)
	move	$5,$0
	sd	$18,64($sp)
	sd	$17,48($sp)
	li	$19,1			# 0x1
	sd	$16,32($sp)
	move	$17,$0
	sd	$31,96($sp)
	.set	noreorder
	.set	nomacro
	jal	setDisplayOfs
	li	$16,99			# 0x63
	.set	macro
	.set	reorder

	li	$18,9			# 0x9
	.align	3
$L58:
	.set	noreorder
	.set	nomacro
	jal	SetDrawTo
	lw	$4,nowDraw
	.set	macro
	.set	reorder

	lw	$2,nowDraw
	move	$4,$0
	move	$5,$0
	move	$6,$0
	xori	$2,$2,0x1
	.set	noreorder
	.set	nomacro
	jal	g2_set_fill_color
	sw	$2,nowDraw
	.set	macro
	.set	reorder

	move	$4,$0
	move	$5,$0
	li	$6,639			# 0x27f
	.set	noreorder
	.set	nomacro
	jal	g2_fill_rect
	li	$7,223			# 0xdf
	.set	macro
	.set	reorder

	lb	$2,chinmode
	#nop
	beq	$2,$0,$L59
	.set	noreorder
	.set	nomacro
	jal	test_chin_24
	lw	$4,nchi
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	b	$L76
	move	$4,$0
	.set	macro
	.set	reorder

	.align	2
$L59:
	.set	noreorder
	.set	nomacro
	jal	test_chin_16
	lw	$4,nchi
	.set	macro
	.set	reorder

	#nop
	move	$4,$0
$L76:
	move	$5,$0
	.set	noreorder
	.set	nomacro
	jal	padRead
	move	$6,$sp
	.set	macro
	.set	reorder

	sll	$2,$2,24
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L61
	lbu	$2,2($sp)
	.set	macro
	.set	reorder

	move	$6,$0
	lbu	$4,3($sp)
	sll	$2,$2,8
	lw	$3,old_pad
	or	$2,$2,$4
	xori	$5,$2,0xffff
	nor	$3,$0,$3
	and	$7,$5,$3
	andi	$2,$7,0x4
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L55
	move	$8,$5
	.set	macro
	.set	reorder

	andi	$2,$7,0x800
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L63
	li	$3,41280			# 0xa140
	.set	macro
	.set	reorder

	li	$6,32			# 0x20
	sw	$3,nchi
$L63:
	andi	$3,$8,0x1000
	li	$2,4			# 0x4
	movn	$6,$2,$3
	andi	$4,$8,0x4000
	li	$2,8			# 0x8
	andi	$3,$8,0x2000
	.set	noreorder
	.set	nomacro
	beq	$3,$0,$L66
	movn	$6,$2,$4
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	beq	$16,$19,$L66
	lb	$2,chinmode
	.set	macro
	.set	reorder

	li	$6,1			# 0x1
	lw	$3,nchi
	subu	$2,$18,$2
	sll	$2,$6,$2
	addu	$3,$3,$2
	sw	$3,nchi
$L66:
	andi	$2,$5,0x8000
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L68
	sw	$5,paddata
	.set	macro
	.set	reorder

	li	$2,2			# 0x2
	.set	noreorder
	.set	nomacro
	beq	$16,$2,$L68
	lb	$2,chinmode
	.set	macro
	.set	reorder

	li	$6,2			# 0x2
	lw	$3,nchi
	subu	$2,$18,$2
	sll	$2,$19,$2
	subu	$3,$3,$2
	sw	$3,nchi
$L68:
	andi	$2,$7,0x100
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L70
	sw	$7,new_pad
	.set	macro
	.set	reorder

	lbu	$2,chinmode
	li	$6,16			# 0x10
	xori	$2,$2,0x1
	sb	$2,chinmode
$L70:
	.set	noreorder
	.set	nomacro
	beq	$6,$0,$L71
	addu	$17,$17,1
	.set	macro
	.set	reorder

	move	$16,$6
	move	$17,$0
$L71:
	slt	$2,$17,9
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L75
	sw	$8,old_pad
	.set	macro
	.set	reorder

	li	$16,99			# 0x63
	move	$17,$0
$L75:
$L61:
	.set	noreorder
	.set	nomacro
	jal	WaitForNextVRstart
	li	$4,1			# 0x1
	.set	macro
	.set	reorder

	b	$L58
	.align	2
$L55:
	ld	$31,96($sp)
	ld	$19,80($sp)
	ld	$18,64($sp)
	ld	$17,48($sp)
	ld	$16,32($sp)
	sw	$5,paddata
	sw	$7,new_pad
	sw	$8,old_pad
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$sp,$sp,112
	.set	macro
	.set	reorder

	.end	mainLoop2
	.align	3
	.globl	ptInt
	.text
	.ent	ptInt
ptInt:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	srl	$6,$4,24
	lui	$5,%hi(hex) # high
	addiu	$5,$5,%lo(hex) # low
	srl	$2,$6,4
	addu	$2,$2,$5
	lw	$9,pbuf
	lbu	$8,0($2)
	andi	$6,$6,0xf
	addu	$6,$6,$5
	srl	$3,$4,16
	sb	$8,0($9)
	andi	$3,$3,0x00ff
	srl	$8,$3,4
	srl	$7,$4,8
	lw	$10,pbuf
	addu	$8,$8,$5
	lbu	$11,0($6)
	andi	$7,$7,0x00ff
	addu	$2,$10,1
	andi	$4,$4,0x00ff
	sw	$2,pbuf
	srl	$9,$7,4
	sb	$11,1($10)
	andi	$3,$3,0xf
	srl	$10,$4,4
	andi	$7,$7,0xf
	lw	$6,pbuf
	andi	$4,$4,0xf
	lbu	$11,0($8)
	addu	$3,$3,$5
	addu	$2,$6,1
	addu	$9,$9,$5
	sw	$2,pbuf
	addu	$7,$7,$5
	sb	$11,1($6)
	addu	$10,$10,$5
	addu	$4,$4,$5
	lw	$6,pbuf
	lbu	$5,0($3)
	addu	$2,$6,1
	sw	$2,pbuf
	sb	$5,1($6)
	lw	$3,pbuf
	lbu	$6,0($9)
	addu	$2,$3,1
	sw	$2,pbuf
	sb	$6,1($3)
	lw	$5,pbuf
	lbu	$6,0($7)
	addu	$2,$5,1
	sw	$2,pbuf
	sb	$6,1($5)
	lw	$3,pbuf
	lbu	$6,0($10)
	addu	$2,$3,1
	sw	$2,pbuf
	sb	$6,1($3)
	lw	$5,pbuf
	lbu	$3,0($4)
	addu	$2,$5,1
	sw	$2,pbuf
	sb	$3,1($5)
	lw	$2,pbuf
	#nop
	addu	$2,$2,1
	.set	noreorder
	.set	nomacro
	j	$31
	sw	$2,pbuf
	.set	macro
	.set	reorder

	.end	ptInt
	.align	3
	.globl	prtByte
	.text
	.ent	prtByte
prtByte:
	.frame	$sp,64,$31		# vars= 0, regs= 8/0, args= 0, extra= 0
	.mask	0x80070000,-16
	.fmask	0x00000000,0
	subu	$sp,$sp,64
	andi	$4,$4,0x00ff
	sd	$18,32($sp)
	andi	$6,$4,0xf
	lui	$18,%hi(hex) # high
	sd	$31,48($sp)
	addiu	$2,$18,%lo(hex) # low
	sd	$17,16($sp)
	sd	$16,0($sp)
	srl	$4,$4,4
	lw	$3,scrX
	addu	$4,$4,$2
	lw	$5,scrY
	andi	$3,$3,0x1f
	lb	$9,0($4)
	andi	$5,$5,0xf
	slt	$2,$3,40
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L124
	move	$4,$5
	.set	macro
	.set	reorder

	addu	$4,$5,1
	move	$3,$0
$L124:
	move	$5,$4
	slt	$2,$5,14
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L125
	sw	$4,scrY
	.set	macro
	.set	reorder

	sw	$0,scrY
	move	$5,$0
$L125:
	lui	$17,%hi(usable) # high
	lb	$2,%lo(usable)($17)
	#nop
	.set	noreorder
	.set	nomacro
	beq	$9,$2,$L144
	move	$4,$0
	.set	macro
	.set	reorder

	sw	$3,scrX
	move	$7,$3
	lw	$8,nowDraw
	andi	$16,$6,0x00ff
	addu	$4,$4,1
	.align	3
$L146:
	slt	$6,$4,32
	.set	noreorder
	.set	nomacro
	beq	$6,$0,$L129
	addiu	$2,$17,%lo(usable) # low
	.set	macro
	.set	reorder

	addu	$2,$4,$2
	lb	$3,0($2)
	#nop
	.set	noreorder
	.set	nomacro
	bnel	$9,$3,$L146
	addu	$4,$4,1
	.set	macro
	.set	reorder

	b	$L128
	.align	2
$L144:
	andi	$16,$6,0x00ff
	sw	$3,scrX
	lw	$8,nowDraw
	move	$7,$3
	li	$6,1			# 0x1
$L128:
	.set	noreorder
	.set	nomacro
	beq	$6,$0,$L129
	andi	$2,$4,0xf
	.set	macro
	.set	reorder

	li	$6,29360128			# 0x1c00000
	sra	$4,$4,4
	li	$3,30343168			# 0x1cf0000
	movn	$6,$3,$4
	sll	$2,$2,4
	.set	noreorder
	.set	nomacro
	b	$L132
	or	$6,$6,$2
	.set	macro
	.set	reorder

	.align	2
$L129:
	li	$6,29360128			# 0x1c00000
$L132:
	sll	$2,$5,4
	sll	$3,$7,4
	subu	$2,$2,$5
	sll	$2,$2,16
	.set	noreorder
	.set	nomacro
	beq	$8,$0,$L133
	or	$5,$3,$2
	.set	macro
	.set	reorder

	li	$2,14680064			# 0xe00000
	addu	$5,$5,$2
$L133:
	move	$4,$6
	li	$7,15			# 0xf
	.set	noreorder
	.set	nomacro
	jal	vramMove
	li	$6,16			# 0x10
	.set	macro
	.set	reorder

	lw	$3,scrX
	addiu	$2,$18,%lo(hex) # low
	lw	$4,scrY
	addu	$2,$16,$2
	addu	$7,$3,1
	lb	$9,0($2)
	andi	$3,$7,0x1f
	andi	$5,$4,0xf
	slt	$2,$3,40
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L134
	move	$4,$5
	.set	macro
	.set	reorder

	addu	$4,$5,1
	move	$3,$0
$L134:
	move	$5,$4
	slt	$2,$5,14
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L135
	sw	$4,scrY
	.set	macro
	.set	reorder

	sw	$0,scrY
	move	$5,$0
$L135:
	lb	$2,%lo(usable)($17)
	#nop
	.set	noreorder
	.set	nomacro
	beq	$9,$2,$L145
	move	$4,$0
	.set	macro
	.set	reorder

	sw	$3,scrX
	move	$7,$3
	lw	$8,nowDraw
	addu	$4,$4,1
	.align	3
$L147:
	slt	$6,$4,32
	.set	noreorder
	.set	nomacro
	beq	$6,$0,$L139
	addiu	$2,$17,%lo(usable) # low
	.set	macro
	.set	reorder

	addu	$2,$4,$2
	lb	$3,0($2)
	#nop
	.set	noreorder
	.set	nomacro
	bnel	$9,$3,$L147
	addu	$4,$4,1
	.set	macro
	.set	reorder

	b	$L138
	.align	2
$L145:
	sw	$3,scrX
	move	$7,$3
	lw	$8,nowDraw
	li	$6,1			# 0x1
$L138:
	.set	noreorder
	.set	nomacro
	beq	$6,$0,$L139
	andi	$2,$4,0xf
	.set	macro
	.set	reorder

	li	$6,29360128			# 0x1c00000
	sra	$4,$4,4
	li	$3,30343168			# 0x1cf0000
	movn	$6,$3,$4
	sll	$2,$2,4
	.set	noreorder
	.set	nomacro
	b	$L142
	or	$6,$6,$2
	.set	macro
	.set	reorder

	.align	2
$L139:
	li	$6,29360128			# 0x1c00000
$L142:
	sll	$2,$5,4
	sll	$3,$7,4
	subu	$2,$2,$5
	sll	$2,$2,16
	.set	noreorder
	.set	nomacro
	beq	$8,$0,$L143
	or	$5,$3,$2
	.set	macro
	.set	reorder

	li	$2,14680064			# 0xe00000
	addu	$5,$5,$2
$L143:
	move	$4,$6
	li	$7,15			# 0xf
	.set	noreorder
	.set	nomacro
	jal	vramMove
	li	$6,16			# 0x10
	.set	macro
	.set	reorder

	lw	$2,scrX
	ld	$31,48($sp)
	addu	$3,$2,1
	ld	$18,32($sp)
	ld	$17,16($sp)
	ld	$16,0($sp)
	sw	$3,scrX
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$sp,$sp,64
	.set	macro
	.set	reorder

	.end	prtByte
	.align	3
	.globl	prtInt
	.text
	.ent	prtInt
prtInt:
	.frame	$sp,32,$31		# vars= 0, regs= 4/0, args= 0, extra= 0
	.mask	0x80010000,-16
	.fmask	0x00000000,0
	subu	$sp,$sp,32
	sd	$16,0($sp)
	move	$16,$4
	sd	$31,16($sp)
	.set	noreorder
	.set	nomacro
	jal	prtByte
	srl	$4,$16,24
	.set	macro
	.set	reorder

	srl	$4,$16,16
	.set	noreorder
	.set	nomacro
	jal	prtByte
	andi	$4,$4,0x00ff
	.set	macro
	.set	reorder

	srl	$4,$16,8
	.set	noreorder
	.set	nomacro
	jal	prtByte
	andi	$4,$4,0x00ff
	.set	macro
	.set	reorder

	andi	$4,$16,0x00ff
	ld	$31,16($sp)
	ld	$16,0($sp)
	#nop
	.set	noreorder
	.set	nomacro
	j	prtByte
	addu	$sp,$sp,32
	.set	macro
	.set	reorder

	.end	prtInt
	.align	3
	.globl	go_down
	.text
	.ent	go_down
go_down:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	j	k_SleepThread
	.end	go_down
	.rdata
	.align	3
$LC10:
	.ascii	"\244\244\244\345\246r\275X = \000"
	.text
	.align	3
	.globl	test_chin_16
	.text
	.ent	test_chin_16
test_chin_16:
	.frame	$sp,112,$31		# vars= 0, regs= 14/0, args= 0, extra= 0
	.mask	0x803f0000,-16
	.fmask	0x00000000,0
	subu	$sp,$sp,112
	sd	$16,0($sp)
	sd	$21,80($sp)
	move	$16,$4
	lui	$21,%hi($LC10) # high
	li	$4,4325376			# 0x420000
	sd	$20,64($sp)
	addiu	$5,$21,%lo($LC10) # low
	sd	$19,48($sp)
	ori	$4,$4,0xff00
	sd	$31,96($sp)
	li	$20,4325376			# 0x420000
	sd	$18,32($sp)
	ori	$20,$20,0xff00
	sd	$17,16($sp)
	.set	noreorder
	.set	nomacro
	jal	strcpy
	li	$19,4325376			# 0x420000
	.set	macro
	.set	reorder

	ori	$19,$19,0xff40
	li	$2,4325376			# 0x420000
	move	$4,$16
	ori	$2,$2,0xff0b
	.set	noreorder
	.set	nomacro
	jal	ptInt
	sw	$2,pbuf
	.set	macro
	.set	reorder

	sb	$0,19($20)
	li	$4,4325376			# 0x420000
	ori	$4,$4,0xff00
	.set	noreorder
	.set	nomacro
	jal	str2ChineseBitmap16
	li	$5,4390912			# 0x430000
	.set	macro
	.set	reorder

	lw	$9,ScrOfs
	andi	$6,$2,0xffff
	li	$4,16			# 0x10
	move	$5,$0
	li	$7,15			# 0xf
	li	$8,4390912			# 0x430000
	.set	noreorder
	.set	nomacro
	jal	gs_load_texture
	li	$10,640			# 0x280
	.set	macro
	.set	reorder

	li	$5,16			# 0x10
	addu	$18,$5,16
	.align	3
$L189:
	andi	$17,$5,0xffff
	move	$4,$20
	sra	$2,$16,8
	.align	3
$L188:
	sb	$16,1($4)
	sll	$3,$2,24
	sb	$2,0($4)
	andi	$2,$16,0x00ff
	sra	$3,$3,16
	addu	$2,$2,-127
	addu	$4,$4,2
	andi	$2,$2,0x00ff
	addu	$16,$16,1
	sltu	$2,$2,33
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L168
	slt	$5,$4,$19
	.set	macro
	.set	reorder

	ori	$16,$3,0xa0
$L168:
	.set	noreorder
	.set	nomacro
	bne	$5,$0,$L188
	sra	$2,$16,8
	.set	macro
	.set	reorder

	li	$4,4325376			# 0x420000
	sb	$0,4390720
	ori	$4,$4,0xff00
	.set	noreorder
	.set	nomacro
	jal	str2ChineseBitmap16
	li	$5,4390912			# 0x430000
	.set	macro
	.set	reorder

	lw	$9,ScrOfs
	move	$5,$17
	andi	$6,$2,0xffff
	li	$4,64			# 0x40
	li	$7,15			# 0xf
	li	$8,4390912			# 0x430000
	.set	noreorder
	.set	nomacro
	jal	gs_load_texture
	li	$10,640			# 0x280
	.set	macro
	.set	reorder

	move	$5,$18
	slt	$2,$5,96
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L189
	addu	$18,$5,16
	.set	macro
	.set	reorder

	andi	$2,$16,0xff00
	li	$4,4325376			# 0x420000
	ori	$16,$2,0x40
	addiu	$5,$21,%lo($LC10) # low
	ori	$4,$4,0xff00
	.set	noreorder
	.set	nomacro
	jal	strcpy
	addu	$19,$20,64
	.set	macro
	.set	reorder

	li	$3,4325376			# 0x420000
	move	$4,$16
	ori	$3,$3,0xff0b
	.set	noreorder
	.set	nomacro
	jal	ptInt
	sw	$3,pbuf
	.set	macro
	.set	reorder

	li	$4,4325376			# 0x420000
	sb	$0,4390675
	ori	$4,$4,0xff00
	.set	noreorder
	.set	nomacro
	jal	str2ChineseBitmap16
	li	$5,4390912			# 0x430000
	.set	macro
	.set	reorder

	lw	$9,ScrOfs
	andi	$6,$2,0xffff
	li	$4,16			# 0x10
	li	$5,96			# 0x60
	li	$7,15			# 0xf
	li	$8,4390912			# 0x430000
	.set	noreorder
	.set	nomacro
	jal	gs_load_texture
	li	$10,640			# 0x280
	.set	macro
	.set	reorder

	li	$5,112			# 0x70
	addu	$18,$5,16
	.align	3
$L191:
	andi	$17,$5,0xffff
	move	$4,$20
	sra	$2,$16,8
	.align	3
$L190:
	sb	$16,1($4)
	sll	$3,$2,24
	sb	$2,0($4)
	andi	$2,$16,0x00ff
	sra	$3,$3,16
	addu	$2,$2,-127
	addu	$4,$4,2
	andi	$2,$2,0x00ff
	addu	$16,$16,1
	sltu	$2,$2,33
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L179
	slt	$5,$4,$19
	.set	macro
	.set	reorder

	ori	$16,$3,0xa0
$L179:
	.set	noreorder
	.set	nomacro
	bne	$5,$0,$L190
	sra	$2,$16,8
	.set	macro
	.set	reorder

	li	$4,4325376			# 0x420000
	sb	$0,4390720
	ori	$4,$4,0xff00
	.set	noreorder
	.set	nomacro
	jal	str2ChineseBitmap16
	li	$5,4390912			# 0x430000
	.set	macro
	.set	reorder

	lw	$9,ScrOfs
	move	$5,$17
	andi	$6,$2,0xffff
	li	$4,64			# 0x40
	li	$7,15			# 0xf
	li	$8,4390912			# 0x430000
	.set	noreorder
	.set	nomacro
	jal	gs_load_texture
	li	$10,640			# 0x280
	.set	macro
	.set	reorder

	move	$5,$18
	slt	$2,$5,192
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L191
	addu	$18,$5,16
	.set	macro
	.set	reorder

	ld	$31,96($sp)
	ld	$21,80($sp)
	ld	$20,64($sp)
	ld	$19,48($sp)
	ld	$18,32($sp)
	ld	$17,16($sp)
	ld	$16,0($sp)
	#nop
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$sp,$sp,112
	.set	macro
	.set	reorder

	.end	test_chin_16
	.align	3
	.globl	test_chin_24
	.text
	.ent	test_chin_24
test_chin_24:
	.frame	$sp,96,$31		# vars= 0, regs= 12/0, args= 0, extra= 0
	.mask	0x801f0000,-16
	.fmask	0x00000000,0
	subu	$sp,$sp,96
	lui	$5,%hi($LC10) # high
	sd	$16,0($sp)
	addiu	$5,$5,%lo($LC10) # low
	move	$16,$4
	sd	$20,64($sp)
	li	$4,4325376			# 0x420000
	sd	$19,48($sp)
	sd	$31,80($sp)
	ori	$4,$4,0xff00
	sd	$18,32($sp)
	li	$20,4325376			# 0x420000
	sd	$17,16($sp)
	.set	noreorder
	.set	nomacro
	jal	strcpy
	ori	$20,$20,0xff00
	.set	macro
	.set	reorder

	li	$19,4325376			# 0x420000
	li	$2,4325376			# 0x420000
	move	$4,$16
	ori	$2,$2,0xff0b
	ori	$19,$19,0xff30
	.set	noreorder
	.set	nomacro
	jal	ptInt
	sw	$2,pbuf
	.set	macro
	.set	reorder

	sb	$0,19($20)
	li	$4,4325376			# 0x420000
	ori	$4,$4,0xff00
	.set	noreorder
	.set	nomacro
	jal	str2ChineseBitmap24
	li	$5,4390912			# 0x430000
	.set	macro
	.set	reorder

	lw	$9,ScrOfs
	andi	$6,$2,0xffff
	li	$4,16			# 0x10
	move	$5,$0
	li	$7,24			# 0x18
	li	$8,4390912			# 0x430000
	.set	noreorder
	.set	nomacro
	jal	gs_load_texture
	li	$10,640			# 0x280
	.set	macro
	.set	reorder

	li	$5,24			# 0x18
	addu	$18,$5,24
	.align	3
$L207:
	andi	$17,$5,0xffff
	move	$3,$20
	sb	$16,1($3)
	.align	3
$L206:
	sra	$5,$16,8
	sb	$5,0($3)
	lbu	$4,1($3)
	#nop
	addu	$2,$4,-126
	sltu	$2,$2,34
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L201
	addu	$16,$16,1
	.set	macro
	.set	reorder

	sll	$2,$5,24
	sra	$2,$2,16
	ori	$16,$2,0xa1
$L201:
	sltu	$2,$4,255
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L198
	addu	$3,$3,2
	.set	macro
	.set	reorder

	slt	$2,$3,$19
	.set	noreorder
	.set	nomacro
	bnel	$2,$0,$L206
	sb	$16,1($3)
	.set	macro
	.set	reorder

$L198:
	li	$4,4325376			# 0x420000
	sb	$0,4390704
	ori	$4,$4,0xff00
	.set	noreorder
	.set	nomacro
	jal	str2ChineseBitmap24
	li	$5,4390912			# 0x430000
	.set	macro
	.set	reorder

	lw	$9,ScrOfs
	move	$5,$17
	andi	$6,$2,0xffff
	li	$4,32			# 0x20
	li	$7,24			# 0x18
	li	$8,4390912			# 0x430000
	.set	noreorder
	.set	nomacro
	jal	gs_load_texture
	li	$10,640			# 0x280
	.set	macro
	.set	reorder

	move	$5,$18
	slt	$2,$5,192
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L207
	addu	$18,$5,24
	.set	macro
	.set	reorder

	ld	$31,80($sp)
	ld	$20,64($sp)
	ld	$19,48($sp)
	ld	$18,32($sp)
	ld	$17,16($sp)
	ld	$16,0($sp)
	#nop
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$sp,$sp,96
	.set	macro
	.set	reorder

	.end	test_chin_24
	.rdata
	.align	3
$LC11:
	.ascii	"------- Hello ! my CDROM ! --------\000"
	.align	3
$LC12:
	.ascii	"sceOpen NAPLINK.ELF = %d\000"
	.align	3
$LC13:
	.ascii	"lseek returns = %X\000"
	.align	3
$LC14:
	.ascii	"read returns = %X\000"
	.align	3
$LC15:
	.ascii	"------- bye ! my CDROM ! --------\000"
	.text
	.align	3
	.globl	testCD
	.text
	.ent	testCD
testCD:
	.frame	$sp,224,$31		# vars= 96, regs= 16/0, args= 0, extra= 0
	.mask	0x807f0000,-16
	.fmask	0x00000000,0
	subu	$sp,$sp,224
	lui	$4,%hi($LC11) # high
	sd	$16,96($sp)
	addiu	$4,$4,%lo($LC11) # low
	sd	$31,208($sp)
	sd	$22,192($sp)
	sd	$21,176($sp)
	sd	$20,160($sp)
	sd	$19,144($sp)
	sd	$18,128($sp)
	.set	noreorder
	.set	nomacro
	jal	nputs
	sd	$17,112($sp)
	.set	macro
	.set	reorder

	lui	$4,%hi($LC8) # high
	li	$5,1			# 0x1
	.set	noreorder
	.set	nomacro
	jal	sceOpen
	addiu	$4,$4,%lo($LC8) # low
	.set	macro
	.set	reorder

	move	$16,$2
	lui	$4,%hi($LC12) # high
	addiu	$4,$4,%lo($LC12) # low
	.set	noreorder
	.set	nomacro
	jal	nprintf
	move	$5,$16
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	bltz	$16,$L208
	move	$5,$0
	.set	macro
	.set	reorder

	move	$4,$16
	move	$6,$0
	.set	noreorder
	.set	nomacro
	jal	sceLseek
	li	$18,4456448			# 0x440000
	.set	macro
	.set	reorder

	li	$19,32			# 0x20
	lui	$4,%hi($LC13) # high
	move	$5,$2
	addiu	$4,$4,%lo($LC13) # low
	.set	noreorder
	.set	nomacro
	jal	nprintf
	li	$20,4456448			# 0x440000
	.set	macro
	.set	reorder

	li	$22,45			# 0x2d
	move	$4,$16
	li	$5,4456448			# 0x440000
	li	$6,35840			# 0x8c00
	.set	noreorder
	.set	nomacro
	jal	sceRead
	li	$21,32			# 0x20
	.set	macro
	.set	reorder

	lui	$4,%hi($LC14) # high
	move	$5,$2
	.set	noreorder
	.set	nomacro
	jal	nprintf
	addiu	$4,$4,%lo($LC14) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	sceClose
	move	$4,$16
	.set	macro
	.set	reorder

	move	$4,$18
	.align	3
$L222:
	.set	noreorder
	.set	nomacro
	jal	ptInt
	sw	$sp,pbuf
	.set	macro
	.set	reorder

	addu	$19,$19,-16
	lw	$2,pbuf
	addu	$18,$18,16
	move	$16,$0
	addu	$17,$20,16
	sb	$22,0($2)
	addu	$5,$2,1
	.align	3
$L212:
	sw	$5,pbuf
	addu	$2,$20,$16
	.set	noreorder
	.set	nomacro
	jal	ptByte
	lbu	$4,0($2)
	.set	macro
	.set	reorder

	addu	$2,$16,1
	lw	$3,pbuf
	andi	$16,$2,0x00ff
	addu	$5,$3,1
	sltu	$2,$16,16
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L212
	sb	$21,0($3)
	.set	macro
	.set	reorder

	sw	$5,pbuf
	move	$4,$sp
	sb	$0,0($5)
	.set	noreorder
	.set	nomacro
	jal	nputs
	move	$20,$17
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	bgtzl	$19,$L222
	move	$4,$18
	.set	macro
	.set	reorder

	li	$16,4456448			# 0x440000
	li	$17,4456448			# 0x440000
	ori	$16,$16,0x8aec
	li	$18,32			# 0x20
	ori	$17,$17,0x8aec
	li	$22,45			# 0x2d
	li	$21,32			# 0x20
	.align	3
$L213:
	move	$4,$16
	.set	noreorder
	.set	nomacro
	jal	ptInt
	sw	$sp,pbuf
	.set	macro
	.set	reorder

	addu	$20,$16,16
	lw	$2,pbuf
	addu	$18,$18,-16
	move	$16,$0
	addu	$19,$17,16
	sb	$22,0($2)
	addu	$5,$2,1
	.align	3
$L215:
	sw	$5,pbuf
	addu	$2,$17,$16
	.set	noreorder
	.set	nomacro
	jal	ptByte
	lbu	$4,0($2)
	.set	macro
	.set	reorder

	addu	$2,$16,1
	lw	$3,pbuf
	andi	$16,$2,0x00ff
	addu	$5,$3,1
	sltu	$2,$16,16
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L215
	sb	$21,0($3)
	.set	macro
	.set	reorder

	sw	$5,pbuf
	move	$4,$sp
	sb	$0,0($5)
	.set	noreorder
	.set	nomacro
	jal	nputs
	move	$16,$20
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	bgtz	$18,$L213
	move	$17,$19
	.set	macro
	.set	reorder

	li	$16,4456448			# 0x440000
	li	$17,4456448			# 0x440000
	ori	$16,$16,0xc000
	li	$18,64			# 0x40
	ori	$17,$17,0xc000
	li	$22,45			# 0x2d
	li	$21,32			# 0x20
	.align	3
$L216:
	move	$4,$16
	.set	noreorder
	.set	nomacro
	jal	ptInt
	sw	$sp,pbuf
	.set	macro
	.set	reorder

	addu	$20,$16,16
	lw	$2,pbuf
	addu	$18,$18,-16
	move	$16,$0
	addu	$19,$17,16
	sb	$22,0($2)
	addu	$5,$2,1
	.align	3
$L218:
	sw	$5,pbuf
	addu	$2,$17,$16
	.set	noreorder
	.set	nomacro
	jal	ptByte
	lbu	$4,0($2)
	.set	macro
	.set	reorder

	addu	$2,$16,1
	lw	$3,pbuf
	andi	$16,$2,0x00ff
	addu	$5,$3,1
	sltu	$2,$16,16
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L218
	sb	$21,0($3)
	.set	macro
	.set	reorder

	sw	$5,pbuf
	move	$4,$sp
	sb	$0,0($5)
	.set	noreorder
	.set	nomacro
	jal	nputs
	move	$16,$20
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	bgtz	$18,$L216
	move	$17,$19
	.set	macro
	.set	reorder

	lui	$4,%hi($LC15) # high
	.set	noreorder
	.set	nomacro
	jal	nputs
	addiu	$4,$4,%lo($LC15) # low
	.set	macro
	.set	reorder

$L208:
	ld	$31,208($sp)
	ld	$22,192($sp)
	ld	$21,176($sp)
	ld	$20,160($sp)
	ld	$19,144($sp)
	ld	$18,128($sp)
	ld	$17,112($sp)
	ld	$16,96($sp)
	#nop
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$sp,$sp,224
	.set	macro
	.set	reorder

	.end	testCD
	.align	3
	.globl	delay
	.text
	.ent	delay
delay:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	blez	$4,$L226
	li	$3,196608			# 0x30000
	.set	macro
	.set	reorder

	ori	$3,$3,0xffff
	addu	$4,$4,-1
	.align	3
$L225:
	addu	$2,$3,1
	.align	3
$L89:
	addu	$2,$2,-1
	.set	noreorder
	nop
	.set	reorder
	.set	noreorder
	nop
	.set	reorder
	.set	noreorder
	nop
	.set	reorder
	.set	noreorder
	nop
	.set	reorder
	bne	$2,$0,$L89
	.set	noreorder
	.set	nomacro
	bgtz	$4,$L225
	addu	$4,$4,-1
	.set	macro
	.set	reorder

$L226:
	j	$31
	.end	delay
	.align	3
	.globl	dump
	.text
	.ent	dump
dump:
	.frame	$sp,96,$31		# vars= 0, regs= 12/0, args= 0, extra= 0
	.mask	0x801f0000,-16
	.fmask	0x00000000,0
	subu	$sp,$sp,96
	lui	$6,%hi($LC6) # high
	sd	$17,16($sp)
	addiu	$6,$6,%lo($LC6) # low
	move	$17,$4
	sd	$20,64($sp)
	sd	$19,48($sp)
	li	$4,3			# 0x3
	sd	$31,80($sp)
	li	$5,1			# 0x1
	sd	$18,32($sp)
	addu	$19,$17,64
	sd	$16,0($sp)
	.set	noreorder
	.set	nomacro
	jal	gputs
	li	$20,1			# 0x1
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	prtInt
	move	$4,$17
	.set	macro
	.set	reorder

	lui	$6,%hi($LC7) # high
	li	$4,15			# 0xf
	addiu	$6,$6,%lo($LC7) # low
	.set	noreorder
	.set	nomacro
	jal	gputs
	li	$5,1			# 0x1
	.set	macro
	.set	reorder

	move	$3,$0
	addu	$2,$3,2
	.align	3
$L230:
	sw	$20,scrX
	sw	$2,scrY
	addu	$18,$3,1
	li	$16,7			# 0x7
	lbu	$4,0($17)
	.align	3
$L229:
	addu	$16,$16,-1
	.set	noreorder
	.set	nomacro
	jal	prtByte
	addu	$17,$17,1
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	gputc
	li	$4,32			# 0x20
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	bgezl	$16,$L229
	lbu	$4,0($17)
	.set	macro
	.set	reorder

	move	$3,$18
	slt	$2,$3,8
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L230
	addu	$2,$3,2
	.set	macro
	.set	reorder

	move	$2,$19
	ld	$31,80($sp)
	ld	$20,64($sp)
	ld	$19,48($sp)
	ld	$18,32($sp)
	ld	$17,16($sp)
	ld	$16,0($sp)
	#nop
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$sp,$sp,96
	.set	macro
	.set	reorder

	.end	dump
	.align	3
	.globl	errlog
	.text
	.ent	errlog
errlog:
	.frame	$sp,32,$31		# vars= 0, regs= 4/0, args= 0, extra= 0
	.mask	0x80010000,-16
	.fmask	0x00000000,0
	subu	$sp,$sp,32
	lw	$5,errY
	sd	$16,0($sp)
	move	$16,$4
	sd	$31,16($sp)
	lw	$4,errX
	.set	noreorder
	.set	nomacro
	jal	gputs
	move	$6,$16
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	strlen
	move	$4,$16
	.set	macro
	.set	reorder

	lw	$3,errX
	#nop
	addu	$3,$3,$2
	slt	$2,$3,80
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L231
	lw	$2,errY
	.set	macro
	.set	reorder

	move	$3,$0
	addu	$2,$2,1
	sw	$2,errY
$L231:
	slt	$2,$2,14
	.set	noreorder
	.set	nomacro
	beql	$2,$0,$L16
	sw	$0,errY
	.set	macro
	.set	reorder

$L16:
	ld	$31,16($sp)
	ld	$16,0($sp)
	sw	$3,errX
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$sp,$sp,32
	.set	macro
	.set	reorder

	.end	errlog
	.align	3
	.globl	FillMem
	.text
	.ent	FillMem
FillMem:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	sra	$5,$5,2
	blez	$5,$L233
	.align	3
$L80:
	sw	$6,0($4)
	addu	$5,$5,-1
	addu	$4,$4,4
	.set	noreorder
	nop
	.set	reorder
	.set	noreorder
	nop
	.set	reorder
	bgtz	$5,$L80
$L233:
	j	$31
	.end	FillMem
	.align	3
	.globl	gputc
	.text
	.ent	gputc
gputc:
	.frame	$sp,16,$31		# vars= 0, regs= 2/0, args= 0, extra= 0
	.mask	0x80000000,-16
	.fmask	0x00000000,0
	lw	$10,scrX
	subu	$sp,$sp,16
	lw	$6,scrY
	sll	$4,$4,24
	andi	$10,$10,0x1f
	sd	$31,0($sp)
	move	$11,$10
	andi	$6,$6,0xf
	sra	$8,$4,24
	slt	$2,$11,40
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L98
	move	$12,$6
	.set	macro
	.set	reorder

	addu	$6,$12,1
	move	$10,$0
	move	$12,$6
	move	$11,$0
$L98:
	slt	$2,$6,14
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L235
	lui	$7,%hi(usable) # high
	.set	macro
	.set	reorder

	move	$6,$0
	move	$12,$0
$L235:
	lb	$2,%lo(usable)($7)
	#nop
	.set	noreorder
	.set	nomacro
	beq	$8,$2,$L234
	move	$4,$0
	.set	macro
	.set	reorder

	lw	$9,nowDraw
	addu	$4,$4,1
	.align	3
$L236:
	slt	$5,$4,32
	.set	noreorder
	.set	nomacro
	beq	$5,$0,$L106
	addiu	$2,$7,%lo(usable) # low
	.set	macro
	.set	reorder

	addu	$2,$4,$2
	lb	$3,0($2)
	#nop
	.set	noreorder
	.set	nomacro
	bnel	$8,$3,$L236
	addu	$4,$4,1
	.set	macro
	.set	reorder

	b	$L101
	.align	2
$L234:
	lw	$9,nowDraw
	li	$5,1			# 0x1
$L101:
	.set	noreorder
	.set	nomacro
	beq	$5,$0,$L106
	andi	$2,$4,0xf
	.set	macro
	.set	reorder

	li	$7,29360128			# 0x1c00000
	sra	$4,$4,4
	li	$3,30343168			# 0x1cf0000
	movn	$7,$3,$4
	sll	$2,$2,4
	.set	noreorder
	.set	nomacro
	b	$L109
	or	$7,$7,$2
	.set	macro
	.set	reorder

	.align	2
$L106:
	li	$7,29360128			# 0x1c00000
$L109:
	sll	$2,$6,4
	sll	$3,$10,4
	subu	$2,$2,$6
	sll	$2,$2,16
	.set	noreorder
	.set	nomacro
	beq	$9,$0,$L110
	or	$5,$3,$2
	.set	macro
	.set	reorder

	li	$2,14680064			# 0xe00000
	addu	$5,$5,$2
$L110:
	move	$4,$7
	sw	$11,scrX
	sw	$12,scrY
	li	$6,16			# 0x10
	.set	noreorder
	.set	nomacro
	jal	vramMove
	li	$7,15			# 0xf
	.set	macro
	.set	reorder

	lw	$2,scrX
	ld	$31,0($sp)
	addu	$11,$2,1
	sw	$11,scrX
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$sp,$sp,16
	.set	macro
	.set	reorder

	.end	gputc
	.align	3
	.globl	gputs
	.text
	.ent	gputs
gputs:
	.frame	$sp,48,$31		# vars= 0, regs= 6/0, args= 0, extra= 0
	.mask	0x80030000,-16
	.fmask	0x00000000,0
	subu	$sp,$sp,48
	sw	$4,scrX
	sd	$17,16($sp)
	sd	$16,0($sp)
	move	$17,$0
	sd	$31,32($sp)
	move	$16,$6
	sw	$5,scrY
	.align	3
$L96:
	lb	$4,0($16)
	#nop
	.set	noreorder
	.set	nomacro
	beq	$4,$0,$L237
	ld	$31,32($sp)
	.set	macro
	.set	reorder

	#nop
	.set	noreorder
	.set	nomacro
	jal	gputc
	addu	$17,$17,1
	.set	macro
	.set	reorder

	slt	$2,$17,256
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L96
	addu	$16,$16,1
	.set	macro
	.set	reorder

	ld	$31,32($sp)
$L237:
	ld	$17,16($sp)
	ld	$16,0($sp)
	#nop
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$sp,$sp,48
	.set	macro
	.set	reorder

	.end	gputs
	.align	3
	.globl	pcdump
	.text
	.ent	pcdump
pcdump:
	.frame	$sp,224,$31		# vars= 96, regs= 16/0, args= 0, extra= 0
	.mask	0x807f0000,-16
	.fmask	0x00000000,0
	subu	$sp,$sp,224
	sd	$16,96($sp)
	sd	$22,192($sp)
	move	$16,$4
	sd	$21,176($sp)
	li	$22,45			# 0x2d
	sd	$18,128($sp)
	li	$21,32			# 0x20
	sd	$17,112($sp)
	move	$18,$16
	sd	$31,208($sp)
	move	$17,$5
	sd	$20,160($sp)
	sd	$19,144($sp)
	.align	3
$L120:
	move	$4,$16
	.set	noreorder
	.set	nomacro
	jal	ptInt
	sw	$sp,pbuf
	.set	macro
	.set	reorder

	addu	$20,$16,16
	lw	$2,pbuf
	addu	$17,$17,-16
	move	$16,$0
	addu	$19,$18,16
	sb	$22,0($2)
	addu	$5,$2,1
	.align	3
$L118:
	sw	$5,pbuf
	addu	$2,$18,$16
	.set	noreorder
	.set	nomacro
	jal	ptByte
	lbu	$4,0($2)
	.set	macro
	.set	reorder

	addu	$2,$16,1
	lw	$3,pbuf
	andi	$16,$2,0x00ff
	addu	$5,$3,1
	sltu	$2,$16,16
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L118
	sb	$21,0($3)
	.set	macro
	.set	reorder

	sw	$5,pbuf
	move	$4,$sp
	sb	$0,0($5)
	.set	noreorder
	.set	nomacro
	jal	nputs
	move	$16,$20
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	bgtz	$17,$L120
	move	$18,$19
	.set	macro
	.set	reorder

	ld	$31,208($sp)
	ld	$22,192($sp)
	ld	$21,176($sp)
	ld	$20,160($sp)
	ld	$19,144($sp)
	ld	$18,128($sp)
	ld	$17,112($sp)
	ld	$16,96($sp)
	#nop
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$sp,$sp,224
	.set	macro
	.set	reorder

	.end	pcdump
	.align	3
	.globl	ptByte
	.text
	.ent	ptByte
ptByte:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	andi	$4,$4,0x00ff
	lui	$3,%hi(hex) # high
	addiu	$3,$3,%lo(hex) # low
	srl	$2,$4,4
	addu	$2,$2,$3
	lw	$6,pbuf
	lbu	$5,0($2)
	andi	$4,$4,0xf
	addu	$4,$4,$3
	sb	$5,0($6)
	lw	$3,pbuf
	lbu	$5,0($4)
	addu	$2,$3,1
	sw	$2,pbuf
	sb	$5,1($3)
	lw	$2,pbuf
	#nop
	addu	$2,$2,1
	.set	noreorder
	.set	nomacro
	j	$31
	sw	$2,pbuf
	.set	macro
	.set	reorder

	.end	ptByte
	.align	3
	.globl	putChinStr16
	.text
	.ent	putChinStr16
putChinStr16:
	.frame	$sp,64,$31		# vars= 0, regs= 8/0, args= 0, extra= 0
	.mask	0x80070000,-16
	.fmask	0x00000000,0
	subu	$sp,$sp,64
	sd	$18,32($sp)
	sd	$16,0($sp)
	move	$18,$5
	move	$16,$4
	sd	$17,16($sp)
	sd	$31,48($sp)
	move	$4,$6
	.set	noreorder
	.set	nomacro
	jal	str2ChineseBitmap16
	li	$5,4390912			# 0x430000
	.set	macro
	.set	reorder

	move	$17,$2
	lw	$9,ScrOfs
	andi	$4,$16,0xffff
	andi	$5,$18,0xffff
	andi	$6,$17,0xffff
	li	$7,15			# 0xf
	li	$8,4390912			# 0x430000
	.set	noreorder
	.set	nomacro
	jal	gs_load_texture
	li	$10,640			# 0x280
	.set	macro
	.set	reorder

	move	$2,$17
	ld	$31,48($sp)
	ld	$18,32($sp)
	ld	$17,16($sp)
	ld	$16,0($sp)
	#nop
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$sp,$sp,64
	.set	macro
	.set	reorder

	.end	putChinStr16
	.align	3
	.globl	putChinStr24
	.text
	.ent	putChinStr24
putChinStr24:
	.frame	$sp,64,$31		# vars= 0, regs= 8/0, args= 0, extra= 0
	.mask	0x80070000,-16
	.fmask	0x00000000,0
	subu	$sp,$sp,64
	sd	$18,32($sp)
	sd	$16,0($sp)
	move	$18,$5
	move	$16,$4
	sd	$17,16($sp)
	sd	$31,48($sp)
	move	$4,$6
	.set	noreorder
	.set	nomacro
	jal	str2ChineseBitmap24
	li	$5,4390912			# 0x430000
	.set	macro
	.set	reorder

	move	$17,$2
	lw	$9,ScrOfs
	andi	$4,$16,0xffff
	andi	$5,$18,0xffff
	andi	$6,$17,0xffff
	li	$7,24			# 0x18
	li	$8,4390912			# 0x430000
	.set	noreorder
	.set	nomacro
	jal	gs_load_texture
	li	$10,640			# 0x280
	.set	macro
	.set	reorder

	move	$2,$17
	ld	$31,48($sp)
	ld	$18,32($sp)
	ld	$17,16($sp)
	ld	$16,0($sp)
	#nop
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$sp,$sp,64
	.set	macro
	.set	reorder

	.end	putChinStr24
	.align	3
	.globl	readEETo
	.text
	.ent	readEETo
readEETo:
	.frame	$sp,64,$31		# vars= 0, regs= 8/0, args= 0, extra= 0
	.mask	0x80070000,-16
	.fmask	0x00000000,0
	li	$2,2031616			# 0x1f0000
	subu	$sp,$sp,64
	ori	$2,$2,0xfffc
	sd	$18,32($sp)
	sd	$17,16($sp)
	and	$6,$6,$2
	sd	$31,48($sp)
	move	$18,$5
	sd	$16,0($sp)
	sra	$6,$6,2
	.set	noreorder
	.set	nomacro
	beq	$6,$0,$L239
	move	$17,$4
	.set	macro
	.set	reorder

	move	$16,$6
	.align	3
$L155:
	move	$4,$18
	.set	noreorder
	.set	nomacro
	jal	eeReadMemory
	addu	$16,$16,-1
	.set	macro
	.set	reorder

	addu	$18,$18,4
	sw	$2,0($17)
	.set	noreorder
	.set	nomacro
	bne	$16,$0,$L155
	addu	$17,$17,4
	.set	macro
	.set	reorder

$L239:
	ld	$31,48($sp)
	ld	$18,32($sp)
	ld	$17,16($sp)
	ld	$16,0($sp)
	#nop
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$sp,$sp,64
	.set	macro
	.set	reorder

	.end	readEETo
	.align	3
	.globl	SetDrawTo
	.text
	.ent	SetDrawTo
SetDrawTo:
	.frame	$sp,16,$31		# vars= 0, regs= 2/0, args= 0, extra= 0
	.mask	0x80000000,-16
	.fmask	0x00000000,0
	subu	$sp,$sp,16
	lbu	$4,nowDraw
	sd	$31,0($sp)
	jal	g2_set_active_frame
	lbu	$4,nowDraw
	.set	noreorder
	.set	nomacro
	jal	g2_set_visible_frame
	xori	$4,$4,0x1
	.set	macro
	.set	reorder

	lw	$3,nowDraw
	li	$2,524288			# 0x80000
	ori	$2,$2,0xc000
	ld	$31,0($sp)
	movz	$2,$0,$3
	sw	$2,ScrOfs
	.set	noreorder
	.set	nomacro
	j	$31
	addu	$sp,$sp,16
	.set	macro
	.set	reorder

	.end	SetDrawTo

	.comm	maxx,4,4

	.comm	maxy,4,4

	.comm	nowDraw,4,4

	.comm	pFont1,4,4

	.comm	dumpAddr,4,4

	.comm	dumpLen,4,4

	.comm	TimeSlic,4,4

	.comm	scrX,4,4

	.comm	scrY,4,4

	.comm	fd,4,4

	.comm	pi,4,4

	.comm	xofs,4,4

	.comm	yofs,4,4

	.comm	nchi,4,4

	.comm	ScrOfs,4,4

	.comm	paddata,4,4

	.comm	new_pad,4,4

	.comm	pbuf,4,4

	.comm	pFont,4,4
