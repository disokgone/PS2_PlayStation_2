//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop

#include "PS2MAN.h"
#include "ELF_VIEW.h"       // ELF header viewer 程式
#include "GENERAL.h"        // 一般函式定義
#include "GO_REM.H"         // 自動化註解程式
#include "MIPS.h"           // MIPS 反組譯程式
#include "PS2About.h"       // About this program
#include "QHDUMP.h"         // 快速 Hex Dump 顯示
#include "SFIND.h"          // 搜尋資料

#define MAINBUFSIZE     5120
#define TEXTLINESIZE    64

#define MAXXCHARS       256
#define MAXYLINES       64
#define MAXGOSTACK      64

enum SCR_MODES { UAMODE, HEXMODE, TXTMODE };
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TPS2MAIN *PS2MAIN;

byte *buf;          // 主檔案的緩衝區
char *scr, *temp, *temp2;   // 畫面處理用的一行緩衝區, 一般處理用的緩衝區
char *scrAll;       // 主畫面的緩衝區 MAXYLINES * MAXXCHARS
int dragLine;       // 滑鼠左鍵抓住移動的行號
int goStk, *goStack;    // 快速移動時保留上次觀看位址
int lastY = 255;    // 上次滑鼠左鍵抓住移動更新顯示的行號
int mouseAddr;      // 滑鼠指到的數值
int fhnd;           // 開啟的主檔案代碼
int outfile = 0;    // 畫面存檔用的代碼
int fptr = 0;       // 主檔案目前的讀取位址
int fsize = 0;      // 主檔案的檔案大小
int gpAddr = 0;     // 全域變數的位址
int TopAddr = 0;    // 主畫面目前的位址
short scrLines;     // 畫面可顯示的行數
short TextHeight;   // 主畫面文字高度
short msX, msY;     // 目前滑鼠的文字座標
char scrMode = UAMODE;      // 0 = Code DisAsm, 1 = Hex dump, 2 = Text dump
char SEESYMBOL = 0;         // 看重定位符號
extern char	USEALIAS;		// CPU 暫存器名稱 (非零值=使用別名, 0=使用Rnn)
extern char	UPPERCA;		// 輸出字串大小寫 (非零值=大寫, 0=小寫)
bool toQuit = false;        // 程式即將關閉
extern bool HasFile;        // 是否已讀入檔案 (in ELF_View.cpp)

//---------------------------------------------------------------------------
__fastcall TPS2MAIN::TPS2MAIN(TComponent* Owner)
    : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::CenterThisLine(TObject *Sender)
{       // 滑鼠右鍵選單 : 此行居中
int     newY;

newY = msY - (scrLines >> 1);   // 取得目前和主畫面正中央差幾行
switch(scrMode) {               // 計算 byte 差距
    case UAMODE:
        newY = newY << 2;       // 1 line = 4 byte
        break;
    case HEXMODE:
        newY = newY << 4;       // 1 line = 16 byte
        break;
    case TXTMODE:
        newY = newY << 6;       // 1 line = 64 byte
        break;
    }
TopAddr = TopAddr + newY;       // 移至新位置顯示
MainPaint(this);                // 主畫面重畫
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::CheckMsClk(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{           // 是否使用滑鼠左, 右鍵
int v;
char *p, c;

MouseMoveXY(this, Shift, X, Y);     // 計算滑鼠新座標 msX, msY
p = scrAll + (MAXXCHARS * msY) + msX - 1;
c = *p;         if (p[1] != '$') *p = '$';
v = GetHex(p);  *p = c;   mouseAddr = v;            // 滑鼠指到的數值
StBar->Panels->Items[3]->Text="$"+IntToHex(v, 8);
PMenuGoTo->Caption = "Go to $" + IntToHex(v, 8);    // Goto 位址
if (goStk > 0) v = goStack[goStk - 1];
else v = 0;
PMenuGoback->Caption = "Go back $" + IntToHex(v, 8);    // Goback 位址
if (Button == mbRight) MSPMenu->Popup(X, Y);        // 選用彈出選單
if (Button == mbLeft) {
    lastY = msY;    dragLine = lastY;   // 記住此行位置
    MouseMoveXY(this, Shift, X, Y);     // 畫出反白行
    }
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::CloseLastFiles(void)
{       // 關閉上次開啟的檔案
if (fhnd < 1) return;       // 未開檔案
REMGO->SaveCurrentREM(OpenDlg->FileName.c_str());   // 註解存檔
FileClose(fhnd);
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::closeMe(TObject *Sender, TCloseAction &Action)
{       // 程式即將關閉
MenuQuitClick(this);
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::doTextDump(TObject *Sender)
{
scrMode = TXTMODE;
MainPaint(this);
}
//---------------------------------------------------------------------------

void __fastcall TPS2MAIN::doHexDump(TObject *Sender)
{
scrMode = HEXMODE;
MainPaint(this);
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::doDisAsm(TObject *Sender)
{
scrMode = UAMODE;
MainPaint(this);
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::FastGoBack(TObject *Sender)
{
if (goStk > 0) {
    goStk --;
    TopAddr = goStack[goStk];       // 取出舊位址
    }
MainPaint(this);
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::FastGoTo(TObject *Sender)
{
if (goStk < MAXGOSTACK) {
    goStack[goStk] = TopAddr;       // 記住舊位址
    goStk ++;
    }
TopAddr = mouseAddr;
MainPaint(this);
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::Key_Down(void)
{
switch(scrMode) {
    case UAMODE:    TopAddr += 4;   break;
    case HEXMODE:   TopAddr += 16;  break;
    case TXTMODE:   TopAddr += TEXTLINESIZE;     break;
    }
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::Key_End(void)
{
fptr = ELFView->GetFinalAddr();     // 傳回最後一字位址
switch(scrMode) {
    case UAMODE:    TopAddr = fptr - (scrLines << 2);   break;
    case HEXMODE:   TopAddr = fptr - (scrLines << 4);   break;
    case TXTMODE:   TopAddr = fptr - (scrLines * TEXTLINESIZE); break;
    }
fptr = TopAddr;
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::Key_Home(void)
{
TopAddr = 0;
fptr = TopAddr;
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::Key_PageDown(void)
{
switch(scrMode) {
    case UAMODE:    TopAddr += (scrLines << 2);     break;
    case HEXMODE:   TopAddr += (scrLines << 4);     break;
    case TXTMODE:   TopAddr += (scrLines * TEXTLINESIZE);   break;
    }
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::Key_PageUp(void)
{
switch(scrMode) {
    case UAMODE:    TopAddr -= (scrLines << 2);     break;
    case HEXMODE:   TopAddr -= (scrLines << 4);     break;
    case TXTMODE:   TopAddr -= (scrLines * TEXTLINESIZE);   break;
    }
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::Key_Up(void)
{
switch(scrMode) {
    case UAMODE:    TopAddr -= 4;   break;
    case HEXMODE:   TopAddr -= 16;  break;
    case TXTMODE:   TopAddr -= TEXTLINESIZE;    break;
    }
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::KeyWorks(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
bool    needRepaint;

needRepaint = true;
switch(Key) {
    case VK_UP:     Key_Up();       break;
    case VK_DOWN:   Key_Down();     break;
    case VK_PRIOR:  Key_PageUp();   break;
    case VK_NEXT:   Key_PageDown(); break;
    case VK_HOME:   Key_Home();     break;
    case VK_END:    Key_End();      break;
    case VK_F2:     USEALIAS ^= 1;  break;  // CPU 暫存器名稱
    case VK_F3:     UPPERCA ^= 1;   break;  // 輸出字串大小寫
    case VK_F4:     SEESYMBOL ^= 1; break;  // 看重定位符號
    default:    needRepaint = false;    break;
    }
if (needRepaint) MainPaint(this);
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::MenuContentsClick(TObject *Sender)
{
Application->HelpFile = ExtractFilePath(Application->ExeName) + "PS2.HLP";
Application->HelpJump("PS2_Main_Help");
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::MainCreate(TObject *Sender)
{
scrAll = (char *) AllocMem(MAXYLINES * MAXXCHARS);  // 主畫面的緩衝區
buf = (byte *) AllocMem(MAINBUFSIZE);   // 主檔案的緩衝區
scr = (char *) AllocMem(256);           // 畫面處理用的一行緩衝區
temp = (char *) AllocMem(1024);         // 一般處理用的緩衝區
temp2 = (char *) AllocMem(1024);        // 一般處理用的緩衝區
goStack = (int *) AllocMem(MAXGOSTACK * 4); // 快速移動時保留上次觀看位址
goStk = 0;
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::MainPaint(TObject *Sender)
{
byte    *p;
char    *scrPtr;
int     addr, i, j;
char    rtv;

scrLines = calcScrLines(PS2MAIN);           // 取得畫面可顯示的行數
Panel1->Width = PS2MAIN->Width - 9;         // 設立下方 Panel 寬度
scrPtr = scrAll;
p = buf;    addr = TopAddr;
if (scrMode == UAMODE) addr -= (addr & 3);  // 必須與 4n 切齊
NOWPC = addr;  fptr = addr;
StBar->Panels->Items[0]->Text = "$" + IntToHex(addr, 8);
ELFView->readFileTo(buf, fptr, MAINBUFSIZE);
switch(scrMode) {
    case UAMODE:
        for (i = 0;i < scrLines;i ++, scrPtr += MAXXCHARS) {
            wsprintf(temp, "$%08lX - ", addr);
            rtv = DisAsmMIPS((void *) p, scr);
            if (rtv) wsprintf(scr, "---???---  %s", GetUAerror(rtv));
            StrCat(temp, scr);
            padSpaces(temp, 44);    // 補足長度到 44 字
            if (SEESYMBOL) {
                StrCopy(temp2, temp);   // temp 會被破壞, 要先備份
                ELFView->GetSymbol(addr, scr);
                StrCopy(temp, temp2);
                }
            else {      // HexDump 4 bytes
                for (j=3;j >= 0;j--) {
                    wsprintf(scr, "%02X", p[j]);
                    StrCat(temp, scr);
                    }
                StrCat(temp, "  ");
                for (j=3;j >= 0;j--) scr[j] = (p[j] > 31) ? p[j] : '.';
                scr[4] = 0;
                }
            StrCat(temp, scr);
            padSpaces(temp, 59);    // 補足長度到 59 字
            scr[0] = 0;
            REMGO->Get_REM(addr, scr);      StrCat(temp, scr);
            if (StrLen(temp) < 60) {    // 嘗試增加一些註解
                StrCopy(scr, temp+12);  // 抓一段文字去找註解
                REMGO->DestAddrRem(scr);    // 以指令的目的碼尋找註解
                StrCat(temp, scr);
                }
            StrCopy(scrPtr, temp);
            p += 4;     addr += 4;
            }
        break;

    case HEXMODE:
        for (i = 0;i < scrLines;i ++, scrPtr += MAXXCHARS) {
            wsprintf(temp, "$%08lX - ", addr);
            for (j=0;j < 16;j++) {
                wsprintf(scr, "%02X ", p[j]);
                StrCat(temp, scr);
                }
            for (j=0;j < 16;j++) scr[j] = (p[j] > 31) ? p[j] : '.';
            scr[16] = 0;    StrCat(temp, scr);
            StrCopy(scrPtr, temp);
            p += 16;    addr += 16;
            }
        break;
    case TXTMODE:
        for (i = 0;i < scrLines;i ++, scrPtr += MAXXCHARS) {
            wsprintf(temp, "$%08lX - ", addr);
            for (j=0;j < TEXTLINESIZE;j++) scr[j] = (p[j] > 31) ? p[j] : '.';
            scr[TEXTLINESIZE] = 0;    StrCat(temp, scr);
            StrCopy(scrPtr, temp);
            p += TEXTLINESIZE;    addr += TEXTLINESIZE;
            }
        break;
    }

Canvas->FillRect(Canvas->ClipRect);
for (i = 0, j = 0, scrPtr = scrAll;i < scrLines;i ++) {
    Canvas->TextOut(0, j, scrPtr);
     j += TextHeight;
    scrPtr += MAXXCHARS;
    }
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::MenuAboutClick(TObject *Sender)
{       // 看關於本程式
if (AboutR5K->ComboBox1->ItemIndex > 0) AboutR5K->ComboBox1->ItemIndex = 0;
AboutR5K->Show();
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::MenuELFhdrClick(TObject *Sender)
{
ELFView->Show();
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::MenuFindClick(TObject *Sender)
{
XFIND->Show();
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::MenuGotoAddrClick(TObject *Sender)
{
REMGO->CmbBx->Text = StBar->Panels->Items[3]->Text;     // 用滑鼠所指位址
REMGO->Get_REM(mouseAddr, temp);
REMGO->AddrEdit->Text = temp;
REMGO->Show();                  // 使用者輸入欲跳到的位址
REMGO->AddrEdit->SetFocus();    // 讓 Edit 物件編修
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::MenuOpenFileClick(TObject *Sender)
{
if (HasFile) {  // 已開啟檔案
    CloseLastFiles();           // 關閉上次開啟的檔案
    }
else OpenDlg->InitialDir = "C:\\PSX\\PSII";
// else OpenDlg->InitialDir = ExtractFilePath(Application->ExeName);
if (OpenDlg->Execute()) {
    fhnd = FileOpen(OpenDlg->FileName, fmOpenRead);
    if (fhnd <= 0) {    // 開啟失敗
        MessageBox(PS2MAIN->Handle, "檔案開啟失敗 !", "錯誤", IDOK);
        return;
        }
    else {              // 開啟成功
        Caption = "PlayStation 2 -" + OpenDlg->FileName;
        fsize = FileSeek(fhnd, 0, 2);
        OpenDlg->FileName = ChangeFileExt(OpenDlg->FileName, ".REM");
        ELFView->MainELFheader();       // 檢查是否有 ELF 檔頭
        StBar->Panels->Items[2]->Text = "gp=$" + IntToHex(gpAddr, 8);
        StBar->Panels->Items[3]->Text = "$" + IntToHex(TopAddr, 8);
        REMGO->LoadREM(OpenDlg->FileName.c_str());  // 讀取註解檔
        }
    MainPaint(this);
    }
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::MenuQuitClick(TObject *Sender)
{
toQuit = true;          // 程式即將關閉
CloseLastFiles();       // 關閉上次開啟的檔案
Application->Terminate();
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::MouseMoveXY(TObject *Sender, TShiftState Shift,
      int X, int Y)
{       // OnMouseMove 事件
TRect   rc;
TColor  oldC;

msX = (short) (X / Canvas->TextWidth("X"));
msY = (short) (Y / TextHeight);
StBar->Panels->Items[1]->Text="("+IntToStr(msX)+", "+IntToStr(msY)+")";
if (lastY < 255) {      // 預視上下捲動畫面
    if (msY >= 0) {
        rc.Top = dragLine * TextHeight;
        rc.Bottom = rc.Top + TextHeight;
        Canvas->FillRect(rc);               // 蓋掉註解
        Canvas->TextOut(0, rc.Top, scrAll+(MAXXCHARS * dragLine));      // 恢復原有資料
        }
    oldC = Canvas->Font->Color;
    Canvas->Font->Color = clWhite;
    Canvas->TextOut(0, msY * TextHeight,  scrAll+(MAXXCHARS * lastY));  // 預視結果
    Canvas->Font->Color = oldC;
    dragLine = msY;
    }
else {
    if (msX > 58) {    // 顯示太長的註解
        if (StrLen(scrAll + (msY * 256)) > 78) {
            Panel1->Caption = scrAll + (msY * 256) + 58;
            Panel1->Show();
            }
        }
    else Panel1->Hide();
    }
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::QuickHexDump(TObject *Sender)
{
QDump->DumpVA(mouseAddr);       // 從虛擬位址 mouseAdr 起顯示資料
QDump->Show();
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::saveScrn(TObject *Sender)
{           // 主畫面內容存檔
int     i;
char    *p;
char    crlf[3];

if (outfile < 1) {
    if (SaveDlg->Execute()) {   // 建立新檔
        outfile = FileCreate(SaveDlg->FileName);
        if (outfile <= 0) {    // 建立失敗
            MessageBox(PS2MAIN->Handle, "無法建立新檔 !", "錯誤", IDOK);
            return;
            }
        }
    }

p = scrAll;
crlf[0] = 13;   crlf[1] = 10;   crlf[2] = 0;
for (i=0;i < scrLines;i ++) {
    FileWrite(outfile, p, StrLen(p));
    FileWrite(outfile, crlf, 2);
    p += MAXXCHARS;
    }
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::setBackTrace(TObject *Sender)
{           // 滑鼠右鍵要求逆追蹤
extern char findID;

XFIND->EdBkadr->Text = "$" + IntToHex(mouseAddr, 8);
findID = 2;     // 2 = BACKTRACE
XFIND->Show();
XFIND->doBktrace(this);
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::StopMouseScroll(TObject *Sender,
      TMouseButton Button, TShiftState Shift, int X, int Y)
{       // OnMouseUp 事件
int     i;

if (Button == mbLeft) { // 之前確定是滑鼠捲動畫面
    MouseMoveXY(this, Shift, X, Y);     // 計算滑鼠新座標 msX, msY
    if (msY < 0) msY = 0;
    do  {       // 捲動畫面
        i = msY - lastY;
        if (i > 0) { Key_Up();      lastY ++; }
        if (i < 0) { Key_Down();    lastY --; }
        if (lastY < 1) lastY = 0;
        } while (i != 0);
    // if (Panel1.Visible) then Offhints;   { 有說明便關閉說明 }
    MainPaint(this);        // 主畫面重畫
    lastY = 255;            // 停止捲動
    }
}
//---------------------------------------------------------------------------
void __fastcall TPS2MAIN::TextViewFromMouseLoc(TObject *Sender)
{       // 滑鼠右鍵選單 : 從滑鼠指到的數值 Text Dump !
lastY = 255;            // Disable scrolling, 停止捲動
TopAddr = mouseAddr;    // 滑鼠指到的數值
scrMode = TXTMODE;
MainPaint(this);        // 主畫面重畫
}
//---------------------------------------------------------------------------

