sbuf	=	0x1C0000

	section .text
;dumploc	 dw	 0
;dumpmode	 dw	 0
;lnsz		 dw	 0

p04x	db	'%04X-', 0
p02Xb	db	'%02X ', 0
pNow	db	'Now at $%08lX', 0      ;MUST fill to 4 bytes

	public	on	xdump
;-------- ¨ú±o myCount --------
; void	 xdump(void)
xdump:
	subiu	sp, sp, 52
	sw	at, 24(sp)
	sw	s0, 28(sp)
	sw	s1, 32(sp)
	sw	s2, 36(sp)
	sw	s3, 40(sp)
	sw	s4, 44(sp)
	sw	ra, 48(sp)
	;----------
;>  mygrCLS();
	jal	mygrCLS
	nop
	;----------
;>  if (dumpmode == 0) {
	la	at, dumpmode
	lw	v0, (at)
	nop
;	bne	v0, zero, @modeNZ
	;----------
;>	for (j=2;j < 25;j ++) {
	addiu	s0, zero, 2	;s0 = j
@for_j:
	;----------
;>	    sprintf(sbuf, "%04X-", dumploc & 0xFFFF);        p = dumploc;
	la	s3, dumploc	;s3 = dumploc
	lw	s3, (s3)
	la	s4, sbuf	;s4 = sbuf
	la	a1, p04x
	andi	a2, s3, 0xFFFF
	jal	sprintf 	;= $11F280
	or	a0, s4, zero
	;----------
;>	    for (i=0, k=5;i < 8;i ++, k += 3) sprintf(sbuf+k, "%02X ", *p++);
	or	s1, zero, zero	;s1 = i = 0
	addiu	s2, zero, 5	;s2 = k = 5
@for_i:
	la	a1, p02Xb
	lbu	a2, (s3)
	jal	sprintf 	;= $11F280
	addu	a0, s4, s2
	addiu	s1, s1, 1	;i ++
	addiu	s2, s2, 3	;k += 3
	sltiu	at, s1, 8
	bne	at, zero, @for_i
	addiu	s3, s3, 1

	la	at, dumploc	;s3 = dumploc
	sw	s3, (at)
	;----------
;>	    grPrt(0, j, 0x40, sbuf, &bg0);
	la	at, bg0
	or	a0, zero, zero
	sw	at, 16(sp)
	or	a1, s0, zero
	addiu	a2, zero, 0x40
	jal	grPrt
	or	a3, s4, zero
	;----------
;>  lnsz = 8;
	la	v0, lnsz
	addiu	at, zero, 8
	sw	at, (v0)
	;----------
	addiu	s0, s0, 1	;j ++
	sltiu	at, s0, 25
	bne	at, zero, @for_j
@modeNZ:
;>  sprintf(sbuf, "Now at $%08lX", dumploc);
	or	a0, s4, zero
	la	a1, pNow
	jal	sprintf
	or	a2, s3, zero
	;----------
;>  grPrt(0, 26, 0x40, sbuf, &bg0);
	la	at, bg0
	or	a0, zero, zero
	sw	at, 16(sp)
	addiu	a1, zero, 26
	addiu	a2, zero, 0x40
	jal	grPrt
	or	a3, s4, zero
	;----------
;exit xdump()
	lw	ra, 48(sp)
	lw	at, 24(sp)
	lw	s0, 28(sp)
	lw	s1, 32(sp)
	lw	s2, 36(sp)
	lw	s3, 40(sp)
	lw	s4, 44(sp)
	jr	ra
	addiu	sp, sp, 52

	end
