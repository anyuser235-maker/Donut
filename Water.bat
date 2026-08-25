@echo off
setlocal EnableDelayedExpansion

:: 1. Your Base64-encoded user.bin auth payload
set "AUTH_DATA=AQAAANCMnd8BFdERjHoAwE/Cl+sBAAAASzvu060eG0e29SFxSAEU4AQAAAACAAAAAAAQZgAAAAEAACAAAABofTM+1ImewOpQDkDWu5j8AFkwvhKvrnfEqsBx4W1LngAAAAAOgAAAAAIAACAAAAC5g9Z+C7CmnztrQE7wEsuseE+d3NQ28ekTPtDo090pOGAAAAC2Sxt9JMTZfFL3FyyfbBP0LFuoFuOOWRej8+npXZgTEChlV9xEIqwPgxNCxniLiJhHW6k8LRBliQ63iT9fpr05hMVWx2degILhEx/3Lrlg0C+3+XfiiCj/sNQF/v1kdV5AAAAAbxQoeqFM3LL5XgEefwR/eKlvm5Rb2uEKaGWBrsYA3YElokPoLq0XyGNREDQl9qgI/RMmEAc5koCK7QAEd6QaXA=="

echo [*] Downloading Parsec installer to current directory...
curl -L -o "parsec-setup.exe" "https://builds.parsec.app/package/parsec-windows.exe"
if %errorlevel% neq 0 (
    echo [-] Failed to download installer.
    exit /b %errorlevel%
)

echo [*] Installing Parsec silently (waiting for completion)...
start /wait "" "parsec-setup.exe" /silent /percomputer /shared

echo [*] Creating ProgramData directory...
if not exist "C:\ProgramData\Parsec" mkdir "C:\ProgramData\Parsec"

echo [*] Writing configuration settings...
(
    echo app_host=1
    echo host_virtual_monitors=1
    echo host_privacy_mode=0
    echo encoder_bitrate=30
) > "C:\ProgramData\Parsec\config.txt"

echo [*] Writing user.bin authentication token...
powershell -NoProfile -Command "[IO.File]::WriteAllBytes('C:\ProgramData\Parsec\user.bin', [Convert]::FromBase64String('%AUTH_DATA%'))"

echo [*] Starting Parsec service...
net stop Parsec >nul 2>&1
timeout /t 2 /nobreak >nul
net start Parsec

echo [*] Launching Parsec daemon...
start "" "C:\Program Files\Parsec\parsecd.exe"

echo [+] Done! Check your local Parsec application to connect.
endlocal
