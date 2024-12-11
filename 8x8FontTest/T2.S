	.text
#-------------------------
# 因為某些參數可能是固定值或因為 .bss 不能放程式, 因此ㄒ須加寫一段小程式
#-------------------------
# 堆疊須加留 32 bytes !
	.globl	drawBitMap
	.ent	drawBitMap
drawBitMap:
	daddu	$t0, $zero, $zero
	addiu	$t0, $zero, 0x72
	sd	$t0, 0($sp)
#	addiu	$t0, $zero, 0		# maybe: 0, 7C, 7E, 80
#	sw	$t0, 8($sp)
	addiu	$t0, $zero, 0x36B0
	sd	$t0, 16($sp)
	addiu	$t0, $zero, 1
	addiu	$t1, $zero, 1
	addiu	$t2, $zero, 0x31
	addiu	$t3, $zero, 0x52
	j	__drawBitMap	# .word	0x08045136
	.end	drawBitMap
#-------------------------

