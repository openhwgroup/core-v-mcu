// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Top module
module adbg_lint_biu
#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 64,
    parameter AUX_WIDTH = 6
)
(
    // Debug interface signals
    input  logic                        tck_i,
    input  logic                        trstn_i,
    input  logic [63:0]                 data_i,
    output logic [63:0]                 data_o,
    input  logic                 [31:0] addr_i,
    input  logic                        strobe_i,
    input  logic                        rd_wrn_i,           // If 0, then write op
    output logic                        rdy_o,
    output logic                        err_o,
    input  logic                  [3:0] word_size_i,  // 1,2, or 4

    input  logic                        clk_i,
    input  logic                        rstn_i,

    output logic                        lint_req_o,
    output logic   [ADDR_WIDTH-1:0]     lint_add_o,
    output logic                        lint_wen_o,
    output logic   [DATA_WIDTH-1:0]     lint_wdata_o,
    output logic [DATA_WIDTH/8-1:0]     lint_be_o,
    output logic    [AUX_WIDTH-1:0]     lint_aux_o,
    input  logic                        lint_gnt_i,
    input  logic                        lint_r_aux_i,
    input  logic                        lint_r_valid_i,
    input  logic   [DATA_WIDTH-1:0]     lint_r_rdata_i,
    input  logic                        lint_r_opc_i
  );

  // Registers
  logic [DATA_WIDTH/8-1:0]        sel_reg;
  logic   [ADDR_WIDTH-1:0]        addr_reg;  // Don't really need the two LSB, this info is in the SEL bits
  logic   [DATA_WIDTH-1:0]        data_in_reg;  // dbg->AXI
  logic   [DATA_WIDTH-1:0]        data_out_reg;  // AXI->dbg
  logic                           wr_reg;
  logic                           str_sync;  // This is 'active-toggle' rather than -high or -low.
  logic                           rdy_sync;  // ditto, active-toggle
  logic                           err_reg;

  // Sync registers.  TFF indicates TCK domain, WBFF indicates wb_clk domain
  logic     rdy_sync_tff1;
  logic     rdy_sync_tff2;
  logic     rdy_sync_tff2q;  // used to detect toggles
  logic     str_sync_wbff1;
  logic     str_sync_wbff2;
  logic     str_sync_wbff2q;  // used to detect toggles


  // Control Signals
  logic     data_o_en;    // latch wb_data_i
  logic     rdy_sync_en;  // toggle the rdy_sync signal, indicate ready to TCK domain
  logic     err_en;       // latch the wb_err_i signal

  // Internal signals
  logic [DATA_WIDTH/8-1:0] be_dec;        // word_size and low-order address bits decoded to SEL bits
  logic                        start_toggle;  // AXI domain, indicates a toggle on the start strobe
  logic   [DATA_WIDTH-1:0] swapped_data_i;
  logic   [DATA_WIDTH-1:0] swapped_data_out;

  // AXI4 FSM states
  enum logic [1:0] {S_IDLE,S_DATA,S_RESP} lint_fsm_state,next_fsm_state;



  // Create byte enable signals from word_size and address (combinatorial)
  // This uses LITTLE ENDIAN byte ordering...lowest-addressed bytes is the
  // least-significant byte of the 32-bit WB bus.
  generate
    if (DATA_WIDTH == 64)
    begin

      always_comb
      begin
        case (word_size_i)
          4'h1:
            begin
              if(addr_i[2:0] == 3'b000)      be_dec = 8'b00000001;
              else if(addr_i[2:0] == 3'b001) be_dec = 8'b00000010;
              else if(addr_i[2:0] == 3'b010) be_dec = 8'b00000100;
              else if(addr_i[2:0] == 3'b011) be_dec = 8'b00001000;
              else if(addr_i[2:0] == 3'b100) be_dec = 8'b00010000;
              else if(addr_i[2:0] == 3'b101) be_dec = 8'b00100000;
              else if(addr_i[2:0] == 3'b110) be_dec = 8'b01000000;
              else                           be_dec = 8'b10000000;
            end
          4'h2:
            begin
              if(addr_i[2:1] == 2'b00)       be_dec = 8'b00000011;
              else if(addr_i[2:1] == 2'b01)  be_dec = 8'b00001100;
              else if(addr_i[2:1] == 2'b10)  be_dec = 8'b00110000;
              else                           be_dec = 8'b11000000;
            end
          4'h4:
            begin
              if(addr_i[2] == 1'b0)          be_dec = 8'b00001111;
              else                           be_dec = 8'b11110000;
            end
          4'h8:                              be_dec = 8'b11111111;
          default:                           be_dec = 8'b11111111;  // default to 64-bit access
        endcase
      end
    end
    else if (DATA_WIDTH == 32)
    begin
      always_comb
      begin
        case (word_size_i)
          4'h1:
            begin
              if(addr_i[1:0] == 2'b00)       be_dec = 4'b0001;
              else if(addr_i[1:0] == 2'b01)  be_dec = 4'b0010;
              else if(addr_i[1:0] == 2'b10)  be_dec = 4'b0100;
              else                           be_dec = 4'b1000;
            end
          4'h2:
            begin
              if(addr_i[1] == 1'b0)          be_dec = 4'b0011;
              else                           be_dec = 4'b1100;
            end
          4'h4:
                                             be_dec = 4'b1111;
          4'h8:
                                             be_dec = 4'b1111;  //error if it happens
          default:                           be_dec = 4'b1111;  // default to 32-bit access
        endcase // word_size_i
      end
    end
  endgenerate

  // Byte- or word-swap data as necessary.  Use the non-latched be_dec signal,
  // since it and the swapped data will be latched at the same time.
  // Remember that since the data is shifted in LSB-first, shorter words
  // will be in the high-order bits. (combinatorial)
  generate
    if (DATA_WIDTH == 64)
    begin

      always_comb
      begin
          case (be_dec)
            8'b00001111: swapped_data_i = {32'h0, data_i[63:32]};
            8'b11110000: swapped_data_i = {       data_i[63:32],  32'h0};
            8'b00000011: swapped_data_i = {48'h0, data_i[63:48]};
            8'b00001100: swapped_data_i = {32'h0, data_i[63:48], 16'h0};
            8'b00110000: swapped_data_i = {16'h0, data_i[63:48], 32'h0};
            8'b11000000: swapped_data_i = {       data_i[63:48], 48'h0};
            8'b00000001: swapped_data_i = {56'h0, data_i[63:56]};
            8'b00000010: swapped_data_i = {48'h0, data_i[63:56],  8'h0};
            8'b00000100: swapped_data_i = {40'h0, data_i[63:56], 16'h0};
            8'b00001000: swapped_data_i = {32'h0, data_i[63:56], 24'h0};
            8'b00010000: swapped_data_i = {24'h0, data_i[63:56], 32'h0};
            8'b00100000: swapped_data_i = {16'h0, data_i[63:56], 40'h0};
            8'b01000000: swapped_data_i = { 8'h0, data_i[63:56], 48'h0};
            8'b10000000: swapped_data_i = {       data_i[63:56], 56'h0};
            default:     swapped_data_i =         data_i;
          endcase
      end
    end
    else if (DATA_WIDTH == 32)
    begin
      always_comb
      begin
        case (be_dec)
          4'b1111: swapped_data_i =         data_i[63:32];
          4'b0011: swapped_data_i = {16'h0, data_i[63:48]};
          4'b1100: swapped_data_i = {       data_i[63:48], 16'h0};
          4'b0001: swapped_data_i = {24'h0, data_i[63:56]};
          4'b0010: swapped_data_i = {16'h0, data_i[63:56],  8'h0};
          4'b0100: swapped_data_i = {8'h0,  data_i[63:56], 16'h0};
          4'b1000: swapped_data_i = {       data_i[63:56], 24'h0};
          default: swapped_data_i =         data_i[63:32];
        endcase
      end
    end
  endgenerate

  // Byte- or word-swap the WB->dbg data, as necessary (combinatorial)
  // We assume bits not required by SEL are don't care.  We reuse assignments
  // where possible to keep the MUX smaller.  (combinatorial)
  generate if (DATA_WIDTH == 64) begin
    always @(*)
    begin
      case (sel_reg)
        8'b00001111: swapped_data_out =         lint_r_rdata_i;
        8'b11110000: swapped_data_out = {32'h0, lint_r_rdata_i[63:32]};
        8'b00000011: swapped_data_out =         lint_r_rdata_i;
        8'b00001100: swapped_data_out = {16'h0, lint_r_rdata_i[63:16]};
        8'b00110000: swapped_data_out = {32'h0, lint_r_rdata_i[63:32]};
        8'b11000000: swapped_data_out = {48'h0, lint_r_rdata_i[63:48]};
        8'b00000001: swapped_data_out =         lint_r_rdata_i;
        8'b00000010: swapped_data_out = {8'h0,  lint_r_rdata_i[63:8]};
        8'b00000100: swapped_data_out = {16'h0, lint_r_rdata_i[63:16]};
        8'b00001000: swapped_data_out = {24'h0, lint_r_rdata_i[63:24]};
        8'b00010000: swapped_data_out = {32'h0, lint_r_rdata_i[63:32]};
        8'b00100000: swapped_data_out = {40'h0, lint_r_rdata_i[63:40]};
        8'b01000000: swapped_data_out = {48'h0, lint_r_rdata_i[63:48]};
        8'b10000000: swapped_data_out = {56'h0, lint_r_rdata_i[63:56]};
        default:     swapped_data_out =         lint_r_rdata_i;
      endcase
    end
  end else if (DATA_WIDTH == 32) begin
    always @(*)
    begin
      case (sel_reg)
        4'b1111: swapped_data_out =         lint_r_rdata_i;
        4'b0011: swapped_data_out =         lint_r_rdata_i;
        4'b1100: swapped_data_out = {16'h0, lint_r_rdata_i[31:16]};
        4'b0001: swapped_data_out =         lint_r_rdata_i;
        4'b0010: swapped_data_out = {8'h0,  lint_r_rdata_i[31:8]};
        4'b0100: swapped_data_out = {16'h0, lint_r_rdata_i[31:16]};
        4'b1000: swapped_data_out = {24'h0, lint_r_rdata_i[31:24]};
        default: swapped_data_out =         lint_r_rdata_i;
      endcase
    end
  end
  endgenerate


  // Latch input data on 'start' strobe, if ready.
  always_ff @(posedge tck_i, negedge trstn_i)
  begin
    if(~trstn_i) begin
      sel_reg     <=  'h0;
      addr_reg    <=  'h0;
      data_in_reg <=  'h0;
      wr_reg      <= 1'b0;
    end
    else
    if(strobe_i && rdy_o) begin
      sel_reg  <= be_dec;
      addr_reg <= addr_i;
      if(!rd_wrn_i) data_in_reg <= swapped_data_i;
      wr_reg <= ~rd_wrn_i;
    end
  end

  // Create toggle-active strobe signal for clock sync.  This will start a transaction
  // on the AXI once the toggle propagates to the FSM in the AXI domain.
  always_ff @(posedge tck_i, negedge trstn_i)
  begin
    if(~trstn_i)               str_sync <= 1'b0;
    else if(strobe_i && rdy_o) str_sync <= ~str_sync;
  end

  // Create rdy_o output.  Set on reset, clear on strobe (if set), set on input toggle
  always_ff @(posedge tck_i, negedge trstn_i)
  begin
    if(~trstn_i) begin
      rdy_sync_tff1  <= 1'b0;
      rdy_sync_tff2  <= 1'b0;
      rdy_sync_tff2q <= 1'b0;
    end else begin
      rdy_sync_tff1  <= rdy_sync;       // Synchronize the ready signal across clock domains
      rdy_sync_tff2  <= rdy_sync_tff1;
      rdy_sync_tff2q <= rdy_sync_tff2;  // used to detect toggles
    end
  end

  always_ff @(posedge tck_i, negedge trstn_i)
  begin
    if(~trstn_i) begin
      rdy_o <= 1'b1;
    end
    else
    begin
      if(strobe_i && rdy_o)
        rdy_o <= 1'b0;
      else if(rdy_sync_tff2 != rdy_sync_tff2q)
        rdy_o <= 1'b1;
    end
  end

  //////////////////////////////////////////////////////////
  // Direct assignments, unsynchronized

  assign lint_add_o   = addr_reg;
  assign lint_wdata_o = data_in_reg;
  assign lint_be_o    = sel_reg;

  always_comb
  begin
    if (DATA_WIDTH == 64)
      data_o = data_out_reg;
    else if (DATA_WIDTH == 32)
      data_o = {32'h0,data_out_reg};
  end

  assign err_o  = err_reg;

  assign lint_aux_o  = 'h0;

  ///////////////////////////////////////////////////////
  // AXI clock domain

  // synchronize the start strobe
  always_ff @(posedge clk_i, negedge rstn_i)
  begin
     if(!rstn_i) begin
       str_sync_wbff1  <= 1'b0;
       str_sync_wbff2  <= 1'b0;
       str_sync_wbff2q <= 1'b0;
     end else begin
       str_sync_wbff1  <= str_sync;
       str_sync_wbff2  <= str_sync_wbff1;
       str_sync_wbff2q <= str_sync_wbff2;  // used to detect toggles
     end
  end

  assign start_toggle = (str_sync_wbff2 != str_sync_wbff2q);

  // Error indicator register
  always_ff @(posedge clk_i, negedge rstn_i)
  begin
      if(!rstn_i) err_reg <= 1'b0;
      else if(err_en) err_reg <= 1'b0; //TODO check if lint can return err
  end

  // WB->dbg data register
  always_ff @ (posedge clk_i, negedge rstn_i)
  begin
    if(!rstn_i)   data_out_reg <= 32'h0;
    else if(data_o_en) data_out_reg <= swapped_data_out;
  end

  // Create a toggle-active ready signal to send to the TCK domain
  always_ff @(posedge clk_i, negedge rstn_i)
  begin
    if(!rstn_i)     rdy_sync <= 1'b0;
    else if(rdy_sync_en) rdy_sync <= ~rdy_sync;
  end

   /////////////////////////////////////////////////////
   // Small state machine to create AXI accesses
   // Not much more that an 'in_progress' bit, but easier
   // to read.  Deals with single-cycle and multi-cycle
   // accesses.

  // Sequential bit
  always_ff @(posedge clk_i, negedge rstn_i)
  begin
    if(~rstn_i) lint_fsm_state <= S_IDLE;
    else             lint_fsm_state <= next_fsm_state;
  end

  // Determination of next state (combinatorial)
  always_comb
  begin
    lint_wen_o = 1'b1;
    lint_req_o = 1'b0;
    next_fsm_state      = lint_fsm_state;
    rdy_sync_en         = 1'b0;
    data_o_en           = 1'b0;
    err_en              = 1'b0;

    case (lint_fsm_state)
      S_IDLE:
      begin
        if(start_toggle)
          next_fsm_state = S_DATA;  // Don't go to next state for 1-cycle transfer
        else
          next_fsm_state = S_IDLE;
      end
      S_DATA:
      begin
        lint_req_o = 1'b1;
        if (wr_reg)
          lint_wen_o = 1'b0;
        if (lint_gnt_i)
          if (wr_reg)
          begin
            next_fsm_state = S_IDLE;
            rdy_sync_en    = 1'b1;
            err_en         = 1'b1;
          end
          else
            next_fsm_state = S_RESP;
      end
      S_RESP:
      begin
        if (lint_r_valid_i)
        begin
          next_fsm_state = S_IDLE;
          rdy_sync_en    = 1'b1;
          err_en         = 1'b1;
          if (!wr_reg)
            data_o_en    = 1'b1;
        end
      end
    endcase
  end

endmodule
