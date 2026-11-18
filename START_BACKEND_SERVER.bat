@echo off
title CorpLab Nexus - Spring Boot Server
color 0a
echo ======================================================================
echo           CORPLAB NEXUS - SPRING BOOT SERVER LAUNCHER
echo ======================================================================
echo.
echo [Step 1/2] Terminating any stale processes on ports 8080, 8085, 8088...
for %%P in (8080 8085 8086 8088) do (
    for /f "tokens=5" %%a in ('netstat -aon ^| findstr :%%P') do (
        echo Freeing port %%P...
        taskkill /F /PID %%a >nul 2>&1
    )
)

echo [Step 2/2] Launching Spring Boot Backend...
cd /d "%~dp0backend"
mvn spring-boot:run
if %errorlevel% neq 0 (
    echo.
    echo If 'mvn' is not installed in Windows PATH, please run PlatformApplication inside IntelliJ!
)
pause
