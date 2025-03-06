#include <sys/types.h>
#include <ctype.h>
#include <graphics.h>
#include <kernel.h>
#include <strings.h>
#include <MYGR.H>
#include <MYGR2.H>
#include "PSDebug.h"

extern	u_long	_BPC, _BDA, _TAR, _DCIC, _BDAM, _BPCM, _SR, _CAUSE, _EPC;
extern	u_char	curx, cury, y, ESC_exit;
extern	char	kbuf[];
extern	char	alias[];
extern	u_short FunKey;

u_long	goAddr, TarAddr;
// CP0 的 reg $0, $1, $2, $4, $10 與 LR33020 相同, 並不存在
char	*cp0s[17] = { "#", "#", "#", "$3 Brkpt PC", "#", "$5 Brkpt Data Addr",
		"$6 Target", "$7 Debug & Cache IControl ",
		"$8 Bad Addr", "$9 Brkpt Data Addr Mask",
		"#", "$11 BPC Mask", "$12 Status Reg", "$13 Cause",
		"$14 Except. PC", "$15 Processor ID", "$16 Error Reg" };
char	*cp2c[32] = { "$0  R11R12", "$1  R13R21", "$2  R22R23", "$3  R31R32",
		"$4  R33", "$5  TRX", "$6  TRY", "$7  TRZ", "$8  L11L12",
		"$9  L13L21", "$10 L22L23", "$11 L31L32", "$12 L33",
		"$13 RBK", "$14 GBK", "$15 BBK", "$16 LR1LR2",
		"$17 LR3LG1", "$18 LG2LG3", "$19 LB1LB2", "$20 LB3",
		"$21 RFC", "$22 GFC", "$23 BFC", "$24 OFX",
		"$25 OFY", "$26 II", "$27 DQA", "$28 DQB",
		"$29 ZSF3", "$30 ZSF4", "$31 FLAG" };
char	*cp2s[32] = { "$0  VXY0", "$1  VZ0", "$2  VXY1", "$3  VZ1",
		"$4  VXY2", "$5  VZ2", "$6  RGB", "$7  OTZ",
		"$8  IR0", "$9  IR1", "$10 IR2", "$11 IR3",
		"$12 SXY0", "$13 SXY1", "$14 SXY2", "$15 SXY2P",
		"$16 SZx", "$17 SZ0", "$18 SZ1", "$19 SZ2",
		"$20 RGB0", "$21 RGB1", "$22 RGB2", "$23 --",
		"$24 MAC0", "$25 MAC1", "$26 MAC2", "$27 MAC3",
		"$28 IRGB", "$29 ORGB", "$30 DATA32", "$31 LZC" };
char	*hwreg[16] = { "spu_delay", "dv5_delay", "com_delay", "Pad RAM size",
		"sio1_data", "sio1_status", "sio1_mode", "sio1_control",
		"sio1_baud", "sio2_data", "sio2_status", "sio2_mode",
		"sio2_control", "sio2_baud", "intr_reg", "intr_mask" };
char	*hwrg2[20] = { "DMA0 MADR", "DMA0 BCR (size)", "DMA0 CHCR", "DMA1 MADR",
		"DMA1 BCR (size)", "DMA1 CHCR", "DMA2 MADR", "DMA2 BCR (size)",
		"DMA2 CHCR", "DMA3 MADR", "DMA3 BCR (size)", "DMA3 CHCR",
		"D_PCR", "D_ICR", "INT 2000", "DIP_SWITCH ?",
		"cdrom_0", "cdrom_1", "cdrom_2", "cdrom_3" };
char	*hwrg3[17] = { "T0_COUNT", "T0_MODE", "T0_TARGET", "T1_COUNT",
		"T1_MODE", "T1_TARGET", "T2_COUNT", "T2_MODE",
		"T2_TARGET", "GPU_0", "GPU_1", "MDEC_0",
		"MDEC_1", "SPU_MVOL_L", "SPU_MVOL_R", "SPU_RevDepth_L", "SPU_RevDepth_R" };
char	*hwrg4[20] = { "SPU_KEYON_1", "SPU_KEYON_2", "SPU_KEYOFF_1", "SPU_KEYOFF_2",
		"SPU_Unknow_1", "SPU_Unknow_2", "SPU_Unknow_3", "SPU_Unknow_4",
		"SPU_Unknow_5", "SPU_Unknow_6", "SPU_Unknow_7", "SPU_SB_ADDR",
		"SPU_Unknow_8", "SP0_FLAG", "SPU_Unknow_9", "SP1_STATUS",
		"CD_MVOL_L", "CD_MVOL_R", "SPU_Unknow_10", "SPU_Unknow_11" };
u_short hwaddr[16] = { 0x1014, 0x1018, 0x1020, 0x1060,
		0x1040, 0x1044, 0x1048, 0x104A,
		0x104E, 0x1050, 0x1054, 0x1058,
		0x105A, 0x105E, 0x1070, 0x1074 };
u_short hwadr2[20] = { 0x1080, 0x1084, 0x1088, 0x1090,
		0x1094, 0x1098, 0x10A0, 0x10A4,
		0x10A8, 0x10C0, 0x10C4, 0x10C8,
		0x10F0, 0x10F4, 0x2030, 0x2040,
		0x1800, 0x1801, 0x1802, 0x1803 };
u_short hwadr3[17] = { 0x1100, 0x1104, 0x1108, 0x1110,
		0x1114, 0x1118, 0x1120, 0x1124,
		0x1128, 0x1810, 0x1814, 0x1820,
		0x1824, 0x1D80, 0x1D82, 0x1D84, 0x1D86 };
u_short hwadr4[20] = { 0x1D88, 0x1D8A, 0x1D8C, 0x1D8E,
		0x1D90, 0x1D92, 0x1D94, 0x1D96,
		0x1D98, 0x1D9A, 0x1DA2, 0x1DA6,
		0x1DA8, 0x1DAA, 0x1DAC, 0x1DAE,
		0x1DB0, 0x1DB2, 0x1DB4, 0x1DB6 };
u_char	hwsize[16] = { 4, 4, 4, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2 };
u_char	hwsiz2[20] = { 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 2, 2, 4, 4, 4, 1, 2, 1 };
u_char	hwsiz3[17] = { 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 2, 2, 2, 2 };

u_char	regloc[31] = { 0x74, 4, 8, 0x0C, 0x10, 0x14, 0x18, 0x24,
		0x28, 0x2C, 0x30, 0x34, 0x38, 0x3C, 0x40, 0x4C,
		0x50, 0x54, 0x58, 0x5C, 0x60, 0x64, 0x68, 0x44,
		0x48, 0x1C, 0x20, 0, 0x78, 0x6C, 0x70 };	// r1 - r31
char	debugType = debNone;	// 0=None, 1=Trace, 2=Step, 3=HwBP, 4=HwData, 5=SwBP
char	hasTAR = 0, exCount;

void doTrace(char *p);			// 分析剩餘參數並單步執行
void dumpReg(short no); 		// 印出暫存器
u_long getCOPcreg(int COPno, int regNo);	// 讀取某個輔助處理器的控制暫存器值
u_long getCOPreg(int COPno, int regNo); // 讀取某個輔助處理器的資料暫存器值
u_long getHwReg(u_short no, u_char sz); // 讀取某個硬體暫存器值
u_long getEPC(void);			// 取得正確的下一行指令位址
void init_regs(void);			// 初始化各暫存器值
char isJALs(u_long p);			// 若是 JAL/JALR 則傳回 1
void LoadMainReg(void); 		// 取回本程式暫存器值 (Newdeb.S)
void lowerStr(char *ps);		// 全字串轉為小寫
void prtoutStr(char *str);		// 印出一行並換行
char *readDec2(char *ps, long *val);	// 讀取 10 進位數值 (deb.c)
char *readHex(char *ps, long *val);	// 讀取 16 進位數值 (deb.c)
void RetProgReg(u_long exeAddr);	// 取回被除錯的程式暫存器值並跳入執行 (Newdeb.S)
void SaveMainReg(void); 		// 保存本程式暫存器值 (Newdeb.S)
void SetMyDebug(void);			// 安裝我的除錯中斷處理程式 (Newdeb.S)
void setregWork(char *p);		// 分析剩餘參數並設定到該暫存器
void setToGo(char *p);			// 分析剩餘參數並執行程式
void showChangedReg(void);		// 秀出有變化的暫存器值
void showCP0(void);			// 看 CP0 的各個暫存器值
char *skipSpace(char *pstr);		// 跳過空白或 tab 鍵 (deb.c)
void stepOver(char *p); 		// 分析剩餘參數並單步執行

// --------------- 從此位址執行 ---------------
void doExec(u_long exeAddr)
{
SetMyDebug();		// 安裝我的除錯中斷處理程式
SaveMainReg();		// 保存本程式暫存器值
RetProgReg(exeAddr);	// 取回被除錯的程式暫存器值並跳入執行
LoadMainReg();		// 取回本程式暫存器值
showCP0();		// 看 CP0 的各個暫存器值
}
// --------------- 分析剩餘參數並單步執行 ---------------
void doTrace(char *p)
{
u_long	n;

if (p[0] != 0) {
	lowerStr(p);		// 全字串轉為小寫
	readDec2(p, &n);
	}
if (n == 0) n = 1;	// 只執行一行
do	{
	goAddr = getEPC();	// 取得正確的下一行指令位址
	doUasm(goAddr, 1);	// 印出 goAddr 該行指令
	bcopy((u_char *) 0xFC80, (u_char *) 0xFD00, 0x80);	// 保留執行前的暫存器值
	// !! 經實驗證明其硬體 Trace 功能並未實作, 因此不能使用硬體 Trace 功能
	debugType = debHwBP;
	SetHwBP(goAddr+4);
	doExec(goAddr); 	// 跳到使用者指定的位址
	showChangedReg();	// 秀出有變化的暫存器值
	n --;
	} while (n);
}
// --------------- 取得正確的下一行指令位址 ---------------
u_long getEPC(void)
{
u_long	*pl;
short	ofs;

if (_CAUSE & 0x80000000) {	// 分支跳離之中被中斷, TAR = 分支跳離之目的地
	if (_CAUSE & 0x40000000) {
		hasTAR = 1;
		TarAddr = _TAR; // 分支跳離之目的地
		return(_EPC+4); // 延遲槽要執行 (EPC = 分支跳離指令之位址)
		}
	pl = (u_long  *) _EPC;
	ofs = pl[0] & 0xFFFF;
	return(_EPC + 4 + (ofs << 2));
	}
else	{
	if (hasTAR) {
		hasTAR = 0;
		return(TarAddr);	// 執行分支跳離之目的地
		}
	return(_EPC);
	}
}
// --------------- 初始化各暫存器值 ---------------
void init_regs(void)
{
u_long	*pl;

pl = (u_long *) 0xFC80;
setmem2(pl, 0, 0x40);
pl[0] =  0x801D0000;	// gp
pl[27] = 0x801D0000;	// fp
pl[28] = 0xBFC00000;	// ra
pl[30] = 0x801FFF00;	// sp
}
// --------------- 分析剩餘參數並設定到該暫存器 ---------------
void setregWork(char *p)
{
u_long	n, val, *lp;
u_short i, regNo;
char	c1, c2;

if (p[0] == 0) dumpReg(-1);	// 暫存器全部印出
else	{	//
	lowerStr(p);		// 全字串轉為小寫
	if (isdigit(p[0])) {	// 看 CP0-3 的暫存器
		c2 = p[0] & 7;
		p = skipSpace(p+1);
		if (p[0] == 0) c1 = 2;
		else c1 = 1;
		readDec2(p, &n);
		if (c1 > 1) switch(c2) {	// CP1 & CP3 不存在, 會當機
			case 0:  c1=17;  prtoutStr(" CP0 data registers --");  break;
			case 1:  c1=32;  prtoutStr(" CP2 data registers --");  break;
			case 2:  c1=32;  prtoutStr(" CP2 control registers --");  break;
			case 3:  c1=16;  break;
			case 4:  c1=18;  break;
			case 5:  c1=17;  break;
			case 6:  c1=20;  break;
			}
		if (c1 > 2) prtoutStr(" Hardware registers of $1F80xxxx --");
		while (c1 > 0) {
		    switch(c2) {
			case 0:
			    if (n > 16) break;
			    if (cp0s[n][0] == '$') {
				sprintf(sbuf, "%s - %08lX", cp0s[n], getCOPreg(0, n));
				prtoutStr(sbuf);
				}
			    break;
			case 1:
			    if (n > 31) break;
			    setmem2(sbuf, 0x2020, 32);
			    sprintf(sbuf, "%s - %08lX ", cp2s[n], getCOPreg(2, n));
			    c1 --;  n++;
			    if (c1 > 0) {
				for (i=0;i < 64;i++) if (sbuf[i] == 0) sbuf[i] = 0x20;
				VSync(0);	// 必須等待
				sprintf(sbuf+23, "%s - %08lX", cp2s[n], getCOPreg(2, n));
				}
			    prtoutStr(sbuf);
			    break;
			case 2:
			    if (n > 31) break;
			    setmem2(sbuf, 0x2020, 32);
			    sprintf(sbuf, "%s - %08lX ", cp2c[n], getCOPcreg(2, n));
			    c1 --;  n++;
			    if (c1 > 0) {
				for (i=0;i < 64;i++) if (sbuf[i] == 0) sbuf[i] = 0x20;
				VSync(0);	// 必須等待
				sprintf(sbuf+23, "%s - %08lX", cp2c[n], getCOPcreg(2, n));
				}
			    prtoutStr(sbuf);
			    break;
			case 3:
			    if (n > 15) break;
			    setmem2(sbuf, 0x2020, 32);
			    i = hwaddr[n];
			    sprintf(sbuf, "$1F80%04X %s ", i, hwreg[n]);
			    for (c1=0;c1 < 64;c1++) if (sbuf[c1] == 0) sbuf[c1] = 0x20;
			    switch(hwsize[n]) {
				case 1:  sprintf(sbuf+24, "%02X", getHwReg(i, hwsize[n]));  break;
				case 2:  sprintf(sbuf+24, "%04X", getHwReg(i, hwsize[n]));  break;
				case 4:  sprintf(sbuf+24, "%08lX", getHwReg(i, hwsize[n]));  break;
				}
			    prtoutStr(sbuf);
			    break;
			case 4:
			    if (n > 19) break;
			    setmem2(sbuf, 0x2020, 32);
			    i = hwadr2[n];
			    sprintf(sbuf, "$1F80%04X %s ", i, hwrg2[n]);
			    for (c1=0;c1 < 64;c1++) if (sbuf[c1] == 0) sbuf[c1] = 0x20;
			    switch(hwsiz2[n]) {
				case 1:  sprintf(sbuf+27, "%02X", getHwReg(i, hwsiz2[n]));  break;
				case 2:  sprintf(sbuf+27, "%04X", getHwReg(i, hwsiz2[n]));  break;
				case 4:  sprintf(sbuf+27, "%08lX", getHwReg(i, hwsiz2[n]));  break;
				}
			    prtoutStr(sbuf);
			    break;
			case 5:
			    if (n > 16) break;
			    setmem2(sbuf, 0x2020, 32);
			    i = hwadr3[n];
			    sprintf(sbuf, "$1F80%04X %s ", i, hwrg3[n]);
			    for (c1=0;c1 < 64;c1++) if (sbuf[c1] == 0) sbuf[c1] = 0x20;
			    switch(hwsiz3[n]) {
				case 1:  sprintf(sbuf+27, "%02X", getHwReg(i, hwsiz3[n]));  break;
				case 2:  sprintf(sbuf+27, "%04X", getHwReg(i, hwsiz3[n]));  break;
				case 4:  sprintf(sbuf+27, "%08lX", getHwReg(i, hwsiz3[n]));  break;
				}
			    prtoutStr(sbuf);
			    break;
			case 6:
			    if (n > 19) break;
			    setmem2(sbuf, 0x2020, 32);
			    i = hwadr4[n];	// 全都是 u_short 大小
			    sprintf(sbuf, "$1F80%04X %s ", i, hwrg4[n]);
			    for (c1=0;c1 < 64;c1++) if (sbuf[c1] == 0) sbuf[c1] = 0x20;
			    sprintf(sbuf+27, "%04X", getHwReg(i, 2));
			    prtoutStr(sbuf);
			    break;
			}
		    if (c2 < 3) VSync(0);   // 等待充足的時間才可以
		    n ++;
		    if (c1 == 0) break;
		    c1 --;
		    }
		y = cury;
		return;
		}
	if (p[0] == 'r') {
		p ++;
		if (p[0] == 'a') { regNo = 31;  p++; }  // = 'ra'
		else { readDec2(p, &n);  regNo = n; }	// 讀其編號
		}
	else	{	// 找其別名
		c1 = p[0];  c2 = p[1];
		for (n=0;n < 64;n += 2) {
			if (alias[n] == c1) {
				if (alias[n+1] == c2) {
					regNo = n >> 1;
					break;
					}
				}
			}
		}
	if (regNo == 0) return; 	// 零號暫存器是無法改變的
	if (regNo > 31) return; 	// 無效的暫存器編號
	dumpReg(regNo);
	p = skipSpace(p+2);
	if (p[0] == 0) return;		// 不設定新值
	readHex(p, &val);
	lp = (u_long *) (0xFC80 + regloc[regNo-1]);
	*lp = val;			// 設定新值
	sprintf(sbuf, ", New value = %08lX", val);
	grPrt(15, cury-1, NORMATTR, sbuf, &bg0);
	}
}
// --------------- 印出暫存器 ---------------
void dumpReg(short no)
{
u_long	*p;
char	*pc;
char	c1, c2, n;

if (no < 0) {	// dump all reg !
	no = 0;
	n = 2;
	do	{
		pc = sbuf;
		c1 = alias[n];	c2 = alias[n+1];
		p = (u_long *) (0xFC80 + regloc[no]);	 // 遊戲的暫存器區
		sprintf(pc, " %c%c = %08lX  ", c1, c2, p[0]);
		n += 2;  no ++;
		c1 = alias[n];	c2 = alias[n+1];
		p = (u_long *) (0xFC80 + regloc[no]);	 // 遊戲的暫存器區
		if (n < 64) sprintf(pc+16, "%c%c = %08lX  ", c1, c2, p[0]);
		n += 2;  no ++;
		c1 = alias[n];	c2 = alias[n+1];
		p = (u_long *) (0xFC80 + regloc[no]);	 // 遊戲的暫存器區
		if (n < 64) sprintf(pc+31, "%c%c = %08lX ", c1, c2, p[0]);
		n += 2;  no ++;
		prtoutStr(sbuf);		// 印出一行並換行
		} while (n < 64);
	}
else	{
	p = (u_long *) (0xFC80 + regloc[no-1]); 	// 遊戲的暫存器區
	no <<= 1;
	c1 = alias[no];  c2 = alias[no+1];
	sprintf(sbuf, " %c%c = %08lX", c1, c2, p[0]);
	prtoutStr(sbuf);		// 印出一行並換行
	}
y = cury;
}
// --------------- 秀出有變化的暫存器值 ---------------
void showChangedReg(void)
{
u_long	*pnew, *pold;
long	i, j, k, n;
char	c1, c2;

pnew = (u_long *) 0xFC80;   pold = (u_long *) 0xFD00;
n = 0;
sbuf[0] = 0x20;
for (i=1;i < 32;i ++) {
	j = regloc[i-1] >> 2;
	if (pold[j] != pnew[j]) {	// 暫存器值有變化
		curx = (n << 4) + 1 - n;	// = 1, 16, 31
		k= i << 1;   c1=alias[k];   c2=alias[k+1];
		sprintf(sbuf+curx, "%c%c = %08lX   ", c1, c2, pnew[j]);
		n ++;
		}
	if (n == 3) {
		prtoutStr(sbuf);
		n = 0;
		}
	}
if (n > 0) prtoutStr(sbuf);	// 印出最後一行
y = cury;
}
// --------------- 全字串轉為小寫 ---------------
void lowerStr(char *ps)
{
char	c;

while (*ps) {
	c = *ps ++;
	if ((c > 0x40) && (c < 0x5B)) c |= 0x20;
	};
}
// ------------ 印出一行並換行 ------------
void prtoutStr(char *str)
{
grPrt(1, cury, 0x10, str, &bg0);
cury ++;
if (cury > 24) {
	cury = 24;
	scrollupNline(1);	// 文字上捲一行
	}
}
// ------------ 分析剩餘參數並執行程式 ------------
void setToGo(char *p)
{
u_long	HwBp;

init_regs();		// 初始化各暫存器值
p = readHex(p, &goAddr);
p = skipSpace(p);
HwBp = 0xFF000000;	// 預設無效的硬體中斷點
if (p[0] == '=') {
	p = skipSpace(p+1);
	readHex(p, &HwBp);
	}
debugType = debHwBP;
if (goAddr == 0) {
	goAddr = getEPC();     // 取得正確的下一行指令位址
	if (hasTAR) {	// 要先執行延遲槽的未完成指令
		doUasm(goAddr, 1);	// 印出 goAddr 該行指令
		SetHwBP(goAddr+4);
		doExec(goAddr); 	// 跳到使用者指定的位址
		}
	goAddr = getEPC();	// 取得正確的下一行指令位址
	}
debugType = debNone;
if (HwBp != 0xFF000000) { SetHwBP(HwBp);  debugType = debHwBP; }
doExec(goAddr); 	// 跳到使用者指定的位址
}
// --------------- 看 CP0 的各個暫存器值 ---------------
void showCP0(void)
{
sprintf(sbuf, "BPC =%08lX, BDA  =%08lX, TAR =%08lX", _BPC, _BDA, _TAR);
prtoutStr(sbuf);
sprintf(sbuf, "DCIC=%08lX, BDAM =%08lX, BPCM=%08lX", _DCIC, _BDAM, _BPCM);
prtoutStr(sbuf);
sprintf(sbuf, "SR  =%08lX, CAUSE=%08lX, EPC =%08lX", _SR, _CAUSE, _EPC);
prtoutStr(sbuf);
y = cury;
}
// --------------- 分析剩餘參數並單步執行 ---------------
void stepOver(char *p)
{
u_long	n;

if (p[0] != 0) {
	lowerStr(p);		// 全字串轉為小寫
	readDec2(p, &n);
	}
if (n == 0) n = 1;	// 只執行一行, 最多執行 ?? 行
// 不能使用硬體 Trace 功能
do	{
	goAddr = getEPC();	// 取得正確的下一行指令位址
	doUasm(goAddr, 1);	// 印出 goAddr 該行指令
	bcopy((u_char *) 0xFC80, (u_char *) 0xFD00, 0x80);	// 保留執行前的暫存器值
	// !! 經實驗證明其硬體 Trace 功能並未實作, 因此不能使用硬體 Trace 功能
	debugType = debHwBP;
	// 若是 JAL/JALR 則設硬體斷點於 PC+8
	if (isJALs(goAddr)) SetHwBP(goAddr+8);
	// 若是 Branchs/J/JR/BREAK/SYCALL/其他一般指令, 則設硬體斷點於 PC+4
	else SetHwBP(goAddr+4);
	doExec(goAddr); 	// 跳到使用者指定的位址
	showChangedReg();	// 秀出有變化的暫存器值
	n --;
	} while (n);
}
// ------------------- 若是 JAL/JALR 則傳回 1 -------------------
char isJALs(u_long pa)
{
pa = *((u_long	*) pa);
if ((pa >> 26) == 3) return(1);
if ((pa & 0xFC1F07FF) == 9) return(1);
return(0);
}
