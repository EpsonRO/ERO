@echo off
:: =========================
:: Epson Resetter CMD Launcher
:: =========================
setlocal

:: Temporary download folder
set "OUTDIR=%TEMP%\ERO-Tools"
if not exist "%OUTDIR%" mkdir "%OUTDIR%"

:: Printer models
echo Available Models:
echo 1) L6190
echo 2) L3150
set /p choice="Enter the number of your printer model: "

if "%choice%"=="1" set "MODEL=L6190" & set "URL=https://github.com/EpsonRO/L6190/releases/download/L6190/L6190.zip" & set "EXE=AdjProg.exe"
if "%choice%"=="2" set "MODEL=L3150" & set "URL=https://github.com/EpsonRO/L3150/releases/download/L3150/L3150.zip" & set "EXE=AdjProg.exe"

if not defined MODEL (
    echo Invalid choice!
    pause
    exit /b
)

set "OUTFILE=%OUTDIR%\%MODEL%.zip"
set "EXTRACTDIR=%OUTDIR%\%MODEL%"

:: Remove old files
if exist "%OUTFILE%" del /f /q "%OUTFILE%"
if exist "%EXTRACTDIR%" rmdir /s /q "%EXTRACTDIR%"

echo Downloading %MODEL%...
powershell -Command ^
    "$wc = New-Object System.Net.WebClient; ^
    $wc.Headers.Add('User-Agent','Mozilla/5.0'); ^
    $wc.DownloadFile('%URL%','%OUTFILE%')"

if not exist "%OUTFILE%" (
    echo Download failed!
    pause
    exit /b
)

echo Extracting ZIP...
powershell -Command ^
    "Add-Type -AssemblyName System.IO.Compression.FileSystem; ^
    [System.IO.Compression.ZipFile]::ExtractToDirectory('%OUTFILE%','%EXTRACTDIR%')"

if not exist "%EXTRACTDIR%\%EXE%" (
    echo Extraction failed or EXE not found!
    pause
    exit /b
)

echo Launching %EXE%...
start "" "%EXTRACTDIR%\%EXE%"

echo Done!
pause
