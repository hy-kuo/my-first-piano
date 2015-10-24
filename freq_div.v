`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:12:25 04/05/2009 
// Design Name: 
// Module Name:    freq_div 
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
module freq_div(
  clk_out, // divided clock output
  clk_ctl, // divided clock for seven-segment display scan
  clk, // clock from the crystal
  rst_n, // low active reset
  clk_5M,
  clk_32M,
  clk_counter
);

output clk_out; // divided clock output
output [`FTSD_SCAN_CTL_BIT_WIDTH-1:0] clk_ctl; // divided clock for seven-segment display scan
output clk_5M;
output clk_32M;
output clk_counter;
input clk; // clock from the crystal
input rst_n; // low active reset

reg clk_out; // divided clock output (in the always block)
reg [`FTSD_SCAN_CTL_BIT_WIDTH-1:0] clk_ctl; // divided clock for seven-segment display scan (in the always block)
reg [5:0] cnt_l; // temperatory buffer
reg [6:0] cnt_h; // temperatory buffer
reg [`FREQ_DIV_BIT-1:0] cnt_tmp; // input node to flip flops
reg [2:0]clk5M_tmp;
reg [3:0]clk32M_tmp;
reg clk_5M;
reg clk_32M;
// Combinational block : increase by 1 neglecting overflow
always @(clk_out or cnt_h or cnt_l or clk_ctl)
  cnt_tmp = {clk_out,cnt_h,clk_ctl,cnt_l,clk_32M,clk32M_tmp,clk_5M,clk5M_tmp} + `INCREMENT;

assign clk_counter={clk_32M,clk32M_tmp};
// Sequential block 
always @(posedge clk or negedge rst_n) 
  if (~rst_n) 
	 {clk_out,cnt_h,clk_ctl,cnt_l,clk_32M,clk32M_tmp,clk_5M,clk5M_tmp} <= `FREQ_DIV_BIT'b0; 
  else 
	 {clk_out,cnt_h,clk_ctl,cnt_l,clk_32M,clk32M_tmp,clk_5M,clk5M_tmp} <= cnt_tmp;

endmodule
