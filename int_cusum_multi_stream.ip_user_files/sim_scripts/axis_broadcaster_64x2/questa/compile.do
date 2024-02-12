vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/axis_infrastructure_v1_1_0
vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/axis_broadcaster_v1_1_25

vmap xpm questa_lib/msim/xpm
vmap axis_infrastructure_v1_1_0 questa_lib/msim/axis_infrastructure_v1_1_0
vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap axis_broadcaster_v1_1_25 questa_lib/msim/axis_broadcaster_v1_1_25

vlog -work xpm  -incr -mfcu -sv "+incdir+../../../ipstatic/hdl" \
"C:/Xilinx2022/Vivado/2022.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx2022/Vivado/2022.1/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"C:/Xilinx2022/Vivado/2022.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93 \
"C:/Xilinx2022/Vivado/2022.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work axis_infrastructure_v1_1_0  -incr -mfcu "+incdir+../../../ipstatic/hdl" \
"../../../ipstatic/hdl/axis_infrastructure_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -incr -mfcu "+incdir+../../../ipstatic/hdl" \
"../../../../int_cusum_multi_stream.gen/sources_1/ip/axis_broadcaster_64x2/hdl/tdata_axis_broadcaster_64x2.v" \
"../../../../int_cusum_multi_stream.gen/sources_1/ip/axis_broadcaster_64x2/hdl/tuser_axis_broadcaster_64x2.v" \

vlog -work axis_broadcaster_v1_1_25  -incr -mfcu "+incdir+../../../ipstatic/hdl" \
"../../../ipstatic/hdl/axis_broadcaster_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -incr -mfcu "+incdir+../../../ipstatic/hdl" \
"../../../../int_cusum_multi_stream.gen/sources_1/ip/axis_broadcaster_64x2/hdl/top_axis_broadcaster_64x2.v" \
"../../../../int_cusum_multi_stream.gen/sources_1/ip/axis_broadcaster_64x2/sim/axis_broadcaster_64x2.v" \

vlog -work xil_defaultlib \
"glbl.v"

