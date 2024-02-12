onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+axis_broadcaster_64x2 -L xpm -L axis_infrastructure_v1_1_0 -L xil_defaultlib -L axis_broadcaster_v1_1_25 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.axis_broadcaster_64x2 xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {axis_broadcaster_64x2.udo}

run -all

endsim

quit -force
