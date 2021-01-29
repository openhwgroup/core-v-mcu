module eFPGA_wrapper (

   // Outputs
   fcb_sysclk_en, fcb_spis_miso_en, fcb_spis_miso, fcb_spim_mosi_en,
   fcb_spim_mosi, fcb_spim_cs_n_en, fcb_spim_cs_n, fcb_spim_ckout_en,
   fcb_spim_ckout, fcb_spi_master_status, fcb_set_por, fcb_rst,
   fcb_pif_vldo_en, fcb_pif_vldo, fcb_pif_do_l_en, fcb_pif_do_l,
   fcb_pif_do_h_en, fcb_pif_do_h,

   fcb_cfg_done_en, fcb_cfg_done,
   fcb_apbs_pslverr, fcb_apbs_pready, fcb_apbs_prdata,
   fcb_apbm_ramfifo_sel, fcb_apbm_pwrite, fcb_apbm_pwdata,
   fcb_apbm_psel, fcb_apbm_penable, fcb_apbm_paddr, fcb_apbm_mclk,
   FB_SPE_OUT_3_, FB_SPE_OUT_2_, FB_SPE_OUT_1_, FB_SPE_OUT_0_,

   gpio_oe_0_o, gpio_data_0_o, gpio_oe_1_o, gpio_data_1_o, gpio_oe_2_o, gpio_data_2_o, gpio_oe_3_o, gpio_data_3_o, gpio_oe_4_o, gpio_data_4_o, gpio_oe_5_o, gpio_data_5_o, gpio_oe_6_o, gpio_data_6_o, gpio_oe_7_o, gpio_data_7_o, gpio_oe_20_o, gpio_data_20_o, gpio_oe_25_o, gpio_data_25_o, gpio_oe_26_o, gpio_data_26_o, gpio_oe_27_o, gpio_data_27_o, gpio_oe_21_o, gpio_data_21_o, gpio_oe_22_o, gpio_data_22_o, gpio_oe_23_o, gpio_data_23_o, gpio_oe_24_o, gpio_data_24_o, events_12_o, events_13_o, gpio_oe_19_o, gpio_data_19_o, events_14_o, events_15_o, gpio_oe_16_o, gpio_data_16_o, gpio_oe_17_o, gpio_data_17_o, gpio_oe_18_o, gpio_data_18_o, udma_cfg_data_26_o, udma_cfg_data_27_o, events_4_o, events_5_o, events_6_o, events_7_o, events_8_o, events_9_o, events_10_o, events_11_o, udma_cfg_data_28_o, udma_cfg_data_29_o, udma_cfg_data_30_o, udma_cfg_data_31_o, events_0_o, events_1_o, events_2_o, events_3_o, udma_cfg_data_14_o, udma_cfg_data_15_o, udma_cfg_data_24_o, udma_cfg_data_25_o, udma_cfg_data_16_o, udma_cfg_data_17_o, udma_cfg_data_18_o, udma_cfg_data_19_o, udma_cfg_data_20_o, udma_cfg_data_21_o, udma_cfg_data_22_o, udma_cfg_data_23_o, udma_rx_lin_data_28_o, udma_rx_lin_data_29_o, udma_cfg_data_6_o, udma_cfg_data_7_o, udma_cfg_data_8_o, udma_cfg_data_9_o, udma_cfg_data_10_o, udma_cfg_data_11_o, udma_cfg_data_12_o, udma_cfg_data_13_o, udma_rx_lin_data_30_o, udma_rx_lin_data_31_o, udma_cfg_data_0_o, udma_cfg_data_1_o, udma_cfg_data_2_o, udma_cfg_data_3_o, udma_cfg_data_4_o, udma_cfg_data_5_o, udma_rx_lin_data_16_o, udma_rx_lin_data_17_o, udma_rx_lin_data_26_o, udma_rx_lin_data_27_o, udma_rx_lin_data_18_o, udma_rx_lin_data_19_o, udma_rx_lin_data_20_o, udma_rx_lin_data_21_o, udma_rx_lin_data_22_o, udma_rx_lin_data_23_o, udma_rx_lin_data_24_o, udma_rx_lin_data_25_o, udma_tx_lin_ready_o, udma_rx_lin_valid_o, udma_rx_lin_data_8_o, udma_rx_lin_data_9_o, udma_rx_lin_data_10_o, udma_rx_lin_data_11_o, udma_rx_lin_data_12_o, udma_rx_lin_data_13_o, udma_rx_lin_data_14_o, udma_rx_lin_data_15_o, udma_rx_lin_data_0_o, udma_rx_lin_data_1_o, udma_rx_lin_data_2_o, udma_rx_lin_data_3_o, udma_rx_lin_data_4_o, udma_rx_lin_data_5_o, udma_rx_lin_data_6_o, udma_rx_lin_data_7_o, apb_hwce_prdata_0_o, apb_hwce_prdata_1_o, apb_hwce_prdata_10_o, apb_hwce_prdata_11_o, apb_hwce_prdata_2_o, apb_hwce_prdata_3_o, apb_hwce_prdata_4_o, apb_hwce_prdata_5_o, apb_hwce_prdata_6_o, apb_hwce_prdata_7_o, apb_hwce_prdata_8_o, apb_hwce_prdata_9_o, apb_hwce_prdata_12_o, apb_hwce_prdata_13_o, apb_hwce_prdata_22_o, apb_hwce_prdata_23_o, apb_hwce_prdata_24_o, apb_hwce_prdata_25_o, apb_hwce_prdata_26_o, apb_hwce_prdata_27_o, apb_hwce_prdata_28_o, apb_hwce_prdata_29_o, apb_hwce_prdata_14_o, apb_hwce_prdata_15_o, apb_hwce_prdata_16_o, apb_hwce_prdata_17_o, apb_hwce_prdata_18_o, apb_hwce_prdata_19_o, apb_hwce_prdata_20_o, apb_hwce_prdata_21_o, apb_hwce_prdata_30_o, apb_hwce_prdata_31_o, gpio_oe_31_o, gpio_data_31_o, apb_hwce_ready_o, apb_hwce_pslverr_o, gpio_oe_28_o, gpio_data_28_o, gpio_oe_29_o, gpio_data_29_o, gpio_oe_30_o, gpio_data_30_o, gpio_oe_32_o, gpio_data_32_o, gpio_oe_37_o, gpio_data_37_o, gpio_oe_38_o, gpio_data_38_o, gpio_oe_39_o, gpio_data_39_o, gpio_oe_40_o, gpio_data_40_o, gpio_oe_33_o, gpio_data_33_o, gpio_oe_34_o, gpio_data_34_o, gpio_oe_35_o, gpio_data_35_o, gpio_oe_36_o, gpio_data_36_o, tcdm_addr_p3_16_o, tcdm_wdata_p3_16_o, tcdm_wdata_p3_22_o, tcdm_wdata_p3_23_o, tcdm_wdata_p3_24_o, tcdm_wdata_p3_25_o, tcdm_wdata_p3_26_o, tcdm_wdata_p3_27_o, tcdm_wdata_p3_28_o, tcdm_wdata_p3_29_o, tcdm_addr_p3_17_o, tcdm_wdata_p3_17_o, tcdm_addr_p3_18_o, tcdm_wdata_p3_18_o, tcdm_addr_p3_19_o, tcdm_wdata_p3_19_o, tcdm_wdata_p3_20_o, tcdm_wdata_p3_21_o, tcdm_addr_p3_10_o, tcdm_wdata_p3_10_o, tcdm_addr_p3_15_o, tcdm_wdata_p3_15_o, tcdm_addr_p3_11_o, tcdm_wdata_p3_11_o, tcdm_addr_p3_12_o, tcdm_wdata_p3_12_o, tcdm_addr_p3_13_o, tcdm_wdata_p3_13_o, tcdm_addr_p3_14_o, tcdm_wdata_p3_14_o, tcdm_addr_p3_1_o, tcdm_wdata_p3_1_o, tcdm_addr_p3_6_o, tcdm_wdata_p3_6_o, tcdm_addr_p3_7_o, tcdm_wdata_p3_7_o, tcdm_addr_p3_8_o, tcdm_wdata_p3_8_o, tcdm_addr_p3_9_o, tcdm_wdata_p3_9_o, tcdm_addr_p3_2_o, tcdm_wdata_p3_2_o, tcdm_addr_p3_3_o, tcdm_wdata_p3_3_o, tcdm_addr_p3_4_o, tcdm_wdata_p3_4_o, tcdm_addr_p3_5_o, tcdm_wdata_p3_5_o, tcdm_wdata_p2_28_o, tcdm_wdata_p2_29_o, tcdm_addr_p3_0_o, tcdm_wdata_p3_0_o, tcdm_wdata_p2_30_o, tcdm_wdata_p2_31_o, tcdm_req_p2_o, tcdm_wen_p2_o, tcdm_be_p2_0_o, tcdm_be_p2_1_o, tcdm_be_p2_2_o, tcdm_be_p2_3_o, tcdm_addr_p2_15_o, tcdm_wdata_p2_15_o, tcdm_wdata_p2_20_o, tcdm_wdata_p2_21_o, tcdm_wdata_p2_22_o, tcdm_wdata_p2_23_o, tcdm_wdata_p2_24_o, tcdm_wdata_p2_25_o, tcdm_wdata_p2_26_o, tcdm_wdata_p2_27_o, tcdm_addr_p2_16_o, tcdm_wdata_p2_16_o, tcdm_addr_p2_17_o, tcdm_wdata_p2_17_o, tcdm_addr_p2_18_o, tcdm_wdata_p2_18_o, tcdm_addr_p2_19_o, tcdm_wdata_p2_19_o, tcdm_addr_p2_9_o, tcdm_wdata_p2_9_o, tcdm_addr_p2_14_o, tcdm_wdata_p2_14_o, tcdm_addr_p2_10_o, tcdm_wdata_p2_10_o, tcdm_addr_p2_11_o, tcdm_wdata_p2_11_o, tcdm_addr_p2_12_o, tcdm_wdata_p2_12_o, tcdm_addr_p2_13_o, tcdm_wdata_p2_13_o, tcdm_addr_p2_0_o, tcdm_wdata_p2_0_o, tcdm_addr_p2_5_o, tcdm_wdata_p2_5_o, tcdm_addr_p2_6_o, tcdm_wdata_p2_6_o, tcdm_addr_p2_7_o, tcdm_wdata_p2_7_o, tcdm_addr_p2_8_o, tcdm_wdata_p2_8_o, tcdm_addr_p2_1_o, tcdm_wdata_p2_1_o, tcdm_addr_p2_2_o, tcdm_wdata_p2_2_o, tcdm_addr_p2_3_o, tcdm_wdata_p2_3_o, tcdm_addr_p2_4_o, tcdm_wdata_p2_4_o, tcdm_addr_p0_0_o, tcdm_wdata_p0_0_o, tcdm_addr_p0_5_o, tcdm_wdata_p0_5_o, tcdm_addr_p0_1_o, tcdm_wdata_p0_1_o, tcdm_addr_p0_2_o, tcdm_wdata_p0_2_o, tcdm_addr_p0_3_o, tcdm_wdata_p0_3_o, tcdm_addr_p0_4_o, tcdm_wdata_p0_4_o, tcdm_addr_p0_6_o, tcdm_wdata_p0_6_o, tcdm_addr_p0_11_o, tcdm_wdata_p0_11_o, tcdm_addr_p0_12_o, tcdm_wdata_p0_12_o, tcdm_addr_p0_13_o, tcdm_wdata_p0_13_o, tcdm_addr_p0_14_o, tcdm_wdata_p0_14_o, tcdm_addr_p0_7_o, tcdm_wdata_p0_7_o, tcdm_addr_p0_8_o, tcdm_wdata_p0_8_o, tcdm_addr_p0_9_o, tcdm_wdata_p0_9_o, tcdm_addr_p0_10_o, tcdm_wdata_p0_10_o, tcdm_addr_p0_15_o, tcdm_wdata_p0_15_o, tcdm_wdata_p0_20_o, tcdm_wdata_p0_21_o, tcdm_addr_p0_16_o, tcdm_wdata_p0_16_o, tcdm_addr_p0_17_o, tcdm_wdata_p0_17_o, tcdm_addr_p0_18_o, tcdm_wdata_p0_18_o, tcdm_addr_p0_19_o, tcdm_wdata_p0_19_o, tcdm_wdata_p0_22_o, tcdm_wdata_p0_23_o, tcdm_req_p0_o, tcdm_wen_p0_o, tcdm_be_p0_0_o, tcdm_be_p0_1_o, tcdm_be_p0_2_o, tcdm_be_p0_3_o, tcdm_addr_p1_0_o, tcdm_wdata_p1_0_o, tcdm_wdata_p0_24_o, tcdm_wdata_p0_25_o, tcdm_wdata_p0_26_o, tcdm_wdata_p0_27_o, tcdm_wdata_p0_28_o, tcdm_wdata_p0_29_o, tcdm_wdata_p0_30_o, tcdm_wdata_p0_31_o, tcdm_addr_p1_1_o, tcdm_wdata_p1_1_o, tcdm_addr_p1_6_o, tcdm_wdata_p1_6_o, tcdm_addr_p1_2_o, tcdm_wdata_p1_2_o, tcdm_addr_p1_3_o, tcdm_wdata_p1_3_o, tcdm_addr_p1_4_o, tcdm_wdata_p1_4_o, tcdm_addr_p1_5_o, tcdm_wdata_p1_5_o, tcdm_addr_p1_7_o, tcdm_wdata_p1_7_o, tcdm_addr_p1_12_o, tcdm_wdata_p1_12_o, tcdm_addr_p1_13_o, tcdm_wdata_p1_13_o, tcdm_addr_p1_14_o, tcdm_wdata_p1_14_o, tcdm_addr_p1_15_o, tcdm_wdata_p1_15_o, tcdm_addr_p1_8_o, tcdm_wdata_p1_8_o, tcdm_addr_p1_9_o, tcdm_wdata_p1_9_o, tcdm_addr_p1_10_o, tcdm_wdata_p1_10_o, tcdm_addr_p1_11_o, tcdm_wdata_p1_11_o, tcdm_addr_p1_16_o, tcdm_wdata_p1_16_o, tcdm_wdata_p1_22_o, tcdm_wdata_p1_23_o, tcdm_addr_p1_17_o, tcdm_wdata_p1_17_o, tcdm_addr_p1_18_o, tcdm_wdata_p1_18_o, tcdm_addr_p1_19_o, tcdm_wdata_p1_19_o, tcdm_wdata_p1_20_o, tcdm_wdata_p1_21_o, tcdm_wdata_p1_24_o, tcdm_wdata_p1_25_o, tcdm_be_p1_0_o, tcdm_be_p1_1_o, tcdm_be_p1_2_o, tcdm_be_p1_3_o, gpio_oe_8_o, gpio_data_8_o, gpio_oe_9_o, gpio_data_9_o, tcdm_wdata_p1_26_o, tcdm_wdata_p1_27_o, tcdm_wdata_p1_28_o, tcdm_wdata_p1_29_o, tcdm_wdata_p1_30_o, tcdm_wdata_p1_31_o, tcdm_req_p1_o, tcdm_wen_p1_o, gpio_oe_10_o, gpio_data_10_o, gpio_oe_11_o, gpio_data_11_o, gpio_oe_14_o, gpio_data_14_o, gpio_oe_15_o, gpio_data_15_o, tcdm_wdata_p3_30_o, tcdm_wdata_p3_31_o, gpio_oe_13_o, gpio_data_13_o, tcdm_req_p3_o, tcdm_wen_p3_o, tcdm_be_p3_0_o, tcdm_be_p3_1_o, tcdm_be_p3_2_o, tcdm_be_p3_3_o, gpio_oe_12_o, gpio_data_12_o,
   // Inputs
   fcb_sys_stm, fcb_sys_rst_n, fcb_sys_clk, fcb_spis_rst_n,
   fcb_spis_mosi, fcb_spis_cs_n, fcb_spis_clk, fcb_spim_miso,
   fcb_spim_ckout_in, fcb_spi_mode_en_bo, fcb_spi_master_en,
   fcb_pif_vldi, fcb_pif_di_l, fcb_pif_di_h, fcb_pif_8b_mode_bo,
   fcb_apbs_pwrite, fcb_apbs_pwdata, fcb_apbs_pstrb, fcb_apbs_psel,
   fcb_apbs_pprot, fcb_apbs_penable, fcb_apbs_paddr,
   fcb_apbm_prdata_1, fcb_apbm_prdata_0, STM, POR, M_5_, M_4_, M_3_,
   M_2_, M_1_, M_0_, MLATCH, FB_SPE_IN_3_, FB_SPE_IN_2_, FB_SPE_IN_1_,
   FB_SPE_IN_0_,
   supplyBus,
   CLK0, CLK1, CLK2, CLK3, CLK4, CLK5, gpio_data_0_i, gpio_data_1_i, gpio_data_2_i, gpio_data_3_i, gpio_data_4_i, gpio_data_5_i, gpio_data_6_i, gpio_data_7_i, udma_cfg_data_8_i, udma_cfg_data_9_i, udma_cfg_data_10_i, udma_cfg_data_11_i, udma_cfg_data_12_i, udma_cfg_data_13_i, udma_cfg_data_14_i, udma_cfg_data_15_i, udma_cfg_data_2_i, udma_cfg_data_3_i, udma_cfg_data_4_i, udma_cfg_data_5_i, udma_cfg_data_6_i, udma_cfg_data_7_i, udma_tx_lin_data_27_i, udma_tx_lin_data_28_i, udma_tx_lin_data_29_i, udma_tx_lin_data_30_i, udma_tx_lin_data_31_i, udma_rx_lin_ready_i, udma_cfg_data_0_i, udma_cfg_data_1_i, udma_tx_lin_data_21_i, udma_tx_lin_data_22_i, udma_tx_lin_data_23_i, udma_tx_lin_data_24_i, udma_tx_lin_data_25_i, udma_tx_lin_data_26_i, udma_tx_lin_data_13_i, udma_tx_lin_data_14_i, udma_tx_lin_data_15_i, udma_tx_lin_data_16_i, udma_tx_lin_data_17_i, udma_tx_lin_data_18_i, udma_tx_lin_data_19_i, udma_tx_lin_data_20_i, udma_tx_lin_data_7_i, udma_tx_lin_data_8_i, udma_tx_lin_data_9_i, udma_tx_lin_data_10_i, udma_tx_lin_data_11_i, udma_tx_lin_data_12_i, udma_tx_lin_valid_i, udma_tx_lin_data_0_i, udma_tx_lin_data_1_i, udma_tx_lin_data_2_i, udma_tx_lin_data_3_i, udma_tx_lin_data_4_i, udma_tx_lin_data_5_i, udma_tx_lin_data_6_i, apb_hwce_pwdata_0_i, apb_hwce_pwdata_1_i, apb_hwce_pwdata_2_i, apb_hwce_pwdata_3_i, apb_hwce_pwdata_4_i, apb_hwce_pwdata_5_i, apb_hwce_pwdata_6_i, apb_hwce_pwdata_7_i, apb_hwce_pwdata_8_i, apb_hwce_pwdata_9_i, apb_hwce_pwdata_10_i, apb_hwce_pwdata_11_i, apb_hwce_pwdata_12_i, apb_hwce_pwdata_13_i, apb_hwce_pwdata_14_i, apb_hwce_pwdata_15_i, apb_hwce_pwdata_16_i, apb_hwce_pwdata_17_i, apb_hwce_pwdata_18_i, apb_hwce_pwdata_19_i, apb_hwce_pwdata_20_i, apb_hwce_pwdata_21_i, apb_hwce_pwdata_22_i, apb_hwce_pwdata_23_i, apb_hwce_pwdata_24_i, apb_hwce_pwdata_25_i, apb_hwce_pwdata_26_i, apb_hwce_pwdata_27_i, apb_hwce_pwdata_28_i, apb_hwce_pwdata_29_i, apb_hwce_pwdata_30_i, apb_hwce_pwdata_31_i, apb_hwce_addr_0_i, apb_hwce_addr_1_i, apb_hwce_addr_2_i, apb_hwce_addr_3_i, apb_hwce_addr_4_i, apb_hwce_addr_5_i, apb_hwce_addr_6_i, apb_hwce_enable_i, apb_hwce_psel_i, apb_hwce_pwrite_i, gpio_data_28_i, gpio_data_29_i, gpio_data_30_i, gpio_data_31_i, gpio_data_32_i, gpio_data_33_i, gpio_data_34_i, gpio_data_35_i, gpio_data_36_i, gpio_data_37_i, gpio_data_38_i, gpio_data_39_i, gpio_data_40_i, RESET_LB, RESET_LT, gpio_data_20_i, gpio_data_21_i, gpio_data_22_i, gpio_data_23_i, gpio_data_24_i, gpio_data_25_i, gpio_data_26_i, gpio_data_27_i, udma_cfg_data_30_i, udma_cfg_data_31_i, gpio_data_16_i, gpio_data_17_i, gpio_data_18_i, gpio_data_19_i, udma_cfg_data_22_i, udma_cfg_data_23_i, udma_cfg_data_24_i, udma_cfg_data_25_i, udma_cfg_data_26_i, udma_cfg_data_27_i, udma_cfg_data_28_i, udma_cfg_data_29_i, udma_cfg_data_16_i, udma_cfg_data_17_i, udma_cfg_data_18_i, udma_cfg_data_19_i, udma_cfg_data_20_i, udma_cfg_data_21_i, tcdm_r_rdata_p3_8_i, tcdm_r_rdata_p3_9_i, tcdm_r_rdata_p3_10_i, tcdm_r_rdata_p3_11_i, tcdm_r_rdata_p3_12_i, tcdm_r_rdata_p3_13_i, tcdm_r_rdata_p3_14_i, tcdm_r_rdata_p3_15_i, tcdm_r_rdata_p3_2_i, tcdm_r_rdata_p3_3_i, tcdm_r_rdata_p3_4_i, tcdm_r_rdata_p3_5_i, tcdm_r_rdata_p3_6_i, tcdm_r_rdata_p3_7_i, tcdm_r_rdata_p2_28_i, tcdm_r_rdata_p2_29_i, tcdm_r_rdata_p2_30_i, tcdm_r_rdata_p2_31_i, tcdm_gnt_p2_i, tcdm_r_valid_p2_i, tcdm_r_rdata_p3_0_i, tcdm_r_rdata_p3_1_i, tcdm_r_rdata_p2_22_i, tcdm_r_rdata_p2_23_i, tcdm_r_rdata_p2_24_i, tcdm_r_rdata_p2_25_i, tcdm_r_rdata_p2_26_i, tcdm_r_rdata_p2_27_i, tcdm_r_rdata_p2_14_i, tcdm_r_rdata_p2_15_i, tcdm_r_rdata_p2_16_i, tcdm_r_rdata_p2_17_i, tcdm_r_rdata_p2_18_i, tcdm_r_rdata_p2_19_i, tcdm_r_rdata_p2_20_i, tcdm_r_rdata_p2_21_i, tcdm_r_rdata_p2_8_i, tcdm_r_rdata_p2_9_i, tcdm_r_rdata_p2_10_i, tcdm_r_rdata_p2_11_i, tcdm_r_rdata_p2_12_i, tcdm_r_rdata_p2_13_i, tcdm_r_rdata_p2_0_i, tcdm_r_rdata_p2_1_i, tcdm_r_rdata_p2_2_i, tcdm_r_rdata_p2_3_i, tcdm_r_rdata_p2_4_i, tcdm_r_rdata_p2_5_i, tcdm_r_rdata_p2_6_i, tcdm_r_rdata_p2_7_i, tcdm_r_rdata_p0_0_i, tcdm_r_rdata_p0_1_i, tcdm_r_rdata_p0_2_i, tcdm_r_rdata_p0_3_i, tcdm_r_rdata_p0_4_i, tcdm_r_rdata_p0_5_i, tcdm_r_rdata_p0_6_i, tcdm_r_rdata_p0_7_i, tcdm_r_rdata_p0_8_i, tcdm_r_rdata_p0_9_i, tcdm_r_rdata_p0_10_i, tcdm_r_rdata_p0_11_i, tcdm_r_rdata_p0_12_i, tcdm_r_rdata_p0_13_i, tcdm_r_rdata_p0_14_i, tcdm_r_rdata_p0_15_i, tcdm_r_rdata_p0_16_i, tcdm_r_rdata_p0_17_i, tcdm_r_rdata_p0_18_i, tcdm_r_rdata_p0_19_i, tcdm_r_rdata_p0_20_i, tcdm_r_rdata_p0_21_i, tcdm_r_rdata_p0_22_i, tcdm_r_rdata_p0_23_i, tcdm_r_rdata_p0_24_i, tcdm_r_rdata_p0_25_i, tcdm_r_rdata_p0_26_i, tcdm_r_rdata_p0_27_i, tcdm_r_rdata_p0_28_i, tcdm_r_rdata_p0_29_i, tcdm_r_rdata_p0_30_i, tcdm_r_rdata_p0_31_i, tcdm_gnt_p0_i, tcdm_r_valid_p0_i, tcdm_r_rdata_p1_0_i, tcdm_r_rdata_p1_1_i, tcdm_r_rdata_p1_2_i, tcdm_r_rdata_p1_3_i, tcdm_r_rdata_p1_4_i, tcdm_r_rdata_p1_5_i, tcdm_r_rdata_p1_6_i, tcdm_r_rdata_p1_7_i, tcdm_r_rdata_p1_8_i, tcdm_r_rdata_p1_9_i, tcdm_r_rdata_p1_10_i, tcdm_r_rdata_p1_11_i, tcdm_r_rdata_p1_12_i, tcdm_r_rdata_p1_13_i, tcdm_r_rdata_p1_14_i, tcdm_r_rdata_p1_15_i, tcdm_r_rdata_p1_16_i, tcdm_r_rdata_p1_17_i, tcdm_r_rdata_p1_18_i, tcdm_r_rdata_p1_19_i, tcdm_r_rdata_p1_20_i, tcdm_r_rdata_p1_21_i, tcdm_r_rdata_p1_22_i, tcdm_r_rdata_p1_23_i, tcdm_r_rdata_p1_24_i, tcdm_r_rdata_p1_25_i, tcdm_r_rdata_p1_26_i, tcdm_r_rdata_p1_27_i, tcdm_r_rdata_p1_28_i, tcdm_r_rdata_p1_29_i, tcdm_r_rdata_p1_30_i, tcdm_r_rdata_p1_31_i, tcdm_gnt_p1_i, tcdm_r_valid_p1_i, gpio_data_8_i, gpio_data_9_i, gpio_data_10_i, gpio_data_11_i, RESET_RB, gpio_data_14_i, gpio_data_15_i, RESET_RT, tcdm_r_rdata_p3_30_i, tcdm_r_rdata_p3_31_i, tcdm_gnt_p3_i, tcdm_r_valid_p3_i, gpio_data_12_i, gpio_data_13_i, tcdm_r_rdata_p3_22_i, tcdm_r_rdata_p3_23_i, tcdm_r_rdata_p3_24_i, tcdm_r_rdata_p3_25_i, tcdm_r_rdata_p3_26_i, tcdm_r_rdata_p3_27_i, tcdm_r_rdata_p3_28_i, tcdm_r_rdata_p3_29_i, tcdm_r_rdata_p3_16_i, tcdm_r_rdata_p3_17_i, tcdm_r_rdata_p3_18_i, tcdm_r_rdata_p3_19_i, tcdm_r_rdata_p3_20_i, tcdm_r_rdata_p3_21_i
 );

output        FB_SPE_OUT_0_;        // From U_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo of myDesign_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo.v
output        FB_SPE_OUT_1_;        // From U_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo of myDesign_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo.v
output        FB_SPE_OUT_2_;        // From U_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo of myDesign_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo.v
output        FB_SPE_OUT_3_;        // From U_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo of myDesign_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo.v
output        fcb_apbm_mclk;        // From U_fcb of fcb.v
output [11:0] fcb_apbm_paddr;       // From U_fcb of fcb.v
output        fcb_apbm_penable;     // From U_fcb of fcb.v
output [7:0]  fcb_apbm_psel;        // From U_fcb of fcb.v
output [17:0] fcb_apbm_pwdata;      // From U_fcb of fcb.v
output        fcb_apbm_pwrite;      // From U_fcb of fcb.v
output        fcb_apbm_ramfifo_sel; // From U_fcb of fcb.v
output [31:0] fcb_apbs_prdata;      // From U_fcb of fcb.v
output        fcb_apbs_pready;      // From U_fcb of fcb.v
output        fcb_apbs_pslverr;     // From U_fcb of fcb.v
output        fcb_cfg_done;         // From U_fcb of fcb.v
output        fcb_cfg_done_en;      // From U_fcb of fcb.v

output [3:0]  fcb_pif_do_h;         // From U_fcb of fcb.v
output        fcb_pif_do_h_en;      // From U_fcb of fcb.v
output [3:0]  fcb_pif_do_l;         // From U_fcb of fcb.v
output        fcb_pif_do_l_en;      // From U_fcb of fcb.v
output        fcb_pif_vldo;         // From U_fcb of fcb.v
output        fcb_pif_vldo_en;      // From U_fcb of fcb.v
output        fcb_rst;              // From U_fcb of fcb.v
output        fcb_set_por;          // From U_fcb of fcb.v
output        fcb_spi_master_status;// From U_fcb of fcb.v
output        fcb_spim_ckout;       // From U_fcb of fcb.v
output        fcb_spim_ckout_en;    // From U_fcb of fcb.v
output        fcb_spim_cs_n;        // From U_fcb of fcb.v
output        fcb_spim_cs_n_en;     // From U_fcb of fcb.v
output        fcb_spim_mosi;        // From U_fcb of fcb.v
output        fcb_spim_mosi_en;     // From U_fcb of fcb.v
output        fcb_spis_miso;        // From U_fcb of fcb.v
output        fcb_spis_miso_en;     // From U_fcb of fcb.v
output        fcb_sysclk_en;        // From U_fcb of fcb.v

output   gpio_oe_0_o;
output   gpio_data_0_o;
output   gpio_oe_1_o;
output   gpio_data_1_o;
output   gpio_oe_2_o;
output   gpio_data_2_o;
output   gpio_oe_3_o;
output   gpio_data_3_o;
output   gpio_oe_4_o;
output   gpio_data_4_o;
output   gpio_oe_5_o;
output   gpio_data_5_o;
output   gpio_oe_6_o;
output   gpio_data_6_o;
output   gpio_oe_7_o;
output   gpio_data_7_o;
output   gpio_oe_20_o;
output   gpio_data_20_o;
output   gpio_oe_25_o;
output   gpio_data_25_o;
output   gpio_oe_26_o;
output   gpio_data_26_o;
output   gpio_oe_27_o;
output   gpio_data_27_o;
output   gpio_oe_21_o;
output   gpio_data_21_o;
output   gpio_oe_22_o;
output   gpio_data_22_o;
output   gpio_oe_23_o;
output   gpio_data_23_o;
output   gpio_oe_24_o;
output   gpio_data_24_o;
output   events_12_o;
output   events_13_o;
output   gpio_oe_19_o;
output   gpio_data_19_o;
output   events_14_o;
output   events_15_o;
output   gpio_oe_16_o;
output   gpio_data_16_o;
output   gpio_oe_17_o;
output   gpio_data_17_o;
output   gpio_oe_18_o;
output   gpio_data_18_o;
output   udma_cfg_data_26_o;
output   udma_cfg_data_27_o;
output   events_4_o;
output   events_5_o;
output   events_6_o;
output   events_7_o;
output   events_8_o;
output   events_9_o;
output   events_10_o;
output   events_11_o;
output   udma_cfg_data_28_o;
output   udma_cfg_data_29_o;
output   udma_cfg_data_30_o;
output   udma_cfg_data_31_o;
output   events_0_o;
output   events_1_o;
output   events_2_o;
output   events_3_o;
output   udma_cfg_data_14_o;
output   udma_cfg_data_15_o;
output   udma_cfg_data_24_o;
output   udma_cfg_data_25_o;
output   udma_cfg_data_16_o;
output   udma_cfg_data_17_o;
output   udma_cfg_data_18_o;
output   udma_cfg_data_19_o;
output   udma_cfg_data_20_o;
output   udma_cfg_data_21_o;
output   udma_cfg_data_22_o;
output   udma_cfg_data_23_o;
output   udma_rx_lin_data_28_o;
output   udma_rx_lin_data_29_o;
output   udma_cfg_data_6_o;
output   udma_cfg_data_7_o;
output   udma_cfg_data_8_o;
output   udma_cfg_data_9_o;
output   udma_cfg_data_10_o;
output   udma_cfg_data_11_o;
output   udma_cfg_data_12_o;
output   udma_cfg_data_13_o;
output   udma_rx_lin_data_30_o;
output   udma_rx_lin_data_31_o;
output   udma_cfg_data_0_o;
output   udma_cfg_data_1_o;
output   udma_cfg_data_2_o;
output   udma_cfg_data_3_o;
output   udma_cfg_data_4_o;
output   udma_cfg_data_5_o;
output   udma_rx_lin_data_16_o;
output   udma_rx_lin_data_17_o;
output   udma_rx_lin_data_26_o;
output   udma_rx_lin_data_27_o;
output   udma_rx_lin_data_18_o;
output   udma_rx_lin_data_19_o;
output   udma_rx_lin_data_20_o;
output   udma_rx_lin_data_21_o;
output   udma_rx_lin_data_22_o;
output   udma_rx_lin_data_23_o;
output   udma_rx_lin_data_24_o;
output   udma_rx_lin_data_25_o;
output   udma_tx_lin_ready_o;
output   udma_rx_lin_valid_o;
output   udma_rx_lin_data_8_o;
output   udma_rx_lin_data_9_o;
output   udma_rx_lin_data_10_o;
output   udma_rx_lin_data_11_o;
output   udma_rx_lin_data_12_o;
output   udma_rx_lin_data_13_o;
output   udma_rx_lin_data_14_o;
output   udma_rx_lin_data_15_o;
output   udma_rx_lin_data_0_o;
output   udma_rx_lin_data_1_o;
output   udma_rx_lin_data_2_o;
output   udma_rx_lin_data_3_o;
output   udma_rx_lin_data_4_o;
output   udma_rx_lin_data_5_o;
output   udma_rx_lin_data_6_o;
output   udma_rx_lin_data_7_o;
output   apb_hwce_prdata_0_o;
output   apb_hwce_prdata_1_o;
output   apb_hwce_prdata_10_o;
output   apb_hwce_prdata_11_o;
output   apb_hwce_prdata_2_o;
output   apb_hwce_prdata_3_o;
output   apb_hwce_prdata_4_o;
output   apb_hwce_prdata_5_o;
output   apb_hwce_prdata_6_o;
output   apb_hwce_prdata_7_o;
output   apb_hwce_prdata_8_o;
output   apb_hwce_prdata_9_o;
output   apb_hwce_prdata_12_o;
output   apb_hwce_prdata_13_o;
output   apb_hwce_prdata_22_o;
output   apb_hwce_prdata_23_o;
output   apb_hwce_prdata_24_o;
output   apb_hwce_prdata_25_o;
output   apb_hwce_prdata_26_o;
output   apb_hwce_prdata_27_o;
output   apb_hwce_prdata_28_o;
output   apb_hwce_prdata_29_o;
output   apb_hwce_prdata_14_o;
output   apb_hwce_prdata_15_o;
output   apb_hwce_prdata_16_o;
output   apb_hwce_prdata_17_o;
output   apb_hwce_prdata_18_o;
output   apb_hwce_prdata_19_o;
output   apb_hwce_prdata_20_o;
output   apb_hwce_prdata_21_o;
output   apb_hwce_prdata_30_o;
output   apb_hwce_prdata_31_o;
output   gpio_oe_31_o;
output   gpio_data_31_o;
output   apb_hwce_ready_o;
output   apb_hwce_pslverr_o;
output   gpio_oe_28_o;
output   gpio_data_28_o;
output   gpio_oe_29_o;
output   gpio_data_29_o;
output   gpio_oe_30_o;
output   gpio_data_30_o;
output   gpio_oe_32_o;
output   gpio_data_32_o;
output   gpio_oe_37_o;
output   gpio_data_37_o;
output   gpio_oe_38_o;
output   gpio_data_38_o;
output   gpio_oe_39_o;
output   gpio_data_39_o;
output   gpio_oe_40_o;
output   gpio_data_40_o;
output   gpio_oe_33_o;
output   gpio_data_33_o;
output   gpio_oe_34_o;
output   gpio_data_34_o;
output   gpio_oe_35_o;
output   gpio_data_35_o;
output   gpio_oe_36_o;
output   gpio_data_36_o;
output   tcdm_addr_p3_16_o;
output   tcdm_wdata_p3_16_o;
output   tcdm_wdata_p3_22_o;
output   tcdm_wdata_p3_23_o;
output   tcdm_wdata_p3_24_o;
output   tcdm_wdata_p3_25_o;
output   tcdm_wdata_p3_26_o;
output   tcdm_wdata_p3_27_o;
output   tcdm_wdata_p3_28_o;
output   tcdm_wdata_p3_29_o;
output   tcdm_addr_p3_17_o;
output   tcdm_wdata_p3_17_o;
output   tcdm_addr_p3_18_o;
output   tcdm_wdata_p3_18_o;
output   tcdm_addr_p3_19_o;
output   tcdm_wdata_p3_19_o;
output   tcdm_wdata_p3_20_o;
output   tcdm_wdata_p3_21_o;
output   tcdm_addr_p3_10_o;
output   tcdm_wdata_p3_10_o;
output   tcdm_addr_p3_15_o;
output   tcdm_wdata_p3_15_o;
output   tcdm_addr_p3_11_o;
output   tcdm_wdata_p3_11_o;
output   tcdm_addr_p3_12_o;
output   tcdm_wdata_p3_12_o;
output   tcdm_addr_p3_13_o;
output   tcdm_wdata_p3_13_o;
output   tcdm_addr_p3_14_o;
output   tcdm_wdata_p3_14_o;
output   tcdm_addr_p3_1_o;
output   tcdm_wdata_p3_1_o;
output   tcdm_addr_p3_6_o;
output   tcdm_wdata_p3_6_o;
output   tcdm_addr_p3_7_o;
output   tcdm_wdata_p3_7_o;
output   tcdm_addr_p3_8_o;
output   tcdm_wdata_p3_8_o;
output   tcdm_addr_p3_9_o;
output   tcdm_wdata_p3_9_o;
output   tcdm_addr_p3_2_o;
output   tcdm_wdata_p3_2_o;
output   tcdm_addr_p3_3_o;
output   tcdm_wdata_p3_3_o;
output   tcdm_addr_p3_4_o;
output   tcdm_wdata_p3_4_o;
output   tcdm_addr_p3_5_o;
output   tcdm_wdata_p3_5_o;
output   tcdm_wdata_p2_28_o;
output   tcdm_wdata_p2_29_o;
output   tcdm_addr_p3_0_o;
output   tcdm_wdata_p3_0_o;
output   tcdm_wdata_p2_30_o;
output   tcdm_wdata_p2_31_o;
output   tcdm_req_p2_o;
output   tcdm_wen_p2_o;
output   tcdm_be_p2_0_o;
output   tcdm_be_p2_1_o;
output   tcdm_be_p2_2_o;
output   tcdm_be_p2_3_o;
output   tcdm_addr_p2_15_o;
output   tcdm_wdata_p2_15_o;
output   tcdm_wdata_p2_20_o;
output   tcdm_wdata_p2_21_o;
output   tcdm_wdata_p2_22_o;
output   tcdm_wdata_p2_23_o;
output   tcdm_wdata_p2_24_o;
output   tcdm_wdata_p2_25_o;
output   tcdm_wdata_p2_26_o;
output   tcdm_wdata_p2_27_o;
output   tcdm_addr_p2_16_o;
output   tcdm_wdata_p2_16_o;
output   tcdm_addr_p2_17_o;
output   tcdm_wdata_p2_17_o;
output   tcdm_addr_p2_18_o;
output   tcdm_wdata_p2_18_o;
output   tcdm_addr_p2_19_o;
output   tcdm_wdata_p2_19_o;
output   tcdm_addr_p2_9_o;
output   tcdm_wdata_p2_9_o;
output   tcdm_addr_p2_14_o;
output   tcdm_wdata_p2_14_o;
output   tcdm_addr_p2_10_o;
output   tcdm_wdata_p2_10_o;
output   tcdm_addr_p2_11_o;
output   tcdm_wdata_p2_11_o;
output   tcdm_addr_p2_12_o;
output   tcdm_wdata_p2_12_o;
output   tcdm_addr_p2_13_o;
output   tcdm_wdata_p2_13_o;
output   tcdm_addr_p2_0_o;
output   tcdm_wdata_p2_0_o;
output   tcdm_addr_p2_5_o;
output   tcdm_wdata_p2_5_o;
output   tcdm_addr_p2_6_o;
output   tcdm_wdata_p2_6_o;
output   tcdm_addr_p2_7_o;
output   tcdm_wdata_p2_7_o;
output   tcdm_addr_p2_8_o;
output   tcdm_wdata_p2_8_o;
output   tcdm_addr_p2_1_o;
output   tcdm_wdata_p2_1_o;
output   tcdm_addr_p2_2_o;
output   tcdm_wdata_p2_2_o;
output   tcdm_addr_p2_3_o;
output   tcdm_wdata_p2_3_o;
output   tcdm_addr_p2_4_o;
output   tcdm_wdata_p2_4_o;
output   tcdm_addr_p0_0_o;
output   tcdm_wdata_p0_0_o;
output   tcdm_addr_p0_5_o;
output   tcdm_wdata_p0_5_o;
output   tcdm_addr_p0_1_o;
output   tcdm_wdata_p0_1_o;
output   tcdm_addr_p0_2_o;
output   tcdm_wdata_p0_2_o;
output   tcdm_addr_p0_3_o;
output   tcdm_wdata_p0_3_o;
output   tcdm_addr_p0_4_o;
output   tcdm_wdata_p0_4_o;
output   tcdm_addr_p0_6_o;
output   tcdm_wdata_p0_6_o;
output   tcdm_addr_p0_11_o;
output   tcdm_wdata_p0_11_o;
output   tcdm_addr_p0_12_o;
output   tcdm_wdata_p0_12_o;
output   tcdm_addr_p0_13_o;
output   tcdm_wdata_p0_13_o;
output   tcdm_addr_p0_14_o;
output   tcdm_wdata_p0_14_o;
output   tcdm_addr_p0_7_o;
output   tcdm_wdata_p0_7_o;
output   tcdm_addr_p0_8_o;
output   tcdm_wdata_p0_8_o;
output   tcdm_addr_p0_9_o;
output   tcdm_wdata_p0_9_o;
output   tcdm_addr_p0_10_o;
output   tcdm_wdata_p0_10_o;
output   tcdm_addr_p0_15_o;
output   tcdm_wdata_p0_15_o;
output   tcdm_wdata_p0_20_o;
output   tcdm_wdata_p0_21_o;
output   tcdm_addr_p0_16_o;
output   tcdm_wdata_p0_16_o;
output   tcdm_addr_p0_17_o;
output   tcdm_wdata_p0_17_o;
output   tcdm_addr_p0_18_o;
output   tcdm_wdata_p0_18_o;
output   tcdm_addr_p0_19_o;
output   tcdm_wdata_p0_19_o;
output   tcdm_wdata_p0_22_o;
output   tcdm_wdata_p0_23_o;
output   tcdm_req_p0_o;
output   tcdm_wen_p0_o;
output   tcdm_be_p0_0_o;
output   tcdm_be_p0_1_o;
output   tcdm_be_p0_2_o;
output   tcdm_be_p0_3_o;
output   tcdm_addr_p1_0_o;
output   tcdm_wdata_p1_0_o;
output   tcdm_wdata_p0_24_o;
output   tcdm_wdata_p0_25_o;
output   tcdm_wdata_p0_26_o;
output   tcdm_wdata_p0_27_o;
output   tcdm_wdata_p0_28_o;
output   tcdm_wdata_p0_29_o;
output   tcdm_wdata_p0_30_o;
output   tcdm_wdata_p0_31_o;
output   tcdm_addr_p1_1_o;
output   tcdm_wdata_p1_1_o;
output   tcdm_addr_p1_6_o;
output   tcdm_wdata_p1_6_o;
output   tcdm_addr_p1_2_o;
output   tcdm_wdata_p1_2_o;
output   tcdm_addr_p1_3_o;
output   tcdm_wdata_p1_3_o;
output   tcdm_addr_p1_4_o;
output   tcdm_wdata_p1_4_o;
output   tcdm_addr_p1_5_o;
output   tcdm_wdata_p1_5_o;
output   tcdm_addr_p1_7_o;
output   tcdm_wdata_p1_7_o;
output   tcdm_addr_p1_12_o;
output   tcdm_wdata_p1_12_o;
output   tcdm_addr_p1_13_o;
output   tcdm_wdata_p1_13_o;
output   tcdm_addr_p1_14_o;
output   tcdm_wdata_p1_14_o;
output   tcdm_addr_p1_15_o;
output   tcdm_wdata_p1_15_o;
output   tcdm_addr_p1_8_o;
output   tcdm_wdata_p1_8_o;
output   tcdm_addr_p1_9_o;
output   tcdm_wdata_p1_9_o;
output   tcdm_addr_p1_10_o;
output   tcdm_wdata_p1_10_o;
output   tcdm_addr_p1_11_o;
output   tcdm_wdata_p1_11_o;
output   tcdm_addr_p1_16_o;
output   tcdm_wdata_p1_16_o;
output   tcdm_wdata_p1_22_o;
output   tcdm_wdata_p1_23_o;
output   tcdm_addr_p1_17_o;
output   tcdm_wdata_p1_17_o;
output   tcdm_addr_p1_18_o;
output   tcdm_wdata_p1_18_o;
output   tcdm_addr_p1_19_o;
output   tcdm_wdata_p1_19_o;
output   tcdm_wdata_p1_20_o;
output   tcdm_wdata_p1_21_o;
output   tcdm_wdata_p1_24_o;
output   tcdm_wdata_p1_25_o;
output   tcdm_be_p1_0_o;
output   tcdm_be_p1_1_o;
output   tcdm_be_p1_2_o;
output   tcdm_be_p1_3_o;
output   gpio_oe_8_o;
output   gpio_data_8_o;
output   gpio_oe_9_o;
output   gpio_data_9_o;
output   tcdm_wdata_p1_26_o;
output   tcdm_wdata_p1_27_o;
output   tcdm_wdata_p1_28_o;
output   tcdm_wdata_p1_29_o;
output   tcdm_wdata_p1_30_o;
output   tcdm_wdata_p1_31_o;
output   tcdm_req_p1_o;
output   tcdm_wen_p1_o;
output   gpio_oe_10_o;
output   gpio_data_10_o;
output   gpio_oe_11_o;
output   gpio_data_11_o;
output   gpio_oe_14_o;
output   gpio_data_14_o;
output   gpio_oe_15_o;
output   gpio_data_15_o;
output   tcdm_wdata_p3_30_o;
output   tcdm_wdata_p3_31_o;
output   gpio_oe_13_o;
output   gpio_data_13_o;
output   tcdm_req_p3_o;
output   tcdm_wen_p3_o;
output   tcdm_be_p3_0_o;
output   tcdm_be_p3_1_o;
output   tcdm_be_p3_2_o;
output   tcdm_be_p3_3_o;
output   gpio_oe_12_o;
output   gpio_data_12_o;

input         FB_SPE_IN_0_;         // To U_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo of myDesign_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo.v
input         FB_SPE_IN_1_;         // To U_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo of myDesign_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo.v
input         FB_SPE_IN_2_;         // To U_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo of myDesign_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo.v
input         FB_SPE_IN_3_;         // To U_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo of myDesign_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo.v
input         MLATCH;               // To U_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo of myDesign_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo.v
input         M_0_;                 // To U_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo of myDesign_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo.v
input         M_1_;                 // To U_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo of myDesign_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo.v
input         M_2_;                 // To U_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo of myDesign_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo.v
input         M_3_;                 // To U_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo of myDesign_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo.v
input         M_4_;                 // To U_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo of myDesign_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo.v
input         M_5_;                 // To U_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo of myDesign_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo.v
input         POR;                  // To U_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo of myDesign_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo.v
input         STM;                  // To U_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo of myDesign_QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_demo.v
input [17:0]  fcb_apbm_prdata_0;    // To U_fcb of fcb.v
input [17:0]  fcb_apbm_prdata_1;    // To U_fcb of fcb.v
input [19:0]  fcb_apbs_paddr;       // To U_fcb of fcb.v
input         fcb_apbs_penable;     // To U_fcb of fcb.v
input [2:0]   fcb_apbs_pprot;       // To U_fcb of fcb.v
input         fcb_apbs_psel;        // To U_fcb of fcb.v
input [3:0]   fcb_apbs_pstrb;       // To U_fcb of fcb.v
input [31:0]  fcb_apbs_pwdata;      // To U_fcb of fcb.v
input         fcb_apbs_pwrite;      // To U_fcb of fcb.v
input         fcb_pif_8b_mode_bo;   // To U_fcb of fcb.v
input [3:0]   fcb_pif_di_h;         // To U_fcb of fcb.v
input [3:0]   fcb_pif_di_l;         // To U_fcb of fcb.v
input         fcb_pif_vldi;         // To U_fcb of fcb.v
input         fcb_spi_master_en;    // To U_fcb of fcb.v
input         fcb_spi_mode_en_bo;   // To U_fcb of fcb.v
input         fcb_spim_ckout_in;    // To U_fcb of fcb.v
input         fcb_spim_miso;        // To U_fcb of fcb.v
input         fcb_spis_clk;         // To U_fcb of fcb.v
input         fcb_spis_cs_n;        // To U_fcb of fcb.v
input         fcb_spis_mosi;        // To U_fcb of fcb.v
input         fcb_spis_rst_n;       // To U_fcb of fcb.v
input         fcb_sys_clk;          // To U_fcb of fcb.v
input         fcb_sys_rst_n;        // To U_fcb of fcb.v
input         fcb_sys_stm;          // To U_fcb of fcb.v
input [475:0] supplyBus;
input         CLK0;
input         CLK1;
input         CLK2;
input         CLK3;
input         CLK4;
input         CLK5;
input         gpio_data_0_i;
input         gpio_data_1_i;
input         gpio_data_2_i;
input         gpio_data_3_i;
input         gpio_data_4_i;
input         gpio_data_5_i;
input         gpio_data_6_i;
input         gpio_data_7_i;
input         udma_cfg_data_8_i;
input         udma_cfg_data_9_i;
input         udma_cfg_data_10_i;
input         udma_cfg_data_11_i;
input         udma_cfg_data_12_i;
input         udma_cfg_data_13_i;
input         udma_cfg_data_14_i;
input         udma_cfg_data_15_i;
input         udma_cfg_data_2_i;
input         udma_cfg_data_3_i;
input         udma_cfg_data_4_i;
input         udma_cfg_data_5_i;
input         udma_cfg_data_6_i;
input         udma_cfg_data_7_i;
input         udma_tx_lin_data_27_i;
input         udma_tx_lin_data_28_i;
input         udma_tx_lin_data_29_i;
input         udma_tx_lin_data_30_i;
input         udma_tx_lin_data_31_i;
input         udma_rx_lin_ready_i;
input         udma_cfg_data_0_i;
input         udma_cfg_data_1_i;
input         udma_tx_lin_data_21_i;
input         udma_tx_lin_data_22_i;
input         udma_tx_lin_data_23_i;
input         udma_tx_lin_data_24_i;
input         udma_tx_lin_data_25_i;
input         udma_tx_lin_data_26_i;
input         udma_tx_lin_data_13_i;
input         udma_tx_lin_data_14_i;
input         udma_tx_lin_data_15_i;
input         udma_tx_lin_data_16_i;
input         udma_tx_lin_data_17_i;
input         udma_tx_lin_data_18_i;
input         udma_tx_lin_data_19_i;
input         udma_tx_lin_data_20_i;
input         udma_tx_lin_data_7_i;
input         udma_tx_lin_data_8_i;
input         udma_tx_lin_data_9_i;
input         udma_tx_lin_data_10_i;
input         udma_tx_lin_data_11_i;
input         udma_tx_lin_data_12_i;
input         udma_tx_lin_valid_i;
input         udma_tx_lin_data_0_i;
input         udma_tx_lin_data_1_i;
input         udma_tx_lin_data_2_i;
input         udma_tx_lin_data_3_i;
input         udma_tx_lin_data_4_i;
input         udma_tx_lin_data_5_i;
input         udma_tx_lin_data_6_i;
input         apb_hwce_pwdata_0_i;
input         apb_hwce_pwdata_1_i;
input         apb_hwce_pwdata_2_i;
input         apb_hwce_pwdata_3_i;
input         apb_hwce_pwdata_4_i;
input         apb_hwce_pwdata_5_i;
input         apb_hwce_pwdata_6_i;
input         apb_hwce_pwdata_7_i;
input         apb_hwce_pwdata_8_i;
input         apb_hwce_pwdata_9_i;
input         apb_hwce_pwdata_10_i;
input         apb_hwce_pwdata_11_i;
input         apb_hwce_pwdata_12_i;
input         apb_hwce_pwdata_13_i;
input         apb_hwce_pwdata_14_i;
input         apb_hwce_pwdata_15_i;
input         apb_hwce_pwdata_16_i;
input         apb_hwce_pwdata_17_i;
input         apb_hwce_pwdata_18_i;
input         apb_hwce_pwdata_19_i;
input         apb_hwce_pwdata_20_i;
input         apb_hwce_pwdata_21_i;
input         apb_hwce_pwdata_22_i;
input         apb_hwce_pwdata_23_i;
input         apb_hwce_pwdata_24_i;
input         apb_hwce_pwdata_25_i;
input         apb_hwce_pwdata_26_i;
input         apb_hwce_pwdata_27_i;
input         apb_hwce_pwdata_28_i;
input         apb_hwce_pwdata_29_i;
input         apb_hwce_pwdata_30_i;
input         apb_hwce_pwdata_31_i;
input         apb_hwce_addr_0_i;
input         apb_hwce_addr_1_i;
input         apb_hwce_addr_2_i;
input         apb_hwce_addr_3_i;
input         apb_hwce_addr_4_i;
input         apb_hwce_addr_5_i;
input         apb_hwce_addr_6_i;
input         apb_hwce_enable_i;
input         apb_hwce_psel_i;
input         apb_hwce_pwrite_i;
input         gpio_data_28_i;
input         gpio_data_29_i;
input         gpio_data_30_i;
input         gpio_data_31_i;
input         gpio_data_32_i;
input         gpio_data_33_i;
input         gpio_data_34_i;
input         gpio_data_35_i;
input         gpio_data_36_i;
input         gpio_data_37_i;
input         gpio_data_38_i;
input         gpio_data_39_i;
input         gpio_data_40_i;
input         RESET_LB;
input         RESET_LT;
input         gpio_data_20_i;
input         gpio_data_21_i;
input         gpio_data_22_i;
input         gpio_data_23_i;
input         gpio_data_24_i;
input         gpio_data_25_i;
input         gpio_data_26_i;
input         gpio_data_27_i;
input         udma_cfg_data_30_i;
input         udma_cfg_data_31_i;
input         gpio_data_16_i;
input         gpio_data_17_i;
input         gpio_data_18_i;
input         gpio_data_19_i;
input         udma_cfg_data_22_i;
input         udma_cfg_data_23_i;
input         udma_cfg_data_24_i;
input         udma_cfg_data_25_i;
input         udma_cfg_data_26_i;
input         udma_cfg_data_27_i;
input         udma_cfg_data_28_i;
input         udma_cfg_data_29_i;
input         udma_cfg_data_16_i;
input         udma_cfg_data_17_i;
input         udma_cfg_data_18_i;
input         udma_cfg_data_19_i;
input         udma_cfg_data_20_i;
input         udma_cfg_data_21_i;
input         tcdm_r_rdata_p3_8_i;
input         tcdm_r_rdata_p3_9_i;
input         tcdm_r_rdata_p3_10_i;
input         tcdm_r_rdata_p3_11_i;
input         tcdm_r_rdata_p3_12_i;
input         tcdm_r_rdata_p3_13_i;
input         tcdm_r_rdata_p3_14_i;
input         tcdm_r_rdata_p3_15_i;
input         tcdm_r_rdata_p3_2_i;
input         tcdm_r_rdata_p3_3_i;
input         tcdm_r_rdata_p3_4_i;
input         tcdm_r_rdata_p3_5_i;
input         tcdm_r_rdata_p3_6_i;
input         tcdm_r_rdata_p3_7_i;
input         tcdm_r_rdata_p2_28_i;
input         tcdm_r_rdata_p2_29_i;
input         tcdm_r_rdata_p2_30_i;
input         tcdm_r_rdata_p2_31_i;
input         tcdm_gnt_p2_i;
input         tcdm_r_valid_p2_i;
input         tcdm_r_rdata_p3_0_i;
input         tcdm_r_rdata_p3_1_i;
input         tcdm_r_rdata_p2_22_i;
input         tcdm_r_rdata_p2_23_i;
input         tcdm_r_rdata_p2_24_i;
input         tcdm_r_rdata_p2_25_i;
input         tcdm_r_rdata_p2_26_i;
input         tcdm_r_rdata_p2_27_i;
input         tcdm_r_rdata_p2_14_i;
input         tcdm_r_rdata_p2_15_i;
input         tcdm_r_rdata_p2_16_i;
input         tcdm_r_rdata_p2_17_i;
input         tcdm_r_rdata_p2_18_i;
input         tcdm_r_rdata_p2_19_i;
input         tcdm_r_rdata_p2_20_i;
input         tcdm_r_rdata_p2_21_i;
input         tcdm_r_rdata_p2_8_i;
input         tcdm_r_rdata_p2_9_i;
input         tcdm_r_rdata_p2_10_i;
input         tcdm_r_rdata_p2_11_i;
input         tcdm_r_rdata_p2_12_i;
input         tcdm_r_rdata_p2_13_i;
input         tcdm_r_rdata_p2_0_i;
input         tcdm_r_rdata_p2_1_i;
input         tcdm_r_rdata_p2_2_i;
input         tcdm_r_rdata_p2_3_i;
input         tcdm_r_rdata_p2_4_i;
input         tcdm_r_rdata_p2_5_i;
input         tcdm_r_rdata_p2_6_i;
input         tcdm_r_rdata_p2_7_i;
input         tcdm_r_rdata_p0_0_i;
input         tcdm_r_rdata_p0_1_i;
input         tcdm_r_rdata_p0_2_i;
input         tcdm_r_rdata_p0_3_i;
input         tcdm_r_rdata_p0_4_i;
input         tcdm_r_rdata_p0_5_i;
input         tcdm_r_rdata_p0_6_i;
input         tcdm_r_rdata_p0_7_i;
input         tcdm_r_rdata_p0_8_i;
input         tcdm_r_rdata_p0_9_i;
input         tcdm_r_rdata_p0_10_i;
input         tcdm_r_rdata_p0_11_i;
input         tcdm_r_rdata_p0_12_i;
input         tcdm_r_rdata_p0_13_i;
input         tcdm_r_rdata_p0_14_i;
input         tcdm_r_rdata_p0_15_i;
input         tcdm_r_rdata_p0_16_i;
input         tcdm_r_rdata_p0_17_i;
input         tcdm_r_rdata_p0_18_i;
input         tcdm_r_rdata_p0_19_i;
input         tcdm_r_rdata_p0_20_i;
input         tcdm_r_rdata_p0_21_i;
input         tcdm_r_rdata_p0_22_i;
input         tcdm_r_rdata_p0_23_i;
input         tcdm_r_rdata_p0_24_i;
input         tcdm_r_rdata_p0_25_i;
input         tcdm_r_rdata_p0_26_i;
input         tcdm_r_rdata_p0_27_i;
input         tcdm_r_rdata_p0_28_i;
input         tcdm_r_rdata_p0_29_i;
input         tcdm_r_rdata_p0_30_i;
input         tcdm_r_rdata_p0_31_i;
input         tcdm_gnt_p0_i;
input         tcdm_r_valid_p0_i;
input         tcdm_r_rdata_p1_0_i;
input         tcdm_r_rdata_p1_1_i;
input         tcdm_r_rdata_p1_2_i;
input         tcdm_r_rdata_p1_3_i;
input         tcdm_r_rdata_p1_4_i;
input         tcdm_r_rdata_p1_5_i;
input         tcdm_r_rdata_p1_6_i;
input         tcdm_r_rdata_p1_7_i;
input         tcdm_r_rdata_p1_8_i;
input         tcdm_r_rdata_p1_9_i;
input         tcdm_r_rdata_p1_10_i;
input         tcdm_r_rdata_p1_11_i;
input         tcdm_r_rdata_p1_12_i;
input         tcdm_r_rdata_p1_13_i;
input         tcdm_r_rdata_p1_14_i;
input         tcdm_r_rdata_p1_15_i;
input         tcdm_r_rdata_p1_16_i;
input         tcdm_r_rdata_p1_17_i;
input         tcdm_r_rdata_p1_18_i;
input         tcdm_r_rdata_p1_19_i;
input         tcdm_r_rdata_p1_20_i;
input         tcdm_r_rdata_p1_21_i;
input         tcdm_r_rdata_p1_22_i;
input         tcdm_r_rdata_p1_23_i;
input         tcdm_r_rdata_p1_24_i;
input         tcdm_r_rdata_p1_25_i;
input         tcdm_r_rdata_p1_26_i;
input         tcdm_r_rdata_p1_27_i;
input         tcdm_r_rdata_p1_28_i;
input         tcdm_r_rdata_p1_29_i;
input         tcdm_r_rdata_p1_30_i;
input         tcdm_r_rdata_p1_31_i;
input         tcdm_gnt_p1_i;
input         tcdm_r_valid_p1_i;
input         gpio_data_8_i;
input         gpio_data_9_i;
input         gpio_data_10_i;
input         gpio_data_11_i;
input         RESET_RB;
input         gpio_data_14_i;
input         gpio_data_15_i;
input         RESET_RT;
input         tcdm_r_rdata_p3_30_i;
input         tcdm_r_rdata_p3_31_i;
input         tcdm_gnt_p3_i;
input         tcdm_r_valid_p3_i;
input         gpio_data_12_i;
input         gpio_data_13_i;
input         tcdm_r_rdata_p3_22_i;
input         tcdm_r_rdata_p3_23_i;
input         tcdm_r_rdata_p3_24_i;
input         tcdm_r_rdata_p3_25_i;
input         tcdm_r_rdata_p3_26_i;
input         tcdm_r_rdata_p3_27_i;
input         tcdm_r_rdata_p3_28_i;
input         tcdm_r_rdata_p3_29_i;
input         tcdm_r_rdata_p3_16_i;
input         tcdm_r_rdata_p3_17_i;
input         tcdm_r_rdata_p3_18_i;
input         tcdm_r_rdata_p3_19_i;
input         tcdm_r_rdata_p3_20_i;
input         tcdm_r_rdata_p3_21_i;


wire [31:0]             fcb_bl_din;             // From U_FCB_TOP of FCB_TOP.v
wire [31:0]             fcb_bl_dout;            // From U_EFPGA_TOP of QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_ARNOLD_Design.v, ...
wire [15:0]             fcb_bl_pwrgate;         // From U_FCB_TOP of FCB_TOP.v
wire                    fcb_blclk;              // From U_FCB_TOP of FCB_TOP.v
wire                    fcb_cload_din_sel;      // From U_FCB_TOP of FCB_TOP.v
wire                    fcb_din_int_l_only;     // From U_FCB_TOP of FCB_TOP.v
wire                    fcb_din_int_r_only;     // From U_FCB_TOP of FCB_TOP.v
wire                    fcb_din_slc_tb_int;     // From U_FCB_TOP of FCB_TOP.v
wire                    fcb_fb_cfg_done;        // From U_FCB_TOP of FCB_TOP.v
wire                    fcb_fb_iso_enb;         // From U_FCB_TOP of FCB_TOP.v
wire [15:0]             fcb_iso_en;             // From U_FCB_TOP of FCB_TOP.v
wire                    fcb_pchg_b;             // From U_FCB_TOP of FCB_TOP.v
wire [15:0]             fcb_pi_pwr;             // From U_FCB_TOP of FCB_TOP.v
wire                    fcb_pif_en;             // From U_EFPGA_TOP of QL_eFPGA_ArcticPro2_32X32_GF_22_ETH_ARNOLD_Design.v
wire [15:0]             fcb_prog;               // From U_FCB_TOP of FCB_TOP.v
wire                    fcb_prog_ifx;           // From U_FCB_TOP of FCB_TOP.v
wire                    fcb_pwr_gate;           // From U_FCB_TOP of FCB_TOP.v
wire                    fcb_re;                 // From U_FCB_TOP of FCB_TOP.v
wire [15:0]             fcb_vlp_clkdis;         // From U_FCB_TOP of FCB_TOP.v
wire                    fcb_vlp_clkdis_ifx;     // From U_FCB_TOP of FCB_TOP.v
wire [15:0]             fcb_vlp_pwrdis;         // From U_FCB_TOP of FCB_TOP.v
wire                    fcb_vlp_pwrdis_ifx;     // From U_FCB_TOP of FCB_TOP.v
wire [15:0]             fcb_vlp_srdis;          // From U_FCB_TOP of FCB_TOP.v
wire                    fcb_vlp_srdis_ifx;      // From U_FCB_TOP of FCB_TOP.v
wire                    fcb_we;                 // From U_FCB_TOP of FCB_TOP.v
wire                    fcb_we_int;             // From U_FCB_TOP of FCB_TOP.v
wire [2:0]              fcb_wl_cload_sel;       // From U_FCB_TOP of FCB_TOP.v
wire [5:0]              fcb_wl_din;             // From U_FCB_TOP of FCB_TOP.v
wire                    fcb_wl_en;              // From U_FCB_TOP of FCB_TOP.v
wire                    fcb_wl_int_din_sel;     // From U_FCB_TOP of FCB_TOP.v
wire [7:0]              fcb_wl_pwrgate;         // From U_FCB_TOP of FCB_TOP.v
wire                    fcb_wl_resetb;          // From U_FCB_TOP of FCB_TOP.v
wire [15:0]             fcb_wl_sel;             // From U_FCB_TOP of FCB_TOP.v
wire                    fcb_wl_sel_tb_int;      // From U_FCB_TOP of FCB_TOP.v
wire                    fcb_wlclk;              // From U_FCB_TOP of FCB_TOP.v
`include "math_block_signal_declaration.vh"


wire                    fcb_clp_cfg_done_n;
wire                    fcb_clp_cfg_enb;
wire                    fcb_clp_lth_enb;
wire                    fcb_clp_pwr_gate;
wire                    fcb_clp_vlp;
wire                    fcb_clp_set_por;

//`define QL_FIR_TEST
//`define QL_IIR_TEST

`ifdef QL_MATH_TEST

math_block_test QL_eFPGA_Design
(
    .clk_i  (CLK0),
    .rst_ni (RESET_LB),
    .apb_hwce_penable_i ( apb_hwce_enable_i ),

    .MU0_EFPGA_MATHB_OPER_DATA_0_  ( MU0_EFPGA_MATHB_OPER_DATA[0] ),
    .MU0_EFPGA_MATHB_OPER_DATA_1_  ( MU0_EFPGA_MATHB_OPER_DATA[1] ),
    .MU0_EFPGA_MATHB_OPER_DATA_2_  ( MU0_EFPGA_MATHB_OPER_DATA[2] ),
    .MU0_EFPGA_MATHB_OPER_DATA_3_  ( MU0_EFPGA_MATHB_OPER_DATA[3] ),
    .MU0_EFPGA_MATHB_OPER_DATA_4_  ( MU0_EFPGA_MATHB_OPER_DATA[4] ),
    .MU0_EFPGA_MATHB_OPER_DATA_5_  ( MU0_EFPGA_MATHB_OPER_DATA[5] ),
    .MU0_EFPGA_MATHB_OPER_DATA_6_  ( MU0_EFPGA_MATHB_OPER_DATA[6] ),
    .MU0_EFPGA_MATHB_OPER_DATA_7_  ( MU0_EFPGA_MATHB_OPER_DATA[7] ),
    .MU0_EFPGA_MATHB_OPER_DATA_8_  ( MU0_EFPGA_MATHB_OPER_DATA[8] ),
    .MU0_EFPGA_MATHB_OPER_DATA_9_  ( MU0_EFPGA_MATHB_OPER_DATA[9] ),
    .MU0_EFPGA_MATHB_OPER_DATA_10_ ( MU0_EFPGA_MATHB_OPER_DATA[10] ),
    .MU0_EFPGA_MATHB_OPER_DATA_11_ ( MU0_EFPGA_MATHB_OPER_DATA[11] ),
    .MU0_EFPGA_MATHB_OPER_DATA_12_ ( MU0_EFPGA_MATHB_OPER_DATA[12] ),
    .MU0_EFPGA_MATHB_OPER_DATA_13_ ( MU0_EFPGA_MATHB_OPER_DATA[13] ),
    .MU0_EFPGA_MATHB_OPER_DATA_14_ ( MU0_EFPGA_MATHB_OPER_DATA[14] ),
    .MU0_EFPGA_MATHB_OPER_DATA_15_ ( MU0_EFPGA_MATHB_OPER_DATA[15] ),
    .MU0_EFPGA_MATHB_OPER_DATA_16_ ( MU0_EFPGA_MATHB_OPER_DATA[16] ),
    .MU0_EFPGA_MATHB_OPER_DATA_17_ ( MU0_EFPGA_MATHB_OPER_DATA[17] ),
    .MU0_EFPGA_MATHB_OPER_DATA_18_ ( MU0_EFPGA_MATHB_OPER_DATA[18] ),
    .MU0_EFPGA_MATHB_OPER_DATA_19_ ( MU0_EFPGA_MATHB_OPER_DATA[19] ),
    .MU0_EFPGA_MATHB_OPER_DATA_20_ ( MU0_EFPGA_MATHB_OPER_DATA[20] ),
    .MU0_EFPGA_MATHB_OPER_DATA_21_ ( MU0_EFPGA_MATHB_OPER_DATA[21] ),
    .MU0_EFPGA_MATHB_OPER_DATA_22_ ( MU0_EFPGA_MATHB_OPER_DATA[22] ),
    .MU0_EFPGA_MATHB_OPER_DATA_23_ ( MU0_EFPGA_MATHB_OPER_DATA[23] ),
    .MU0_EFPGA_MATHB_OPER_DATA_24_ ( MU0_EFPGA_MATHB_OPER_DATA[24] ),
    .MU0_EFPGA_MATHB_OPER_DATA_25_ ( MU0_EFPGA_MATHB_OPER_DATA[25] ),
    .MU0_EFPGA_MATHB_OPER_DATA_26_ ( MU0_EFPGA_MATHB_OPER_DATA[26] ),
    .MU0_EFPGA_MATHB_OPER_DATA_27_ ( MU0_EFPGA_MATHB_OPER_DATA[27] ),
    .MU0_EFPGA_MATHB_OPER_DATA_28_ ( MU0_EFPGA_MATHB_OPER_DATA[28] ),
    .MU0_EFPGA_MATHB_OPER_DATA_29_ ( MU0_EFPGA_MATHB_OPER_DATA[29] ),
    .MU0_EFPGA_MATHB_OPER_DATA_30_ ( MU0_EFPGA_MATHB_OPER_DATA[30] ),
    .MU0_EFPGA_MATHB_OPER_DATA_31_ ( MU0_EFPGA_MATHB_OPER_DATA[31] ),

    .MU0_EFPGA_MATHB_OPER_defPin_1_ ( MU0_EFPGA_MATHB_OPER_defPin[1] ),
    .MU0_EFPGA_MATHB_OPER_defPin_0_ ( MU0_EFPGA_MATHB_OPER_defPin[0] ),

    .MU0_EFPGA_MATHB_COEF_DATA_0_   ( MU0_EFPGA_MATHB_COEF_DATA[0] ),
    .MU0_EFPGA_MATHB_COEF_DATA_1_   ( MU0_EFPGA_MATHB_COEF_DATA[1] ),
    .MU0_EFPGA_MATHB_COEF_DATA_2_   ( MU0_EFPGA_MATHB_COEF_DATA[2] ),
    .MU0_EFPGA_MATHB_COEF_DATA_3_   ( MU0_EFPGA_MATHB_COEF_DATA[3] ),
    .MU0_EFPGA_MATHB_COEF_DATA_4_   ( MU0_EFPGA_MATHB_COEF_DATA[4] ),
    .MU0_EFPGA_MATHB_COEF_DATA_5_   ( MU0_EFPGA_MATHB_COEF_DATA[5] ),
    .MU0_EFPGA_MATHB_COEF_DATA_6_   ( MU0_EFPGA_MATHB_COEF_DATA[6] ),
    .MU0_EFPGA_MATHB_COEF_DATA_7_   ( MU0_EFPGA_MATHB_COEF_DATA[7] ),
    .MU0_EFPGA_MATHB_COEF_DATA_8_   ( MU0_EFPGA_MATHB_COEF_DATA[8] ),
    .MU0_EFPGA_MATHB_COEF_DATA_9_   ( MU0_EFPGA_MATHB_COEF_DATA[9] ),
    .MU0_EFPGA_MATHB_COEF_DATA_10_  ( MU0_EFPGA_MATHB_COEF_DATA[10] ),
    .MU0_EFPGA_MATHB_COEF_DATA_11_  ( MU0_EFPGA_MATHB_COEF_DATA[11] ),
    .MU0_EFPGA_MATHB_COEF_DATA_12_  ( MU0_EFPGA_MATHB_COEF_DATA[12] ),
    .MU0_EFPGA_MATHB_COEF_DATA_13_  ( MU0_EFPGA_MATHB_COEF_DATA[13] ),
    .MU0_EFPGA_MATHB_COEF_DATA_14_  ( MU0_EFPGA_MATHB_COEF_DATA[14] ),
    .MU0_EFPGA_MATHB_COEF_DATA_15_  ( MU0_EFPGA_MATHB_COEF_DATA[15] ),
    .MU0_EFPGA_MATHB_COEF_DATA_16_  ( MU0_EFPGA_MATHB_COEF_DATA[16] ),
    .MU0_EFPGA_MATHB_COEF_DATA_17_  ( MU0_EFPGA_MATHB_COEF_DATA[17] ),
    .MU0_EFPGA_MATHB_COEF_DATA_18_  ( MU0_EFPGA_MATHB_COEF_DATA[18] ),
    .MU0_EFPGA_MATHB_COEF_DATA_19_  ( MU0_EFPGA_MATHB_COEF_DATA[19] ),
    .MU0_EFPGA_MATHB_COEF_DATA_20_  ( MU0_EFPGA_MATHB_COEF_DATA[20] ),
    .MU0_EFPGA_MATHB_COEF_DATA_21_  ( MU0_EFPGA_MATHB_COEF_DATA[21] ),
    .MU0_EFPGA_MATHB_COEF_DATA_22_  ( MU0_EFPGA_MATHB_COEF_DATA[22] ),
    .MU0_EFPGA_MATHB_COEF_DATA_23_  ( MU0_EFPGA_MATHB_COEF_DATA[23] ),
    .MU0_EFPGA_MATHB_COEF_DATA_24_  ( MU0_EFPGA_MATHB_COEF_DATA[24] ),
    .MU0_EFPGA_MATHB_COEF_DATA_25_  ( MU0_EFPGA_MATHB_COEF_DATA[25] ),
    .MU0_EFPGA_MATHB_COEF_DATA_26_  ( MU0_EFPGA_MATHB_COEF_DATA[26] ),
    .MU0_EFPGA_MATHB_COEF_DATA_27_  ( MU0_EFPGA_MATHB_COEF_DATA[27] ),
    .MU0_EFPGA_MATHB_COEF_DATA_28_  ( MU0_EFPGA_MATHB_COEF_DATA[28] ),
    .MU0_EFPGA_MATHB_COEF_DATA_29_  ( MU0_EFPGA_MATHB_COEF_DATA[29] ),
    .MU0_EFPGA_MATHB_COEF_DATA_30_  ( MU0_EFPGA_MATHB_COEF_DATA[30] ),
    .MU0_EFPGA_MATHB_COEF_DATA_31_  ( MU0_EFPGA_MATHB_COEF_DATA[31] ),

    .MU0_EFPGA_MATHB_COEF_defPin_1_  ( MU0_EFPGA_MATHB_COEF_defPin[1] ),
    .MU0_EFPGA_MATHB_COEF_defPin_0_  ( MU0_EFPGA_MATHB_COEF_defPin[0] ),
    .MU0_EFPGA_MATHB_DATAOUT_SEL_0_  ( MU0_EFPGA_MATHB_DATAOUT_SEL[0] ),
    .MU0_EFPGA_MATHB_DATAOUT_SEL_1_  ( MU0_EFPGA_MATHB_DATAOUT_SEL[1] ),

    .MU0_EFPGA_MATHB_MAC_OUT_SEL_0_  ( MU0_EFPGA_MATHB_MAC_OUT_SEL[0] ),
    .MU0_EFPGA_MATHB_MAC_OUT_SEL_1_  ( MU0_EFPGA_MATHB_MAC_OUT_SEL[1] ),
    .MU0_EFPGA_MATHB_MAC_OUT_SEL_2_  ( MU0_EFPGA_MATHB_MAC_OUT_SEL[2] ),
    .MU0_EFPGA_MATHB_MAC_OUT_SEL_3_  ( MU0_EFPGA_MATHB_MAC_OUT_SEL[3] ),
    .MU0_EFPGA_MATHB_MAC_OUT_SEL_4_  ( MU0_EFPGA_MATHB_MAC_OUT_SEL[4] ),
    .MU0_EFPGA_MATHB_MAC_OUT_SEL_5_  ( MU0_EFPGA_MATHB_MAC_OUT_SEL[5] ),

    .MU0_MATHB_EFPGA_MAC_OUT_0_      ( MU0_MATHB_EFPGA_MAC_OUT[0]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_1_      ( MU0_MATHB_EFPGA_MAC_OUT[1]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_2_      ( MU0_MATHB_EFPGA_MAC_OUT[2]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_3_      ( MU0_MATHB_EFPGA_MAC_OUT[3]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_4_      ( MU0_MATHB_EFPGA_MAC_OUT[4]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_5_      ( MU0_MATHB_EFPGA_MAC_OUT[5]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_6_      ( MU0_MATHB_EFPGA_MAC_OUT[6]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_7_      ( MU0_MATHB_EFPGA_MAC_OUT[7]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_8_      ( MU0_MATHB_EFPGA_MAC_OUT[8]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_9_      ( MU0_MATHB_EFPGA_MAC_OUT[9]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_10_     ( MU0_MATHB_EFPGA_MAC_OUT[10]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_11_     ( MU0_MATHB_EFPGA_MAC_OUT[11]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_12_     ( MU0_MATHB_EFPGA_MAC_OUT[12]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_13_     ( MU0_MATHB_EFPGA_MAC_OUT[13]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_14_     ( MU0_MATHB_EFPGA_MAC_OUT[14]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_15_     ( MU0_MATHB_EFPGA_MAC_OUT[15]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_16_     ( MU0_MATHB_EFPGA_MAC_OUT[16]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_17_     ( MU0_MATHB_EFPGA_MAC_OUT[17]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_18_     ( MU0_MATHB_EFPGA_MAC_OUT[18]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_19_     ( MU0_MATHB_EFPGA_MAC_OUT[19]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_20_     ( MU0_MATHB_EFPGA_MAC_OUT[20]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_21_     ( MU0_MATHB_EFPGA_MAC_OUT[21]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_22_     ( MU0_MATHB_EFPGA_MAC_OUT[22]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_23_     ( MU0_MATHB_EFPGA_MAC_OUT[23]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_24_     ( MU0_MATHB_EFPGA_MAC_OUT[24]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_25_     ( MU0_MATHB_EFPGA_MAC_OUT[25]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_26_     ( MU0_MATHB_EFPGA_MAC_OUT[26]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_27_     ( MU0_MATHB_EFPGA_MAC_OUT[27]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_28_     ( MU0_MATHB_EFPGA_MAC_OUT[28]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_29_     ( MU0_MATHB_EFPGA_MAC_OUT[29]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_30_     ( MU0_MATHB_EFPGA_MAC_OUT[30]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_31_     ( MU0_MATHB_EFPGA_MAC_OUT[31]    ),

    .*
);

`else

`ifdef QL_FIR_TEST


fir_test QL_eFPGA_Design
(
    .clk_i  (CLK0),
    .rst_ni (RESET_LB),

    .MU0_EFPGA_MATHB_OPER_DATA_0_  ( MU0_EFPGA_MATHB_OPER_DATA[0] ),
    .MU0_EFPGA_MATHB_OPER_DATA_1_  ( MU0_EFPGA_MATHB_OPER_DATA[1] ),
    .MU0_EFPGA_MATHB_OPER_DATA_2_  ( MU0_EFPGA_MATHB_OPER_DATA[2] ),
    .MU0_EFPGA_MATHB_OPER_DATA_3_  ( MU0_EFPGA_MATHB_OPER_DATA[3] ),
    .MU0_EFPGA_MATHB_OPER_DATA_4_  ( MU0_EFPGA_MATHB_OPER_DATA[4] ),
    .MU0_EFPGA_MATHB_OPER_DATA_5_  ( MU0_EFPGA_MATHB_OPER_DATA[5] ),
    .MU0_EFPGA_MATHB_OPER_DATA_6_  ( MU0_EFPGA_MATHB_OPER_DATA[6] ),
    .MU0_EFPGA_MATHB_OPER_DATA_7_  ( MU0_EFPGA_MATHB_OPER_DATA[7] ),
    .MU0_EFPGA_MATHB_OPER_DATA_8_  ( MU0_EFPGA_MATHB_OPER_DATA[8] ),
    .MU0_EFPGA_MATHB_OPER_DATA_9_  ( MU0_EFPGA_MATHB_OPER_DATA[9] ),
    .MU0_EFPGA_MATHB_OPER_DATA_10_ ( MU0_EFPGA_MATHB_OPER_DATA[10] ),
    .MU0_EFPGA_MATHB_OPER_DATA_11_ ( MU0_EFPGA_MATHB_OPER_DATA[11] ),
    .MU0_EFPGA_MATHB_OPER_DATA_12_ ( MU0_EFPGA_MATHB_OPER_DATA[12] ),
    .MU0_EFPGA_MATHB_OPER_DATA_13_ ( MU0_EFPGA_MATHB_OPER_DATA[13] ),
    .MU0_EFPGA_MATHB_OPER_DATA_14_ ( MU0_EFPGA_MATHB_OPER_DATA[14] ),
    .MU0_EFPGA_MATHB_OPER_DATA_15_ ( MU0_EFPGA_MATHB_OPER_DATA[15] ),
    .MU0_EFPGA_MATHB_OPER_DATA_16_ ( MU0_EFPGA_MATHB_OPER_DATA[16] ),
    .MU0_EFPGA_MATHB_OPER_DATA_17_ ( MU0_EFPGA_MATHB_OPER_DATA[17] ),
    .MU0_EFPGA_MATHB_OPER_DATA_18_ ( MU0_EFPGA_MATHB_OPER_DATA[18] ),
    .MU0_EFPGA_MATHB_OPER_DATA_19_ ( MU0_EFPGA_MATHB_OPER_DATA[19] ),
    .MU0_EFPGA_MATHB_OPER_DATA_20_ ( MU0_EFPGA_MATHB_OPER_DATA[20] ),
    .MU0_EFPGA_MATHB_OPER_DATA_21_ ( MU0_EFPGA_MATHB_OPER_DATA[21] ),
    .MU0_EFPGA_MATHB_OPER_DATA_22_ ( MU0_EFPGA_MATHB_OPER_DATA[22] ),
    .MU0_EFPGA_MATHB_OPER_DATA_23_ ( MU0_EFPGA_MATHB_OPER_DATA[23] ),
    .MU0_EFPGA_MATHB_OPER_DATA_24_ ( MU0_EFPGA_MATHB_OPER_DATA[24] ),
    .MU0_EFPGA_MATHB_OPER_DATA_25_ ( MU0_EFPGA_MATHB_OPER_DATA[25] ),
    .MU0_EFPGA_MATHB_OPER_DATA_26_ ( MU0_EFPGA_MATHB_OPER_DATA[26] ),
    .MU0_EFPGA_MATHB_OPER_DATA_27_ ( MU0_EFPGA_MATHB_OPER_DATA[27] ),
    .MU0_EFPGA_MATHB_OPER_DATA_28_ ( MU0_EFPGA_MATHB_OPER_DATA[28] ),
    .MU0_EFPGA_MATHB_OPER_DATA_29_ ( MU0_EFPGA_MATHB_OPER_DATA[29] ),
    .MU0_EFPGA_MATHB_OPER_DATA_30_ ( MU0_EFPGA_MATHB_OPER_DATA[30] ),
    .MU0_EFPGA_MATHB_OPER_DATA_31_ ( MU0_EFPGA_MATHB_OPER_DATA[31] ),

    .MU0_EFPGA_MATHB_OPER_defPin_1_ ( MU0_EFPGA_MATHB_OPER_defPin[1] ),
    .MU0_EFPGA_MATHB_OPER_defPin_0_ ( MU0_EFPGA_MATHB_OPER_defPin[0] ),

    .MU0_EFPGA_MATHB_COEF_DATA_0_   ( MU0_EFPGA_MATHB_COEF_DATA[0] ),
    .MU0_EFPGA_MATHB_COEF_DATA_1_   ( MU0_EFPGA_MATHB_COEF_DATA[1] ),
    .MU0_EFPGA_MATHB_COEF_DATA_2_   ( MU0_EFPGA_MATHB_COEF_DATA[2] ),
    .MU0_EFPGA_MATHB_COEF_DATA_3_   ( MU0_EFPGA_MATHB_COEF_DATA[3] ),
    .MU0_EFPGA_MATHB_COEF_DATA_4_   ( MU0_EFPGA_MATHB_COEF_DATA[4] ),
    .MU0_EFPGA_MATHB_COEF_DATA_5_   ( MU0_EFPGA_MATHB_COEF_DATA[5] ),
    .MU0_EFPGA_MATHB_COEF_DATA_6_   ( MU0_EFPGA_MATHB_COEF_DATA[6] ),
    .MU0_EFPGA_MATHB_COEF_DATA_7_   ( MU0_EFPGA_MATHB_COEF_DATA[7] ),
    .MU0_EFPGA_MATHB_COEF_DATA_8_   ( MU0_EFPGA_MATHB_COEF_DATA[8] ),
    .MU0_EFPGA_MATHB_COEF_DATA_9_   ( MU0_EFPGA_MATHB_COEF_DATA[9] ),
    .MU0_EFPGA_MATHB_COEF_DATA_10_  ( MU0_EFPGA_MATHB_COEF_DATA[10] ),
    .MU0_EFPGA_MATHB_COEF_DATA_11_  ( MU0_EFPGA_MATHB_COEF_DATA[11] ),
    .MU0_EFPGA_MATHB_COEF_DATA_12_  ( MU0_EFPGA_MATHB_COEF_DATA[12] ),
    .MU0_EFPGA_MATHB_COEF_DATA_13_  ( MU0_EFPGA_MATHB_COEF_DATA[13] ),
    .MU0_EFPGA_MATHB_COEF_DATA_14_  ( MU0_EFPGA_MATHB_COEF_DATA[14] ),
    .MU0_EFPGA_MATHB_COEF_DATA_15_  ( MU0_EFPGA_MATHB_COEF_DATA[15] ),
    .MU0_EFPGA_MATHB_COEF_DATA_16_  ( MU0_EFPGA_MATHB_COEF_DATA[16] ),
    .MU0_EFPGA_MATHB_COEF_DATA_17_  ( MU0_EFPGA_MATHB_COEF_DATA[17] ),
    .MU0_EFPGA_MATHB_COEF_DATA_18_  ( MU0_EFPGA_MATHB_COEF_DATA[18] ),
    .MU0_EFPGA_MATHB_COEF_DATA_19_  ( MU0_EFPGA_MATHB_COEF_DATA[19] ),
    .MU0_EFPGA_MATHB_COEF_DATA_20_  ( MU0_EFPGA_MATHB_COEF_DATA[20] ),
    .MU0_EFPGA_MATHB_COEF_DATA_21_  ( MU0_EFPGA_MATHB_COEF_DATA[21] ),
    .MU0_EFPGA_MATHB_COEF_DATA_22_  ( MU0_EFPGA_MATHB_COEF_DATA[22] ),
    .MU0_EFPGA_MATHB_COEF_DATA_23_  ( MU0_EFPGA_MATHB_COEF_DATA[23] ),
    .MU0_EFPGA_MATHB_COEF_DATA_24_  ( MU0_EFPGA_MATHB_COEF_DATA[24] ),
    .MU0_EFPGA_MATHB_COEF_DATA_25_  ( MU0_EFPGA_MATHB_COEF_DATA[25] ),
    .MU0_EFPGA_MATHB_COEF_DATA_26_  ( MU0_EFPGA_MATHB_COEF_DATA[26] ),
    .MU0_EFPGA_MATHB_COEF_DATA_27_  ( MU0_EFPGA_MATHB_COEF_DATA[27] ),
    .MU0_EFPGA_MATHB_COEF_DATA_28_  ( MU0_EFPGA_MATHB_COEF_DATA[28] ),
    .MU0_EFPGA_MATHB_COEF_DATA_29_  ( MU0_EFPGA_MATHB_COEF_DATA[29] ),
    .MU0_EFPGA_MATHB_COEF_DATA_30_  ( MU0_EFPGA_MATHB_COEF_DATA[30] ),
    .MU0_EFPGA_MATHB_COEF_DATA_31_  ( MU0_EFPGA_MATHB_COEF_DATA[31] ),

    .MU0_EFPGA_MATHB_COEF_defPin_1_  ( MU0_EFPGA_MATHB_COEF_defPin[1] ),
    .MU0_EFPGA_MATHB_COEF_defPin_0_  ( MU0_EFPGA_MATHB_COEF_defPin[0] ),
    .MU0_EFPGA_MATHB_DATAOUT_SEL_0_  ( MU0_EFPGA_MATHB_DATAOUT_SEL[0] ),
    .MU0_EFPGA_MATHB_DATAOUT_SEL_1_  ( MU0_EFPGA_MATHB_DATAOUT_SEL[1] ),

    .MU0_EFPGA_MATHB_MAC_OUT_SEL_0_  ( MU0_EFPGA_MATHB_MAC_OUT_SEL[0] ),
    .MU0_EFPGA_MATHB_MAC_OUT_SEL_1_  ( MU0_EFPGA_MATHB_MAC_OUT_SEL[1] ),
    .MU0_EFPGA_MATHB_MAC_OUT_SEL_2_  ( MU0_EFPGA_MATHB_MAC_OUT_SEL[2] ),
    .MU0_EFPGA_MATHB_MAC_OUT_SEL_3_  ( MU0_EFPGA_MATHB_MAC_OUT_SEL[3] ),
    .MU0_EFPGA_MATHB_MAC_OUT_SEL_4_  ( MU0_EFPGA_MATHB_MAC_OUT_SEL[4] ),
    .MU0_EFPGA_MATHB_MAC_OUT_SEL_5_  ( MU0_EFPGA_MATHB_MAC_OUT_SEL[5] ),

    .MU0_MATHB_EFPGA_MAC_OUT_0_      ( MU0_MATHB_EFPGA_MAC_OUT[0]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_1_      ( MU0_MATHB_EFPGA_MAC_OUT[1]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_2_      ( MU0_MATHB_EFPGA_MAC_OUT[2]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_3_      ( MU0_MATHB_EFPGA_MAC_OUT[3]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_4_      ( MU0_MATHB_EFPGA_MAC_OUT[4]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_5_      ( MU0_MATHB_EFPGA_MAC_OUT[5]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_6_      ( MU0_MATHB_EFPGA_MAC_OUT[6]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_7_      ( MU0_MATHB_EFPGA_MAC_OUT[7]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_8_      ( MU0_MATHB_EFPGA_MAC_OUT[8]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_9_      ( MU0_MATHB_EFPGA_MAC_OUT[9]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_10_     ( MU0_MATHB_EFPGA_MAC_OUT[10]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_11_     ( MU0_MATHB_EFPGA_MAC_OUT[11]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_12_     ( MU0_MATHB_EFPGA_MAC_OUT[12]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_13_     ( MU0_MATHB_EFPGA_MAC_OUT[13]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_14_     ( MU0_MATHB_EFPGA_MAC_OUT[14]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_15_     ( MU0_MATHB_EFPGA_MAC_OUT[15]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_16_     ( MU0_MATHB_EFPGA_MAC_OUT[16]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_17_     ( MU0_MATHB_EFPGA_MAC_OUT[17]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_18_     ( MU0_MATHB_EFPGA_MAC_OUT[18]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_19_     ( MU0_MATHB_EFPGA_MAC_OUT[19]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_20_     ( MU0_MATHB_EFPGA_MAC_OUT[20]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_21_     ( MU0_MATHB_EFPGA_MAC_OUT[21]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_22_     ( MU0_MATHB_EFPGA_MAC_OUT[22]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_23_     ( MU0_MATHB_EFPGA_MAC_OUT[23]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_24_     ( MU0_MATHB_EFPGA_MAC_OUT[24]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_25_     ( MU0_MATHB_EFPGA_MAC_OUT[25]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_26_     ( MU0_MATHB_EFPGA_MAC_OUT[26]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_27_     ( MU0_MATHB_EFPGA_MAC_OUT[27]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_28_     ( MU0_MATHB_EFPGA_MAC_OUT[28]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_29_     ( MU0_MATHB_EFPGA_MAC_OUT[29]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_30_     ( MU0_MATHB_EFPGA_MAC_OUT[30]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_31_     ( MU0_MATHB_EFPGA_MAC_OUT[31]    ),

    .*


);

`else

`ifdef QL_IIR_TEST


iir_test QL_eFPGA_Design
(
    .clk_i  (CLK0),
    .rst_ni (RESET_LB),

    .MU0_EFPGA_MATHB_OPER_DATA_0_  ( MU0_EFPGA_MATHB_OPER_DATA[0] ),
    .MU0_EFPGA_MATHB_OPER_DATA_1_  ( MU0_EFPGA_MATHB_OPER_DATA[1] ),
    .MU0_EFPGA_MATHB_OPER_DATA_2_  ( MU0_EFPGA_MATHB_OPER_DATA[2] ),
    .MU0_EFPGA_MATHB_OPER_DATA_3_  ( MU0_EFPGA_MATHB_OPER_DATA[3] ),
    .MU0_EFPGA_MATHB_OPER_DATA_4_  ( MU0_EFPGA_MATHB_OPER_DATA[4] ),
    .MU0_EFPGA_MATHB_OPER_DATA_5_  ( MU0_EFPGA_MATHB_OPER_DATA[5] ),
    .MU0_EFPGA_MATHB_OPER_DATA_6_  ( MU0_EFPGA_MATHB_OPER_DATA[6] ),
    .MU0_EFPGA_MATHB_OPER_DATA_7_  ( MU0_EFPGA_MATHB_OPER_DATA[7] ),
    .MU0_EFPGA_MATHB_OPER_DATA_8_  ( MU0_EFPGA_MATHB_OPER_DATA[8] ),
    .MU0_EFPGA_MATHB_OPER_DATA_9_  ( MU0_EFPGA_MATHB_OPER_DATA[9] ),
    .MU0_EFPGA_MATHB_OPER_DATA_10_ ( MU0_EFPGA_MATHB_OPER_DATA[10] ),
    .MU0_EFPGA_MATHB_OPER_DATA_11_ ( MU0_EFPGA_MATHB_OPER_DATA[11] ),
    .MU0_EFPGA_MATHB_OPER_DATA_12_ ( MU0_EFPGA_MATHB_OPER_DATA[12] ),
    .MU0_EFPGA_MATHB_OPER_DATA_13_ ( MU0_EFPGA_MATHB_OPER_DATA[13] ),
    .MU0_EFPGA_MATHB_OPER_DATA_14_ ( MU0_EFPGA_MATHB_OPER_DATA[14] ),
    .MU0_EFPGA_MATHB_OPER_DATA_15_ ( MU0_EFPGA_MATHB_OPER_DATA[15] ),
    .MU0_EFPGA_MATHB_OPER_DATA_16_ ( MU0_EFPGA_MATHB_OPER_DATA[16] ),
    .MU0_EFPGA_MATHB_OPER_DATA_17_ ( MU0_EFPGA_MATHB_OPER_DATA[17] ),
    .MU0_EFPGA_MATHB_OPER_DATA_18_ ( MU0_EFPGA_MATHB_OPER_DATA[18] ),
    .MU0_EFPGA_MATHB_OPER_DATA_19_ ( MU0_EFPGA_MATHB_OPER_DATA[19] ),
    .MU0_EFPGA_MATHB_OPER_DATA_20_ ( MU0_EFPGA_MATHB_OPER_DATA[20] ),
    .MU0_EFPGA_MATHB_OPER_DATA_21_ ( MU0_EFPGA_MATHB_OPER_DATA[21] ),
    .MU0_EFPGA_MATHB_OPER_DATA_22_ ( MU0_EFPGA_MATHB_OPER_DATA[22] ),
    .MU0_EFPGA_MATHB_OPER_DATA_23_ ( MU0_EFPGA_MATHB_OPER_DATA[23] ),
    .MU0_EFPGA_MATHB_OPER_DATA_24_ ( MU0_EFPGA_MATHB_OPER_DATA[24] ),
    .MU0_EFPGA_MATHB_OPER_DATA_25_ ( MU0_EFPGA_MATHB_OPER_DATA[25] ),
    .MU0_EFPGA_MATHB_OPER_DATA_26_ ( MU0_EFPGA_MATHB_OPER_DATA[26] ),
    .MU0_EFPGA_MATHB_OPER_DATA_27_ ( MU0_EFPGA_MATHB_OPER_DATA[27] ),
    .MU0_EFPGA_MATHB_OPER_DATA_28_ ( MU0_EFPGA_MATHB_OPER_DATA[28] ),
    .MU0_EFPGA_MATHB_OPER_DATA_29_ ( MU0_EFPGA_MATHB_OPER_DATA[29] ),
    .MU0_EFPGA_MATHB_OPER_DATA_30_ ( MU0_EFPGA_MATHB_OPER_DATA[30] ),
    .MU0_EFPGA_MATHB_OPER_DATA_31_ ( MU0_EFPGA_MATHB_OPER_DATA[31] ),

    .MU0_EFPGA_MATHB_OPER_defPin_1_ ( MU0_EFPGA_MATHB_OPER_defPin[1] ),
    .MU0_EFPGA_MATHB_OPER_defPin_0_ ( MU0_EFPGA_MATHB_OPER_defPin[0] ),

    .MU0_EFPGA_MATHB_COEF_DATA_0_   ( MU0_EFPGA_MATHB_COEF_DATA[0] ),
    .MU0_EFPGA_MATHB_COEF_DATA_1_   ( MU0_EFPGA_MATHB_COEF_DATA[1] ),
    .MU0_EFPGA_MATHB_COEF_DATA_2_   ( MU0_EFPGA_MATHB_COEF_DATA[2] ),
    .MU0_EFPGA_MATHB_COEF_DATA_3_   ( MU0_EFPGA_MATHB_COEF_DATA[3] ),
    .MU0_EFPGA_MATHB_COEF_DATA_4_   ( MU0_EFPGA_MATHB_COEF_DATA[4] ),
    .MU0_EFPGA_MATHB_COEF_DATA_5_   ( MU0_EFPGA_MATHB_COEF_DATA[5] ),
    .MU0_EFPGA_MATHB_COEF_DATA_6_   ( MU0_EFPGA_MATHB_COEF_DATA[6] ),
    .MU0_EFPGA_MATHB_COEF_DATA_7_   ( MU0_EFPGA_MATHB_COEF_DATA[7] ),
    .MU0_EFPGA_MATHB_COEF_DATA_8_   ( MU0_EFPGA_MATHB_COEF_DATA[8] ),
    .MU0_EFPGA_MATHB_COEF_DATA_9_   ( MU0_EFPGA_MATHB_COEF_DATA[9] ),
    .MU0_EFPGA_MATHB_COEF_DATA_10_  ( MU0_EFPGA_MATHB_COEF_DATA[10] ),
    .MU0_EFPGA_MATHB_COEF_DATA_11_  ( MU0_EFPGA_MATHB_COEF_DATA[11] ),
    .MU0_EFPGA_MATHB_COEF_DATA_12_  ( MU0_EFPGA_MATHB_COEF_DATA[12] ),
    .MU0_EFPGA_MATHB_COEF_DATA_13_  ( MU0_EFPGA_MATHB_COEF_DATA[13] ),
    .MU0_EFPGA_MATHB_COEF_DATA_14_  ( MU0_EFPGA_MATHB_COEF_DATA[14] ),
    .MU0_EFPGA_MATHB_COEF_DATA_15_  ( MU0_EFPGA_MATHB_COEF_DATA[15] ),
    .MU0_EFPGA_MATHB_COEF_DATA_16_  ( MU0_EFPGA_MATHB_COEF_DATA[16] ),
    .MU0_EFPGA_MATHB_COEF_DATA_17_  ( MU0_EFPGA_MATHB_COEF_DATA[17] ),
    .MU0_EFPGA_MATHB_COEF_DATA_18_  ( MU0_EFPGA_MATHB_COEF_DATA[18] ),
    .MU0_EFPGA_MATHB_COEF_DATA_19_  ( MU0_EFPGA_MATHB_COEF_DATA[19] ),
    .MU0_EFPGA_MATHB_COEF_DATA_20_  ( MU0_EFPGA_MATHB_COEF_DATA[20] ),
    .MU0_EFPGA_MATHB_COEF_DATA_21_  ( MU0_EFPGA_MATHB_COEF_DATA[21] ),
    .MU0_EFPGA_MATHB_COEF_DATA_22_  ( MU0_EFPGA_MATHB_COEF_DATA[22] ),
    .MU0_EFPGA_MATHB_COEF_DATA_23_  ( MU0_EFPGA_MATHB_COEF_DATA[23] ),
    .MU0_EFPGA_MATHB_COEF_DATA_24_  ( MU0_EFPGA_MATHB_COEF_DATA[24] ),
    .MU0_EFPGA_MATHB_COEF_DATA_25_  ( MU0_EFPGA_MATHB_COEF_DATA[25] ),
    .MU0_EFPGA_MATHB_COEF_DATA_26_  ( MU0_EFPGA_MATHB_COEF_DATA[26] ),
    .MU0_EFPGA_MATHB_COEF_DATA_27_  ( MU0_EFPGA_MATHB_COEF_DATA[27] ),
    .MU0_EFPGA_MATHB_COEF_DATA_28_  ( MU0_EFPGA_MATHB_COEF_DATA[28] ),
    .MU0_EFPGA_MATHB_COEF_DATA_29_  ( MU0_EFPGA_MATHB_COEF_DATA[29] ),
    .MU0_EFPGA_MATHB_COEF_DATA_30_  ( MU0_EFPGA_MATHB_COEF_DATA[30] ),
    .MU0_EFPGA_MATHB_COEF_DATA_31_  ( MU0_EFPGA_MATHB_COEF_DATA[31] ),

    .MU0_EFPGA_MATHB_COEF_defPin_1_  ( MU0_EFPGA_MATHB_COEF_defPin[1] ),
    .MU0_EFPGA_MATHB_COEF_defPin_0_  ( MU0_EFPGA_MATHB_COEF_defPin[0] ),
    .MU0_EFPGA_MATHB_DATAOUT_SEL_0_  ( MU0_EFPGA_MATHB_DATAOUT_SEL[0] ),
    .MU0_EFPGA_MATHB_DATAOUT_SEL_1_  ( MU0_EFPGA_MATHB_DATAOUT_SEL[1] ),

    .MU0_EFPGA_MATHB_MAC_OUT_SEL_0_  ( MU0_EFPGA_MATHB_MAC_OUT_SEL[0] ),
    .MU0_EFPGA_MATHB_MAC_OUT_SEL_1_  ( MU0_EFPGA_MATHB_MAC_OUT_SEL[1] ),
    .MU0_EFPGA_MATHB_MAC_OUT_SEL_2_  ( MU0_EFPGA_MATHB_MAC_OUT_SEL[2] ),
    .MU0_EFPGA_MATHB_MAC_OUT_SEL_3_  ( MU0_EFPGA_MATHB_MAC_OUT_SEL[3] ),
    .MU0_EFPGA_MATHB_MAC_OUT_SEL_4_  ( MU0_EFPGA_MATHB_MAC_OUT_SEL[4] ),
    .MU0_EFPGA_MATHB_MAC_OUT_SEL_5_  ( MU0_EFPGA_MATHB_MAC_OUT_SEL[5] ),

    .MU0_MATHB_EFPGA_MAC_OUT_0_      ( MU0_MATHB_EFPGA_MAC_OUT[0]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_1_      ( MU0_MATHB_EFPGA_MAC_OUT[1]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_2_      ( MU0_MATHB_EFPGA_MAC_OUT[2]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_3_      ( MU0_MATHB_EFPGA_MAC_OUT[3]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_4_      ( MU0_MATHB_EFPGA_MAC_OUT[4]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_5_      ( MU0_MATHB_EFPGA_MAC_OUT[5]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_6_      ( MU0_MATHB_EFPGA_MAC_OUT[6]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_7_      ( MU0_MATHB_EFPGA_MAC_OUT[7]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_8_      ( MU0_MATHB_EFPGA_MAC_OUT[8]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_9_      ( MU0_MATHB_EFPGA_MAC_OUT[9]     ),
    .MU0_MATHB_EFPGA_MAC_OUT_10_     ( MU0_MATHB_EFPGA_MAC_OUT[10]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_11_     ( MU0_MATHB_EFPGA_MAC_OUT[11]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_12_     ( MU0_MATHB_EFPGA_MAC_OUT[12]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_13_     ( MU0_MATHB_EFPGA_MAC_OUT[13]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_14_     ( MU0_MATHB_EFPGA_MAC_OUT[14]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_15_     ( MU0_MATHB_EFPGA_MAC_OUT[15]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_16_     ( MU0_MATHB_EFPGA_MAC_OUT[16]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_17_     ( MU0_MATHB_EFPGA_MAC_OUT[17]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_18_     ( MU0_MATHB_EFPGA_MAC_OUT[18]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_19_     ( MU0_MATHB_EFPGA_MAC_OUT[19]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_20_     ( MU0_MATHB_EFPGA_MAC_OUT[20]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_21_     ( MU0_MATHB_EFPGA_MAC_OUT[21]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_22_     ( MU0_MATHB_EFPGA_MAC_OUT[22]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_23_     ( MU0_MATHB_EFPGA_MAC_OUT[23]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_24_     ( MU0_MATHB_EFPGA_MAC_OUT[24]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_25_     ( MU0_MATHB_EFPGA_MAC_OUT[25]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_26_     ( MU0_MATHB_EFPGA_MAC_OUT[26]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_27_     ( MU0_MATHB_EFPGA_MAC_OUT[27]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_28_     ( MU0_MATHB_EFPGA_MAC_OUT[28]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_29_     ( MU0_MATHB_EFPGA_MAC_OUT[29]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_30_     ( MU0_MATHB_EFPGA_MAC_OUT[30]    ),
    .MU0_MATHB_EFPGA_MAC_OUT_31_     ( MU0_MATHB_EFPGA_MAC_OUT[31]    ),

    .MU1_EFPGA_MATHB_OPER_DATA_0_  ( MU1_EFPGA_MATHB_OPER_DATA[0] ),
    .MU1_EFPGA_MATHB_OPER_DATA_1_  ( MU1_EFPGA_MATHB_OPER_DATA[1] ),
    .MU1_EFPGA_MATHB_OPER_DATA_2_  ( MU1_EFPGA_MATHB_OPER_DATA[2] ),
    .MU1_EFPGA_MATHB_OPER_DATA_3_  ( MU1_EFPGA_MATHB_OPER_DATA[3] ),
    .MU1_EFPGA_MATHB_OPER_DATA_4_  ( MU1_EFPGA_MATHB_OPER_DATA[4] ),
    .MU1_EFPGA_MATHB_OPER_DATA_5_  ( MU1_EFPGA_MATHB_OPER_DATA[5] ),
    .MU1_EFPGA_MATHB_OPER_DATA_6_  ( MU1_EFPGA_MATHB_OPER_DATA[6] ),
    .MU1_EFPGA_MATHB_OPER_DATA_7_  ( MU1_EFPGA_MATHB_OPER_DATA[7] ),
    .MU1_EFPGA_MATHB_OPER_DATA_8_  ( MU1_EFPGA_MATHB_OPER_DATA[8] ),
    .MU1_EFPGA_MATHB_OPER_DATA_9_  ( MU1_EFPGA_MATHB_OPER_DATA[9] ),
    .MU1_EFPGA_MATHB_OPER_DATA_10_ ( MU1_EFPGA_MATHB_OPER_DATA[10] ),
    .MU1_EFPGA_MATHB_OPER_DATA_11_ ( MU1_EFPGA_MATHB_OPER_DATA[11] ),
    .MU1_EFPGA_MATHB_OPER_DATA_12_ ( MU1_EFPGA_MATHB_OPER_DATA[12] ),
    .MU1_EFPGA_MATHB_OPER_DATA_13_ ( MU1_EFPGA_MATHB_OPER_DATA[13] ),
    .MU1_EFPGA_MATHB_OPER_DATA_14_ ( MU1_EFPGA_MATHB_OPER_DATA[14] ),
    .MU1_EFPGA_MATHB_OPER_DATA_15_ ( MU1_EFPGA_MATHB_OPER_DATA[15] ),
    .MU1_EFPGA_MATHB_OPER_DATA_16_ ( MU1_EFPGA_MATHB_OPER_DATA[16] ),
    .MU1_EFPGA_MATHB_OPER_DATA_17_ ( MU1_EFPGA_MATHB_OPER_DATA[17] ),
    .MU1_EFPGA_MATHB_OPER_DATA_18_ ( MU1_EFPGA_MATHB_OPER_DATA[18] ),
    .MU1_EFPGA_MATHB_OPER_DATA_19_ ( MU1_EFPGA_MATHB_OPER_DATA[19] ),
    .MU1_EFPGA_MATHB_OPER_DATA_20_ ( MU1_EFPGA_MATHB_OPER_DATA[20] ),
    .MU1_EFPGA_MATHB_OPER_DATA_21_ ( MU1_EFPGA_MATHB_OPER_DATA[21] ),
    .MU1_EFPGA_MATHB_OPER_DATA_22_ ( MU1_EFPGA_MATHB_OPER_DATA[22] ),
    .MU1_EFPGA_MATHB_OPER_DATA_23_ ( MU1_EFPGA_MATHB_OPER_DATA[23] ),
    .MU1_EFPGA_MATHB_OPER_DATA_24_ ( MU1_EFPGA_MATHB_OPER_DATA[24] ),
    .MU1_EFPGA_MATHB_OPER_DATA_25_ ( MU1_EFPGA_MATHB_OPER_DATA[25] ),
    .MU1_EFPGA_MATHB_OPER_DATA_26_ ( MU1_EFPGA_MATHB_OPER_DATA[26] ),
    .MU1_EFPGA_MATHB_OPER_DATA_27_ ( MU1_EFPGA_MATHB_OPER_DATA[27] ),
    .MU1_EFPGA_MATHB_OPER_DATA_28_ ( MU1_EFPGA_MATHB_OPER_DATA[28] ),
    .MU1_EFPGA_MATHB_OPER_DATA_29_ ( MU1_EFPGA_MATHB_OPER_DATA[29] ),
    .MU1_EFPGA_MATHB_OPER_DATA_30_ ( MU1_EFPGA_MATHB_OPER_DATA[30] ),
    .MU1_EFPGA_MATHB_OPER_DATA_31_ ( MU1_EFPGA_MATHB_OPER_DATA[31] ),

    .MU1_EFPGA_MATHB_OPER_defPin_1_ ( MU1_EFPGA_MATHB_OPER_defPin[1] ),
    .MU1_EFPGA_MATHB_OPER_defPin_0_ ( MU1_EFPGA_MATHB_OPER_defPin[0] ),

    .MU1_EFPGA_MATHB_COEF_DATA_0_   ( MU1_EFPGA_MATHB_COEF_DATA[0] ),
    .MU1_EFPGA_MATHB_COEF_DATA_1_   ( MU1_EFPGA_MATHB_COEF_DATA[1] ),
    .MU1_EFPGA_MATHB_COEF_DATA_2_   ( MU1_EFPGA_MATHB_COEF_DATA[2] ),
    .MU1_EFPGA_MATHB_COEF_DATA_3_   ( MU1_EFPGA_MATHB_COEF_DATA[3] ),
    .MU1_EFPGA_MATHB_COEF_DATA_4_   ( MU1_EFPGA_MATHB_COEF_DATA[4] ),
    .MU1_EFPGA_MATHB_COEF_DATA_5_   ( MU1_EFPGA_MATHB_COEF_DATA[5] ),
    .MU1_EFPGA_MATHB_COEF_DATA_6_   ( MU1_EFPGA_MATHB_COEF_DATA[6] ),
    .MU1_EFPGA_MATHB_COEF_DATA_7_   ( MU1_EFPGA_MATHB_COEF_DATA[7] ),
    .MU1_EFPGA_MATHB_COEF_DATA_8_   ( MU1_EFPGA_MATHB_COEF_DATA[8] ),
    .MU1_EFPGA_MATHB_COEF_DATA_9_   ( MU1_EFPGA_MATHB_COEF_DATA[9] ),
    .MU1_EFPGA_MATHB_COEF_DATA_10_  ( MU1_EFPGA_MATHB_COEF_DATA[10] ),
    .MU1_EFPGA_MATHB_COEF_DATA_11_  ( MU1_EFPGA_MATHB_COEF_DATA[11] ),
    .MU1_EFPGA_MATHB_COEF_DATA_12_  ( MU1_EFPGA_MATHB_COEF_DATA[12] ),
    .MU1_EFPGA_MATHB_COEF_DATA_13_  ( MU1_EFPGA_MATHB_COEF_DATA[13] ),
    .MU1_EFPGA_MATHB_COEF_DATA_14_  ( MU1_EFPGA_MATHB_COEF_DATA[14] ),
    .MU1_EFPGA_MATHB_COEF_DATA_15_  ( MU1_EFPGA_MATHB_COEF_DATA[15] ),
    .MU1_EFPGA_MATHB_COEF_DATA_16_  ( MU1_EFPGA_MATHB_COEF_DATA[16] ),
    .MU1_EFPGA_MATHB_COEF_DATA_17_  ( MU1_EFPGA_MATHB_COEF_DATA[17] ),
    .MU1_EFPGA_MATHB_COEF_DATA_18_  ( MU1_EFPGA_MATHB_COEF_DATA[18] ),
    .MU1_EFPGA_MATHB_COEF_DATA_19_  ( MU1_EFPGA_MATHB_COEF_DATA[19] ),
    .MU1_EFPGA_MATHB_COEF_DATA_20_  ( MU1_EFPGA_MATHB_COEF_DATA[20] ),
    .MU1_EFPGA_MATHB_COEF_DATA_21_  ( MU1_EFPGA_MATHB_COEF_DATA[21] ),
    .MU1_EFPGA_MATHB_COEF_DATA_22_  ( MU1_EFPGA_MATHB_COEF_DATA[22] ),
    .MU1_EFPGA_MATHB_COEF_DATA_23_  ( MU1_EFPGA_MATHB_COEF_DATA[23] ),
    .MU1_EFPGA_MATHB_COEF_DATA_24_  ( MU1_EFPGA_MATHB_COEF_DATA[24] ),
    .MU1_EFPGA_MATHB_COEF_DATA_25_  ( MU1_EFPGA_MATHB_COEF_DATA[25] ),
    .MU1_EFPGA_MATHB_COEF_DATA_26_  ( MU1_EFPGA_MATHB_COEF_DATA[26] ),
    .MU1_EFPGA_MATHB_COEF_DATA_27_  ( MU1_EFPGA_MATHB_COEF_DATA[27] ),
    .MU1_EFPGA_MATHB_COEF_DATA_28_  ( MU1_EFPGA_MATHB_COEF_DATA[28] ),
    .MU1_EFPGA_MATHB_COEF_DATA_29_  ( MU1_EFPGA_MATHB_COEF_DATA[29] ),
    .MU1_EFPGA_MATHB_COEF_DATA_30_  ( MU1_EFPGA_MATHB_COEF_DATA[30] ),
    .MU1_EFPGA_MATHB_COEF_DATA_31_  ( MU1_EFPGA_MATHB_COEF_DATA[31] ),

    .MU1_EFPGA_MATHB_COEF_defPin_1_  ( MU1_EFPGA_MATHB_COEF_defPin[1] ),
    .MU1_EFPGA_MATHB_COEF_defPin_0_  ( MU1_EFPGA_MATHB_COEF_defPin[0] ),
    .MU1_EFPGA_MATHB_DATAOUT_SEL_0_  ( MU1_EFPGA_MATHB_DATAOUT_SEL[0] ),
    .MU1_EFPGA_MATHB_DATAOUT_SEL_1_  ( MU1_EFPGA_MATHB_DATAOUT_SEL[1] ),

    .MU1_EFPGA_MATHB_MAC_OUT_SEL_0_  ( MU1_EFPGA_MATHB_MAC_OUT_SEL[0] ),
    .MU1_EFPGA_MATHB_MAC_OUT_SEL_1_  ( MU1_EFPGA_MATHB_MAC_OUT_SEL[1] ),
    .MU1_EFPGA_MATHB_MAC_OUT_SEL_2_  ( MU1_EFPGA_MATHB_MAC_OUT_SEL[2] ),
    .MU1_EFPGA_MATHB_MAC_OUT_SEL_3_  ( MU1_EFPGA_MATHB_MAC_OUT_SEL[3] ),
    .MU1_EFPGA_MATHB_MAC_OUT_SEL_4_  ( MU1_EFPGA_MATHB_MAC_OUT_SEL[4] ),
    .MU1_EFPGA_MATHB_MAC_OUT_SEL_5_  ( MU1_EFPGA_MATHB_MAC_OUT_SEL[5] ),

    .MU1_MATHB_EFPGA_MAC_OUT_0_      ( MU1_MATHB_EFPGA_MAC_OUT[0]     ),
    .MU1_MATHB_EFPGA_MAC_OUT_1_      ( MU1_MATHB_EFPGA_MAC_OUT[1]     ),
    .MU1_MATHB_EFPGA_MAC_OUT_2_      ( MU1_MATHB_EFPGA_MAC_OUT[2]     ),
    .MU1_MATHB_EFPGA_MAC_OUT_3_      ( MU1_MATHB_EFPGA_MAC_OUT[3]     ),
    .MU1_MATHB_EFPGA_MAC_OUT_4_      ( MU1_MATHB_EFPGA_MAC_OUT[4]     ),
    .MU1_MATHB_EFPGA_MAC_OUT_5_      ( MU1_MATHB_EFPGA_MAC_OUT[5]     ),
    .MU1_MATHB_EFPGA_MAC_OUT_6_      ( MU1_MATHB_EFPGA_MAC_OUT[6]     ),
    .MU1_MATHB_EFPGA_MAC_OUT_7_      ( MU1_MATHB_EFPGA_MAC_OUT[7]     ),
    .MU1_MATHB_EFPGA_MAC_OUT_8_      ( MU1_MATHB_EFPGA_MAC_OUT[8]     ),
    .MU1_MATHB_EFPGA_MAC_OUT_9_      ( MU1_MATHB_EFPGA_MAC_OUT[9]     ),
    .MU1_MATHB_EFPGA_MAC_OUT_10_     ( MU1_MATHB_EFPGA_MAC_OUT[10]    ),
    .MU1_MATHB_EFPGA_MAC_OUT_11_     ( MU1_MATHB_EFPGA_MAC_OUT[11]    ),
    .MU1_MATHB_EFPGA_MAC_OUT_12_     ( MU1_MATHB_EFPGA_MAC_OUT[12]    ),
    .MU1_MATHB_EFPGA_MAC_OUT_13_     ( MU1_MATHB_EFPGA_MAC_OUT[13]    ),
    .MU1_MATHB_EFPGA_MAC_OUT_14_     ( MU1_MATHB_EFPGA_MAC_OUT[14]    ),
    .MU1_MATHB_EFPGA_MAC_OUT_15_     ( MU1_MATHB_EFPGA_MAC_OUT[15]    ),
    .MU1_MATHB_EFPGA_MAC_OUT_16_     ( MU1_MATHB_EFPGA_MAC_OUT[16]    ),
    .MU1_MATHB_EFPGA_MAC_OUT_17_     ( MU1_MATHB_EFPGA_MAC_OUT[17]    ),
    .MU1_MATHB_EFPGA_MAC_OUT_18_     ( MU1_MATHB_EFPGA_MAC_OUT[18]    ),
    .MU1_MATHB_EFPGA_MAC_OUT_19_     ( MU1_MATHB_EFPGA_MAC_OUT[19]    ),
    .MU1_MATHB_EFPGA_MAC_OUT_20_     ( MU1_MATHB_EFPGA_MAC_OUT[20]    ),
    .MU1_MATHB_EFPGA_MAC_OUT_21_     ( MU1_MATHB_EFPGA_MAC_OUT[21]    ),
    .MU1_MATHB_EFPGA_MAC_OUT_22_     ( MU1_MATHB_EFPGA_MAC_OUT[22]    ),
    .MU1_MATHB_EFPGA_MAC_OUT_23_     ( MU1_MATHB_EFPGA_MAC_OUT[23]    ),
    .MU1_MATHB_EFPGA_MAC_OUT_24_     ( MU1_MATHB_EFPGA_MAC_OUT[24]    ),
    .MU1_MATHB_EFPGA_MAC_OUT_25_     ( MU1_MATHB_EFPGA_MAC_OUT[25]    ),
    .MU1_MATHB_EFPGA_MAC_OUT_26_     ( MU1_MATHB_EFPGA_MAC_OUT[26]    ),
    .MU1_MATHB_EFPGA_MAC_OUT_27_     ( MU1_MATHB_EFPGA_MAC_OUT[27]    ),
    .MU1_MATHB_EFPGA_MAC_OUT_28_     ( MU1_MATHB_EFPGA_MAC_OUT[28]    ),
    .MU1_MATHB_EFPGA_MAC_OUT_29_     ( MU1_MATHB_EFPGA_MAC_OUT[29]    ),
    .MU1_MATHB_EFPGA_MAC_OUT_30_     ( MU1_MATHB_EFPGA_MAC_OUT[30]    ),
    .MU1_MATHB_EFPGA_MAC_OUT_31_     ( MU1_MATHB_EFPGA_MAC_OUT[31]    ),
    .*


);



`else
  `ifndef PULP_FPGA_EMUL
    //}}}
    myDesign_QL_eFPGA_ArcticPro2_32X32_GF_22_QL_eFPGA QL_eFPGA_Design (
    //{{{
    // Outputs
      .BL_DOUT_0_      (fcb_bl_dout[0]),
      .BL_DOUT_10_     (fcb_bl_dout[1]),
      .BL_DOUT_11_     (fcb_bl_dout[2]),
      .BL_DOUT_12_     (fcb_bl_dout[3]),
      .BL_DOUT_13_     (fcb_bl_dout[4]),
      .BL_DOUT_14_     (fcb_bl_dout[5]),
      .BL_DOUT_15_     (fcb_bl_dout[6]),
      .BL_DOUT_16_     (fcb_bl_dout[7]),
      .BL_DOUT_17_     (fcb_bl_dout[8]),
      .BL_DOUT_18_     (fcb_bl_dout[9]),
      .BL_DOUT_19_     (fcb_bl_dout[10]),
      .BL_DOUT_1_      (fcb_bl_dout[11]),
      .BL_DOUT_20_     (fcb_bl_dout[12]),
      .BL_DOUT_21_     (fcb_bl_dout[13]),
      .BL_DOUT_22_     (fcb_bl_dout[14]),
      .BL_DOUT_23_     (fcb_bl_dout[15]),
      .BL_DOUT_24_     (fcb_bl_dout[16]),
      .BL_DOUT_25_     (fcb_bl_dout[17]),
      .BL_DOUT_26_     (fcb_bl_dout[18]),
      .BL_DOUT_27_     (fcb_bl_dout[19]),
      .BL_DOUT_28_     (fcb_bl_dout[20]),
      .BL_DOUT_29_     (fcb_bl_dout[21]),
      .BL_DOUT_2_      (fcb_bl_dout[22]),
      .BL_DOUT_30_     (fcb_bl_dout[23]),
      .BL_DOUT_31_     (fcb_bl_dout[24]),
      .BL_DOUT_3_      (fcb_bl_dout[25]),
      .BL_DOUT_4_      (fcb_bl_dout[26]),
      .BL_DOUT_5_      (fcb_bl_dout[27]),
      .BL_DOUT_6_      (fcb_bl_dout[28]),
      .BL_DOUT_7_      (fcb_bl_dout[29]),
      .BL_DOUT_8_      (fcb_bl_dout[30]),
      .BL_DOUT_9_      (fcb_bl_dout[31]),
      .FB_SPE_OUT_0_   (FB_SPE_OUT_0_),
      .FB_SPE_OUT_1_   (FB_SPE_OUT_1_),
      .FB_SPE_OUT_2_   (FB_SPE_OUT_2_),
      .FB_SPE_OUT_3_   (FB_SPE_OUT_3_),
      .PARALLEL_CFG    (fcb_pif_en),


    // Inputs
      .supplyBus        (supplyBus    ),
      .M_0_             (M_0_),
      .BL_CLK           (fcb_blclk),
      .BL_DIN_0_        (fcb_bl_din[0]),
      .BL_DIN_10_       (fcb_bl_din[10]),
      .BL_DIN_11_       (fcb_bl_din[11]),
      .BL_DIN_12_       (fcb_bl_din[12]),
      .BL_DIN_13_       (fcb_bl_din[13]),
      .BL_DIN_14_       (fcb_bl_din[14]),
      .BL_DIN_15_       (fcb_bl_din[15]),
      .BL_DIN_16_       (fcb_bl_din[16]),
      .BL_DIN_17_       (fcb_bl_din[17]),
      .BL_DIN_18_       (fcb_bl_din[18]),
      .BL_DIN_19_       (fcb_bl_din[19]),
      .BL_DIN_1_        (fcb_bl_din[1]),
      .BL_DIN_20_       (fcb_bl_din[20]),
      .BL_DIN_21_       (fcb_bl_din[21]),
      .BL_DIN_22_       (fcb_bl_din[22]),
      .BL_DIN_23_       (fcb_bl_din[23]),
      .BL_DIN_24_       (fcb_bl_din[24]),
      .BL_DIN_25_       (fcb_bl_din[25]),
      .BL_DIN_26_       (fcb_bl_din[26]),
      .BL_DIN_27_       (fcb_bl_din[27]),
      .BL_DIN_28_       (fcb_bl_din[28]),
      .BL_DIN_29_       (fcb_bl_din[29]),
      .BL_DIN_2_        (fcb_bl_din[2]),
      .BL_DIN_30_       (fcb_bl_din[30]),
      .BL_DIN_31_       (fcb_bl_din[31]),
      .BL_DIN_3_        (fcb_bl_din[3]),
      .BL_DIN_4_        (fcb_bl_din[4]),
      .BL_DIN_5_        (fcb_bl_din[5]),
      .BL_DIN_6_        (fcb_bl_din[6]),
      .BL_DIN_7_        (fcb_bl_din[7]),
      .BL_DIN_8_        (fcb_bl_din[8]),
      .BL_DIN_9_        (fcb_bl_din[9]),
      .BL_PWRGATE_0_    (fcb_bl_pwrgate[0]),
      .BL_PWRGATE_1_    (fcb_bl_pwrgate[1]),
      .BL_PWRGATE_2_    (fcb_bl_pwrgate[2]),
      .BL_PWRGATE_3_    (fcb_bl_pwrgate[3]),
      .CLOAD_DIN_SEL    (fcb_cload_din_sel),
      .DIN_INT_L_ONLY   (fcb_din_int_l_only),
      .DIN_INT_R_ONLY   (fcb_din_int_r_only),
      .DIN_SLC_TB_INT   (fcb_din_slc_tb_int),
      .FB_CFG_DONE      (fcb_fb_cfg_done),
      .FB_ISO_ENB       (fcb_fb_iso_enb),
      .FB_SPE_IN_0_     (FB_SPE_IN_0_),
      .FB_SPE_IN_1_     (FB_SPE_IN_1_),
      .FB_SPE_IN_2_     (FB_SPE_IN_2_),
      .FB_SPE_IN_3_     (FB_SPE_IN_3_),
      .ISO_EN_0_        (fcb_iso_en[0]),
      .ISO_EN_1_        (fcb_iso_en[1]),
      .ISO_EN_2_        (fcb_iso_en[2]),
      .ISO_EN_3_        (fcb_iso_en[3]),
      .MLATCH           (MLATCH),
      .M_1_             (M_1_),
      .M_2_             (M_2_),
      .M_3_             (M_3_),
      .M_4_             (M_4_),
      .M_5_             (M_5_),
      .NB               (),
      .PB               (),
      .PCHG_B           (fcb_pchg_b),
      .PI_PWR_0_        (fcb_pi_pwr[0]),
      .PI_PWR_1_        (fcb_pi_pwr[1]),
      .PI_PWR_2_        (fcb_pi_pwr[2]),
      .PI_PWR_3_        (fcb_pi_pwr[3]),
      .POR              (POR),
      .PROG_0_          (fcb_prog[0]),
      .PROG_1_          (fcb_prog[1]),
      .PROG_2_          (fcb_prog[2]),
      .PROG_3_          (fcb_prog[3]),
      .PROG_IFX         (fcb_prog_ifx),
      .PWR_GATE         (fcb_pwr_gate),
      .RE               (fcb_re),
      .STM              (STM),
      .VLP_CLKDIS_0_    (fcb_vlp_clkdis[0]),
      .VLP_CLKDIS_1_    (fcb_vlp_clkdis[1]),
      .VLP_CLKDIS_2_    (fcb_vlp_clkdis[2]),
      .VLP_CLKDIS_3_    (fcb_vlp_clkdis[3]),
      .VLP_CLKDIS_IFX   (fcb_vlp_clkdis_ifx),
      .VLP_PWRDIS_0_    (fcb_vlp_pwrdis[0]),
      .VLP_PWRDIS_1_    (fcb_vlp_pwrdis[1]),
      .VLP_PWRDIS_2_    (fcb_vlp_pwrdis[2]),
      .VLP_PWRDIS_3_    (fcb_vlp_pwrdis[3]),
      .VLP_PWRDIS_IFX   (fcb_vlp_pwrdis_ifx),
      .VLP_SRDIS_0_     (fcb_vlp_srdis[0]),
      .VLP_SRDIS_1_     (fcb_vlp_srdis[1]),
      .VLP_SRDIS_2_     (fcb_vlp_srdis[2]),
      .VLP_SRDIS_3_     (fcb_vlp_srdis[3]),
      .VLP_SRDIS_IFX    (fcb_vlp_srdis_ifx),
      .WE               (fcb_we),
      .WE_INT           (fcb_we_int),
      .WL_CLK           (fcb_wlclk),
      .WL_CLOAD_SEL_0_  (fcb_wl_cload_sel[0]),
      .WL_CLOAD_SEL_1_  (fcb_wl_cload_sel[1]),
      .WL_CLOAD_SEL_2_  (fcb_wl_cload_sel[2]),
      .WL_DIN_0_        (fcb_wl_din[0]),
      .WL_DIN_1_        (fcb_wl_din[1]),
      .WL_DIN_2_        (fcb_wl_din[2]),
      .WL_DIN_3_        (fcb_wl_din[3]),
      .WL_DIN_4_        (fcb_wl_din[4]),
      .WL_DIN_5_        (fcb_wl_din[5]),
      .WL_EN            (fcb_wl_en),
      .WL_INT_DIN_SEL   (fcb_wl_int_din_sel),
      .WL_PWRGATE_0_    (fcb_wl_pwrgate[0]),
      .WL_PWRGATE_1_    (fcb_wl_pwrgate[1]),
      .WL_RESETB        (fcb_wl_resetb),
      .WL_SEL_0_        (fcb_wl_sel[0]),
      .WL_SEL_1_        (fcb_wl_sel[1]),
      .WL_SEL_2_        (fcb_wl_sel[2]),
      .WL_SEL_3_        (fcb_wl_sel[3]),
      .WL_SEL_TB_INT    (fcb_wl_sel_tb_int),
      `include "math_block_connection.vh"
      .gpio_data_41_i   ( 1'b0            ),
      .gpio_data_41_o   (                 ),
      .gpio_oe_41_o     (                 ),
      .gpio_data_42_i   ( 1'b0            ),
      .gpio_data_42_o   (                 ),
      .gpio_oe_42_o     (                 ),
      
      .apb_hwce_pstrb_i ( 1'b0            ),    // ToDo: This is a hack to eliminate error, need to determine how to correctly set this signal
      .*
      );
  `endif
`endif
`endif
`endif
fcb U_fcb(
    // Outputs
    .fcb_cfg_done        (fcb_cfg_done),
    .fcb_cfg_done_en     (fcb_cfg_done_en),
    .fcb_spim_mosi       (fcb_spim_mosi),
    .fcb_spim_mosi_en    (fcb_spim_mosi_en),
    .fcb_spim_cs_n       (fcb_spim_cs_n),
    .fcb_spim_cs_n_en    (fcb_spim_cs_n_en),
    .fcb_spim_ckout      (fcb_spim_ckout),
    .fcb_spim_ckout_en   (fcb_spim_ckout_en),
    .fcb_spis_miso       (fcb_spis_miso),
    .fcb_spis_miso_en    (fcb_spis_miso_en),
    .fcb_pif_vldo        (fcb_pif_vldo),
    .fcb_pif_vldo_en     (fcb_pif_vldo_en),
    .fcb_pif_do_l        (fcb_pif_do_l[3:0]),
    .fcb_pif_do_l_en     (fcb_pif_do_l_en),
    .fcb_pif_do_h        (fcb_pif_do_h[3:0]),
    .fcb_pif_do_h_en     (fcb_pif_do_h_en),
    .fcb_apbs_pready     (fcb_apbs_pready),
    .fcb_apbs_prdata     (fcb_apbs_prdata[31:0]),
    .fcb_apbs_pslverr    (fcb_apbs_pslverr),
    .fcb_blclk           (fcb_blclk),
    .fcb_re              (fcb_re),
    .fcb_we              (fcb_we),
    .fcb_we_int          (fcb_we_int),
    .fcb_pchg_b          (fcb_pchg_b),
    .fcb_bl_din          (fcb_bl_din[31:0]),
    .fcb_cload_din_sel   (fcb_cload_din_sel),
    .fcb_din_slc_tb_int  (fcb_din_slc_tb_int),
    .fcb_din_int_l_only  (fcb_din_int_l_only),
    .fcb_din_int_r_only  (fcb_din_int_r_only),
    .fcb_bl_pwrgate      (fcb_bl_pwrgate[15:0]),
    .fcb_wlclk           (fcb_wlclk),
    .fcb_wl_resetb       (fcb_wl_resetb),
    .fcb_wl_en           (fcb_wl_en),
    .fcb_wl_sel          (fcb_wl_sel[15:0]),
    .fcb_wl_cload_sel    (fcb_wl_cload_sel[2:0]),
    .fcb_wl_pwrgate      (fcb_wl_pwrgate[7:0]),
    .fcb_wl_din          (fcb_wl_din[5:0]),
    .fcb_wl_int_din_sel  (fcb_wl_int_din_sel),
    .fcb_prog            (fcb_prog[15:0]),
    .fcb_prog_ifx        (fcb_prog_ifx),
    .fcb_wl_sel_tb_int   (fcb_wl_sel_tb_int),
    .fcb_iso_en          (fcb_iso_en[15:0]),
    .fcb_pi_pwr          (fcb_pi_pwr[15:0]),
    .fcb_vlp_clkdis      (fcb_vlp_clkdis[15:0]),
    .fcb_vlp_clkdis_ifx  (fcb_vlp_clkdis_ifx),
    .fcb_vlp_srdis       (fcb_vlp_srdis[15:0]),
    .fcb_vlp_srdis_ifx   (fcb_vlp_srdis_ifx),
    .fcb_vlp_pwrdis      (fcb_vlp_pwrdis[15:0]),
    .fcb_vlp_pwrdis_ifx  (fcb_vlp_pwrdis_ifx),
    .fcb_apbm_paddr      (fcb_apbm_paddr[11:0]),
    .fcb_apbm_psel       (fcb_apbm_psel[7:0]),
    .fcb_apbm_penable    (fcb_apbm_penable),
    .fcb_apbm_pwrite     (fcb_apbm_pwrite),
    .fcb_apbm_pwdata     (fcb_apbm_pwdata[17:0]),
    .fcb_apbm_ramfifo_sel(fcb_apbm_ramfifo_sel),
    .fcb_apbm_mclk       (fcb_apbm_mclk),
    .fcb_rst             (fcb_rst),
    .fcb_sysclk_en       (fcb_sysclk_en),
    .fcb_fb_cfg_done     (fcb_fb_cfg_done),
    .fcb_clp_cfg_done_n  (fcb_clp_cfg_done_n),
    .fcb_clp_cfg_enb     (fcb_clp_cfg_enb),
    .fcb_clp_lth_enb     (fcb_clp_lth_enb),
    .fcb_clp_pwr_gate    (fcb_clp_pwr_gate),
    .fcb_clp_vlp         (fcb_clp_vlp),
    .fcb_fb_iso_enb      (fcb_fb_iso_enb),
    .fcb_pwr_gate        (fcb_pwr_gate),
    .fcb_set_por         (fcb_set_por),
    .fcb_clp_set_por     (fcb_clp_set_por),
    .fcb_spi_master_status(fcb_spi_master_status),
    // Inputs
    .fcb_sys_clk         (fcb_sys_clk),
    .fcb_sys_rst_n       (fcb_sys_rst_n),
    .fcb_spis_clk        (fcb_spis_clk),
    .fcb_spis_rst_n      (fcb_spis_rst_n),
    .fcb_sys_stm         (fcb_sys_stm),
    .fcb_spim_miso       (fcb_spim_miso),
    .fcb_spim_ckout_in   (fcb_spim_ckout_in),
    .fcb_spis_mosi       (fcb_spis_mosi),
    .fcb_spis_cs_n       (fcb_spis_cs_n),
    .fcb_pif_vldi        (fcb_pif_vldi),
    .fcb_pif_di_l        (fcb_pif_di_l[3:0]),
    .fcb_pif_di_h        (fcb_pif_di_h[3:0]),
    .fcb_spi_mode_en_bo  (fcb_spi_mode_en_bo),
    .fcb_pif_en          (fcb_pif_en),
    .fcb_pif_8b_mode_bo  (fcb_pif_8b_mode_bo),
    .fcb_apbs_paddr      (fcb_apbs_paddr[19:0]),
    .fcb_apbs_pprot      (fcb_apbs_pprot[2:0]),
    .fcb_apbs_psel       (fcb_apbs_psel),
    .fcb_apbs_penable    (fcb_apbs_penable),
    .fcb_apbs_pwrite     (fcb_apbs_pwrite),
    .fcb_apbs_pwdata     (fcb_apbs_pwdata[31:0]),
    .fcb_apbs_pstrb      (fcb_apbs_pstrb[3:0]),
    .fcb_bl_dout         (fcb_bl_dout[31:0]),
    .fcb_apbm_prdata_0   (fcb_apbm_prdata_0[17:0]),
    .fcb_apbm_prdata_1   (fcb_apbm_prdata_1[17:0]),
    .fcb_spi_master_en   (fcb_spi_master_en)
);
//}}}


MATH_UNIT U0_MATH_UNIT(
//{{{
                       // Outputs
                       //vincent@20181115.MATHB_EFPGA_MAC_OUT(MU0_MATHB_EFPGA_MAC_OUT[31:0]),
                       .FMATHB_EFPGA_MAC_OUT(MU0_MATHB_EFPGA_MAC_OUT[31:0]),
                       .TPRAM_EFPGA_OPER_R_DATA(MU0_TPRAM_EFPGA_OPER_R_DATA[31:0]),
                       .TPRAM_EFPGA_COEF_R_DATA(MU0_TPRAM_EFPGA_COEF_R_DATA[31:0]),
                       // Inputs
                       .EFPGA2MATHB_CLK (MU0_EFPGA2MATHB_CLK),
                       .EFPGA_MATHB_CLK_EN(MU0_EFPGA_MATHB_CLK_EN),
                       .EFPGA_MATHB_OPER_DATA(MU0_EFPGA_MATHB_OPER_DATA[31:0]),
                       .EFPGA_MATHB_OPER_SEL(MU0_EFPGA_MATHB_OPER_SEL),
                       .EFPGA_MATHB_OPER_defPin(MU0_EFPGA_MATHB_OPER_defPin[1:0]),
                       .EFPGA_MATHB_COEF_DATA(MU0_EFPGA_MATHB_COEF_DATA[31:0]),
                       .EFPGA_MATHB_COEF_SEL(MU0_EFPGA_MATHB_COEF_SEL),
                       .EFPGA_MATHB_COEF_defPin(MU0_EFPGA_MATHB_COEF_defPin[1:0]),
                       .EFPGA_MATHB_DATAOUT_SEL(MU0_EFPGA_MATHB_DATAOUT_SEL[1:0]),
                       .EFPGA_MATHB_MAC_ACC_CLEAR(MU0_EFPGA_MATHB_MAC_ACC_CLEAR),
                       .EFPGA_MATHB_MAC_ACC_RND(MU0_EFPGA_MATHB_MAC_ACC_RND),
                       .EFPGA_MATHB_MAC_ACC_SAT(MU0_EFPGA_MATHB_MAC_ACC_SAT),
                       .EFPGA_MATHB_MAC_OUT_SEL(MU0_EFPGA_MATHB_MAC_OUT_SEL[5:0]),
                       .EFPGA_MATHB_TC_defPin(MU0_EFPGA_MATHB_TC_defPin),
                       .EFPGA_TPRAM_OPER_POWERDN(MU0_EFPGA_TPRAM_OPER_POWERDN),
                       .EFPGA_TPRAM_OPER_R_ADDR(MU0_EFPGA_TPRAM_OPER_R_ADDR[11:0]),
                       .EFPGA_TPRAM_OPER_R_CLK(MU0_EFPGA_TPRAM_OPER_R_CLK),
                       .EFPGA_TPRAM_OPER_R_MODE(MU0_EFPGA_TPRAM_OPER_R_MODE[1:0]),
                       .EFPGA_TPRAM_OPER_WDSEL(MU0_EFPGA_TPRAM_OPER_WDSEL),
                       .EFPGA_TPRAM_OPER_WE(MU0_EFPGA_TPRAM_OPER_WE),
                       .EFPGA_TPRAM_OPER_W_ADDR(MU0_EFPGA_TPRAM_OPER_W_ADDR[11:0]),
                       .EFPGA_TPRAM_OPER_W_CLK(MU0_EFPGA_TPRAM_OPER_W_CLK),
                       .EFPGA_TPRAM_OPER_W_DATA(MU0_EFPGA_TPRAM_OPER_W_DATA[31:0]),
                       .EFPGA_TPRAM_OPER_W_MODE(MU0_EFPGA_TPRAM_OPER_W_MODE[1:0]),
                       .EFPGA_TPRAM_COEF_POWERDN(MU0_EFPGA_TPRAM_COEF_POWERDN),
                       .EFPGA_TPRAM_COEF_R_ADDR(MU0_EFPGA_TPRAM_COEF_R_ADDR[11:0]),
                       .EFPGA_TPRAM_COEF_R_CLK(MU0_EFPGA_TPRAM_COEF_R_CLK),
                       .EFPGA_TPRAM_COEF_R_MODE(MU0_EFPGA_TPRAM_COEF_R_MODE[1:0]),
                       .EFPGA_TPRAM_COEF_WDSEL(MU0_EFPGA_TPRAM_COEF_WDSEL),
                       .EFPGA_TPRAM_COEF_WE(MU0_EFPGA_TPRAM_COEF_WE),
                       .EFPGA_TPRAM_COEF_W_ADDR(MU0_EFPGA_TPRAM_COEF_W_ADDR[11:0]),
                       .EFPGA_TPRAM_COEF_W_CLK(MU0_EFPGA_TPRAM_COEF_W_CLK),
                       .EFPGA_TPRAM_COEF_W_DATA(MU0_EFPGA_TPRAM_COEF_W_DATA[31:0]),
                       .EFPGA_TPRAM_COEF_W_MODE(MU0_EFPGA_TPRAM_COEF_W_MODE[1:0]));
//}}}

MATH_UNIT U1_MATH_UNIT(
//{{{
                       // Outputs
                       //vincent@20181115.MATHB_EFPGA_MAC_OUT(MU1_MATHB_EFPGA_MAC_OUT[31:0]),
                       .FMATHB_EFPGA_MAC_OUT(MU1_MATHB_EFPGA_MAC_OUT[31:0]),
                       .TPRAM_EFPGA_OPER_R_DATA(MU1_TPRAM_EFPGA_OPER_R_DATA[31:0]),
                       .TPRAM_EFPGA_COEF_R_DATA(MU1_TPRAM_EFPGA_COEF_R_DATA[31:0]),
                       // Inputs
                       .EFPGA2MATHB_CLK (MU1_EFPGA2MATHB_CLK),
                       .EFPGA_MATHB_CLK_EN(MU1_EFPGA_MATHB_CLK_EN),
                       .EFPGA_MATHB_OPER_DATA(MU1_EFPGA_MATHB_OPER_DATA[31:0]),
                       .EFPGA_MATHB_OPER_SEL(MU1_EFPGA_MATHB_OPER_SEL),
                       .EFPGA_MATHB_OPER_defPin(MU1_EFPGA_MATHB_OPER_defPin[1:0]),
                       .EFPGA_MATHB_COEF_DATA(MU1_EFPGA_MATHB_COEF_DATA[31:0]),
                       .EFPGA_MATHB_COEF_SEL(MU1_EFPGA_MATHB_COEF_SEL),
                       .EFPGA_MATHB_COEF_defPin(MU1_EFPGA_MATHB_COEF_defPin[1:0]),
                       .EFPGA_MATHB_DATAOUT_SEL(MU1_EFPGA_MATHB_DATAOUT_SEL[1:0]),
                       .EFPGA_MATHB_MAC_ACC_CLEAR(MU1_EFPGA_MATHB_MAC_ACC_CLEAR),
                       .EFPGA_MATHB_MAC_ACC_RND(MU1_EFPGA_MATHB_MAC_ACC_RND),
                       .EFPGA_MATHB_MAC_ACC_SAT(MU1_EFPGA_MATHB_MAC_ACC_SAT),
                       .EFPGA_MATHB_MAC_OUT_SEL(MU1_EFPGA_MATHB_MAC_OUT_SEL[5:0]),
                       .EFPGA_MATHB_TC_defPin(MU1_EFPGA_MATHB_TC_defPin),
                       .EFPGA_TPRAM_OPER_POWERDN(MU1_EFPGA_TPRAM_OPER_POWERDN),
                       .EFPGA_TPRAM_OPER_R_ADDR(MU1_EFPGA_TPRAM_OPER_R_ADDR[11:0]),
                       .EFPGA_TPRAM_OPER_R_CLK(MU1_EFPGA_TPRAM_OPER_R_CLK),
                       .EFPGA_TPRAM_OPER_R_MODE(MU1_EFPGA_TPRAM_OPER_R_MODE[1:0]),
                       .EFPGA_TPRAM_OPER_WDSEL(MU1_EFPGA_TPRAM_OPER_WDSEL),
                       .EFPGA_TPRAM_OPER_WE(MU1_EFPGA_TPRAM_OPER_WE),
                       .EFPGA_TPRAM_OPER_W_ADDR(MU1_EFPGA_TPRAM_OPER_W_ADDR[11:0]),
                       .EFPGA_TPRAM_OPER_W_CLK(MU1_EFPGA_TPRAM_OPER_W_CLK),
                       .EFPGA_TPRAM_OPER_W_DATA(MU1_EFPGA_TPRAM_OPER_W_DATA[31:0]),
                       .EFPGA_TPRAM_OPER_W_MODE(MU1_EFPGA_TPRAM_OPER_W_MODE[1:0]),
                       .EFPGA_TPRAM_COEF_POWERDN(MU1_EFPGA_TPRAM_COEF_POWERDN),
                       .EFPGA_TPRAM_COEF_R_ADDR(MU1_EFPGA_TPRAM_COEF_R_ADDR[11:0]),
                       .EFPGA_TPRAM_COEF_R_CLK(MU1_EFPGA_TPRAM_COEF_R_CLK),
                       .EFPGA_TPRAM_COEF_R_MODE(MU1_EFPGA_TPRAM_COEF_R_MODE[1:0]),
                       .EFPGA_TPRAM_COEF_WDSEL(MU1_EFPGA_TPRAM_COEF_WDSEL),
                       .EFPGA_TPRAM_COEF_WE(MU1_EFPGA_TPRAM_COEF_WE),
                       .EFPGA_TPRAM_COEF_W_ADDR(MU1_EFPGA_TPRAM_COEF_W_ADDR[11:0]),
                       .EFPGA_TPRAM_COEF_W_CLK(MU1_EFPGA_TPRAM_COEF_W_CLK),
                       .EFPGA_TPRAM_COEF_W_DATA(MU1_EFPGA_TPRAM_COEF_W_DATA[31:0]),
                       .EFPGA_TPRAM_COEF_W_MODE(MU1_EFPGA_TPRAM_COEF_W_MODE[1:0]));

endmodule

