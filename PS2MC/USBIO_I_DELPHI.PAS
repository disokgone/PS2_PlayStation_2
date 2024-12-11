unit usbio_i_delphi;

{************************************************************************
 *
 *  Description:   declaration of needed types, constants and
 *                 functions from setupapi.dll ( refer to setupapi.h in C )
 *
 *  Runtime Env.:  Win32, Part of UsbioLib
 *  Author(s):     Thomas Fröhlich
 *  Company:       Thesycon GmbH, Ilmenau
 ************************************************************************}



interface
uses Windows;

type
  HDEVINFO                             = Pointer;

function SetupDiGetClassDevsA(
                   ClassGuid           : PGUID;
                   Enumerator          : PCHAR;
                   hwndParent          : HWND;
                   Flags               : DWORD
                   ): HDEVINFO; stdcall; external 'setupapi.dll';

//SetupDiGetClassDevsA(
//    IN LPGUID ClassGuid,  OPTIONAL
//    IN PCSTR  Enumerator, OPTIONAL
//    IN HWND   hwndParent, OPTIONAL
//    IN DWORD  Flags
//    );

const
DIGCF_DEFAULT                          = DWORD($00000001);
DIGCF_PRESENT                          = DWORD($00000002);
DIGCF_ALLCLASSES                       = DWORD($00000004);
DIGCF_PROFILE                          = DWORD($00000008);
DIGCF_DEVICEINTERFACE                  = DWORD($00000010);

type
  SP_DEVICE_INTERFACE_DETAIL_DATA_A =
  packed record
                   cbSize              : DWORD;
                   DevicePath          : array [0..0]of char;
  end;
  PSP_DEVICE_INTERFACE_DETAIL_DATA_A   = ^SP_DEVICE_INTERFACE_DETAIL_DATA_A;


//typedef struct _SP_DEVICE_INTERFACE_DETAIL_DATA_A {
//    DWORD  cbSize;
//    CHAR  DevicePath[ANYSIZE_ARRAY];
//} SP_DEVICE_INTERFACE_DETAIL_DATA_A, *PSP_DEVICE_INTERFACE_DETAIL_DATA_A;



function SetupDiDestroyDeviceInfoList(
                   DeviceInfoSet       : HDEVINFO
                   ): boolean; stdcall; external 'setupapi.dll';


//SetupDiDestroyDeviceInfoList(
//    IN HDEVINFO DeviceInfoSet
//    );


type
  SP_DEVINFO_DATA =
  packed record
    cbSize                             : DWORD;
    ClassGuid                          : TGUID;
    DevInst                            : DWORD;
    Reserved                           : DWORD;
  end;
  PSP_DEVINFO_DATA                     = ^SP_DEVINFO_DATA;
//typedef struct _SP_DEVINFO_DATA {
//    DWORD cbSize;
//    GUID  ClassGuid;
//    DWORD DevInst;    // DEVINST handle
//    DWORD Reserved;
//} SP_DEVINFO_DATA, *PSP_DEVINFO_DATA;





type
  SP_DEVICE_INTERFACE_DATA =
  packed record
    cbSize                             : DWORD;
    InterfaceClassGuid                 : TGUID;
    Flags                              : DWORD;
    Reserved                           : DWORD;
  end;
  PSP_DEVICE_INTERFACE_DATA            = ^SP_DEVICE_INTERFACE_DATA;

//typedef struct _SP_DEVICE_INTERFACE_DATA {
//    DWORD cbSize;
//    GUID  InterfaceClassGuid;
//    DWORD Flags;
//    DWORD Reserved;
//} SP_DEVICE_INTERFACE_DATA, *PSP_DEVICE_INTERFACE_DATA;





function SetupDiEnumDeviceInterfaces(
                   DeviceInfoSet       : HDEVINFO;
                   DeviceInfoData      : PSP_DEVINFO_DATA;
                   InterfaceClassGuid  : PGUID;
                   MemberIndex         : DWORD;
                   DeviceInterfaceData : PSP_DEVICE_INTERFACE_DATA
                   ):boolean;stdcall; external 'setupapi.dll';
//SetupDiEnumDeviceInterfaces(
//    IN  HDEVINFO                  DeviceInfoSet,
//    IN  PSP_DEVINFO_DATA          DeviceInfoData,     OPTIONAL
//    IN  LPGUID                    InterfaceClassGuid,
//    IN  DWORD                     MemberIndex,
//    OUT PSP_DEVICE_INTERFACE_DATA DeviceInterfaceData
//    );



function SetupDiGetDeviceInterfaceDetailA(
                   DeviceInfoSet                 : HDEVINFO;
                   DeviceInterfaceData           : PSP_DEVICE_INTERFACE_DATA;
                   DeviceInterfaceDetailData     : PSP_DEVICE_INTERFACE_DETAIL_DATA_A;
                   DeviceInterfaceDetailDataSize : DWORD;
                   RequiredSize                  : PDWORD;
                   DeviceInfoData                : PSP_DEVINFO_DATA
                   ):boolean;stdcall; external 'setupapi.dll';


//SetupDiGetDeviceInterfaceDetailA(
//    IN  HDEVINFO                           DeviceInfoSet,
//    IN  PSP_DEVICE_INTERFACE_DATA          DeviceInterfaceData,
//    OUT PSP_DEVICE_INTERFACE_DETAIL_DATA_A DeviceInterfaceDetailData,     OPTIONAL
//    IN  DWORD                              DeviceInterfaceDetailDataSize,
//    OUT PDWORD                             RequiredSize,                  OPTIONAL
//    OUT PSP_DEVINFO_DATA                   DeviceInfoData                 OPTIONAL
//    );




implementation

end.
