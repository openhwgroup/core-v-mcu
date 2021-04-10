-------------------------------------------------------------------------------
-- Title      : divide-by-2 with glitchfree select
-- Project    : Frequency Locked Loop (FLL) - IIS/DZ
-------------------------------------------------------------------------------
-- File       : FLL_glitchfree_clkdiv.vhd
-- Author     : David Bellasi <bellasi@ee.ethz.ch>
-- Company    : Integrated Systems Laboratory, ETH Zurich
-- Created    : 2016-10-18
-------------------------------------------------------------------------------
-- Description: asynchronous clock divider with glitchfree select.
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
-- 2016-10-18  3.0      bellasid            ported to tsmc55lp
-- 2017-01-30  3.1      muheim              change it to tech independens
--                                          try without the inverter (INV_X4B_A9TL) to the ClkA_C(1),
-- 2017-07-11  3.1a     bellasid/muheim     fix slow to fast clock switch issue
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FLLPkg.all;


entity FLL_glitchfree_clkdiv is
  generic (
    WIDTH : natural := 7
    );
  port(
    Clk_CI     : in  std_logic;
    Rst_RBI    : in  std_logic;
    ClkDiv2_CO : out std_logic;
    ClkOut_CO  : out std_logic;
    Select_SI  : in  std_logic_vector(log2ceil(WIDTH+1)-1 downto 0)
    );
end FLL_glitchfree_clkdiv;

architecture rtl of FLL_glitchfree_clkdiv is

  component FLL_clock_gated
    port (
      Clk_CO    : out std_logic;
      Clk_CI    : in  std_logic;
      Enable_SI : in  std_logic);
  end component;

  ----------------------------------------------------------------------
  signal GateEn_S           : unsigned(WIDTH-1 downto 0);
  signal SelA_SP, SelA_SN   : std_logic_vector(WIDTH-1 downto 0);
  signal SelAA_SP, SelAA_SN : std_logic_vector(WIDTH-1 downto 0);
  signal SelAAInv_S         : std_logic_vector(WIDTH-1 downto 0);
  signal SelB_SP, SelB_SN   : std_logic_vector(WIDTH-1 downto 0);
  signal SelBB_SP, SelBB_SN : std_logic_vector(WIDTH-1 downto 0);
  signal ClkBEn_S           : std_logic_vector(WIDTH-1 downto 0);
  --
  signal ClkA_C              : std_logic_vector(WIDTH downto 0);
  signal ClkAout_C           : std_logic_vector(WIDTH-1 downto 0);
  signal ClkAGt_C            : std_logic_vector(WIDTH-1 downto 0);
  signal ClkB_C              : std_logic_vector(WIDTH-1 downto 0);
  signal ClkBout_C           : std_logic_vector(WIDTH-1 downto 0);

begin


--
-- Bit mask for the clock gates
--
  bin2term : process (Select_SI)
  begin  -- process bin2term
    --
    GateEn_S <= (others => '0');
    --
    for K in 0 to WIDTH loop
      if (unsigned(Select_SI) = to_unsigned(K, Select_SI'length)) then
        GateEn_S <= to_unsigned(2**K-1, GateEn_S'length);
      end if;
    end loop;  -- K
    --
  end process bin2term;


--
-- glitch-free clock divider
--

  ClkA_C(0) <= Clk_CI;

  dividers : for K in 0 to WIDTH-1 generate

-------------------------------------------------------------------------------

    i_clkBEn : FLL_clock_gated
      port map (
        Clk_CO    => ClkAGt_C(K),
        Clk_CI    => ClkA_C(K),
        Enable_SI => ClkBEn_S(K));

    clk_div : process (ClkAGt_C, Rst_RBI)
    begin  -- process clk_div
      if Rst_RBI = '0' then             -- asynchronous reset (active low)
        ClkB_C(K) <= '0';
      elsif ClkAGt_C(K)'event and ClkAGt_C(K) = '1' then  -- rising clock edge
        ClkB_C(K) <= not ClkB_C(K);
      end if;
    end process clk_div;

-------------------------------------------------------------------------------

    SelA_SN(K)    <= SelBB_SP(K) or GateEn_S(K);
    SelAA_SN(K)   <= SelA_SP(K);
    SelAAInv_S(K) <= not SelAA_SP(K);
    SelB_SN(K)    <= GateEn_S(K);
    SelBB_SN(K)   <= SelB_SP(K);
    ClkBEn_S(K)   <= SelAA_SP(K);

-------------------------------------------------------------------------------

    clkA : process (ClkA_C, Rst_RBI)
    begin  -- process clkA
      if Rst_RBI = '0' then             -- asynchronous reset (active low)
        SelA_SP(K) <= '1';
        SelAA_SP(K) <= '1';
      elsif ClkA_C(K)'event and ClkA_C(K) = '1' then  -- rising clock edge
        SelA_SP(K) <= SelA_SN(K);
        SelAA_SP(K) <= SelAA_SN(K);
      end if;
    end process clkA;

    i_clkgateA : FLL_clock_gated
      port map (
        Clk_CO    => ClkAout_C(K),
        Clk_CI    => ClkA_C(K),
        Enable_SI => SelAAInv_S(K));

-------------------------------------------------------------------------------

    clkB : process (ClkB_C, Rst_RBI)
    begin  -- process clkB
      if Rst_RBI = '0' then             -- asynchronous reset (active low)
        SelB_SP(K) <= '1';
        SelBB_SP(K) <= '1';
      elsif ClkB_C(K)'event and ClkB_C(K) = '0' then  -- falling clock edge
        SelB_SP(K) <= SelB_SN(K);
        SelBB_SP(K) <= SelBB_SN(K);
      end if;
    end process clkB;

    i_clkgateB : FLL_clock_gated
      port map (
        Clk_CO    => ClkBout_C(K),
        Clk_CI    => ClkB_C(K),
        Enable_SI => SelBB_SP(K));

-------------------------------------------------------------------------------

    ClkA_C(K+1) <= ClkAout_C(K) or ClkBout_C(K);

  end generate dividers;

  ClkOut_CO  <= ClkA_C(WIDTH);
  ClkDiv2_CO <= ClkA_C(1);

end rtl;
