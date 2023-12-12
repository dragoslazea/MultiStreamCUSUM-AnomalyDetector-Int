@echo off
REM ****************************************************************************
REM Vivado (TM) v2022.1 (64-bit)
REM
REM Filename    : elaborate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for elaborating the compiled design
REM
REM Generated by Vivado on Sun Dec 10 23:34:56 +0200 2023
REM SW Build 3526262 on Mon Apr 18 15:48:16 MDT 2022
REM
REM IP Build 3524634 on Mon Apr 18 20:55:01 MDT 2022
REM
REM usage: elaborate.bat
REM
REM ****************************************************************************
REM elaborate design
echo "xelab --debug typical --relax --mt 2 -L xil_defaultlib -L axis_infrastructure_v1_1_0 -L axis_data_fifo_v2_0_8 -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot testbench_2_sensors_id_from_file_behav xil_defaultlib.testbench_2_sensors_id_from_file xil_defaultlib.glbl -log elaborate.log"
call xelab  --debug typical --relax --mt 2 -L xil_defaultlib -L axis_infrastructure_v1_1_0 -L axis_data_fifo_v2_0_8 -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot testbench_2_sensors_id_from_file_behav xil_defaultlib.testbench_2_sensors_id_from_file xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0