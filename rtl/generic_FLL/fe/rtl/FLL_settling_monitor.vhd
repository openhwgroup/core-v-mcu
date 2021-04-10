-------------------------------------------------------------------------------
-- Title      : frequency monitor
-- Project    : Frequency Locked Loop (FLL) - IIS/DZ
-------------------------------------------------------------------------------
-- File       : FLL_digital.vhd
-- Author     : David Bellasi <bellasi@ee.ethz.ch>
-- Company    : Integrated Systems Laboratory, ETH Zurich
-- Created    : 2016-10-18
-------------------------------------------------------------------------------
-- Description: monitors the settling behavior, generates the LOCK signal
--              (that is intended to be used as reset signal for the circuit
--              clocked by the FLL clock) in both the normal and the
--              stand-alone mode of the FLL.
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

entity FLL_settling_monitor is
  generic (
    CLK_PERIOD_QUANTIZER_WIDTH : natural := 16;
    LOCKTOLERANCE_WIDTH        : natural := 16;
    STABLE_CYCLE_WIDTH         : natural := 8;
    UNSTABLE_CYCLE_WIDTH       : natural := 8
    );
  port(
    -- configuration values
    LockTolerance_DI  : in  std_logic_vector(LOCKTOLERANCE_WIDTH-1 downto 0);
    StableCycles_DI   : in  std_logic_vector(STABLE_CYCLE_WIDTH-1 downto 0);
    UnstableCycles_DI : in  std_logic_vector(UNSTABLE_CYCLE_WIDTH-1 downto 0);
    --
    -- from filter_and_control bLock_SO
    Aberration_DI     : in  std_logic_vector(CLK_PERIOD_QUANTIZER_WIDTH downto 0);
    --
    -- status
    Lock_SO           : out std_logic;
    LockReset_SI      : in  std_logic;
    --
    -- configuration signals
    OpMode_SI         : in  std_logic;
    --
    -- General signals
    RefClk_CI         : in  std_logic;
    DCOClk_CI         : in  std_logic;
    Rst_RBI           : in  std_logic
    );
end FLL_settling_monitor;


architecture rtl of FLL_settling_monitor is

  ----------------------------------------------------------------------
  -- Signal declarations     -------------------------------------------
  ----------------------------------------------------------------------

  -- Aberration_DI holds the difference between target mult_factorization and
  --
  signal CurrentLock_DP, CurrentLock_DN           : std_logic;
  signal StableCycleCnt_DP, StableCycleCnt_DN     : unsigned(STABLE_CYCLE_WIDTH-1 downto 0);
  signal UnstableCycleCnt_DP, UnstableCycleCnt_DN : unsigned(UNSTABLE_CYCLE_WIDTH-1 downto 0);
  --
  signal STACurrentLock_DP, STACurrentLock_DN     : std_logic;
  signal STALockCnt_DP, STALockCnt_DN             : unsigned(STABLE_CYCLE_WIDTH-1 downto 0);
  --


begin

  Lock_SO <= CurrentLock_DP when OpMode_SI = '1' else STACurrentLock_DP;

  -- NORMAL MODE: Lock signal assert/de-assert logic:
  --    Count consecutive cycles in which the Aberration_DI signal stays within the
  --    tolerance specified by LockTolerance_DI. If the number of cycles specified
  --    by StableCycles_DI is reached the lock signal is asserted. Then,
  --    if the lock signal is high, consecutive cycles are counted in which the
  --    error is out of tolerance. If the counter reaches the number of cycles
  --    specified by UnstableCycles_DI, the lock is deasserted (i.e., the FLL is
  --    out of tune)

  process (Aberration_DI, CurrentLock_DP, LockReset_SI, LockTolerance_DI,
           StableCycleCnt_DP, StableCycles_DI, UnstableCycleCnt_DP,
           UnstableCycles_DI) is
  begin

    CurrentLock_DN      <= CurrentLock_DP;
    --
    UnstableCycleCnt_DN <= UnstableCycleCnt_DP;
    StableCycleCnt_DN   <= StableCycleCnt_DP;
    --
    if unsigned(abs(signed(Aberration_DI))) < unsigned(LockTolerance_DI) then
      StableCycleCnt_DN   <= StableCycleCnt_DP + 1;
      UnstableCycleCnt_DN <= (others => '0');
      if StableCycleCnt_DP = unsigned(StableCycles_DI) then
        StableCycleCnt_DN <= StableCycleCnt_DP;
        CurrentLock_DN    <= '1';
      end if;
    else
      StableCycleCnt_DN   <= (others => '0');
      UnstableCycleCnt_DN <= UnstableCycleCnt_DP+1;
      if UnstableCycleCnt_DP = unsigned(UnstableCycles_DI) then
        UnstableCycleCnt_DN <= UnstableCycleCnt_DP;
        CurrentLock_DN      <= '0';
      end if;
    end if;
    --
    if LockReset_SI = '1' then
      CurrentLock_DN      <= '0';
      UnstableCycleCnt_DN <= (others => '0');
      StableCycleCnt_DN   <= (others => '0');
    end if;
  end process;


  process (RefClk_CI, Rst_RBI) is
  begin  -- process
    if Rst_RBI = '0' then         -- asynchronous reset (active low)
      CurrentLock_DP      <= '0';
      StableCycleCnt_DP   <= (others => '0');
      UnstableCycleCnt_DP <= (others => '0');
    elsif RefClk_CI'event and RefClk_CI = '1' then  -- rising clock edge
      if OpMode_SI = '1' then
        CurrentLock_DP      <= CurrentLock_DN;
        StableCycleCnt_DP   <= StableCycleCnt_DN;
        UnstableCycleCnt_DP <= UnstableCycleCnt_DN;
      end if;
    end if;
  end process;



  -- STAND-ALONE MODE: Lock signal assert/de-assert logic:
  --  Count the dco clock cycles up until a configurable number, and
  --  if reached assert the lock signal

  process (LockReset_SI, STACurrentLock_DP, STALockCnt_DP, StableCycles_DI)
  begin  -- process
    STALockCnt_DN     <= STALockCnt_DP+1;
    STACurrentLock_DN <= STACurrentLock_DP;
    --
    if STALockCnt_DP = unsigned(StableCycles_DI) then
      STALockCnt_DN     <= STALockCnt_DP;
      STACurrentLock_DN <= '1';
    end if;
    --
    if LockReset_SI = '1' then
       STACurrentLock_DN <= '0';
       STALockCnt_DN     <= (others => '0');
    end if;
  end process;


  process (DCOClk_CI, Rst_RBI)
  begin  -- process
    --
    if Rst_RBI = '0' then         -- asynchronous reset (active low)
      STACurrentLock_DP <= '0';
      STALockCnt_DP     <= (others => '0');
      --
    elsif DCOClk_CI'event and DCOClk_CI = '1' then  -- rising clock edge
      if (OpMode_SI = '0') and (STACurrentLock_DP = '0') then
        STACurrentLock_DP <= STACurrentLock_DN;
        STALockCnt_DP     <= STALockCnt_DN;
      end if;
    end if;
    --
  end process;

end rtl;

