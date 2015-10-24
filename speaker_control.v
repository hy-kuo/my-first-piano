`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:34:20 05/15/2012 
// Design Name: 
// Module Name:    speaker_control 
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
module speaker_control
(clk, pressed,
rst_n, audio_in_left, audio_in_right, audio_appsel, 
audio_sysclk, audio_bck, audio_ws, audio_data);
	 
input clk, rst_n;
input [15:0]audio_in_left;
input [15:0]audio_in_right;
input pressed;
output audio_appsel, audio_sysclk, audio_bck, audio_ws;
output reg audio_data;
reg [31:0] audio_out;
wire [4:0]counter;
wire [4:0] clk_counter;
assign audio_appsel=1'b1;
assign audio_sysclk=clk;


assign counter=5'd31-clk_counter;

always @ (pressed)
begin
if(pressed)
audio_data<=audio_out[counter];
else audio_data <= 0;
end
always @(posedge audio_ws or negedge rst_n)

if(~rst_n)
	audio_out = {32'b0};
else
	audio_out = {audio_in_left, audio_in_right};
	

freq_div(
  .clk_out(clk_d), // divided clock output
  .clk_ctl(clk_ctl), // divided clock for seven-segment display scan
  .clk(clk), // clock from the crystal
  .rst_n(rst_n), // low active reset
  .clk_5M(audio_bck),
  .clk_32M(audio_ws),
  .clk_counter(clk_counter)
);

endmodule
