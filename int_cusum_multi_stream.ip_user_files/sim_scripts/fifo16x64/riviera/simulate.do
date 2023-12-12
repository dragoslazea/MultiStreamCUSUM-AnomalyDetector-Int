onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+fifo16x64 -L xpm -L axis_infrastructure_v1_1_0 -L axis_data_fifo_v2_0_8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.fifo16x64 xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {fifo16x64.udo}

run -all

endsim

quit -force
