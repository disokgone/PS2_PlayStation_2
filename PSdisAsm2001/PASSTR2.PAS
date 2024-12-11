unit Passtr2;

{$R-}  {$H-}

interface

uses SysUtils;

type
  PPasString2 = ^TPasString2;
  TPasString2 = class(TObject)
  private
    FpSort: Pointer;    { 2 byte 一組作為 pList 的 index }
    FpList: Pointer;    { 4 byte 一組作為指到記憶體中的字串指標 }
    FpKey: Pointer;     { 4 byte 一組是一個使用者設定數值 }
    FpStr:  PChar;      { 指到記憶體中的一堆 Pascal 字串 }
    FpTail: Pointer;    { 指到記憶體中的一堆 Pascal 字串末端 }
    FMaxCount: Integer;
    FMaxMem: Integer;
    FCount: Integer;
    FKeyValue: Integer;
    FSortLoc: Integer;  { 上次排序值 }
    LastResult: Integer;        { 此自字串比較結果 }
    FSorted: Boolean;
    FcaseSensitive: Boolean;
  protected
    procedure cmpStr(s1, s2: PChar);
    procedure DelThis(ndx: Integer);
    function Get(Index: Integer): PChar;
    function GetCaseSense: Boolean;
    function GetCount: Integer;
    function GetKeyValue: Integer;
    function GetSorted: Boolean;
    function GetSortLoc: Integer;
    function PasStrQuickFind(s: PChar): Integer;
    procedure Put(Index: Integer; s: PChar);
    procedure SetKeyValue(KeyValue: Integer);
  public
    procedure Clear;
    constructor Create;         { 程式初始時呼叫, 使用者請勿呼叫 }
    procedure Delete(Index: Integer);           { 刪除後全體上移 }
    procedure Free;                             { 釋放所有記憶體 }
    procedure Insert(Index: Integer; S: PChar; KeyVal: Integer);
    procedure StrMove(OldIndex, NewIndex: Integer); { 如有排序 => 本程序無效 }
    procedure Setup(MaxCount, MaxMemSize: Integer; xSort, xCase: Boolean);
    function Where(s: PChar): Integer;          { 找尋此字串適合位置 }
    property Count: Integer read GetCount;
    property SortLoc: Integer read GetSortLoc;
    property KeyValue: Integer read GetKeyValue write SetKeyValue;
    property Sorted: Boolean read GetSorted;
    property caseSensitive: Boolean read GetCaseSense;
    property Strings[Index: Integer]: PChar read Get write Put; default;
  end;

implementation

procedure TPasString2.Clear;
begin                                   { 假設已經 Created }
     FillChar(FpSort^, FMaxCount shl 1, $FF);
     FillChar(FpList^, FMaxCount shl 2, 0);
     FillChar(FpKey^, FMaxCount shl 2, 0);
     FillChar(FpStr^, FMaxMem, 0);      { 全清成 0 }
     FCount := 0;
     FSortLoc := 0;
     FpTail := FpStr;
end;

procedure TPasString2.cmpStr(s1, s2: PChar);
begin
     if FcaseSensitive then LastResult := StrComp(s1, s2)    { 要分大小寫 }
     else LastResult := StrIComp(s1, s2)     { 不分大小寫 }
end;

constructor TPasString2.Create;
begin
     inherited;
     FMaxCount := 0;
end;

procedure TPasString2.Delete(Index: Integer); assembler;        { 刪去某字串 }
asm     { 傳入 -> EAX = pSelf 物件本身的指標
               -> EDX = Index (從 0 算起)
          返回 : 無 }
        PUSH    EBX
        MOV     EBX,EAX         { EAX = Self 物件本身的指標 }
        CMP     [EBX].FSorted, 0
        JZ      @@notSort00
{ 如須排序, 則取排序後的順序刪去字串 }
        MOV     [EBX].FSortLoc, EDX     { 保存此次被操作的序號 }
        MOV     EAX,EDX
        MOV     EDX, [EBX].FpSort       { EDX = FpSort }
        MOV     ECX, [EBX].FCount
        LEA     EDX, [EDX + EAX*2]      { 取排序列 }
        SUB     ECX,EAX
        MOVZX   EAX, WORD PTR [EDX]     { = index }
        DEC     ECX
        PUSH    EAX                     { = 排序後的順序 }
        SHL     ECX,1
        LEA     EAX, EDX+2
        CALL    MOVE            { MOVE(src, dest, count) 刪去此值 }
        POP     EDX
        MOV     EAX,EDX
{ 內值大於 EAX 者皆須減一 }
        PUSH    EDI
        MOV     EDI, [EBX].FpSort
        MOV     ECX, [EBX].FCount
@@rptDec:
        SCASW
        JA     @@noDec
        DEC     WORD PTR [EDI-2]
@@noDec:
        LOOP    @@rptDec
        MOV     WORD PTR [EDI-2], $FFFF
        POP     EDI
@@notSort00:
        MOV     EAX,EBX
        CALL    DelThis         { 刪去此一字串 }
        POP     EBX
end;

procedure TPasString2.DelThis(ndx: Integer); assembler;
asm     { 傳入 -> EAX = pSelf 物件本身的指標
               -> EDX = 欲刪字串在 pList 之 index 位置 }
        PUSH    EBX
        MOV     EBX,EAX
        MOV     EAX,EDX
        MOV     EDX, [EBX].FpList
        MOV     ECX, [EDX + EAX*4]      { 取得該字串指標 }
        PUSH    EAX                     { 保存 ndx }
        JCXZ    @@IsNull01              { 無字串可刪 }
{ Step 1: 刪掉該字串 }
        PUSH    ECX                     { 保存 pStr }
        PUSH    ECX
        MOV     EAX, ECX
        CALL    StrLen                  { EAX = 字串長度 }
        POP     ECX
        MOV     EDX,ECX                 { = 該字串頭端 }
        INC     EAX
        PUSH    EAX                     { 保存 (Len(pStr)+1) }
        ADD     EAX,ECX                 { = 該字串尾端 }
        MOV     ECX, [EBX].FpTail
        SUB     ECX,EAX                 { = 剩餘該搬的長度 }
        CALL    MOVE                    { MOVE(src, dest, count) 刪去此字串 }
{ Step 2: 修正 pList, 只要指標值大於 pStr 者, 一律減 (Len(pStr)+1) }
        POP     EDX                     { 取回 (Len(pStr)+1) }
        SUB     [EBX].FpTail, EDX       { = pTail - (Len(Str)+1) }
        POP     EAX                     { 取回 pStr }
        PUSH    EDI
        MOV     ECX, [EBX].FMaxCount
        MOV     EDI, [EBX].FpList
@@nxtSubx:
        SCASD
        JAE     @@IsLessPtr
        SUB     [EDI-4], EDX
@@IsLessPtr:
        LOOP    @@nxtSubx
        POP     EDI
@@IsNull01:
{ Step 3: 刪掉該指標 }
        DEC     [EBX].FCount
        MOV     ECX, [EBX].FpList
        POP     EAX                     { 取回 ndx }
        LEA     EDX, [ECX + EAX*4]
        MOV     ECX, [EBX].FCount
        PUSH    EAX
        SUB     ECX,EAX
        LEA     EAX,EDX+4
        SHL     ECX,2
        PUSH    ECX
        CALL    MOVE                    { MOVE(src, dest, count) 刪去此指標 }
        MOV     EDX, [EBX].FpList
        MOV     ECX, [EBX].FCount
        MOV     DWORD PTR [EDX + ECX*4], 0
{ Step 4: 刪除該鍵值 }
        MOV     EDX, [EBX].FpKey
        POP     ECX                     { 取回應覆蓋長度 }
        POP     EAX                     { 取回 ndx }
        LEA     EDX, [EDX + EAX*4]
        LEA     EAX,EDX+4
        CALL    MOVE                    { MOVE(src, dest, count) 刪去此鍵值 }
        POP     EBX
end;

procedure TPasString2.Free;             { 釋放所有記憶體 }
begin
     Freemem(FpStr);
     Freemem(FpKey);
     Freemem(FpList);
     Freemem(FpSort);
     Freemem(Pointer(Self));
end;

function TPasString2.Get(Index: Integer): PChar; assembler;
asm     { 傳入 -> EAX = pSelf 物件本身的指標
               -> EDX = Index 從 0 算起 !! 未檢查 index 是否合法 !!
               -> ECX = 放字串的空間 (系統傳來)
          返回 : 無 }
        PUSH    EBX
        PUSH    ECX
        MOV     EBX,EAX
        MOV     EAX,EDX
        MOV     ECX, [EBX].FpSort
        MOV     EDX, [EBX].FpList
        CMP     [EBX].FSorted, 0
        JZ      @@noSort
        MOVZX   EAX, WORD PTR [ECX + EAX*2]     { 取排序後的順序為 Index }
        CMP     AX, $FFFF
        JZ      @@ISnil
@@noSort:
        MOV     ECX, [EBX].FpKey
        MOV     ECX, [ECX + EAX*4]
        MOV     [EBX].FKeyValue, ECX    { 傳回其鍵值 }
        MOV     EAX, [EDX + EAX*4]      { 依此 index 取字串 }
        OR      EAX,EAX
        JZ      @@ISnil
        MOVZX   ECX,BYTE PTR [EAX]
        JMP     @@notNil
@@ISnil:
        XOR     EDX,EDX
        MOV     EAX, [EBX].FpTail
        MOV     ECX,EDX
        MOV     [EAX],EDX
@@notNil:
        POP     EDX                     { 傳回字串指標 : EAX }
        POP     EBX
end;

function TPasString2.GetCaseSense: Boolean;
begin
     Result := FcaseSensitive;  { T: 字串要分大小寫, F: 不分 }
end;

function TPasString2.GetCount: Integer;
begin
     Result := FCount;          { 傳回現有字串數 }
end;

function TPasString2.GetKeyValue: Integer;
begin
     Result := FKeyValue;       { 傳回鍵值 }
end;

function TPasString2.GetSorted: Boolean;
begin
     Result := FSorted;         { T: 字串要排序, F: 不排序 }
end;

function TPasString2.GetSortLoc: Integer;
begin
     Result := FSortLoc;        { 傳回排序位置 }
end;

procedure TPasString2.Insert(Index: Integer; S: PChar; KeyVal: Integer);
assembler; var
   ndx, pStr: Integer;
asm     { 傳入 -> EAX = pSelf 物件本身的指標
          EDX = 欲插入位置 (排序時無效, 此值即被忽略)
          ECX = 欲插入字串 (char * 格式)
          [EBP+8] = 欲設定鍵值 Key-Value
          返回 <- EAX = 無意義 }
        PUSH    EBX                     { 本程式中 EBX = Self 物件指標 }
        MOV     EBX, EAX
        MOV     ndx,EDX
        MOV     pStr, ECX
{ Step 1: 如須排序, 則先找此字串之排序適當位置 }
        CMP     [EBX].FSorted, 0
        JZ      @@notSort01
        MOV     EDX,ECX                 { 以此字串排序 }
        MOV     EAX,EBX
        CALL    PasStrQuickFind         { 傳回 EAX = 最適插入位置 }
        MOV     [EBX].FSortLoc, EAX     { 保存其排序位置 }
        MOV     ECX, [EBX].FMaxCount
        MOV     EDX, [EBX].FpSort
        SUB     ECX,EAX
        LEA     EAX, [EDX + EAX*2]      { 取排序列 }
        DEC     ECX                     { 把排序列下移 }
        LEA     EDX, EAX+2
        SHL     ECX,1
        PUSH    EAX
        CALL    MOVE                    { MOVE(src, dest, count) 騰出空位 }
        MOV     EAX, [EBX].FCount       { 新增字串一定放在字串列最後面 }
        POP     EDX
        MOV     ndx, EAX
        MOV     [EDX], AX               { pSort[排序 index] = Count }
@@notSort01:
{ Step 2: 將此字串塞到字串堆尾端 (index = AX) }
        MOV     EAX, [EBX].FpTail
        MOV     EDX, pStr
        CALL    StrCopy                 { StrPCopy(dest:PChar; src:PChar); }
        MOV     ECX, [EBX].FMaxCount
        MOV     EAX, ndx
        DEC     ECX
        MOV     EDX, [EBX].FpList       { pList 字串指標列下移 }
        SUB     ECX,EAX
        LEA     EAX, [EDX + EAX*4]
        SHL     ECX,2
        LEA     EDX,EAX+4
        CALL    MOVE                    { MOVE(src, dest, count) 騰出空位 }
        MOV     EAX, ndx
        MOV     ECX, [EBX].FpList
        MOV     EDX, [EBX].FpTail
        MOV     [ECX + EAX*4],EDX       { pList[ndx] = pTail }
        MOV     ECX, [EBX].FpKey
        MOV     EDX, [EBP+8]
        MOV     [ECX + EAX*4],EDX       { pKey[ndx] = Key-Value }
        MOV     EAX, pStr
        CALL    StrLen
        INC     EAX                     { pTail += (Len(Str)+1) }
        ADD     [EBX].FpTail, EAX       { 設立新尾端 }
        INC     [EBX].FCount
        POP     EBX
end;

procedure TPasString2.StrMove(OldIndex, NewIndex: Integer); assembler;
var
   nOld, nNew, nNew2, tmp, tmp2: Integer;
asm     { 傳入 -> EAX = pSelf 物件本身的指標
               -> EDX = OldIndex (從 0 算起)
               -> ECX = NewIndex }
        PUSH    EBX
        PUSH    ESI
        MOV     EBX,EAX
        CMP     [EBX].FSorted, 0
        JNZ     @@smDone        { 排序無效 }
        MOV     nNew, ECX
        CMP     ECX,EDX
        MOV     nOld, EDX
        JZ      @@smDone        { 原位不須動 }
        MOV     EDX,ECX
        CALL    DelThis;        { DelThis(nNew) }
        MOV     EAX, nOld
        MOV     ECX, nNew
        SUB     ECX,EAX         { = nNew - nOld }
        MOV     EDX, [EBX].FpList
        JS      @@OldIsLarge    { if nOld > nNew then goto => }
{ 此處 nOld < nNew, 資料移到後方 }
        MOV     ESI,EAX         { = nOld }
        LEA     EAX, [EDX + EAX*4]
        DEC     ECX
        MOV     nNew, EAX       { 保存 @pList[nOld] }
        MOV     EDX, [EAX]      { 保存 pList[nOld] }
        SHL     ECX,2           { = (nNew - nOld - 1) << 2 }
        MOV     tmp, EDX
        PUSH    ECX
        LEA     EDX, EAX+4
        ADD     nNew, ECX       { = @pList[nNew-1] }
        XCHG    EAX,EDX
        CALL    MOVE            { 整批前移 }
        MOV     EDX, [EBX].FpKey
        LEA     EAX, [EDX + ESI*4]
        POP     ECX             { = (nNew - nOld - 1) << 2 }
        MOV     nNew2, EAX      { 保存 @pKey[nOld] }
        MOV     EDX, [EAX]
        MOV     tmp2, EDX       { 保存 pKey[nOld] }
        LEA     EDX, EAX+4
        ADD     nNew2, ECX      { = @pKey[nNew-1] }
        XCHG    EAX,EDX
        CALL    MOVE            { 整批前移 }
        JMP     @@smOK
@@OldIsLarge:
{ 此處 nNew < nOld, 資料移到前方 }
        DEC     EAX
        NEG     ECX
        MOV     ESI,EAX         { = nOld - 1 }
        LEA     EAX, [EDX + EAX*4]
        DEC     ECX
        MOV     EDX, [EAX]      { 保存 pList[nOld] 到 tmp }
        MOV     tmp, EDX
        SHL     ECX,2           { = (nOld - nNew - 1) << 2 }
        MOV     EAX, nNew
        PUSH    ECX
        MOV     tmp2, EAX       { 保存 nNew => tmp2 }
        MOV     EDX, [EBX].FpList
        LEA     EAX, [EDX + EAX*4]      { = @pList[nNew] }
        MOV     nNew, EAX       { 保存 @(pList[nNew]) }
        LEA     EDX,EAX+4
        CALL    MOVE            { 整批後移 }
        MOV     EDX, [EBX].FpKey
        POP     ECX             { = (nOld - nNew - 1) << 2 }
        LEA     EAX, [EDX + ESI*4]
        MOV     EDX, [EAX]      { 保存 pKey[nOld] }
        MOV     EAX, tmp2
        MOV     tmp2, EDX
        MOV     EDX, [EBX].FpKey
        LEA     EAX, [EDX + EAX*4]      { = @pKey[nNew] }
        MOV     nNew2, EAX      { 保存 @(pKey[nNew]) }
        LEA     EDX,EAX+4
        CALL    MOVE            { 整批後移 }
@@smOK:
        MOV     EAX, nNew
        MOV     EDX, tmp
        MOV     [EAX], EDX      { pList[nNew(-1)] = pList[nOld] }
        MOV     EAX, nNew2
        MOV     EDX, tmp2
        MOV     [EAX], EDX      { pKey[nNew(-1)] = pKey[nOld] }
@@smDone:
        POP     ESI
        POP     EBX
end;

procedure TPasString2.Put(Index: Integer; s: PChar); assembler;
var
   i, indx, pS: Integer;        { Put 主程式使用 }
   saveDiff, savePtr: Integer;  { @@ReplaceString 使用 }
asm     { 傳入 -> EAX = pSelf 物件本身的指標
               -> EDX = Index 從 0 算起
               -> ECX = 指到 S 字串的指標
               -> FKeyValue = 使用者預先設定好的鍵值 }
        PUSH    EBX
        MOV     EBX,EAX
        MOV     indx, EDX       { 保存 index & S }
        MOV     pS, ECX
{ Step 1: 如須排序, 則先暫時隱藏此舊字串, 防止新舊字串混淆, 舊字串會被刪除 }
        CMP     [EBX].FSorted, 0
        JZ      @@notSort02
        MOV     EAX,EDX
        CALL    @@delSortN              { 傳回此被刪的 index }
        MOV     EDX,EAX
        CMP     AX, $FFFF
        MOV     indx, EDX               { 保存 index }
        JNZ     @@notSort02
  { 要排序, 若 pSort[index] = -1 (隱藏) .. 此位置無字串, 加入新字串 }
        MOV     EDX,[EBX].FCount        { 新增字串一定放在字串列最後面 }
        INC     [EBX].FCount
@@notSort02:
{ Step 2: 如有舊字串, 則取代之 }
        MOV     ECX, [EBX].FpList
        CMP     DWORD PTR [ECX + EDX*4], 0      { pList[indx] = 0 ? }
        JZ      @@isEmpty       { = nil !! }
  { 此位置已有字串, 須取代之, 增入新字串作業一併完成 ! }
        MOV     EAX,EDX
        MOV     EDX, pS
        CALL    @@ReplaceString { EBX = pSelf, EAX = indx, EDX = String }
        JMP     @@mkSort
@@isEmpty:
  { 此位置無字串, 直接增加新字串 }
        MOV     EDX, pS         { src = String }
        MOV     EAX, [EBX].FpTail       { dest = Space for NewStr }
        CALL    StrCopy         { StrCopy(*dest, *src) }
        CALL    StrLen
        MOV     ECX, EAX        { ECX = length(src)+1 }
        MOV     EAX, indx
        ADD     [EBX].FpTail, ECX       { 設立新尾端 }
        MOV     ECX, [EBX].FpList
        INC     [EBX].FCount
        MOV     [ECX + EAX*4], EDX      { 修正 pList[indx] }
{ Step 3: 如須排序, 則為此新字串找好位置 }
@@mkSort:
        CMP     [EBX].FSorted, 0
        JZ      @@notSort03     { 若不須排序, 則已完成 }
  { 要 SORT ! 依字串順序安排各字串位置 }
        MOV     EAX,EBX                 { 呼叫物件時須放 EAX = 該物件指標 }
        MOV     EDX, pS
        CALL    PasStrQuickFind         { do quick find(s: PChar) }
  { EAX = 最接近的 FpSort index 值 }
        MOV     [EBX].FSortLoc, EAX     { 保存其排序位置 }
  { 不管字串比較結果如何, 於此位置插入 ! }
        MOV     ECX, [EBX].FMaxCount
        MOV     EDX, [EBX].FpSort
        SUB     ECX,EAX
        LEA     EAX,[EDX + EAX*2]
        DEC     ECX
        PUSH    EAX
        SHL     ECX,1           { ECX = count to move, 2 byte 一組 }
        LEA     EDX,EAX + 2
        CALL    MOVE            { MOVE(src, dest, count) 騰出空間 }
        MOV     EDX, indx
        POP     EAX
        MOV     [EAX], DX       { 設定 FpSort[Nearest Index] = indx }
@@notSort03:
        MOV     EAX, indx
        MOV     EDX, [EBX].FpKey
        MOV     ECX, [EBX].FKeyValue
        MOV     [EDX + EAX*4], ECX      { 設定鍵值 }
        POP     EBX
        JMP     @@PutExit

{ 刪去 pSort[EAX] 值, 傳回此值 }
@@delSortN:
        PUSH    ESI
        PUSH    EDI
        MOV     ECX, [EBX].FpSort
        LEA     EDI,[ECX + EAX*2]
        XCHG    DX, [EDI]       { 暫存到 DX }
        LEA     ESI, EDI+2
        MOV     ECX, [EBX].FCount
        DEC     ECX
        SUB     ECX, EAX
        MOV     EAX,ECX
        SHR     ECX,1
        AND     AL,1
        REP     MOVSD
        MOV     CL,AL
        REP     MOVSW           { 覆蓋此值 }
        MOV     WORD PTR [EDI], $FFFF   { 清為空值 }
        MOVZX   EAX,DX
        POP     EDI
        POP     ESI
        RET

{ 於此位置, 直接貼上新字串, 舊字串將被蓋掉消失 !! (Put 專用內部子函式) }
@@ReplaceString:                { EBX = pSelf, EAX = indx, EDX = String }
        PUSH    ESI
        PUSH    EDI
        PUSH    EDX             { 保存 NewStr (short string 格式) }
        MOV     EDI, [EBX].FpList
        MOV     CL, [EDX]
        MOV     ESI, [EDI + EAX*4]      { ESI = pList[index] = OldStr }
        MOV     savePtr, ESI
        MOVZX   EAX, BYTE PTR [ESI]
        SUB     CL, AL                  { CL = NewLen - OldLen }
        MOV     EDI, ESI                { EDI = pList[index] = OldStr }
        MOVSX   ECX,CL
        INC     ESI                     { 此略過 1 byte 字串長度 }
        MOV     saveDiff, ECX           { 暫存此差值 }
        ADD     EAX,ESI                 { src = 舊字串尾端 }
        MOVZX   EDX, BYTE PTR [EDX]
        MOV     ECX, [EBX].FpTail
        ADD     EDX,ESI                 { dest = 新字串尾端 }
        SUB     ECX,EAX                 { count = Tail - src }
        CALL    MOVE                    { MOVE(src, dest, count) 調整字串空間 }
{ 空間已清出來了 }
        MOV     EDX, EDI                { 暫存 }
        POP     ESI                     { ESI = NewStr }
        CLD                             { copy 此字串 }
        LODSB
        MOVZX   ECX,AL
        STOSB
        SHR     ECX,2
        AND     AL,3
        REP     MOVSD
        MOV     CL,AL
        REP     MOVSB
{ 雖然拷貝到相同位置, 但長度已變, 故須修正整個 pList }
        MOV     EAX,EDX
        MOV     EDX, saveDiff
        MOV     EDI,[EBX].FpList
        ADD     [EBX].FpTail, EDX       { pTail += 新舊字串長度差值 }
        MOV     ECX, [EBX].FMaxCount    { 長度 : 整個 pList }
@@loop01:
        SCASD                           { 位於 OldStr 之後的字串都須 }
        JAE     @@noChange
        ADD     [EDI-4], EDX            { 加上此差值 }
@@noChange:
        LOOP    @@loop01
        POP     EDI
        POP     ESI
        RET
@@PutExit:
end;

function TPasString2.PasStrQuickFind(s: PChar): Integer; assembler;
var                             { 找此字串之適當位置, 須在排序模式下 }
   hidden, mv, pStr: Integer;
asm     { 傳入 -> EAX = pSelf 物件本身的指標
               -> EDX = short String
          返回 : 最接近的字串 FpSort[index] 值 }
        PUSH    EBX
        PUSH    ESI
        PUSH    EDI
        MOV     EBX, EAX        { = Self }
        MOV     [EBX].LastResult, 99    { 預設此自字串比較結果 = 沒找到 }
        MOV     pStr, EDX       { 暫存此字串指標 }
        MOV     EAX, -1
        MOV     hidden, EAX     { 上一個隱藏字串 hidden = $FFFF }
        XOR     ESI,ESI         { 左值 LV = 0 }
{ *Step 1: 初始 LV, RV, & MIDDLE POINT }
        MOV     EDI, [EBX].FCount
        OR      EDI,EDI
        MOV     mv, EDI
        JZ      @@SRHDONE       { 沒字串好找的 ! }
        DEC     EDI             { 右值 RV = Count-1 }
        JZ      @@LastCmp       { 只有一個值 }
@@TO_NEXT:
        MOV     EAX,ESI
        ADD     EAX,EDI
        SHR     EAX,1           { 中值 MV = (LV+RV)/2 }
        MOV     mv,EAX
{ *Step 2: IF (LV == RV) OR (LV > RV) THEN 搜尋結束 }
        CMP     ESI,EDI
        JA      @@SRHDONE
@@tryNext:
        MOV     EDX, [EBX].FpSort
        MOVZX   ECX,WORD PTR [EDX + EAX*2]      { 取字串 index }
        CMP     CX,$FFFF
        JNZ     @@Tocmp
  { 是故意隱藏的字串, 忽略此字串, 看下一個 ! }
@@tryOne:
        CMP     EAX,EDI         { if Mid = RV then (已檢查至右值) }
        JZ      @@SRHDONE       { .. this is the nearest }
        CMP     EAX, hidden     { 老是遇到此隱藏字串, 可能當機, 故脫出 ! }
        JZ      @@SRHDONE       { for exit endless loop }
        MOV     hidden, EAX
        INC     EAX
        CMP     EAX, [EBX].FCount       { 至少找遍整堆字串 ! }
        JB      @@tryNext
        JMP     @@SRHDONE
@@Tocmp:
        CALL    @@doCmp
        OR      EAX,EAX
{ *Step 3: IF (*THIS == *MIDDLE) => FOUND ! }
        JZ      @@SRHDONE
{ #STEP 4: IF (*THIS > *MIDDLE) => Take LARGER side for next compare }
        JS      @@TAKSML
{ Here takes LARGER side for next compare }
        CMP     ESI, mv         { 若左值 = 中值 則結束 }
        JZ      @@LVEQMID
        MOV     ESI, mv         { NEW LV = OLD Mid }
        JMP     @@TO_NEXT
{ (LV OVERLAP WITH MIDDLE) & (*THIS > *MIDDLE) }
@@LVEQMID:
        INC     mv
        MOV     ESI, mv         { 令新左值 = 舊中值 }
        CMP     ESI,EDI
        JBE     @@TO_NEXT
        JMP     @@SRHDONE

{ 只有一個值 }
@@LastCmp:
        XOR     ECX, ECX
        MOV     mv, ECX
        CALL    @@doCmp
        CMP     AL, 1
        JL      @@SRHDONE
        INC     mv
        JMP     @@SRHDONE
@@doCmp:
{ LV = ESI, MID = ECX, RV = EDI }
        MOV     EAX, [EBX].FpList
        MOV     ECX,[EAX + ECX*4]       { ECX = *middle 字串指標 }
        MOV     EDX, pStr               { EDX = *this }
        MOV     EAX,EBX
        CALL    cmpStr
        MOV     EAX,[EBX].LastResult    { 取此自字串比較結果 }
        RET
{ #STEP 5: IF (*THIS < *MIDDLE) => Take SMALLER side for next compare }
{ Here takes SMALLER side for next compare }
@@TAKSML:
        CMP     EDI, mv         { 若右值 = 中值 則結束 }
        JZ      @@SRHDONE
        MOV     EDI, mv         { KEEPS LV, NEW RV = OLD MID }
        JMP     @@TO_NEXT
@@SRHDONE:                      { 此中值為最接近值 }
        MOV     EAX, mv
        POP     EDI
        POP     ESI
        POP     EBX
end;

procedure TPasString2.SetKeyValue(KeyValue: Integer);
begin
     FKeyValue := KeyValue;     { 設定鍵值 }
end;

procedure TPasString2.Setup(MaxCount, MaxMemSize: Integer; xSort, xCase: Boolean);
begin                                   { 初始化借記憶體 }
     FCount := 0;                       { 現有字串數 = 0 }
     FSorted := xSort;                  { 字串是否須排序 }
     FcaseSensitive := xCase;           { 搜尋, 排序是否須分大小寫 }
     FMaxCount := MaxCount;             { 最大允許字串數 }
     FMaxMem := MaxMemSize;             { 最大取用記憶體數 }
     GetMem(FpSort, MaxCount shl 1);    { 假設輸入值一切合法且記憶體夠 }
     GetMem(FpList, MaxCount shl 2);
     GetMem(FpKey, MaxCount shl 2);
     GetMem(FpStr, MaxMemSize);
     Clear;                             { 全清除 }
end;

function TPasString2.Where(s: PChar): Integer; { 找尋此字串適合位置 }
var
   loc: Integer;
   pi: ^Integer;
begin
     loc := PasStrQuickFind(s);
     pi := Pointer(Integer(FpKey) + (loc shl 2));
     FKeyValue := pi^;
     Result := loc;
end;

initialization
  TPasString2.Create;                   { 程式載入後立即建構此物件 }
{ finalization }
end.
