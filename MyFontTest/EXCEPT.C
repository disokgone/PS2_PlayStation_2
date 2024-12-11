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
#include "GR_1.H"
#include "hw.h"
#include "pad.h"
#include "nuputs.h"

extern	void ExceptHandlerA(void);	// in Except2.S
extern	void init_Screen(void);		// 基本的畫面初始
extern	void gputs(int x, int y, char *s);	// 印出一字串
extern	int wait_pad(void);		// 等待按下任意鍵
extern	void *pFont;
extern	int nowDraw, maxx, maxy;
void getCP0(int *regs);			// 取得 CPU 本身的 cp0 暫存器值

void cls(void);		// 清除畫面
void ExceptHandler(int status, int cause, int epc, int badVA, int regList);	// 我的例外處理程式
int installMyExceptionHandler(void);	// 安裝我的例外處理程式
void SetupMyScreen(void);		// 設定畫面與字型
void showCP0(void);			// 顯示 CPU 本身的 cp0 暫存器值
void showGPR(int status, int cause, int epc, int badVA, int regList);	// 顯示一般暫存器值

static int xp[4] = { 0, 13, 26, 39 };
static char *cp0Name[32] = { "index", "random", "EntryLo0", "EntryLo1", "context", "pagemask",
		"wired", NULL, "BadVAddr", "timerCount", "EntryHi", "TimerCompare", "Status",
		"cause", "EPC", "PRid", "config", "LLAddr", NULL, NULL, "XContext",
 		NULL, NULL, NULL, "resv-24", "resv-25", "ECC", "cache Err",
		"TagLo", "TagHi", "ErrorEPC", "resv-31" };
static char *regName[32] = { "zero", "at", "v0", "v1", "a0", "a1", "a2", "a3", "t0", "t1",
		"t2", "t3", "t4", "t5", "t6", "t7", "s0", "s1", "s2", "s3", "s4", "s5",
		"s6", "s7", "t8", "t9", "k0", "k1", "gp", "sp", "fp", "ra" };
static char *ExceptErr[13] = { "Interrupt", "TLB Modification", "TLB (load)", "TLB (store)",
		"Address Error (load)", "Address Error (store)", "Bus Error (instruction)",
		"Bus Error (data)", "Syscall", "Break", "Reserved instruction",
		"Coprocessor Unusable", "Arithmetic overflow" };
static char use32bit = 1;	// 只顯示 32-bit 的一般暫存器值
char	*s;

// ------------ 清除畫面 ------------
void cls(void)
{
g2_set_fill_color(0, 0, 0);
g2_fill_rect(0, 0, maxx, maxy);
}
// ------------ 安裝我的例外處理程式 ------------
int installMyExceptionHandler(void)
{
int	eh_tbl, handler, v;

// 取得例外處理程序的 jump table !
iHookEERW();		// 可自由讀寫 EE 主記憶體 !
FlushCache(0);
v = eeReadMemory(0x8000000C);	// 在 $8000000C 應是 0x3c1a8001 = lui $k0, 0x8001
if ((v >> 16) != 0x3C1A) return(1);	// 與我所見不同, 勿亂改, 失敗返回 !
eh_tbl = v << 16;	// = 0x80010000
v = eeReadMemory(0x80000018);	// 在 $80000018 應是 0x8F5A4980 = lw $k0, 0x4980($k0)
if (((v >> 16) & 0xFFFF) != 0x8F5A) return(1);	// 與我所見不同, 勿亂改, 失敗返回 !
eh_tbl += (v & 0x7FFF);		// = 0x80014980
if (v & 0x8000) eh_tbl -= 0x8000;	// 為負值 !

// 在此 jump table 的第 1-7 項及第 10-13 項須改成我的處理位址
handler = (int) ExceptHandlerA;
for (v= 1;v <  8;v ++) eeWriteMemory(eh_tbl + (v << 2), handler);
for (v=10;v < 14;v ++) eeWriteMemory(eh_tbl + (v << 2), handler);
return(0);	// 安裝成功 !
}
// ------------ 我的例外處理程式 ------------
void ExceptHandler(int status, int cause, int epc, int badVA, int regList)
{	// 例外發生後, 由 Except2.S 跳至此 !
int	pad, thread_id;

thread_id = *((int *) 0xA5AA0);		// !! Naplink 所啟動的執行緒 (其值如 0x30)
s = (char *) 0x446200;	// 和堆疊共用 $80016200 - $80016600
nprintf("thread_id = %X", thread_id);
// TerminateThread(thread_id);
// DeleteThread(thread_id);
SetupMyScreen();	// 設定畫面與字型
FlushCache(0);
// gs.pmode = 0xFF61;
// FlushCache(0);
pad = PAD_CROSS;
while(1) {
//	if (pad & PAD_START) Exit(1);
	if (pad & PAD_START) break;
	if (pad & PAD_SELECT) { use32bit ^= 1;  pad = PAD_CROSS; }
	cls();
	sprintf(s, "pad = %d", pad);
	gputs(1, 13, s);
	if (pad & PAD_CIRCLE) showCP0();
	if (pad & PAD_CROSS) showGPR(status, cause, epc, badVA, regList);
	
	// 注意 ! 最後一個 gputs() 的字元會印不出來 !
	gputs(12, 14, "Press any key ... ");
	pad = wait_pad();		// 等待按下任意鍵
	}
}
// ------------ 顯示 CPU 本身的 cp0 暫存器值 ------------
void showCP0(void)
{
int	i, cpr[32], x, y;

gputs(0, 0, "CP0 registers ---");
getCP0(cpr);		x = 0;	y = 1;
for (i=0;i < 32;i ++) {
	if (cp0Name[i] == NULL) continue;
	sprintf(s, "%s: %08X", cp0Name[i], cpr[i]);
	gputs(x, y, s);		x += 26;
	if (x > 26) { x = 0;  y ++; }
	}
}
// ------------ 顯示一般暫存器值 ------------
void showGPR(int status, int cause, int epc, int badVA, int regList)
{
int	i, j, v1, v2, y;

sprintf(s, "Exception : %s", ExceptErr[(cause & 0x7C) >> 2]);
gputs(0, 0, s);
sprintf(s, "bad VAddr: %08X", badVA);
gputs(0, 1, s);
sprintf(s, "Status: %08X", status);
gputs(26, 1, s);
sprintf(s, "EPC = %08X", epc);
gputs(0, 2, s);
// 印出 32 個一般暫存器值
y = 3;
if (use32bit) {
	for (i=1;i < 32;i ++) {
		v1 = eeReadMemory((0x80000000 | regList) + (i << 4));
		sprintf(s, "%s: %08X", regName[i], v1);
		gputs(xp[i & 3], y, s);
		if ((i & 3) == 3) y ++;
		}
	}
else	{
    for (i=1;i < 22;i ++) {
	j = i << 2;
	v1 = eeReadMemory((0x80000000 | regList) + (j << 2));
	v2 = eeReadMemory((0x80000000 | regList) + (j << 2) + 4);
	sprintf(s, "%s: %08X%08X", regName[i], v2, v1);
	gputs((i & 1) ? 25 : 0, y, s);
	if (i & 1) y ++;
	}
    gputs(12, 14, "Press any key ... ");
    wait_pad();		y = 0;		cls();
    for (i=8;i < 32;i ++) {
	j = i << 2;
	v1 = eeReadMemory((0x80000000 | regList) + (j << 2));
	v2 = eeReadMemory((0x80000000 | regList) + (j << 2) + 4);
	sprintf(s, "%s: %08X%08X", regName[i], v2, v1);
	gputs((i & 1) ? 25 : 0, y, s);
	if (i & 1) y ++;
	}
    }
}
// ------------ 設定畫面與字型 ------------
void SetupMyScreen(void)
{
init_Screen();		// 基本的畫面初始 (640 * 224)
g2_set_active_frame(0);
gs_load_texture(0, 512, 192, 112, (uint32) pFont, 0, 640);
nowDraw = 0;
}

