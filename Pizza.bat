@echo off
setlocal

echo [*] Downloading Parsec installer to current directory...
curl -L -o "parsec-setup.exe" "https://builds.parsec.app/package/parsec-windows.exe"
if %errorlevel% neq 0 (
    echo [-] Failed to download installer.
    exit /b %errorlevel%
)

echo [*] Installing Parsec silently...
start /wait "" "parsec-setup.exe" /silent /percomputer /shared

echo [*] Enabling hosting in configuration...
if not exist "C:\ProgramData\Parsec" mkdir "C:\ProgramData\Parsec"
(
    echo app_host=1
    echo host_virtual_monitors=1
    echo host_privacy_mode=0
    echo encoder_bitrate=30
) > "C:\ProgramData\Parsec\config.txt"

echo [*] Starting background service...
net stop Parsec >nul 2>&1
timeout /t 1 /nobreak >nul
net start Parsec

echo [*] Launching Parsec GUI for manual login...
start "" "C:\Program Files\Parsec\parsecd.exe"

echo [+] Done! Log into your account on the screen.
endlocal
