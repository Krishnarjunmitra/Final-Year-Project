onbreak {quit -f}
onerror {quit -f}

vsim  -lib xil_defaultlib tb_fp_mul_pipelined_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {tb_fp_mul_pipelined.udo}

run 1000ns

quit -force
