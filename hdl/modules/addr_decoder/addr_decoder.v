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
  input [31:0]data_out10,
  output reg acmp11,
  input [31:0]data_out11,
  output reg acmp12,
  input [31:0]data_out12,
  output reg acmp13,
  input [31:0]data_out13,
  output reg acmp14,
  input [31:0]data_out14,
  output reg acmp15,
  input [31:0]data_out15,
  output reg acmp16,
  input [31:0]data_out16
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
    acmp11 <= 1'b0;
    acmp12 <= 1'b0;
    acmp13 <= 1'b0;
    acmp14 <= 1'b0;
    acmp15 <= 1'b0;
    acmp16 <= 1'b0;
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
    acmp11 <= 1'b0;
    acmp12 <= 1'b0;
    acmp13 <= 1'b0;
    acmp14 <= 1'b0;
    acmp15 <= 1'b0;
    acmp16 <= 1'b0;
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
    acmp11 <= 1'b0;
    acmp12 <= 1'b0;
    acmp13 <= 1'b0;
    acmp14 <= 1'b0;
    acmp15 <= 1'b0;
    acmp16 <= 1'b0;
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
    acmp11 <= 1'b0;
    acmp12 <= 1'b0;
    acmp13 <= 1'b0;
    acmp14 <= 1'b0;
    acmp15 <= 1'b0;
    acmp16 <= 1'b0;
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
    acmp11 <= 1'b0;
    acmp12 <= 1'b0;
    acmp13 <= 1'b0;
    acmp14 <= 1'b0;
    acmp15 <= 1'b0;
    acmp16 <= 1'b0;
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
    acmp11 <= 1'b0;
    acmp12 <= 1'b0;
    acmp13 <= 1'b0;
    acmp14 <= 1'b0;
    acmp15 <= 1'b0;
    acmp16 <= 1'b0;
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
    acmp11 <= 1'b0;
    acmp12 <= 1'b0;
    acmp13 <= 1'b0;
    acmp14 <= 1'b0;
    acmp15 <= 1'b0;
    acmp16 <= 1'b0;
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
    acmp11 <= 1'b0;
    acmp12 <= 1'b0;
    acmp13 <= 1'b0;
    acmp14 <= 1'b0;
    acmp15 <= 1'b0;
    acmp16 <= 1'b0;
    data_out <= data_out8;
  end
  16'h09:
  begin
    acmp1 <= 1'b0;
    acmp2 <= 1'b0;
    acmp3 <= 1'b0;
    acmp4 <= 1'b0;
    acmp5 <= 1'b0;
    acmp6 <= 1'b0;
    acmp7 <= 1'b0;
    acmp8 <= 1'b0;
    acmp9 <= 1'b1;
    acmp10 <= 1'b0;
    acmp11 <= 1'b0;
    acmp12 <= 1'b0;
    acmp13 <= 1'b0;
    acmp14 <= 1'b0;
    acmp15 <= 1'b0;
    acmp16 <= 1'b0;
    data_out <= data_out9;
  end
  16'h0a:
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
    acmp10 <= 1'b1;
    acmp11 <= 1'b0;
    acmp12 <= 1'b0;
    acmp13 <= 1'b0;
    acmp14 <= 1'b0;
    acmp15 <= 1'b0;
    acmp16 <= 1'b0;
    data_out <= data_out10;
  end
  16'h0b:
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
    acmp11 <= 1'b1;
    acmp12 <= 1'b0;
    acmp13 <= 1'b0;
    acmp14 <= 1'b0;
    acmp15 <= 1'b0;
    acmp16 <= 1'b0;
    data_out <= data_out11;
  end
  16'h0c:
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
    acmp11 <= 1'b0;
    acmp12 <= 1'b1;
    acmp13 <= 1'b0;
    acmp14 <= 1'b0;
    acmp15 <= 1'b0;
    acmp16 <= 1'b0;
    data_out <= data_out12;
  end
  16'h0d:
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
    acmp11 <= 1'b0;
    acmp12 <= 1'b0;
    acmp13 <= 1'b1;
    acmp14 <= 1'b0;
    acmp15 <= 1'b0;
    acmp16 <= 1'b0;
    data_out <= data_out13;
  end
  16'h0e:
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
    acmp11 <= 1'b0;
    acmp12 <= 1'b0;
    acmp13 <= 1'b0;
    acmp14 <= 1'b1;
    acmp15 <= 1'b0;
    acmp16 <= 1'b0;
    data_out <= data_out14;
  end
  16'h0f:
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
    acmp11 <= 1'b0;
    acmp12 <= 1'b0;
    acmp13 <= 1'b0;
    acmp14 <= 1'b0;
    acmp15 <= 1'b1;
    acmp16 <= 1'b0;
    data_out <= data_out15;
  end
  16'h10:
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
    acmp11 <= 1'b0;
    acmp12 <= 1'b0;
    acmp13 <= 1'b0;
    acmp14 <= 1'b0;
    acmp15 <= 1'b0;
    acmp16 <= 1'b1;
    data_out <= data_out16;
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
    acmp11 <= 1'b0;
    acmp12 <= 1'b0;
    acmp13 <= 1'b0;
    acmp14 <= 1'b0;
    acmp15 <= 1'b0;
    acmp16 <= 1'b0;
  data_out <= 32'h00000000;
  end
  endcase

endmodule
