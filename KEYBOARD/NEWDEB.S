	SECTION .TEXT

;u_long getCOPcreg(int COPnum, int regNum) 讀取某個輔助處理器的某個控制暫存器值
	PUBLIC	ON
getCOPcreg:
	PUBLIC	OFF
	subiu	sp, sp, 8
	sw	ra, (sp)
	sw	t0, 4(sp)
	lui	t0, 0x4042	;= CFCm V0, rnn 的指令
	andi	a0, a0, 3
	sll	a0, a0, 26	;=m
	andi	a1, a1, 31
	sll	a1, a1, 11	;=nn
	or	t0, t0, a0
	or	t0, t0, a1
	la	a0, @CFCHERE
	sw	t0, (a0)
	nop
	nop
	lw	ra, (sp)
@CFCHERE:
	nop			;此處放 CFCm V0, rnn 的指令
	lw	t0, 4(sp)
	jr	ra
	addiu	sp, sp, 8

;u_long getCOPreg(int COPnum, int regNum) 讀取某個輔助處理器的某個資料暫存器值
	PUBLIC	ON
getCOPreg:
	PUBLIC	OFF
	subiu	sp, sp, 8
	sw	ra, (sp)
	sw	t0, 4(sp)
	lui	t0, 0x4002	;= MFCm V0, rnn 的指令
	andi	a0, a0, 3
	sll	a0, a0, 26	;=m
	andi	a1, a1, 31
	sll	a1, a1, 11	;=nn
	or	t0, t0, a0
	or	t0, t0, a1
	la	a0, @MFCHERE
	sw	t0, (a0)
	nop
	nop
	lw	ra, (sp)
@MFCHERE:
	nop			;此處放 MFCm V0, rnn 的指令
	lw	t0, 4(sp)
	jr	ra
	addiu	sp, sp, 8

;u_long getHwReg(u_short no, u_char sz) 讀取某個硬體暫存器值
	PUBLIC	ON
getHwReg:
	PUBLIC	OFF
	lui	t0, 0x1F80
	andi	a0, a0, 0x3FFF
	andi	a1, a1, 7
	subiu	a1, a1, 1
	beq	a1, zero, @is1Byte
	or	a0, t0, a0
	subiu	a1, a1, 1
	beq	a1, zero, @is2Byte
	nop
	jr	ra
	lw	v0, (a0)
@is2Byte:
	jr	ra
	lhu	v0, (a0)
@is1Byte:
	jr	ra
	lbu	v0, (a0)

;void SetHwBP(HwBp)	設定硬體中斷點
	PUBLIC	ON
SetHwBP:
	PUBLIC	OFF
	lui	t0, 0xE100
	mfc0	t2, a3		;=mfc0 t2, $7 (= CP0.DCIC)
	ori	t1, 0x303F
	and	t2, t2, t1
	or	t2, t2, t0
	mtc0	t2, a3		;=mtc0 t2, $7 (= CP0.DCIC)
	mtc0	a0, v1		;=mtc0 t2, $3 (= CP0.BPC)
	la	t0, 0xFFFFFFFF
	jr	ra
	mtc0	t0, t3		;=mtc0 t2, $11 (= CP0.BPCM)

;void SetMyDebug(void)	安裝我的除錯中斷處理程式
	PUBLIC	ON
SetMyDebug:
	PUBLIC	OFF
	la	t0, @NewDebugIn
	lui	t1, 0x3C1A
	srl	t2, t0, 16
	or	t1, t1, t2
	sw	t1, 0x40(zero)	;=0x3C1Apppp (LUI K0, pppp)
	lui	t1, 0x275A
	andi	t2, t0, 0xFFFF
	or	t1, t1, t2
	sw	t1, 0x44(zero)	;=0x275Aqqqq (ORI K0, K0, qqqq)
	la	t2, 0x03400008
	sw	t2, 0x48(zero)		;= JR	 K0
	jr	ra
	sw	zero, 0x4C(zero)	;= NOP
;---- 此段程式取自勝利男孩以求相容性
@NewDebugIn:
	subiu	sp, sp, 8
	sw	ra, (sp)
	sw	at, 4(sp)		;我增加的, 勝利男孩沒有 (at => $FCF4)
;按此順序保存暫存器 (未保留 at, sp, ra)
	jal	SaveReg
	or	at, zero, 0xFC80	;31 regs 偷放在 $0000FC80 - $0000FCFB
;計算中斷時的 sp 值
	addiu	t0, sp, 8
	sw	t0, 0x78(at)		;$FCF8 = sp
	lw	t1, (sp)
	lw	t2, 4(sp)
	sw	t1, 0x70(at)		;$FCF0 = ra
;使與電腦傳輸致能
	lbu	t0, 0x5F0(zero)
	sw	t2, 0x74(at)		;$FCF4 = at
	andi	t0, t0, 0xFFFE
	sb	t0, 0x5F0(zero) 	;$0.05F0 &= 0xFFFE (set not busy)
;取得 CP0 的部份暫存器值
	la	t0, _BPC
	mfc0	t1, v1		;= mfc0    t1, 3
	mfc0	t2, a1		;= mfc0    t2, 5
	sw	t1, (t0)	;= BPC
	sw	t2, 4(t0)	;= BDA
	mfc0	t1, a2		;= mfc0    t1, 6
	mfc0	t2, a3		;= mfc0    t2, 7
	sw	t1, 8(t0)	;= TAR
	sw	t2, 12(t0)	;= DCIC
	mfc0	t1, t1		;= mfc0    t1, 9
	mfc0	t2, t3		;= mfc0    t2, 11
	sw	t1, 16(t0)	;= BDAM
	sw	t2, 20(t0)	;= BPCM
	mfc0	t1, t4		;= mfc0    t1, 12
	mfc0	t2, t5		;= mfc0    t2, 13
	mfc0	t3, t6		;= mfc0    t3, 14
	sw	t1, 24(t0)	;= SR
	sw	t2, 28(t0)	;= CAUSE
	sw	t3, 32(t0)	;= EPC
;清除硬體除錯暫存器等
;程式將由 EPC+4 起執行 (非在 branch delay slot 被中斷)
;如 BREAK 指令是在 branch delay slot 則須將分支動作再執行一遍 (由 EPC 起執行)
;CLear DCIC 暫存器 bit 23 = 0 使 bit 31-24 的除錯功能暫時失效
	mfc0	t1, a3		;t1 = CP0.DCIC ($7)
	ori	t0, zero, 0xFFFF
	and	t1, t1, t0	;mask off bit 31-16 !!
	mtc0	t1, a3		;使 bit 31-24 的各項除錯功能暫時失效
;取用除錯程式的暫存器值
	la	t0, _savek0
	lw	k0, (t0)
	lw	k1, 4(t0)
	lw	ra, 20(t0)
	lw	gp, 8(t0)
	lw	sp, 12(t0)
	lw	fp, 16(t0)
	jr	ra		;返回除錯程式
	rfe			;使中斷恢復可用
;------- 取回被除錯的程式暫存器值並跳入執行 -------
;void RetProgReg(u_long exeAddr)
	PUBLIC	ON
RetProgReg:
	PUBLIC	OFF
;記錄除錯程式的暫存器值
	la	t0, _savek0
	sw	k0, (t0)
	sw	k1, 4(t0)
	sw	gp, 8(t0)
	sw	sp, 12(t0)
	sw	fp, 16(t0)
	sw	ra, 20(t0)
;設置一個跳躍指令 at @jumpIns (jr k0, k0 = exeAddr)
	la	t1, @jumpIns
	sh	a0, 4(t1)
	srl	a0, a0, 16
	sh	a0, (t1)	;合併到該指令 !
;取回被除錯的程式暫存器值並跳入執行
	jal	LoadReg 		;按此順序取回暫存器 (未取回 at, sp, ra)
	ori	at, zero, 0xFC80	;31 regs 偷放在 $0000FC80 - $0000FCFB
;Set DCIC 暫存器 bit 23 = 1 恢復 bit 31-24 的除錯功能
	mfc0	at, a3		;at = CP0.DCIC ($7=a3)
	la	ra, 0x00800000	;bit 23 = 1
	or	at, at, ra	;set bit 23 !
	mtc0	at, a3		;恢復 bit 31-24 的各項除錯功能
;取回 at, sp, ra
	ori	at, zero, 0xFC80	;31 regs 偷放在 $0000FC80 - $0000FCFB
	lw	sp, 0x78(at)
	lw	ra, 0x70(at)
	lw	at, 0x74(at)
	sw	k0, -4(sp)
@jumpIns:
	lui	k0, 0		;此處放置一個跳躍指令 k0 = xxxxxxxx
	ori	k0, k0, 0
	jr	k0		;此處放置一個跳躍指令 jr k0
	lw	k0, -4(sp)
;------------------------------
;void LoadMainReg(void);	;取回本程式暫存器值
	PUBLIC	ON
LoadMainReg:
	PUBLIC	OFF
	subiu	sp, sp, 4
	sw	ra, (sp)
	la	at, 0xFC00	;偷放在 $0000FC00 - $0000FC78
	jal	LoadReg 	;未保留 at, sp, ra
	nop
	lw	ra, (sp)
	nop
	jr	ra
	addiu	sp, sp, 4
;------------------------------
;void SaveMainReg(void);	;保存本程式暫存器值
	PUBLIC	ON
SaveMainReg:
	PUBLIC	OFF
	subiu	sp, sp, 8
	sw	ra, (sp)
	sw	at, 4(sp)
	la	at, 0xFC00	;偷放在 $0000FC00 - $0000FC78
	jal	SaveReg 	;未保留 at, sp, ra
	nop
	lw	ra, (sp)
	lw	at, 4(sp)
	jr	ra
	addiu	sp, sp, 8
;------- 用法須小心, 以 at 為基底 -------- (未保留 at, sp, ra)
	PUBLIC	ON
LoadReg:
	PUBLIC	OFF
	lw	gp, (at)		;按此順序保存暫存器 ($00-$6F)
	lw	v0, 4(at)
	lw	v1, 8(at)
	lw	a0, 0x0c(at)
	lw	a1, 0x10(at)
	lw	a2, 0x14(at)
	lw	a3, 0x18(at)
	lw	k0, 0x1c(at)
	lw	k1, 0x20(at)
	lw	t0, 0x24(at)
	lw	t1, 0x28(at)
	lw	t2, 0x2c(at)
	lw	t3, 0x30(at)
	lw	t4, 0x34(at)
	lw	t5, 0x38(at)
	lw	t6, 0x3c(at)
	lw	t7, 0x40(at)
	lw	t8, 0x44(at)
	lw	t9, 0x48(at)
	lw	s0, 0x4c(at)
	lw	s1, 0x50(at)
	lw	s2, 0x54(at)
	lw	s3, 0x58(at)
	lw	s4, 0x5c(at)
	lw	s5, 0x60(at)
	lw	s6, 0x64(at)
	lw	s7, 0x68(at)
	jr	ra
	lw	fp, 0x6c(at)
;------- 用法須小心, 以 at 為基底 -------- (未保留 at, sp, ra)
	PUBLIC	ON
SaveReg:
	PUBLIC	OFF
	sw	gp, (at)		;按此順序保存暫存器 ($00-$6F)
	sw	v0, 4(at)
	sw	v1, 8(at)
	sw	a0, 0x0c(at)
	sw	a1, 0x10(at)
	sw	a2, 0x14(at)
	sw	a3, 0x18(at)
	sw	k0, 0x1c(at)
	sw	k1, 0x20(at)
	sw	t0, 0x24(at)
	sw	t1, 0x28(at)
	sw	t2, 0x2c(at)
	sw	t3, 0x30(at)
	sw	t4, 0x34(at)
	sw	t5, 0x38(at)
	sw	t6, 0x3c(at)
	sw	t7, 0x40(at)
	sw	t8, 0x44(at)
	sw	t9, 0x48(at)
	sw	s0, 0x4c(at)
	sw	s1, 0x50(at)
	sw	s2, 0x54(at)
	sw	s3, 0x58(at)
	sw	s4, 0x5c(at)
	sw	s5, 0x60(at)
	sw	s6, 0x64(at)
	sw	s7, 0x68(at)
	jr	ra
	sw	fp, 0x6c(at)
;------------------------------
	SECTION .DATA
	PUBLIC	ON
_BPC	dw	0	;= CP0.$3
_BDA	dw	0	;= CP0.$5
_TAR	dw	0	;= CP0.$6
_DCIC	dw	0	;= CP0.$7
_BDAM	dw	0	;= CP0.$9
_BPCM	dw	0	;= CP0.$11
_SR	dw	0	;= CP0.$12
_CAUSE	dw	0	;= CP0.$13
_EPC	dw	0	;= CP0.$14
_savek0 dw	0	;執行程式前的特殊暫存器值
_savek1 dw	0
_savegp dw	0
_savesp dw	0
_savefp dw	0
_savera dw	0
	PUBLIC	OFF
	END
