// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

module fcbrwf (
    //------------------------------------------------------------------------//
    //-- INPUT PORT                                                         --//
    //------------------------------------------------------------------------//
    input  logic        fcb_sys_clk,  //Main Clock for FCB except SPI Slave Int
    input  logic        fcb_sys_rst_n,  //Main Reset for FCB except SPI Slave int
    input  logic        fcb_sys_stm,  //1'b1 : Put the module into Test Mode
    input  logic        fpif_frwf_pif_on,  //PIF Path is ON			//
    input  logic [39:0] fpif_frwf_wff_wr_data,  //Bit 31:0 : Write Data, Bit 38:32 : SFR //
    input  logic        fpif_frwf_wff_wr_en,  //Write Data Enable 			 //
    input  logic        fpif_frwf_crf_rd_en,  //Read Enable Of Read Back FIFO		//
    input  logic        faps_frwf_apb_on,  //APB Path Is ON.			//	
    input  logic [39:0] faps_frwf_wff_wr_data,  //Bit 31:0 : Write Data, Bit 38:32 : SFR//
    input  logic        faps_frwf_wff_wr_en,  //Write Data Enable			//
    input  logic        faps_frwf_crf_rd_en,  //Read Enable Of Read Back FIFO		//
    input  logic [ 7:0] frfu_sfr_rd_data,  //SFR Read Data				//
    input  logic        frfu_cwf_full,  //Full Flag of Cfg Write FIFO
    input  logic        frfu_frwf_crf_wr_en,  //Write Enable of Cfg Read FIFO
    input  logic [31:0] frfu_frwf_crf_wr_data,  //Write Enable of Cfg Read FIFO
    //------------------------------------------------------------------------//
    //-- OUTPUT PORT                                                        --//
    //------------------------------------------------------------------------//
    output logic        frwf_frfu_ff0_of,  // FIFO 0 Overflow
    output logic        frwf_wff_full,  // Full Flag of Write Data FIFO
    output logic        frwf_wff_full_m1,  //Full minus 1 Flag of Write Data FIFO
    output logic        frwf_crf_empty,  //Empty Flag of Read Back FIFO
    output logic        frwf_crf_empty_p1,  //Empty Plus One Flag of Read Back FIFO
    output logic [31:0] frwf_crf_rd_data,  // Read Data for APBS/PIF
    output logic [ 6:0] frwf_frfu_wr_addr,  //SFR Write Addr
    output logic [ 6:0] frwf_frfu_rd_addr,  //SFR Read Addr
    output logic        frwf_frfu_wr_en,  //SFR Write Enable
    output logic        frwf_frfu_rd_en,  //SFR Read Enable
    output logic [ 7:0] frwf_frfu_wr_data,  //SFR Write Data
    output logic        frwf_frfu_frwf_on,  //APB/PIF Path ON
    output logic [31:0] frwf_frfu_cwf_wr_data,  //Cfg Write Data
    output logic        frwf_frfu_cwf_wr_en,  //Write Enable to indicate the whole 32-B
    output logic        frwf_frfu_crf_full,  //Full Flag of Cfg Read FIFO
    output logic        frwf_frfu_crf_full_m1  //Full minus 1 Flag of Cfg Read FIFO
);

  //------------------------------------------------------------------------//
  //-- Local Parameter                                                    --//
  //------------------------------------------------------------------------//
  localparam PAR_DLY = 1'b1;

  //------------------------------------------------------------------------//
  //-- EMUN/Flops                                                         --//
  //------------------------------------------------------------------------//
  typedef enum logic [2:0] {
    MAIN_S00 = 3'b000,
    MAIN_S01 = 3'b001,
    MAIN_S02 = 3'b010,
    MAIN_S03 = 3'b011,
    MAIN_S04 = 3'b100,
    MAIN_S05 = 3'b101
  } EN_STATE;

  //------------------------------------------------------------------------//
  //-- Wire/Flops                                                         --//
  //------------------------------------------------------------------------//
  EN_STATE rfw_stm_cs;
  EN_STATE rfw_stm_ns;

  logic wff_empty;
  logic wff_empty_p1;

  logic [39:0] frwf_frfu_cwf_wr_data_temp;


  //--------------------------------------------------------------------------------//
  //-- Start Functional Description                                               --//
  //--------------------------------------------------------------------------------//
  assign frwf_frfu_ff0_of		= ( frwf_wff_full == 1'b1 )
				? ( fpif_frwf_wff_wr_en | faps_frwf_wff_wr_en ) : 1'b0 ;	// FIFO 0 Overflow
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  assign frwf_frfu_cwf_wr_data[31:0] = frwf_frfu_cwf_wr_data_temp[31:0];
  assign frwf_frfu_wr_data = frwf_frfu_cwf_wr_data_temp[7:0];
  assign frwf_frfu_wr_addr = frwf_frfu_cwf_wr_data_temp[38:32];
  assign frwf_frfu_rd_addr = frwf_frfu_cwf_wr_data_temp[38:32];

  assign frwf_frfu_frwf_on = fpif_frwf_pif_on | faps_frwf_apb_on;

  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      rfw_stm_cs <= #PAR_DLY MAIN_S00;
    end else begin
      rfw_stm_cs <= #PAR_DLY rfw_stm_ns;
    end
  end
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  always_comb begin

    rfw_stm_ns = rfw_stm_cs;
    frwf_frfu_rd_en = 1'b0;
    frwf_frfu_cwf_wr_en = 1'b0;
    frwf_frfu_wr_en = 1'b0;

    unique case (rfw_stm_cs)
      MAIN_S00: begin
        if ( wff_empty == 1'b0 && frwf_frfu_cwf_wr_data_temp[39] == 1'b1 && frwf_frfu_cwf_wr_data_temp[38:32] == 7'h20 )//Data
	  begin
          if (frfu_cwf_full == 1'b0) begin
            rfw_stm_ns = MAIN_S01;
          end
        end
	else if ( wff_empty == 1'b0 && frwf_frfu_cwf_wr_data_temp[39] == 1'b1 )//SFR Write
	  begin
          rfw_stm_ns = MAIN_S02;
        end
	else if ( wff_empty == 1'b0 && frwf_frfu_cwf_wr_data_temp[39] == 1'b0 )//SFR Read
	  begin
          rfw_stm_ns = MAIN_S03;
        end else begin
          rfw_stm_ns = rfw_stm_cs;
        end
      end

      MAIN_S01: begin
        frwf_frfu_cwf_wr_en = 1'b1;
        rfw_stm_ns = MAIN_S00;
      end

      MAIN_S02: begin
        frwf_frfu_wr_en = 1'b1;
        rfw_stm_ns = MAIN_S00;
      end

      MAIN_S03: begin
        frwf_frfu_rd_en = 1'b1;
        rfw_stm_ns = MAIN_S00;
      end

      default: begin
        rfw_stm_ns = MAIN_S00;
      end
    endcase
  end
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  //----------------------------------------------------------------//
  //-- FIFO Component                                             --//
  //----------------------------------------------------------------//
  //--------------------------------------------------------//
  //-- qf_sff Instance                                    --//
  //-- rff -- 2 Entries                                   --//
  //--------------------------------------------------------//
  qf_sff #(
      .PAR_FIFO_DATA_WIDTH(40),
      .PAR_FIFO_DEPTH_BITS(1)
  ) qf_sff_INST_0  // WFF
  (
      //------------------------------------------------------------//
      //-- INPUT                                                  --//
      //------------------------------------------------------------//
      .fifo_clk(fcb_sys_clk),
      .fifo_rst_n(fcb_sys_rst_n),
      .fifo_rd_en(frwf_frfu_cwf_wr_en | frwf_frfu_wr_en | frwf_frfu_rd_en),
      .fifo_wr_data                   ( ( fpif_frwf_wff_wr_data & {40{fpif_frwf_wff_wr_en}} ) | 
				  ( faps_frwf_wff_wr_data & {40{faps_frwf_wff_wr_en}} ) ),
      .fifo_wr_en(fpif_frwf_wff_wr_en | faps_frwf_wff_wr_en),
      //------------------------------------------------------------//
      //-- OUTPUT                                                 --//
      //------------------------------------------------------------//
      .fifo_empty_flag(wff_empty),
      .fifo_empty_p1_flag(wff_empty_p1),
      .fifo_full_flag(frwf_wff_full),
      .fifo_full_m1_flag(frwf_wff_full_m1),
      .fifo_rd_data(frwf_frfu_cwf_wr_data_temp)  // XXX
  );

  //----------------------------------------------------------------//
  //-- FIFO Component                                             --//
  //----------------------------------------------------------------//
  //--------------------------------------------------------//
  //-- qf_sff Instance                                    --//
  //-- rff -- 2 Entries                                   --//
  //--------------------------------------------------------//
  qf_sff #(
      .PAR_FIFO_DATA_WIDTH(32),
      .PAR_FIFO_DEPTH_BITS(1)
  ) qf_sff_INST_1  // RFF
  (
      //------------------------------------------------------------//
      //-- INPUT                                                  --//
      //------------------------------------------------------------//
      .fifo_clk(fcb_sys_clk),
      .fifo_rst_n(fcb_sys_rst_n),
      .fifo_rd_en(fpif_frwf_crf_rd_en | faps_frwf_crf_rd_en),
      .fifo_wr_data(({
        {24{1'b0}}, frfu_sfr_rd_data
      } & {32{frwf_frfu_rd_en}}) | (frfu_frwf_crf_wr_data & {32{frfu_frwf_crf_wr_en}})),
      .fifo_wr_en(frwf_frfu_rd_en | frfu_frwf_crf_wr_en),
      //------------------------------------------------------------//
      //-- OUTPUT                                                 --//
      //------------------------------------------------------------//
      .fifo_empty_flag(frwf_crf_empty),
      .fifo_empty_p1_flag(frwf_crf_empty_p1),
      .fifo_full_flag(frwf_frfu_crf_full),
      .fifo_full_m1_flag(frwf_frfu_crf_full_m1),
      .fifo_rd_data(frwf_crf_rd_data)
  );

  //--------------------------------------------------------------------------------//
  //-- END                                                                        --//
  //--------------------------------------------------------------------------------//
endmodule


