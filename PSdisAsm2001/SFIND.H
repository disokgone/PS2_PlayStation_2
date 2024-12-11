//---------------------------------------------------------------------------
#ifndef SFINDH
#define SFINDH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ExtCtrls.hpp>
//---------------------------------------------------------------------------
class TXFIND : public TForm
{
__published:	// IDE-managed Components
    TButton *Button1;
    TButton *Button2;
    TButton *Button3;
    TCheckBox *ChkBxTojpn;
    TCheckBox *ChkBxWCase;
    TEdit *EdBkadr;
    TEdit *EdHex;
    TEdit *EdText;
    TGroupBox *GroupBox1;
    TLabel *Label1;
    TLabel *Label2;
    TLabel *Label3;
    TMemo *Memo;
    TRadioGroup *RadGrpAlign;
    TRadioGroup *RadGrpDisp;
    void __fastcall checkClientSize(TObject *Sender);   // OnPaint 事件
    void __fastcall checkKeys(TObject *Sender, WORD &Key,
          TShiftState Shift);                       // 檢查按鍵
    void __fastcall doBktrace(TObject *Sender);     // 按逆追蹤鈕
    void __fastcall doSearch(TObject *Sender);
    void __fastcall findCancel(TObject *Sender);    // 放棄鈕
    void __fastcall setFindMode(TObject *Sender);   // 設定搜尋型態
    void __fastcall mayFastGoto(TObject *Sender);
private:	// User declarations
    void __fastcall BackSrh(void);      // 執行 Back Trace searching
    void __fastcall checkAllStatus(void);   // 把各個控制物件的狀態記錄下來
    void __fastcall findInit(void);     // 借記憶體, 將不釋還, 除非程式結束
    void __fastcall HexSrh(void);       // 執行 Hex search (case insensitive)
    bool __fastcall matchTarget(int *p, int vadr);  // 傳回是否合於目標位址
    void __fastcall SrhFound(int vadr, int ofs);    // 此位址可能符合, 仍然要看其餘條件
    void __fastcall TxtSrh(void);       // 執行 Text search
public:		// User declarations
    __fastcall TXFIND(TComponent* Owner);
};
//---------------------------------------------------------------------------
struct SFindX {
    int     bktrAddr;       // 逆追蹤位址
    int     targetLen;      // 要尋找字列的長度
    byte    *flist;         // 要尋找的字列
    char    alignType;      // 位址切齊 0=any, 1=2n, 2=4n, 3=2n+2
    char    displayMode;    // 顯示方式 0=UAsm, 1=Hex dump, 2=Text dump
    char    chRule;         // 1 = 大小寫要相符, 2 = 要轉為日文
};
//---------------------------------------------------------------------------
extern PACKAGE TXFIND *XFIND;
//---------------------------------------------------------------------------
#endif
