	.set noreorder
#--------------------------------------
xDMA02CH	=	0x1000A000
xDMA02ADR	=	0x1000A010
xDMA02SIZE	=	0x1000A020
xDMA02TAG	=	0x1000A030
#--------------------------------------
	.data
	.align	7	# 切齊 128 bytes
envData:		# 15 個 qword = 15 * 16 = 240 bytes
	.dword 	0x100000000000800E,0xE
frameYOfs:
	.dword 	0x000A0000,0x4C		# framebuffer width = 640/64 (假定目標畫面寬是 640)
	.dword	0x8C,0x4E		# 0-8 Zbuffer base, 24-27 Z format (32bit)
	.word	27648,30976		# X,Y offset
	.dword	0x18
xxyy:
#	.half	0, 639, 0, 223		# x1,x2,y1,y2 - scissor window
#	.dword	0x40	# 剪刀裁切區會被清成黑色, 但之後 2D/3D 仍能繪圖於上 !
	.dword 	1,0x1A			# refer to prim attributes
	.dword 	1,0x46
	.dword 	0,0x45			# Dither off
	.dword 	0x70000,0x47
	.dword 	0x30000,0x47
	.dword 	6,0
	.dword 	0x3F80000000000000,0x1	# Background RGBA (low bits: R -> G -> B)
	.dword 	0x79006C00,0x5
	.dword 	0x87009400,0x5
	.dword 	0x70000,0x47
#--------------------------------------
	.align	7	# 切齊 128 bytes
ee2gs:		# 含 6 個 qwords = 6 * 16 = 96 bytes
	.dword	0x1000000000000004, 0xE
	.dword	0x000A000000000000, 0x50	# 48-53 = Dest width/64 (假定目標畫面寬是 640)
	.word	0
destXY:
	.half	0, 448 			# dest x,y
	.dword	0x51
picWH:
	.word	256, 30			# width, height
	.dword	0x52
	.dword	0, 0x53			# direction 00 = ee-mem -> gs-mem
picSize:
	.dword	0x0800000000008780, 0	# low 7-bit is size (h*w*4 / 16)
#--------------------------------------
	.align	7	# 切齊 128 bytes
xVramMove:		# 含 6 個 qwords = 6 * 16 = 96 bytes
	.dword	0x1000000000000004, 0xE
	.dword	0x000A0000000A0000, 0x50	# 48-53 = Dest width/64 (假定目標畫面寬是 640)
srcXY:
	.half	640, 0			# 來源 x,y
	.half	16, 16			# 目的 x,y
	.dword	0x51
movWH:
	.word	16, 15			# width, height
	.dword	0x52
	.dword	2, 0x53			# direction 02 = gs-mem -> gs-mem
	.dword	0x0800000000000000, 0	# VRAM 內搬移, 不必設值
#--------------------------------------
	.global 	setDrawOfs
	.global 	loadfontA
	.global		uploadBitMap32
	.global 	vramMove
	.global		waitVSync
	.global		setDisplayOfs
#--------------------------------------
	.align	3	# 切齊 8 bytes
	.ent		setDrawEnv
	.text
#--------------------------------------
# void setDrawOfs(unsigned short frameYOfs);	// 要畫的緩衝區
setDrawOfs:
#	la	$v0, xxyy
#	sw	$a0, 0($v0)	# set X1, X2
#	sw	$a1, 4($v0)	# set Y1, Y2

	la	$2, frameYOfs
	sh	$6, 0($2)	# set draw frame's Y offset (w * h / 0x800)

	li	$2, 14
	sw	$2, xDMA02SIZE
	la	$2, envData
	sw	$2, xDMA02ADR
	li	$2, 0x101
	sw	$2, xDMA02CH
	j	DMA02wait
	nop
#--------------------------------------
#void loadfontA(void);
loadfontA:
	subu	$29, $29, 16
	sd	$31, 0($29)

	lui	$3, 448		# X=0, Y=448
	sw	$3, destXY

	li	$3, 256		# width = 256
	sw	$3, picWH
	li	$3, 30			# height = 30
	sw	$3, picWH + 4

	li	$3, 0x8780		# 0x8000 | (w * h * 4 / 16)
	sw	$3, picSize

	la	$2, ee2gs
	sw	$2, xDMA02ADR		# 設定上傳用的 prim 碼
	li	$2, 6
	sw	$2, xDMA02SIZE
	li	$2, 0x101
	sw	$2, xDMA02CH		# 送出上傳用的 prim 碼
	jal	DMA02wait
	nop
	lw	$2, pFont1
	sw	$2, xDMA02ADR		# 設定上傳用的圖形資料
	li	$2, 0x780
	sw	$2, xDMA02SIZE
	li	$2, 0x101
	sw	$2, xDMA02CH		# 送出上傳用的圖形資料
	jal	DMA02wait
	nop
	ld	$31, 0($29)
	addiu	$29, $29, 16
	jr	$31
	nop
#--------------------------------------
#void uploadBitMap32(void *pBitMap, int HHWW, int VramX, int VramY, int dotqwc);
#	把 32-bit [R,G,B,A] 圖形點陣上傳到 VRAM 的 (X, Y)
uploadBitMap32:
	subu	$29, $29, 32
	sd	$31, 0($29)
	sd	$16, 0x10($29)
	addu	$16, $4, $0

	la	$2, destXY
	sh	$6, 0($2)		# a2 = VRAM X
	sh	$7, 2($2)		# a3 = VRAM Y

	addu	$9, $5, $0		# = HHWW (圖形寬與高)
	andi	$5, $5, 0x1FFF	# a1 = Width
	la	$2, picWH
	srl	$9, $9, 16		# t1 = Height
	andi	$9, $9, 0x1FFF	# a1 = Width
	sw	$5, 0($2)
	sw	$9, 4($2)

	la	$2, picSize
	ori	$4, $8, 0x8000	# bit 15 = 1 (來源為 EE-memory)
	sh	$4, 0($2)

	la	$2, ee2gs
	sw	$2, xDMA02ADR		# 設定上傳用的 prim 碼
	li	$2, 6
	sw	$2, xDMA02SIZE
	li	$2, 0x101
	sw	$2, xDMA02CH		# 送出上傳用的 prim 碼
	jal	DMA02wait
	nop

	sw	$16, xDMA02ADR		# = pBitMap 圖形碼
	sw	$8, xDMA02SIZE		# 此處亦是 qword count = W * H * 4 / 16
	li	$2, 0x101
	sw	$2, xDMA02CH		# 送出上傳的圖形碼
	jal	DMA02wait
	nop
	ld	$16, 0x10($29)
	ld	$31, 0($29)
	addiu	$29, $29, 32
	jr	$31
	nop
#--------------------------------------
# void vramMove(int srcXY, int dstXY, int width, int height);
#	 將 VRAM 的 (srcX, srcY) 圖形點陣搬移到 VRAM 的 (dstX, dstY)
vramMove:
	subu	$29, $29, 32
	sd	$31, 0($29)

	la	$2, srcXY
	sw	$4, 0($2)		# a0 = src VRAM XY (low X, High Y)
	sw	$5, 4($2)		# a1 = dest VRAM XY (low X, High Y)

	la	$2, movWH
	sw	$6, 0($2)		# a2 = 圖形寬
	sw	$7, 4($2)		# a3 = 圖形高

	la	$2, xVramMove
	sw	$2, xDMA02ADR		# 設定上傳用的 prim 碼
	li	$2, 6
	sw	$2, xDMA02SIZE
	li	$2, 0x101
	sw	$2, xDMA02CH		# 送出的 prim 碼
	jal	DMA02wait
	nop
	ori	$4, $0, 0
	jal	FlushCache
	nop
	ld	$31, 0($29)
	addiu	$29, $29, 32
	jr	$31
	nop
#--------------------------------------
# void waitVSync(void);
waitVSync:
	subu	$29, $29, 16
	sd	$16, 0($29)
	lui	$16, 1
	la	$2, 0x12001000
	lw	$3, 0($2)
	and	$3, $3, 8
	sw	$3, 0($2)	# 產生 VSync
$flyback:
	nop
	lw	$3, 0($2)
	and	$3, $3, 8
	bne	$3, $0, $itisok
	subu	$16, $16, 1
	bne	$16, $0, $flyback
	nop
$itisok:
	la	$2, 0x1000F000
	addiu	$3, $0, 4
	sw	$3, 0($2)
	lui	$16, 1
$retest:
	nop
	lw	$3, 0($2)
	andi	$3, $3, 4
	bne	$3, $0, $isok02
	subu	$16, $16, 1
	bne	$16, $0, $retest
	nop

$isok02:
	ld	$16, 0($29)
	addiu	$29, $29, 16
	jr	$31
	nop
#--------------------------------------
# void setDisplayOfs(int Xofs, int Yofs);	// 我自訂的 !
setDisplayOfs:

	andi	$4, $4, 0x7FF		# Xofs &= 0x7FF (11-bit 有效)
	andi	$5, $5, 0x7FF		# Yofs &= 0x7FF (11-bit 有效)
	sll	$5, $5, 11
	or	$5, $5, $4		# bit[21-11] = YOfs, bit[10-0] = XOfs

	dsll	$5, $5, 32		# bit[53-43] = YOfs, bit[42-32] = XOfs
	ori	$5, $5, 0x1400	# set FBW / FBP
	lui	$2, 0x1200
	sd	$5, 0x90($2)		# write to GS.dispfb2
	jr	$31
	nop

	.end		setDrawEnv
