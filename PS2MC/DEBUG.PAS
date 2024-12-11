procedure debugCLS(TextAttr: byte; Comma: Char);  external;
procedure debugDec(Dec: Dword; Count, Signed: Byte);  external;
procedure debugDump(Y: Integer; pAddr: Pointer; Count: Integer);  external;
procedure debugHex(Hex: Dword; Count: Byte);  external;
procedure debugStr(X, Y: Integer; Str: String);  external;
  { Show a String at Monochrome screen }
