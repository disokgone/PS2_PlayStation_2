	SECTION .TEXT
MAXCNT	=	16 + 1	;鍵盤 SIO 輸入緩衝區最多只放 16 字元
K_CAP	=	0x40	;Cap lock on
K_NUM	=	0x20	;Num lock on
K_SCR	=	0x10	;Scroll lock on
K_ALT	=	8	;ALT key on
K_CTRL	=	4	;CTRL key on
K_SHIFT2 =	3	;one of both SHIFT key on
K_SHIFT =	2	;total SHIFT+CapLock key on
K_TNUM	=	1	;total SHIFT+NUM-lock on
MAXKEYPTR	=	63
;--------------- 提供外部程式呼叫的函式 -------------------------------
;int putch(a0 = keyCode) -> 將 a0 的鍵碼值加入到鍵盤環狀緩衝區內
;	傳回 0 = 鍵盤環狀緩衝區未滿, 1 = 鍵盤環狀緩衝區已滿
;void processKbd(void) -> 處理傳來的鍵碼值, 可隨時呼叫以免 SIO 傳輸區佔滿
;short kbhit(void) -> 模擬一般的 C 語言函式 kbhit(), 有字傳回 1, 無字傳回 0
;void flushkbd(void) -> 清除鍵盤緩衝區
;short getch(void) -> 模擬一般的 C 語言函式 getch(), 無字傳回 0
;	有字傳回 high-byte = Scan-code, low-byte = ASCII code
;----------------------------------------------------------------------
;short kblinedata(void) -- 檢查 SIO 傳輸區是否有新按鍵傳來
	PUBLIC	ON
kblinedata:
	PUBLIC	OFF

	la	t1, keycnt
	lbu	t0, (t1)
	or	v0, zero, zero	;無字傳回 0
	sltiu	t2, t0, MAXCNT
	bgtz	t2, @haskey0
	nop
	sb	zero, (t1)
@nokey0:
	jr	ra
	nop
@haskey0:
	beq	t0, zero, @nokey0
	nop
	ori	v0, zero, 1	;有字傳回 1
	jr	ra
	nop

;----------------------------------------------------------------------
;void processKbd(void) -- 處理傳來的鍵碼值, 可隨時呼叫以免 SIO 傳輸區佔滿
;將按鍵值轉成鍵盤燈號與按鍵狀態與掃瞄碼並存到鍵盤緩衝區 keybuff
;!! 本程式處理時最好能先禁止 SIO 中斷, 以免發生錯誤 !!
	PUBLIC	ON
processKbd:
	PUBLIC	OFF
	subiu	sp, sp, 12
	sw	ra, (sp)
	sw	v1, 4(sp)
	sw	a1, 8(sp)
@readNext:
	jal	kblinedata	;先確認有無新按鍵
	or	t5, zero, zero	;= scan code
	beq	v0, zero, @byebye	;沒新按鍵則傳回 0
	or	t6, zero, zero	;= ASCII
	jal	GetKbdScan	;取得鍵盤傳來的 scan code !
	nop			;v0 = 取得的 scan code
	la	v1, KBDst0
	lw	t7, (v1)	;t7 = [stat, Hi_st1, Lo_st0]
;真正麻煩的分類即將開始 ! (目標 : t5=scan code, t6=ASCII code, t7=status)
;先取得其 ASCII code, 放到 t6 的 low-byte !
	beq	v0, zero, @readNext	;if (scancode == 0) goto @readNext
	or	t5, zero, v0	;t5 = scan code
	andi	v0, v0, 0x7F
	sltiu	t2, v0, 0x4F	;only for scan code = [$00 - $4E]
	beq	t2, zero, @noASCII
	srl	t2, t7, 16
	la	t1, scan2ASCII	;(a table in scancode.s)
	addu	t1, t1, v0
	lbu	t6, (t1)	;t6 = ASCII[scan_code]
@noASCII:
;現在 : t5 = scan code, t6 = ASCII code, t7 = KBDst0 and 1, t2 = KBDst2
	andi	t4, t2, K_TNUM	;若總合 NumLock 按著
	beq	t4, zero, @notnumlock
	nop
;************** 總合 NUM lock 鍵按下的部份在此檢查 **************
;檢查 t5/t6 (scan code/ASCII), 是 [pad 數字盤] 則轉換, 以查表行之
	la	t1, num_table	;以 num_table 為查表來源
	jal	_getTableValue	;查表取得按下 NUM lock 鍵後的 ASCII 值
	or	t0, t5, zero	;以 t5 (scan code) 去查表, 傳回值在 t0
	beq	t0, t5, @notnumlock
	nop
;值已改變, 轉換成功
	beq	zero, zero, @return
	or	t6, zero, t0	;setup new ASCII code
@notnumlock:
	andi	t4, t7, K_CTRL	;若 CTRL 按著
	bne	t4, zero, @ctrl_on
	andi	t4, t7, K_ALT	;若 Alt 按著, 則傳回 0 (Space 傳回 $20)
	bne	t4, zero, @alt_on
	ori	t4, zero, 0x39	;Space 鍵的 scan code = 0x39
	srl	t2, t7, 16
	andi	t4, t2, K_SHIFT ;若總合 Shift 按著 (A..Z)
	bne	t4, zero, @shift_on
@shift_ret:
	andi	t4, t7, K_SHIFT2	;若任一 Shift 按著 (0..9/symbol)
	bne	t4, zero, @shift2_on
;此處完全沒有燈亮 (Alt/Ctrl/Shift -- all off !)
;F11, F12 => 0x85, 0x86
	ori	t4, zero, 0x57	;t4 = F11
	bne	t4, t5, @notF11
	ori	t4, zero, 0x58	;t4 = F12
	ori	t5, zero, 0x85	;0x57 轉換為 0x85
@notF11:
	bne	t4, t5, @return
	nop
	ori	t5, zero, 0x86	;0x58 轉換為 0x86
;轉換已完成, 可存入鍵盤緩衝區
@return:
	or	a1, zero, t5	;a1 = t5 = pre-scan code
	andi	t5, t5, 0xFF	;t5 的 high byte 可能為 0xE0 將在此消去
	sll	v0, t5, 8	;t5 = scan code
	andi	a0, t6, 0xFF
	or	a0, a0, v0	;t6 = ASCII, a0 = (scan | ASCII)
;處理 INS/CAP/NUM/SCRL/ALT/CTRL/SHIFT
	jal	_changeLight	;檢查狀態與燈號設置
	nop
	beq	a0, zero, @readNext	;此鍵碼無效
	nop
	jal	putch		;將 a0 此鍵碼加到鍵盤讀取緩衝區
	nop
	beq	v0, zero, @readNext	;keybuff 環狀緩衝區未滿, 可再轉換
	nop
@byebye:
	lw	ra, (sp)
	lw	v1, 4(sp)
	lw	a1, 8(sp)
	jr	ra
	addiu	sp, sp, 12
;************** ALT 鍵按下的部份在此檢查 **************
@alt_on:
;檢查 t5/t6 (scan code/ASCII), 是 [0..9 -=] & [F1..F10] 則轉換
	jal	check_alt_1
	nop
	beq	t4, t5, @go_alt ;if (ASCII != $20) t6 = 0 (Space 傳回 $20) !
	nop
	or	t6, zero, zero	;若 Alt 按著且不是空白鍵, 則傳回 0
@go_alt:
	la	t1, alt_table	;以 alt_table 為查表來源
	jal	_getTableValue	;查表取得按下 alt 鍵後的 scan code 值
	or	t0, t5, zero	;以 t5 (scan code) 去查表, 傳回值在 t0
	beq	zero, zero, @return	;轉換已完成, 可存入鍵盤緩衝區
	or	t5, zero, t0	;setup new scan code
;************** CTRL 鍵按下的部份在此檢查 **************
;檢查 t5/t6 (scan code/ASCII), 是 [A..Z] & [0..9 -=] & [F1..F10] 則轉換
@ctrl_on:
;先檢查 ASCII => 'A..Z', 若符合則 ASCII -= 0x60
	ori	t2, zero, 0x61	;t2 = $61 (key 'a')
	sltu	t3, t6, t2
	bgtz	t3, @ctr_01	;t5 < 'a' ==> 非此段落
	ori	t2, zero, 0x7B	;t2 = $7A (key 'z'+1)
	sltu	t3, t6, t2
	beq	t3, zero, @ctr_01	;t5 > 'z' ==> 非此段落
	nop
	beq	zero, zero, @return	;不檢查 CTRL 部份了 !
	subiu	t6, t6, 0x60	;ASCII -= 0x60
@ctr_01:
;檢查 scan-code => 'F1..F10', 若符合則 scan-code += 0x0A
	ori	t2, zero, 0x3B	;t2 = $3B (key F1)
	sltu	t3, t5, t2
	bgtz	t3, @ctr_02	;t5 < F1 ==> 非此段落
	ori	t2, zero, 0x45	;t2 = $45 (key F10+1)
	sltu	t3, t5, t2
	beq	t3, zero, @ctr_02	;t5 > 'z' ==> 非此段落
	nop
	beq	zero, zero, @return	;不檢查 CTRL 部份了 !
	addiu	t5, t5, 0x0A	;scan-code += 0x0A
@ctr_02:
;檢查 scancode => '1..90-=', 若符合則 ASCII = 0
	ori	t2, zero, 0x02	;t2 = $02 (key '1')
	sltu	t3, t5, t2
	bgtz	t3, @ctr_03	;t5 < '1' ==> 非此段落
	ori	t2, zero, 0x0E	;t2 = $0E (key '='+1)
	sltu	t3, t5, t2
	beq	t3, zero, @ctr_03	;t5 > '=' ==> 非此段落
	nop
	or	t6, zero, zero	;此段落 ASCII = 0
@ctr_03:
;剩餘部份很亂, 以查表行之
	la	t1, ctr_table0	;以 ctr_table0 為查表來源
	jal	_getTableValue	;查表取得按下 shift 鍵後的 ASCII 值
	or	t0, t5, zero	;以 t5 (scan code) 去查表, 傳回值在 t0
	or	t6, zero, t0	;setup new ASCII code
	la	t1, ctr_table1	;以 ctr_table1 為查表來源
	jal	_getTableValue	;查表取得按下 shift 鍵後的 ASCII 值
	or	t0, t5, zero	;以 t5 (scan code) 去查表, 傳回值在 t0
	beq	zero, zero, @return	;不檢查 CTRL 部份了 !
	or	t5, zero, t0	;setup new scan code
;************** SHIFT 鍵按下的部份在此檢查 **************
@shift_on:
;檢查 t5/t6 (scan code/ASCII), 是 [A..Z] 則轉換
;先檢查 ASCII => 'A..Z', 若符合則 ASCII -= 0x20
	ori	t2, zero, 0x61	;t2 = $61 (key 'a')
	sltu	t3, t6, t2
	bgtz	t3, @shift_ret	;t5 < 'a' ==> 非此段落
	ori	t2, zero, 0x7B	;t2 = $7A (key 'z'+1)
	sltu	t3, t6, t2
	beq	t3, zero, @shift_ret	;t5 > 'z' ==> 非此段落
	nop
	beq	zero, zero, @return	;不檢查 CTRL 部份了 !
	andi	t6, t6, 0x5F	;ASCII &= 0x5F
@shift2_on:
;檢查 t5/t6 (scan code/ASCII), 是 [A..Z] 則轉換
;先檢查 ASCII => 'A..Z', 若符合則 ASCII -= 0x20
	ori	t2, zero, 0x61	;t2 = $61 (key 'a')
	sltu	t3, t6, t2
	bgtz	t3, @shi_01	;t5 < 'a' ==> 非此段落
	ori	t2, zero, 0x7B	;t2 = $7A (key 'z'+1)
	sltu	t3, t6, t2
	beq	t3, zero, @shi_01	;t5 > 'z' ==> 非此段落
	nop
	srl	t2, t7, 16	;t2 = KBDst2
	andi	t2, t2, K_SHIFT ;check Total Shift+CapsLock
	beq	t2, zero, @return	;不須改變大小寫
	nop
	beq	zero, zero, @return	;不檢查 CTRL 部份了 !
	andi	t6, t6, 0x5F	;ASCII &= 0x5F
@shi_01:
;檢查 scan-code => 'F1..F10', 若符合則 scan-code += 0x19
	ori	t2, zero, 0x3B	;t2 = $3B (key F1)
	sltu	t3, t5, t2
	bgtz	t3, @shi_02	;t5 < F1 ==> 非此段落
	ori	t2, zero, 0x45	;t2 = $45 (key F10+1)
	sltu	t3, t5, t2
	beq	t3, zero, @shi_02	;t5 > 'z' ==> 非此段落
	nop
	beq	zero, zero, @return	;不檢查 CTRL 部份了 !
	addiu	t5, t5, 0x19	;scan-code += 0x19
@shi_02:
;剩餘部份很亂, 以查表行之
	la	t1, shi_table0	;以 shi_table0 為查表來源
	jal	_getTableValue	;查表取得按下 shift 鍵後的 ASCII 值
	or	t0, t5, zero	;以 t5 (scan code) 去查表, 傳回值在 t0
	beq	t0, t5, @shntfnd0	;not found !
	nop
	beq	zero, zero, @return	;不檢查剩餘部份了 !
	or	t6, zero, t0	;setup new ASCII code
@shntfnd0:
	srl	t2, t7, 16	;t2 = KBDst2
	andi	t2, t2, K_TNUM	;check Total Shift+NumLock
	beq	t2, zero, @shi_03	;不須改變數字盤
	nop
	la	t1, num_table	;以 num_table 為查表來源
	jal	_getTableValue	;查表取得按下 shift 鍵後的 ASCII 值
	or	t0, t5, zero	;以 t5 (scan code) 去查表, 傳回值在 t0
	or	t6, zero, t0	;setup new ASCII code
@shi_03:
	la	t1, shi_table1	;以 shi_table1 為查表來源
	jal	_getTableValue	;查表取得按下 shift 鍵後的 ASCII 值
	or	t0, t5, zero	;以 t5 (scan code) 去查表, 傳回值在 t0
	beq	zero, zero, @return	;不檢查剩餘部份了 !
	or	t5, zero, t0	;setup new scan code
;----------------------------------------------------------------------
;檢查 t5/t6 (scan code/ASCII), 是 [0..9 -=] & [F1..F10] 則轉換
	PUBLIC	ON
check_alt_1:
	PUBLIC	OFF
;先檢查 '1..90-=', 若符合則 scan code + 0x76
	ori	t2, zero, 0x02	;t2 = $02 (key '1')
	sltu	t3, t5, t2
	bgtz	t3, @alt_ret	;t5 < '1' ==> 不轉換
	ori	t2, zero, 0x0E	;t2 = $0E (key '='+1)
	sltu	t3, t5, t2
	bgtz	t3, @alt_plus	;t5 <= '=' ==> 轉換, + 0x76 !!
	ori	t2, zero, 0x76
;檢查 'F1..F10', 若符合則 scan code + 0x2D
	ori	t2, zero, 0x3B	;t2 = $3B (key F1)
	sltu	t3, t5, t2
	bgtz	t3, @alt_ret	;t5 < '1' ==> 不轉換
	ori	t2, zero, 0x45	;t2 = $45 (key F10+1)
	sltu	t3, t5, t2
	beq	t3, zero, @alt_ret	;t5 <= '=' ==> 轉換, + 0x2D !!
	ori	t2, zero, 0x2D
@alt_plus:
	addu	t5, t5, t2	;加上差值
@alt_ret:
	jr	ra
	nop
;----------------------------------------------------------------------
;u_char _getTableValue(scan_code, xlat_table)
;t0 = 欲轉換的碼 (byte), t1 = 為查表來源, 傳回 t0 = 轉換後的碼 (byte)
;表格中第一字元為掃瞄碼, 第二字元為轉換後的碼, 查不到則 (t0) 碼不變
	PUBLIC	ON
_getTableValue:
	PUBLIC	OFF
	lbu	t2, (t1)	;取得被比較的碼 (byte)
	addiu	t1, t1, 2
	beq	t2, zero, @XlatDone	;是 0 則脫出
	nop
	bne	t2, t0, _getTableValue	;不相等則繼續找
	nop
@Found0:
	lbu	t0, -1(t1)	;取得轉換後的碼 (byte)
@XlatDone:
	jr	ra		;返回
	nop
;----------------------------------------------------------------------
;short addptr(kbdptr) => (t0 =	kbdptr), return t0 = new value of kbdptr
	PUBLIC	ON
_addkbdptr:
	PUBLIC	OFF
	ori	v1, zero, MAXKEYPTR-1
	beq	v1, t0, @been_top
	addiu	t0, t0, 2	;未到頂端, 可加 2
	jr	ra
	nop
@been_top:
	jr	ra
	or	t0, zero, zero	;已到頂端, 傳回 0
;----------------------------------------------------------------------
;處理 INS/CAP/NUM/SCRL/ALT/CTRL/SHIFT (檢查狀態與燈號設置)
;_changeLight(a0 = key_code, a1=pre-scan code), 傳回 a0 = key_code
	PUBLIC	ON
_changeLight:
	PUBLIC	OFF
	subiu	sp, sp, 8
	sw	ra, (sp)
	sw	v1, 4(sp)
	la	v1, KBDst0
	lhu	t7, (v1)	;t7.H = KBDst1, t7.L = KBDst0
	srl	t1, a0, 8	;t1 = scan_code
	ori	t0, zero, 0x3A	;CAP_LOCK 的按下碼
	ori	t2, zero, 0x4000
	jal	_try_thiskey
	ori	t3, zero, 0x40
	beq	a0, zero, @Used ;此鍵已處理, 可提早返回
	ori	t0, zero, 0x45	;NUM_LOCK 的按下碼
	ori	t2, zero, 0x2000
	jal	_try_thiskey
	ori	t3, zero, 0x20
	beq	a0, zero, @Used ;此鍵已處理, 可提早返回
	ori	t0, zero, 0x46	;SCR_LOCK 的按下碼
	ori	t2, zero, 0x1000
	jal	_try_thiskey
	ori	t3, zero, 0x10
	beq	a0, zero, @Used ;此鍵已處理, 可提早返回
	ori	t0, zero, 0x52	;Insert 的按下碼
	ori	t2, zero, 0x8000
	or	v0, zero, a0	;save a0 -> v0
	jal	_try_thiskey
	ori	t3, zero, 0x80
	beq	a0, zero, @Used ;此鍵已處理, 可提早返回
	or	a0, zero, v0	;restore a0 <- v0
;檢查 Alt !
	ori	t0, zero, 0x38	;=ALT ON
	bne	t0, t1, @notaltky
	ori	t0, zero, 0xB8	;=ALT OFF
;here is ALT ON !
	ori	t7, t7, 8
	srl	t4, a1, 8
	ori	t3, zero, 0xE0
	andi	t7, t7, 0xFDFF	;先假設是右側按鍵
	beq	t3, t4, @isRight
	nop
	or	t7, t7, 0x200	;Left-ALT ON !
@isRight:
	sh	t7, (v1)
	beq	zero, zero, @Used	;此鍵已處理, 可提早返回
	or	a0, zero, zero
@notaltky:
	bne	t0, t1, @notaltky2
;here is ALT OFF !
	andi	t7, t7, 0xFFF7
	srl	t4, a1, 8
	ori	t3, zero, 0xE0
	beq	t3, t4, @isRight2
	nop
	andi	t7, t7, 0x0FDFF ;Left-ALT OFF !
@isRight2:
	sh	t7, (v1)
	beq	zero, zero, @Used	;此鍵已處理, 可提早返回
	or	a0, zero, zero
@notaltky2:
;檢查 Ctrl !
	ori	t0, zero, 0x1D	;=CTRL ON
	bne	t0, t1, @notctrky
	ori	t0, zero, 0x9D	;=CTRL OFF
;here is CTRL ON !
	ori	t7, t7, 4
	srl	t4, a1, 8
	ori	t3, zero, 0xE0
	andi	t7, t7, 0xFEFF	;先假設是右側按鍵
	beq	t3, t4, @isRight3
	nop
	or	t7, t7, 0x100	;Left-CTRL ON !
@isRight3:
	sh	t7, (v1)
	beq	zero, zero, @Used	;此鍵已處理, 可提早返回
	or	a0, zero, zero
@notctrky:
	bne	t0, t1, @notctrky2
;here is CTRL OFF !
	andi	t7, t7, 0xFFFB
	srl	t4, a1, 8
	ori	t3, zero, 0xE0
	beq	t3, t4, @isRight4
	nop
	andi	t7, t7, 0x0FEFF ;Left-CTRL OFF !
@isRight4:
	sh	t7, (v1)
	beq	zero, zero, @Used	;此鍵已處理, 可提早返回
	or	a0, zero, zero
@notctrky2:
;檢查 Left-Shift !
	ori	t0, zero, 0x2A	;=Left Shift ON
	bne	t0, t1, @notlshift
	ori	t0, zero, 0xAA	;=Left Shift OFF
;here is Left-Shift ON !
	ori	t7, t7, 2
	sh	t7, (v1)
	beq	zero, zero, @Used	;此鍵已處理, 可提早返回
	or	a0, zero, zero
@notlshift:
	bne	t0, t1, @notlshift2
;here is Left-Shift OFF !
	andi	t7, t7, 0xFFFD
	sh	t7, (v1)
	beq	zero, zero, @Used	;此鍵已處理, 可提早返回
	or	a0, zero, zero
@notlshift2:
;檢查 Right-Shift !
	ori	t0, zero, 0x36	;=Right Shift ON
	bne	t0, t1, @notrshift
	ori	t0, zero, 0xB6	;=Right Shift OFF
;here is Right-Shift ON !
	ori	t7, t7, 1
	sh	t7, (v1)
	beq	zero, zero, @Used	;此鍵已處理, 可提早返回
	or	a0, zero, zero
@notrshift:
	bne	t0, t1, @Used		;已無檢查項目
;here is Left-Shift OFF !
	andi	t7, t7, 0xFFFE
	sh	t7, (v1)		;此鍵已處理, 可提早返回
	or	a0, zero, zero
;計算總合燈號值
@Used:
	la	v1, KBDst0
	lw	t7, (v1)		;t7 = [KBDst2, KBDst1, KBDst0]
	or	t2, zero, zero		;set t2 = result
	andi	t1, t7, 3
	beq	t1, zero, @no_shift	;沒按半個 shift 鍵
	nop
	ori	t2, zero, 3		;有按任一 shift 鍵
@no_shift:
	andi	t1, t7, K_CAP
	beq	t1, zero, @no_CAPon	;Cap Lock off
	nop
	xori	t2, t2, K_SHIFT 	;和 shift 總合值作 XOR
@no_CAPon:
	andi	t1, t7, K_NUM
	beq	t1, zero, @no_NUMon	;Num Lock off
	nop
	xori	t2, t2, K_TNUM		;和 NUM lock 總合值作 XOR
@no_NUMon:
	sb	t2, 2(v1)		;設定新的 KBDst2 總合值
	lw	ra, (sp)
	lw	v1, 4(sp)
	jr	ra
	addiu	sp, sp, 8
;----------------------------------------------------------------------
	PUBLIC	ON
_try_thiskey:
	PUBLIC	OFF
	bne	t0, t1, @notthis
	ori	t0, t0, 0x80	;放開碼
;正按著
	or	t7, t7, t2	;KBDst1 |= t2
	xor	t7, t7, t3	;KBDst0 ^= t3
	beq	zero, zero, @newStat
	or	a0, zero, zero	;此鍵碼必須消除 (只影響燈號)
@notthis:
	bne	t0, t1, @neither
	xori	t2, t2, 0xFFFF
;正放開
	and	t7, t7, t2	;KBDst1 mask off (t2)
	or	a0, zero, zero	;此鍵碼必須消除 (只影響燈號)
@newStat:
	jr	ra
	sh	t7, (v1)
@neither:
	jr	ra
	nop
;----------------------------------------------------------------------
;void flushkbd(void) -> 清除鍵盤緩衝區
	PUBLIC	ON
flushkbd:
	PUBLIC	OFF
	la	t1, keyHead
	sw	zero, (t1)	;keyTail = keyHead = 0
	jr	ra
	sh	zero, 4(t1)	;KBDst0 = KBDst1 = 0
;----------------------------------------------------------------------
;short kbhit(void) -> 模擬一般的 C 語言函式 kbhit(), 有字傳回 1, 無字傳回 0
	PUBLIC	ON
kbhit:
	PUBLIC	OFF
	la	t1, keyHead
	lw	t3, (t1)	;t3.H = keyTail, t3.L=keyHead
	or	v0, zero, zero		;v0 = 0 (no key)
	or	t4, zero, t3
	andi	t2, t3, MAXKEYPTR - 1	;t2 = keyHead
	srl	t3, t3, 16
	andi	t3, t3, MAXKEYPTR - 1	;t3 = keyTail
	beq	t2, t3, @noKeyinbuf
	nop
	addiu	v0, v0, 1		;v0 = 1 (has key)
@noKeyinbuf:
	jr	ra
	nop
;----------------------------------------------------------------------
;int getch(void) -> 模擬一般的 C 語言函式 getch(), 無字傳回 0
;	有字傳回 high-byte = Scan-code, low-byte = ASCII code
	PUBLIC	ON
getch:
	PUBLIC	OFF
	subiu	sp, sp, 8
	sw	ra, (sp)
	sw	t0, 4(sp)
	jal	kbhit
	nop		;t1=&keyHead, t2=keyHead, t3=keyTail
	beq	v0, zero, @noKeyinbuf2	;沒按鍵可讀
	nop
	la	t0, keybuff
	addu	t0, t0, t3
	lhu	v0, (t0)	;return(keybuff[keyTail])
	jal	_addkbdptr
	or	t0, zero, t3
	sh	t0, 2(t1)	;keyTail += 2
@noKeyinbuf2:
	lw	ra, (sp)
	lw	t0, 4(sp)
	jr	ra
	addiu	sp, sp, 8
;----------------------------------------------------------------------
;int putch(a0 = keyCode) 將 a0 的鍵碼值加入到鍵盤環狀緩衝區內
;ASCII 碼不為零且 scan code > 0x7F 者不可加入 (此為 key release code)
;ASCII 碼為零且 scan code > 0xA6 者不可加入 (此為 key release code)
;傳回 0 = 未滿, 1 = 已滿
	PUBLIC	ON
putch:
	PUBLIC	OFF
	subiu	sp, sp, 8
	sw	ra, (sp)
	sw	v1, 4(sp)
	andi	t0, a0, 0xFF	;t0 = ASCII
	beq	t0, zero, @noASCI
	srl	t0, a0, 8	;t0 = scan code
	sltiu	t0, t0, 0x80	;t0 = Boolean(t0 < 0x80)
	beq	t0, zero, @buf_Full	;不可加入 (此為 key release code)
	nop
	or	t0, zero, zero	;通過下列算式
@noASCI:
	sltiu	t0, t0, 0xA7	;t0 = Boolean(t0 < 0xA7)
	beq	t0, zero, @buf_Full	;不可加入 (此為 key release code)
	nop
@keptin:
	la	t1, keyHead
	lw	t3, (t1)	;t3.H = keyTail, t3.L=keyHead
	la	t2, keybuff	;t2 = keybuff
	srl	t4, t3, 16	;t4 = keyTail
	andi	t3, t3, MAXKEYPTR	;t3 = keyHead
	andi	t4, t4, MAXKEYPTR	;t4 = keyTail
;檢查緩衝區是否已滿
	jal	_addkbdptr
	or	t0, zero, t3
	beq	t0, t4, @buf_Full	;if ((keyHead+2) == keyTail) 緩衝區已滿
	ori	v0, zero, 1	;keybuff 環狀緩衝區已滿, 不可再轉換
	addu	t2, t2, t3
	sh	a0, (t2)	;keybuff[keyHead] = key_code
	sh	t0, (t1)	;keyHead += 2
	or	v0, zero, zero	;keybuff 環狀緩衝區未滿, 可再轉換
@buf_Full:
	lw	ra, (sp)
	lw	v1, 4(sp)
	jr	ra
	addiu	sp, sp, 8
;----------------------------------------------------------------------
	SECTION .DATA
	PUBLIC	ON
keybuff dd	0, 0, 0, 0	;8x8 = 64 bytes = 32 組 scancodes
	dd	0, 0, 0, 0
keyHead dh	0	;指到 keybuff 鍵盤緩衝區的頭端 (ring-buffer)
keyTail dh	0	;指到 keybuff 鍵盤緩衝區的尾端 (ring-buffer)
KBDst0	db	0	;鍵盤狀況 0 (相容於 PC-BIOS $40:17)
KBDst1	db	0	;鍵盤狀況 1 (相容於 PC-BIOS $40:18)
KBDst2	db	0	;b1=Cap, b0=Num 是否大小寫與數字盤工作狀態
	PUBLIC	OFF
	END
