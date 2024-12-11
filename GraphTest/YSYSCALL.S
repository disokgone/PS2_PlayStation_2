	.text
	.globl	AddDmacHandler
	.globl	AddIntcHandler
	.globl	ChangeThreadPriority
	.globl	CreateSema
	.globl	CreateThread
	.globl	DeleteSema
	.globl	DeleteThread
	.globl	Exit
	.globl	ExitDeleteThread
	.globl	ExitThread
	.globl	FlushCache
	.globl	FullReset
	.globl	GetThreadId
	.globl	GsGetIMR
	.globl	GsPutIMR
	.globl	HookSyscall	# = RFU116 (0x74)
	.globl	iHookEERW	# 掛上 eeReadMemory, eeReadMemory 的功能
	.globl	iPollSema
	.globl	iReferSemaStatus
	.globl	iRFU061 	# iRFU061 ?
	.globl	isceSifSetDChain
	.globl	isceSifSetDma
	.globl	iSignalSema
	.globl	iWakeupThread
	.globl	LoadExecPS2
	.globl	PollSema
	.globl	ReferSemaStatus
	.globl	RemoveDmacHandler
	.globl	RemoveIntcHandler
	.globl	ResetEE
	.globl	RFU003
	.globl	RFU060
	.globl	RFU061
	.globl	RFU116
	.globl	RotateThreadReadyQueue
	.globl	sceSifGetReg
	.globl	sceSifSetDChain
	.globl	sceSifSetDma
	.globl	sceSifSetReg
	.globl	eeReadMemory	# 要先執行 iHookSceRW
	.globl	eeWriteMemory	# 要先執行 iHookSceRW
	.globl	SetGsCrt
	.globl	SetVSyncFlag
	.globl	SignalSema
	.globl	SleepThread
	.globl	StartThread
	.globl	WaitSema
	.globl	WakeupThread
	.globl	_DisableDmac
	.globl	_DisableIntc
	.globl	_EnableDmac
	.globl	_EnableIntc
	.globl	_iDisableDmac


FullReset:
	addiu	$3, $0, 0
	syscall 0
	jr	$31
	nop

ResetEE:
	addiu	$3, $0, 1
	syscall 0
	jr	$31

SetGsCrt:
	addiu	$3, $0, 2
	syscall 0
	jr	$31

RFU003:
	addiu	$3, $0, 3
	syscall 0
	jr	$31

Exit:
	addiu	$3, $0, 4
	syscall 0
	jr	$31

LoadExecPS2:
	addiu	$3, $0, 6
	syscall 0
	jr	$31

# AddIntcHandler(int IntNo, void *IntrHandler, int code);
AddIntcHandler:
	addiu	$3, $0, 0x0010
	syscall 0
	jr	$31

# RemoveIntcHandler(int IntrNo, ?)
RemoveIntcHandler:
	addiu	$3, $0, 0x0011
	syscall 0
	jr	$31

AddDmacHandler:
	addiu	$3, $0, 0x0012
	syscall 0
	jr	$31

RemoveDmacHandler:
	addiu	$3, $0, 0x0013
	syscall 0
	jr	$31

# _EnableIntc(int IntrNo);
_EnableIntc:
	addiu	$3, $0, 0x0014
	syscall 0
	jr	$31

# _DisableIntc(int IntrNo);
_DisableIntc:
	addiu	$3, $0, 0x0015
	syscall 0
	jr	$31

_EnableDmac:
	addiu	$3, $0, 0x0016
	syscall 0
	jr	$31

_DisableDmac:
	addiu	$3, $0, 0x0017
	syscall 0
	jr	$31

_iDisableDmac:		# ??
	subu	$3, $0, 0x001D
	syscall 0
	jr	$31

CreateThread:
	addiu	$3, $0, 0x0020
	syscall 0
	jr	$31

DeleteThread:
	addiu	$3, $0, 0x0021
	syscall 0
	jr	$31

StartThread:
	addiu	$3, $0, 0x0022
	syscall 0
	jr	$31

ExitThread:
	addiu	$3, $0, 0x0023
	syscall 0
	jr	$31

ExitDeleteThread:
	addiu	$3, $0, 0x0024
	syscall 0
	jr	$31

ChangeThreadPriority:
	addiu	$3, $0, 0x0029
	syscall 0
	jr	$31

RotateThreadReadyQueue:
	addiu	$3, $0, 0x002B
	syscall 0
	jr	$31

GetThreadId:
	addiu	$3, $0, 0x002F
	syscall 0
	jr	$31

SleepThread:
	addiu	$3, $0, 0x0032
	syscall 0
	jr	$31

WakeupThread:
	addiu	$3, $0, 0x0033
	syscall 0
	jr	$31

iWakeupThread:
	subu	$3, $0, 0x0034
	syscall 0
	jr	$31

RFU060:		# RFU060($gp_addr, $gp_size, 0x80000, bss_beginAddr, Thread 例外處置位址);
	addiu	$3, $0, 0x003C
	syscall 0
	jr	$31

iRFU061:
	subu	$3, $0, 0x003C
	syscall 0
	jr	$31

RFU061:		# RFU061($sp_addr, $sp_size);
	addiu	$3, $0, 0x003D
	syscall 0
	jr	$31

CreateSema:
	addiu	$3, $0, 0x0040
	syscall 0
	jr	$31

DeleteSema:
	addiu	$3, $0, 0x0041
	syscall 0
	jr	$31

SignalSema:
	addiu	$3, $0, 0x0042
	syscall 0
	jr	$31

iSignalSema:
	subu	$3, $0, 0x0043
	syscall 0
	jr	$31

WaitSema:
	addiu	$3, $0, 0x0044
	syscall 0
	jr	$31

PollSema:
	addiu	$3, $0, 0x0045
	syscall 0
	jr	$31

iPollSema:
	subu	$3, $0, 0x0046
	syscall 0
	jr	$31

ReferSemaStatus:
	addiu	$3, $0, 0x0047
	syscall 0
	jr	$31

iReferSemaStatus:
	subu	$3, $0, 0x0048
	syscall 0
	jr	$31

FlushCache:
	addiu	$3, $0, 0x0064
	syscall 0
	jr	$31

GsGetIMR:
	addiu	$3, $0, 0x0070
	syscall 0
	jr	$31

GsPutIMR:
	addiu	$3, $0, 0x0071
	syscall 0
	jr	$31

SetVSyncFlag:
	addiu	$3, $0, 0x0073
	syscall 0
	jr	$31

HookSyscall:
	addiu	$3, $0, 0x0074
	syscall 0
	jr	$31

sceSifSetDma:
	addiu	$3, $0, 0x0077
	syscall 0
	jr	$31

isceSifSetDma:
	subu	$3, $0, 0x0077
	syscall 0
	jr	$31

sceSifSetDChain:
	addiu	$3, $0, 0x0078
	syscall 0
	jr	$31

isceSifSetDChain:
	subu	$3, $0, 0x0078
	syscall 0
	jr	$31

sceSifSetReg:
	addiu	$3, $0, 0x0079
	syscall 0
	jr	$31

sceSifGetReg:
	addiu	$3, $0, 0x007A
	syscall 0
	jr	$31

eeReadMemory:
	addiu	$3, $0, 0x00FE
	syscall 0
	jr	$31

eeWriteMemory:
	addiu	$3, $0, 0x00FF
	syscall 0
	jr	$31

# 掛上 eeReadMemory, eeReadMemory 的功能
	.set noreorder
iHookEERW:		
	subu	$29, $29, 0x10
	sd	$31, 0($29)

	la	$5, iReadEEMemory
	jal	HookSyscall
	addiu	$4, $0, 0xFE

	la	$5, iWriteEEMemory
	jal	HookSyscall
	addiu	$4, $0, 0xFF

	jal	FlushCache
	addu	$4, $0, $0

	jal	FlushCache
	addiu	$4, $0, 2

	ld	$31, 0($29)
	jr	$31
	addu	$29, $29, 0x10

iReadEEMemory:
	jr	$31
	lw	$2, 0($4)

iWriteEEMemory:
	sw	$5, 0($4)
	nop
	jr	$31
	lw	$2, 0($4)
	.set reorder
