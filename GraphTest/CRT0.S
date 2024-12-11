	.set noreorder
	.text
#--------------------------------------
	.global 	_start
	.align	3	# 8 bytes
#--------------------------------------
	.ent		_start
_start:
# 1. 首先應先清除未使用空間 (.sbss  及 .bss)
	la	$v0, _fbss		# Front of .bss (或 __bss_start), 會與 qword 切齊
	la	$v1, _end		# end addr. of .sbss & .bss, 會與 qword 切齊
lpClr00:
	nop
	nop
	sq	$zero, 0($v0)		# 填入 16 個 0 !!
	sltu	$t0, $v0, $v1
	bne	$t0, $zero, lpClr00	# 清除未載入程式的區域 (.sbss 及 .bss)
	addiu	$v0, $v0, 16

# 2. initialize main thread
#	執行 RFU060(_gp, _stack, _stack_size, _args, _root)

	la	$gp, _gp		# 規定 gp 空間不能高於 64 KBytes
	daddu	$sp, $v0, $zero		# 通常 sp = _end, 從預定的 .data 尾端用起
	move	$a0, $gp		# 所以不能把太大的檔案硬塞到 .data 中 !
	la	$a1, _stack		# stack pointer, 會與 qword 切齊
	la	$a2, _stack_size	# 自訂的, 或 0x100000 亦可
	la	$a3, _args		# end of data (即是 .sbss/.bss 的起點)
	la	$t0, _root		# 又稱為 _HandleThreadExc (大多重新啟動)
	jal	RFU060
	nop

# initialize heap area
	la	$a0, _end		# sp 最頂端位址
	la	$a1, _heap_size		# heap 大小 (通常 < 64KB)
	jal	RFU061			# 設定 heap 位址, 及其大小 (< 64KB)
	nop

#	jal	some-init	# 通常是設立 Thread, Sema ...

	jal	FlushCache
	addiu	$a0, $zero, 0		# flush data cache

	jal	FlushCache
	addiu	$a0, $zero, 2		# flush code cache

# call main program
	ei
	la	$a0, _args
	daddu	$a1, $a0, 4	# => char *argv[]
	jal	_main
	lw	$a0, ($a0)	# => int argc

	move	$a0, $v0	# 傳回 int main() 值
	j	Exit
	nop
#--------------------------------------
# _HandleThreadExc:
_root:
	jal	ExitThread	# 清除執行緒
	nop
#	j	FullReset	# 重新啟動 PS2 (若是懶得處理時)
#	nop
	subu	$a0, $zero, 99	# 自訂傳回 -99
	j	Exit		# 我也懶得處理 !
	nop

	subu	$sp, $sp, 0x20
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
.bss
.align	6
_args: .space	256 + 16*4 + 1*4
	.end	_start