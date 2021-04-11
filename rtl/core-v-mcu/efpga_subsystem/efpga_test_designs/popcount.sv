
module pop_count (
    input  logic [31:0] input_val_i,
    output logic [ 6:0] pop_count_o
);
  logic [15:0][1:0] cnt_l1;
  logic [ 7:0][2:0] cnt_l2;
  logic [ 3:0][3:0] cnt_l3;
  logic [ 1:0][4:0] cnt_l4;

  genvar l, m, n, p;
  generate
    for (l = 0; l < 16; l++) begin
      assign cnt_l1[l] = {1'b0, input_val_i[2*l]} + {1'b0, input_val_i[2*l+1]};
    end
  endgenerate

  generate
    for (m = 0; m < 8; m++) begin
      assign cnt_l2[m] = {1'b0, cnt_l1[2*m]} + {1'b0, cnt_l1[2*m+1]};
    end
  endgenerate

  generate
    for (n = 0; n < 4; n++) begin
      assign cnt_l3[n] = {1'b0, cnt_l2[2*n]} + {1'b0, cnt_l2[2*n+1]};
    end
  endgenerate

  generate
    for (p = 0; p < 2; p++) begin
      assign cnt_l4[p] = {1'b0, cnt_l3[2*p]} + {1'b0, cnt_l3[2*p+1]};
    end
  endgenerate

  assign pop_count_o = {1'b0, cnt_l4[0]} + {1'b0, cnt_l4[1]};




endmodule : pop_count
