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
				M2_state <= S_LOAD_SP_LO_11;
			end
