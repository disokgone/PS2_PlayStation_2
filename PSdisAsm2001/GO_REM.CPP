//---------------------------------------------------------------------------
#include <vcl.h>
#include <vcl/clipbrd.hpp>
#pragma hdrstop

#include "GO_REM.h"
#include "GENERAL.h"        // 一般函式
#include "PS2MAN.h"         // 主畫面函式
#include "PASSTR2.hpp"      // PasString2 物件定義

#define MAXLINE     16000    // 一次可放 16000 行註解
#define REMSIZE     512000  // 最多 512 K 字元/註解檔
#define MEMOSIZE    96000   // 最多 96 K 字元/Memo
#define TMPSIZE     256     // 最多 256 字元/行

extern int  TopAddr;        // in PS2MAN.cpp 主畫面正在看的位址起點
extern int  validHexLen;    // General.cpp : GetHex() 所得到的有效字串長度
extern char *temp2;         // in PS2MAN.cpp 暫用字串
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"

TREMGO *REMGO;
TPasString2 *rem;
int     nowLine;            // 目前 Memo 看的是 rem->Strings 的第幾項起
char    *rtmp, *rtmp1;
char    *mstr;      // Memo 用的 String
//---------------------------------------------------------------------------
__fastcall TREMGO::TREMGO(TComponent* Owner)
    : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TREMGO::Btn2Click(TObject *Sender)
{
Hide();         // 放棄: 關閉此視窗
}
//---------------------------------------------------------------------------
void __fastcall TREMGO::chkEditCuts(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
int     shState;
TClipboard  *clpb;
TCustomEdit *te;

_asm    mov shState, ecx    // Shift 變數是 Class 成員, 難以比較

te = NULL;
if (rem == NULL) initREM();
if (Sender == AddrEdit) te =AddrEdit;
if (Sender == Memo) te = Memo;
if ((Sender == CmbBx) && (Key == 0x0D)) {   // 輸入了位址
    Get_REM(GetHex(CmbBx->Text.c_str()), rtmp);     // 讀取先前註解
    AddrEdit->Text = rtmp;
    AddrEdit->SetFocus();   // 讓 Edit 物件編修    
    return;
    }
if (te == NULL) return;

if (Key == 0x0D) SetOneREM(NULL);
clpb = Clipboard();
if (shState == ssCtrl) {
    switch(Key){
        case 'C':   // copy to ClipBoard
            clpb->AsText = te->SelText;     break;
        case 'X':   // cut to ClipBoard
            clpb->AsText = te->SelText;
            te->Text = "";      break;
        case 'V':   // paste from ClipBoard
            te->SelText = clpb->AsText;     break;
        }
    }
}
//---------------------------------------------------------------------------
void __fastcall TREMGO::DestAddrRem(char *p)
{           // 以指令的目的碼尋找註解
int     v;
char    *p1, *p2;

p1 = p;
p2 = StrPos(p1, "$");
*p = 0;    p1[43] = 0;
if (p2 == NULL) return;     // 沒機會增加註解
do  {
    v = GetHex(p2);
    if (validHexLen == 9) { // 可能為有效虛擬位址
        Get_REM(v, temp2);
        if (*temp2 != 0) {
            StrCopy(p, temp2);
            return;
            }
        }
    if (validHexLen == 0) return;   // 沒有數字了
    p1 = p2 + validHexLen;
    p2 = StrPos(p1, "$");
    } while (p2 != NULL);
}
//---------------------------------------------------------------------------
void __fastcall TREMGO::FastAddrToGo(TObject *Sender)
{           // 在有效的十六進位數上快按兩下 : 跳到此位址
int     adr;

adr = GetHex(Memo->SelText.c_str());    // 取得標示字串位址
if (validHexLen > 3) {
    TopAddr = adr;      // 設立欲前往的位址
    Hide();             // 隱藏註解視窗
    }
}
//---------------------------------------------------------------------------
void __fastcall TREMGO::FindRemStr(TObject *Sender)
{           // 找位於 EditAddr 物件中所列的字串 (不論大小寫)
int     i, j;

StrCopy(rtmp1, AddrEdit->Text.c_str());     // 取得欲搜尋字串
if (StrLen(rtmp1) < 1) {            // 未填搜尋字串
    MessageBox(REMGO->Handle, "請在編輯框內填入欲搜尋的字串", "未填搜尋字串", MB_OK);
    return;
    }
i = 200;            j = 0;          // Memo 最多放 200 行
Memo->Clear();      Memo->Hide();
StrUpper(rtmp1);                    // 轉成大寫比較
while (i > 0) {
    if (j >= rem->Count) break;     // 沒字串了
    StrCopy(rtmp, rem->Strings[j]); // 取出一行註解
    if (AnsiStrPos(StrUpper(rtmp), rtmp1) != NULL) {    // 找到了 (不論大小寫)
        Memo->Lines->Add(rem->Strings[j]);      // Show 該行註解
        i --;
        }
    j ++;
    }
Memo->Show();
}
//---------------------------------------------------------------------------
void __fastcall TREMGO::FirstAddRem(unsigned int adr, char *str)
{           // 加入 adr 位址的註解 str (第一次分析 ELF 檔頭時使用)
int     i;
unsigned int    kv;

if (rem == NULL) initREM();
wsprintf(rtmp, "$%08lX:%s", adr, str);
wsprintf(rtmp1, "$%08lX", adr);
i = rem->Where(rtmp1);   // 二元搜尋可能位置
do  {   // 已有則先刪除, 只保留一行
    if (i >= rem->Count) break;
    StrCopy(rtmp1, rem->Strings[i]);    // 要拷貝字串才能得到 key value !
    kv = rem->KeyValue;
    if (kv == adr) {
        rem->Delete(i);
        wsprintf(rtmp, "%s, %s", rtmp1, str);   // 把後出現的字串接於其後
        }
    } while (kv <= adr);
rem->Insert(0, rtmp, adr);      // 新增
if ((rem->Count & 255) == 0){   // 每 256 行更新一次
    Show();     Refresh();            Panel1->Show();
    wsprintf(rtmp, "讀取 Symbol Line 第 %d 行", rem->Count);
    Panel1->Caption = rtmp;
    }
}
//---------------------------------------------------------------------------
void __fastcall TREMGO::Get_REM(int adr, char *dest)
{           // 取得一行註解內容
char    *p;
int     i, n, kv;

if (rem == NULL) return;        // 物件未初始化
n = rem->Count;
*dest = 0;      if (n == 0) return;
wsprintf(rtmp1, "$%08lX", adr);     // 轉成位址字串
i = rem->Where(rtmp1);          // 二元搜尋可能位置
n = 3;                          // 最多再看後面三個
while(true){
    StrCopy(rtmp, rem->Strings[i]);
    kv = rem->KeyValue;
    if (kv != adr) { n--;  i++; }
    else {      // 找到了 !
        p = StrPos(rtmp, ":");    // 前方的位址值可跳過
        if (p == NULL) return;
        StrCopy(dest, p+1);
        return;
        }
    if (n < 1) return;
    };
}
//---------------------------------------------------------------------------
void __fastcall TREMGO::initREM(void)
{           // 借記憶體
rem = (TPasString2 *) AllocMem(52);     // 13 個內部 private 物件
rem->Setup(MAXLINE, REMSIZE, true, true);
rem->Clear();
mstr = (char *) AllocMem(MEMOSIZE);
rtmp = (char *) AllocMem(256);
rtmp1 = (char *) AllocMem(256);
}
//---------------------------------------------------------------------------
void __fastcall TREMGO::LoadREM(char *fname)
{           // 載入檔案的說明
int     hnd, i, fptr, v;
char    *p, *p1;
char    CR[2];

hnd = FileOpen(fname, fmOpenRead);
if (rem == NULL) initREM();     // 建立物件
if (hnd < 1) return;            // 沒有註解檔 !
CR[0] = 13;     CR[1] = 0;
// 以下開始擷取註解資料
fptr = 0;       p = rtmp;
while(1){
    FileSeek(hnd, fptr, 0);
    setmem(p, TMPSIZE, 0);
    FileRead(hnd, p, TMPSIZE);  // 一次讀入 256 bytes, 只解析一行
    if (*p == 10) *p = ' ';     // 是換行的延續
    if (*p == 0) break;         // 沒資料了
    p1 = StrPos(p, CR);         // 找換行符號
    if (p1 == NULL) break;      // 沒資料了
    *p1 = 0;
    v = GetHex(p);
    CmbBx->Items->Add("$" + IntToHex(v, 8));
    rem->Insert(0, p, v);
    fptr += (p1-p+2);           // !! CR,LF 共貳字 !!
    if ((rem->Count & 255) == 0){   // 每 256 行更新一次
        Show();     Refresh();      Panel1->Show();
        wsprintf(rtmp, "正在讀取註解檔第 %ld 行", rem->Count);
        Panel1->Caption = rtmp;
        }
    }
Panel1->Hide();
FileClose(hnd);
nowLine = 0;
wsprintf(rtmp, "輸入註解 : 現有 %ld 行", rem->Count);
REMGO->Caption = rtmp;
UpdateMemo();       // 從 nowLine 起看 rem->Strings
Hide();
}
//---------------------------------------------------------------------------
void __fastcall TREMGO::SetOneREM(TObject *Sender)
{           // 確定寫入此行註解
int     adr, i, kv;
ShortString  s;

if (rem == NULL) initREM();
adr = GetHex(CmbBx->Text.c_str());
TopAddr = adr;          // 設立欲前往的位址
CmbBx->Items->Add("$" + IntToHex(adr, 8));
wsprintf(rtmp, "$%08lX:%s", adr, AddrEdit->Text.c_str());
wsprintf(rtmp1, "$%08lX", adr);     // 以此位址值來搜尋
i = rem->Where(rtmp1);   // 二元搜尋可能位置
do  {   // 已有則先刪除, 只保留一行
    if (i >= rem->Count) break;
    StrCopy(rtmp1, rem->Strings[i]);    // 要拷貝字串才能得到 key value !
    kv = rem->KeyValue;
    if (kv == adr) rem->Delete(i);
    i ++;
    } while (kv <= adr);
rem->Insert(0, rtmp, adr);     // 新增
wsprintf(rtmp, "輸入註解 : 現有 %ld 行", rem->Count);
REMGO->Caption = rtmp;
UpdateMemo();   // Memo 更新
Hide();
PS2MAIN->MainPaint(NULL);      // 主畫面重畫
}
//---------------------------------------------------------------------------
void __fastcall TREMGO::UpdateMemo(void)
{       // 從 nowLine 起看 rem->Strings
char    *p;
int     i, j;

i = 200;        // 最多放 200 行
j = nowLine;
Memo->Clear();      Memo->Hide();
p = mstr;
while (i > 0) {
    if (j >= rem->Count) break;     // 沒字串了
    StrCopy(p, rem->Strings[j]);
    p += StrLen(rem->Strings[j]);
    *p = 13;    p[1] = 10;      p += 2;     *p = 0;
    j ++;   i--;
    }
Memo->SetTextBuf(mstr);
Memo->Show();
Refresh();
}
//---------------------------------------------------------------------------
void __fastcall TREMGO::ViewNext200(TObject *Sender)
{           // 看後 200 行
if (rem == NULL) initREM();
nowLine += 200;
if (nowLine >= rem->Count) nowLine = rem->Count - 200;
if (nowLine < 0) nowLine = 0;
UpdateMemo();
}
//---------------------------------------------------------------------------
void __fastcall TREMGO::ViewPrev200(TObject *Sender)
{           // 看前 200 行
if (rem == NULL) initREM();
nowLine -= 200;
if (nowLine >= rem->Count) nowLine = rem->Count - 200;
if (nowLine < 0) nowLine = 0;
UpdateMemo();
}
//---------------------------------------------------------------------------
void __fastcall TREMGO::SaveCurrentREM(char *fname)
{           // 為目前的註解存檔
int     fh, i;
char    CR[3];

// ChangeFileExt(fname, ".REM");
fh = FileCreate(fname);
if (fh < 0) {
    MessageBox(REMGO->Handle, "無法寫入註解檔", "檔案建立失敗", MB_OK);
    return;
    }
CR[0] = 13;     CR[1] = 10;     CR[2] = 0;
for (i=0;i < rem->Count;i ++) {     // 逐行記錄
    StrCopy(rtmp, rem->Strings[i]); // 取出一行註解
    FileWrite(fh, rtmp, StrLen(rtmp));
    FileWrite(fh, CR, 2);
    }
FileClose(fh);
rem->Clear();   Memo->Clear();      // 恢復空白狀態
}
//---------------------------------------------------------------------------
void __fastcall TREMGO::SetMemoSize(TObject *Sender)
{
AddrEdit->Width = REMGO->Width - 23;
Memo->Width = REMGO->Width - 23;
Memo->Height = REMGO->Height - 125;
}
//---------------------------------------------------------------------------

