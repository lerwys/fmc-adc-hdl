`timescale 1ns / 1ps
// Author: Andrzej Wojenski
// Modifications for ML605 port: Lucas Russo <lucas.russo@lnls.br>
//
// Module:  virtex6_fmc_adc_130m_4ch
// Version: 1.0
//
// Description: Firmware for FMC ADC 130M 4CH (PASSIVE and ACTIVE)
//              Codes for Xilinx ML605 devkit
//              Includes:
//              -- configuration communication interfaces (like I2C)
//              -- data interfaces (like ADC LTC2208)
//              -- data acquisition with Chipscope blocks
//              Allows:
//              - configure whole FMC card
//              - do simple ADC measurements with Chipscope
//
//  Note: If using this firmware with Artix7 FPGA check tap resolution (IDELAY lines)
module virtex6_fmc_adc_130m_4ch_adc_test(

    // Clock
    input sys_clk_i_p,
    input sys_clk_i_n,

    // ADC LTC2208 interface
    output fmc_adc_pga_o,
    output fmc_adc_shdn_o,
    output fmc_adc_dith_o,
    output fmc_adc_rand_o,

    // ADC0 LTC2208
    input fmc_adc0_clk,
    input [15:0]fmc_adc0_data,
    input fmc_adc0_of,

    // ADC1 LTC2208
    input fmc_adc1_clk,
    input [15:0]fmc_adc1_data,
    input fmc_adc1_of,

    // ADC2 LTC2208
    input fmc_adc2_clk,
    input [15:0]fmc_adc2_data,
    input fmc_adc2_of,

    // ADC3 LTC2208
    input fmc_adc3_clk,
    input [15:0]fmc_adc3_data,
    input fmc_adc3_of,

    // FMC
    input fmc_prsnt_i,
    input fmc_pg_m2c_i,
    //input fmc_clk_dir_i, - not supported on Kintex7 KC705 board

    // Trigger
    output fmc_trig_dir_o,
    output fmc_trig_term_o,
    inout fmc_trig_val_o_p,
    inout fmc_trig_val_o_n,

    // Si571 clock gen
    inout si571_scl_pad,
    inout si571_sda_pad,
    output fmc_si571_oe_o,

    // AD9510 clock distribution PLL
    output spi_ad9510_cs,
    output spi_ad9510_sclk_o,
    output spi_ad9510_mosi_o,
    input spi_ad9510_miso_i,

    output fmc_pll_function_o,
    input fmc_pll_status_i,
    // fmc_pll_status_i loopback for debug
    output fmc_pll_status_o,

    // AD9510 clock copy
    input fmc_fpga_clk_p,
    input fmc_fpga_clk_n,

    // Clock reference selection (TS3USB221)
    output fmc_clk_sel_o,

    // EEPROM
    inout eeprom_scl_pad,
    inout eeprom_sda_pad,

    // Temperature monitor
    // LM75AIMM
    inout lm75_scl_pad,
    inout lm75_sda_pad,

    input fmc_lm75_temp_alarm_i,

    // LEDs
    output fmc_led1_o,
    output fmc_led2_o,
    output fmc_led3_o,

    // LEDs on Virtex ML605 board
    output board_led1_o,
    output board_led2_o,
    output board_led3_o,

    // MMCM led Virtex ML605 board
    output mmcm_led_o,

    // Uncross signals
    output clk_swap_o,

    // Wishbone master  - RS232
    input rs232_rxd_i,
    output rs232_txd_o
    );

localparam FPGA_DEVICE = "VIRTEX6";
localparam REF_ADC_CLK = 0;
localparam REF_ADC_CLK_FREQ = 8.882;  //476.066*35/148 aprox 112.5831 MHz
localparam ASYNC_FIFO_SIZE = 16;
localparam NUM_ADC_BITS = 16; //16bits
localparam NUM_ADC_CHAN = 4;

localparam DSP_REF_NUM_BITS = 24;
localparam DSP_POS_NUM_BITS = 26;

wire [31:0] wb_adr;
wire [31:0] wb_data_in, wb_data_out;
wire [3:0]wb_sel;

wire wb_stb1;
wire wb_err1;
wire wb_ack1;
wire [31:0]wb_data_out1;

wire wb_stb2;
wire wb_err2;
wire wb_ack2;
wire [31:0]wb_data_out2;

wire wb_stb3;
wire wb_err3;
wire wb_ack3;
wire [31:0]wb_data_out3;

wire wb_stb4;
wire wb_err4;
wire wb_ack4;
wire [31:0]wb_data_out4;

wire wb_stb5;
wire wb_err5;
wire wb_ack5;
wire [31:0]wb_data_out5;

wire wb_stb6;
wire wb_err6;
wire wb_ack6;
wire [31:0]wb_data_out6;

wire rst_n;

assign wb_ack = wb_ack1 || wb_ack2 || wb_ack3 || wb_ack4 || wb_ack5;

assign wb_stb1 = wb_cyc && wb_stb && wb_acmp1;
assign wb_stb2 = wb_cyc && wb_stb && wb_acmp2;
assign wb_stb3 = wb_cyc && wb_stb && wb_acmp3;
assign wb_stb4 = wb_cyc && wb_stb && wb_acmp4;
assign wb_stb5 = wb_cyc && wb_stb && wb_acmp5;

assign wb_err = wb_err1 || wb_err2 || wb_err3 || wb_err4 || wb_err5;

wire [3:0]idelay_rdy;
wire [4:0]idelay0_val;
wire [4:0]idelay1_val;
wire [4:0]idelay2_val;
wire [4:0]idelay3_val;
wire [4:0]idelay0_read;
wire [4:0]idelay1_read;
wire [4:0]idelay2_read;
wire [4:0]idelay3_read;
wire [16:0]idelay0_select;
wire [16:0]idelay1_select;
wire [16:0]idelay2_select;
wire [16:0]idelay3_select;

wire [127:0]w_data;

wire adc_ref_clk;
wire adc_ref_clk_w;
wire adc_ref_clk2x;
wire adc_ref_clk2x_w;

wire [NUM_ADC_BITS-1:0] fmc_adc0_data_sync;
wire [NUM_ADC_BITS-1:0] fmc_adc1_data_sync;
wire [NUM_ADC_BITS-1:0] fmc_adc2_data_sync;
wire [NUM_ADC_BITS-1:0] fmc_adc3_data_sync;

reg [NUM_ADC_BITS*NUM_ADC_CHAN-1:0] adc_data;

wire adc_clk [NUM_ADC_CHAN-1:0];

wire fmc_adc0_clk_out;
wire fmc_adc1_clk_out;
wire fmc_adc2_clk_out;
wire fmc_adc3_clk_out;

wire [NUM_ADC_BITS-1:0] fmc_adc0_data_out;
wire [NUM_ADC_BITS-1:0] fmc_adc1_data_out;
wire [NUM_ADC_BITS-1:0] fmc_adc2_data_out;
wire [NUM_ADC_BITS-1:0] fmc_adc3_data_out;

//MMCM signals
wire mmcm_locked;

// Chipscope control signals
wire [35:0] CONTROL0;
//wire [35:0] CONTROL1;
//wire [35:0] CONTROL2;
//wire [35:0] CONTROL3;

// Chipscope ILA 0 signals
wire [7:0] TRIG_ILA0_0;
wire [15:0] TRIG_ILA0_1;
wire [15:0] TRIG_ILA0_2;
wire [15:0] TRIG_ILA0_3;
wire [15:0] TRIG_ILA0_4;

//// Chipscope ILA 1 signals
//wire [7:0] TRIG_ILA1_0;
//wire [31:0] TRIG_ILA1_1;
//wire [31:0] TRIG_ILA1_2;
//wire [31:0] TRIG_ILA1_3;
//wire [31:0] TRIG_ILA1_4;
//
//// Chipscope ILA 2 signals
//wire [7:0] TRIG_ILA2_0;
//wire [31:0] TRIG_ILA2_1;
//wire [31:0] TRIG_ILA2_2;
//wire [31:0] TRIG_ILA2_3;
//wire [31:0] TRIG_ILA2_4;
//
//// Chipscope ILA 3 signals
//wire [7:0] TRIG_ILA3_0;
//wire [31:0] TRIG_ILA3_1;
//wire [31:0] TRIG_ILA3_2;
//wire [31:0] TRIG_ILA3_3;
//wire [31:0] TRIG_ILA3_4;

fmc_adc_130m_4ch #(
        .FPGA_DEVICE(FPGA_DEVICE),
        .USE_CHIPSCOPE_ICON(0),
        .USE_CHIPSCOPE_ILA(0)
    ) fmc_adc_130m_4ch_i (
        .sys_clk(wb_clk),
        .ref_clk(ref_clk),
        .rst(wb_rst || reg_rst),
        .trigger(),

        .fmc_fpga_clk_p(fmc_fpga_clk_p),
        .fmc_fpga_clk_n(fmc_fpga_clk_n),

        .adc0_clk(fmc_adc0_clk),
        .adc0_clk_out(fmc_adc0_clk_out),
        .adc0_data_in(fmc_adc0_data),
        .adc0_data_out(fmc_adc0_data_out),
        .adc0_ov(fmc_adc0_of),

        .adc1_clk(fmc_adc1_clk),
        .adc1_clk_out(fmc_adc1_clk_out),
        .adc1_data_in(fmc_adc1_data),
        .adc1_data_out(fmc_adc1_data_out),
        .adc1_ov(fmc_adc1_of),

        .adc2_clk(fmc_adc2_clk),
        .adc2_clk_out(fmc_adc2_clk_out),
        .adc2_data_in(fmc_adc2_data),
        .adc2_data_out(fmc_adc2_data_out),
        .adc2_ov(fmc_adc2_of),

        .adc3_clk(fmc_adc3_clk),
        .adc3_clk_out(fmc_adc3_clk_out),
        .adc3_data_in(fmc_adc3_data),
        .adc3_data_out(fmc_adc3_data_out),
        .adc3_ov(fmc_adc3_of),

        .adc0_delay_reg(idelay0_val),
        .adc0_delay_reg_read(idelay0_read),
        .adc0_delay_load(idelay0_load),
        .adc0_delay_select(idelay0_select),
        .adc0_delay_rdy(idelay_rdy[0]),

        .adc1_delay_reg(idelay1_val),
        .adc1_delay_reg_read(idelay1_read),
        .adc1_delay_load(idelay1_load),
        .adc1_delay_select(idelay1_select),
        .adc1_delay_rdy(idelay_rdy[1]),

        .adc2_delay_reg(idelay2_val),
        .adc2_delay_reg_read(idelay2_read),
        .adc2_delay_load(idelay2_load),
        .adc2_delay_select(idelay2_select),
        .adc2_delay_rdy(idelay_rdy[2]),

        .adc3_delay_reg(idelay3_val),
        .adc3_delay_reg_read(idelay3_read),
        .adc3_delay_load(idelay3_load),
        .adc3_delay_select(idelay3_select),
        .adc3_delay_rdy(idelay_rdy[3]),

        .data(w_data)
);

assign adc_clk[0] = fmc_adc0_clk_out;
assign adc_clk[1] = fmc_adc1_clk_out;
assign adc_clk[2] = fmc_adc2_clk_out;
assign adc_clk[3] = fmc_adc3_clk_out;

//Synchronize all adc data to a single clock

MMCM_BASE #(
  .BANDWIDTH("OPTIMIZED"),   // Jitter programming ("HIGH","LOW","OPTIMIZED")
  .CLKFBOUT_MULT_F(8.0),     // Multiply value for all CLKOUT (5.0-64.0).
  .CLKFBOUT_PHASE(0.0),      // Phase offset in degrees of CLKFB (0.00-360.00).
  .CLKIN1_PERIOD(REF_ADC_CLK_FREQ),       // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
  .CLKOUT0_DIVIDE_F(8.0),    // Divide amount for CLKOUT0 (1.000-128.000).
  // CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
  .CLKOUT0_DUTY_CYCLE(0.5),
  .CLKOUT1_DUTY_CYCLE(0.5),
  // CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
  .CLKOUT0_PHASE(0.0),
  .CLKOUT1_PHASE(0.0),
  // CLKOUT1_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
  .CLKOUT1_DIVIDE(4),
  .CLOCK_HOLD("FALSE"),      // Hold VCO Frequency (TRUE/FALSE)
  .DIVCLK_DIVIDE(1),         // Master division value (1-80)
  .REF_JITTER1(0.01),         // Reference input jitter in UI (0.000-0.999).
  .STARTUP_WAIT("FALSE")     // Not supported. Must be set to FALSE.
 )
  MMCM_BASE_inst (
    // Clock Outputs: 1-bit (each) output: User configurable clock outputs
    .CLKOUT0(adc_ref_clk_w),     // 1-bit output: CLKOUT0 output
    .CLKOUT1(adc_ref_clk2x_w),     // 1-bit output: CLKOUT1 output
    // Feedback Clocks: 1-bit (each) output: Clock feedback ports
    .CLKFBOUT(adc_clk_fbout),   // 1-bit output: Feedback clock output
    // Status Port: 1-bit (each) output: MMCM status ports
    .LOCKED(mmcm_locked),       // 1-bit output: LOCK output
    // Clock Input: 1-bit (each) input: Clock input
    .CLKIN1(adc_clk[REF_ADC_CLK]),
    // Control Ports: 1-bit (each) input: MMCM control ports
    .PWRDWN(),       // 1-bit input: Power-down input
    .RST(wb_rst),             // 1-bit input: Reset input
    // Feedback Clocks: 1-bit (each) input: Clock feedback ports
    .CLKFBIN(adc_clk_fbin)      // 1-bit input: Feedback clock input
 );

 assign mmcm_led_o = mmcm_locked;

 BUFG BUFG_inst_fb (
  .O(adc_clk_fbin), // 1-bit output: Clock buffer output
  .I(adc_clk_fbout)  // 1-bit input: Clock buffer input
 );

 BUFG BUFG_inst_adc (
  .O(adc_ref_clk), // 1-bit output: Clock buffer output
  .I(adc_ref_clk_w)  // 1-bit input: Clock buffer input
 );

 BUFG BUFG_inst_adc2x (
  .O(adc_ref_clk2x), // 1-bit output: Clock buffer output
  .I(adc_ref_clk2x_w)  // 1-bit input: Clock buffer input
 );

// Async fifo for CDC
generic_async_fifo #( .g_data_width(NUM_ADC_BITS),
                      .g_size(ASYNC_FIFO_SIZE),
                      .g_almost_empty_threshold(2),
                      .g_almost_full_threshold(NUM_ADC_BITS-2)
                    ) generic_async_fifo_ch0_i
  (
    .rst_n_i     (!wb_rst),

    // write port()
    .clk_wr_i    (adc_clk[0]),
    .d_i         (fmc_adc0_data_out),
    .we_i        (1'b1),
    .wr_full_o   (),

    // read port ()
    .clk_rd_i    (adc_ref_clk),
    .q_o         (fmc_adc0_data_sync),
    .rd_i        (1'b1),
    .rd_empty_o  ()
  );

generic_async_fifo #( .g_data_width(NUM_ADC_BITS),
                      .g_size(ASYNC_FIFO_SIZE),
                      .g_almost_empty_threshold(2),
                      .g_almost_full_threshold(NUM_ADC_BITS-2)
                    ) generic_async_fifo_ch1_i
  (
    .rst_n_i     (!wb_rst),

    // write port()
    .clk_wr_i    (adc_clk[1]),
    .d_i         (fmc_adc1_data_out),
    .we_i        (1'b1),
    .wr_full_o   (),

    // read port ()
    .clk_rd_i    (adc_ref_clk),
    .q_o         (fmc_adc1_data_sync),
    .rd_i        (1'b1),
    .rd_empty_o  ()
  );

generic_async_fifo #( .g_data_width(NUM_ADC_BITS),
                      .g_size(ASYNC_FIFO_SIZE),
                      .g_almost_empty_threshold(2),
                      .g_almost_full_threshold(NUM_ADC_BITS-2)
                    ) generic_async_fifo_ch2_i
  (
    .rst_n_i     (!wb_rst),

    // write port()
    .clk_wr_i    (adc_clk[2]),
    .d_i         (fmc_adc2_data_out),
    .we_i        (1'b1),
    .wr_full_o   (),

    // read port ()
    .clk_rd_i    (adc_ref_clk),
    .q_o         (fmc_adc2_data_sync),
    .rd_i        (1'b1),
    .rd_empty_o  ()
  );

generic_async_fifo #( .g_data_width(NUM_ADC_BITS),
                      .g_size(ASYNC_FIFO_SIZE),
                      .g_almost_empty_threshold(2),
                      .g_almost_full_threshold(NUM_ADC_BITS-2)
                    ) generic_async_fifo_ch3_i
  (
    .rst_n_i     (!wb_rst),

    // write port()
    .clk_wr_i    (adc_clk[3]),
    .d_i         (fmc_adc3_data_out),
    .we_i        (1'b1),
    .wr_full_o   (),

    // read port ()
    .clk_rd_i    (adc_ref_clk),
    .q_o         (fmc_adc3_data_sync),
    .rd_i        (1'b1),
    .rd_empty_o  ()
  );

//always@(posedge adc_ref_clk)
//begin
//  if (rst == 1'b1)
//    adc_data <= 0;
//  else
//    adc_data <= {fmc_adc3_data_sync,fmc_adc2_data_sync,
//                  fmc_adc1_data_sync,fmc_adc0_data_sync};
//end

// =====================================
//              INTERFACES
// =====================================

// =====================================
//                Si571
// =====================================
//                 I2C
// =====================================
// Address: 0x10000
// =====================================
i2c_master_top wb_i2c_master_i_si571 (
      .wb_clk_i(wb_clk),
      .wb_rst_i(wb_rst),
      .arst_i(),
      .wb_adr_i(wb_adr),
      .wb_dat_i(wb_data_in),
      .wb_dat_o(wb_data_out1),
      .wb_we_i(wb_we),
      .wb_stb_i(wb_stb1),
      //.wb_sel_i(wb_sel),
      .wb_cyc_i(wb_cyc),
      .wb_ack_o(wb_ack1),
      //.wb_int_o(),

      .scl_pad_i(si571_scl_in),
      .scl_pad_o(si571_scl_out),
      .scl_padoen_o(si571_scl_oe_n),
      .sda_pad_i(si571_sda_in),
      .sda_pad_o(si571_sda_out),
      .sda_padoen_o(si571_sda_oe_n)
      );

assign si571_scl_pad = si571_scl_oe_n ? 1'bz : si571_scl_out;
assign si571_scl_in = si571_scl_pad;

assign si571_sda_pad = si571_sda_oe_n ? 1'bz : si571_sda_out;
assign si571_sda_in = si571_sda_pad;

// =====================================
//                AD9510
// =====================================
//                 SPI
// =====================================
// Address: 0x20000
// =====================================
spi_bidir_top wb_spi_bidir_i_ad9510 (
      .wb_clk_i(wb_clk),
      .wb_rst_i(wb_rst),

      .wb_adr_i(wb_adr),
      .wb_dat_i(wb_data_in),
      .wb_dat_o(wb_data_out2),
      .wb_sel_i(wb_sel),
      .wb_stb_i(wb_stb2),
      .wb_cyc_i(wb_cyc),
      .wb_we_i(wb_we),
      .wb_ack_o(wb_ack2),
      .wb_err_o(wb_err2),
      .wb_int_o(),

      .ss_pad_o(spi_ad9510_cs),
      .sclk_pad_o(spi_ad9510_sclk_o),
      .mosi_pad_o(spi_ad9510_mosi_o),
      .mosi_pad_i(),
      .mosi_out_en(),
      .miso_pad_i(spi_ad9510_miso_i)
      );

assign fmc_pll_status_o = fmc_pll_status_i;

// =====================================
//               24AA64T-I
// =====================================
//                 I2C
// =====================================
// Address: 0x30000
// =====================================
i2c_master_top wb_i2c_master_i_eeprom (
      .wb_clk_i(wb_clk),
      .wb_rst_i(wb_rst),
      .arst_i(),
      .wb_adr_i(wb_adr),
      .wb_dat_i(wb_data_in),
      .wb_dat_o(wb_data_out3),
      .wb_we_i(wb_we),
      .wb_stb_i(wb_stb3),
      //.wb_sel_i(wb_sel),
      .wb_cyc_i(wb_cyc),
      .wb_ack_o(wb_ack3),
      //.wb_int_o(),

      .scl_pad_i(eeprom_scl_in),
      .scl_pad_o(eeprom_scl_out),
      .scl_padoen_o(eeprom_scl_oe_n),
      .sda_pad_i(eeprom_sda_in),
      .sda_pad_o(eeprom_sda_out),
      .sda_padoen_o(eeprom_sda_oe_n)
      );

assign eeprom_scl_pad = eeprom_scl_oe_n ? 1'bz : eeprom_scl_out;
assign eeprom_scl_in = eeprom_scl_pad;

assign eeprom_sda_pad = eeprom_sda_oe_n ? 1'bz : eeprom_sda_out;
assign eeprom_sda_in = eeprom_sda_pad;

// =====================================
//               LM75AIMM
// =====================================
//                 I2C
// =====================================
// Address: 0x40000
// =====================================
i2c_master_top wb_i2c_master_i_lm75 (
      .wb_clk_i(wb_clk),
      .wb_rst_i(wb_rst),
      .arst_i(),
      .wb_adr_i(wb_adr),
      .wb_dat_i(wb_data_in),
      .wb_dat_o(wb_data_out4),
      .wb_we_i(wb_we),
      .wb_stb_i(wb_stb4),
      //.wb_sel_i(wb_sel),
      .wb_cyc_i(wb_cyc),
      .wb_ack_o(wb_ack4),
      //.wb_int_o(),

      .scl_pad_i(lm75_scl_in),
      .scl_pad_o(lm75_scl_out),
      .scl_padoen_o(lm75_scl_oe_n),
      .sda_pad_i(lm75_sda_in),
      .sda_pad_o(lm75_sda_out),
      .sda_padoen_o(lm75_sda_oe_n)
      );

assign lm75_scl_pad = lm75_scl_oe_n ? 1'bz : lm75_scl_out;
assign lm75_scl_in = lm75_scl_pad;

assign lm75_sda_pad = lm75_sda_oe_n ? 1'bz : lm75_sda_out;
assign lm75_sda_in = lm75_sda_pad;

// =====================================
//               TRIGGER
// =====================================
// Trigger data output (if in output mode)
IOBUFDS #(
      .DIFF_TERM("FALSE"),    // Differential Termination ("TRUE"/"FALSE")
      .IBUF_LOW_PWR("FALSE"),  // Low Power - "TRUE", High Performance = "FALSE"
      .IOSTANDARD("BLVDS_25") // Specify the I/O standard
   ) IOBUFDS_trig (
      .O(fmc_trig_val_i),     // Buffer output  // for further use!!!
      .IO(fmc_trig_val_o_p),   // Diff_p inout (connect directly to top-level port)
      .IOB(fmc_trig_val_o_n), // Diff_n inout (connect directly to top-level port)
      .I(fmc_trig_val_o_reg), // Buffer input
      .T(fmc_trig_dir_o)      // 3-state enable input, high=input, low=output
   );

wb_fmc_130m_4ch_csr wb_fmc_130m_4ch_csr_i (
    .rst_n_i(!wb_rst),
    .wb_clk_i(wb_clk),
    .wb_addr_i(wb_adr),
    .wb_data_i(wb_data_in),
    .wb_data_o(wb_data_out5),
    .wb_cyc_i(wb_cyc),
    .wb_sel_i(wb_sel),
    .wb_stb_i(wb_stb5),
    .wb_we_i(wb_we),
    .wb_ack_o(wb_ack5),

    // General FMC status
    .wb_fmc_130m_4ch_csr_fmc_status_prsnt_i(fmc_prsnt_i),
    .wb_fmc_130m_4ch_csr_fmc_status_pg_m2c_i(fmc_pg_m2c_i),
    .wb_fmc_130m_4ch_csr_fmc_status_clk_dir_i(1'b0), // not supported on Kintex7 KC705 board
    .wb_fmc_130m_4ch_csr_fmc_status_firmware_id_i(32'h01332A11),
    // Trigger config
    .wb_fmc_130m_4ch_csr_trigger_dir_o(fmc_trig_dir_o),
    .wb_fmc_130m_4ch_csr_trigger_term_o(fmc_trig_term_o),
    .wb_fmc_130m_4ch_csr_trigger_trig_val_o(fmc_trig_val_o_reg),
    .wb_fmc_130m_4ch_csr_trigger_reserved_i(0),

     // ADC config
    .wb_fmc_130m_4ch_csr_adc_rand_o(fmc_adc_rand_o),
    .wb_fmc_130m_4ch_csr_adc_dith_o(fmc_adc_dith_o),
    .wb_fmc_130m_4ch_csr_adc_shdn_o(fmc_adc_shdn_o),
    .wb_fmc_130m_4ch_csr_adc_pga_o(fmc_adc_pga_o),
    .wb_fmc_130m_4ch_csr_adc_reserved_i(0),
    // Clock distribution config
    .wb_fmc_130m_4ch_csr_clk_distrib_si571_oe_o(fmc_si571_oe_o),
    .wb_fmc_130m_4ch_csr_clk_distrib_pll_function_o(fmc_pll_function_o),
    .wb_fmc_130m_4ch_csr_clk_distrib_pll_status_i(fmc_pll_status_i),
    .wb_fmc_130m_4ch_csr_clk_distrib_clk_sel_o(fmc_clk_sel_o),
    .wb_fmc_130m_4ch_csr_clk_distrib_reserved_i(0),
    // Monitoring and FMC status
    .wb_fmc_130m_4ch_csr_monitor_temp_alarm_i(fmc_lm75_temp_alarm_i),
    .wb_fmc_130m_4ch_csr_monitor_led1_o(fmc_led1_o_w),
    .wb_fmc_130m_4ch_csr_monitor_led2_o(fmc_led2_o_w),
    .wb_fmc_130m_4ch_csr_monitor_led3_o(fmc_led3_o_w),
    .wb_fmc_130m_4ch_csr_monitor_reserved_i(0),
    // FPGA control
    .wb_fmc_130m_4ch_csr_fpga_ctrl_fmc_idelay_rst_o(reg_rst),
    .wb_fmc_130m_4ch_csr_fpga_ctrl_fmc_fifo_rst_o(),
    .wb_fmc_130m_4ch_csr_fpga_ctrl_fmc_idelay0_rdy_i(idelay_rdy[0]),
    .wb_fmc_130m_4ch_csr_fpga_ctrl_fmc_idelay1_rdy_i(idelay_rdy[1]),
    .wb_fmc_130m_4ch_csr_fpga_ctrl_fmc_idelay2_rdy_i(idelay_rdy[2]),
    .wb_fmc_130m_4ch_csr_fpga_ctrl_fmc_idelay3_rdy_i(idelay_rdy[3]),
    .wb_fmc_130m_4ch_csr_fpga_ctrl_reserved_i(0),

    // IDELAY lines control
    .wb_fmc_130m_4ch_csr_idelay0_cal_update_o(idelay0_load),
    .wb_fmc_130m_4ch_csr_idelay0_cal_line_o(idelay0_select),
    .wb_fmc_130m_4ch_csr_idelay0_cal_val_o(idelay0_val),
    .wb_fmc_130m_4ch_csr_idelay0_cal_val_read_i(idelay0_read),
    .wb_fmc_130m_4ch_csr_idelay0_cal_reserved_i(0),

    .wb_fmc_130m_4ch_csr_idelay1_cal_update_o(idelay1_load),
    .wb_fmc_130m_4ch_csr_idelay1_cal_line_o(idelay1_select),
    .wb_fmc_130m_4ch_csr_idelay1_cal_val_o(idelay1_val),
    .wb_fmc_130m_4ch_csr_idelay1_cal_val_read_i(idelay1_read),
    .wb_fmc_130m_4ch_csr_idelay1_cal_reserved_i(0),

    .wb_fmc_130m_4ch_csr_idelay2_cal_update_o(idelay2_load),
    .wb_fmc_130m_4ch_csr_idelay2_cal_line_o(idelay2_select),
    .wb_fmc_130m_4ch_csr_idelay2_cal_val_o(idelay2_val),
    .wb_fmc_130m_4ch_csr_idelay2_cal_val_read_i(idelay2_read),
    .wb_fmc_130m_4ch_csr_idelay2_cal_reserved_i(0),

    .wb_fmc_130m_4ch_csr_idelay3_cal_update_o(idelay3_load),
    .wb_fmc_130m_4ch_csr_idelay3_cal_line_o(idelay3_select),
    .wb_fmc_130m_4ch_csr_idelay3_cal_val_o(idelay3_val),
    .wb_fmc_130m_4ch_csr_idelay3_cal_val_read_i(idelay3_read),
    .wb_fmc_130m_4ch_csr_idelay3_cal_reserved_i(0),

    .wb_fmc_130m_4ch_csr_data0_val_i(w_data[31:0]),
    .wb_fmc_130m_4ch_csr_data1_val_i(w_data[63:32]),
    .wb_fmc_130m_4ch_csr_data2_val_i(w_data[95:64]),
    .wb_fmc_130m_4ch_csr_data3_val_i(w_data[127:96]),

    .wb_fmc_130m_4ch_csr_dcm_adc_en_o(adc_change_reg),
    .wb_fmc_130m_4ch_csr_dcm_adc_phase_o(adc_phase_reg),
    .wb_fmc_130m_4ch_csr_dcm_adc_done_i(adc_done_reg),
    .wb_fmc_130m_4ch_csr_dcm_adc_status0_i(0),
    .wb_fmc_130m_4ch_csr_dcm_adc_reset_o(adc_rst_reg),
    .wb_fmc_130m_4ch_csr_dcm_reserved_i(0)
  );

assign fmc_led1_o = fmc_led1_o_w || fmc_trig_val_i; // for trigger test (TTL, 1kHz)
assign fmc_led2_o = fmc_led2_o_w;
assign fmc_led3_o = fmc_led3_o_w;

assign board_led1_o = fmc_led1_o_w;
assign board_led2_o = fmc_led2_o_w;
assign board_led3_o = fmc_led3_o_w;

addr_decode i_addr_decode(
        .addr_in(wb_adr[31:16]),
        .data_out(wb_data_out),
        .acmp1(wb_acmp1),
        .data_out1(wb_data_out1),
        .acmp2(wb_acmp2),
        .data_out2(wb_data_out2),
        .acmp3(wb_acmp3),
        .data_out3(wb_data_out3),
        .acmp4(wb_acmp4),
        .data_out4(wb_data_out4),
        .acmp5(wb_acmp5),
        .data_out5(wb_data_out5)
);

// Clock source, Si chip, 200MHz (KC705 board)
// Wishbone clock running at 100MHz
// Ref clock for IDELAY block running at 200MHz -> 78ps taps
// update this core to newer version (ISE)
wb_clk wb_clk_i
 (// Clock in ports
  .CLK_IN1_P(sys_clk_i_p),
  .CLK_IN1_N(sys_clk_i_n),
  // Clock out ports
  .CLK_OUT1(wb_clk),
  .CLK_OUT2(ref_clk),
  //.CLK_OUT3(chipscope_clk),
  // Status and control signals
  .RESET(1'b0),
  .LOCKED()
 );

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

// Chipscope Analysis
chipscope_icon_1_port cmp_chipscope_icon_1_port_i (
   .CONTROL0                               (CONTROL0)
);

chipscope_ila_131072 cmp_chipscope_ila_131072_0_adc_i (
    .CONTROL                               (CONTROL0),
    .CLK                                   (adc_ref_clk),
    .TRIG0                                 (TRIG_ILA0_0),
    .TRIG1                                 (TRIG_ILA0_1),
    .TRIG2                                 (TRIG_ILA0_2),
    .TRIG3                                 (TRIG_ILA0_3),
    .TRIG4                                 (TRIG_ILA0_4)
  );

assign TRIG_ILA0_0[0]                       = 0;
assign TRIG_ILA0_0[1]                       = 0;
assign TRIG_ILA0_0[2]                       = 0;
assign TRIG_ILA0_0[3]                       = 0;
assign TRIG_ILA0_0[4]                       = 0;
assign TRIG_ILA0_0[5]                       = 0;
assign TRIG_ILA0_0[6]                       = 0;
assign TRIG_ILA0_0[7]                       = 0;

// ADC Data
assign TRIG_ILA0_1                          = fmc_adc0_data_sync;
assign TRIG_ILA0_2                          = fmc_adc1_data_sync;
assign TRIG_ILA0_3                          = fmc_adc2_data_sync;
assign TRIG_ILA0_4                          = fmc_adc3_data_sync;

endmodule
