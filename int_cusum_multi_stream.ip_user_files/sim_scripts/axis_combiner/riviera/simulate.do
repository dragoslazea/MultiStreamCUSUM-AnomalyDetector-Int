onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+axis_combiner -L xpm -L axis_infrastructure_v1_1_0 -L axis_combiner_v1_1_24 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.axis_combiner xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {axis_combiner.udo}

run -all

endsim

quit -force
