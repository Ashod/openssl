
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

perl Configure VC-WIN64A enable-static-engine --prefix=.\bin\%VSNAME%\x64\dll
@if errorlevel 1 goto end

perl util\mkfiles.pl >MINFO

cmd /c "nasm -f win64 -v" >NUL 2>&1
if %errorlevel% neq 0 goto ml64

perl ms\uplink-x86_64.pl nasm > ms\uptable.asm
nasm -f win64 -o ms\uptable.obj ms\uptable.asm
goto proceed

:ml64
perl ms\uplink-x86_64.pl masm > ms\uptable.asm
ml64 -c -Foms\uptable.obj ms\uptable.asm

:proceed
perl util\mk1mf.pl TMP=tmp OUT=out_%VSNAME%_x64 INC=inc VC-WIN64A >ms\nt.mak
perl util\mk1mf.pl TMP=tmp OUT=out_%VSNAME%_x64_debug INC=inc debug VC-WIN64A >ms\nt.dbg.mak
perl util\mk1mf.pl TMP=tmp OUT=out_%VSNAME%_x64_dll INC=inc dll VC-WIN64A >ms\ntdll.mak
perl util\mk1mf.pl TMP=tmp OUT=out_%VSNAME%_x64_dll_debug INC=inc debug dll VC-WIN64A >ms\ntdll.dbg.mak

perl util\mkdef.pl 32 libeay > ms\libeay32.def
perl util\mkdef.pl 32 ssleay > ms\ssleay32.def
@if errorlevel 1 goto end

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