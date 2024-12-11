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
    procedure CleanUp;  { 釋放資源 }
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
    procedure WaitPeer; { 等待對方端點回應 }
    function  WaitProcessPkt: Boolean;          { 等待並處理接收的封包 }
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
  // 以下的函式是 PC_PS2MC.pas 所有
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
{ 以下取自 PL2301.H, 關於取得的連線狀態
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
  fn_PC_init_OK         =       'C:\PC_MC_OK.$$$';      { 電腦建立此檔, 代表已 Ready OK }
  DefaultPS2ELF_file    =       'host:d:\psx2\ps2_9305\myps2.elf';
  jobName: array [1..4] of string = ('執行 EE 程式', '執行 IOP 程式', '重置遊戲主機', '暫停命令');

var
  MYUSB: TMYUSB;
  aUSB             : Tusbio;
  piCmd            : TusbioPipe;        { 是 TUSBIO 的衍生類別, 送命令給互傳晶片 }
  piRead           : TusbioPipe;        { 專用於讀取 PS2 端的資料到 PC }
  piWrite          : TusbioPipe;        { 專用於寫出 PC 端的資料給 PS2 }
  piTest           : TusbioPipe;        { 用於測試連線, 並取得狀態 }
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
  isitok           : boolean;   { F:無裝置, T:裝置可用 }
  usrAbort         : boolean;   { T: 欲脫離 }
  onLine           : boolean;   { T: 正連線中 }
  toShowDebug      : boolean = False;    { F: 欲顯示除錯訊息 }
  lastStat         : Integer;
  ps2fn            : string;
  my_path          : string;             { 本執行檔的路徑 }

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
            if i = NPM_DONE then Exit;      // PS2 有工作剛完成, 換 PC 主動
        end;
     end;
end;

procedure TMYUSB.CleanUp;
begin   { 釋放資源 }
     DeleteFile(fn_PC_init_OK);         { 代表 PC init ready 用, 此檔已不應存在 }
     if aUSB = nil then Exit;
     MemoWrite('正要釋放資源, 請稍候 ...');
     if DevList <> nil then aUSB.DestroyDeviceList(DevList);
     if piCmd  <> nil then begin    piCmd.ResetPipe;   piCmd.Destroy;   end;
     if piRead <> nil then begin    piRead.ResetPipe;  piRead.Destroy;  end;
     if piWrite <> nil then begin   piWrite.ResetPipe; piWrite.Destroy; end;
     if piTest  <> nil then begin   piTest.ResetPipe;  piTest.Destroy;  end;
     aUSB.ResetDevice;          aUSB.Destroy;          aUSB := nil;
     isitok := False;
     MemoWrite('已釋放資源, 程式可安心結束 !');
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
     NPMInfo[0] := len;         // 欲寫總長度
     NPMInfo[1] := $014D704E;   // EXEC-EE 碼 (01, 'MpN')
     status := send_packet(pProgRdIn);  // 送出檔名
     if status = 0 then begin
        MemoWrite('pc: do_execec - send_packet failed !');
        Exit;
     end;
     GetPS2Return(nil);         // 讀取從 PS2 傳回的代碼
     WaitProcessPkt;    { PC 轉為被動端, 持續收取 PS2 要求 }
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
     { $401C9E, NPMInfo[] 在 recv_packet() 會自動讀入 }
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
                          sendInfoToPS2(1, 0, nil);     { 首字是 tty ! }
                          Result := NPMInfo[1];         Sleep(250);
                          Exit;
                       end;
                    end;
                    Lengot := PInteger(pProgRdIn)^;     // = 開檔旗號
                    s := UpperCase(ChangeSlash2BackSlash(s));
                    rv := suFileOpen(s, Lengot);
                    if toShowDebug then MemoWrite('PC 開檔: ' + s + ' , flag = ' + IntToHex(LenGot,4) + ' ,開檔結果  = ' + IntToStr(rv));
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
                    flag := PInteger(@pProgRdIn[4])^;  { 欲讀長度 }
                    pFBuf := pProgRdIn + 8;     { 欲讀長度應小於 512K }
                    if toShowDebug then MemoWrite('PC Read file handle: ' + IntToStr(rv) + ',count =' + IntToStr(flag));
                    rv := suFileRead(rv, pFBuf, flag);      // 舊函式在檔案大時, 易出錯
                    sendInfoToPS2(rv, rv, pFBuf);
//                    FreeMem(pFbuf);             { 不管 benchmarking }
                  end;
             $13: begin { $401E68, PACKET_WRITE, naplink.c-line 260 }
                    rv := PInteger(pProgRdIn)^;        { file handle }
                    flag := PInteger(@pProgRdIn[4])^;  { 欲寫長度 }
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
                    flag := PInteger(@pProgRdIn[4])^;   { 新位置 }
                    LenGot := PInteger(@pProgRdIn[8])^; { 從哪算起 }
                    rv := FileSeek(rv, flag, LenGot);
                    sendInfoToPS2(rv, 0, nil);
                  end;
             $15: begin { $401EE4, PACKET_WAZZUP, naplink.c-line 282 }
                    StatBar.Panels[1].Text := 'PS2 on line.';
                    if (jobID > 0) and (jobID <> cmdExecEE) then begin
                        NPMInfo[0] := $123456;
                        MemoWrite('完成的工作: ' + jobName[jobID]);
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
                    StatBar.Panels[1].Text := '收到不良封包';
                  end;
        end;
     end;
     Result := NPMInfo[1];
end;

procedure TMYUSB.doReset(Sender: TObject);
begin   { $402045 }
     if onLine then begin  TellBad;  Exit;  end;
     CheckLineClear;            jobID := cmdReset;
     NPMInfo[0] := 0;           // 欲寫總長度
     NPMInfo[1] := $004D704E;   // RESET 碼 (00, 'MpN')
     status := send_packet(nil);        // 空的包裝
     if status = 0 then begin
        MemoWrite('pc: do_reset - send_packet failed !');
        Exit;
     end;
     GetPS2Return(nil);         // 讀取從 PS2 傳回的代碼
//     CheckLineClear;
     WaitProcessPkt;    { PC 轉為被動端, 持續收取 PS2 要求 }
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
begin   // 讀取從 PS2 傳回的代碼
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
     if toShowDebug then MemoWrite('讀取從 PS2 傳回的代碼 = 0x' + IntToHex(Ans[0], 8));
     Result := Ans[0];
end;

procedure TMYUSB.GoFunc1(Sender: TObject);
begin   { 與 PS2 連線 }
     if not isitok then Exit;   { 無裝置 }
     piCmd := TusbioPipe.Create;        usrAbort := False;
     status := piCmd.Open(DeviceNo, DevList, @USBIO_IID);
     if status <> USBIO_ERR_SUCCESS then begin
        MemoWrite('開啟傳輸導管裝置失敗' + piCmd.errortext(status));
        Exit;
     end;
     piCmd.ResetPipe;           { see $40242C }
     // 進行 Configuration 裝置參數設定
     ZeroMemory(@conf, sizeof(conf));
     conf.ConfigurationIndex := 0;
     conf.NbOfInterfaces := 1;
     conf.InterfaceList[0].InterfaceIndex := 0;
     conf.InterfaceList[0].AlternateSettingIndex := 0;
     conf.InterfaceList[0].MaximumTransferSize := 4096;
     MemoWrite('Configuring the device ...');
     status := piCmd.SetConfiguration(@conf);
     if status <> USBIO_ERR_SUCCESS then begin
        MemoWrite('命令導管裝置設定失敗' + piCmd.errortext(status));
        Exit;
     end;
     MemoWrite('命令導管裝置設定成功 !');
     // 開啟三條傳輸導管
     MemoWrite('Opening pipes...');
     piRead := TusbioPipe.Create;
     piWrite := TusbioPipe.Create;
     piTest := TusbioPipe.Create;
     status := piRead.Bind(DeviceNo, $83, DevList, @USBIO_IID);
     if status <> USBIO_ERR_SUCCESS then begin
        MemoWrite('讀取專用導管裝置設定失敗' + piRead.errortext(status));
        Exit;
     end;
     status := piWrite.Bind(DeviceNo, $02, DevList, @USBIO_IID);
     if status <> USBIO_ERR_SUCCESS then begin
        MemoWrite('寫出專用導管裝置設定失敗' + piWrite.errortext(status));
        Exit;
     end;
     status := piTest.Bind(DeviceNo, $81, DevList, @USBIO_IID);
     if status <> USBIO_ERR_SUCCESS then begin
        MemoWrite('測試專用導管裝置設定失敗' + piTest.errortext(status));
        Exit;
     end;
     MemoWrite('三條傳輸導管開啟成功 !');
     MainPipeCommand(1, TX_Request);    // 經由 piCmd 命令導管寫出指令
     MainPipeCommand(1, TX_Complete);
     MainPipeCommand(3, Peer_Exist);    // 執行後則 PC : ready !
     WaitPeer;          { 經由測試專用導管, 等待對方端點回應 }
end;

procedure TMYUSB.MainPipeCommand(Req: Byte; wrtValue: Word);
var
   Request: USBIO_CLASS_OR_VENDOR_REQUEST;
   ByteCnt: Cardinal;
begin   { 請參看 NAPLINK.EXE $40148B, $4014EB }
     ZeroMemory(@Request, sizeof(USBIO_CLASS_OR_VENDOR_REQUEST));
     Request.Flags := USBIO_SHORT_TRANSFER_OK;            { = 0x10000 }
     Request._Type := RequestTypeVendor;        { = 2 }
     Request.Recipient := RecipientInterface;   { = 1 }
     Request.RequestTypeReservedBits := 0;
     Request.Request := Req;    { 1=Clear, 3=Set }
     Request.Value := wrtValue;
     Request.Index := 0;        ByteCnt := 0;
     // 經由 piCmd 命令導管寫出指令
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
        MemoWrite('導管錯誤碼: ' + piRead.errortext(status));
        status := WaitLineStatusOK(waitTime);
        MemoWrite('pc: int_status: PL2301 內部狀態碼: 0x' + IntToHex(status, 2));
        Exit;
     end;
     // receive packet body
     { Rbuf[0] = 將傳回的資料總長度, 通常 Rbuf[1] = 0x??4D704E }
     { $401629, 反覆讀取直到 remain < 1 }
     remain := NPMInfo[0];
     if remain > 0 then repeat
        LenToRead := CONFIG_TRAN_SIZE;
        if remain < CONFIG_TRAN_SIZE then LenToRead := remain; { 空間仍夠, 直接讀取進來 }
        status := piRead.ReadSync(pReadIn, LenToRead, waitTime);
        Inc(pReadIn, LenToRead);        Dec(remain, LenToRead);
        Inc(LenRead, LenToRead);
        PrgsBar.Position := LenRead * 100 div NPMInfo[0];
     until remain = 0;
     { $4016CE, 完成了 }
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
     repeat     // 等待 PS2 端可收取資料                
           if WaitAndStatus(TX_Ready) <> 0 then t := 0;
           Dec(t);
     until t < 1;
     NPMInfo[0] := 0;           // 欲寫總長度
     NPMInfo[1] := $034D704E;   // 脫出碼 (03, 'MpN')
     status := send_packet(nil);        // 空的包裝
     if status = 0 then begin   { $401926 }
        MemoWrite('pc: do_quit - send_packet failed !');
        Exit;
     end;
     GetPS2Return(nil);         // 讀取從 PS2 傳回的代碼
     WaitProcessPkt;    { PC 轉為被動端, 持續收取 PS2 要求 }
     piRead.ResetPipe;          piWrite.ResetPipe;
end;

procedure TMYUSB.sendToPS2(Sender: TObject);
var
   fh: Integer;
begin   { 把檔案傳給 PS2 }
     if OpenDlg.Execute then begin
        fh := FileOpen(OpenDlg.FileName, fmOpenRead or fmShareDenyNone);
        if fh > 0 then begin
            FileClose(fh);              RecordPath;     { save this path }
            ps2fn := 'host:' + OpenDlg.FileName;
            doEXECEE(nil);
        end
        else MemoWrite('無法開啟檔案: ' + OpenDlg.FileName);
     end;
end;

function  TMYUSB.send_packet(WtBuf: PChar): Integer;
var
   LenDone, LenToWrite: Cardinal;       { = 本次欲寫長度 }
   TotalLen: Cardinal;
begin   { NAPLINK.EXE -- $40159E }
     Result := 0;               PrgsBar.Position := 0;
     LenDone := 0;

     while WaitAndStatus(TX_Ready) = 0 do
        if WaitAndStatus(Peer_Exist) = 0 then Exit;
     { wait for peer to clear TX_REQ, 被最佳化去除 }
     { $401749 }
     if toShowDebug then MemoWrite('send NPM Info: ' + IntToHex(NPMInfo[0], 8) + ', ' + IntToHex(NPMInfo[1], 8));
     MainPipeCommand(3, TX_Request);    { set TX_REQ }
     { send block, 先送出表頭部份 }
     LenToWrite := 8;
     status := piWrite.WriteSync(@NPMInfo[0], LenToWrite, waitTime);
     if status <> USBIO_ERR_SUCCESS then begin { $4015FD }
        MemoWrite('pc: send_packet - error sending -> packet header !');
        MemoWrite('導管錯誤碼: ' + piWrite.errortext(status));
        status := WaitLineStatusOK(waitTime);
        MemoWrite('pc: int_status: PL2301 內部狀態碼: 0x' + IntToHex(status, 2));
        Exit;
     end;
     { $401780, 送出資料本體部份, 反覆寫出直到 TotalLen = 0 }
     TotalLen := NPMInfo[0];
//     if WtBuf <> nil then DebugDump(16, WtBuf, 16);
     while (TotalLen > 0) do begin
        LenToWrite := CONFIG_TRAN_SIZE;
        if TotalLen < CONFIG_TRAN_SIZE then LenToWrite := TotalLen;  { 剩不多, 全寫出 }
        status := piWrite.WriteSync(WtBuf, LenToWrite, waitTime);
        if status <> USBIO_ERR_SUCCESS then begin { $4017D4 }
            MemoWrite('pc: send_packet - Error sending -> packet body !');
            MemoWrite('導管錯誤碼: ' + piWrite.errortext(status));
            status := WaitLineStatusOK(waitTime);
            MemoWrite('pc: int_status: PL2301 內部狀態碼: 0x' + IntToHex(status, 2));
            Exit;
        end;
        Inc(WtBuf, LenToWrite);         Dec(TotalLen, LenToWrite);
        Inc(LenDone, LenToWrite);
        PrgsBar.Position := 100 - (LenDone * 100 div (TotalLen + LenDone));
     end;
     { $4017F0, 完成了, 通常不必等 TX_Request 清除 }
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
     MessageBox(Handle, '請重按一次', '正取消連線並重試中', MB_OK);
     usrAbort := True;
end;

{ =================================================
  產生必須的物件, 檢查是否有裝置
  ================================================= }
procedure TMYUSB.ToClose1(Sender: TObject; var Action: TCloseAction);
begin
     usrAbort := True;
     quit_thread;
     if piTest <> nil then MainPipeCommand(1, Peer_Exist); // 執行後則 PC : not ready !
     CleanUp;           { 釋放資源 }
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
             MemoWrite('無法產生 USB 裝置列表, 請確認已安裝驅動程式 !');
             aUSB.Destroy;
             Exit;
        end;

     // 嘗試開啟第一個可用的 USB <--> PS2 裝置
     // 以試誤法找到此裝置編號是幾號? (USB 含 Hub 最多可有 128 個節點)
     DeviceNo := 0;     nFound := 0;
     repeat
           status := aUSB.Open(DeviceNo, DevList, @USBIO_IID);
           if status = USBIO_ERR_SUCCESS then begin     // 裝置須開啟才能讀取
              Status := aUSB.GetDeviceDescriptor(@desc);
              if status <> USBIO_ERR_SUCCESS then       // 失敗, 試下一個
                  MemoWrite('GetDeviceDescriptor: ' + aUSB.errortext(status))
              else begin
                  MemoWrite('找到了 Prolific USB cable !');
                  MemoWrite('GetDeviceDescriptor: Vendor = $' + IntToHex(desc.idVendor, 4) + ', Product = $' + IntToHex(desc.idProduct, 4));
                  Inc(nFound);          Break;  // 找到了便脫離
              end;  end
           else begin
//              MemoWrite('開啟裝置編號 ' + IntToStr(DeviceNo) + ': ' + aUSB.errortext(status));
              aUSB.Close;
           end;
           Inc(DeviceNo);
     until DeviceNo > 127;

     if nFound < 1 then begin
        MemoWrite('可看 [控制台->系統->USBIO controlled devices] 底下是否有安裝 [PL-2301 Cable] 此裝置 !');
        MemoWrite('也可能是 USB 裝置沒插好, 或未供應電源 !');
        CleanUp;        { 釋放資源 }
        Exit;
     end;
     isitok := True;
     my_path := ExtractFilePath(Application.ExeName);
     // 建立處理訊息窗
     Form1 := TForm.Create(MYUSB);      Memo2 := TMemo.Create(Form1);
     Form1.Top := Memo1.Top + 12;       Form1.Left := Memo1.Left + 128;
     Form1.Width := Memo1.Width;        Form1.Height := Memo1.Height + 12;
     Memo2.Top := 2;                    Memo2.Left := 2;
     Memo2.Width := Form1.ClientWidth - 4;      Memo2.Parent := Form1;
     Memo2.Height := Form1.ClientHeight - 4;    Form1.Caption := '處理過程訊息';
     Form1.Color := $00760348;          Memo2.Color := $0046344B;
     Form1.OnResize := formResize;      Memo2.Font.Color := clYellow;
     // 於 C:\ 下建立檔案, 讓 PS2 可讀到, 以當成 PC ready 的信號.
     hThr := CreateThread(nil, 0, @PS2_MC_Thread, nil, 0, lpThrID);
end;

procedure TMYUSB.ToProcessMessages;
begin
     Application.ProcessMessages;
end;

procedure TMYUSB.WaitPeer;
var
   fail: Integer;
begin   { 等待對方端點回應 }
//     DebugStr(0, 0, 'WaitPeer: ');
     if WaitAndStatus(Peer_Exist) <> 0 then begin
        StatBar.Panels[1].Text := '端點已回應';
        Exit;
     end;
     MemoWrite('Waiting for peer... (等待對方端點回應)');
     fail := 0;
     while ((WaitAndStatus(Peer_Exist) = 0) and (not usrAbort))
        do begin
           Application.ProcessMessages;
           Inc(fail);
           if fail > 15 then usrAbort := True;
        end;
     MemoWrite('無法等待對方端點回應 !');
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
                StatBar.Panels[0].Text := '狀態: 0x' + IntToHex(lastStat, 2);
                if lastStat and 1 = 0 then StatBar.Panels[1].Text := 'PS2 離線';
//                DebugHex(lastStat, 2);
//                MemoWrite('line status: 0x' + IntToHex(Integer(buffer), 2));
           end;
           if status <> USBIO_ERR_SUCCESS then begin
                MemoWrite('內部狀態導管裝置: ' + piTest.ErrorText(status));
                status := USBIO_ERR_SUCCESS;    { force to Quit ! }
           end;
     until status = USBIO_ERR_SUCCESS;
     Result := buffer;          // 傳回 Overlap_Status 內部狀態
end;

function  TMYUSB.WaitAndStatus(testValue: Byte): Byte;
begin   { see NAPLINK.EXE $40154B }
     Application.ProcessMessages;
     if usrAbort then begin  Result := 0;  Exit;  end;
     Result := WaitLineStatusOK(10000) and testValue;
end;

function  TMYUSB.WaitProcessPkt: Boolean;
begin   { 等待並處理接收的封包, $4023A0 }
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
begin   { 把除號換成倒斜線 }
     l := Length(s);    i := 1;         s1 := '';
     repeat
        ch := Byte(s[i]);
        if ch > $9E then begin  { 可能是中文字(含造字) }
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
            Result := INVALID_HANDLE_VALUE;     { 檔案不存在 }
            Exit;
        end;
     end;
     hf := CreateFile(fname, dwAccess, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, dwCD, 0, 0);
     if hf = INVALID_HANDLE_VALUE then MemoWrite('PC 開檔錯誤: 0x' + IntToHex(GetLastError(), 8));
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
     if not ret then MemoWrite('PC 讀檔錯誤碼: 0x' + IntToHex(GetLastError(), 8));
     Result := rtRead;
end;

function  suFileWrite(fhnd: THANDLE; buf: PChar; len: Integer): Integer;
var
   pOvlp: POverlapped;
   rtWrite: DWORD;
   ret: Boolean;
begin
     if fhnd < 5 then begin // 寫到除錯幕
        buf[len] := #0;
        MemoWrite(StrPas(buf));
        Result := len;         Exit;
     end;
     pOvlp := nil;
     ret := WriteFile(fhnd, buf^, len, rtWrite, pOvlp);
     if not ret then MemoWrite('PC 寫檔錯誤碼: 0x' + IntToHex(GetLastError(), 8));
     Result := rtWrite;
end;

procedure TMYUSB.NameSwitch(Sender: TObject);
begin
     Switch_List_Mode;
end;

procedure TMYUSB.RestoreSaveGame(Sender: TObject);
begin   { 恢復遊戲記憶 }
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
     if Button = mbRight then begin     { 儲存整個遊戲目錄 }
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
