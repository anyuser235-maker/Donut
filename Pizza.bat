@echo off
:: ========================================================
:: Cloud VM RAM & CPU Performance Optimization Script
:: ========================================================

echo [1/5] Unlocking & Activating High Performance Power Plan...
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

echo [2/5] Configuring Fixed 16 GB Pagefile on C:...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-CimInstance -Query 'Select * from Win32_ComputerSystem' -Property @{AutomaticManagedPagefile = $False}; $pf = Get-CimInstance Win32_PageFileSetting -Filter \"Name like 'C:%'\"; if ($pf) { $pf | Set-CimInstance -Property @{InitialSize = 16384; MaximumSize = 16384} } else { New-CimInstance -ClassName Win32_PageFileSetting -Property @{Name = 'C:\pagefile.sys'; InitialSize = 16384; MaximumSize = 16384} }; Get-CimInstance Win32_PageFileSetting -Filter \"Name not like 'C:%'\" | Remove-CimInstance"

echo [3/5] Optimizing RAM Paging & Memory Management...
:: Keep Windows Kernel and core drivers in physical RAM instead of paging to disk
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v DisablePagingExecutive /t REG_DWORD /d 1 /f >nul
:: Prioritize process working set RAM for active games over file system cache
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 0 /f >nul
:: Prevent VM shutdown lag from wiping pagefile
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 0 /f >nul

echo [4/5] Optimizing CPU Priority & Foreground Responsiveness...
:: Optimize thread scheduling and short quanta for foreground gaming processes (0x26 / Dec 38)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f >nul

echo [5/5] Disabling Background DVR & Latency Overhead...
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f >nul

echo.
echo ========================================================
echo  All RAM, Pagefile, and CPU optimizations applied!
echo ========================================================
pause
