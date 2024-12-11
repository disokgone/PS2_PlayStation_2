{***************************************************    
 *                                                  
 *  Module: usbspec.h                               
 *  Long name: USB Specification 1.0                
 *  Description:                                    
 *                                                  
 *  Runtime Env.:                                   
 *  Author(s): Guenter Hildebrandt, Thomas Fröhlich 
 *  Company: Thesycon GmbH, Ilmenau                 
 ***************************************************}
unit USBSPEC;
interface

uses
  Windows;


type USHORT = word;

// 
// descriptor types 
// 
const
  USB_DEVICE_DESCRIPTOR_TYPE           = DWORD($01);
  USB_CONFIGURATION_DESCRIPTOR_TYPE    = DWORD($02);
  USB_STRING_DESCRIPTOR_TYPE           = DWORD($03);
  USB_INTERFACE_DESCRIPTOR_TYPE        = DWORD($04);
  USB_ENDPOINT_DESCRIPTOR_TYPE         = DWORD($05);
  USB_HID_DESCRIPTOR_TYPE              = DWORD($21);


type
  USB_DEVICE_DESCRIPTOR = 
  packed record
    bLength                            : UCHAR;
    bDescriptorType                    : UCHAR;
    bcdUSB                             : USHORT;
    bDeviceClass                       : UCHAR;
    bDeviceSubClass                    : UCHAR;
    bDeviceProtocol                    : UCHAR;
    bMaxPacketSize0                    : UCHAR;
    idVendor                           : USHORT;
    idProduct                          : USHORT;
    bcdDevice                          : USHORT;
    iManufacturer                      : UCHAR;
    iProduct                           : UCHAR;
    iSerialNumber                      : UCHAR;
    bNumConfigurations                 : UCHAR;
  end {_USB_DEVICE_DESCRIPTOR};
  PUSB_DEVICE_DESCRIPTOR               = ^USB_DEVICE_DESCRIPTOR;


type
  USB_CONFIGURATION_DESCRIPTOR = 
  packed record
    bLength                            : UCHAR;
    bDescriptorType                    : UCHAR;
    wTotalLength                       : USHORT;
    bNumInterfaces                     : UCHAR;
    bConfigurationValue                : UCHAR;
    iConfiguration                     : UCHAR;
    bmAttributes                       : UCHAR;
    MaxPower                           : UCHAR;
  end {_USB_CONFIGURATION_DESCRIPTOR};
  PUSB_CONFIGURATION_DESCRIPTOR        = ^USB_CONFIGURATION_DESCRIPTOR;


type
  USB_INTERFACE_DESCRIPTOR = 
  packed record
    bLength                            : UCHAR;
    bDescriptorType                    : UCHAR;
    bInterfaceNumber                   : UCHAR;
    bAlternateSetting                  : UCHAR;
    bNumEndpoints                      : UCHAR;
    bInterfaceClass                    : UCHAR;
    bInterfaceSubClass                 : UCHAR;
    bInterfaceProtocol                 : UCHAR;
    iInterface                         : UCHAR;
  end {_USB_INTERFACE_DESCRIPTOR};
  PUSB_INTERFACE_DESCRIPTOR            = ^USB_INTERFACE_DESCRIPTOR;


type
  USB_ENDPOINT_DESCRIPTOR = 
  packed record
    bLength                            : UCHAR;
    bDescriptorType                    : UCHAR;
    bEndpointAddress                   : UCHAR;
    bmAttributes                       : UCHAR;
    wMaxPacketSize                     : USHORT;
    bInterval                          : UCHAR;
  end {_USB_ENDPOINT_DESCRIPTOR};
  PUSB_ENDPOINT_DESCRIPTOR             = ^USB_ENDPOINT_DESCRIPTOR;


type
  USB_STRING_DESCRIPTOR = 
  packed record
    bLength                            : UCHAR;
    bDescriptorType                    : UCHAR;
    bString                            : Array[0..1-1] of WCHAR; 
  end {_USB_STRING_DESCRIPTOR};
  PUSB_STRING_DESCRIPTOR               = ^USB_STRING_DESCRIPTOR;


type
  USB_HID_DESCRIPTOR = 
  packed record
    bLength                            : UCHAR;
    bDescriptorType                    : UCHAR;
    bcdHID                             : USHORT;
    bCountryCode                       : UCHAR;
    bNumDescriptors                    : UCHAR;
    bDescriptorType1                   : UCHAR;
    wDescriptorLength1                 : USHORT;
  end {_USB_HID_DESCRIPTOR};
  PUSB_HID_DESCRIPTOR                  = ^USB_HID_DESCRIPTOR;


type
  USB_COMMON_DESCRIPTOR = 
  packed record
    bLength                            : UCHAR;
    bDescriptorType                    : UCHAR;
  end {_USB_COMMON_DESCRIPTOR};
  PUSB_COMMON_DESCRIPTOR               = ^USB_COMMON_DESCRIPTOR;


// 
// Audio Descriptors 
// 


const
  AUDIO_CS_INTERFACE_TYPE              = DWORD($24);
  AUDIO_CS_ENDPOINT_TYPE               = DWORD($25);
  AUDIO_CS_SUBTYPE_HEADER              = DWORD($01);
  AUDIO_CS_SUBTYPE_INPUT_TERMINAL      = DWORD($02);
  AUDIO_CS_SUBTYPE_OUTPUT_TERMINAL     = DWORD($03);
//AUDIO_CS_SUBTYPE_MIXER_UNIT          = DWORD($04);
//AUDIO_CS_SUBTYPE_SELECTOR_UNIT       = DWORD($05);
  AUDIO_CS_SUBTYPE_FEATUR_UNIT         = DWORD($06);
  AUDIO_CS_SUBTYPE_PROCESSING_UNIT     = DWORD($07);
  AUDIO_CS_SUBTYPE_EXTENSION_UNIT      = DWORD($08);


type
  AUDIO_COMMON_INTERFACE_DESCRIPTOR = 
  packed record
    bLength                            : UCHAR;
    bDescriptorType                    : UCHAR;
    bDescriptorSubtypeType             : UCHAR;
  end {_AUDIO_COMMON_INTERFACE_DESCRIPTOR};
  PAUDIO_COMMON_INTERFACE_DESCRIPTOR   = ^AUDIO_COMMON_INTERFACE_DESCRIPTOR;


type
  AUDIO_INTERFACE_HEADER_DESCRIPTOR = 
  packed record
    bcdADC                             : USHORT;
    bTotalLength                       : USHORT;
    blnCollection                      : UCHAR;
/// baInterfaceNr                      : UCHAR;
  end {_AUDIO_INTERFACE_HEADER_DESCRIPTOR};
  PAUDIO_INTERFACE_HEADER_DESCRIPTOR   = ^AUDIO_INTERFACE_HEADER_DESCRIPTOR;


type
  AUDIO_INTERFACE_INPUT_TERMINAL_DESCRIPTOR = 
  packed record
    bTerminalId                        : UCHAR;
    wTerminalType                      : USHORT;
    bAssocTerminal                     : UCHAR;
    bNrChannels                        : UCHAR;
    wChannelConfig                     : USHORT;
    iChannelNames                      : UCHAR;
    iTerminal                          : UCHAR;
  end {_AUDIO_INTERFACE_INPUT_TERMINAL_DESCRIPTOR};
  PAUDIO_INTERFACE_INPUT_TERMINAL_DESCRIPTOR = ^AUDIO_INTERFACE_INPUT_TERMINAL_DESCRIPTOR;


type
  AUDIO_INTERFACE_OUTPUT_TERMINAL_DESCRIPTOR = 
  packed record
    bTerminalId                        : UCHAR;
    wTerminalType                      : USHORT;
    bAssocTerminal                     : UCHAR;
    bSourceID                          : UCHAR;
    iTerminal                          : UCHAR;
  end {_AUDIO_INTERFACE_OUTPUT_TERMINAL_DESCRIPTOR};
  PAUDIO_INTERFACE_OUTPUT_TERMINAL_DESCRIPTOR = ^AUDIO_INTERFACE_OUTPUT_TERMINAL_DESCRIPTOR;


type
  AUDIO_INTERFACE_FEATURE_UNIT_DESCRIPTOR = 
  packed record
    bUnitID                            : UCHAR;
    bSourceID                          : UCHAR;
    bControlSize                       : UCHAR;
//  bmaControls                        : UCHAR;
  end {_AUDIO_INTERFACE_FEATURE_UNIT_DESCRIPTOR};
  PAUDIO_INTERFACE_FEATURE_UNIT_DESCRIPTOR = ^AUDIO_INTERFACE_FEATURE_UNIT_DESCRIPTOR;


type
  AUDIO_INTERFACE_AS_GENERAL_DESCRIPTOR = 
  packed record
    bTerminalLink                      : UCHAR;
    bDelay                             : UCHAR;
    wFormatTag                         : USHORT;
  end {_AUDIO_INTERFACE_AS_GENERAL_DESCRIPTOR};
  PAUDIO_INTERFACE_AS_GENERAL_DESCRIPTOR = ^AUDIO_INTERFACE_AS_GENERAL_DESCRIPTOR;


type
  AUDIO_FORMAT_TYPE_I_DESCRIPTOR = 
  packed record
    bFormatType                        : UCHAR;
    bNrChannels                        : UCHAR;
    bSubframeSize                      : UCHAR;
    bBitResolution                     : UCHAR;
    bSamFreqType                       : UCHAR;
  end {_AUDIO_FORMAT_TYPE_I_DESCRIPTOR};
  PAUDIO_FORMAT_TYPE_I_DESCRIPTOR      = ^AUDIO_FORMAT_TYPE_I_DESCRIPTOR;


type
  AUDIO_CS_ENDPOINT_DESCRIPTOR = 
  packed record
    bLength                            : UCHAR;
    bDescriptorType                    : UCHAR;
    bDescriptorSubtypeType             : UCHAR;
    bmAttributes                       : UCHAR;
    bLockDelayUnits                    : UCHAR;
    wLockDelay                         : USHORT;
  end {_AUDIO_CS_ENDPOINT_DESCRIPTOR};
  PAUDIO_CS_ENDPOINT_DESCRIPTOR        = ^AUDIO_CS_ENDPOINT_DESCRIPTOR;


implementation

end.
