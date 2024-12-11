//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop

#include "PS2About.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TAboutR5K *AboutR5K;
//---------------------------------------------------------------------------
__fastcall TAboutR5K::TAboutR5K(TComponent* Owner)
    : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TAboutR5K::doClose(TObject *Sender)
{
Close();
}
//---------------------------------------------------------------------------
