	.set noreorder
	.align	3	# 8 bytes
	.global 	conv1632
#--------------------------------------
	.text
	.ent		conv1632
#--------------------------------------
# conv1632(void *src16pixel, void *dst32pixel);
conv1632:
	lhu	$8, 0($4)	# get 1st dot (ABBBBBGGGGGRRRRR)
	andi	$9, $8, 0x7FFF
	srl	$9, $9, 15	# get bit 15 = [A]
	sb	$9, 3($5)	# store [A]

	andi	$9, $8, 0x7C00	# get bit [14-10] = [BBBBB]
	srl	$9, $9, 7	# 7 = 10 - 3
	sb	$9, 2($5)	# store [BBBBB000]

	andi	$9, $8, 0x3E0 # get bit [9-5] = [GGGGG]
	srl	$9, $9, 2	# 2 = 5 - 3
	sb	$9, 1($5)	# store [GGGGG000]

	andi	$9, $8, 0x1F	# get bit [9-5] = [RRRRR]
	sll	$9, $9, 3
	sb	$9, 0($5)	# store [RRRRR000]

	addiu	$4, $4, 2
	addiu	$5, $5, 4
	subu	$6, $6, 1
	bne	$6, $0, conv1632
	nop
	jr	$31
	nop
#--------------------------------------
	.end	conv1632
