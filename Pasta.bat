@echo off
title Cloud VM Setup
setlocal enabledelayedexpansion

set "WWM_ROOT=D:\SteamLibrary\steamapps\common\Where Winds Meet"
set "SHADER_DIR=%WWM_ROOT%\LocalData"
set "BIN_DIR=%WWM_ROOT%\Engine\Binaries\Win64r"
set "ARCHIVE_NAME=WWM_LocalData.zip"
set "CONFIG_URL=https://raw.githubusercontent.com/anyuser235-maker/Donut/refs/heads/main/cookie/rotten.txt"
set "OPTISCALER_INI_URL=https://raw.githubusercontent.com/anyuser235-maker/Donut/main/cookie/OptiScaler.ini"
set "SEVENZIP=%ProgramFiles%\7-Zip\7z.exe"

set "START_DIR=%~dp0"
if "%START_DIR%"=="" set "START_DIR=%CD%"
if "%START_DIR:~-1%"=="\" set "START_DIR=%START_DIR:~0,-1%"

cd /d "%START_DIR%"

cls
echo ================================================================
echo            CLOUD VM MASTER STARTUP SUITE
echo ================================================================
echo.

echo  [1/5] Initializing Parsec Host...
set "PARSEC_TEMP=%TEMP%\parsec-setup.exe"
curl -fsSL -o "%PARSEC_TEMP%" "https://builds.parsec.app/package/parsec-windows.exe"
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
    if exist "%ProgramFiles%\Parsec\parsecd.exe" (
        start "" "%ProgramFiles%\Parsec\parsecd.exe"
    )
    echo        -^> [OK] Parsec initialized.
)
echo.

echo  [2/5] Setting up Toolchain Dependencies...
if not exist "%SEVENZIP%" (
    echo        -^> Installing 7-Zip...
    set "ZIP_INSTALLER=%TEMP%\7zi.exe"
    curl -fsSL -o "%ZIP_INSTALLER%" "https://github.com/ip7z/7zip/releases/download/26.02/7z2602-x64.exe"
    if %errorlevel% neq 0 (
        echo        -^> [ERROR] Failed to download 7-Zip installer.
        goto :FAIL
    )
    start /wait "" "%ZIP_INSTALLER%" /S
    del /f /q "%ZIP_INSTALLER%" >nul 2>&1
)
if not exist "%SEVENZIP%" (
    echo        -^> [ERROR] 7-Zip is still not installed after setup attempt.
    goto :FAIL
)
echo        -^> [OK] 7-Zip ready.

if not exist "%START_DIR%\rclone.exe" (
    echo        -^> Fetching Rclone binary...
    curl -fsSL -o "%START_DIR%\rclone.zip" "https://downloads.rclone.org/rclone-current-windows-amd64.zip"
    if %errorlevel% neq 0 (
        echo        -^> [ERROR] Failed to download Rclone.
        goto :FAIL
    )
    echo        -^> Extracting Rclone binary...
    "%SEVENZIP%" e "%START_DIR%\rclone.zip" -o"%START_DIR%\" rclone.exe -r -y >nul 2>&1
    del /f /q "%START_DIR%\rclone.zip" >nul 2>&1
)
if not exist "%START_DIR%\rclone.exe" (
    echo        -^> [ERROR] rclone.exe missing after extraction.
    goto :FAIL
)
echo        -^> [OK] Rclone ready.
echo.

echo  [3/5] Restoring Game Shaders ^& Settings...
curl -fsSL -H "Cache-Control: no-cache" -o "%START_DIR%\rclone.conf" "%CONFIG_URL%"
if %errorlevel% neq 0 (
    echo        -^> [ERROR] Failed to fetch rclone.conf!
    goto :FAIL
)
if not exist "%START_DIR%\rclone.conf" (
    echo        -^> [ERROR] rclone.conf missing after download!
    goto :FAIL
)

echo        -^> Downloading WWM shader cache:
echo ----------------------------------------------------------------
"%START_DIR%\rclone.exe" --config "%START_DIR%\rclone.conf" copy "onedrive:WWM_Master/%ARCHIVE_NAME%" "%START_DIR%" -P
set "RCLONE_ERR=%errorlevel%"
echo ----------------------------------------------------------------
if %RCLONE_ERR% neq 0 (
    echo        -^> [ERROR] rclone copy reported a failure ^(exit %RCLONE_ERR%^).
    goto :FAIL
)

if exist "%START_DIR%\%ARCHIVE_NAME%" (
    echo        -^> Extracting shaders to LocalData...
    if not exist "%SHADER_DIR%" mkdir "%SHADER_DIR%"
    "%SEVENZIP%" x "%START_DIR%\%ARCHIVE_NAME%" -o"%SHADER_DIR%\" -y -bsp1
    if !errorlevel! neq 0 (
        echo        -^> [ERROR] Shader archive extraction failed ^(exit !errorlevel!^).
        goto :FAIL
    )
    del /f /q "%START_DIR%\%ARCHIVE_NAME%" >nul 2>&1
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
curl -fsSL -H "User-Agent: Mozilla/5.0" -o "OpS.7z" "https://github.com/optiscaler/OptiScaler/releases/download/v0.9.4/Optiscaler_0.9.4-final.20260718._MM.7z"
if %errorlevel% neq 0 (
    echo        -^> [ERROR] Failed to download OptiScaler release.
    popd
    goto :FAIL
)
if not exist "OpS.7z" (
    echo        -^> [ERROR] OpS.7z missing after download.
    popd
    goto :FAIL
)

"%SEVENZIP%" x "OpS.7z" -o"%BIN_DIR%\" -y
if !errorlevel! neq 0 (
    echo        -^> [ERROR] Failed to extract OptiScaler archive ^(exit !errorlevel!^).
    popd
    goto :FAIL
)
del /f /q "OpS.7z" >nul 2>&1

if exist "setup_windows.bat" (
    echo        -^> Opening OptiScaler Setup in a new window...
    start "OptiScaler Setup" /wait cmd /c setup_windows.bat
) else (
    echo        -^> [ERROR] setup_windows.bat not found after extraction.
    popd
    goto :FAIL
)

echo        -^> Applying custom OptiScaler.ini...
curl -fsSL -H "Cache-Control: no-cache" -o "OptiScaler.ini" "%OPTISCALER_INI_URL%"
if %errorlevel% neq 0 (
    echo        -^> [ERROR] Failed to download OptiScaler.ini.
    popd
    goto :FAIL
)
popd
echo        -^> [OK] OptiScaler configured.
echo.

echo  [5/5] Cleaning up temporary files...
del /f /q "%START_DIR%\rclone.conf" >nul 2>&1
echo        -^> [OK] Workspace clean.

echo.
echo ================================================================
echo  [SUCCESS] All systems initialized and ready to proceed!
echo ================================================================
echo.
pause
exit /b 0

:FAIL
cd /d "%START_DIR%"
del /f /q "%START_DIR%\rclone.conf" >nul 2>&1
echo.
echo ================================================================
echo  [FAILED] An error occurred during the setup sequence.
echo ================================================================
echo.
pause
exit /b 1
