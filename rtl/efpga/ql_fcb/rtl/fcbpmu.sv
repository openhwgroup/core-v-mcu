// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1


module fcbpmu #(
    parameter [5:0] PAR_QLFCB_6BIT_125NS = 6'h0d,  // Default Assume 100MHz
    parameter [5:0] PAR_QLFCB_6BIT_250NS = 6'h19  // Default Assume 100MHz
) (
    //------------------------------------------------------------------------//
    //-- INPUT PORT                                                         --//
    //------------------------------------------------------------------------//
    input logic fcb_sys_clk,  //Main Clock for FCB except SPI Slave Int
    input logic fcb_sys_rst_n,  //Main Reset for FCB except SPI Slave int
    //input logic [7:0]             frfu_fpmu_quad_pd_en_b0 ,       //
    //input logic [7:0]             frfu_fpmu_quad_pd_en_b1 ,       //
    //input logic [1:0]             frfu_fpmu_quad_pd_mode ,     	//
    //input logic [7:0]             frfu_fpmu_quad_wu_en_b0 ,       //
    //input logic [7:0]             frfu_fpmu_quad_wu_en_b1 ,       //
    //input logic [1:0]             frfu_fpmu_quad_wu_mode ,     	//
    //input logic                   frfu_fpmu_prog_pmu_chip_wu_en ,  //	XXX
    //input logic                   frfu_fpmu_pmu_chip_vlp_wu_en ,  //
    //input logic                   frfu_fpmu_prog_pmu_chip_vlp_en ,     //
    //input logic                   frfu_fpmu_pmu_chip_vlp_en ,     //	XXX
    input logic [7:0] frfu_fpmu_iso_en_sd_0,  //
    input logic [7:0] frfu_fpmu_iso_en_sd_1,  //
    input logic [7:0] frfu_fpmu_pi_pwr_sd_0,  //
    input logic [7:0] frfu_fpmu_pi_pwr_sd_1,  //
    //input logic [7:0]             frfu_fpmu_vlp_sd_0 ,    	//
    //input logic [7:0]             frfu_fpmu_vlp_sd_1 ,    	//
    input logic [7:0] frfu_fpmu_vlp_clkdis_sd_0,  //
    input logic [7:0] frfu_fpmu_vlp_clkdis_sd_1,  //
    input logic [7:0] frfu_fpmu_vlp_srdis_sd_0,  //
    input logic [7:0] frfu_fpmu_vlp_srdis_sd_1,  //
    input logic [7:0] frfu_fpmu_vlp_pwrdis_sd_0,  //
    input logic [7:0] frfu_fpmu_vlp_pwrdis_sd_1,  //
    input logic frfu_fpmu_vlp_clkdis_ifx_sd,  //
    input logic frfu_fpmu_vlp_srdis_ifx_sd,  //
    input logic frfu_fpmu_vlp_pwrdis_ifx_sd,  //
    input logic frfu_fpmu_pmu_mux_sel_sd,  //
    input logic [7:0] frfu_fpmu_pmu_timer_ccnt,  //
    input logic [5:0] frfu_fpmu_pmu_pwr_gate_ccnt,  //
    input logic fcb_clp_mode_en_bo,  //
    //input logic                   frfu_fpmu_pmu_chip_pd_en ,      	//JC
    //input logic                   frfu_fpmu_prog_pmu_chip_pd_en ,         //Pulse JC
    //input logic                   frfu_fpmu_prog_pmu_quad_pd_en ,	// JC
    //input logic                   frfu_fpmu_prog_pmu_quad_wu_en , // JC
    input logic frfu_fpmu_prog_cfg_done,  // JC
    input logic frfu_fpmu_clr_cfg_done,  // JC
    input logic [7:0] frfu_fpmu_quad_cfg_b0,  //
    input logic [7:0] frfu_fpmu_quad_cfg_b1,  //
    input logic [3:0] frfu_fpmu_pmu_chip_cmd,  //
    input logic frfu_fpmu_prog_pmu_chip_cmd,  //
    input logic [1:0] frfu_fpmu_pmu_time_ctl,  // JC
    input logic frfu_fpmu_fb_cfg_done,  // JC
    input logic frfu_fpmu_fb_iso_enb_sd,
    input logic frfu_fpmu_pwr_gate_sd,
    input logic frfu_fpmu_prog_ifx_sd,
    input logic frfu_fpmu_set_por_sd,
    input logic [7:0] frfu_fpmu_prog_sd_0,
    input logic [7:0] frfu_fpmu_prog_sd_1,
    input logic fcb_fb_default_on_bo,  //eFPGA Macro Default Power State
    //------------------------------------------------------------------------//
    //-- OUTPUT PORT                                                        --//
    //------------------------------------------------------------------------//
    output logic fpmu_frfu_clr_pmu_chip_cmd,  //JC X
    output logic fpmu_frfu_clr_quads,  //JC X
    output logic [15:0] fcb_iso_en,  //Fabric ISO Enable, 0x1->Isolation Enabl
    output logic [15:0] fcb_pi_pwr,  //Fabric Power Down Enable, 0x1->Power ON
    output logic [15:0] fcb_vlp_clkdis,  //Fabric Clock Function Disable Signal fo
    output logic fcb_vlp_clkdis_ifx,  //Fabric Clock Function Disable signal fo
    output logic [15:0] fcb_vlp_srdis,  //Fabric Set/Reset Function Disable Signa
    output logic fcb_vlp_srdis_ifx,  //Fabric Set/Reset Function Disable signa
    output logic [15:0] fcb_vlp_pwrdis,  //Fabric VLP Power Down signals for Quads
    output logic fcb_vlp_pwrdis_ifx,  //Fabric VLP Power Down signals for Inter
    output logic fcb_set_por,  //JC this signal need to be handle outside by customer's logic
    output logic fcb_fb_iso_enb,  //JC
    output logic fcb_pwr_gate,  //JC
    output logic fcb_prog_ifx,  //JC
    output logic [15:0] fcb_prog,  //JC X
    output logic fpmu_frfu_clr_cfg_done,  //JC X
    //output logic			fpmu_frfu_clr_pmu_chip_pd_en,   //JC X
    //output logic [7:0]            fpmu_frfu_clr_quad_pd_en_b0 ,   //Clear Quad PD Enable, bit 0->Quad00, Bi
    //output logic [7:0]            fpmu_frfu_clr_quad_pd_en_b1 ,   //Clear Quad PD Enable, bit 0->Quad20, Bi
    //output logic                  fpmu_frfu_clr_quad_pd_wr_en_b0 ,   //Clear Enable, Once Asserted, the corres
    //output logic                  fpmu_frfu_clr_quad_pd_wr_en_b1 ,   //Clear Enable, Once Asserted, the corres
    //output logic [7:0]            fpmu_frfu_clr_quad_wu_en_b0 ,   //Clear Quad Wake Up Enable, bit 0->Quad0
    //output logic [7:0]            fpmu_frfu_clr_quad_wu_en_b1 ,   //Clear Quad Wake Up Enable, bit 0->Quad2
    //output logic                  fpmu_frfu_clr_quad_wu_wr_en_b0 ,   //Clear Enable, Once Asserted, the corres
    //output logic                  fpmu_frfu_clr_quad_wu_wr_en_b1 ,   //Clear Enable, Once Asserted, the corres
    output logic [1:0] fpmu_frfu_pw_sta_00,  //
    output logic [1:0] fpmu_frfu_pw_sta_01,  //
    output logic [1:0] fpmu_frfu_pw_sta_02,  //
    output logic [1:0] fpmu_frfu_pw_sta_03,  //
    output logic [1:0] fpmu_frfu_pw_sta_10,  //
    output logic [1:0] fpmu_frfu_pw_sta_11,  //
    output logic [1:0] fpmu_frfu_pw_sta_12,  //
    output logic [1:0] fpmu_frfu_pw_sta_13,  //
    output logic [1:0] fpmu_frfu_pw_sta_20,  //
    output logic [1:0] fpmu_frfu_pw_sta_21,  //
    output logic [1:0] fpmu_frfu_pw_sta_22,  //
    output logic [1:0] fpmu_frfu_pw_sta_23,  //
    output logic [1:0] fpmu_frfu_pw_sta_30,  //
    output logic [1:0] fpmu_frfu_pw_sta_31,  //
    output logic [1:0] fpmu_frfu_pw_sta_32,  //
    output logic [1:0] fpmu_frfu_pw_sta_33,  //
    output logic [1:0] fpmu_frfu_chip_pw_sta,  //	// JC 05232017
    //output logic                  fpmu_frfu_clr_pmu_chip_wu_en ,  //Clear Whole Chip WakeUp Enable
    //output logic                  fpmu_frfu_clr_pmu_chip_vlp_en , //Clear Whole Chip VLP Enable
    output logic fpmu_frfu_pmu_busy,
    output logic fpmu_frfu_fb_cfg_cleanup,
    output logic fpmu_pmu_busy  //Indicate the PMU is Busy
);


  //------------------------------------------------------------------------//
  //-- Local Parameter                                                    --//
  //------------------------------------------------------------------------//
  localparam PAR_DLY = 1'b1;
  localparam PAR_PMU_CMD_IDLE = 4'h0;
  localparam PAR_PMU_CMD_CLPD = 4'h4;
  localparam PAR_PMU_CMD_CLVLP = 4'h5;
  localparam PAR_PMU_CMD_CLWU0 = 4'h6;
  localparam PAR_PMU_CMD_CLWU1 = 4'h7;
  localparam PAR_PMU_CMD_QLPD = 4'h8;
  localparam PAR_PMU_CMD_QLVLP = 4'h9;
  localparam PAR_PMU_CMD_QLVLPWU = 4'hA;
  localparam PAR_PMU_CMD_QLPDWU = 4'hB;

  typedef enum logic [7:0] {
    MAIN_S00 = 8'h00,
    MAIN_S01 = 8'h01,
    MAIN_S02 = 8'h02,
    MAIN_S03 = 8'h03,
    MAIN_S04 = 8'h04,
    MAIN_S05 = 8'h05,
    MAIN_S06 = 8'h06,
    MAIN_S07 = 8'h07,

    MAIN_S08 = 8'h08,
    MAIN_S09 = 8'h09,
    MAIN_S0A = 8'h0A,
    MAIN_S0B = 8'h0B,
    MAIN_S0C = 8'h0C,
    MAIN_S0D = 8'h0D,
    MAIN_S0E = 8'h0E,
    MAIN_S0F = 8'h0F,

    MAIN_S10 = 8'h10,
    MAIN_S11 = 8'h11,
    MAIN_S12 = 8'h12,
    MAIN_S13 = 8'h13,
    MAIN_S14 = 8'h14,
    MAIN_S15 = 8'h15,
    MAIN_S16 = 8'h16,
    MAIN_S17 = 8'h17,

    MAIN_S18 = 8'h18,
    MAIN_S19 = 8'h19,
    MAIN_S1A = 8'h1A,
    MAIN_S1B = 8'h1B,
    MAIN_S1C = 8'h1C,
    MAIN_S1D = 8'h1D,
    MAIN_S1E = 8'h1E,
    MAIN_S1F = 8'h1F,

    MAIN_S20 = 8'h20,
    MAIN_S21 = 8'h21,
    MAIN_S22 = 8'h22,
    MAIN_S23 = 8'h23,
    MAIN_S24 = 8'h24,
    MAIN_S25 = 8'h25,
    MAIN_S26 = 8'h26,
    MAIN_S27 = 8'h27,

    MAIN_S28 = 8'h28,
    MAIN_S29 = 8'h29,
    MAIN_S2A = 8'h2A,
    MAIN_S2B = 8'h2B,
    MAIN_S2C = 8'h2C,
    MAIN_S2D = 8'h2D,
    MAIN_S2E = 8'h2E,
    MAIN_S2F = 8'h2F,

    MAIN_S30 = 8'h90,
    MAIN_S31 = 8'h91,
    MAIN_S32 = 8'h92,
    MAIN_S33 = 8'h93,
    MAIN_S34 = 8'h94,
    MAIN_S35 = 8'h95,
    MAIN_S36 = 8'h96,
    MAIN_S37 = 8'h97,

    MAIN_S38 = 8'h98,
    MAIN_S39 = 8'h99,
    MAIN_S3A = 8'h9A,
    MAIN_S3B = 8'h9B,
    MAIN_S3C = 8'h9C,
    MAIN_S3D = 8'h9D,
    MAIN_S3E = 8'h9E,
    MAIN_S3F = 8'h9F,


    MAIN_S40 = 8'hA0,
    MAIN_S41 = 8'hA1,
    MAIN_S42 = 8'hA2,
    MAIN_S43 = 8'hA3,
    MAIN_S44 = 8'hA4,
    MAIN_S45 = 8'hA5,
    MAIN_S46 = 8'hA6,
    MAIN_S47 = 8'hA7,

    MAIN_S48 = 8'hA8,
    MAIN_S49 = 8'hA9,
    MAIN_S4A = 8'hAA,
    MAIN_S4B = 8'hAB,
    MAIN_S4C = 8'hAC,
    MAIN_S4D = 8'hAD,
    MAIN_S4E = 8'hAE,
    MAIN_S4F = 8'hAF,

    MAIN_S50 = 8'hB0,
    MAIN_S51 = 8'hB1,
    MAIN_S52 = 8'hB2,
    MAIN_S53 = 8'hB3,
    MAIN_S54 = 8'hB4,
    MAIN_S55 = 8'hB5,
    MAIN_S56 = 8'hB6,
    MAIN_S57 = 8'hB7,

    MAIN_S58 = 8'hB8,
    MAIN_S59 = 8'hB9,
    MAIN_S5A = 8'hBA,
    MAIN_S5B = 8'hBB,
    MAIN_S5C = 8'hBC,
    MAIN_S5D = 8'hBD,
    MAIN_S5E = 8'hBE,
    MAIN_S5F = 8'hBF,

    MAIN_S60 = 8'hC0,
    MAIN_S61 = 8'hC1,
    MAIN_S62 = 8'hC2,
    MAIN_S63 = 8'hC3,
    MAIN_S64 = 8'hC4,
    MAIN_S65 = 8'hC5,
    MAIN_S66 = 8'hC6,
    MAIN_S67 = 8'hC7,

    MAIN_S68 = 8'hC8,
    MAIN_S69 = 8'hC9,
    MAIN_S6A = 8'hCA,
    MAIN_S6B = 8'hCB,
    MAIN_S6C = 8'hCC,
    MAIN_S6D = 8'hCD,
    MAIN_S6E = 8'hCE,
    MAIN_S6F = 8'hCF,

    PWRD_S00 = 8'h30,
    PWRD_S01 = 8'h31,
    PWRD_S02 = 8'h32,
    PWRD_S03 = 8'h33,
    PWRD_S04 = 8'h34,
    PWRD_S05 = 8'h35,
    PWRD_S06 = 8'h36,
    PWRD_S07 = 8'h37,
    PWRD_S08 = 8'h38,
    PWRD_S09 = 8'h39,
    PWRD_S0A = 8'h3A,
    PWRD_S0B = 8'h3B,
    PWRD_S0C = 8'h3C,
    PWRD_S0D = 8'h3D,
    PWRD_S0E = 8'h3E,
    PWRD_S0F = 8'h3F,
    PWRD_S10 = 8'h40,
    PWRD_S11 = 8'h41,
    PWRD_S12 = 8'h42,
    PWRD_S13 = 8'h43,
    PWRD_S14 = 8'h44,
    PWRD_S15 = 8'h45,
    PWRD_S16 = 8'h46,
    PWRD_S17 = 8'h47,
    PWRD_S18 = 8'h48,
    PWRD_S19 = 8'h49,
    PWRD_S1A = 8'h4A,
    PWRD_S1B = 8'h4B,
    PWRD_S1C = 8'h4C,
    PWRD_S1D = 8'h4D,
    PWRD_S1E = 8'h4E,
    PWRD_S1F = 8'h4F,

    PWRU_S00 = 8'h50,
    PWRU_S01 = 8'h51,
    PWRU_S02 = 8'h52,
    PWRU_S03 = 8'h53,
    PWRU_S04 = 8'h54,
    PWRU_S05 = 8'h55,
    PWRU_S06 = 8'h56,
    PWRU_S07 = 8'h57,
    PWRU_S08 = 8'h58,
    PWRU_S09 = 8'h59,
    PWRU_S0A = 8'h5A,
    PWRU_S0B = 8'h5B,
    PWRU_S0C = 8'h5C,
    PWRU_S0D = 8'h5D,
    PWRU_S0E = 8'h5E,
    PWRU_S0F = 8'h5F,
    PWRU_S10 = 8'h60,
    PWRU_S11 = 8'h61,
    PWRU_S12 = 8'h62,
    PWRU_S13 = 8'h63,
    PWRU_S14 = 8'h64,
    PWRU_S15 = 8'h65,
    PWRU_S16 = 8'h66,
    PWRU_S17 = 8'h67,
    PWRU_S18 = 8'h68,
    PWRU_S19 = 8'h69,
    PWRU_S1A = 8'h6A,
    PWRU_S1B = 8'h6B,
    PWRU_S1C = 8'h6C,
    PWRU_S1D = 8'h6D,
    PWRU_S1E = 8'h6E,
    PWRU_S1F = 8'h6F,


    VLPE_S00 = 8'h70,
    VLPE_S01 = 8'h71,
    VLPE_S02 = 8'h72,
    VLPE_S03 = 8'h73,
    VLPE_S04 = 8'h74,
    VLPE_S05 = 8'h75,
    VLPE_S06 = 8'h76,
    VLPE_S07 = 8'h77,
    VLPE_S08 = 8'h78,
    VLPE_S09 = 8'h79,
    VLPE_S0A = 8'h7A,
    VLPE_S0B = 8'h7B,
    VLPE_S0C = 8'h7C,
    VLPE_S0D = 8'h7D,
    VLPE_S0E = 8'h7E,
    VLPE_S0F = 8'h7F,

    VLPU_S00 = 8'h80,
    VLPU_S01 = 8'h81,
    VLPU_S02 = 8'h82,
    VLPU_S03 = 8'h83,
    VLPU_S04 = 8'h84,
    VLPU_S05 = 8'h85,
    VLPU_S06 = 8'h86,
    VLPU_S07 = 8'h87,
    VLPU_S08 = 8'h88,
    VLPU_S09 = 8'h89,
    VLPU_S0A = 8'h8A,
    VLPU_S0B = 8'h8B,
    VLPU_S0C = 8'h8C,
    VLPU_S0D = 8'h8D,
    VLPU_S0E = 8'h8E,
    VLPU_S0F = 8'h8F,

    END_S00 = 8'hF0,
    END_S01 = 8'hF1,
    END_S02 = 8'hF2,
    END_S03 = 8'hF3,
    END_S04 = 8'hF4,
    END_S05 = 8'hF5,
    END_S06 = 8'hF6,
    END_S07 = 8'hF7,
    END_S08 = 8'hF8,
    END_S09 = 8'hF9,
    END_S0A = 8'hFA,
    END_S0B = 8'hFB,
    END_S0C = 8'hFC,
    END_S0D = 8'hFD,
    END_S0E = 8'hFE,
    END_S0F = 8'hFF
  } EN_STATE;

  typedef enum logic [4:0] {
    CFG_S00 = 5'h00,
    CFG_S01 = 5'h01,
    CFG_S02 = 5'h02,
    CFG_S03 = 5'h03,
    CFG_S04 = 5'h04,
    CFG_S05 = 5'h05,
    CFG_S06 = 5'h06,
    CFG_S07 = 5'h07,
    CFG_S08 = 5'h08,
    CFG_S09 = 5'h09,
    CFG_S0A = 5'h0A,
    CFG_S0B = 5'h0B,
    CFG_S0C = 5'h0C,
    CFG_S0D = 5'h0D,
    CFG_S0E = 5'h0E,
    CFG_S0F = 5'h0F,
    CFG_S10 = 5'h10,
    CFG_S11 = 5'h11,
    CFG_S12 = 5'h12,
    CFG_S13 = 5'h13,
    CFG_S14 = 5'h14,
    CFG_S15 = 5'h15,
    CFG_S16 = 5'h16,
    CFG_S17 = 5'h17,
    CFG_S18 = 5'h18,
    CFG_S19 = 5'h19,
    CFG_S1A = 5'h1A,
    CFG_S1B = 5'h1B,
    CFG_S1C = 5'h1C,
    CFG_S1D = 5'h1D,
    CFG_S1E = 5'h1E,
    CFG_S1F = 5'h1F
  } CFG_STATE;

  //------------------------------------------------------------------------//
  //-- Wire/Flops                                                         --//
  //------------------------------------------------------------------------//
  EN_STATE         pmu_stm_cs;
  EN_STATE         pmu_stm_ns;
  EN_STATE         pmu_return_stm_cs;
  EN_STATE         pmu_return_stm_ns;
  EN_STATE         pmu_return_x_stm_cs;
  EN_STATE         pmu_return_x_stm_ns;

  CFG_STATE        pmu_cfg_stm_cs;
  CFG_STATE        pmu_cfg_stm_ns;

  logic     [15:0] fcb_iso_en_cs;
  logic     [15:0] fcb_pi_pwr_cs;
  logic     [15:0] fcb_vlp_clkdis_cs;
  logic            fcb_vlp_clkdis_ifx_cs;
  logic     [15:0] fcb_vlp_srdis_cs;
  logic            fcb_vlp_srdis_ifx_cs;
  logic     [15:0] fcb_vlp_pwrdis_cs;
  logic            fcb_vlp_pwrdis_ifx_cs;
  logic            fcb_set_por_cs;
  logic            fcb_fb_iso_enb_cs;
  logic            fcb_pwr_gate_cs;
  logic            fcb_prog_ifx_cs;
  logic     [15:0] fcb_prog_cs;

  logic     [15:0] fcb_iso_en_ns;
  logic     [15:0] fcb_pi_pwr_ns;
  logic     [15:0] fcb_vlp_clkdis_ns;
  logic            fcb_vlp_clkdis_ifx_ns;
  logic     [15:0] fcb_vlp_srdis_ns;
  logic            fcb_vlp_srdis_ifx_ns;
  logic     [15:0] fcb_vlp_pwrdis_ns;
  logic            fcb_vlp_pwrdis_ifx_ns;
  logic            fcb_set_por_ns;
  logic            fcb_fb_iso_enb_ns;
  logic            fcb_pwr_gate_ns;
  logic            fcb_prog_ifx_ns;
  logic     [15:0] fcb_prog_ns;

  logic     [15:0] set_fcb_iso_en;
  logic     [15:0] set_fcb_pi_pwr;
  logic     [15:0] set_fcb_vlp_clkdis;
  logic            set_fcb_vlp_clkdis_ifx;
  logic     [15:0] set_fcb_vlp_srdis;
  logic            set_fcb_vlp_srdis_ifx;
  logic     [15:0] set_fcb_vlp_pwrdis;
  logic            set_fcb_vlp_pwrdis_ifx;
  logic            set_fcb_set_por;
  logic            set_fcb_fb_iso_enb;
  logic            set_fcb_pwr_gate;
  logic            set_fcb_prog_ifx;
  logic     [15:0] set_fcb_prog;

  logic     [15:0] clr_fcb_iso_en;
  logic     [15:0] clr_fcb_pi_pwr;
  logic     [15:0] clr_fcb_vlp_clkdis;
  logic            clr_fcb_vlp_clkdis_ifx;
  logic     [15:0] clr_fcb_vlp_srdis;
  logic            clr_fcb_vlp_srdis_ifx;
  logic     [15:0] clr_fcb_vlp_pwrdis;
  logic            clr_fcb_vlp_pwrdis_ifx;
  logic            clr_fcb_set_por;
  logic            clr_fcb_fb_iso_enb;
  logic            clr_fcb_pwr_gate;
  logic            clr_fcb_prog_ifx;
  logic     [15:0] clr_fcb_prog;

  logic            frfu_fpmu_prog_cfg_done_cs;  // JC
  logic            frfu_fpmu_prog_pmu_chip_cmd_cs;

  logic            frfu_fpmu_prog_cfg_done_ns;  // JC
  logic            frfu_fpmu_prog_pmu_chip_cmd_ns;

  logic     [15:0] quad_status_0_cs;
  logic     [15:0] quad_status_1_cs;
  logic     [15:0] quad_status_0_ns;
  logic     [15:0] quad_status_1_ns;

  logic     [15:0] set_quad_status_0;
  logic     [15:0] set_quad_status_1;
  logic     [15:0] clr_quad_status_0;
  logic     [15:0] clr_quad_status_1;

  logic     [15:0] quad_vlp_en;
  logic     [15:0] quad_pd_en;
  logic     [15:0] quad_vlp_wu;
  logic     [15:0] quad_pd_wu;
  logic     [15:0] quad_cfg;

  logic     [ 1:0] chip_pw_sta_cs;
  logic     [ 1:0] chip_pw_sta_ns;
  logic            set_vlp_chip_pw_sta;
  logic            set_pd_chip_pw_sta;
  logic            set_idle_chip_pw_sta;

  logic            kickoff_clvlp;
  logic            kickoff_clpd;
  logic            kickoff_clvlpwu;
  logic            kickoff_clpdwu;

  logic     [15:0] chip_quad_vlp_en;
  logic     [15:0] chip_quad_pd_en;
  logic     [15:0] chip_quad_vlp_wu;
  logic     [15:0] chip_quad_pd_wu;

  logic     [15:0] pmu_stm_quad_cs;
  logic     [15:0] pmu_stm_quad_ns;

  logic     [ 3:0] pmu_index_cnt_cs;
  logic     [ 3:0] pmu_index_cnt_ns;

  logic            chip_level_vlp_en_cs;
  logic            chip_level_vlp_en_ns;

  logic     [ 7:0] pmu_timer_cs;
  logic     [ 7:0] pmu_timer_ns;
  logic            pmu_timer_kickoff;
  logic     [ 7:0] pmu_timer_ini_value;
  logic            pmu_timer_timeout;

  logic     [ 7:0] timer_125ns_value;
  logic     [ 7:0] timer_250ns_value;

  logic            partial_cfg_kickoff;
  logic            full_cfg_kickoff;
  logic            full_cfg_kickoff_dly1cyc;

  logic            cfg_set_fcb_fb_iso_enb;
  logic            cfg_clr_fcb_prog_ifx;
  logic     [15:0] cfg_clr_fcb_prog;
  logic     [15:0] cfg_clr_fcb_iso_en;

  logic     [15:0] quads_at_idle_state;
  logic            cfg_timer_kickoff;
  logic     [ 7:0] cfg_timer_ini_value;

  logic            cfg_partial_mode_cs;
  logic            cfg_partial_mode_ns;

  logic            clear_cfg_kickoff;
  logic     [ 3:0] cfg_prog_cnt_cs;
  logic     [ 3:0] cfg_prog_cnt_ns;
  logic     [15:0] cfg_set_fcb_prog;
  logic     [15:0] cfg_set_fcb_iso_en;
  logic            cfg_clr_fcb_fb_iso_enb;
  logic            cfg_set_fcb_prog_ifx;

  logic            pmu_clpd_ing_cs;
  logic            pmu_clpd_ing_ns;

  //--------------------------------------------------------------------------------//
  //-- Start Functional Description                                               --//
  //--------------------------------------------------------------------------------//
  //------------------------------------------------------------------------//
  //-- Current State : 	Next State : 	Result				--//
  //-- 0			0		No Action			--//
  //-- 0			1		Full Cfg			--//
  //-- 1			0		Clear Cfg			--//
  //-- 1			1		Partial Cfg			--//
  //------------------------------------------------------------------------//
  assign clear_cfg_kickoff = (frfu_fpmu_fb_cfg_done == 1'b1) ? frfu_fpmu_clr_cfg_done : 1'b0;

  assign partial_cfg_kickoff = (frfu_fpmu_fb_cfg_done == 1'b1) ? frfu_fpmu_prog_cfg_done : 1'b0;

  assign full_cfg_kickoff = (frfu_fpmu_fb_cfg_done == 1'b0) ? frfu_fpmu_prog_cfg_done : 1'b0;

  assign full_cfg_kickoff_dly1cyc 	= ( frfu_fpmu_fb_cfg_done == 1'b1 )
					?   frfu_fpmu_prog_cfg_done_cs : 1'b0 ;



  assign quad_cfg = ({frfu_fpmu_quad_cfg_b1, frfu_fpmu_quad_cfg_b0});

  assign fpmu_frfu_pmu_busy = (pmu_cfg_stm_cs == CFG_S00 && pmu_stm_cs == MAIN_S00) ? 1'b0 : 1'b1;

  assign fpmu_pmu_busy = (pmu_cfg_stm_cs == CFG_S00 && pmu_stm_cs == MAIN_S00) ? 1'b0 : 1'b1;

  assign quads_at_idle_state[15:0] = (~quad_status_1_cs[15:0]) & (~quad_status_0_cs[15:0]);


  assign fpmu_frfu_fb_cfg_cleanup = (pmu_cfg_stm_cs == CFG_S00) ? 1'b1 : 1'b0;

  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      pmu_cfg_stm_cs      <= #PAR_DLY CFG_S00;
      cfg_partial_mode_cs <= #PAR_DLY 1'b0;
      cfg_prog_cnt_cs     <= #PAR_DLY 4'b0;
    end else begin
      pmu_cfg_stm_cs      <= #PAR_DLY pmu_cfg_stm_ns;
      cfg_partial_mode_cs <= #PAR_DLY cfg_partial_mode_ns;
      cfg_prog_cnt_cs     <= #PAR_DLY cfg_prog_cnt_ns;
    end
  end
  //------------------------------------------------------------------------//
  //--  									--//
  //-- PROG == 0, Quad => Power Down					--//
  //-- PROG == 1, Quad => Power Up					--//
  //--  									--//
  //------------------------------------------------------------------------//
  always_comb begin
    pmu_cfg_stm_ns         = pmu_cfg_stm_cs;
    cfg_partial_mode_ns    = cfg_partial_mode_cs;
    cfg_timer_kickoff      = 1'b0;
    cfg_timer_ini_value    = timer_125ns_value;
    cfg_set_fcb_fb_iso_enb = 'b0;
    cfg_clr_fcb_prog_ifx   = 'b0;
    cfg_clr_fcb_prog       = 'b0;
    cfg_clr_fcb_iso_en     = 'b0;

    cfg_prog_cnt_ns        = cfg_prog_cnt_cs;
    cfg_set_fcb_prog       = 'b0;
    cfg_set_fcb_prog_ifx   = 'b0;
    cfg_set_fcb_iso_en     = 'b0;
    cfg_clr_fcb_fb_iso_enb = 'b0;

    case (pmu_cfg_stm_cs)
      CFG_S00: begin
        if (partial_cfg_kickoff == 1'b1) begin
          pmu_cfg_stm_ns = CFG_S02;
          cfg_partial_mode_ns = 1'b1;
        end else if (full_cfg_kickoff == 1'b1) begin
          pmu_cfg_stm_ns = CFG_S01;
          cfg_partial_mode_ns = 1'b0;
        end
	else if ( clear_cfg_kickoff == 1'b1 )	// New Added to reset the PROG/PROG_IFX/ISO_EN/FB_ISO_ENB
	  begin
          pmu_cfg_stm_ns = CFG_S10;
        end else begin
          pmu_cfg_stm_ns = pmu_cfg_stm_cs;
        end
      end
      CFG_S01: begin
        if (full_cfg_kickoff_dly1cyc == 1'b1) begin
          pmu_cfg_stm_ns = CFG_S02;
        end else begin
          pmu_cfg_stm_ns = CFG_S00;
        end
      end
      CFG_S02: begin
        pmu_cfg_stm_ns = CFG_S03;
      end
      CFG_S03: begin
        cfg_clr_fcb_prog[3:0] = quads_at_idle_state[3:0];
        pmu_cfg_stm_ns = CFG_S04;
      end
      CFG_S04: begin
        cfg_clr_fcb_prog[7:4] = quads_at_idle_state[7:4];
        pmu_cfg_stm_ns = CFG_S05;
      end
      CFG_S05: begin
        cfg_clr_fcb_prog[11:8] = quads_at_idle_state[11:8];
        pmu_cfg_stm_ns = CFG_S06;
      end
      CFG_S06: begin
        cfg_clr_fcb_prog[15:12] = quads_at_idle_state[15:12];
        if (cfg_partial_mode_cs == 1'b0) begin
          cfg_clr_fcb_prog_ifx = 1'b1;
        end
        pmu_cfg_stm_ns = CFG_S07;
      end

      CFG_S07: begin
        if (cfg_partial_mode_cs == 1'b0) begin
          pmu_cfg_stm_ns = CFG_S08;
        end else begin
          pmu_cfg_stm_ns = CFG_S0A;
        end
      end

      CFG_S08: begin
        if (pmu_timer_timeout == 1'b1) begin
          cfg_timer_kickoff = 1'b1;
          cfg_timer_ini_value = timer_125ns_value;
          pmu_cfg_stm_ns = CFG_S09;
        end else begin
          pmu_cfg_stm_ns = pmu_cfg_stm_cs;
        end
      end
      CFG_S09: begin
        if (pmu_timer_timeout == 1'b1) begin
          pmu_cfg_stm_ns = CFG_S0A;
          cfg_set_fcb_fb_iso_enb = 1'b1;
        end else begin
          pmu_cfg_stm_ns = pmu_cfg_stm_cs;
        end
      end
      CFG_S0A: begin
        pmu_cfg_stm_ns = CFG_S0B;
      end
      CFG_S0B: begin
        pmu_cfg_stm_ns = CFG_S0C;
        cfg_clr_fcb_iso_en = quads_at_idle_state;
      end
      CFG_S0C: begin
        pmu_cfg_stm_ns = CFG_S0D;
      end
      CFG_S0D: begin
        pmu_cfg_stm_ns = CFG_S00;
      end
      //----------------------------------------------------------------//
      //-- New Added							--//
      //----------------------------------------------------------------//
      CFG_S10: begin
        pmu_cfg_stm_ns = CFG_S11;
      end
      CFG_S11 :					// Tcfg2fie
      begin
        if (pmu_timer_timeout == 1'b1) begin
          cfg_timer_kickoff   = 1'b1;
          cfg_timer_ini_value = timer_125ns_value;
          pmu_cfg_stm_ns      = CFG_S12;
        end else begin
          pmu_cfg_stm_ns = pmu_cfg_stm_cs;
        end
      end
      CFG_S12: begin
        if (pmu_timer_timeout == 1'b1) begin
          pmu_cfg_stm_ns = CFG_S13;
          cfg_clr_fcb_fb_iso_enb = 1'b1;  // NEW NAME
        end else begin
          pmu_cfg_stm_ns = pmu_cfg_stm_cs;
        end
      end
      CFG_S13: begin
        pmu_cfg_stm_ns = CFG_S14;
      end
      CFG_S14: begin
        pmu_cfg_stm_ns = CFG_S15;
        cfg_set_fcb_iso_en = 16'b1111_1111_1111_1111;  // ALL
      end
      CFG_S15: begin
        if (pmu_timer_timeout == 1'b1) begin
          cfg_timer_kickoff   = 1'b1;
          cfg_timer_ini_value = timer_125ns_value;
          pmu_cfg_stm_ns      = CFG_S16;
        end else begin
          pmu_cfg_stm_ns = pmu_cfg_stm_cs;
        end
      end
      CFG_S16: begin
        cfg_set_fcb_prog[cfg_prog_cnt_cs] = 1'b1;
        pmu_cfg_stm_ns                    = CFG_S17;
      end
      CFG_S17: begin
        if (pmu_timer_timeout == 1'b1) begin
          cfg_timer_kickoff   = 1'b1;
          cfg_timer_ini_value = timer_125ns_value;
          pmu_cfg_stm_ns      = CFG_S18;
        end else begin
          pmu_cfg_stm_ns = pmu_cfg_stm_cs;
        end
      end
      CFG_S18: begin
        if (pmu_timer_timeout == 1'b1) begin
          if (cfg_prog_cnt_cs == 4'b1111) begin
            pmu_cfg_stm_ns  = CFG_S19;
            cfg_prog_cnt_ns = 'b0;
          end else begin
            pmu_cfg_stm_ns  = CFG_S16;
            cfg_prog_cnt_ns = cfg_prog_cnt_cs + 1;
          end
        end else begin
          pmu_cfg_stm_ns = pmu_cfg_stm_cs;
        end
      end
      CFG_S19: begin
        pmu_cfg_stm_ns = CFG_S1A;
      end
      CFG_S1A: begin
        cfg_set_fcb_prog_ifx = 'b1;
        pmu_cfg_stm_ns = CFG_S1B;
      end
      CFG_S1B: begin
        pmu_cfg_stm_ns = CFG_S1C;
      end
      CFG_S1C: begin
        pmu_cfg_stm_ns = CFG_S00;
      end
      default: begin
        pmu_cfg_stm_ns = CFG_S00;
      end
      //----------------------------------------------------------------//
      //-- END Sequence 						--//
      //----------------------------------------------------------------//
    endcase
  end
  //------------------------------------------------------------------------//
  //-- Timer, 1 base                                                      --//
  //------------------------------------------------------------------------//
  always_comb begin
    if (frfu_fpmu_pmu_time_ctl == 2'b00) begin
      timer_125ns_value = {1'b0, PAR_QLFCB_6BIT_125NS, 1'b0};
      timer_250ns_value = {1'b0, PAR_QLFCB_6BIT_250NS, 1'b0};
    end else if (frfu_fpmu_pmu_time_ctl == 2'b01) begin
      timer_125ns_value = {2'b00, PAR_QLFCB_6BIT_125NS};
      timer_250ns_value = {2'b00, PAR_QLFCB_6BIT_250NS};
    end else if (frfu_fpmu_pmu_time_ctl == 2'b10) begin
      if (PAR_QLFCB_6BIT_125NS >= 6'h04) begin
        timer_125ns_value = {2'b00, PAR_QLFCB_6BIT_125NS} >> 1;
      end else begin
        timer_125ns_value = {2'b00, PAR_QLFCB_6BIT_125NS};
      end

      if (PAR_QLFCB_6BIT_250NS >= 6'h04) begin
        timer_250ns_value = {2'b00, PAR_QLFCB_6BIT_250NS} >> 1;
      end else begin
        timer_125ns_value = {2'b00, PAR_QLFCB_6BIT_125NS};
      end
    end else begin
      if (PAR_QLFCB_6BIT_125NS >= 6'h08) begin
        timer_125ns_value = {2'b00, PAR_QLFCB_6BIT_125NS} >> 2;
      end else if (PAR_QLFCB_6BIT_125NS >= 6'h04) begin
        timer_125ns_value = {2'b00, PAR_QLFCB_6BIT_125NS} >> 1;
      end else begin
        timer_125ns_value = {2'b00, PAR_QLFCB_6BIT_125NS};
      end

      if (PAR_QLFCB_6BIT_250NS >= 6'h08) begin
        timer_250ns_value = {2'b00, PAR_QLFCB_6BIT_250NS} >> 2;
      end else if (PAR_QLFCB_6BIT_250NS >= 6'h04) begin
        timer_250ns_value = {2'b00, PAR_QLFCB_6BIT_250NS} >> 1;
      end else begin
        timer_125ns_value = {2'b00, PAR_QLFCB_6BIT_125NS};
      end
    end
  end

  //------------------------------------------------------------------------//
  //-- Timer, 1 base                                                      --//
  //------------------------------------------------------------------------//
  assign pmu_timer_timeout = (pmu_timer_cs == 8'h01 || pmu_timer_cs == 8'h00) ? 1'b1 : 1'b0;

  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      pmu_timer_cs <= #PAR_DLY 8'h00;
    end else begin
      pmu_timer_cs <= #PAR_DLY pmu_timer_ns;
    end
  end

  always_comb begin
    if (pmu_timer_kickoff == 1'b1) begin
      pmu_timer_ns = pmu_timer_ini_value;
    end else if (cfg_timer_kickoff == 1'b1) begin
      pmu_timer_ns = cfg_timer_ini_value;
    end else if (pmu_timer_cs == 8'h00) begin
      pmu_timer_ns = pmu_timer_cs;
    end else begin
      pmu_timer_ns = pmu_timer_cs - 1'b1;
    end
  end

  //--------------------------------------------------------------------------------//
  //-- Start Functional Description                                               --//
  //--------------------------------------------------------------------------------//
  //------------------------------------------------------------------------//
  //-- Quad PD WU                                                         --//
  //------------------------------------------------------------------------//
  assign kickoff_clvlp = ( chip_pw_sta_cs == 2'b00 && frfu_fpmu_pmu_chip_cmd == PAR_PMU_CMD_CLVLP ) 
	    	     ? 1'b1 : 1'b0 ;

  assign kickoff_clpd  = ( chip_pw_sta_cs == 2'b00 && frfu_fpmu_pmu_chip_cmd == PAR_PMU_CMD_CLPD ) 
	    	     ? 1'b1 : 1'b0 ;

  assign kickoff_clvlpwu = ( chip_pw_sta_cs == 2'b01 && 
		         ( frfu_fpmu_pmu_chip_cmd == PAR_PMU_CMD_CLWU0 || frfu_fpmu_pmu_chip_cmd == PAR_PMU_CMD_CLWU1 )) 
	    	       ? 1'b1 : 1'b0 ;

  assign kickoff_clpdwu  = ( chip_pw_sta_cs == 2'b10 && 
		         ( frfu_fpmu_pmu_chip_cmd == PAR_PMU_CMD_CLWU0 || frfu_fpmu_pmu_chip_cmd == PAR_PMU_CMD_CLWU1 )) 
	    	       ? 1'b1 : 1'b0 ;

  //------------------------------------------------------------------------//
  //-- Quad PD WU                                                         --//
  //-- PD --> WU								--//
  //------------------------------------------------------------------------//
  genvar index_7;
  generate
    for (index_7 = 0; index_7 < 16; index_7 = index_7 + 1) begin : CL_PD_WU
      always_comb begin
        chip_quad_pd_wu[index_7] = 1'b0;
        if ( frfu_fpmu_pmu_chip_cmd == PAR_PMU_CMD_CLWU0 || frfu_fpmu_pmu_chip_cmd == PAR_PMU_CMD_CLWU0 )
            begin
          if (quad_status_0_cs[index_7] == 1'b0 && quad_status_1_cs[index_7] == 1'b1) begin
            chip_quad_pd_wu[index_7] = 1'b1;
          end
        end
      end
    end
  endgenerate
  //------------------------------------------------------------------------//
  //-- CHIP Quad VLP WU                                                   --//
  //-- VLP --> WAKE UP							--//
  //------------------------------------------------------------------------//
  genvar index_6;
  generate
    for (index_6 = 0; index_6 < 16; index_6 = index_6 + 1) begin : CL_VLP_WU
      always_comb begin
        chip_quad_vlp_wu[index_6] = 1'b0;
        if ( frfu_fpmu_pmu_chip_cmd == PAR_PMU_CMD_CLWU0 || frfu_fpmu_pmu_chip_cmd == PAR_PMU_CMD_CLWU0 )
            begin
          if ( quad_status_0_cs[index_6] == 1'b1 && quad_status_1_cs[index_6] == 1'b0 )	// VLP 
                begin
            chip_quad_vlp_wu[index_6] = 1'b1;
          end
        end
      end
    end
  endgenerate
  //------------------------------------------------------------------------//
  //-- CHIP Quad PD                                                       --//
  //-- VLP --> PD								--//
  //-- IDLE --> PD							--//
  //------------------------------------------------------------------------//
  genvar index_5;
  generate
    for (index_5 = 0; index_5 < 16; index_5 = index_5 + 1) begin : CL_PD_EN
      always_comb begin
        chip_quad_pd_en[index_5] = 1'b0;
        // if ( frfu_fpmu_pmu_chip_cmd == PAR_PMU_CMD_CLPD )
        //  begin
        //    chip_quad_pd_en[index_5] = 1'b1 ;
        //  end
        //else if ( frfu_fpmu_pmu_chip_cmd == PAR_PMU_CMD_CLPD )
        if (frfu_fpmu_pmu_chip_cmd == PAR_PMU_CMD_CLPD) begin
          if ((quad_status_0_cs[index_5] == 1'b1 && quad_status_1_cs[index_5] == 1'b0) ||  // VLP
              ( quad_status_0_cs[index_5] == 1'b0 && quad_status_1_cs[index_5] == 1'b0) ) 	// Active
                begin
            chip_quad_pd_en[index_5] = 1'b1;
          end
        end
      end
    end
  endgenerate
  //------------------------------------------------------------------------//
  //-- CHIP Quad VLP							--//
  //-- ACTIVE --> VLP							--//
  //------------------------------------------------------------------------//
  genvar index_4;
  generate
    for (index_4 = 0; index_4 < 16; index_4 = index_4 + 1) begin : CL_VLP_EN
      always_comb begin
        chip_quad_vlp_en[index_4] = 1'b0;
        if (frfu_fpmu_pmu_chip_cmd == PAR_PMU_CMD_CLVLP) begin
          if ( quad_status_0_cs[index_4] == 1'b0 && quad_status_1_cs[index_4] == 1'b0 ) // Active
                begin
            chip_quad_vlp_en[index_4] = 1'b1;
          end
        end
      end
    end
  endgenerate
  //------------------------------------------------------------------------//
  //-- Quad PD WU                                                         --//
  //-- PD --> WU								--//
  //------------------------------------------------------------------------//
  genvar index_3;
  generate
    for (index_3 = 0; index_3 < 16; index_3 = index_3 + 1) begin : PD_WU
      always_comb begin
        quad_pd_wu[index_3] = 1'b0;
        if (frfu_fpmu_pmu_chip_cmd == PAR_PMU_CMD_QLPDWU) begin
          if ( quad_cfg[index_3] == 1'b1 && quad_status_0_cs[index_3] == 1'b0 && quad_status_1_cs[index_3] == 1'b1 )
                begin
            quad_pd_wu[index_3] = 1'b1;
          end
        end
      end
    end
  endgenerate
  //------------------------------------------------------------------------//
  //-- Quad VLP WU                                                        --//
  //-- VLP --> WU								--//
  //------------------------------------------------------------------------//
  genvar index_2;
  generate
    for (index_2 = 0; index_2 < 16; index_2 = index_2 + 1) begin : VLP_WU
      always_comb begin
        quad_vlp_wu[index_2] = 1'b0;
        if (frfu_fpmu_pmu_chip_cmd == PAR_PMU_CMD_QLVLPWU) begin
          if ( quad_cfg[index_2] == 1'b1 && quad_status_0_cs[index_2] == 1'b1 && quad_status_1_cs[index_2] == 1'b0 )
                begin
            quad_vlp_wu[index_2] = 1'b1;
          end
        end
      end
    end
  endgenerate

  //------------------------------------------------------------------------//
  //-- Quad PD                                                            --//
  //-- IDLE -> PD								--//
  //------------------------------------------------------------------------//
  genvar index_1;
  generate
    for (index_1 = 0; index_1 < 16; index_1 = index_1 + 1) begin : PD_EN
      always_comb begin
        quad_pd_en[index_1] = 1'b0;
        if (frfu_fpmu_pmu_chip_cmd == PAR_PMU_CMD_QLPD) begin
          if ( quad_cfg[index_1] == 1'b1 && quad_status_0_cs[index_1] == 1'b0 && quad_status_1_cs[index_1] == 1'b0 )
                begin
            quad_pd_en[index_1] = 1'b1;
          end
        end
      end
    end
  endgenerate

  //------------------------------------------------------------------------//
  //-- Quad VLP								--//
  //-- IDLE -> VLP							--//
  //------------------------------------------------------------------------//
  genvar index_0;
  generate
    for (index_0 = 0; index_0 < 16; index_0 = index_0 + 1) begin : VLP_EN
      always_comb begin
        quad_vlp_en[index_0] = 1'b0;
        if (frfu_fpmu_pmu_chip_cmd == PAR_PMU_CMD_QLVLP) begin
          if ( quad_cfg[index_0] == 1'b1 && quad_status_0_cs[index_0] == 1'b0 && quad_status_1_cs[index_0] == 1'b0 )
                begin
            quad_vlp_en[index_0] = 1'b1;
          end
        end
      end
    end
  endgenerate


  //--------------------------------------------------------------------------------//
  //-- Start Functional Description                                               --//
  //--------------------------------------------------------------------------------//
  //----------------------------------------------------------------//
  //-- MUX							--//
  //----------------------------------------------------------------//
  always_comb begin
    if (frfu_fpmu_pmu_mux_sel_sd == 1'b1) begin
      fcb_iso_en         = {frfu_fpmu_iso_en_sd_1, frfu_fpmu_iso_en_sd_0};
      fcb_pi_pwr         = {frfu_fpmu_pi_pwr_sd_1, frfu_fpmu_pi_pwr_sd_0};
      fcb_vlp_clkdis     = {frfu_fpmu_vlp_clkdis_sd_1, frfu_fpmu_vlp_clkdis_sd_0};
      fcb_vlp_srdis      = {frfu_fpmu_vlp_srdis_sd_1, frfu_fpmu_vlp_srdis_sd_0};
      fcb_vlp_pwrdis     = {frfu_fpmu_vlp_pwrdis_sd_1, frfu_fpmu_vlp_pwrdis_sd_0};
      fcb_vlp_clkdis_ifx = {frfu_fpmu_vlp_clkdis_ifx_sd};
      fcb_vlp_srdis_ifx  = {frfu_fpmu_vlp_srdis_ifx_sd};
      fcb_vlp_pwrdis_ifx = {frfu_fpmu_vlp_pwrdis_ifx_sd};
      fcb_set_por        = frfu_fpmu_set_por_sd;
      fcb_fb_iso_enb     = frfu_fpmu_fb_iso_enb_sd;
      fcb_pwr_gate       = frfu_fpmu_pwr_gate_sd;
      fcb_prog_ifx       = frfu_fpmu_prog_ifx_sd;
      fcb_prog           = {frfu_fpmu_prog_sd_1, frfu_fpmu_prog_sd_0};
    end else begin
      fcb_iso_en         = fcb_iso_en_cs;
      fcb_pi_pwr         = fcb_pi_pwr_cs;
      fcb_vlp_clkdis     = fcb_vlp_clkdis_cs;
      fcb_vlp_pwrdis     = fcb_vlp_pwrdis_cs;
      fcb_vlp_srdis      = fcb_vlp_srdis_cs;
      fcb_vlp_srdis_ifx  = fcb_vlp_srdis_ifx_cs;
      fcb_vlp_clkdis_ifx = fcb_vlp_clkdis_ifx_cs;
      fcb_vlp_pwrdis_ifx = fcb_vlp_pwrdis_ifx_cs;
      fcb_set_por        = fcb_set_por_cs;
      fcb_fb_iso_enb     = fcb_fb_iso_enb_cs;
      fcb_pwr_gate       = fcb_pwr_gate_cs;
      fcb_prog_ifx       = fcb_prog_ifx_cs;
      fcb_prog           = fcb_prog_cs;
    end
  end


  //----------------------------------------------------------------//
  //-- Toggle the Pin 						--//
  //----------------------------------------------------------------//
  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      if ( fcb_fb_default_on_bo == 1'b1 ) // Default ON
	begin
        fcb_fb_iso_enb_cs 		<=#PAR_DLY 'b0;
        fcb_iso_en_cs  		<=#PAR_DLY 16'hffff ;
        fcb_pi_pwr_cs  		<=#PAR_DLY 16'hffff ;
        fcb_vlp_clkdis_cs  		<=#PAR_DLY 'b0;
        fcb_vlp_clkdis_ifx_cs  	<=#PAR_DLY 'b0;
        fcb_vlp_srdis_cs  		<=#PAR_DLY 'b0;
        fcb_vlp_srdis_ifx_cs  	<=#PAR_DLY 'b0;
        fcb_vlp_pwrdis_cs  		<=#PAR_DLY 'b0;
        fcb_vlp_pwrdis_ifx_cs  	<=#PAR_DLY 'b0;
        fcb_pwr_gate_cs 		<=#PAR_DLY 'b0;
        fcb_prog_ifx_cs 		<=#PAR_DLY 1'b1;
        fcb_prog_cs 			<=#PAR_DLY 16'hffff ;
        fcb_set_por_cs  		<=#PAR_DLY 'b0;
      end else begin
        fcb_fb_iso_enb_cs 		<=#PAR_DLY 'b0;
        fcb_iso_en_cs  		<=#PAR_DLY 16'hffff ;
        fcb_pi_pwr_cs  		<=#PAR_DLY 'b0 ;
        fcb_vlp_clkdis_cs  		<=#PAR_DLY 'b0;
        fcb_vlp_clkdis_ifx_cs  	<=#PAR_DLY 'b0;
        fcb_vlp_srdis_cs  		<=#PAR_DLY 'b0;
        fcb_vlp_srdis_ifx_cs  	<=#PAR_DLY 'b0;
        fcb_vlp_pwrdis_cs  		<=#PAR_DLY 'b0;
        fcb_vlp_pwrdis_ifx_cs  	<=#PAR_DLY 'b0;
        fcb_pwr_gate_cs 		<=#PAR_DLY 1'b1;
        fcb_prog_ifx_cs 		<=#PAR_DLY 'b0;
        fcb_prog_cs 			<=#PAR_DLY 'b0 ;
        fcb_set_por_cs  		<=#PAR_DLY 'b0;
      end
    end else begin
      fcb_fb_iso_enb_cs     <= #PAR_DLY fcb_fb_iso_enb_ns;
      fcb_iso_en_cs         <= #PAR_DLY fcb_iso_en_ns;
      fcb_pi_pwr_cs         <= #PAR_DLY fcb_pi_pwr_ns;
      fcb_vlp_clkdis_cs     <= #PAR_DLY fcb_vlp_clkdis_ns;
      fcb_vlp_clkdis_ifx_cs <= #PAR_DLY fcb_vlp_clkdis_ifx_ns;
      fcb_vlp_srdis_cs      <= #PAR_DLY fcb_vlp_srdis_ns;
      fcb_vlp_srdis_ifx_cs  <= #PAR_DLY fcb_vlp_srdis_ifx_ns;
      fcb_vlp_pwrdis_cs     <= #PAR_DLY fcb_vlp_pwrdis_ns;
      fcb_vlp_pwrdis_ifx_cs <= #PAR_DLY fcb_vlp_pwrdis_ifx_ns;
      fcb_pwr_gate_cs       <= #PAR_DLY fcb_pwr_gate_ns;
      fcb_prog_ifx_cs       <= #PAR_DLY fcb_prog_ifx_ns;
      fcb_prog_cs           <= #PAR_DLY fcb_prog_ns;
      fcb_set_por_cs        <= #PAR_DLY fcb_set_por_ns;
    end
  end

  always_comb begin
    fcb_fb_iso_enb_ns     = fcb_fb_iso_enb_cs;  // 1
    fcb_iso_en_ns         = fcb_iso_en_cs;  // 2
    fcb_pi_pwr_ns         = fcb_pi_pwr_cs;  // 3
    fcb_vlp_clkdis_ns     = fcb_vlp_clkdis_cs;  // 4
    fcb_vlp_clkdis_ifx_ns = fcb_vlp_clkdis_ifx_cs;  // 5
    fcb_vlp_srdis_ns      = fcb_vlp_srdis_cs;  // 6
    fcb_vlp_srdis_ifx_ns  = fcb_vlp_srdis_ifx_cs;  // 7
    fcb_vlp_pwrdis_ns     = fcb_vlp_pwrdis_cs;  // 8
    fcb_vlp_pwrdis_ifx_ns = fcb_vlp_pwrdis_ifx_cs;  // 9
    fcb_pwr_gate_ns       = fcb_pwr_gate_cs;  // A
    fcb_prog_ifx_ns       = fcb_prog_ifx_cs;  // B
    fcb_prog_ns           = fcb_prog_cs;  // C
    fcb_set_por_ns        = fcb_set_por_cs;  // D

    if ( set_fcb_fb_iso_enb == 1'b1 )					// 1
    begin
      fcb_fb_iso_enb_ns = 1'b1;
    end else if (clr_fcb_fb_iso_enb == 1'b1) begin
      fcb_fb_iso_enb_ns = 1'b0;
    end else if (cfg_set_fcb_fb_iso_enb == 1'b1) begin
      fcb_fb_iso_enb_ns = 1'b1;
    end
  else if ( cfg_clr_fcb_fb_iso_enb == 1'b1 )				// 07-17
    begin
      fcb_fb_iso_enb_ns = 1'b0;
    end

    if ( |set_fcb_iso_en == 1'b1 )					// 2
    begin
      fcb_iso_en_ns = set_fcb_iso_en | fcb_iso_en_cs;
    end else if (|clr_fcb_iso_en == 1'b1) begin
      fcb_iso_en_ns = (~clr_fcb_iso_en) & fcb_iso_en_cs;
    end else if (|cfg_clr_fcb_iso_en == 1'b1) begin
      fcb_iso_en_ns = (~cfg_clr_fcb_iso_en) & fcb_iso_en_cs;
    end else if (|cfg_set_fcb_iso_en == 1'b1) begin
      fcb_iso_en_ns = cfg_set_fcb_iso_en | fcb_iso_en_cs;  // 07-17
    end

    if ( |set_fcb_pi_pwr == 1'b1 )					// 3
    begin
      fcb_pi_pwr_ns = set_fcb_pi_pwr | fcb_pi_pwr_cs;
    end else if (|clr_fcb_pi_pwr == 1'b1) begin
      fcb_pi_pwr_ns = (~clr_fcb_pi_pwr) & fcb_pi_pwr_cs;
    end

    if ( |set_fcb_vlp_clkdis == 1'b1 )					// 4
    begin
      fcb_vlp_clkdis_ns = set_fcb_vlp_clkdis | fcb_vlp_clkdis_cs;
    end else if (|clr_fcb_vlp_clkdis == 1'b1) begin
      fcb_vlp_clkdis_ns = (~clr_fcb_vlp_clkdis) & fcb_vlp_clkdis_cs;
    end

    if ( set_fcb_vlp_clkdis_ifx == 1'b1 )					// 5
    begin
      fcb_vlp_clkdis_ifx_ns = 1'b1;
    end else if (clr_fcb_vlp_clkdis_ifx == 1'b1) begin
      fcb_vlp_clkdis_ifx_ns = 1'b0;
    end

    if ( |set_fcb_vlp_srdis == 1'b1 )					// 6
    begin
      fcb_vlp_srdis_ns = set_fcb_vlp_srdis | fcb_vlp_srdis_cs;
    end else if (|clr_fcb_vlp_srdis == 1'b1) begin
      fcb_vlp_srdis_ns = (~clr_fcb_vlp_srdis) & fcb_vlp_srdis_cs;
    end

    if ( set_fcb_vlp_srdis_ifx == 1'b1 )					// 7
    begin
      fcb_vlp_srdis_ifx_ns = 1'b1;
    end else if (clr_fcb_vlp_srdis_ifx == 1'b1) begin
      fcb_vlp_srdis_ifx_ns = 1'b0;
    end

    if ( |set_fcb_vlp_pwrdis == 1'b1 )					// 8
    begin
      fcb_vlp_pwrdis_ns = set_fcb_vlp_pwrdis | fcb_vlp_pwrdis_cs;
    end else if (|clr_fcb_vlp_pwrdis == 1'b1) begin
      fcb_vlp_pwrdis_ns = (~clr_fcb_vlp_pwrdis) & fcb_vlp_pwrdis_cs;
    end

    if ( set_fcb_vlp_pwrdis_ifx == 1'b1 )					// 9
    begin
      fcb_vlp_pwrdis_ifx_ns = 1'b1;
    end else if (clr_fcb_vlp_pwrdis_ifx == 1'b1) begin
      fcb_vlp_pwrdis_ifx_ns = 1'b0;
    end

    if ( set_fcb_set_por == 1'b1 )					// A
    begin
      fcb_set_por_ns = 1'b1;
    end else if (clr_fcb_set_por == 1'b1) begin
      fcb_set_por_ns = 1'b0;
    end

    if ( set_fcb_prog_ifx == 1'b1 )					// B
    begin
      fcb_prog_ifx_ns = 1'b1;
    end else if (clr_fcb_prog_ifx == 1'b1) begin
      fcb_prog_ifx_ns = 1'b0;
    end else if (cfg_clr_fcb_prog_ifx == 1'b1) begin
      //fcb_prog_ifx_ns         = 1'b1 ;
      fcb_prog_ifx_ns = 1'b0;
    end
  else if ( cfg_set_fcb_prog_ifx == 1'b1 ) 				// New Added 07-17
    begin
      fcb_prog_ifx_ns = 1'b1;
    end

    if ( |set_fcb_prog == 1'b1 )						// C
    begin
      fcb_prog_ns = set_fcb_prog | fcb_prog_cs;
    end else if (|clr_fcb_prog == 1'b1) begin
      fcb_prog_ns = (~clr_fcb_prog) & fcb_prog_cs;
    end else if (|cfg_clr_fcb_prog == 1'b1) begin
      fcb_prog_ns = (~cfg_clr_fcb_prog) & fcb_prog_cs;
    end else if (|cfg_set_fcb_prog == 1'b1) begin
      fcb_prog_ns = cfg_set_fcb_prog | fcb_prog_cs;  // 07-17
    end

    if ( set_fcb_pwr_gate == 1'b1 )					// D
    begin
      fcb_pwr_gate_ns = 1'b1;
    end else if (clr_fcb_pwr_gate == 1'b1) begin
      fcb_pwr_gate_ns = 1'b0;
    end
  end

  //----------------------------------------------------------------//
  //-- Latch the Rising Edge					--//
  //----------------------------------------------------------------//

  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      frfu_fpmu_prog_cfg_done_cs     <= #PAR_DLY 1'b0;  // JC
      frfu_fpmu_prog_pmu_chip_cmd_cs <= #PAR_DLY 1'b0;
    end else begin
      frfu_fpmu_prog_cfg_done_cs     <= #PAR_DLY frfu_fpmu_prog_cfg_done;  // JC
      frfu_fpmu_prog_pmu_chip_cmd_cs <= #PAR_DLY frfu_fpmu_prog_pmu_chip_cmd;
    end
  end

  //----------------------------------------------------------------//
  //-- Main State Machine 					--//
  //----------------------------------------------------------------//
  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      pmu_stm_cs <= #PAR_DLY MAIN_S00;
      pmu_return_stm_cs <= #PAR_DLY MAIN_S00;
      pmu_stm_quad_cs <= #PAR_DLY 'b0;
      pmu_index_cnt_cs <= #PAR_DLY 'b0;
      chip_level_vlp_en_cs <= #PAR_DLY 'b0;
      pmu_clpd_ing_cs <= #PAR_DLY 'b0;
    end else begin
      if (fcb_clp_mode_en_bo == 1'b0) begin
        pmu_stm_cs <= #PAR_DLY pmu_stm_ns;
        pmu_return_stm_cs <= #PAR_DLY pmu_return_stm_ns;
        pmu_stm_quad_cs <= #PAR_DLY pmu_stm_quad_ns;
        pmu_index_cnt_cs <= #PAR_DLY pmu_index_cnt_ns;
        chip_level_vlp_en_cs <= #PAR_DLY chip_level_vlp_en_ns;
        pmu_clpd_ing_cs <= #PAR_DLY pmu_clpd_ing_ns;
      end
    end
  end


  always_comb begin
    pmu_stm_ns			= pmu_stm_cs ;
    pmu_return_stm_ns 		= pmu_return_stm_cs ;
    pmu_stm_quad_ns		= pmu_stm_quad_cs ;
    pmu_index_cnt_ns 		= pmu_index_cnt_cs ;
    chip_level_vlp_en_ns 		= chip_level_vlp_en_cs ;

    set_fcb_iso_en  		= 'b0 ;
    set_fcb_pi_pwr  		= 'b0 ;
    set_fcb_vlp_clkdis  		= 'b0 ;
    set_fcb_vlp_clkdis_ifx  	= 'b0 ;
    set_fcb_vlp_srdis  		= 'b0 ;
    set_fcb_vlp_srdis_ifx  	= 'b0 ;
    set_fcb_vlp_pwrdis  		= 'b0 ;
    set_fcb_vlp_pwrdis_ifx  	= 'b0 ;
    set_fcb_set_por  		= 'b0 ;
    set_fcb_fb_iso_enb 		= 'b0 ;
    set_fcb_pwr_gate 		= 'b0 ;
    set_fcb_prog_ifx 		= 'b0 ;
    set_fcb_prog 			= 'b0 ;
    clr_fcb_iso_en  		= 'b0 ;
    clr_fcb_pi_pwr  		= 'b0 ;
    clr_fcb_vlp_clkdis  		= 'b0 ;
    clr_fcb_vlp_clkdis_ifx  	= 'b0 ;
    clr_fcb_vlp_srdis  		= 'b0 ;
    clr_fcb_vlp_srdis_ifx  	= 'b0 ;
    clr_fcb_vlp_pwrdis  		= 'b0 ;
    clr_fcb_vlp_pwrdis_ifx  	= 'b0 ;
    clr_fcb_set_por  		= 'b0 ;
    clr_fcb_fb_iso_enb 		= 'b0 ;
    clr_fcb_pwr_gate 		= 'b0 ;
    clr_fcb_prog_ifx 		= 'b0 ;
    clr_fcb_prog 			= 'b0 ;
    set_quad_status_0 		= 'b0 ;
    set_quad_status_1 		= 'b0 ;
    clr_quad_status_0 		= 'b0 ;
    clr_quad_status_1 		= 'b0 ;
    set_vlp_chip_pw_sta 		= 'b0 ;
    set_pd_chip_pw_sta 		= 'b0 ;
    set_idle_chip_pw_sta 		= 'b0 ;

    fpmu_frfu_clr_pmu_chip_cmd	= 1'b0 ;
    fpmu_frfu_clr_quads 		= 1'b0 ;
    fpmu_frfu_clr_cfg_done	= 1'b0 ;
    pmu_timer_kickoff 		= 1'b0 ;
    pmu_timer_ini_value 		= timer_125ns_value ;

    pmu_clpd_ing_ns 		= pmu_clpd_ing_cs 	;

    case (pmu_stm_cs)
      MAIN_S00: begin
        if (frfu_fpmu_prog_pmu_chip_cmd_cs == 1'b1) begin
          if (kickoff_clvlp == 1'b1) begin
            pmu_stm_ns = MAIN_S08;
            pmu_stm_quad_ns = chip_quad_vlp_en;
            chip_level_vlp_en_ns = 1'b1;
          end else if (kickoff_clpd == 1'b1) begin
            pmu_stm_ns = MAIN_S18;
            pmu_stm_quad_ns = chip_quad_pd_en;
            chip_level_vlp_en_ns = 1'b0;  //JC
            pmu_clpd_ing_ns = 1'b1;
          end else if (kickoff_clvlpwu == 1'b1) begin
            pmu_stm_ns = MAIN_S10;
            pmu_stm_quad_ns = chip_quad_vlp_wu;
            chip_level_vlp_en_ns = 1'b1;
          end else if (kickoff_clpdwu == 1'b1) begin
            pmu_stm_ns = MAIN_S20;
            pmu_stm_quad_ns = chip_quad_pd_wu;
            chip_level_vlp_en_ns = 1'b0;  //JC
          end else if (|quad_vlp_en == 1'b1) begin
            pmu_stm_ns = MAIN_S28;
            pmu_stm_quad_ns = quad_vlp_en;
            chip_level_vlp_en_ns = 1'b0;
          end else if (|quad_pd_en == 1'b1) begin
            pmu_stm_ns = MAIN_S30;
            pmu_stm_quad_ns = quad_pd_en;
            chip_level_vlp_en_ns = 1'b0;  //JC
          end else if (|quad_vlp_wu == 1'b1) begin
            pmu_stm_ns = MAIN_S38;
            pmu_stm_quad_ns = quad_vlp_wu;
            chip_level_vlp_en_ns = 1'b0;
          end else if (|quad_pd_wu == 1'b1) begin
            pmu_stm_ns = MAIN_S40;
            pmu_stm_quad_ns = quad_pd_wu;
            chip_level_vlp_en_ns = 1'b0;  //JC
          end else begin
            pmu_stm_ns = END_S00;  // CMD programmed, but nothing happen
            pmu_stm_quad_ns = 'b0;
          end
        end else begin
          pmu_stm_ns = pmu_stm_cs;
        end
      end
      //----------------------------------------------------------------//
      //-- CHIP VLP							--//
      //----------------------------------------------------------------//
      MAIN_S08: begin
        pmu_stm_ns = MAIN_S09;
        clr_fcb_fb_iso_enb = 1'b1;
        pmu_timer_kickoff = 1'b1;
        pmu_timer_ini_value = timer_125ns_value;
      end
      MAIN_S09: begin
        if (pmu_timer_timeout == 1'b0) begin
          pmu_stm_ns = pmu_stm_cs;
        end else begin
          pmu_stm_ns = MAIN_S0A;
        end
      end
      MAIN_S0A: begin
        pmu_stm_ns = VLPE_S00;
        pmu_return_stm_ns = MAIN_S0B;
      end

      MAIN_S0B: begin
        pmu_stm_ns = MAIN_S0C;
      end

      MAIN_S0C: begin
        pmu_stm_ns = MAIN_S0D;
      end

      MAIN_S0D: begin
        pmu_stm_ns          = END_S00;
        set_vlp_chip_pw_sta = 1'b1;
      end

      //----------------------------------------------------------------//
      //-- CHIP VLP WU						--//
      //----------------------------------------------------------------//
      MAIN_S10: begin
        pmu_stm_ns = MAIN_S11;
      end
      MAIN_S11: begin
        pmu_stm_ns = VLPU_S00;
        pmu_return_stm_ns = MAIN_S12;
      end
      MAIN_S12: begin
        pmu_stm_ns = MAIN_S13;
        set_fcb_fb_iso_enb = 1'b1;
      end
      MAIN_S13: begin
        pmu_stm_ns = MAIN_S14;
      end
      MAIN_S14: begin
        pmu_stm_ns = MAIN_S15;
      end
      MAIN_S15: begin
        pmu_stm_ns = MAIN_S16;
      end
      MAIN_S16: begin
        set_idle_chip_pw_sta = 1'b1;
        pmu_stm_ns = END_S00;
      end
      //----------------------------------------------------------------//
      //-- CHIP PD							--//
      //----------------------------------------------------------------//
      MAIN_S18: begin
        pmu_stm_ns = MAIN_S19;
        fpmu_frfu_clr_cfg_done = 1'b1;
        pmu_timer_kickoff = 1'b1;
        pmu_timer_ini_value = timer_125ns_value;
      end
      MAIN_S19: begin
        if (pmu_timer_timeout == 1'b0) begin
          pmu_stm_ns = pmu_stm_cs;
        end else begin
          pmu_stm_ns = MAIN_S1A;
        end
      end
      MAIN_S1A: begin
        pmu_stm_ns = MAIN_S1B;
        clr_fcb_fb_iso_enb = 1'b1;
        pmu_timer_kickoff = 1'b1;
        pmu_timer_ini_value = timer_125ns_value;
      end
      MAIN_S1B: begin
        if (pmu_timer_timeout == 1'b0) begin
          pmu_stm_ns = pmu_stm_cs;
        end else begin
          pmu_stm_ns = MAIN_S1C;
        end
      end
      MAIN_S1C: begin
        pmu_stm_ns = MAIN_S1D;
      end

      MAIN_S1D: begin
        pmu_stm_ns = PWRD_S00;
        pmu_return_stm_ns = MAIN_S1E;
      end

      MAIN_S1E: begin
        set_fcb_pwr_gate = 1'b1;
        pmu_stm_ns = MAIN_S60;
        //pmu_stm_ns 		= MAIN_S1F ;
      end

      MAIN_S60: begin
        pmu_stm_ns = VLPU_S00;
        pmu_return_stm_ns = MAIN_S61;
      end

      MAIN_S61: begin
        pmu_stm_ns = MAIN_S1F;
      end

      MAIN_S1F: begin
        set_pd_chip_pw_sta = 1'b1;
        pmu_stm_ns = END_S00;
      end

      //----------------------------------------------------------------//
      //-- CHIP PD WU							--//
      //----------------------------------------------------------------//
      MAIN_S20: begin
        pmu_stm_ns = MAIN_S21;
        clr_fcb_pwr_gate = 1'b1;
        pmu_timer_kickoff = 1'b1;
        pmu_timer_ini_value = timer_125ns_value;
      end

      MAIN_S21: begin
        if (pmu_timer_timeout == 1'b0) begin
          pmu_stm_ns = pmu_stm_cs;
        end else begin
          pmu_stm_ns = MAIN_S22;
        end
      end

      MAIN_S22: begin
        pmu_stm_ns = PWRU_S00;
        pmu_return_stm_ns = MAIN_S23;
      end

      MAIN_S23: begin
        pmu_stm_ns = MAIN_S24;
        set_fcb_prog_ifx = 1'b1;
        pmu_timer_kickoff = 1'b1;
        pmu_timer_ini_value = timer_125ns_value;
      end

      MAIN_S24: begin
        if (pmu_timer_timeout == 1'b0) begin
          pmu_stm_ns = pmu_stm_cs;
        end else begin
          pmu_stm_ns = MAIN_S25;
        end
      end

      MAIN_S25: begin
        pmu_stm_ns = MAIN_S26;
        pmu_timer_kickoff = 1'b1;
        pmu_timer_ini_value = timer_250ns_value;
        set_fcb_set_por = 1'b1;
      end

      MAIN_S26: begin
        if (pmu_timer_timeout == 1'b0) begin
          pmu_stm_ns = pmu_stm_cs;
        end else begin
          pmu_stm_ns = MAIN_S27;
        end
      end

      MAIN_S27: begin
        clr_fcb_set_por = 1'b1;
        set_idle_chip_pw_sta = 1'b1;
        pmu_stm_ns = END_S00;
      end

      //----------------------------------------------------------------//
      //-- QUAD VLP							--//
      //----------------------------------------------------------------//
      MAIN_S28: begin
        pmu_stm_ns = MAIN_S29;
      end
      MAIN_S29: begin
        pmu_stm_ns = MAIN_S2A;
      end
      MAIN_S2A: begin
        pmu_stm_ns        = VLPE_S00;
        pmu_return_stm_ns = MAIN_S2B;
      end

      MAIN_S2B: begin
        pmu_stm_ns = MAIN_S2C;
      end

      MAIN_S2C: begin
        pmu_stm_ns = MAIN_S2D;
      end

      MAIN_S2D: begin
        pmu_stm_ns = END_S00;
      end

      //----------------------------------------------------------------//
      //-- QUAD PD							--//
      //----------------------------------------------------------------//
      MAIN_S30: begin
        pmu_stm_ns = MAIN_S31;
      end
      MAIN_S31: begin
        pmu_stm_ns        = PWRD_S00;
        pmu_return_stm_ns = MAIN_S32;
      end
      MAIN_S32: begin
        pmu_stm_ns = MAIN_S33;
      end
      MAIN_S33: begin
        pmu_stm_ns = MAIN_S34;
      end
      MAIN_S34: begin
        pmu_stm_ns = MAIN_S35;
      end
      MAIN_S35: begin
        pmu_stm_ns = END_S00;
      end

      //----------------------------------------------------------------//
      //-- QUAD VLP WU						--//
      //----------------------------------------------------------------//
      MAIN_S38: begin
        pmu_stm_ns = MAIN_S39;
      end
      MAIN_S39: begin
        pmu_stm_ns        = VLPU_S00;
        pmu_return_stm_ns = MAIN_S3A;
      end
      MAIN_S3A: begin
        pmu_stm_ns = MAIN_S3B;
      end
      MAIN_S3B: begin
        pmu_stm_ns = MAIN_S3C;
      end
      MAIN_S3C: begin
        pmu_stm_ns = MAIN_S3D;
      end
      MAIN_S3D: begin
        pmu_stm_ns = MAIN_S3E;
      end
      MAIN_S3E: begin
        pmu_stm_ns = END_S00;
      end

      //----------------------------------------------------------------//
      //-- QUAD PD WU							--//
      //----------------------------------------------------------------//
      MAIN_S40: begin
        pmu_stm_ns = MAIN_S41;
      end
      MAIN_S41: begin
        pmu_stm_ns        = PWRU_S00;
        pmu_return_stm_ns = MAIN_S42;
      end
      MAIN_S42: begin
        pmu_stm_ns = MAIN_S43;
      end
      MAIN_S43: begin
        pmu_stm_ns = MAIN_S44;
      end
      MAIN_S44: begin
        pmu_stm_ns = MAIN_S45;
      end
      MAIN_S45: begin
        pmu_stm_ns = END_S00;
      end

      //----------------------------------------------------------------//
      //-- QUAD VLP UP Sequence 					--//
      //----------------------------------------------------------------//
      VLPU_S00: begin
        pmu_index_cnt_ns = 'b0;
        pmu_stm_ns = VLPU_S01;
      end
      VLPU_S01: begin
        clr_fcb_vlp_pwrdis_ifx = chip_level_vlp_en_cs;
        clr_fcb_vlp_pwrdis = pmu_stm_quad_cs;
        pmu_timer_kickoff = 1'b1;
        pmu_timer_ini_value = timer_250ns_value;
        pmu_stm_ns = VLPU_S02;
      end
      VLPU_S02: begin
        if (pmu_timer_timeout == 1'b0) begin
          pmu_stm_ns = pmu_stm_cs;
        end else begin
          pmu_stm_ns = VLPU_S03;
        end
      end
      VLPU_S03: begin
        clr_fcb_vlp_srdis_ifx = chip_level_vlp_en_cs;
        clr_fcb_vlp_srdis     = pmu_stm_quad_cs;
        pmu_timer_kickoff     = 1'b1;
        pmu_timer_ini_value   = timer_250ns_value;
        pmu_stm_ns            = VLPU_S04;
      end
      VLPU_S04: begin
        if (pmu_timer_timeout == 1'b0) begin
          pmu_stm_ns = pmu_stm_cs;
        end else begin
          pmu_stm_ns = VLPU_S05;
        end
      end

      VLPU_S05: begin
        clr_fcb_vlp_clkdis_ifx = chip_level_vlp_en_cs;
        clr_fcb_vlp_clkdis     = pmu_stm_quad_cs;
        pmu_timer_kickoff      = 1'b1;
        pmu_timer_ini_value    = timer_250ns_value;
        pmu_stm_ns             = VLPU_S06;
      end

      VLPU_S06: begin
        if (pmu_timer_timeout == 1'b0) begin
          pmu_stm_ns = pmu_stm_cs;
        end else begin
          pmu_stm_ns = VLPU_S07;
        end
      end

      VLPU_S07: begin
        //set_fcb_iso_en	= pmu_stm_quad_cs ;	
        if ( pmu_clpd_ing_cs == 1'b1 )		//JC NOTE	
          begin
          clr_fcb_iso_en = 'b0;  //JC NOTE
        end else begin
          clr_fcb_iso_en = pmu_stm_quad_cs;  //JC NOTE
        end
        pmu_timer_kickoff   = 1'b1;
        pmu_timer_ini_value = timer_125ns_value;
        pmu_stm_ns          = VLPU_S08;
      end
      VLPU_S08: begin
        if (pmu_timer_timeout == 1'b0) begin
          pmu_stm_ns = pmu_stm_cs;
        end else begin
          pmu_stm_ns = VLPU_S09;
        end
      end
      VLPU_S09: begin
        pmu_stm_ns = pmu_return_stm_cs;
        if ( pmu_clpd_ing_cs == 1'b0 )		//JC NOTE	
	  begin
          clr_quad_status_1 = pmu_stm_quad_cs;  // IDLE
          clr_quad_status_0 = pmu_stm_quad_cs;
        end
      end

      //----------------------------------------------------------------//
      //-- QUAD VLP Sequence 						--//
      //----------------------------------------------------------------//
      VLPE_S00: begin
        pmu_index_cnt_ns = 'b0;
        pmu_stm_ns = VLPE_S01;
      end
      VLPE_S01: begin
        set_fcb_iso_en = pmu_stm_quad_cs;
        pmu_timer_kickoff = 1'b1;
        pmu_timer_ini_value = timer_250ns_value;
        pmu_stm_ns = VLPE_S02;
      end
      VLPE_S02: begin
        if (pmu_timer_timeout == 1'b0) begin
          pmu_stm_ns = pmu_stm_cs;
        end else begin
          pmu_stm_ns = VLPE_S03;
        end
      end
      VLPE_S03: begin
        set_fcb_vlp_clkdis_ifx = chip_level_vlp_en_cs;
        set_fcb_vlp_clkdis     = pmu_stm_quad_cs;
        pmu_timer_kickoff      = 1'b1;
        pmu_timer_ini_value    = timer_250ns_value;
        pmu_stm_ns             = VLPE_S04;
      end
      VLPE_S04: begin
        if (pmu_timer_timeout == 1'b0) begin
          pmu_stm_ns = pmu_stm_cs;
        end else begin
          pmu_stm_ns = VLPE_S05;
        end
      end

      VLPE_S05: begin
        set_fcb_vlp_srdis_ifx = chip_level_vlp_en_cs;
        set_fcb_vlp_srdis     = pmu_stm_quad_cs;
        pmu_timer_kickoff     = 1'b1;
        pmu_timer_ini_value   = timer_250ns_value;
        pmu_stm_ns            = VLPE_S06;
      end

      VLPE_S06: begin
        if (pmu_timer_timeout == 1'b0) begin
          pmu_stm_ns = pmu_stm_cs;
        end else begin
          pmu_stm_ns = VLPE_S07;
        end
      end

      VLPE_S07: begin
        set_fcb_vlp_pwrdis_ifx = chip_level_vlp_en_cs;
        set_fcb_vlp_pwrdis     = pmu_stm_quad_cs;
        pmu_timer_kickoff      = 1'b1;
        pmu_timer_ini_value    = timer_250ns_value;
        pmu_stm_ns             = VLPE_S08;
      end

      VLPE_S08: begin
        if (pmu_timer_timeout == 1'b0) begin
          pmu_stm_ns = pmu_stm_cs;
        end else begin
          pmu_stm_ns = VLPE_S09;
        end
      end

      VLPE_S09: begin
        clr_quad_status_1 = pmu_stm_quad_cs;  // VLP
        set_quad_status_0 = pmu_stm_quad_cs;
        pmu_stm_ns = pmu_return_stm_cs;
      end

      //----------------------------------------------------------------//
      //-- QUAD PD Sequence 						--//
      //----------------------------------------------------------------//
      PWRD_S00: begin
        pmu_index_cnt_ns    = 'b0;
        pmu_stm_ns          = PWRD_S01;
        set_fcb_iso_en      = pmu_stm_quad_cs;
        pmu_timer_kickoff   = 1'b1;
        pmu_timer_ini_value = timer_125ns_value;
      end

      PWRD_S01: begin
        if (pmu_timer_timeout == 1'b0) begin
          pmu_stm_ns = pmu_stm_cs;
        end else begin
          pmu_stm_ns = PWRD_S02;
        end
      end

      PWRD_S02: begin
        pmu_stm_ns = PWRD_S03;
      end

      PWRD_S03: begin
        if (pmu_stm_quad_cs[pmu_index_cnt_cs] == 1'b1) begin
          pmu_stm_ns = PWRD_S04;
        end else begin
          if (pmu_index_cnt_cs == 4'b1111) begin
            pmu_stm_ns = PWRD_S06;
          end else begin
            pmu_index_cnt_ns = pmu_index_cnt_cs + 1'b1;
            pmu_stm_ns = pmu_stm_cs;
          end
        end
      end

      PWRD_S04: begin
        pmu_stm_ns                       = PWRD_S05;
        clr_fcb_pi_pwr[pmu_index_cnt_cs] = 1'b1;
        //set_quad_status_1[pmu_index_cnt_cs]   = 1'b1 ;	// IDLE
        //clr_quad_status_0[pmu_index_cnt_cs]   = 1'b1 ;
        pmu_timer_kickoff                = 1'b1;
        pmu_timer_ini_value              = timer_125ns_value;
      end

      PWRD_S05: begin
        if (pmu_timer_timeout == 1'b0) begin
          pmu_stm_ns = pmu_stm_cs;
        end else begin
          if (pmu_index_cnt_cs == 4'b1111) begin
            pmu_stm_ns = PWRD_S06;
          end else begin
            pmu_index_cnt_ns = pmu_index_cnt_cs + 1'b1;
            pmu_stm_ns = PWRD_S03;
          end
        end
      end

      PWRD_S06: begin
        set_quad_status_1 = pmu_stm_quad_cs;  // PD
        clr_quad_status_0 = pmu_stm_quad_cs;
        pmu_stm_ns = pmu_return_stm_cs;
      end

      //----------------------------------------------------------------//
      //-- QUAD PD WU Sequence 					--//
      //----------------------------------------------------------------//

      PWRU_S00: begin
        pmu_index_cnt_ns = 'b0;
        pmu_stm_ns = PWRU_S01;
      end

      PWRU_S01: begin
        if (pmu_stm_quad_cs[pmu_index_cnt_cs] == 1'b1) begin
          pmu_stm_ns = PWRU_S02;
        end else begin
          if (pmu_index_cnt_cs == 4'b1111) begin
            pmu_stm_ns = PWRU_S04;
          end else begin
            pmu_index_cnt_ns = pmu_index_cnt_cs + 1'b1;
            pmu_stm_ns = PWRU_S01;
          end
        end
      end

      PWRU_S02: begin
        pmu_stm_ns                       = PWRU_S03;
        set_fcb_pi_pwr[pmu_index_cnt_cs] = 1'b1;
        set_fcb_prog[pmu_index_cnt_cs]   = 1'b1;
        //clr_quad_status_1[pmu_index_cnt_cs]   = 1'b1 ;	// IDLE
        //clr_quad_status_0[pmu_index_cnt_cs]   = 1'b1 ;
        pmu_timer_kickoff                = 1'b1;
        pmu_timer_ini_value              = timer_125ns_value;
      end

      PWRU_S03: begin
        if (pmu_timer_timeout == 1'b0) begin
          pmu_stm_ns = pmu_stm_cs;
        end else begin
          if (pmu_index_cnt_cs == 4'b1111) begin
            pmu_stm_ns = PWRU_S04;
          end else begin
            pmu_index_cnt_ns = pmu_index_cnt_cs + 1'b1;
            pmu_stm_ns = PWRU_S01;
          end
        end
      end

      PWRU_S04: begin
        clr_quad_status_1 = pmu_stm_quad_cs;  // IDLE
        clr_quad_status_0 = pmu_stm_quad_cs;
        pmu_stm_ns = pmu_return_stm_cs;
      end

      //----------------------------------------------------------------//
      //-- END Sequence 						--//
      //----------------------------------------------------------------//
      END_S00: begin
        pmu_stm_ns 			= MAIN_S00;
        fpmu_frfu_clr_pmu_chip_cmd	= 1'b1 ;
        fpmu_frfu_clr_quads 		= 1'b1 ;
        pmu_clpd_ing_ns 		= 1'b0 ;
      end

      //----------------------------------------------------------------//
      //-- Default							--//
      //----------------------------------------------------------------//
      default: begin
        pmu_stm_ns = MAIN_S00;
      end
    endcase
  end
  //----------------------------------------------------------------//
  //-- Power Satus 						--//
  //----------------------------------------------------------------//

  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      if (fcb_fb_default_on_bo == 1'b1) begin
        quad_status_1_cs <= #PAR_DLY 'b0;
        quad_status_0_cs <= #PAR_DLY 'b0;
        chip_pw_sta_cs   <= #PAR_DLY 'b0;
      end else begin
        quad_status_1_cs <= #PAR_DLY 16'hffff;
        quad_status_0_cs <= #PAR_DLY 'b0;
        chip_pw_sta_cs   <= #PAR_DLY 2'b10;
      end
    end else begin
      quad_status_1_cs <= #PAR_DLY quad_status_1_ns;
      quad_status_0_cs <= #PAR_DLY quad_status_0_ns;
      chip_pw_sta_cs   <= #PAR_DLY chip_pw_sta_ns;
    end
  end
  //------------------------------------------------------------------------//
  //-- CHIP Quad VLP WU                                                   --//
  //-- VLP --> WAKE UP                                                    --//
  //------------------------------------------------------------------------//
  genvar index_qs0;
  generate
    for (index_qs0 = 0; index_qs0 < 16; index_qs0 = index_qs0 + 1) begin : Quad_Status
      always_comb begin
        if (set_quad_status_1[index_qs0] == 1'b1) begin
          quad_status_1_ns[index_qs0] = 1'b1;
        end else if (clr_quad_status_1[index_qs0] == 1'b1) begin
          quad_status_1_ns[index_qs0] = 1'b0;
        end else begin
          quad_status_1_ns[index_qs0] = quad_status_1_cs[index_qs0];
        end

        if (set_quad_status_0[index_qs0] == 1'b1) begin
          quad_status_0_ns[index_qs0] = 1'b1;
        end else if (clr_quad_status_0[index_qs0] == 1'b1) begin
          quad_status_0_ns[index_qs0] = 1'b0;
        end else begin
          quad_status_0_ns[index_qs0] = quad_status_0_cs[index_qs0];
        end
      end
    end
  endgenerate

  always_comb begin
    if (set_vlp_chip_pw_sta == 1'b1) begin
      chip_pw_sta_ns = 2'b01;
    end else if (set_pd_chip_pw_sta) begin
      chip_pw_sta_ns = 2'b10;
    end else if (set_idle_chip_pw_sta) begin
      chip_pw_sta_ns = 2'b00;
    end else begin
      chip_pw_sta_ns = chip_pw_sta_cs;
    end
  end

  assign fpmu_frfu_chip_pw_sta = chip_pw_sta_cs;
  assign fpmu_frfu_pw_sta_00   = {quad_status_1_cs[0], quad_status_0_cs[0]};
  assign fpmu_frfu_pw_sta_01   = {quad_status_1_cs[1], quad_status_0_cs[1]};
  assign fpmu_frfu_pw_sta_02   = {quad_status_1_cs[2], quad_status_0_cs[2]};
  assign fpmu_frfu_pw_sta_03   = {quad_status_1_cs[3], quad_status_0_cs[3]};
  assign fpmu_frfu_pw_sta_10   = {quad_status_1_cs[4], quad_status_0_cs[4]};
  assign fpmu_frfu_pw_sta_11   = {quad_status_1_cs[5], quad_status_0_cs[5]};
  assign fpmu_frfu_pw_sta_12   = {quad_status_1_cs[6], quad_status_0_cs[6]};
  assign fpmu_frfu_pw_sta_13   = {quad_status_1_cs[7], quad_status_0_cs[7]};
  assign fpmu_frfu_pw_sta_20   = {quad_status_1_cs[8], quad_status_0_cs[8]};
  assign fpmu_frfu_pw_sta_21   = {quad_status_1_cs[9], quad_status_0_cs[9]};
  assign fpmu_frfu_pw_sta_22   = {quad_status_1_cs[10], quad_status_0_cs[10]};
  assign fpmu_frfu_pw_sta_23   = {quad_status_1_cs[11], quad_status_0_cs[11]};
  assign fpmu_frfu_pw_sta_30   = {quad_status_1_cs[12], quad_status_0_cs[12]};
  assign fpmu_frfu_pw_sta_31   = {quad_status_1_cs[13], quad_status_0_cs[13]};
  assign fpmu_frfu_pw_sta_32   = {quad_status_1_cs[14], quad_status_0_cs[14]};
  assign fpmu_frfu_pw_sta_33   = {quad_status_1_cs[15], quad_status_0_cs[15]};


  //--------------------------------------------------------------------------------//
  //-- END                                                                        --//
  //--------------------------------------------------------------------------------//
endmodule


