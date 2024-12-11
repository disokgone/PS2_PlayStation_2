	.set noreorder
	.set noat
	.global 	ExceptHandlerA
	.global 	getCP0
#--------------------------------------
	.align	3	# 切齊 8 bytes
	.text

	.ent	ExceptHandlerA

ExceptHandlerA:
	lui	$k0, 0x45
	addiu	$k0, $k0, 0x9200	# 0x449200 = reg.SaveList
	sq	$zero, 0($k0)
	sq	$at, 0x10($k0)
	sq	$v0, 0x20($k0)
	sq	$v1, 0x30($k0)
	sq	$a0, 0x40($k0)
	sq	$a1, 0x50($k0)
	sq	$a2, 0x60($k0)
	sq	$a3, 0x70($k0)
	sq	$t0, 0x80($k0)
	sq	$t1, 0x90($k0)
	sq	$t2, 0xA0($k0)
	sq	$t3, 0xB0($k0)
	sq	$t4, 0xC0($k0)
	sq	$t5, 0xD0($k0)
	sq	$t6, 0xE0($k0)
	sq	$t7, 0xF0($k0)
	sq	$s0, 0x100($k0)
	sq	$s1, 0x110($k0)
	sq	$s2, 0x120($k0)
	sq	$s3, 0x130($k0)
	sq	$s4, 0x140($k0)
	sq	$s5, 0x150($k0)
	sq	$s6, 0x160($k0)
	sq	$s7, 0x170($k0)
	sq	$t8, 0x180($k0)
	sq	$t9, 0x190($k0)
	sq	$zero, 0x1A0($k0)
	sq	$zero, 0x1B0($k0)
	sq	$gp, 0x1C0($k0)
	sq	$sp, 0x1D0($k0)
	sq	$fp, 0x1E0($k0)
	sq	$ra, 0x1F0($k0)
	mfc0	$a0, $t4	# = SR
	mfc0	$a1, $t5	# = Cause
	mfc0	$a2, $t6	# = EPC
	la	$a3, ExceptHandler	# (eret) return to ExceptHandler (in except.c)
	mtc0	$a3, $t6	# eret 時會跳至此處
	mfc0	$a3, $t0 	# = bad-VA
	lui	$t0, 0x45
	addiu	$t0, $t0, 0x9200
	sync
	li	$v0, 0xFFFFFFFE
	mfc0	$at, $t4	# = SR
	and	$at, $at, $v0
	mtc0	$at, $t4
	sync
	andi	$v0, $a1, 0x7C
	lui	$sp, 0x44
	addiu	$sp, $sp, 0x6200	# sp = $446200 !
	eret
	nop

	.end	ExceptHandlerA
#-----------------------------------------
# void getCP0(int *cpr);
getCP0:
	subu	$sp, $sp, 32
	sd	$ra, 16($sp)
	mfc0	$v0, $zero	# 0 = index
	mfc0	$v1, $at	# 1 = random
	sw	$v0, 0($a0)
	sw	$v1, 4($a0)
	mfc0	$v0, $v0	# 2 = EntryLo0
	mfc0	$v1, $v1	# 3 = EntryLo1
	sw	$v0, 8($a0)
	sw	$v1, 0x0C($a0)
	mfc0	$v0, $a0	# 4 = context
	mfc0	$v1, $a1	# 5 = pagemask
	sw	$v0, 0x10($a0)
	sw	$v1, 0x14($a0)
	mfc0	$v0, $a2	# 6 = wired
	mfc0	$v1, $a3	# 7 = reserved
	sw	$v0, 0x18($a0)
	sw	$v1, 0x1C($a0)
	mfc0	$v0, $t0	# 8 = BadVAddr
	mfc0	$v1, $t1	# 9 = timer count
	sw	$v0, 0x20($a0)
	sw	$v1, 0x24($a0)
	mfc0	$v0, $t2	# 10 = EntryHi
	mfc0	$v1, $t3	# 11 = timer compare
	sw	$v0, 0x28($a0)
	sw	$v1, 0x2C($a0)
	mfc0	$v0, $t4	# 12 = SR (status)
	mfc0	$v1, $t5	# 13 = cause
	sw	$v0, 0x30($a0)
	sw	$v1, 0x34($a0)
	mfc0	$v0, $t6	# 14 = EPC (exception PC)
	mfc0	$v1, $t7	# 15 = PRid (uP's ID)
	sw	$v0, 0x38($a0)
	sw	$v1, 0x3C($a0)
	mfc0	$v0, $s0	# 16 = config
	mfc0	$v1, $s1	# 17 = LLAddr (loaded link addr)
	sw	$v0, 0x40($a0)
	sw	$v1, 0x44($a0)
	mfc0	$v0, $s2	# 18 = reserved
	mfc0	$v1, $s3	# 19 = reserved
	sw	$v0, 0x48($a0)
	sw	$v1, 0x4C($a0)
	mfc0	$v0, $s4	# 20 = XContext
	mfc0	$v1, $s5	# 21 = reserved
	sw	$v0, 0x50($a0)
	sw	$v1, 0x54($a0)
	mfc0	$v0, $s6	# 22 = reserved
	mfc0	$v1, $s7	# 23 = reserved
	sw	$v0, 0x58($a0)
	sw	$v1, 0x5C($a0)
	mfc0	$v0, $t8	# 24 = reserved
	mfc0	$v1, $t9	# 25 = reserved
	sw	$v0, 0x60($a0)
	sw	$v1, 0x64($a0)
	mfc0	$v0, $k0	# 26 = ECC
	mfc0	$v1, $k1	# 27 = cache Err
	sw	$v0, 0x68($a0)
	sw	$v1, 0x6C($a0)
	mfc0	$v0, $gp	# 28 = TagLo
	mfc0	$v1, $sp	# 29 = TagHi
	sw	$v0, 0x70($a0)
	sw	$v1, 0x74($a0)
	mfc0	$v0, $fp	# 30 = ErrorECC
	mfc0	$v1, $ra	# 31 = reserved
	sw	$v0, 0x78($a0)
	sw	$v1, 0x7C($a0)
	ld	$ra, 16($sp)
	jr	$ra
	addiu	$sp, $sp, 32
