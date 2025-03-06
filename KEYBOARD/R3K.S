;使用舊的 r3.inc (r3000 反組譯程式)
	SECTION .DATA
NONE	=	0
STDZ	=	4	;rs, rt, rd, 00000
STZZ	=	8	;rs, rt, 00000 00000
STI16	=	12	;rs, rt, imm16
ZTI16	=	16	;00000, rt, imm16
STO16	=	20	;rs, rt, ofs16
BTO16	=	24	;base, rt, ofs16
SZO16	=	28	;rs, 00000, ofs16
SCO16	=	32	;rs, condition, ofs16
CC20	=	36	;code 20 bits (bit 25-6)
TAR26	=	40	;26 bit target (bit 25-0)
SZDZ	=	44	;rs, 00000, rd, 00000
SZZZ	=	48	;rs, 00000 00000 00000
ZZDZ	=	52	;00000 00000, rd, 00000
ZTDC	=	56	;00000, rt, rd, shift_count
COPZ	=	60	;complex CoProcessor decodes
TDZZ	=	64	;cmds, rt, rd, 00000 00000
BCO16	=	68	;01000, 00000/1, ofs16
TNZZ	=	72	;cmds, rt, $nn, 00000 00000

	PUBLIC	ON
_Major00 db	'.       .       J       JAL     '      ;list by bit 31-26
	db	'BEQ     BNE     BLEZ    BGTZ    '
	db	'ADDI    ADDIU   SLTI    SLTIU   '
	db	'ANDI    ORI     XORI    LUI     '
	db	'COP0    COP1    COP2    COP3    '      ;from 0 - 13h
_Major20 db	'LB      LH      LWL     LW      '      ;from 20 - 3Ah
	db	'LBU     LHU     LWR     ???     '
	db	'SB      SH      SWL     SW      '
_Unknown db	'???     ???     SWR     ???     '
	db	'???     LWC1    LWC2    LWC3    '
	db	'???     ???     ???     ???     '
	db	'SWC1    SWC2    SWC3    ???     '      ;from 0 - 3Ah
_NOPcmd db	'NOP     '
_Special db	'SLL     ???     SRL     SRA     '      ;list by bit 5-0
	db	'SLLV    ???     SRLV    SRAV    '
	db	'JR      JALR    ???     ???     '
	db	'SYSCALL BREAK   MULT    ???     '
	db	'MFHI    MTHI    MFLO    MTLO    '
	db	'???     ???     ???     ???     '
	db	'MULTU   MULT16  DIV     DIVU    '
	db	'???     ???     ???     ???     '
	db	'ADD     ADDU    SUB     SUBU    '
	db	'AND     OR      XOR     NOR     '
	db	'???     ???     SLT     SLTU    '      ;from 0 - 2Bh
_RegImm db	'BLTZ    BGEZ    BLTZAL  BGEZAL  '      ;bit 20-16 = 0,1,10h,11h
_COPzRs db	'MFCz    CFCz    MTCz    CTCz    '      ;bit 25-21=0,2,4,6,8,1Xh
	db	'BCzF    BCzT    COPz    '
_CP0S	db	'TLBR    TLBWI   TLBWR   TLBP    RFE     '
_CP0N	db	5, 0, 1, 5, 5, 5, 2, 5, 3, 4
_COPsty0 db	TNZZ, TNZZ, TNZZ, TNZZ
	db	BCO16, BCO16
_CP2S	db	'SSTEP   SBSTEP  WSTEP   BSTEP   '
_MjStyle db	0, 0, TAR26, TAR26, STO16, STO16, SZO16, SZO16
	db	STI16, STI16, STI16, STI16, STI16, STI16, STI16, ZTI16
	db	COPZ, COPZ, COPZ, COPZ
_MjSt20 db	BTO16, BTO16, BTO16, BTO16, BTO16, BTO16, BTO16, 0
	db	BTO16, BTO16, BTO16, BTO16, 0, 0, BTO16, 0
	db	0, BTO16, BTO16, BTO16, 0, 0, 0, 0
	db	BTO16, BTO16, BTO16, 0
_SpStyle db	ZTDC, 0, ZTDC, ZTDC, STDZ, 0, STDZ, STDZ
	db	SZZZ, SZDZ, 0, 0, CC20, CC20, STZZ, 0
	db	ZZDZ, SZZZ, ZZDZ, SZZZ, 0, 0, 0, 0
	db	STZZ, STZZ, STZZ, STZZ, 0, 0, 0, 0
	db	STDZ, STDZ, STDZ, STDZ, STDZ, STDZ, STDZ, STDZ
	db	0, 0, STDZ, STDZ
_RIStyle db	SCO16, SCO16, SCO16, SCO16
	PUBLIC	OFF

	END
