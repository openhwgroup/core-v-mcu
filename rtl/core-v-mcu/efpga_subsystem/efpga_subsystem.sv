`include "pulp_soc_defines.sv"

module efpga_subsystem
#(
        parameter L2_ADDR_WIDTH       = 32,
        parameter APB_HWCE_ADDR_WIDTH = 7
)
(
    input  logic                                             asic_clk_i,

    input  logic                                             fpga_clk0_i,
    input  logic                                             fpga_clk1_i,
    input  logic                                             fpga_clk2_i,
    input  logic                                             fpga_clk3_i,
    input  logic                                             fpga_clk4_i,
    input  logic                                             fpga_clk5_i,

    input  logic  [2:0]                                      sel_clk_dc_fifo_efpga_i,
    input  logic                                             clk_gating_dc_fifo_i,
    input  logic  [3:0]                                      reset_type1_efpga_i,
    input  logic                                             enable_udma_efpga_i,
    input  logic                                             enable_events_efpga_i,
    input  logic                                             enable_apb_efpga_i,
    input  logic                                             enable_tcdm3_efpga_i,
    input  logic                                             enable_tcdm2_efpga_i,
    input  logic                                             enable_tcdm1_efpga_i,
    input  logic                                             enable_tcdm0_efpga_i,

    input  logic                                             rst_n,
    output logic                                             efpga_clk_o,

    /*

        CONFIGURATION PORTS

    */

    /*

        PULP PORTS

    */

    input   logic                                            udma_tx_lin_valid_i          ,
    input   logic [31:0]                                     udma_tx_lin_data_i           ,
    output  logic                                            udma_tx_lin_ready_o          ,
    output  logic                                            udma_rx_lin_valid_o          ,
    output  logic [31:0]                                     udma_rx_lin_data_o           ,
    input   logic                                            udma_rx_lin_ready_i          ,
    input   logic [31:0]                                     udma_cfg_data_i              ,
    output  logic [31:0]                                     udma_cfg_data_o              ,


    XBAR_TCDM_BUS.Master                                     l2_asic_tcdm_o[`N_EFPGA_TCDM_PORTS-1:0],
    XBAR_TCDM_BUS.Slave                                      apbprogram_i,
    XBAR_TCDM_BUS.Slave                                      apbt1_i,

    output logic  [`N_FPGAIO-1:0]                            fpgaio_oe_o,
    input  logic  [`N_FPGAIO-1:0]                            fpgaio_in_i,
    output logic  [`N_FPGAIO-1:0]                            fpgaio_out_o,
    output logic  [`N_EFPGA_EVENTS-1:0]                      efpga_event_o,

    //eFPGA SPIS
    input  logic                                             efpga_fcb_spis_rst_n_i       ,
    input  logic                                             efpga_fcb_spis_mosi_i        ,
    input  logic                                             efpga_fcb_spis_cs_n_i        ,
    input  logic                                             efpga_fcb_spis_clk_i         ,
    input  logic                                             efpga_fcb_spi_mode_en_bo_i   ,
    output logic                                             efpga_fcb_spis_miso_en_o     ,
    output logic                                             efpga_fcb_spis_miso_o        ,

    //eFPGA TEST MODE
    input  logic                                             efpga_STM_i                  ,

    output logic                                             efpga_test_fcb_pif_vldo_en_o ,
    output logic                                             efpga_test_fcb_pif_vldo_o    ,
    output logic                                             efpga_test_fcb_pif_do_l_en_o ,
    output logic                                             efpga_test_fcb_pif_do_l_0_o  ,
    output logic                                             efpga_test_fcb_pif_do_l_1_o  ,
    output logic                                             efpga_test_fcb_pif_do_l_2_o  ,
    output logic                                             efpga_test_fcb_pif_do_l_3_o  ,
    output logic                                             efpga_test_fcb_pif_do_h_en_o ,
    output logic                                             efpga_test_fcb_pif_do_h_0_o  ,
    output logic                                             efpga_test_fcb_pif_do_h_1_o  ,
    output logic                                             efpga_test_fcb_pif_do_h_2_o  ,
    output logic                                             efpga_test_fcb_pif_do_h_3_o  ,
    output logic                                             efpga_test_FB_SPE_OUT_0_o    ,
    output logic                                             efpga_test_FB_SPE_OUT_1_o    ,
    output logic                                             efpga_test_FB_SPE_OUT_2_o    ,
    output logic                                             efpga_test_FB_SPE_OUT_3_o    ,
    input  logic                                             efpga_test_fcb_pif_vldi_i    ,
    input  logic                                             efpga_test_fcb_pif_di_l_0_i  ,
    input  logic                                             efpga_test_fcb_pif_di_l_1_i  ,
    input  logic                                             efpga_test_fcb_pif_di_l_2_i  ,
    input  logic                                             efpga_test_fcb_pif_di_l_3_i  ,
    input  logic                                             efpga_test_fcb_pif_di_h_0_i  ,
    input  logic                                             efpga_test_fcb_pif_di_h_1_i  ,
    input  logic                                             efpga_test_fcb_pif_di_h_2_i  ,
    input  logic                                             efpga_test_fcb_pif_di_h_3_i  ,
    input  logic                                             efpga_test_FB_SPE_IN_0_i     ,
    input  logic                                             efpga_test_FB_SPE_IN_1_i     ,
    input  logic                                             efpga_test_FB_SPE_IN_2_i     ,
    input  logic                                             efpga_test_FB_SPE_IN_3_i     ,
    input  logic                                             efpga_test_M_0_i             ,
    input  logic                                             efpga_test_M_1_i             ,
    input  logic                                             efpga_test_M_2_i             ,
    input  logic                                             efpga_test_M_3_i             ,
    input  logic                                             efpga_test_M_4_i             ,
    input  logic                                             efpga_test_M_5_i             ,
    input  logic                                             efpga_test_MLATCH_i
`ifndef SYNTHESIS
    ,
    input  logic                                             enable_perf_counter_efpga_i,
    input  logic                                             reset_perf_counter_efpga_i,
    output logic [31:0]                                      perf_counter_value_o
`endif
);


`ifndef SYNTHESIS

    always_ff @(posedge asic_clk_i or negedge rst_n) begin
        if(~rst_n) begin
             perf_counter_value_o <= '0;
        end else begin
             if(enable_perf_counter_efpga_i)
                perf_counter_value_o <= perf_counter_value_o + 1;
             if(reset_perf_counter_efpga_i)
                perf_counter_value_o <= '0;
        end
    end



`endif

    XBAR_TCDM_BUS               l2_efpga_tcdm [`N_EFPGA_TCDM_PORTS-1:0]();

    logic                       fcb_apbs_penable_x;
    logic  [31:0]               fcb_apbs_prdata_x;
    logic  [31:0]               fcb_apbs_pwdata_x;
    logic  [19:0]               fcb_apbs_paddr_x;
    logic                       fcb_apbs_pwrite_x;
    logic                       fcb_apbs_psel_x;

    logic  [`N_EFPGA_TCDM_PORTS-1:0]                    tcdm_req_fpga, tcdm_req_fpga_gated;
    logic  [`N_EFPGA_TCDM_PORTS-1:0][L2_ADDR_WIDTH-1:0] tcdm_addr_fpga;
    logic  [`N_EFPGA_TCDM_PORTS-1:0]                    tcdm_wen_fpga;
    logic  [`N_EFPGA_TCDM_PORTS-1:0][31:0]              tcdm_wdata_fpga;
    logic  [`N_EFPGA_TCDM_PORTS-1:0][31:0]              tcdm_rdata_fpga;
    logic  [`N_EFPGA_TCDM_PORTS-1:0][3:0]               tcdm_be_fpga;
    logic  [`N_EFPGA_TCDM_PORTS-1:0]                    tcdm_gnt_fpga;
    logic  [`N_EFPGA_TCDM_PORTS-1:0][31:0]              tcdm_r_rdata_fpga;
    logic  [`N_EFPGA_TCDM_PORTS-1:0]                    tcdm_r_valid_fpga;

    /*

        CONFIGURATION PORTS

    */

   logic  [31:0]                                 fcb_apbs_prdata;
   logic                                         fcb_apbs_pready;
   logic                                         fcb_apbs_pslverr;
   logic  [19:0]                                 fcb_apbs_paddr;
   logic                                         fcb_apbs_penable;
   logic  [2:0]                                  fcb_apbs_pprot;
   logic                                         fcb_apbs_psel;
   logic  [3:0]                                  fcb_apbs_pstrb;
   logic  [31:0]                                 fcb_apbs_pwdata;
   logic                                         fcb_apbs_pwrite;

   XBAR_TCDM_BUS                                 apbprogram_int();

   /*
       Type1 APB interface
    */

   logic  [31:0]                                  apb_hwce_prdata;
   logic                                          apb_hwce_ready, apb_hwce_ready_gated;
   logic                                          apb_hwce_pslverr;
   logic  [APB_HWCE_ADDR_WIDTH-1:0]               apb_hwce_addr;
   logic                                          apb_hwce_enable;
   logic                                          apb_hwce_psel;
   logic                                          apb_hwce_pstrb;
   logic  [31:0]                                  apb_hwce_pwdata;
   logic                                          apb_hwce_pwrite;

   XBAR_TCDM_BUS                                  apbt1_int();


    logic                                         efpga_clk;
    logic  [`N_EFPGA_EVENTS-1:0]                   event_fpga,event_fpga_gate, event_edge, wedge_ack;


    efpga_sel_clk_dc_fifo efpga_sel_clk_dc_fifo_mux_i
    (

        .clk0_i         ( fpga_clk0_i             ),
        .clk1_i         ( fpga_clk1_i             ),
        .clk2_i         ( fpga_clk2_i             ),
        .clk3_i         ( fpga_clk3_i             ),
        .clk4_i         ( fpga_clk4_i             ),
        .clk5_i         ( fpga_clk5_i             ),
        .sel_clk_i      ( sel_clk_dc_fifo_efpga_i ),
        .efpga_clk_o    ( efpga_clk_o             )
    );

/*
    pulp_clock_gating_async i_clk_gate_dc_efpga
    (
        .clk_i(efpga_clk),
        .en_async_i(clk_gating_dc_fifo_i),
        .en_ack_o(),
        .test_en_i(1'b0),
        .clk_o(efpga_clk_o)
    );
*/
    generate
        for (genvar g_tcdm = 0; g_tcdm < `N_EFPGA_TCDM_PORTS; g_tcdm++) begin : DC_FIFO_TCDM_EFPGA

             log_int_dc_slice_wrap logint_dc_efpga_tcdm
             (
                .push_clk(efpga_clk_o),
                .push_rst_n(rst_n),
                .push_bus(l2_efpga_tcdm[g_tcdm]),
                .pop_clk(asic_clk_i),
                .pop_rst_n(rst_n),
                .test_cgbypass_i('0),
                .pop_bus(l2_asic_tcdm_o[g_tcdm])
             );

             `ifndef SYNTHESIS
             assign  #1 l2_efpga_tcdm[g_tcdm].req   = tcdm_req_fpga_gated[g_tcdm]   ;
             assign  #1 l2_efpga_tcdm[g_tcdm].add   = tcdm_addr_fpga[g_tcdm]        ;
             assign  #1 l2_efpga_tcdm[g_tcdm].wen   = tcdm_wen_fpga[g_tcdm]         ;
             assign  #1 l2_efpga_tcdm[g_tcdm].wdata = tcdm_wdata_fpga[g_tcdm]       ;
             assign  #1 l2_efpga_tcdm[g_tcdm].be    = tcdm_be_fpga[g_tcdm]          ;
            `else
             assign  l2_efpga_tcdm[g_tcdm].req   = tcdm_req_fpga_gated[g_tcdm]   ;
             assign  l2_efpga_tcdm[g_tcdm].add   = tcdm_addr_fpga[g_tcdm]        ;
             assign  l2_efpga_tcdm[g_tcdm].wen   = tcdm_wen_fpga[g_tcdm]         ;
             assign  l2_efpga_tcdm[g_tcdm].wdata = tcdm_wdata_fpga[g_tcdm]       ;
             assign  l2_efpga_tcdm[g_tcdm].be    = tcdm_be_fpga[g_tcdm]          ;
             `endif
             assign  tcdm_gnt_fpga[g_tcdm]       = l2_efpga_tcdm[g_tcdm].gnt     ;
             assign  tcdm_r_rdata_fpga[g_tcdm]   = l2_efpga_tcdm[g_tcdm].r_rdata ;
             assign  tcdm_r_valid_fpga[g_tcdm]   = l2_efpga_tcdm[g_tcdm].r_valid ;
         end
    endgenerate

    /*
        CONFIGURATION BINDING
            LOGINT --> LOGINT DUAL CLOCK FIFO --> LOGINT2APB --> APB2APB_STANDARD
    */


    log_int_dc_slice_wrap logint_dc_efpga_apbprogram
    (
       .push_clk(asic_clk_i),
       .push_rst_n(rst_n),
       .push_bus(apbprogram_i),
       .pop_clk(efpga_clk_o),
       .pop_rst_n(rst_n),
       .test_cgbypass_i('0),
       .pop_bus(apbprogram_int)
    );

    lint_2_apb #(
        .ADDR_WIDTH     ( 20                          ), // 32,
        .DATA_WIDTH     ( 32                          ), // 32,
        .BE_WIDTH       ( 4                           ), // DATA_WIDTH/8,
        .ID_WIDTH       ( 1                           ), // 10,
        .AUX_WIDTH      ( 1                           )  // 8
    ) lint_2_apb_program_i (
        .clk            ( efpga_clk_o                   ),
        .rst_n          ( rst_n                         ),
        .data_req_i     ( apbprogram_int.req            ),
        .data_add_i     ( apbprogram_int.add[19:0]      ),
        .data_wen_i     ( apbprogram_int.wen            ),
        .data_wdata_i   ( apbprogram_int.wdata          ),
        .data_be_i      ( apbprogram_int.be             ),
        .data_aux_i     ( '0                            ),
        .data_ID_i      ( '0                            ),
        .data_gnt_o     ( apbprogram_int.gnt            ),
        // Resp
        .data_r_valid_o ( apbprogram_int.r_valid        ),
        .data_r_rdata_o ( apbprogram_int.r_rdata        ),
        .data_r_opc_o   (                               ),
        .data_r_aux_o   (                               ),
        .data_r_ID_o    (                               ),

        .master_PADDR   ( fcb_apbs_paddr                ),
        .master_PWDATA  ( fcb_apbs_pwdata               ),
        .master_PWRITE  ( fcb_apbs_pwrite               ),
        .master_PSEL    ( fcb_apbs_psel                 ),
        .master_PENABLE ( fcb_apbs_penable              ),
        .master_PRDATA  ( fcb_apbs_prdata               ),
        .master_PREADY  ( fcb_apbs_pready               ),
        .master_PSLVERR ( fcb_apbs_pslverr              )
    );


      apb2apbcomp #(
         .APB_DATA_WIDTH (32),
         .APB_ADDR_WIDTH (20)
      ) apb2apbcomp_config (
       .clk_i         (efpga_clk_o       ),
       .rst_n         (rst_n             ),
       .apb_pwrite_i  (fcb_apbs_pwrite   ),
       .apb_psel_i    (fcb_apbs_psel     ),
       .apb_penable_i (fcb_apbs_penable  ),
       .apb_paddr_i   (fcb_apbs_paddr    ),
       .apb_pwdata_i  (fcb_apbs_pwdata   ),

       .apb_pwrite_o  (fcb_apbs_pwrite_x ),
       .apb_psel_o    (fcb_apbs_psel_x   ),
       .apb_pready_i  (fcb_apbs_pready   ),
       .apb_penable_o (fcb_apbs_penable_x),
       .apb_paddr_o   (fcb_apbs_paddr_x  ),
       .apb_pwdata_o  (fcb_apbs_pwdata_x )
      );


    /*
        APB TYPE1 BINDING
            LOGINT --> LOGINT DUAL CLOCK FIFO --> LOGINT2APB
    */


    log_int_dc_slice_wrap logint_dc_efpga_apbt1
    (
       .push_clk(asic_clk_i),
       .push_rst_n(rst_n),
       .push_bus(apbt1_i),
       .pop_clk(efpga_clk_o),
       .pop_rst_n(rst_n),
       .test_cgbypass_i('0),
       .pop_bus(apbt1_int)
    );

    lint_2_apb #(
        .ADDR_WIDTH     ( APB_HWCE_ADDR_WIDTH         ), // 32,
        .DATA_WIDTH     ( 32                          ), // 32,
        .BE_WIDTH       ( 4                           ), // DATA_WIDTH/8,
        .ID_WIDTH       ( 1                           ), // 10,
        .AUX_WIDTH      ( 1                           )  // 8
    ) lint_2_apb_t1_i (
        .clk            ( efpga_clk_o                   ),
        .rst_n          ( rst_n                         ),
        .data_req_i     ( apbt1_int.req                 ),
        .data_add_i     ( apbt1_int.add[APB_HWCE_ADDR_WIDTH-1:0] ),
        .data_wen_i     ( apbt1_int.wen                 ),
        .data_wdata_i   ( apbt1_int.wdata               ),
        .data_be_i      ( apbt1_int.be                  ),
        .data_aux_i     ( '0                            ),
        .data_ID_i      ( '0                            ),
        .data_gnt_o     ( apbt1_int.gnt                 ),
        // Resp
        .data_r_valid_o ( apbt1_int.r_valid             ),
        .data_r_rdata_o ( apbt1_int.r_rdata             ),
        .data_r_opc_o   (                               ),
        .data_r_aux_o   (                               ),
        .data_r_ID_o    (                               ),

        .master_PADDR   ( apb_hwce_addr                 ),
        .master_PWDATA  ( apb_hwce_pwdata               ),
        .master_PWRITE  ( apb_hwce_pwrite               ),
        .master_PSEL    ( apb_hwce_psel                 ),
        .master_PENABLE ( apb_hwce_enable               ),
        .master_PRDATA  ( apb_hwce_prdata               ),
        .master_PREADY  ( apb_hwce_ready_gated          ),
        .master_PSLVERR ( apb_hwce_pslverr              )
    );

    /*
      EVENT Propagation from EFPGA to ASIC

    */

    generate
      for(genvar g_event=0;g_event<`N_EFPGA_EVENTS;g_event++) begin: event_wedge_edge
          pulp_sync_wedge i_wedge_efpga
          (
              .clk_i(asic_clk_i),
              .rstn_i(rst_n),
              .en_i(1'b1),
              .serial_i(event_edge[g_event]),
              .serial_o(wedge_ack[g_event]),
              .r_edge_o(efpga_event_o[g_event]),
              .f_edge_o()
          );
          edge_propagator_tx i_prop_efpga
          (
           .clk_i(efpga_clk_o),
           .rstn_i(rst_n),
           .valid_i(event_fpga_gate[g_event]),
           .ack_i(wedge_ack[g_event]),
           .valid_o(event_edge[g_event])
          );
      end
    endgenerate

    //TODO enable_udma_efpga_i
  `ifndef SYNTHESIS
    assign #1 event_fpga_gate      = event_fpga & {`N_EFPGA_EVENTS{enable_events_efpga_i}};
  `else
    assign event_fpga_gate      = event_fpga & {`N_EFPGA_EVENTS{enable_events_efpga_i}};
  `endif
    assign apb_hwce_ready_gated    = enable_apb_efpga_i & apb_hwce_ready;
    assign tcdm_req_fpga_gated[3]  = enable_tcdm3_efpga_i &  tcdm_req_fpga[3];
    assign tcdm_req_fpga_gated[2]  = enable_tcdm1_efpga_i &  tcdm_req_fpga[2];
    assign tcdm_req_fpga_gated[1]  = enable_tcdm2_efpga_i &  tcdm_req_fpga[1];
    assign tcdm_req_fpga_gated[0]  = enable_tcdm0_efpga_i &  tcdm_req_fpga[0];


      assign tcdm_addr_fpga[0][31:20]   = 12'h1C0;
      assign tcdm_addr_fpga[1][31:20]   = 12'h1C0;
      assign tcdm_addr_fpga[2][31:20]   = 12'h1C0;
      assign tcdm_addr_fpga[3][31:20]   = 12'h1C0;


      eFPGA_wrapper eFPGA_wrapper(

          //Outputs

         .fcb_sysclk_en(),

         .fcb_spis_miso_en(efpga_fcb_spis_miso_en_o),
         .fcb_spis_miso(efpga_fcb_spis_miso_o),
         .fcb_spim_mosi_en(),
         .fcb_spim_mosi(),
         .fcb_spim_cs_n_en(),
         .fcb_spim_cs_n(),
         .fcb_spim_ckout_en(),
         .fcb_spim_ckout(),
         .fcb_spi_master_status(),

         .fcb_set_por(),
         .fcb_rst(),

         .fcb_pif_vldo_en(efpga_test_fcb_pif_vldo_en_o),
         .fcb_pif_vldo(efpga_test_fcb_pif_vldo_o),
         .fcb_pif_do_l_en(efpga_test_fcb_pif_do_l_en_o),
         .fcb_pif_do_l({efpga_test_fcb_pif_do_l_3_o, efpga_test_fcb_pif_do_l_2_o, efpga_test_fcb_pif_do_l_1_o, efpga_test_fcb_pif_do_l_0_o}),
         .fcb_pif_do_h_en(efpga_test_fcb_pif_do_h_en_o),
         .fcb_pif_do_h({efpga_test_fcb_pif_do_h_3_o, efpga_test_fcb_pif_do_h_2_o, efpga_test_fcb_pif_do_h_1_o, efpga_test_fcb_pif_do_h_0_o}),

         .fcb_cfg_done_en(),
         .fcb_cfg_done(),

         .fcb_apbs_pslverr(fcb_apbs_pslverr),
         .fcb_apbs_pready(fcb_apbs_pready),
         .fcb_apbs_prdata(fcb_apbs_prdata),

         .fcb_apbm_ramfifo_sel(),
         .fcb_apbm_pwrite(),
         .fcb_apbm_pwdata(),
         .fcb_apbm_psel(),
         .fcb_apbm_penable(),
         .fcb_apbm_paddr(),
         .fcb_apbm_mclk(),

         .FB_SPE_OUT_3_(efpga_test_FB_SPE_OUT_3_o),
         .FB_SPE_OUT_2_(efpga_test_FB_SPE_OUT_2_o),
         .FB_SPE_OUT_1_(efpga_test_FB_SPE_OUT_1_o),
         .FB_SPE_OUT_0_(efpga_test_FB_SPE_OUT_0_o),

         // Inputs

         .fcb_sys_stm(efpga_STM_i),
         .fcb_sys_rst_n(rst_n),
         .fcb_sys_clk(efpga_clk_o),
         .fcb_spis_rst_n(efpga_fcb_spis_rst_n_i),
         .fcb_spis_mosi(efpga_fcb_spis_mosi_i),
         .fcb_spis_cs_n(efpga_fcb_spis_cs_n_i),
         .fcb_spis_clk(efpga_fcb_spis_clk_i),
         .fcb_spim_miso('0),
         .fcb_spim_ckout_in('0),
         .fcb_spi_mode_en_bo(efpga_fcb_spi_mode_en_bo_i), //0 in APB and 1 in SPIS
         .fcb_spi_master_en('0),
         .fcb_pif_vldi(efpga_test_fcb_pif_vldi_i),
         .fcb_pif_di_l({efpga_test_fcb_pif_di_l_3_i, efpga_test_fcb_pif_di_l_2_i, efpga_test_fcb_pif_di_l_1_i, efpga_test_fcb_pif_di_l_0_i}),
         .fcb_pif_di_h({efpga_test_fcb_pif_di_h_3_i, efpga_test_fcb_pif_di_h_2_i, efpga_test_fcb_pif_di_h_1_i, efpga_test_fcb_pif_di_h_0_i}),
         .fcb_pif_8b_mode_bo(1'b1),

         .fcb_apbs_pwrite(fcb_apbs_pwrite_x),
         .fcb_apbs_pwdata(fcb_apbs_pwdata_x),
         .fcb_apbs_pstrb('0),
         .fcb_apbs_psel(fcb_apbs_psel_x),
         .fcb_apbs_pprot('0),
         .fcb_apbs_penable(fcb_apbs_penable_x),
         .fcb_apbs_paddr(fcb_apbs_paddr_x),
         .fcb_apbm_prdata_1('0),
         .fcb_apbm_prdata_0('0),

         .STM(efpga_STM_i),
         .POR(~rst_n),
         .M_5_(efpga_test_M_5_i),
         .M_4_(efpga_test_M_4_i),
         .M_3_(efpga_test_M_3_i),
         .M_2_(efpga_test_M_2_i),
         .M_1_(efpga_test_M_1_i),
         .M_0_(efpga_test_M_0_i),
         .MLATCH(efpga_test_MLATCH_i),
         .FB_SPE_IN_3_(efpga_test_FB_SPE_IN_3_i),
         .FB_SPE_IN_2_(efpga_test_FB_SPE_IN_2_i),
         .FB_SPE_IN_1_(efpga_test_FB_SPE_IN_1_i),
         .FB_SPE_IN_0_(efpga_test_FB_SPE_IN_0_i),


         //inputs
         .supplyBus('0),

         .CLK0                               (   efpga_clk_o             ),
         .CLK1                               (   fpga_clk1_i             ),
         .CLK2                               (   fpga_clk2_i             ),
         .CLK3                               (   fpga_clk3_i             ),
         .CLK4                               (   fpga_clk4_i             ),
         .CLK5                               (   fpga_clk5_i             ),

         .fpgaio_data_0_i                      (   fpgaio_in_i[0]          ),
         .fpgaio_data_1_i                      (   fpgaio_in_i[1]          ),
         .fpgaio_data_2_i                      (   fpgaio_in_i[2]          ),
         .fpgaio_data_3_i                      (   fpgaio_in_i[3]          ),
         .fpgaio_data_4_i                      (   fpgaio_in_i[4]          ),
         .fpgaio_data_5_i                      (   fpgaio_in_i[5]          ),
         .fpgaio_data_6_i                      (   fpgaio_in_i[6]          ),
         .fpgaio_data_7_i                      (   fpgaio_in_i[7]          ),

         .udma_tx_lin_valid_i                ( udma_tx_lin_valid_i       ),
         .udma_tx_lin_data_0_i               ( udma_tx_lin_data_i[0]     ),
         .udma_tx_lin_data_1_i               ( udma_tx_lin_data_i[1]     ),
         .udma_tx_lin_data_2_i               ( udma_tx_lin_data_i[2]     ),
         .udma_tx_lin_data_3_i               ( udma_tx_lin_data_i[3]     ),
         .udma_tx_lin_data_4_i               ( udma_tx_lin_data_i[4]     ),
         .udma_tx_lin_data_5_i               ( udma_tx_lin_data_i[5]     ),
         .udma_tx_lin_data_6_i               ( udma_tx_lin_data_i[6]     ),
         .udma_tx_lin_data_7_i               ( udma_tx_lin_data_i[7]     ),
         .udma_tx_lin_data_8_i               ( udma_tx_lin_data_i[8]     ),
         .udma_tx_lin_data_9_i               ( udma_tx_lin_data_i[9]     ),
         .udma_tx_lin_data_10_i              ( udma_tx_lin_data_i[10]    ),
         .udma_tx_lin_data_11_i              ( udma_tx_lin_data_i[11]    ),
         .udma_tx_lin_data_12_i              ( udma_tx_lin_data_i[12]    ),
         .udma_tx_lin_data_13_i              ( udma_tx_lin_data_i[13]    ),
         .udma_tx_lin_data_14_i              ( udma_tx_lin_data_i[14]    ),
         .udma_tx_lin_data_15_i              ( udma_tx_lin_data_i[15]    ),
         .udma_tx_lin_data_16_i              ( udma_tx_lin_data_i[16]    ),
         .udma_tx_lin_data_17_i              ( udma_tx_lin_data_i[17]    ),
         .udma_tx_lin_data_18_i              ( udma_tx_lin_data_i[18]    ),
         .udma_tx_lin_data_19_i              ( udma_tx_lin_data_i[19]    ),
         .udma_tx_lin_data_20_i              ( udma_tx_lin_data_i[20]    ),
         .udma_tx_lin_data_21_i              ( udma_tx_lin_data_i[21]    ),
         .udma_tx_lin_data_22_i              ( udma_tx_lin_data_i[22]    ),
         .udma_tx_lin_data_23_i              ( udma_tx_lin_data_i[23]    ),
         .udma_tx_lin_data_24_i              ( udma_tx_lin_data_i[24]    ),
         .udma_tx_lin_data_25_i              ( udma_tx_lin_data_i[25]    ),
         .udma_tx_lin_data_26_i              ( udma_tx_lin_data_i[26]    ),
         .udma_tx_lin_data_27_i              ( udma_tx_lin_data_i[27]    ),
         .udma_tx_lin_data_28_i              ( udma_tx_lin_data_i[28]    ),
         .udma_tx_lin_data_29_i              ( udma_tx_lin_data_i[29]    ),
         .udma_tx_lin_data_30_i              ( udma_tx_lin_data_i[30]    ),
         .udma_tx_lin_data_31_i              ( udma_tx_lin_data_i[31]    ),
         .udma_rx_lin_ready_i                ( udma_rx_lin_ready_i       ),
         .udma_cfg_data_0_i                  ( udma_cfg_data_i[0]        ),
         .udma_cfg_data_1_i                  ( udma_cfg_data_i[1]        ),
         .udma_cfg_data_2_i                  ( udma_cfg_data_i[2]        ),
         .udma_cfg_data_3_i                  ( udma_cfg_data_i[3]        ),
         .udma_cfg_data_4_i                  ( udma_cfg_data_i[4]        ),
         .udma_cfg_data_5_i                  ( udma_cfg_data_i[5]        ),
         .udma_cfg_data_6_i                  ( udma_cfg_data_i[6]        ),
         .udma_cfg_data_7_i                  ( udma_cfg_data_i[7]        ),
         .udma_cfg_data_8_i                  ( udma_cfg_data_i[8]        ),
         .udma_cfg_data_9_i                  ( udma_cfg_data_i[9]        ),
         .udma_cfg_data_10_i                 ( udma_cfg_data_i[10]       ),
         .udma_cfg_data_11_i                 ( udma_cfg_data_i[11]       ),
         .udma_cfg_data_12_i                 ( udma_cfg_data_i[12]       ),
         .udma_cfg_data_13_i                 ( udma_cfg_data_i[13]       ),
         .udma_cfg_data_14_i                 ( udma_cfg_data_i[14]       ),
         .udma_cfg_data_15_i                 ( udma_cfg_data_i[15]       ),
         .udma_cfg_data_16_i                 ( udma_cfg_data_i[16]       ),
         .udma_cfg_data_17_i                 ( udma_cfg_data_i[17]       ),
         .udma_cfg_data_18_i                 ( udma_cfg_data_i[18]       ),
         .udma_cfg_data_19_i                 ( udma_cfg_data_i[19]       ),
         .udma_cfg_data_20_i                 ( udma_cfg_data_i[20]       ),
         .udma_cfg_data_21_i                 ( udma_cfg_data_i[21]       ),
         .udma_cfg_data_22_i                 ( udma_cfg_data_i[22]       ),
         .udma_cfg_data_23_i                 ( udma_cfg_data_i[23]       ),
         .udma_cfg_data_24_i                 ( udma_cfg_data_i[24]       ),
         .udma_cfg_data_25_i                 ( udma_cfg_data_i[25]       ),
         .udma_cfg_data_26_i                 ( udma_cfg_data_i[26]       ),
         .udma_cfg_data_27_i                 ( udma_cfg_data_i[27]       ),
         .udma_cfg_data_28_i                 ( udma_cfg_data_i[28]       ),
         .udma_cfg_data_29_i                 ( udma_cfg_data_i[29]       ),
         .udma_cfg_data_30_i                 ( udma_cfg_data_i[30]       ),
         .udma_cfg_data_31_i                 ( udma_cfg_data_i[31]       ),

         .apb_hwce_addr_0_i                  (   apb_hwce_addr[2]        ),
         .apb_hwce_addr_1_i                  (   apb_hwce_addr[3]        ),
         .apb_hwce_addr_2_i                  (   apb_hwce_addr[4]        ),
         .apb_hwce_addr_3_i                  (   apb_hwce_addr[5]        ),
         .apb_hwce_addr_4_i                  (   apb_hwce_addr[6]        ),
         .apb_hwce_addr_5_i                  (   apb_hwce_addr[7]        ),
         .apb_hwce_addr_6_i                  (   apb_hwce_addr[8]        ),
         .apb_hwce_enable_i                  (   apb_hwce_enable         ),
         .apb_hwce_psel_i                    (   apb_hwce_psel           ),
         .apb_hwce_pwdata_0_i                (   apb_hwce_pwdata[0]      ),
         .apb_hwce_pwdata_1_i                (   apb_hwce_pwdata[1]      ),
         .apb_hwce_pwdata_2_i                (   apb_hwce_pwdata[2]      ),
         .apb_hwce_pwdata_3_i                (   apb_hwce_pwdata[3]      ),
         .apb_hwce_pwdata_4_i                (   apb_hwce_pwdata[4]      ),
         .apb_hwce_pwdata_5_i                (   apb_hwce_pwdata[5]      ),
         .apb_hwce_pwdata_6_i                (   apb_hwce_pwdata[6]      ),
         .apb_hwce_pwdata_7_i                (   apb_hwce_pwdata[7]      ),
         .apb_hwce_pwdata_8_i                (   apb_hwce_pwdata[8]      ),
         .apb_hwce_pwdata_9_i                (   apb_hwce_pwdata[9]      ),
         .apb_hwce_pwdata_10_i               (   apb_hwce_pwdata[10]     ),
         .apb_hwce_pwdata_11_i               (   apb_hwce_pwdata[11]     ),
         .apb_hwce_pwdata_12_i               (   apb_hwce_pwdata[12]     ),
         .apb_hwce_pwdata_13_i               (   apb_hwce_pwdata[13]     ),
         .apb_hwce_pwdata_14_i               (   apb_hwce_pwdata[14]     ),
         .apb_hwce_pwdata_15_i               (   apb_hwce_pwdata[15]     ),
         .apb_hwce_pwdata_16_i               (   apb_hwce_pwdata[16]     ),
         .apb_hwce_pwdata_17_i               (   apb_hwce_pwdata[17]     ),
         .apb_hwce_pwdata_18_i               (   apb_hwce_pwdata[18]     ),
         .apb_hwce_pwdata_19_i               (   apb_hwce_pwdata[19]     ),
         .apb_hwce_pwdata_20_i               (   apb_hwce_pwdata[20]     ),
         .apb_hwce_pwdata_21_i               (   apb_hwce_pwdata[21]     ),
         .apb_hwce_pwdata_22_i               (   apb_hwce_pwdata[22]     ),
         .apb_hwce_pwdata_23_i               (   apb_hwce_pwdata[23]     ),
         .apb_hwce_pwdata_24_i               (   apb_hwce_pwdata[24]     ),
         .apb_hwce_pwdata_25_i               (   apb_hwce_pwdata[25]     ),
         .apb_hwce_pwdata_26_i               (   apb_hwce_pwdata[26]     ),
         .apb_hwce_pwdata_27_i               (   apb_hwce_pwdata[27]     ),
         .apb_hwce_pwdata_28_i               (   apb_hwce_pwdata[28]     ),
         .apb_hwce_pwdata_29_i               (   apb_hwce_pwdata[29]     ),
         .apb_hwce_pwdata_30_i               (   apb_hwce_pwdata[30]     ),
         .apb_hwce_pwdata_31_i               (   apb_hwce_pwdata[31]     ),
         .apb_hwce_pwrite_i                  (   apb_hwce_pwrite         ),
         .fpgaio_data_28_i                     (   fpgaio_in_i[28]         ),
         .fpgaio_data_29_i                     (   fpgaio_in_i[29]         ),
         .fpgaio_data_30_i                     (   fpgaio_in_i[30]         ),
         .fpgaio_data_31_i                     (   fpgaio_in_i[31]         ),
         .fpgaio_data_32_i                     (   fpgaio_in_i[32]         ),
         .fpgaio_data_33_i                     (   fpgaio_in_i[33]         ),
         .fpgaio_data_34_i                     (   fpgaio_in_i[34]         ),
         .fpgaio_data_35_i                     (   fpgaio_in_i[35]         ),
         .fpgaio_data_36_i                     (   fpgaio_in_i[36]         ),
         .fpgaio_data_37_i                     (   fpgaio_in_i[37]         ),
         .fpgaio_data_38_i                     (   fpgaio_in_i[38]         ),
         .fpgaio_data_39_i                     (   fpgaio_in_i[39]         ),
         .fpgaio_data_40_i                     (   fpgaio_in_i[40]         ),
         .RESET_LB                           (   reset_type1_efpga_i[1]  ),
         .RESET_LT                           (   reset_type1_efpga_i[0]  ),
         .fpgaio_data_22_i                     (   fpgaio_in_i[22]         ),
         .fpgaio_data_23_i                     (   fpgaio_in_i[23]         ),
         .fpgaio_data_24_i                     (   fpgaio_in_i[24]         ),
         .fpgaio_data_25_i                     (   fpgaio_in_i[25]         ),
         .fpgaio_data_26_i                     (   fpgaio_in_i[26]         ),
         .fpgaio_data_27_i                     (   fpgaio_in_i[27]         ),
         .fpgaio_data_16_i                     (   fpgaio_in_i[16]         ),
         .fpgaio_data_17_i                     (   fpgaio_in_i[17]         ),
         .fpgaio_data_18_i                     (   fpgaio_in_i[18]         ),
         .fpgaio_data_19_i                     (   fpgaio_in_i[19]         ),
         .fpgaio_data_20_i                     (   fpgaio_in_i[20]         ),
         .fpgaio_data_21_i                     (   fpgaio_in_i[21]         ),
         .tcdm_r_rdata_p3_7_i                (   tcdm_r_rdata_fpga[3][7]    ),
         .tcdm_r_rdata_p3_8_i                (   tcdm_r_rdata_fpga[3][8]    ),
         .tcdm_r_rdata_p3_9_i                (   tcdm_r_rdata_fpga[3][9]    ),
         .tcdm_r_rdata_p3_10_i               (   tcdm_r_rdata_fpga[3][10]   ),
         .tcdm_r_rdata_p3_11_i               (   tcdm_r_rdata_fpga[3][11]   ),
         .tcdm_r_rdata_p3_12_i               (   tcdm_r_rdata_fpga[3][12]   ),
         .tcdm_r_rdata_p3_13_i               (   tcdm_r_rdata_fpga[3][13]   ),
         .tcdm_r_rdata_p3_14_i               (   tcdm_r_rdata_fpga[3][14]   ),
         .tcdm_r_rdata_p3_1_i                (   tcdm_r_rdata_fpga[3][1]    ),
         .tcdm_r_rdata_p3_2_i                (   tcdm_r_rdata_fpga[3][2]    ),
         .tcdm_r_rdata_p3_3_i                (   tcdm_r_rdata_fpga[3][3]    ),
         .tcdm_r_rdata_p3_4_i                (   tcdm_r_rdata_fpga[3][4]    ),
         .tcdm_r_rdata_p3_5_i                (   tcdm_r_rdata_fpga[3][5]    ),
         .tcdm_r_rdata_p3_6_i                (   tcdm_r_rdata_fpga[3][6]    ),
         .tcdm_r_rdata_p2_27_i               (   tcdm_r_rdata_fpga[2][27]   ),
         .tcdm_r_rdata_p2_28_i               (   tcdm_r_rdata_fpga[2][28]   ),
         .tcdm_r_rdata_p2_29_i               (   tcdm_r_rdata_fpga[2][29]   ),
         .tcdm_r_rdata_p2_30_i               (   tcdm_r_rdata_fpga[2][30]   ),
         .tcdm_r_rdata_p2_31_i               (   tcdm_r_rdata_fpga[2][31]   ),
         .tcdm_r_valid_p2_i                  (   tcdm_r_valid_fpga[2]       ),
         .tcdm_gnt_p3_i                      (   tcdm_gnt_fpga[3]           ),
         .tcdm_r_rdata_p3_0_i                (   tcdm_r_rdata_fpga[3][0]    ),
         .tcdm_r_rdata_p2_21_i               (   tcdm_r_rdata_fpga[2][21]   ),
         .tcdm_r_rdata_p2_22_i               (   tcdm_r_rdata_fpga[2][22]   ),
         .tcdm_r_rdata_p2_23_i               (   tcdm_r_rdata_fpga[2][23]   ),
         .tcdm_r_rdata_p2_24_i               (   tcdm_r_rdata_fpga[2][24]   ),
         .tcdm_r_rdata_p2_25_i               (   tcdm_r_rdata_fpga[2][25]   ),
         .tcdm_r_rdata_p2_26_i               (   tcdm_r_rdata_fpga[2][26]   ),
         .tcdm_r_rdata_p2_13_i               (   tcdm_r_rdata_fpga[2][13]   ),
         .tcdm_r_rdata_p2_14_i               (   tcdm_r_rdata_fpga[2][14]   ),
         .tcdm_r_rdata_p2_15_i               (   tcdm_r_rdata_fpga[2][15]   ),
         .tcdm_r_rdata_p2_16_i               (   tcdm_r_rdata_fpga[2][16]   ),
         .tcdm_r_rdata_p2_17_i               (   tcdm_r_rdata_fpga[2][17]   ),
         .tcdm_r_rdata_p2_18_i               (   tcdm_r_rdata_fpga[2][18]   ),
         .tcdm_r_rdata_p2_19_i               (   tcdm_r_rdata_fpga[2][19]   ),
         .tcdm_r_rdata_p2_20_i               (   tcdm_r_rdata_fpga[2][20]   ),
         .tcdm_r_rdata_p2_7_i                (   tcdm_r_rdata_fpga[2][7]    ),
         .tcdm_r_rdata_p2_8_i                (   tcdm_r_rdata_fpga[2][8]    ),
         .tcdm_r_rdata_p2_9_i                (   tcdm_r_rdata_fpga[2][9]    ),
         .tcdm_r_rdata_p2_10_i               (   tcdm_r_rdata_fpga[2][10]   ),
         .tcdm_r_rdata_p2_11_i               (   tcdm_r_rdata_fpga[2][11]   ),
         .tcdm_r_rdata_p2_12_i               (   tcdm_r_rdata_fpga[2][12]   ),
         .tcdm_gnt_p2_i                      (   tcdm_gnt_fpga[2]           ),
         .tcdm_r_rdata_p2_0_i                (   tcdm_r_rdata_fpga[2][0]    ),
         .tcdm_r_rdata_p2_1_i                (   tcdm_r_rdata_fpga[2][1]    ),
         .tcdm_r_rdata_p2_2_i                (   tcdm_r_rdata_fpga[2][2]    ),
         .tcdm_r_rdata_p2_3_i                (   tcdm_r_rdata_fpga[2][3]    ),
         .tcdm_r_rdata_p2_4_i                (   tcdm_r_rdata_fpga[2][4]    ),
         .tcdm_r_rdata_p2_5_i                (   tcdm_r_rdata_fpga[2][5]    ),
         .tcdm_r_rdata_p2_6_i                (   tcdm_r_rdata_fpga[2][6]    ),
         .tcdm_gnt_p0_i                      (   tcdm_gnt_fpga[0]           ),
         .tcdm_r_rdata_p0_0_i                (   tcdm_r_rdata_fpga[0][0]    ),
         .tcdm_r_rdata_p0_1_i                (   tcdm_r_rdata_fpga[0][1]    ),
         .tcdm_r_rdata_p0_2_i                (   tcdm_r_rdata_fpga[0][2]    ),
         .tcdm_r_rdata_p0_3_i                (   tcdm_r_rdata_fpga[0][3]    ),
         .tcdm_r_rdata_p0_4_i                (   tcdm_r_rdata_fpga[0][4]    ),
         .tcdm_r_rdata_p0_5_i                (   tcdm_r_rdata_fpga[0][5]    ),
         .tcdm_r_rdata_p0_6_i                (   tcdm_r_rdata_fpga[0][6]    ),
         .tcdm_r_rdata_p0_7_i                (   tcdm_r_rdata_fpga[0][7]    ),
         .tcdm_r_rdata_p0_8_i                (   tcdm_r_rdata_fpga[0][8]    ),
         .tcdm_r_rdata_p0_9_i                (   tcdm_r_rdata_fpga[0][9]    ),
         .tcdm_r_rdata_p0_10_i               (   tcdm_r_rdata_fpga[0][10]   ),
         .tcdm_r_rdata_p0_11_i               (   tcdm_r_rdata_fpga[0][11]   ),
         .tcdm_r_rdata_p0_12_i               (   tcdm_r_rdata_fpga[0][12]   ),
         .tcdm_r_rdata_p0_13_i               (   tcdm_r_rdata_fpga[0][13]   ),
         .tcdm_r_rdata_p0_14_i               (   tcdm_r_rdata_fpga[0][14]   ),
         .tcdm_r_rdata_p0_15_i               (   tcdm_r_rdata_fpga[0][15]   ),
         .tcdm_r_rdata_p0_16_i               (   tcdm_r_rdata_fpga[0][16]   ),
         .tcdm_r_rdata_p0_17_i               (   tcdm_r_rdata_fpga[0][17]   ),
         .tcdm_r_rdata_p0_18_i               (   tcdm_r_rdata_fpga[0][18]   ),
         .tcdm_r_rdata_p0_19_i               (   tcdm_r_rdata_fpga[0][19]   ),
         .tcdm_r_rdata_p0_20_i               (   tcdm_r_rdata_fpga[0][20]   ),
         .tcdm_r_rdata_p0_21_i               (   tcdm_r_rdata_fpga[0][21]   ),
         .tcdm_r_rdata_p0_22_i               (   tcdm_r_rdata_fpga[0][22]   ),
         .tcdm_r_rdata_p0_23_i               (   tcdm_r_rdata_fpga[0][23]   ),
         .tcdm_r_rdata_p0_24_i               (   tcdm_r_rdata_fpga[0][24]   ),
         .tcdm_r_rdata_p0_25_i               (   tcdm_r_rdata_fpga[0][25]   ),
         .tcdm_r_rdata_p0_26_i               (   tcdm_r_rdata_fpga[0][26]   ),
         .tcdm_r_rdata_p0_27_i               (   tcdm_r_rdata_fpga[0][27]   ),
         .tcdm_r_rdata_p0_28_i               (   tcdm_r_rdata_fpga[0][28]   ),
         .tcdm_r_rdata_p0_29_i               (   tcdm_r_rdata_fpga[0][29]   ),
         .tcdm_r_rdata_p0_30_i               (   tcdm_r_rdata_fpga[0][30]   ),
         .tcdm_r_rdata_p0_31_i               (   tcdm_r_rdata_fpga[0][31]   ),
         .tcdm_r_valid_p0_i                  (   tcdm_r_valid_fpga[0]       ),
         .tcdm_gnt_p1_i                      (   tcdm_gnt_fpga[1]           ),
         .tcdm_r_rdata_p1_0_i                (   tcdm_r_rdata_fpga[1][0]    ),
         .tcdm_r_rdata_p1_1_i                (   tcdm_r_rdata_fpga[1][1]    ),
         .tcdm_r_rdata_p1_2_i                (   tcdm_r_rdata_fpga[1][2]    ),
         .tcdm_r_rdata_p1_3_i                (   tcdm_r_rdata_fpga[1][3]    ),
         .tcdm_r_rdata_p1_4_i                (   tcdm_r_rdata_fpga[1][4]    ),
         .tcdm_r_rdata_p1_5_i                (   tcdm_r_rdata_fpga[1][5]    ),
         .tcdm_r_rdata_p1_6_i                (   tcdm_r_rdata_fpga[1][6]    ),
         .tcdm_r_rdata_p1_7_i                (   tcdm_r_rdata_fpga[1][7]    ),
         .tcdm_r_rdata_p1_8_i                (   tcdm_r_rdata_fpga[1][8]    ),
         .tcdm_r_rdata_p1_9_i                (   tcdm_r_rdata_fpga[1][9]    ),
         .tcdm_r_rdata_p1_10_i               (   tcdm_r_rdata_fpga[1][10]   ),
         .tcdm_r_rdata_p1_11_i               (   tcdm_r_rdata_fpga[1][11]   ),
         .tcdm_r_rdata_p1_12_i               (   tcdm_r_rdata_fpga[1][12]   ),
         .tcdm_r_rdata_p1_13_i               (   tcdm_r_rdata_fpga[1][13]   ),
         .tcdm_r_rdata_p1_14_i               (   tcdm_r_rdata_fpga[1][14]   ),
         .tcdm_r_rdata_p1_15_i               (   tcdm_r_rdata_fpga[1][15]   ),
         .tcdm_r_rdata_p1_16_i               (   tcdm_r_rdata_fpga[1][16]   ),
         .tcdm_r_rdata_p1_17_i               (   tcdm_r_rdata_fpga[1][17]   ),
         .tcdm_r_rdata_p1_18_i               (   tcdm_r_rdata_fpga[1][18]   ),
         .tcdm_r_rdata_p1_19_i               (   tcdm_r_rdata_fpga[1][19]   ),
         .tcdm_r_rdata_p1_20_i               (   tcdm_r_rdata_fpga[1][20]   ),
         .tcdm_r_rdata_p1_21_i               (   tcdm_r_rdata_fpga[1][21]   ),
         .tcdm_r_rdata_p1_22_i               (   tcdm_r_rdata_fpga[1][22]   ),
         .tcdm_r_rdata_p1_23_i               (   tcdm_r_rdata_fpga[1][23]   ),
         .tcdm_r_rdata_p1_24_i               (   tcdm_r_rdata_fpga[1][24]   ),
         .tcdm_r_rdata_p1_25_i               (   tcdm_r_rdata_fpga[1][25]   ),
         .tcdm_r_rdata_p1_26_i               (   tcdm_r_rdata_fpga[1][26]   ),
         .tcdm_r_rdata_p1_27_i               (   tcdm_r_rdata_fpga[1][27]   ),
         .tcdm_r_rdata_p1_28_i               (   tcdm_r_rdata_fpga[1][28]   ),
         .tcdm_r_rdata_p1_29_i               (   tcdm_r_rdata_fpga[1][29]   ),
         .tcdm_r_rdata_p1_30_i               (   tcdm_r_rdata_fpga[1][30]   ),
         .tcdm_r_rdata_p1_31_i               (   tcdm_r_rdata_fpga[1][31]   ),
         .tcdm_r_valid_p1_i                  (   tcdm_r_valid_fpga[1]       ),
         .fpgaio_data_8_i                      (   fpgaio_in_i[8]             ),
         .fpgaio_data_9_i                      (   fpgaio_in_i[9]             ),
         .fpgaio_data_10_i                     (   fpgaio_in_i[10]            ),
         .fpgaio_data_11_i                     (   fpgaio_in_i[11]            ),
         .RESET_RB                           (   reset_type1_efpga_i[2]     ),
         .fpgaio_data_14_i                     (   fpgaio_in_i[14]            ),
         .fpgaio_data_15_i                     (   fpgaio_in_i[15]            ),
         .RESET_RT                           (   reset_type1_efpga_i[3]     ),
         .tcdm_r_rdata_p3_29_i               (   tcdm_r_rdata_fpga[3][29]   ),
         .tcdm_r_rdata_p3_30_i               (   tcdm_r_rdata_fpga[3][30]   ),
         .tcdm_r_rdata_p3_31_i               (   tcdm_r_rdata_fpga[3][31]   ),
         .tcdm_r_valid_p3_i                  (   tcdm_r_valid_fpga[3]       ),
         .fpgaio_data_12_i                     (   fpgaio_in_i[12]            ),
         .fpgaio_data_13_i                     (   fpgaio_in_i[13]            ),
         .tcdm_r_rdata_p3_21_i               (   tcdm_r_rdata_fpga[3][21]   ),
         .tcdm_r_rdata_p3_22_i               (   tcdm_r_rdata_fpga[3][22]   ),
         .tcdm_r_rdata_p3_23_i               (   tcdm_r_rdata_fpga[3][23]   ),
         .tcdm_r_rdata_p3_24_i               (   tcdm_r_rdata_fpga[3][24]   ),
         .tcdm_r_rdata_p3_25_i               (   tcdm_r_rdata_fpga[3][25]   ),
         .tcdm_r_rdata_p3_26_i               (   tcdm_r_rdata_fpga[3][26]   ),
         .tcdm_r_rdata_p3_27_i               (   tcdm_r_rdata_fpga[3][27]   ),
         .tcdm_r_rdata_p3_28_i               (   tcdm_r_rdata_fpga[3][28]   ),
         .tcdm_r_rdata_p3_15_i               (   tcdm_r_rdata_fpga[3][15]   ),
         .tcdm_r_rdata_p3_16_i               (   tcdm_r_rdata_fpga[3][16]   ),
         .tcdm_r_rdata_p3_17_i               (   tcdm_r_rdata_fpga[3][17]   ),
         .tcdm_r_rdata_p3_18_i               (   tcdm_r_rdata_fpga[3][18]   ),
         .tcdm_r_rdata_p3_19_i               (   tcdm_r_rdata_fpga[3][19]   ),
         .tcdm_r_rdata_p3_20_i               (   tcdm_r_rdata_fpga[3][20]   ),
         //outputs
         .fpgaio_oe_0_o                        ( fpgaio_oe_o[0]              ),
         .fpgaio_data_0_o                      ( fpgaio_out_o[0]            ),
         .fpgaio_oe_1_o                        ( fpgaio_oe_o[1]              ),
         .fpgaio_data_1_o                      ( fpgaio_out_o[1]            ),
         .fpgaio_oe_2_o                        ( fpgaio_oe_o[2]              ),
         .fpgaio_data_2_o                      ( fpgaio_out_o[2]            ),
         .fpgaio_oe_3_o                        ( fpgaio_oe_o[3]              ),
         .fpgaio_data_3_o                      ( fpgaio_out_o[3]            ),
         .fpgaio_oe_4_o                        ( fpgaio_oe_o[4]              ),
         .fpgaio_data_4_o                      ( fpgaio_out_o[4]            ),
         .fpgaio_oe_5_o                        ( fpgaio_oe_o[5]              ),
         .fpgaio_data_5_o                      ( fpgaio_out_o[5]            ),
         .fpgaio_oe_6_o                        ( fpgaio_oe_o[6]              ),
         .fpgaio_data_6_o                      ( fpgaio_out_o[6]            ),
         .fpgaio_oe_7_o                        ( fpgaio_oe_o[7]              ),
         .fpgaio_data_7_o                      ( fpgaio_out_o[7]            ),
         .events_10_o                        ( event_fpga[10]            ),
         .events_11_o                        ( event_fpga[11]            ),
         .fpgaio_oe_18_o                       ( fpgaio_oe_o[18]             ),
         .fpgaio_data_18_o                     ( fpgaio_out_o[18]           ),
         .fpgaio_oe_19_o                       ( fpgaio_oe_o[19]             ),
         .fpgaio_data_19_o                     ( fpgaio_out_o[19]           ),
         .fpgaio_oe_20_o                       ( fpgaio_oe_o[20]             ),
         .fpgaio_data_20_o                     ( fpgaio_out_o[20]           ),
         .fpgaio_oe_21_o                       ( fpgaio_oe_o[21]             ),
         .fpgaio_data_21_o                     ( fpgaio_out_o[21]           ),
         .events_12_o                        ( event_fpga[12]            ),
         .events_13_o                        ( event_fpga[13]            ),
         .events_14_o                        ( event_fpga[14]            ),
         .events_15_o                        ( event_fpga[15]            ),
         .fpgaio_oe_16_o                       ( fpgaio_oe_o[16]             ),
         .fpgaio_data_16_o                     ( fpgaio_out_o[16]           ),
         .fpgaio_oe_17_o                       ( fpgaio_oe_o[17]             ),
         .fpgaio_data_17_o                     ( fpgaio_out_o[17]           ),
         .events_8_o                         ( event_fpga[8]             ),
         .events_9_o                         ( event_fpga[9]             ),
         .events_0_o                         ( event_fpga[0]             ),
         .events_1_o                         ( event_fpga[1]             ),
         .events_2_o                         ( event_fpga[2]             ),
         .events_3_o                         ( event_fpga[3]             ),
         .events_4_o                         ( event_fpga[4]             ),
         .events_5_o                         ( event_fpga[5]             ),
         .events_6_o                         ( event_fpga[6]             ),
         .events_7_o                         ( event_fpga[7]             ),

         .udma_tx_lin_ready_o                ( udma_tx_lin_ready_o       ),
         .udma_rx_lin_valid_o                ( udma_rx_lin_valid_o       ),
         .udma_rx_lin_data_0_o               ( udma_rx_lin_data_o[0]     ),
         .udma_rx_lin_data_1_o               ( udma_rx_lin_data_o[1]     ),
         .udma_rx_lin_data_2_o               ( udma_rx_lin_data_o[2]     ),
         .udma_rx_lin_data_3_o               ( udma_rx_lin_data_o[3]     ),
         .udma_rx_lin_data_4_o               ( udma_rx_lin_data_o[4]     ),
         .udma_rx_lin_data_5_o               ( udma_rx_lin_data_o[5]     ),
         .udma_rx_lin_data_6_o               ( udma_rx_lin_data_o[6]     ),
         .udma_rx_lin_data_7_o               ( udma_rx_lin_data_o[7]     ),
         .udma_rx_lin_data_8_o               ( udma_rx_lin_data_o[8]     ),
         .udma_rx_lin_data_9_o               ( udma_rx_lin_data_o[9]     ),
         .udma_rx_lin_data_10_o              ( udma_rx_lin_data_o[10]    ),
         .udma_rx_lin_data_11_o              ( udma_rx_lin_data_o[11]    ),
         .udma_rx_lin_data_12_o              ( udma_rx_lin_data_o[12]    ),
         .udma_rx_lin_data_13_o              ( udma_rx_lin_data_o[13]    ),
         .udma_rx_lin_data_14_o              ( udma_rx_lin_data_o[14]    ),
         .udma_rx_lin_data_15_o              ( udma_rx_lin_data_o[15]    ),
         .udma_rx_lin_data_16_o              ( udma_rx_lin_data_o[16]    ),
         .udma_rx_lin_data_17_o              ( udma_rx_lin_data_o[17]    ),
         .udma_rx_lin_data_18_o              ( udma_rx_lin_data_o[18]    ),
         .udma_rx_lin_data_19_o              ( udma_rx_lin_data_o[19]    ),
         .udma_rx_lin_data_20_o              ( udma_rx_lin_data_o[20]    ),
         .udma_rx_lin_data_21_o              ( udma_rx_lin_data_o[21]    ),
         .udma_rx_lin_data_22_o              ( udma_rx_lin_data_o[22]    ),
         .udma_rx_lin_data_23_o              ( udma_rx_lin_data_o[23]    ),
         .udma_rx_lin_data_24_o              ( udma_rx_lin_data_o[24]    ),
         .udma_rx_lin_data_25_o              ( udma_rx_lin_data_o[25]    ),
         .udma_rx_lin_data_26_o              ( udma_rx_lin_data_o[26]    ),
         .udma_rx_lin_data_27_o              ( udma_rx_lin_data_o[27]    ),
         .udma_rx_lin_data_28_o              ( udma_rx_lin_data_o[28]    ),
         .udma_rx_lin_data_29_o              ( udma_rx_lin_data_o[29]    ),
         .udma_rx_lin_data_30_o              ( udma_rx_lin_data_o[30]    ),
         .udma_rx_lin_data_31_o              ( udma_rx_lin_data_o[31]    ),
         .udma_cfg_data_0_o                  ( udma_cfg_data_o[0]        ),
         .udma_cfg_data_1_o                  ( udma_cfg_data_o[1]        ),
         .udma_cfg_data_2_o                  ( udma_cfg_data_o[2]        ),
         .udma_cfg_data_3_o                  ( udma_cfg_data_o[3]        ),
         .udma_cfg_data_4_o                  ( udma_cfg_data_o[4]        ),
         .udma_cfg_data_5_o                  ( udma_cfg_data_o[5]        ),
         .udma_cfg_data_6_o                  ( udma_cfg_data_o[6]        ),
         .udma_cfg_data_7_o                  ( udma_cfg_data_o[7]        ),
         .udma_cfg_data_8_o                  ( udma_cfg_data_o[8]        ),
         .udma_cfg_data_9_o                  ( udma_cfg_data_o[9]        ),
         .udma_cfg_data_10_o                 ( udma_cfg_data_o[10]       ),
         .udma_cfg_data_11_o                 ( udma_cfg_data_o[11]       ),
         .udma_cfg_data_12_o                 ( udma_cfg_data_o[12]       ),
         .udma_cfg_data_13_o                 ( udma_cfg_data_o[13]       ),
         .udma_cfg_data_14_o                 ( udma_cfg_data_o[14]       ),
         .udma_cfg_data_15_o                 ( udma_cfg_data_o[15]       ),
         .udma_cfg_data_16_o                 ( udma_cfg_data_o[16]       ),
         .udma_cfg_data_17_o                 ( udma_cfg_data_o[17]       ),
         .udma_cfg_data_18_o                 ( udma_cfg_data_o[18]       ),
         .udma_cfg_data_19_o                 ( udma_cfg_data_o[19]       ),
         .udma_cfg_data_20_o                 ( udma_cfg_data_o[20]       ),
         .udma_cfg_data_21_o                 ( udma_cfg_data_o[21]       ),
         .udma_cfg_data_22_o                 ( udma_cfg_data_o[22]       ),
         .udma_cfg_data_23_o                 ( udma_cfg_data_o[23]       ),
         .udma_cfg_data_24_o                 ( udma_cfg_data_o[24]       ),
         .udma_cfg_data_25_o                 ( udma_cfg_data_o[25]       ),
         .udma_cfg_data_26_o                 ( udma_cfg_data_o[26]       ),
         .udma_cfg_data_27_o                 ( udma_cfg_data_o[27]       ),
         .udma_cfg_data_28_o                 ( udma_cfg_data_o[28]       ),
         .udma_cfg_data_29_o                 ( udma_cfg_data_o[29]       ),
         .udma_cfg_data_30_o                 ( udma_cfg_data_o[30]       ),
         .udma_cfg_data_31_o                 ( udma_cfg_data_o[31]       ),

         .apb_hwce_prdata_0_o                ( apb_hwce_prdata[0]        ),
         .apb_hwce_prdata_1_o                ( apb_hwce_prdata[1]        ),
         .apb_hwce_prdata_10_o               ( apb_hwce_prdata[10]       ),
         .apb_hwce_prdata_11_o               ( apb_hwce_prdata[11]       ),
         .apb_hwce_prdata_2_o                ( apb_hwce_prdata[2]        ),
         .apb_hwce_prdata_3_o                ( apb_hwce_prdata[3]        ),
         .apb_hwce_prdata_4_o                ( apb_hwce_prdata[4]        ),
         .apb_hwce_prdata_5_o                ( apb_hwce_prdata[5]        ),
         .apb_hwce_prdata_6_o                ( apb_hwce_prdata[6]        ),
         .apb_hwce_prdata_7_o                ( apb_hwce_prdata[7]        ),
         .apb_hwce_prdata_8_o                ( apb_hwce_prdata[8]        ),
         .apb_hwce_prdata_9_o                ( apb_hwce_prdata[9]        ),
         .apb_hwce_prdata_12_o               ( apb_hwce_prdata[12]       ),
         .apb_hwce_prdata_13_o               ( apb_hwce_prdata[13]       ),
         .apb_hwce_prdata_22_o               ( apb_hwce_prdata[22]       ),
         .apb_hwce_prdata_23_o               ( apb_hwce_prdata[23]       ),
         .apb_hwce_prdata_24_o               ( apb_hwce_prdata[24]       ),
         .apb_hwce_prdata_25_o               ( apb_hwce_prdata[25]       ),
         .apb_hwce_prdata_26_o               ( apb_hwce_prdata[26]       ),
         .apb_hwce_prdata_27_o               ( apb_hwce_prdata[27]       ),
         .apb_hwce_prdata_28_o               ( apb_hwce_prdata[28]       ),
         .apb_hwce_prdata_29_o               ( apb_hwce_prdata[29]       ),
         .apb_hwce_prdata_14_o               ( apb_hwce_prdata[14]       ),
         .apb_hwce_prdata_15_o               ( apb_hwce_prdata[15]       ),
         .apb_hwce_prdata_16_o               ( apb_hwce_prdata[16]       ),
         .apb_hwce_prdata_17_o               ( apb_hwce_prdata[17]       ),
         .apb_hwce_prdata_18_o               ( apb_hwce_prdata[18]       ),
         .apb_hwce_prdata_19_o               ( apb_hwce_prdata[19]       ),
         .apb_hwce_prdata_20_o               ( apb_hwce_prdata[20]       ),
         .apb_hwce_prdata_21_o               ( apb_hwce_prdata[21]       ),
         .apb_hwce_prdata_30_o               ( apb_hwce_prdata[30]       ),
         .apb_hwce_prdata_31_o               ( apb_hwce_prdata[31]       ),
         .fpgaio_oe_31_o                       ( fpgaio_oe_o[31]             ),
         .fpgaio_data_31_o                     ( fpgaio_out_o[31]           ),
         .apb_hwce_ready_o                   ( apb_hwce_ready            ),
         .apb_hwce_pslverr_o                 ( apb_hwce_pslverr          ),
         .fpgaio_oe_28_o                       ( fpgaio_oe_o[28]             ),
         .fpgaio_data_28_o                     ( fpgaio_out_o[28]           ),
         .fpgaio_oe_29_o                       ( fpgaio_oe_o[29]             ),
         .fpgaio_data_29_o                     ( fpgaio_out_o[29]           ),
         .fpgaio_oe_30_o                       ( fpgaio_oe_o[30]             ),
         .fpgaio_data_30_o                     ( fpgaio_out_o[30]           ),
         .fpgaio_oe_32_o                       ( fpgaio_oe_o[32]             ),
         .fpgaio_data_32_o                     ( fpgaio_out_o[32]           ),
         .fpgaio_oe_37_o                       ( fpgaio_oe_o[37]             ),
         .fpgaio_data_37_o                     ( fpgaio_out_o[37]           ),
         .fpgaio_oe_38_o                       ( fpgaio_oe_o[38]             ),
         .fpgaio_data_38_o                     ( fpgaio_out_o[38]           ),
         .fpgaio_oe_39_o                       ( fpgaio_oe_o[39]             ),
         .fpgaio_data_39_o                     ( fpgaio_out_o[39]           ),
         .fpgaio_oe_40_o                       ( fpgaio_oe_o[40]             ),
         .fpgaio_data_40_o                     ( fpgaio_out_o[40]           ),

         .fpgaio_oe_33_o                       ( fpgaio_oe_o[33]             ),
         .fpgaio_data_33_o                     ( fpgaio_out_o[33]           ),
         .fpgaio_oe_34_o                       ( fpgaio_oe_o[34]             ),
         .fpgaio_data_34_o                     ( fpgaio_out_o[34]           ),
         .fpgaio_oe_35_o                       ( fpgaio_oe_o[35]             ),
         .fpgaio_data_35_o                     ( fpgaio_out_o[35]           ),
         .fpgaio_oe_36_o                       ( fpgaio_oe_o[36]             ),
         .fpgaio_data_36_o                     ( fpgaio_out_o[36]           ),
         .fpgaio_oe_22_o                       ( fpgaio_oe_o[22]             ),
         .fpgaio_data_22_o                     ( fpgaio_out_o[22]           ),
         .fpgaio_oe_27_o                       ( fpgaio_oe_o[27]             ),
         .fpgaio_data_27_o                     ( fpgaio_out_o[27]           ),
         .fpgaio_oe_23_o                       ( fpgaio_oe_o[23]             ),
         .fpgaio_data_23_o                     ( fpgaio_out_o[23]           ),
         .fpgaio_oe_24_o                       ( fpgaio_oe_o[24]             ),
         .fpgaio_data_24_o                     ( fpgaio_out_o[24]           ),
         .fpgaio_oe_25_o                       ( fpgaio_oe_o[25]             ),
         .fpgaio_data_25_o                     ( fpgaio_out_o[25]           ),
         .fpgaio_oe_26_o                       ( fpgaio_oe_o[26]             ),
         .fpgaio_data_26_o                     ( fpgaio_out_o[26]           ),
         .tcdm_wdata_p3_10_o                 ( tcdm_wdata_fpga[3][10]       ),
         .tcdm_wdata_p3_11_o                 ( tcdm_wdata_fpga[3][11]       ),
         .tcdm_wdata_p3_20_o                 ( tcdm_wdata_fpga[3][20]       ),
         .tcdm_wdata_p3_21_o                 ( tcdm_wdata_fpga[3][21]       ),
         .tcdm_wdata_p3_22_o                 ( tcdm_wdata_fpga[3][22]       ),
         .tcdm_wdata_p3_23_o                 ( tcdm_wdata_fpga[3][23]       ),
         .tcdm_wdata_p3_24_o                 ( tcdm_wdata_fpga[3][24]       ),
         .tcdm_wdata_p3_25_o                 ( tcdm_wdata_fpga[3][25]       ),
         .tcdm_wdata_p3_26_o                 ( tcdm_wdata_fpga[3][26]       ),
         .tcdm_wdata_p3_27_o                 ( tcdm_wdata_fpga[3][27]       ),
         .tcdm_wdata_p3_12_o                 ( tcdm_wdata_fpga[3][12]       ),
         .tcdm_wdata_p3_13_o                 ( tcdm_wdata_fpga[3][13]       ),
         .tcdm_wdata_p3_14_o                 ( tcdm_wdata_fpga[3][14]       ),
         .tcdm_wdata_p3_15_o                 ( tcdm_wdata_fpga[3][15]       ),
         .tcdm_wdata_p3_16_o                 ( tcdm_wdata_fpga[3][16]       ),
         .tcdm_wdata_p3_17_o                 ( tcdm_wdata_fpga[3][17]       ),
         .tcdm_wdata_p3_18_o                 ( tcdm_wdata_fpga[3][18]       ),
         .tcdm_wdata_p3_19_o                 ( tcdm_wdata_fpga[3][19]       ),
         .tcdm_addr_p3_19_o                  ( tcdm_addr_fpga[3][19]        ),
         .tcdm_wen_p3_o                      ( tcdm_wen_fpga[3]             ),
         .tcdm_wdata_p3_8_o                  ( tcdm_wdata_fpga[3][8]        ),
         .tcdm_wdata_p3_9_o                  ( tcdm_wdata_fpga[3][9]        ),
         .tcdm_wdata_p3_0_o                  ( tcdm_wdata_fpga[3][0]        ),
         .tcdm_wdata_p3_1_o                  ( tcdm_wdata_fpga[3][1]        ),
         .tcdm_wdata_p3_2_o                  ( tcdm_wdata_fpga[3][2]        ),
         .tcdm_wdata_p3_3_o                  ( tcdm_wdata_fpga[3][3]        ),
         .tcdm_wdata_p3_4_o                  ( tcdm_wdata_fpga[3][4]        ),
         .tcdm_wdata_p3_5_o                  ( tcdm_wdata_fpga[3][5]        ),
         .tcdm_wdata_p3_6_o                  ( tcdm_wdata_fpga[3][6]        ),
         .tcdm_wdata_p3_7_o                  ( tcdm_wdata_fpga[3][7]        ),
         .tcdm_addr_p3_1_o                   ( tcdm_addr_fpga[3][1]         ),
         .tcdm_addr_p3_2_o                   ( tcdm_addr_fpga[3][2]         ),
         .tcdm_addr_p3_11_o                  ( tcdm_addr_fpga[3][11]        ),
         .tcdm_addr_p3_12_o                  ( tcdm_addr_fpga[3][12]        ),
         .tcdm_addr_p3_13_o                  ( tcdm_addr_fpga[3][13]        ),
         .tcdm_addr_p3_14_o                  ( tcdm_addr_fpga[3][14]        ),
         .tcdm_addr_p3_15_o                  ( tcdm_addr_fpga[3][15]        ),
         .tcdm_addr_p3_16_o                  ( tcdm_addr_fpga[3][16]        ),
         .tcdm_addr_p3_17_o                  ( tcdm_addr_fpga[3][17]        ),
         .tcdm_addr_p3_18_o                  ( tcdm_addr_fpga[3][18]        ),
         .tcdm_addr_p3_3_o                   ( tcdm_addr_fpga[3][3]         ),
         .tcdm_addr_p3_4_o                   ( tcdm_addr_fpga[3][4]         ),
         .tcdm_addr_p3_5_o                   ( tcdm_addr_fpga[3][5]         ),
         .tcdm_addr_p3_6_o                   ( tcdm_addr_fpga[3][6]         ),
         .tcdm_addr_p3_7_o                   ( tcdm_addr_fpga[3][7]         ),
         .tcdm_addr_p3_8_o                   ( tcdm_addr_fpga[3][8]         ),
         .tcdm_addr_p3_9_o                   ( tcdm_addr_fpga[3][9]         ),
         .tcdm_addr_p3_10_o                  ( tcdm_addr_fpga[3][10]        ),
         .tcdm_wdata_p2_26_o                 ( tcdm_wdata_fpga[2][26]       ),
         .tcdm_wdata_p2_27_o                 ( tcdm_wdata_fpga[2][27]       ),
         .tcdm_req_p3_o                      ( tcdm_req_fpga[3]             ),
         .tcdm_addr_p3_0_o                   ( tcdm_addr_fpga[3][0]         ),
         .tcdm_wdata_p2_28_o                 ( tcdm_wdata_fpga[2][28]       ),
         .tcdm_wdata_p2_29_o                 ( tcdm_wdata_fpga[2][29]       ),
         .tcdm_wdata_p2_30_o                 ( tcdm_wdata_fpga[2][30]       ),
         .tcdm_wdata_p2_31_o                 ( tcdm_wdata_fpga[2][31]       ),
         .tcdm_be_p2_0_o                     ( tcdm_be_fpga[2][0]           ),
         .tcdm_be_p2_1_o                     ( tcdm_be_fpga[2][1]           ),
         .tcdm_be_p2_2_o                     ( tcdm_be_fpga[2][2]           ),
         .tcdm_be_p2_3_o                     ( tcdm_be_fpga[2][3]           ),
         .tcdm_wdata_p2_8_o                  ( tcdm_wdata_fpga[2][8]        ),
         .tcdm_wdata_p2_9_o                  ( tcdm_wdata_fpga[2][9]        ),
         .tcdm_wdata_p2_18_o                 ( tcdm_wdata_fpga[2][18]       ),
         .tcdm_wdata_p2_19_o                 ( tcdm_wdata_fpga[2][19]       ),
         .tcdm_wdata_p2_20_o                 ( tcdm_wdata_fpga[2][20]       ),
         .tcdm_wdata_p2_21_o                 ( tcdm_wdata_fpga[2][21]       ),
         .tcdm_wdata_p2_22_o                 ( tcdm_wdata_fpga[2][22]       ),
         .tcdm_wdata_p2_23_o                 ( tcdm_wdata_fpga[2][23]       ),
         .tcdm_wdata_p2_24_o                 ( tcdm_wdata_fpga[2][24]       ),
         .tcdm_wdata_p2_25_o                 ( tcdm_wdata_fpga[2][25]       ),
         .tcdm_wdata_p2_10_o                 ( tcdm_wdata_fpga[2][10]       ),
         .tcdm_wdata_p2_11_o                 ( tcdm_wdata_fpga[2][11]       ),
         .tcdm_wdata_p2_12_o                 ( tcdm_wdata_fpga[2][12]       ),
         .tcdm_wdata_p2_13_o                 ( tcdm_wdata_fpga[2][13]       ),
         .tcdm_wdata_p2_14_o                 ( tcdm_wdata_fpga[2][14]       ),
         .tcdm_wdata_p2_15_o                 ( tcdm_wdata_fpga[2][15]       ),
         .tcdm_wdata_p2_16_o                 ( tcdm_wdata_fpga[2][16]       ),
         .tcdm_wdata_p2_17_o                 ( tcdm_wdata_fpga[2][17]       ),
         .tcdm_addr_p2_17_o                  ( tcdm_addr_fpga[2][17]        ),
         .tcdm_addr_p2_18_o                  ( tcdm_addr_fpga[2][18]        ),
         .tcdm_wdata_p2_6_o                  ( tcdm_wdata_fpga[2][6]        ),
         .tcdm_wdata_p2_7_o                  ( tcdm_wdata_fpga[2][7]        ),
         .tcdm_addr_p2_19_o                  ( tcdm_addr_fpga[2][19]        ),
         .tcdm_wen_p2_o                      ( tcdm_wen_fpga[2]             ),
         .tcdm_wdata_p2_0_o                  ( tcdm_wdata_fpga[2][0]        ),
         .tcdm_wdata_p2_1_o                  ( tcdm_wdata_fpga[2][1]        ),
         .tcdm_wdata_p2_2_o                  ( tcdm_wdata_fpga[2][2]        ),
         .tcdm_wdata_p2_3_o                  ( tcdm_wdata_fpga[2][3]        ),
         .tcdm_wdata_p2_4_o                  ( tcdm_wdata_fpga[2][4]        ),
         .tcdm_wdata_p2_5_o                  ( tcdm_wdata_fpga[2][5]        ),
         .tcdm_req_p2_o                      ( tcdm_req_fpga[2]             ),
         .tcdm_addr_p2_0_o                   ( tcdm_addr_fpga[2][0]         ),
         .tcdm_addr_p2_9_o                   ( tcdm_addr_fpga[2][9]         ),
         .tcdm_addr_p2_10_o                  ( tcdm_addr_fpga[2][10]        ),
         .tcdm_addr_p2_11_o                  ( tcdm_addr_fpga[2][11]        ),
         .tcdm_addr_p2_12_o                  ( tcdm_addr_fpga[2][12]        ),
         .tcdm_addr_p2_13_o                  ( tcdm_addr_fpga[2][13]        ),
         .tcdm_addr_p2_14_o                  ( tcdm_addr_fpga[2][14]        ),
         .tcdm_addr_p2_15_o                  ( tcdm_addr_fpga[2][15]        ),
         .tcdm_addr_p2_16_o                  ( tcdm_addr_fpga[2][16]        ),
         .tcdm_addr_p2_1_o                   ( tcdm_addr_fpga[2][1]         ),
         .tcdm_addr_p2_2_o                   ( tcdm_addr_fpga[2][2]         ),
         .tcdm_addr_p2_3_o                   ( tcdm_addr_fpga[2][3]         ),
         .tcdm_addr_p2_4_o                   ( tcdm_addr_fpga[2][4]         ),
         .tcdm_addr_p2_5_o                   ( tcdm_addr_fpga[2][5]         ),
         .tcdm_addr_p2_6_o                   ( tcdm_addr_fpga[2][6]         ),
         .tcdm_addr_p2_7_o                   ( tcdm_addr_fpga[2][7]         ),
         .tcdm_addr_p2_8_o                   ( tcdm_addr_fpga[2][8]         ),
         .tcdm_req_p0_o                      ( tcdm_req_fpga[0]             ),
         .tcdm_addr_p0_0_o                   ( tcdm_addr_fpga[0][0]         ),
         .tcdm_addr_p0_9_o                   ( tcdm_addr_fpga[0][9]         ),
         .tcdm_addr_p0_10_o                  ( tcdm_addr_fpga[0][10]        ),
         .tcdm_addr_p0_1_o                   ( tcdm_addr_fpga[0][1]         ),
         .tcdm_addr_p0_2_o                   ( tcdm_addr_fpga[0][2]         ),
         .tcdm_addr_p0_3_o                   ( tcdm_addr_fpga[0][3]         ),
         .tcdm_addr_p0_4_o                   ( tcdm_addr_fpga[0][4]         ),
         .tcdm_addr_p0_5_o                   ( tcdm_addr_fpga[0][5]         ),
         .tcdm_addr_p0_6_o                   ( tcdm_addr_fpga[0][6]         ),
         .tcdm_addr_p0_7_o                   ( tcdm_addr_fpga[0][7]         ),
         .tcdm_addr_p0_8_o                   ( tcdm_addr_fpga[0][8]         ),
         .tcdm_addr_p0_11_o                  ( tcdm_addr_fpga[0][11]        ),
         .tcdm_addr_p0_12_o                  ( tcdm_addr_fpga[0][12]        ),
         .tcdm_wdata_p0_0_o                  ( tcdm_wdata_fpga[0][0]        ),
         .tcdm_wdata_p0_1_o                  ( tcdm_wdata_fpga[0][1]        ),
         .tcdm_wdata_p0_2_o                  ( tcdm_wdata_fpga[0][2]        ),
         .tcdm_wdata_p0_3_o                  ( tcdm_wdata_fpga[0][3]        ),
         .tcdm_wdata_p0_4_o                  ( tcdm_wdata_fpga[0][4]        ),
         .tcdm_wdata_p0_5_o                  ( tcdm_wdata_fpga[0][5]        ),
         .tcdm_wdata_p0_6_o                  ( tcdm_wdata_fpga[0][6]        ),
         .tcdm_wdata_p0_7_o                  ( tcdm_wdata_fpga[0][7]        ),
         .tcdm_addr_p0_13_o                  ( tcdm_addr_fpga[0][13]        ),
         .tcdm_addr_p0_14_o                  ( tcdm_addr_fpga[0][14]        ),
         .tcdm_addr_p0_15_o                  ( tcdm_addr_fpga[0][15]        ),
         .tcdm_addr_p0_16_o                  ( tcdm_addr_fpga[0][16]        ),
         .tcdm_addr_p0_17_o                  ( tcdm_addr_fpga[0][17]        ),
         .tcdm_addr_p0_18_o                  ( tcdm_addr_fpga[0][18]        ),
         .tcdm_addr_p0_19_o                  ( tcdm_addr_fpga[0][19]        ),
         .tcdm_wen_p0_o                      ( tcdm_wen_fpga[0]             ),
         .tcdm_wdata_p0_8_o                  ( tcdm_wdata_fpga[0][8]        ),
         .tcdm_wdata_p0_9_o                  ( tcdm_wdata_fpga[0][9]        ),
         .tcdm_wdata_p0_18_o                 ( tcdm_wdata_fpga[0][18]       ),
         .tcdm_wdata_p0_19_o                 ( tcdm_wdata_fpga[0][19]       ),
         .tcdm_wdata_p0_10_o                 ( tcdm_wdata_fpga[0][10]       ),
         .tcdm_wdata_p0_11_o                 ( tcdm_wdata_fpga[0][11]       ),
         .tcdm_wdata_p0_12_o                 ( tcdm_wdata_fpga[0][12]       ),
         .tcdm_wdata_p0_13_o                 ( tcdm_wdata_fpga[0][13]       ),
         .tcdm_wdata_p0_14_o                 ( tcdm_wdata_fpga[0][14]       ),
         .tcdm_wdata_p0_15_o                 ( tcdm_wdata_fpga[0][15]       ),
         .tcdm_wdata_p0_16_o                 ( tcdm_wdata_fpga[0][16]       ),
         .tcdm_wdata_p0_17_o                 ( tcdm_wdata_fpga[0][17]       ),
         .tcdm_wdata_p0_20_o                 ( tcdm_wdata_fpga[0][20]       ),
         .tcdm_wdata_p0_21_o                 ( tcdm_wdata_fpga[0][21]       ),
         .tcdm_wdata_p0_30_o                 ( tcdm_wdata_fpga[0][30]       ),
         .tcdm_wdata_p0_31_o                 ( tcdm_wdata_fpga[0][31]       ),
         .tcdm_be_p0_0_o                     ( tcdm_be_fpga[0][0]           ),
         .tcdm_be_p0_1_o                     ( tcdm_be_fpga[0][1]           ),
         .tcdm_be_p0_2_o                     ( tcdm_be_fpga[0][2]           ),
         .tcdm_be_p0_3_o                     ( tcdm_be_fpga[0][3]           ),
         .tcdm_req_p1_o                      ( tcdm_req_fpga[1]             ),
         .tcdm_addr_p1_0_o                   ( tcdm_addr_fpga[1][0]         ),
         .tcdm_wdata_p0_22_o                 ( tcdm_wdata_fpga[0][22]       ),
         .tcdm_wdata_p0_23_o                 ( tcdm_wdata_fpga[0][23]       ),
         .tcdm_wdata_p0_24_o                 ( tcdm_wdata_fpga[0][24]       ),
         .tcdm_wdata_p0_25_o                 ( tcdm_wdata_fpga[0][25]       ),
         .tcdm_wdata_p0_26_o                 ( tcdm_wdata_fpga[0][26]       ),
         .tcdm_wdata_p0_27_o                 ( tcdm_wdata_fpga[0][27]       ),
         .tcdm_wdata_p0_28_o                 ( tcdm_wdata_fpga[0][28]       ),
         .tcdm_wdata_p0_29_o                 ( tcdm_wdata_fpga[0][29]       ),
         .tcdm_addr_p1_1_o                   ( tcdm_addr_fpga[1][1]         ),
         .tcdm_addr_p1_2_o                   ( tcdm_addr_fpga[1][2]         ),
         .tcdm_addr_p1_11_o                  ( tcdm_addr_fpga[1][11]        ),
         .tcdm_addr_p1_12_o                  ( tcdm_addr_fpga[1][12]        ),
         .tcdm_addr_p1_3_o                   ( tcdm_addr_fpga[1][3]         ),
         .tcdm_addr_p1_4_o                   ( tcdm_addr_fpga[1][4]         ),
         .tcdm_addr_p1_5_o                   ( tcdm_addr_fpga[1][5]         ),
         .tcdm_addr_p1_6_o                   ( tcdm_addr_fpga[1][6]         ),
         .tcdm_addr_p1_7_o                   ( tcdm_addr_fpga[1][7]         ),
         .tcdm_addr_p1_8_o                   ( tcdm_addr_fpga[1][8]         ),
         .tcdm_addr_p1_9_o                   ( tcdm_addr_fpga[1][9]         ),
         .tcdm_addr_p1_10_o                  ( tcdm_addr_fpga[1][10]        ),
         .tcdm_addr_p1_13_o                  ( tcdm_addr_fpga[1][13]        ),
         .tcdm_addr_p1_14_o                  ( tcdm_addr_fpga[1][14]        ),
         .tcdm_wdata_p1_2_o                  ( tcdm_wdata_fpga[1][2]        ),
         .tcdm_wdata_p1_3_o                  ( tcdm_wdata_fpga[1][3]        ),
         .tcdm_wdata_p1_4_o                  ( tcdm_wdata_fpga[1][4]        ),
         .tcdm_wdata_p1_5_o                  ( tcdm_wdata_fpga[1][5]        ),
         .tcdm_wdata_p1_6_o                  ( tcdm_wdata_fpga[1][6]        ),
         .tcdm_wdata_p1_7_o                  ( tcdm_wdata_fpga[1][7]        ),
         .tcdm_wdata_p1_8_o                  ( tcdm_wdata_fpga[1][8]        ),
         .tcdm_wdata_p1_9_o                  ( tcdm_wdata_fpga[1][9]        ),
         .tcdm_addr_p1_15_o                  ( tcdm_addr_fpga[1][15]        ),
         .tcdm_addr_p1_16_o                  ( tcdm_addr_fpga[1][16]        ),
         .tcdm_addr_p1_17_o                  ( tcdm_addr_fpga[1][17]        ),
         .tcdm_addr_p1_18_o                  ( tcdm_addr_fpga[1][18]        ),
         .tcdm_addr_p1_19_o                  ( tcdm_addr_fpga[1][19]        ),
         .tcdm_wen_p1_o                      ( tcdm_wen_fpga[1]             ),
         .tcdm_wdata_p1_0_o                  ( tcdm_wdata_fpga[1][0]        ),
         .tcdm_wdata_p1_1_o                  ( tcdm_wdata_fpga[1][1]        ),
         .tcdm_wdata_p1_10_o                 ( tcdm_wdata_fpga[1][10]       ),
         .tcdm_wdata_p1_11_o                 ( tcdm_wdata_fpga[1][11]       ),
         .tcdm_wdata_p1_20_o                 ( tcdm_wdata_fpga[1][20]       ),
         .tcdm_wdata_p1_21_o                 ( tcdm_wdata_fpga[1][21]       ),
         .tcdm_wdata_p1_12_o                 ( tcdm_wdata_fpga[1][12]       ),
         .tcdm_wdata_p1_13_o                 ( tcdm_wdata_fpga[1][13]       ),
         .tcdm_wdata_p1_14_o                 ( tcdm_wdata_fpga[1][14]       ),
         .tcdm_wdata_p1_15_o                 ( tcdm_wdata_fpga[1][15]       ),
         .tcdm_wdata_p1_16_o                 ( tcdm_wdata_fpga[1][16]       ),
         .tcdm_wdata_p1_17_o                 ( tcdm_wdata_fpga[1][17]       ),
         .tcdm_wdata_p1_18_o                 ( tcdm_wdata_fpga[1][18]       ),
         .tcdm_wdata_p1_19_o                 ( tcdm_wdata_fpga[1][19]       ),
         .tcdm_wdata_p1_22_o                 ( tcdm_wdata_fpga[1][22]       ),
         .tcdm_wdata_p1_23_o                 ( tcdm_wdata_fpga[1][23]       ),
         .tcdm_be_p1_0_o                     ( tcdm_be_fpga[1][0]           ),
         .tcdm_be_p1_1_o                     ( tcdm_be_fpga[1][1]           ),
         .tcdm_be_p1_2_o                     ( tcdm_be_fpga[1][2]           ),
         .tcdm_be_p1_3_o                     ( tcdm_be_fpga[1][3]           ),
         .fpgaio_oe_8_o                        ( fpgaio_oe_o[8]              ),
         .fpgaio_data_8_o                      ( fpgaio_out_o[8]            ),
         .fpgaio_oe_9_o                        ( fpgaio_oe_o[9]              ),
         .fpgaio_data_9_o                      ( fpgaio_out_o[9]            ),
         .tcdm_wdata_p1_24_o                 ( tcdm_wdata_fpga[1][24]       ),
         .tcdm_wdata_p1_25_o                 ( tcdm_wdata_fpga[1][25]       ),
         .tcdm_wdata_p1_26_o                 ( tcdm_wdata_fpga[1][26]       ),
         .tcdm_wdata_p1_27_o                 ( tcdm_wdata_fpga[1][27]       ),
         .tcdm_wdata_p1_28_o                 ( tcdm_wdata_fpga[1][28]       ),
         .tcdm_wdata_p1_29_o                 ( tcdm_wdata_fpga[1][29]       ),
         .tcdm_wdata_p1_30_o                 ( tcdm_wdata_fpga[1][30]       ),
         .tcdm_wdata_p1_31_o                 ( tcdm_wdata_fpga[1][31]       ),
         .fpgaio_oe_10_o                       ( fpgaio_oe_o[10]             ),
         .fpgaio_data_10_o                     ( fpgaio_out_o[10]           ),
         .fpgaio_oe_11_o                       ( fpgaio_oe_o[11]             ),
         .fpgaio_data_11_o                     ( fpgaio_out_o[11]           ),
         .fpgaio_oe_14_o                       ( fpgaio_oe_o[14]             ),
         .fpgaio_data_14_o                     ( fpgaio_out_o[14]           ),
         .fpgaio_oe_15_o                       ( fpgaio_oe_o[15]             ),
         .fpgaio_data_15_o                     ( fpgaio_out_o[15]           ),
         .tcdm_wdata_p3_28_o                 ( tcdm_wdata_fpga[3][28]       ),
         .tcdm_wdata_p3_29_o                 ( tcdm_wdata_fpga[3][29]       ),
         .fpgaio_oe_13_o                       ( fpgaio_oe_o[13]             ),
         .fpgaio_data_13_o                     ( fpgaio_out_o[13]           ),
         .tcdm_wdata_p3_30_o                 ( tcdm_wdata_fpga[3][30]       ),
         .tcdm_wdata_p3_31_o                 ( tcdm_wdata_fpga[3][31]       ),
         .tcdm_be_p3_0_o                     ( tcdm_be_fpga[3][0]           ),
         .tcdm_be_p3_1_o                     ( tcdm_be_fpga[3][1]           ),
         .tcdm_be_p3_2_o                     ( tcdm_be_fpga[3][2]           ),
         .tcdm_be_p3_3_o                     ( tcdm_be_fpga[3][3]           ),
         .fpgaio_oe_12_o                       ( fpgaio_oe_o[12]             ),
         .fpgaio_data_12_o                     ( fpgaio_out_o[12]           )
       );

endmodule
