-------------------------------------------------------------------------------
-- Title      : registers
-- Project    : Frequency Locked Loop (FLL) - IIS/DZ
-------------------------------------------------------------------------------
-- File       : FLL_reg.vhd
-- Author     : David Bellasi <bellasi@ee.ethz.ch>
-- Company    : Integrated Systems Laboratory, ETH Zurich
-- Created    : 2016-10-18
-------------------------------------------------------------------------------
-- Description: register wrapper to allow a separate power domain for the regs
--              to be defined
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
-- Date        Version  Author              Description
-- 2016-10-18  3.0      bellasid            ported to tsmc55lp
-- 2017-01-27  3.1      muheim              change it to tech independens
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FLL_reg is
  generic(
    MASK : std_logic_vector(32-1 downto 0);
    DEFAULT : std_logic_vector(32-1 downto 0)
    );
  port(
    Data_DI : in  std_logic_vector(32-1 downto 0);
    Data_DO : out std_logic_vector(32-1 downto 0);
    Ena_SI  : in  std_logic;
    Clk_CI  : in  std_logic;
    Rst_RBI : in  std_logic
    );
end FLL_reg;


architecture rtl of FLL_reg is

signal Reg_DP, Reg_DN : std_logic_vector(32-1 downto 0);

begin

  Reg_DN <= Data_DI;
  Data_DO <= Reg_DP;

  update : process (Clk_CI, Rst_RBI) is
  begin  -- process update_cfg_regs
    if Rst_RBI = '0' then             -- asynchronous reset (active low)
      Reg_DP <= DEFAULT;
    elsif Clk_CI'event and Clk_CI = '1' then  -- rising clock edge
      if Ena_SI = '1' then
        Reg_DP <= Reg_DN and MASK;
      end if;
    end if;
  end process update;

end rtl;

