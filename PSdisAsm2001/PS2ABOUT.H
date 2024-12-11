//---------------------------------------------------------------------------
#ifndef PS2AboutH
#define PS2AboutH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ExtCtrls.hpp>
#include <Graphics.hpp>
//---------------------------------------------------------------------------
class TAboutR5K : public TForm
{
__published:	// IDE-managed Components
    TImage *Image1;
    TButton *Button1;
    TLabel *Label1;
    TLabel *Label2;
    TComboBox *ComboBox1;
    void __fastcall doClose(TObject *Sender);
private:	// User declarations
public:		// User declarations
    __fastcall TAboutR5K(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TAboutR5K *AboutR5K;
//---------------------------------------------------------------------------
#endif
