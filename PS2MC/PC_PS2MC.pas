unit PC_PS2MC;

interface

uses
  Windows, Controls, SysUtils;

type
  TPS2_TIME = record
    pad0, sec, min, hour, date, month: BYTE;
    year: WORD;
  end;

  PPS2_DIR = ^TPS2_DIR;
  TPS2_DIR = record
    build_time, last_time: TPS2_TIME;
    blks, flag, pad0, pad1: Integer;
    fname: array [0..31] of Char;
  end;

function  Arrange_JOB(job: Integer): Boolean;   { 傳回 T: 排程失敗 }
function  check_CRC32(fn: string): Integer;     { 計算 CRC-32 }
function  Check_DIR_File: Boolean;      { 等待並解析目錄資料檔 }
function  Check_GameName_File(slot: Integer): Boolean;  { 等待並解析目錄與遊戲名稱資料檔 }
procedure Check_PS2_CMD_File;   { 檢查是否有 C:\PS2_CMD.$$$ 出現 }
procedure Check_PS2_GameName;   { 讀出日文遊戲名稱 }
function  Check_SAVGM_File: Boolean;    { 等待並解析遊戲保存目錄資料檔 }
function  GetFlags(flags: Integer): string;     { 傳回檔案旗號意義 }
function  GetTimeStr(dTime: TPS2_TIME): string; { 傳回檔案時間字串 }
function  Get_CMD_File_Size: Integer;
function  goBackLevel(s: string): string;
function  PadStr(s: string; len, mode: Integer): string;    { 替字串補上空白 }
procedure Parse_mc_dir(slot: Integer);          { 解析目錄資料 }
procedure ProcMsg(s: string);           { 輸出處理訊息 }
function  PS2_MC_Thread(pr: Pointer): LongInt;  stdcall;    { 底層主要執行緒 }
procedure quit_thread;
procedure SaveGameFile(slot: Integer; ppd: PPS2_DIR);       { 另存新檔 }
procedure SeeItsName(slot: Integer);
procedure SetMemCardInfo;               { 左右記憶卡是否存在 ? }
procedure SetMemCardDIR;                { 是記憶卡新讀取的目錄內容 }
procedure SetRead_Game(slot: Integer);  { 儲存整個遊戲檔案目錄 }
procedure SetRead_GameName(slot: Integer);      { 設定取得當前記憶卡根目錄及其遊戲名稱 }
procedure SetRead_MC(slot: Integer);    { 設定重讀當前記憶卡目錄 }
procedure Set_GetFile(slot: Integer);
procedure Set_RestoreFile(slot: Integer);       { 還原單一記憶卡檔案 }
procedure Set_RestoreGame(slot: Integer);       { 還原遊戲記憶卡檔案 }
procedure Switch_List_Mode;
procedure Update_Title_info;
procedure UseThisItem(slot: Integer);
procedure Work_Done;
function  Write_CMD_File: Integer;

const
   TO_QUIT = -1;
   NO_JOB = 0;
   GAME_NAME = 1;
   SEE_DIR = 2;
   GET_FILE = 3;
   GET_GAME = 4;
   RESTORE_FILE = 5;
   RESTORE_GAME = 6;
   DIR_BUF_SIZE = 16384;
   ICON_BUF_SIZE = 8192;
   EQU_PS2DIR  = $8427;
   EQU_PS2FILE = $8497;         { 或 $8417 }
   MAX_DIR_COUNT = DIR_BUF_SIZE shr 6;
   DIR_ANS_FILE: string = 'PS2MCDIR.$$$';       { PS2 寫給電腦的目錄讀取報告 }
   KBFREE_NOWDIR: string = ' Kbytes 可用, 現在目錄: ';
   GAME_NAME_FILE: string = 'PS2GNAME.$$$';     { PS2 寫給電腦的目錄及遊戲名稱讀取報告 }
   PC_CMD_FILE0: string = 'C:\PCFORPS2.$$0';    { 電腦寫給 PS2 的命令資料 }
   PC_CMD_FILE: string = 'C:\PCFORPS2.$$$';     { 電腦寫給 PS2 的命令資料 }
   PS2_CMD_FILE: string = 'C:\PS2_CMD.$$$';     { PS2 寫給電腦的報告資料 }
   PS2_IS_BUSY: string = 'PS2 忙碌中, 請稍後再試 !';
   SAVE_LOG_FILE: string = 'DIR_LOG.PS2';       { 針對該層目錄的 PS2 目錄資訊 }
   SYS_ICON_FILE: string = 'PS2_ICON.$$$';      { PS2 寫給電腦的 icon.sys 讀取報告 }
   LR: array [0..1] of string = ('左記憶卡', '右記憶卡');

var
   Work_Id: Integer = NO_JOB;
   Next_Work: Integer = NO_JOB;         { 如果此值非零, 則讀取 C:\PS2_CMD.$$$ 此檔後須做此事 }
   chk_slot: Integer;
   MC_free: array [0..1] of Integer;
   pIO: PChar;
   JpnName: array [0..1] of PChar;      { 各含 32 * MAX_DIR_COUNT bytes 的日文遊戲名稱 }
   MC_DIR: array [0..1] of PChar;
   icon_Buf: PChar;
   parse_mode: Boolean = false;         { T: 看日文遊戲名稱, F: 看目錄名稱 }
   bAbort: Boolean = false;
   MC_changed: array [0..1] of Boolean;
   MC_exist: array [0..1] of Boolean;
   MC_path: array [0..1] of string;     { 目前的記憶卡目錄位置 }
   pc_fn, mc_fn: string;

// {$I DEBUG.PAS}
{$I Hex.PAS}
// {$L DEBUGMON.OBJ}
{$L Hex.OBJ}

implementation

uses MY_USB1, PS2Icon;

function  Arrange_JOB(job: Integer): Boolean;
begin
     Result := false;   { 假設成功 }
     if Work_Id = NO_JOB then Work_Id := job
     else begin
        if Next_Work = NO_JOB then Next_Work := job
        else begin
            MYUSB.StatBar.Panels[2].Text := PS2_IS_BUSY;
            Result := True;    { 排程失敗 }
        end;
     end;
end;

function  check_CRC32(fn: string): Integer;
var
   p: PChar;
   fh, i, len, v: Integer;
begin
     fn := pc_fn + '\' + fn;    { 加入上層目錄 }
     fh := FileOpen(fn, fmOpenRead or fmShareDenyNone);
     Result := 0;
     if fh > 5 then begin
        len := FileSeek(fh, 0, 2);      p := AllocMem(((len + 31) shr 4) shl 4);
        FileSeek(fh, 0, 0);             FileRead(fh, p^, len);    FileClose(fh);
        // 公式方法須與 mc_dir.c 的 int ez_crc32(unsigned char *s, int len) 一致
        v := $53554352;	                // 自訂 magic value = "SUCR"
        for i := 0 to len - 1 do begin
            fh := Byte(p[i]);
	    Inc(v, fh + 5);	        fh := fh shl 6;
            Inc(v, fh);                 fh := fh shl 3;
            Inc(v, fh);                 fh := fh shl 2;
            Inc(v, fh);                 
        end;
        FreeMem(p);                     Result := v;
     end;
end;

function  Check_DIR_File: Boolean;
var     { 等待並解析目錄資料檔 }
   pTmp: PChar;
   fh, len, slot: Integer;
   s: string;
begin
     s := my_path + DIR_ANS_FILE;       Result := false;
     if FileExists(s) then begin        { 等待此檔完成 }
        DeleteFile(PC_CMD_FILE);        { 刪除電腦命令檔案 }
        fh := FileOpen(s, fmOpenRead);
        if fh < 0 then Exit;                    { 該檔案尚未完成 }
        pTmp := AllocMem(DIR_BUF_SIZE);
        len := FileRead(fh, pTmp^, DIR_BUF_SIZE);       FileClose(fh);
        if len < DIR_BUF_SIZE then begin FreeMem(pTmp);  Exit;  end;    { 該檔案尚未完成 }

        DeleteFile(s);          { 讀完後先刪除 }
        slot := ReadDW(pTmp, DIR_BUF_SIZE - 8);
        Move(pTmp^, MC_DIR[slot]^, DIR_BUF_SIZE);
        Parse_mc_dir(slot);             { 解析目錄資料 }
        FreeMem(pTmp);          // MC_changed[slot] := True;
        Update_Title_info;
        Result := True;         Work_Done;
     end;
end;

function  Check_GameName_File(slot: Integer): Boolean;
var     { 等待並解析目錄與遊戲名稱資料檔 }
   pTmp: PChar;
   fh, cnt, len: Integer;
   s: string;
begin
     s := my_path + GAME_NAME_FILE;     Result := false;
     if FileExists(s) then begin        { 等待此檔完成 }
        DeleteFile(PC_CMD_FILE);        { 刪除電腦命令檔案 }
        fh := FileOpen(s, fmOpenRead);
        if fh < 0 then Exit;                    { 該檔案尚未完成 }
        FileRead(fh, pIO^, 16);
        cnt := ReadDW(pIO, 0);          { byte [0..3] = int total_item_count }
        if cnt < 1 then begin FileClose(fh);  Exit;  end;   { 該檔案尚未完成 }

        len := cnt shl 7;       { 目錄 (64 bytes) 與遊戲名稱 (64 bytes) }
        pTmp := AllocMem(len);
        FileRead(fh, pTmp^, len);       FileClose(fh);
        DeleteFile(s);          { 讀完後先刪除 }
        ZeroMemory(MC_DIR[slot], DIR_BUF_SIZE);
        ZeroMemory(JpnName[slot], DIR_BUF_SIZE);
        len := cnt shl 6;
        Move(pTmp^, MC_DIR[slot]^, len);
        Move(pTmp[len], JpnName[slot]^, len);
        Parse_mc_dir(slot);     { 解析目錄資料 }
        FreeMem(pTmp);          MC_changed[slot] := false;
        Result := True;
     end;
end;

procedure Check_PS2_CMD_File;
var
   fh: Integer;
   s: string;
begin   { 檢查是否有 C:\PS2_CMD.$$$ 出現 }
     fh := FileOpen(PS2_CMD_FILE, fmOpenRead);
     if fh > 0 then begin
        FileRead(fh, pIO^, 1024);
        FileClose(fh);          DeleteFile(PS2_CMD_FILE);
        DeleteFile(my_path + DIR_ANS_FILE);
        if ReadInt(pIO, 0) = $434D then begin   { 是 'MC' }
            MYUSB.Form1.BringToFront;
            s := StrPas(pIO + 3);       { 取得資訊意涵 }
            if s = 'INFO' then SetMemCardInfo;  { 左右記憶卡是否存在 ? }
        end;
     end
     else Sleep(125);           { 至少一秒須檢查八次 }
end;

procedure Check_PS2_GameName;
begin   { 讀出日文遊戲名稱 }
     if MC_changed[0] then SetRead_GameName(0);
     if MC_changed[1] then SetRead_GameName(1);
     if (MC_changed[0] or MC_changed[1]) then Exit;
     Work_Done;         { 遊戲名稱檢查完畢 }
end;

function  Check_SAVGM_File: Boolean;
var     { 等待並解析遊戲保存目錄資料檔 }
   ppd: PPS2_DIR;
   pTmp: PChar;
   fh, i, len: Integer;
   s: string;
begin
     s := pc_fn + '\' + SAVE_LOG_FILE;  Result := false;
     if FileExists(s) then begin        { 等待此檔完成 }
        DeleteFile(PC_CMD_FILE);        { 刪除電腦命令檔案 }

        fh := FileOpen(s, fmOpenRead);
        if fh < 0 then Exit;                    { 該檔案尚未完成 }
        { 讀取並分析是否還有子目錄 ! }
        pTmp := AllocMem(DIR_BUF_SIZE);
        len := FileRead(fh, pTmp^, DIR_BUF_SIZE);       FileClose(fh);
        if len < 1 then begin FreeMem(pTmp);  Exit;  end;       { 該檔案尚未完成 }
//        slot := ReadDW(pTmp, DIR_BUF_SIZE - 8);
        fh := 0;
        ppd := PPS2_DIR(pTmp);  { 轉換成檔案目錄指標陣列 }
        for i := 1 to (DIR_BUF_SIZE shr 6) do begin
            if ppd^.fname[0] = #0 then Break;
            s := StrPas(ppd^.fname);
            if ppd^.flag = EQU_PS2DIR then begin
                if (s = '.') or (s = '..') then begin  Inc(ppd);  continue; end;
                Inc(fh);        { 子目錄數量加一 }
            end
            else begin  { 檢查檔案的 CRC-32 是否正確 }
                if ppd^.blks > 0 then begin { 檔案的長度 > 0 }
                   len := check_CRC32(ppd^.fname);
                   if len <> ppd^.pad1 then begin
                        ProcMsg('注意: ' + ppd^.fname + ' 的 CRC32 檢查檢查不合 !');
                        ProcMsg('  正確的 CRC32 = 0x' + IntToHex(ppd^.pad1, 8) + ', 錯誤的 CRC32 = 0x' + IntToHex(len, 8));
                   end;
                end
                else ProcMsg('注意: ' + ppd^.fname + ' 的檔案長度是 0, 不必儲存 !');
            end;
            Inc(ppd);
        end;
        if fh > 0 then begin    { 本程式不遞回處理, 因此只處理到此, 做太多會當機 (fileio.c bug) }
            MessageBox(MYUSB.Handle, '注意: 此遊戲尚有子目錄, 請自行手動儲存 !', '尚有子目錄未儲存 !', MB_OK);
            MYUSB.StatBar.Panels[2].Text := '尚有' + IntToStr(fh) + '個子目錄未儲存 !';
            ProcMsg('注意: 此遊戲尚有' + IntToStr(fh) + '個子目錄未儲存 !');
        end
        else MYUSB.StatBar.Panels[2].Text := '遊戲已儲存 !';
        ProcMsg('遊戲已儲存');
        // 開始動畫
        fh := FileOpen(pc_fn + '\icon.sys', fmOpenRead);
        if fh > 0 then begin
            ZeroMemory(pTmp, 512);      FileRead(fh, pTmp^, 512);
            FileClose(fh);      s := pc_fn + '\' + StrPas(pTmp + $104); // $144, $184
            ICONS.DisplayIcon(s);               // 顯示立體圖徵 (3D ICON)
            ICONS.MayClose(pTmp + $C0);         // 遊戲名稱
        end;
        FreeMem(pTmp);          DeleteFile(PC_CMD_FILE);    { 刪除電腦命令檔案 }
        Result := True;         Work_Done;
     end;
end;

function  GetFlags(flags: Integer): string;
var     { 傳回檔案旗號意義 }
   ans: array [0..8] of Char;
begin
     FillChar(ans[0], 8, #32);          ans[8] := #0;
     case flags of
        EQU_PS2DIR:  Result := '<DIR>'; { 是一般目錄 }
        EQU_PS2FILE: Result := '     '; { 是一般檔案 }
        else Result := Format('$%04X', [flags]);        { 不明 !? }
     end;
end;

function  GetTimeStr(dTime: TPS2_TIME): string;
begin
     Result := Format(' %02d-%02d-%02d %02d:%02d:%02d ', [dTime.year, dTime.month,
        dTime.date, dTime.hour, dTime.min, dTime.sec]);
end;

function  Get_CMD_File_Size: Integer;
var
   fh, i: Integer;
begin
     fh := FileOpen(PC_CMD_FILE, fmOpenRead);
     if fh < 0 then begin Result := -1;  Exit;  end;
     i := FileSeek(fh, 0, 2);           FileClose(fh);
     Result := i;
end;

function  goBackLevel(s: string): string;
var
   i, len: Integer;
begin   { s 不是 '/*' }
     len := Length(s);
     { 倒退找 '/' }
     for i := len - 2 downto 1 do begin
        if s[i] = '/' then begin
            Result := Copy(s, 1, i) + '*';
            Exit;
        end;
     end;
     Result := '/*';    { 完全失敗 ! }
end;

function  PadStr(s: string; len, mode: Integer): string;
var     { 替字串補上空白 }
   l: Integer;
begin
     l := Length(s);
     if l >= len then begin
        Result := Copy(s, 1, len);      { 太長則截短 }
        Exit;
     end;
     { 太短則於前(mode=0) 或後(mode=1) 補上空白 }
     if mode <> 0 then Result := s + StringOfChar(' ', len - l)
     else Result := StringOfChar(' ', len - l) + s;
end;

procedure Parse_mc_dir(slot: Integer);
var
   ppd: PPS2_DIR;
   pN: PChar;
   i: Integer;
   s: string;
begin   { 解析目錄資料 (MC_DIR[x]) }
     if slot = 0 then MYUSB.ListBox1.Clear
     else MYUSB.ListBox2.Clear;
     ppd := PPS2_DIR(MC_DIR[slot]);     { 轉換成檔案目錄指標陣列 }
     pN := JpnName[slot];               { 轉換成遊戲名稱字串指標陣列 }
     if ppd^.fname[0] = '.' then parse_mode := false;   { 子目錄內沒有遊戲名稱 }
     for i := 0 to MAX_DIR_COUNT do begin
        if ppd^.fname[0] = #0 then Exit;        { 解析完成 }
        if parse_mode then begin        { 以遊戲名稱觀點 }
            if pN[0] = #0 then s := '--- No game name found ! ---'
            else s := StrPas(pN);
        end
        else begin { 以檔案目錄觀點 }
            s := PadStr(StrPas(ppd^.fname), 50, 1) + '  ' + GetFlags(ppd^.flag);
            s := s + Format('   %7d   ', [ppd^.blks]) + GetTimeStr(ppd^.build_time);
        end;
        if slot = 0 then MYUSB.ListBox1.Items.Add(s)
        else MYUSB.ListBox2.Items.Add(s);
        Inc(ppd);       Inc(pN, 64);
     end;
end;

procedure ProcMsg(s: string);
begin   { 輸出處理訊息 }
     MYUSB.Memo2.Lines.Add(s);
     MYUSB.Form1.BringToFront;
end;

function  PS2_MC_Thread(pr: Pointer): LongInt;  stdcall;
var
   fhnd: Integer;
begin   { 底層主要執行緒 }
     pIO := AllocMem(1024);     { 與 PS2 溝通用緩衝區 }
     icon_Buf := AllocMem(ICON_BUF_SIZE);       { 暫放 PS2 的 icon.sys }
     MC_DIR[0] := AllocMem(DIR_BUF_SIZE);       { 放當前觀察的記憶卡目錄內容 }
     MC_DIR[1] := AllocMem(DIR_BUF_SIZE);
     JpnName[0] := AllocMem(DIR_BUF_SIZE);      { 放日文遊戲名稱, 1 組 = 64 bytes }
     JpnName[1] := AllocMem(DIR_BUF_SIZE);
     MC_path[0] := '/*';        MC_path[1] := '/*';     { 預設讀取記憶卡根目錄 }
     DeleteFile(PC_CMD_FILE);           { 防止 PS2 誤動作 }
     fhnd := FileCreate(fn_PC_init_OK); { 本程式離開前, 便刪除此檔 ! }
     if fhnd < 0 then begin     { 不太可能 ! }
        MemoWrite('無法建立檔案 : ' + fn_PC_init_OK);
        MemoWrite('請關閉本程式 !');
     end;
     FileClose(fhnd);
     fhnd := FileCreate(my_path + DIR_ANS_FILE);        { 測試能否建檔 ! }
     if fhnd < 0 then my_path := 'C:\';                 { 若不行則使用 C:\ }
     FileClose(fhnd);           DeleteFile(my_path + fn_PC_init_OK);
     Sleep(500);                // my_path := 'C:\';
     ProcMsg('背景執行緒工作目錄 = ' + my_path);
     repeat
        case Work_Id of
            NO_JOB:
              begin
                if Next_Work <> NO_JOB then begin
                    Work_Id := Next_Work;       Next_Work := NO_JOB;    end
                else begin
                    MYUSB.StatBar.Panels[2].Text := '';
                    Check_PS2_CMD_File;         { 檢查是否有 C:\PS2_CMD.$$$ 出現 }
                    Check_DIR_File;             { 檢查是否有 C:\PS2MCDIR.$$$ 出現 }
                end;
              end;
            GAME_NAME: Check_PS2_GameName;      { 檢查遊戲名稱 }
            GET_FILE: Set_GetFile(chk_slot);    { 取得記憶卡檔案 }
            GET_GAME: SetRead_Game(chk_slot);   { 儲存整個遊戲檔案目錄 }
            RESTORE_FILE: Set_RestoreFile(chk_slot);    { 還原單一記憶卡檔案 }
            RESTORE_GAME: Set_RestoreGame(chk_slot);    { 還原遊戲記憶卡檔案 }
            SEE_DIR: SetRead_MC(chk_slot);      { 查看目錄內容 }
        end;
//        DebugStr(0, 0, 'Work_Id = ');  DebugHex(Work_Id, 4);
     until bAbort or (Work_Id = TO_QUIT);
     FreeMem(pIO);
     Result := 0;
end;

procedure quit_thread;
begin
     bAbort := True;          DeleteFile(PC_CMD_FILE);
     Work_Id := TO_QUIT;
end;

procedure SaveGameFile(slot: Integer; ppd: PPS2_DIR);
var
   s: string;
begin   { 另存新檔 }
     if ppd^.blks < 1 then Exit;        { 檔案長度是 0 ! }
     MYUSB.SaveDlg1.FileName := StrPas(ppd^.fname);
     if not MYUSB.SaveDlg1.Execute then Exit;
     chk_slot := slot;
     pc_fn := MYUSB.SaveDlg1.FileName;
     s := MC_path[slot];
     mc_fn := Copy(s, 1, Length(s) - 1) + StrPas(ppd^.fname);
     MYUSB.StatBar.Panels[2].Text := '即將取得記憶卡檔案 : ' + mc_fn;
     ProcMsg('將由' + LR[slot] + '下載檔案 : ' + mc_fn);
     ProcMsg(', 存到電腦目錄 ' + pc_fn);
     Arrange_JOB(GET_FILE);     { 取得記憶卡檔案 }
end;

procedure SeeItsName(slot: Integer);
var
   ppd: PPS2_DIR;
   pN: PChar;
   i: Integer;
   s: string;
begin   { 解析目錄資料 (MC_DIR[x]) }
     if slot = 0 then begin
          i := MYUSB.ListBox1.ItemIndex;
          s := MYUSB.ListBox1.Items[i];          end
     else begin
          i := MYUSB.ListBox2.ItemIndex;
          s := MYUSB.ListBox2.Items[i];          end;
     ppd := PPS2_DIR(MC_DIR[slot]);     { 轉換成檔案目錄指標陣列 }
     if ppd^.fname[0] = '.' then Exit;  { 子目錄內沒有遊戲名稱,　不必再看 ! }

     ppd := PPS2_DIR(MC_DIR[slot] + (i * SizeOf(TPS2_DIR)));    { 轉換成檔案目錄指標陣列 }
     pN := JpnName[slot] + (i shl 6);   { 轉換成遊戲名稱字串指標陣列 }
     if s[1] > #$7f then begin          { 以檔案目錄觀點 }
        if ppd^.fname[0] = #0 then s := ''      { 此處無檔案或目錄, 解析完成 }
        else begin
            s := PadStr(StrPas(ppd^.fname), 50, 1) + '  ' + GetFlags(ppd^.flag);
            s := s + Format('   %7d   ', [ppd^.blks]) + GetTimeStr(ppd^.build_time);
        end;
     end
     else begin { 以遊戲名稱觀點 }
        if pN[0] = #0 then s := '--- No game name found ! ---'
            else s := StrPas(pN);       { = 遊戲名 }
     end;
     if slot = 0 then MYUSB.ListBox1.Items[i] := s
     else MYUSB.ListBox2.Items[i] := s;
end;

procedure SetMemCardDIR;
begin   { 是記憶卡新讀取的目錄內容 }
     Parse_mc_dir(chk_slot);
end;

procedure SetMemCardInfo;
var
   i: Integer;
begin   { 左右記憶卡是否存在 ? }
     ProcMsg('分析' + LR[0] + '是否有效');
     MC_exist[0] := false;      MC_free[0] := 0;        { 假設左記憶卡不存在 }
     if pIO[16] = #2 then begin { 左記憶卡是有效的記憶卡 }
        MC_exist[0] := True;    i := ReadDW(pIO, 20) - 2;
        if i <> MC_free[0] then MC_changed[0] := True;
        MC_free[0] := i;
     end;

     ProcMsg('分析' + LR[1] + '是否有效');
     MC_exist[1] := false;      MC_free[1] := 0;        { 假設右記憶卡不存在 }
     if pIO[208] = #2 then begin { 右記憶卡是有效的記憶卡 }
        MC_exist[1] := True;    i := ReadDW(pIO, 212) - 2;
        if i <> MC_free[1] then MC_changed[1] := True;
        MC_free[1] := i;
     end;

     Update_Title_info;
     if (MC_changed[0] or MC_changed[1]) then Work_Id := GAME_NAME;   { 須重讀遊戲名稱 }
end;

procedure SetRead_Game(slot: Integer);
var
   s: string;
   This_done: Boolean;
begin   { 儲存整個遊戲檔案目錄 }
     if bAbort then Exit;       { user abort ! }
     ZeroMemory(pIO, 1024);
     pIO[0] := 'S';             pIO[1] := Char(slot and 1);     { save Directory ! }
     StrPCopy(pIO + $10, 'host:' + pc_fn);      { 存放結果的電腦檔案名稱 }
     StrPCopy(pIO + $110, mc_fn);     { 想存的 PS2 目錄名稱 }
     if Write_CMD_File < 0 then Exit; { 必須迅速寫出檔案 }
     MYUSB.StatBar.Panels[2].Text := '準備儲存整個遊戲到 ' + pc_fn;
     s := pc_fn + '\' + SAVE_LOG_FILE;
     if FileExists(s) then DeleteFile(s);       { 防止此檔預先存在 }
     ProcMsg('準備保存' + LR[slot] + '遊戲到電腦 ' + pc_fn);
     repeat
        if Get_CMD_File_Size < 16 then Write_CMD_File;
        This_done := Check_SAVGM_File;
        Sleep(125);
     until bAbort or This_done;
     Work_Done;         Sleep(300);     DeleteFile(PC_CMD_FILE);
end;

procedure SetRead_GameName(slot: Integer);
var
   This_done: Boolean;
begin   { 設定取得當前記憶卡根目錄及其遊戲名稱 }
     if bAbort then Exit;       { user abort ! }
     DeleteFile(my_path + GAME_NAME_FILE);
     ZeroMemory(pIO, 1024);
     pIO[0] := 'N';             pIO[1] := Char(slot and 1);     { read Game Name ! }
     StrPCopy(pIO + $10, 'host:' + my_path + GAME_NAME_FILE);   { 存放結果的電腦檔案名稱 }
     if Write_CMD_File < 0 then Exit;           { 必須迅速寫出檔案 }
     MYUSB.StatBar.Panels[2].Text := '準備取得遊戲名稱 ...';
     ProcMsg('準備取得' + LR[slot] + '遊戲名稱');
     repeat
        if Get_CMD_File_Size < 16 then Write_CMD_File;
        This_done := Check_GameName_File(slot);
        Sleep(125);
     until bAbort or This_done;
     Work_Done;
end;

procedure SetRead_MC(slot: Integer);
var
   s: string;
   This_done: Boolean;
begin   { 設定重讀當前記憶卡目錄 }
     if bAbort then Exit;       { user abort ! }
     ZeroMemory(pIO, 1024);
     pIO[0] := 'D';             pIO[1] := Char(slot and 1);     { read Directory ! }
     s := my_path + DIR_ANS_FILE;     { 要記得加 host: }
     StrPCopy(pIO + $10, 'host:' + s);          { 存放結果的電腦檔案名稱 }
     StrPCopy(pIO + $110, MC_path[slot]);       { 想看的 PS2 目錄名稱 }
     if Write_CMD_File < 0 then Exit;           { 必須迅速寫出檔案 }
     ProcMsg('準備取得' + LR[slot] + '目錄內容 ' + MC_path[slot]);
     repeat
        if Get_CMD_File_Size < 16 then Write_CMD_File;
        This_done := Check_DIR_File;
        Sleep(125);
     until bAbort or This_done;
     Work_Done;         DeleteFile(PC_CMD_FILE);
end;

procedure Set_GetFile(slot: Integer);
var
   This_done: Boolean;
begin   { 取得記憶卡檔案 }
     if bAbort then Exit;       { user abort ! }
     ZeroMemory(pIO, 1024);
     pIO[0] := 'C';             pIO[1] := Char(slot and 1);     { copy file to PC ! }
     StrPCopy(pIO + $10, 'host:' + pc_fn);      { 存放結果的電腦檔案名稱 }
     StrPCopy(pIO + $110, mc_fn);               { 想要的 PS2 檔案名稱 }
     if Write_CMD_File < 0 then Exit;           { 必須迅速寫出檔案 }
     MYUSB.StatBar.Panels[2].Text := '準備取得檔案 ' + pc_fn;
     ProcMsg('準備拷貝' + LR[slot] + '檔案 ' + pc_fn);
     This_done := false;
     repeat
        if Get_CMD_File_Size < 16 then Write_CMD_File;
        if FileExists(pc_fn) then begin         { 等待此檔完成 }
            DeleteFile(PC_CMD_FILE);            { 刪除電腦命令檔案 }
            This_done := True;
        end;
        Sleep(125);
     until bAbort or This_done;
     Work_Done;
end;

procedure  Set_RestoreFile(slot: Integer);
var
   fh: Integer;
   This_done: Boolean;
begin   { 還原單一記憶卡檔案 }
     if bAbort then Exit;       { user abort ! }
     ZeroMemory(pIO, 1024);
     pIO[0] := 'W';             pIO[1] := Char(slot and 1);     { restore one file to PS2 ! }
     StrPCopy(pIO + $10, 'host:' + pc_fn);      { 存放電腦檔案名稱 }
     StrPCopy(pIO + $110, mc_fn);               { 想的遊戲 PS2 記憶卡路徑, 尾端不含 '/' }
     if Write_CMD_File < 0 then Exit;           { 必須迅速寫出檔案 }
     MYUSB.StatBar.Panels[2].Text := '準備還原單一記憶卡檔案 ' + mc_fn;
     ProcMsg('準備還原' + LR[slot] + '單一記憶卡檔案 ' + mc_fn);
     This_done := false;
     repeat
        if FileExists(PS2_CMD_FILE) then begin  { 等待此檔產生 }
            DeleteFile(PC_CMD_FILE);            { 刪除電腦命令檔案 }
            fh := FileOpen(PS2_CMD_FILE, fmOpenRead);
            if fh > 0 then begin
                if FileSeek(fh, 0, 2) > 0 then begin
                    This_done := True; { 有長度便是好了 }
                end;
                FileClose(fh);
            end;
        end
        else if Get_CMD_File_Size < 16 then Write_CMD_File;
        Sleep(125);
     until bAbort or This_done;
     Work_Done;         MC_changed[slot] := True;
end;

procedure Set_RestoreGame(slot: Integer);
var
   fh: Integer;
   This_done: Boolean;
begin   { 還原遊戲記憶卡檔案 }
     if bAbort then Exit;       { user abort ! }
     ZeroMemory(pIO, 1024);
     pIO[0] := 'R';             pIO[1] := Char(slot and 1);     { restore game to PS2 ! }
     StrPCopy(pIO + $10, 'host:' + pc_fn);      { 存放電腦檔案路徑, 尾端不含 '\' }
     StrPCopy(pIO + $110, mc_fn);               { 想的遊戲 PS2 記憶卡路徑, 尾端不含 '/' }
     if Write_CMD_File < 0 then Exit;           { 必須迅速寫出檔案 }
     MYUSB.StatBar.Panels[2].Text := '準備還原遊戲 ' + mc_fn;
     ProcMsg('準備還原' + LR[slot] + '遊戲 ' + mc_fn);
     This_done := false;
     repeat
        if FileExists(PS2_CMD_FILE) then begin  { 等待此檔產生 }
            DeleteFile(PC_CMD_FILE);            { 刪除電腦命令檔案 }
            fh := FileOpen(PS2_CMD_FILE, fmOpenRead);
            if fh > 0 then begin
                if FileSeek(fh, 0, 2) > 0 then begin
                    This_done := True; { 有長度便是好了 }
                end;
                FileClose(fh);
            end;
        end
        else if Get_CMD_File_Size < 16 then Write_CMD_File;
        Sleep(125);
     until bAbort or This_done;
     Work_Done;     //    DeleteFile(PS2_CMD_FILE);
     MC_changed[slot] := True;          ICONS.Stop_Show;
end;

procedure Switch_List_Mode;
begin
     parse_mode := not parse_mode;
     Parse_mc_dir(0);   Parse_mc_dir(1);
end;

procedure Update_Title_info;
var
   s: string;
begin
     s := '左側記憶卡：';
     if MC_exist[0] then begin
        s := s + IntToStr(MC_free[0]) + KBFREE_NOWDIR;
        s := s + MC_path[0];
        ProcMsg(LR[0] + '可用空間 ' + IntToStr(MC_free[0]) + ' Kb');
     end;
     MYUSB.Label1.Caption := s;

     s := '右側記憶卡：';
     if MC_exist[1] then begin
        s := s + IntToStr(MC_free[1]) + KBFREE_NOWDIR;
        s := s + MC_path[1];
        ProcMsg(LR[1] + '可用空間 ' + IntToStr(MC_free[1]) + ' Kb');
     end;
     MYUSB.Label2.Caption := s;
end;

procedure UseThisItem(slot: Integer);
var
   ppd: PPS2_DIR;
   i: Integer;
   s: string;
begin   { 若是目錄則切入, 若是檔案則拷貝到電腦 }
     if Work_Id <> NO_JOB then begin
        MYUSB.StatBar.Panels[2].Text := PS2_IS_BUSY;
        Exit;
     end;
     if slot = 0 then i := MYUSB.ListBox1.ItemIndex
     else i := MYUSB.ListBox2.ItemIndex;
     ppd := PPS2_DIR(MC_DIR[slot] + (i * SizeOf(TPS2_DIR)));    { 轉換成檔案目錄指標陣列 }
     if ppd^.fname[0] = #0 then Exit;   { 此處無檔案或目錄, 解析完成 }
     if ppd^.flag <> EQU_PS2DIR then begin
        SaveGameFile(slot, ppd);        { 另存新檔 }
        Exit;
     end;

     s := MC_path[slot];        chk_slot := slot;
     if s <> '/*' then begin
        if i = 0 then Exit;     { 必是 '.' }
        if i = 1 then begin     { 必是 '..', 回上層目錄 }
            s := goBackLevel(s);
            i := 1000;
        end;
     end;
     if i < 999 then s := Copy(s, 1, Length(s) - 1) + StrPas(ppd^.fname) + '/*'; { 往下層目錄 }
     MYUSB.StatBar.Panels[2].Text := '正要切入目錄 : ' + s;
     MC_path[slot] := s;
     Arrange_JOB(SEE_DIR);
end;

procedure Work_Done;
begin
     if Next_Work <> NO_JOB then Work_Id := Next_Work
     else Work_Id := NO_JOB;
     Next_Work := NO_JOB;
end;

function  Write_CMD_File: Integer;
var
   fh: Integer;
begin
     DeleteFile(PC_CMD_FILE);
     fh := FileCreate(PC_CMD_FILE0);            { 必須迅速寫出檔案 }
     Result := fh;
     if fh < 0 then begin
        MYUSB.Memo1.Lines.Add('無法產生命令檔 ' + PC_CMD_FILE);
        Exit;
     end;
     FileWrite(fh, pIO^, 1024);         FileClose(fh);
     RenameFile(PC_CMD_FILE0, PC_CMD_FILE);     Sleep(30);
     Result := 0;
end;

end.
