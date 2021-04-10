// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module jtag_axi_wrap
  (
   input logic 	       update,

   input logic [95:0]  axireg_i,
   output logic [95:0] axireg_o,

   input logic 	       clk_i,
   input logic 	       rst_ni,

   AXI_BUS.Master      jtag_master
   );

   typedef enum        logic [2:0]       {idle, request, readdata, storedata, ack} FSMState;

   FSMState            state_dn, state_dp;
   logic [63:0]        axireg_n, axireg_p;

   logic 	       axi_request;
   logic 	       loadstore;

   assign axi_request = axireg_i[0];
   assign loadstore   = axireg_i[1];


   always_comb begin

      state_dn = state_dp;

      axireg_n = axireg_p;
      axireg_o = {32'b0, axireg_p};

      // default assignments
      jtag_master.aw_id     = '0;  // write address ID. set to 0
      jtag_master.aw_addr   = '0;  // write address
      jtag_master.aw_lock   = '0;  // write lock type (00 for normal access)
      jtag_master.aw_cache  = '0;  // write attributes for caching (0000 for noncacheable and nunbufferable)
      jtag_master.aw_prot   = '0;  // no idea
      jtag_master.aw_region = '0;  // optional 000
      jtag_master.aw_user   = '0;  // dunno
      jtag_master.aw_qos    = '0;  // dunno
      jtag_master.aw_valid  = '0;  // write address valid

      jtag_master.ar_id     = '0;
      jtag_master.ar_addr   = '0;
      jtag_master.ar_lock   = '0;
      jtag_master.ar_cache  = '0;
      jtag_master.ar_prot   = '0;
      jtag_master.ar_region = '0;
      jtag_master.ar_user   = '0;
      jtag_master.ar_qos    = '0;
      jtag_master.ar_valid  = '0;

      jtag_master.w_data    = '0;
      jtag_master.w_strb    = '0;
      jtag_master.w_last    = '0;
      jtag_master.w_user    = '0;
      jtag_master.w_valid   = '0;

      // constant signals
      jtag_master.aw_burst = 1'b1;  // incremental burst
      jtag_master.ar_burst = 1'b1;  // incremental burst
      jtag_master.aw_size = 3'b011; // store 8 bytes
      jtag_master.ar_size = 3'b011; // read 8 bytes
      jtag_master.aw_len = 4'b0;    // single burst
      jtag_master.ar_len = 4'b0;    // single burst

      jtag_master.b_ready = 1'b1;   // master can accept resp. information
      jtag_master.r_ready   = '0; // read ready. 1 master ready/ 0 master not ready

      case (state_dp)

	idle: begin
	   if (update)
	     state_dn = request;
	end

	request: begin

	   if (axi_request) begin
	      if (loadstore) begin // store data
		 jtag_master.aw_addr = {axireg_i[31:3] , 3'b0};
		 jtag_master.aw_valid = 1'b1;

		 if (jtag_master.aw_ready)
		   state_dn = storedata;
		 else
		   state_dn = request;

	      end
	      else begin // read data
		 jtag_master.ar_addr = {axireg_i[31:3] , 3'b0};
		 jtag_master.ar_valid = 1'b1;

		 if (jtag_master.ar_ready)
		   state_dn = readdata;
		 else
		   state_dn = request;

	      end
	   end
	   else
	     state_dn = idle;         // nothing to send or receive

	end

	readdata: begin

	   jtag_master.r_ready = 1'b1;

	   if (jtag_master.r_valid & jtag_master.r_last) begin
	      axireg_n = jtag_master.r_data;
	      state_dn = idle;
	   end
	   else
	     state_dn = readdata;

	end

	storedata: begin

	   jtag_master.w_data = axireg_i[95:32];
	   jtag_master.w_valid = 1'b1;
	   jtag_master.w_last = 1'b1;
	   jtag_master.w_strb = 8'hff;

	   if (jtag_master.w_ready)
	     state_dn = ack;
	   else
	     state_dn = storedata;

	end

	ack: begin

	   if (jtag_master.b_valid)
	     state_dn = idle;
	   else
	     state_dn = ack;
	end


      endcase // case (state_dp)

   end

   always_ff @(posedge clk_i, negedge rst_ni) begin
      if (~rst_ni) begin
	 state_dp <= idle;
	 axireg_p <= 64'b0;
      end
      else begin
	 state_dp <= state_dn;
	 axireg_p <= axireg_n;
      end
   end


endmodule // jtag_axi_wrap

