	.set noreorder
	.text
	.align	3	# 8 bytes
	.ent		DMA_lib_1
#--------------------------------------
	.global 	DMA02wait
	.global 	SendPrim
	.global 	DMAreset
#--------------------------------------
xDMA02CH	=	0x1000A000
xDMA02ADR	=	0x1000A010
xDMA02SIZE	=	0x1000A020
xDMA02TAG	=	0x1000A030
xDMA00CTR	=	0x1000E000
xDMA01CTR	=	0x1000E010
xDMA02CTR	=	0x1000E020
xDMA03CTR	=	0x1000E030
xDMA04CTR	=	0x1000E040
xDMA05CTR	=	0x1000E050
#--------------------------------------
# void DMA02wait(void);
DMA02wait:
	lw	$a0, xDMA02CH
	andi	$a0, $a0, 0x0100
	bne	$a0, $zero, DMA02wait
	nop
	jr	$ra
	nop
#--------------------------------------
# void SendPrim(void *PrimList);
SendPrim:
	sw	$a0, xDMA02TAG
	sw	$zero, xDMA02SIZE
	lw	$a0, xDMA02CH
	ori	$a0, $a0, 0x105
	sw	$a0, xDMA02CH
	jr	$ra
	nop
#--------------------------------------
# void DMAreset(void);
DMAreset:
	lui	$v0, 0x1000
	ori	$v0, $v0, 0xA000
	sw	$zero, 0x80($v0)
	sw	$zero, 0x00($v0)
	sw	$zero, 0x30($v0)
	sw	$zero, 0x10($v0)
	sw	$zero, 0x50($v0)
	sw	$zero, 0x40($v0)

	ori	$v0, $zero, 0xFF1F
	sw	$v0, xDMA01CTR
	lw	$a0, xDMA01CTR
	and	$a0, $a0, $v0
	sw	$a0, xDMA01CTR

	la	$v0, xDMA00CTR
	sw	$zero, 0($v0)
	sw	$zero, 0x20($v0)
	sw	$zero, 0x30($v0)
	sw	$zero, 0x50($v0)
	sw	$zero, 0x40($v0)

	lw	$v1, 0($v0)
	ori	$v1, $v1, 1
	sw	$v1, 0($v0)
	jr	$ra
	nop
#--------------------------------------
	.end		DMA_lib_1
