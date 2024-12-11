unit UsbIoPipe;

interface

uses Windows, UsbIo_i, UsbIo, UsbIoBuf, UsbIo_i_delphi;

{$I DEBUG.PAS}

{************************************************************************
 *
 *  Module:       UsbIoPipe.h
 *  Long name:    CUsbIoPipe class
 *  Description:  USB In/Out Pipe class definition
 *
 *  Runtime Env.: Win32, Part of UsbioLib
 *  Author(s):    Guenter Hildebrandt, Udo Eberhardt, Thomas Fröhlich
 *  Company:      Thesycon GmbH, Ilmenau
 ************************************************************************}

type
  TUsbIoPipe = class(TUsbIo)
  public
      function Bind(
                   DeviceNumber        : integer;
                   EndpointAddress     : UCHAR;
                   DeviceList          : HDEVINFO  = nil;
                   InterfaceGuid       : PGUID = nil
                   ): DWORD;
      function Unbind: DWORD;
      function ResetPipe: DWORD;
      function AbortPipe: DWORD;
      function GetPipeParameters(PipeParameters: PUSBIO_PIPE_PARAMETERS): DWORD;
      function SetPipeParameters(PipeParameters: PUSBIO_PIPE_PARAMETERS): DWORD;
      function PipeControlTransferIn(
                   Buffer              : pointer;
               var ByteCount           : DWORD;
                   ControlTransfer     : USBIO_PIPE_CONTROL_TRANSFER
                   ): DWORD;
      function PipeControlTransferOut(
                   Buffer              : pointer;
               var ByteCount           : DWORD;
                   ControlTransfer     : USBIO_PIPE_CONTROL_TRANSFER
                   ): DWORD;
      function Read (Buf: TUsbIoBuf): BOOL;
      function Write(Buf: TUsbIoBuf): BOOL;
      function WaitForCompletion(
                   Buf                 : TUsbIoBuf;
                   Timeout             : DWORD = INFINITE
                   ): DWORD;
      function ReadSync(
                   Buffer              : pointer;
               var ByteCount           : DWORD;
                   Timeout             : DWORD = INFINITE
                   ): DWORD;
      function WriteSync(
                   Buffer              : pointer;
               var ByteCount           : DWORD;
                   Timeout             : DWORD = INFINITE
                   ): DWORD;
  end;

implementation

{$L DEBUGMON.OBJ}

type
  TTUsbIoBuf = class(TUsbIoBuf);


function TUsbIoPipe.Bind(
                   DeviceNumber        : integer;
                   EndpointAddress     : UCHAR;
                   DeviceList          : HDEVINFO  = nil;
                   InterfaceGuid       : PGUID = nil
                   ): DWORD;
var
  status           : DWORD;
  BindPipe         : USBIO_BIND_PIPE;
begin
  status:=Open(DeviceNumber,DeviceList,InterfaceGuid);
  if status <> USBIO_ERR_SUCCESS then
    begin
      result:=status;
      Exit;
    end;
  ZeroMemory(@BindPipe,sizeof(USBIO_BIND_PIPE));
  BindPipe.EndpointAddress:=EndpointAddress;
  status:=IoctlSync(IOCTL_USBIO_BIND_PIPE,
                    @BindPipe,
                    sizeof(USBIO_BIND_PIPE),
                    nil,
                    0,
                    nil);
  result:=status;
end;

function TUsbIoPipe.Unbind: DWORD;
begin
  Result:=IoctlSync(IOCTL_USBIO_UNBIND_PIPE,
                    nil,
                    0,
                    nil,
                    0,
                    nil);
end;

function TUsbIoPipe.ResetPipe: DWORD;
begin
  Result:=IoctlSync(IOCTL_USBIO_RESET_PIPE,
                    nil,
                    0,
                    nil,
                    0,
                    nil);
end;

function TUsbIoPipe.AbortPipe: DWORD;
begin
  Result:=IoctlSync(IOCTL_USBIO_ABORT_PIPE,
		    nil,
		    0,
		    nil,
		    0,
		    nil);
end;

function TUsbIoPipe.GetPipeParameters(PipeParameters: PUSBIO_PIPE_PARAMETERS): DWORD;
begin
  ZeroMemory(PipeParameters,sizeof(USBIO_PIPE_PARAMETERS));
  Result:=IoctlSync(IOCTL_USBIO_GET_PIPE_PARAMETERS,
                    nil,
                    0,
                    PipeParameters,
                    sizeof(USBIO_PIPE_PARAMETERS),
                    nil);
end;

function TUsbIoPipe.SetPipeParameters(PipeParameters: PUSBIO_PIPE_PARAMETERS): DWORD;
begin
  Result:=IoctlSync(IOCTL_USBIO_SET_PIPE_PARAMETERS,
                    @PipeParameters,
                    sizeof(USBIO_PIPE_PARAMETERS),
                    nil,
                    0,
                    nil);
end;

function TUsbIoPipe.PipeControlTransferIn(
                   Buffer              : pointer;
               var ByteCount           : DWORD;
                   ControlTransfer     : USBIO_PIPE_CONTROL_TRANSFER
                   ): DWORD;
begin
  Result:=IoctlSync(IOCTL_USBIO_PIPE_CONTROL_TRANSFER_IN,
                    @ControlTransfer,
                    sizeof(USBIO_PIPE_CONTROL_TRANSFER),
                    Buffer,
                    ByteCount,
                    @ByteCount);
end;

function TUsbIoPipe.PipeControlTransferOut(
                   Buffer              : pointer;
               var ByteCount           : DWORD;
                   ControlTransfer     : USBIO_PIPE_CONTROL_TRANSFER
                   ): DWORD;
begin
  Result:=IoctlSync(IOCTL_USBIO_PIPE_CONTROL_TRANSFER_OUT,
                    @ControlTransfer,
                    sizeof(USBIO_PIPE_CONTROL_TRANSFER),
                    Buffer,
                    ByteCount,
                    @ByteCount);

end;

function TUsbIoPipe.Read(Buf: TUsbIoBuf): BOOL;
var
  succ             : boolean;
  b                : TTUsbIoBuf;
begin
  b:=TTUsbIoBuf(Buf);
  succ:=ReadFile(FileHandle,
                 b.buffer^,
                 B.NumberOfBytesToTransfer,
                 B.BytesTransferred,
                 @B.Overlapped);
  if succ then
    b.status:=USBIO_ERR_SUCCESS
  else
    begin
      b.Status:=GetLastError;
      if b.Status=ERROR_IO_PENDING then succ:=true;
    end;
  result:=succ;
end;

function TUsbIoPipe.Write(Buf: TUsbIoBuf): BOOL;
var
  succ             : boolean;
  b                : TTUsbIoBuf;
begin
  b:=TTUsbIoBuf(Buf);
  succ:=WriteFile(FileHandle,
                 b.buffer^,
                 B.NumberOfBytesToTransfer,
                 B.BytesTransferred,
                 @B.Overlapped);
  if succ then
    b.Status:=USBIO_ERR_SUCCESS
  else
    begin
      b.Status:=GetLastError;
      if b.Status=ERROR_IO_PENDING then succ:=true;
    end;
  result:=succ;
end;

function TUsbIoPipe.WaitForCompletion(
                   Buf                 : TUsbIoBuf;
                   Timeout             : DWORD = INFINITE
                   ): DWORD;
var
  status           : DWORD;
  err              : DWORD;
  succ             : BOOL;
  B                : TTUsbIoBuf;

begin
  b:=TTUsbIoBuf(Buf);
  if b.Status=USBIO_ERR_SUCCESS then
    status:=USBIO_ERR_SUCCESS
  else
    begin
      if b.Status=ERROR_IO_PENDING then		{ = 0x3E5 }
      begin
        err:=Windows.WaitForSingleObject(b.Overlapped.hEvent,Timeout);
        if err=WAIT_TIMEOUT then		{ = 0x102 }
          status:=USBIO_ERR_TIMEOUT
        else
          begin
            succ:=Windows.GetOverlappedResult(FileHandle,
                                      b.Overlapped,
                                      b.BytesTransferred,
                                      false);
        if succ then b.Status:=USBIO_ERR_SUCCESS
                else b.Status:=Windows.GetLastError;
        status:=b.Status;
      end;
    end else
      status:=b.Status;
  end;
  result:=status;
end;

function TUsbIoPipe.ReadSync(
                   Buffer              : pointer;
               var ByteCount           : DWORD;
                   Timeout             : DWORD = INFINITE
                   ): DWORD;
var
	status           : DWORD;
	Buf              : TUsbIoBuf;
begin
	Buf:=TUsbIoBuf.Create(Buffer,ByteCount);
	Buf.NumberOfBytesToTransfer:=ByteCount;
	Buf.BytesTransferred:=0;
	Read(Buf);
	status:=WaitForCompletion(Buf, Timeout);
	if status=USBIO_ERR_TIMEOUT then	{ = 0x102 }
		begin
			CancelIo;
			status:=WaitForCompletion(Buf,INFINITE);
		end;
	ByteCount:=Buf.BytesTransferred;
        Overlap_Status := Buf.Status;
//        DebugDump(4, Buf.Buffer, 32);
	buf.free;
	result:=status;
end;

function TUsbIoPipe.WriteSync(
									 Buffer              : pointer;
							 var ByteCount           : DWORD;
									 Timeout             : DWORD = INFINITE
									 ): DWORD;
var
	status           : DWORD;
	Buf              : TUsbIoBuf;
begin
	Buf:=TUsbIoBuf.Create(Buffer,ByteCount);
	Buf.NumberOfBytesToTransfer:=ByteCount;
	Buf.BytesTransferred:=0;
	Write(Buf);
	status:=WaitForCompletion(Buf,Timeout);
	if status=USBIO_ERR_TIMEOUT then
		begin
			CancelIo;
			status:=WaitForCompletion(Buf,INFINITE);
		end;
  ByteCount:=Buf.BytesTransferred;
  result:=status;
end;

end.
