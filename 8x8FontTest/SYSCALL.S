	.text
	.globl	AddDmacHandler
	.globl	AddIntcHandler
	.globl	ChangeThreadPriority
	.globl	CreateSema
	.globl	CreateThread
	.globl	DeleteSema
	.globl	DeleteThread
	.globl	ExitDeleteThread
	.globl	ExitThread
	.globl	FlushCache
	.globl	GetThreadId
	.globl	GsGetIMR
	.globl	GsPutIMR
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
	.globl	RFU060
	.globl	RFU061
	.globl	RFU116
	.globl	RotateThreadReadyQueue
	.globl	sceSifGetReg
	.globl	sceSifSetDChain
	.globl	sceSifSetDma
	.globl	sceSifSetReg
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


SetGsCrt:
	addiu	$v1, $zero, 2
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

# _EnableIntc(long IntrNo);
_EnableIntc:
	addiu	$v1, $zero, 0x0014
	syscall 0
	jr	$ra

# _DisableIntc(long IntrNo);
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

_iDisableDmac:
	subiu	$v1, $zero, 0x0017
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
	subiu	$v1, $zero, 0x0033
	syscall 0
	jr	$ra

RFU060:
	addiu	$v1, $zero, 0x003C
	syscall 0
	jr	$ra

iRFU061:
	subiu	$v1, $zero, 0x003C
	syscall 0
	jr	$ra

RFU061:
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
	subiu	$v1, $zero, 0x0042
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
	subiu	$v1, $zero, 0x0045
	syscall 0
	jr	$ra

ReferSemaStatus:
	addiu	$v1, $zero, 0x0047
	syscall 0
	jr	$ra

iReferSemaStatus:
	subiu	$v1, $zero, 0x0047
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

RFU116:
	addiu	$v1, $zero, 0x0074
	syscall 0
	jr	$ra

sceSifSetDma:
	addiu	$v1, $zero, 0x0077
	syscall 0
	jr	$ra

isceSifSetDma:
	subiu	$v1, $zero, 0x0077
	syscall 0
	jr	$ra

sceSifSetDChain:
	addiu	$v1, $zero, 0x0078
	syscall 0
	jr	$ra

isceSifSetDChain:
	subiu	$v1, $zero, 0x0078
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

