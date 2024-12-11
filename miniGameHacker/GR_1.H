/* DMA1.S */
void DMA02wait(void);
void DMAreset(void);
void SendPrim(void *PrimList);

/* GS1.S */
void Init_GS(int intlace, int ntscpal, int framefield);
	// intlace : 0=非交錯, 1=交錯
	// ntscpal : 2=NTSC, 3=PAL
	// framefield : 1=frame, 2=field

void SetVideoMode(void);

/* PIX1.S */
void conv1632(void *src16pixel, void *dst32pixel, int dotCount);
	// src16pixel : 指到含有 ABBBBBGGGGGRRRRR 的 16-bit 色點陣列
	// dst32pixel : 指到將放 { byte R, G, B, A } 的 32-bit 色點陣列
	// dotCount : 是指 16-bit 色點陣列來源欲轉換的色點數

/* SCRN1.S */
// void clearScrn(int X1X2, int Y1Y2);
void setDrawEnv(int X1X2, int Y1Y2);
	// x1x2 : low16 = left, high16 = right
	// y1y2 : low16 = top, high16 = bottom

void uploadBitMap32(void *pBitMap, int HHWW, int VramX, int VramY, int dotqwc);	// pBitMap 點陣位址
	// 把 32-bit [R,G,B,A] 圖形點陣上傳到 VRAM 的 (X, Y)
	// HHWW : low16 = Width, high16 = Height
	// dotdwc = W * H * 4 / 16 (= dots * 4 / 16, count by qword)

void vramMove(int srcXY, int dstXY, int width, int height);
	// 將 VRAM 的 (srcX, srcY) 圖形點陣搬移到 VRAM 的 (dstX, dstY)

void waitVSync1(void);
	// 產生並等待一次的 VSync 時間
void waitVSync2(void);

/* SYSCALL.S */
void FlushCache(int cacheType);
