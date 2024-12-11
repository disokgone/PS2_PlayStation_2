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
     if mode = 0 then begin     { ¬O PS2 «þ¨ì¹q¸£, ±NÅª¨ú¹CÀ¸ªº°O¾Ð¥d¥Ø¿ý¬O¤w©T©wªº }
        s := DirListBox1.Directory;
        l := Length(s);
        if s[l] = '\' then s := Copy(s, 1, l - 1);         // ¥h°£§ÀºÝªº '\'
        Edit1.Text := s + '\' + pc_fn2;
        Exit;
     end;
     { ¬O¹q¸£«þ¨ì PS2, ­Ë°h¨ú¥X§À¼h¥Ø¿ý¦WºÙ, ©ñ¨ì Edit1.Text }
     pc_fn2 := DirListBox1.Directory;           ICONS.Bye;
     l := Length(pc_fn2);       // §À¦r³q±`¤£¬O '\', °£«D¬O 'X:\'
     Edit1.Text := '/';         mc_fn := '/';   { ¥ý°²³]¨S¦³¦r }
     for i := l downto 1 do begin
        if pc_fn2[i] = '\' then begin
           if i = l - 1 then Exit;
           Edit1.Text := '/' + Copy(pc_fn2, i + 1, l - i);  { «þ¨©¤¤¶¡¼Æ­Ó¦r }
           mc_fn := Edit1.Text;         Break;  { ¦n¤F }
        end;
     end;
     Label4.Caption := '—V‹Y–¼ÌF';    // = '¹CÀ¸¦WºÙ¡G'
     if pc_fn2[l] = '\' then pc_fn2[l] := #0;
     if FileExists(pc_fn2 + '\icon.sys') then begin
        i := FileOpen(pc_fn2 + '\icon.sys', fmOpenRead);
        if i > 0 then begin
            p := AllocMem(128);
            FileSeek(i, 192, 0);        FileRead(i, p^, 64);
            Label4.Caption := Label4.Caption + StrPas(p);   { ¨ú±o¤é¤å¹CÀ¸¦WºÙ }
            FileSeek(i, $104, 0);       FileRead(i, p^, 64);    { $144, $184 }
            FileClose(i);               s := pc_fn2 + '\' + StrPas(p);
            ICONS.Show;
            ICONS.DisplayIcon(s);       // Åã¥Ü¥ßÅé¹Ï¼x (3D ICON)
            FreeMem(p);
        end;
     end;
     if FileExists(pc_fn2 + '\DIR_LOG.PS2') then begin
        i := FileOpen(pc_fn2 + '\DIR_LOG.PS2', fmOpenRead);
        if i > 0 then begin     { ¨ú±o¹CÀ¸«Ø¥ß®É¶¡ }
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
     Show;      mode := 0;      Caption := '«O¦s¹CÀ¸°O¿ý';
     Label1.Caption := '½Ð¿ï¾Ü©Ò­n¦s©ñ¹CÀ¸ªº¥Ø¿ý¡G';
     Label2.Caption := '½Ð¿ï¾Ü©Ò­n¦s©ñ¹CÀ¸ªººÏºÐ¾÷¡G';
     Label3.Caption := '§Y±N·s«Øªº¹q¸£¥Ø¿ý¡G';
     Label5.Hide;       ComboBox1.Hide;
     DirListBox1.Height := 289;         DirListBox1.Top := 152;
     DirListBox1.Update;                Label4.Caption := '';
     ppd := PPS2_DIR(MC_DIR[slot] + (index * SizeOf(TPS2_DIR)));
     pc_fn2 := StrPas(ppd^.fname);      chk_slot := slot;
     s := MC_path[slot];        { s = '/²{¦b¥Ø¿ý/*' }
     mc_fn := Copy(s, 1, Length(s) - 1) + pc_fn2;       { = ±NÅª¨ú¹CÀ¸ªº°O¾Ð¥d¥Ø¿ý }
     ChgDir(nil);
end;

procedure TSaveGameDir.PrepareRestore;
begin
     Show;      mode := 1;      Caption := '¦^´_¹CÀ¸¸ê®Æ¦Ü°O¾Ð¥d';
     Label1.Caption := '½Ð¿ï¾Ü­ì¥»¦s©ñ¹CÀ¸ªº¥Ø¿ý¡G¡]°£¤F¤l¥Ø¿ý¥~, ©Ò¦³ÀÉ®×±N³Q«þ¨©¡I¡^';
     Label2.Caption := '½Ð¿ï¾Ü­ì¥»¦s©ñ¹CÀ¸ªººÏºÐ¾÷¡G';
     Label3.Caption := '§Y±N¦^´_ªº¹CÀ¸¥Ø¿ý¦WºÙ¡G¡]³q±`¤£¥²­×§ï, ¥H§K¹CÀ¸¤£»{±o¡I¡^';
     Label5.Show;       ComboBox1.Show;         ComboBox1.ItemIndex := 0;
     { ­Ë°h¨ú¥X§À¼h¥Ø¿ý¦WºÙ, ©ñ¨ì Edit1.Text }
     DirListBox1.Height := 273;         DirListBox1.Top := 168;
     DirListBox1.Update;
     ChgDir(nil);
end;

procedure TSaveGameDir.ToSaveGame(Sender: TObject);
begin
     if mode = 0 then begin
        pc_fn := Edit1.Text;            { = ±N¦s©ñ¹CÀ¸ªº¹q¸£¥Ø¿ý }
        if not DirectoryExists(pc_fn) then ForceDirectories(pc_fn); { ¥ý«Ø¥Ø¿ý }
        Arrange_JOB(GET_GAME);          { ¨ú±o°O¾Ð¥dÀÉ®× }
        Hide;           Exit;
     end;
     { ¦^´_ªº¹CÀ¸¨ì°O¾Ð¥d }
     pc_fn := DirListBox1.Directory;    { ¹CÀ¸ÀÉ®×¨Ó·½, §ÀºÝ¤£§t '\' }
     mc_fn := Edit1.Text;               { °O¾Ð¥dÀx¦s¥Ø¼Ð¸ô®|, §ÀºÝ¤£§t '/' }
     chk_slot := ComboBox1.ItemIndex;   { 0: ¥ª°O¾Ð¥d, 1: ¥k°O¾Ð¥d }
     Arrange_JOB(RESTORE_GAME);         { ÁÙ­ì°O¾Ð¥dÀÉ®× }
     Hide;
end;

procedure TSaveGameDir.RestoreOneFile(Sender: TObject);
var
   ppd: PPS2_DIR;
   pT: PChar;
   fh, i: Integer;
   s: string;
begin   { ¦^´_¹CÀ¸³æ¤@ªºÀÉ®×¨ì°O¾Ð¥d }
     OpenDlg1.InitialDir := DirListBox1.Directory;      { §ÀºÝ¤£§t '\' }
     if OpenDlg1.Execute then begin
        pc_fn := OpenDlg1.FileName;             { ³æ¤@ªºÀÉ®×¨Ó·½ }
        s := ExtractFileName(pc_fn);
        { ¶}±Ò¦P¥Ø¿ýªº SAVE_LOG_FILE (DIR_LOG.PS2), ¨ú±o¨ä¯u¥¿¤j¤p¼gÀÉ¦W !! }
        fh := FileOpen(ExtractFilePath(pc_fn) + SAVE_LOG_FILE, fmOpenRead);
        if fh < 1 then mc_fn := Edit1.Text + '/' + s    { §ä¤£¨ì dir_log.ps2, ¼È¤£ºÞ¤j¤p¼g, °O¾Ð¥dÀx¦s¥Ø¼ÐÀÉ¦W }
        else begin
            pT := AllocMem(DIR_BUF_SIZE);       ppd := PPS2_DIR(pT);
            FileRead(fh, pT^, DIR_BUF_SIZE);    FileClose(fh);
            for i := 0 to (DIR_BUF_SIZE shr 6) do begin
                if ppd^.fname[0] = #0 then Break;       { ¤wµLÀÉ®× }
                if ppd^.flag = EQU_PS2FILE then begin
                    if AnsiCompareText(s, StrPas(ppd^.fname)) = 0 then begin { ¤£¤À¤j¤p¼g }
                        mc_fn := Edit1.Text + '/' + StrPas(ppd^.fname); { ¦¹¬°¯u¦W ! }
                        Break;  { §ä¨ì¤F«K²æÂ÷ }
                    end;
                end;
                Inc(ppd);
            end;
            FreeMem(pT);
        end;
        chk_slot := ComboBox1.ItemIndex;        { 0: ¥ª°O¾Ð¥d, 1: ¥k°O¾Ð¥d }
        Arrange_JOB(RESTORE_FILE);              { ÁÙ­ì°O¾Ð¥d³æ¤@ªºÀÉ®× }
        Hide;
     end;
end;

end.
