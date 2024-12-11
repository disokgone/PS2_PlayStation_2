unit USBIO_I;

interface

uses Windows;

{***********************************************************************

* Module:         usbio_i.h
* Long name:      USBIO Driver Interface
* Description:    Defines the interface (API) of the USBIO driver
*
* Runtime Env.: Win32
* Author(s): Guenter Hildebrandt, Thomas Fr鐬lich
* Company: Thesycon GmbH, Ilmenau

*********************************************************************** }

// 
// Define the API version number. 
// This will be incremented if changes are made. 
//
// Applications should check if the driver supports the
// required API version using IOCTL_USBIO_GET_DRIVER_INFO.
//
// current API version: 1.41


const
  USBIO_API_VERSION                    = DWORD($0141);

// build in (default) GUID for the interface
const
  USBIO_IID_STR	                       = '{325ddf96-938c-11d3-9e34-0080c82727f4}';
  // 此 GUID 與 NAPLINK.EXE 所用的值相同, 不須更改 !
  USBIO_IID_STR_W         : widestring = USBIO_IID_STR;
  USBIO_IID               : TGUID      = USBIO_IID_STR;

type USHORT                            = word;

//
// Error Codes
//
const
  USBIO_ERR_SUCCESS                    = DWORD($00000000);
  USBIO_ERR_CRC                        = DWORD($E0000001);
  USBIO_ERR_BTSTUFF                    = DWORD($E0000002);
  USBIO_ERR_DATA_TOGGLE_MISMATCH       = DWORD($E0000003);
  USBIO_ERR_STALL_PID                  = DWORD($E0000004);
  USBIO_ERR_DEV_NOT_RESPONDING         = DWORD($E0000005);
  USBIO_ERR_PID_CHECK_FAILURE          = DWORD($E0000006);
  USBIO_ERR_UNEXPECTED_PID             = DWORD($E0000007);
  USBIO_ERR_DATA_OVERRUN               = DWORD($E0000008);
  USBIO_ERR_DATA_UNDERRUN              = DWORD($E0000009);
  USBIO_ERR_RESERVED1                  = DWORD($E000000A);
  USBIO_ERR_RESERVED2                  = DWORD($E000000B);
  USBIO_ERR_BUFFER_OVERRUN             = DWORD($E000000C);
  USBIO_ERR_BUFFER_UNDERRUN            = DWORD($E000000D);
  USBIO_ERR_NOT_ACCESSED               = DWORD($E000000F);
  USBIO_ERR_FIFO                       = DWORD($E0000010);
  USBIO_ERR_ENDPOINT_HALTED            = DWORD($E0000030);
  USBIO_ERR_NO_MEMORY                  = DWORD($E0000100);
  USBIO_ERR_INVALID_URB_FUNCTION       = DWORD($E0000200);
  USBIO_ERR_INVALID_PARAMETER          = DWORD($E0000300);
  USBIO_ERR_ERROR_BUSY                 = DWORD($E0000400);
  USBIO_ERR_REQUEST_FAILED             = DWORD($E0000500);
  USBIO_ERR_INVALID_PIPE_HANDLE        = DWORD($E0000600);
  USBIO_ERR_NO_BANDWIDTH               = DWORD($E0000700);
  USBIO_ERR_INTERNAL_HC_ERROR          = DWORD($E0000800);
  USBIO_ERR_ERROR_SHORT_TRANSFER       = DWORD($E0000900);
  USBIO_ERR_BAD_START_FRAME            = DWORD($E0000A00);
  USBIO_ERR_ISOCH_REQUEST_FAILED       = DWORD($E0000B00);
  USBIO_ERR_FRAME_CONTROL_OWNED        = DWORD($E0000C00);
  USBIO_ERR_FRAME_CONTROL_NOT_OWNED    = DWORD($E0000D00);

  USBIO_ERR_CANCELED                   = DWORD($E0010000);
  USBIO_ERR_CANCELING                  = DWORD($E0020000);

  USBIO_ERR_FAILED                     = DWORD($E0001000);
  USBIO_ERR_INVALID_INBUFFER           = DWORD($E0001001);
  USBIO_ERR_INVALID_OUTBUFFER          = DWORD($E0001002);
  USBIO_ERR_OUT_OF_MEMORY              = DWORD($E0001003);
  USBIO_ERR_PENDING_REQUESTS           = DWORD($E0001004);
  USBIO_ERR_ALREADY_CONFIGURED         = DWORD($E0001005);
  USBIO_ERR_NOT_CONFIGURED             = DWORD($E0001006);
  USBIO_ERR_OPEN_PIPES                 = DWORD($E0001007);
  USBIO_ERR_ALREADY_BOUND              = DWORD($E0001008);
  USBIO_ERR_NOT_BOUND                  = DWORD($E0001009);
  USBIO_ERR_DEVICE_NOT_PRESENT         = DWORD($E000100A);
  USBIO_ERR_CONTROL_NOT_SUPPORTED      = DWORD($E000100B);
  USBIO_ERR_TIMEOUT                    = DWORD($E000100C);
  USBIO_ERR_INVALID_RECIPIENT          = DWORD($E000100D);
  USBIO_ERR_INVALID_TYPE               = DWORD($E000100E);
  USBIO_ERR_INVALID_IOCTL              = DWORD($E000100F);
  USBIO_ERR_INVALID_DIRECTION          = DWORD($E0001010);
  USBIO_ERR_TOO_MUCH_ISO_PACKETS       = DWORD($E0001011);
  USBIO_ERR_POOL_EMPTY                 = DWORD($E0001012);
  USBIO_ERR_PIPE_NOT_FOUND             = DWORD($E0001013);
  USBIO_ERR_INVALID_ISO_PACKET         = DWORD($E0001014);
  USBIO_ERR_OUT_OF_ADDRESS_SPACE       = DWORD($E0001015);
  USBIO_ERR_INTERFACE_NOT_FOUND        = DWORD($E0001016);
  USBIO_ERR_INVALID_DEVICE_STATE       = DWORD($E0001017);
  USBIO_ERR_INVALID_PARAM              = DWORD($E0001018);
  USBIO_ERR_DEMO_EXPIRED               = DWORD($E0001019);
  USBIO_ERR_INVALID_POWER_STATE        = DWORD($E000101A);
  USBIO_ERR_POWER_DOWN                 = DWORD($E000101B);
  USBIO_ERR_VERSION_MISMATCH           = DWORD($E000101C);
  USBIO_ERR_SET_CONFIGURATION_FAILED	 = DWORD($E000101D);

  USBIO_ERR_VID_RESTRICTION            = DWORD($E0001080);
  USBIO_ERR_ISO_RESTRICTION            = DWORD($E0001081);
  USBIO_ERR_BULK_RESTRICTION           = DWORD($E0001082);
  USBIO_ERR_EP0_RESTRICTION            = DWORD($E0001083);
  USBIO_ERR_PIPE_RESTRICTION           = DWORD($E0001084);
  USBIO_ERR_PIPE_SIZE_RESTRICTION      = DWORD($E0001085);

  USBIO_ERR_DEVICE_NOT_FOUND           = DWORD($E0001100);
  USBIO_ERR_DEVICE_NOT_OPEN            = DWORD($E0001102);
  USBIO_ERR_NO_SUCH_DEVICE_INSTANCE    = DWORD($E0001104);
  USBIO_ERR_INVALID_FUNCTION_PARAM     = DWORD($E0001105);


//
// IOCTL codes.
// Note that function codes 0-2047 are reserved for Microsoft, and
// 2048-4095 are reserved for customers.
//

  IOCTL_USBIO_GET_DESCRIPTOR           = DWORD($80942006);
  IOCTL_USBIO_SET_DESCRIPTOR           = DWORD($80942009); 
  IOCTL_USBIO_SET_FEATURE              = DWORD($8094200C); 
  IOCTL_USBIO_CLEAR_FEATURE            = DWORD($80942010); 
  IOCTL_USBIO_GET_STATUS               = DWORD($80942014); 
  IOCTL_USBIO_GET_CONFIGURATION        = DWORD($80942018); 
  IOCTL_USBIO_GET_INTERFACE            = DWORD($8094201C); 
  IOCTL_USBIO_STORE_CONFIG_DESCRIPTOR  = DWORD($80942020); 
  IOCTL_USBIO_SET_CONFIGURATION        = DWORD($80942024); 
  IOCTL_USBIO_UNCONFIGURE_DEVICE       = DWORD($80942028); 
  IOCTL_USBIO_SET_INTERFACE            = DWORD($8094202C);

  IOCTL_USBIO_CLASS_OR_VENDOR_IN_REQUEST         = DWORD($80942032);
  IOCTL_USBIO_CLASS_OR_VENDOR_OUT_REQUEST        = DWORD($80942035); 
  IOCTL_USBIO_GET_DEVICE_PARAMETERS    = DWORD($8094203C); 
  IOCTL_USBIO_SET_DEVICE_PARAMETERS    = DWORD($80942040); 
  IOCTL_USBIO_GET_CONFIGURATION_INFO   = DWORD($80942050); 
  IOCTL_USBIO_RESET_DEVICE             = DWORD($80942054); 
  IOCTL_USBIO_GET_CURRENT_FRAME_NUMBER = DWORD($80942058);
  IOCTL_USBIO_SET_DEVICE_POWER_STATE   = DWORD($8094205C);
  IOCTL_USBIO_GET_DEVICE_POWER_STATE   = DWORD($80942060);
  IOCTL_USBIO_GET_DRIVER_INFO          = DWORD($8094206C); 
  IOCTL_USBIO_CYCLE_PORT               = DWORD($80942070);

  IOCTL_USBIO_BIND_PIPE                = DWORD($80942078);
  IOCTL_USBIO_UNBIND_PIPE              = DWORD($8094207C);
  IOCTL_USBIO_RESET_PIPE               = DWORD($80942080); 
  IOCTL_USBIO_ABORT_PIPE               = DWORD($80942084); 
  IOCTL_USBIO_GET_PIPE_PARAMETERS      = DWORD($8094208C);
  IOCTL_USBIO_SET_PIPE_PARAMETERS      = DWORD($80942090); 
  IOCTL_USBIO_PIPE_CONTROL_TRANSFER_IN = DWORD($809420A2); 
  IOCTL_USBIO_PIPE_CONTROL_TRANSFER_OUT= DWORD($809420A5); 
  USBIO_RESET_DEVICE_ON_CLOSE          = DWORD($00000001);
  USBIO_UNCONFIGURE_ON_CLOSE           = DWORD($00000002);
  USBIO_ENABLE_REMOTE_WAKEUP           = DWORD($00000004);
  USBIO_SHORT_TRANSFER_OK              = DWORD($00010000);
  USBIO_START_TRANSFER_ASAP            = DWORD($00020000);
  USBIO_MAX_INTERFACES                 = DWORD(32);
  USBIO_MAX_PIPES                      = DWORD(32);


{$MINENUMSIZE 4}   // enum type constants should be longwords
type
  USBIO_PIPE_TYPE                      = (
    PipeTypeControl,
    PipeTypeIsochronous,
    PipeTypeBulk,
    PipeTypeInterrupt);

type
  USBIO_REQUEST_RECIPIENT              = (
    RecipientDevice,
    RecipientInterface,
    RecipientEndpoint,
    RecipientOther);

type
  USBIO_REQUEST_TYPE                   = (
    UsbioRequestDummy_0,                       // =0
    RequestTypeClass,
    RequestTypeVendor);

type
  USBIO_DEVICE_POWER_STATE             = (
    DevicePowerStateD0,
    DevicePowerStateD1,
    DevicePowerStateD2,
    DevicePowerStateD3);


type
  USBIO_DESCRIPTOR_REQUEST =
  packed record
    Recipient                          : USBIO_REQUEST_RECIPIENT;
    DescriptorType                     : UCHAR;
    DescriptorIndex                    : UCHAR;
    LanguageId                         : USHORT;
  end;
  PUSBIO_DESCRIPTOR_REQUEST            = ^USBIO_DESCRIPTOR_REQUEST;


type
  USBIO_FEATURE_REQUEST =
  packed record
    Recipient                          : USBIO_REQUEST_RECIPIENT;
    FeatureSelector                    : USHORT;
    Index                              : USHORT;
  end;
  PUSBIO_FEATURE_REQUEST               = ^USBIO_FEATURE_REQUEST;


type
  USBIO_STATUS_REQUEST =
  packed record
    Recipient                          : USBIO_REQUEST_RECIPIENT;
    Index                              : USHORT;
  end;
  PUSBIO_STATUS_REQUEST                = ^USBIO_STATUS_REQUEST;


type
  USBIO_STATUS_REQUEST_DATA =
  packed record
    Status                             : USHORT;
  end;
  PUSBIO_STATUS_REQUEST_DATA           = ^USBIO_STATUS_REQUEST_DATA;


type
  USBIO_GET_CONFIGURATION_DATA =
  packed record
    ConfigurationValue                 : UCHAR;
  end;
  PUSBIO_GET_CONFIGURATION_DATA        = ^USBIO_GET_CONFIGURATION_DATA;


type
  USBIO_GET_INTERFACE =
  packed record
    _Interface                         : USHORT;       //in c++ Interface
  end;
  PUSBIO_GET_INTERFACE                 = ^USBIO_GET_INTERFACE;


type
  USBIO_GET_INTERFACE_DATA =
  packed record
    AlternateSetting                   : UCHAR;
  end;
  PUSBIO_GET_INTERFACE_DATA            = ^USBIO_GET_INTERFACE_DATA;


type
  USBIO_INTERFACE_SETTING =
  packed record
    InterfaceIndex                     : USHORT;
    AlternateSettingIndex              : USHORT;
    MaximumTransferSize                : ULONG;
  end;
  PUSBIO_INTERFACE_SETTING             = ^USBIO_INTERFACE_SETTING;


type
  USBIO_SET_CONFIGURATION =
  packed record
    ConfigurationIndex                 : USHORT;
    NbOfInterfaces                     : USHORT;
    InterfaceList                      : array[0..(USBIO_MAX_INTERFACES-1)]
                                           of USBIO_INTERFACE_SETTING;
  end;
  PUSBIO_SET_CONFIGURATION             = ^USBIO_SET_CONFIGURATION;


type
  USBIO_CLASS_OR_VENDOR_REQUEST =
  packed record
    Flags                              : ULONG;
    _Type                              : USBIO_REQUEST_TYPE;
    Recipient                          : USBIO_REQUEST_RECIPIENT;
    RequestTypeReservedBits            : UCHAR;
    Request                            : UCHAR;
    Value                              : USHORT;
    Index                              : USHORT;
  end;
  PUSBIO_CLASS_OR_VENDOR_REQUEST       = ^USBIO_CLASS_OR_VENDOR_REQUEST;


type
  USBIO_DEVICE_PARAMETERS =
  packed record
    Options                            : ULONG;
    RequestTimeout                     : ULONG;
  end;
  PUSBIO_DEVICE_PARAMETERS             = ^USBIO_DEVICE_PARAMETERS;


type
  USBIO_INTERFACE_CONFIGURATION_INFO =
  packed record
    InterfaceNumber                    : UCHAR;
    AlternateSetting                   : UCHAR;
    _Class                             : UCHAR;
    SubClass                           : UCHAR;
    Protocol                           : UCHAR;
    NumberOfPipes                      : UCHAR;
    reserved1                          : UCHAR;
    reserved2                          : UCHAR;
  end;
  PUSBIO_INTERFACE_CONFIGURATION_INFO  = ^USBIO_INTERFACE_CONFIGURATION_INFO;


type
  USBIO_PIPE_CONFIGURATION_INFO =
  packed record
    PipeType                           : USBIO_PIPE_TYPE;
    MaximumTransferSize                : ULONG;
    MaximumPacketSize                  : USHORT;
    EndpointAddress                    : UCHAR;
    Interval                           : UCHAR;
    InterfaceNumber                    : UCHAR;
    reserved1                          : UCHAR;
    reserved2                          : UCHAR;
    reserved3                          : UCHAR;
  end;
  PUSBIO_PIPE_CONFIGURATION_INFO       = ^USBIO_PIPE_CONFIGURATION_INFO;


type
  USBIO_CONFIGURATION_INFO =
  packed record
    NbOfInterfaces                     : ULONG;
    NbOfPipes                          : ULONG;
    InterfaceInfo                      : Array[0..USBIO_MAX_INTERFACES-1]
                                           of USBIO_INTERFACE_CONFIGURATION_INFO;
    PipeInfo                           : Array[0..USBIO_MAX_PIPES-1]
                                           of USBIO_PIPE_CONFIGURATION_INFO;
  end;
  PUSBIO_CONFIGURATION_INFO            = ^USBIO_CONFIGURATION_INFO;


type
  USBIO_FRAME_NUMBER =
  packed record
    FrameNumber                        : ULONG;
  end;
  PUSBIO_FRAME_NUMBER = ^USBIO_FRAME_NUMBER;


type
  USBIO_DEVICE_POWER =
  packed record
    DevicePowerState                   : USBIO_DEVICE_POWER_STATE;
  end;
  PUSBIO_DEVICE_POWER                  = ^USBIO_DEVICE_POWER;


type
  USBIO_DRIVER_INFO =
  packed record
    APIVersion                         : USHORT;
    DriverVersion                      : USHORT;
    DriverBuildNumber                  : ULONG;
    Flags                              : ULONG;
  end;
  PUSBIO_DRIVER_INFO                   = ^USBIO_DRIVER_INFO;


const
  USBIO_INFOFLAG_CHECKED_BUILD         : longword = $00000010;
  USBIO_INFOFLAG_DEMO_VERSION          : longword = $00000020;


type
  USBIO_BIND_PIPE =
  packed record
    EndpointAddress                    : UCHAR;
  end;
  PUSBIO_BIND_PIPE                     = ^USBIO_BIND_PIPE;


type
  USBIO_PIPE_PARAMETERS =
  packed record
    Flags                              : ULONG;
  end;
  PUSBIO_PIPE_PARAMETERS               = ^USBIO_PIPE_PARAMETERS;


type
  USBIO_PIPE_CONTROL_TRANSFER =
  packed record
    Flags                              : ULONG;
    SetupPacket                        : Array[0..8-1] of UCHAR;
  end;
  PUSBIO_PIPE_CONTROL_TRANSFER         = ^USBIO_PIPE_CONTROL_TRANSFER;



//
// Isochronous Transfers
//
// The data buffer passed to ReadFile/WriteFile must contain a
// predefined header that describes the size and location of the
// packets to be transferred. The USBIO_ISO_TRANSFER_HEADER consists
// of a fixed size part USBIO_ISO_TRANSFER and a variable size array
// of USBIO_ISO_PACKET descriptors.
//

type
  USBIO_ISO_TRANSFER =
  packed record
    NumberOfPackets                    : ULONG;
    Flags                              : ULONG;
    StartFrame                         : ULONG;
    ErrorCount                         : ULONG;
  end;
  PUSBIO_ISO_TRANSFER                  = ^USBIO_ISO_TRANSFER;


type
  USBIO_ISO_PACKET =
  packed record
    Offset                             : ULONG;
    Length                             : ULONG;
    Status                             : ULONG;
  end;
  PUSBIO_ISO_PACKET                    = ^USBIO_ISO_PACKET;


type
  USBIO_ISO_TRANSFER_HEADER =
  packed record
    IsoTransfer                        : USBIO_ISO_TRANSFER;
    IsoPacket                          : Array[0..1-1] of USBIO_ISO_PACKET;
  end;
  PUSBIO_ISO_TRANSFER_HEADER           = ^USBIO_ISO_TRANSFER_HEADER;

//
// Define the device type value. Note that values used by Microsoft
// are in the range 0-32767, and 32768-65535 are reserved for use
// by customers.
//

const
  FILE_DEVICE_USBIO                    = DWORD($8094);

const
  _USBIO_IOCTL_BASE                    = DWORD($800);

implementation

end.
