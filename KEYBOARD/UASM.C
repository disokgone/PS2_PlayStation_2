#include <sys/types.h>
#include <graphics.h>
#include <kernel.h>
#include <stdlib.h>
#include <strings.h>
#include "PSDebug.h"

extern char	_Major00[], _Major20[], _Unknown[], _NOPcmd[];
extern char	_Special[], _RegImm[], _COPzRs[], _CP0S[], _CP2S[];
extern u_char	_MjStyle[], _MjSt20[], _SpStyle[], _RIStyle[];
extern u_char	_CP0N[], _COPsty0[];
extern u_char	curx, cury, y;
char	alias[65] = "zoatv0v1a0a1a2a3t0t1t2t3t4t5t6t7s0s1s2s3s4s5s6s7t8t9k0k1gpspfpra";
char	*badCOP = "Co-Processor(Bad) ";

void chk_lz(void);	// 檢查 bit 21 to 25
void chk_mz(void);	// 檢查 bit 16 to 20
void chk_rz(void);	// 檢查 bit 11 to 15
void chk_zz(void);	// 檢查 bit 0 to 10
void doUasm(u_long addr, u_long nline); 	// 執行反組譯
void prt_base(void);	// print (rbase) (bit 25-21)
void prt_code(void);	// 印出 20-bit code 立即值
void prt_cop(void);	// 印出 25-bit CopFuncNum 立即值
void prt_imm16(void);	// 印出 16-bit 立即值
void prt_nn(void);	// 印出 10 進位暫存器編號
void prt_ofs16(void);	// 印出 16-bit 偏移值
void prt_rd(void);	// print rd (bit 15-11)
void prt_rn(u_short rn, char addcma);	// print by regNo
void prt_rs(void);	// print rs (bit 25-21)
void prt_rt(void);	// print rt (bit 20-16)
void prt_sc(void);	// 印出 10 進位旋轉次數
void prt_target(void);	// 印出 26-bit target 立即值
void scrollupNline(u_short n);		// 文字上捲 N 行 (in DEB.C)
u_long unAsm(u_long *pCode, char *dst);
// pCode = 欲反組譯的位址, dst = 放輸出字串的地方, !! 傳回值為可能有效作用位址

u_long	xcode, uAddr;
char	*pDisasm;
u_short ploc;
u_char	hasOpr, useAlias = 1, uAshowCh = 0;

// ------------ 執行反組譯 ------------
void doUasm(u_long addr, u_long nline)
{
u_long	*pc;
u_short i, j;

// if (nline == 0) nline = 21;
uAddr = addr;
for (i=0;i < nline;i ++) {
	pc = (u_long *) uAddr;
	setmem2(sbuf, 0x2020, 32);
	sprintf(sbuf, "$%08lX ", uAddr);
	unAsm(pc, sbuf+10);
	grPrt(1, cury, 0x10, sbuf, &bg0);
	if (uAshowCh) {
		pc = (u_long *) sbuf;	 pc[0] = xcode;    sbuf[4] = 0;
		grPrt(37, cury, 0x10, sbuf, &bg0);	// 秀出字元
		}
	else	{
		curx = 43;
		for (j=0;j < 4;j ++) {
			sprintf(sbuf, "%02X", xcode & 0xFF);
			grPrt(curx, cury, 0x10, sbuf, &bg0);	  // 秀出數值
			xcode >>= 8;
			curx -= 2;
			}
		}
	uAddr += 4;
	cury ++;
	if (cury > 24) {
		cury = 24;
		scrollupNline(1);	// 文字上捲一行
		}
	}
y = cury;
}
// ------------ 反組譯一行程式 ------------
u_long unAsm(u_long *pCode, char *dst)
{
u_short decode, opcode, i, j;
char	*p;

pDisasm = dst;
if (((long) pCode) & 3) {	// 位址未對齊
	p = (char *) pCode;
	hasOpr = p[0];	xcode = hasOpr;
	hasOpr = p[1];	xcode = (xcode << 8) | hasOpr;
	hasOpr = p[2];	xcode = (xcode << 8) | hasOpr;
	hasOpr = p[3];	xcode = (xcode << 8) | hasOpr;
	}
else xcode = *pCode;
hasOpr = 0;		// 前面未有 operator
opcode = xcode >> 26;
i = opcode << 3;
if (opcode > 0x13) {	// 是 COP3 以後的指令
	if (opcode < 0x20) {
		strcpy(dst, "???");
		decode = 0;
		}
	else	{
		bcopy(_Major20+i-0x100, dst, 8);	// 取得指令字串
		decode = _MjSt20[opcode - 0x20];	// 取得解碼方法
		}
	}
else	{
	p = _Major00 + i;
	decode = _MjStyle[opcode];
	if (p[0] == '.') {
		if (opcode) {	// This is RegImm = 1 !
			opcode = (xcode >> 16) & 0x1F;
			if (opcode & 0x0E) {	// bad code !
				p = _Unknown;
				decode = 0;
				}
			else	{
				if (opcode > 15) opcode -= 14;
				i = opcode << 3;
				p = _RegImm + i;
				decode = _RIStyle[opcode];
				}
			}
		else	{	// This is Special = 0 !
			opcode = xcode & 0x3F;
			i = opcode << 3;
			p = _Special + i;
			decode = _SpStyle[opcode];
			if (xcode == 0) {
				p = _NOPcmd;	// it's a NOP !
				decode = 0;
				}
			}
		}
	else	{	// 接下來過濾 cop 指令
		if ((opcode > 0x0F) && (opcode < 0x14)) {	// is COP !!
			if (xcode & 0x02000000) switch(opcode - 16) {
				case	0:	// COP0
					if ((xcode & 0x01FFFFE0) == 0) {
						i = xcode & 0x1F;
						if (i > 8) i = 9;
						i = _CP0N[i];
						if (i < 5) p = _CP0S + (i<<3);
						decode = 0;
						}
					break;
				case	2:	// COP2
					if ((xcode & 0xFF00FFFF) == 0x4A00FFFF) {
						i = (xcode >> 19) & 0x38;
						p = _CP2S + i;
						decode = 0;	// ps 沒用到, 暫不解碼
						}
					break;
				}
			else	{	// COPz command
				i = (xcode >> 19) & 0x38;	// >> 22 << 3
				if (i == 0x30) { p = _Unknown;	decode = 0; }
				else	{
					if ((i == 0x20) || (i == 0x28)) i += ((xcode >> 13) & 8);
					p = _COPzRs + i;
					decode = _COPsty0[i >> 3];
					}
				}
			}
		}
	bcopy(p, dst, 8);	// 取得指令字串
	}
// 依解碼方法解碼輸出
ploc = 8;	// 從 dst[8] 開始放解碼字串
decode >>= 2;
switch(decode) {
	case 0: // NONE = 不必再輸出
		dst[8] = 0;  break;
	case 1: // STDZ = rs, rt, rd, 0
		prt_rd();  prt_rs();  prt_rt();  break;
	case 2: // STZZ = rs, rt, 0, 0
		prt_rs();  prt_rt();  break;
	case 3: // STI16 = rs, rt, imm16
		prt_rt();  prt_rs();  prt_imm16();  break;
	case 4: // ZTI16 = 0, rt, imm16
		chk_lz();  prt_rt();  prt_imm16();  break;
	case 5: // STO16 = rs, rt, ofs16
		prt_rs();  prt_rt();  prt_ofs16();  break;
	case 6: // BTO16 = base, rt, ofs16 (base 如同 rs, ofs16 可當立即值印出)
		prt_rt();  prt_imm16();  prt_base();  break;
	case 7: // SZO16 = rs, 0, ofs16
		prt_rs();  chk_mz();  prt_ofs16();  break;
	case 8: // SCO16 = rs, condition, ofs16
		prt_rs();  prt_ofs16();  break;
	case 9: // CC20 = code 20 bits (bit 25-6)
		prt_code();  break;
	case 10: // TAR26 = 26 bits target (bit 25-0)
		prt_target();  break;
	case 11: // SZDZ = rs, 0, rd, 0
		prt_rs();  chk_mz();  prt_rd();  break;
	case 12: // SZZZ = rs, 0, 0, 0
		prt_rs();  chk_mz();  chk_rz();  break;
	case 13: // ZZDZ = 0, 0, rd, 0
		chk_lz();  chk_mz();  prt_rd();  break;
	case 14: // ZTDC = 0, rt, rd, shift_count
		chk_lz();  prt_rd();  prt_rt();  prt_sc();  break;
	case 15: // COPZ = CoProcessor function codes (bit 24-0)
		prt_cop();  break;
	case 16: // TDZZ = rt, rd, 0, 0 (currently not in use)
		prt_rt();  prt_rd();  chk_zz();  break;
	case 17: // BCO16 = 01000, 00000/1, ofs16
		prt_ofs16();  break;
	case 18: // TNZZ = cmd, rt, $nn, 0, 0
		prt_rt();  prt_nn();  chk_zz();  break;
	default: // undefined !
		break;
	}
pDisasm[ploc] = 0;
return(0);
}
// -------------- 檢查 bit 21 to 25 --------------
void chk_lz(void)
{
if (xcode & 0x03E00000) {
	strcpy(pDisasm+8, " bad bit 21-25");
	ploc = 23;
	}
}
// -------------- 檢查 bit 16 to 20 --------------
void chk_mz(void)
{
if (xcode & 0x1F0000) {
	strcpy(pDisasm+8, " bad bit 16-20");
	ploc = 23;
	}
}
// -------------- 檢查 bit 11 to 15 --------------
void chk_rz(void)
{
if (xcode & 0xF800) {
	strcpy(pDisasm+8, " bad bit 11-15");
	ploc = 23;
	}
}
// -------------- 檢查 bit 0 to 10 --------------
void chk_zz(void)
{
if (xcode & 0x07FF) {
	strcpy(pDisasm+8, " bad bit 0-10");
	ploc = 23;
	}
}
// -------------- 印出暫存器名稱 --------------
void prt_base(void)
{
prt_rn((xcode >> 21) & 31, 1);
}
// -------------- 印出 20-bit code 立即值 --------------
void prt_code(void)
{
char	*pdst;

pdst = pDisasm + ploc;
sprintf(pdst, "%05X", (xcode >> 6) & 0xFFFFF);
ploc += strlen(pdst);
}
// -------------- 印出 25-bit CopFuncNum 立即值 --------------
void prt_cop(void)
{
u_long	dest;
char	*pdst;

pdst = pDisasm + ploc;
dest = xcode & 0x1FFFFFF;
sprintf(pdst, "$%07lX", dest);
ploc += strlen(pdst);
}
// -------------- 印出 16-bit 立即值 --------------
void prt_imm16(void)
{
char	*pdst;

pdst = pDisasm + ploc;
if (hasOpr) { *pdst = ',';  pdst++;  ploc++;}   // 前面已有 operator
else hasOpr = 1;
sprintf(pdst, "%04X", xcode & 0xFFFF);
ploc += strlen(pdst);
}
// -------------- 印出 16-bit 偏移值 --------------
void prt_ofs16(void)
{
u_long	dest;
char	*pdst;

pdst = pDisasm + ploc;
dest = ((xcode & 0x7FFF) << 2);
if ((xcode & 0x8000) == 0x8000) {
	dest = (0x8000 - (xcode & 0x7FFF)) << 2;
	dest = uAddr + 4 - dest;
	}
else dest = uAddr + 4 + dest;
sprintf(pdst, ",$%08lX", dest);
ploc += strlen(pdst);
}
// -------------- 印出 10 進位暫存器編號 --------------
void prt_nn(void)
{
char	*pdst;

pdst = pDisasm + ploc;
if (hasOpr) { *pdst = ',';  pdst++;  ploc++;}   // 前面已有 operator
else hasOpr = 1;
sprintf(pdst, "$%02d", (xcode >> 11) & 31);     // 目的 CoProcessor 暫存器編號
ploc += strlen(pdst);
pDisasm[3] = 0x30 + ((xcode >> 26) & 3);	// 目的 CoProcessor 編號
}
// -------------- 印出暫存器名稱 --------------
void prt_rd(void)
{
prt_rn((xcode >> 11) & 31, 0);
}
// -------------- 印出暫存器名稱 --------------
void prt_rs(void)
{
prt_rn((xcode >> 21) & 31, 0);
}
// -------------- 印出暫存器名稱 --------------
void prt_rt(void)
{
prt_rn((xcode >> 16) & 31, 0);
}
// -------------- 印出暫存器名稱 --------------
void prt_rn(u_short rn, char addcma)
{
short	i;
char	*pdst;

pdst = pDisasm + ploc;
if ((addcma == 0) && (hasOpr)) { *pdst = ',';  pdst++;  ploc++;} // 前面已有 operator
else hasOpr = 1;
if (useAlias) { 	// 以暫存器別名印出
	rn <<= 1;
	i = 0;
	if (addcma) { pdst[i] = '(';  i++; }
	pdst[i] = alias[rn];
	pdst[i+1] = alias[rn+1];
	if (addcma) pdst[i+2] = ')';
	ploc += 2;
	}
else	{		// 以暫存器編號印出
	if (addcma) sprintf(pdst, "(r%02d)", rn);
	else sprintf(pdst, "r%02d", rn);
	ploc += 3;
	}
if (addcma) ploc += 2;
}
// -------------- 印出 10 進位旋轉次數 --------------
void prt_sc(void)
{
char	*pdst;

pdst = pDisasm + ploc;
if (hasOpr) { *pdst = ',';  pdst++;  ploc++;}   // 前面已有 operator
else hasOpr = 1;
sprintf(pdst, "%02d", xcode & 31);              // 旋轉次數
ploc += strlen(pdst);
}
// -------------- 印出 26-bit target 立即值 --------------
void prt_target(void)
{
u_long	dest;
char	*pdst;

pdst = pDisasm + ploc;
dest = uAddr & 0xF0000000;
dest += ((xcode & 0x3FFFFFF) << 2);
sprintf(pdst, "$%08lX", dest);
ploc += strlen(pdst);
}
