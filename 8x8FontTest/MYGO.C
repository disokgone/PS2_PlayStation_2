#include <sys/types.h>
#include <file.h>
#include <kernel.h>
#include <libapi.h>
#include <libetc.h>
#include "AR2.H"
// --------------------------------------
extern void testVBlank(void);
extern void doDump(void);
void ExecGame(void);
extern int waitPad(int last);
// --------------------------------------
// char *fn1 = "\\SETUP.EXE;1";         // $
// char *fn2 = "\\CDSETUP.EXE;1";
// char *fn3 = "\\CWIN95\\README.TXT;1";
// char *mess = "%X,%d,%d,%d,%d,%d";
// char *eg01 = "\\PS2%03X.EXE;1";      // $109718
// char *eg02 = "CdSrh = %X";           // $109728
// char *eg03 = "Srh OK!";              // $109734
// char *eg04 = "cdrom0:\\PS2_%02X.EXE;1"       // $10973C

// 請在 $10968C 插入 j $10E4C8, nop
// 即是檔案的 $F68C 放十六進位的 32 39 04 08, 00 00 00 00

extern	int	dumploc, dumpmode, x, xlen, *pkt, *ctrl;
extern	char	eg01[], eg02[], eg03[], eg04[];
extern	char	fn1[], fn2[], fn3[], mess1[];
// --------------------------------------
void myGo(void)
{
char	tempbuf[48];
int	i, j, k, rtv;

testVBlank();
dumpmode = 0;		dumploc = 0x16B5E8;
ctrl = Ar2Sys();	x = ctrl[2];	xlen = ctrl[3];
drawFrame(pkt, x, 8, xlen, 256, 0);
pkt = malloc(0x2800);		ctrl = malloc(8);
beginPacket(pkt, ctrl); 	// 建立第一個封包控制段落
rtv = sceCdDiskReady(0);	// 傳回值為 cdrom0 狀態
i = sceCdSearchFile(tempbuf, (char *) fn1);	// 嘗試搜尋三個檔案
j = sceCdSearchFile(tempbuf, (char *) fn2);
k = sceCdSearchFile(tempbuf, (char *) fn3);
sprintf(tempbuf, (char *) mess1, rtv, i, j, k, x, xlen);
drawBitMap(pkt, 16, 48, tempbuf);	// 印出處理結果
messageBox3((char *) fn1, (char *) fn2, (char *) fn3);	// 印出搜尋檔名
// i = waitPad(Pad1x);		// 等按下非 X 的按鈕
// if (i == Pad1tri) doDump();	// 按下三角形鈕
// if (i == Pad1crc) ExecGame();	// 按下 O 鈕
ExecGame();	// 按下 O 鈕
}
// --------------------------------------
void ExecGame(void)
{
char	buf[96];
int	i, key, num, rtv;

rtv = sceCdDiskReady(0);	// 傳回值為 cdrom0 狀態
// i = waitPad(Pad1crc);		// 等按下非 O 的按鈕
drawFrame(pkt, x, 8, xlen, 256, 0);	key = 0;	num = 0;
do	{
	sprintf(buf + 48, eg01, num);
	drawBitMap(pkt, 24, 120, buf);	// 印出將執行的檔名
	key = waitPad(key);
	if (key == Pad1Up) { num --;  if (num < 0) num = 999; }
	if (key == Pad1Down) { num ++;	if (num > 999) num = 0; }
	} while (key != Pad1Start);
i = sceCdSearchFile(buf, buf + 48);	// 嘗試搜尋三個檔案
sprintf(buf, eg02, i);
messageBox3(eg03, buf + 48, buf);	// 印出搜尋結果
sprintf(buf, eg04, num);
ustrcpy((char *) 0x174560, buf);
loadRunELF_Program(1, 0);	// 載入程式, 保留功能
}

