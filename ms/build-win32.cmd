
set VSNAME=vs
IF exist "%VS110COMNTOOLS%" (
set VSNAME=vs2012
) ELSE IF exist "%VS100COMNTOOLS%" (
set VSNAME=vs2010
) ELSE IF exist "%VS90COMNTOOLS%" (
set VSNAME=vs2008
) ELSE IF exist "%VS80COMNTOOLS%" (
set VSNAME=vs2005
) ELSE (
@echo "No Visual Studio installation found. Assuming unknown version..."
)

perl Configure VC-WIN32 enable-static-engine --prefix=.\bin\%VSNAME%\x86\dll
@if errorlevel 1 goto end

perl util\mkfiles.pl >MINFO
perl util\mk1mf.pl TMP=tmp OUT=out_%VSNAME%_x86 INC=inc nasm VC-WIN32 >ms\nt.mak
perl util\mk1mf.pl TMP=tmp OUT=out_%VSNAME%_x86_debug INC=inc nasm debug VC-WIN32 >ms\nt.dbg.mak
perl util\mk1mf.pl TMP=tmp OUT=out_%VSNAME%_x86_dll INC=inc nasm dll VC-WIN32 >ms\ntdll.mak
perl util\mk1mf.pl TMP=tmp OUT=out_%VSNAME%_x86_dll_debug INC=inc nasm debug dll VC-WIN32 >ms\ntdll.dbg.mak

perl util\mkdef.pl 32 libeay > ms\libeay32.def
perl util\mkdef.pl 32 ssleay > ms\ssleay32.def

@echo Building Release DLL
rmdir /s /q tmp
rmdir /s /q inc
nmake -f ms\ntdll.mak
@if errorlevel 1 goto end

@echo Testing Release DLL
nmake -f ms\ntdll.mak test
@if errorlevel 1 goto end

@echo Installing Release DLL
nmake -f ms\ntdll.mak install
@if errorlevel 1 goto end

@echo Building Debug DLL
rmdir /s /q tmp
rmdir /s /q inc
nmake -f ms\ntdll.dbg.mak
@if errorlevel 1 goto end

@echo Testing Debug DLL
nmake -f ms\ntdll.dbg.mak test
@if errorlevel 1 goto end

@echo Installing Debug DLL
nmake -f ms\ntdll.dbg.mak install
@if errorlevel 1 goto end

@echo Building Release
rmdir /s /q tmp
rmdir /s /q inc
nmake -f ms\nt.mak
@if errorlevel 1 goto end

@echo Testing Release
nmake -f ms\nt.mak test
@if errorlevel 1 goto end

@echo Installing Release
nmake -f ms\nt.mak install
@if errorlevel 1 goto end

@echo Building Debug
rmdir /s /q tmp
rmdir /s /q inc
nmake -f ms\nt.dbg.mak
@if errorlevel 1 goto end

@echo Testing Debug
nmake -f ms\nt.dbg.mak test
@if errorlevel 1 goto end

@echo Installing Debug
nmake -f ms\nt.dbg.mak install
@if errorlevel 1 goto end

:end