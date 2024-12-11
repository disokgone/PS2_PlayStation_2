	.set noreorder
	.text
#--------------------------------------
	.global 	_start
	.align	3	# 8 bytes
#--------------------------------------
	.ent		_start
_start:
# 1. 首先應先清除未使用空間 (.sbss  及 .bss)
	la	$2, _fbss		# Front of .bss (或 __bss_start), 會與 qword 切齊
	la	$3, _end		# end addr. of .sbss & .bss, 會與 qword 切齊
lpClr00:
	nop
	nop
	sq	$0, 0($2)		# 填入 16 個 0 !!
	sltu	$8, $2, $3
	bne	$8, $0, lpClr00	# 清除未載入程式的區域 (.sbss 及 .bss)
	addiu	$2, $2, 0x10

# 2. initialize main thread
#	執行 RFU060(_gp, _stack, _stack_size, _args, _root)

	la	$28, _gp		# 規定 gp 空間不能高於 64 KBytes
	daddu	$29, $2, $0		# 通常 sp = _end, 從預定的 .data 尾端用起
	move	$4, $28		# 所以不能把太大的檔案硬塞到 .data 中 !
	la	$5, _stack		# stack pointer, 會與 qword 切齊
	la	$6, _stack_size	# 自訂的, 或 0x100000 亦可
	la	$7, _args		# end of data (即是 .sbss/.bss 的起點)
	la	$8, _root		# 又稱為 _HandleThreadExc (大多重新啟動)
	jal	RFU060

# initialize heap area
	la	$4, _end		# sp 最頂端位址
	la	$5, _heap_size		# heap 大小 (通常 < 64KB)
	jal	RFU061			# 設定 heap 位址, 及其大小 (< 64KB)

#	jal	some-init	# 通常是設立 Thread, Sema ...

	addiu	$4, $0, 0		# flush data cache
	jal	FlushCache

	addiu	$4, $0, 2		# flush code cache
	jal	FlushCache

# call main program
	ei
	la	$4, _args
	daddu	$5, $4, 4	# => char *argv[]
	lw	$4, ($4)	# => int argc
	jal	_main

	move	$4, $2	# 傳回 int main() 值
	j	Exit
	nop
#--------------------------------------
# _HandleThreadExc:
_root:
	jal	ExitThread	# 清除執行緒
	nop
#	j	FullReset	# 重新啟動 PS2 (若是懶得處理時)
#	nop
	subu	$4, $0, 99	# 自訂傳回 -99
	j	Exit		# 我也懶得處理 !
	nop

	subu	$29, $29, 0x20
	sd	$31, 0x10($29)
	sd	$30, 0($29)
	daddu	$30, $29, $0
#	la	$a0, .data
#	la	$a1, ???	# .bss 內的一個地方
#	jal	???		# 並登錄錯誤
	nop
	daddu	$29, $30, $0
	ld	$31, 0x10($29)
	ld	$30, 0($29)
	addiu	$29, $29, 0x20
	jr	$31
	nop
#--------------------------------------
.bss
.align	6
_args: .space	256 + 16*4 + 1*4
	.end	_start
