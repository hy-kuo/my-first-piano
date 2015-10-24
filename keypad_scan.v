`timescale 1ns / 1ps
//************************************************************************
// Filename      : keypad_scan.v
// Author        : Hsi-Pin Ma
// Function      : Keypad Scan 
// Last Modified : Date: 2012-04-03
// Revision      : Revision: 1
// Copyright (c), Laboratory for Reliable Computing (LaRC), EE, NTHU
// All rights reserved
//************************************************************************
`include "global.v"
module keypad_scan(
  clk, // scan clock
  rst_n, // active low reset
  col_n, // pressed_detected col_numn index
  row_n, // scanned row_n index
  key, // returned pressed_detected key
  pressed // whether key_detected pressed_detected (1) or not (0)
);

// Declare I/Os
input clk; // scan clock
input rst_n; // active low reset
input [`KEYPAD_COL_WIDTH-1:0] col_n; // pressed_detected col_numn index
output [`KEYPAD_ROW_WIDTH-1:0] row_n; // scanned row_n index
output [3:0] key; // returned pressed_detected key
output pressed; // whether key_detected pressed_detected (1) or not (0)

// Declare internal nodes
reg [1:0] sel, sel_next; //a repetitive counter for row_n-wise scan
reg [`KEYPAD_ROW_WIDTH-1:0] row_n;
reg [3:0] key;
reg [3:0] key_detected;
reg [3:0] key_next;
reg keypad_state, keypad_state_next;
reg [`KEYPAD_PAUSE_PERIOD_BIT_WIDTH-1:0] pause_delay, pause_delay_next;
reg pressed_detected;
reg pressed_next;
reg pressed;

// A repetitive counter for row_n-wise scan
always @(posedge clk or negedge rst_n)
  if (~rst_n)
    sel = 2'b00;
  else
    sel = sel_next;

always @(sel)
  sel_next = sel + 1'b1;
  
// row-wise scan
always @*
  case (sel)
    2'd0: row_n = 4'b0111;
    2'd1: row_n = 4'b1011;
    2'd2: row_n = 4'b1101;
    2'd3: row_n = 4'b1110;
    default: row_n=4'b1111;
  endcase

// col_numn-wise readout
always @*
begin
  case ({row_n,col_n})
    `KEYPAD_DEC_WIDTH'b0111_0111: // press 'F'
    begin
      key_detected = `KEY_F;
      pressed_detected = `KEYPAD_PRESSED;
    end
    `KEYPAD_DEC_WIDTH'b0111_1011: // press 'E'
    begin
      key_detected = `KEY_E;
      pressed_detected = `KEYPAD_PRESSED;
    end	 
    `KEYPAD_DEC_WIDTH'b0111_1101: // press 'D'
    begin
      key_detected = `KEY_D;
      pressed_detected = `KEYPAD_PRESSED;
    end	 
    `KEYPAD_DEC_WIDTH'b0111_1110: // press 'C'
    begin
      key_detected = `KEY_C;
      pressed_detected = `KEYPAD_PRESSED;
    end
    `KEYPAD_DEC_WIDTH'b1011_0111: // press 'B'
    begin
      key_detected = `KEY_B;
      pressed_detected = `KEYPAD_PRESSED;
    end
    `KEYPAD_DEC_WIDTH'b1011_1011: // press '3'
    begin
      key_detected = `KEY_3;
      pressed_detected = `KEYPAD_PRESSED;
    end	 
    `KEYPAD_DEC_WIDTH'b1011_1101: // press '6'
    begin
      key_detected = `KEY_6;
      pressed_detected = `KEYPAD_PRESSED;
    end	 
    `KEYPAD_DEC_WIDTH'b1011_1110: // press '9'
    begin
      key_detected = `KEY_9;
      pressed_detected = `KEYPAD_PRESSED;
    end	
    `KEYPAD_DEC_WIDTH'b1101_0111: // press 'A'
    begin
      key_detected = `KEY_A;
      pressed_detected = `KEYPAD_PRESSED;
    end
    `KEYPAD_DEC_WIDTH'b1101_1011: // press '2'
    begin
      key_detected = `KEY_2;
      pressed_detected = `KEYPAD_PRESSED;
    end	 
    `KEYPAD_DEC_WIDTH'b1101_1101: // press '5'
    begin
      key_detected = `KEY_5;
      pressed_detected = `KEYPAD_PRESSED;
    end	 
    `KEYPAD_DEC_WIDTH'b1101_1110: // press '`KEYPAD_DEC_WIDTH'
    begin
      key_detected = `KEY_8;
      pressed_detected = `KEYPAD_PRESSED;
    end
    `KEYPAD_DEC_WIDTH'b1110_0111: // press '0'
    begin
      key_detected = `KEY_0;
      pressed_detected = `KEYPAD_PRESSED;
    end
    `KEYPAD_DEC_WIDTH'b1110_1011: // press '1'
    begin
      key_detected = `KEY_1;
      pressed_detected = `KEYPAD_PRESSED;
    end	 
    `KEYPAD_DEC_WIDTH'b1110_1101: // press '4'
    begin
      key_detected = `KEY_4;
      pressed_detected = `KEYPAD_PRESSED;
    end	 
    `KEYPAD_DEC_WIDTH'b1110_1110: // press '7'
    begin
      key_detected = `KEY_7;
      pressed_detected = `KEYPAD_PRESSED;
    end
    default:
    begin
      key_detected = `KEY_0;
      pressed_detected = `KEYPAD_NOT_PRESSED;
    end  			
  endcase
end

// ************************
// FSM for keypad scan
// ************************
// FSM state transition
always @*
  case (keypad_state)
    `SCAN:
     begin
      if (pressed_detected == `KEYPAD_PRESSED)
      begin
        keypad_state_next = `PAUSE;
        pressed_next = `KEYPAD_PRESSED;
        pause_delay_next = `KEYPAD_PAUSE_PERIOD_BIT_WIDTH'b0;
        key_next = key_detected;
      end
      else
      begin
        keypad_state_next = `SCAN;
        pressed_next = `KEYPAD_NOT_PRESSED;
        pause_delay_next = `KEYPAD_PAUSE_PERIOD_BIT_WIDTH'b0;
        key_next = key;
      end
    end
    `PAUSE:
    begin
      if (pause_delay==`KEYPAD_PAUSE_PERIOD_BIT_WIDTH'b1111)
      begin
        keypad_state_next = `SCAN;
        pressed_next = `KEYPAD_NOT_PRESSED;
        pause_delay_next = `KEYPAD_PAUSE_PERIOD_BIT_WIDTH'b0;
        key_next = key;
      end
      else
      begin
        keypad_state_next = `PAUSE;
        pressed_next = `KEYPAD_PRESSED;
		  if (pressed_detected == `KEYPAD_PRESSED)
        pause_delay_next = 4'b0 ;
		  else
		   pause_delay_next = pause_delay + 1'b1;
			
        key_next = key;
      end
    end
    default:
    begin
      keypad_state_next = `SCAN;
      pressed_next = `KEYPAD_NOT_PRESSED;
      pause_delay_next = `KEYPAD_PAUSE_PERIOD_BIT_WIDTH'b0;
      key_next = key;
    end
  endcase

// FSM state register
always @(posedge clk or negedge rst_n)
  if (~rst_n)
    keypad_state <= 1'b0;
  else
    keypad_state <= keypad_state_next;

// Keypad Pause state counter
always @(posedge clk or negedge rst_n)
  if (~rst_n)
    pause_delay <= `KEYPAD_PAUSE_PERIOD_BIT_WIDTH'd0;
  else
    pause_delay <= pause_delay_next;

// pressed indicator
always @(posedge clk or negedge rst_n)
  if (~rst_n)
    pressed <= `KEYPAD_NOT_PRESSED;
  else
    pressed <= pressed_next;

// pressed key indicator
always @(posedge clk or negedge rst_n)
  if (~rst_n)
    key <= `KEY_0;
  else
    key <= key_next;
  
endmodule
