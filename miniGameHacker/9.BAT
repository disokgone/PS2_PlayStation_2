cls
@echo off
set PSYQ_PATH=d:\psx
@echo on
psymake /f H.MAK
@echo off
rem pause
if errorlevel 1 goto err_exit
   @echo on
   cpe2x H.CPE
   if errorlevel 1 goto err_exit
   del *.CPE
rem  goto err_exit
   d:\psx2\psexe 8x8.FON /d40000
   d:\psx2\psexe H.EXE
   @echo off
:err_exit

