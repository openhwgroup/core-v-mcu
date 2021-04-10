// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`timescale  1ns/1ps


module tb;
   parameter N_L2_BANKS = 4;
   parameter AXI_32_ID_WIDTH = 5;
   parameter AXI_32_USER_WIDTH = 6;

   parameter ADDR_MEM_WIDTH = 14;


   //AXI64
   parameter AXI64_ADDR_WIDTH  = 32;
   parameter AXI64_DATA_WIDTH  = 64;
   parameter AXI64_STRB_WIDTH  =  8;
   parameter AXI64_USER_WIDTH  =  6;
   parameter AXI64_ID_WIDTH    =  5;


   parameter AXI32_ADDR_WIDTH  = 32;
   parameter AXI32_DATA_WIDTH  = 32;
   parameter AXI32_STRB_WIDTH  =  4;
   parameter AXI32_USER_WIDTH  =  6;
   parameter AXI32_ID_WIDTH    =  5;


   parameter ADDR_WIDTH      = 32;
   parameter DATA_WIDTH      = 32;
   parameter BE_WIDTH        = 4;
   parameter AUX_WIDTH       = 5;
   parameter ID_WIDTH        = 6;

   parameter CLUST_MEM_WIDTH = 20;

   logic                          clk, rst_n;
   logic [4:0]                    fetch_enable;
   logic                          axi_fetch_enable;

    AXI_BUS
    #(
        .AXI_ADDR_WIDTH ( AXI64_ADDR_WIDTH    ),
        .AXI_DATA_WIDTH ( AXI64_DATA_WIDTH    ),
        .AXI_ID_WIDTH   ( AXI64_ID_WIDTH      ),
        .AXI_USER_WIDTH ( AXI64_USER_WIDTH    )
    )
    axi_from_cluster();

    AXI_BUS
    #(
        .AXI_ADDR_WIDTH ( AXI32_ADDR_WIDTH    ),
        .AXI_DATA_WIDTH ( AXI32_DATA_WIDTH    ),
        .AXI_ID_WIDTH   ( AXI32_ID_WIDTH      ),
        .AXI_USER_WIDTH ( AXI32_USER_WIDTH    )
    )
    axi_to_cluster();


    AXI_BUS
    #(
        .AXI_ADDR_WIDTH ( AXI64_ADDR_WIDTH    ),
        .AXI_DATA_WIDTH ( AXI64_DATA_WIDTH    ),
        .AXI_ID_WIDTH   ( AXI64_ID_WIDTH      ),
        .AXI_USER_WIDTH ( AXI64_USER_WIDTH    )
    )
    axi_post_conv();


    UNICAD_MEM_BUS_64 #( .ADDR_WIDTH(CLUST_MEM_WIDTH))    mem_link();

   APB_BUS apb_periph_bus();

   logic [N_L2_BANKS-1:0][31:0]               mem_wdata;
   logic [N_L2_BANKS-1:0][ADDR_MEM_WIDTH-1:0] mem_add;
   logic [N_L2_BANKS-1:0]                     mem_csn;
   logic [N_L2_BANKS-1:0]                     mem_wen;
   logic [N_L2_BANKS-1:0][3:0]                mem_be;
   logic [N_L2_BANKS-1:0][31:0]               mem_rdata;


   // ---------------- Master SIDE (Interleaved) --------------------------
   logic [4:0]                                data_req_TGEN;
   logic [4:0][ADDR_WIDTH-1:0]                data_add_TGEN;
   logic [4:0]                                data_wen_TGEN;
   logic [4:0][DATA_WIDTH-1:0]                data_wdata_TGEN;
   logic [4:0][BE_WIDTH-1:0]                  data_be_TGEN;
   logic [4:0][AUX_WIDTH-1:0]                 data_aux_TGEN;
   logic [4:0]                                data_gnt_TGEN;
   logic [4:0]                                data_err_TGEN;
   logic [4:0]                                data_r_valid_TGEN;
   logic [4:0][DATA_WIDTH-1:0]                data_r_rdata_TGEN;
   logic [4:0][AUX_WIDTH-1:0]                 data_r_aux_TGEN;


   logic                   EXT_req_int;
   logic [31:0]            EXT_add_int;
   logic                   EXT_wen_int;
   logic [31:0]            EXT_wdata_int;
   logic [3:0]             EXT_be_int;
   logic                   EXT_gnt_int;
   logic [8:0]             EXT_id_int;

   // RESPONSE CHANNEL
   logic                  EXT_r_valid_int;
   logic                  EXT_r_opc_int;
   logic [8:0]            EXT_r_id_int;
   logic [31:0]           EXT_r_rdata_int;


   // assign  axi_to_cluster.aw_ready  = 1'b0;
   // assign  axi_to_cluster.ar_ready  = 1'b0;
   // assign  axi_to_cluster.w_ready   = 1'b0;

   // assign  axi_to_cluster.b_id    = '0;
   // assign  axi_to_cluster.b_resp  = '0;
   // assign  axi_to_cluster.b_user  = '0;
   // assign  axi_to_cluster.b_valid = '0;

   // assign  axi_to_cluster.r_id    = '0;
   // assign  axi_to_cluster.r_user  = '0;
   // assign  axi_to_cluster.r_data  = '0;
   // assign  axi_to_cluster.r_resp  = '0;
   // assign  axi_to_cluster.r_last  = '0;
   // assign  axi_to_cluster.r_valid = '0;

   assign  apb_periph_bus.prdata   = '0;
   assign  apb_periph_bus.pready   = '0;
   assign  apb_periph_bus.pslverr  = '0;


   fc_interconnect
   #(
       .N_L2_BANKS        ( N_L2_BANKS          ),

       .AXI_32_ID_WIDTH   ( AXI32_ID_WIDTH      ),
       .AXI_32_USER_WIDTH ( AXI32_USER_WIDTH    ),
       .ADDR_L2_WIDTH     ( ADDR_MEM_WIDTH      ),

       .AXI_ADDR_WIDTH    ( AXI64_ADDR_WIDTH    ),
       .AXI_DATA_WIDTH    ( AXI64_DATA_WIDTH    ),
       .AXI_STRB_WIDTH    ( AXI64_STRB_WIDTH    ),
       .AXI_USER_WIDTH    ( AXI64_USER_WIDTH    ),
       .AXI_ID_WIDTH      ( AXI64_ID_WIDTH      )
   )
   i_fc_interconnect
   (
      .clk      ( clk                               ),
      .rst_n    ( rst_n                             ),
      .test_en_i( 1'b0                              ), // ANTONIO ATTACH ME PLEASE

      .L2_D_o   ( mem_wdata                         ),
      .L2_A_o   ( mem_add                           ),
      .L2_CEN_o ( mem_csn                           ),
      .L2_WEN_o ( mem_wen                           ),
      .L2_BE_o  ( mem_be                            ),
      .L2_Q_i   ( mem_rdata                         ),

      //RISC DATA PORT
      .FC_DATA_req_i     ( data_req_TGEN[0]       ),
      .FC_DATA_add_i     ( data_add_TGEN[0]       ),
      .FC_DATA_wen_i     ( data_wen_TGEN[0]       ),
      .FC_DATA_wdata_i   ( data_wdata_TGEN[0]     ),
      .FC_DATA_be_i      ( data_be_TGEN[0]        ),
      //.FC_DATA_aux_i   ( data_aux_TGEN[0]       ),
      .FC_DATA_gnt_o     ( data_gnt_TGEN[0]       ),
      //.FC_DATA_r_aux_o ( data_r_aux_TGEN[0]     ),
      .FC_DATA_r_valid_o ( data_r_valid_TGEN[0]   ),
      .FC_DATA_r_rdata_o ( data_r_rdata_TGEN[0]   ),
      .FC_DATA_r_opc_o   ( data_err_TGEN[0]       ),

      // RISC INSTR PORT
      .FC_INSTR_req_i     ( data_req_TGEN[1]         ),
      .FC_INSTR_add_i     ( data_add_TGEN[1]         ),
      .FC_INSTR_wen_i     ( data_wen_TGEN[1]         ),
      .FC_INSTR_wdata_i   ( data_wdata_TGEN[1]       ),
      .FC_INSTR_be_i      ( data_be_TGEN[1]          ),
      //.FC_INSTR_aux_i   ( data_aux_TGEN[1]         ),
      .FC_INSTR_gnt_o     ( data_gnt_TGEN[1]         ),
      //.FC_INSTR_r_aux_o ( data_r_aux_TGEN[1]       ),
      .FC_INSTR_r_valid_o ( data_r_valid_TGEN[1]     ),
      .FC_INSTR_r_rdata_o ( data_r_rdata_TGEN[1]     ),
      .FC_INSTR_r_opc_o   ( data_err_TGEN[1]         ),

       // UDMA TX
      .UDMA_TX_req_i     (  data_req_TGEN[2]         ),
      .UDMA_TX_add_i     (  data_add_TGEN[2]         ),
      .UDMA_TX_wen_i     (  data_wen_TGEN[2]         ),
      .UDMA_TX_wdata_i   (  data_wdata_TGEN[2]       ),
      .UDMA_TX_be_i      (  data_be_TGEN[2]          ),
      //.UDMA_TX_aux_i   (  data_aux_TGEN[2]         ),
      .UDMA_TX_gnt_o     (  data_gnt_TGEN[2]         ),
      //.UDMA_TX_r_aux_o (  data_r_aux_TGEN[2]       ),
      .UDMA_TX_r_valid_o (  data_r_valid_TGEN[2]     ),
      .UDMA_TX_r_rdata_o (  data_r_rdata_TGEN[2]     ),
      .UDMA_TX_r_opc_o   (  data_err_TGEN[2]         ),

       // UDMA RX
      .UDMA_RX_req_i     ( data_req_TGEN[3]          ),
      .UDMA_RX_add_i     ( data_add_TGEN[3]          ),
      .UDMA_RX_wen_i     ( data_wen_TGEN[3]          ),
      .UDMA_RX_wdata_i   ( data_wdata_TGEN[3]        ),
      .UDMA_RX_be_i      ( data_be_TGEN[3]           ),
      //.UDMA_RX_aux_i   ( data_aux_TGEN[3]          ),
      .UDMA_RX_gnt_o     ( data_gnt_TGEN[3]          ),
      //.UDMA_RX_r_aux_o ( data_r_aux_TGEN[3]        ),
      .UDMA_RX_r_valid_o ( data_r_valid_TGEN[3]      ),
      .UDMA_RX_r_rdata_o ( data_r_rdata_TGEN[3]      ),
      .UDMA_RX_r_opc_o   ( data_err_TGEN[3]          ),

       // DBG
      .DBG_RX_req_i     ( data_req_TGEN[4]           ),
      .DBG_RX_add_i     ( data_add_TGEN[4]           ),
      .DBG_RX_wen_i     ( data_wen_TGEN[4]           ),
      .DBG_RX_wdata_i   ( data_wdata_TGEN[4]         ),
      .DBG_RX_be_i      ( data_be_TGEN[4]            ),
      //.DBG_RX_aux_i   ( data_aux_TGEN[4]           ),
      .DBG_RX_gnt_o     ( data_gnt_TGEN[4]           ),
      //.DBG_RX_r_aux_o ( data_r_aux_TGEN[4]         ),
      .DBG_RX_r_valid_o ( data_r_valid_TGEN[4]       ),
      .DBG_RX_r_rdata_o ( data_r_rdata_TGEN[4]       ),
      .DBG_RX_r_opc_o   ( data_err_TGEN[4]           ),


      // AXI INTERFACE (FROM CLUSTER)
      .AXI_Slave_aw_addr_i   ( axi_from_cluster.aw_addr   ),
      .AXI_Slave_aw_prot_i   ( axi_from_cluster.aw_prot   ),
      .AXI_Slave_aw_region_i ( axi_from_cluster.aw_region ),
      .AXI_Slave_aw_len_i    ( axi_from_cluster.aw_len    ),
      .AXI_Slave_aw_size_i   ( axi_from_cluster.aw_size   ),
      .AXI_Slave_aw_burst_i  ( axi_from_cluster.aw_burst  ),
      .AXI_Slave_aw_lock_i   ( axi_from_cluster.aw_lock   ),
      .AXI_Slave_aw_cache_i  ( axi_from_cluster.aw_cache  ),
      .AXI_Slave_aw_qos_i    ( axi_from_cluster.aw_qos    ),
      .AXI_Slave_aw_id_i     ( axi_from_cluster.aw_id[AXI64_ID_WIDTH-1:0]     ),
      .AXI_Slave_aw_user_i   ( axi_from_cluster.aw_user[AXI64_USER_WIDTH-1:0] ),
      .AXI_Slave_aw_valid_i  ( axi_from_cluster.aw_valid  ),
      .AXI_Slave_aw_ready_o  ( axi_from_cluster.aw_ready  ),
      // ADDRESS READ CHANNEL
      .AXI_Slave_ar_addr_i   ( axi_from_cluster.ar_addr   ),
      .AXI_Slave_ar_prot_i   ( axi_from_cluster.ar_prot   ),
      .AXI_Slave_ar_region_i ( axi_from_cluster.ar_region ),
      .AXI_Slave_ar_len_i    ( axi_from_cluster.ar_len    ),
      .AXI_Slave_ar_size_i   ( axi_from_cluster.ar_size   ),
      .AXI_Slave_ar_burst_i  ( axi_from_cluster.ar_burst  ),
      .AXI_Slave_ar_lock_i   ( axi_from_cluster.ar_lock   ),
      .AXI_Slave_ar_cache_i  ( axi_from_cluster.ar_cache  ),
      .AXI_Slave_ar_qos_i    ( axi_from_cluster.ar_qos    ),
      .AXI_Slave_ar_id_i     ( axi_from_cluster.ar_id[AXI64_ID_WIDTH-1:0] ),
      .AXI_Slave_ar_user_i   ( axi_from_cluster.ar_user[AXI64_USER_WIDTH-1:0]   ),
      .AXI_Slave_ar_valid_i  ( axi_from_cluster.ar_valid  ),
      .AXI_Slave_ar_ready_o  ( axi_from_cluster.ar_ready  ),
      // WRITE CHANNEL
      .AXI_Slave_w_user_i    ( axi_from_cluster.w_user[AXI64_USER_WIDTH-1:0]    ),
      .AXI_Slave_w_data_i    ( axi_from_cluster.w_data    ),
      .AXI_Slave_w_strb_i    ( axi_from_cluster.w_strb    ),
      .AXI_Slave_w_last_i    ( axi_from_cluster.w_last    ),
      .AXI_Slave_w_valid_i   ( axi_from_cluster.w_valid   ),
      .AXI_Slave_w_ready_o   ( axi_from_cluster.w_ready   ),
       // WRITE RESPONSE CHANNEL
      .AXI_Slave_b_id_o      ( axi_from_cluster.b_id[AXI64_ID_WIDTH-1:0] ),
      .AXI_Slave_b_resp_o    ( axi_from_cluster.b_resp    ),
      .AXI_Slave_b_user_o    ( axi_from_cluster.b_user[AXI64_USER_WIDTH-1:0]    ),
      .AXI_Slave_b_valid_o   ( axi_from_cluster.b_valid   ),
      .AXI_Slave_b_ready_i   ( axi_from_cluster.b_ready   ),
       // READ CHANNEL
      .AXI_Slave_r_id_o      ( axi_from_cluster.r_id[AXI64_ID_WIDTH-1:0] ),
      .AXI_Slave_r_user_o    ( axi_from_cluster.r_user[AXI64_USER_WIDTH-1:0]    ),
      .AXI_Slave_r_data_o    ( axi_from_cluster.r_data    ),
      .AXI_Slave_r_resp_o    ( axi_from_cluster.r_resp    ),
      .AXI_Slave_r_last_o    ( axi_from_cluster.r_last    ),
      .AXI_Slave_r_valid_o   ( axi_from_cluster.r_valid   ),
      .AXI_Slave_r_ready_i   ( axi_from_cluster.r_ready   ),


       // BRIDGES
      .EXT_data_req_o        ( EXT_req_int      ),
      .EXT_data_add_o        ( EXT_add_int      ),
      .EXT_data_wen_o        ( EXT_wen_int      ),
      .EXT_data_wdata_o      ( EXT_wdata_int    ),
      .EXT_data_be_o         ( EXT_be_int       ),
      .EXT_data_ID_o         ( EXT_id_int       ),
      .EXT_data_aux_o        (                  ),
      .EXT_data_gnt_i        ( EXT_gnt_int      ),
      .EXT_data_r_rdata_i    ( EXT_r_rdata_int  ),
      .EXT_data_r_valid_i    ( EXT_r_valid_int  ),
      .EXT_data_r_ID_i       ( EXT_r_id_int     ),
      .EXT_data_r_opc_i      ( EXT_r_opc_int    ),
      .EXT_data_r_aux_i      ( '0               ),

       // LINT TO APB
      .APB_PADDR_o           ( apb_periph_bus.paddr   ),
      .APB_PWDATA_o          ( apb_periph_bus.pwdata  ),
      .APB_PWRITE_o          ( apb_periph_bus.pwrite  ),
      .APB_PSEL_o            ( apb_periph_bus.psel    ),
      .APB_PENABLE_o         ( apb_periph_bus.penable ),
      .APB_PRDATA_i          ( apb_periph_bus.prdata  ),
      .APB_PREADY_i          ( apb_periph_bus.pready  ),
      .APB_PSLVERR_i         ( apb_periph_bus.pslverr ),

      // LINT TO AXI
      // ---------------------------------------------------------
      // AXI TARG Port Declarations ------------------------------
      // ---------------------------------------------------------
      .AXI_Master_aw_addr_o   ( axi_to_cluster.aw_addr   ),
      .AXI_Master_aw_prot_o   ( axi_to_cluster.aw_prot   ),
      .AXI_Master_aw_region_o ( axi_to_cluster.aw_region ),
      .AXI_Master_aw_len_o    ( axi_to_cluster.aw_len    ),
      .AXI_Master_aw_size_o   ( axi_to_cluster.aw_size   ),
      .AXI_Master_aw_burst_o  ( axi_to_cluster.aw_burst  ),
      .AXI_Master_aw_lock_o   ( axi_to_cluster.aw_lock   ),
      .AXI_Master_aw_cache_o  ( axi_to_cluster.aw_cache  ),
      .AXI_Master_aw_qos_o    ( axi_to_cluster.aw_qos    ),
      .AXI_Master_aw_id_o     ( axi_to_cluster.aw_id     ),
      .AXI_Master_aw_user_o   ( axi_to_cluster.aw_user   ),
      .AXI_Master_aw_valid_o  ( axi_to_cluster.aw_valid  ),
      .AXI_Master_aw_ready_i  ( axi_to_cluster.aw_ready  ),
       // ADDRESS READ CHANNEL
      .AXI_Master_ar_addr_o   ( axi_to_cluster.ar_addr   ),
      .AXI_Master_ar_prot_o   ( axi_to_cluster.ar_prot   ),
      .AXI_Master_ar_region_o ( axi_to_cluster.ar_region ),
      .AXI_Master_ar_len_o    ( axi_to_cluster.ar_len    ),
      .AXI_Master_ar_size_o   ( axi_to_cluster.ar_size   ),
      .AXI_Master_ar_burst_o  ( axi_to_cluster.ar_burst  ),
      .AXI_Master_ar_lock_o   ( axi_to_cluster.ar_lock   ),
      .AXI_Master_ar_cache_o  ( axi_to_cluster.ar_cache  ),
      .AXI_Master_ar_qos_o    ( axi_to_cluster.ar_qos    ),
      .AXI_Master_ar_id_o     ( axi_to_cluster.ar_id     ),
      .AXI_Master_ar_user_o   ( axi_to_cluster.ar_user   ),
      .AXI_Master_ar_valid_o  ( axi_to_cluster.ar_valid  ),
      .AXI_Master_ar_ready_i  ( axi_to_cluster.ar_ready  ),
       // WRITE CHANNEL
      .AXI_Master_w_user_o    ( axi_to_cluster.w_user    ),
      .AXI_Master_w_data_o    ( axi_to_cluster.w_data    ),
      .AXI_Master_w_strb_o    ( axi_to_cluster.w_strb    ),
      .AXI_Master_w_last_o    ( axi_to_cluster.w_last    ),
      .AXI_Master_w_valid_o   ( axi_to_cluster.w_valid   ),
      .AXI_Master_w_ready_i   ( axi_to_cluster.w_ready   ),
       // WRITE RESPONSE CHANNEL
      .AXI_Master_b_id_i      ( axi_to_cluster.b_id      ),
      .AXI_Master_b_resp_i    ( axi_to_cluster.b_resp    ),
      .AXI_Master_b_user_i    ( axi_to_cluster.b_user    ),
      .AXI_Master_b_valid_i   ( axi_to_cluster.b_valid   ),
      .AXI_Master_b_ready_o   ( axi_to_cluster.b_ready   ),
       // READ CHANNEL
      .AXI_Master_r_id_i      ( axi_to_cluster.r_id      ),
      .AXI_Master_r_user_i    ( axi_to_cluster.r_user    ),
      .AXI_Master_r_data_i    ( axi_to_cluster.r_data    ),
      .AXI_Master_r_resp_i    ( axi_to_cluster.r_resp    ),
      .AXI_Master_r_last_i    ( axi_to_cluster.r_last    ),
      .AXI_Master_r_valid_i   ( axi_to_cluster.r_valid   ),
      .AXI_Master_r_ready_o   ( axi_to_cluster.r_ready   )
);



axi_size_conv_UPSIZE
#(
    .AXI_ADDR_WIDTH     ( AXI32_ADDR_WIDTH  ),
    .AXI_DATA_WIDTH_IN  ( AXI32_DATA_WIDTH  ),
    .AXI_USER_WIDTH_IN  ( AXI32_USER_WIDTH  ),
    .AXI_ID_WIDTH_IN    ( AXI32_ID_WIDTH    ),
    .AXI_STRB_WIDTH_IN  ( AXI32_STRB_WIDTH  ),

    .AXI_DATA_WIDTH_OUT ( AXI64_DATA_WIDTH  ),
    .AXI_USER_WIDTH_OUT ( AXI64_USER_WIDTH  ),
    .AXI_ID_WIDTH_OUT   ( AXI64_ID_WIDTH    ),
    .AXI_STRB_WIDTH_OUT ( AXI64_STRB_WIDTH  )
)
i_axi_size_conv_UPSIZE
(
    .clk_i                  ( clk   ),
    .rst_ni                 ( rst_n ),
    .test_mode_i            ( 1'b0  ),
    // AXI4 SLAVE
    //***************************************
    // WRITE ADDRESS CHANNEL
    .axi_slave_aw_valid_i   ( axi_to_cluster.aw_valid  ),
    .axi_slave_aw_addr_i    ( axi_to_cluster.aw_addr   ),
    .axi_slave_aw_prot_i    ( axi_to_cluster.aw_prot   ),
    .axi_slave_aw_region_i  ( axi_to_cluster.aw_region ),
    .axi_slave_aw_len_i     ( axi_to_cluster.aw_len    ),
    .axi_slave_aw_size_i    ( axi_to_cluster.aw_size   ),
    .axi_slave_aw_burst_i   ( axi_to_cluster.aw_burst  ),
    .axi_slave_aw_lock_i    ( axi_to_cluster.aw_lock   ),
    .axi_slave_aw_cache_i   ( axi_to_cluster.aw_cache  ),
    .axi_slave_aw_qos_i     ( axi_to_cluster.aw_qos    ),
    .axi_slave_aw_id_i      ( axi_to_cluster.aw_id     ),
    .axi_slave_aw_user_i    ( axi_to_cluster.aw_user   ),
    .axi_slave_aw_ready_o   ( axi_to_cluster.aw_ready  ),

    .axi_slave_ar_valid_i   ( axi_to_cluster.ar_valid  ),
    .axi_slave_ar_addr_i    ( axi_to_cluster.ar_addr   ),
    .axi_slave_ar_prot_i    ( axi_to_cluster.ar_prot   ),
    .axi_slave_ar_region_i  ( axi_to_cluster.ar_region ),
    .axi_slave_ar_len_i     ( axi_to_cluster.ar_len    ),
    .axi_slave_ar_size_i    ( axi_to_cluster.ar_size   ),
    .axi_slave_ar_burst_i   ( axi_to_cluster.ar_burst  ),
    .axi_slave_ar_lock_i    ( axi_to_cluster.ar_lock   ),
    .axi_slave_ar_cache_i   ( axi_to_cluster.ar_cache  ),
    .axi_slave_ar_qos_i     ( axi_to_cluster.ar_qos    ),
    .axi_slave_ar_id_i      ( axi_to_cluster.ar_id     ),
    .axi_slave_ar_user_i    ( axi_to_cluster.ar_user   ),
    .axi_slave_ar_ready_o   ( axi_to_cluster.ar_ready  ),

    .axi_slave_w_valid_i    ( axi_to_cluster.w_valid    ),
    .axi_slave_w_data_i     ( axi_to_cluster.w_data     ),
    .axi_slave_w_strb_i     ( axi_to_cluster.w_strb     ),
    .axi_slave_w_user_i     ( axi_to_cluster.w_user     ),
    .axi_slave_w_last_i     ( axi_to_cluster.w_last     ),
    .axi_slave_w_ready_o    ( axi_to_cluster.w_ready    ),

    .axi_slave_r_valid_o    ( axi_to_cluster.r_valid    ),
    .axi_slave_r_data_o     ( axi_to_cluster.r_data     ),
    .axi_slave_r_resp_o     ( axi_to_cluster.r_resp     ),
    .axi_slave_r_last_o     ( axi_to_cluster.r_last     ),
    .axi_slave_r_id_o       ( axi_to_cluster.r_id       ),
    .axi_slave_r_user_o     ( axi_to_cluster.r_user     ),
    .axi_slave_r_ready_i    ( axi_to_cluster.r_ready    ),

    .axi_slave_b_valid_o    ( axi_to_cluster.b_valid    ),
    .axi_slave_b_resp_o     ( axi_to_cluster.b_resp     ),
    .axi_slave_b_id_o       ( axi_to_cluster.b_id       ),
    .axi_slave_b_user_o     ( axi_to_cluster.b_user     ),
    .axi_slave_b_ready_i    ( axi_to_cluster.b_ready    ),



    // WRITE ADDRESS CHANNEL
    .axi_master_aw_valid_o  ( axi_post_conv.aw_valid  ),
    .axi_master_aw_addr_o   ( axi_post_conv.aw_addr   ),
    .axi_master_aw_prot_o   ( axi_post_conv.aw_prot   ),
    .axi_master_aw_region_o ( axi_post_conv.aw_region ),
    .axi_master_aw_len_o    ( axi_post_conv.aw_len    ),
    .axi_master_aw_size_o   ( axi_post_conv.aw_size   ),
    .axi_master_aw_burst_o  ( axi_post_conv.aw_burst  ),
    .axi_master_aw_lock_o   ( axi_post_conv.aw_lock   ),
    .axi_master_aw_cache_o  ( axi_post_conv.aw_cache  ),
    .axi_master_aw_qos_o    ( axi_post_conv.aw_qos    ),
    .axi_master_aw_id_o     ( axi_post_conv.aw_id     ),
    .axi_master_aw_user_o   ( axi_post_conv.aw_user   ),
    .axi_master_aw_ready_i  ( axi_post_conv.aw_ready  ),

    .axi_master_ar_valid_o  ( axi_post_conv.ar_valid  ),
    .axi_master_ar_addr_o   ( axi_post_conv.ar_addr   ),
    .axi_master_ar_prot_o   ( axi_post_conv.ar_prot   ),
    .axi_master_ar_region_o ( axi_post_conv.ar_region ),
    .axi_master_ar_len_o    ( axi_post_conv.ar_len    ),
    .axi_master_ar_size_o   ( axi_post_conv.ar_size   ),
    .axi_master_ar_burst_o  ( axi_post_conv.ar_burst  ),
    .axi_master_ar_lock_o   ( axi_post_conv.ar_lock   ),
    .axi_master_ar_cache_o  ( axi_post_conv.ar_cache  ),
    .axi_master_ar_qos_o    ( axi_post_conv.ar_qos    ),
    .axi_master_ar_id_o     ( axi_post_conv.ar_id     ),
    .axi_master_ar_user_o   ( axi_post_conv.ar_user   ),
    .axi_master_ar_ready_i  ( axi_post_conv.ar_ready  ),

    .axi_master_w_valid_o   ( axi_post_conv.w_valid   ),
    .axi_master_w_data_o    ( axi_post_conv.w_data    ),
    .axi_master_w_strb_o    ( axi_post_conv.w_strb    ),
    .axi_master_w_user_o    ( axi_post_conv.w_user    ),
    .axi_master_w_last_o    ( axi_post_conv.w_last    ),
    .axi_master_w_ready_i   ( axi_post_conv.w_ready   ),

    .axi_master_r_valid_i   ( axi_post_conv.r_valid   ),
    .axi_master_r_data_i    ( axi_post_conv.r_data    ),
    .axi_master_r_resp_i    ( axi_post_conv.r_resp    ),
    .axi_master_r_last_i    ( axi_post_conv.r_last    ),
    .axi_master_r_id_i      ( axi_post_conv.r_id      ),
    .axi_master_r_user_i    ( axi_post_conv.r_user    ),
    .axi_master_r_ready_o   ( axi_post_conv.r_ready   ),

    .axi_master_b_valid_i   ( axi_post_conv.b_valid   ),
    .axi_master_b_resp_i    ( axi_post_conv.b_resp    ),
    .axi_master_b_id_i      ( axi_post_conv.b_id      ),
    .axi_master_b_user_i    ( axi_post_conv.b_user    ),
    .axi_master_b_ready_o   ( axi_post_conv.b_ready   )
);






   axi_mem_if_wrap
   #(
       .AXI_ADDRESS_WIDTH ( AXI64_ADDR_WIDTH ),
       .AXI_DATA_WIDTH    ( AXI64_DATA_WIDTH ),
       .AXI_ID_WIDTH      ( AXI64_ID_WIDTH   ),
       .AXI_USER_WIDTH    ( AXI64_USER_WIDTH ),
       .MEM_ADDR_WIDTH    ( CLUST_MEM_WIDTH  ),
       .BUFF_DEPTH_SLAVE  ( 4                )
   )
   CLUSTER_AXI_MEM_IF
   (
       .clk_i      ( clk           ),
       .rst_ni     ( rst_n         ),
       .test_en_i  ( 1'b0          ),
       .axi_slave  ( axi_post_conv ),
       .mem_master ( mem_link      )
   );


   L2_SP_RAM
   #(
      .DATA_WIDTH ( AXI64_DATA_WIDTH   ), //= 32,
      .ADDR_WIDTH ( CLUST_MEM_WIDTH    ), //= 20,
      .BE_WIDTH   ( AXI64_DATA_WIDTH/8 ), //= DATA_WIDTH/8,
      .AUX_WIDTH  ( 1                  ), //= 4,
      .ID_WIDTH   ( 1                  )  //= 3
   )
   CLUSTER_AXI_MEM
   (
      .CLK       ( clk                 ),
      .RSTN      ( rst_n               ),
      .CEN       ( mem_link.csn        ),
      .WEN       ( mem_link.wen        ),
      .A         ( mem_link.add        ),
      .D         ( mem_link.wdata      ),
      .BE        ( mem_link.be         ),
      .Q         ( mem_link.rdata      ),
      .id_i      ( '0                  ),
      .r_id_o    (                     ),
      .aux_i     ( '0                  ),
      .r_aux_o   (                     ),
      .r_valid_o (                     )
   );

   always
   begin
      #(1.0) clk = ~clk;
   end


   initial
   begin
      rst_n = 1'b1;
      clk   = 1'b0;
      fetch_enable = '0;
      axi_fetch_enable = '0;

      @(negedge clk);
      @(negedge clk);
      @(negedge clk);

      rst_n  = 1'b0;

      @(negedge clk);
      @(negedge clk);
      @(negedge clk);

      rst_n = 1'b1;

      @(negedge clk);
      @(negedge clk);
      @(negedge clk);
      @(negedge clk);

      fetch_enable = '0;
      axi_fetch_enable = '1;

   end


   genvar i,j;
   generate

      for(i=0; i<N_L2_BANKS; i++)
      begin : MEM_CUTS
         L2_SP_RAM
         #(
            .DATA_WIDTH ( DATA_WIDTH      ), //= 32,
            .ADDR_WIDTH ( ADDR_MEM_WIDTH  ), //= 20,
            .BE_WIDTH   ( BE_WIDTH        ), //= DATA_WIDTH/8,
            .AUX_WIDTH  ( AUX_WIDTH       ), //= 4,
            .ID_WIDTH   ( ID_WIDTH        )  //= 3
         )
         MEM_CUTS
         (
            .CLK       ( clk                 ),
            .RSTN      ( rst_n               ),
            .CEN       ( mem_csn[i]          ),
            .WEN       ( mem_wen[i]          ),
            .A         ( mem_add[i]          ),
            .D         ( mem_wdata[i]        ),
            .BE        ( mem_be[i]           ),
            .Q         ( mem_rdata[i]        ),
            .id_i      ( '0                  ),
            .r_id_o    (                     ),
            .aux_i     ( '0                  ),
            .r_aux_o   (                     ),
            .r_valid_o (                     )
         );
      end



      L2_SP_RAM_STALL
      #(
         .DATA_WIDTH ( DATA_WIDTH      ), //= 32,
         .ADDR_WIDTH ( ADDR_WIDTH      ), //= 20,
         .BE_WIDTH   ( BE_WIDTH        ), //= DATA_WIDTH/8,
         .AUX_WIDTH  ( AUX_WIDTH       ), //= 4,
         .ID_WIDTH   ( 9               )  //= 3
      )
      BRIDGE
      (
         .CLK       ( clk              ),
         .RSTN      ( rst_n            ),

         .CEN       ( ~EXT_req_int     ),
         .WEN       (                  ),
         .A         (  EXT_add_int     ),
         .D         (  EXT_wdata_int   ),
         .BE        (  EXT_be_int      ),
         .Q         (  EXT_r_rdata_int ),
         .gnt_o     (  EXT_gnt_int     ),
         .r_gnt_i   (  1'b1            ),

         .id_i      ( EXT_id_int       ),
         .r_id_o    ( EXT_r_id_int     ),
         .aux_i     ( '0               ),
         .r_aux_o   (                  ),
         .r_valid_o ( EXT_r_valid_int  )
      );



      for(i=0; i<5; i++)
      begin : FC_MASTER
         TGEN_32
         #(
            .ID_WIDTH       ( ID_WIDTH    ), //10,
            .AUX_WIDTH      ( AUX_WIDTH   ), //5,
            .ADDR_WIDTH     ( ADDR_WIDTH  ), //32,
            .DATA_WIDTH     ( DATA_WIDTH  ), //32,
            .BE_WIDTH       ( BE_WIDTH    ) //DATA_WIDTH/8
         )
         FC_MASTER_i
         (
            .data_req_o      ( data_req_TGEN   [i]   ),
            .data_gnt_i      ( data_gnt_TGEN   [i]   ),
            .data_add_o      ( data_add_TGEN   [i]   ),
            .data_wen_o      ( data_wen_TGEN   [i]   ),
            .data_wdata_o    ( data_wdata_TGEN [i]   ),
            .data_be_o       ( data_be_TGEN    [i]   ),
            .data_aux_o      ( data_aux_TGEN   [i]   ),
            .data_err_i      ( data_err_TGEN   [i]   ),
            .data_r_valid_i  ( data_r_valid_TGEN [i] ),
            .data_r_rdata_i  ( data_r_rdata_TGEN [i] ),
            .data_r_aux_i    ( data_r_aux_TGEN   [i] ),

            .clk             ( clk                   ),
            .rst_n           ( rst_n                 ),

            .fetch_enable_i  ( fetch_enable[i]       )
         );
      end




      TGEN_wrap
      #(
            .AXI4_ADDRESS_WIDTH ( AXI64_ADDR_WIDTH  ), //= 32,
            .AXI4_RDATA_WIDTH   ( AXI64_DATA_WIDTH  ), //= 32,
            .AXI4_WDATA_WIDTH   ( AXI64_DATA_WIDTH  ), //= 32,
            .AXI4_ID_WIDTH      ( AXI64_ID_WIDTH    ), //= 16,
            .AXI4_USER_WIDTH    ( AXI64_USER_WIDTH  ), //= 10,
            .AXI_NUMBYTES       ( AXI64_STRB_WIDTH  ), //= AXIAXI_STRB_WIDTH  4_WDATA_WIDTH/8,
            .SRC_ID             ( '0                )  //= 0
      )
      AXI_TGEN
      (
            .clk              ( clk              ),
            .rst_n            ( rst_n            ),

            .axi_port_master  ( axi_from_cluster ),

            .fetch_en_i       ( axi_fetch_enable ),
            .eoc_o            (                  ),
            .PASS_o           (                  ),
            .FAIL_o           (                  )
      );

   endgenerate

endmodule
