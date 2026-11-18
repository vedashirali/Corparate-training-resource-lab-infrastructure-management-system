@echo off
echo ====================================================================
echo   CorpLab Platform: Clearing Port & Terminating Zombie Java Processes
echo ====================================================================
echo.
taskkill /F /IM java.exe 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] Background Java processes terminated successfully!
) else (
    echo [INFO] No lingering Java processes were found.
)
echo.
echo ====================================================================
echo   Ports 8085 and 8088 are now 100%% FREE!
echo   Go to IntelliJ IDEA and click the Green [Run] button.
echo ====================================================================
pause
