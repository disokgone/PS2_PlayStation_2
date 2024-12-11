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

function  Arrange_JOB(job: Integer): Boolean;   { �Ǧ^ T: �Ƶ{���� }
function  check_CRC32(fn: string): Integer;     { �p�� CRC-32 }
function  Check_DIR_File: Boolean;      { ���ݨøѪR�ؿ������ }
function  Check_GameName_File(slot: Integer): Boolean;  { ���ݨøѪR�ؿ��P�C���W�ٸ���� }
procedure Check_PS2_CMD_File;   { �ˬd�O�_�� C:\PS2_CMD.$$$ �X�{ }
procedure Check_PS2_GameName;   { Ū�X���C���W�� }
function  Check_SAVGM_File: Boolean;    { ���ݨøѪR�C���O�s�ؿ������ }
function  GetFlags(flags: Integer): string;     { �Ǧ^�ɮ׺X���N�q }
function  GetTimeStr(dTime: TPS2_TIME): string; { �Ǧ^�ɮ׮ɶ��r�� }
function  Get_CMD_File_Size: Integer;
function  goBackLevel(s: string): string;
function  PadStr(s: string; len, mode: Integer): string;    { ���r��ɤW�ť� }
procedure Parse_mc_dir(slot: Integer);          { �ѪR�ؿ���� }
procedure ProcMsg(s: string);           { ��X�B�z�T�� }
function  PS2_MC_Thread(pr: Pointer): LongInt;  stdcall;    { ���h�D�n����� }
procedure quit_thread;
procedure SaveGameFile(slot: Integer; ppd: PPS2_DIR);       { �t�s�s�� }
procedure SeeItsName(slot: Integer);
procedure SetMemCardInfo;               { ���k�O�Хd�O�_�s�b ? }
procedure SetMemCardDIR;                { �O�O�Хd�sŪ�����ؿ����e }
procedure SetRead_Game(slot: Integer);  { �x�s��ӹC���ɮץؿ� }
procedure SetRead_GameName(slot: Integer);      { �]�w���o��e�O�Хd�ڥؿ��Ψ�C���W�� }
procedure SetRead_MC(slot: Integer);    { �]�w��Ū��e�O�Хd�ؿ� }
procedure Set_GetFile(slot: Integer);
procedure Set_RestoreFile(slot: Integer);       { �٭��@�O�Хd�ɮ� }
procedure Set_RestoreGame(slot: Integer);       { �٭�C���O�Хd�ɮ� }
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
   EQU_PS2FILE = $8497;         { �� $8417 }
   MAX_DIR_COUNT = DIR_BUF_SIZE shr 6;
   DIR_ANS_FILE: string = 'PS2MCDIR.$$$';       { PS2 �g���q�����ؿ�Ū�����i }
   KBFREE_NOWDIR: string = ' Kbytes �i��, �{�b�ؿ�: ';
   GAME_NAME_FILE: string = 'PS2GNAME.$$$';     { PS2 �g���q�����ؿ��ιC���W��Ū�����i }
   PC_CMD_FILE0: string = 'C:\PCFORPS2.$$0';    { �q���g�� PS2 ���R�O��� }
   PC_CMD_FILE: string = 'C:\PCFORPS2.$$$';     { �q���g�� PS2 ���R�O��� }
   PS2_CMD_FILE: string = 'C:\PS2_CMD.$$$';     { PS2 �g���q�������i��� }
   PS2_IS_BUSY: string = 'PS2 ���L��, �еy��A�� !';
   SAVE_LOG_FILE: string = 'DIR_LOG.PS2';       { �w��Ӽh�ؿ��� PS2 �ؿ���T }
   SYS_ICON_FILE: string = 'PS2_ICON.$$$';      { PS2 �g���q���� icon.sys Ū�����i }
   LR: array [0..1] of string = ('���O�Хd', '�k�O�Хd');

var
   Work_Id: Integer = NO_JOB;
   Next_Work: Integer = NO_JOB;         { �p�G���ȫD�s, �hŪ�� C:\PS2_CMD.$$$ ���ɫᶷ������ }
   chk_slot: Integer;
   MC_free: array [0..1] of Integer;
   pIO: PChar;
   JpnName: array [0..1] of PChar;      { �U�t 32 * MAX_DIR_COUNT bytes �����C���W�� }
   MC_DIR: array [0..1] of PChar;
   icon_Buf: PChar;
   parse_mode: Boolean = false;         { T: �ݤ��C���W��, F: �ݥؿ��W�� }
   bAbort: Boolean = false;
   MC_changed: array [0..1] of Boolean;
   MC_exist: array [0..1] of Boolean;
   MC_path: array [0..1] of string;     { �ثe���O�Хd�ؿ���m }
   pc_fn, mc_fn: string;

// {$I DEBUG.PAS}
{$I Hex.PAS}
// {$L DEBUGMON.OBJ}
{$L Hex.OBJ}

implementation

uses MY_USB1, PS2Icon;

function  Arrange_JOB(job: Integer): Boolean;
begin
     Result := false;   { ���]���\ }
     if Work_Id = NO_JOB then Work_Id := job
     else begin
        if Next_Work = NO_JOB then Next_Work := job
        else begin
            MYUSB.StatBar.Panels[2].Text := PS2_IS_BUSY;
            Result := True;    { �Ƶ{���� }
        end;
     end;
end;

function  check_CRC32(fn: string): Integer;
var
   p: PChar;
   fh, i, len, v: Integer;
begin
     fn := pc_fn + '\' + fn;    { �[�J�W�h�ؿ� }
     fh := FileOpen(fn, fmOpenRead or fmShareDenyNone);
     Result := 0;
     if fh > 5 then begin
        len := FileSeek(fh, 0, 2);      p := AllocMem(((len + 31) shr 4) shl 4);
        FileSeek(fh, 0, 0);             FileRead(fh, p^, len);    FileClose(fh);
        // ������k���P mc_dir.c �� int ez_crc32(unsigned char *s, int len) �@�P
        v := $53554352;	                // �ۭq magic value = "SUCR"
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
var     { ���ݨøѪR�ؿ������ }
   pTmp: PChar;
   fh, len, slot: Integer;
   s: string;
begin
     s := my_path + DIR_ANS_FILE;       Result := false;
     if FileExists(s) then begin        { ���ݦ��ɧ��� }
        DeleteFile(PC_CMD_FILE);        { �R���q���R�O�ɮ� }
        fh := FileOpen(s, fmOpenRead);
        if fh < 0 then Exit;                    { ���ɮש|������ }
        pTmp := AllocMem(DIR_BUF_SIZE);
        len := FileRead(fh, pTmp^, DIR_BUF_SIZE);       FileClose(fh);
        if len < DIR_BUF_SIZE then begin FreeMem(pTmp);  Exit;  end;    { ���ɮש|������ }

        DeleteFile(s);          { Ū������R�� }
        slot := ReadDW(pTmp, DIR_BUF_SIZE - 8);
        Move(pTmp^, MC_DIR[slot]^, DIR_BUF_SIZE);
        Parse_mc_dir(slot);             { �ѪR�ؿ���� }
        FreeMem(pTmp);          // MC_changed[slot] := True;
        Update_Title_info;
        Result := True;         Work_Done;
     end;
end;

function  Check_GameName_File(slot: Integer): Boolean;
var     { ���ݨøѪR�ؿ��P�C���W�ٸ���� }
   pTmp: PChar;
   fh, cnt, len: Integer;
   s: string;
begin
     s := my_path + GAME_NAME_FILE;     Result := false;
     if FileExists(s) then begin        { ���ݦ��ɧ��� }
        DeleteFile(PC_CMD_FILE);        { �R���q���R�O�ɮ� }
        fh := FileOpen(s, fmOpenRead);
        if fh < 0 then Exit;                    { ���ɮש|������ }
        FileRead(fh, pIO^, 16);
        cnt := ReadDW(pIO, 0);          { byte [0..3] = int total_item_count }
        if cnt < 1 then begin FileClose(fh);  Exit;  end;   { ���ɮש|������ }

        len := cnt shl 7;       { �ؿ� (64 bytes) �P�C���W�� (64 bytes) }
        pTmp := AllocMem(len);
        FileRead(fh, pTmp^, len);       FileClose(fh);
        DeleteFile(s);          { Ū������R�� }
        ZeroMemory(MC_DIR[slot], DIR_BUF_SIZE);
        ZeroMemory(JpnName[slot], DIR_BUF_SIZE);
        len := cnt shl 6;
        Move(pTmp^, MC_DIR[slot]^, len);
        Move(pTmp[len], JpnName[slot]^, len);
        Parse_mc_dir(slot);     { �ѪR�ؿ���� }
        FreeMem(pTmp);          MC_changed[slot] := false;
        Result := True;
     end;
end;

procedure Check_PS2_CMD_File;
var
   fh: Integer;
   s: string;
begin   { �ˬd�O�_�� C:\PS2_CMD.$$$ �X�{ }
     fh := FileOpen(PS2_CMD_FILE, fmOpenRead);
     if fh > 0 then begin
        FileRead(fh, pIO^, 1024);
        FileClose(fh);          DeleteFile(PS2_CMD_FILE);
        DeleteFile(my_path + DIR_ANS_FILE);
        if ReadInt(pIO, 0) = $434D then begin   { �O 'MC' }
            MYUSB.Form1.BringToFront;
            s := StrPas(pIO + 3);       { ���o��T�N�[ }
            if s = 'INFO' then SetMemCardInfo;  { ���k�O�Хd�O�_�s�b ? }
        end;
     end
     else Sleep(125);           { �ܤ֤@���ˬd�K�� }
end;

procedure Check_PS2_GameName;
begin   { Ū�X���C���W�� }
     if MC_changed[0] then SetRead_GameName(0);
     if MC_changed[1] then SetRead_GameName(1);
     if (MC_changed[0] or MC_changed[1]) then Exit;
     Work_Done;         { �C���W���ˬd���� }
end;

function  Check_SAVGM_File: Boolean;
var     { ���ݨøѪR�C���O�s�ؿ������ }
   ppd: PPS2_DIR;
   pTmp: PChar;
   fh, i, len: Integer;
   s: string;
begin
     s := pc_fn + '\' + SAVE_LOG_FILE;  Result := false;
     if FileExists(s) then begin        { ���ݦ��ɧ��� }
        DeleteFile(PC_CMD_FILE);        { �R���q���R�O�ɮ� }

        fh := FileOpen(s, fmOpenRead);
        if fh < 0 then Exit;                    { ���ɮש|������ }
        { Ū���ä��R�O�_�٦��l�ؿ� ! }
        pTmp := AllocMem(DIR_BUF_SIZE);
        len := FileRead(fh, pTmp^, DIR_BUF_SIZE);       FileClose(fh);
        if len < 1 then begin FreeMem(pTmp);  Exit;  end;       { ���ɮש|������ }
//        slot := ReadDW(pTmp, DIR_BUF_SIZE - 8);
        fh := 0;
        ppd := PPS2_DIR(pTmp);  { �ഫ���ɮץؿ����а}�C }
        for i := 1 to (DIR_BUF_SIZE shr 6) do begin
            if ppd^.fname[0] = #0 then Break;
            s := StrPas(ppd^.fname);
            if ppd^.flag = EQU_PS2DIR then begin
                if (s = '.') or (s = '..') then begin  Inc(ppd);  continue; end;
                Inc(fh);        { �l�ؿ��ƶq�[�@ }
            end
            else begin  { �ˬd�ɮת� CRC-32 �O�_���T }
                if ppd^.blks > 0 then begin { �ɮת����� > 0 }
                   len := check_CRC32(ppd^.fname);
                   if len <> ppd^.pad1 then begin
                        ProcMsg('�`�N: ' + ppd^.fname + ' �� CRC32 �ˬd�ˬd���X !');
                        ProcMsg('  ���T�� CRC32 = 0x' + IntToHex(ppd^.pad1, 8) + ', ���~�� CRC32 = 0x' + IntToHex(len, 8));
                   end;
                end
                else ProcMsg('�`�N: ' + ppd^.fname + ' ���ɮת��׬O 0, �����x�s !');
            end;
            Inc(ppd);
        end;
        if fh > 0 then begin    { ���{�������^�B�z, �]���u�B�z�즹, ���Ӧh�|��� (fileio.c bug) }
            MessageBox(MYUSB.Handle, '�`�N: ���C���|���l�ؿ�, �Цۦ����x�s !', '�|���l�ؿ����x�s !', MB_OK);
            MYUSB.StatBar.Panels[2].Text := '�|��' + IntToStr(fh) + '�Ӥl�ؿ����x�s !';
            ProcMsg('�`�N: ���C���|��' + IntToStr(fh) + '�Ӥl�ؿ����x�s !');
        end
        else MYUSB.StatBar.Panels[2].Text := '�C���w�x�s !';
        ProcMsg('�C���w�x�s');
        // �}�l�ʵe
        fh := FileOpen(pc_fn + '\icon.sys', fmOpenRead);
        if fh > 0 then begin
            ZeroMemory(pTmp, 512);      FileRead(fh, pTmp^, 512);
            FileClose(fh);      s := pc_fn + '\' + StrPas(pTmp + $104); // $144, $184
            ICONS.DisplayIcon(s);               // ��ܥ���ϼx (3D ICON)
            ICONS.MayClose(pTmp + $C0);         // �C���W��
        end;
        FreeMem(pTmp);          DeleteFile(PC_CMD_FILE);    { �R���q���R�O�ɮ� }
        Result := True;         Work_Done;
     end;
end;

function  GetFlags(flags: Integer): string;
var     { �Ǧ^�ɮ׺X���N�q }
   ans: array [0..8] of Char;
begin
     FillChar(ans[0], 8, #32);          ans[8] := #0;
     case flags of
        EQU_PS2DIR:  Result := '<DIR>'; { �O�@��ؿ� }
        EQU_PS2FILE: Result := '     '; { �O�@���ɮ� }
        else Result := Format('$%04X', [flags]);        { ���� !? }
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
begin   { s ���O '/*' }
     len := Length(s);
     { �˰h�� '/' }
     for i := len - 2 downto 1 do begin
        if s[i] = '/' then begin
            Result := Copy(s, 1, i) + '*';
            Exit;
        end;
     end;
     Result := '/*';    { �������� ! }
end;

function  PadStr(s: string; len, mode: Integer): string;
var     { ���r��ɤW�ť� }
   l: Integer;
begin
     l := Length(s);
     if l >= len then begin
        Result := Copy(s, 1, len);      { �Ӫ��h�I�u }
        Exit;
     end;
     { �ӵu�h��e(mode=0) �Ϋ�(mode=1) �ɤW�ť� }
     if mode <> 0 then Result := s + StringOfChar(' ', len - l)
     else Result := StringOfChar(' ', len - l) + s;
end;

procedure Parse_mc_dir(slot: Integer);
var
   ppd: PPS2_DIR;
   pN: PChar;
   i: Integer;
   s: string;
begin   { �ѪR�ؿ���� (MC_DIR[x]) }
     if slot = 0 then MYUSB.ListBox1.Clear
     else MYUSB.ListBox2.Clear;
     ppd := PPS2_DIR(MC_DIR[slot]);     { �ഫ���ɮץؿ����а}�C }
     pN := JpnName[slot];               { �ഫ���C���W�٦r����а}�C }
     if ppd^.fname[0] = '.' then parse_mode := false;   { �l�ؿ����S���C���W�� }
     for i := 0 to MAX_DIR_COUNT do begin
        if ppd^.fname[0] = #0 then Exit;        { �ѪR���� }
        if parse_mode then begin        { �H�C���W���[�I }
            if pN[0] = #0 then s := '--- No game name found ! ---'
            else s := StrPas(pN);
        end
        else begin { �H�ɮץؿ��[�I }
            s := PadStr(StrPas(ppd^.fname), 50, 1) + '  ' + GetFlags(ppd^.flag);
            s := s + Format('   %7d   ', [ppd^.blks]) + GetTimeStr(ppd^.build_time);
        end;
        if slot = 0 then MYUSB.ListBox1.Items.Add(s)
        else MYUSB.ListBox2.Items.Add(s);
        Inc(ppd);       Inc(pN, 64);
     end;
end;

procedure ProcMsg(s: string);
begin   { ��X�B�z�T�� }
     MYUSB.Memo2.Lines.Add(s);
     MYUSB.Form1.BringToFront;
end;

function  PS2_MC_Thread(pr: Pointer): LongInt;  stdcall;
var
   fhnd: Integer;
begin   { ���h�D�n����� }
     pIO := AllocMem(1024);     { �P PS2 ���q�νw�İ� }
     icon_Buf := AllocMem(ICON_BUF_SIZE);       { �ȩ� PS2 �� icon.sys }
     MC_DIR[0] := AllocMem(DIR_BUF_SIZE);       { ���e�[��O�Хd�ؿ����e }
     MC_DIR[1] := AllocMem(DIR_BUF_SIZE);
     JpnName[0] := AllocMem(DIR_BUF_SIZE);      { ����C���W��, 1 �� = 64 bytes }
     JpnName[1] := AllocMem(DIR_BUF_SIZE);
     MC_path[0] := '/*';        MC_path[1] := '/*';     { �w�]Ū���O�Хd�ڥؿ� }
     DeleteFile(PC_CMD_FILE);           { ���� PS2 �~�ʧ@ }
     fhnd := FileCreate(fn_PC_init_OK); { ���{�����}�e, �K�R������ ! }
     if fhnd < 0 then begin     { ���ӥi�� ! }
        MemoWrite('�L�k�إ��ɮ� : ' + fn_PC_init_OK);
        MemoWrite('���������{�� !');
     end;
     FileClose(fhnd);
     fhnd := FileCreate(my_path + DIR_ANS_FILE);        { ���կ�_���� ! }
     if fhnd < 0 then my_path := 'C:\';                 { �Y����h�ϥ� C:\ }
     FileClose(fhnd);           DeleteFile(my_path + fn_PC_init_OK);
     Sleep(500);                // my_path := 'C:\';
     ProcMsg('�I��������u�@�ؿ� = ' + my_path);
     repeat
        case Work_Id of
            NO_JOB:
              begin
                if Next_Work <> NO_JOB then begin
                    Work_Id := Next_Work;       Next_Work := NO_JOB;    end
                else begin
                    MYUSB.StatBar.Panels[2].Text := '';
                    Check_PS2_CMD_File;         { �ˬd�O�_�� C:\PS2_CMD.$$$ �X�{ }
                    Check_DIR_File;             { �ˬd�O�_�� C:\PS2MCDIR.$$$ �X�{ }
                end;
              end;
            GAME_NAME: Check_PS2_GameName;      { �ˬd�C���W�� }
            GET_FILE: Set_GetFile(chk_slot);    { ���o�O�Хd�ɮ� }
            GET_GAME: SetRead_Game(chk_slot);   { �x�s��ӹC���ɮץؿ� }
            RESTORE_FILE: Set_RestoreFile(chk_slot);    { �٭��@�O�Хd�ɮ� }
            RESTORE_GAME: Set_RestoreGame(chk_slot);    { �٭�C���O�Хd�ɮ� }
            SEE_DIR: SetRead_MC(chk_slot);      { �d�ݥؿ����e }
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
begin   { �t�s�s�� }
     if ppd^.blks < 1 then Exit;        { �ɮת��׬O 0 ! }
     MYUSB.SaveDlg1.FileName := StrPas(ppd^.fname);
     if not MYUSB.SaveDlg1.Execute then Exit;
     chk_slot := slot;
     pc_fn := MYUSB.SaveDlg1.FileName;
     s := MC_path[slot];
     mc_fn := Copy(s, 1, Length(s) - 1) + StrPas(ppd^.fname);
     MYUSB.StatBar.Panels[2].Text := '�Y�N���o�O�Хd�ɮ� : ' + mc_fn;
     ProcMsg('�N��' + LR[slot] + '�U���ɮ� : ' + mc_fn);
     ProcMsg(', �s��q���ؿ� ' + pc_fn);
     Arrange_JOB(GET_FILE);     { ���o�O�Хd�ɮ� }
end;

procedure SeeItsName(slot: Integer);
var
   ppd: PPS2_DIR;
   pN: PChar;
   i: Integer;
   s: string;
begin   { �ѪR�ؿ���� (MC_DIR[x]) }
     if slot = 0 then begin
          i := MYUSB.ListBox1.ItemIndex;
          s := MYUSB.ListBox1.Items[i];          end
     else begin
          i := MYUSB.ListBox2.ItemIndex;
          s := MYUSB.ListBox2.Items[i];          end;
     ppd := PPS2_DIR(MC_DIR[slot]);     { �ഫ���ɮץؿ����а}�C }
     if ppd^.fname[0] = '.' then Exit;  { �l�ؿ����S���C���W��,�@�����A�� ! }

     ppd := PPS2_DIR(MC_DIR[slot] + (i * SizeOf(TPS2_DIR)));    { �ഫ���ɮץؿ����а}�C }
     pN := JpnName[slot] + (i shl 6);   { �ഫ���C���W�٦r����а}�C }
     if s[1] > #$7f then begin          { �H�ɮץؿ��[�I }
        if ppd^.fname[0] = #0 then s := ''      { ���B�L�ɮשΥؿ�, �ѪR���� }
        else begin
            s := PadStr(StrPas(ppd^.fname), 50, 1) + '  ' + GetFlags(ppd^.flag);
            s := s + Format('   %7d   ', [ppd^.blks]) + GetTimeStr(ppd^.build_time);
        end;
     end
     else begin { �H�C���W���[�I }
        if pN[0] = #0 then s := '--- No game name found ! ---'
            else s := StrPas(pN);       { = �C���W }
     end;
     if slot = 0 then MYUSB.ListBox1.Items[i] := s
     else MYUSB.ListBox2.Items[i] := s;
end;

procedure SetMemCardDIR;
begin   { �O�O�Хd�sŪ�����ؿ����e }
     Parse_mc_dir(chk_slot);
end;

procedure SetMemCardInfo;
var
   i: Integer;
begin   { ���k�O�Хd�O�_�s�b ? }
     ProcMsg('���R' + LR[0] + '�O�_����');
     MC_exist[0] := false;      MC_free[0] := 0;        { ���]���O�Хd���s�b }
     if pIO[16] = #2 then begin { ���O�Хd�O���Ī��O�Хd }
        MC_exist[0] := True;    i := ReadDW(pIO, 20) - 2;
        if i <> MC_free[0] then MC_changed[0] := True;
        MC_free[0] := i;
     end;

     ProcMsg('���R' + LR[1] + '�O�_����');
     MC_exist[1] := false;      MC_free[1] := 0;        { ���]�k�O�Хd���s�b }
     if pIO[208] = #2 then begin { �k�O�Хd�O���Ī��O�Хd }
        MC_exist[1] := True;    i := ReadDW(pIO, 212) - 2;
        if i <> MC_free[1] then MC_changed[1] := True;
        MC_free[1] := i;
     end;

     Update_Title_info;
     if (MC_changed[0] or MC_changed[1]) then Work_Id := GAME_NAME;   { ����Ū�C���W�� }
end;

procedure SetRead_Game(slot: Integer);
var
   s: string;
   This_done: Boolean;
begin   { �x�s��ӹC���ɮץؿ� }
     if bAbort then Exit;       { user abort ! }
     ZeroMemory(pIO, 1024);
     pIO[0] := 'S';             pIO[1] := Char(slot and 1);     { save Directory ! }
     StrPCopy(pIO + $10, 'host:' + pc_fn);      { �s�񵲪G���q���ɮצW�� }
     StrPCopy(pIO + $110, mc_fn);     { �Q�s�� PS2 �ؿ��W�� }
     if Write_CMD_File < 0 then Exit; { �������t�g�X�ɮ� }
     MYUSB.StatBar.Panels[2].Text := '�ǳ��x�s��ӹC���� ' + pc_fn;
     s := pc_fn + '\' + SAVE_LOG_FILE;
     if FileExists(s) then DeleteFile(s);       { ����ɹw���s�b }
     ProcMsg('�ǳƫO�s' + LR[slot] + '�C����q�� ' + pc_fn);
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
begin   { �]�w���o��e�O�Хd�ڥؿ��Ψ�C���W�� }
     if bAbort then Exit;       { user abort ! }
     DeleteFile(my_path + GAME_NAME_FILE);
     ZeroMemory(pIO, 1024);
     pIO[0] := 'N';             pIO[1] := Char(slot and 1);     { read Game Name ! }
     StrPCopy(pIO + $10, 'host:' + my_path + GAME_NAME_FILE);   { �s�񵲪G���q���ɮצW�� }
     if Write_CMD_File < 0 then Exit;           { �������t�g�X�ɮ� }
     MYUSB.StatBar.Panels[2].Text := '�ǳƨ��o�C���W�� ...';
     ProcMsg('�ǳƨ��o' + LR[slot] + '�C���W��');
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
begin   { �]�w��Ū��e�O�Хd�ؿ� }
     if bAbort then Exit;       { user abort ! }
     ZeroMemory(pIO, 1024);
     pIO[0] := 'D';             pIO[1] := Char(slot and 1);     { read Directory ! }
     s := my_path + DIR_ANS_FILE;     { �n�O�o�[ host: }
     StrPCopy(pIO + $10, 'host:' + s);          { �s�񵲪G���q���ɮצW�� }
     StrPCopy(pIO + $110, MC_path[slot]);       { �Q�ݪ� PS2 �ؿ��W�� }
     if Write_CMD_File < 0 then Exit;           { �������t�g�X�ɮ� }
     ProcMsg('�ǳƨ��o' + LR[slot] + '�ؿ����e ' + MC_path[slot]);
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
begin   { ���o�O�Хd�ɮ� }
     if bAbort then Exit;       { user abort ! }
     ZeroMemory(pIO, 1024);
     pIO[0] := 'C';             pIO[1] := Char(slot and 1);     { copy file to PC ! }
     StrPCopy(pIO + $10, 'host:' + pc_fn);      { �s�񵲪G���q���ɮצW�� }
     StrPCopy(pIO + $110, mc_fn);               { �Q�n�� PS2 �ɮצW�� }
     if Write_CMD_File < 0 then Exit;           { �������t�g�X�ɮ� }
     MYUSB.StatBar.Panels[2].Text := '�ǳƨ��o�ɮ� ' + pc_fn;
     ProcMsg('�ǳƫ���' + LR[slot] + '�ɮ� ' + pc_fn);
     This_done := false;
     repeat
        if Get_CMD_File_Size < 16 then Write_CMD_File;
        if FileExists(pc_fn) then begin         { ���ݦ��ɧ��� }
            DeleteFile(PC_CMD_FILE);            { �R���q���R�O�ɮ� }
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
begin   { �٭��@�O�Хd�ɮ� }
     if bAbort then Exit;       { user abort ! }
     ZeroMemory(pIO, 1024);
     pIO[0] := 'W';             pIO[1] := Char(slot and 1);     { restore one file to PS2 ! }
     StrPCopy(pIO + $10, 'host:' + pc_fn);      { �s��q���ɮצW�� }
     StrPCopy(pIO + $110, mc_fn);               { �Q���C�� PS2 �O�Хd���|, ���ݤ��t '/' }
     if Write_CMD_File < 0 then Exit;           { �������t�g�X�ɮ� }
     MYUSB.StatBar.Panels[2].Text := '�ǳ��٭��@�O�Хd�ɮ� ' + mc_fn;
     ProcMsg('�ǳ��٭�' + LR[slot] + '��@�O�Хd�ɮ� ' + mc_fn);
     This_done := false;
     repeat
        if FileExists(PS2_CMD_FILE) then begin  { ���ݦ��ɲ��� }
            DeleteFile(PC_CMD_FILE);            { �R���q���R�O�ɮ� }
            fh := FileOpen(PS2_CMD_FILE, fmOpenRead);
            if fh > 0 then begin
                if FileSeek(fh, 0, 2) > 0 then begin
                    This_done := True; { �����׫K�O�n�F }
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
begin   { �٭�C���O�Хd�ɮ� }
     if bAbort then Exit;       { user abort ! }
     ZeroMemory(pIO, 1024);
     pIO[0] := 'R';             pIO[1] := Char(slot and 1);     { restore game to PS2 ! }
     StrPCopy(pIO + $10, 'host:' + pc_fn);      { �s��q���ɮ׸��|, ���ݤ��t '\' }
     StrPCopy(pIO + $110, mc_fn);               { �Q���C�� PS2 �O�Хd���|, ���ݤ��t '/' }
     if Write_CMD_File < 0 then Exit;           { �������t�g�X�ɮ� }
     MYUSB.StatBar.Panels[2].Text := '�ǳ��٭�C�� ' + mc_fn;
     ProcMsg('�ǳ��٭�' + LR[slot] + '�C�� ' + mc_fn);
     This_done := false;
     repeat
        if FileExists(PS2_CMD_FILE) then begin  { ���ݦ��ɲ��� }
            DeleteFile(PC_CMD_FILE);            { �R���q���R�O�ɮ� }
            fh := FileOpen(PS2_CMD_FILE, fmOpenRead);
            if fh > 0 then begin
                if FileSeek(fh, 0, 2) > 0 then begin
                    This_done := True; { �����׫K�O�n�F }
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
     s := '�����O�Хd�G';
     if MC_exist[0] then begin
        s := s + IntToStr(MC_free[0]) + KBFREE_NOWDIR;
        s := s + MC_path[0];
        ProcMsg(LR[0] + '�i�ΪŶ� ' + IntToStr(MC_free[0]) + ' Kb');
     end;
     MYUSB.Label1.Caption := s;

     s := '�k���O�Хd�G';
     if MC_exist[1] then begin
        s := s + IntToStr(MC_free[1]) + KBFREE_NOWDIR;
        s := s + MC_path[1];
        ProcMsg(LR[1] + '�i�ΪŶ� ' + IntToStr(MC_free[1]) + ' Kb');
     end;
     MYUSB.Label2.Caption := s;
end;

procedure UseThisItem(slot: Integer);
var
   ppd: PPS2_DIR;
   i: Integer;
   s: string;
begin   { �Y�O�ؿ��h���J, �Y�O�ɮ׫h������q�� }
     if Work_Id <> NO_JOB then begin
        MYUSB.StatBar.Panels[2].Text := PS2_IS_BUSY;
        Exit;
     end;
     if slot = 0 then i := MYUSB.ListBox1.ItemIndex
     else i := MYUSB.ListBox2.ItemIndex;
     ppd := PPS2_DIR(MC_DIR[slot] + (i * SizeOf(TPS2_DIR)));    { �ഫ���ɮץؿ����а}�C }
     if ppd^.fname[0] = #0 then Exit;   { ���B�L�ɮשΥؿ�, �ѪR���� }
     if ppd^.flag <> EQU_PS2DIR then begin
        SaveGameFile(slot, ppd);        { �t�s�s�� }
        Exit;
     end;

     s := MC_path[slot];        chk_slot := slot;
     if s <> '/*' then begin
        if i = 0 then Exit;     { ���O '.' }
        if i = 1 then begin     { ���O '..', �^�W�h�ؿ� }
            s := goBackLevel(s);
            i := 1000;
        end;
     end;
     if i < 999 then s := Copy(s, 1, Length(s) - 1) + StrPas(ppd^.fname) + '/*'; { ���U�h�ؿ� }
     MYUSB.StatBar.Panels[2].Text := '���n���J�ؿ� : ' + s;
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
     fh := FileCreate(PC_CMD_FILE0);            { �������t�g�X�ɮ� }
     Result := fh;
     if fh < 0 then begin
        MYUSB.Memo1.Lines.Add('�L�k���ͩR�O�� ' + PC_CMD_FILE);
        Exit;
     end;
     FileWrite(fh, pIO^, 1024);         FileClose(fh);
     RenameFile(PC_CMD_FILE0, PC_CMD_FILE);     Sleep(30);
     Result := 0;
end;

end.
