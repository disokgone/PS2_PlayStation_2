	.set noreorder
	.set noat
	.global 	ExceptHandlerA
	.global 	getCP0
#--------------------------------------
	.align	3	# 切齊 8 bytes
	.text

	.ent	ExceptHandlerA

ExceptHandlerA:
	lui	$26, 0x45
	addiu	$26, $26, 0x9200	# 0x449200 = reg.SaveList
	sq	$0, 0($26)
	sq	$1, 0x10($26)
	sq	$2, 0x20($26)
	sq	$3, 0x30($26)
	sq	$4, 0x40($26)
	sq	$5, 0x50($26)
	sq	$6, 0x60($26)
	sq	$7, 0x70($26)
	sq	$8, 0x80($26)
	sq	$9, 0x90($26)
	sq	$10, 0xA0($26)
	sq	$11, 0xB0($26)
	sq	$12, 0xC0($26)
	sq	$13, 0xD0($26)
	sq	$14, 0xE0($26)
	sq	$15, 0xF0($26)
	sq	$16, 0x100($26)
	sq	$17, 0x110($26)
	sq	$18, 0x120($26)
	sq	$19, 0x130($26)
	sq	$20, 0x140($26)
	sq	$21, 0x150($26)
	sq	$22, 0x160($26)
	sq	$23, 0x170($26)
	sq	$24, 0x180($26)
	sq	$25, 0x190($26)
	sq	$0, 0x1A0($26)
	sq	$0, 0x1B0($26)
	sq	$28, 0x1C0($26)
	sq	$29, 0x1D0($26)
	sq	$30, 0x1E0($26)
	sq	$31, 0x1F0($26)
	mfc0	$4, $12	# = SR
	mfc0	$5, $13	# = Cause
	mfc0	$6, $14	# = EPC
	la	$7, ExceptHandler	# (eret) return to ExceptHandler (in except.c)
	mtc0	$7, $14	# eret 時會跳至此處
	mfc0	$7, $8 	# = bad-VA
	lui	$8, 0x45
	addiu	$8, $8, 0x9200
	sync
	li	$2, 0xFFFFFFFE
	mfc0	$1, $12	# = SR
	and	$1, $1, $2
	mtc0	$1, $12
	sync
	andi	$2, $5, 0x7C
	lui	$29, 0x44
	addiu	$29, $29, 0x6200	# sp = $446200 !
	eret
	nop

	.end	ExceptHandlerA
#-----------------------------------------
# void getCP0(int *cpr);
getCP0:
	subu	$29, $29, 32
	sd	$31, 16($29)
	mfc0	$2, $0	# 0 = index
	mfc0	$3, $1	# 1 = random
	sw	$2, 0($4)
	sw	$3, 4($4)
	mfc0	$2, $2	# 2 = EntryLo0
	mfc0	$3, $3	# 3 = EntryLo1
	sw	$2, 8($4)
	sw	$3, 0x0C($4)
	mfc0	$2, $4	# 4 = context
	mfc0	$3, $5	# 5 = pagemask
	sw	$2, 0x10($4)
	sw	$3, 0x14($4)
	mfc0	$2, $6	# 6 = wired
	mfc0	$3, $7	# 7 = reserved
	sw	$2, 0x18($4)
	sw	$3, 0x1C($4)
	mfc0	$2, $8	# 8 = BadVAddr
	mfc0	$3, $9	# 9 = timer count
	sw	$2, 0x20($4)
	sw	$3, 0x24($4)
	mfc0	$2, $10	# 10 = EntryHi
	mfc0	$3, $11	# 11 = timer compare
	sw	$2, 0x28($4)
	sw	$3, 0x2C($4)
	mfc0	$2, $12	# 12 = SR (status)
	mfc0	$3, $13	# 13 = cause
	sw	$2, 0x30($4)
	sw	$3, 0x34($4)
	mfc0	$2, $14	# 14 = EPC (exception PC)
	mfc0	$3, $15	# 15 = PRid (uP's ID)
	sw	$2, 0x38($4)
	sw	$3, 0x3C($4)
	mfc0	$2, $16	# 16 = config
	mfc0	$3, $17	# 17 = LLAddr (loaded link addr)
	sw	$2, 0x40($4)
	sw	$3, 0x44($4)
	mfc0	$2, $18	# 18 = reserved
	mfc0	$3, $19	# 19 = reserved
	sw	$2, 0x48($4)
	sw	$3, 0x4C($4)
	mfc0	$2, $20	# 20 = XContext
	mfc0	$3, $21	# 21 = reserved
	sw	$2, 0x50($4)
	sw	$3, 0x54($4)
	mfc0	$2, $22	# 22 = reserved
	mfc0	$3, $23	# 23 = reserved
	sw	$2, 0x58($4)
	sw	$3, 0x5C($4)
	mfc0	$2, $24	# 24 = reserved
	mfc0	$3, $25	# 25 = reserved
	sw	$2, 0x60($4)
	sw	$3, 0x64($4)
	mfc0	$2, $26	# 26 = ECC
	mfc0	$3, $27	# 27 = cache Err
	sw	$2, 0x68($4)
	sw	$3, 0x6C($4)
	mfc0	$2, $28	# 28 = TagLo
	mfc0	$3, $29	# 29 = TagHi
	sw	$2, 0x70($4)
	sw	$3, 0x74($4)
	mfc0	$2, $30	# 30 = ErrorECC
	mfc0	$3, $31	# 31 = reserved
	sw	$2, 0x78($4)
	sw	$3, 0x7C($4)
	ld	$31, 16($29)
	jr	$31
	addiu	$29, $29, 32
