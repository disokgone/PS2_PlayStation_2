	section .text

	public	on
WAITCNT1 equ	0x400			;0x400 * 6 * 29.5ns = 181.248 us
WAITCNT2 equ	0x800			;0x800 * 6 * 29.5ns = 362.496 us
WAITCNT3 equ	0x1800			;0x1800 * 6 * 29.5ns = 1087.488 us
oldSR	dw	0
	public	off

;byte mcsRW(byte toSIO);		// 只等 181 us, 若無中斷發生則為失敗
;寫出 1 byte 給記憶卡, 傳回讀到的 1 byte
	public	on
mcsRW:					;s = short wait
	public	off

	LUI	t7, 0x1F80
	ORI	v1, zero, WAITCNT1	;v1 = wait counter (181.248 us)
@wait01:
	LW	v0, 0x1070(t7)		;wait memcSIO interrupt !
	SUBIU	v1, v1, 1
	BLTZ	v1, @fail_0		;失敗傳回 -1
	ANDI	v0, v0, 0x80
	BEQ	v0, zero, @wait01	;wait memcSIO interrupt !
	NOP
	BEQ	zero, zero,  mcRWxint	;中斷已經發生, 可以交換資料
	NOP
@fail_0:
	JR	ra
	SUBIU	v0, zero, 1		;失敗傳回 -1

;------------------------------
;byte mclRW(byte toSIO);		// 等 1087 us, 若無中斷發生則為失敗
;寫出 1 byte 給記憶卡, 傳回讀到的 1 byte
	public	on
mclRW:					;l = long wait
	public	off

	LUI	t7, 0x1F80
	ORI	v1, zero, WAITCNT3	;v1 = wait counter (1087.488 us)
@wait02:
	LW	v0, 0x1070(t7)		;wait memcSIO INterrupt !
	SUBIU	v1, v1, 1
	BLTZ	v1, @fail_1		;time out ! 失敗傳回 -1
	ANDI	v0, v0, 0x80
	BEQ	v0, zero, @wait02	;wait memcSIO INterrupt !
	NOP
	BEQ	zero, zero,  mcRWxint	;中斷已經發生, 可以交換資料
	NOP
@fail_1:
	JR	ra
	SUBIU	v0, zero, 1		;失敗傳回 -1

;------------------------------
;byte mcRWxint(byte toMemc);		// 等待固定時間而非等中斷發生
;寫出 1 byte 給記憶卡, 傳回讀到的 1 byte
	public	on
mcRWxint:
	public	off

	LUI	t7, 0x1F80
	ORI	v1, zero, WAITCNT2	;v1 = wait counter (362.496 us)
@wait_03:
	LHU	v0, 0x1044(t7)
	SUBIU	v1, v1, 1
	BLTZ	v1, @fail_2		;time out ! 失敗傳回 -1
	ANDI	v0, v0, 0x80		;等資料已送出
	BNE	v0, zero, @wait_03	;wait SIO.STATUS.DSR == 0
	NOP
	LHU	v0, 0x104A(t7)
	NOP
	ORI	v0, v0, 0x12
	SH	v0, 0x104A(t7)		;memcSIO |= 0x12 (CR_ERRRST+CR_DTR)
	LBU	v0, 0x1040(t7)		;return(memcSIO.Rbuf)
	SB	a0, 0x1040(t7)		;send a0 to memcSIO.Sbuf
	SUBIU	v1, zero, 0x81
	JR	ra
	SW	v1, 0x1070(t7)		;ireg = 0xFF7F
@fail_2:
	JR	ra
	SUBIU	v0, zero, 1		;失敗傳回 -1

;------------------------------
;void _delay3n_2(long cnt);
	public	on
_delay3n_2:
	public	off

	SUBIU	a0, a0, 1
	BNE	a0, zero, _delay3n_2
	NOP
	JR	ra
	NOP

;------------------------------
;void _clr_imask(short bitmask);	;對所選位元禁能其中斷
	public	on
_clr_imask:
	public	off

	lui	t7, 0x1F80
	lw	v0, 0x1074(t7)		;v0 = old imask
	xori	v1, a0, 0xFFFF		;v1 = mask to clear imask
	and	v0, v1, v0		;mask your bits !
	jr	ra
	sw	v0, 0x1074(t7)		;set new imask !

;------------------------------
;void _set_imask(short bitmask);	;對所選位元致能其中斷
	public	on
_set_imask:
	public	off

	lui	t7, 0x1F80
	lw	v0, 0x1074(t7)		;v0 = old imask
	xori	v1, a0, 0xFFFF		;v1 = mask to clear ireg
	or	v0, v0, a0		;mask your bits !
	sw	v1, 0x1070(t7)		;set new ireg !
	jr	ra
	sw	v0, 0x1074(t7)		;set new imask !

;------------------------------
;void _clr_sio0(void);			// 初始 sio0 狀態
	public	on
_clr_sio0:
	public	off

	lui	t7, 0x1F80
	ori	v0, zero, 0x40
	sh	v0, 0x104A(t7)		;sio.ctrl = CR_INTRST
	ori	v0, zero, 0x11
	sh	v0, 0x104E(t7)		;sio.baud = 2073600 / 8
	ori	v0, zero, 0x0D		;No parity, no start bit, no stop bit
	jr	ra
	sh	v0, 0x1048(t7)		;sio.mode = MR_CHLEN_8 + MR_BR_1

;------------------------------
;void _en_intr(void);			// enable interrupt !
	public	on
_en_intr:
	public	off

	la	v1, oldSR
	lw	v0, (v1)
	nop
	mtc0	v0, r12
	jr	ra
	nop

;------------------------------
;void _no_intr(void);			// disable all interrupt !
	public	on
_no_intr:
	public	off

	mfc0	v0, r12
	la	v1, oldSR
	sw	v0, (v1)
	andi	v0, v0, 0xFBFE		;set intr0(-), IEc0(-)
	jr	ra
	mtc0	v0, r12

;------------------------------
	public	on
init_pad:
	public	off

	subu	sp,sp,4
	sw	ra,(sp)

	li	t0,0x1f801040
	li	t1,0x40
	sh	t1,10(t0)
	li	t1,0x88
	sh	t1,14(t0)
	li	t1,0x0d
	sh	t1,8(t0)
	li	t1,0x0a
	sh	t1,10(t0)
	jal	_delay3n_2
	li	a0,500

	li	t1,0x02
	sh	t1,10(t0)
	jal	_delay3n_2
	li	a0,500

	li	t1,0x2002
	sh	t1,10(t0)
	jal	_delay3n_2
	li	a0,500

	sh	zero,10(t0)

	lw	ra,(sp)
	nop
	jr	ra
	addu	sp,sp,4

	end
