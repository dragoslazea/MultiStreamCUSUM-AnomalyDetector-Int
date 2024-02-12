// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
// Date        : Tue Dec 12 09:54:39 2023
// Host        : LAPTOP-S8S4C16E running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/IVA/Research/int_cusum_multi_stream/int_cusum_multi_stream.gen/sources_1/ip/axis_broadcaster_64x2/axis_broadcaster_64x2_stub.v
// Design      : axis_broadcaster_64x2
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "top_axis_broadcaster_64x2,Vivado 2022.1" *)
module axis_broadcaster_64x2(aclk, aresetn, s_axis_tvalid, s_axis_tready, 
  s_axis_tdata, m_axis_tvalid, m_axis_tready, m_axis_tdata)
/* synthesis syn_black_box black_box_pad_pin="aclk,aresetn,s_axis_tvalid,s_axis_tready,s_axis_tdata[63:0],m_axis_tvalid[1:0],m_axis_tready[1:0],m_axis_tdata[127:0]" */;
  input aclk;
  input aresetn;
  input s_axis_tvalid;
  output s_axis_tready;
  input [63:0]s_axis_tdata;
  output [1:0]m_axis_tvalid;
  input [1:0]m_axis_tready;
  output [127:0]m_axis_tdata;
endmodule
