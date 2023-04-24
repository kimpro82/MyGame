@echo off

:: "almost" written by ChatGPT

:: Setting
setlocal
set program=TestExecutionFile.bat
set log_file=Playtime.ini

:: Run the program and measure its start and end time
set start_time=%time%
call %program%
set end_time=%time%

:: Calculate elapsed time.
:: set /a elapsed_time=(1%end_time:~0,2%-100)*3600 + (1%end_time:~3,2%-100)*60 + (1%end_time:~6,2%-100) - ((1%start_time:~0,2%-100)*3600 + (1%start_time:~3,2%-100)*60 + (1%start_time:~6,2%-100))
:: 균형이 맞지 않는 괄호

:: Save execution date and time to log file.
echo [%program%] >> %log_file%
echo date=%date% >> %log_file%
echo start_time=%start_time% >> %log_file%
echo end_time=%end_time% >> %log_file%
echo elapsed_time=%elapsed_time% >> %log_file%
echo.>> %log_file%

echo The recent playtime has been saved into "%log_file%".