//---------------------------------------------------------------------------
#ifndef ELF_VIEWH
#define ELF_VIEWH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include "PS2ELF.h"         // 和 PS2 比較有關的定義
#define  MAXNREL    8

//---------------------------------------------------------------------------
class TELFView : public TForm
{
__published:	// IDE-managed Components
    TMemo *Memo1;
    void __fastcall checkSize(TObject *Sender);
    void __fastcall Memo1FastGo(TObject *Sender);
private:	// User declarations
    Elf32_Ehdr  *EH;    // ELF main Header
    Elf32_Phdr  *PH;    // Program Seg. Header
    Elf32_Shdr  *SH;    // Section Header
    Elf32_Sym   *SYM;   // symbol table (通常只有一個)
    Elf32_Iop   *IOP;   // IOPM 資料
    int     *progVAdr, *progLen, *progOfs, *progRel;
    // 程式或資料區段的起始位址與長度與其檔案起點與重定位表區段
    int     *cacheRel[MAXNREL];     // Relocation table ptr.(8 bytes/entry)
    char    *strtab, *secName;      // string table (通常有二個)
    int     strSectNo, symSectNo;   // 此二字串表來自哪個區段
    int     iopSect;                // IOPM 存在於哪個區段
    int     progCnt, nRelTable;     // 程式或資料區段的數目, 重定位表數目
    void __fastcall CheckProgSeg(void);         // 如果沒有可用的資料段, 試程式段
    void __fastcall ParseProgSegment(void);     // 分析並顯示 Prog.Seg. 表頭
    void __fastcall ParseSectionHdrs(void);     // 分析並顯示 Section 表頭
    void __fastcall ShowIOPM(void);             // 顯示 IOPM 區段
    void __fastcall ShowProgSegs(void);         // 顯示有資料的程式區段
    void __fastcall WriteSymbolToREM(void);     // 把符號表的資料寫到註解中
public:		// User declarations
    __fastcall TELFView(TComponent* Owner);
    bool __fastcall BadAddrInELF(int *adr, int *ofs);   // adr 轉換成檔案位址, true 為不良
    int __fastcall  FindCacheVA(int sectNo, Elf32_Shdr *Sh, int VAdr);  // 到快取中尋找
    void __fastcall GetEffectiveAddr(struct ProgramBolck *pblk);        // 傳回所有可用的程式區段值
    int __fastcall  GetFinalAddr(void);         // 傳回最後一字位址
    void __fastcall GetSymbol(int adr, char *p); // 取得與此位址有關的符號 (符號表僅有一個)
    void __fastcall MainELFheader(void);        // 檢查是否有 ELF 檔頭
    int __fastcall  readFileTo(char *p, int adr, int len);  // 傳回實讀長度
    void __fastcall RelocateELF(char *p, int va, int len, int n);   // 加以重定位
};
//---------------------------------------------------------------------------
extern PACKAGE TELFView *ELFView;
//---------------------------------------------------------------------------
struct ProgramBolck{
    int     count;      // 程式或資料區段的數目
    int     *vaddr;     // 程式或資料區段的虛擬位址陣列
    int     *len;       // 程式或資料區段的長度
};
//---------------------------------------------------------------------------
#endif
