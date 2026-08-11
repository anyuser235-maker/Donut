@echo off
setlocal

:: 1. Download 7-Zip installer
curl -L -o "7zi.exe" "https://github.com/ip7z/7zip/releases/download/26.02/7z2602-x64.exe"

:: 2. Install 7-Zip silently
7zi.exe /S

:: 3. Delete 7-Zip installer
del /f /q "7zi.exe"

:: 4. Download OptiScaler archive
curl -L -H "User-Agent: Mozilla/5.0" -o "OpS.7z" "https://github.com/optiscaler/OptiScaler/releases/download/v0.9.4/Optiscaler_0.9.4-final.20260718._MM.7z"

:: 5. Extract OpS.7z into current directory
"C:\Program Files\7-Zip\7z.exe" x "OpS.7z" -o"%CD%" -y

:: 6. Remove OpS.7z
del /f /q "OpS.7z"

:: 7. Run setup_windows.bat with inputs: 1 (dxgi.dll), 2 (Nvidia), and Enter (to pass pause)[cite: 1]
(echo 1 & echo 2 & echo.) | cmd /c setup_windows.bat

echo Process finished!
