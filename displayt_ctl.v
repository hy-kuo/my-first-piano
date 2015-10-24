`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:21:38 04/09/2012 
// Design Name: 
// Module Name:    displayt_ctl 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "global.v"
module display_ctl(
    state,
	 op_a0,
	 op_a1,
	 op_b0,
	 op_b1,
	 result0,
	 result1,
	 result2,
	 result3,
	 in0,
	 in1,
	 in2,
	 in3
    );
input [1:0] state;
input [3:0]op_a0 ;
input [3:0]op_a1 ;
input [3:0]op_b0 ;
input [3:0]op_b1 ;
input [`BCD_BIT_WIDTH-1:0]result0 ;
input [`BCD_BIT_WIDTH-1:0]result1 ;
input [`BCD_BIT_WIDTH-1:0]result2 ;
input [`BCD_BIT_WIDTH-1:0]result3 ;
output reg [`BCD_BIT_WIDTH-1:0] in0,in1,in2,in3;

always@*
  case(state)
    `OP_A_IN:begin
	     in0=op_a1;
		  in1=op_a0;
		  in2=4'd0;
		  in3=4'd0;
		  end
    `OP_B_IN:begin
	     in0=op_a1;
		  in1=op_a0;
		  in2=op_b1;
		  in3=op_b0;
		  end
    `RESULT_OUT:begin
	     in0=result3;//result[3];
		  in1=result2;
		  in2=result1;
		  in3=result0;
		  end		  
  endcase
endmodule
