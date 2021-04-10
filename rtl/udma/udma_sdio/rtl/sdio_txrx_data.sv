// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

///////////////////////////////////////////////////////////////////////////////
//
// Description: Module handling data transfer
//
///////////////////////////////////////////////////////////////////////////////
//
// Authors    : Antonio Pullini (pullinia@iis.ee.ethz.ch)
//
///////////////////////////////////////////////////////////////////////////////
module sdio_txrx_data
(
    input  logic         clk_i,
    input  logic         rstn_i,

    input  logic         clr_stat_i,

    output logic   [5:0] status_o,

    output logic         busy_o,

    output logic         sdclk_en_o,

    input  logic         data_start_i,
    input  logic   [9:0] data_block_size_i,
    input  logic   [7:0] data_block_num_i,
    input  logic         data_rwn_i,
    input  logic         data_quad_i,
    output logic         data_last_o,

    output logic         eot_o,

    input  logic  [31:0] in_data_if_data_i, 
    input  logic         in_data_if_valid_i,
    output logic         in_data_if_ready_o, 

    output logic  [31:0] out_data_if_data_o, 
    output logic         out_data_if_valid_o,
    input  logic         out_data_if_ready_i, 

    output logic   [3:0] sddata_o,
    input  logic   [3:0] sddata_i,
    output logic   [3:0] sddata_oen_o
  );

  localparam STATUS_RSP_TIMEOUT   = 6'h1;

  localparam RSP_TYPE_NULL        = 3'b000;
  localparam RSP_TYPE_48_CRC      = 3'b001;
  localparam RSP_TYPE_48_NOCRC    = 3'b010;
  localparam RSP_TYPE_136         = 3'b011;
  localparam RSP_TYPE_48_BSY      = 3'b100;

    enum logic [4:0] {ST_IDLE,
                      ST_WAIT,
                      ST_TX_START,
                      ST_TX_STOP,
                      ST_TX_SHIFT,
                      ST_TX_CRC,
                      ST_TX_END,
                      ST_TX_CRCSTAT,
                      ST_TX_BUSY,
                      ST_RX_START,
                      ST_RX_STOP,
                      ST_RX_SHIFT,
                      ST_RX_CRC} s_state,r_state;

    logic [3:0] [15:0] s_crc;
    logic [3:0]        s_crc_block_en;
    logic [3:0]        s_crc_block_clr;
    logic [3:0]        s_crc_block_shift;
    logic [3:0]        s_crc_in;
    logic [3:0]        s_crc_out;
    logic              s_crc_en;
    logic              s_crc_clr;
    logic              s_crc_shift;
    logic              s_crc_intx;

    logic  [31:0] r_data;

    logic         s_eot;

    logic   [3:0] r_sddata;
    logic   [3:0] s_sddata;
    logic         s_sddata_oen;
    logic         s_shift_data;

    logic         s_cnt_start;
    logic         s_cnt_done;
    logic   [8:0] s_cnt_target;
    logic   [8:0] r_cnt;
    logic         r_cnt_running;
    logic   [5:0] s_status;
    logic   [5:0] r_status;
    logic         s_status_sample;

    logic   [2:0] r_bit_cnt;
    logic   [2:0] s_bit_cnt_target;

    logic   [7:0] r_cnt_block;
    logic   [7:0] s_cnt_block;
    logic         s_cnt_block_upd;
    logic         s_cnt_block_done;

    logic         s_cnt_byte_evnt;
    logic         s_cnt_byte;
    logic         r_cnt_byte;

    logic   [1:0] r_byte_in_word;
    logic   [3:0] s_dataout;
    logic  [31:0] s_datain;
    logic         s_busy;
 
    logic         s_in_data_ready;
    logic         s_lastbitofword;

    logic       s_clk_en;
    logic       s_rx_en;
    logic       s_out_data_valid;

    assign s_crc_in = s_crc_intx ? sddata_i : s_sddata;

    assign s_crc_block_en[0] = s_crc_en;
    assign s_crc_block_en[1] = data_quad_i & s_crc_en;
    assign s_crc_block_en[2] = data_quad_i & s_crc_en;
    assign s_crc_block_en[3] = data_quad_i & s_crc_en;

    assign s_crc_block_clr[0] = s_crc_clr;
    assign s_crc_block_clr[1] = data_quad_i & s_crc_clr;
    assign s_crc_block_clr[2] = data_quad_i & s_crc_clr;
    assign s_crc_block_clr[3] = data_quad_i & s_crc_clr;

    assign s_crc_block_shift[0] = s_crc_shift;
    assign s_crc_block_shift[1] = data_quad_i & s_crc_shift;
    assign s_crc_block_shift[2] = data_quad_i & s_crc_shift;
    assign s_crc_block_shift[3] = data_quad_i & s_crc_shift;

    assign sddata_o = r_sddata;

    assign sddata_oen_o[0] = s_sddata_oen;
    assign sddata_oen_o[1] = data_quad_i ? s_sddata_oen : 1'b1;
    assign sddata_oen_o[2] = data_quad_i ? s_sddata_oen : 1'b1;
    assign sddata_oen_o[3] = data_quad_i ? s_sddata_oen : 1'b1;

    assign data_last_o = s_busy & s_cnt_block_done;
    assign busy_o = s_busy;
    assign sdclk_en_o = s_clk_en;

    assign in_data_if_ready_o = s_in_data_ready;

    assign out_data_if_valid_o = s_out_data_valid;
    assign out_data_if_data_o = s_datain;

    assign eot_o = s_eot;
    assign status_o = r_status;

    genvar i;

    generate
      for(i=0;i<4;i++)
      begin
        sdio_crc16 i_data_crc (
          .clk_i         ( clk_i          ),
          .rstn_i        ( rstn_i         ),
          .crc16_o       ( s_crc[i]       ),
          .crc16_serial_o( s_crc_out[i]   ),
          .data_i        ( s_crc_in[i]    ),
          .shift_i       ( s_crc_block_shift[i] ),
          .clr_i         ( s_crc_block_clr[i]   ),
          .sample_i      ( s_crc_block_en[i]    )
        );
      end
    endgenerate

    always_comb begin : proc_data_in
      s_datain = r_data;
      if(data_quad_i)
      begin
        case(r_byte_in_word)
          0:
            begin
              if(r_bit_cnt == 0)
                s_datain[7:4] = sddata_i;
              else
                s_datain[3:0] = sddata_i;
            end
          1:
            begin
              if(r_bit_cnt == 0)
                s_datain[15:12] = sddata_i;
              else
                s_datain[11:8] = sddata_i;
            end
          2:
            begin
              if(r_bit_cnt == 0)
                s_datain[23:20] = sddata_i;
              else
                s_datain[19:16] = sddata_i;
            end
          3:
            begin
              if(r_bit_cnt == 0)
                s_datain[31:28] = sddata_i;
              else
                s_datain[27:24] = sddata_i;
            end
        endcase
      end
      else
      begin
        case(r_byte_in_word)
          0:
          begin
            case(r_bit_cnt)
              0:
                s_datain[7] = sddata_i[0];
              1:
                s_datain[6] = sddata_i[0];
              2:
                s_datain[5] = sddata_i[0];
              3:
                s_datain[4] = sddata_i[0];
              4:
                s_datain[3] = sddata_i[0];
              5:
                s_datain[2] = sddata_i[0];
              6:
                s_datain[1] = sddata_i[0];
              7:
                s_datain[0] = sddata_i[0];
            endcase // r_bit_cnt
          end
          1:
          begin
            case(r_bit_cnt)
              0:
                s_datain[15] = sddata_i[0];
              1:
                s_datain[14] = sddata_i[0];
              2:
                s_datain[13] = sddata_i[0];
              3:
                s_datain[12] = sddata_i[0];
              4:
                s_datain[11] = sddata_i[0];
              5:
                s_datain[10] = sddata_i[0];
              6:
                s_datain[9 ] = sddata_i[0];
              7:
                s_datain[8 ] = sddata_i[0];
            endcase // r_bit_cnt
          end
          2:
          begin
            case(r_bit_cnt)
              0:
                s_datain[23] = sddata_i[0];
              1:
                s_datain[22] = sddata_i[0];
              2:
                s_datain[21] = sddata_i[0];
              3:
                s_datain[20] = sddata_i[0];
              4:
                s_datain[19] = sddata_i[0];
              5:
                s_datain[18] = sddata_i[0];
              6:
                s_datain[17] = sddata_i[0];
              7:
                s_datain[16] = sddata_i[0];
            endcase // r_bit_cnt
          end
          3:
          begin
            case(r_bit_cnt)
              0:
                s_datain[31] = sddata_i[0];
              1:
                s_datain[30] = sddata_i[0];
              2:
                s_datain[29] = sddata_i[0];
              3:
                s_datain[28] = sddata_i[0];
              4:
                s_datain[27] = sddata_i[0];
              5:
                s_datain[26] = sddata_i[0];
              6:
                s_datain[25] = sddata_i[0];
              7:
                s_datain[24] = sddata_i[0];
            endcase // r_bit_cnt
          end
        endcase
      end
    end

    always_comb begin : proc_data_out
      s_dataout = 4'b0;
      if(data_quad_i)
      begin
        case(r_byte_in_word)
          0:
            s_dataout = (r_bit_cnt == 0) ?   r_data[7:4] :   r_data[3:0];
          1:
            s_dataout = (r_bit_cnt == 0) ? r_data[15:12] :  r_data[11:8];
          2:
            s_dataout = (r_bit_cnt == 0) ? r_data[23:20] : r_data[19:16];
          3:
            s_dataout = (r_bit_cnt == 0) ? r_data[31:28] : r_data[27:24];
        endcase
      end
      else
      begin
        case(r_byte_in_word)
          0:
          begin
            case(r_bit_cnt)
              0:
                s_dataout[0] = r_data[7];
              1:
                s_dataout[0] = r_data[6];
              2:
                s_dataout[0] = r_data[5];
              3:
                s_dataout[0] = r_data[4];
              4:
                s_dataout[0] = r_data[3];
              5:
                s_dataout[0] = r_data[2];
              6:
                s_dataout[0] = r_data[1];
              7:
                s_dataout[0] = r_data[0];
            endcase // r_bit_cnt
          end
          1:
          begin
            case(r_bit_cnt)
              0:
                s_dataout[0] = r_data[15];
              1:
                s_dataout[0] = r_data[14];
              2:
                s_dataout[0] = r_data[13];
              3:
                s_dataout[0] = r_data[12];
              4:
                s_dataout[0] = r_data[11];
              5:
                s_dataout[0] = r_data[10];
              6:
                s_dataout[0] = r_data[9];
              7:
                s_dataout[0] = r_data[8];
            endcase // r_bit_cnt
          end
          2:
          begin
            case(r_bit_cnt)
              0:
                s_dataout[0] = r_data[23];
              1:
                s_dataout[0] = r_data[22];
              2:
                s_dataout[0] = r_data[21];
              3:
                s_dataout[0] = r_data[20];
              4:
                s_dataout[0] = r_data[19];
              5:
                s_dataout[0] = r_data[18];
              6:
                s_dataout[0] = r_data[17];
              7:
                s_dataout[0] = r_data[16];
            endcase // r_bit_cnt
          end
          3:
          begin
            case(r_bit_cnt)
              0:
                s_dataout[0] = r_data[31];
              1:
                s_dataout[0] = r_data[30];
              2:
                s_dataout[0] = r_data[29];
              3:
                s_dataout[0] = r_data[28];
              4:
                s_dataout[0] = r_data[27];
              5:
                s_dataout[0] = r_data[26];
              6:
                s_dataout[0] = r_data[25];
              7:
                s_dataout[0] = r_data[24];
            endcase // r_bit_cnt
          end
        endcase
      end
    end



    always_comb
    begin
      s_sddata        = 4'b0;
      s_sddata_oen    = 1'b1;
      s_state         = r_state;
      s_shift_data    = 1'b0;
      s_crc_shift     = 1'b0;
      s_crc_en        = 1'b1;
      s_crc_clr       = 1'b0;
      s_crc_intx      = 1'b0; //default CRC takes input from sddata out
      s_cnt_start     = 1'b0;
      s_cnt_target    = 9'h0;
      s_cnt_byte      = 1'b0;
      s_status        = 'h0;
      s_status_sample = 1'b0;
      s_busy          = 1'b1;
      s_clk_en        = 1'b1;
      s_rx_en         = 1'b0;
      s_eot           = 1'b0;
      s_cnt_block_upd = 1'b0;
      s_cnt_block     = r_cnt_block;

      s_in_data_ready = 1'b0;
      s_out_data_valid = 1'b0;
      case(r_state)
        ST_IDLE:
        begin
          s_busy = 1'b0;
          s_clk_en = 1'b0;
          if(data_start_i)
          begin
            s_status_sample = 1'b1; // Clear previous status
            s_clk_en = 1'b1;
            s_cnt_block_upd = 1'b1;
            s_cnt_block = data_block_num_i;
            if(data_rwn_i)
              s_state = ST_RX_START;
            else
              s_state = ST_TX_START;
          end
        end
        ST_TX_START:
        begin
          s_sddata     = 4'b0;      //start bit
          s_sddata_oen = 1'b1; // outup enabled
          s_state = ST_TX_SHIFT;
          s_cnt_start = 1'b1;  // starts counting
          s_cnt_byte  = 1'b1;  // counting bytes not cycles
          s_cnt_target = data_block_size_i;// shifts buffer size
          s_in_data_ready = 1'b1;
        end
        ST_TX_SHIFT:
        begin
          s_in_data_ready = s_lastbitofword;
          s_sddata = s_dataout;      // direction controller to SD periph
          s_sddata_oen = 1'b0; // outup enabled
          s_shift_data = 1'b1;
          s_crc_en = 1'b1;     // crc is calculated
          if(s_cnt_done)
          begin
            s_in_data_ready = 1'b0;
            s_state = ST_TX_CRC;
            s_cnt_start  = 1'b1;  // starts counting
            s_cnt_target = 8'd15; // shifts 16bits CRC out/channel
          end
        end
        ST_TX_CRC:
        begin
          s_sddata = s_crc_out;  // outputs CRC
          s_sddata_oen = 1'b0; // outup enabled
          s_crc_shift  = 1'b1; // shifts CRC out
          s_crc_en     = 1'b0; // crc is not calculated but shifted
          if(s_cnt_done)
          begin
            s_state      = ST_TX_END;
          end
        end
        ST_TX_END:
        begin
          s_sddata = 4'hF;  // outputs CRC
          s_sddata_oen = 1'b0; // outup enabled
          s_crc_shift  = 1'b0; // shifts CRC out
          s_crc_en     = 1'b0; // crc is not calculated but shifted
          s_state      = ST_TX_CRCSTAT;
          s_cnt_start  = 1'b1; // starts counting
          s_cnt_target = 8'd7; // waits 8 cycles
        end
        ST_TX_CRCSTAT:
        begin
          s_sddata_oen = 1'b1; // outup disabled 
          if(s_cnt_done)
          begin 
            s_cnt_start  = 1'b1;  // starts counting
            s_cnt_target = 9'h1FF;// waits max 512 cycles          
            s_state = ST_TX_BUSY;
          end
        end
        ST_TX_BUSY:
        begin
          s_sddata_oen = 1'b1; // outup disabled
          if(s_cnt_done) //means timeout
          begin
            s_state = ST_IDLE;
          end
          else
          begin
            if(sddata_i[0])
            begin
              if(s_cnt_block_done)
              begin
                s_eot   = 1'b1;
                s_state = ST_IDLE;
              end
              else
              begin
                s_cnt_block_upd = 1'b1;
                s_cnt_block = r_cnt_block - 1;
                s_state = ST_TX_START;
              end
            end
          end
        end
        ST_RX_START:
        begin
          if(!sddata_i[0])
          begin
            s_cnt_start = 1'b1;  // starts counting
            s_cnt_byte  = 1'b1;  // counting bytes not cycles
            s_cnt_target = data_block_size_i;// shifts buffer size
            s_state = ST_RX_SHIFT;
          end
          else if(s_cnt_done)
          begin
            s_status = r_status | STATUS_RSP_TIMEOUT;
            s_status_sample = 1'b1;
            s_state = ST_IDLE;
          end
        end
        ST_RX_SHIFT:
        begin
          s_rx_en = 1'b1;
          s_out_data_valid = s_lastbitofword;
          s_crc_en = 1'b1;      // crc is calculated
          s_crc_intx = 1'b1;    // crc input is from extern
          if(s_cnt_done)
          begin
              s_state = ST_RX_CRC;
              s_cnt_start = 1'b1;  // starts counting
              s_cnt_target = 8'd15;// shifts 8 bits
          end
        end
        ST_RX_CRC:
        begin
          s_out_data_valid = s_lastbitofword;
          s_crc_en = 1'b1;      // crc is calculated
          s_crc_intx = 1'b1;    // crc input is from extern
          if(s_cnt_done)
          begin
            if(s_cnt_block_done)
            begin
              s_eot   = 1'b1;
              s_state = ST_IDLE;
            end
            else
            begin
              s_cnt_block_upd = 1'b1;
              s_cnt_block = r_cnt_block - 1;
              s_state = ST_RX_START;
            end
          end
        end
        ST_WAIT:
        begin
          if(s_cnt_done)
          begin
            s_eot   = 1'b1;
            s_state = ST_IDLE;
          end
        end
      endcase
    end

    assign s_cnt_done = r_cnt_byte ? ((r_cnt == 0) && s_cnt_byte_evnt) : (r_cnt == 0);

    always_ff @(posedge clk_i or negedge rstn_i) begin : proc_r_cnt
      if(~rstn_i) begin
        r_cnt <= 9'h1FF;
        r_cnt_running <= 0;
        r_cnt_byte    <= 0;
        r_cnt_block   <= 0;
        r_byte_in_word <= 0;
      end else begin
        if(s_cnt_block_upd)
        begin
          r_cnt_block <=  s_cnt_block;
        end

        if(s_cnt_start)
        begin
          r_cnt <= s_cnt_target;
          r_cnt_running <= 1'b1;
          r_byte_in_word <= 0;
          r_cnt_byte <= s_cnt_byte;
        end
        else if(s_cnt_done)
        begin
          r_cnt <= 9'h1FF;
          r_cnt_running <= 1'b0;
          r_cnt_byte    <= 1'b0;
          r_byte_in_word <= 0;
        end
        else if(r_cnt_running && (!r_cnt_byte || s_cnt_byte_evnt))
        begin
          r_cnt <= r_cnt - 1;
          if(r_cnt_byte)
            r_byte_in_word <= r_byte_in_word + 1;
        end
      end
   end

    assign s_lastbitofword = s_cnt_byte_evnt & (r_byte_in_word == 2'b11);
    assign s_cnt_block_done = (r_cnt_block == 0);

    //bit counter used to count the TX/RX bits(each byte)
    //if in quad mode only 0..1 quad bits 
    //if in single count 0..7
    assign s_bit_cnt_target = data_quad_i ? 3'h1 : 3'h7;
    assign s_cnt_byte_evnt  = (r_bit_cnt == s_bit_cnt_target);
    always_ff @(posedge clk_i or negedge rstn_i) begin : proc_r_bit_cnt
      if(~rstn_i) begin
        r_bit_cnt <= 3'h0;
      end else 
      begin
        if(r_cnt_byte)
        begin
          if (s_cnt_byte_evnt)
            r_bit_cnt <= 3'h0;
          else
            r_bit_cnt <= r_bit_cnt + 1;;
        end
      end
    end


    always_ff @(posedge clk_i or negedge rstn_i) 
    begin
      if(~rstn_i) begin
        r_state  <=  ST_IDLE;
        r_status <=  'h0;
        r_data   <=  'h0;
      end else 
      begin
        if(clr_stat_i)
        begin
          r_state  <= ST_IDLE;
          r_status <= 'h0;
          r_data   <=  'h0;
        end
        else
        begin 
          r_state  <= s_state;
          if(s_status_sample)
            r_status <= s_status;
          if(s_in_data_ready)
            r_data <= in_data_if_data_i;
          else if(s_rx_en)
            r_data <= s_datain;
        end
      end
    end

    always_ff @(negedge clk_i or negedge rstn_i) begin : proc_sddata
      if(~rstn_i) begin
        r_sddata     <= 4'h0;
      end else begin
        r_sddata     <= s_sddata;
      end
    end

endmodule

