-------------------------------------------------------------------------------
-- Title      : clock gate
-- Project    : Frequency Locked Loop (FLL) - IIS/DZ
-------------------------------------------------------------------------------
-- File       : FLL_clock_gated.rtl.vhd
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
-- 2017-01-27  1.0      muheim	Created
-- 2017-05-16  1.1      muheim	build the gate with a latche
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity FLL_clock_gated is

  port (
    Clk_CO    : out std_logic;
    Clk_CI    : in  std_logic;
    Enable_SI : in  std_logic);

  signal Enable_SP, Enable_SN : std_logic;

end entity FLL_clock_gated;

architecture rtl of FLL_clock_gated is

begin  -- architecture rtl

  Enable_SN <= Enable_SI;

  p_lat: process (Clk_CI, Enable_SN)
         begin
           if Clk_CI='0' then
             Enable_SP <= Enable_SN;
           end if;
         end process p_lat;

  Clk_CO <= Clk_CI and Enable_SP;

end architecture rtl;

