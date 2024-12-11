function ReadDW(p: Pointer; loc: Integer): Integer; external;
function ReadInt(buf: PChar; index: Integer): Integer; external;
function SetDW(p: Pointer; loc, val: Integer): Integer; external;
procedure SetInt(buf: PChar; index: Integer; SrcVar:Integer); external;
function PtrAdd(p: Pointer; disp, siz: Integer): Pointer; external;

