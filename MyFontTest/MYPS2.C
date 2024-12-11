#include <stdio.h>
#include <tamtypes.h>
#include <kernel.h>
#include <sifrpc.h>
#include <malloc.h>
#include <string.h>
#include <mylibk.h>	// 須引用 sifrpc.h !
/* 其它的 .H 檔放在 C:\PS2DEV\GCC\MYINC\FROM_TUT\ 之下 */
#include <g2.h>
#include <gs.h>
#include "nuputs.h"
#include "ETFONT.h"
#include "GR_1.H"
#include "hw.h"
#include "pad.h"
#include "sceCDROM.h"	// 我自訂, 取自 Action-Replay 2 程式

#define x1x2	0x027F0000		// 清除作用視窗 X=0 to X=639
#define y1y2	0x00DF0000		// 清除作用視窗 Y=0 to Y=223
//#define x3x4	0x027F0000		// 清除作用視窗 X=0 to X=639
//#define y3y4	0x01BF00E0		// 清除作用視窗 Y=224 to Y=447

#define BeginX	0
#define BeginY	0

#define sizeMyFont	0x1E0100
// 256 | (30 << 16)	// 16x15 字型, 一行 16 字, 共 2 行

#define DefDumpAddr	0x00420000
#define DefDumpLen	0x1000

void delay(int n);		// 等 n/60 sec
int  dump(int adr);
void errlog(char *s);
void FillMem(int addr, int len, int val);	// 填入數值
void go_down(void);		// = k_SleepThread()
void gputc(char c);		// 印出一字
void gputs(int x, int y, char *s);	// 印出一字串
void init_Screen(void);		// 基本的畫面初始
void loadfontA(void);		// 上傳我的字形 to (0, 448)
void mainLoop(void);		// 程式主迴圈
void mainLoop2(void);		// 程式主迴圈 2 (中文測試)
void pcdump(int adr, int len);	// hex dump to PC
void prtByte(unsigned char v);
void prtInt(int v);
void ptByte(unsigned char v);
void ptInt(int v);
int putChinStr16(int x, int y, char *s);	// 在 dot(x, y) 處印出中英文串 s
int putChinStr24(int x, int y, char *s);	// 在 dot(x, y) 處印出中英文串 s
void readEETo(int ee, int iop, int len);	// len 須是 4 的倍數
void SetDrawTo(int toDraw);	// 設定要畫的緩衝區號 frame buffer 0 or 1
void testCD(void);
void test_chin_16(int chr);	// 試印中文
void test_chin_24(int chr);	// 試印中文
extern void readMyFont(void *pFont);
int installMyExceptionHandler(void);
void ExceptHandlerA(void);
void ExceptHandler(int status, int cause, int epc, int badVA, int regList);
int wait_pad(void);	// 等待按下任意鍵
// extern int pFont1;		// 放 32-bit [R,G,B,A] 的點陣陣列
// int pFont1 = 0x140000;

int maxx, maxy;
int nowDraw;		// 現在正要繪圖的 frame buffer 編號 (0 or 1)
int *pFont1;		// 256 * 30 的 32-bit 點陣字元 (alpha = 0..0x7F)
int dumpAddr, dumpLen, TimeSlic;
int scrX, scrY, fd;
int *pi, xofs, yofs;
int errX = 1;		// for error log !
int errY = 13;		// for error log !
int nchi, ScrOfs;
u32 paddata;
u32 old_pad = 0;
u32 new_pad;
char *pbuf;		// 印字用的暫時指標
char usable[34] = " @#$%:!?,<=>+-*/0123456789ABCDEF";	// 可印出的字元
char hex[18] = "0123456789ABCDEF";	// 十六進位傾印用的字元
char chinmode = 0;
void *pFont;
extern void *get_myFont2(void);

int _main(void)
{
pFont = get_myFont2();
init_Screen();		// 基本的畫面初始

sif_rpc_init(0);	// for pad, naplink...
install_VRstart_handler();	// 垂直回掃管理
iHookEERW();		// 可自由讀寫 EE 主記憶體 !
nputs("Go ! \n");	// !! 必須先暖身, 否則 nprintf() 會當掉 !! (原因不明)
nprintf("pFont2 = %X", pFont);

// if (installMyExceptionHandler()) nputs("Exception Handler 安裝失敗 !");

do_pad_init();		// joy pad 初始化 (in my_pad.c)

// 讀取字型到 pFont1 !
// pFont1 = (int *) 0x420000;
// readMyFont(pFont1);

// loadfontA();		// 上傳字形, 成功 !
scrX = scrY = 0;	nchi = 0xA140;

// testCD();
// 設定傾印位址及長度, 等待時間
dumpAddr = DefDumpAddr;
dumpLen = DefDumpLen;
TimeSlic = 4;

dumpAddr = dump((int) dumpAddr);
dumpLen -= 64;		
gputs(0, 0, "ABCDEF :");	gputc(0x30 + nowDraw);

ExceptHandler(0, 1, 2, 3, 0x19200);
// ExceptHandlerA();
//wait_pad();	// wait for any key pressed !

// fd = readChineseFont();		// 載入 16x15 及 24x24 字型
nprintf("readChineseFont = %d", fd);

nprintf("Go : %d, pFont1 = %X\n", 66, &pFont1);

	mainLoop();	// 程式主迴圈

nputs("Bye ! \n");
go_down();
return(0);
}

// ------------ Hex 傾印 ------------
int dump(int adr)
{
int	i, j;
char	*q, c;

q = (char *) adr;	c = 0;
gputs(3, 1, "   $");    prtInt(adr);    gputs(15, 1, " --");
for (i = 0;i < 8;i ++) {
	scrX = 1;	scrY = 2 + i;
	for (j = 0;j < 8;j ++) {
		prtByte(*q);	gputc(' ');
		q ++;
		}
	}
return(adr + 64);
}
// ------------ 在畫面上顯示錯誤 ------------
void errlog(char *s)
{
gputs(errX, errY, s);
errX += strlen(s);
if (errX > 79) {  errX = 0;  errY ++;  }
if (errY > 13) errY = 0;
// nprintf("x = %d, y= %d, s = %s", errX, errY, s);
}
// ------------ 基本的畫面初始 ------------
void init_Screen(void)
{
// int	VidType;
// char	*pc;

/* do init for G2.c */
	if (gs_is_ntsc())	g2_init(NTSC_640_224_32);
	else			g2_init( PAL_640_256_32);

	maxx = g2_get_max_x();
	maxy = g2_get_max_y();

	// clear the screens and make sure visible and active
	// buffers are different.
	g2_set_active_frame(0);
	g2_set_fill_color(0, 0, 0);
	g2_fill_rect(0, 0, maxx, maxy);
	g2_set_visible_frame(0);

	g2_set_active_frame(1);
	g2_set_fill_color(0, 0, 0);
	g2_fill_rect(0, 0, maxx, maxy);

	gs_load_texture(0, 512, 192, 112, (uint32) pFont, 0, 640);
/* end init for G2.c */

/*Areset();
// #define pNTSC	0x1FC7FF52
// pc = (char *) pNTSC;
// VidType = (*pc == 'E') ? 3 : 2;              // 是 NTSC = 2, PAL = 3
VidType = 2;
Init_GS(0, VidType, 1);		// set 640 x 224 (32-bpp)
SetVideoMode();
DMA02wait();
setDrawOfs(0); 			// 設定繪圖環境 (frame at addr $0)
FlushCache(0); */
nowDraw = 0;			// 現在正要繪圖的 frame buffer 編號 (0 or 1)
}
// ------------ 程式主迴圈 ------------
void mainLoop(void)
{
struct padButtonStatus buttons;		// in pad.h
int	cnt, i, xpos, ypos;
char	ret, lastkey;

xpos = 0;	ypos = 0;	cnt = 0;	lastkey = 99;
while (1) {
	SetDrawTo(nowDraw);	// 設定要畫的緩衝區號 frame buffer 0 or 1
	nowDraw ^= 1;

	g2_set_fill_color(0, 0, 0);
	g2_fill_rect(0, 0, 639, 200);		// CLS

	dumpAddr = dump((int) dumpAddr);
	dumpLen -= 64;		
	gputs(0, 0, "ABCDEF :");	gputc(0x30 + nowDraw);
	for (i=1;i < 32;i ++) usable[i] = i;
	usable[32] = 0;
	gputs(0, 11, usable);

	for (i=32;i < 64;i ++) usable[i-32] = i;
	usable[32] = 0;
	gputs(0, 12, usable);

	g2_set_color(255, 255, 255);	g2_line(0, 0, 639, 223);
	g2_set_color(255, 255, 0);	g2_line(4, 0, 600, 0);
	g2_set_color(255, 0, 255);	g2_line(600, 0, 600, 223);
	g2_set_color(0, 255, 255);	g2_line(600, 223, 4, 223);
	g2_set_color(255, 220, 128);	g2_line(4, 223, 4, 0);

/*	g2_set_fill_color(145, 230, 98);
	g2_fill_rect(60, 30, 560, 60);
	g2_fill_rect(0, 0, 0xBA, 16);
	g2_fill_rect(126, 158, 320, 176);	*/

	setDisplayOfs(0, ypos);		// 檢查是否有畫到兩個畫面時使用

	// read pad !
        ret = padRead(0, 0, &buttons); // port, slot, buttons
        if (ret != 0) {
		ret = 0;
		paddata = 0xffff ^ ((buttons.btns[0] << 8) | buttons.btns[1]);
		new_pad = paddata & ~old_pad;
		old_pad = paddata;
		if (new_pad & PAD_L1) {
			LoadExecPS2("cdrom0:\\NAPLINK.ELF;1", 0, NULL);
			Exit(0);
			}
		if (new_pad & PAD_L2) {
			__asm__(" j 0xA0000");
			}
		if (new_pad & PAD_R1) {
//			LoadExecPS2("host0:c:\\PSX\\PSII\\3_STARS.EXE", 0, NULL);
			LoadExecPS2("cdrom0:\\3_STARS.EXE;1", 0, NULL);
			Exit(0);
			}
		if (new_pad & PAD_START) {
			ret = 32;
			xpos = 0;	ypos = 0;
			}
            	if (paddata & PAD_UP) {
			ret = 4;
			ypos -= 8;
			if (ypos < 0) ypos = 2040;
			}
            	if (paddata & PAD_DOWN) { 
			ret = 8;
			ypos += 8;
			if (ypos > 2040) ypos = 0;
			}
            	if (paddata & PAD_RIGHT) {
			if (lastkey != 1) {
				ret = 1;
			}	}
            	if (paddata & PAD_LEFT) {
			if (lastkey != 2) {
				ret = 2;
			}	}
		if (new_pad & PAD_SELECT) {
			ret = 16;
			mainLoop2();
			}
		if (ret) { lastkey = ret;	cnt = 0; }
		else cnt ++;
		if (cnt > 8) { lastkey = 99;	cnt = 0; }
		}
	WaitForNextVRstart(1);
	}
}

// ------------ 程式主迴圈 2 ------------
void mainLoop2(void)
{
struct padButtonStatus buttons;		// in pad.h
int	cnt;
char	ret, lastkey;

cnt = 0;	lastkey = 99;
setDisplayOfs(0, 0);
while (1) {
	SetDrawTo(nowDraw);	// 設定要畫的緩衝區號 frame buffer 0 or 1
	nowDraw ^= 1;

	g2_set_fill_color(0, 0, 0);
	g2_fill_rect(0, 0, 639, 223);		// CLS

	if (chinmode) test_chin_24(nchi);	// 中文測試
	else test_chin_16(nchi);

        ret = padRead(0, 0, &buttons); // port, slot, buttons
        if (ret != 0) {
		ret = 0;
		paddata = 0xffff ^ ((buttons.btns[0] << 8) | buttons.btns[1]);
		new_pad = paddata & ~old_pad;
		old_pad = paddata;
		if (new_pad & PAD_L1) return;	// L1 = 1, R1 = 2, L2 = 4, R2 = 8
		if (new_pad & PAD_START) {
			ret = 32;
			nchi = 0xA140;
			}
            	if (paddata & PAD_UP) {
			ret = 4;
			}
            	if (paddata & PAD_DOWN) { 
			ret = 8;
			}
            	if (paddata & PAD_RIGHT) {
			if (lastkey != 1) {
				ret = 1;
				nchi = nchi + (1 << (9 - chinmode));
			}	}
            	if (paddata & PAD_LEFT) {
			if (lastkey != 2) {
				ret = 2;
				nchi = nchi - (1 << (9 - chinmode));
			}	}
		if (new_pad & PAD_SELECT) {
			ret = 16;
			chinmode ^= 1;	// show 16x15 or 24x24
			}
		if (ret) { lastkey = ret;	cnt = 0; }
		else cnt ++;
		if (cnt > 8) { lastkey = 99;	cnt = 0; }
		}
	WaitForNextVRstart(1);
	}
}
// ------------ 填入數值 ------------
void FillMem(int addr, int len, int val)
{
int	*pi;

pi = (int *) addr;	len >>= 2;
while(len > 0) {  *pi = val;	pi ++;		len --; }
}
// ------------ 等 n/60 sec ------------
void delay(int n)
{
int	i, j;

while(n > 0) {
	for (i=0;i < 0x40000;i++) j=i+1;
	n --;
	}
}
// ------------ 印出一字串 ------------
void gputs(int x, int y, char *s)
{
int	n;

scrX = x;		scrY = y;	n = 0;
while(*s != 0) {
	gputc(*s);	s ++;
	n ++;		if (n > 255) break;	// 安全檢查
	}
}
// ------------ 印出一字 ------------
void gputc(char c)
{	// 目前只有 [0 - 0x7F] 可印
int	i, sXY, dXY;

// 檢驗是否超出範圍
scrX &= 63;	scrY &= 15;	// 640 / 12 = 53, 224 / 14 = 16
if (scrX > 53) { scrY ++;	scrX = 0; }
if (scrY > 15) scrY = 0;

// 取得圖案區的 Y 值
sXY = 0x02000000;	// 字型是上載到 (0, 512)
if ((c & 0x80) == 0) {	// 可印的字 !
	i = (c >> 4);	i = (i << 4) - (i << 1);	// i = (c >> 4) * 14;
	c = c & 15;
	sXY = sXY | (i << 16) | ((c << 4) - (c << 2));	// low(X) = (c & 15) * 12
}

// 檢驗是否超出範圍
dXY = (scrX * 12) | ((scrY * 14) << 16);
if (nowDraw) dXY += 0xE00000;		// 是下半個畫面 ( y += 224)
vramMove(sXY, dXY, 12, 14);
scrX ++;
}
// ------------ Hex 傾印 ------------
void pcdump(int adr, int len)
{
unsigned char *p, i;
char	s[96];

p = (unsigned char *) adr;
do	{
	pbuf = s;
	ptInt(adr);	*pbuf ++ = '-';		//   nprintf("\n%08X-", adr);
	for (i=0;i < 16;i ++) { ptByte(p[i]);	*pbuf ++ = ' '; }
	pbuf[0] = 0;
/*	for (i=0;i < 16;i ++) {
		pbuf[i] = p[i];
		if (p[i] < 32) pbuf[i] = '.';
		}	pbuf[17] = 0;	*/
  	nputs(s);
	len -= 16;	adr += 16;	p += 16;
	} while (len > 0);
}
// ------------ 印出 1 byte (Hex) ------------
void ptByte(unsigned char v)
{
char	c;

c = v & 15;		v = (v >> 4) & 15;
*pbuf = hex[(u8) v];	pbuf ++;
*pbuf = hex[(u8) c];	pbuf ++;
}

// ------------ 印出 4 byte (Hex) ------------
void ptInt(int v)
{
union	{
	int	i;
	unsigned char n[4];
	} iu;

iu.i = v;
ptByte(iu.n[3]);		ptByte(iu.n[2]);
ptByte(iu.n[1]);		ptByte(iu.n[0]);
}
// ------------ 印出 1 byte (Hex) ------------
void prtByte(unsigned char v)
{
char	c;

c = v & 15;		v = (v >> 4) & 15;
gputc(hex[(u8) v]);		gputc(hex[(u8) c]);
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

//---------------------------------------------------------------------------
int putChinStr16(int x, int y, char *s)
{	// 在 dot(x, y) 處印出中英文串 s
int	w; //, w2;
char	*buf;

buf = (char *) 0x430000;
w = str2ChineseBitmap16(s, buf);	
// w2 = w >> 2;	w2 = (w2 << 4) - w2;	// 即 w2 = (w >> 2) * 15;
// uploadBitMap32(buf, w | 0x0F0000, x, y, w2);
gs_load_texture(x, y, w, 15, (uint32) buf, ScrOfs, 640);
return(w);
}

//---------------------------------------------------------------------------
int putChinStr24(int x, int y, char *s)
{	// 在 dot(x, y) 處印出中英文串 s
int	w;
char	*buf;

buf = (char *) 0x430000;
w = str2ChineseBitmap24(s, buf);	
gs_load_texture(x, y, w, 24, (uint32) buf, ScrOfs, 640);
return(w);
}

// ------------ 從 IOP 讀回一段記憶體到 ------------
void readEETo(int ee, int iop, int len)
{	// iop, len 須是 4 的倍數
int	i, *eep;

eep = (int *) ee;	len &= 0x1FFFFC;	// 最多 2M - 4 bytes
for (i=0;i < (len >> 2);i ++) {  *eep = eeReadMemory(iop);  eep ++;  iop += 4;  }
}

// ------------ 休息 ------------
void go_down(void)
{
k_SleepThread();
}

// ------------ 設定要畫的緩衝區號 ------------
void SetDrawTo(int toDraw)	// 設定要畫的緩衝區號 frame buffer 0 or 1
{	// 成功, 可 swap double buffer !
// SetCrtFrameBuffer(toDraw ^ 1);	// 想看到的畫面緩衝區號 frame buffer 0 or 1
/* if (toDraw) setDrawOfs(70);	// 要畫的緩衝區要向下移, 與下一行不須要即能切換 !
else setDrawOfs(0); */
// FlushCache(0);
g2_set_active_frame(nowDraw);	// 與上式同樣的作用 !
g2_set_visible_frame(nowDraw ^ 1);
ScrOfs = (nowDraw == 0) ? 0 : 573440;	// 573440 = 640 x 224 x 4
}

// ------------ 試印中文 ------------
void test_chin_16(int chr)
{
int	x, y;
u8	c;
char	*s;

s = (char *) 0x42FF00;

strcpy(s, "中文字碼 = ");
pbuf = s + 11;		ptInt(chr);		s[19] = 0;	putChinStr16(16, 0, s);
for (y = 16;y < 96;y += 16) { // 5 lines
	for (x=0;x < 64;x += 2) {
		s[x] = (chr >> 8) & 0xFF;
		s[x + 1] = chr & 0xFF;		c = s[x + 1];
		chr ++;
		if ((c > 0x7E) && (c < 0xA0)) chr = (s[x] << 8) | 0xA0;
		}
	s[64] = 0;
	putChinStr16(64, y, s);
	}
chr = (chr & 0xFF00) | 0x40;
strcpy(s, "中文字碼 = ");
pbuf = s + 11;		ptInt(chr);		s[19] = 0;	putChinStr16(16, 96, s);
for (y = 112;y < 192;y += 16) { // 5 lines
	for (x=0;x < 64;x += 2) {
		s[x] = (chr >> 8) & 0xFF;
		s[x + 1] = chr & 0xFF;		c = s[x + 1];
		chr ++;
		if ((c > 0x7E) && (c < 0xA0)) chr = (s[x] << 8) | 0xA0;
		}
	s[64] = 0;
	putChinStr16(64, y, s);
	}
}
// ------------ 試印中文 ------------
void test_chin_24(int chr)
{
int	x, y;
u8	c;
char	*s;

s = (char *) 0x42FF00;

strcpy(s, "中文字碼 = ");
pbuf = s + 11;		ptInt(chr);		s[19] = 0;	putChinStr24(16, 0, s);
for (y = 24;y < 192;y += 24) { // 7 lines
	for (x=0;x < 48;x += 2) {
		s[x] = (chr >> 8) & 0xFF;
		s[x + 1] = chr & 0xFF;		c = s[x + 1];
		chr ++;
		if ((c > 0x7D) && (c < 0xA0)) chr = (s[x] << 8) | 0xA1;
		if (c > 0xFE) { break;	s[x] = 0; }
		}
	s[48] = 0;
	putChinStr24(32, y, s);
	}
}
// ------------ 試讀光碟 ------------
void testCD(void)
{
int	fd, ret;

nputs("------- Hello ! my CDROM ! --------");
fd = sceOpen("cdrom0:\\NAPLINK.ELF;1", O_RDONLY);
nprintf("sceOpen NAPLINK.ELF = %d", fd);
if (fd < 0) return;	// 0..15 是成功的 !

ret = sceLseek(fd, 0, 0);
nprintf("lseek returns = %X", ret);

ret = sceRead(fd, (void *) 0x440000, 0x8C00);	// 0x8B0C = 35596
nprintf("read returns = %X", ret);	// bug: 須讀滿 0x80 長度, 傳回長度是切齊 256 byte !

sceClose(fd);
pcdump(0x440000, 32);	// first 32 bytes
pcdump(0x448AEC, 32);	//  last 32 bytes
pcdump(0x44C000, 64);	//  last 32 bytes
nputs("------- bye ! my CDROM ! --------");
}
// ------------ 等待按下任意鍵 ------------
int wait_pad(void)
{
struct padButtonStatus buttons;		// in pad.h
int	ret;

do	{
	ret = padRead(0, 0, &buttons); // port, slot, buttons
	if (ret != 0) {
		ret = 0;
		paddata = 0xffff ^ ((buttons.btns[0] << 8) | buttons.btns[1]);
		new_pad = paddata & ~old_pad;
		old_pad = paddata;
		ret = new_pad;
		}
	} while (ret == 0);
return(ret);
}
