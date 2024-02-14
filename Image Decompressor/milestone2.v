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
module milestone2(
                /////// board clocks                      ////////////
                input logic CLOCK_50_I,                   // 50 MHz clock
                input logic Resetn,

                input logic M2_start,
                output logic M2_end,

				input logic [15:0] M2_SRAM_read_data,
				output logic [15:0] M2_SRAM_write_data,
                output logic [17:0] M2_SRAM_address,
                output logic M2_SRAM_we_n
);

M2_state_type M2_state;

// Multipliers
logic signed [31:0] Mult1_op_1;
logic [31:0] Mult1_op_2,Mult1_result;
logic [63:0] Mult1_result_long;
logic signed [31:0] Mult1_sum;
logic [31:0] Mult1_buff;

logic signed [31:0] Mult2_op_1;
logic [31:0] Mult2_op_2,Mult2_result;
logic [63:0] Mult2_result_long;
logic signed [31:0] Mult2_sum;
logic [31:0] Mult2_buff;

logic signed [31:0] Mult3_op_1;
logic [31:0] Mult3_op_2,Mult3_result;
logic [63:0] Mult3_result_long;
logic signed [31:0] Mult3_sum;
logic [31:0] Mult3_buff;

logic signed [31:0] Mult4_op_1;
logic [31:0] Mult4_op_2,Mult4_result;
logic [63:0] Mult4_result_long;
logic signed [31:0] Mult4_sum;
logic [31:0] Mult4_buff;

// Registers
logic [5:0] FETCH_blockRow;
logic [5:0] FETCH_blockCol;
logic [2:0] FETCH_dataRow;
logic [2:0] FETCH_dataCol;
logic [9:0] FETCH_rowAddress;
logic [9:0] FETCH_colAddress;
logic FETCH_Y_to_UV_flag;

logic [5:0] YUV_blockRow;
logic [5:0] YUV_blockCol;
logic [2:0] YUV_dataRow;
logic [2:0] YUV_dataCol;
logic [9:0] YUV_rowAddress;
logic [9:0] YUV_colAddress;
logic YUV_Y_to_UV_flag;
logic [31:0] YUV_buffer;

// SRAM addresses
logic [17:0] SRAM_FETCH_Y_OFFSET, SRAM_FETCH_UV_OFFSET;
logic [17:0] SRAM_YUV_Y_OFFSET, SRAM_YUV_UV_OFFSET;
logic [17:0] SRAM_FETCH_address, SRAM_YUV_address;

// DPRAM addresses
logic [6:0] SP_address_a;
logic [6:0] SP_address_b;
logic [6:0] T_address_a;
logic [6:0] T_address_b;
logic [6:0] S_address_a;
logic [6:0] S_address_b;

logic SP_wren_a;
logic SP_wren_b;
logic T_wren_a;
logic T_wren_b;
logic S_wren_a;
logic S_wren_b;

// DPRAM data
logic [31:0] SP_data_read_a;
logic [31:0] SP_data_write_a;
logic [31:0] SP_data_read_b;
logic [31:0] SP_data_write_b;

logic [2:0] SP_dataRow_a;
logic [2:0] SP_dataCol_a;
logic [2:0] SP_dataRow_b;
logic [2:0] SP_dataCol_b;

logic [31:0] T_data_read_a;
logic [31:0] T_data_write_a;
logic [31:0] T_data_read_b;
logic [31:0] T_data_write_b;

logic [2:0] T_dataRow_a;
logic [2:0] T_dataCol_a;
logic [2:0] T_dataRow_b;
logic [2:0] T_dataCol_b;

logic [31:0] S_data_read_a;
logic [31:0] S_data_write_a;
logic [31:0] S_data_read_b;
logic [31:0] S_data_write_b;

logic [2:0] S_dataRow_a;
logic [2:0] S_dataCol_a;
logic [2:0] S_dataRow_b;
logic [2:0] S_dataCol_b;
// ------------------------------------------

//DPRAMs
//for S' values
dual_port_RAM0 dual_port_RAM0_inst0 (
	.address_a(SP_address_a),
	.address_b(SP_address_b),
	.clock(CLOCK_50_I),
	.data_a(SP_data_write_a),
	.data_b(SP_data_write_b),
	.wren_a(SP_wren_a),
	.wren_b(SP_wren_b),
	.q_a(SP_data_read_a),
	.q_b(SP_data_read_b)
);
//for T values
dual_port_RAM1 dual_port_RAM1_inst1 (
	.address_a(T_address_a),
	.address_b(T_address_b),
	.clock(CLOCK_50_I),
	.data_a(T_data_write_a),
	.data_b(T_data_write_b),
	.wren_a(T_wren_a),
	.wren_b(T_wren_b),
	.q_a(T_data_read_a),
	.q_b(T_data_read_b)
);
//for S values
dual_port_RAM2 dual_port_RAM2_inst2 (
	.address_a(S_address_a),
	.address_b(S_address_b),
	.clock(CLOCK_50_I),
	.data_a(S_data_write_a),
	.data_b(S_data_write_b),
	.wren_a(S_wren_a),
	.wren_b(S_wren_b),
	.q_a(S_data_read_a),
	.q_b(S_data_read_b)
);

always_ff @ (posedge CLOCK_50_I or negedge Resetn) begin
	if (Resetn == 1'b0) begin
			M2_state <= S_M2_IDLE;
            M2_end <= 1'b0;
            M2_SRAM_we_n <= 1'b1;

            SRAM_FETCH_Y_OFFSET <= 18'd76800;
			SRAM_FETCH_UV_OFFSET <= 18'd153600;
			FETCH_blockRow <= 0;
			FETCH_blockCol <= 0;
			FETCH_dataRow <= 0;
			FETCH_dataCol <= 0;
			FETCH_Y_to_UV_flag <=0;
			
			SRAM_YUV_Y_OFFSET <= 18'd0;
			SRAM_YUV_UV_OFFSET <= 18'd38400;
			YUV_blockRow <= 0;
			YUV_blockCol <= 0;
			YUV_dataRow <= 0;
			YUV_dataCol <= 0;
			YUV_Y_to_UV_flag <= 0;	
			YUV_buffer <= 0;
			
			SP_wren_a <= 1;
			SP_wren_b <= 0;
			T_wren_a <= 1;
			T_wren_b <= 0;
			S_wren_a <= 1;
			S_wren_b <= 0;

			SP_dataRow_a <=0;
			SP_dataCol_a <=0;
			SP_dataRow_b <=0;
			SP_dataCol_b <=0;
			
			T_dataRow_a <=0;
			T_dataCol_a <=0;
			T_dataRow_b <=0;
			T_dataCol_b <=0;
			
			S_dataRow_a <=0;
			S_dataCol_a <=0;
			S_dataRow_b <=0;
			S_dataCol_b <=0;			

	end else begin
		case(M2_state)
			S_M2_IDLE: begin
				M2_end <= 1'b0;
				M2_SRAM_we_n <= 1'b1;
				if ((M2_start == 1) && (M2_end == 0)) begin
					M2_state <= S_MEGASTART_DELAY_0;
				end	else begin
					M2_state <= S_M2_IDLE;
				end
			end
			S_MEGASTART_DELAY_0: begin
				FETCH_blockCol <= 0;
				FETCH_blockRow <= 0;
				FETCH_dataRow <= 0;
				FETCH_dataCol <= 0;	
				YUV_blockCol <= 0;
				YUV_blockRow <= 0;
				YUV_dataRow <= 0;
				YUV_dataCol <= 0;					
                M2_state <= S_LOAD_SP_LI_00;                
			end
//----------------------------------------------------------------------
			S_LOAD_SP_LI_00: begin
				M2_state <= S_LOAD_SP_LI_01;
			end
			S_LOAD_SP_LI_01: begin
				M2_SRAM_we_n <= 1;
				M2_SRAM_address <= SRAM_FETCH_address;
				
				SP_wren_a <= 0;
				SP_dataRow_a <= 0;
				SP_dataCol_a <= 0;
				
				M2_state <= S_LOAD_SP_LI_02;
			end
			S_LOAD_SP_LI_02: begin
				FETCH_dataCol <= FETCH_dataCol + 1;
				M2_state <= S_LOAD_SP_LI_9;
			end
			S_LOAD_SP_LI_9: begin
				M2_SRAM_address <= SRAM_FETCH_address;
				M2_state <= S_LOAD_SP_LI_10;
			end
			S_LOAD_SP_LI_10: begin
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_LOAD_SP_LI_11;
			end
			S_LOAD_SP_LI_11: begin
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------
				M2_state <= S_LOAD_SP_LI_12;
			end			
			S_LOAD_SP_LI_12: begin
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_LOAD_SP_LI_13;
			end			
			S_LOAD_SP_LI_13: begin
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------			
				M2_state <= S_LOAD_SP_LI_14;
			end			
			S_LOAD_SP_LI_14: begin
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------			
				M2_state <= S_LOAD_SP_LI_15;
			end			
			S_LOAD_SP_LI_15: begin
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------
				M2_state <= S_LOAD_SP_LI_16;
			end			
			S_LOAD_SP_LI_16: begin

				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_LOAD_SP_1;
			end			
			S_LOAD_SP_1: begin
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;
				//----------------------------------------------------------------------
				M2_state <= S_LOAD_SP_2;
			end
			S_LOAD_SP_2: begin
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_LOAD_SP_3;
			end 
			S_LOAD_SP_3: begin
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------
				M2_state <= S_LOAD_SP_4;
			end
			S_LOAD_SP_4: begin
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_LOAD_SP_5;
			end
			S_LOAD_SP_5: begin
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------			
				M2_state <= S_LOAD_SP_6;
			end
			S_LOAD_SP_6: begin
				FETCH_dataRow <= FETCH_dataRow + 1;
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------			
				M2_state <= S_LOAD_SP_7;
			end
			S_LOAD_SP_7: begin
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------
				M2_state <= S_LOAD_SP_8;
			end
			S_LOAD_SP_8: begin
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_LOAD_SP_9;
			end
			S_LOAD_SP_9: begin
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataRow_a <= SP_dataRow_a + 1;
				SP_dataCol_a <= SP_dataCol_a + 1;
				//----------------------------------------------------------------------
				M2_state <= S_LOAD_SP_10;
			end
			S_LOAD_SP_10: begin
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_LOAD_SP_11;
			end
			S_LOAD_SP_11: begin
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------
				M2_state <= S_LOAD_SP_12;
			end
			S_LOAD_SP_12: begin
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_LOAD_SP_13;
			end
			S_LOAD_SP_13: begin
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------			
				M2_state <= S_LOAD_SP_14;
			end
			S_LOAD_SP_14: begin
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------			
				M2_state <= S_LOAD_SP_15;
			end
			S_LOAD_SP_15: begin
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------
				M2_state <= S_LOAD_SP_16;
			end
			S_LOAD_SP_16: begin
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				if (FETCH_dataRow < 'd7) begin
					M2_state <= S_LOAD_SP_1;
				end else begin
					M2_state <= S_LOAD_SP_LO_1;
				end				
			end
//----------------------------------------------------------------------			
			S_LOAD_SP_LO_1: begin
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;
				//----------------------------------------------------------------------			
				M2_state <= S_LOAD_SP_LO_2;
			end
			S_LOAD_SP_LO_2: begin
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_LOAD_SP_LO_3;
			end 
			S_LOAD_SP_LO_3: begin
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------
				M2_state <= S_LOAD_SP_LO_4;
			end
			S_LOAD_SP_LO_4: begin
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_LOAD_SP_LO_5;
			end
			S_LOAD_SP_LO_5: begin
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------			
				M2_state <= S_LOAD_SP_LO_6;
			end
			S_LOAD_SP_LO_6: begin
				FETCH_dataRow <= FETCH_dataRow + 1;
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------			
				M2_state <= S_LOAD_SP_LO_7;
			end
			S_LOAD_SP_LO_7: begin
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------
				M2_state <= S_LOAD_SP_LO_8;
			end
			S_LOAD_SP_LO_8: begin
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_LOAD_SP_LO_9;
			end
			S_LOAD_SP_LO_9: begin
				SP_wren_a <= 0;
				SP_dataRow_a <= SP_dataRow_a + 1;
				SP_dataCol_a <= SP_dataCol_a + 1;
				//----------------------------------------------------------------------
				M2_state <= S_LOAD_SP_LO_10;
			end
			S_LOAD_SP_LO_10: begin
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				FETCH_blockCol <= 1;
				M2_state <= S_LOAD_T_LI_01;
			end
//----------------------------------------------------------------------			
			S_LOAD_T_LI_00: begin
				M2_state <= S_LOAD_T_LI_01;
			end
			S_LOAD_T_LI_01: begin
				SP_wren_b <= 0;
				SP_dataCol_b <= 0;
				SP_dataRow_b <= 0;
				
				T_wren_a <= 0;
				T_dataRow_a <= 0;
				T_dataCol_a <= 0;
				
				M2_state <= S_LOAD_T_LI_02;
			end
			S_LOAD_T_LI_02: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				M2_state <= S_LOAD_T_LI_9;
			end			
			S_LOAD_T_LI_9: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= 0;
				Mult2_sum <= 0;
				Mult3_sum <= 0;					
				Mult4_sum <= 0;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LI_10;
			end			
			S_LOAD_T_LI_10: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd2008;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd1702;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1137;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd399;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LI_11;
			end			
			S_LOAD_T_LI_11: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1892;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd783;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd783;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd1892;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LI_12;
			end			
			S_LOAD_T_LI_12: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1702;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd399;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd2008;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd1137;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LI_13;
			end			
			S_LOAD_T_LI_13: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LI_14;
			end			
			S_LOAD_T_LI_14: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1137;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd2008;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd399;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1702;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LI_15;
			end			
			S_LOAD_T_LI_15: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd783;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1892;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1892;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd783;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LI_16;
			end				
			S_LOAD_T_LI_16: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd399;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1137;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1702;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd2008;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_dataCol_a <= 'd7;
				T_dataRow_a <= 'd7;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_1;
			end			
			S_LOAD_T_1: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= 0;
				Mult2_sum <= 0;
				Mult3_sum <= 0;					
				Mult4_sum <= 0;
				Mult1_buff <= (Mult1_sum + Mult1_result) >>> 8;
				Mult2_buff <= (Mult2_sum + Mult2_result) >>> 8;	
				Mult3_buff <= (Mult3_sum + Mult3_result) >>> 8;
				Mult4_buff <= (Mult4_sum + Mult4_result) >>> 8;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;				
				T_dataRow_a <= T_dataRow_a + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_2;
			end
			S_LOAD_T_2: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= -12'd399;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1137;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd1702;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd2008;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult1_buff;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_3;
			end
			S_LOAD_T_3: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= -12'd1892;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd783;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd783;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1892;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_4;
			end
			S_LOAD_T_4: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1137;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd2008;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd399;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd1702;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult2_buff;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_5;
			end
			S_LOAD_T_5: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_6;
			end
			S_LOAD_T_6: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= -12'd1702;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd399;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd2008;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd1137;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult3_buff;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_7;
			end
			S_LOAD_T_7: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				SP_dataRow_b <= SP_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= -12'd783;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd1892;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd1892;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd783;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_8;
			end
			S_LOAD_T_8: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd2008;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1702;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1137;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd399;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult4_buff;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_9;
			end
			S_LOAD_T_9: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= 0;
				Mult2_sum <= 0;
				Mult3_sum <= 0;					
				Mult4_sum <= 0;
				Mult1_buff <= (Mult1_sum + Mult1_result) >>> 8;
				Mult2_buff <= (Mult2_sum + Mult2_result) >>> 8;	
				Mult3_buff <= (Mult3_sum + Mult3_result) >>> 8;
				Mult4_buff <= (Mult4_sum + Mult4_result) >>> 8;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;				
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_10;
			end
			S_LOAD_T_10: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd2008;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd1702;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1137;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd399;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult1_buff;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_11;
			end
			S_LOAD_T_11: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1892;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd783;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd783;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd1892;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_12;
			end
			S_LOAD_T_12: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1702;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd399;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd2008;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd1137;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult2_buff;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_13;
			end
			S_LOAD_T_13: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_14;
			end
			S_LOAD_T_14: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1137;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd2008;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd399;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1702;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult3_buff;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_15;
			end			
			S_LOAD_T_15: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd783;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1892;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1892;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd783;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_16;
			end			
			S_LOAD_T_16: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd399;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1137;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1702;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd2008;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult4_buff;
				//----------------------------------------------------------------------							
				if (SP_dataRow_b < 'd7) begin
					M2_state <= S_LOAD_T_1;
				end else begin
					M2_state <= S_LOAD_T_LO_1;
				end					
			end
//----------------------------------------------------------------------
			S_LOAD_T_LO_1: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= 0;
				Mult2_sum <= 0;
				Mult3_sum <= 0;					
				Mult4_sum <= 0;
				Mult1_buff <= (Mult1_sum + Mult1_result) >>> 8;
				Mult2_buff <= (Mult2_sum + Mult2_result) >>> 8;	
				Mult3_buff <= (Mult3_sum + Mult3_result) >>> 8;
				Mult4_buff <= (Mult4_sum + Mult4_result) >>> 8;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;				
				T_dataRow_a <= T_dataRow_a + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LO_2;
			end
			S_LOAD_T_LO_2: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= -12'd399;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1137;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd1702;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd2008;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult1_buff;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LO_3;
			end
			S_LOAD_T_LO_3: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= -12'd1892;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd783;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd783;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1892;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LO_4;
			end
			S_LOAD_T_LO_4: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1137;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd2008;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd399;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd1702;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult2_buff;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LO_5;
			end
			S_LOAD_T_LO_5: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LO_6;
			end
			S_LOAD_T_LO_6: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= -12'd1702;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd399;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd2008;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd1137;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult3_buff;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LO_7;
			end
			S_LOAD_T_LO_7: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= -12'd783;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd1892;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd1892;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd783;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LO_8;
			end
			S_LOAD_T_LO_8: begin
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd2008;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1702;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1137;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd399;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult4_buff;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LO_9;
			end
			S_LOAD_T_LO_9: begin
				Mult1_sum <= 0;
				Mult2_sum <= 0;
				Mult3_sum <= 0;					
				Mult4_sum <= 0;
				Mult1_buff <= (Mult1_sum + Mult1_result) >>> 8;
				Mult2_buff <= (Mult2_sum + Mult2_result) >>> 8;	
				Mult3_buff <= (Mult3_sum + Mult3_result) >>> 8;
				Mult4_buff <= (Mult4_sum + Mult4_result) >>> 8;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;				
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LO_10;
			end
			S_LOAD_T_LO_10: begin
				T_wren_a <= 1;
				T_data_write_a <= Mult1_buff;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LO_11;
			end
			S_LOAD_T_LO_11: begin
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LO_12;
			end
			S_LOAD_T_LO_12: begin
				T_wren_a <= 1;
				T_data_write_a <= Mult2_buff;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LO_13;
			end
			S_LOAD_T_LO_13: begin
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LO_14;
			end
			S_LOAD_T_LO_14: begin
				T_wren_a <= 1;
				T_data_write_a <= Mult3_buff;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LO_15;
			end		
			S_LOAD_T_LO_15: begin
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LO_16;
			end			
			S_LOAD_T_LO_16: begin
				T_wren_a <= 1;
				T_data_write_a <= Mult4_buff;
				//----------------------------------------------------------------------				
				M2_state <= S_LOAD_T_LO_17;
				//----------------------------------------------------------------------				
			end
			S_LOAD_T_LO_17: begin
				T_wren_a <= 0;
				//----------------------------------------------------------------------				
				M2_state <= S_MS_A_LI_00;
				//----------------------------------------------------------------------				
			end			
//----------------------------------------------------------------------
			S_MS_A_LI_00: begin

				M2_state <= S_MS_A_LI_01;
			end
			S_MS_A_LI_01: begin
				T_wren_b <= 0;
				T_dataRow_b <= 0;
				T_dataCol_b <= 0;
				
				S_wren_a <= 0;
				S_dataRow_a <= 0;
				S_dataCol_a <= 0;
				
				M2_SRAM_we_n <= 1;
				M2_SRAM_address <= SRAM_FETCH_address;
				
				SP_wren_a <= 0;
				SP_dataRow_a <= 0;
				SP_dataCol_a <= 0;
				
				M2_state <= S_MS_A_LI_02;
			end
			S_MS_A_LI_02: begin
				FETCH_dataCol <= FETCH_dataCol + 1;
				M2_state <= S_MS_A_LI_9;
			end
			S_MS_A_LI_9: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= 12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= 12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= 0;
				Mult2_sum <= 0;
				Mult3_sum <= 0;					
				Mult4_sum <= 0;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_LI_10;
			end
			S_MS_A_LI_10: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd2008;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= 12'd1702;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= 12'd1137;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= 12'd399;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_LI_11;
			end
			S_MS_A_LI_11: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd1892;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= 12'd783;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= -12'd783;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= -12'd1892;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------	
				//----------------------------------------------------------------------
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_LI_12;
			end			
			S_MS_A_LI_12: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd1702;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= -12'd399;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= -12'd2008;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= -12'd1137;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_LI_13;
			end			
			S_MS_A_LI_13: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= -12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= -12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------	
				//----------------------------------------------------------------------
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------			
				M2_state <= S_MS_A_LI_14;
			end			
			S_MS_A_LI_14: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd1137;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= -12'd2008;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= 12'd399;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= 12'd1702;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------			
				M2_state <= S_MS_A_LI_15;
			end			
			S_MS_A_LI_15: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd783;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= -12'd1892;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= 12'd1892;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= -12'd783;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------	
				//----------------------------------------------------------------------
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_LI_16;
			end			
			S_MS_A_LI_16: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd399;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= -12'd1137;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= 12'd1702;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= -12'd2008;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				S_wren_a <= 0;
				S_dataRow_a <= 3'd7;
				S_dataCol_a <= 3'd7;
				//----------------------------------------------------------------------
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_1;
			end			
//----------------------------------------------------------------------
			S_MS_A_1: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= 12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= 12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= 0;
				Mult2_sum <= 0;
				Mult3_sum <= 0;					
				Mult4_sum <= 0;
				Mult1_buff <= (Mult1_sum + Mult1_result) >>> 16;
				Mult2_buff <= (Mult2_sum + Mult2_result) >>> 16;	
				Mult3_buff <= (Mult3_sum + Mult3_result) >>> 16;
				Mult4_buff <= (Mult4_sum + Mult4_result) >>> 16;
				//----------------------------------------------------------------------
				S_wren_a <= 0;
				S_dataRow_a <= S_dataRow_a + 1;
				S_dataCol_a <= S_dataCol_a + 1;
				//----------------------------------------------------------------------
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_2;
			end
			S_MS_A_2: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= -12'd399;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= -12'd1137;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= -12'd1702;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= -12'd2008;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				S_wren_a <= 1;
				S_data_write_a <= Mult1_buff;
				//----------------------------------------------------------------------
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_3;
			end 
			S_MS_A_3: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= -12'd1892;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= -12'd783;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= 12'd783;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= 12'd1892;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------	
				S_wren_a <= 0;
				S_dataRow_a <= S_dataRow_a + 1;
				//----------------------------------------------------------------------
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_4;
			end
			S_MS_A_4: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd1137;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= 12'd2008;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= 12'd399;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= -12'd1702;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				S_wren_a <= 1;
				S_data_write_a <= Mult2_buff;
				//----------------------------------------------------------------------
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_5;
			end
			S_MS_A_5: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= -12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= -12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------	
				S_wren_a <= 0;
				S_dataRow_a <= S_dataRow_a + 1;
				//----------------------------------------------------------------------
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------			
				M2_state <= S_MS_A_6;
			end
			S_MS_A_6: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= -12'd1702;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= -12'd399;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= 12'd2008;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= -12'd1137;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				S_wren_a <= 1;
				S_data_write_a <= Mult3_buff;
				//----------------------------------------------------------------------
				FETCH_dataRow <= FETCH_dataRow + 1;
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------			
				M2_state <= S_MS_A_7;
			end
			S_MS_A_7: begin
				T_dataRow_b <= T_dataRow_b + 1;
				T_dataCol_b <= T_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= -12'd783;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= 12'd1892;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= -12'd1892;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= 12'd783;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------	
				S_wren_a <= 0;
				S_dataRow_a <= S_dataRow_a + 1;
				//----------------------------------------------------------------------
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_8;
			end
			S_MS_A_8: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd2008;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= -12'd1702;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= 12'd1137;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= -12'd399;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				S_wren_a <= 1;
				S_data_write_a <= Mult4_buff;
				//----------------------------------------------------------------------
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_9;
			end
			S_MS_A_9: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= 12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= 12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= 0;
				Mult2_sum <= 0;
				Mult3_sum <= 0;					
				Mult4_sum <= 0;
				Mult1_buff <= (Mult1_sum + Mult1_result) >>> 16;
				Mult2_buff <= (Mult2_sum + Mult2_result) >>> 16;	
				Mult3_buff <= (Mult3_sum + Mult3_result) >>> 16;
				Mult4_buff <= (Mult4_sum + Mult4_result) >>> 16;
				//----------------------------------------------------------------------
				S_wren_a <= 0;
				S_dataRow_a <= S_dataRow_a + 1;
				//----------------------------------------------------------------------
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataRow_a <= SP_dataRow_a + 1;
				SP_dataCol_a <= SP_dataCol_a + 1;
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_10;
			end
			S_MS_A_10: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd2008;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= 12'd1702;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= 12'd1137;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= 12'd399;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				S_wren_a <= 1;
				S_data_write_a <= Mult1_buff;
				//----------------------------------------------------------------------
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_11;
			end
			S_MS_A_11: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd1892;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= 12'd783;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= -12'd783;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= -12'd1892;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------	
				S_wren_a <= 0;
				S_dataRow_a <= S_dataRow_a + 1;
				//----------------------------------------------------------------------
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_12;
			end
			S_MS_A_12: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd1702;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= -12'd399;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= -12'd2008;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= -12'd1137;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				S_wren_a <= 1;
				S_data_write_a <= Mult2_buff;
				//----------------------------------------------------------------------
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_13;
			end
			S_MS_A_13: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= -12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= -12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------	
				S_wren_a <= 0;
				S_dataRow_a <= S_dataRow_a + 1;
				//----------------------------------------------------------------------
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------			
				M2_state <= S_MS_A_14;
			end
			S_MS_A_14: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd1137;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= -12'd2008;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= 12'd399;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= 12'd1702;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				S_wren_a <= 1;
				S_data_write_a <= Mult3_buff;
				//----------------------------------------------------------------------
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------			
				M2_state <= S_MS_A_15;
			end
			S_MS_A_15: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd783;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= -12'd1892;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= 12'd1892;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= -12'd783;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------	
				S_wren_a <= 0;
				S_dataRow_a <= S_dataRow_a + 1;
				//----------------------------------------------------------------------
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_16;
			end
			S_MS_A_16: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd399;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= -12'd1137;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= 12'd1702;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= -12'd2008;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				S_wren_a <= 1;
				S_data_write_a <= Mult4_buff;
				//----------------------------------------------------------------------
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				if (FETCH_dataRow < 'd7) begin
					M2_state <= S_MS_A_1;
				end else begin
					M2_state <= S_MS_A_LO_1;
				end				
			end
//----------------------------------------------------------------------
			S_MS_A_LO_1: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= 12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= 12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= 0;
				Mult2_sum <= 0;
				Mult3_sum <= 0;					
				Mult4_sum <= 0;
				Mult1_buff <= (Mult1_sum + Mult1_result) >>> 16;
				Mult2_buff <= (Mult2_sum + Mult2_result) >>> 16;	
				Mult3_buff <= (Mult3_sum + Mult3_result) >>> 16;
				Mult4_buff <= (Mult4_sum + Mult4_result) >>> 16;
				//----------------------------------------------------------------------
				S_wren_a <= 0;
				S_dataRow_a <= S_dataRow_a + 1;
				S_dataCol_a <= S_dataCol_a + 1;
				//----------------------------------------------------------------------
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;
				//----------------------------------------------------------------------			
				M2_state <= S_MS_A_LO_2;
			end
			S_MS_A_LO_2: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= -12'd399;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= -12'd1137;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= -12'd1702;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= -12'd2008;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				S_wren_a <= 1;
				S_data_write_a <= Mult1_buff;
				//----------------------------------------------------------------------
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_LO_3;
			end 
			S_MS_A_LO_3: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= -12'd1892;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= -12'd783;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= 12'd783;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= 12'd1892;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------	
				S_wren_a <= 0;
				S_dataRow_a <= S_dataRow_a + 1;
				//----------------------------------------------------------------------
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_LO_4;
			end
			S_MS_A_LO_4: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd1137;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= 12'd2008;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= 12'd399;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= -12'd1702;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				S_wren_a <= 1;
				S_data_write_a <= Mult2_buff;
				//----------------------------------------------------------------------
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_LO_5;
			end
			S_MS_A_LO_5: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= -12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= -12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------	
				S_wren_a <= 0;
				S_dataRow_a <= S_dataRow_a + 1;
				//----------------------------------------------------------------------
				M2_SRAM_address <= SRAM_FETCH_address;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------			
				M2_state <= S_MS_A_LO_6;
			end
			S_MS_A_LO_6: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= -12'd1702;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= -12'd399;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= 12'd2008;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= -12'd1137;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				S_wren_a <= 1;
				S_data_write_a <= Mult3_buff;
				//----------------------------------------------------------------------
				FETCH_dataRow <= FETCH_dataRow + 1;
				FETCH_dataCol <= FETCH_dataCol + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------			
				M2_state <= S_MS_A_LO_7;
			end
			S_MS_A_LO_7: begin
				T_dataRow_b <= T_dataRow_b + 1;
				T_dataCol_b <= T_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= -12'd783;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= 12'd1892;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= -12'd1892;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= 12'd783;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------	
				S_wren_a <= 0;
				S_dataRow_a <= S_dataRow_a + 1;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataCol_a <= SP_dataCol_a + 1;			
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_LO_8;
			end
			S_MS_A_LO_8: begin
				T_dataRow_b <= T_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= T_data_read_b;
				Mult1_op_1 <= 12'd2008;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= T_data_read_b;
				Mult2_op_1 <= -12'd1702;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= T_data_read_b;
				Mult3_op_1 <= 12'd1137;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= T_data_read_b;
				Mult4_op_1 <= -12'd399;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				S_wren_a <= 1;
				S_data_write_a <= Mult4_buff;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_LO_9;
			end
			S_MS_A_LO_9: begin
				Mult1_sum <= 0;
				Mult2_sum <= 0;
				Mult3_sum <= 0;					
				Mult4_sum <= 0;
				Mult1_buff <= (Mult1_sum + Mult1_result) >>> 16;
				Mult2_buff <= (Mult2_sum + Mult2_result) >>> 16;	
				Mult3_buff <= (Mult3_sum + Mult3_result) >>> 16;
				Mult4_buff <= (Mult4_sum + Mult4_result) >>> 16;
				//----------------------------------------------------------------------
				S_wren_a <= 0;
				S_dataRow_a <= S_dataRow_a + 1;
				//----------------------------------------------------------------------
				SP_wren_a <= 0;
				SP_dataRow_a <= SP_dataRow_a + 1;
				SP_dataCol_a <= SP_dataCol_a + 1;
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_LO_10;
			end
			S_MS_A_LO_10: begin
				S_wren_a <= 1;
				S_data_write_a <= Mult1_buff;
				//----------------------------------------------------------------------
				SP_wren_a <= 1;
				SP_data_write_a <= M2_SRAM_read_data;
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_LO_11;
			end
			S_MS_A_LO_11: begin
				S_wren_a <= 0;
				S_dataRow_a <= S_dataRow_a + 1;
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_LO_12;
			end
			S_MS_A_LO_12: begin
				S_wren_a <= 1;
				S_data_write_a <= Mult2_buff;
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_LO_13;
			end
			S_MS_A_LO_13: begin
				S_wren_a <= 0;
				S_dataRow_a <= S_dataRow_a + 1;
				//----------------------------------------------------------------------			
				M2_state <= S_MS_A_LO_14;
			end
			S_MS_A_LO_14: begin
				S_wren_a <= 1;
				S_data_write_a <= Mult3_buff;
				//----------------------------------------------------------------------			
				M2_state <= S_MS_A_LO_15;
			end
			S_MS_A_LO_15: begin
				S_wren_a <= 0;
				S_dataRow_a <= S_dataRow_a + 1;
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_LO_16;
			end
			S_MS_A_LO_16: begin
				S_wren_a <= 1;
				S_data_write_a <= Mult4_buff;
				//----------------------------------------------------------------------
				M2_state <= S_MS_A_LO_17;
			end
			S_MS_A_LO_17: begin
				S_wren_a <= 0;
				SP_wren_a <= 0;
				//----------------------------------------------------------------------
				M2_state <= S_MS_B_LI_00;
			end
//----------------------------------------------------------------------
			S_MS_B_LI_00: begin
			
				M2_state <= S_MS_B_LI_01;
			end
			S_MS_B_LI_01: begin
				SP_wren_b <= 0;
				SP_dataCol_b <= 0;
				SP_dataRow_b <= 0;
				
				T_wren_a <= 0;
				T_dataRow_a <= 0;
				T_dataCol_a <= 0;
				
				M2_SRAM_we_n <= 1;
				
				S_wren_b <= 0;
				S_dataCol_b <= 0;
				S_dataRow_b <= 0;
				
				M2_state <= S_MS_B_LI_02;
			end
			S_MS_B_LI_02: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				M2_state <= S_MS_B_LI_9;
			end			
			S_MS_B_LI_9: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= 0;
				Mult2_sum <= 0;
				Mult3_sum <= 0;					
				Mult4_sum <= 0;
				//----------------------------------------------------------------------
				M2_state <= S_MS_B_LI_10;
			end			
			S_MS_B_LI_10: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd2008;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd1702;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1137;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd399;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				YUV_buffer <= S_data_read_b;
				//----------------------------------------------------------------------
				S_dataCol_b <= S_dataCol_b + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_LI_11;
			end			
			S_MS_B_LI_11: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1892;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd783;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd783;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd1892;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				M2_state <= S_MS_B_LI_12;
			end			
			S_MS_B_LI_12: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1702;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd399;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd2008;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd1137;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				M2_SRAM_we_n <= 0;
				M2_SRAM_address <= SRAM_YUV_address;
				M2_SRAM_write_data <= {YUV_buffer[7:0],S_data_read_b[7:0]};
				//----------------------------------------------------------------------
				S_dataCol_b <= S_dataCol_b + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_LI_13;
			end			
			S_MS_B_LI_13: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				M2_SRAM_we_n <= 1;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_LI_14;
			end			
			S_MS_B_LI_14: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1137;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd2008;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd399;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1702;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				YUV_buffer <= S_data_read_b;
				//----------------------------------------------------------------------
				S_dataCol_b <= S_dataCol_b + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_LI_15;
			end			
			S_MS_B_LI_15: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd783;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1892;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1892;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd783;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				YUV_dataCol <= YUV_dataCol + 2;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_LI_16;
			end				
			S_MS_B_LI_16: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd399;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1137;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1702;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd2008;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_dataCol_a <= 'd7;
				T_dataRow_a <= 'd7;
				//----------------------------------------------------------------------
				M2_SRAM_we_n <= 0;
				M2_SRAM_address <= SRAM_YUV_address;
				M2_SRAM_write_data <= {YUV_buffer[7:0],S_data_read_b[7:0]};
				//----------------------------------------------------------------------
				S_dataCol_b <= S_dataCol_b + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_1;
			end			
//----------------------------------------------------------------------
			S_MS_B_1: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= 0;
				Mult2_sum <= 0;
				Mult3_sum <= 0;					
				Mult4_sum <= 0;
				Mult1_buff <= (Mult1_sum + Mult1_result) >>> 8;
				Mult2_buff <= (Mult2_sum + Mult2_result) >>> 8;	
				Mult3_buff <= (Mult3_sum + Mult3_result) >>> 8;
				Mult4_buff <= (Mult4_sum + Mult4_result) >>> 8;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;				
				T_dataRow_a <= T_dataRow_a + 1;
				//----------------------------------------------------------------------
				M2_SRAM_we_n <= 1;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_2;
			end
			S_MS_B_2: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= -12'd399;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1137;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd1702;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd2008;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult1_buff;
				//----------------------------------------------------------------------
				YUV_buffer <= S_data_read_b;
				//----------------------------------------------------------------------
				S_dataCol_b <= S_dataCol_b + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_3;
			end
			S_MS_B_3: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= -12'd1892;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd783;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd783;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1892;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------
				YUV_dataCol <= YUV_dataCol + 2;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_4;
			end
			S_MS_B_4: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1137;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd2008;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd399;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd1702;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult2_buff;
				//----------------------------------------------------------------------
				M2_SRAM_we_n <= 0;
				M2_SRAM_address <= SRAM_YUV_address;
				M2_SRAM_write_data <= {YUV_buffer[7:0],S_data_read_b[7:0]};
				//----------------------------------------------------------------------
				S_dataCol_b <= S_dataCol_b + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_5;
			end
			S_MS_B_5: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------
				M2_SRAM_we_n <= 1;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_6;
			end
			S_MS_B_6: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= -12'd1702;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd399;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd2008;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd1137;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult3_buff;
				//----------------------------------------------------------------------
				YUV_buffer <= S_data_read_b;
				//----------------------------------------------------------------------
				S_dataCol_b <= S_dataCol_b + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_7;
			end
			S_MS_B_7: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				SP_dataRow_b <= SP_dataRow_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= -12'd783;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd1892;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd1892;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd783;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------
				YUV_dataCol <= YUV_dataCol + 2;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_8;
			end
			S_MS_B_8: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd2008;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1702;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1137;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd399;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult4_buff;
				//----------------------------------------------------------------------
				M2_SRAM_we_n <= 0;
				M2_SRAM_address <= SRAM_YUV_address;
				M2_SRAM_write_data <= {YUV_buffer[7:0],S_data_read_b[7:0]};
				//----------------------------------------------------------------------
				S_dataCol_b <= S_dataCol_b + 1;
				S_dataRow_b <= S_dataRow_b + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_9;
			end
			S_MS_B_9: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= 0;
				Mult2_sum <= 0;
				Mult3_sum <= 0;					
				Mult4_sum <= 0;
				Mult1_buff <= (Mult1_sum + Mult1_result) >>> 8;
				Mult2_buff <= (Mult2_sum + Mult2_result) >>> 8;	
				Mult3_buff <= (Mult3_sum + Mult3_result) >>> 8;
				Mult4_buff <= (Mult4_sum + Mult4_result) >>> 8;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;				
				//----------------------------------------------------------------------
				M2_SRAM_we_n <= 1;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_10;
			end
			S_MS_B_10: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd2008;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd1702;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1137;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd399;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult1_buff;
				//----------------------------------------------------------------------
				YUV_buffer <= S_data_read_b;
				//----------------------------------------------------------------------
				S_dataCol_b <= S_dataCol_b + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_11;
			end
			S_MS_B_11: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1892;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd783;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd783;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd1892;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------
				YUV_dataCol <= YUV_dataCol + 2;
				YUV_dataRow <= YUV_dataRow + 1;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_12;
			end
			S_MS_B_12: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1702;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd399;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd2008;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd1137;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult2_buff;
				//----------------------------------------------------------------------
				M2_SRAM_we_n <= 0;
				M2_SRAM_address <= SRAM_YUV_address;
				M2_SRAM_write_data <= {YUV_buffer[7:0],S_data_read_b[7:0]};
				//----------------------------------------------------------------------
				S_dataCol_b <= S_dataCol_b + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_13;
			end
			S_MS_B_13: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------
				M2_SRAM_we_n <= 1;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_14;
			end
			S_MS_B_14: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1137;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd2008;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd399;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1702;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult3_buff;
				//----------------------------------------------------------------------
				YUV_buffer <= S_data_read_b;
				//----------------------------------------------------------------------
				S_dataCol_b <= S_dataCol_b + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_15;
			end			
			S_MS_B_15: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd783;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1892;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1892;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd783;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------
				YUV_dataCol <= YUV_dataCol + 2;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_16;
			end			
			S_MS_B_16: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd399;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1137;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1702;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd2008;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult4_buff;
				//----------------------------------------------------------------------
				M2_SRAM_we_n <= 0;
				M2_SRAM_address <= SRAM_YUV_address;
				M2_SRAM_write_data <= {YUV_buffer[7:0],S_data_read_b[7:0]};
				//----------------------------------------------------------------------
				S_dataCol_b <= S_dataCol_b + 1;
				//----------------------------------------------------------------------							
				if (YUV_dataRow < 'd7) begin
					M2_state <= S_MS_B_1;
				end else begin
					M2_state <= S_MS_B_LO_1;
				end					
			end
//----------------------------------------------------------------------
			S_MS_B_LO_1: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= 0;
				Mult2_sum <= 0;
				Mult3_sum <= 0;					
				Mult4_sum <= 0;
				Mult1_buff <= (Mult1_sum + Mult1_result) >>> 8;
				Mult2_buff <= (Mult2_sum + Mult2_result) >>> 8;	
				Mult3_buff <= (Mult3_sum + Mult3_result) >>> 8;
				Mult4_buff <= (Mult4_sum + Mult4_result) >>> 8;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;				
				T_dataRow_a <= T_dataRow_a + 1;
				//----------------------------------------------------------------------
				M2_SRAM_we_n <= 1;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_LO_2;
			end
			S_MS_B_LO_2: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= -12'd399;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1137;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd1702;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd2008;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult1_buff;
				//----------------------------------------------------------------------
				YUV_buffer <= S_data_read_b;
				//----------------------------------------------------------------------
				S_dataCol_b <= S_dataCol_b + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_LO_3;
			end
			S_MS_B_LO_3: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= -12'd1892;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd783;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd783;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1892;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------
				YUV_dataCol <= YUV_dataCol + 2;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_LO_4;
			end
			S_MS_B_LO_4: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1137;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd2008;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd399;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd1702;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult2_buff;
				//----------------------------------------------------------------------
				M2_SRAM_we_n <= 0;
				M2_SRAM_address <= SRAM_YUV_address;
				M2_SRAM_write_data <= {YUV_buffer[7:0],S_data_read_b[7:0]};
				//----------------------------------------------------------------------
				S_dataCol_b <= S_dataCol_b + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_LO_5;
			end
			S_MS_B_LO_5: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd1448;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1448;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd1448;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd1448;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------
				M2_SRAM_we_n <= 1;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_LO_6;
			end
			S_MS_B_LO_6: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= -12'd1702;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd399;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd2008;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd1137;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult3_buff;
				//----------------------------------------------------------------------
				YUV_buffer <= S_data_read_b;
				//----------------------------------------------------------------------
				S_dataCol_b <= S_dataCol_b + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_LO_7;
			end
			S_MS_B_LO_7: begin
				SP_dataCol_b <= SP_dataCol_b + 1;
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= -12'd783;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= 12'd1892;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= -12'd1892;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= 12'd783;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------
				YUV_dataCol <= YUV_dataCol + 2;
//				YUV_dataRow <= YUV_dataRow + 1;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_LO_8;
			end
			S_MS_B_LO_8: begin
				// Mult 1 --------------------------------------------------------------
				Mult1_op_2 <= SP_data_read_b;
				Mult1_op_1 <= 12'd2008;
				// Mult 2 --------------------------------------------------------------
				Mult2_op_2 <= SP_data_read_b;
				Mult2_op_1 <= -12'd1702;
				// Mult 3 --------------------------------------------------------------
				Mult3_op_2 <= SP_data_read_b;
				Mult3_op_1 <= 12'd1137;
				// Mult 4 --------------------------------------------------------------
				Mult4_op_2 <= SP_data_read_b;
				Mult4_op_1 <= -12'd399;	
				//----------------------------------------------------------------------
				Mult1_sum <= Mult1_sum + Mult1_result;
				Mult2_sum <= Mult2_sum + Mult2_result;	
				Mult3_sum <= Mult3_sum + Mult3_result;
				Mult4_sum <= Mult4_sum + Mult4_result;
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult4_buff;
				//----------------------------------------------------------------------
				M2_SRAM_we_n <= 0;
				M2_SRAM_address <= SRAM_YUV_address;
				M2_SRAM_write_data <= {YUV_buffer[7:0],S_data_read_b[7:0]};
				//----------------------------------------------------------------------
				S_dataCol_b <= S_dataCol_b + 1;
				S_dataRow_b <= S_dataRow_b + 1;
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_LO_9;
			end
			S_MS_B_LO_9: begin
				// Mult 1 --------------------------------------------------------------
				// Mult 2 --------------------------------------------------------------
				// Mult 3 --------------------------------------------------------------
				// Mult 4 --------------------------------------------------------------
				//----------------------------------------------------------------------
				Mult1_sum <= 0;
				Mult2_sum <= 0;
				Mult3_sum <= 0;					
				Mult4_sum <= 0;
				Mult1_buff <= (Mult1_sum + Mult1_result) >>> 8;
				Mult2_buff <= (Mult2_sum + Mult2_result) >>> 8;	
				Mult3_buff <= (Mult3_sum + Mult3_result) >>> 8;
				Mult4_buff <= (Mult4_sum + Mult4_result) >>> 8;
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;				
				//----------------------------------------------------------------------
				M2_SRAM_we_n <= 1;
				YUV_dataCol <= YUV_dataCol + 2;
				YUV_dataRow <= YUV_dataRow + 1;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_LO_10;
			end
			S_MS_B_LO_10: begin
				// Mult 1 --------------------------------------------------------------
				// Mult 2 --------------------------------------------------------------
				// Mult 3 --------------------------------------------------------------
				// Mult 4 --------------------------------------------------------------
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult1_buff;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_LO_11;
			end
			S_MS_B_LO_11: begin
				// Mult 1 --------------------------------------------------------------
				// Mult 2 --------------------------------------------------------------
				// Mult 3 --------------------------------------------------------------
				// Mult 4 --------------------------------------------------------------
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_LO_12;
			end
			S_MS_B_LO_12: begin
				// Mult 1 --------------------------------------------------------------
				// Mult 2 --------------------------------------------------------------
				// Mult 3 --------------------------------------------------------------
				// Mult 4 --------------------------------------------------------------
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult2_buff;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_LO_13;
			end
			S_MS_B_LO_13: begin
				// Mult 1 --------------------------------------------------------------
				// Mult 2 --------------------------------------------------------------
				// Mult 3 --------------------------------------------------------------
				// Mult 4 --------------------------------------------------------------
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_LO_14;
			end
			S_MS_B_LO_14: begin
				// Mult 1 --------------------------------------------------------------
				// Mult 2 --------------------------------------------------------------
				// Mult 3 --------------------------------------------------------------
				// Mult 4 --------------------------------------------------------------
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult3_buff;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_LO_15;
			end		
			S_MS_B_LO_15: begin
				// Mult 1 --------------------------------------------------------------
				// Mult 2 --------------------------------------------------------------
				// Mult 3 --------------------------------------------------------------
				// Mult 4 --------------------------------------------------------------
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				T_wren_a <= 0;
				T_dataCol_a <= T_dataCol_a + 1;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_LO_16;
			end			
			S_MS_B_LO_16: begin
				// Mult 1 --------------------------------------------------------------
				// Mult 2 --------------------------------------------------------------
				// Mult 3 --------------------------------------------------------------
				// Mult 4 --------------------------------------------------------------
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				T_wren_a <= 1;
				T_data_write_a <= Mult4_buff;
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------
				//----------------------------------------------------------------------				
				M2_state <= S_MS_B_LO_17;
				//----------------------------------------------------------------------				
			end
			S_MS_B_LO_17: begin
				T_wren_a <= 0;
				//----------------------------------------------------------------------
				M2_state <= S_MEGASTATE_END;
			end			
			S_MEGASTATE_END: begin
				if (FETCH_Y_to_UV_flag == 0) begin
					if (FETCH_blockCol < 'd39) begin
						FETCH_blockCol <= FETCH_blockCol + 1;
						YUV_blockCol <= YUV_blockCol + 1;
						M2_state <= S_MS_A_LI_00;
					end else if (FETCH_blockRow < 'd29) begin
						FETCH_blockRow <= FETCH_blockRow + 1;
						YUV_blockRow <= YUV_blockRow + 1;
						FETCH_blockCol <= 0;
						YUV_blockCol <= 0;
						M2_state <= S_MS_A_LI_00;
					end else begin
						FETCH_Y_to_UV_flag <= 1;
						YUV_Y_to_UV_flag <= 1;
						FETCH_blockRow <= 0;
						FETCH_blockCol <= 0;
						YUV_blockRow <= 0;
						YUV_blockCol <= 0;
						M2_state <= S_MS_A_LI_00;
					end
				end else begin
					if (FETCH_blockCol < 'd19) begin
						FETCH_blockCol <= FETCH_blockCol + 1;
						YUV_blockCol <= YUV_blockCol + 1;
						M2_state <= S_MS_A_LI_00;
					end else if (FETCH_blockRow < 'd59) begin // U and V together take 59 rows
						FETCH_blockRow <= FETCH_blockRow + 1;
						YUV_blockRow <= YUV_blockRow + 1;
						FETCH_blockCol <= 0;
						YUV_blockCol <= 0;
						M2_state <= S_MS_A_LI_00;
					end else begin
						M2_end <=1;
						M2_state <= S_M2_IDLE;
					end 
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

always_comb begin
	// SRAM address to FETCH data
	FETCH_rowAddress = {FETCH_blockRow,3'b0} + FETCH_dataRow;
	FETCH_colAddress = {FETCH_blockCol,3'b0} + FETCH_dataCol;
	if (FETCH_Y_to_UV_flag == 0) begin
		SRAM_FETCH_address = SRAM_FETCH_Y_OFFSET + {FETCH_rowAddress, 8'b0} + {FETCH_rowAddress, 6'b0} + FETCH_colAddress;
	end else begin
		SRAM_FETCH_address = SRAM_FETCH_UV_OFFSET + {FETCH_rowAddress, 7'b0} + {FETCH_rowAddress, 5'b0} + FETCH_colAddress;
	end
	// address to write data in SP DPRAM
	SP_address_a = {SP_dataRow_a,3'b0} + SP_dataCol_a;

	// address to read data from SP DPRAM
	SP_address_b = {SP_dataRow_b,3'b0} + SP_dataCol_b;
	
	// address to write data in T DPRAM
	T_address_a = {T_dataRow_a,3'b0} + T_dataCol_a;
	
	// address to read data from T DPRAM
	T_address_b = {T_dataRow_b,3'b0} + T_dataCol_b;
	
	// address to write data in S DPRAM
	S_address_a = {S_dataRow_a,3'b0} + S_dataCol_a;

	// address to read data from S DPRAM
	S_address_b = {S_dataRow_b,3'b0} + S_dataCol_b;
	
	// SRAM address to write YUV data
	YUV_rowAddress = {YUV_blockRow,3'b0} + YUV_dataRow;
	YUV_colAddress = {YUV_blockCol,2'b0} + (YUV_dataCol >>> 1);
	if (YUV_Y_to_UV_flag == 0) begin
		SRAM_YUV_address = SRAM_YUV_Y_OFFSET + {YUV_rowAddress, 7'b0} + {YUV_rowAddress, 5'b0} + YUV_colAddress;
	end else begin
		SRAM_YUV_address = SRAM_YUV_UV_OFFSET + {YUV_rowAddress, 6'b0} + {YUV_rowAddress, 4'b0} + YUV_colAddress;
	end	

end
	
endmodule