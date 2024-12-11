program MY_USB;

uses
  Forms,
  MY_USB1 in 'MY_USB1.pas' {MYUSB},
  PC_PS2MC in 'PC_PS2MC.pas',
  PS2Icon in 'PS2Icon.pas' {ICONS},
  SavGmDir in 'SavGmDir.pas' {SaveGameDir};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMYUSB, MYUSB);
  Application.CreateForm(TICONS, ICONS);
  Application.CreateForm(TSaveGameDir, SaveGD);
  Application.Run;
end.
