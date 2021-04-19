// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

module qf_aff2 #(
    parameter PAR_FIFO_DATA_WIDTH = 32
) (
    //------------------------------------------------------------------------//
    //-- INPUT PORT                                                         --//
    //------------------------------------------------------------------------//
    input  logic                           fifo_wr_clk,
    input  logic                           fifo_wr_rst_n,
    input  logic                           fifo_rd_clk,
    input  logic                           fifo_rd_rst_n,
    input  logic [PAR_FIFO_DATA_WIDTH-1:0] fifo_wr_data,
    input  logic                           fifo_wr_en,
    input  logic                           fifo_rd_en,
    //------------------------------------------------------------------------//
    //-- OUTPUT PORT                                                        --//
    //------------------------------------------------------------------------//
    output logic [PAR_FIFO_DATA_WIDTH-1:0] fifo_rd_data,
    output logic                           fifo_empty_flag_rdclk,
    output logic                           fifo_full_flag_wrclk
);

  //------------------------------------------------------------------------//
  //-- Local Parameter                                                    --//
  //------------------------------------------------------------------------//
  localparam PAR_DLY = 1'b1;

  //------------------------------------------------------------------------//
  //-- EMUN/Flops                                                         --//
  //------------------------------------------------------------------------//

  //------------------------------------------------------------------------//
  //-- Wire/Flops                                                         --//
  //------------------------------------------------------------------------//
  logic [1:0] fifo_wr_ptr_cs;
  logic [1:0] fifo_wr_ptr_ns;
  logic [1:0] fifo_rd_ptr_cs;
  logic [1:0] fifo_rd_ptr_ns;
  logic [1:0] fifo_wr_ptr_rdclk;
  logic [1:0] fifo_rd_ptr_wrclk;

  //--------------------------------------------------------------------------------//
  //-- Start Functional Description                                               --//
  //--------------------------------------------------------------------------------//
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  always_comb begin
    if ( ( fifo_wr_ptr_cs[1] != fifo_rd_ptr_wrclk[1] ) &&
       ( fifo_wr_ptr_cs[0] != fifo_rd_ptr_wrclk[0] )  )
    begin
      fifo_full_flag_wrclk = 1'b1;
    end else begin
      fifo_full_flag_wrclk = 1'b0;
    end

    if ( ( fifo_rd_ptr_cs[1] == fifo_wr_ptr_rdclk[1] ) &&
       ( fifo_rd_ptr_cs[0] == fifo_wr_ptr_rdclk[0] )  )
    begin
      fifo_empty_flag_rdclk = 1'b1;
    end else begin
      fifo_empty_flag_rdclk = 1'b0;
    end
  end

  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  qf_dff #(
      .PAR_DFF_WIDTH(2)
  ) qf_dff_w2r_INST (
      .dest_clk  (fifo_rd_clk),
      .dest_rst_n(fifo_rd_rst_n),
      .org_data  (fifo_wr_ptr_cs),
      .dest_data (fifo_wr_ptr_rdclk)
  );

  always_ff @(negedge fifo_wr_clk or negedge fifo_wr_rst_n) begin
    if (fifo_wr_rst_n == 1'b0) begin
      fifo_wr_ptr_cs <= #PAR_DLY 2'b00;
    end else begin
      if (fifo_wr_en == 1'b1) begin
        fifo_wr_ptr_cs <= #PAR_DLY fifo_wr_ptr_ns;
      end
    end
  end
  always_comb begin
    unique case (fifo_wr_ptr_cs)
      2'b00: begin
        fifo_wr_ptr_ns = 2'b01;
      end
      2'b01: begin
        fifo_wr_ptr_ns = 2'b11;
      end
      2'b11: begin
        fifo_wr_ptr_ns = 2'b10;
      end
      2'b10: begin
        fifo_wr_ptr_ns = 2'b00;
      end
      default: begin
        fifo_wr_ptr_ns = 2'b00;
      end
    endcase
  end
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  qf_dff #(
      .PAR_DFF_WIDTH(2)
  ) qf_dff_r2w_INST (
      .dest_clk  (fifo_wr_clk),
      .dest_rst_n(fifo_wr_rst_n),
      .org_data  (fifo_rd_ptr_cs),
      .dest_data (fifo_rd_ptr_wrclk)
  );

  always_ff @(posedge fifo_rd_clk or negedge fifo_rd_rst_n) begin
    if (fifo_rd_rst_n == 1'b0) begin
      fifo_rd_ptr_cs <= #PAR_DLY 2'b00;
    end else begin
      if (fifo_rd_en == 1'b1) begin
        fifo_rd_ptr_cs <= #PAR_DLY fifo_rd_ptr_ns;
      end
    end
  end

  always_comb begin
    unique case (fifo_rd_ptr_cs)
      2'b00: begin
        fifo_rd_ptr_ns = 2'b01;
      end
      2'b01: begin
        fifo_rd_ptr_ns = 2'b11;
      end
      2'b11: begin
        fifo_rd_ptr_ns = 2'b10;
      end
      2'b10: begin
        fifo_rd_ptr_ns = 2'b00;
      end
      default: begin
        fifo_rd_ptr_ns = 2'b00;
      end
    endcase
  end

  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  qf_rfm_f #(
      .PAR_MEMORY_WIDTH_BIT(PAR_FIFO_DATA_WIDTH),
      .PAR_MEMORY_DEPTH_BIT(1)
  ) qf_rfm_f_INST (
      .rfm_clk    (fifo_wr_clk),
      .rfm_wr_en  (fifo_wr_en),
      .rfm_wr_addr(fifo_wr_ptr_cs[1] ^ fifo_wr_ptr_cs[0]),
      .rfm_wr_data(fifo_wr_data),
      .rfm_rd_addr(fifo_rd_ptr_cs[1] ^ fifo_rd_ptr_cs[0]),
      .rfm_rd_data(fifo_rd_data)
  );

  //--------------------------------------------------------------------------------//
  //-- END                                                                        --//
  //--------------------------------------------------------------------------------//
endmodule


