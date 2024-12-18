unit SavGmDir;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FileCtrl;

type
{  TPS2_TIME = record
    pad0, sec, min, hour, date, month: BYTE;
    year: WORD;
  end;

  PPS2_DIR = ^TPS2_DIR;
  TPS2_DIR = record
    build_time, last_time: TPS2_TIME;
    blks, flag, pad0, pad1: Integer;
    fname: array [0..31] of Char;
  end;     }

  TSaveGameDir = class(TForm)
    Button1: TButton;
    Button2: TButton;
    DirListBox1: TDirectoryListBox;
    DrvComboBox1: TDriveComboBox;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ComboBox1: TComboBox;
    Button3: TButton;
    OpenDlg1: TOpenDialog;
    procedure Bye(Sender: TObject);
    procedure ChgDir(Sender: TObject);
    procedure ChgDrv(Sender: TObject);
    procedure Prepare(slot, index: Integer);
    procedure ToSaveGame(Sender: TObject);
    procedure RestoreOneFile(Sender: TObject);
  private
    { Private declarations }
  public
    procedure PrepareRestore;
    { Public declarations }
  end;

var
  SaveGD: TSaveGameDir;
  pc_fn2: string;
  mode: Integer;

implementation

uses PC_PS2MC, PS2Icon;
{$R *.DFM}

procedure TSaveGameDir.Bye(Sender: TObject);
begin
     Hide;
end;

procedure TSaveGameDir.ChgDrv(Sender: TObject);
begin
     DirListBox1.Drive := DrvComboBox1.Drive;
end;

procedure TSaveGameDir.ChgDir(Sender: TObject);
var
   dTime: TPS2_TIME;
   i, l: Integer;
   p: PChar;
   s: string;
begin
     if mode = 0 then begin     { 是 PS2 拷到電腦, 將讀取遊戲的記憶卡目錄是已固定的 }
        s := DirListBox1.Directory;
        l := Length(s);
        if s[l] = '\' then s := Copy(s, 1, l - 1);         // 去除尾端的 '\'
        Edit1.Text := s + '\' + pc_fn2;
        Exit;
     end;
     { 是電腦拷到 PS2, 倒退取出尾層目錄名稱, 放到 Edit1.Text }
     pc_fn2 := DirListBox1.Directory;           ICONS.Bye;
     l := Length(pc_fn2);       // 尾字通常不是 '\', 除非是 'X:\'
     Edit1.Text := '/';         mc_fn := '/';   { 先假設沒有字 }
     for i := l downto 1 do begin
        if pc_fn2[i] = '\' then begin
           if i = l - 1 then Exit;
           Edit1.Text := '/' + Copy(pc_fn2, i + 1, l - i);  { 拷貝中間數個字 }
           mc_fn := Edit1.Text;         Break;  { 好了 }
        end;
     end;
     Label4.Caption := '�V�Y�����F';    // = '遊戲名稱：'
     if pc_fn2[l] = '\' then pc_fn2[l] := #0;
     if FileExists(pc_fn2 + '\icon.sys') then begin
        i := FileOpen(pc_fn2 + '\icon.sys', fmOpenRead);
        if i > 0 then begin
            p := AllocMem(128);
            FileSeek(i, 192, 0);        FileRead(i, p^, 64);
            Label4.Caption := Label4.Caption + StrPas(p);   { 取得日文遊戲名稱 }
            FileSeek(i, $104, 0);       FileRead(i, p^, 64);    { $144, $184 }
            FileClose(i);               s := pc_fn2 + '\' + StrPas(p);
            ICONS.Show;
            ICONS.DisplayIcon(s);       // 顯示立體圖徵 (3D ICON)
            FreeMem(p);
        end;
     end;
     if FileExists(pc_fn2 + '\DIR_LOG.PS2') then begin
        i := FileOpen(pc_fn2 + '\DIR_LOG.PS2', fmOpenRead);
        if i > 0 then begin     { 取得遊戲建立時間 }
            FileRead(i, dTime, 8);      FileClose(i);
            Label4.Caption := Label4.Caption + '  ' + GetTimeStr(dTime);
        end;
     end;
end;

procedure TSaveGameDir.Prepare(slot, index: Integer);
var
   ppd: PPS2_DIR;
   s: string;
begin
     Show;      mode := 0;      Caption := '保存遊戲記錄';
     Label1.Caption := '請選擇所要存放遊戲的目錄：';
     Label2.Caption := '請選擇所要存放遊戲的磁碟機：';
     Label3.Caption := '即將新建的電腦目錄：';
     Label5.Hide;       ComboBox1.Hide;
     DirListBox1.Height := 289;         DirListBox1.Top := 152;
     DirListBox1.Update;                Label4.Caption := '';
     ppd := PPS2_DIR(MC_DIR[slot] + (index * SizeOf(TPS2_DIR)));
     pc_fn2 := StrPas(ppd^.fname);      chk_slot := slot;
     s := MC_path[slot];        { s = '/現在目錄/*' }
     mc_fn := Copy(s, 1, Length(s) - 1) + pc_fn2;       { = 將讀取遊戲的記憶卡目錄 }
     ChgDir(nil);
end;

procedure TSaveGameDir.PrepareRestore;
begin
     Show;      mode := 1;      Caption := '回復遊戲資料至記憶卡';
     Label1.Caption := '請選擇原本存放遊戲的目錄：（除了子目錄外, 所有檔案將被拷貝！）';
     Label2.Caption := '請選擇原本存放遊戲的磁碟機：';
     Label3.Caption := '即將回復的遊戲目錄名稱：（通常不必修改, 以免遊戲不認得！）';
     Label5.Show;       ComboBox1.Show;         ComboBox1.ItemIndex := 0;
     { 倒退取出尾層目錄名稱, 放到 Edit1.Text }
     DirListBox1.Height := 273;         DirListBox1.Top := 168;
     DirListBox1.Update;
     ChgDir(nil);
end;

procedure TSaveGameDir.ToSaveGame(Sender: TObject);
begin
     if mode = 0 then begin
        pc_fn := Edit1.Text;            { = 將存放遊戲的電腦目錄 }
        if not DirectoryExists(pc_fn) then ForceDirectories(pc_fn); { 先建目錄 }
        Arrange_JOB(GET_GAME);          { 取得記憶卡檔案 }
        Hide;           Exit;
     end;
     { 回復的遊戲到記憶卡 }
     pc_fn := DirListBox1.Directory;    { 遊戲檔案來源, 尾端不含 '\' }
     mc_fn := Edit1.Text;               { 記憶卡儲存目標路徑, 尾端不含 '/' }
     chk_slot := ComboBox1.ItemIndex;   { 0: 左記憶卡, 1: 右記憶卡 }
     Arrange_JOB(RESTORE_GAME);         { 還原記憶卡檔案 }
     Hide;
end;

procedure TSaveGameDir.RestoreOneFile(Sender: TObject);
var
   ppd: PPS2_DIR;
   pT: PChar;
   fh, i: Integer;
   s: string;
begin   { 回復遊戲單一的檔案到記憶卡 }
     OpenDlg1.InitialDir := DirListBox1.Directory;      { 尾端不含 '\' }
     if OpenDlg1.Execute then begin
        pc_fn := OpenDlg1.FileName;             { 單一的檔案來源 }
        s := ExtractFileName(pc_fn);
        { 開啟同目錄的 SAVE_LOG_FILE (DIR_LOG.PS2), 取得其真正大小寫檔名 !! }
        fh := FileOpen(ExtractFilePath(pc_fn) + SAVE_LOG_FILE, fmOpenRead);
        if fh < 1 then mc_fn := Edit1.Text + '/' + s    { 找不到 dir_log.ps2, 暫不管大小寫, 記憶卡儲存目標檔名 }
        else begin
            pT := AllocMem(DIR_BUF_SIZE);       ppd := PPS2_DIR(pT);
            FileRead(fh, pT^, DIR_BUF_SIZE);    FileClose(fh);
            for i := 0 to (DIR_BUF_SIZE shr 6) do begin
                if ppd^.fname[0] = #0 then Break;       { 已無檔案 }
                if ppd^.flag = EQU_PS2FILE then begin
                    if AnsiCompareText(s, StrPas(ppd^.fname)) = 0 then begin { 不分大小寫 }
                        mc_fn := Edit1.Text + '/' + StrPas(ppd^.fname); { 此為真名 ! }
                        Break;  { 找到了便脫離 }
                    end;
                end;
                Inc(ppd);
            end;
            FreeMem(pT);
        end;
        chk_slot := ComboBox1.ItemIndex;        { 0: 左記憶卡, 1: 右記憶卡 }
        Arrange_JOB(RESTORE_FILE);              { 還原記憶卡單一的檔案 }
        Hide;
     end;
end;

end.
