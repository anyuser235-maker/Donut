@echo off
:: ========================================================
:: Cloud VM Performance & Stability Optimization Script
:: ========================================================

echo [1/5] Activating High Performance Power Plan...
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1

echo [2/5] Configuring Fixed 16 GB Pagefile on C:...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$cs = Get-CimInstance Win32_ComputerSystem; if ($cs.AutomaticManagedPagefile) { Set-CimInstance -CimInstance $cs -Property @{AutomaticManagedPagefile = $false} }; $pf = Get-CimInstance Win32_PageFileSetting; if ($pf) { $pf | Set-CimInstance -Property @{InitialSize = 16384; MaximumSize = 16384} } else { New-CimInstance -ClassName Win32_PageFileSetting -Property @{Name = 'C:\pagefile.sys'; InitialSize = 16384; MaximumSize = 16384} }" >nul 2>&1

echo [3/5] Optimizing Memory & Foreground CPU Priority...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v DisablePagingExecutive /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f >nul

echo [4/5] Increasing GPU TDR Timeout Delays (Prevents D3D12 Crashes)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v TdrDelay /t REG_DWORD /d 10 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v TdrDdiDelay /t REG_DWORD /d 10 /f >nul

echo [5/5] Disabling Background GameDVR...
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f >nul

echo.
echo ========================================================
echo  System stabilized and optimizations applied!
echo ========================================================
