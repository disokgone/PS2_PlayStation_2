//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop

#include "SFIND.h"
#include "ELF_VIEW.h"       // ELF header viewer 程式
#include "GENERAL.h"        // 一般函式定義
#include "MIPS.h"           // MIPS 反組譯程式
#include "PS2MAN.h"         // 呼叫主畫面函式

#define FBUFSIZE    2048
#define FBUFSAFE    FBUFSIZE - 256
enum FindMode { HEXFIND, TXTFIND, BACKTRACE };
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TXFIND *XFIND;
struct SFindX   fs;     // SFind struct 搜尋結構
struct ProgramBolck     progBlk;    // 有效程式段資訊 (ELF_View.cpp)
byte    *fbuf = NULL;   // Find 用的檔案緩衝區
byte    *fhex;          // Find 用的要尋找的字列
char    *pt1, *pt2, *pt3;   // 顯示與處理用
int     maxFind;
extern int  FinAdr;         // 最大有效位址值 (ELF_View.cpp)
extern int  TopAddr;        // 主畫面位址 (PS2MAN.cpp)
extern int  validHexLen;    // GetHex() 所得到的有效字串長度 (General.cpp)
char    findID;         // HEXFIND, TXTFIND, BACKTRACE 三種
//---------------------------------------------------------------------------
__fastcall TXFIND::TXFIND(TComponent* Owner)
    : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TXFIND::BackSrh(void)
{       // 執行 Back Trace searching
int     c, i, j, ln, va;

c = 0;
while (c < progBlk.count) {
    va = progBlk.vaddr[c];      ln = progBlk.len[c];    // 取得一段的資料
    while (ln > 0) {
        va -= (va & 3);         // 取四的倍數位址才有意義
        ELFView->readFileTo(fbuf, va, FBUFSIZE);        // 一次讀入 2 Kbytes
        // 於 2K 內找字串
        for (i=0;i < FBUFSAFE;i += 4) {
            if (matchTarget((int *) (fbuf+i), va+i)) {   // 目標位址相同
                    SrhFound(va, i);        // 此位址可能符合
                }
            }
        va += FBUFSAFE;     ln -= FBUFSAFE;
        };
    c ++;
    };
}
//---------------------------------------------------------------------------
void __fastcall TXFIND::checkAllStatus(void)
{           // 把各個控制物件的狀態記錄下來
char    *p, *p1;
int     bktrAdr;        // 逆追蹤位址
int     tgLen;          // Target length : 要找的文字或數字長度
int     v;

// 先看 Edit 物件
tgLen = 0;
if (findID == HEXFIND) {    // 記錄 Hex 數值到 fhex[], tglen = 長度
    StrCopy(pt1+1, EdHex->Text.c_str());    // 取得字串
    p = pt1+1;
    do  {
        p1 = StrPos(p, " ");
        *(p-1) = '$';           // 要用十六進位
        v = GetHex(p-1);
        if (validHexLen > 0) {  // 有效轉換
            fhex[tgLen++] = v & 255;    // 填入一值
            }
        if (p1 != NULL) p = p1 + 1;     // 後面有字
        else validHexLen = 0;   // 後面沒字了 !
        } while(validHexLen);
    }
if (findID == TXTFIND) {    // 記錄字串數值到 fhex[], tglen = 長度
    StrCopy(fhex, EdText->Text.c_str());    // 取得字串
    tgLen = StrLen(fs.flist);
    }
if (findID == BACKTRACE) {  // 逆追蹤
    EdText->Text = "";      EdHex->Text = "";
    }
fs.targetLen = tgLen;       // Target length : 要找的文字或數字長度
// 把轉換後的數值顯示出來
pt1[0] = 0;     fhex[tgLen] = 0;
for (v=0;v < tgLen;v ++) {
    wsprintf(pt2, "%02X ", fhex[v]);
    StrCat(pt1, pt2);
    }
EdHex->Text = pt1;
EdText->Text = (char *) fs.flist;
fs.bktrAddr = GetHex(EdBkadr->Text.c_str());    // 取逆追蹤位址
// 再看 RadioGroup 物件
fs.alignType = RadGrpAlign->ItemIndex;
fs.displayMode = RadGrpDisp->ItemIndex;
fs.chRule = 0;
if (ChkBxWCase->Checked) fs.chRule |= 1;
if (ChkBxTojpn->Checked) fs.chRule |= 2;
}
//---------------------------------------------------------------------------
void __fastcall TXFIND::checkClientSize(TObject *Sender)
{       // OnPaint 事件
Memo->Width = XFIND->Width - 23;
}
//---------------------------------------------------------------------------
void __fastcall TXFIND::checkKeys(TObject *Sender, WORD &Key,
      TShiftState Shift)
{           // 檢查按鍵
if (Key == 27) Hide();      // ESC: 放棄搜尋
if (Key == 13) doSearch(this);  // Enter: 執行搜尋
}
//---------------------------------------------------------------------------
void __fastcall TXFIND::doBktrace(TObject *Sender)
{           // 按逆追蹤鈕
findID = BACKTRACE;         // 逆追蹤
doSearch(Sender);
}
//---------------------------------------------------------------------------
void __fastcall TXFIND::doSearch(TObject *Sender)
{           // 按確定鈕
ELFView->GetEffectiveAddr(&progBlk);        // 取得所有程式或資料區段的資料
if (progBlk.count < 1) return;      // 沒有可被搜尋的區段
maxFind = 100;          // Memo 最多放 100 個找到的資料
if (fbuf == NULL) findInit();
checkAllStatus();       // 把各個控制物件的狀態記錄下來
Memo->Clear();          // 搜尋範圍為整個檔案
switch(findID) {
    case HEXFIND:       // 不論大小寫
        HexSrh();   break;
    case TXTFIND:       // 可能要分大小寫
        TxtSrh();   break;
    case BACKTRACE:     // 逆追蹤專用程式
        BackSrh();  break;
    }
}
//---------------------------------------------------------------------------
void __fastcall TXFIND::findCancel(TObject *Sender)
{           // 放棄鈕
Hide();
}
//---------------------------------------------------------------------------
void __fastcall TXFIND::findInit(void)
{           // 借記憶體, 將不釋還, 除非程式結束
fbuf = (byte *) AllocMem(FBUFSIZE);
fhex = (char *) AllocMem(64);       // 要找的東西長度不應太長
fs.flist = fhex;    fs.targetLen = 0;
pt1 = (char *) AllocMem(256);
pt2 = (char *) AllocMem(256);
pt3 = (char *) AllocMem(256);
}
//---------------------------------------------------------------------------
void __fastcall TXFIND::HexSrh(void)
{       // 執行 Hex search (case insensitive)
int     c, i, j, ln, va;

c = 0;
while (c < progBlk.count) {
    va = progBlk.vaddr[c];      ln = progBlk.len[c];    // 取得一段的資料
    while (ln > 0) {
        ELFView->readFileTo(fbuf, va, FBUFSIZE);        // 一次讀入 2 Kbytes
        // 於 2K 內找一段數值
        for (i=0;i < FBUFSAFE;i ++) {
            if (fbuf[i] == *fhex) {         // 第一字相同
                for (j=1;j < fs.targetLen;j ++)
                    if (fbuf[i+j] != fhex[j]) j = fs.targetLen + 2; // 不同
                if (j == fs.targetLen) {    // 找到了
                    SrhFound(va, i);        // 此位址可能符合
                    i += fs.targetLen;
                    }
                }
            }
        va += FBUFSAFE;     ln -= FBUFSAFE;
        };
    c ++;
    };
}
//---------------------------------------------------------------------------
bool __fastcall TXFIND::matchTarget(int *p, int vadr)
{       // 傳回是否合於目標位址
unsigned int    code32, dest;
unsigned short  hi16, lo16;

code32 = (unsigned int) *p;
hi16 = code32 >> 16;    lo16 = (unsigned short) code32;
// 看本身 code32
if ((int) code32 == fs.bktrAddr) return(true);
// 看 addiu rx,rx,imm16
if (lo16 == (unsigned short) fs.bktrAddr) {
    if ((hi16 & 0xF800) == 0x4000) return(true);    // ADDI/ADDIU
    if ((hi16 & 0xF800) == 0x6000) return(true);    // DADDI/DADDIU
    }
if ((int) code32 == fs.bktrAddr) return(true);
// 看 J/JAL  [target26]
dest = (vadr & 0xF0000000) | ((code32 & 0x03FFFFFF) << 2);
switch (hi16 & 0xFC00) {
    case 0x0800:    // J    xxx
        if ((int) dest == fs.bktrAddr) return(true);
        break;
    case 0x0C00:    // JAL  xxx
        if ((int) dest == fs.bktrAddr) return(true);
        break;
    }
// 看 Branch XXXX [ofs16]
dest = ((short int) lo16 << 2) + vadr + 8;
if ((int) dest != fs.bktrAddr) return(false);
switch (hi16 & 0xFC00) {
    case 0x1000:    return(true);   // = BEQ
    case 0x5000:    return(true);   // = BEQL
    case 0x0400:
        if (hi16 & 0x000C) return(false);   // 指令不良
        return(true);   // = BGEZxx, BLTZxx
    case 0x1C00:
        if (hi16 & 0x001F) return(false);   // 指令不良
        return(true);   // = BGTZ
    case 0x5C00:
        if (hi16 & 0x001F) return(false);   // 指令不良
        return(true);   // = BGTZL
    case 0x1800:
        if (hi16 & 0x001F) return(false);   // 指令不良
        return(true);   // = BLEZ
    case 0x5800:
        if (hi16 & 0x001F) return(false);   // 指令不良
        return(true);   // = BLEZL
    case 0x1400:
        return(true);   // = BNE
    case 0x5400:
        return(true);   // = BNEL
    }
return(false);      // 沒符合條件
}
//---------------------------------------------------------------------------
void __fastcall TXFIND::mayFastGoto(TObject *Sender)
{       // 快點兩下, 若為合法數值可直接顯示
TopAddr = GetHex(Memo->SelText.c_str());
Hide();
PS2MAIN->MainPaint(this);
}
//---------------------------------------------------------------------------
void __fastcall TXFIND::setFindMode(TObject *Sender)
{           // 設定搜尋型態
if (Sender == EdText) findID = TXTFIND;     // 是文字搜尋
if (Sender == EdHex) findID = HEXFIND;      // 是數值搜尋
if (Sender == EdBkadr) findID = BACKTRACE;  // 是逆追蹤
}
//---------------------------------------------------------------------------
void __fastcall TXFIND::SrhFound(int vadr, int ofs)
{       // 此位址可能符合, 仍然要看其餘條件
int     destAddr, i;
char    rtv;

if (maxFind < 1) return;    // 找到太多個了, 暫停 !
destAddr = vadr + ofs;
switch(fs.alignType) {      // 位址切齊 0=any, 1=2n, 2=4n, 3=2n+2
    case 1:     // 要 2n 的位址
        if (destAddr & 1) return;   // 此奇數位址不合
        break;
    case 2:     // 要 4n 的位址
        if (destAddr & 3) return;   // 此位址不合 4n
        break;
    case 3:     // 要 2n+2 的位址
        if ((destAddr & 3) != 2) return;    // 此位址不合 2n + 2
        break;
    }
// 把找到的資料秀出來
wsprintf(pt1, "$%08lX - ", destAddr);
switch(fs.displayMode) {    // 顯示方式 0=UAsm, 1=Hex dump, 2=Text dump
    case 0:     // 0=UAsm
        NOWPC = destAddr - (destAddr & 3);  // 化為四的倍數
        wsprintf(pt1, "$%08lX - ", NOWPC);
        ofs -= (destAddr & 3);              // 化為四的倍數
        rtv = DisAsmMIPS((void *) (fbuf+ofs), pt2);
        if (rtv) wsprintf(pt2, "---???---  %s", GetUAerror(rtv));
        StrCat(pt1, pt2);
        padSpaces(pt1, 44);     // 補足長度到 44 字
        for (i=3;i >= 0;i--) {
            wsprintf(pt2, "%02X", fbuf[ofs+i]);
            StrCat(pt1, pt2);
            }
        StrCat(pt1, "  ");
        for (i=3;i >= 0;i--) {
            rtv = fbuf[ofs+i];  if (rtv < 32) rtv = '.';
            pt2[i] = rtv;
            }
        pt2[4] = 0;    StrCat(pt1, pt2);
        break;
    case 1:     // 1=Hex dump
        for (i=0;i < 24;i ++) {    // 顯示適當長度的數字
            wsprintf(pt2, "%02X ", fbuf[ofs+i]);
            StrCat(pt1, pt2);
            }
        break;
    case 2:     // 2=Text dump
        for (i=0;i < 64;i ++) {    // 顯示固定長度的字串
            rtv = fbuf[ofs+i];
            if (rtv < 64) rtv = '.';
            wsprintf(pt2, "%c", rtv);
            StrCat(pt1, pt2);
            }
        break;
    }
Memo->Lines->Add(pt1);          // !! Memo 放太多行仍會錯亂 !!
maxFind --;     // 每找到一個便減一
}
//---------------------------------------------------------------------------
void __fastcall TXFIND::TxtSrh(void)
{       // 執行 Text search
int     c, i, j, ln, va;

c = 0;
while (c < progBlk.count) {
    va = progBlk.vaddr[c];      ln = progBlk.len[c];    // 取得一段的資料
    while (ln > 0) {
        ELFView->readFileTo(fbuf, va, FBUFSIZE);        // 一次讀入 2 Kbytes
        // 於 2K 內找字串
        for (i=0;i < FBUFSAFE;i ++) {
            if (fbuf[i] == *fhex) {         // 第一字相同
                if (fs.chRule & 1) {        // 1 = 大小寫要相符
                    if (StrLComp(fbuf+i, fhex, fs.targetLen) == 0) {
                        SrhFound(va, i);        // 此位址可能符合
                        i += fs.targetLen;
                        }
                    }
                else if (StrLIComp(fbuf+i, fhex, fs.targetLen) == 0) {  // 大小寫不管
                    SrhFound(va, i);        // 此位址可能符合
                    i += fs.targetLen;
                    }
                }
            }
        va += FBUFSAFE;     ln -= FBUFSAFE;
        };
    c ++;
    };
}
//---------------------------------------------------------------------------

