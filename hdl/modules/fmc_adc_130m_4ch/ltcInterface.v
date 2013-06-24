`timescale 1ns / 1ps
// Author: Andrzej Wojenski
//
// Module:  ltcInterface
// Version: 1.0
//
// Description: ADC LTC2208 chip data handling
//              -- data transfer lines implementation for ADC chips
//              Allows:
//              - data shifting (IDELAY for data lines, controled through PC)
//
//  Note: If using this firmware with Artix7 FPGA check tap resolution (IDELAY lines)
module ltcInterface(

                // LTC clock input
                input adc0_clk_in,
                // LTC data input
                input [15:0]adc0_data_in,
                input adc0_ov_in,

                // LTC clock output
                output adc0_clk_out,
                // LTC data output
                output [16:0]adc0_data_out, // with overflow bit
                // Control signals for IDELAY
                input sys_clk,
                input ref_clk, // 200MHz
                input rst,

                input [4:0]adc0_delay_reg,
                input [16:0]adc0_delay_select, // now only for data (with ov bit), for clock 16:0
                input adc0_delay_load,
                output [4:0]adc0_delay_reg_read,
                output adc0_delay_rdy

);
// param for IODELAY group
parameter IDELAY_SIGNAL_GROUP = "adc0_data_delay_group";
parameter FPGA_DEVICE = "VIRTEX6";

// Small fifo depth. This FIFO is intended just to cross phase-mismatched
// clock domains (BUFR -> BUFG), but frequency locked
localparam c_async_fifo_size = 16;
localparam c_num_adc_bits = 17;
localparam c_num_fifo_guard_bits = 3;

genvar i;

wire [16:0]adc0_del;
wire [4:0]adc0_read_reg[16:0];

wire adc0_data_in_w[16:0] = {adc0_ov_in, adc0_data_in[15:0]};
wire [16:0]adc0_data_out_d;


//clock signals
wire adc0_clk_ibufg_out;
wire adc0_clk_bufr_out;
wire adc0_clk_bufg_in;
wire adc0_clk_out_w;
wire rst_n;

// fifo signals
reg adc_data_valid_out;
wire adc_fifo_full;
wire adc_fifo_empty;
wire adc_fifo_wr;
wire adc_fifo_rd;

assign rst_n = !rst;

// control value
assign adc0_delay_reg_read[4:0] = adc0_read_reg[0];

// Clock signal
IBUFG #(
      .IBUF_LOW_PWR("FALSE"),  // Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      .IOSTANDARD("DEFAULT")  // Specify the input I/O standard
   ) IBUFG_ADC0_CLK_inst (
      .O(adc0_clk_ibufg_out), // Clock buffer output
      .I(adc0_clk_in)  // Clock buffer input (connect directly to top-level port)
   );

// On ML605 kit, all clock pins are assigned to MRCC pins. However, two of them
// (fmc_adc1_clk and fmc_adc3_clk) are located in the outer left/right column
// I/Os. These locations cannot connect to BUFG primitives, only inner (center)
// left/right column I/Os on the same half top/bottom can!
//
// For 7-series FPGAs there is no such impediment, apparently.

generate
  if (FPGA_DEVICE == "VIRTEX6") begin : CLOCK_INST_DEVICE_VIRTEX6

    BUFR #(
       .BUFR_DIVIDE("BYPASS"), // "BYPASS", "1", "2", "3", "4", "5", "6", "7", "8"
       .SIM_DEVICE("VIRTEX6")  // Specify target device, "VIRTEX4", "VIRTEX5", "VIRTEX6"
    ) BUFR_inst (
       .O(adc0_clk_bufr_out),     // Clock buffer output
       .CE(1'b1),   // Active high divide counter clock enable input, when low disables output
       .CLR(1'b0), // Active high divide counter reset input
       .I(adc0_clk_ibufg_out)      // Clock buffer input driven by an IBUFG, MMCM or local interconnect
    );

    assign adc0_clk_bufg_in = adc0_clk_bufr_out;

  end
  else if (FPGA_DEVICE == "7SERIES") begin : CLOCK_INST_DEVICE_7SERIES

    assign adc0_clk_bufg_in = adc0_clk_ibufg_out;

  end
endgenerate

BUFG BUFG_ADC0_CLK_inst (
   .O(adc0_clk_out_w), // 1-bit output: Clock output (invert clock for timings)
   .I(adc0_clk_bufg_in)  // 1-bit input: Clock input
);

assign adc0_clk_out = adc0_clk_out_w;

// ===============================================
//              Data path calibration
//                  (ADC LTC)
// ===============================================

reg adc0_delay_load_reg = 0;
reg adc0_delay_load_en = 0;

// for one pulse signal
always @(posedge sys_clk)
begin
        adc0_delay_load_reg <= adc0_delay_load;

        if (adc0_delay_load_reg == 1'b0 && adc0_delay_load == 1'b1) // rising edge
                adc0_delay_load_en <= 1'b1;
        else
                adc0_delay_load_en <= 1'b0;
end

// data shifting
// with OV bit

generate
    for (i = 0; i < 17; i = i + 1) begin: ADC_DELAY_DATA
        if (FPGA_DEVICE == "VIRTEX6") begin: ADC_VIRTEX6_DELAY_DATA_DEVICE
            (* IODELAY_GROUP = IDELAY_SIGNAL_GROUP *) // Specifies group name
                                                      //for associated IDELAYs/ODELAYs and IDELAYCTRL
            IODELAYE1 #(
              .IDELAY_TYPE ("VAR_LOADABLE"),
              .IDELAY_VALUE (0),
              .SIGNAL_PATTERN ("DATA"),
              .HIGH_PERFORMANCE_MODE ("TRUE"),
              .DELAY_SRC ("I")
            )
            IODELAYE1_adc0_inst (
              .CNTVALUEOUT(adc0_read_reg[i]), // 5-bit output: Counter value output
              .DATAOUT(adc0_data_out_d[i]),         // 1-bit output: Delayed data output
              .C(sys_clk),                     // 1-bit input: Clock input
              .CE(1'b0),                   // 1-bit input: Active high enable increment/decrement input
              .CINVCTRL(1'b0),       // 1-bit input: Dynamic clock inversion input
              .CNTVALUEIN(adc0_delay_reg),   // 5-bit input: Counter value input
              .DATAIN(),           // 1-bit input: Internal delay data input
              .ODATAIN(),
              .CLKIN(),
              .IDATAIN(adc0_data_in_w[i]),   // 1-bit input: Data input from the I/O
              .INC(1'b0),                 // 1-bit input: Increment / Decrement tap delay input
              .RST(adc0_delay_load_en && adc0_delay_select[i]), // 1-bit input: Active-high reset tap-delay input
              .T(1'b1)
            );
        end
        else if (FPGA_DEVICE == "7SERIES") begin: ADC_7SERIES_DELAY_DATA_DEVICE  //7-SERIES
            (* IODELAY_GROUP = IDELAY_SIGNAL_GROUP *) // Specifies group name for associated IDELAYs/ODELAYs and IDELAYCTRL
            IDELAYE2 #(
                .CINVCTRL_SEL("FALSE"),          // Enable dynamic clock inversion (FALSE, TRUE)
                .DELAY_SRC("IDATAIN"),           // Delay input (IDATAIN, DATAIN)
                .HIGH_PERFORMANCE_MODE("TRUE"), // Reduced jitter ("TRUE"), Reduced power ("FALSE")
                .IDELAY_TYPE("VAR_LOAD"),           // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
                .IDELAY_VALUE(0),                // Input delay tap setting (0-31)
                .PIPE_SEL("FALSE"),              // Select pipelined mode, FALSE, TRUE
                .REFCLK_FREQUENCY(200.0),        // IDELAYCTRL clock input frequency in MHz (190.0-210.0).
                .SIGNAL_PATTERN("DATA")          // DATA, CLOCK input signal
            )
            IDELAYE2_adc0_inst (
                .CNTVALUEOUT(adc0_read_reg[i]), // 5-bit output: Counter value output
                .DATAOUT(adc0_data_out_d[i]),         // 1-bit output: Delayed data output
                .C(sys_clk),                     // 1-bit input: Clock input
                .CE(1'b0),                   // 1-bit input: Active high enable increment/decrement input
                .CINVCTRL(1'b0),       // 1-bit input: Dynamic clock inversion input
                .CNTVALUEIN(adc0_delay_reg),   // 5-bit input: Counter value input
                .DATAIN(),           // 1-bit input: Internal delay data input
                .IDATAIN(adc0_data_in_w[i]),   // 1-bit input: Data input from the I/O
                .INC(1'b0),                 // 1-bit input: Increment / Decrement tap delay input
                .LD(adc0_delay_load_en && adc0_delay_select[i]), // 1-bit input: Load IDELAY_VALUE input
                .LDPIPEEN(1'b0),       // 1-bit input: Enable PIPELINE register to load data input
                .REGRST(rst)            // 1-bit input: Active-high reset tap-delay input
            );
        end
    end
endgenerate

// Clock shifting
//(* IODELAY_GROUP = "adc0_data_delay_group" *) // Specifies group name for associated IDELAYs/ODELAYs and IDELAYCTRL
//   IDELAYE2 #(
//      .CINVCTRL_SEL("FALSE"),          // Enable dynamic clock inversion (FALSE, TRUE)
//      .DELAY_SRC("IDATAIN"),           // Delay input (IDATAIN, DATAIN)
//      .HIGH_PERFORMANCE_MODE("TRUE"), // Reduced jitter ("TRUE"), Reduced power ("FALSE")
//      .IDELAY_TYPE("VAR_LOAD"),           // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
//      .IDELAY_VALUE(0),                // Input delay tap setting (0-31)
//      .PIPE_SEL("FALSE"),              // Select pipelined mode, FALSE, TRUE
//      .REFCLK_FREQUENCY(200.0),        // IDELAYCTRL clock input frequency in MHz (190.0-210.0).
//      .SIGNAL_PATTERN("CLOCK")          // DATA, CLOCK input signal
//   )
//   IDELAYE2_adc0_inst (
//      .CNTVALUEOUT(), // 5-bit output: Counter value output
//      .DATAOUT(adc0_clk_del),         // 1-bit output: Delayed data output
//      .C(sys_clk),                     // 1-bit input: Clock input
//      .CE(1'b0),                   // 1-bit input: Active high enable increment/decrement input
//      .CINVCTRL(1'b0),       // 1-bit input: Dynamic clock inversion input
//      .CNTVALUEIN(adc0_delay_reg),   // 5-bit input: Counter value input
//      .DATAIN(),           // 1-bit input: Internal delay data input
//      .IDATAIN(adc0_clk),         // 1-bit input: Data input from the I/O
//      .INC(1'b0),                 // 1-bit input: Increment / Decrement tap delay input
//      .LD(adc0_delay_load_en && adc0_delay_select[i]), // 1-bit input: Load IDELAY_VALUE input
//      .LDPIPEEN(1'b0),       // 1-bit input: Enable PIPELINE register to load data input
//      .REGRST(rst)            // 1-bit input: Active-high reset tap-delay input
//   );

generate
  if (FPGA_DEVICE == "VIRTEX6") begin: ADC_IDDR_VIRTEX6
    // BUFG and BUFR/BUFIO are not guaranteed to be phase-matched,
    // as they drive independently clock nets. Hence, a FIFO is needed to employ
    // a clock domain crossing.
    //inferred_async_fifo
    generic_async_fifo #(
      .g_data_width(c_num_adc_bits),
      .g_size(c_async_fifo_size),
      .g_almost_empty_threshold(c_num_fifo_guard_bits),
      .g_almost_full_threshold(c_async_fifo_size - c_num_fifo_guard_bits)
    ) async_fifo (
      .rst_n_i     (rst_n),

      // write port
      .clk_wr_i    (adc0_clk_bufr_out),
      .d_i         (adc0_data_out_d),
      .we_i        (adc_fifo_wr),
      //.we_i        (1'b1),
      .wr_full_o   (adc_fifo_full),

      // read port
      .clk_rd_i    (adc0_clk_out_w),
      .q_o         (adc0_data_out),
      .rd_i        (adc_fifo_rd),
      //.rd_i        (1'b1),
      .rd_empty_o  (adc_fifo_empty)
    );

    // Generate valid signal for adc_data_o.
    // Just delay the valid adc_fifo_rd signal as the fifo takes
    // one clock cycle, after it has registered adc_fifo_rd, to output
    // data on q_o port

    always @(posedge adc0_clk_out_w)
    begin
        adc_data_valid_out <= adc_fifo_rd;

        if (adc_fifo_empty) begin
          adc_data_valid_out <= 1'b0;
        end;
    end;

    assign adc_fifo_wr = ~adc_fifo_full;
    assign adc_fifo_rd = ~adc_fifo_empty;
  end
  else if (FPGA_DEVICE == "7SERIES") begin: ADC_IDDR_7SERIES

    assign adc0_data_out = adc0_data_out_d;
  end
endgenerate

(* IODELAY_GROUP = IDELAY_SIGNAL_GROUP *) // Specifies group name for associated IDELAYs/ODELAYs and IDELAYCTRL
  IDELAYCTRL IDELAYCTRL_adc0_inst (
      .RDY(adc0_delay_rdy),       // 1-bit output: Ready output
      .REFCLK(ref_clk), // 1-bit input: Reference clock input
      .RST(rst)        // 1-bit input: Active high reset input
   );

endmodule
