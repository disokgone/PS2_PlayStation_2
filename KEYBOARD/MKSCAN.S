	section .text
MAXKEY	=	16 + 1
;PrtScr = E0 12 E0 7C // E0 F0 7C E0 F0 12 (E0+12=Left Shift, E0+7C=pad *)
;Pause = E1 14 77 E1 F0 14 F0 77 (E1=直接傳回, 14=Left CTRL, 77=NUM lock)
	public	on
GetKbdScan:
	public	off

	subiu	sp, sp, 16
	sw	ra, (sp)
	sw	t7, 4(sp)
	sw	v1, 8(sp)
	sw	t6, 12(sp)
	or	v0, zero, zero	;v0 = 0 (傳回值之位元組)(預設傳回值: no key)
	or	v1, zero, zero	;v1 = 0 (傳回值之位元組)
	or	t7, zero, zero	;t7 = keyuse 目前已檢視的按鍵數值
	la	t0, keyline	;t0 = &keyline
	la	t1, keycnt	;t1 = &keycnt
	lbu	t2, (t1)	;t2 = keycnt
	lbu	t3, (t0)	;t3 = 第一個傳來的 line code
	beq	t2, zero, @nokeys	;沒按鍵
	sltiu	t4, t2, MAXKEY
	bne	t4, zero, @check2	;good key count !
	ori	t2, zero, 0xE0
;bad key count here !
	beq	zero, zero, @skipall	;quick exit !!
	sb	zero, (t1)	;let keycnt = 0 !
@check2:
	beq	t2, t3, @isE0	;begin with $E0 (Special keys)
	ori	t2, zero, 0xE1
	bne	t2, t3, @notE1	;not Pause (E1 開頭為 Pause 鍵)
	ori	t2, zero, 0xF0
	beq	zero, zero, @nokeys
	ori	v0, zero, 0xE1	;直接傳回 0xE1 !

@notE1:
	bne	t2, t3, @notF0	;not key release (F0 開頭為放開鍵碼)
	nop
	addiu	t0, t0, 1	;keyline ++
	addiu	t7, t7, 1	;keyuse ++
	lbu	t3, (t0)	;t3 = 第貳個傳來的 line code
	ori	v1, zero, 0x80	;v1 = 0x80 (傳回放開鍵碼其 bit 7 = 1)
@notF0:
;Here is generic key !
	la	t2, KeyCodeTable
	sltiu	t4, t3, 0x84	;正常傳來按鍵值其值小於 $84
	beq	t4, zero, @nokeys	;bad line code, discard it !
	addu	t2, t2, t3
	lbu	t4, (t2)	;t4 = KeyCodeTable[keyline]
	beq	zero, zero, @nokeys
	or	v0, v1, t4	;return(KeyOnOff + scancode)
@isE0:
	ori	v1, zero, 0xE000	;傳回值 v1 = 0xE000
	addiu	t0, t0, 1	;keyline ++
	addiu	t7, t7, 1	;keyuse ++
	lbu	t3, (t0)	;t3 = 第貳個傳來的 line code
	ori	t2, zero, 0xF0
	bne	t2, t3, @not_F0 ;not key release
	nop
	addiu	t0, t0, 1	;keyline ++
	addiu	t7, t7, 1	;keyuse ++
	lbu	t3, (t0)	;t3 = 第貳 or 第參個傳來的 line code
	ori	v1, v1, 0x80	;v1 |= 0x80 (傳回放開鍵碼其 bit 7 = 1)
@not_F0:
	la	t2, E0code
	ori	t6, zero, 19
@chnxky:
	lbu	t4, (t2)
	addiu	t2, t2, 2
	beq	t3, t4, @Found
	subiu	t6, t6, 1
	bgtz	t6, @chnxky
	nop
	beq	zero, zero, @nokeys	;沒有符合者 bad line data !
@Found:
	lbu	t4, -1(t2)
	nop
	or	v0, v1, t4	;return(KeyOnOff + scancode)
@nokeys:
	la	t0, keyline	;t0 = &keyline[0]
	lbu	t2, (t1)
	addiu	t7, t7, 1	;keyuse ++
	addu	t3, t0, t7	;t3 = &keyline[KEYUSE]
	subu	t2, t2, t7
	sb	t2, (t1)	;keycnt -= keyuse
@moves:
	lbu	t1, (t3)	;move undealed key to beginning of table
	addiu	t3, t3, 1
	sb	t1, (t0)	;將尚未處理的按鍵前移
	addiu	t0, t0, 1
	bgtz	t2, @moves
	subiu	t2, t2, 1
@skipall:
	lw	ra, (sp)
	lw	t7, 4(sp)
	lw	v1, 8(sp)
	lw	t6, 12(sp)
	jr	ra
	addiu	sp, sp, 16

	END
