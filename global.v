//**************************************************************************
// Filename      : global.v
// Author        : Hsi-Pin Ma
// Function      : global definition or parameters for the project
// Last Modified : Date: 2009-03-10 
// Revision      : Revision: 1
// Copyright (c), Laboratory for Reliable Computing (LaRC), EE, NTHU
// All rights reserved
//**************************************************************************

// Frequency divider
`define FTSD_SCAN_CTL_BIT_WIDTH 2 // number of bits for ftsd scan control
`define FREQ_DIV_BIT 25

// SSD scan
`define FTSD_BIT_WIDTH 15 // FTSD display control bit width
`define FTSD_DIGIT_NUM 4 // number of FTSD digit
`define FTSD_SCAN_CTL_DISP1 4'b0111 // set the value of FTSD 1
`define FTSD_SCAN_CTL_DISP2 4'b1011 // set the value of FTSD 2
`define FTSD_SCAN_CTL_DISP3 4'b1101 // set the value of FTSD 3
`define FTSD_SCAN_CTL_DISP4 4'b1110 // set the value of FTSD 4
`define FTSD_SCAN_CTL_DISPALL 4'b0000 // set the value of FTSD to ALL

// 14-segment display
`define FTSD_BIT_WIDTH 15 // 14-segment display control
`define FTSD_NUM 4 //number of 14-segment display
`define BCD_BIT_WIDTH 4 // BCD bit width
`define FTSD_ZERO  `FTSD_BIT_WIDTH'b0000_0011_1111_111 //0
`define FTSD_ONE   `FTSD_BIT_WIDTH'b1111_1111_1011_011 //1
`define FTSD_TWO   `FTSD_BIT_WIDTH'b0010_0100_1111_111 //2
`define FTSD_THREE `FTSD_BIT_WIDTH'b0000_1100_1111_111 //3
`define FTSD_FOUR  `FTSD_BIT_WIDTH'b1001_1000_1111_111 //4
`define FTSD_FIVE  `FTSD_BIT_WIDTH'b0100_1000_1111_111 //5
`define FTSD_SIX   `FTSD_BIT_WIDTH'b0100_0000_1111_111 //6
`define FTSD_SEVEN `FTSD_BIT_WIDTH'b0001_1111_1111_111 //7
`define FTSD_EIGHT `FTSD_BIT_WIDTH'b0000_0000_1111_111 //8
`define FTSD_NINE  `FTSD_BIT_WIDTH'b0000_1000_1111_111 //9
`define FTSD_A     `FTSD_BIT_WIDTH'b0001_0000_1111_111 //a
`define FTSD_B     `FTSD_BIT_WIDTH'b1110_0001_1111_011 //b
`define FTSD_C     `FTSD_BIT_WIDTH'b0110_0011_1111_111 //c
`define FTSD_D     `FTSD_BIT_WIDTH'b1000_0100_1111_111 //d
`define FTSD_E     `FTSD_BIT_WIDTH'b0110_0000_1111_111 //e
`define FTSD_F     `FTSD_BIT_WIDTH'b0111_0000_1111_111 //f
`define FTSD_DEF   `FTSD_BIT_WIDTH'b1111_1111_1111_111 //default

// BCD counter

`define BCD_BIT_WIDTH 4 // BCD bit width 
`define ENABLED 1 // ENABLE indicator
`define DISABLED 0 // EIDABLE indicator
`define INCREMENT 1'b1 // increase by 1
`define BCD_ZERO 4'd0 // 1 for BCD
`define BCD_ONE 4'd1 // 1 for BCD
`define BCD_TWO 4'd2 // 2 for BCD
`define BCD_THREE 4'd3 // 2 for BCD
`define BCD_FOUR 4'd4 // 2 for BCD
`define BCD_FIVE 4'd5 // 5 for BCD
`define BCD_SIX 4'd6 // 2 for BCD
`define BCD_SEVEN 4'd7 // 2 for BCD
`define BCD_EIGHT 4'd8 // 2 for BCD
`define BCD_NINE 4'd9 // 9 for BCD
`define BCD_DEF 4'd15 // all 1

// Keypad scan
`define KEYPAD_ROW_WIDTH 4  // Row width of keypad
`define KEYPAD_COL_WIDTH 4  // column width of keypad
`define KEYPAD_DEC_WIDTH 8  // keypad decoding bits (row+col)
`define KEY_0  4'd0 // key '0'
`define KEY_1  4'd1 // key '1'
`define KEY_2  4'd2 // key '2'
`define KEY_3  4'd3 // key '3'
`define KEY_4  4'd4 // key '4'
`define KEY_5  4'd5 // key '5'
`define KEY_6  4'd6 // key '6'
`define KEY_7  4'd7 // key '7'
`define KEY_8  4'd8 // key '`KEYPAD_DEC_WIDTH'
`define KEY_9  4'd9 // key '9'
`define KEY_A  4'd10 // key 'A'
`define KEY_B  4'd11 // key 'B'
`define KEY_C  4'd12 // key 'C'
`define KEY_D  4'd13 // key 'D'
`define KEY_E  4'd14 // key 'E'
`define KEY_F  4'd15 // key 'F'
`define KEYPAD_PRESSED 1'b1 // key pressed indicator
`define KEYPAD_NOT_PRESSED 1'b0 // key not pressed indicator
`define SCAN 1'b1 // Scan state of the keypad readout
`define PAUSE 1'b0 // pause state of the keypad readout
`define KEYPAD_PAUSE_PERIOD_BIT_WIDTH 4 // bit width of the keypad pause period

