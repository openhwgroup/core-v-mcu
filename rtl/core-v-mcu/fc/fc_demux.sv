// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


//`define  XBAR_DEMUX_VERBOSE

`define TO_MASTER0 0
`define TO_MASTER1 1

module fc_demux (
    input logic                    clk,
    input logic                    rst_n,
    input logic                    port_sel_i,
          XBAR_TCDM_BUS.Slave      slave_port,
          XBAR_TCDM_BUS.Master     master_port0,
          UNICAD_MEM_BUS_32.Master master_port1
);

  // Internal Signals from the decoder to the Interfaces
  logic        req_port1;
  logic [31:0] addr_port1;
  logic        gnt_port1;
  logic        rvalid_port1;
  logic        wen_port1;
  logic [ 3:0] be_port1;
  logic [31:0] rdata_port1;
  logic [31:0] wdata_port1;

  logic        req_port0;
  logic [31:0] addr_port0;
  logic        gnt_port0;
  logic        rvalid_port0;
  logic        wen_port0;
  logic [ 3:0] be_port0;
  logic [31:0] rdata_port0;
  logic [31:0] wdata_port0;

  logic        dest_q;

  logic        req_slave;
  logic [31:0] addr_slave;
  logic        gnt_slave;
  logic        rvalid_slave;
  logic        wen_slave;
  logic [ 3:0] be_slave;
  logic [31:0] rdata_slave;
  logic [31:0] wdata_slave;

  logic master_port1_gnt, master_port1_r_valid;

  assign req_slave          = slave_port.req;
  assign addr_slave         = slave_port.add;
  assign wen_slave          = slave_port.wen;
  assign wdata_slave        = slave_port.wdata;
  assign be_slave           = slave_port.be;
  assign slave_port.gnt     = gnt_slave;
  assign slave_port.r_rdata = rdata_slave;
  assign slave_port.r_valid = rvalid_slave;

  assign master_port0.req   = req_port0;
  assign master_port0.add   = addr_port0;
  assign master_port0.wen   = wen_port0;
  assign master_port0.wdata = wdata_port0;
  assign master_port0.be    = be_port0;
  assign gnt_port0          = master_port0.gnt;
  assign rdata_port0        = master_port0.r_rdata;
  assign rvalid_port0       = master_port0.r_valid;

  assign master_port1.csn   = ~req_port1;
  assign master_port1.add   = addr_port1;
  assign master_port1.wen   = wen_port1;
  assign master_port1.wdata = wdata_port1;
  assign master_port1.be    = be_port1;
  assign gnt_port1          = master_port1_gnt;
  assign rdata_port1        = master_port1.rdata;
  assign rvalid_port1       = master_port1_r_valid;
  assign master_port1_gnt   = 1'b1;

  enum logic {
    IDLE,
    VALID
  } demux_state_q;

  // MAXIMUM one outstanding REFILL
  always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
      dest_q               <= `TO_MASTER0;
      demux_state_q        <= IDLE;
      master_port1_r_valid <= 1'b0;
    end else begin
      unique case (demux_state_q)
        IDLE: begin
          if (req_slave & gnt_slave) begin
            case (port_sel_i)
              1'b0: begin
                dest_q <= `TO_MASTER0;
                master_port1_r_valid <= 1'b0;
              end
              1'b1: begin
                dest_q <= `TO_MASTER1;
                master_port1_r_valid <= master_port1_gnt;
              end
            endcase
            demux_state_q <= VALID;
          end
        end  // IDLE
        VALID: begin
          if (rvalid_slave) begin
            if (req_slave & gnt_slave) begin
              case (port_sel_i)
                1'b0: begin
                  dest_q <= `TO_MASTER0;
                  master_port1_r_valid <= 1'b0;
                end
                1'b1: begin
                  dest_q <= `TO_MASTER1;
                  master_port1_r_valid <= master_port1_gnt;
                end
              endcase
              demux_state_q <= VALID;
            end else begin
              demux_state_q        <= IDLE;
              master_port1_r_valid <= 1'b0;
            end
          end
        end  // VALID
      endcase

    end
  end

  //MULTIPLEXERS
  always_comb begin
    req_port0 = req_slave  & ~port_sel_i;

    //operand isolation
    addr_port0  = addr_slave & {32{~port_sel_i}};
    wen_port0   = wen_slave  & {32{~port_sel_i}};
    be_port0    = be_slave   & {32{~port_sel_i}};
    wdata_port0 = wdata_slave  & {32{~port_sel_i}};

    req_port1   = req_slave  & port_sel_i;
    //operand isolation
    addr_port1  = addr_slave & {32{port_sel_i}};
    wen_port1   = wen_slave  & {32{port_sel_i}};
    be_port1    = be_slave   & {32{port_sel_i}};
    wdata_port1 = wdata_slave  & {32{port_sel_i}};

`ifndef SYNTHESIS
`ifdef XBAR_DEMUX_VERBOSE
    unique case (1'b1)
      req_port0: $display("Request towards port0 (addr %x) at %t", addr_port0, $time);
      req_port1: $display("Request towards port1 (addr %x) at %t", addr_port1, $time);
    endcase
`endif
`endif

    // Select the grant depending on the targ destqination
    if (req_slave) gnt_slave = port_sel_i ? gnt_port1 : gnt_port0;
    else gnt_slave = 1'b0;

    // Backroute the response from Master0/Master1 to Slave
    case (dest_q)
      `TO_MASTER0: begin
        {rvalid_slave, rdata_slave} = {rvalid_port0, rdata_port0};
      end
      `TO_MASTER1: begin
        {rvalid_slave, rdata_slave} = {rvalid_port1, rdata_port1};
      end
      default: begin
        {rvalid_slave, rdata_slave} = '0;
      end
    endcase  //~case (dest_q)
  end

endmodule
