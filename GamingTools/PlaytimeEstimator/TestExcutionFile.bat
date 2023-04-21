@echo off

@REM "almost" written by ChatGPT

setlocal enableextensions enabledelayedexpansion

set /a "n = %random% %% 3 + 1"
set start_time=!time!
timeout /t %n% > nul
set end_time=!time!

@REM set /a "start_ms=((1!start_time:~0,2!-100)*3600 + (1!start_time:~3,2!-100)*60 + (1!start_time:~6,2!-100))*100 + (1!start_time:~9,2!-100)"
@REM set /a "end_ms=((1!end_time:~0,2!-100)*3600 + (1!end_time:~3,2!-100)*60 + (1!end_time:~6,2!-100))*100 + (1!end_time:~9,2!-100)"
@REM set /a "elapsed_time=(end_ms - start_ms) / 100"
@REM 균형이 맞지 않는 괄호

echo [실행파일 출력 개시]
echo  실행시간 : %start_time% ~ %end_time%
@REM echo  실행시간 : %elapsed_time%초 (%start_time% ~ %end_time% )
echo [실행파일 출력 종료]

endlocal