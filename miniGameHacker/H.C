/*------------------------------------------------------------------*/
/* Try to convert 8_12.FON (8x12 font for DOS BOX) to GsIMAGE !     */
/*     by CPU.SJC (c) 1999-4-28 				    */
/*------------------------------------------------------------------*/
#include <sys/types.h>
#include <file.h>
#include <graphics.h>
#include <kernel.h>
#include <libapi.h>
#include <libetc.h>
#include <libcd.h>
#include <MYGR.H>
#include <MYGR2.H>
#include <MYGH.H>
#include "GHALL.H"

#define OT_COUNT	64		// 每個表項佔 20 bytes
#define PACKETMAX	32		// 程式大概會用多少表項, < 10000
#define PACKETMAX2     (PACKETMAX * 24) // 最長的封包要 52 bytes, 此乘其平均值
#define CLUTY		496

GsOT	usrOT[2];			// 兩個 OT 表的主指標
GsOT_TAG  OTag[2][OT_COUNT];		// 指到各別 OT 的指標陣列
PACKET	GPUPacket[2][PACKETMAX2];	// GPU Packet work area

u_long	dumpmode = 0, dumploc = 0;
long	wkmode = 0, lnsz;
long	curBufNdx;			// 目前顯示的緩衝區
GRCFG	gc;		// BG use !
BGINFO	bg0;
CdlLOC	hpos;
char	sbuf[40];

void dump(void);			// 傾印記憶體內值
int edit_addr(int pad);		// 輸入 dump 位址, 按 Start 決定, X 放棄
void init_BG(void);			// 文字背景初始化設定
u_long mainPad(long pad);		// 主程式的搖桿處理
void mygrCLS(void);			// CLS
int  padCvt(u_long v);			// 轉換搖桿為連續數值
int  Redraw(int padv);			// 重畫畫面
// 設定主程式的處理函式
void uInitVideo(void);			// 第一次執行, 初始化畫面

void main(void)
{
u_long	pad=0;		// 搖桿按鈕狀態
u_short i, j, n, side;

uInitVideo();		// 第一次執行, 初始化畫面
PadInit(0);		// 啟動搖桿訊號
printf("Press select to quit !\n");
printf("The mini Game Hacker was installed at $801E0000 !\n");
init_BG();
xdump();		// 先執行一次, 以便能看到畫面

i = 1;
do	{
	grMakePkt(0, 0, (PACKET *) PKTBUF, &gc, &bg0);
	GsClearOt(0, 0, &usrOT[1-side]);	// Clear OT !
	OTag[side][0].p = (unsigned) PKTBUF;
	OTag[side][0].num = 0;
	GsDrawOt(&usrOT[side]); // Draw my defines !
	DrawSync(0);		// wait for drawing is done
	VSync(0);		// wait for V-sync
	GsSwapDispBuff();	// switch to next buffer
	side= GsGetActiveBuff();	// get Current drawing ID
	GsSortClear(0, 0, 0, &usrOT[side]);	// CLS with light blue color
	GsDrawOt(&usrOT[side]); // Do CLS
	DrawSync(0);
	pad = PadRead(0);
	i = Redraw(pad);	// 重畫畫面
} while (i);
StopPAD();		// 停止搖桿功能
// program cleanup
ResetGraph(3);		// 保留顯示環境, 不會清除畫面
printf("Exit program!\n");
asm(" li  $4, 0xbfc00000
      jr  $4  ");
}

// -------------------- 輸入 dump 位址, 按 Start 決定, X 放棄 --------------------
u_long	editaddr, lastEdKey;
char	edit_stat = 0, ed_pos;
int edit_addr(int pad)
{
u_long	i, v;
char	nshift, v1;

if (edit_stat < 1) {	// 初進入
	mygrCLS();	editaddr = 0;	ed_pos = 0;
	edit_stat = 1;	lastEdKey = 0;
	}
// 秀出現在數值
sprintf(sbuf, "Set Addr to dump : 0x%08lX", editaddr);
grPrt(1, 6, NORMATTR, sbuf, &bg0);
// 秀出游標位置
sprintf(sbuf, "||||||||");
grPrt(22, 5, NORMATTR, sbuf, &bg0);
sbuf[0] = 'v';	sbuf[1] = 0;
grPrt(22 + ed_pos, 5, NORMATTR, sbuf, &bg0);
// 檢視按鍵作出反應
i = padCvt(pad);
if (i == lastEdKey) return(1);	// 與上次按鍵同
lastEdKey = i;		if (i == 0) return(1);	// 無按鍵
nshift = 28 - (ed_pos << 2);
v = 0xFFFFFFFF ^ (15 << nshift);		// = mask
v1 = (editaddr >> nshift) & 15;	// = value (0..15)
switch(i) {
	case  1:	// up
		v1 = (v1 - 1) & 15;	
		editaddr = (editaddr & v) | (v1 << nshift);
		break;
	case  2:	// down
		v1 = (v1 + 1) & 15;	
		editaddr = (editaddr & v) | (v1 << nshift);
		break;
	case  3:	// left
		ed_pos --;
		if (ed_pos > 100) ed_pos = 7;
		break;	
	case  4:	// right
		ed_pos ++;
		if (ed_pos > 7) ed_pos = 0;
		break;	
	case  6:  wkmode = 1;	edit_stat = 0;	// 按 X 放棄
		xdump();	return(1);
	case  7:	// square
		v1 = (v1 - 5) & 15;	
		editaddr = (editaddr & v) | (v1 << nshift);
		break;
	case  8:	// O
		v1 = (v1 + 5) & 15;	
		editaddr = (editaddr & v) | (v1 << nshift);
		break;
	case 14:  dumploc = editaddr;		// 按 Start 決定
		wkmode = 1;	edit_stat = 0;	
		xdump();	return(1);
	}
return(1);
}
// -------------------- 重畫畫面 --------------------
int Redraw(int padv)
{
int	i;

i = 1;
switch(wkmode) {
	case 0: 	// 輸入 dump 位址, 按 Start 決定, X 放棄
		i = edit_addr(padv);	break;
	case 1:
		i = mainPad(padv);	   // 主程式的搖桿處理
		if (i == 0) return(0);
		if ((i & 0xFFFF) == 0) return(1);
		else xdump();
		break;
//	default:

	}
return(i);
}
// -------------------- 傾印記憶體內值 --------------------
void dump(void)
{
u_char	*p, *q;
u_short adr, i, j, k;

if ((dumploc & 0x3FFFFF) > 0x3F0000) dumploc = 0x1FFF80;
if ((dumploc & 0x3FFFFF) > 0x200000) dumploc = 0;
mygrCLS();
p = (u_char *) dumploc;
adr = (u_long) p & 0xFFFF;
if (dumpmode == 0) {
    for (j=2;j < 25;j ++) {
	sprintf(sbuf, "%04X-", adr);
	for (i=0, k=5;i < 8;i ++, k += 3) sprintf(sbuf+k, "%02X ", *p++);
	grPrt(0, j, NORMATTR, sbuf, &bg0);
	adr += 8;
	}
    lnsz = 8;
    }
else {
    lnsz = 24;
    setmem2(sbuf, 0x2020, 16);
    q = (u_char *) bg0.bgbuf + 0x8A;	// at (5, 2)
    for (j=2;j < 25;j++) {
	sprintf(sbuf, "%04X-", adr);
	grPrt(0, j, NORMATTR, sbuf, &bg0);
	for (i=0;i<24;i++) {
		*q++ = *p++;
		*q++ = NORMATTR;
		}
	q += 16;
	adr += 24;
	}
    }
sprintf(sbuf, "Now at $%08lX", dumploc);
grPrt(0, 26, NORMATTR, sbuf, &bg0);
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

// setup Color to see !
myCLUT = (long *) CLUTEMP;
setmem2(myCLUT, 0, 16); 		// clear 16 palettes
grDefCLUT(myCLUT, 0, 8, 4, 2, 0);	// 指定顏色 0 (Bkg)
grDefCLUT(myCLUT, 1, 24, 24, 24, 0);	// 指定顏色 1 (Face)
clutId = LoadClut2(myCLUT, 992, CLUTY); // 載入 16 個顏色到 (992, 496)

for (i=0;i < 16;i++) {
	gc.clut[i] = clutId;		// default color
	gc.tpage[i] = Tpage;		// 256 CharFont !
	gc.u[i] = 0;
	gc.v[i] = rc.y - 256;
	}

grDefCLUT(myCLUT, 0, 24, 24, 0, 0);	// 指定顏色 0 (Bkg)
grDefCLUT(myCLUT, 1, 0,  0, 8, 0);	// 指定顏色 1 (Face)
clutId = LoadClut2(myCLUT, 992, CLUTY+1); // 載入 16 個顏色到 (992, 497)
gc.clut[5] = clutId;			// 指定第 5 號調色盤 (反相文字, 游標)

grDefCLUT(myCLUT, 0, 2, 8, 4, 0);	// 指定顏色 0 (Bkg)
grDefCLUT(myCLUT, 1, 16, 24, 24, 0);	// 指定顏色 1 (Face)
clutId = LoadClut2(myCLUT, 992, CLUTY+2); // 載入 16 個顏色到 (256, 498)
gc.clut[6] = clutId;			// 指定第 6 號調色盤 (線框盒)

grDefCLUT(myCLUT, 0, 2, 8, 4, 0);	// 指定顏色 0 (Bkg)
grDefCLUT(myCLUT, 1, 24, 24, 16, 0);	// 指定顏色 1 (Face)
clutId = LoadClut2(myCLUT, 992, CLUTY+3); // 載入 16 個顏色到 (992, 499)
gc.clut[7] = clutId;			// 指定第 7 號調色盤 (數值盒)

// setting my BG !
p = (u_long *) TEXTBUF;
bg0.bgbuf = p;
bg0.xlen = 32;
bg0.ylen = 30;
mygrCLS();
}

// -------------------- 主程式的搖桿處理 --------------------
u_long mainPad(long pad)
{
u_short i, j, n;

i = 1;
j = padCvt(pad);
if (j > 0) n = 1;
switch(j) {
	case  1: dumploc -= lnsz;  VSync(2);  break;	// Up
	case  2: dumploc += lnsz;  VSync(2);  break;	// Down
	case  3: dumploc -= (lnsz << 4);  break;  // Left
	case  4: dumploc += (lnsz << 4);  break;  // Right
	case  5: dumploc -= (lnsz << 8);  break;  // Triangle
	case  6: dumploc += (lnsz << 8);  break;  // X
	case  7: dumploc -= (lnsz << 5);  break;  // Square
	case  8: dumploc += (lnsz << 5);  break;  // O
	case  9: dumploc -= (lnsz << 9);  break;  // L1
	case 10: dumploc += (lnsz << 9);  break;  // L2
//	case 11: showFiles();  break;	// R1
	case 12: dumpmode ^= 1;  VSync(15);  break;	// R2
	case 13: i=0;  n=0;	break;		// quit with Select key !
//	case 14: editMem(dumploc);  n=0;  break;  // read 1 Sector to dump !
	default: n=0;  break;
	}
return((i << 16) | n);
}

// -------------------- Clear Screen --------------------
void mygrCLS(void)
{
setmem2(bg0.bgbuf, (NORMATTR << 8) | 0x20, 960);	// CLS
}
// -------------------- 轉換搖桿為連續數值 --------------------
char PadTranslate[16] = { 10, 12, 9, 11, 5, 8, 6, 7, 13, 0, 0, 14, 1, 4, 2, 3 };
int padCvt(u_long v)
{
int i, j;

j = 0;
for (i=0;i < 16;i++) {
	if (v & 1) {
		j = PadTranslate[i];
		i = 16;
		}
	v >>= 1;
	}
return(j);
}

// -------------------- 預備繪圖 --------------------
void prepareToShow(void)
{
// 取得目前顯示中緩衝區編號
curBufNdx = GsGetActiveBuff();

// 設定 GPU 繪圖原始碼位址指標
GsSetWorkBase((PACKET*) GPUPacket[curBufNdx]);

// 清除目前 OT 表
GsClearOt(0, 0, &usrOT[curBufNdx]);
}

// -------------------- 第一次執行, 初始化畫面 --------------------
void uInitVideo(void)
{

// 初始化螢幕為 NTSC mode
SetVideoMode(MODE_NTSC);

// 畫面採用 256 x 240
GsInitGraph(256 ,240, 4, 0, 0); 	// use GPUOFS, 非交錯, 色彩 16-bit
GsDefDispBuff(0, 0, 0, 240);		// 定義兩個緩衝區的左上角座標
SetDispMask(0); 			// 隱藏顯示

// 初始化 Ordering Table
usrOT[0].length = OT_COUNT;		// 內含 OT 表項個數
usrOT[1].length = OT_COUNT;
usrOT[0].org = OTag[0]; 		// 指到各別 OT 的指標
usrOT[1].org = OTag[1];
GsClearOt(0,0,&usrOT[0]);		// 設定 2 OT, Z value = 0
GsClearOt(0,0,&usrOT[1]);

printf("Video initialized OK !\n");
}
