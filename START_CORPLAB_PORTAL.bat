@echo off
title CorpLab Nexus Enterprise Portal
color 0b
echo ======================================================================
echo           CORPLAB NEXUS - 1-CLICK AUTOMATIC PORTAL LAUNCHER
echo ======================================================================
echo.
echo [Step 1/2] Freeing any background port locks (8080, 8085, 8088)...
for %%P in (8080 8085 8086 8088) do (
    for /f "tokens=5" %%a in ('netstat -aon ^| findstr :%%P') do (
        taskkill /F /PID %%a >nul 2>&1
    )
)

echo [Step 2/2] Opening CorpLab Nexus in your web browser...
start "" "%~dp0frontend\login.html"

echo.
echo ======================================================================
echo  [SUCCESS] Portal launched successfully!
echo.
echo  Default Login Credentials:
echo   - Username : admin
echo   - Password : veda  (or Admin@123)
echo.
echo  Or simply click the "Continue with Google" button on the screen!
echo ======================================================================
echo.
pause
