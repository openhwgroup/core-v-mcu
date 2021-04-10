-------------------------------------------------------------------------------
-- Title      : mux
-- Project    : Frequency Locked Loop (FLL) - IIS/DZ
-------------------------------------------------------------------------------
-- File       : FLL_mux.rtl.vhd
-- Author     : Beat Muheim  <muheim@rophaien.ee.ethz.ch>
-- Company    : Integrated Systems Laboratory, ETH Zurich
-- Created    : 2017-01-27
-- Last update: 2017-01-27
-- Platform   : ModelSim (simulation), Synopsys (synthesis)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright 2018 ETH Zurich and University of Bologna.
-- Copyright and related rights are licensed under the Solderpad Hardware
-- License, Version 0.51 (the "License"); you may not use this file except in
-- compliance with the License.  You may obtain a copy of the License at
-- http:--solderpad.org/licenses/SHL-0.51. Unless required by applicable law
-- or agreed to in writing, software, hardware and materials distributed under
-- this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
-- CONDITIONS OF ANY KIND, either express or implied. See the License for the
-- specific language governing permissions and limitations under the License.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2017-06-09  1.1      muheim	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity FLL_mux is

  port (
    Z_SO    : out std_logic;
    A_SI    : in  std_logic;
    B_SI    : in  std_logic;
    Sel_SI  : in  std_logic);

end entity FLL_mux;

architecture rtl of FLL_mux is

begin  -- architecture rtl

  Z_SO <= B_SI when (Sel_SI = '1')  else A_SI;

end architecture rtl;

