#include <WINDOWS.H>
#define INMIPS_C
#include "MIPS.h"

#define UNKNOWN 1	// 未知的指令
#define NOTIMPL 2	// 此 MIPS 等級不支援的指令
#define BAD0005 0x04	// bad bits in bit  0- 5
#define BAD0610 0x08	// bad bits in bit  6-10
#define BAD1115 0x10	// bad bits in bit 11-15
#define BAD1620 0x20	// bad bits in bit 16-20
#define BAD2125 0x40	// bad bits in bit 21-25
#define BADPTR	0x80	// 傳來的指標不良

#define V0005	1
#define V0610	2
#define V1115	4
#define V1620	8
#define V2125	16

#define RD	1
#define RS	2
#define RT	3
#define SHCNT	4
#define OFS16	5
#define IMM16	6
#define TAR26	7
#define FUN26	8
#define FS	9	    // COPn reg RD (=FPU:fs)
#define FT	10	    // COPn reg RT (=FPU:ft)
#define BASE16	11
#define FR	12	    // COPn reg RS (=FPU:fr)
#define FD	13	    // FPU:fd

typedef unsigned long	DWORD;

DWORD	code32; 		// 32 位元指令
DWORD	NOWPC;		    // 目前此行的位址值
WORD	HIGH16, LOW16;	// 32 位元指令的高與低 16 位元
char	*outstr;		// 輸出用的字串
char	tempbuf[32];	// only for temporatory output !
char	INSTRLEN = 10;	// 指令欄的空間 (含空白)
char	MIPS_LEVEL = 4; // 目前反組譯的等級為 MIPS LEVEL 1-4
char	USEALIAS = 1;	// CPU 暫存器名稱 (非零值=使用別名, 0=使用Rnn)
char	UPPERCA = 0;	// 輸出字串大小寫 (非零值=大寫, 0=小寫)
char	errorCode;		// 反組譯錯誤碼
char	hasOperand;		// 前方已有操作子

void _fastcall AsmOptions(struct ASMOPT *uaopt);
char _fastcall DisAsmMIPS(void *buf, char *str);  // 反組譯一行指令
// 反組譯位於 *buf 的 MIPS 程式碼到 *str 字串中, 傳回 0 為 OK, 非零值為錯誤碼
char *_fastcall GetUAerror(char n);	// 取得錯誤字串

void SPECIAL(void);	// 反組譯 SPECIAL group
void REGIMM(void);	// 反組譯 REGIMM group
void CP0(void); 	// 反組譯 CP0 group
void CP1(void); 	// 反組譯 CP1 group
void CP2(void); 	// 反組譯 CP2 group
void CP3(void); 	// 反組譯 CP3 group
void MIPS3(void);   // 反組譯 MIPS level 3 group
// ------------- 以下為 FPU Subroutines -------------
int FBC1XX(void);   // FPU: BCxx
void FMOVX(void);   // FPU: MOVF/MOVT
int FMTGRP(void);   // 須注意 fmt 欄位者
int FPU4(void);     // 7 個 MIPS4 的特殊指令
void ShowCC(int cc);	// display ccc bit count
void showFD(void);  // 印出 FPU 暫存器名稱 (fd)
void showFR(void);  // 印出 FPU 暫存器名稱 (fr)
void showIns2(char **xstr, int num, char *sfmt);    // 印出 xstr[num] 字串
// ------------- 以上為 FPU Subroutines -------------

char checkNotZero(char pattern);	// 檢查某些位元, 若不為零則返回非零值
void showBASE16(void);	// 印出 (OFS16)RB
void showFUN26(void);	// 印出 coprocessor function codes (26 bit)
void showIMM16(void);	// 印出 16 bit immediate value
void showIns(char **xstr, int num);	// 印出 xstr[num] 字串
void showOFS16(void);	// 印出 NOWPC + 8 + ((signed) ofs16 << 2)
void showR3(int r1, int r2, int r3);	// 印出 3 暫存器名稱 (r1, r2, r3)
void showRD(void);	// 印出暫存器名稱 (rd)
void showFS(void);	// 印出暫存器名稱 (fs)
void showRS(void);	// 印出暫存器名稱 (rs)
void showRT(void);	// 印出暫存器名稱 (rt)
void showFT(void);	// 印出暫存器名稱 (rt)
void showSHCNT(void);	// 印出旋轉位元數 (十進位)
void showTAR26(void);	// 印出目的位址
void showTypes(int typ);	// 依所給型式印出操作子
void xtputs(char *s);	// 把字串 s 接到 outstr 之後
char *errStr[8] = { "未知的指令", "此 MIPS 等級不支援", "bad bits 0-5",
	"bad bits 6-10", "bad bits 11-15", "bad bits 16-20",
	"bad bits 21-25", "傳來的指標不良" };

// =============
enum ONEINSSTR { J, JAL, BEQ, BNE, BLEZ, BGTZ, ADDI, ADDIU, SLTI, SLTIU,
		ANDI, ORI, XORI, LUI, BEQL, BNEL, BLEZL, BGTZL, DADDI,
		DADDIU, L16, LDL, LDR, LB, LH, LWL, LW, LBU, LHU, LWR, LWU,
		S16, SB, SH, SWL, SW, SDL, SDR, SWR, CACHE, LL, PREF, LWC1,
		LWC2, LWC3, LLD, LDC1, LDC2, LD, SC, SWC1, SWC2, SWC3,
		SCD, SDC1, SDC2, SD, ONEINSSIZE};

char	*oneIns[ONEINSSIZE] = { "j", "jal", "beq", "bne", "blez", "bgtz",
		"addi", "addiu", "slti", "sltiu", "andi", "ori", "xori",
		"lui", "beql", "bnel", "blezl", "bgtzl", "daddi", "daddiu",
		"l16", "ldl", "ldr", "lb", "lh", "lwl", "lw", "lbu", "lhu", "lwr",
		"lwu", "s16", "sb", "sh", "swl", "sw", "sdl", "sdr", "swr", "cache",
		"ll", "pref", "lwc1", "lwc2", "lwc3", "lld", "ldc1", "ldc2",
		"ld", "sc", "swc1", "swc2", "swc3", "scd", "sdc1", "sdc2", "sd" };


char	*CPUalias[32] = { "zero", "at", "v0", "v1", "a0", "a1", "a2", "a3"
		, "t0", "t1", "t2", "t3", "t4", "t5", "t6", "t7"
		, "s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7", "t8", "t9"
		, "k0", "k1", "gp", "sp", "fp", "ra" };
char	COMMA[3] = ", ";

enum SINGLESTR { JR, JALR, SYNC, TLBR, TLBW, TLBWR, TLBP, RFE, ERET,
	WAIT, MFC0, DMFC0, MTC0, DMTC0, BC0F, BC0T, COP0, MFC1, DMFC1,
	CFC1, MTC1, DMTC1, CTC1, COP1, MFC2, MTC2, COP2,
	MFC3, MTC3, COP3, MUL, MAD, MADU, MSUB, MSUBU, NOP, CALCX, SIGNLESIZE};

char *single[SIGNLESIZE] = { "jr", "jalr", "sync", "tlbr", "tlbw", "tlbwr",
	"tlbp", "rfe", "eret", "wait", "mfc0", "dmfc0", "mtc0", "dmtc0",
	"bc0f", "bc0t", "cop0", "mfc1", "dmfc1", "cfc1", "mtc1", "dmtc1",
	"ctc1", "cop1", "mfc2", "mtc2", "cop2", "mfc3",
	"mtc3", "cop3", "mul", "mad", "madu", "msub", "msubu", "nop", "calcX" };

char *str00[4] = { "sll", "", "srl", "sra" };
char *str01[4] = { "sllv", "", "srlv", "srav" };
char *str02[2] = { "movz", "movn" };
char *str03[2] = { "syscall", "break" };
char *str041[2] = { "mthi", "mtlo" };
char *str042[2] = { "mfhi", "mflo" };
char *str05[4] = { "dsllv", "", "dsrlv", "dsrav" };
char *str06[4] = { "mult", "multu", "div", "divu" };
char *str07[4] = { "dmult", "dmultu", "ddiv", "ddivu" };
char *str08[4] = { "add", "addu", "sub", "subu" };
char *str09[4] = { "and", "or", "xor", "nor" };
char *str10[2] = { "slt", "sltu" };
char *str11[4] = { "dadd", "daddu", "dsub", "dsubu" };
char *str12[4] = { "tge", "tgeu", "tlt", "tltu" };
char *str13[2] = { "teq", "tne" };
char *str14[4] = { "dsll", "", "dsrl", "dsra" };
char *str15[4] = { "dsll32", "", "dsrl32", "dsra32" };

char *strr0[4] = { "bltz", "bgez", "bltzl", "bgezl" };
char *strr2[4] = { "tgei", "tgeiu", "tlti", "tltiu" };
char *strr3[2] = { "teqi", "tnei" };
char *strr4[4] = { "bltzal", "bgezal", "bltzall", "bgezall" };

// ---------------------- 以下為 FPU 解碼段落 --------------------------------
enum FSINGLESTR { MOVF, MOVT, MOVZ, MOVN, RECIP, RSQRT, LWXC1, SWXC1, LDXC1,
	SDXC1, PREFX, CVT, FSIGNLESIZE};
char *fsingle[FSIGNLESIZE] = { "movf", "movt", "movz", "movn", "recip", "rsqrt",
	"lwxc1", "swxc1", "ldxc1", "sdxc1", "prefx", "cvt" };
char *bcxx[4] = { "bc1f", "bc1t", "bc1fl", "bc1tl" };
char *cond4[16] = { "f", "un", "eq", "ueq", "olt", "ult", "ole", "ule",
	"sf", "ngle", "seq", "ngl", "lt", "nge", "le", "ngt" }; // FPU: C.cond4.fmt
char *fadd[4] = { "add", "sub", "mul", "div" };
char *fmadd[4] = { "madd", "msub", "nmadd", "nmsub" };
char *fmts[4] = { ".s", ".d", ".w", ".l" };
char *fround[4] = { "round", "trunc", "ceil", "floor" };
char *fsqrt[4] = { "sqrt", "abs", "mov", "neg" };
// ---------------------- 以上為 FPU 解碼段落 --------------------------------

// ============= 反組譯選項 =============
void _fastcall AsmOptions(struct ASMOPT *uaopt)
{
INSTRLEN = uaopt->colLength;
MIPS_LEVEL = uaopt->mipsLevel;
USEALIAS = uaopt->useAlias;
UPPERCA = uaopt->charCase;
}

// ============= 反組譯一行 =============
char _fastcall DisAsmMIPS(void *buf, char *str)
{	// ============= 請參閱 MIPS_R5S.DOC MIPS_R5K.DOC =============
if ((buf == NULL) || (str == NULL)) {
	errorCode = BADPTR;	// 傳來的指標不良
	return(errorCode);
	}
code32 = *((DWORD *) buf);	// 先一次取得 32 位元指令
outstr = str;
*str = 0;			// clear string to NULL
LOW16 = *((WORD *) buf);	// 低 16 位元
HIGH16 = *((WORD *) buf+1);	// 高 16 位元
errorCode = 0;			// 傳回 0 為 OK
hasOperand = 0; 		// No operand at first

switch(HIGH16 >> 10) {	// bit 31-26
	case 0:  SPECIAL();	break;
	case 1:  REGIMM();	break;
	case 2:  showIns(oneIns, J);		// 顯示指令字串
		 showR3(TAR26, 0, 0);  break;	// 顯示 oprands
	case 3:  showIns(oneIns, JAL);
		 showR3(TAR26, 0, 0);  break;
	case 4:  showIns(oneIns, BEQ);
		 showR3(RS, RT, OFS16);  break;
	case 5:  showIns(oneIns, BNE);
		 showR3(RS, RT, OFS16);  break;
	case 6:  if (checkNotZero(V1620)) break;
		 showIns(oneIns, BLEZ);
		 showR3(RS, OFS16, 0);	break;
	case 7:  if (checkNotZero(V1620)) break;
		 showIns(oneIns, BGTZ);
		 showR3(RS, OFS16, 0);	break;
	case 8:  showIns(oneIns, ADDI);
		 showR3(RT, RS, IMM16);  break;
	case 9:  showIns(oneIns, ADDIU);
		 showR3(RT, RS, IMM16);  break;
	case 10: showIns(oneIns, SLTI);
		 showR3(RT, RS, IMM16);  break;
	case 11: showIns(oneIns, SLTIU);
		 showR3(RT, RS, IMM16);  break;
	case 12: showIns(oneIns, ANDI);
		 showR3(RT, RS, IMM16);  break;
	case 13: showIns(oneIns, ORI);
		 showR3(RT, RS, IMM16);  break;
	case 14: showIns(oneIns, XORI);
		 showR3(RT, RS, IMM16);  break;
	case 15: if (checkNotZero(V2125)) break;
		 showIns(oneIns, LUI);
		 showR3(RT, IMM16, 0);	break;
	case 16: CP0();     break;
	case 17: CP1();     break;
	case 18: CP2();     break;
	case 19: CP3();     break;
	case 20: showIns(oneIns, BEQL);
		 showR3(RS, RT, OFS16);  break;
	case 21: showIns(oneIns, BNEL);
		 showR3(RS, RT, OFS16);  break;
	case 22: showIns(oneIns, BLEZL);
		 showR3(RS, 0, OFS16);	break;
	case 23: showIns(oneIns, BGTZL);
		 showR3(RS, 0, OFS16);	break;
	case 24: showIns(oneIns, DADDI);
		 showR3(RS, RT, IMM16);  break;
	case 25: showIns(oneIns, DADDIU);
		 showR3(RS, RT, IMM16);  break;
	case 26: showIns(oneIns, LDL);
		 showR3(RT, BASE16, 0);  break;
	case 27: showIns(oneIns, LDR);
		 showR3(RT, BASE16, 0);  break;
	case 28: MIPS3();  break;
    case 30: showIns(oneIns, L16);
		 showR3(RT, BASE16, 0);  break;
    case 31: showIns(oneIns, S16);
		 showR3(RT, BASE16, 0);  break;
	case 32: showIns(oneIns, LB);
		 showR3(RT, BASE16, 0);  break;
	case 33: showIns(oneIns, LH);
		 showR3(RT, BASE16, 0);  break;
	case 34: showIns(oneIns, LWL);
		 showR3(RT, BASE16, 0);  break;
	case 35: showIns(oneIns, LW);
		 showR3(RT, BASE16, 0);  break;
	case 36: showIns(oneIns, LBU);
		 showR3(RT, BASE16, 0);  break;
	case 37: showIns(oneIns, LHU);
		 showR3(RT, BASE16, 0);  break;
	case 38: showIns(oneIns, LWR);
		 showR3(RT, BASE16, 0);  break;
	case 39: showIns(oneIns, LWU);
		 showR3(RT, BASE16, 0);  break;
	case 40: showIns(oneIns, SB);
		 showR3(RT, BASE16, 0);  break;
	case 41: showIns(oneIns, SH);
		 showR3(RT, BASE16, 0);  break;
	case 42: showIns(oneIns, SWL);
		 showR3(RT, BASE16, 0);  break;
	case 43: showIns(oneIns, SW);
		 showR3(RT, BASE16, 0);  break;
	case 44: showIns(oneIns, SDL);
		 showR3(RT, BASE16, 0);  break;
	case 45: showIns(oneIns, SDR);
		 showR3(RT, BASE16, 0);  break;
	case 46: showIns(oneIns, SWR);
		 showR3(RT, BASE16, 0);  break;
	case 47: showIns(oneIns, CACHE);
		 showR3(FT, BASE16, 0);  break;
	case 48: showIns(oneIns, LL);
		 showR3(RT, BASE16, 0);  break;
	case 49: showIns(oneIns, LWC1);
		 showR3(FT, BASE16, 0);  break;
	case 50: showIns(oneIns, LWC2);
		 showR3(FT, BASE16, 0);  break;
	case 51: if (MIPS_LEVEL > 3) {
			showIns(oneIns, PREF);
			showR3(FT, BASE16, 0);	break;
			}
		 showIns(oneIns, LWC3);
		 showR3(RT, BASE16, 0);  break;
	case 52: showIns(oneIns, LLD);
		 showR3(RT, BASE16, 0);  break;
	case 53: showIns(oneIns, LDC1);
		 showR3(FT, BASE16, 0);  break;
	case 54: showIns(oneIns, LDC2);
		 showR3(FT, BASE16, 0);  break;
	case 55: showIns(oneIns, LD);
		 showR3(RT, BASE16, 0);  break;
	case 56: showIns(oneIns, SC);
		 showR3(RT, BASE16, 0);  break;
	case 57: showIns(oneIns, SWC1);
		 showR3(FT, BASE16, 0);  break;
	case 58: showIns(oneIns, SWC2);
		 showR3(FT, BASE16, 0);  break;
	case 59: showIns(oneIns, SWC3);
		 showR3(FT, BASE16, 0);  break;
	case 60: showIns(oneIns, SCD);
		 showR3(RT, BASE16, 0);  break;
	case 61: showIns(oneIns, SDC1);
		 showR3(FT, BASE16, 0);  break;
	case 62: showIns(oneIns, SDC2);
		 showR3(FT, BASE16, 0);  break;
	case 63: showIns(oneIns, SD);
		 showR3(RT, BASE16, 0);  break;
	}

if (UPPERCA) AnsiUpper(str);	// 要轉為大寫
if ((*outstr == 0) && (errorCode == 0)) errorCode = UNKNOWN;	// 未知的指令
NOWPC += 4;

return(errorCode);
}

// =============== 取得錯誤字串 ===============
char *_fastcall GetUAerror(char n)
{
short	i, j;

i = 1;	    j = 0;
if (n == 0) return(errStr[0]);
do  {
    if (n & i) return(errStr[j]);
    i <<= 1;	j ++;
    } while (i < 0x100);
return(NULL);
}

// =============== 反組譯 SPECIAL group ===============
void SPECIAL(void)
{	// 為了要求通用性與嚴謹度, 程式會繁瑣些
switch((LOW16 >> 2) & 15) {	// check bit 5-0
	case 0:
	if ((LOW16 & 0x7FF) == 1) { FMOVX();  break; }	// FPU: MOVF/MOVT
		if (code32 == 0) { showIns(single, NOP);  break; }
		if ((LOW16 & 3) == 1) { errorCode = UNKNOWN;  break; }
		if (checkNotZero(V2125)) break;
		showIns(str00, LOW16 & 3);	// 顯示指令字串
		showR3(RD, RT, SHCNT);	break;	// 顯示 oprands
	case 1:
		if ((LOW16 & 3) == 1) { errorCode = UNKNOWN;  break; }
		if (checkNotZero(V0610)) break;
		showIns(str01, LOW16 & 3);	// 顯示指令字串
		showR3(RD, RT, RS);  break;	// 顯示 oprands
	case 2:
		switch (LOW16 & 3) {
			case 0:
			  if (checkNotZero(V1620 | V1115 | V0610)) break;
			  showIns(single, JR);
			  showR3(RS, 0, 0);  break;	// 顯示 oprands

			case 1:
			  if (checkNotZero(V1620 | V0610)) break;
			  showIns(single, JALR);
			  showR3(RD, RS, 0);  break;	// 顯示 oprands

			default:
			  if (checkNotZero(V0610)) break;
			  showIns(str02, LOW16 & 1);	// 顯示指令字串
			  showR3(RD, RS, RT);  break;	// 顯示 oprands
			}  break;
	case 3:
		if (LOW16 & 2) {
			if ((LOW16 & 1) == 0) { errorCode = UNKNOWN;  break; }
			if (checkNotZero(V2125 | V1620 | V1115)) break;
			showIns(single, SYNC);
			showSHCNT();  break;
			}
		showIns(str03, LOW16 & 1);    // 顯示指令字串
		if (hasOperand) xtputs(COMMA);
		wsprintf(tempbuf, "$%05lX", (code32 >> 6) & 0xFFFFF);
		xtputs(tempbuf);  hasOperand = 1;  break;
	case 4:
		if (checkNotZero(V0610 | V1620)) break;
		if ((LOW16 & 1) == 0) {
			if (checkNotZero(V1115)) break;
			showIns(str041, (LOW16 & 2) >> 1);	// 顯示指令字串
			showR3(RS, 0, 0);  break;	// 顯示 oprands
			}
		if (checkNotZero(V2125)) break;
		showIns(str042, (LOW16 & 2) >> 1);	// 顯示指令字串
		showR3(RD, 0, 0);  break;	// 顯示 oprands
	case 5:
		if ((LOW16 & 3) == 1) { errorCode = UNKNOWN;  break; }
		if (checkNotZero(V0610)) break;
		showIns(str05, LOW16 & 3);	// 顯示指令字串
		showR3(RD, RT, RS);  break;	// 顯示 oprands
	case 6:
		if (checkNotZero(V0610 | V1115)) break;
		showIns(str06, LOW16 & 3);	// 顯示指令字串
		showR3(RS, RT, 0);  break;	// 顯示 oprands
	case 7:
		if (checkNotZero(V0610 | V1115)) break;
		showIns(str07, LOW16 & 3);	// 顯示指令字串
		showR3(RS, RT, 0);  break;	// 顯示 oprands
	case 8:
		if (checkNotZero(V0610)) break;
		showIns(str08, LOW16 & 3);	// 顯示指令字串
		showR3(RD, RS, RT);  break;	// 顯示 oprands
	case 9:
		if (checkNotZero(V0610)) break;
		showIns(str09, LOW16 & 3);	// 顯示指令字串
		showR3(RD, RS, RT);  break;	// 顯示 oprands
	case 10:
		if ((LOW16 & 2) == 0) { errorCode = UNKNOWN;  break; }
		if (checkNotZero(V0610)) break;
		showIns(str10, LOW16 & 1);	// 顯示指令字串
		showR3(RD, RS, RT);  break;	// 顯示 oprands
	case 11:
		if (checkNotZero(V0610)) break;
		showIns(str11, LOW16 & 3);	// 顯示指令字串
		showR3(RD, RS, RT);  break;	// 顯示 oprands
	case 12:
		showIns(str12, LOW16 & 3);	// 顯示指令字串
		showR3(RS, RT, 0);		// 顯示 oprands
		wsprintf(tempbuf, ", ($%03X)", LOW16 >> 6);  xtputs(tempbuf);
		break;
	case 13:
		if (LOW16 & 1) { errorCode = UNKNOWN;  break; }
		showIns(str13, (LOW16 & 2) >> 1);	// 顯示指令字串
		showR3(RS, RT, 0);		// 顯示 oprands
		wsprintf(tempbuf, ", ($%03X)", LOW16 >> 6);  xtputs(tempbuf);
		break;
	case 14:
		if ((LOW16 & 3) == 1) { errorCode = UNKNOWN;  break; }
		if (checkNotZero(V2125)) break;
		showIns(str14, LOW16 & 3);	// 顯示指令字串
		showR3(RD, RT, SHCNT);	break;	// 顯示 oprands
	case 15:
		if ((LOW16 & 3) == 1) { errorCode = UNKNOWN;  break; }
		if (checkNotZero(V2125)) break;
		showIns(str15, LOW16 & 3);	// 顯示指令字串
		showR3(RD, RT, SHCNT);	break;	// 顯示 oprands
	}
}

void REGIMM(void)
{
int	n;

n = HIGH16 & 3;
switch((HIGH16 >> 2) & 7) {	    // check bit 20-18
	case 0:
		showIns(strr0, n);		// 顯示指令字串
		showR3(RS, OFS16, 0);  break;	// 顯示 oprands
	case 2:
		showIns(strr2, n);		// 顯示指令字串
		showR3(RS, IMM16, 0);  break;	// 顯示 oprands
	case 3:
		if (n & 1) { errorCode = UNKNOWN;  break; }
		showIns(strr3, n >> 1); 	// 顯示指令字串
		showR3(RS, IMM16, 0);  break;	// 顯示 oprands
	case 4:
		showIns(strr4, n);		// 顯示指令字串
		showR3(RS, OFS16, 0);  break;	// 顯示 oprands
	}
}

void CP0(void)
{
int	ok;

ok = 1;
if (HIGH16 & 0x0200) {
	if (HIGH16 & 0x01E0) ok = 0;
	if (checkNotZero(V0610 | V1115 | V1620)) ok = 0;
	if (ok) switch(LOW16 & 0x3F) {
		case 1: showIns(single, TLBR);	break;
		case 2: showIns(single, TLBW);	break;
		case 6: showIns(single, TLBWR);  break;
		case 8: showIns(single, TLBP);	break;
		case 16: showIns(single, RFE);	break;
		case 24: showIns(single, ERET);  break;
		case 32: showIns(single, WAIT);  break;
		default: ok = 0;
		}
	}
if (checkNotZero(V0005 | V0610)) ok = 0;
if (ok) switch((HIGH16 >> 5) & 0x1F) {
	case 0: showIns(single, MFC0);
		showR3(RT, FS, 0);  break;
	case 1: showIns(single, DMFC0);
		showR3(RT, FS, 0);  break;
	case 4: showIns(single, MTC0);
		showR3(RT, FS, 0);  break;
	case 5: showIns(single, DMTC0);
		showR3(RT, FS, 0);  break;
	case 8: switch(HIGH16 & 0x1F) {
		  case 0: showIns(single, BC0F);
			  showR3(OFS16, 0, 0);	break;
		  case 1: showIns(single, BC0T);
			  showR3(OFS16, 0, 0);	break;
		  }
	default: ok = 0;
	}

if (!ok) {
	showIns(single, COP0);
	showR3(FUN26, 0, 0);
	}
}

void CP1(void)
{
int	ok;

ok = 0;
if ((LOW16 & 0x07FF) == 0) {
    ok = 1;
	switch((HIGH16 >> 5) & 0x1F) {
		case 0: showIns(single, MFC1);
			showR3(RT, FS, 0);  break;
		case 1: showIns(single, DMFC1);
			showR3(RT, FS, 0);  break;
		case 2: showIns(single, CFC1);
			showR3(RT, FS, 0);  break;
		case 4: showIns(single, MTC1);
			showR3(RT, FS, 0);  break;
		case 5: showIns(single, DMTC1);
			showR3(RT, FS, 0);  break;
		case 6: showIns(single, CTC1);
			showR3(RT, FS, 0);  break;
	default: ok = 0;
		}
	}

if (!ok) switch((HIGH16 >> 5) & 0x1F) {
    case 8:
	if ((HIGH16 & 0x1F) < 2) {
	    showIns(bcxx, HIGH16 & 1);
	    showR3(OFS16, 0, 0);    ok = 1;
	    }
	else ok = FBC1XX();
	break;
    default: ok = FMTGRP();
    }

if (!ok) {
	showIns(single, COP1);
	showR3(FUN26, 0, 0);
	}
}

void CP2(void)
{
int	ok;

ok = 1;
if (checkNotZero(V0005 | V0610)) ok = 0;
if (ok) switch((HIGH16 >> 5) & 0x1F) {
	case 0: showIns(single, MFC2);
		showR3(RT, FS, 0);  break;
	case 4: showIns(single, MTC2);
		showR3(RT, FS, 0);  break;
	default: ok = 0;  break;
	}

if (!ok) {
    errorCode = 0;	// 假設是 Cop2 便算了
	showIns(single, COP2);
	showR3(FUN26, 0, 0);
	}
}

void CP3(void)
{
int	ok;

ok = 1;
if (FPU4()) return;	// 已確定為 FPU 指令則返回
if (checkNotZero(V0005 | V0610)) ok = 0;
if (ok) switch((HIGH16 >> 5) & 0x1F) {
	case 0: showIns(single, MFC3);
		showR3(RT, FS, 0);  break;
	case 4: showIns(single, MTC3);
		showR3(RT, FS, 0);  break;
	default: ok = 0;  break;
	}

if (!ok) {
	showIns(single, COP3);
	showR3(FUN26, 0, 0);
	}
}

void MIPS3(void)
{
if ((LOW16 & 0x3F) == 0x28) {	// is CALCX rd, rs, rt (oprX) ** New in PS2 **
	showIns(single, CALCX);
	showR3(RD, RS, RT);
    wsprintf(tempbuf, ", X=%d", (LOW16 >> 6) & 31);
    xtputs(tempbuf);
    return;
    }
if (checkNotZero(V0610)) return;
if ((LOW16 & 0x3F) == 2) {
	showIns(single, MUL);
	showR3(RD, RS, RT);
	return;
	}

if (checkNotZero(V1115)) return;
switch(LOW16 & 0x3F) {
	case 0: showIns(single, MAD);
		showR3(RS, RT, 0);  break;
	case 1: showIns(single, MADU);
		showR3(RS, RT, 0);  break;
	case 4: showIns(single, MSUB);
		showR3(RS, RT, 0);  break;
	case 5: showIns(single, MSUBU);
		showR3(RS, RT, 0);  break;
	}
}
// ============= 在指令與操作子間填入規定數量的空白字元 =============
void addSpace(void)
{
int	i, l;

l = strlen(outstr);
if (l > INSTRLEN) return;
for (i=0;i < INSTRLEN-l;i ++) outstr[i+l] = ' ';        // 需填字元數
outstr[INSTRLEN] = 0;
}

// ============= 檢查某些位元, 若不為零則返回非零值 =============
char checkNotZero(char pattern)
{
if (pattern & V0005) if (LOW16 & 0x003F) errorCode |= BAD0005;
if (pattern & V0610) if (LOW16 & 0x07C0) errorCode |= BAD0610;
if (pattern & V1115) if (LOW16 & 0xF800) errorCode |= BAD1115;
if (pattern & V1620) if (HIGH16 & 0x001F) errorCode |= BAD1620;
if (pattern & V2125) if (HIGH16 & 0x03E0) errorCode |= BAD2125;
return(errorCode);
}

// ============= 印出 (OFS16)RB =============
void showBASE16(void)
{	// 16 bit signed offset
int	rb;

if (hasOperand) xtputs(COMMA);
if (LOW16 < 0x8000) wsprintf(tempbuf, "$%04X", LOW16);
else wsprintf(tempbuf, "-$%04X", 0x10000 - (LOW16 & 0xFFFF));
xtputs(tempbuf);
rb = (HIGH16 >> 5) & 31;
if (USEALIAS) wsprintf(tempbuf, "(%s)", CPUalias[rb]);
else wsprintf(tempbuf, "(r%d)", rb);
xtputs(tempbuf);
hasOperand = 1;
}

// ============= 印出 coprocessor function codes (26 bit) =============
void showFUN26(void)
{	// 26 bit 副處理機命令
if (hasOperand) xtputs(COMMA);
wsprintf(tempbuf, "$%07lX", code32 & 0x03FFFFFF);
xtputs(tempbuf);
hasOperand = 1;
}

// ============= 印出 16 bit immediate value =============
void showIMM16(void)
{
if (hasOperand) xtputs(COMMA);
wsprintf(tempbuf, "$%04X", LOW16);  xtputs(tempbuf);
hasOperand = 1;
}

// ============= 印出 xstr[num] 字串 =============
void showIns(char **xstr, int num)
{
if (num < 0) num = 0;
xtputs(xstr[num]);
addSpace();
}

// ============= 印出 NOWPC + 8 + ((signed) ofs16 << 2) =============
void showOFS16(void)
{
long	dest;

if (hasOperand) xtputs(COMMA);
dest = ((short int) LOW16 << 2) + NOWPC + 4;
wsprintf(tempbuf, "$%08lX", dest);  xtputs(tempbuf);
hasOperand = 1;
}

// ============= 印出 3 暫存器名稱 (r1, r2, r3) =============
void showR3(int r1, int r2, int r3)
{
showTypes(r1);
showTypes(r2);
showTypes(r3);
}

// ============= 印出暫存器名稱 (fs) =============
void showFS(void)
{	// fs 為 bit 15-11 的 5 bits
int	fs;

if (hasOperand) xtputs(COMMA);
fs = LOW16 >> 11;
wsprintf(tempbuf, "#%d", fs);  xtputs(tempbuf);     // FPU ot COPx general regNo
hasOperand = 1;
}

// ============= 印出暫存器名稱 (rd) =============
void showRD(void)
{	// rd 為 bit 15-11 的 5 bits
int	rd;

if (hasOperand) xtputs(COMMA);
rd = LOW16 >> 11;
if (USEALIAS) xtputs(CPUalias[rd]);
else { wsprintf(tempbuf, "r%d", rd);  xtputs(tempbuf); }
hasOperand = 1;
}

// ============= 印出暫存器名稱 (rs) =============
void showRS(void)
{	// rs 為 bit 25-21 的 5 bits
int	rs;

if (hasOperand) xtputs(COMMA);
rs = (HIGH16 >> 5) & 31;
if (USEALIAS) xtputs(CPUalias[rs]);
else { wsprintf(tempbuf, "r%d", rs);  xtputs(tempbuf); }
hasOperand = 1;
}

// ============= 印出暫存器名稱 (rt) =============
void showRT(void)
{	// rt 為 bit 20-16 的 5 bits
int	rt;

if (hasOperand) xtputs(COMMA);
rt = HIGH16 & 31;
if (USEALIAS) xtputs(CPUalias[rt]);
else { wsprintf(tempbuf, "r%d", rt);  xtputs(tempbuf); }
hasOperand = 1;
}

// ============= 印出暫存器名稱 (rd) =============
void showFT(void)
{	// rt 為 bit 20-16 的 5 bits
int	rt;

if (hasOperand) xtputs(COMMA);
rt = HIGH16 & 31;
wsprintf(tempbuf, "#%d", rt);  xtputs(tempbuf);
hasOperand = 1;
}

// ============= 印出旋轉位元數 (十進位) =============
void showSHCNT(void)
{	// sa5 為 bit 10-6 的 5 bits
int	sa;

if (hasOperand) xtputs(COMMA);
sa = (LOW16 >> 6) & 31;
wsprintf(tempbuf, "%d", sa);
xtputs(tempbuf);
hasOperand = 1;
}

// ============= 印出目的位址 =============
void showTAR26(void)
{	// 26 bit 256MB offset in NOWPC
if (hasOperand) xtputs(COMMA);
wsprintf(tempbuf, "$%08lX", (NOWPC & 0xF0000000) | ((code32 & 0x03FFFFFF) << 2));
xtputs(tempbuf);
hasOperand = 1;
}

// ============= 依所給型式印出操作子 =============
void showTypes(int typ)
{
if (typ) switch(typ) {
	case RD:  showRD();  break;
	case RS:  showRS();  break;
	case RT:  showRT();  break;
	case SHCNT:  showSHCNT();  break;
	case OFS16:  showOFS16();  break;
	case IMM16:  showIMM16();  break;
	case TAR26:  showTAR26();  break;
	case FUN26:  showFUN26();  break;
	case FS:    showFS();	break;
	case FT:    showFT();	break;
	case BASE16:  showBASE16();  break;
	case FR:    showFR();	break;
	case FD:    showFD();	break;
	}
}

// ============= 把字串 s 接到 outstr 之後 =============
void xtputs(char *s)
{
strcat(outstr, s);
}
// ---------------------- 以下為 FPU 解碼段落 --------------------------------
// FPU: BC1x, BC1xL
int FBC1XX(void)
{
if (HIGH16 & 0x1C) {	// MIPS4
    if (MIPS_LEVEL < 4) { errorCode = NOTIMPL;	return(0); }
    showIns(bcxx, HIGH16 & 3);
    ShowCC(HIGH16 >> 2);
    showR3(OFS16, 0, 0);
    }
else {
    if (MIPS_LEVEL < 2) { errorCode = NOTIMPL;	return(0); }
    if (MIPS_LEVEL > 3) {   // BC1xL in MIPS 4
	showIns(bcxx, HIGH16 & 3);
	ShowCC(HIGH16 >> 2);
	showR3(OFS16, 0, 0);
	}
    else {  // BC1xL in MIPS 2-3
	showIns(bcxx, HIGH16 & 3);
	showR3(OFS16, 0, 0);
	}
    }
return(1);
}

// FPU: MOVF/MOVT, 測試 (FCR32.bit[24+ccc] == 0 或 1) then move_reg
void FMOVX(void)
{
if (HIGH16 & 2) { errorCode = UNKNOWN;	    return; }
if (MIPS_LEVEL < 4) { errorCode = NOTIMPL;  return; }
showIns(fsingle, MOVF + (HIGH16 & 1));
showR3(RD, RS, 0);
ShowCC(HIGH16 >> 2);
}

// ------------ bit 25-21 = format bits[5] ------------
int FMTGRP(void)
{	    // 須注意 fmt 欄位者
char	fmt;

fmt = (HIGH16 >> 5) & 31;
if (fmt < 16) return(0);    // reserved group
if (fmt & 0x0A) return(0);  // reserved group
// fmt 剩下 16, 17, 20, 21
fmt = ((fmt >> 1) & 2) | (fmt & 1);	// fmt = 0 .. 3
if (((LOW16 >> 2) & 15) != 8) {  // 除了第八種以外都適用的規則
    if (fmt > 1) { errorCode = BAD2125;     return(0); }
    }
switch ((LOW16 >> 2) & 15) {	// 看低位的 bit [5..0]
    case 0:
	showIns2(fadd, LOW16 & 3, fmts[fmt]);
	showR3(FD, FS, FT);	return(1);
    case 1:
	showIns2(fsqrt, LOW16 & 3, fmts[fmt]);
	showR3(FD, FS, 0);	return(1);
    case 2:
	if (MIPS_LEVEL < 3) { errorCode = NOTIMPL;  return(0); }
	wsprintf(tempbuf, ".l%s", fmts[fmt]);
	showIns2(fround, LOW16 & 3, tempbuf);
	showR3(FD, FS, 0);	return(1);
    case 3:
	if (MIPS_LEVEL < 2) { errorCode = NOTIMPL;  return(0); }
	wsprintf(tempbuf, ".w%s", fmts[fmt]);
	showIns2(fround, LOW16 & 3, tempbuf);
	showR3(FD, FS, 0);	return(1);
    case 4:
	if (MIPS_LEVEL < 4) { errorCode = NOTIMPL;  return(0); }
	switch(LOW16 & 3) {
	    case 0: return(0);
	    case 1:
		if (HIGH16 & 2) { errorCode = BAD1620;	return(0); }
		showIns2(fsingle, MOVF + (HIGH16 & 1), fmts[fmt]);
		showR3(FD, FS, 0);  ShowCC(HIGH16 >> 2);    return(1);
	    case 2:
		showIns2(fsingle, MOVZ, fmts[fmt]);
		showR3(FD, FS, RT);	return(1);
	    case 3:
		showIns2(fsingle, MOVN, fmts[fmt]);
		showR3(FD, FS, RT);	return(1);
	    }
    case 5:
	if (MIPS_LEVEL < 4) { errorCode = NOTIMPL;  return(0); }
	switch(LOW16 & 3) {
	    case 0: return(0);
	    case 1:
		showIns2(fsingle, RECIP, fmts[fmt]);
		showR3(FD, FS, 0);	return(1);
	    case 2:
		showIns2(fsingle, RSQRT, fmts[fmt]);
		showR3(FD, FS, 0);	return(1);
	    case 3: return(0);
	    }
    case 8:
	if (LOW16 & 2) { errorCode = BAD0005;	return(0); }
	if (fmt == (LOW16 & 1)) { errorCode = BAD2125;	return(0); }
	wsprintf(tempbuf, "%s%s", fmts[LOW16 & 1], fmts[fmt]);
	showIns2(fsingle, CVT, tempbuf);
	showR3(FD, FS, 0);	return(1);
    case 9:
	if (LOW16 & 2) { errorCode = BAD0005;	return(0); }
	wsprintf(tempbuf, "%s%s", fmts[2+(LOW16 & 1)], fmts[fmt]);
	showIns2(fsingle, CVT, tempbuf);
	showR3(FD, FS, 0);	return(1);
    }
if ((LOW16 & 0xf0) == 0x30) {	// C.cond4 = 0011-cond4
    if (MIPS_LEVEL < 4) {
	wsprintf(tempbuf, "c.%s%s", cond4[LOW16 & 15], fmts[fmt]);
	xtputs(tempbuf);    addSpace();
	showR3(FS, FT, 0);  return(1);
	}
    wsprintf(tempbuf, "c.%s%s", cond4[LOW16 & 15], fmts[fmt]);
    xtputs(tempbuf);	addSpace();
    ShowCC(HIGH16 >> 2);
    showR3(FS, FT, 0);	return(1);
    }
return(0);	// 仍未解碼
}
// ------------ bit 25-21 = format bits[5] ------------
int FPU4(void)
{	// 7 個 MIPS4 的特殊指令
char	fmt;

// 先看兩個一般等級的指令
if ((LOW16 & 0xF83F) == 0) {	// FPU: LWXC1 fd, rindex(rbase)
    showIns(fsingle, LWXC1);
    showR3(FD, 0, 0);
    wsprintf(tempbuf, ", #%d(#%d)", HIGH16 & 31, (HIGH16 >> 5) & 31);
    xtputs(tempbuf);
    return(1);
    }
if ((LOW16 & 0x07FF) == 8) {	// FPU: SWXC1 fs, rindex(rbase)
    showIns(fsingle, SWXC1);
    showR3(FS, 0, 0);
    wsprintf(tempbuf, ", #%d(#%d)", HIGH16 & 31, (HIGH16 >> 5) & 31);
    xtputs(tempbuf);
    return(1);
    }
if (MIPS_LEVEL < 4) return(0);	// 後面就要 MIPS level 4 以上
switch ((LOW16 >> 3) & 7) {
    case 0:
	if ((LOW16 & 0xF83F) != 1) return(0);
	showIns(fsingle, LDXC1);
	showR3(FD, 0, 0);
	wsprintf(tempbuf, ", #%d(#%d)", HIGH16 & 31, (HIGH16 >> 5) & 31);
	xtputs(tempbuf);
	return(1);
    case 1:
	if ((LOW16 & 0x07FF) == 9) {
	    showIns(fsingle, SDXC1);
	    showR3(FS, 0, 0);
	    wsprintf(tempbuf, ", #%d(#%d)", HIGH16 & 31, (HIGH16 >> 5) & 31);
	    xtputs(tempbuf);
	    return(1);
	    }
	if ((LOW16 & 0x07FF) == 15) {
	    showIns(fsingle, SDXC1);
	    wsprintf(tempbuf, "#%d, #%d(#%d)", LOW16 >> 11, HIGH16 & 31, (HIGH16 >> 5) & 31);
	    xtputs(tempbuf);
	    return(1);
	    }
	return(0);
    }
if (LOW16 & 0x20) { // MADD - NMSUB
    fmt = LOW16 & 7;
    if (fmt > 1) return(0);	// 0, 1 才可用
    showIns2(fmadd, (LOW16 >> 3) & 3, fmts[fmt]);
    showR3(FD, FR, FS);     showFT();	return(1);
    }
return(0);	// 仍未解碼
}
// ------------ display ccc bit count ------------
void ShowCC(int cc)
{
if (hasOperand) xtputs(COMMA);
wsprintf(tempbuf, "bit%d", 24 + (cc & 7));
xtputs(tempbuf);
hasOperand = 1;
}

// ============= 印出 FPU 暫存器名稱 (fd) =============
void showFD(void)
{	// fd 為 bit 10-6 的 5 bits
int	fd;

if (hasOperand) xtputs(COMMA);
fd = (LOW16 >> 6) & 31;
wsprintf(tempbuf, "#%d", fd);  xtputs(tempbuf);
hasOperand = 1;
}

// ============= 印出 FPU 暫存器名稱 (fr) =============
void showFR(void)
{	// fr 為 bit 21-25 的 5 bits
int	fr;

if (hasOperand) xtputs(COMMA);
fr = HIGH16 >> 5;
wsprintf(tempbuf, "#%d", fr);  xtputs(tempbuf);
hasOperand = 1;
}

// ============= 印出 xstr[num] 字串 =============
void showIns2(char **xstr, int num, char *sfmt)
{
if (num < 0) num = 0;
xtputs(xstr[num]);  xtputs(sfmt);
addSpace();
}


