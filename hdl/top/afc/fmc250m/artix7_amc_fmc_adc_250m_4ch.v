`timescale 1ns / 1ps
// Author: Andrzej Wojenski
//
// Module:  kintex7_fmc_adc_4ch_250m
// Version: 1.0
//
// Description: Firmware for FMC ADC 250M 4CH (PASSIVE and ACTIVE)
//              Codes for AMC card with Xilinx Artix7 200T -2 1156 FPGA
//              Includes:
//              -- configuration communication interfaces (like I2C)
//              -- data interfaces (like ADC ISLA)
//              -- data acquisition with Chipscope blocks
//              Allows:
//              - configure whole FMC card
//              - do simple ADC measurements with Chipscope
//
//  Note: If using this firmware with Artix7 FPGA check tap resolution (IDELAY lines)
//  Note2: Trigger line in input mode only

module artix7_amc_fmc_adc_250m_4ch(

  // Clock
  input sys_clk_i_p,
  input sys_clk_i_n,

  ////////////////////////////////////////////////////////////////
  ///////////////////////////// FMC1 /////////////////////////////
  ////////////////////////////////////////////////////////////////
  // FMC ISLA ADC data interface
  input fmc1_adc0_clk_p,
  input fmc1_adc0_clk_n,
  input [7:0]fmc1_adc0_data_in_p,
  input [7:0]fmc1_adc0_data_in_n,

  input fmc1_adc1_clk_p,
  input fmc1_adc1_clk_n,
  input [7:0]fmc1_adc1_data_in_p,
  input [7:0]fmc1_adc1_data_in_n,

  input fmc1_adc2_clk_p,
  input fmc1_adc2_clk_n,
  input [7:0]fmc1_adc2_data_in_p,
  input [7:0]fmc1_adc2_data_in_n,

  input fmc1_adc3_clk_p,
  input fmc1_adc3_clk_n,
  input [7:0]fmc1_adc3_data_in_p,
  input [7:0]fmc1_adc3_data_in_n,

  // FMC
  //input fmc1_prsnt_i, // connected to CPU
  //input fmc1_pg_m2c_i, // connected to CPU
  //input fmc1_clk_dir_i, // connected to CPU

  // Trigger
  output fmc1_trig_dir_o,
  output fmc1_trig_term_o,
  input fmc1_trig_val_o_p,
  input fmc1_trig_val_o_n,
  //inout fmc1_trig_val_o_p,
  //inout fmc1_trig_val_o_n,

  // ADC ISLA
  output [3:0]fmc1_spi_adc_cs,
  output fmc1_spi_adc_sclk_o,
  output fmc1_spi_adc_mosi_o,
  input fmc1_spi_adc_miso_i,

  output fmc1_adc_clkdivrst_o_p,
  output fmc1_adc_clkdivrst_o_n,
  output fmc1_adc_resetn_o,
  output fmc1_adc_sleep_o,

  // Si571 clock gen
  inout fmc1_si571_scl_pad,
  inout fmc1_si571_sda_pad,
  output fmc1_si571_oe_o,

  // AD9510 clock distribution PLL
  output fmc1_spi_ad9510_cs,
  output fmc1_spi_ad9510_sclk_o,
  output fmc1_spi_ad9510_mosi_o,
  input fmc1_spi_ad9510_miso_i,

  output fmc1_pll_function_o,
  input fmc1_pll_status_i,

  // Clock reference selection (TS3USB221)
  output fmc1_clk_sel_o,

  // EEPROM - connected to CPU
  //inout eeprom_scl_pad,
  //inout eeprom_sda_pad,

  // AMC7823 FMC monitor
  output fmc1_spi_amc7823_cs,
  output fmc1_spi_amc7823_sclk_o,
  output fmc1_spi_amc7823_mosi_o,
  input fmc1_spi_amc7823_miso_i,

  input fmc1_mon_dev_i,

  // LEDs
  output fmc1_led1_o,
  output fmc1_led2_o,
  output fmc1_led3_o,

  ////////////////////////////////////////////////////////////////
  ///////////////////////////// FMC2 /////////////////////////////
  ////////////////////////////////////////////////////////////////
  // FMC ISLA ADC data interface
  input fmc2_adc0_clk_p,
  input fmc2_adc0_clk_n,
  input [7:0]fmc2_adc0_data_in_p,
  input [7:0]fmc2_adc0_data_in_n,

  input fmc2_adc1_clk_p,
  input fmc2_adc1_clk_n,
  input [7:0]fmc2_adc1_data_in_p,
  input [7:0]fmc2_adc1_data_in_n,

  input fmc2_adc2_clk_p,
  input fmc2_adc2_clk_n,
  input [7:0]fmc2_adc2_data_in_p,
  input [7:0]fmc2_adc2_data_in_n,

  input fmc2_adc3_clk_p,
  input fmc2_adc3_clk_n,
  input [7:0]fmc2_adc3_data_in_p,
  input [7:0]fmc2_adc3_data_in_n,

  // FMC
  //input fmc2_prsnt_i, // connected to CPU
  //input fmc2_pg_m2c_i, // connected to CPU
  //input fmc2_clk_dir_i, // connected to CPU

  // Trigger
  output fmc2_trig_dir_o,
  output fmc2_trig_term_o,
  input fmc2_trig_val_o_p,
  input fmc2_trig_val_o_n,
  //inout fmc2_trig_val_o_p,
  //inout fmc2_trig_val_o_n,

  // ADC ISLA
  output [3:0]fmc2_spi_adc_cs,
  output fmc2_spi_adc_sclk_o,
  output fmc2_spi_adc_mosi_o,
  input fmc2_spi_adc_miso_i,

  output fmc2_adc_clkdivrst_o_p,
  output fmc2_adc_clkdivrst_o_n,
  output fmc2_adc_resetn_o,
  output fmc2_adc_sleep_o,

  // Si571 clock gen
  inout fmc2_si571_scl_pad,
  inout fmc2_si571_sda_pad,
  output fmc2_si571_oe_o,

  // AD9510 clock distribution PLL
  output fmc2_spi_ad9510_cs,
  output fmc2_spi_ad9510_sclk_o,
  output fmc2_spi_ad9510_mosi_o,
  input fmc2_spi_ad9510_miso_i,

  output fmc2_pll_function_o,
  input fmc2_pll_status_i,

  // Clock reference selection (TS3USB221)
  output fmc2_clk_sel_o,

  // EEPROM - connected to CPU
  //inout eeprom_scl_pad,
  //inout eeprom_sda_pad,

  // AMC7823 FMC monitor
  output fmc2_spi_amc7823_cs,
  output fmc2_spi_amc7823_sclk_o,
  output fmc2_spi_amc7823_mosi_o,
  input fmc2_spi_amc7823_miso_i,

  input fmc2_mon_dev_i,

  // LEDs
  output fmc2_led1_o,
  output fmc2_led2_o,
  output fmc2_led3_o,

  // LEDs on Kintex FC705 board
  //output board_led1_o,
  //output board_led2_o,
  //output board_led3_o,

  // Wishbone master  - RS232
  input rs232_rxd_i,
  output rs232_txd_o
);

localparam c_num_fmc = 2;

wire [31:0] wb_adr;
wire [31:0] wb_data_in, wb_data_out;
wire [3:0]wb_sel;

wire wb_stb1[c_num_fmc-1:0];
wire wb_err1[c_num_fmc-1:0];
wire wb_err1_or[c_num_fmc:0]; // num_fmc plus 1
wire wb_ack1[c_num_fmc-1:0];
wire [31:0]wb_data_out1[c_num_fmc-1:0];
wire wb_ack1_or[c_num_fmc:0]; // num_fmc plus 1
wire wb_acmp1[c_num_fmc-1:0];

wire wb_stb2[c_num_fmc-1:0];
wire wb_err2[c_num_fmc-1:0];
wire wb_err2_or[c_num_fmc:0]; // num_fmc plus 1
wire wb_ack2[c_num_fmc-1:0];
wire [31:0]wb_data_out2[c_num_fmc-1:0];
wire wb_ack2_or[c_num_fmc:0]; // num_fmc plus 1
wire wb_acmp2[c_num_fmc-1:0];

wire wb_stb3[c_num_fmc-1:0];
wire wb_err3[c_num_fmc-1:0];
wire wb_err3_or[c_num_fmc:0]; // num_fmc plus 1
wire wb_ack3[c_num_fmc-1:0];
wire [31:0]wb_data_out3[c_num_fmc-1:0];
wire wb_ack3_or[c_num_fmc:0]; // num_fmc plus 1
wire wb_acmp3[c_num_fmc-1:0];

wire wb_stb4[c_num_fmc-1:0];
wire wb_err4[c_num_fmc-1:0];
wire wb_err4_or[c_num_fmc:0]; // num_fmc plus 1
wire wb_ack4[c_num_fmc-1:0];
wire [31:0]wb_data_out4[c_num_fmc-1:0];
wire wb_ack4_or[c_num_fmc:0]; // num_fmc plus 1
wire wb_acmp4[c_num_fmc-1:0];

wire wb_stb5[c_num_fmc-1:0];
wire wb_err5[c_num_fmc-1:0];
wire wb_err5_or[c_num_fmc:0]; // num_fmc plus 1
wire wb_ack5[c_num_fmc-1:0];
wire [31:0]wb_data_out5[c_num_fmc-1:0];
wire wb_ack5_or[c_num_fmc:0]; // num_fmc plus 1
wire wb_acmp5[c_num_fmc-1:0];

wire wb_stb6[c_num_fmc-1:0];
wire wb_err6[c_num_fmc-1:0];
wire wb_err6_or[c_num_fmc:0]; // num_fmc plus 1
wire wb_ack6[c_num_fmc-1:0];
wire [31:0]wb_data_out6[c_num_fmc-1:0];
wire wb_ack6_or[c_num_fmc:0]; // num_fmc plus 1
wire wb_acmp6[c_num_fmc-1:0];

// Chipscope icon
wire [35:0] icon_ctrl0;
wire [35:0] icon_ctrl1;
wire [35:0] icon_ctrl2;
wire [35:0] icon_ctrl3;
wire [35:0] icon_ctrl4;
wire [35:0] icon_ctrl5;
wire [35:0] icon_ctrl6;
wire [35:0] icon_ctrl7;
wire [35:0] icon_ctrl8;

//// Top level wires to generate statements
//wire fmc_adc0_clk_p_int[c_num_fmc-1:0];
//wire fmc_adc0_clk_n_int[c_num_fmc-1:0];
//wire [7:0]fmc_adc0_data_in_p_int[c_num_fmc-1:0];
//wire [7:0]fmc_adc0_data_in_n_int[c_num_fmc-1:0];
//
//wire fmc_adc1_clk_p_int[c_num_fmc-1:0];
//wire fmc_adc1_clk_n_int[c_num_fmc-1:0];
//wire [7:0]fmc_adc1_data_in_p_int[c_num_fmc-1:0];
//wire [7:0]fmc_adc1_data_in_n_int[c_num_fmc-1:0];
//
//wire fmc_adc2_clk_p_int[c_num_fmc-1:0];
//wire fmc_adc2_clk_n_int[c_num_fmc-1:0];
//wire [7:0]fmc_adc2_data_in_p_int[c_num_fmc-1:0];
//wire [7:0]fmc_adc2_data_in_n_int[c_num_fmc-1:0];
//
//wire fmc_adc3_clk_p_int[c_num_fmc-1:0];
//wire fmc_adc3_clk_n_int[c_num_fmc-1:0];
//wire [7:0]fmc_adc3_data_in_p_int[c_num_fmc-1:0];
//wire [7:0]fmc_adc3_data_in_n_int[c_num_fmc-1:0];
//
//// FMC
////wire fmc_prsnt_i_int[c_num_fmc-1:0]; // connected to CPU
////wire fmc_pg_m2c_i_int[c_num_fmc-1:0]; // connected to CPU
////wire fmc_clk_dir_i_int[c_num_fmc-1:0]; // connected to CPU
//
//// Trigger
//wire fmc_trig_dir_o_int[c_num_fmc-1:0];
//wire fmc_trig_term_o_int[c_num_fmc-1:0];
//wire fmc_trig_val_o_p_int[c_num_fmc-1:0];
//wire fmc_trig_val_o_n_int[c_num_fmc-1:0];
////wire fmc_trig_val_o_p_int[c_num_fmc-1:0];
////wire fmc_trig_val_o_n_int[c_num_fmc-1:0];
//
//// ADC ISLA
//wire [3:0]fmc_spi_adc_cs_int[c_num_fmc-1:0];
//wire fmc_spi_adc_sclk_o_int[c_num_fmc-1:0];
//wire fmc_spi_adc_mosi_o_int[c_num_fmc-1:0];
//wire fmc_spi_adc_miso_i_int[c_num_fmc-1:0];
//
//wire fmc_adc_clkdivrst_o_p_int[c_num_fmc-1:0];
//wire fmc_adc_clkdivrst_o_n_int[c_num_fmc-1:0];
//wire fmc_adc_resetn_o_int[c_num_fmc-1:0];
//wire fmc_adc_sleep_o_int[c_num_fmc-1:0];
//
//// Si571 clock gen
//wire fmc_si571_scl_pad_int[c_num_fmc-1:0];
//wire fmc_si571_sda_pad_int[c_num_fmc-1:0];
//wire fmc_si571_oe_o_int[c_num_fmc-1:0];
//
//// AD9510 clock distribution PLL
//wire fmc_spi_ad9510_cs_int[c_num_fmc-1:0];
//wire fmc_spi_ad9510_sclk_o_int[c_num_fmc-1:0];
//wire fmc_spi_ad9510_mosi_o_int[c_num_fmc-1:0];
//wire fmc_spi_ad9510_miso_i_int[c_num_fmc-1:0];
//
//wire fmc_pll_function_o_int[c_num_fmc-1:0];
//wire fmc_pll_status_i_int[c_num_fmc-1:0];
//
//// Clock reference selection (TS3USB221)
//wire fmc_clk_sel_o_int[c_num_fmc-1:0];
//
//// EEPROM - connected to CPU
////wire fmc_eeprom_scl_pad_int[c_num_fmc-1:0];
////wire fmc_eeprom_sda_pad_int[c_num_fmc-1:0];
//
//// AMC7823 FMC monitor
//wire fmc_spi_amc7823_cs_int[c_num_fmc-1:0];
//wire fmc_spi_amc7823_sclk_o_int[c_num_fmc-1:0];
//wire fmc_spi_amc7823_mosi_o_int[c_num_fmc-1:0];
//wire fmc_spi_amc7823_miso_i_int[c_num_fmc-1:0];
//
//wire fmc_mon_dev_i_int[c_num_fmc-1:0];
//
//// LEDs
//wire fmc_led1_o_int[c_num_fmc-1:0];
//wire fmc_led2_o_int[c_num_fmc-1:0];
//wire fmc_led3_o_int[c_num_fmc-1:0];

genvar i;

generate
  assign wb_ack1_or[0] = 1'b0;
  assign wb_ack2_or[0] = 1'b0;
  assign wb_ack3_or[0] = 1'b0;
  assign wb_ack4_or[0] = 1'b0;
  assign wb_ack5_or[0] = 1'b0;
  assign wb_ack6_or[0] = 1'b0;

  // ORing all acks from each FMC
  for (i = 0; i < c_num_fmc; i=i+1) begin
    assign wb_ack1_or[i+1] = wb_ack1_or[i] || wb_ack1[i];
    assign wb_ack2_or[i+1] = wb_ack2_or[i] || wb_ack2[i];
    assign wb_ack3_or[i+1] = wb_ack3_or[i] || wb_ack3[i];
    assign wb_ack4_or[i+1] = wb_ack4_or[i] || wb_ack4[i];
    assign wb_ack5_or[i+1] = wb_ack5_or[i] || wb_ack5[i];
    assign wb_ack6_or[i+1] = wb_ack6_or[i] || wb_ack6[i];
  end;

  // ORing all acks from all FMCs
  assign wb_ack = wb_ack1_or[c_num_fmc] || wb_ack2_or[c_num_fmc] ||
                    wb_ack3_or[c_num_fmc] || wb_ack4_or[c_num_fmc] ||
                    wb_ack5_or[c_num_fmc] || wb_ack6_or[c_num_fmc];
endgenerate;

generate
  for (i = 0; i < c_num_fmc; i=i+1) begin
    assign wb_stb1[i] = wb_cyc && wb_stb && wb_acmp1[i];
    assign wb_stb2[i] = wb_cyc && wb_stb && wb_acmp2[i];
    assign wb_stb3[i] = wb_cyc && wb_stb && wb_acmp3[i];
    assign wb_stb4[i] = wb_cyc && wb_stb && wb_acmp4[i];
    assign wb_stb5[i] = wb_cyc && wb_stb && wb_acmp5[i];
    assign wb_stb6[i] = wb_cyc && wb_stb && wb_acmp6[i];
  end;
endgenerate;

generate
  assign wb_err1_or[0] = 1'b0;
  assign wb_err2_or[0] = 1'b0;
  assign wb_err3_or[0] = 1'b0;
  assign wb_err4_or[0] = 1'b0;
  assign wb_err5_or[0] = 1'b0;
  assign wb_err6_or[0] = 1'b0;

  // ORing all errs from each FMC
  for (i = 0; i < c_num_fmc; i=i+1) begin
    assign wb_err1_or[i+1] = wb_err1_or[i] || wb_err1[i];
    assign wb_err2_or[i+1] = wb_err2_or[i] || wb_err2[i];
    assign wb_err3_or[i+1] = wb_err3_or[i] || wb_err3[i];
    assign wb_err4_or[i+1] = wb_err4_or[i] || wb_err4[i];
    assign wb_err5_or[i+1] = wb_err5_or[i] || wb_err5[i];
    assign wb_err6_or[i+1] = wb_err6_or[i] || wb_err6[i];
  end;

  // ORing all errs from all FMCs
  assign wb_err = wb_err1_or[c_num_fmc] || wb_err2_or[c_num_fmc] ||
                    wb_err3_or[c_num_fmc] || wb_err4_or[c_num_fmc] ||
                    wb_err5_or[c_num_fmc] || wb_err6_or[c_num_fmc];
endgenerate;

wire [3:0]fmc1_idelay_rdy;
wire [4:0]fmc1_idelay0_val;
wire [4:0]fmc1_idelay1_val;
wire [4:0]fmc1_idelay2_val;
wire [4:0]fmc1_idelay3_val;
wire [4:0]fmc1_idelay0_read;
wire [4:0]fmc1_idelay1_read;
wire [4:0]fmc1_idelay2_read;
wire [4:0]fmc1_idelay3_read;
wire [16:0]fmc1_idelay0_select;
wire [16:0]fmc1_idelay1_select;
wire [16:0]fmc1_idelay2_select;
wire [16:0]fmc1_idelay3_select;

wire [127:0]fmc1_w_data;

wire [3:0]fmc2_idelay_rdy;
wire [4:0]fmc2_idelay0_val;
wire [4:0]fmc2_idelay1_val;
wire [4:0]fmc2_idelay2_val;
wire [4:0]fmc2_idelay3_val;
wire [4:0]fmc2_idelay0_read;
wire [4:0]fmc2_idelay1_read;
wire [4:0]fmc2_idelay2_read;
wire [4:0]fmc2_idelay3_read;
wire [16:0]fmc2_idelay0_select;
wire [16:0]fmc2_idelay1_select;
wire [16:0]fmc2_idelay2_select;
wire [16:0]fmc2_idelay3_select;

wire [127:0]fmc2_w_data;

//// Top level wires to generate statements
//assign fmc_adc0_clk_p_int[0] = fmc1_adc0_clk_p;
//assign fmc_adc0_clk_p_int[1] = fmc2_adc0_clk_p;
//assign fmc_adc0_clk_n_int[0] = fmc1_adc0_clk_n;
//assign fmc_adc0_clk_n_int[1] = fmc2_adc0_clk_n;
//assign fmc_adc0_data_in_p_int[0] = fmc1_adc0_data_in_p;
//assign fmc_adc0_data_in_p_int[1] = fmc2_adc0_data_in_p;
//assign fmc_adc0_data_in_n_int[0] = fmc1_adc0_data_in_n;
//assign fmc_adc0_data_in_n_int[1] = fmc2_adc0_data_in_n;
//
//assign fmc_adc1_clk_p_int[0] = fmc1_adc1_clk_p;
//assign fmc_adc1_clk_p_int[1] = fmc2_adc1_clk_p;
//assign fmc_adc1_clk_n_int[0] = fmc1_adc1_clk_n;
//assign fmc_adc1_clk_n_int[1] = fmc2_adc1_clk_n;
//assign fmc_adc1_data_in_p_int[0] = fmc1_adc1_data_in_p;
//assign fmc_adc1_data_in_p_int[1] = fmc2_adc1_data_in_p;
//assign fmc_adc1_data_in_n_int[0] = fmc1_adc1_data_in_n;
//assign fmc_adc1_data_in_n_int[1] = fmc2_adc1_data_in_n;
//
//assign fmc_adc2_clk_p_int[0] = fmc1_adc2_clk_p;
//assign fmc_adc2_clk_p_int[1] = fmc2_adc2_clk_p;
//assign fmc_adc2_clk_n_int[0] = fmc1_adc2_clk_n;
//assign fmc_adc2_clk_n_int[1] = fmc2_adc2_clk_n;
//assign fmc_adc2_data_in_p_int[0] = fmc1_adc2_data_in_p;
//assign fmc_adc2_data_in_p_int[1] = fmc2_adc2_data_in_p;
//assign fmc_adc2_data_in_n_int[0] = fmc1_adc2_data_in_n;
//assign fmc_adc2_data_in_n_int[1] = fmc2_adc2_data_in_n;
//
//assign fmc_adc3_clk_p_int[0] = fmc1_adc3_clk_p;
//assign fmc_adc3_clk_p_int[1] = fmc2_adc3_clk_p;
//assign fmc_adc3_clk_n_int[0] = fmc1_adc3_clk_n;
//assign fmc_adc3_clk_n_int[1] = fmc2_adc3_clk_n;
//assign fmc_adc3_data_in_p_int[0] = fmc1_adc3_data_in_p;
//assign fmc_adc3_data_in_p_int[1] = fmc2_adc3_data_in_p;
//assign fmc_adc3_data_in_n_int[0] = fmc1_adc3_data_in_n;
//assign fmc_adc3_data_in_n_int[1] = fmc2_adc3_data_in_n;
//
//// FMC
////assign fmc_prsnt_i_int[0]; // connected to CPU
////assign fmc_pg_m2c_i_int[0]; // connected to CPU
////assign fmc_clk_dir_i_int[0]; // connected to CPU
//
//// Trigger
//assign fmc1_trig_dir_o = fmc_trig_dir_o_int[0];
//assign fmc2_trig_dir_o = fmc_trig_dir_o_int[1];
//assign fmc1_trig_term_o = fmc_trig_term_o_int[0];
//assign fmc2_trig_term_o = fmc_trig_term_o_int[1];
//assign fmc1_trig_val_o_p = fmc_trig_val_o_p_int[0];
//assign fmc2_trig_val_o_p = fmc_trig_val_o_p_int[1];
//assign fmc1_trig_val_o_n = fmc_trig_val_o_n_int[0];
//assign fmc2_trig_val_o_n = fmc_trig_val_o_n_int[1];
//
//// ADC ISLA
//assign fmc1_spi_adc_cs = fmc_spi_adc_cs_int[0];
//assign fmc2_spi_adc_cs = fmc_spi_adc_cs_int[1];
//assign fmc1_spi_adc_sclk_o = fmc_spi_adc_sclk_o_int[0];
//assign fmc2_spi_adc_sclk_o = fmc_spi_adc_sclk_o_int[1];
//assign fmc1_spi_adc_mosi_o = fmc_spi_adc_mosi_o_int[0];
//assign fmc2_spi_adc_mosi_o = fmc_spi_adc_mosi_o_int[1];
//assign fmc_spi_adc_miso_i_int[0] = fmc1_spi_adc_miso_i;
//assign fmc_spi_adc_miso_i_int[1] = fmc2_spi_adc_miso_i;
//
//assign fmc1_adc_clkdivrst_o_p = fmc_adc_clkdivrst_o_p_int[0];
//assign fmc2_adc_clkdivrst_o_p = fmc_adc_clkdivrst_o_p_int[1];
//assign fmc1_adc_clkdivrst_o_n = fmc_adc_clkdivrst_o_n_int[0];
//assign fmc2_adc_clkdivrst_o_n = fmc_adc_clkdivrst_o_n_int[1];
//assign fmc1_adc_resetn_o = fmc_adc_resetn_o_int[0];
//assign fmc2_adc_resetn_o = fmc_adc_resetn_o_int[1];
//assign fmc1_adc_sleep_o = fmc_adc_sleep_o_int[0];
//assign fmc2_adc_sleep_o = fmc_adc_sleep_o_int[1];
//
//// Si571 clock gen
//assign fmc1_si571_scl_pad = fmc_si571_scl_pad_int[0];
//assign fmc2_si571_scl_pad = fmc_si571_scl_pad_int[1];
//assign fmc1_si571_sda_pad = fmc_si571_sda_pad_int[0];
//assign fmc2_si571_sda_pad = fmc_si571_sda_pad_int[1];
//assign fmc1_si571_oe_o = fmc_si571_oe_o_int[0];
//assign fmc2_si571_oe_o = fmc_si571_oe_o_int[1];
//
//// AD9510 clock distribution PLL
//assign fmc1_spi_ad9510_cs = fmc_spi_ad9510_cs_int[0];
//assign fmc2_spi_ad9510_cs = fmc_spi_ad9510_cs_int[1];
//assign fmc1_spi_ad9510_sclk_o = fmc_spi_ad9510_sclk_o_int[0];
//assign fmc2_spi_ad9510_sclk_o = fmc_spi_ad9510_sclk_o_int[1];
//assign fmc1_spi_ad9510_mosi_o = fmc_spi_ad9510_mosi_o_int[0];
//assign fmc2_spi_ad9510_mosi_o = fmc_spi_ad9510_mosi_o_int[1];
//assign fmc_spi_ad9510_miso_i_int[0] = fmc1_spi_ad9510_miso_i;
//assign fmc_spi_ad9510_miso_i_int[1] = fmc2_spi_ad9510_miso_i;
//
//assign fmc1_pll_function_o = fmc_pll_function_o_int[0];
//assign fmc2_pll_function_o = fmc_pll_function_o_int[1];
//assign fmc_pll_status_i_int[0] = fmc1_pll_status_i;
//assign fmc_pll_status_i_int[1] = fmc2_pll_status_i;
//
//// Clock reference selection (TS3USB221)
//assign fmc1_clk_sel_o = fmc_clk_sel_o_int[0];
//assign fmc1_clk_sel_o = fmc_clk_sel_o_int[1];
//
//// EEPROM - connected to CPU
////assign fmc_eeprom_scl_pad_int[0];
////assign fmc_eeprom_sda_pad_int[0];
//
//// AMC7823 FMC monitor
//assign fmc1_spi_amc7823_cs = fmc_spi_amc7823_cs_int[0];
//assign fmc2_spi_amc7823_cs = fmc_spi_amc7823_cs_int[0];
//assign fmc1_spi_amc7823_sclk_o = fmc_spi_amc7823_sclk_o_int[0];
//assign fmc2_spi_amc7823_sclk_o = fmc_spi_amc7823_sclk_o_int[0];
//assign fmc1_spi_amc7823_mosi_o = fmc_spi_amc7823_mosi_o_int[0];
//assign fmc2_spi_amc7823_mosi_o = fmc_spi_amc7823_mosi_o_int[0];
//assign fmc_spi_amc7823_miso_i_int[0] = fmc1_spi_amc7823_miso_i;
//assign fmc_spi_amc7823_miso_i_int[0] = fmc2_spi_amc7823_miso_i;
//
//assign fmc_mon_dev_i_int[0] = fmc1_mon_dev_i;
//assign fmc_mon_dev_i_int[1] = fmc2_mon_dev_i;
//
//// LEDs
//assign fmc1_led1_o = fmc_led1_o_int[0];
//assign fmc2_led1_o = fmc_led1_o_int[1];
//assign fmc1_led2_o = fmc_led2_o_int[0];
//assign fmc2_led2_o = fmc_led2_o_int[1];
//assign fmc1_led3_o = fmc_led3_o_int[0];
//assign fmc2_led3_o = fmc_led3_o_int[1];

////////////////////////////////////////////////////////////////
////////////////////////// FMC 1 Devices ///////////////////////
////////////////////////////////////////////////////////////////

fmc_adc_250m_4ch #(
  .FPGA_DEVICE("7SERIES"),
  .FPGA_BOARD("AFC"),
  .USE_CHIPSCOPE_ICON(0)
  )  fmc1_adc_250m_4ch_i(
  .sys_clk(wb_clk),
  .ref_clk(ref_clk),
  .rst(wb_rst || fmc1_reg_rst),
  .trigger(),

  .adc0_clk_p(fmc1_adc0_clk_p),
  .adc0_clk_n(fmc1_adc0_clk_n),
  .adc0_data_in_p(fmc1_adc0_data_in_p),
  .adc0_data_in_n(fmc1_adc0_data_in_n),

  .adc1_clk_p(fmc1_adc1_clk_p),
  .adc1_clk_n(fmc1_adc1_clk_n),
  .adc1_data_in_p(fmc1_adc1_data_in_p),
  .adc1_data_in_n(fmc1_adc1_data_in_n),

  .adc2_clk_p(fmc1_adc2_clk_p),
  .adc2_clk_n(fmc1_adc2_clk_n),
  .adc2_data_in_p(fmc1_adc2_data_in_p),
  .adc2_data_in_n(fmc1_adc2_data_in_n),

  .adc3_clk_p(fmc1_adc3_clk_p),
  .adc3_clk_n(fmc1_adc3_clk_n),
  .adc3_data_in_p(fmc1_adc3_data_in_p),
  .adc3_data_in_n(fmc1_adc3_data_in_n),

  .adc0_delay_reg(fmc1_idelay0_val),
  .adc0_delay_reg_read(fmc1_idelay0_read),
  .adc0_delay_load(fmc1_idelay0_load),
  .adc0_delay_select(fmc1_idelay0_select),
  .adc0_delay_rdy(fmc1_idelay_rdy[0]),

  .adc1_delay_reg(fmc1_idelay1_val),
  .adc1_delay_reg_read(fmc1_idelay1_read),
  .adc1_delay_load(fmc1_idelay1_load),
  .adc1_delay_select(fmc1_idelay1_select),
  .adc1_delay_rdy(fmc1_idelay_rdy[1]),

  .adc2_delay_reg(fmc1_idelay2_val),
  .adc2_delay_reg_read(fmc1_idelay2_read),
  .adc2_delay_load(fmc1_idelay2_load),
  .adc2_delay_select(fmc1_idelay2_select),
  .adc2_delay_rdy(fmc1_idelay_rdy[2]),

  .adc3_delay_reg(fmc1_idelay3_val),
  .adc3_delay_reg_read(fmc1_idelay3_read),
  .adc3_delay_load(fmc1_idelay3_load),
  .adc3_delay_select(fmc1_idelay3_select),
  .adc3_delay_rdy(fmc1_idelay_rdy[3]),

  .data(fmc1_w_data),

  .icon_ctrl0_i(icon_ctrl0),
  .icon_ctrl1_i(icon_ctrl1),
  .icon_ctrl2_i(icon_ctrl2),
  .icon_ctrl3_i(icon_ctrl3)
);

// =====================================
//              INTERFACES
// =====================================

// =====================================
//              ISLA216P25
// =====================================
//                 SPI
// =====================================
// Address: 0x10000
// =====================================
wb_spi_bidir wb_fmc1_spi_bidir_i_isla (
      .clk_sys_i(wb_clk),
      .rst_n_i  (wb_rst),

      .wb_adr_i(wb_adr),
      .wb_dat_i(wb_data_in),
      .wb_dat_o(wb_data_out1[0]),
      .wb_sel_i(wb_sel),
      .wb_stb_i(wb_stb1[0]),
      .wb_cyc_i(wb_cyc),
      .wb_we_i(wb_we),
      .wb_ack_o(wb_ack1[0]),
      .wb_err_o(wb_err1[0]),
      .wb_int_o(),

      .pad_cs_o(fmc1_spi_adc_cs),
      .pad_sclk_o(fmc1_spi_adc_sclk_o),
      .pad_mosi_o(fmc1_spi_adc_mosi_o),
      .pad_mosi_i(),
      .pad_mosi_en(),
      .pad_miso_i(fmc1_spi_adc_miso_i)
      );

// =====================================
//                Si571
// =====================================
//                 I2C
// =====================================
// Address: 0x20000
// =====================================
i2c_master_top wb_fmc1_i2c_master_i_si571 (
      .wb_clk_i(wb_clk),
      .wb_rst_i(wb_rst),
      .arst_i(),
      .wb_adr_i(wb_adr),
      .wb_dat_i(wb_data_in),
      .wb_dat_o(wb_data_out2[0]),
      .wb_we_i(wb_we),
      .wb_stb_i(wb_stb2[0]),
      //.wb_sel_i(wb_sel),
      .wb_cyc_i(wb_cyc),
      .wb_ack_o(wb_ack2[0]),
      //.wb_int_o(),

      .scl_pad_i(fmc1_si571_scl_in),
      .scl_pad_o(fmc1_si571_scl_out),
      .scl_padoen_o(fmc1_si571_scl_oe_n),
      .sda_pad_i(fmc1_si571_sda_in),
      .sda_pad_o(fmc1_si571_sda_out),
      .sda_padoen_o(fmc1_si571_sda_oe_n)
      );

assign fmc1_si571_scl_pad = fmc1_si571_scl_oe_n ? 1'bz : fmc1_si571_scl_out;
assign fmc1_si571_scl_in = fmc1_si571_scl_pad;

assign fmc1_si571_sda_pad = fmc1_si571_sda_oe_n ? 1'bz : fmc1_si571_sda_out;
assign fmc1_si571_sda_in = fmc1_si571_sda_pad;

// =====================================
//                AD9510
// =====================================
//                 SPI
// =====================================
// Address: 0x30000
// =====================================
wb_spi_bidir wb_fmc1_spi_bidir_i_ad9510 (
      .clk_sys_i(wb_clk),
      .rst_n_i  (wb_rst),

      .wb_adr_i(wb_adr),
      .wb_dat_i(wb_data_in),
      .wb_dat_o(wb_data_out3[0]),
      .wb_sel_i(wb_sel),
      .wb_stb_i(wb_stb3[0]),
      .wb_cyc_i(wb_cyc),
      .wb_we_i(wb_we),
      .wb_ack_o(wb_ack3[0]),
      .wb_err_o(wb_err3[0]),
      .wb_int_o(),

      .pad_cs_o(fmc1_spi_ad9510_cs),
      .pad_sclk_o(fmc1_spi_ad9510_sclk_o),
      .pad_mosi_o(fmc1_spi_ad9510_mosi_o),
      .pad_mosi_i(),
      .pad_mosi_en(),
      .pad_miso_i(fmc1_spi_ad9510_miso_i)
  );

// =====================================
//               24AA64T-I
// =====================================
//                 I2C
// =====================================
// Address: 0x40000
// =====================================
i2c_master_top wb_fmc1_i2c_master_i_eeprom (
      .wb_clk_i(wb_clk),
      .wb_rst_i(wb_rst),
      .arst_i(),
      .wb_adr_i(wb_adr),
      .wb_dat_i(wb_data_in),
      .wb_dat_o(wb_data_out4[0]),
      .wb_we_i(wb_we),
      .wb_stb_i(wb_stb4[0]),
      //.wb_sel_i(wb_sel),
      .wb_cyc_i(wb_cyc),
      .wb_ack_o(wb_ack4[0]),
      //.wb_int_o(),

      .scl_pad_i(fmc1_eeprom_scl_in),
      .scl_pad_o(fmc1_eeprom_scl_out),
      .scl_padoen_o(fmc1_eeprom_scl_oe_n),
      .sda_pad_i(fmc1_eeprom_sda_in),
      .sda_pad_o(fmc1_eeprom_sda_out),
      .sda_padoen_o(fmc1_eeprom_sda_oe_n)
      );

assign fmc1_eeprom_scl_pad = fmc1_eeprom_scl_oe_n ? 1'bz : fmc1_eeprom_scl_out;
assign fmc1_eeprom_scl_in = fmc1_eeprom_scl_pad;

assign fmc1_eeprom_sda_pad = fmc1_eeprom_sda_oe_n ? 1'bz : fmc1_eeprom_sda_out;
assign fmc1_eeprom_sda_in = fmc1_eeprom_sda_pad;

// =====================================
//               AMC7823
// =====================================
//                 SPI
// =====================================
// Address: 0x50000
// =====================================
wb_spi_bidir wb_fmc1_spi_bidir_i_amc7823 (
      .clk_sys_i(wb_clk),
      .rst_n_i  (wb_rst),

      .wb_adr_i(wb_adr),
      .wb_dat_i(wb_data_in),
      .wb_dat_o(wb_data_out5[0]),
      .wb_sel_i(wb_sel),
      .wb_stb_i(wb_stb5[0]),
      .wb_cyc_i(wb_cyc),
      .wb_we_i(wb_we),
      .wb_ack_o(wb_ack5[0]),
      .wb_err_o(wb_err5[0]),
      .wb_int_o(),

      .pad_cs_o(fmc1_spi_amc7823_cs),
      .pad_sclk_o(fmc1_spi_amc7823_sclk_o),
      .pad_mosi_o(fmc1_spi_amc7823_mosi_o),
      .pad_mosi_i(),
      .pad_mosi_en(),
      .pad_miso_i(fmc1_spi_amc7823_miso_i)
    );

// =====================================
//               TRIGGER
// =====================================
// Trigger data output (if in output mode)
IBUFDS #(
      .DIFF_TERM("FALSE"),       // Differential Termination
      .IBUF_LOW_PWR("FALSE"),     // Low power="TRUE", Highest performance="FALSE"
      .IOSTANDARD("LVDS_25")     // Specify the input I/O standard
   ) IBUFDS_fmc1_inst (
      .O(fmc1_trig_val_i),  // Buffer output
      .I(fmc1_trig_val_o_p),  // Diff_p buffer input (connect directly to top-level port)
      .IB(fmc1_trig_val_o_n) // Diff_n buffer input (connect directly to top-level port)
   );

//IOBUFDS #(
//      .DIFF_TERM("FALSE"),    // Differential Termination ("TRUE"/"FALSE")
//      .IBUF_LOW_PWR("FALSE"),  // Low Power - "TRUE", High Performance = "FALSE"
//      .IOSTANDARD("BLVDS_25") // Specify the I/O standard
//   ) IOBUFDS_fmc1_trig (
//      .O(fmc1_trig_val_i),     // Buffer output  // for further use!!!
//      .IO(fmc1_trig_val_o_p),   // Diff_p inout (connect directly to top-level port)
//      .IOB(fmc1_trig_val_o_n), // Diff_n inout (connect directly to top-level port)
//      .I(fmc1_trig_val_o_reg), // Buffer input
//      .T(fmc1_trig_dir_o)      // 3-state enable input, high=input, low=output
//   );

OBUFDS #(
      //.IOSTANDARD("DIFF_HSTL_II_DCI_18") // Specify the output I/O standard
                .IOSTANDARD("LVDS_25") // Specify the output I/O standard
                //.IOSTANDARD("LVDS") // Specify the output I/O standard 1.8V
   ) OBUFDS_fmc1_adc_rst (
      .O(fmc1_adc_clkdivrst_o_p),     // Diff_p output (connect directly to top-level port)
      .OB(fmc1_adc_clkdivrst_o_n),   // Diff_n output (connect directly to top-level port)
      .I(fmc1_adc_clkdivrst_o)      // Buffer input
   );

wire [1:0]fmc1_adc_sleep_w;
assign fmc1_adc_sleep_o = fmc1_adc_sleep_w[1] ? 1'bz : (fmc1_adc_sleep_w[0] ? 1'b1 : 1'b0);

wb_fmc_250m_4ch_csr wb_fmc1_250m_4ch_csr_i (
    .rst_n_i(!wb_rst),
    .wb_clk_i(wb_clk),
    .wb_addr_i(wb_adr),
    .wb_data_i(wb_data_in),
    .wb_data_o(wb_data_out6[0]),
    .wb_cyc_i(wb_cyc),
    .wb_sel_i(wb_sel),
    .wb_stb_i(wb_stb6[0]),
    .wb_we_i(wb_we),
    .wb_ack_o(wb_ack6[0]),

    // General FMC status
    .wb_fmc_250m_4ch_csr_fmc_status_prsnt_i(fmc1_prsnt_i),
    .wb_fmc_250m_4ch_csr_fmc_status_pg_m2c_i(fmc1_pg_m2c_i),
    .wb_fmc_250m_4ch_csr_fmc_status_clk_dir_i(1'b0), // not supported on Kintex7 KC705 board
    .wb_fmc_250m_4ch_csr_fmc_status_firmware_id_i(32'h01332A11),
    // Trigger config
    .wb_fmc_250m_4ch_csr_trigger_dir_o(fmc1_trig_dir_o),
    .wb_fmc_250m_4ch_csr_trigger_term_o(fmc1_trig_term_o),
    .wb_fmc_250m_4ch_csr_trigger_trig_val_o(fmc1_trig_val_o_reg),
    .wb_fmc_250m_4ch_csr_trigger_reserved_i(0),
    // ADC config
    .wb_fmc_250m_4ch_csr_adc_clkdivrst_o(fmc1_adc_clkdivrst_o),
    .wb_fmc_250m_4ch_csr_adc_resetn_o(fmc1_adc_resetn_o),
    .wb_fmc_250m_4ch_csr_adc_sleep_o(fmc1_adc_sleep_w),
    .wb_fmc_250m_4ch_csr_adc_reserved_i(0),
    // Clock distribution config
    .wb_fmc_250m_4ch_csr_clk_distrib_si571_oe_o(fmc1_si571_oe_o),
    .wb_fmc_250m_4ch_csr_clk_distrib_pll_function_o(fmc1_pll_function_o),
    .wb_fmc_250m_4ch_csr_clk_distrib_pll_status_i(fmc1_pll_status_i),
    .wb_fmc_250m_4ch_csr_clk_distrib_clk_sel_o(fmc1_clk_sel_o),
    .wb_fmc_250m_4ch_csr_clk_distrib_reserved_i(0),
    // Monitoring and FMC status
    .wb_fmc_250m_4ch_csr_monitor_mon_dev_i(fmc1_mon_dev_i),
    .wb_fmc_250m_4ch_csr_monitor_led1_o(fmc1_led1_o_w),
    .wb_fmc_250m_4ch_csr_monitor_led2_o(fmc1_led2_o_w),
    .wb_fmc_250m_4ch_csr_monitor_led3_o(fmc1_led3_o_w),
    .wb_fmc_250m_4ch_csr_monitor_reserved_i(0),
    // FPGA control
    .wb_fmc_250m_4ch_csr_fpga_ctrl_fmc_idelay_rst_o(fmc1_reg_rst),
    .wb_fmc_250m_4ch_csr_fpga_ctrl_fmc_fifo_rst_o(),
    .wb_fmc_250m_4ch_csr_fpga_ctrl_fmc_idelay0_rdy_i(fmc1_idelay_rdy[0]),
    .wb_fmc_250m_4ch_csr_fpga_ctrl_fmc_idelay1_rdy_i(fmc1_idelay_rdy[1]),
    .wb_fmc_250m_4ch_csr_fpga_ctrl_fmc_idelay2_rdy_i(fmc1_idelay_rdy[2]),
    .wb_fmc_250m_4ch_csr_fpga_ctrl_fmc_idelay3_rdy_i(fmc1_idelay_rdy[3]),
    .wb_fmc_250m_4ch_csr_fpga_ctrl_reserved_i(0),

    // IDELAY lines control
    .wb_fmc_250m_4ch_csr_idelay0_cal_update_o(fmc1_idelay0_load),
    .wb_fmc_250m_4ch_csr_idelay0_cal_line_o(fmc1_idelay0_select),
    .wb_fmc_250m_4ch_csr_idelay0_cal_val_o(fmc1_idelay0_val),
    .wb_fmc_250m_4ch_csr_idelay0_cal_val_read_i(fmc1_idelay0_read),
    .wb_fmc_250m_4ch_csr_idelay0_cal_reserved_i(0),

    .wb_fmc_250m_4ch_csr_idelay1_cal_update_o(fmc1_idelay1_load),
    .wb_fmc_250m_4ch_csr_idelay1_cal_line_o(fmc1_idelay1_select),
    .wb_fmc_250m_4ch_csr_idelay1_cal_val_o(fmc1_idelay1_val),
    .wb_fmc_250m_4ch_csr_idelay1_cal_val_read_i(fmc1_idelay1_read),
    .wb_fmc_250m_4ch_csr_idelay1_cal_reserved_i(0),

    .wb_fmc_250m_4ch_csr_idelay2_cal_update_o(fmc1_idelay2_load),
    .wb_fmc_250m_4ch_csr_idelay2_cal_line_o(fmc1_idelay2_select),
    .wb_fmc_250m_4ch_csr_idelay2_cal_val_o(fmc1_idelay2_val),
    .wb_fmc_250m_4ch_csr_idelay2_cal_val_read_i(fmc1_idelay2_read),
    .wb_fmc_250m_4ch_csr_idelay2_cal_reserved_i(0),

    .wb_fmc_250m_4ch_csr_idelay3_cal_update_o(fmc1_idelay3_load),
    .wb_fmc_250m_4ch_csr_idelay3_cal_line_o(fmc1_idelay3_select),
    .wb_fmc_250m_4ch_csr_idelay3_cal_val_o(fmc1_idelay3_val),
    .wb_fmc_250m_4ch_csr_idelay3_cal_val_read_i(fmc1_idelay3_read),
    .wb_fmc_250m_4ch_csr_idelay3_cal_reserved_i(0),

    .wb_fmc_250m_4ch_csr_data0_val_i(fmc1_w_data[31:0]),
    .wb_fmc_250m_4ch_csr_data1_val_i(fmc1_w_data[63:32]),
    .wb_fmc_250m_4ch_csr_data2_val_i(fmc1_w_data[95:64]),
    .wb_fmc_250m_4ch_csr_data3_val_i(fmc1_w_data[127:96])

  );

assign fmc1_led1_o = fmc1_led1_o_w || fmc1_trig_val_i; // trigger tests (input), blinking LED (1kHz, TTL)
assign fmc1_led2_o = fmc1_led2_o_w;
assign fmc1_led3_o = fmc1_led3_o_w;

//assign board_led1_o = fmc1_led1_o_w;
//assign board_led2_o = fmc1_led2_o_w;
//assign board_led3_o = fmc1_led3_o_w;

////////////////////////////////////////////////////////////////
////////////////////////// FMC 2 Devices ///////////////////////
////////////////////////////////////////////////////////////////

fmc_adc_250m_4ch #(
  .FPGA_DEVICE("7SERIES"),
  .FPGA_BOARD("AFC"),
  .USE_CHIPSCOPE_ICON(0)
  ) fmc2_adc_250m_4ch_i(
  .sys_clk(wb_clk),
  .ref_clk(ref_clk),
  .rst(wb_rst || fmc2_reg_rst),
  .trigger(),

  .adc0_clk_p(fmc2_adc0_clk_p),
  .adc0_clk_n(fmc2_adc0_clk_n),
  .adc0_data_in_p(fmc2_adc0_data_in_p),
  .adc0_data_in_n(fmc2_adc0_data_in_n),

  .adc1_clk_p(fmc2_adc1_clk_p),
  .adc1_clk_n(fmc2_adc1_clk_n),
  .adc1_data_in_p(fmc2_adc1_data_in_p),
  .adc1_data_in_n(fmc2_adc1_data_in_n),

  .adc2_clk_p(fmc2_adc2_clk_p),
  .adc2_clk_n(fmc2_adc2_clk_n),
  .adc2_data_in_p(fmc2_adc2_data_in_p),
  .adc2_data_in_n(fmc2_adc2_data_in_n),

  .adc3_clk_p(fmc2_adc3_clk_p),
  .adc3_clk_n(fmc2_adc3_clk_n),
  .adc3_data_in_p(fmc2_adc3_data_in_p),
  .adc3_data_in_n(fmc2_adc3_data_in_n),

  .adc0_delay_reg(fmc2_idelay0_val),
  .adc0_delay_reg_read(fmc2_idelay0_read),
  .adc0_delay_load(fmc2_idelay0_load),
  .adc0_delay_select(fmc2_idelay0_select),
  .adc0_delay_rdy(fmc2_idelay_rdy[0]),

  .adc1_delay_reg(fmc2_idelay1_val),
  .adc1_delay_reg_read(fmc2_idelay1_read),
  .adc1_delay_load(fmc2_idelay1_load),
  .adc1_delay_select(fmc2_idelay1_select),
  .adc1_delay_rdy(fmc2_idelay_rdy[1]),

  .adc2_delay_reg(fmc2_idelay2_val),
  .adc2_delay_reg_read(fmc2_idelay2_read),
  .adc2_delay_load(fmc2_idelay2_load),
  .adc2_delay_select(fmc2_idelay2_select),
  .adc2_delay_rdy(fmc2_idelay_rdy[2]),

  .adc3_delay_reg(fmc2_idelay3_val),
  .adc3_delay_reg_read(fmc2_idelay3_read),
  .adc3_delay_load(fmc2_idelay3_load),
  .adc3_delay_select(fmc2_idelay3_select),
  .adc3_delay_rdy(fmc2_idelay_rdy[3]),

  .data(fmc2_w_data),

  .icon_ctrl0_i(icon_ctrl4),
  .icon_ctrl1_i(icon_ctrl5),
  .icon_ctrl2_i(icon_ctrl6),
  .icon_ctrl3_i(icon_ctrl7)
);

// =====================================
//              INTERFACES
// =====================================

// =====================================
//              ISLA216P25
// =====================================
//                 SPI
// =====================================
// Address: 0x10000
// =====================================
wb_spi_bidir wb_fmc2_spi_bidir_i_isla (
      .clk_sys_i(wb_clk),
      .rst_n_i  (wb_rst),

      .wb_adr_i(wb_adr),
      .wb_dat_i(wb_data_in),
      .wb_dat_o(wb_data_out1[1]),
      .wb_sel_i(wb_sel),
      .wb_stb_i(wb_stb1[1]),
      .wb_cyc_i(wb_cyc),
      .wb_we_i(wb_we),
      .wb_ack_o(wb_ack1[1]),
      .wb_err_o(wb_err1[1]),
      .wb_int_o(),

      .pad_cs_o(fmc2_spi_adc_cs),
      .pad_sclk_o(fmc2_spi_adc_sclk_o),
      .pad_mosi_o(fmc2_spi_adc_mosi_o),
      .pad_mosi_i(),
      .pad_mosi_en(),
      .pad_miso_i(fmc2_spi_adc_miso_i)
    );

// =====================================
//                Si571
// =====================================
//                 I2C
// =====================================
// Address: 0x20000
// =====================================
i2c_master_top wb_fmc2_i2c_master_i_si571 (
      .wb_clk_i(wb_clk),
      .wb_rst_i(wb_rst),
      .arst_i(),
      .wb_adr_i(wb_adr),
      .wb_dat_i(wb_data_in),
      .wb_dat_o(wb_data_out2[1]),
      .wb_we_i(wb_we),
      .wb_stb_i(wb_stb2[1]),
      //.wb_sel_i(wb_sel),
      .wb_cyc_i(wb_cyc),
      .wb_ack_o(wb_ack2[1]),
      //.wb_int_o(),

      .scl_pad_i(fmc2_si571_scl_in),
      .scl_pad_o(fmc2_si571_scl_out),
      .scl_padoen_o(fmc2_si571_scl_oe_n),
      .sda_pad_i(fmc2_si571_sda_in),
      .sda_pad_o(fmc2_si571_sda_out),
      .sda_padoen_o(fmc2_si571_sda_oe_n)
      );

assign fmc2_si571_scl_pad = fmc2_si571_scl_oe_n ? 1'bz : fmc2_si571_scl_out;
assign fmc2_si571_scl_in = fmc2_si571_scl_pad;

assign fmc2_si571_sda_pad = fmc2_si571_sda_oe_n ? 1'bz : fmc2_si571_sda_out;
assign fmc2_si571_sda_in = fmc2_si571_sda_pad;

// =====================================
//                AD9510
// =====================================
//                 SPI
// =====================================
// Address: 0x30000
// =====================================
wb_spi_bidir wb_fmc2_spi_bidir_i_ad9510 (
      .clk_sys_i(wb_clk),
      .rst_n_i  (wb_rst),

      .wb_adr_i(wb_adr),
      .wb_dat_i(wb_data_in),
      .wb_dat_o(wb_data_out3[1]),
      .wb_sel_i(wb_sel),
      .wb_stb_i(wb_stb3[1]),
      .wb_cyc_i(wb_cyc),
      .wb_we_i(wb_we),
      .wb_ack_o(wb_ack3[1]),
      .wb_err_o(wb_err3[1]),
      .wb_int_o(),

      .pad_cs_o(fmc2_spi_ad9510_cs),
      .pad_sclk_o(fmc2_spi_ad9510_sclk_o),
      .pad_mosi_o(fmc2_spi_ad9510_mosi_o),
      .pad_mosi_i(),
      .pad_mosi_en(),
      .pad_miso_i(fmc2_spi_ad9510_miso_i)
  );

// =====================================
//               24AA64T-I
// =====================================
//                 I2C
// =====================================
// Address: 0x40000
// =====================================
i2c_master_top wb_fmc2_i2c_master_i_eeprom (
      .wb_clk_i(wb_clk),
      .wb_rst_i(wb_rst),
      .arst_i(),
      .wb_adr_i(wb_adr),
      .wb_dat_i(wb_data_in),
      .wb_dat_o(wb_data_out4[1]),
      .wb_we_i(wb_we),
      .wb_stb_i(wb_stb4[1]),
      //.wb_sel_i(wb_sel),
      .wb_cyc_i(wb_cyc),
      .wb_ack_o(wb_ack4[1]),
      //.wb_int_o(),

      .scl_pad_i(fmc2_eeprom_scl_in),
      .scl_pad_o(fmc2_eeprom_scl_out),
      .scl_padoen_o(fmc2_eeprom_scl_oe_n),
      .sda_pad_i(fmc2_eeprom_sda_in),
      .sda_pad_o(fmc2_eeprom_sda_out),
      .sda_padoen_o(fmc2_eeprom_sda_oe_n)
      );

assign fmc2_eeprom_scl_pad = fmc2_eeprom_scl_oe_n ? 1'bz : fmc2_eeprom_scl_out;
assign fmc2_eeprom_scl_in = fmc2_eeprom_scl_pad;

assign fmc2_eeprom_sda_pad = fmc2_eeprom_sda_oe_n ? 1'bz : fmc2_eeprom_sda_out;
assign fmc2_eeprom_sda_in = fmc2_eeprom_sda_pad;

// =====================================
//               AMC7823
// =====================================
//                 SPI
// =====================================
// Address: 0x50000
// =====================================
wb_spi_bidir wb_fmc2_spi_bidir_i_amc7823 (
      .clk_sys_i(wb_clk),
      .rst_n_i  (wb_rst),

      .wb_adr_i(wb_adr),
      .wb_dat_i(wb_data_in),
      .wb_dat_o(wb_data_out5[1]),
      .wb_sel_i(wb_sel),
      .wb_stb_i(wb_stb5[1]),
      .wb_cyc_i(wb_cyc),
      .wb_we_i(wb_we),
      .wb_ack_o(wb_ack5[1]),
      .wb_err_o(wb_err5[1]),
      .wb_int_o(),

      .pad_cs_o(fmc2_spi_amc7823_cs),
      .pad_sclk_o(fmc2_spi_amc7823_sclk_o),
      .pad_mosi_o(fmc2_spi_amc7823_mosi_o),
      .pad_mosi_i(),
      .pad_mosi_en(),
      .pad_miso_i(fmc2_spi_amc7823_miso_i)
      );

// =====================================
//               TRIGGER
// =====================================
// Trigger data output (if in output mode)
IBUFDS #(
      .DIFF_TERM("FALSE"),       // Differential Termination
      .IBUF_LOW_PWR("FALSE"),     // Low power="TRUE", Highest performance="FALSE"
      .IOSTANDARD("LVDS_25")     // Specify the input I/O standard
   ) IBUFDS_fmc2_inst (
      .O(fmc2_trig_val_i),  // Buffer output
      .I(fmc2_trig_val_o_p),  // Diff_p buffer input (connect directly to top-level port)
      .IB(fmc2_trig_val_o_n) // Diff_n buffer input (connect directly to top-level port)
   );

//IOBUFDS #(
//      .DIFF_TERM("FALSE"),    // Differential Termination ("TRUE"/"FALSE")
//      .IBUF_LOW_PWR("FALSE"),  // Low Power - "TRUE", High Performance = "FALSE"
//      .IOSTANDARD("BLVDS_25") // Specify the I/O standard
//   ) IOBUFDS_fmc2_trig (
//      .O(fmc2_trig_val_i),     // Buffer output  // for further use!!!
//      .IO(fmc2_trig_val_o_p),   // Diff_p inout (connect directly to top-level port)
//      .IOB(fmc2_trig_val_o_n), // Diff_n inout (connect directly to top-level port)
//      .I(fmc2_trig_val_o_reg), // Buffer input
//      .T(fmc2_trig_dir_o)      // 3-state enable input, high=input, low=output
//   );

OBUFDS #(
      //.IOSTANDARD("DIFF_HSTL_II_DCI_18") // Specify the output I/O standard
                .IOSTANDARD("LVDS_25") // Specify the output I/O standard
                //.IOSTANDARD("LVDS") // Specify the output I/O standard 1.8V
   ) OBUFDS_fmc2_adc_rst (
      .O(fmc2_adc_clkdivrst_o_p),     // Diff_p output (connect directly to top-level port)
      .OB(fmc2_adc_clkdivrst_o_n),   // Diff_n output (connect directly to top-level port)
      .I(fmc2_adc_clkdivrst_o)      // Buffer input
   );

wire [1:0]fmc2_adc_sleep_w;
assign fmc2_adc_sleep_o = fmc2_adc_sleep_w[1] ? 1'bz : (fmc2_adc_sleep_w[0] ? 1'b1 : 1'b0);

wb_fmc_250m_4ch_csr wb_fmc2_250m_4ch_csr_i (
    .rst_n_i(!wb_rst),
    .wb_clk_i(wb_clk),
    .wb_addr_i(wb_adr),
    .wb_data_i(wb_data_in),
    .wb_data_o(wb_data_out6[1]),
    .wb_cyc_i(wb_cyc),
    .wb_sel_i(wb_sel),
    .wb_stb_i(wb_stb6[1]),
    .wb_we_i(wb_we),
    .wb_ack_o(wb_ack6[1]),

    // General FMC status
    .wb_fmc_250m_4ch_csr_fmc_status_prsnt_i(fmc2_prsnt_i),
    .wb_fmc_250m_4ch_csr_fmc_status_pg_m2c_i(fmc2_pg_m2c_i),
    .wb_fmc_250m_4ch_csr_fmc_status_clk_dir_i(1'b0), // not supported on Kintex7 KC705 board
    .wb_fmc_250m_4ch_csr_fmc_status_firmware_id_i(32'h01332A11),
    // Trigger config
    .wb_fmc_250m_4ch_csr_trigger_dir_o(fmc2_trig_dir_o),
    .wb_fmc_250m_4ch_csr_trigger_term_o(fmc2_trig_term_o),
    .wb_fmc_250m_4ch_csr_trigger_trig_val_o(fmc2_trig_val_o_reg),
    .wb_fmc_250m_4ch_csr_trigger_reserved_i(0),
    // ADC config
    .wb_fmc_250m_4ch_csr_adc_clkdivrst_o(fmc2_adc_clkdivrst_o),
    .wb_fmc_250m_4ch_csr_adc_resetn_o(fmc2_adc_resetn_o),
    .wb_fmc_250m_4ch_csr_adc_sleep_o(fmc2_adc_sleep_w),
    .wb_fmc_250m_4ch_csr_adc_reserved_i(0),
    // Clock distribution config
    .wb_fmc_250m_4ch_csr_clk_distrib_si571_oe_o(fmc2_si571_oe_o),
    .wb_fmc_250m_4ch_csr_clk_distrib_pll_function_o(fmc2_pll_function_o),
    .wb_fmc_250m_4ch_csr_clk_distrib_pll_status_i(fmc2_pll_status_i),
    .wb_fmc_250m_4ch_csr_clk_distrib_clk_sel_o(fmc2_clk_sel_o),
    .wb_fmc_250m_4ch_csr_clk_distrib_reserved_i(0),
    // Monitoring and FMC status
    .wb_fmc_250m_4ch_csr_monitor_mon_dev_i(fmc2_mon_dev_i),
    .wb_fmc_250m_4ch_csr_monitor_led1_o(fmc2_led1_o_w),
    .wb_fmc_250m_4ch_csr_monitor_led2_o(fmc2_led2_o_w),
    .wb_fmc_250m_4ch_csr_monitor_led3_o(fmc2_led3_o_w),
    .wb_fmc_250m_4ch_csr_monitor_reserved_i(0),
    // FPGA control
    .wb_fmc_250m_4ch_csr_fpga_ctrl_fmc_idelay_rst_o(fmc2_reg_rst),
    .wb_fmc_250m_4ch_csr_fpga_ctrl_fmc_fifo_rst_o(),
    .wb_fmc_250m_4ch_csr_fpga_ctrl_fmc_idelay0_rdy_i(fmc2_idelay_rdy[0]),
    .wb_fmc_250m_4ch_csr_fpga_ctrl_fmc_idelay1_rdy_i(fmc2_idelay_rdy[1]),
    .wb_fmc_250m_4ch_csr_fpga_ctrl_fmc_idelay2_rdy_i(fmc2_idelay_rdy[2]),
    .wb_fmc_250m_4ch_csr_fpga_ctrl_fmc_idelay3_rdy_i(fmc2_idelay_rdy[3]),
    .wb_fmc_250m_4ch_csr_fpga_ctrl_reserved_i(0),

    // IDELAY lines control
    .wb_fmc_250m_4ch_csr_idelay0_cal_update_o(fmc2_idelay0_load),
    .wb_fmc_250m_4ch_csr_idelay0_cal_line_o(fmc2_idelay0_select),
    .wb_fmc_250m_4ch_csr_idelay0_cal_val_o(fmc2_idelay0_val),
    .wb_fmc_250m_4ch_csr_idelay0_cal_val_read_i(fmc2_idelay0_read),
    .wb_fmc_250m_4ch_csr_idelay0_cal_reserved_i(0),

    .wb_fmc_250m_4ch_csr_idelay1_cal_update_o(fmc2_idelay1_load),
    .wb_fmc_250m_4ch_csr_idelay1_cal_line_o(fmc2_idelay1_select),
    .wb_fmc_250m_4ch_csr_idelay1_cal_val_o(fmc2_idelay1_val),
    .wb_fmc_250m_4ch_csr_idelay1_cal_val_read_i(fmc2_idelay1_read),
    .wb_fmc_250m_4ch_csr_idelay1_cal_reserved_i(0),

    .wb_fmc_250m_4ch_csr_idelay2_cal_update_o(fmc2_idelay2_load),
    .wb_fmc_250m_4ch_csr_idelay2_cal_line_o(fmc2_idelay2_select),
    .wb_fmc_250m_4ch_csr_idelay2_cal_val_o(fmc2_idelay2_val),
    .wb_fmc_250m_4ch_csr_idelay2_cal_val_read_i(fmc2_idelay2_read),
    .wb_fmc_250m_4ch_csr_idelay2_cal_reserved_i(0),

    .wb_fmc_250m_4ch_csr_idelay3_cal_update_o(fmc2_idelay3_load),
    .wb_fmc_250m_4ch_csr_idelay3_cal_line_o(fmc2_idelay3_select),
    .wb_fmc_250m_4ch_csr_idelay3_cal_val_o(fmc2_idelay3_val),
    .wb_fmc_250m_4ch_csr_idelay3_cal_val_read_i(fmc2_idelay3_read),
    .wb_fmc_250m_4ch_csr_idelay3_cal_reserved_i(0),

    .wb_fmc_250m_4ch_csr_data0_val_i(fmc2_w_data[31:0]),
    .wb_fmc_250m_4ch_csr_data1_val_i(fmc2_w_data[63:32]),
    .wb_fmc_250m_4ch_csr_data2_val_i(fmc2_w_data[95:64]),
    .wb_fmc_250m_4ch_csr_data3_val_i(fmc2_w_data[127:96])

  );

assign fmc2_led1_o = fmc2_led1_o_w || fmc2_trig_val_i; // trigger tests (input), blinking LED (1kHz, TTL)
assign fmc2_led2_o = fmc2_led2_o_w;
assign fmc2_led3_o = fmc2_led3_o_w;

//assign board_led1_o = fmc2_led1_o_w;
//assign board_led2_o = fmc2_led2_o_w;
//assign board_led3_o = fmc2_led3_o_w;

addr_decode i_addr_decode(
        .addr_in(wb_adr[31:16]),
        .data_out(wb_data_out),
        //FMC1
        .acmp1(wb_acmp1[0]),
        .data_out1(wb_data_out1[0]),
        .acmp2(wb_acmp2[0]),
        .data_out2(wb_data_out2[0]),
        .acmp3(wb_acmp3[0]),
        .data_out3(wb_data_out3[0]),
        .acmp4(wb_acmp4[0]),
        .data_out4(wb_data_out4[0]),
        .acmp5(wb_acmp5[0]),
        .data_out5(wb_data_out5[0]),
        .acmp6(wb_acmp6[0]),
        .data_out6(wb_data_out6[0]),
        //FMC2
        .acmp7(wb_acmp1[1]),
        .data_out7(wb_data_out1[1]),
        .acmp8(wb_acmp2[1]),
        .data_out8(wb_data_out2[1]),
        .acmp9(wb_acmp3[1]),
        .data_out9(wb_data_out3[1]),
        .acmp10(wb_acmp4[1]),
        .data_out10(wb_data_out4[1]),
        .acmp11(wb_acmp5[1]),
        .data_out11(wb_data_out5[1]),
        .acmp12(wb_acmp6[1]),
        .data_out12(wb_data_out6[1])
);

// Clock source = 125 MHz
// Wishbone clock running at 100MHz
// Ref clock for IDELAY block running at 200MHz -> 78ps taps
wb_clk wb_clk_i
 (// Clock in ports
  .CLK_IN1_P(sys_clk_i_p),
  .CLK_IN1_N(sys_clk_i_n),
  // Clock out ports
  .CLK_OUT1(wb_clk),
  .CLK_OUT2(ref_clk),
  // Status and control signals
  .RESET(1'b0),
  .LOCKED()
 );

/*
wb_clk wb_clk_i
 (// Clock in ports
  .CLK_IN1_P(sys_clk_i_p),
  .CLK_IN1_N(sys_clk_i_n),
  // Clock out ports
  .CLK_OUT1(wb_clk),
  .CLK_OUT2(ref_clk),
  .CLK_OUT3(chipscope_clk),
  // Status and control signals
  .RESET(1'b0),
  .LOCKED()
 );
*/

rs232_syscon_top_1_0 i_rs232_syscon_top_1_0 (
        .rs232_rxd_i(rs232_rxd_i),
        .rs232_txd_o(rs232_txd_o),
        .clk_i(wb_clk),
        .reset_i(1'b0),
        .rst_o(wb_rst),
        .cyc_o(wb_cyc),
        .adr_o(wb_adr),
        .data_in(wb_data_out),
        .we_o(wb_we),
        .stb_o(wb_stb),
        .data_out(wb_data_in),
        .ack_i(wb_ack),
        .err_i(wb_err),
        .sel_o(wb_sel)
);


//wire [35:0]ctrl0;
//wire [17:0]trig0;
//
//assign trig0[3:0] = spi_adc_cs;
//assign trig0[4] = spi_adc_sclk_o;
//assign trig0[5] = spi_adc_mosi_o;
//assign trig0[6] = spi_adc_miso_i;
//assign trig0[7] = si571_scl_in;
//assign trig0[8] = si571_scl_out;
//assign trig0[9] = si571_scl_oe_n;
//assign trig0[10] = si571_sda_in;
//assign trig0[11] = si571_sda_out;
//assign trig0[12] = si571_sda_oe_n;
//assign trig0[13] = spi_ad9510_cs;
//assign trig0[14] = spi_ad9510_sclk_o;
//assign trig0[15] = spi_ad9510_mosi_o;
//assign trig0[16] = spi_ad9510_miso_i;
//assign trig0[17] = spi_amc7823_cs;
//assign trig0[18] = spi_amc7823_sclk_o;
//assign trig0[19] = spi_amc7823_mosi_o;
//assign trig0[20] = spi_amc7823_miso_i;
//
//chipscope_icon icon_i (
//    .CONTROL0(ctrl0) // INOUT BUS [35:0]
//       //.CONTROL1(), // INOUT BUS [35:0]
//       //.CONTROL2(), // INOUT BUS [35:0]
//       //.CONTROL3() // INOUT BUS [35:0]
//
//);
//
//chipscope_ila_fifo sys_ila (
//    .CONTROL(ctrl0), // INOUT BUS [35:0]
//    .CLK(chipscope_clk), // IN
//    .TRIG0(trig0) // IN BUS [127:0]
//);

chipscope_icon_8_port chipscope_icon_8_port_i (
    .CONTROL0(icon_ctrl0), // INOUT BUS [35:0]
    .CONTROL1(icon_ctrl1), // INOUT BUS [35:0]
    .CONTROL2(icon_ctrl2), // INOUT BUS [35:0]
    .CONTROL3(icon_ctrl3), // INOUT BUS [35:0]
    .CONTROL4(icon_ctrl4), // INOUT BUS [35:0]
    .CONTROL5(icon_ctrl5), // INOUT BUS [35:0]
    .CONTROL6(icon_ctrl6), // INOUT BUS [35:0]
    .CONTROL7(icon_ctrl7) // INOUT BUS [35:0]
);


endmodule
