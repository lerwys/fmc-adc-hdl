// Author: Andrzej Wojenski
// 
// Module:  addr_decode
// Version: 1.0
//
// Description: Wishbone address decoder
module addr_decode(
	input [15:0]addr_in,
	output reg [31:0]data_out,
	output reg acmp1,
	input [31:0]data_out1,
	output reg acmp2,
	input [31:0]data_out2,
	output reg acmp3,
	input [31:0]data_out3,
	output reg acmp4,
	input [31:0]data_out4,
	output reg acmp5,
	input [31:0]data_out5,
	output reg acmp6,
	input [31:0]data_out6,
	output reg acmp7,
	input [31:0]data_out7,
	output reg acmp8,
	input [31:0]data_out8,
	output reg acmp9,
	input [31:0]data_out9,
	output reg acmp10,
	input [31:0]data_out10
);

always@(*)
	case(addr_in[15:0])
			16'h01:
			begin
			acmp1 <= 1'b1;
			acmp2 <= 1'b0;
			acmp3 <= 1'b0;
			acmp4 <= 1'b0;
			acmp5 <= 1'b0;
			acmp6 <= 1'b0;
			acmp7 <= 1'b0;
			acmp8 <= 1'b0;
			acmp9 <= 1'b0;
			acmp10 <= 1'b0;
			data_out <= data_out1;
			end
			16'h02:
			begin
			acmp1 <= 1'b0;
			acmp2 <= 1'b1;
			acmp3 <= 1'b0;
			acmp4 <= 1'b0;
			acmp5 <= 1'b0;
			acmp6 <= 1'b0;
			acmp7 <= 1'b0;
			acmp8 <= 1'b0;
			acmp9 <= 1'b0;
			acmp10 <= 1'b0;
			data_out <= data_out2;
			end
			16'h03:
			begin
			acmp1 <= 1'b0;
			acmp2 <= 1'b0;
			acmp3 <= 1'b1;
			acmp4 <= 1'b0;
			acmp5 <= 1'b0;
			acmp6 <= 1'b0;
			acmp7 <= 1'b0;
			acmp8 <= 1'b0;
			acmp9 <= 1'b0;
			acmp10 <= 1'b0;
			data_out <= data_out3;
			end
			16'h04:
			begin
			acmp1 <= 1'b0;
			acmp2 <= 1'b0;
			acmp3 <= 1'b0;
			acmp4 <= 1'b1;
			acmp5 <= 1'b0;
			acmp6 <= 1'b0;
			acmp7 <= 1'b0;
			acmp8 <= 1'b0;
			acmp9 <= 1'b0;
			acmp10 <= 1'b0;
			data_out <= data_out4;
			end
			16'h05:
			begin
			acmp1 <= 1'b0;
			acmp2 <= 1'b0;
			acmp3 <= 1'b0;
			acmp4 <= 1'b0;
			acmp5 <= 1'b1;
			acmp6 <= 1'b0;
			acmp7 <= 1'b0;
			acmp8 <= 1'b0;
			acmp9 <= 1'b0;
			acmp10 <= 1'b0;
			data_out <= data_out5;
			end
			16'h06:
			begin
			acmp1 <= 1'b0;
			acmp2 <= 1'b0;
			acmp3 <= 1'b0;
			acmp4 <= 1'b0;
			acmp5 <= 1'b0;
			acmp6 <= 1'b1;
			acmp7 <= 1'b0;
			acmp8 <= 1'b0;
			acmp9 <= 1'b0;
			acmp10 <= 1'b0;
			data_out <= data_out6;
			end
			16'h07:
			begin
			acmp1 <= 1'b0;
			acmp2 <= 1'b0;
			acmp3 <= 1'b0;
			acmp4 <= 1'b0;
			acmp5 <= 1'b0;
			acmp6 <= 1'b0;
			acmp7 <= 1'b1;
			acmp8 <= 1'b0;
			acmp9 <= 1'b0;
			acmp10 <= 1'b0;
			data_out <= data_out7;
			end
			16'h08:
			begin
			acmp1 <= 1'b0;
			acmp2 <= 1'b0;
			acmp3 <= 1'b0;
			acmp4 <= 1'b0;
			acmp5 <= 1'b0;
			acmp6 <= 1'b0;
			acmp7 <= 1'b0;
			acmp8 <= 1'b1;
			acmp9 <= 1'b0;
			acmp10 <= 1'b0;
			data_out <= data_out8;
			end
			default:
			begin
			acmp1 <= 1'b0;
			acmp2 <= 1'b0;
			acmp3 <= 1'b0;
			acmp4 <= 1'b0;
			acmp5 <= 1'b0;
			acmp6 <= 1'b0;
			acmp7 <= 1'b0;
			acmp8 <= 1'b0;
			acmp9 <= 1'b0;
			acmp10 <= 1'b0;
			data_out <= 32'h00000000;
			end
	endcase
	
endmodule