// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

module fcbaps #(
    parameter [6:0] PAR_CFGDP_ADDR = 7'h20  //Convert AHB Address to Address of Cfg a
) (
    //------------------------------------------------------------------------//
    //-- INPUT PORT                                                         --//
    //------------------------------------------------------------------------//
    input  logic        fcb_sys_clk,  //Main Clock for FCB except SPI Slave Int
    input  logic        fcb_sys_rst_n,  //Main Reset for FCB except SPI Slave int
    input  logic        fcb_sys_stm,  //1'b1 : Put the module into Test Mode
    input  logic        fcb_spi_mode_en_bo,  //1'b1 : SPI Master/Slave is Enable. 1'b0
    input  logic [19:0] fcb_apbs_paddr,  //APB Address in byte Resolution. Up to 1
    input  logic [ 2:0] fcb_apbs_pprot,  //ABP PPROT, If FCB_APB_PROT_EN is 1, the
    input  logic        fcb_apbs_psel,  //APB Slave select signal
    input  logic        fcb_apbs_penable,  //APB Enable signal for data transfer
    input  logic        fcb_apbs_pwrite,  //APB write Enable Signal
    input  logic [31:0] fcb_apbs_pwdata,  //APB Write Data
    input  logic [ 3:0] fcb_apbs_pstrb,  //APB Byte Enable.
    input  logic        fcb_apbs_prot_en_bo,  //If 1, this APB slave can only be access
    input  logic        frwf_wff_full,  //Full Flag of Write FIFO
    input  logic        frwf_wff_full_m1,  //Full minus one Flag of Write FIFO
    input  logic        frwf_crf_empty,  //Empty Flag of Cfg Read FIFO
    input  logic        frwf_crf_empty_p1,  //Empty plus 1 Flag of Cfg Read FIFO
    input  logic [31:0] frwf_crf_rd_data,  //Cfg Read FIFO Data
    //------------------------------------------------------------------------//
    //-- OUTPUT PORT                                                        --//
    //------------------------------------------------------------------------//
    output logic        fcb_apbs_pready,  //APB Slave Ready Signal
    output logic [31:0] fcb_apbs_prdata,  //APB READ Data
    output logic        fcb_apbs_pslverr,  //ABP Error Response
    output logic        faps_frwf_apb_on,  //APB Path is ON
    output logic [39:0] faps_frwf_wff_wr_data,  //Bit 31:0 : Write Data, Bit 38:32 : SFR
    output logic        faps_frwf_wff_wr_en,  //Write Enable of Write FIFO
    output logic        faps_frwf_crf_rd_en  //Read Enable of Cfg Read FIFO
);

  //------------------------------------------------------------------------//
  //-- Local Parameter                                                    --//
  //------------------------------------------------------------------------//
  localparam PAR_DLY = 1'b1;

  //------------------------------------------------------------------------//
  //-- EMUN/Flops                                                         --//
  //------------------------------------------------------------------------//
  typedef enum logic [3:0] {
    MAIN_S00 = 4'h0,
    MAIN_S01 = 4'h1,
    MAIN_S02 = 4'h2,
    MAIN_S03 = 4'h3,
    MAIN_S04 = 4'h4,
    MAIN_S05 = 4'h5,
    MAIN_S06 = 4'h6,
    MAIN_S07 = 4'h7
  } EN_STATE;

  //------------------------------------------------------------------------//
  //-- Wire/Flops                                                         --//
  //------------------------------------------------------------------------//
  EN_STATE apbs_stm_cs;
  EN_STATE apbs_stm_ns;

  logic    fcb_apbs_pready_cs;
  logic    fcb_apbs_pready_ns;

  logic    apbs_wff_wr_en;

  //logic [7:0]    		apb_address_cs ; 
  //logic [7:0]    		apb_address_ns ; 

  //--------------------------------------------------------------------------------//
  //-- Start Functional Description                                               --//
  //--------------------------------------------------------------------------------//
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  assign fcb_apbs_pready = fcb_apbs_pready_cs;

  assign fcb_apbs_prdata = frwf_crf_rd_data;

  assign fcb_apbs_pslverr = 1'b0;

  assign faps_frwf_apb_on = (fcb_spi_mode_en_bo == 1'b0) ? 1'b1 : 1'b0;
  //assign faps_frwf_apb_on 	= 1'b1 ; 	// JC 20170830

  assign faps_frwf_wff_wr_en 	= ( fcb_apbs_pready_cs & fcb_apbs_penable & fcb_apbs_psel & fcb_apbs_pwrite ) | apbs_wff_wr_en ;

  assign faps_frwf_crf_rd_en 	= fcb_apbs_pready_cs & fcb_apbs_penable & fcb_apbs_psel & (~fcb_apbs_pwrite) ;


  always_comb begin
    if (apbs_wff_wr_en == 1'b1) begin
      faps_frwf_wff_wr_data[39] = 1'b0;  //SFR READ
      faps_frwf_wff_wr_data[38:32] = fcb_apbs_paddr[8:2];
      faps_frwf_wff_wr_data[31:0] = 'b0;
    end else if (faps_frwf_wff_wr_en == 1'b1 && fcb_apbs_paddr[19:9] == 'b0) begin
      faps_frwf_wff_wr_data[39] = 1'b1;  //SFR WRITE
      faps_frwf_wff_wr_data[38:32] = fcb_apbs_paddr[8:2];
      faps_frwf_wff_wr_data[31:0] = fcb_apbs_pwdata;
    end
  else if ( faps_frwf_wff_wr_en == 1'b1 && ( fcb_apbs_paddr[19:9] != 'b0 || fcb_apbs_paddr[8:2] == 7'h20 )) //CFG WRITE 1128
    begin
      faps_frwf_wff_wr_data[39] = 1'b1;
      faps_frwf_wff_wr_data[38:32] = 7'h20;
      faps_frwf_wff_wr_data[31:0] = fcb_apbs_pwdata;
    end else begin
      faps_frwf_wff_wr_data[39] = 'b0;
      faps_frwf_wff_wr_data[38:32] = 'b0;
      faps_frwf_wff_wr_data[31:0] = 'b0;
    end
  end
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      fcb_apbs_pready_cs <= #PAR_DLY 'b0;
      //apb_address_cs		<= #PAR_DLY 'b0 ;	
      apbs_stm_cs <= #PAR_DLY MAIN_S00;
    end else begin
      fcb_apbs_pready_cs <= #PAR_DLY fcb_apbs_pready_ns;
      //apb_address_cs		<= #PAR_DLY apb_address_ns ;	
      apbs_stm_cs <= #PAR_DLY apbs_stm_ns;
    end
  end
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  always_comb begin
    apbs_wff_wr_en = 1'b0;
    fcb_apbs_pready_ns = fcb_apbs_pready_cs;
    //apb_address_ns	= apb_address_cs ;	
    apbs_stm_ns = apbs_stm_cs;

    unique case (apbs_stm_cs)
      MAIN_S00: begin
        //if ( fcb_sys_stm == 1'b0 && fcb_spi_mode_en_bo == 1'b0 )
        //  begin
        //    apbs_stm_ns = MAIN_S01 ;
        //  end
        //else
        //  begin
        //    apbs_stm_ns = apbs_stm_cs ;
        //  end
        apbs_stm_ns = MAIN_S01;  // JC 20170830
      end

      MAIN_S01: begin
        if (fcb_apbs_psel == 1'b1 && fcb_apbs_pwrite == 1'b1) begin
          if (frwf_wff_full == 1'b1) begin
            apbs_stm_ns = apbs_stm_cs;
          end else begin
            apbs_stm_ns = MAIN_S02;
            fcb_apbs_pready_ns = 1'b1;
          end
        end
	else if ( fcb_apbs_psel == 1'b1 && fcb_apbs_pwrite == 1'b0 && ( fcb_apbs_paddr[19:9] != 'b0 || fcb_apbs_paddr[8:2] == 7'h20 )) // Read Cfg
	  begin
          if (frwf_crf_empty == 1'b1) begin
            apbs_stm_ns = apbs_stm_cs;
          end else begin
            fcb_apbs_pready_ns = 1'b1;
            apbs_stm_ns = MAIN_S03;
          end
        end
	else if ( fcb_apbs_psel == 1'b1 && fcb_apbs_pwrite == 1'b0 && fcb_apbs_paddr[19:9] == 'b0 ) // Read SFR
          begin
          apbs_wff_wr_en = 1'b1;
          apbs_stm_ns    = MAIN_S04;
        end else begin
          apbs_stm_ns = apbs_stm_cs;
        end
      end

      MAIN_S02: begin
        apbs_stm_ns        = MAIN_S01;
        fcb_apbs_pready_ns = 1'b0;
      end

      MAIN_S03: begin
        apbs_stm_ns        = MAIN_S01;
        fcb_apbs_pready_ns = 1'b0;
      end

      MAIN_S04: begin
        if (frwf_crf_empty == 1'b1) begin
          apbs_stm_ns = apbs_stm_cs;
        end else begin
          fcb_apbs_pready_ns = 1'b1;
          apbs_stm_ns        = MAIN_S03;
        end
      end

      default: begin
        apbs_stm_ns = MAIN_S01;
      end
    endcase
  end
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  //--------------------------------------------------------------------------------//
  //-- END                                                                        --//
  //--------------------------------------------------------------------------------//
endmodule


