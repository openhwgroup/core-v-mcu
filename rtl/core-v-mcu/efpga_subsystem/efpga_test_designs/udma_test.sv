module udma_test (
    input logic clk_i,
    input logic rst_ni,

    output logic udma_cfg_data_0_o,
    output logic udma_cfg_data_1_o,
    output logic udma_cfg_data_2_o,
    output logic udma_cfg_data_3_o,
    output logic udma_cfg_data_4_o,
    output logic udma_cfg_data_5_o,
    output logic udma_cfg_data_6_o,
    output logic udma_cfg_data_7_o,
    output logic udma_cfg_data_8_o,
    output logic udma_cfg_data_9_o,
    output logic udma_cfg_data_10_o,
    output logic udma_cfg_data_11_o,
    output logic udma_cfg_data_12_o,
    output logic udma_cfg_data_13_o,
    output logic udma_cfg_data_14_o,
    output logic udma_cfg_data_15_o,
    output logic udma_cfg_data_16_o,
    output logic udma_cfg_data_17_o,
    output logic udma_cfg_data_18_o,
    output logic udma_cfg_data_19_o,
    output logic udma_cfg_data_20_o,
    output logic udma_cfg_data_21_o,
    output logic udma_cfg_data_22_o,
    output logic udma_cfg_data_23_o,
    output logic udma_cfg_data_24_o,
    output logic udma_cfg_data_25_o,
    output logic udma_cfg_data_26_o,
    output logic udma_cfg_data_27_o,
    output logic udma_cfg_data_28_o,
    output logic udma_cfg_data_29_o,
    output logic udma_cfg_data_30_o,
    output logic udma_cfg_data_31_o,

    input logic udma_cfg_data_0_i,
    input logic udma_cfg_data_1_i,
    input logic udma_cfg_data_2_i,
    input logic udma_cfg_data_3_i,
    input logic udma_cfg_data_4_i,
    input logic udma_cfg_data_5_i,
    input logic udma_cfg_data_6_i,
    input logic udma_cfg_data_7_i,
    input logic udma_cfg_data_8_i,
    input logic udma_cfg_data_9_i,
    input logic udma_cfg_data_10_i,
    input logic udma_cfg_data_11_i,
    input logic udma_cfg_data_12_i,
    input logic udma_cfg_data_13_i,
    input logic udma_cfg_data_14_i,
    input logic udma_cfg_data_15_i,
    input logic udma_cfg_data_16_i,
    input logic udma_cfg_data_17_i,
    input logic udma_cfg_data_18_i,
    input logic udma_cfg_data_19_i,
    input logic udma_cfg_data_20_i,
    input logic udma_cfg_data_21_i,
    input logic udma_cfg_data_22_i,
    input logic udma_cfg_data_23_i,
    input logic udma_cfg_data_24_i,
    input logic udma_cfg_data_25_i,
    input logic udma_cfg_data_26_i,
    input logic udma_cfg_data_27_i,
    input logic udma_cfg_data_28_i,
    input logic udma_cfg_data_29_i,
    input logic udma_cfg_data_30_i,
    input logic udma_cfg_data_31_i,

    output logic udma_rx_lin_data_0_o,
    output logic udma_rx_lin_data_1_o,
    output logic udma_rx_lin_data_2_o,
    output logic udma_rx_lin_data_3_o,
    output logic udma_rx_lin_data_4_o,
    output logic udma_rx_lin_data_5_o,
    output logic udma_rx_lin_data_6_o,
    output logic udma_rx_lin_data_7_o,
    output logic udma_rx_lin_data_8_o,
    output logic udma_rx_lin_data_9_o,
    output logic udma_rx_lin_data_10_o,
    output logic udma_rx_lin_data_11_o,
    output logic udma_rx_lin_data_12_o,
    output logic udma_rx_lin_data_13_o,
    output logic udma_rx_lin_data_14_o,
    output logic udma_rx_lin_data_15_o,
    output logic udma_rx_lin_data_16_o,
    output logic udma_rx_lin_data_17_o,
    output logic udma_rx_lin_data_18_o,
    output logic udma_rx_lin_data_19_o,
    output logic udma_rx_lin_data_20_o,
    output logic udma_rx_lin_data_21_o,
    output logic udma_rx_lin_data_22_o,
    output logic udma_rx_lin_data_23_o,
    output logic udma_rx_lin_data_24_o,
    output logic udma_rx_lin_data_25_o,
    output logic udma_rx_lin_data_26_o,
    output logic udma_rx_lin_data_27_o,
    output logic udma_rx_lin_data_28_o,
    output logic udma_rx_lin_data_29_o,
    output logic udma_rx_lin_data_30_o,
    output logic udma_rx_lin_data_31_o,

    output logic udma_rx_lin_valid_o,
    input  logic udma_rx_lin_ready_i
);

  enum logic [1:0] {
    IDLE,
    GENERATE_DATA,
    WAIT_CLEAR
  }
      CS, NS;

  logic [31:0] reg_data;
  logic [31:0] reg_data_next;
  logic [15:0] initial_value;

  logic [ 2:0] reg_rx_sync;

  logic [ 7:0] reg_count;
  logic [ 7:0] reg_count_next;

  logic [ 7:0] s_target_word;
  logic        cfg_en;

  logic sampleData, busy;

  assign udma_cfg_data_0_o = busy;

  assign udma_cfg_data_1_o = 1'b0;  //pragma attribute udma_cfg_data_1_o  pad out_buff
  assign udma_cfg_data_2_o = 1'b0;  //pragma attribute udma_cfg_data_2_o  pad out_buff
  assign udma_cfg_data_3_o = 1'b0;  //pragma attribute udma_cfg_data_3_o  pad out_buff
  assign udma_cfg_data_4_o = 1'b0;  //pragma attribute udma_cfg_data_4_o  pad out_buff
  assign udma_cfg_data_5_o = 1'b0;  //pragma attribute udma_cfg_data_5_o  pad out_buff
  assign udma_cfg_data_6_o = 1'b0;  //pragma attribute udma_cfg_data_6_o  pad out_buff
  assign udma_cfg_data_7_o = 1'b0;  //pragma attribute udma_cfg_data_7_o  pad out_buff
  assign udma_cfg_data_8_o = 1'b0;  //pragma attribute udma_cfg_data_8_o  pad out_buff
  assign udma_cfg_data_9_o = 1'b0;  //pragma attribute udma_cfg_data_9_o  pad out_buff
  assign udma_cfg_data_10_o = 1'b0;  //pragma attribute udma_cfg_data_10_o  pad out_buff
  assign udma_cfg_data_11_o = 1'b0;  //pragma attribute udma_cfg_data_11_o  pad out_buff
  assign udma_cfg_data_12_o = 1'b0;  //pragma attribute udma_cfg_data_12_o  pad out_buff
  assign udma_cfg_data_13_o = 1'b0;  //pragma attribute udma_cfg_data_13_o  pad out_buff
  assign udma_cfg_data_14_o = 1'b0;  //pragma attribute udma_cfg_data_14_o  pad out_buff
  assign udma_cfg_data_15_o = 1'b0;  //pragma attribute udma_cfg_data_15_o  pad out_buff
  assign udma_cfg_data_16_o = 1'b0;  //pragma attribute udma_cfg_data_16_o  pad out_buff
  assign udma_cfg_data_17_o = 1'b0;  //pragma attribute udma_cfg_data_17_o  pad out_buff
  assign udma_cfg_data_18_o = 1'b0;  //pragma attribute udma_cfg_data_18_o  pad out_buff
  assign udma_cfg_data_19_o = 1'b0;  //pragma attribute udma_cfg_data_19_o  pad out_buff
  assign udma_cfg_data_20_o = 1'b0;  //pragma attribute udma_cfg_data_20_o  pad out_buff
  assign udma_cfg_data_21_o = 1'b0;  //pragma attribute udma_cfg_data_21_o  pad out_buff
  assign udma_cfg_data_22_o = 1'b0;  //pragma attribute udma_cfg_data_22_o  pad out_buff
  assign udma_cfg_data_23_o = 1'b0;  //pragma attribute udma_cfg_data_23_o  pad out_buff
  assign udma_cfg_data_24_o = 1'b0;  //pragma attribute udma_cfg_data_24_o  pad out_buff
  assign udma_cfg_data_25_o = 1'b0;  //pragma attribute udma_cfg_data_25_o  pad out_buff
  assign udma_cfg_data_26_o = 1'b0;  //pragma attribute udma_cfg_data_26_o  pad out_buff
  assign udma_cfg_data_27_o = 1'b0;  //pragma attribute udma_cfg_data_27_o  pad out_buff
  assign udma_cfg_data_28_o = 1'b0;  //pragma attribute udma_cfg_data_28_o  pad out_buff
  assign udma_cfg_data_29_o = 1'b0;  //pragma attribute udma_cfg_data_29_o  pad out_buff
  assign udma_cfg_data_30_o = 1'b0;  //pragma attribute udma_cfg_data_30_o  pad out_buff
  assign udma_cfg_data_31_o = 1'b0;  //pragma attribute udma_cfg_data_31_o  pad out_buff

  assign busy = (CS == GENERATE_DATA);
  assign cfg_en = udma_cfg_data_0_i;

  assign s_target_word[0] = udma_cfg_data_8_i;
  assign s_target_word[1] = udma_cfg_data_9_i;
  assign s_target_word[2] = udma_cfg_data_10_i;
  assign s_target_word[3] = udma_cfg_data_11_i;
  assign s_target_word[4] = udma_cfg_data_12_i;
  assign s_target_word[5] = udma_cfg_data_13_i;
  assign s_target_word[6] = udma_cfg_data_14_i;
  assign s_target_word[7] = udma_cfg_data_15_i;

  assign initial_value[0] = udma_cfg_data_16_i;
  assign initial_value[1] = udma_cfg_data_17_i;
  assign initial_value[2] = udma_cfg_data_18_i;
  assign initial_value[3] = udma_cfg_data_19_i;
  assign initial_value[4] = udma_cfg_data_20_i;
  assign initial_value[5] = udma_cfg_data_21_i;
  assign initial_value[6] = udma_cfg_data_22_i;
  assign initial_value[7] = udma_cfg_data_23_i;
  assign initial_value[8] = udma_cfg_data_24_i;
  assign initial_value[9] = udma_cfg_data_25_i;
  assign initial_value[10] = udma_cfg_data_26_i;
  assign initial_value[11] = udma_cfg_data_27_i;
  assign initial_value[12] = udma_cfg_data_28_i;
  assign initial_value[13] = udma_cfg_data_29_i;
  assign initial_value[14] = udma_cfg_data_30_i;
  assign initial_value[15] = udma_cfg_data_31_i;

  always_comb begin
    NS                  = CS;
    sampleData          = 1'b0;
    reg_count_next      = reg_count;
    reg_data_next       = reg_data;
    udma_rx_lin_valid_o = 1'b0;

    case (CS)

      IDLE: begin
        if (cfg_en) begin
          NS = GENERATE_DATA;
          reg_data_next = $unsigned(initial_value);
        end
      end

      GENERATE_DATA: begin
        udma_rx_lin_valid_o = 1'b1;
        if (udma_rx_lin_ready_i) begin
          reg_data_next  = reg_data + 1;
          reg_count_next = reg_count + 1;
          if (reg_count == s_target_word - 1) begin
            reg_count_next = '0;
            NS             = WAIT_CLEAR;
          end
        end
      end

      WAIT_CLEAR: begin
        if (~cfg_en) NS = IDLE;
      end

      default: NS = IDLE;
    endcase
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (rst_ni == 1'b0) begin
      CS        <= IDLE;
      reg_data  <= '0;
      reg_count <= '0;
    end else begin
      reg_data  <= reg_data_next;
      reg_count <= reg_count_next;
      CS        <= NS;
    end
  end

  assign udma_rx_lin_data_0_o  = reg_data[0];
  assign udma_rx_lin_data_1_o  = reg_data[1];
  assign udma_rx_lin_data_2_o  = reg_data[2];
  assign udma_rx_lin_data_3_o  = reg_data[3];
  assign udma_rx_lin_data_4_o  = reg_data[4];
  assign udma_rx_lin_data_5_o  = reg_data[5];
  assign udma_rx_lin_data_6_o  = reg_data[6];
  assign udma_rx_lin_data_7_o  = reg_data[7];
  assign udma_rx_lin_data_8_o  = reg_data[8];
  assign udma_rx_lin_data_9_o  = reg_data[9];
  assign udma_rx_lin_data_10_o = reg_data[10];
  assign udma_rx_lin_data_11_o = reg_data[11];
  assign udma_rx_lin_data_12_o = reg_data[12];
  assign udma_rx_lin_data_13_o = reg_data[13];
  assign udma_rx_lin_data_14_o = reg_data[14];
  assign udma_rx_lin_data_15_o = reg_data[15];
  assign udma_rx_lin_data_16_o = reg_data[16];
  assign udma_rx_lin_data_17_o = reg_data[17];
  assign udma_rx_lin_data_18_o = reg_data[18];
  assign udma_rx_lin_data_19_o = reg_data[19];
  assign udma_rx_lin_data_20_o = reg_data[20];
  assign udma_rx_lin_data_21_o = reg_data[21];
  assign udma_rx_lin_data_22_o = reg_data[22];
  assign udma_rx_lin_data_23_o = reg_data[23];
  assign udma_rx_lin_data_24_o = reg_data[24];
  assign udma_rx_lin_data_25_o = reg_data[25];
  assign udma_rx_lin_data_26_o = reg_data[26];
  assign udma_rx_lin_data_27_o = reg_data[27];
  assign udma_rx_lin_data_28_o = reg_data[28];
  assign udma_rx_lin_data_29_o = reg_data[29];
  assign udma_rx_lin_data_30_o = reg_data[30];
  assign udma_rx_lin_data_31_o = reg_data[31];

endmodule
