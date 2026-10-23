@echo off
setlocal

set "ROOT=%~dp0"
set "OUT=%TEMP%\my_minsec_stopwatch_tb.vvp"

where iverilog >nul 2>nul
if errorlevel 1 (
    echo ERROR: Icarus Verilog is not installed or is not in PATH.
    exit /b 1
)

iverilog -g2012 -s main_controller_tb -o "%OUT%" ^
    "%ROOT%my_minsec_stopwatch.srcs\sources_1\imports\sources_1\new\top.v" ^
    "%ROOT%my_minsec_stopwatch.srcs\sources_1\imports\sources_1\new\main_controller.v" ^
    "%ROOT%my_minsec_stopwatch.srcs\sources_1\imports\sources_1\new\tick_generator.v" ^
    "%ROOT%my_minsec_stopwatch.srcs\sources_1\imports\sources_1\new\fnd_controller.v" ^
    "%ROOT%my_minsec_stopwatch.srcs\sources_1\imports\sources_1\imports\new\btn_debounce.v" ^
    "%ROOT%my_minsec_stopwatch.sim\sim_1\new\main_controller_tb.v"
if errorlevel 1 exit /b 1

vvp "%OUT%" +VCD="%TEMP%\stopwatch_timing.vcd"
exit /b %errorlevel%
