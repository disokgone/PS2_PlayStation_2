//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop

#include "GENERAL.h"
#include "ELF_VIEW.h"   // ELF header viewer 程式

Elf32_Sym   *symG;      // General.cpp 將用的 symbol section
Elf32_Iop   *iopG;      // General.cpp 將用的 IOPM section
int     symGmax;        // 符號表的最大項數
int     validHexLen;    // GetHex() 所得到的有效字串長度
char    ctemp[16];

//---------------------------------------------------------------------------
#pragma package(smart_init)

//---------------------------------------------------------------------------
int binaSearch(int *tbl, int key, int elesz, int maxNdx)
{   // 傳回二元搜尋 int 表找到最近的位置 index (= byte offset)
int     l, m, r;        // 左,中,右的位置
int     esz;

if (tbl == NULL) return(0);     // bad sort table !
if (elesz <= 0) return(0);      // bad sort table !
if (maxNdx <= 0) return(0);     // bad sort table !
esz = elesz >> 2;       // 4 byte = 1 int !
l = 0;      r = maxNdx;
do  {
    m = (l+r) / 2;              // 與中點值比較
    if (l == m) break;          // 左半邊沒了 !
    if (key == tbl[m*esz]) break;
    if (key > tbl[m*esz]) {
        if (m == r) { m++;  break; }
        l = m;
        }
    else {
        if (l == m) break;
        r = m;
        }
    } while (1);
return(m * elesz);
}
//---------------------------------------------------------------------------
short calcScrLines(TForm *pform)        // 取得畫面可顯示的行數
{
extern short TextHeight;
int     j;

TextHeight = (short) pform->Canvas->TextHeight("l");
j = pform->ClientHeight;
if ((TextHeight > 0) && (j > 0)) return((short) (j/TextHeight));
else return(1);
}
//---------------------------------------------------------------------------
char CollideMode(int a, int al, int b, int bl)
{       // 前提假設 al = a + len_1, bl = b + len_2 (且 [a < al][b < bl])
if (a < b) {
    if (al > bl) return(4);     // A 比 B 大, B 包含於 A
    if (al >= b) return(1);     // A 與 B 重疊, A 在 B 之前
    return(0);                  // A, B 沒有交集
    }
if (a > bl) return(0);          // A, B 沒有交集
if (al < b) return(0);          // A, B 沒有交集
if (al > bl) return(3);         // A 與 B 重疊, B 在 A 之前
return(2);                      // A 比 B 小, A 包含於 B
}
//---------------------------------------------------------------------------
int GetHex(char *s)             // 從字串 s 處取得 Hex 值
{
char c, d;
int i, v;

validHexLen = 0;        // 假設完全沒數字
StrLCopy(ctemp, s, 15);
for (i=0;i < 16;i++) {
    c=ctemp[i];   d=0;
    if ((c == '$') || ((c > 0x2F) && (c < 0x3A))) d=1;  // [$, 0..9] ok !
    else c |= 0x20;
    if ((c > 0x60) && (c < 0x67)) d=1;  // [A..F] ok !
    if (d == 0) { ctemp[i]=0;  i=17; }  // others is bad !
    }
if (ctemp[0] == 0) return(0);
if ((ctemp[0] == '$') && (ctemp[1] == 0)) return(0);
validHexLen = StrLen(ctemp);
v = StrToInt(ctemp);
return(v);
}
//---------------------------------------------------------------------------
void grabAddrAsCacheTable(int fh, int fofs, int allSize, int *pTable)
{       // 取 2048 組位址到 pTable[] 當快取 (Elf32_Rel 型態)
int     i, j, gap;      // 重定位資訊大小 >= $8000 時才會執行本程式

setmem(pTable, 8192, 0);    // clear (2048 * 4) bytes to 0
gap = (allSize >> 14) << 3; // 分成 2048 等分
j = fofs;
for (i=0;i < 2047;i++, j+=gap) {
    FileSeek(fh, j, 0);
    FileRead(fh, pTable+i, 4);      // 讀入一個位址
    }
FileSeek(fh, fofs+allSize-8, 0);
FileRead(fh, pTable+i, 4);          // 讀入最後一個位址
}
//---------------------------------------------------------------------------
void MakeRelocate(char *p, int pofs, int info, int addlo, int addhi)
{       // 到唯一的 symbol section 取重定位資訊
int     *pi, value;

pi = (int *) (p+pofs);
pofs = info >> 8;       // pofs = symbol table index
if (pofs > symGmax) return;     // bad entry !
value = symG[pofs].st_value;    // 取得 symbol 數值
info &= 0xFF;           // info = relocation type
switch(info) {          // 目前只有以下各種
    case R_MIPS_32:     /* Direct 32 bit */
        *pi |= value;   break;
    case R_MIPS_26:     /* Direct 26 bit shifted */
        *pi |= ((*pi & 0xF0000000) | (value >> 6));     break;
    case R_MIPS_HI16:   /* High 16 bit */
        *pi |= ((*pi & 0xFFFF0000) | (value >> 16));    break;
    case R_MIPS_LO16:   /* Low 16 bit */
        *pi |= ((*pi & 0xFFFF0000) | (value &0xFFFF));  break;
    case R_MIPS_GPREL16:    /* GP relative 16 bit */
        *pi += ((value - iopG->i_GP) & 0xFFFF);     break;
    case R_MIPS_LITERAL:	/* 16 bit literal entry */
        *pi += value;   break;      // 未知 !!
    }
}
//---------------------------------------------------------------------------
void MemoAdd(TMemo *mm, char *s)
{
mm->Lines->Add(AnsiString(s));
}
//---------------------------------------------------------------------------
void padSpaces(char *src, int len)          // 補足空白字元
{
int	    l;

l = strlen(src);
if (l > len) return;
setmem(src+l, len-l, 0x20);     // 需填字元數
src[len] = 0;
}
//---------------------------------------------------------------------------

