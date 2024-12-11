//---------------------------------------------------------------------------
#ifndef PS2MANH
#define PS2MANH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <Menus.hpp>
#include <Dialogs.hpp>
#include <ComCtrls.hpp>
#include <ExtCtrls.hpp>
//---------------------------------------------------------------------------
class TPS2MAIN : public TForm
{
__published:	// IDE-managed Components
    TMainMenu *MainMenu1;
    TMenuItem *MenuFile1;
    TMenuItem *MenuOpenFile;
    TMenuItem *MenuPrintScr;
    TMenuItem *MenuQuit;
    TMenuItem *MenuN1;
    TMenuItem *MenuSearch;
    TMenuItem *MenuFind;
    TMenuItem *MenuGotoAddr;
    TMenuItem *MenuHelp;
    TMenuItem *MenuContents;
    TMenuItem *MenuIndex;
    TMenuItem *MenuAbout;
    TMenuItem *MenuView;
    TMenuItem *MenuDisasm;
    TMenuItem *MenuELFhdr;
    TMenuItem *MenuHexDump;
    TMenuItem *MenuTextDump;
    TPopupMenu *MSPMenu;
    TMenuItem *PMenuGoTo;
    TMenuItem *PMenuBkTrace;
    TMenuItem *PMenuQDump;
    TMenuItem *PMenuGoback;
    TMenuItem *PMenuView;
    TMenuItem *PMenuSaveScr;
    TMenuItem *PMenuAddRem;
    TMenuItem *PMenuCenter;
    TStatusBar *StBar;
    TOpenDialog *OpenDlg;
    TSaveDialog *SaveDlg;
    TPanel *Panel1;
    void __fastcall MenuOpenFileClick(TObject *Sender);
    void __fastcall MainCreate(TObject *Sender);
    void __fastcall MainPaint(TObject *Sender);
    void __fastcall doTextDump(TObject *Sender);
    void __fastcall doHexDump(TObject *Sender);
    void __fastcall doDisAsm(TObject *Sender);
    void __fastcall Key_Down(void);
    void __fastcall Key_End(void);
    void __fastcall Key_Home(void);
    void __fastcall Key_PageDown(void);
    void __fastcall Key_PageUp(void);
    void __fastcall Key_Up(void);
    void __fastcall KeyWorks(TObject *Sender, WORD &Key,
          TShiftState Shift);
    void __fastcall MouseMoveXY(TObject *Sender, TShiftState Shift, int X,
          int Y);
    void __fastcall MenuGotoAddrClick(TObject *Sender);
    void __fastcall MenuQuitClick(TObject *Sender);
    void __fastcall CheckMsClk(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
    void __fastcall FastGoTo(TObject *Sender);
    void __fastcall MenuELFhdrClick(TObject *Sender);
    void __fastcall StopMouseScroll(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
    void __fastcall CenterThisLine(TObject *Sender);
    void __fastcall TextViewFromMouseLoc(TObject *Sender);
    void __fastcall FastGoBack(TObject *Sender);
    void __fastcall QuickHexDump(TObject *Sender);

    void __fastcall MenuFindClick(TObject *Sender);
    void __fastcall setBackTrace(TObject *Sender);
    void __fastcall saveScrn(TObject *Sender);
    void __fastcall MenuAboutClick(TObject *Sender);
    void __fastcall closeMe(TObject *Sender, TCloseAction &Action);
    void __fastcall MenuContentsClick(TObject *Sender);
private:	// User declarations
    void __fastcall CloseLastFiles(void);   // 關閉上次開啟的檔案
public:		// User declarations
    __fastcall TPS2MAIN(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TPS2MAIN *PS2MAIN;
//---------------------------------------------------------------------------
#endif
