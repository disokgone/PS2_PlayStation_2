	.set noreorder

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
	.align	3	# 8 bytes
#--------------------------------------
	.global 	DMA02wait
	.global 	SendPrim
	.global 	DMAreset
#--------------------------------------
	.text
	.ent		DMA02wait
#--------------------------------------
# void DMA02wait(void);
DMA02wait:
	lw	$4, xDMA02CH
	andi	$4, $4, 0x0100
	bne	$4, $0, DMA02wait
	nop
	jr	$31
	nop
#--------------------------------------
# void SendPrim(void *PrimList);
SendPrim:
	sw	$4, xDMA02TAG
	sw	$0, xDMA02SIZE
	lw	$4, xDMA02CH
	ori	$4, $4, 0x105
	sw	$4, xDMA02CH
	jr	$31
	nop
#--------------------------------------
# void DMAreset(void);
DMAreset:
	lui	$2, 0x1000
	ori	$2, $2, 0xA000
	sw	$0, 0x80($2)
	sw	$0, 0x00($2)
	sw	$0, 0x30($2)
	sw	$0, 0x10($2)
	sw	$0, 0x50($2)
	sw	$0, 0x40($2)

	ori	$2, $0, 0xFF1F
	sw	$2, xDMA01CTR
	lw	$4, xDMA01CTR
	and	$4, $4, $2
	sw	$4, xDMA01CTR

	la	$2, xDMA00CTR
	sw	$0, 0($2)
	sw	$0, 0x20($2)
	sw	$0, 0x30($2)
	sw	$0, 0x50($2)
	sw	$0, 0x40($2)

	lw	$3, 0($2)
	ori	$3, $3, 1
	sw	$3, 0($2)
	jr	$31
	nop
#--------------------------------------
	.end		DMA02wait
