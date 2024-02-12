onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib axis_register_slice_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {axis_register_slice.udo}

run -all

quit -force
