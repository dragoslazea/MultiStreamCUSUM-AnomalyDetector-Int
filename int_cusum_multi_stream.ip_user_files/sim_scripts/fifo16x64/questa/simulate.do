onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib fifo16x64_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {fifo16x64.udo}

run -all

quit -force
