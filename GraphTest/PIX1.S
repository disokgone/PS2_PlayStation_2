	.set noreorder
	.align	3	# 8 bytes
	.global 	conv1632
#--------------------------------------
	.text
	.ent		conv1632
#--------------------------------------
# conv1632(void *src16pixel, void *dst32pixel);
conv1632:
	lhu	$t0, 0($a0)	# get 1st dot (ABBBBBGGGGGRRRRR)
	andi	$t1, $t0, 0x7FFF
	srl	$t1, $t1, 15	# get bit 15 = [A]
	sb	$t1, 3($a1)	# store [A]

	andi	$t1, $t0, 0x7C00	# get bit [14-10] = [BBBBB]
	srl	$t1, $t1, 7	# 7 = 10 - 3
	sb	$t1, 2($a1)	# store [BBBBB000]

	andi	$t1, $t0, 0x3E0 # get bit [9-5] = [GGGGG]
	srl	$t1, $t1, 2	# 2 = 5 - 3
	sb	$t1, 1($a1)	# store [GGGGG000]

	andi	$t1, $t0, 0x1F	# get bit [9-5] = [RRRRR]
	sll	$t1, $t1, 3
	sb	$t1, 0($a1)	# store [RRRRR000]

	addiu	$a0, $a0, 2
	addiu	$a1, $a1, 4
	subu	$a2, $a2, 1
	bne	$a2, $zero, conv1632
	nop
	jr	$ra
	nop
#--------------------------------------
	.end	conv1632
