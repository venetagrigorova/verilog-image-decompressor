

# add waves to waveform
add wave Clock_50
#add wave -binary uut/milestone1_unit/Resetn

#add wave -divider {Milestone1}
#add wave uut/SRAM_we_n
add wave -hexadecimal uut/top_state

add wave -divider {Milestone 2}
add wave -hexadecimal uut/milestone2_unit/M2_state
#add wave -binary uut/milestone2_unit/M2_start
#add wave -binary uut/milestone2_unit/M2_end

add wave -divider {FETCH}
#add wave -unsigned uut/milestone2_unit/FETCH_blockRow
#add wave -unsigned uut/milestone2_unit/FETCH_blockCol
#add wave -unsigned uut/milestone2_unit/FETCH_dataRow
#add wave -unsigned uut/milestone2_unit/FETCH_dataCol
add wave -unsigned uut/milestone2_unit/SRAM_FETCH_address
add wave -decimal uut/milestone2_unit/M2_SRAM_read_data

add wave -divider {S Prime}
add wave -unsigned uut/milestone2_unit/SP_dataRow_a
add wave -unsigned uut/milestone2_unit/SP_dataCol_a
add wave -unsigned uut/milestone2_unit/SP_address_a
add wave -unsigned uut/milestone2_unit/SP_wren_a
add wave -decimal uut/milestone2_unit/SP_data_write_a
add wave -unsigned uut/milestone2_unit/SP_dataRow_b
add wave -unsigned uut/milestone2_unit/SP_dataCol_b
add wave -unsigned uut/milestone2_unit/SP_address_b
add wave -unsigned uut/milestone2_unit/SP_wren_b
add wave -decimal uut/milestone2_unit/SP_data_read_b

add wave -divider {Multipliers}
add wave -signed uut/milestone2_unit/Mult1_op_1
add wave -signed uut/milestone2_unit/Mult1_op_2
add wave -signed uut/milestone2_unit/Mult1_result_long
add wave -signed uut/milestone2_unit/Mult2_op_1
add wave -signed uut/milestone2_unit/Mult2_op_2
add wave -signed uut/milestone2_unit/Mult2_result_long
add wave -signed uut/milestone2_unit/Mult3_op_1
add wave -signed uut/milestone2_unit/Mult3_op_2
add wave -signed uut/milestone2_unit/Mult3_result_long
add wave -signed uut/milestone2_unit/Mult4_op_1
add wave -signed uut/milestone2_unit/Mult4_op_2
add wave -signed uut/milestone2_unit/Mult4_result_long

add wave -divider {T}
add wave -unsigned uut/milestone2_unit/T_dataRow_a
add wave -unsigned uut/milestone2_unit/T_dataCol_a
add wave -unsigned uut/milestone2_unit/T_address_a
add wave -unsigned uut/milestone2_unit/T_wren_a
add wave -unsigned uut/milestone2_unit/T_data_write_a
add wave -unsigned uut/milestone2_unit/T_dataRow_b
add wave -unsigned uut/milestone2_unit/T_dataCol_b
add wave -unsigned uut/milestone2_unit/T_address_b
add wave -unsigned uut/milestone2_unit/T_wren_b
add wave -unsigned uut/milestone2_unit/T_data_read_b

#add wave -divider {S}
#add wave -unsigned uut/milestone2_unit/S_dataRow_a
#add wave -unsigned uut/milestone2_unit/S_dataCol_a
#add wave -unsigned uut/milestone2_unit/S_address_a
#add wave -unsigned uut/milestone2_unit/S_wren_a
#add wave -unsigned uut/milestone2_unit/S_data_write_a
#add wave -unsigned uut/milestone2_unit/S_dataRow_b
#add wave -unsigned uut/milestone2_unit/S_dataCol_b
#add wave -unsigned uut/milestone2_unit/S_address_b

#add wave -divider {YUV}
#add wave -unsigned uut/milestone2_unit/YUV_blockRow
#add wave -unsigned uut/milestone2_unit/YUV_blockCol
#add wave -unsigned uut/milestone2_unit/YUV_dataRow
#add wave -unsigned uut/milestone2_unit/YUV_dataCol
#add wave -unsigned uut/milestone2_unit/SRAM_YUV_address
#add wave -hexadecimal uut/milestone2_unit/M2_SRAM_write_data
#add wave -unsigned uut/milestone2_unit/M2_SRAM_we_n
#add wave -binary uut/milestone2_unit/FETCH_Y_to_UV_flag
#add wave -binary uut/milestone2_unit/YUV_Y_to_UV_flag

#add wave -divider {Milestone 1}
#add wave -hexadecimal uut/milestone1_unit/M1_state
#add wave -binary uut/milestone1_unit/M1_start
#add wave -binary uut/milestone1_unit/M1_end

#add wave -unsigned uut/SRAM_address
#add wave -unsigned uut/milestone1_unit/RGB_address
#add wave -unsigned uut/milestone1_unit/COL_counter
#add wave -unsigned uut/milestone1_unit/ROW_counter
#add wave -unsigned uut/milestone1_unit/Y_address
#add wave -unsigned uut/milestone1_unit/UV_address

#add wave -divider {Received values}
#add wave -hexadecimal uut/milestone1_unit/M1_SRAM_read_data
#add wave -hexadecimal uut/milestone1_unit/Y_buff
#add wave -hexadecimal uut/milestone1_unit/U_even
#add wave -hexadecimal uut/milestone1_unit/V_even

add wave -divider {SRAM write data}
add wave -hexadecimal uut/SRAM_unit/SRAM_write_data

#add wave -divider {Multiplier1}
#add wave -unsigned uut/milestone1_unit/Mult1_op_2
#add wave -unsigned uut/milestone1_unit/Mult1_op_1
#add wave -unsigned uut/milestone1_unit/Mult1_result
#add wave -decimal uut/milestone1_unit/U_odd_sum
#add wave -unsigned uut/milestone1_unit/U_odd

#add wave -divider {Multiplier2}
#add wave -unsigned uut/milestone1_unit/Mult2_op_2
#add wave -unsigned uut/milestone1_unit/Mult2_op_1
#add wave -unsigned uut/milestone1_unit/Mult2_result
#add wave -decimal uut/milestone1_unit/V_odd_sum
#add wave -unsigned uut/milestone1_unit/V_odd

#add wave -divider {Multiplier3}
#add wave -unsigned uut/milestone1_unit/Mult3_op_2
#add wave -unsigned uut/milestone1_unit/Mult3_op_1
#add wave -unsigned uut/milestone1_unit/Mult3_result
#add wave -decimal uut/milestone1_unit/R_odd_sum
#add wave -decimal uut/milestone1_unit/G_odd_sum
#add wave -decimal uut/milestone1_unit/B_odd_sum
#add wave -unsigned uut/milestone1_unit/R_odd
#add wave -unsigned uut/milestone1_unit/G_odd
#add wave -unsigned uut/milestone1_unit/B_odd

#add wave -divider {Multiplier4}
#add wave -unsigned uut/milestone1_unit/Mult4_op_2
#add wave -unsigned uut/milestone1_unit/Mult4_op_1
#add wave -unsigned uut/milestone1_unit/Mult4_result
#add wave -decimal uut/milestone1_unit/R_even_sum
#add wave -decimal uut/milestone1_unit/G_even_sum
#add wave -decimal uut/milestone1_unit/B_even_sum
#add wave -unsigned uut/milestone1_unit/R_even
#add wave -unsigned uut/milestone1_unit/G_even
#add wave -unsigned uut/milestone1_unit/B_even











