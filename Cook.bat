@echo off
title WWM Cloud Sync :: Test Backup (Engine Folder)
setlocal enabledelayedexpansion

set "TARGET_DIR=D:\wwm\wwm_lite\Engine"
set "ARCHIVE_NAME=D:\Engine_test.zip"
set "CONFIG_URL=https://raw.githubusercontent.com/anyuser235-maker/Donut/refs/heads/main/cookie/spoilt.txt"
set "REMOTE_DEST=GDrive:GameCloudBackup"

cls
echo ================================================================
echo                WWM TEST BACKUP - ENGINE FOLDER (2.01 GB)
echo ================================================================
echo.

:: Prompt for password safely at runtime
set /p "RCLONE_CONFIG_PASS=Enter Rclone Config Password: "
if "%RCLONE_CONFIG_PASS%"=="" (
    echo.
    echo  [ERROR] Password cannot be empty.
    goto :FAIL
)
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

echo  [3/4] Packaging Engine directory (Store Mode - Ultra Fast)...
if not exist "%TARGET_DIR%" (
    echo        -^> [ERROR] Target directory not found:
    echo            %TARGET_DIR%
    goto :FAIL
)

if exist "%ARCHIVE_NAME%" del /f /q "%ARCHIVE_NAME%" >nul 2>&1

:: Disable delayed expansion for 7-Zip call
setlocal DisableDelayedExpansion
"C:\Program Files\7-Zip\7z.exe" a -tzip -mx0 -bsp1 "%ARCHIVE_NAME%" "%TARGET_DIR%"
set "ZIP_STATUS=%errorlevel%"
endlocal & set "ZIP_STATUS=%ZIP_STATUS%"

if %ZIP_STATUS% neq 0 (
    echo        -^> [ERROR] 7-Zip packaging failed.
    goto :FAIL
)
echo        -^> [OK] Archive created successfully at %ARCHIVE_NAME%.
echo.

echo  [4/4] Uploading test archive to Google Drive (%REMOTE_DEST%)...
echo ----------------------------------------------------------------
rclone.exe --config rclone.conf copy "%ARCHIVE_NAME%" "%REMOTE_DEST%" ^
  -P ^
  --stats 5s ^
  --drive-chunk-size 128M ^
  --retries 5 ^
  --low-level-retries 10 ^
  --timeout 10m

if %errorlevel% neq 0 (
    echo ----------------------------------------------------------------
    echo        -^> [ERROR] Google Drive upload failed.
    goto :FAIL
)
echo ----------------------------------------------------------------
echo.

echo  [*] Cleaning up temporary test archive and config...
del /f /q "%ARCHIVE_NAME%" >nul 2>&1
del /f /q rclone.conf >nul 2>&1
set "RCLONE_CONFIG_PASS="

echo.
echo ================================================================
echo  [SUCCESS] Test complete! Saved to %REMOTE_DEST%/Engine_test.zip
echo ================================================================
echo.
pause
exit /b 0

:FAIL
del /f /q "%ARCHIVE_NAME%" >nul 2>&1
del /f /q rclone.conf >nul 2>&1
set "RCLONE_CONFIG_PASS="
echo.
echo ================================================================
echo  [FAILED] Test run encountered an error.
echo ================================================================
echo.
pause
exit /b 1
