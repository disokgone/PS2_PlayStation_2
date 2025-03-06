#include <sys/types.h>
#include <ctype.h>
#include <graphics.h>
#include <kernel.h>
#include <stdlib.h>
#include <MYGR.H>
#include <MYGR2.H>
#include "PSDebug.h"

#define NHELP	16
#define LASTKEYS	0x70000 	// 放之前打的命令字串

extern	u_char	curx, cury, y, ESC_exit;
extern	char	kbuf[];
extern	u_short FunKey;

u_char	*psrc, *pend, srh[32];
u_short nKcmd = 0, nEdCmd, srhlen, kofs[22];
char	*helps[NHELP] = { "? - This Help",
		"d [begin dump address] [bytes to be dumped]",
		"e [input address] [some heximal bytes]",
		"f [fill addr] [len] [some bytes to fill]",
		"f [fill addr] [len]  \'string to fill\'",
		"g [start address] = [stop address]",
		"p [step line count]",
		"r [regName] [newValue]",
		"rn (n = 0 .. 3 to view Coprocessor)",
		"s [search addr] [len] [bytes or string]",
		"t [trace line count]",
		"u [disAsm address] [line count]",
		"F1 - disAsm register name: Alias or Decimal",
		"F2 - disAsm final Dump: Heximal or Character",
		"F9 - list commands just typed (max 21)",
		"F10- Goto line command number" };

void clrline(long y);			// 清除一行螢幕 (deb.c)
void cmdGoesDown(void); 		// 讀出下一個命令行字串
void cmdGoesUp(void);			// 讀出上一個命令行字串
void do_Search(u_short nlen, u_char *psrc, u_long srclen, u_char *srhdta);
// 搜尋功能
void gotoXcmd(void);			// 跳至某個先前打的命令行字串
void gotoXFn(void);			// 特殊功能鍵處理程式
char gotoXkOK(void);			// 鍵盤輸入處理程式
void KbdClear(void);			// 清除鍵盤緩衝區 (deb.c)
void mainSetupKbd(void);		// 設置主程式鍵盤處理函式 (deb.c)
void printHelp(void);			// 印出求助訊息
void prtoutStr(char *str);		// 印出一行並換行 (Regwork.c)
void reshowKbuf(void);			// 重顯示此字串
void scrollupNline(u_short n);		// 文字上捲 N 行 (deb.c)
void showCmds(void);			// 列出先前打的命令行字串
char *skipSpace(char *pstr);		// 跳過空白或 tab 鍵 (deb.c)
void storeThisLine(void);		// 將 kbuf[128] 的字串保存起來
char (* KbdInputOk)(void);		// 鍵盤輸入一行後的處理程式 (deb.c)
void (* KbdSpcialFn)(void);		// 呼叫特殊功能鍵分析 (deb.c)

// ----------------- 讀出下一個命令行字串 (Help.C) -----------------
void cmdGoesDown(void)
{
u_short i, j;
do	{
	clrline(cury);
	cury --;
	} while (cury == y);
KbdClear();	// 清除鍵盤緩衝區
nEdCmd ++;
if (nEdCmd >= nKcmd) { nEdCmd = nKcmd;	 return; }
i = kofs[nEdCmd];
strcpy(kbuf+1, (char *) (LASTKEYS+i));	// 取得以前輸入的字串
kbuf[0] = strlen(kbuf+1);	// 輸入字串的長度
reshowKbuf();			// 重顯示此字串
}
// ----------------- 讀出上一個命令行字串 -----------------
void cmdGoesUp(void)
{
u_short i, j;
do	{
	clrline(cury);
	cury --;
	} while (cury == y);
KbdClear();	// 清除鍵盤緩衝區
if (nEdCmd > 20) nEdCmd = 21;
nEdCmd --;
if (nEdCmd > 256) nEdCmd = 0;
i = kofs[nEdCmd];
strcpy(kbuf+1, (char *) (LASTKEYS+i));	// 取得以前輸入的字串
kbuf[0] = strlen(kbuf+1);	// 輸入字串的長度
reshowKbuf();			// 重顯示此字串
}
// ----------------- 搜尋功能 -----------------
void do_Search(u_short nlen, u_char *pb, u_long srclen, u_char *fdta)
{
u_char	c1, n;

if (nlen != 0) {	// 若 nlen == 0 則沿用舊值
	psrc = pb;
	pend = psrc + srclen;
	setmem2(srh, 0, 16);
	bcopy(fdta, srh, nlen); 	// 拷貝欲搜尋資料
	}
c1 = srh[0];
n = 0;
while (psrc <= pend) {
	if (*psrc == c1) if (bcmp(psrc, srh, nlen) == 0) {
		sprintf(sbuf, "%08lX", psrc);
		prtoutStr(sbuf);
		n ++;
		if (n == 21) break;
		}
	psrc ++;
	}
}
// ----------------- 跳至某個先前打的命令行字串 -----------------
void gotoXcmd(void)
{
KbdInputOk = gotoXkOK;	// 鍵盤輸入一行後的處理程式
KbdSpcialFn = gotoXFn;	// 呼叫特殊功能鍵分析 (deb.
ESC_exit = 1;		// ESC 會像 Enter 返回
KbdClear();	// 清除鍵盤緩衝區
grPrt(2, cury, NORMATTR, "Goto Line Number : ", &bg0);
curx = 21;
}
// ----------- 跳至某個先前打的命令行字串的特殊功能鍵處理程式 -----------
void gotoXFn(void)
{
clrline(27);		// 只清除訊息
}
// ----------- 跳至某個先前打的命令行字串的鍵盤輸入處理程式 -----------
char gotoXkOK(void)
{
u_short n;
char	*p;

mainSetupKbd(); 	// 還原主程式鍵盤處理函式
if ((FunKey & 0xFF) == 0x1B) return;
p = kbuf + 1;
p  = skipSpace(p);
// 只讀入 2 位數的十進位值
n = 0;
if (isdigit(p[0])) {
	n = p[0] - 0x30;
	if (isdigit(p[1])) {
		n = (n * 10) + (p[1] - 0x30);
		}
	}
KbdClear();
if ((n > 0) && (n <= nKcmd)) {
	n = kofs[n-1];
	strcpy(kbuf+1, (char *) (LASTKEYS+n));	// 取得以前輸入的字串
	kbuf[0] = strlen(kbuf+1);	// 輸入字串的長度
	reshowKbuf();			// 重顯示此字串
	return(0);	// 有塞字串, 勿清除
	}
else return(1); 	// 要清除一行
}
// ----------------- 印出求助訊息 -----------------
void printHelp(void)
{
short	i;

setmem2(bg0.bgbuf, 0x1020, 1440);   y=cury=2;	// CLS
for (i=0;i < NHELP;i++) prtoutStr(helps[i]);
y = cury;
}
// ----------------- 重顯示此字串 -----------------
void reshowKbuf(void)
{
char	*p;
short	l, len;
char	ch;

l = kbuf[0];
p = kbuf + 1;
do	{
	len = (l > 43) ? 43 : l;
	ch = p[len];  p[len] = 0;
	grPrt(2, cury, NORMATTR, p, &bg0);
	if (len == 43) { curx = 2;  cury ++; }
	else curx += len;
	p += len;
	l -= len;
	if (cury > 24) {
		y --;		// 此次輸入的第一行
		cury = 24;
		scrollupNline(1);	// 文字上捲一行
		}
	} while (l > 0);
// 設定游標位置

}
// ----------------- 列出先前打的命令行字串 (Help.C) -----------------
void showCmds(void)
{
short	i;

setmem2(bg0.bgbuf, 0x1020, 1440);	// CLS
for (i=0;i < nKcmd;i++) {
	sprintf(sbuf, "%2d:", i+1);
	grPrt(1, i+2, 0x10, sbuf, &bg0);
	grPrt(4, i+2, 0x10, (char *) (kofs[i]+LASTKEYS), &bg0);
	}
cury = y = i+2;
putch(0x011B);		// 推入 ESC 鍵
}
// ----------------- 將 kbuf[128] 的字串保存起來 -----------------
void storeThisLine(void)
{
u_short i, n;

if (kbuf[0] == 0) return;		// 有字才存
if (nKcmd > 20) {
	nKcmd = 20;
	n = kofs[1];
	bcopy(LASTKEYS + n, LASTKEYS, kofs[21] - n);	// 字串前移
	for (i=0;i < 21;i ++) kofs[i] = kofs[i+1] - n;	// 指標前移
	}
if (nKcmd == 0) { kofs[0] = 0;	kofs[1] = kbuf[0] + 1; }
else kofs[nKcmd+1] = kofs[nKcmd] + kbuf[0] + 1; 	// 增加指標尾端
bcopy(kbuf+1, LASTKEYS + kofs[nKcmd], kbuf[0] + 1);	// 增加字串
nKcmd ++;
nEdCmd = nKcmd; 			// 供下次取用
}
