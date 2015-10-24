`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:35:58 05/15/2012 
// Design Name: 
// Module Name:    DoReMi 
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
module DoReMi(clk, rst_n, in, out,in0,in1);

input [3:0]in;
input clk, rst_n;
output [19:0]out;
output reg [3:0]in0,in1;
reg [19:0]out;

reg [15:0]counter;




	
always@*
case(in)
	4'h0: out = 0;/*begin out = 20'd90909; in0=4'd13; end*/
	4'h0: out = 0; /* begin out = 20'd81632; in0=4'd12; end*/
	4'h1: out = 20'd76628;
	4'h2: out = 20'd68259;
	4'h3: out = 20'd60606;
	4'h4: out = 20'd57306;
	4'h5: out = 20'd51020;
	4'h6: out = 20'd45454;
	4'h7: out = 20'd40485;
	4'h8: out = 20'd38167;
	4'h9: out = 20'd34013;
	4'hA: out = 20'd30303;
	4'hB: out = 20'd28653;
	4'hC: out = 20'd25510;
	4'hD: out = 20'd22727;
	4'hE: out = 20'd20242;

	default: out = 20'd0;
endcase



endmodule
