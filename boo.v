/*********************************** 
 * Show a Flying BOO on LCD.        *
 * Each image is 16x16 bits.        *
 ***********************************/

module boo(pressed,LCD_CLK, RESETN, LCD_DATA, LCD_ENABLE,
       LCD_RW, LCD_RSTN, LCD_CS1, LCD_CS2, LCD_DI);

	input  LCD_CLK;
	input  RESETN;
	input pressed;
	output reg [7:0]  LCD_DATA;
	output LCD_ENABLE; 
	output reg LCD_RW;
	output LCD_RSTN;
	output reg LCD_CS1 = 0;
	output reg LCD_CS2 = 1;
	output reg LCD_DI;

	reg [7:0]  LCD_DATA_NEXT;
	reg LCD_RW_NEXT;
	reg LCD_DI_NEXT;
	
	reg [2:0]  STATE, STATE_NEXT;
	reg [2:0]  X_PAGE, X_PAGE_NEXT;
	reg [5:0]  Y, Y_NEXT;
	reg [1:0]IMAGE, IMAGE_NEXT;
	reg [7:0] PATTERN;
	reg [6:0]  INDEX, INDEX_NEXT;
	reg [15:0] PAUSE_TIME, PAUSE_TIME_NEXT;
	
	reg START, START_NEXT;	
	reg NEW_PAGE, NEW_PAGE_NEXT;
	reg NEW_COL, NEW_COL_NEXT;
	reg [2:0] PAGE_COUNTER, PAGE_COUNTER_NEXT;
	reg [6:0] COL_COUNTER, COL_COUNTER_NEXT;
	reg ENABLE, ENABLE_NEXT;

	parameter Init = 3'd0, Set_StartLine = 3'd1, Clear_Screen = 3'd2, Copy_Image = 3'd3, Pause = 3'd4;
	parameter Delay = 16'b0000_0000_0000_1000;
	
	assign LCD_ENABLE = LCD_CLK & ENABLE; // when ENABLE=1, LCD write can occur at falling edge of clock 
	assign LCD_RSTN = RESETN;
	assign PAUSED_TO_THE_END = (PAUSE_TIME == 0) ? 1 : 0;	
	
	always@(posedge LCD_CLK or negedge RESETN) begin
		if (!RESETN) begin
			STATE    <= Init;
			PAUSE_TIME    <= Delay;
			X_PAGE   <= 0;
			Y  <= 0;
			INDEX 	<=  0;
			LCD_DI   <= 0;
			LCD_RW   <= 0;
			IMAGE    <= 0;
			START <= 0;
			NEW_PAGE <= 1'b0;
			NEW_COL <= 1'b0;
			COL_COUNTER <= 0;
			PAGE_COUNTER <= 0;
			ENABLE <= 1'b0;
		end else begin
			STATE    <= STATE_NEXT;
			PAUSE_TIME    <= PAUSE_TIME_NEXT;
			X_PAGE   <= X_PAGE_NEXT;
			Y  <= Y_NEXT;
			INDEX<= INDEX_NEXT;
			LCD_DI   <= LCD_DI_NEXT;
			LCD_RW   <= LCD_RW_NEXT;
			LCD_DATA <= LCD_DATA_NEXT;
			IMAGE <= IMAGE_NEXT;	
			START <= START_NEXT;	
			NEW_PAGE <= NEW_PAGE_NEXT;
			NEW_COL <= NEW_COL_NEXT;
			COL_COUNTER <= COL_COUNTER_NEXT;
			PAGE_COUNTER <= PAGE_COUNTER_NEXT;
			ENABLE <= ENABLE_NEXT;
		end
	end

	always @(*) begin
		// default assignments
		STATE_NEXT  = STATE;
		PAUSE_TIME_NEXT = PAUSE_TIME;
		X_PAGE_NEXT = X_PAGE;
		Y_NEXT = Y;
		INDEX_NEXT = INDEX;
		LCD_DI_NEXT = LCD_DI;
		LCD_RW_NEXT = LCD_RW;
		LCD_DATA_NEXT = LCD_DATA;	
		IMAGE_NEXT = IMAGE;
		COL_COUNTER_NEXT = COL_COUNTER; 
		PAGE_COUNTER_NEXT = PAGE_COUNTER;
		START_NEXT =	1'b0;	
		NEW_PAGE_NEXT = 1'b0;
		NEW_COL_NEXT = 1'b0;	
		ENABLE_NEXT = 1'b0;
		case(STATE)
			Init: begin  //initial state
				STATE_NEXT =  Set_StartLine;
				// prepare LCD instruction to turn display on
				LCD_DI_NEXT = 1'b0;
				LCD_RW_NEXT = 1'b0;
				LCD_DATA_NEXT = 8'b0011111_1;
				ENABLE_NEXT = 1'b1;
			end
			Set_StartLine: begin //set start line
				STATE_NEXT = Clear_Screen;
				// prepare LCD instruction to set start line
				LCD_DI_NEXT = 1'b0;
				LCD_RW_NEXT = 1'b0;
				LCD_DATA_NEXT = 8'b11_000000; // start line = 0
				ENABLE_NEXT = 1'b1;
				START_NEXT = 1'b1;
			end
			Clear_Screen: begin
				if (START) begin
					NEW_PAGE_NEXT = 1'b1;
					PAGE_COUNTER_NEXT = 0;
					COL_COUNTER_NEXT = 0;
					X_PAGE_NEXT = 0; // set initial X address
					//Y_NEXT = (Y+1)%64; // set initial Y address
				end else	
				if (NEW_PAGE) begin
					// prepare LCD instruction to move to new page
					LCD_DI_NEXT = 1'b0;
					LCD_RW_NEXT = 1'd0;
					LCD_DATA_NEXT = {5'b10111, X_PAGE};
					ENABLE_NEXT = 1'b1;
					NEW_COL_NEXT = 1'b1;
				end else if (NEW_COL) begin 
					// prepare LCD instruction to move to column 0 
					LCD_DI_NEXT    = 1'b0;
					LCD_RW_NEXT    = 1'd0;
					LCD_DATA_NEXT  = 8'b01_000000; // to move to column 0
					ENABLE_NEXT = 1'b1;
				end else if (COL_COUNTER < 64) begin
					// prepare LCD instruction to write 00000000 into display RAM
					LCD_DI_NEXT    = 1'b1;
					LCD_RW_NEXT    = 1'd0;
					LCD_DATA_NEXT  = 8'b00000000;
					ENABLE_NEXT = 1'b1;
					COL_COUNTER_NEXT = COL_COUNTER + 1;
				end else begin
					if (PAGE_COUNTER == 7) begin // last page of screen
						STATE_NEXT = Copy_Image;
						START_NEXT = 1'b1;
					end else begin
						// prepare to change page
						X_PAGE_NEXT  = X_PAGE + 1;
						NEW_PAGE_NEXT = 1'b1;
						PAGE_COUNTER_NEXT = PAGE_COUNTER + 1;
						COL_COUNTER_NEXT = 0;
					end
				end
			end						
			Copy_Image: begin // write image pattern into LCD RAM
				if (START) begin
					NEW_PAGE_NEXT = 1'b1;
					X_PAGE_NEXT = 3;  // image initial X address
					//Y_NEXT = (Y+1)%64; // image initial Y address
					PAGE_COUNTER_NEXT = 0;
					COL_COUNTER_NEXT = 0;
				end else if (NEW_PAGE) begin
					// prepare LCD instruction to move to new page 
					LCD_DI_NEXT = 1'b0;
					LCD_RW_NEXT = 1'b0;
					LCD_DATA_NEXT = {5'b10111, X_PAGE}; 
					ENABLE_NEXT = 1'b1;
					NEW_COL_NEXT = 1'b1;
				end else if (NEW_COL) begin
					// prepare LCD instruction to move to new column
					LCD_DI_NEXT = 1'b0;
					LCD_RW_NEXT = 1'b0;
					LCD_DATA_NEXT = {2'b01,Y};
					ENABLE_NEXT = 1'b1;
				end else if (COL_COUNTER < 32) begin //load image 1 byte at a time, 16 is the width of image
					// prepare LCD instruction to write image data into display RAM
					LCD_DI_NEXT = 1'b1;
					LCD_RW_NEXT = 1'b0;
					LCD_DATA_NEXT = PATTERN;
					ENABLE_NEXT = 1'b1;
					INDEX_NEXT = INDEX + 1;
					COL_COUNTER_NEXT = COL_COUNTER + 1;
				end else begin 
										
					if(pressed)begin					
					IMAGE_NEXT = 2'b01;
					end else IMAGE_NEXT = 2'b00;

					if (PAGE_COUNTER == 3) begin // last page of image
						STATE_NEXT = Pause;
					end else begin
						// prepare to change page
						X_PAGE_NEXT = X_PAGE + 1;		
						NEW_PAGE_NEXT = 1'b1;
						PAGE_COUNTER_NEXT = PAGE_COUNTER + 1;
						COL_COUNTER_NEXT = 0;
					end
				end				
			end
			Pause: begin
				if (PAUSED_TO_THE_END) begin
					STATE_NEXT = Copy_Image;
					START_NEXT = 1'b1;
				end 
				else STATE_NEXT = Pause;
				PAUSE_TIME_NEXT = PAUSE_TIME - 1; 
			end
			default: STATE_NEXT = Init;
		endcase
    end
	
/*******************************
 * Set BOO image patterns		*
 *******************************/
  always @(*)begin
	case (IMAGE)
		2'b00:	// 1st image 	smile
			case (INDEX)
			  8'h00  :  PATTERN = 8'hC0; // upper half of image, wid = 32
			  8'h01  :  PATTERN = 8'h20; // NOT SINGING
			  8'h02  :  PATTERN = 8'h10; //1110_0000
			  8'h03  :  PATTERN = 8'h08;
			  8'h04  :  PATTERN = 8'h04;
			  8'h05  :  PATTERN = 8'h02;
			  8'h06  :  PATTERN = 8'h02;
			  8'h07  :  PATTERN = 8'h02;
			  8'h08  :  PATTERN = 8'h02; 
			  8'h09  :  PATTERN = 8'h01;
			  8'h0A  :  PATTERN = 8'h01;
			  8'h0B  :  PATTERN = 8'h01;
			  8'h0C  :  PATTERN = 8'h01;
			  8'h0D  :  PATTERN = 8'h01;
			  8'h0E  :  PATTERN = 8'h01;
			  8'h0F  :  PATTERN = 8'h03;
			  8'h10  :  PATTERN = 8'h02;
			  8'h11  :  PATTERN = 8'h02;
			  8'h12  :  PATTERN = 8'h04;
			  8'h13  :  PATTERN = 8'h04;
			  8'h14  :  PATTERN = 8'h08;
			  8'h15  :  PATTERN = 8'h30;
			  8'h16  :  PATTERN = 8'hC0;
			  8'h17  :  PATTERN = 8'h00;  
			  8'h18  :  PATTERN = 8'h00; 
			  8'h19  :  PATTERN = 8'h00;
			  8'h1A  :  PATTERN = 8'h00;
			  8'h1B  :  PATTERN = 8'h00;
			  8'h1C  :  PATTERN = 8'h00;
			  8'h1D  :  PATTERN = 8'h00;
			  8'h1E  :  PATTERN = 8'h00;
			  8'h1F  :  PATTERN = 8'h00;
			  8'h20  :  PATTERN = 8'h3F; // middle half of image, wid = 32
			  8'h21  :  PATTERN = 8'hE0;
			  8'h22  :  PATTERN = 8'h20;
			  8'h23  :  PATTERN = 8'h20;
			  8'h24  :  PATTERN = 8'h20;
			  8'h25  :  PATTERN = 8'h30;
			  8'h26  :  PATTERN = 8'h10;
			  8'h27  :  PATTERN = 8'h4F;    
			  8'h28  :  PATTERN = 8'h20; 
			  8'h29  :  PATTERN = 8'h21;
			  8'h2A  :  PATTERN = 8'h22;
			  8'h2B  :  PATTERN = 8'h02;
			  8'h2C  :  PATTERN = 8'h84;
			  8'h2D  :  PATTERN = 8'h88;
			  8'h2E  :  PATTERN = 8'h08;
			  8'h2F  :  PATTERN = 8'h28;
			  8'h30  :  PATTERN = 8'h28;
			  8'h31  :  PATTERN = 8'h28;
			  8'h32  :  PATTERN = 8'h08;
			  8'h33  :  PATTERN = 8'h10;
			  8'h34  :  PATTERN = 8'hE0;
			  8'h35  :  PATTERN = 8'h20;
			  8'h36  :  PATTERN = 8'h1F;
			  8'h37  :  PATTERN = 8'h00;  
			  8'h38  :  PATTERN = 8'h00; 
			  8'h39  :  PATTERN = 8'h00;
			  8'h3A  :  PATTERN = 8'h00;
			  8'h3B  :  PATTERN = 8'h00;
			  8'h3C  :  PATTERN = 8'h00;
			  8'h3D  :  PATTERN = 8'h00;
			  8'h3E  :  PATTERN = 8'h00;
			  8'h3F  :  PATTERN = 8'h00;
			  8'h40  :  PATTERN = 8'h00; // lower half of image, wid = 32
			  8'h41  :  PATTERN = 8'h00;
			  8'h42  :  PATTERN = 8'h01; //1110_0000
			  8'h43  :  PATTERN = 8'h0F;
			  8'h44  :  PATTERN = 8'h18;
			  8'h45  :  PATTERN = 8'h20;
			  8'h46  :  PATTERN = 8'h40;
			  8'h47  :  PATTERN = 8'h40;    
			  8'h48  :  PATTERN = 8'h40; 
			  8'h49  :  PATTERN = 8'h40;
			  8'h4A  :  PATTERN = 8'h48;
			  8'h4B  :  PATTERN = 8'h48;
			  8'h4C  :  PATTERN = 8'h51;
			  8'h4D  :  PATTERN = 8'h50;
			  8'h4E  :  PATTERN = 8'h51;
			  8'h4F  :  PATTERN = 8'h48;
			  8'h50  :  PATTERN = 8'h28;
			  8'h51  :  PATTERN = 8'h20;
			  8'h52  :  PATTERN = 8'h10;
			  8'h53  :  PATTERN = 8'h0C;
			  8'h54  :  PATTERN = 8'h00;
			  8'h55  :  PATTERN = 8'h00;
			  8'h56  :  PATTERN = 8'h00;
			  8'h57  :  PATTERN = 8'h00;
			  8'h58  :  PATTERN = 8'h00;
			  8'h59  :  PATTERN = 8'h00;
			  8'h5A  :  PATTERN = 8'h00;
			  8'h5B  :  PATTERN = 8'h00;
			  8'h5C  :  PATTERN = 8'h00;
			  8'h5D  :  PATTERN = 8'h00;
			  8'h5E  :  PATTERN = 8'h00;
			  8'h5F  :  PATTERN = 8'h00;			  
			   		  
			endcase
		2'b01:	// 2nd image sing
			case (INDEX)
			  8'h00  :  PATTERN = 8'h00; // upper half of image, wid = 32
			  8'h01  :  PATTERN = 8'hC0; // SINGING
			  8'h02  :  PATTERN = 8'h30; //1110_0000
			  8'h03  :  PATTERN = 8'h08;
			  8'h04  :  PATTERN = 8'h04;
			  8'h05  :  PATTERN = 8'h02;
			  8'h06  :  PATTERN = 8'h02;
			  8'h07  :  PATTERN = 8'h01;
			  8'h08  :  PATTERN = 8'h01; 
			  8'h09  :  PATTERN = 8'h01;
			  8'h0A  :  PATTERN = 8'h01;
			  8'h0B  :  PATTERN = 8'h01;
			  8'h0C  :  PATTERN = 8'h01;
			  8'h0D  :  PATTERN = 8'h02;
			  8'h0E  :  PATTERN = 8'h02;
			  8'h0F  :  PATTERN = 8'h02;
			  8'h10  :  PATTERN = 8'h02;
			  8'h11  :  PATTERN = 8'h04;
			  8'h12  :  PATTERN = 8'h04;
			  8'h13  :  PATTERN = 8'h08;
			  8'h14  :  PATTERN = 8'h10;
			  8'h15  :  PATTERN = 8'h60;
			  8'h16  :  PATTERN = 8'h80;
			  8'h17  :  PATTERN = 8'h00;  
			  8'h18  :  PATTERN = 8'h00; 
			  8'h19  :  PATTERN = 8'h00;
			  8'h1A  :  PATTERN = 8'h00;
			  8'h1B  :  PATTERN = 8'h00;
			  8'h1C  :  PATTERN = 8'h00;
			  8'h1D  :  PATTERN = 8'h00;
			  8'h1E  :  PATTERN = 8'h00;
			  8'h1F  :  PATTERN = 8'h00;
			  8'h20  :  PATTERN = 8'h33; // middle half of image, wid = 32
			  8'h21  :  PATTERN = 8'h4D;
			  8'h22  :  PATTERN = 8'hC4;
			  8'h23  :  PATTERN = 8'h04;
			  8'h24  :  PATTERN = 8'h04;
			  8'h25  :  PATTERN = 8'h02;
			  8'h26  :  PATTERN = 8'h01;
			  8'h27  :  PATTERN = 8'h00;    
			  8'h28  :  PATTERN = 8'h08; 
			  8'h29  :  PATTERN = 8'h18;
			  8'h2A  :  PATTERN = 8'h18;
			  8'h2B  :  PATTERN = 8'h09;
			  8'h2C  :  PATTERN = 8'h61;
			  8'h2D  :  PATTERN = 8'h22;
			  8'h2E  :  PATTERN = 8'h62;
			  8'h2F  :  PATTERN = 8'h02;
			  8'h30  :  PATTERN = 8'h0A;
			  8'h31  :  PATTERN = 8'h1A;
			  8'h32  :  PATTERN = 8'h1A;
			  8'h33  :  PATTERN = 8'h02;
			  8'h34  :  PATTERN = 8'h02;
			  8'h35  :  PATTERN = 8'hFE;
			  8'h36  :  PATTERN = 8'h01;
			  8'h37  :  PATTERN = 8'h00;  
			  8'h38  :  PATTERN = 8'h10; 
			  8'h39  :  PATTERN = 8'h38;
			  8'h3A  :  PATTERN = 8'h38;
			  8'h3B  :  PATTERN = 8'h1F;
			  8'h3C  :  PATTERN = 8'h03;
			  8'h3D  :  PATTERN = 8'h01;
			  8'h3E  :  PATTERN = 8'h00;
			  8'h3F  :  PATTERN = 8'h00;
			  8'h40  :  PATTERN = 8'h00; // lower half of image, wid = 32
			  8'h41  :  PATTERN = 8'h00;
			  8'h42  :  PATTERN = 8'h03; //1110_0000
			  8'h43  :  PATTERN = 8'h0C;
			  8'h44  :  PATTERN = 8'h10;
			  8'h45  :  PATTERN = 8'h20;
			  8'h46  :  PATTERN = 8'h20;
			  8'h47  :  PATTERN = 8'h40;    
			  8'h48  :  PATTERN = 8'h4A; 
			  8'h49  :  PATTERN = 8'h4A;
			  8'h4A  :  PATTERN = 8'h52;
			  8'h4B  :  PATTERN = 8'h52;
			  8'h4C  :  PATTERN = 8'h52;
			  8'h4D  :  PATTERN = 8'h52;
			  8'h4E  :  PATTERN = 8'h52;
			  8'h4F  :  PATTERN = 8'h4A;
			  8'h50  :  PATTERN = 8'h26;
			  8'h51  :  PATTERN = 8'h20;
			  8'h52  :  PATTERN = 8'h10;
			  8'h53  :  PATTERN = 8'h10;
			  8'h54  :  PATTERN = 8'h0C;
			  8'h55  :  PATTERN = 8'h03;
			  8'h56  :  PATTERN = 8'h00;
			  8'h57  :  PATTERN = 8'h00;
			  8'h58  :  PATTERN = 8'h00;
			  8'h59  :  PATTERN = 8'h00;
			  8'h5A  :  PATTERN = 8'h00;
			  8'h5B  :  PATTERN = 8'h00;
			  8'h5C  :  PATTERN = 8'h00;
			  8'h5D  :  PATTERN = 8'h00;
			  8'h5E  :  PATTERN = 8'h00;
			  8'h5F  :  PATTERN = 8'h00;		 			  
			endcase
	endcase	
  end

endmodule 
