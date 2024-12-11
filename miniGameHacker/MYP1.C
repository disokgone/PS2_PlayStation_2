#include <sys/types.h>
#include <file.h>
#include <kernel.h>
#include "GR_1.H"

// #define bufA 0x300000
#define pNTSC	0x1FC7FF52
// #define	x1x2	639 << 16		// 作用視窗 X=0 to X=639
#define x1x2	0x027F0000		// 作用視窗 X=0 to X=639
#define y1y2	0x00E00000		// 作用視窗 Y=0 to Y=223

#define BeginX	3
#define BeginY	3

#define sizeMyFont	0x1E0100
// 256 | (30 << 16)	// 16x15 字型, 一行 16 字, 共 2 行

#define DefDumpAddr	0x00300000
#define DefDumpLen	0x10000

void delay(int n);		// 等 n/60 sec
int dump(int adr);
void FillMem(int addr, int len, int val);	// 填入數值
void gputc(char c);		// 印出一字
void gputs(int x, int y, char *s);	// 印出一字串
void init_Screen(void);
void loadfont(void);		// 上傳我的字形
void loadfontA(void);		// 上傳我的字形
void prtByte(unsigned char v);
void prtInt(int v);
void switchScrn(int n);		// 切換畫面
void simple(void);
void Test01(void);
void Test02(void);

extern int pFont1;		// 放 32-bit [R,G,B,A] 的點陣陣列
int dumpAddr, dumpLen, TimeSlic;
int scrX, scrY;
char usable[34] = " @#$%:!?,<=>+-*/0123456789ABCDEF";
char hex[18] = "0123456789ABCDEF";

int _main(void)
{
// 設定傾印位址及長度, 等待時間
init_Screen();		// 基本的畫面初始
loadfontA();		// 上傳字形
simple();
delay(30);	// 等 0.5 sec
switchScrn(0);
switchScrn(1);

waitVSync1();
loadfont();		// 上傳字形
switchScrn(1);

waitVSync2();
FlushCache(0);
simple();
delay(30);	// 等 0.5 sec

Test01();
switchScrn(1);
delay(60);	// 等 1 sec

simple();
Test02();
switchScrn(0);
delay(60);	// 等 1 sec

simple();
switchScrn(1);
return(0);
}

// ------------ Hex 傾印 ------------
void simple(void)
{
FlushCache(0);

dumpAddr = (int) _main;
dumpLen = DefDumpLen;
TimeSlic = 4;

while(dumpLen > 0) {
	delay(40);	// 等 0.5 sec
	scrX = BeginX;		scrY = BeginY;
	dumpAddr = dump(dumpAddr);
	dumpLen -= 64;
	}
}
// ------------ Hex 傾印 ------------
int dump(int adr)
{
int	i, j;
char	*q, c;

q = (char *) adr;	scrX = 6;	scrY = 3;	c = 0;
gputs(6, 3, "   $");    prtInt(adr);    gputs(18, 3, " --");
for (i = 0;i < 8;i ++) {
	scrX = 4;	scrY = 4 + i;
	for (j = 0;j < 8;j ++) {
		prtByte(c);	gputc(' ');	c ++;
		q ++;
		}
	}
return(adr + 64);
}

// ------------ 基本的畫面初始 ------------
void init_Screen(void)
{
int	VidType;
char	*pc;

DMAreset();
pc = (char *) pNTSC;
// VidType = (*pc == 'E') ? 3 : 2;              // 是 NTSC = 2, PAL = 3
VidType = 2;
Init_GS(0, VidType, 1);
SetVideoMode();
DMA02wait();
setDrawEnv(x1x2, y1y2);		// 設定繪圖環境
}

// ------------ 切換畫面 ------------
#define co1	0xFFFFFF00	// 水色
#define co2	0xFF00FFFF	// yellow
#define co3	0x007FFFFF	// 淡黃色
#define co4	0x01FFFFFF	// 白色

void switchScrn(int n)
{
uploadBitMap32(&pFont1, 0x001E0100, 0, 224, 0x780);
uploadBitMap32(&pFont1, 0x001E0100, 200, 60, 0x780);	// 資料內容不合
FillMem(0x370000, 0x800, co3);	// 淡黃色
uploadBitMap32((void *) 0x370000, 0x00800010, 40, 20, 0x200);	// 失敗
FillMem(0x370000, 0x800, co4);
uploadBitMap32((void *) 0x370000, 0x00800010, 40, 90, 0x200);	// 失敗
if (n == 0) {
	FillMem(0x370000, 0x8000, co1);
	uploadBitMap32((void *) 0x370000, 0x00800100, 300, 90, 0x2000);
	}
else	{
	FillMem(0x370000, 0x6000, co2);
	uploadBitMap32((void *) 0x370000, 0x008000C0, 200, 110, 0x1800);
	}
}
// ------------ 填入數值 ------------
void FillMem(int addr, int len, int val)
{
int	*pi;

pi = (int *) addr;
while(len > 0) {  *pi = val;	pi ++;		len --;	}
}
// ------------ 等 n/60 sec ------------
void delay(int n)
{
int	i, j;

while(n > 0) {
	for (i=0;i < 0x40000;i++) j=i+1; 
	n --;
	}
// while(n > 0) {  waitVSync();	n --; }
}
// ------------ 印出一字串 ------------
void gputs(int x, int y, char *s)
{
int	n;	// , savX, savY;

// savX = scrX;		savY = scrY;
scrX = x;		scrY = y;	n = 0;
while(*s != 0) {
	gputc(*s);	s ++;
	n ++;		if (n > 255) break;	// 安全檢查
	}
// scrX = savX;		scrY = savY;
}
// ------------ 印出一字 ------------
void gputc(char c)
{	// 目前只有 '0-F', ' :!?,<=>+-*/' 可印
int	i, sXY, dXY;

for (i=0;i < 32;i ++) if (c == usable[i]) break;	// 有此字
if (i > 31) i = 1;
sXY = (i >> 4) ? 239 : 224;	// 0-F = 224, 10-1F = 239
sXY = ((i & 15) << 4) | (sXY << 16);
dXY = (scrY << 4) - scrY;	// 先乘 15
dXY = (scrX << 4) | (dXY << 16);
vramMove(sXY, dXY, 16, 15);
scrX ++;
if (scrX > 39) { scrY ++;	scrX = BeginX; }
if (scrY > 13) scrY = BeginY;
}
// ------------ 上傳我的字形 ------------
void loadfont(void)
{
uploadBitMap32(&pFont1, sizeMyFont, 32, 0, 0x780);	// 放到畫面 (0, 224) 備用
uploadBitMap32(&pFont1, sizeMyFont, 0, 32, 0x780);	// 放到畫面 (0, 224) 備用
uploadBitMap32(&pFont1, sizeMyFont, 224, 0, 0x780);	// 放到畫面 (0, 224) 備用
uploadBitMap32(&pFont1, sizeMyFont, 0, 224, 0x780);	// 放到畫面 (0, 224) 備用
}

// ------------ 印出 1 byte (Hex) ------------
void prtByte(unsigned char v)
{
char	c;

c = v & 15;		v = (v >> 4) & 15;
gputc(hex[v]);		gputc(hex[c]);
}

// ------------ 印出 4 byte (Hex) ------------
void prtInt(int v)
{
union	{
	int	i;
	unsigned char n[4];
	} iu;

iu.i = v;
prtByte(iu.n[3]);		prtByte(iu.n[2]);
prtByte(iu.n[1]);		prtByte(iu.n[0]);
}
