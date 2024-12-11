struct ASMOPT {
    char    colLength;
    char    mipsLevel;
    char    useAlias;
    char    charCase;
    };

#ifndef  INMIPS_C
  extern unsigned int NOWPC;
  extern void _fastcall AsmOptions(struct ASMOPT *uaopt);
  extern char _fastcall DisAsmMIPS(void *buf, char *str);  // 反組譯一行指令
  extern char *_fastcall GetUAerror(char n);  // 取得錯誤字串
#endif
