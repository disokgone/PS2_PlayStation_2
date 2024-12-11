.set nomips16
.data 1
.p2align 5

__set_fb1:
    .dword 0x0000000070000002, 0x00	# DMA tag
    .dword 0x1000000000008001, 0x0E	# GIF tag
    .dword 0x000A0000, 0x4c             # framebuf: ptr = 0, width 10*64 = 640

__set_fb2:
    .dword 0x0000000070000002, 0x00	# DMA tag
    .dword 0x1000000000008001, 0x0E	# GIF tag
    .dword 0x000A0046, 0x4c             # framebuf: ptr = 0x8c000, width 10*64 = 640


VRendf:     .word 0
VRendid:    .word 0
VRcount:    .word 0	# 已發生的垂直回掃次數
VRstartid:  .word 0	# INT 2 中斷的 ID

.text
.p2align 4
.set noreorder

# ----------------------------
# void install_VRstart_handler();
    .globl install_VRstart_handler
    .ent install_VRstart_handler
install_VRstart_handler:
    di

    # install handler
    li $4, 2			# IntNo = 2
    la $5, VRstart_handler	# IntcHandler = VRstart_handler
    addiu $6, $0, 0		# code = 0
    li $3, 16		# int AddIntcHandler(int IntNo, void *IntcHandler, int code);
    syscall
    nop

    la $4, VRstartid
    sw $2, 0($4)	# 儲存傳回中斷的 ID

    # enable the handler
    li $4, 2		# IntNo = 2
    li $3, 20		# _EnableIntc(int IntcNo);
    syscall
    nop

    la $4, VRcount
    sw $0, 0($4)	# VRcount = 0

    ei

    jr $31
    nop

    .end install_VRstart_handler

# ************* untested vv-------------------
# void remove_VRstart_handler();
    .globl remove_VRstart_handler
    .ent remove_VRstart_handler
remove_VRstart_handler:
    di

    lui $2, %hi(VRstartid)
    addiu $4, $0, 2		# $a0 = IntNo = 2
    ori $2, %lo(VRstartid)
    addiu $3, $0, 17		# RemoveIntcHandler(int IntcNo, int IntcID);
    lw $5, 0($2)		# get $a1 = VRstartid
    syscall
    nop

    ei

    jr $31
    nop

    .end remove_VRstart_handler
# ************* untested ^^----------------------------

# ----------------------------

    .ent VRstart_handler
VRstart_handler:
    la $2, VRcount		# VRcount ++;
    lw $3, 0($2)
    nop
    addiu $3, 1
    sw $3, 0($2)

    daddu $2, $0, $0		# return(0);

    jr $31
    nop

    .end VRstart_handler

# ----------------------------

    .set at
# clears flag and waits until it gets reset (blocking call)
# void WaitForNextVRstart(int numvrs);
# numvrs = number of vertical retraces to wait for (可用於定時等待)
    .globl WaitForNextVRstart
    .ent WaitForNextVRstart
WaitForNextVRstart:
    la $2, VRcount
    sw $0, 0($2)		# VRcount = 0

WaitForNextVRstart.lp:
    lw $3, 0($2)
    nop
    blt $3, $4, WaitForNextVRstart.lp
    nop			# while (VRcount < numvrs) nop;

    jr $31
    nop

    .end WaitForNextVRstart

# ----------------------------

    .set noat

# has start-of-Vertical-Retrace occurred since the flag was last cleared ?
# (non-blocking call)
# int TestVRstart();
    .globl TestVRstart
    .ent TestVRstart
TestVRstart:
    la $3, VRcount
    lw $2, 0($3)	# return(VRcount);

    jr $31
    nop

    .end TestVRstart


# clear the start-of-Vertical-Retrace flag
# void ClearVRcount();
    .globl ClearVRcount
    .ent ClearVRcount
ClearVRcount:
    la $2, VRcount
    sw $0, 0($2)	# VRcount = 0

    jr $31
    nop

    .end ClearVRcount

# ----------------------------
# if SetVideoMode() sets interlaced field-mode 512x384 ... you get 60 vr int's / second
#   which means you must wait for 2 vr's before swapping buffers
# 因為他們用的是 512*384*4, 故 1 frame buf = 768KB = 0xC0000, 故
# framebuffer 1 = 0x00080000, 0x4c	=> framebuf: ptr = 0x00000, width 8*64 = 512
# framebuffer 2 = 0x00080060, 0x4c	=> framebuf: ptr = 0xc0000, width 8*64 = 512
# << 硬體規定要除以 0x800 [vram dot width] * (32 [bit per pixel] / 8 [bits/byte] ) = 0x2000 >>
# 但我們用的是 640*224*4, 故 1 frame buf = 573440 = 0x8C000, 故
# framebuffer 1 = 0x000A0000, 0x4c	=> framebuf: ptr = 0x00000, width 10*64 = 640
# framebuffer 2 = 0x000A0046, 0x4c	=> framebuf: ptr = 0x8c000, width 10*64 = 640
# (在 32-bit 圖素模式下) 0xc0000 / 0x2000 = 0x60, 0x8c000 / 0x2000 = 0x46

# use this function to swap framebuffers
# void SetDrawFrameBuffer(int which);
# which = 0 : framebuffer 1
#         1 : framebuffer 2
    .globl SetDrawFrameBuffer
    .ent SetDrawFrameBuffer
SetDrawFrameBuffer:
    addiu $29, -16
    sd $31, 0($29)

    jal DMA02wait	# in DMA1.S
    nop

    andi $2, $4, 1	# $v0 = which & 1;
    la $4, __set_fb1

    beq $2, $0, SetDrawFrameBuffer.sendDma
    nop

    la $4, __set_fb2

SetDrawFrameBuffer.sendDma:

    li $3, 0x1000a000

    sw $4, 0x0030($3)	# DMA02TAG = DMA tag start
    sw $0, 0x0020($3)	# DMA02SIZE = 由 tag 內容決定
    lw $2, 0x0000($3)
    ori $2, 0x0105
    sw $2, 0x0000($3)	# DMA02CH |= 0x105 開始送 !
    nop

    ld $31, 0($29)	# 最好儘早 FlushCache(0); !!
    addiu $29, 16

    jr $31
    nop

    .end SetDrawFrameBuffer


# use this function to set which buffer is output to the screen
# void SetCrtFrameBuffer(int which);
# which = 0: framebuffer 1
#         1: framebuffer 2
	.globl SetCrtFrameBuffer
	.ent SetCrtFrameBuffer
SetCrtFrameBuffer:

	lui $2, 0x1200
	sll $4, 31
	sra $4, 31      # we have 0->0 or 1->0xffffffff
	andi $4, 0x0046 # addr of framebuffer 2 (見第 160 行說明)
	ori $4, 0x1400  # width (= (640 / 64) << 9)
			# psm = 0 (32-bit full color)

	sd $4, 0x0090($2)	# 我用的是 GS.dispfb2

	jr $31
	nop

	.end SetCrtFrameBuffer

# ----------------------------

    .globl resetVU0
    .ent resetVU0
resetVU0:
    cfc2.ni $3, $28
    li $2, 0xffffff00
    and $2, $3
    ori $2, 2
    ctc2.ni $3, $28
    sync.p

    jr $31
    nop
    .end resetVU0

# ----------------------------
# ----------------------------


    .globl qmemcpy
    .ent qmemcpy
# void qmemcpy(void *dest, void *src, int numqwords);
qmemcpy:
    lq $2, 0($5)
    addiu $6, -1
    sq $2, 0($4)
    addiu $4, 0x0010
    bnez $6, qmemcpy
    addiu $5, 0x0010

    jr $31
    nop
    .end qmemcpy


    .globl dmemcpy
    .ent dmemcpy
# void dmemcpy(void *dest, void *src, int numdwords);
dmemcpy:
    ld $2, 0($5)
    addiu $6, -1
    sd $2, 0($4)
    addiu $4, 0x0008
    bnez $6, dmemcpy
    addiu $5, 0x0008

    jr $31
    nop
    .end dmemcpy


    .globl wmemcpy
    .ent wmemcpy
# void wmemcpy(void *dest, void *src, int numwords);
wmemcpy:
    lw $2, 0($5)
    addiu $6, -1
    sw $2, 0($4)
    addiu $4, 0x0004
    bnez $6, wmemcpy
    addiu $5, 0x0004

    jr $31
    nop
    .end wmemcpy

