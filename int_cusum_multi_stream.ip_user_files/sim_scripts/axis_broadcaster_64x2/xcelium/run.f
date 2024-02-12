-makelib xcelium_lib/xpm -sv \
  "C:/Xilinx2022/Vivado/2022.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "C:/Xilinx2022/Vivado/2022.1/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
  "C:/Xilinx2022/Vivado/2022.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "C:/Xilinx2022/Vivado/2022.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/axis_infrastructure_v1_1_0 \
  "../../../ipstatic/hdl/axis_infrastructure_v1_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../int_cusum_multi_stream.gen/sources_1/ip/axis_broadcaster_64x2/hdl/tdata_axis_broadcaster_64x2.v" \
  "../../../../int_cusum_multi_stream.gen/sources_1/ip/axis_broadcaster_64x2/hdl/tuser_axis_broadcaster_64x2.v" \
-endlib
-makelib xcelium_lib/axis_broadcaster_v1_1_25 \
  "../../../ipstatic/hdl/axis_broadcaster_v1_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../int_cusum_multi_stream.gen/sources_1/ip/axis_broadcaster_64x2/hdl/top_axis_broadcaster_64x2.v" \
  "../../../../int_cusum_multi_stream.gen/sources_1/ip/axis_broadcaster_64x2/sim/axis_broadcaster_64x2.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

