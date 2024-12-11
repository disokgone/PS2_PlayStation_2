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
	addiu	$v1, $zero, 0
	syscall 0
	jr	$ra
	nop

ResetEE:
	addiu	$v1, $zero, 1
	syscall 0
	jr	$ra

SetGsCrt:
	addiu	$v1, $zero, 2
	syscall 0
	jr	$ra

RFU003:
	addiu	$v1, $zero, 3
	syscall 0
	jr	$ra

Exit:
	addiu	$v1, $zero, 4
	syscall 0
	jr	$ra

LoadExecPS2:
	addiu	$v1, $zero, 6
	syscall 0
	jr	$ra

# AddIntcHandler(int IntNo, void *IntrHandler, int code);
AddIntcHandler:
	addiu	$v1, $zero, 0x0010
	syscall 0
	jr	$ra

# RemoveIntcHandler(int IntrNo, ?)
RemoveIntcHandler:
	addiu	$v1, $zero, 0x0011
	syscall 0
	jr	$ra

AddDmacHandler:
	addiu	$v1, $zero, 0x0012
	syscall 0
	jr	$ra

RemoveDmacHandler:
	addiu	$v1, $zero, 0x0013
	syscall 0
	jr	$ra

# _EnableIntc(int IntrNo);
_EnableIntc:
	addiu	$v1, $zero, 0x0014
	syscall 0
	jr	$ra

# _DisableIntc(int IntrNo);
_DisableIntc:
	addiu	$v1, $zero, 0x0015
	syscall 0
	jr	$ra

_EnableDmac:
	addiu	$v1, $zero, 0x0016
	syscall 0
	jr	$ra

_DisableDmac:
	addiu	$v1, $zero, 0x0017
	syscall 0
	jr	$ra

_iDisableDmac:		# ??
	subu	$v1, $zero, 0x001D
	syscall 0
	jr	$ra

CreateThread:
	addiu	$v1, $zero, 0x0020
	syscall 0
	jr	$ra

DeleteThread:
	addiu	$v1, $zero, 0x0021
	syscall 0
	jr	$ra

StartThread:
	addiu	$v1, $zero, 0x0022
	syscall 0
	jr	$ra

ExitThread:
	addiu	$v1, $zero, 0x0023
	syscall 0
	jr	$ra

ExitDeleteThread:
	addiu	$v1, $zero, 0x0024
	syscall 0
	jr	$ra

ChangeThreadPriority:
	addiu	$v1, $zero, 0x0029
	syscall 0
	jr	$ra

RotateThreadReadyQueue:
	addiu	$v1, $zero, 0x002B
	syscall 0
	jr	$ra

GetThreadId:
	addiu	$v1, $zero, 0x002F
	syscall 0
	jr	$ra

SleepThread:
	addiu	$v1, $zero, 0x0032
	syscall 0
	jr	$ra

WakeupThread:
	addiu	$v1, $zero, 0x0033
	syscall 0
	jr	$ra

iWakeupThread:
	subu	$v1, $zero, 0x0034
	syscall 0
	jr	$ra

RFU060:		# RFU060($gp_addr, $gp_size, 0x80000, bss_beginAddr, Thread 例外處置位址);
	addiu	$v1, $zero, 0x003C
	syscall 0
	jr	$ra

iRFU061:
	subu	$v1, $zero, 0x003C
	syscall 0
	jr	$ra

RFU061:		# RFU061($sp_addr, $sp_size);
	addiu	$v1, $zero, 0x003D
	syscall 0
	jr	$ra

CreateSema:
	addiu	$v1, $zero, 0x0040
	syscall 0
	jr	$ra

DeleteSema:
	addiu	$v1, $zero, 0x0041
	syscall 0
	jr	$ra

SignalSema:
	addiu	$v1, $zero, 0x0042
	syscall 0
	jr	$ra

iSignalSema:
	subu	$v1, $zero, 0x0043
	syscall 0
	jr	$ra

WaitSema:
	addiu	$v1, $zero, 0x0044
	syscall 0
	jr	$ra

PollSema:
	addiu	$v1, $zero, 0x0045
	syscall 0
	jr	$ra

iPollSema:
	subu	$v1, $zero, 0x0046
	syscall 0
	jr	$ra

ReferSemaStatus:
	addiu	$v1, $zero, 0x0047
	syscall 0
	jr	$ra

iReferSemaStatus:
	subu	$v1, $zero, 0x0048
	syscall 0
	jr	$ra

FlushCache:
	addiu	$v1, $zero, 0x0064
	syscall 0
	jr	$ra

GsGetIMR:
	addiu	$v1, $zero, 0x0070
	syscall 0
	jr	$ra

GsPutIMR:
	addiu	$v1, $zero, 0x0071
	syscall 0
	jr	$ra

SetVSyncFlag:
	addiu	$v1, $zero, 0x0073
	syscall 0
	jr	$ra

HookSyscall:
	addiu	$v1, $zero, 0x0074
	syscall 0
	jr	$ra

sceSifSetDma:
	addiu	$v1, $zero, 0x0077
	syscall 0
	jr	$ra

isceSifSetDma:
	subu	$v1, $zero, 0x0077
	syscall 0
	jr	$ra

sceSifSetDChain:
	addiu	$v1, $zero, 0x0078
	syscall 0
	jr	$ra

isceSifSetDChain:
	subu	$v1, $zero, 0x0078
	syscall 0
	jr	$ra

sceSifSetReg:
	addiu	$v1, $zero, 0x0079
	syscall 0
	jr	$ra

sceSifGetReg:
	addiu	$v1, $zero, 0x007A
	syscall 0
	jr	$ra

eeReadMemory:
	addiu	$v1, $zero, 0x00FE
	syscall 0
	jr	$ra

eeWriteMemory:
	addiu	$v1, $zero, 0x00FF
	syscall 0
	jr	$ra

# 掛上 eeReadMemory, eeReadMemory 的功能
	.set noreorder
iHookEERW:		
	subu	$sp, $sp, 0x10
	sd	$ra, 0($sp)

	la	$a1, iReadEEMemory
	jal	HookSyscall
	addiu	$a0, $zero, 0xFE

	la	$a1, iWriteEEMemory
	jal	HookSyscall
	addiu	$a0, $zero, 0xFF

	jal	FlushCache
	addu	$a0, $zero, $zero

	jal	FlushCache
	addiu	$a0, $zero, 2

	ld	$ra, 0($sp)
	jr	$ra
	addu	$sp, $sp, 0x10

iReadEEMemory:
	jr	$ra
	lw	$v0, 0($a0)

iWriteEEMemory:
	sw	$a1, 0($a0)
	nop
	jr	$ra
	lw	$v0, 0($a0)
	.set reorder
