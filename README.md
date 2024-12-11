# PS2_PlayStation_2
some programs for PlayStation 2 (needs some program files from in ps2dev, gcc ..)

Most of the programs needs [psexe.com] to transmit the data and executive files to PS2 via a PL2301 or PL2302 cable which worked with USB ports of PS2 and computer.
I preserved some .o (object) files because you may not have a complete compiler system to rebuild it.
Some .REM files were remark text used in my MIPS R3000/R5000 disassembler.

*** ps2lib was the first library to be released. Created by Gustavo Scotti, the library was released in October 2001.  (this text line was copied from ps2dev)
*** Thanks to Gustavo Scotti (gustavo@scotti.com) ***

[8x8 Font Test]  Try to show DOS 8x12 font to PS2 screen.

[GameSaveFor_PS2MC\BISLPM-62005XXXXXXXX] Some files downloaded from a PS2 memory card for use in PS2MC project below. (OpenGL was used to show 3D animation images.)

[Graph Test] Heximal dump from 0x420000 (length = 0x1000) to PS2 screen.

[MemCard Test] Simple test exist or not of PS2 memory card and print result in text to computer.

[MyFont Test] Chinese 16x15 and 24x24 font test, you can change font size by press [SELECT] key.

You may hit [L1] key to < LoadExecPS2("cdrom0:\\NAPLINK.ELF;1", 0, 0) >.

You may hit [R1] key to < LoadExecPS2("cdrom0:\\3_STARS.EXE;1", 0, 0) >.

You may hit [L2] key to < j 0xA0000 >.

[PS2 disAsm 2001] A computer program to disassemble .ELF file for PS2 CPU (R5900).

[PS2MC] Please run MyUSB.exe to perform USB upload/download game data access on PS2.

MyUSB.exe uses USBIO library. Need to pay for comercial use !

** USBIO is a good tool to help us to access USB devices. You can reach the company for more information here:

https://www.thesycon.de/eng/company_overview.shtml

[mini Game Hacker] Use gamepad to edit the memory address to do a heximal data dump (show) on PS2 screen, this is useful to examine memory contents when a program/game halted or died.


There were some infomations (file date/time/size) about the files to build correct ELF file to execute on a PS2 machine.
(I may change or add new items below in the future...)

PSYMAKE.COM  -- File date: 1995-04-12  18:54    File size:  19360 bytes.

PSYLIB.EXE   -- File date: 1995-11-08  22:59    File size: 105897 bytes.

PSEXE.COM    -- File date: 1998-04-01  13:19    File size:   6673 bytes.

CPE2X.COM    -- File date: 1999-01-14  00:33    File size:  35252 bytes.

AA.BAT       -- File date: 1999-05-18  15:23    File size:     58 bytes.

CC.BAT       -- File date: 1999-05-25  15:22    File size:     42 bytes.

LD2.BAT      -- File date: 2001-11-27  14:50    File size:     90 bytes.

from /usr/local/sce/ee/gcc .......

CC1.EXE      -- File date: 2001-12-15  22:37    File size:4822451 bytes.

EE-GCC.EXE   -- File date: 2001-12-15  22:37    File size: 168795 bytes.

EE-AS.EXE    -- File date: 2001-12-15  22:38    File size: 756957 bytes.

EE-OBJDUMP.EXE  File date: 2001-12-15  22:38    File size: 690964 bytes.

EE-STRIP.EXE -- File date: 2001-12-15  22:38    File size: 658481 bytes.

EE-LD.EXE    -- File date: 2001-12-15  22:39    File size: 628989 bytes.


