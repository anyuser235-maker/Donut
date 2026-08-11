@echo off
setlocal

:: 1. Change working directory to game folder
cd /d "D:\SteamLibrary\steamapps\common\Where Winds Meet\Engine\Binaries\Win64r"

:: 2. Download 7-Zip installer
curl -L -o "7zi.exe" "https://github.com/ip7z/7zip/releases/download/26.02/7z2602-x64.exe"

:: 3. Install 7-Zip silently
7zi.exe /S

:: 4. Delete 7-Zip installer
del /f /q "7zi.exe"

:: 5. Download OptiScaler archive
curl -L -H "User-Agent: Mozilla/5.0" -o "OpS.7z" "https://github.com/optiscaler/OptiScaler/releases/download/v0.9.4/Optiscaler_0.9.4-final.20260718._MM.7z"

:: 6. Extract OpS.7z into current directory
"C:\Program Files\7-Zip\7z.exe" x "OpS.7z" -o"%CD%" -y

:: 7. Remove OpS.7z
del /f /q "OpS.7z"

:: 8. Open setup_windows.bat in a new window for manual input and wait for it to complete
start /wait cmd /c setup_windows.bat

echo Process finished!
