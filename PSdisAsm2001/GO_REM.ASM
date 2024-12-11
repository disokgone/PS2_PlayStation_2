	.586p
	ifdef ??version
	if    ??version GT 500H
	.mmx
	endif
	endif
	model flat
	ifndef	??version
	?debug	macro
	endm
	endif
	?debug	S "D:\BCBS\PS2\GO_REM.cpp"
	?debug	T "D:\BCBS\PS2\GO_REM.cpp"
_TEXT	segment dword public use32 'CODE'
_TEXT	ends
_DATA	segment dword public use32 'DATA'
_DATA	ends
_BSS	segment dword public use32 'BSS'
_BSS	ends
 ?debug  C FB0C0100600000
DGROUP	group	_BSS,_DATA
_BSS	segment dword public use32 'BSS'
	align	4
_REMGO	label	dword
	db	4	dup(?)
	align	4
_rem	label	dword
	db	4	dup(?)
	align	4
_nowLine	label	dword
	db	4	dup(?)
	align	4
_rtmp	label	dword
	db	4	dup(?)
	align	4
_rtmp1	label	dword
	db	4	dup(?)
	align	4
_mstr	label	dword
	db	4	dup(?)
_BSS	ends
_DATA	segment dword public use32 'DATA'
@_$DCSF$@TREMGO@$bctr$qqrp18Classes@TComponent	segment virtual
	align	2
@@_$DCSF$@TREMGO@$bctr$qqrp18Classes@TComponent	label	dword
	dd	@@$xt$p6TREMGO
	dd	1029
	dd	-4
	dd	0
@_$DCSF$@TREMGO@$bctr$qqrp18Classes@TComponent	ends
_DATA	ends
_DATA	segment dword public use32 'DATA'
@_$ECTTF$@TREMGO@$bctr$qqrp18Classes@TComponent	segment virtual
	align	2
@@_$ECTTF$@TREMGO@$bctr$qqrp18Classes@TComponent	label	dword
	dd	0
	dd	-40
	dw	0
	dw	5
	dd	0
	dd	@@_$DCSF$@TREMGO@$bctr$qqrp18Classes@TComponent
@_$ECTTF$@TREMGO@$bctr$qqrp18Classes@TComponent	ends
_DATA	ends
_TEXT	segment dword public use32 'CODE'
@TREMGO@$bctr$qqrp18Classes@TComponent	segment virtual
	align	2
@@TREMGO@$bctr$qqrp18Classes@TComponent	proc	near
?live16385@0:
	push      ebp
	mov       ebp,esp
	add       esp,-48
	test      dl,dl
	mov       byte ptr [ebp-8],dl
	jle       short @1
	call      __ClassCreate
@1:
@2:
	mov       dword ptr [ebp-48],ecx
	mov       byte ptr [ebp-41],dl
	mov       dword ptr [ebp-4],eax
	mov       eax,offset @@_$ECTTF$@TREMGO@$bctr$qqrp18Classes@TComponent
	call      @__InitExceptBlockLDTC
	mov       word ptr [ebp-24],8
	mov       ecx,dword ptr [ebp-48]
	xor       edx,edx
	mov       eax,dword ptr [ebp-4]
	call      @@Forms@TForm@$bctr$qqrp18Classes@TComponent
	add       dword ptr [ebp-12],15
	mov       edx,dword ptr [ebp-40]
	mov       dword ptr fs:[0],edx
	mov       eax,dword ptr [ebp-4]
@4:
@3:
	mov       dl,byte ptr [ebp-41]
	test      dl,dl
	je        short @5
	call      __AfterConstruction
@5:
	mov       esp,ebp
	pop       ebp
	ret 
@@TREMGO@$bctr$qqrp18Classes@TComponent	endp
@TREMGO@$bctr$qqrp18Classes@TComponent	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@TREMGO@Btn2Click$qqrp14System@TObject	segment virtual
	align	2
@@TREMGO@Btn2Click$qqrp14System@TObject	proc	near
?live16390@0:
@6:
	push      ebp
	mov       ebp,esp
	add       esp,-8
	mov       dword ptr [ebp-8],edx
	mov       dword ptr [ebp-4],eax
	mov       eax,dword ptr [ebp-4]
	call      @@Forms@TCustomForm@Hide$qqrv
@7:
	pop       ecx
	pop       ecx
	pop       ebp
	ret 
@@TREMGO@Btn2Click$qqrp14System@TObject	endp
@TREMGO@Btn2Click$qqrp14System@TObject	ends
_TEXT	ends
_DATA	segment dword public use32 'DATA'
@_$DCUF$@TREMGO@chkEditCuts$qqrp14System@TObjectrus46System@%Set$t18Classes@Classes__1$iuc$0$iuc$6%	segment virtual
	align	2
@@_$DCUF$@TREMGO@chkEditCuts$qqrp14System@TObjectrus46System@%Set$t18Classes@Classes__1$iuc$0$iuc$6%	label	dword
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-4
	dd	0
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-8
	dd	0
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-12
	dd	0
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-16
	dd	0
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-20
	dd	0
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-24
	dd	0
@_$DCUF$@TREMGO@chkEditCuts$qqrp14System@TObjectrus46System@%Set$t18Classes@Classes__1$iuc$0$iuc$6%	ends
_DATA	ends
_DATA	segment dword public use32 'DATA'
@_$ECTVF$@TREMGO@chkEditCuts$qqrp14System@TObjectrus46System@%Set$t18Classes@Classes__1$iuc$0$iuc$6%	segment virtual
	align	2
@@_$ECTVF$@TREMGO@chkEditCuts$qqrp14System@TObjectrus46System@%Set$t18Classes@Classes__1$iuc$0$iuc$6%	label	dword
	dd	0
	dd	-60
	dw	0
	dw	5
	dd	0
	dd	@@_$DCUF$@TREMGO@chkEditCuts$qqrp14System@TObjectrus46System@%Set$t18Classes@Classes__1$iuc$0$iuc$6%
	dw	0
	dw	5
	dd	0
	dd	@@_$DCUF$@TREMGO@chkEditCuts$qqrp14System@TObjectrus46System@%Set$t18Classes@Classes__1$iuc$0$iuc$6%+16
	dw	0
	dw	5
	dd	0
	dd	@@_$DCUF$@TREMGO@chkEditCuts$qqrp14System@TObjectrus46System@%Set$t18Classes@Classes__1$iuc$0$iuc$6%+32
	dw	0
	dw	5
	dd	0
	dd	@@_$DCUF$@TREMGO@chkEditCuts$qqrp14System@TObjectrus46System@%Set$t18Classes@Classes__1$iuc$0$iuc$6%+48
	dw	0
	dw	5
	dd	0
	dd	@@_$DCUF$@TREMGO@chkEditCuts$qqrp14System@TObjectrus46System@%Set$t18Classes@Classes__1$iuc$0$iuc$6%+64
	dw	0
	dw	5
	dd	0
	dd	@@_$DCUF$@TREMGO@chkEditCuts$qqrp14System@TObjectrus46System@%Set$t18Classes@Classes__1$iuc$0$iuc$6%+80
@_$ECTVF$@TREMGO@chkEditCuts$qqrp14System@TObjectrus46System@%Set$t18Classes@Classes__1$iuc$0$iuc$6%	ends
_DATA	ends
_TEXT	segment dword public use32 'CODE'
@TREMGO@chkEditCuts$qqrp14System@TObjectrus46System@%Set$t18Classes@Classes__1$iuc$0$iuc$6%	segment virtual
	align	2
@@TREMGO@chkEditCuts$qqrp14System@TObjectrus46System@%Set$t18Classes@Classes__1$iuc$0$iuc$6%	proc	near
?live16391@0:
	push      ebp
	mov       ebp,esp
	add       esp,-84
	mov       dword ptr [ebp-72],ecx
	mov       dword ptr [ebp-68],edx
	mov       dword ptr [ebp-64],eax
@8:
	mov       eax,offset @@_$ECTVF$@TREMGO@chkEditCuts$qqrp14System@TObjectrus46System@%Set$t18Classes@Classes__1$iuc$0$iuc$6%
	call      @__InitExceptBlockLDTC
    	mov	 dword ptr [ebp-76], ecx    
	xor       edx,edx
	mov       dword ptr [ebp-84],edx
	mov       ecx,dword ptr [_rem]
	test      ecx,ecx
	jne       short @9
	mov       eax,dword ptr [ebp-64]
	call      @@TREMGO@initREM$qqrv
@9:
	mov       edx,dword ptr [ebp-64]
	mov       ecx,dword ptr [edx+728]
	mov       eax,dword ptr [ebp-68]
	cmp       ecx,eax
	jne       short @10
	mov       edx,dword ptr [ebp-64]
	mov       ecx,dword ptr [edx+728]
	mov       dword ptr [ebp-84],ecx
@10:
	mov       eax,dword ptr [ebp-64]
	mov       edx,dword ptr [eax+732]
	mov       ecx,dword ptr [ebp-68]
	cmp       edx,ecx
	jne       short @11
	mov       eax,dword ptr [ebp-64]
	mov       edx,dword ptr [eax+732]
	mov       dword ptr [ebp-84],edx
@11:
	mov       ecx,dword ptr [ebp-64]
	mov       eax,dword ptr [ecx+724]
	mov       edx,dword ptr [ebp-68]
	cmp       eax,edx
	jne       @12
	mov       ecx,dword ptr [ebp-72]
	cmp       word ptr [ecx],13
	jne       @12
	mov       word ptr [ebp-44],8
	xor       eax,eax
	mov       dword ptr [ebp-4],eax
	lea       edx,dword ptr [ebp-4]
	inc       dword ptr [ebp-32]
	mov       ecx,dword ptr [ebp-64]
	mov       eax,dword ptr [ecx+724]
	call      @@Controls@TControl@GetText$qqrv
	mov       edx,dword ptr [ebp-4]
	test      edx,edx
	je        short @13
	mov       ecx,dword ptr [ebp-4]
	jmp       short @14
@13:
	mov       ecx,offset s@
@14:
	push      ecx
	call      @@GetHex$qpc
	pop       ecx
	mov       edx,eax
	mov       ecx,dword ptr [_rtmp]
	mov       eax,dword ptr [ebp-64]
	call      @@TREMGO@Get_REM$qqripc
	dec       dword ptr [ebp-32]
	lea       eax,dword ptr [ebp-4]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	mov       word ptr [ebp-44],20
	lea       eax,dword ptr [ebp-8]
	mov       edx,dword ptr [_rtmp]
	call      @@System@AnsiString@$bctr$qqrpxc
	inc       dword ptr [ebp-32]
	mov       edx,dword ptr [eax]
	mov       eax,dword ptr [ebp-64]
	mov       eax,dword ptr [eax+728]
	call      @@Controls@TControl@SetText$qqrx17System@AnsiString
	dec       dword ptr [ebp-32]
	lea       eax,dword ptr [ebp-8]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	mov       ecx,dword ptr [ebp-64]
	mov       eax,dword ptr [ecx+728]
	mov       edx,dword ptr [eax]
	call      dword ptr [edx+176]
	mov       ecx,dword ptr [ebp-60]
	mov       dword ptr fs:[0],ecx
	jmp       @15
@12:
	mov       eax,dword ptr [ebp-84]
	test      eax,eax
	jne       short @16
	mov       edx,dword ptr [ebp-60]
	mov       dword ptr fs:[0],edx
	jmp       @15
@16:
	mov       ecx,dword ptr [ebp-72]
	cmp       word ptr [ecx],13
	jne       short @17
	xor       edx,edx
	mov       eax,dword ptr [ebp-64]
	call      @@TREMGO@SetOneREM$qqrp14System@TObject
@17:
	call      @@Clipbrd@Clipboard$qqrv
	mov       dword ptr [ebp-80],eax
	mov       ecx,dword ptr [ebp-76]
	cmp       ecx,2
	jne       @19
@18:
	mov       eax,dword ptr [ebp-72]
	mov       dx,word ptr [eax]
	sub       dx,67
	je        short @24
	sub       dx,19
	je        @23
	sub       dx,2
	je        short @22
	jmp       @20
@24:
	mov       word ptr [ebp-44],32
	xor       ecx,ecx
	mov       dword ptr [ebp-12],ecx
	lea       edx,dword ptr [ebp-12]
	inc       dword ptr [ebp-32]
	mov       eax,dword ptr [ebp-84]
	mov       ecx,dword ptr [eax]
	call      dword ptr [ecx+192]
	lea       edx,dword ptr [ebp-12]
	mov       eax,dword ptr [ebp-80]
	mov       edx,dword ptr [edx]
	call      @@Clipbrd@TClipboard@SetAsText$qqrx17System@AnsiString
	dec       dword ptr [ebp-32]
	lea       eax,dword ptr [ebp-12]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	jmp       @25
@22:
	mov       word ptr [ebp-44],44
	xor       ecx,ecx
	mov       dword ptr [ebp-16],ecx
	lea       edx,dword ptr [ebp-16]
	inc       dword ptr [ebp-32]
	mov       eax,dword ptr [ebp-84]
	mov       ecx,dword ptr [eax]
	call      dword ptr [ecx+192]
	lea       edx,dword ptr [ebp-16]
	mov       eax,dword ptr [ebp-80]
	mov       edx,dword ptr [edx]
	call      @@Clipbrd@TClipboard@SetAsText$qqrx17System@AnsiString
	dec       dword ptr [ebp-32]
	lea       eax,dword ptr [ebp-16]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	mov       word ptr [ebp-44],56
	mov       edx,offset s@+1
	lea       eax,dword ptr [ebp-20]
	call      @@System@AnsiString@$bctr$qqrpxc
	inc       dword ptr [ebp-32]
	mov       edx,dword ptr [eax]
	mov       eax,dword ptr [ebp-84]
	call      @@Controls@TControl@SetText$qqrx17System@AnsiString
	dec       dword ptr [ebp-32]
	lea       eax,dword ptr [ebp-20]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	jmp       short @25
@23:
	mov       word ptr [ebp-44],68
	xor       ecx,ecx
	mov       dword ptr [ebp-24],ecx
	lea       edx,dword ptr [ebp-24]
	inc       dword ptr [ebp-32]
	mov       eax,dword ptr [ebp-80]
	call      @@Clipbrd@TClipboard@GetAsText$qqrv
	lea       edx,dword ptr [ebp-24]
	mov       eax,dword ptr [ebp-84]
	mov       edx,dword ptr [edx]
	call      @@Stdctrls@TCustomEdit@SetSelText$qqrx17System@AnsiString
	dec       dword ptr [ebp-32]
	lea       eax,dword ptr [ebp-24]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
@20:
@21:
@25:
@19:
	mov       ecx,dword ptr [ebp-60]
	mov       dword ptr fs:[0],ecx
@26:
@15:
	mov       esp,ebp
	pop       ebp
	ret       4
@@TREMGO@chkEditCuts$qqrp14System@TObjectrus46System@%Set$t18Classes@Classes__1$iuc$0$iuc$6%	endp
@TREMGO@chkEditCuts$qqrp14System@TObjectrus46System@%Set$t18Classes@Classes__1$iuc$0$iuc$6%	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@TREMGO@DestAddrRem$qqrpc	segment virtual
	align	2
@@TREMGO@DestAddrRem$qqrpc	proc	near
?live16395@0:
@27:
	push      ebp
	mov       ebp,esp
	add       esp,-20
	mov       dword ptr [ebp-8],edx
	mov       dword ptr [ebp-4],eax
	mov       eax,dword ptr [ebp-8]
	mov       dword ptr [ebp-16],eax
	mov       edx,offset s@+2
	mov       eax,dword ptr [ebp-16]
	call      @@Sysutils@StrPos$qqrpxct1
	mov       dword ptr [ebp-20],eax
	mov       edx,dword ptr [ebp-8]
	mov       byte ptr [edx],0
	mov       ecx,dword ptr [ebp-16]
	mov       byte ptr [ecx+43],0
	mov       eax,dword ptr [ebp-20]
	test      eax,eax
	je        short @29
@30:
	mov       edx,dword ptr [ebp-20]
	push      edx
	call      @@GetHex$qpc
	pop       ecx
	mov       dword ptr [ebp-12],eax
	mov       ecx,dword ptr [_validHexLen]
	cmp       ecx,9
	jne       short @31
	mov       ecx,dword ptr [_temp2]
	mov       edx,dword ptr [ebp-12]
	mov       eax,dword ptr [ebp-4]
	call      @@TREMGO@Get_REM$qqripc
	mov       eax,dword ptr [_temp2]
	mov       dl,byte ptr [eax]
	test      dl,dl
	je        short @32
	mov       edx,dword ptr [_temp2]
	mov       eax,dword ptr [ebp-8]
	call      @@Sysutils@StrCopy$qqrpcpxc
	jmp       short @29
@32:
@31:
	mov       ecx,dword ptr [_validHexLen]
	test      ecx,ecx
	je        short @29
	mov       eax,dword ptr [ebp-20]
	mov       edx,dword ptr [_validHexLen]
	add       eax,edx
	mov       dword ptr [ebp-16],eax
	mov       edx,offset s@+4
	mov       eax,dword ptr [ebp-16]
	call      @@Sysutils@StrPos$qqrpxct1
	mov       dword ptr [ebp-20],eax
	mov       ecx,dword ptr [ebp-20]
	test      ecx,ecx
	jne       short @30
@35:
@29:
	mov       esp,ebp
	pop       ebp
	ret 
@@TREMGO@DestAddrRem$qqrpc	endp
@TREMGO@DestAddrRem$qqrpc	ends
_TEXT	ends
_DATA	segment dword public use32 'DATA'
@_$DCWF$@TREMGO@FastAddrToGo$qqrp14System@TObject	segment virtual
	align	2
@@_$DCWF$@TREMGO@FastAddrToGo$qqrp14System@TObject	label	dword
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-4
	dd	0
@_$DCWF$@TREMGO@FastAddrToGo$qqrp14System@TObject	ends
_DATA	ends
_DATA	segment dword public use32 'DATA'
@_$ECTXF$@TREMGO@FastAddrToGo$qqrp14System@TObject	segment virtual
	align	2
@@_$ECTXF$@TREMGO@FastAddrToGo$qqrp14System@TObject	label	dword
	dd	0
	dd	-40
	dw	0
	dw	5
	dd	0
	dd	@@_$DCWF$@TREMGO@FastAddrToGo$qqrp14System@TObject
@_$ECTXF$@TREMGO@FastAddrToGo$qqrp14System@TObject	ends
_DATA	ends
_TEXT	segment dword public use32 'CODE'
@TREMGO@FastAddrToGo$qqrp14System@TObject	segment virtual
	align	2
@@TREMGO@FastAddrToGo$qqrp14System@TObject	proc	near
?live16396@0:
@36:
	push      ebp
	mov       ebp,esp
	add       esp,-52
	mov       dword ptr [ebp-48],edx
	mov       dword ptr [ebp-44],eax
	mov       eax,offset @@_$ECTXF$@TREMGO@FastAddrToGo$qqrp14System@TObject
	call      @__InitExceptBlockLDTC
	mov       word ptr [ebp-24],8
	xor       edx,edx
	mov       dword ptr [ebp-4],edx
	lea       edx,dword ptr [ebp-4]
	inc       dword ptr [ebp-12]
	mov       eax,dword ptr [ebp-44]
	mov       eax,dword ptr [eax+732]
	mov       ecx,dword ptr [eax]
	call      dword ptr [ecx+192]
	mov       edx,dword ptr [ebp-4]
	test      edx,edx
	je        short @37
	mov       eax,dword ptr [ebp-4]
	jmp       short @38
@37:
	mov       eax,offset s@+6
@38:
	push      eax
	call      @@GetHex$qpc
	pop       ecx
	mov       dword ptr [ebp-52],eax
	dec       dword ptr [ebp-12]
	lea       eax,dword ptr [ebp-4]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	mov       ecx,dword ptr [_validHexLen]
	cmp       ecx,3
	jle       short @39
	mov       eax,dword ptr [ebp-52]
	mov       dword ptr [_TopAddr],eax
	mov       eax,dword ptr [ebp-44]
	call      @@Forms@TCustomForm@Hide$qqrv
@39:
	mov       edx,dword ptr [ebp-40]
	mov       dword ptr fs:[0],edx
@40:
	mov       esp,ebp
	pop       ebp
	ret 
@@TREMGO@FastAddrToGo$qqrp14System@TObject	endp
@TREMGO@FastAddrToGo$qqrp14System@TObject	ends
_TEXT	ends
_DATA	segment dword public use32 'DATA'
@_$DCYF$@TREMGO@FindRemStr$qqrp14System@TObject	segment virtual
	align	2
@@_$DCYF$@TREMGO@FindRemStr$qqrp14System@TObject	label	dword
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-4
	dd	0
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-8
	dd	0
@_$DCYF$@TREMGO@FindRemStr$qqrp14System@TObject	ends
_DATA	ends
_DATA	segment dword public use32 'DATA'
@_$ECTZF$@TREMGO@FindRemStr$qqrp14System@TObject	segment virtual
	align	2
@@_$ECTZF$@TREMGO@FindRemStr$qqrp14System@TObject	label	dword
	dd	0
	dd	-44
	dw	0
	dw	5
	dd	0
	dd	@@_$DCYF$@TREMGO@FindRemStr$qqrp14System@TObject
	dw	0
	dw	5
	dd	0
	dd	@@_$DCYF$@TREMGO@FindRemStr$qqrp14System@TObject+16
@_$ECTZF$@TREMGO@FindRemStr$qqrp14System@TObject	ends
_DATA	ends
_TEXT	segment dword public use32 'CODE'
@TREMGO@FindRemStr$qqrp14System@TObject	segment virtual
	align	2
@@TREMGO@FindRemStr$qqrp14System@TObject	proc	near
?live16399@0:
@41:
	push      ebp
	mov       ebp,esp
	add       esp,-64
	mov       dword ptr [ebp-52],edx
	mov       dword ptr [ebp-48],eax
	mov       eax,offset @@_$ECTZF$@TREMGO@FindRemStr$qqrp14System@TObject
	call      @__InitExceptBlockLDTC
	mov       word ptr [ebp-28],8
	xor       edx,edx
	mov       dword ptr [ebp-4],edx
	lea       edx,dword ptr [ebp-4]
	inc       dword ptr [ebp-16]
	mov       eax,dword ptr [ebp-48]
	mov       eax,dword ptr [eax+728]
	call      @@Controls@TControl@GetText$qqrv
	mov       edx,dword ptr [ebp-4]
	test      edx,edx
	je        short @42
	mov       edx,dword ptr [ebp-4]
	jmp       short @43
@42:
	mov       edx,offset s@+7
@43:
	mov       eax,dword ptr [_rtmp1]
	call      @@Sysutils@StrCopy$qqrpcpxc
	dec       dword ptr [ebp-16]
	lea       eax,dword ptr [ebp-4]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	mov       eax,dword ptr [_rtmp1]
	call      @@Sysutils@StrLen$qqrpxc
	cmp       eax,1
	jae       short @44
	push      0
	push      offset s@+37
	push      offset s@+8
	mov       eax,dword ptr [_REMGO]
	call      @@Controls@TWinControl@GetHandle$qqrv
	push      eax
	call      @MessageBoxA
	mov       edx,dword ptr [ebp-44]
	mov       dword ptr fs:[0],edx
	jmp       @45
@44:
	mov       dword ptr [ebp-56],200
	xor       ecx,ecx
	mov       dword ptr [ebp-60],ecx
	mov       eax,dword ptr [ebp-48]
	mov       eax,dword ptr [eax+732]
	mov       edx,dword ptr [eax]
	call      dword ptr [edx+204]
	mov       ecx,dword ptr [ebp-48]
	mov       eax,dword ptr [ecx+732]
	call      @@Controls@TControl@Hide$qqrv
	mov       eax,dword ptr [_rtmp1]
	call      @@Sysutils@StrUpper$qqrpc
	mov       edx,dword ptr [ebp-56]
	test      edx,edx
	jle       @47
@46:
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@GetCount$qqrv
	mov       edx,dword ptr [ebp-60]
	cmp       eax,edx
	jle       @49
	mov       edx,dword ptr [ebp-60]
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@Get$qqri
	mov       edx,eax
	mov       eax,dword ptr [_rtmp]
	call      @@Sysutils@StrCopy$qqrpcpxc
	mov       eax,dword ptr [_rtmp]
	call      @@Sysutils@StrUpper$qqrpc
	mov       edx,dword ptr [_rtmp1]
	call      @@Sysutils@AnsiStrPos$qqrpct1
	test      eax,eax
	je        short @50
	mov       ecx,dword ptr [ebp-48]
	mov       eax,dword ptr [ecx+732]
	add       eax,520
	mov       dword ptr [ebp-64],eax
	mov       eax,dword ptr [_rem]
	mov       word ptr [ebp-28],20
	mov       edx,dword ptr [ebp-60]
	call      @@Passtr2@TPasString2@Get$qqri
	mov       edx,eax
	lea       eax,dword ptr [ebp-8]
	call      @@System@AnsiString@$bctr$qqrpxc
	inc       dword ptr [ebp-16]
	mov       edx,dword ptr [eax]
	mov       ecx,dword ptr [ebp-64]
	mov       eax,dword ptr [ecx]
	mov       ecx,dword ptr [eax]
	call      dword ptr [ecx+52]
	dec       dword ptr [ebp-16]
	lea       eax,dword ptr [ebp-8]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	dec       dword ptr [ebp-56]
@50:
	inc       dword ptr [ebp-60]
	mov       ecx,dword ptr [ebp-56]
	test      ecx,ecx
	jg        @46
@47:
@49:
	mov       eax,dword ptr [ebp-48]
	mov       eax,dword ptr [eax+732]
	call      @@Controls@TControl@Show$qqrv
	mov       edx,dword ptr [ebp-44]
	mov       dword ptr fs:[0],edx
@51:
@45:
	mov       esp,ebp
	pop       ebp
	ret 
@@TREMGO@FindRemStr$qqrp14System@TObject	endp
@TREMGO@FindRemStr$qqrp14System@TObject	ends
_TEXT	ends
_DATA	segment dword public use32 'DATA'
@_$DCAG$@TREMGO@FirstAddRem$qqruipc	segment virtual
	align	2
@@_$DCAG$@TREMGO@FirstAddRem$qqruipc	label	dword
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-4
	dd	0
@_$DCAG$@TREMGO@FirstAddRem$qqruipc	ends
_DATA	ends
_DATA	segment dword public use32 'DATA'
@_$ECTBG$@TREMGO@FirstAddRem$qqruipc	segment virtual
	align	2
@@_$ECTBG$@TREMGO@FirstAddRem$qqruipc	label	dword
	dd	0
	dd	-40
	dw	0
	dw	5
	dd	0
	dd	@@_$DCAG$@TREMGO@FirstAddRem$qqruipc
@_$ECTBG$@TREMGO@FirstAddRem$qqruipc	ends
_DATA	ends
_TEXT	segment dword public use32 'CODE'
@TREMGO@FirstAddRem$qqruipc	segment virtual
	align	2
@@TREMGO@FirstAddRem$qqruipc	proc	near
?live16402@0:
@52:
	push      ebp
	mov       ebp,esp
	add       esp,-60
	mov       dword ptr [ebp-52],ecx
	mov       dword ptr [ebp-48],edx
	mov       dword ptr [ebp-44],eax
	mov       eax,offset @@_$ECTBG$@TREMGO@FirstAddRem$qqruipc
	call      @__InitExceptBlockLDTC
	mov       edx,dword ptr [_rem]
	test      edx,edx
	jne       short @53
	mov       eax,dword ptr [ebp-44]
	call      @@TREMGO@initREM$qqrv
@53:
	mov       edx,dword ptr [ebp-52]
	mov       eax,dword ptr [_rtmp]
	push      edx
	mov       ecx,dword ptr [ebp-48]
	push      ecx
	push      offset s@+50
	push      eax
	call      @_wsprintfA
	add       esp,16
	mov       edx,dword ptr [ebp-48]
	push      edx
	push      offset s@+60
	mov       ecx,dword ptr [_rtmp1]
	push      ecx
	call      @_wsprintfA
	add       esp,12
	mov       edx,dword ptr [_rtmp1]
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@Where$qqrpc
	mov       dword ptr [ebp-56],eax
@54:
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@GetCount$qqrv
	mov       edx,dword ptr [ebp-56]
	cmp       eax,edx
	jle       short @55
	mov       edx,dword ptr [ebp-56]
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@Get$qqri
	mov       edx,eax
	mov       eax,dword ptr [_rtmp1]
	call      @@Sysutils@StrCopy$qqrpcpxc
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@GetKeyValue$qqrv
	mov       dword ptr [ebp-60],eax
	mov       edx,dword ptr [ebp-60]
	mov       ecx,dword ptr [ebp-48]
	cmp       edx,ecx
	jne       short @56
	mov       edx,dword ptr [ebp-56]
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@Delete$qqri
	mov       ecx,dword ptr [ebp-52]
	mov       eax,dword ptr [_rtmp1]
	push      ecx
	push      eax
	mov       edx,dword ptr [_rtmp]
	push      offset s@+67
	push      edx
	call      @_wsprintfA
	add       esp,16
@56:
	mov       ecx,dword ptr [ebp-60]
	mov       eax,dword ptr [ebp-48]
	cmp       ecx,eax
	jbe       short @54
@55:
	mov       edx,dword ptr [ebp-48]
	mov       ecx,dword ptr [_rtmp]
	push      edx
	xor       edx,edx
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@Insert$qqripci
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@GetCount$qqrv
	test      al,-1
	jne       short @58
	mov       eax,dword ptr [ebp-44]
	call      @@Forms@TCustomForm@Show$qqrv
	mov       eax,dword ptr [ebp-44]
	call      @@Controls@TControl@Refresh$qqrv
	mov       edx,dword ptr [ebp-44]
	mov       eax,dword ptr [edx+756]
	call      @@Controls@TControl@Show$qqrv
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@GetCount$qqrv
	push      eax
	push      offset s@+74
	mov       edx,dword ptr [_rtmp]
	push      edx
	call      @_wsprintfA
	mov       word ptr [ebp-24],8
	add       esp,12
	lea       eax,dword ptr [ebp-4]
	mov       edx,dword ptr [_rtmp]
	call      @@System@AnsiString@$bctr$qqrpxc
	inc       dword ptr [ebp-12]
	mov       edx,dword ptr [eax]
	mov       eax,dword ptr [ebp-44]
	mov       eax,dword ptr [eax+756]
	call      @@Controls@TControl@SetText$qqrx17System@AnsiString
	dec       dword ptr [ebp-12]
	lea       eax,dword ptr [ebp-4]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
@58:
	mov       ecx,dword ptr [ebp-40]
	mov       dword ptr fs:[0],ecx
@59:
	mov       esp,ebp
	pop       ebp
	ret 
@@TREMGO@FirstAddRem$qqruipc	endp
@TREMGO@FirstAddRem$qqruipc	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@TREMGO@Get_REM$qqripc	segment virtual
	align	2
@@TREMGO@Get_REM$qqripc	proc	near
?live16405@0:
@60:
	push      ebp
	mov       ebp,esp
	add       esp,-28
	mov       dword ptr [ebp-12],ecx
	mov       dword ptr [ebp-8],edx
	mov       dword ptr [ebp-4],eax
	mov       eax,dword ptr [_rem]
	test      eax,eax
	je        @62
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@GetCount$qqrv
	mov       dword ptr [ebp-24],eax
	mov       edx,dword ptr [ebp-12]
	mov       byte ptr [edx],0
	mov       ecx,dword ptr [ebp-24]
	test      ecx,ecx
	je        @62
	mov       eax,dword ptr [ebp-8]
	mov       edx,dword ptr [_rtmp1]
	push      eax
	push      offset s@+100
	push      edx
	call      @_wsprintfA
	add       esp,12
	mov       edx,dword ptr [_rtmp1]
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@Where$qqrpc
	mov       dword ptr [ebp-20],eax
	mov       dword ptr [ebp-24],3
@64:
	mov       edx,dword ptr [ebp-20]
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@Get$qqri
	mov       edx,eax
	mov       eax,dword ptr [_rtmp]
	call      @@Sysutils@StrCopy$qqrpcpxc
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@GetKeyValue$qqrv
	mov       dword ptr [ebp-28],eax
	mov       edx,dword ptr [ebp-28]
	mov       ecx,dword ptr [ebp-8]
	cmp       edx,ecx
	je        short @65
	dec       dword ptr [ebp-24]
	inc       dword ptr [ebp-20]
	jmp       short @66
@65:
	mov       edx,offset s@+107
	mov       eax,dword ptr [_rtmp]
	call      @@Sysutils@StrPos$qqrpxct1
	mov       dword ptr [ebp-16],eax
	mov       ecx,dword ptr [ebp-16]
	test      ecx,ecx
	je        short @62
	mov       edx,dword ptr [ebp-16]
	mov       eax,dword ptr [ebp-12]
	inc       edx
	call      @@Sysutils@StrCopy$qqrpcpxc
	jmp       short @62
@66:
	mov       ecx,dword ptr [ebp-24]
	dec       ecx
	jl        short @62
	jmp       short @64
@70:
@62:
	mov       esp,ebp
	pop       ebp
	ret 
@@TREMGO@Get_REM$qqripc	endp
@TREMGO@Get_REM$qqripc	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@TREMGO@initREM$qqrv	segment virtual
	align	2
@@TREMGO@initREM$qqrv	proc	near
?live16406@0:
@71:
	push      ebp
	mov       ebp,esp
	push      ecx
	mov       dword ptr [ebp-4],eax
	mov       eax,52
	call      @@Sysutils@AllocMem$qqrui
	mov       dword ptr [_rem],eax
	push      1
	push      1
	mov       ecx,512000
	mov       edx,16000
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@Setup$qqriioo
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@Clear$qqrv
	mov       eax,96000
	call      @@Sysutils@AllocMem$qqrui
	mov       dword ptr [_mstr],eax
	mov       eax,256
	call      @@Sysutils@AllocMem$qqrui
	mov       dword ptr [_rtmp],eax
	mov       eax,256
	call      @@Sysutils@AllocMem$qqrui
	mov       dword ptr [_rtmp1],eax
@72:
	pop       ecx
	pop       ebp
	ret 
@@TREMGO@initREM$qqrv	endp
@TREMGO@initREM$qqrv	ends
_TEXT	ends
_DATA	segment dword public use32 'DATA'
@_$DCCG$@TREMGO@LoadREM$qqrpc	segment virtual
	align	2
@@_$DCCG$@TREMGO@LoadREM$qqrpc	label	dword
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-4
	dd	0
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-8
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-12
	dd	0
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-16
	dd	0
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-20
	dd	0
@_$DCCG$@TREMGO@LoadREM$qqrpc	ends
_DATA	ends
_DATA	segment dword public use32 'DATA'
@_$ECTDG$@TREMGO@LoadREM$qqrpc	segment virtual
	align	2
@@_$ECTDG$@TREMGO@LoadREM$qqrpc	label	dword
	dd	0
	dd	-56
	dw	0
	dw	5
	dd	0
	dd	@@_$DCCG$@TREMGO@LoadREM$qqrpc
	dw	0
	dw	5
	dd	0
	dd	@@_$DCCG$@TREMGO@LoadREM$qqrpc+16
	dw	0
	dw	5
	dd	0
	dd	@@_$DCCG$@TREMGO@LoadREM$qqrpc+44
	dw	0
	dw	5
	dd	0
	dd	@@_$DCCG$@TREMGO@LoadREM$qqrpc+60
@_$ECTDG$@TREMGO@LoadREM$qqrpc	ends
_DATA	ends
_TEXT	segment dword public use32 'CODE'
@TREMGO@LoadREM$qqrpc	segment virtual
	align	2
@@TREMGO@LoadREM$qqrpc	proc	near
?live16407@0:
@73:
	push      ebp
	mov       ebp,esp
	add       esp,-96
	mov       dword ptr [ebp-64],edx
	mov       dword ptr [ebp-60],eax
	mov       eax,offset @@_$ECTDG$@TREMGO@LoadREM$qqrpc
	call      @__InitExceptBlockLDTC
	mov       word ptr [ebp-40],8
	lea       eax,dword ptr [ebp-4]
	mov       edx,dword ptr [ebp-64]
	call      @@System@AnsiString@$bctr$qqrpxc
	inc       dword ptr [ebp-28]
	xor       edx,edx
	mov       eax,dword ptr [eax]
	call      @@Sysutils@FileOpen$qqrx17System@AnsiStringui
	mov       dword ptr [ebp-68],eax
	dec       dword ptr [ebp-28]
	lea       eax,dword ptr [ebp-4]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	mov       ecx,dword ptr [_rem]
	test      ecx,ecx
	jne       short @74
	mov       eax,dword ptr [ebp-60]
	call      @@TREMGO@initREM$qqrv
@74:
	mov       edx,dword ptr [ebp-68]
	dec       edx
	jge       short @75
	mov       ecx,dword ptr [ebp-56]
	mov       dword ptr fs:[0],ecx
	jmp       @76
@75:
	mov       byte ptr [ebp-90],13
	mov       byte ptr [ebp-89],0
	xor       eax,eax
	mov       edx,dword ptr [_rtmp]
	mov       dword ptr [ebp-76],eax
	mov       dword ptr [ebp-84],edx
@77:
	xor       ecx,ecx
	mov       edx,dword ptr [ebp-76]
	mov       eax,dword ptr [ebp-68]
	call      @@Sysutils@FileSeek$qqriii
	push      256
	push      0
	mov       ecx,dword ptr [ebp-84]
	push      ecx
	call      @_memset
	add       esp,12
	mov       ecx,256
	mov       edx,dword ptr [ebp-84]
	mov       eax,dword ptr [ebp-68]
	call      @@Sysutils@FileRead$qqripvui
	mov       eax,dword ptr [ebp-84]
	movsx     edx,byte ptr [eax]
	cmp       edx,10
	jne       short @78
	mov       ecx,dword ptr [ebp-84]
	mov       byte ptr [ecx],32
@78:
	mov       eax,dword ptr [ebp-84]
	mov       dl,byte ptr [eax]
	test      dl,dl
	je        @80
	lea       edx,dword ptr [ebp-90]
	mov       eax,dword ptr [ebp-84]
	call      @@Sysutils@StrPos$qqrpxct1
	mov       dword ptr [ebp-88],eax
	mov       ecx,dword ptr [ebp-88]
	test      ecx,ecx
	je        @80
	mov       eax,dword ptr [ebp-88]
	mov       byte ptr [eax],0
	mov       edx,dword ptr [ebp-84]
	push      edx
	call      @@GetHex$qpc
	pop       ecx
	mov       dword ptr [ebp-80],eax
	mov       ecx,dword ptr [ebp-60]
	xor       edx,edx
	mov       eax,dword ptr [ecx+724]
	lea       ecx,dword ptr [ebp-8]
	add       eax,496
	mov       dword ptr [ebp-96],eax
	mov       word ptr [ebp-40],20
	mov       dword ptr [ebp-8],edx
	mov       edx,8
	inc       dword ptr [ebp-28]
	mov       eax,dword ptr [ebp-80]
	call      @@Sysutils@IntToHex$qqrii
	lea       edx,dword ptr [ebp-8]
	xor       eax,eax
	mov       dword ptr [ebp-12],eax
	lea       ecx,dword ptr [ebp-12]
	inc       dword ptr [ebp-28]
	mov       eax,offset s@+109
	call      @@System@$badd$qqrpxcrx17System@AnsiString
	mov       eax,dword ptr [ebp-96]
	lea       edx,dword ptr [ebp-12]
	mov       eax,dword ptr [eax]
	mov       edx,dword ptr [edx]
	mov       ecx,dword ptr [eax]
	call      dword ptr [ecx+52]
	dec       dword ptr [ebp-28]
	lea       eax,dword ptr [ebp-12]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	dec       dword ptr [ebp-28]
	lea       eax,dword ptr [ebp-8]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	mov       ecx,dword ptr [ebp-80]
	xor       edx,edx
	push      ecx
	mov       eax,dword ptr [_rem]
	mov       ecx,dword ptr [ebp-84]
	call      @@Passtr2@TPasString2@Insert$qqripci
	mov       eax,dword ptr [ebp-88]
	mov       edx,dword ptr [ebp-84]
	sub       eax,edx
	add       eax,2
	add       dword ptr [ebp-76],eax
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@GetCount$qqrv
	test      al,-1
	jne       @77
	mov       eax,dword ptr [ebp-60]
	call      @@Forms@TCustomForm@Show$qqrv
	mov       eax,dword ptr [ebp-60]
	call      @@Controls@TControl@Refresh$qqrv
	mov       edx,dword ptr [ebp-60]
	mov       eax,dword ptr [edx+756]
	call      @@Controls@TControl@Show$qqrv
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@GetCount$qqrv
	push      eax
	push      offset s@+111
	mov       edx,dword ptr [_rtmp]
	push      edx
	call      @_wsprintfA
	mov       word ptr [ebp-40],32
	add       esp,12
	lea       eax,dword ptr [ebp-16]
	mov       edx,dword ptr [_rtmp]
	call      @@System@AnsiString@$bctr$qqrpxc
	inc       dword ptr [ebp-28]
	mov       edx,dword ptr [eax]
	mov       eax,dword ptr [ebp-60]
	mov       eax,dword ptr [eax+756]
	call      @@Controls@TControl@SetText$qqrx17System@AnsiString
	dec       dword ptr [ebp-28]
	lea       eax,dword ptr [ebp-16]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	jmp       @77
@80:
	mov       ecx,dword ptr [ebp-60]
	mov       eax,dword ptr [ecx+756]
	call      @@Controls@TControl@Hide$qqrv
	mov       eax,dword ptr [ebp-68]
	call      @@Sysutils@FileClose$qqri
	xor       edx,edx
	mov       dword ptr [_nowLine],edx
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@GetCount$qqrv
	push      eax
	push      offset s@+135
	mov       edx,dword ptr [_rtmp]
	push      edx
	call      @_wsprintfA
	mov       word ptr [ebp-40],44
	add       esp,12
	lea       eax,dword ptr [ebp-20]
	mov       edx,dword ptr [_rtmp]
	call      @@System@AnsiString@$bctr$qqrpxc
	inc       dword ptr [ebp-28]
	mov       edx,dword ptr [eax]
	mov       eax,dword ptr [_REMGO]
	call      @@Controls@TControl@SetText$qqrx17System@AnsiString
	dec       dword ptr [ebp-28]
	lea       eax,dword ptr [ebp-20]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	mov       eax,dword ptr [ebp-60]
	call      @@TREMGO@UpdateMemo$qqrv
	mov       eax,dword ptr [ebp-60]
	call      @@Forms@TCustomForm@Hide$qqrv
	mov       edx,dword ptr [ebp-56]
	mov       dword ptr fs:[0],edx
@84:
@76:
	mov       esp,ebp
	pop       ebp
	ret 
@@TREMGO@LoadREM$qqrpc	endp
@TREMGO@LoadREM$qqrpc	ends
_TEXT	ends
_DATA	segment dword public use32 'DATA'
@_$DCEG$@TREMGO@SetOneREM$qqrp14System@TObject	segment virtual
	align	2
@@_$DCEG$@TREMGO@SetOneREM$qqrp14System@TObject	label	dword
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-4
	dd	0
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-8
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-12
	dd	0
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-16
	dd	0
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-20
	dd	0
@_$DCEG$@TREMGO@SetOneREM$qqrp14System@TObject	ends
_DATA	ends
_DATA	segment dword public use32 'DATA'
@_$ECTFG$@TREMGO@SetOneREM$qqrp14System@TObject	segment virtual
	align	2
@@_$ECTFG$@TREMGO@SetOneREM$qqrp14System@TObject	label	dword
	dd	0
	dd	-56
	dw	0
	dw	5
	dd	0
	dd	@@_$DCEG$@TREMGO@SetOneREM$qqrp14System@TObject
	dw	0
	dw	5
	dd	0
	dd	@@_$DCEG$@TREMGO@SetOneREM$qqrp14System@TObject+16
	dw	0
	dw	5
	dd	0
	dd	@@_$DCEG$@TREMGO@SetOneREM$qqrp14System@TObject+44
	dw	0
	dw	5
	dd	0
	dd	@@_$DCEG$@TREMGO@SetOneREM$qqrp14System@TObject+60
@_$ECTFG$@TREMGO@SetOneREM$qqrp14System@TObject	ends
_DATA	ends
_TEXT	segment dword public use32 'CODE'
@TREMGO@SetOneREM$qqrp14System@TObject	segment virtual
	align	2
@@TREMGO@SetOneREM$qqrp14System@TObject	proc	near
?live16410@0:
@85:
	push      ebp
	mov       ebp,esp
	add       esp,-336
	mov       dword ptr [ebp-64],edx
	mov       dword ptr [ebp-60],eax
	mov       eax,offset @@_$ECTFG$@TREMGO@SetOneREM$qqrp14System@TObject
	call      @__InitExceptBlockLDTC
	mov       byte ptr [ebp-336],0
	mov       edx,dword ptr [_rem]
	test      edx,edx
	jne       short @86
	mov       eax,dword ptr [ebp-60]
	call      @@TREMGO@initREM$qqrv
@86:
	mov       word ptr [ebp-40],8
	xor       edx,edx
	mov       dword ptr [ebp-4],edx
	lea       edx,dword ptr [ebp-4]
	inc       dword ptr [ebp-28]
	mov       eax,dword ptr [ebp-60]
	mov       eax,dword ptr [eax+724]
	call      @@Controls@TControl@GetText$qqrv
	mov       edx,dword ptr [ebp-4]
	test      edx,edx
	je        short @87
	mov       ecx,dword ptr [ebp-4]
	jmp       short @88
@87:
	mov       ecx,offset s@+158
@88:
	push      ecx
	call      @@GetHex$qpc
	pop       ecx
	mov       dword ptr [ebp-68],eax
	dec       dword ptr [ebp-28]
	lea       eax,dword ptr [ebp-4]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	mov       edx,dword ptr [ebp-60]
	mov       eax,dword ptr [ebp-68]
	mov       dword ptr [_TopAddr],eax
	xor       eax,eax
	mov       ecx,dword ptr [edx+724]
	mov       edx,8
	add       ecx,496
	mov       dword ptr [ebp-80],ecx
	lea       ecx,dword ptr [ebp-8]
	mov       word ptr [ebp-40],20
	mov       dword ptr [ebp-8],eax
	inc       dword ptr [ebp-28]
	mov       eax,dword ptr [ebp-68]
	call      @@Sysutils@IntToHex$qqrii
	lea       edx,dword ptr [ebp-8]
	xor       ecx,ecx
	mov       dword ptr [ebp-12],ecx
	lea       ecx,dword ptr [ebp-12]
	inc       dword ptr [ebp-28]
	mov       eax,offset s@+159
	call      @@System@$badd$qqrpxcrx17System@AnsiString
	mov       eax,dword ptr [ebp-80]
	lea       edx,dword ptr [ebp-12]
	mov       eax,dword ptr [eax]
	mov       edx,dword ptr [edx]
	mov       ecx,dword ptr [eax]
	call      dword ptr [ecx+52]
	dec       dword ptr [ebp-28]
	lea       eax,dword ptr [ebp-12]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	dec       dword ptr [ebp-28]
	lea       eax,dword ptr [ebp-8]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	mov       word ptr [ebp-40],32
	xor       ecx,ecx
	mov       dword ptr [ebp-16],ecx
	lea       edx,dword ptr [ebp-16]
	inc       dword ptr [ebp-28]
	mov       eax,dword ptr [ebp-60]
	mov       eax,dword ptr [eax+728]
	call      @@Controls@TControl@GetText$qqrv
	mov       edx,dword ptr [ebp-16]
	test      edx,edx
	je        short @89
	mov       ecx,dword ptr [ebp-16]
	jmp       short @90
@89:
	mov       ecx,offset s@+171
@90:
	push      ecx
	mov       edx,dword ptr [_rtmp]
	mov       eax,dword ptr [ebp-68]
	push      eax
	push      offset s@+161
	push      edx
	call      @_wsprintfA
	add       esp,16
	dec       dword ptr [ebp-28]
	lea       eax,dword ptr [ebp-16]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	mov       ecx,dword ptr [ebp-68]
	mov       eax,dword ptr [_rtmp1]
	push      ecx
	push      offset s@+172
	push      eax
	call      @_wsprintfA
	add       esp,12
	mov       edx,dword ptr [_rtmp1]
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@Where$qqrpc
	mov       dword ptr [ebp-72],eax
@91:
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@GetCount$qqrv
	mov       edx,dword ptr [ebp-72]
	cmp       eax,edx
	jle       short @92
	mov       edx,dword ptr [ebp-72]
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@Get$qqri
	mov       edx,eax
	mov       eax,dword ptr [_rtmp1]
	call      @@Sysutils@StrCopy$qqrpcpxc
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@GetKeyValue$qqrv
	mov       dword ptr [ebp-76],eax
	mov       edx,dword ptr [ebp-76]
	mov       ecx,dword ptr [ebp-68]
	cmp       edx,ecx
	jne       short @93
	mov       edx,dword ptr [ebp-72]
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@Delete$qqri
@93:
	inc       dword ptr [ebp-72]
	mov       ecx,dword ptr [ebp-76]
	mov       eax,dword ptr [ebp-68]
	cmp       ecx,eax
	jle       short @91
@92:
	mov       edx,dword ptr [ebp-68]
	mov       ecx,dword ptr [_rtmp]
	push      edx
	xor       edx,edx
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@Insert$qqripci
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@GetCount$qqrv
	push      eax
	push      offset s@+179
	mov       edx,dword ptr [_rtmp]
	push      edx
	call      @_wsprintfA
	mov       word ptr [ebp-40],44
	add       esp,12
	lea       eax,dword ptr [ebp-20]
	mov       edx,dword ptr [_rtmp]
	call      @@System@AnsiString@$bctr$qqrpxc
	inc       dword ptr [ebp-28]
	mov       edx,dword ptr [eax]
	mov       eax,dword ptr [_REMGO]
	call      @@Controls@TControl@SetText$qqrx17System@AnsiString
	dec       dword ptr [ebp-28]
	lea       eax,dword ptr [ebp-20]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	mov       eax,dword ptr [ebp-60]
	call      @@TREMGO@UpdateMemo$qqrv
	mov       eax,dword ptr [ebp-60]
	call      @@Forms@TCustomForm@Hide$qqrv
	mov       edx,dword ptr [_PS2MAIN]
	mov       eax,dword ptr [edx]
	xor       edx,edx
	call      @@TPS2MAIN@MainPaint$qqrp14System@TObject
	mov       ecx,dword ptr [ebp-56]
	mov       dword ptr fs:[0],ecx
@95:
	mov       esp,ebp
	pop       ebp
	ret 
@@TREMGO@SetOneREM$qqrp14System@TObject	endp
@TREMGO@SetOneREM$qqrp14System@TObject	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@TREMGO@UpdateMemo$qqrv	segment virtual
	align	2
@@TREMGO@UpdateMemo$qqrv	proc	near
?live16413@0:
@96:
	push      ebp
	mov       ebp,esp
	add       esp,-16
	mov       dword ptr [ebp-4],eax
	mov       dword ptr [ebp-12],200
	mov       eax,dword ptr [_nowLine]
	mov       dword ptr [ebp-16],eax
	mov       edx,dword ptr [ebp-4]
	mov       eax,dword ptr [edx+732]
	mov       edx,dword ptr [eax]
	call      dword ptr [edx+204]
	mov       ecx,dword ptr [ebp-4]
	mov       eax,dword ptr [ecx+732]
	call      @@Controls@TControl@Hide$qqrv
	mov       edx,dword ptr [_mstr]
	mov       dword ptr [ebp-8],edx
	mov       ecx,dword ptr [ebp-12]
	test      ecx,ecx
	jle       short @98
@97:
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@GetCount$qqrv
	mov       edx,dword ptr [ebp-16]
	cmp       eax,edx
	jle       short @100
	mov       edx,dword ptr [ebp-16]
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@Get$qqri
	mov       edx,eax
	mov       eax,dword ptr [ebp-8]
	call      @@Sysutils@StrCopy$qqrpcpxc
	mov       edx,dword ptr [ebp-16]
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@Get$qqri
	call      @@Sysutils@StrLen$qqrpxc
	add       dword ptr [ebp-8],eax
	mov       ecx,dword ptr [ebp-8]
	mov       byte ptr [ecx],13
	mov       eax,dword ptr [ebp-8]
	mov       byte ptr [eax+1],10
	add       dword ptr [ebp-8],2
	mov       edx,dword ptr [ebp-8]
	mov       byte ptr [edx],0
	inc       dword ptr [ebp-16]
	dec       dword ptr [ebp-12]
	mov       ecx,dword ptr [ebp-12]
	test      ecx,ecx
	jg        short @97
@98:
@100:
	mov       eax,dword ptr [ebp-4]
	mov       edx,dword ptr [_mstr]
	mov       eax,dword ptr [eax+732]
	call      @@Controls@TControl@SetTextBuf$qqrpc
	mov       ecx,dword ptr [ebp-4]
	mov       eax,dword ptr [ecx+732]
	call      @@Controls@TControl@Show$qqrv
	mov       eax,dword ptr [ebp-4]
	call      @@Controls@TControl@Refresh$qqrv
@101:
	mov       esp,ebp
	pop       ebp
	ret 
@@TREMGO@UpdateMemo$qqrv	endp
@TREMGO@UpdateMemo$qqrv	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@TREMGO@ViewNext200$qqrp14System@TObject	segment virtual
	align	2
@@TREMGO@ViewNext200$qqrp14System@TObject	proc	near
?live16414@0:
@102:
	push      ebp
	mov       ebp,esp
	add       esp,-8
	mov       dword ptr [ebp-8],edx
	mov       dword ptr [ebp-4],eax
	mov       eax,dword ptr [_rem]
	test      eax,eax
	jne       short @103
	mov       eax,dword ptr [ebp-4]
	call      @@TREMGO@initREM$qqrv
@103:
	add       dword ptr [_nowLine],200
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@GetCount$qqrv
	mov       edx,dword ptr [_nowLine]
	cmp       eax,edx
	jg        short @104
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@GetCount$qqrv
	add       eax,-200
	mov       dword ptr [_nowLine],eax
@104:
	mov       edx,dword ptr [_nowLine]
	test      edx,edx
	jge       short @105
	xor       ecx,ecx
	mov       dword ptr [_nowLine],ecx
@105:
	mov       eax,dword ptr [ebp-4]
	call      @@TREMGO@UpdateMemo$qqrv
@106:
	pop       ecx
	pop       ecx
	pop       ebp
	ret 
@@TREMGO@ViewNext200$qqrp14System@TObject	endp
@TREMGO@ViewNext200$qqrp14System@TObject	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@TREMGO@ViewPrev200$qqrp14System@TObject	segment virtual
	align	2
@@TREMGO@ViewPrev200$qqrp14System@TObject	proc	near
?live16415@0:
@107:
	push      ebp
	mov       ebp,esp
	add       esp,-8
	mov       dword ptr [ebp-8],edx
	mov       dword ptr [ebp-4],eax
	mov       eax,dword ptr [_rem]
	test      eax,eax
	jne       short @108
	mov       eax,dword ptr [ebp-4]
	call      @@TREMGO@initREM$qqrv
@108:
	sub       dword ptr [_nowLine],200
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@GetCount$qqrv
	mov       edx,dword ptr [_nowLine]
	cmp       eax,edx
	jg        short @109
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@GetCount$qqrv
	add       eax,-200
	mov       dword ptr [_nowLine],eax
@109:
	mov       edx,dword ptr [_nowLine]
	test      edx,edx
	jge       short @110
	xor       ecx,ecx
	mov       dword ptr [_nowLine],ecx
@110:
	mov       eax,dword ptr [ebp-4]
	call      @@TREMGO@UpdateMemo$qqrv
@111:
	pop       ecx
	pop       ecx
	pop       ebp
	ret 
@@TREMGO@ViewPrev200$qqrp14System@TObject	endp
@TREMGO@ViewPrev200$qqrp14System@TObject	ends
_TEXT	ends
_DATA	segment dword public use32 'DATA'
@_$DCGG$@TREMGO@SaveCurrentREM$qqrpc	segment virtual
	align	2
@@_$DCGG$@TREMGO@SaveCurrentREM$qqrpc	label	dword
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-4
	dd	0
@_$DCGG$@TREMGO@SaveCurrentREM$qqrpc	ends
_DATA	ends
_DATA	segment dword public use32 'DATA'
@_$ECTHG$@TREMGO@SaveCurrentREM$qqrpc	segment virtual
	align	2
@@_$ECTHG$@TREMGO@SaveCurrentREM$qqrpc	label	dword
	dd	0
	dd	-40
	dw	0
	dw	5
	dd	0
	dd	@@_$DCGG$@TREMGO@SaveCurrentREM$qqrpc
@_$ECTHG$@TREMGO@SaveCurrentREM$qqrpc	ends
_DATA	ends
_TEXT	segment dword public use32 'CODE'
@TREMGO@SaveCurrentREM$qqrpc	segment virtual
	align	2
@@TREMGO@SaveCurrentREM$qqrpc	proc	near
?live16416@0:
@112:
	push      ebp
	mov       ebp,esp
	add       esp,-60
	mov       dword ptr [ebp-48],edx
	mov       dword ptr [ebp-44],eax
	mov       eax,offset @@_$ECTHG$@TREMGO@SaveCurrentREM$qqrpc
	call      @__InitExceptBlockLDTC
	mov       word ptr [ebp-24],8
	lea       eax,dword ptr [ebp-4]
	mov       edx,dword ptr [ebp-48]
	call      @@System@AnsiString@$bctr$qqrpxc
	inc       dword ptr [ebp-12]
	mov       eax,dword ptr [eax]
	call      @@Sysutils@FileCreate$qqrx17System@AnsiString
	mov       dword ptr [ebp-52],eax
	dec       dword ptr [ebp-12]
	lea       eax,dword ptr [ebp-4]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	mov       ecx,dword ptr [ebp-52]
	test      ecx,ecx
	jge       short @113
	push      0
	push      offset s@+217
	push      offset s@+202
	mov       eax,dword ptr [_REMGO]
	call      @@Controls@TWinControl@GetHandle$qqrv
	push      eax
	call      @MessageBoxA
	mov       edx,dword ptr [ebp-40]
	mov       dword ptr fs:[0],edx
	jmp       @114
@113:
	mov       byte ptr [ebp-59],13
	mov       byte ptr [ebp-58],10
	mov       byte ptr [ebp-57],0
	xor       ecx,ecx
	mov       dword ptr [ebp-56],ecx
	jmp       short @116
@115:
	mov       edx,dword ptr [ebp-56]
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@Get$qqri
	mov       edx,eax
	mov       eax,dword ptr [_rtmp]
	call      @@Sysutils@StrCopy$qqrpcpxc
	mov       eax,dword ptr [_rtmp]
	call      @@Sysutils@StrLen$qqrpxc
	mov       ecx,eax
	mov       edx,dword ptr [_rtmp]
	mov       eax,dword ptr [ebp-52]
	call      @@Sysutils@FileWrite$qqripxvui
	lea       edx,dword ptr [ebp-59]
	mov       ecx,2
	mov       eax,dword ptr [ebp-52]
	call      @@Sysutils@FileWrite$qqripxvui
	inc       dword ptr [ebp-56]
@116:
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@GetCount$qqrv
	mov       edx,dword ptr [ebp-56]
	cmp       eax,edx
	jg        short @115
	mov       eax,dword ptr [ebp-52]
	call      @@Sysutils@FileClose$qqri
	mov       eax,dword ptr [_rem]
	call      @@Passtr2@TPasString2@Clear$qqrv
	mov       edx,dword ptr [ebp-44]
	mov       eax,dword ptr [edx+732]
	mov       edx,dword ptr [eax]
	call      dword ptr [edx+204]
	mov       ecx,dword ptr [ebp-40]
	mov       dword ptr fs:[0],ecx
@118:
@114:
	mov       esp,ebp
	pop       ebp
	ret 
@@TREMGO@SaveCurrentREM$qqrpc	endp
@TREMGO@SaveCurrentREM$qqrpc	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@TREMGO@SetMemoSize$qqrp14System@TObject	segment virtual
	align	2
@@TREMGO@SetMemoSize$qqrp14System@TObject	proc	near
?live16419@0:
@119:
	push      ebp
	mov       ebp,esp
	add       esp,-8
	mov       dword ptr [ebp-8],edx
	mov       dword ptr [ebp-4],eax
	mov       eax,dword ptr [_REMGO]
	mov       edx,dword ptr [eax+56]
	add       edx,-23
	mov       ecx,dword ptr [ebp-4]
	mov       eax,dword ptr [ecx+728]
	call      @@Controls@TControl@SetWidth$qqri
	mov       edx,dword ptr [_REMGO]
	mov       eax,dword ptr [ebp-4]
	mov       edx,dword ptr [edx+56]
	mov       eax,dword ptr [eax+732]
	add       edx,-23
	call      @@Controls@TControl@SetWidth$qqri
	mov       edx,dword ptr [_REMGO]
	mov       eax,dword ptr [ebp-4]
	mov       edx,dword ptr [edx+60]
	mov       eax,dword ptr [eax+732]
	add       edx,-125
	call      @@Controls@TControl@SetHeight$qqri
@120:
	pop       ecx
	pop       ecx
	pop       ebp
	ret 
@@TREMGO@SetMemoSize$qqrp14System@TObject	endp
@TREMGO@SetMemoSize$qqrp14System@TObject	ends
_TEXT	ends
_DATA	segment dword public use32 'DATA'
@_$DCIG$@Forms@TForm@$bctr$qqrp18Classes@TComponent	segment virtual
	align	2
@@_$DCIG$@Forms@TForm@$bctr$qqrp18Classes@TComponent	label	dword
	dd	@@$xt$p11Forms@TForm
	dd	1029
	dd	-4
	dd	0
@_$DCIG$@Forms@TForm@$bctr$qqrp18Classes@TComponent	ends
_DATA	ends
_DATA	segment dword public use32 'DATA'
@_$ECTJG$@Forms@TForm@$bctr$qqrp18Classes@TComponent	segment virtual
	align	2
@@_$ECTJG$@Forms@TForm@$bctr$qqrp18Classes@TComponent	label	dword
	dd	0
	dd	-40
	dw	0
	dw	5
	dd	0
	dd	@@_$DCIG$@Forms@TForm@$bctr$qqrp18Classes@TComponent
@_$ECTJG$@Forms@TForm@$bctr$qqrp18Classes@TComponent	ends
_DATA	ends
_TEXT	segment dword public use32 'CODE'
@Forms@TForm@$bctr$qqrp18Classes@TComponent	segment virtual
	align	2
@@Forms@TForm@$bctr$qqrp18Classes@TComponent	proc	near
?live16386@0:
	push      ebp
	mov       ebp,esp
	add       esp,-48
	test      dl,dl
	mov       byte ptr [ebp-8],dl
	jle       short @121
	call      __ClassCreate
@121:
@122:
	mov       dword ptr [ebp-48],ecx
	mov       byte ptr [ebp-41],dl
	mov       dword ptr [ebp-4],eax
	mov       eax,offset @@_$ECTJG$@Forms@TForm@$bctr$qqrp18Classes@TComponent
	call      @__InitExceptBlockLDTC
	mov       word ptr [ebp-24],8
	mov       ecx,dword ptr [ebp-48]
	xor       edx,edx
	mov       eax,dword ptr [ebp-4]
	call      @@Forms@TCustomForm@$bctr$qqrp18Classes@TComponent
	add       dword ptr [ebp-12],14
	mov       edx,dword ptr [ebp-40]
	mov       dword ptr fs:[0],edx
	mov       eax,dword ptr [ebp-4]
@124:
@123:
	mov       dl,byte ptr [ebp-41]
	test      dl,dl
	je        short @125
	call      __AfterConstruction
@125:
	mov       esp,ebp
	pop       ebp
	ret 
@@Forms@TForm@$bctr$qqrp18Classes@TComponent	endp
@Forms@TForm@$bctr$qqrp18Classes@TComponent	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@$xt$p11Forms@TForm	segment virtual
	align	2
@@$xt$p11Forms@TForm	label	dword
	dd	4
	dw	144
	dw	12
	dd	@@$xt$11Forms@TForm
	db	84
	db	70
	db	111
	db	114
	db	109
	db	32
	db	42
	db	0
@$xt$p11Forms@TForm	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@$xt$17System@AnsiString	segment virtual
	align	2
@@$xt$17System@AnsiString	label	byte
	dd	4
	dw	3
	dw	48
	dd	-1
	dd	3
	dw	68
	dw	72
	dd	0
	dw	0
	dw	0
	dd	0
	dd	1
	dd	1
	dd	@@System@AnsiString@$bdtr$qqrv
	dw	3
	dw	76
	db	83
	db	121
	db	115
	db	116
	db	101
	db	109
	db	58
	db	58
	db	65
	db	110
	db	115
	db	105
	db	83
	db	116
	db	114
	db	105
	db	110
	db	103
	db	0
	db	0
	dd	0
	dd	0
	dd	0
@$xt$17System@AnsiString	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@$xt$p6TREMGO	segment virtual
	align	2
@@$xt$p6TREMGO	label	dword
	dd	4
	dw	144
	dw	12
	dd	@@$xt$6TREMGO
	db	84
	db	82
	db	69
	db	77
	db	71
	db	79
	db	32
	db	42
	db	0
@$xt$p6TREMGO	ends
_TEXT	ends
_DATA	segment dword public use32 'DATA'
@TREMGO@	segment virtual
	align	2
@@TREMGO@	label	byte
	dd	@@TREMGO@+76
	dd	0
	dd	0
	dd	0
	dd	@@$xp$6TREMGO+4
	dd	@@TREMGO@+300
	dd	@@TREMGO@+425
	dd	0
	dd	@@TREMGO@+647
	dd	760
	dd	@Forms@TForm@
	dd	@@Classes@TComponent@SafeCallException$qqrp14System@TObjectpv
	dd	@@Forms@TCustomForm@AfterConstruction$qqrv
	dd	@@Forms@TCustomForm@BeforeDestruction$qqrv
	dd	@@System@TObject@Dispatch$qqrpv
	dd	@@Forms@TCustomForm@DefaultHandler$qqrpv
	dd	@@System@TObject@NewInstance$qqrp17System@TMetaClass
	dd	@@System@TObject@FreeInstance$qqrv
	dd	@@TREMGO@$bdtr$qqrv
	dd	@@Controls@TWinControl@AssignTo$qqrp19Classes@TPersistent
	dd	@@Forms@TCustomForm@DefineProperties$qqrp14Classes@TFiler
	dd	@@Classes@TPersistent@Assign$qqrp19Classes@TPersistent
	dd	@@Forms@TCustomForm@Loaded$qqrv
	dd	@@Forms@TCustomForm@Notification$qqrp18Classes@TComponent18Classes@TOperation
	dd	@@Forms@TCustomForm@ReadState$qqrp15Classes@TReader
	dd	@@Controls@TControl@SetName$qqrx17System@AnsiString
	dd	@@Classes@TComponent@UpdateRegistry$qqrox17System@AnsiStringt2
	dd	@@Forms@TCustomForm@ValidateRename$qqrp18Classes@TComponentx17System@AnsiStringt2
	dd	@@Classes@TComponent@WriteState$qqrp15Classes@TWriter
	dd	@@Forms@TCustomForm@QueryInterface$qqsrx5_GUIDpv
	dd	@@TREMGO@$bctr$qqrp18Classes@TComponent
	dd	@@Controls@TWinControl@CanResize$qqrrit1
	dd	@@Controls@TWinControl@CanAutoSize$qqrrit1
	dd	@@Controls@TWinControl@ConstrainedResize$qqrrit1t1t1
	dd	@@Controls@TWinControl@GetClientOrigin$qqrv
	dd	@@Forms@TCustomForm@GetClientRect$qqrv
	dd	@@Controls@TWinControl@GetDeviceContext$qqrrpv
	dd	@@Controls@TControl@GetDragImages$qqrv
	dd	@@Controls@TControl@GetEnabled$qqrv
	dd	@@Forms@TCustomForm@GetFloating$qqrv
	dd	@@Controls@TControl@GetFloatingDockSiteClass$qqrv
	dd	@@Controls@TControl@SetDragMode$qqr18Controls@TDragMode
	dd	@@Controls@TControl@SetEnabled$qqro
	dd	@@Forms@TCustomForm@SetParent$qqrp20Controls@TWinControl
	dd	@@Forms@TCustomForm@SetParentBiDiMode$qqro
	dd	@@Controls@TControl@SetBiDiMode$qqr17Classes@TBiDiMode
	dd	@@Forms@TCustomForm@WndProc$qqrr17Messages@TMessage
	dd	@@Controls@TControl@InitiateAction$qqrv
	dd	@@Controls@TWinControl@Invalidate$qqrv
	dd	@@Controls@TWinControl@Repaint$qqrv
	dd	@@Controls@TWinControl@SetBounds$qqriiii
	dd	@@Controls@TWinControl@Update$qqrv
	dd	@@Forms@TScrollingWinControl@AdjustClientRect$qqrr13Windows@TRect
	dd	@@Forms@TCustomForm@AlignControls$qqrp17Controls@TControlr13Windows@TRect
	dd	@@Controls@TWinControl@CreateHandle$qqrv
	dd	@@Forms@TCustomForm@CreateParams$qqrr22Controls@TCreateParams
	dd	@@Forms@TCustomForm@CreateWindowHandle$qqrrx22Controls@TCreateParams
	dd	@@Forms@TCustomForm@CreateWnd$qqrv
	dd	@@Forms@TCustomForm@DestroyWindowHandle$qqrv
	dd	@@Controls@TWinControl@DestroyWnd$qqrv
	dd	@@Controls@TWinControl@GetControlExtents$qqrv
	dd	@@Forms@TCustomForm@PaintWindow$qqrpv
	dd	@@Controls@TWinControl@ShowControl$qqrp17Controls@TControl
	dd	@@Forms@TCustomForm@SetFocus$qqrv
	dd	@@Forms@TScrollingWinControl@AutoScrollEnabled$qqrv
	dd	@@Forms@TScrollingWinControl@AutoScrollInView$qqrp17Controls@TControl
	dd	@@Forms@TCustomForm@Resizing$qqr18Forms@TWindowState
	dd	@@Forms@TCustomForm@DoCreate$qqrv
	dd	@@Forms@TCustomForm@DoDestroy$qqrv
	dd	@@Forms@TCustomForm@UpdateActions$qqrv
	dd	@@Forms@TForm@$bctr$qqrp18Classes@TComponenti
	dd	@@Forms@TCustomForm@CloseQuery$qqrv
	dd	@@Forms@TCustomForm@SetFocusedControl$qqrp20Controls@TWinControl
	dd	@@Forms@TCustomForm@ShowModal$qqrv
	dd	@@Forms@TCustomForm@WantChildKey$qqrp17Controls@TControlr17Messages@TMessage
	dw	10
	dd	@@TREMGO@+654
	dd	720
	dw	0
	db	6
	db        76,97,98,101,108,49
	dd	724
	dw	1
	db	5
	db        67,109,98,66,120
	dd	728
	dw	2
	db	8
	db        65,100,100,114,69,100,105,116
	dd	732
	dw	3
	db	4
	db        77,101,109,111
	dd	736
	dw	4
	db	4
	db        66,116,110,49
	dd	740
	dw	4
	db	4
	db        66,116,110,50
	dd	744
	dw	4
	db	4
	db        66,116,110,51
	dd	748
	dw	4
	db	4
	db        66,116,110,52
	dd	752
	dw	4
	db	4
	db        66,116,110,53
	dd	756
	dw	5
	db	6
	db        80,97,110,101,108,49
	dw	13
	dw	16
	dd	@@TREMGO@Btn2Click$qqrp14System@TObject
	db	9
	db        66,116,110,50,67,108,105,99,107
	dw	18
	dd	@@TREMGO@chkEditCuts$qqrp14System@TObjectrus46System@%Set$t18Classes@Classes__1$iuc$0$iuc$6%
	db	11
	db        99,104,107,69,100,105,116,67,117,116,115
	dw	19
	dd	@@TREMGO@FastAddrToGo$qqrp14System@TObject
	db	12
	db        70,97,115,116,65,100,100,114,84,111,71,111
	dw	17
	dd	@@TREMGO@FindRemStr$qqrp14System@TObject
	db	10
	db        70,105,110,100,82,101,109,83,116,114
	dw	14
	dd	@@TREMGO@Get_REM$qqripc
	db	7
	db        71,101,116,95,82,69,77
	dw	14
	dd	@@TREMGO@initREM$qqrv
	db	7
	db        105,110,105,116,82,69,77
	dw	14
	dd	@@TREMGO@LoadREM$qqrpc
	db	7
	db        76,111,97,100,82,69,77
	dw	21
	dd	@@TREMGO@SaveCurrentREM$qqrpc
	db	14
	db        83,97,118,101,67,117,114,114,101,110,116,82,69,77
	dw	16
	dd	@@TREMGO@SetOneREM$qqrp14System@TObject
	db	9
	db        83,101,116,79,110,101,82,69,77
	dw	17
	dd	@@TREMGO@UpdateMemo$qqrv
	db	10
	db        85,112,100,97,116,101,77,101,109,111
	dw	18
	dd	@@TREMGO@ViewNext200$qqrp14System@TObject
	db	11
	db        86,105,101,119,78,101,120,116,50,48,48
	dw	18
	dd	@@TREMGO@ViewPrev200$qqrp14System@TObject
	db	11
	db        86,105,101,119,80,114,101,118,50,48,48
	dw	18
	dd	@@TREMGO@SetMemoSize$qqrp14System@TObject
	db	11
	db        83,101,116,77,101,109,111,83,105,122,101
	db	6
	db        84,82,69,77,71,79
	dw	6
	dd	@Stdctrls@TLabel@
	dd	@Stdctrls@TComboBox@
	dd	@Stdctrls@TEdit@
	dd	@Stdctrls@TMemo@
	dd	@Stdctrls@TButton@
	dd	@Extctrls@TPanel@
@TREMGO@	ends
_DATA	ends
_TEXT	segment dword public use32 'CODE'
@$xp$6TREMGO	segment virtual
	align	2
@@$xp$6TREMGO	label	byte
	dd	@@$xp$6TREMGO+4
	db	7
	db	6
	db        84,82,69,77,71,79
	dd	@@TREMGO@+76
	dd	@$xp$11Forms@TForm
	dw	86
	db	6
	db        71,79,95,82,69,77
	dw	0
@$xp$6TREMGO	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@$xt$6TREMGO	segment virtual
	align	2
@@$xt$6TREMGO	label	byte
	dd	760
	dw	3
	dw	48
	dd	0
	dd	183
	dw	56
	dw	72
	dd	0
	dw	0
	dw	0
	dd	0
	dd	16
	dd	16
	dd	@@TREMGO@$bdtr$qqrv
	dw	3
	dw	76
	db	84
	db	82
	db	69
	db	77
	db	71
	db	79
	db	0
	db	0
	dd	@@$xt$11Forms@TForm
	dd	0
	dd	3
	dd	0
	dd	0
	dd	0
@$xt$6TREMGO	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@$xt$11Forms@TForm	segment virtual
	align	2
@@$xt$11Forms@TForm	label	byte
	dd	720
	dw	3
	dw	48
	dd	0
	dd	183
	dw	64
	dw	80
	dd	0
	dw	0
	dw	0
	dd	0
	dd	15
	dd	15
	dd	@@Forms@TForm@$bdtr$qqrv
	dw	3
	dw	84
	db	70
	db	111
	db	114
	db	109
	db	115
	db	58
	db	58
	db	84
	db	70
	db	111
	db	114
	db	109
	db	0
	db	0
	db	0
	db	0
	dd	@@$xt$17Forms@TCustomForm
	dd	0
	dd	3
	dd	0
	dd	0
	dd	0
@$xt$11Forms@TForm	ends
_TEXT	ends
_DATA	segment dword public use32 'DATA'
@_$ECTKG$@TREMGO@$bdtr$qqrv	segment virtual
	align	2
@@_$ECTKG$@TREMGO@$bdtr$qqrv	label	dword
	dd	0
	dd	-36
@_$ECTKG$@TREMGO@$bdtr$qqrv	ends
_DATA	ends
_TEXT	segment dword public use32 'CODE'
@TREMGO@$bdtr$qqrv	segment virtual
	align	2
@@TREMGO@$bdtr$qqrv	proc	near
?live16427@0:
@126:
	push      ebp
	mov       ebp,esp
	add       esp,-44
	call      __BeforeDestruction
	mov       byte ptr [ebp-41],dl
	mov       dword ptr [ebp-40],eax
	mov       eax,offset @@_$ECTKG$@TREMGO@$bdtr$qqrv
	call      @__InitExceptBlockLDTC
	mov       dl,byte ptr [ebp-41]
	test      dl,dl
	jl        short @127
	sub       dword ptr [ebp-8],15
	xor       edx,edx
	mov       eax,dword ptr [ebp-40]
	call      @@Forms@TForm@$bdtr$qqrv
@127:
@128:
	mov       ecx,dword ptr [ebp-36]
	mov       dword ptr fs:[0],ecx
@130:
@129:
	mov       al,byte ptr [ebp-41]
	test      al,al
	jle       short @131
	mov       eax,dword ptr [ebp-40]
	call      __ClassDestroy
@131:
	mov       esp,ebp
	pop       ebp
	ret 
@@TREMGO@$bdtr$qqrv	endp
@TREMGO@$bdtr$qqrv	ends
_TEXT	ends
_DATA	segment dword public use32 'DATA'
@_$DCLG$@Classes@TComponent@UpdateRegistry$qqrox17System@AnsiStringt2	segment virtual
	align	2
@@_$DCLG$@Classes@TComponent@UpdateRegistry$qqrox17System@AnsiStringt2	label	dword
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-4
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	8
	dd	0
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-8
	dd	@@$xt$17System@AnsiString
	dd	4
	dd	-12
	dd	0
@_$DCLG$@Classes@TComponent@UpdateRegistry$qqrox17System@AnsiStringt2	ends
_DATA	ends
_DATA	segment dword public use32 'DATA'
@_$ECTMG$@Classes@TComponent@UpdateRegistry$qqrox17System@AnsiStringt2	segment virtual
	align	2
@@_$ECTMG$@Classes@TComponent@UpdateRegistry$qqrox17System@AnsiStringt2	label	dword
	dd	0
	dd	-48
	dw	0
	dw	5
	dd	2
	dd	@@_$DCLG$@Classes@TComponent@UpdateRegistry$qqrox17System@AnsiStringt2
	dw	8
	dw	5
	dd	4
	dd	@@_$DCLG$@Classes@TComponent@UpdateRegistry$qqrox17System@AnsiStringt2+28
@_$ECTMG$@Classes@TComponent@UpdateRegistry$qqrox17System@AnsiStringt2	ends
_DATA	ends
_TEXT	segment dword public use32 'CODE'
@Classes@TComponent@UpdateRegistry$qqrox17System@AnsiStringt2	segment virtual
	align	2
@@Classes@TComponent@UpdateRegistry$qqrox17System@AnsiStringt2	proc	near
?live16428@0:
@132:
	push      ebp
	mov       ebp,esp
	add       esp,-56
	mov       dword ptr [ebp-4],ecx
	mov       byte ptr [ebp-53],dl
	mov       dword ptr [ebp-52],eax
	mov       eax,offset @@_$ECTMG$@Classes@TComponent@UpdateRegistry$qqrox17System@AnsiStringt2
	call      @__InitExceptBlockLDTC
	mov       dword ptr [ebp-20],2
	lea       edx,dword ptr [ebp-4]
	lea       eax,dword ptr [ebp-4]
	call      @@System@AnsiString@$bctr$qqrrx17System@AnsiString
	inc       dword ptr [ebp-20]
	lea       edx,dword ptr [ebp+8]
	mov       word ptr [ebp-32],8
	lea       eax,dword ptr [ebp+8]
	call      @@System@AnsiString@$bctr$qqrrx17System@AnsiString
	inc       dword ptr [ebp-20]
	lea       edx,dword ptr [ebp+8]
	lea       eax,dword ptr [ebp-12]
	call      @@System@AnsiString@$bctr$qqrrx17System@AnsiString
	inc       dword ptr [ebp-20]
	mov       edx,dword ptr [eax]
	lea       eax,dword ptr [ebp-8]
	push      edx
	lea       edx,dword ptr [ebp-4]
	mov       word ptr [ebp-32],20
	call      @@System@AnsiString@$bctr$qqrrx17System@AnsiString
	inc       dword ptr [ebp-20]
	mov       ecx,dword ptr [eax]
	mov       dl,byte ptr [ebp-53]
	mov       eax,dword ptr [@Classes@TComponent@]
	call      @@Classes@TComponent@UpdateRegistry$qqrp17System@TMetaClassox17System@AnsiStringt3
	dec       dword ptr [ebp-20]
	lea       eax,dword ptr [ebp-12]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	dec       dword ptr [ebp-20]
	lea       eax,dword ptr [ebp-8]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	dec       dword ptr [ebp-20]
	lea       eax,dword ptr [ebp+8]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	dec       dword ptr [ebp-20]
	lea       eax,dword ptr [ebp-4]
	mov       edx,2
	call      @@System@AnsiString@$bdtr$qqrv
	mov       ecx,dword ptr [ebp-48]
	mov       dword ptr fs:[0],ecx
@133:
	mov       esp,ebp
	pop       ebp
	ret       4
@@Classes@TComponent@UpdateRegistry$qqrox17System@AnsiStringt2	endp
@Classes@TComponent@UpdateRegistry$qqrox17System@AnsiStringt2	ends
_TEXT	ends
_DATA	segment dword public use32 'DATA'
@_$DCNG$@Forms@TForm@$bctr$qqrp18Classes@TComponenti	segment virtual
	align	2
@@_$DCNG$@Forms@TForm@$bctr$qqrp18Classes@TComponenti	label	dword
	dd	@@$xt$p11Forms@TForm
	dd	1029
	dd	-4
	dd	0
@_$DCNG$@Forms@TForm@$bctr$qqrp18Classes@TComponenti	ends
_DATA	ends
_DATA	segment dword public use32 'DATA'
@_$ECTOG$@Forms@TForm@$bctr$qqrp18Classes@TComponenti	segment virtual
	align	2
@@_$ECTOG$@Forms@TForm@$bctr$qqrp18Classes@TComponenti	label	dword
	dd	0
	dd	-40
	dw	0
	dw	5
	dd	0
	dd	@@_$DCNG$@Forms@TForm@$bctr$qqrp18Classes@TComponenti
@_$ECTOG$@Forms@TForm@$bctr$qqrp18Classes@TComponenti	ends
_DATA	ends
_TEXT	segment dword public use32 'CODE'
@Forms@TForm@$bctr$qqrp18Classes@TComponenti	segment virtual
	align	2
@@Forms@TForm@$bctr$qqrp18Classes@TComponenti	proc	near
?live16429@0:
	push      ebp
	mov       ebp,esp
	add       esp,-48
	test      dl,dl
	mov       byte ptr [ebp-8],dl
	jle       short @134
	call      __ClassCreate
@134:
@135:
	mov       dword ptr [ebp-48],ecx
	mov       byte ptr [ebp-41],dl
	mov       dword ptr [ebp-4],eax
	mov       eax,offset @@_$ECTOG$@Forms@TForm@$bctr$qqrp18Classes@TComponenti
	call      @__InitExceptBlockLDTC
	mov       word ptr [ebp-24],8
	mov       edx,dword ptr [ebp+8]
	push      edx
	mov       ecx,dword ptr [ebp-48]
	xor       edx,edx
	mov       eax,dword ptr [ebp-4]
	call      @@Forms@TCustomForm@$bctr$qqrp18Classes@TComponenti
	add       dword ptr [ebp-12],14
	mov       ecx,dword ptr [ebp-40]
	mov       dword ptr fs:[0],ecx
	mov       eax,dword ptr [ebp-4]
@137:
@136:
	mov       dl,byte ptr [ebp-41]
	test      dl,dl
	je        short @138
	call      __AfterConstruction
@138:
	mov       esp,ebp
	pop       ebp
	ret       4
@@Forms@TForm@$bctr$qqrp18Classes@TComponenti	endp
@Forms@TForm@$bctr$qqrp18Classes@TComponenti	ends
_TEXT	ends
_DATA	segment dword public use32 'DATA'
@_$DCPG$@Forms@TForm@$bdtr$qqrv	segment virtual
	align	2
@@_$DCPG$@Forms@TForm@$bdtr$qqrv	label	dword
	dd	@@$xt$p11Forms@TForm
	dd	1029
	dd	-4
	dd	0
@_$DCPG$@Forms@TForm@$bdtr$qqrv	ends
_DATA	ends
_DATA	segment dword public use32 'DATA'
@_$ECTQG$@Forms@TForm@$bdtr$qqrv	segment virtual
	align	2
@@_$ECTQG$@Forms@TForm@$bdtr$qqrv	label	dword
	dd	0
	dd	-40
	dw	0
	dw	5
	dd	0
	dd	@@_$DCPG$@Forms@TForm@$bdtr$qqrv
@_$ECTQG$@Forms@TForm@$bdtr$qqrv	ends
_DATA	ends
_TEXT	segment dword public use32 'CODE'
@Forms@TForm@$bdtr$qqrv	segment virtual
	align	2
@@Forms@TForm@$bdtr$qqrv	proc	near
?live16430@0:
@139:
	push      ebp
	mov       ebp,esp
	add       esp,-44
	call      __BeforeDestruction
	mov       byte ptr [ebp-41],dl
	mov       dword ptr [ebp-4],eax
	mov       eax,offset @@_$ECTQG$@Forms@TForm@$bdtr$qqrv
	call      @__InitExceptBlockLDTC
	mov       dword ptr [ebp-12],14
	mov       dl,byte ptr [ebp-41]
	test      dl,dl
	jl        short @140
	mov       word ptr [ebp-24],8
	sub       dword ptr [ebp-12],14
	xor       edx,edx
	mov       eax,dword ptr [ebp-4]
	call      @@Forms@TCustomForm@$bdtr$qqrv
@140:
	mov       ecx,dword ptr [ebp-40]
	mov       dword ptr fs:[0],ecx
@141:
	mov       al,byte ptr [ebp-41]
	test      al,al
	jle       short @142
	mov       eax,dword ptr [ebp-4]
	call      __ClassDestroy
@142:
	mov       esp,ebp
	pop       ebp
	ret 
@@Forms@TForm@$bdtr$qqrv	endp
@Forms@TForm@$bdtr$qqrv	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@$xt$17Forms@TCustomForm	segment virtual
	align	2
@@$xt$17Forms@TCustomForm	label	byte
	dd	720
	dw	3
	dw	48
	dd	0
	dd	183
	dw	68
	dw	84
	dd	0
	dw	0
	dw	0
	dd	0
	dd	14
	dd	14
	dd	@@Forms@TCustomForm@$bdtr$qqrv
	dw	3
	dw	88
	db	70
	db	111
	db	114
	db	109
	db	115
	db	58
	db	58
	db	84
	db	67
	db	117
	db	115
	db	116
	db	111
	db	109
	db	70
	db	111
	db	114
	db	109
	db	0
	db	0
	dd	@@$xt$26Forms@TScrollingWinControl
	dd	0
	dd	3
	dd	0
	dd	0
	dd	@@$xt$17System@AnsiString
	dd	548
	dd	@@$xt$43System@%DelphiInterface$t15Forms@IDesigner%
	dd	568
	dd	@@$xt$42System@%DelphiInterface$t14Forms@IOleForm%
	dd	588
	dd	0
@$xt$17Forms@TCustomForm	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@$xt$42System@%DelphiInterface$t14Forms@IOleForm%	segment virtual
	align	2
@@$xt$42System@%DelphiInterface$t14Forms@IOleForm%	label	byte
	dd	4
	dw	3
	dw	48
	dd	-1
	dd	3
	dw	92
	dw	96
	dd	0
	dw	0
	dw	0
	dd	0
	dd	1
	dd	1
	dd	@@System@%DelphiInterface$t14Forms@IOleForm%@$bdtr$qqrv
	dw	3
	dw	100
	db	83
	db	121
	db	115
	db	116
	db	101
	db	109
	db	58
	db	58
	db	68
	db	101
	db	108
	db	112
	db	104
	db	105
	db	73
	db	110
	db	116
	db	101
	db	114
	db	102
	db	97
	db	99
	db	101
	db	60
	db	70
	db	111
	db	114
	db	109
	db	115
	db	58
	db	58
	db	73
	db	79
	db	108
	db	101
	db	70
	db	111
	db	114
	db	109
	db	62
	db	0
	db	0
	db	0
	db	0
	dd	0
	dd	0
	dd	0
@$xt$42System@%DelphiInterface$t14Forms@IOleForm%	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@$xt$43System@%DelphiInterface$t15Forms@IDesigner%	segment virtual
	align	2
@@$xt$43System@%DelphiInterface$t15Forms@IDesigner%	label	byte
	dd	4
	dw	3
	dw	48
	dd	-1
	dd	3
	dw	92
	dw	96
	dd	0
	dw	0
	dw	0
	dd	0
	dd	1
	dd	1
	dd	@@System@%DelphiInterface$t15Forms@IDesigner%@$bdtr$qqrv
	dw	3
	dw	100
	db	83
	db	121
	db	115
	db	116
	db	101
	db	109
	db	58
	db	58
	db	68
	db	101
	db	108
	db	112
	db	104
	db	105
	db	73
	db	110
	db	116
	db	101
	db	114
	db	102
	db	97
	db	99
	db	101
	db	60
	db	70
	db	111
	db	114
	db	109
	db	115
	db	58
	db	58
	db	73
	db	68
	db	101
	db	115
	db	105
	db	103
	db	110
	db	101
	db	114
	db	62
	db	0
	db	0
	db	0
	dd	0
	dd	0
	dd	0
@$xt$43System@%DelphiInterface$t15Forms@IDesigner%	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@$xt$26Forms@TScrollingWinControl	segment virtual
	align	2
@@$xt$26Forms@TScrollingWinControl	label	byte
	dd	520
	dw	3
	dw	48
	dd	0
	dd	183
	dw	76
	dw	92
	dd	0
	dw	0
	dw	0
	dd	0
	dd	10
	dd	10
	dd	@@Forms@TScrollingWinControl@$bdtr$qqrv
	dw	3
	dw	96
	db	70
	db	111
	db	114
	db	109
	db	115
	db	58
	db	58
	db	84
	db	83
	db	99
	db	114
	db	111
	db	108
	db	108
	db	105
	db	110
	db	103
	db	87
	db	105
	db	110
	db	67
	db	111
	db	110
	db	116
	db	114
	db	111
	db	108
	db	0
	dd	@@$xt$20Controls@TWinControl
	dd	0
	dd	3
	dd	0
	dd	0
	dd	0
@$xt$26Forms@TScrollingWinControl	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@System@%DelphiInterface$t14Forms@IOleForm%@$bdtr$qqrv	segment virtual
	align	2
@@System@%DelphiInterface$t14Forms@IOleForm%@$bdtr$qqrv	proc	near
?live16443@0:
@143:
	push      ebp
	mov       ebp,esp
	add       esp,-8
	mov       dword ptr [ebp-8],edx
	mov       dword ptr [ebp-4],eax
	mov       eax,dword ptr [ebp-4]
	test      eax,eax
	je        short @144
	mov       edx,dword ptr [ebp-4]
	mov       ecx,dword ptr [edx]
	test      ecx,ecx
	je        short @145
	mov       eax,dword ptr [ebp-4]
	mov       edx,dword ptr [eax]
	push      edx
	mov       ecx,dword ptr [edx]
	call      dword ptr [ecx+8]
@145:
	mov       eax,dword ptr [ebp-4]
	xor       edx,edx
	mov       dword ptr [eax],edx
	test      byte ptr [ebp-8],1
	je        short @146
	mov       ecx,dword ptr [ebp-4]
	push      ecx
	call      @$bdele$qpv
	pop       ecx
@146:
@144:
@147:
	pop       ecx
	pop       ecx
	pop       ebp
	ret 
@@System@%DelphiInterface$t14Forms@IOleForm%@$bdtr$qqrv	endp
@System@%DelphiInterface$t14Forms@IOleForm%@$bdtr$qqrv	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@System@%DelphiInterface$t15Forms@IDesigner%@$bdtr$qqrv	segment virtual
	align	2
@@System@%DelphiInterface$t15Forms@IDesigner%@$bdtr$qqrv	proc	near
?live16444@0:
@148:
	push      ebp
	mov       ebp,esp
	add       esp,-8
	mov       dword ptr [ebp-8],edx
	mov       dword ptr [ebp-4],eax
	mov       eax,dword ptr [ebp-4]
	test      eax,eax
	je        short @149
	mov       edx,dword ptr [ebp-4]
	mov       ecx,dword ptr [edx]
	test      ecx,ecx
	je        short @150
	mov       eax,dword ptr [ebp-4]
	mov       edx,dword ptr [eax]
	push      edx
	mov       ecx,dword ptr [edx]
	call      dword ptr [ecx+8]
@150:
	mov       eax,dword ptr [ebp-4]
	xor       edx,edx
	mov       dword ptr [eax],edx
	test      byte ptr [ebp-8],1
	je        short @151
	mov       ecx,dword ptr [ebp-4]
	push      ecx
	call      @$bdele$qpv
	pop       ecx
@151:
@149:
@152:
	pop       ecx
	pop       ecx
	pop       ebp
	ret 
@@System@%DelphiInterface$t15Forms@IDesigner%@$bdtr$qqrv	endp
@System@%DelphiInterface$t15Forms@IDesigner%@$bdtr$qqrv	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@$xt$20Controls@TWinControl	segment virtual
	align	2
@@$xt$20Controls@TWinControl	label	byte
	dd	496
	dw	3
	dw	48
	dd	0
	dd	183
	dw	72
	dw	88
	dd	0
	dw	0
	dw	0
	dd	0
	dd	9
	dd	9
	dd	@@Controls@TWinControl@$bdtr$qqrv
	dw	3
	dw	92
	db	67
	db	111
	db	110
	db	116
	db	114
	db	111
	db	108
	db	115
	db	58
	db	58
	db	84
	db	87
	db	105
	db	110
	db	67
	db	111
	db	110
	db	116
	db	114
	db	111
	db	108
	db	0
	db	0
	db	0
	dd	@@$xt$17Controls@TControl
	dd	0
	dd	3
	dd	0
	dd	0
	dd	@@$xt$49System@%DelphiInterface$t21Controls@IDockManager%
	dd	328
	dd	@@$xt$17System@AnsiString
	dd	344
	dd	0
@$xt$20Controls@TWinControl	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@$xt$49System@%DelphiInterface$t21Controls@IDockManager%	segment virtual
	align	2
@@$xt$49System@%DelphiInterface$t21Controls@IDockManager%	label	byte
	dd	4
	dw	3
	dw	48
	dd	-1
	dd	3
	dw	96
	dw	100
	dd	0
	dw	0
	dw	0
	dd	0
	dd	1
	dd	1
	dd	@@System@%DelphiInterface$t21Controls@IDockManager%@$bdtr$qqrv
	dw	3
	dw	104
	db	83
	db	121
	db	115
	db	116
	db	101
	db	109
	db	58
	db	58
	db	68
	db	101
	db	108
	db	112
	db	104
	db	105
	db	73
	db	110
	db	116
	db	101
	db	114
	db	102
	db	97
	db	99
	db	101
	db	60
	db	67
	db	111
	db	110
	db	116
	db	114
	db	111
	db	108
	db	115
	db	58
	db	58
	db	73
	db	68
	db	111
	db	99
	db	107
	db	77
	db	97
	db	110
	db	97
	db	103
	db	101
	db	114
	db	62
	db	0
	dd	0
	dd	0
	dd	0
@$xt$49System@%DelphiInterface$t21Controls@IDockManager%	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@$xt$17Controls@TControl	segment virtual
	align	2
@@$xt$17Controls@TControl	label	byte
	dd	288
	dw	3
	dw	48
	dd	0
	dd	183
	dw	68
	dw	84
	dd	0
	dw	0
	dw	0
	dd	0
	dd	6
	dd	6
	dd	@@Controls@TControl@$bdtr$qqrv
	dw	3
	dw	88
	db	67
	db	111
	db	110
	db	116
	db	114
	db	111
	db	108
	db	115
	db	58
	db	58
	db	84
	db	67
	db	111
	db	110
	db	116
	db	114
	db	111
	db	108
	db	0
	db	0
	dd	@@$xt$18Classes@TComponent
	dd	0
	dd	3
	dd	0
	dd	0
	dd	@@$xt$17System@AnsiString
	dd	112
	dd	0
@$xt$17Controls@TControl	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@System@%DelphiInterface$t21Controls@IDockManager%@$bdtr$qqrv	segment virtual
	align	2
@@System@%DelphiInterface$t21Controls@IDockManager%@$bdtr$qqrv	proc	near
?live16448@0:
@153:
	push      ebp
	mov       ebp,esp
	add       esp,-8
	mov       dword ptr [ebp-8],edx
	mov       dword ptr [ebp-4],eax
	mov       eax,dword ptr [ebp-4]
	test      eax,eax
	je        short @154
	mov       edx,dword ptr [ebp-4]
	mov       ecx,dword ptr [edx]
	test      ecx,ecx
	je        short @155
	mov       eax,dword ptr [ebp-4]
	mov       edx,dword ptr [eax]
	push      edx
	mov       ecx,dword ptr [edx]
	call      dword ptr [ecx+8]
@155:
	mov       eax,dword ptr [ebp-4]
	xor       edx,edx
	mov       dword ptr [eax],edx
	test      byte ptr [ebp-8],1
	je        short @156
	mov       ecx,dword ptr [ebp-4]
	push      ecx
	call      @$bdele$qpv
	pop       ecx
@156:
@154:
@157:
	pop       ecx
	pop       ecx
	pop       ebp
	ret 
@@System@%DelphiInterface$t21Controls@IDockManager%@$bdtr$qqrv	endp
@System@%DelphiInterface$t21Controls@IDockManager%@$bdtr$qqrv	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@$xt$18Classes@TComponent	segment virtual
	align	2
@@$xt$18Classes@TComponent	label	byte
	dd	36
	dw	3
	dw	48
	dd	0
	dd	183
	dw	68
	dw	84
	dd	0
	dw	0
	dw	0
	dd	0
	dd	4
	dd	4
	dd	@@Classes@TComponent@$bdtr$qqrv
	dw	3
	dw	88
	db	67
	db	108
	db	97
	db	115
	db	115
	db	101
	db	115
	db	58
	db	58
	db	84
	db	67
	db	111
	db	109
	db	112
	db	111
	db	110
	db	101
	db	110
	db	116
	db	0
	dd	@@$xt$19Classes@TPersistent
	dd	0
	dd	3
	dd	0
	dd	0
	dd	@@$xt$17System@AnsiString
	dd	8
	dd	0
@$xt$18Classes@TComponent	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@$xt$19Classes@TPersistent	segment virtual
	align	2
@@$xt$19Classes@TPersistent	label	byte
	dd	4
	dw	3
	dw	48
	dd	0
	dd	183
	dw	72
	dw	88
	dd	0
	dw	0
	dw	0
	dd	0
	dd	2
	dd	2
	dd	@@Classes@TPersistent@$bdtr$qqrv
	dw	3
	dw	92
	db	67
	db	108
	db	97
	db	115
	db	115
	db	101
	db	115
	db	58
	db	58
	db	84
	db	80
	db	101
	db	114
	db	115
	db	105
	db	115
	db	116
	db	101
	db	110
	db	116
	db	0
	db	0
	db	0
	db	0
	dd	@@$xt$14System@TObject
	dd	0
	dd	3
	dd	0
	dd	0
	dd	0
@$xt$19Classes@TPersistent	ends
_TEXT	ends
_TEXT	segment dword public use32 'CODE'
@$xt$14System@TObject	segment virtual
	align	2
@@$xt$14System@TObject	label	byte
	dd	4
	dw	3
	dw	48
	dd	0
	dd	179
	dw	64
	dw	68
	dd	0
	dw	0
	dw	0
	dd	0
	dd	1
	dd	1
	dd	@@System@TObject@$bdtr$qqrv
	dw	3
	dw	72
	db	83
	db	121
	db	115
	db	116
	db	101
	db	109
	db	58
	db	58
	db	84
	db	79
	db	98
	db	106
	db	101
	db	99
	db	116
	db	0
	dd	0
	dd	0
	dd	0
@$xt$14System@TObject	ends
_TEXT	ends
_DATA	segment dword public use32 'DATA'
s@	label	byte
	db	0,0
	;	s@+2:
	db	"$",0
	;	s@+4:
	db	"$",0,0,0,189,208,166
	;	s@+11:
	db	"b",189
	;	s@+13:
	db	"s",191,232,174,216,164,186,182,241,164
	;	s@+23:
	db	"J",177,253,183
	;	s@+27:
	db	"j",180
	;	s@+29:
	db	"M",170,186,166
	;	s@+33:
	db	"r",166,234,0,165,188,182,241,183
	;	s@+42:
	db	"j",180
	;	s@+44:
	db	"M",166
	;	s@+46:
	db	"r",166,234,0
	;	s@+50:
	db	"$%08lX:%s",0
	;	s@+60:
	db	"$%08lX",0
	;	s@+67:
	db	"%s, %s",0,197,170,168,250
	;	s@+78:
	db	" Symbol Line ",178,196
	;	s@+93:
	db	" %d ",166,230,0
	;	s@+100:
	db	"$%08lX",0
	;	s@+107:
	db	":",0
	;	s@+109:
	db	"$",0,165,191,166
	;	s@+114:
	db	"b",197,170,168,250,181,249,184,209,192,201,178,196
	;	s@+127:
	db	" %ld ",166,230,0,191,233,164
	;	s@+138:
	db	"J",181,249,184,209
	;	s@+143:
	db	" : ",178
	;	s@+147:
	db	"{",166,179
	;	s@+150:
	db	" %ld ",166,230,0,0
	;	s@+159:
	db	"$",0
	;	s@+161:
	db	"$%08lX:%s",0,0
	;	s@+172:
	db	"$%08lX",0,191,233,164
	;	s@+182:
	db	"J",181,249,184,209
	;	s@+187:
	db	" : ",178
	;	s@+191:
	db	"{",166,179
	;	s@+194:
	db	" %ld ",166,230,0,181
	;	s@+203:
	db	"L",170
	;	s@+205:
	db	"k",188
	;	s@+207:
	db	"g",164
	;	s@+209:
	db	"J",181,249,184,209,192,201,0,192,201,174,215,171,216,165,223
	db	165,162,177,209,0
	align	4
_DATA	ends
_TEXT	segment dword public use32 'CODE'
_TEXT	ends
 ?debug  C FB04085F5053324D41494E01000000
 ?debug  C FB0408405452454D474F4004000000
 ?debug  C FB040C4024787024365452454D474F04000000
 ?debug  C FB040D40466F726D734054466F726D4004000000
 ?debug  C FB0411405374646374726C7340544C6162656C4004000000
 ?debug  C FB0414405374646374726C734054436F6D626F426F784004000000
 ?debug  C FB0410405374646374726C734054456469744004000000
 ?debug  C FB0410405374646374726C7340544D656D6F4004000000
 ?debug  C FB0412405374646374726C734054427574746F6E4004000000
 ?debug  C FB0411404578746374726C73405450616E656C4004000000
 ?debug  C FB041240247870243131466F726D734054466F726D04000000
 ?debug  C FB045140436C61737365734054436F6D706F6E656E744055706461746552656769737472792471717270313753797374656D40544D657461436C6173736F78313753797374656D40416E7369537472696E67743302000000
 ?debug  C FB041440436C61737365734054436F6D706F6E656E744004000000
	publicdll	_REMGO
 extrn   _PS2MAIN:dword
 extrn   _TopAddr:dword
 extrn   _validHexLen:dword
 extrn   _temp2:dword
	public	_rem
	public	_nowLine
	public	_rtmp
	public	_rtmp1
	public	_mstr
 extrn   __Exception_list:dword
 extrn   @__InitExceptBlockLDTC:near
 extrn   __ClassCreate:near
 extrn   __AfterConstruction:near
@@Forms@TCustomForm@Hide$qqrv equ @Forms@TCustomForm@Hide$qqrv
 extrn   @Forms@TCustomForm@Hide$qqrv:near
@@GetHex$qpc equ @GetHex$qpc
 extrn   @GetHex$qpc:near
@@Controls@TControl@GetText$qqrv equ @Controls@TControl@GetText$qqrv
 extrn   @Controls@TControl@GetText$qqrv:near
@@System@AnsiString@$bdtr$qqrv equ @System@AnsiString@$bdtr$qqrv
 extrn   @System@AnsiString@$bdtr$qqrv:near
@@Controls@TControl@SetText$qqrx17System@AnsiString equ @Controls@TControl@SetText$qqrx17System@AnsiString
 extrn   @Controls@TControl@SetText$qqrx17System@AnsiString:near
@@System@AnsiString@$bctr$qqrpxc equ @System@AnsiString@$bctr$qqrpxc
 extrn   @System@AnsiString@$bctr$qqrpxc:near
@@Clipbrd@Clipboard$qqrv equ @Clipbrd@Clipboard$qqrv
 extrn   @Clipbrd@Clipboard$qqrv:near
@@Clipbrd@TClipboard@SetAsText$qqrx17System@AnsiString equ @Clipbrd@TClipboard@SetAsText$qqrx17System@AnsiString
 extrn   @Clipbrd@TClipboard@SetAsText$qqrx17System@AnsiString:near
@@Stdctrls@TCustomEdit@SetSelText$qqrx17System@AnsiString equ @Stdctrls@TCustomEdit@SetSelText$qqrx17System@AnsiString
 extrn   @Stdctrls@TCustomEdit@SetSelText$qqrx17System@AnsiString:near
@@Clipbrd@TClipboard@GetAsText$qqrv equ @Clipbrd@TClipboard@GetAsText$qqrv
 extrn   @Clipbrd@TClipboard@GetAsText$qqrv:near
@@Sysutils@StrPos$qqrpxct1 equ @Sysutils@StrPos$qqrpxct1
 extrn   @Sysutils@StrPos$qqrpxct1:near
@@Sysutils@StrCopy$qqrpcpxc equ @Sysutils@StrCopy$qqrpcpxc
 extrn   @Sysutils@StrCopy$qqrpcpxc:near
@@Sysutils@StrLen$qqrpxc equ @Sysutils@StrLen$qqrpxc
 extrn   @Sysutils@StrLen$qqrpxc:near
@MessageBoxA equ MessageBoxA
 extrn   MessageBoxA:near
@@Controls@TWinControl@GetHandle$qqrv equ @Controls@TWinControl@GetHandle$qqrv
 extrn   @Controls@TWinControl@GetHandle$qqrv:near
@@Controls@TControl@Hide$qqrv equ @Controls@TControl@Hide$qqrv
 extrn   @Controls@TControl@Hide$qqrv:near
@@Sysutils@StrUpper$qqrpc equ @Sysutils@StrUpper$qqrpc
 extrn   @Sysutils@StrUpper$qqrpc:near
@@Passtr2@TPasString2@GetCount$qqrv equ @Passtr2@TPasString2@GetCount$qqrv
 extrn   @Passtr2@TPasString2@GetCount$qqrv:near
@@Passtr2@TPasString2@Get$qqri equ @Passtr2@TPasString2@Get$qqri
 extrn   @Passtr2@TPasString2@Get$qqri:near
@@Sysutils@AnsiStrPos$qqrpct1 equ @Sysutils@AnsiStrPos$qqrpct1
 extrn   @Sysutils@AnsiStrPos$qqrpct1:near
@@Controls@TControl@Show$qqrv equ @Controls@TControl@Show$qqrv
 extrn   @Controls@TControl@Show$qqrv:near
@_wsprintfA equ _wsprintfA
 extrn   _wsprintfA:near
@@Passtr2@TPasString2@Where$qqrpc equ @Passtr2@TPasString2@Where$qqrpc
 extrn   @Passtr2@TPasString2@Where$qqrpc:near
@@Passtr2@TPasString2@GetKeyValue$qqrv equ @Passtr2@TPasString2@GetKeyValue$qqrv
 extrn   @Passtr2@TPasString2@GetKeyValue$qqrv:near
@@Passtr2@TPasString2@Delete$qqri equ @Passtr2@TPasString2@Delete$qqri
 extrn   @Passtr2@TPasString2@Delete$qqri:near
@@Passtr2@TPasString2@Insert$qqripci equ @Passtr2@TPasString2@Insert$qqripci
 extrn   @Passtr2@TPasString2@Insert$qqripci:near
@@Forms@TCustomForm@Show$qqrv equ @Forms@TCustomForm@Show$qqrv
 extrn   @Forms@TCustomForm@Show$qqrv:near
@@Controls@TControl@Refresh$qqrv equ @Controls@TControl@Refresh$qqrv
 extrn   @Controls@TControl@Refresh$qqrv:near
@@Sysutils@AllocMem$qqrui equ @Sysutils@AllocMem$qqrui
 extrn   @Sysutils@AllocMem$qqrui:near
@@Passtr2@TPasString2@Setup$qqriioo equ @Passtr2@TPasString2@Setup$qqriioo
 extrn   @Passtr2@TPasString2@Setup$qqriioo:near
@@Passtr2@TPasString2@Clear$qqrv equ @Passtr2@TPasString2@Clear$qqrv
 extrn   @Passtr2@TPasString2@Clear$qqrv:near
@@Sysutils@FileOpen$qqrx17System@AnsiStringui equ @Sysutils@FileOpen$qqrx17System@AnsiStringui
 extrn   @Sysutils@FileOpen$qqrx17System@AnsiStringui:near
@@Sysutils@FileSeek$qqriii equ @Sysutils@FileSeek$qqriii
 extrn   @Sysutils@FileSeek$qqriii:near
@_memset equ _memset
 extrn   _memset:near
@@Sysutils@FileRead$qqripvui equ @Sysutils@FileRead$qqripvui
 extrn   @Sysutils@FileRead$qqripvui:near
@@System@$badd$qqrpxcrx17System@AnsiString equ @System@$badd$qqrpxcrx17System@AnsiString
 extrn   @System@$badd$qqrpxcrx17System@AnsiString:near
@@Sysutils@IntToHex$qqrii equ @Sysutils@IntToHex$qqrii
 extrn   @Sysutils@IntToHex$qqrii:near
@@Sysutils@FileClose$qqri equ @Sysutils@FileClose$qqri
 extrn   @Sysutils@FileClose$qqri:near
@@TPS2MAIN@MainPaint$qqrp14System@TObject equ @TPS2MAIN@MainPaint$qqrp14System@TObject
 extrn   @TPS2MAIN@MainPaint$qqrp14System@TObject:near
@@Controls@TControl@SetTextBuf$qqrpc equ @Controls@TControl@SetTextBuf$qqrpc
 extrn   @Controls@TControl@SetTextBuf$qqrpc:near
@@Sysutils@FileCreate$qqrx17System@AnsiString equ @Sysutils@FileCreate$qqrx17System@AnsiString
 extrn   @Sysutils@FileCreate$qqrx17System@AnsiString:near
@@Sysutils@FileWrite$qqripxvui equ @Sysutils@FileWrite$qqripxvui
 extrn   @Sysutils@FileWrite$qqripxvui:near
@@Controls@TControl@SetWidth$qqri equ @Controls@TControl@SetWidth$qqri
 extrn   @Controls@TControl@SetWidth$qqri:near
@@Controls@TControl@SetHeight$qqri equ @Controls@TControl@SetHeight$qqri
 extrn   @Controls@TControl@SetHeight$qqri:near
@@Forms@TCustomForm@$bctr$qqrp18Classes@TComponent equ @Forms@TCustomForm@$bctr$qqrp18Classes@TComponent
 extrn   @Forms@TCustomForm@$bctr$qqrp18Classes@TComponent:near
 extrn   @Forms@TForm@:byte
@@Classes@TComponent@SafeCallException$qqrp14System@TObjectpv equ @Classes@TComponent@SafeCallException$qqrp14System@TObjectpv
 extrn   @Classes@TComponent@SafeCallException$qqrp14System@TObjectpv:near
@@Forms@TCustomForm@AfterConstruction$qqrv equ @Forms@TCustomForm@AfterConstruction$qqrv
 extrn   @Forms@TCustomForm@AfterConstruction$qqrv:near
@@Forms@TCustomForm@BeforeDestruction$qqrv equ @Forms@TCustomForm@BeforeDestruction$qqrv
 extrn   @Forms@TCustomForm@BeforeDestruction$qqrv:near
@@System@TObject@Dispatch$qqrpv equ @System@TObject@Dispatch$qqrpv
 extrn   @System@TObject@Dispatch$qqrpv:near
@@Forms@TCustomForm@DefaultHandler$qqrpv equ @Forms@TCustomForm@DefaultHandler$qqrpv
 extrn   @Forms@TCustomForm@DefaultHandler$qqrpv:near
@@System@TObject@NewInstance$qqrp17System@TMetaClass equ @System@TObject@NewInstance$qqrp17System@TMetaClass
 extrn   @System@TObject@NewInstance$qqrp17System@TMetaClass:near
@@System@TObject@FreeInstance$qqrv equ @System@TObject@FreeInstance$qqrv
 extrn   @System@TObject@FreeInstance$qqrv:near
@@Controls@TWinControl@AssignTo$qqrp19Classes@TPersistent equ @Controls@TWinControl@AssignTo$qqrp19Classes@TPersistent
 extrn   @Controls@TWinControl@AssignTo$qqrp19Classes@TPersistent:near
@@Forms@TCustomForm@DefineProperties$qqrp14Classes@TFiler equ @Forms@TCustomForm@DefineProperties$qqrp14Classes@TFiler
 extrn   @Forms@TCustomForm@DefineProperties$qqrp14Classes@TFiler:near
@@Classes@TPersistent@Assign$qqrp19Classes@TPersistent equ @Classes@TPersistent@Assign$qqrp19Classes@TPersistent
 extrn   @Classes@TPersistent@Assign$qqrp19Classes@TPersistent:near
@@Forms@TCustomForm@Loaded$qqrv equ @Forms@TCustomForm@Loaded$qqrv
 extrn   @Forms@TCustomForm@Loaded$qqrv:near
@@Forms@TCustomForm@Notification$qqrp18Classes@TComponent18Classes@TOperation equ @Forms@TCustomForm@Notification$qqrp18Classes@TComponent18Classes@TOperation
 extrn   @Forms@TCustomForm@Notification$qqrp18Classes@TComponent18Classes@TOperation:near
@@Forms@TCustomForm@ReadState$qqrp15Classes@TReader equ @Forms@TCustomForm@ReadState$qqrp15Classes@TReader
 extrn   @Forms@TCustomForm@ReadState$qqrp15Classes@TReader:near
@@Controls@TControl@SetName$qqrx17System@AnsiString equ @Controls@TControl@SetName$qqrx17System@AnsiString
 extrn   @Controls@TControl@SetName$qqrx17System@AnsiString:near
@@Forms@TCustomForm@ValidateRename$qqrp18Classes@TComponentx17System@AnsiStringt2 equ @Forms@TCustomForm@ValidateRename$qqrp18Classes@TComponentx17System@AnsiStringt2
 extrn   @Forms@TCustomForm@ValidateRename$qqrp18Classes@TComponentx17System@AnsiStringt2:near
@@Classes@TComponent@WriteState$qqrp15Classes@TWriter equ @Classes@TComponent@WriteState$qqrp15Classes@TWriter
 extrn   @Classes@TComponent@WriteState$qqrp15Classes@TWriter:near
@@Forms@TCustomForm@QueryInterface$qqsrx5_GUIDpv equ @Forms@TCustomForm@QueryInterface$qqsrx5_GUIDpv
 extrn   @Forms@TCustomForm@QueryInterface$qqsrx5_GUIDpv:near
@@Controls@TWinControl@CanResize$qqrrit1 equ @Controls@TWinControl@CanResize$qqrrit1
 extrn   @Controls@TWinControl@CanResize$qqrrit1:near
@@Controls@TWinControl@CanAutoSize$qqrrit1 equ @Controls@TWinControl@CanAutoSize$qqrrit1
 extrn   @Controls@TWinControl@CanAutoSize$qqrrit1:near
@@Controls@TWinControl@ConstrainedResize$qqrrit1t1t1 equ @Controls@TWinControl@ConstrainedResize$qqrrit1t1t1
 extrn   @Controls@TWinControl@ConstrainedResize$qqrrit1t1t1:near
@@Controls@TWinControl@GetClientOrigin$qqrv equ @Controls@TWinControl@GetClientOrigin$qqrv
 extrn   @Controls@TWinControl@GetClientOrigin$qqrv:near
@@Forms@TCustomForm@GetClientRect$qqrv equ @Forms@TCustomForm@GetClientRect$qqrv
 extrn   @Forms@TCustomForm@GetClientRect$qqrv:near
@@Controls@TWinControl@GetDeviceContext$qqrrpv equ @Controls@TWinControl@GetDeviceContext$qqrrpv
 extrn   @Controls@TWinControl@GetDeviceContext$qqrrpv:near
@@Controls@TControl@GetDragImages$qqrv equ @Controls@TControl@GetDragImages$qqrv
 extrn   @Controls@TControl@GetDragImages$qqrv:near
@@Controls@TControl@GetEnabled$qqrv equ @Controls@TControl@GetEnabled$qqrv
 extrn   @Controls@TControl@GetEnabled$qqrv:near
@@Forms@TCustomForm@GetFloating$qqrv equ @Forms@TCustomForm@GetFloating$qqrv
 extrn   @Forms@TCustomForm@GetFloating$qqrv:near
@@Controls@TControl@GetFloatingDockSiteClass$qqrv equ @Controls@TControl@GetFloatingDockSiteClass$qqrv
 extrn   @Controls@TControl@GetFloatingDockSiteClass$qqrv:near
@@Controls@TControl@SetDragMode$qqr18Controls@TDragMode equ @Controls@TControl@SetDragMode$qqr18Controls@TDragMode
 extrn   @Controls@TControl@SetDragMode$qqr18Controls@TDragMode:near
@@Controls@TControl@SetEnabled$qqro equ @Controls@TControl@SetEnabled$qqro
 extrn   @Controls@TControl@SetEnabled$qqro:near
@@Forms@TCustomForm@SetParent$qqrp20Controls@TWinControl equ @Forms@TCustomForm@SetParent$qqrp20Controls@TWinControl
 extrn   @Forms@TCustomForm@SetParent$qqrp20Controls@TWinControl:near
@@Forms@TCustomForm@SetParentBiDiMode$qqro equ @Forms@TCustomForm@SetParentBiDiMode$qqro
 extrn   @Forms@TCustomForm@SetParentBiDiMode$qqro:near
@@Controls@TControl@SetBiDiMode$qqr17Classes@TBiDiMode equ @Controls@TControl@SetBiDiMode$qqr17Classes@TBiDiMode
 extrn   @Controls@TControl@SetBiDiMode$qqr17Classes@TBiDiMode:near
@@Forms@TCustomForm@WndProc$qqrr17Messages@TMessage equ @Forms@TCustomForm@WndProc$qqrr17Messages@TMessage
 extrn   @Forms@TCustomForm@WndProc$qqrr17Messages@TMessage:near
@@Controls@TControl@InitiateAction$qqrv equ @Controls@TControl@InitiateAction$qqrv
 extrn   @Controls@TControl@InitiateAction$qqrv:near
@@Controls@TWinControl@Invalidate$qqrv equ @Controls@TWinControl@Invalidate$qqrv
 extrn   @Controls@TWinControl@Invalidate$qqrv:near
@@Controls@TWinControl@Repaint$qqrv equ @Controls@TWinControl@Repaint$qqrv
 extrn   @Controls@TWinControl@Repaint$qqrv:near
@@Controls@TWinControl@SetBounds$qqriiii equ @Controls@TWinControl@SetBounds$qqriiii
 extrn   @Controls@TWinControl@SetBounds$qqriiii:near
@@Controls@TWinControl@Update$qqrv equ @Controls@TWinControl@Update$qqrv
 extrn   @Controls@TWinControl@Update$qqrv:near
@@Forms@TScrollingWinControl@AdjustClientRect$qqrr13Windows@TRect equ @Forms@TScrollingWinControl@AdjustClientRect$qqrr13Windows@TRect
 extrn   @Forms@TScrollingWinControl@AdjustClientRect$qqrr13Windows@TRect:near
@@Forms@TCustomForm@AlignControls$qqrp17Controls@TControlr13Windows@TRect equ @Forms@TCustomForm@AlignControls$qqrp17Controls@TControlr13Windows@TRect
 extrn   @Forms@TCustomForm@AlignControls$qqrp17Controls@TControlr13Windows@TRect:near
@@Controls@TWinControl@CreateHandle$qqrv equ @Controls@TWinControl@CreateHandle$qqrv
 extrn   @Controls@TWinControl@CreateHandle$qqrv:near
@@Forms@TCustomForm@CreateParams$qqrr22Controls@TCreateParams equ @Forms@TCustomForm@CreateParams$qqrr22Controls@TCreateParams
 extrn   @Forms@TCustomForm@CreateParams$qqrr22Controls@TCreateParams:near
@@Forms@TCustomForm@CreateWindowHandle$qqrrx22Controls@TCreateParams equ @Forms@TCustomForm@CreateWindowHandle$qqrrx22Controls@TCreateParams
 extrn   @Forms@TCustomForm@CreateWindowHandle$qqrrx22Controls@TCreateParams:near
@@Forms@TCustomForm@CreateWnd$qqrv equ @Forms@TCustomForm@CreateWnd$qqrv
 extrn   @Forms@TCustomForm@CreateWnd$qqrv:near
@@Forms@TCustomForm@DestroyWindowHandle$qqrv equ @Forms@TCustomForm@DestroyWindowHandle$qqrv
 extrn   @Forms@TCustomForm@DestroyWindowHandle$qqrv:near
@@Controls@TWinControl@DestroyWnd$qqrv equ @Controls@TWinControl@DestroyWnd$qqrv
 extrn   @Controls@TWinControl@DestroyWnd$qqrv:near
@@Controls@TWinControl@GetControlExtents$qqrv equ @Controls@TWinControl@GetControlExtents$qqrv
 extrn   @Controls@TWinControl@GetControlExtents$qqrv:near
@@Forms@TCustomForm@PaintWindow$qqrpv equ @Forms@TCustomForm@PaintWindow$qqrpv
 extrn   @Forms@TCustomForm@PaintWindow$qqrpv:near
@@Controls@TWinControl@ShowControl$qqrp17Controls@TControl equ @Controls@TWinControl@ShowControl$qqrp17Controls@TControl
 extrn   @Controls@TWinControl@ShowControl$qqrp17Controls@TControl:near
@@Forms@TCustomForm@SetFocus$qqrv equ @Forms@TCustomForm@SetFocus$qqrv
 extrn   @Forms@TCustomForm@SetFocus$qqrv:near
@@Forms@TScrollingWinControl@AutoScrollEnabled$qqrv equ @Forms@TScrollingWinControl@AutoScrollEnabled$qqrv
 extrn   @Forms@TScrollingWinControl@AutoScrollEnabled$qqrv:near
@@Forms@TScrollingWinControl@AutoScrollInView$qqrp17Controls@TControl equ @Forms@TScrollingWinControl@AutoScrollInView$qqrp17Controls@TControl
 extrn   @Forms@TScrollingWinControl@AutoScrollInView$qqrp17Controls@TControl:near
@@Forms@TCustomForm@Resizing$qqr18Forms@TWindowState equ @Forms@TCustomForm@Resizing$qqr18Forms@TWindowState
 extrn   @Forms@TCustomForm@Resizing$qqr18Forms@TWindowState:near
@@Forms@TCustomForm@DoCreate$qqrv equ @Forms@TCustomForm@DoCreate$qqrv
 extrn   @Forms@TCustomForm@DoCreate$qqrv:near
@@Forms@TCustomForm@DoDestroy$qqrv equ @Forms@TCustomForm@DoDestroy$qqrv
 extrn   @Forms@TCustomForm@DoDestroy$qqrv:near
@@Forms@TCustomForm@UpdateActions$qqrv equ @Forms@TCustomForm@UpdateActions$qqrv
 extrn   @Forms@TCustomForm@UpdateActions$qqrv:near
@@Forms@TCustomForm@CloseQuery$qqrv equ @Forms@TCustomForm@CloseQuery$qqrv
 extrn   @Forms@TCustomForm@CloseQuery$qqrv:near
@@Forms@TCustomForm@SetFocusedControl$qqrp20Controls@TWinControl equ @Forms@TCustomForm@SetFocusedControl$qqrp20Controls@TWinControl
 extrn   @Forms@TCustomForm@SetFocusedControl$qqrp20Controls@TWinControl:near
@@Forms@TCustomForm@ShowModal$qqrv equ @Forms@TCustomForm@ShowModal$qqrv
 extrn   @Forms@TCustomForm@ShowModal$qqrv:near
@@Forms@TCustomForm@WantChildKey$qqrp17Controls@TControlr17Messages@TMessage equ @Forms@TCustomForm@WantChildKey$qqrp17Controls@TControlr17Messages@TMessage
 extrn   @Forms@TCustomForm@WantChildKey$qqrp17Controls@TControlr17Messages@TMessage:near
 extrn   @Stdctrls@TLabel@:byte
 extrn   @Stdctrls@TComboBox@:byte
 extrn   @Stdctrls@TEdit@:byte
 extrn   @Stdctrls@TMemo@:byte
 extrn   @Stdctrls@TButton@:byte
 extrn   @Extctrls@TPanel@:byte
 extrn   @$xp$11Forms@TForm:byte
 extrn   __BeforeDestruction:near
 extrn   __ClassDestroy:near
@@System@AnsiString@$bctr$qqrrx17System@AnsiString equ @System@AnsiString@$bctr$qqrrx17System@AnsiString
 extrn   @System@AnsiString@$bctr$qqrrx17System@AnsiString:near
@@Classes@TComponent@UpdateRegistry$qqrp17System@TMetaClassox17System@AnsiStringt3 equ @Classes@TComponent@UpdateRegistry$qqrp17System@TMetaClassox17System@AnsiStringt3
 extrn   @Classes@TComponent@UpdateRegistry$qqrp17System@TMetaClassox17System@AnsiStringt3:near
 extrn   @Classes@TComponent@:byte
@@Forms@TCustomForm@$bctr$qqrp18Classes@TComponenti equ @Forms@TCustomForm@$bctr$qqrp18Classes@TComponenti
 extrn   @Forms@TCustomForm@$bctr$qqrp18Classes@TComponenti:near
@@Forms@TCustomForm@$bdtr$qqrv equ @Forms@TCustomForm@$bdtr$qqrv
 extrn   @Forms@TCustomForm@$bdtr$qqrv:near
@@Forms@TScrollingWinControl@$bdtr$qqrv equ @Forms@TScrollingWinControl@$bdtr$qqrv
 extrn   @Forms@TScrollingWinControl@$bdtr$qqrv:near
 extrn   @$bdele$qpv:near
@@Controls@TWinControl@$bdtr$qqrv equ @Controls@TWinControl@$bdtr$qqrv
 extrn   @Controls@TWinControl@$bdtr$qqrv:near
@@Controls@TControl@$bdtr$qqrv equ @Controls@TControl@$bdtr$qqrv
 extrn   @Controls@TControl@$bdtr$qqrv:near
@@Classes@TComponent@$bdtr$qqrv equ @Classes@TComponent@$bdtr$qqrv
 extrn   @Classes@TComponent@$bdtr$qqrv:near
@@Classes@TPersistent@$bdtr$qqrv equ @Classes@TPersistent@$bdtr$qqrv
 extrn   @Classes@TPersistent@$bdtr$qqrv:near
@@System@TObject@$bdtr$qqrv equ @System@TObject@$bdtr$qqrv
 extrn   @System@TObject@$bdtr$qqrv:near
 ?debug  C FB09474F5F52454D2E64666D00
 ?debug  C FB0A474F5F52454D00
 ?debug  C 9F757569642E6C6962
 ?debug  C 9F757569642E6C6962
 ?debug  C 9F757569642E6C6962
 ?debug  C 9F757569642E6C6962
 ?debug  C 9F76636C6535302E6C6962
	?debug	D "D:\BCBS\PS2\PASSTR2.hpp" 11125 18929
	?debug	D "D:\BCBS\PS2\PS2MAN.h" 10418 46960
	?debug	D "D:\BCBS\PS2\GENERAL.h" 10363 46459
	?debug	D "D:\BCBS\PS2\GO_REM.h" 11125 19367
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\CLIPBRD.HPP" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\transact.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\comsvcs.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\mtx.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\OleCtrls.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\DocObj.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\dlgs.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\oledlg.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\OleDlg.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\OleCtnrs.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\DBClient.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\DSIntf.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\Midas.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\Provider.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\databkr.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\ocidl.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\objsafe.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\ComObj.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\StdVCL.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\AxCtrls.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\stddef.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\ole2.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\propidl.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\msxml.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\servprov.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\oleidl.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\urlmon.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\objbase.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\alloc.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\malloc.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\tchar.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\dir.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\cguid.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\DBCommon.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\Bde.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\SMIntf.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\dbtables.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\Mask.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\Buttons.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\RichEdit.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\RichEdit.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\ToolWin.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\ComCtrls.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\Db.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\dbctrls.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\extctrls.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\commdlg.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\CommDlg.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\StdCtrls.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\shellapi.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\ShellAPI.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\regstr.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\RegStr.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\wininet.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\WinInet.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\objidl.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\oaidl.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\oleauto.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\ActiveX.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\UrlMon.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\ShlObj.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\dialogs.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\forms.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\multimon.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\MultiMon.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\Contnrs.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\Menus.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\Imm.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\CommCtrl.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\Commctrl.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\ImgList.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\ActnList.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\controls.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\graphics.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\classes.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\SysConst.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\sysutils.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\messages.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\dde.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\wincrypt.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\wintrust.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\SysInit.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\windows.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\unknwn.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\sysvari.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\sysopen.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\search.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\stdlib.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\sysdyn.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\systvar.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\sysset.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\syscomp.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\syscurr.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\systdate.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\systobj.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\rpcnsip.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\rpcndr.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\rpcnterr.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\rpcnsi.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\rpcdcep.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\rpcdce.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\rpc.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\wtypes.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\wstring.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\sysmac.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\dstring.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\sysclass.H" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\basetyps.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\prsht.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\winspool.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\imm.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\mcx.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\winsvc.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\winnetwk.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\winreg.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\winver.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\wincon.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\winnls.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\tvout.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\winuser.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\pshpack1.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\wingdi.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\winerror.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\winbase.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\pshpack8.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\pshpack2.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\poppack.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\pshpack4.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\_loc.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\locale.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\_str.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\string.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\guiddef.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\basetsd.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\mbctype.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\ctype.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\winnt.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\windef.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\stdarg.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\excpt.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\_null.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\_defs.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\_stddef.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\mem.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\windows.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\sysmac.H" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\system.hpp" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\vcl0.h" 10303 10240
	?debug	D "C:\PROGRAM FILES\BORLAND\CBUILDER5\INCLUDE\VCL\VCL3.H" 10303 10240
	?debug	D "D:\BCBS\PS2\GO_REM.cpp" 11125 19509
	end
