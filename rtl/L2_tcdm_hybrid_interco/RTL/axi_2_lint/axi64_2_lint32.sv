// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module axi64_2_lint32
#(
   parameter AXI_ADDR_WIDTH        = 32,
   parameter AXI_DATA_WIDTH        = 64,
   parameter AXI_STRB_WIDTH        = 8,
   parameter AXI_USER_WIDTH        = 6,
   parameter AXI_ID_WIDTH          = 7,

   parameter BUFF_DEPTH_SLICES     = 4,

   parameter DATA_WIDTH            = 32,
   parameter BE_WIDTH              = DATA_WIDTH/8,
   parameter ADDR_WIDTH            = 32,
   parameter AUX_WIDTH             = 4
)
(
   // AXI GLOBAL SIGNALS
   input  logic                               clk,
   input  logic                               rst_n,
   input  logic                               test_en_i,

   // AXI INTERFACE
   input  logic [AXI_ADDR_WIDTH-1:0]          AW_ADDR_i,
   input  logic [2:0]                         AW_PROT_i,
   input  logic [3:0]                         AW_REGION_i,
   input  logic [7:0]                         AW_LEN_i,
   input  logic [2:0]                         AW_SIZE_i,
   input  logic [1:0]                         AW_BURST_i,
   input  logic                               AW_LOCK_i,
   input  logic [3:0]                         AW_CACHE_i,
   input  logic [3:0]                         AW_QOS_i,
   input  logic [AXI_ID_WIDTH-1:0]            AW_ID_i,
   input  logic [AXI_USER_WIDTH-1:0]          AW_USER_i,
   input  logic                               AW_VALID_i,
   output logic                               AW_READY_o,
   // ADDRESS READ CHANNEL
   input  logic [AXI_ADDR_WIDTH-1:0]          AR_ADDR_i,
   input  logic [2:0]                         AR_PROT_i,
   input  logic [3:0]                         AR_REGION_i,
   input  logic [7:0]                         AR_LEN_i,
   input  logic [2:0]                         AR_SIZE_i,
   input  logic [1:0]                         AR_BURST_i,
   input  logic                               AR_LOCK_i,
   input  logic [3:0]                         AR_CACHE_i,
   input  logic [3:0]                         AR_QOS_i,
   input  logic [AXI_ID_WIDTH-1:0]            AR_ID_i,
   input  logic [AXI_USER_WIDTH-1:0]          AR_USER_i,
   input  logic                               AR_VALID_i,
   output logic                               AR_READY_o,
   // WRITE CHANNEL
   input  logic [AXI_USER_WIDTH-1:0]          W_USER_i,
   input  logic [AXI_DATA_WIDTH-1:0]          W_DATA_i,
   input  logic [AXI_STRB_WIDTH-1:0]          W_STRB_i,
   input  logic                               W_LAST_i,
   input  logic                               W_VALID_i,
   output logic                               W_READY_o,
   // WRITE RESPONSE CHANNEL
   output logic [AXI_ID_WIDTH-1:0]            B_ID_o,
   output logic [1:0]                         B_RESP_o,
   output logic [AXI_USER_WIDTH-1:0]          B_USER_o,
   output logic                               B_VALID_o,
   input  logic                               B_READY_i,
   // READ CHANNEL
   output logic [AXI_ID_WIDTH-1:0]            R_ID_o,
   output logic [AXI_USER_WIDTH-1:0]          R_USER_o,
   output logic [AXI_DATA_WIDTH-1:0]          R_DATA_o,
   output logic [1:0]                         R_RESP_o,
   output logic                               R_LAST_o,
   output logic                               R_VALID_o,
   input  logic                               R_READY_i,

   // LINT Interface - WRITE Request
   output logic [1:0]                         data_W_req_o,
   input  logic [1:0]                         data_W_gnt_i,
   output logic [1:0][DATA_WIDTH-1:0]         data_W_wdata_o,
   output logic [1:0][ADDR_WIDTH-1:0]         data_W_add_o,
   output logic [1:0]                         data_W_wen_o,
   output logic [1:0][BE_WIDTH-1:0]           data_W_be_o,
   output logic [1:0][AUX_WIDTH-1:0]          data_W_aux_o,  // FIXME : not used now,


   // LINT Interface - Response
   input  logic [1:0]                         data_W_r_valid_i,
   input  logic [1:0][DATA_WIDTH-1:0]         data_W_r_rdata_i,
   input  logic [1:0][AUX_WIDTH-1:0]          data_W_r_aux_i,     // FIXME : not used now,
   input  logic [1:0]                         data_W_r_opc_i,    // FIXME : not used now,

   // LINT Interface - READ Request
   output logic [1:0]                         data_R_req_o,
   input  logic [1:0]                         data_R_gnt_i,
   output logic [1:0][DATA_WIDTH-1:0]         data_R_wdata_o,
   output logic [1:0][ADDR_WIDTH-1:0]         data_R_add_o,
   output logic [1:0]                         data_R_wen_o,
   output logic [1:0][BE_WIDTH-1:0]           data_R_be_o,
   output logic [1:0][AUX_WIDTH-1:0]          data_R_aux_o,    // FIXME : not used now,

   // LINT Interface - Response
   input  logic [1:0]                         data_R_r_valid_i,
   input  logic [1:0][DATA_WIDTH-1:0]         data_R_r_rdata_i,
   input  logic [1:0][AUX_WIDTH-1:0]          data_R_r_aux_i,  // FIXME : not used now,
   input  logic [1:0]                         data_R_r_opc_i    // FIXME : not used now,
);

   localparam ADDR_OFFSET           = $clog2(DATA_WIDTH)-3;


   // Signals From the AXI SLICES to AXI to LINT BRIDGES
   // AXI INTERFACE
   logic [AXI_ADDR_WIDTH-1:0]          AW_ADDR_int;
   logic [2:0]                         AW_PROT_int;
   logic [3:0]                         AW_REGION_int;
   logic [7:0]                         AW_LEN_int;
   logic [2:0]                         AW_SIZE_int;
   logic [1:0]                         AW_BURST_int;
   logic                               AW_LOCK_int;
   logic [3:0]                         AW_CACHE_int;
   logic [3:0]                         AW_QOS_int;
   logic [AXI_ID_WIDTH-1:0]            AW_ID_int;
   logic [AXI_USER_WIDTH-1:0]          AW_USER_int;
   logic                               AW_VALID_int;
   logic                               AW_READY_int;
   // ADDRESS READ CHANNEL
   logic [AXI_ADDR_WIDTH-1:0]          AR_ADDR_int;
   logic [2:0]                         AR_PROT_int;
   logic [3:0]                         AR_REGION_int;
   logic [7:0]                         AR_LEN_int;
   logic [2:0]                         AR_SIZE_int;
   logic [1:0]                         AR_BURST_int;
   logic                               AR_LOCK_int;
   logic [3:0]                         AR_CACHE_int;
   logic [3:0]                         AR_QOS_int;
   logic [AXI_ID_WIDTH-1:0]            AR_ID_int;
   logic [AXI_USER_WIDTH-1:0]          AR_USER_int;
   logic                               AR_VALID_int;
   logic                               AR_READY_int;
   // WRITE CHANNEL
   logic [AXI_USER_WIDTH-1:0]          W_USER_int;
   logic [AXI_DATA_WIDTH-1:0]          W_DATA_int;
   logic [AXI_STRB_WIDTH-1:0]          W_STRB_int;
   logic                               W_LAST_int;
   logic                               W_VALID_int;
   logic                               W_READY_int;
   // BACKWARD WRITE CHANNEL
   logic [AXI_ID_WIDTH-1:0]            B_ID_int;
   logic [1:0]                         B_RESP_int;
   logic [AXI_USER_WIDTH-1:0]          B_USER_int;
   logic                               B_VALID_int;
   logic                               B_READY_int;
   // READ CHANNEL
   logic [AXI_ID_WIDTH-1:0]            R_ID_int;
   logic [AXI_USER_WIDTH-1:0]          R_USER_int;
   logic [AXI_DATA_WIDTH-1:0]          R_DATA_int;
   logic [1:0]                         R_RESP_int;
   logic                               R_LAST_int;
   logic                               R_VALID_int;
   logic                               R_READY_int;


   logic                               data_W_req_int;
   logic                               data_W_gnt_int;
   logic [63:0]                        data_W_wdata_int;
   logic [31:0]                        data_W_add_int;
   logic                               data_W_wen_int;
   logic [7:0]                         data_W_be_int;
   logic                               data_W_r_valid_int;
   logic [63:0]                        data_W_r_rdata_int;

   logic                               data_R_req_int;
   logic                               data_R_gnt_int;
   logic [63:0]                        data_R_wdata_int;
   logic [31:0]                        data_R_add_int;
   logic                               data_R_wen_int;
   logic [7:0]                         data_R_be_int;
   logic                               data_R_r_valid_int;
   logic [63:0]                        data_R_r_rdata_int;


   assign data_R_aux_o = '0;
   assign data_W_aux_o = '0;

   ///////////////////////////////////////////////////////////////////
   //  █████╗ ██╗    ██╗        ███████╗██╗     ██╗ ██████╗███████╗ //
   // ██╔══██╗██║    ██║        ██╔════╝██║     ██║██╔════╝██╔════╝ //
   // ███████║██║ █╗ ██║        ███████╗██║     ██║██║     █████╗   //
   // ██╔══██║██║███╗██║        ╚════██║██║     ██║██║     ██╔══╝   //
   // ██║  ██║╚███╔███╔╝███████╗███████║███████╗██║╚██████╗███████╗ //
   // ╚═╝  ╚═╝ ╚══╝╚══╝ ╚══════╝╚══════╝╚══════╝╚═╝ ╚═════╝╚══════╝ //
   // AXI WRITE ADDRESS CHANNEL BUFFER ///////////////////////////////
   axi_aw_buffer
   #(
       .ID_WIDTH     ( AXI_ID_WIDTH       ),
       .ADDR_WIDTH   ( AXI_ADDR_WIDTH     ),
       .USER_WIDTH   ( AXI_USER_WIDTH     ),
       .BUFFER_DEPTH ( BUFF_DEPTH_SLICES  )
   )
   Slave_aw_buffer
   (
      .clk_i           ( clk           ),
      .rst_ni          ( rst_n         ),
      .test_en_i       ( test_en_i     ),

      .slave_valid_i   ( AW_VALID_i    ),
      .slave_addr_i    ( AW_ADDR_i     ),
      .slave_prot_i    ( AW_PROT_i     ),
      .slave_region_i  ( AW_REGION_i   ),
      .slave_len_i     ( AW_LEN_i      ),
      .slave_size_i    ( AW_SIZE_i     ),
      .slave_burst_i   ( AW_BURST_i    ),
      .slave_lock_i    ( AW_LOCK_i     ),
      .slave_cache_i   ( AW_CACHE_i    ),
      .slave_qos_i     ( AW_QOS_i      ),
      .slave_id_i      ( AW_ID_i       ),
      .slave_user_i    ( AW_USER_i     ),
      .slave_ready_o   ( AW_READY_o    ),

      .master_valid_o  ( AW_VALID_int  ),
      .master_addr_o   ( AW_ADDR_int   ),
      .master_prot_o   ( AW_PROT_int   ),
      .master_region_o ( AW_REGION_int ),
      .master_len_o    ( AW_LEN_int    ),
      .master_size_o   ( AW_SIZE_int   ),
      .master_burst_o  ( AW_BURST_int  ),
      .master_lock_o   ( AW_LOCK_int   ),
      .master_cache_o  ( AW_CACHE_int  ),
      .master_qos_o    ( AW_QOS_int    ),
      .master_id_o     ( AW_ID_int     ),
      .master_user_o   ( AW_USER_int   ),
      .master_ready_i  ( AW_READY_int  )
   );

   /////////////////////////////////////////////////////////////////
   //  █████╗ ██████╗         ███████╗██╗     ██╗ ██████╗███████╗ //
   // ██╔══██╗██╔══██╗        ██╔════╝██║     ██║██╔════╝██╔════╝ //
   // ███████║██████╔╝        ███████╗██║     ██║██║     █████╗   //
   // ██╔══██║██╔══██╗        ╚════██║██║     ██║██║     ██╔══╝   //
   // ██║  ██║██║  ██║███████╗███████║███████╗██║╚██████╗███████╗ //
   // ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝ ╚═════╝╚══════╝ //
   // AXI READ  ADDRESS CHANNEL BUFFER /////////////////////////////
   axi_ar_buffer
   #(
       .ID_WIDTH     ( AXI_ID_WIDTH     ),
       .ADDR_WIDTH   ( AXI_ADDR_WIDTH   ),
       .USER_WIDTH   ( AXI_USER_WIDTH   ),
       .BUFFER_DEPTH ( BUFF_DEPTH_SLICES)
   )
   Slave_ar_buffer
   (
      .clk_i           ( clk            ),
      .rst_ni          ( rst_n          ),
      .test_en_i       ( test_en_i      ),

      .slave_valid_i   ( AR_VALID_i     ),
      .slave_addr_i    ( AR_ADDR_i      ),
      .slave_prot_i    ( AR_PROT_i      ),
      .slave_region_i  ( AR_REGION_i    ),
      .slave_len_i     ( AR_LEN_i       ),
      .slave_size_i    ( AR_SIZE_i      ),
      .slave_burst_i   ( AR_BURST_i     ),
      .slave_lock_i    ( AR_LOCK_i      ),
      .slave_cache_i   ( AR_CACHE_i     ),
      .slave_qos_i     ( AR_QOS_i       ),
      .slave_id_i      ( AR_ID_i        ),
      .slave_user_i    ( AR_USER_i      ),
      .slave_ready_o   ( AR_READY_o     ),

      .master_valid_o  ( AR_VALID_int   ),
      .master_addr_o   ( AR_ADDR_int    ),
      .master_prot_o   ( AR_PROT_int    ),
      .master_region_o ( AR_REGION_int  ),
      .master_len_o    ( AR_LEN_int     ),
      .master_size_o   ( AR_SIZE_int    ),
      .master_burst_o  ( AR_BURST_int   ),
      .master_lock_o   ( AR_LOCK_int    ),
      .master_cache_o  ( AR_CACHE_int   ),
      .master_qos_o    ( AR_QOS_int     ),
      .master_id_o     ( AR_ID_int      ),
      .master_user_o   ( AR_USER_int    ),
      .master_ready_i  ( AR_READY_int   )
   );

   ///////////////////////////////////////////////////////////
   // ██╗    ██╗        ███████╗██╗     ██╗ ██████╗███████╗ //
   // ██║    ██║        ██╔════╝██║     ██║██╔════╝██╔════╝ //
   // ██║ █╗ ██║        ███████╗██║     ██║██║     █████╗   //
   // ██║███╗██║        ╚════██║██║     ██║██║     ██╔══╝   //
   // ╚███╔███╔╝███████╗███████║███████╗██║╚██████╗███████╗ //
   //  ╚══╝╚══╝ ╚══════╝╚══════╝╚══════╝╚═╝ ╚═════╝╚══════╝ //
   // AXI WRITE CHANNEL BUFFER ///////////////////////////////
   axi_w_buffer
   #(
      .DATA_WIDTH      ( AXI_DATA_WIDTH   ),
      .USER_WIDTH      ( AXI_USER_WIDTH   ),
      .BUFFER_DEPTH    ( BUFF_DEPTH_SLICES)
   )
   Slave_w_buffer
   (
      .clk_i          ( clk        ),
      .rst_ni         ( rst_n      ),
      .test_en_i      ( test_en_i  ),

      .slave_valid_i  ( W_VALID_i  ),
      .slave_data_i   ( W_DATA_i   ),
      .slave_strb_i   ( W_STRB_i   ),
      .slave_user_i   ( W_USER_i   ),
      .slave_last_i   ( W_LAST_i   ),
      .slave_ready_o  ( W_READY_o  ),

      .master_valid_o ( W_VALID_int ),
      .master_data_o  ( W_DATA_int  ),
      .master_strb_o  ( W_STRB_int  ),
      .master_user_o  ( W_USER_int  ),
      .master_last_o  ( W_LAST_int  ),
      .master_ready_i ( W_READY_int )
   );

   // ██████╗         ███████╗██╗     ██╗ ██████╗███████╗
   // ██╔══██╗        ██╔════╝██║     ██║██╔════╝██╔════╝
   // ██████╔╝        ███████╗██║     ██║██║     █████╗
   // ██╔══██╗        ╚════██║██║     ██║██║     ██╔══╝
   // ██║  ██║███████╗███████║███████╗██║╚██████╗███████╗
   // ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝ ╚═════╝╚══════╝
   axi_r_buffer
   #(
      .ID_WIDTH     ( AXI_ID_WIDTH      ),
      .DATA_WIDTH   ( AXI_DATA_WIDTH    ),
      .USER_WIDTH   ( AXI_USER_WIDTH    ),
      .BUFFER_DEPTH ( BUFF_DEPTH_SLICES )
   )
   Slave_r_buffer
   (
      .clk_i          ( clk         ),
      .rst_ni         ( rst_n       ),
      .test_en_i      ( test_en_i   ),

      .slave_valid_i  ( R_VALID_int ),
      .slave_data_i   ( R_DATA_int  ),
      .slave_resp_i   ( R_RESP_int  ),
      .slave_user_i   ( R_USER_int  ),
      .slave_id_i     ( R_ID_int    ),
      .slave_last_i   ( R_LAST_int  ),
      .slave_ready_o  ( R_READY_int ),

      .master_valid_o ( R_VALID_o   ),
      .master_data_o  ( R_DATA_o    ),
      .master_resp_o  ( R_RESP_o    ),
      .master_user_o  ( R_USER_o    ),
      .master_id_o    ( R_ID_o      ),
      .master_last_o  ( R_LAST_o    ),
      .master_ready_i ( R_READY_i   )
   );


   // ██████╗         ███████╗██╗     ██╗ ██████╗███████╗
   // ██╔══██╗        ██╔════╝██║     ██║██╔════╝██╔════╝
   // ██████╔╝        ███████╗██║     ██║██║     █████╗
   // ██╔══██╗        ╚════██║██║     ██║██║     ██╔══╝
   // ██████╔╝███████╗███████║███████╗██║╚██████╗███████╗
   // ╚═════╝ ╚══════╝╚══════╝╚══════╝╚═╝ ╚═════╝╚══════╝
   axi_b_buffer
   #(
        .ID_WIDTH       ( AXI_ID_WIDTH      ),
        .USER_WIDTH     ( AXI_USER_WIDTH    ),
        .BUFFER_DEPTH   ( BUFF_DEPTH_SLICES )
   )
   Slave_b_buffer
   (
        .clk_i          ( clk              ),
        .rst_ni         ( rst_n            ),
        .test_en_i      ( test_en_i        ),

        .slave_valid_i  ( B_VALID_int      ),
        .slave_resp_i   ( B_RESP_int       ),
        .slave_id_i     ( B_ID_int         ),
        .slave_user_i   ( B_USER_int       ),
        .slave_ready_o  ( B_READY_int      ),

        .master_valid_o ( B_VALID_o         ),
        .master_resp_o  ( B_RESP_o          ),
        .master_id_o    ( B_ID_o            ),
        .master_user_o  ( B_USER_o          ),
        .master_ready_i ( B_READY_i         )
   );


logic data_W_size_int, data_R_size_int;


   axi_write_ctrl
   #(
       .AXI4_ADDRESS_WIDTH (AXI_ADDR_WIDTH ), //= 32,
       .AXI4_RDATA_WIDTH   (AXI_DATA_WIDTH ), //= 64,
       .AXI4_WDATA_WIDTH   (AXI_DATA_WIDTH ), //= 64,
       .AXI4_ID_WIDTH      (AXI_ID_WIDTH   ), //= 16,
       .AXI4_USER_WIDTH    (AXI_USER_WIDTH ), //= 10,
       .AXI_NUMBYTES       (AXI_STRB_WIDTH ), //= AXI4_WDATA_WIDTH/8,
       .MEM_ADDR_WIDTH     (ADDR_WIDTH     ) //= 13
   )
   i_axi_write_ctrl
   (
      .clk        (clk),
      .rst_n      (rst_n),

      //AXI Write address bus -------------------------------------
      .AWID_i     ( AW_ID_int     ),
      .AWADDR_i   ( AW_ADDR_int   ),
      .AWLEN_i    ( AW_LEN_int    ),
      .AWSIZE_i   ( AW_SIZE_int   ),
      .AWBURST_i  ( AW_BURST_int  ),
      .AWLOCK_i   ( AW_LOCK_int   ),
      .AWCACHE_i  ( AW_CACHE_int  ),
      .AWPROT_i   ( AW_PROT_int   ),
      .AWREGION_i ( AW_REGION_int ),
      .AWUSER_i   ( AW_USER_int   ),
      .AWQOS_i    ( AW_QOS_int    ),
      .AWVALID_i  ( AW_VALID_int  ),
      .AWREADY_o  ( AW_READY_int  ),
      // ---------------------------------------------------------

      //AXI write data bus -------------- // USED// -------------
      .WDATA_i     ( W_DATA_int   ),
      .WSTRB_i     ( W_STRB_int   ),
      .WLAST_i     ( W_LAST_int   ),
      .WUSER_i     ( W_USER_int   ),
      .WVALID_i    ( W_VALID_int  ),
      .WREADY_o    ( W_READY_int  ),

      //AXI write response bus -------------- // USED// ----------
      .BID_o      ( B_ID_int      ),
      .BRESP_o    ( B_RESP_int    ),
      .BVALID_o   ( B_VALID_int   ),
      .BUSER_o    ( B_USER_int    ),
      .BREADY_i   ( B_READY_int   ),

      // Memory Port
      .MEM_CEN_o  (                  ),
      .MEM_WEN_o  ( data_W_wen_int   ),
      .MEM_A_o    ( data_W_add_int   ),
      .MEM_D_o    ( data_W_wdata_int ),
      .MEM_BE_o   ( data_W_be_int    ),
      .MEM_Q_i    ( '0               ),
      .MEM_size_o ( data_W_size_int  ),

      .grant_i    ( data_W_gnt_int   ),
      .valid_o    ( data_W_req_int   )
   );


   lint64_to_32 parallel_lint_write
   (
      .clk              ( clk              ),
      .rst_n            ( rst_n            ),
      // LINT Interface - WRITE Request
      .data_req_i       ( data_W_req_int   ),
      .data_gnt_o       ( data_W_gnt_int   ),
      .data_wdata_i     ( data_W_wdata_int ),
      .data_add_i       ( data_W_add_int   ),
      .data_wen_i       ( data_W_wen_int   ),
      .data_be_i        ( data_W_be_int    ),
      .data_size_i      ( data_W_size_int  ),
      .data_r_valid_o   ( data_W_r_valid_int ),
      .data_r_rdata_o   ( data_W_r_rdata_int ),

      // LINT Interface - WRITE Request
      .data_req_o       ( data_W_req_o      ),
      .data_gnt_i       ( data_W_gnt_i      ),
      .data_wdata_o     ( data_W_wdata_o    ),
      .data_add_o       ( data_W_add_o      ),
      .data_wen_o       ( data_W_wen_o      ),
      .data_be_o        ( data_W_be_o       ),
      .data_r_valid_i   ( data_W_r_valid_i  ),
      .data_r_rdata_i   ( data_W_r_rdata_i  )
   );






   axi_read_ctrl
   #(
      .AXI4_ADDRESS_WIDTH  ( AXI_ADDR_WIDTH ), // 32,
      .AXI4_RDATA_WIDTH    ( AXI_DATA_WIDTH ), // 64,
      .AXI4_WDATA_WIDTH    ( AXI_DATA_WIDTH ), // 64,
      .AXI4_ID_WIDTH       ( AXI_ID_WIDTH   ), // 16,
      .AXI4_USER_WIDTH     ( AXI_USER_WIDTH ), // 10,
      .AXI_NUMBYTES        ( AXI_STRB_WIDTH ), // AXI4_WDATA_WIDTH/8,
      .MEM_ADDR_WIDTH      ( ADDR_WIDTH     )  // 13,
   )
   i_axi_read_ctrl
   (
      .clk                 ( clk              ),// input logic
      .rst_n               ( rst_n            ),// input logic

      .ARID_i              ( AR_ID_int        ),// input  logic [AXI4_ID_WIDTH-1:0]
      .ARADDR_i            ( AR_ADDR_int      ),// input  logic [AXI4_ADDRESS_WIDTH-1:0]
      .ARLEN_i             ( AR_LEN_int       ),// input  logic [ 7:0]
      .ARSIZE_i            ( AR_SIZE_int      ),// input  logic [ 2:0]
      .ARBURST_i           ( AR_BURST_int     ),// input  logic [ 1:0]
      .ARLOCK_i            ( AR_LOCK_int      ),// input  logic
      .ARCACHE_i           ( AR_CACHE_int     ),// input  logic [ 3:0]
      .ARPROT_i            ( AR_PROT_int      ),// input  logic [ 2:0]
      .ARREGION_i          ( AR_REGION_int    ),// input  logic [ 3:0]
      .ARUSER_i            ( AR_USER_int      ),// input  logic [ AXI4_USER_WIDTH-1:0]
      .ARQOS_i             ( AR_QOS_int       ),// input  logic [ 3:0]
      .ARVALID_i           ( AR_VALID_int     ),// input  logic
      .ARREADY_o           ( AR_READY_int     ),// output logic

      .RID_o               ( R_ID_int         ),// output  logic [AXI4_ID_WIDTH-1:0]
      .RDATA_o             ( R_DATA_int       ),// output  logic [AXI4_RDATA_WIDTH-1:0]
      .RRESP_o             ( R_RESP_int       ),// output  logic [ 1:0]
      .RLAST_o             ( R_LAST_int       ),// output  logic
      .RUSER_o             ( R_USER_int       ),// output  logic [AXI4_USER_WIDTH-1:0]
      .RVALID_o            ( R_VALID_int      ),// output  logic
      .RREADY_i            ( R_READY_int      ),// input   logic

      .MEM_CEN_o           (                   ),
      .MEM_WEN_o           ( data_R_wen_int    ),
      .MEM_A_o             ( data_R_add_int    ),
      .MEM_D_o             ( data_R_wdata_int  ),
      .MEM_BE_o            ( data_R_be_int     ),
      .MEM_Q_i             ( data_R_r_rdata_int),
      .grant_i             ( data_R_gnt_int    ),
      .valid_o             ( data_R_req_int    ),
      .r_valid_i           ( data_R_r_valid_int),
      .MEM_size_o          ( data_R_size_int   )
   );


   lint64_to_32 parallel_lint_read
   (
      .clk              ( clk              ),
      .rst_n            ( rst_n            ),
      // LINT Interface - WRITE Request
      .data_req_i       ( data_R_req_int   ),
      .data_gnt_o       ( data_R_gnt_int   ),
      .data_wdata_i     ( data_R_wdata_int ),
      .data_add_i       ( data_R_add_int   ),
      .data_wen_i       ( data_R_wen_int   ),
      .data_be_i        ( data_R_be_int    ),
      .data_r_valid_o   ( data_R_r_valid_int ),
      .data_r_rdata_o   ( data_R_r_rdata_int ),
      .data_size_i      ( data_R_size_int  ),

      // LINT Interface - WRITE Request
      .data_req_o       ( data_R_req_o   ),
      .data_gnt_i       ( data_R_gnt_i   ),
      .data_wdata_o     ( data_R_wdata_o ),
      .data_add_o       ( data_R_add_o   ),
      .data_wen_o       ( data_R_wen_o   ),
      .data_be_o        ( data_R_be_o    ),
      .data_r_valid_i   ( data_R_r_valid_i  ),
      .data_r_rdata_i   ( data_R_r_rdata_i  )
   );


endmodule
