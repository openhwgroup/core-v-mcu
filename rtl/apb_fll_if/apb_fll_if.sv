// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module apb_fll_if
#(
    parameter APB_ADDR_WIDTH = 12
)
(
    input  logic                      HCLK,
    input  logic                      HRESETn,
    input  logic [APB_ADDR_WIDTH-1:0] PADDR,
    input  logic               [31:0] PWDATA,
    input  logic                      PWRITE,
    input  logic                      PSEL,
    input  logic                      PENABLE,
    output logic               [31:0] PRDATA,
    output logic                      PREADY,
    output logic                      PSLVERR,

    output logic                      fll1_req,
    output logic                      fll1_wrn,
    output logic                [4:0] fll1_add,
    output logic               [31:0] fll1_data,
    input  logic                      fll1_ack,
    input  logic               [31:0] fll1_r_data,
    input  logic                      fll1_lock,
    output logic                      fll2_req,
    output logic                      fll2_wrn,
    output logic                [4:0] fll2_add,
    output logic               [31:0] fll2_data,
    input  logic                      fll2_ack,
    input  logic               [31:0] fll2_r_data,
    input  logic                      fll2_lock,
    output logic                      fll3_req,
    output logic                      fll3_wrn,
    output logic                [4:0] fll3_add,
    output logic               [31:0] fll3_data,
    input  logic                      fll3_ack,
    input  logic               [31:0] fll3_r_data,
    input  logic                      fll3_lock
);

    logic        fll1_rd_access;
    logic        fll1_wr_access;
    logic        fll2_rd_access;
    logic        fll2_wr_access;
    logic        fll3_rd_access;
    logic        fll3_wr_access;

    logic        read_ready;
    logic        write_ready;
    logic [31:0] read_data;

    logic        rvalid;

    logic        fll1_ack_sync0;
    logic        fll1_ack_sync;
    logic        fll2_ack_sync0;
    logic        fll2_ack_sync;
    logic        fll3_ack_sync0;
    logic        fll3_ack_sync;

    logic        fll1_lock_sync0;
    logic        fll1_lock_sync;
    logic        fll2_lock_sync0;
    logic        fll2_lock_sync;
    logic        fll3_lock_sync0;
    logic        fll3_lock_sync;

    logic        fll1_valid;
    logic        fll2_valid;
    logic        fll3_valid;

    enum logic [3:0] { IDLE, CVP1_PHASE1, CVP1_PHASE2, CVP2_PHASE1, CVP2_PHASE2, CVP3_PHASE1, CVP3_PHASE2, READ, WRITE, WAIT} state,state_next;

    always_ff @(posedge HCLK, negedge HRESETn)
    begin
        if (!HRESETn)
          begin
            fll1_valid <= 0;
            fll2_valid <= 0;
            fll3_valid <= 0;
            fll1_ack_sync0  <= 1'b0;
            fll1_ack_sync   <= 1'b0;
            fll2_ack_sync0  <= 1'b0;
            fll2_ack_sync   <= 1'b0;
            fll3_ack_sync0  <= 1'b0;
            fll3_ack_sync   <= 1'b0;
            fll1_lock_sync0 <= 1'b0;
            fll1_lock_sync  <= 1'b0;
            fll2_lock_sync0 <= 1'b0;
            fll2_lock_sync  <= 1'b0;
            fll3_lock_sync0 <= 1'b0;
            fll3_lock_sync  <= 1'b0;
            state           <= IDLE;
            write_ready <= 0;
            read_ready <= 0;
        end
        else
        begin
            fll1_ack_sync0  <= fll1_ack & !PREADY & PENABLE;
            fll1_ack_sync   <= fll1_ack_sync0 &  !PREADY & PENABLE ;
            fll2_ack_sync0  <= fll2_ack &  !PREADY & PENABLE;
            fll2_ack_sync   <= fll2_ack_sync0 &  !PREADY & PENABLE;
            fll3_ack_sync0  <= fll3_ack &  !PREADY & PENABLE;
            fll3_ack_sync   <= fll3_ack_sync0 &  !PREADY & PENABLE;
            fll1_lock_sync0 <= fll1_lock &  !PREADY & PENABLE;
            fll1_lock_sync  <= fll1_lock_sync0 &  !PREADY & PENABLE;
            fll2_lock_sync0 <= fll2_lock &  !PREADY & PENABLE;
            fll2_lock_sync  <= fll2_lock_sync0 &  !PREADY & PENABLE;
            fll3_lock_sync0 <= fll3_lock &  !PREADY & PENABLE;
            fll3_lock_sync  <= fll3_lock_sync0 &  !PREADY & PENABLE;
//            state           <= state_next;
            case (state)
              IDLE: begin
                fll1_valid <= 0;
                fll2_valid <= 0;
                fll3_valid <= 0;
                write_ready <= 0;
                read_ready <= 0;

                if (PSEL & PENABLE)
                  if (PWRITE) state <= WRITE;
                  else state <= READ;
              end
              WRITE: begin
                case (PADDR[APB_ADDR_WIDTH-1:5])
                  0: fll1_valid <= 1;
                  1: fll2_valid <= 1;
                  2: fll3_valid <= 1;
                endcase // case (PADDR[3:2])
                if (fll1_ack_sync | fll2_ack_sync | fll3_ack_sync) begin
                  write_ready <= 1;
                  state <= WAIT;
                end
              end // case: WRITE
              READ: begin
                case (PADDR[APB_ADDR_WIDTH-1:5])
                  0: begin
                    fll1_valid <= 1;
                    read_data <= fll1_r_data;
                  end
                  1: begin
                    fll2_valid <= 1;
                    read_data <= fll2_r_data;
                  end
                  2: begin
                    fll3_valid <= 1;
                    read_data <= fll3_r_data;
                  end
                endcase // case (PADDR[3:2])
                if (fll1_ack_sync | fll2_ack_sync | fll3_ack_sync) begin
                  read_ready <= 1;
                  state <= WAIT;
                end
              end // case: READ
              WAIT:
              if (PENABLE == 0)
                state <= IDLE;
              endcase

            end // else: !if(!HRESETn)
    end // always_ff @ (posedge HCLK, negedge HRESETn)

  assign fll1_req = fll1_valid;
  assign fll2_req = fll2_valid;
  assign fll3_req = fll3_valid;

  assign fll1_wrn   =  ~PWRITE;
  assign fll1_add   = fll1_valid ? PADDR[4:0] : '0;
  assign fll1_data  = fll1_valid ? PWDATA     : '0;

  assign fll2_wrn   =  ~PWRITE;
  assign fll2_add   = fll2_valid ? PADDR[4:0] : '0;
  assign fll2_data  = fll2_valid ? PWDATA     : '0;

  assign fll3_wrn   =  ~PWRITE;
  assign fll3_add   = fll3_valid ? PADDR[4:0] : '0;
  assign fll3_data  = fll3_valid ? PWDATA     : '0;


    assign PREADY     = PWRITE ? write_ready : read_ready;
    assign PRDATA     = read_data;
    assign PSLVERR    = 1'b0;

endmodule
