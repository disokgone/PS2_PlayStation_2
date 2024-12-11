#include <stdio.h>
#include <tamtypes.h>
#include <stdlib.h>
#include <string.h>
#include <kernel.h>
#include <sifrpc.h>
#include <mylibk.h>	// 須引用 sifrpc.h !
#include "nuputs.h"
#include "ETFONT.h"
#include "sceCDROM.h"	// 我自訂, 取自 Action-Replay 2 程式
#define	UseCDROM	// 可試由光碟讀取中文字型

#ifdef	UseCDROM
#define	fclose(fd)		sceClose(fd)
#define	fopen(fn, mode)		sceOpen(fn, mode)
#define	fread(fd, buf, len)	sceRead(fd, buf, len)
#define	fseek(fd, ofs, whence)	sceLseek(fd, ofs, whence)
#define	fwrite(fd, buf, len)	sceWrite(fd, buf, len)

#else	// .. UseCDROM
#define	fclose(fd)		fio_close(fd)
#define	fopen(fn, mode)		fio_open(fn, mode)
#define	fread(fd, buf, len)	fio_read(fd, buf, len)
#define	fseek(fd, ofs, whence)	fio_lseek(fd, ofs, whence)
#define	fwrite(fd, buf, len)	fio_write(fd, buf, len)
#endif	// .. UseCDROM

extern void errlog(char *s);
//---------------------------------------------------------------------------
#define		bgn1615		0x200000	// 從此放入 PS2 的記憶體
static	u8	OneChin[72];	// 最大可放 1 個 24x24 一位元點陣字
//---------------------------------------------------------------------------
int     cForeColor = 0xFFFFFF;		// 字型前景色 (有像點處)
int     cBackColor = 0x002020;		// 字型背景色 (low byte = red)
int	flen16[4] = { 3840, 12240, 392820, 10950 };	// 各字型檔長度
int	flen24[4] = { 12288, 29376, 942768, 26280 };	// 各字型檔長度
int	fpos16[4];	// 放各字型檔在記憶體的起點位址
int	fpos24[4];	// 放各字型檔在記憶體的起點位址

char    *stdf16[4] = {  "cdrom0:\\ETFONT\\ASCFONT.15;1",	// 16x15 英數字型
            "cdrom0:\\ETFONT\\SPCFONT.15;1",	// 16x15 符號字型
            "cdrom0:\\ETFONT\\STDFONT.15;1",	// 標準 16x15 字型
            "cdrom0:\\ETFONT\\SPCFSUPP.15;1" };	// 16x15 符號字型2
char    *stdf24[4] = {  "cdrom0:\\ETFONT\\ASCFONT.24;1",	// 24x24 英數字型
            "cdrom0:\\ETFONT\\SPCFONT.24;1",	// 24x24 符號字型
            "cdrom0:\\ETFONT\\STDFONT.24;1",	// 標準 24x24 字型
            "cdrom0:\\ETFONT\\SPCFSUPP.24;1" };	// 24x24 符號字型2
/*
char    *stdf16[4] = {  "host:D:\\ETFONT\\ASCFONT.15",	// 16x15 英數字型
            "host:D:\\ETFONT\\SPCFONT.15",	// 16x15 符號字型
            "host:D:\\ETFONT\\STDFONT.15",	// 標準 16x15 字型
            "host:D:\\ETFONT\\SPCFSUPP.15" };	// 16x15 符號字型2
char    *stdf24[4] = {  "host:D:\\ETFONT\\ASCFONT.24",	// 24x24 英數字型
            "host:D:\\ETFONT\\SPCFONT.24",	// 24x24 符號字型
            "host:D:\\ETFONT\\STDFONT.24",	// 標準 24x24 字型
            "host:D:\\ETFONT\\SPCFSUPP.24" };	// 24x24 符號字型2	*/
//---------------------------------------------------------------------------
int CheckChinese(int chr)
{
// 檢查是否為 .15 中文字 (in isch.asm)
// 傳回 0=1 byte 英文字, 1=2 byte 中文符號, 2=2 byte 中文, 3=2 byte 中文符號2
int     i;

i = swap16(chr);        chr = i & 0xFF;
if ((i < 0xA100) || (i > 0xFA00)) return(0);
if ((chr < 0x40) || (chr > 0xFE)) return(0);
if ((chr > 0x7E) && (chr < 0xA1)) return(0);
if (i < 0xA3C0) return(1);  // 1=2 byte 中文符號 (SPCFONT.15 : $A140 - $A3BF)
if (i < 0xC67F) return(2);  // 2=2 byte 中文 (STDFONT.15 : $A440 - $C67E)
if (i < 0xC8D4) return(3);  // 3=2 byte 中文符號2 (SPCFSUPP.15: $C6A1 - $C8D3)
if (i < 0xF9FF) return(2);  // 2=2 byte 中文 (STDFONT.15 : $C940 - $F9FE)
return(0);      // 保險 !
}
//---------------------------------------------------------------------------
int GetChineseOfs1615(int chType, int chr)
{       // 傳回其在檔案的偏移值
int     n, l;

n = swap16(chr);	chr = chr & 0xFF;
l = (u8) n - 0x40;	if (l > 0x60) l -= 0x22;    // l = [0..9C]
switch(chType) {
    case 0: return((u8) chr * 15);    	// 單一英文字 * 15 (in ASCFONT.15)
    case 1: // 2 byte 中文符號, SPCFONT.15 : $A140 - $A3BF
        n = ((chr - 0xA1) * 157 + l) * 30;      break;
    case 2: // 2 byte 中文, STDFONT.15 : $A440 - $C67E, $C940 - $F9FE
        n = (chr - 0xA4) * 157 + l;
        if (chr > 0xC8) n -= 408;       // 跳過中文符號2 (SPCFSUPP.15 : $C6A1 - $C8D3)
        n *= 30;
        break;
    case 3: // 2 byte 中文符號2, SPCFSUPP.15 : $C6A1 - $C8D3
        n = ((chr - 0xC6) * 157 + l - 63) * 30;         break;
    }
return(n);
}
//---------------------------------------------------------------------------
int GetChineseOfs24(int chType, int chr)
{       // 傳回其在檔案的偏移值
int     n, l;

n = swap16(chr);        chr = chr & 0xFF;
l = (u8) n - 0x40;      if (l > 0x60) l -= 0x22;	// l = [0..9C]
switch(chType) {
    case 0: return((u8) chr * 48);     	// 單一英文字 * 48 (in ASCFONT.24)
    case 1: // 2 byte 中文符號, SPCFONT.24 : $A140 - $A3BF
        n = ((chr - 0xA1) * 157 + l) * 72;      break;
    case 2: // 2 byte 中文, STDFONT.24 : $A440 - $C67E, $C940 - $F9FE
        n = (chr - 0xA4) * 157 + l;
        if (chr > 0xC8) n -= 408;       // 跳過中文符號2 (SPCFSUPP.24 : $C6A1 - $C8D3)
        n *= 72;
        break;
    case 3: // 2 byte 中文符號2, SPCFSUPP.24 : $C6A1 - $C8D3
        n = ((chr - 0xC6) * 157 + l - 63) * 72;         break;
    }
return(n);
}
//---------------------------------------------------------------------------
int getChinStrWidth(char *s)
{	// 計算輸出圖型區的總寬度
int	chr, w;

w = 0;
while (*s) {
	chr = (u8) *s | (*(u8 *)(s+1) << 8);		// 防止位址沒切齊
	if (CheckChinese(chr)) { w += 16;	s += 2; }
	else { w += 8;	s ++; }
	}
return(w);	// 傳回輸出圖型區總寬度
}
//---------------------------------------------------------------------------
int getChinStrWidth24(char *s)
{	// 計算輸出圖型區的總寬度
int	chr, w;

w = 0;
while (*s) {
	chr = (u8) *s | (*(u8 *)(s+1) << 8);		// 防止位址沒切齊
	if (CheckChinese(chr)) { w += 24;	s += 2; }
	else { w += 16;	s ++; }
	}
return(w);	// 傳回輸出圖型區總寬度
}
//---------------------------------------------------------------------------
char *getFont16(int chr)
{       // 取得點陣資料
char    *p;
int     i, fontOfs;

p = (char *) OneChin;        	bzero(p, 32);
i = CheckChinese(chr);
if (i == 0) { // 非中文字
	fontOfs = fpos16[0] + ((chr & 0xFF) * 15);
	memmove(p, (u8 *) fontOfs, 15);		// 讀取字型
	return(NULL);
	}
fontOfs = fpos16[i] + GetChineseOfs1615(i, chr);
memmove(p, (u8 *) fontOfs, 30);		// 讀取字型
return(p);
}
//---------------------------------------------------------------------------
char *getFont24(int chr)
{       // 取得點陣資料
char    *p;
int     i, fontOfs;

p = (char *) OneChin;        	bzero(p, 72);
i = CheckChinese(chr);
if (i == 0) { // 非中文字
	fontOfs = fpos24[0] + ((chr & 0xFF) * 48);
	memmove(p, (u8 *) fontOfs, 48);		// 讀取字型
	return(NULL);
	}
fontOfs = fpos24[i] + GetChineseOfs24(i, chr);
memmove(p, (u8 *) fontOfs, 72);		// 讀取字型
return(p);
}
//---------------------------------------------------------------------------
void plotme(char *b1p, char *b32p, int x, int w, int h, int wb32)
{	// 把一位元點陣 (b1p), 輸出為 32 位元點陣 (b1p), w 須為 8 之倍數
// x 是要畫出的水平偏移位置, wb32 是 b32p 緩衝區的總寬度
int	i, *pi;
u8	c, d;

c = d = 0;	b32p += (x << 2);	wb32 <<= 2;	// for pixel mode 32-bit !
while (h > 0) {
	pi = (int *) b32p;
	for (i=0;i < w;i ++) {
		if (c == 0) { d = *b1p;		b1p ++;		c = 8; }
		*pi = (d & 0x80) ? cForeColor : cBackColor;
		pi ++;	d <<= 1;	c --;
		}
	h --;	b32p += wb32;
	}
}
//---------------------------------------------------------------------------
int readChineseFont(void)
{	// 載入 16x15 及 24x24 字型
char	*addr;
int	fd, i, l, ret;

ret = 0;	addr = (char *) bgn1615;
for (i=0;i < 4;i ++) {
	fd = fopen(stdf16[i], O_RDONLY);
	if (fd < 0) {
		nprintf("載入中文字型失敗 -- %s, 錯誤碼 = %d", stdf16[i], fd);
		errlog("0");
		ret = fd;	// 記下最近的錯誤碼
		}
	else	{
		fpos16[i] = (int) addr;
		l = fread(fd, addr, flen16[i]);
		nprintf("載入中文字型 -- %s, 讀取長度 = %d bytes, %X", stdf16[i], l, addr);
		addr += flen16[i];	// 移到下一檔案擺放位置
		fclose(fd);
		if (l != flen16[i]) ret = 0x101;	// 長度有異 !
		errlog("1");
		}
	}
errlog("-");
for (i=0;i < 4;i ++) {
	fd = fopen(stdf24[i], O_RDONLY);
	if (fd < 0) {
		nprintf("載入中文字型失敗 -- %s, 錯誤碼 = %d", stdf24[i], fd);
		errlog("0");
		ret = fd;	// 記下最近的錯誤碼
		}
	else	{
		fpos24[i] = (int) addr;
		l = fread(fd, addr, flen24[i]);
		nprintf("載入中文字型 -- %s, 讀取長度 = %d bytes, %X", stdf24[i], l, addr);
		addr += flen24[i];	// 移到下一檔案擺放位置
		fclose(fd);
		if (l != flen24[i]) ret = 0x102;	// 長度有異 !
		errlog("1");
		}
	}
nprintf("最後可用位址 = %X", addr);
return(ret);
}
//---------------------------------------------------------------------------
void readMyFont(void *pFont)
{
int	fd;
/*
#ifdef	UseCDROM
	fd = sceOpen("cdrom0:\\S16CH.BIN;1", O_RDONLY);
#else
	fd = fio_open("host:d:\\psx2\\ps2_03\\s16ch.bin", O_RDONLY);
#endif

fread(fd, pFont, 30720);
fclose(fd);
*/
fd = fio_open("host:d:\\psx2\\ps2_03\\s16ch.bin", O_RDONLY);
fio_read(fd, pFont, 30720);
fio_close(fd);
}
//---------------------------------------------------------------------------
int str2ChineseBitmap16(char *s, char *buf)
{	// 將字串 s 轉成 16x15 中文字的 32-bit 點陣 (英數為 8x15, 中文字為 16x15)
int	chr, w, x;
char	*p;

w = getChinStrWidth(s);		// 需先計算輸出圖型區的總寬度
x = 0;
while (*s) {
	chr = (u8) *s | (*(u8 *)(s+1) << 8);		// 防止位址沒切齊
	p = getFont16(chr);
	if (p == NULL) plotme(OneChin, buf, x, 8, 15, w);	// 英數為 8x15, 放在 OneChin[0..14]
	else { plotme(p, buf, x, 16, 15, w);	x += 8; 	s ++; }
	x += 8;		s ++; 
	}
return(w);	// 傳回輸出圖型區總寬度
}
//---------------------------------------------------------------------------
int str2ChineseBitmap24(char *s, char *buf)
{	// 將字串 s 轉成 24x24 中文字的 32-bit 點陣 (英數為 16x24, 中文字為 24x24)
int	chr, w, x;
char	*p;

w = getChinStrWidth24(s);	// 需先計算輸出圖型區的總寬度
x = 0;
while (*s) {
	chr = (u8) *s | (*(u8 *)(s+1) << 8);		// 防止位址沒切齊
	p = getFont24(chr);
	if (p == NULL) plotme(OneChin, buf, x, 16, 24, w);	// 英數為 16x24, 放在 OneChin[0..14]
	else { plotme(p, buf, x, 24, 24, w);	x += 8; 	s ++; }
	x += 16;		s ++;
	}
return(w);	// 傳回輸出圖型區總寬度
}
//---------------------------------------------------------------------------
int swap16(int v)
{
u8	a;

a = (u8) (v >> 8);    	v &= 0xFF;      return(a | (v << 8));
}
//---------------------------------------------------------------------------

