`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:21:49 05/15/2012 
// Design Name: 
// Module Name:    speaker 
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
module speaker(
clk, // clock from crystal
rst_n, // active low reset
audio_appsel, // playing mode selection
audio_sysclk, // control clock for DAC (from crystal)
audio_bck, // bit clock of audio data (5MHz)
audio_ws, // left/right parallel to serial control
audio_data, // serial output audio data
col_n,
row_n,
ftsd_ctl,
pressed,
LCD_DATA, 
LCD_ENABLE,
LCD_RW, 
LCD_RSTN, 
LCD_CS1, 
LCD_CS2, 
LCD_DI
);



// I/O declaration
input clk; // clock from the crystal
input rst_n; // active low reset
output audio_appsel; // playing mode selection
output audio_sysclk; // control clock for DAC (from crystal)
output audio_bck; // bit clock of audio data (5MHz)
output audio_ws; // left/right parallel to serial control
output audio_data; // serial output audio data
output pressed;
input [3:0] col_n; // pressed column index
output [3:0] row_n;  // scanned row index

output  [7:0]  LCD_DATA;
output LCD_ENABLE; 
output  LCD_RW;
output LCD_RSTN;
output  LCD_CS1;
output  LCD_CS2;
output  LCD_DI;


output [3:0] ftsd_ctl; // 14-segment display scan control


// Declare internal nodes
wire [15:0] audio_in_left, audio_in_right;
wire [19:0]out;
wire [3:0]key;
wire clk_debounce;
wire [3:0]in0;
wire led_clk;
freqdiv(
  .clk_40M(clk), // clock from the 40MHz oscillator
  .rst_n(rst_n), // low active reset
  .clk_1(clk_d), // divided clock output
  .clk_debounce(clk_debounce), // clock control for debounce circuit
  .clk_ftsd_scan(ftsd_ctl_en) // divided clock for 14-segment display scan
);

clk_div(.clock_40MHz(clk),.clock_100KHz(led_clk));

keypad_scan(
  .clk(clk_debounce), // scan clock
  .rst_n(rst_n), // active low reset
  .col_n(col_n), // pressed_detected col_numn index
  .row_n(row_n), // scanned row_n index
  .key(key), // returned pressed_detected key
  .pressed(pressed) // whether key_detected pressed_detected (1) or not (0)
);


/*
scan_ctl (
  .in0(in0), // 1st input
  .in1(key), // 2nd input
  .in2(key), // 3rd input
  .in3(key),  // 4th input
  .ftsd_ctl_en(ftsd_ctl_en), // divided clock for scan control
  .ftsd_ctl(ftsd_ctl), // ftsd display control signal
  .ftsd_in(ftsd_in) // output to ftsd display
);
*/
ftsd(
  .in(ftsd_in),  // binary input
  .display(display) // 14-segment display output
);



DoReMi(
.clk(clk_out),
.rst_n(rst_n),
.in(key), 
.out(out),
.in0(in0),
.in1(in1)
);







// Note generation
buzzer_control Ung(
.clk(clk), // clock from crystal
.rst_n(rst_n), // active low reset
.note_div(out), // div for note generation
.audio_left(audio_in_left), // left sound audio
.audio_right(audio_in_right) // right sound audio
);



// Speaker controllor
speaker_control Usc(
.clk(clk), // clock from the crystal
.pressed(pressed),
.rst_n(rst_n), // active low reset
.audio_in_left(audio_in_left), // left channel audio data input
.audio_in_right(audio_in_right), // right channel audio data input
.audio_appsel(audio_appsel), // playing mode selection
.audio_sysclk(audio_sysclk), // control clock for DAC (from crystal)
.audio_bck(audio_bck), // bit clock of audio data (5MHz)
.audio_ws(audio_ws), // left/right parallel to serial control
.audio_data(audio_data) // serial output audio data
);

boo(pressed,led_clk, 1'b1,LCD_DATA, LCD_ENABLE,
       LCD_RW, LCD_RSTN, LCD_CS1, LCD_CS2, LCD_DI);
		 
endmodule



