// Borland C++ Builder
// Copyright (c) 1995, 1999 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Passtr2.pas' rev: 5.00

#ifndef Passtr2HPP
#define Passtr2HPP

#pragma delphiheader begin
#pragma option push -w-
#pragma option push -Vx
#include <SysUtils.hpp>	// Pascal unit
#include <SysInit.hpp>	// Pascal unit
#include <System.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Passtr2
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TPasString2;
typedef TPasString2* *PPasString2;

class PASCALIMPLEMENTATION TPasString2 : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	void *FpSort;
	void *FpList;
	void *FpKey;
	char *FpStr;
	void *FpTail;
	int FMaxCount;
	int FMaxMem;
	int FCount;
	int FKeyValue;
	int FSortLoc;
	int LastResult;
	bool FSorted;
	bool FcaseSensitive;
	
protected:
	void __fastcall cmpStr(char * s1, char * s2);
	void __fastcall DelThis(int ndx);
	char * __fastcall Get(int Index);
	bool __fastcall GetCaseSense(void);
	int __fastcall GetCount(void);
	int __fastcall GetKeyValue(void);
	bool __fastcall GetSorted(void);
	int __fastcall GetSortLoc(void);
	int __fastcall PasStrQuickFind(char * s);
	void __fastcall Put(int Index, char * s);
	void __fastcall SetKeyValue(int KeyValue);
	
public:
	void __fastcall Clear(void);
	__fastcall TPasString2(void);
	void __fastcall Delete(int Index);
	HIDESBASE void __fastcall Free(void);
	void __fastcall Insert(int Index, char * S, int KeyVal);
	void __fastcall StrMove(int OldIndex, int NewIndex);
	void __fastcall Setup(int MaxCount, int MaxMemSize, bool xSort, bool xCase);
	int __fastcall Where(char * s);
	__property int Count = {read=GetCount, nodefault};
	__property int SortLoc = {read=GetSortLoc, nodefault};
	__property int KeyValue = {read=GetKeyValue, write=SetKeyValue, nodefault};
	__property bool Sorted = {read=GetSorted, nodefault};
	__property bool caseSensitive = {read=GetCaseSense, nodefault};
	__property char * Strings[int Index] = {read=Get, write=Put/*, default*/};
public:
	#pragma option push -w-inl
	/* TObject.Destroy */ inline __fastcall virtual ~TPasString2(void) { }
	#pragma option pop
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Passtr2 */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Passtr2;
#endif
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Passtr2
