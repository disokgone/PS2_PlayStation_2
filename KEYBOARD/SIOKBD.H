void StartSIOKBD(void);
void StopSIOKBD(void);

extern u_char	keyshow, keycnt, keyline[];

u_char putch(u_short keyCode);	// 將鍵碼值加入到鍵盤環狀緩衝區內
// 傳回 0 = 鍵盤環狀緩衝區未滿, 1 = 鍵盤環狀緩衝區已滿

void processKbd(void);	// 處理傳來的鍵碼值, 可隨時呼叫以免 SIO 傳輸區佔滿
u_short kbhit(void);	// 模擬一般的 C 語言 kbhit(), 有字傳回 1, 無字傳回 0

void flushkbd(void);	// 清除鍵盤緩衝區
u_short getch(void);	// 模擬一般的 C 語言 getch(), 無字傳回 0,
// 有字傳回 high-byte = Scan-code, low-byte = ASCII code
