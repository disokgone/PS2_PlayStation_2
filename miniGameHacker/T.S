.text
	.ent	goon

	#la	a0, reg1
	#la	a1, var1
	#lw	t0, (a1)
	#addu	a0, a0, t0

	.end	goon
.data
	.ent	outer
reg1	=	0x10000100
var1:
	#dw    0

	.end	outer
