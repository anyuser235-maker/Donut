@echo off
title WWM Fast Restore
set "GAME_DIR=D:\SteamLibrary\steamapps\common\Where Winds Meet\LocalData"

:: 1. Download Rclone if missing
if not exist "rclone.exe" (
    echo Downloading Rclone...
    curl -s -L -o rclone.zip "https://downloads.rclone.org/rclone-current-windows-amd64.zip"
    tar -xf rclone.zip --strip-components=1 */rclone.exe
    del rclone.zip
)

:: 2. Pull encrypted config from GitHub
echo Fetching config...
curl -s -L -o rclone.conf "https://raw.githubusercontent.com/anyuser235-maker/Donut/refs/heads/main/cookie/rotten.txt"

:: 3. Download master archive from OneDrive
echo.
echo Please enter your Rclone config password:
rclone.exe --config rclone.conf copy "onedrive:WWM_Master/WWM_LocalData.zip" . -P

:: 4. Extract directly to game directory
echo.
echo Extracting files to LocalData...
"C:\Program Files\7-Zip\7z.exe" x WWM_LocalData.zip -o"%GAME_DIR%" -y -bsp1

:: 5. Clean up downloaded archive
del WWM_LocalData.zip

echo.
echo ========================================================
echo [SUCCESS] Shaders & Settings restored! Launch via Steam.
echo ========================================================
pause
