// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module AddressDecoder_Resp_L2
#(
   parameter N_MASTER      = 8,
   parameter ID_WIDTH      = N_MASTER
)
(
   // FROM Test And Set Interface
   input  logic                            data_r_valid_i,
   input  logic [ID_WIDTH-1:0]             data_r_ID_i,
   // To Response Network
   output logic [N_MASTER-1:0]             data_r_valid_o
);

   assign data_r_valid_o = {ID_WIDTH{data_r_valid_i}} & data_r_ID_i;

endmodule
