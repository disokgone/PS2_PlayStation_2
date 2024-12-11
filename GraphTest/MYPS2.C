#include <stdio.h>
#include <tamtypes.h>
#include <kernel.h>
#include <sifrpc.h>
#include <malloc.h>
#include <string.h>
#include <mylibk.h>
/* 其它的 .H 檔放在 C:\PS2DEV\GCC\MYINC\FROM_TUT\ 之下 */
#include <g2.h>
#include <gs.h>
#include "nuputs.h"
#include "GR_1.H"
#include "hw.h"
#include "pad.h"
#include "loadmodule.h"

#if defined(ROM_PADMAN) && defined(NEW_PADMAN)
#error Only one of ROM_PADMAN & NEW_PADMAN should be defined!
#endif

#if !defined(ROM_PADMAN) && !defined(NEW_PADMAN)
#error ROM_PADMAN or NEW_PADMAN must be defined!
#endif

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

/*
 * Macros
 */
#define WAIT_PAD_READY(p, s) {while(padGetState((p),(s)) != PAD_STATE_STABLE) WaitForNextVRstart(1); }

void delay(int n);		// 等 n/60 sec
void do_pad_init(void);		// joy pad 初始化
int  dump(int adr);
void FillMem(int addr, int len, int val);	// 填入數值
void go_down(void);		// = k_SleepThread()
void gputc(char c);		// 印出一字
void gputs(int x, int y, char *s);	// 印出一字串
int  initializePad(int port, int slot);	// 初始化搖桿
void init_Screen(void);		// 基本的畫面初始
void loadfont(void);		// 上傳我的字形
void loadfontA(void);		// 上傳我的字形 to (0, 448)
void loadModules(void);		// 載入程式 (.irx)
void mainLoop(void);		// 程式主迴圈
void pcdump(int adr, int len);	// hex dump to PC
void prtByte(unsigned char v);
void prtInt(int v);
void ptByte(unsigned char v);
void ptInt(int v);
void readEETo(int ee, int iop, int len);	// len 須是 4 的倍數
void SetDrawTo(int toDraw);	// 設定要畫的緩衝區號 frame buffer 0 or 1

// extern int pFont1;		// 放 32-bit [R,G,B,A] 的點陣陣列
// int pFont1 = 0x140000;

// pad_dma_buf is provided by the user, one buf for each pad
// contains the pad's current state
static char padBuf[256] __attribute__((aligned(64)));
static char actAlign[6];
static int actuators;

int maxx, maxy;
int nowDraw;		// 現在正要繪圖的 frame buffer 編號 (0 or 1)
int *pFont1;		// 256 * 30 的 32-bit 點陣字元 (alpha = 0..0x7F)
int dumpAddr, dumpLen, TimeSlic;
int scrX, scrY, fd;
int *pi, xofs, yofs;
u32 paddata;
u32 old_pad = 0;
u32 new_pad;
char *pbuf;		// 印字用的暫時指標
char usable[34] = " @#$%:!?,<=>+-*/0123456789ABCDEF";	// 可印出的字元
char hex[18] = "0123456789ABCDEF";	// 十六進位傾印用的字元


int _main(void)
{
init_Screen();		// 基本的畫面初始

sif_rpc_init(0);	// for pad, naplink...
install_VRstart_handler();	// 垂直回掃管理
iHookEERW();		// 可自由讀寫 EE 主記憶體 !
nputs("Go ! \n");	// !! 必須先暖身, 否則 nprintf() 會當掉 !! (原因不明)

do_pad_init();		// joy pad 初始化

// 讀取字型到 pFont1 !
pFont1 = (int *) 0x420000;
fd = fio_open("host:d:\\psx2\\ps2_03\\s16ch.bin", O_RDWR);
fio_read(fd, pFont1, 30720);
fio_close(fd);

loadfontA();		// 上傳字形, 成功 !
scrX = scrY = 0;

// 設定傾印位址及長度, 等待時間
dumpAddr = DefDumpAddr;
dumpLen = DefDumpLen;
TimeSlic = 4;

nprintf("Go : %d, pFont1 = %X\n", 66, &pFont1);

	mainLoop();	// 程式主迴圈

nputs("Bye ! \n");
go_down();
return(0);
}

// ------------ init pad ------------
void do_pad_init(void)
{
int i, port, slot, ret;

loadModules();		padInit(0);
port = 0;		slot = 0;
nprintf("PortMax: %d\n", padGetPortMax());	// PortMax: 2
nprintf("SlotMax: %d\n", padGetSlotMax(port));	// SlotMax: 1
if ((ret = padPortOpen(0, 0, padBuf)) == 0) {	// padBuf in pad.c
	nprintf("padOpenPort failed: %d\n", ret);
	k_SleepThread();
  }
    
if (!initializePad(0, 0)) {
	nprintf("pad initalization failed !\n");
	k_SleepThread();
  }
WaitForNextVRstart(1);
i = 0;
while(padGetState(port, slot) != PAD_STATE_STABLE) {
	if (i==0) {
		nprintf("Please wait, pad state != OK\n");
		i = 1;	}
	WaitForNextVRstart(1); // Perhaps a bit to long ;)
  }
if (i==1) nprintf("Pad: OK !\n");
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
// long	l;
int	i, xpos, ypos;
char	ret;

xpos = 0;	ypos = 0;
// gs_load_texture(640, 0, 256, 240, 0x300000, 640, 640);
for (i=0;i < 9000;i ++) {
	WaitForNextVRstart(1);
	SetDrawTo(nowDraw);	// 設定要畫的緩衝區號 frame buffer 0 or 1
	nowDraw ^= 1;
	g2_set_color(255, 255, 255);
	g2_line(0, 0, 639, 223);
//	loadfontA();		// 上傳字形, 成功 !
//	FlushCache(0);
//	g2_put_image(0, 0, 256, 30, (int *) 0x420000);	// hover_w, hover_h, hover
//	vramMove(0x1C00000, 0xA00100, 256, 30);
//	loadfont();

	dumpAddr = dump((int) dumpAddr);
	dumpLen -= 64;		
	gputs(32, 160, "Frame :");	gputc(0x30 + nowDraw);

// setDisplayOfs(0, ypos);		// 檢查是否有畫到兩個畫面時使用
/*	l = *((long *) 0x12000090);	// 固定印出 0x0..05515606C
	prtInt(l >> 32);	prtInt(l);	*/
	// read pad !
        ret = padRead(0, 0, &buttons); // port, slot, buttons
        if (ret != 0) {
		paddata = 0xffff ^ ((buttons.btns[0] << 8) | buttons.btns[1]);
		new_pad = paddata & ~old_pad;
		old_pad = paddata;
		if (new_pad & PAD_START) {
			xpos = 0;	ypos = 0;
			}
            	if (paddata & PAD_UP) {
			ypos -= 8;
			if (ypos < 0) ypos = 2040;
			}
            	if (paddata & PAD_DOWN) { 
			ypos += 8;
			if (ypos > 2040) ypos = 0;
			}
            	if (paddata & PAD_RIGHT) {
			ypos += 64;
			if (ypos > 2040) ypos = 0;
			}
            	if (paddata & PAD_LEFT) {
			ypos -= 64;
			if (xpos < 0) ypos = 2040;
			}
		if (new_pad & PAD_SELECT) {
			nprintf("X = %d, Y = %d\n", xpos, ypos);
			}
		}
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
{	// 目前只有 '0-F', ' :!?,<=>+-*/' 可印
int	i, sXY, dXY;

// 檢驗是否超出範圍
scrX &= 31;	scrY &= 15;	// 640 / 16 = 40, 224 / 16 = 14
if (scrX > 39) { scrY ++;	scrX = BeginX; }
if (scrY > 13) scrY = BeginY;

// 是否有此字
for (i=0;i < 32;i ++) if (c == usable[i]) break;

// 取得圖案區的 Y 值 (0-F = 0, 10-1F = 15)
if (i < 32) {
	sXY = (i >> 4) ? 0x1CF0000 : 0x1C00000;		// Y = 0x1C0 = 448
	sXY |= ((i & 15) << 4);		}
else  sXY = 0x1C00000;		// 超出範圍的字 !

// 檢驗是否超出範圍
dXY = (scrX * 16) | ((scrY * 15) << 16);
if (nowDraw) dXY += 0xE00000;		// 是下半個畫面 ( y += 224)
vramMove(sXY, dXY, 16, 15);
scrX ++;
}
// ------------ 上傳我的字形 ------------
void loadfont(void)
{
uploadBitMap32(pFont1, sizeMyFont, 320, 184, 0x780);	// 放到畫面 (320, 184) 備用
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
}

// ------------ 載入程式 ------------
void loadModules(void)
{
int ret;

if ((ret =_lf_bind(0)) != 0) nprintf("_lf_bind: %d\n", ret);

// 以下為顯示的訊息 ...
// loadmodule: fname rom0:SIO2MAN args 0 arg
#ifdef ROM_PADMAN
    ret = _sifLoadModule("rom0:SIO2MAN", 0, NULL, 0);
#else
    ret = _sifLoadModule("rom0:XSIO2MAN", 0, NULL, 0);
#endif
    if (ret == 1) {	// 0 = OK, 1 = Failed
        nprintf("sifLoadModule sio failed: %d\n", ret);
        k_SleepThread();
    }    
// loadmodule: id 27, ret 0

// loadmodule: fname rom0:PADMAN args 0 arg
#ifdef ROM_PADMAN
    ret = _sifLoadModule("rom0:PADMAN", 0, NULL, 0);
#else
    ret = _sifLoadModule("rom0:XPADMAN", 0, NULL, 0);
#endif 
    if (ret == 1) {	// 0 = OK, 1 = Failed
        nprintf("sifLoadModule pad failed: %d\n", ret);
        k_SleepThread();
    }
// Pad driver. (99/11/22)
// loadmodule: id 28, ret 0
}

// ------------ 初始化搖桿 ------------
int initializePad(int port, int slot)
{
int ret;

    while((ret=padGetState(port, slot)) != PAD_STATE_STABLE) {
	if(ret==0) { // No pad connected!
            nprintf("Pad(%d, %d) is disconnected\n", port, slot);
            return 0;
	}
	WaitForNextVRstart(1);
    }

/* InfoMode does not work with rom0:padman */
#ifndef ROM_PADMAN
    nprintf("padInfoMode: %d\n", padInfoMode(port, slot, PAD_MODECURID, 0));

    // If ExId == 0x07 => This is a dual shock controller
    if (padInfoMode(port, slot, PAD_MODECUREXID, 0) == 0) {
        nprintf("This is NOT a dual shock controller\n");
        nprintf("Did you forget to define RAM_PADMAN perhaps?\n");
        return 1;
    }
#endif
    nprintf("Enabling dual shock functions\n");

    nprintf("setMainMode dualshock (locked): %d\n", 
               padSetMainMode(port, slot, 
                              PAD_MMODE_DUALSHOCK, PAD_MMODE_LOCK));
	// 結果顯示 setMainMode dualshock (locked): 1
    WAIT_PAD_READY(port, slot);
    nprintf("infoPressMode: %d\n", padInfoPressMode(port, slot));
	// 結果顯示 infoPressMode: 0
    WAIT_PAD_READY(port, slot);        
    nprintf("enterPressMode: %d\n", padEnterPressMode(port, slot));
	// 結果顯示 enterPressMode: 0
    WAIT_PAD_READY(port, slot);
    actuators = padInfoAct(port, slot, -1, 0);
    nprintf("# of actuators: %d\n",actuators);
	// 結果顯示 # of actuators: 2
    if (actuators != 0) {
        actAlign[0] = 0;   // Enable small engine
        actAlign[1] = 1;   // Enable big engine
        actAlign[2] = 0xff;
        actAlign[3] = 0xff;
        actAlign[4] = 0xff;
        actAlign[5] = 0xff;

        WAIT_PAD_READY(port, slot);
        nprintf("padSetActAlign: %d\n", 
                   padSetActAlign(port, slot, actAlign));
    }	// 結果顯示 padSetActAlign: 1
    else {
        nprintf("Did not find any actuators.\n");
    }

    WAIT_PAD_READY(port, slot);

return 1;
}

// ------------ 無用碼 ------------
void notUsed(void)
{
// if OK, read here about 1 MB, R/W every 4096 bytes !
dumpAddr = 0xA0000000;		dumpLen = 0x40000;
fd = fio_open("host:c:\\ps2000.bin", O_CREAT | O_WRONLY);
gputs(1,1,"@@");
while (dumpLen) {
	gputs(3,1,"# :");	prtInt(dumpAddr);
	readEETo(0x420000, dumpAddr, 4096);	// 從 EE 讀 128 bytes 到 $420000
	dumpAddr += 4096;	dumpLen -= 4096;
	fio_write(fd, pFont1, 4096);
	}
fio_close(fd);
gputs(6,1,"@@##");	// ok !
}
