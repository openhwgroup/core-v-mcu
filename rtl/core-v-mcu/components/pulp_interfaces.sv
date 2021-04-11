// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


`include "pulp_soc_defines.sv"

//**********************************************************
//**************** XBAR TCDM BUS 64 ************************
//**********************************************************

interface XBAR_TCDM_BUS_64;

   // REQUEST CHANNEL
   //***************************************
   logic        req;
   logic [31:0] add;
   logic        wen;
   logic [63:0] wdata;
   logic [7:0]  be;
   logic        gnt;

   // RESPONSE CHANNEL
   logic        r_opc;
   logic [63:0] r_rdata;
   logic        r_valid;

   // Master Side
   //***************************************
   modport Master
   (
      output req, output add, output wen, output wdata, output be,
      input gnt, input r_rdata, input r_opc, input r_valid
   );

   // Slave Side
   //***************************************
   modport Slave
   (
      input req, input add, input wen, input wdata, input be,
      output gnt, output r_rdata, output r_opc, output r_valid
   );

endinterface // XBAR_TCDM_BUS_64

//**********************************************************
//**************** XBAR TCDM BUS ***************************
//**********************************************************

interface XBAR_TCDM_BUS;

   // REQUEST CHANNEL
   //***************************************
   logic          req;
   logic [31:0]   add;
   logic          wen;
   logic [31:0]   wdata;
   logic [3:0]    be;
   logic          gnt;

   // RESPONSE CHANNEL
   logic         r_opc;
   logic [31:0]  r_rdata;
   logic         r_valid;

   // Master Side
   //***************************************
   modport Master
     (
      output req, output add, output wen, output wdata, output be,
      input gnt, input r_rdata, input r_opc, input r_valid
      );

   // Slave Side
   //***************************************
   modport Slave
     (
      input req, input add, input wen, input wdata, input be,
      output gnt, output r_rdata, output r_opc, output r_valid
      );

endinterface // XBAR_TCDM_BUS

//**********************************************************
//**************** XBAR PERIPHERAL BUS *********************
//**********************************************************

interface XBAR_PERIPH_BUS
#(
   parameter ID_WIDTH = `NB_CORES+1
);
   // REQUEST CHANNEL
   logic                   req;
   logic [31:0]            add;
   logic                   wen;
   logic [31:0]            wdata;
   logic [3:0]             be;
   logic                   gnt;
   logic [ID_WIDTH-1:0]    id;

   // RESPONSE CHANNEL
   logic                   r_valid;
   logic                   r_opc;
   logic [ID_WIDTH-1:0]    r_id;
   logic [31:0]            r_rdata;

   // Master Side
   //***************************************
   modport Master
   (
         output req, output add, output wen, output wdata, output be, output id,
         input gnt, input r_rdata, input r_opc, input r_id, input r_valid
   );

   // Slave Side
   //***************************************
   modport Slave
   (
         input req, input add, input wen, input wdata, input be, input id,
         output gnt, output r_rdata, output r_opc, output r_id, output r_valid
   );

endinterface

//**********************************************************
//**************** MESSAGE BUS -- TODO *********************
//**********************************************************

interface MESSAGE_BUS
#(
   parameter ID_WIDTH = `NB_CORES+1
);
   // REQUEST CHANNEL
   logic                   req;
   logic [31:0]            add;
   logic                   wen;
   logic [31:0]            wdata;
   logic [3:0]             be;
   logic                   gnt;
   logic [ID_WIDTH-1:0]    id;

   // RESPONSE CHANNEL
   logic                   r_valid;
   logic                   r_opc;
   logic [ID_WIDTH-1:0]    r_id;
   logic [31:0]            r_rdata;

   // Master Side
   //***************************************
   modport Master
   (
         output req, output add, output wen, output wdata, output be, output id,
         input gnt, input r_rdata, input r_opc, input r_id, input r_valid
   );

   // Slave Side
   //***************************************
   modport Slave
   (
         input req, input add, input wen, input wdata, input be, input id,
         output gnt, output r_rdata, output r_opc, output r_id, output r_valid
   );

endinterface

//**********************************************************
//******************** XBAR DEMUX BUS **********************
//**********************************************************

interface XBAR_DEMUX_BUS;

   // REQUEST CHANNEL
   logic        barrier;
   logic        busy;
   logic        exec_cancel;
   logic        exec_stall;
   logic        req;
   logic [31:0] add;
   logic        we;
   logic [31:0] wdata;
   logic [3:0]  be;
   logic        gnt;

   // RESPONSE CHANNEL
   logic        r_gnt;
   logic        r_valid;
   logic [31:0] r_rdata;

   // Master Side
   //***************************************
   modport Master
   (
      output barrier, input busy, output exec_cancel, output exec_stall,
      output req, output add, output we, output wdata, output be, input gnt,
      output r_gnt, input r_rdata, input r_valid
   );

   // Slave Side
   //***************************************
   modport Slave
   (
      input barrier, output busy, input exec_cancel, input exec_stall,
      input req, input add, input we, input wdata, input be, output gnt,
      input r_gnt, output r_rdata, output r_valid
   );

endinterface // XBAR_DEMUX_BUS

//********************************************************
//**************** TCDM BANK MEM BUS *********************
//********************************************************

interface TCDM_BANK_MEM_BUS;

   logic [31:0] wdata;
   logic [31:0] add;
   logic        req;
   logic        wen;
   logic [3:0]  be;
   logic [31:0] rdata;

   modport Master
     (
      output wdata, output add, output req,
      output wen,   output be,  input rdata
      );

   modport Slave
     (
      input wdata, input add, input req,
      input wen,   input be,  output rdata
      );

endinterface


//********************************************************
//**************** UNICAD MEMORY BUS *********************
//********************************************************
interface UNICAD_MEM_BUS_64;
   logic [63:0] wdata;
   logic [31:0] add;
   logic        csn;
   logic        wen;
   logic [7:0]  be;
   logic [63:0] rdata;

   modport Master
   (
      output wdata, output add, output csn,
      output wen, output be, input rdata
   );

   modport Slave
   (
      input wdata, input add, input csn,
      input wen, input be, output rdata
   );
endinterface



//**********************************************************
//**************** UNICAD_MEM_BUS_32************************
//**********************************************************
interface UNICAD_MEM_BUS_32;
   logic [31:0] wdata;
   logic [31:0] add;
   logic        csn;
   logic        wen;
   logic [3:0]  be;
   logic [31:0] rdata;

   modport Master
   (
      output wdata, output add, output csn,
      output wen, output be, input rdata
   );

   modport Slave
   (
      input wdata, input add, input csn,
      input wen, input be, output rdata
   );
endinterface


//********************************************************
//******************** TCDM BUS **************************
//********************************************************

interface TCDM_BUS;


   logic [63:0]        data;
   logic [8:0]           addr;
   logic [3:0]        csn;
   logic [3:0]           wen;
   logic [63:0]        wmn;
   logic [3:0][63:0]   qdata;

   modport Master
     (
      output   data, output addr, output csn,
      output wen, output wmn, input qdata
      );

   modport Slave
     (
      input data, input addr, input csn,
      input wen, input wmn, output qdata
      );

endinterface

//********************************************************
//***************** BBMUX CONFIG BUS *********************
//********************************************************

interface BBMUX_CONFIG_BUS;

   // REQUEST CHANNEL
   //***************************************
   logic [3:0][1:0]    bbmux_tcdm;
   logic [3:0][1:0]    bbmux_core;
   logic [1:0]           bbmux_scm;
   logic [1:0]           bbmux_int;
   logic               bbmux_sel;

   // RESPONSE CHANNEL
   //***************************************

   // Master Side
   //***************************************
   modport Master
     (
      output bbmux_tcdm,
      output bbmux_core,
      output bbmux_scm,
      output bbmux_int,
      output bbmux_sel
      );

   // Slave Side
   //***************************************
   modport Slave
     (
      input bbmux_tcdm,
      input bbmux_core,
      input bbmux_scm,
      input bbmux_int,
      input bbmux_sel
      );

endinterface // BBMUX_CONFIG_BUS

interface AXI_BUS2
#(
   parameter AXI_ADDR_WIDTH = 32,
   parameter AXI_DATA_WIDTH = 64,
   parameter AXI_ID_WIDTH   = 10,
   parameter AXI_USER_WIDTH = 6
);

   localparam AXI_STRB_WIDTH = `EVAL_BE_WIDTH(AXI_DATA_WIDTH);

   logic [AXI_ADDR_WIDTH-1:0]  aw_addr;
   logic [2:0]                 aw_prot;
   logic [3:0]                 aw_region;
   logic [7:0]                 aw_len;
   logic [2:0]                 aw_size;
   logic [1:0]                 aw_burst;
   logic                       aw_lock;
   logic [3:0]                 aw_cache;
   logic [3:0]                 aw_qos;
   logic [AXI_ID_WIDTH-1:0]    aw_id;
   logic [AXI_USER_WIDTH-1:0]  aw_user;
   logic                       aw_ready;
   logic                       aw_valid;

   logic [AXI_ADDR_WIDTH-1:0]  ar_addr;
   logic [2:0]                 ar_prot;
   logic [3:0]                 ar_region;
   logic [7:0]                 ar_len;
   logic [2:0]                 ar_size;
   logic [1:0]                 ar_burst;
   logic                       ar_lock;
   logic [3:0]                 ar_cache;
   logic [3:0]                 ar_qos;
   logic [AXI_ID_WIDTH-1:0]    ar_id;
   logic [AXI_USER_WIDTH-1:0]  ar_user;
   logic                       ar_ready;
   logic                       ar_valid;

   logic                       w_valid;
   logic [AXI_DATA_WIDTH-1:0]  w_data;
   logic [AXI_STRB_WIDTH-1:0]  w_strb;
   logic [AXI_USER_WIDTH-1:0]  w_user;
   logic                       w_last;
   logic                       w_ready;

   logic [AXI_DATA_WIDTH-1:0]  r_data;
   logic [1:0]                 r_resp;
   logic                       r_last;
   logic [AXI_ID_WIDTH-1:0]    r_id;
   logic [AXI_USER_WIDTH-1:0]  r_user;
   logic                       r_ready;
   logic                       r_valid;

   logic [1:0]                 b_resp;
   logic [AXI_ID_WIDTH-1:0]    b_id;
   logic [AXI_USER_WIDTH-1:0]  b_user;
   logic                       b_ready;
   logic                       b_valid;

   // Master Side
   //***************************************
   modport Master
     (

      output aw_valid, output aw_addr, output aw_prot, output aw_region,
      output aw_len, output aw_size, output aw_burst, output aw_lock,
      output aw_cache, output aw_qos, output aw_id, output aw_user,
      input aw_ready,

      output ar_valid, output ar_addr, output ar_prot, output ar_region,
      output ar_len, output ar_size, output ar_burst, output ar_lock,
      output ar_cache, output ar_qos, output ar_id, output ar_user,
      input ar_ready,

      output w_valid, output w_data, output w_strb,  output w_user, output w_last,
      input w_ready,

      input r_valid, input r_data, input r_resp, input r_last, input r_id, input r_user,
      output r_ready,

      input b_valid, input b_resp, input b_id, input b_user,
      output b_ready

      );

   // Master Side
   //***************************************
   modport Slave
     (

      input aw_valid, input aw_addr, input aw_prot, input aw_region,
      input aw_len, input aw_size, input aw_burst, input aw_lock,
      input aw_cache, input aw_qos, input aw_id, input aw_user,
      output aw_ready,

      input ar_valid, input ar_addr, input ar_prot, input ar_region,
      input ar_len, input ar_size, input ar_burst, input ar_lock,
      input ar_cache, input ar_qos, input ar_id, input ar_user,
      output ar_ready,

      input w_valid, input w_data, input w_strb, input w_user, input w_last,
      output w_ready,

      output r_valid, output r_data, output r_resp, output r_last, output r_id, output r_user,
      input r_ready,

      output b_valid, output b_resp, output b_id, output b_user,
      input b_ready

      );

endinterface

interface AXI_BUS_ASYNC2
      #(
      parameter AXI_ADDR_WIDTH = 32,
      parameter AXI_DATA_WIDTH = 64,
      parameter AXI_ID_WIDTH   = 10,
      parameter AXI_USER_WIDTH = 6,
      parameter BUFFER_WIDTH = 8
      );

   localparam AXI_STRB_WIDTH = `EVAL_BE_WIDTH(AXI_DATA_WIDTH);

   logic [AXI_ADDR_WIDTH-1:0] aw_addr;
   logic [2:0]                aw_prot;
   logic [3:0]              aw_region;
   logic [7:0]              aw_len;
   logic [2:0]              aw_size;
   logic [1:0]              aw_burst;
   logic                      aw_lock;
   logic [3:0]              aw_cache;
   logic [3:0]              aw_qos;
   logic [AXI_ID_WIDTH-1:0]   aw_id;
   logic [AXI_USER_WIDTH-1:0] aw_user;
    logic [BUFFER_WIDTH-1:0]   aw_writetoken;
    logic [BUFFER_WIDTH-1:0]   aw_readpointer;

   logic [AXI_ADDR_WIDTH-1:0] ar_addr;
   logic [2:0]              ar_prot;
   logic [3:0]              ar_region;
   logic [7:0]              ar_len;
   logic [2:0]              ar_size;
   logic [1:0]              ar_burst;
   logic                      ar_lock;
   logic [3:0]                ar_cache;
   logic [3:0]                ar_qos;
   logic [AXI_ID_WIDTH-1:0]   ar_id;
   logic [AXI_USER_WIDTH-1:0] ar_user;
   logic [BUFFER_WIDTH-1:0]   ar_writetoken;
   logic [BUFFER_WIDTH-1:0]   ar_readpointer;

   logic [AXI_DATA_WIDTH-1:0] w_data;
   logic [AXI_STRB_WIDTH-1:0] w_strb;
   logic [AXI_USER_WIDTH-1:0] w_user;
   logic                      w_last;
   logic [BUFFER_WIDTH-1:0]   w_writetoken;
   logic [BUFFER_WIDTH-1:0]   w_readpointer;

   logic [AXI_DATA_WIDTH-1:0] r_data;
   logic [1:0]              r_resp;
   logic                      r_last;
   logic [AXI_ID_WIDTH-1:0]   r_id;
   logic [AXI_USER_WIDTH-1:0] r_user;
   logic [BUFFER_WIDTH-1:0]   r_writetoken;
   logic [BUFFER_WIDTH-1:0]   r_readpointer;

   logic [1:0]              b_resp;
   logic [AXI_ID_WIDTH-1:0]   b_id;
   logic [AXI_USER_WIDTH-1:0] b_user;
   logic [BUFFER_WIDTH-1:0]   b_writetoken;
   logic [BUFFER_WIDTH-1:0]   b_readpointer;

   // Master Side
   //***************************************
   modport Master
      (

         output aw_addr, output aw_prot, output aw_region,
         output aw_len, output aw_size, output aw_burst, output aw_lock,
         output aw_cache, output aw_qos, output aw_id, output aw_user,
         output aw_writetoken, input aw_readpointer,

         output ar_addr, output ar_prot, output ar_region,
         output ar_len, output ar_size, output ar_burst, output ar_lock,
         output ar_cache, output ar_qos, output ar_id, output ar_user,
         output ar_writetoken, input ar_readpointer,

         output w_data, output w_strb,  output w_user, output w_last,
         output w_writetoken, input w_readpointer,

         input r_data, input r_resp, input r_last, input r_id, input r_user,
         input r_writetoken, output r_readpointer,

         input b_resp, input b_id, input b_user,
         input b_writetoken, output b_readpointer

         );

   // Master Side
   //***************************************
   modport Slave
      (

         input aw_addr, input aw_prot, input aw_region,
         input aw_len, input aw_size, input aw_burst, input aw_lock,
         input aw_cache, input aw_qos, input aw_id, input aw_user,
         input aw_writetoken, output aw_readpointer,

         input ar_addr, input ar_prot, input ar_region,
         input ar_len, input ar_size, input ar_burst, input ar_lock,
         input ar_cache, input ar_qos, input ar_id, input ar_user,
         input ar_writetoken, output ar_readpointer,

         input w_data, input w_strb, input w_user, input w_last,
         input w_writetoken, output w_readpointer,

         output r_data, output r_resp, output r_last, output r_id, output r_user,
         output r_writetoken, input r_readpointer,

         output b_resp, output b_id, output b_user,
         output b_writetoken, input b_readpointer

         );

endinterface

   //********************************************************
   //***************** CLKGATE CONFIG BUS *******************
   //********************************************************

interface CLKGATE_CONFIG_BUS;

   // REQUEST CHANNEL
   //***************************************
   logic [`NB_CORES-1:0] clkgate_tcdm;
   logic [`NB_CORES-1:0] clkgate_core;
   logic                 clkgate_scm;
   logic                 clkgate_int;
   logic                 clkgate_hwacc;
   logic                 clkgate_sel;

   // RESPONSE CHANNEL
   //***************************************
   //

   // Master Side
   //***************************************
   modport Master
     (
      output clkgate_tcdm,
      output clkgate_core,
      output clkgate_scm,
      output clkgate_int,
      output clkgate_hwacc,
      output clkgate_sel
      );

   // Slave Side
   //***************************************
   modport Slave
     (
      input clkgate_tcdm,
      input clkgate_core,
      input clkgate_scm,
      input clkgate_int,
      input clkgate_hwacc,
      input clkgate_sel
      );

endinterface // CLKGATE_CONFIG_BUS

   //********************************************************
   //***************** MMU CONFIG BUS ***********************
   //********************************************************

interface MMU_CONFIG_BUS;

   // size of section in SRAM that is mapped in sequential
   // (non-interleaved) order for collision free private accesses,
   // always starting at the top of the whole SRAM section
   // n = 0: disable sequential section
   // n > 0: seq. section of size 2^n * 32 Byte
   logic [3:0] mmu_sram_seqsec_size;
   // seperate section can be declared sindie the SCM part
   // sizing works as above, the seq. section always starts
   // at the top of the SCM section
   logic [3:0] mmu_scm_seqsec_size;
   // NOTE: address translation can be fully disabled setting
   //       both mmu_sram_seq_size and mmu_scm_seq_size to 0
   //       (this is the default reset value)

   // Master Side
   //***************************************
   modport Master
     (
      output mmu_sram_seqsec_size,
      output mmu_scm_seqsec_size
      );

   // Slave Side
   //***************************************
   modport Slave
     (
      input mmu_sram_seqsec_size,
      input mmu_scm_seqsec_size
      );

endinterface // MMU_CONFIG_BUS

   //********************************************************
   //***************** BIST IC BUS **************************
   //********************************************************

interface BIST_BUS;

   logic         bist_en;
   logic         bist_done_even;
   logic         bist_done_odd;
   logic         bist_result_even;
   logic         bist_result_odd;
   logic [31:0]  bist_pattern;

   // Master Side
   //***************************************
   modport Master
     (
      output     bist_en,
      input      bist_done_even,
      input      bist_done_odd,
      input      bist_result_even,
      input      bist_result_odd,
      output     bist_pattern
      );

   // Slave Side
   //***************************************
   modport Slave
     (
      input      bist_en,
      output     bist_done_even,
      output     bist_done_odd,
      output     bist_result_even,
      output     bist_result_odd,
      input      bist_pattern
      );

endinterface // BIST_BUS

   //********************************************************
   //****************** BRAM PORT BUS ***********************
   //********************************************************

interface BRAM_PORT;

   logic clk;
   logic rst;
   logic en;
   logic [ 7:0] we;
   logic [14:0] addr;
   logic [63:0] din;
   logic [63:0] dout;

   modport Master (
      output clk,
      output rst,
      output en,
      output we,
      output addr,
      output din,
      input  dout
   );

   modport Slave (
      input  clk,
      input  rst,
      input  en,
      input  we,
      input  addr,
      input  din,
      output dout
   );

endinterface // BRAM_PORT


interface SP_ICACHE_CTRL_UNIT_BUS;

    // ICACHE_CTRL UNIT INTERFACE
    //***************************************
    logic                 ctrl_req_enable;
    logic                 ctrl_ack_enable;
    logic                 ctrl_req_disable;
    logic                 ctrl_ack_disable;
    logic                 ctrl_pending_trans;
    logic                 ctrl_flush_req;
    logic                 ctrl_flush_ack;
    logic                 icache_is_private;


    logic                 sel_flush_req;
    logic [31:0]          sel_flush_addr;
    logic                 sel_flush_ack;

`ifdef FEATURE_ICACHE_STAT
    logic [31:0]          ctrl_hit_count;
    logic [31:0]          ctrl_trans_count;
    logic [31:0]          ctrl_miss_count;

    logic                 ctrl_clear_regs;
    logic                 ctrl_enable_regs;

`endif

    // Master Side
    //***************************************
    modport Master
    (
        output ctrl_req_enable,
        output ctrl_req_disable,
        output ctrl_flush_req,
        output icache_is_private,

        input  ctrl_flush_ack,
        input  ctrl_ack_enable,
        input  ctrl_ack_disable,
        input  ctrl_pending_trans,

        output        sel_flush_req,
        output        sel_flush_addr,
        input         sel_flush_ack

    `ifdef FEATURE_ICACHE_STAT
        ,
        input  ctrl_hit_count,
        input  ctrl_trans_count,
        input  ctrl_miss_count,
        output ctrl_clear_regs,
        output ctrl_enable_regs
    `endif
    );

    // Slave Side
    //***************************************
    modport Slave
    (
        input  ctrl_req_enable,
        input  ctrl_req_disable,
        input  ctrl_flush_req,
        input  icache_is_private,

        output ctrl_flush_ack,
        output ctrl_ack_enable,
        output ctrl_ack_disable,
        output ctrl_pending_trans,

        input        sel_flush_req,
        input        sel_flush_addr,
        output       sel_flush_ack

    `ifdef FEATURE_ICACHE_STAT
        ,
        output ctrl_hit_count,
        output ctrl_trans_count,
        output ctrl_miss_count,
        input  ctrl_clear_regs,
        input  ctrl_enable_regs
    `endif
    );

endinterface //~ SP_ICACHE_CTRL_UNIT_BUS






interface MP_ICACHE_CTRL_UNIT_BUS;
    // ICACHE_CTRL UNIT INTERFACE
    //***************************************
    logic                 bypass_req;
    logic [`NB_CORES:0]   bypass_ack; // NB_CORES + 1
    logic                 flush_req;
    logic                 flush_ack;

    logic                 sel_flush_req;
    logic [31:0]          sel_flush_addr;
    logic                 sel_flush_ack;

`ifdef FEATURE_ICACHE_STAT
    logic [31:0]          global_hit_count;
    logic [31:0]          global_trans_count;
    logic [31:0]          global_miss_count;

    logic [`NB_CORES-1:0][31:0]  bank_hit_count;
    logic [`NB_CORES-1:0][31:0]  bank_trans_count;
    logic [`NB_CORES-1:0][31:0]  bank_miss_count;

    logic                 ctrl_clear_regs;
    logic                 ctrl_enable_regs;
`endif

    // Master Side
    //***************************************
    modport Master
    (
        output bypass_req,
        output flush_req,
        input  bypass_ack,
        input  flush_ack,

        output sel_flush_req,
        output sel_flush_addr,
        input  sel_flush_ack

    `ifdef FEATURE_ICACHE_STAT
        ,
        input  global_hit_count,
        input  global_trans_count,
        input  global_miss_count,

        input  bank_hit_count,
        input  bank_trans_count,
        input  bank_miss_count,

        output ctrl_clear_regs,
        output ctrl_enable_regs
    `endif
    );

    // Slave Side
    //***************************************
    modport Slave
    (
        input  bypass_req,
        input  flush_req,
        output bypass_ack,
        output flush_ack,

        input  sel_flush_req,
        input  sel_flush_addr,
        output sel_flush_ack

    `ifdef FEATURE_ICACHE_STAT
        ,
        output global_hit_count,
        output global_trans_count,
        output global_miss_count,

        output bank_hit_count,
        output bank_trans_count,
        output bank_miss_count,

        input  ctrl_clear_regs,
        input  ctrl_enable_regs
    `endif
    );
endinterface //~ MP_ICACHE_CTRL_UNIT_BUS








interface MP_PF_ICACHE_CTRL_UNIT_BUS;
    // ICACHE_CTRL UNIT INTERFACE
    //***************************************
    logic                 bypass_req;
    logic [`NB_CORES:0]   bypass_ack; // NB_CORES + 1
    logic                 flush_req;
    logic                 flush_ack;

    logic                 sel_flush_req;
    logic [31:0]          sel_flush_addr;
    logic                 sel_flush_ack;

    logic [31:0]          pf_addr;
    logic [7:0]           pf_size;
    logic                 pf_req;
    logic                 pf_ack;
    logic                 pf_done;


`ifdef FEATURE_ICACHE_STAT
    logic [31:0]          global_hit_count;
    logic [31:0]          global_trans_count;
    logic [31:0]          global_miss_count;

    logic [`NB_CORES-1:0][31:0]  bank_hit_count;
    logic [`NB_CORES-1:0][31:0]  bank_trans_count;
    logic [`NB_CORES-1:0][31:0]  bank_miss_count;

    logic                 ctrl_clear_regs;
    logic                 ctrl_enable_regs;
`endif

    // Master Side
    //***************************************
    modport Master
    (
        output bypass_req,
        output flush_req,
        input  bypass_ack,
        input  flush_ack,

        output sel_flush_req,
        output sel_flush_addr,
        input  sel_flush_ack,

        output pf_addr, pf_size, pf_req,
        input  pf_ack,  pf_done

    `ifdef FEATURE_ICACHE_STAT
        ,
        input  global_hit_count,
        input  global_trans_count,
        input  global_miss_count,

        input  bank_hit_count,
        input  bank_trans_count,
        input  bank_miss_count,

        output ctrl_clear_regs,
        output ctrl_enable_regs
    `endif
    );

    // Slave Side
    //***************************************
    modport Slave
    (
        input  bypass_req,
        input  flush_req,
        output bypass_ack,
        output flush_ack,

        input  sel_flush_req,
        input  sel_flush_addr,
        output sel_flush_ack,

        input  pf_addr, pf_size, pf_req,
        output pf_ack,  pf_done

    `ifdef FEATURE_ICACHE_STAT
        ,
        output global_hit_count,
        output global_trans_count,
        output global_miss_count,

        output bank_hit_count,
        output bank_trans_count,
        output bank_miss_count,

        input  ctrl_clear_regs,
        input  ctrl_enable_regs
    `endif
    );
endinterface //~ MP_PF_ICACHE_CTRL_UNIT_BUS









interface PRI_ICACHE_CTRL_UNIT_BUS;
    // ICACHE_CTRL UNIT INTERFACE
    //***************************************
    logic                 bypass_req;
    logic                 bypass_ack;
    logic                 flush_req;
    logic                 flush_ack;

    logic                 sel_flush_req;
    logic [31:0]          sel_flush_addr;
    logic                 sel_flush_ack;

`ifdef FEATURE_ICACHE_STAT
    logic [31:0]          ctrl_hit_count;
    logic [31:0]          ctrl_trans_count;
    logic [31:0]          ctrl_miss_count;
    logic [31:0]          ctrl_cong_count;

    logic                 ctrl_clear_regs;
    logic                 ctrl_enable_regs;
`endif

    // Master Side
    //***************************************
    modport Master
    (
        output bypass_req,
        output flush_req,
        input  bypass_ack,
        input  flush_ack,

        output sel_flush_req,
        output sel_flush_addr,
        input  sel_flush_ack

    `ifdef FEATURE_ICACHE_STAT
        ,
        input  ctrl_hit_count,
        input  ctrl_trans_count,
        input  ctrl_miss_count,
        input  ctrl_cong_count,

        output ctrl_clear_regs,
        output ctrl_enable_regs
    `endif
    );

    // Slave Side
    //***************************************
    modport Slave
    (
        input  bypass_req,
        input  flush_req,
        output bypass_ack,
        output flush_ack,

        input  sel_flush_req,
        input  sel_flush_addr,
        output sel_flush_ack

    `ifdef FEATURE_ICACHE_STAT
        ,
        output ctrl_hit_count,
        output ctrl_trans_count,
        output ctrl_miss_count,
        output ctrl_cong_count,

        input  ctrl_clear_regs,
        input  ctrl_enable_regs
    `endif
    );

endinterface //~ PRI_ICACHE_CTRL_UNIT_BUS






interface L0_CTRL_UNIT_BUS;

    // L0_CTRL_UNIT INTERFACE
    //***************************************
    logic                 flush_FetchBuffer;
    logic                 flush_ack;
//`ifdef FEATURE_ICACHE_STAT
    logic [31:0]          ctrl_stall_count;
//`endif
    // Master Side
    //***************************************
    modport Master
    (
        input  ctrl_stall_count,
        output flush_FetchBuffer,
        input  flush_ack
    );

    // Slave Side
    //***************************************
    modport Slave
    (
        output ctrl_stall_count,
        input  flush_FetchBuffer,
        output flush_ack
    );

endinterface //~ L0_CTRL_UNIT_BUS

//////////////////////////////////////////////////////////////
//                                                          //
//  █████╗ ██████╗ ██████╗     ██████╗ ██╗   ██╗███████╗    //
// ██╔══██╗██╔══██╗██╔══██╗    ██╔══██╗██║   ██║██╔════╝    //
// ███████║██████╔╝██████╔╝    ██████╔╝██║   ██║███████╗    //
// ██╔══██║██╔═══╝ ██╔══██╗    ██╔══██╗██║   ██║╚════██║    //
// ██║  ██║██║     ██████╔╝    ██████╔╝╚██████╔╝███████║    //
// ╚═╝  ╚═╝╚═╝     ╚═════╝     ╚═════╝  ╚═════╝ ╚══════╝    //
//                                                          //
//////////////////////////////////////////////////////////////

interface APB_BUS
#(
    parameter APB_ADDR_WIDTH = 32,
    parameter APB_DATA_WIDTH = 32
);

    logic [APB_ADDR_WIDTH-1:0]                                        paddr;
    logic [APB_DATA_WIDTH-1:0]                                        pwdata;
    logic                                                             pwrite;
    logic                                                             psel;
    logic                                                             penable;
    logic [APB_DATA_WIDTH-1:0]                                        prdata;
    logic                                                             pready;
    logic                                                             pslverr;


   // Master Side
   //***************************************
   modport Master
   (
      output      paddr,  pwdata,  pwrite, psel,  penable,
      input       prdata,          pready,        pslverr
   );

   // Slave Side
   //***************************************
   modport Slave
   (
      input      paddr,  pwdata,  pwrite, psel,  penable,
      output     prdata,          pready,        pslverr
   );

endinterface

//  ██████╗██╗   ██╗██████╗     ██████╗ ██╗   ██╗███████╗
// ██╔════╝██║   ██║██╔══██╗    ██╔══██╗██║   ██║██╔════╝
// ██║     ██║   ██║██████╔╝    ██████╔╝██║   ██║███████╗
// ██║     ╚██╗ ██╔╝██╔═══╝     ██╔══██╗██║   ██║╚════██║
// ╚██████╗ ╚████╔╝ ██║         ██████╔╝╚██████╔╝███████║
//  ╚═════╝  ╚═══╝  ╚═╝         ╚═════╝  ╚═════╝ ╚══════╝

interface FLL_BUS
#(
    parameter FLL_ADDR_WIDTH = 2,
    parameter FLL_DATA_WIDTH = 32
);

    logic                       req;
    logic                       wrn;
    logic [FLL_ADDR_WIDTH-1:0]  add;
    logic [FLL_DATA_WIDTH-1:0]  data;
    logic                       ack;
    logic [FLL_DATA_WIDTH-1:0]  r_data;
    logic                       lock;


   // Master Side
   //***************************************
   modport Master
   (
      output      req, wrn, add, data,
      input       ack, r_data, lock
   );

   // Slave Side
   //***************************************
   modport Slave
   (
      input       req, wrn, add, data,
      output      ack, r_data, lock
   );

endinterface


//**********************************************************
//**************** CORE PREF BUS ***************************
//**********************************************************

interface CORE_PREF_BUS;

   // REQUEST CHANNEL
   //***************************************
   logic          req;
   logic [31:0]   add;
   logic          gnt;
   logic          branch;

   // RESPONSE CHANNEL
   logic         r_ready;
   logic [31:0]  r_rdata;
   logic         r_valid;

   // Master Side
   //***************************************
   modport Master
   (
      output req, output add, output r_ready, output branch,
      input gnt, input r_rdata, input r_valid
   );

   // Slave Side
   //***************************************
   modport Slave
   (
      input req, input add,  input r_ready, input branch,
      output gnt, output r_rdata, output r_valid
   );

endinterface // CORE_PREF_BUS


// Copyright (c) 2014 IIS @ ETHZ, Federal Institute of Technology.
//
// AUTHORS
// - Mario Burger <marioburger@student.ethz.ch>
// - Fabian Schuiki <fschuiki@student.ethz.ch>
// - Michael Gautschi <gautschi@iis.ethz.ch>
//
// HISTORY
// - [2014-10-07] file created
// - [2014-10-09] modified handshake signals
// - [2014-10-10] changed naming convention (us/ds)
// - [2014-10-15] updated naming convention
// - [2014-12-05] added rounding modes & flags
// - [2015-05-22] integrated in PULP
// - [2015-11-25] merged into pulp4
// - [2016-08-31] restructured defines, parameters and interfaces
// -----------------------------------------------------------------------------


/// Interface an APU (Auxiliary Processing Unit) is expected to implement in
/// order to be attached to the interconnect and sharing mechanism. See the file
/// apu_template.sv for an example as how to create a module that implements the
/// interface.
interface marx_apu_if #(
												parameter WOP      = 1,
												parameter NARGS    = 2,
												parameter NUSFLAGS = 1,
												parameter NDSFLAGS = 1,
                        parameter WAPUTAG  = 2,
                        parameter WRESULT  = 32,
                        parameter WARG     = 32
												);

	 // Downstream
	 logic valid_ds_s;
	 logic ready_ds_s;

	 logic [WARG-1:0]            operands_ds_d [NARGS-1:0];
	 logic [WOP-1:0]             op_ds_d;
	 logic [NDSFLAGS-1:0]        flags_ds_d;
	 logic [WAPUTAG-1:0]         tag_ds_d;

	 // Upstream
	 logic                       req_us_s;
	 logic                       ack_us_s;

	 logic [WRESULT-1:0]         result_us_d;
	 logic [NUSFLAGS-1:0]        flags_us_d;
	 logic [WAPUTAG-1:0]         tag_us_d;

	 // The interface from the APU's perspective.
	 modport apu (
		            input  valid_ds_s, operands_ds_d, op_ds_d, flags_ds_d, tag_ds_d, ack_us_s,
		            output ready_ds_s, req_us_s, result_us_d, flags_us_d, tag_us_d
	              );

	 // The interface from interconnect's perspective.
	 modport marx (
		             output valid_ds_s, operands_ds_d, op_ds_d, flags_ds_d, tag_ds_d, ack_us_s,
		             input  ready_ds_s, req_us_s, result_us_d, flags_us_d, tag_us_d
	               );

endinterface // marx_apu_if

// Interface between arbiter and fp-interconnect
interface marx_arbiter_if #(
		                        parameter NIN = -1, // number of request inputs
		                        parameter NOUT = -1, // number of allocatable resources
		                        parameter NIN2 = $clog2(NIN)
	                          );

	 // Allocation request handshake.
	 logic [NIN-1:0]      req_d;
	 logic [NIN-1:0]      ack_d;

	 // Index of the resource allocated.
	 logic                unsigned [NOUT-1:0] [NIN2-1:0] assid_d;

	 // Resource handshake.
	 logic [NOUT-1:0]     avail_d; // resource is ready to be allocated
	 logic [NOUT-1:0]     alloc_d; // resource was allocated

	 modport arbiter (
		                input  req_d, avail_d,
		                output ack_d, assid_d, alloc_d
	                  );

	 modport marx (
		             output req_d, avail_d,
		             input  ack_d, assid_d, alloc_d
	               );

endinterface // marx_arbiter_if


/// The interface between the Marx interconnect and the cores. The interconnect
/// shall instantiate the "marx" modport.
interface cpu_marx_if #(
												parameter WOP_CPU      = 0,
												parameter WAPUTYPE     = 0,
												parameter NUSFLAGS_CPU = 1,
												parameter NDSFLAGS_CPU = 1,
                        parameter WRESULT      = 32,
                        parameter WARG         = 32,
                        parameter NARGS_CPU    = 3
												);

	 // Downstream
	 logic                            req_ds_s;
	 logic                            ack_ds_s;

	 logic [WAPUTYPE-1:0]             type_ds_d;

	 logic [WARG-1:0]                 operands_ds_d [NARGS_CPU-1:0];
	 logic [WOP_CPU-1:0]              op_ds_d;
	 logic [NDSFLAGS_CPU-1:0]         flags_ds_d;

	 // Upstream
	 logic                            valid_us_s;
	 logic                            ready_us_s;

	 logic [WRESULT-1:0]              result_us_d;
	 logic [NUSFLAGS_CPU-1:0]         flags_us_d;

	 // The interface from the Core's perspective.
	 modport cpu (
		            output req_ds_s, type_ds_d, operands_ds_d, op_ds_d, flags_ds_d, ready_us_s,
		            input  ack_ds_s, valid_us_s, result_us_d, flags_us_d
	              );

	 // The interface from the interconnect's perspective.
	 modport marx (
		             input  req_ds_s, type_ds_d, operands_ds_d, op_ds_d, ready_us_s, flags_ds_d,
		             output ack_ds_s, valid_us_s, result_us_d, flags_us_d
	               );

endinterface
