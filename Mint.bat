@echo off
setlocal EnableDelayedExpansion

:: ====================================================================
:: SECTION 1: Parsec Installation & Remote Config
:: ====================================================================
echo [1/2] Setting up Parsec...

set "PARSEC_TEMP=%TEMP%\parsec-setup.exe"
curl -L -o "%PARSEC_TEMP%" "https://builds.parsec.app/package/parsec-windows.exe"
if %errorlevel% neq 0 (
    echo [-] Failed to download Parsec installer.
) else (
    echo [*] Installing Parsec silently...
    start /wait "" "%PARSEC_TEMP%" /silent /percomputer /shared
    del /f /q "%PARSEC_TEMP%" 2>nul

    echo [*] Writing Parsec configuration...
    if not exist "C:\ProgramData\Parsec" mkdir "C:\ProgramData\Parsec"
    (
        echo app_host=1
        echo host_privacy_mode=0
        echo encoder_bitrate=40
        echo server_raw_mouse=1
        echo app_mouse_mode=1
    ) > "C:\ProgramData\Parsec\config.txt"

    echo [*] Restarting Parsec service...
    net stop Parsec >nul 2>&1
    timeout /t 2 /nobreak >nul
    net start Parsec >nul 2>&1

    echo [*] Launching Parsec GUI...
    if exist "C:\Program Files\Parsec\parsecd.exe" (
        start "" "C:\Program Files\Parsec\parsecd.exe"
    )
)

:: ====================================================================
:: SECTION 2: 7-Zip & OptiScaler Setup
:: ====================================================================
echo.
echo [2/2] Setting up OptiScaler...

set "GAME_DIR=D:\SteamLibrary\steamapps\common\Where Winds Meet\Engine\Binaries\Win64r"

if not exist "%GAME_DIR%" (
    echo [-] Game directory not found: "%GAME_DIR%"
    goto :finish
)

cd /d "%GAME_DIR%"

:: Install 7-Zip to %TEMP% so game folder stays clean
set "ZIP_INSTALLER=%TEMP%\7zi.exe"
curl -L -o "%ZIP_INSTALLER%" "https://github.com/ip7z/7zip/releases/download/26.02/7z2602-x64.exe"
start /wait "" "%ZIP_INSTALLER%" /S
del /f /q "%ZIP_INSTALLER%" 2>nul

:: Download and extract OptiScaler
curl -L -H "User-Agent: Mozilla/5.0" -o "OpS.7z" "https://github.com/optiscaler/OptiScaler/releases/download/v0.9.4/Optiscaler_0.9.4-final.20260718._MM.7z"

if exist "C:\Program Files\7-Zip\7z.exe" (
    "C:\Program Files\7-Zip\7z.exe" x "OpS.7z" -o"%CD%" -y
    del /f /q "OpS.7z"
) else (
    echo [-] 7-Zip executable not found at C:\Program Files\7-Zip\7z.exe
)

:: Run setup_windows.bat if present
if exist "setup_windows.bat" (
    echo [*] Running setup_windows.bat...
    start /wait cmd /c setup_windows.bat
)

:: Download custom INI
curl -L -o "OptiScaler.ini" "https://raw.githubusercontent.com/anyuser235-maker/Donut/main/cookie/OptiScaler.ini"

:finish
echo.
echo [+] All startup tasks completed.
endlocal
