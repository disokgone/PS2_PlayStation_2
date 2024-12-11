#!! int = 4 bytes, long = 8 bytes
# LW/SW = load/store 4 bytes, LD/SD = load/store 8 bytes, L16/S16 = load/store 16 bytes
#!! 1 storage = 2 bytes !!
        .sdata
        .align  2

        .type    VSyncCount,@object
        .size    VSyncCount,8
	.globl	VSyncCount	# = $16A028, 8 bytes
VSyncCount:
	.dword	0

	.globl	fVSyncUsable	# = $16A030, 4 bytes
fVSyncUsable:
	.word	0		# 1 = 代表 VSync 中斷已安裝並致能, 0 = 未安裝

