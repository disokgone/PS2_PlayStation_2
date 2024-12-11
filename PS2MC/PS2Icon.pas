unit PS2Icon;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OpenGL, Math;

type
  PRGBA = ^TRGBA;
  TRGBA = record
    r, g, b, a: Byte;
  end;

  TXYZ = record
    x, y, z, a: Smallint;       { 都須除以 4096 }
  end;

  TUV = record
    u, v: Smallint;             { [(0/4096) .. (4095/4096)] in texture }
  end;

  PXYZ_0F = ^TXYZ_0F;
  TXYZ_0F = record              { 一組 24 bytes }
    p, n: TXYZ;                 { 如果有 c 組動畫系列, 則應改為 p[c], n: TXYZ }
    uv: TUV;                    { = 4 bytes }
    color: TColor;              { = 4 bytes }
  end;

  TICONS = class(TForm)
    procedure doResize(Sender: TObject);
    procedure DisplayIcon(fn: string);
    procedure showAgain(Sender: TObject);
    procedure doKeys(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    procedure SayLocation;
    procedure AtInit;
    procedure DrawScene;
    procedure GLInit;
    procedure MoveSideways(dist: Single);
    procedure MoveUpDown(dist: Single);
    procedure PrepareTexture;
    procedure SeeFrame(val: Integer);
    procedure Show_PS2_icon;
    procedure RotateXY(delta: Single);
    procedure RotateY(delta: Single);
    procedure RotateYZ(delta: Single);
    procedure ZoomIn(dist: Single);
  public
    procedure Bye;
    procedure Stop_Show;
    procedure MayClose(p: PChar);
  end;

  function  LoopAround(pr: Pointer): LongInt;  stdcall;

  procedure glBindTexture (target: GLenum; texture: GLuint); stdcall;
  procedure glGenTextures (n: GLsizei; textures: PGLuint); stdcall;
  procedure glBindTexture; external opengl32;
  procedure glGenTextures; external opengl32;

const
  NDOT = 2000;
  LOOP_COUNT = 50;
  ambience: array [0..3] of Single = (0.55, 0.55, 0.55, 1.0);
  lightpos: array [0..3] of Single = (3.0, 3.0, 3.0, 1.0);
  clr: array [0..3] of Single = (0.7, 0, 0.3, 1);       // R,G,B,ALPHA

var
  ICONS: TICONS;
  lpThrID: LongWord;
  hDC, hThr: HWND;
  hRC: HGLRC;
  pfd: PIXELFORMATDESCRIPTOR;
  TexUV: array [0..NDOT, 0..1] of GLfloat;
  Vertes: array [0..NDOT, 0..2] of GLfloat;
  CX, CY, CZ, VX, VY, VZ: Single;
  pT: PChar;            { 放整個動畫檔 }
  maxDots: Integer = 0;
  nTriangle: Integer = 0;
  frames: Integer;
  fsize: Integer;       { 檔案大小 }
  select_frame: Integer = 0;
  mainTexture: GLuint;
  bInit: Boolean = false;
  keep_show: Boolean = false;

implementation
uses MY_USB1;
{$R *.DFM}

procedure TICONS.Bye;
begin
     keep_show := False;
end;

procedure TICONS.DisplayIcon(fn: string);
var
   fh, len: Integer;
begin
     keep_show := False;
     fh := FileOpen(fn, fmOpenRead);            FreeMem(pT);    pT := nil;
     if fh > 5 then begin
        fsize := FileSeek(fh, 0, 2);            FileSeek(fh, 0, 0);
        len := ((fsize + 31) shr 4) shl 4;
        pT := AllocMem(len);    // 夠用即可
        FileRead(fh, pT^, fsize);               FileClose(fh);
        select_frame := 0;                      mainTexture := 0;
        SeeFrame(0);    { 把想看的某一圖面的三角形資料釋出 }
        PrepareTexture; { 把檔案尾端 32Kb 的 16-bit 128 x 128 texture 轉換成 RGBA }
        BringToFront;           DrawScene;
        if hThr = 0 then
            hThr := CreateThread(nil, 0, @LoopAround, nil, 0, lpThrID);
     end;
end;

procedure TICONS.PrepareTexture;
var
   rgba_image: PRGBA;
   pI: PRGBA;
   pS: PSmallint;
   i: Integer;
begin
     // 把檔案尾端 32Kb 的 16-bit 128 x 128 texture 轉換成 RGBA
     pI := PRGBA(AllocMem(65536));      { = 128 * 128 * 4 bytes }
     rgba_image := pI;          pS := Pointer(pT + fsize - 32768);    { 圖案來源 }
     for i := 1 to 16384 do begin       { 16384 = 128 * 128 }
        pI^.r := (pS^ and $1F) shl 3;   { 紅 : low 5 bits }
        pI^.g := (pS^ and $3E0) shr 2;  { 綠 : mid 5 bits }
        pI^.b := (pS^ and $7C00) shr 7; { 藍 : high 5 bits }
//        pI^.a := (pS^ and $8000) shr 8; { 透明度 : highest 1 bit, ? 貼圖會失敗 !! }
        pI^.a := 255;
        Inc(pI);        Inc(pS);
     end;
     // 設定到 OpenGL 圖案系統中
     glEnable(GL_TEXTURE_2D);
     glGenTextures(1, @mainTexture);    { 保留一個的圖案物件給我們用 }
     glBindTexture(GL_TEXTURE_2D, mainTexture); { 準備建立我們的圖案物件 }
     glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);  // 此行不需要
     glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);  // 此行不需要
     // 以下指定: level = 0 (不使用 mipmaps); 4 = R/G/B/A 四種顏色成分; 128x128 點; 邊框寬度為 0
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);  // 此行很重要, 勿改
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);  // 此行很重要, 勿改
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);     // 此行不需要
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);     // 此行不需要
     glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);  { 直接貼圖, 很重要, 勿改 }
     glTexImage2D(GL_TEXTURE_2D, 0, 4, 128, 128, 0, GL_RGBA, GL_UNSIGNED_BYTE, rgba_image);
     FreeMem(rgba_image);       { 再也用不到了 }
end;

procedure TICONS.SeeFrame(val: Integer);
var
   c: TXYZ_0F;
   p: TXYZ;
   v: GLfloat;
   i, j, ofs, ofsuv, sets, sizes: Integer;
begin
     frames := Byte(pT[4]);          sizes := (frames shl 3) + 16;
     Inc(select_frame, val);
     if select_frame < 0 then select_frame := frames - 1;
     if select_frame >= frames then select_frame := 0;
     ofs := 20 + (select_frame * sizeof(TXYZ));
     ofsuv := 20 + sizes - 8;
     sets := Byte(pT[16]) + (Byte(pT[17]) shl 8);           maxDots := sets - 1;
     nTriangle := sets div 3;           i := 4096;
     Caption := IntToStr(frames) + ' 組動畫系列, ' + IntToStr(sets) + ' 組點資料, ' +
            IntToStr(nTriangle) + ' 個三角形, tpag = '  + IntToStr(Byte(pT[8]));
     Caption := Caption + ' (正在看第' + IntToStr(select_frame) + '組動畫系列)';
     for j := 0 to sets do begin
        if (frames = 1) then begin { 只有一組動畫系列, 不必挑嘴 ! }
            Move(pT[20 + (j * sizeof(TXYZ_0F))], c, sizeof(TXYZ_0F));
            Vertes[j][0] := c.p.x / i;
            Vertes[j][1] := c.p.y / i;
            Vertes[j][2] := c.p.z / i;
            { 已取得一點, 連續三點畫一個三角形 }
        end
        else begin  { 有多組動畫系列 }
            Move(pT[ofs + (j * sizes)], p, sizeof(TXYZ));
            Vertes[j][0] := p.x / i;
            Vertes[j][1] := p.y / i;
            Vertes[j][2] := p.z / i;
            { 已取得一點, 連續三點畫一個三角形 }
        end;
        { 取得其圖案座標資料 }
        Move(pT[ofsuv], c.uv, 8);               { 直接由尾端取 8 bytes }
        TexUV[j][0] := c.uv.u / i;              { 圖案的寬與高是 128 點 }
        TexUV[j][1] := c.uv.v / i;
        Inc(ofsuv, sizes);
     end;
     for j := 0 to maxDots do   { 放大圖形 }
        for i := 0 to 2 do begin
            v := Vertes[j][i];     v := v * 6;
            Vertes[j][i] := v;
        end;
end;

procedure TICONS.AtInit;
var
   pf: Integer;
begin
  hDC := GetDC(Handle);
  ZeroMemory(@pfd, sizeof(pfd));
  pfd.nSize        := sizeof(pfd);
  pfd.nVersion     := 1;
  pfd.dwFlags      := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
  pfd.iPixelType   := PFD_TYPE_RGBA;
  pfd.cColorBits   := 32;

  pf := ChoosePixelFormat(hDC, @pfd);
  if pf = 0 then begin
        MessageBox(Handle, 'ChoosePixelFormat() failed: Cannot find a suitable pixel format.', 'Error', MB_OK);
        Exit;
  end;
  if SetPixelFormat(hDC, pf, @pfd) = FALSE then begin
  	MessageBox(Handle, 'SetPixelFormat() failed: Cannot set format specified.', 'Error', MB_OK);
        Exit;
  end;
  DescribePixelFormat(hDC, pf, sizeof(PIXELFORMATDESCRIPTOR), pfd);

  hRC := wglCreateContext(hDC);
  wglMakeCurrent(hDC, hRC);
  ReleaseDC(hDC, Handle);

  GLInit;
end;

procedure TICONS.Show_PS2_icon;
var
   i, j: Integer;
begin
     if pT = nil then Exit;
     if mainTexture = 0 then PrepareTexture;
     glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, @clr[0]);
     glPolygonMode(GL_FRONT, GL_FILL);  // GL_FRONT_AND_BACK
     glEnable(GL_TEXTURE_2D);           // 允許使用貼圖
     glBindTexture(GL_TEXTURE_2D, mainTexture); // 來源: 貼我們的圖 mainTexture
     glBegin(GL_TRIANGLES);
     glEdgeFlag(false);
     for j := 0 to nTriangle - 1 do begin
        for i := 0 to 2 do begin
            glTexCoord2fv(@TexUV[i + (j * 3)][0]);      // j x 3 三角形
            glVertex3fv( @Vertes[i + (j * 3)][0]);      // j x 3 三角形
        end;
     end;
     glEnd();
end;
procedure TICONS.DrawScene;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glLoadIdentity;
  gluLookAt(CX,CY,CZ,  VX, VY, VZ,  0,-1,0);   // eye-XYZ, scene-Center-XYZ, up-XYZ

  glPushMatrix;
//  glTranslatef(VX, VY, VZ);
  Show_PS2_icon;
  glPopMatrix;

  glFinish;
  SwapBuffers(wglGetCurrentDC);
//  SayLocation;
end;

procedure TICONS.GLInit;
begin
  //LIGHTING
  glMaterialf(GL_FRONT, GL_SHININESS, 75.0);
  glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @ambience[0]);
  glLightfv(GL_LIGHT0, GL_POSITION, @lightpos[0]);
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);

  //DRAWING
  glClearColor(0.0, 0.0, 0.3, 1.0);
  glClearDepth(100.0);
  glDepthFunc(GL_LESS);
  glEnable(GL_DEPTH_TEST);
  glCullFace(GL_BACK);
  glEnable(GL_CULL_FACE);
  glShadeModel(GL_SMOOTH);

  //INIT VARS
  CX := 0.0;
  CY := 0.0;
  CZ := -90.0;
  VX := 0;
  VY := -16;
  VZ := 1;

  bInit := True;
end;

procedure TICONS.doResize(Sender: TObject);
begin
     if not bInit then AtInit;
     glMatrixMode(GL_PROJECTION);
     glLoadIdentity;
     gluPerspective(20.0, ClientWidth/ClientHeight, 0.1, 400.0);
     glMatrixMode(GL_MODELVIEW);
     glViewport(0, 0, ClientWidth, ClientHeight);
end;

procedure TICONS.MayClose(p: PChar);
var
   i : Integer;
begin
     Show;      Sleep(30);
     i := MessageBox(Handle, '可以關閉遊戲動畫了', p, MB_OK);
     if i = IDOK then keep_show := False;
end;

procedure TICONS.MoveSideways(dist: Single);
var
   xd, yd, d, t, xnd, ynd: Single;
begin
     xd := VX - CX;
     yd := VY - CY;
     d := Sqrt((xd*xd)+(yd*yd));
     if d = 0.0 then t := 0.0
     else t := ArcCos(xd / d);
     if yd < 0.0 then t := (2.0 * PI) - t;

     xnd := (cos(t - (0.5*PI)) * dist);
     ynd := (sin(t - (0.5*PI)) * dist);

     CX := CX + xnd;
     CY := CY + ynd;
     VX := VX + xnd;
     VX := VX + ynd;
end;

procedure TICONS.MoveUpDown(dist: Single);
var
   xd, yd, d, t, xnd, ynd: Single;
begin
     xd := VX - CX;
     yd := VY - CY;
     d := Sqrt((xd*xd)+(yd*yd));
     if d = 0.0 then t := 0.0
     else t := ArcCos(xd / d);

     if yd < 0.0 then t := (2.0 * PI) - t;

     xnd := (cos(t) * dist);
     ynd := (sin(t) * dist);

     CX := CX + xnd;
     CY := CY + ynd;
     VX := VX + xnd;
     VX := VX + ynd;
end;

procedure TICONS.RotateXY(delta: Single);
var
   xd, yd, r, theta, xnd, ynd: Single;
begin
     xd := VX - CX;
     yd := VY - CY;
     r := Sqrt((xd*xd)+(yd*yd));        { XY 平面投影的直徑 }

     if r = 0.0 then theta := 0.0
     else theta := ArcCos(xd / r);      { 計算原本的夾角 }
     if yd < 0.0 then theta := (2.0 * PI) - theta;      { 得到圓周弧度值 }

     theta := theta + delta;            { 逆時針轉 deltaDeg 弧度 }
     xnd := Cos(theta) * r;
     ynd := Sin(theta) * r;

     CX := VX - xnd;
     CY := VY - ynd;    { 得到新的眼睛座標位置 }
end;

procedure TICONS.RotateY(delta: Single);
var
   xd, zd, r, theta, xnd, znd: Single;
begin
     xd := VX - CX;     zd := VZ - CZ;
     r := Sqrt((xd*xd)+(zd*zd));        { XZ 平面投影的直徑 }

     if r = 0.0 then theta := 0.0
     else theta := ArcCos(xd / r);      { 計算原本的夾角 }
     if zd < 0.0 then theta := (2 * PI) - theta;      { 得到圓周弧度值 }

     theta := theta + delta;            { 逆時針轉 deltaDeg 弧度 }
     xnd := Cos(theta) * r;
     znd := Sin(theta) * r;

     CX := VX - xnd;
     CZ := VZ - znd;    { 得到新的眼睛座標位置 }
end;

procedure TICONS.RotateYZ(delta: Single);
var
   yd, zd, r, theta, ynd, znd: Single;
begin
     yd := VY - CY;
     zd := VZ - CZ;
     r := Sqrt((yd*yd)+(zd*zd));        { YZ 平面投影的直徑 }

     if r = 0.0 then theta := 0.0
     else theta := ArcCos(zd / r);      { 計算原本的夾角 }
     if yd < 0.0 then theta := (2.0 * PI) - theta;      { 得到圓周弧度值 }

     theta := theta + delta;            { 逆時針轉 deltaDeg 弧度 }
     ynd := Sin(theta) * r;
     znd := Cos(theta) * r;

     CZ := VZ - znd;
     CY := VY - ynd;    { 得到新的眼睛座標位置 }
end;

procedure TICONS.ZoomIn(dist: Single);
var
   xd, yd, zd, r, xnd, ynd, znd: Single;
begin
     xd := VX - CX;
     yd := VY - CY;
     zd := VZ - CZ;
     r := Sqrt((xd*xd) + (yd*yd) + (zd*zd));    { CV 向量的原本長度 }

     xnd := xd / r * (r + dist);
     ynd := yd / r * (r + dist);
     znd := zd / r * (r + dist);

     CX := VX - xnd;
     CY := VY - ynd;
     CZ := VZ - znd;    { 得到新的眼睛座標位置 }
end;

procedure TICONS.showAgain(Sender: TObject);
begin
     DrawScene;
end;

function  LoopAround(pr: Pointer): LongInt;  stdcall;
var
//   t1, t2: TDateTime;
   h, m, s, ms: Word;
   i, j, k: Integer;
begin   // 不斷繞圈
//     t1 := Time;
     if keep_show then ExitThread(0);
     keep_show := True;         j := 0;         k := 0;
     while keep_show do begin
        Inc(k);
        if k = 6 then begin
            if j = frames - 1 then j := 0;
            Inc(j);             k := 0;
            if frames = 1 then j := 1;          // 只有一組
            ICONS.SeeFrame(j);
        end;
        ICONS.RotateY(0.10472);                 // 逆時針轉 6 度
        ICONS.Invalidate;       // canvas 的 repaint 是畫面閃動的主因
        Sleep(60);
     end;
     ICONS.Hide;                hThr := 0;
     Result := 0;               ExitThread(0);
//     t2 := Time;
//     DecodeTime(t2 - t1, h, m, s, ms);
     i := (((h * 60) + m) * 60) + s;
     i := ms + (i * 1000);
{     ICONS.Caption := Format('%4.3f fps', [LOOP_COUNT * 1000 / i]) +
        Format(', 轉 %d 次, 花 %d 毫秒', [LOOP_COUNT, i]);  }
end;

procedure TICONS.Stop_Show;
begin
     keep_show := False;
end;

procedure TICONS.SayLocation;
var
   s: string;
begin
     s := 'Eye: (' + Format('%3.3f, %3.3f, %3.3f', [CX, CY, CZ]) + ')';
//     MYUSB.Memo1.Lines.Add(s);
//     DebugStr(0, 3, s);
     s := 'Screen Center: (' + Format('%3.3f, %3.3f, %3.3f', [VX, VY, VZ]) + ')';
//     DebugStr(0, 4, s);
end;

procedure TICONS.doKeys(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     case Key of
        38: MoveUpDown(1.0);            // VK_UP
        40: MoveUpDown(-1.0);           // VK_DOWN
        37: MoveSideways(-1.0);         // VK_LEFT
        39: MoveSideways(1.0);          // VK_RIGHT
        109: SeeFrame(-1);              // '-' 看前一動畫系列
        107: SeeFrame(1);               // '+' 看下一動畫系列
        74: RotateXY(0.2618);           // j - 逆時針轉 15 度
        75: RotateXY(-0.2618);          // k - 順時針轉 15 度
        73: RotateY(0.19634);           // i - 逆時針轉 15 度
        77: RotateYZ(-0.2618);          // m - 順時針轉 15 度
        79: ZoomIn(1);                  // o - 拉近
        80: ZoomIn(-1);                 // p - 拉遠
     end;
     DrawScene;
end;

end.
