#	.text
#	.global _start
#_start:	.word	0
#------------------------------------------
#!!! 建立此表必須很小心, 故請勿任意更動 !!!
#!!! .ds 的空間為 2 bytes, 故兩位址相減後須除以二 !!!
#------------------------------------------
	.bss		# AR2 at $0C0000
#-------------------------
#	.org	0x0C0000
#-------------------------
	.ent	EXPORT_AR2
		.ds	0x734
		.global 	loadRunELF_Program
loadRunELF_Program:	.ds	0	# $0C0E68

		.ds	0x1F8CC
#= $100000
#-------------------------
#	.org	0x100000
#-------------------------
		.ds	0x2AC
		.global 	drawFrame
drawFrame:	.ds	0x35A0	# $100558

		.global 	messageBox3
messageBox3:	.ds	0x104C	# $107098

		.global 	waitPad #^^ 暫用 ^^
waitPad:	.ds	0x158	# $109130, $158 = ($3E0 - $130) / 2

		.global 	doDump	#^^ 暫用 ^^
doDump: 	.ds	0x2ADC	# $1093E0

		.global 	Ar2Sys
Ar2Sys: 	.ds	0x24	# $10E998

		.global 	readPad
readPad:	.ds	0	# $10E9E0

		.ds	0xB10
#= $110000
#-------------------------
#	.org	0x110000
#-------------------------
		.ds	0x44
		.global 	beginPacket
beginPacket:	.ds	0x2228	# $110088

		.global 	__drawBitMap
__drawBitMap:	.ds	0x41E8	# $1144D8

		.global 	sceCdDiskReady
sceCdDiskReady: .ds	0x10	# $11C8A8

		.global 	sceCdSearchFile
sceCdSearchFile:  .ds	0x136C	# $11C8C8

		.global 	fillchar
fillchar:	.ds	0xAC	# $11EFA0

		.global 	ustrcpy
ustrcpy:	.ds	0x1C	# $11F0F8

		.global 	ustrlen
ustrlen:	.ds	0x18	# $11F130

		.global 	ustrncpy
ustrncpy:	.ds	0x90	# $11F160

		.global 	sprintf
sprintf:	.ds	0	# $11F280

		.ds	0x6C0
#= $120000
#-------------------------
#	.org	0x120000
#-------------------------
		.ds	0x8E8
		.global 	malloc
malloc: 	.ds	0	# $1211D0

	.end	EXPORT_AR2
