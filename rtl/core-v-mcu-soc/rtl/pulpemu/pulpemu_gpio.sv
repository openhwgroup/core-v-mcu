// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module pulpemu_gpio (
    // mode
    input  logic        mode_fmc_zynqn_i,
    // GPIO (from/to PULP)
    input  logic [31:0] pulp_gpio_out,
    output logic [31:0] pulp_gpio_in,
    input  logic [31:0] pulp_gpio_dir,
    // GPIO (from/to pads)
    inout  wire         fmc_gpio0,
    inout  wire         fmc_gpio1,
    inout  wire         fmc_gpio2,
    inout  wire         fmc_gpio3,
    inout  wire         fmc_gpio4,
    inout  wire         fmc_gpio5,
    inout  wire         fmc_gpio6,
    inout  wire         fmc_gpio7
);

  IOBUF iobuf_fmc_gpio0_i (
      .T (~pulp_gpio_dir[0]),
      .I (pulp_gpio_out[0]),
      .O (pulp_gpio_in[0]),
      .IO(fmc_gpio0)
  );
  IOBUF iobuf_fmc_gpio1_i (
      .T (~pulp_gpio_dir[1]),
      .I (pulp_gpio_out[1]),
      .O (pulp_gpio_in[1]),
      .IO(fmc_gpio1)
  );
  IOBUF iobuf_fmc_gpio2_i (
      .T (~pulp_gpio_dir[2]),
      .I (pulp_gpio_out[2]),
      .O (pulp_gpio_in[2]),
      .IO(fmc_gpio2)
  );
  IOBUF iobuf_fmc_gpio3_i (
      .T (~pulp_gpio_dir[3]),
      .I (pulp_gpio_out[3]),
      .O (pulp_gpio_in[3]),
      .IO(fmc_gpio3)
  );
  IOBUF iobuf_fmc_gpio4_i (
      .T (~pulp_gpio_dir[4]),
      .I (pulp_gpio_out[4]),
      .O (pulp_gpio_in[4]),
      .IO(fmc_gpio4)
  );
  IOBUF iobuf_fmc_gpio5_i (
      .T (~pulp_gpio_dir[5]),
      .I (pulp_gpio_out[5]),
      .O (pulp_gpio_in[5]),
      .IO(fmc_gpio5)
  );
  IOBUF iobuf_fmc_gpio6_i (
      .T (~pulp_gpio_dir[6]),
      .I (pulp_gpio_out[6]),
      .O (pulp_gpio_in[6]),
      .IO(fmc_gpio6)
  );
  IOBUF iobuf_fmc_gpio7_i (
      .T (~pulp_gpio_dir[7]),
      .I (pulp_gpio_out[7]),
      .O (pulp_gpio_in[7]),
      .IO(fmc_gpio7)
  );

endmodule  // pulpemu_spi_slave
