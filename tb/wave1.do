onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/i_clk_rst_gen/clk_soc_o
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/i_clk_rst_gen/clk_per_o
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/i_clk_rst_gen/clk_cluster_o
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/i_clk_rst_gen/ref_clk_i
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_lint_fc_instr_bus/add
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_lint_fc_instr_bus/r_rdata
add wave -noupdate -group {load/store bus} /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_lint_fc_data_bus/add
add wave -noupdate -group {load/store bus} /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_lint_fc_data_bus/req
add wave -noupdate -group {load/store bus} /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_lint_fc_data_bus/r_valid
add wave -noupdate -group {load/store bus} /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_lint_fc_data_bus/r_rdata
add wave -noupdate -group {load/store bus} /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_lint_fc_data_bus/wdata
add wave -noupdate -group {load/store bus} /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_lint_fc_data_bus/wen
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_mem_rom_bus/add
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_mem_rom_bus/req
add wave -noupdate -group apbt1_interface /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_efpga_subsystem/apbt1_interface/lint_rst
add wave -noupdate -group apbt1_interface /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_efpga_subsystem/apbt1_interface/lint_clk
add wave -noupdate -group apbt1_interface /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_efpga_subsystem/apbt1_interface/lint_req
add wave -noupdate -group apbt1_interface /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_efpga_subsystem/apbt1_interface/lint_gnt
add wave -noupdate -group apbt1_interface /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_efpga_subsystem/apbt1_interface/lint_fmo
add wave -noupdate -group apbt1_interface /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_efpga_subsystem/apbt1_interface/lint_valid
add wave -noupdate -group apbt1_interface /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_efpga_subsystem/apbt1_interface/lint_req_data
add wave -noupdate -group apbt1_interface /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_efpga_subsystem/apbt1_interface/efpga_req_data
add wave -noupdate -group apbt1_interface /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_efpga_subsystem/apbt1_interface/lint_rdata
add wave -noupdate -group apbt1_interface /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_efpga_subsystem/apbt1_interface/efpga_rst
add wave -noupdate -group apbt1_interface /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_efpga_subsystem/apbt1_interface/efpga_clk
add wave -noupdate -group apbt1_interface /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_efpga_subsystem/apbt1_interface/efpga_req
add wave -noupdate -group apbt1_interface /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_efpga_subsystem/apbt1_interface/efpga_gnt
add wave -noupdate -group apbt1_interface /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_efpga_subsystem/apbt1_interface/efpga_valid
add wave -noupdate -group apbt1_interface /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_efpga_subsystem/apbt1_interface/efpga_rdata
add wave -noupdate -group apbt1_interface /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_efpga_subsystem/apbt1_interface/req_push
add wave -noupdate -group apbt1_interface /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_efpga_subsystem/apbt1_interface/req_empty
add wave -noupdate -group apbt1_interface /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_efpga_subsystem/apbt1_interface/req_full
add wave -noupdate -group apbt1_interface /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_efpga_subsystem/apbt1_interface/resp_empty
add wave -noupdate -group APB /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_apb_periph_bus/paddr
add wave -noupdate -group APB /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_apb_periph_bus/pwdata
add wave -noupdate -group APB /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_apb_periph_bus/pwrite
add wave -noupdate -group APB /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_apb_periph_bus/psel
add wave -noupdate -group APB /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_apb_periph_bus/penable
add wave -noupdate -group APB /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_apb_periph_bus/prdata
add wave -noupdate -group APB /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_apb_periph_bus/pready
add wave -noupdate -group APB /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/s_apb_periph_bus/pslverr
add wave -noupdate -group UART0 /core_v_mcu_tb/uart_0/rx
add wave -noupdate -group UART0 /core_v_mcu_tb/uart_0/tx
add wave -noupdate -group UART1 /core_v_mcu_tb/uart_1/rx
add wave -noupdate -group UART1 /core_v_mcu_tb/uart_1/tx
add wave -noupdate -group QSPI /core_v_mcu_tb/qspi/cs
add wave -noupdate -group QSPI /core_v_mcu_tb/qspi/sclk
add wave -noupdate -group QSPI /core_v_mcu_tb/qspi/si
add wave -noupdate -group QSPI /core_v_mcu_tb/qspi/so
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_apb_soc_ctrl/wd_expired_o
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_apb_soc_ctrl/wd_current_count
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_apb_soc_ctrl/wd_count
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_apb_soc_ctrl/wd_enabled
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_apb_soc_ctrl/reset_reason
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_apb_soc_ctrl/por_reg
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_apb_soc_ctrl/wd_reset
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_apb_soc_ctrl/wd_cleared
add wave -noupdate /core_v_mcu_tb/core_v_mcu_i/i_soc_domain/soc_peripherals_i/i_apb_soc_ctrl/reset_reason_clear
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {78100962 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 196
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
WaveRestoreZoom {0 fs} {173557694 fs}
