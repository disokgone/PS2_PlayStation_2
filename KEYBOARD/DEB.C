#include <sys/types.h>
#include <ctype.h>
#include <graphics.h>
#include <kernel.h>
#include <MYGR.H>
#include <MYGR2.H>
#include "PSDebug.h"

#define SCRNSIZE	1440	// (384 / 8) * (240 / 8)

u_long	lastDump = 0;
extern	u_long	uAddr;		// dis-Asm address
extern	u_short keyHead, keyTail;
extern	u_char	keybuff[64], KBDst0, KBDst1, KBDst2;
extern	u_char	useAlias, uAshowCh;
char	kbuf[128];	// kbuf[0] 為本字串長度, 0 為字串結束
u_short FunKey; 	// 功能鍵
u_char	curx = 2, cury = 2, curcnt = 0, y = 2, ESC_exit = 0;

void clrline(long y);			// 清除一行螢幕
void cmdGoesDown(void); 		// 讀出下一個命令行字串 (Help.C)
void cmdGoesUp(void);			// 讀出上一個命令行字串 (Help.C)
void doDump(u_long addr, u_long len);	// 執行傾印
void do_Search(u_short nlen, u_char *psrc, u_long srclen, u_char *srhdta);
// 搜尋功能 (Help.C)
void doTrace(char *p);			// 分析剩餘參數並單步執行 (Regwork.C)
void doUasm(u_long addr, u_long nline); // 執行反組譯
char *gotoSpace(char *pstr);		// 找到空白或 tab 鍵
void gotoXcmd(void);			// 跳至某個先前打的命令行字串 (Help.C)
u_short GetKbdScan(void);		// get scan code back !
void KbdClear(void);			// 清除鍵盤緩衝區
void KbdInput(void);			// 收集輸入的字串
void mainFuncKey(void); 		// 主程式的特殊功能鍵分析
void mainSetupKbd(void);		// 設置主程式鍵盤處理函式
char mainParseKbd(void);		// 主程式的命令分析
void printHelp(void);			// 印出求助訊息 (Help.C)
char *readDec2(char *ps, long *val);	// 讀取 10 進位數值
char *readHex(char *ps, long *val);	// 讀取 16 進位數值
void scrollupNline(u_short n);		// 文字上捲 N 行
void setregWork(char *p);		// 分析剩餘參數並設定到該暫存器
void setToGo(char *p);			// 分析剩餘參數並執行程式 (Regwork.C)
void showCmds(void);			// 列出先前打的命令行字串 (Help.C)
char *skipSpace(char *pstr);		// 跳過空白或 tab 鍵
void stepOver(char *p); 		// 分析剩餘參數並單步執行 (Regwork.C)
void storeThisLine(void);		// 將 kbuf[128] 的字串保存起來 (Help.C)
char (* KbdInputOk)(void);		// 鍵盤輸入一行後的處理程式
void (* KbdSpcialFn)(void);		// 呼叫特殊功能鍵分析
// ------------------- 特殊功能鍵如下 -------------------
// F1 = 切換反組譯程式的暫存器名稱為別名或數字名
// F2 = 切換反組譯的行末要印數字還是文字
// F9 = 列出先前打的命令行字串
// F10 = 跳至某個先前打的命令行字串

// -------------- 清除一行螢幕 --------------
void clrline(long y)
{
u_char	*p;

p = (u_char *) bg0.bgbuf;
setmem2(p + (y * 96), 0x1020, 48);		// 48 = 384 / 8
}

// --------------- 執行傾印 ---------------
void doDump(u_long addr, u_long len)
{
u_long	i, j, l;
u_char	*p;

p = (u_char *) addr;
do	{
	l = 8;	if (l > len) l = len;
	setmem2(sbuf, 0, 32);		// fill 64 byte !
	sprintf(sbuf, "$%08lX - ", p);  j = 12;
	for (i=0;i < l;i ++) {
		sprintf(sbuf+j, "%02X", p[i]);
		sbuf[j+2] = ' ';
		j += 3;
		sbuf[36+i] = p[i];
		if (p[i] == 0) sbuf[36+i] = '.';
		}
	p += 8;
	len -= l;
	grPrt(1, cury, 0x10, sbuf, &bg0);
	cury ++;
	if (cury > 24) {
		cury = 24;
		scrollupNline(1);	// 文字上捲一行
		}
	} while (len > 0);
lastDump = (u_long) p;
y = cury;
}

// --------------- 找到空白或 tab 鍵 ---------------
char *gotoSpace(char *pstr)
{
char	ch;

do	{
	ch = *pstr ++;
	if (ch == 0) break;	// 已到行尾
	if ((ch == 0x20) || (ch == 9)) break;	// 找到了
	} while (1);
return(pstr - 1);
}
// -------------- 設置主程式鍵盤處理函式 --------------
void mainSetupKbd(void)
{
KbdInputOk = mainParseKbd;
KbdSpcialFn = mainFuncKey;
ESC_exit = 0;		// ESC 只會清除該行而不會像 Enter 返回
}
// -------------- 清除鍵盤緩衝區 --------------
void KbdClear(void)
{
setmem2(kbuf, 0, 127 >> 1);
cury = y;
curx = 2;
clrline(y);
grPrt(1, y, 0x10, ">", &bg0);
clrline(26);
clrline(27);
}
// -------------- 收集輸入的字串 --------------
void KbdInput(void)
{		// 輸入字數不得超過 126 字元 (< 127 chars)
u_short key, kn, tmp;

curcnt ++;
if (kbhit()) {
	key = getch();
	tmp = key & 0xFF;
	kn = kbuf[0];
	if (tmp != 0) switch(tmp) {	// has ASCII code
		case 0x08:	// 按了倒退鍵
			if (kn > 0) kn --;
			kbuf[0] = kn;
			kbuf[kn+1] = 0;
			tmp = 32;	// 印出空白
			grPrt(curx, cury, 0x10, (char *) &tmp, &bg0);
			curx --;
			if (curx < 2) {
				if (cury > y) {
					curx = 44;
					cury --;
					}
				else { curx = 2;  cury = y; }
				}
			break;
		case 0x0D:	// 按了換行鍵
			kbuf[kn+1] = 0;
			tmp = 32;	// 印出空白
			grPrt(curx, cury, 0x10, (char *) &tmp, &bg0);
			y = y + (kbuf[0] / 43) + 1;	// 一行有 43 字
			if (y > 24) {
				scrollupNline(1);	// 文字上捲一行
				y = 24;
				}
			FunKey = key;	// 讓程式可分別是 ESC/Enter 離開的
			if (KbdInputOk()) KbdClear();	// 此行處理完了, 秀出提示符號
			break;
		case 0x1B:	// 按了 ESC 鍵, 放棄此行重新輸入
			FunKey = key;	// 讓程式可分別是 ESC/Enter 離開的
			if (ESC_exit) KbdInputOk();	// ESC 如同 Enter !
			else do {
				clrline(cury);
				cury --;
				} while (cury == y);
			KbdClear();	// 清除鍵盤緩衝區
			break;
		default:
		    if (kn < 126) {
			kbuf[kn+1] = tmp;
			kbuf[kn+2] = 0;
			kbuf[0] ++;
			grPrt(curx, cury, 0x10, kbuf+kn+1, &bg0);
			curx ++;
			if (curx > 44) {	// 一行有 43 字 + 1
				curx = 2;
				cury ++;
				}
			if (cury > 24) {
				y --;		// 此次輸入的第一行
				cury = 24;
				scrollupNline(1);	// 文字上捲一行
				}
			}
		    else    {
			clrline(26);
			grPrt(2, 26, 0x10, "Console input buffer full !", &bg0);
			}
		    break;
		}
	else	{
		clrline(27);
		sprintf(sbuf, "special Fn key - $%X", key >> 8);
		grPrt(2, 27, 0x10, sbuf, &bg0);
		FunKey = key;
		KbdSpcialFn();		// 呼叫特殊功能鍵分析
		}
	}
tmp = 219;	// 實心方塊
if (curcnt < 0x20) tmp = 0x5F;
if (curcnt > 0x3F) curcnt = 0;
grPrt(curx, cury, 0x10, (char *) &tmp, &bg0);
}

// --------------- 主程式的特殊功能鍵分析 ---------------
void mainFuncKey(void)
{
switch(FunKey >> 8) {
	case 0x3B:	// F1 = 切換反組譯程式的暫存器名稱為別名或數字名
		useAlias ^= 1;	break;
	case 0x3C:	// F2 = 切換反組譯的行末要印數字還是文字
		uAshowCh ^= 1;	break;
	case 0x43:	// F9 = 列出先前打的命令行字串
		showCmds();	break;
	case 0x44:	// F10 = 跳至某個先前打的命令行字串
		gotoXcmd();	break;
	case 0x48:	// Up arrow = 讀出上一個命令行字串
		cmdGoesUp();	break;
	case 0x50:	// Down arrow = 讀出下一個命令行字串
		cmdGoesDown();	  break;
	}
}
// --------------- 主程式的命令分析 ---------------
char mainParseKbd(void)
{
u_long	arg1, arg2;
u_char	*pb, no, nLen, fdta[32];
char	*p;

storeThisLine();	// 將 kbuf[128] 的字串保存起來 (in Help.C)
p = kbuf + 1;
p  = skipSpace(p);
clrline(25);		// 顯示提示訊息或錯誤用
if (isupper(p[0])) p[0] = _tolower(p[0]);
switch(p[0]) {
	case '?':       // show help
		printHelp();  break;
	case 'd':       // dump (addr) (length)
		p = skipSpace(p+1);
		if (p[0] == 0) arg1 = lastDump; // 用上次的起始位址
		else p = readHex(p, &arg1);	// 傾印起始位址
		p = skipSpace(p);
		if (p[0] == 0) arg2 = 0xA8;	// 正好印一個畫面
		else p = readHex(p, &arg2);	// 傾印長度
		doDump(arg1, arg2);		// 執行傾印
		break;

	case 'e':       // enter (addr) (hex-byte-list)
		p = skipSpace(p+1);
		p = readHex(p, &arg1);		// 設值起始位址
		pb = (u_char *) arg1;
		p = skipSpace(p);
		while (isxdigit(*p)) {
			p = readHex(p, &arg1);	// 設立值
			p = skipSpace(p);
			*pb = arg1;
			pb ++;
			if (*p == 0) break;
			}
		break;

	case 'f':       // fill (addr) (hex-byte-list) or ('string')
		p = skipSpace(p+1);
		p = readHex(p, &arg1);		// 設值起始位址
		pb = (u_char *) arg1;
		p = skipSpace(p);
		p = readHex(p, &arg2);		// 填值長度
		p = skipSpace(p);
		nLen = 0;  setmem2(fdta, 0, 16);
		if (p[0] == 0x27) {
			p ++;
			while (p[0] != 0x27) {
				if (p[0] == 0) break;
				if (nLen == 32) break;
				fdta[nLen++] = *p++;
				}
			}
		else while (isxdigit(*p)) {
			p = readHex(p, &arg1);	// 設立值
			p = skipSpace(p);
			fdta[nLen] = arg1;
			nLen ++;
			if (*p == 0) break;
			if (nLen > 31) break;
			}
		// 執行填入動作
		if (nLen == 0) break;
		no = 0;
		while (arg2) {
			*pb ++ = fdta[no++];
			if (no == nLen) no = 0;
			arg2 --;
			};
		break;

	case 'g':       // go (execAddr) = (hardware break-point)
		p = skipSpace(p+1);
		setToGo(p);			// 分析剩餘參數並執行程式
		break;

	case 'p':       // stepover (nLines)
		p = skipSpace(p+1);
		stepOver(p);			// 分析剩餘參數並單步執行
		break;

	case 'r':       // register (name) (new-value)
		p = skipSpace(p+1);
		setregWork(p);			// 分析剩餘參數並設定到該暫存器
		break;

	case 's':       // search (start addr) (hex-byte-list) or ('string')
		p = skipSpace(p+1);
		if (p[0] == 0) do_Search(0, 0, 0, 0);	// 繼續上次搜尋
		p = readHex(p, &arg1);		// 搜尋起始位址
		pb = (u_char *) arg1;
		p = skipSpace(p);
		p = readHex(p, &arg2);		// 搜尋長度
		p = skipSpace(p);
		nLen = 0;  setmem2(fdta, 0, 16);
		if (p[0] == 0x27) {
			p ++;
			while (p[0] != 0x27) {
				if (p[0] == 0) break;
				if (nLen == 32) break;
				fdta[nLen++] = *p++;
				}
			}
		else while (isxdigit(*p)) {
			p = readHex(p, &arg1);	// 設立值
			p = skipSpace(p);
			fdta[nLen] = arg1;
			nLen ++;
			if (*p == 0) break;
			if (nLen > 31) break;
			}
		// 執行搜尋動作
		if (nLen == 0) break;
		do_Search(nLen, pb, arg2, fdta); // 找滿 21 個便自動停止
		break;

	case 't':       // trace (nLines)
		p = skipSpace(p+1);
		doTrace(p);			// 分析剩餘參數並單步執行
		break;

	case 'u':       // unAsm (addr) (nLines)
		p = skipSpace(p+1);
		if (p[0] == 0) arg1 = uAddr;	// 用上次的起始位址
		else p = readHex(p, &arg1);	// 反組譯起始位址
		p = skipSpace(p);
		if (p[0] == 0) arg2 = 21;	// 正好印一個畫面
		else p = readHex(p, &arg2);	// 反組譯行數
		doUasm(arg1, arg2);		// 執行反組譯
		break;

	default:
		grPrt(2, 25, 0x10, "Type ? for Help", &bg0);
		break;
	}
return(1);	// 要清除一行
}

// --------------- 文字上捲 N 行 ---------------
void scrollupNline(u_short n)
{
char	*p;
short	i;

p = (u_char *) bg0.bgbuf;
memmove(p+192, p+288, (23-n)*96);	// 上捲 N 行
for (i=cury;i < 25;i++) clrline(i);	// 清除游標以下數行
}
// --------------- 讀取 10 進位數值 ---------------
char *readDec2(char *ps, long *val)
{
long v, n;
char cc;

v = 0;
ps = skipSpace(ps);		// 略過前方的空白
do	{
	n = 0;
	cc = isdigit(*ps);
	if (cc) {
		n = *ps++;
		n -= 0x30;
		v = (v * 10) + n;	// 增入一位數
		}
	} while (cc);		// 一直轉換直到遇見非 16 進位數值
*val = v;
return(ps);
}

// --------------- 讀取 16 進位數值 ---------------
char *readHex(char *ps, long *val)
{
long v, n;
char cc;

v = 0;
ps = skipSpace(ps);		// 略過前方的空白
do	{
	cc = isxdigit(*ps);
	if (cc) {
		n = *ps ++;
		n = n - 0x30;
		if (n > 9) n = n - 7;
		v = (v << 4) + (n & 15);	// 增入一位數
		}
	} while (cc);		// 一直轉換直到遇見非 16 進位數值
*val = v;
return(ps);
}

// --------------- 跳過空白或 tab 鍵 ---------------
char *skipSpace(char *pstr)
{
char	ch;

do	{
	ch = *pstr ++;
	if (ch == 0) break;	// 已到行尾
	} while ((ch == 0x20) || (ch == 9));
return(pstr - 1);
}

