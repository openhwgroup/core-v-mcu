// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`define REG_MASK        4'b0000 //BASEADDR+0x00
`define REG_MASK_SET    4'b0001 //BASEADDR+0x04
`define REG_MASK_CLEAR  4'b0010 //BASEADDR+0x08
`define REG_INT         4'b0011 //BASEADDR+0x0C
`define REG_INT_SET     4'b0100 //BASEADDR+0x10
`define REG_INT_CLEAR   4'b0101 //BASEADDR+0x14
`define REG_ACK         4'b0110 //BASEADDR+0x18
`define REG_ACK_SET     4'b0111 //BASEADDR+0x1C
`define REG_ACK_CLEAR   4'b1000 //BASEADDR+0x20
`define REG_FIFO        4'b1001 //BASEADDR+0x24

module apb_interrupt_cntrl
#(
  parameter PER_ID_WIDTH  = 5,
  parameter EVT_ID_WIDTH  = 8,
  parameter ENA_SEC_IRQ   = 1,
  parameter FIFO_PIN = 26
)
(
  // clock and reset
  input  logic           clk_i,
  input  logic           rst_ni,
  input  logic           test_mode_i,

  // bus for incoming event ids
  input  logic                    event_fifo_valid_i,
  output logic                    event_fifo_fulln_o,
  input  logic [EVT_ID_WIDTH-1:0] event_fifo_data_i,

  input  logic [31:0]    events_i,

  output logic [4:0]     core_irq_id_o,
  output logic           core_irq_req_o,
  input  logic           core_irq_ack_i,
  output logic           core_irq_sec_o,
  input  logic [4:0]     core_irq_id_i,
  output logic [31:0]    irq_o,

  input  logic           core_secure_mode_i,
  output logic           core_clock_en_o,
  output logic           fetch_en_o,

  // bus slave connections - periph bus and eu_direct_link
  APB_BUS.Slave          apb_slave
 );

  logic             [31:0] s_events;

  logic             [31:0] s_ack_next;
  logic             [31:0] r_ack;
  logic             [31:0] s_int_next;
  logic             [31:0] r_int;
  logic             [31:0] s_mask_next;
  logic             [31:0] r_mask;
  logic [EVT_ID_WIDTH-1:0] r_fifo_event;

  logic [EVT_ID_WIDTH-1:0] s_event_fifo_data;
  logic                    s_event_fifo_valid;
  logic                    s_event_fifo_ready;
  logic                    s_is_int_clr_fifo;
  logic                    s_is_int_fifo;

  logic              [3:0] s_apb_addr;

  logic                    s_is_apb_write;
  logic                    s_is_apb_read;
  logic                    s_is_mask;
  logic                    s_is_mask_set;
  logic                    s_is_mask_clr;
  logic                    s_is_int;
  logic                    s_is_int_set;
  logic                    s_is_int_clr;
  logic                    s_is_ack;
  logic                    s_is_ack_set;
  logic                    s_is_ack_clr;
  logic                    s_is_fifo;
  logic                    s_is_event;

  assign core_clock_en_o = 1'b1;
  assign fetch_en_o      = 1'b1;

  assign s_events = {events_i[31:FIFO_PIN+1],s_event_fifo_valid,events_i[FIFO_PIN-1:0]};

  assign s_is_apb_write = apb_slave.psel & apb_slave.penable & apb_slave.pwrite;
  assign s_is_apb_read  = apb_slave.psel & apb_slave.penable & ~apb_slave.pwrite;

  assign s_is_int_clr_fifo  = s_is_int_clr & apb_slave.psel & apb_slave.penable & (apb_slave.pwdata[FIFO_PIN] == 1'b1);
  assign s_is_int_fifo      = s_is_int     & apb_slave.psel & apb_slave.penable & (apb_slave.pwdata[FIFO_PIN] == 1'b0);

  assign s_event_fifo_ready = (core_irq_ack_i & (core_irq_id_i == FIFO_PIN)) | (s_is_apb_write & (s_is_int_clr_fifo | s_is_int_fifo));

  assign s_apb_addr     = apb_slave.paddr[5:2];
  assign s_is_mask      = s_apb_addr == `REG_MASK;
  assign s_is_mask_set  = s_apb_addr == `REG_MASK_SET;
  assign s_is_mask_clr  = s_apb_addr == `REG_MASK_CLEAR;
  assign s_is_int       = s_apb_addr == `REG_INT;
  assign s_is_int_set   = s_apb_addr == `REG_INT_SET;
  assign s_is_int_clr   = s_apb_addr == `REG_INT_CLEAR;
  assign s_is_ack       = s_apb_addr == `REG_ACK;
  assign s_is_ack_set   = s_apb_addr == `REG_ACK_SET;
  assign s_is_ack_clr   = s_apb_addr == `REG_ACK_CLEAR;
  assign s_is_fifo      = s_apb_addr == `REG_FIFO;
  assign s_is_event     = |s_events;

  assign core_irq_req_o = |(r_int & r_mask);

  generic_fifo
  #(
    .DATA_WIDTH(8),
    .DATA_DEPTH(4)
  ) i_event_fifo (
    .clk     ( clk_i ),
    .rst_n   ( rst_ni ),

    .data_i  ( event_fifo_data_i  ),
    .valid_i ( event_fifo_valid_i ),
    .grant_o ( event_fifo_fulln_o ),

    .data_o  ( s_event_fifo_data  ),
    .valid_o ( s_event_fifo_valid ),
    .grant_i ( s_event_fifo_ready ),

    .test_mode_i()
  );

  always_comb begin : proc_mask
    s_mask_next = r_mask;
    if (s_is_apb_write)
    begin
      if (s_is_mask)
        s_mask_next = apb_slave.pwdata;
      else if (s_is_mask_set)
        s_mask_next = r_mask | apb_slave.pwdata;
      else if (s_is_mask_clr)
        s_mask_next = r_mask & ~apb_slave.pwdata;
    end
  end

  always_comb begin : proc_id
    core_irq_id_o = '0;
    irq_o = r_int;
    for(int i=0;i<32;i++)
    begin
      if (r_int[i] && r_mask[i])
        core_irq_id_o = i;
    end
  end

  always_comb begin : proc_int
    s_int_next = r_int;
    for(int i=0;i<32;i++)
    begin
      if (core_irq_ack_i && (core_irq_id_i == i))
        s_int_next[i] = 1'b0;
      else if(s_is_apb_write)
      begin
        if (s_is_int)
          s_int_next[i] = apb_slave.pwdata[i];
        else if (s_is_int_set)
          s_int_next[i] = (r_int[i] | s_events[i]) | apb_slave.pwdata[i];
        else if (s_is_int_clr)
          s_int_next[i] = (r_int[i] | s_events[i]) & ~apb_slave.pwdata[i];
        else if(s_events[i])
          s_int_next[i] = 1'b1;
      end
      else if(s_events[i])
        s_int_next[i] = 1'b1;
    end
  end

  always_comb begin : proc_ack
    s_ack_next = r_ack;
    for(int i=0;i<32;i++)
    begin
      if (core_irq_ack_i && (core_irq_id_i == i))
        s_ack_next[i] = 1'b1;
      else if(s_is_apb_write)
      begin
        if (s_is_ack)
          s_ack_next[i] = apb_slave.pwdata[i];
        else if (s_is_ack_set)
          s_ack_next[i] = r_ack[i] | apb_slave.pwdata[i];
        else if (s_is_ack_clr)
          s_ack_next[i] = r_ack[i] & ~apb_slave.pwdata[i];
      end
    end
  end

  always_ff @(posedge clk_i, negedge rst_ni)
  begin
    if(~rst_ni) begin
      r_mask       <= '0;
      r_int        <= '0;
      r_ack        <= '0;
      r_fifo_event <= '0;
    end
    else
    begin
      if (s_is_mask_clr || s_is_mask_set || s_is_mask)
        r_mask <= s_mask_next;
      if (s_is_int_clr || s_is_int_set || s_is_int || s_is_event || core_irq_ack_i || s_is_event)
        r_int <= s_int_next;
      if (s_is_ack_clr || s_is_ack_set || s_is_ack || core_irq_ack_i)
        r_ack <= s_ack_next;
      if (s_event_fifo_valid && s_event_fifo_ready)
        r_fifo_event <= s_event_fifo_data;
    end
  end

    // read data
    always_comb
    begin
      apb_slave.prdata = '0;
      // normal registers
      if (s_is_apb_read)
      begin
        if (s_is_int)
          apb_slave.prdata = r_int;
        else if (s_is_ack)
          apb_slave.prdata = r_ack;
        else if (s_is_mask)
          apb_slave.prdata = r_mask;
        else if (s_is_fifo)
          apb_slave.prdata[EVT_ID_WIDTH-1:0] = r_fifo_event;
      end
    end

   assign apb_slave.pready  = 1'b1;
   assign apb_slave.pslverr = 1'b0;

endmodule

