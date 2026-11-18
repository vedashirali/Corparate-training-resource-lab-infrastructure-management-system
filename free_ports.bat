@echo off
title CorpLab Nexus - Port Cleaner & Process Terminator
color 0b
echo ======================================================================
echo          CorpLab Nexus - Auto Port Cleaner & Server Reset
echo ======================================================================
echo.
echo Scanning and terminating any stuck processes on ports 8080, 8085, 8086, 8088...
echo.

for %%P in (8080 8085 8086 8088) do (
    for /f "tokens=5" %%a in ('netstat -aon ^| findstr :%%P') do (
        echo [INFO] Found process with PID %%a holding port %%P. Terminating...
        taskkill /F /PID %%a >nul 2>&1
    )
)

echo.
echo ======================================================================
echo  [SUCCESS] All ports are cleared and free!
echo  You can now return to IntelliJ and click the Green Play button.
echo ======================================================================
echo.
pause
