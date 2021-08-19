@echo off
echo #########################
echo # Brother's Game System #
echo # Copyright(C) 199X Kim #
echo #########################
:LIST
echo.
echo [LIST]
echo 1. Princess Maker 2
echo 2. Mother Goose
echo 3. Park
set /p x=Enter your choice(1-3) : 
if "%x%"=="1" echo c:\game\pm2\pm2.exe
if "%x%"=="2" echo c:\game\mg\mg.exe
if "%x%"=="3" echo c:\park.exe
goto LIST