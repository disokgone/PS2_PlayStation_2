//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("PS2MAIN.res");
USEUNIT("GENERAL.cpp");
USEUNIT("Mips.cpp");
USEUNIT("Passtr2.pas");
USEFORM("ELF_VIEW.cpp", ELFView);
USEFORM("GO_REM.cpp", REMGO);
USEFORM("PS2MAN.cpp", PS2MAIN);
USEFORM("QHDUMP.cpp", QDump);
USEFORM("SFIND.cpp", XFIND);
USEFORM("PS2About.cpp", AboutR5K);
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
    try
    {
        Application->Initialize();
        Application->Title = "PlayStation2 (R5900) disassembler version 1.00";
        Application->HelpFile = "D:\\BCBS\\PS2\\Ps2.hlp";
        Application->CreateForm(__classid(TPS2MAIN), &PS2MAIN);
        Application->CreateForm(__classid(TREMGO), &REMGO);
        Application->CreateForm(__classid(TELFView), &ELFView);
        Application->CreateForm(__classid(TQDump), &QDump);
        Application->CreateForm(__classid(TXFIND), &XFIND);
        Application->CreateForm(__classid(TAboutR5K), &AboutR5K);
        Application->Run();
    }
    catch (Exception &exception)
    {
        Application->ShowException(&exception);
    }
    return 0;
}
//---------------------------------------------------------------------------


