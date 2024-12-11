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
     if mode = 0 then begin     { �O PS2 ����q��, �NŪ���C�����O�Хd�ؿ��O�w�T�w�� }
        s := DirListBox1.Directory;
        l := Length(s);
        if s[l] = '\' then s := Copy(s, 1, l - 1);         // �h�����ݪ� '\'
        Edit1.Text := s + '\' + pc_fn2;
        Exit;
     end;
     { �O�q������ PS2, �˰h���X���h�ؿ��W��, ��� Edit1.Text }
     pc_fn2 := DirListBox1.Directory;           ICONS.Bye;
     l := Length(pc_fn2);       // ���r�q�`���O '\', ���D�O 'X:\'
     Edit1.Text := '/';         mc_fn := '/';   { �����]�S���r }
     for i := l downto 1 do begin
        if pc_fn2[i] = '\' then begin
           if i = l - 1 then Exit;
           Edit1.Text := '/' + Copy(pc_fn2, i + 1, l - i);  { ���������ƭӦr }
           mc_fn := Edit1.Text;         Break;  { �n�F }
        end;
     end;
     Label4.Caption := '�V�Y���́F';    // = '�C���W�١G'
     if pc_fn2[l] = '\' then pc_fn2[l] := #0;
     if FileExists(pc_fn2 + '\icon.sys') then begin
        i := FileOpen(pc_fn2 + '\icon.sys', fmOpenRead);
        if i > 0 then begin
            p := AllocMem(128);
            FileSeek(i, 192, 0);        FileRead(i, p^, 64);
            Label4.Caption := Label4.Caption + StrPas(p);   { ���o���C���W�� }
            FileSeek(i, $104, 0);       FileRead(i, p^, 64);    { $144, $184 }
            FileClose(i);               s := pc_fn2 + '\' + StrPas(p);
            ICONS.Show;
            ICONS.DisplayIcon(s);       // ��ܥ���ϼx (3D ICON)
            FreeMem(p);
        end;
     end;
     if FileExists(pc_fn2 + '\DIR_LOG.PS2') then begin
        i := FileOpen(pc_fn2 + '\DIR_LOG.PS2', fmOpenRead);
        if i > 0 then begin     { ���o�C���إ߮ɶ� }
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
     Show;      mode := 0;      Caption := '�O�s�C���O��';
     Label1.Caption := '�п�ܩҭn�s��C�����ؿ��G';
     Label2.Caption := '�п�ܩҭn�s��C�����Ϻо��G';
     Label3.Caption := '�Y�N�s�ت��q���ؿ��G';
     Label5.Hide;       ComboBox1.Hide;
     DirListBox1.Height := 289;         DirListBox1.Top := 152;
     DirListBox1.Update;                Label4.Caption := '';
     ppd := PPS2_DIR(MC_DIR[slot] + (index * SizeOf(TPS2_DIR)));
     pc_fn2 := StrPas(ppd^.fname);      chk_slot := slot;
     s := MC_path[slot];        { s = '/�{�b�ؿ�/*' }
     mc_fn := Copy(s, 1, Length(s) - 1) + pc_fn2;       { = �NŪ���C�����O�Хd�ؿ� }
     ChgDir(nil);
end;

procedure TSaveGameDir.PrepareRestore;
begin
     Show;      mode := 1;      Caption := '�^�_�C����ƦܰO�Хd';
     Label1.Caption := '�п�ܭ쥻�s��C�����ؿ��G�]���F�l�ؿ��~, �Ҧ��ɮױN�Q�����I�^';
     Label2.Caption := '�п�ܭ쥻�s��C�����Ϻо��G';
     Label3.Caption := '�Y�N�^�_���C���ؿ��W�١G�]�q�`�����ק�, �H�K�C�����{�o�I�^';
     Label5.Show;       ComboBox1.Show;         ComboBox1.ItemIndex := 0;
     { �˰h���X���h�ؿ��W��, ��� Edit1.Text }
     DirListBox1.Height := 273;         DirListBox1.Top := 168;
     DirListBox1.Update;
     ChgDir(nil);
end;

procedure TSaveGameDir.ToSaveGame(Sender: TObject);
begin
     if mode = 0 then begin
        pc_fn := Edit1.Text;            { = �N�s��C�����q���ؿ� }
        if not DirectoryExists(pc_fn) then ForceDirectories(pc_fn); { ���إؿ� }
        Arrange_JOB(GET_GAME);          { ���o�O�Хd�ɮ� }
        Hide;           Exit;
     end;
     { �^�_���C����O�Хd }
     pc_fn := DirListBox1.Directory;    { �C���ɮרӷ�, ���ݤ��t '\' }
     mc_fn := Edit1.Text;               { �O�Хd�x�s�ؼи��|, ���ݤ��t '/' }
     chk_slot := ComboBox1.ItemIndex;   { 0: ���O�Хd, 1: �k�O�Хd }
     Arrange_JOB(RESTORE_GAME);         { �٭�O�Хd�ɮ� }
     Hide;
end;

procedure TSaveGameDir.RestoreOneFile(Sender: TObject);
var
   ppd: PPS2_DIR;
   pT: PChar;
   fh, i: Integer;
   s: string;
begin   { �^�_�C����@���ɮר�O�Хd }
     OpenDlg1.InitialDir := DirListBox1.Directory;      { ���ݤ��t '\' }
     if OpenDlg1.Execute then begin
        pc_fn := OpenDlg1.FileName;             { ��@���ɮרӷ� }
        s := ExtractFileName(pc_fn);
        { �}�ҦP�ؿ��� SAVE_LOG_FILE (DIR_LOG.PS2), ���o��u���j�p�g�ɦW !! }
        fh := FileOpen(ExtractFilePath(pc_fn) + SAVE_LOG_FILE, fmOpenRead);
        if fh < 1 then mc_fn := Edit1.Text + '/' + s    { �䤣�� dir_log.ps2, �Ȥ��ޤj�p�g, �O�Хd�x�s�ؼ��ɦW }
        else begin
            pT := AllocMem(DIR_BUF_SIZE);       ppd := PPS2_DIR(pT);
            FileRead(fh, pT^, DIR_BUF_SIZE);    FileClose(fh);
            for i := 0 to (DIR_BUF_SIZE shr 6) do begin
                if ppd^.fname[0] = #0 then Break;       { �w�L�ɮ� }
                if ppd^.flag = EQU_PS2FILE then begin
                    if AnsiCompareText(s, StrPas(ppd^.fname)) = 0 then begin { �����j�p�g }
                        mc_fn := Edit1.Text + '/' + StrPas(ppd^.fname); { �����u�W ! }
                        Break;  { ���F�K���� }
                    end;
                end;
                Inc(ppd);
            end;
            FreeMem(pT);
        end;
        chk_slot := ComboBox1.ItemIndex;        { 0: ���O�Хd, 1: �k�O�Хd }
        Arrange_JOB(RESTORE_FILE);              { �٭�O�Хd��@���ɮ� }
        Hide;
     end;
end;

end.
