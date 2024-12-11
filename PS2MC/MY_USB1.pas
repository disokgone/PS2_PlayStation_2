unit MY_USB1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls,
  USBIO, USBIObuf, USBIOPipe, USBIO_I, USBSPEC, usbio_i_delphi, ComCtrls;

// {$I DEBUG.PAS}

type
  TMYUSB = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    CheckBox1: TCheckBox;
    Memo1: TMemo;
    OpenDlg: TOpenDialog;
    PrgsBar: TProgressBar;
    StatBar: TStatusBar;
    ListBox1: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    ListBox2: TListBox;
    Button7: TButton;
    SaveDlg1: TSaveDialog;
    Button8: TButton;
    procedure debugShowChg(Sender: TObject);
    procedure doAbort(Sender: TObject);
    procedure doEXECEE(Sender: TObject);
    procedure doReset(Sender: TObject);
    procedure formResize(Sender: TObject);
    procedure GoFunc1(Sender: TObject);
    procedure sendQuitToPS2(Sender: TObject);
    procedure sendToPS2(Sender: TObject);
    procedure ToClose1(Sender: TObject; var Action: TCloseAction);
    procedure ToCreateForm(Sender: TObject);
    procedure NameSwitch(Sender: TObject);
    procedure SeeItsName1(Sender: TObject);
    procedure SeeItsName2(Sender: TObject);
    procedure UseIt2(Sender: TObject);
    procedure UseIt1(Sender: TObject);
    procedure RestoreSaveGame(Sender: TObject);
    procedure MouseKeyDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    procedure CheckLineClear;
    procedure CleanUp;  { ����귽 }
    function  do_recv_process_Pkt: Integer;
    function  GetPS2Return(pDst: PChar): Integer;
    procedure MainPipeCommand(Req: Byte; wrtValue: Word);
    procedure RecordPath;
    function  recv_packet(pReadIn: PChar; var LenRead: Cardinal): Integer;
    procedure ReloadPath;
    function  sendInfoToPS2(value, BufLen: Integer; pBuf: PChar): Integer;
    function  send_packet(WtBuf: PChar): Integer;
    procedure TellBad;
    function  WaitAndStatus(testValue: Byte): Byte;
    function  WaitLineStatusOK(waitms: Integer): Byte;
    procedure WaitPeer; { ���ݹ����I�^�� }
    function  WaitProcessPkt: Boolean;          { ���ݨóB�z�������ʥ] }
  public
    Form1: TForm;
    Memo2: TMemo;
    procedure ToProcessMessages;
  end;

  function  ChangeSlash2BackSlash(s: string): string;
  procedure MemoDump(p: Pointer; n: Integer);
  procedure MemoWrite(s: string);
  function  suFileOpen(fn: string; openFlag: Integer): THANDLE;
  function  suFileRead(fhnd: THANDLE; buf: PChar; len: Integer): Integer;
  function  suFileWrite(fhnd: THANDLE; buf: PChar; len: Integer): Integer;
  // �H�U���禡�O PC_PS2MC.pas �Ҧ�
//  function  PS2_MC_Thread(pr: Pointer): LongInt;  stdcall;
//  procedure quit_thread;

const
  CONFIG_INDEX                         = 0;
  CONFIG_NB_OF_INTERFACES              = 1;
  CONFIG_INTERFACE                     = 0;
  CONFIG_ALT_SETTING                   = 0;
  CONFIG_TRAN_SIZE                     = 4096;
  ENDPOINT_ADDRESS                     = $81;
  BUFFER_SIZE                          = 64;
  NB_OF_BUFFERS                        = 5;
  NPM_DONE  =   $154D704E;
  NPM_OK    =   $204D704E;
  waitTime  =   2500;
{ �H�U���� PL2301.H, ������o���s�u���A
#define PEER_E    0x01 /* bit0 - Peer Exists */
#define TX_REQ    0x02 /* bit1 - Transfer Request */
#define TX_C      0x04 /* bit2 - Transfer Complete */
#define RESET_I   0x08 /* bit3 - Reset Input Pipe */
#define RESET_O   0x10 /* bit4 - Reset Ouput Pipe */
#define TX_RDY    0x20 /* bit5 - Transmit Request Acknowledge */
#define RESERVED  0x40 /* bit6 - Transmit Complete Acknowledge */
#define S_EN      0x80 /* bit7 - Suspend Enable */  }
  Peer_Exist    =       1;
  TX_Request    =       2;
  TX_Complete   =       4;
  Reset_InpPipe =       8;
  Reset_OutPipe =       16;
  TX_Ready      =       32;
  Suspend_En    =       128;
  noJOB         =       -1;
  cmdExecEE     =       1;
  cmdReset      =       3;
  cmdQuit       =       4;
  psTTY: PChar  =       'tty';
  myusbCfg: string      =       'SU_USB.CFG';
  fn_PC_init_OK         =       'C:\PC_MC_OK.$$$';      { �q���إߦ���, �N��w Ready OK }
  DefaultPS2ELF_file    =       'host:d:\psx2\ps2_9305\myps2.elf';
  jobName: array [1..4] of string = ('���� EE �{��', '���� IOP �{��', '���m�C���D��', '�Ȱ��R�O');

var
  MYUSB: TMYUSB;
  aUSB             : Tusbio;
  piCmd            : TusbioPipe;        { �O TUSBIO ���l�����O, �e�R�O�����Ǵ��� }
  piRead           : TusbioPipe;        { �M�Ω�Ū�� PS2 �ݪ���ƨ� PC }
  piWrite          : TusbioPipe;        { �M�Ω�g�X PC �ݪ���Ƶ� PS2 }
  piTest           : TusbioPipe;        { �Ω���ճs�u, �è��o���A }
  BufPool          : TUsbIoBufPool;
  mbuf             : TUsbIoBuf;
  DevList          : HDEVINFO;     // = ep
  desc             : USB_DEVICE_DESCRIPTOR;
  StrDescSize      : DWORD = sizeof(USB_STRING_DESCRIPTOR)+256;
  status           : DWORD;
  conf             : USBIO_SET_CONFIGURATION;
  buf1             : array[0..100] of byte;
  bytecnt          : DWORD;
  lpThrID          : LongWord;
  hThr             : HWND;
  NPMInfo          : array [0..1] of Cardinal;  { Length, Address of PS2 }
  DeviceNo         : Integer;
  TestCounter      : Integer;
  ThreadID         : Integer;
  pProgRdIn        : PChar;
  jobID            : Integer = noJOB;
  chkReturn        : Cardinal = NPM_OK;
  isitok           : boolean;   { F:�L�˸m, T:�˸m�i�� }
  usrAbort         : boolean;   { T: ������ }
  onLine           : boolean;   { T: ���s�u�� }
  toShowDebug      : boolean = False;    { F: ����ܰ����T�� }
  lastStat         : Integer;
  ps2fn            : string;
  my_path          : string;             { �������ɪ����| }

// {$L DEBUGMON.OBJ}

implementation

uses PC_PS2MC, PS2Icon, SavGmDir;
{$R *.DFM}

procedure TMYUSB.CheckLineClear;
var
   i, j: Integer;
begin
     if piTest = nil then GoFunc1(nil);
     for j := 0 to 200 do begin
        if WaitAndStatus(TX_Request) <> 0 then begin
            i := do_recv_process_Pkt;
            if i = NPM_DONE then Exit;      // PS2 ���u�@�觹��, �� PC �D��
        end;
     end;
end;

procedure TMYUSB.CleanUp;
begin   { ����귽 }
     DeleteFile(fn_PC_init_OK);         { �N�� PC init ready ��, ���ɤw�����s�b }
     if aUSB = nil then Exit;
     MemoWrite('���n����귽, �еy�� ...');
     if DevList <> nil then aUSB.DestroyDeviceList(DevList);
     if piCmd  <> nil then begin    piCmd.ResetPipe;   piCmd.Destroy;   end;
     if piRead <> nil then begin    piRead.ResetPipe;  piRead.Destroy;  end;
     if piWrite <> nil then begin   piWrite.ResetPipe; piWrite.Destroy; end;
     if piTest  <> nil then begin   piTest.ResetPipe;  piTest.Destroy;  end;
     aUSB.ResetDevice;          aUSB.Destroy;          aUSB := nil;
     isitok := False;
     MemoWrite('�w����귽, �{���i�w�ߵ��� !');
end;

procedure TMYUSB.debugShowChg(Sender: TObject);
begin
     toShowDebug := not CheckBox1.Checked;
end;

procedure TMYUSB.doAbort(Sender: TObject);
begin
     usrAbort := True;
end;

procedure TMYUSB.doEXECEE(Sender: TObject);
var
   len: Integer;
begin   { $40206E, $401F52 }
     if onLine then begin  TellBad;  Exit;  end;
     CheckLineClear;    jobID := cmdExecEE;
     StrPCopy(pProgRdIn, ps2fn);
     len := StrLen(pProgRdIn) + 1;
     NPMInfo[0] := len;         // ���g�`����
     NPMInfo[1] := $014D704E;   // EXEC-EE �X (01, 'MpN')
     status := send_packet(pProgRdIn);  // �e�X�ɦW
     if status = 0 then begin
        MemoWrite('pc: do_execec - send_packet failed !');
        Exit;
     end;
     GetPS2Return(nil);         // Ū���q PS2 �Ǧ^���N�X
     WaitProcessPkt;    { PC �ର�Q�ʺ�, ���򦬨� PS2 �n�D }
end;

function  TMYUSB.do_recv_process_Pkt: Integer;
var
   pFBuf, p: PChar;
   flag, LenGot: Cardinal;
   fh, rv: Integer;
   retCode: Byte;
   s: string;
begin   { $401C5C }
     FillChar(pProgRdIn^, 256, 0);
     Status := recv_packet(pProgRdIn, LenGot);
     if Status = 0 then begin
        MemoWrite('pc: recv_and_process_packet --> Error recieving packet !');
        Result := -1;
        Exit;
     end;
     { $401C9E, NPMInfo[] �b recv_packet() �|�۰�Ū�J }
     if toShowDebug then MemoWrite('PS2 >> NPMInfo = [ ' + IntToStr(NPMInfo[0]) + ' , ' + IntToHex(NPMInfo[1], 8) + ' ]');
     if ((NPMInfo[1] and $FFFFFF) = $4D704E) then begin
        retCode := Byte(NPMInfo[1] shr 24);
        s := StrPas(PChar(@pProgRdIn[4]));
//        DebugDump(8, @pProgRdIn[0], 16);
        case retCode of
             $10: begin { $401D0E, PACKET_OPEN, naplink.c-line 209 }
                    p := StrPos(PChar(@pProgRdIn[4]), psTTY);
                    if p <> Nil then begin
                       if (p = PChar(@pProgRdIn[4])) or ((p-1)^ = '/') then begin
                          sendInfoToPS2(1, 0, nil);     { ���r�O tty ! }
                          Result := NPMInfo[1];         Sleep(250);
                          Exit;
                       end;
                    end;
                    Lengot := PInteger(pProgRdIn)^;     // = �}�ɺX��
                    s := UpperCase(ChangeSlash2BackSlash(s));
                    rv := suFileOpen(s, Lengot);
                    if toShowDebug then MemoWrite('PC �}��: ' + s + ' , flag = ' + IntToHex(LenGot,4) + ' ,�}�ɵ��G  = ' + IntToStr(rv));
                    sendInfoToPS2(rv, 0, nil);
                  end;
             $11: begin { $401DCA, PACKET_CLOSE, naplink.c-line 235 }
                    fh := PInteger(pProgRdIn)^;         { file handle }
                    if fh < 2 then rv := 0
                    else rv := Byte(CloseHandle(fh));   { 0=Bad, 1=OK }
                    if toShowDebug then MemoWrite('PC Close file handle: ' + IntToStr(fh));
                    sendInfoToPS2(rv, 0, nil);
                  end;
             $12: begin { $401E01, PACKET_READ, naplink.c-line 246 }
                    rv := PInteger(pProgRdIn)^;        { file handle }
                    flag := PInteger(@pProgRdIn[4])^;  { ��Ū���� }
                    pFBuf := pProgRdIn + 8;     { ��Ū�������p�� 512K }
                    if toShowDebug then MemoWrite('PC Read file handle: ' + IntToStr(rv) + ',count =' + IntToStr(flag));
                    rv := suFileRead(rv, pFBuf, flag);      // �¨禡�b�ɮפj��, ���X��
                    sendInfoToPS2(rv, rv, pFBuf);
//                    FreeMem(pFbuf);             { ���� benchmarking }
                  end;
             $13: begin { $401E68, PACKET_WRITE, naplink.c-line 260 }
                    rv := PInteger(pProgRdIn)^;        { file handle }
                    flag := PInteger(@pProgRdIn[4])^;  { ���g���� }
                    if toShowDebug then MemoWrite('PC Write file handle: ' + IntToStr(rv) + ',count =' + IntToStr(flag));
                    if rv < 4 then begin
//                      if rv = 1 then begin
//                      else MemoDump(@pProgRdIn[8], flag);
                        s := StrPas(PChar(@pProgRdIn[8]));
                        MemoWrite(s);

                        rv := flag;
                      end
                    else rv := suFileWrite(rv, pProgRdIn + 8, flag);
                    sendInfoToPS2(rv, 0, nil);
                  end;
             $14: begin { $401EB0, PACKET_LSEEK, naplink.c-line 272 }
                    rv := PInteger(pProgRdIn)^;         { file handle }
                    flag := PInteger(@pProgRdIn[4])^;   { �s��m }
                    LenGot := PInteger(@pProgRdIn[8])^; { �q����_ }
                    rv := FileSeek(rv, flag, LenGot);
                    sendInfoToPS2(rv, 0, nil);
                  end;
             $15: begin { $401EE4, PACKET_WAZZUP, naplink.c-line 282 }
                    StatBar.Panels[1].Text := 'PS2 on line.';
                    if (jobID > 0) and (jobID <> cmdExecEE) then begin
                        NPMInfo[0] := $123456;
                        MemoWrite('�������u�@: ' + jobName[jobID]);
                        jobID := noJOB;
                    end;
                    if jobID = cmdExecEE then sendInfoToPS2(0, 0, nil);
                  end;
             $20: begin { $401FA8 }
                    StatBar.Panels[1].Text := 'PS2 is well.';
                    sendInfoToPS2(0, 0, nil);
                  end;
             else begin
                    MemoWrite('PC: BAD PACKET 0x' + IntToHex(NPMInfo[1], 8));
                    StatBar.Panels[1].Text := '���줣�}�ʥ]';
                  end;
        end;
     end;
     Result := NPMInfo[1];
end;

procedure TMYUSB.doReset(Sender: TObject);
begin   { $402045 }
     if onLine then begin  TellBad;  Exit;  end;
     CheckLineClear;            jobID := cmdReset;
     NPMInfo[0] := 0;           // ���g�`����
     NPMInfo[1] := $004D704E;   // RESET �X (00, 'MpN')
     status := send_packet(nil);        // �Ū��]��
     if status = 0 then begin
        MemoWrite('pc: do_reset - send_packet failed !');
        Exit;
     end;
     GetPS2Return(nil);         // Ū���q PS2 �Ǧ^���N�X
//     CheckLineClear;
     WaitProcessPkt;    { PC �ର�Q�ʺ�, ���򦬨� PS2 �n�D }
end;

procedure TMYUSB.formResize(Sender: TObject);
begin
//     Memo1.Width := ClientWidth - 18;
//     Memo1.Height := ClientHeight - 117;
     if hThr <> 0 then begin
        Memo2.Width := Form1.ClientWidth - 4;
        Memo2.Height := Form1.ClientHeight - 4;
        Memo2.Show;
        Form1.Show;             Form1.BringtoFront;
     end;
end;

function  TMYUSB.GetPS2Return(pDst: PChar): Integer;
var
   Ans: array [0..3] of DWORD;
   LenReturn: Cardinal;
begin   // Ū���q PS2 �Ǧ^���N�X
     LenReturn := 0;            FillChar(Ans[0], 16, 0);
     status := recv_packet(PChar(@Ans[0]), LenReturn);
//     DebugDump(3, @Ans[0], 16);
     if toShowDebug then MemoWrite('recv status = ' + IntToStr(status));
     if NPMInfo[1] = NPM_DONE then begin Result := 0;  Exit;  end; // it's NPM_DONE
     if NPMInfo[1] <> chkReturn then begin      { NPM_OK }
        MemoWrite('Was expecting PACKET_RETURN, but -> got 0x' + IntToHex(NPMInfo[1], 8));
        Result := -1;
        Exit;
     end;
     { $4018AF }
     if (NPMInfo[0] > 4) and (pDst <> nil) then Move(Ans[1], pDst^, NPMInfo[0] - 4);
     if toShowDebug then MemoWrite('Ū���q PS2 �Ǧ^���N�X = 0x' + IntToHex(Ans[0], 8));
     Result := Ans[0];
end;

procedure TMYUSB.GoFunc1(Sender: TObject);
begin   { �P PS2 �s�u }
     if not isitok then Exit;   { �L�˸m }
     piCmd := TusbioPipe.Create;        usrAbort := False;
     status := piCmd.Open(DeviceNo, DevList, @USBIO_IID);
     if status <> USBIO_ERR_SUCCESS then begin
        MemoWrite('�}�Ҷǿ�ɺ޸˸m����' + piCmd.errortext(status));
        Exit;
     end;
     piCmd.ResetPipe;           { see $40242C }
     // �i�� Configuration �˸m�ѼƳ]�w
     ZeroMemory(@conf, sizeof(conf));
     conf.ConfigurationIndex := 0;
     conf.NbOfInterfaces := 1;
     conf.InterfaceList[0].InterfaceIndex := 0;
     conf.InterfaceList[0].AlternateSettingIndex := 0;
     conf.InterfaceList[0].MaximumTransferSize := 4096;
     MemoWrite('Configuring the device ...');
     status := piCmd.SetConfiguration(@conf);
     if status <> USBIO_ERR_SUCCESS then begin
        MemoWrite('�R�O�ɺ޸˸m�]�w����' + piCmd.errortext(status));
        Exit;
     end;
     MemoWrite('�R�O�ɺ޸˸m�]�w���\ !');
     // �}�ҤT���ǿ�ɺ�
     MemoWrite('Opening pipes...');
     piRead := TusbioPipe.Create;
     piWrite := TusbioPipe.Create;
     piTest := TusbioPipe.Create;
     status := piRead.Bind(DeviceNo, $83, DevList, @USBIO_IID);
     if status <> USBIO_ERR_SUCCESS then begin
        MemoWrite('Ū���M�ξɺ޸˸m�]�w����' + piRead.errortext(status));
        Exit;
     end;
     status := piWrite.Bind(DeviceNo, $02, DevList, @USBIO_IID);
     if status <> USBIO_ERR_SUCCESS then begin
        MemoWrite('�g�X�M�ξɺ޸˸m�]�w����' + piWrite.errortext(status));
        Exit;
     end;
     status := piTest.Bind(DeviceNo, $81, DevList, @USBIO_IID);
     if status <> USBIO_ERR_SUCCESS then begin
        MemoWrite('���ձM�ξɺ޸˸m�]�w����' + piTest.errortext(status));
        Exit;
     end;
     MemoWrite('�T���ǿ�ɺ޶}�Ҧ��\ !');
     MainPipeCommand(1, TX_Request);    // �g�� piCmd �R�O�ɺ޼g�X���O
     MainPipeCommand(1, TX_Complete);
     MainPipeCommand(3, Peer_Exist);    // �����h PC : ready !
     WaitPeer;          { �g�Ѵ��ձM�ξɺ�, ���ݹ����I�^�� }
end;

procedure TMYUSB.MainPipeCommand(Req: Byte; wrtValue: Word);
var
   Request: USBIO_CLASS_OR_VENDOR_REQUEST;
   ByteCnt: Cardinal;
begin   { �аѬ� NAPLINK.EXE $40148B, $4014EB }
     ZeroMemory(@Request, sizeof(USBIO_CLASS_OR_VENDOR_REQUEST));
     Request.Flags := USBIO_SHORT_TRANSFER_OK;            { = 0x10000 }
     Request._Type := RequestTypeVendor;        { = 2 }
     Request.Recipient := RecipientInterface;   { = 1 }
     Request.RequestTypeReservedBits := 0;
     Request.Request := Req;    { 1=Clear, 3=Set }
     Request.Value := wrtValue;
     Request.Index := 0;        ByteCnt := 0;
     // �g�� piCmd �R�O�ɺ޼g�X���O
     piCmd.ClassOrVendorOutRequest(nil, ByteCnt, @Request);
end;

procedure TMYUSB.RecordPath;
var
   fh: Integer;
   pBuf: PChar;
   s: string;
begin
     s := ExtractFilePath(Application.ExeName) + myusbCfg;
     fh := FileCreate(s);
     if fh > 0 then begin
        pBuf := AllocMem(256);          ZeroMemory(pBuf, 256);
        StrPCopy(pBuf + 128, ExtractFilePath(OpenDlg.FileName));
        FileWrite(fh, pBuf^, 256);
        FileClose(fh);          FreeMem(pBuf);
     end;
end;

procedure TMYUSB.ReloadPath;
var
   fh: Integer;
   pBuf: PChar;
   s: string;
begin
     s := ExtractFilePath(Application.ExeName) + myusbCfg;
     fh := FileOpen(s, fmOpenRead);
     if fh > 0 then begin
        pBuf := AllocMem(256);          ZeroMemory(pBuf, 256);
        FileRead(fh, pBuf^, 256);       FileClose(fh);
        OpenDlg.InitialDir := StrPas(pBuf + 128);
        FreeMem(pBuf);
     end;
end;

function  TMYUSB.recv_packet(pReadIn: PChar; var LenRead: Cardinal): Integer;
var
   remain, LenToRead: Cardinal;
begin   { NAPLINK.EXE -- $40159E }
     Result := 0;       LenRead := 0;
     // while(CHECK_QLF(hnd, TX_REQ) == 0);
     while WaitAndStatus(TX_Request) = 0 do
        if WaitAndStatus(Peer_Exist) = 0 then Exit;
     { $4015DA }
     MainPipeCommand(1, TX_Request);    // CLEAR_QLF(hnd, TX_REQ);
     // receive packet header
     LenToRead := 8;            FillChar(NPMInfo[0], 8, 0);
     status := piRead.ReadSync(@NPMInfo[0], LenToRead, waitTime);
//     DebugDump(2, @NPMInfo[0], 16);
//     MemoWrite('new recv: 0x' + IntToHex(NPMInfo[1], 8));
     if status <> 0 then begin { $4015FD }
        MemoWrite('pc: recv_packet - error getting -> packet header!');
        MemoWrite('�ɺ޿��~�X: ' + piRead.errortext(status));
        status := WaitLineStatusOK(waitTime);
        MemoWrite('pc: int_status: PL2301 �������A�X: 0x' + IntToHex(status, 2));
        Exit;
     end;
     // receive packet body
     { Rbuf[0] = �N�Ǧ^������`����, �q�` Rbuf[1] = 0x??4D704E }
     { $401629, ����Ū������ remain < 1 }
     remain := NPMInfo[0];
     if remain > 0 then repeat
        LenToRead := CONFIG_TRAN_SIZE;
        if remain < CONFIG_TRAN_SIZE then LenToRead := remain; { �Ŷ�����, ����Ū���i�� }
        status := piRead.ReadSync(pReadIn, LenToRead, waitTime);
        Inc(pReadIn, LenToRead);        Dec(remain, LenToRead);
        Inc(LenRead, LenToRead);
        PrgsBar.Position := LenRead * 100 div NPMInfo[0];
     until remain = 0;
     { $4016CE, �����F }
     while(True) do begin
        if WaitAndStatus(TX_Complete) <> 0 then begin   { wait for TX_C }
            MainPipeCommand(1, TX_Complete);            { clear TX_C }
            Result := 1;        PrgsBar.Position := 100;
            Exit
        end;
        if WaitAndStatus(Peer_Exist) = 0 then Exit;
     end;
end;

function  TMYUSB.sendInfoToPS2(value, BufLen: Integer; pBuf: PChar): Integer;
var
   pTmp: PChar;
begin   { $40198F }
     if BufLen < 0 then BufLen := 0;
     NPMInfo[0] := BufLen + 4;
     NPMInfo[1] := NPM_OK;
     pTmp := AllocMem(BufLen + 4);
     PInteger(pTmp)^ := value;
     if BufLen <> 0 then Move(pBuf^, pTmp[4], BufLen);
     status := send_packet(pTmp);
     FreeMem(pTmp);     Result := 0;
     if status = 0 then Result := -1;
end;

procedure TMYUSB.sendQuitToPS2(Sender: TObject);
var
   t: Integer;
begin   { $4018F6 }
     if onLine then begin  TellBad;  Exit;  end;
     CheckLineClear;            jobID := cmdQuit;
     t := 40;
     repeat     // ���� PS2 �ݥi�������                
           if WaitAndStatus(TX_Ready) <> 0 then t := 0;
           Dec(t);
     until t < 1;
     NPMInfo[0] := 0;           // ���g�`����
     NPMInfo[1] := $034D704E;   // ��X�X (03, 'MpN')
     status := send_packet(nil);        // �Ū��]��
     if status = 0 then begin   { $401926 }
        MemoWrite('pc: do_quit - send_packet failed !');
        Exit;
     end;
     GetPS2Return(nil);         // Ū���q PS2 �Ǧ^���N�X
     WaitProcessPkt;    { PC �ର�Q�ʺ�, ���򦬨� PS2 �n�D }
     piRead.ResetPipe;          piWrite.ResetPipe;
end;

procedure TMYUSB.sendToPS2(Sender: TObject);
var
   fh: Integer;
begin   { ���ɮ׶ǵ� PS2 }
     if OpenDlg.Execute then begin
        fh := FileOpen(OpenDlg.FileName, fmOpenRead or fmShareDenyNone);
        if fh > 0 then begin
            FileClose(fh);              RecordPath;     { save this path }
            ps2fn := 'host:' + OpenDlg.FileName;
            doEXECEE(nil);
        end
        else MemoWrite('�L�k�}���ɮ�: ' + OpenDlg.FileName);
     end;
end;

function  TMYUSB.send_packet(WtBuf: PChar): Integer;
var
   LenDone, LenToWrite: Cardinal;       { = �������g���� }
   TotalLen: Cardinal;
begin   { NAPLINK.EXE -- $40159E }
     Result := 0;               PrgsBar.Position := 0;
     LenDone := 0;

     while WaitAndStatus(TX_Ready) = 0 do
        if WaitAndStatus(Peer_Exist) = 0 then Exit;
     { wait for peer to clear TX_REQ, �Q�̨Τƥh�� }
     { $401749 }
     if toShowDebug then MemoWrite('send NPM Info: ' + IntToHex(NPMInfo[0], 8) + ', ' + IntToHex(NPMInfo[1], 8));
     MainPipeCommand(3, TX_Request);    { set TX_REQ }
     { send block, ���e�X���Y���� }
     LenToWrite := 8;
     status := piWrite.WriteSync(@NPMInfo[0], LenToWrite, waitTime);
     if status <> USBIO_ERR_SUCCESS then begin { $4015FD }
        MemoWrite('pc: send_packet - error sending -> packet header !');
        MemoWrite('�ɺ޿��~�X: ' + piWrite.errortext(status));
        status := WaitLineStatusOK(waitTime);
        MemoWrite('pc: int_status: PL2301 �������A�X: 0x' + IntToHex(status, 2));
        Exit;
     end;
     { $401780, �e�X��ƥ��鳡��, ���мg�X���� TotalLen = 0 }
     TotalLen := NPMInfo[0];
//     if WtBuf <> nil then DebugDump(16, WtBuf, 16);
     while (TotalLen > 0) do begin
        LenToWrite := CONFIG_TRAN_SIZE;
        if TotalLen < CONFIG_TRAN_SIZE then LenToWrite := TotalLen;  { �Ѥ��h, ���g�X }
        status := piWrite.WriteSync(WtBuf, LenToWrite, waitTime);
        if status <> USBIO_ERR_SUCCESS then begin { $4017D4 }
            MemoWrite('pc: send_packet - Error sending -> packet body !');
            MemoWrite('�ɺ޿��~�X: ' + piWrite.errortext(status));
            status := WaitLineStatusOK(waitTime);
            MemoWrite('pc: int_status: PL2301 �������A�X: 0x' + IntToHex(status, 2));
            Exit;
        end;
        Inc(WtBuf, LenToWrite);         Dec(TotalLen, LenToWrite);
        Inc(LenDone, LenToWrite);
        PrgsBar.Position := 100 - (LenDone * 100 div (TotalLen + LenDone));
     end;
     { $4017F0, �����F, �q�`������ TX_Request �M�� }
     if WaitAndStatus(TX_Request) = 0 then begin
        MainPipeCommand(3, TX_Complete);        { set TX_C, $40181C }
        while(WaitAndStatus(TX_Complete) <> 0) do
            if WaitAndStatus(Peer_Exist) = 0 then Exit;
        PrgsBar.Position := 100;
        Result := 1;    // MemoWrite('Write OK !');
        Exit
     end;
     if WaitAndStatus(Peer_Exist) = 0 then Exit;
end;

procedure TMYUSB.TellBad;
begin
     MessageBox(Handle, '�Э����@��', '�������s�u�í��դ�', MB_OK);
     usrAbort := True;
end;

{ =================================================
  ���ͥ���������, �ˬd�O�_���˸m
  ================================================= }
procedure TMYUSB.ToClose1(Sender: TObject; var Action: TCloseAction);
begin
     usrAbort := True;
     quit_thread;
     if piTest <> nil then MainPipeCommand(1, Peer_Exist); // �����h PC : not ready !
     CleanUp;           { ����귽 }
end;

procedure TMYUSB.ToCreateForm(Sender: TObject);
var
   nFound: Integer;
begin
//     DebugCLS(15, ',');
     pProgRdIn := AllocMem($80000);
     ReloadPath;                ps2fn := DefaultPS2ELF_file;
     aUSB := Tusbio.Create;     isitok := False;
     DevList := aUSB.CreateDeviceList(@USBIO_IID);
     if DevList = nil then
        begin
             MemoWrite('�L�k���� USB �˸m�C��, �нT�{�w�w���X�ʵ{�� !');
             aUSB.Destroy;
             Exit;
        end;

     // ���ն}�ҲĤ@�ӥi�Ϊ� USB <--> PS2 �˸m
     // �H�ջ~�k��즹�˸m�s���O�X��? (USB �t Hub �̦h�i�� 128 �Ӹ`�I)
     DeviceNo := 0;     nFound := 0;
     repeat
           status := aUSB.Open(DeviceNo, DevList, @USBIO_IID);
           if status = USBIO_ERR_SUCCESS then begin     // �˸m���}�Ҥ~��Ū��
              Status := aUSB.GetDeviceDescriptor(@desc);
              if status <> USBIO_ERR_SUCCESS then       // ����, �դU�@��
                  MemoWrite('GetDeviceDescriptor: ' + aUSB.errortext(status))
              else begin
                  MemoWrite('���F Prolific USB cable !');
                  MemoWrite('GetDeviceDescriptor: Vendor = $' + IntToHex(desc.idVendor, 4) + ', Product = $' + IntToHex(desc.idProduct, 4));
                  Inc(nFound);          Break;  // ���F�K����
              end;  end
           else begin
//              MemoWrite('�}�Ҹ˸m�s�� ' + IntToStr(DeviceNo) + ': ' + aUSB.errortext(status));
              aUSB.Close;
           end;
           Inc(DeviceNo);
     until DeviceNo > 127;

     if nFound < 1 then begin
        MemoWrite('�i�� [����x->�t��->USBIO controlled devices] ���U�O�_���w�� [PL-2301 Cable] ���˸m !');
        MemoWrite('�]�i��O USB �˸m�S���n, �Υ������q�� !');
        CleanUp;        { ����귽 }
        Exit;
     end;
     isitok := True;
     my_path := ExtractFilePath(Application.ExeName);
     // �إ߳B�z�T����
     Form1 := TForm.Create(MYUSB);      Memo2 := TMemo.Create(Form1);
     Form1.Top := Memo1.Top + 12;       Form1.Left := Memo1.Left + 128;
     Form1.Width := Memo1.Width;        Form1.Height := Memo1.Height + 12;
     Memo2.Top := 2;                    Memo2.Left := 2;
     Memo2.Width := Form1.ClientWidth - 4;      Memo2.Parent := Form1;
     Memo2.Height := Form1.ClientHeight - 4;    Form1.Caption := '�B�z�L�{�T��';
     Form1.Color := $00760348;          Memo2.Color := $0046344B;
     Form1.OnResize := formResize;      Memo2.Font.Color := clYellow;
     // �� C:\ �U�إ��ɮ�, �� PS2 �iŪ��, �H�� PC ready ���H��.
     hThr := CreateThread(nil, 0, @PS2_MC_Thread, nil, 0, lpThrID);
end;

procedure TMYUSB.ToProcessMessages;
begin
     Application.ProcessMessages;
end;

procedure TMYUSB.WaitPeer;
var
   fail: Integer;
begin   { ���ݹ����I�^�� }
//     DebugStr(0, 0, 'WaitPeer: ');
     if WaitAndStatus(Peer_Exist) <> 0 then begin
        StatBar.Panels[1].Text := '���I�w�^��';
        Exit;
     end;
     MemoWrite('Waiting for peer... (���ݹ����I�^��)');
     fail := 0;
     while ((WaitAndStatus(Peer_Exist) = 0) and (not usrAbort))
        do begin
           Application.ProcessMessages;
           Inc(fail);
           if fail > 15 then usrAbort := True;
        end;
     MemoWrite('�L�k���ݹ����I�^�� !');
end;

function  TMYUSB.WaitLineStatusOK(waitms: Integer): Byte;
var
   LenToRead: Cardinal;
   buffer: Byte;
begin
     buffer := 0;
     repeat
           LenToRead := 1;
           status := piTest.ReadSync(@buffer, LenToRead, 10000);
           if lastStat <> Integer(buffer) then begin
                lastStat := Integer(buffer);
                StatBar.Panels[0].Text := '���A: 0x' + IntToHex(lastStat, 2);
                if lastStat and 1 = 0 then StatBar.Panels[1].Text := 'PS2 ���u';
//                DebugHex(lastStat, 2);
//                MemoWrite('line status: 0x' + IntToHex(Integer(buffer), 2));
           end;
           if status <> USBIO_ERR_SUCCESS then begin
                MemoWrite('�������A�ɺ޸˸m: ' + piTest.ErrorText(status));
                status := USBIO_ERR_SUCCESS;    { force to Quit ! }
           end;
     until status = USBIO_ERR_SUCCESS;
     Result := buffer;          // �Ǧ^ Overlap_Status �������A
end;

function  TMYUSB.WaitAndStatus(testValue: Byte): Byte;
begin   { see NAPLINK.EXE $40154B }
     Application.ProcessMessages;
     if usrAbort then begin  Result := 0;  Exit;  end;
     Result := WaitLineStatusOK(10000) and testValue;
end;

function  TMYUSB.WaitProcessPkt: Boolean;
begin   { ���ݨóB�z�������ʥ], $4023A0 }
     onLine := True;
     repeat
           if WaitAndStatus(TX_Request) = 0 then Application.ProcessMessages
           else do_recv_process_Pkt;
     until (usrAbort = True) or (NPMInfo[0] = $123456);
     onLine := False;           usrAbort := False;
     Result := usrAbort;
end;

function  ChangeSlash2BackSlash(s: string): string;
var
   i, l: Integer;
   ch, cl: Byte;
   s1: string;
begin   { �Ⱓ�������˱׽u }
     l := Length(s);    i := 1;         s1 := '';
     repeat
        ch := Byte(s[i]);
        if ch > $9E then begin  { �i��O����r(�t�y�r) }
            Inc(i);     cl := Byte(s[i]);
            s1 := s1 + Char(ch) + Char(cl);
        end
        else begin
            if Char(ch) = '/' then ch := Byte('\');
            s1 := s1 + Char(ch);
        end;
        Inc(i);
     until i > l;
     Result := s1;
end;

procedure MemoDump(p: Pointer; n: Integer);
var
   i, j: Integer;
   pB: PChar;
   s: string;
begin
     pB := PChar(p);
     s := StrPas(pB);   if toShowDebug then MemoWrite('Str = ' + s);
     if n > 32 then n := 32;
     repeat
        s := '';        j := 16;        if n < 16 then j := n;
        for i := 0 to j do begin
            s := s + IntToHex(Integer(pB^), 2) + ' ';
            Inc(pB);
        end;
        if toShowDebug then MemoWrite(s);
        Dec(n, j);
     until n < 1;
end;

procedure MemoWrite(s: string);
begin
     MYUSB.Memo1.Lines.Add(s);
end;

function  suFileOpen(fn: string; openFlag: Integer): THANDLE;
var
   hf: THANDLE;
   dwAccess, dwCD: DWORD;
   fname: array[0..255] of Char;
begin
     dwAccess := 0;
     if (openFlag and 1) = 1 then dwAccess := GENERIC_READ;   // O_RDONLY = 1, O_RDWR = 3
     if (openFlag and 2) = 2 then dwAccess := dwAccess or GENERIC_WRITE;  // O_WRONLY = 2, O_RDWR = 3
     dwCD := OPEN_EXISTING;
     if (openFlag and $400) = $400 then begin          // O_TRUNC = 0x400
        dwCD := TRUNCATE_EXISTING;      dwAccess := dwAccess or GENERIC_WRITE;  end;
     if (openFlag and $200) = $200 then begin          // O_CREAT = 0x200
        dwCD := CREATE_ALWAYS;          dwAccess := dwAccess or GENERIC_WRITE;  end;
     StrPCopy(fname, fn);
     if (openFlag and $200) = 0 then begin      { not create }
        if not FileExists(fn) then begin
            Result := INVALID_HANDLE_VALUE;     { �ɮפ��s�b }
            Exit;
        end;
     end;
     hf := CreateFile(fname, dwAccess, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, dwCD, 0, 0);
     if hf = INVALID_HANDLE_VALUE then MemoWrite('PC �}�ɿ��~: 0x' + IntToHex(GetLastError(), 8));
     Result := hf;
end;

function  suFileRead(fhnd: THANDLE; buf: PChar; len: Integer): Integer;
var
   pOvlp: POverlapped;
   rtRead: DWORD;
   ret: Boolean;
begin
     pOvlp := nil;
     ret := ReadFile(fhnd, buf^, len, rtRead, pOvlp);
     if not ret then MemoWrite('PC Ū�ɿ��~�X: 0x' + IntToHex(GetLastError(), 8));
     Result := rtRead;
end;

function  suFileWrite(fhnd: THANDLE; buf: PChar; len: Integer): Integer;
var
   pOvlp: POverlapped;
   rtWrite: DWORD;
   ret: Boolean;
begin
     if fhnd < 5 then begin // �g�찣����
        buf[len] := #0;
        MemoWrite(StrPas(buf));
        Result := len;         Exit;
     end;
     pOvlp := nil;
     ret := WriteFile(fhnd, buf^, len, rtWrite, pOvlp);
     if not ret then MemoWrite('PC �g�ɿ��~�X: 0x' + IntToHex(GetLastError(), 8));
     Result := rtWrite;
end;

procedure TMYUSB.NameSwitch(Sender: TObject);
begin
     Switch_List_Mode;
end;

procedure TMYUSB.RestoreSaveGame(Sender: TObject);
begin   { ��_�C���O�� }
     SaveGD.PrepareRestore;
end;

procedure TMYUSB.SeeItsName1(Sender: TObject);
begin
     SeeItsName(0);
end;

procedure TMYUSB.SeeItsName2(Sender: TObject);
begin
     SeeItsName(1);
end;

procedure TMYUSB.UseIt1(Sender: TObject);
begin
     UseThisItem(0);
end;

procedure TMYUSB.UseIt2(Sender: TObject);
begin
     UseThisItem(1);
end;

procedure TMYUSB.MouseKeyDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   index, slot: Integer;
begin
     if Button = mbRight then begin     { �x�s��ӹC���ؿ� }
        if Sender = ListBox1 then begin
            slot := 0;
            index := ListBox1.ItemIndex;
        end
        else begin
            slot := 1;
            index := ListBox2.ItemIndex;
        end;
        SaveGD.Prepare(slot, index);
     end;
end;

end.
