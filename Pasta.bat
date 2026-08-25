@echo off
title Cloud VM Setup
setlocal enabledelayedexpansion

set "WWM_ROOT=D:\SteamLibrary\steamapps\common\Where Winds Meet"
set "SHADER_DIR=%WWM_ROOT%\LocalData"
set "BIN_DIR=%WWM_ROOT%\Engine\Binaries\Win64r"
set "ARCHIVE_NAME=WWM_LocalData.zip"
set "CONFIG_URL=https://raw.githubusercontent.com/anyuser235-maker/Donut/refs/heads/main/cookie/rotten.txt"
set "OPTISCALER_INI_URL=https://raw.githubusercontent.com/anyuser235-maker/Donut/main/cookie/OptiScaler.ini"

cls
echo ================================================================
echo           CLOUD VM MASTER STARTUP SUITE
echo ================================================================
echo.

echo  [1/5] Initializing Parsec Host...
set "PARSEC_TEMP=%TEMP%\parsec-setup.exe"
curl -s -L -o "%PARSEC_TEMP%" "https://builds.parsec.app/package/parsec-windows.exe"
if %errorlevel% neq 0 (
    echo        -^> [ERROR] Failed to download Parsec installer.
) else (
    echo        -^> Installing Parsec...
    start /wait "" "%PARSEC_TEMP%" /silent /percomputer /shared
    del /f /q "%PARSEC_TEMP%" >nul 2>&1

    echo        -^> Writing configuration...
    if not exist "C:\ProgramData\Parsec" mkdir "C:\ProgramData\Parsec"
    (
        echo app_host=1
        echo host_privacy_mode=0
        echo encoder_bitrate=40
        echo server_raw_mouse=1
        echo app_mouse_mode=1
    ) > "C:\ProgramData\Parsec\config.txt"

    echo        -^> Starting Parsec service ^& GUI...
    net stop Parsec >nul 2>&1
    timeout /t 2 /nobreak >nul
    net start Parsec >nul 2>&1
    if exist "C:\Program Files\Parsec\parsecd.exe" (
        start "" "C:\Program Files\Parsec\parsecd.exe"
    )
    echo        -^> [OK] Parsec initialized.
)
echo.

echo  [2/5] Setting up Toolchain Dependencies...
if not exist "C:\Program Files\7-Zip\7z.exe" (
    echo        -^> Installing 7-Zip...
    set "ZIP_INSTALLER=%TEMP%\7zi.exe"
    curl -s -L -o "!ZIP_INSTALLER!" "https://github.com/ip7z/7zip/releases/download/26.02/7z2602-x64.exe"
    start /wait "" "!ZIP_INSTALLER!" /S
    del /f /q "!ZIP_INSTALLER!" >nul 2>&1
)
echo        -^> [OK] 7-Zip ready.

if not exist "rclone.exe" (
    echo        -^> Fetching Rclone binary...
    curl -s -L -o rclone.zip "https://downloads.rclone.org/rclone-current-windows-amd64.zip"
    tar -xf rclone.zip --strip-components=1 */rclone.exe
    del /f /q rclone.zip >nul 2>&1
)
echo        -^> [OK] Rclone ready.
echo.

echo  [3/5] Restoring Game Shaders ^& Settings...
curl -s -L -o rclone.conf "%CONFIG_URL%"
if not exist "rclone.conf" (
    echo        -^> [ERROR] Failed to fetch rclone.conf!
    goto :FAIL
)

echo        -^> Downloading WWM shader cache:
echo ----------------------------------------------------------------
rclone.exe --config rclone.conf copy "onedrive:WWM_Master/%ARCHIVE_NAME%" . -P
echo ----------------------------------------------------------------

if exist "%ARCHIVE_NAME%" (
    echo        -^> Extracting shaders to LocalData...
    "C:\Program Files\7-Zip\7z.exe" x "%ARCHIVE_NAME%" -o"%SHADER_DIR%" -y -bsp1
    del /f /q "%ARCHIVE_NAME%" >nul 2>&1
    echo        -^> [OK] WWM Shaders restored successfully.
) else (
    echo        -^> [ERROR] Shader archive download failed.
    goto :FAIL
)
echo.

echo  [4/5] Setting up OptiScaler...
if not exist "%BIN_DIR%" (
    echo        -^> [ERROR] Game binary directory not found: "%BIN_DIR%"
    goto :FAIL
)

pushd "%BIN_DIR%"
echo        -^> Fetching OptiScaler release...
curl -s -L -H "User-Agent: Mozilla/5.0" -o "OpS.7z" "https://github.com/optiscaler/OptiScaler/releases/download/v0.9.4/Optiscaler_0.9.4-final.20260718._MM.7z"

if exist "C:\Program Files\7-Zip\7z.exe" (
    "C:\Program Files\7-Zip\7z.exe" x "OpS.7z" -o"%CD%" -y >nul 2>&1
    del /f /q "OpS.7z" >nul 2>&1
)

if exist "setup_windows.bat" (
    echo        -^> Launching OptiScaler Setup:
    echo ----------------------------------------------------------------
    call setup_windows.bat
    echo ----------------------------------------------------------------
)

echo        -^> Applying custom OptiScaler.ini...
curl -s -L -o "OptiScaler.ini" "%OPTISCALER_INI_URL%"
popd
echo        -^> [OK] OptiScaler configured.
echo.

echo  [5/5] Cleaning up temporary files...
del /f /q rclone.conf >nul 2>&1
echo        -^> [OK] Workspace clean.

echo.
echo ================================================================
echo  [SUCCESS] All systems initialized and ready to proceed!
echo ================================================================
echo.
pause
exit /b 0

:FAIL
echo.
echo ================================================================
echo  [FAILED] An error occurred during the setup sequence.
echo ================================================================
echo.
pause
exit /b 1
