unit UsbIoBuf;

interface

uses Windows;

{************************************************************************
 *
 *  Module:       UsbIoBuf.h
 *  Long name:    CUsbIoBuf class
 *  Description:  definition of an USB I/O buffer and buffer pool
 *
 *  Runtime Env.: Win32, Part of UsbioLib
 *  Author(s):    Guenter Hildebrandt, Udo Eberhardt, Thomas Fröhlich
 *  Company:      Thesycon GmbH, Ilmenau
 ************************************************************************}

type
  TUsbIoBuf = class
  protected
    BufferMem                          : pointer;
    BufferSize                         : DWORD;
    Overlapped                         : TOverlapped;
    BufferMemAllocated                 : boolean;
    procedure Init;
  public
    NumberOfBytesToTransfer            : DWORD;
    BytesTransferred                   : DWORD;
    Status                             : DWORD;
    Next                               : TUsbIoBuf;
    OperationFinished                  : BOOL;
    constructor Create; overload;
    constructor Create(_buffer: pointer; _buffersize: DWORD); overload;   //in c++ buffer, buffersize
    constructor Create(                  _buffersize: DWORD); overload;
    destructor Destroy; override;
    property buffer                    : pointer read BufferMem;
    property internal                  : DWORD read Overlapped.Internal;
    property Size                      : DWORD read BufferSize;
  end;

  TUsbIoBufPool = class
  private
    Head                               : TUsbIoBuf;
    Count                              : Integer;
    CritSect                           : TRTLCriticalSection;
    BufArray                           : array of TUsbIoBuf;
    BufferMemory                       : pointer;
  public
    constructor Create;
    destructor  Destroy; override;
    function Allocate(SizeOfBuffer, NumberOfBuffers: DWORD): BOOL;
    procedure FreePool;                 //in c++ void Free();
    property CurrentCount: Integer read Count;
    function Get: TUsbIoBuf;
    procedure Put(Buf: TUsbIoBuf);
  end;

implementation

constructor TUsbIoBuf.Create;
begin
  inherited Create;
  Init;
end;

constructor TUsbIoBuf.Create(_buffer: pointer; _buffersize: DWORD);
begin
  inherited Create;
  Init;
  BufferMem:=_buffer;
  BufferSize:=_buffersize;
end;

constructor TUsbIoBuf.Create(_buffersize: DWORD);
begin
  inherited Create;
  Init;
  if buffersize <> 0 then
  begin
    Getmem(Buffermem, buffersize);
    BufferSize:=buffersize;
    BufferMemAllocated:=true;
  end;
end;

destructor TUsbIoBuf.Destroy;
begin
  if Overlapped.hEvent <> 0 then CloseHandle(Overlapped.hEvent);
  if BufferMemAllocated and (BufferMem<>nil) then Freemem(BufferMem);
end;

procedure TUsbIoBuf.Init;
begin
  NumberOfBytesToTransfer:=0;
  BytesTransferred:=0;
  Status:=0;
  Next:=nil;
  OperationFinished:=false;
  BufferMem:=nil;
  BufferSize:=0;
  BufferMemAllocated:=false;

  ZeroMemory(@Overlapped,sizeof(Overlapped));
  Overlapped.hEvent:=CreateEvent(nil,false,false,nil);
end;

constructor TUsbIoBufPool.Create;
begin
  inherited Create;
  Head:=nil;
  Count:=0;
  BufArray:=nil;
  BufferMemory:=nil;
  InitializeCriticalSection(CritSect);
end;

destructor TUsbIoBufPool.Destroy;
begin
  FreePool;
  DeleteCriticalSection(CritSect);
  inherited Destroy;
end;

function TUsbIoBufPool.Allocate(SizeOfBuffer, NumberOfBuffers: DWORD): BOOL;
var
  i                : DWORD;
  buf              : TUsbIoBuf;
  succ             : boolean;
  size             : DWORD;
begin
  succ:=false;
  EnterCriticalSection(CritSect);
  try
    if length(BufArray) = 0 then
    begin
      SetLength(BufArray,NumberOfBuffers);
      size:=SizeOfBuffer*NumberOfBuffers;
      GetMem(BufferMemory, size);
      for i := 0 to NumberOfBuffers - 1 do
        begin
          Buf:=TUsbIobuf.Create;
          BufArray[i]:=buf;
          buf.BufferSize:=SizeOfBuffer;
          buf.BufferMem:=@(PChar(BufferMemory)[i*SizeOfBuffer]);
          buf.Next:=Head;
          Head:=buf;
        end;
      Count:=NumberOfBuffers;
      succ:=true;
    end;
  finally
    LeaveCriticalSection(CritSect);
  end;
  result:=succ;
end;

procedure TUsbIoBufPool.FreePool;
begin
  EnterCriticalSection(CritSect);
  try
    SetLength(BufArray, 0);
    if BufferMemory<>nil then
    begin
      FreeMem(BufferMemory);
      BufferMemory := nil;
    end;
    Head:=nil;
    Count:=0;
  finally
    LeaveCriticalSection(CritSect);
  end;
end;

function TUsbIoBufPool.Get: TUsbIoBuf;
var
  buf              : TUsbIoBuf;
begin
  EnterCriticalSection(CritSect);
  try
    buf:=Head;
    if buf<>nil then
      begin
        Head:=buf.Next;
        buf.Next:=nil;
        Dec(Count);
      end;
    result:=buf;
  finally
    LeaveCriticalSection(CritSect);
  end;
end;

procedure TUsbIoBufPool.Put(Buf: TUsbIoBuf);
begin
  EnterCriticalSection(CritSect);
  try
    Buf.Next:=Head;
    Head:=Buf;
    Inc(Count);
  finally
    LeaveCriticalSection(CritSect);
  end;
end;

end.
