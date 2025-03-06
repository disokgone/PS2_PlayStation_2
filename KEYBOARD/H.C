/*------------------------------------------------------------------*/
/* Show a 256x240 BMP to Screen 				    */
/*     by CPU.SJC (c) 1999-7-20 				    */
/*------------------------------------------------------------------*/
#include <ctype.h>
#include <sys/types.h>
#include <file.h>
#include <graphics.h>
#include <kernel.h>
#include <libetc.h>
#include <libsio.h>
#include <DEBUG.H>
#include <MYGR.H>
#include <MYGR2.H>
#include "SIOKBD.H"

#define OT_COUNT	2048		// 每個表項佔 20 bytes
#define PACKETMAX	1024		// 程式大概會用多少表項, < 10000
#define PACKETMAX2     (PACKETMAX * 24) // 最長的封包要 52 bytes, 此乘其平均值
#define NORMATTR	0x10
#define FONT256 0x40000 	// for 8x8.FON
#define TEXTBUF 0x80000 	// SCREEN BUFFER (48x30) start at here !
#define PKTBUF	0xA0000 	// PACKET BUFFER (48x30x20) start at here !
#define TEMPBUFF 0xC0000	// For expanding bitmap !
#define SCRNSIZE	1440	// (384 / 8) * (240 / 8)

GRCFG	gc;		// BG use !
BGINFO	bg0;
GsOT	usrOT[2];			// 兩個 OT 表的主指標
GsOT_TAG  OTag[2][OT_COUNT];		// 指到各別 OT 的指標陣列
PACKET	GPUPacket[2][PACKETMAX2];	// GPU Packet work area
int	curBufNdx;			// 目前顯示的緩衝區
u_short myClut[4]= { 0x8000, 0x7E73, 0x2F3F, 0x1C9C };
PACKET *ptail;

char	sbuf[64];
extern	u_char y;

void clrline(long y);
void doDump(u_long addr, u_long len);	// 執行傾印
char *gotoSpace(char *pstr);		// 找到空白或 tab 鍵
void init_BG(void);
u_short GetKbdScan(void);		// get scan code back !
void KbdClear(void);			// 清除鍵盤緩衝區
void KbdInput(void);			// 收集輸入的字串
void mainFuncKey(void); 		// 主程式的特殊功能鍵分析
void mainSetupKbd(void);		// 設置主程式鍵盤處理函式
void mainParseKbd(void);		// 主程式的命令分析
long myReadFile2(char *fn, long addr, u_long len);	// 讀取某段長度到記憶體 (MYCD.C)
void prepareToShow(void);
char *readHex(char *ps, long *val);	// 讀取 16 進位數值
void scrollupNline(u_short n);		// 文字上捲 N 行
char *skipSpace(char *pstr);		// 跳過空白或 tab 鍵
void uInitVideo(void);			// 第一次執行, 初始化畫面

void main(void)
{
u_long	pad;		// 搖桿按鈕狀態
RECT	rc;
int	i, side;

StartSIOKBD();		// 啟動鍵盤連線功能
flushkbd();
uInitVideo();		// 第一次執行, 初始化畫面
init_BG();
printf("Press select to quit !\n");
myReadFile2("\\8X8.FON;1", 0x40000, 0x800);     // 8x8 FONT
printf("usrOT=%lX, OTag=%lX, Pkt=%lX\n", usrOT, OTag, GPUPacket);
i = 1;
mainSetupKbd(); 	// 設置主程式鍵盤處理函式
KbdClear();		// 清除鍵盤緩衝區, 避免誤動作
y = 2;
do	{
	prepareToShow();
	side = GsGetActiveBuff();
	GsClearOt(0, 0, &usrOT[side]);
	ptail = grMakePkt(0, 0, (PACKET *) PKTBUF, &gc, &bg0);
	AddPrims(OTag[side], (void *) PKTBUF, ptail);
	GsDrawOt(&usrOT[side]); // Draw my TEXT background !
	DrawSync(0);		// wait for drawing is done
	VSync(0);		// wait for V-sync
	side = 1 - side;
	GsSwapDispBuff();	// switch to next buffer
	pad = PadRead(0);
	processKbd();	// 處理傳來的鍵碼值, 可隨時呼叫以免 SIO 傳輸區佔滿
	KbdInput();	// 收集輸入的字串
	if (pad & Pad1Select) i = 0;	// quit with Select key !
} while (i);
StopPAD(0);		// 停止搖桿功能
StopSIOKBD();		// 停止鍵盤連線功能
// program cleanup
ResetGraph(3);		// 保留顯示環境, 不會清除畫面
printf("Exit program!\n");
asm(" li  $4, 0xbfc00000
      jr  $4  ");
}

// -------------------- 第一次執行, 初始化畫面 --------------------
void uInitVideo(void)
{

// 初始化螢幕為 NTSC mode
SetVideoMode(MODE_NTSC);
ResetGraph(0);				// 完整 Reset (Drawing & Display Env.)

// 畫面採用 384 x 240 (左右各 8 點被當作預備區)
GsInitGraph(384, 240, 4, 0, 0); 	// use GPUOFS, 非交錯, 色彩 16-bit
GsDefDispBuff(0, 0, 0, 240);		// 定義兩個緩衝區的左上角座標
SetDispMask(0); 			// 隱藏顯示

// 初始化 Ordering Table
usrOT[0].length = OT_COUNT;		// 內含 OT 表項個數
usrOT[1].length = OT_COUNT;
usrOT[0].org = OTag[0]; 		// 指到各別 OT 的指標
usrOT[1].org = OTag[1];
GsClearOt(0,0,&usrOT[0]);		// 設定 2 OT, Z value = 0
GsClearOt(0,0,&usrOT[1]);

// 啟動搖桿訊號
PadInit(0);

printf("Video initialized OK !\n");
}

// -------------------- 預備繪圖 --------------------
void prepareToShow(void)
{
int	side;

// 取得目前顯示中緩衝區編號
side = GsGetActiveBuff();

// 設定 GPU 繪圖原始碼位址指標
GsSetWorkBase((PACKET*) PKTBUF);

// 清除目前 OT 表
GsClearOt(0, 0, &usrOT[side]);
}

// -------------------- 文字背景初始化設定 --------------------
void init_BG(void)
{
u_long	*p;
long	*myCLUT, clutId;
short	i, Tpage;
RECT	rc;

// Convert 256 characters
p = (u_long *) TEMPBUFF;	// temp buffer
grLoadFnt1(960, 384, (u_long *) FONT256, (u_long *) p);
rc.x = 960;	rc.y = 384;	rc.w = 32;	rc.h = 128;
LoadImage(&rc, p);
Tpage = GetTPage(0, 0, 960, 384);	// 256 CharFont !
printf("Tpage = %X\n", Tpage);
clutId = LoadClut((long *) myClut, 768, 0);	// load palette to VRAM

// Clear Graphic configuration
for (i=0;i < 16;i++) {
	gc.clut[i] = 0; 	// default color
	gc.tpage[i] = 0;	// 256 CharFont !
	gc.u[i] = 0;
	gc.v[i] = 0;
	}
gc.clut[0] = clutId;		// Normal ASCII Color
gc.tpage[1] = Tpage;		// Normal ASCII Text
gc.v[1] = 128;

// setting my BG !
p = (u_long *) TEXTBUF;
bg0.bgbuf = p;
bg0.xlen = 48;		// 48 = 384 / 8
bg0.ylen = 30;

setmem2(p, 0x1020, SCRNSIZE);
}

