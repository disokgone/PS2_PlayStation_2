//---------------------------------------------------------------------------
#ifndef GO_REMH
#define GO_REMH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ExtCtrls.hpp>
//---------------------------------------------------------------------------
class TREMGO : public TForm
{
__published:	// IDE-managed Components
    TLabel *Label1;
    TComboBox *CmbBx;
    TEdit *AddrEdit;
    TMemo *Memo;
    TButton *Btn1;
    TButton *Btn2;
    TButton *Btn3;
    TButton *Btn4;
    TButton *Btn5;
    TPanel *Panel1;
    void __fastcall Btn2Click(TObject *Sender);
    void __fastcall chkEditCuts(TObject *Sender, WORD &Key, TShiftState Shift);
    void __fastcall FastAddrToGo(TObject *Sender);
    void __fastcall FindRemStr(TObject *Sender);
    void __fastcall Get_REM(int adr, char *dest);
    void __fastcall initREM(void);
    void __fastcall LoadREM(char *fname);
    void __fastcall SaveCurrentREM(char *fname);    // 為目前的註解存檔
    void __fastcall SetOneREM(TObject *Sender);
    void __fastcall UpdateMemo(void);       // 從 nowLine 起看 rem->Strings
    void __fastcall ViewNext200(TObject *Sender);
    void __fastcall ViewPrev200(TObject *Sender);
        void __fastcall SetMemoSize(TObject *Sender);
private:	// User declarations
public: 	// User declarations
    __fastcall TREMGO(TComponent* Owner);
    void __fastcall DestAddrRem(char *p);   // 以指令的目的碼尋找註解
    void __fastcall FirstAddRem(unsigned int adr, char *str);   // 加入 adr 位址的註解 str (第一次分析 ELF 檔頭時使用)
};
//---------------------------------------------------------------------------
extern PACKAGE TREMGO *REMGO;
//---------------------------------------------------------------------------
#endif
