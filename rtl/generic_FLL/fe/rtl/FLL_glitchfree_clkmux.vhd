-------------------------------------------------------------------------------
-- Title      : glitchfree clk select
-- Project    : Frequency Locked Loop (FLL) - IIS/DZ
-------------------------------------------------------------------------------
-- File       : FLL_glitchfree_clkmux.vhd
-- Author     : David Bellasi <bellasi@ee.ethz.ch>
-- Company    : Integrated Systems Laboratory, ETH Zurich
-- Created    : 2016-10-18
-------------------------------------------------------------------------------
-- Description: Glitchfree clock select.
--
--              NOTE: after reset clock 0 is selected by default. It takes a
--                    couple of cycles until the select signal becomes effective.
--
--              TRUTH TABLE:
--
--              Select_SI   TestMode_TI  =>   ClkOut_CO
--              ---------------------------------------------------------
--                  0              0          ClkIn0_CI
--                  1              0          ClkIn1_CI
--                  x              1          ClkIn1_CI
--
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
-- 2016-11-04  3.0      bellasid            created
-- 2017-01-30  3.1      muheim              change it to tech independens
--                                          replace POSTICG_X4B_A9TL by a FLL_clock_gated
-- 2017-07-03  3.1a     bellasid            fix slow to fast clock switch issue

-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FLL_glitchfree_clkmux is
  port(
    ClkIn0_CI   : in  std_logic;
    ClkIn1_CI   : in  std_logic;
    Select_SI   : in  std_logic;
    ClkOut_CO   : out std_logic;
    Rst_RBI     : in  std_logic
    );
end FLL_glitchfree_clkmux;

architecture rtl of FLL_glitchfree_clkmux is

  component FLL_clock_gated
    port (
      Clk_CO    : out std_logic;
      Clk_CI    : in  std_logic;
      Enable_SI : in  std_logic);
  end component;

  signal SelA_SP, SelA_SN   : std_logic;
  signal SelAA_SP, SelAA_SN : std_logic;
  signal SelB_SP, SelB_SN   : std_logic;
  signal SelBB_SP, SelBB_SN : std_logic;
  --
  signal ClkA_C             : std_logic;
  signal ClkAout_C          : std_logic;
  signal ClkB_C             : std_logic;
  signal ClkBout_C          : std_logic;

begin

  ClkA_C <= ClkIn0_CI;
  ClkB_C <= ClkIn1_CI;

-------------------------------------------------------------------------------

  SelA_SN    <= SelBB_SP nor Select_SI;
  SelAA_SN   <= SelA_SP;
  --
  SelB_SN    <= Select_SI and (not SelAA_SP);
  SelBB_SN   <= SelB_SP;

-------------------------------------------------------------------------------

  clkA : process (ClkA_C, Rst_RBI)
  begin  -- process clkA
    if Rst_RBI = '0' then               -- asynchronous reset (active low)
      SelA_SP  <= '0';
      SelAA_SP <= '0';
    elsif ClkA_C'event and ClkA_C = '1' then  -- rising clock edge
      SelA_SP  <= SelA_SN;
      SelAA_SP <= SelAA_SN;
    end if;
  end process clkA;

  i_clkgateA : FLL_clock_gated
    port map (
      Clk_CO    => ClkAout_C,
      Clk_CI    => ClkA_C,
      Enable_SI => SelAA_SP);

-------------------------------------------------------------------------------

  clkB : process (ClkB_C, Rst_RBI)
  begin  -- process clkB
    if Rst_RBI = '0' then               -- asynchronous reset (active low)
      SelB_SP  <= '0';
      SelBB_SP <= '0';
    elsif ClkB_C'event and ClkB_C = '0' then  -- falling clock edge
      SelB_SP  <= SelB_SN;
      SelBB_SP <= SelBB_SN;
    end if;
  end process clkB;

  i_clkgateB : FLL_clock_gated
    port map (
      Clk_CO    => ClkBout_C,
      Clk_CI    => ClkB_C,
      Enable_SI => SelBB_SP);

-------------------------------------------------------------------------------

  ClkOut_CO <= ClkAout_C or ClkBout_C;

end rtl;
