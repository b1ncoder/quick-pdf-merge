@echo off
setlocal

echo.
echo PDF direct merge tool - uninstall context menu
echo.

set "REG_PATH=HKCU\Software\Classes\SystemFileAssociations\.pdf\shell\MergePDFDirect"
set "OLD_REG_PATH=HKCU\Software\Classes\SystemFileAssociations\.pdf\shell\MergePDF"
set "OLD_ADMIN_REG_PATH=HKCR\SystemFileAssociations\.pdf\shell\MergePDF"
set "SENDTO=%APPDATA%\Microsoft\Windows\SendTo"
set "SENDTO_VBS=%SENDTO%\Merge PDF.vbs"
set "SENDTO_BAT=%SENDTO%\Merge PDF.bat"
set "LAUNCHER=%~dp0merge_pdf_sendto.vbs"
for /f "usebackq delims=" %%i in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "Join-Path '%SENDTO%' (([string]::Concat([char]21512,[char]24182,'PDF')) + '.lnk')"`) do set "SENDTO_CN_LNK=%%i"
for /f "usebackq delims=" %%i in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "Join-Path '%SENDTO%' (([string]::Concat([char]21512,[char]24182,'PDF')) + '.vbs')"`) do set "SENDTO_CN_VBS=%%i"

set "FOUND=0"
reg query "%REG_PATH%" >nul 2>&1 && set "FOUND=1"
reg query "%OLD_REG_PATH%" >nul 2>&1 && set "FOUND=1"
reg query "%OLD_ADMIN_REG_PATH%" >nul 2>&1 && set "FOUND=1"
if exist "%SENDTO_VBS%" set "FOUND=1"
if exist "%SENDTO_CN_LNK%" set "FOUND=1"
if exist "%SENDTO_CN_VBS%" set "FOUND=1"
if exist "%SENDTO_BAT%" set "FOUND=1"
if exist "%LAUNCHER%" set "FOUND=1"

if "%FOUND%"=="0" (
    echo [INFO] No installed PDF merge context menu was detected.
    pause
    exit /b 0
)

choice /C YN /M "Remove PDF merge context menu"
if errorlevel 2 (
    echo Uninstall cancelled.
    pause
    exit /b 0
)

reg delete "%REG_PATH%" /f >nul 2>&1
reg delete "%OLD_REG_PATH%" /f >nul 2>&1
reg delete "%OLD_ADMIN_REG_PATH%" /f >nul 2>&1
if exist "%SENDTO_VBS%" del "%SENDTO_VBS%"
if exist "%SENDTO_CN_LNK%" del "%SENDTO_CN_LNK%"
if exist "%SENDTO_CN_VBS%" del "%SENDTO_CN_VBS%"
if exist "%SENDTO_BAT%" del "%SENDTO_BAT%"
if exist "%LAUNCHER%" del "%LAUNCHER%"

echo.
echo Uninstall completed.
echo If Explorer does not refresh immediately, restart Explorer or sign in again.
echo.
pause
