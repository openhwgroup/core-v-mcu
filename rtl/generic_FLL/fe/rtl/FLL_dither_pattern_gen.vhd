-------------------------------------------------------------------------------
-- Title      : Dither Pattern Generator
-- Project    : Frequency Locked Loop (FLL) - IIS/DZ
-------------------------------------------------------------------------------
-- File       : FLL_dither_pattern_gen.vhd
-- Author     : David Bellasi <bellasi@ee.ethz.ch>
-- Company    : Integrated Systems Laboratory, ETH Zurich
-- Created    : 2016-10-18
-------------------------------------------------------------------------------
-- Description: Generates a sequence of ideally spaced zeros and ones
--              in which the percentage of ones corresponds to the
--              fractional number present at the input of the unit.
--              The circuit that produces such a sequence is a simple
--              sigma-delta loop with one-bit quantizer.
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

entity FLL_dither_pattern_gen is
  generic (
    FRACTIONAL_BITS : natural := 7
    );
  port(
    -- inputs
    Frac_DI          : in  std_logic_vector(FRACTIONAL_BITS-1 downto 0);  -- fractional bits input
    Update_SI        : in  std_logic;
    --
    -- outputs
    DitherPattern_DO : out std_logic;
    --
    -- general signals
    En_SI            : in  std_logic;
    Clk_CI           : in  std_logic;  -- DCO clock or any integer division of it
    Rst_RBI          : in  std_logic    -- reset
    );
end FLL_dither_pattern_gen;


architecture rtl of FLL_dither_pattern_gen is

  signal Frac_DP, Frac_DN         : std_logic_vector(FRACTIONAL_BITS-1 downto 0);
  signal Feedback_DN, Feedback_DP : unsigned(FRACTIONAL_BITS downto 0);

begin

  -----------------------------------------------------------------------------
  -- Dither pattern generator (sigma delta loop with single bit quantizer)
  -----------------------------------------------------------------------------

  Frac_DN <= Frac_DI;

  Feedback_DN      <= unsigned("0" & Frac_DP) + unsigned("0" & Feedback_DP(FRACTIONAL_BITS-1 downto 0));
  DitherPattern_DO <= Feedback_DP(FRACTIONAL_BITS);

  mem : process (Clk_CI, Rst_RBI)
  begin  -- process mem
    if Rst_RBI = '0' then               -- asynchronous reset (active low)
      Feedback_DP <= (others => '0');
      Frac_DP     <= (others => '0');
    elsif Clk_CI'event and Clk_CI = '1' then  -- rising clock edge
      if En_SI = '1' then
        Feedback_DP <= Feedback_DN;
        if Update_SI = '1' then
          Frac_DP <= Frac_DN;
        end if;
      end if;
    end if;
  end process mem;

end rtl;

