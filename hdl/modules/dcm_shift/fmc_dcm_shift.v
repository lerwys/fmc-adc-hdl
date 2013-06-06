// Module for DCM phase shifting
// Author: Andrzej Wojenski
module fmc_adc_dac_dcm_manager(

	 // System signals
	 input sys_rst,
	 input sys_clk,	
	 
	 input dcm_reset,
	 input dcm_change,
	 input dcm_phase_inc,
	 input dcm_psdone,
	 
	 input dcm_store_en, // storing data when running ADC or DAC mode
	 
	 // DCM status signals
	 input [2:0]dcm_status,
	 input dcm_locked,
	 input dcm_valid,
	 
	 output dcm_psen_out,
	 output dcm_psin_out,
	 output dcm_done_out, // phase shifting done when signal is 1
	 output dcm_reset_signal_out, // 20 cycles
	 
	 output [2:0]dcm_status_store_out,
	 output dcm_locked_store_out,
	 output dcm_valid_store_out
    
);

reg dcm_change_flag = 1'b0;
reg dcm_psen = 1'b0;
reg dcm_psin = 1'b0;
reg dcm_done_reg = 1'b0;

assign dcm_psen_out = dcm_psen;
assign dcm_psin_out = dcm_psin;
assign dcm_done_out = dcm_done_reg;

always @(posedge sys_clk)
begin
if (sys_rst || !dcm_change)
	begin
		dcm_done_reg <= 1'b0;
		dcm_change_flag <= 1'b0;
		dcm_psen <= 1'b0;
		dcm_psin <= 1'b0;
	end		
else	
begin

	// change phase of DCM
	if (dcm_change == 1'b1 && dcm_change_flag == 1'b0)
		begin		
			// only for one clock cycle
			dcm_psen	<= 1'b1;
			dcm_psin <= dcm_phase_inc; // from WB register
			dcm_change_flag <= 1'b1;
		end		
	else
		begin
			dcm_psen	<= 1'b0;
			dcm_psin <= 1'b0;
			dcm_change_flag <= dcm_change_flag;
		end
	
	// store done signal
	if (dcm_psdone == 1'b1)
		dcm_done_reg <= 1'b1;
	else
		dcm_done_reg <= dcm_done_reg;
end
end

// Sync status signals
reg [8:0]dcm_status_sync = 0;
reg [2:0]dcm_locked_sync = 0;
reg [2:0]dcm_valid_sync = 0;

always @(posedge sys_clk)
begin
	dcm_status_sync[2:0] <= dcm_status[2:0];
	dcm_status_sync[5:3] <= dcm_status_sync[2:0];	
	dcm_status_sync[8:6] <= dcm_status_sync[5:3];		
	
	dcm_valid_sync[0] <= dcm_valid;
	dcm_valid_sync[1] <= dcm_valid_sync[0];
	dcm_valid_sync[2] <= dcm_valid_sync[1];
	
	dcm_locked_sync[0] <= dcm_locked;
	dcm_locked_sync[1] <= dcm_locked_sync[0];
	dcm_locked_sync[2] <= dcm_locked_sync[1];
end

wire [2:0]w_dcm_status_sync;
wire w_dcm_locked_sync;
wire w_dcm_valid_sync;

assign w_dcm_status_sync[2:0] = dcm_status_sync[8:6];
assign w_dcm_locked_sync = dcm_locked_sync[2];
assign w_dcm_valid_sync = dcm_valid_sync[2];

// store data if DCM has an error while running (for example DAC waveform sending)

reg [2:0]dcm_status_store = 0;
reg dcm_locked_store = 1'b0;
reg dcm_valid_store = 1'b0;

assign dcm_status_store_out[2:0] = dcm_status_store[2:0];
assign dcm_locked_store_out = dcm_locked_store;
assign dcm_valid_store_out = dcm_valid_store;

always @(posedge sys_clk)
begin
if (sys_rst) // showing valid status
begin
	dcm_status_store <= 0;
	dcm_locked_store <= 1'b1;
	dcm_valid_store <= 1'b1;
end
else
begin

	if (dcm_store_en == 1'b1) // regs being cleared while adc_start od dac_start are changed to 0 by software
	begin
	
		if (w_dcm_status_sync[1:0] != 0) // don't check status2 since it is not used in design
			dcm_status_store[2:0] <= w_dcm_status_sync[2:0];
		else
			dcm_status_store[2:0] <= dcm_status_store[2:0];
			
		if (w_dcm_locked_sync == 1'b0)
			dcm_locked_store <= 1'b0;
		else
			dcm_locked_store <= dcm_locked_store;
			
		if (w_dcm_valid_sync == 1'b0)
			dcm_valid_store <= 1'b0;
		else
			dcm_valid_store <= dcm_valid_store;
		
	end
	else
	begin
		dcm_status_store[2:0] <= w_dcm_status_sync[2:0];
		dcm_locked_store <= w_dcm_locked_sync;
		dcm_valid_store <= w_dcm_valid_sync;
	end

end
end

// reset signal
reg dcm_reset_signal = 1'b0;
reg [4:0]dcm_rst_cnt = 0;

assign dcm_reset_signal_out = dcm_reset_signal;

always @(posedge sys_clk)
begin
if (sys_rst || !dcm_reset)
	begin
		dcm_reset_signal <= 1'b0;
		dcm_rst_cnt <= 0;
	end		
else	
begin
	
	if (dcm_reset == 1'b1 && (dcm_rst_cnt < 20) )	
		dcm_reset_signal <= 1'b1;		
	else
		dcm_reset_signal <= 1'b0;
	
	// count 20 cycles of reset signal
	if (dcm_reset == 1'b1 && dcm_reset_signal == 1'b1)
		dcm_rst_cnt <= dcm_rst_cnt + 1'b1; 
	else
		dcm_rst_cnt <= dcm_rst_cnt;

end
end


endmodule
