/*
Copyright by Henry Ko and Nicola Nicolici
Developed for the Digital Systems Design course (COE3DQ4)
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/

`timescale 1ns/100ps
`default_nettype none
`include "define_state.h" 
module milestone1(
                /////// board clocks                      ////////////
                input logic CLOCK_50_I,                   // 50 MHz clock
                input logic Resetn,

                input logic M1_start,
                output logic M1_end,

				input logic [15:0] M1_SRAM_read_data,
				output logic [15:0] M1_SRAM_write_data,
                output logic [17:0] M1_SRAM_address,
                output logic M1_SRAM_we_n
);

M1_state_type M1_state;

// For VGA
logic [9:0] VGA_red, VGA_green, VGA_blue;
logic [9:0] pixel_X_pos;
logic [9:0] pixel_Y_pos;

// Multipliers
logic [31:0] Mult1_op_1;
logic [31:0] Mult1_op_2,Mult1_result;
logic [63:0] Mult1_result_long;

logic [31:0] Mult2_op_1;
logic [31:0] Mult2_op_2,Mult2_result;
logic [63:0] Mult2_result_long;

logic [31:0] Mult3_op_1;
logic [31:0] Mult3_op_2,Mult3_result;
logic [63:0] Mult3_result_long;

logic [31:0] Mult4_op_1;
logic [31:0] Mult4_op_2,Mult4_result;
logic [63:0] Mult4_result_long;

// Registers

logic [15:0] Reg_U5;
logic [15:0] Reg_U4;
logic [15:0] Reg_U3;
logic [15:0] Reg_U2;
logic [15:0] Reg_U1;
logic [15:0] Reg_U0;
logic signed [31:0] U_odd_sum;

logic [15:0] Reg_V5;
logic [15:0] Reg_V4;
logic [15:0] Reg_V3;
logic [15:0] Reg_V2;
logic [15:0] Reg_V1;
logic [15:0] Reg_V0;
logic signed [31:0] V_odd_sum;

logic signed [31:0] R_odd_sum;
logic signed [31:0] G_odd_sum;
logic signed [31:0] B_odd_sum;

logic signed [31:0] R_even_sum;
logic signed [31:0] G_even_sum;
logic signed [31:0] B_even_sum;

// addresses
logic [17:0] U_OFFSET, V_OFFSET, RGB_OFFSET;
logic [17:0] Y_address, UV_address, RGB_address;

// Buffers
logic [15:0] Y_buff[2:0];
logic [15:0] U_even[2:0];
logic [15:0] V_even[2:0];

logic [31:0] U_odd;
logic [31:0] V_odd;

logic [7:0] R_even[1:0];
logic [7:0] G_even[1:0];
logic [7:0] B_even[1:0];
logic signed [31:0] G_even_temp;

logic [7:0] R_odd[1:0];
logic [7:0] G_odd[1:0];
logic [7:0] B_odd[1:0];
logic signed [31:0] G_odd_temp;

// ------------------------------------------
logic [7:0] ROW_counter;
logic [8:0] COL_counter;

always_ff @ (posedge CLOCK_50_I or negedge Resetn) begin
	if (Resetn == 1'b0) begin
			M1_state <= S_M1_IDLE;
            M1_end <= 1'b0;
            M1_SRAM_we_n <= 1'b1;

            U_OFFSET <= 18'd38400;
            V_OFFSET <= 18'd57600;
            RGB_OFFSET <= 18'd146944;
                
            Y_address <= 18'd0;
            UV_address <= 18'd0;
            RGB_address <= 18'd0;                
               
            Reg_U5 <= 16'd0;
            Reg_U4 <= 16'd0;
            Reg_U3 <= 16'd0;
            Reg_U2 <= 16'd0;
            Reg_U1 <= 16'd0;
            Reg_U0 <= 16'd0;

            Reg_V5 <= 16'd0;
            Reg_V4 <= 16'd0;
            Reg_V3 <= 16'd0;
            Reg_V2 <= 16'd0;
            Reg_V1 <= 16'd0;
            Reg_V0 <= 16'd0;

			Y_buff[2] <= 16'd0;
			Y_buff[1] <= 16'd0;
			Y_buff[0] <= 16'd0;
			U_even[2] <= 16'd0;
			U_even[1] <= 16'd0;
			U_even[0] <= 16'd0;
			V_even[2] <= 16'd0;
			V_even[1] <= 16'd0;
			V_even[0] <= 16'd0;

			U_odd <= 32'd0;
			V_odd <= 32'd0;

			R_even[1] <= 8'd0;
			R_even[0] <= 8'd0;
			G_even[1] <= 8'd0;
			G_even[0] <= 8'd0;
			B_even[1] <= 8'd0;
			B_even[0] <= 8'd0;

			R_odd[1] <= 8'd0;
			R_odd[0] <= 8'd0;				
			G_odd[1] <= 8'd0;
			G_odd[0] <= 8'd0;				
			B_odd[1] <= 8'd0;
			B_odd[0] <= 8'd0;				
				
			ROW_counter <= 0;
			COL_counter <= 0;

	end else begin
		case(M1_state)
				S_M1_IDLE: begin
					            M1_end <= 1'b0;
            M1_SRAM_we_n <= 1'b1;

            U_OFFSET <= 18'd38400;
            V_OFFSET <= 18'd57600;
            RGB_OFFSET <= 18'd146944;
                
            Y_address <= 18'd0;
            UV_address <= 18'd0;
            RGB_address <= 18'd0;                
               
            Reg_U5 <= 16'd0;
            Reg_U4 <= 16'd0;
            Reg_U3 <= 16'd0;
            Reg_U2 <= 16'd0;
            Reg_U1 <= 16'd0;
            Reg_U0 <= 16'd0;

            Reg_V5 <= 16'd0;
            Reg_V4 <= 16'd0;
            Reg_V3 <= 16'd0;
            Reg_V2 <= 16'd0;
            Reg_V1 <= 16'd0;
            Reg_V0 <= 16'd0;

			Y_buff[2] <= 16'd0;
			Y_buff[1] <= 16'd0;
			Y_buff[0] <= 16'd0;
			U_even[2] <= 16'd0;
			U_even[1] <= 16'd0;
			U_even[0] <= 16'd0;
			V_even[2] <= 16'd0;
			V_even[1] <= 16'd0;
			V_even[0] <= 16'd0;

			U_odd <= 32'd0;
			V_odd <= 32'd0;

			R_even[1] <= 8'd0;
			R_even[0] <= 8'd0;
			G_even[1] <= 8'd0;
			G_even[0] <= 8'd0;
			B_even[1] <= 8'd0;
			B_even[0] <= 8'd0;

			R_odd[1] <= 8'd0;
			R_odd[0] <= 8'd0;				
			G_odd[1] <= 8'd0;
			G_odd[0] <= 8'd0;				
			B_odd[1] <= 8'd0;
			B_odd[0] <= 8'd0;				
				
			ROW_counter <= 0;
			COL_counter <= 0;
			
					M1_SRAM_we_n <= 1'b1;
					COL_counter <= 0;
					ROW_counter <= 0;
					Y_address <= 18'd0;
					UV_address <= 18'd0;
					RGB_address <= 18'd0;					
					if ((M1_start == 1) && (M1_end == 0)) begin
						M1_state <= S_LOAD_0;
					end
					else begin
						M1_state <= S_M1_IDLE;
					end
					
					
				end
				S_LOAD_0: begin
					M1_SRAM_we_n <= 1'd1; //prepare to read	
					COL_counter <= 0;
					M1_SRAM_address <= U_OFFSET + UV_address;	
					
                    M1_state <= S_LOAD_1;                
				end
				S_LOAD_1: begin
                    M1_SRAM_address <= V_OFFSET + UV_address;
                    UV_address <= UV_address + 1; 	
					
					M1_state <= S_LOAD_2;
				end
				S_LOAD_2: begin
					M1_SRAM_address <= U_OFFSET + UV_address;	
					
                    M1_state <= S_LOAD_3;
                end
                S_LOAD_3: begin
					M1_SRAM_address <= V_OFFSET + UV_address;
					UV_address <= UV_address + 1;

					U_even[0] <= M1_SRAM_read_data;
					U_even[1] <= M1_SRAM_read_data;
					U_even[2] <= M1_SRAM_read_data;					

					M1_state <= S_LOAD_4;
                end
                S_LOAD_4: begin
					M1_SRAM_address <= U_OFFSET + UV_address;
					
					V_even[0] <= M1_SRAM_read_data;
					V_even[1] <= M1_SRAM_read_data;
					V_even[2] <= M1_SRAM_read_data;					

                    M1_state <= S_LOAD_5;
                end
                S_LOAD_5: begin  
					M1_SRAM_address <= V_OFFSET + UV_address;
					UV_address <= UV_address + 1;
					
					U_even[0] <= U_even[1];
					U_even[1] <= U_even[2];
					U_even[2] <= M1_SRAM_read_data;                

                    M1_state <= S_LOAD_6;
                end
                S_LOAD_6: begin
					M1_SRAM_address <= Y_address;
					Y_address <= Y_address + 1;		
					
					V_even[0] <= V_even[1];
					V_even[1] <= V_even[2];
					V_even[2] <= M1_SRAM_read_data;				
                    					
					M1_state <= S_LOAD_7;
                end
                S_LOAD_7: begin
					M1_SRAM_address <= Y_address;
					Y_address <= Y_address + 1;	
					
					U_even[0] <= U_even[1];
					U_even[1] <= U_even[2];
					U_even[2] <= M1_SRAM_read_data;
					
					M1_state <= S_LOAD_8;
                end
				S_LOAD_8: begin
					M1_SRAM_address <= Y_address;
					Y_address <= Y_address + 1;		
					
					V_even[0] <= V_even[1];
					V_even[1] <= V_even[2];
					V_even[2] <= M1_SRAM_read_data;	
					
					M1_state <= S_LOAD_9;
				end
				S_LOAD_9: begin
					Y_buff[0] <= M1_SRAM_read_data;
					Y_buff[1] <= M1_SRAM_read_data;
					Y_buff[2] <= M1_SRAM_read_data;
					//--- Mult 1 --------------------------------------
						Reg_U0 <= U_even[1][15:8];
                        Reg_U1 <= U_even[0][7:0];
                        Reg_U2 <= U_even[0][15:8];
                        Reg_U3 <= U_even[0][15:8];
                        Reg_U4 <= U_even[0][15:8];
                        Reg_U5 <= U_even[0][15:8];
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= V_even[1][15:8];
                        Reg_V1 <= V_even[0][7:0];
                        Reg_V2 <= V_even[0][15:8];
                        Reg_V3 <= V_even[0][15:8];
                        Reg_V4 <= V_even[0][15:8];
                        Reg_V5 <= V_even[0][15:8];
                    //--- Mult 3 --------------------------------------
					
					M1_state <= S_LOAD_10;
				end
                S_LOAD_10: begin
					Y_buff[0] <= Y_buff[1];
					Y_buff[1] <= Y_buff[2];
					Y_buff[2] <= M1_SRAM_read_data;					
					//--- Mult 1 --------------------------------------
						Reg_U0 <= U_even[1][7:0];
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd21;
                    U_odd_sum  <= 32'd128;
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= V_even[1][7:0];
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd21;
                    V_odd_sum  <= 32'd128;
                    //--- Mult 3 --------------------------------------
                  
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= Y_buff[1][15:8] - 32'd16;
                    Mult4_op_1 <= 32'd76284;
                    R_even_sum <= 0;
                    G_even_sum <= 0;
                    B_even_sum <= 0;
                    
					M1_state <= S_LOAD_11;
                end
                S_LOAD_11: begin
					Y_buff[0] <= Y_buff[1];
					Y_buff[1] <= Y_buff[2];
					Y_buff[2] <= M1_SRAM_read_data;					
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd52;
                    U_odd_sum  <= U_odd_sum + Mult1_result;                    
					//--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd52;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------                    
                   
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= U_even[0][15:8] - 32'd128;
                    Mult4_op_1 <= 32'd25624;
                    R_even_sum <= R_even_sum + Mult4_result;
                    G_even_sum <= G_even_sum + Mult4_result;
                    B_even_sum <= B_even_sum + Mult4_result;
                    
					M1_state <= S_LOAD_12;
                end
                S_LOAD_12: begin
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd159;
                    U_odd_sum  <= U_odd_sum - Mult1_result;                    
					//--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd159;
                    V_odd_sum  <= V_odd_sum - Mult2_result;
                    //--- Mult 3 --------------------------------------                    

                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= U_even[0][15:8] - 32'd128;
                    Mult4_op_1 <= 32'd132251;
                    G_even_sum <= G_even_sum - Mult4_result;
					
					M1_state <= S_LOAD_13;
                end
                S_LOAD_13: begin
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd159;
                    U_odd_sum  <= U_odd_sum + Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd159;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------
                   
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= V_even[0][15:8] - 32'd128;
                    Mult4_op_1 <= 32'd104595;
                    B_even_sum <= B_even_sum + Mult4_result;
                    
					M1_state <= S_LOAD_14;
                end
                S_LOAD_14: begin
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd52;
                    U_odd_sum  <= U_odd_sum + Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd52;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------

                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= V_even[0][15:8] - 32'd128;
                    Mult4_op_1 <= 32'd53281;
                    R_even_sum <= R_even_sum + Mult4_result;
                    
					M1_state <= S_LOAD_15;
                end
                S_LOAD_15: begin
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd21;
                    U_odd_sum  <= U_odd_sum - Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd21;
                    V_odd_sum  <= V_odd_sum - Mult2_result;
                    //--- Mult 3 --------------------------------------

                    //--- Mult 4 --------------------------------------
					if (R_even_sum[31]==1'b1) begin R_even[1] <= 8'd0; end
					else if (R_even_sum[30:24]!= 0) begin R_even[1] <= 8'd255; end
					else begin R_even[1] <= R_even_sum >>> 16; end
					
					G_even_temp = G_even_sum - Mult4_result;
					if (G_even_temp[31]==1'b1) begin G_even[1] <= 8'd0; end
					else if (G_even_temp[30:24]!= 0) begin G_even[1] <= 8'd255; end
					else begin G_even[1] <= G_even_temp >>> 16; end

					if (B_even_sum[31]==1'b1) begin B_even[1] <= 8'd0; end
					else if (B_even_sum[30:24]!= 0) begin B_even[1] <= 8'd255; end					
					else begin B_even[1] <= B_even_sum >>> 16; end
					
					M1_state <= S_LOAD_16;
                end
                S_LOAD_16: begin
					//--- Mult 1 --------------------------------------
						Reg_U0 <= U_even[2][15:8];
                        Reg_U1 <= Reg_U5;
                        Reg_U2 <= Reg_U0;
                        Reg_U3 <= Reg_U1;
                        Reg_U4 <= Reg_U2;
                        Reg_U5 <= Reg_U3;
                    Mult1_op_2 <= Reg_U3;
                    Mult1_op_1 <= 32'd21;
                    U_odd <= (U_odd_sum + Mult1_result) >>> 8;
                    U_odd_sum  <= 32'd128;
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= V_even[2][15:8];
                        Reg_V1 <= Reg_V5;
                        Reg_V2 <= Reg_V0;
                        Reg_V3 <= Reg_V1;
                        Reg_V4 <= Reg_V2;
                        Reg_V5 <= Reg_V3;
                    Mult2_op_2 <= Reg_V3;
                    Mult2_op_1 <= 32'd21;
                    V_odd <= (V_odd_sum + Mult2_result) >>> 8;
                    V_odd_sum  <= 32'd128;
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= Y_buff[0][7:0] - 32'd16;
                    Mult3_op_1 <= 32'd76284;
                    R_odd_sum  <= 0;
                    G_odd_sum  <= 0;
                    B_odd_sum  <= 0;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= Y_buff[1][15:8] - 32'd16;
                    Mult4_op_1 <= 32'd76284;
                    R_even_sum <= 0;
                    G_even_sum <= 0;
                    B_even_sum <= 0;
                    
					M1_state <= S_LOAD_17;
                end
                S_LOAD_17: begin
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd52;
                    U_odd_sum  <= U_odd_sum + Mult1_result;                    
					//--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd52;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------                    
                    Mult3_op_2 <= U_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd25624;
                    R_odd_sum  <= R_odd_sum + Mult3_result;
                    G_odd_sum  <= G_odd_sum + Mult3_result;
                    B_odd_sum  <= B_odd_sum + Mult3_result;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= U_even[0][7:0] - 32'd128;
                    Mult4_op_1 <= 32'd25624;
                    R_even_sum <= R_even_sum + Mult4_result;
                    G_even_sum <= G_even_sum + Mult4_result;
                    B_even_sum <= B_even_sum + Mult4_result;
                    
					M1_state <= S_LOAD_18;
                end
                S_LOAD_18: begin
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd159;
                    U_odd_sum  <= U_odd_sum - Mult1_result;                    
					//--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd159;
                    V_odd_sum  <= V_odd_sum - Mult2_result;
                    //--- Mult 3 --------------------------------------                    
                    Mult3_op_2 <= U_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd132251;
                    G_odd_sum  <= G_odd_sum - Mult3_result;
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= U_even[0][7:0] - 32'd128;
                    Mult4_op_1 <= 32'd132251;
                    G_even_sum <= G_even_sum - Mult4_result;
					                    
					M1_state <= S_LOAD_19;
                end
                S_LOAD_19: begin
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd159;
                    U_odd_sum  <= U_odd_sum + Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd159;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= V_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd104595;
                    B_odd_sum  <= B_odd_sum + Mult3_result;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= V_even[0][7:0] - 32'd128;
                    Mult4_op_1 <= 32'd104595;
                    B_even_sum <= B_even_sum + Mult4_result;
                    
					M1_state <= S_LOAD_20;
                end
                S_LOAD_20: begin
					M1_SRAM_address <= Y_address;
					Y_address <= Y_address + 1;
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd52;
                    U_odd_sum  <= U_odd_sum + Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd52;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= V_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd53281;
                    R_odd_sum  <= R_odd_sum + Mult3_result;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= V_even[0][7:0] - 32'd128;
                    Mult4_op_1 <= 32'd53281;
                    R_even_sum <= R_even_sum + Mult4_result;
                    
					M1_state <= S_LOAD_21;
                end
                S_LOAD_21: begin
					M1_SRAM_address <= U_OFFSET + UV_address;
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd21;
                    U_odd_sum  <= U_odd_sum - Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd21;
                    V_odd_sum  <= V_odd_sum - Mult2_result;
                    //--- Mult 3 --------------------------------------
					if (R_odd_sum[31]==1'b1) begin R_odd[1] <= 8'd0; end
					else if (R_odd_sum[30:24]!= 0) begin R_odd[1] <= 8'd255; end
					else begin R_odd[1] <= R_odd_sum >>> 16; end
					
					G_odd_temp = G_odd_sum - Mult3_result;
					if (G_odd_temp[31]==1'b1) begin G_odd[1] <= 8'd0; end
					else if (G_odd_temp[30:24]!= 0) begin G_odd[1] <= 8'd255; end
					else begin G_odd[1] <= G_odd_temp >>> 16; end

					if (B_odd_sum[31]==1'b1) begin B_odd[1] <= 8'd0; end
					else if (B_odd_sum[30:24]!= 0) begin B_odd[1] <= 8'd255; end					
					else begin B_odd[1] <= B_odd_sum >>> 16; end						
                    //--- Mult 4 --------------------------------------
                    R_even[0] <= R_even[1];
                    G_even[0] <= G_even[1];
                    B_even[0] <= B_even[1];
					
					if (R_even_sum[31]==1'b1) begin R_even[1] <= 8'd0; end
					else if (R_even_sum[30:24]!= 0) begin R_even[1] <= 8'd255; end
					else begin R_even[1] <= R_even_sum >>> 16; end
					
					G_even_temp = G_even_sum - Mult4_result;
					if (G_even_temp[31]==1'b1) begin G_even[1] <= 8'd0; end
					else if (G_even_temp[30:24]!= 0) begin G_even[1] <= 8'd255; end
					else begin G_even[1] <= G_even_temp >>> 16; end

					if (B_even_sum[31]==1'b1) begin B_even[1] <= 8'd0; end
					else if (B_even_sum[30:24]!= 0) begin B_even[1] <= 8'd255; end					
					else begin B_even[1] <= B_even_sum >>> 16; end				
	
					M1_state <= S_LOAD_22;
                end
				S_LOAD_22: begin
					M1_SRAM_address <= V_OFFSET + UV_address;
					UV_address <= UV_address + 1;
					
					M1_state <= S_COMMON_0;
				end
                S_COMMON_0: begin
					M1_SRAM_address <= Y_address;
					Y_address <= Y_address + 1;					
					//-------------------------------------------------					
					Y_buff[0] <= Y_buff[1];
					Y_buff[1] <= Y_buff[2];
					Y_buff[2] <= M1_SRAM_read_data;					
					//--- Mult 1 --------------------------------------
						Reg_U0 <= U_even[2][7:0];
                        Reg_U1 <= Reg_U5;
                        Reg_U2 <= Reg_U0;
                        Reg_U3 <= Reg_U1;
                        Reg_U4 <= Reg_U2;
                        Reg_U5 <= Reg_U3;
                    Mult1_op_2 <= Reg_U3;
                    Mult1_op_1 <= 32'd21;
                    U_odd <= (U_odd_sum + Mult1_result) >>> 8;
                    U_odd_sum  <= 32'd128;
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= V_even[2][7:0];
                        Reg_V1 <= Reg_V5;
                        Reg_V2 <= Reg_V0;
                        Reg_V3 <= Reg_V1;
                        Reg_V4 <= Reg_V2;
                        Reg_V5 <= Reg_V3;
                    Mult2_op_2 <= Reg_V3;
                    Mult2_op_1 <= 32'd21;
                    V_odd <= (V_odd_sum + Mult2_result) >>> 8;
                    V_odd_sum  <= 32'd128;
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= Y_buff[1][7:0] - 32'd16;
                    Mult3_op_1 <= 32'd76284;
                    R_odd_sum  <= 0;
                    G_odd_sum  <= 0;
                    B_odd_sum  <= 0;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= Y_buff[2][15:8] - 32'd16;
                    Mult4_op_1 <= 32'd76284;
                    R_even_sum <= 0;
                    G_even_sum <= 0;
                    B_even_sum <= 0;
				
					M1_state <= S_COMMON_1;
                end                
                S_COMMON_1: begin
					U_even[0] <= U_even[1];
					U_even[1] <= U_even[2];
					U_even[2] <= M1_SRAM_read_data;					
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd52;
                    U_odd_sum  <= U_odd_sum + Mult1_result;                    
					//--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd52;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------                    
                    Mult3_op_2 <= U_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd25624;
                    R_odd_sum  <= R_odd_sum + Mult3_result;
                    G_odd_sum  <= G_odd_sum + Mult3_result;
                    B_odd_sum  <= B_odd_sum + Mult3_result;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= U_even[1][15:8] - 32'd128;
                    Mult4_op_1 <= 32'd25624;
                    R_even_sum <= R_even_sum + Mult4_result;
                    G_even_sum <= G_even_sum + Mult4_result;
                    B_even_sum <= B_even_sum + Mult4_result;
                    
					M1_state <= S_COMMON_2;
                end
                S_COMMON_2: begin
					V_even[0] <= V_even[1];
					V_even[1] <= V_even[2];
					V_even[2] <= M1_SRAM_read_data;					
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd159;
                    U_odd_sum  <= U_odd_sum - Mult1_result;                    
					//--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd159;
                    V_odd_sum  <= V_odd_sum - Mult2_result;
                    //--- Mult 3 --------------------------------------                    
                    Mult3_op_2 <= U_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd132251;
                    G_odd_sum  <= G_odd_sum - Mult3_result;
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= U_even[0][15:8] - 32'd128;
                    Mult4_op_1 <= 32'd132251;
                    G_even_sum <= G_even_sum - Mult4_result;
					
					M1_state <= S_COMMON_3;
                end
                S_COMMON_3: begin
					Y_buff[0] <= Y_buff[1];
					Y_buff[1] <= Y_buff[2];
					Y_buff[2] <= M1_SRAM_read_data;
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd159;
                    U_odd_sum  <= U_odd_sum + Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd159;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= V_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd104595;
                    B_odd_sum  <= B_odd_sum + Mult3_result;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= V_even[0][15:8] - 32'd128;
                    Mult4_op_1 <= 32'd104595;
                    B_even_sum <= B_even_sum + Mult4_result;
                    
					M1_state <= S_COMMON_4;
                end
                S_COMMON_4: begin
					M1_SRAM_we_n <= 1'd0; //prepare to write				
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;
					M1_SRAM_write_data <= {R_even[0],G_even[0]};
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd52;
                    U_odd_sum  <= U_odd_sum + Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd52;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= V_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd53281;
                    R_odd_sum  <= R_odd_sum + Mult3_result;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= V_even[0][15:8] - 32'd128;
                    Mult4_op_1 <= 32'd53281;
                    R_even_sum <= R_even_sum + Mult4_result;
                    
					M1_state <= S_COMMON_5;
                end
                S_COMMON_5: begin
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;
					M1_SRAM_write_data <= {B_even[0],R_odd[1]};
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd21;
                    U_odd_sum  <= U_odd_sum - Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd21;
                    V_odd_sum  <= V_odd_sum - Mult2_result;
                    //--- Mult 3 --------------------------------------
                    R_odd[0] <= R_odd[1];
                    G_odd[0] <= G_odd[1];
                    B_odd[0] <= B_odd[1];

					if (R_odd_sum[31]==1'b1) begin R_odd[1] <= 8'd0; end
					else if (R_odd_sum[30:24]!= 0) begin R_odd[1] <= 8'd255; end
					else begin R_odd[1] <= R_odd_sum >>> 16; end
					
					G_odd_temp = G_odd_sum - Mult3_result;
					if (G_odd_temp[31]==1'b1) begin G_odd[1] <= 8'd0; end
					else if (G_odd_temp[30:24]!= 0) begin G_odd[1] <= 8'd255; end
					else begin G_odd[1] <= G_odd_temp >>> 16; end

					if (B_odd_sum[31]==1'b1) begin B_odd[1] <= 8'd0; end
					else if (B_odd_sum[30:24]!= 0) begin B_odd[1] <= 8'd255; end					
					else begin B_odd[1] <= B_odd_sum >>> 16; end	

                    //--- Mult 4 --------------------------------------
                    R_even[0] <= R_even[1];
                    G_even[0] <= G_even[1];
                    B_even[0] <= B_even[1];
					
					if (R_even_sum[31]==1'b1) begin R_even[1] <= 8'd0; end
					else if (R_even_sum[30:24]!= 0) begin R_even[1] <= 8'd255; end
					else begin R_even[1] <= R_even_sum >>> 16; end
					
					G_even_temp = G_even_sum - Mult4_result;
					if (G_even_temp[31]==1'b1) begin G_even[1] <= 8'd0; end
					else if (G_even_temp[30:24]!= 0) begin G_even[1] <= 8'd255; end
					else begin G_even[1] <= G_even_temp >>> 16; end

					if (B_even_sum[31]==1'b1) begin B_even[1] <= 8'd0; end
					else if (B_even_sum[30:24]!= 0) begin B_even[1] <= 8'd255; end					
					else begin B_even[1] <= B_even_sum >>> 16; end						
										
					M1_state <= S_COMMON_6;
                end
                S_COMMON_6: begin
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;			
					M1_SRAM_write_data <= {G_odd[0][7:0],B_odd[0][7:0]};
					//--- Mult 1 --------------------------------------
						Reg_U0 <= U_even[2][15:8];
                        Reg_U1 <= Reg_U5;
                        Reg_U2 <= Reg_U0;
                        Reg_U3 <= Reg_U1;
                        Reg_U4 <= Reg_U2;
                        Reg_U5 <= Reg_U3;
                    Mult1_op_2 <= Reg_U3;
                    Mult1_op_1 <= 32'd21;
                    U_odd <= (U_odd_sum + Mult1_result) >>> 8;
                    U_odd_sum  <= 32'd128;
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= V_even[2][15:8];
                        Reg_V1 <= Reg_V5;
                        Reg_V2 <= Reg_V0;
                        Reg_V3 <= Reg_V1;
                        Reg_V4 <= Reg_V2;
                        Reg_V5 <= Reg_V3;
                    Mult2_op_2 <= Reg_V3;
                    Mult2_op_1 <= 32'd21;
                    V_odd <= (V_odd_sum + Mult2_result) >>> 8;
                    V_odd_sum  <= 32'd128;
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= Y_buff[0][7:0] - 32'd16;
                    Mult3_op_1 <= 32'd76284;
                    R_odd_sum  <= 0;
                    G_odd_sum  <= 0;
                    B_odd_sum  <= 0;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= Y_buff[1][15:8] - 32'd16;
                    Mult4_op_1 <= 32'd76284;
                    R_even_sum <= 0;
                    G_even_sum <= 0;
                    B_even_sum <= 0;
                    
					M1_state <= S_COMMON_7;
                end
                S_COMMON_7: begin
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;					
					M1_SRAM_write_data <= {R_even[0],G_even[0]};
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd52;
                    U_odd_sum  <= U_odd_sum + Mult1_result;                    
					//--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd52;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------                    
                    Mult3_op_2 <= U_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd25624;
                    R_odd_sum  <= R_odd_sum + Mult3_result;
                    G_odd_sum  <= G_odd_sum + Mult3_result;
                    B_odd_sum  <= B_odd_sum + Mult3_result;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= U_even[0][7:0] - 32'd128;
                    Mult4_op_1 <= 32'd25624;
                    R_even_sum <= R_even_sum + Mult4_result;
                    G_even_sum <= G_even_sum + Mult4_result;
                    B_even_sum <= B_even_sum + Mult4_result;
                    
					M1_state <= S_COMMON_8;
                end
                S_COMMON_8: begin
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;					
					M1_SRAM_write_data <= {B_even[0],R_odd[1]};
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd159;
                    U_odd_sum  <= U_odd_sum - Mult1_result;                    
					//--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd159;
                    V_odd_sum  <= V_odd_sum - Mult2_result;
                    //--- Mult 3 --------------------------------------                    
                    Mult3_op_2 <= U_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd132251;
                    G_odd_sum  <= G_odd_sum - Mult3_result;
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= U_even[0][7:0] - 32'd128;
                    Mult4_op_1 <= 32'd132251;
                    G_even_sum <= G_even_sum - Mult4_result;
					                    
					M1_state <= S_COMMON_9;
                end
                S_COMMON_9: begin
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;				
					M1_SRAM_write_data <= {G_odd[1],B_odd[1]};
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd159;
                    U_odd_sum  <= U_odd_sum + Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd159;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= V_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd104595;
                    B_odd_sum  <= B_odd_sum + Mult3_result;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= V_even[0][7:0] - 32'd128;
                    Mult4_op_1 <= 32'd104595;
                    B_even_sum <= B_even_sum + Mult4_result;
                    
					M1_state <= S_COMMON_10;
                end
                S_COMMON_10: begin
					M1_SRAM_we_n <= 1'd1; //prepare to read				
					M1_SRAM_address <= Y_address;
					Y_address <= Y_address + 1;
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd52;
                    U_odd_sum  <= U_odd_sum + Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd52;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= V_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd53281;
                    R_odd_sum  <= R_odd_sum + Mult3_result;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= V_even[0][7:0] - 32'd128;
                    Mult4_op_1 <= 32'd53281;
                    R_even_sum <= R_even_sum + Mult4_result;
                    
					M1_state <= S_COMMON_11;
                end
                S_COMMON_11: begin
					M1_SRAM_address <= U_OFFSET + UV_address;
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd21;
                    U_odd_sum  <= U_odd_sum - Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd21;
                    V_odd_sum  <= V_odd_sum - Mult2_result;
                    //--- Mult 3 --------------------------------------
					R_odd[0] <= R_odd[1];
                    G_odd[0] <= G_odd[1];
                    B_odd[0] <= B_odd[1];
				
					if (R_odd_sum[31]==1'b1) begin R_odd[1] <= 8'd0; end
					else if (R_odd_sum[30:24]!= 0) begin R_odd[1] <= 8'd255; end
					else begin R_odd[1] <= R_odd_sum >>> 16; end
					
					G_odd_temp = G_odd_sum - Mult3_result;
					if (G_odd_temp[31]==1'b1) begin G_odd[1] <= 8'd0; end
					else if (G_odd_temp[30:24]!= 0) begin G_odd[1] <= 8'd255; end
					else begin G_odd[1] <= G_odd_temp >>> 16; end

					if (B_odd_sum[31]==1'b1) begin B_odd[1] <= 8'd0; end
					else if (B_odd_sum[30:24]!= 0) begin B_odd[1] <= 8'd255; end					
					else begin B_odd[1] <= B_odd_sum >>> 16; end	
					
                    //--- Mult 4 --------------------------------------
                    R_even[0] <= R_even[1];
                    G_even[0] <= G_even[1];
                    B_even[0] <= B_even[1];
					
					if (R_even_sum[31]==1'b1) begin R_even[1] <= 8'd0; end
					else if (R_even_sum[30:24]!= 0) begin R_even[1] <= 8'd255; end
					else begin R_even[1] <= R_even_sum >>> 16; end
					
					G_even_temp = G_even_sum - Mult4_result;
					if (G_even_temp[31]==1'b1) begin G_even[1] <= 8'd0; end
					else if (G_even_temp[30:24]!= 0) begin G_even[1] <= 8'd255; end
					else begin G_even[1] <= G_even_temp >>> 16; end

					if (B_even_sum[31]==1'b1) begin B_even[1] <= 8'd0; end
					else if (B_even_sum[30:24]!= 0) begin B_even[1] <= 8'd255; end					
					else begin B_even[1] <= B_even_sum >>> 16; end	
					
					M1_state <= S_COMMON_12;
				end	
				S_COMMON_12: begin
					M1_SRAM_address <= V_OFFSET + UV_address;
					UV_address <= UV_address + 1;
                    if (COL_counter < 461) begin 
						M1_state <= S_COMMON_0;
					end else begin
						M1_state <= S_LEAD_OUT_0;
					end				
				end
				S_LEAD_OUT_0: begin
                    M1_SRAM_address <= Y_address;
					Y_address <= Y_address + 1;		
					UV_address <= UV_address - 1; // to compensate the extra increment in the last common case
					//-------------------------------------------------					
					Y_buff[0] <= Y_buff[1];
					Y_buff[1] <= Y_buff[2];
					Y_buff[2] <= M1_SRAM_read_data;					
					//--- Mult 1 --------------------------------------
						Reg_U0 <= U_even[2][7:0];
                        Reg_U1 <= Reg_U5;
                        Reg_U2 <= Reg_U0;
                        Reg_U3 <= Reg_U1;
                        Reg_U4 <= Reg_U2;
                        Reg_U5 <= Reg_U3;
                    Mult1_op_2 <= Reg_U3;
                    Mult1_op_1 <= 32'd21;
                    U_odd <= (U_odd_sum + Mult1_result) >>> 8;
                    U_odd_sum  <= 32'd128;
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= V_even[2][7:0];
                        Reg_V1 <= Reg_V5;
                        Reg_V2 <= Reg_V0;
                        Reg_V3 <= Reg_V1;
                        Reg_V4 <= Reg_V2;
                        Reg_V5 <= Reg_V3;
                    Mult2_op_2 <= Reg_V3;
                    Mult2_op_1 <= 32'd21;
                    V_odd <= (V_odd_sum + Mult2_result) >>> 8;
                    V_odd_sum  <= 32'd128;
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= Y_buff[1][7:0] - 32'd16;
                    Mult3_op_1 <= 32'd76284;
                    R_odd_sum  <= 0;
                    G_odd_sum  <= 0;
                    B_odd_sum  <= 0;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= Y_buff[2][15:8] - 32'd16;
                    Mult4_op_1 <= 32'd76284;
                    R_even_sum <= 0;
                    G_even_sum <= 0;
                    B_even_sum <= 0;
					
					M1_state <= S_LEAD_OUT_1;
				end
				S_LEAD_OUT_1: begin			
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd52;
                    U_odd_sum  <= U_odd_sum + Mult1_result;                    
					//--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd52;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------                    
                    Mult3_op_2 <= U_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd25624;
                    R_odd_sum  <= R_odd_sum + Mult3_result;
                    G_odd_sum  <= G_odd_sum + Mult3_result;
                    B_odd_sum  <= B_odd_sum + Mult3_result;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= U_even[1][15:8] - 32'd128;
                    Mult4_op_1 <= 32'd25624;
                    R_even_sum <= R_even_sum + Mult4_result;
                    G_even_sum <= G_even_sum + Mult4_result;
                    B_even_sum <= B_even_sum + Mult4_result;
                    
					M1_state <= S_LEAD_OUT_2;
				end
				S_LEAD_OUT_2: begin				
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd159;
                    U_odd_sum  <= U_odd_sum - Mult1_result;                    
					//--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd159;
                    V_odd_sum  <= V_odd_sum - Mult2_result;
                    //--- Mult 3 --------------------------------------                    
                    Mult3_op_2 <= U_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd132251;
                    G_odd_sum  <= G_odd_sum - Mult3_result;
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= U_even[1][15:8] - 32'd128;
                    Mult4_op_1 <= 32'd132251;
                    G_even_sum <= G_even_sum - Mult4_result;
                                        
                    M1_state <= S_LEAD_OUT_3;
				end
				S_LEAD_OUT_3: begin
					Y_buff[0] <= Y_buff[1];
					Y_buff[1] <= Y_buff[2];
					Y_buff[2] <= M1_SRAM_read_data;
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd159;
                    U_odd_sum  <= U_odd_sum + Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd159;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= V_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd104595;
                    B_odd_sum  <= B_odd_sum + Mult3_result;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= V_even[1][15:8] - 32'd128;
                    Mult4_op_1 <= 32'd104595;
                    B_even_sum <= B_even_sum + Mult4_result;
                    
					M1_state <= S_LEAD_OUT_4;
				end
				S_LEAD_OUT_4: begin
					M1_SRAM_we_n <= 1'd0; //prepare to write				
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;
					M1_SRAM_write_data <= {R_even[0],G_even[0]};
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd52;
                    U_odd_sum  <= U_odd_sum + Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd52;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= V_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd53281;
                    R_odd_sum  <= R_odd_sum + Mult3_result;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= V_even[1][15:8] - 32'd128;
                    Mult4_op_1 <= 32'd53281;
                    R_even_sum <= R_even_sum + Mult4_result;
                    
					M1_state <= S_LEAD_OUT_5;
				end
				S_LEAD_OUT_5: begin
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;
					M1_SRAM_write_data <= {B_even[0],R_odd[1]};
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd21;
                    U_odd_sum  <= U_odd_sum - Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd21;
                    V_odd_sum  <= V_odd_sum - Mult2_result;
                    //--- Mult 3 --------------------------------------
                    R_odd[0] <= R_odd[1];
                    G_odd[0] <= G_odd[1];
                    B_odd[0] <= B_odd[1];

					if (R_odd_sum[31]==1'b1) begin R_odd[1] <= 8'd0; end
					else if (R_odd_sum[30:24]!= 0) begin R_odd[1] <= 8'd255; end
					else begin R_odd[1] <= R_odd_sum >>> 16; end
					
					G_odd_temp = G_odd_sum - Mult3_result;
					if (G_odd_temp[31]==1'b1) begin G_odd[1] <= 8'd0; end
					else if (G_odd_temp[30:24]!= 0) begin G_odd[1] <= 8'd255; end
					else begin G_odd[1] <= G_odd_temp >>> 16; end

					if (B_odd_sum[31]==1'b1) begin B_odd[1] <= 8'd0; end
					else if (B_odd_sum[30:24]!= 0) begin B_odd[1] <= 8'd255; end					
					else begin B_odd[1] <= B_odd_sum >>> 16; end	
					
                    //--- Mult 4 --------------------------------------
                    R_even[0] <= R_even[1];
                    G_even[0] <= G_even[1];
                    B_even[0] <= B_even[1];
					
					if (R_even_sum[31]==1'b1) begin R_even[1] <= 8'd0; end
					else if (R_even_sum[30:24]!= 0) begin R_even[1] <= 8'd255; end
					else begin R_even[1] <= R_even_sum >>> 16; end
					
					G_even_temp = G_even_sum - Mult4_result;
					if (G_even_temp[31]==1'b1) begin G_even[1] <= 8'd0; end
					else if (G_even_temp[30:24]!= 0) begin G_even[1] <= 8'd255; end
					else begin G_even[1] <= G_even_temp >>> 16; end

					if (B_even_sum[31]==1'b1) begin B_even[1] <= 8'd0; end
					else if (B_even_sum[30:24]!= 0) begin B_even[1] <= 8'd255; end					
					else begin B_even[1] <= B_even_sum >>> 16; end	
    
					M1_state <= S_LEAD_OUT_6;
				end
				S_LEAD_OUT_6: begin
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;			
					M1_SRAM_write_data <= {G_odd[0][7:0],B_odd[0][7:0]};
					//--- Mult 1 --------------------------------------
						Reg_U0 <= U_even[2][7:0];
                        Reg_U1 <= Reg_U5;
                        Reg_U2 <= Reg_U0;
                        Reg_U3 <= Reg_U1;
                        Reg_U4 <= Reg_U2;
                        Reg_U5 <= Reg_U3;
                    Mult1_op_2 <= Reg_U3;
                    Mult1_op_1 <= 32'd21;
                    U_odd <= (U_odd_sum + Mult1_result) >>> 8;
                    U_odd_sum  <= 32'd128;
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= V_even[2][7:0];
                        Reg_V1 <= Reg_V5;
                        Reg_V2 <= Reg_V0;
                        Reg_V3 <= Reg_V1;
                        Reg_V4 <= Reg_V2;
                        Reg_V5 <= Reg_V3;
                    Mult2_op_2 <= Reg_V3;
                    Mult2_op_1 <= 32'd21;
                    V_odd <= (V_odd_sum + Mult2_result) >>> 8;
                    V_odd_sum  <= 32'd128;
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= Y_buff[0][7:0] - 32'd16;
                    Mult3_op_1 <= 32'd76284;
                    R_odd_sum  <= 0;
                    G_odd_sum  <= 0;
                    B_odd_sum  <= 0;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= Y_buff[1][15:8] - 32'd16;
                    Mult4_op_1 <= 32'd76284;
                    R_even_sum <= 0;
                    G_even_sum <= 0;
                    B_even_sum <= 0;
                    
					M1_state <= S_LEAD_OUT_7;
				end
				S_LEAD_OUT_7: begin
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;					
					M1_SRAM_write_data <= {R_even[0],G_even[0]};
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd52;
                    U_odd_sum  <= U_odd_sum + Mult1_result;                    
					//--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd52;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------                    
                    Mult3_op_2 <= U_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd25624;
                    R_odd_sum  <= R_odd_sum + Mult3_result;
                    G_odd_sum  <= G_odd_sum + Mult3_result;
                    B_odd_sum  <= B_odd_sum + Mult3_result;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= U_even[1][7:0] - 32'd128;
                    Mult4_op_1 <= 32'd25624;
                    R_even_sum <= R_even_sum + Mult4_result;
                    G_even_sum <= G_even_sum + Mult4_result;
                    B_even_sum <= B_even_sum + Mult4_result;
                    
					M1_state <= S_LEAD_OUT_8;
				end
				S_LEAD_OUT_8: begin
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;
					M1_SRAM_write_data <= {B_even[0],R_odd[1]};
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd159;
                    U_odd_sum  <= U_odd_sum - Mult1_result;                    
					//--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd159;
                    V_odd_sum  <= V_odd_sum - Mult2_result;
                    //--- Mult 3 --------------------------------------                    
                    Mult3_op_2 <= U_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd132251;
                    G_odd_sum  <= G_odd_sum - Mult3_result;
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= U_even[1][7:0] - 32'd128;
                    Mult4_op_1 <= 32'd132251;
                    G_even_sum <= G_even_sum - Mult4_result;
                                        					
					M1_state <= S_LEAD_OUT_9;
				end
				S_LEAD_OUT_9: begin
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;				
					M1_SRAM_write_data <= {G_odd[1],B_odd[1]};
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd159;
                    U_odd_sum  <= U_odd_sum + Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd159;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= V_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd104595;
                    B_odd_sum  <= B_odd_sum + Mult3_result;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= V_even[1][7:0] - 32'd128;
                    Mult4_op_1 <= 32'd104595;
                    B_even_sum <= B_even_sum + Mult4_result;
                    
					M1_state <= S_LEAD_OUT_10;
				end
				S_LEAD_OUT_10: begin
					M1_SRAM_we_n <= 1'd1; //prepare to read				
					M1_SRAM_address <= Y_address;
					Y_address <= Y_address + 1;
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd52;
                    U_odd_sum  <= U_odd_sum + Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd52;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= V_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd53281;
                    R_odd_sum  <= R_odd_sum + Mult3_result;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= V_even[1][7:0] - 32'd128;
                    Mult4_op_1 <= 32'd53281;
                    R_even_sum <= R_even_sum + Mult4_result;
                    
					M1_state <= S_LEAD_OUT_11;
				end				
				S_LEAD_OUT_11: begin
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd21;
                    U_odd_sum  <= U_odd_sum - Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd21;
                    V_odd_sum  <= V_odd_sum - Mult2_result;
                    //--- Mult 3 --------------------------------------
					R_odd[0] <= R_odd[1];
                    G_odd[0] <= G_odd[1];
                    B_odd[0] <= B_odd[1];

					if (R_odd_sum[31]==1'b1) begin R_odd[1] <= 8'd0; end
					else if (R_odd_sum[30:24]!= 0) begin R_odd[1] <= 8'd255; end
					else begin R_odd[1] <= R_odd_sum >>> 16; end
					
					G_odd_temp = G_odd_sum - Mult3_result;
					if (G_odd_temp[31]==1'b1) begin G_odd[1] <= 8'd0; end
					else if (G_odd_temp[30:24]!= 0) begin G_odd[1] <= 8'd255; end
					else begin G_odd[1] <= G_odd_temp >>> 16; end

					if (B_odd_sum[31]==1'b1) begin B_odd[1] <= 8'd0; end
					else if (B_odd_sum[30:24]!= 0) begin B_odd[1] <= 8'd255; end					
					else begin B_odd[1] <= B_odd_sum >>> 16; end	
					
                    //--- Mult 4 --------------------------------------
                    R_even[0] <= R_even[1];
                    G_even[0] <= G_even[1];
                    B_even[0] <= B_even[1];
					
					if (R_even_sum[31]==1'b1) begin R_even[1] <= 8'd0; end
					else if (R_even_sum[30:24]!= 0) begin R_even[1] <= 8'd255; end
					else begin R_even[1] <= R_even_sum >>> 16; end
					
					G_even_temp = G_even_sum - Mult4_result;
					if (G_even_temp[31]==1'b1) begin G_even[1] <= 8'd0; end
					else if (G_even_temp[30:24]!= 0) begin G_even[1] <= 8'd255; end
					else begin G_even[1] <= G_even_temp >>> 16; end

					if (B_even_sum[31]==1'b1) begin B_even[1] <= 8'd0; end
					else if (B_even_sum[30:24]!= 0) begin B_even[1] <= 8'd255; end					
					else begin B_even[1] <= B_even_sum >>> 16; end	
                    
					M1_state <= S_LEAD_OUT_12;
				end
				S_LEAD_OUT_12: begin								
					M1_state <= S_LEAD_OUT_13;
				end
                S_LEAD_OUT_13: begin
					Y_buff[0] <= Y_buff[1];
					Y_buff[1] <= Y_buff[2];
					Y_buff[2] <= M1_SRAM_read_data;					
					//--- Mult 1 --------------------------------------
						Reg_U0 <= U_even[2][7:0];
                        Reg_U1 <= Reg_U5;
                        Reg_U2 <= Reg_U0;
                        Reg_U3 <= Reg_U1;
                        Reg_U4 <= Reg_U2;
                        Reg_U5 <= Reg_U3;
                    Mult1_op_2 <= Reg_U3;
                    Mult1_op_1 <= 32'd21;
                    U_odd <= (U_odd_sum + Mult1_result) >>> 8;
                    U_odd_sum  <= 32'd128;
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= V_even[2][7:0];
                        Reg_V1 <= Reg_V5;
                        Reg_V2 <= Reg_V0;
                        Reg_V3 <= Reg_V1;
                        Reg_V4 <= Reg_V2;
                        Reg_V5 <= Reg_V3;
                    Mult2_op_2 <= Reg_V3;
                    Mult2_op_1 <= 32'd21;
                    V_odd <= (V_odd_sum + Mult2_result) >>> 8;
                    V_odd_sum  <= 32'd128;
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= Y_buff[1][7:0] - 32'd16;
                    Mult3_op_1 <= 32'd76284;
                    R_odd_sum  <= 0;
                    G_odd_sum  <= 0;
                    B_odd_sum  <= 0;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= Y_buff[2][15:8] - 32'd16;
                    Mult4_op_1 <= 32'd76284;
                    R_even_sum <= 0;
                    G_even_sum <= 0;
                    B_even_sum <= 0;
				
					M1_state <= S_LEAD_OUT_14;
                end                
                S_LEAD_OUT_14: begin
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd52;
                    U_odd_sum  <= U_odd_sum + Mult1_result;                    
					//--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd52;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------                    
                    Mult3_op_2 <= U_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd25624;
                    R_odd_sum  <= R_odd_sum + Mult3_result;
                    G_odd_sum  <= G_odd_sum + Mult3_result;
                    B_odd_sum  <= B_odd_sum + Mult3_result;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= U_even[2][15:8] - 32'd128;
                    Mult4_op_1 <= 32'd25624;
                    R_even_sum <= R_even_sum + Mult4_result;
                    G_even_sum <= G_even_sum + Mult4_result;
                    B_even_sum <= B_even_sum + Mult4_result;
                    
					M1_state <= S_LEAD_OUT_15;
                end
                S_LEAD_OUT_15: begin
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd159;
                    U_odd_sum  <= U_odd_sum - Mult1_result;                    
					//--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd159;
                    V_odd_sum  <= V_odd_sum - Mult2_result;
                    //--- Mult 3 --------------------------------------                    
                    Mult3_op_2 <= U_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd132251;
                    G_odd_sum  <= G_odd_sum - Mult3_result;
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= U_even[2][15:8] - 32'd128;
                    Mult4_op_1 <= 32'd132251;
                    G_even_sum <= G_even_sum - Mult4_result;
					
					M1_state <= S_LEAD_OUT_16;
                end
                S_LEAD_OUT_16: begin
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd159;
                    U_odd_sum  <= U_odd_sum + Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd159;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= V_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd104595;
                    B_odd_sum  <= B_odd_sum + Mult3_result;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= V_even[2][15:8] - 32'd128;
                    Mult4_op_1 <= 32'd104595;
                    B_even_sum <= B_even_sum + Mult4_result;
                    
					M1_state <= S_LEAD_OUT_17;
                end
                S_LEAD_OUT_17: begin
					M1_SRAM_we_n <= 1'd0; //prepare to write				
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;
					M1_SRAM_write_data <= {R_even[0],G_even[0]};
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd52;
                    U_odd_sum  <= U_odd_sum + Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd52;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= V_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd53281;
                    R_odd_sum  <= R_odd_sum + Mult3_result;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= V_even[2][15:8] - 32'd128;
                    Mult4_op_1 <= 32'd53281;
                    R_even_sum <= R_even_sum + Mult4_result;
                    
					M1_state <= S_LEAD_OUT_18;
                end
                S_LEAD_OUT_18: begin
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;
					M1_SRAM_write_data <= {B_even[0],R_odd[1]};
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd21;
                    U_odd_sum  <= U_odd_sum - Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd21;
                    V_odd_sum  <= V_odd_sum - Mult2_result;
                    //--- Mult 3 --------------------------------------
                    R_odd[0] <= R_odd[1];
                    G_odd[0] <= G_odd[1];
                    B_odd[0] <= B_odd[1];

					if (R_odd_sum[31]==1'b1) begin R_odd[1] <= 8'd0; end
					else if (R_odd_sum[30:24]!= 0) begin R_odd[1] <= 8'd255; end
					else begin R_odd[1] <= R_odd_sum >>> 16; end
					
					G_odd_temp = G_odd_sum - Mult3_result;
					if (G_odd_temp[31]==1'b1) begin G_odd[1] <= 8'd0; end
					else if (G_odd_temp[30:24]!= 0) begin G_odd[1] <= 8'd255; end
					else begin G_odd[1] <= G_odd_temp >>> 16; end

					if (B_odd_sum[31]==1'b1) begin B_odd[1] <= 8'd0; end
					else if (B_odd_sum[30:24]!= 0) begin B_odd[1] <= 8'd255; end					
					else begin B_odd[1] <= B_odd_sum >>> 16; end	
					
                    //--- Mult 4 --------------------------------------
                    R_even[0] <= R_even[1];
                    G_even[0] <= G_even[1];
                    B_even[0] <= B_even[1];

					if (R_even_sum[31]==1'b1) begin R_even[1] <= 8'd0; end
					else if (R_even_sum[30:24]!= 0) begin R_even[1] <= 8'd255; end
					else begin R_even[1] <= R_even_sum >>> 16; end
					
					G_even_temp = G_even_sum - Mult4_result;
					if (G_even_temp[31]==1'b1) begin G_even[1] <= 8'd0; end
					else if (G_even_temp[30:24]!= 0) begin G_even[1] <= 8'd255; end
					else begin G_even[1] <= G_even_temp >>> 16; end

					if (B_even_sum[31]==1'b1) begin B_even[1] <= 8'd0; end
					else if (B_even_sum[30:24]!= 0) begin B_even[1] <= 8'd255; end					
					else begin B_even[1] <= B_even_sum >>> 16; end	
										
					M1_state <= S_LEAD_OUT_19;
                end
                S_LEAD_OUT_19: begin
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;			
					M1_SRAM_write_data <= {G_odd[0][7:0],B_odd[0][7:0]};
					//--- Mult 1 --------------------------------------
						Reg_U0 <= U_even[2][7:0];
                        Reg_U1 <= Reg_U5;
                        Reg_U2 <= Reg_U0;
                        Reg_U3 <= Reg_U1;
                        Reg_U4 <= Reg_U2;
                        Reg_U5 <= Reg_U3;
                    Mult1_op_2 <= Reg_U3;
                    Mult1_op_1 <= 32'd21;
                    U_odd <= (U_odd_sum + Mult1_result) >>> 8;
                    U_odd_sum  <= 32'd128;
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= V_even[2][7:0];
                        Reg_V1 <= Reg_V5;
                        Reg_V2 <= Reg_V0;
                        Reg_V3 <= Reg_V1;
                        Reg_V4 <= Reg_V2;
                        Reg_V5 <= Reg_V3;
                    Mult2_op_2 <= Reg_V3;
                    Mult2_op_1 <= 32'd21;
                    V_odd <= (V_odd_sum + Mult2_result) >>> 8;
                    V_odd_sum  <= 32'd128;
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= Y_buff[1][7:0] - 32'd16;
                    Mult3_op_1 <= 32'd76284;
                    R_odd_sum  <= 0;
                    G_odd_sum  <= 0;
                    B_odd_sum  <= 0;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= Y_buff[2][15:8] - 32'd16;
                    Mult4_op_1 <= 32'd76284;
                    R_even_sum <= 0;
                    G_even_sum <= 0;
                    B_even_sum <= 0;
                    
					M1_state <= S_LEAD_OUT_20;
                end
                S_LEAD_OUT_20: begin
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;					
					M1_SRAM_write_data <= {R_even[0],G_even[0]};
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd52;
                    U_odd_sum  <= U_odd_sum + Mult1_result;                    
					//--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd52;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------                    
                    Mult3_op_2 <= U_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd25624;
                    R_odd_sum  <= R_odd_sum + Mult3_result;
                    G_odd_sum  <= G_odd_sum + Mult3_result;
                    B_odd_sum  <= B_odd_sum + Mult3_result;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= U_even[2][7:0] - 32'd128;
                    Mult4_op_1 <= 32'd25624;
                    R_even_sum <= R_even_sum + Mult4_result;
                    G_even_sum <= G_even_sum + Mult4_result;
                    B_even_sum <= B_even_sum + Mult4_result;
                    
					M1_state <= S_LEAD_OUT_21;
                end
                S_LEAD_OUT_21: begin
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;					
					M1_SRAM_write_data <= {B_even[0],R_odd[1]};
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd159;
                    U_odd_sum  <= U_odd_sum - Mult1_result;                    
					//--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd159;
                    V_odd_sum  <= V_odd_sum - Mult2_result;
                    //--- Mult 3 --------------------------------------                    
                    Mult3_op_2 <= U_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd132251;
                    G_odd_sum  <= G_odd_sum - Mult3_result;
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= U_even[2][7:0] - 32'd128;
                    Mult4_op_1 <= 32'd132251;
                    G_even_sum <= G_even_sum - Mult4_result;
					                    
					M1_state <= S_LEAD_OUT_22;
                end
                S_LEAD_OUT_22: begin
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;				
					M1_SRAM_write_data <= {G_odd[1],B_odd[1]};
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd159;
                    U_odd_sum  <= U_odd_sum + Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd159;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= V_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd104595;
                    B_odd_sum  <= B_odd_sum + Mult3_result;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= V_even[2][7:0] - 32'd128;
                    Mult4_op_1 <= 32'd104595;
                    B_even_sum <= B_even_sum + Mult4_result;
                    
					M1_state <= S_LEAD_OUT_23;
                end
                S_LEAD_OUT_23: begin
					M1_SRAM_we_n <= 1'd1; //prepare to read				
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd52;
                    U_odd_sum  <= U_odd_sum + Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd52;
                    V_odd_sum  <= V_odd_sum + Mult2_result;
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= V_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd53281;
                    R_odd_sum  <= R_odd_sum + Mult3_result;                    
                    //--- Mult 4 --------------------------------------
                    Mult4_op_2 <= V_even[2][7:0] - 32'd128;
                    Mult4_op_1 <= 32'd53281;
                    R_even_sum <= R_even_sum + Mult4_result;
                    
					M1_state <= S_LEAD_OUT_24;
                end
                S_LEAD_OUT_24: begin
					//--- Mult 1 --------------------------------------
						Reg_U0 <= Reg_U5;
                        Reg_U1 <= Reg_U0;
                        Reg_U2 <= Reg_U1;
                        Reg_U3 <= Reg_U2;
                        Reg_U4 <= Reg_U3;
                        Reg_U5 <= Reg_U4;
                    Mult1_op_2 <= Reg_U4;
                    Mult1_op_1 <= 32'd21;
                    U_odd_sum  <= U_odd_sum - Mult1_result; 
                    //--- Mult 2 --------------------------------------
                        Reg_V0 <= Reg_V5;
                        Reg_V1 <= Reg_V0;
                        Reg_V2 <= Reg_V1;
                        Reg_V3 <= Reg_V2;
                        Reg_V4 <= Reg_V3;
                        Reg_V5 <= Reg_V4;
                    Mult2_op_2 <= Reg_V4;
                    Mult2_op_1 <= 32'd21;
                    V_odd_sum  <= V_odd_sum - Mult2_result;
                    //--- Mult 3 --------------------------------------
					R_odd[0] <= R_odd[1];
                    G_odd[0] <= G_odd[1];
                    B_odd[0] <= B_odd[1];
				
					if (R_odd_sum[31]==1'b1) begin R_odd[1] <= 8'd0; end
					else if (R_odd_sum[30:24]!= 0) begin R_odd[1] <= 8'd255; end
					else begin R_odd[1] <= R_odd_sum >>> 16; end
					
					G_odd_temp = G_odd_sum - Mult3_result;
					if (G_odd_temp[31]==1'b1) begin G_odd[1] <= 8'd0; end
					else if (G_odd_temp[30:24]!= 0) begin G_odd[1] <= 8'd255; end
					else begin G_odd[1] <= G_odd_temp >>> 16; end

					if (B_odd_sum[31]==1'b1) begin B_odd[1] <= 8'd0; end
					else if (B_odd_sum[30:24]!= 0) begin B_odd[1] <= 8'd255; end					
					else begin B_odd[1] <= B_odd_sum >>> 16; end	
					
                    //--- Mult 4 --------------------------------------
                    R_even[0] <= R_even[1];
                    G_even[0] <= G_even[1];
                    B_even[0] <= B_even[1];

					if (R_even_sum[31]==1'b1) begin R_even[1] <= 8'd0; end
					else if (R_even_sum[30:24]!= 0) begin R_even[1] <= 8'd255; end
					else begin R_even[1] <= R_even_sum >>> 16; end
					
					G_even_temp = G_even_sum - Mult4_result;
					if (G_even_temp[31]==1'b1) begin G_even[1] <= 8'd0; end
					else if (G_even_temp[30:24]!= 0) begin G_even[1] <= 8'd255; end
					else begin G_even[1] <= G_even_temp >>> 16; end

					if (B_even_sum[31]==1'b1) begin B_even[1] <= 8'd0; end
					else if (B_even_sum[30:24]!= 0) begin B_even[1] <= 8'd255; end					
					else begin B_even[1] <= B_even_sum >>> 16; end	
				
					M1_state <= S_LEAD_OUT_25;
				end	
				S_LEAD_OUT_25: begin
					M1_state <= S_LEAD_OUT_26;
				end
				S_LEAD_OUT_26: begin
					//--- Mult 1 --------------------------------------
                    U_odd <= (U_odd_sum + Mult1_result) >>> 8;
                    //--- Mult 2 --------------------------------------
                    V_odd <= (V_odd_sum + Mult2_result) >>> 8;
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= Y_buff[2][7:0] - 32'd16;
                    Mult3_op_1 <= 32'd76284;
                    R_odd_sum  <= 0;
                    G_odd_sum  <= 0;
                    B_odd_sum  <= 0;                    
					
					M1_state <= S_LEAD_OUT_27;
				end
				S_LEAD_OUT_27: begin
                    //--- Mult 3 --------------------------------------                    
                    Mult3_op_2 <= U_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd25624;
                    R_odd_sum  <= R_odd_sum + Mult3_result;
                    G_odd_sum  <= G_odd_sum + Mult3_result;
                    B_odd_sum  <= B_odd_sum + Mult3_result;                    
					
					M1_state <= S_LEAD_OUT_28;
				end
				S_LEAD_OUT_28: begin
                    //--- Mult 3 --------------------------------------                    
                    Mult3_op_2 <= U_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd132251;
                    G_odd_sum  <= G_odd_sum - Mult3_result;
                    
					M1_state <= S_LEAD_OUT_29;
				end
				S_LEAD_OUT_29: begin
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= V_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd104595;
                    B_odd_sum  <= B_odd_sum + Mult3_result;                    
					
					M1_state <= S_LEAD_OUT_30;
				end
				S_LEAD_OUT_30: begin
					M1_SRAM_we_n <= 1'd0; //prepare to write				
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;
					M1_SRAM_write_data <= {R_even[0],G_even[0]};
                    //--- Mult 3 --------------------------------------
                    Mult3_op_2 <= V_odd[7:0] - 32'd128;
                    Mult3_op_1 <= 32'd53281;
                    R_odd_sum  <= R_odd_sum + Mult3_result;                    
					
					M1_state <= S_LEAD_OUT_31;
				end
				S_LEAD_OUT_31: begin
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;
					M1_SRAM_write_data <= {B_even[0],R_odd[1]};
                    //--- Mult 3 --------------------------------------
                    R_odd[0] <= R_odd[1];
                    G_odd[0] <= G_odd[1];
                    B_odd[0] <= B_odd[1];

					if (R_odd_sum[31]==1'b1) begin R_odd[1] <= 8'd0; end
					else if (R_odd_sum[30:24]!= 0) begin R_odd[1] <= 8'd255; end
					else begin R_odd[1] <= R_odd_sum >>> 16; end
					
					G_odd_temp = G_odd_sum - Mult3_result;
					if (G_odd_temp[31]==1'b1) begin G_odd[1] <= 8'd0; end
					else if (G_odd_temp[30:24]!= 0) begin G_odd[1] <= 8'd255; end
					else begin G_odd[1] <= G_odd_temp >>> 16; end

					if (B_odd_sum[31]==1'b1) begin B_odd[1] <= 8'd0; end
					else if (B_odd_sum[30:24]!= 0) begin B_odd[1] <= 8'd255; end					
					else begin B_odd[1] <= B_odd_sum >>> 16; end
					
					M1_state <= S_LEAD_OUT_32;
				end				
				S_LEAD_OUT_32: begin
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;			
					M1_SRAM_write_data <= {G_odd[0][7:0],B_odd[0][7:0]}; 
					
					M1_state <= S_LEAD_OUT_33;
				end
				S_LEAD_OUT_33: begin
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;					
					M1_SRAM_write_data <= {R_even[1],G_even[1]}; 
					
					M1_state <= S_LEAD_OUT_34;
				end
				S_LEAD_OUT_34: begin
					M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;
					M1_SRAM_write_data <= {B_even[1],R_odd[1]};
					
					M1_state <= S_LEAD_OUT_35;
				end

				S_LEAD_OUT_35: begin
               M1_SRAM_address <= RGB_OFFSET + RGB_address;
					RGB_address <= RGB_address + 1;
					COL_counter <= COL_counter + 1;				
					M1_SRAM_write_data <= {G_odd[1],B_odd[1]};		
					
					M1_state <= S_LEAD_OUT_36;
				end
				
				S_LEAD_OUT_36: begin
					M1_SRAM_we_n <= 1'd1; //prepare to read

               ROW_counter <= ROW_counter + 1;
               if (ROW_counter >= 8'd239) begin
						M1_end <=1;
						M1_state <= S_M1_IDLE;
					end else begin
						M1_state <= S_LOAD_0;
					end 
				end
            endcase
        end
end

assign Mult1_result_long = Mult1_op_1*Mult1_op_2;
assign Mult1_result = Mult1_result_long[31:0];

assign Mult2_result_long = Mult2_op_1*Mult2_op_2;
assign Mult2_result = Mult2_result_long[31:0];

assign Mult3_result_long = Mult3_op_1*Mult3_op_2;
assign Mult3_result = Mult3_result_long[31:0];

assign Mult4_result_long = Mult4_op_1*Mult4_op_2;
assign Mult4_result = Mult4_result_long[31:0];

endmodule