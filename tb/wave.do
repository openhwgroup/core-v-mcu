onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/i_clk_rst_gen/i_sim_clk_gen/ref_clk_i
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/i_clk_rst_gen/i_sim_clk_gen/soc_clk_o
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/i_clk_rst_gen/i_sim_clk_gen/per_clk_o
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/i_clk_rst_gen/i_sim_clk_gen/cluster_clk_o
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_lint_fc_instr_bus/add
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_lint_fc_instr_bus/r_rdata
add wave -noupdate -expand -group {load/store bus} /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_lint_fc_data_bus/add
add wave -noupdate -expand -group {load/store bus} /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_lint_fc_data_bus/req
add wave -noupdate -expand -group {load/store bus} /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_lint_fc_data_bus/r_valid
add wave -noupdate -expand -group {load/store bus} /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_lint_fc_data_bus/r_rdata
add wave -noupdate -expand -group {load/store bus} /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_lint_fc_data_bus/wdata
add wave -noupdate -expand -group {load/store bus} /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_lint_fc_data_bus/wen
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_mem_rom_bus/add
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_mem_rom_bus/req
add wave -noupdate -expand -group APB /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_apb_periph_bus/paddr
add wave -noupdate -expand -group APB /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_apb_periph_bus/pwdata
add wave -noupdate -expand -group APB /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_apb_periph_bus/pwrite
add wave -noupdate -expand -group APB /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_apb_periph_bus/psel
add wave -noupdate -expand -group APB /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_apb_periph_bus/penable
add wave -noupdate -expand -group APB /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_apb_periph_bus/prdata
add wave -noupdate -expand -group APB /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_apb_periph_bus/pready
add wave -noupdate -expand -group APB /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_apb_periph_bus/pslverr
add wave -noupdate -expand -group UART0 {/core_v_mcu_tb/io_t[7]}
add wave -noupdate -expand -group UART0 {/core_v_mcu_tb/io_t[8]}
add wave -noupdate -expand -group UART1 {/core_v_mcu_tb/io_t[9]}
add wave -noupdate -expand -group UART1 {/core_v_mcu_tb/io_t[10]}
add wave -noupdate -expand -group QSPI {/core_v_mcu_tb/io_t[13]}
add wave -noupdate -expand -group QSPI {/core_v_mcu_tb/io_t[14]}
add wave -noupdate -expand -group QSPI {/core_v_mcu_tb/io_t[15]}
add wave -noupdate -expand -group QSPI {/core_v_mcu_tb/io_t[16]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3278413 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {3247745 ps} {3350849 ps}
