unit USBIO;

interface

uses Windows, usbio_i, usbio_i_delphi, usbspec;

{************************************************************************
 *
 *  Module:       UsbIo.h and UsbIo.cpp
 *  Long name:    CUsbIo class
 *  Description:  CUsbIo base device class definition
 *
 *  Runtime Env.: Win32, Part of UsbioLib
 *  Author(s):    Guenter Hildebrandt, Udo Eberhardt, Thomas Fröhlich
 *  Company:      Thesycon GmbH, Ilmenau
 ************************************************************************}

const
  USBIO_DEVICE_NAME                    = 'USBIO_Device';

type
  TUsbIo = class
  protected
    FileHandle                         : THandle;		{ ofs $04 }
    Overlapped                         : TOVERLAPPED;
    CritSect                           : TRTLCriticalSection;	{ ofs $1C }
    CheckedBuildDetected               : Boolean;
    DemoVersionDetected                : Boolean;
    mDevDetail                         : PSP_DEVICE_INTERFACE_DETAIL_DATA_A;

  public
    constructor Create;                          //is CUsbIo() in c++
    destructor Destroy; override;                //is ~CUsbIo() in c++
    function  CreateDeviceList(InterfaceGuid:PGUID): HDEVINFO;
    procedure DestroyDeviceList(DeviceList: HDEVINFO);
    function  Open(
                   DeviceNumber        : integer;
                   DeviceList          : HDEVINFO=nil;
                   InterfaceGuid       : PGUID=nil
                   ): DWORD;
    procedure Close;
    function  GetDevicePathName():PCHAR;
    function  GetDriverInfo(DriverInfo: PUSBIO_DRIVER_INFO): DWORD;
    function  GetDescriptor(
                   Buffer              : Pointer;
               var ByteCount           : DWORD;
                   Recipient           : USBIO_REQUEST_RECIPIENT;
                   DescriptorType      : UCHAR;
                   DescriptorIndex     : UCHAR = 0;
                   LanguageId          : USHORT = 0
                   ): DWORD;
    function  SetDescriptor(
                   Buffer              : Pointer;
               var ByteCount           : LongInt;
                   Recipient           : USBIO_REQUEST_RECIPIENT;
                   DescriptorType      : UCHAR;
                   DescriptorIndex     : UCHAR = 0;
                   LanguageId          : USHORT = 0
                   ): DWORD;
    function  SetFeature(
                   Recipient           : USBIO_REQUEST_RECIPIENT;
                   FeatureSelector     : USHORT;
                   Index               : USHORT = 0
                   ): DWORD;
    function  ClearFeature(
                   Recipient           : USBIO_REQUEST_RECIPIENT;
                   FeatureSelector     : USHORT;
                   Index               : USHORT = 0
                   ): DWORD;
    function  GetStatus(
               var StatusValue         : USHORT;
                   Recipient           : USBIO_REQUEST_RECIPIENT;
                   Index               : USHORT = 0
                   ): DWORD;
    function  GetConfiguration(var ConfigurationValue: UCHAR): DWORD;
    function  GetInterface(
                   var AlternateSetting: UCHAR;
                   _Interface          : USHORT = 0
                   ): DWORD;
    function  StoreConfigurationDescriptor(Desc: PUSB_CONFIGURATION_DESCRIPTOR): DWORD;
    function  SetConfiguration(Conf: PUSBIO_SET_CONFIGURATION): DWORD;
    function  UnconfigureDevice: DWORD;
    function  SetInterface(Setting: PUSBIO_INTERFACE_SETTING): DWORD;
    function  ClassOrVendorInRequest(
                   Buffer              : Pointer;
               var ByteCount           : DWORD;
                   Request             : PUSBIO_CLASS_OR_VENDOR_REQUEST
                   ): DWORD;
    function  ClassOrVendorOutRequest(
                   Buffer              : Pointer;
               var ByteCount           : DWORD;
                   Request             : PUSBIO_CLASS_OR_VENDOR_REQUEST
                   ): DWORD;
    function  GetDeviceParameters(DevParam: PUSBIO_DEVICE_PARAMETERS): DWORD;
    function  SetDeviceParameters(DevParam: PUSBIO_DEVICE_PARAMETERS): DWORD;
    function  GetConfigurationInfo(Info: PUSBIO_CONFIGURATION_INFO): DWORD;
    function  ResetDevice: DWORD;
    function  CyclePort: DWORD;
    function  GetCurrentFrameNumber(var FrameNumber: DWORD): DWORD;
    function  GetDevicePowerState(var DevicePowerState: USBIO_DEVICE_POWER_STATE): DWORD;
    function  SetDevicePowerState(    DevicePowerState: USBIO_DEVICE_POWER_STATE): DWORD;
    function  GetDeviceDescriptor(Desc: PUSB_DEVICE_DESCRIPTOR): DWORD;
    function  GetConfigurationDescriptor(
                   Desc                : PUSB_CONFIGURATION_DESCRIPTOR;
               var ByteCount           : DWORD;
                   Index               : UCHAR = 0
                   ): DWORD;
    function  GetStringDescriptor(
                   Desc                : PUSB_STRING_DESCRIPTOR;
               var ByteCount           : DWORD;
                   Index               : UCHAR = 0
                   ): DWORD;
    function  ErrorText(ErrorCode: DWORD): string;
    function  IoctlSync(
                   IoctlCode           : DWORD;
                   InBuffer            : Pointer;
                   InBufferSize        : DWORD;
                   OutBuffer           : Pointer;
                   OutBufferSize       : DWORD;
                   BytesReturned       : PDWORD
                   ): DWORD;
    function  CancelIo: BOOL;
    property  IsCheckedBuild: boolean read CheckedBuildDetected;
    property  IsDemoVersion : boolean read DemoVersionDetected;
  end;

var
   Overlap_Status: Integer;     { ©ñ TUsbIoPipe.ReadSync «áªº TUsbIoBuf.Overlap.Internal }

implementation

uses Sysutils;

constructor TUsbIo.Create;
begin	{ $402900 }
  inherited Create;
  FileHandle:=0;
  ZeroMemory(@Overlapped,sizeof(Overlapped));
  InitializeCriticalSection(CritSect);		{ + $1C }
  CheckedBuildDetected:=FALSE;
  DemoVersionDetected:=FALSE;
  mDevDetail:=nil;
end;

destructor TUsbIo.Destroy;
begin	{ $402960 }
  Close;
  DeleteCriticalSection(CritSect);	{ + $1C }
  inherited Destroy;
end;

function TUsbIo.CreateDeviceList(InterfaceGuid:PGUID): HDEVINFO;
var
  h                : HDEVINFO;
begin	{ $402980 }

  h:=SetupDiGetClassDevsA(InterfaceGuid,                  // LPGUID ClassGuid,
        nil,                                  // PCTSTR Enumerator,
        0,                                  // HWND hwndParent,
        DIGCF_DEVICEINTERFACE or DIGCF_PRESENT  // DWORD Flags
        );
  if DWORD(h)=INVALID_HANDLE_VALUE then result:=nil
                                   else result:=h;
end;

procedure TUsbIo.DestroyDeviceList(DeviceList: HDEVINFO);
begin	{ $4029A0 }
  if DeviceList<>nil then
    SetupDiDestroyDeviceInfoList(DeviceList);
end;

function TUsbIo.Open(DeviceNumber      : integer;
                     DeviceList        : HDEVINFO=nil;
                     InterfaceGuid     : PGUID=nil): DWORD;
var	{ $4029B0 }
  status                               : DWORD;
  h                                    : THandle;
  name                                 : string;
  DevData                              : SP_DEVICE_INTERFACE_DATA; { [esp+24], usbio__delphi.pas line 89 }
  succ                                 : boolean;
  RegLen                               : DWORD;		{ [esp+10] }
  info                                 : USBIO_DRIVER_INFO ;	{ [esp+14] }
  pName: PChar;
begin
  if FileHandle <> 0 then		{ FileHandle = dword ptr [esi+04] }
    begin
      Result := USBIO_ERR_SUCCESS;
      exit;
    end;
  if DeviceList = nil then		{ DeviceList = dword ptr [esp+0094] }
    begin
      Name := '\\.\'+USBIO_DEVICE_NAME+IntToStr(DeviceNumber);
    end else
    begin
      if InterfaceGuid=nil then		{ = dword ptr [esp+0098] }
        begin
          result:=USBIO_ERR_INVALID_FUNCTION_PARAM;	{ = 0xE0001105 }
          exit;
        end;
      if mDevDetail<>nil then
        begin
          dispose(mDevDetail);
          mDevDetail:=nil;
        end;
      ZeroMemory(@DevData,sizeof(DevData));
      DevData.cbSize := sizeof(SP_DEVICE_INTERFACE_DATA);	{ size = 0x1C }
      succ:=SetupDiEnumDeviceInterfaces(DeviceList, nil, InterfaceGuid, DeviceNumber, @DevData );
      if not(succ) then
        begin
          Status:=GetLastError();	{ ERROR_NO_MORE_ITEMS = 0x103 }
          if Status=ERROR_NO_MORE_ITEMS then Status:=USBIO_ERR_NO_SUCH_DEVICE_INSTANCE; { = 0xE0001104 }
          result:=Status;
          exit;
        end;
      SetupDiGetDeviceInterfaceDetailA(DeviceList,@DevData,nil,0,@RegLen,nil);
      try
        getmem(mDevDetail,reglen);
      except
         result:=USBIO_ERR_NO_MEMORY;	{ = 0xE0000100 }
         exit;
      end;
      ZeroMemory(mDevDetail,RegLen);
      mDevDetail^.cbSize:=sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA_A);
      succ:=SetupDiGetDeviceInterfaceDetailA(DeviceList, @DevData, mDevDetail, RegLen, @RegLen, nil);
      if not(succ) then
        begin
          result:=GetLastError();
          exit;
        end;
      Name:=string(pchar(@mDevDetail^.DevicePath));
    end; {else}

{ NAPLINK.EXE $402AF0 }
    pName := AllocMem(512);     StrPCopy(pName, Name);
    h:=CreateFile(pName, GENERIC_READ or GENERIC_WRITE, // access mode
      FILE_SHARE_WRITE or FILE_SHARE_READ, // share mode
      nil, // security desc.
      OPEN_EXISTING, // how to create
      FILE_FLAG_OVERLAPPED, // file attributes
      0); // template file
    FreeMem(pName);

    if h=INVALID_HANDLE_VALUE then
      status:=USBIO_ERR_DEVICE_NOT_FOUND	{ = 0xE0001100 }
    else
    begin
      FileHandle:=h;
      Overlapped.hEvent:=CreateEvent(nil, false, false, nil);
      if Overlapped.hEvent=0 then
        begin
          status:=USBIO_ERR_NO_MEMORY;		{ = 0xE0000100 }
          Close;
        end else
        begin
          status:=GetDriverInfo(@info);
          if status <> USBIO_ERR_SUCCESS then	{ USBIO_ERR_SUCCESS = 0 }
            Close
          else
          begin
            CheckedBuildDetected:=(info.Flags and USBIO_INFOFLAG_CHECKED_BUILD) <> 0;	{ USBIO_INFOFLAG_DEMO_VERSION = 0x10 }
	    DemoVersionDetected :=(info.Flags and USBIO_INFOFLAG_DEMO_VERSION) <> 0;	{ USBIO_INFOFLAG_DEMO_VERSION = 0x20 }
            if info.APIVersion <> USBIO_API_VERSION then	{ USBIO_API_VERSION = 0x141 }
              begin
	          status:=USBIO_ERR_VERSION_MISMATCH;	{ 0xE000101C }
        	  Close;
              end
              else
                status:=USBIO_ERR_SUCCESS;
          end;
        end;
    end;
  result:=status;
end;

procedure TUsbIo.Close;
begin	{ $402BE0 }
  if FileHandle<>0 then
    begin
      Windows.CloseHandle(FileHandle);
      FileHandle:=0;
    end;
  if Overlapped.hEvent <> 0 then
    begin
      Windows.CloseHandle(Overlapped.hEvent);
      Overlapped.hEvent:=0;
    end;
  if mDevDetail<>nil then
    begin
      dispose(mDevDetail);
//      mDevDetail := nil;
    end;
end;

function  TUsbIo.GetDevicePathName():PCHAR;
begin
  if mDevDetail<>nil then result:=PCHAR(@(mDevDetail^.DevicePath))
                     else result:=nil;
end;

function TUsbIo.GetDriverInfo(DriverInfo: PUSBIO_DRIVER_INFO): DWORD;
begin	{ at $402C30 }
  Result:=IoctlSync(IOCTL_USBIO_GET_DRIVER_INFO,	{ = 0x8094206C }
        nil,
        0,
        DriverInfo,
        sizeof(USBIO_DRIVER_INFO),
        nil);

end;

function TUsbIo.GetDescriptor(
                   Buffer              : Pointer;
               var ByteCount           : DWORD;
                   Recipient           : USBIO_REQUEST_RECIPIENT;
                   DescriptorType      : UCHAR;
                   DescriptorIndex     : UCHAR = 0;
                   LanguageId          : USHORT = 0
                   ): DWORD;
var
  req              : USBIO_DESCRIPTOR_REQUEST;
begin
  ZeroMemory(@req,sizeof(req));
  req.Recipient      :=Recipient;
  req.DescriptorType :=DescriptorType;
  req.DescriptorIndex:=DescriptorIndex;
  req.LanguageId     :=LanguageId;
  Result:=IoctlSync(IOCTL_USBIO_GET_DESCRIPTOR,	 { = 0x80942006 }
        @req,
        sizeof(req),	{ = 8 }
        Buffer,
        ByteCount,
        @ByteCount);
end;

function TUsbIo.SetDescriptor(
                   Buffer              : Pointer;
               var ByteCount           : LongInt;
                   Recipient           : USBIO_REQUEST_RECIPIENT;
                   DescriptorType      : UCHAR;
                   DescriptorIndex     : UCHAR = 0;
                   LanguageId          : USHORT = 0
                   ): DWORD;
var
  req              : USBIO_DESCRIPTOR_REQUEST;
begin
  ZeroMemory(@req,sizeof(req));
  req.Recipient      :=Recipient;
  req.DescriptorType :=DescriptorType;
  req.DescriptorIndex:=DescriptorIndex;
  req.LanguageId     :=LanguageId;
  Result:=IoctlSync(IOCTL_USBIO_SET_DESCRIPTOR,	 { = 0x80942024 }
        @req,
        sizeof(req),	{ = 0x104 }
        Buffer,
        ByteCount,
        PDWORD(@ByteCount));
end;

function TUsbIo.SetFeature(
                   Recipient           : USBIO_REQUEST_RECIPIENT;
                   FeatureSelector     : USHORT;
                   Index               : USHORT = 0
                   ): DWORD;
var
  req              : USBIO_FEATURE_REQUEST;
begin
  ZeroMemory(@req,sizeof(req));
  req.Recipient      := Recipient;
  req.FeatureSelector:= FeatureSelector;
  req.Index          := Index;
  Result := IoctlSync(IOCTL_USBIO_SET_FEATURE,
                      @req,
                      sizeof(req),
                      nil,
                      0,
                      nil);
end;

function TUsbIo.ClearFeature(
                   Recipient           : USBIO_REQUEST_RECIPIENT;
                   FeatureSelector     : USHORT;
                   Index               : USHORT = 0
                   ): DWORD;
var
  req              : USBIO_FEATURE_REQUEST;
begin
  ZeroMemory(@req,sizeof(req));
  req.Recipient      :=Recipient;
  req.FeatureSelector:=FeatureSelector;
  req.Index          :=Index;
  Result:=IoctlSync(IOCTL_USBIO_CLEAR_FEATURE,
                    @req,
                    sizeof(req),
                    nil,
                    0,
                    nil);
end;

function TUsbIo.GetStatus(
               var StatusValue         : USHORT;
                   Recipient           : USBIO_REQUEST_RECIPIENT;
                   Index               : USHORT = 0
                   ): DWORD;
var
  req              : USBIO_STATUS_REQUEST;
  data             : USBIO_STATUS_REQUEST_DATA;
begin
  ZeroMemory(@req, sizeof(req));
  ZeroMemory(@data,sizeof(data));
  req.Recipient:= Recipient;
  req.Index    := Index;
  Result:=IoctlSync(IOCTL_USBIO_GET_STATUS,
              @req,
        sizeof(req),
        @data,
        sizeof(data),
        nil);
  StatusValue:=data.Status;
end;

function TUsbIo.GetConfiguration(var ConfigurationValue: UCHAR): DWORD;
var
  data             : USBIO_GET_CONFIGURATION_DATA;
begin
  ZeroMemory(@data, sizeof(data));
  Result:=IoctlSync(IOCTL_USBIO_GET_CONFIGURATION,
                    nil,
        0,
        @data,
        sizeof(data),
        nil);
  ConfigurationValue:=data.ConfigurationValue;
end;

function TUsbIo.GetInterface(
                   var AlternateSetting: UCHAR;
                   _Interface          : USHORT = 0
                   ): DWORD;
var
  req              : USBIO_GET_INTERFACE;
  data             : USBIO_GET_INTERFACE_DATA;
begin
  ZeroMemory(@req, sizeof(req));
  ZeroMemory(@data,sizeof(data));
  req._Interface := _Interface;
  Result:=IoctlSync(IOCTL_USBIO_GET_INTERFACE,
        @req,
        sizeof(req),
        @data,
        sizeof(data),
        nil);
  AlternateSetting:=data.AlternateSetting;
end;

function TUsbIo.StoreConfigurationDescriptor(Desc: PUSB_CONFIGURATION_DESCRIPTOR): DWORD;
begin
  Result:=IoctlSync(IOCTL_USBIO_STORE_CONFIG_DESCRIPTOR,
                    Desc,
                    Desc^.wTotalLength,
                    nil,
                    0,
                    nil);
end;

function TUsbIo.SetConfiguration(Conf: PUSBIO_SET_CONFIGURATION): DWORD;
begin
  Result:=IoctlSync(IOCTL_USBIO_SET_CONFIGURATION,  { = 0x80942024 }
        Conf,
        sizeof(USBIO_SET_CONFIGURATION),	{ = 0x0104 }
        nil,
        0,
        nil);
end;

function TUsbIo.UnconfigureDevice: DWORD;
begin
  Result:=IoctlSync(IOCTL_USBIO_UNCONFIGURE_DEVICE,
                    nil,
                    0,
                    nil,
                    0,
                    nil);
end;

function TUsbIo.SetInterface(Setting: PUSBIO_INTERFACE_SETTING): DWORD;
begin
  Result:=IoctlSync(IOCTL_USBIO_SET_INTERFACE,
        Setting,
        sizeof(USBIO_INTERFACE_SETTING),
        nil,
        0,
        nil);
end;

function TUsbIo.ClassOrVendorInRequest(
                   Buffer              : Pointer;
               var ByteCount           : DWORD;
                   Request             : PUSBIO_CLASS_OR_VENDOR_REQUEST
                   ): DWORD;
begin
  Result:=IoctlSync(IOCTL_USBIO_CLASS_OR_VENDOR_IN_REQUEST,
        Request,
        sizeof(USBIO_CLASS_OR_VENDOR_REQUEST),
        Buffer,
        ByteCount,
        @ByteCount);
end;

function TUsbIo.ClassOrVendorOutRequest(
                   Buffer              : Pointer;
               var ByteCount           : DWORD;
                   Request             : PUSBIO_CLASS_OR_VENDOR_REQUEST
                   ): DWORD;
begin	{ = $402CD0 }
  Result:=IoctlSync(IOCTL_USBIO_CLASS_OR_VENDOR_OUT_REQUEST,  { = 0x80942035 }
        Request,
        sizeof(USBIO_CLASS_OR_VENDOR_REQUEST),	 { = 0x12 }
        Buffer,
        ByteCount,
        @ByteCount);
end;

function TUsbIo.GetDeviceParameters(DevParam: PUSBIO_DEVICE_PARAMETERS): DWORD;
begin
  ZeroMemory(DevParam,sizeof(USBIO_DEVICE_PARAMETERS));
  Result:=IoctlSync(IOCTL_USBIO_GET_DEVICE_PARAMETERS,
        nil,
        0,
        DevParam,
        sizeof(USBIO_DEVICE_PARAMETERS),
        nil);
end;

function TUsbIo.SetDeviceParameters(DevParam: PUSBIO_DEVICE_PARAMETERS): DWORD;
begin
  Result:=IoctlSync(IOCTL_USBIO_SET_DEVICE_PARAMETERS,
        DevParam,
        sizeof(USBIO_DEVICE_PARAMETERS),
        nil,
        0,
        nil);
end;

function TUsbIo.GetConfigurationInfo(Info: PUSBIO_CONFIGURATION_INFO): DWORD;
begin
  ZeroMemory(@Info,sizeof(USBIO_CONFIGURATION_INFO));
  Result:=IoctlSync(IOCTL_USBIO_GET_CONFIGURATION_INFO,
              nil,
        0,
        Info,
        sizeof(USBIO_CONFIGURATION_INFO),
        nil);
end;

function TUsbIo.ResetDevice: DWORD;
begin	{ 0x402D00 }
  Result:=IoctlSync(IOCTL_USBIO_RESET_DEVICE,
        nil,
        0,
        nil,
        0,
        nil);
end;

function TUsbIo.CyclePort: DWORD;
begin
  Result:=IoctlSync(IOCTL_USBIO_CYCLE_PORT,
        nil,
        0,
        nil,
        0,
        nil);
end;

function TUsbIo.GetCurrentFrameNumber(var FrameNumber: DWORD): DWORD;
var
  data             : USBIO_FRAME_NUMBER;
begin
  ZeroMemory(@data,sizeof(data));
  Result:=IoctlSync(IOCTL_USBIO_GET_CURRENT_FRAME_NUMBER,
        nil,
        0,
        @data,
        sizeof(data),
        nil);
  FrameNumber:=data.FrameNumber;
end;

function TUsbIo.GetDevicePowerState(var DevicePowerState: USBIO_DEVICE_POWER_STATE): DWORD;
var
  PowerRequest     : USBIO_DEVICE_POWER;
begin
  Result:=IoctlSync(IOCTL_USBIO_GET_DEVICE_POWER_STATE,
        nil,
        0,
        @PowerRequest,
        sizeof(USBIO_DEVICE_POWER),
        nil);
  if Result=USBIO_ERR_SUCCESS then DevicePowerState:=PowerRequest.DevicePowerState;
end;

function TUsbIo.SetDevicePowerState(DevicePowerState: USBIO_DEVICE_POWER_STATE): DWORD;
var
  PowerRequest     : USBIO_DEVICE_POWER;
begin
  PowerRequest.DevicePowerState:=DevicePowerState;
  Result:=IoctlSync(IOCTL_USBIO_SET_DEVICE_POWER_STATE,
        @PowerRequest,
        sizeof(USBIO_DEVICE_POWER),
        nil,
        0,
        nil);
end;

function TUsbIo.GetDeviceDescriptor(Desc: PUSB_DEVICE_DESCRIPTOR): DWORD;
var
  ByteCount        : DWORD;
begin
  ByteCount:=sizeof(USB_DEVICE_DESCRIPTOR);     { 18 bytes }
  Result:=GetDescriptor(Desc,
      ByteCount,
      RecipientDevice,
      USB_DEVICE_DESCRIPTOR_TYPE,               { = 1 }
      0,
      0);
end;

function TUsbIo.GetConfigurationDescriptor(
                   Desc                : PUSB_CONFIGURATION_DESCRIPTOR;
               var ByteCount           : DWORD;
                   Index               : UCHAR = 0
                   ): DWORD;
begin
  Result:=GetDescriptor(Desc,
                  ByteCount,
      RecipientDevice,
      USB_CONFIGURATION_DESCRIPTOR_TYPE,
      Index,
      0);
end;

function TUsbIo.GetStringDescriptor(
                   Desc                : PUSB_STRING_DESCRIPTOR;
               var ByteCount           : DWORD;
                   Index               : UCHAR = 0
                   ): DWORD;
begin
  Result:=GetDescriptor(Desc,
      ByteCount,
      RecipientDevice,
      USB_STRING_DESCRIPTOR_TYPE,
      Index,
      0);

end;

function TUsbIo.IoctlSync(
                   IoctlCode           : DWORD;
                   InBuffer            : Pointer;
                   InBufferSize        : DWORD;
                   OutBuffer           : Pointer;
                   OutBufferSize       : DWORD;
                   BytesReturned       : PDWORD
                   ): DWORD;
var
  status           : DWORD;
  BytesRet         : DWORD;
  succ             : BOOL;
begin	{ $402D50 }
  BytesRet:=0;
  if FileHandle = 0 then
  begin
    Result:=USBIO_ERR_DEVICE_NOT_OPEN;	{ 0xE0001102 }
    Exit;
  end;
  EnterCriticalSection(CritSect);

    succ:=DeviceIoControl(FileHandle,
        IoctlCode,
        InBuffer,
        InBufferSize,
        OutBuffer,
        OutBufferSize,
        BytesRet,
        @Overlapped);

    if succ then
      status:=USBIO_ERR_SUCCESS
    else
    begin
      status:=GetLastError;
      if status=ERROR_IO_PENDING then
        begin
          succ:=GetOverlappedResult(FileHandle,
                                    Overlapped,
                                    BytesRet,
                                    true);
          if succ then status:=USBIO_ERR_SUCCESS
                  else status:=GetLastError;
        end;
    end;

  LeaveCriticalSection(CritSect);

  if BytesReturned<>nil then BytesReturned^:=BytesRet;
  result:=status;
end;

function TUsbIo.CancelIo: BOOL;
begin
  Result := Windows.CancelIo(FileHandle);
end;

function TUsbIo.ErrorText(ErrorCode: DWORD): string;
const
  size             = 71;
  ErrorCodeTable   :
     array[0..size] of record
                   ECode               : DWORD;
                   EText               : string[70]
     end =
    ((ECode: USBIO_ERR_SUCCESS;                 EText:'No error.'),
     (ECode: USBIO_ERR_CRC;                     EText:'HC Error: Wrong CRC.'),
     (ECode: USBIO_ERR_BTSTUFF;                 EText:'HC Error: Wrong bitstuffing.'),
     (ECode: USBIO_ERR_DATA_TOGGLE_MISMATCH;    EText:'HC Error: Data toggle mismatch.'),
     (ECode: USBIO_ERR_STALL_PID;               EText:'HC Error: stall PID.'),
     (ECode: USBIO_ERR_DEV_NOT_RESPONDING;      EText:'HC Error: Device not responding.'),
     (ECode: USBIO_ERR_PID_CHECK_FAILURE;       EText:'HC Error: PIP check failed.'),
     (ECode: USBIO_ERR_UNEXPECTED_PID;          EText:'HC Error: Unexpected PID.'),
     (ECode: USBIO_ERR_DATA_OVERRUN;            EText:'HC Error: Data Overrun.'),
     (ECode: USBIO_ERR_DATA_UNDERRUN;           EText:'HC Error: Data Underrun.'),
     (ECode: USBIO_ERR_RESERVED1;               EText:'HC Error: Reserved1.'),
     (ECode: USBIO_ERR_RESERVED2;               EText:'HC Error: Reserved2.'),
     (ECode: USBIO_ERR_BUFFER_OVERRUN;          EText:'HC Error: Buffer Overrun.'),
     (ECode: USBIO_ERR_BUFFER_UNDERRUN;         EText:'HC Error: Buffer Underrun.'),
     (ECode: USBIO_ERR_NOT_ACCESSED;            EText:'HC Error: Not accessed.'),
     (ECode: USBIO_ERR_FIFO;                    EText:'HC Error: FIFO error.'),
     (ECode: USBIO_ERR_ENDPOINT_HALTED;         EText:'USBD Error: Endpoint halted.'),
     (ECode: USBIO_ERR_NO_MEMORY;               EText:'USBD Error: No System Memory.'),
     (ECode: USBIO_ERR_INVALID_URB_FUNCTION;    EText:'USBD Error: Invalid URB function.'),
     (ECode: USBIO_ERR_INVALID_PARAMETER;       EText:'USBD Error: Invalid parameter.'),
     (ECode: USBIO_ERR_ERROR_BUSY;              EText:'USBD Error: Error: BUSY.'),
     (ECode: USBIO_ERR_REQUEST_FAILED;          EText:'USBD Error: Request failed.'),
     (ECode: USBIO_ERR_INVALID_PIPE_HANDLE;     EText:'USBD Error: Invalid pipe handle.'),
     (ECode: USBIO_ERR_NO_BANDWIDTH;            EText:'USBD Error: No bandwidth available.'),
     (ECode: USBIO_ERR_INTERNAL_HC_ERROR;       EText:'USBD Error: Internal HC error.'),
     (ECode: USBIO_ERR_ERROR_SHORT_TRANSFER;    EText:'USBD Error: Error: short transfer.'),
     (ECode: USBIO_ERR_BAD_START_FRAME;         EText:'USBD Error: Bad start frame.'),
     (ECode: USBIO_ERR_ISOCH_REQUEST_FAILED;    EText:'USBD Error: Isochronous request failed.'),
     (ECode: USBIO_ERR_FRAME_CONTROL_OWNED;     EText:'USBD Error: Frame control owned.'),
     (ECode: USBIO_ERR_FRAME_CONTROL_NOT_OWNED; EText:'USBD Error: Frame control not owned.'),
     (ECode: USBIO_ERR_CANCELED;                EText:'USBD Error: canceled.'),
     (ECode: USBIO_ERR_CANCELING;               EText:'USBD Error: canceling.'),
     (ECode: USBIO_ERR_FAILED;                  EText:'Operation failed.'),
     (ECode: USBIO_ERR_INVALID_INBUFFER;        EText:'Input buffer too small.'),
     (ECode: USBIO_ERR_INVALID_OUTBUFFER;       EText:'Output buffer too small.'),
     (ECode: USBIO_ERR_OUT_OF_MEMORY;           EText:'Out of memory.'),
     (ECode: USBIO_ERR_PENDING_REQUESTS;        EText:'There are pending requests. Use Abort first.'),
     (ECode: USBIO_ERR_ALREADY_CONFIGURED;      EText:'USB device is already configured.'),
     (ECode: USBIO_ERR_NOT_CONFIGURED;          EText:'USB device is not configured.'),
     (ECode: USBIO_ERR_OPEN_PIPES;              EText:'There are open pipes. Use Unbind/Close first.'),
     (ECode: USBIO_ERR_ALREADY_BOUND;           EText:'Pipe is already bound.'),
     (ECode: USBIO_ERR_NOT_BOUND;               EText:'Handle is not bound to a pipe.'),
     (ECode: USBIO_ERR_DEVICE_NOT_PRESENT;      EText:'Device is removed.'),
     (ECode: USBIO_ERR_CONTROL_NOT_SUPPORTED;   EText:'Control code is not supported.'),
     (ECode: USBIO_ERR_TIMEOUT;                 EText:'Request timeout interval has expired.'),
     (ECode: USBIO_ERR_INVALID_RECIPIENT;       EText:'Invalid recipient.'),
     (ECode: USBIO_ERR_INVALID_TYPE;            EText:'Invalid pipe type. Use IOCTRL for control pipe.'),
     (ECode: USBIO_ERR_INVALID_IOCTL;           EText:'Invalid IO control code.'),
     (ECode: USBIO_ERR_INVALID_DIRECTION;       EText:'Invalid direction of IO operation.'),
     (ECode: USBIO_ERR_TOO_MUCH_ISO_PACKETS;    EText:'Too much ISO packets. See registry key!'),
     (ECode: USBIO_ERR_POOL_EMPTY;              EText:'Request pool empty.'),
     (ECode: USBIO_ERR_PIPE_NOT_FOUND;          EText:'Pipe not found.'),
     (ECode: USBIO_ERR_INVALID_ISO_PACKET;      EText:'Invalid ISO packet. Offset + Length > Buffer Size!'),
     (ECode: USBIO_ERR_OUT_OF_ADDRESS_SPACE;    EText:'Out of address space.'),
     (ECode: USBIO_ERR_INTERFACE_NOT_FOUND;     EText:'Interface not found.'),
     (ECode: USBIO_ERR_INVALID_DEVICE_STATE;    EText:'Invalid device state (stopped or power down).'),
     (ECode: USBIO_ERR_INVALID_PARAM;           EText:'Invalid parameter.'),
     (ECode: USBIO_ERR_DEMO_EXPIRED;            EText:'DEMO version has expired! You must reboot!'),
     (ECode: USBIO_ERR_INVALID_POWER_STATE;     EText:'Device is in invalid power state. Use D0.'),
     (ECode: USBIO_ERR_POWER_DOWN;              EText:'Requests cancelled while device goes power down.'),                                                 (ECode: USBIO_ERR_VERSION_MISMATCH;        EText:'API Version does not match.'),
     (ECode: USBIO_ERR_DEVICE_NOT_FOUND;        EText:'Device not found.'),
     (ECode: USBIO_ERR_DEVICE_NOT_OPEN;         EText:'Device not open'),
     (ECode: USBIO_ERR_NO_SUCH_DEVICE_INSTANCE; EText:'No such device instance. Use a different device number.'),
     (ECode: USBIO_ERR_INVALID_FUNCTION_PARAM;  EText:'An invalid parameter was passed.'),
     (ECode: USBIO_ERR_SET_CONFIGURATION_FAILED; EText:'Set configuration failed. Configure one interface only.'),
     (ECode: USBIO_ERR_VID_RESTRICTION;         EText:'Light version restriction: Unsupported Vendor ID.'),
     (ECode: USBIO_ERR_ISO_RESTRICTION;         EText:'Light version restriction: ISO pipes are not supported.'),
     (ECode: USBIO_ERR_BULK_RESTRICTION;        EText:'Light version restriction: BULK pipes are not supported.'),
     (ECode: USBIO_ERR_EP0_RESTRICTION;         EText:'Light version restriction: EP0 requests are not fully supported.'),
     (ECode: USBIO_ERR_PIPE_RESTRICTION;        EText:'Light version restriction: Too many pipes or pipe type not supported.'),
     (ECode: USBIO_ERR_PIPE_SIZE_RESTRICTION;   EText:'Light version restriction: Maximum FIFO size exceeded.')
     );

var
  i                : DWORD;
  found            : boolean;
  msgbuffer        : PCHAR;
begin
  found:=false;
  Result := 'Unknown error Code.';
  for i := 1 to size do
    if ErrorCode = ErrorCodeTable[i].ECode then
    begin
      Result:=ErrorCodeTable[i].EText;
      found:=true;
      break;
    end;
  if not(found) then
    if FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_IGNORE_INSERTS,
         nil, ErrorCode, LANG_NEUTRAL or (SUBLANG_DEFAULT shl 10),
         PCHAR(@MsgBuffer), 0, nil)<>0 then result:=msgbuffer;
  Result:='Error code '+IntToHex(ErrorCode, 8)+': '+Result;
end;


end.


