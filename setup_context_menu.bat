@echo off
setlocal

if /I "%~1"=="uninstall" goto uninstall
if /I "%~1"=="remove" goto uninstall
if /I "%~1"=="-" goto help
if /I "%~1"=="/?" goto help
if /I "%~1"=="--help" goto help
goto install

:common_paths
set "REG_PATH=HKCU\Software\Classes\SystemFileAssociations\.pdf\shell\MergePDFDirect"
set "OLD_REG_PATH=HKCU\Software\Classes\SystemFileAssociations\.pdf\shell\MergePDF"
set "OLD_ADMIN_REG_PATH=HKCR\SystemFileAssociations\.pdf\shell\MergePDF"
set "SENDTO=%APPDATA%\Microsoft\Windows\SendTo"
set "LAUNCHER=%~dp0merge_pdf_sendto.vbs"
set "OLD_SENDTO_VBS=%SENDTO%\Merge PDF.vbs"
set "OLD_SENDTO_BAT=%SENDTO%\Merge PDF.bat"
for /f "usebackq delims=" %%i in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "Join-Path '%SENDTO%' (([string]::Concat([char]21512,[char]24182,'PDF')) + '.lnk')"`) do set "SENDTO_LINK=%%i"
for /f "usebackq delims=" %%i in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "Join-Path '%SENDTO%' (([string]::Concat([char]21512,[char]24182,'PDF')) + '.vbs')"`) do set "OLD_SENDTO_CN_VBS=%%i"
exit /b 0

:find_python
set "PYTHON_CMD="
for %%p in (python python3 py) do (
    if not defined PYTHON_CMD (
        %%p --version >nul 2>&1 && set "PYTHON_CMD=%%p"
    )
)

if not defined PYTHON_CMD (
    echo [ERROR] Python was not found. Please install Python 3.8+ first.
    exit /b 1
)
echo [OK] Python command: %PYTHON_CMD%

set "PYTHON_EXE="
for /f "usebackq delims=" %%i in (`%PYTHON_CMD% -c "import sys; print(sys.executable)"`) do set "PYTHON_EXE=%%i"
if not defined PYTHON_EXE (
    echo [ERROR] Could not locate python.exe.
    exit /b 1
)
echo [OK] python.exe: %PYTHON_EXE%

for %%i in ("%PYTHON_EXE%") do set "PYTHONW_EXE=%%~dpipythonw.exe"
if not exist "%PYTHONW_EXE%" (
    echo [ERROR] pythonw.exe was not found next to python.exe.
    echo Expected: %PYTHONW_EXE%
    exit /b 1
)
echo [OK] pythonw.exe: %PYTHONW_EXE%
exit /b 0

:install
echo.
echo PDF direct merge tool - install context menu
echo.

call :common_paths
call :find_python
if errorlevel 1 (
    pause
    exit /b 1
)

set "SCRIPT=%~dp0merge_pdf_direct.py"
if not exist "%SCRIPT%" (
    echo [ERROR] merge_pdf_direct.py was not found.
    echo Please keep this setup script in the same folder as merge_pdf_direct.py.
    pause
    exit /b 1
)
echo [OK] Merge script: %SCRIPT%

set "EXISTING=0"
reg query "%REG_PATH%" >nul 2>&1 && set "EXISTING=1"
reg query "%OLD_REG_PATH%" >nul 2>&1 && set "EXISTING=1"
reg query "%OLD_ADMIN_REG_PATH%" >nul 2>&1 && set "EXISTING=1"
if exist "%SENDTO_LINK%" set "EXISTING=1"
if exist "%OLD_SENDTO_VBS%" set "EXISTING=1"
if exist "%OLD_SENDTO_CN_VBS%" set "EXISTING=1"
if exist "%OLD_SENDTO_BAT%" set "EXISTING=1"

if "%EXISTING%"=="1" (
    echo.
    echo [INFO] Existing PDF merge context menu or SendTo shortcut detected.
    choice /C YN /M "Overwrite installation"
    if errorlevel 2 (
        echo Installation cancelled.
        pause
        exit /b 0
    )
)

echo.
echo [*] Installing Python dependency: pypdf
"%PYTHON_EXE%" -m pip install pypdf --quiet
if errorlevel 1 (
    echo [ERROR] Failed to install pypdf.
    echo Please run manually:
    echo   "%PYTHON_EXE%" -m pip install pypdf
    pause
    exit /b 1
)
echo [OK] pypdf is ready.

echo.
echo [*] Writing PDF context menu...
powershell -NoProfile -ExecutionPolicy Bypass -Command "New-Item -Path 'Registry::%REG_PATH%' -Force | Out-Null; Set-Item -Path 'Registry::%REG_PATH%' -Value ([string]::Concat([char]21512,[char]24182,'PDF'))" >nul
reg add "%REG_PATH%" /v "Icon" /d "shell32.dll,70" /f >nul
reg add "%REG_PATH%\command" /ve /d "\"%PYTHONW_EXE%\" \"%SCRIPT%\" \"%%1\"" /f >nul
if errorlevel 1 (
    echo [ERROR] Failed to write context menu registry entries.
    pause
    exit /b 1
)
echo [OK] PDF context menu added.

echo.
echo [*] Creating hidden SendTo launcher for multiple selected PDF files...
if not exist "%SENDTO%" mkdir "%SENDTO%"
if exist "%OLD_SENDTO_BAT%" del "%OLD_SENDTO_BAT%"
if exist "%OLD_SENDTO_VBS%" del "%OLD_SENDTO_VBS%"
if exist "%OLD_SENDTO_CN_VBS%" del "%OLD_SENDTO_CN_VBS%"
if exist "%SENDTO_LINK%" del "%SENDTO_LINK%"
(
    echo Set shell = CreateObject^("WScript.Shell"^)
    echo args = ""
    echo For Each item In WScript.Arguments
    echo     args = args ^& " " ^& Chr^(34^) ^& item ^& Chr^(34^)
    echo Next
    echo cmd = Chr^(34^) ^& "%PYTHONW_EXE%" ^& Chr^(34^) ^& " " ^& Chr^(34^) ^& "%SCRIPT%" ^& Chr^(34^) ^& args
    echo shell.Run cmd, 0, False
) > "%LAUNCHER%"
if errorlevel 1 (
    echo [ERROR] Failed to create hidden launcher.
    pause
    exit /b 1
)
for /f "usebackq delims=" %%i in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('%SENDTO_LINK%'); $s.TargetPath=(Join-Path $env:SystemRoot 'System32\wscript.exe'); $s.Arguments=([char]34 + '%LAUNCHER%' + [char]34); $s.IconLocation='shell32.dll,70'; $s.Save(); Write-Output '%SENDTO_LINK%'"`) do set "SENDTO_LINK=%%i"
if errorlevel 1 (
    echo [ERROR] Failed to create SendTo shortcut.
    pause
    exit /b 1
)
echo [OK] %SENDTO_LINK%

set "TC_HINT=%~dp0tc_usermenu_hint.txt"
(
    echo Total Commander user menu configuration
    echo.
    echo Menu item name:
    echo   Direct Merge PDF
    echo.
    echo Command:
    echo   %PYTHONW_EXE%
    echo.
    echo Parameters:
    echo   "%SCRIPT%" %%L
    echo.
    echo Notes:
    echo   merge_pdf_direct.py can read the temporary file list generated by %%L.
    echo   The output file is saved next to the first PDF as merged.pdf.
    echo   If merged.pdf already exists, merged_001.pdf, merged_002.pdf, etc. is used.
    echo   Successful merges are silent. Only errors display a message.
) > "%TC_HINT%"
echo [OK] Total Commander hint generated: %TC_HINT%

echo.
echo Installation completed.
echo.
echo Windows Explorer:
echo   Select multiple PDF files - Right click - Send to - Chinese menu item for Merge PDF
echo.
echo Behavior:
echo   Successful merges are silent.
echo   Error cases display a message box.
echo.
pause
exit /b 0

:uninstall
echo.
echo PDF direct merge tool - uninstall context menu
echo.

call :common_paths

set "FOUND=0"
reg query "%REG_PATH%" >nul 2>&1 && set "FOUND=1"
reg query "%OLD_REG_PATH%" >nul 2>&1 && set "FOUND=1"
reg query "%OLD_ADMIN_REG_PATH%" >nul 2>&1 && set "FOUND=1"
if exist "%OLD_SENDTO_VBS%" set "FOUND=1"
if exist "%SENDTO_LINK%" set "FOUND=1"
if exist "%OLD_SENDTO_CN_VBS%" set "FOUND=1"
if exist "%OLD_SENDTO_BAT%" set "FOUND=1"
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
if exist "%OLD_SENDTO_VBS%" del "%OLD_SENDTO_VBS%"
if exist "%SENDTO_LINK%" del "%SENDTO_LINK%"
if exist "%OLD_SENDTO_CN_VBS%" del "%OLD_SENDTO_CN_VBS%"
if exist "%OLD_SENDTO_BAT%" del "%OLD_SENDTO_BAT%"
if exist "%LAUNCHER%" del "%LAUNCHER%"

echo.
echo Uninstall completed.
echo If Explorer does not refresh immediately, restart Explorer or sign in again.
echo.
pause
exit /b 0

:help
echo.
echo PDF direct merge tool setup
echo.
echo Usage:
echo   setup_context_menu.bat
echo   setup_context_menu.bat uninstall
echo.
exit /b 0
