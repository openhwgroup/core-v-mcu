-------------------------------------------------------------------------------
-- Title      : loop filter and loop control
-- Project    : Frequency Locked Loop (FLL) - IIS/DZ
-------------------------------------------------------------------------------
-- File       : FLL_loop_filter_and_control.vhd
-- Author     : David Bellasi <bellasi@ee.ethz.ch>
-- Company    : Integrated Systems Laboratory, ETH Zurich
-- Created    : 2016-10-18
-------------------------------------------------------------------------------
-- Description: Loop filter (= integrator with gain) and
--              control and configuration facilities
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
-- 2017-06-10  3.2      bellasid            remove ZeroDelta_SI
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FLL_loop_filter is
  generic (
    CLK_PERIOD_QUANTIZER_WIDTH : natural := 16;
    GAIN_WORDWIDTH             : natural := 4;
    DCO_WORDWIDTH              : natural := 10;
    FRACTIONAL_WORDWIDTH       : natural := 10
    );
  port(
    -- configuration values
    Gain_SI          : in  std_logic_vector(GAIN_WORDWIDTH-1 downto 0);  -- gain value (all fractional bits)
    SetPoint_SI      : in  std_logic_vector(CLK_PERIOD_QUANTIZER_WIDTH-1 downto 0);  -- target clock multiplication factor
    --
    -- from period quantizer
    ActMultFactor_DI : in  std_logic_vector(CLK_PERIOD_QUANTIZER_WIDTH-1 downto 0);  -- measured multiplication factor
    --
    -- state
    Integrator_DI    : in  std_logic_vector(DCO_WORDWIDTH+FRACTIONAL_WORDWIDTH-1 downto 0);
    Integrator_DO    : out std_logic_vector(DCO_WORDWIDTH+FRACTIONAL_WORDWIDTH-1 downto 0);
    --
    -- status
    Aberration_DO    : out std_logic_vector(CLK_PERIOD_QUANTIZER_WIDTH downto 0);
    --
    -- General signals
    Enable_SI        : in  std_logic
    );
end FLL_loop_filter;


architecture rtl of FLL_loop_filter is

  signal Gain_D                : unsigned(GAIN_WORDWIDTH-1 downto 0);
  --
  signal TargetMultFactor_D    : signed(CLK_PERIOD_QUANTIZER_WIDTH downto 0);
  signal ActualMultFactor_D    : signed(CLK_PERIOD_QUANTIZER_WIDTH downto 0);
  signal Delta_D               : signed(CLK_PERIOD_QUANTIZER_WIDTH downto 0);
  signal DeltaExt_D            : signed(CLK_PERIOD_QUANTIZER_WIDTH+FRACTIONAL_WORDWIDTH downto 0);
  signal DeltaExtAmp_D         : signed(CLK_PERIOD_QUANTIZER_WIDTH+FRACTIONAL_WORDWIDTH downto 0);
  signal DeltaShort_D          : signed((1+DCO_WORDWIDTH+FRACTIONAL_WORDWIDTH)-1 downto 0);
  signal Integrator_D          : signed((1+DCO_WORDWIDTH+FRACTIONAL_WORDWIDTH)-1 downto 0);


  ----------------------------------------------------------------------
  -- fixed-point constants   -------------------------------------------
  ----------------------------------------------------------------------

begin

  Gain_D <= unsigned(Gain_SI);

  ActualMultFactor_D <= signed("0" & ActMultFactor_DI) when Enable_SI = '1' else (others => '0');
  TargetMultFactor_D <= signed("0" & SetPoint_SI)      when Enable_SI = '1' else (others => '0');

  Delta_D <= TargetMultFactor_D - ActualMultFactor_D;

  Aberration_DO <= std_logic_vector(Delta_D);

  DeltaExt_D <= signed(std_logic_vector(Delta_D) & std_logic_vector(to_unsigned(0,FRACTIONAL_WORDWIDTH)));

  with to_integer(Gain_D) select
    DeltaExtAmp_D <=
    DeltaExt_D                  when 0,
    SHIFT_RIGHT(DeltaExt_D, 1)  when 1,
    SHIFT_RIGHT(DeltaExt_D, 2)  when 2,
    SHIFT_RIGHT(DeltaExt_D, 3)  when 3,
    SHIFT_RIGHT(DeltaExt_D, 4)  when 4,
    SHIFT_RIGHT(DeltaExt_D, 5)  when 5,
    SHIFT_RIGHT(DeltaExt_D, 6)  when 6,
    SHIFT_RIGHT(DeltaExt_D, 7)  when 7,
    SHIFT_RIGHT(DeltaExt_D, 8)  when 8,
    SHIFT_RIGHT(DeltaExt_D, 9)  when 9,
    SHIFT_RIGHT(DeltaExt_D, 10) when 10,
    (others => '0')             when others;

  -- Clamp to min (negative) and max (positive) value corresponding to the signed wordwidth of the Integrator.

  DeltaShort_D <= to_signed(2**(DeltaShort_D'length-1)-1,DeltaShort_D'length) when DeltaExtAmp_D > to_signed(2**(DeltaShort_D'length-1)-1,DeltaShort_D'length) else
                  to_signed(-2**(DeltaShort_D'length-1),DeltaShort_D'length) when DeltaExtAmp_D < to_signed(-2**(DeltaShort_D'length-1),DeltaShort_D'length) else
                  DeltaExtAmp_D(DeltaShort_D'length-1 downto 0);

  -- Note that Intergrator_DI is non-negative and is one bit shorter than Integrator_D.

  Integrator_D <= signed("0" & Integrator_DI) + DeltaShort_D;

  -- Saturate to max DCO input value and ensure non-negativity
  Integrator_DO <= (others => '1') when ((Integrator_D < 0) and (DeltaShort_D >= 0)) else
                   (others => '0') when ((Integrator_D < 0) and (DeltaShort_D < 0)) else
                   std_logic_vector(Integrator_D(Integrator_DO'length-1 downto 0));


end rtl;

