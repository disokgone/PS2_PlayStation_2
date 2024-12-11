	.set noreorder
	.data
	.align	4	# 16 bytes
hwData:
	.dword	0x000DF9FF01824290

	.text
	.align	3	# 8 bytes
	.ent		GS_lib_1
#--------------------------------------
	.global 	_start
	.global 	Init_GS
	.global 	SetVideoMode
	.global 	Test01
	.global 	Test02
#--------------------------------------
_start:

	la	$gp, _gp
	addiu	$sp, $gp, 0x7F00	# 亦可自行定義 (多放在 .bss 之後)

	addiu	$a0, $zero, 0
	jal	FlushCache
	nop
	addiu	$a0, $zero, 2
	jal	FlushCache
	nop

	jal	_main
	nop

	move	$a0, $v0	# 傳回 int main() 值
	j	Exit
	nop
#--------------------------------------
_HandleThreadExc:
	jal	ExitThread	# 清除執行緒
	nop
#	j	FullReset	# 重新啟動 PS2 (若是懶得處理時)
#	nop
	subiu	$a0, $zero, 99	# 自訂傳回 -99
	j	Exit		# 我也懶得處理 !
	nop

	subiu	$sp, $sp, 0x20
	sd	$ra, 0x10($sp)
	sd	$fp, 0($sp)
	daddu	$fp, $sp, $zero
#	la	$a0, .data
#	la	$a1, ???	# .bss 內的一個地方
#	jal	???		# 並登錄錯誤
	nop
	daddu	$sp, $fp, $zero
	ld	$ra, 0x10($sp)
	ld	$fp, 0($sp)
	addiu	$sp, $sp, 0x20
	jr	$ra
	nop
#--------------------------------------
# void SetVideoMode(void);
SetVideoMode:
	lui	$v0, 0x1200
	ori	$v1, $zero, 0xFF62
	sd	$v1, 0($v0)

	addiu	$v1, $zero, 2
	sd	$v1, 0x20($v0)

	addiu	$v1, $zero, 0x1400
	sd	$v1, 0x90($v0)

#	ld	$v1, hwData
	li	$v1, 0x000DF9FF01824290
	sd	$v1, 0xA0($v0)
	jr	$ra
	nop
#--------------------------------------
# void Init_GS(bool interlace, int NTSC2_pal3, int frame1_field2);
Init_GS:
	addu	$s1, $a0, $zero
	addu	$s2, $a1, $zero
	addu	$s3, $a2, $zero

	la	$v0, 0x12001000
	li	$v1, 0x200
	sd	$v1, 0($v0)

	ori	$a0, $zero, 0xFF00
	ld	$v0, 0($v0)
	dsrl	$v0, $v0, 16
	andi	$v0, $v0, 0xFF
	addiu	$v1, $zero, 0x71
	syscall 0			# PutIMR(int maskBits)
	nop

	andi	$a0, $s1, 1
	andi	$a1, $s2, 0xFF
	andi	$a2, $s3, 1
	addiu	$v1, $zero, 2
	syscall 0			# SetGsCrt(?, ?, ?)
	nop

	jr	$ra
	nop
#--------------------------------------
# 1. 首先應先清除未使用空間 (.sbss  及 .bss) --> 可略過
Test01:
	subiu	$sp, $sp, 16
	sd	$ra, 0($sp)
	la	$v0, _fbss		# Front of .bss (或 __bss_start)
	addiu	$v0, $v0, 15
	subiu	$v1, $zero, 16		# $v1 = 0xFFFFFFF0
	and	$v0, $v0, $v1		# 確定 $v0 與 16 bytes 切齊
	la	$v1, _end		# end addr. of .sbss & .bss
lpClr00:
	nop
	nop
	.word	0x7C400000		# =>	s16	$zero, 0($v0) 填入 16 個 0 !!
	sltu	$t0, $v0, $v1
	bne	$t0, $zero, lpClr00	# 清除未載入程式的區域 (.sbss 及 .bss)
	addiu	$v0, $v0, 0x10

# 2. 執行 RFU060(gp_addr, gpsize, ?size=0x80000, .bss_begin, Thread 例外處置位址)
	la	$gp, _gp
	move	$a0, $gp
	li	$a1, 0xFFFF		# 規定 gp 空間不能高於 64 KBytes
	li	$a2, 0x80000		# 或 0x100000 亦可
	la	$a3, _fbss		# end of data (即是 .sbss/.bss 的起點)
	la	$t0, _HandleThreadExc	# 又稱為 _root (大多重新啟動)
	jal	RFU060
	nop
	ld	$ra, 0($sp)
	addiu	$sp, $sp, 16
	jr	$ra
	nop

Test02:
	la	$a0, _gp
	addu	$sp, $a0, 0x7F00
	subiu	$sp, $sp, 16
	sd	$ra, 0($sp)
	la	$a0, _end	# sp 最頂端位址
	li	$a1, 0xFFFF	# sp 大小 (< 64KB)
	jal	RFU061		# 設定 sp 位址, 及其大小 (< 64KB)
	nop
#	jal	some-init	# 通常是設立 Thread, Sema ...
#	nop
	ld	$ra, 0($sp)
	addiu	$sp, $sp, 16
	jr	$ra
	nop
#--------------------------------------
	.end		GS_lib_1
