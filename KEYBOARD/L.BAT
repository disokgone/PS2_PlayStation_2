rem call aa scancode
rem call aa mkscan
rem call aa EMUINT16
rem call cc UASM
del PSDEB.LIB
del SIOS.LIB
psylib /a PSDEB DEB.O HELP.O R3K.O NEWDEB.O REGWORK.O UASM.O
psylib /a SIOS EMUINT16.o mkscan.o scancode.o SIOKBD.O
