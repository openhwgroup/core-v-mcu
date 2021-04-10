-------------------------------------------------------------------------------
-- Title      : clock divider
-- Project    : Frequency Locked Loop (FLL) - IIS/DZ
-------------------------------------------------------------------------------
-- File       : FLL_clk_divider.vhd
-- Author     : David Bellasi <bellasi@ee.ethz.ch>
-- Company    : Integrated Systems Laboratory, ETH Zurich
-- Created    : 2016-10-18
-------------------------------------------------------------------------------
-- Description: An asynchronous pre-divider (selectable up to 1/4) brings
--              the input frequency to a save rate to be used by an synchronous
--              divider. ClkOut1 is either Clk_CI or Clk_CI/2 for Select_SI = 0
--              and Select_SI > 0, respectively.
--              The ClkOut1 is intended to provide the clock for the loop
--              feedback.
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
--                                          replace POSTICG_X4B_A9TL by a FLL_clock_gated
--                                          remve component declaratishen for OR2_X4M_A9TL
-- 2017-07-11  3.1a     bellasid/muheim     fix slow to fast clock switch issue
--                                          fix clk 1/256
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FLLPkg.all;

entity FLL_clk_divider is
  generic(
    WIDTH : natural := 7
    );
  port(
    Clk_CI     : in  std_logic;
    Rst_RBI    : in  std_logic;
    ClkOut0_CO : out std_logic;
    ClkOut1_CO : out std_logic;
    Select_SI  : in  std_logic_vector(log2ceil(WIDTH+1)-1 downto 0)
    );
end FLL_clk_divider;

architecture rtl of FLL_clk_divider is

  ----------------------------------------------------------------------
  -- purpose : computes ceil(log2(n)) to get "bit width"
  function log2ceil (n : natural) return natural is
  begin  -- log2ceil
    if n = 0 then
      return 0;
    end if;
    for index in 1 to 32 loop
      if (2**index >= n) then
        return index;
      end if;
    end loop;  -- n
  end log2ceil;


  ----------------------------------------------------------------------
  component FLL_clock_gated
    port (
      Clk_CO    : out std_logic;
      Clk_CI    : in  std_logic;
      Enable_SI : in  std_logic);
  end component;

  component FLL_glitchfree_clkdiv
    generic (
      WIDTH : natural);
    port (
      Clk_CI     : in  std_logic;
      Rst_RBI    : in  std_logic;
      ClkDiv2_CO : out std_logic;
      ClkOut_CO  : out std_logic;
      Select_SI  : in  std_logic_vector(log2ceil(WIDTH+1)-1 downto 0));
  end component;

  ----------------------------------------------------------------------
  constant SYNCCNTWIDTH : natural := WIDTH-2;
  signal ClkDivSyncCnt_C : unsigned(SYNCCNTWIDTH-1 downto 0);

  --
  signal PreDivSelect_S     : std_logic_vector(1 downto 0);
  signal OutSel_S           : std_logic;
  --
  signal SelA_SP, SelA_SN   : std_logic;
  signal SelAA_SP, SelAA_SN : std_logic;
  signal SelAAInv_S         : std_logic;
  signal SelB_SP, SelB_SN   : std_logic;
  signal SelBB_SP, SelBB_SN : std_logic;
  signal ClkBEn_S           : std_logic;
  --
  signal ClkA_C             : std_logic;
  signal ClkAout_C          : std_logic;
  signal ClkAGt_C           : std_logic;
  signal ClkAGtInv_C        : std_logic;
  signal ClkAGtSelect_C     : std_logic;
  signal ClkB_C             : std_logic;
  signal ClkBout_C          : std_logic;
  --
  signal SelectSyncEn_S               : std_logic;
  signal SelectSync_S                 : unsigned(log2ceil(WIDTH+1)-1 downto 0);
  signal SelectSync_SP, SelectSync_SN : unsigned(log2ceil(SYNCCNTWIDTH+1)-1 downto 0);


begin

  --
  -- Select Signal Map
  --

  select_map: process (Select_SI)
  begin  -- process select_map
     if unsigned(Select_SI) < 3 then
        OutSel_S <= '0';
        PreDivSelect_S <= Select_SI(1 downto 0);
        SelectSync_S <= (others => '0');
     else
        OutSel_S <= '1';
        PreDivSelect_S <= "10";
        SelectSync_S <= unsigned(Select_SI)-3;
     end if;
  end process select_map;



  -----------------------------------------------------------------------------
  -- Clk A
  -----------------------------------------------------------------------------

  --
  -- asynchronous pre-divider (up to divide-by-4) with glitch-free select
  --

  i_glitchfree_clkdiv: FLL_glitchfree_clkdiv
    generic map (
      WIDTH => 2)
    port map (
      Clk_CI     => Clk_CI,
      Rst_RBI    => Rst_RBI,
      ClkDiv2_CO => ClkOut1_CO,
      ClkOut_CO  => ClkA_C,
      Select_SI  => PreDivSelect_S);

  -----------------------------------------------------------------------------
  -- Clk B
  -----------------------------------------------------------------------------

  --
  -- synchronous divider
  --

  i_clkBEn : FLL_clock_gated
    port map (
      Clk_CO    => ClkAGt_C,
      Clk_CI    => ClkA_C,
      Enable_SI => ClkBEn_S);

    synchronous_clk_div : process (ClkAGt_C, Rst_RBI)
    begin  -- process clk_div
      if Rst_RBI = '0' then             -- asynchronous reset (active low)
        ClkDivSyncCnt_C <= (others => '0');
      elsif ClkAGt_C'event and ClkAGt_C = '1' then  -- rising clock edge
        ClkDivSyncCnt_C <= ClkDivSyncCnt_C + 1;
      end if;
    end process synchronous_clk_div;

  --
  -- glitch-free synchronous clock phase select
  --

  ClkB_C <= ClkDivSyncCnt_C(to_integer(SelectSync_SP));

  SelectSync_SN <= SelectSync_S(SelectSync_SP'length-1 downto 0);

  SelectSyncEn_S <= '1' when ClkDivSyncCnt_C = to_unsigned(0,ClkDivSyncCnt_C'length) else '0';

  ClkAGtInv_C <=  not ClkAGt_C;

   i_clkAgategate : FLL_clock_gated
    port map (
      Clk_CO    => ClkAGtSelect_C,
      Clk_CI    => ClkAGtInv_C,
      Enable_SI => SelectSyncEn_S);


  select_sync: process (ClkAGtSelect_C, Rst_RBI)
  begin  -- process select_sync
    if Rst_RBI = '0' then               -- asynchronous reset (active low)
      SelectSync_SP <= (others => '0');
    elsif ClkAGtSelect_C'event and ClkAGtSelect_C = '1' then  -- rising clock edge
      SelectSync_SP <= SelectSync_SN;
    end if;
  end process select_sync;

  -----------------------------------------------------------------------------
  -- Glitch-free select between clock A and clock B
  -----------------------------------------------------------------------------

    SelA_SN    <= SelBB_SP or OutSel_S;
    SelAA_SN   <= SelA_SP;
    SelAAInv_S <= not SelAA_SP;
    SelB_SN    <= OutSel_S;
    SelBB_SN   <= SelB_SP;
    ClkBEn_S   <= SelAA_SP;

  --

    clkA : process (ClkA_C, Rst_RBI)
    begin  -- process clkA
      if Rst_RBI = '0' then             -- asynchronous reset (active low)
        SelA_SP <= '0';
        SelAA_SP <= '0';
      elsif ClkA_C'event and ClkA_C = '1' then  -- rising clock edge
        SelA_SP <= SelA_SN;
        SelAA_SP <= SelAA_SN;
      end if;
    end process clkA;

   i_clkgateA : FLL_clock_gated
    port map (
      Clk_CO    => ClkAout_C,
      Clk_CI    => ClkA_C,
      Enable_SI => SelAAInv_S);

  --

    clkB : process (ClkB_C, Rst_RBI)
    begin  -- process clkB
      if Rst_RBI = '0' then             -- asynchronous reset (active low)
        SelB_SP <= '0';
        SelBB_SP <= '0';
      elsif ClkB_C'event and ClkB_C = '0' then  -- falling clock edge
        SelB_SP <= SelB_SN;
        SelBB_SP <= SelBB_SN;
      end if;
    end process clkB;

   i_clkgateB : FLL_clock_gated
    port map (
      Clk_CO    => ClkBout_C,
      Clk_CI    => ClkB_C,
      Enable_SI => SelBB_SP);

  --
  -- glitch-free clock output
  --

  ClkOut0_CO <= ClkAout_C or ClkBout_C;

end rtl;
