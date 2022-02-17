// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
`include "pulp_soc_defines.svh"

module efpga_subsystem #(
    parameter L2_ADDR_WIDTH       = 32,
    parameter APB_FPGA_ADDR_WIDTH = 20
) (
    input logic asic_clk_i,
    input logic fpga_clk0_i,
    input logic fpga_clk1_i,
    input logic fpga_clk2_i,
    input logic fpga_clk3_i,
    input logic fpga_clk4_i,
    input logic fpga_clk5_i,

    input logic       clk_gating_dc_fifo_i,
    input logic [3:0] reset_type1_efpga_i,
    input logic       enable_udma_efpga_i,
    input logic       enable_events_efpga_i,
    input logic       enable_apb_efpga_i,
    input logic       enable_tcdm3_efpga_i,
    input logic       enable_tcdm2_efpga_i,
    input logic       enable_tcdm1_efpga_i,
    input logic       enable_tcdm0_efpga_i,

    input logic        rst_n,
    input logic [31:0] control_in,

    XBAR_TCDM_BUS.Master l2_asic_tcdm_o[`N_EFPGA_TCDM_PORTS-1:0],
    APB_BUS.Slave apbprogram_i,
    XBAR_TCDM_BUS.Slave apbt1_i,


    output       [               31:0] status_out,
    output       [                7:0] version,
    output logic [      `N_FPGAIO-1:0] fpgaio_oe_o,
    input  logic [      `N_FPGAIO-1:0] fpgaio_in_i,
    output logic [      `N_FPGAIO-1:0] fpgaio_out_o,
    output logic [`N_EFPGA_EVENTS-1:0] efpga_event_o,

    //eFPGA TEST MODE
    output logic [15:0] testio_o,
    input  logic [20:0] testio_i
);

  // FCB Test

  logic [3:0] efpga_test_fcb_pif_do_l_o;
  logic [3:0] efpga_test_fcb_pif_do_h_o;
  logic [3:0] efpga_test_FB_SPE_OUT_o;
  logic       efpga_test_fcb_pif_do_l_en_o;
  logic       efpga_test_fcb_pif_do_h_en_o;
  logic       efpga_fcb_pif_vldo_o;
  logic       efpga_fcb_pif_vldo_en_o;


  assign testio_o[3:0]  = efpga_test_fcb_pif_do_l_o;
  assign testio_o[7:4]  = efpga_test_fcb_pif_do_h_o;
  assign testio_o[11:8] = efpga_test_FB_SPE_OUT_o;
  assign testio_o[12]   = efpga_test_fcb_pif_do_l_en_o;
  assign testio_o[13]   = efpga_test_fcb_pif_do_h_en_o;
  assign testio_o[14]   = efpga_fcb_pif_vldo_o;
  assign testio_o[15]   = efpga_fcb_pif_vldo_en_o;




  logic       efpga_STM_i;
  logic       efpga_test_fcb_pif_vldi_i;
  logic [3:0] efpga_test_fcb_pif_di_l_i;
  logic [3:0] efpga_test_fcb_pif_di_h_i;
  logic [3:0] efpga_test_FB_SPE_IN_i;
  logic [5:0] efpga_test_M_i;
  logic       efpga_test_MLATCH_i;




  assign efpga_test_fcb_pif_di_l_i = testio_i[3:0];
  assign efpga_test_fcb_pif_di_h_i = testio_i[7:4];
  assign efpga_test_FB_SPE_IN_i = testio_i[11:8];
  assign efpga_test_M_i = testio_i[17:12];
  assign efpga_test_MLATCH_i = testio_i[18];
  assign efpga_test_fcb_pif_vldi_i = testio_i[19];
  assign efpga_STM_i = testio_i[20];



  //FCB connections
  logic fcb2efpga_blclk;
  logic fcb2efpga_re, fcb2efpga_we;
  logic fcb2efpga_we_int, fcb2efpga_pchg_b;
  logic [31:0] fcb2efpga_bl_din, efpga2fcb_bl_dout;
  logic fcb2efpga_cload_din_sel, fcb2efpga_din_slc_tb_int;
  logic fcb2efpga_din_int_l_only, fcb2efpga_din_int_r_only;
  logic [15:0] fcb2efpga_bl_pwrgate;
  logic [ 7:0] fcb2efpga_wl_pwrgate;
  logic [ 2:0] fcb2efpga_wl_cload_sel;
  logic [15:0] fcb2efpga_wl_sel;
  logic [ 5:0] fcb2efpga_wl_din;
  logic [15:0] fcb2efpga_prog;
  logic        fcb2efpga_prog_ifx;

  logic [15:0] fcb2efpga_iso_en;
  logic [15:0] fcb2efpga_pi_pwr;
  logic [15:0] fcb2efpga_vlp_clkdis;
  logic        fcb2efpga_vlp_clkdis_ifx;
  logic [15:0] fcb2efpga_vlp_srdis;
  logic        fcb2efpga_vlp_srdis_ifx;
  logic [15:0] fcb2efpga_vlp_pwrdis;
  logic        fcb2efpga_vlp_pwrdis_ifx;
  logic        fcb2efpga_wlclk;
  logic        fcb2efpga_wl_resetb;
  logic        fcb2efpga_wl_en;
  logic        fcb2efpga_wl_int_din_sel;
  logic        fcb2efpga_wl_sel_tb_int;
  logic        fcb2efpga_fb_iso_enb;
  logic        fcb2efpga_pwr_gate;
  logic        fcb2efpga_set_por;
  logic        efpga2fcb_pif_en;
  logic        efpga_por;



  logic        fcb_fb_cfg_done;
  logic        efpga_clock;

  logic [31:0] control_in_d1, control_in_d2, efpga_control_in;
  logic control_in_valid;


  XBAR_TCDM_BUS l2_efpga_tcdm[`N_EFPGA_TCDM_PORTS-1:0] ();
  logic [`N_EFPGA_TCDM_PORTS-1:0] tcdm_clk;
  logic [`N_EFPGA_TCDM_PORTS-1:0] tcdm_req_fpga, tcdm_req_fpga_gated;
  logic [`N_EFPGA_TCDM_PORTS-1:0][APB_FPGA_ADDR_WIDTH-1:0] tcdm_addr_fpga;
  logic [`N_EFPGA_TCDM_PORTS-1:0]                          tcdm_wen_fpga;
  logic [`N_EFPGA_TCDM_PORTS-1:0][                   31:0] tcdm_wdata_fpga;
  logic [`N_EFPGA_TCDM_PORTS-1:0][                   31:0] tcdm_rdata_fpga;
  logic [`N_EFPGA_TCDM_PORTS-1:0][                    3:0] tcdm_be_fpga;
  logic [`N_EFPGA_TCDM_PORTS-1:0]                          tcdm_gnt_fpga;
  logic [`N_EFPGA_TCDM_PORTS-1:0]                          tcdm_fmo_fpga;
  logic [`N_EFPGA_TCDM_PORTS-1:0]                          tcdm_valid_fpga;

  /*

        CONFIGURATION PORTS

    */

  /*
       Type1 APB interface
    */


  XBAR_TCDM_BUS apbt1_int ();

  logic s_lint_VALID, s_lint_GNT, s_lint_REQ;

  logic s_efpga_clk;
  logic [`N_EFPGA_EVENTS-1:0] s_event, event_gate, event_edge, wedge_ack;
  logic wen_p3, qualified_valid_p3;
  logic wen_p2, qualified_valid_p2;
  logic wen_p1, qualified_valid_p1;
  logic wen_p0, qualified_valid_p0;

  logic reset_hi;
  assign reset_hi = ~rst_n;
  assign efpga_por = reset_hi | fcb2efpga_set_por;
  assign qualified_valid_p3 = l2_asic_tcdm_o[3].r_valid & wen_p3;
  assign qualified_valid_p2 = l2_asic_tcdm_o[2].r_valid & wen_p2;
  assign qualified_valid_p1 = l2_asic_tcdm_o[1].r_valid & wen_p1;
  assign qualified_valid_p0 = l2_asic_tcdm_o[0].r_valid & wen_p0;
  always @(posedge asic_clk_i or negedge rst_n) begin
    if (~rst_n) begin
      control_in_valid <= 0;
      control_in_d1 <= 0;
      control_in_d2 <= 0;
    end else begin
      control_in_d1 <= control_in;
      control_in_d2 <= control_in_d1;
      control_in_valid <= (control_in_d2 == control_in) && (control_in_d1 == control_in);
    end
  end
  always @(posedge s_efpga_clk or negedge rst_n) begin
    if (~rst_n) efpga_control_in <= 0;
    else if (control_in_valid) efpga_control_in <= control_in_d1;
  end


  always @(posedge asic_clk_i or negedge rst_n) begin
    if (~rst_n) begin
      wen_p3 <= 1'b1;  // default read
      wen_p2 <= 1'b1;  // default read
      wen_p1 <= 1'b1;  // default read
      wen_p0 <= 1'b1;  // default read
    end else begin
      wen_p3 <= l2_asic_tcdm_o[3].req ? l2_asic_tcdm_o[3].wen : wen_p3;
      wen_p2 <= l2_asic_tcdm_o[2].req ? l2_asic_tcdm_o[2].wen : wen_p2;
      wen_p1 <= l2_asic_tcdm_o[1].req ? l2_asic_tcdm_o[1].wen : wen_p1;
      wen_p0 <= l2_asic_tcdm_o[0].req ? l2_asic_tcdm_o[0].wen : wen_p0;
    end  // else: !if(~rst_n)
  end  // always @ (posedge asic_clk_i or negedge rst_n)



  generate
    for (genvar g_tcdm = 0; g_tcdm < `N_EFPGA_TCDM_PORTS; g_tcdm++) begin : DC_FIFO_TCDM_EFPGA

      tcdm_interface efpga_tcdm (
          .efpga_rst(reset_hi),
          .efpga_clk(tcdm_clk[g_tcdm]),
          .efpga_req(tcdm_req_fpga_gated[g_tcdm]),
          .efpga_gnt(l2_efpga_tcdm[g_tcdm].gnt),  //(tcdm_gnt_fpga[g_tcdm]),
          .efpga_fmo(tcdm_fmo_fpga[g_tcdm]),
          .efpga_valid(l2_efpga_tcdm[g_tcdm].r_valid),  //(tcdm_valid_fpga[g_tcdm]),
          .efpga_req_data({
            tcdm_wen_fpga[g_tcdm],
            tcdm_addr_fpga[g_tcdm][APB_FPGA_ADDR_WIDTH-1:0],
            tcdm_be_fpga[g_tcdm],
            tcdm_wdata_fpga[g_tcdm]
          }),
          .soc_req_data({
            l2_asic_tcdm_o[g_tcdm].wen,
            l2_asic_tcdm_o[g_tcdm].add[APB_FPGA_ADDR_WIDTH-1:0],
            l2_asic_tcdm_o[g_tcdm].be,
            l2_asic_tcdm_o[g_tcdm].wdata
          }),
          .efpga_rdata(l2_efpga_tcdm[g_tcdm].r_rdata),  //(tcdm_rdata_fpga[g_tcdm]),
          .soc_rdata(l2_asic_tcdm_o[g_tcdm].r_rdata),
          .soc_rst(reset_hi),
          .soc_clk(asic_clk_i),
          .soc_req(l2_asic_tcdm_o[g_tcdm].req),
          .soc_gnt(l2_asic_tcdm_o[g_tcdm].gnt),
          .soc_valid(l2_asic_tcdm_o[g_tcdm].r_valid)
      );
      assign l2_asic_tcdm_o[g_tcdm].add[31:20] = 12'h1C0;

`ifndef SYNTHESIS
      assign #1 l2_efpga_tcdm[g_tcdm].req   = tcdm_req_fpga_gated[g_tcdm];
      assign #1 l2_efpga_tcdm[g_tcdm].add   = tcdm_addr_fpga[g_tcdm];
      assign #1 l2_efpga_tcdm[g_tcdm].wen   = tcdm_wen_fpga[g_tcdm];
      assign #1 l2_efpga_tcdm[g_tcdm].wdata = tcdm_wdata_fpga[g_tcdm];
      assign #1 l2_efpga_tcdm[g_tcdm].be    = tcdm_be_fpga[g_tcdm];
`else
      assign l2_efpga_tcdm[g_tcdm].req   = tcdm_req_fpga_gated[g_tcdm];
      assign l2_efpga_tcdm[g_tcdm].add   = tcdm_addr_fpga[g_tcdm];
      assign l2_efpga_tcdm[g_tcdm].wen   = tcdm_wen_fpga[g_tcdm];
      assign l2_efpga_tcdm[g_tcdm].wdata = tcdm_wdata_fpga[g_tcdm];
      assign l2_efpga_tcdm[g_tcdm].be    = tcdm_be_fpga[g_tcdm];
`endif
      assign tcdm_gnt_fpga[g_tcdm]   = l2_efpga_tcdm[g_tcdm].gnt;
      assign tcdm_rdata_fpga[g_tcdm] = l2_efpga_tcdm[g_tcdm].r_rdata;
      assign tcdm_valid_fpga[g_tcdm] = l2_efpga_tcdm[g_tcdm].r_valid;
    end
  endgenerate


  apbt1_interface apbt1_interface (
      .lint_rst(reset_hi),
      .lint_clk(asic_clk_i),
      .lint_req(s_lint_REQ),
      .lint_gnt(s_lint_GNT),  //(tcdm_gnt_fpga[g_tcdm]),
      .lint_fmo(),
      .lint_valid(s_lint_VALID),  //(tcdm_valid_fpga[g_tcdm]),
      .lint_req_data({
        apbt1_i.wen, apbt1_i.add[APB_FPGA_ADDR_WIDTH-1:0], apbt1_i.be, apbt1_i.wdata
      }),
      .efpga_req_data({
        apbt1_int.wen, apbt1_int.add[APB_FPGA_ADDR_WIDTH-1:0], apbt1_int.be, apbt1_int.wdata
      }),
      .lint_rdata(apbt1_i.r_rdata),  //(tcdm_rdata_fpga[g_tcdm]),
      .efpga_rdata(apbt1_int.r_rdata),
      .efpga_rst(reset_hi),
      .efpga_clk(s_efpga_clk),
      .efpga_req(apbt1_int.req),
      .efpga_gnt(apbt1_int.gnt),
      .efpga_valid(apbt1_int.r_valid)
  );

  /*
   
  log_int_dc_slice #(
      .ADDR_WIDTH(20)
  ) logint_dc_efpga_apbt1 (
      .push_clk    (asic_clk_i),
      .push_rst_n  (enable_apb_efpga_i), //(rst_n),
      .data_req_i  (s_lint_REQ),
      .data_add_i  (apbt1_i.add[19:0]),
      .data_wen_i  (apbt1_i.wen),
      .data_wdata_i(apbt1_i.wdata),
      .data_be_i   (apbt1_i.be),
      .data_ID_i   (4'b0000),
      .data_gnt_o  (s_lint_GNT),

      .data_r_valid_o(s_lint_VALID),
      .data_r_rdata_o(apbt1_i.r_rdata),
      .data_r_ID_o   (),
      .data_req_o  (apbt1_int.req),
      .data_add_o  (apbt1_int.add[19:0]),
      .data_wen_o  (apbt1_int.wen),
      .data_wdata_o(apbt1_int.wdata),
      .data_be_o   (apbt1_int.be),
      .data_ID_o   (),
      .data_gnt_i  (apbt1_int.gnt),
      .data_r_valid_i(apbt1_int.r_valid),
      .data_r_rdata_i(apbt1_int.r_rdata),
      .data_r_ID_i   ('0),
      .pop_clk(s_efpga_clk),
      .pop_rst_n(enable_apb_efpga_i),//(rst_n),
      .test_cgbypass_i('0)


  );
 */
  /*
      EVENT Propagation from EFPGA to ASIC

    */
  generate
    for (genvar g_event = 0; g_event < `N_EFPGA_EVENTS; g_event++) begin : event_wedge_edge
      pulp_sync_wedge i_wedge_efpga (
          .clk_i(asic_clk_i),
          .rstn_i(rst_n),
          .en_i(1'b1),
          .serial_i(event_edge[g_event]),
          .serial_o(wedge_ack[g_event]),
          .r_edge_o(efpga_event_o[g_event]),
          .f_edge_o()
      );
      edge_propagator_tx i_prop_efpga (
          .clk_i  (s_efpga_clk),
          .rstn_i (rst_n),
          .valid_i(event_gate[g_event]),
          .ack_i  (wedge_ack[g_event]),
          .valid_o(event_edge[g_event])
      );
    end
  endgenerate

  logic [4:0] d_lint_GNT;
  always @(posedge asic_clk_i or negedge rst_n) begin
    if (rst_n == 0) begin
      d_lint_GNT <= 0;
    end else begin
      if (apbt1_i.req == 0) d_lint_GNT <= '0;
      else d_lint_GNT <= {d_lint_GNT[3:0], apbt1_i.req};

      //           d_lint_GNT <= {((apbt1_i.req & ~apbt1_i.wen & s_lint_GNT) | d_lint_GNT[0]),s_lint_GNT};
    end
  end

`ifndef SYNTHESIS
  assign #1 event_gate = s_event & {`N_EFPGA_EVENTS{enable_events_efpga_i}};
`else
  assign event_gate = s_event & {`N_EFPGA_EVENTS{enable_events_efpga_i}};
`endif
  assign apbt1_i.r_valid = enable_apb_efpga_i ? s_lint_VALID : 1;  // always valid if not enabled
  assign apbt1_i.gnt    = enable_apb_efpga_i ? d_lint_GNT[4] & s_lint_GNT : apbt1_i.req;   // always granted if not enabled
  assign s_lint_REQ = enable_apb_efpga_i ? apbt1_i.req & ~(d_lint_GNT[0] | d_lint_GNT[1]) : 0;

  assign tcdm_req_fpga_gated[3] = enable_tcdm3_efpga_i & tcdm_req_fpga[3] & tcdm_gnt_fpga[3];
  assign tcdm_req_fpga_gated[2] = enable_tcdm1_efpga_i & tcdm_req_fpga[2] & tcdm_gnt_fpga[2];
  assign tcdm_req_fpga_gated[1] = enable_tcdm2_efpga_i & tcdm_req_fpga[1] & tcdm_gnt_fpga[1];
  assign tcdm_req_fpga_gated[0] = enable_tcdm0_efpga_i & tcdm_req_fpga[0] & tcdm_gnt_fpga[0];



  fcb U_fcb (
      // Outputs
      .fcb_cfg_done(),  //done
      .fcb_cfg_done_en(),  //done
      .fcb_spim_mosi(),  //done
      .fcb_spim_mosi_en(),  //done
      .fcb_spim_cs_n(),  //done
      .fcb_spim_cs_n_en(),  // done
      .fcb_spim_ckout(),  // done
      .fcb_spim_ckout_en(),  // done
      .fcb_spis_miso(),  //done
      .fcb_spis_miso_en(),  //done
      .fcb_pif_vldo(efpga_fcb_pif_vldo_o),  //done
      .fcb_pif_vldo_en(efpga_fcb_pif_vldo_en_o),  //done
      .fcb_pif_do_l(efpga_test_fcb_pif_do_l_o),
      .fcb_pif_do_l_en(efpga_test_fcb_pif_do_l_en_o),  //done
      .fcb_pif_do_h(efpga_test_fcb_pif_do_h_o),
      .fcb_pif_do_h_en(efpga_test_fcb_pif_do_h_en_o),  //done
      .fcb_apbs_pready(apbprogram_i.pready),  //(fcb_apbs_pready), //done
      .fcb_apbs_prdata(apbprogram_i.prdata),  //(fcb_apbs_prdata[31:0]), //done
      .fcb_apbs_pslverr(apbprogram_i.pslverr),  //(fcb_apbs_pslverr), //done
      .fcb_blclk(fcb2efpga_blclk),  //done
      .fcb_re(fcb2efpga_re),  //done
      .fcb_we(fcb2efpga_we),  //done
      .fcb_we_int(fcb2efpga_we_int),  // done
      .fcb_pchg_b(fcb2efpga_pchg_b),  //done
      .fcb_bl_din(fcb2efpga_bl_din[31:0]),  //done
      .fcb_cload_din_sel(fcb2efpga_cload_din_sel),  //done
      .fcb_din_slc_tb_int(fcb2efpga_din_slc_tb_int),  //done
      .fcb_din_int_l_only(fcb2efpga_din_int_l_only),  //done
      .fcb_din_int_r_only(fcb2efpga_din_int_r_only),  //done
      .fcb_bl_pwrgate(fcb2efpga_bl_pwrgate),  //done
      .fcb_wlclk(fcb2efpga_wlclk),
      .fcb_wl_resetb(fcb2efpga_wl_resetb),
      .fcb_wl_en(fcb2efpga_wl_en),
      .fcb_wl_sel(fcb2efpga_wl_sel[15:0]),
      .fcb_wl_cload_sel(fcb2efpga_wl_cload_sel[2:0]),
      .fcb_wl_pwrgate(fcb2efpga_wl_pwrgate[7:0]),
      .fcb_wl_din(fcb2efpga_wl_din[5:0]),
      .fcb_wl_int_din_sel(fcb2efpga_wl_int_din_sel),
      .fcb_prog(fcb2efpga_prog[15:0]),
      .fcb_prog_ifx(fcb2efpga_prog_ifx),
      .fcb_wl_sel_tb_int(fcb2efpga_wl_sel_tb_int),
      .fcb_fb_iso_enb(fcb2efpga_fb_iso_enb),
      .fcb_iso_en(fcb2efpga_iso_en[15:0]),
      .fcb_pi_pwr(fcb2efpga_pi_pwr[15:0]),
      .fcb_vlp_clkdis(fcb2efpga_vlp_clkdis[15:0]),
      .fcb_vlp_clkdis_ifx(fcb2efpga_vlp_clkdis_ifx),
      .fcb_vlp_srdis(fcb2efpga_vlp_srdis[15:0]),
      .fcb_vlp_srdis_ifx(fcb2efpga_vlp_srdis_ifx),
      .fcb_vlp_pwrdis(fcb2efpga_vlp_pwrdis[15:0]),
      .fcb_vlp_pwrdis_ifx(fcb2efpga_vlp_pwrdis_ifx),
      .fcb_apbm_paddr(),
      .fcb_apbm_psel(),
      .fcb_apbm_penable(),
      .fcb_apbm_pwrite(),
      .fcb_apbm_pwdata(),
      .fcb_apbm_ramfifo_sel(),
      .fcb_apbm_mclk(),
      .fcb_rst(),  //done
      .fcb_sysclk_en(),  // done
      .fcb_fb_cfg_done(fcb_fb_cfg_done),
      .fcb_clp_cfg_done_n(),
      .fcb_clp_cfg_enb(),
      .fcb_clp_lth_enb(),
      .fcb_clp_pwr_gate(),
      .fcb_clp_vlp(),

      .fcb_pwr_gate(fcb2efpga_pwr_gate),
      .fcb_set_por(fcb2efpga_set_por),  //done
      .fcb_clp_set_por(),
      .fcb_spi_master_status(),  // done
      // Inputs
      .fcb_sys_clk(asic_clk_i),
      .fcb_sys_rst_n(rst_n),
      .fcb_spis_clk(1'b0),
      .fcb_spis_rst_n(1'b0),
      .fcb_sys_stm(efpga_STM_i),  //fcb_sys_stm),
      .fcb_spim_miso(1'b0),
      .fcb_spim_ckout_in(1'b0),
      .fcb_spis_mosi(1'b0),
      .fcb_spis_cs_n(1'b0),
      .fcb_pif_vldi(efpga_test_fcb_pif_vldi_i),
      .fcb_pif_di_l(efpga_test_fcb_pif_di_l_i),
      .fcb_pif_di_h(efpga_test_fcb_pif_di_h_i),
      .fcb_spi_mode_en_bo(1'b0),
      .fcb_pif_en(efpga2fcb_pif_en),
      .fcb_pif_8b_mode_bo(1'b1),
      .fcb_apbs_pprot(3'b000),
      .fcb_apbs_psel(apbprogram_i.psel),
      .fcb_apbs_penable(apbprogram_i.penable),
      .fcb_apbs_pwrite(apbprogram_i.pwrite),
      .fcb_apbs_pwdata(apbprogram_i.pwdata),
      .fcb_apbs_paddr(apbprogram_i.paddr[19:0]),
      .fcb_apbs_pstrb(4'b0000),
      .fcb_bl_dout(efpga2fcb_bl_dout[31:0]),
      .fcb_apbm_prdata_0('0),
      .fcb_apbm_prdata_1('0),
      .fcb_spi_master_en(1'b0)
  );

  eFPGA_wrapper eFPGA_wrapper (

      //Outputs
      .test_fb_spe_out(efpga_test_FB_SPE_OUT_o),
      .test_fb_spe_in(efpga_test_FB_SPE_IN_i),
      .MLATCH(efpga_test_MLATCH_i),
      .STM(efpga_STM_i),
      .POR(efpga_por),
      .M(efpga_test_M_i),

      .fcb_bl_din(fcb2efpga_bl_din),
      .fcb_bl_dout(efpga2fcb_bl_dout),
      .fcb_bl_pwrgate(fcb2efpga_bl_pwrgate),  //done

      .fcb_blclk         (fcb2efpga_blclk),  //done
      .fcb_cload_din_sel (fcb2efpga_cload_din_sel),  //done
      .fcb_din_int_l_only(fcb2efpga_din_int_l_only),  //done
      .fcb_din_int_r_only(fcb2efpga_din_int_r_only),  //done
      .fcb_din_slc_tb_int(fcb2efpga_din_slc_tb_int),  //done
      .fcb_fb_iso_enb    (fcb2efpga_fb_iso_enb),
      .fcb_fb_cfg_done   (fcb_fb_cfg_done),
      .fcb_iso_en        (fcb2efpga_iso_en[15:0]),
      .fcb_pchg_b        (fcb2efpga_pchg_b),  //done
      .fcb_pi_pwr        (fcb2efpga_pi_pwr[15:0]),
      .fcb_pif_en        (efpga2fcb_pif_en),
      .fcb_prog          (fcb2efpga_prog[15:0]),
      .fcb_prog_ifx      (fcb2efpga_prog_ifx),
      .fcb_pwr_gate      (fcb2efpga_pwr_gate),
      .fcb_re            (fcb2efpga_re),  //done
      .fcb_vlp_clkdis    (fcb2efpga_vlp_clkdis[15:0]),
      .fcb_vlp_clkdis_ifx(fcb2efpga_vlp_clkdis_ifx),
      .fcb_vlp_srdis     (fcb2efpga_vlp_srdis[15:0]),
      .fcb_vlp_srdis_ifx (fcb2efpga_vlp_srdis_ifx),
      .fcb_vlp_pwrdis    (fcb2efpga_vlp_pwrdis[15:0]),
      .fcb_vlp_pwrdis_ifx(fcb2efpga_vlp_pwrdis_ifx),
      .fcb_we            (fcb2efpga_we),  //done
      .fcb_we_int        (fcb2efpga_we_int),  // done
      .fcb_wl_cload_sel  (fcb2efpga_wl_cload_sel[2:0]),
      .fcb_wl_din        (fcb2efpga_wl_din[5:0]),
      .fcb_wl_en         (fcb2efpga_wl_en),
      .fcb_wl_int_din_sel(fcb2efpga_wl_int_din_sel),
      .fcb_wl_pwrgate    (fcb2efpga_wl_pwrgate[7:0]),
      .fcb_wl_resetb     (fcb2efpga_wl_resetb),
      .fcb_wl_sel        (fcb2efpga_wl_sel[15:0]),
      .fcb_wl_sel_tb_int (fcb2efpga_wl_sel_tb_int),
      .fcb_wlclk         (fcb2efpga_wlclk),


      .fpgaio_oe (fpgaio_oe_o),
      .fpgaio_out(fpgaio_out_o),

      //inputs


      .CLK0(fpga_clk0_i),
      .CLK1(fpga_clk1_i),
      .CLK2(fpga_clk2_i),
      .CLK3(fpga_clk3_i),
      .CLK4(fpga_clk4_i),
      .CLK5(fpga_clk5_i),

      .fpgaio_in(fpgaio_in_i),
      .lint_ADDR(apbt1_int.add[APB_FPGA_ADDR_WIDTH-1:0]),
      .lint_REQ(apbt1_int.req),
      .lint_WDATA(apbt1_int.wdata),
      .lint_BE(apbt1_int.be),
      .lint_WEN(apbt1_int.wen),
      .apb_fpga_clk_o(s_efpga_clk),

      .RESET_RT(reset_type1_efpga_i[0]),
      .RESET_RB(reset_type1_efpga_i[1]),
      .RESET_LB(reset_type1_efpga_i[2]),
      .RESET_LT(reset_type1_efpga_i[3]),



      .tcdm_rdata_p0(tcdm_rdata_fpga[0]),
      .tcdm_clk_p0  (tcdm_clk[0]),
      .tcdm_rdata_p1(tcdm_rdata_fpga[1]),
      .tcdm_clk_p1  (tcdm_clk[1]),
      .tcdm_rdata_p2(tcdm_rdata_fpga[2]),
      .tcdm_clk_p2  (tcdm_clk[2]),
      .tcdm_rdata_p3(tcdm_rdata_fpga[3]),

      .tcdm_clk_p3(tcdm_clk[3]),
      .tcdm_gnt_p0(tcdm_gnt_fpga[0]),
      .tcdm_gnt_p1(tcdm_gnt_fpga[1]),
      .tcdm_gnt_p2(tcdm_gnt_fpga[2]),
      .tcdm_gnt_p3(tcdm_gnt_fpga[3]),
      .tcdm_fmo_p0(tcdm_fmo_fpga[0]),
      .tcdm_fmo_p1(tcdm_fmo_fpga[1]),
      .tcdm_fmo_p2(tcdm_fmo_fpga[2]),
      .tcdm_fmo_p3(tcdm_fmo_fpga[3]),

      .tcdm_valid_p0(tcdm_valid_fpga[0]),
      .tcdm_valid_p1(tcdm_valid_fpga[1]),
      .tcdm_valid_p2(tcdm_valid_fpga[2]),
      .tcdm_valid_p3(tcdm_valid_fpga[3]),
      .control_in   (control_in),
      //outputs
      .status_out   (status_out),
      .version      (version),
      .events_o     (s_event),
      .lint_RDATA   (apbt1_int.r_rdata),
      .lint_VALID   (apbt1_int.r_valid),
      .lint_GNT     (apbt1_int.gnt),

      .tcdm_wdata_p0(tcdm_wdata_fpga[0]),
      .tcdm_wdata_p1(tcdm_wdata_fpga[1]),
      .tcdm_wdata_p2(tcdm_wdata_fpga[2]),
      .tcdm_wdata_p3(tcdm_wdata_fpga[3]),

      .tcdm_addr_p0(tcdm_addr_fpga[0][APB_FPGA_ADDR_WIDTH-1:0]),
      .tcdm_addr_p1(tcdm_addr_fpga[1][APB_FPGA_ADDR_WIDTH-1:0]),
      .tcdm_addr_p2(tcdm_addr_fpga[2][APB_FPGA_ADDR_WIDTH-1:0]),
      .tcdm_addr_p3(tcdm_addr_fpga[3][APB_FPGA_ADDR_WIDTH-1:0]),

      .tcdm_wen_p0(tcdm_wen_fpga[0]),
      .tcdm_wen_p1(tcdm_wen_fpga[1]),
      .tcdm_wen_p2(tcdm_wen_fpga[2]),
      .tcdm_wen_p3(tcdm_wen_fpga[3]),

      .tcdm_req_p0(tcdm_req_fpga[0]),
      .tcdm_req_p1(tcdm_req_fpga[1]),
      .tcdm_req_p2(tcdm_req_fpga[2]),
      .tcdm_req_p3(tcdm_req_fpga[3]),

      .tcdm_be_p0(tcdm_be_fpga[0]),
      .tcdm_be_p1(tcdm_be_fpga[1]),
      .tcdm_be_p2(tcdm_be_fpga[2]),
      .tcdm_be_p3(tcdm_be_fpga[3])
  );

endmodule
