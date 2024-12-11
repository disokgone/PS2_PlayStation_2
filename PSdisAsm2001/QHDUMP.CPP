//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop

#include "QHDUMP.h"
#include "ELF_VIEW.h"   // ELF header viewer 程式
#include "GENERAL.h"        // 一般函式定義

#define QDUMPSIZE   5120
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TQDump *QDump = NULL;
unsigned char   *qdump;     // 放即將顯示的內容
extern char     *temp;      // 1024 bytes (in PS2MAN.cpp)
int     xchr;       // 一行要 dump 多少 bytes
int     yline;      // 螢幕有多少行
short   TxtHt;      // 一字之高度
//---------------------------------------------------------------------------
__fastcall TQDump::TQDump(TComponent* Owner)
    : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TQDump::calcScrSize(void)
{       // 計算 Quick Dump 畫面大小
TxtHt = QDump->Canvas->TextHeight("I");
yline = (QDump->Height - 40) / TxtHt;
xchr = StrToInt(Edit1->Text);
Memo1->Top = QDump->Height - Memo1->Height - 43;
}
//---------------------------------------------------------------------------
void __fastcall TQDump::chkEnter(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
if (Key == 0x0D) reDrawIt(this);
}
//---------------------------------------------------------------------------
void __fastcall TQDump::DumpVA(int vadr)
{       // 從虛擬位址 vadr 起顯示資料
TRect   rc;
int     adr, i, n, y;
char    *p, *p1, c;

calcScrSize();          // 計算 Quick Dump 畫面大小
rc = Canvas->ClipRect;  Memo1->Hide();
rc.Top = 40;
Canvas->FillRect(rc);   // 清除畫面
if (qdump == NULL) qdump = (unsigned char *) AllocMem(QDUMPSIZE);
if (xchr <= 0) return;
CBx1->Text = "$" + IntToHex(vadr, 8);
ELFView->readFileTo(qdump, vadr, QDUMPSIZE);
p = temp + 256;     p1 = temp + 512;
n = 0;              adr = vadr;
for (y=0;y < yline;y ++, adr += xchr) {
    wsprintf(p, "$%08lX - ", adr);
    for (i=0;i < xchr;i++, n++) {
        wsprintf(p1, "%02X ", qdump[n]);
        StrCat(p, p1);
        }
    n -= xchr;
    for (i=0;i < xchr;i++, n++) {
        c = qdump[n];
        if (c < 0x20) c = '.';
        p1[i] = c;
        }
    p1[i] = 0;
    StrCat(p, p1);
    Canvas->TextOut(0, 40 + (y * TxtHt), p);
    }
}
//---------------------------------------------------------------------------
void __fastcall TQDump::reDrawIt(TObject *Sender)
{       // OnPaint 事件
DumpVA(GetHex(CBx1->Text.c_str()));
}
//---------------------------------------------------------------------------
void __fastcall TQDump::showTextMemo(TObject *Sender)
{
int     adr, i, j, n, y;
char    *p1, c;

Memo1->Clear();         Memo1->Show();
p1 = temp + 256;        adr = StrToInt(CBx1->Text);
n = 0;
for (y=0;y < yline;y ++, adr += xchr) {
    wsprintf(p1, "$%08lX - ", adr);
    for (i = j = 0;i < xchr;i++, j++, n++) {
        c = qdump[n];
        if (c < 0x20) { p1[12+j] = '\\';  j ++;
            switch(c)   {
                case  8: c = 'b';       break;
                case  9: c = 't';       break;
                case 10: c = 'n';       break;
                case 13: c = 'r';       break;
                default: j --;          c = ' ';
                }       }
        p1[12+j] = c;
        }
    p1[12+j] = 0;
    Memo1->Lines->Add(StrPas(p1));
    }
Memo1->SelStart = 0;    Memo1->SelLength = 0;
}
//---------------------------------------------------------------------------

