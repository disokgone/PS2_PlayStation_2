	.set noreorder
	.data
#--------------------------------------
xDMA02CH	=	0x1000A000
xDMA02ADR	=	0x1000A010
xDMA02SIZE	=	0x1000A020
xDMA02TAG	=	0x1000A030
#--------------------------------------
	.align	5	# 切齊 32 bytes
envData:		# 15 個 qword = 15 * 16 = 240 bytes
	.dword 	0x100000000000800E,0xE
	.dword 	0x00A0000,0x4C		# framebuffer width = 640/64 (假定目標畫面寬是 640)
	.dword	0x8C,0x4E		# 0-8 Zbuffer base, 24-27 Z format (32bit)
	.word	27648,30976		# X,Y offset
	.dword	0x18
xxyy:
	.half	500,639,120,223		# x1,x2,y1,y2 - scissor window
	.dword	0x40	# 剪刀裁切區會被清成黑色, 但之後 2D/3D 仍能繪圖於上 !
	.dword 	1,0x1A			# refer to prim attributes
	.dword 	1,0x46
	.dword 	0,0x45			# Dither off
	.dword 	0x70000,0x47
	.dword 	0x30000,0x47
	.dword 	6,0
	.dword 	0x3F80000000000000,0x1	# Background RGBA
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
	.half	0,224 			# dest x,y
	.dword	0x51
picWH:
	.word	256,30			# width, height
	.dword	0x52
	.dword	0, 0x53			# direction 00 = ee-mem -> gs-mem
picSize:
	.dword	0x0800000000008780, 0	# low 7-bit is size (h*w*4 / 16)
#--------------------------------------
	.align	5	# 切齊 32 bytes
xVramMove:		# 含 6 個 qwords = 6 * 16 = 96 bytes
	.dword	0x1000000000000004, 0xE
	.dword	0x000A0000000A0000, 0x50	# 48-53 = Dest width/64 (假定目標畫面寬是 640)
srcXY:
	.half	0, 224			# 來源 x,y
# dstXY:
	.half	32, 64 			# 目的 x,y
	.dword	0x51
movWH:
	.word	16,15			# width, height
	.dword	0x52
	.dword	2, 0x53			# direction 02 = gs-mem -> gs-mem
	.dword	0x0800000000000000, 0	# VRAM 內搬移, 不必設值
#--------------------------------------
	.text
	.align	3	# 切齊 8 bytes
	.ent		primWork
#--------------------------------------
	.global 	setDrawEnv
	.global 	loadfontA
	.global		uploadBitMap32
	.global 	vramMove
	.global		waitVSync1
	.global		waitVSync2
#--------------------------------------
# void clearScrn(int X1X2, int Y1Y2);
# clearScrn:
# void setDrawEnv(int X1X2, int Y1Y2);
setDrawEnv:
	la	$v0, xxyy
	sw	$a0, 0($v0)
	sw	$a1, 4($v0)
	li	$v0, 15
	sw	$v0, xDMA02SIZE
	la	$v0, envData
	sw	$v0, xDMA02ADR
	li	$v0, 0x101
	sw	$v0, xDMA02CH
	j	DMA02wait
	nop
#--------------------------------------
#void loadfontA(void);
loadfontA:
	subiu	$sp, $sp, 16
	sd	$ra, 0($sp)
	la	$v0, ee2gs
	sw	$v0, xDMA02ADR		# 設定上傳用的 prim 碼
	li	$v0, 6
	sw	$v0, xDMA02SIZE
	li	$v0, 0x101
	sw	$v0, xDMA02CH		# 送出上傳用的 prim 碼
	jal	DMA02wait
	nop
	la	$v0, pFont1
	sw	$v0, xDMA02ADR		# 設定上傳用的 prim 碼
	li	$v0, 0x780
	sw	$v0, xDMA02SIZE
	li	$v0, 0x101
	sw	$v0, xDMA02CH		# 送出上傳用的 prim 碼
	jal	DMA02wait
	nop
	ld	$ra, 0($sp)
	addiu	$sp, $sp, 16
	jr	$ra
	nop
#--------------------------------------
#void uploadBitMap32(void *pBitMap, int HHWW, int VramX, int VramY, int dotqwc);
#	把 32-bit [R,G,B,A] 圖形點陣上傳到 VRAM 的 (X, Y)
uploadBitMap32:
	subiu	$sp, $sp, 32
	sd	$ra, 0($sp)
	sd	$s0, 0x10($sp)
	addu	$s0, $a0, $zero

	la	$v0, ee2gs
	sw	$v0, xDMA02ADR		# 設定上傳用的 prim 碼
	li	$v0, 6
	sw	$v0, xDMA02SIZE

	la	$v0, destXY
	sh	$a2, 0($v0)		# a2 = VRAM X
	sh	$a3, 2($v0)		# a3 = VRAM Y

	addu	$t1, $a1, $zero		# = HHWW (圖形寬與高)
	andi	$a1, $a1, 0x1FFF	# a1 = Width
	la	$v0, picWH
	srl	$t1, $t1, 16		# t1 = Height
	andi	$t1, $t1, 0x1FFF	# a1 = Width
	sw	$a1, 0($v0)
	sw	$t1, 4($v0)

	la	$v0, picSize
	ori	$a0, $t0, 0x8000	# bit 15 = 1 (來源為 EE-memory)
	sh	$a0, 0($v0)

	li	$v0, 0x101
	sw	$v0, xDMA02CH		# 送出上傳用的 prim 碼
	jal	DMA02wait
	nop

	sw	$s0, xDMA02ADR		# = pBitMap 圖形碼
	sw	$t0, xDMA02SIZE		# 此處亦是 qword count = W * H * 4 / 16
	li	$v0, 0x101
	sw	$v0, xDMA02CH		# 送出上傳的圖形碼
	jal	DMA02wait
	nop
	ld	$s0, 0x10($sp)
	ld	$ra, 0($sp)
	addiu	$sp, $sp, 32
	jr	$ra
	nop
#--------------------------------------
# void vramMove(int srcXY, int dstXY, int width, int height);
#	 將 VRAM 的 (srcX, srcY) 圖形點陣搬移到 VRAM 的 (dstX, dstY)
vramMove:
	subiu	$sp, $sp, 16
	sd	$ra, 0($sp)
	la	$v0, xVramMove
	sw	$v0, xDMA02ADR		# 設定上傳用的 prim 碼
	li	$v0, 6
	sw	$v0, xDMA02SIZE

	la	$v0, srcXY
	sw	$a0, 0($v0)		# a0 = src VRAM XY (low X, High Y)
	sw	$a1, 4($v0)		# a1 = dest VRAM XY (low X, High Y)

	la	$v0, movWH
	sw	$a2, 0($v0)		# a2 = 圖形寬
	sw	$a3, 4($v0)		# a3 = 圖形高

	li	$v0, 0x101
	sw	$v0, xDMA02CH		# 送出的 prim 碼
	jal	DMA02wait
	nop
	ld	$ra, 0($sp)
	addiu	$sp, $sp, 16
	jr	$ra
	nop
#--------------------------------------
# void waitVSync1(void);
waitVSync1:
	subiu	$sp, $sp, 16
	sd	$s0, 0($sp)
	lui	$s0, 1
	la	$v0, 0x12001000
	lw	$v1, 0($v0)
	and	$v1, $v1, 8
	sw	$v1, 0($v0)	# 產生 VSync
$flyback:
	nop
	lw	$v1, 0($v0)
	and	$v1, $v1, 8
	bne	$v1, $zero, $itisok
	subiu	$s0, $s0, 1
	bne	$s0, $zero, $flyback
	nop
$itisok:
	ld	$s0, 0($sp)
	addiu	$sp, $sp, 16
	jr	$ra
	nop

#--------------------------------------
# void waitVSync2(void);
waitVSync2:
	subiu	$sp, $sp, 16
	sd	$s0, 0($sp)
	la	$v0, 0x1000F000
	addiu	$v1, $zero, 4
	sw	$v1, 0($v0)
	lui	$s0, 1
$retest:
	nop
	lw	$v1, 0($v0)
	andi	$v1, $v1, 4
	bne	$v1, $zero, $isok02
	subiu	$s0, $s0, 1
	bne	$s0, $zero, $retest
	nop

$isok02:
	ld	$s0, 0($sp)
	addiu	$sp, $sp, 16
	jr	$ra
	nop
#--------------------------------------
	.end		primWork
