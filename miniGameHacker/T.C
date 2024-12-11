#include <sys/types.h>
#include <file.h>
#include <graphics.h>
#include <kernel.h>
#include <libapi.h>
#include <libetc.h>
#include <stdio.h>
#include <MYGR.H>
#include <MYGR2.H>
#include <MYGH.H>
#include "GHALL.H"

void dump(void);			// 傾印記憶體內值
void xdump(void);			// 傾印記憶體內值
int edit_addr(int pad); 	// 輸入 dump 位址, 按 Start 決定, X 放棄
u_long mainPad(long pad);		// 主程式的搖桿處理
void mygrCLS(void);			// CLS
int  padCvt(u_long v);			// 轉換搖桿為連續數值
int  Redraw(int padv);			// 重畫畫面

u_long	dumpmode = 0, dumploc = 0;
long	wkmode = 0, lnsz;
BGINFO	bg0;
char	sbuf[40];
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
sbuf[0] = 'v';  sbuf[1] = 0;
grPrt(22 + ed_pos, 5, NORMATTR, sbuf, &bg0);
// 檢視按鍵作出反應
i = padCvt(pad);
if (i == lastEdKey) return(1);	// 與上次按鍵同
lastEdKey = i;		if (i == 0) return(1);	// 無按鍵
nshift = 28 - (ed_pos << 2);
v = 0xFFFFFFFF ^ (15 << nshift);		// = mask
v1 = (editaddr >> nshift) & 15; // = value (0..15)
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

// -------------------- 主程式的搖桿處理 --------------------
u_long mainPad(long pad)
{
u_short i, j, n;

i = 1;
j = padCvt(pad);
if (j > 0) n = 1;
switch(j) {
	case  1: dumploc -= lnsz;	break;	// Up
	case  2: dumploc += lnsz;	break;	// Down
	case  3: dumploc -= (lnsz << 4);  break;  // Left
	case  4: dumploc += (lnsz << 4);  break;  // Right
	case  5: dumploc -= (lnsz << 8);  break;  // Triangle
	case  6: dumploc += (lnsz << 8);  break;  // X
	case  7: dumploc -= (lnsz << 5);  break;  // Square
	case  8: dumploc += (lnsz << 5);  break;  // O
	case  9: dumploc -= (lnsz << 9);  break;  // L1
	case 10: dumploc += (lnsz << 9);  break;  // L2
//	case 11: showFiles();  break;	// R1
	case 12: dumpmode ^= 1; 	break;	// R2
	case 13: i=0;  n=0;	break;		// quit with Select key !
//	case 14: editMem(dumploc);  n=0;  break;  // read 1 Sector to dump !
	default: n=0;  break;
	}
return((i << 16) | n);
}

// ---------- CLS -------------
void mygrCLS(void)
{

}
