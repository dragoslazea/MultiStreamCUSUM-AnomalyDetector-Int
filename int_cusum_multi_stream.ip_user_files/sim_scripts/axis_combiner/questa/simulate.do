onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib axis_combiner_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {axis_combiner.udo}

run -all

quit -force
