//---------------------------------------------------------------------------
#ifndef QHDUMPH
#define QHDUMPH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
//---------------------------------------------------------------------------
class TQDump : public TForm
{
__published:	// IDE-managed Components
    TLabel *L1;
    TComboBox *CBx1;
    TLabel *L2;
    TEdit *Edit1;
    TButton *Btn1;
        TButton *Btn2;
        TMemo *Memo1;
    void __fastcall reDrawIt(TObject *Sender);
    void __fastcall chkEnter(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall showTextMemo(TObject *Sender);
private:	// User declarations
public:		// User declarations
    __fastcall TQDump(TComponent* Owner);
    void __fastcall calcScrSize(void);  // 計算 Quick Dump 畫面大小
    void __fastcall DumpVA(int vadr);   // 從虛擬位址 vadr 起顯示資料

};
//---------------------------------------------------------------------------
extern PACKAGE TQDump *QDump;
//---------------------------------------------------------------------------
#endif
