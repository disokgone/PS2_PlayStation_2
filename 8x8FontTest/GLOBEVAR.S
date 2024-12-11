#-------------------------
	.data
	.globl	x
	.globl	xlen
	.globl	dumploc
	.globl	dumpmode
	.globl	pkt
	.globl	ctrl
	.globl	eg01
	.globl	eg02
	.globl	eg03
	.globl	eg04
	.globl	fn1
	.globl	fn2
	.globl	fn3
	.globl	mess1

	.ent	globVar
x:		.word	0
xlen:		.word	0
dumploc:	.word	0
dumpmode:	.word	0
pkt:		.word	0
ctrl:		.word	0
eg01:		.asciz	"\\PS2%03X.EXE;1\0"
eg02:		.asciz	"CdSrh = %X\0"
eg03:		.asciz	"Srh OK!"
eg04:		.asciz	"cdrom0:\\PS2_%02X.EXE;1\0"
fn1:		.asciz	"\\SETUP.EXE;1\0\0\0"
fn2:		.asciz	"\\CDSETUP.EXE;1\0"
fn3:		.asciz	"\\CWIN95\\README.TXT;1\0\0\0"
mess1:		.asciz	"%X,%d,%d,%d,%d,%d\0\0"
	.end	globVar
