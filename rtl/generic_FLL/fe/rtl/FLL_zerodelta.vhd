-------------------------------------------------------------------------------
-- Title      : Frequency Locked Loop (FLL): handle DCOENB and zero delta
-- Project    : GAP8
-------------------------------------------------------------------------------
-- File       : FLL_zerodelta.vhd
-- Author     : David Bellasi <bellasi@ee.ethz.ch>
-- Company    : Integrated Systems Laboratory, ETH Zurich
-- Created    : 2016-10-18
-------------------------------------------------------------------------------
-- Description:
--
-- 1) Handle DCOENB signal:
-- DCOENB release must be delayed when RET is de-asserted to make sure that
-- the ring-oscillator is started in a defined state when the power
-- comes back on after a sleep state. The assumption is that the VDD domain is
-- both powered down only after a positive transition on the RET signal and
-- powered up before a negative transition of the RET. If this is NOT the case,
-- the following delay logic must be put in the VDD_AO_gated domain.
--
-- 2) Delay loop closing after RET is deasserted and after switching
-- from stand-alone mode to closed-loop mode. To ensure a smooth transition
-- from stand-alone to closed-loop mode (especially after pre-configuring the
-- integrator register), the delta value of the loop filter must be zeroed for
-- a few ref clock cycles to avoid the transition artifacts produced by the
-- clk_period_quantizer to disturb the settled loop.
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
-- 2016-11-07  3.0      bellasid            created
-- 2017-01-30  3.1      muheim              change it to tech independens
--                                          replace POSTICG_X4B_A9TL by a FLL_clock_gated
-- 2017-06-02  3.1a     muheim              replace the xor statments for the
--                                          RetDelayClkGtEn_S signal with a 'or'
--                                          add after xor bilding OpModeClkGtEn_S
--                                          a 'or' withe the RetDelayClkGtEn_S signal
-- 2017-06-10  3.2      bellasid            fixed issue with parasitic states
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FLL_zerodelta is
  generic(
    DELAY : natural := 2
    );
  port(
    RefClk_CI     : in  std_logic;
    OpMode_SI     : in  std_logic;
    RetEn_SI      : in  std_logic;
    DCOEn_SBO     : out std_logic;
    DelayDelta_SO : out std_logic;
    TestMode_TI   : in  std_logic;
    Rst_RBI       : in  std_logic
    );
end FLL_zerodelta;


architecture rtl of FLL_zerodelta is

  signal RetClkInv_C                    : std_logic;
  signal RetDelayClkGtEn_S              : std_logic;
  signal RetDelayNeg_SN, RetDelayNeg_SP : std_logic_vector(0 downto 0);
  signal RetDelayPos_SN, RetDelayPos_SP : std_logic_vector(DELAY-1 downto 0);
  signal RetDelay_S                     : std_logic_vector(DELAY downto 0);
  --
  signal OpModeClkGtEn_S                : std_logic;
  signal OpModeDelay_SN, OpModeDelay_SP : std_logic_vector(DELAY-1 downto 0);

begin


  -- 1)

  --
  DCOEn_SBO     <= '1' when (Rst_RBI = '0') else '0' when (RetEn_SI = '0' and RetDelayNeg_SP = "0" and TestMode_TI = '0') else '1';

  RetClkInv_C <= (not RefClk_CI) when TestMode_TI = '0' else RefClk_CI;
  --
  RetDelayNeg : process (RetClkInv_C, Rst_RBI)
  begin  -- process RetDelay
    if Rst_RBI = '0' then               -- asynchronous reset (active low)
      RetDelayNeg_SP <= "0";
    elsif RetClkInv_C'event and RetClkInv_C = '1' then  -- rising clock edge
      if RetDelayClkGtEn_S = '1' then
        RetDelayNeg_SP <= RetDelayNeg_SN;
      end if;
    end if;
  end process RetDelayNeg;

  -- 2)

  RetDelay_S  <= RetDelayNeg_SP & RetDelayPos_SP;
  RetDelayNeg_SN <= "1" when RetEn_SI='1' else "0";

  RetDelayUpdate : process (RetDelayPos_SP, RetDelay_S, RetEn_SI)
  begin  -- process OpModeDelayUpdate
    RetDelayPos_SN <= RetDelayPos_SP;
    RetDelayClkGtEn_S <= '1';
    if RetEn_SI = '1' then
      if    RetDelay_S = "0000" then RetDelayPos_SN  <= "000";
      elsif RetDelay_S = "1000" then RetDelayPos_SN  <= "100";
      elsif RetDelay_S = "1100" then RetDelayPos_SN  <= "110";
      elsif RetDelay_S = "1111" then RetDelayClkGtEn_S <= '0';
      else                           RetDelayPos_SN  <= "111";
      end if;
    else
      if    RetDelay_S = "1111" then RetDelayPos_SN  <= "111";
      elsif RetDelay_S = "0111" then RetDelayPos_SN  <= "011";
      elsif RetDelay_S = "0011" then RetDelayPos_SN  <= "001";
      elsif RetDelay_S = "0000" then RetDelayClkGtEn_S <= '0';
      else                           RetDelayPos_SN  <= "000";
      end if;
    end if;
  end process RetDelayUpdate;

  RetDelayPos : process (RefClk_CI, Rst_RBI)
  begin  -- process RetDelay
    if Rst_RBI = '0' then               -- asynchronous reset (active low)
      RetDelayPos_SP <= (others => '0');
    elsif RefClk_CI'event and RefClk_CI = '1' then  -- rising clock edge
      if RetDelayClkGtEn_S = '1' then
        RetDelayPos_SP <= RetDelayPos_SN;
      end if;
    end if;
  end process RetDelayPos;

  DelayDelta_SO <= '1' when ((OpModeDelay_SP(0) = '0') or (RetDelayPos_SP(0) = '1')) else '0';

  OpModeDelayUpdate : process (OpModeDelay_SP, OpMode_SI)
  begin  -- process OpModeDelayUpdate
    OpModeDelay_SN <= OpModeDelay_SP;
    OpModeClkGtEn_S <= '1';
    if OpMode_SI = '1' then
      if    OpModeDelay_SP = "000" then OpModeDelay_SN <= "100";
      elsif OpModeDelay_SP = "100" then OpModeDelay_SN <= "110";
      elsif OpModeDelay_SP = "111" then OpModeClkGtEn_S  <= '0';
      else                              OpModeDelay_SN <= "111";
      end if;
    else
      if    OpModeDelay_SP = "111" then OpModeDelay_SN <= "011";
      elsif OpModeDelay_SP = "011" then OpModeDelay_SN <= "001";
      elsif OpModeDelay_SP = "000" then OpModeClkGtEn_S  <= '0';
      else                              OpModeDelay_SN <= "000";
      end if;
    end if;
  end process OpModeDelayUpdate;

  OpModeDelay : process (RefClk_CI, Rst_RBI)
  begin  -- process OpModeDelay
    if Rst_RBI = '0' then               -- asynchronous reset (active low)
      OpModeDelay_SP <= (others => '0');
    elsif RefClk_CI'event and RefClk_CI = '1' then  -- rising clock edge
      if OpModeClkGtEn_S = '1' then
        OpModeDelay_SP <= OpModeDelay_SN;
      end if;
    end if;
  end process OpModeDelay;

end rtl;

