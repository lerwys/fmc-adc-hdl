`timescale 1ns / 1ps
// Author: Andrzej Wojenski
//
// Module:  fmc_adc_130m_4ch
// Version: 1.0
//
// Description: Complete FMC ADC 130M 4CH data acquisition module
//              -- data transfer lines implementation for ADC chips
//              -- data acquisition with Chipscope blocks
//              Allows:
//              - do simple ADC measurements with Chipscope
//              - data shifting (IDELAY for data lines, controled through PC)
//
//  Note: If using this firmware with Artix7 FPGA check tap resolution (IDELAY lines)
module fmc_adc_130m_4ch(

    input sys_clk,
    input ref_clk, // 200MHz reference clock for IDELAYCTRL
    input rst,
    input trigger,

    input fmc_fpga_clk_p,
    input fmc_fpga_clk_n,

    input adc0_clk,
    input [15:0]adc0_data_in,
    input adc0_ov,

    input adc1_clk,
    input [15:0]adc1_data_in,
    input adc1_ov,

    input adc2_clk,
    input [15:0]adc2_data_in,
    input adc2_ov,

    input adc3_clk,
    input [15:0]adc3_data_in,
    input adc3_ov,

    input [4:0]adc0_delay_reg,
    output [4:0]adc0_delay_reg_read,
    input adc0_delay_load,
    input [16:0]adc0_delay_select,
    output adc0_delay_rdy,

    input [4:0]adc1_delay_reg,
    output [4:0]adc1_delay_reg_read,
    input adc1_delay_load,
    input [16:0]adc1_delay_select,
    output adc1_delay_rdy,

    input [4:0]adc2_delay_reg,
    output [4:0]adc2_delay_reg_read,
    input adc2_delay_load,
    input [16:0]adc2_delay_select,
    output adc2_delay_rdy,

    input [4:0]adc3_delay_reg,
    output [4:0]adc3_delay_reg_read,
    input adc3_delay_load,
    input [16:0]adc3_delay_select,
    output adc3_delay_rdy,

    output [127:0]data  // change this!!!

    );

parameter FPGA_DEVICE = "VIRTEX6";

// REBUILD ALL CORES UNDER XILINX ISE 14.4

wire [16:0]adc0_data_out;
wire [16:0]adc1_data_out;
wire [16:0]adc2_data_out;
wire [16:0]adc3_data_out;

// On ML605 kit, all clock pins are assigned to MRCC pins. However, two of them
// (fmc_adc1_clk and fmc_adc3_clk) are located in the outer left/right column
// I/Os. These locations cannot connect to BUFG primitives, only inner (center)
// left/right column I/Os on the same half top/bottom can!
//
// For 7-series FPGAs there is no such impediment, apparently.

ltcInterface #(
  .IDELAY_SIGNAL_GROUP("adc0_data_delay_group"),
  .FPGA_DEVICE(FPGA_DEVICE)
) ltcInterface_adc0_i (

    // LTC clock input
    //.adc0_clk_in(adc0_clk),
    .adc0_clk_in(adc0_clk),
    // LTC data input
    .adc0_data_in(adc0_data_in),
    .adc0_ov_in(adc0_ov),
    // LTC clock output (SDR)
    .adc0_clk_out(adc0_clk_out),
    // LTC data output (SDR)
    .adc0_data_out(adc0_data_out),
    // Control signals for IDELAY
    .sys_clk(sys_clk),
    .ref_clk(ref_clk), // 200MHz
    .rst(rst),

    .adc0_delay_reg(adc0_delay_reg),
    .adc0_delay_select(adc0_delay_select),
    .adc0_delay_load(adc0_delay_load),
    .adc0_delay_reg_read(adc0_delay_reg_read),
    .adc0_delay_rdy(adc0_delay_rdy)

);

ltcInterface #(
  .IDELAY_SIGNAL_GROUP("adc1_data_delay_group"),
  .FPGA_DEVICE(FPGA_DEVICE)
) ltcInterface_adc1_i (

    // LTC clock input
    //.adc0_clk_in(adc1_clk),
    .adc0_clk_in(adc1_clk),
    // LTC data input
    .adc0_data_in(adc1_data_in),
    .adc0_ov_in(adc1_ov),
    // LTC clock output (SDR)
    .adc0_clk_out(adc1_clk_out),
    // LTC data output (SDR)
    .adc0_data_out(adc1_data_out),
    // Control signals for IDELAY
    .sys_clk(sys_clk),
    .ref_clk(ref_clk), // 200MHz
    .rst(rst),

    .adc0_delay_reg(adc1_delay_reg),
    .adc0_delay_select(adc1_delay_select),
    .adc0_delay_load(adc1_delay_load),
    .adc0_delay_reg_read(adc1_delay_reg_read),
    .adc0_delay_rdy(adc1_delay_rdy)

);

ltcInterface #(
  .IDELAY_SIGNAL_GROUP("adc2_data_delay_group"),
  .FPGA_DEVICE(FPGA_DEVICE)
) ltcInterface_adc2_i (

    // LTC clock input
    //.adc0_clk_in(adc2_clk),
    .adc0_clk_in(adc2_clk),
    // LTC data input
    .adc0_data_in(adc2_data_in),
    .adc0_ov_in(adc2_ov),
    // LTC clock output (SDR)
    .adc0_clk_out(adc2_clk_out),
    // LTC data output (SDR)
    .adc0_data_out(adc2_data_out),
    // Control signals for IDELAY
    .sys_clk(sys_clk),
    .ref_clk(ref_clk), // 200MHz
    .rst(rst),

    .adc0_delay_reg(adc2_delay_reg),
    .adc0_delay_select(adc2_delay_select),
    .adc0_delay_load(adc2_delay_load),
    .adc0_delay_reg_read(adc2_delay_reg_read),
    .adc0_delay_rdy(adc2_delay_rdy)

);

ltcInterface #(
  .IDELAY_SIGNAL_GROUP("adc1_data_delay_group"), // uses the same idelayctrl (and same bank) as ADC1
  .FPGA_DEVICE(FPGA_DEVICE)
) ltcInterface_adc3_i (

    // LTC clock input
    //.adc0_clk_in(adc3_clk),
    .adc0_clk_in(adc3_clk),
    // LTC data input
    .adc0_data_in(adc3_data_in),
    .adc0_ov_in(adc3_ov),
    // LTC clock output (SDR)
    .adc0_clk_out(adc3_clk_out),
    // LTC data output (SDR)
    .adc0_data_out(adc3_data_out),
    // Control signals for IDELAY
    .sys_clk(sys_clk),
    .ref_clk(ref_clk), // 200MHz
    .rst(rst),

    .adc0_delay_reg(adc3_delay_reg),
    .adc0_delay_select(adc3_delay_select),
    .adc0_delay_load(adc3_delay_load),
    .adc0_delay_reg_read(adc3_delay_reg_read),
    .adc0_delay_rdy(adc3_delay_rdy)

);

// ===============================================
//               Samples acquisition
// ===============================================

reg [16:0]adc0_reg = 0;
reg [16:0]adc1_reg = 0;
reg [16:0]adc2_reg = 0;
reg [16:0]adc3_reg = 0;

// now only for chipscope
always@(posedge adc0_clk_out)
  adc0_reg[15:0] <= adc0_data_out[15:0];

always@(posedge adc1_clk_out)
  adc1_reg[15:0] <= adc1_data_out[15:0];

always@(posedge adc2_clk_out)
  adc2_reg[15:0] <= adc2_data_out[15:0];

always@(posedge adc3_clk_out)
  adc3_reg[15:0] <= adc3_data_out[15:0];

// ===============================================
//                   Chipscope
// ===============================================

wire [35:0]ctrl0;
wire [35:0]ctrl1;
wire [35:0]ctrl2;
wire [35:0]ctrl3;

wire [16:0]trig0;
wire [16:0]trig1;
wire [16:0]trig2;
wire [16:0]trig3;

assign trig0[16:0] = adc0_reg[16:0];
assign trig1[16:0] = adc1_reg[16:0];
assign trig2[16:0] = adc2_reg[16:0];
assign trig3[16:0] = adc3_reg[16:0];

chipscope_icon icon_i (
   .CONTROL0(ctrl0), // INOUT BUS [35:0]
   .CONTROL1(ctrl1), // INOUT BUS [35:0]
   .CONTROL2(ctrl2), // INOUT BUS [35:0]
   .CONTROL3(ctrl3) // INOUT BUS [35:0]
);

chipscope_ila_w17_trigger adc0_ila (
    .CONTROL(ctrl0), // INOUT BUS [35:0]
    .CLK(adc0_clk_out), // IN
    .TRIG0(trig0) // IN BUS [16:0]
);

chipscope_ila_w17_trigger adc1_ila (
    .CONTROL(ctrl1), // INOUT BUS [35:0]
    .CLK(adc1_clk_out), // IN
    .TRIG0(trig1) // IN BUS [16:0]
);

chipscope_ila_w17_trigger adc2_ila (
    .CONTROL(ctrl2), // INOUT BUS [35:0]
    .CLK(adc2_clk_out), // IN
    .TRIG0(trig2) // IN BUS [16:0]
);

chipscope_ila_w17_trigger adc3_ila (
    .CONTROL(ctrl3), // INOUT BUS [35:0]
    .CLK(adc3_clk_out), // IN
    .TRIG0(trig3) // IN BUS [16:0]
);

endmodule
