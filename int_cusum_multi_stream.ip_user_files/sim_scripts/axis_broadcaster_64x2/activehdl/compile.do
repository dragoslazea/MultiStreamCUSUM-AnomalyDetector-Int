vlib work
vlib activehdl

vlib activehdl/xpm
vlib activehdl/axis_infrastructure_v1_1_0
vlib activehdl/xil_defaultlib
vlib activehdl/axis_broadcaster_v1_1_25

vmap xpm activehdl/xpm
vmap axis_infrastructure_v1_1_0 activehdl/axis_infrastructure_v1_1_0
vmap xil_defaultlib activehdl/xil_defaultlib
vmap axis_broadcaster_v1_1_25 activehdl/axis_broadcaster_v1_1_25

vlog -work xpm  -sv2k12 "+incdir+../../../ipstatic/hdl" \
"C:/Xilinx2022/Vivado/2022.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx2022/Vivado/2022.1/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"C:/Xilinx2022/Vivado/2022.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"C:/Xilinx2022/Vivado/2022.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work axis_infrastructure_v1_1_0  -v2k5 "+incdir+../../../ipstatic/hdl" \
"../../../ipstatic/hdl/axis_infrastructure_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../ipstatic/hdl" \
"../../../../int_cusum_multi_stream.gen/sources_1/ip/axis_broadcaster_64x2/hdl/tdata_axis_broadcaster_64x2.v" \
"../../../../int_cusum_multi_stream.gen/sources_1/ip/axis_broadcaster_64x2/hdl/tuser_axis_broadcaster_64x2.v" \

vlog -work axis_broadcaster_v1_1_25  -v2k5 "+incdir+../../../ipstatic/hdl" \
"../../../ipstatic/hdl/axis_broadcaster_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../ipstatic/hdl" \
"../../../../int_cusum_multi_stream.gen/sources_1/ip/axis_broadcaster_64x2/hdl/top_axis_broadcaster_64x2.v" \
"../../../../int_cusum_multi_stream.gen/sources_1/ip/axis_broadcaster_64x2/sim/axis_broadcaster_64x2.v" \

vlog -work xil_defaultlib \
"glbl.v"

