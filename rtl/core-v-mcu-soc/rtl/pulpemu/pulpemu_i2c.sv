// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module pulpemu_i2c (
    // mode
    input  logic mode_fmc_zynqn_i,
    // I2C port (from/to PULP)
    output logic pulp_i2c_scl_i,
    input  logic pulp_i2c_scl_o,
    input  logic pulp_i2c_scl_oe,
    output logic pulp_i2c_sda_i,
    input  logic pulp_i2c_sda_o,
    input  logic pulp_i2c_sda_oe,
    // I2C port (from/to pads)
    inout  wire  fmc_i2c_scl,
    inout  wire  fmc_i2c_sda
);

  // biasing
  IOBUF iobuf_i2c_scl_i (
      .T (~pulp_i2c_scl_oe),
      .I (pulp_i2c_scl_o),
      .O (pulp_i2c_scl_i),
      .IO(fmc_i2c_scl)
  );
  IOBUF iobuf_i2c_sda_i (
      .T (~pulp_i2c_sda_oe),
      .I (pulp_i2c_sda_o),
      .O (pulp_i2c_sda_i),
      .IO(fmc_i2c_sda)
  );

endmodule  // pulpemu_spi_slave
