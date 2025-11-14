transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib activehdl/xil_defaultlib

vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xil_defaultlib  -v2k5 -l xil_defaultlib \
"../../../fp_mul_advanced.srcs/sources_1/new/fp_mul_pipelined.v" \
"../../../fp_mul_advanced.srcs/sources_1/new/vedic12x12.v" \
"../../../fp_mul_advanced.srcs/sources_1/new/vedic24x24.v" \
"../../../fp_mul_advanced.srcs/sources_1/new/vedic3x3.v" \
"../../../fp_mul_advanced.srcs/sources_1/new/vedic6x6.v" \
"../../../fp_mul_advanced.srcs/sim_1/new/tb_fp_mul_pipelined.v" \


vlog -work xil_defaultlib \
"glbl.v"

