`timescale 1ns / 1ps
// Author: Andrzej Wojenski
//
// Module:  fmc_adc_250m_4ch
// Version: 1.0
//
// Description: Complete FMC ADC 250M 4CH data acquisition module
//              -- data transfer lines implementation for ADC chips
//              -- data acquisition with Chipscope blocks
//              Allows:
//              - do simple ADC measurements with Chipscope
//              - data shifting (IDELAY for data lines, controled through PC)
//
//  Note: If using this firmware with Artix7 FPGA check tap resolution (IDELAY lines)
module fmc_adc_250m_4ch(

  input sys_clk,
  input ref_clk, // 200MHz reference clock for IDELAYCTRL
  input rst,
  input trigger,

  input adc0_clk_p,
  input adc0_clk_n,
  input [7:0]adc0_data_in_p,
  input [7:0]adc0_data_in_n,
  output adc0_clk_out,
  output [15:0] adc0_data_out,

  input adc1_clk_p,
  input adc1_clk_n,
  input [7:0]adc1_data_in_p,
  input [7:0]adc1_data_in_n,
  output adc1_clk_out,
  output [15:0] adc1_data_out,

  input adc2_clk_p,
  input adc2_clk_n,
  input [7:0]adc2_data_in_p,
  input [7:0]adc2_data_in_n,
  output adc2_clk_out,
  output [15:0] adc2_data_out,

  input adc3_clk_p,
  input adc3_clk_n,
  input [7:0]adc3_data_in_p,
  input [7:0]adc3_data_in_n,
  output adc3_clk_out,
  output [15:0] adc3_data_out,

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

  output [127:0]data,

  // Chipscope icon inout
  inout [35:0] icon_ctrl0_i,
  inout [35:0] icon_ctrl1_i,
  inout [35:0] icon_ctrl2_i,
  inout [35:0] icon_ctrl3_i
);

parameter FPGA_DEVICE = "VIRTEX6";
parameter FPGA_BOARD = "ML605";
parameter USE_CHIPSCOPE_ICON = 1;
parameter USE_CHIPSCOPE_ILA = 1;

wire adc0_clk;
wire adc1_clk;
wire adc2_clk;
wire adc3_clk;

wire [15:0]adc0_d_ddr;

islaInterface #(
        .IDELAY_SIGNAL_GROUP("adc0_data_delay_group"),
        .IDELAY_LVDS_INV(8'h00),
        .FPGA_DEVICE(FPGA_DEVICE)
        //.IDELAY_LVDS_INV(8'h89)
) islaInterface_adc0_i (

                // ISLA clock input
                .adc0_clk_p(adc0_clk_p),
                .adc0_clk_n(adc0_clk_n),
                // ISLA data input
                .adc0_data_in_p(adc0_data_in_p),
                .adc0_data_in_n(adc0_data_in_n),
                // ISLA clock output (SDR)
                .adc0_clk(adc0_clk),
                // ISLA data output (SDR)
                .adc0_d_ddr(adc0_d_ddr),
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

wire [15:0]adc1_d_ddr;

islaInterface #(
        .IDELAY_SIGNAL_GROUP("adc1_data_delay_group"),
        .IDELAY_LVDS_INV(8'h00),
        .FPGA_DEVICE(FPGA_DEVICE)
        //.IDELAY_LVDS_INV(8'hC7)
) islaInterface_adc1_i (

                // ISLA clock input
                .adc0_clk_p(adc1_clk_p),
                .adc0_clk_n(adc1_clk_n),
                // ISLA data input
                .adc0_data_in_p(adc1_data_in_p),
                .adc0_data_in_n(adc1_data_in_n),
                // ISLA clock output (SDR)
                .adc0_clk(adc1_clk),
                // ISLA data output (SDR)
                .adc0_d_ddr(adc1_d_ddr),
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

wire [15:0]adc2_d_ddr;

islaInterface #(
        .IDELAY_SIGNAL_GROUP("adc2_data_delay_group"),
        .IDELAY_LVDS_INV(8'h00),
        .FPGA_DEVICE(FPGA_DEVICE)
        //.IDELAY_LVDS_INV(8'hE3)
) islaInterface_adc2_i (

                // ISLA clock input
                .adc0_clk_p(adc2_clk_p),
                .adc0_clk_n(adc2_clk_n),
                // ISLA data input
                .adc0_data_in_p(adc2_data_in_p),
                .adc0_data_in_n(adc2_data_in_n),
                // ISLA clock output (SDR)
                .adc0_clk(adc2_clk),
                // ISLA data output (SDR)
                .adc0_d_ddr(adc2_d_ddr),
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

wire [15:0]adc3_d_ddr;

generate
  if (FPGA_BOARD == "ML605" || FPGA_BOARD == "AFC") begin //KC705 does not support channel 3, only ML605

    islaInterface #(
            .IDELAY_SIGNAL_GROUP("adc3_data_delay_group"),
            .IDELAY_LVDS_INV(8'h00),
            .FPGA_DEVICE(FPGA_DEVICE)
            //.IDELAY_LVDS_INV(8'hE3)
    ) islaInterface_adc3_i (

                    // ISLA clock input
                    .adc0_clk_p(adc3_clk_p),
                    .adc0_clk_n(adc3_clk_n),
                    // ISLA data input
                    .adc0_data_in_p(adc3_data_in_p),
                    .adc0_data_in_n(adc3_data_in_n),
                    // ISLA clock output (SDR)
                    .adc0_clk(adc3_clk),
                    // ISLA data output (SDR)
                    .adc0_d_ddr(adc3_d_ddr),
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
  end
endgenerate

// ===============================================
//               Samples acquisition
// ===============================================

wire [31:0]adc0_d_sys;
wire [31:0]adc1_d_sys;
wire [31:0]adc2_d_sys;
wire [31:0]adc3_d_sys;

reg [15:0]adc0_reg = 0;
reg [15:0]adc1_reg = 0;
reg [15:0]adc2_reg = 0;
reg [15:0]adc3_reg = 0;
reg [127:0]adc_data = 0;

//assign adc0_del[15:0] = adc0_d_ddr[15:0]; // temporary

always@(posedge adc0_clk)
        adc0_reg[15:0] <= adc0_d_ddr[15:0];
        //adc0_reg[15:0] <= adc0_del[15:0];

always@(posedge adc1_clk)
        adc1_reg[15:0] <= adc1_d_ddr[15:0];

always@(posedge adc2_clk)
        adc2_reg[15:0] <= adc2_d_ddr[15:0];

generate
  if (FPGA_BOARD == "ML605" || FPGA_BOARD == "AFC") begin  //KC705 does not support channel 3, only ML605 and AFC
    always@(posedge adc3_clk)
          adc3_reg[15:0] <= adc3_d_ddr[15:0];
  end
endgenerate

// Output assignments
assign adc0_clk_out = adc0_clk;
assign adc0_data_out = adc0_reg;

assign adc1_clk_out = adc1_clk;
assign adc1_data_out = adc1_reg;

assign adc2_clk_out = adc2_clk;
assign adc2_data_out = adc2_reg;

assign adc3_clk_out = adc3_clk;
assign adc3_data_out = adc3_reg;

// clock sync 1:2 1 block ram 36k per adc
/*
adc_isla_fifo adc0_fifo_i (
  .rst(rst), // input rst
  .wr_clk(adc0_clk), // input wr_clk
  .rd_clk(sys_clk), // input rd_clk
  .din(adc0_reg), // input [15 : 0] din
  .wr_en(1'b1), // input wr_en
  .rd_en(1'b1), // input rd_en
  .dout(adc0_d_sys), // output [31 : 0] dout
  .full(), // output full
  .empty(), // output empty
  .almost_empty(), // output almost_empty
  .valid(), // output valid
  .prog_empty() // output prog_empty
);

adc_isla_fifo adc1_fifo_i (
  .rst(rst), // input rst
  .wr_clk(adc1_clk), // input wr_clk
  .rd_clk(sys_clk), // input rd_clk
  .din(adc1_reg), // input [15 : 0] din
  .wr_en(1'b1), // input wr_en
  .rd_en(1'b1), // input rd_en
  .dout(adc1_d_sys), // output [31 : 0] dout
  .full(), // output full
  .empty(), // output empty
  .almost_empty(), // output almost_empty
  .valid(), // output valid
  .prog_empty() // output prog_empty
);

adc_isla_fifo adc2_fifo_i (
  .rst(rst), // input rst
  .wr_clk(adc2_clk), // input wr_clk
  .rd_clk(sys_clk), // input rd_clk
  .din(adc2_reg), // input [15 : 0] din
  .wr_en(1'b1), // input wr_en
  .rd_en(1'b1), // input rd_en
  .dout(adc2_d_sys), // output [31 : 0] dout
  .full(), // output full
  .empty(), // output empty
  .almost_empty(), // output almost_empty
  .valid(), // output valid
  .prog_empty() // output prog_empty
);

wire [127:0]fifo_data;

// ddr3 fifo // about 8 block ram - 1x16k, 7x32k
ddr3_fifo ddr3_fifo_i (
  .clk(sys_clk), // input clk
  .rst(rst), // input rst
  // need to add adc3 data!!!
  //.din({32'b00, adc2_d_sys, adc1_d_sys, adc0_d_sys}), // input [127 : 0] din
  .din({adc2_d_sys, adc2_d_sys, adc1_d_sys, adc0_d_sys}), // input [127 : 0] din
  .wr_en(1'b1), // input wr_en
  .rd_en(1'b1), // input rd_en
  .dout(fifo_data), // output [127 : 0] dout
  .full(), // output full
  .empty() // output empty
);

// all:
// 11x 32k / 445 blocks
// 1x 16k / 890 blocks
always@(posedge sys_clk or posedge rst)
begin
        if (rst == 1'b1)
                adc_data <= 0;
        else
                adc_data <= fifo_data;
end

assign data = adc_data;
*/
// ===============================================
//                   Chipscope
// ===============================================

wire [35:0]ctrl0;
wire [35:0]ctrl1;
wire [35:0]ctrl2;
wire [35:0]ctrl3;

wire [15:0]trig0;
wire [15:0]trig1;
wire [15:0]trig2;
wire [15:0]trig3;

assign trig0[15:0] = adc0_reg[15:0];
assign trig1[15:0] = adc1_reg[15:0];
assign trig2[15:0] = adc2_reg[15:0];
assign trig3[15:0] = adc3_reg[15:0];

generate
  if (USE_CHIPSCOPE_ILA) begin
    if (USE_CHIPSCOPE_ICON) begin
      chipscope_icon icon_i (
          .CONTROL0(ctrl0), // INOUT BUS [35:0]
          .CONTROL1(ctrl1), // INOUT BUS [35:0]
          .CONTROL2(ctrl2), // INOUT BUS [35:0]
          .CONTROL3(ctrl3) // INOUT BUS [35:0]
      );
    end else begin
      assign ctrl0 = icon_ctrl0_i;
      assign ctrl1 = icon_ctrl1_i;
      assign ctrl2 = icon_ctrl2_i;
      assign ctrl3 = icon_ctrl3_i;
    end;

    chipscope_ila_w16_trigger adc0_ila (
        .CONTROL(ctrl0), // INOUT BUS [35:0]
        .CLK(adc0_clk), // IN
          //.CLK(ref_clk), // IN
        .TRIG0(trig0) // IN BUS [15:0]
    );

    chipscope_ila_w16_trigger adc1_ila (
        .CONTROL(ctrl1), // INOUT BUS [35:0]
        .CLK(adc1_clk), // IN
         //.CLK(ref_clk), // IN
        .TRIG0(trig1) // IN BUS [15:0]
    );

    chipscope_ila_w16_trigger adc2_ila (
        .CONTROL(ctrl2), // INOUT BUS [35:0]
        .CLK(adc2_clk), // IN
         //.CLK(ref_clk), // IN
        .TRIG0(trig2) // IN BUS [15:0]
    );

    if (FPGA_BOARD == "ML605" || FPGA_BOARD == "AFC") begin  //KC705 does not support channel 3, only ML605
      chipscope_ila_w16_trigger adc3_ila (
          .CONTROL(ctrl3), // INOUT BUS [35:0]
          .CLK(adc3_clk), // IN
          .TRIG0(trig3) // IN BUS [15:0]
      );
    end;
  end;
endgenerate

endmodule
