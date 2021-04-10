// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`define I2C_CMD_START   4'h0
`define I2C_CMD_STOP    4'h2
`define I2C_CMD_RD_ACK  4'h4
`define I2C_CMD_RD_NACK 4'h6
`define I2C_CMD_WR      4'h8
`define I2C_CMD_WAIT    4'hA
`define I2C_CMD_RPT     4'hC
`define I2C_CMD_CFG     4'hE
`define I2C_CMD_WAIT_EV 4'h1

`define BUS_CMD_NONE  3'b000
`define BUS_CMD_START 3'b001
`define BUS_CMD_STOP  3'b010
`define BUS_CMD_WRITE 3'b011
`define BUS_CMD_READ  3'b100
`define BUS_CMD_WAIT  3'b101


module udma_i2c_control
(
	//
	// inputs & outputs
	//
	input  logic                      clk_i,          // master clock
	input  logic                      rstn_i,         // asynchronous active low reset

	input  logic                [3:0] ext_events_i,

	input  logic                [7:0] data_tx_i,
	input  logic                      data_tx_valid_i,
	output logic                      data_tx_ready_o,

	output logic                [7:0] data_rx_o,
	output logic                      data_rx_valid_o,
	input  logic                      data_rx_ready_i,

	input  logic                      sw_rst_i,

	output logic                      err_o,

	// I2C signals
	input  logic                      scl_i,
	output logic                      scl_o,
	output logic                      scl_oe,
	input  logic                      sda_i,
	output logic                      sda_o,
	output logic                      sda_oe
);

	//
	// Variable declarations
	//
    enum logic [3:0]    {
                            ST_WAIT_IN_CMD,
                            ST_WAIT_EV,
                            ST_CMD_DONE,
                            ST_READ,
                            ST_WRITE,
                            ST_STORE_DATA,
                            ST_SKIP_CMD,
                            ST_GET_DATA,
                            ST_GET_WAIT,
                            ST_GET_WAIT_EV,
                            ST_GET_RPT,
                            ST_GET_CFG_MSB,
                            ST_GET_CFG_LSB
                        } CS,NS;

    logic s_cmd_start;
    logic s_cmd_stop;
    logic s_cmd_rd_ack;
    logic s_cmd_rd_nack;
    logic s_cmd_wr;
    logic s_cmd_wait;
    logic s_cmd_wait_ev;
    logic s_cmd_rpt;
    logic s_cmd_cfg;

    logic s_en_decode;

    logic s_sample_div;
    logic s_sample_rpt;
    logic s_sample_ev;

    logic [15:0] s_div_num;
    logic [15:0] r_div_num;

    logic [6:0] s_rpt_num;
    logic [6:0] r_rpt_num;

    logic [7:0] s_data;
    logic [7:0] r_data;
    logic [7:0] s_bits;
    logic [7:0] r_bits;

    logic s_core_txd;
    logic s_core_rxd;

    logic r_sample_wd;
    logic s_sample_wd;

    logic r_rd_ack;
    logic s_rd_ack;

    logic [2:0] s_bus_if_cmd;
    logic       s_bus_if_cmd_valid;

    logic s_en_bus_ctrl;

	logic s_scl_oen;
	logic s_sda_oen;

	logic s_cmd_done;

	logic s_busy;
	logic s_busy_rise;
	logic r_busy;
	logic s_al;
	logic s_al_rise;
	logic r_al;

	logic s_do_rst;

	logic s_data_tx_ready;

	logic s_data_rx_valid;

	logic [1:0] s_ev_sel;
	logic [1:0] r_ev_sel;

	logic       s_event;

	assign s_busy_rise = ~r_busy & s_busy;
	assign s_al_rise   = ~r_al   & s_al;

	assign err_o       = s_busy_rise | s_al_rise;

	assign s_do_rst    = sw_rst_i;

    assign s_cmd_start   = s_en_decode ? (data_tx_i[7:4] == `I2C_CMD_START)   : 1'b0;
    assign s_cmd_stop    = s_en_decode ? (data_tx_i[7:4] == `I2C_CMD_STOP)    : 1'b0;
    assign s_cmd_rd_ack  = s_en_decode ? (data_tx_i[7:4] == `I2C_CMD_RD_ACK)  : 1'b0;
    assign s_cmd_rd_nack = s_en_decode ? (data_tx_i[7:4] == `I2C_CMD_RD_NACK) : 1'b0;
    assign s_cmd_wr      = s_en_decode ? (data_tx_i[7:4] == `I2C_CMD_WR)      : 1'b0;
    assign s_cmd_wait    = s_en_decode ? (data_tx_i[7:4] == `I2C_CMD_WAIT)    : 1'b0;
    assign s_cmd_wait_ev = s_en_decode ? (data_tx_i[7:4] == `I2C_CMD_WAIT_EV) : 1'b0;
    assign s_cmd_rpt     = s_en_decode ? (data_tx_i[7:4] == `I2C_CMD_RPT)     : 1'b0;
    assign s_cmd_cfg     = s_en_decode ? (data_tx_i[7:4] == `I2C_CMD_CFG)     : 1'b0;

    assign s_ev_sel      = data_tx_i[1:0];

    assign s_core_txd = (CS == ST_READ) ? r_rd_ack : s_data[7];

    assign data_rx_o       = r_data;

    assign data_rx_valid_o = s_do_rst ? 1'b1 : s_data_rx_valid;
    assign data_tx_ready_o = s_do_rst ? 1'b1 : s_data_tx_ready;

	//
	// Module body
	//
	assign scl_oe = ~s_scl_oen;
	assign sda_oe = ~s_sda_oen;

    always_comb begin : proc_s_event
        s_event = 1'b0;
        for(int i=0;i<4;i++)
            if(r_ev_sel == i)
                s_event = ext_events_i[i];
    end

	// hookup bus_controller
	udma_i2c_bus_ctrl bus_controller (
		.clk_i      ( clk_i              ),
		.rstn_i     ( rstn_i             ),
		.sw_rst_i   ( s_do_rst           ),
		.ena_i      ( s_en_bus_ctrl      ),
		.clk_cnt_i  ( r_div_num          ),
		.cmd_i      ( s_bus_if_cmd       ),
		.cmd_valid_i( s_bus_if_cmd_valid ),
		.cmd_ack_o  ( s_cmd_done         ),
		.busy_o     ( s_busy             ),
		.al_o       ( s_al               ),
		.din_i      ( s_core_txd         ),
		.dout_o     ( s_core_rxd         ),
		.scl_i      ( scl_i              ),
		.scl_o      ( scl_o              ),
		.scl_oen    ( s_scl_oen          ),
		.sda_i      ( sda_i              ),
		.sda_o      ( sda_o              ),
		.sda_oen    ( s_sda_oen          )
	);


	always_comb
	begin
		NS  = CS;
		s_data_tx_ready     = 1'b0;
		s_data_rx_valid     = 1'b0;
		s_bus_if_cmd        = `BUS_CMD_NONE;
		s_bus_if_cmd_valid  = 1'b0;
		s_rd_ack            = r_rd_ack;
		s_sample_wd         = r_sample_wd;
		s_rpt_num           = r_rpt_num;
		s_bits              = r_bits;
		s_data              = r_data;
		s_en_bus_ctrl       = 1'b1;
		s_en_decode         = 1'b0;
		s_div_num           = r_div_num;
		s_sample_div        = 1'b0;
		s_sample_rpt        = 1'b0;
		s_sample_ev         = 1'b0;
		case(CS)
			ST_WAIT_IN_CMD:
			begin
				s_en_bus_ctrl   = 1'b0;
				s_data_tx_ready	= 1'b1;
				s_en_bus_ctrl   = 1'b1;
				if (data_tx_valid_i)
				begin
					s_en_decode     = 1'b1;
					if(s_cmd_start)
					begin
						s_bus_if_cmd       = `BUS_CMD_START;
						s_bus_if_cmd_valid = 1'b1;
						NS = ST_CMD_DONE;
					end
					else if(s_cmd_stop)
					begin
						s_bus_if_cmd       = `BUS_CMD_STOP;
						s_bus_if_cmd_valid = 1'b1;
						NS = ST_CMD_DONE;
					end
					else if(s_cmd_wait)
					begin
						NS = ST_GET_WAIT;
					end
					else if(s_cmd_wait_ev)
					begin
						s_sample_ev = 1'b1;
						NS = ST_WAIT_EV;
					end
					else if(s_cmd_rd_ack)
					begin
	        			s_bus_if_cmd       = `BUS_CMD_READ;
						s_bus_if_cmd_valid = 1'b1;
						s_rd_ack = 1'b0;
						s_bits = 8'h8;
						NS = ST_READ;
					end
					else if(s_cmd_rd_nack)
					begin
	        			s_bus_if_cmd       = `BUS_CMD_READ;
						s_bus_if_cmd_valid = 1'b1;
						s_rd_ack = 1'b1;
						s_bits = 8'h8;
						NS = ST_READ;
					end
					else if(s_cmd_wr)
					begin
						NS = ST_GET_DATA;
					end
					else if(s_cmd_rpt)
					begin
						NS = ST_GET_RPT;
					end
					else if(s_cmd_cfg)
					begin
						NS = ST_GET_CFG_MSB;
					end
				end
			end
			ST_CMD_DONE:
			begin
				if (s_cmd_done && (r_bits == 'h0))
					NS = ST_WAIT_IN_CMD;
				else if (s_cmd_done && !(r_bits == 'h0))
				begin
        			s_bus_if_cmd       = `BUS_CMD_WAIT;
					s_bus_if_cmd_valid = 1'b1;
					s_bits             = r_bits - 1;
					NS = ST_CMD_DONE;
				end
			end
			ST_WAIT_EV:
			begin
				if (s_event && (r_bits == 'h0))
					NS = ST_WAIT_IN_CMD;
				else if (s_event && !(r_bits == 'h0))
				begin
					s_bits             = r_bits - 1;
					NS = ST_WAIT_EV;
				end
			end
			ST_READ:
				if (s_cmd_done && (r_bits == 'h1))
				begin
        			s_bus_if_cmd       = `BUS_CMD_WRITE;
					s_bus_if_cmd_valid = 1'b1;
					s_bits = r_bits - 1;
					s_data = {r_data[6:0],s_core_rxd};
					NS = ST_READ;
				end
				else if (s_cmd_done && !(r_bits == 'h0))
				begin
        			s_bus_if_cmd       = `BUS_CMD_READ;
					s_bus_if_cmd_valid = 1'b1;
					s_bits = r_bits - 1;
					s_data = {r_data[6:0],s_core_rxd};
					NS = ST_READ;
				end
				else if(s_cmd_done && (r_bits == 'h0))
				begin
					NS = ST_STORE_DATA;
				end
			ST_STORE_DATA:
			begin
				s_data_rx_valid = 1'b1;
				if (data_rx_ready_i)
				begin
					if(r_rpt_num == 'h0)
						NS = ST_WAIT_IN_CMD;
					else
					begin
	        			s_bus_if_cmd       = `BUS_CMD_READ;
						s_bus_if_cmd_valid = 1'b1;
						s_bits = 'h8;
						s_sample_rpt = 1'b1;
						s_rpt_num = r_rpt_num - 1;
						NS = ST_READ;
					end
				end
			end
			ST_GET_DATA:
			begin
					s_data_tx_ready	= 1'b1;
					if (data_tx_valid_i)
					begin
	        			s_bus_if_cmd       = `BUS_CMD_WRITE;
						s_bus_if_cmd_valid = 1'b1;
						s_data = data_tx_i;
						s_bits = 8'h8;
						NS = ST_WRITE;
					end
			end
			ST_SKIP_CMD:
			begin
				s_data_tx_ready	= 1'b1;
				begin
					NS = ST_WAIT_IN_CMD;
				end
			end
			ST_GET_RPT:
			begin
					s_data_tx_ready	= 1'b1;
					if (data_tx_valid_i)
					begin
						s_sample_rpt    = 1'b1;
						if (data_tx_i == 'h0)
						begin
							s_rpt_num = 'h0;
							NS = ST_SKIP_CMD;
						end
						else
						begin
	        				s_rpt_num       = data_tx_i - 1;
							NS = ST_WAIT_IN_CMD;
	        			end
					end
			end
			ST_GET_CFG_MSB:
			begin
					s_data_tx_ready	= 1'b1;
					if (data_tx_valid_i)
					begin
						s_sample_div = 1'b1;
	        			s_div_num[15:8] = data_tx_i;
						NS = ST_GET_CFG_LSB;
					end
			end
			ST_GET_CFG_LSB:
			begin
					s_data_tx_ready	= 1'b1;
					if (data_tx_valid_i)
					begin
						s_sample_div = 1'b1;
	        			s_div_num[7:0] = data_tx_i;
						NS = ST_WAIT_IN_CMD;
					end
			end
			ST_GET_WAIT:
			begin
					s_data_tx_ready	= 1'b1;
					if (data_tx_valid_i)
					begin
	        			s_bus_if_cmd       = `BUS_CMD_WAIT;
						s_bus_if_cmd_valid = 1'b1;
						s_bits = data_tx_i;
						NS = ST_CMD_DONE;
					end
			end
			ST_WRITE:
				if (s_cmd_done && (r_bits == 'h1))
				begin
        			s_bus_if_cmd       = `BUS_CMD_READ;
					s_bus_if_cmd_valid = 1'b1;
					s_data = {r_data[6:0],1'b0};
					s_bits = r_bits - 1;
					NS = ST_WRITE;
				end
				else if (s_cmd_done && !(r_bits == 'h0))
				begin
        			s_bus_if_cmd       = `BUS_CMD_WRITE;
					s_bus_if_cmd_valid = 1'b1;
					s_data = {r_data[6:0],1'b0};
					s_bits = r_bits - 1;
					NS = ST_WRITE;
				end
				else if(s_cmd_done && (r_bits == 'h0) && !(r_rpt_num == 'h0))
				begin
					s_bits = 'h8;
					s_sample_rpt = 1'b1;
					s_rpt_num = r_rpt_num - 1;
					NS = ST_GET_DATA;
				end
				else if (s_cmd_done && (r_bits == 'h0) && (r_rpt_num == 'h0))
				begin
					NS = ST_WAIT_IN_CMD;
				end
			default:
			begin
				NS  = ST_WAIT_IN_CMD;
				s_en_bus_ctrl       = 1'b0;
				s_data_tx_ready     = 1'b0;
				s_bus_if_cmd        = `BUS_CMD_NONE;
				s_bus_if_cmd_valid  = 1'b0;
				s_rd_ack            = r_rd_ack;
				s_sample_wd         = r_sample_wd;
				s_rpt_num           = r_rpt_num;
				s_bits              = r_bits;
				s_data              = r_data;
			end
		endcase // CS
	end

	always @(posedge clk_i or negedge rstn_i)
	  if (!rstn_i)
	  begin
	    CS          <= ST_WAIT_IN_CMD;
	    r_sample_wd <= 1'b0;
	    r_rpt_num   <= 'h0;
	    r_data      <= 'h0;
	    r_bits      <= 'h0;
	    r_rd_ack    <= 1'b0;
	    r_div_num   <= 16'h100;
	    r_busy      <= 1'b0;
	    r_al        <= 1'b0;
	    r_ev_sel    <=  'h0;
	  end
	  else
	  begin
	  	if (s_do_rst)
	  	begin
		    CS          <= ST_WAIT_IN_CMD;
		    r_sample_wd <= 1'b0;
		    r_rpt_num   <= 'h0;
	    	r_data      <= 'h0;
		    r_bits      <= 'h0;
	    	r_rd_ack    <= 1'b0;
		    r_div_num   <= 16'h100;
	    	r_busy      <= 1'b0;
	    	r_al        <= 1'b0;
     	    r_ev_sel    <=  'h0;
	  	end
	  	else
	  	begin
		  	CS  <= NS;
		  	r_sample_wd <= s_sample_wd;
	  		r_data      <= s_data;
		  	r_bits      <= s_bits;
		    r_rd_ack    <= s_rd_ack;
		    r_busy      <= s_busy;
		    r_al        <= s_al;
            if (s_sample_rpt)
		  		r_rpt_num <= s_rpt_num;
		    if (s_sample_div)
	    		r_div_num <= s_div_num;
	    	if (s_sample_ev)
	    		r_ev_sel  <= s_ev_sel;
	  	end
	  end



endmodule
