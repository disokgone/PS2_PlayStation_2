//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop

#include "ELF_VIEW.h"
#include "GENERAL.h"        // 一般函式定義
#include "GO_REM.H"         // 自動化註解程式
#include "PASSTR2.hpp"      // PasString2 物件定義
#include "PS2MAN.h"         // 主畫面的部份功能

#define max(a,b)    (((a) > (b)) ? (a) : (b))

extern Elf32_Sym   *symG;   // General.cpp 將用的 symbol section
extern Elf32_Iop   *iopG;   // General.cpp 將用的 IOPM section
extern int  fhnd, gpAddr, TopAddr;  // in PS2MAN.cpp
extern int  symGmax;        // used in General.cpp
extern char *temp;          // in PS2MAN.CPP
extern bool toQuit;         // 程式即將關閉 in PS2MAN.CPP
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TELFView *ELFView;
int     FinAdr = 0;         // 最大有效位址值
int     FoundProgNo;        // 找到的程式段編號
bool    HasFile = false;    // 是否已讀入檔案
bool    cacheGood;          // 快取檢查是否合格
char    ELF_IDENT[4] = { 0x7F, 'E', 'L', 'F' };
char    *sec_flag[3] = { "Writable", "Occupies memory during execution",
                "Executable" };
char    *sec_types[13] = { "Unused", "Program data", "Symbol table", "String table",
                "Relocation entries with addends", "Symbol hash table", "Dynamic linking information",
                "Notes", "Program space with no data (bss)", "Relocation entries, no addends",
                "Reserved", "Dynamic linker symbol table", "Number of defined types" };
char    *seg_flag[3] = { "Executable", "Writable", "Readable" };
char    *seg_types[8] = { "unused", "Loadable program segment", "Dynamic linking information",
                "Program interpreter", "Auxiliary information", "Reserved",
                "Entry for header table itself", "Number of defined types" };
//---------------------------------------------------------------------------
__fastcall TELFView::TELFView(TComponent* Owner)
    : TForm(Owner)
{
}
//---------------------------------------------------------------------------
bool __fastcall TELFView::BadAddrInELF(int *adr, int *ofs)
{       // 分析 adr, 轉換成檔案位址, true 為不良
int     i, j;

j = *adr;
for (i=0;i < progCnt;i ++) {
    if ((j >= progVAdr[i]) && (j <= (progLen[i] + progVAdr[i]))) {
        // 找到一個存在的區域
        *adr = progVAdr[i]; // 傳回此區域的起點位址
        *ofs = progOfs[i];  // 傳回此區域在檔案的起點偏移值
        FoundProgNo = i;
        return(false);      // Good Address, OK !
        }
    }
return(true);       // It's really a bad address !
}
//---------------------------------------------------------------------------
void __fastcall TELFView::CheckProgSeg(void)
{       // 如果沒有可用的資料段, 試程式段
// PS2 的 Utility CD 有 PBPX_952.01 此檔有 33 個空 Section 及 1 個 Prog.seg.
Elf32_Phdr  *psh;
int     i;

for (i=0;i < EH->e_phnum;i ++) {
    psh = &PH[i];
    if (psh->p_type == 1) {     /* Loadable program segment */
        progVAdr[progCnt] = psh->p_vaddr;
        progLen[progCnt] = psh->p_filesz;
        progOfs[progCnt] = psh->p_offset;
        progRel[progCnt] = i << 16;     // 高位 16 bit 為程式區段編號
        progCnt ++;
        }   // 通常只增加一兩個較大的程式段, 但無妨其正確性
    }
}
//---------------------------------------------------------------------------
void __fastcall TELFView::checkSize(TObject *Sender)
{       // 儘量讓 Memo1 充滿視窗
Memo1->Height = ELFView->Height - 42;
Memo1->Width = ELFView->Width - 25;
}
//---------------------------------------------------------------------------
int __fastcall TELFView::FindCacheVA(int sectNo, Elf32_Shdr *Sh, int VAdr)
{       // 到快取中尋找, 每次取 1024 bytes
int     i, j;

cacheGood = false;
for (i=0;i < nRelTable;i ++) {
    if (*cacheRel[i] == sectNo) {   // 此段落有重定位資訊
        if (Sh->sh_size < 0x8000) { // 此段落已完全載入 (Elf32_Rel type)
            j = binaSearch(cacheRel[i]+1, VAdr, 8, Sh->sh_size / 8);
            if (j > (int) Sh->sh_size) return(0);       // 失敗 !!
            Move(cacheRel[i]+1+(j >> 2), temp, 1024);   // get 1024 bytes
            j = 0;
            cacheGood = true;
            return(j);      // 傳回 byte offset
            }
        else {      // 此段落只載入位址當快取表 (Elf32_Rel type)
            j = binaSearch(cacheRel[i]+1, VAdr, 4, 2048);
            if (j > 8192) return(0);            // 失敗 !!
            FileSeek(fhnd, (int) (Sh->sh_offset + (Sh->sh_size / 2048) * (j / 4)), 0);
            FileRead(fhnd, temp, 1024);
            j = binaSearch((int *) temp, VAdr, 8, 1024 / 8);
            if (j > 1024) return(0);            // 失敗 !!
            cacheGood = true;
            return(j);      // 傳回 byte offset
            }
        }
    }
return(0);
}
//---------------------------------------------------------------------------
void __fastcall TELFView::GetEffectiveAddr(struct ProgramBolck *pblk)
{       // 傳回所有可用的程式區段值
pblk->count = progCnt;
pblk->vaddr = progVAdr;
pblk->len = progLen;
}
//---------------------------------------------------------------------------
int __fastcall TELFView::GetFinalAddr(void)
{       // 傳回最後一字位址
int i;

if (!HasFile) {     // 根本沒有 ELF 檔頭
    if (fhnd > 0) { i = FileSeek(fhnd, 0, 2);  return(i); }
    return(0);
    }
if (FinAdr != 0) return(FinAdr);
for (i=0;i < progCnt;i ++) FinAdr = max(FinAdr, progVAdr[i] + progLen[i]);
return(FinAdr);
}
//---------------------------------------------------------------------------
void __fastcall TELFView::GetSymbol(int adr, char *p)
{       // 取得與此位址有關的符號 (符號表僅有一個)
Elf32_Shdr  *sh;
Elf32_Sym   *sy;
int     *pi;
int     ofs, sectNo, tail, va;

*p = 0;
if (!HasFile) return;               // 根本沒有 ELF 檔頭
va = adr;
if (BadAddrInELF(&va, &ofs)) return;    // 檢查位址是否合法
sectNo = progRel[FoundProgNo] & 0xFFFF; // sectNo = 重定位區段編號
if (sectNo == 0) return;            // 零號區段為空段, 不必重定位
if (sectNo > EH->e_shnum) return;   // 重定位區段編號不良
sh = &SH[sectNo];                   // 取得重定位區段資訊
// temp 有 1024 bytes, 可放 8*128 or 16*64 個重定位資訊當快取
ofs = FindCacheVA(sectNo, sh, adr);
// 到快取中尋找, 每次取 1024 bytes 到 temp, ofs 必傳回 8 的倍數
ofs >>= 2;      // ofs 轉成 int index
if (!cacheGood) return;             // 快取不良則返回
pi = (int *) temp;
tail = adr + 4;
while(tail > pi[ofs]){  // 反覆檢查重定位資訊
    if (adr == pi[ofs]) {           // 此位址有效 !!
        // 取得一組 Elf32_Rel 重定位資訊
        sy = &SYM[pi[ofs+1] >> 8];
        wsprintf(p, "%s ($%lX)", strtab + sy->st_name, sy->st_value);
        break;
        }
    ofs += 2;   // 看下一組重定位資訊
    };
}
//---------------------------------------------------------------------------
void __fastcall TELFView::MainELFheader(void)
{       // 檢查是否有 ELF 檔頭
unsigned int    ofs, v;
unsigned short  Hdr_size;           // size of ELF header

HasFile = false;
FileSeek(fhnd, 0x28, 0);   FileRead(fhnd, &Hdr_size, 2);
if ((Hdr_size < 8) || (Hdr_size > 0x80)) return;        // 可能有誤 !
if (HasFile) {
    SysFreeMem(EH);  SysFreeMem(PH);  SysFreeMem(SH);  SysFreeMem(SYM);  SysFreeMem(IOP);
    SysFreeMem(progVAdr);  SysFreeMem(progLen);  SysFreeMem(progOfs);  SysFreeMem(progRel);
    }
HasFile = true;
EH = (Elf32_Ehdr *) AllocMem(Hdr_size);
FileSeek(fhnd, 0, 0);   FileRead(fhnd, EH, Hdr_size);
if (StrLComp(EH->e_ident, ELF_IDENT, 4) != 0) return;   // 非 ELF 檔頭
if (EH->e_machine != 8) {           // 非 MIPS R3000
    MessageBox(ELFView->Handle, "此檔案不是 PS2 ELF 格式 !", "注意", IDOK);
    return;
    }
PH = (Elf32_Phdr *) AllocMem(EH->e_phentsize * EH->e_phnum);    // 借所有的 program seg. 表頭
SH = (Elf32_Shdr *) AllocMem(EH->e_shentsize * EH->e_shnum);    // 借所有的 section 表頭
IOP = (Elf32_Iop *) AllocMem(sizeof(Elf32_Iop));  setmem(IOP, sizeof(Elf32_Iop), 0);
iopSect = -1;

FileSeek(fhnd, (int) (EH->e_shoff + (EH->e_shentsize * EH->e_shstrndx) + 16), 0);
FileRead(fhnd, &ofs, 4);    // Get string table address base.
FileRead(fhnd, &v, 4);      // Get string table size.
if (v > 0x80000) v = 512;   // string table size 超過 512K 有問題, 乾脆不用
secName = (char *) AllocMem(v);
FileSeek(fhnd, (int) ofs, 0);  FileRead(fhnd, secName, v);      // Get string table

FileSeek(fhnd, (int) EH->e_phoff, 0);   FileRead(fhnd, PH, EH->e_phentsize * EH->e_phnum);
FileSeek(fhnd, (int) EH->e_shoff, 0);   FileRead(fhnd, SH, EH->e_shentsize * EH->e_shnum);

Memo1->Clear();
Show();     Hide();     // !! 必須要 Show 一下才不會 Access violation !!
ParseProgSegment();     // 分析並顯示 prog.Seg. 表頭
MemoAdd(Memo1, "--------------------------------------");
progVAdr = (int *) AllocMem(EH->e_shnum * sizeof(progVAdr));
progLen = (int *) AllocMem(EH->e_shnum * sizeof(progLen));
progOfs = (int *) AllocMem(EH->e_shnum * sizeof(progOfs));
progRel = (int *) AllocMem(EH->e_shnum * sizeof(progRel));
setmem(progVAdr, EH->e_shnum * sizeof(progVAdr), 0);
setmem(progLen, EH->e_shnum * sizeof(progLen), 0);
setmem(progOfs, EH->e_shnum * sizeof(progOfs), 0);
setmem(progRel, EH->e_shnum * sizeof(progRel), 0);
setmem(cacheRel, 4 * MAXNREL, 0);       // 清除重定位表
progCnt = 0;    nRelTable = 0;      symGmax = 0;
ParseSectionHdrs();                     // 分析並顯示 Section 表頭
if (iopSect > 0) ShowIOPM();            // 顯示有關 I/O processor R3000 之訊息
else MemoAdd(Memo1, "沒有 I/O Processor Module !");
CheckProgSeg();     // 如果沒有可用的資料段, 試程式段
ShowProgSegs();     // 顯示有資料的程式區段
Show();
WriteSymbolToREM(); // 把符號表的資料寫到註解中
}
//---------------------------------------------------------------------------
void __fastcall TELFView::Memo1FastGo(TObject *Sender)
{       // 滑鼠雙擊快速移位
TopAddr = GetHex(Memo1->SelText.c_str());
Hide();
PS2MAIN->MainPaint(this);
}
//---------------------------------------------------------------------------
void __fastcall TELFView::ParseProgSegment(void)
{       // 分析並顯示 prog.Seg. 表頭
Elf32_Phdr  *psh;
char    *str, *str2;
int     i;
char    c, d, e;

psh = PH;  str = temp;  str2 = temp + 512;
for (i=0;i < EH->e_phnum;i ++, psh ++) {
    wsprintf(temp, "Segment No.%d", i);
    MemoAdd(Memo1, temp);
    // Segment Type
    if (psh->p_type > 7) {
        if (psh->p_type == 0x70000080) StrCopy(str, "Segment type : 模組相關資訊");
        else wsprintf(str, "Segment type : Unknown ($%lX)", psh->p_type);
        }
    else wsprintf(str, "Segment type : %s", seg_types[psh->p_type]);
    MemoAdd(Memo1, temp);
    // Segment virtual address
    wsprintf(str, "Segment virtual address : $%08lX", psh->p_vaddr);
    MemoAdd(Memo1, temp);
    // Segment physical address
    wsprintf(str, "Segment physical address : $%08lX", psh->p_paddr);
    MemoAdd(Memo1, temp);
    // Segment file offset
    wsprintf(str, "Segment file offset : $%08lX", psh->p_offset);
    MemoAdd(Memo1, temp);
    // Segment size in file
    wsprintf(str, "Segment size in file : $%08lX", psh->p_filesz);
    MemoAdd(Memo1, temp);
    // Segment size in memory
    wsprintf(str, "Segment size in memory : $%08lX", psh->p_memsz);
    MemoAdd(Memo1, temp);
    // Segment flags
    d = psh->p_flags;
    StrCopy(str, "Segment flags : ");
    *str2 = 0;
    for (c=0, e=1;c < 3;c ++, e <<= 1) if (d & e) {
        if (*str2) StrLCat(str2, ", ", 255);
        StrLCat(str2, seg_flag[c], 255);
        }
    if (psh->p_flags > 7) wsprintf(str2, "Unknown ($%lX)", psh->p_flags);
    StrLCat(str, str2, 255);
    MemoAdd(Memo1, temp);
    // Segment alignment
    wsprintf(str, "Segment alignment : %ld", psh->p_align);
    MemoAdd(Memo1, temp);
    MemoAdd(Memo1, "");
    }
}
//---------------------------------------------------------------------------
void __fastcall TELFView::ParseSectionHdrs(void)
{       // 分析並顯示 Section 表頭
Elf32_Shdr  *sh;
char    *str, *str2;
int     i, *intp;
unsigned int l;
char    c, d, e;

sh = SH;  str = temp;  str2 = temp + 512;

for (i=0;i < EH->e_shnum;i ++, sh ++) {
    wsprintf(str, "Section No.%d : %s", i, secName+sh->sh_name);
    MemoAdd(Memo1, temp);
    // Section type
    l = sh->sh_type;
    StrCopy(str, "Section type : ");
    if (l > 12) {
        if ((l >> 24) != 0x70) wsprintf(str2, " Unknown ($%lX)", l);
        else {
            switch (l & 0xFF) {
                case 0: StrCopy(str2, "Shared objects used in link");  break;
                case 2: StrCopy(str2, "Conflicting symbols");  break;
                case 3: StrCopy(str2, "Global data area sizes");  break;
                case 4: StrCopy(str2, "Reserved for SGI/MIPS compilers");  break;
                case 5: StrCopy(str2, "MIPS ECOFF debugging information");  break;
                case 6: StrCopy(str2, "Register usage information");  break;
                case 13: StrCopy(str2, "Miscellaneous options");  break;
                case 30: StrCopy(str2, "DWARF debugging information");  break;
                case 33: StrCopy(str2, "Event section");  break;
                default: wsprintf(str2, "Unknown ($%lX)", l);
                }
            }
        }
    else wsprintf(str2, "%s", sec_types[l]);
    StrLCat(str, str2, 255);
    MemoAdd(Memo1, temp);
    // Section flags
    l = sh->sh_flags;
    d = l;  *str2 = 0;
    for (c=0, e=1;c < 3;c ++, e <<= 1) if (d & e) {
        if (*str2) StrLCat(str2, ", ", 255);
        StrLCat(str2, sec_flag[c], 255);
        }
    if (*str2 == 0) wsprintf(str2, "Unknown flag ($%lX)", l);
    wsprintf(str, "Section flags : %s", str2);
    MemoAdd(Memo1, temp);
    // Section virtual addr at execution
    wsprintf(str, "Section virtual addr at execution : $%08lX", sh->sh_addr);
    MemoAdd(Memo1, temp);
    // Section file offset
    wsprintf(str, "Section file offset : $%08lX", sh->sh_offset);
    MemoAdd(Memo1, temp);
    // Section size in bytes
    wsprintf(str, "Section size in bytes : $%08lX", sh->sh_size);
    MemoAdd(Memo1, temp);
    // Link to another section
    wsprintf(str, "Link to another section : No.%ld", sh->sh_link);
    MemoAdd(Memo1, temp);
    // Additional section information
    wsprintf(str, "Additional section information : $%08lX", sh->sh_info);
    MemoAdd(Memo1, temp);
    // Section alignment
    wsprintf(str, "Section alignment : %ld", sh->sh_addralign);
    MemoAdd(Memo1, temp);
    // Entry size if section holds table
    wsprintf(str, "Entry size if section holds table : %ld", sh->sh_entsize);
    MemoAdd(Memo1, temp);
    MemoAdd(Memo1, "");
    // 載入 String Table
    if (sh->sh_type == SHT_STRTAB) {
        if (EH->e_shstrndx != i) {  // Section Name 不必重覆載入
            strSectNo = i;
            strtab = (char *) AllocMem(sh->sh_size);
            FileSeek(fhnd, (int) sh->sh_offset, 0);
            FileRead(fhnd, strtab, sh->sh_size);
            }
        }
    // 載入 Symbol Table (16 bytes = 1 entry)
    if (sh->sh_type == SHT_SYMTAB) {
        symSectNo = i;
        SYM = (Elf32_Sym *) AllocMem(sh->sh_size);
        symGmax = sh->sh_size >> 4;     // 16 bytes = 1 entry
        FileSeek(fhnd, (int) sh->sh_offset, 0);
        FileRead(fhnd, SYM, sh->sh_size);
        }
    if (sh->sh_type == SHT_PROGBITS) {  // 有資訊的程式區才保留
        progVAdr[progCnt] = sh->sh_addr;
        progLen[progCnt] = sh->sh_size;
        progOfs[progCnt] = sh->sh_offset;
        progRel[progCnt] = i << 16;     // 高位 16 bit 為程式區段編號
        progCnt ++;
        }
    if ((sh->sh_type == SHT_RELA) || (sh->sh_type == SHT_REL)) {
        // 有重定位資訊
        if (nRelTable < MAXNREL) {      // 尚有重定位表空間
            if (sh->sh_size < 0x8000) { // 如果重定位表大小 < $8000, 則完全載入
                cacheRel[nRelTable] = (int *) AllocMem(sh->sh_size+4);
                intp = cacheRel[nRelTable];
                FileSeek(fhnd, (int) sh->sh_offset, 0);
                FileRead(fhnd, intp+1, sh->sh_size);
                }
            else {  // 如果重定位表大小 >= $8000, 則只讀入 2048 個位址當快取
                cacheRel[nRelTable] = (int *) AllocMem(8196);   // 4+(2048*4)
                intp = cacheRel[nRelTable];
                grabAddrAsCacheTable(fhnd, sh->sh_offset, sh->sh_size, intp+1);
                }   // grabAddrAsCacheTable() 放在 GENERAL.cpp
            intp[0] = i;        // 此為第 i 個 Section !
            nRelTable ++;
            }
        for (l=0;(int) l < progCnt;l ++) if ((progRel[l] >> 16) == (int) sh->sh_info) {
            progRel[l] |= (i & 0xFFFF); // 低位 16 bit 為重定位區段編號
            }
        }
    if (sh->sh_type == 0x70000080) {
        // 有 I/O processor module
        FileSeek(fhnd, (int) sh->sh_offset, 0);
        FileRead(fhnd, IOP, sh->sh_size);
        TopAddr = IOP->i_EntryPC;
        iopSect = i;
        }
    }
}
//---------------------------------------------------------------------------
int __fastcall TELFView::readFileTo(char *p, int adr, int len)
{       // 傳回實讀長度
int     adr2, sAdr2;
int     i, j, rlen, totalen;
char    mode;

if (toQuit) return(0);  // 程式即將關閉
setmem(p, len, 0);      // 先清為零
if (!HasFile) {         // 根本沒有 ELF 檔頭
    FileSeek(fhnd, adr, 0);     // 先移到偏移值
    FileRead(fhnd, p, len);
    return(len);
    }
adr2 = adr + len;
totalen = 0;
iopG = IOP;     symG = SYM;     // 此二數為 General.cpp 在 MakeRelocate() 使用
for (i=0;i < progCnt;i ++) {
    sAdr2 = progVAdr[i] + progLen[i] - 1;
    mode = CollideMode(adr, adr2, progVAdr[i], sAdr2);
    if (progLen[i] == 0) mode = 0;      // 此區長度為零, 略過 !
    if (mode) {     // 找到一個有碰撞的區域
        switch(mode) {
            case 1: // A < B, 互相交叉
                FileSeek(fhnd, progOfs[i], 0);  // 先移到偏移值
                rlen = adr2 - progVAdr[i];
                sAdr2 = progVAdr[i] - adr;
                FileRead(fhnd, p + sAdr2, rlen);
                RelocateELF(p + sAdr2, progVAdr[i], rlen, i);
                totalen += rlen;    break;      // 還要檢查下一個區域
            case 2: // A 包含於 B
                FileSeek(fhnd, progOfs[i] + adr - progVAdr[i], 0);  // 先移到偏移值
                FileRead(fhnd, p, len);
                RelocateELF(p, adr, len, i);
                return(totalen);    // 已經全讀入了 !
            case 3: // A > B, 互相交叉
                FileSeek(fhnd, progOfs[i] + adr - progVAdr[i], 0);  // 先移到偏移值
                rlen = sAdr2 - adr;
                FileRead(fhnd, p, rlen);
                RelocateELF(p, adr, rlen, i);
                totalen += rlen;    break;      // 還要檢查下一個區域
            case 4: // B 包含於 A
                FileSeek(fhnd, progOfs[i], 0);  // 先移到偏移值
                sAdr2 = progVAdr[i] - adr;
                FileRead(fhnd, p + sAdr2 , progLen[i]);
                RelocateELF(p + sAdr2, progVAdr[i], rlen, i);
                totalen += progLen[i];  break;  // 還要檢查下一個區域
            }
        }
    }
return(totalen);
}
//---------------------------------------------------------------------------
void __fastcall TELFView::RelocateELF(char *p, int va, int len, int n)
{       // 將緩衝區 p 長度為 len 的區域, 設為 va 虛擬位址加以重定位
        // progOfs[n] 為其檔案位址
Elf32_Shdr  *sh;
int     sectNo, ofs, tail, *pi;

if (iopSect < 1) return;            // 此 ELF 檔已經重定位過, 不須再做一遍 !
if (!HasFile) return;               // 根本沒有 ELF 檔頭
sectNo = progRel[n] & 0xFFFF;       // sectNo = 重定位區段編號
if (sectNo == 0) return;            // 零號區段為空段, 不必重定位
if (sectNo > EH->e_shnum) return;   // 重定位區段編號不良
sh = &SH[sectNo];                   // 取得重定位區段資訊
// temp 有 1024 bytes, 可放 8*128 or 16*64 個重定位資訊當快取
ofs = FindCacheVA(sectNo, sh, va);
// 到快取中尋找, 每次取 1024 bytes 到 temp, ofs 必傳回 8 的倍數
ofs >>= 2;      // ofs 轉成 int index
if (!cacheGood) return;             // 快取不良則返回
pi = (int *) temp;
tail = va + len;
while(1){       // 反覆填入重定位資訊
    if (tail < pi[ofs]) break;      // 已過尾端
    if (va <= pi[ofs]) {            // 此位址在 p[len] 內, 有效 !!
        MakeRelocate(p, pi[ofs]-va, pi[ofs+1], 0, 0);   // Elf32_Rel 重定位
        }       // MakeRelocate() 在 General.h
    ofs += 2;   // 看下一組重定位資訊
    };
}
//---------------------------------------------------------------------------
void __fastcall TELFView::ShowIOPM(void)
{
MemoAdd(Memo1, "--------------------------------");
if (iopSect == -1) {
    MemoAdd(Memo1, "IOPM 程式資訊區段不存在於此檔中 !");
    Show();
    }
wsprintf(temp, "此模組的全名 : %s", IOP->modName);
MemoAdd(Memo1, temp);
wsprintf(temp, "程式的 Entry Point (PC) : $%08lX", IOP->i_EntryPC);
MemoAdd(Memo1, temp);
wsprintf(temp, "$00000001:程式的 Entry Point (PC) : $%08lX", IOP->i_EntryPC);
MemoAdd(REMGO->Memo, temp);
wsprintf(temp, ".data section 擺\放的 virtual address : $%08lX", IOP->i_dataVA);
MemoAdd(Memo1, temp);
wsprintf(temp, ".rodata section (read only) 擺\放的 virtual address : $%08lX", IOP->i_rodata);
MemoAdd(Memo1, temp);
gpAddr = IOP->i_GP;
wsprintf(temp, "全域變數 Global Pointer (gp) 暫存器的初值 : $%08lX", IOP->i_GP);
MemoAdd(Memo1, temp);
wsprintf(temp, "$00000002:全域變數 Global Pointer (gp) 暫存器的初值 : $%08lX", IOP->i_GP);
MemoAdd(REMGO->Memo, temp);
wsprintf(temp, ".data 加上 .rodata 此二區段的大小總合 : $%08lX", IOP->i_dataSize);
MemoAdd(Memo1, temp);
wsprintf(temp, "Segment No.1 應多借多少 bytes : $%08lX", IOP->i_seg1add);
MemoAdd(Memo1, temp);
}
//---------------------------------------------------------------------------
void __fastcall TELFView::ShowProgSegs(void)
{       // 顯示有資料的程式區段
int     i;

MemoAdd(Memo1, "================================");
for (i=0;i < progCnt;i ++) {
    wsprintf(temp, "有程式的區段 No.%d: 起始虛擬位址 = $%08lX", i, progVAdr[i]);
    MemoAdd(Memo1, temp);
    wsprintf(temp, "     區段長度 = $%08lX", progLen[i]);
    MemoAdd(Memo1, temp);
    }
}
//---------------------------------------------------------------------------
void __fastcall TELFView::WriteSymbolToREM(void)
{       // 把符號表的資料寫到註解中
Elf32_Sym   *sy;
int     i;
extern char *rtmp;

sy = SYM;       // 通常只有一個, 故直接取用
i = FileOpen(PS2MAIN->OpenDlg->FileName, fmOpenRead);   // 嘗試開啟 .REM
if (i <= 0) {
    i = MessageBox(ELFView->Handle, "是否要轉換整個符號表為註解 ?", "符號表轉換", MB_YESNO);
    if (i == ID_NO) return; // 不轉換符號表為註解
    }
else {
    FileClose(i);           // 已有註解檔了
    return;                 // 不轉換符號表為註解
    }
REMGO->Panel1->Show();    
for (i=0;i < symGmax;i ++) {
    REMGO->FirstAddRem(sy->st_value, strtab + sy->st_name);   // 直接加入此註解
    sy ++;
    }
REMGO->Panel1->Hide();
}
//---------------------------------------------------------------------------

