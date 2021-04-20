// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

module fcbssc (
    //------------------------------------------------------------------------//
    //-- INPUT PORT                                                         --//
    //------------------------------------------------------------------------//
    input  logic       fcb_sys_clk,  //Main Clock for FCB except SPI Slave Int
    input  logic       fcb_sys_rst_n,  //Main Reset for FCB except SPI Slave int
    input  logic       fcb_spis_clk,  //Clock for SPIS Slave Interface
    input  logic       fcb_spis_rst_n,  //Reset for SPIS slave Interface, it is a
    input  logic       fcb_sys_stm,  //1'b1 : Put the module into Test Mode
    input  logic       fcb_spis_mosi,  //SPI Slave MOSI
    input  logic       fcb_spis_cs_n,  //SPI Slave Chip Select
    input  logic       fcb_spi_mode_en_bo,  //1'b1 : SPI Master/Slave is Enable. 1'b0
    input  logic [7:0] frfu_sfr_rd_data,  //SFR Read Data
    input  logic       frfu_cwf_full,  //Full Flag of Cfg Write FIFO
    input  logic       fmic_spi_master_en,  //1'b1: Enable SPI Master Mode, 1'b0: Ena
    //------------------------------------------------------------------------//
    //-- OUTPUT PORT                                                        --//
    //------------------------------------------------------------------------//
    output logic       fcb_spis_miso,  //SPI Slave MISO
    output logic       fcb_spis_miso_en,  //SPI Slave MISO output enable
    output logic [6:0] fssc_frfu_wr_addr,  //SFR Write Address
    output logic       fssc_frfu_wr_en,  //SFR Write Enable
    output logic [7:0] fssc_frfu_wr_data,  //SFR Write Data
    output logic       fssc_frfu_spis_on,  //SPI Slave is ON
    output logic [6:0] fssc_frfu_rd_addr,  //SFR Read Address
    output logic       fssc_frfu_rd_en,  //SFR Read Enable
    output logic [7:0] fssc_frfu_cwf_wr_data,  //Write Data of Cfg Write FIFO
    output logic       fssc_frfu_cwf_wr_en  //Write Enable to indicate the whole 32-B
);

  //------------------------------------------------------------------------//
  //-- Local Parameter                                                    --//
  //------------------------------------------------------------------------//
  localparam PAR_DLY = 1'b1;
  localparam PAR_DDY = 1'b1;

  //------------------------------------------------------------------------//
  //-- EMUN/Flops                                                         --//
  //------------------------------------------------------------------------//
  typedef enum logic [2:0] {
    MAIN_S00 = 3'b000,
    MAIN_S01 = 3'b001,
    MAIN_S02 = 3'b010,
    MAIN_S03 = 3'b011,
    MAIN_S04 = 3'b100,
    MAIN_S05 = 3'b101,
    MAIN_S06 = 3'b110,
    MAIN_S07 = 3'b111
  } EN_STATE;
  //------------------------------------------------------------------------//
  //-- Wire/Flops                                                         --//
  //------------------------------------------------------------------------//

  EN_STATE        scc_stm_cs;
  EN_STATE        scc_stm_ns;

  logic           ssc_write_pending_p;
  logic    [ 6:0] ssc_addr;
  logic    [ 7:0] ssc_wr_data;
  logic           ssc_wr_data_valid_nc;
  logic           ssc_rd_data_ack_nc;

  logic           fifo_rd_en;
  logic    [14:0] fifo_rd_data;
  logic           fifo_empty_flag_rdclk;
  logic           fifo_full_flag_wrclk_nc;

  logic           fcb_spis_cs_n_qf;

  logic    [ 7:0] frfu_sfr_rd_data_syncff1;  //SFR Read Data

  //--------------------------------------------------------------------------------//
  //-- Start Functional Description                                               --//
  //--------------------------------------------------------------------------------//
  assign fcb_spis_miso_en = fssc_frfu_spis_on;

  assign fssc_frfu_wr_addr = fifo_rd_data[14:8];
  assign fssc_frfu_wr_data = fifo_rd_data[7:0];

  assign fssc_frfu_cwf_wr_data = fifo_rd_data[7:0];

  //assign fssc_frfu_spis_on	= ( 	fcb_sys_stm 		== 1'b0 &&
  assign fssc_frfu_spis_on	= ( 	fcb_spi_mode_en_bo 	== 1'b1	&&	// JC 20170830
					fmic_spi_master_en	== 1'b0 )
				? 1'b1 : 1'b0 ;

  assign fssc_frfu_rd_addr = ssc_addr;  // Dont care power for now
  assign fssc_frfu_rd_en = 1'b0;  // Floating


  assign fcb_spis_cs_n_qf = (fssc_frfu_spis_on == 1'b1) ? fcb_spis_cs_n : 1'b1;
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      scc_stm_cs <= #PAR_DLY MAIN_S00;
    end else begin
      scc_stm_cs <= #PAR_DLY scc_stm_ns;
    end
  end
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  always_comb begin

    scc_stm_ns          = scc_stm_cs;
    fifo_rd_en          = 1'b0;
    fssc_frfu_wr_en     = 1'b0;
    fssc_frfu_cwf_wr_en = 1'b0;

    unique case (scc_stm_cs)
      MAIN_S00: begin
        if (fifo_empty_flag_rdclk == 1'b0 && fifo_rd_data[14:8] != 7'h20) begin
          scc_stm_ns = MAIN_S01;
        end else if (fifo_empty_flag_rdclk == 1'b0) begin
          scc_stm_ns = MAIN_S02;
        end
      end

      MAIN_S01: begin
        fifo_rd_en = 1'b1;
        fssc_frfu_wr_en = 1'b1;
        scc_stm_ns = MAIN_S00;
      end

      MAIN_S02: begin
        fifo_rd_en          = 1'b1;
        fssc_frfu_cwf_wr_en = 1'b1;
        scc_stm_ns          = MAIN_S00;
      end

      default: begin
        scc_stm_ns = MAIN_S00;
      end
    endcase
  end
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  always_ff @(posedge fcb_spis_clk or negedge fcb_spis_rst_n) begin
    if (fcb_spis_rst_n == 1'b0) begin
      frfu_sfr_rd_data_syncff1 <= #PAR_DLY 'b0;
    end else begin
      frfu_sfr_rd_data_syncff1 <= #PAR_DLY frfu_sfr_rd_data;
    end
  end

  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  qf_aff2 #(
      .PAR_FIFO_DATA_WIDTH(15)
  ) qf_aff2_INST (
      .fifo_wr_clk          (fcb_spis_clk),
      .fifo_wr_rst_n        (fcb_sys_rst_n),
      .fifo_rd_clk          (fcb_sys_clk),
      .fifo_rd_rst_n        (fcb_sys_rst_n),
      .fifo_wr_data         ({ssc_addr, ssc_wr_data}),
      .fifo_wr_en           (ssc_write_pending_p),
      .fifo_rd_en           (fifo_rd_en),
      //
      .fifo_rd_data         (fifo_rd_data),
      .fifo_empty_flag_rdclk(fifo_empty_flag_rdclk),
      .fifo_full_flag_wrclk (fifo_full_flag_wrclk_nc)  // Floating
  );

  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  SPI_slave SPI_slave (
      .rst_n          (fcb_sys_rst_n),
      .int_rst_n      (fcb_spis_rst_n),  // Reset by Chip Select As well
      .SPI_SCLK       (fcb_spis_clk),
      .SPI_MOSI       (fcb_spis_mosi),
      .SPI_SS         (fcb_spis_cs_n_qf),  // Qualify
      .rd_data        (frfu_sfr_rd_data_syncff1),
      // 
      .SPI_MISO       (fcb_spis_miso),
      .write_pending_p(ssc_write_pending_p),
      .addr           (ssc_addr),
      .wr_data        (ssc_wr_data),
      .wr_data_valid  (ssc_wr_data_valid_nc),  // Floating
      .rd_data_ack    (ssc_rd_data_ack_nc)  // Floating
  );

  //--------------------------------------------------------------------------------//
  //-- END                                                                        --//
  //--------------------------------------------------------------------------------//
endmodule


