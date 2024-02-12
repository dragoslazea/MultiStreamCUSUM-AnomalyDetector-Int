onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -L xpm -L axis_infrastructure_v1_1_0 -L axis_combiner_v1_1_24 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.axis_combiner xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {axis_combiner.udo}

run -all

quit -force
