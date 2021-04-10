-------------------------------------------------------------------------------
-- Title      : synchronizer
-- Project    : Frequency Locked Loop (FLL) - IIS/DZ
-------------------------------------------------------------------------------
-- File       : FLL_synchroedge.vhd
-- Author     : David Bellasi <bellasi@ee.ethz.ch>
-- Company    : Integrated Systems Laboratory, ETH Zurich
-- Created    : 2016-10-18
-------------------------------------------------------------------------------
-- Description: multi-stage one-way synchronizer with edge detection
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
-- 2017-01-27  3.1      muheim              change it to tech independens
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FLL_synchroedge is
  generic(
    SYNCHRONIZERS : natural   := 3;     -- Number of synchronizers (min 3)
    RESET_VALUE   : std_logic := '0'    -- Output value at reset
    );
  port(
    AsyncSignal_DI : in  std_logic;
    RisingEdge_DO  : out std_logic;
    En_SI          : in  std_logic;
    Clk_CI         : in  std_logic;
    Rst_RBI        : in  std_logic
    );
end FLL_synchroedge;

architecture rtl of FLL_synchroedge is
  signal Sync_DP, Sync_DN : std_logic_vector(SYNCHRONIZERS-1 downto 0);
begin

  Sync_DN       <= Sync_DP(SYNCHRONIZERS-2 downto 0) & AsyncSignal_DI;
  RisingEdge_DO <= Sync_DP(Sync_DP'high-1) and (not Sync_DP(Sync_DP'high));

  pClock : process(Clk_CI, Rst_RBI)
  begin
    if Rst_RBI = '0' then
      Sync_DP <= (others => RESET_VALUE);
    elsif Clk_CI'event and Clk_CI = '1' then
      if En_SI = '1' then
        Sync_DP <= Sync_DN;
      end if;
    end if;
  end process;

end rtl;
