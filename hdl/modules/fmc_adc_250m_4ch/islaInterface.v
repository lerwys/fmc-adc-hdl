`timescale 1ns / 1ps
// Author: Andrzej Wojenski
//
// Module:  islaInterface
// Version: 1.0
//
// Description: ADC ISLA chip data handling
//              -- data transfer lines implementation for ADC chips
//              Allows:
//              - data shifting (IDELAY for data lines, controled through PC)
//
//  Note: If using this firmware with Artix7 FPGA check tap resolution (IDELAY lines)
module islaInterface(

                // ISLA clock input
                input adc0_clk_p,
                input adc0_clk_n,
                // ISLA data input
                input [7:0]adc0_data_in_p,
                input [7:0]adc0_data_in_n,
                // ISLA clock output (SDR)
                output adc0_clk,
                // ISLA data output (SDR)
                output [15:0]adc0_d_ddr,
                // Control signals for IDELAY
                input sys_clk,
                input ref_clk, // 200MHz
                input rst,

                input [4:0]adc0_delay_reg,
                input [7:0]adc0_delay_select, // for clock 8:0
                input adc0_delay_load,
                output [4:0]adc0_delay_reg_read,
                output adc0_delay_rdy

);
// param for IODELAY group
parameter IDELAY_SIGNAL_GROUP = "adc0_data_delay_group";
parameter [7:0]IDELAY_LVDS_INV = 8'h00;
parameter FPGA_DEVICE = "VIRTEX6";

// Small fifo depth. This FIFO is intended just to cross phase-mismatched
// clock domains (BUFR -> BUFG), but frequency locked
localparam c_async_fifo_size = 16;
localparam c_num_adc_bits = 16;
localparam c_num_fifo_guard_bits = 3;

genvar i_lvds;
genvar i;

wire [15:0]adc0_del;
wire [7:0]adc0_d;

wire [4:0]adc0_read_reg[7:0];
wire adc0_ibufgds_clk;
wire adc0_ibufds_clk;
wire adc0_bufg_clk;
wire adc0_ddr_clk;

// fifo signals.
wire adc_fifo_wr;
wire adc_fifo_rd;
//reg adc_fifo_wr;
//reg adc_fifo_rd;
wire adc_fifo_full;
wire adc_fifo_empty;

wire [15:0]adc0_d_ddr_int;

// reset signals
wire rst_n;

assign rst_n = ~rst;

// control value
assign adc0_delay_reg_read[4:0] = adc0_read_reg[0];

// On ML605 kit, all clock pins are assigned to MRCC pins. However, two of them
// (fmc_adc1_clk and fmc_adc3_clk) are located in the outer left/right column
// I/Os. These locations cannot connect to BUFG primitives, only inner (center)
// left/right column I/Os on the same half top/bottom can!
//
// For 7-series FPGAs there is no such impediment, apparently.

generate
  // Clock signal
  if (FPGA_DEVICE == "VIRTEX6") begin : CLOCK_INST_DEVICE_VIRTEX6
      IBUFDS #(
        .DIFF_TERM("TRUE"), // Differential Termination
        .IBUF_LOW_PWR("FALSE"), // Low power="TRUE", Highest performance="FALSE"
        .IOSTANDARD("LVDS_25") // Specifies the I/O standard for this buffer
    ) IBUFDS_ADC0_CLK_inst (
        .O(adc0_ibufds_clk),  // Clock buffer output
        .I(adc0_clk_p),  // Diff_p clock buffer input
        .IB(adc0_clk_n) // Diff_n clock buffer input
    );

    BUFR #(
       .BUFR_DIVIDE("BYPASS"), // "BYPASS", "1", "2", "3", "4", "5", "6", "7", "8"
       .SIM_DEVICE("VIRTEX6")  // Specify target device, "VIRTEX4", "VIRTEX5", "VIRTEX6"
    ) BUFR_inst (
       .O(adc0_ddr_clk),     // Clock buffer output
       .CE(1'b1),   // Active high divide counter clock enable input, when low disables output
       .CLR(1'b0), // Active high divide counter reset input
       .I(adc0_ibufds_clk)      // Clock buffer input driven by an IBUFG, MMCM or local interconnect
    );

    BUFG BUFG_ADC0_CLK_inst (
      .O(adc0_bufg_clk), // 1-bit output: Clock output (invert clock for timings)
      .I(adc0_ddr_clk)  // 1-bit input: Clock input
    );
  end
  else if (FPGA_DEVICE == "7SERIES") begin : CLOCK_INST_DEVICE_7SERIES
    IBUFGDS #(
        .DIFF_TERM("TRUE"), // Differential Termination
        .IBUF_LOW_PWR("FALSE"), // Low power="TRUE", Highest performance="FALSE"
        .IOSTANDARD("LVDS_25") // Specifies the I/O standard for this buffer
    ) IBUFGDS_ADC0_CLK_inst (
        .O(adc0_ibufgds_clk),  // Clock buffer output
        .I(adc0_clk_p),  // Diff_p clock buffer input
        .IB(adc0_clk_n) // Diff_n clock buffer input
    );

    BUFG BUFG_ADC0_CLK_inst (
      .O(adc0_ddr_clk), // 1-bit output: Clock output (invert clock for timings)
      .I(adc0_ibufgds_clk)  // 1-bit input: Clock input
    );
  end
endgenerate

wire [7:0]w_adc0_d;

// LVDS data lines to single ended
generate
        for (i = 0; i < 8; i = i + 1) begin: ADC_LVDS
         IBUFDS #(
        .DIFF_TERM("TRUE"),   // Differential Termination
          .IOSTANDARD("LVDS_25") // Specify the input I/O standard
        ) IBUFDS_inst (
          .O(w_adc0_d[i]),  // Buffer output
          .I(adc0_data_in_p[i]),  // Diff_p buffer input (connect directly to top-level port)
          .IB(adc0_data_in_n[i]) // Diff_n buffer input (connect directly to top-level port)
        );
        end
endgenerate

generate
        for (i = 0; i < 8; i = i + 1) begin: ADC_LVDS_INV
                if (IDELAY_LVDS_INV[i] == 1) begin
                        assign adc0_d[i] = !w_adc0_d[i];
                end
                else begin
                        assign adc0_d[i] = w_adc0_d[i];
                end
        end
endgenerate

// ===============================================
//              Data path calibration
//                  (ADC ISLA)
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
generate
  for (i = 0; i < 8; i = i + 1) begin: ADC0_DELAY_DDR_DATA
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
          .DATAOUT(adc0_del[i]),         // 1-bit output: Delayed data output
          .C(sys_clk),                     // 1-bit input: Clock input
          .CE(1'b0),                   // 1-bit input: Active high enable increment/decrement input
          .CINVCTRL(1'b0),       // 1-bit input: Dynamic clock inversion input
          .CNTVALUEIN(adc0_delay_reg),   // 5-bit input: Counter value input
          .DATAIN(),           // 1-bit input: Internal delay data input
          .ODATAIN(),
          .CLKIN(),
          .IDATAIN(adc0_d[i]),   // 1-bit input: Data input from the I/O
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
            .DATAOUT(adc0_del[i]),         // 1-bit output: Delayed data output
            .C(sys_clk),                     // 1-bit input: Clock input
            .CE(1'b0),                   // 1-bit input: Active high enable increment/decrement input
            .CINVCTRL(1'b0),       // 1-bit input: Dynamic clock inversion input
            .CNTVALUEIN(adc0_delay_reg),   // 5-bit input: Counter value input
            .DATAIN(),           // 1-bit input: Internal delay data input
            .IDATAIN(adc0_d[i]),   // 1-bit input: Data input from the I/O
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

// DDR data management
generate
  for (i = 0; i < 8; i = i + 1) begin: ADC_DDR_DATA
    IDDR #(
      .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE", "SAME_EDGE"
                                                  //    or "SAME_EDGE_PIPELINED"
      .INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
      .INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC"
    ) IDDR_inst (
      .Q1(adc0_d_ddr_int[2*i + 1]), // 1-bit output for positive edge of clock
      .Q2(adc0_d_ddr_int[2*i]), // 1-bit output for negative edge of clock
      .C(adc0_ddr_clk),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D(adc0_del[i]),   // 1-bit DDR data input
                //.R(!sys_rst),   // 1-bit reset input
      .R(rst),   // 1-bit reset
      .S(1'b0)    // 1-bit set
    );
  end
endgenerate

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
      .clk_wr_i    (adc0_ddr_clk),
      .d_i         (adc0_d_ddr_int),
      //.we_i        (adc_fifo_wr),
      .we_i        (1'b1),
      .wr_full_o   (adc_fifo_full),

      // read port
      .clk_rd_i    (adc0_bufg_clk),
      .q_o         (adc0_d_ddr),
      //.rd_i        (adc_fifo_rd),
      .rd_i        (1'b1),
      .rd_empty_o  (adc_fifo_empty)
    );

    // Generate valid signal for adc_data_o.
    // Just delay the valid adc_fifo_rd signal as the fifo takes
    // one clock cycle, after it has registered adc_fifo_rd, to output
    // data on q_o port
    //
    //always @(posedge adc0_clk)
    //begin
    //    adc_data_valid_out <= adc_fifo_rd;
    //
    //    if (adc_fifo_empty == '1') begin
    //      adc_data_valid_out <= '0';
    //    end;
    //end;

    // ease timing
    //always @(posedge adc0_ddr_clk) begin
    //    adc_fifo_wr <= ~adc_fifo_full;
    //end
    //
    //always @(posedge adc0_bufg_clk) begin
    //    adc_fifo_rd <= ~adc_fifo_empty;
    //end

    //assign adc_fifo_wr = ~adc_fifo_full;
    //assign adc_fifo_rd = ~adc_fifo_empty;

    assign adc0_clk = adc0_bufg_clk;
  end
  else if (FPGA_DEVICE == "7SERIES") begin: ADC_IDDR_7SERIES
    // This is a global clock already. Just connect directly to output
    assign adc0_clk = adc0_ddr_clk;
    assign adc0_d_ddr = adc0_d_ddr_int;
  end
endgenerate

(* IODELAY_GROUP = IDELAY_SIGNAL_GROUP *) // Specifies group name for associated IDELAYs/ODELAYs and IDELAYCTRL
  IDELAYCTRL IDELAYCTRL_adc0_inst (
      .RDY(adc0_delay_rdy),       // 1-bit output: Ready output
      .REFCLK(ref_clk), // 1-bit input: Reference clock input
      .RST(rst)        // 1-bit input: Active high reset input
   );

endmodule
