int CheckChinese(int chr);      // 檢查是否為 .15 中文字 (in isch.asm)
// 傳回 0=1 byte 英文字, 1=2 byte 中文符號, 2=2 byte 中文, 3=2 byte 中文符號2

int GetChineseOfs1615(int chType, int chr);     // 傳回其在檔案的偏移值

int GetChineseOfs24(int chType, int chr);       // 傳回其在檔案的偏移值

int getChinStrWidth(char *s);	// 計算輸出圖型區的總寬度

int getChinStrWidth24(char *s);	// 計算輸出圖型區的總寬度

char *getFont16(int chr);       // 取得 16x15 點陣資料

char *getFont24(int chr);       // 取得 24x24 點陣資料

void plotme(char *b1p, char *b32p, int x, int w, int h, int wb32);
// 把一位元點陣 (b1p), 輸出為 32 位元點陣 (b1p), w 須為 8 之倍數

int readChineseFont(void);	// 載入 16x15 及 24x24 字型

int str2ChineseBitmap16(char *s, char *buf);	// 傳回輸出圖型區總寬度 (dot)
// 將字串 s 轉成 16x15 中文字的 32-bit 點陣 (英數為 8x15, 中文字為 16x15)

int str2ChineseBitmap24(char *s, char *buf);	// 傳回輸出圖型區總寬度 (dot)
// 將字串 s 轉成 24x24 中文字的 32-bit 點陣 (英數為 16x24, 中文字為 24x24)

int swap16(int v);
